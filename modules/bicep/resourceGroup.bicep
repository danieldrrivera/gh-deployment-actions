// The scope that this resource will be deployed to.
targetScope = 'subscription'

@description('The name of the Resource Group to be created.')
@minLength(1)
@maxLength(90)
param resourceGroupName string = 'rg-${uniqueString(subscription().subscriptionId)}'

@description('The Azure region into which the resources should be deployed.')
param resourceGroupLocation string

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  "environment": "Development"
  "department": "DevOps"
}
''')
param resourceGroupTags object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: resourceGroupTags
}
