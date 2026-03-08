# Application Gateway Web Application Firewall (WAF) Policies `[Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies]`

This module deploys an Application Gateway Web Application Firewall (WAF) Policy.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 20250506

Compliant usage of this module requires the following parameter values:
- mode: Detection || Prevention
- state: 'Enabled'
- customRules ruleType == RateLimitRules
- rulesetType Microsoft_DefaultRuleSet v2.1


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies` | 2024-03-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_applicationgatewaywebapplicationfirewallpolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-03-01/ApplicationGatewayWebApplicationFirewallPolicies)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/network/application-gateway-web-application-firewall-policy:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [Using large parameter set](#example-2-using-large-parameter-set)
- [WAF-aligned](#example-3-waf-aligned)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module applicationGatewayWebApplicationFirewallPolicyMod 'br/<registry-alias>:res/network/application-gateway-web-application-firewall-policy:<version>' = {
  name: 'applicationGatewayWebApplicationFirewallPolicy-mod'
  params: {
    // Required parameters
    name: 'nagwafpmin001'
    // Non-required parameters
    location: '<location>'
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
      ]
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/network/application-gateway-web-application-firewall-policy:<version>'

// Required parameters
param name = 'nagwafpmin001'
// Non-required parameters
param location = '<location>'
param managedRules = {
  managedRuleSets: [
    {
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
  ]
}
```

</details>
<p>

### Example 2: _Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module applicationGatewayWebApplicationFirewallPolicyMod 'br/<registry-alias>:res/network/application-gateway-web-application-firewall-policy:<version>' = {
  name: 'applicationGatewayWebApplicationFirewallPolicy-mod'
  params: {
    // Required parameters
    name: 'nagwafpmax001'
    // Non-required parameters
    location: '<location>'
    managedRules: {
      managedRuleSets: [
        {
          ruleGroupOverrides: []
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
        {
          ruleGroupOverrides: []
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '0.1'
        }
      ]
    }
    policySettings: {
      customBlockResponseBody: 'PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=='
      customBlockResponseStatusCode: 403
      fileUploadLimitInMb: 10
      jsChallengeCookieExpirationInMins: 60
      mode: 'Prevention'
      state: 'Enabled'
    }
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
using 'br/public:res/network/application-gateway-web-application-firewall-policy:<version>'

// Required parameters
param name = 'nagwafpmax001'
// Non-required parameters
param location = '<location>'
param managedRules = {
  managedRuleSets: [
    {
      ruleGroupOverrides: []
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
    {
      ruleGroupOverrides: []
      ruleSetType: 'Microsoft_BotManagerRuleSet'
      ruleSetVersion: '0.1'
    }
  ]
}
param policySettings = {
  customBlockResponseBody: 'PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=='
  customBlockResponseStatusCode: 403
  fileUploadLimitInMb: 10
  jsChallengeCookieExpirationInMins: 60
  mode: 'Prevention'
  state: 'Enabled'
}
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

### Example 3: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module applicationGatewayWebApplicationFirewallPolicyMod 'br/<registry-alias>:res/network/application-gateway-web-application-firewall-policy:<version>' = {
  name: 'applicationGatewayWebApplicationFirewallPolicy-mod'
  params: {
    // Required parameters
    name: 'nagwafpwaf001'
    // Non-required parameters
    location: '<location>'
    managedRules: {
      managedRuleSets: [
        {
          ruleGroupOverrides: []
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '0.1'
        }
      ]
    }
    policySettings: {
      fileUploadLimitInMb: 10
      jsChallengeCookieExpirationInMins: 60
      mode: 'Prevention'
      state: 'Enabled'
    }
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
using 'br/public:res/network/application-gateway-web-application-firewall-policy:<version>'

// Required parameters
param name = 'nagwafpwaf001'
// Non-required parameters
param location = '<location>'
param managedRules = {
  managedRuleSets: [
    {
      ruleGroupOverrides: []
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
    {
      ruleSetType: 'Microsoft_BotManagerRuleSet'
      ruleSetVersion: '0.1'
    }
  ]
}
param policySettings = {
  fileUploadLimitInMb: 10
  jsChallengeCookieExpirationInMins: 60
  mode: 'Prevention'
  state: 'Enabled'
}
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
| [`managedRules`](#parameter-managedrules) | object | Describes the managedRules structure. Default compliant values:<p>```<p>{<p>  managedRuleSets: [<p>    {<p>      ruleSetType: 'Microsoft_DefaultRuleSet'<p>      ruleSetVersion: '2.1'<p>    }<p>  ]<p>  exclusions: []<p>}<p>```<p> |
| [`name`](#parameter-name) | string | Name of the Application Gateway WAF policy. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`customRules`](#parameter-customrules) | array | The custom rules inside the policy. Once a rule is matched, the corresponding action defined in the rule is applied to the request. Default empty, compliant usage allows only RateLimitRule. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`policySettings`](#parameter-policysettings) | object | The PolicySettings for policy. Default compliant values:<p>```<p>{<p>mode: 'Detection'<p>state: 'Enabled'<p>maxRequestBodySizeinKb: 128<p>requestBodyEnforcement: true<p>fileUploadLimitinMb: 100<p>}<p>```<p> |
| [`tags`](#parameter-tags) | object | Resource tags. |

### Parameter: `managedRules`

Describes the managedRules structure. Default compliant values:<p>```<p>{<p>  managedRuleSets: [<p>    {<p>      ruleSetType: 'Microsoft_DefaultRuleSet'<p>      ruleSetVersion: '2.1'<p>    }<p>  ]<p>  exclusions: []<p>}<p>```<p>

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      exclusions: []
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
        }
      ]
  }
  ```

### Parameter: `name`

Name of the Application Gateway WAF policy.

- Required: Yes
- Type: string

### Parameter: `customRules`

The custom rules inside the policy. Once a rule is matched, the corresponding action defined in the rule is applied to the request. Default empty, compliant usage allows only RateLimitRule.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `location`

Location for all resources.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `policySettings`

The PolicySettings for policy. Default compliant values:<p>```<p>{<p>mode: 'Detection'<p>state: 'Enabled'<p>maxRequestBodySizeinKb: 128<p>requestBodyEnforcement: true<p>fileUploadLimitinMb: 100<p>}<p>```<p>

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      fileUploadLimitinMb: 100
      maxRequestBodySizeinKb: 128
      mode: 'Detection'
      requestBodyEnforcement: true
      state: 'Enabled'
  }
  ```

### Parameter: `tags`

Resource tags.

- Required: No
- Type: object

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the application gateway WAF policy. |
| `resourceGroupName` | string | The resource group the application gateway WAF policy was deployed into. |
| `resourceId` | string | The resource ID of the application gateway WAF policy. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
