param location string = resourceGroup().location

resource storageAccountGreen 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'mystorageaccountgreen'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_RAGRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource storageAccountBlue 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'mystorageaccountblue'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_RAGRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource blobGreen 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: storageAccountGreen
  properties: {
    automaticSnapshotPolicyEnabled: false
    changeFeed: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: true
      days: 7
      enabled: true
    }
    isVersioningEnabled: false
  }
}

resource blobBlue 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: storageAccountBlue
  properties: {
    automaticSnapshotPolicyEnabled: false
    changeFeed: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: true
      days: 7
      enabled: true
    }
    isVersioningEnabled: false
  }
}

resource containerGreen 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '$web'
  parent: blobGreen
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    immutableStorageWithVersioning: {
      enabled: false
    }
    metadata: {}
    publicAccess: 'None'
  }
}

resource containerBlue 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '$web'
  parent: blobBlue
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    immutableStorageWithVersioning: {
      enabled: false
    }
    metadata: {}
    publicAccess: 'None'
  }
}
