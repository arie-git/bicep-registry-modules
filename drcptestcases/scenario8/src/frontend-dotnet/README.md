func init frontend-dotnet --worker-runtime dotnet

cd frontend-dotnet

func new --name HttpTrigger1 --template "HTTP trigger" --authlevel "function"

dotnet add package Microsoft.Azure.WebJobs.Extensions.CosmosDB

func start


To publish manually run `func azure functionapp publish <AZURE_APP_NAME>`. For example, `func azure functionapp publish s2c3drcptst0801devweapp-fe`

View logs `func azure functionapp logstream <APP_NAME> `