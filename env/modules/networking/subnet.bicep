param vnetName string
param subnetPrefixes string
param subnetName string
param routetableName string = ''

resource vnet 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: vnetName
}

resource routetable 'Microsoft.Network/routeTables@2022-01-01' existing = {
  name: routetableName
}

resource subnet 'Microsoft.Network/virtualnetworks/subnets@2015-06-15' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetPrefixes
    routeTable: empty(routetable.id)? json('null') : {
      id: routetable.id
    }
  }
}
