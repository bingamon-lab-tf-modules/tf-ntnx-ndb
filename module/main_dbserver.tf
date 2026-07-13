# NDB DB server VM family
#
# Credentials come from the sensitive credential vars keyed by each.key, not
# from the map(object) inputs (which are meant to be populated from PC YAML).

# NDB DB server VM resources (provision a new DB server VM)
resource "nutanix_ndb_dbserver_vm" "dbservervm" {
  for_each = var.dbservervms

  database_type               = each.value.database_type
  compute_profile_id          = each.value.compute_profile_id
  network_profile_id          = each.value.network_profile_id
  nx_cluster_id               = each.value.nx_cluster_id
  software_profile_id         = each.value.software_profile_id
  software_profile_version_id = each.value.software_profile_version_id
  description                 = each.value.description
  latest_snapshot             = each.value.latest_snapshot
  snapshot_id                 = each.value.snapshot_id
  time_machine_id             = each.value.time_machine_id
  timezone                    = each.value.timezone

  vm_password = try(var.dbservervm_credentials[each.key].vm_password, null)

  dynamic "postgres_database" {
    for_each = each.value.postgres_database != null ? [each.value.postgres_database] : []
    content {
      vm_name           = postgres_database.value.vm_name
      client_public_key = postgres_database.value.client_public_key
    }
  }

  dynamic "maintenance_tasks" {
    for_each = each.value.maintenance_tasks != null ? [each.value.maintenance_tasks] : []
    content {
      maintenance_window_id = maintenance_tasks.value.maintenance_window_id

      dynamic "tasks" {
        for_each = maintenance_tasks.value.tasks != null ? maintenance_tasks.value.tasks : []
        content {
          task_type    = tasks.value.task_type
          pre_command  = tasks.value.pre_command
          post_command = tasks.value.post_command
        }
      }
    }
  }

  dynamic "tags" {
    for_each = each.value.tags != null ? each.value.tags : []
    content {
      tag_id = tags.value.tag_id
      value  = tags.value.value
    }
  }

  delete              = each.value.delete
  remove              = each.value.remove
  soft_remove         = each.value.soft_remove
  delete_vgs          = each.value.delete_vgs
  delete_vm_snapshots = each.value.delete_vm_snapshots

  lifecycle {
    ignore_changes = [vm_password]
  }
}

# NDB DB server VM registration resources (register an existing DB server VM)
resource "nutanix_ndb_register_dbserver" "dbservervm_registration" {
  for_each = var.dbservervm_registrations

  database_type                      = each.value.database_type
  vm_ip                              = each.value.vm_ip
  nxcluster_id                       = each.value.nxcluster_id
  name                               = each.value.name
  description                        = each.value.description
  forced_install                     = each.value.forced_install
  working_directory                  = each.value.working_directory
  update_name_description_in_cluster = each.value.update_name_description_in_cluster

  username = try(var.dbservervm_registration_credentials[each.key].username, null)
  password = try(var.dbservervm_registration_credentials[each.key].password, null)
  ssh_key  = try(var.dbservervm_registration_credentials[each.key].ssh_key, null)

  dynamic "postgres_database" {
    for_each = each.value.postgres_database != null ? [each.value.postgres_database] : []
    content {
      listener_port          = postgres_database.value.listener_port
      postgres_software_home = postgres_database.value.postgres_software_home
    }
  }

  dynamic "tags" {
    for_each = each.value.tags != null ? each.value.tags : []
    content {
      tag_id = tags.value.tag_id
      value  = tags.value.value
    }
  }

  delete              = each.value.delete
  remove              = each.value.remove
  soft_remove         = each.value.soft_remove
  delete_vgs          = each.value.delete_vgs
  delete_vm_snapshots = each.value.delete_vm_snapshots

  lifecycle {
    ignore_changes = [password, ssh_key]
  }
}

# NDB DB server authorization resources (authorize DB servers against a time machine)
resource "nutanix_ndb_authorize_dbserver" "dbserver_authorization" {
  for_each = var.dbserver_authorizations

  dbservers_id      = each.value.dbservers_id
  time_machine_id   = each.value.time_machine_id
  time_machine_name = each.value.time_machine_name
}

# NDB cluster registration resources (register a Nutanix PE cluster with NDB)
resource "nutanix_ndb_cluster" "cluster" {
  for_each = var.clusters

  name              = each.value.name
  cluster_ip        = each.value.cluster_ip
  storage_container = each.value.storage_container
  description       = each.value.description
  agent_vm_prefix   = each.value.agent_vm_prefix
  cluster_type      = each.value.cluster_type
  port              = each.value.port
  protocol          = each.value.protocol
  version           = each.value.version

  username = try(var.cluster_credentials[each.key].username, null)
  password = try(var.cluster_credentials[each.key].password, null)

  dynamic "agent_network_info" {
    for_each = each.value.agent_network_info != null ? [each.value.agent_network_info] : []
    content {
      dns = agent_network_info.value.dns
      ntp = agent_network_info.value.ntp
    }
  }

  dynamic "networks_info" {
    for_each = each.value.networks_info != null ? each.value.networks_info : []
    content {
      access_type = networks_info.value.access_type
      type        = networks_info.value.type

      dynamic "network_info" {
        for_each = networks_info.value.network_info != null ? [networks_info.value.network_info] : []
        content {
          gateway     = network_info.value.gateway
          static_ip   = network_info.value.static_ip
          subnet_mask = network_info.value.subnet_mask
          vlan_name   = network_info.value.vlan_name
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [password]
  }
}
