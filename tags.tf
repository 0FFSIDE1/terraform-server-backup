# Purpose: Centralizes mandatory tags so all supported AWS resources receive consistent ownership, environment, and backup metadata.
# Inputs: var.environment, var.project, var.additional_tags, and var.enable_dlm_ami_backups.
# Outputs: local.common_tags for provider-level default tags and local.backup_selection_tags for AWS Backup selections.
# Resources: None; this file provides shared metadata only.
# Dependencies: variables.tf defines all inputs used here.
# Examples: Set additional_tags = { Owner = "platform", CostCenter = "1234" } to extend the defaults.
# Warnings: The Backup tag is used by both AWS Backup and DLM discovery; changing it can stop future backups for tag-based selections.
# Requirements: Tag keys and values must comply with AWS tagging limits.

locals {
  backup_tag_value = var.enable_dlm_ami_backups ? "Enabled" : "AWSBackupOnly"

  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
      Backup      = local.backup_tag_value
    },
    var.additional_tags
  )

  backup_selection_tags = {
    Backup = "Enabled"
  }
}
