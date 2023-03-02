// Deploy this template using the following command:
// az deployment group create \
//   --name myCRDeployment \
//   --resource-group rg-myresourcegroup \
//   --template-file deploy/deploy-containerRegistry.bicep \
//   --parameters @deploy/deploy.containerRegistry.parameters.json

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

module containerRegistry '../../modules/bicep/containerRegistry.bicep' = {
  name: containerRegistryName
  params: {
    containerRegistryLocation: containerRegistryLocation
    containerRegistryName: containerRegistryName
    containerRegistrySkuName: containerRegistrySkuName
    containerRegistryTags: containerRegistryTags
  }
}
