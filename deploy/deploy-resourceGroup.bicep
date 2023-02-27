// Deploy this template using the following command:
// az deployment sub create \
// az deployment sub what-if \
//   --name myRGDeployment \
//   --location eastus \
//   --template-file deploy/deploy-resourceGroup.bicep \
//   --parameters @deploy/deploy.resourceGroup.parameters.json

// The scope that this resource will be deployed to.
targetScope = 'subscription'

@description('The name of the Resource Group to be created.')
@minLength(1)
@maxLength(90)
param resourceGroupName string = 'rg-${uniqueString(subscription().subscriptionId)}'

@description('The Azure region into which the resources should be deployed.')
param resourceGroupLocation string

@description('A flag to indicate whether or not a resource group lock should be created.')
param enableResourceGroupLock bool = false

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  environment: 'Development'
  department: 'DevOps'
}
''')
param resourceGroupTags object = {}

// Create resource group
module resourceGroup '../modules/resourceGroup.bicep' = {
  name: resourceGroupName
  params: {
    resourceGroupName: resourceGroupName
    resourceGroupLocation: resourceGroupLocation
    resourceGroupTags: resourceGroupTags
  }
}

// Create a resource object to the resource group we created
resource existingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if(enableResourceGroupLock) {
  name: resourceGroupName
}

// If enabled, create a resource group lock by passing in the scope of the resource group
module resourceGroupLock '../modules/resourceLock.bicep' = if(enableResourceGroupLock) {
  scope: existingResourceGroup
  name: '${resourceGroupName}-lock'
  params: {
    resourceLockName: '${resourceGroupName}-lock'
  }
}
