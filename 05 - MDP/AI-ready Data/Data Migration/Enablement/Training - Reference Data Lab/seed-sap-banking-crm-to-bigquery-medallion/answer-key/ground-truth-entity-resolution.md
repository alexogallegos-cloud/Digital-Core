# Ground Truth - Entity Resolution (crosswalk SAP <-> CRM)

> EL ARTEFACTO ESTRELLA de este seed. Como genere ambos sistemas desde un set de
> clientes reales, conozco el match verdadero. Un pipeline de migracion/MDM debe
> reconstruir este crosswalk; aqui se mide su precision/recall.

## Resumen por tipo de match
| match_type | # | Significado | Dificultad |
|------------|---|-------------|-----------|
| exact_ref | 116 | crm_account.sap_partner_ref poblado y correcto | trivial (join directo) |
| fuzzy_name | 94 | ref nulo; match por nombre normalizado + pais | media (normalizacion + fuzzy) |
| duplicate | 25 | 2a cuenta CRM del mismo cliente real | alta (MDM: merge a golden record) |
| crm_only | 40 | cuenta CRM sin contraparte SAP (prospecto) | identificar como no-cliente |
| sap_only | 90 | Business Partner SAP sin cuenta CRM | dim_customer sin enriquecimiento CRM |

## Regla de resolucion (la que el pipeline debe implementar)
1. Si `crm_account.sap_partner_ref` != null y existe en BUT000 -> match exacto.
2. Si no: normalizar nombre (sin acentos, mayusculas, sin puntuacion, colapsar espacios)
   y pais (ISO-2 via country_map); match por (name_key, country) contra BUT000.
3. Multiples cuentas CRM que resuelven al mismo PARTNER -> merge (1 golden record).
4. CRM sin match -> prospecto (no entra a dim_customer como cliente bancario).

## Crosswalk completo (muestra de las primeras 25 filas; el resto en este archivo)
| crm_id | match_type | sap_partner | match_key | crm_name | sap_name |
|--------|-----------|-------------|-----------|----------|----------|
| CRM-000001 | exact_ref | 0001000204 | CORPORATIVO REGIO SAPI DE CV | Corporativo Regio SAPI de CV | Corporativo Regio SAPI de CV |
| CRM-000002 | fuzzy_name | 0001000278 | DISTRIBUIDORA CONTINENTAL SA | Distribuidora Continental SA | Distribuidora Continental SA |
| CRM-000003 | exact_ref | 0001000230 | MARIA RIVERA FLORES | MARIA RIVERA FLORES | Maria Rivera Flores |
| CRM-000004 | fuzzy_name | 0001000096 | CORPORATIVO DEL GOLFO S A | Corporativo del Golfo S.A. | Corporativo del Golfo S.A. |
| CRM-000005 | exact_ref | 0001000123 | CORPORATIVO DEL GOLFO SA DE  | CORPORATIVO DEL GOLFO SA DE  | Corporativo del Golfo |
| CRM-000006 | fuzzy_name | 0001000124 | SERVICIOS PENINSULAR S A DE  | Servicios Peninsular S.A. de | Servicios Peninsular |
| CRM-000007 | exact_ref | 0001000293 | ANA RIVERA SANCHEZ | Ana Rivera Sanchez | Ana Rivera Sanchez |
| CRM-000008 | fuzzy_name | 0001000036 | ROSA SANCHEZ GARCIA | Rosa Sanchez Garcia | Rosa Sanchez Garcia |
| CRM-000009 | fuzzy_name | 0001000144 | GRUPO DEL PACIFICO SAPI DE C | GRUPO DEL PACIFICO SAPI DE C | Grupo del Pacifico S.A. |
| CRM-000010 | fuzzy_name | 0001000088 | LUIS TORRES RODRIGUEZ | Luis Torres Rodriguez | Luis Torres Rodriguez |
| CRM-000011 | exact_ref | 0001000189 | JOSE PEREZ LOPEZ | JOSE PEREZ LOPEZ | Jose Perez Lopez |
| CRM-000012 | fuzzy_name | 0001000007 | JUAN LOPEZ HERNANDEZ | Juan Lopez Hernandez | Juan Lopez Hernandez |
| CRM-000013 | exact_ref | 0001000138 | CORPORATIVO DEL PACIFICO S A | Corporativo del Pacifico S.A | Corporativo del Pacifico |
| CRM-000014 | exact_ref | 0001000244 | COMERCIAL DEL BAJIO SA DE CV | Comercial del Bajio SA de CV | Comercial del Bajio S.A. de  |
| CRM-000015 | exact_ref | 0001000150 | LUIS FLORES GONZALEZ | Luis Flores Gonzalez | Luis Flores Gonzalez |
| CRM-000016 | fuzzy_name | 0001000053 | CONSTRUCTORA CENTRAL SAPI DE | CONSTRUCTORA CENTRAL SAPI DE | Constructora Central S.A. de |
| CRM-000017 | exact_ref | 0001000095 | JUAN LOPEZ PEREZ | Juan Lopez Perez | Juan Lopez Perez |
| CRM-000018 | exact_ref | 0001000082 | CORPORATIVO DEL GOLFO | Corporativo del Golfo | Corporativo del Golfo SA de  |
| CRM-000019 | exact_ref | 0001000270 | SERVICIOS DEL GOLFO | Servicios del Golfo | Servicios del Golfo SA |
| CRM-000020 | fuzzy_name | 0001000118 | GRUPO PENINSULAR S A DE C V | Grupo Peninsular S.A. de C.V | Grupo Peninsular SA de CV |
| CRM-000021 | fuzzy_name | 0001000254 | GRUPO DEL BAJIO SA DE CV | Grupo del Bajio SA de CV | Grupo del Bajio S.A. de C.V. |
| CRM-000022 | fuzzy_name | 0001000249 | MIGUEL TORRES RAMIREZ | Miguel Torres Ramirez | Miguel Torres Ramirez |
| CRM-000023 | exact_ref | 0001000005 | INDUSTRIAS DEL PACIFICO SAPI | Industrias del Pacifico SAPI | Industrias del Pacifico |
| CRM-000024 | fuzzy_name | 0001000103 | TRANSPORTES CONTINENTAL SA | TRANSPORTES CONTINENTAL SA | Transportes Continental S.A. |
| CRM-000025 | fuzzy_name | 0001000025 | FRANCISCO RODRIGUEZ RAMIREZ | Francisco Rodriguez Ramirez | Francisco Rodriguez Ramirez |

> Total filas crosswalk: 365 (incluye sap_only sin crm_id).
