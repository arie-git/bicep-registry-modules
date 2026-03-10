using System;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;


namespace APG.CCC
{
    public class CosmosDataRelay
    {
        private readonly RelayOptions _dataRelayOptions;
        private readonly ILogger<CosmosDataRelay> _logger;

        public CosmosDataRelay(IOptions<RelayOptions> dataRelayOptions, ILogger<CosmosDataRelay> logger)
        {
            _dataRelayOptions = dataRelayOptions?.Value ?? throw new ArgumentNullException(nameof(dataRelayOptions));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        [FunctionName(nameof(CosmosDataRelay))]
        public Task RunAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequestMessage httpRequest,
            [CosmosDB(
            databaseName: "%DataRelay:CosmosDBDatabaseName%",
            containerName: "%DataRelay:CosmosDBContainerName%",
            Connection = "DataRelay:CosmosDBConnectionString"
            )]IAsyncCollector<dynamic> cosmosDatabase
            )
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            if (httpRequest?.Content == null)
            {
                throw new ArgumentNullException(nameof(httpRequest), "HttpRequest or its content is null.");
            }

            if (cosmosDatabase == null)
            {
                throw new ArgumentNullException(nameof(cosmosDatabase));
            }

            return RunInternalAsync(httpRequest, cosmosDatabase);
        }

        private async Task<HttpResponseMessage> RunInternalAsync(HttpRequestMessage httpRequest, IAsyncCollector<dynamic> cosmosDatabase)
        {
            string jsonRequest = null;
            try
            {
                jsonRequest = await httpRequest.Content.ReadAsStringAsync();

                _logger.LogInformation($"Forward message: {jsonRequest}");

                DeviceMessage msg = JsonConvert.DeserializeObject<DeviceMessage>(jsonRequest);
                await cosmosDatabase.AddAsync(new
                {
                    id = System.Guid.NewGuid().ToString(),
                    Sequence = msg.Sequence,
                    Eui = msg.Eui,
                    payload = msg.Payload,
                    ts = msg.Timestamp
                });

                return new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error handling message: {jsonRequest}.");
                return new HttpResponseMessage(HttpStatusCode.InternalServerError)
                {
                    Content = new StringContent(ex.Message, Encoding.UTF8, "application/json")
                };
            }
        }
    }
}

