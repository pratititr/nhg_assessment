param frontDoorName string = 'myFrontDoor'
param originGroup string = 'myOriginGroup'
param blueCdnOrigin string = 'blueOrigin'
param greenCdnOrigin string = 'greenOrigin'
param frontDoorEndPoint string = 'blueGreenEndpoint'
param frontDoorRoute string = 'frontDoorDemoRoute'
param location string = 'East US'

resource storageAccountGreen 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: 'mystorageaccountgreen'
}
output greenEnvHostName string= storageAccountGreen.properties.primaryEndpoints.web
var trimStorageAccountGreen = substring(storageAccountGreen.properties.primaryEndpoints.web, 8, (lastIndexOf(storageAccountGreen.properties.primaryEndpoints.web, '/') - 8))

resource storageAccountBlue 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: 'mystorageaccountblue'
}
output blueEnvHostName string= storageAccountBlue.properties.primaryEndpoints.web
var trimStorageAccountBlue = substring(storageAccountBlue.properties.primaryEndpoints.web, 8, (lastIndexOf(storageAccountBlue.properties.primaryEndpoints.web, '/') - 8))
resource symbolicname 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: frontDoorName
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    extendedProperties: {}
    originResponseTimeoutSeconds: 60
  }
}
resource demoOriginGroup 'Microsoft.Cdn/profiles/originGroups@2022-11-01-preview' = {
  name: originGroup
  parent: symbolicname
  properties: {
    healthProbeSettings: {
      probeIntervalInSeconds: 100
      probePath: '/'
      probeProtocol: 'Http'
      probeRequestType: 'HEAD'
    }
    loadBalancingSettings: {
      additionalLatencyInMilliseconds: 50
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    sessionAffinityState: 'Disabled'
  }
}
resource blueOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2022-11-01-preview' = {
  name: blueCdnOrigin
  parent: demoOriginGroup
  properties: {
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
    hostName: trimStorageAccountBlue
    httpPort: 80
    httpsPort: 443
    originHostHeader: trimStorageAccountBlue
    priority: 1
    weight: 100
  }
}
resource greenOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2022-11-01-preview' = {
  name: greenCdnOrigin
  parent: demoOriginGroup
  properties: {
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
    hostName: trimStorageAccountGreen
    httpPort: 80
    httpsPort: 443
    originHostHeader: trimStorageAccountGreen
    priority: 1
    weight: 100
  }
}
resource fdEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2022-11-01-preview' = {
  name: frontDoorEndPoint
  location: 'Global'
  parent: symbolicname
  properties: {
    enabledState: 'Enabled'
  }
}
resource myRoutes 'Microsoft.Cdn/profiles/afdEndpoints/routes@2022-11-01-preview' = {
  name: frontDoorRoute
  parent: fdEndpoint
  properties: {
    enabledState: 'Enabled'
    forwardingProtocol: 'MatchRequest'
    httpsRedirect: 'Enabled'
    linkToDefaultDomain: 'Enabled'
    originGroup: {
      id: demoOriginGroup.id
    }
    patternsToMatch: [
      '/*'
    ]
    supportedProtocols: [
      'Http'
      'Https'
    ]
  }
}
output fdHostName string = fdEndpoint.properties.hostName
