param location string = resourceGroup().location
param dnsPrefix string = 'wrkshp-001-student-001'
param linuxAdminUsername string = 'azureuser'
param sshRSAPublicKey string = '<SSH PUBLIC KEY>'
param agentVMSize string = 'standard_d2s_v3'
param clusterName string = 'aks-k8s-pygoat-wrkshp-001-student-001'
param containerRegistryBaseName string = 'crs001'

module k8s 'k8s.bicep' = {
  name: clusterName
  params: {
    dnsPrefix: dnsPrefix
    linuxAdminUsername: linuxAdminUsername
    sshRSAPublicKey: sshRSAPublicKey
    location: location
    agentCount: 1
    agentVMSize: agentVMSize
    osDiskSizeGB: 0
    clusterName: clusterName
  }
}

module cr 'containerRegistry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    containerRegistryBaseName: containerRegistryBaseName     
  }
}
