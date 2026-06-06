-- Macros que implementan las reglas de transformacion del answer key
-- (ver ../answer-key/ground-truth-transformation-rules.md). Dialecto: BigQuery.

{% macro dats_to_date(col) %}
  safe.parse_date('%Y%m%d', nullif(cast({{ col }} as string), '00000000'))
{% endmacro %}

{% macro alpha_strip(col) %}
  nullif(ltrim(cast({{ col }} as string), '0'), '')
{% endmacro %}

{# entity resolution: sin acentos, mayusculas, sin puntuacion, sin sufijos legales, espacios colapsados #}
{% macro norm_name(col) %}
  trim(regexp_replace(
    regexp_replace(
      regexp_replace(
        regexp_replace(upper(normalize(cast({{ col }} as string), NFD)), r'\pM', ''),
        r'[^A-Z0-9 ]', ' '),
      r'\b(SADECV|SAPI|SAB|SA|SC|RL|CV|DE|S|A|C|V)\b', ' '),
    r'\s+', ' '))
{% endmacro %}

{# pais CRM (inconsistente) -> ISO-2 #}
{% macro crm_country_iso(col) %}
  case trim(regexp_replace(upper(normalize(cast({{ col }} as string), NFD)), r'\pM', ''))
    when 'MX' then 'MX' when 'MEXICO' then 'MX' when 'MEX' then 'MX'
    when 'US' then 'US' when 'USA' then 'US' when 'ESTADOS UNIDOS' then 'US' when 'UNITED STATES' then 'US'
    when 'CL' then 'CL' when 'CHILE' then 'CL' when 'CHL' then 'CL'
    else trim(regexp_replace(upper(normalize(cast({{ col }} as string), NFD)), r'\pM', ''))
  end
{% endmacro %}
