# MANIFEST — Banamex GemCog · MDs Canónicos Indexados (AS-IS)
> Gemelo Cognitivo del Sistema · S500 + S151 · Unisys ClearPath MCP
> Última actualización: 2026-07-24 · v2.10 · **Índice AS-IS puro** — artefactos TO-BE (Fase 2+) movidos a to-be-backlog.md
> Este archivo es la fuente de verdad de qué MDs AS-IS son canónicos y están indexados.

---

## Índices transversales

| Archivo | Descripción |
|---------|-------------|
| [capability-map.md](capability-map.md) | Índice navegable de capacidades con estado de cobertura S500+S151 · 23 capacidades BC-XX cubiertas dentro del universo BIAN v12 de referencia · punto de entrada para gap-analysis |
| [capability-model-taxonomy.md](capability-model-taxonomy.md) | Taxonomía canónica del modelo BC-XX (BC-01..BC-23) — jerarquía de 5 niveles Dominio→Subdominio→Capacidad→Proceso→Reglas · BIAN v12 como campo de referencia, BC-XX como clave primaria · fuente de verdad de la normalización regla→capacidad |
| [task-process-rules-index.md](task-process-rules-index.md) | Índice transversal Tarea→Proceso→Regla · 527T · 783R enlazadas a tareas (subconjunto del catálogo total de 1,513) |
| [rules-catalog/rules-index.md](rules-catalog/rules-index.md) | Catálogo de reglas · índice maestro de los 33 archivos |
| [traceability-matrix.md](traceability-matrix.md) | Matriz de trazabilidad Reglas↔Capacidades↔Vocabulario · 1,513 reglas únicas · 23 capacidades · build-traceability.py |
| [vocab-rules-xref.md](vocab-rules-xref.md) | Cross-reference Vocabulario→Reglas · Capa 1↔Capa 2 · build-traceability.py |
| [program-registry-s500.md](program-registry-s500.md) | Registro canónico S500 · 77 programas COBOL P-prefix → BC-XX · 14 capacidades · BIAN es referencia, BC-XX es clave primaria |
| [program-registry-s151.md](program-registry-s151.md) | Registro canónico S151 · 75 programas COBOL P-prefix → BC-XX · 17 capacidades · BIAN es referencia, BC-XX es clave primaria |
| [kb-capa3-capacidades.md](kb-capa3-capacidades.md) | Knowledge base Capa 3 — resumen ejecutivo de capacidades |
| [kb-capa4-flujos.md](kb-capa4-flujos.md) | Knowledge base Capa 4 — Flujos de Proceso · 527T · 783R · 6 flujos críticos (F-06: Art. 61 LIC · DATO-REQUERIDO BIAN) · gap ~730 reglas sin tarea · mapa dominios+capacidades |
| [kb-capa5-fronteras.md](kb-capa5-fronteras.md) | Knowledge base Capa 5 — fronteras de bounded contexts entre capacidades |
| [integration-map.md](integration-map.md) | Mapa de Integración AS-IS — 19 sistemas externos + 13 dependencias cross-sistema · mecanismos de entrega · riesgos de separación Citi/Banamex |
| [wfl-catalog.md](wfl-catalog.md) | Catálogo de WFLs — 7 orquestadores batch documentados · ciclo de vida · dependencias · fuente de detalle para cap-wfl.md |
| [enrichment-report.md](enrichment-report.md) | Reporte de enriquecimiento — cobertura nodos 114/114 S500 + 104/104 S151 · 100% · generado por enrich-dependency-graphs.py |

---

## Capacidades (23 · 20 archivos físicos)

> FSV comparte cap-int.md · ACC comparte cap-sec.md · SPI comparte cap-pay.md — 23 capacidades documentadas en 20 archivos físicos.

