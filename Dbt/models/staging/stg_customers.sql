-- models/staging/stg_customers.sql
{{ config(materialized='incremental',
    incremental_strategy='merge',
        unique_key=['"customer_id"', '"Date"'])
}}

select
    "customerID"                         as "customer_id",
    "gender"                             as "gender",
    "SeniorCitizen"::varchar       as "is_senior_citizen",
    "Partner"                     as "has_partner",
    "Dependents"               as "has_dependents",
    "tenure"::integer                  as "tenure",
    "PhoneService"                       as "phone_service",
    "InternetService"                    as "internet_service",
    "Contract"                           as "contract_type",
    HASH("PaymentMethod")                      as "payment_id",
    "PaymentMethod"                      as "payment_method",
    "MonthlyCharges"::number(10,2)       as "monthly_charges",
    TRY_TO_NUMBER(NULLIF(TRIM("TotalCharges"), ''), 10, 2) as "total_charges",
    "Churn"                     as "has_churned",
    "Date"

    FROM    {{ source('snowflake', 'customers') }}
where NULLIF(TRIM("TotalCharges"), '') is not null
{% if is_incremental() %}
   and "Date" <= (select coalesce(max("Date"), '190001') from {{ this }})
 {% endif %}

