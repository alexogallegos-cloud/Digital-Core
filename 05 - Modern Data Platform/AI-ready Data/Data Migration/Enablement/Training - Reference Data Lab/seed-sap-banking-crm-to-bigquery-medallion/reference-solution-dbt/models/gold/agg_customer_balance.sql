-- saldo neto por cliente y moneda (S=cargo, H=abono). Para reconciliacion de montos.
select
  customer_sk, currency,
  sum(case when dc_indicator = 'H' then amount else -amount end) as net_balance,
  count(*) as txn_count
from {{ ref('fact_transaction') }}
where customer_sk is not null
group by customer_sk, currency
