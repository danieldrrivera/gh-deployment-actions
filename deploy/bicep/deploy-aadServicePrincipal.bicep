// Deploy this template using the following command:
// az deployment group create \
// az deployment group what-if \
//   --name mySPDeployment \
//   --resource-group rg-myresourcegroup \
//   --template-file deploy/deploy-aadServicePrincipal.bicep \
//   --parameters @deploy/deploy.aadServicePrincipal.parameters.json

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

module devopsServicePrincipal '../../modules/bicep/aadServicePrincipal.bicep' = {
  name: identityName
  params: {
    identityName: identityName
    identityLocation: identityLocation
    identityRoleType: identityRoleType
  }
}
