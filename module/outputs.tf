# Database outputs
output "databases" {
  description = "Details of created NDB databases"
  value = {
    for k, v in nutanix_ndb_database.database : k => {
      id                    = v.id
      name                  = v.name
      status                = v.status
      database_name         = v.database_name
      type                  = v.type
      database_cluster_type = v.database_cluster_type
    }
  }
}

output "database_ids" {
  description = "Map of database names to IDs"
  value = {
    for k, v in nutanix_ndb_database.database : k => v.id
  }
}

# Profile outputs
output "profiles" {
  description = "Details of created NDB profiles"
  value = {
    for k, v in nutanix_ndb_profile.profile : k => {
      name              = v.name
      status            = v.status
      engine_type       = v.engine_type
      latest_version_id = v.latest_version_id
    }
  }
}

output "profile_ids" {
  description = "Map of profile names to IDs"
  value = {
    for k, v in nutanix_ndb_profile.profile : k => v.id
  }
}

# SLA outputs
output "slas" {
  description = "Details of created NDB SLAs"
  value = {
    for k, v in nutanix_ndb_sla.sla : k => {
      name                 = v.name
      unique_name          = v.unique_name
      continuous_retention = v.continuous_retention
      daily_retention      = v.daily_retention
    }
  }
}

output "sla_ids" {
  description = "Map of SLA names to IDs"
  value = {
    for k, v in nutanix_ndb_sla.sla : k => v.id
  }
}

# Network outputs
output "networks" {
  description = "Details of created NDB networks"
  value = {
    for k, v in nutanix_ndb_network.network : k => {
      name    = v.name
      type    = v.type
      managed = v.managed
    }
  }
}

output "network_ids" {
  description = "Map of network names to IDs"
  value = {
    for k, v in nutanix_ndb_network.network : k => v.id
  }
}

# Clone outputs
output "clones" {
  description = "Details of created NDB clones"
  value = {
    for k, v in nutanix_ndb_clone.clone : k => {
      name          = v.name
      status        = v.status
      database_name = v.database_name
      type          = v.type
    }
  }
}

output "clone_ids" {
  description = "Map of clone names to IDs"
  value = {
    for k, v in nutanix_ndb_clone.clone : k => v.id
  }
}

# Stretched VLAN outputs
output "stretched_vlans" {
  description = "Details of created NDB stretched VLANs"
  value = {
    for k, v in nutanix_ndb_stretched_vlan.stretched_vlan : k => {
      name = v.name
      type = v.type
    }
  }
}

output "stretched_vlan_ids" {
  description = "Map of stretched VLAN names to IDs"
  value = {
    for k, v in nutanix_ndb_stretched_vlan.stretched_vlan : k => v.id
  }
}

# Summary output
output "ndb_summary" {
  description = "Summary of all NDB resources created"
  value = {
    total_databases       = length(nutanix_ndb_database.database)
    total_profiles        = length(nutanix_ndb_profile.profile)
    total_slas            = length(nutanix_ndb_sla.sla)
    total_networks        = length(nutanix_ndb_network.network)
    total_clones          = length(nutanix_ndb_clone.clone)
    total_stretched_vlans = length(nutanix_ndb_stretched_vlan.stretched_vlan)
  }
}
