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
  description = <<-EOT
    Map of NDB clone refresh operations (nutanix_ndb_clone_refresh). ONE-SHOT:
    the refresh runs on create; re-running requires a NEW for_each key, and
    destroy does not undo a refresh already applied. Same semantics as
    database_snapshots / database_restores below.
  EOT
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
  description = <<-EOT
    Map of NDB log catchup operations for database instances
    (nutanix_ndb_log_catchups). ONE-SHOT: the catchup runs on create;
    re-running requires a NEW for_each key, and destroy does not undo it.
  EOT
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
  description = <<-EOT
    Map of NDB database scale operations (nutanix_ndb_database_scale).
    ONE-SHOT: the scale runs on create; scaling again requires a NEW for_each
    key, and destroy does NOT scale the database back down. The config becomes
    append-only history of scale events, not a declaration of desired size.
  EOT
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

##################################################
# DB server VM family (issue 590)
#
# NOTE: every NDB resource requires a reachable NDB endpoint. Configure
# NDB_ENDPOINT / NDB_USERNAME / NDB_PASSWORD (provider ndb_endpoint /
# ndb_username / ndb_password) or all NDB resources fail at apply.
#
# Credentials for these resources are NOT carried in the map(object) inputs
# below (which are meant to be populated from PC YAML); they live in the
# matching `sensitive = true` credential vars, keyed by the same map key.
##################################################

# DB server VM configuration
variable "dbservervms" {
  description = "Map of NDB DB server VMs to provision. Each entry needs a software profile (software_profile_id or software_profile_version_id) plus a network profile. Passwords are supplied via var.dbservervm_credentials, not here (spec §10)."
  type = map(object({
    database_type               = optional(string, "postgres_database")
    compute_profile_id          = string
    network_profile_id          = string
    nx_cluster_id               = string
    software_profile_id         = optional(string)
    software_profile_version_id = optional(string)
    description                 = optional(string)
    latest_snapshot             = optional(bool)
    snapshot_id                 = optional(string)
    time_machine_id             = optional(string)
    timezone                    = optional(string)

    postgres_database = optional(object({
      vm_name           = string
      client_public_key = optional(string)
    }))

    maintenance_tasks = optional(object({
      maintenance_window_id = optional(string)
      tasks = optional(list(object({
        task_type    = optional(string)
        pre_command  = optional(string)
        post_command = optional(string)
      })))
    }))

    tags = optional(list(object({
      tag_id = optional(string)
      value  = optional(string)
    })))

    delete              = optional(bool)
    remove              = optional(bool)
    soft_remove         = optional(bool)
    delete_vgs          = optional(bool)
    delete_vm_snapshots = optional(bool)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.dbservervms : (
        v.software_profile_id != null && v.software_profile_version_id != null
      )
    ])
    error_message = "Each DB server VM must reference a software profile via BOTH software_profile_id and software_profile_version_id (the provider requires the pair)."
  }

  validation {
    condition = alltrue([
      for k, v in var.dbservervms : v.network_profile_id != null && v.network_profile_id != ""
    ])
    error_message = "network_profile_id is required for all DB server VMs."
  }
}

# DB server VM sensitive credentials (keyed to match var.dbservervms)
variable "dbservervm_credentials" {
  description = "Sensitive credentials for DB server VMs, keyed to match var.dbservervms. Keep passwords out of YAML (spec §10)."
  type = map(object({
    vm_password = optional(string)
  }))
  default   = {}
  sensitive = true
}

# DB server VM registration configuration (existing VMs)
variable "dbservervm_registrations" {
  description = "Map of existing DB server VMs to register with NDB. Login credentials (username/password/ssh_key) are supplied via var.dbservervm_registration_credentials, not here (spec §10)."
  type = map(object({
    database_type                      = optional(string, "postgres_database")
    vm_ip                              = string
    nxcluster_id                       = optional(string)
    name                               = optional(string)
    description                        = optional(string)
    forced_install                     = optional(bool)
    working_directory                  = optional(string)
    update_name_description_in_cluster = optional(bool)

    postgres_database = optional(object({
      listener_port          = optional(string)
      postgres_software_home = optional(string)
    }))

    tags = optional(list(object({
      tag_id = optional(string)
      value  = optional(string)
    })))

    delete              = optional(bool)
    remove              = optional(bool)
    soft_remove         = optional(bool)
    delete_vgs          = optional(bool)
    delete_vm_snapshots = optional(bool)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.dbservervm_registrations : v.vm_ip != null && v.vm_ip != ""
    ])
    error_message = "vm_ip is required for all DB server VM registrations."
  }
}

