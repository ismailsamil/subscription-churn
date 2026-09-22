select 
"customerID"                         as customer_id,
    coalesce("gender", 'Unknown')                            as gender,
    case
    when "SeniorCitizen" = 1 then true
    when "SeniorCitizen" = 0 then false
    else null
end as is_senior_citizen ,
    "Partner"                     as has_partner,
    "Dependents"               as has_dependents,
    "tenure"::integer                    as tenure_months,
    "PhoneService"                       as phone_service,
    "InternetService"                    as internet_service,
    "Contract"                           as contract_type,
    "PaymentMethod"                      as payment_method,
    "MonthlyCharges"::number(10,2)       as monthly_charges,
    coalesce("TotalCharges"::number(10,2), 0)        as total_charges,
    "Churn"::varchar = 'Yes'                    as has_churned

from {{ ref('stg_customers') }} 
where customer_id is not null and tenure is not null and monthly_charges is not null and total_charges is not null