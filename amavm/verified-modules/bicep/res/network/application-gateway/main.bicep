metadata name = 'Network Application Gateways'
metadata description = 'This module deploys a Network Application Gateway.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of this module requires the following parameter values:
- sku WAF_v2 or Standard_v2
- firewallPolicy configured
- sslPolicyType = 'Predefined'
- sslPolicyName = AppGwSslPolicy20220101 || AppGwSslPolicy20170401S || AppGwSslPolicy20220101S'
- sslPolicyMinProtocolVersion at least TLS_v1_2
- no Public IP attached in httpListener
- httpListener protocol = 'https'
- backendPool protocol = 'https'
- requestRoutingRules not empty
'''
metadata complianceVersion = '20260309'

@description('Required. Name of the Application Gateway.')
@maxLength(80)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}
@description('Optional. Authentication certificates of the application gateway resource.')
param authenticationCertificates array = []

@description('Optional. Upper bound on number of Application Gateway capacity.')
@maxValue(125)
@minValue(2)
param autoscaleMaxCapacity int = 2

@description('Optional. Lower bound on number of Application Gateway capacity.')
@minValue(1)
param autoscaleMinCapacity int = 1

@description('''Optional. Backend address pool of the application gateway resource. Compliant usage requires 'https' protocol''')
param backendAddressPools backendAddressPoolType

@description('''Optional. Backend http settings of the application gateway resource. Compliant usage requires 'https' protocol''')
param backendHttpSettingsCollection backendHttpSettingsCollectionType

@description('Optional. Backend settings of the application gateway resource. For default limits, see [Application Gateway limits](https://learn.microsoft.com/en-us/azure/azure-subscription-service-limits#application-gateway-limits).')
param backendSettingsCollection array = []

@description('Optional. Custom error configurations of the application gateway resource.')
param customErrorConfigurations customErrorConfigurationType

@description('Optional. Whether FIPS is enabled on the application gateway resource. Default is false')
param enableFips bool = false

@description('Optional. Whether HTTP2 is enabled on the application gateway resource. Default is true')
param enableHttp2 bool = true

@description('Optional. The resource ID of an associated firewall policy. This will override the compliant by default WAF policy')
param firewallPolicyResourceId string = ''

@description('Optional. Frontend IP addresses of the application gateway resource.')
param frontendIPConfigurations frontendIPConfigurationType

@description('Optional. Frontend ports of the application gateway resource.')
param frontendPorts frontendPortType

@description('Optional. Subnets of the application gateway resource.')
param gatewayIPConfigurations gatewayIPConfigurationType

@description('Optional. Enable request buffering.')
param enableRequestBuffering bool = false

@description('Optional. Enable response buffering.')
param enableResponseBuffering bool = false

@description('Optional. Entra JWT validation configurations.')
param entraJWTValidationConfigs array = []

@description('Optional. Http listeners of the application gateway resource. Compliant usage requires HTTPS protocol, additionally Public IP address in frontend IP configuration results in non-compliance.')
param httpListeners httpListenerType

@description('Optional. Load distribution policies of the application gateway resource.')
param loadDistributionPolicies array = []

@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.')
param privateEndpoints privateEndpointType = []

@description('Optional. PrivateLink configurations on application gateway.')
param privateLinkConfigurations array = []

@description('Optional. Probes of the application gateway resource.')
param probes probeType

@description('Optional. Redirect configurations of the application gateway resource.')
param redirectConfigurations redirectConfigurationsType

@description('Optional. Request routing rules of the application gateway resource. Compliant usage requires at least one request routing rule configured.')
param requestRoutingRules requestRoutingRuleType

@description('Optional. Rewrite rules for the application gateway resource.')
param rewriteRuleSets rewriteRuleSetType

@description('Optional. The name of the SKU for the Application Gateway. Defaults to WAF_v2. Compliant usage requires Standard_v2 or WAF_v2')
@allowed([
  'Basic'
  'Standard_v2'
  'WAF_v2'
])
param sku string = 'WAF_v2'

@description('Optional. The number of Application instances to be configured.')
@minValue(0)
@maxValue(10)
param capacity int = 2

@description('Optional. SSL certificates of the application gateway resource.')
param sslCertificates sslCertificatesType

@description('Optional. Ssl cipher suites to be enabled in the specified order to application gateway.')
@allowed([
  'TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA'
  'TLS_DHE_DSS_WITH_AES_128_CBC_SHA'
  'TLS_DHE_DSS_WITH_AES_128_CBC_SHA256'
  'TLS_DHE_DSS_WITH_AES_256_CBC_SHA'
  'TLS_DHE_DSS_WITH_AES_256_CBC_SHA256'
  'TLS_DHE_RSA_WITH_AES_128_CBC_SHA'
  'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
  'TLS_DHE_RSA_WITH_AES_256_CBC_SHA'
  'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
  'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA'
  'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256'
  'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
  'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA'
  'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384'
  'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
  'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA'
  'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256'
  'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
  'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA'
  'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384'
  'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
  'TLS_RSA_WITH_3DES_EDE_CBC_SHA'
  'TLS_RSA_WITH_AES_128_CBC_SHA'
  'TLS_RSA_WITH_AES_128_CBC_SHA256'
  'TLS_RSA_WITH_AES_128_GCM_SHA256'
  'TLS_RSA_WITH_AES_256_CBC_SHA'
  'TLS_RSA_WITH_AES_256_CBC_SHA256'
  'TLS_RSA_WITH_AES_256_GCM_SHA384'
])
param sslPolicyCipherSuites array = [
  'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
  'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
]

@description('Optional. Ssl protocol enums. Compliant usage requires at least TLSv1_2.')
@allowed([
  'TLSv1_0'
  'TLSv1_1'
  'TLSv1_2'
  'TLSv1_3'
])
param sslPolicyMinProtocolVersion string = 'TLSv1_2'

@description('Optional. Ssl predefined policy name enums. Compliant usage requires (default) AppGwSslPolicy20220101 or AppGwSslPolicy20170401S or AppGwSslPolicy20220101S')
@allowed([
  'AppGwSslPolicy20150501'
  'AppGwSslPolicy20170401'
  'AppGwSslPolicy20170401S'
  'AppGwSslPolicy20220101'
  'AppGwSslPolicy20220101S'
  ''
])
param sslPolicyName string = 'AppGwSslPolicy20220101'

@description('Optional. Type of Ssl Policy. Compliant usage requires (default) Predefined')
@allowed([
  'Custom'
  'CustomV2'
  'Predefined'
])
param sslPolicyType string = 'Predefined'

@description('Optional. SSL profiles of the application gateway resource.')
param sslProfiles array = []

@description('Optional. Trusted client certificates of the application gateway resource.')
param trustedClientCertificates array = []

@description('Optional. Trusted Root certificates of the application gateway resource.')
param trustedRootCertificates trustedRootCertificatesType

@description('Optional. URL path map of the application gateway resource.')
param urlPathMaps urlPathMapType

@description('Optional. Application gateway web application firewall configuration. This will override the compliant by default WAF policy.')
param webApplicationFirewallConfiguration wafConfigurationType?

@description('Optional. Zones for the resource. For example: [1, 2, 3]. Default: []')
param zones array = []

// Variables
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId} from '../../../../bicep-shared/environments.bicep'

var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version

var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})


var defaultLogCategoryNames = [
  'ApplicationGatewayAccessLog'
  'ApplicationGatewayPerformanceLog'
  'ApplicationGatewayFirewallLog'
]

var defaultLogCategories = [for category in defaultLogCategoryNames ?? []: {
  category: category
}]

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingType

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: !empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : null
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Resource tags.')
param tags object?

@description('Optional. Listeners of the application gateway resource. For default limits, see [Application Gateway limits](https://learn.microsoft.com/en-us/azure/azure-subscription-service-limits#application-gateway-limits).')
param listeners array = []

@description('Optional. Routing rules of the application gateway resource.')
param routingRules array = []

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

var enableReferencedModulesTelemetry = false

var specificBuiltInRoleNames = {
  'Network Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '4d97b98b-1d4f-4787-a291-c67834d212e7'
  )
}

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

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.network-appgw.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}',
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

module wafPolicy 'br/amavm:res/network/application-gateway-web-application-firewall-policy:0.1.0' = if (empty(firewallPolicyResourceId) && empty(webApplicationFirewallConfiguration)) {
  name: '${uniqueString(deployment().name)}-waf-policy'
  params: {
    name: '${name}-agfp'
    location: location
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2025-05-01' = {
  name: name
  location: location
  tags: finalTags
  identity: identity
  properties: union(
    {
      authenticationCertificates: authenticationCertificates
      autoscaleConfiguration: autoscaleMaxCapacity > 0 && autoscaleMinCapacity >= 0
        ? {
            maxCapacity: autoscaleMaxCapacity
            minCapacity: autoscaleMinCapacity
          }
        : null
      backendAddressPools: backendAddressPools
      backendHttpSettingsCollection: backendHttpSettingsCollection
      backendSettingsCollection: backendSettingsCollection
      customErrorConfigurations: customErrorConfigurations
      enableHttp2: enableHttp2
      entraJWTValidationConfigs: entraJWTValidationConfigs
      firewallPolicy: !empty(firewallPolicyResourceId)
        ? {
            id: firewallPolicyResourceId
          }
        : !empty(wafPolicy.outputs.resourceId)
          ? {
              id: wafPolicy.outputs.resourceId
            }
          : null
      forceFirewallPolicyAssociation: !empty(firewallPolicyResourceId)
      frontendIPConfigurations: frontendIPConfigurations
      frontendPorts: frontendPorts
      gatewayIPConfigurations: gatewayIPConfigurations
      globalConfiguration: endsWith(sku, 'v2')
        ? {
            enableRequestBuffering: enableRequestBuffering
            enableResponseBuffering: enableResponseBuffering
          }
        : null
      httpListeners: httpListeners
      loadDistributionPolicies: loadDistributionPolicies
      listeners: listeners
      privateLinkConfigurations: privateLinkConfigurations
      probes: probes
      redirectConfigurations: redirectConfigurations
      requestRoutingRules: requestRoutingRules
      routingRules: routingRules
      rewriteRuleSets: rewriteRuleSets
      sku: {
        name: sku
        tier: endsWith(sku, 'v2') ? sku : substring(sku, 0, indexOf(sku, '_'))
        capacity: autoscaleMaxCapacity > 0 && autoscaleMinCapacity >= 0 ? null : capacity
      }
      sslCertificates: sslCertificates
      sslPolicy: sslPolicyType != 'Predefined'
        ? {
            cipherSuites: sslPolicyCipherSuites
            minProtocolVersion: sslPolicyMinProtocolVersion
            policyName: empty(sslPolicyName) ? null : sslPolicyName
            policyType: sslPolicyType
          }
        : {
            policyName: empty(sslPolicyName) ? null : sslPolicyName
            policyType: sslPolicyType
          }
      sslProfiles: sslProfiles
      trustedClientCertificates: trustedClientCertificates
      trustedRootCertificates: trustedRootCertificates
      urlPathMaps: urlPathMaps
    },
    (enableFips
      ? {
          enableFips: enableFips
        }
      : {}),
    (!empty(webApplicationFirewallConfiguration)
      ? { webApplicationFirewallConfiguration: webApplicationFirewallConfiguration }
      : {})
  )
  zones: zones
}

resource applicationGateway_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.')
  }
  scope: applicationGateway
}

resource applicationGateway_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [{ category: 'AllMetrics' }]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: null
        }
      ]
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? defaultLogCategories): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: applicationGateway
  }
]

module applicationGateway_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-agw-pep-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? 'pep-${last(split(applicationGateway.id, '/'))}-${privateEndpoint.?service}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(applicationGateway.id, '/'))}-${privateEndpoint.?service}-${index}'
              properties: {
                privateLinkServiceId: applicationGateway.id
                groupIds: [
                  privateEndpoint.?service
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(applicationGateway.id, '/'))}-${privateEndpoint.?service}-${index}'
              properties: {
                privateLinkServiceId: applicationGateway.id
                groupIds: [
                  privateEndpoint.?service
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      enableTelemetry: enableReferencedModulesTelemetry
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

resource applicationGateway_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(
      applicationGateway.id,
      roleAssignment.principalId,
      roleAssignment.roleDefinitionId
    )
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: applicationGateway
  }
]

@description('The name of the application gateway.')
output name string = applicationGateway.name

@description('The resource ID of the application gateway.')
output resourceId string = applicationGateway.id

@description('The resource group the application gateway was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = applicationGateway.location

@description('The private endpoints of the application gateway.')
output privateEndpoints array = [
  for (pe, i) in (!empty(privateEndpoints) ? array(privateEndpoints) : []): {
    name: applicationGateway_privateEndpoints[i].outputs.name
    resourceId: applicationGateway_privateEndpoints[i].outputs.resourceId
    groupId: applicationGateway_privateEndpoints[i].outputs.groupId
    customDnsConfig: applicationGateway_privateEndpoints[i].outputs.customDnsConfig
    networkInterfaceIds: applicationGateway_privateEndpoints[i].outputs.networkInterfaceIds
  }
]

//check all arrays for compliancy
var backendProtocolsValidation = [for setting in (backendHttpSettingsCollection ?? []) : setting.?properties.protocol]
var httpListenersProtocolsValidation = [for setting in (httpListeners ?? []) : setting.?properties.protocol]
var requestRoutingRulesValidation =  [for setting in (requestRoutingRules ?? []) : setting.?properties.backendHttpSettings.id]
var httpListenerPublic = [for setting in (httpListeners ?? []) : setting.?properties.frontendIPConfiguration]

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = (sku == 'Basic') || empty(applicationGateway.properties.firewallPolicy.id) || (sslPolicyType != 'Predefined') || contains(['', 'AppGwSslPolicy20150501', 'AppGwSslPolicy20170401'],sslPolicyName) || contains(['TLSv1_0', 'TLSv1_1'], sslPolicyMinProtocolVersion) || contains(httpListenerPublic, 'Public') || empty(requestRoutingRulesValidation) || !contains(httpListenersProtocolsValidation, 'https') || !contains(backendProtocolsValidation, 'https')

// =============== //
//   Definitions   //
// =============== //
type customErrorConfigurationType = {
  @description('Required. Error page URL of the application gateway custom error.')
  customErrorPageUrl: string
  @description('Required. Status code of the application gateway custom error.')
  statusCode: 'HttpStatus400' | 'HttpStatus403' | 'HttpStatus404' | 'HttpStatus405' | 'HttpStatus408' | 'HttpStatus500' | 'HttpStatus502' | 'HttpStatus503' | 'HttpStatus504'
}[]?
type httpListenerType = {
  @description('Required. Name of the HTTP listener.')
  name: string
  @description('Optional. Resource ID of HTTP listener')
  id: string?
  @description('Required. Properties of HTTP listener.')
  properties: {
    @description('Required. Frontend IP configuration of the HTTP listener.')
    frontendIPConfiguration: {
      @description('Required. Resource ID of the HTTP listener')
      id: string
    }
    @description('Required. Frontend port of the HTTP listener.')
    frontendPort: {
      @description('Required. Resource ID of Front end port')
      id: string
    }
    @description('Required. Protocol of the HTTP listener.')
    protocol: 'http' | 'https' | 'tcp' | 'tls'
    @description('Conditional. SSL certificate of the HTTP listener. Required when protocol is Https.')
    sslCertificate: {
      @description('Required. Resource ID')
      id: string
    }?
    @description('Optional. Host name of HTTP listener.')
    hostName: string?
    @description('Optional. List of Host names for HTTP Listener that allows special wildcard characters as well.')
    hostNames: string[]?
    @description('Optional. Applicable only if protocol is https. Enables SNI for multi-hosting.')
    requireServerNameIndication: bool?
    @description('Optional. SSL profile of the HTTP listener.')
    sslProfile: {
      @description('Required. Resource ID')
      id: string
    }?
    @description('Optional. Custom error configurations of the HTTP listener.')
    customErrorConfigurations: customErrorConfigurationType
    @description('Optional. Reference to the FirewallPolicy resource')
    firewallPolicy: {
      @description('Required. Resource ID of firewall policy')
      id: string
    }?
  }
}[]?

type backendAddressPoolType = {
  @description('Required. Name of the backend pool.')
  name: string
  @description('Optional. Resource ID of backend address pool')
  id: string?
  @description('Required. Properties of backend pool.')
  properties: {
    @description('Optional. Backend addresses.')
    backendAddresses: [
    {
      @description('Optional. FQDN of backend')
      fqdn: string?
      @description('Optional. IP address of backend ')
      ipAddress: string?
    }]
  }?
}[]?

type backendHttpSettingsCollectionType = {
  @description('Required. Name of the backend HTTP settings.')
  name: string
  @description('Optional. Resource ID of backend http settings collection')
  id: string?
  @description('Required. Properties of backend HTTP settings.')
  properties: {
    @description('Required. The destination port on the backend.')
    port: int
    @description('Required. Protocol.')
    protocol: 'http' | 'https' | 'tcp'| 'tls'
    @description('Required. Cookie based affinity.')
    cookieBasedAffinity: 'Enabled' | 'Disabled'
    @description('Optional. Cookie name to use for the affinity cookie.')
    affinityCookieName: string?
    @description('Optional. Request timeout in seconds. Application Gateway will fail the request if response is not received within RequestTimeout. Acceptable values are from 1 second to 86400 seconds.')
    requestTimeout: int?
    @description('Optional. Array of references to application gateway authentication certificates.')
    authenticationCertificates:[
      {
        @description('Required. Resource ID')
        id: string
      }
    ]?
    @description('Optional. Connection draining of the backend http settings resource.')
    connectionDraining: {
      @description('Required. Whether connection draining is enabled or not.')
      enabled: bool
      @description('Required. The number of seconds connection draining is active. Acceptable values are from 1 second to 3600 seconds.')
      drainTimeoutInSec: int
    }?
    @description('Optional. Whether to pick host header should be picked from the host name of the backend server. Default value is false.')
    pickHostNameFromBackendAddress: bool?
    @description('Optional. Host header to be sent to the backend servers.')
    hostName: string?
    @description('Optional. Probe resource of an application gateway.')
    probe: {
      @description('Optional. Probe resource ID of an application gateway.')
      id: string
    }?
    @description('Optional. Path which should be used as a prefix for all HTTP requests. Null means no path will be prefixed. Default value is null.')
    path: string?
    @description('Optional. Whether the probe is enabled. Default value is false.')
    probeEnabled: bool?
    @description('Optional. Array of references to application gateway trusted root certificates.')
    trustedRootCertificates: [
      {
        @description('Required. Resource ID of the trusted root certificate.')
        id: string
      }
    ]?
  }
}[]?

type requestRoutingRuleType = {
  @description('Required. Name of the rule.')
  name: string
  @description('Optional. Resource ID of request routing rule')
  id: string?
  @description('Required. Properties of the rule.')
  properties: {
    @description('Required. Rule type.')
    ruleType: 'Basic' | 'PathBasedRouting'
    @description('Required. Priority of the request routing rule. Must be unique. Value should be between 1 and 20000')
    priority: int
    @description('Required. HTTP listener of the rule.')
    httpListener: {
      @description('Required. Resource ID of http listener.')
      id: string
    }
    @description('Conditional. Backend address pool of the rule. Required when ruleType is Basic and redirectConfiguration is not provided.')
    backendAddressPool: {
      @description('Required. Resource ID of backend address pool.')
      id: string
    }?
    @description('Conditional. Backend HTTP settings of the rule. Required when ruleType is Basic and redirectConfiguration is not provided.')
    backendHttpSettings: {
      @description('Required. Resource ID of backed http settings.')
      id: string
    }?
    @description('Conditional. Redirect configuration of the rule. Required when backendAddressPool and backendHttpSettings are not provided.')
    redirectConfiguration: {
      @description('Required. Resource ID of redirect configuration.')
      id: string
    }?
    @description('Optional. Load Distribution Policy resource of the application gateway.')
    loadDistributionPolicy: {
      @description('Required. Resource ID of load distribution policy.')
      id: string
    }?
    @description('Optional. Rewrite Rule Set resource in Basic rule of the application gateway.')
    rewriteRuleSet: {
      @description('Required. Resource ID of rewrite ruleset.')
      id: string
    }?
    @description('Optional. URL path map resource of the application gateway')
    urlPathMap: {
      @description('Required. Resource ID of url path map.')
      id: string
    }?
  }
}[]?

type gatewayIPConfigurationType = {
  @description('Required. Name of the gateway IP configuration.')
  name: string
  @description('Optional. Resource ID of gateway IP configuration')
  id: string?
  @description('Required. Properties of gateway IP configuration.')
  properties: {
    @description('Required. Resource ID of a subnet.')
    subnet: {
      @description('Required. Resource ID of subnet')
      id: string
    }
  }
}[]?

type probeType = {
  @description('Required. Name of the probe.')
  name: string
  @description('Optional. Resource ID of probe')
  id: string?
  @description('Required. Properties of the probe.')
  properties: {
    @description('Required. Protocol used for the probe.')
    protocol: 'http' | 'https' | 'tcp' | 'tls'
    @description('Optional. Host name to send the probe to.')
    host: string?
    @description('''Required. Relative path of probe. Valid path starts from '/'. Probe is sent to <Protocol>://<host>:<port><path>.''')
    path: string
    @description('Required. Custom port which will be used for probing the backend servers. The valid value ranges from 1 to 65535. In case not set, port from http settings will be used. This property is valid for Basic, Standard_v2 and WAF_v2 only.')
    port: int?
    @description('Required. The probing interval in seconds. This is the time interval between two consecutive probes. Acceptable values are from 1 second to 86400 seconds.')
    interval: int
    @description('Required. The probe timeout in seconds. Probe marked as failed if valid response is not received with this timeout period. Acceptable values are from 1 second to 86400 seconds.')
    timeout: int
    @description('Required. The probe retry count. Backend server is marked down after consecutive probe failure count reaches UnhealthyThreshold. Acceptable values are from 1 second to 20.')
    unhealthyThreshold: int
    @description('Optional. Whether the host header should be picked from the backend http settings. Default value is false.')
    pickHostNameFromBackendHttpSettings: bool?
    @description('Optional. Whether the server name indication should be picked from the backend settings for Tls protocol. Default value is false.')
    pickHostNameFromBackendSettings: bool?
    @description('Optional. Minimum number of servers that are always marked healthy. Default value is 0')
    minServers: int?
    @description('Optional. Criterion for classifying a healthy probe response.')
    match: {
      @description('Optional. Body that must be contained in the health response. Default value is empty.')
      body: string?
      @description('Optional. Allowed ranges of healthy status codes. Default range of healthy status codes is 200-399.')
      statusCodes: string[]?
    }?
  }
}[]?

