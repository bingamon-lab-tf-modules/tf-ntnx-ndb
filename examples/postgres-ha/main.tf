################################################################################
# PostgreSQL HA Instance Example
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

  # Provision PostgreSQL HA database
  databases = {
    postgres_ha = {
      name         = "postgres-ha-prod"
      description  = "Production PostgreSQL HA cluster"
      databasetype = "postgres_database"

      softwareprofileid = var.software_profile_id
      computeprofileid  = var.compute_profile_id
      networkprofileid  = var.network_profile_id

      nxclusterid  = var.cluster_id
      clustered    = true
      nodecount    = 3
      sshpublickey = var.ssh_public_key
      vm_password  = var.vm_password

      postgresql_info = {
        listener_port  = "5432"
        database_size  = "500"
        db_password    = var.db_password
        database_names = "proddb"

        ha_instance = {
          cluster_name            = "postgres-ha-cluster"
          patroni_cluster_name    = "patroni-cluster"
          proxy_read_port         = "5001"
          proxy_write_port        = "5000"
          enable_synchronous_mode = true
        }
      }

      # Node configuration for HA
      nodes = [
        {
          vmname           = "postgres-ha-node-1"
          computeprofileid = var.compute_profile_id
          networkprofileid = var.network_profile_id
          nx_cluster_id    = var.cluster_id
        },
        {
          vmname           = "postgres-ha-node-2"
          computeprofileid = var.compute_profile_id
          networkprofileid = var.network_profile_id
          nx_cluster_id    = var.cluster_id
        },
        {
          vmname           = "postgres-ha-node-3"
          computeprofileid = var.compute_profile_id
          networkprofileid = var.network_profile_id
          nx_cluster_id    = var.cluster_id
        }
      ]

      timemachineinfo = {
        name        = "postgres-ha-tm"
        description = "HA Time Machine"

        sla_details = {
          primary_sla_id = var.sla_id
          nx_cluster_ids = [var.cluster_id]
        }

        schedule = {
          snapshottimeofday = {
            hours   = 1
            minutes = 0
          }

          continuousschedule = {
            enabled           = true
            logbackupinterval = 15
            snapshotsperday   = 4
          }

          weeklyschedule = {
            enabled   = true
            dayofweek = "SATURDAY"
          }

          monthlyschedule = {
            enabled    = true
            dayofmonth = 1
          }

          quartelyschedule = {
            enabled    = true
            startmonth = "JANUARY"
            dayofmonth = 1
          }

          yearlyschedule = {
            enabled    = true
            month      = "JANUARY"
            dayofmonth = 1
          }
        }
      }
    }
  }

  # Configure time machine cluster for DR
  tms_clusters = {
    dr_cluster = {
      time_machine_id = module.ndb.databases["postgres_ha"].time_machine_id
      nx_cluster_id   = var.dr_cluster_id
      sla_id          = var.dr_sla_id
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
  description = "Primary Nutanix cluster ID"
  type        = string
}

variable "dr_cluster_id" {
  description = "DR Nutanix cluster ID for time machine replication"
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

variable "sla_id" {
  description = "SLA ID for time machine"
  type        = string
}

variable "dr_sla_id" {
  description = "DR SLA ID for time machine replication"
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
  value       = module.ndb.database_ids["postgres_ha"]
}

output "time_machine_id" {
  description = "Time machine ID"
  value       = module.ndb.databases["postgres_ha"].time_machine_id
}

output "tms_cluster_id" {
  description = "Time machine cluster ID for DR"
  value       = module.ndb.tms_cluster_ids["dr_cluster"]
}
