metadata name = 'Static Web Apps (early preview)'
metadata description = 'This module deploys a Static Web App.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of Static Web App requires:

- publicNetworkAccess: 'Disabled'
'''
metadata complianceVersion = '20260309'

@description('Required. The name of the static site.')
@minLength(1)
@maxLength(40)
param name string

@allowed([
  'Free'
  'Standard'
  //'Dedicated' // preview
])
@description('''Optional. The service tier and name of the resource SKU.

Setting any other value than Standard will make the resource noncompliant.
''')
param sku string = 'Standard'

@description('Optional. False if config file is locked for this static web app; otherwise, true.')
param allowConfigFileUpdates bool = true

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'Enabled'
  'Disabled'
])
@description('Optional. State indicating whether staging environments are allowed or not allowed for a static web app.')
param stagingEnvironmentPolicy string = 'Enabled'

@allowed([
  'Disabled'
  'Disabling'
  'Enabled'
  'Enabling'
])
@description('Optional. State indicating the status of the enterprise grade CDN serving traffic to the static web app.')
param enterpriseGradeCdnStatus string = 'Disabled'

@description('Optional. Build properties for the static site.')
param buildProperties staticSiteBuildPropertiesType

@description('Optional. Template Options for the static site.')
param templateProperties staticSiteTemplatePropertiesType?

@description('Optional. The provider that submitted the last deployment to the primary environment of the static site.')
param provider string = 'None'

@secure()
@description('Optional. The Personal Access Token for accessing the GitHub repository.')
param repositoryToken string?

@description('Optional. The name of the GitHub repository.')
param repositoryUrl string?

@description('Optional. The branch name of the GitHub repository.')
param branch string?

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}

@description('''Optional. Property to enable or disable public traffic for the Static Web App.

Setting this parameter to 'Enabled' will make the resource non-compliant.
''')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Optional. The lock settings of the service.')
param lock lockType

@description('''Required. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.
Note, requires the 'sku' to be 'Standard'.

Available values for 'service' are:
- staticSites

