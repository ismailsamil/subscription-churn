select 
Customer_id,
    gender,
   is_senior_citizen,
   has_dependents,
   has_partner,
   has_churned
from {{ ref('customers_silver') }} 
