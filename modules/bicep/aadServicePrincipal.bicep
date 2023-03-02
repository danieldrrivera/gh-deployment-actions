@description('The name of the Managed Identity being created.')
@minLength(3)
@maxLength(128)
param identityName string

@description('The Azure region into which the resources should be deployed.')
param identityLocation string = resourceGroup().location

@description('The built-in role to assign')
@allowed([
  'Owner'
  'Contributor'
  'Reader'
])
param identityRoleType string

var identityRoleDefinitionId = {
  Owner: {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  }
  Contributor: {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  }
  Reader: {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  }
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: identityName
  location: identityLocation
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, identityName, identityLocation, identityRoleDefinitionId[identityRoleType].id)
  properties: {
    principalId: userIdentity.properties.principalId
    roleDefinitionId: identityRoleDefinitionId[identityRoleType].id
    principalType: 'ServicePrincipal'
  }
}
