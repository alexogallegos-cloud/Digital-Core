# Program Registry S151 — Movimientos Contables GL

> **Fuente de verdad canónica** de los 75 programas COBOL P-prefix del sistema S151 (Movimientos Contables / GL) mapeados a identificadores BC-XX.
> BIAN es referencia, **BC-XX es la clave primaria**.
> Sustituye a `bian-mapping-s151-LEGACY.md` (archivado 2026-07-23).

---

## Inventario por tipo de artefacto S151

| Tipo | Cantidad | Descripción |
|------|----------|-------------|
| COBOL P-prefix | **75** | Programas de negocio — cubiertos en este registro |
| COBOL L-prefix | 4 | Librerías COBOL (L014, L020, L030, L040) |
| ALGOL L-prefix | 11 | Librerías ALGOL (L001, L002R2-R5, L006, L009-L012, L194) — BC-04 ACL Wave 0 |
| ALGOL P-prefix | 5 | Programas ALGOL (P000, P007, P012, P021, P810) |
| DASDL | 6 | Esquemas BD10, BD11, BD12, BD13, BD02ADSALDO, BD99CONTROL |
| WFL | 3 | Orquestadores: LINEA, LOTE, SPLUNK |
| **Total** | **104** | Archivos fuente en source/S151/ |

---

## Tabla principal — 75 programas COBOL P-prefix → BC-XX