| Slug | Archivo | Capacidad | Riesgos MR |
|------|---------|-----------|------------|
| ADJ | [capacidades/cap-adj.md](capacidades/cap-adj.md) | GL Adjustments & Sync — BC-09 | 8 |
| CFR | [capacidades/cap-cfr.md](capacidades/cap-cfr.md) | CFR Regulatory Reporting — Serie B CNBV | 11 |
| CMP | [capacidades/cap-cmp.md](capacidades/cap-cmp.md) | Compliance & Regulation — FraudLink | 10 |
| DEP | [capacidades/cap-dep.md](capacidades/cap-dep.md) | Deposits — Conciliación B01↔B03 | 7 |
| GL  | [capacidades/cap-gl.md](capacidades/cap-gl.md) | Finance GL — Motor de Asientos + P108 | 10 |
| HLD | [capacidades/cap-hld.md](capacidades/cap-hld.md) | Holdings — Saldos P050+P052+P138 | 10 |
| INT | [capacidades/cap-int.md](capacidades/cap-int.md) | Interest & Fees + Integraciones CITI/IBM/ACL | 9 |
| MQ  | [capacidades/cap-mq.md](capacidades/cap-mq.md) | MQ/Async — TIPO-PROC 33-37 | 1 |
| ODS | [capacidades/cap-ods.md](capacidades/cap-ods.md) | Operational Data Stores — DMSII + L030 + P606 | 13 |
| ORC | [capacidades/cap-orc.md](capacidades/cap-orc.md) | Operational Reconciliation — Batch Lifecycle | 11 |
| PAY | [capacidades/cap-pay.md](capacidades/cap-pay.md) | Payments — Cargos y Abonos + SPEI/CLABE | 2 |
| REC | [capacidades/cap-rec.md](capacidades/cap-rec.md) | Financial Reconciliation — Punteo + P178 | 12 |
| RPT | [capacidades/cap-rpt.md](capacidades/cap-rpt.md) | Batch Control & Regulatory Extraction — P677 gate + P610 dispatcher + P612 WFL + P199 bridge + P120 SAR | 10 |
| SCH | [capacidades/cap-sch.md](capacidades/cap-sch.md) | Scheduling — Cierre Día + P103 Calendar-Corporativo | 7 |
| SEC | [capacidades/cap-sec.md](capacidades/cap-sec.md) | Security — Enmascaramiento PII + Access Control | 9 |
| STA | [capacidades/cap-sta.md](capacidades/cap-sta.md) | Statements — Generador MOVSXCONT P158 | 5 |
| TAR | [capacidades/cap-tar.md](capacidades/cap-tar.md) | ATM/PoS — Liquidación Tarjetas | 7 |
| TEL | [capacidades/cap-tel.md](capacidades/cap-tel.md) | Teller — Gateway Online/Sucursal | 4 |
| WFL | [capacidades/cap-wfl.md](capacidades/cap-wfl.md) | Batch Orchestration — WFL Orchestrator T.5.1 · síntesis de wfl-catalog.md | — |
| CPE | [capacidades/cap-cpe.md](capacidades/cap-cpe.md) | CPE Captación Productiva Especial Mensual — T.6.1 · P310+P330+P335 · RMENSUALCPE · SAT-IDSISTEMA="S152" | 7 |

---

## Catálogo de reglas — Capa 2 (33 archivos · 1,513 reglas únicas)

### S500 — Cargos / Abonos (12 archivos · ~558 reglas)

| Archivo | Programas | IDs |
|---------|-----------|-----|
| [rules-catalog/rules-s500.md](rules-catalog/rules-s500.md) | P103 · P100 · P075 · P655 · S500P630 | RN-S500-001..078 |
| [rules-catalog/rules-s500-p130.md](rules-catalog/rules-s500-p130.md) | S500/P130 · WFL LINEA | RN-S500-079..107 |
| [rules-catalog/rules-s500-p020-p142-p144.md](rules-catalog/rules-s500-p020-p142-p144.md) | P020 · P142 · P144 | RN-S500-108..152 |
| [rules-catalog/rules-s500-s151registra-p103fraude.md](rules-catalog/rules-s500-s151registra-p103fraude.md) | S151REGISTRA · P103 FraudLink | RN-S500-153..182 |
| [rules-catalog/rules-s500-p310.md](rules-catalog/rules-s500-p310.md) | P310-CARGA (Captación CPE) | RN-S500-183..202 |
| [rules-catalog/rules-s500-p010-p110.md](rules-catalog/rules-s500-p010-p110.md) | P010 Teller · P280 · P110 ATM · P010_PAR · P060 | RN-S500-203..246 |
| [rules-catalog/rules-s500-deposits-a.md](rules-catalog/rules-s500-deposits-a.md) | P170 · P191 · P127 · P109 · P290 · P164 · P115 | RN-S500-261..302 |
| [rules-catalog/rules-s500-deposits-b-interest.md](rules-catalog/rules-s500-deposits-b-interest.md) | P107 · P189 · P117 · P168 · P315 · P181 · P187 · P108 · P050 · P199 · P305 · P121 · P330 · P320 | RN-S500-361..430 |
| [rules-catalog/rules-s500-payments-statements.md](rules-catalog/rules-s500-payments-statements.md) | P155 · P178 · P176 · P174 · P161 · P179 · P335 · P400 · P185 · P184 · P165 | RN-S500-501..560 |
| [rules-catalog/rules-s500-financial-servicing.md](rules-catalog/rules-s500-financial-servicing.md) | P105 · P015 · P045 · P180 · P120 · P102 · P005 · P046 · P106 · P160 · P101 | RN-S500-611..664 |
| [rules-catalog/rules-s500-reconciliation.md](rules-catalog/rules-s500-reconciliation.md) | P080 · P186 · P104 · P197 · P131 · P195 · P125 · P140 · P190 · P055 · P200 · P188 · P430 · P420 · P091 · P093 | RN-S500-721..776 |
| [rules-catalog/rules-s500-algol-wfl-stubs.md](rules-catalog/rules-s500-algol-wfl-stubs.md) | 15 ALGOL · 3 WFL · 5 INC · 7 DASDL — estrategia RETAIN+ENCAPSULATE | (arquitectura) |

