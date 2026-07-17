EC2 Instance Tag

Your EC2 instance must include:

tags = {
  Name    = "production-api"
  Backup  = "Enabled"
}

This tag allows the DLM policy to automatically discover and create AMIs.

Deployment

Initialize Terraform:

terraform init

Review the changes:

terraform plan

Apply the configuration:

terraform apply

After deployment:

AWS Backup will create scheduled EBS backups (daily, weekly, and monthly) according to the plan.
DLM will automatically create a daily AMI of tagged EC2 instances and retain the most recent 14 images.
Restoring from AWS Backup
Open the AWS Console.
Go to AWS Backup.
Select Protected Resources.
Choose your EC2 instance.
Select a recovery point.
Click Restore.
Review the restore settings and start the restore job.
Disaster Recovery Using an AMI
Open EC2 Console.
Select AMIs.
Choose the latest AMI created by DLM.
Click Launch Instance from AMI.
Select:
Instance type
VPC
Subnet
Security groups
IAM role
Key pair
Launch the instance.
Reassociate any Elastic IPs if required.
Verify that your application starts correctly and passes health checks.
Update your load balancer target group or DNS to direct traffic to the restored instance.
Production Best Practices
Encrypt backups with a customer-managed KMS key.
Enable KMS key rotation.
Use lifecycle policies to expire old backups automatically.
Tag all production instances consistently (for example, Backup=Enabled).
Test restoration procedures regularly rather than assuming backups are usable.
Consider copying backups to a secondary AWS Region or account for protection against regional outages.
Store Terraform state remotely (for example, in an S3 backend with DynamoDB state locking).
Monitor AWS Backup and DLM jobs with Amazon CloudWatch and configure alerts for failed backup or restore operations.

This design follows common AWS production practices by separating backup management (AWS Backup) from machine-image disaster recovery (DLM-managed AMIs), providing both operational backups and rapid recovery options.