type redirectConfigurationsType = {
  @description('Required. Name of the redirect configuration.')
  name: string
  @description('Optional. Resource ID of redirect configuration')
  id: string?
  @description('Required. Properties of the redirect configuration.')
  properties: {
    @description('Optional. Include path in the redirected url.')
    includePath: bool?
    @description('Optional. Include query string in the redirect url')
    includeQueryString: bool?
    @description('Required. HTTP redirection type')
    redirectType: 'Found' | 'Permanent' | 'SeeOther' | 'Temporary'
    @description('Required. Request routing specifying redirect configuration.')
    requestRoutingRules: [
      {
        @description('Required. Resource ID of request routing rule')
        id: string
      }
    ]?
    @description('Optional. Path rules specifying redirect configuration.')
    pathRules: [
      {
        @description('Required. Resource ID of path rule')
        id: string?
      }
    ]?
    @description('Required. Reference to a listener to redirect the request to.')
    targetListener: {
      @description('Required. Resource ID of target listener.')
      id: string
    }?
    @description('Optional. Url to redirect the request to.')
    targetUrl: string?
    @description('Optional. Url path maps specifying default redirect configuration.')
    urlPathMaps: [
      {
        @description('Required. Resource ID of url path map.')
        id: string
      }
    ]?
  }
}[]?

