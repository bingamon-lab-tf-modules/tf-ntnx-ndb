# Validation checks for NDB resources
check "databases_have_profiles" {
  assert {
    condition = alltrue([
      for k, v in var.databases :
      v.dbparameterprofileid != null
    ])
    error_message = "All databases should have a database parameter profile ID configured."
  }
}

check "databases_have_time_machine" {
  assert {
    condition = alltrue([
      for k, v in var.databases :
      v.timemachineinfo != null
    ])
    error_message = "All databases should have time machine info configured for backup."
  }
}

check "static_networks_have_ip_pools" {
  assert {
    condition = alltrue([
      for k, v in var.networks :
      length(v.ip_pools) > 0 if v.type == "Static"
    ])
    error_message = "Static NDB networks should have at least one IP pool configured."
  }
}

check "clones_have_source" {
  assert {
    condition = alltrue([
      for k, v in var.clones :
      v.time_machine_id != null || v.time_machine_name != null
    ])
    error_message = "Clones should reference a time machine by ID or name."
  }
}

check "tms_cluster_requirements" {
  assert {
    condition = alltrue([
      for k, v in var.tms_clusters : (
        v.time_machine_id != null &&
        v.nx_cluster_id != null &&
        v.sla_id != null
      )
    ])
    error_message = "Each time machine cluster must have time_machine_id, nx_cluster_id, and sla_id specified."
  }
}

check "log_catchup_source_requirements" {
  assert {
    condition = alltrue([
      for k, v in var.log_catchups : (
        v.time_machine_id != null ||
        v.database_id != null
      )
    ])
    error_message = "Each log catchup must have either time_machine_id or database_id specified."
  }
}

check "register_database_connection_requirements" {
  assert {
    condition = alltrue([
      for k, v in var.register_databases : (
        v.vm_ip != null
      )
    ])
    error_message = "Each database registration must have vm_ip specified."
  }
}

check "scale_database_requirements" {
  assert {
    condition = alltrue([
      for k, v in var.scale_databases : (
        v.database_uuid != null &&
        v.application_type != null &&
        v.data_storage_size != null &&
        v.data_storage_size > 0
      )
    ])
    error_message = "Each scale operation must have database_uuid, application_type, and data_storage_size > 0."
  }
}

check "stretched_vlan_minimum_vlans" {
  assert {
    condition = alltrue([
      for k, v in var.stretched_vlans : length(v.vlan_ids) >= 2
    ])
    error_message = "Stretched VLANs must have at least 2 VLANs."
  }
}

check "maintenance_task_window_resolvable" {
  assert {
    condition = alltrue([
      for k, v in var.maintenance_tasks : (
        v.maintenance_window_id != null ||
        contains(keys(var.maintenance_windows), coalesce(v.maintenance_window_key, "__unset__"))
      )
    ])
    error_message = "Each maintenance task must resolve its window: set maintenance_window_id, or set maintenance_window_key to an existing key in var.maintenance_windows."
  }
}

check "maintenance_task_targets_dbserver" {
  assert {
    condition = alltrue([
      for k, v in var.maintenance_tasks : (
        (v.dbserver_id != null && length(coalesce(v.dbserver_id, [])) > 0) ||
        (v.dbserver_cluster != null && length(coalesce(v.dbserver_cluster, [])) > 0)
      )
    ])
    error_message = "Each maintenance task should target at least one DB server via dbserver_id or dbserver_cluster."
  }
}

check "dbserver_authorization_time_machine" {
  assert {
    condition = alltrue([
      for k, v in var.dbserver_authorizations : (
        v.time_machine_id != null || v.time_machine_name != null
      )
    ])
    error_message = "Each DB server authorization must reference a time machine by id or name."
  }
}

check "database_restore_source_resolvable" {
  assert {
    condition = alltrue([
      for k, v in var.database_restores : (
        v.database_id != null &&
        (v.snapshot_id != null || v.latest_snapshot != null || v.user_pitr_timestamp != null)
      )
    ])
    error_message = "Each database restore must target a database_id and a resolvable source (snapshot_id, latest_snapshot, or user_pitr_timestamp)."
  }
}
