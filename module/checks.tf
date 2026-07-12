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
