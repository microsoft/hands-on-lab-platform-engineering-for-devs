@minLength(2)
@description('The location to use for the deployment. defaults to Resource Groups location.')
param locationName string = resourceGroup().location

@minLength(3)
@maxLength(20)
@description('Used to name all resources')
param resourceName string

var akvRawName = 'kv-${replace(resourceName, '-', '')}-${uniqueString(resourceGroup().id, resourceName)}'
var akvName = length(akvRawName) > 24 ? substring(akvRawName, 0, 24) : akvRawName

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: akvName
  location: locationName
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    publicNetworkAccess: 'enabled'

    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    enablePurgeProtection: true
  }
}

output keyVaultName string = kv.name
output keyVaultId string = kv.id
