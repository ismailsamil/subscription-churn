-- What is the current churn situation?
-- Create KPI cards:
                        -- Total Customers
                        -- Churned Customers
                        -- Active Customers
                        -- Churn Rate
                        -- Monthly Revenue Lost
                        -- Annualized Revenue Lost
                        -- Average Monthly Charge

{{ config(
    materialized='view',
) }}


select
    count(*) as "total_customers",

    sum("churn_flag") as "churned_customers",

    count(*) - sum("churn_flag") as "active_customers",

    round(
        sum("churn_flag") / nullif(count(*), 0),
        4
    ) as "churn_rate",

    sum("monthly_revenue_lost") as "monthly_revenue_lost"   ,

    sum("annualized_revenue_lost") as "annualized_revenue_lost",

    avg("monthly_charges") as "avg_monthly_charges"

from {{ ref('fct_customer_churn') }}