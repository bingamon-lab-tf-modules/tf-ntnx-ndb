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

  # ---------------------------------------------------------------------------
  # Factored output value expressions
  #
  # These large/complex output values are defined once here and referenced from
  # both their individual `output` block and the aggregate `output "outputs"`
  # (spec §7.6 contract). Terraform cannot reference one output from another, so
  # this local is the shared single source of truth. Behaviour is unchanged.
  # ---------------------------------------------------------------------------

  # Details of created NDB profiles (used by output "profiles").
  out_profiles = merge(
    {
      for k, v in nutanix_ndb_profile.compute_profile : k => {
        id                = v.id
        name              = v.name
        type              = "Compute"
        status            = v.status
        engine_type       = v.engine_type
        published         = v.published
        latest_version_id = v.latest_version_id
      }
    },
    {
      for k, v in nutanix_ndb_profile.database_parameter_profile : k => {
        id                = v.id
        name              = v.name
        type              = "Database_Parameter"
        status            = v.status
        engine_type       = v.engine_type
        published         = v.published
        latest_version_id = v.latest_version_id
      }
    },
    {
      for k, v in nutanix_ndb_profile.network_profile : k => {
        id                = v.id
        name              = v.name
        type              = "Network"
        status            = v.status
        engine_type       = v.engine_type
        published         = v.published
        latest_version_id = v.latest_version_id
      }
    },
    {
      for k, v in nutanix_ndb_profile.software_profile : k => {
        id                = v.id
        name              = v.name
        type              = "Software"
        status            = v.status
        engine_type       = v.engine_type
        published         = v.published
        latest_version_id = v.latest_version_id
      }
    }
  )

  # Map of profile names to IDs (used by output "profile_ids").
  out_profile_ids = merge(
    { for k, v in nutanix_ndb_profile.compute_profile : k => v.id },
    { for k, v in nutanix_ndb_profile.database_parameter_profile : k => v.id },
    { for k, v in nutanix_ndb_profile.network_profile : k => v.id },
    { for k, v in nutanix_ndb_profile.software_profile : k => v.id }
  )

  # Per-database connection details (used by output "database_connection_strings").
  out_database_connection_strings = {
    for k, v in nutanix_ndb_database.database : k => {
      database_name = v.database_name
      type          = v.type
      status        = v.status

      # Listener port as configured on the database instance (deterministic input).
      listener_port = try(var.databases[k].postgresql_info.listener_port, null)

      # Runtime metadata exported by NDB as name/value pairs.
      properties = v.properties

      # Per-node connection info exported by NDB. dbserver carries the runtime
      # server connection map for each database node.
      nodes = [
        for n in v.database_nodes : {
          id       = n.id
          name     = n.name
          primary  = n.primary
          status   = n.status
          dbserver = n.dbserver
        }
      ]

      # Best-effort connection URI built from the primary node name and the
      # configured listener port. Host resolution depends on the surrounding
      # DNS/NDB configuration.
      connection_string = format(
        "%s://%s:%s/%s",
        v.type == "postgres_database" ? "postgresql" : (v.type == "mysql_database" ? "mysql" : "db"),
        try([for n in v.database_nodes : n.name if try(n.primary, false)][0], try(v.database_nodes[0].name, "")),
        try(var.databases[k].postgresql_info.listener_port, ""),
        try(v.database_name, "")
      )
    }
  }

  # Summary of all NDB resources created (used by output "ndb_summary").
  out_ndb_summary = {
    total_databases = length(nutanix_ndb_database.database)
    total_profiles = (
      length(nutanix_ndb_profile.compute_profile) +
      length(nutanix_ndb_profile.database_parameter_profile) +
      length(nutanix_ndb_profile.network_profile) +
      length(nutanix_ndb_profile.software_profile)
    )
    total_slas                      = length(nutanix_ndb_sla.sla)
    total_networks                  = length(nutanix_ndb_network.network)
    total_clones                    = length(nutanix_ndb_clone.clone)
    total_stretched_vlans           = length(nutanix_ndb_stretched_vlan.stretched_vlan)
    total_dbservervms               = length(nutanix_ndb_dbserver_vm.dbservervm)
    total_dbservervm_registrations  = length(nutanix_ndb_register_dbserver.dbservervm_registration)
    total_dbserver_authorizations   = length(nutanix_ndb_authorize_dbserver.dbserver_authorization)
    total_maintenance_windows       = length(nutanix_ndb_maintenance_window.maintenance_window)
    total_maintenance_tasks         = length(nutanix_ndb_maintenance_task.maintenance_task)
    total_tags                      = length(nutanix_ndb_tag.tag)
    total_clusters                  = length(nutanix_ndb_cluster.cluster)
    total_database_snapshots        = length(nutanix_ndb_database_snapshot.database_snapshot)
    total_database_restores         = length(nutanix_ndb_database_restore.database_restore)
    total_software_profile_versions = length(nutanix_ndb_software_version_profile.software_profile_version)
  }
}
