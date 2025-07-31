# Can show RDS endpoint for output

output "rds_endpoint1" {
    description = "The endpoint of the RDS instance."
    value       = aws_db_instance.postgres.endpoint
}

# Database name

output "db_name" {
    description = "The name of the PostgreSQL database."
    value       = var.db_name
}

# output "secret_id" {
#   description = "AWS Secrets Manager secret ID"
#   value       = aws_secretsmanager_secret.db_credentials.id
# }

output "psql_command" {
  description = "Command to connect to database"
  value       = "psql -h ${aws_db_instance.postgres.address} -U postgres -d ${var.db_name}"
  sensitive   = true
}