param resourceName string

param location string = resourceGroup().location

param devcenterId string


resource projects 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: resourceName
  location: location
  properties: {
    devCenterId: devcenterId
    description: 'lorem ipsum'
  }
}
