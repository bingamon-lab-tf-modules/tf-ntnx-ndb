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
      time_machine_id       = v.time_machine_id
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
  value = merge(
    {
      for k, v in nutanix_ndb_profile.compute_profile : k => {
        id                = v.id
        name              = v.name
        type              = "Compute"
        status            = v.status
        engine_type       = v.engine_type
        published         = v.published
        latest_version_id = v.latest_version_id
      }
    },
    {
      for k, v in nutanix_ndb_profile.database_parameter_profile : k => {
        id                = v.id
        name              = v.name
        type              = "Database_Parameter"
        status            = v.status
        engine_type       = v.engine_type
        published         = v.published
        latest_version_id = v.latest_version_id
      }
    },
    {
      for k, v in nutanix_ndb_profile.network_profile : k => {
        id                = v.id
        name              = v.name
        type              = "Network"
        status            = v.status
        engine_type       = v.engine_type
        published         = v.published
        latest_version_id = v.latest_version_id
      }
    },
    {
      for k, v in nutanix_ndb_profile.software_profile : k => {
        id                = v.id
        name              = v.name
        type              = "Software"
        status            = v.status
        engine_type       = v.engine_type
        published         = v.published
        latest_version_id = v.latest_version_id
      }
    }
  )
}

output "profile_ids" {
  description = "Map of profile names to IDs"
  value = merge(
    { for k, v in nutanix_ndb_profile.compute_profile : k => v.id },
    { for k, v in nutanix_ndb_profile.database_parameter_profile : k => v.id },
    { for k, v in nutanix_ndb_profile.network_profile : k => v.id },
    { for k, v in nutanix_ndb_profile.software_profile : k => v.id }
  )
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

# Time machine cluster outputs
output "tms_clusters" {
  description = "Details of configured NDB time machine clusters"
  value = {
    for k, v in nutanix_ndb_tms_cluster.tms_cluster : k => {
      id               = v.id
      time_machine_id  = v.time_machine_id
      nx_cluster_id    = v.nx_cluster_id
      sla_id           = v.sla_id
      status           = v.status
      schedule_id      = v.schedule_id
      owner_id         = v.owner_id
      log_drive_id     = v.log_drive_id
      log_drive_status = v.log_drive_status
      date_created     = v.date_created
      date_modified    = v.date_modified
    }
  }
}

output "tms_cluster_ids" {
  description = "Map of time machine cluster names to IDs"
  value = {
    for k, v in nutanix_ndb_tms_cluster.tms_cluster : k => v.id
  }
}

# Log catchup outputs
output "log_catchups" {
  description = "Details of NDB log catchup operations"
  value = {
    for k, v in nutanix_ndb_log_catchups.log_catchup : k => {
      id              = v.id
      time_machine_id = v.time_machine_id
      database_id     = v.database_id
      for_restore     = v.for_restore
    }
  }
}

output "log_catchup_ids" {
  description = "Map of log catchup names to IDs"
  value = {
    for k, v in nutanix_ndb_log_catchups.log_catchup : k => v.id
  }
}

# Registered database outputs
output "registered_databases" {
  description = "Details of registered NDB databases"
  value = {
    for k, v in nutanix_ndb_register_database.register_database : k => {
      id              = v.id
      name            = v.name
      database_name   = v.database_name
      database_type   = v.databasetype
      status          = v.status
      database_status = v.database_status
      time_machine_id = v.time_machine_id
      time_zone       = v.time_zone
      date_created    = v.date_created
      date_modified   = v.date_modified
    }
  }
  sensitive = true
}

output "registered_database_ids" {
  description = "Map of registered database names to IDs"
  value = {
    for k, v in nutanix_ndb_register_database.register_database : k => v.id
  }
}

# Scaled database outputs
output "scaled_databases" {
  description = "Details of scaled NDB databases"
  value = {
    for k, v in nutanix_ndb_database_scale.database_scale : k => {
      id              = v.id
      name            = v.name
      database_name   = v.database_name
      database_type   = v.databasetype
      status          = v.status
      time_machine_id = v.time_machine_id
      date_created    = v.date_created
      date_modified   = v.date_modified
    }
  }
}

output "scaled_database_ids" {
  description = "Map of scaled database names to IDs"
  value = {
    for k, v in nutanix_ndb_database_scale.database_scale : k => v.id
  }
}

# Data lookup outputs (populated only when enable_data_lookups is true)
output "available_cluster_ids" {
  description = "Map of existing (data-lookup) NDB cluster names to IDs. Populated only when enable_data_lookups is true."
  value       = local.cluster_id_by_name
}

output "available_sla_ids" {
  description = "Map of existing (data-lookup) NDB SLA names to IDs. Populated only when enable_data_lookups is true."
  value       = local.sla_id_by_name
}

output "available_profile_ids" {
  description = "Map of existing (data-lookup) NDB profile names to IDs across compute, software, network, and database-parameter profiles. Populated only when enable_data_lookups is true."
  value       = local.all_profile_ids
}

# Summary output
output "ndb_summary" {
  description = "Summary of all NDB resources created"
  value = {
    total_databases = length(nutanix_ndb_database.database)
    total_profiles = (
      length(nutanix_ndb_profile.compute_profile) +
      length(nutanix_ndb_profile.database_parameter_profile) +
      length(nutanix_ndb_profile.network_profile) +
      length(nutanix_ndb_profile.software_profile)
    )
    total_slas            = length(nutanix_ndb_sla.sla)
    total_networks        = length(nutanix_ndb_network.network)
    total_clones          = length(nutanix_ndb_clone.clone)
    total_stretched_vlans = length(nutanix_ndb_stretched_vlan.stretched_vlan)
  }
}
