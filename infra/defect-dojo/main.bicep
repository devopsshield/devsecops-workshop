param nameSuffix string = 'ek001'
param virtualMachineName string = 'vm-defectdojo-${nameSuffix}-${uniqueString(resourceGroup().id)}'
//param sshPublicKeyName string = 'vm-defectdojo-001_key'
param networkInterfaceName string = 'nic-vm-defectdojo-${nameSuffix}-${uniqueString(resourceGroup().id)}' //138'
param publicIPAddressName string = 'pip-vm-defectdojo-${nameSuffix}-${uniqueString(resourceGroup().id)}'
param virtualNetworkName string = 'vnet-vm-defectdojo-${nameSuffix}-${uniqueString(resourceGroup().id)}'
param networkSecurityGroupName string = 'nsg-vm-defectdojo-${nameSuffix}-${uniqueString(resourceGroup().id)}'

param location string = resourceGroup().location
param adminUsername string //= 'azureuser'

param sshPublicKey string //= 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4AAZjNhnoNi/tBRwOFPoVg82Ejvt3qLEutQHEUJcBfohXW31R+aeWaGYkz3t4x1nYejoxX2m2Qk8wUsxU0SYhzI9DkOlov39PJ+MoggSGzKnpAUDeJ324kYIlu/2ZkRxkcnnDSe9t32yMWC4KC0tJMNuFzuAObIyi4h5JFJ/f8WqWuWK9uSv1FqnFqvALks8+f1eg5WMw4u4wa5wWBUICGOqVQ4zzQwq+hcAVgCgvi41mJbYn2oVKJyeX2R8mFDjaV+VPRkhgCMphG55ultCkNoH5naLQxLIjSop2ioDxPeYcdqCdO97MSPvkHhwKZgT03R/JJhQJ89Gm8QAdTIGiV5R16vq9EOL83vaVHsJ1jR1zsgDa/EVsQQBmxVNlybs0tgqlgn138Af+1QTNdYQu05fLqd6ara2Wgl61al0HMNjBrLgtJ1To4yxrYJ1iQY9W4I77a4jrq2Sg0ouObgsJu45dwrRpt22Fbh1OWhkfK/XFoEu5O9vr1ghRcZAwxjU= generated-by-azure'

param flexibleServers_psql_name string = 'psql-defectdojo-${nameSuffix}-${uniqueString(resourceGroup().id)}'
param administratorLogin string //= 'ddadmin'

param dnsLabelPrefix string = 'app-defectdojo-${nameSuffix}-${uniqueString(resourceGroup().id)}'

@secure()
param administratorLoginPassword string

param addPostgresServer bool = true

// resource sshPublicKey 'Microsoft.Compute/sshPublicKeys@2023-09-01' = {
//   name: sshPublicKeyName
//   location: location
//   properties: {
//     publicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4AAZjNhnoNi/tBRwOFPoVg82Ejvt3qLEutQHEUJcBfohXW31R+aeWaGYkz3t4x1nYejoxX2m2Qk8wUsxU0SYhzI9DkOlov39PJ+MoggSGzKnpAUDeJ324kYIlu/2ZkRxkcnnDSe9t32yMWC4KC0tJMNuFzuAObIyi4h5JFJ/f8WqWuWK9uSv1FqnFqvALks8+f1eg5WMw4u4wa5wWBUICGOqVQ4zzQwq+hcAVgCgvi41mJbYn2oVKJyeX2R8mFDjaV+VPRkhgCMphG55ultCkNoH5naLQxLIjSop2ioDxPeYcdqCdO97MSPvkHhwKZgT03R/JJhQJ89Gm8QAdTIGiV5R16vq9EOL83vaVHsJ1jR1zsgDa/EVsQQBmxVNlybs0tgqlgn138Af+1QTNdYQu05fLqd6ara2Wgl61al0HMNjBrLgtJ1To4yxrYJ1iQY9W4I77a4jrq2Sg0ouObgsJu45dwrRpt22Fbh1OWhkfK/XFoEu5O9vr1ghRcZAwxjU= generated-by-azure'
//   }
// }

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        //id: networkSecurityGroups_vm_defectdojo_001_nsg_name_SSH.id
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowAnyHTTPInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'for letsencrypt ACME challenge'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 310
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowAnyCustom8443Inbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'for DefectDojo HTTPS access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 320
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowAnyCustom8080Inbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'for DefectDojo HTTP access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 330
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
        // }
        // {
        //   name: 'AllowAnyHTTPSOutbound'
        //   type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        //   properties: {
        //     protocol: 'Tcp'
        //     sourcePortRange: '*'
        //     destinationPortRange: '443'
        //     sourceAddressPrefix: '*'
        //     destinationAddressPrefix: '*'
        //     access: 'Allow'
        //     priority: 340
        //     direction: 'Outbound'
        //     sourcePortRanges: []
        //     destinationPortRanges: []
        //     sourceAddressPrefixes: []
        //     destinationAddressPrefixes: []
        //   }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    //ipAddress: '13.88.253.103'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        //id: virtualNetworks_vm_defectdojo_001_vnet_name_default.id
        properties: {
          addressPrefix: '10.1.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }

  resource virtualNetworkDefaultSubnet 'subnets@2023-09-01' = {
    //parent: virtualNetwork
    name: 'default'
    properties: {
      addressPrefix: '10.1.0.0/24'
      delegations: []
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v3'
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        //name: '${virtualMachineName}_OsDisk_1_25ec5f171b214cee80b2dc63e23bb19c'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
          // id: resourceId(
          //   'Microsoft.Compute/disks',
          //   '${virtualMachineName}_OsDisk_1_25ec5f171b214cee80b2dc63e23bb19c'
          // )
        }
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          automaticByPlatformSettings: {
            rebootSetting: 'IfRequired'
            bypassPlatformSafetyChecksOnUserSchedule: false
          }
          assessmentMode: 'ImageDefault'
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
      //requireGuestProvisionSignal: true
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        //id: '${networkInterfaces_vm_defectdojo_001138_name_resource.id}/ipConfigurations/ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.1.0.4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
            properties: {
              deleteOption: 'Detach'
            }
          }
          subnet: {
            id: virtualNetwork::virtualNetworkDefaultSubnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    disableTcpStateTracking: false
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}

module postgresql 'modules/postgresql.bicep' = if (addPostgresServer) {
  name: 'postgresql'
  params: {
    location: location
    flexibleServers_psql_name: flexibleServers_psql_name
    administratorLoginPassword: administratorLoginPassword
    administratorLogin: administratorLogin
    startIpAddress: publicIPAddress.properties.ipAddress
    endIpAddress: publicIPAddress.properties.ipAddress
  }
}

output publicIPAddress string = publicIPAddress.properties.ipAddress
output fqdn string = publicIPAddress.properties.dnsSettings.fqdn
// output postgresql if addPostgresServer = true
output flexibleServers_psql_name string = addPostgresServer ? postgresql.outputs.flexibleServers_psql_name : ''
output administratorLogin string = addPostgresServer ? postgresql.outputs.administratorLogin : ''
output fullyQualifiedDomainName string = postgresql.outputs.fullyQualifiedDomainName
output dnsLabelPrefix string = dnsLabelPrefix
output adminUsername string = adminUsername
