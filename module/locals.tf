# Local values
locals {
  # Available NDB clusters from data lookup
  available_clusters = var.enable_data_lookups ? try(data.nutanix_ndb_clusters.available[0].clusters, []) : []

  # Cluster ID lookup by name
  cluster_id_by_name = {
    for cluster in local.available_clusters : cluster.name => cluster.id
  }

  # Available profiles by type
  compute_profiles            = var.enable_data_lookups ? try(data.nutanix_ndb_profiles.compute[0].profiles, []) : []
  software_profiles           = var.enable_data_lookups ? try(data.nutanix_ndb_profiles.software[0].profiles, []) : []
  network_profiles            = var.enable_data_lookups ? try(data.nutanix_ndb_profiles.network[0].profiles, []) : []
  database_parameter_profiles = var.enable_data_lookups ? try(data.nutanix_ndb_profiles.database_parameter[0].profiles, []) : []

  # Profile ID lookups by name
  compute_profile_id_by_name = {
    for profile in local.compute_profiles : profile.name => profile.id
  }

  software_profile_id_by_name = {
    for profile in local.software_profiles : profile.name => profile.id
  }

  network_profile_id_by_name = {
    for profile in local.network_profiles : profile.name => profile.id
  }

  database_parameter_profile_id_by_name = {
    for profile in local.database_parameter_profiles : profile.name => profile.id
  }

  # Available SLAs from data lookup
  available_slas = var.enable_data_lookups ? try(data.nutanix_ndb_slas.available[0].slas, []) : []

  # SLA ID lookup by name
  sla_id_by_name = {
    for sla in local.available_slas : sla.name => sla.id
  }

  # All profile IDs consolidated
  all_profile_ids = merge(
    local.compute_profile_id_by_name,
    local.software_profile_id_by_name,
    local.network_profile_id_by_name,
    local.database_parameter_profile_id_by_name
  )

  # Available DB servers from data lookup
  available_dbservers = var.enable_data_lookups ? try(data.nutanix_ndb_dbservers.available[0].dbservers, []) : []

  # DB server ID lookup by name
  dbserver_id_by_name = {
    for dbserver in local.available_dbservers : dbserver.name => dbserver.id
  }

  # Available maintenance windows from data lookup
  available_maintenance_windows = var.enable_data_lookups ? try(data.nutanix_ndb_maintenance_windows.available[0].maintenance_windows, []) : []

  # Maintenance window ID lookup by name
  maintenance_window_id_by_name = {
    for window in local.available_maintenance_windows : window.name => window.id
  }

  # Available tags from data lookup
  available_tags = var.enable_data_lookups ? try(data.nutanix_ndb_tags.available[0].tags, []) : []

  # Tag ID lookup by name
  tag_id_by_name = {
    for tag in local.available_tags : tag.name => tag.id
  }

  # Available snapshots from data lookup
  available_snapshots = var.enable_data_lookups ? try(data.nutanix_ndb_snapshots.available[0].snapshots, []) : []

  # Snapshot ID lookup by name
  snapshot_id_by_name = {
    for snapshot in local.available_snapshots : snapshot.name => snapshot.id
  }
}
