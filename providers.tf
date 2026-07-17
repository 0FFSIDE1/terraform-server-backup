# Purpose: Defines Terraform and AWS provider requirements for this root module.
# Inputs: var.aws_region and local.common_tags.
# Outputs: Provider configuration consumed implicitly by all AWS resources.
# Resources: None; this file only configures required plugins and provider behavior.
# Dependencies: tags.tf must define local.common_tags before provider default_tags is evaluated.
# Examples: Run `terraform init -upgrade` after changing provider constraints.
# Warnings: Backend configuration is intentionally omitted so operators can choose local, S3, or HCP Terraform state without editing module code.
# Requirements: Terraform >= 1.9.0 and AWS provider >= 6.0.0, < 7.0.0.

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0, < 7.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
