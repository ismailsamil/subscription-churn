import snowflake.connector
from dotenv import load_dotenv
import os
load_dotenv()


def get_snowflake_connection(user, password, account, warehouse, database, schema,Role):
    """
    Establishes a connection to Snowflake.

    Args:
        user (str): Snowflake username.
        password (str): Snowflake password.
        account (str): Snowflake account identifier.
        warehouse (str): Snowflake warehouse name.
        database (str): Snowflake database name.
        schema (str): Snowflake schema name.

    Returns:
        snowflake.connector.connection.SnowflakeConnection: A connection object to interact with Snowflake.
    """
    try:
        conn = snowflake.connector.connect(
            user=user,
            password=password,
            account=account,
            warehouse=warehouse,
            database=database,
            schema=schema,
            role=Role
        )
        return conn
    except Exception as e:
        print(f"Error connecting to Snowflake: {e}")
        return None

def helper_Fun():
    """
    A placeholder helper function. This function can be expanded to include any additional logic or utility functions needed for the Snowflake connection.

    Returns:
        str: A message indicating that the helper function was called.
    """
    user=os.getenv("user")   
    password=os.getenv("password")
    account=os.getenv("account")
    warehouse=os.getenv("warehouse")
    database=os.getenv("database")
    schema=os.getenv("schema")
    role=os.getenv("role")

    conn=get_snowflake_connection(user, password, account, warehouse, database, schema, role)
    print("Connection established successfully!" if conn else "Failed to establish connection.")
