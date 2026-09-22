


select
    "customerID"                         as customer_id,
    "tenure"::integer                    as tenure_months,
    "PhoneService"                       as phone_service,
    "InternetService"                    as internet_service,
    "Contract"                           as contract_type,
    HASH("PaymentMethod")                      as payment_id,
    "MonthlyCharges"::number(10,2)       as monthly_charges,
    "TotalCharges"::number(10,2)         as total_charges

from {{ ref('customers_silver') }} 
