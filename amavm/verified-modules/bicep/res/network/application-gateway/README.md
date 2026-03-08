# Network Application Gateways `[Microsoft.Network/applicationGateways]`

This module deploys a Network Application Gateway.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Cross-referenced modules](#cross-referenced-modules)
- [Data Collection](#data-collection)

## Compliance

Version: 20250506

Compliant usage of this module requires the following parameter values:
- sku WAF_v2 or Standard_v2
- firewallPolicy configured
- sslPolicyType = 'Predefined'
- sslPolicyName = AppGwSslPolicy20220101 || AppGwSslPolicy20170401S || AppGwSslPolicy20220101S'
- sslPolicyMinProtocolVersion at least TLS_v1_2
- no Public IP attached in httpListener
- httpListener protocol = 'https'
- backendPool protocol = 'https'
- requestRoutingRules not empty


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.Network/applicationGateways` | 2024-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_applicationgateways.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-05-01/applicationGateways)</li></ul> |
| `Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies` | 2024-03-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_applicationgatewaywebapplicationfirewallpolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-03-01/ApplicationGatewayWebApplicationFirewallPolicies)</li></ul> |
| `Microsoft.Network/privateEndpoints` | 2024-01-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-01-01/privateEndpoints)</li></ul> |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/privateEndpoints/privateDnsZoneGroups)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/network/application-gateway:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [Using large parameter set](#example-2-using-large-parameter-set)
- [WAF-aligned](#example-3-waf-aligned)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module applicationGatewayMod 'br/<registry-alias>:res/network/application-gateway:<version>' = {
  name: 'applicationGateway-mod'
  params: {
    // Required parameters
    name: '<name>'
    // Non-required parameters
    backendAddressPools: [
      {
        name: 'backendAddressPool1'
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings1'
        properties: {
          cookieBasedAffinity: 'Disabled'
          port: 80
          protocol: 'http'
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfig1'
        properties: {
          publicIPAddress: {
            id: '<id>'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'frontendPort1'
        properties: {
          port: 80
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'publicIPConfig1'
        properties: {
          subnet: {
            id: '<id>'
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener1'
        properties: {
          frontendIPConfiguration: {
            id: '<id>'
          }
          frontendPort: {
            id: '<id>'
          }
          hostName: 'www.contoso.com'
          protocol: 'http'
        }
      }
    ]
    location: '<location>'
    managedIdentities: {}
    requestRoutingRules: [
      {
        name: 'requestRoutingRule1'
        properties: {
          backendAddressPool: {
            id: '<id>'
          }
          backendHttpSettings: {
            id: '<id>'
          }
          httpListener: {
            id: '<id>'
          }
          priority: 100
          ruleType: 'Basic'
        }
      }
    ]
    sku: 'Standard_v2'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/network/application-gateway:<version>'

// Required parameters
param name = '<name>'
// Non-required parameters
param backendAddressPools = [
  {
    name: 'backendAddressPool1'
  }
]
param backendHttpSettingsCollection = [
  {
    name: 'backendHttpSettings1'
    properties: {
      cookieBasedAffinity: 'Disabled'
      port: 80
      protocol: 'http'
    }
  }
]
param frontendIPConfigurations = [
  {
    name: 'frontendIPConfig1'
    properties: {
      publicIPAddress: {
        id: '<id>'
      }
    }
  }
]
param frontendPorts = [
  {
    name: 'frontendPort1'
    properties: {
      port: 80
    }
  }
]
param gatewayIPConfigurations = [
  {
    name: 'publicIPConfig1'
    properties: {
      subnet: {
        id: '<id>'
      }
    }
  }
]
param httpListeners = [
  {
    name: 'httpListener1'
    properties: {
      frontendIPConfiguration: {
        id: '<id>'
      }
      frontendPort: {
        id: '<id>'
      }
      hostName: 'www.contoso.com'
      protocol: 'http'
    }
  }
]
param location = '<location>'
param managedIdentities = {}
param requestRoutingRules = [
  {
    name: 'requestRoutingRule1'
    properties: {
      backendAddressPool: {
        id: '<id>'
      }
      backendHttpSettings: {
        id: '<id>'
      }
      httpListener: {
        id: '<id>'
      }
      priority: 100
      ruleType: 'Basic'
    }
  }
]
param sku = 'Standard_v2'
```

</details>
<p>

### Example 2: _Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module applicationGatewayMod 'br/<registry-alias>:res/network/application-gateway:<version>' = {
  name: 'applicationGateway-mod'
  params: {
    // Required parameters
    name: '<name>'
    // Non-required parameters
    backendAddressPools: [
      {
        name: 'appServiceBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: 'aghapp.azurewebsites.net'
            }
          ]
        }
      }
      {
        name: 'privateVmBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: '10.0.0.4'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appServiceBackendHttpsSetting'
        properties: {
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          port: 443
          protocol: 'https'
          requestTimeout: 30
        }
      }
      {
        name: 'privateVmHttpSetting'
        properties: {
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          port: 80
          probe: {
            id: '<id>'
          }
          protocol: 'http'
          requestTimeout: 30
        }
      }
    ]
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    enableHttp2: true
    enableTelemetry: '<enableTelemetry>'
    frontendIPConfigurations: [
      {
        name: 'private'
        properties: {
          privateIPAddress: '10.0.0.20'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: '<id>'
          }
        }
      }
      {
        name: 'public'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateLinkConfiguration: {
            id: '<id>'
          }
          publicIPAddress: {
            id: '<id>'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port4433'
        properties: {
          port: 4433
        }
      }
      {
        name: 'port80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port8080'
        properties: {
          port: 8080
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'apw-ip-configuration'
        properties: {
          subnet: {
            id: '<id>'
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'public443'
        properties: {
          frontendIPConfiguration: {
            id: '<id>'
          }
          frontendPort: {
            id: '<id>'
          }
          hostNames: []
          protocol: 'https'
          requireServerNameIndication: false
          sslCertificate: {
            id: '<id>'
          }
        }
      }
      {
        name: 'private4433'
        properties: {
          frontendIPConfiguration: {
            id: '<id>'
          }
          frontendPort: {
            id: '<id>'
          }
          hostNames: []
          protocol: 'https'
          requireServerNameIndication: false
          sslCertificate: {
            id: '<id>'
          }
        }
      }
      {
        name: 'httpRedirect80'
        properties: {
          frontendIPConfiguration: {
            id: '<id>'
          }
          frontendPort: {
            id: '<id>'
          }
          hostNames: []
          protocol: 'http'
          requireServerNameIndication: false
        }
      }
      {
        name: 'httpRedirect8080'
        properties: {
          frontendIPConfiguration: {
            id: '<id>'
          }
          frontendPort: {
            id: '<id>'
          }
          hostNames: []
          protocol: 'http'
          requireServerNameIndication: false
        }
      }
    ]
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedIdentities: {
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'public'
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          Role: 'DeploymentValidation'
        }
      }
    ]
    privateLinkConfigurations: [
      {
        id: '<id>'
        name: 'pvtlink01'
        properties: {
          ipConfigurations: [
            {
              id: '<id>'
              name: 'privateLinkIpConfig1'
              properties: {
                primary: false
                privateIPAllocationMethod: 'Dynamic'
                subnet: {
                  id: '<id>'
                }
              }
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'privateVmHttpSettingProbe'
        properties: {
          host: '10.0.0.4'
          interval: 60
          match: {
            statusCodes: [
              '200'
              '401'
            ]
          }
          minServers: 3
          path: '/'
          pickHostNameFromBackendHttpSettings: false
          protocol: 'http'
          timeout: 15
          unhealthyThreshold: 5
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'httpRedirect80'
        properties: {
          includePath: true
          includeQueryString: true
          redirectType: 'Permanent'
          requestRoutingRules: [
            {
              id: '<id>'
            }
          ]
          targetListener: {
            id: '<id>'
          }
        }
      }
      {
        name: 'httpRedirect8080'
        properties: {
          includePath: true
          includeQueryString: true
          redirectType: 'Permanent'
          requestRoutingRules: [
            {
              id: '<id>'
            }
          ]
          targetListener: {
            id: '<id>'
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'public443-appServiceBackendHttpsSetting-appServiceBackendHttpsSetting'
        properties: {
          backendAddressPool: {
            id: '<id>'
          }
          backendHttpSettings: {
            id: '<id>'
          }
          httpListener: {
            id: '<id>'
          }
          priority: 200
          ruleType: 'Basic'
        }
      }
      {
        name: 'private4433-privateVmHttpSetting-privateVmHttpSetting'
        properties: {
          backendAddressPool: {
            id: '<id>'
          }
          backendHttpSettings: {
            id: '<id>'
          }
          httpListener: {
            id: '<id>'
          }
          priority: 250
          ruleType: 'Basic'
        }
      }
      {
        name: 'httpRedirect80-public443'
        properties: {
          httpListener: {
            id: '<id>'
          }
          priority: 300
          redirectConfiguration: {
            id: '<id>'
          }
          ruleType: 'Basic'
        }
      }
      {
        name: 'httpRedirect8080-private4433'
        properties: {
          httpListener: {
            id: '<id>'
          }
          priority: 350
          redirectConfiguration: {
            id: '<id>'
          }
          rewriteRuleSet: {
            id: '<id>'
          }
          ruleType: 'Basic'
        }
      }
    ]
    rewriteRuleSets: [
      {
        id: '<id>'
        name: 'customRewrite'
        properties: {
          rewriteRules: [
            {
              actionSet: {
                requestHeaderConfigurations: [
                  {
                    headerName: 'Content-Type'
                    headerValue: 'JSON'
                  }
                  {
                    headerName: 'someheader'
                  }
                ]
                responseHeaderConfigurations: []
              }
              conditions: []
              name: 'NewRewrite'
              ruleSequence: 100
            }
          ]
        }
      }
    ]
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Owner'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
      }
    ]
    sku: 'WAF_v2'
    sslCertificates: [
      {
        name: 'az-apgw-x-001-ssl-certificate'
        properties: {
          keyVaultSecretId: '<keyVaultSecretId>'
        }
      }
    ]
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    webApplicationFirewallConfiguration: {
      disabledRuleGroups: [
        {
          ruleGroupName: 'Known-CVEs'
        }
        {
          ruleGroupName: 'REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION'
        }
        {
          ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
        }
      ]
      enabled: true
      exclusions: [
        {
          matchVariable: 'RequestHeaderNames'
          selector: 'hola'
          selectorMatchOperator: 'StartsWith'
        }
      ]
      fileUploadLimitInMb: 100
      firewallMode: 'Detection'
      maxRequestBodySizeInKb: 128
      requestBodyCheck: true
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
    zones: [
      '1'
      '2'
      '3'
    ]
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/network/application-gateway:<version>'

// Required parameters
param name = '<name>'
// Non-required parameters
param backendAddressPools = [
  {
    name: 'appServiceBackendPool'
    properties: {
      backendAddresses: [
        {
          fqdn: 'aghapp.azurewebsites.net'
        }
      ]
    }
  }
  {
    name: 'privateVmBackendPool'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.0.0.4'
        }
      ]
    }
  }
]
param backendHttpSettingsCollection = [
  {
    name: 'appServiceBackendHttpsSetting'
    properties: {
      cookieBasedAffinity: 'Disabled'
      pickHostNameFromBackendAddress: true
      port: 443
      protocol: 'https'
      requestTimeout: 30
    }
  }
  {
    name: 'privateVmHttpSetting'
    properties: {
      cookieBasedAffinity: 'Disabled'
      pickHostNameFromBackendAddress: false
      port: 80
      probe: {
        id: '<id>'
      }
      protocol: 'http'
      requestTimeout: 30
    }
  }
]
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
    name: 'customSetting'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
enableHttp2: true
param enableTelemetry = '<enableTelemetry>'
param frontendIPConfigurations = [
  {
    name: 'private'
    properties: {
      privateIPAddress: '10.0.0.20'
      privateIPAllocationMethod: 'Static'
      subnet: {
        id: '<id>'
      }
    }
  }
  {
    name: 'public'
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      privateLinkConfiguration: {
        id: '<id>'
      }
      publicIPAddress: {
        id: '<id>'
      }
    }
  }
]
param frontendPorts = [
  {
    name: 'port443'
    properties: {
      port: 443
    }
  }
  {
    name: 'port4433'
    properties: {
      port: 4433
    }
  }
  {
    name: 'port80'
    properties: {
      port: 80
    }
  }
  {
    name: 'port8080'
    properties: {
      port: 8080
    }
  }
]
param gatewayIPConfigurations = [
  {
    name: 'apw-ip-configuration'
    properties: {
      subnet: {
        id: '<id>'
      }
    }
  }
]
param httpListeners = [
  {
    name: 'public443'
    properties: {
      frontendIPConfiguration: {
        id: '<id>'
      }
      frontendPort: {
        id: '<id>'
      }
      hostNames: []
      protocol: 'https'
      requireServerNameIndication: false
      sslCertificate: {
        id: '<id>'
      }
    }
  }
  {
    name: 'private4433'
    properties: {
      frontendIPConfiguration: {
        id: '<id>'
      }
      frontendPort: {
        id: '<id>'
      }
      hostNames: []
      protocol: 'https'
      requireServerNameIndication: false
      sslCertificate: {
        id: '<id>'
      }
    }
  }
  {
    name: 'httpRedirect80'
    properties: {
      frontendIPConfiguration: {
        id: '<id>'
      }
      frontendPort: {
        id: '<id>'
      }
      hostNames: []
      protocol: 'http'
      requireServerNameIndication: false
    }
  }
  {
    name: 'httpRedirect8080'
    properties: {
      frontendIPConfiguration: {
        id: '<id>'
      }
      frontendPort: {
        id: '<id>'
      }
      hostNames: []
      protocol: 'http'
      requireServerNameIndication: false
    }
  }
]
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedIdentities = {
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param privateEndpoints = [
  {
    privateDnsZoneGroup: {
      privateDnsZoneGroupConfigs: [
        {
          privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
        }
      ]
    }
    service: 'public'
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
]
param privateLinkConfigurations = [
  {
    id: '<id>'
    name: 'pvtlink01'
    properties: {
      ipConfigurations: [
        {
          id: '<id>'
          name: 'privateLinkIpConfig1'
          properties: {
            primary: false
            privateIPAllocationMethod: 'Dynamic'
            subnet: {
              id: '<id>'
            }
          }
        }
      ]
    }
  }
]
param probes = [
  {
    name: 'privateVmHttpSettingProbe'
    properties: {
      host: '10.0.0.4'
      interval: 60
      match: {
        statusCodes: [
          '200'
          '401'
        ]
      }
      minServers: 3
      path: '/'
      pickHostNameFromBackendHttpSettings: false
      protocol: 'http'
      timeout: 15
      unhealthyThreshold: 5
    }
  }
]
param redirectConfigurations = [
  {
    name: 'httpRedirect80'
    properties: {
      includePath: true
      includeQueryString: true
      redirectType: 'Permanent'
      requestRoutingRules: [
        {
          id: '<id>'
        }
      ]
      targetListener: {
        id: '<id>'
      }
    }
  }
  {
    name: 'httpRedirect8080'
    properties: {
      includePath: true
      includeQueryString: true
      redirectType: 'Permanent'
      requestRoutingRules: [
        {
          id: '<id>'
        }
      ]
      targetListener: {
        id: '<id>'
      }
    }
  }
]
param requestRoutingRules = [
  {
    name: 'public443-appServiceBackendHttpsSetting-appServiceBackendHttpsSetting'
    properties: {
      backendAddressPool: {
        id: '<id>'
      }
      backendHttpSettings: {
        id: '<id>'
      }
      httpListener: {
        id: '<id>'
      }
      priority: 200
      ruleType: 'Basic'
    }
  }
  {
    name: 'private4433-privateVmHttpSetting-privateVmHttpSetting'
    properties: {
      backendAddressPool: {
        id: '<id>'
      }
      backendHttpSettings: {
        id: '<id>'
      }
      httpListener: {
        id: '<id>'
      }
      priority: 250
      ruleType: 'Basic'
    }
  }
  {
    name: 'httpRedirect80-public443'
    properties: {
      httpListener: {
        id: '<id>'
      }
      priority: 300
      redirectConfiguration: {
        id: '<id>'
      }
      ruleType: 'Basic'
    }
  }
  {
    name: 'httpRedirect8080-private4433'
    properties: {
      httpListener: {
        id: '<id>'
      }
      priority: 350
      redirectConfiguration: {
        id: '<id>'
      }
      rewriteRuleSet: {
        id: '<id>'
      }
      ruleType: 'Basic'
    }
  }
]
param rewriteRuleSets = [
  {
    id: '<id>'
    name: 'customRewrite'
    properties: {
      rewriteRules: [
        {
          actionSet: {
            requestHeaderConfigurations: [
              {
                headerName: 'Content-Type'
                headerValue: 'JSON'
              }
              {
                headerName: 'someheader'
              }
            ]
            responseHeaderConfigurations: []
          }
          conditions: []
          name: 'NewRewrite'
          ruleSequence: 100
        }
      ]
    }
  }
]
param roleAssignments = [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]
param sku = 'WAF_v2'
param sslCertificates = [
  {
    name: 'az-apgw-x-001-ssl-certificate'
    properties: {
      keyVaultSecretId: '<keyVaultSecretId>'
    }
  }
]
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
param webApplicationFirewallConfiguration = {
  disabledRuleGroups: [
    {
      ruleGroupName: 'Known-CVEs'
    }
    {
      ruleGroupName: 'REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION'
    }
    {
      ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
    }
  ]
  enabled: true
  exclusions: [
    {
      matchVariable: 'RequestHeaderNames'
      selector: 'hola'
      selectorMatchOperator: 'StartsWith'
    }
  ]
  fileUploadLimitInMb: 100
  firewallMode: 'Detection'
  maxRequestBodySizeInKb: 128
  requestBodyCheck: true
  ruleSetType: 'OWASP'
  ruleSetVersion: '3.0'
}
param zones = [
  '1'
  '2'
  '3'
]
```

</details>
<p>

### Example 3: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module applicationGatewayMod 'br/<registry-alias>:res/network/application-gateway:<version>' = {
  name: 'applicationGateway-mod'
  params: {
    // Required parameters
    name: '<name>'
    // Non-required parameters
    backendAddressPools: [
      {
        name: 'appServiceBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: 'aghapp.azurewebsites.net'
            }
          ]
        }
      }
      {
        name: 'privateVmBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: '10.0.0.4'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appServiceBackendHttpsSetting'
        properties: {
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          port: 443
          protocol: 'https'
          requestTimeout: 30
        }
      }
      {
        name: 'privateVmHttpSetting'
        properties: {
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          port: 80
          probe: {
            id: '<id>'
          }
          protocol: 'http'
          requestTimeout: 30
        }
      }
    ]
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    enableHttp2: true
    enableTelemetry: '<enableTelemetry>'
    firewallPolicyResourceId: '<firewallPolicyResourceId>'
    frontendIPConfigurations: [
      {
        name: 'private'
        properties: {
          privateIPAddress: '10.0.0.20'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: '<id>'
          }
        }
      }
      {
        name: 'public'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateLinkConfiguration: {
            id: '<id>'
          }
          publicIPAddress: {
            id: '<id>'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port4433'
        properties: {
          port: 4433
        }
      }
      {
        name: 'port80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port8080'
        properties: {
          port: 8080
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'apw-ip-configuration'
        properties: {
          subnet: {
            id: '<id>'
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'public443'
        properties: {
          frontendIPConfiguration: {
            id: '<id>'
          }
          frontendPort: {
            id: '<id>'
          }
          hostNames: []
          protocol: 'https'
          requireServerNameIndication: false
          sslCertificate: {
            id: '<id>'
          }
        }
      }
      {
        name: 'private4433'
        properties: {
          frontendIPConfiguration: {
            id: '<id>'
          }
          frontendPort: {
            id: '<id>'
          }
          hostNames: []
          protocol: 'https'
          requireServerNameIndication: false
          sslCertificate: {
            id: '<id>'
          }
        }
      }
      {
        name: 'httpRedirect80'
        properties: {
          frontendIPConfiguration: {
            id: '<id>'
          }
          frontendPort: {
            id: '<id>'
          }
          hostNames: []
          protocol: 'http'
          requireServerNameIndication: false
        }
      }
      {
        name: 'httpRedirect8080'
        properties: {
          frontendIPConfiguration: {
            id: '<id>'
          }
          frontendPort: {
            id: '<id>'
          }
          hostNames: []
          protocol: 'http'
          requireServerNameIndication: false
        }
      }
    ]
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedIdentities: {
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'public'
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          Role: 'DeploymentValidation'
        }
      }
    ]
    privateLinkConfigurations: [
      {
        id: '<id>'
        name: 'pvtlink01'
        properties: {
          ipConfigurations: [
            {
              id: '<id>'
              name: 'privateLinkIpConfig1'
              properties: {
                primary: false
                privateIPAllocationMethod: 'Dynamic'
                subnet: {
                  id: '<id>'
                }
              }
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'privateVmHttpSettingProbe'
        properties: {
          host: '10.0.0.4'
          interval: 60
          match: {
            statusCodes: [
              '200'
              '401'
            ]
          }
          minServers: 3
          path: '/'
          pickHostNameFromBackendHttpSettings: false
          protocol: 'http'
          timeout: 15
          unhealthyThreshold: 5
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'httpRedirect80'
        properties: {
          includePath: true
          includeQueryString: true
          redirectType: 'Permanent'
          requestRoutingRules: [
            {
              id: '<id>'
            }
          ]
          targetListener: {
            id: '<id>'
          }
        }
      }
      {
        name: 'httpRedirect8080'
        properties: {
          includePath: true
          includeQueryString: true
          redirectType: 'Permanent'
          requestRoutingRules: [
            {
              id: '<id>'
            }
          ]
          targetListener: {
            id: '<id>'
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'public443-appServiceBackendHttpsSetting-appServiceBackendHttpsSetting'
        properties: {
          backendAddressPool: {
            id: '<id>'
          }
          backendHttpSettings: {
            id: '<id>'
          }
          httpListener: {
            id: '<id>'
          }
          priority: 200
          ruleType: 'Basic'
        }
      }
      {
        name: 'private4433-privateVmHttpSetting-privateVmHttpSetting'
        properties: {
          backendAddressPool: {
            id: '<id>'
          }
          backendHttpSettings: {
            id: '<id>'
          }
          httpListener: {
            id: '<id>'
          }
          priority: 250
          ruleType: 'Basic'
        }
      }
      {
        name: 'httpRedirect80-public443'
        properties: {
          httpListener: {
            id: '<id>'
          }
          priority: 300
          redirectConfiguration: {
            id: '<id>'
          }
          ruleType: 'Basic'
        }
      }
      {
        name: 'httpRedirect8080-private4433'
        properties: {
          httpListener: {
            id: '<id>'
          }
          priority: 350
          redirectConfiguration: {
            id: '<id>'
          }
          rewriteRuleSet: {
            id: '<id>'
          }
          ruleType: 'Basic'
        }
      }
    ]
    rewriteRuleSets: [
      {
        id: '<id>'
        name: 'customRewrite'
        properties: {
          rewriteRules: [
            {
              actionSet: {
                requestHeaderConfigurations: [
                  {
                    headerName: 'Content-Type'
                    headerValue: 'JSON'
                  }
                  {
                    headerName: 'someheader'
                  }
                ]
                responseHeaderConfigurations: []
              }
              conditions: []
              name: 'NewRewrite'
              ruleSequence: 100
            }
          ]
        }
      }
    ]
    sku: 'WAF_v2'
    sslCertificates: [
      {
        name: 'az-apgw-x-001-ssl-certificate'
        properties: {
          keyVaultSecretId: '<keyVaultSecretId>'
        }
      }
    ]
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/network/application-gateway:<version>'

// Required parameters
param name = '<name>'
// Non-required parameters
param backendAddressPools = [
  {
    name: 'appServiceBackendPool'
    properties: {
      backendAddresses: [
        {
          fqdn: 'aghapp.azurewebsites.net'
        }
      ]
    }
  }
  {
    name: 'privateVmBackendPool'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.0.0.4'
        }
      ]
    }
  }
]
param backendHttpSettingsCollection = [
  {
    name: 'appServiceBackendHttpsSetting'
    properties: {
      cookieBasedAffinity: 'Disabled'
      pickHostNameFromBackendAddress: true
      port: 443
      protocol: 'https'
      requestTimeout: 30
    }
  }
  {
    name: 'privateVmHttpSetting'
    properties: {
      cookieBasedAffinity: 'Disabled'
      pickHostNameFromBackendAddress: false
      port: 80
      probe: {
        id: '<id>'
      }
      protocol: 'http'
      requestTimeout: 30
    }
  }
]
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
    name: 'customSetting'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
enableHttp2: true
param enableTelemetry = '<enableTelemetry>'
param firewallPolicyResourceId = '<firewallPolicyResourceId>'
param frontendIPConfigurations = [
  {
    name: 'private'
    properties: {
      privateIPAddress: '10.0.0.20'
      privateIPAllocationMethod: 'Static'
      subnet: {
        id: '<id>'
      }
    }
  }
  {
    name: 'public'
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      privateLinkConfiguration: {
        id: '<id>'
      }
      publicIPAddress: {
        id: '<id>'
      }
    }
  }
]
param frontendPorts = [
  {
    name: 'port443'
    properties: {
      port: 443
    }
  }
  {
    name: 'port4433'
    properties: {
      port: 4433
    }
  }
  {
    name: 'port80'
    properties: {
      port: 80
    }
  }
  {
    name: 'port8080'
    properties: {
      port: 8080
    }
  }
]
param gatewayIPConfigurations = [
  {
    name: 'apw-ip-configuration'
    properties: {
      subnet: {
        id: '<id>'
      }
    }
  }
]
param httpListeners = [
  {
    name: 'public443'
    properties: {
      frontendIPConfiguration: {
        id: '<id>'
      }
      frontendPort: {
        id: '<id>'
      }
      hostNames: []
      protocol: 'https'
      requireServerNameIndication: false
      sslCertificate: {
        id: '<id>'
      }
    }
  }
  {
    name: 'private4433'
    properties: {
      frontendIPConfiguration: {
        id: '<id>'
      }
      frontendPort: {
        id: '<id>'
      }
      hostNames: []
      protocol: 'https'
      requireServerNameIndication: false
      sslCertificate: {
        id: '<id>'
      }
    }
  }
  {
    name: 'httpRedirect80'
    properties: {
      frontendIPConfiguration: {
        id: '<id>'
      }
      frontendPort: {
        id: '<id>'
      }
      hostNames: []
      protocol: 'http'
      requireServerNameIndication: false
    }
  }
  {
    name: 'httpRedirect8080'
    properties: {
      frontendIPConfiguration: {
        id: '<id>'
      }
      frontendPort: {
        id: '<id>'
      }
      hostNames: []
      protocol: 'http'
      requireServerNameIndication: false
    }
  }
]
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedIdentities = {
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param privateEndpoints = [
  {
    privateDnsZoneGroup: {
      privateDnsZoneGroupConfigs: [
        {
          privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
        }
      ]
    }
    service: 'public'
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
]
param privateLinkConfigurations = [
  {
    id: '<id>'
    name: 'pvtlink01'
    properties: {
      ipConfigurations: [
        {
          id: '<id>'
          name: 'privateLinkIpConfig1'
          properties: {
            primary: false
            privateIPAllocationMethod: 'Dynamic'
            subnet: {
              id: '<id>'
            }
          }
        }
      ]
    }
  }
]
param probes = [
  {
    name: 'privateVmHttpSettingProbe'
    properties: {
      host: '10.0.0.4'
      interval: 60
      match: {
        statusCodes: [
          '200'
          '401'
        ]
      }
      minServers: 3
      path: '/'
      pickHostNameFromBackendHttpSettings: false
      protocol: 'http'
      timeout: 15
      unhealthyThreshold: 5
    }
  }
]
param redirectConfigurations = [
  {
    name: 'httpRedirect80'
    properties: {
      includePath: true
      includeQueryString: true
      redirectType: 'Permanent'
      requestRoutingRules: [
        {
          id: '<id>'
        }
      ]
      targetListener: {
        id: '<id>'
      }
    }
  }
  {
    name: 'httpRedirect8080'
    properties: {
      includePath: true
      includeQueryString: true
      redirectType: 'Permanent'
      requestRoutingRules: [
        {
          id: '<id>'
        }
      ]
      targetListener: {
        id: '<id>'
      }
    }
  }
]
param requestRoutingRules = [
  {
    name: 'public443-appServiceBackendHttpsSetting-appServiceBackendHttpsSetting'
    properties: {
      backendAddressPool: {
        id: '<id>'
      }
      backendHttpSettings: {
        id: '<id>'
      }
      httpListener: {
        id: '<id>'
      }
      priority: 200
      ruleType: 'Basic'
    }
  }
  {
    name: 'private4433-privateVmHttpSetting-privateVmHttpSetting'
    properties: {
      backendAddressPool: {
        id: '<id>'
      }
      backendHttpSettings: {
        id: '<id>'
      }
      httpListener: {
        id: '<id>'
      }
      priority: 250
      ruleType: 'Basic'
    }
  }
  {
    name: 'httpRedirect80-public443'
    properties: {
      httpListener: {
        id: '<id>'
      }
      priority: 300
      redirectConfiguration: {
        id: '<id>'
      }
      ruleType: 'Basic'
    }
  }
  {
    name: 'httpRedirect8080-private4433'
    properties: {
      httpListener: {
        id: '<id>'
      }
      priority: 350
      redirectConfiguration: {
        id: '<id>'
      }
      rewriteRuleSet: {
        id: '<id>'
      }
      ruleType: 'Basic'
    }
  }
]
param rewriteRuleSets = [
  {
    id: '<id>'
    name: 'customRewrite'
    properties: {
      rewriteRules: [
        {
          actionSet: {
            requestHeaderConfigurations: [
              {
                headerName: 'Content-Type'
                headerValue: 'JSON'
              }
              {
                headerName: 'someheader'
              }
            ]
            responseHeaderConfigurations: []
          }
          conditions: []
          name: 'NewRewrite'
          ruleSequence: 100
        }
      ]
    }
  }
]
param sku = 'WAF_v2'
param sslCertificates = [
  {
    name: 'az-apgw-x-001-ssl-certificate'
    properties: {
      keyVaultSecretId: '<keyVaultSecretId>'
    }
  }
]
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | Name of the Application Gateway. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authenticationCertificates`](#parameter-authenticationcertificates) | array | Authentication certificates of the application gateway resource. |
| [`autoscaleMaxCapacity`](#parameter-autoscalemaxcapacity) | int | Upper bound on number of Application Gateway capacity. |
| [`autoscaleMinCapacity`](#parameter-autoscalemincapacity) | int | Lower bound on number of Application Gateway capacity. |
| [`backendAddressPools`](#parameter-backendaddresspools) | array | Backend address pool of the application gateway resource. Compliant usage requires 'https' protocol |
| [`backendHttpSettingsCollection`](#parameter-backendhttpsettingscollection) | array | Backend http settings of the application gateway resource. Compliant usage requires 'https' protocol |
| [`backendSettingsCollection`](#parameter-backendsettingscollection) | array | Backend settings of the application gateway resource. For default limits, see [Application Gateway limits](https://learn.microsoft.com/en-us/azure/azure-subscription-service-limits#application-gateway-limits). |
| [`capacity`](#parameter-capacity) | int | The number of Application instances to be configured. |
| [`customErrorConfigurations`](#parameter-customerrorconfigurations) | array | Custom error configurations of the application gateway resource. |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service. |
| [`enableFips`](#parameter-enablefips) | bool | Whether FIPS is enabled on the application gateway resource. Default is false |
| [`enableHttp2`](#parameter-enablehttp2) | bool | Whether HTTP2 is enabled on the application gateway resource. Default is true |
| [`enableRequestBuffering`](#parameter-enablerequestbuffering) | bool | Enable request buffering. |
| [`enableResponseBuffering`](#parameter-enableresponsebuffering) | bool | Enable response buffering. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`firewallPolicyResourceId`](#parameter-firewallpolicyresourceid) | string | The resource ID of an associated firewall policy. This will override the compliant by default WAF policy |
| [`frontendIPConfigurations`](#parameter-frontendipconfigurations) | array | Frontend IP addresses of the application gateway resource. |
| [`frontendPorts`](#parameter-frontendports) | array | Frontend ports of the application gateway resource. |
| [`gatewayIPConfigurations`](#parameter-gatewayipconfigurations) | array | Subnets of the application gateway resource. |
| [`httpListeners`](#parameter-httplisteners) | array | Http listeners of the application gateway resource. Compliant usage requires HTTPS protocol, additionally Public IP address in frontend IP configuration results in non-compliance. |
| [`listeners`](#parameter-listeners) | array | Listeners of the application gateway resource. For default limits, see [Application Gateway limits](https://learn.microsoft.com/en-us/azure/azure-subscription-service-limits#application-gateway-limits). |
| [`loadDistributionPolicies`](#parameter-loaddistributionpolicies) | array | Load distribution policies of the application gateway resource. |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`managedIdentities`](#parameter-managedidentities) | object | The managed identity definition for this resource. |
| [`privateEndpoints`](#parameter-privateendpoints) | array | Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. |
| [`privateLinkConfigurations`](#parameter-privatelinkconfigurations) | array | PrivateLink configurations on application gateway. |
| [`probes`](#parameter-probes) | array | Probes of the application gateway resource. |
| [`redirectConfigurations`](#parameter-redirectconfigurations) | array | Redirect configurations of the application gateway resource. |
| [`requestRoutingRules`](#parameter-requestroutingrules) | array | Request routing rules of the application gateway resource. Compliant usage requires at least one request routing rule configured. |
| [`rewriteRuleSets`](#parameter-rewriterulesets) | array | Rewrite rules for the application gateway resource. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`routingRules`](#parameter-routingrules) | array | Routing rules of the application gateway resource. |
| [`sku`](#parameter-sku) | string | The name of the SKU for the Application Gateway. Defaults to WAF_v2. Compliant usage requires Standard_v2 or WAF_v2 |
| [`sslCertificates`](#parameter-sslcertificates) | array | SSL certificates of the application gateway resource. |
| [`sslPolicyCipherSuites`](#parameter-sslpolicyciphersuites) | array | Ssl cipher suites to be enabled in the specified order to application gateway. |
| [`sslPolicyMinProtocolVersion`](#parameter-sslpolicyminprotocolversion) | string | Ssl protocol enums. Compliant usage requires at least TLSv1_2. |
| [`sslPolicyName`](#parameter-sslpolicyname) | string | Ssl predefined policy name enums. Compliant usage requires (default) AppGwSslPolicy20220101 or AppGwSslPolicy20170401S or AppGwSslPolicy20220101S |
| [`sslPolicyType`](#parameter-sslpolicytype) | string | Type of Ssl Policy. Compliant usage requires (default) Predefined |
| [`sslProfiles`](#parameter-sslprofiles) | array | SSL profiles of the application gateway resource. |
| [`tags`](#parameter-tags) | object | Resource tags. |
| [`trustedClientCertificates`](#parameter-trustedclientcertificates) | array | Trusted client certificates of the application gateway resource. |
| [`trustedRootCertificates`](#parameter-trustedrootcertificates) | array | Trusted Root certificates of the application gateway resource. |
| [`urlPathMaps`](#parameter-urlpathmaps) | array | URL path map of the application gateway resource. |
| [`webApplicationFirewallConfiguration`](#parameter-webapplicationfirewallconfiguration) | object | Application gateway web application firewall configuration. This will override the compliant by default WAF policy. |
| [`zones`](#parameter-zones) | array | Zones for the resource. For example: [1, 2, 3]. Default: [] |

### Parameter: `name`

Name of the Application Gateway.

- Required: Yes
- Type: string

### Parameter: `authenticationCertificates`

Authentication certificates of the application gateway resource.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `autoscaleMaxCapacity`

Upper bound on number of Application Gateway capacity.

- Required: No
- Type: int
- Default: `2`
- MinValue: 2
- MaxValue: 125

### Parameter: `autoscaleMinCapacity`

Lower bound on number of Application Gateway capacity.

- Required: No
- Type: int
- Default: `1`
- MinValue: 1

### Parameter: `backendAddressPools`

Backend address pool of the application gateway resource. Compliant usage requires 'https' protocol

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-backendaddresspoolsname) | string | Name of the backend pool. |
| [`properties`](#parameter-backendaddresspoolsproperties) | object | Properties of backend pool. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-backendaddresspoolsid) | string | Resource ID of backend address pool |

### Parameter: `backendAddressPools.name`

Name of the backend pool.

- Required: Yes
- Type: string

### Parameter: `backendAddressPools.properties`

Properties of backend pool.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`backendAddresses`](#parameter-backendaddresspoolspropertiesbackendaddresses) | array | Backend addresses. |

### Parameter: `backendAddressPools.properties.backendAddresses`

Backend addresses.

- Required: Yes
- Type: array

### Parameter: `backendAddressPools.id`

Resource ID of backend address pool

- Required: No
- Type: string

### Parameter: `backendHttpSettingsCollection`

Backend http settings of the application gateway resource. Compliant usage requires 'https' protocol

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-backendhttpsettingscollectionname) | string | Name of the backend HTTP settings. |
| [`properties`](#parameter-backendhttpsettingscollectionproperties) | object | Properties of backend HTTP settings. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-backendhttpsettingscollectionid) | string | Resource ID of backend http settings collection |

### Parameter: `backendHttpSettingsCollection.name`

Name of the backend HTTP settings.

- Required: Yes
- Type: string

### Parameter: `backendHttpSettingsCollection.properties`

Properties of backend HTTP settings.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`cookieBasedAffinity`](#parameter-backendhttpsettingscollectionpropertiescookiebasedaffinity) | string | Cookie based affinity. |
| [`port`](#parameter-backendhttpsettingscollectionpropertiesport) | int | The destination port on the backend. |
| [`protocol`](#parameter-backendhttpsettingscollectionpropertiesprotocol) | string | Protocol. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`affinityCookieName`](#parameter-backendhttpsettingscollectionpropertiesaffinitycookiename) | string | Cookie name to use for the affinity cookie. |
| [`authenticationCertificates`](#parameter-backendhttpsettingscollectionpropertiesauthenticationcertificates) | array | Array of references to application gateway authentication certificates. |
| [`connectionDraining`](#parameter-backendhttpsettingscollectionpropertiesconnectiondraining) | object | Connection draining of the backend http settings resource. |
| [`hostName`](#parameter-backendhttpsettingscollectionpropertieshostname) | string | Host header to be sent to the backend servers. |
| [`path`](#parameter-backendhttpsettingscollectionpropertiespath) | string | Path which should be used as a prefix for all HTTP requests. Null means no path will be prefixed. Default value is null. |
| [`pickHostNameFromBackendAddress`](#parameter-backendhttpsettingscollectionpropertiespickhostnamefrombackendaddress) | bool | Whether to pick host header should be picked from the host name of the backend server. Default value is false. |
| [`probe`](#parameter-backendhttpsettingscollectionpropertiesprobe) | object | Probe resource of an application gateway. |
| [`probeEnabled`](#parameter-backendhttpsettingscollectionpropertiesprobeenabled) | bool | Whether the probe is enabled. Default value is false. |
| [`requestTimeout`](#parameter-backendhttpsettingscollectionpropertiesrequesttimeout) | int | Request timeout in seconds. Application Gateway will fail the request if response is not received within RequestTimeout. Acceptable values are from 1 second to 86400 seconds. |
| [`trustedRootCertificates`](#parameter-backendhttpsettingscollectionpropertiestrustedrootcertificates) | array | Array of references to application gateway trusted root certificates. |

### Parameter: `backendHttpSettingsCollection.properties.cookieBasedAffinity`

Cookie based affinity.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `backendHttpSettingsCollection.properties.port`

The destination port on the backend.

- Required: Yes
- Type: int

### Parameter: `backendHttpSettingsCollection.properties.protocol`

Protocol.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'http'
    'https'
    'tcp'
    'tls'
  ]
  ```

### Parameter: `backendHttpSettingsCollection.properties.affinityCookieName`

Cookie name to use for the affinity cookie.

- Required: No
- Type: string

### Parameter: `backendHttpSettingsCollection.properties.authenticationCertificates`

Array of references to application gateway authentication certificates.

- Required: No
- Type: array

### Parameter: `backendHttpSettingsCollection.properties.connectionDraining`

Connection draining of the backend http settings resource.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`drainTimeoutInSec`](#parameter-backendhttpsettingscollectionpropertiesconnectiondrainingdraintimeoutinsec) | int | The number of seconds connection draining is active. Acceptable values are from 1 second to 3600 seconds. |
| [`enabled`](#parameter-backendhttpsettingscollectionpropertiesconnectiondrainingenabled) | bool | Whether connection draining is enabled or not. |

### Parameter: `backendHttpSettingsCollection.properties.connectionDraining.drainTimeoutInSec`

The number of seconds connection draining is active. Acceptable values are from 1 second to 3600 seconds.

- Required: Yes
- Type: int

### Parameter: `backendHttpSettingsCollection.properties.connectionDraining.enabled`

Whether connection draining is enabled or not.

- Required: Yes
- Type: bool

### Parameter: `backendHttpSettingsCollection.properties.hostName`

Host header to be sent to the backend servers.

- Required: No
- Type: string

### Parameter: `backendHttpSettingsCollection.properties.path`

Path which should be used as a prefix for all HTTP requests. Null means no path will be prefixed. Default value is null.

- Required: No
- Type: string

### Parameter: `backendHttpSettingsCollection.properties.pickHostNameFromBackendAddress`

Whether to pick host header should be picked from the host name of the backend server. Default value is false.

- Required: No
- Type: bool

### Parameter: `backendHttpSettingsCollection.properties.probe`

Probe resource of an application gateway.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-backendhttpsettingscollectionpropertiesprobeid) | string | Probe resource ID of an application gateway. |

### Parameter: `backendHttpSettingsCollection.properties.probe.id`

Probe resource ID of an application gateway.

- Required: Yes
- Type: string

### Parameter: `backendHttpSettingsCollection.properties.probeEnabled`

Whether the probe is enabled. Default value is false.

- Required: No
- Type: bool

### Parameter: `backendHttpSettingsCollection.properties.requestTimeout`

Request timeout in seconds. Application Gateway will fail the request if response is not received within RequestTimeout. Acceptable values are from 1 second to 86400 seconds.

- Required: No
- Type: int

### Parameter: `backendHttpSettingsCollection.properties.trustedRootCertificates`

Array of references to application gateway trusted root certificates.

- Required: No
- Type: array

### Parameter: `backendHttpSettingsCollection.id`

Resource ID of backend http settings collection

- Required: No
- Type: string

### Parameter: `backendSettingsCollection`

Backend settings of the application gateway resource. For default limits, see [Application Gateway limits](https://learn.microsoft.com/en-us/azure/azure-subscription-service-limits#application-gateway-limits).

- Required: No
- Type: array
- Default: `[]`

### Parameter: `capacity`

The number of Application instances to be configured.

- Required: No
- Type: int
- Default: `2`
- MinValue: 0
- MaxValue: 10

### Parameter: `customErrorConfigurations`

Custom error configurations of the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`customErrorPageUrl`](#parameter-customerrorconfigurationscustomerrorpageurl) | string | Error page URL of the application gateway custom error. |
| [`statusCode`](#parameter-customerrorconfigurationsstatuscode) | string | Status code of the application gateway custom error. |

### Parameter: `customErrorConfigurations.customErrorPageUrl`

Error page URL of the application gateway custom error.

- Required: Yes
- Type: string

### Parameter: `customErrorConfigurations.statusCode`

Status code of the application gateway custom error.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'HttpStatus400'
    'HttpStatus403'
    'HttpStatus404'
    'HttpStatus405'
    'HttpStatus408'
    'HttpStatus500'
    'HttpStatus502'
    'HttpStatus503'
    'HttpStatus504'
  ]
  ```

### Parameter: `diagnosticSettings`

The diagnostic settings of the service.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`eventHubAuthorizationRuleResourceId`](#parameter-diagnosticsettingseventhubauthorizationruleresourceid) | string | Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| [`eventHubName`](#parameter-diagnosticsettingseventhubname) | string | Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`logAnalyticsDestinationType`](#parameter-diagnosticsettingsloganalyticsdestinationtype) | string | A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type. |
| [`logCategoriesAndGroups`](#parameter-diagnosticsettingslogcategoriesandgroups) | array | The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection. |
| [`marketplacePartnerResourceId`](#parameter-diagnosticsettingsmarketplacepartnerresourceid) | string | The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs. |
| [`metricCategories`](#parameter-diagnosticsettingsmetriccategories) | array | The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection. |
| [`name`](#parameter-diagnosticsettingsname) | string | The name of diagnostic setting. |
| [`storageAccountResourceId`](#parameter-diagnosticsettingsstorageaccountresourceid) | string | Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`workspaceResourceId`](#parameter-diagnosticsettingsworkspaceresourceid) | string | Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |

### Parameter: `diagnosticSettings.eventHubAuthorizationRuleResourceId`

Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.eventHubName`

Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logAnalyticsDestinationType`

A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureDiagnostics'
    'Dedicated'
  ]
  ```

### Parameter: `diagnosticSettings.logCategoriesAndGroups`

The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingslogcategoriesandgroupscategory) | string | Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here. |
| [`categoryGroup`](#parameter-diagnosticsettingslogcategoriesandgroupscategorygroup) | string | Name of a Diagnostic Log category group for a resource type this setting is applied to. |
| [`enabled`](#parameter-diagnosticsettingslogcategoriesandgroupsenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `diagnosticSettings.logCategoriesAndGroups.category`

Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logCategoriesAndGroups.categoryGroup`

Name of a Diagnostic Log category group for a resource type this setting is applied to.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logCategoriesAndGroups.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `diagnosticSettings.marketplacePartnerResourceId`

The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.metricCategories`

The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingsmetriccategoriescategory) | string | Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-diagnosticsettingsmetriccategoriesenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `diagnosticSettings.metricCategories.category`

Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.

- Required: Yes
- Type: string

### Parameter: `diagnosticSettings.metricCategories.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `diagnosticSettings.name`

The name of diagnostic setting.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.storageAccountResourceId`

Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.workspaceResourceId`

Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `enableFips`

Whether FIPS is enabled on the application gateway resource. Default is false

- Required: No
- Type: bool
- Default: `False`

### Parameter: `enableHttp2`

Whether HTTP2 is enabled on the application gateway resource. Default is true

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableRequestBuffering`

Enable request buffering.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `enableResponseBuffering`

Enable response buffering.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `firewallPolicyResourceId`

The resource ID of an associated firewall policy. This will override the compliant by default WAF policy

- Required: No
- Type: string
- Default: `''`

### Parameter: `frontendIPConfigurations`

Frontend IP addresses of the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-frontendipconfigurationsname) | string | Name of the frontend IP configuration. |
| [`properties`](#parameter-frontendipconfigurationsproperties) | object | Properties of the frontend IP configuration. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-frontendipconfigurationsid) | string | Resource ID of front end IP configuration |

### Parameter: `frontendIPConfigurations.name`

Name of the frontend IP configuration.

- Required: Yes
- Type: string

### Parameter: `frontendIPConfigurations.properties`

Properties of the frontend IP configuration.

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`privateIPAddress`](#parameter-frontendipconfigurationspropertiesprivateipaddress) | string | Private IP address. |
| [`privateIPAllocationMethod`](#parameter-frontendipconfigurationspropertiesprivateipallocationmethod) | string | Private IP allocation method. |
| [`privateLinkConfiguration`](#parameter-frontendipconfigurationspropertiesprivatelinkconfiguration) | object | Private link configuration. |
| [`publicIPAddress`](#parameter-frontendipconfigurationspropertiespublicipaddress) | object | Public IP address. |
| [`subnet`](#parameter-frontendipconfigurationspropertiessubnet) | object | Subnet configuration. |

### Parameter: `frontendIPConfigurations.properties.privateIPAddress`

Private IP address.

- Required: No
- Type: string

### Parameter: `frontendIPConfigurations.properties.privateIPAllocationMethod`

Private IP allocation method.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Dynamic'
    'Static'
  ]
  ```

### Parameter: `frontendIPConfigurations.properties.privateLinkConfiguration`

Private link configuration.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-frontendipconfigurationspropertiesprivatelinkconfigurationid) | string | Resource ID of the private link configuration. |

### Parameter: `frontendIPConfigurations.properties.privateLinkConfiguration.id`

Resource ID of the private link configuration.

- Required: Yes
- Type: string

### Parameter: `frontendIPConfigurations.properties.publicIPAddress`

Public IP address.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-frontendipconfigurationspropertiespublicipaddressid) | string | Resource ID of the public IP address. |

### Parameter: `frontendIPConfigurations.properties.publicIPAddress.id`

Resource ID of the public IP address.

- Required: Yes
- Type: string

### Parameter: `frontendIPConfigurations.properties.subnet`

Subnet configuration.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-frontendipconfigurationspropertiessubnetid) | string | Resource ID of the subnet. |

### Parameter: `frontendIPConfigurations.properties.subnet.id`

Resource ID of the subnet.

- Required: Yes
- Type: string

### Parameter: `frontendIPConfigurations.id`

Resource ID of front end IP configuration

- Required: No
- Type: string

### Parameter: `frontendPorts`

Frontend ports of the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-frontendportsname) | string | Name of the frontend port. |
| [`properties`](#parameter-frontendportsproperties) | object | Properties of the frontend port. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-frontendportsid) | string | Resource Id of the front end port |

### Parameter: `frontendPorts.name`

Name of the frontend port.

- Required: Yes
- Type: string

### Parameter: `frontendPorts.properties`

Properties of the frontend port.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`port`](#parameter-frontendportspropertiesport) | int | Front end port number. |

### Parameter: `frontendPorts.properties.port`

Front end port number.

- Required: Yes
- Type: int

### Parameter: `frontendPorts.id`

Resource Id of the front end port

- Required: No
- Type: string

### Parameter: `gatewayIPConfigurations`

Subnets of the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-gatewayipconfigurationsname) | string | Name of the gateway IP configuration. |
| [`properties`](#parameter-gatewayipconfigurationsproperties) | object | Properties of gateway IP configuration. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-gatewayipconfigurationsid) | string | Resource ID of gateway IP configuration |

### Parameter: `gatewayIPConfigurations.name`

Name of the gateway IP configuration.

- Required: Yes
- Type: string

### Parameter: `gatewayIPConfigurations.properties`

Properties of gateway IP configuration.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnet`](#parameter-gatewayipconfigurationspropertiessubnet) | object | Resource ID of a subnet. |

### Parameter: `gatewayIPConfigurations.properties.subnet`

Resource ID of a subnet.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-gatewayipconfigurationspropertiessubnetid) | string | Resource ID of subnet |

### Parameter: `gatewayIPConfigurations.properties.subnet.id`

Resource ID of subnet

- Required: Yes
- Type: string

### Parameter: `gatewayIPConfigurations.id`

Resource ID of gateway IP configuration

- Required: No
- Type: string

### Parameter: `httpListeners`

Http listeners of the application gateway resource. Compliant usage requires HTTPS protocol, additionally Public IP address in frontend IP configuration results in non-compliance.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-httplistenersname) | string | Name of the HTTP listener. |
| [`properties`](#parameter-httplistenersproperties) | object | Properties of HTTP listener. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-httplistenersid) | string | Resource ID of HTTP listener |

### Parameter: `httpListeners.name`

Name of the HTTP listener.

- Required: Yes
- Type: string

### Parameter: `httpListeners.properties`

Properties of HTTP listener.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`frontendIPConfiguration`](#parameter-httplistenerspropertiesfrontendipconfiguration) | object | Frontend IP configuration of the HTTP listener. |
| [`frontendPort`](#parameter-httplistenerspropertiesfrontendport) | object | Frontend port of the HTTP listener. |
| [`protocol`](#parameter-httplistenerspropertiesprotocol) | string | Protocol of the HTTP listener. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`sslCertificate`](#parameter-httplistenerspropertiessslcertificate) | object | SSL certificate of the HTTP listener. Required when protocol is Https. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`customErrorConfigurations`](#parameter-httplistenerspropertiescustomerrorconfigurations) | array | Custom error configurations of the HTTP listener. |
| [`firewallPolicy`](#parameter-httplistenerspropertiesfirewallpolicy) | object | Reference to the FirewallPolicy resource |
| [`hostName`](#parameter-httplistenerspropertieshostname) | string | Host name of HTTP listener. |
| [`hostNames`](#parameter-httplistenerspropertieshostnames) | array | List of Host names for HTTP Listener that allows special wildcard characters as well. |
| [`requireServerNameIndication`](#parameter-httplistenerspropertiesrequireservernameindication) | bool | Applicable only if protocol is https. Enables SNI for multi-hosting. |
| [`sslProfile`](#parameter-httplistenerspropertiessslprofile) | object | SSL profile of the HTTP listener. |

### Parameter: `httpListeners.properties.frontendIPConfiguration`

Frontend IP configuration of the HTTP listener.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-httplistenerspropertiesfrontendipconfigurationid) | string | Resource ID of the HTTP listener |

### Parameter: `httpListeners.properties.frontendIPConfiguration.id`

Resource ID of the HTTP listener

- Required: Yes
- Type: string

### Parameter: `httpListeners.properties.frontendPort`

Frontend port of the HTTP listener.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-httplistenerspropertiesfrontendportid) | string | Resource ID of Front end port |

### Parameter: `httpListeners.properties.frontendPort.id`

Resource ID of Front end port

- Required: Yes
- Type: string

### Parameter: `httpListeners.properties.protocol`

Protocol of the HTTP listener.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'http'
    'https'
    'tcp'
    'tls'
  ]
  ```

### Parameter: `httpListeners.properties.sslCertificate`

SSL certificate of the HTTP listener. Required when protocol is Https.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-httplistenerspropertiessslcertificateid) | string | Resource ID |

### Parameter: `httpListeners.properties.sslCertificate.id`

Resource ID

- Required: Yes
- Type: string

### Parameter: `httpListeners.properties.customErrorConfigurations`

Custom error configurations of the HTTP listener.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`customErrorPageUrl`](#parameter-httplistenerspropertiescustomerrorconfigurationscustomerrorpageurl) | string | Error page URL of the application gateway custom error. |
| [`statusCode`](#parameter-httplistenerspropertiescustomerrorconfigurationsstatuscode) | string | Status code of the application gateway custom error. |

### Parameter: `httpListeners.properties.customErrorConfigurations.customErrorPageUrl`

Error page URL of the application gateway custom error.

- Required: Yes
- Type: string

### Parameter: `httpListeners.properties.customErrorConfigurations.statusCode`

Status code of the application gateway custom error.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'HttpStatus400'
    'HttpStatus403'
    'HttpStatus404'
    'HttpStatus405'
    'HttpStatus408'
    'HttpStatus500'
    'HttpStatus502'
    'HttpStatus503'
    'HttpStatus504'
  ]
  ```

### Parameter: `httpListeners.properties.firewallPolicy`

Reference to the FirewallPolicy resource

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-httplistenerspropertiesfirewallpolicyid) | string | Resource ID of firewall policy |

### Parameter: `httpListeners.properties.firewallPolicy.id`

Resource ID of firewall policy

- Required: Yes
- Type: string

### Parameter: `httpListeners.properties.hostName`

Host name of HTTP listener.

- Required: No
- Type: string

### Parameter: `httpListeners.properties.hostNames`

List of Host names for HTTP Listener that allows special wildcard characters as well.

- Required: No
- Type: array

### Parameter: `httpListeners.properties.requireServerNameIndication`

Applicable only if protocol is https. Enables SNI for multi-hosting.

- Required: No
- Type: bool

### Parameter: `httpListeners.properties.sslProfile`

SSL profile of the HTTP listener.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-httplistenerspropertiessslprofileid) | string | Resource ID |

### Parameter: `httpListeners.properties.sslProfile.id`

Resource ID

- Required: Yes
- Type: string

### Parameter: `httpListeners.id`

Resource ID of HTTP listener

- Required: No
- Type: string

### Parameter: `listeners`

Listeners of the application gateway resource. For default limits, see [Application Gateway limits](https://learn.microsoft.com/en-us/azure/azure-subscription-service-limits#application-gateway-limits).

- Required: No
- Type: array
- Default: `[]`

### Parameter: `loadDistributionPolicies`

Load distribution policies of the application gateway resource.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `location`

Location for all resources.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `lock`

The lock settings of the service.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-lockkind) | string | Specify the type of lock. |
| [`name`](#parameter-lockname) | string | Specify the name of lock. |

### Parameter: `lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `managedIdentities`

The managed identity definition for this resource.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      systemAssigned: true
  }
  ```

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`systemAssigned`](#parameter-managedidentitiessystemassigned) | bool | Enables system assigned managed identity on the resource. |
| [`userAssignedResourceIds`](#parameter-managedidentitiesuserassignedresourceids) | array | The resource ID(s) to assign to the resource. |

### Parameter: `managedIdentities.systemAssigned`

Enables system assigned managed identity on the resource.

- Required: No
- Type: bool

### Parameter: `managedIdentities.userAssignedResourceIds`

The resource ID(s) to assign to the resource.

- Required: No
- Type: array

### Parameter: `privateEndpoints`

Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.

- Required: No
- Type: array
- Default: `[]`

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnetResourceId`](#parameter-privateendpointssubnetresourceid) | string | Resource ID of the subnet where the endpoint needs to be created. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`service`](#parameter-privateendpointsservice) | string | If the resource supports multiple endpoints, specify the sub-resource to deploy the private endpoint for.<p>For example "blob", "table", "queue" or "file".<p><p>See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`applicationSecurityGroupResourceIds`](#parameter-privateendpointsapplicationsecuritygroupresourceids) | array | Application security groups in which the private endpoint IP configuration is included. |
| [`customDnsConfigs`](#parameter-privateendpointscustomdnsconfigs) | array | Custom DNS configurations. |
| [`customNetworkInterfaceName`](#parameter-privateendpointscustomnetworkinterfacename) | string | The custom name of the network interface attached to the private endpoint. |
| [`enableTelemetry`](#parameter-privateendpointsenabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`ipConfigurations`](#parameter-privateendpointsipconfigurations) | array | A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints. |
| [`isManualConnection`](#parameter-privateendpointsismanualconnection) | bool | If Manual Private Link Connection is required. |
| [`location`](#parameter-privateendpointslocation) | string | The location to deploy the private endpoint to. |
| [`lock`](#parameter-privateendpointslock) | object | Specify the type of lock. |
| [`manualConnectionRequestMessage`](#parameter-privateendpointsmanualconnectionrequestmessage) | string | A message passed to the owner of the remote resource with the manual connection request. |
| [`name`](#parameter-privateendpointsname) | string | The name of the private endpoint. |
| [`privateDnsZoneGroupName`](#parameter-privateendpointsprivatednszonegroupname) | string | The name of the private DNS zone group to create if `privateDnsZoneResourceIds` were provided. |
| [`privateDnsZoneResourceIds`](#parameter-privateendpointsprivatednszoneresourceids) | array | The private DNS zone groups to associate the private endpoint with. A DNS zone group can support up to 5 DNS zones. |
| [`privateLinkServiceConnectionName`](#parameter-privateendpointsprivatelinkserviceconnectionname) | string | The name of the private link connection to create. |
| [`resourceGroupName`](#parameter-privateendpointsresourcegroupname) | string | Specify if you want to deploy the Private Endpoint into a different resource group than the main resource. |
| [`roleAssignments`](#parameter-privateendpointsroleassignments) | array | Array of role assignments to create. |
| [`tags`](#parameter-privateendpointstags) | object | Tags to be applied on all resources/resource groups in this deployment. |

### Parameter: `privateEndpoints.subnetResourceId`

Resource ID of the subnet where the endpoint needs to be created.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.service`

If the resource supports multiple endpoints, specify the sub-resource to deploy the private endpoint for.<p>For example "blob", "table", "queue" or "file".<p><p>See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource

- Required: No
- Type: string

### Parameter: `privateEndpoints.applicationSecurityGroupResourceIds`

Application security groups in which the private endpoint IP configuration is included.

- Required: No
- Type: array

### Parameter: `privateEndpoints.customDnsConfigs`

Custom DNS configurations.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`fqdn`](#parameter-privateendpointscustomdnsconfigsfqdn) | string | Fqdn that resolves to private endpoint IP address. |
| [`ipAddresses`](#parameter-privateendpointscustomdnsconfigsipaddresses) | array | A list of private IP addresses of the private endpoint. |

### Parameter: `privateEndpoints.customDnsConfigs.fqdn`

Fqdn that resolves to private endpoint IP address.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.customDnsConfigs.ipAddresses`

A list of private IP addresses of the private endpoint.

- Required: Yes
- Type: array

### Parameter: `privateEndpoints.customNetworkInterfaceName`

The custom name of the network interface attached to the private endpoint.

- Required: No
- Type: string

### Parameter: `privateEndpoints.enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool

### Parameter: `privateEndpoints.ipConfigurations`

A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-privateendpointsipconfigurationsname) | string | The name of the resource that is unique within a resource group. |
| [`properties`](#parameter-privateendpointsipconfigurationsproperties) | object | Properties of private endpoint IP configurations. |

### Parameter: `privateEndpoints.ipConfigurations.name`

The name of the resource that is unique within a resource group.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.ipConfigurations.properties`

Properties of private endpoint IP configurations.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`groupId`](#parameter-privateendpointsipconfigurationspropertiesgroupid) | string | The ID of a group obtained from the remote resource that this private endpoint should connect to. |
| [`memberName`](#parameter-privateendpointsipconfigurationspropertiesmembername) | string | The member name of a group obtained from the remote resource that this private endpoint should connect to. |
| [`privateIPAddress`](#parameter-privateendpointsipconfigurationspropertiesprivateipaddress) | string | A private IP address obtained from the private endpoint's subnet. |

### Parameter: `privateEndpoints.ipConfigurations.properties.groupId`

The ID of a group obtained from the remote resource that this private endpoint should connect to.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.ipConfigurations.properties.memberName`

The member name of a group obtained from the remote resource that this private endpoint should connect to.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.ipConfigurations.properties.privateIPAddress`

A private IP address obtained from the private endpoint's subnet.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.isManualConnection`

If Manual Private Link Connection is required.

- Required: No
- Type: bool

### Parameter: `privateEndpoints.location`

The location to deploy the private endpoint to.

- Required: No
- Type: string

### Parameter: `privateEndpoints.lock`

Specify the type of lock.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-privateendpointslockkind) | string | Specify the type of lock. |
| [`name`](#parameter-privateendpointslockname) | string | Specify the name of lock. |

### Parameter: `privateEndpoints.lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `privateEndpoints.lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `privateEndpoints.manualConnectionRequestMessage`

A message passed to the owner of the remote resource with the manual connection request.

- Required: No
- Type: string

### Parameter: `privateEndpoints.name`

The name of the private endpoint.

- Required: No
- Type: string

### Parameter: `privateEndpoints.privateDnsZoneGroupName`

The name of the private DNS zone group to create if `privateDnsZoneResourceIds` were provided.

- Required: No
- Type: string

### Parameter: `privateEndpoints.privateDnsZoneResourceIds`

The private DNS zone groups to associate the private endpoint with. A DNS zone group can support up to 5 DNS zones.

- Required: No
- Type: array

### Parameter: `privateEndpoints.privateLinkServiceConnectionName`

The name of the private link connection to create.

- Required: No
- Type: string

### Parameter: `privateEndpoints.resourceGroupName`

Specify if you want to deploy the Private Endpoint into a different resource group than the main resource.

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'DNS Resolver Contributor'`
  - `'DNS Zone Contributor'`
  - `'Domain Services Contributor'`
  - `'Domain Services Reader'`
  - `'Network Contributor'`
  - `'Private DNS Zone Contributor'`

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-privateendpointsroleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-privateendpointsroleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-privateendpointsroleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-privateendpointsroleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-privateendpointsroleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-privateendpointsroleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-privateendpointsroleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `privateEndpoints.roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `privateEndpoints.roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments.principalType`

The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
  ]
  ```

### Parameter: `privateEndpoints.tags`

Tags to be applied on all resources/resource groups in this deployment.

- Required: No
- Type: object

### Parameter: `privateLinkConfigurations`

PrivateLink configurations on application gateway.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `probes`

Probes of the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-probesname) | string | Name of the probe. |
| [`properties`](#parameter-probesproperties) | object | Properties of the probe. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-probesid) | string | Resource ID of probe |

### Parameter: `probes.name`

Name of the probe.

- Required: Yes
- Type: string

### Parameter: `probes.properties`

Properties of the probe.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`interval`](#parameter-probespropertiesinterval) | int | The probing interval in seconds. This is the time interval between two consecutive probes. Acceptable values are from 1 second to 86400 seconds. |
| [`path`](#parameter-probespropertiespath) | string | Relative path of probe. Valid path starts from '/'. Probe is sent to <Protocol>://<host>:<port><path>. |
| [`port`](#parameter-probespropertiesport) | int | Custom port which will be used for probing the backend servers. The valid value ranges from 1 to 65535. In case not set, port from http settings will be used. This property is valid for Basic, Standard_v2 and WAF_v2 only. |
| [`protocol`](#parameter-probespropertiesprotocol) | string | Protocol used for the probe. |
| [`timeout`](#parameter-probespropertiestimeout) | int | The probe timeout in seconds. Probe marked as failed if valid response is not received with this timeout period. Acceptable values are from 1 second to 86400 seconds. |
| [`unhealthyThreshold`](#parameter-probespropertiesunhealthythreshold) | int | The probe retry count. Backend server is marked down after consecutive probe failure count reaches UnhealthyThreshold. Acceptable values are from 1 second to 20. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`host`](#parameter-probespropertieshost) | string | Host name to send the probe to. |
| [`match`](#parameter-probespropertiesmatch) | object | Criterion for classifying a healthy probe response. |
| [`minServers`](#parameter-probespropertiesminservers) | int | Minimum number of servers that are always marked healthy. Default value is 0 |
| [`pickHostNameFromBackendHttpSettings`](#parameter-probespropertiespickhostnamefrombackendhttpsettings) | bool | Whether the host header should be picked from the backend http settings. Default value is false. |
| [`pickHostNameFromBackendSettings`](#parameter-probespropertiespickhostnamefrombackendsettings) | bool | Whether the server name indication should be picked from the backend settings for Tls protocol. Default value is false. |

### Parameter: `probes.properties.interval`

The probing interval in seconds. This is the time interval between two consecutive probes. Acceptable values are from 1 second to 86400 seconds.

- Required: Yes
- Type: int

### Parameter: `probes.properties.path`

Relative path of probe. Valid path starts from '/'. Probe is sent to <Protocol>://<host>:<port><path>.

- Required: Yes
- Type: string

### Parameter: `probes.properties.port`

Custom port which will be used for probing the backend servers. The valid value ranges from 1 to 65535. In case not set, port from http settings will be used. This property is valid for Basic, Standard_v2 and WAF_v2 only.

- Required: No
- Type: int

### Parameter: `probes.properties.protocol`

Protocol used for the probe.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'http'
    'https'
    'tcp'
    'tls'
  ]
  ```

### Parameter: `probes.properties.timeout`

The probe timeout in seconds. Probe marked as failed if valid response is not received with this timeout period. Acceptable values are from 1 second to 86400 seconds.

- Required: Yes
- Type: int

### Parameter: `probes.properties.unhealthyThreshold`

The probe retry count. Backend server is marked down after consecutive probe failure count reaches UnhealthyThreshold. Acceptable values are from 1 second to 20.

- Required: Yes
- Type: int

### Parameter: `probes.properties.host`

Host name to send the probe to.

- Required: No
- Type: string

### Parameter: `probes.properties.match`

Criterion for classifying a healthy probe response.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`body`](#parameter-probespropertiesmatchbody) | string | Body that must be contained in the health response. Default value is empty. |
| [`statusCodes`](#parameter-probespropertiesmatchstatuscodes) | array | Allowed ranges of healthy status codes. Default range of healthy status codes is 200-399. |

### Parameter: `probes.properties.match.body`

Body that must be contained in the health response. Default value is empty.

- Required: No
- Type: string

### Parameter: `probes.properties.match.statusCodes`

Allowed ranges of healthy status codes. Default range of healthy status codes is 200-399.

- Required: No
- Type: array

### Parameter: `probes.properties.minServers`

Minimum number of servers that are always marked healthy. Default value is 0

- Required: No
- Type: int

### Parameter: `probes.properties.pickHostNameFromBackendHttpSettings`

Whether the host header should be picked from the backend http settings. Default value is false.

- Required: No
- Type: bool

### Parameter: `probes.properties.pickHostNameFromBackendSettings`

Whether the server name indication should be picked from the backend settings for Tls protocol. Default value is false.

- Required: No
- Type: bool

### Parameter: `probes.id`

Resource ID of probe

- Required: No
- Type: string

### Parameter: `redirectConfigurations`

Redirect configurations of the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-redirectconfigurationsname) | string | Name of the redirect configuration. |
| [`properties`](#parameter-redirectconfigurationsproperties) | object | Properties of the redirect configuration. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-redirectconfigurationsid) | string | Resource ID of redirect configuration |

### Parameter: `redirectConfigurations.name`

Name of the redirect configuration.

- Required: Yes
- Type: string

### Parameter: `redirectConfigurations.properties`

Properties of the redirect configuration.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`redirectType`](#parameter-redirectconfigurationspropertiesredirecttype) | string | HTTP redirection type |
| [`requestRoutingRules`](#parameter-redirectconfigurationspropertiesrequestroutingrules) | array | Request routing specifying redirect configuration. |
| [`targetListener`](#parameter-redirectconfigurationspropertiestargetlistener) | object | Reference to a listener to redirect the request to. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`includePath`](#parameter-redirectconfigurationspropertiesincludepath) | bool | Include path in the redirected url. |
| [`includeQueryString`](#parameter-redirectconfigurationspropertiesincludequerystring) | bool | Include query string in the redirect url |
| [`pathRules`](#parameter-redirectconfigurationspropertiespathrules) | array | Path rules specifying redirect configuration. |
| [`targetUrl`](#parameter-redirectconfigurationspropertiestargeturl) | string | Url to redirect the request to. |
| [`urlPathMaps`](#parameter-redirectconfigurationspropertiesurlpathmaps) | array | Url path maps specifying default redirect configuration. |

### Parameter: `redirectConfigurations.properties.redirectType`

HTTP redirection type

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Found'
    'Permanent'
    'SeeOther'
    'Temporary'
  ]
  ```

### Parameter: `redirectConfigurations.properties.requestRoutingRules`

Request routing specifying redirect configuration.

- Required: No
- Type: array

### Parameter: `redirectConfigurations.properties.targetListener`

Reference to a listener to redirect the request to.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-redirectconfigurationspropertiestargetlistenerid) | string | Resource ID of target listener. |

### Parameter: `redirectConfigurations.properties.targetListener.id`

Resource ID of target listener.

- Required: Yes
- Type: string

### Parameter: `redirectConfigurations.properties.includePath`

Include path in the redirected url.

- Required: No
- Type: bool

### Parameter: `redirectConfigurations.properties.includeQueryString`

Include query string in the redirect url

- Required: No
- Type: bool

### Parameter: `redirectConfigurations.properties.pathRules`

Path rules specifying redirect configuration.

- Required: No
- Type: array

### Parameter: `redirectConfigurations.properties.targetUrl`

Url to redirect the request to.

- Required: No
- Type: string

### Parameter: `redirectConfigurations.properties.urlPathMaps`

Url path maps specifying default redirect configuration.

- Required: No
- Type: array

### Parameter: `redirectConfigurations.id`

Resource ID of redirect configuration

- Required: No
- Type: string

### Parameter: `requestRoutingRules`

Request routing rules of the application gateway resource. Compliant usage requires at least one request routing rule configured.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-requestroutingrulesname) | string | Name of the rule. |
| [`properties`](#parameter-requestroutingrulesproperties) | object | Properties of the rule. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-requestroutingrulesid) | string | Resource ID of request routing rule |

### Parameter: `requestRoutingRules.name`

Name of the rule.

- Required: Yes
- Type: string

### Parameter: `requestRoutingRules.properties`

Properties of the rule.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`httpListener`](#parameter-requestroutingrulespropertieshttplistener) | object | HTTP listener of the rule. |
| [`priority`](#parameter-requestroutingrulespropertiespriority) | int | Priority of the request routing rule. Must be unique. Value should be between 1 and 20000 |
| [`ruleType`](#parameter-requestroutingrulespropertiesruletype) | string | Rule type. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`backendAddressPool`](#parameter-requestroutingrulespropertiesbackendaddresspool) | object | Backend address pool of the rule. Required when ruleType is Basic and redirectConfiguration is not provided. |
| [`backendHttpSettings`](#parameter-requestroutingrulespropertiesbackendhttpsettings) | object | Backend HTTP settings of the rule. Required when ruleType is Basic and redirectConfiguration is not provided. |
| [`redirectConfiguration`](#parameter-requestroutingrulespropertiesredirectconfiguration) | object | Redirect configuration of the rule. Required when backendAddressPool and backendHttpSettings are not provided. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`loadDistributionPolicy`](#parameter-requestroutingrulespropertiesloaddistributionpolicy) | object | Load Distribution Policy resource of the application gateway. |
| [`rewriteRuleSet`](#parameter-requestroutingrulespropertiesrewriteruleset) | object | Rewrite Rule Set resource in Basic rule of the application gateway. |
| [`urlPathMap`](#parameter-requestroutingrulespropertiesurlpathmap) | object | URL path map resource of the application gateway |

### Parameter: `requestRoutingRules.properties.httpListener`

HTTP listener of the rule.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-requestroutingrulespropertieshttplistenerid) | string | Resource ID of http listener. |

### Parameter: `requestRoutingRules.properties.httpListener.id`

Resource ID of http listener.

- Required: Yes
- Type: string

### Parameter: `requestRoutingRules.properties.priority`

Priority of the request routing rule. Must be unique. Value should be between 1 and 20000

- Required: Yes
- Type: int

### Parameter: `requestRoutingRules.properties.ruleType`

Rule type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Basic'
    'PathBasedRouting'
  ]
  ```

### Parameter: `requestRoutingRules.properties.backendAddressPool`

Backend address pool of the rule. Required when ruleType is Basic and redirectConfiguration is not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-requestroutingrulespropertiesbackendaddresspoolid) | string | Resource ID of backend address pool. |

### Parameter: `requestRoutingRules.properties.backendAddressPool.id`

Resource ID of backend address pool.

- Required: Yes
- Type: string

### Parameter: `requestRoutingRules.properties.backendHttpSettings`

Backend HTTP settings of the rule. Required when ruleType is Basic and redirectConfiguration is not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-requestroutingrulespropertiesbackendhttpsettingsid) | string | Resource ID of backed http settings. |

### Parameter: `requestRoutingRules.properties.backendHttpSettings.id`

Resource ID of backed http settings.

- Required: Yes
- Type: string

### Parameter: `requestRoutingRules.properties.redirectConfiguration`

Redirect configuration of the rule. Required when backendAddressPool and backendHttpSettings are not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-requestroutingrulespropertiesredirectconfigurationid) | string | Resource ID of redirect configuration. |

### Parameter: `requestRoutingRules.properties.redirectConfiguration.id`

Resource ID of redirect configuration.

- Required: Yes
- Type: string

### Parameter: `requestRoutingRules.properties.loadDistributionPolicy`

Load Distribution Policy resource of the application gateway.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-requestroutingrulespropertiesloaddistributionpolicyid) | string | Resource ID of load distribution policy. |

### Parameter: `requestRoutingRules.properties.loadDistributionPolicy.id`

Resource ID of load distribution policy.

- Required: Yes
- Type: string

### Parameter: `requestRoutingRules.properties.rewriteRuleSet`

Rewrite Rule Set resource in Basic rule of the application gateway.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-requestroutingrulespropertiesrewriterulesetid) | string | Resource ID of rewrite ruleset. |

### Parameter: `requestRoutingRules.properties.rewriteRuleSet.id`

Resource ID of rewrite ruleset.

- Required: Yes
- Type: string

### Parameter: `requestRoutingRules.properties.urlPathMap`

URL path map resource of the application gateway

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-requestroutingrulespropertiesurlpathmapid) | string | Resource ID of url path map. |

### Parameter: `requestRoutingRules.properties.urlPathMap.id`

Resource ID of url path map.

- Required: Yes
- Type: string

### Parameter: `requestRoutingRules.id`

Resource ID of request routing rule

- Required: No
- Type: string

### Parameter: `rewriteRuleSets`

Rewrite rules for the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-rewriterulesetsid) | string | Reource ID of the rewrite rule set. |
| [`name`](#parameter-rewriterulesetsname) | string | Name of the rewrite rule set. |
| [`properties`](#parameter-rewriterulesetsproperties) | object | Properties of the rewrite rule set. |

### Parameter: `rewriteRuleSets.id`

Reource ID of the rewrite rule set.

- Required: Yes
- Type: string

### Parameter: `rewriteRuleSets.name`

Name of the rewrite rule set.

- Required: Yes
- Type: string

### Parameter: `rewriteRuleSets.properties`

Properties of the rewrite rule set.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`rewriteRules`](#parameter-rewriterulesetspropertiesrewriterules) | array | Rewrite rules in the rewrite rule set. |

### Parameter: `rewriteRuleSets.properties.rewriteRules`

Rewrite rules in the rewrite rule set.

- Required: Yes
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`actionSet`](#parameter-rewriterulesetspropertiesrewriterulesactionset) | object | Set of actions to be done as part of the rewrite rule. |
| [`name`](#parameter-rewriterulesetspropertiesrewriterulesname) | string | Name of the rewrite rule. |
| [`ruleSequence`](#parameter-rewriterulesetspropertiesrewriterulesrulesequence) | int | Rule sequence. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`conditions`](#parameter-rewriterulesetspropertiesrewriterulesconditions) | array | Conditions based on which the action set execution will be evaluated. |

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet`

Set of actions to be done as part of the rewrite rule.

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`requestHeaderConfigurations`](#parameter-rewriterulesetspropertiesrewriterulesactionsetrequestheaderconfigurations) | array | Request header configuration. |
| [`responseHeaderConfigurations`](#parameter-rewriterulesetspropertiesrewriterulesactionsetresponseheaderconfigurations) | array | Response header configuration. |
| [`urlConfiguration`](#parameter-rewriterulesetspropertiesrewriterulesactionseturlconfiguration) | object | URL configuration. |

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.requestHeaderConfigurations`

Request header configuration.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`headerName`](#parameter-rewriterulesetspropertiesrewriterulesactionsetrequestheaderconfigurationsheadername) | string | Header name. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`headerValue`](#parameter-rewriterulesetspropertiesrewriterulesactionsetrequestheaderconfigurationsheadervalue) | string | Header value. |
| [`headerValueMatcher`](#parameter-rewriterulesetspropertiesrewriterulesactionsetrequestheaderconfigurationsheadervaluematcher) | object | Header value matcher. |

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.requestHeaderConfigurations.headerName`

Header name.

- Required: Yes
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.requestHeaderConfigurations.headerValue`

Header value.

- Required: No
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.requestHeaderConfigurations.headerValueMatcher`

Header value matcher.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`pattern`](#parameter-rewriterulesetspropertiesrewriterulesactionsetrequestheaderconfigurationsheadervaluematcherpattern) | string | Pattern to match. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`ignoreCase`](#parameter-rewriterulesetspropertiesrewriterulesactionsetrequestheaderconfigurationsheadervaluematcherignorecase) | bool | Whether to ignore case when matching. |
| [`negate`](#parameter-rewriterulesetspropertiesrewriterulesactionsetrequestheaderconfigurationsheadervaluematchernegate) | bool | Whether to negate the match. |

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.requestHeaderConfigurations.headerValueMatcher.pattern`

Pattern to match.

- Required: Yes
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.requestHeaderConfigurations.headerValueMatcher.ignoreCase`

Whether to ignore case when matching.

- Required: No
- Type: bool

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.requestHeaderConfigurations.headerValueMatcher.negate`

Whether to negate the match.

- Required: No
- Type: bool

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.responseHeaderConfigurations`

Response header configuration.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`headerName`](#parameter-rewriterulesetspropertiesrewriterulesactionsetresponseheaderconfigurationsheadername) | string | Header name. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`headerValue`](#parameter-rewriterulesetspropertiesrewriterulesactionsetresponseheaderconfigurationsheadervalue) | string | Header value. |
| [`headerValueMatcher`](#parameter-rewriterulesetspropertiesrewriterulesactionsetresponseheaderconfigurationsheadervaluematcher) | object | Header value matcher. |

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.responseHeaderConfigurations.headerName`

Header name.

- Required: Yes
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.responseHeaderConfigurations.headerValue`

Header value.

- Required: No
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.responseHeaderConfigurations.headerValueMatcher`

Header value matcher.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`pattern`](#parameter-rewriterulesetspropertiesrewriterulesactionsetresponseheaderconfigurationsheadervaluematcherpattern) | string | Pattern to match. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`ignoreCase`](#parameter-rewriterulesetspropertiesrewriterulesactionsetresponseheaderconfigurationsheadervaluematcherignorecase) | bool | Whether to ignore case when matching. |
| [`negate`](#parameter-rewriterulesetspropertiesrewriterulesactionsetresponseheaderconfigurationsheadervaluematchernegate) | bool | Whether to negate the match. |

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.responseHeaderConfigurations.headerValueMatcher.pattern`

Pattern to match.

- Required: Yes
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.responseHeaderConfigurations.headerValueMatcher.ignoreCase`

Whether to ignore case when matching.

- Required: No
- Type: bool

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.responseHeaderConfigurations.headerValueMatcher.negate`

Whether to negate the match.

- Required: No
- Type: bool

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.urlConfiguration`

URL configuration.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`modifiedPath`](#parameter-rewriterulesetspropertiesrewriterulesactionseturlconfigurationmodifiedpath) | string | Modified path. |
| [`modifiedQueryString`](#parameter-rewriterulesetspropertiesrewriterulesactionseturlconfigurationmodifiedquerystring) | string | Modified query string. |
| [`reroute`](#parameter-rewriterulesetspropertiesrewriterulesactionseturlconfigurationreroute) | bool | Whether to reroute. |

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.urlConfiguration.modifiedPath`

Modified path.

- Required: No
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.urlConfiguration.modifiedQueryString`

Modified query string.

- Required: No
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.actionSet.urlConfiguration.reroute`

Whether to reroute.

- Required: No
- Type: bool

### Parameter: `rewriteRuleSets.properties.rewriteRules.name`

Name of the rewrite rule.

- Required: Yes
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.ruleSequence`

Rule sequence.

- Required: Yes
- Type: int

### Parameter: `rewriteRuleSets.properties.rewriteRules.conditions`

Conditions based on which the action set execution will be evaluated.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`pattern`](#parameter-rewriterulesetspropertiesrewriterulesconditionspattern) | string | Pattern to match. |
| [`variable`](#parameter-rewriterulesetspropertiesrewriterulesconditionsvariable) | string | Variable to be matched. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`ignoreCase`](#parameter-rewriterulesetspropertiesrewriterulesconditionsignorecase) | bool | Whether to ignore case when evaluating the condition. |
| [`negate`](#parameter-rewriterulesetspropertiesrewriterulesconditionsnegate) | bool | Whether to negate the condition. |

### Parameter: `rewriteRuleSets.properties.rewriteRules.conditions.pattern`

Pattern to match.

- Required: Yes
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.conditions.variable`

Variable to be matched.

- Required: Yes
- Type: string

### Parameter: `rewriteRuleSets.properties.rewriteRules.conditions.ignoreCase`

Whether to ignore case when evaluating the condition.

- Required: No
- Type: bool

### Parameter: `rewriteRuleSets.properties.rewriteRules.conditions.negate`

Whether to negate the condition.

- Required: No
- Type: bool

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-roleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-roleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-roleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-roleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-roleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-roleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-roleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `roleAssignments.principalType`

The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
  ]
  ```

### Parameter: `routingRules`

Routing rules of the application gateway resource.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `sku`

The name of the SKU for the Application Gateway. Defaults to WAF_v2. Compliant usage requires Standard_v2 or WAF_v2

- Required: No
- Type: string
- Default: `'WAF_v2'`
- Allowed:
  ```Bicep
  [
    'Basic'
    'Standard_v2'
    'WAF_v2'
  ]
  ```

### Parameter: `sslCertificates`

SSL certificates of the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-sslcertificatesname) | string | Name of the SSL certificate |
| [`properties`](#parameter-sslcertificatesproperties) | object | Properties of the SSL certificate |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-sslcertificatesid) | string | Resource ID of the SSL certificate |

### Parameter: `sslCertificates.name`

Name of the SSL certificate

- Required: Yes
- Type: string

### Parameter: `sslCertificates.properties`

Properties of the SSL certificate

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`data`](#parameter-sslcertificatespropertiesdata) | string | Base-64 encoded pfx certificate. Only applicable in PUT Request. |
| [`keyVaultSecretId`](#parameter-sslcertificatespropertieskeyvaultsecretid) | string | Secret Id of (base-64 encoded unencrypted pfx) 'Secret' or 'Certificate' object stored in KeyVault. |
| [`password`](#parameter-sslcertificatespropertiespassword) | string | Password for the pfx file specified in data. Only applicable in PUT request. |

### Parameter: `sslCertificates.properties.data`

Base-64 encoded pfx certificate. Only applicable in PUT Request.

- Required: No
- Type: string

### Parameter: `sslCertificates.properties.keyVaultSecretId`

Secret Id of (base-64 encoded unencrypted pfx) 'Secret' or 'Certificate' object stored in KeyVault.

- Required: No
- Type: string

### Parameter: `sslCertificates.properties.password`

Password for the pfx file specified in data. Only applicable in PUT request.

- Required: No
- Type: string

### Parameter: `sslCertificates.id`

Resource ID of the SSL certificate

- Required: No
- Type: string

### Parameter: `sslPolicyCipherSuites`

Ssl cipher suites to be enabled in the specified order to application gateway.

- Required: No
- Type: array
- Default:
  ```Bicep
  [
    'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
    'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
  ]
  ```
- Allowed:
  ```Bicep
  [
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
  ]
  ```

### Parameter: `sslPolicyMinProtocolVersion`

Ssl protocol enums. Compliant usage requires at least TLSv1_2.

- Required: No
- Type: string
- Default: `'TLSv1_2'`
- Allowed:
  ```Bicep
  [
    'TLSv1_0'
    'TLSv1_1'
    'TLSv1_2'
    'TLSv1_3'
  ]
  ```

### Parameter: `sslPolicyName`

Ssl predefined policy name enums. Compliant usage requires (default) AppGwSslPolicy20220101 or AppGwSslPolicy20170401S or AppGwSslPolicy20220101S

- Required: No
- Type: string
- Default: `'AppGwSslPolicy20220101'`
- Allowed:
  ```Bicep
  [
    ''
    'AppGwSslPolicy20150501'
    'AppGwSslPolicy20170401'
    'AppGwSslPolicy20170401S'
    'AppGwSslPolicy20220101'
    'AppGwSslPolicy20220101S'
  ]
  ```

### Parameter: `sslPolicyType`

Type of Ssl Policy. Compliant usage requires (default) Predefined

- Required: No
- Type: string
- Default: `'Predefined'`
- Allowed:
  ```Bicep
  [
    'Custom'
    'CustomV2'
    'Predefined'
  ]
  ```

### Parameter: `sslProfiles`

SSL profiles of the application gateway resource.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `tags`

Resource tags.

- Required: No
- Type: object

### Parameter: `trustedClientCertificates`

Trusted client certificates of the application gateway resource.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `trustedRootCertificates`

Trusted Root certificates of the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-trustedrootcertificatesname) | string | Name of the SSL certificate |
| [`properties`](#parameter-trustedrootcertificatesproperties) | object | Properties of the SSL certificate |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-trustedrootcertificatesid) | string | Resource ID of the SSL certificate |

### Parameter: `trustedRootCertificates.name`

Name of the SSL certificate

- Required: Yes
- Type: string

### Parameter: `trustedRootCertificates.properties`

Properties of the SSL certificate

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`data`](#parameter-trustedrootcertificatespropertiesdata) | string | Base-64 encoded pfx certificate. Only applicable in PUT Request. |
| [`keyVaultSecretId`](#parameter-trustedrootcertificatespropertieskeyvaultsecretid) | string | Secret Id of (base-64 encoded unencrypted pfx) 'Secret' or 'Certificate' object stored in KeyVault. |

### Parameter: `trustedRootCertificates.properties.data`

Base-64 encoded pfx certificate. Only applicable in PUT Request.

- Required: No
- Type: string

### Parameter: `trustedRootCertificates.properties.keyVaultSecretId`

Secret Id of (base-64 encoded unencrypted pfx) 'Secret' or 'Certificate' object stored in KeyVault.

- Required: No
- Type: string

### Parameter: `trustedRootCertificates.id`

Resource ID of the SSL certificate

- Required: No
- Type: string

### Parameter: `urlPathMaps`

URL path map of the application gateway resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapsid) | string | Resource ID of the URL path map. |
| [`name`](#parameter-urlpathmapsname) | string | Name of the URL path map. |
| [`properties`](#parameter-urlpathmapsproperties) | object | Properties of the URL path map. |

### Parameter: `urlPathMaps.id`

Resource ID of the URL path map.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.name`

Name of the URL path map.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties`

Properties of the URL path map.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`pathRules`](#parameter-urlpathmapspropertiespathrules) | array | Array of path rules. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`defaultBackendAddressPool`](#parameter-urlpathmapspropertiesdefaultbackendaddresspool) | object | Default backend address pool. Required when defaultRedirectConfiguration is not provided. |
| [`defaultBackendHttpSettings`](#parameter-urlpathmapspropertiesdefaultbackendhttpsettings) | object | Default backend HTTP settings. Required when defaultRedirectConfiguration is not provided. |
| [`defaultRedirectConfiguration`](#parameter-urlpathmapspropertiesdefaultredirectconfiguration) | object | Default redirect configuration. Required when defaultBackendAddressPool and defaultBackendHttpSettings are not provided. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`defaultLoadDistributionPolicy`](#parameter-urlpathmapspropertiesdefaultloaddistributionpolicy) | object | Default load distribution policy. |
| [`defaultRewriteRuleSet`](#parameter-urlpathmapspropertiesdefaultrewriteruleset) | object | Default rewrite rule set. |

### Parameter: `urlPathMaps.properties.pathRules`

Array of path rules.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-urlpathmapspropertiespathrulesname) | string | Name of the path rule. |
| [`properties`](#parameter-urlpathmapspropertiespathrulesproperties) | object | Properties of the path rule. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiespathrulesid) | string | Resource ID of the path rule. |

### Parameter: `urlPathMaps.properties.pathRules.name`

Name of the path rule.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.pathRules.properties`

Properties of the path rule.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`paths`](#parameter-urlpathmapspropertiespathrulespropertiespaths) | array | Array of URL paths for the rule. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`backendAddressPool`](#parameter-urlpathmapspropertiespathrulespropertiesbackendaddresspool) | object | Backend address pool for the path rule. Required when redirectConfiguration is not provided. |
| [`backendHttpSettings`](#parameter-urlpathmapspropertiespathrulespropertiesbackendhttpsettings) | object | Backend HTTP settings for the path rule. Required when redirectConfiguration is not provided. |
| [`redirectConfiguration`](#parameter-urlpathmapspropertiespathrulespropertiesredirectconfiguration) | object | Redirect configuration for the path rule. Required when backendAddressPool and backendHttpSettings are not provided. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`firewallPolicy`](#parameter-urlpathmapspropertiespathrulespropertiesfirewallpolicy) | object | Firewall policy for the path rule. |
| [`loadDistributionPolicy`](#parameter-urlpathmapspropertiespathrulespropertiesloaddistributionpolicy) | object | Load distribution policy for the path rule. |
| [`rewriteRuleSet`](#parameter-urlpathmapspropertiespathrulespropertiesrewriteruleset) | object | Rewrite rule set for the path rule. |

### Parameter: `urlPathMaps.properties.pathRules.properties.paths`

Array of URL paths for the rule.

- Required: Yes
- Type: array

### Parameter: `urlPathMaps.properties.pathRules.properties.backendAddressPool`

Backend address pool for the path rule. Required when redirectConfiguration is not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiespathrulespropertiesbackendaddresspoolid) | string | Resource ID of the backend address pool. |

### Parameter: `urlPathMaps.properties.pathRules.properties.backendAddressPool.id`

Resource ID of the backend address pool.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.pathRules.properties.backendHttpSettings`

Backend HTTP settings for the path rule. Required when redirectConfiguration is not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiespathrulespropertiesbackendhttpsettingsid) | string | Resource ID of the backend HTTP settings. |

### Parameter: `urlPathMaps.properties.pathRules.properties.backendHttpSettings.id`

Resource ID of the backend HTTP settings.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.pathRules.properties.redirectConfiguration`

Redirect configuration for the path rule. Required when backendAddressPool and backendHttpSettings are not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiespathrulespropertiesredirectconfigurationid) | string | Resource ID of the redirect configuration. |

### Parameter: `urlPathMaps.properties.pathRules.properties.redirectConfiguration.id`

Resource ID of the redirect configuration.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.pathRules.properties.firewallPolicy`

Firewall policy for the path rule.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiespathrulespropertiesfirewallpolicyid) | string | Resource ID of the firewall policy. |

### Parameter: `urlPathMaps.properties.pathRules.properties.firewallPolicy.id`

Resource ID of the firewall policy.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.pathRules.properties.loadDistributionPolicy`

Load distribution policy for the path rule.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiespathrulespropertiesloaddistributionpolicyid) | string | Resource ID of the load distribution policy. |

### Parameter: `urlPathMaps.properties.pathRules.properties.loadDistributionPolicy.id`

Resource ID of the load distribution policy.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.pathRules.properties.rewriteRuleSet`

Rewrite rule set for the path rule.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiespathrulespropertiesrewriterulesetid) | string | Resource ID of the rewrite rule set. |

### Parameter: `urlPathMaps.properties.pathRules.properties.rewriteRuleSet.id`

Resource ID of the rewrite rule set.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.pathRules.id`

Resource ID of the path rule.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.defaultBackendAddressPool`

Default backend address pool. Required when defaultRedirectConfiguration is not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiesdefaultbackendaddresspoolid) | string | Resource ID of the backend address pool. |

### Parameter: `urlPathMaps.properties.defaultBackendAddressPool.id`

Resource ID of the backend address pool.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.defaultBackendHttpSettings`

Default backend HTTP settings. Required when defaultRedirectConfiguration is not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiesdefaultbackendhttpsettingsid) | string | Resource ID of the backend HTTP settings. |

### Parameter: `urlPathMaps.properties.defaultBackendHttpSettings.id`

Resource ID of the backend HTTP settings.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.defaultRedirectConfiguration`

Default redirect configuration. Required when defaultBackendAddressPool and defaultBackendHttpSettings are not provided.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiesdefaultredirectconfigurationid) | string | Resource ID of the redirect configuration. |

### Parameter: `urlPathMaps.properties.defaultRedirectConfiguration.id`

Resource ID of the redirect configuration.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.defaultLoadDistributionPolicy`

Default load distribution policy.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiesdefaultloaddistributionpolicyid) | string | Resource ID of the load distribution policy. |

### Parameter: `urlPathMaps.properties.defaultLoadDistributionPolicy.id`

Resource ID of the load distribution policy.

- Required: Yes
- Type: string

### Parameter: `urlPathMaps.properties.defaultRewriteRuleSet`

Default rewrite rule set.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-urlpathmapspropertiesdefaultrewriterulesetid) | string | Resource ID of the rewrite rule set. |

### Parameter: `urlPathMaps.properties.defaultRewriteRuleSet.id`

Resource ID of the rewrite rule set.

- Required: Yes
- Type: string

### Parameter: `webApplicationFirewallConfiguration`

Application gateway web application firewall configuration. This will override the compliant by default WAF policy.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-webapplicationfirewallconfigurationenabled) | bool | Web Application Firewall configuration enabled. |
| [`firewallMode`](#parameter-webapplicationfirewallconfigurationfirewallmode) | string | Web Application Firewall mode. |
| [`ruleSetType`](#parameter-webapplicationfirewallconfigurationrulesettype) | string | Web Application Firewall rule set type. |
| [`ruleSetVersion`](#parameter-webapplicationfirewallconfigurationrulesetversion) | string | Web Application Firewall rule set version. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`disabledRuleGroups`](#parameter-webapplicationfirewallconfigurationdisabledrulegroups) | array | Disabled rule groups. |
| [`exclusions`](#parameter-webapplicationfirewallconfigurationexclusions) | array | WAF exclusions. |
| [`fileUploadLimitInMb`](#parameter-webapplicationfirewallconfigurationfileuploadlimitinmb) | int | File upload limit in Mb for WAF. Min 0 |
| [`maxRequestBodySize`](#parameter-webapplicationfirewallconfigurationmaxrequestbodysize) | int | Maximum request body size. Min 8, Max 128 |
| [`maxRequestBodySizeInKb`](#parameter-webapplicationfirewallconfigurationmaxrequestbodysizeinkb) | int | Maximum request body size in Kb for WAF. Min 8, Max 128 |
| [`requestBodyCheck`](#parameter-webapplicationfirewallconfigurationrequestbodycheck) | bool | Request body check. |

### Parameter: `webApplicationFirewallConfiguration.enabled`

Web Application Firewall configuration enabled.

- Required: Yes
- Type: bool

### Parameter: `webApplicationFirewallConfiguration.firewallMode`

Web Application Firewall mode.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Detection'
    'Prevention'
  ]
  ```

### Parameter: `webApplicationFirewallConfiguration.ruleSetType`

Web Application Firewall rule set type.

- Required: Yes
- Type: string

### Parameter: `webApplicationFirewallConfiguration.ruleSetVersion`

Web Application Firewall rule set version.

- Required: Yes
- Type: string

### Parameter: `webApplicationFirewallConfiguration.disabledRuleGroups`

Disabled rule groups.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`ruleGroupName`](#parameter-webapplicationfirewallconfigurationdisabledrulegroupsrulegroupname) | string | Rule group name. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`rules`](#parameter-webapplicationfirewallconfigurationdisabledrulegroupsrules) | array | List of rule IDs within the rule group to disable. |

### Parameter: `webApplicationFirewallConfiguration.disabledRuleGroups.ruleGroupName`

Rule group name.

- Required: Yes
- Type: string

### Parameter: `webApplicationFirewallConfiguration.disabledRuleGroups.rules`

List of rule IDs within the rule group to disable.

- Required: No
- Type: array

### Parameter: `webApplicationFirewallConfiguration.exclusions`

WAF exclusions.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`matchVariable`](#parameter-webapplicationfirewallconfigurationexclusionsmatchvariable) | string | Match variable for the exclusion rule. |
| [`selectorMatchOperator`](#parameter-webapplicationfirewallconfigurationexclusionsselectormatchoperator) | string | Selector match operator. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`selector`](#parameter-webapplicationfirewallconfigurationexclusionsselector) | string | Selector for the exclusion rule. |

### Parameter: `webApplicationFirewallConfiguration.exclusions.matchVariable`

Match variable for the exclusion rule.

- Required: Yes
- Type: string

### Parameter: `webApplicationFirewallConfiguration.exclusions.selectorMatchOperator`

Selector match operator.

- Required: Yes
- Type: string

### Parameter: `webApplicationFirewallConfiguration.exclusions.selector`

Selector for the exclusion rule.

- Required: No
- Type: string

### Parameter: `webApplicationFirewallConfiguration.fileUploadLimitInMb`

File upload limit in Mb for WAF. Min 0

- Required: No
- Type: int

### Parameter: `webApplicationFirewallConfiguration.maxRequestBodySize`

Maximum request body size. Min 8, Max 128

- Required: No
- Type: int

### Parameter: `webApplicationFirewallConfiguration.maxRequestBodySizeInKb`

Maximum request body size in Kb for WAF. Min 8, Max 128

- Required: No
- Type: int

### Parameter: `webApplicationFirewallConfiguration.requestBodyCheck`

Request body check.

- Required: No
- Type: bool

### Parameter: `zones`

Zones for the resource. For example: [1, 2, 3]. Default: []

- Required: No
- Type: array
- Default: `[]`

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the application gateway. |
| `privateEndpoints` | array | The private endpoints of the application gateway. |
| `resourceGroupName` | string | The resource group the application gateway was deployed into. |
| `resourceId` | string | The resource ID of the application gateway. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/amavm:res/network/application-gateway-web-application-firewall-policy:0.1.0` | Remote reference |
| `br/amavm:res/network/private-endpoint:0.2.0` | Remote reference |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
