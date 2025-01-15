targetScope = 'resourceGroup'

@description('Name of Dev Center')
@minLength(3)
@maxLength(26)
param resourceName string

param location string = resourceGroup().location

param projectName string

// DevCenter
resource devcenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: resourceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

module project './projects/main.bicep' = {
  name: guid('project')
  params: {
    location: location
    resourceName: projectName
    devcenterId: devcenter.id
  }
}

module definition1 './definitions/main.bicep' = {
  name: 'WebDevBoxDefinition'
  params: {
    location: location
    definitionName: 'WebDevBoxDefinition'
    devcenterName: devcenter.name
    image: 'vs-22-ent-win-11-m365'
    sku: '8-vcpu-32gb-ram-256-ssd'
  }
}

module definition2 './definitions/main.bicep' = {
  name: 'SuperPowerfulDevBoxDefinition'
  params: {
    location: location
    definitionName: 'SuperPowerfulDevBoxDefinition'
    devcenterName: devcenter.name
    image: 'vs-22-ent-win-11-m365'
    sku: '32-vcpu-128gb-ram-2048-ssd'
  }
}
