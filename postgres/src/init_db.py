"""Initialize database with sample tables and data."""

import os
from dotenv import load_dotenv
from mlservice.db import Settings, get_connection

load_dotenv()


def init_database():
    """Initialize database with sample schema."""
    settings = Settings()

    # Read SQL file
    sql_file = os.path.join('..', '..', 'scripts', 'init_database.sql')
    with open(sql_file, 'r') as f:
        sql_script = f.read()

    print("Initializing database with sample schema...")

    try:
        with get_connection(settings) as conn:
            cursor = conn.cursor()

            # Execute the SQL script
            cursor.execute(sql_script)
            conn.commit()

            # Verify tables were created
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_type = 'BASE TABLE'
            """)

            tables = cursor.fetchall()
            print(f"\n✅ Created {len(tables)} tables:")
            for table in tables:
                print(f"  - {table[0]}")

            cursor.close()

    except Exception as e:
        print(f"❌ Error: {e}")
        raise


if __name__ == "__main__":
    init_database()