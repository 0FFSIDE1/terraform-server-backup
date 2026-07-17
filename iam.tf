# Purpose: Defines least-surprise service roles required by AWS Backup and Amazon Data Lifecycle Manager.
# Inputs: var.project and var.enable_dlm_ami_backups control names and optional DLM creation.
# Outputs: IAM role ARNs consumed by backup.tf and dlm.tf.
# Resources: IAM roles and AWS-managed service-role policy attachments.
# Dependencies: AWS services assume these roles through service principals backup.amazonaws.com and dlm.amazonaws.com.
# Examples: Extend these roles with additional scoped policies only when backing up services that require extra permissions.
# Warnings: AWS-managed policies are broad enough for supported service operations; review them during regulated deployments.
# Requirements: The Terraform caller must be allowed to create IAM roles and attach service-role policies.

resource "aws_iam_role" "backup" {
  name = "${var.project}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role" "dlm" {
  count = var.enable_dlm_ami_backups ? 1 : 0

  name = "${var.project}-dlm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dlm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dlm" {
  count = var.enable_dlm_ami_backups ? 1 : 0

  role       = aws_iam_role.dlm[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}
