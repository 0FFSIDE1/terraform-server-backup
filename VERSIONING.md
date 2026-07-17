# VERSIONING

## Purpose

This document supports the Terraform Server Backup project by explaining operational expectations for encrypted AWS Backup recovery points and optional DLM AMIs.

## Current guidance

- Keep Terraform formatted with `terraform fmt -recursive`.
- Validate with `terraform validate` after initialization.
- Store state in an encrypted remote backend for production.
- Tag protected EC2 instances with `Backup=Enabled`.
- Test restores regularly and document recovery evidence.
- Treat KMS key deletion, backup vault deletion, and state exposure as high-risk changes.

## Maintainer notes

Update this file whenever backup schedules, retention, IAM permissions, restore processes, or release practices change.
