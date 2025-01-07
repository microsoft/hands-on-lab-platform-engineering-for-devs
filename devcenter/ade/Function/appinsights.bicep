param name string
param location string = resourceGroup().location
param tags object = {}

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${name}-workspace'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    IngestionMode: 'LogAnalytics'
    WorkspaceResourceId: workspace.id
  }
  tags: tags
}

output instrumentationKey string = applicationInsights.properties.InstrumentationKey
