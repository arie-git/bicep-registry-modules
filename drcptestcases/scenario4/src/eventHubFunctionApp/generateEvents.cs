using System.Diagnostics.Tracing;
using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Extensions.Abstractions;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Azure.Messaging.EventHubs;

namespace APGAM.CCC
{
    public class generateEvents
    {
        private readonly ILogger _logger;

        public generateEvents(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<generateEvents>();
        }

        [Function(nameof(GenerateEvents))]
        [EventHubOutput("dest", Connection = "EventHubConnection")]
        public string GenerateEvents([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processing a request.");

            // read the contents of the posted data into a string
            string requestQuery = req.Query.ToString() ?? string.Empty;
            string requestBody = new StreamReader(req.Body).ReadToEnd();

            var message = $"Output message created at {DateTime.Now}. \nQuery: {requestQuery} \nBody: {requestBody}";

            _logger.LogInformation("First Event Hubs triggered message: {msg}", message.ToString());

            return message;
        }

    }
}
