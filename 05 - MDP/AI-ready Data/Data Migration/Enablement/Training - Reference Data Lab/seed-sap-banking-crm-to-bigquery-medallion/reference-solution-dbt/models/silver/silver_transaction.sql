-- REGLA-05 dedup, REGLA-06 FK (resuelve leading-zero via ALPHA), REGLA-03 CURR/TCURX, completeness
with src as (
  select *, row_number() over (partition by acct, item_no order by amount) as _rn
  from {{ ref('bkkit') }}
),
dedup as (select * from src where _rn = 1),
acct as (select account_id from {{ ref('silver_account') }}),
tc as (select currkey, safe_cast(currdec as int64) as currdec from {{ ref('tcurx') }})
select
  {{ alpha_strip('d.acct') }}                                       as account_id,
  d.item_no,
  {{ dats_to_date('d.post_date') }}                                 as post_date,
  {{ dats_to_date('d.valut') }}                                     as value_date,
  safe_cast(d.amount as numeric) / pow(10, coalesce(tc.currdec, 2)) as amount,
  d.waers                                                           as currency,
  d.dc_ind                                                          as dc_indicator,
  d.text                                                            as memo
from dedup d
join acct a on {{ alpha_strip('d.acct') }} = a.account_id
left join tc on d.waers = tc.currkey
where coalesce(d.amount,'') <> ''
