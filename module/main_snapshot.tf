# NDB snapshot and restore resources
#
# These are one-shot action resources: the action runs on create. Re-running an
# action requires a NEW for_each key; destroying the resource does not undo the
# snapshot/restore that already executed.

# NDB database snapshot resources (take a time-machine snapshot)
resource "nutanix_ndb_database_snapshot" "database_snapshot" {
  for_each = var.database_snapshots

  name                    = each.value.name
  time_machine_id         = each.value.time_machine_id
  time_machine_name       = each.value.time_machine_name
  expiry_date_timezone    = each.value.expiry_date_timezone
  remove_schedule_in_days = each.value.remove_schedule_in_days
  replicate_to_clusters   = each.value.replicate_to_clusters

  dynamic "tags" {
    for_each = each.value.tags != null ? each.value.tags : []
    content {
      tag_id = tags.value.tag_id
      value  = tags.value.value
    }
  }
}

# NDB database restore resources (restore from a snapshot or point-in-time)
resource "nutanix_ndb_database_restore" "database_restore" {
  for_each = var.database_restores

  database_id         = each.value.database_id
  snapshot_id         = each.value.snapshot_id
  latest_snapshot     = each.value.latest_snapshot
  user_pitr_timestamp = each.value.user_pitr_timestamp
  time_zone_pitr      = each.value.time_zone_pitr
  restore_version     = each.value.restore_version

  dynamic "tags" {
    for_each = each.value.tags != null ? each.value.tags : []
    content {
      tag_id = tags.value.tag_id
      value  = tags.value.value
    }
  }
}
