// ============== //
//   Parameters   //
// ============== //
@description('Required. The name of the Key Vault to set the secrets in.')
param keyVaultName string

@description('Required. The secrets to set in the Key Vault.')
param secretsToSet secretToSetType[]

// ============= //
//   Resources   //
// ============= //
resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

resource secrets 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = [
  for secret in secretsToSet: {
    name: secret.name
    parent: keyVault
    properties: {
      value: secret.value
    }
  }
]

// =========== //
//   Outputs   //
// =========== //
@description('The references to the secrets exported to the provided Key Vault.')
output secretsSet secretSetOutputType[] = [
  #disable-next-line outputs-should-not-contain-secrets // Only returning the references, not a secret value
  for index in range(0, length(secretsToSet ?? [])): {
    secretResourceId: secrets[index].id
    secretUri: secrets[index].properties.secretUri
    secretUriWithVersion: secrets[index].properties.secretUriWithVersion
  }
]

// =============== //
//   Definitions   //
// =============== //

type secretToSetType = {
  @description('Required. The name of the secret.')
  name: string

  @secure()
  @description('Required. The value of the secret.')
  value: string
}

type secretSetOutputType = {
  @description('The resource ID of the secret.')
  secretResourceId: string

  @description('The URI of the secret.')
  secretUri: string

  @description('The URI of the secret with version.')
  secretUriWithVersion: string
}
