-- models/staging/stg_customers.sql


select
    "customerID"                         as customer_id,
    "gender"                             as gender,
    "SeniorCitizen"::varchar       as is_senior_citizen,
    "Partner"                     as has_partner,
    "Dependents"               as has_dependents,
    "tenure"::integer                    as tenure_months,
    "PhoneService"                       as phone_service,
    "InternetService"                    as internet_service,
    "Contract"                           as contract_type,
    HASH("PaymentMethod")                      as payment_id,
    "PaymentMethod"                      as payment_method,
    "MonthlyCharges"::number(10,2)       as monthly_charges,
    "TotalCharges"::number(10,2)         as total_charges,
    "Churn"                     as has_churned

    FROM    {{ source('snowflake', 'customers') }}


