targetScope = 'resourceGroup'

@description('Name of Dev Center')
@minLength(3)
@maxLength(26)
param resourceName string

param locationName string = resourceGroup().location

param projectName string

// DevCenter
resource devcenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: resourceName
  location: locationName
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

module project './projects/main.bicep' = {
  name: guid('project')
  params: {
    locationName: locationName
    resourceName: projectName
    devcenterId: devcenter.id
  }
}
