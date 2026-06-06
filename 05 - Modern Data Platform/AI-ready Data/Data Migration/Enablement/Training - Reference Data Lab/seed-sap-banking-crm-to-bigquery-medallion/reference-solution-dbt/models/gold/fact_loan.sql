select
  l.loan_id, c.customer_sk, l.principal, l.currency, l.rate, l.start_date, l.term_months
from {{ ref('silver_loan') }} l
left join {{ ref('dim_customer') }} c on l.party_id = c.party_id
