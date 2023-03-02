// Deploy this template using the following command:
// az deployment group create \
// az deployment group what-if \
  // --name myVNetDeployment \
  // --resource-group rg-myresourcegroup \
  // --template-file deploy/deploy-virtualNetwork.bicep \
  // --parameters @deploy/deploy.virtualNetwork.parameters.json

@description('The name of the Virtual Network to be created.')
@minLength(2)
@maxLength(64)
param virtualNetworkName string

@description('The Azure region into which the resources should be deployed.')
param virtualNetworkLocation string = resourceGroup().location

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  "environment": "Development"
  "department": "DevOps"
}
''')
param virtualNetworkTags object = {}

@description('An array of IP address ranges that can be used by subnets.')
param virtualNetworkAddressPrefixes array

@description('An array of IP address ranges that can be used by the subnets. Currently one IP range per subnet')
param virtualNetworkSubnetPrefixes array

@description('An array of subnet names that will be used in the creation of the subnets.')
param virtualNetworkSubnetNames array

module virtualNetwork '../../modules/bicep/virtualNetwork.bicep' =  {
  name: virtualNetworkName
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkLocation: virtualNetworkLocation
    virtualNetworkTags: virtualNetworkTags
    virtualNetworkAddressPrefixes: virtualNetworkAddressPrefixes
    virtualNetworkSubnetPrefixes: virtualNetworkSubnetPrefixes
    virtualNetworkSubnetNames: virtualNetworkSubnetNames
  }
}
