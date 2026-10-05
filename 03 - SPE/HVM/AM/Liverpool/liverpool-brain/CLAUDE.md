# Liverpool Brain — Federated Brain (Scaffold)

> Brain federado del programa Liverpool · `SPE-AM-003`
> **Estado**: `[STATE: SCAFFOLD]` — estructura creada, brain pendiente de población
> **Hereda**: `../CLAUDE.md` (Liverpool AM) → AM L4 → HVM → 03 S&PE → Digital Core

```
┌─[★ Digital Core — Liverpool Brain]────────────────────────┐
│ Brain federado · SPE-AM-003                               │
│ Agrega: SAP + Oracle + Mainframe + Java                   │
│ Dominios retail: R01-R10                                  │
└───────────────────────────────────────────────────────────┘
```

---

## Propósito

El `liverpool-brain/` es el brain federado del programa de Application Modernization de Liverpool. Agrega y correlaciona el conocimiento de los 4 sistemas que componen el stack Liverpool:

- `systems/core/SAP/digital-brain/brain.db` → SAP ECC/S4HANA
- `systems/core/Mainframe/digital-brain/brain.db` → IBM z/OS COBOL
- `systems/processors/Oracle-PL-SQL/digital-brain/brain.db` → Oracle/PL-SQL
- `systems/channels/Digital-Platform/digital-brain/brain.db` → Java Microservicios

---

## Adaptación Retail vs. Banking

Liverpool es una empresa **retail** (no banking). El schema del brain se adapta respecto al modelo bancario BanCoppel:

| Concepto | BanCoppel (Banking) | Liverpool (Retail) |
|----------|---------------------|-------------------|
| Tabla principal | `sps` (Stored Procedures) | `components` (componentes heterogéneos) |
| Dominio ID | D01-D49 (bancario) | R01-R10 (retail) |
| ETB capabilities | Banking Technology Blueprint | Retail Technology Blueprint (por definir) |
| Lenguaje principal | Informix SPL | SAP ABAP + PL-SQL + COBOL + Java |
| Sistema central | Core bancario Informix | ERP SAP + Oracle financiero |

### Tabla `components` (schema principal del brain retail)

```sql
CREATE TABLE components (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    source_system TEXT,           -- 'SAP' | 'Oracle' | 'Mainframe' | 'Java'
    source_language TEXT,         -- 'ABAP' | 'PL-SQL' | 'COBOL' | 'Java'
    component_type TEXT,          -- 'program' | 'function' | 'package' | 'service' | 'batch'
    domain_id TEXT,               -- R01-R10
    business_name TEXT,
    description TEXT,
    togaf_type TEXT,              -- 'core' | 'processors' | 'channels' | 'data' | 'integration'
    migration_fate TEXT,          -- 'rehost' | 'replatform' | 'refactor' | 'repurchase' | 'retain' | 'retire'
    lines_of_code INTEGER,
    complexity TEXT,              -- 'low' | 'medium' | 'high' | 'very-high'
    status TEXT DEFAULT 'active'  -- 'active' | 'deprecated' | 'candidate'
);
```

---

## Digital Twins

| DT | Ubicación | Estado |
|----|-----------|--------|
| dt-inteligencia-cliente | `dt/dt-inteligencia-cliente/` | `[STATE: ACTIVE]` — Poblado 2026-09-02 |

---

