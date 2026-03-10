
# app.py
from __future__ import annotations
import base64
import json
import logging
import os
from typing import Any, Dict, Optional

import requests
import streamlit as st
import streamlit.components.v1 as components

# ---------------- Logging ----------------
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger("azure-easyauth")

# ---------------- Constants ----------------
GRAPH_BASE = os.getenv("GRAPH_BASE", "https://graph.microsoft.com/v1.0")  # change for national clouds
APP_TITLE = "Azure Auth + Microsoft Graph (Delegated)"
APP_DESC = "Streamlit running behind Azure App Service Authentication (Easy Auth)."

# ---------------- Utilities: identity & tokens ----------------
def _lower_headers() -> Dict[str, str]:
    try:
        headers = st.context.headers or {}
        return {k.lower(): v for k, v in headers.items()}
    except Exception as e:
        logger.debug("st.context.headers not available: %s", e)
        return {}

def decode_client_principal(b64_json: str) -> Dict[str, Any] | None:
    """Decode X-MS-CLIENT-PRINCIPAL payload into a dict."""
    if not b64_json:
        return None
    try:
        payload = json.loads(base64.b64decode(b64_json))
        return payload
    except Exception as e:
        logger.exception("Failed decoding X-MS-CLIENT-PRINCIPAL: %s", e)
        return None

def get_identity() -> Dict[str, Any] | None:
    """
    Try to resolve identity from headers; fallback to /.auth/me on the client.
    Returns a dict with best-effort fields: name, upn, oid, idp
    """
    # Fast path: headers
    h = _lower_headers()
    principal_b64 = h.get("x-ms-client-principal")
    if principal_b64:
        payload = decode_client_principal(principal_b64) or {}
        claims_list = payload.get("claims", [])
        claims = {
            (c.get("typ") or c.get("type")): (c.get("val") or c.get("value"))
            for c in claims_list
        }
        name = (claims.get("name")
                or claims.get("upn")
                or claims.get("preferred_username")
                or h.get("x-ms-client-principal-name"))
        oid = (claims.get("http://schemas.microsoft.com/identity/claims/objectidentifier")
               or claims.get("oid"))
        idp = h.get("x-ms-client-principal-idp") or payload.get("auth_typ")
        return {
            "name": name,
            "upn": claims.get("upn") or claims.get("preferred_username"),
            "oid": oid,
            "idp": idp,
            "raw": payload,
        }

    # Fallback: client-side /.auth/me
    result = components.html(
        """
        <script>
        (async () => {
          try {
            const res = await fetch('/.auth/me', { credentials: 'include' });
            if (!res.ok) { Streamlit.setComponentValue(null); return; }
            const data = await res.json();
            // App Service returns array of provider entries
            // Static Web Apps returns { clientPrincipal: {...} }
            let identity = null;
            if (Array.isArray(data) && data.length > 0) {
               const entry = data[0];
               const claims = entry.user_claims || entry.claims || [];
               const get = (k) => {
                 const c = claims.find(c => (c.typ || c.type) === k);
                 return c ? (c.val || c.value) : null;
               };
               identity = {
                  name: get('name') || entry.name || entry.user_id || null,
                  upn: get('upn') || get('preferred_username') || null,
                  oid: get('oid') || get('http://schemas.microsoft.com/identity/claims/objectidentifier') || null,
                  idp: entry.identity_provider || null,
                  raw: entry
               };
            } else if (data && data.clientPrincipal) {
               const cp = data.clientPrincipal;
               const claims = cp.claims || [];
               const get = (k) => {
                 const c = claims.find(c => (c.typ || c.type) === k);
                 return c ? (c.val || c.value) : null;
               };
               identity = {
                  name: cp.userDetails || get('name'),
                  upn: get('upn') || cp.userDetails,
                  oid: get('oid'),
                  idp: cp.identityProvider,
                  raw: cp
               };
            }
            Streamlit.setComponentValue(identity);
          } catch (e) {
            Streamlit.setComponentValue(null);
          }
        })();
        </script>
        """,
        height=0,
    )
    return result  # Streamlit passes the JS value back

def get_access_token() -> Optional[str]:
    """
    Try to get a delegated access token for Microsoft Graph.
    1) X-MS-TOKEN-AAD-ACCESS-TOKEN header (preferred)
    2) Fallback: /.auth/me
    """
    # 1) Header
    h = _lower_headers()
    token = h.get("x-ms-token-aad-access-token")
    if token:
        return token

    # 2) Fallback via client
    result = components.html(
        """
        <script>
        (async () => {
          try {
            // Attempt refresh to keep tokens current (non-blocking if not supported)
            try { await fetch('/.auth/refresh', { credentials:'include' }); } catch(e) {}
            const res = await fetch('/.auth/me', { credentials:'include' });
            if (!res.ok) { Streamlit.setComponentValue(null); return; }
            const data = await res.json();
            let accessToken = null;
            if (Array.isArray(data) && data.length > 0) {
              const entry = data[0];
              accessToken = entry.access_token || entry.accessToken || null;
            }
            Streamlit.setComponentValue(accessToken);
          } catch (e) {
            Streamlit.setComponentValue(null);
          }
        })();
        </script>
        """,
        height=0,
    )
    return result

def graph_get(path: str, token: str) -> requests.Response:
    return requests.get(f"{GRAPH_BASE}{path}", headers={"Authorization": f"Bearer {token}"}, timeout=20)

def graph_me(token: str) -> Dict[str, Any] | None:
    try:
        r = graph_get("/me", token)
        if r.status_code == 401:
            st.toast("Graph token expired. Click **Refresh tokens**.", icon="⚠️")
        r.raise_for_status()
        return r.json()
    except Exception as e:
        logger.exception("Graph /me failed: %s", e)
        return None

