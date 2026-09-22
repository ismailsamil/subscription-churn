select 
payment_id ,
   payment_method
from {{ ref('customers_silver') }} 
