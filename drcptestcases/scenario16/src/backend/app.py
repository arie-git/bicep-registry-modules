import base64
import json
import os
import logging
import time
from dotenv import load_dotenv, find_dotenv
from flask import Flask, request, jsonify, g
from azure.identity import ManagedIdentityCredential, OnBehalfOfCredential
from azure.core.exceptions import ClientAuthenticationError
from typing import Optional
from llm_tool import get_initial_response, get_followup_response
from graph_tool import fetch_policy_violations, fetch_subscriptions
from search_tool import search_knowledge_base


# -----------------------------------------------------------------------------
# Environment & logging
# -----------------------------------------------------------------------------
load_dotenv(find_dotenv())

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger("backend")

app = Flask(__name__)

TENANT_ID = os.getenv("AZURE_TENANT_ID") or os.getenv("TENANT_ID")
CLIENT_ID = (
    os.getenv("AZURE_CLIENT_ID")            # preferred
    or os.getenv("CLIENT_ID_BACKEND")
    or os.getenv("AZURE_CLIENT_ID_BACKEND")
)
CLIENT_SECRET = os.getenv("AZURE_CLIENT_SECRET") or os.getenv("CLIENT_SECRET")
CLIENT_CERT_PATH = os.getenv("CLIENT_CERT_PATH")
CLIENT_CERT_PASSWORD = os.getenv("CLIENT_CERT_PASSWORD")  # optional for PFX

ARM_SCOPE = "https://management.azure.com/.default"

# Log config presence (without secrets)
logger.info("Backend configuration initialized")
logger.debug({
    "TENANT_ID_present": bool(TENANT_ID),
    "CLIENT_ID_present": bool(CLIENT_ID),
    "CLIENT_SECRET_present": bool(CLIENT_SECRET),
    "CLIENT_CERT_PATH": CLIENT_CERT_PATH,
    "CLIENT_CERT_PASSWORD_present": bool(CLIENT_CERT_PASSWORD),
})

# -----------------------------------------------------------------------------
# Safe JWT peek (for observability; no validation)
# -----------------------------------------------------------------------------
def _peek_jwt(token: str) -> dict:
    """
    Return a safe, non-validating peek at JWT header/payload for observability.
    DO NOT log the full token; only selected claims.
    """
    try:
        parts = token.split(".")
        if len(parts) < 2:
            return {"_peek_error": "invalid_jwt_parts"}

        def b64url_to_json(b64: str):
            padded = b64 + "==="[: (4 - len(b64) % 4) % 4]
            return json.loads(base64.urlsafe_b64decode(padded.encode("utf-8")))

        header = b64url_to_json(parts[0])
        payload = b64url_to_json(parts[1])
        return {
            "alg": header.get("alg"),
            "kid": header.get("kid"),
            "aud": payload.get("aud"),
            "iss": payload.get("iss"),
            "tid": payload.get("tid"),
            "appid": payload.get("appid"),
            "scp": payload.get("scp"),
            "roles": payload.get("roles"),
            "upn": payload.get("upn") or payload.get("preferred_username"),
            "oid": payload.get("oid"),
            "sub": payload.get("sub"),
        }
    except Exception as e:
        return {"_peek_error": f"{type(e).__name__}: {e}"}

# -----------------------------------------------------------------------------
# OBO credential construction
# -----------------------------------------------------------------------------
def _build_obo_credential(user_assertion: str) -> Optional[OnBehalfOfCredential]:
    """
    Build an OnBehalfOfCredential using either client secret or certificate.
    Returns a credential or None on failure.
    """
    if not TENANT_ID or not CLIENT_ID:
        logger.error("AZURE_TENANT_ID / AZURE_CLIENT_ID missing in environment")
        return None

    try:
        if CLIENT_SECRET:
            return OnBehalfOfCredential(
                tenant_id=TENANT_ID,
                client_id=CLIENT_ID,
                client_secret=CLIENT_SECRET,
                user_assertion=user_assertion,
            )

        if CLIENT_CERT_PATH:
            # NOTE: For newer azure-identity versions, the kwarg is 'client_certificate_path'.
            return OnBehalfOfCredential(
                tenant_id=TENANT_ID,
                client_id=CLIENT_ID,
                client_certificate_path=CLIENT_CERT_PATH,
                password=CLIENT_CERT_PASSWORD or None,
                user_assertion=user_assertion,
            )

        logger.error("No backend credential set (AZURE_CLIENT_SECRET or CLIENT_CERT_PATH required)")
        return None
    except Exception as e:
        logger.exception("Failed to construct OnBehalfOfCredential")
        return None