### S151 — Movimientos Contables GL (21 archivos · ~992 reglas)

| Archivo | Programas | IDs |
|---------|-----------|-----|
| [rules-catalog/rules-s151-p112.md](rules-catalog/rules-s151-p112.md) | P112 Punteo | RN-S151-001..020 · citados en rules-s151.md (fuente canónica del rango) |
| [rules-catalog/rules-s151.md](rules-catalog/rules-s151.md) | P109 GL Posting Engine | RN-S151-021..060 |
| [rules-catalog/rules-s151-p130-p131.md](rules-catalog/rules-s151-p130-p131.md) | P130 Agrupador · P131 Traductor CFR | RN-S151-061..080 · RN-S151-091..112 |
| [rules-catalog/rules-s151-p108-p150.md](rules-catalog/rules-s151-p108-p150.md) | P108 GL Bitácora · P150 CITI | RN-S151-121..180 |
| [rules-catalog/rules-s151-p021-p120.md](rules-catalog/rules-s151-p021-p120.md) | P021 ALGOL · P103 · P120 SAR | RN-S151-181..232 |
| [rules-catalog/rules-s151-p010.md](rules-catalog/rules-s151-p010.md) | P010 Gateway Online | RN-S151-241..272 |
| [rules-catalog/rules-s151-p050-p052.md](rules-catalog/rules-s151-p050-p052.md) | P050 · P052 Holdings | RN-S151-281..330 |
| [rules-catalog/rules-s151-p151.md](rules-catalog/rules-s151-p151.md) | P151 IBM-Citibank ALR/AHR/OCM | RN-S151-331..360 |
| [rules-catalog/rules-s151-p158.md](rules-catalog/rules-s151-p158.md) | P158 MOVSXCONT Statements | RN-S151-361..390 |
| [rules-catalog/rules-s151-p178-p138.md](rules-catalog/rules-s151-p178-p138.md) | P178 Verificación Saldos · P138 Posición Global | RN-S151-391..420 |
| [rules-catalog/rules-s151-p199-p600.md](rules-catalog/rules-s151-p199-p600.md) | P199 · P610 · P612 · P677 RPT | RN-S151-421..490 |
| [rules-catalog/rules-s151-dasdl.md](rules-catalog/rules-s151-dasdl.md) | DASDL BD10·BD11·BD12·BD13·BD99·BD02 · 6 bases completas | RN-S151-491..525 |
| [rules-catalog/rules-s151-l030.md](rules-catalog/rules-s151-l030.md) | L030 Librería Maestra | RN-S151-526..550 |
| [rules-catalog/rules-s151-p602-p606-p620-p630.md](rules-catalog/rules-s151-p602-p606-p620-p630.md) | P602 · P606 · P620 · P630 | RN-S151-551..590 |
| [rules-catalog/rules-s151-p655-p670-p671-p680-p690.md](rules-catalog/rules-s151-p655-p670-p671-p680-p690.md) | P655 · P670 · P671 · P680 · P690 | RN-S151-591..632 |
| [rules-catalog/rules-s151-l002r3-r4-r5.md](rules-catalog/rules-s151-l002r3-r4-r5.md) | L002R3 · L002R4 · L002R5 ACL ALGOL | RN-S151-633..689 |
| [rules-catalog/rules-s151-p312-p330-p360.md](rules-catalog/rules-s151-p312-p330-p360.md) | P312 · P330 · P360 BC-09 | RN-S151-710..749 |
| [rules-catalog/rules-s151-contabilidad-a.md](rules-catalog/rules-s151-contabilidad-a.md) | P107 · P167 · P169 · P115 · P135 · P177 · P110 · P117 · P104 · P172 · P116 · P197 · P111 · P128 | RN-S151-750..822 |
| [rules-catalog/rules-s151-contabilidad-b.md](rules-catalog/rules-s151-contabilidad-b.md) | P122 · P152 · P168 · P114 · P113 · P171 · P153 · P195 · P170 · P196 · P102 · P194 · P103 | RN-S151-850..920 |
| [rules-catalog/rules-s151-movimientos.md](rules-catalog/rules-s151-movimientos.md) | P053 · P030 · P014 · P055 · L040 · P054 · P005 · P013 · P001 · P025 · P016 · L020 · L014 · P011 · P020 · P071 · P017 · P073 · P090 · P600 | RN-S151-950..1139 |
| [rules-catalog/rules-s151-algol-wfl-stubs.md](rules-catalog/rules-s151-algol-wfl-stubs.md) | 11 ALGOL · 3 WFL — estrategia RETAIN+ENCAPSULATE | (arquitectura) |

