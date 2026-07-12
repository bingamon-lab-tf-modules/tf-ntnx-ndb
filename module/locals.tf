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
}
