resource "aws_backup_vault" "main" {

  name        = "${var.project}-vault"
  kms_key_arn = aws_kms_key.backup.arn

}

resource "aws_backup_plan" "daily" {

  name = "${var.project}-backup"

  rule {

    rule_name         = "Daily"
    target_vault_name = aws_backup_vault.main.name

    schedule = "cron(0 2 * * ? *)"

    start_window = 60

    completion_window = 180

    lifecycle {

      delete_after = 35

    }

    recovery_point_tags = {

      BackupType = "Daily"

    }
  }

  rule {

    rule_name = "Weekly"

    target_vault_name = aws_backup_vault.main.name

    schedule = "cron(0 3 ? * SUN *)"

    lifecycle {

      delete_after = 90

    }
  }

  rule {

    rule_name = "Monthly"

    target_vault_name = aws_backup_vault.main.name

    schedule = "cron(0 4 1 * ? *)"

    lifecycle {

      delete_after = 365

    }

  }

}

resource "aws_backup_selection" "ec2" {

  iam_role_arn = aws_iam_role.backup.arn

  name = "production"

  plan_id = aws_backup_plan.daily.id

  resources = [

    var.instance_arn

  ]

}