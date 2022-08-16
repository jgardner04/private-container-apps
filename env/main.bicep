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

// Create the firewall pip
module hubFwPip './modules/networking/pip.bicep' = {
  scope: resourceGroup(hubAppRg.name)
  name: 'hubFwPip'
  params: {
    pipName: 'fwPip'
    location: location
    tags: tags
  }
}

// Create firewall
module hubFW './modules/networking/firewall.bicep' = {
  scope: resourceGroup(hubAppRg.name)
  dependsOn: [vmVnet]
  name: hubFwName
  params: {
    fwName: 'container-apps-fw'
    location: location
    tags: tags
    ipConfigurations: {
      name: hubFwPip.outputs.pipName
      properties: {
        subnet: {
          id: fwSubnet.outputs.subnetId
        }
        publicIPAddress: {
          id: hubFwPip.outputs.pipId
        }
      }
    }
  }
}

// Create routetables
// VM Routetable
module vmRouteTable './modules/networking/routetable.bicep' = {
  scope: resourceGroup(vmRg.name)
  dependsOn: [hubFW]
  name: 'vmRouteTable'
  params: {
    udrName: 'vm-rt'
    udrRouteName: 'Default-route'
    location: location
    nextHopIpAddress: hubFW.outputs.fwPip
  }
}

// Container Routetable
module containerRouteTable './modules/networking/routetable.bicep' = {
  scope: resourceGroup(containerAppRg.name)
  dependsOn: [hubFW]
  name: 'containerRouteTable'
  params: {
    udrName: 'container-rt'
    udrRouteName: 'Default-route'
    location: location
    nextHopIpAddress: hubFW.outputs.fwPip
  }
}

// Create the subnets
module fwSubnet './modules/networking/subnet.bicep' = {
  scope: resourceGroup(hubAppRg.name)

  dependsOn: [hubVnet]
  name: 'fwSubnet'
  params: {
    vnetName: 'hubVnet'
    subnetPrefixes: firewallSbunetPrefix
    subnetName: 'AzureFirewallSubnet'
  }
}

module vmSubnet './modules/networking/subnet.bicep' = {
  scope: resourceGroup(vmRg.name)

  dependsOn: [vmVnet, vmRouteTable]
  name: 'vmSubnet'
  params: {
    vnetName: vmVnetName
    subnetPrefixes: vmSubnetPrefixs
    subnetName: 'vms'
    routeTableId: vmRouteTable.outputs.routeTableId
  }
}

module containerSubnet './modules/networking/subnet.bicep' = {
  scope: resourceGroup(containerAppRg.name)

  dependsOn: [containerVnet, containerRouteTable]
  name: 'containerSubnet'
  params: {
    vnetName: containerVnetName
    subnetPrefixes: containerSubnetPrefixs
    subnetName: 'containers'
    routeTableId: containerRouteTable.outputs.routeTableId
  }
}

// Create vnet Peering
module vmToHubPeering 'modules/networking/peering.bicep' = {
  scope: resourceGroup(vmRg.name)
  dependsOn: [vmVnet, hubVnet,]
  name: 'vmToHubPeering'
  params: {
    localVnetName: vmVnetName
    remoteVnetName: hubVnetName
    remoteVnetID: hubVnet.outputs.vnetId
  }
}

module containerToHubPeering 'modules/networking/peering.bicep' = {
  scope: resourceGroup(containerAppRg.name)
  dependsOn: [containerVnet, hubVnet,]
  name: 'containerToHubPeering'
  params: {
    localVnetName: containerVnetName
    remoteVnetName: hubVnetName
    remoteVnetID: hubVnet.outputs.vnetId
  }
}
