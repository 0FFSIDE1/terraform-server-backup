# Purpose: Creates a customer-managed KMS key for encrypting AWS Backup recovery points.
# Inputs: var.project controls the alias; provider default_tags applies common metadata.
# Outputs: aws_kms_key.backup and aws_kms_alias.backup consumed by the backup vault and module outputs.
# Resources: KMS key and alias.
# Dependencies: AWS Backup vault references this key to encrypt recovery points at rest.
# Examples: Rotate this key automatically with enable_key_rotation = true; do not reuse alias/aws/* names because AWS reserves them.
# Warnings: Scheduling key deletion makes encrypted recovery points unrecoverable after the deletion window; disable the key only during tested incident response procedures.
# Requirements: IAM principals applying this module need KMS create, tag, alias, and policy permissions.

resource "aws_kms_key" "backup" {
  description             = "Customer-managed key for ${var.project} AWS Backup vault encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${var.project}-backup"
  target_key_id = aws_kms_key.backup.key_id
}