type rewriteRuleSetType = {
  @description('Required. Reource ID of the rewrite rule set.')
  id: string

  @description('Required. Name of the rewrite rule set.')
  name: string

  @description('Required. Properties of the rewrite rule set.')
  properties: {
    @description('Required. Rewrite rules in the rewrite rule set.')
    rewriteRules: {
      @description('Required. Name of the rewrite rule.')
      name: string
      @description('Required. Rule sequence.')
      ruleSequence: int
      @description('Optional. Conditions based on which the action set execution will be evaluated.')
      conditions: {
        @description('Optional. Whether to ignore case when evaluating the condition.')
        ignoreCase: bool?
        @description('Optional. Whether to negate the condition.')
        negate: bool?
        @description('Required. Pattern to match.')
        pattern: string
        @description('Required. Variable to be matched.')
        variable: string
      }[]?
      @description('Required. Set of actions to be done as part of the rewrite rule.')
      actionSet: {
        @description('Optional. Request header configuration.')
        requestHeaderConfigurations: {
          @description('Required. Header name.')
          headerName: string
          @description('Optional. Header value.')
          headerValue: string?
          @description('Optional. Header value matcher.')
          headerValueMatcher: {
            @description('Optional. Whether to ignore case when matching.')
            ignoreCase: bool?
            @description('Optional. Whether to negate the match.')
            negate: bool?
            @description('Required. Pattern to match.')
            pattern: string
          }?
        }[]?
        @description('Optional. Response header configuration.')
        responseHeaderConfigurations: {
          @description('Required. Header name.')
          headerName: string
          @description('Optional. Header value.')
          headerValue: string?
          @description('Optional. Header value matcher.')
          headerValueMatcher: {
            @description('Optional. Whether to ignore case when matching.')
            ignoreCase: bool?
            @description('Optional. Whether to negate the match.')
            negate: bool?
            @description('Required. Pattern to match.')
            pattern: string
          }?
        }[]?
        @description('Optional. URL configuration.')
        urlConfiguration: {
          @description('Optional. Modified path.')
          modifiedPath: string?
          @description('Optional. Modified query string.')
          modifiedQueryString: string?
          @description('Optional. Whether to reroute.')
          reroute: bool?
        }?
      }
    }[]
  }
}[]?

