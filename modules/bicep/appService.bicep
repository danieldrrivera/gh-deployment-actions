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

var appServicePlanName = '${appServiceName}-ASP'

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  location: appServiceLocation
  tags: appServiceTags
  properties: {
    serverFarmId: appServicePlan.outputs.appServicePlanId
  }
}

module appServicePlan 'appServicePlan.bicep' = {
  name: appServicePlanName
  params: {
    appServicPlanName: appServicePlanName
    appServicePlanLocation: appServiceLocation
    appServicePlanDetails: appServicePlanDetails
  }
}

resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: 'web'
  parent: appService
  properties: {
    repoUrl: appServiceSourceControl.sourceControlUrl
    branch: appServiceSourceControl.sourceControlBranch
    isManualIntegration: appServiceSourceControl.sourecControlManualIntegration
  }
}
