from snowflake.snowpark import Session
from dotenv import load_dotenv
import os

load_dotenv()


def get_snowflake_session(
    user,
    password,
    account,
    warehouse,
    database,
    schema,
    role
):
    """
    Establish a Snowpark session with Snowflake.
    """

    try:
        connection_parameters = {
            "user": user,
            "password": password,
            "account": account,
            "warehouse": warehouse,
            "database": database,
            "schema": schema,
            "role": role
        }

        session = Session.builder.configs(connection_parameters).create()

        return session

    except Exception as e:
        print(f"Error connecting to Snowflake: {e}")
        return None


def helper_fun():
    """
    Read Snowflake credentials from .env
    and create a Snowpark session.
    """

    user = os.getenv("user")
    password = os.getenv("password")
    account = os.getenv("account")
    warehouse = os.getenv("warehouse")
    database = os.getenv("database")
    schema = os.getenv("schema")
    role = os.getenv("role")

    session = get_snowflake_session(
        user=user,
        password=password,
        account=account,
        warehouse=warehouse,
        database=database,
        schema=schema,
        role=role
    )

    if session:
        print("Connection established successfully!")
    else:
        print("Failed to establish connection.")

    return session

