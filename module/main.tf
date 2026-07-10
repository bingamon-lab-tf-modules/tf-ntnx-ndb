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

# NDB Profile resources
resource "nutanix_ndb_profile" "profile" {
  for_each = var.profiles

  name        = each.value.name
  description = each.value.description
  engine_type = each.value.engine_type
  published   = each.value.published

  dynamic "compute_profile" {
    for_each = each.value.compute_profile != null ? [each.value.compute_profile] : []
    content {
      cpus         = compute_profile.value.cpus
      core_per_cpu = compute_profile.value.core_per_cpu
      memory_size  = compute_profile.value.memory_size
    }
  }

  dynamic "software_profile" {
    for_each = each.value.software_profile != null ? [each.value.software_profile] : []
    content {
      topology = software_profile.value.topology

      dynamic "postgres_database" {
        for_each = software_profile.value.postgres_database != null ? [software_profile.value.postgres_database] : []
        content {
          source_dbserver_id = postgres_database.value.source_dbserver_id
          os_notes           = postgres_database.value.os_notes
          db_software_notes  = postgres_database.value.db_software_notes
          # TODO: available_cluster_ids is not supported in nutanix provider 2.3.1
          # available_cluster_ids = postgres_database.value.available_cluster_ids
        }
      }
    }
  }

  dynamic "network_profile" {
    for_each = each.value.network_profile != null ? [each.value.network_profile] : []
    content {
      topology = network_profile.value.topology

      dynamic "postgres_database" {
        for_each = network_profile.value.postgres_database != null ? [network_profile.value.postgres_database] : []
        content {
          dynamic "single_instance" {
            for_each = postgres_database.value.single_instance != null ? [postgres_database.value.single_instance] : []
            content {
              vlan_name = single_instance.value.vlan_name
            }
          }

          dynamic "ha_instance" {
            for_each = postgres_database.value.ha_instance != null ? [postgres_database.value.ha_instance] : []
            content {
              vlan_name       = ha_instance.value.vlan_name
              num_of_clusters = ha_instance.value.num_of_clusters
              cluster_name    = ha_instance.value.cluster_name
              cluster_id      = ha_instance.value.cluster_id
            }
          }
        }
      }
    }
  }

  dynamic "database_parameter_profile" {
    for_each = each.value.database_parameter_profile != null ? [each.value.database_parameter_profile] : []
    content {
      dynamic "postgres_database" {
        for_each = database_parameter_profile.value.postgres_database != null ? [database_parameter_profile.value.postgres_database] : []
        content {
          max_connections       = postgres_database.value.max_connections
          max_replication_slots = postgres_database.value.max_replication_slots
          max_wal_senders       = postgres_database.value.max_wal_senders
          # TODO: shared_buffers is not supported in nutanix provider 2.3.1
          # shared_buffers                      = postgres_database.value.shared_buffers
          # TODO: effective_cache_size is not supported in nutanix provider 2.3.1
          # effective_cache_size                = postgres_database.value.effective_cache_size
          # TODO: maintenance_work_mem is not supported in nutanix provider 2.3.1
          # maintenance_work_mem                = postgres_database.value.maintenance_work_mem
          checkpoint_completion_target = postgres_database.value.checkpoint_completion_target
          wal_buffers                  = postgres_database.value.wal_buffers
          # TODO: default_statistics_target is not supported in nutanix provider 2.3.1
          # default_statistics_target           = postgres_database.value.default_statistics_target
          random_page_cost         = postgres_database.value.random_page_cost
          effective_io_concurrency = postgres_database.value.effective_io_concurrency
          # TODO: work_mem is not supported in nutanix provider 2.3.1
          # work_mem                            = postgres_database.value.work_mem
          min_wal_size         = postgres_database.value.min_wal_size
          max_wal_size         = postgres_database.value.max_wal_size
          max_worker_processes = postgres_database.value.max_worker_processes
          # TODO: max_parallel_workers_per_gather is not supported in nutanix provider 2.3.1
          # max_parallel_workers_per_gather     = postgres_database.value.max_parallel_workers_per_gather
          # TODO: max_parallel_workers is not supported in nutanix provider 2.3.1
          # max_parallel_workers                = postgres_database.value.max_parallel_workers
          # TODO: max_parallel_maintenance_workers is not supported in nutanix provider 2.3.1
          # max_parallel_maintenance_workers    = postgres_database.value.max_parallel_maintenance_workers
          checkpoint_timeout = postgres_database.value.checkpoint_timeout
          wal_keep_segments  = postgres_database.value.wal_keep_segments
          timezone           = postgres_database.value.timezone
        }
      }
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
