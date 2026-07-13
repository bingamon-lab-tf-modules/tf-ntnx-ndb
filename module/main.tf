# NDB Database resources
resource "nutanix_ndb_database" "database" {
  for_each = var.databases

  name                     = each.value.name
  description              = each.value.description
  databasetype             = each.value.databasetype
  softwareprofileid        = each.value.softwareprofileid
  softwareprofileversionid = each.value.softwareprofileversionid
  computeprofileid         = each.value.computeprofileid
  networkprofileid         = each.value.networkprofileid
  dbparameterprofileid     = each.value.dbparameterprofileid
  nxclusterid              = each.value.nxclusterid
  sshpublickey             = each.value.sshpublickey
  createdbserver           = each.value.createdbserver
  dbserverid               = each.value.dbserverid
  clustered                = each.value.clustered
  autotunestagingdrive     = each.value.autotunestagingdrive
  nodecount                = each.value.nodecount
  newdbservertimezone      = each.value.newdbservertimezone
  vm_password              = each.value.vm_password

  dynamic "postgresql_info" {
    for_each = each.value.postgresql_info != null ? [each.value.postgresql_info] : []
    content {
      listener_port  = postgresql_info.value.listener_port
      database_size  = postgresql_info.value.database_size
      db_password    = postgresql_info.value.db_password
      database_names = postgresql_info.value.database_names
      auth_method    = postgresql_info.value.auth_method

      dynamic "ha_instance" {
        for_each = postgresql_info.value.ha_instance != null ? [postgresql_info.value.ha_instance] : []
        content {
          cluster_name            = ha_instance.value.cluster_name
          patroni_cluster_name    = ha_instance.value.patroni_cluster_name
          proxy_read_port         = ha_instance.value.proxy_read_port
          proxy_write_port        = ha_instance.value.proxy_write_port
          archive_wal_expire_days = ha_instance.value.archive_wal_expire_days
          backup_policy           = ha_instance.value.backup_policy
          enable_synchronous_mode = ha_instance.value.enable_synchronous_mode
          # TODO: num_synchronous_standbys is not supported in nutanix provider 2.3.1
          # num_synchronous_standbys = ha_instance.value.num_synchronous_standbys
          enable_peer_auth = ha_instance.value.enable_peer_auth
        }
      }
    }
  }

  dynamic "nodes" {
    for_each = each.value.nodes != null ? each.value.nodes : []
    content {
      vmname           = nodes.value.vmname
      networkprofileid = nodes.value.networkprofileid
      computeprofileid = nodes.value.computeprofileid
      nx_cluster_id    = nodes.value.nx_cluster_id
      dbserverid       = nodes.value.dbserverid

      dynamic "properties" {
        for_each = nodes.value.properties != null ? nodes.value.properties : []
        content {
          name  = properties.value.name
          value = properties.value.value
        }
      }
    }
  }

  dynamic "timemachineinfo" {
    for_each = each.value.timemachineinfo != null ? [each.value.timemachineinfo] : []
    content {
      name             = timemachineinfo.value.name
      description      = timemachineinfo.value.description
      slaid            = timemachineinfo.value.slaid
      autotunelogdrive = timemachineinfo.value.autotunelogdrive

      dynamic "sla_details" {
        for_each = timemachineinfo.value.sla_details != null ? [timemachineinfo.value.sla_details] : []
        content {
          primary_sla {
            sla_id         = sla_details.value.primary_sla_id
            nx_cluster_ids = sla_details.value.nx_cluster_ids
          }
        }
      }

      dynamic "schedule" {
        for_each = timemachineinfo.value.schedule != null ? [timemachineinfo.value.schedule] : []
        content {
          dynamic "snapshottimeofday" {
            for_each = schedule.value.snapshottimeofday != null ? [schedule.value.snapshottimeofday] : []
            content {
              hours   = snapshottimeofday.value.hours
              minutes = snapshottimeofday.value.minutes
              seconds = snapshottimeofday.value.seconds
            }
          }

          dynamic "continuousschedule" {
            for_each = schedule.value.continuousschedule != null ? [schedule.value.continuousschedule] : []
            content {
              enabled           = continuousschedule.value.enabled
              logbackupinterval = continuousschedule.value.logbackupinterval
              snapshotsperday   = continuousschedule.value.snapshotsperday
            }
          }

          dynamic "weeklyschedule" {
            for_each = schedule.value.weeklyschedule != null ? [schedule.value.weeklyschedule] : []
            content {
              enabled   = weeklyschedule.value.enabled
              dayofweek = weeklyschedule.value.dayofweek
            }
          }

          dynamic "monthlyschedule" {
            for_each = schedule.value.monthlyschedule != null ? [schedule.value.monthlyschedule] : []
            content {
              enabled    = monthlyschedule.value.enabled
              dayofmonth = monthlyschedule.value.dayofmonth
            }
          }

          dynamic "quartelyschedule" {
            for_each = schedule.value.quartelyschedule != null ? [schedule.value.quartelyschedule] : []
            content {
              enabled    = quartelyschedule.value.enabled
              startmonth = quartelyschedule.value.startmonth
              dayofmonth = quartelyschedule.value.dayofmonth
            }
          }

          dynamic "yearlyschedule" {
            for_each = schedule.value.yearlyschedule != null ? [schedule.value.yearlyschedule] : []
            content {
              enabled    = yearlyschedule.value.enabled
              dayofmonth = yearlyschedule.value.dayofmonth
              month      = yearlyschedule.value.month
            }
          }
        }
      }
    }
  }

  dynamic "actionarguments" {
    for_each = each.value.actionarguments != null ? each.value.actionarguments : []
    content {
      name  = actionarguments.value.name
      value = actionarguments.value.value
    }
  }

  delete                 = each.value.delete
  remove                 = each.value.remove
  soft_remove            = each.value.soft_remove
  forced                 = each.value.forced
  delete_time_machine    = each.value.delete_time_machine
  delete_logical_cluster = each.value.delete_logical_cluster

  lifecycle {
    ignore_changes = [vm_password]
  }
}

