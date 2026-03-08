@description('Required. The name of the parent registry. Required if the template is used in a standalone deployment.')
param registryName string

@description('Optional. The name of the credentail.')
param name string

@allowed([
  'docker.io'
  'quay.io'
  'ghcr.io'
])
@description('Required. The login server of your source registry.')
param loginServer string

@description('Required. KeyVault Secret URI for accessing the username.')
param kvUserNameSecretUri string

@description('Required. KeyVault Secret URI for accessing the password.')
param kvPwdSecretUri string

#disable-next-line use-recent-api-versions
resource registry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: registryName
}

#disable-next-line use-recent-api-versions
resource credentialSetResource 'Microsoft.ContainerRegistry/registries/credentialSets@2023-01-01-preview' = {
  name: name
  parent: registry
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    loginServer: loginServer
    authCredentials: [
      {
        name: 'Credential1'
        passwordSecretIdentifier: kvUserNameSecretUri
        usernameSecretIdentifier: kvPwdSecretUri
      }
    ]
  }
}


@description('The Name of the Cache Rule.')
output name string = credentialSetResource.name

@description('The name of the Cache Rule.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the Cache Rule.')
output resourceId string = credentialSetResource.id

@export()
@description('Describes how to create credentials to store the username and password in Key Vault’s secrets for your source registry.')
type credentialType = {
  @description('Required. The name of the credential.')
  name: string

  @description('Required. The login server of your source registry.')
  loginServer: ('docker.io' | 'quay.io' | 'ghcr.io')

  @description('Required. KeyVault Secret URI for accessing the password.')
  passwordSecretIdentifier: string

  @description('Required. KeyVault Secret URI for accessing the username.')
  usernameSecretIdentifier: string
}
