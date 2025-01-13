param resourceName string

param locationName string = resourceGroup().location

param devcenterId string


resource projects 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: resourceName
  location: locationName
  properties: {
    devCenterId: devcenterId
    description: 'lorem ipsum'
  }
}
