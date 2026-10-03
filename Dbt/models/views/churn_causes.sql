-- Why customers churn
-- Churn Rate by Contract Type
-- Churn Rate by Tenure Group
-- Churn Rate by Internet Service
-- Churn Rate by Payment Method
-- Churn Rate by Senior Citizen
-- Churn Rate by Partner Status
-- Churn Rate by Dependents


select
    "contract_type",

    count(*) as "customers",

    sum("churn_flag") as "churned_customers",

    round(
        sum("churn_flag") / nullif(count(*), 0),
        4
    ) as "churn_rate",

    sum("monthly_revenue_lost") as "monthly_revenue_lost"

from {{ ref('fct_customer_churn') }}

group by "contract_type"