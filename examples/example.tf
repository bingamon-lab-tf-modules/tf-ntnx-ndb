################################################################################
# tf-ntnx-ndb — minimal single PostgreSQL database example
#
# Provisions one PostgreSQL database instance with a time machine and exposes
# the sensitive connection-string output. See the postgres-single, postgres-ha,
# and mysql-with-clone directories for fuller scenarios.
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
  source = "git::https://github.com/bingamon-lab-tf-modules/tf-ntnx-ndb.git//module?ref=v0.1.0"

  databases = {
    postgres_app = {
      name         = "postgres-app"
      description  = "Application PostgreSQL database"
      databasetype = "postgres_database"

      softwareprofileid    = var.software_profile_id
      computeprofileid     = var.compute_profile_id
      networkprofileid     = var.network_profile_id
      dbparameterprofileid = var.database_parameter_profile_id

      nxclusterid  = var.cluster_id
      sshpublickey = var.ssh_public_key
      vm_password  = var.vm_password

      postgresql_info = {
        listener_port  = "5432"
        database_size  = "200"
        db_password    = var.db_password
        database_names = "appdb"
      }

      timemachineinfo = {
        name  = "postgres-app-tm"
        slaid = var.sla_id

        schedule = {
          snapshottimeofday = {
            hours   = 2
            minutes = 0
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

variable "software_profile_id" {
  description = "Software profile ID for PostgreSQL"
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

variable "sla_id" {
  description = "SLA ID for time machine"
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

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

################################################################################
# Outputs
################################################################################

output "database_id" {
  description = "Database instance ID"
  value       = module.ndb.database_ids["postgres_app"]
}

output "database_connection_strings" {
  description = "Sensitive per-database connection details for the provisioned database"
  value       = module.ndb.database_connection_strings
  sensitive   = true
}
