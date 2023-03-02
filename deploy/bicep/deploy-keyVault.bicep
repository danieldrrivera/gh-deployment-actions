// Deploy this template using the following command:
// az deployment group create \
// az deployment group what-if \
//   --name myKVDeployment \
//   --resource-group rg-myresourcegroup \
//   --template-file deploy/deploy-keyVault.bicep \
//   --parameters @deploy/deploy.keyVault.parameters.json

@description('The name to use for this Azure Key Vault.')
@minLength(3)
@maxLength(24)
param keyVaultName string = 'kv-myvault'

@description('The Azure region into which the resources should be deployed.')
param keyVaultLocation string = resourceGroup().location

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  environment: 'Development'
  department: 'DevOps'
}
''')
param keyVaultTags object = {}

@description('The properties for this Key Vault.')
@allowed([
  'standard'
  'premium'
])
param keyVaultSkuName string = 'standard'

@description('A flag to indicate if you will be adding Access Policies to this Key Vault')
param keyVaultAddAccessPolicies bool = false

@description('''
An array specifying the identities and list of access policies
per identity to add to this Key Vault as show here:
"identities": [
  {
      "identityName": "DevOpsDeployer",
      "permissions": {
          "certificates": [
              "all"
          ],
          "keys": [
              "all"
          ],
          "secrets": [
              "all"
          ],
          "storage": [
              "all"
          ]
      }
  }
]
''')
param keyVaultAccessPolicies object

@description('''
An array specifying the secret names to create and
list of access tags for the secret to add to this 
Key Vault as show here:
"secrets": [
  {
    "secretName": "vmAdminPassword",
    "tags": {
      "environment": "Development",
      "department": "DevOps"
    }
  },
  {
    "secretName": "sqlAdminPassword",
    "tags": {
      "environment": "Development",
      "department": "DevOps"
    }
  }
]
''')
param keyVaultSecrets object

module keyVault '../../modules/keyVault.bicep' = {
  name: keyVaultName
  params: {
    keyVaultName: keyVaultName
    keyVaultLocation: keyVaultLocation
    keyVaultTags: keyVaultTags
    keyVaultSkuName: keyVaultSkuName
    keyVaultAddAccessPolicies: keyVaultAddAccessPolicies
    keyVaultAccessPolicies: keyVaultAccessPolicies
    keyVaultSecrets: keyVaultSecrets
  }
}