## Archivos del Brain

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `rtb-capabilities.json` | 232 capacidades L3 del Retail Technology Blueprint v5 | `[STATE: ACTIVE]` — 2026-09-02 |
| `liverpool-brain.db` | SQLite federado (282 caps, 10 dominios, 219 components, 469 cross-deps, 40,056 tickets, 202 filas anuales vc×año, 78 apps AMS) | `[STATE: ACTIVE]` — 2026-09-30 |
| `rebuild-all.py` | **Pipeline completo** — encadena brain y portal en orden. Punto de entrada canónico | `[STATE: ACTIVE]` — 2026-09-29 |
| `build-liverpool-brain.py` | Crea el esquema desde cero. No correr suelto: borra las cargas posteriores | `[STATE: ACTIVE]` |
| `liverpool-brain.py` | Agent API + interfaz 5 métodos + federación vía ATTACH | `[STATE: ACTIVE]` |
| `generators/extract-from-dashboard.py` | Extrae 117 servicios del Dashboard AS-IS HTML → components | `[STATE: ACTIVE]` |
| `generators/extract-sap-source.py` | Extrae 12 programas ABAP del Módulo Importaciones → components SAP granulares | `[STATE: ACTIVE]` — 2026-09-07 |
| `generators/load-sud-to-brain.py` | Carga los 54 sistemas SUD → components, cross_dependencies, sud_systems | `[STATE: ACTIVE]` — 2026-09-08 |
| `generators/load-tickets-to-brain.py` | Carga el análisis AMS de GenWizard → ams_groups, ticket_corpus, recurrencias | `[STATE: ACTIVE]` — 2026-09-29 |
| `generators/build-etb-coverage.py` | Ancla las 282 capacidades a eslabón de cadena de valor y dominio | `[STATE: ACTIVE]` — 2026-09-29 |
| `generators/build-capability-mapping.py` | Consolida el mapeo capacidad ↔ aplicación y lo carga al brain | `[STATE: ACTIVE]` — 2026-09-29 |
| `generators/load-cadena-valor-tickets.py` | Carga `ams_yearly` (87 grupos × 2024-2026 con SLA) y enriquece `ams_groups`/`ams_group_component` con `vc_id` | `[STATE: ACTIVE]` — 2026-09-30 |
| `generators/build-cadena-valor-tickets.py` | Genera portal/cadena-valor-tickets-liv.html — carga operativa por eslabón ETB con tendencia anual y alertas SLA | `[STATE: ACTIVE]` — 2026-09-30 |
| `generators/load-procesos-criticos.py` | Carga 43 procesos críticos → `critical_processes` + `process_systems`; registra 5 sistemas nuevos (Regla B8) | `[STATE: ACTIVE]` — 2026-09-30 |
| `generators/load-ams-applications.py` | Carga catálogo oficial AMS → tabla `ams_applications` (78 apps, 7 dominios, mapeo VC, flag Apigee/BTP); 4 apps nuevas por Regla B8 | `[STATE: ACTIVE]` — 2026-09-30 |
| `generators/build-procesos-criticos.py` | Genera portal/procesos-criticos-liv.html — flujos por categoría, sistemas nuevos y cobertura ETB | `[STATE: ACTIVE]` — 2026-09-30 |
| `generators/build-portal.py` | Genera portal/index.html desde brain.db | `[STATE: ACTIVE]` |
| `generators/build-capability-coverage.py` | Genera portal/capability-coverage-liv.html | `[STATE: ACTIVE]` — 2026-09-29 |
| `generators/build-ams-tickets.py` | Genera portal/ams-tickets-liv.html | `[STATE: ACTIVE]` — 2026-09-29 |
| `generators/build-cadena-valor.py` | Genera portal/cadena-valor.html | `[STATE: ACTIVE]` |
| `generators/build-mapa-capacidades.py` | Genera portal/mapa-capacidades.html | `[STATE: ACTIVE]` |

### Estado del brain al 2026-09-30

```
RTL capabilities (Retail)       :    232  (Retail Technology Blueprint v5 — RTL.x.xx)
FSV capabilities (FS R03)       :     50  (Financial Services overlay — FSV.x.xx)
Total capabilities               :    282  (todas con eslabón, dominio y estado de cobertura)
Retail domains                   :     10  (R01-R10)
Components (dashboard)           :    117  (seeded_by=Arquitectura_Liverpool_Dashboard_1.html)
Components (SAP source — ZIM/ZRT):     12  (seeded_by=source/Source Code SAP)
Components (SUD)                 :     54  (seeded_by=SUD)
Components (Regla B8 Procesos)   :      5  (VCM, SIBO, Exstream, VAS, App Pocket)
Components (Regla B8 AMS)        :      4  (DWH/DATA, SAP S4H SBB, SAS, VAS Relojes)
Total components                 :    219
Cross-dependencies               :    469  (463 con evidencia SUD)
capability_coverage              :    486  aristas capacidad × aplicación
Tickets AMS (corpus GenWizard)   : 40,056  en 93 grupos, 4,833 patrones recurrentes
critical_processes               :     43  (11 PDFs, 7 categorías, 104 relaciones sistema-proceso)
ams_applications                 :     78  (catálogo oficial AMS · 7 dominios · 7 apps in scope Apigee/BTP)
```

