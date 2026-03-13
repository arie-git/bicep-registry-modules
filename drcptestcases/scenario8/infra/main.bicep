// Scenario 8 — PostgreSQL + Service Bus (message-driven processing)
// Demonstrates: PostgreSQL Flexible Server (Entra-only, VNet-integrated), Service Bus (Premium, PE),
//               Function App with Service Bus trigger writing to PostgreSQL via managed identity.
// DRCP policies: 11 PostgreSQL + 5 Service Bus = 16 total

targetScope = 'subscription'

// general parameters
param location string = deployment().location
param tags object = {}

param deploymentId string = ''
#disable-next-line no-unused-params
param whatIf string = ''

// APG ServiceNow registrations
param applicationId string = 'AM-CCC'
param environmentId string

// Parts used in naming convention
param namePrefix string = ''
@maxLength(2)
param organizationCode string = 's2'
@maxLength(3)
param departmentCode string = 'c3'
param applicationCode string = 'drcptst'
@maxLength(4)
param applicationInstanceCode string = '0801'
param systemCode string = ''
@maxLength(2)
param systemInstanceCode string = ''
@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentType string = 'dev'

// System-specific parameters
@description('CIDR prefix for the virtual network. Needs a /26 prefix (3 subnets)')
param networkAddressSpace string = ''
@description('AAD group object id for the engineering group')
param engineersGroupObjectId string = ''

@description('PostgreSQL database name')
param postgresqlDatabaseName string = 'ordersdb'

var mytags = union(tags, {
  environmentId: environmentId
  applicationId: applicationId
  businessUnit: organizationCode
  purpose: '${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}'
  environmentType: environmentType
  deploymentPipelineId: deploymentId
})

var isDevEnvironment = !(environmentType == 'prd' || environmentType == 'acc' || environmentType == 'tst')

var vnetResourceGroupName = '${applicationId}-${environmentId}-VirtualNetworks'
var vnetName = '${applicationId}-${environmentId}-VirtualNetwork'

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: az.resourceGroup(vnetResourceGroupName)
}

var effectiveNetworkSpace = (networkAddressSpace != '') ? networkAddressSpace : vNet.properties.addressSpace.addressPrefixes[0]

var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: mytags
}

module names 'br/amavm:utl/amavm/naming:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-names'
  params: {
    prefix: namePrefix
    organization: organizationCode
    department: departmentCode
    workload: '${applicationCode}${applicationInstanceCode}'
    role: systemCode
    roleIndex: systemInstanceCode
    environment: environmentType
    location: location
  }
}

// --------------------------------------------------
//
// Networking
//  - NSG, Route Table
//  - Subnet-In (private endpoints for Service Bus, KV, Storage)
//  - Subnet-Out (Function App VNet integration)
//  - Subnet-Pg (PostgreSQL VNet-delegated)
//
// --------------------------------------------------

var subnetsName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
var privateEndpointsName = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
    location: vNet.location
    tags: mytags
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
}

module udr 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: names.outputs.namingConvention['Microsoft.Network/routeTables']
    location: vNet.location
    tags: mytags
  }
}

// Subnet for private endpoints (Service Bus, Key Vault, Storage)
module subnetIn 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet-pe'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsName}-In'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
}

// Subnet for Function App egress (VNet integration)
module subnetOut 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet-func'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsName}-Out'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      delegations: [
        {
          name: 'Microsoft.Web.serverFarms'
          type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
        }
      ]
    }
  }
  dependsOn: [ subnetIn ]
}

// Subnet for PostgreSQL Flexible Server (VNet-delegated — DRCP requires VNet integration, not PE)
module subnetPg 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet-pg'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsName}-Pg'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 2)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      delegations: [
        {
          name: 'Microsoft.DBforPostgreSQL.flexibleServers'
          type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
          properties: {
            serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        }
      ]
    }
  }
  dependsOn: [ subnetOut ]
}

// --------------------------------------------------
//
// Logging
//  - Log Analytics workspace
//  - Application Insights
//
// --------------------------------------------------

var logAnalyticsWorkspaceName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-laworkspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: mytags
  }
}

var applicationInsightsName = names.outputs.namingConvention['Microsoft.Insights/components']
module applicationInsights 'br/amavm:res/insights/component:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appinsights'
  params: {
    location: location
    name: applicationInsightsName
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    applicationType: 'web'
    kind: 'web'
    tags: mytags
  }
}

