{{ config(materialized='incremental',
    incremental_strategy='merge',
        unique_key=['"customer_id"', '"date"'])
}}

select
    "customer_id",
    "tenure",
     "phone_service",
    "internet_service",
   "contract_type",
    "payment_id",
   "monthly_charges",
    "total_charges",
    "churn_flag" ,
    "monthly_revenue_lost",
    "annualized_revenue_lost",
    "tenure_segment",
    "Date" as "date"

from {{ ref('customers_silver') }} 
Having
 {% if is_incremental() %}
    "Date" <= (select coalesce(max("date"), '190001') from {{ this }})
 {% endif %}
