@description('The name of the App Service to create.')
@minLength(1)
@maxLength(15)
param appServicPlanName string

@description('The Azure region into which the resources should be deployed.')
param appServicePlanLocation string = resourceGroup().location

@description('''
An object specifying the app service plan sku information as show here:
{
  appServicePlanSkuTier: 'Free'
  appServicePlanSkuCode: 'F1'
  appServicePlanKind: 'linux'
}
''')
param appServicePlanDetails object

/// TODO - Troubleshoot kinds attribute not being set based on input provided
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicPlanName
  location: appServicePlanLocation
  kind: appServicePlanDetails.appServicePlanKind
  sku: {
    tier: appServicePlanDetails.appServicePlanSkuTier
    name: appServicePlanDetails.appServicePlanSkuCode
  }
}

output appServicePlanId string = appServicePlan.id
