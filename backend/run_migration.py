#!/usr/bin/env python3
"""
Database migration script to add missing chat tables
"""
import os
import sys
from pathlib import Path

# Add the src directory to Python path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from src.routes.utils.database import engine
from sqlalchemy import text

def run_migration():
    """Run the migration to add chat tables"""
    
    migration_sql = """
    -- Add chat_sessions table
    CREATE TABLE IF NOT EXISTS chat_sessions (
        session_id BIGSERIAL PRIMARY KEY,
        user_id BIGINT NOT NULL,
        machine_id BIGINT,
        title VARCHAR(255),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        FOREIGN KEY (machine_id) REFERENCES machines(machine_id) ON DELETE SET NULL
    );

    -- Add chat_messages table
    CREATE TABLE IF NOT EXISTS chat_messages (
        message_id BIGSERIAL PRIMARY KEY,
        session_id BIGINT NOT NULL,
        role VARCHAR(50) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
        content TEXT NOT NULL,
        timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
        message_metadata JSONB,
        FOREIGN KEY (session_id) REFERENCES chat_sessions(session_id) ON DELETE CASCADE
    );

    -- Add indexes for performance
    CREATE INDEX IF NOT EXISTS idx_chat_sessions_user_id ON chat_sessions (user_id);
    CREATE INDEX IF NOT EXISTS idx_chat_sessions_machine_id ON chat_sessions (machine_id);
    CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages (session_id);
    """
    
    try:
        with engine.connect() as conn:
            # Split SQL into individual statements
            statements = [stmt.strip() for stmt in migration_sql.split(';') if stmt.strip()]
            
            for statement in statements:
                if statement:
                    print(f"Executing: {statement[:50]}...")
                    conn.execute(text(statement))
                    conn.commit()
                    print("✅ Success")
            
            print("\n🎉 Migration completed successfully!")
            
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    print("🚀 Starting database migration...")
    run_migration()