Default: staticSites is used if at least one subnetResourceId is provided but 'service' is not specified.
''')
param privateEndpoints privateEndpointType

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Object with "resourceId" and "location" of the a user defined function app.')
param linkedBackend linkedBackendType?

@description('Optional. Static site app settings.')
param appSettings object = {} // TODO: make a type

@description('Optional. Function app settings.')
param functionAppSettings object = {} // TODO: make a type

@description('Optional. The custom domains associated with this static site. The deployment will fail as long as the validation records are not present.')
param customDomains array = []

@description('Optional. Custom domain validation method. If not specified, automatically determined based on domain structure.')
@allowed([
  'dns-txt-token'
  'cname-delegation'
])
param validationMethod string?


var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : null)
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'
var specificBuiltInRoleNames = {
  'Web Plan Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','2cc479cb-7b4d-49a8-b449-8c00fd0f0a4b')
  'Website Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','de139f84-1756-47ae-9be6-808fbbe84772')
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

// When a private endpoint configuration is provided without the service name, this array will be used to lookup default services for each privateEndpoint in the parameters
var privateEndpointDefaultServices = [
  'staticSites'
]
var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union(tags ?? {}, {telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion})

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.web-staticsite.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource staticSite 'Microsoft.Web/staticSites@2024-04-01' = {
  name: name
  location: location
  tags: finalTags
  #disable-next-line BCP036
  identity: identity
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    allowConfigFileUpdates: allowConfigFileUpdates
    stagingEnvironmentPolicy: stagingEnvironmentPolicy
    enterpriseGradeCdnStatus: enterpriseGradeCdnStatus
    provider: !empty(provider) ? provider : 'None'
    branch: branch
    buildProperties: buildProperties
    repositoryToken: repositoryToken
    repositoryUrl: repositoryUrl
    templateProperties: templateProperties
    publicNetworkAccess: publicNetworkAccess
  }
}

module staticSite_linkedBackend 'linked-backend/main.bicep' = if (!empty(linkedBackend)) {
  name: take('${uniqueString(deployment().name, location)}-staticsite-userdefinedfunction',64)
  params: {
    staticSiteName: staticSite.name
    backendResourceId: linkedBackend.?backendResourceId ?? ''
    region: linkedBackend.?location ?? location }
}

module staticSite_appSettings 'config/main.bicep' = if (!empty(appSettings)) {
  name: '${uniqueString(deployment().name, location)}-staticsite-appsettings'
  params: {
    kind: 'appsettings'
    staticSiteName: staticSite.name
    properties: appSettings
  }
}

module staticSite_functionAppSettings 'config/main.bicep' = if (!empty(functionAppSettings)) {
  name: '${uniqueString(deployment().name, location)}-StaticSite-functionAppSettings'
  params: {
    kind: 'functionappsettings'
    staticSiteName: staticSite.name
    properties: functionAppSettings
  }
}

module staticSite_customDomains 'custom-domain/main.bicep' = [
  for (customDomain, index) in customDomains: {
    name: take('${uniqueString(deployment().name, location)}-${index}-staticsite-customdomains',64)
    params: {
      name: customDomain
      staticSiteName: staticSite.name
      validationMethod: validationMethod ?? (indexOf(customDomain, '.') == lastIndexOf(customDomain, '.')
        ? 'dns-txt-token'
        : 'cname-delegation')
    }
  }
]

resource staticSite_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.')
  }
  scope: staticSite
}

resource staticSite_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(staticSite.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: staticSite
  }
]


var defaultPrivateEndpoints = [
  for service in privateEndpointDefaultServices ?? []: {
    service: service
    subnetResourceId: !empty(privateEndpoints) ? privateEndpoints[0].subnetResourceId : null
  }
]
var applyingPrivateEndpoints = (empty(privateEndpoints) || (length(privateEndpoints) == 1 && privateEndpoints[0].?service != null))
  ? privateEndpoints
  : defaultPrivateEndpoints

module staticSite_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (applyingPrivateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-staticsite-pep-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? 'pep-${last(split(staticSite.id, '/'))}-${privateEndpoint.?service ?? 'staticSites'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(staticSite.id, '/'))}-${privateEndpoint.?service ?? 'staticSites'}-${index}'
              properties: {
                privateLinkServiceId: staticSite.id
                groupIds: [
                  privateEndpoint.?service ?? 'staticSites'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(staticSite.id, '/'))}-${privateEndpoint.?service ?? 'staticSites'}-${index}'
              properties: {
                privateLinkServiceId: staticSite.id
                groupIds: [
                  privateEndpoint.?service ?? 'staticSites'
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
        '2020-06-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock ?? lock
      privateDnsZoneGroup: privateEndpoint.?privateDnsZoneGroup
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? finalTags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
  }
]

@description('The name of the static site.')
output name string = staticSite.name

@description('The resource ID of the static site.')
output resourceId string = staticSite.id

@description('The resource group the static site was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = staticSite.?identity.?principalId ?? ''

@description('The location the resource was deployed into.')
output location string = staticSite.location

@description('The default autogenerated hostname for the static site.')
output defaultHostname string = staticSite.properties.defaultHostname

@description('The private endpoints of the static site.')
output privateEndpoints array = [
  for (pe, i) in (!empty(privateEndpoints) ? array(privateEndpoints) : []): {
    name: staticSite_privateEndpoints[i].outputs.name
    resourceId: staticSite_privateEndpoints[i].outputs.resourceId
    groupId: staticSite_privateEndpoints[i].outputs.groupId
    customDnsConfigs: staticSite_privateEndpoints[i].outputs.customDnsConfigs
    networkInterfaceResourceIds: staticSite_privateEndpoints[i].outputs.networkInterfaceResourceIds
  }
]

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = (publicNetworkAccess == 'Disabled')

// =============== //
//   Definitions   //
// =============== //

import {
  diagnosticSettingType
  lockType
  managedIdentitiesType
  privateEndpointType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'

import { customDomainType } from 'custom-domain/main.bicep'
import { linkedBackendType } from 'linked-backend/main.bicep'

@description('Build properties to configure on the repository.')
type staticSiteBuildPropertiesType = {
  @description('Optional. Command preset for API build action.')
  apiBuildCommand: string?
  @description('''Optional. Location of your application code. For example, '/' represents the root of your app, while '/app' represents a directory called 'app'.''')
  apiLocation: string?
  @description('Optional. Command preset for APP build action.')
  appBuildCommand: string?
  @description('''Required. Location of your application code. For example, '/' represents the root of your app, while '/app' represents a directory called 'app'.''')
  appLocation: string
  @description('''Optional. Github Action secret name override.''')
  githubActionSecretNameOverride: string?
  @description('''Optional. The path of your build output relative to your apps location.
  For example, setting a value of 'build' when your app location is set to '/app' will cause the content at '/app/build' to be served.
  ''')
  outputLocation: string?
  @description('''Optional. Whether to skip Github Action Workflow generation.''')
  skipGithubActionWorkflowGeneration: true?
}

@description('Template options for generating a new repository.')
type staticSiteTemplatePropertiesType = {
  @description('''Optional. Description of the newly generated repository.''')
  description: string?
  @description('''Optional. Whether or not the newly generated repository is a private repository. Defaults to false (i.e. public).''')
  isPrivate: bool?
  @description('''Optional. Owner of the newly generated repository.''')
  owner: string?
  @description('''Optional. Name of the newly generated repository.''')
  repositoryName: string?
  @description('''Optional. URL of the template repository. The newly generated repository will be based on this one.''')
  templateRepositoryUrl: string?
}