# NDB Register Database resources
resource "nutanix_ndb_register_database" "register_database" {
  for_each = var.register_databases

  database_type = each.value.database_type
  database_name = each.value.database_name
  description   = each.value.description
  category      = each.value.category

  # Cluster placement
  nx_cluster_id = each.value.nx_cluster_id

  # VM connection details
  vm_ip          = each.value.vm_ip
  vm_username    = each.value.vm_username
  vm_password    = each.value.vm_password
  vm_sshkey      = each.value.vm_sshkey
  vm_description = each.value.vm_description

  # Registration options
  clustered                       = each.value.clustered
  forced_install                  = each.value.forced_install
  auto_tune_staging_drive         = each.value.auto_tune_staging_drive
  working_directory               = each.value.working_directory
  reset_description_in_nx_cluster = each.value.reset_description_in_nx_cluster

  # PostgreSQL specific configuration
  dynamic "postgress_info" {
    for_each = each.value.postgress_info != null ? [each.value.postgress_info] : []
    content {
      listener_port            = postgress_info.value.listener_port
      db_password              = postgress_info.value.db_password
      db_name                  = postgress_info.value.db_name
      db_user                  = postgress_info.value.db_user
      switch_log               = postgress_info.value.switch_log
      allow_multiple_databases = postgress_info.value.allow_multiple_databases
      backup_policy            = postgress_info.value.backup_policy
      postgres_software_home   = postgress_info.value.postgres_software_home
      software_home            = postgress_info.value.software_home
    }
  }

  # Time Machine configuration
  dynamic "time_machine_info" {
    for_each = each.value.time_machine_info != null ? [each.value.time_machine_info] : []
    content {
      name             = time_machine_info.value.name
      description      = time_machine_info.value.description
      slaid            = time_machine_info.value.sla_id
      autotunelogdrive = time_machine_info.value.auto_tune_log_drive

      dynamic "sla_details" {
        for_each = time_machine_info.value.sla_details != null ? [time_machine_info.value.sla_details] : []
        content {
          primary_sla {
            sla_id         = sla_details.value.primary_sla_id
            nx_cluster_ids = sla_details.value.nx_cluster_ids
          }
        }
      }

      dynamic "schedule" {
        for_each = time_machine_info.value.schedule != null ? [time_machine_info.value.schedule] : []
        content {
          dynamic "snapshottimeofday" {
            for_each = schedule.value.snapshot_time_of_day != null ? [schedule.value.snapshot_time_of_day] : []
            content {
              hours   = snapshottimeofday.value.hours
              minutes = snapshottimeofday.value.minutes
              seconds = snapshottimeofday.value.seconds
            }
          }

          dynamic "continuousschedule" {
            for_each = schedule.value.continuous_schedule != null ? [schedule.value.continuous_schedule] : []
            content {
              enabled           = continuousschedule.value.enabled
              logbackupinterval = continuousschedule.value.log_backup_interval
              snapshotsperday   = continuousschedule.value.snapshots_per_day
            }
          }

          dynamic "weeklyschedule" {
            for_each = schedule.value.weekly_schedule != null ? [schedule.value.weekly_schedule] : []
            content {
              enabled   = weeklyschedule.value.enabled
              dayofweek = weeklyschedule.value.day_of_week
            }
          }

          dynamic "monthlyschedule" {
            for_each = schedule.value.monthly_schedule != null ? [schedule.value.monthly_schedule] : []
            content {
              enabled    = monthlyschedule.value.enabled
              dayofmonth = monthlyschedule.value.day_of_month
            }
          }

          dynamic "quartelyschedule" {
            for_each = schedule.value.quarterly_schedule != null ? [schedule.value.quarterly_schedule] : []
            content {
              enabled    = quartelyschedule.value.enabled
              startmonth = quartelyschedule.value.start_month
              dayofmonth = quartelyschedule.value.day_of_month
            }
          }

          dynamic "yearlyschedule" {
            for_each = schedule.value.yearly_schedule != null ? [schedule.value.yearly_schedule] : []
            content {
              enabled    = yearlyschedule.value.enabled
              month      = yearlyschedule.value.month
              dayofmonth = yearlyschedule.value.day_of_month
            }
          }
        }
      }
    }
  }

  # Tags
  dynamic "tags" {
    for_each = each.value.tags != null ? each.value.tags : []
    content {
      tag_id = tags.value.tag_id
      value  = tags.value.tag_value
    }
  }

  # Action arguments
  dynamic "actionarguments" {
    for_each = each.value.action_arguments != null ? each.value.action_arguments : []
    content {
      name  = actionarguments.value.name
      value = actionarguments.value.value
    }
  }

  # Delete options
  delete                 = each.value.delete_on_destroy
  remove                 = each.value.remove_on_destroy
  soft_remove            = each.value.soft_remove
  forced                 = each.value.forced_delete
  delete_time_machine    = each.value.delete_time_machine
  delete_logical_cluster = each.value.delete_logical_cluster
}

