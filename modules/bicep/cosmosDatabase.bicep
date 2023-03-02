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

@description('The type of environment. This must be nonprod or prod.')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var cosmosDBDatabaseName = 'ProductCatalog'
var cosmosDBDatabaseThroughput = (environmentType == 'prod') ? 1000 : 400
var cosmosDBContainerName = 'Products'
var cosmosDBContainerPartitionKey = '/productid'

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: cosmosDBAccountName
  location: cosmosDBLocation
  tags: cosmosDBTags
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: cosmosDBLocation
      }
    ]
  }
}

resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  parent: cosmosDBAccount
  name: cosmosDBDatabaseName
  properties: {
    resource: {
      id: cosmosDBDatabaseName
    }
    options: {
      throughput: cosmosDBDatabaseThroughput
    }
  }

  resource container 'containers' = {
    name: cosmosDBContainerName
    properties: {
      resource: {
        id: cosmosDBContainerName
        partitionKey: {
          kind: 'Hash'
          paths: [
            cosmosDBContainerPartitionKey
          ]
        }
      }
      options: {}
    }
  }
}
