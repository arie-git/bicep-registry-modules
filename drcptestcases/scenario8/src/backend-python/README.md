func init backend-dotnet --python -m V2

cd backend-dotnet

func new --name CosmosDBTrigger --template "Azure Cosmos DB trigger" --authlevel "function"

pip install -r requirements.txt

func start

To publish manually run `func azure functionapp publish <AZURE_APP_NAME>`. For example, `func azure functionapp publish s2c3drcptst0801devweapp-fe`

Until the DRCP firewall allows outgoing 443 traffic, we need to publish from local. Run `func azure functionapp publish s2c3drcptst0801devweapp-be --verbose --build local`

View logs `func azure functionapp logstream <APP_NAME> `