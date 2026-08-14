# Ground Truth - Source Inventory

> Computado de los datos emitidos. seed=42. NO editar a mano.

| Tabla SAP | Descripcion | Clave primaria | # filas | Notas |
|-----------|-------------|----------------|---------|-------|
| KNA1 | Customer master | MANDT+KUNNR | 200 | 15 con LOEKZ='X' |
| MARA | Material master | MANDT+MATNR | 150 | 10 con LVORM='X' |
| MAKT | Material text (multi-idioma) | MANDT+MATNR+SPRAS | 257 | 107 filas idioma 'E' |
| TCURX | Decimales por moneda | CURRKEY | 5 | check table |
| VBAK | Sales order header | MANDT+VBELN | 1000 | total headers |
| VBAP | Sales order item | MANDT+VBELN+POSNR | 3550 | incluye duplicados y huerfanos plantados |

Total defectos plantados: **217** (ver `planted-defects.md`).