# NDB Database Scale resources
resource "nutanix_ndb_database_scale" "database_scale" {
  for_each = var.scale_databases

  database_uuid     = each.value.database_uuid
  application_type  = each.value.application_type
  data_storage_size = each.value.data_storage_size
  pre_script_cmd    = each.value.pre_script_cmd
  post_script_cmd   = each.value.post_script_cmd
  scale_count       = each.value.scale_count
}

# NDB Compute Profile resources
resource "nutanix_ndb_profile" "compute_profile" {
  for_each = { for k, v in var.profiles : k => v if v.type == "Compute" }

  name        = each.value.name
  description = each.value.description
  published   = each.value.published

  compute_profile {
    cpus         = each.value.compute.cpus
    core_per_cpu = each.value.compute.core_per_cpu
    memory_size  = each.value.compute.memory_size_gb
  }
}

# NDB Database Parameter Profile resources
resource "nutanix_ndb_profile" "database_parameter_profile" {
  for_each = { for k, v in var.profiles : k => v if v.type == "Database_Parameter" }

  name        = each.value.name
  description = each.value.description
  engine_type = each.value.engine_type
  published   = each.value.published

  database_parameter_profile {
    dynamic "postgres_database" {
      for_each = each.value.engine_type == "postgres_database" && each.value.database_parameters != null ? [each.value.database_parameters] : []
      content {
        max_connections              = try(postgres_database.value.max_connections, null)
        max_replication_slots        = try(postgres_database.value.max_replication_slots, null)
        effective_io_concurrency     = try(postgres_database.value.effective_io_concurrency, null)
        timezone                     = try(postgres_database.value.timezone, null)
        max_prepared_transactions    = try(postgres_database.value.max_prepared_transactions, null)
        max_locks_per_transaction    = try(postgres_database.value.max_locks_per_transaction, null)
        max_wal_senders              = try(postgres_database.value.max_wal_senders, null)
        max_worker_processes         = try(postgres_database.value.max_worker_processes, null)
        min_wal_size                 = try(postgres_database.value.min_wal_size, null)
        max_wal_size                 = try(postgres_database.value.max_wal_size, null)
        checkpoint_timeout           = try(postgres_database.value.checkpoint_timeout, null)
        autovacuum                   = try(postgres_database.value.autovacuum, null)
        checkpoint_completion_target = try(postgres_database.value.checkpoint_completion_target, null)
        synchronous_commit           = try(postgres_database.value.synchronous_commit, null)
        random_page_cost             = try(postgres_database.value.random_page_cost, null)
      }
    }
  }
}

