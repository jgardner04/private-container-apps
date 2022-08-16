param fwName string
param location string
param tags object
param zones array = [
  '1' 
  '2' 
  '3'
]
param sku object = {
  name: 'AZFW_Vnet'
  tier: 'Standard'
}
param ipConfigurations object

resource fw 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: fwName
  location: location
  tags: tags
  zones: zones
  properties: {
    additionalProperties: {
      'Network.DNS.EnableProxy': 'true'
    }
    sku: sku
    threatIntelMode: 'Deny'
    ipConfigurations: [
      ipConfigurations
    ]
    networkRuleCollections: [
      {
        name: 'time'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 101
          rules: [
            {
              name: 'Allow time'
              description: 'Network Rule to allow time sync'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                'UDP'
              ]
              destinationPorts: [
                '123'
              ]
              destinationAddresses: [
                '*'
              ]
            }
          ]
        }
      }
      {
        name: 'dns'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 102
          rules: [
            {
              name: 'Allow DNS'
              description: 'Network Rule to allow DNS queries'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                'UDP'
              ]
              destinationPorts: [
                '53'
              ]
              destinationAddresses: [
                '*'
              ]
            }
          ]
        }
      }
      {
        name: 'servicetags'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 103
          rules: [
            {
              name: 'Allow servicetags'
              description: 'Network Rule to allow Service Tags'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                'Any'
              ]
              destinationPorts: [
                '*'
              ]
              destinationAddresses: [
                'AzureContainerRegistry'
                'MicrosoftContainerRegistry'
                'AzureActiveDirectory' 
                'AzureMonitor'
              ]
            }
          ]
        }
      }
    ]
    applicationRuleCollections: [
      {
        name: 'aksbasics'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 101
          rules: [
            {
              name: 'Allow AKS basic FQDNs'
              description: 'Application Rule to allow access to certain FQDNs'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 80
                  protocolType:'Http'              
                }
                {
                  port: 443
                  protocolType: 'Https'
                }

              ]
              targetFqdns:[
                '*.cdn.mscr.io'
                'mcr.microsoft.com'
                '*.data.mcr.microsoft.com'
                'management.azure.com'
                'login.microsoftonline.com'
                'acs-mirror.azureedge.net'
                'dc.services.visualstudio.com'
                '*.opinsights.azure.com'
                '*.oms.opinsights.azure.com'
                '*.microsoftonline.com'
                '*.monitoring.azure.com'
                'api.snapcraft.io'
                '*.agentsvc.azure-automation.net'
                'md-0fz4cs3dgc1b.z37.blob.storage.azure.net'
                'azurecliprod.blob.core.windows.net'
                '3097d017-5d0e-452d-a367-e8f14ba6c9f7.agentsvc.azure-automation.net'
                'vstsagentpackage.azureedge.net'
                'cc-jobruntimedata-prod-su1.azure-automation.net'
              ]

            }
          ]

        }
      }
      {
        name: 'osupdates'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 102
          rules: [
            {
              name: 'Allow OS Updates'
              description: 'Application Rule to allow access to OS Updates'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 80
                  protocolType:'Http'              
                }
                {
                  port: 443
                  protocolType: 'Https'
                }

              ]
              targetFqdns:[
                'download.opensuse.org'
                'security.ubuntu.com'
                'archieve.ubuntu.com'
                'changelogs.ubuntu.com'
                'azure.archive.ubuntu.com'
                'ntp.ubuntu.com'
                'packages.microsoft.com'
                'snapcraft.io'
              ]

            }
          ]

        }
      }
      {
        name: 'publicimages'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 103
          rules: [
            {
              name: 'Allow public images'
              description: 'Application Rule to allow access to public registries'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 80
                  protocolType:'Http'              
                }
                {
                  port: 443
                  protocolType: 'Https'
                }

              ]
              targetFqdns:[
                'auth.docker.io'
                'registry-1.docker.io'
                'production.cloudflare.docker.com'
                '*.docker.com'
              ]

            }
          ]

        }
      }
      {
        name: 'istio'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 104
          rules: [
            {
              name: 'Allow istio binaries'
              description: 'Application Rule to allow access to istio binaries'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 80
                  protocolType:'Http'              
                }
                {
                  port: 443
                  protocolType: 'Https'
                }

              ]
              targetFqdns:[
                'istio.io'
                'quay.io'
                '*istio.io'
                'grafana.com'
                '*.grafana.com'
              ]

            }
            {
              name: 'Allow helm binaries'
              description: 'Application Rule to allow access to helm binaries'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 80
                  protocolType:'Http'              
                }
                {
                  port: 443
                  protocolType: 'Https'
                }

              ]
              targetFqdns:[
                'get.helm.sh'
              ]

            }
          ]

        }
      }
      {
        name: 'github'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 105
          rules: [
            {
              name: 'Allow github'
              description: 'Application Rule to allow access to github'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 80
                  protocolType:'Http'              
                }
                {
                  port: 443
                  protocolType: 'Https'
                }

              ]
              targetFqdns:[
                '*.github.com'
                'github.com'
                '*.s3.amazonaws.com'
                '*.github.io'
                'github-releases.githubusercontent.com'
              ]

            }
          ]

        }
      }
      {
        name: 'miscbinaries'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 106
          rules: [
            {
              name: 'Allow MS and Google Binaries'
              description: 'Application Rule to allow access to MS and Google binaries'
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 80
                  protocolType:'Http'              
                }
                {
                  port: 443
                  protocolType: 'Https'
                }

              ]
              targetFqdns:[
                '*.aka.ms'
                'aka.ms'
                '*.microsoft.com'
                'storage.googleapis.com'
                '*.storage.googleapis.com'
              ]

            }
          ]

        }
      }
    ]
  }
}

output fwPip string = fw.properties.ipConfigurations[0].properties.privateIPAddress
output fwName string = fw.name
