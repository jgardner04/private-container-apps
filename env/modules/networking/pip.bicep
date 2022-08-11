param pipName string
param location string
param tags object
param skuName string = 'Standard'
param publicIPAllocationMethod string = 'Static'
param ideleTimeoutInMinutes int = 4
param publicIPAddressVersion string = 'IPv4'

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: pipName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIPAddressVersion: publicIPAddressVersion
    idleTimeoutInMinutes: ideleTimeoutInMinutes
  }
}
