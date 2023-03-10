@description('''
The name of the Storage Account to be created. 
Must contain letters and numbers only. 
Storage Account names must be all lower case. 
This module will convert the name to lowercase
''')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('The Azure region into which the resources should be deployed.')
param storageAccountLocation string = resourceGroup().location

@description('''
An object specifying the tags as key:value pairs to assign to this resource as show here:
{
  "environment": "Development"
  "department": "DevOps"
}
''')
param storageAccountTags object = {}

@description('The Sku name to be used in the creation of this storage account.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountSkuName string = 'Standard_LRS'

@description('The type of storage account to create. The default is StorageV2.')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param storageAccountType string = 'StorageV2'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: toLower(storageAccountName)
  location: storageAccountLocation
  tags: storageAccountTags
  sku: {
    name: storageAccountSkuName
  }
  kind: storageAccountType
}
