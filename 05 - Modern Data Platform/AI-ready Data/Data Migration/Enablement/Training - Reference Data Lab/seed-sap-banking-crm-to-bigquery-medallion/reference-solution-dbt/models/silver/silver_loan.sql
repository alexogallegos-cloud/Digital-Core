-- REGLA-06 FK partner, REGLA-03 CURR/TCURX, REGLA-01 DATS
with src as (select * from {{ ref('vdarl') }}),
     party as (select party_id from {{ ref('silver_party') }}),
     tc as (select currkey, safe_cast(currdec as int64) as currdec from {{ ref('tcurx') }})
select
  {{ alpha_strip('darlehen') }}                                     as loan_id,
  {{ alpha_strip('partner') }}                                      as party_id,
  safe_cast(s.principal as numeric) / pow(10, coalesce(tc.currdec, 2)) as principal,
  s.waers                                                           as currency,
  safe_cast(s.rate as numeric)                                      as rate,
  {{ dats_to_date('s.start_date') }}                                as start_date,
  safe_cast(s.term_months as int64)                                 as term_months
from src s
left join tc on s.waers = tc.currkey
where {{ alpha_strip('partner') }} in (select party_id from party)
