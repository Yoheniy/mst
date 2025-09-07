#!/usr/bin/env python3
"""
Script to fix enum case consistency in database - convert all enum values to lowercase
"""
import os
import sys
from pathlib import Path

# Add the src directory to Python path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from src.routes.utils.database import engine
from sqlalchemy import text

def fix_enum_case():
    """Update all enum values from uppercase to lowercase for consistency"""
    
    enum_updates = [
        # Table: users, Column: role
        {
            "table": "users",
            "column": "role", 
            "uppercase_values": ["'ADMIN'", "'CUSTOMER'", "'TECHNICIAN'", "'SALES_AGENT'"],
            "lowercase_values": ["'admin'", "'customer'", "'technician'", "'sales_agent'"]
        },
        
        # Table: tickets, Column: status
        {
            "table": "tickets", 
            "column": "status",
            "uppercase_values": ["'OPEN'", "'IN_PROGRESS'", "'RESOLVED'", "'CLOSED'", "'ESCALATED'"],
            "lowercase_values": ["'open'", "'in_progress'", "'resolved'", "'closed'", "'escalated'"]
        },
        
        # Table: tickets, Column: priority
        {
            "table": "tickets",
            "column": "priority", 
            "uppercase_values": ["'LOW'", "'MEDIUM'", "'HIGH'", "'URGENT'"],
            "lowercase_values": ["'low'", "'medium'", "'high'", "'urgent'"]
        },
        
        # Table: knowledge_base_contents, Column: content_type
        {
            "table": "knowledge_base_contents",
            "column": "content_type",
            "uppercase_values": ["'DOCUMENT'", "'FAQ'", "'TROUBLESHOOTING_GUIDE'", "'VIDEO'", "'TUTORIAL'", "'ERROR_GUIDE'"],
            "lowercase_values": ["'document'", "'faq'", "'troubleshooting_guide'", "'video'", "'tutorial'", "'error_guide'"]
        },
        
        # Table: anomaly_reports, Column: status
        {
            "table": "anomaly_reports",
            "column": "status",
            "uppercase_values": ["'SUBMITTED'", "'UNDER_REVIEW'", "'KB_INCORPORATED'", "'CLOSED'"],
            "lowercase_values": ["'submitted'", "'under_review'", "'kb_incorporated'", "'closed'"]
        },
        
        # Table: anomaly_reports, Column: priority
        {
            "table": "anomaly_reports",
            "column": "priority",
            "uppercase_values": ["'LOW'", "'MEDIUM'", "'HIGH'"],
            "lowercase_values": ["'low'", "'medium'", "'high'"]
        },
        
        # Table: error_codes, Column: severity
        {
            "table": "error_codes",
            "column": "severity", 
            "uppercase_values": ["'MINOR'", "'WARNING'", "'CRITICAL'"],
            "lowercase_values": ["'minor'", "'warning'", "'critical'"]
        },
        
        # Table: error_codes, Column: manufacturer_origin
        {
            "table": "error_codes",
            "column": "manufacturer_origin",
            "uppercase_values": ["'MACHINE'", "'CHILLER'", "'LASER_SOURCE'", "'DRIVE'", "'CONTROLLER'", "'SOFTWARE'", "'OTHER'"],
            "lowercase_values": ["'machine'", "'chiller'", "'laser_source'", "'drive'", "'controller'", "'software'", "'other'"]
        },
        
        # Table: chat_messages, Column: role
        {
            "table": "chat_messages",
            "column": "role",
            "uppercase_values": ["'USER'", "'ASSISTANT'", "'SYSTEM'"],
            "lowercase_values": ["'user'", "'assistant'", "'system'"]
        }
    ]
    
    try:
        with engine.connect() as conn:
            print("🔄 Converting all enum values to lowercase...")
            
            total_updated = 0
            
            for enum_update in enum_updates:
                table = enum_update["table"]
                column = enum_update["column"]
                uppercase_values = enum_update["uppercase_values"]
                lowercase_values = enum_update["lowercase_values"]
                
                # Create UPDATE statements for each value pair
                for upper_val, lower_val in zip(uppercase_values, lowercase_values):
                    update_sql = f"""
                    UPDATE {table} 
                    SET {column} = {lower_val}
                    WHERE {column} = {upper_val};
                    """
                    
                    try:
                        result = conn.execute(text(update_sql))
                        updated_count = result.rowcount
                        if updated_count > 0:
                            print(f"✅ {table}.{column}: {upper_val} → {lower_val} ({updated_count} rows)")
                            total_updated += updated_count
                    except Exception as e:
                        print(f"⚠️  Error updating {table}.{column}: {e}")
            
            conn.commit()
            print(f"\n🎉 Enum case fix completed! Total rows updated: {total_updated}")
            
            # Show summary of current values
            print("\n📊 Current enum value distribution:")
            summary_queries = [
                ("users", "role"),
                ("tickets", "status"), 
                ("tickets", "priority"),
                ("knowledge_base_contents", "content_type"),
                ("anomaly_reports", "status"),
                ("anomaly_reports", "priority"),
                ("error_codes", "severity"),
                ("error_codes", "manufacturer_origin"),
                ("chat_messages", "role")
            ]
            
            for table, column in summary_queries:
                try:
                    query = f"SELECT {column}, COUNT(*) as count FROM {table} GROUP BY {column} ORDER BY {column};"
                    result = conn.execute(text(query))
                    rows = result.fetchall()
                    
                    if rows:
                        print(f"\n{table}.{column}:")
                        for row in rows:
                            print(f"  {row[0]}: {row[1]}")
                except Exception as e:
                    print(f"⚠️  Could not query {table}.{column}: {e}")
            
    except Exception as e:
        print(f"❌ Enum case fix failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    print("🚀 Starting comprehensive enum case fix...")
    fix_enum_case()