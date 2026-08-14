-- Reconciliacion: dim_customer = 1 golden record por party (= silver_party).
select 'dim_customer_count_mismatch' as failure
from (select count(*) as c from {{ ref('dim_customer') }}) a
cross join (select count(*) as c from {{ ref('silver_party') }}) b
where a.c <> b.c
