import os
import math
import pandas as pd
from typing import Dict, Any, List

from utils import read_sql_file, parse_db_config, get_db_connection
from pipeline_dimensional_data.config import DB_CONFIG_FILE
from logging_utils import get_rotating_logger


RAW_XLSX_PATH = os.path.join("raw_data", "raw_data_source.xlsx")
LOG_FILE = os.path.join("logs", "tasks.log")

# Mapping: Excel sheet name -> staging table name
SHEET_TO_TABLE = {
    "Categories": "Stg_Categories",
    "Customers": "Stg_Customers",
    "Employees": "Stg_Employees",
    "OrderDetails": "Stg_OrderDetails",
    "Orders": "Stg_Orders",
    "Products": "Stg_Products",
    "Region": "Stg_Region",
    "Shippers": "Stg_Shippers",
    "Suppliers": "Stg_Suppliers",
    "Territories": "Stg_Territories"
}

# -------------------------
# Helper function to run SQL
# -------------------------
def run_sql_file(conn, sql_file_path, params: dict = None, logger=None):
    """
    Execute an SQL file with optional parameters.

    :param sql_file_path: path to SQL file
    :param params: dictionary of template parameters to replace in SQL
    :param logger: optional logger to log execution
    """
    sql_query = read_sql_file(sql_file_path)

    if params:
        for key, value in params.items():
            sql_query = sql_query.replace(f"{{{{{key}}}}}", str(value))

    if logger:
        logger.info(f"Executing SQL script: {sql_file_path}")

    cursor = conn.cursor()
    cursor.execute(sql_query)
    conn.commit()
    cursor.close()

    if logger:
        logger.info(f"Finished SQL script: {sql_file_path}")


# -------------------------
# Load staging from Excel
# -------------------------
def _df_to_param_rows(df: pd.DataFrame, cols: List[str]) -> List[tuple]:
    """
    Convert dataframe rows to list of tuples, matching columns order in cols.
    Replace NaN with None for DB insert.
    """
    rows = []
    for _, r in df.iterrows():
        vals = []
        for c in cols:
            v = r.get(c, None)
            if pd.isna(v):
                v = None
            if isinstance(v, (float,)) and math.isnan(v):
                v = None
            vals.append(v)
        rows.append(tuple(vals))
    return rows


def load_staging_tables(xlsx_path: str = RAW_XLSX_PATH,
                        truncate_before_insert: bool = True,
                        batch_size: int = 1000,
                        execution_id: str = None) -> Dict[str, Any]:
    """
    Reads the Excel file and loads each sheet to the corresponding staging table.

    :param xlsx_path: path to the excel file (single file with many sheets)
    :param truncate_before_insert: whether to TRUNCATE staging tables before load
    :param batch_size: how many rows per executemany
    :param execution_id: for logging
    :return: dict with success status and details
    """
    logger = get_rotating_logger("load_staging", LOG_FILE)

    logger.info(f"Starting load_staging_tables | file={xlsx_path} | execution_id={execution_id}")

    if not os.path.exists(xlsx_path):
        msg = f"Excel file not found: {xlsx_path}"
        logger.error(msg)
        return {"success": False, "task": "load_staging_tables", "error": msg}

    try:
        logger.info("Reading Excel file into pandas (this may take a moment)...")
        xls = pd.read_excel(xlsx_path, sheet_name=None, engine="openpyxl")
        logger.info(f"Excel read complete. Sheets found: {list(xls.keys())}")

        conn_params = parse_db_config(DB_CONFIG_FILE, section="sqlserver")
        conn = get_db_connection(conn_params)
        cursor = conn.cursor()

        for sheet_name, df in xls.items():
            if sheet_name not in SHEET_TO_TABLE:
                logger.warning(f"Sheet '{sheet_name}' not mapped to a staging table; skipping.")
                continue

            staging_table = SHEET_TO_TABLE[sheet_name]
            full_table_name = f"staging.{staging_table}"

            logger.info(f"Processing sheet '{sheet_name}' -> {full_table_name} | rows={len(df)}")

            df.columns = [str(c).strip() for c in df.columns]

            df = df.loc[:, ~df.columns.str.contains("^Unnamed")]

            if "staging_raw_id_sk" in df.columns:
                df = df.drop(columns=["staging_raw_id_sk"])

            insert_cols = [col for col in df.columns]
            if not insert_cols:
                logger.warning(f"No columns detected for sheet {sheet_name}; skipping.")
                continue

            placeholders = ",".join(["?"] * len(insert_cols))
            column_list_sql = ",".join([f"[{c}]" for c in insert_cols])  # bracket columns for safety

            insert_sql = f"INSERT INTO {full_table_name} ({column_list_sql}) VALUES ({placeholders})"

            if truncate_before_insert:
                try:
                    logger.info(f"Truncating table {full_table_name} before load.")
                    cursor.execute(f"TRUNCATE TABLE {full_table_name};")
                    conn.commit()
                except Exception as te:

                    logger.warning(f"TRUNCATE failed for {full_table_name}: {te}. Falling back to DELETE.")
                    cursor.execute(f"DELETE FROM {full_table_name};")
                    conn.commit()

            rows = _df_to_param_rows(df, insert_cols)
            logger.info(f"Prepared {len(rows)} rows for insert into {full_table_name}.")

            if not rows:
                logger.info(f"No rows to insert for {full_table_name}; continuing.")
                continue


            try:
                cursor.fast_executemany = True
            except Exception:
                pass

            total = len(rows)
            for i in range(0, total, batch_size):
                batch = rows[i:i + batch_size]
                logger.info(f"Inserting rows {i + 1}-{i + len(batch)} into {full_table_name} ...")
                cursor.executemany(insert_sql, batch)
                conn.commit()

            logger.info(f"Finished inserting into {full_table_name} (inserted {total} rows).")

        cursor.close()
        conn.close()

        logger.info("All staging sheets processed successfully.")
        return {"success": True, "task": "load_staging_tables"}

    except Exception as e:
        logger.exception("Failed loading staging tables")
        return {"success": False, "task": "load_staging_tables", "error": str(e)}


