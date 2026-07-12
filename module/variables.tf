# Module configuration
variable "enable_data_lookups" {
  description = "Enable data source lookups for clusters, profiles, and SLAs"
  type        = bool
  default     = false
}

# Database configuration
variable "databases" {
  description = "Map of NDB databases to create"
  type = map(object({
    name                     = string
    description              = optional(string)
    databasetype             = optional(string, "postgres_database")
    softwareprofileid        = optional(string)
    softwareprofileversionid = optional(string)
    computeprofileid         = optional(string)
    networkprofileid         = optional(string)
    dbparameterprofileid     = optional(string)
    nxclusterid              = optional(string)
    sshpublickey             = optional(string)
    createdbserver           = optional(bool, true)
    dbserverid               = optional(string)
    clustered                = optional(bool, false)
    autotunestagingdrive     = optional(bool, true)
    nodecount                = optional(number, 1)
    newdbservertimezone      = optional(string)
    vm_password              = optional(string)

    postgresql_info = optional(object({
      vm_name        = optional(string)
      listener_port  = optional(string)
      database_size  = optional(string)
      db_password    = optional(string)
      database_names = optional(string)
      auth_method    = optional(string)
      ha_instance = optional(object({
        cluster_name             = optional(string)
        patroni_cluster_name     = optional(string)
        proxy_read_port          = optional(string)
        proxy_write_port         = optional(string)
        archive_wal_expire_days  = optional(number)
        backup_policy            = optional(string)
        enable_synchronous_mode  = optional(bool)
        num_synchronous_standbys = optional(number)
        enable_peer_auth         = optional(bool)
      }))
    }))

    nodes = optional(list(object({
      vmname           = optional(string)
      networkprofileid = optional(string)
      computeprofileid = optional(string)
      nx_cluster_id    = optional(string)
      dbserverid       = optional(string)
      properties = optional(list(object({
        name  = string
        value = string
      })))
    })))

    timemachineinfo = optional(object({
      name             = optional(string)
      description      = optional(string)
      slaid            = optional(string)
      autotunelogdrive = optional(bool)
      sla_details = optional(object({
        primary_sla_id = string
        nx_cluster_ids = optional(list(string))
      }))
      schedule = optional(object({
        snapshottimeofday = optional(object({
          hours   = optional(number)
          minutes = optional(number)
          seconds = optional(number)
        }))
        continuousschedule = optional(object({
          enabled           = optional(bool)
          logbackupinterval = optional(number)
          snapshotsperday   = optional(number)
        }))
        weeklyschedule = optional(object({
          enabled   = optional(bool)
          dayofweek = optional(string)
        }))
        monthlyschedule = optional(object({
          enabled    = optional(bool)
          dayofmonth = optional(number)
        }))
        quartelyschedule = optional(object({
          enabled    = optional(bool)
          startmonth = optional(string)
          dayofmonth = optional(number)
        }))
        yearlyschedule = optional(object({
          enabled    = optional(bool)
          dayofmonth = optional(number)
          month      = optional(string)
        }))
      }))
    }))

    actionarguments = optional(list(object({
      name  = string
      value = string
    })))

    delete                 = optional(bool)
    remove                 = optional(bool)
    soft_remove            = optional(bool)
    forced                 = optional(bool)
    delete_time_machine    = optional(bool)
    delete_logical_cluster = optional(bool)
  }))
  default = {}
}