type frontendIPConfigurationType = {
  @description('Required. Name of the frontend IP configuration.')
  name: string
  @description('Optional. Resource ID of front end IP configuration')
  id: string?
  @description('Required. Properties of the frontend IP configuration.')
  properties: {
    @description('Optional. Private IP address.')
    privateIPAddress: string?
    @description('Optional. Private IP allocation method.')
    privateIPAllocationMethod: 'Dynamic' | 'Static'?
    @description('Optional. Private link configuration.')
    privateLinkConfiguration: {
      @description('Required. Resource ID of the private link configuration.')
      id: string
    }?
    @description('Optional. Public IP address.')
    publicIPAddress: {
      @description('Required. Resource ID of the public IP address.')
      id: string
    }?
    @description('Optional. Subnet configuration.')
    subnet: {
      @description('Required. Resource ID of the subnet.')
      id: string
    }?
  }
}[]?

type frontendPortType = {
  @description('Optional. Resource Id of the front end port')
  id: string?
  @description('Required. Name of the frontend port.')
  name: string
  @description('Required. Properties of the frontend port.')
  properties: {
    @description('Required. Front end port number.')
    port: int
  }
}[]?

type wafConfigurationType = {
  @description('Required. Web Application Firewall mode.')
  firewallMode: 'Detection' | 'Prevention'
  @description('Required. Web Application Firewall rule set type.')
  ruleSetType: string
  @description('Required. Web Application Firewall rule set version.')
  ruleSetVersion: string
  @description('Optional. Disabled rule groups.')
  disabledRuleGroups: {
    @description('Required. Rule group name.')
    ruleGroupName: string
    @description('Optional. List of rule IDs within the rule group to disable.')
    rules: int[]?
  }[]?
  @description('Optional. WAF exclusions.')
  exclusions: {
    @description('Required. Match variable for the exclusion rule.')
    matchVariable: string
    @description('Optional. Selector for the exclusion rule.')
    selector: string?
    @description('Required. Selector match operator.')
    selectorMatchOperator: string
  }[]?
  @description('Optional. File upload limit in Mb for WAF. Min 0')
  fileUploadLimitInMb: int?
  @description('Optional. Maximum request body size. Min 8, Max 128')
  maxRequestBodySize: int?
  @description('Optional. Maximum request body size in Kb for WAF. Min 8, Max 128')
  maxRequestBodySizeInKb: int?
  @description('Optional. Request body check.')
  requestBodyCheck: bool?
  @description('Required. Web Application Firewall configuration enabled.')
  enabled: bool
}

