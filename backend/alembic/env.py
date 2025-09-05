from logging.config import fileConfig
from src.model import models  # <- import all your models here!
from src.routes.utils.database import get_sqlmodel_metadata
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
import sqlalchemy as sa
import os
import sys
from dotenv import load_dotenv

load_dotenv()

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

DATABASE_URL = os.getenv("DATABASE_URL")
config.set_main_option("sqlalchemy.url", DATABASE_URL) # type: ignore

target_metadata = get_sqlmodel_metadata()

# Add this function to handle SQLModel types
def render_item(type_, obj, autogen_context):
    """Apply custom rendering for specific types."""
    if hasattr(obj, 'type') and hasattr(obj.type, '__class__'):
        if 'AutoString' in str(obj.type.__class__):
            return "sa.String()"
        # Add other type mappings if needed
    return False

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        render_item=render_item,  # Add this line
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, 
            target_metadata=target_metadata,
            render_item=render_item,  # Add this line
        )

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()