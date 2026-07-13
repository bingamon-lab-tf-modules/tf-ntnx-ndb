################################################################################
# MySQL Database with Clone Example
################################################################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 2.4.2"
    }
  }
}

provider "nutanix" {
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint
  port     = var.nutanix_port
  insecure = var.nutanix_insecure

  ndb_username = var.nutanix_ndb_username
  ndb_password = var.nutanix_ndb_password
  ndb_endpoint = var.nutanix_ndb_endpoint
}

module "ndb" {
  source = "../../module"

  enable_data_lookups = true

  # Create a clone from existing time machine
  clones = {
    mysql_clone = {
      name        = "mysql-clone-dev"
      description = "MySQL clone for development"

      time_machine_id = var.source_time_machine_id
      latest_snapshot = true
      time_zone       = "UTC"

      nx_cluster_id   = var.cluster_id
      create_dbserver = true
      clustered       = false
      node_count      = 1

      compute_profile_id            = var.compute_profile_id
      network_profile_id            = var.network_profile_id
      database_parameter_profile_id = var.database_parameter_profile_id

      ssh_public_key = var.ssh_public_key
      vm_password    = var.vm_password

      nodes = [
        {
          vmname           = "mysql-clone-vm"
          computeprofileid = var.compute_profile_id
          networkprofileid = var.network_profile_id
          nx_cluster_id    = var.cluster_id
        }
      ]

      # Delete options
      delete                 = true
      remove                 = false
      delete_time_machine    = true
      delete_logical_cluster = true
    }
  }

  # Perform log catchup before clone operations
  log_catchups = {
    pre_clone_catchup = {
      time_machine_id = var.source_time_machine_id
      for_restore     = true
    }
  }
}

################################################################################
# Variables
################################################################################

variable "nutanix_username" {
  description = "Nutanix Prism Central username"
  type        = string
}

variable "nutanix_password" {
  description = "Nutanix Prism Central password"
  type        = string
  sensitive   = true
}

variable "nutanix_endpoint" {
  description = "Nutanix Prism Central endpoint"
  type        = string
}

variable "nutanix_port" {
  description = "Nutanix Prism Central port"
  type        = number
  default     = 9440
}

variable "nutanix_insecure" {
  description = "Allow insecure connection"
  type        = bool
  default     = true
}

variable "nutanix_ndb_username" {
  description = "NDB username"
  type        = string
}

variable "nutanix_ndb_password" {
  description = "NDB password"
  type        = string
  sensitive   = true
}

variable "nutanix_ndb_endpoint" {
  description = "NDB endpoint"
  type        = string
}

variable "cluster_id" {
  description = "Nutanix cluster ID"
  type        = string
}

variable "source_time_machine_id" {
  description = "Source time machine ID for cloning"
  type        = string
}

variable "compute_profile_id" {
  description = "Compute profile ID"
  type        = string
}

variable "network_profile_id" {
  description = "Network profile ID"
  type        = string
}

variable "database_parameter_profile_id" {
  description = "Database parameter profile ID"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for database server"
  type        = string
}

variable "vm_password" {
  description = "VM password"
  type        = string
  sensitive   = true
}

################################################################################
# Outputs
################################################################################

output "clone_id" {
  description = "Clone instance ID"
  value       = module.ndb.clone_ids["mysql_clone"]
}

output "clone_status" {
  description = "Clone status"
  value       = module.ndb.clones["mysql_clone"].status
}

output "log_catchup_id" {
  description = "Log catchup operation ID"
  value       = module.ndb.log_catchup_ids["pre_clone_catchup"]
}
