select
  da.account_sk, dc.customer_sk, t.post_date, t.amount, t.currency, t.dc_indicator
from {{ ref('silver_transaction') }} t
join {{ ref('dim_account') }}  da on t.account_id = da.account_id
left join {{ ref('dim_customer') }} dc on da.customer_sk = dc.customer_sk
