@description('The name of the Virtual Network')
param vnetName string = 'vnet'

@description('the app subnet name of Dev Box')
param subnetName string = 'subnet'

@description('The address prefixes of the vnet')
param vnetAddressPrefixes string = '10.4.0.0/16'

@description('The subnet address prefixes for Dev Box')
param subnetAddressPrefixes string = '10.4.0.0/24'

@description('The location of the resource')
param location string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixes
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefixes
        }
      }
    ]
  }

  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

output vnetName string = virtualNetwork.name
output subnetName string = virtualNetwork::subnet.name
output subnetId string = virtualNetwork::subnet.id
