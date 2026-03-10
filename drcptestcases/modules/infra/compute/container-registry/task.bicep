param acrName string
param name string
param location string = resourceGroup().location

@description('The URL(absolute or relative) of the source context for the task step. See https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/container-registry/container-registry-tasks-overview.md#context-locations')
param dockerContextPath string = ''
@description('The Docker file path relative to the source context.')
param dockerFilePath string = 'Dockerfile'
@description('The fully qualified image names including the repository and tag.')
param dockerImageName string = ''

param doTaskRun bool = false

param enableTimeTrigger bool = false

@description('Cron config of scheduled task runs')
param cronSchedule string = '${dateTimeAdd(utcNow('u'),'PT11M', 'mm HH dd MM')} *' //'0 * * * *'

param forceUpdateTag string = utcNow('yyyyMMddHHmmss')

param agentPoolName string = ''

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

resource acrTask 'Microsoft.ContainerRegistry/registries/tasks@2019-06-01-preview' = {
  name: name
  location: location
  parent: acr
  properties: {
    status: 'Enabled'
    agentPoolName: agentPoolName != '' ? agentPoolName : null
    agentConfiguration: {
      cpu: 2
    }
    platform: {
      os: 'Linux'
      architecture: 'amd64'
    }
    step : {
      contextPath: dockerContextPath
      dockerFilePath: dockerFilePath
      type: 'Docker'
      imageNames: [
        dockerImageName
      ]
      isPushEnabled: true
    }
    trigger: {
      timerTriggers: enableTimeTrigger ? [
        {
          name: '${name}-cron'
          schedule: cronSchedule
        }
      ] : null
    }
  }
}

resource acrTaskRun 'Microsoft.ContainerRegistry/registries/taskRuns@2019-06-01-preview' = if(doTaskRun) {
  name: name
  parent: acr
  location: location
  properties: {
    forceUpdateTag: forceUpdateTag
    runRequest:{
      isArchiveEnabled: true
      type: 'TaskRunRequest'
      taskId: acrTask.id
    }
  }
}

output id string = acrTask.id
output imageNames array = acrTask.properties.step.imageNames
