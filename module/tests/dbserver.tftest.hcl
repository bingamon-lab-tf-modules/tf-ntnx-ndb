##################################################
# Unit Tests: NDB DB server / maintenance / snapshot family (issue 590)
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

  mock_data "nutanix_ndb_dbservers" {
    defaults = {
      dbservers = []
    }
  }

  mock_data "nutanix_ndb_maintenance_windows" {
    defaults = {
      maintenance_windows = []
    }
  }

  mock_data "nutanix_ndb_tags" {
    defaults = {
      tags = []
    }
  }

  mock_data "nutanix_ndb_snapshots" {
    defaults = {
      snapshots = []
    }
  }

  mock_data "nutanix_ndb_clusters" {
    defaults = {
      clusters = []
    }
  }
}

#########################
# Tests
#########################

# Test 1: Empty configuration plans zero resources across the whole 590 family.
run "empty_config" {
  command = plan

  assert {
    condition     = output.ndb_summary.total_dbservervms == 0
    error_message = "Expected 0 DB server VMs for an empty configuration"
  }

  assert {
    condition     = output.ndb_summary.total_maintenance_windows == 0
    error_message = "Expected 0 maintenance windows for an empty configuration"
  }

  assert {
    condition     = output.ndb_summary.total_clusters == 0
    error_message = "Expected 0 cluster registrations for an empty configuration"
  }

  assert {
    condition = (
      output.ndb_summary.total_dbservervm_registrations == 0 &&
      output.ndb_summary.total_dbserver_authorizations == 0 &&
      output.ndb_summary.total_maintenance_tasks == 0 &&
      output.ndb_summary.total_tags == 0 &&
      output.ndb_summary.total_database_snapshots == 0 &&
      output.ndb_summary.total_database_restores == 0 &&
      output.ndb_summary.total_software_profile_versions == 0
    )
    error_message = "Expected every 590 resource family to plan zero for an empty configuration"
  }
}

# Test 2: DB server VM + maintenance window + task-by-key + tag.
run "dbserver_and_maintenance" {
  command = plan

  variables {
    dbservervms = {
      pg_node_1 = {
        compute_profile_id          = "compute-profile-id"
        network_profile_id          = "network-profile-id"
        nx_cluster_id               = "cluster-id"
        software_profile_id         = "software-profile-id"
        software_profile_version_id = "software-profile-version-id"
        postgres_database = {
          vm_name = "pg-node-1"
        }
      }
    }

    dbservervm_credentials = {
      pg_node_1 = {
        vm_password = "dummy-vm-password"
      }
    }

    maintenance_windows = {
      weekly = {
        name        = "weekly-window"
        recurrence  = "WEEKLY"
        start_time  = "02:00:00"
        duration    = 2
        day_of_week = "SUNDAY"
      }
    }

    maintenance_tasks = {
      task_weekly = {
        maintenance_window_key = "weekly"
        dbserver_id            = ["dbserver-id"]
        tasks = [
          {
            task_type = "OS_PATCHING"
          }
        ]
      }
    }

    tags = {
      env = {
        name        = "env"
        entity_type = "DATABASE"
      }
    }
  }

  assert {
    condition     = output.ndb_summary.total_dbservervms == 1
    error_message = "Expected exactly 1 DB server VM"
  }

  assert {
    condition     = output.ndb_summary.total_maintenance_windows == 1
    error_message = "Expected exactly 1 maintenance window"
  }

  assert {
    condition     = output.ndb_summary.total_maintenance_tasks == 1
    error_message = "Expected exactly 1 maintenance task"
  }

  assert {
    condition     = contains(keys(output.maintenance_task_ids), "task_weekly")
    error_message = "Expected a maintenance task keyed by task_weekly (window resolved by key)"
  }

  assert {
    condition     = output.ndb_summary.total_tags == 1
    error_message = "Expected exactly 1 tag"
  }
}

# Test 3: Cluster registration with required agent/network blocks and creds.
run "cluster_registration" {
  command = plan

  variables {
    clusters = {
      pe_east = {
        name              = "pe-east"
        cluster_ip        = "10.0.0.5"
        storage_container = "ndb-storage"
        agent_network_info = {
          dns = "10.0.0.2"
          ntp = "10.0.0.3"
        }
        networks_info = [
          {
            type = "STATIC"
            network_info = {
              vlan_name = "vlan-ndb"
            }
          }
        ]
      }
    }

    cluster_credentials = {
      pe_east = {
        username = "admin"
        password = "dummy-cluster-password"
      }
    }
  }

  assert {
    condition     = output.ndb_summary.total_clusters == 1
    error_message = "Expected exactly 1 cluster registration"
  }

  assert {
    condition     = contains(keys(output.cluster_ids), "pe_east")
    error_message = "Expected a cluster registration keyed by pe_east"
  }
}

# Test 4: Snapshot + restore one-shot actions plan.
run "snapshot_and_restore" {
  command = plan

  variables {
    database_snapshots = {
      nightly = {
        name            = "nightly-snap"
        time_machine_id = "tm-id"
      }
    }

    database_restores = {
      rollback = {
        database_id     = "db-id"
        latest_snapshot = "true"
      }
    }

    software_profile_versions = {
      pg15_v2 = {
        name        = "pg15-v2"
        engine_type = "postgres_database"
        profile_id  = "software-profile-id"
      }
    }
  }

  assert {
    condition     = output.ndb_summary.total_database_snapshots == 1
    error_message = "Expected exactly 1 database snapshot"
  }

  assert {
    condition     = output.ndb_summary.total_database_restores == 1
    error_message = "Expected exactly 1 database restore"
  }

  assert {
    condition     = output.ndb_summary.total_software_profile_versions == 1
    error_message = "Expected exactly 1 software profile version"
  }
}

# Test 5: Maintenance window with an invalid recurrence is rejected.
run "maintenance_window_invalid_recurrence" {
  command = plan

  variables {
    maintenance_windows = {
      broken = {
        name       = "broken"
        recurrence = "HOURLY"
        start_time = "02:00:00"
      }
    }
  }

  expect_failures = [var.maintenance_windows]
}

# Test 6: DB server VM without a software profile is rejected.
run "dbservervm_missing_software_profile" {
  command = plan

  variables {
    dbservervms = {
      no_software = {
        compute_profile_id = "compute-profile-id"
        network_profile_id = "network-profile-id"
        nx_cluster_id      = "cluster-id"
      }
    }
  }

  expect_failures = [var.dbservervms]
}

# Test 7: Restore without a source reference is rejected.
run "restore_without_source" {
  command = plan

  variables {
    database_restores = {
      bad = {
        database_id = "db-id"
      }
    }
  }

  expect_failures = [var.database_restores]
}

# Test 8: Authorization without a time machine reference is rejected.
run "authorization_without_time_machine" {
  command = plan

  variables {
    dbserver_authorizations = {
      bad = {
        dbservers_id = ["dbserver-id"]
      }
    }
  }

  expect_failures = [var.dbserver_authorizations]
}
