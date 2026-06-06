-- Anti-trampa TCURX: montos JPY/CLP (0 decimales) NO deben tener parte decimal.
select currency, count(*) as bad_rows
from {{ ref('fact_transaction') }}
where currency in ('JPY','CLP')
  and amount <> trunc(amount)
group by currency
