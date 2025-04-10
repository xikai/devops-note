# 创建一个IAM角色供DLM服务使用
resource "aws_iam_role" "dlm_role" {
  name = "${var.env}-${var.project_name}-dlm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dlm.amazonaws.com"
        }
      }
    ]
  })
}

# 创建IAM策略并附加到DLM角色
resource "aws_iam_role_policy" "dlm_policy" {
  name = "${var.env}-${var.project_name}-dlm-policy"
  role = aws_iam_role.dlm_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots"
        ],
        Resource = "*"
      }
    ]
  })
}

# 创建DLM生命周期策略
resource "aws_dlm_lifecycle_policy" "ebs_snapshot_policy" {
  description        = "EBS Snapshot Policy for Prod Environment"
  execution_role_arn = aws_iam_role.dlm_role.arn
  state              = var.state

  policy_details {
    resource_types = [var.resource_types]

    schedule {
      name = "${var.env}-${var.project_name}-${var.resource_types}-snapshots-policy"

      create_rule {
        interval      = var.interval
        interval_unit = var.interval_unit
        times         = var.times
      }

      retain_rule {
        count = var.retain_rule
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = var.copy_tags

    }
    target_tags = var.target_tags
  }
}