| # | Programa | BC-ID | Capacidad (ES) | bian_ref | Rol funcional | Confianza |
|---|----------|-------|----------------|----------|---------------|-----------|
| 1 | P108 | BC-13 | Finance GL | 7.1.1 | GL Posting Engine — bitácora pre-posting | ALTA |
| 2 | P109 | BC-13 | Finance GL | 7.1.1 | GL Posting Engine — motor asientos definitivo | ALTA |
| 3 | P150 | BC-13 | Finance GL | 7.1.1 | Interface CITI-Banamex ALR/AHR/OCM | ALTA |
| 4 | P151 | BC-13 | Finance GL | 7.1.1 | Transformador IBM-Citibank (P151 remapea a S151) | ALTA |
| 5 | P112 | BC-11 | Reconciliación Financiera | 6.7.1 | Punteo CNBV B-0111B — conciliación saldos | ALTA |
| 6 | P178 | BC-11 | Reconciliación Financiera | 6.7.1 | Verificación saldos finales STABDSAL=3 | ALTA |
| 7 | P199 | BC-11 | Reconciliación Financiera | 6.7.1 | Migración cap B08TDMIGCAP → entries GL | ALTA |
| 8 | P130 | BC-19 | CFR Reporting Regulatorio | T.4.1 | Agrupador CFR Serie B CNBV | ALTA |
| 9 | P131 | BC-19 | CFR Reporting Regulatorio | T.4.1 | Traductor CFR → formato regulatorio | ALTA |
| 10 | P120 | BC-19 | CFR Reporting Regulatorio | T.4.1 | SAR Banxico SETID=BNMEX | ALTA |
| 11 | P610 | BC-18 | Control Batch y Extracción Regulatoria | T.3.4 | Dispatcher CFR — lanzador de P130/P131 | ALTA |
| 12 | P612 | BC-18 | Control Batch y Extracción Regulatoria | T.3.4 | WFL launcher — activa reportes batch | ALTA |
| 13 | P677 | BC-18 | Control Batch y Extracción Regulatoria | T.3.4 | Gate-keeper batch — controla ejecución | ALTA |
| 14 | P670 | BC-18 | Control Batch y Extracción Regulatoria | T.3.4 | Archivador GL — consolida MOVIMIENTOS finalizados | ALTA |
| 15 | P671 | BC-18 | Control Batch y Extracción Regulatoria | T.3.4 | Complemento archivado GL | ALTA |
| 16 | P138 | BC-18 | Control Batch y Extracción Regulatoria | T.3.4 | Posición global — P138 posición consolidada | ALTA |
| 17 | P312 | BC-09 | Ajustes GL | 6.7.1+6.7.2 | CARGA ajustes — alimenta ciclo CPE/Adj | ALTA |
| 18 | P330 | BC-09 | Ajustes GL | 6.7.1+6.7.2 | Cálculos ajuste — CALCULOS-PROD-ESP | ALTA |
| 19 | P360 | BC-09 | Ajustes GL | 6.7.1+6.7.2 | Dispersión ajuste — escribe B20/B21/B70/B72/B80 | ALTA |
| 20 | P050 | BC-03 | Holdings | 4.1.2 | Saldos Holdings — lee/escribe BD02ADSALDO | ALTA |
| 21 | P052 | BC-03 | Holdings | 4.1.2 | Pagos Interbancarios + SECORE + S274 | ALTA |
| 22 | P158 | BC-07 | Estado de Cuenta | 6.1.4 | MOVSXCONT — generador extractos P158 | ALTA |
| 23 | P103 | BC-14 | Scheduling | 8.1.1 | Cierre Diario — Calendar-Corporativo | ALTA |
| 24 | P602 | BC-14 | Scheduling | 8.1.1 | Scheduling batch — componente cierre | ALTA |
| 25 | P620 | BC-14 | Scheduling | 8.1.1 | Scheduling complementario cierre | ALTA |
| 26 | P606 | BC-15 | Operational Data Stores | 9.1.1 | ODS DMSII — escritura datastore | ALTA |
| 27 | P690 | BC-15 | Operational Data Stores | 9.1.1 | ODS complementario — vuelca BD99CONTROL | ALTA |
| 28 | P655 | BC-16 | Seguridad y Enmascaramiento | T.3.5 | Enmascaramiento PII — fail-open DEFECTO-PROD | ALTA |
| 29 | P680 | BC-12 | Orquestación Operativa | 6.7.2 | P680 vuelca S151BD99CONTROL (6 datasets) | ALTA |
| 30 | P630 | BC-02 | Tarjetas ATM/PoS | 2.2.6 | Liquidación Tarjetas — TARINTERCAM → cargos/abonos | ALTA |
| 31 | P010 | BC-01 | Teller Gateway | 2.1.1 | Gateway Online S151 — P010 en contexto GL | ALTA |
| 32 | P102 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 33 | P104 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 34 | P107 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 35 | P110 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 36 | P111 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 37 | P113 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 38 | P114 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 39 | P115 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 40 | P116 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 41 | P117 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 42 | P122 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 43 | P128 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 44 | P135 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 45 | P152 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 46 | P153 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | MEDIA |
| 47 | P001 | BC-06 | Pagos | 6.1.3 | Operaciones pago/cargos S151 | BAJA |
| 48 | P005 | BC-06 | Pagos | 6.1.3 | Operaciones pago/cargos S151 | BAJA |
| 49 | P011 | BC-06 | Pagos | 6.1.3 | Operaciones pago/cargos S151 | BAJA |
| 50 | P013 | BC-06 | Pagos | 6.1.3 | Operaciones pago/cargos S151 | BAJA |
| 51 | P014 | BC-06 | Pagos | 6.1.3 | Operaciones pago/cargos S151 | BAJA |
| 52 | P015 | BC-06 | Pagos | 6.1.3 | Operaciones pago/cargos S151 | BAJA |
| 53 | P016 | BC-06 | Pagos | 6.1.3 | Operaciones pago/cargos S151 | BAJA |
| 54 | P017 | BC-06 | Pagos | 6.1.3 | Operaciones pago/cargos S151 | BAJA |
| 55 | P020 | BC-06 | Pagos | 6.1.3 | Cargos y Abonos → S151REGISTRA CVE TIPO-PROC 33-37 | MEDIA |
| 56 | P025 | BC-08 | Intereses y Comisiones | 6.1.5 | Intereses S151 | BAJA |
| 57 | P030 | BC-08 | Intereses y Comisiones | 6.1.5 | Intereses S151 | BAJA |
| 58 | P053 | BC-08 | Intereses y Comisiones | 6.1.5 | Intereses S151 | BAJA |
| 59 | P054 | BC-08 | Intereses y Comisiones | 6.1.5 | Intereses S151 | BAJA |
| 60 | P055 | BC-08 | Intereses y Comisiones | 6.1.5 | Intereses S151 | BAJA |
| 61 | P071 | BC-10 | Compliance y Regulación | 6.5.2 | Compliance / regulación S151 | BAJA |
| 62 | P073 | BC-10 | Compliance y Regulación | 6.5.2 | Compliance / regulación S151 | BAJA |
| 63 | P090 | BC-10 | Compliance y Regulación | 6.5.2 | Compliance / regulación S151 | BAJA |
| 64 | P167 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 65 | P168 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 66 | P169 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 67 | P170 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 68 | P171 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 69 | P172 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 70 | P177 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 71 | P194 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 72 | P195 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 73 | P196 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 74 | P197 | BC-05 | Depósitos | 5.1.1 | Operaciones depósito S151 | BAJA |
| 75 | P600 | BC-18 | Control Batch y Extracción Regulatoria | T.3.4 | Control batch S151 | BAJA |