# -------------------------
# Core pipeline tasks
# -------------------------
def update_dimensions(start_date=None, end_date=None, execution_id=None, params = None):
    """
    Run all dimension updates sequentially.
    """
    logger = get_rotating_logger("update_dimensions", LOG_FILE)

    try:
        conn_params = parse_db_config(DB_CONFIG_FILE, section="sqlserver")
        conn = get_db_connection(conn_params)

        dim_scripts = [
            "update_dim_categories.sql",
            "update_dim_customers.sql",
            "update_dim_employees.sql",
            "update_dim_products.sql",
            "update_dim_region.sql",
            "update_dim_shippers.sql",
            "update_dim_suppliers.sql",
            "update_dim_territories.sql"
        ]

        for script in dim_scripts:
            run_sql_file(
                conn,
                f"pipeline_dimensional_data/queries/{script}",
                params=params,
                logger=logger
            )

        conn.close()
        logger.info("All dimension tables updated successfully.")

        return {"success": True, "task": "update_dimensions"}

    except Exception as e:
        logger.exception("Dimension update failed")
        return {"success": False, "task": "update_dimensions", "error": str(e)}


def update_facts(start_date: str, end_date: str, execution_id=None, params=None):
    """
    Run fact table updates sequentially.
    """
    logger = get_rotating_logger("update_facts", LOG_FILE)

    try:
        conn_params = parse_db_config(DB_CONFIG_FILE, section="sqlserver")
        conn = get_db_connection(conn_params)

        fact_scripts = [
            "update_fact_FactOrders.sql",
            "update_fact_FactOrderDetails.sql",
            "update_fact_error_FactOrders.sql",
            "update_fact_error_FactOrderDetails.sql"
        ]

        for script in fact_scripts:
            run_sql_file(
                conn,
                f"pipeline_dimensional_data/queries/{script}",
                params=params,
                logger=logger
            )

        conn.close()
        logger.info("All fact tables updated successfully.")

        return {"success": True, "task": "update_facts"}

    except Exception as e:
        logger.exception("Fact update failed")
        return {"success": False, "task": "update_facts", "error": str(e)}


# -------------------------
# Full pipeline execution
# -------------------------
def run_full_pipeline(start_date: str, end_date: str, execution_id=None):
    """
    Run the full dimensional data flow.
    """
    database_name = "ORDER_DDS"

    params = {"start_date": start_date, "end_date": end_date, "database_name": "ORDER_DDS"}

    # 1) Load staging
    load_status = load_staging_tables(execution_id=execution_id)
    if not load_status.get("success"):
        return {"success": False, "stage": "staging", "details": load_status}

    # 2) Update dimensions
    dim_status = update_dimensions(start_date=start_date, end_date=end_date, execution_id=execution_id, params=params)
    if not dim_status["success"]:
        return {"success": False, "stage": "dimensions", "details": dim_status}

    # 3) Update facts
    fact_status = update_facts(start_date=start_date, end_date=end_date, execution_id=execution_id, params=params)
    if not fact_status["success"]:
        return {"success": False, "stage": "facts", "details": fact_status}

    return {"success": True, "stage": "full_pipeline"}