# NDB Network Profile resources
resource "nutanix_ndb_profile" "network_profile" {
  for_each = { for k, v in var.profiles : k => v if v.type == "Network" }

  name        = each.value.name
  description = each.value.description
  engine_type = each.value.engine_type
  published   = each.value.published

  network_profile {
    topology = each.value.network.topology

    dynamic "postgres_database" {
      for_each = each.value.engine_type == "postgres_database" ? [each.value.network] : []
      content {
        dynamic "single_instance" {
          for_each = postgres_database.value.topology == "single" ? [1] : []
          content {
            vlan_name = postgres_database.value.vlan_name
          }
        }

        dynamic "ha_instance" {
          for_each = postgres_database.value.topology == "cluster" && postgres_database.value.ha_instance != null ? [postgres_database.value.ha_instance] : []
          content {
            vlan_name       = ha_instance.value.vlan_names
            cluster_name    = ha_instance.value.cluster_names
            num_of_clusters = ha_instance.value.num_of_clusters
          }
        }
      }
    }
  }
}

# NDB Software Profile resources
resource "nutanix_ndb_profile" "software_profile" {
  for_each = { for k, v in var.profiles : k => v if v.type == "Software" }

  name        = each.value.name
  description = each.value.description
  engine_type = each.value.engine_type
  published   = each.value.published

  software_profile {
    topology              = each.value.software.topology
    available_cluster_ids = each.value.software.available_cluster_ids

    dynamic "postgres_database" {
      for_each = each.value.engine_type == "postgres_database" && each.value.software.postgres != null ? [each.value.software.postgres] : []
      content {
        source_dbserver_id               = postgres_database.value.source_dbserver_id
        base_profile_version_name        = postgres_database.value.base_profile_version_name
        base_profile_version_description = postgres_database.value.base_profile_version_description
        os_notes                         = postgres_database.value.os_notes
        db_software_notes                = postgres_database.value.db_software_notes
      }
    }
  }
}

