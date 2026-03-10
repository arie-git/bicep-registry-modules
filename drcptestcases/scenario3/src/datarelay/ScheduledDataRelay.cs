using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Security.Cryptography;
using Microsoft.Extensions.Options;
using System.Net.Http;
using System.Net;
using System.Text;

namespace APG.CCC
{
    public class ScheduledDataRelay
    {
        private readonly RelayOptions _relayOptions;
        private readonly ILogger<ScheduledDataRelay> _logger;

        public ScheduledDataRelay(IOptions<RelayOptions> relayOptions, ILogger<ScheduledDataRelay> logger)
        {
            _relayOptions = relayOptions?.Value ?? throw new ArgumentNullException(nameof(relayOptions));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        //public void Run([TimerTrigger("0 */5 */1 * * *")]TimerInfo myTimer, ILogger log)
        [FunctionName("ScheduledDataRelay")]
        public async Task<HttpResponseMessage> RunAsync
            ([TimerTrigger("0 */5 * * * *")] TimerInfo myTimer, ILogger log)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            try
            {
                await RunInternalAsync();
                return new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {

                return new HttpResponseMessage(HttpStatusCode.InternalServerError)
                {
                    Content = new StringContent(ex.Message, Encoding.UTF8, "application/json")
                };
            }
        }

        private async Task RunInternalAsync()
        {
            _logger.LogInformation($"Forward message");

            //Reference - https://learn.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-dotnet?tabs=net-cli%2Cmanaged-identity%2Croles-azure-portal%2Csign-in-azure-cli%2Cidentity-netcore-cli
            var blobServiceClient = new BlobServiceClient(
                    new Uri("https://" + _relayOptions.StorageAccountName + ".blob.core.windows.net"),
                    new DefaultAzureCredential());
            string payload = "";

            switch (RandomNumberGenerator.GetInt32(1, 5))
            {
                case 1: payload = "CAFE0000CAFE0051"; break;
                case 2: payload = "CAFE0000CAFE0052"; break;
                case 3: payload = "CAFE0000CAFE0053"; break;
                case 4: payload = "CAFE0000CAFE0054"; break;
                case 5: payload = "CAFE0000CAFE0055"; break;
            }

            // Return a container client object
            BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(_relayOptions.ContainerName);
            UnicodeEncoding uniEncoding = new UnicodeEncoding();
            using var stream = new MemoryStream(uniEncoding.GetBytes(payload));
            string fileName = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString() + ".txt";
            BlobClient blobClient = containerClient.GetBlobClient(fileName);
            await blobClient.UploadAsync(stream, new BlobUploadOptions
            {
                HttpHeaders = new BlobHttpHeaders { ContentType = "text/plain" }
            });
        }
    }
}