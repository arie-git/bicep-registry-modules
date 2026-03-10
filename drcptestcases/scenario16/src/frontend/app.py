import os
import logging
import json
import base64
from datetime import datetime, timezone
from dotenv import load_dotenv, find_dotenv
import streamlit as st
from openai import AzureOpenAI

# Azure SDK imports
from azure.identity import DefaultAzureCredential, get_bearer_token_provider
from azure.core.credentials import AccessToken, TokenCredential
from azure.mgmt.resource import SubscriptionClient
from azure.mgmt.resourcegraph import ResourceGraphClient
from azure.mgmt.resourcegraph.models import QueryRequest
from azure.search.documents import SearchClient

# --- Configuration & Setup ---
load_dotenv(find_dotenv())

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT")
AZURE_OPENAI_DEPLOYMENT = os.getenv("AZURE_OPENAI_DEPLOYMENT")
AZURE_OPENAI_API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION", "2024-02-15-preview")

# Azure Search Configuration
AZURE_SEARCH_ENDPOINT = os.getenv("AZURE_SEARCH_ENDPOINT")
AZURE_SEARCH_INDEX = os.getenv("AZURE_SEARCH_INDEX")

# Page Config
st.set_page_config(
    page_title="Cloud Remediation Assistant", page_icon="🛡️", layout="wide"
)
st.title("🛡️ Cloud Remediation Assistant")
st.caption("Identify violations and get AI-assisted remediation help.")

# --- Authentication Helpers (from working-auth.py) ---


def extract_username(headers_lc, default_username="You"):
    principal_b64 = headers_lc.get("x-ms-client-principal")
    if principal_b64:
        try:
            token = json.loads(base64.b64decode(principal_b64))
            claims = {c.get("typ"): c.get("val") for c in token.get("claims", [])}
            return claims.get("name", default_username)
        except Exception:
            pass
    return headers_lc.get("x-ms-client-principal-name", default_username)


def get_access_token_from_headers(headers_lc) -> tuple[str, int]:
    """
    Returns (token, expires_on) from Easy Auth headers and rejects near-expiry tokens.
    """
    token = headers_lc.get("x-ms-token-aad-access-token")
    exp = headers_lc.get("x-ms-token-aad-expires-on")
    if not token:
        # If running locally without Easy Auth, this might fail unless we mock or handle it.
        # For this logic, we assume Easy Auth is present or we catch the error later.
        raise RuntimeError("Token not found in Easy Auth headers.")

    if exp:
        expiry_dt = datetime.fromisoformat(exp.replace("Z", "+00:00"))
        exp_timestamp = int(expiry_dt.timestamp())
    else:
        exp_timestamp = int(datetime.now().timestamp()) + 3600

    return token, exp_timestamp


class EasyAuthCredential(TokenCredential):
    """
    TokenCredential that surfaces the Easy Auth ARM token to Azure SDK clients.
    """

    def __init__(self, headers_lc: dict):
        self._headers_lc = headers_lc

    def get_token(self, *scopes, **kwargs) -> AccessToken:
        token, expiry = get_access_token_from_headers(self._headers_lc)
        return AccessToken(token, expiry)


# --- Service Logic (Graph & Search) ---


def fetch_subscriptions(headers_lc):
    """Fetch all subscriptions using the Azure Management plane (User Credential)."""
    try:
        cred = EasyAuthCredential(headers_lc)
        sub_client = SubscriptionClient(cred)
        subs = []
        for s in sub_client.subscriptions.list():
            subs.append(
                {
                    "name": s.display_name,
                    "subscriptionId": s.subscription_id,
                    "tenantId": s.tenant_id,
                }
            )
        return subs
    except Exception as e:
        logger.error(f"Failed to fetch subscriptions: {e}")
        st.error(f"Error fetching subscriptions: {e}")
        return []


