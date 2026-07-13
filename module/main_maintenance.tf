# NDB maintenance and tag resources

# NDB maintenance window resources
resource "nutanix_ndb_maintenance_window" "maintenance_window" {
  for_each = var.maintenance_windows

  name          = each.value.name
  recurrence    = each.value.recurrence
  start_time    = each.value.start_time
  description   = each.value.description
  duration      = each.value.duration
  day_of_week   = each.value.day_of_week
  week_of_month = each.value.week_of_month
  timezone      = each.value.timezone
}

# NDB maintenance task resources (associate maintenance tasks to DB servers)
resource "nutanix_ndb_maintenance_task" "maintenance_task" {
  for_each = var.maintenance_tasks

  # Resolve the target window from a direct id or, failing that, from a
  # maintenance_windows map key (the created window's id).
  maintenance_window_id = coalesce(
    each.value.maintenance_window_id,
    try(nutanix_ndb_maintenance_window.maintenance_window[each.value.maintenance_window_key].id, null)
  )

  dbserver_id      = each.value.dbserver_id
  dbserver_cluster = each.value.dbserver_cluster

  dynamic "tasks" {
    for_each = each.value.tasks != null ? each.value.tasks : []
    content {
      task_type    = tasks.value.task_type
      pre_command  = tasks.value.pre_command
      post_command = tasks.value.post_command
    }
  }
}

# NDB tag resources
resource "nutanix_ndb_tag" "tag" {
  for_each = var.tags

  name        = each.value.name
  entity_type = each.value.entity_type
  description = each.value.description
  required    = each.value.required
  status      = each.value.status
}
