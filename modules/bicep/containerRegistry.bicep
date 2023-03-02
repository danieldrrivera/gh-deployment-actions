@description('The name to use for this Azure Container Registry')
@minLength(5)
@maxLength(50)
param containerRegistryName string

@description('The Azure location to create this Container Registry in.')
param containerRegistryLocation string = resourceGroup().location

@description('The SKU name for the container registry.')
@allowed([
  'Basic'
  'Classic'
  'Premium'
  'Standard'
])
param containerRegistrySkuName string = 'Basic'

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  "environment": "Development"
  "department": "DevOps"
}
''')
param containerRegistryTags object = {}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerRegistryName
  location: containerRegistryLocation
  tags: containerRegistryTags
  sku: {
    name: containerRegistrySkuName
  }
}
