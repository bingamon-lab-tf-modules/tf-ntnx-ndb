##################################################
# Unit Tests: NDB
##################################################

#########################
# Provider
#########################

provider "nutanix" {
  username     = "dummy"
  password     = "dummy"
  endpoint     = "dummy.local"
  insecure     = true
  wait_timeout = 1

  ndb_username = "dummy"
  ndb_password = "dummy"
  ndb_endpoint = "dummy-ndb.local"
}

#########################
# Mock Data (Nutanix Provider)
#########################

mock_provider "nutanix" {

  # NDB cluster lookup (data.nutanix_ndb_clusters.available)
  mock_data "nutanix_ndb_clusters" {
    defaults = {
      clusters = []
    }
  }

  # NDB profile lookups (data.nutanix_ndb_profiles.* per profile type)
  mock_data "nutanix_ndb_profiles" {
    defaults = {
      profiles = []
    }
  }

  # NDB SLA lookup (data.nutanix_ndb_slas.available)
  mock_data "nutanix_ndb_slas" {
    defaults = {
      slas = []
    }
  }
}

#########################
# Tests
#########################

# Test 1: Empty configuration plans zero resources.
run "empty_config" {
  command = plan

  assert {
    condition     = output.ndb_summary.total_databases == 0
    error_message = "Expected 0 databases for an empty configuration"
  }

  assert {
    condition     = length(output.database_connection_strings) == 0
    error_message = "Expected no connection strings for an empty configuration"
  }
}

# Test 2: Data lookups enabled exercises data.tf and the name to id locals.
run "data_lookups_enabled" {
  command = plan

  variables {
    enable_data_lookups = true
  }

  assert {
    condition     = length(output.available_cluster_ids) == 0
    error_message = "Expected empty cluster id map from mocked data lookups"
  }

  assert {
    condition     = length(output.available_sla_ids) == 0
    error_message = "Expected empty SLA id map from mocked data lookups"
  }

  assert {
    condition     = length(output.available_profile_ids) == 0
    error_message = "Expected empty profile id map from mocked data lookups"
  }
}

# Test 3: Database + SLA + profile plans and exposes connection strings.
run "database_with_sla_and_profile" {
  command = plan

  variables {
    slas = {
      gold = {
        name                 = "gold-sla"
        description          = "Gold retention SLA"
        continuous_retention = 30
        daily_retention      = 60
      }
    }

    profiles = {
      small_compute = {
        name        = "small-compute"
        description = "Small compute profile"
        type        = "Compute"
        published   = true
        compute = {
          cpus           = 2
          core_per_cpu   = 1
          memory_size_gb = 4
        }
      }
    }

    databases = {
      pg_main = {
        name                 = "pg-main"
        description          = "Primary PostgreSQL database"
        databasetype         = "postgres_database"
        softwareprofileid    = "software-profile-id"
        computeprofileid     = "compute-profile-id"
        networkprofileid     = "network-profile-id"
        dbparameterprofileid = "db-parameter-profile-id"
        nxclusterid          = "cluster-id"
        sshpublickey         = "ssh-ed25519 mock-public-key ndb@test"
        vm_password          = "dummy-password"

        postgresql_info = {
          listener_port  = "5432"
          database_size  = "200"
          db_password    = "dummy-db-password"
          database_names = "appdb"
        }

        timemachineinfo = {
          name  = "pg-main-tm"
          slaid = "sla-id"

          schedule = {
            snapshottimeofday = {
              hours   = 2
              minutes = 0
              seconds = 0
            }

            continuousschedule = {
              enabled           = true
              logbackupinterval = 30
              snapshotsperday   = 1
            }

            weeklyschedule = {
              enabled   = true
              dayofweek = "SUNDAY"
            }

            monthlyschedule = {
              enabled    = true
              dayofmonth = 1
            }
          }
        }
      }
    }
  }

  assert {
    condition     = output.ndb_summary.total_databases == 1
    error_message = "Expected exactly 1 database"
  }

  assert {
    condition     = output.ndb_summary.total_slas == 1
    error_message = "Expected exactly 1 SLA"
  }

  assert {
    condition     = output.ndb_summary.total_profiles == 1
    error_message = "Expected exactly 1 profile"
  }

  assert {
    condition     = length(output.database_ids) == 1
    error_message = "Expected exactly 1 database id"
  }

  assert {
    condition     = length(output.database_connection_strings) == 1
    error_message = "Expected exactly 1 connection-string entry"
  }

  assert {
    condition     = contains(keys(output.database_connection_strings), "pg_main")
    error_message = "Expected a connection-string entry keyed by pg_main"
  }

  assert {
    condition     = output.database_connection_strings["pg_main"].listener_port == "5432"
    error_message = "Expected listener_port 5432 in the connection-string output"
  }
}

