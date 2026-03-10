// ADF general parameters
@description('Name of the data factory. Required.')
param name string
@description('Location of the data factory.')
param location string = resourceGroup().location
@description('Tags of the data factory.')
param tags object

@description('Choose whether to connect your self-hosted integration runtime to Azure Data Factory via public endpoint or private endpoint. This applies to self-hosted integration runtime running either on premises or inside customer managed Azure virtual network')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

// Repository support
@description('If to enable the source repository integration on data factory. Default: false.')
param enableRepo bool = false
@description('Repository account name.')
param repoAccountName string = ''
@description('Repository project name.')
param repoProjectName string = ''
@description('Repository name.')
param repositoryName string = ''
@description('Repository collaboration branch name.')
param repoCollaborationBranch string = ''
@description('Repository folder name.')
param repoRootFolder string = ''
@description('Type of the repository. Options: FactoryGitHubConfiguration, FactoryVSTSConfiguration.')
@allowed([
  'FactoryGitHubConfiguration'
  'FactoryVSTSConfiguration'
])
param repoType string = 'FactoryVSTSConfiguration'

@description('The resource id of the existing log analytics workspace. Required.')
param logAnalyticsWorkspaceId string = ''

// ADF
resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    publicNetworkAccess: publicNetworkAccess
    #disable-next-line BCP225
    repoConfiguration: enableRepo ? {
      accountName: repoAccountName
      projectName: repoProjectName
      collaborationBranch: repoCollaborationBranch
      repositoryName: repositoryName
      rootFolder: repoRootFolder
      type: repoType
    } : null
  }
}

resource adfDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (logAnalyticsWorkspaceId != '') {
  scope: adf
  name: '${name}_diagnostic'
  properties: {
    logs: [
      {
        enabled: true
        category: 'ActivityRuns'
      }
      {
        enabled: true
        category: 'PipelineRuns'
      }
      {
        enabled: true
        category: 'TriggerRuns'
      }
      {
        enabled: true
        category: 'SandboxActivityRuns'
      }
      {
        enabled: true
        category: 'SandboxPipelineRuns'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}

output name string = adf.name
output id string = adf.id
output principalId string = adf.identity.principalId
