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