# Test 3b: Clone, register_database, network, stretched_vlan, tms_cluster,
# log_catchup, clone_refresh, and scale_database against v2.5.1 sensitive schemas.
run "clone_register_and_day2_operations" {
  command = plan

  variables {
    clones = {
      pg_clone = {
        name                          = "pg-clone-dev"
        time_machine_id               = "tm-id-001"
        latest_snapshot               = true
        time_zone                     = "UTC"
        nx_cluster_id                 = "cluster-id"
        compute_profile_id            = "compute-profile-id"
        network_profile_id            = "network-profile-id"
        database_parameter_profile_id = "db-parameter-profile-id"
        ssh_public_key                = "ssh-ed25519 mock-clone-public-key ndb@test"
        vm_password                   = "dummy-clone-vm-password"
        nodes = [
          {
            vmname           = "pg-clone-vm"
            computeprofileid = "compute-profile-id"
            networkprofileid = "network-profile-id"
            nx_cluster_id    = "cluster-id"
          }
        ]
        postgresql_info = {
          vm_name     = "pg-clone-vm"
          db_password = "dummy-clone-db-password"
        }
      }
    }

    register_databases = {
      existing_pg = {
        database_type = "postgres_database"
        database_name = "existing-pg"
        nx_cluster_id = "cluster-id"
        vm_ip         = "10.0.10.25"
        vm_username   = "era"
        vm_password   = "dummy-reg-vm-password"
        vm_sshkey     = "mock-ssh-private-key"
        postgress_info = {
          listener_port          = "5432"
          db_password            = "dummy-reg-db-password"
          db_name                = "appdb"
          postgres_software_home = "/usr/pgsql-15"
        }
      }
    }

    networks = {
      dhcp_net = {
        name       = "ndb-dhcp-net"
        type       = "DHCP"
        cluster_id = "cluster-id"
      }
    }

    stretched_vlans = {
      dr_vlan = {
        name     = "ndb-stretched-vlan"
        type     = "DHCP"
        vlan_ids = ["vlan-1", "vlan-2"]
      }
    }

    tms_clusters = {
      dr_tm = {
        time_machine_id = "tm-id-001"
        nx_cluster_id   = "dr-cluster-id"
        sla_id          = "dr-sla-id"
      }
    }

    log_catchups = {
      catchup_1 = {
        time_machine_id = "tm-id-001"
        for_restore     = true
      }
    }

    clone_refreshes = {
      refresh_1 = {
        clone_id            = "clone-id-001"
        user_pitr_timestamp = "2026-01-01 00:00:00"
        timezone            = "UTC"
      }
    }

    scale_databases = {
      scale_1 = {
        database_uuid     = "db-uuid-001"
        application_type  = "postgres_database"
        data_storage_size = 50
      }
    }
  }

  assert {
    condition     = output.ndb_summary.total_clones == 1
    error_message = "Expected 1 clone"
  }

  assert {
    condition     = output.ndb_summary.total_networks == 1
    error_message = "Expected 1 network"
  }

  assert {
    condition     = output.ndb_summary.total_stretched_vlans == 1
    error_message = "Expected 1 stretched VLAN"
  }

  assert {
    condition     = contains(keys(output.registered_database_ids), "existing_pg")
    error_message = "Expected registered database key existing_pg"
  }
}

# Test 4: Invalid profile type is rejected by variable validation.
run "profile_invalid_type" {
  command = plan

  variables {
    profiles = {
      broken = {
        name = "broken"
        type = "Invalid"
      }
    }
  }

  expect_failures = [var.profiles]
}

# Test 5: Compute profile without a compute block is rejected.
run "profile_compute_missing" {
  command = plan

  variables {
    profiles = {
      no_compute = {
        name = "no-compute"
        type = "Compute"
      }
    }
  }

  expect_failures = [var.profiles]
}

# Test 6: Scale operation with zero storage is rejected.
run "scale_zero_storage" {
  command = plan

  variables {
    scale_databases = {
      grow = {
        database_uuid     = "db-uuid"
        application_type  = "postgres_database"
        data_storage_size = 0
      }
    }
  }

  expect_failures = [var.scale_databases]
}

# Test 7: Registering a non-postgres database is rejected.
run "register_wrong_type" {
  command = plan

  variables {
    register_databases = {
      legacy = {
        database_type = "mysql_database"
        database_name = "legacy"
        vm_ip         = "10.0.0.10"
      }
    }
  }

  expect_failures = [var.register_databases]
}
