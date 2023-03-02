//
// TODO - How to RBAC AD Groups
//

@description('The name of the Key Vault to add Access Policies to.')
param keyVaultName string

@description('''
An object specifying a single identity and list of 
access policies to add to this Key Vault as show here:
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
''')
param keyVaultAccessPolicies object

resource existingKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: keyVaultAccessPolicies.identityName
}

resource kvAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: existingKeyVault
  properties: {
    accessPolicies: [
      {
        applicationId: userIdentity.properties.clientId
        objectId: userIdentity.properties.principalId
        permissions: keyVaultAccessPolicies.permissions
        tenantId: tenant().tenantId
      }
    ]
  }
}
