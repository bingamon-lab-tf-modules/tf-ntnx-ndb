# NDB Cluster lookups
data "nutanix_ndb_clusters" "available" {
  count = var.enable_data_lookups ? 1 : 0
}

# NDB Profile lookups
data "nutanix_ndb_profiles" "compute" {
  count        = var.enable_data_lookups ? 1 : 0
  profile_type = "Compute"
}

data "nutanix_ndb_profiles" "software" {
  count        = var.enable_data_lookups ? 1 : 0
  profile_type = "Software"
}

data "nutanix_ndb_profiles" "network" {
  count        = var.enable_data_lookups ? 1 : 0
  profile_type = "Network"
}

data "nutanix_ndb_profiles" "database_parameter" {
  count        = var.enable_data_lookups ? 1 : 0
  profile_type = "Database_Parameter"
}

# NDB SLA lookups
data "nutanix_ndb_slas" "available" {
  count = var.enable_data_lookups ? 1 : 0
}

# NDB DB server lookups
data "nutanix_ndb_dbservers" "available" {
  count = var.enable_data_lookups ? 1 : 0
}

# NDB maintenance window lookups
data "nutanix_ndb_maintenance_windows" "available" {
  count = var.enable_data_lookups ? 1 : 0
}

# NDB tag lookups
data "nutanix_ndb_tags" "available" {
  count = var.enable_data_lookups ? 1 : 0
}

# NDB snapshot lookups
data "nutanix_ndb_snapshots" "available" {
  count = var.enable_data_lookups ? 1 : 0
}
