param location string = resourceGroup().location
param containerRegistryBaseName string = 'crs001'

var containerRegistryName = '${containerRegistryBaseName}${uniqueString(resourceGroup().id)}'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}
