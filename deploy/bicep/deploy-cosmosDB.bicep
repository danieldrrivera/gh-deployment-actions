// Deploy this template using the following command:
// az deployment group create \
// az deployment group what-if \
//   --name myCDBDeployment \
//   --resource-group rg-myresourcegroup \
//   --template-file deploy/deploy-cosmosDB.bicep \
//   --parameters @deploy/deploy.cosmosDB.parameters.json

@description('The name of the Cosmos DB account. This name must be globally unique.')
@minLength(3)
@maxLength(44)
param cosmosDBAccountName string

@description('The Azure region into which the resources should be deployed.')
param cosmosDBLocation string

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  environment: 'Development'
  department: 'DevOps'
}
''')
param cosmosDBTags object = {}

module cosmosDB '../modules/bicep/cosmosDatabase.bicep' = {
  name: cosmosDBAccountName
  params: {
    cosmosDBAccountName: cosmosDBAccountName
    cosmosDBLocation: cosmosDBLocation
    cosmosDBTags: cosmosDBTags
    environmentType: 'nonprod'
  }
}
