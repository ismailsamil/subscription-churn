{{ config(materialized='incremental',
    incremental_strategy='merge',
        unique_key=['"customer_id"', '"Date"'])
}}


{% macro yes_no_to_boolean(value) %}
    case
        when {{ value }} = 'Yes' then true
        when {{ value }} = 'No' then false
        else null
    end
{% endmacro %}


select 
    "customer_id",  

    coalesce("gender", 'Unknown') as "gender",

    case
        when "is_senior_citizen" = '1' then true
        when "is_senior_citizen" = '0' then false
        else null
    end as "is_senior_citizen",

    {{ yes_no_to_boolean("has_partner") }} as "has_partner",
    {{ yes_no_to_boolean("has_dependents") }} as "has_dependents",
    "tenure",
    {{ yes_no_to_boolean("phone_service") }} as "phone_service",
    {{ yes_no_to_boolean("internet_service") }} as "internet_service",
    "contract_type",
    "payment_id",
    "payment_method",
    "monthly_charges",

    coalesce("total_charges", 0) as "total_charges",

    case
        when "has_churned" = 'Yes' then 1
        else 0
    end as "churn_flag",

    case
        when "has_churned" = 'Yes'
        then "monthly_charges"
        else 0
    end as "monthly_revenue_lost",

    case
        when "has_churned" = 'Yes'
        then "monthly_charges" * 12
        else 0
    end as "annualized_revenue_lost" ,
    case
    when "tenure" <= 6 then '0-6 months'
    when "tenure" <= 12 then '7-12 months'
    when "tenure" <= 24 then '13-24 months'
    when "tenure" <= 48 then '25-48 months'
    else '49+ months'
end as "tenure_segment",
"Date"

from {{ ref('stg_customers') }}

where "customer_id" is not null
  and "has_churned" is not null
  and "monthly_charges" is not null
  AND "tenure" is not null
{% if is_incremental() %}
   and "Date" <= (select coalesce(max("Date"), '190001') from {{ this }})
 {% endif %}