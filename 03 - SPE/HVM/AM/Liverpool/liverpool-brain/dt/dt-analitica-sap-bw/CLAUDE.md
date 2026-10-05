# Digital Twin — Analítica y Business Intelligence (SAP BW + CDP)
> `liverpool-brain/dt/dt-analitica-sap-bw/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-08
> **[STATE: ACTIVE — scaffold; fuente de datos pendiente]**

## Propósito

Gemelo digital de la capa analítica de Liverpool: SAP BW Híbrido (Presidencia), BW LIV (operacional), BW PDM (producto), BW4 SBB (Suburbia en Azure), SAP BusinessObjects y SAS on GCP, más el CDP-GCP en construcción.

Es el DT más subestimado del programa: **toda decisión sobre SAP ECC impacta directamente a los extractores BW**. Sin este DT, el esfuerzo de migración SAP → S/4HANA está incompleto porque los extractores de BW (DataSources) son parte del esfuerzo de conversión.

## Capa de Arquitectura

**Data Architecture domain** — DWH + Analítica + Customer Intelligence

## Dominios Principales

R09 — Analítica e Inteligencia
R07 — Finanzas y Contabilidad (reportes Presidencia)
R01 — Gestión Comercial (analytics de producto y ventas)

## Sistemas Involucrados

| Sistema | Vendor | Rol |
|---------|--------|-----|
| **SAP BW Híbrido** | SAP | Reporting ejecutivo / Presidencia. Combina on-premise y nube. |
| **SAP BW LIV** | SAP | DWH operacional Liverpool — ventas, inventario, finanzas. |
| **SAP BW PDM** | SAP | Analítica de producto — surtido, precios, márgenes. |
| **SAP BW4 SBB** | SAP | DWH Suburbia en Azure — instancia separada post-adquisición. |
| **SAP BusinessObjects** | SAP | Capa de reportes y dashboards sobre BW (Crystal Reports, Lumira). |
| **SAS on GCP** | SAS / Google | Modelos estadísticos — scoring de crédito, demand forecasting. |
| **CDP-GCP** | Internal / GCP | Customer Data Platform en construcción — Customer 360. |

## Arquitectura AS-IS

```
SISTEMAS TRANSACCIONALES
    │
    ├── SAP ECC LIV  ──── DataSources ──→ SAP BW LIV ──→ BW Híbrido
    │                                          │               │
    ├── SAP ECC SBB  ──── DataSources ──→ BW4 SBB (Azure)     │
    │                                                           │
    ├── Mainframe    ──── Control-D (archivos flat) ──→ BW LIV │
    │                                                           │
    ├── Oracle PL-SQL ─── Interfaces custom ──→ BW PDM         │
    │                                                           ▼
    └── Sterling OMS ─── `[DATO-REQUERIDO]`          SAP BusinessObjects
                                                           │
                                                           │  Dashboards Presidencia
                                                           │  Reportes regulatorios
                                                           ▼
                                                    USUARIOS DE NEGOCIO
                                                    (Presidencia, Finanzas, Comercial)

PLATAFORMA TO-BE (en construcción)
    │
    ├── CDP-GCP ──── Eventos cliente (compras, lealtad, digital) ──→ Customer 360
    │
    └── SAS on GCP ──── Modelos ML (scoring, forecasting) ──→ Decisiones comerciales
```

## Señales del AS-IS

| Señal | Impacto | Sistema |
|-------|---------|---------|
| BW Híbrido en Presidencia | Cualquier caída de BW LIV afecta el reporting ejecutivo — SLA implícito sin documentar | BW Híbrido |
| 4 instancias BW independientes | LIV, SBB, PDM y Híbrido son silos analíticos — la vista consolidada de empresa no existe en tiempo real | Todas |
| DataSources SAP = scope S/4HANA migration | La migración ECC → S/4HANA invalida los DataSources tradicionales — requiere BW Bridge o migración a SAP Analytics Cloud | BW LIV / BW4 SBB |
| CDP-GCP en construcción | Hay una inversión activa en Customer 360 que no está coordinada con BW — riesgo de duplicación | CDP-GCP |

## Hipótesis 7R para Este Módulo

| Hipótesis | Sistema | Fundamento |
|-----------|---------|-----------|
| **Retain + Evolve** | SAP BW LIV / BW4 SBB | Migrar a SAP Analytics Cloud (SAC) como capa de presentación sobre S/4HANA HANA Live. Los DataSources se reemplazan por CDS Views en S/4. |
| **Retire gradual** | SAP BW Híbrido | Consolidar reporting Presidencia en SAC + CDP una vez estabilizados. |
| **Repurchase** | SAP BusinessObjects | SAP ha anunciado EOL de BusinessObjects legacy — migrar a SAC o Looker (GCP). |
| **Expand** | CDP-GCP + SAS | Son el target analytics — invertir en completar el Customer 360 y conectar SAS con datos BW. |
| **Retire** | BW PDM | Si Oracle PL-SQL se moderniza, los datos de producto migran a PIM/STEP + CDP. BW PDM pierde razón de ser. |

## Estado

`[STATE: ACTIVE — scaffold]` — DT creado 2026-09-08.
Fuentes de datos primarias (`[DATO-REQUERIDO]`): inventario de DataSources BW, catálogo de reportes BusinessObjects, roadmap CDP-GCP, modelo de datos SAS.

## Fuentes de Datos Disponibles

- [x] Dashboard AS-IS (confirmación de las 4 instancias BW + CDP + SAS)
- [ ] Inventario de DataSources y transformaciones BW LIV
- [ ] Catálogo de reportes BusinessObjects (quién usa qué, frecuencia, SLA)
- [ ] Roadmap CDP-GCP (estado actual, milestones, equipo)
- [ ] Modelo de datos SAS (qué variables consume, qué scores produce)
- [ ] Assessment BW Bridge / SAC readiness para migración S/4HANA

## Dependencias Cross-DT

- `dt-sap-doble-landscape` → la migración SAP ECC → S/4HANA invalida los DataSources; este DT debe coordinarse con la decisión brownfield/greenfield
- `dt-mainframe-core` → Control-D alimenta BW LIV con archivos flat nocturnos; si el mainframe se moderniza, ese pipeline desaparece
- `dt-inteligencia-cliente` → CDP-GCP y este DT son la misma capa analítica vista desde dos ángulos (customer-centric vs. operacional); deben confluir en un roadmap único
- `dt-catalogo-producto` → BW PDM depende de los datos de PIM/STEP y Oracle PL-SQL; la decisión 7R del catálogo determina el futuro de BW PDM