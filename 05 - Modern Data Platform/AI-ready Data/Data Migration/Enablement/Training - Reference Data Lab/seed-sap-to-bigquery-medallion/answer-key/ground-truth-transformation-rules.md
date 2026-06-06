# Ground Truth - Transformation Rules

> Cada regla [REGLA] aplica entre bronze y silver salvo nota. El pipeline correcto
> debe implementarlas todas; el answer key mide el resultado.

| ID | Regla | Columnas | Logica |
|----|-------|----------|--------|
| REGLA-01 | DATS_to_DATE | KNA1.ERDAT, VBAK.ERDAT | 'YYYYMMDD'->DATE; '00000000' (y fuera de rango) -> NULL |
| REGLA-02 | ALPHA_strip | KUNNR, MATNR | quitar ceros a la izquierda para la clave de negocio; aplicar ANTES de cualquier join (resuelve leading_zero_inconsistency) |
| REGLA-03 | CURR_to_NUMERIC | NETWR + WAERK + TCURX | net_amount = CAST(NETWR AS NUMERIC) / POW(10, TCURX.CURRDEC[WAERK]); NUNCA asumir 2 decimales fijos |
| REGLA-04 | filter_deleted | KNA1.LOEKZ, MARA.LVORM | excluir filas con flag='X' en silver; conservarlas en bronze |
| REGLA-05 | dedup_key | VBAP (VBELN,POSNR) | deduplicar por clave; regla de supervivencia: keep-first determinista |
| REGLA-06 | canonical_language | MAKT.SPRAS | description = MAKT donde SPRAS='S'; ignorar otros idiomas (no duplicar material) |
| REGLA-07 | fk_validate_quarantine | VBAK.KUNNR, VBAP.VBELN, VBAP.MATNR | validar FK; filas que fallan van a _quarantine, no a la tabla limpia |
| REGLA-08 | completeness | VBAK.KUNNR, VBAP.NETWR | nulo en obligatorio -> cuarentena |
| REGLA-09 | range_check | VBAP.NETWR | outlier (magnitud absurda) -> alertar (DQ), NO eliminar |
