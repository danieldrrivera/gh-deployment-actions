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

@description('An array of IP address ranges that can be used by the Virtual Network.')
param virtualNetworkAddressPrefixes array

@description('An array of IP address ranges that can be used by the subnets. Currently one IP range per subnet')
param virtualNetworkSubnetPrefixes array

@description('An array of subnet names that will be used in the creation of subnets.')
param virtualNetworkSubnetNames array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkName
  location: virtualNetworkLocation
  tags: virtualNetworkTags
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetworkAddressPrefixes
    }
  }
}

module virtualNetworkSubnet 'virtualNetworkSubnet.bicep' = [for i in range(0, length(virtualNetworkSubnetNames)): {
  name: virtualNetworkSubnetNames[i]
  params: {
    virtualNetworkName: virtualNetwork.name
    virtualNetworkSubnetName: virtualNetworkSubnetNames[i]
    virtualNetworkSubnetAddressPrefix: virtualNetworkSubnetPrefixes[i]
  }
}]
