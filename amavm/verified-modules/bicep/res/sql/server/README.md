# Azure SQL Server `[Microsoft.Sql/servers]`

This module deploys an Azure SQL Server.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Cross-referenced modules](#cross-referenced-modules)
- [Notes](#notes)
- [Data Collection](#data-collection)

## Compliance

Version: 20240726

Compliant usage of Azure SQL Server requires:
- publicNetworkAccess: 'Disabled'
- restrictOutboundNetworkAccess: 'Enabled'
- minimalTlsVersion: 1.2 and higher
- administrators.azureADOnlyAuthentication: not false
- securityAlertPolicies.state: 'Enabled'
- vulnerabilityAssessmentsClassic or vulnerabilityAssessmentsExpress are configured


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.Network/privateEndpoints` | 2024-01-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-01-01/privateEndpoints)</li></ul> |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/privateEndpoints/privateDnsZoneGroups)</li></ul> |
| `Microsoft.Sql/servers` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers)</li></ul> |
| `Microsoft.Sql/servers/advancedThreatProtectionSettings` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_advancedthreatprotectionsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/advancedThreatProtectionSettings)</li></ul> |
| `Microsoft.Sql/servers/auditingSettings` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_auditingsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/auditingSettings)</li></ul> |
| `Microsoft.Sql/servers/databases` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_databases.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/databases)</li></ul> |
| `Microsoft.Sql/servers/databases` | 2023-08-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_databases.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-08-01-preview/servers/databases)</li></ul> |
| `Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_databases_backuplongtermretentionpolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/databases/backupLongTermRetentionPolicies)</li></ul> |
| `Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_databases_backupshorttermretentionpolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/databases/backupShortTermRetentionPolicies)</li></ul> |
| `Microsoft.Sql/servers/elasticPools` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_elasticpools.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/elasticPools)</li></ul> |
| `Microsoft.Sql/servers/encryptionProtector` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_encryptionprotector.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/encryptionProtector)</li></ul> |
| `Microsoft.Sql/servers/firewallRules` | 2023-08-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_firewallrules.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-08-01-preview/servers/firewallRules)</li></ul> |
| `Microsoft.Sql/servers/keys` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_keys.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/keys)</li></ul> |
| `Microsoft.Sql/servers/outboundFirewallRules` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_outboundfirewallrules.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/outboundFirewallRules)</li></ul> |
| `Microsoft.Sql/servers/securityAlertPolicies` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_securityalertpolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/securityAlertPolicies)</li></ul> |
| `Microsoft.Sql/servers/sqlVulnerabilityAssessments` | 2023-08-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_sqlvulnerabilityassessments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-08-01-preview/servers/sqlVulnerabilityAssessments)</li></ul> |
| `Microsoft.Sql/servers/virtualNetworkRules` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_virtualnetworkrules.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/virtualNetworkRules)</li></ul> |
| `Microsoft.Sql/servers/vulnerabilityAssessments` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_vulnerabilityassessments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/vulnerabilityAssessments)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/sql/server:<version>`.

- [With an administrator](#example-1-with-an-administrator)
- [With audit settings](#example-2-with-audit-settings)
- [Using only defaults](#example-3-using-only-defaults)
- [Using large parameter set](#example-4-using-large-parameter-set)
- [With a secondary database](#example-5-with-a-secondary-database)
- [With vulnerability assessment](#example-6-with-vulnerability-assessment)
- [WAF-aligned](#example-7-waf-aligned)

### Example 1: _With an administrator_

This instance deploys the module with a Microsoft Entra ID identity as SQL administrator.


<details>

<summary>via Bicep module</summary>

```bicep
module serverMod 'br/<registry-alias>:res/sql/server:<version>' = {
  name: 'server-mod'
  params: {
    // Required parameters
    name: 'sqlsadmin'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    administrators: {
      azureADOnlyAuthentication: true
      login: 'myspn'
      principalType: 'Application'
      sid: '<sid>'
    }
    location: '<location>'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/sql/server:<version>'

// Required parameters
param name = 'sqlsadmin'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param administrators = {
  azureADOnlyAuthentication: true
  login: 'myspn'
  principalType: 'Application'
  sid: '<sid>'
}
param location = '<location>'
```

</details>
<p>

### Example 2: _With audit settings_

This instance deploys the module with auditing settings.


<details>

<summary>via Bicep module</summary>

```bicep
module serverMod 'br/<registry-alias>:res/sql/server:<version>' = {
  name: 'server-mod'
  params: {
    // Required parameters
    name: 'audsqlsrv001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    administratorLogin: 'adminUserName'
    administratorLoginPassword: '<administratorLoginPassword>'
    auditSettings: {
      isManagedIdentityInUse: true
      state: 'Enabled'
      storageAccountResourceId: '<storageAccountResourceId>'
    }
    location: '<location>'
    managedIdentities: {
      systemAssigned: true
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/sql/server:<version>'

// Required parameters
param name = 'audsqlsrv001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param administratorLogin = 'adminUserName'
param administratorLoginPassword = '<administratorLoginPassword>'
param auditSettings = {
  isManagedIdentityInUse: true
  state: 'Enabled'
  storageAccountResourceId: '<storageAccountResourceId>'
}
param location = '<location>'
param managedIdentities = {
  systemAssigned: true
}
```

</details>
<p>

### Example 3: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module serverMod 'br/<registry-alias>:res/sql/server:<version>' = {
  name: 'server-mod'
  params: {
    // Required parameters
    name: 'ssmin001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    administratorLogin: 'adminUserName'
    administratorLoginPassword: '<administratorLoginPassword>'
    location: '<location>'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/sql/server:<version>'

// Required parameters
param name = 'ssmin001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param administratorLogin = 'adminUserName'
param administratorLoginPassword = '<administratorLoginPassword>'
param location = '<location>'
```

</details>
<p>

### Example 4: _Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module serverMod 'br/<registry-alias>:res/sql/server:<version>' = {
  name: 'server-mod'
  params: {
    // Required parameters
    name: 'sqlsmax'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    administratorLogin: 'adminUserName'
    administratorLoginPassword: '<administratorLoginPassword>'
    databases: [
      {
        backupLongTermRetentionPolicy: {
          monthlyRetention: 'P6M'
        }
        backupShortTermRetentionPolicy: {
          retentionDays: 14
        }
        capacity: 0
        collation: 'SQL_Latin1_General_CP1_CI_AS'
        diagnosticSettings: [
          {
            eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
            eventHubName: '<eventHubName>'
            name: 'customSetting'
            storageAccountResourceId: '<storageAccountResourceId>'
            workspaceResourceId: '<workspaceResourceId>'
          }
        ]
        elasticPoolId: '<elasticPoolId>'
        encryptionProtectorObj: {
          serverKeyName: '<serverKeyName>'
          serverKeyType: 'AzureKeyVault'
        }
        licenseType: 'LicenseIncluded'
        maxSizeBytes: 34359738368
        name: 'sqlsmaxdb-001'
        skuName: 'ElasticPool'
        skuTier: 'GeneralPurpose'
      }
    ]
    elasticPools: [
      {
        licenseType: 'LicenseIncluded'
        maintenanceConfigurationId: '<maintenanceConfigurationId>'
        name: 'sqlsmax-ep-001'
        skuCapacity: 10
        skuName: 'GP_Gen5'
        skuTier: 'GeneralPurpose'
      }
    ]
    firewallRules: [
      {
        endIpAddress: '0.0.0.0'
        name: 'AllowAllWindowsAzureIps'
        startIpAddress: '0.0.0.0'
      }
    ]
    keys: [
      {
        name: '<name>'
        serverKeyType: 'AzureKeyVault'
        uri: '<uri>'
      }
    ]
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    primaryUserAssignedIdentityId: '<primaryUserAssignedIdentityId>'
    restrictOutboundNetworkAccess: 'Disabled'
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
    securityAlertPolicy: {
      emailAccountAdmins: true
      state: 'Enabled'
    }
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    virtualNetworkRules: [
      {
        ignoreMissingVnetServiceEndpoint: true
        name: 'newVnetRule1'
        virtualNetworkSubnetId: '<virtualNetworkSubnetId>'
      }
    ]
    vulnerabilityAssessmentsClassic: {
      recurringScansEmails: [
        'test1@contoso.com'
        'test2@contoso.com'
      ]
      recurringScansEmailSubscriptionAdmins: true
      recurringScansIsEnabled: true
      storageAccountResourceId: '<storageAccountResourceId>'
    }
    vulnerabilityAssessmentsExpress: {
      state: 'Enabled'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/sql/server:<version>'

// Required parameters
param name = 'sqlsmax'
param privateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param administratorLogin = 'adminUserName'
param administratorLoginPassword = '<administratorLoginPassword>'
param databases = [
  {
    backupLongTermRetentionPolicy: {
      monthlyRetention: 'P6M'
    }
    backupShortTermRetentionPolicy: {
      retentionDays: 14
    }
    capacity: 0
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    elasticPoolId: '<elasticPoolId>'
    encryptionProtectorObj: {
      serverKeyName: '<serverKeyName>'
      serverKeyType: 'AzureKeyVault'
    }
    licenseType: 'LicenseIncluded'
    maxSizeBytes: 34359738368
    name: 'sqlsmaxdb-001'
    skuName: 'ElasticPool'
    skuTier: 'GeneralPurpose'
  }
]
param elasticPools = [
  {
    licenseType: 'LicenseIncluded'
    maintenanceConfigurationId: '<maintenanceConfigurationId>'
    name: 'sqlsmax-ep-001'
    skuCapacity: 10
    skuName: 'GP_Gen5'
    skuTier: 'GeneralPurpose'
  }
]
param firewallRules = [
  {
    endIpAddress: '0.0.0.0'
    name: 'AllowAllWindowsAzureIps'
    startIpAddress: '0.0.0.0'
  }
]
param keys = [
  {
    name: '<name>'
    serverKeyType: 'AzureKeyVault'
    uri: '<uri>'
  }
]
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedIdentities = {
  systemAssigned: true
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param primaryUserAssignedIdentityId = '<primaryUserAssignedIdentityId>'
param restrictOutboundNetworkAccess = 'Disabled'
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
param securityAlertPolicy = {
  emailAccountAdmins: true
  state: 'Enabled'
}
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
param virtualNetworkRules = [
  {
    ignoreMissingVnetServiceEndpoint: true
    name: 'newVnetRule1'
    virtualNetworkSubnetId: '<virtualNetworkSubnetId>'
  }
]
param vulnerabilityAssessmentsClassic = {
  recurringScansEmails: [
    'test1@contoso.com'
    'test2@contoso.com'
  ]
  recurringScansEmailSubscriptionAdmins: true
  recurringScansIsEnabled: true
  storageAccountResourceId: '<storageAccountResourceId>'
}
param vulnerabilityAssessmentsExpress = {
  state: 'Enabled'
}
```

</details>
<p>

### Example 5: _With a secondary database_

This instance deploys the module with a secondary database.


<details>

<summary>via Bicep module</summary>

```bicep
module serverMod 'br/<registry-alias>:res/sql/server:<version>' = {
  name: 'server-mod'
  params: {
    // Required parameters
    name: 'sqlsec-sec'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    administratorLogin: 'adminUserName'
    administratorLoginPassword: '<administratorLoginPassword>'
    databases: [
      {
        createMode: 'Secondary'
        maxSizeBytes: 2147483648
        name: '<name>'
        skuName: 'Basic'
        skuTier: 'Basic'
        sourceDatabaseResourceId: '<sourceDatabaseResourceId>'
      }
    ]
    location: '<location>'
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
using 'br/public:res/sql/server:<version>'

// Required parameters
param name = 'sqlsec-sec'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param administratorLogin = 'adminUserName'
param administratorLoginPassword = '<administratorLoginPassword>'
param databases = [
  {
    createMode: 'Secondary'
    maxSizeBytes: 2147483648
    name: '<name>'
    skuName: 'Basic'
    skuTier: 'Basic'
    sourceDatabaseResourceId: '<sourceDatabaseResourceId>'
  }
]
param location = '<location>'
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

### Example 6: _With vulnerability assessment_

This instance deploys the module with a vulnerability assessment.


<details>

<summary>via Bicep module</summary>

```bicep
module serverMod 'br/<registry-alias>:res/sql/server:<version>' = {
  name: 'server-mod'
  params: {
    // Required parameters
    name: 'sqlsvln'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    administratorLogin: 'adminUserName'
    administratorLoginPassword: '<administratorLoginPassword>'
    location: '<location>'
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    primaryUserAssignedIdentityId: '<primaryUserAssignedIdentityId>'
    securityAlertPolicy: {
      emailAccountAdmins: true
      state: 'Enabled'
    }
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    vulnerabilityAssessmentsClassic: {
      recurringScansEmails: [
        'test1@contoso.com'
        'test2@contoso.com'
      ]
      recurringScansEmailSubscriptionAdmins: true
      recurringScansIsEnabled: true
      storageAccountResourceId: '<storageAccountResourceId>'
    }
    vulnerabilityAssessmentsExpress: {
      state: 'Enabled'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/sql/server:<version>'

// Required parameters
param name = 'sqlsvln'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param administratorLogin = 'adminUserName'
param administratorLoginPassword = '<administratorLoginPassword>'
param location = '<location>'
param managedIdentities = {
  systemAssigned: true
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param primaryUserAssignedIdentityId = '<primaryUserAssignedIdentityId>'
param securityAlertPolicy = {
  emailAccountAdmins: true
  state: 'Enabled'
}
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
param vulnerabilityAssessmentsClassic = {
  recurringScansEmails: [
    'test1@contoso.com'
    'test2@contoso.com'
  ]
  recurringScansEmailSubscriptionAdmins: true
  recurringScansIsEnabled: true
  storageAccountResourceId: '<storageAccountResourceId>'
}
param vulnerabilityAssessmentsExpress = {
  state: 'Enabled'
}
```

</details>
<p>

### Example 7: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module serverMod 'br/<registry-alias>:res/sql/server:<version>' = {
  name: 'server-mod'
  params: {
    // Required parameters
    name: 'sqlswaf'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        service: 'sqlServer'
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
    ]
    // Non-required parameters
    administrators: {
      azureADOnlyAuthentication: true
      login: 'myspn'
      principalType: 'Application'
      sid: '<sid>'
      tenantId: '<tenantId>'
    }
    databases: [
      {
        backupLongTermRetentionPolicy: {
          monthlyRetention: 'P6M'
        }
        backupShortTermRetentionPolicy: {
          retentionDays: 14
        }
        capacity: 0
        collation: 'SQL_Latin1_General_CP1_CI_AS'
        diagnosticSettings: [
          {
            eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
            eventHubName: '<eventHubName>'
            name: 'customSetting'
            storageAccountResourceId: '<storageAccountResourceId>'
            workspaceResourceId: '<workspaceResourceId>'
          }
        ]
        elasticPoolId: '<elasticPoolId>'
        encryptionProtectorObj: {
          serverKeyName: '<serverKeyName>'
          serverKeyType: 'AzureKeyVault'
        }
        licenseType: 'LicenseIncluded'
        maxSizeBytes: 34359738368
        name: 'sqlswafdb-001'
        skuName: 'ElasticPool'
        skuTier: 'GeneralPurpose'
      }
    ]
    elasticPools: [
      {
        licenseType: 'LicenseIncluded'
        maintenanceConfigurationId: '<maintenanceConfigurationId>'
        name: 'sqlswaf-ep-001'
        skuCapacity: 10
        skuName: 'GP_Gen5'
        skuTier: 'GeneralPurpose'
      }
    ]
    keys: [
      {
        serverKeyType: 'AzureKeyVault'
        uri: '<uri>'
      }
    ]
    location: '<location>'
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    primaryUserAssignedIdentityId: '<primaryUserAssignedIdentityId>'
    restrictOutboundNetworkAccess: 'Disabled'
    securityAlertPolicy: {
      emailAccountAdmins: true
      state: 'Enabled'
    }
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    virtualNetworkRules: [
      {
        ignoreMissingVnetServiceEndpoint: true
        name: 'newVnetRule1'
        virtualNetworkSubnetId: '<virtualNetworkSubnetId>'
      }
    ]
    vulnerabilityAssessmentsClassic: {
      recurringScansEmails: [
        'test1@contoso.com'
        'test2@contoso.com'
      ]
      recurringScansEmailSubscriptionAdmins: true
      recurringScansIsEnabled: true
      storageAccountResourceId: '<storageAccountResourceId>'
    }
    vulnerabilityAssessmentsExpress: {
      state: 'Enabled'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/sql/server:<version>'

// Required parameters
param name = 'sqlswaf'
param privateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    service: 'sqlServer'
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
]
// Non-required parameters
param administrators = {
  azureADOnlyAuthentication: true
  login: 'myspn'
  principalType: 'Application'
  sid: '<sid>'
  tenantId: '<tenantId>'
}
param databases = [
  {
    backupLongTermRetentionPolicy: {
      monthlyRetention: 'P6M'
    }
    backupShortTermRetentionPolicy: {
      retentionDays: 14
    }
    capacity: 0
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    elasticPoolId: '<elasticPoolId>'
    encryptionProtectorObj: {
      serverKeyName: '<serverKeyName>'
      serverKeyType: 'AzureKeyVault'
    }
    licenseType: 'LicenseIncluded'
    maxSizeBytes: 34359738368
    name: 'sqlswafdb-001'
    skuName: 'ElasticPool'
    skuTier: 'GeneralPurpose'
  }
]
param elasticPools = [
  {
    licenseType: 'LicenseIncluded'
    maintenanceConfigurationId: '<maintenanceConfigurationId>'
    name: 'sqlswaf-ep-001'
    skuCapacity: 10
    skuName: 'GP_Gen5'
    skuTier: 'GeneralPurpose'
  }
]
param keys = [
  {
    serverKeyType: 'AzureKeyVault'
    uri: '<uri>'
  }
]
param location = '<location>'
param managedIdentities = {
  systemAssigned: true
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param primaryUserAssignedIdentityId = '<primaryUserAssignedIdentityId>'
param restrictOutboundNetworkAccess = 'Disabled'
param securityAlertPolicy = {
  emailAccountAdmins: true
  state: 'Enabled'
}
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
param virtualNetworkRules = [
  {
    ignoreMissingVnetServiceEndpoint: true
    name: 'newVnetRule1'
    virtualNetworkSubnetId: '<virtualNetworkSubnetId>'
  }
]
param vulnerabilityAssessmentsClassic = {
  recurringScansEmails: [
    'test1@contoso.com'
    'test2@contoso.com'
  ]
  recurringScansEmailSubscriptionAdmins: true
  recurringScansIsEnabled: true
  storageAccountResourceId: '<storageAccountResourceId>'
}
param vulnerabilityAssessmentsExpress = {
  state: 'Enabled'
}
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the server. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`administratorLogin`](#parameter-administratorlogin) | string | The administrator username for the server. Required if no `administrators` object for AAD authentication is provided.<p>Once created it cannot be changed. Default: empty |
| [`administratorLoginPassword`](#parameter-administratorloginpassword) | securestring | The administrator login password. Required if no `administrators` object for AAD authentication is provided. |
| [`administrators`](#parameter-administrators) | object | The Entra ID administrator of the server. Required if no `administratorLogin` & `administratorLoginPassword` is provided.<p>This can only be used at server create time. If used for server update, it will be ignored or it will result in an error.<p>For updates individual APIs will need to be used.<p><p>Setting administrators.azureADOnlyAuthentication to false will make the resource non-compliant.<p> |
| [`primaryUserAssignedIdentityId`](#parameter-primaryuserassignedidentityid) | string | The resource ID of a user assigned identity to be used by default. Default: first item in managedIdentities.userAssignedIdentities.<p>Required if " managedIdentities.userAssignedIdentities" is not empty. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`advancedthreatProtection`](#parameter-advancedthreatprotection) | string | Whether or not to enable advanced threat protection for this server. Default is 'Enabled'. |
| [`auditSettings`](#parameter-auditsettings) | object | The audit settings configuration. |
| [`databases`](#parameter-databases) | array | The databases to create in the server. |
| [`elasticPools`](#parameter-elasticpools) | array | The Elastic Pools to create in the server. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`encryptionProtector`](#parameter-encryptionprotector) | object | The encryption protection configuration. |
| [`firewallRules`](#parameter-firewallrules) | array | The firewall rules to create in the server. |
| [`keys`](#parameter-keys) | array | The keys to configure. |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`managedIdentities`](#parameter-managedidentities) | object | The managed identity definition for this resource. |
| [`minimalTlsVersion`](#parameter-minimaltlsversion) | string | Minimal TLS version allowed. Default: 1.2<p><p>Setting this parameter to values lower than '1.2' or 'None' will make the resource non-compliant.<p> |
| [`outboundFirewallRules`](#parameter-outboundfirewallrules) | array | A list of fully-qualified domain named that the SQL Server will be allowed to access when restrictOutboundNetworkAccess is Enabled. |
| [`privateEndpoints`](#parameter-privateendpoints) | array | Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. |
| [`publicNetworkAccess`](#parameter-publicnetworkaccess) | string | Whether or not public network access is allowed for this resource.<p>For security reasons it should be disabled. If not specified, it will be disabled by default.<p><p>Setting this parameter to 'Enabled' will make the resource non-compliant.<p> |
| [`restrictOutboundNetworkAccess`](#parameter-restrictoutboundnetworkaccess) | string | Whether or not to restrict outbound network access for this server. Default is 'Enabled'.<p><p>Setting this parameter to 'Disabled' will make the resource non-compliant.<p> |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`securityAlertPolicy`](#parameter-securityalertpolicy) | object | The security alert policies to create in the server. Deafult: state is Enabled. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`virtualNetworkRules`](#parameter-virtualnetworkrules) | array | The virtual network rules to create in the server. |
| [`vulnerabilityAssessmentsClassic`](#parameter-vulnerabilityassessmentsclassic) | object | The vulnerability assessment (Classic) configuration. |
| [`vulnerabilityAssessmentsExpress`](#parameter-vulnerabilityassessmentsexpress) | object | The vulnerability assessment (Express) configuration. Default: 'Enabled' |

### Parameter: `name`

The name of the server.

- Required: Yes
- Type: string

### Parameter: `administratorLogin`

The administrator username for the server. Required if no `administrators` object for AAD authentication is provided.<p>Once created it cannot be changed. Default: empty

- Required: No
- Type: string
- Default: `''`

### Parameter: `administratorLoginPassword`

The administrator login password. Required if no `administrators` object for AAD authentication is provided.

- Required: No
- Type: securestring
- Default: `''`

### Parameter: `administrators`

The Entra ID administrator of the server. Required if no `administratorLogin` & `administratorLoginPassword` is provided.<p>This can only be used at server create time. If used for server update, it will be ignored or it will result in an error.<p>For updates individual APIs will need to be used.<p><p>Setting administrators.azureADOnlyAuthentication to false will make the resource non-compliant.<p>

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalType`](#parameter-administratorsprincipaltype) | string | Principal Type of the sever administrator. |
| [`sid`](#parameter-administratorssid) | string | SID (object ID) of the server administrator. Pattern = ^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$ |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`administratorType`](#parameter-administratorsadministratortype) | string | Type of the sever administrator. |
| [`azureADOnlyAuthentication`](#parameter-administratorsazureadonlyauthentication) | bool | Azure Active Directory only Authentication enabled. |
| [`login`](#parameter-administratorslogin) | string | Login name of the server administrator. |
| [`tenantId`](#parameter-administratorstenantid) | string | Tenant ID of the administrator. Pattern = ^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$. |

### Parameter: `administrators.principalType`

Principal Type of the sever administrator.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Application'
    'Group'
    'User'
  ]
  ```

### Parameter: `administrators.sid`

SID (object ID) of the server administrator. Pattern = ^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$

- Required: Yes
- Type: string

### Parameter: `administrators.administratorType`

Type of the sever administrator.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'ActiveDirectory'
  ]
  ```

### Parameter: `administrators.azureADOnlyAuthentication`

Azure Active Directory only Authentication enabled.

- Required: No
- Type: bool

### Parameter: `administrators.login`

Login name of the server administrator.

- Required: No
- Type: string

### Parameter: `administrators.tenantId`

Tenant ID of the administrator. Pattern = ^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$.

- Required: No
- Type: string

### Parameter: `primaryUserAssignedIdentityId`

The resource ID of a user assigned identity to be used by default. Default: first item in managedIdentities.userAssignedIdentities.<p>Required if " managedIdentities.userAssignedIdentities" is not empty.

- Required: No
- Type: string
- Default: `[coalesce(tryGet(parameters('managedIdentities'), 'userAssignedResourceIds', 0), '')]`

### Parameter: `advancedthreatProtection`

Whether or not to enable advanced threat protection for this server. Default is 'Enabled'.

- Required: No
- Type: string
- Default: `'Enabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `auditSettings`

The audit settings configuration.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`state`](#parameter-auditsettingsstate) | string | Specifies the state of the audit setting. If state is Enabled, storageEndpoint or isAzureMonitorTargetEnabled are required. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`auditActionsAndGroups`](#parameter-auditsettingsauditactionsandgroups) | array | Specifies the Actions-Groups and Actions to audit. |
| [`isAzureMonitorTargetEnabled`](#parameter-auditsettingsisazuremonitortargetenabled) | bool | Specifies whether audit events are sent to Azure Monitor. If true, the workspaceResourceId also needs to be provided. |
| [`isDevopsAuditEnabled`](#parameter-auditsettingsisdevopsauditenabled) | bool | Specifies the state of devops audit. If state is Enabled, devops logs will be sent to Azure Monitor. |
| [`isManagedIdentityInUse`](#parameter-auditsettingsismanagedidentityinuse) | bool | Specifies whether Managed Identity is used to access blob storage. |
| [`isStorageSecondaryKeyInUse`](#parameter-auditsettingsisstoragesecondarykeyinuse) | bool | Specifies whether storageAccountAccessKey value is the storage's secondary key. |
| [`name`](#parameter-auditsettingsname) | string | Specifies the name of the audit setting. |
| [`queueDelayMs`](#parameter-auditsettingsqueuedelayms) | int | Specifies the amount of time in milliseconds that can elapse before audit actions are forced to be processed. |
| [`retentionDays`](#parameter-auditsettingsretentiondays) | int | Specifies the number of days to keep in the audit logs in the storage account. |
| [`storageAccountResourceId`](#parameter-auditsettingsstorageaccountresourceid) | string | Specifies the identifier key of the storage account that audit logs will be sent to. |
| [`workspaceResourceId`](#parameter-auditsettingsworkspaceresourceid) | string | Resource ID of the log analytics workspace that audit logs will be sent to. |

### Parameter: `auditSettings.state`

Specifies the state of the audit setting. If state is Enabled, storageEndpoint or isAzureMonitorTargetEnabled are required.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `auditSettings.auditActionsAndGroups`

Specifies the Actions-Groups and Actions to audit.

- Required: No
- Type: array

### Parameter: `auditSettings.isAzureMonitorTargetEnabled`

Specifies whether audit events are sent to Azure Monitor. If true, the workspaceResourceId also needs to be provided.

- Required: No
- Type: bool

### Parameter: `auditSettings.isDevopsAuditEnabled`

Specifies the state of devops audit. If state is Enabled, devops logs will be sent to Azure Monitor.

- Required: No
- Type: bool

### Parameter: `auditSettings.isManagedIdentityInUse`

Specifies whether Managed Identity is used to access blob storage.

- Required: No
- Type: bool

### Parameter: `auditSettings.isStorageSecondaryKeyInUse`

Specifies whether storageAccountAccessKey value is the storage's secondary key.

- Required: No
- Type: bool

### Parameter: `auditSettings.name`

Specifies the name of the audit setting.

- Required: No
- Type: string

### Parameter: `auditSettings.queueDelayMs`

Specifies the amount of time in milliseconds that can elapse before audit actions are forced to be processed.

- Required: No
- Type: int

### Parameter: `auditSettings.retentionDays`

Specifies the number of days to keep in the audit logs in the storage account.

- Required: No
- Type: int

### Parameter: `auditSettings.storageAccountResourceId`

Specifies the identifier key of the storage account that audit logs will be sent to.

- Required: No
- Type: string

### Parameter: `auditSettings.workspaceResourceId`

Resource ID of the log analytics workspace that audit logs will be sent to.

- Required: No
- Type: string

### Parameter: `databases`

The databases to create in the server.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-databasesname) | string | The name of the database. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`autoPauseDelay`](#parameter-databasesautopausedelay) | int | Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled. |
| [`backupLongTermRetentionPolicy`](#parameter-databasesbackuplongtermretentionpolicy) | object | The long term backup retention policy to create for the database. |
| [`backupShortTermRetentionPolicy`](#parameter-databasesbackupshorttermretentionpolicy) | object | The short term backup retention policy to create for the database. |
| [`catalogCollation`](#parameter-databasescatalogcollation) | string | Collation of the metadata catalog. |
| [`collation`](#parameter-databasescollation) | string | The collation of the database. |
| [`createMode`](#parameter-databasescreatemode) | string | Specifies the mode of database creation. |
| [`diagnosticSettings`](#parameter-databasesdiagnosticsettings) | array | The diagnostic settings of the service. |
| [`elasticPoolId`](#parameter-databaseselasticpoolid) | string | The resource identifier of the elastic pool containing this database. |
| [`freeLimitExhaustionBehavior`](#parameter-databasesfreelimitexhaustionbehavior) | string | Specifies the behavior when monthly free limits are exhausted for the free database. Default: 'BillOverUsage'. |
| [`highAvailabilityReplicaCount`](#parameter-databaseshighavailabilityreplicacount) | int | The number of secondary replicas associated with the database that are used to provide high availability.<p>Not applicable to a Hyperscale database within an elastic pool. |
| [`isLedgerOn`](#parameter-databasesisledgeron) | bool | Whether or not this database is a ledger database, which means all tables in the database are ledger tables.<p>Note: the value of this property cannot be changed after the database has been created. |
| [`licenseType`](#parameter-databaseslicensetype) | string | The license type to apply for this database. LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit. |
| [`location`](#parameter-databaseslocation) | string | Location for all resources. |
| [`maintenanceConfigurationId`](#parameter-databasesmaintenanceconfigurationid) | string | Maintenance configuration ID assigned to the database. This configuration defines the period when the maintenance updates will occur. |
| [`manualCutover`](#parameter-databasesmanualcutover) | bool | Whether or not customer controlled manual cutover needs to be done during Update Database operation to Hyperscale tier. |
| [`maxSizeBytes`](#parameter-databasesmaxsizebytes) | int | The max size of the database expressed in bytes.<p><p>See https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=azuresqldb-current&tabs=sqlpool#maxsize for supported sizes. |
| [`minCapacity`](#parameter-databasesmincapacity) | string | Minimal capacity that database will always have allocated. |
| [`performCutover`](#parameter-databasesperformcutover) | bool | To trigger customer controlled manual cutover during the wait state while Scaling operation is in progress. |
| [`preferredEnclaveType`](#parameter-databasespreferredenclavetype) | string | Type of enclave requested on the database i.e. Default or VBS enclaves. |
| [`readScale`](#parameter-databasesreadscale) | string | The state of read-only routing. |
| [`recoveryServicesRecoveryPointResourceId`](#parameter-databasesrecoveryservicesrecoverypointresourceid) | string | Resource ID of backup if createMode set to RestoreLongTermRetentionBackup. |
| [`requestedBackupStorageRedundancy`](#parameter-databasesrequestedbackupstorageredundancy) | string | The storage account type to be used to store backups for this database. |
| [`restorePointInTime`](#parameter-databasesrestorepointintime) | string | Point in time (ISO8601 format) of the source database to restore when createMode set to Restore or PointInTimeRestore. |
| [`sampleName`](#parameter-databasessamplename) | string | The name of the sample schema to apply when creating this database. |
| [`secondaryType`](#parameter-databasessecondarytype) | string | The secondary type of the database if it is a secondary. Valid values are Geo, Named and Standby. Default: empty |
| [`skuCapacity`](#parameter-databasesskucapacity) | int | Capacity of the particular SKU. |
| [`skuFamily`](#parameter-databasesskufamily) | string | If the service has different generations of hardware, for the same SKU, then that can be captured here. |
| [`skuName`](#parameter-databasesskuname) | string | The name of the SKU that represents a Service Objective, e.g. P3, S1, GP_Gen5, GP_Gen5_2. Default: GP_Gen5_2.<p><p>The list of SKUs may vary by region and support offer.To determine the SKUs (including the SKU name, tier/edition, family, and capacity) that are available to your subscription in an Azure region,<p>use the Capabilities_ListByLocation REST API or one of the following commands:<p><p>Azure CLI: `az sql db list-editions -l {location} -o table` and find option in ServiceObjective column.<p><p>Azure PowerShell: Get-AzSqlServerServiceObjective -Location {location} |
| [`skuSize`](#parameter-databasesskusize) | string | Size of the particular SKU. |
| [`skuTier`](#parameter-databasesskutier) | string | The skuTier or edition of the particular SKU. |
| [`sourceDatabaseDeletionDate`](#parameter-databasessourcedatabasedeletiondate) | string | The time that the database was deleted when restoring a deleted database. |
| [`sourceDatabaseResourceId`](#parameter-databasessourcedatabaseresourceid) | string | Resource ID of database if createMode set to Copy, Secondary, PointInTimeRestore, Recovery or Restore. |
| [`sourceResourceId`](#parameter-databasessourceresourceid) | string | The resource identifier of the source associated with the create operation of this database.<p>This property is only supported for DataWarehouse edition and allows to restore across subscriptions. |
| [`tags`](#parameter-databasestags) | object | Tags of the resource. |
| [`useFreeLimit`](#parameter-databasesusefreelimit) | bool | Whether or not the database uses free monthly limits. Allowed on one database in a subscription. |
| [`zoneRedundant`](#parameter-databaseszoneredundant) | bool | Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. |

### Parameter: `databases.name`

The name of the database.

- Required: Yes
- Type: string

### Parameter: `databases.autoPauseDelay`

Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled.

- Required: No
- Type: int

### Parameter: `databases.backupLongTermRetentionPolicy`

The long term backup retention policy to create for the database.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`monthlyRetention`](#parameter-databasesbackuplongtermretentionpolicymonthlyretention) | string | Weekly retention in ISO 8601 duration format. Default: 'P1M'.<p><p>If you specify a value, the first backup of each month is copied to the long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed. |
| [`weeklyRetention`](#parameter-databasesbackuplongtermretentionpolicyweeklyretention) | string | Monthly retention in ISO 8601 duration format. Default: 'P1W'.<p><p>If you specify a value, one backup every week is copied to long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed. |
| [`weekOfYear`](#parameter-databasesbackuplongtermretentionpolicyweekofyear) | int | Week of year backup to keep for yearly retention. Default: 1.<p><p>If the specified WeekOfYear is in the past when the policy is configured, the first LTR backup is created the following year.<p> |
| [`yearlyRetention`](#parameter-databasesbackuplongtermretentionpolicyyearlyretention) | string | Yearly retention in ISO 8601 duration format. Default: 'P1Y'.<p><p>If you specify a value, one backup during the week specified by WeekOfYear is copied to the long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed. |

### Parameter: `databases.backupLongTermRetentionPolicy.monthlyRetention`

Weekly retention in ISO 8601 duration format. Default: 'P1M'.<p><p>If you specify a value, the first backup of each month is copied to the long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed.

- Required: No
- Type: string

### Parameter: `databases.backupLongTermRetentionPolicy.weeklyRetention`

Monthly retention in ISO 8601 duration format. Default: 'P1W'.<p><p>If you specify a value, one backup every week is copied to long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed.

- Required: No
- Type: string

### Parameter: `databases.backupLongTermRetentionPolicy.weekOfYear`

Week of year backup to keep for yearly retention. Default: 1.<p><p>If the specified WeekOfYear is in the past when the policy is configured, the first LTR backup is created the following year.<p>

- Required: No
- Type: int

### Parameter: `databases.backupLongTermRetentionPolicy.yearlyRetention`

Yearly retention in ISO 8601 duration format. Default: 'P1Y'.<p><p>If you specify a value, one backup during the week specified by WeekOfYear is copied to the long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed.

- Required: No
- Type: string

### Parameter: `databases.backupShortTermRetentionPolicy`

The short term backup retention policy to create for the database.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`diffBackupIntervalInHours`](#parameter-databasesbackupshorttermretentionpolicydiffbackupintervalinhours) | int | The differential backup interval in hours.<p>This is how many interval hours between each differential backup will be supported.<p>Only applicable to live databases but not dropped databases. |
| [`retentionDays`](#parameter-databasesbackupshorttermretentionpolicyretentiondays) | int | The backup retention period in days. This is how many days Point-in-Time Restore will be supported.<p>Basic-tier databases are limited to a maximum of 7 days. For all databases, the maximum is 35 days. |

### Parameter: `databases.backupShortTermRetentionPolicy.diffBackupIntervalInHours`

The differential backup interval in hours.<p>This is how many interval hours between each differential backup will be supported.<p>Only applicable to live databases but not dropped databases.

- Required: No
- Type: int
- Allowed:
  ```Bicep
  [
    12
    24
  ]
  ```

### Parameter: `databases.backupShortTermRetentionPolicy.retentionDays`

The backup retention period in days. This is how many days Point-in-Time Restore will be supported.<p>Basic-tier databases are limited to a maximum of 7 days. For all databases, the maximum is 35 days.

- Required: No
- Type: int

### Parameter: `databases.catalogCollation`

Collation of the metadata catalog.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'DATABASE_DEFAULT'
    'SQL_Latin1_General_CP1_CI_AS'
  ]
  ```

### Parameter: `databases.collation`

The collation of the database.

- Required: No
- Type: string

### Parameter: `databases.createMode`

Specifies the mode of database creation.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Copy'
    'Default'
    'OnlineSecondary'
    'PointInTimeRestore'
    'Recovery'
    'Restore'
    'RestoreLongTermRetentionBackup'
    'Secondary'
  ]
  ```

### Parameter: `databases.diagnosticSettings`

The diagnostic settings of the service.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`eventHubAuthorizationRuleResourceId`](#parameter-databasesdiagnosticsettingseventhubauthorizationruleresourceid) | string | Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| [`eventHubName`](#parameter-databasesdiagnosticsettingseventhubname) | string | Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`logAnalyticsDestinationType`](#parameter-databasesdiagnosticsettingsloganalyticsdestinationtype) | string | A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type. |
| [`logCategoriesAndGroups`](#parameter-databasesdiagnosticsettingslogcategoriesandgroups) | array | The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection. |
| [`marketplacePartnerResourceId`](#parameter-databasesdiagnosticsettingsmarketplacepartnerresourceid) | string | The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs. |
| [`metricCategories`](#parameter-databasesdiagnosticsettingsmetriccategories) | array | The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection. |
| [`name`](#parameter-databasesdiagnosticsettingsname) | string | The name of diagnostic setting. |
| [`storageAccountResourceId`](#parameter-databasesdiagnosticsettingsstorageaccountresourceid) | string | Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`workspaceResourceId`](#parameter-databasesdiagnosticsettingsworkspaceresourceid) | string | Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |

### Parameter: `databases.diagnosticSettings.eventHubAuthorizationRuleResourceId`

Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.

- Required: No
- Type: string

### Parameter: `databases.diagnosticSettings.eventHubName`

Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `databases.diagnosticSettings.logAnalyticsDestinationType`

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

### Parameter: `databases.diagnosticSettings.logCategoriesAndGroups`

The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-databasesdiagnosticsettingslogcategoriesandgroupscategory) | string | Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here. |
| [`categoryGroup`](#parameter-databasesdiagnosticsettingslogcategoriesandgroupscategorygroup) | string | Name of a Diagnostic Log category group for a resource type this setting is applied to. |
| [`enabled`](#parameter-databasesdiagnosticsettingslogcategoriesandgroupsenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `databases.diagnosticSettings.logCategoriesAndGroups.category`

Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.

- Required: No
- Type: string

### Parameter: `databases.diagnosticSettings.logCategoriesAndGroups.categoryGroup`

Name of a Diagnostic Log category group for a resource type this setting is applied to.

- Required: No
- Type: string

### Parameter: `databases.diagnosticSettings.logCategoriesAndGroups.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `databases.diagnosticSettings.marketplacePartnerResourceId`

The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.

- Required: No
- Type: string

### Parameter: `databases.diagnosticSettings.metricCategories`

The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-databasesdiagnosticsettingsmetriccategoriescategory) | string | Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-databasesdiagnosticsettingsmetriccategoriesenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `databases.diagnosticSettings.metricCategories.category`

Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.

- Required: Yes
- Type: string

### Parameter: `databases.diagnosticSettings.metricCategories.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `databases.diagnosticSettings.name`

The name of diagnostic setting.

- Required: No
- Type: string

### Parameter: `databases.diagnosticSettings.storageAccountResourceId`

Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `databases.diagnosticSettings.workspaceResourceId`

Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `databases.elasticPoolId`

The resource identifier of the elastic pool containing this database.

- Required: No
- Type: string

### Parameter: `databases.freeLimitExhaustionBehavior`

Specifies the behavior when monthly free limits are exhausted for the free database. Default: 'BillOverUsage'.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'AutoPause'
    'BillOverUsage'
  ]
  ```

### Parameter: `databases.highAvailabilityReplicaCount`

The number of secondary replicas associated with the database that are used to provide high availability.<p>Not applicable to a Hyperscale database within an elastic pool.

- Required: No
- Type: int

### Parameter: `databases.isLedgerOn`

Whether or not this database is a ledger database, which means all tables in the database are ledger tables.<p>Note: the value of this property cannot be changed after the database has been created.

- Required: No
- Type: bool

### Parameter: `databases.licenseType`

The license type to apply for this database. LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    ''
    'BasePrice'
    'LicenseIncluded'
  ]
  ```

### Parameter: `databases.location`

Location for all resources.

- Required: No
- Type: string

### Parameter: `databases.maintenanceConfigurationId`

Maintenance configuration ID assigned to the database. This configuration defines the period when the maintenance updates will occur.

- Required: No
- Type: string

### Parameter: `databases.manualCutover`

Whether or not customer controlled manual cutover needs to be done during Update Database operation to Hyperscale tier.

- Required: No
- Type: bool

### Parameter: `databases.maxSizeBytes`

The max size of the database expressed in bytes.<p><p>See https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=azuresqldb-current&tabs=sqlpool#maxsize for supported sizes.

- Required: No
- Type: int

### Parameter: `databases.minCapacity`

Minimal capacity that database will always have allocated.

- Required: No
- Type: string

### Parameter: `databases.performCutover`

To trigger customer controlled manual cutover during the wait state while Scaling operation is in progress.

- Required: No
- Type: bool

### Parameter: `databases.preferredEnclaveType`

Type of enclave requested on the database i.e. Default or VBS enclaves.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    ''
    'Default'
    'VBS'
  ]
  ```

### Parameter: `databases.readScale`

The state of read-only routing.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    ''
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `databases.recoveryServicesRecoveryPointResourceId`

Resource ID of backup if createMode set to RestoreLongTermRetentionBackup.

- Required: No
- Type: string

### Parameter: `databases.requestedBackupStorageRedundancy`

The storage account type to be used to store backups for this database.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    ''
    'Geo'
    'Local'
    'Zone'
  ]
  ```

### Parameter: `databases.restorePointInTime`

Point in time (ISO8601 format) of the source database to restore when createMode set to Restore or PointInTimeRestore.

- Required: No
- Type: string

### Parameter: `databases.sampleName`

The name of the sample schema to apply when creating this database.

- Required: No
- Type: string

### Parameter: `databases.secondaryType`

The secondary type of the database if it is a secondary. Valid values are Geo, Named and Standby. Default: empty

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    ''
    'Geo'
    'Named'
    'Standby'
  ]
  ```

### Parameter: `databases.skuCapacity`

Capacity of the particular SKU.

- Required: No
- Type: int

### Parameter: `databases.skuFamily`

If the service has different generations of hardware, for the same SKU, then that can be captured here.

- Required: No
- Type: string

### Parameter: `databases.skuName`

The name of the SKU that represents a Service Objective, e.g. P3, S1, GP_Gen5, GP_Gen5_2. Default: GP_Gen5_2.<p><p>The list of SKUs may vary by region and support offer.To determine the SKUs (including the SKU name, tier/edition, family, and capacity) that are available to your subscription in an Azure region,<p>use the Capabilities_ListByLocation REST API or one of the following commands:<p><p>Azure CLI: `az sql db list-editions -l {location} -o table` and find option in ServiceObjective column.<p><p>Azure PowerShell: Get-AzSqlServerServiceObjective -Location {location}

- Required: No
- Type: string

### Parameter: `databases.skuSize`

Size of the particular SKU.

- Required: No
- Type: string

### Parameter: `databases.skuTier`

The skuTier or edition of the particular SKU.

- Required: No
- Type: string

### Parameter: `databases.sourceDatabaseDeletionDate`

The time that the database was deleted when restoring a deleted database.

- Required: No
- Type: string

### Parameter: `databases.sourceDatabaseResourceId`

Resource ID of database if createMode set to Copy, Secondary, PointInTimeRestore, Recovery or Restore.

- Required: No
- Type: string

### Parameter: `databases.sourceResourceId`

The resource identifier of the source associated with the create operation of this database.<p>This property is only supported for DataWarehouse edition and allows to restore across subscriptions.

- Required: No
- Type: string

### Parameter: `databases.tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `databases.useFreeLimit`

Whether or not the database uses free monthly limits. Allowed on one database in a subscription.

- Required: No
- Type: bool

### Parameter: `databases.zoneRedundant`

Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones.

- Required: No
- Type: bool

### Parameter: `elasticPools`

The Elastic Pools to create in the server.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-elasticpoolsname) | string | The name of the elastic pool. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`databaseMaxCapacity`](#parameter-elasticpoolsdatabasemaxcapacity) | int | The maximum capacity any one database can consume. |
| [`databaseMinCapacity`](#parameter-elasticpoolsdatabasemincapacity) | int | The minimum capacity all databases are guaranteed. |
| [`highAvailabilityReplicaCount`](#parameter-elasticpoolshighavailabilityreplicacount) | int | The number of secondary replicas associated with the elastic pool that are used to provide high availability. Applicable only to Hyperscale elastic pools. |
| [`licenseType`](#parameter-elasticpoolslicensetype) | string | Tags of the resource. |
| [`maintenanceConfigurationId`](#parameter-elasticpoolsmaintenanceconfigurationid) | string | Maintenance configuration resource ID assigned to the elastic pool. This configuration defines the period when the maintenance updates will will occur. |
| [`maxSizeBytes`](#parameter-elasticpoolsmaxsizebytes) | int | The storage limit for the database elastic pool in bytes. |
| [`minCapacity`](#parameter-elasticpoolsmincapacity) | int | Minimal capacity that serverless pool will not shrink below, if not paused. |
| [`skuCapacity`](#parameter-elasticpoolsskucapacity) | int | Capacity of the particular SKU. |
| [`skuName`](#parameter-elasticpoolsskuname) | string | The name of the SKU, typically, a letter + Number code, e.g. P3. |
| [`skuTier`](#parameter-elasticpoolsskutier) | string | The tier or edition of the particular SKU, e.g. Basic, Premium. |
| [`tags`](#parameter-elasticpoolstags) | object | Tags of the resource. |
| [`zoneRedundant`](#parameter-elasticpoolszoneredundant) | bool | Whether or not this elastic pool is zone redundant, which means the replicas of this elastic pool will be spread across multiple availability zones. |

### Parameter: `elasticPools.name`

The name of the elastic pool.

- Required: Yes
- Type: string

### Parameter: `elasticPools.databaseMaxCapacity`

The maximum capacity any one database can consume.

- Required: No
- Type: int

### Parameter: `elasticPools.databaseMinCapacity`

The minimum capacity all databases are guaranteed.

- Required: No
- Type: int

### Parameter: `elasticPools.highAvailabilityReplicaCount`

The number of secondary replicas associated with the elastic pool that are used to provide high availability. Applicable only to Hyperscale elastic pools.

- Required: No
- Type: int

### Parameter: `elasticPools.licenseType`

Tags of the resource.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'BasePrice'
    'LicenseIncluded'
  ]
  ```

### Parameter: `elasticPools.maintenanceConfigurationId`

Maintenance configuration resource ID assigned to the elastic pool. This configuration defines the period when the maintenance updates will will occur.

- Required: No
- Type: string

### Parameter: `elasticPools.maxSizeBytes`

The storage limit for the database elastic pool in bytes.

- Required: No
- Type: int

### Parameter: `elasticPools.minCapacity`

Minimal capacity that serverless pool will not shrink below, if not paused.

- Required: No
- Type: int

### Parameter: `elasticPools.skuCapacity`

Capacity of the particular SKU.

- Required: No
- Type: int

### Parameter: `elasticPools.skuName`

The name of the SKU, typically, a letter + Number code, e.g. P3.

- Required: No
- Type: string

### Parameter: `elasticPools.skuTier`

The tier or edition of the particular SKU, e.g. Basic, Premium.

- Required: No
- Type: string

### Parameter: `elasticPools.tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `elasticPools.zoneRedundant`

Whether or not this elastic pool is zone redundant, which means the replicas of this elastic pool will be spread across multiple availability zones.

- Required: No
- Type: bool

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `encryptionProtector`

The encryption protection configuration.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`serverKeyName`](#parameter-encryptionprotectorserverkeyname) | string | The name of the server key. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`autoRotationEnabled`](#parameter-encryptionprotectorautorotationenabled) | bool | Key auto rotation opt-in. |
| [`serverKeyType`](#parameter-encryptionprotectorserverkeytype) | string | The encryption protector type. |

### Parameter: `encryptionProtector.serverKeyName`

The name of the server key.

- Required: Yes
- Type: string

### Parameter: `encryptionProtector.autoRotationEnabled`

Key auto rotation opt-in.

- Required: No
- Type: bool

### Parameter: `encryptionProtector.serverKeyType`

The encryption protector type.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVault'
    'ServiceManaged'
  ]
  ```

### Parameter: `firewallRules`

The firewall rules to create in the server.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-firewallrulesname) | string | The name of the Server Firewall Rule. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`endIpAddress`](#parameter-firewallrulesendipaddress) | string | The end IP address of the firewall rule. Must be IPv4 format.<p>Must be greater than or equal to startIpAddress. Use value \'0.0.0.0\' for all Azure-internal IP addresses. |
| [`startIpAddress`](#parameter-firewallrulesstartipaddress) | string | The start IP address of the firewall rule. Must be IPv4 format.<p>Use value \'0.0.0.0\' for all Azure-internal IP addresses. |

### Parameter: `firewallRules.name`

The name of the Server Firewall Rule.

- Required: Yes
- Type: string

### Parameter: `firewallRules.endIpAddress`

The end IP address of the firewall rule. Must be IPv4 format.<p>Must be greater than or equal to startIpAddress. Use value \'0.0.0.0\' for all Azure-internal IP addresses.

- Required: No
- Type: string

### Parameter: `firewallRules.startIpAddress`

The start IP address of the firewall rule. Must be IPv4 format.<p>Use value \'0.0.0.0\' for all Azure-internal IP addresses.

- Required: No
- Type: string

### Parameter: `keys`

The keys to configure.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-keysname) | string | The name of the key. Must follow the [<keyVaultName>_<keyName>_<keyVersion>] pattern. |
| [`serverKeyType`](#parameter-keysserverkeytype) | string | The encryption protector type like "ServiceManaged", "AzureKeyVault". Default: ServiceManaged. |
| [`uri`](#parameter-keysuri) | string | The URI of the key. If the ServerKeyType is AzureKeyVault, then either the URI or the keyVaultName/keyName combination is required.<p>The AKV URI is required to be in this format: 'https://YourVaultName.vault.azure.net/keys/YourKeyName/YourKeyVersion'<p> |

### Parameter: `keys.name`

The name of the key. Must follow the [<keyVaultName>_<keyName>_<keyVersion>] pattern.

- Required: No
- Type: string

### Parameter: `keys.serverKeyType`

The encryption protector type like "ServiceManaged", "AzureKeyVault". Default: ServiceManaged.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVault'
    'ServiceManaged'
  ]
  ```

### Parameter: `keys.uri`

The URI of the key. If the ServerKeyType is AzureKeyVault, then either the URI or the keyVaultName/keyName combination is required.<p>The AKV URI is required to be in this format: 'https://YourVaultName.vault.azure.net/keys/YourKeyName/YourKeyVersion'<p>

- Required: No
- Type: string

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

### Parameter: `minimalTlsVersion`

Minimal TLS version allowed. Default: 1.2<p><p>Setting this parameter to values lower than '1.2' or 'None' will make the resource non-compliant.<p>

- Required: No
- Type: string
- Default: `'1.2'`
- Allowed:
  ```Bicep
  [
    '1.0'
    '1.1'
    '1.2'
    '1.3'
    'None'
  ]
  ```

### Parameter: `outboundFirewallRules`

A list of fully-qualified domain named that the SQL Server will be allowed to access when restrictOutboundNetworkAccess is Enabled.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-outboundfirewallrulesname) | string | Fully-qualified domain name that the SQL Server will be allowed to access when outbound networking restrictions are enabled. |

### Parameter: `outboundFirewallRules.name`

Fully-qualified domain name that the SQL Server will be allowed to access when outbound networking restrictions are enabled.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints`

Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.

- Required: Yes
- Type: array

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

### Parameter: `publicNetworkAccess`

Whether or not public network access is allowed for this resource.<p>For security reasons it should be disabled. If not specified, it will be disabled by default.<p><p>Setting this parameter to 'Enabled' will make the resource non-compliant.<p>

- Required: No
- Type: string
- Default: `'Disabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
    'SecuredByPerimeter'
  ]
  ```

### Parameter: `restrictOutboundNetworkAccess`

Whether or not to restrict outbound network access for this server. Default is 'Enabled'.<p><p>Setting this parameter to 'Disabled' will make the resource non-compliant.<p>

- Required: No
- Type: string
- Default: `'Enabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'Reservation Purchaser'`
  - `'SQL DB Contributor'`
  - `'SQL Managed Instance Contributor'`
  - `'SQL Security Manager'`
  - `'SQL Server Contributor'`
  - `'SqlDb Migration Role'`
  - `'SqlMI Migration Role'`

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

### Parameter: `securityAlertPolicy`

The security alert policies to create in the server. Deafult: state is Enabled.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      state: 'Enabled'
  }
  ```

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`disabledAlerts`](#parameter-securityalertpolicydisabledalerts) | array | Specifies an array of alerts that are disabled. Default: empty.<p>Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action, Brute_Force. |
| [`emailAccountAdmins`](#parameter-securityalertpolicyemailaccountadmins) | bool | Specifies that the alert is sent to the account administrators. |
| [`emailAddresses`](#parameter-securityalertpolicyemailaddresses) | array | Specifies an array of email addresses to which the alert is sent. |
| [`retentionDays`](#parameter-securityalertpolicyretentiondays) | int | Specifies the number of days to keep in the Threat Detection audit logs. |
| [`state`](#parameter-securityalertpolicystate) | string | Specifies the state of the policy, whether it is enabled or disabled or a policy has not been applied yet on the specific database. |

### Parameter: `securityAlertPolicy.disabledAlerts`

Specifies an array of alerts that are disabled. Default: empty.<p>Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action, Brute_Force.

- Required: No
- Type: array

### Parameter: `securityAlertPolicy.emailAccountAdmins`

Specifies that the alert is sent to the account administrators.

- Required: No
- Type: bool

### Parameter: `securityAlertPolicy.emailAddresses`

Specifies an array of email addresses to which the alert is sent.

- Required: No
- Type: array

### Parameter: `securityAlertPolicy.retentionDays`

Specifies the number of days to keep in the Threat Detection audit logs.

- Required: No
- Type: int

### Parameter: `securityAlertPolicy.state`

Specifies the state of the policy, whether it is enabled or disabled or a policy has not been applied yet on the specific database.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `virtualNetworkRules`

The virtual network rules to create in the server.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-virtualnetworkrulesname) | string | The name of the Server Virtual Network Rule. |
| [`virtualNetworkSubnetId`](#parameter-virtualnetworkrulesvirtualnetworksubnetid) | string | The resource Id of the virtual network subnet. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`ignoreMissingVnetServiceEndpoint`](#parameter-virtualnetworkrulesignoremissingvnetserviceendpoint) | bool | Allow creating a firewall rule before the virtual network has vnet service endpoint enabled. |

### Parameter: `virtualNetworkRules.name`

The name of the Server Virtual Network Rule.

- Required: Yes
- Type: string

### Parameter: `virtualNetworkRules.virtualNetworkSubnetId`

The resource Id of the virtual network subnet.

- Required: Yes
- Type: string

### Parameter: `virtualNetworkRules.ignoreMissingVnetServiceEndpoint`

Allow creating a firewall rule before the virtual network has vnet service endpoint enabled.

- Required: No
- Type: bool

### Parameter: `vulnerabilityAssessmentsClassic`

The vulnerability assessment (Classic) configuration.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`storageAccountResourceId`](#parameter-vulnerabilityassessmentsclassicstorageaccountresourceid) | string | A blob storage to hold the scan results. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`createStorageRoleAssignment`](#parameter-vulnerabilityassessmentsclassiccreatestorageroleassignment) | bool | Create the Storage Blob Data Contributor role assignment on the storage account.<p>Note, the role assignment must not already exist on the storage account. |
| [`recurringScansEmails`](#parameter-vulnerabilityassessmentsclassicrecurringscansemails) | array | Specifies an array of email addresses to which the scan notification is sent. |
| [`recurringScansEmailSubscriptionAdmins`](#parameter-vulnerabilityassessmentsclassicrecurringscansemailsubscriptionadmins) | bool | Specifies that the schedule scan notification will be is sent to the subscription administrators. |
| [`recurringScansIsEnabled`](#parameter-vulnerabilityassessmentsclassicrecurringscansisenabled) | bool | Recurring scans state. |
| [`storageContainerName`](#parameter-vulnerabilityassessmentsclassicstoragecontainername) | string | A blob container to hold the scan results. |
| [`useStorageAccountAccessKey`](#parameter-vulnerabilityassessmentsclassicusestorageaccountaccesskey) | bool | Use Access Key to access the storage account.<p>The storage account cannot be behind a firewall or virtual network.<p>If an access key is not used, the SQL Server system assigned managed identity must be assigned the Storage Blob Data Contributor role on the storage account. |

### Parameter: `vulnerabilityAssessmentsClassic.storageAccountResourceId`

A blob storage to hold the scan results.

- Required: Yes
- Type: string

### Parameter: `vulnerabilityAssessmentsClassic.createStorageRoleAssignment`

Create the Storage Blob Data Contributor role assignment on the storage account.<p>Note, the role assignment must not already exist on the storage account.

- Required: No
- Type: bool

### Parameter: `vulnerabilityAssessmentsClassic.recurringScansEmails`

Specifies an array of email addresses to which the scan notification is sent.

- Required: No
- Type: array

### Parameter: `vulnerabilityAssessmentsClassic.recurringScansEmailSubscriptionAdmins`

Specifies that the schedule scan notification will be is sent to the subscription administrators.

- Required: No
- Type: bool

### Parameter: `vulnerabilityAssessmentsClassic.recurringScansIsEnabled`

Recurring scans state.

- Required: No
- Type: bool

### Parameter: `vulnerabilityAssessmentsClassic.storageContainerName`

A blob container to hold the scan results.

- Required: No
- Type: string

### Parameter: `vulnerabilityAssessmentsClassic.useStorageAccountAccessKey`

Use Access Key to access the storage account.<p>The storage account cannot be behind a firewall or virtual network.<p>If an access key is not used, the SQL Server system assigned managed identity must be assigned the Storage Blob Data Contributor role on the storage account.

- Required: No
- Type: bool

### Parameter: `vulnerabilityAssessmentsExpress`

The vulnerability assessment (Express) configuration. Default: 'Enabled'

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      state: 'Enabled'
  }
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`state`](#parameter-vulnerabilityassessmentsexpressstate) | string | A blob storage to hold the scan results. |

### Parameter: `vulnerabilityAssessmentsExpress.state`

A blob storage to hold the scan results.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `databases` | array | The names of the deployed subnets. |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `fullyQualifiedDomainName` | string | The FQDN of the deployed SQL server. |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the deployed SQL server. |
| `resourceGroupName` | string | The resource group of the deployed SQL server. |
| `resourceId` | string | The resource ID of the deployed SQL server. |
| `systemAssignedMIPrincipalId` | string | The principal ID of the system assigned identity. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/amavm:res/network/private-endpoint:0.2.0` | Remote reference |

## Notes

### Parameter Usage: `administrators`

Configure Azure Active Directory Authentication method for server administrator.
<https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/administrators?tabs=bicep>

<details>

<summary>Parameter JSON format</summary>

```json
"administrators": {
    "value": {
        "azureADOnlyAuthentication": true,
        "login": "John Doe", // if application can be anything
        "sid": "[[objectId]]", // if application, the object ID
        "principalType" : "User", // options: "User", "Group", "Application"
        "tenantId": "[[tenantId]]"
    }
}
```

</details>

<details>

<summary>Bicep format</summary>

```bicep
administrators: {
    azureADOnlyAuthentication: true
    login: 'John Doe' // if application can be anything
    sid: '[[objectId]]' // if application the object ID
    'principalType' : 'User' // options: 'User' 'Group' 'Application'
    tenantId: '[[tenantId]]'
}
```

</details>
<p>

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
