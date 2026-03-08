metadata name = 'Application Gateway Web Application Firewall (WAF) Policies'
metadata description = 'This module deploys an Application Gateway Web Application Firewall (WAF) Policy.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of this module requires the following parameter values:
- mode: Detection || Prevention
- state: 'Enabled'
- customRules ruleType == RateLimitRules
- rulesetType Microsoft_DefaultRuleSet v2.1
'''
metadata complianceVersion = '20250506'
@description('Required. Name of the Application Gateway WAF policy.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Resource tags.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('''Required. Describes the managedRules structure. Default compliant values:
```
{
  managedRuleSets: [
    {
      ruleSetType: 'Microsoft_DefaultRuleSet'
      ruleSetVersion: '2.1'
    }
  ]
  exclusions: []
}
```
''')
param managedRules object = {
  managedRuleSets: [
    {
      ruleSetType: 'Microsoft_DefaultRuleSet'
      ruleSetVersion: '2.1'
    }
  ]
  exclusions: []
}

@description('Optional. The custom rules inside the policy. Once a rule is matched, the corresponding action defined in the rule is applied to the request. Default empty, compliant usage allows only RateLimitRule.')
param customRules array = []

@description('''Optional. The PolicySettings for policy. Default compliant values:
  ```
  {
  mode: 'Detection'
  state: 'Enabled'
  maxRequestBodySizeinKb: 128
  requestBodyEnforcement: true
  fileUploadLimitinMb: 100
  }
  ```
''')
param policySettings object = {
  mode: 'Detection'
  state: 'Enabled'
  maxRequestBodySizeinKb: 128
  requestBodyEnforcement: true
  fileUploadLimitinMb: 100
}

// Variables
import {telemetryId} from '../../../../bicep-shared/environments.bicep'

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version

var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: take('${telemetryId}.res.network-appgwwebappfirewallpolicy.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}', 64)
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

resource applicationGatewayWAFPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2024-03-01' = {
  name: name
  location: location
  tags: finalTags
  properties: {
    managedRules: managedRules ?? {}
    customRules: customRules
    policySettings: policySettings
  }
}

@description('The name of the application gateway WAF policy.')
output name string = applicationGatewayWAFPolicy.name

@description('The resource ID of the application gateway WAF policy.')
output resourceId string = applicationGatewayWAFPolicy.id

@description('The resource group the application gateway WAF policy was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = applicationGatewayWAFPolicy.location

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false
