resource "aws_kms_key" "backup" {
    
    description = "KMS key for AWS Backup"
    deletion_window_in_days = 30
    enable_key_rotation = true

}

resource "aws_kms_alias" "backup" {

    name = "alias/aws-backup"
    target_key_id = aws_kms_key.backup.key_id
}