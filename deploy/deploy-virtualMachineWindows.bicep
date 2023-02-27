// Deploy this template using the following command:
// az deployment group create \
// az deployment group what-if \
//   --name myVMDeployment \
//   --resource-group rg-myresourcegroup \
//   --template-file deploy/deploy-virtualMachineWindows.bicep \
//   --parameters @deploy/deploy.virtualMachineWindows.parameters.json

@description('The Username for the Administrator account on this Virtual Machine.')
@maxLength(20)
param vmAdminUsername string

@description('The Password for the Administrator account on this Virtual Machine.')
@secure()
@minLength(12)
@maxLength(123)
param vmAdminPassword string

@description('A flag to determine if a public ip will be enable for this Virtual Machine')
param vmPublicIpEnabled bool = false

@description('Name for the Public IP used to access the Virtual Machine.')
param vmPublicIpName string = 'PublicIP-${uniqueString(resourceGroup().id)}'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param vmPublicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param vmPublicIpSku string = 'Basic'

@description('''
The Windows version for the VM. This will pick a fully patched image of this given Windows version.
Use the following command to obtain a list of images available:
az vm image list --publisher MicrosoftWindowsServer --sku 2022 --all --output table
''')
param vmOSVersion string = '2022-datacenter-core-g2'

@description('Specifies the storage account type for the managed disk.')
@allowed([
  'PremiumV2_LRS'
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param vmStorageAccountType string = 'Standard_LRS'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_B1s'

@description('The name of the Virtual Machine to create.')
@minLength(1)
@maxLength(15)
param vmName string

@description('The Azure region into which the resources should be deployed.')
param vmLocation string = resourceGroup().location

@description('The name of the Virtual Network this Virual Machine will be placed in.')
param vmVnetName string

@description('The Subnet this Virtual MAchine will be placed in')
param vmSubnetName string

@description('A flag to determine if boot diagnostics will be enabled. If enabled, please provide the storage account name to store the diagnostics information to.')
param vmBootDiagnosticsEnabled bool = false

@description('The name of the storage acccount to store the boot diagnostics.')
param vmBootDiagnosticsStorageAccountName string

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  "environment": "Development"
  "department": "DevOps"
}
''')
param vmTags object = {}

module virtualMachine '../modules/virtualMachineWindows.bicep' = {
  name: vmName
  params: {
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmName: vmName
    vmLocation: vmLocation
    vmTags: vmTags
    vmVnetName: vmVnetName
    vmSubnetName: vmSubnetName
    vmPublicIpEnabled: vmPublicIpEnabled
    vmSize: vmSize
    vmOSVersion: vmOSVersion
    vmPublicIPAllocationMethod: vmPublicIPAllocationMethod
    vmPublicIpName: vmPublicIpName
    vmPublicIpSku: vmPublicIpSku
    vmStorageAccountType: vmStorageAccountType
    vmBootDiagnosticsEnabled: vmBootDiagnosticsEnabled
    vmBootDiagnosticsStorageAccountName: vmBootDiagnosticsStorageAccountName
  }
}