type urlPathMapType = {
  @description('Required. Resource ID of the URL path map.')
  id: string
  @description('Required. Name of the URL path map.')
  name: string
  @description('Required. Properties of the URL path map.')
  properties: {
    @description('Conditional. Default backend address pool. Required when defaultRedirectConfiguration is not provided.')
    defaultBackendAddressPool: {
      @description('Required. Resource ID of the backend address pool.')
      id: string
    }?
    @description('Conditional. Default backend HTTP settings. Required when defaultRedirectConfiguration is not provided.')
    defaultBackendHttpSettings: {
      @description('Required. Resource ID of the backend HTTP settings.')
      id: string
    }?
    @description('Optional. Default load distribution policy.')
    defaultLoadDistributionPolicy: {
      @description('Required. Resource ID of the load distribution policy.')
      id: string
    }?
    @description('Conditional. Default redirect configuration. Required when defaultBackendAddressPool and defaultBackendHttpSettings are not provided.')
    defaultRedirectConfiguration: {
      @description('Required. Resource ID of the redirect configuration.')
      id: string
    }?
    @description('Optional. Default rewrite rule set.')
    defaultRewriteRuleSet: {
      @description('Required. Resource ID of the rewrite rule set.')
      id: string
    }?
    @description('Required. Array of path rules.')
    pathRules: {
      @description('Optional. Resource ID of the path rule.')
      id: string
      @description('Required. Name of the path rule.')
      name: string
      @description('Required. Properties of the path rule.')
      properties: {
        @description('Conditional. Backend address pool for the path rule. Required when redirectConfiguration is not provided.')
        backendAddressPool: {
          @description('Required. Resource ID of the backend address pool.')
          id: string
        }?
        @description('Conditional. Backend HTTP settings for the path rule. Required when redirectConfiguration is not provided.')
        backendHttpSettings: {
          @description('Required. Resource ID of the backend HTTP settings.')
          id: string
        }?
        @description('Optional. Firewall policy for the path rule.')
        firewallPolicy: {
          @description('Required. Resource ID of the firewall policy.')
          id: string
        }?
        @description('Optional. Load distribution policy for the path rule.')
        loadDistributionPolicy: {
          @description('Required. Resource ID of the load distribution policy.')
          id: string
        }?
        @description('Required. Array of URL paths for the rule.')
        paths: string[]
        @description('Conditional. Redirect configuration for the path rule. Required when backendAddressPool and backendHttpSettings are not provided.')
        redirectConfiguration: {
          @description('Required. Resource ID of the redirect configuration.')
          id: string
        }?
        @description('Optional. Rewrite rule set for the path rule.')
        rewriteRuleSet: {
          @description('Required. Resource ID of the rewrite rule set.')
          id: string
        }?
      }
    }[]?
  }
}[]?

