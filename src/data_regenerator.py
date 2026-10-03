import pandas as pd
import random
import string
from loader import write_Df_to_Snowflake, helper_fun

def generate_customer_id() -> str:
    """
    Generate a random customer ID in the format:
    4 digits + hyphen + 5 uppercase letters
    Example: 7590-VHVEG
    """
    numbers = ''.join(random.choices(string.digits, k=4))
    letters = ''.join(random.choices(string.ascii_uppercase, k=5))

    return f"{numbers}-{letters}"


if __name__ == "__main__":

    # print("Original rows:", len(df))
    df = pd.read_csv(r"C:\Users\ismsamil\OneDrive - NTT DATA EMEAL\Desktop\Subscription Churn\data\WA_Fn-UseC_-Telco-Customer-Churn.csv")
    row_nums = 910_000

    rows = []

    for _ in range(row_nums):

        data = {
            "customerID": generate_customer_id(),

            "gender": random.choice(
                ["Male", "Female", None]
            ),

            "SeniorCitizen": random.choice(
                [0, 1, None]
            ),

            "Partner": random.choice(
                ["Yes", "No", None]
            ),

            "Dependents": random.choice(
                ["Yes", "No", None]
            ),

            "tenure": random.choice(
                [random.randint(0, 99)]
            ),

            "PhoneService": random.choice(
                ["Yes", "No", None]
            ),

            "MultipleLines": random.choice(
                ["Yes", "No", "No phone service", None]
            ),

            "InternetService": random.choice(
                ["DSL", "Fiber optic", "No", None]
            ),

            "OnlineSecurity": random.choice(
                ["Yes", "No", "No internet service", None]
            ),

            "OnlineBackup": random.choice(
                ["Yes", "No", "No internet service", None]
            ),

            "DeviceProtection": random.choice(
                ["Yes", "No", "No internet service", None]
            ),

            "TechSupport": random.choice(
                ["Yes", "No", "No internet service", None]
            ),

            "StreamingTV": random.choice(
                ["Yes", "No", "No internet service", None]
            ),

            "StreamingMovies": random.choice(
                ["Yes", "No", "No internet service", None]
            ),

            "Contract": random.choice(
                ["Month-to-month", "One year", "Two year", None]
            ),

            "PaperlessBilling": random.choice(
                ["Yes", "No", None]
            ),

            "PaymentMethod": random.choice(
                [
                    "Electronic check",
                    "Mailed check",
                    "Bank transfer (automatic)",
                    "Credit card (automatic)"
                ]
            ),

            "MonthlyCharges": random.choice(
                [round(random.uniform(0, 100), 2)]
            ),

            "TotalCharges": random.choice([
                    round(random.uniform(0, 10000), 2)
    ]),

            "Churn": random.choice(
                ["No"]
            ),
            "Date": (pd.Timestamp.now() + pd.DateOffset(months=1)).strftime("%Y%m")
        }
    
        rows.append(data)


    # Create generated DataFrame
    df_generated = pd.DataFrame(rows)
    
    print("Generated rows:", len(df_generated))

    # Append generated data to original data
    df_final = pd.concat(
        [df, df_generated],
        ignore_index=True
    )
    df_final["TotalCharges"] = pd.to_numeric(
    df_final["TotalCharges"],
    errors="coerce"
)
    df_final["MonthlyCharges"] = pd.to_numeric(
        df_final["MonthlyCharges"],
        errors="coerce"
    )
    df_final["Date"]=(pd.Timestamp.now() + pd.DateOffset(months=1)).strftime("%Y%m")
    session=helper_fun()
    print("Final rows:", len(df_final))

    write_Df_to_Snowflake(df_final, "customers_raw", session)

    # print(df_final.head())
    # print("Final rows:", df_final.head(30))