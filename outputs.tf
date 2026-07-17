# Purpose: Exposes identifiers that operators, CI/CD pipelines, runbooks, and downstream modules need after deployment.
# Inputs: Values are derived from resources in backup.tf, kms.tf, iam.tf, and dlm.tf.
# Outputs: Backup vault, backup plan, IAM role, KMS key, and optional DLM policy identifiers.
# Resources: None; output blocks read existing Terraform state.
# Dependencies: Outputs depend on successful creation of referenced resources.
# Examples: Use `terraform output backup_vault_name` before starting a restore job from the AWS CLI.
# Warnings: Outputs intentionally avoid secrets; ARNs may still be sensitive in some organizations and should be handled through approved channels.
# Requirements: Terraform state must be protected because it contains infrastructure metadata.

output "backup_vault_name" {
  description = "Name of the encrypted AWS Backup vault. Consumers: operators and restore automation. Usage example: aws backup list-recovery-points-by-backup-vault --backup-vault-name $(terraform output -raw backup_vault_name)."
  value       = aws_backup_vault.main.name
}

output "backup_plan_name" {
  description = "Name of the AWS Backup plan. Consumers: platform teams auditing backup coverage. Usage example: terraform output -raw backup_plan_name."
  value       = aws_backup_plan.main.name
}

output "backup_plan_id" {
  description = "ID of the AWS Backup plan. Consumers: downstream modules that attach additional selections. Usage example: module.backup.backup_plan_id."
  value       = aws_backup_plan.main.id
}

output "backup_role_arn" {
  description = "ARN of the AWS Backup service role. Consumers: security reviewers and restore automation. Usage example: confirm CloudTrail AssumeRole events reference this ARN."
  value       = aws_iam_role.backup.arn
}

output "kms_key_arn" {
  description = "ARN of the customer-managed KMS key used by the backup vault. Consumers: security teams and key rotation monitoring. Usage example: configure KMS alarms against this key ARN."
  value       = aws_kms_key.backup.arn
}

output "dlm_lifecycle_policy_id" {
  description = "ID of the optional DLM AMI lifecycle policy. Consumers: operations teams troubleshooting AMI creation. Usage example: aws dlm get-lifecycle-policy --policy-id $(terraform output -raw dlm_lifecycle_policy_id)."
  value       = try(aws_dlm_lifecycle_policy.ami[0].id, null)
}
