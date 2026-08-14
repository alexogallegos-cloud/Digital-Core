-- REGLA-09 entity resolution: ref exacto, luego fuzzy por (norm_name, pais).
-- Reconstruye el crosswalk; comparar contra ../answer-key/crosswalk-truth.csv.
with crm as (select * from {{ ref('silver_crm_account') }}),
     party as (
       select party_id, {{ norm_name('name') }} as name_key, country
       from {{ ref('silver_party') }}
     ),
exact as (
  select c.crm_id, {{ alpha_strip('c.sap_partner_ref') }} as party_id, 'exact_ref' as match_type
  from crm c
  where c.sap_partner_ref is not null
    and {{ alpha_strip('c.sap_partner_ref') }} in (select party_id from party)
),
unmatched as (select * from crm where crm_id not in (select crm_id from exact)),
fuzzy as (
  select u.crm_id, p.party_id, 'fuzzy_name' as match_type
  from unmatched u
  join party p
    on {{ norm_name('u.account_name') }} = p.name_key
   and u.country = p.country
)
select * from exact
union all
select * from fuzzy
