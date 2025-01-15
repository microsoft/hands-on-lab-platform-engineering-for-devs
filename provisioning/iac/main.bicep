targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string = 'rg-plateng-for-devs'

@description('Name of Dev Center')
@minLength(3)
@maxLength(20)
param devCenterName string = 'web-dev-center'

@description('Name of Project associated with Dev Center')
@minLength(3)
@maxLength(63)
param projectName string = 'frontend-project'

@description('Name of Environment Type associated with Dev Center and Project')
@minLength(3)
@maxLength(63)
param environmentTypeName string = 'DEV'

var location = deployment().location
var guidSeed = guid(location, resourceGroupName, devCenterName, projectName, environmentTypeName)

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}


module keyvault './modules/keyvault/main.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: guid('keyvault', guidSeed)
  dependsOn: [
    resourceGroup
  ]
  params: {
    location: location
    resourceName: devCenterName
  }
}


module devcenter './modules/devcenter/main.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: guid('devcenter', guidSeed)
  dependsOn: [
    resourceGroup
    keyvault
  ]
  params: {
    location: location
    resourceName: devCenterName
    projectName: projectName
    // projectName: projectName
    // environmentTypeName: environmentTypeName
    // guidSeed: guidSeed
  }
}
