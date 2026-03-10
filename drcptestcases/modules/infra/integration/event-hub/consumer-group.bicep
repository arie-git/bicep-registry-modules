@description('Name of the Event Hub namespace. Required.')
param eventHubNamespaceName string

@description('The name of the Event Hub.')
param eventHubName string

@description('The name of the consumer group in the Event Hub.')
param name string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubNamespaceName
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' existing = {
  name: eventHubName
  parent: eventHubNamespace
}

resource evhConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2023-01-01-preview' = {
  name: name
  parent: eventHub
  properties:{
    userMetadata: 'DRCP Tests generated consumer group'
  }
}
