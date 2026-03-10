@description('The name of the WAF policy.')
param name string

@description('The location of the WAF policy. Defaults to the location of the resource group.')
param location string = resourceGroup().location

@allowed([
  'Detection'
  'Prevention'
])
param wafMode string = 'Detection'

@description('WAF rule set type.')
@allowed([
  'OWASP'
])
param wafRuleSetType string = 'OWASP'

@description('WAF rule set version.')
@allowed([
  '3.2'
  '3.1'
  '3.0'
])
param wafRuleSetVersion string = '3.2'

@allowed([
  'Enabled'
  'Disabled'
])
param wafState string = 'Enabled'

@description('List of custom rules. Once a rule is matched, the corresponding action defined in the rule is applied to the request.')
param customRules array = []

@description('If the request body inspection is turned off, WAF does not evaluate the content of HTTP message body.')
param requestBodyCheck bool = true

@description('The maximum request body size controls the overall request size limit excluding any file uploads.')
param maxBodySize int = 128

@description('Maximum file upload size.')
param maxFileUpload int = 100

param ruleGroupOverride array = []

param exclusions array = []

param tags object = {}

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    customRules: customRules
    policySettings: {
      mode: wafMode
      state: wafState
      maxRequestBodySizeInKb: maxBodySize
      requestBodyEnforcement: requestBodyCheck
      fileUploadLimitInMb: maxFileUpload
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
        }
        // {
        //   ruleSetType: wafRuleSetType
        //   ruleSetVersion: wafRuleSetVersion
        //   ruleGroupOverrides: ruleGroupOverride
        // }
      ]
      exclusions: exclusions
    }
  }
}

output id string = wafPolicy.id

output name string = wafPolicy.name
