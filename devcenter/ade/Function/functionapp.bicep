param name string
param hostingPlanName string
param storageAccountName string
param appInsightsInstrumentationKey string
param location string = resourceGroup().location
param tags object = {}
param azdServiceName string
param runtimeName string
param runtimeVersion string
param runtimeNameAndVersion string = '${runtimeName}|${runtimeVersion}'
param linuxFxVersion string = runtimeNameAndVersion
param extensionVersion string = '~4'
param environmentVariables array = []

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
  tags: tags
}

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    reserved: true
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: union([
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: extensionVersion
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'ENABLE_ORYX_BUILD'
          value: 'true'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtimeName
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: guid(name)
        }
      ], environmentVariables)
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
    }
    httpsOnly: true
  }
  tags: union(tags, { 'azd-service-name': azdServiceName })
}

output principalId string = functionApp.identity.principalId