# Profile configuration
variable "profiles" {
  description = "Map of NDB profiles to create"
  type = map(object({
    name        = string
    description = optional(string)
    engine_type = optional(string) # postgres_database, mysql_database, mariadb_database, etc.
    type        = string           # Compute, Database_Parameter, Network, Software
    published   = optional(bool, false)

    # Compute profile settings
    compute = optional(object({
      cpus           = number
      core_per_cpu   = optional(number, 1)
      memory_size_gb = number
    }))

    # Database parameter settings (for postgres)
    database_parameters = optional(object({
      max_connections              = optional(string)
      max_replication_slots        = optional(string)
      effective_io_concurrency     = optional(string)
      timezone                     = optional(string)
      max_prepared_transactions    = optional(string)
      max_locks_per_transaction    = optional(string)
      max_wal_senders              = optional(string)
      max_worker_processes         = optional(string)
      min_wal_size                 = optional(string)
      max_wal_size                 = optional(string)
      checkpoint_timeout           = optional(string)
      autovacuum                   = optional(string)
      checkpoint_completion_target = optional(string)
      synchronous_commit           = optional(string)
      random_page_cost             = optional(string)
    }))

    # Network profile settings
    network = optional(object({
      topology  = string           # single, cluster
      vlan_name = optional(string) # For single instance

      # For HA instance
      ha_instance = optional(object({
        vlan_names      = list(string)
        cluster_names   = list(string)
        num_of_clusters = string
      }))
    }))

    # Software profile settings
    software = optional(object({
      topology              = string # single, cluster
      available_cluster_ids = optional(list(string))

      postgres = optional(object({
        source_dbserver_id               = string
        base_profile_version_name        = string
        base_profile_version_description = optional(string)
        os_notes                         = optional(string)
        db_software_notes                = optional(string)
      }))
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.profiles : v.name != null && v.name != ""
    ])
    error_message = "name is required for all NDB profiles."
  }

  validation {
    condition = alltrue([
      for k, v in var.profiles : contains(["Compute", "Database_Parameter", "Network", "Software"], v.type)
    ])
    error_message = "type must be Compute, Database_Parameter, Network, or Software."
  }

  validation {
    condition = alltrue([
      for k, v in var.profiles : v.type != "Compute" || v.compute != null
    ])
    error_message = "compute settings are required for Compute profiles."
  }
}

# SLA configuration
variable "slas" {
  description = "Map of NDB SLAs to create"
  type = map(object({
    name                 = string
    description          = optional(string)
    continuous_retention = optional(number)
    daily_retention      = optional(number)
    weekly_retention     = optional(number)
    monthly_retention    = optional(number)
    quarterly_retention  = optional(number)
  }))
  default = {}
}

# Network configuration
variable "networks" {
  description = "Map of NDB networks to create"
  type = map(object({
    name          = string
    type          = string
    cluster_id    = string
    gateway       = optional(string)
    subnet_mask   = optional(string)
    primary_dns   = optional(string)
    secondary_dns = optional(string)
    dns_domain    = optional(string)
    ip_pools = optional(list(object({
      start_ip = string
      end_ip   = string
    })), [])
  }))
  default = {}
}

# Clone configuration
variable "clones" {
  description = "Map of NDB database clones to create"
  type = map(object({
    name                          = string
    description                   = optional(string)
    time_machine_id               = optional(string)
    time_machine_name             = optional(string)
    snapshot_id                   = optional(string)
    user_pitr_timestamp           = optional(string)
    latest_snapshot               = optional(bool)
    time_zone                     = optional(string)
    nx_cluster_id                 = optional(string)
    ssh_public_key                = optional(string)
    compute_profile_id            = optional(string)
    network_profile_id            = optional(string)
    database_parameter_profile_id = optional(string)
    vm_password                   = optional(string)
    create_dbserver               = optional(bool, true)
    clustered                     = optional(bool, false)
    node_count                    = optional(number, 1)
    dbserver_cluster_id           = optional(string)
    dbserver_logical_cluster_id   = optional(string)

    nodes = optional(list(object({
      vmname           = optional(string)
      networkprofileid = optional(string)
      computeprofileid = optional(string)
      nx_cluster_id    = optional(string)
      dbserverid       = optional(string)
      properties = optional(list(object({
        name  = string
        value = string
      })))
    })))

    postgresql_info = optional(object({
      vm_name        = optional(string)
      listener_port  = optional(string)
      database_size  = optional(string)
      db_password    = optional(string)
      database_names = optional(string)
      auth_method    = optional(string)
      ha_instance = optional(object({
        cluster_name             = optional(string)
        patroni_cluster_name     = optional(string)
        proxy_read_port          = optional(string)
        proxy_write_port         = optional(string)
        archive_wal_expire_days  = optional(number)
        backup_policy            = optional(string)
        enable_synchronous_mode  = optional(bool)
        num_synchronous_standbys = optional(number)
        enable_peer_auth         = optional(bool)
      }))
    }))

    actionarguments = optional(list(object({
      name  = string
      value = string
    })))

    delete                 = optional(bool)
    remove                 = optional(bool)
    soft_remove            = optional(bool)
    forced                 = optional(bool)
    delete_time_machine    = optional(bool)
    delete_logical_cluster = optional(bool)
  }))
  default = {}
}

# Stretched VLAN configuration
variable "stretched_vlans" {
  description = "Map of NDB stretched VLANs to create"
  type = map(object({
    name        = string
    description = optional(string)
    type        = string
    vlan_ids    = list(string)
    metadata = optional(object({
      gateway     = optional(string)
      subnet_mask = optional(string)
    }))
  }))
  default = {}
}

# Clone refresh configuration
variable "clone_refreshes" {
  description = "Map of NDB clone refresh operations"
  type = map(object({
    clone_id            = string
    snapshot_id         = optional(string)
    user_pitr_timestamp = optional(string)
    timezone            = optional(string, "UTC")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.clone_refreshes : v.clone_id != null && v.clone_id != ""
    ])
    error_message = "clone_id is required for all NDB clone refreshes."
  }
}

# Time machine cluster configuration
variable "tms_clusters" {
  description = "Map of NDB time machine clusters for data availability across registered Nutanix clusters"
  type = map(object({
    time_machine_id = string
    nx_cluster_id   = string
    sla_id          = string
    type            = optional(string, "OTHER")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.tms_clusters : v.time_machine_id != null && v.time_machine_id != ""
    ])
    error_message = "time_machine_id is required for all NDB time machine clusters."
  }

  validation {
    condition = alltrue([
      for k, v in var.tms_clusters : v.nx_cluster_id != null && v.nx_cluster_id != ""
    ])
    error_message = "nx_cluster_id is required for all NDB time machine clusters."
  }

  validation {
    condition = alltrue([
      for k, v in var.tms_clusters : v.sla_id != null && v.sla_id != ""
    ])
    error_message = "sla_id is required for all NDB time machine clusters."
  }
}

# Log catchup configuration
variable "log_catchups" {
  description = "Map of NDB log catchup operations for database instances"
  type = map(object({
    time_machine_id     = optional(string)
    database_id         = optional(string)
    for_restore         = optional(bool, false)
    log_catchup_version = optional(number)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.log_catchups : (
        (v.time_machine_id != null && v.time_machine_id != "") ||
        (v.database_id != null && v.database_id != "")
      )
    ])
    error_message = "Either time_machine_id or database_id is required for all NDB log catchups."
  }
}

# Register database configuration
variable "register_databases" {
  description = "Map of existing databases to register with NDB"
  type = map(object({
    database_type = string # postgres_database
    database_name = string
    description   = optional(string)
    category      = optional(string, "DEFAULT")

    # Cluster placement
    nx_cluster_id = optional(string)

    # VM connection details
    vm_ip          = string
    vm_username    = optional(string)
    vm_password    = optional(string)
    vm_sshkey      = optional(string)
    vm_description = optional(string)

    # Registration options
    clustered                       = optional(bool, false)
    forced_install                  = optional(bool, true)
    auto_tune_staging_drive         = optional(bool, true)
    working_directory               = optional(string, "/tmp")
    reset_description_in_nx_cluster = optional(bool, false)

    # PostgreSQL specific configuration
    postgress_info = optional(object({
      listener_port            = string
      db_password              = string
      db_name                  = string
      db_user                  = optional(string, "postgres")
      switch_log               = optional(bool, true)
      allow_multiple_databases = optional(bool, true)
      backup_policy            = optional(string, "prefer_secondary")
      postgres_software_home   = string
      software_home            = optional(string)
    }))

    # Time Machine configuration
    time_machine_info = optional(object({
      name                = string
      description         = optional(string)
      sla_id              = optional(string)
      auto_tune_log_drive = optional(bool, true)

      # For HA instances
      sla_details = optional(object({
        primary_sla_id = string
        nx_cluster_ids = optional(list(string))
      }))

      schedule = optional(object({
        snapshot_time_of_day = optional(object({
          hours   = number
          minutes = number
          seconds = optional(number, 0)
        }))

        continuous_schedule = optional(object({
          enabled             = bool
          log_backup_interval = number
          snapshots_per_day   = number
        }))

        weekly_schedule = optional(object({
          enabled     = bool
          day_of_week = string # MONDAY, TUESDAY, etc.
        }))

        monthly_schedule = optional(object({
          enabled      = bool
          day_of_month = string
        }))

        quarterly_schedule = optional(object({
          enabled      = bool
          start_month  = string # JANUARY, APRIL, JULY, OCTOBER
          day_of_month = number
        }))

        yearly_schedule = optional(object({
          enabled      = bool
          month        = string
          day_of_month = number
        }))
      }))
    }))

    # Tags
    tags = optional(list(object({
      tag_id    = string
      tag_value = string
    })))

    # Action arguments
    action_arguments = optional(list(object({
      name  = string
      value = string
    })))

    # Delete options
    delete_on_destroy      = optional(bool, false)
    remove_on_destroy      = optional(bool, true)
    soft_remove            = optional(bool, false)
    forced_delete          = optional(bool, false)
    delete_time_machine    = optional(bool, true)
    delete_logical_cluster = optional(bool, true)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.register_databases : v.database_name != null && v.database_name != ""
    ])
    error_message = "database_name is required for all NDB register databases."
  }

  validation {
    condition = alltrue([
      for k, v in var.register_databases : v.vm_ip != null && v.vm_ip != ""
    ])
    error_message = "vm_ip is required for all NDB register databases."
  }

  validation {
    condition = alltrue([
      for k, v in var.register_databases : v.database_type == "postgres_database"
    ])
    error_message = "database_type must be postgres_database."
  }
}

# Scale database configuration
variable "scale_databases" {
  description = "Map of NDB database scale operations"
  type = map(object({
    database_uuid     = string
    application_type  = string # postgres_database
    data_storage_size = number # Storage to add in GiB
    pre_script_cmd    = optional(string)
    post_script_cmd   = optional(string)
    scale_count       = optional(number)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.scale_databases : v.database_uuid != null && v.database_uuid != ""
    ])
    error_message = "database_uuid is required for all NDB scale databases."
  }

  validation {
    condition = alltrue([
      for k, v in var.scale_databases : v.application_type != null && v.application_type != ""
    ])
    error_message = "application_type is required for all NDB scale databases."
  }

  validation {
    condition = alltrue([
      for k, v in var.scale_databases : v.data_storage_size != null && v.data_storage_size > 0
    ])
    error_message = "data_storage_size must be greater than 0 for all NDB scale databases."
  }
}