**Cobertura ETB (2026-09-29):** 46% ponderado — 81 cubiertas, 99 parciales, 97 sin cobertura, 5 transversales.

| Eslabón | Cobertura | Lectura |
|---------|-----------|---------|
| VC-03 Comercio Unificado | 56% | Mejor servido junto con Desarrollo de Oferta |
| VC-01 Desarrollo de Oferta | 56% | PLM Centric C8, o9 PA&A y PIM STEP |
| VC-06 Servicios Financieros | 55% | VPL, FICO TRIAD y Base24; brechas regulatorias |
| VC-02 Cadena de Suministro | 53% | 8 brechas son Manufacturing, no aplica a retail |
| VC-09 Analítica | 50% | Descriptiva cubierta; predictiva ausente |
| VC-07 Fundación Empresarial | 38% | Sin herramientas de seguridad ni gobierno de TI |
| VC-04 Canales de Interacción | 37% | Sin recomendación, marketplace ni comercio social |
| VC-05 Engagement y Marketing | 30% | Sin marketing automation ni retail media |
| VC-08 Fundación de Información | 18% | Sin gobierno, calidad, linaje ni catálogo de datos |

**Brechas de inventario detectadas por tickets:** tres grupos AMS concentran 9,155 tickets sin aplicación catalogada: `AMS DWH/DATA` (7,065), `AMS ACC` (1,341) y `AMS CONTROL CXEC` (749). Por Regla B8 la evidencia operativa prueba que esos sistemas existen. El caso de DWH/DATA se corrobora de forma independiente: los SUD de SAS y CDP citan un data warehouse en BigQuery que no está en el catálogo.

**SAP source (12 programas — Módulo Importaciones):**
Ciclo completo de importaciones: creación de pedido, registro de datos, pre-embarque de proveedor, pedimentos aduanales, faltantes y sobrantes, contabilización.
Programas activos en 2025: `ZRTPOC079N` (abr-2025) y `ZRT_PO_REP_EPI_BD` (oct-2025, pedimentos de ECC a POS).

**Pipeline de reconstrucción — usar siempre `rebuild-all.py`:**
```bash
python rebuild-all.py            # brain completo y las 16 vistas del portal
python rebuild-all.py --portal   # solo regenerar vistas
```
`build-liverpool-brain.py` recrea el esquema desde cero, de modo que correrlo suelto borra las
cargas de SUD, tickets y cobertura. El pipeline las reaplica en orden; esa era una deuda abierta
desde el 2026-09-08 y quedó cerrada el 2026-09-29.

Portal: `python -m http.server 8002 --directory portal` → http://localhost:8002/

---

## Reglas de Brains Aplicables

Aplican todas las Reglas B1-B12 de AM L4 ([../CLAUDE.md](../CLAUDE.md)), adaptadas a retail:
- **B1**: Brain retail auto-sustentable
- **B2**: ETB embebido — adaptar a capacidades retail (R01-R10) vs. bancario (D01-D49)
- **B4**: Federación vía ATTACH de 4 brains de sistema
- **B5**: Cross-system dependencies declaradas en ambos lados (SAP ↔ Oracle ↔ Mainframe ↔ Java)

---

*Creado 2026-09-02 · Scaffold → v0.3 2026-09-07: 129 components (117 dashboard, 12 SAP Importaciones) → v0.4 2026-09-08: carga SUD, 183 components y 469 dependencias → v0.5 2026-09-29: cobertura ETB mapeada (282 capacidades, 46% ponderado), análisis de tickets AMS de GenWizard (40,056 tickets, 93 grupos), dos vistas nuevas de portal y pipeline `rebuild-all.py` que cierra la deuda del rebuild destructivo → v0.6 2026-09-30: análisis anual cadena de valor tickets (87 grupos × 2024-2026, tabla `ams_yearly`, `vc_id` en todos los grupos, 13 nuevos grupos mapeados, vista `cadena-valor-tickets-liv.html`) → v0.7 2026-09-30: 43 procesos críticos (11 PDFs) mapeados al ETB; tabla `critical_processes` + `process_systems` (104 aristas); 5 sistemas nuevos por Regla B8 (VCM, SIBO, Exstream, VAS, App Pocket); 188 components totales; 17 vistas del portal · Portal activo en localhost:8002*