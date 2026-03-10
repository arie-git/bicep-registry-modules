using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Azure.Identity;
using Azure.Storage;
using Azure.Storage.Files.Shares;
using Azure.Storage.Files.Shares.Models;
using Newtonsoft.Json;

namespace backend_dotnet
{
    public static class CosmosDbTrigger
    {
        // Data model
        public class MyItem
        {
            [JsonProperty(PropertyName = "id")]
            public Guid Id { get; set; }

            [JsonProperty(PropertyName = "name")]
            public string Name { get; set; }
        }

        [FunctionName("CosmosDbTrigger")]
        // https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-cosmosdb-v2-trigger?tabs=python-v2%2Cin-process%2Cextensionv4&pivots=programming-language-csharp
        public static void Run([CosmosDBTrigger(
            databaseName: "testdb",
            containerName: "testcnt",
            Connection = "CosmosDbConnection",
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true)]IReadOnlyList<MyItem> input,
            ILogger log)
        {
            if (input != null && input.Count > 0)
            {
                log.LogInformation("Documents modified " + input.Count);
                log.LogInformation("First document Id " + input[0].Id);
                log.LogInformation("First document Id " + input[0].Name);
            }

            var accountName = Environment.GetEnvironmentVariable("AzureFiles_accountName");
            var accountKey = Environment.GetEnvironmentVariable("AzureFiles_accountKey");
            var shareName = Environment.GetEnvironmentVariable("AzureFiles_shareName");
            //var connectionString = Environment.GetEnvironmentVariable("AzureFiles_connectionString");

            var shareClientOptions = new ShareClientOptions();
            shareClientOptions.ShareTokenIntent = ShareTokenIntent.Backup;
            // var credential = new DefaultAzureCredential();

            // Create a SharedKeyCredential that we can use to authenticate
            StorageSharedKeyCredential credential = new StorageSharedKeyCredential(accountName, accountKey);

            log.LogInformation("Creating client to " + $"https://{accountName}.file.core.windows.net/");
            var serviceClient = new ShareServiceClient(new Uri($"https://{accountName}.file.core.windows.net/"), credential, shareClientOptions);
            //var serviceClient = new ShareServiceClient(new Uri($"https://{accountName}.file.core.windows.net/"), credential);
            //var serviceClient = new ShareServiceClient(connectionString, shareClientOptions);

            log.LogInformation($"Creating client to {shareName} share.");
            var shareClient = serviceClient.GetShareClient(shareName);

            // Ensure that the share exists
            if (!shareClient.Exists())
            {
                log.LogInformation($"{shareName} does not exist.");

                // Create the share if it doesn't already exist
                shareClient.Create();

                // Ensure that the share was created
                if (shareClient.Exists())
                {
                    log.LogInformation($"{shareName} created.");
                }
                else
                {
                    throw new System.Exception("Could not create a file share");
                }
            } else {
                log.LogInformation($"{shareName} exists.");

                // Get a reference to the sample directory
                ShareDirectoryClient directory = shareClient.GetDirectoryClient("backend-dotnet");

                // Create the directory if it doesn't already exist
                directory.CreateIfNotExists();

                // Ensure that the directory exists
                if (directory.Exists())
                {
                    log.LogInformation($"Directory exists.");

                    // Get a reference to a file object
                    ShareFileClient fileClient = directory.GetFileClient($"data{DateTime.Now.ToString("yyyyMMddHHmmss")}.txt");

                    MemoryStream stream1 = new MemoryStream(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(input[0],Formatting.None)));
                    stream1.Position = 0;

                    fileClient.Create(stream1.Capacity);

                    log.LogInformation($"Uploading cosmos item to file.");
                    fileClient.Upload(stream1);
                    log.LogInformation($"Finished uploading.");

                }
            }

        }
    }
}