type sslCertificatesType = {
  @description('Required. Name of the SSL certificate')
  name: string
  @description('Optional. Resource ID of the SSL certificate')
  id: string?
     @description('Required. Properties of the SSL certificate')
    properties: {
      @description('Optional. Base-64 encoded pfx certificate. Only applicable in PUT Request.')
      data: string?
      @description('''Optional. Secret Id of (base-64 encoded unencrypted pfx) 'Secret' or 'Certificate' object stored in KeyVault.''')
      keyVaultSecretId: string?
      @description('Optional. Password for the pfx file specified in data. Only applicable in PUT request.')
      password: string?
    }
}[]?

type trustedRootCertificatesType = {
  @description('Required. Name of the SSL certificate')
  name: string
  @description('Optional. Resource ID of the SSL certificate')
  id: string?
     @description('Required. Properties of the SSL certificate')
    properties: {
      @description('Optional. Base-64 encoded pfx certificate. Only applicable in PUT Request.')
      data: string?
      @description('''Optional. Secret Id of (base-64 encoded unencrypted pfx) 'Secret' or 'Certificate' object stored in KeyVault.''')
      keyVaultSecretId: string?
    }
}[]?

import {
  customerManagedKeyManagedDiskType
  customerManagedKeyType
  diagnosticSettingType
  lockType
  managedIdentitiesType
  privateEndpointType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'
