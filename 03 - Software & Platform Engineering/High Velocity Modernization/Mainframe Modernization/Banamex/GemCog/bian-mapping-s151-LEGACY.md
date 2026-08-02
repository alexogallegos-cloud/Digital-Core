# BIAN Mapping — Sistema S151 (Movimientos Contables GL)
> Mapeo de los 104 programas S151 a las 21 capacidades BIAN del portal GemCog  
> Generado: 2026-07-17 · Swarm: 3 agentes · Fuentes: rules-catalog, inventario-s151, kb-capa5-fronteras  
> QC 2026-07-20: P010→2.1.1 · P158→6.1.4 · P120→T.4.1 (Tabla Completa)  
> QC 2026-07-21: P150→6.7.1 · BD10/BD11 semántica corregida · tablas de dominio sincronizadas (swarm auditoría semántica bancaria) · tabla de cobertura actualizada post-reclasificaciones
> BIAN-002 2026-07-21: P021 reclasificado 9.1.1→6.7.2 · 9.1.1: 23→22 prog / 61,833→61,733 LOC · 6.7.2: 2→3 prog / 5,044→5,144 LOC · justificación: cap-orc.md documenta P021 con 5 reglas RN-S151-181..185 (control shutdown S500)
> Indexado: ✅ 2026-07-17 — Programa→Capacidad — fuente autoritativa de resolución de capacidad
> **Tipo-artefacto:** `Mapa`  
> **Capa-GemCog:** `3`  
> **Propósito:** Mapeo explícito de los 104 programas S151 a las 21 capacidades BIAN — base para el análisis de impacto de cambios en GL y movimientos contables.  
> **Relacionado-con:** capability-map · capability-model-taxonomy · bian-mapping-s500

---

## Resumen por Capacidad BIAN

| # | Capacidad BIAN | ID | Programas | LOC Total | % LOC | Conf. Prom. |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Finance GL | 7.1.1 | 53 | 219,664 | 49.4% | MEDIA |
| 2 | Operational Data Stores DMSII | 9.1.1 | 22 | 61,733 | 13.9% | ALTA |
| 3 | Financial Reconciliation | 6.7.1 | 7 | 42,957 | 9.7% | ALTA |
| 4 | Batch Control & Regulatory Extraction | T.3.4 | 8 | 38,978 | 8.8% | MEDIA |
| 5 | Teller | 2.1.1 | 1 | 18,943 | 4.3% | MEDIA |
| 6 | Holdings | 4.1.2 | 1 | 15,722 | 3.5% | MEDIA |
| 7 | Payments | 6.1.3 | 1 | 13,708 | 3.1% | MEDIA |
| 8 | Statements | 6.1.4 | 1 | 13,694 | 3.1% | ALTA |
| 9 | Scheduling WFL | 8.1.1 | 4 | 10,803 | 2.4% | ALTA |
| 10 | Operational Reconciliation | 6.7.2 | 3 | 5,144 | 1.2% | ALTA |
| 11 | CFR Regulatory Pipeline | T.4.1 | 3 | 3,646 | 0.8% | ALTA |

**Total: 104 programas · 444,992 LOC**

> ✅ **Resumen actualizado: QC 2026-07-21** — P010→2.1.1 · P158→6.1.4 · P120→T.4.1 · P150→6.7.1 aplicados en tabla de cobertura.

---

## Tabla Completa — 104 Programas

_Ordenado por LOC descendente._

