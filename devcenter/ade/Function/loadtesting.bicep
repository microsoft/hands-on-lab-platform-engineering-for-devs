param name string
param location string = resourceGroup().location
param tags object = {}

resource loadtesting 'Microsoft.LoadTestService/loadTests@2022-12-01' = {
  name: name
  location: location
  tags: tags
}

