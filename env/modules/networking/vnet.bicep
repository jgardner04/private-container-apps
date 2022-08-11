param tags object
param name string
param location string
param addressPrefixes array


// Create a new vnet
resource vnet 'Microsoft.Network/virtualnetworks@2015-05-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
  }
}

output vnetId string = vnet.id
