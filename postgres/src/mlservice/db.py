"""Database connection and security utilities."""

import os
import re
import pg8000
import json
import boto3
from typing import Optional, List, Any
from contextlib import contextmanager
from dotenv import load_dotenv

load_dotenv()

# SQL injection patterns
SQL_INJECTION_PATTERNS = [
    r"(\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\b.*\b(from|into|where|table)\b)",
    r"(--|\#|\/\*|\*\/|;)",  # SQL comments
    r"(\b(or|and)\b\s*\d+\s*=\s*\d+)",  # Tautologies like 'or 1=1'
    r"(\b(sleep|benchmark|waitfor)\b)",  # Time-based attacks
    r"(@@version|version\(\)|database\(\)|user\(\))",  # Information gathering
    r"(\binto\s+(outfile|dumpfile)\b)",  # File operations
    r"(xp_cmdshell|sp_executesql)",  # Dangerous stored procedures
]

# Mutating SQL keywords
MUTATING_KEYWORDS = [
    'INSERT', 'UPDATE', 'DELETE', 'MERGE', 'TRUNCATE',
    'CREATE', 'DROP', 'ALTER', 'RENAME', 'GRANT', 'REVOKE',
    'COMMENT ON', 'SECURITY LABEL', 'CREATE EXTENSION', 'CREATE FUNCTION',
    'INSTALL', 'CLUSTER', 'REINDEX', 'VACUUM', 'ANALYZE'
]

class Settings:
    """Application settings from environment variables."""
    
    def __init__(self):
        self.debug = os.getenv('DEBUG', 'false').lower() == 'true'
        self.read_only_connection = os.getenv('READ_ONLY_CONNECTION', 'true').lower() == 'true'
        self.secret_id = os.getenv('SECRET_ID')
        self.aws_region = os.getenv('AWS_REGION', 'us-east-1')
        
        # Direct connection settings (fallback if no secret)
        self.pg_host = os.getenv('PG_HOST')
        self.pg_port = int(os.getenv('PG_PORT', '5432'))
        self.pg_user = os.getenv('PG_USER', 'postgres')
        self.pg_password = os.getenv('PG_PASSWORD')
        self.pg_dbname = os.getenv('PG_DBNAME', 'mcp_demo')

def get_db_credentials(settings: Settings) -> dict:
    """Get database credentials from AWS Secrets Manager or environment."""
    
    # Try AWS Secrets Manager first
    if settings.secret_id:
        try:
            client = boto3.client('secretsmanager', region_name=settings.aws_region)
            response = client.get_secret_value(SecretId=settings.secret_id)
            secret = json.loads(response['SecretString'])
            
            return {
                'host': secret['host'],
                'port': secret.get('port', 5432),
                'user': secret['username'],
                'password': secret['password'],
                'database': secret['dbname']
            }
        except Exception as e:
            print(f"Warning: Failed to get secret from AWS: {e}")
            # Fall through to environment variables
    
    # Use environment variables
    if not settings.pg_host or not settings.pg_password:
        raise ValueError("Database connection info not found. Set SECRET_ID or PG_HOST/PG_PASSWORD.")
    
    return {
        'host': settings.pg_host,
        'port': settings.pg_port,
        'user': settings.pg_user,
        'password': settings.pg_password,
        'database': settings.pg_dbname
    }

@contextmanager
def get_connection(settings: Settings):
    """Get a database connection with context manager."""
    credentials = get_db_credentials(settings)
    
    conn = pg8000.connect(
        host=credentials['host'],
        port=credentials['port'],
        user=credentials['user'],
        password=credentials['password'],
        database=credentials['database'],
        ssl_context=True  # Enable SSL for RDS
    )
    
    try:
        yield conn
    finally:
        conn.close()

def check_sql_injection_risk(query: str) -> List[str]:
    """Check for SQL injection patterns."""
    issues = []
    query_lower = query.lower()
    
    for pattern in SQL_INJECTION_PATTERNS:
        if re.search(pattern, query_lower, re.IGNORECASE):
            issues.append(f"Suspicious pattern detected: {pattern[:50]}...")
    
    return issues

def detect_mutating_keywords(query: str) -> List[str]:
    """Detect mutating SQL keywords."""
    query_upper = query.upper().strip()
    detected = []
    
    for keyword in MUTATING_KEYWORDS:
        if query_upper.startswith(keyword) or f' {keyword} ' in query_upper:
            detected.append(keyword)
    
    return detected