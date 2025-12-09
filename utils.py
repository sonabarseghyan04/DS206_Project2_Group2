
import pyodbc
from datetime import datetime
import uuid
import configparser
from typing import Dict, Any
import os


def create_connection_string(cfg: dict) -> str:
    conn = (
        f"DRIVER={{{cfg['driver']}}};"
        f"SERVER={cfg['server']};"
        f"DATABASE={cfg['database']};"
        f"Trusted_Connection={cfg.get('trusted_connection','yes')};"
        f"TrustServerCertificate={cfg.get('trustservercertificate','yes')};"
    )
    return conn




# =========================
# DATABASE UTILS
# =========================

def read_sql_file(file_path: str) -> str:
    """
    Reads an SQL file and returns its content as a string.

    Args:
        file_path (str): Path to the SQL file.

    Returns:
        str: SQL query content.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        sql = file.read()
    return sql


def parse_db_config(config_file: str, section: str = 'sqlserver') -> dict:

    """
    Reads a database config file (.cfg or .ini) and returns connection parameters.

    Args:
        config_file (str): Path to the config file.
        section (str): Section in the config file. Default is 'SQLServer'.

    Returns:
        dict: Dictionary with connection parameters.
    """
    parser = configparser.ConfigParser()
    parser.read(config_file)

    if section not in parser:
        raise Exception(f"Section {section} not found in {config_file}")

    db_config = {param: parser.get(section, param) for param in parser[section]}
    return db_config

def get_sql_config(config_file: str, section: str = "SQLServer") -> dict:
    return parse_db_config(config_file, section)


def get_db_connection(db_config: dict):
    conn_str = create_connection_string(db_config)
    return pyodbc.connect(conn_str)




# =========================
# EXECUTION & LOGGING UTILS
# =========================

def generate_uuid() -> str:
    """
    Generates a unique UUID string for tracking executions.

    Returns:
        str: UUID string.
    """
    return str(uuid.uuid4())


def current_timestamp() -> str:
    """
    Returns the current timestamp as a formatted string.

    Returns:
        str: Current timestamp in YYYY-MM-DD HH:MM:SS format.
    """
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


# =========================
# FILE UTILS
# =========================

def ensure_folder_exists(folder_path: str):
    """
    Checks if a folder exists, creates it if it doesn't.

    Args:
        folder_path (str): Path to the folder.
    """
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
