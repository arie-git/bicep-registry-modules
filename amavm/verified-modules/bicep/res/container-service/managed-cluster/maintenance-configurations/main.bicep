metadata name = 'Azure Kubernetes Service (AKS) Managed Cluster Maintenance Configurations'
metadata description = 'This module deploys an Azure Kubernetes Service (AKS) Managed Cluster Maintenance Configurations.'
metadata owner = 'AMCCC'
metadata compliance = 'inherited from parent'
metadata complianceVersion = '20260309'

@description('Required. Maintenance window for the maintenance configuration.')
param maintenanceWindow maintenanceWindowType

@description('Optional. Time slots on which upgrade is not allowed.')
param notAllowedTime notAllowedTimeType?

@description('Optional. If two array entries specify the same day of the week, the applied configuration is the union of times in both entries.')
param timeInWeek timeInWeekType?

@description('Conditional. The name of the parent managed cluster. Required if the template is used in a standalone deployment.')
param managedClusterName string

@description('Optional. Name of the maintenance configuration.')
@allowed([
  'aksManagedAutoUpgradeSchedule'
  'aksManagedNodeOSUpgradeSchedule'
])
param name string = 'aksManagedAutoUpgradeSchedule'

resource managedCluster 'Microsoft.ContainerService/managedClusters@2025-09-01' existing = {
  name: managedClusterName
}

resource aksManagedAutoUpgradeSchedule 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2025-09-01' = {
  name: name
  parent: managedCluster
  properties: {
    maintenanceWindow: maintenanceWindow
    notAllowedTime: notAllowedTime
    timeInWeek: timeInWeek
  }
}

@description('The name of the maintenance configuration.')
output name string = aksManagedAutoUpgradeSchedule.name

@description('The resource ID of the maintenance configuration.')
output resourceId string = aksManagedAutoUpgradeSchedule.id

@description('The resource group the agent pool was deployed into.')
output resourceGroupName string = resourceGroup().name

// Definitions
@export()
type maintenanceConfigurationType = {
  @description('Required. Maintenance window for the maintenance configuration.')
  maintenanceWindow: maintenanceWindowType
  @description('Optional. Time slots on which upgrade is not allowed.')
  notAllowedTime: notAllowedTimeType?
  @description('Optional. If two array entries specify the same day of the week, the applied configuration is the union of times in both entries.')
  timeInWeek: timeInWeekType?
}

@description('Maintenance window for the maintenance configuration.')
type maintenanceWindowType = {
  @description('Required. Length of maintenance window range from 4 to 24 hours.')
  @minValue(4)
  @maxValue(24)
  durationHours: int

  @description('''Optional. Date ranges on which upgrade is not allowed. 'utcOffset' applies to this field.
  For example, with 'utcOffset: +02:00' and 'dateSpan' being '2022-12-23' to '2023-01-03',
  maintenance will be blocked from '2022-12-22 22:00' to '2023-01-03 22:00' in UTC time.''')
  notAllowedDates: [
    {
      @description('The start date of the date span.')
      start: string
      @description('The end date of the date span.')
      end: string
    }
  ]?

  @description('Required. Recurrence schedule for the maintenance window.')
  schedule: {
    @description('''Optional. For schedules like: 'recur every month on the 15th' or 'recur every 3 months on the 20th'.''')
    absoluteMonthly: {
      @description('Required. The date of the month.')
      @minValue(1)
      @maxValue(31)
      dayOfMonth: int
      @description('Required. Specifies the number of months between each set of occurrences.')
      @minValue(1)
      @maxValue(6)
      intervalMonths: int
    }?

    @description('''Optional. For schedules like: 'recur every day' or 'recur every 3 days'.''')
    daily: {
      @description('Required. Specifies the number of days between each set of occurrences.')
      @minValue(1)
      @maxValue(7)
      intervalDays: int
    }?

    @description('''Optional. For schedules like: 'recur every month on the first Monday' or 'recur every 3 months on last Friday'.''')
    relativeMonthly: {
      @description('Required. Specifies on which day of the week the maintenance occurs.')
      dayOfWeek: 'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday' |  'Saturday' | 'Sunday'
      @description('Required. Specifies the number of months between each set of occurrences.')
      @minValue(1)
      @maxValue(6)
      intervalMonths: int
      @description('Required. Specifies on which instance of the allowed days specified in daysOfWeek the maintenance occurs.')
      weekIndex: 'First' | 'Second' | 'Third' | 'Fourth' | 'Last'
    }?

    @description('''Optional. For schedules like: 'recur every Monday' or 'recur every 3 weeks on Wednesday'.''')
    weekly: {
      @description('Required. Specifies on which day of the week the maintenance occurs.')
      dayOfWeek: 'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday' |  'Saturday' | 'Sunday'
      @description('Required. Specifies the number of weeks between each set of occurrences.')
      @minValue(1)
      @maxValue(4)
      intervalWeeks: int
    }?
  }

  @description('''Optional. The date the maintenance window activates.
  If the current date is before this date, the maintenance window is inactive and will not be used for upgrades.
  If not specified, the maintenance window will be active right away.''')
  startDate: string?

  @description('''Required. The start time of the maintenance window. Accepted values are from '00:00' to '23:59'.
  'utcOffset' applies to this field. For example: '02:00' with 'utcOffset: +02:00' means UTC time '00:00'.''')
  startTime: string

  @description('''Optional. The UTC offset in format +/-HH:mm. For example, '+05:30' for IST and '-07:00' for PST.
  If not specified, the default is '+00:00'.''')
  utcOffset: string?
}

@description('Time slots on which upgrade is not allowed.')
type notAllowedTimeType = {
  @description('Required. The end of a time span')
  end: 'string'
  @description('Required. The start of a time span')
  start: 'string'
}[]

@description('If two array entries specify the same day of the week, the applied configuration is the union of times in both entries.')
type timeInWeekType = {
  @description('Required. The day of the week.')
  day: 'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday' |  'Saturday' | 'Sunday'

  @description('''Required. Each integer hour represents a time range beginning at 0m after the hour ending at the next hour (non-inclusive).
  0 corresponds to 00:00 UTC, 23 corresponds to 23:00 UTC. Specifying [0, 1] means the 00:00 - 02:00 UTC time range.''')
  hourSlots: [
    @minValue(1)
    @maxValue(23)
    int
  ]
}[]

output evidenceOfNonCompliance bool = false
