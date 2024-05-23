param location string = resourceGroup().location
param keyVaultName string = 'kv-w001-${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    //vaultUri: 'https://${vaults_kv_w001_rbf6xriugto5s_name}.vault.azure.net/'
    //provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

output keyVaultName string = keyVault.name
