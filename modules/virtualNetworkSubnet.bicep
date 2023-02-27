@description('The name of the existing Virtual Network to associate this subnet to.')
param virtualNetworkName string

@description('The name of the Subnet to be created.')
@minLength(1)
@maxLength(80)
param virtualNetworkSubnetName string

@description('The address prefix for the Subnet.')
param virtualNetworkSubnetAddressPrefix string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: virtualNetworkName
}

resource virtualNetworkSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: virtualNetworkSubnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: virtualNetworkSubnetAddressPrefix
  }
  // The dependsOn attribute is needed in order to prevent deployment from failing on subnet creation
  // The subnets attempt to get created before the Virtual Network is finished being created.
  dependsOn: [
    virtualNetwork
  ]
}