# DB server VM registration sensitive credentials (keyed to match registrations)
variable "dbservervm_registration_credentials" {
  description = "Sensitive login credentials for DB server VM registrations, keyed to match var.dbservervm_registrations. Keep secrets out of YAML (spec §10)."
  type = map(object({
    username = optional(string)
    password = optional(string)
    ssh_key  = optional(string)
  }))
  default   = {}
  sensitive = true
}

# DB server authorization configuration (authorize DB servers against a time machine)
variable "dbserver_authorizations" {
  description = "Map of NDB DB server authorizations against a time machine. Each entry references a time machine by id or name."
  type = map(object({
    dbservers_id      = optional(list(string))
    time_machine_id   = optional(string)
    time_machine_name = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.dbserver_authorizations : (
        (v.time_machine_id != null && v.time_machine_id != "") ||
        (v.time_machine_name != null && v.time_machine_name != "")
      )
    ])
    error_message = "Each DB server authorization must reference a time machine by time_machine_id or time_machine_name."
  }
}

# NDB cluster registration configuration (register a Nutanix PE cluster with NDB)
variable "clusters" {
  description = "Map of Nutanix PE clusters to register with NDB (multi-cluster NDB). Admin credentials are supplied via var.cluster_credentials, not here (spec §10)."
  type = map(object({
    name              = string
    cluster_ip        = string
    storage_container = string
    description       = optional(string)
    agent_vm_prefix   = optional(string)
    cluster_type      = optional(string)
    port              = optional(number)
    protocol          = optional(string)
    version           = optional(string)

    agent_network_info = optional(object({
      dns = optional(string)
      ntp = optional(string)
    }))

    networks_info = optional(list(object({
      access_type = optional(list(string))
      type        = optional(string)
      network_info = optional(object({
        gateway     = optional(string)
        static_ip   = optional(string)
        subnet_mask = optional(string)
        vlan_name   = optional(string)
      }))
    })))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.clusters : (
        v.name != null && v.name != "" &&
        v.cluster_ip != null && v.cluster_ip != "" &&
        v.storage_container != null && v.storage_container != ""
      )
    ])
    error_message = "name, cluster_ip, and storage_container are required for all NDB cluster registrations."
  }
}

# NDB cluster registration sensitive credentials (keyed to match var.clusters)
variable "cluster_credentials" {
  description = "Sensitive admin credentials for NDB cluster registrations, keyed to match var.clusters. Keep secrets out of YAML (spec §10)."
  type = map(object({
    username = optional(string)
    password = optional(string)
  }))
  default   = {}
  sensitive = true
}

##################################################
# Maintenance and tags (issue 590)
##################################################

# Maintenance window configuration
variable "maintenance_windows" {
  description = "Map of NDB maintenance windows. recurrence must be WEEKLY or MONTHLY; day_of_week (when set) must be an uppercase weekday."
  type = map(object({
    name          = string
    recurrence    = string # WEEKLY, MONTHLY
    start_time    = string
    description   = optional(string)
    duration      = optional(number)
    day_of_week   = optional(string) # MONDAY..SUNDAY
    week_of_month = optional(number)
    timezone      = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.maintenance_windows : contains(["WEEKLY", "MONTHLY"], v.recurrence)
    ])
    error_message = "recurrence must be WEEKLY or MONTHLY for all NDB maintenance windows."
  }

  validation {
    condition = alltrue([
      for k, v in var.maintenance_windows : (
        v.day_of_week == null ||
        contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], coalesce(v.day_of_week, "MONDAY"))
      )
    ])
    error_message = "day_of_week must be an uppercase weekday (MONDAY..SUNDAY) for NDB maintenance windows."
  }
}

