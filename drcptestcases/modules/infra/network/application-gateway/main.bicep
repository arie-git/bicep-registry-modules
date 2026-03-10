@description('The name of the application gateway.')
param name string

@description('The location of the application gateway. Defaults to the location of the resource group.')
param location string = resourceGroup().location

@description('Application gateway size.')
@allowed([
  'Standard_Large'
  'Standard_Medium'
  'Standard_Small'
  'Standard_v2'
  'WAF_Large'
  'WAF_Medium'
  'WAF_v2'
])
param skuName string = 'WAF_v2'

@description('Application gateway size.')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param tier string = 'WAF_v2'

@description('Application gateway autoscale maximum instance capacity.')
@maxValue(125)
@minValue(2)
param autoScaleMaxCapacity int = 2

@description('Application gateway autoscale minimum instance capacity.')
@minValue(1)
param autoScaleMinCapacity int = 1

@description('Optional. Resource Id of the log analytics workspace for diagnostic logs.')
param logAnalyticsWorkspaceId string = ''

@description('The protocol used for backend configuration, listener settings and rules.')
@allowed([
  'Https'
  'Http'
])
param protocol string = 'Https'

@description('Request timeout duration in seconds.')
@minValue(1)
@maxValue(86400)
param duration int = 30

@description('The probing interval in seconds.')
@minValue(1)
@maxValue(86400)
param intervalDuration int =30

@description('The public IP that will be used as frontend address.')
param publicIpId string

@description('Private IP address for gateway')
param privateIpAddress string

@description('The private subnet that will be used as frontend address.')
param subnetId string

@description('Name of WAF policy which will be associated with application gateway.')
param wafPolicyName string

@description('Zones for the resource. For example: [1, 2, 3]. Default: []')
param zones array = []

@description('The port for the listener, it can be well known values such as 80 or 443 but can be more.')
@minValue(1)
@maxValue(65199)
param port int = 443

@description('FQDN for backend pool target resources to which application gateway can send traffic.')
param backendFqdn string = ''

@description('Application Gateway Listener certificate data.')
@secure()
param certificate_data string

@description('Application Gateway Listener certificate password.')
@secure()
param certificate_password string

@description('Http request routing rule type.')
@allowed([
  'Basic'
  'PathBasedRouting'
])
param ruleType string = 'Basic'

@minValue(1)
@maxValue(20000)
@description('The priority value should be between 1 and 20000, where 1 represents highest priority and 20000 represents lowest.')
param rulePriority int = 1

param ipConfigName string = 'appGatewayIpConfig'

param publicFrontendIpName string = 'appGwPublicFrontendIpv4'

param privateFrontendIpName string = 'appGwPrivateFrontendIpv4'

param frontendPortName string = 'appGatewayFrontendPort443'

param backendPoolName string = 'appGatewayBackendPool'

param backendHttpSettingsName string = 'appGatewayBackendHttpSettings'

param listenerName string = 'appGatewayHttpListener'

param healthProbeName string = 'healthProbeHttps'

param ruleName string = 'rule1'

param sslCertificateName string = 'gateway'

param tags object = {}
module wafPolicy 'waf-policy.bicep' = {
  name: wafPolicyName
  params: {
    name: wafPolicyName
    location: location
  }
}

resource appgw 'Microsoft.Network/applicationGateways@2023-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    autoscaleConfiguration: {
      minCapacity: autoScaleMinCapacity
      maxCapacity: autoScaleMaxCapacity
    }
    sku: {
      name: skuName
      tier: tier
    }
    gatewayIPConfigurations: [
      {
        name: ipConfigName
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: publicFrontendIpName
        properties: {
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
      {
        name: privateFrontendIpName
        properties: {
          privateIPAddress: privateIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    enableHttp2: true
    frontendPorts: [
      {
        name: frontendPortName
        properties: {
          port: port
        }
      }
    ]

    backendAddressPools: [
      {
        name: backendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: backendFqdn
            }
          ]
        }
      }
    ]

    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingsName
        properties: {
          port: port
          protocol: protocol
          pickHostNameFromBackendAddress: true
          cookieBasedAffinity: 'Enabled'
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', name, healthProbeName)
          }
          requestTimeout: duration
        }
      }
    ]

    firewallPolicy: {
      id: wafPolicy.outputs.id
    }

    httpListeners: [
      {
        name: listenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, privateFrontendIpName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, frontendPortName)
          }
          protocol: protocol
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', name, sslCertificateName)
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: ruleName
        properties: {
          priority: rulePriority
          ruleType: ruleType
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, listenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', name, backendHttpSettingsName)
          }
        }
      }
    ]

    sslCertificates: [
      {
        name: sslCertificateName
        properties: {
          data: certificate_data
          password: certificate_password
        }
      }
    ]
    sslPolicy: {
      policyType: 'Predefined'
      policyName: 'AppGwSslPolicy20220101'
    }
    probes: [
      {
        name: healthProbeName
        properties: {
          protocol: protocol
          path: '/'
          interval: intervalDuration
          timeout: duration
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
  }
  zones: zones
}

var diagnosticsCategories = [
  'ApplicationGatewayAccessLog'
  'ApplicationGatewayPerformanceLog'
  'ApplicationGatewayFirewallLog'
]

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${name}-diag'
  scope: appgw
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [for category in diagnosticsCategories: {
      category: category
      enabled: true
    }]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
