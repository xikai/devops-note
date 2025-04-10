resource "alicloud_ecs_auto_snapshot_policy" "snapshot_policy" {
  # 快照策略名称
  name = "${var.env}-${var.project_name}-snapshot-policy"

  # 自动快照重复的星期几，取值范围：[1, 7]，代表周一到周日
  repeat_weekdays = var.repeat_weekdays

  # 自动快照的保留时间，-1 表示永久保留，或者是一个介于 1 到 65536 之间的数字表示保留天数
  retention_days = var.retention_days

  # 自动快照计划创建的时间点，取值范围：[0, 23]，代表从 00:00 到 24:00
  time_points = var.time_points
}
