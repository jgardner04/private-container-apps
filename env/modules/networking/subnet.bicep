param vnetName string
param subnetPrefixes string
param subnetName string

resource vnet 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: vnetName
}


resource subnet 'Microsoft.Network/virtualnetworks/subnets@2015-06-15' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetPrefixes
  }
}