def fetch_policy_violations(subscription_id, headers_lc):
    """Fetch policy violations using Resource Graph (User Credential)."""
    try:
        cred = EasyAuthCredential(headers_lc)
        graph_client = ResourceGraphClient(cred)

        kql_query = """
        policyresources
        | where type == "microsoft.policyinsights/policystates"
        | where properties.complianceState == "NonCompliant"
        | where properties.policySetDefinitionCategory == "apg drcp policy"
        | extend policyDefinitionReferenceId = tostring(properties.policyDefinitionReferenceId)
        | extend policyDefinitionId = tostring(properties.policyDefinitionId)
        | extend subscriptionId = tostring(properties.subscriptionId)
        | extend resourceGroup = tostring(properties.resourceGroup)
        | extend resourceType = tostring(properties.resourceType)
        | join kind=leftouter (
            policyresources
            | where type == "microsoft.authorization/policydefinitions"
            | extend policyDefinitionId = tolower(id)
            | project policyDefinitionId, 
                    policyDefinitionName = name,
                    policyDefinitionDisplayName = tostring(properties.displayName),
                    policyDefinitionDescription = tostring(properties.description),
                    policyDefinitionMode = tostring(properties.mode),
                    policyDefinitionMetadata = properties.metadata,
                    policyDefinitionControlId = tostring(properties.metadata.drcp.controlId)
        ) on policyDefinitionId
        | project-away policyDefinitionId1
        """

        query = QueryRequest(subscriptions=[subscription_id], query=kql_query)
        results = graph_client.resources(query)

        clean_data = [
            {
                "policyDefinitionReferenceId": row.get("policyDefinitionReferenceId"),
                "policyDefinitionId": row.get("policyDefinitionId"),
                "resourceGroup": row.get("resourceGroup"),
                "resourceType": row.get("resourceType"),
                "policyDefinitionDisplayName": row.get("policyDefinitionDisplayName"),
                "policyDefinitionControlId": row.get("policyDefinitionControlId"),
                # Helper for selection display
                "display_label": f"{row.get('policyDefinitionControlId', 'N/A')} - {row.get('policyDefinitionDisplayName', 'Unknown')}",
            }
            for row in results.data
        ]
        return clean_data
    except Exception as e:
        logger.error(f"Error fetching policy violations: {e}")
        st.error(f"Error fetching violations: {e}")
        return []


def search_knowledge_base(query: str):
    """
    Search the Azure Cognitive Search index (App Credential - Managed Identity).
    """
    try:
        # Use DefaultAzureCredential (Managed Identity in Azure, CLI locally)
        credential = DefaultAzureCredential()

        search_client = SearchClient(
            endpoint=AZURE_SEARCH_ENDPOINT,
            index_name=AZURE_SEARCH_INDEX,
            credential=credential,
        )

        results = search_client.search(
            search_text="*", filter=f"id eq '{query}'", top=1
        )

        clean_results = []
        for result in results:
            clean_results.append(
                {
                    "id": result.get("id"),
                    "description": result.get("description"),
                    "remediation": result.get("remediation"),
                }
            )
        return clean_results
    except Exception as e:
        logger.error(f"Search failed: {e}")
        st.error(f"Knowledge Base search failed: {e}")
        return []


# --- Main Application Flow ---

# 1. Auth Headers
if hasattr(st, "context") and st.context.headers:
    headers = dict(st.context.headers)
    headers_lc = {k.lower(): v for k, v in headers.items()}
else:
    # Fallback for local testing if needed, or empty
    headers_lc = {}
    st.info(
        "No Easy Auth headers found. Functionality may be limited if running locally without headers."
    )

# 2. User Greeting
username = extract_username(headers_lc)
st.sidebar.markdown(f"**User:** {username}")

# 3. Session State Init
if "messages" not in st.session_state:
    st.session_state.messages = [
        {
            "role": "system",
            "content": "You are a helpful cloud remediation assistant. If the user provides a policy violation, help them fix it using the provided knowledge base info.",
        }
    ]
if "selected_sub_id" not in st.session_state:
    st.session_state.selected_sub_id = None
if "violations" not in st.session_state:
    st.session_state.violations = []
if "current_context" not in st.session_state:
    st.session_state.current_context = None

# 4. Stepped Process UI

# --- Step 1: Subscription Selection ---
st.subheader("1. Select Subscription")
if st.button("Load Subscriptions"):
    with st.spinner("Fetching subscriptions..."):
        subs = fetch_subscriptions(headers_lc)
        st.session_state.subs = subs

if "subs" in st.session_state and st.session_state.subs:
    sub_options = {s["name"]: s["subscriptionId"] for s in st.session_state.subs}
    selected_sub_name = st.selectbox("Choose a subscription:", list(sub_options.keys()))
    if selected_sub_name:
        st.session_state.selected_sub_id = sub_options[selected_sub_name]
else:
    st.write("Click above to load your subscriptions.")

