-- REGLA-01 DATS->DATE, REGLA-02 ALPHA_strip, REGLA-04 filter_deleted
with src as (select * from {{ ref('but000') }})
select
  {{ alpha_strip('partner') }}                                   as party_id,
  type                                                           as party_type,
  case when type = '2' then name_org1
       else trim(concat(coalesce(name_first,''),' ',coalesce(name_last,''))) end as name,
  land1                                                          as country,
  {{ dats_to_date('crdat') }}                                    as created_date
from src
where coalesce(xdele,'') <> 'X'
  and coalesce(partner,'') <> ''
