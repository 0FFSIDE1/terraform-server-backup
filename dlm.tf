resource "aws_iam_role" "dlm" {

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

  role = aws_iam_role.dlm.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"

}

resource "aws_dlm_lifecycle_policy" "ami" {

  description        = "Production AMI Policy"

  execution_role_arn = aws_iam_role.dlm.arn

  state = "ENABLED"

  policy_details {

    resource_types = ["INSTANCE"]

    target_tags = {

      Backup = "Enabled"

    }

    schedules {

      name = "Daily AMI"

      create_rule {

        interval = 24

        interval_unit = "HOURS"

        times = ["02:30"]

      }

      retain_rule {

        count = 14

      }

      copy_tags = true

    }

  }

}