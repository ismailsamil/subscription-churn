{{ config(
    materialized='table',
) }}

select 
DISTINCT("customer_id"),
    "gender",
   "is_senior_citizen",
   "has_dependents",
   "has_partner"   
from {{ ref('customers_silver') }} 
