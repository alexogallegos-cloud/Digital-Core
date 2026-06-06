-- Customer 360 mastereado: SAP = system of record; CRM enriquece via entity resolution.
-- REGLA-10 master_merge: multiples cuentas CRM del mismo party -> 1 golden record.
with party as (select * from {{ ref('silver_party') }}),
er as (
  select party_id,
         array_agg(distinct crm_id) as crm_account_ids,
         count(distinct crm_id)     as crm_n
  from {{ ref('int_entity_resolution') }}
  group by party_id
),
seg as (
  select party_id, segment from (
    select e.party_id, c.segment,
           row_number() over (partition by e.party_id order by c.crm_id) as rn
    from {{ ref('int_entity_resolution') }} e
    join {{ ref('silver_crm_account') }} c using (crm_id)
  ) where rn = 1
)
select
  row_number() over (order by p.party_id)             as customer_sk,
  p.party_id, p.name, p.party_type, p.country,
  seg.segment,
  er.party_id is not null                             as crm_matched,
  coalesce(er.crm_account_ids, [])                    as crm_account_ids,
  if(er.party_id is not null, 'SAP+CRM', 'SAP-only')  as golden_record_source
from party p
left join er  on p.party_id = er.party_id
left join seg on p.party_id = seg.party_id
