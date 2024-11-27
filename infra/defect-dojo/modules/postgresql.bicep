param flexibleServers_psql_name string = 'psql-defectdojo-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

param startIpAddress string //= '2024.4.10.11'
param endIpAddress string //= '2024.4.10.11'

param administratorLogin string = 'ddadmin'

@secure()
param administratorLoginPassword string

resource flexibleServers_psql 'Microsoft.DBforPostgreSQL/flexibleServers@2023-06-01-preview' = {
  name: flexibleServers_psql_name
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    replica: {
      role: 'Primary'
    }
    storage: {
      iops: 120
      tier: 'P4'
      storageSizeGB: 32
      autoGrow: 'Disabled'
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    dataEncryption: {
      type: 'SystemManaged'
    }
    authConfig: {
      activeDirectoryAuth: 'Disabled'
      passwordAuth: 'Enabled'
    }
    version: '16'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    availabilityZone: '1'
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
    replicationRole: 'Primary'
  }

  resource flexibleServers_psql_defectdojo_001_name_ClientIPAddress_2024_4_10_11_4_3 'firewallRules@2023-06-01-preview' = {
    name: 'ClientIPAddress_Initial'
    properties: {
      startIpAddress: startIpAddress
      endIpAddress: endIpAddress
    }
  }
}

output flexibleServers_psql_name string = flexibleServers_psql.name
output administratorLogin string = flexibleServers_psql.properties.administratorLogin
output fullyQualifiedDomainName string = flexibleServers_psql.properties.fullyQualifiedDomainName