# -----------------------------------------------------------------------------
# Middleware: attach OBO credential to request context
# -----------------------------------------------------------------------------
@app.before_request
def attach_obo_credential():
    """
    Extract Bearer token, log safe claims, create OBO credential, attach to g.obo_cred.
    If anything fails, set g.obo_cred = None (routes handle 401).
    """
    g.obo_cred = None

    auth = request.headers.get("Authorization")
    if not auth or not auth.startswith("Bearer "):
        # No bearer token presented
        logger.debug("Authorization header missing or not Bearer")
        return

    user_assertion = auth.split(" ", 1)[1].strip()

    # Safe debug info
    peek = _peek_jwt(user_assertion)
    logger.info(
        "Incoming token peek: aud=%s iss=%s tid=%s appid=%s scp=%s roles=%s upn=%s",
        peek.get("aud"), peek.get("iss"), peek.get("tid"), peek.get("appid"),
        peek.get("scp"), peek.get("roles"), peek.get("upn"),
    )
    if "_peek_error" in peek:
        logger.warning("JWT peek error: %s", peek["_peek_error"])

    # Build OBO credential
    obo = _build_obo_credential(user_assertion)
    if not obo:
        # Leave g.obo_cred as None; route will return 401
        return

    g.obo_cred = obo

# -----------------------------------------------------------------------------
# Diagnostics endpoint: test OBO to ARM
# -----------------------------------------------------------------------------
@app.route("/debug-token", methods=["GET"])
def debug_token():
    """
    Attempts to exchange the incoming user token for an ARM token via OBO.
    """
    if not getattr(g, "obo_cred", None):
        return jsonify({
            "obo": "missing",
            "hint": "Ensure Authorization: Bearer <token-for-backend-API> is sent"
        }), 401

    try:
        t0 = time.perf_counter()
        tok = g.obo_cred.get_token(ARM_SCOPE)
        ms = int((time.perf_counter() - t0) * 1000)
        return jsonify({
            "obo": "ok",
            "resource": ARM_SCOPE,
            "expires_on": tok.expires_on,
            "acquired_ms": ms
        }), 200
    except ClientAuthenticationError as e:
        logger.exception("OBO ClientAuthenticationError")
        return jsonify({
            "obo": "failed",
            "type": "ClientAuthenticationError",
            "details": str(e),
            "hint": "Check API permissions/consent for ARM and backend credentials"
        }), 401
    except Exception as e:
        logger.exception("Unexpected error during OBO to ARM")
        return jsonify({"obo": "failed", "error": str(e)}), 500

# -----------------------------------------------------------------------------
# Optional friendlier error handlers
# -----------------------------------------------------------------------------
@app.errorhandler(401)
def handle_unauthorized(e):
    return jsonify({
        "error": "unauthorized",
        "hint": "Ensure Bearer token audience matches the backend API (api://<backend-app-id>)"
    }), 401

@app.errorhandler(500)
def handle_server_error(e):
    return jsonify({
        "error": "server_error",
        "hint": "See server logs for stack trace"
    }), 500


# -----------------------------------------------------------------------------
# Routes
# -----------------------------------------------------------------------------
@app.route("/subscriptions", methods=["GET"])
def get_subscriptions():
    if not getattr(g, "obo_cred", None):
        return jsonify({"error": "Missing or invalid token"}), 401
    try:
        data = fetch_subscriptions(g.obo_cred)
        return jsonify(data), 200
    except Exception as e:
        logger.exception("Unhandled error in /subscriptions")
        return jsonify({"error": str(e)}), 500


@app.route("/violations/<subscription_id>", methods=["GET"])
def get_policy_violations(subscription_id):
    if not getattr(g, "obo_cred", None):
        return jsonify({"error": "Missing or invalid token"}), 401
    try:
        data = fetch_policy_violations(subscription_id, g.obo_cred)
        return jsonify(data), 200
    except Exception as e:
        logger.exception("Unhandled error in /violations/%s", subscription_id)
        return jsonify({"error": str(e)}), 500


@app.route("/search/<query>", methods=["GET"])
def search(query):
    if not getattr(g, "obo_cred", None):
        return jsonify({"error": "Missing or invalid token"}), 401
    try:
        data = search_knowledge_base(query, g.obo_cred)
        return jsonify(data), 200
    except Exception as e:
        logger.exception("Unhandled error in /search/%s", query)
        return jsonify({"error": str(e)}), 500


@app.route("/llm/init", methods=["POST"])
def init_llm():
    if not getattr(g, "obo_cred", None):
        return jsonify({"error": "Missing or invalid token"}), 401
    data = request.get_json(silent=True) or {}
    search_text = data.get("search_text")
    control_id = data.get("control_id")
    try:
        result = get_initial_response(search_text, control_id, g.obo_cred)
        return jsonify(result), 200
    except Exception as e:
        logger.exception("Unhandled error in /llm/init")
        return jsonify({"error": str(e)}), 500



@app.route("/llm/chat", methods=["POST"])
def chat_llm():
    if not g.obo_cred:
        return jsonify({"error": "Missing or invalid token"}), 401
    data = request.json
    messages = data.get("messages")  # Full conversation history from frontend
    user_input = data.get("user_input")
    try:
        result = get_followup_response(messages, user_input, g.obo_cred)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)