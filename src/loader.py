from connection import helper_fun
import pandas as pd
import os

def write_Df_to_Snowflake(df, table_name, session):
    """
    Writes a DataFrame to a Snowflake table.

    Args:
        df (pandas.DataFrame): The DataFrame to be written to Snowflake.
        table_name (str): The name of the target Snowflake table.
        conn (snowflake.snowpark.session.Session): A session object to interact with Snowflake.

    Returns:
        None
    """
    # Ensure the cursor is defined even if an exception occurs
    try:
        # Create a cursor object

        # Write the DataFrame to the specified Snowflake table
        success, nchunks, nrows, _ = session.write_pandas(df, table_name,auto_create_table=True)

        if success:
            print(f"Successfully wrote {nrows} rows to {table_name}.")
        else:
            print(f"Failed to write DataFrame to {table_name}.")

    except Exception as e:
        print(f"Error writing DataFrame to Snowflake: {e}")
 


if __name__ == "__main__":
    session=helper_fun()
    file_data="WA_Fn-UseC_-Telco-Customer-Churn.csv"
    df_customers=pd.read_csv(os.path.join("data", file_data),header=0)
    write_Df_to_Snowflake(df_customers, "CUSTOMERS", session)