# NDB Software Profile Version resources (publish a new version of a software profile)
resource "nutanix_ndb_software_version_profile" "software_profile_version" {
  for_each = var.software_profile_versions

  name                  = each.value.name
  engine_type           = each.value.engine_type
  profile_id            = each.value.profile_id
  description           = each.value.description
  status                = each.value.status
  available_cluster_ids = each.value.available_cluster_ids

  dynamic "postgres_database" {
    for_each = each.value.postgres_database != null ? [each.value.postgres_database] : []
    content {
      source_dbserver_id = postgres_database.value.source_dbserver_id
      os_notes           = postgres_database.value.os_notes
      db_software_notes  = postgres_database.value.db_software_notes
    }
  }
}

# NDB SLA resources
resource "nutanix_ndb_sla" "sla" {
  for_each = var.slas

  name                 = each.value.name
  description          = each.value.description
  continuous_retention = each.value.continuous_retention
  daily_retention      = each.value.daily_retention
  weekly_retention     = each.value.weekly_retention
  monthly_retention    = each.value.monthly_retention
  quarterly_retention  = each.value.quarterly_retention
}

# NDB Network resources
resource "nutanix_ndb_network" "network" {
  for_each = var.networks

  name          = each.value.name
  type          = each.value.type
  cluster_id    = each.value.cluster_id
  gateway       = each.value.gateway
  subnet_mask   = each.value.subnet_mask
  primary_dns   = each.value.primary_dns
  secondary_dns = each.value.secondary_dns
  dns_domain    = each.value.dns_domain

  dynamic "ip_pools" {
    for_each = each.value.ip_pools
    content {
      start_ip = ip_pools.value.start_ip
      end_ip   = ip_pools.value.end_ip
    }
  }
}

