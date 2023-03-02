@description('The name to use for this Azure Key Vault.')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('The Azure location to create this Key Vault in.')
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

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: keyVaultLocation
  tags: keyVaultTags
  properties: {
    sku: {
      family: 'A'
      name: keyVaultSkuName
    }
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    tenantId: tenant().tenantId
    accessPolicies: []
  }
}

module kvPolicies 'keyVaultAccessPolicies.bicep' = [for i in range(0, length(keyVaultAccessPolicies.identities)): if(keyVaultAddAccessPolicies) {
  name: 'keyvault-policies-${keyVaultAccessPolicies.identities[i].identityName}'
  params: {
    keyVaultName: kv.name
    keyVaultAccessPolicies: keyVaultAccessPolicies.identities[i]
  }
}]

module kvSecrets 'keyVaultSecrets.bicep' = [for i in range(0, length(keyVaultSecrets.secrets)): {
  name: 'keyvault-secret-${keyVaultSecrets.secrets[i].secretName}'
  params: {
    keyVaultName: kv.name
    keyVaultSecretName: keyVaultSecrets.secrets[i].secretName
    keyVaultSecretTags: keyVaultSecrets.secrets[i].tags
  }
}]
