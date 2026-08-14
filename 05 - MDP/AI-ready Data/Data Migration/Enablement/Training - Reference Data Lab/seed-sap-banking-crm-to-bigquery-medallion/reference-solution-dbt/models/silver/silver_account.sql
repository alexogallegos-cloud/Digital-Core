-- REGLA-04 filter_deleted, REGLA-06 FK validate/quarantine, REGLA-02 ALPHA
with src as (select * from {{ ref('bkk_acct') }}),
     party as (select party_id from {{ ref('silver_party') }})
select
  {{ alpha_strip('acct') }}     as account_id,
  {{ alpha_strip('partner') }}  as party_id,
  product, waers                as currency,
  {{ dats_to_date('open_date') }} as open_date,
  status
from src
where coalesce(loevm,'') <> 'X'
  and coalesce(partner,'') <> ''
  and {{ alpha_strip('partner') }} in (select party_id from party)
