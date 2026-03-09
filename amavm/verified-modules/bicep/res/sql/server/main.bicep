metadata name = 'Azure SQL Server'
metadata description = 'This module deploys an Azure SQL Server.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of Azure SQL Server requires:
- publicNetworkAccess: 'Disabled'
- restrictOutboundNetworkAccess: 'Enabled'
- minimalTlsVersion: 1.2 and higher
- administrators.azureADOnlyAuthentication: not false
- securityAlertPolicies.state: 'Enabled'
- vulnerabilityAssessmentsClassic or vulnerabilityAssessmentsExpress are configured
'''
metadata complianceVersion = '20260309'

@description('''Conditional. The administrator username for the server. Required if no `administrators` object for AAD authentication is provided.
Once created it cannot be changed. Default: empty''')
param administratorLogin string = ''

@description('Conditional. The administrator login password. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param administratorLoginPassword string = ''

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. The name of the server.')
param name string

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}

@description('''Conditional. The resource ID of a user assigned identity to be used by default. Default: first item in managedIdentities.userAssignedIdentities.
Required if " managedIdentities.userAssignedIdentities" is not empty.''')
param primaryUserAssignedIdentityId string = managedIdentities.?userAssignedResourceIds[0] ?? ''

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('''Conditional. The Entra ID administrator of the server. Required if no `administratorLogin` & `administratorLoginPassword` is provided.
This can only be used at server create time. If used for server update, it will be ignored or it will result in an error.
For updates individual APIs will need to be used.

Setting administrators.azureADOnlyAuthentication to false will make the resource non-compliant.
''')
param administrators administratorsType?

@allowed([
  '1.2'
  '1.3'
])
@description('''Optional. Minimal TLS version allowed. Default: 1.2

Setting this parameter to values lower than '1.2' or 'None' will make the resource non-compliant.
''')
param minimalTlsVersion string = '1.2'

@description('Optional. The databases to create in the server.')
param databases databaseType[]?

@description('Optional. The Elastic Pools to create in the server.')
param elasticPools elasticPoolType[]?

@description('Optional. The firewall rules to create in the server.')
param firewallRules firewallRuleType[]?

@description('Optional. The virtual network rules to create in the server.')
param virtualNetworkRules virtualNetworkRuleType[]?

@description('Optional. The keys to configure.')
param keys keyType[]?

@description('''Optional. Whether or not public network access is allowed for this resource.
For security reasons it should be disabled. If not specified, it will be disabled by default.

Setting this parameter to 'Enabled' will make the resource non-compliant.
''')
@allowed([
  'Enabled'
  'Disabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string = 'Disabled'

@description('''Optional. Whether or not to restrict outbound network access for this server. Default is 'Enabled'.

