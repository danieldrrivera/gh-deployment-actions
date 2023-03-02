// Deploy this template using the following command:
// az deployment group create \
// az deployment group what-if \
//   --name myASDeployment \
//   --resource-group rg-myresourcegroup \
//   --template-file deploy/deploy-appService.bicep \
//   --parameters @deploy/deploy.appService.parameters.json

@description('The name of the App Service to create.')
@minLength(2)
@maxLength(60)
param appServiceName string

@description('The Azure region into which the resources should be deployed.')
param appServiceLocation string = resourceGroup().location

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  environment: 'Development'
  department: 'DevOps'
}
''')
param appServiceTags object = {}

@description('''
An object specifying the app service plan sku information as show here:
{
  appServicePlanSkuTier: 'Free'
  appServicePlanSkuCode: 'F1'
  appServicePlanKind: 'linux'
}
''')
param appServicePlanDetails object

@description('''
An object specifying the source control parameters to 
obtain the source code for the app service as show here:
{
  sourceControlUrl: 'https://github.com/danieldrrivera/azure-web-app.git'
  sourceControlBranch: 'main'
  sourecControlManualIntegration: true
}
''')
param appServiceSourceControl object

module appService '../modules/bicep/appService.bicep' = {
  name: appServiceName
  params: {
    appServiceName: appServiceName
    appServiceLocation: appServiceLocation
    appServiceTags: appServiceTags
    appServiceSourceControl: appServiceSourceControl
    appServicePlanDetails: appServicePlanDetails
  }
}