# NDB Clone resources
resource "nutanix_ndb_clone" "clone" {
  for_each = var.clones

  name                          = each.value.name
  description                   = each.value.description
  time_machine_id               = each.value.time_machine_id
  time_machine_name             = each.value.time_machine_name
  snapshot_id                   = each.value.snapshot_id
  user_pitr_timestamp           = each.value.user_pitr_timestamp
  latest_snapshot               = each.value.latest_snapshot
  time_zone                     = each.value.time_zone
  nx_cluster_id                 = each.value.nx_cluster_id
  ssh_public_key                = each.value.ssh_public_key
  compute_profile_id            = each.value.compute_profile_id
  network_profile_id            = each.value.network_profile_id
  database_parameter_profile_id = each.value.database_parameter_profile_id
  vm_password                   = each.value.vm_password
  create_dbserver               = each.value.create_dbserver
  clustered                     = each.value.clustered
  node_count                    = each.value.node_count
  dbserver_cluster_id           = each.value.dbserver_cluster_id
  dbserver_logical_cluster_id   = each.value.dbserver_logical_cluster_id

  dynamic "nodes" {
    for_each = each.value.nodes != null ? each.value.nodes : []
    content {
      # TODO: vmname is not supported in nutanix provider 2.3.1 for nutanix_ndb_clone nodes (use vm_name instead)
      # vmname           = nodes.value.vmname
      # TODO: networkprofileid is not supported in nutanix provider 2.3.1 for nutanix_ndb_clone nodes (use network_profile_id instead)
      # networkprofileid = nodes.value.networkprofileid
      # TODO: computeprofileid is not supported in nutanix provider 2.3.1 for nutanix_ndb_clone nodes (use compute_profile_id instead)
      # computeprofileid = nodes.value.computeprofileid
      vm_name            = nodes.value.vmname
      compute_profile_id = nodes.value.computeprofileid
      network_profile_id = nodes.value.networkprofileid
      nx_cluster_id      = nodes.value.nx_cluster_id
      # TODO: dbserverid is not supported in nutanix provider 2.3.1 for nutanix_ndb_clone nodes (use dbserver_id instead)
      # dbserverid       = nodes.value.dbserverid
      dbserver_id = nodes.value.dbserverid

      dynamic "properties" {
        for_each = nodes.value.properties != null ? nodes.value.properties : []
        content {
          name  = properties.value.name
          value = properties.value.value
        }
      }
    }
  }

  dynamic "postgresql_info" {
    for_each = each.value.postgresql_info != null ? [each.value.postgresql_info] : []
    content {
      vm_name = postgresql_info.value.vm_name != null ? postgresql_info.value.vm_name : try(each.value.nodes[0].vmname, each.value.name)
      # TODO: listener_port is not supported in nutanix provider 2.3.1 for nutanix_ndb_clone postgresql_info
      # listener_port  = postgresql_info.value.listener_port
      # TODO: database_size is not supported in nutanix provider 2.3.1 for nutanix_ndb_clone postgresql_info
      # database_size  = postgresql_info.value.database_size
      db_password = postgresql_info.value.db_password
      # TODO: database_names is not supported in nutanix provider 2.3.1 for nutanix_ndb_clone postgresql_info
      # database_names = postgresql_info.value.database_names
      # TODO: auth_method is not supported in nutanix provider 2.3.1 for nutanix_ndb_clone postgresql_info
      # auth_method    = postgresql_info.value.auth_method

      # TODO: ha_instance block is not supported in nutanix provider 2.3.1 for nutanix_ndb_clone postgresql_info
      # dynamic "ha_instance" {
      #   for_each = postgresql_info.value.ha_instance != null ? [postgresql_info.value.ha_instance] : []
      #   content {
      #     cluster_name             = ha_instance.value.cluster_name
      #     patroni_cluster_name     = ha_instance.value.patroni_cluster_name
      #     proxy_read_port          = ha_instance.value.proxy_read_port
      #     proxy_write_port         = ha_instance.value.proxy_write_port
      #     archive_wal_expire_days  = ha_instance.value.archive_wal_expire_days
      #     backup_policy            = ha_instance.value.backup_policy
      #     enable_synchronous_mode  = ha_instance.value.enable_synchronous_mode
      #     num_synchronous_standbys = ha_instance.value.num_synchronous_standbys
      #     enable_peer_auth         = ha_instance.value.enable_peer_auth
      #   }
      # }
    }
  }

  dynamic "actionarguments" {
    for_each = each.value.actionarguments != null ? each.value.actionarguments : []
    content {
      name  = actionarguments.value.name
      value = actionarguments.value.value
    }
  }

  delete                 = each.value.delete
  remove                 = each.value.remove
  soft_remove            = each.value.soft_remove
  forced                 = each.value.forced
  delete_time_machine    = each.value.delete_time_machine
  delete_logical_cluster = each.value.delete_logical_cluster

  lifecycle {
    ignore_changes = [vm_password, ssh_public_key]
  }
}

# NDB Clone Refresh resources
resource "nutanix_ndb_clone_refresh" "clone_refresh" {
  for_each = var.clone_refreshes

  clone_id    = each.value.clone_id
  snapshot_id = each.value.snapshot_id
  timezone    = each.value.timezone
}

# NDB Stretched VLAN resources
resource "nutanix_ndb_stretched_vlan" "stretched_vlan" {
  for_each = var.stretched_vlans

  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  vlan_ids    = each.value.vlan_ids

  dynamic "metadata" {
    for_each = each.value.metadata != null ? [each.value.metadata] : []
    content {
      gateway     = metadata.value.gateway
      subnet_mask = metadata.value.subnet_mask
    }
  }
}

# NDB Time Machine Cluster resources
resource "nutanix_ndb_tms_cluster" "tms_cluster" {
  for_each = var.tms_clusters

  time_machine_id = each.value.time_machine_id
  nx_cluster_id   = each.value.nx_cluster_id
  sla_id          = each.value.sla_id
  type            = each.value.type
}

# NDB Log Catchup resources
resource "nutanix_ndb_log_catchups" "log_catchup" {
  for_each = var.log_catchups

  time_machine_id     = each.value.time_machine_id
  database_id         = each.value.database_id
  for_restore         = each.value.for_restore
  log_catchup_version = each.value.log_catchup_version
}