---

## Resumen por BC-XX

| BC-ID | Capacidad (ES) | # Programas | Confianza |
|-------|----------------|-------------|-----------|
| BC-01 | Teller Gateway | 1 | ALTA |
| BC-02 | Tarjetas ATM/PoS | 1 | ALTA |
| BC-03 | Holdings | 2 | ALTA |
| BC-05 | Depósitos | 28 | ALTA/MEDIA/BAJA |
| BC-06 | Pagos | 9 | MEDIA/BAJA |
| BC-07 | Estado de Cuenta | 1 | ALTA |
| BC-08 | Intereses y Comisiones | 5 | BAJA |
| BC-09 | Ajustes GL | 3 | ALTA |
| BC-10 | Compliance y Regulación | 3 | BAJA |
| BC-11 | Reconciliación Financiera | 3 | ALTA |
| BC-12 | Orquestación Operativa | 1 | ALTA |
| BC-13 | Finance GL | 4 | ALTA |
| BC-14 | Scheduling | 3 | ALTA |
| BC-15 | Operational Data Stores | 2 | ALTA |
| BC-16 | Seguridad y Enmascaramiento | 1 | ALTA |
| BC-18 | Control Batch y Extracción Regulatoria | 7 | ALTA/BAJA |
| BC-19 | CFR Reporting Regulatorio | 3 | ALTA |
| **Total** | | **75** | |

---

## Artefactos excluidos de este registro

| Tipo | Cantidad | Artefactos | BC-XX |
|------|----------|-----------|-------|
| COBOL L-libs | 4 | L014, L020, L030, L040 | — (infraestructura) |
| ALGOL L-libs | 11 | L001, L002R2-R5, L006, L009-L012, L194 | BC-04 gap (ACL técnico Wave 0) |
| ALGOL P-programs | 5 | P000, P007, P012, P021, P810 | — (ALGOL, no COBOL) |
| DASDL | 6 | BD10, BD11, BD12, BD13, BD02ADSALDO, BD99CONTROL | — (esquema DMSII) |
| WFL | 3 | LINEA, LOTE, SPLUNK | BC-20 (orquestación, cap-wfl) |

---

## Programas pendientes de revisión SME

Los 44 programas con confianza BAJA/MEDIA requieren validación de dominio S151:
P001, P005, P011-P017, P025, P030, P053-P055, P071, P073, P090, P167-P172, P177, P194-P197, P600 + los 15 de confianza MEDIA (P102, P104, P107, P110-P117, P122, P128, P135, P152, P153).

Proceso recomendado: scatter-gather ≤10 programas/agente, mismo patrón que S500.

---

> **Nota BC-04**: Las 11 librerías ALGOL L-prefix (especialmente L002R2-R5 = Anti-Corruption Layer S500→S151) son la capa técnica de integración entre los dos sistemas. No se asignan a BC-XX de negocio. Están catalogadas en `rules-s151-l002.md` y en el plan Wave 0 ENCAPSULATE de `kb-capa5-fronteras.md`.

---

*Creado: 2026-07-23 · Fase 1 DISCOVER Etapa 3 · Sustituye bian-mapping-s151-LEGACY.md · 75 COBOL P-prefix · 17 BC-XX · 31 ALTA · 16 MEDIA · 28 BAJA*
