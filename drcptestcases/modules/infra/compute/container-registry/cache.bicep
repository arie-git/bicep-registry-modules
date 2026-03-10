param name string

param acrName string

@description('E.g. \'mcr.microsoft.com/dotnet/samples\'')
param sourceRepositoryPath string

@description('E.g. \'samples\'')
param targetRepositoryPath string

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

// TODO: change API when cache rules are out of preview
resource acrCacheRule 'Microsoft.ContainerRegistry/registries/cacheRules@2023-01-01-preview' = {
  name: name
  parent: acr
  properties: {
    sourceRepository: sourceRepositoryPath
    targetRepository: targetRepositoryPath
  }
}
