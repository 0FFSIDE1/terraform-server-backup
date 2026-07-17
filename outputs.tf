output "backup_vault" {
  value = aws_backup_vault.main.name
}

output "backup_plan" {
  value = aws_backup_plan.daily.name
}