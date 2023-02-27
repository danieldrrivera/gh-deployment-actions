@description('The name of the Key Vault to add Secrets to.')
param keyVaultName string

@description('The name of the Secret to create.')
@minLength(1)
@maxLength(127)
param keyVaultSecretName string

@description('The value for the Key Vault Secret being created. The value is defaulted to the value of newGuid().')
@secure()
param keyVaultSecretValue string = newGuid() 

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  "environment": "Development"
  "department": "DevOps"
}
''')
param keyVaultSecretTags object = {}

resource existingKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: keyVaultSecretName
  tags: keyVaultSecretTags
  parent: existingKeyVault
  properties: {
    attributes: {
      enabled: true
    }
    value: keyVaultSecretValue
  } 
}
