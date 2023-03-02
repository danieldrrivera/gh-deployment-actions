@description('The name of the lock to be created.')
param resourceLockName string

resource resourceLock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: resourceLockName
  properties: {
    level: 'CanNotDelete'
    notes: 'Lock to prevent this resource from being deleted'
  }
}
