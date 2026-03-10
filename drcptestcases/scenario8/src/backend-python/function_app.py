import azure.functions as func
import logging
import os

from datetime import date, datetime

from azure.identity import DefaultAzureCredential, ManagedIdentityCredential

from azure.core.exceptions import (
    ResourceExistsError,
    ResourceNotFoundError
)

from azure.storage.fileshare import ShareServiceClient

app = func.FunctionApp()

#https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-cosmosdb-v2-trigger?tabs=python-v2%2Cin-process%2Cfunctionsv2&pivots=programming-language-python#decorators
#https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob#local-development-with-identity-based-connections
@app.function_name(name="CosmosDBTrigger")
@app.cosmos_db_trigger(arg_name="documents",
                        connection="CosmosDbConnection",
                        database_name="testdb",
                        container_name="testcnt",
                        lease_collection_name="leases",
                        create_lease_collection_if_not_exists="true")
def cosmos_function(documents: func.DocumentList) -> str:
    if documents:
        logging.info('Document id: %s, name: %s', documents[0]['id'], documents[0]['name'])

        account_name = os.environ["AzureFiles_accountName"]
        share_name = os.environ["AzureFiles_shareName"]

        # https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/identity/azure-identity#authenticate-with-a-system-assigned-managed-identity
        default_credential = DefaultAzureCredential()

        service_client = ShareServiceClient(account_url=f"https://{account_name}.file.core.windows.net/", credential=default_credential, token_intent='backup')

        try:
            data = documents[0]
            share_name=share_name
            # filename with a current date and time
            dest_file_path= datetime.utcnow().strftime('%Y%m%d%H%M%S') + ".json"

            # Create a ShareFileClient from a connection string
            file_client = service_client.get_share_client(share_name).get_file_client(dest_file_path) #ShareFileClient.from_connection_string(connection_string, share_name, dest_file_path)

            print("Uploading to:", share_name + "/" + dest_file_path)
            file_client.upload_file(data)

        except ResourceExistsError as ex:
            print("ResourceExistsError:", ex.message)

        except ResourceNotFoundError as ex:
            print("ResourceNotFoundError:", ex.message)


@app.function_name(name="HttpTrigger2")
@app.route(route="httpTrigger2", auth_level=func.AuthLevel.ANONYMOUS)
def http_trigger_2(req):
    name = req.params.get('name')
    return f'Hello, {name}!'

@app.function_name(name="HttpTrigger3")
@app.route(route="httpTrigger3", auth_level=func.AuthLevel.ANONYMOUS)
def http_trigger_2(req):
    name = req.params.get('name')

    account_name = os.environ["AzureFiles_accountName"]
    share_name = os.environ["AzureFiles_shareName"]

    # https://learn.microsoft.com/en-us/python/api/overview/azure/identity-readme?view=azure-python#authenticating-with-defaultazurecredential
    default_credential = DefaultAzureCredential()

    service_client = ShareServiceClient(account_url=f"https://{account_name}.file.core.windows.net/", credential=default_credential, token_intent='backup')

    try:
        data = name
        share_name=share_name
        # filename with a current date and time
        dest_file_path= datetime.utcnow().strftime('%Y%m%d%H%M%S') + ".json"

        # Create a ShareFileClient from a connection string
        file_client = service_client.get_share_client(share_name).get_file_client(dest_file_path) #ShareFileClient.from_connection_string(connection_string, share_name, dest_file_path)

        print("Uploading to:", share_name + "/" + dest_file_path)
        file_client.upload_file(data)

    except ResourceExistsError as ex:
        print("ResourceExistsError:", ex.message)

    except ResourceNotFoundError as ex:
        print("ResourceNotFoundError:", ex.message)

    return f'Hello, {name}!'