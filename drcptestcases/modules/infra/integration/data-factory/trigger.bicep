@description('Name of the data factory. Required.')
param adfName string
@description('Name of the trigger. Required.')
param triggerName string
@description('Type of trigger. Required.')
@allowed([
    'BlobEventsTrigger'
    'BlobTrigger'
    'ChainingTrigger'
    'CustomTrigger'
    'RerunTumblingWindowTrigger'
    'ScheduleTrigger'
    'TumblingWindowTrigger'
  ]
)
param triggerType string
@description('Resource Id of Blob for Blob Event Trigger. Optional.')
param blobResourceId string = ''
@description('Folder path of Blob for Blob Trigger. Optional.')
param blobFolderPath string = ''
@description('Name of Linked service for Blob Event Trigger. Optional.')
param linkedServiceReference string = ''
@description('Concurrency count. Optional.')
param concurrency int = 2
@description('Frequnecy of the schedule for Scheduled Trigger. Optional.')
@allowed([
  'Day'
  'Hour'
  'Minute'
  'Month'
  'NotSpecified'
  'Week'
  'Year'
])
param scheduleFrequency string = 'Day'
@description('Start time of Scheduled Trigger. Optional.')
param scheduleStartTime string //2021-01-01T00:00:00Z
@description('End time of Scheduled Trigger. Optional.')
param scehduleEndTime string //2021-02-01T00:00:00Z
@description('Timezoen for Scheduled Trigger. Optional.')
param scheduleTimeZone string //UTC, W. Europe Standard Time
@description('Interval for Scheduled Trigger. Optional.')
param scheduleInterval int = 1

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
}

resource blobEventTrigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = if (triggerType == 'BlobEventsTrigger') {
  name: triggerName
  parent: adf
  properties: {
    type: 'BlobEventsTrigger'
    typeProperties: {
      events: [
        'Microsoft.Storage.BlobCreated'
        'Microsoft.Storage.BlobDeleted'
      ]
      scope: blobResourceId
    }
  }
}

resource blobTrigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = if (triggerType == 'BlobTrigger') {
  name: triggerName
  parent: adf
  properties: {
    type: 'BlobTrigger'
    typeProperties: {
      folderPath: blobFolderPath
      linkedService: {
        referenceName: linkedServiceReference
        type: 'LinkedServiceReference'
      }
      maxConcurrency: concurrency
    }
  }
}

resource scheduleTrigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = if (triggerType == 'ScheduleTrigger') {
  name: triggerName
  parent: adf
  properties: {
    type: 'ScheduleTrigger'
    typeProperties: {
      recurrence: {
        endTime: scehduleEndTime
        frequency: scheduleFrequency
        interval: scheduleInterval
        startTime: scheduleStartTime
        timeZone: scheduleTimeZone
      }
    }
  }
}

resource tumblingWindowTrigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = if (triggerType == 'TumblingWindowTrigger') {
  name: triggerName
  parent: adf
  properties: {
    pipeline: {}
    type: 'TumblingWindowTrigger'
    typeProperties: {
      frequency: scheduleFrequency
      interval: scheduleInterval
      maxConcurrency: concurrency
      startTime: scheduleStartTime
    }
  }
}