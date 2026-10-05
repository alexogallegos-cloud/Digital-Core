# Digital Twin — SAP Doble Landscape (ECC LIV vs S/4HANA SBB)
> `liverpool-brain/dt/dt-sap-doble-landscape/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-02

## Propósito

Gemelo digital de los dos landscapes SAP paralelos de Liverpool: SAP ECC on-prem para Liverpool (LIV) y SAP S/4HANA en Azure para Suburbia (SBB). Con 56 servicios en el inventario, SAP es el sistema con mayor presencia en el programa.

Este DT responde la pregunta más estratégica del ERP: ¿cuál es el camino de Liverpool desde SAP ECC hacia S/4HANA, y qué puede aprender del caso SBB que ya está en S/4?

## Dominios Principales
R01 — Gestión Comercial
R04 — Cadena de Suministro y Logística
R07 — Finanzas y Contabilidad
R08 — Recursos Humanos

## Landscapes SAP

| Landscape | Sociedad | Plataforma | Módulos principales | Estado |
|-----------|---------|-----------|--------------------|----|
| SAP ECC (LIV) | Liverpool | On-premise | FI/CO · MM · SD · WM · HCM · BI · PDM · SRM · F&R | Baseline — candidato a migración |
| SAP S/4HANA (SBB) | Suburbia | Azure (cloud) | FI/CO · MM · SD · EWM · HCM · BW4 | Target — ya migrado |
| SAP BW (híbrido) | LIV+SBB | On-prem + Azure | BW Híbrido (Presidencia) + BW LIV + BW PDM + BW4 SBB | Transitional |

## Módulos / Plataformas SAP en el Inventario

| p (plataforma dashboard) | Módulo | Landscape | Servicios (~) |
|--------------------------|--------|-----------|--------------|
| SAP ECC | FI, MM, SD, WM, SRM | LIV on-prem | ~18 |
| SAP S/4HANA | FI/CO, MM, SD | SBB Azure | ~6 |
| SAP EWM | Extended Warehouse Management | LIV+SBB | ~6 |
| SAP PMR | Planificación / reposición | LIV | ~3 |
| SAP PDM/PDTA | Product Data Management | LIV | ~4 |
| SAP SRM | Supplier Relationship Mgmt | LIV | ~3 |
| SAP F&R | Forecasting & Replenishment | LIV | ~3 |
| HCM | Human Capital Management | LIV+SBB | ~6 |
| SAP BW | Business Warehouse / BI | LIV+SBB | ~5 |
| SAP PMR | Planificación compras | LIV | ~2 |

## Flujos Clave a Modelar

1. **Ciclo de compra/reposición**: SAP PMR (planificación) → SAP F&R (forecasting) → SAP SRM (proveedor) → SAP MM (pedido compra) → SAP EWM (recepción CD)
2. **Ciclo financiero**: SD (venta) → FI/CO (contabilización) → SAP BW (reporting) → Presidencia
3. **Gestión del producto**: SAP PDM/PDTA → SAP MM (artículo) → PIM-STEP (atributos web)
4. **RRHH**: SAP HCM — nómina LIV + SBB (¿instancias separadas o compartidas?)
5. **Diferencial LIV vs SBB**: qué procesos existen en ECC que no están en S/4 SBB y viceversa

## Señales Activas

- **56 servicios SAP** — la mayor concentración del inventario
- SAP ECC LIV: **on-prem**, candidato a S/4HANA migration (brownfield vs greenfield pendiente definir)
- SAP S/4HANA SBB: **ya en Azure** — es el caso de referencia para la migración LIV
- SAP EWM: módulo más complejo logísticamente — robots Locus, sorters Mecalux, Putwall ATOX en PLAN N5 (automatización CD)
- SAP BW: híbrido — BW LIV on-prem + BW4 SBB Azure → dos stacks de reporting paralelos

## Preguntas Estratégicas que Responde

1. ¿Qué hay en SAP ECC LIV que SBB S/4HANA ya resolvió? ¿Puede LIV adoptar la misma configuración?
2. ¿Brownfield (upgrade in-place ECC→S/4) o Greenfield (reimplementación desde SBB) para LIV?
3. ¿Cuántas customizaciones Z/Y existen en ECC LIV que bloquean el upgrade estándar?
4. ¿Cuál es el impacto de la automatización de CD (EWM N5) en el timeline de modernización?
5. ¿Cómo unificar el BW Híbrido en una sola plataforma de analytics?

## Estado

`[STATE: SCAFFOLD]` — estructura creada 2026-09-02.
Este DT requiere acceso ABAP para poblar la capa de customizaciones. Es el de construcción más larga.
Prerequisito: activar el Specialist - SAP ABAP para el análisis RE de SAP ECC LIV.

## Fuentes de Datos Necesarias para Activar

- [ ] Lista de programas Z/Y en SAP ECC LIV (SE80 export o equivalente)
- [ ] Lista de BADIs + Enhancement Spots activos
- [ ] Scope comparison ECC LIV vs S/4HANA SBB (qué módulos/transacciones difieren)
- [ ] SAP Simplification Item Catalog (assessment S/4HANA readiness)
- [ ] Configuración SAP EWM — estrategias de warehouse, procesos de automation N5

## Dependencias Cross-DT

- `dt-catalogo-producto` → SAP PDM/PDTA + SAP ECC MARA son la base del artículo; el DT de catálogo depende de este
- `dt-pedido-omnicanal` → SAP EWM es el sistema de fulfillment de almacén; el OMS depende de EWM
- `dt-bus-integracion` → los dos landscapes SAP tienen flows IIB distintos — la migración LIV→S/4 afecta el bus