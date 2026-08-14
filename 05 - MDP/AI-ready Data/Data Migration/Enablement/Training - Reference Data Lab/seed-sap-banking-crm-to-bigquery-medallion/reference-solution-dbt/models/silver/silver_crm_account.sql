-- REGLA-07 country_map; tipado. Dedup/merge se hace en gold (mastering).
select
  id                                       as crm_id,
  account_name,
  {{ crm_country_iso('country') }}         as country,
  city, segment,
  nullif(sap_partner_ref,'')               as sap_partner_ref,
  lower(coalesce(is_active,'')) = 'true'   as is_active,
  safe_cast(created_at as timestamp)       as created_at,
  -- REGLA-08 email validity (DQ flag; el email vive en crm_contact)
  regexp_contains(coalesce(account_name,''), r'.+') as _row_ok
from {{ ref('crm_account') }}
