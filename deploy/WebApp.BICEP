@description('SKU vaule')
@allowed([
  'S1'
  'P1'
  'S2'
  'S3'
  'P2'
  'P3'
  'P4'
])
param sku string = 'S1' // The SKU of App Service Plan
// param linuxFxVersion string = 'node|14-lts' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources
// param repositoryUrl string = 'https://github.com/Azure-Samples/nodejs-docs-hello-world'
// param branch string = 'master'

@description('App OS')
@allowed([
  'linux'
  'app'
  'windows'
])
param AppOS string = 'windows'

@description('The VNet Name where the Key Vault Private Link is to be created')
param PLvnetName string = 'test'

@description('The VNet Resource Group Name where the Key Vault Private Link is to be created')
param PLvnetResourceGroupName string = 'rg-myresourcegroup'

@description('The VNet Resource Group Name where the Key Vault Private Link is to be created')
param vnetIntegrationResourceGroupName string = 'rg-myresourcegroup'

@description('The SubnetName Name where the Key Vault Private Link is to be created')
param PLSubnetName string = 'test'

param SubscriptionID string = subscription().subscriptionId

param privateDNSSubscriptionID string = subscription().subscriptionId

param privateDNSRG string = 'khaz-eus2-rg-infra-network-dns-001-prod'

@description('The name of the Key Vault private link endpoint')
param webappPleName string = 'khaz-eus2-rg-infra-network-dns-001-prod'

param appvirtualNetwork string = 'KHAZ-EUS2-CCOE-NONPROD-VNET-001_10.13.108.0_22'

param appsubnet2Name string = 'KHAZ-EUS2-CCOE-0001-NONPROD-SNET-APP-001_10.13.109.48_28'

param webSiteName string = 'testwebsite'

param appServicePlanName string = 'test'

param existingASP string = ''

param ResourceGroupName string = 'rg-myresourcegroup'


var webappPrivateEndpointName = webappPleName
var isReserved = (AppOS == 'linux') ? true : false
var webappPrivateEndpointGroupName = 'sites'
var webappPrivateDnsZoneGroupNameVar = '${webappPrivateEndpointName}/${webappPrivateEndpointGroupName}PrivateDnsZoneGroup'
// var webappPrivateEndpointId = webappPrivateEndpointName_resource.id
var webappPublicDNSZoneForwarder = 'privatelink.azurewebsites.net'
var appServiceID = appService.id
var resourceGroupName = ResourceGroupName
var ASPExternalID = '/subscriptions/${SubscriptionID}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/serverfarms/${existingASP}'
var webAppPENameExternalID = '/subscriptions/${SubscriptionID}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/privateEndpoints/${webappPrivateEndpointName}'



resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  // name: appServicePlanName
  name: (existingASP == '' ? appServicePlanName : existingASP)
  location: location
  properties: {
    reserved: isReserved
  }
  sku: {
    name: sku
  }
  kind: AppOS
}

// Referencing an existing Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: PLvnetName
  scope: resourceGroup(SubscriptionID, PLvnetResourceGroupName)
  // scope: resourceGroup(vnetResourceGroupName)
}

// Need a reference to an existing subnet to determine if it's already been delegated to SQL MI
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${vnet.name}/${PLSubnetName}'
  // scope: resourceGroup(vnetResourceGroupName)
  scope: resourceGroup(SubscriptionID, PLvnetResourceGroupName)
}

// Referencing an existing Virtual Network
resource vnetApp 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: appvirtualNetwork
  scope: resourceGroup(SubscriptionID, vnetIntegrationResourceGroupName)
  // scope: resourceGroup(vnetResourceGroupName)
}

// Need a reference to an existing subnet to determine if it's already been delegated to SQL MI
resource subnetApp 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${vnetApp.name}/${appsubnet2Name}'
  // scope: resourceGroup(vnetResourceGroupName)
  scope: resourceGroup(SubscriptionID, vnetIntegrationResourceGroupName)
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: webSiteName
  location: location
  properties: {
    // serverFarmId: appServicePlan.id
    serverFarmId: (existingASP == ''?appServicePlan.id:ASPExternalID)
    reserved: isReserved
    publicNetworkAccess: 'Disabled'
    siteConfig: {
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      remoteDebuggingEnabled: false
      alwaysOn: true
      scmMinTlsVersion: '1.2'
      webSocketsEnabled: false
    }
  }
  kind: AppOS
  dependsOn: [ 
    appServicePlan 
  ]
}


resource webApp2NetworkConfig 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: appService
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetApp.id //resourceId('Microsoft.Network/virtualNetworks/subnets',appvirtualNetwork ,appsubnet2Name)
  }
}

resource webappPrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-04-01' = if (existingASP == '') {
  name: webappPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: webappPrivateEndpointName
        properties: {
          privateLinkServiceId: appServiceID
          groupIds: [
            webappPrivateEndpointGroupName
          ]
          
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }

    ]
    subnet: {
      id: subnet.id
    }
    manualPrivateLinkServiceConnections: []
    customDnsConfigs: []
  }
  dependsOn: [
    vnet
    webApp2NetworkConfig
  ]
}

//'/subscriptions/019c44d5-0283-4326-85a9-9e7b73acfe76/resourceGroups/khaz-eus2-rg-infra-network-dns-001-prod/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
resource webappPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = {
  name: webappPrivateDnsZoneGroupNameVar
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azurewebsites-net'
        properties: {
          privateDnsZoneId: resourceId(privateDNSSubscriptionID, privateDNSRG, 'Microsoft.Network/privateDnsZones', webappPublicDNSZoneForwarder) //subscriptionResourceId('Private DNS zone','',privateDnsZones_privatelink_vaultcore_azure_net_externalid)
          //Id
        }
      }
    ]
  }
  dependsOn: [
    appService
    webappPrivateEndpointName_resource
  ]
}

// az deployment group create 
// --resource-group RG-demoRGDeplopyment 
// --subscription KHAZ-TEST-CCOE --mode Incremental 
// --template-file WebApp.BICEP 
// --parameters vnetName="KHAZ-EUS2-CCOE-NONPROD-VNET-001_10.13.108.0_22" 
// SubnetName="KHAZ-EUS2-CCOE-0001-NONPROD-SNET-PL-001_10.13.109.32_29" 
// vnetResourceGroupName="KHAZ-EUS2-RG-INFRA-NETWORK-001-NONPROD" 
// privateDNSSubscriptionID=019c44d5-0283-4326-85a9-9e7b73acfe76 
// privateDNSRG=khaz-eus2-rg-infra-network-dns-001-prod 
// webappPleName=EUS2-CCOE-0001WBP01-PL-WB-001

// az deployment group what-if \
//   --name KenanDeployment \
//   --resource-group rg-myresourcegroup \
//   --template-file deploy/WebApp.BICEP \
//   --parameters vnetName="KHAZ-EUS2-CCOE-NONPROD-VNET-001_10.13.108.0_22" \
//   SubnetName="KHAZ-EUS2-CCOE-0001-NONPROD-SNET-PL-001_10.13.109.32_29" \
//   vnetResourceGroupName="KHAZ-EUS2-RG-INFRA-NETWORK-001-NONPROD" \
//   privateDNSSubscriptionID=019c44d5-0283-4326-85a9-9e7b73acfe76 \
//   privateDNSRG=khaz-eus2-rg-infra-network-dns-001-prod \
//   webappPleName=EUS2-CCOE-0001WBP01-PL-WB-001
