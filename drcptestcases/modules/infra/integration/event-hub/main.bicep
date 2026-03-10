@description('Name of the Event Hub namespace. Required.')
param eventHubNamespaceName string

@description('Name of the Event Hub instance. Required.')
param name string

@description('Number of partitions created for the Event Hub. Default is 1. Maximum is 32.')
@minValue(1)
@maxValue(32)
param partitionCount int = 1

@description('Number of days to retain events for this Event Hub. Default is 1. Maximum is 7.')
@minValue(1)
@maxValue(7)
param messageRetentionInDays int = 1

@description('Indicates whether to configure capture for this Event Hub. Required.')
param doConfigureCapture bool

@description('Indicates whether capture is enabled for this Event Hub by default once configured. Default is true.')
param captureEnabled bool = true

@description('Destination for Event Hub capture. Default is EventHubArchive.AzureBlockBlob.')
@allowed([
  'EventHubArchive.AzureBlockBlob'
])
param captureDestination string = 'EventHubArchive.AzureBlockBlob'

@description('Resource id of the storage account to be used to create the blobs. Required for capture configuration to blob destination.')
param storageAccountResourceId string = ''

@description('Name of the blob container to use for Event Hub capture. Required for capture configuration to blob destination.')
param blobContainer string = ''

@description('Format of the Event Hub capture file name. Required for capture configuration. Default is {Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}')
param captureNameFormat string = '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'

@description('Capture encoding format. Default is Avro.')
@allowed([
  'Avro'
  'AvroDeflate'
])
param captureEncoding string = 'Avro'

@description('Interval in seconds to flush captured data to the destination. Default is 300.')
@minValue(60)
@maxValue(900)
param captureIntervalInSeconds int = 300

@description('''The size window defines the amount of data built up in your Event Hub before an capture operation.
Value should be between 10485760 to 524288000 bytes''')
@minValue(10485760)
@maxValue(524288000)
param captureSizeLimitInBytes int = 10485763

@description('Indicates whether to skip empty archives. Default is false.')
param captureSkipEmptyArchives bool = false

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' existing = {
  name: eventHubNamespaceName
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  name: name
  parent: eventHubNamespace
  properties:{
    partitionCount: partitionCount
    messageRetentionInDays: messageRetentionInDays
    captureDescription: !doConfigureCapture ? null : {
      enabled: captureEnabled
      encoding: captureEncoding
      intervalInSeconds: captureIntervalInSeconds
      sizeLimitInBytes: captureSizeLimitInBytes
      skipEmptyArchives: captureSkipEmptyArchives
      destination:{
        name: captureDestination
        properties: {
          storageAccountResourceId: storageAccountResourceId
          blobContainer: blobContainer
          archiveNameFormat: captureNameFormat
        }
        identity: {
          type: 'SystemAssigned'
        }
      }
    }
  }
}

output name string = eventHub.name
output id string = eventHub.id
output status string = eventHub.properties.status