# Maintenance task configuration (associate maintenance tasks to DB servers)
variable "maintenance_tasks" {
  description = "Map of NDB maintenance tasks. Reference the target window by maintenance_window_id (direct) or maintenance_window_key (a key in var.maintenance_windows, resolved to the created window's id). Each task should target a DB server via dbserver_id or dbserver_cluster."
  type = map(object({
    maintenance_window_id  = optional(string)
    maintenance_window_key = optional(string)
    dbserver_id            = optional(list(string))
    dbserver_cluster       = optional(list(string))
    tasks = optional(list(object({
      task_type    = optional(string)
      pre_command  = optional(string)
      post_command = optional(string)
    })))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.maintenance_tasks : (
        (v.maintenance_window_id != null && v.maintenance_window_id != "") ||
        (v.maintenance_window_key != null && v.maintenance_window_key != "")
      )
    ])
    error_message = "Each maintenance task must set maintenance_window_id or maintenance_window_key."
  }
}

# Tag configuration
variable "tags" {
  description = "Map of NDB tags to create."
  type = map(object({
    name        = string
    entity_type = string
    description = optional(string)
    required    = optional(bool)
    status      = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.tags : (
        v.name != null && v.name != "" &&
        v.entity_type != null && v.entity_type != ""
      )
    ])
    error_message = "name and entity_type are required for all NDB tags."
  }
}

##################################################
# Snapshot / restore one-shot actions (issue 590)
##################################################

# Database snapshot configuration (one-shot time-machine snapshot)
variable "database_snapshots" {
  description = "Map of one-shot NDB time-machine snapshot actions. Each entry references a time machine by time_machine_id or time_machine_name. One-shot semantics: the snapshot is taken on create; re-taking requires a NEW for_each key; destroy does not undo a snapshot already taken."
  type = map(object({
    name                    = optional(string)
    time_machine_id         = optional(string)
    time_machine_name       = optional(string)
    expiry_date_timezone    = optional(string)
    remove_schedule_in_days = optional(number)
    replicate_to_clusters   = optional(list(string))
    tags = optional(list(object({
      tag_id = optional(string)
      value  = optional(string)
    })))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.database_snapshots : (
        (v.time_machine_id != null && v.time_machine_id != "") ||
        (v.time_machine_name != null && v.time_machine_name != "")
      )
    ])
    error_message = "Each database snapshot must reference a time machine by time_machine_id or time_machine_name."
  }
}

# Database restore configuration (one-shot restore action)
variable "database_restores" {
  description = "Map of one-shot NDB database restore actions. Each entry targets a database_id and a source: snapshot_id, latest_snapshot, or user_pitr_timestamp. One-shot semantics: the restore runs on create; re-running requires a NEW for_each key; destroy does not undo a restore already applied."
  type = map(object({
    database_id         = string
    snapshot_id         = optional(string)
    latest_snapshot     = optional(string)
    user_pitr_timestamp = optional(string)
    time_zone_pitr      = optional(string)
    restore_version     = optional(number)
    tags = optional(list(object({
      tag_id = optional(string)
      value  = optional(string)
    })))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.database_restores : v.database_id != null && v.database_id != ""
    ])
    error_message = "database_id is required for all NDB database restores."
  }

  validation {
    condition = alltrue([
      for k, v in var.database_restores : (
        (v.snapshot_id != null && v.snapshot_id != "") ||
        (v.latest_snapshot != null && v.latest_snapshot != "") ||
        (v.user_pitr_timestamp != null && v.user_pitr_timestamp != "")
      )
    ])
    error_message = "Each database restore must reference a source: snapshot_id, latest_snapshot, or user_pitr_timestamp."
  }
}

##################################################
# Software profile version (issue 590)
##################################################

# Software profile version configuration (publish a new version of a software profile)
variable "software_profile_versions" {
  description = "Map of new software-profile versions to publish against an existing software profile (profile_id)."
  type = map(object({
    name                  = string
    engine_type           = string
    profile_id            = string
    description           = optional(string)
    status                = optional(string)
    available_cluster_ids = optional(list(string))
    postgres_database = optional(object({
      source_dbserver_id = optional(string)
      os_notes           = optional(string)
      db_software_notes  = optional(string)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.software_profile_versions : (
        v.name != null && v.name != "" &&
        v.engine_type != null && v.engine_type != "" &&
        v.profile_id != null && v.profile_id != ""
      )
    ])
    error_message = "name, engine_type, and profile_id are required for all NDB software profile versions."
  }
}