def graph_photo_base64(token: str) -> str | None:
    """
    Returns a base64 image string for user photo (small), or None if not available.
    """
    try:
        r = requests.get(
            f"{GRAPH_BASE}/me/photo/$value",
            headers={"Authorization": f"Bearer {token}"},
            timeout=20,
        )
        if r.status_code == 200 and r.content:
            b64 = base64.b64encode(r.content).decode("ascii")
            return f"data:image/jpeg;base64,{b64}"
    except Exception as e:
        logger.debug("Graph photo not available: %s", e)
    return None

# ---------------- UI helpers ----------------
def init_state():
    st.session_state.setdefault("identity", None)
    st.session_state.setdefault("access_token_present", False)
    st.session_state.setdefault("me", None)
    st.session_state.setdefault("photo_b64", None)

def fetch_identity_and_token():
    with st.spinner("Resolving identity & tokens…"):
        identity = get_identity()
        token = get_access_token()
        st.session_state.identity = identity
        st.session_state.access_token_present = bool(token)
        st.session_state._access_token = token  # keep private; never show

def refresh_tokens():
    # client-side refresh then reload the page
    components.html(
        """
        <script>
         (async () => {
           try { await fetch('/.auth/refresh', { credentials:'include' }); } catch(e) {}
           window.location.reload();
         })();
        </script>
        """,
        height=0,
    )

# ---------------- App layout ----------------
st.set_page_config(page_title=APP_TITLE, page_icon="🔐", layout="wide")
init_state()

# Header
st.title(APP_TITLE)
st.caption(APP_DESC)

# Sidebar: status & actions
with st.sidebar:
    st.header("Status")
    if st.session_state.identity is None:
        st.info("Identity not loaded yet.")
    else:
        idn = st.session_state.identity or {}
        st.success(idn.get("name") or "Signed in user")
        st.write(f"**UPN**: {idn.get('upn') or '—'}")
        st.write(f"**OID**: {idn.get('oid') or '—'}")
        st.write(f"**IdP**: {idn.get('idp') or '—'}")

    token_ok = st.session_state.access_token_present
    st.write("---")
    st.write("**Delegated token present:**", "✅" if token_ok else "❌")

    st.write("---")
    if st.button("Load identity & token", use_container_width=True):
        fetch_identity_and_token()
    if st.button("Refresh tokens", use_container_width=True):
        refresh_tokens()

# Main layout: two columns
col_left, col_right = st.columns([1.2, 1])

with col_left:
    st.subheader("Signed-in user")
    if st.session_state.identity is None:
        fetch_identity_and_token()

    idn = st.session_state.identity
    if not idn:
        st.warning("No identity available. If running locally without Easy Auth, enter a name below.")
        local_name = st.text_input("Local dev name")
        if local_name:
            st.success(f"Hello, {local_name}! 👋 (local)")
    else:
        # User card row with optional photo
        photo_col, info_col = st.columns([0.35, 0.65])
        with photo_col:
            if st.session_state.photo_b64:
                st.image(st.session_state.photo_b64, caption="", width=140)
            else:
                st.image("https://ui-avatars.com/api/?background=0D8ABC&color=fff&name=User", width=140)

        with info_col:
            st.markdown(f"### {idn.get('name') or '—'}")
            st.markdown(f"- **UPN:** {idn.get('upn') or '—'}")
            st.markdown(f"- **Object ID:** {idn.get('oid') or '—'}")
            st.markdown(f"- **Provider:** {idn.get('idp') or '—'}")

        st.write("---")
        btn_cols = st.columns([0.4, 0.6])
        with btn_cols[0]:
            get_me = st.button("Get Graph /me", type="primary")
        with btn_cols[1]:
            get_photo = st.button("Get photo")

        token = st.session_state.get("_access_token")
        if get_me:
            if not token:
                st.error("No delegated access token available. Click **Refresh tokens** in the sidebar.")
            else:
                with st.spinner("Calling Microsoft Graph /me…"):
                    me = graph_me(token)
                if me:
                    st.session_state.me = me
                    st.success("Graph /me retrieved.")
                else:
                    st.error("Failed to retrieve /me.")

        if get_photo:
            if not token:
                st.error("No delegated access token available.")
            else:
                with st.spinner("Retrieving user photo…"):
                    b64 = graph_photo_base64(token)
                if b64:
                    st.session_state.photo_b64 = b64
                    st.toast("Photo loaded.", icon="🖼️")
                else:
                    st.info("No photo available.")

        if st.session_state.me:
            st.write("#### /me payload")
            st.json(st.session_state.me)

with col_right:
    st.subheader("Diagnostics")
    with st.expander("Raw Easy Auth headers (sanitized)"):
        # Show only key auth headers and DO NOT show tokens
        h = _lower_headers()
        safe_keys = [
            "x-ms-client-principal",
            "x-ms-client-principal-name",
            "x-ms-client-principal-id",
            "x-ms-client-principal-idp",
            # Token headers not shown by design; uncomment for controlled debugging only
            # "x-ms-token-aad-access-token", "x-ms-token-aad-id-token"
        ]
        st.json({k: h.get(k) for k in safe_keys if k in h})

    with st.expander("Identity object"):
        st.json(st.session_state.identity or {})

    st.write("---")
    st.caption("Tip: If tokens expire during long sessions, use **Refresh tokens** in the sidebar.")

# Footer
st.write("---")
st.caption("Powered by Azure App Service Authentication (Easy Auth) + Microsoft Graph + Streamlit.")
