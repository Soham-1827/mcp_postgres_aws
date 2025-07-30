terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}


provider "aws" {
    region = var.aws_region

}

resource "random_string" "suffix" {
    length = 5
    special = false
    upper = false
}


locals {
    common_tags = {
        Environment = var.environment
        Project     = "mcp-postgres-project"
        ManagedBy   = "Terraform"
        CreatedAt = timestamp()
    }
}


data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

resource "aws_security_group" "postgres" {
  name        = "${var.environment}-mcp-postgres-sg-${random_string.suffix.result}"
  description = "Security group for MCP PostgreSQL RDS"
  vpc_id      = data.aws_vpc.default.id


  ingress {
    description = "PostgreSQL from allowed IPs"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-mcp-postgres-sg"
  })
}

resource "aws_db_instance" "postgres" {
    identifier     = "${var.environment}-mcp-postgres-${random_string.suffix.result}"
    engine         = "postgres"
    engine_version = "17.4-R1"
    instance_class = "var.db_instance_class"
    allocated_storage = 20
    storage_type = "gp3"
    storage_encrypted = true
    db_name = var.db_name
    username = "postgres"
    password = var.db_password
    port = 5432

    db_subnet_group_name = "default"
    vpc_security_group_ids = [aws_security_group.postgres.id]
    publicly_accessible = var.publicly_accessible

    backup_retention_period = 7
    backup_window = "03:00-04:00"
    maintenance_window     = "sun:04:00-sun:05:00"

    deletion_protection = false
    skip_final_snapshot = true

    enabled_cloudwatch_logs_exports = ["postgresql"]

    tags = merge(local.common_tags, {
    Name = "${var.environment}-mcp-postgres"
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
    secret_id = aws_secretsmanager_secret.db_credentials.id

    secret_string = jsonencode({
        host = aws_db_instance.postgres.address
        port = aws_db_instance.postgres.port
        username = aws_db_instance.postgres.username
        password = var.db_password
        dbname = aws_db_instance.postgres.db_name
    })
}

output "rds_endpoint" {
    description = "RDS instance endpoint"
    value = aws_db_instance.postgres.endpoint
}

output "rds_address" {
    description = "RDS instance address (without port)"
    value = aws_db_instance.postgres.address
}

output "database_name" {
  description = "Name of the created database"
  value       = aws_db_instance.postgres.db_name
}

output "database_username" {
  description = "Master username for database"
  value       = aws_db_instance.postgres.username
}

output "secret_id" {
  description = "The ID of the secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.id
}

output "secret_arn" {
  description = "The ARN of the secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.postgres.id
}

output "connection_command" {
  description = "Example psql connection command"
  value       = "psql -h ${aws_db_instance.postgres.address} -U ${aws_db_instance.postgres.username} -d ${aws_db_instance.postgres.db_name} -p ${aws_db_instance.postgres.port}"
}

output "random_suffix" {
  description = "Random suffix used for resource names"
  value       = random_string.suffix.result
}
