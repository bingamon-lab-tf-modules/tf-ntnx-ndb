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
  value       = local.out_profiles
}

output "profile_ids" {
  description = "Map of profile names to IDs"
  value       = local.out_profile_ids
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

output "available_dbserver_ids" {
  description = "Map of existing (data-lookup) NDB DB server names to IDs. Populated only when enable_data_lookups is true."
  value       = local.dbserver_id_by_name
}

output "available_maintenance_window_ids" {
  description = "Map of existing (data-lookup) NDB maintenance window names to IDs. Populated only when enable_data_lookups is true."
  value       = local.maintenance_window_id_by_name
}

output "available_tag_ids" {
  description = "Map of existing (data-lookup) NDB tag names to IDs. Populated only when enable_data_lookups is true."
  value       = local.tag_id_by_name
}

output "available_snapshot_ids" {
  description = "Map of existing (data-lookup) NDB snapshot names to IDs. Populated only when enable_data_lookups is true."
  value       = local.snapshot_id_by_name
}

# DB server VM outputs
output "dbservervms" {
  description = "Details of provisioned NDB DB server VMs"
  value = {
    for k, v in nutanix_ndb_dbserver_vm.dbservervm : k => {
      id           = v.id
      name         = v.name
      status       = v.status
      ip_addresses = v.ip_addresses
      era_version  = v.era_version
    }
  }
}

output "dbservervm_ids" {
  description = "Map of DB server VM keys to IDs"
  value = {
    for k, v in nutanix_ndb_dbserver_vm.dbservervm : k => v.id
  }
}

# DB server VM registration outputs
output "dbservervm_registrations" {
  description = "Details of registered NDB DB server VMs"
  value = {
    for k, v in nutanix_ndb_register_dbserver.dbservervm_registration : k => {
      id     = v.id
      name   = v.name
      status = v.status
      vm_ip  = v.vm_ip
    }
  }
}

output "dbservervm_registration_ids" {
  description = "Map of DB server VM registration keys to IDs"
  value = {
    for k, v in nutanix_ndb_register_dbserver.dbservervm_registration : k => v.id
  }
}

# DB server authorization outputs
output "dbserver_authorizations" {
  description = "Details of NDB DB server authorizations"
  value = {
    for k, v in nutanix_ndb_authorize_dbserver.dbserver_authorization : k => {
      id                = v.id
      time_machine_id   = v.time_machine_id
      time_machine_name = v.time_machine_name
    }
  }
}

output "dbserver_authorization_ids" {
  description = "Map of DB server authorization keys to IDs"
  value = {
    for k, v in nutanix_ndb_authorize_dbserver.dbserver_authorization : k => v.id
  }
}

# Maintenance window outputs
output "maintenance_windows" {
  description = "Details of NDB maintenance windows"
  value = {
    for k, v in nutanix_ndb_maintenance_window.maintenance_window : k => {
      id            = v.id
      name          = v.name
      status        = v.status
      next_run_time = v.next_run_time
    }
  }
}

output "maintenance_window_ids" {
  description = "Map of maintenance window keys to IDs"
  value = {
    for k, v in nutanix_ndb_maintenance_window.maintenance_window : k => v.id
  }
}

# Maintenance task outputs
output "maintenance_tasks" {
  description = "Details of NDB maintenance tasks"
  value = {
    for k, v in nutanix_ndb_maintenance_task.maintenance_task : k => {
      id                    = v.id
      maintenance_window_id = v.maintenance_window_id
    }
  }
}

output "maintenance_task_ids" {
  description = "Map of maintenance task keys to IDs"
  value = {
    for k, v in nutanix_ndb_maintenance_task.maintenance_task : k => v.id
  }
}

# Tag outputs
output "tags" {
  description = "Details of NDB tags"
  value = {
    for k, v in nutanix_ndb_tag.tag : k => {
      id          = v.id
      name        = v.name
      entity_type = v.entity_type
      status      = v.status
    }
  }
}

output "tag_ids" {
  description = "Map of tag keys to IDs"
  value = {
    for k, v in nutanix_ndb_tag.tag : k => v.id
  }
}

# Cluster registration outputs
output "clusters" {
  description = "Details of NDB-registered Nutanix PE clusters"
  value = {
    for k, v in nutanix_ndb_cluster.cluster : k => {
      id          = v.id
      name        = v.name
      status      = v.status
      unique_name = v.unique_name
    }
  }
}

output "cluster_ids" {
  description = "Map of cluster registration keys to IDs"
  value = {
    for k, v in nutanix_ndb_cluster.cluster : k => v.id
  }
}

# Database snapshot outputs
output "database_snapshots" {
  description = "Details of NDB database snapshots"
  value = {
    for k, v in nutanix_ndb_database_snapshot.database_snapshot : k => {
      id            = v.id
      name          = v.name
      status        = v.status
      snapshot_uuid = v.snapshot_uuid
    }
  }
}

output "database_snapshot_ids" {
  description = "Map of database snapshot keys to IDs"
  value = {
    for k, v in nutanix_ndb_database_snapshot.database_snapshot : k => v.id
  }
}

# Database restore outputs
output "database_restores" {
  description = "Details of NDB database restore actions"
  value = {
    for k, v in nutanix_ndb_database_restore.database_restore : k => {
      id          = v.id
      status      = v.status
      database_id = v.database_id
    }
  }
}

output "database_restore_ids" {
  description = "Map of database restore keys to IDs"
  value = {
    for k, v in nutanix_ndb_database_restore.database_restore : k => v.id
  }
}

# Software profile version outputs
output "software_profile_versions" {
  description = "Details of published NDB software profile versions"
  value = {
    for k, v in nutanix_ndb_software_version_profile.software_profile_version : k => {
      id         = v.id
      name       = v.name
      version    = v.version
      db_version = v.db_version
    }
  }
}

output "software_profile_version_ids" {
  description = "Map of software profile version keys to IDs"
  value = {
    for k, v in nutanix_ndb_software_version_profile.software_profile_version : k => v.id
  }
}

# Connection-string outputs
#
# Per-database connection details derived from the provider-exported attributes
# of nutanix_ndb_database.database. NDB exposes per-node connection metadata in
# the computed database_nodes[*].dbserver map and per-database runtime metadata
# in the computed properties list; both are only fully known after apply. The
# configured listener port is surfaced from the module input so consumers can
# assemble endpoints without a second lookup.
output "database_connection_strings" {
  description = "Map of database keys to connection details (exported nodes, properties, configured listener port, and a best-effort URI) derived from NDB-exported attributes of nutanix_ndb_database.database. Sensitive."
  sensitive   = true
  value       = local.out_database_connection_strings
}

# Summary output
output "ndb_summary" {
  description = "Summary of all NDB resources created"
  value       = local.out_ndb_summary
}

# ---------------------------------------------------------------------------
# Aggregate output (spec §7.6 contract)
# ---------------------------------------------------------------------------
output "outputs" {
  description = "Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs)."
  sensitive   = true
  value = {
    databases = {
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
    database_ids = {
      for k, v in nutanix_ndb_database.database : k => v.id
    }
    profiles    = local.out_profiles
    profile_ids = local.out_profile_ids
    slas = {
      for k, v in nutanix_ndb_sla.sla : k => {
        name                 = v.name
        unique_name          = v.unique_name
        continuous_retention = v.continuous_retention
        daily_retention      = v.daily_retention
      }
    }
    sla_ids = {
      for k, v in nutanix_ndb_sla.sla : k => v.id
    }
    networks = {
      for k, v in nutanix_ndb_network.network : k => {
        name    = v.name
        type    = v.type
        managed = v.managed
      }
    }
    network_ids = {
      for k, v in nutanix_ndb_network.network : k => v.id
    }
    clones = {
      for k, v in nutanix_ndb_clone.clone : k => {
        name          = v.name
        status        = v.status
        database_name = v.database_name
        type          = v.type
      }
    }
    clone_ids = {
      for k, v in nutanix_ndb_clone.clone : k => v.id
    }
    stretched_vlans = {
      for k, v in nutanix_ndb_stretched_vlan.stretched_vlan : k => {
        name = v.name
        type = v.type
      }
    }
    stretched_vlan_ids = {
      for k, v in nutanix_ndb_stretched_vlan.stretched_vlan : k => v.id
    }
    tms_clusters = {
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
    tms_cluster_ids = {
      for k, v in nutanix_ndb_tms_cluster.tms_cluster : k => v.id
    }
    log_catchups = {
      for k, v in nutanix_ndb_log_catchups.log_catchup : k => {
        id              = v.id
        time_machine_id = v.time_machine_id
        database_id     = v.database_id
        for_restore     = v.for_restore
      }
    }
    log_catchup_ids = {
      for k, v in nutanix_ndb_log_catchups.log_catchup : k => v.id
    }
    registered_databases = {
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
    registered_database_ids = {
      for k, v in nutanix_ndb_register_database.register_database : k => v.id
    }
    scaled_databases = {
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
    scaled_database_ids = {
      for k, v in nutanix_ndb_database_scale.database_scale : k => v.id
    }
    available_cluster_ids            = local.cluster_id_by_name
    available_sla_ids                = local.sla_id_by_name
    available_profile_ids            = local.all_profile_ids
    available_dbserver_ids           = local.dbserver_id_by_name
    available_maintenance_window_ids = local.maintenance_window_id_by_name
    available_tag_ids                = local.tag_id_by_name
    available_snapshot_ids           = local.snapshot_id_by_name
    dbservervms = {
      for k, v in nutanix_ndb_dbserver_vm.dbservervm : k => {
        id           = v.id
        name         = v.name
        status       = v.status
        ip_addresses = v.ip_addresses
        era_version  = v.era_version
      }
    }
    dbservervm_ids = {
      for k, v in nutanix_ndb_dbserver_vm.dbservervm : k => v.id
    }
    dbservervm_registrations = {
      for k, v in nutanix_ndb_register_dbserver.dbservervm_registration : k => {
        id     = v.id
        name   = v.name
        status = v.status
        vm_ip  = v.vm_ip
      }
    }
    dbservervm_registration_ids = {
      for k, v in nutanix_ndb_register_dbserver.dbservervm_registration : k => v.id
    }
    dbserver_authorizations = {
      for k, v in nutanix_ndb_authorize_dbserver.dbserver_authorization : k => {
        id                = v.id
        time_machine_id   = v.time_machine_id
        time_machine_name = v.time_machine_name
      }
    }
    dbserver_authorization_ids = {
      for k, v in nutanix_ndb_authorize_dbserver.dbserver_authorization : k => v.id
    }
    maintenance_windows = {
      for k, v in nutanix_ndb_maintenance_window.maintenance_window : k => {
        id            = v.id
        name          = v.name
        status        = v.status
        next_run_time = v.next_run_time
      }
    }
    maintenance_window_ids = {
      for k, v in nutanix_ndb_maintenance_window.maintenance_window : k => v.id
    }
    maintenance_tasks = {
      for k, v in nutanix_ndb_maintenance_task.maintenance_task : k => {
        id                    = v.id
        maintenance_window_id = v.maintenance_window_id
      }
    }
    maintenance_task_ids = {
      for k, v in nutanix_ndb_maintenance_task.maintenance_task : k => v.id
    }
    tags = {
      for k, v in nutanix_ndb_tag.tag : k => {
        id          = v.id
        name        = v.name
        entity_type = v.entity_type
        status      = v.status
      }
    }
    tag_ids = {
      for k, v in nutanix_ndb_tag.tag : k => v.id
    }
    clusters = {
      for k, v in nutanix_ndb_cluster.cluster : k => {
        id          = v.id
        name        = v.name
        status      = v.status
        unique_name = v.unique_name
      }
    }
    cluster_ids = {
      for k, v in nutanix_ndb_cluster.cluster : k => v.id
    }
    database_snapshots = {
      for k, v in nutanix_ndb_database_snapshot.database_snapshot : k => {
        id            = v.id
        name          = v.name
        status        = v.status
        snapshot_uuid = v.snapshot_uuid
      }
    }
    database_snapshot_ids = {
      for k, v in nutanix_ndb_database_snapshot.database_snapshot : k => v.id
    }
    database_restores = {
      for k, v in nutanix_ndb_database_restore.database_restore : k => {
        id          = v.id
        status      = v.status
        database_id = v.database_id
      }
    }
    database_restore_ids = {
      for k, v in nutanix_ndb_database_restore.database_restore : k => v.id
    }
    software_profile_versions = {
      for k, v in nutanix_ndb_software_version_profile.software_profile_version : k => {
        id         = v.id
        name       = v.name
        version    = v.version
        db_version = v.db_version
      }
    }
    software_profile_version_ids = {
      for k, v in nutanix_ndb_software_version_profile.software_profile_version : k => v.id
    }
    database_connection_strings = local.out_database_connection_strings
    ndb_summary                 = local.out_ndb_summary
  }
}