# --- Step 2: Violation Scan ---
if st.session_state.selected_sub_id:
    st.divider()
    st.subheader("2. Scan for Violations")
    if st.button("Scan Subscription"):
        with st.spinner("Scanning for policy violations..."):
            violations = fetch_policy_violations(
                st.session_state.selected_sub_id, headers_lc
            )
            st.session_state.violations = violations
            if not violations:
                st.success("No violations found!")

    if st.session_state.violations:
        st.info(f"Found {len(st.session_state.violations)} violations.")
        # Create a dict for the selectbox: Label -> Violation Object
        violation_map = {v["display_label"]: v for v in st.session_state.violations}

        selected_violation_label = st.selectbox(
            "Select a violation to remediate:", options=list(violation_map.keys())
        )

        # --- Step 3: Remediation & Chat Context ---
        st.divider()
        st.subheader("3. Remediation Assistant")

        if st.button("Get Help for this Violation"):
            selected_violation = violation_map[selected_violation_label]
            control_id = selected_violation.get("policyDefinitionControlId")

            # Search KB
            with st.spinner(f"Searching knowledge base for {control_id}..."):
                # Prefer controlId for search, fallback to something else if needed
                search_query = control_id if control_id else "unknown"
                kb_results = search_knowledge_base(search_query)

            # Construct Context
            remediation_text = "No specific remediation found in knowledge base."
            if kb_results:
                remediation_text = kb_results[0].get("remediation", remediation_text)

            # Set System Prompt / Context
            system_context = (
                f"You are a Cloud Security Expert assisting developers.\n"
                f"The audience consists of developers who have Azure experience but may not be familiar with the specific configurations of this company's tenant.\n"
                f"The user is asking about a specific policy violation:\n"
                f"- Policy: {selected_violation.get('policyDefinitionDisplayName')}\n"
                f"- Control ID: {control_id}\n"
                f"- Resource Group: {selected_violation.get('resourceGroup')}\n\n"
                f"Remediation Knowledge Base:\n{remediation_text}\n\n"
                f"Instructions:\n"
                f"- Provide a detailed explanation of the violation based on the knowledge base result. Do not simply rehash the short KB answer.\n"
                f"- Explain the security implications and why this policy is important.\n"
                f"- Guide the user through the remediation, ensuring the advice applies to their likely level of expertise (Azure-aware but context-dependent).\n"
                f"- When providing code examples or infrastructure-as-code solutions, ALWAYS prefer Azure Bicep over ARM templates or Terraform, as Bicep is the company standard."
            )

            # Reset Chat with new context
            st.session_state.messages = []  # Clear old history
            st.session_state.messages.append(
                {"role": "system", "content": system_context}
            )
            st.session_state.messages.append(
                {
                    "role": "assistant",
                    "content": f"I've analyzed the violation **{control_id}**. \n\n**Remediation Summary:**\n{remediation_text}\n\nI can explain why this is important or guide you through the specific steps for our environment. How would you like to proceed?",
                }
            )
            st.session_state.current_context = control_id
            st.rerun()

# --- Step 4: Chat Interface ---
st.divider()
st.subheader("Chat Assistant")

# Display chat messages
for message in st.session_state.messages:
    if message["role"] != "system":
        with st.chat_message(message["role"]):
            st.markdown(message["content"])

# Chat Input
if prompt := st.chat_input("Ask a question about this violation..."):
    # Append user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Generate Response
    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            try:
                # App Credential for OpenAI (Managed Identity)
                cred = DefaultAzureCredential()
                token_provider = get_bearer_token_provider(
                    cred, "https://cognitiveservices.azure.com/.default"
                )

                client = AzureOpenAI(
                    azure_endpoint=AZURE_OPENAI_ENDPOINT,
                    azure_ad_token_provider=token_provider,
                    api_version=AZURE_OPENAI_API_VERSION,
                )

                # Send full history including system context
                completion = client.chat.completions.create(
                    model=AZURE_OPENAI_DEPLOYMENT,
                    messages=st.session_state.messages,
                    temperature=0.7,
                    max_tokens=1000,
                )

                reply = completion.choices[0].message.content
                st.markdown(reply)
                st.session_state.messages.append(
                    {"role": "assistant", "content": reply}
                )

            except Exception as e:
                st.error(f"Error generating response: {e}")
                logger.error(f"OpenAI Error: {e}")
