//-------------------------------
// Required parameters
//-------------------------------
@description('Name of the Managed Identity to deploy.')
param managedIdentityName string
//-------------------------------
// Optional parameters
//-------------------------------
@description('Location of the resource. The default location will be taken over from the resourceGroup.')
param location string = resourceGroup().location
//-------------------------------
// Resources
//-------------------------------
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}
//-------------------------------
// Output
//-------------------------------
output principalId string = managedIdentity.properties.principalId
output managedIdentityName string = managedIdentity.name
output managedIdentityResourceId string = managedIdentity.id
