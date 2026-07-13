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
