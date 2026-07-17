# Purpose: Configures encrypted AWS Backup vault storage, scheduled backup plans, and EC2 resource selections.
# Inputs: var.project, var.instance_arn, retention variables, backup cron, and local.backup_selection_tags.
# Outputs: Backup vault and plan identifiers exported through outputs.tf.
# Resources: AWS Backup vault, plan, tag selection, and optional direct instance selection.
# Dependencies: The vault depends on the KMS key; selections depend on the IAM role and plan.
# Examples: Tag EC2 instances with Backup=Enabled for automatic coverage, or set instance_arn for one explicitly selected instance.
# Warnings: Recovery point retention affects monthly AWS Backup storage cost and restore availability; test restores before relying on the plan.
# Requirements: AWS Backup must support the selected resource type in var.aws_region.

resource "aws_backup_vault" "main" {
  name        = "${var.project}-vault"
  kms_key_arn = aws_kms_key.backup.arn
}

resource "aws_backup_plan" "main" {
  name = "${var.project}-backup"

  # Daily backups provide the shortest recovery point objective for routine rollback.
  rule {
    rule_name         = "Daily"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.backup_start_cron
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = var.daily_retention_days
    }

    recovery_point_tags = merge(local.common_tags, {
      BackupType = "Daily"
    })
  }

  # Weekly backups preserve a longer operational restore window while limiting storage growth.
  rule {
    rule_name         = "Weekly"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 3 ? * SUN *)"
    start_window      = 60
    completion_window = 240

    lifecycle {
      delete_after = var.weekly_retention_days
    }

    recovery_point_tags = merge(local.common_tags, {
      BackupType = "Weekly"
    })
  }

  # Monthly backups support audit and disaster-recovery recovery points beyond weekly retention.
  rule {
    rule_name         = "Monthly"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 4 1 * ? *)"
    start_window      = 60
    completion_window = 360

    lifecycle {
      delete_after = var.monthly_retention_days
    }

    recovery_point_tags = merge(local.common_tags, {
      BackupType = "Monthly"
    })
  }
}

resource "aws_backup_selection" "tagged_ec2" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.project}-tagged-ec2"
  plan_id      = aws_backup_plan.main.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = local.backup_selection_tags.Backup
  }
}

resource "aws_backup_selection" "explicit_ec2" {
  count = var.instance_arn == null ? 0 : 1

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.project}-explicit-ec2"
  plan_id      = aws_backup_plan.main.id
  resources    = [var.instance_arn]
}
