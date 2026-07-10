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
    engine_type = string
    published   = optional(bool, false)

    compute_profile = optional(object({
      cpus         = number
      core_per_cpu = number
      memory_size  = number
    }))

    software_profile = optional(object({
      topology = optional(string)
      postgres_database = optional(object({
        source_dbserver_id    = optional(string)
        os_notes              = optional(string)
        db_software_notes     = optional(string)
        available_cluster_ids = optional(list(string))
      }))
    }))

    network_profile = optional(object({
      topology = optional(string)
      postgres_database = optional(object({
        single_instance = optional(object({
          vlan_name = optional(string)
        }))
        ha_instance = optional(object({
          vlan_name       = optional(list(string))
          num_of_clusters = optional(number)
          cluster_name    = optional(list(string))
          cluster_id      = optional(list(string))
        }))
      }))
    }))

    database_parameter_profile = optional(object({
      postgres_database = optional(object({
        max_connections                  = optional(string)
        max_replication_slots            = optional(string)
        max_wal_senders                  = optional(string)
        shared_buffers                   = optional(string)
        effective_cache_size             = optional(string)
        maintenance_work_mem             = optional(string)
        checkpoint_completion_target     = optional(string)
        wal_buffers                      = optional(string)
        default_statistics_target        = optional(string)
        random_page_cost                 = optional(string)
        effective_io_concurrency         = optional(string)
        work_mem                         = optional(string)
        min_wal_size                     = optional(string)
        max_wal_size                     = optional(string)
        max_worker_processes             = optional(string)
        max_parallel_workers_per_gather  = optional(string)
        max_parallel_workers             = optional(string)
        max_parallel_maintenance_workers = optional(string)
        checkpoint_timeout               = optional(string)
        wal_keep_segments                = optional(string)
        timezone                         = optional(string)
      }))
    }))
  }))
  default = {}
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