// --------------------------------------------------
//
// Key Vault
//
// --------------------------------------------------

var keyVaultName = names.outputs.namingConvention['Microsoft.KeyVault/vaults']
module keyVault 'br/amavm:res/key-vault/vault:0.3.0' = {
  scope: resourceGroup
  name: '${deployment().name}-keyvault'
  params: {
    name: keyVaultName
    enablePurgeProtection: !isDevEnvironment
    softDeleteRetentionInDays: 7
    networkAcls: {
      bypass: 'AzureServices'
    }
    publicNetworkAccess: 'Disabled'
    privateEndpoints: [
      {
        name: '${privateEndpointsName}-kv'
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'vault'
        tags: mytags
      }
    ]
    diagnosticSettings: [
      {
        name: '${keyVaultName}-diagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    roleAssignments: isDevEnvironment ? [
      {
        principalId: engineersGroupObjectId
        roleDefinitionIdOrName: '00482a5a-887f-4fb3-b363-3b7fe8e74483' // KeyVault Admin
        principalType: 'Group'
      }
    ] : []
  }
  dependsOn: [ subnetPg ]
}

// --------------------------------------------------
//
// Storage Account (Function App backing storage)
//
// --------------------------------------------------

var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']
module storageAccount 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    name: storageAccountName
    location: location
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    networkAcls: {
      bypass: 'None'
    }
    roleAssignments: isDevEnvironment ? [
      {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
    ] : []
    privateEndpoints: [
      {
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'blob'
        name: '${privateEndpointsName}-sta-blob'
      }
      {
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'file'
        name: '${privateEndpointsName}-sta-file'
      }
    ]
    blobServices: {
      diagnosticSettings: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    fileServices: {
      diagnosticSettings: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: mytags
  }
  dependsOn: [ subnetPg ]
}

// --------------------------------------------------
//
// PostgreSQL Flexible Server
//  DRCP policies: Entra-only auth, VNet-delegated, TLS 1.2,
//  v17+, zone redundant, service-managed encryption, Defender
//
// --------------------------------------------------

var postgresqlName = names.outputs.namingConvention['Microsoft.DBforPostgreSQL/servers']
module postgresqlServer 'br/amavm:res/db-for-postgre-sql/flexible-server:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-postgresql'
  params: {
    name: postgresqlName
    location: location
    tags: mytags

    // Compute
    skuName: 'Standard_D2s_v3'
    tier: 'GeneralPurpose'
    availabilityZone: 1
    storageSizeGB: 32

    // Auth — Entra-only (drcp-pgsql-auth: passwordAuth=Disabled, activeDirectoryAuth=Enabled)
    // AMAVM defaults: { activeDirectoryAuth: 'Enabled', passwordAuth: 'Disabled' }

    // Version — v17 (drcp-pgsql-version: >= 16)
    // AMAVM default: '17'

    // HA — zone redundant (drcp-pgsql-ha)
    // AMAVM default: 'ZoneRedundant'
    highAvailabilityZone: 2

    // Network — VNet-delegated (drcp-pgsql-network: delegatedSubnetResourceId + privateDnsZone required)
    delegatedSubnetResourceId: subnetPg.outputs.resourceId
    // privateDnsZoneArmResourceId uses AMAVM default (Azure public DNS)
    publicNetworkAccess: 'Disabled'

    // Encryption — service-managed (drcp-pgsql-encryption: NOT AzureKeyVault)
    // No CMK = service-managed by default

    // Backup
    backupRetentionDays: 7
    geoRedundantBackup: isDevEnvironment ? 'Disabled' : 'Enabled'

    // TLS + SSL enforced via AMAVM default configurations:
    //   require_secure_transport = 'ON' (drcp-pgsql-ssl)
    //   ssl_min_protocol_version = 'TLSv1.2' (drcp-pgsql-tls)

    // Defender (drcp-pgsql-defender)
    // AMAVM default: serverThreatProtection = 'Enabled'

    // Database
    databases: [
      {
        name: postgresqlDatabaseName
        charset: 'UTF8'
        collation: 'en_US.utf8'
      }
    ]

    // Diagnostics
    diagnosticSettings: [
      {
        name: '${postgresqlName}-diagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]

    // RBAC — Engineers group as Entra admin (must be in drcp-psql-03 allowedPrincipalNames)
    administrators: [
      {
        objectId: engineersGroupObjectId
        principalName: 'F-DRCP-${applicationId}-${environmentId}-Engineer-001-ASG'
        principalType: 'Group'
      }
    ]
  }
}

// --------------------------------------------------
//
// Service Bus Namespace (Premium — required for PE)
//  DRCP policies: disableLocalAuth, publicNetworkAccess=Disabled,
//  TLS 1.2, same-sub PE, auto DNS zone
//
// --------------------------------------------------

var serviceBusName = names.outputs.namingConvention['Microsoft.ServiceBus/namespaces']
module serviceBusNamespace 'br/amavm:res/service-bus/namespace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-servicebus'
  params: {
    name: serviceBusName
    location: location
    tags: mytags

    // SKU — Premium required for PE and zone redundancy
    // AMAVM defaults: { name: 'Premium', capacity: 2 }, zoneRedundant: true

    // Auth — Entra-only (drcp-sb-auth: disableLocalAuth=true)
    // AMAVM default: disableLocalAuth = true

    // Network (drcp-sb-network: publicNetworkAccess=Disabled)
    // AMAVM default: publicNetworkAccess = 'Disabled'

    // TLS (drcp-sb-tls: minimumTlsVersion=1.2)
    // AMAVM default: minimumTlsVersion = '1.2'

    // Private endpoint (drcp-sb-pe: same subscription)
    privateEndpoints: [
      {
        name: '${privateEndpointsName}-sb'
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'namespace'
        tags: mytags
      }
    ]

    // Queues — order processing
    queues: [
      {
        name: 'orders'
        maxMessageSizeInKilobytes: 1024
        maxSizeInMegabytes: 1024
        deadLetteringOnMessageExpiration: true
        maxDeliveryCount: 5
      }
    ]

    // Topics — event broadcasting
    topics: [
      {
        name: 'events'
        maxMessageSizeInKilobytes: 1024
        maxSizeInMegabytes: 1024
      }
    ]

    // Diagnostics
    diagnosticSettings: [
      {
        name: '${serviceBusName}-diagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]

    // RBAC — Function App MI gets Data Receiver for queue trigger
    roleAssignments: [
      {
        principalId: functionApp.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Azure Service Bus Data Receiver'  // Queue trigger
      }
    ]
  }
  dependsOn: [ subnetPg ]
}

// --------------------------------------------------
//
// Function App (Service Bus trigger → PostgreSQL writer)
//
// --------------------------------------------------

var aspName = names.outputs.namingConvention['Microsoft.Web/serverfarms']
module appServicePlan 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-asp'
  params: {
    name: aspName
    location: location
    kind: 'Linux'
    skuName: 'S1'
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: mytags
  }
}

var functionAppName = names.outputs.namingConvention['Microsoft.Web/sites']
module functionApp 'br/amavm:res/web/site:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-func'
  params: {
    name: functionAppName
    location: location
    kind: 'functionapp,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    storageAccountResourceId: storageAccount.outputs.resourceId
    virtualNetworkSubnetId: subnetOut.outputs.resourceId
    outboundVnetRouting: {
      allTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }

    privateEndpoints: [
      {
        name: '${privateEndpointsName}-func'
        subnetResourceId: subnetIn.outputs.resourceId
      }
    ]

    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]

    appInsightResourceId: applicationInsights.outputs.resourceId

    // Runtime config
    netFrameworkVersion: 'v8.0'
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'

      // Service Bus — identity-based connection (no SAS keys)
      ServiceBusConnection__fullyQualifiedNamespace: '${serviceBusName}.servicebus.windows.net'

      // PostgreSQL — Entra token auth (constructed FQDN to avoid circular dependency)
      PostgreSqlHost: '${postgresqlName}.postgres.database.azure.com'
      PostgreSqlDatabase: postgresqlDatabaseName
    }

    tags: mytags
  }
}

// --------------------------------------------------
// Outputs
// --------------------------------------------------

output resourceGroupName string = resourceGroup.name
output functionAppName string = functionApp.outputs.name
output postgresqlFqdn string = '${postgresqlName}.postgres.database.azure.com'
output serviceBusNamespaceName string = serviceBusNamespace.outputs.name
