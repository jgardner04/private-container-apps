targetScope = 'subscription'

param vmVnetName string = 'vmVnet'
param containerVnetName string = 'containerAppsVnet'
param location string = 'westus3'
param hubVnetName string = 'hubVnet'
param hubVnetAddressPrefixs array = ['192.168.230.0/24']
param hubFwName string = 'hub-fw'
param firewallSbunetPrefix string = '192.168.230.0/26'
param vmVnetAddressPrefixs array = ['192.168.200.0/24']
param vmSubnetPrefixs string = '192.168.200.0/25'
param containerVnetAddressPrefixs array = ['192.168.220.0/24']
param containerSubnetPrefixs string = '192.168.220.0/24'
param tags object = {
  use: 'demo'
  owner: 'jogardn'
  app: 'container-apps-demo'
}

// Create the resource groups
resource vmRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'container-apps-test-vms'
  location: location
  tags: tags
}

resource containerAppRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'container-apps-test-containers'
  location: location
  tags: tags
}

resource hubAppRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'container-apps-test-hub'
  location: location
  tags: tags
}

// Create the vnets
module vmVnet './modules/networking/vnet.bicep' = {
  scope: resourceGroup(vmRg.name)
  name: 'vmVnet'
  params: {
    name: vmVnetName
    location: location
    tags: tags
    addressPrefixes: vmVnetAddressPrefixs
  }
}

module containerVnet './modules/networking/vnet.bicep' = {
  scope: resourceGroup(containerAppRg.name)
  name: 'containerVnet'
  params: {
    name: containerVnetName
    location: location
    tags: tags
    addressPrefixes: containerVnetAddressPrefixs
  }
}

module hubVnet './modules/networking/vnet.bicep' = {
  scope: resourceGroup(hubAppRg.name)
  name: 'hubVnet'
  params: {
    name: hubVnetName
    location: location
    tags: tags
    addressPrefixes: hubVnetAddressPrefixs
  }
}

// Create the subnets
module fwSubnet './modules/networking/subnet.bicep' = {
  scope: resourceGroup(hubAppRg.name)
  name: 'fwSubnet'
  params: {
    vnetName: hubFwName
    subnetPrefixes: firewallSbunetPrefix
    subnetName: 'firewall'
  }
}

module vmSubnet './modules/networking/subnet.bicep' = {
  scope: resourceGroup(vmRg.name)

  dependsOn: [vmVnet]
  name: 'vmSubnet'
  params: {
    vnetName: vmVnetName
    subnetPrefixes: vmSubnetPrefixs
    subnetName: 'vms'
  }
}

module containerSubnet './modules/networking/subnet.bicep' = {
  scope: resourceGroup(containerAppRg.name)

  dependsOn: [containerVnet]
  name: 'containerSubnet'
  params: {
    vnetName: containerVnetName
    subnetPrefixes: containerSubnetPrefixs
    subnetName: 'containers'
  }
}

// Create vnet Peering
module vmToContainerPeering 'modules/networking/peering.bicep' = {
  scope: resourceGroup(vmRg.name)
  dependsOn: [vmVnet, containerVnet]
  name: 'vmToContainerPeering'
  params: {
    localVnetName: vmVnetName
    remoteVnetName: containerVnetName
    remoteVnetID: containerVnet.outputs.vnetId
  }
}

module containerToVmPeering 'modules/networking/peering.bicep' = {
  scope: resourceGroup(containerAppRg.name)
  dependsOn: [containerVnet, vmVnet]
  name: 'containerToVmPeering'
  params: {
    localVnetName: containerVnetName
    remoteVnetName: vmVnetName
    remoteVnetID: vmVnet.outputs.vnetId
  }
}