| Programa | Tipo | LOC | Dominio | BIAN ID | Capacidad BIAN | Confianza | Rol Funcional |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **P109** | COBOL | 19,381 | CONTABILIDAD | 7.1.1 | Finance GL | ALTA | Programa de contabilidad GL del mayor bloque del sistema S151 — procesamiento de... |
| **L030** | COBOL | 19,253 | MOVIMIENTOS | 7.1.1 | Finance GL | ALTA | Librería COBOL maestra S151 (S151LIB030) — consulta y control del estado diario... |
| **P010** | COBOL | 18,943 | MOVIMIENTOS | 2.1.1 | Teller | MEDIA | Gateway online multi-sistema (PROGRAM-ID: LINEA) — dispatcher de ~30 bibliotecas... |
| **P151** | COBOL | 17,370 | CONTABILIDAD | 6.7.1 | Financial Reconciliation | ALTA | Transformador IBM-Citibank — genera archivos ALR (Account Ledger), AHR (Account... |
| **P050** | COBOL | 15,722 | MOVIMIENTOS | 4.1.2 | Holdings | MEDIA | Servidor de saldos concentrados (PROGRAM-ID: P050ADSALDOS) — 93 funciones COMS;... |
| **P108** | COBOL | 14,572 | CONTABILIDAD | 7.1.1 | Finance GL | ALTA | Motor de contabilización dual GL (GL Bitácora) — genera MOVCONTABLES (ALFA) y MO... |
| **P052** | COBOL | 13,708 | MOVIMIENTOS | 6.1.3 | Payments | MEDIA | Distribuidor multi-destino de movimientos (PROGRAM-ID: ACCIVAL) — enruta a Tesor... |
| **P158** | COBOL | 13,694 | CONTABILIDAD | 6.1.4 | Statements | ALTA | Generador de movimientos por contrato (MOVSXCONT) para estados de cuenta — alime... |
| **P130** | COBOL | 13,360 | CONTABILIDAD | T.4.1 | CFR Regulatory Pipeline | ALTA | Agrupador Contable CFR — agrupa movimientos del LOG151 por sistema/libro/moneda/... |
| **P053** | COBOL | 12,817 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesamiento de movimientos GL S151 — programa batch del dominio MOVIMIENTOS si... |
| **P150** | COBOL | 12,746 | CONTABILIDAD | 6.7.1 | Financial Reconciliation | ALTA | Interfaz CITI ALR/AHR/OCM (contraparte de P108) — BRANCH=484 hardcoded; escritur... |
| **P015** | COBOL | 12,003 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesador intraday de movimientos (ActMov) — activado por L002R3/R4/R5 via LEVA... |
| **P131** | COBOL | 11,833 | CONTABILIDAD | T.4.1 | CFR Regulatory Pipeline | ALTA | Traductor Contable CFR→CNBV (SETID='BNMEX' hardcoded) — recibe AGRUPADO de P130... |
| **P107** | COBOL | 9,759 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilidad GL S151 — BC-05 General Ledger (P100-P199); procesamien... |
| **L002R3** ⚠️ NO-TRANSPILABLE | ALGOL | 9,355 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Librería ALGOL multi-canal base (REGISTRAS) — gestiona 10 canales paralelos LOGS... |
| **P167** | COBOL | 7,860 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilidad GL S151 — BC-05 General Ledger (P100-P199); generación... |
| **P169** | COBOL | 7,852 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Fase final GL nocturna — ejecutada por L002R3 cuando FIN_S408 AND FIN_S500 AND F... |
| **LOTE** | WFL | 7,738 | CONTROL | 8.1.1 | Scheduling WFL | ALTA | Orquestador WFL del batch nocturno GL S151 — define secuencia de ejecución de to... |
| **L002R5** ⚠️ NO-TRANSPILABLE | ALGOL | 7,414 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Librería ALGOL enriquecida (REGISTRAS v5) — misma tabla de 10 FUNCIONes que R4;... |
| **L002R4** ⚠️ NO-TRANSPILABLE | ALGOL | 7,280 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Librería ALGOL con dispatch explícito (REGISTRAS v4) — CASE 10 funciones (1=CARG... |
| **L011** ⚠️ NO-TRANSPILABLE | ALGOL | 7,210 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Librería ALGOL de soporte runtime S151 — acceso a bases de datos DMSII; funcione... |
| **L012** ⚠️ NO-TRANSPILABLE | ALGOL | 7,142 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Librería ALGOL de soporte runtime S151 — funciones auxiliares de infraestructura... |
| **P115** | COBOL | 7,050 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilidad GL S151 — BC-05 General Ledger (P100-P199); procesamien... |
| **P135** | COBOL | 6,816 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilidad GL S151 — BC-05 General Ledger (P100-P199); procesamien... |
| **P030** | COBOL | 5,969 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Programa de procesamiento de movimientos GL S151 — BC-06 Procesamiento de Movimi... |
| **P014** | COBOL | 5,429 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Programa de procesamiento de movimientos GL S151 — BC-06 Procesamiento de Movimi... |
| **P178** | COBOL | 4,865 | CONTABILIDAD | 6.7.1 | Financial Reconciliation | ALTA | Verificador de saldos por sistema-producto-instrumento vs BD DMSII (B70SXPOSICIO... |
| **L002R2** ⚠️ NO-TRANSPILABLE | ALGOL | 4,507 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Librería ALGOL runtime S151 — versión base del conjunto L002Rx; acceso DMSII; fo... |
| **P055** | COBOL | 4,235 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Programa de procesamiento de movimientos GL S151 — BC-06 Procesamiento de Movimi... |
| **P177** | COBOL | 4,197 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilidad GL S151 — BC-05 General Ledger (P100-P199); probable fu... |
| **P810** ⚠️ NO-TRANSPILABLE | ALGOL | 4,113 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Programa utilitario ALGOL de control S151 — funciones de administración de datos... |
| **L040** | COBOL | 4,110 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Librería COBOL de movimientos S151 — funciones de soporte para el procesamiento... |
| **P054** | COBOL | 4,098 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Programa de procesamiento de movimientos GL S151 — BC-06 Procesamiento de Movimi... |
| **P110** | COBOL | 3,798 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilidad GL S151 — BC-05 General Ledger (P100-P199); procesamien... |
| **P005** | COBOL | 3,641 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Programa de procesamiento de movimientos GL S151 — BC-06 Procesamiento de Movimi... |
| **P013** | COBOL | 3,626 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesamiento batch de movimientos del GL S151 — dominio MOVIMIENTOS, mayor LOC... |
| **P001** | COBOL | 3,585 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Programa de movimientos GL de ejecución al cierre del ciclo WFL LOTE — posting f... |
| **P117** | COBOL | 3,394 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL post-punteo — clúster P113-P117 del ciclo nocturn... |
| **P104** | COBOL | 3,345 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL de inicialización de ciclo — ejecuta antes del mo... |
| **P112** | COBOL | 3,326 | CONTABILIDAD | 6.7.1 | Financial Reconciliation | ALTA | PUNTEO POR CLAVES DE TRANSACCION — reconciliación S500↔S151 por dimensión LIBRO+... |
| **P172** | COBOL | 3,283 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL tardío — clúster P169-P172 post-consolidación de... |
| **L009** | ALGOL | 3,276 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Librería ALGOL de runtime de acceso a datasets DMSII — capa de infraestructura d... |
| **P116** | COBOL | 3,244 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL post-punteo — clúster P113-P117 |
| **P197** | COBOL | 3,195 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL tardío — clúster P194-P197 con parche CRONOS2K de... |
| **P025** | COBOL | 3,142 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesamiento batch de movimientos del GL S151 — dominio MOVIMIENTOS mid-range L... |
| **L001** | ALGOL | 3,126 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | LIBCONTROL — librería de control central de S151; gestiona acceso a BD99CONTROL,... |
| **P016** | COBOL | 2,801 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesamiento batch de movimientos del GL S151 — dominio MOVIMIENTOS |
| **P199** | COBOL | 2,752 | CONTABILIDAD | 6.7.1 | Financial Reconciliation | ALTA | CTASMIGCAP — puente de migración cross-system S500→S151; lee MOVS500 y persiste... |
| **L020** | COBOL | 2,712 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Módulo COBOL de soporte a procesamiento de movimientos GL — dominio MOVIMIENTOS |
| **P606** | COBOL | 2,674 | REPORTES | T.3.4 | Batch Control & Regulatory Extraction | ALTA | LEE-ARCHMOVYDES — lector de movimientos S151MOVANT+S151DESANT con filtrado multi... |
| **L014** | COBOL | 2,561 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Módulo COBOL de soporte a procesamiento de movimientos GL S151 — subprograma com... |
| **P360** | COBOL | 2,538 | AJUSTES | 6.7.2 | Operational Reconciliation | ALTA | Integración archivos planos → base DMSII de saldos destino — paso 2 del sub-pipe... |
| **P330** | COBOL | 2,506 | AJUSTES | 6.7.2 | Operational Reconciliation | ALTA | Extracción DMSII→archivos planos de 6 estructuras (B20/B21/B70/B71/B72/B80) — pa... |
| **P111** | COBOL | 2,374 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL post-punteo inmediato — ejecuta justo después de... |
| **P011** | COBOL | 2,356 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesamiento batch de movimientos del GL S151 — dominio MOVIMIENTOS |
| **P128** | COBOL | 2,346 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL — dominio CONTABILIDAD de S151 |
| **P122** | COBOL | 2,218 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL — ejecuta en la secuencia post-P120 (Proceso Conc... |
| **P152** | COBOL | 2,193 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL post-consolidación — clúster P152-P153, después d... |
| **P168** | COBOL | 2,171 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL tardío — adyacente al clúster P169-P172 del ciclo... |
| **P114** | COBOL | 2,153 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL post-punteo — clúster P113-P117 |
| **P020** | COBOL | 2,139 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesamiento batch de movimientos del GL S151 — dominio MOVIMIENTOS |
| **P113** | COBOL | 2,123 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL post-punteo — primero del clúster P113-P117 |
| **L006** | ALGOL | 2,029 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Librería ALGOL de runtime — capa de acceso a datos operativos DMSII del GL S151 |
| **P071** | COBOL | 2,022 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesamiento batch de movimientos del GL S151 — dominio MOVIMIENTOS |
| **P171** | COBOL | 1,960 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL tardío — clúster P169-P172 post-consolidación del... |
| **P017** | COBOL | 1,935 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesamiento batch de movimientos del GL S151 — dominio MOVIMIENTOS |
| **P073** | COBOL | 1,782 | MOVIMIENTOS | 7.1.1 | Finance GL | MEDIA | Procesamiento batch de movimientos del GL S151 — dominio MOVIMIENTOS |
| **P610** 🔴 CFR | COBOL | 1,767 | REPORTES | T.4.1 | CFR Regulatory Pipeline | ALTA | CALLLIBCTL dispatcher multi-función — incluye F09 que genera archivo TANDEM/ICA... |
| **P153** | COBOL | 1,572 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL post-consolidación — clúster P152-P153 |
| **P195** | COBOL | 1,561 | CONTABILIDAD | 7.1.1 | Finance GL | MEDIA | Programa de contabilización GL tardío — clúster P194-P197 con parche CRONOS2K de... |
| **LINEA** | WFL | 1,546 | CONTROL | 8.1.1 | Scheduling WFL | ALTA | Orquestador WFL del modo online S151. WFL en dominio CONTROL mapea directamente... |
| **P670** | COBOL | 1,487 | REPORTES | T.3.4 | Batch Control & Regulatory Extraction | MEDIA | Rules catalog (RN-S151-598..608) confirma que P670 archiva archivos MOVIMIENTOS... |
| **P170** | COBOL | 1,437 | CONTABILIDAD | 7.1.1 | Finance GL | ALTA | Dominio CONTABILIDAD, rango P100-P199 — BC-05 General Ledger. Programa COBOL de... |
| **P120** | COBOL | 1,317 | CONTABILIDAD | T.4.1 | CFR Regulatory Pipeline | ALTA | Extractor SAR Banxico — genera archivo de Sustentabilidad de Actividades de Riesgo... |
| **P138** | COBOL | 1,240 | CONTABILIDAD | 7.1.1 | Finance GL | ALTA | Dominio CONTABILIDAD, rango P100-P199 — BC-05 General Ledger. Programa COBOL de... |
| **P312** | COBOL | 1,211 | AJUSTES | 6.7.1 | Financial Reconciliation | ALTA | Dominio AJUSTES, rango P300-P399 — BC-09 Ajustes GL. Ajuste contable manual. Aju... |
| **S151BD10MOVDIA151** | DASDL | 1,203 | MOVIMIENTOS | 9.1.1 | Operational Data Stores DMSII | ALTA | Transaction Register DASDL — diario de movimientos (BxMOVTOS/MOVCONTABLES). NO es el GL: contiene las transacciones individuales. El GL real es BD11 (S151BD11SDOS151). |
| **P196** | COBOL | 1,136 | CONTABILIDAD | 7.1.1 | Finance GL | ALTA | Dominio CONTABILIDAD, rango P100-P199 — BC-05 General Ledger. Programa COBOL de... |
| **P677** | COBOL | 1,093 | REPORTES | T.3.4 | Batch Control & Regulatory Extraction | MEDIA | Dominio REPORTES, rango P600-P699 — BC-08 Reportería GL. Sin reglas en el catalo... |
| **P090** | COBOL | 1,077 | MOVIMIENTOS | 7.1.1 | Finance GL | ALTA | Dominio MOVIMIENTOS, rango P001-P099 — BC-06 Procesamiento de Movimientos. Movim... |
| **P600** | COBOL | 903 | REPORTES | T.3.4 | Batch Control & Regulatory Extraction | MEDIA | Dominio REPORTES, rango P600-P699 — BC-08 Reportería GL. Sin reglas en el catalo... |
| **P102** | COBOL | 856 | CONTABILIDAD | 7.1.1 | Finance GL | ALTA | Dominio CONTABILIDAD, rango P100-P199 — BC-05 General Ledger. Programa COBOL de... |
| **P194** | COBOL | 854 | CONTABILIDAD | 7.1.1 | Finance GL | ALTA | Dominio CONTABILIDAD, rango P100-P199 — BC-05 General Ledger. Programa COBOL de... |
| **P690** | COBOL | 824 | REPORTES | 7.1.1 | Finance GL | ALTA | Rules catalog (RN-S151-625..632) confirma: P690 ejecuta transición de estado FUN... |
| **P655** | COBOL | 770 | REPORTES | 8.1.1 | Scheduling WFL | MEDIA | Rules catalog (RN-S151-591..600) confirma: P655 es CALLLIBCTL — cambia ESTATUS e... |
| **P602** | COBOL | 749 | REPORTES | 8.1.1 | Scheduling WFL | MEDIA | Rules catalog (RN-S151-551..560) confirma: P602 es CALLLIBCTL — wrapper mínimo q... |
| **S151BD02ADSALDO** | DASDL | 716 | MOVIMIENTOS | 9.1.1 | Operational Data Stores DMSII | ALTA | Schema DASDL para saldos adicionales de movimientos (DMSII). Todos los DASDL son... |
| **S151BD13BIFIN** | DASDL | 715 | CONTABILIDAD | 9.1.1 | Operational Data Stores DMSII | ALTA | Schema DASDL de bifurcación financiera contable (DMSII). Todos los DASDL son def... |
| **P000** | ALGOL | 714 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Utilitario ALGOL de control. ALGOL en Unisys ClearPath MCP es el lenguaje nativo... |
| **P680** | COBOL | 687 | REPORTES | 6.7.1 | Financial Reconciliation | MEDIA | Rules catalog (RN-S151-617..624) confirma: P680 ejecuta volcado secuencial B01→B... |
| **S151BD12MC001S151** | DASDL | 640 | MOVIMIENTOS | 9.1.1 | Operational Data Stores DMSII | ALTA | Schema DASDL para movimientos S151 (MC001). Todos los DASDL son definiciones de... |
| **L010** | ALGOL | 573 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Utilitario ALGOL de control (prefijo L). ALGOL en Unisys ClearPath MCP es el len... |
| **P103** | COBOL | 562 | CONTABILIDAD | 7.1.1 | Finance GL | ALTA | Dominio CONTABILIDAD, rango P100-P199 — BC-05 General Ledger. Programa COBOL de... |
| **P671** 🔴 CFR | COBOL | 562 | REPORTES | T.4.1 | CFR Regulatory Pipeline | ALTA | Rules catalog (RN-S151-609..616) confirma regulación CNBV explícita: RN-609 clas... |
| **S151BD99CONTROL** | DASDL | 538 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Schema DASDL de control maestro S151 (B04SISTEM, B01SISDIA, etc.). Dataset de co... |
| **P630** | COBOL | 489 | REPORTES | 7.1.1 | Finance GL | MEDIA | Rules catalog (RN-S151-581..590) confirma: P630 consulta o actualiza la fecha de... |
| **S151BD11SDOS151** | DASDL | 333 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | GL Balance DASDL — libro mayor REAL de S151. Contiene B72POSCONTA con clave 10 dimensiones (KEYCTA+KEYCVEC+NATCTA+...) y estructura SDOANT/CARGOS/ABONOS/SDOACT. No confundir con BD10 (Transaction Register). |
| **P012** | ALGOL | 265 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Utilitario ALGOL de control. ALGOL en Unisys ClearPath MCP es el lenguaje nativo... |
| **P007** | ALGOL | 260 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Utilitario ALGOL de control. ALGOL en Unisys ClearPath MCP es el lenguaje nativo... |
| **P620** | COBOL | 210 | REPORTES | 9.1.1 | Operational Data Stores DMSII | ALTA | Rules catalog (RN-S151-571..580) confirma: P620 gestiona alta/baja de directorio... |
| **L194** | ALGOL | 114 | CONTROL | 9.1.1 | Operational Data Stores DMSII | ALTA | Utilitario ALGOL de control (prefijo L). ALGOL en Unisys ClearPath MCP es el len... |
| **P021** | ALGOL | 100 | CONTROL | 6.7.2 | Operational Reconciliation | ALTA | Orquestador de shutdown S500 — envía señales HI a pasos batch S500 (pasos 9, 12, 2) via DCKEYIN; 5 reglas RN-S151-181..185 en cap-orc.md · BIAN-002 corregido 2026-07-21 | |
| **SPLUNK** | WFL | 98 | CONTROL | T.3.4 | Batch Control & Regulatory Extraction | ALTA | WFL de envío de logs a Splunk (observabilidad operativa). Genera flujo de datos... |
| **P612** | COBOL | 86 | REPORTES | T.3.4 | Batch Control & Regulatory Extraction | MEDIA | Dominio REPORTES, rango P600-P699 — BC-08 Reportería GL. Programa muy pequeño (8... |

---

## Análisis por Dominio S151

### CONTABILIDAD (40 programas · 206,480 LOC)

Programas del libro mayor contable — asientos GL, cuadratura CNBV, interfaz CITI (BC-05 General Ledger P100-P199)

| Programa | Tipo | LOC | BIAN ID | Capacidad | Confianza |
| --- | --- | --- | --- | --- | --- |
| P109 | COBOL | 19,381 | 7.1.1 | Finance GL | ALTA |
| P151 | COBOL | 17,370 | 6.7.1 | Financial Reconciliation | ALTA |
| P108 | COBOL | 14,572 | 7.1.1 | Finance GL | ALTA |
| P158 | COBOL | 13,694 | 6.1.4 | Statements | ALTA |
| P130 | COBOL | 13,360 | T.4.1 | CFR Regulatory Pipeline | ALTA |
| P150 | COBOL | 12,746 | 6.7.1 | Financial Reconciliation | ALTA |
| P131 | COBOL | 11,833 | T.4.1 | CFR Regulatory Pipeline | ALTA |
| P107 | COBOL | 9,759 | 7.1.1 | Finance GL | MEDIA |
| P167 | COBOL | 7,860 | 7.1.1 | Finance GL | MEDIA |
| P169 | COBOL | 7,852 | 7.1.1 | Finance GL | MEDIA |
| P115 | COBOL | 7,050 | 7.1.1 | Finance GL | MEDIA |
| P135 | COBOL | 6,816 | 7.1.1 | Finance GL | MEDIA |
| P178 | COBOL | 4,865 | 6.7.1 | Financial Reconciliation | ALTA |
| P177 | COBOL | 4,197 | 7.1.1 | Finance GL | MEDIA |
| P110 | COBOL | 3,798 | 7.1.1 | Finance GL | MEDIA |
| P117 | COBOL | 3,394 | 7.1.1 | Finance GL | MEDIA |
| P104 | COBOL | 3,345 | 7.1.1 | Finance GL | MEDIA |
| P112 | COBOL | 3,326 | 6.7.1 | Financial Reconciliation | ALTA |
| P172 | COBOL | 3,283 | 7.1.1 | Finance GL | MEDIA |
| P116 | COBOL | 3,244 | 7.1.1 | Finance GL | MEDIA |
| P197 | COBOL | 3,195 | 7.1.1 | Finance GL | MEDIA |
| P199 | COBOL | 2,752 | 6.7.1 | Financial Reconciliation | ALTA |
| P111 | COBOL | 2,374 | 7.1.1 | Finance GL | MEDIA |
| P128 | COBOL | 2,346 | 7.1.1 | Finance GL | MEDIA |
| P122 | COBOL | 2,218 | 7.1.1 | Finance GL | MEDIA |
| P152 | COBOL | 2,193 | 7.1.1 | Finance GL | MEDIA |
| P168 | COBOL | 2,171 | 7.1.1 | Finance GL | MEDIA |
| P114 | COBOL | 2,153 | 7.1.1 | Finance GL | MEDIA |
| P113 | COBOL | 2,123 | 7.1.1 | Finance GL | MEDIA |
| P171 | COBOL | 1,960 | 7.1.1 | Finance GL | MEDIA |
| P153 | COBOL | 1,572 | 7.1.1 | Finance GL | MEDIA |
| P195 | COBOL | 1,561 | 7.1.1 | Finance GL | MEDIA |
| P170 | COBOL | 1,437 | 7.1.1 | Finance GL | ALTA |
| P120 | COBOL | 1,317 | T.4.1 | CFR Regulatory Pipeline | ALTA |
| P138 | COBOL | 1,240 | 7.1.1 | Finance GL | ALTA |
| P196 | COBOL | 1,136 | 7.1.1 | Finance GL | ALTA |
| P102 | COBOL | 856 | 7.1.1 | Finance GL | ALTA |
| P194 | COBOL | 854 | 7.1.1 | Finance GL | ALTA |
| S151BD13BIFIN | DASDL | 715 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| P103 | COBOL | 562 | 7.1.1 | Finance GL | ALTA |

### MOVIMIENTOS (27 programas · 152,225 LOC)

Programas de procesamiento de movimientos contables — pipeline S500→GL, distribución multi-destino (BC-06 P001-P099)

| Programa | Tipo | LOC | BIAN ID | Capacidad | Confianza |
| --- | --- | --- | --- | --- | --- |
| L030 | COBOL | 19,253 | 7.1.1 | Finance GL | ALTA |
| P010 | COBOL | 18,943 | 2.1.1 | Teller | MEDIA |
| P050 | COBOL | 15,722 | 4.1.2 | Holdings | MEDIA |
| P052 | COBOL | 13,708 | 6.1.3 | Payments | MEDIA |
| P053 | COBOL | 12,817 | 7.1.1 | Finance GL | MEDIA |
| P015 | COBOL | 12,003 | 7.1.1 | Finance GL | MEDIA |
| P030 | COBOL | 5,969 | 7.1.1 | Finance GL | MEDIA |
| P014 | COBOL | 5,429 | 7.1.1 | Finance GL | MEDIA |
| P055 | COBOL | 4,235 | 7.1.1 | Finance GL | MEDIA |
| L040 | COBOL | 4,110 | 7.1.1 | Finance GL | MEDIA |
| P054 | COBOL | 4,098 | 7.1.1 | Finance GL | MEDIA |
| P005 | COBOL | 3,641 | 7.1.1 | Finance GL | MEDIA |
| P013 | COBOL | 3,626 | 7.1.1 | Finance GL | MEDIA |
| P001 | COBOL | 3,585 | 7.1.1 | Finance GL | MEDIA |
| P025 | COBOL | 3,142 | 7.1.1 | Finance GL | MEDIA |
| P016 | COBOL | 2,801 | 7.1.1 | Finance GL | MEDIA |
| L020 | COBOL | 2,712 | 7.1.1 | Finance GL | MEDIA |
| L014 | COBOL | 2,561 | 7.1.1 | Finance GL | MEDIA |
| P011 | COBOL | 2,356 | 7.1.1 | Finance GL | MEDIA |
| P020 | COBOL | 2,139 | 7.1.1 | Finance GL | MEDIA |
| P071 | COBOL | 2,022 | 7.1.1 | Finance GL | MEDIA |
| P017 | COBOL | 1,935 | 7.1.1 | Finance GL | MEDIA |
| P073 | COBOL | 1,782 | 7.1.1 | Finance GL | MEDIA |
| S151BD10MOVDIA151 | DASDL | 1,203 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| P090 | COBOL | 1,077 | 7.1.1 | Finance GL | ALTA |
| S151BD02ADSALDO | DASDL | 716 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| S151BD12MC001S151 | DASDL | 640 | 9.1.1 | Operational Data Stores DMSII | ALTA |

### CONTROL (21 programas · 67,731 LOC)

Librerías de runtime, utilitarios ALGOL, DASDL schemas, orquestadores — infraestructura cross-cutting del sistema

| Programa | Tipo | LOC | BIAN ID | Capacidad | Confianza |
| --- | --- | --- | --- | --- | --- |
| L002R3 ⚠️ | ALGOL | 9,355 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| LOTE | WFL | 7,738 | 8.1.1 | Scheduling WFL | ALTA |
| L002R5 ⚠️ | ALGOL | 7,414 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| L002R4 ⚠️ | ALGOL | 7,280 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| L011 ⚠️ | ALGOL | 7,210 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| L012 ⚠️ | ALGOL | 7,142 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| L002R2 ⚠️ | ALGOL | 4,507 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| P810 ⚠️ | ALGOL | 4,113 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| L009 | ALGOL | 3,276 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| L001 | ALGOL | 3,126 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| L006 | ALGOL | 2,029 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| LINEA | WFL | 1,546 | 8.1.1 | Scheduling WFL | ALTA |
| P000 | ALGOL | 714 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| L010 | ALGOL | 573 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| S151BD99CONTROL | DASDL | 538 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| S151BD11SDOS151 | DASDL | 333 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| P012 | ALGOL | 265 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| P007 | ALGOL | 260 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| L194 | ALGOL | 114 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| P021 | ALGOL | 100 | 6.7.2 | Operational Reconciliation | ALTA |
| SPLUNK | WFL | 98 | T.3.4 | Batch Control & Regulatory Extraction | ALTA |

### REPORTES (13 programas · 12,301 LOC)

Programas de reportería, análisis, CFR regulatorio — estados de cuenta, reportes Banxico/CNBV (BC-08 P600-P699)

| Programa | Tipo | LOC | BIAN ID | Capacidad | Confianza |
| --- | --- | --- | --- | --- | --- |
| P606 | COBOL | 2,674 | T.3.4 | Batch Control & Regulatory Extraction | ALTA |
| P610 🔴 | COBOL | 1,767 | T.4.1 | CFR Regulatory Pipeline | ALTA |
| P670 | COBOL | 1,487 | T.3.4 | Batch Control & Regulatory Extraction | MEDIA |
| P677 | COBOL | 1,093 | T.3.4 | Batch Control & Regulatory Extraction | MEDIA |
| P600 | COBOL | 903 | T.3.4 | Batch Control & Regulatory Extraction | MEDIA |
| P690 | COBOL | 824 | 7.1.1 | Finance GL | ALTA |
| P655 | COBOL | 770 | 8.1.1 | Scheduling WFL | MEDIA |
| P602 | COBOL | 749 | 8.1.1 | Scheduling WFL | MEDIA |
| P680 | COBOL | 687 | 6.7.1 | Financial Reconciliation | MEDIA |
| P671 🔴 | COBOL | 562 | T.4.1 | CFR Regulatory Pipeline | ALTA |
| P630 | COBOL | 489 | 7.1.1 | Finance GL | MEDIA |
| P620 | COBOL | 210 | 9.1.1 | Operational Data Stores DMSII | ALTA |
| P612 | COBOL | 86 | T.3.4 | Batch Control & Regulatory Extraction | MEDIA |

### AJUSTES (3 programas · 6,255 LOC)

Programas de ajustes operativos — extracción e integración de saldos entre bases DMSII (BC-09 Ajustes GL)

| Programa | Tipo | LOC | BIAN ID | Capacidad | Confianza |
| --- | --- | --- | --- | --- | --- |
| P360 | COBOL | 2,538 | 6.7.2 | Operational Reconciliation | ALTA |
| P330 | COBOL | 2,506 | 6.7.2 | Operational Reconciliation | ALTA |
| P312 | COBOL | 1,211 | 6.7.1 | Financial Reconciliation | ALTA |

---

## Programas de Alta Prioridad

### CFR Regulatorio (T.4.1 — Confirmado)

Estos programas generan archivos regulatorios con evidencia directa en código fuente.

| Programa | Tipo | LOC | Regulador | Descripción |
| --- | --- | --- | --- | --- |
| **P610** | COBOL | 1,767 | Banxico | CALLLIBCTL dispatcher multi-función — incluye F09 que genera archivo TANDEM/ICA para reporte regulatorio Banxico |
| **P671** | COBOL | 562 | CNBV | Rules catalog (RN-S151-609..616) confirma regulación CNBV explícita: RN-609 clasifica INTELAR (PROTECCOB / ALERTANOT / D |

### No Transpilables — Reescritura Obligatoria

Librerías y programas ALGOL Unisys ClearPath MCP. No existe transpiler ALGOL→Java/Python/Go.
Estrategia recomendada: RETAIN + evaluar ENCAPSULATE si es interfaz crítica.

| Programa | Tipo | LOC | BIAN ID | Capacidad | Rol |
| --- | --- | --- | --- | --- | --- |
| **L002R3** | ALGOL | 9,355 | 9.1.1 | Operational Data Stores DMSII | Librería ALGOL multi-canal base (REGISTRAS) — gestiona 10 canales paralelos LOGS[0:9]/DESS[0:9]/CBII |
| **L002R5** | ALGOL | 7,414 | 9.1.1 | Operational Data Stores DMSII | Librería ALGOL enriquecida (REGISTRAS v5) — misma tabla de 10 FUNCIONes que R4; lanzamiento directo  |
| **L002R4** | ALGOL | 7,280 | 9.1.1 | Operational Data Stores DMSII | Librería ALGOL con dispatch explícito (REGISTRAS v4) — CASE 10 funciones (1=CARGAMEMORY, 2=ELIMINA,  |
| **L011** | ALGOL | 7,210 | 9.1.1 | Operational Data Stores DMSII | Librería ALGOL de soporte runtime S151 — acceso a bases de datos DMSII; funciones auxiliares de infr |
| **L012** | ALGOL | 7,142 | 9.1.1 | Operational Data Stores DMSII | Librería ALGOL de soporte runtime S151 — funciones auxiliares de infraestructura y acceso DMSII; com |
| **L002R2** | ALGOL | 4,507 | 9.1.1 | Operational Data Stores DMSII | Librería ALGOL runtime S151 — versión base del conjunto L002Rx; acceso DMSII; forma parte del BC-04  |
| **P810** | ALGOL | 4,113 | 9.1.1 | Operational Data Stores DMSII | Programa utilitario ALGOL de control S151 — funciones de administración de datos DMSII; operaciones  |

**Total no transpilable: 7 programas · 47,021 LOC**

### Hallazgos Críticos de Clasificación

| Programa | BIAN | Capacidad | Hallazgo |
| --- | --- | --- | --- |
| **P010** | 2.1.1 | Teller | PROGRAM-ID: LINEA — dispatcher online de ~30 bibliotecas LIB-CONS{NNN}. NO motor GL. Reclasificado T.3.4 → 2.1.1 (QC 2026-07-20). |
| **P158** | 6.1.4 | Statements | Genera MOVSXCONT para estados de cuenta. Solo corre para sistemas {500,408,84,87,407,404,017}. No es posting GL. Reclasificado T.3.4 → 6.1.4 (QC 2026-07-20). |
| **P120** | T.4.1 | CFR Regulatory Pipeline | Extractor SAR regulatorio Banxico. NO es motor GL genérico. Reclasificado 7.1.1 → T.4.1 (QC 2026-07-20). |
| **P151** | 6.7.1 | Financial Reconciliation | Transformador IBM-Citibank ALR/AHR/OCM. Interfaz de conciliación con contraparte Citi vía WFL P940. |
| **P150** | 6.7.1 | Financial Reconciliation | Reclasificado 7.1.1 → 6.7.1 (QC 2026-07-21 · swarm semántico): P150 es Interfaz CITI (contraparte de P151) — BRANCH=484 hardcodeado en ≥5 campos. Clasificarlo como GL ordinario ocultaba el mayor riesgo de separación Citi. Tratar junto con P151 como bloque de desconexión Citi antes del cutover GL. |
| **P131** | T.4.1 | CFR Regulatory Pipeline | ALERTA: SETID='BNMEX' hardcodeado — crítico para separación Citi/Banamex. |
| **P178** | 6.7.1 | Financial Reconciliation | Verificación de saldos vs DMSII (B70SXPOSICION). Genera R01-REPMES + R02-REPPOS. |
| **P050** | 4.1.2 | Holdings | Servidor COMS 93 funciones — saldos concentrados. Gap: BIAN no tiene 'Balance Management'; Holdings es el más próximo. |
| **P655** | 8.1.1 | Scheduling WFL | CALLLIBCTL — cambia ESTATUS B04SISTEM (FUNCION=2/3). Clasificado REPORTES en inventario pero función real es control de ciclo. |
| **P602** | 8.1.1 | Scheduling WFL | CALLLIBCTL — mismo patrón que P655. Dominio REPORTES vs función real de control de ciclo batch. |
| **P620** | 9.1.1 | Operational Data Stores | Gestión de directorios infraestructura (USER.DIR.PACK.CSI.DIA). Parece reporte por dominio pero es DMSII. |
| **P680** | 6.7.1 | Financial Reconciliation | ÚNICO punto restauración BD control. BUG-PRODUCCION línea 537: SECERRHI copiado en SECINFHI (campo incorrecto). Riesgo equivalencia. |
| **P670** | T.3.4 | Analytics | Backup/archivo movimientos con CLOSE WITH SAVE — sin flags CNBV. No es CFR. |
| **P690** | 7.1.1 | Finance GL | Transición estado FUNCION=99→FUNCION=11 en GL. Sin flags CNBV. No es CFR. |
| **P671** | T.4.1 | CFR | Programa más reciente (dic-2024). INTELAR: PROTECCOB+ALERTANOT+DOMICILIA, CLABE 18 dígitos. Menor madurez en codebase. |

---

## Cobertura por Capacidad BIAN

El sistema S151 cubre **12 capacidades BIAN** de las 22 disponibles en el portal GemCog.
Las capacidades con programas S151 se marcan con ✅; las que solo tienen programas S500 con —.

| BIAN ID | Capacidad | S151 ✅ | S500 (ref) | Nota |
| --- | --- | --- | --- | --- |
| 2.1.1 | Teller | **1 prog** (P010) | ✅ | Gateway online multi-sistema — reclasificado T.3.4→2.1.1 QC 2026-07-20 |
| 2.2.6 | ATM | — | ✅ (S500) | — |
| 2.2.7 | Card Management | — | ✅ (S500) | — |
| 4.1.2 | Holdings | **1 prog** | ✅ | Saldos concentrados P050 (gap Balance Mgmt) |
| 5.1.1 | Deposits | — | ✅ (S500) | — |
| 6.1.3 | Payments | **1 prog** | ✅ | Distribución multi-destino P052/ACCIVAL |
| 6.1.4 | Statements | **1 prog** (P158) | ✅ | Generador MOVSXCONT estados de cuenta — reclasificado T.3.4→6.1.4 QC 2026-07-20 |
| 6.1.5 | Interest & Fees | — | ✅ (S500) | — |
| 6.5.2 | Compliance & Regulation | — | ✅ (S500) | — |
| 6.6.1 | Financial Servicing | — | ✅ (S500) | — |
| 6.7.1 | Financial Reconciliation | **7 prog** | ✅ | Reconciliación financiera S500↔S151 (+P150 QC 2026-07-21) |
| 6.7.2 | Operational Reconciliation | **3 prog** | ✅ | Ajustes operativos BC-09 · P330/P360 pipeline + P021 shutdown S500 (BIAN-002 2026-07-21) |
| 7.1.1 | Finance GL | **53 prog** | — | Núcleo S151 — 53 programas GL |
| 8.1.1 | Scheduling WFL | **4 prog** | ✅ | Orquestación WFL + control ciclo |
| 9.1.1 | Operational Data Stores DMSII | **22 prog** | ✅ | Infraestructura DMSII — ALGOL + DASDL (P021 movido a 6.7.2 · BIAN-002 2026-07-21) |
| 10.1.1 | Access Control | — | ✅ (S500) | — |
| T.1.3 | Payment Schemes SPEI/CLABE | — | ✅ (S500) | — |
| T.2.3 | MQ Async L091-L093 | — | ✅ (S500) | — |
| T.3.4 | Batch Control & Regulatory Extraction | **8 prog** | ✅ | Reportes analíticos + estados de cuenta |
| T.3.5 | Security | — | ✅ (S500) | — |
| T.4.1 | CFR Regulatory Pipeline | **3 prog** | — | CFR Banxico (P610) + CNBV (P671) + SAR Banxico (P120) |
| T.5.1 | Batch Orchestration / WFL Orchestrator | **2 prog** | ✅ | Orquestación WFL batch S151 — LOTE (batch nocturno) + LINEA (online); 7 reglas totales (5 S500 · 2 S151) · TRZ-006 2026-07-21 |

---

## Estadísticas Globales

| Métrica | Valor |
| --- | --- |
| Total programas | **104** |
| Capacidades BIAN cubiertas | **12** |
| LOC total sistema S151 | **444,992** |
| Confianza ALTA | 52 (50%) |
| Confianza MEDIA | 52 (50%) |
| Confianza BAJA | 0 (0%) |
| Programas no transpilables (ALGOL) | 7 (47,021 LOC) |
| Programas CFR regulatorios confirmados | 3 (T.4.1) |
| Capacidad dominante | 7.1.1 Finance GL (53 prog · 219,664 LOC) |

### LOC por Capacidad BIAN (ranking)

| # | BIAN ID | Capacidad | LOC Total | % del total |
| --- | --- | --- | --- | --- |
| 1 | 7.1.1 | Finance GL | 219,664 | 49.4% |
| 2 | 9.1.1 | Operational Data Stores DMSII | 61,733 | 13.9% |
| 3 | 6.7.1 | Financial Reconciliation | 42,957 | 9.7% |
| 4 | T.3.4 | Batch Control & Regulatory Extraction | 38,978 | 8.8% |
| 5 | 2.1.1 | Teller | 18,943 | 4.3% |
| 6 | 4.1.2 | Holdings | 15,722 | 3.5% |
| 7 | 6.1.3 | Payments | 13,708 | 3.1% |
| 8 | 6.1.4 | Statements | 13,694 | 3.1% |
| 9 | 8.1.1 | Scheduling WFL | 10,803 | 2.4% |
| 10 | 6.7.2 | Operational Reconciliation | 5,144 | 1.2% |
| 11 | T.4.1 | CFR Regulatory Pipeline | 3,646 | 0.8% |
