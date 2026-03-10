import os
from azure.search.documents import SearchClient
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())

index_name = os.getenv("AZURE_SEARCH_INDEX")
endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")


def search_knowledge_base(query: str, credential):
    """
    Search the Azure Cognitive Search index using the provided credential.
    In production, pass OnBehalfOfCredential from the API.
    """
    search_client = SearchClient(
        endpoint=endpoint, index_name=index_name, credential=credential
    )

    results = search_client.search(search_text="*", filter=f"id eq '{query}'", top=3)

    return [
        {
            "id": result["id"],
            "description": result["description"],
            "remediation": result["remediation"],
        }
        for result in results
    ]


if __name__ == "__main__":
    from azure.identity import DefaultAzureCredential
    from pprint import pprint

    test_query = "drcp-aps-18"
    print("Testing with DefaultAzureCredential...")
    pprint(search_knowledge_base(test_query, DefaultAzureCredential()))
