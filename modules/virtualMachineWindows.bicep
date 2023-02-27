@description('The Username for the Administrator account on this Virtual Machine.')
@maxLength(20)
param vmAdminUsername string

@description('The Password for the Virtual Machine.')
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

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
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

param MakeOrAddPPG bool = false
var resourceGroupName = 'rg-myresourcegroup'
var placementGroupName = 'myProxGroup'

resource vmBootGiagnosticsSorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = if(vmBootDiagnosticsEnabled) {
  name: vmBootDiagnosticsStorageAccountName
}

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: vmLocation
  tags: vmTags
  properties: {
    proximityPlacementGroup: MakeOrAddPPG == true ? resourceId('Microsoft.Compute/proximityPlacementGroups', placementGroupName) : null
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: vmOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: vmStorageAccountType
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNIC.id
        }
      ]
    }
    diagnosticsProfile: (!vmBootDiagnosticsEnabled) ? {} : {
      bootDiagnostics: {
        enabled: true
        storageUri: vmBootGiagnosticsSorageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

resource vmNIC 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${vmName}-nic'
  location: vmLocation
  properties: {
    ipConfigurations: [
      {
        name: '${vmName}-pipconfig'
        properties: {
          privateIPAllocationMethod: vmPublicIPAllocationMethod
          publicIPAddress: (!vmPublicIpEnabled) ? {} : {
            id: vmPIP.id
          }
          subnet: {
            id: resourceId('Microsoft.Networks/virtualNetworks/subnets', vmVnetName, vmSubnetName)
          }
        }
      }
    ]
  }
}

resource vmPIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = if(vmPublicIpEnabled) {
  name: vmPublicIpName
  location: vmLocation
  sku: {
    name: vmPublicIpSku
  }
  properties: {
    publicIPAllocationMethod: vmPublicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: vmName
    }
  }
}


output vmHostname string = vmPIP.properties.dnsSettings.fqdn
