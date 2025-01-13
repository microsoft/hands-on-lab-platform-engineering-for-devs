// ------
// Scopes
// ------

targetScope = 'resourceGroup'

@description('Name of Dev Center')
@minLength(3)
@maxLength(26)
param devCenterName string

param location string = resourceGroup().location

// DevCenter
resource devcenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: devCenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}