---

## Código fuente raw — Capa 0 (source/)

> Código fuente Unisys ClearPath MCP original — copiado de los directorios de extracción el 2026-07-22. Fuente primaria de verdad para validación de reglas, resolución de conflictos vRSM y análisis del chatbot RAG. Capa 0 del Gemelo Cognitivo.

| Directorio | Archivos | Descripción |
|------------|----------|-------------|
| [source/S500/](source/S500/) | 114 | S500 Cargos/Abonos — COBOL (P*.txt) · ALGOL · DASDL · INC · WFL · copiados de S500/source/S500/extracted_source/ |
| [source/S151/](source/S151/) | 104 | S151 GL Movimientos Contables — COBOL (P*.txt) · ALGOL (L*.txt) · DASDL · WFL · copiados de S151/source/S151/ |

---

## Vocabulario e inventario (Capa 0 inventarios + Capa 1)

| Archivo | Capa | Descripción |
|---------|------|-------------|
| [data/S500/inventario-s500.md](data/S500/inventario-s500.md) | Capa 0 | Inventario maestro S500 — 114 programas · LOC por tipo · base del grafo de dependencias |
| [data/S151/inventario-s151.md](data/S151/inventario-s151.md) | Capa 0 | Inventario maestro S151 — 104 programas · LOC por tipo · base del grafo de dependencias |
| [data/S500/vocab-s500.md](data/S500/vocab-s500.md) | Capa 1 | Vocabulario controlado S500 — 38,262 entradas (63 términos dominio + 38,199 campos COBOL/INC · +28 entradas DMSII vRSM Fase 1: 11 GROUP OCCURS + 17 ÍNDICE-DMSII BD03/BD05/BD06/BD07) · correcciones Gaps C/D/F aplicadas · correlacionado a reglas vía vocab-rules-xref.md |
| [data/S151/vocab-s151.md](data/S151/vocab-s151.md) | Capa 1 | Vocabulario controlado S151 — 31,671 entradas (80 términos dominio + 31,591 campos COBOL/ALGOL) · correcciones Gaps D/F aplicadas (15 $SET OMIT marcados NO-FÍSICO · W77-MONEDA reclasificado CAMPO-COMP · P630+P655 colisiones marcadas) · correlacionado a reglas vía vocab-rules-xref.md |

---

## Portal / Infraestructura GemCog

| Archivo | Descripción |
|---------|-------------|
| [portal-presentation-layer.md](portal-presentation-layer.md) | Capa de presentación del portal GemCog — especificación HTML/CSS de todas las vistas · deploy S3 |

---

## Referencias AS-IS — Fase 1 DISCOVER

| Archivo | Descripción |
|---------|-------------|
| [interface-contract-bc04-acl.md](interface-contract-bc04-acl.md) | Contrato de interfaz BC-04 ACL · síntesis S500-side (RN-S500-153..182) + S151-side (RN-S151-633..689) + dispatch table — documenta la integración AS-IS entre S500 y S151 |

> **Artefactos TO-BE (Fase 2+):** movidos a [to-be-backlog.md](to-be-backlog.md) para mantener este MANIFEST como índice AS-IS puro. Se re-indexarán aquí al activar cada fase de migración.

---

## Archivos supersedidos `[DEPRECATED]`

> Reemplazados por los registros canónicos de programas. Conservados en el repositorio como referencia histórica; no usar como fuente de datos activa.

| Archivo | Reemplazado por |
|---------|-----------------|
| [bian-mapping-s500.md](bian-mapping-s500.md) | [program-registry-s500.md](program-registry-s500.md) |
| [bian-mapping-s500-LEGACY.md](bian-mapping-s500-LEGACY.md) | [program-registry-s500.md](program-registry-s500.md) |
| [bian-mapping-s151.md](bian-mapping-s151.md) | [program-registry-s151.md](program-registry-s151.md) |
| [bian-mapping-s151-LEGACY.md](bian-mapping-s151-LEGACY.md) | [program-registry-s151.md](program-registry-s151.md) |

---