Setting this parameter to 'Disabled' will make the resource non-compliant.
''')
@allowed([
  'Enabled'
  'Disabled'
])
param restrictOutboundNetworkAccess string = 'Enabled'

@description('Optional. Whether or not IPv6 is enabled on the server. Default: Disabled.')
@allowed([
  'Disabled'
  'Enabled'
])
param isIPv6Enabled string = 'Disabled'

@description('Optional. The connection policy for the server. Default: Default.')
@allowed([
  'Default'
  'Redirect'
  'Proxy'
])
param connectionPolicy string = 'Default'

@description('''Optional. Whether or not to enable advanced threat protection for this server. Default is 'Enabled'.''')
@allowed([
  'Enabled'
  'Disabled'
])
param advancedthreatProtection string = 'Enabled'

@description('Optional. A list of fully-qualified domain named that the SQL Server will be allowed to access when restrictOutboundNetworkAccess is Enabled.')
param outboundFirewallRules outboundFirewallRuleType[]?

@description('Optional. The encryption protection configuration.')
param encryptionProtector encryptionProtectorType?

@description('Optional. The security alert policies to create in the server. Default: state is Enabled.')
param securityAlertPolicy securityPolicyAlertType = {
  state: 'Enabled'
}

@description('Optional. The vulnerability assessment (Classic) configuration.')
param vulnerabilityAssessmentsClassic vulnerabilityAssessmentType?

@description('Optional. The vulnerability assessment (Express) configuration. Default: \'Enabled\'')
param vulnerabilityAssessmentsExpress sqlVulnerabilityAssessmentType = {
  state: 'Enabled'
}

@description('Optional. The audit settings configuration.')
param auditSettings auditSettingsType?

@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.')
param privateEndpoints privateEndpointType


// Variables
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {
  'Reservation Purchaser': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','f7b75c60-3036-4b75-91c3-6b41c27c1689')
  'SQL DB Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','9b7fa17d-e63e-47b0-bb0a-15c516ac86ec')
  'SQL Managed Instance Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','4939a1f6-9ae0-4e48-a1e0-f2cbe897382d')
  'SQL Security Manager': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','056cd41c-7e88-42e1-933e-88ba6a50c9c3')
  'SQL Server Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','6d8ee4ec-f05a-4a1d-8b00-a9b17e38b437')
  'SqlDb Migration Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','189207d4-bb67-4208-a635-b06afe8b2c57')
  'SqlMI Migration Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','1d335eef-eee1-47fe-a9e0-53214eba8872')
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union(tags ?? {}, {telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion})

// When a private endpoint configuration is provided without the service name, this array will be used to lookup default services for each privateEndpoint in the parameters
var privateEndpointDefaultServices = [
  'sqlServer'
]

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
    ? {
        type: (managedIdentities.?systemAssigned ?? true)
          ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
          : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
        userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
      }
    : {
        type: 'None'
      }

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.sql-server.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
    64
  )
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

resource server 'Microsoft.Sql/servers@2023-08-01' = {
  location: location
  name: name
  tags: finalTags
  identity: identity
  properties: {
    administratorLogin: !empty(administratorLogin) ? administratorLogin : null
    administratorLoginPassword: !empty(administratorLoginPassword) ? administratorLoginPassword : null
    administrators: !empty(administrators)
      ? {
          administratorType: administrators.?administratorType ?? 'ActiveDirectory'
          azureADOnlyAuthentication: administrators.?azureADOnlyAuthentication ?? true
          login: administrators.?login ?? administrators!.sid
          principalType: administrators!.principalType
          sid: administrators!.sid
          tenantId: administrators.?tenantId ?? tenant().tenantId
        }
      : null
    version: '12.0'
    minimalTlsVersion: minimalTlsVersion
    primaryUserAssignedIdentityId: !empty(primaryUserAssignedIdentityId) ? primaryUserAssignedIdentityId : null
    publicNetworkAccess: !empty(publicNetworkAccess)
      ? any(publicNetworkAccess)
      : (!empty(privateEndpoints) && empty(firewallRules??[]) && empty(virtualNetworkRules??[]) ? 'Disabled' : null)
    isIPv6Enabled: isIPv6Enabled
    restrictOutboundNetworkAccess: !empty(restrictOutboundNetworkAccess) ? restrictOutboundNetworkAccess : null
  }
}

resource server_connection_policy 'Microsoft.Sql/servers/connectionPolicies@2023-08-01' = {
  name: 'default'
  parent: server
  properties: {
    connectionType: connectionPolicy
  }
}

resource advancedthreatProtectionResource 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2023-08-01' = {
  name: take('${uniqueString(deployment().name, name, location)}-sqlserver-advanced-threat-protection',64)
  parent: server
  properties: {
    state: advancedthreatProtection
  }
}

// The explicit creation of the master is needed for successfull applying of audit settings on the server
resource server_masterDb 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: server
  location: location
  name: 'master'
  properties: {}
}

resource server_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: server
}

resource server_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(server.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
    properties: {
      #disable-next-line use-safe-access
      roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName)
        ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
        : contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
            ? roleAssignment.roleDefinitionIdOrName
            : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName)
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: server
  }
]

var defaultPrivateEndpoints = [for service in privateEndpointDefaultServices ?? []: {
  service: service
  subnetResourceId: !empty(privateEndpoints) ? privateEndpoints[0].subnetResourceId : null
}]
var applyingPrivateEndpoints =  ( empty(privateEndpoints) || (length(privateEndpoints)==1 && privateEndpoints[0].?service != null) ) ? privateEndpoints : defaultPrivateEndpoints

@batchSize(1)
module server_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (applyingPrivateEndpoints ?? []): {
    name: take('${uniqueString(deployment().name, name, location)}-sqlserver-pep-${index}',64)
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? '${last(split(server.id, '/'))}-pep-${privateEndpoint.?service ?? 'sqlServer'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(server.id, '/'))}-${privateEndpoint.?service ?? 'sqlServer'}-${index}'
              properties: {
                privateLinkServiceId: server.id
                groupIds: [
                  privateEndpoint.?service ?? 'sqlServer'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(server.id, '/'))}-${privateEndpoint.?service ?? 'sqlServer'}-${index}'
              properties: {
                privateLinkServiceId: server.id
                groupIds: [
                  privateEndpoint.?service ?? 'sqlServer'
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      enableTelemetry: privateEndpoint.?enableTelemetry ?? enableTelemetry
      location: privateEndpoint.?location ?? reference(
        split(privateEndpoint.subnetResourceId, '/subnets/')[0],
        '2024-05-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock ?? lock
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? finalTags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
  }
]

module server_firewallRules 'firewall-rule/main.bicep' = [
  for (firewallRule, index) in (firewallRules ?? []): {
    name: take('${uniqueString(deployment().name, name, location)}-sqlserver-fwrules-${index}-${firewallRule.name}',64)
    params: {
      name: firewallRule.name
      serverName: server.name
      endIpAddress: firewallRule.?endIpAddress
      startIpAddress: firewallRule.?startIpAddress
    }
  }
]

module server_virtualNetworkRules 'virtual-network-rule/main.bicep' = [
  for (virtualNetworkRule, index) in (virtualNetworkRules ?? []): {
    name: take('${uniqueString(deployment().name, name, location)}-sqlserver-vnetrules-${index}-${virtualNetworkRule.name}',64)
    params: {
      name: virtualNetworkRule.name
      serverName: server.name
      ignoreMissingVnetServiceEndpoint: virtualNetworkRule.?ignoreMissingVnetServiceEndpoint
      virtualNetworkSubnetId: virtualNetworkRule.virtualNetworkSubnetId
    }
  }
]

module server_outboundFirewallRules 'outbound-firewall-rule/main.bicep' = [
  for (firewallRule, index) in (outboundFirewallRules ?? []): {
    name: take('${uniqueString(deployment().name, name, location)}-sqlserver-outfwrules-${index}-${firewallRule.name}',64)
    params: {
      name: firewallRule.name
      serverName: server.name
    }
  }
]

module server_audit_settings 'audit-settings/main.bicep' = if (!empty(auditSettings)) {
  name: take('${uniqueString(deployment().name, name, location)}-sqlserver-auditsettings',64)
  params: {
    serverName: server.name
    name: auditSettings.?name
    #disable-next-line BCP318
    state: auditSettings.state
    auditActionsAndGroups: auditSettings.?auditActionsAndGroups
    isAzureMonitorTargetEnabled: auditSettings.?isAzureMonitorTargetEnabled
    isDevopsAuditEnabled: auditSettings.?isDevopsAuditEnabled
    isManagedIdentityInUse: auditSettings.?isManagedIdentityInUse
    isStorageSecondaryKeyInUse: auditSettings.?isStorageSecondaryKeyInUse
    queueDelayMs: auditSettings.?queueDelayMs
    retentionDays: auditSettings.?retentionDays
    storageAccountResourceId: auditSettings.?storageAccountResourceId
    workspaceResourceId: auditSettings.?workspaceResourceId
  }
  dependsOn:[
    server_outboundFirewallRules // access to storage needs the firewall
    server_masterDb
  ]
}

module server_securityAlertPolicies 'security-alert-policy/main.bicep' = if (!empty(securityAlertPolicy)) {
  name: take('${uniqueString(deployment().name, name, location)}-sqlserver-secalertpolicy',64)
  params: {
    serverName: server.name
    disabledAlerts: securityAlertPolicy.?disabledAlerts
    emailAccountAdmins: securityAlertPolicy.?emailAccountAdmins
    emailAddresses: securityAlertPolicy.?emailAddresses
    retentionDays: securityAlertPolicy.?retentionDays
    state: securityAlertPolicy.?state
    // storageAccountAccessKey: securityAlertPolicy.?storageAccountAccessKey
    // storageAccountResourceId: securityAlertPolicy.?storageAccountResourceId
    // storageEndpoint: securityAlertPolicy.?storageEndpoint
    // createStorageRoleAssignment: securityAlertPolicy.?createStorageRoleAssignment
    // useStorageAccountAccessKey: securityAlertPolicy.?useStorageAccountAccessKey
  }
}

module server_vulnerabilityAssessment 'vulnerability-assessment/main.bicep' = if(!empty(vulnerabilityAssessmentsClassic.?storageAccountResourceId)) {
  name: take('${uniqueString(deployment().name, name, location)}-sqlserver-vulnassessment',64)
  params: {
    serverName: server.name
    recurringScansEmails: vulnerabilityAssessmentsClassic.?recurringScansEmails
    recurringScansEmailSubscriptionAdmins: vulnerabilityAssessmentsClassic.?recurringScansEmailSubscriptionAdmins
    recurringScansIsEnabled: vulnerabilityAssessmentsClassic.?recurringScansIsEnabled
    #disable-next-line BCP318
    storageAccountResourceId: vulnerabilityAssessmentsClassic.storageAccountResourceId
    storageContainerName: vulnerabilityAssessmentsClassic.?storageContainerName
    useStorageAccountAccessKey: vulnerabilityAssessmentsClassic.?useStorageAccountAccessKey
    createStorageRoleAssignment: vulnerabilityAssessmentsClassic.?createStorageRoleAssignment
  }
  dependsOn: [
    server_securityAlertPolicies // TODO: check why this dependency in the upstream code ?
    server_outboundFirewallRules // access to storage needs the firewall
  ]
}

module server_sqlVulnerabilityAssessment 'sql-vulnerability-assessment/main.bicep' = if(!empty(vulnerabilityAssessmentsExpress)) {
  name: take('${uniqueString(deployment().name, name, location)}-sqlserver-vulnassessment',64)
  params: {
    serverName: server.name
    #disable-next-line BCP318
    state: vulnerabilityAssessmentsExpress.state
  }
}
module server_keys 'key/main.bicep' = [
  for (key, index) in (keys ?? []): {
    name: '${uniqueString(deployment().name, name, location)}-sqlserver-key-${index}'
    params: {
      name: key.?name
      serverName: server.name
      serverKeyType: key.?serverKeyType
      uri: key.?uri
    }
  }
]

module server_encryptionProtector 'encryption-protector/main.bicep' = if (!empty(encryptionProtector)) {
  name: take('${uniqueString(deployment().name, name, location)}-sqlserver-encryprotector',64)
  params: {
    sqlServerName: server.name
    #disable-next-line BCP318
    serverKeyName: encryptionProtector.serverKeyName
    serverKeyType: encryptionProtector.?serverKeyType
    autoRotationEnabled: encryptionProtector.?autoRotationEnabled
  }
  dependsOn: [
    server_keys
  ]
}

module server_elasticPools 'elastic-pool/main.bicep' = [
  for (elasticPool, index) in (elasticPools ?? []): {
    name: take('${uniqueString(deployment().name, name, location)}-sql-pool-${index}',64)
    params: {
      name: elasticPool.name
      serverName: server.name
      databaseMaxCapacity: elasticPool.?databaseMaxCapacity
      databaseMinCapacity: elasticPool.?databaseMinCapacity
      highAvailabilityReplicaCount: elasticPool.?highAvailabilityReplicaCount
      licenseType: elasticPool.?licenseType
      maintenanceConfigurationId: elasticPool.?maintenanceConfigurationId
      maxSizeBytes: elasticPool.?maxSizeBytes
      minCapacity: elasticPool.?minCapacity
      skuCapacity: elasticPool.?skuCapacity
      skuName: elasticPool.?skuName
      skuTier: elasticPool.?skuTier
      zoneRedundant: elasticPool.?zoneRedundant
      location: location
      tags: elasticPool.?tags ?? finalTags
    }
  }
]
module server_databases 'database/main.bicep' = [
  for (database, index) in (databases ?? []): {
    name: take('${uniqueString(deployment().name, name, location)}-sql-db-${index}-${database.name}',64)
    params: {
      serverName: server.name
      name: database.name
      skuCapacity: database.?skuCapacity
      skuFamily: database.?skuFamily
      skuName: database.?skuName
      skuSize: database.?skuSize
      skuTier: database.?skuTier
      autoPauseDelay: database.?autoPauseDelay
      availabilityZone: database.?availabilityZone
      backupLongTermRetentionPolicy: database.?backupLongTermRetentionPolicy
      backupShortTermRetentionPolicy: database.?backupShortTermRetentionPolicy
      catalogCollation: database.?catalogCollation
      collation: database.?collation
      createMode: database.?createMode
      diagnosticSettings: database.?diagnosticSettings
      elasticPoolId: database.?elasticPoolId
      freeLimitExhaustionBehavior: database.?freeLimitExhaustionBehavior
      highAvailabilityReplicaCount: database.?highAvailabilityReplicaCount
      isLedgerOn: database.?isLedgerOn
      licenseType: database.?licenseType
      location: location
      maintenanceConfigurationId: database.?maintenanceConfigurationId
      manualCutover: database.?manualCutover
      maxSizeBytes: database.?maxSizeBytes
      minCapacity: database.?minCapacity
      performCutover: database.?performCutover
      preferredEnclaveType: database.?preferredEnclaveType
      readScale: database.?readScale
      recoveryServicesRecoveryPointResourceId: database.?recoveryServicesRecoveryPointResourceId
      requestedBackupStorageRedundancy: database.?requestedBackupStorageRedundancy
      restorePointInTime: database.?restorePointInTime
      sampleName: database.?sampleName
      secondaryType: database.?secondaryType
      sourceDatabaseDeletionDate: database.?sourceDatabaseDeletionDate
      sourceDatabaseResourceId: database.?sourceDatabaseResourceId
      sourceResourceId: database.?sourceResourceId
      tags: database.?tags ?? finalTags
      useFreeLimit: database.?useFreeLimit
      zoneRedundant: database.?zoneRedundant
      enableTelemetry: false
    }
    dependsOn: [
      server_elasticPools // Enables us to add databases to existing elastic pools
    ]
  }
]


@description('The name of the deployed SQL server.')
output name string = server.name

@description('The resource ID of the deployed SQL server.')
output resourceId string = server.id

@description('The resource group of the deployed SQL server.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = server.?identity.?principalId ?? ''

@description('The location the resource was deployed into.')
output location string = server.location

@description('The FQDN of the deployed SQL server.')
output fullyQualifiedDomainName string = server.properties.fullyQualifiedDomainName

@description('The names of the deployed subnets.')
output databases array = [for (database, index) in (databases ?? []): {
  name: server_databases[index].outputs.name
  resourceId: server_databases[index].outputs.resourceId
}]

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = publicNetworkAccess != 'Disabled' || restrictOutboundNetworkAccess != 'Enabled' || ! (administrators.?azureADOnlyAuthentication ?? true) || securityAlertPolicy.?state != 'Enabled' || ( empty(vulnerabilityAssessmentsClassic) && empty(vulnerabilityAssessmentsExpress))

// =============== //
//   Definitions   //
// =============== //

import {
  lockType
  managedIdentitiesType
  privateEndpointType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'

import { auditSettingsType } from 'audit-settings/main.bicep'
import { databaseType } from 'database/main.bicep'
import { firewallRuleType } from 'firewall-rule/main.bicep'
import { outboundFirewallRuleType } from 'outbound-firewall-rule/main.bicep'
import { virtualNetworkRuleType } from 'virtual-network-rule/main.bicep'
import { securityPolicyAlertType } from 'security-alert-policy/main.bicep'
import { vulnerabilityAssessmentType } from 'vulnerability-assessment/main.bicep'
import { sqlVulnerabilityAssessmentType } from 'sql-vulnerability-assessment/main.bicep'
import { keyType } from 'key/main.bicep'
import { encryptionProtectorType } from 'encryption-protector/main.bicep'
import { elasticPoolType } from 'elastic-pool/main.bicep'

type administratorsType = {
  @description('Optional. Type of the sever administrator.')
  administratorType: 'ActiveDirectory'?

  @description('Optional. Azure Active Directory only Authentication enabled.')
  azureADOnlyAuthentication: bool?

  @description('Optional. Login name of the server administrator.')
  login: string?

  @description('Required. Principal Type of the sever administrator.')
  principalType: 'Application' | 'Group' | 'User'

  @description('Required. SID (object ID) of the server administrator. Pattern = ^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')
  @minLength(36)
  @maxLength(36)
  sid: string

  @description('Optional. Tenant ID of the administrator. Pattern = ^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$.')
  @minLength(36)
  @maxLength(36)
  tenantId: string?
}
