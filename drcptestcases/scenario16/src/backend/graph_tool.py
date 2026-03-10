from azure.identity import DefaultAzureCredential
from azure.mgmt.resourcegraph import ResourceGraphClient
from azure.mgmt.resourcegraph.models import QueryRequest
from azure.mgmt.resource import SubscriptionClient


def fetch_subscriptions(credential):
    sub_client = SubscriptionClient(credential)

    return [
        {"id": s.subscription_id, "name": s.display_name}
        for s in sub_client.subscriptions.list()
    ]


def fetch_policy_violations(subscription_id, credential):
    graph_client = ResourceGraphClient(credential)

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

    try:
        results = graph_client.resources(query)
        clean_data = [
            {
                "policyDefinitionReferenceId": row.get("policyDefinitionReferenceId"),
                "policyDefinitionId": row.get("policyDefinitionId"),
                "subscriptionId": row.get("subscriptionId"),
                "resourceGroup": row.get("resourceGroup"),
                "resourceType": row.get("resourceType"),
                "policyDefinitionName": row.get("policyDefinitionName"),
                "policyDefinitionDisplayName": row.get("policyDefinitionDisplayName"),
                "policyDefinitionDescription": row.get("policyDefinitionDescription"),
                "policyDefinitionMode": row.get("policyDefinitionMode"),
                "policyDefinitionControlId": row.get("policyDefinitionControlId"),
            }
            for row in results.data
        ]
        return clean_data
    except Exception as e:
        raise RuntimeError(f"Error executing Resource Graph query: {e}")


if __name__ == "__main__":
    from pprint import pprint
    from azure.identity import DefaultAzureCredential

    # Use DefaultAzureCredential for local testing
    credential = DefaultAzureCredential()

    print("\n=== Testing fetch_subscriptions() ===")
    try:
        subs = fetch_subscriptions(credential)
        pprint(subs)
    except Exception as e:
        print(f"Error fetching subscriptions: {e}")

    print("\n=== Testing fetch_policy_violations() ===")
    try:
        test_subscription = "cd63e258-8f0c-40f8-bfe5-d6d7e883c4fa"
        violations = fetch_policy_violations(test_subscription, credential)
        pprint(violations[:3])  # Show first 3 for brevity
    except Exception as e:
        print(f"Error fetching policy violations: {e}")
