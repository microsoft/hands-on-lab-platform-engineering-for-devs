@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param name string = ''

@minLength(1)
@description('Location to deploy the environment resources')
param location string = resourceGroup().location

var environmentName = !empty(name) ? replace(name, ' ', '-') : 'env-${uniqueString(resourceGroup().id)}'
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

var prefix = '${name}-${resourceToken}'

module storageAccount './storageaccount.bicep' = {
  name: 'storageAccount'
  params: {
    name: '${toLower(take(replace(prefix, '-', ''), 17))}storage'
    location: location
    tags: tags
  }
}

module apiFunctionApp './functionapp.bicep' = {
  name: 'api-func'
  params: {
    name: '${prefix}-api-func'
    hostingPlanName: '${prefix}-plan'
    location: location
    runtimeName: 'node'
    runtimeVersion: '20'
    azdServiceName: 'api'
    storageAccountName: storageAccount.outputs.storageAccountName
    appInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    tags: tags
    environmentVariables: [
      {
        name: 'RELEASE'
        value: '1'
      }
    ]
  }
}

module applicationInsights './appinsights.bicep' = {
  name: 'appinsights'
  params: {
    name: '${prefix}-insights'
    location: location
    tags: tags
  }
}

module loadTesting './loadtesting.bicep' = {
  name: 'loadtesting'
  params: {
    name: '${prefix}-load'
    location: location
    tags: tags
  }
}
