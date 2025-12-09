DB_CONFIG_FILE = "sql_server_config.cfg"
DB_NAME = "ORDER_DDS"
SCHEMA_NAME = "dimensional"

# Dimension tables
DIM_TABLES = [
    "DimCategories",
    "DimCustomers",
    "DimEmployees",
    "DimProducts",
    "DimRegion",
    "DimShippers",
    "DimSuppliers",
    "DimTerritories"
]

# Fact tables
FACT_TABLES = [
    "FactOrders",
    "FactOrderDetails"
]

# Fact error tables
FACT_ERROR_TABLES = [
    "FactOrders_Error",
    "FactOrderDetails_Error"
]

# Mapping of dimensional tables to their staging tables
DIM_TO_STG_MAP = {
    "DimCategories": "Stg_Categories",
    "DimCustomers": "Stg_Customers",
    "DimEmployees": "Stg_Employees",
    "DimProducts": "Stg_Products",
    "DimRegion": "Stg_Region",
    "DimShippers": "Stg_Shippers",
    "DimSuppliers": "Stg_Suppliers",
    "DimTerritories": "Stg_Territories"
}

FACT_TO_STG_MAP = {
    "FactOrders": "Stg_Orders",
    "FactOrderDetails": "Stg_OrderDetails"
}

FACT_ERROR_TO_STG_MAP = {
    "FactOrders_Error": "Stg_Orders",
    "FactOrderDetails_Error": "Stg_OrderDetails"
}
