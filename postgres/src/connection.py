"""Test database connection before running MCP server."""

import os
from dotenv import load_dotenv
from mlservice.db import Settings, get_connection

load_dotenv()


def test_connection():
    """Test the database connection."""
    settings = Settings()

    print(f"Testing connection to PostgreSQL...")
    print(f"Using secret: {settings.secret_id}")

    try:
        with get_connection(settings) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT version()")
            version = cursor.fetchone()[0]
            print(f"✅ Connected successfully!")
            print(f"PostgreSQL version: {version}")

            # Test database name
            cursor.execute("SELECT current_database()")
            db_name = cursor.fetchone()[0]
            print(f"Database: {db_name}")

            cursor.close()

    except Exception as e:
        print(f"❌ Connection failed: {e}")
        raise


if __name__ == "__main__":
    test_connection()