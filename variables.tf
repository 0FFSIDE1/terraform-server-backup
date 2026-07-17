# Purpose: Declares all operator-controlled inputs for backup, AMI lifecycle, encryption, retention, and tagging behavior.
# Inputs: Values are supplied through *.tfvars files, CLI -var arguments, environment variables, or Terraform Cloud workspace variables.
# Outputs: Variables are consumed by providers.tf, tags.tf, kms.tf, iam.tf, backup.tf, dlm.tf, and outputs.tf.
# Resources: None; this file defines the public interface for the root module.
# Dependencies: Validation rules keep downstream AWS APIs from receiving malformed values.
# Examples: See EXAMPLES.md and VARIABLE_REFERENCE.md for production-ready input sets.
# Warnings: Do not commit real account IDs, resource ARNs for private systems, access keys, or secrets in tfvars files.
# Requirements: Terraform 1.x variable validation syntax.

variable "aws_region" {
  description = "AWS Region where backup resources are deployed. Example: us-east-1. Allowed values must be valid AWS Region identifiers."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region must look like a valid AWS Region identifier, such as us-east-1 or us-gov-west-1."
  }
}

variable "project" {
  description = "Short project name used in resource names and tags. Example: production-api. Use lowercase letters, numbers, and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.project))
    error_message = "project must be 3-63 lowercase alphanumeric or hyphen characters and must start and end with an alphanumeric character."
  }
}

variable "environment" {
  description = "Deployment environment tag. Allowed values: dev, test, staging, prod. Example: prod."
  type        = string

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "environment must be one of dev, test, staging, or prod."
  }
}

variable "instance_arn" {
  description = "Optional EC2 instance ARN for direct AWS Backup selection. Leave null to use tag-based selection only. Example: arn:aws:ec2:us-east-1:123456789012:instance/i-0123456789abcdef0."
  type        = string
  default     = null

  validation {
    condition     = var.instance_arn == null || can(regex("^arn:(aws|aws-us-gov|aws-cn):ec2:[a-z0-9-]+:[0-9]{12}:instance/i-[a-f0-9]+$", var.instance_arn))
    error_message = "instance_arn must be null or a valid EC2 instance ARN."
  }
}

variable "instance_id" {
  description = "Deprecated compatibility input retained for callers that previously supplied an EC2 instance ID. It is not used because AWS Backup requires ARNs and DLM discovers instances by tag."
  type        = string
  default     = null
}

variable "backup_start_cron" {
  description = "AWS Backup daily cron expression in UTC. Default runs daily at 02:00 UTC. Example: cron(0 2 * * ? *)."
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "daily_retention_days" {
  description = "Number of days to retain daily AWS Backup recovery points. Allowed minimum is 1. Default: 35."
  type        = number
  default     = 35
}

variable "weekly_retention_days" {
  description = "Number of days to retain weekly AWS Backup recovery points. Must be greater than daily_retention_days for tiered retention. Default: 90."
  type        = number
  default     = 90
}

variable "monthly_retention_days" {
  description = "Number of days to retain monthly AWS Backup recovery points. Must be greater than weekly_retention_days. Default: 365."
  type        = number
  default     = 365
}

variable "enable_dlm_ami_backups" {
  description = "Whether to create a DLM policy that makes AMIs for EC2 instances tagged Backup=Enabled. Default: true."
  type        = bool
  default     = true
}

variable "ami_retention_count" {
  description = "Number of DLM-created AMIs to retain per tagged instance. Default: 14."
  type        = number
  default     = 14
}

variable "additional_tags" {
  description = "Additional tags merged into every taggable AWS resource. Example: { Owner = \"platform\" }."
  type        = map(string)
  default     = {}
}
