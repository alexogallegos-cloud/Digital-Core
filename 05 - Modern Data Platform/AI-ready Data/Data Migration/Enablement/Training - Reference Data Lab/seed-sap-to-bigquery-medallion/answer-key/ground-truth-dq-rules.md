# Ground Truth - DQ Rules (conteos esperados)

> Conteos computados de los datos emitidos. Un pipeline correcto debe reproducirlos.

| DQ test | Dimension | Tabla | Filas que FALLAN (esperado) | Accion |
|---------|-----------|-------|------------------------------|--------|
| referential: VBAK.KUNNR in KNA1 | integridad | VBAK | 8 | cuarentena |
| completeness: VBAK.KUNNR not null | completeness | VBAK | 6 | cuarentena |
| referential: VBAP.VBELN in VBAK | integridad | VBAP | 12 | cuarentena |
| referential: VBAP.MATNR in MARA | integridad | VBAP | 10 | cuarentena |
| completeness: VBAP.NETWR not null | completeness | VBAP | 6 | cuarentena |
| uniqueness: (VBELN,POSNR) | unicidad | VBAP | 5 (duplicados removidos) | dedup |
| validity: ERDAT fecha valida | validez | KNA1+VBAK | 14 | DATS->NULL |
| validity: deletion flag | validez | KNA1+MARA | 25 | filtrar |
| validity: NETWR range | validez | VBAP | 4 | alertar (no eliminar) |
