variable "aws_region" {
    description = "The AWS region to deploy resources in."
    type        = string
    default     = "us-east-1"
}

variable "environment" {
    description = "The deployment environment (e.g., dev, staging, prod)."
    type        = string
    default     = "dev"
}

variable "db_password" {
    description = "The password for the database."
    type = string
    sensitive = true

    validation {
      condition = length(var.db_password) >= 8
        error_message = "The database password must be at least 8 characters long."
    }
}

variable "db_instance_class" {
    description = "RDS instance type."
    type        = string
    default     = "db.t3.micro" #free
}

variable "allowed_ip" {
  description = "IP address allowed to access database"
  type        = string
  default     = "0.0.0.0/0"  # ⚠️ DANGER: Allows all IPs!
}

variable "publicly_accessible" {
    description = "Whether the RDS instance is publicly accessible."
    type        = bool
    default     = true
}

variable "db_name" {
    description = "Name of the PostgreSQL database to create."
    type = string
    default = "mcp_demo"
}