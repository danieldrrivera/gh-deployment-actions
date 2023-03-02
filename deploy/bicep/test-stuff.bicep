// az deployment group what-if \
// az deployment group create \
//   --name myTestDeployment \
//   --resource-group rg-myresourcegroup \
//   --template-file deploy/test-stuff.bicep \
//   --parameters @deploy/test.parameters.json

@description('A list of Access Policies to add to this Key Vault')
param keyVaultAccessPolicies object = {}

resource groupIdentity 'Microsoft.ManagedIdentity/identities@2022-01-31-preview' existing = {
  name: keyVaultAccessPolicies.identities[0].identityName
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: keyVaultAccessPolicies.identities[1].identityName
}

output groupObjectId string = groupIdentity.properties.principalId
output userApplicationId string = userIdentity.properties.clientId
output userObjectId string = userIdentity.properties.principalId
output keyVaultPolicies object = keyVaultAccessPolicies
