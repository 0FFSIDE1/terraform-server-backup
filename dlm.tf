# Purpose: Creates optional AMI lifecycle automation for fast EC2 recovery in addition to AWS Backup recovery points.
# Inputs: var.enable_dlm_ami_backups, var.project, var.ami_retention_count, and the Backup=Enabled tag contract.
# Outputs: DLM lifecycle policy ID exported by outputs.tf when enabled.
# Resources: AWS DLM lifecycle policy for EC2 instances.
# Dependencies: Uses the DLM IAM role from iam.tf and discovers EC2 instances by tag.
# Examples: Add Backup=Enabled to production instances that need daily machine images retained for rapid launch.
# Warnings: AMIs and their snapshots incur EBS snapshot charges; DLM discovery is tag-based, so incorrect tags can omit critical instances or include non-production instances.
# Requirements: DLM supports AMI lifecycle policies for EC2 instances in the selected Region.

resource "aws_dlm_lifecycle_policy" "ami" {
  count = var.enable_dlm_ami_backups ? 1 : 0

  description        = "${var.project} daily EC2 AMI policy"
  execution_role_arn = aws_iam_role.dlm[0].arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["INSTANCE"]

    target_tags = {
      Backup = "Enabled"
    }

    schedules {
      name = "Daily AMI"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["02:30"]
      }

      retain_rule {
        count = var.ami_retention_count
      }

      copy_tags = true
    }
  }
}
