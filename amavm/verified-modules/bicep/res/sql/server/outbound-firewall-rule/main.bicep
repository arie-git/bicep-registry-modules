metadata name = 'Azure SQL Server Outbound Firewall Rule'
metadata description = 'This module deploys an Azure SQL Server Outbound Firewall Rule.'
metadata owner = 'AMCCC'
metadata compliance = 'inherited from parent'
metadata complianceVersion = '20260309'

@description('Required. Fully-qualified domain name that the SQL Server will be allowed to access when outbound networking restrictions are enabled.')
param name string

@description('Conditional. The name of the SQL Server. Required if the template is used in a standalone deployment.')
param serverName string

resource server 'Microsoft.Sql/servers@2023-08-01' existing = {
  name: serverName
}

resource firewallRule 'Microsoft.Sql/servers/outboundFirewallRules@2023-08-01' = {
  name: name
  parent: server
}

@description('The name of the deployed firewall rule.')
output name string = firewallRule.name

@description('The resource ID of the deployed firewall rule.')
output resourceId string = firewallRule.id

@description('The resource group of the deployed firewall rule.')
output resourceGroupName string = resourceGroup().name

// =============== //
//   Definitions   //
// =============== //

@export()
type outboundFirewallRuleType = {
  @description('Required. Fully-qualified domain name that the SQL Server will be allowed to access when outbound networking restrictions are enabled.')
  name: string
}

@description('Evidence of non-compliance (inherited from parent).')
output evidenceOfNonCompliance bool = false
