select
  row_number() over (order by a.account_id) as account_sk,
  a.account_id, c.customer_sk, a.product, a.currency, a.open_date, a.status
from {{ ref('silver_account') }} a
left join {{ ref('dim_customer') }} c on a.party_id = c.party_id
