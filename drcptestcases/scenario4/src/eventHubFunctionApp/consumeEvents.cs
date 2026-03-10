using System.Diagnostics.Tracing;
using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Extensions.Abstractions;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Azure.Messaging.EventHubs;
using Azure.Storage.Blobs;

namespace APGAM.CCC
{
    public class consumeEvents
    {
        private readonly ILogger _logger;

        public consumeEvents(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<consumeEvents>();
        }

        [Function(nameof(EventDataBatchFunction))]
        [BlobOutput("dest/{datetime:yyMMddhhmmss}-{rand-guid}-output.txt", Connection= "AzureWebJobsStorage")]
        public string EventDataBatchFunction(
            [EventHubTrigger("dest", ConsumerGroup = "drcptesting", Connection = "EventHubConnection", IsBatched = false)] string eventContent,
            FunctionContext functionContext)
        {
            int contentLength = ((String)eventContent).Length;
            _logger.LogInformation("Event content length: {contentLength}", contentLength);

            return eventContent;
        }
    }
}
