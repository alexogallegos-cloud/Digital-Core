# Ontología Base — Retail
> Enterprise Brain · Knowledge Base · Ontología de Negocio por Industria
> Versión 1.1 · 2026-11-27 · Digital Core · Accenture México

Clientes del estate: **Liverpool · Coppel**

---

## Identidad

| Campo | Valor |
|-------|-------|
| `system_info.industry` | `retail` |
| `system_info.brain_name` canónico | `retail-brain` |
| Industry SME | `SME/Industry/Industry Retail/` |
| Sin eje LOB/ramo | El discriminador es la **categoría/departamento de producto** y el **canal de venta** |
| FSV overlay | Si el retailer opera servicios financieros (tarjeta propia, crédito al consumo), agrega `financial_services` como ontología secundaria — con sus propios reguladores |

---

## Modelo de Capabilities

### Retail ETB — Estructura L1/L2

El catálogo completo (Liverpool: Retail_ETB_V4 v5.0 con 171 L3 + 61 extensiones propias) vive en el Industry Retail SME. Esta tabla documenta la estructura L1/L2 destilada del estate.

| L1 | L2 (principales) | Tablas brain.db | Aplica si |
|----|-----------------|-----------------|-----------|
| **Customer & Loyalty** | CRM · Programa de lealtad · Segmentación · Personalización · Customer Service | `capabilities` · `journeys` · `vocabulary` | siempre |
| **Merchandising & Planning** | Planeación de temporada · Open-to-buy · Surtido · Planograma · Pricing | `capabilities` · `processes` · `rules` | siempre |
| **Product & Catalog** | Gestión de catálogo · Master Data · Contenido · Lifecycle de producto | `capabilities` · `data_entities` | siempre |
| **Sourcing & Procurement** | Negociación con proveedores · POs · Importaciones · Vendor compliance | `capabilities` · `suppliers` · `processes` | siempre |
| **Supply Chain & Logistics** | Planeación de demanda · Inventarios · WMS · TMS · Last mile · Devoluciones | `capabilities` · `technology_components` · `journeys` | siempre |
| **Commerce (Omnichannel)** | Tiendas físicas · eCommerce · Marketplaces · App · Click & Collect · BOPIS | `capabilities` · `journeys` · `components` | siempre |
| **Payments & Financial Services** | Medios de pago · Tarjeta propia · Crédito al consumo · BNPL · Remesas | `capabilities` · `regulatory_obligations` | si FSV activo |
| **Marketing & Digital** | Campañas · Personalización digital · SEO/SEM · Social commerce | `capabilities` | siempre |
| **Finance & Accounting** | P&L por tienda/canal · CFDI · NIIF · Conciliación de caja | `capabilities` · `data_entities` | siempre |
| **Human Capital** | Nómina · Turnover (alta rotación en retail) · Scheduling · Capacitación | `capabilities` · `stakeholders` | siempre |
| **Technology & Infrastructure** | POS · ERP · eCommerce platform · WMS · MDM · Cloud | `technology_components` · `itom_layer` | siempre |

### FSV Overlay (Financial Services Value)

Aplica cuando el retailer opera servicios financieros (Liverpool, Coppel). Se agrega como ontología secundaria en `ontology_bindings`:

| L1 FSV | Regulador adicional que activa | Tablas adicionales |
|--------|-------------------------------|-------------------|
| Crédito al consumo (tarjeta propia) | CNBV (si opera como SOFOM/banco) · CONDUSEF | `regulatory_obligations` · `rules` (tasas, cobranza) |
| Medios de pago propios | Banxico (si opera SPEI/CoDi) | `regulatory_obligations` · `components` |
| Seguros (garantía extendida, protección de crédito) | CNSF | `regulatory_obligations` · `capabilities` |
| Remesas | Banxico · CNBV | `regulatory_obligations` · `journeys` |

---

## Ontología de Procesos

`process_ontology` en `system_info`: `retail-mx`

### L1 — Cadena de Valor Retail (PLAN → BUY → MOVE → SELL → SERVE)

| L1 | L2 (principales) | Regulador rector | `process_id` sugerido |
|----|-----------------|-----------------|----------------------|
| **PLAN** | Planeación de temporada · Planeación financiera (OTB) · Planeación de surtido · Pronóstico de demanda | SAT (facturación) · IMSS (nómina) | `P-PLN-001..N` |
| **BUY / SOURCE** | Negociación con proveedores · Generación de POs · Importaciones · Calidad de producto · Vendor compliance | SAT (importaciones) · SHCP (aranceles) · PROFECO (etiquetado) | `P-BUY-001..N` |
| **MOVE** | Recepción en CD · Almacenamiento (WMS) · Cross-docking · Reabasto de tiendas · Devoluciones a proveedor · Last mile eCommerce | SCT (transporte) · COFEPRIS (si hay alimentos/medicamentos) | `P-MOV-001..N` |
| **SELL** | Venta en tienda · Venta digital (eCommerce/app) · Marketplace · Click & Collect · BOPIS · Cierre de caja · Conciliación de medios de pago | SAT (CFDI) · PROFECO (precios, ofertas, garantías) · Banxico (si opera pagos) · CNBV (si opera crédito) | `P-SEL-001..N` |
| **SERVE** | Servicio post-venta · Garantías · Devoluciones del cliente · Programa de lealtad · Atención de quejas | PROFECO (garantías legales: 1 año mínimo) · CONDUSEF (si hay producto financiero) | `P-SRV-001..N` |
| **FINANCIAL SERVICES** (FSV) | Originación de crédito · Cobranza · Pagos de tarjeta · Seguros de compra | CNBV · CONDUSEF · Banxico (si aplica) | `P-FSV-001..N` |

---

## Reguladores Rectores

### Mapa Regulatorio Retail México

| Regulador | Tipo | Jurisdicción | Tablas brain.db afectadas |
|-----------|------|-------------|--------------------------|
| **PROFECO** | Protección al consumidor | Garantías · Precios · Publicidad engañosa · Etiquetado | `regulatory_obligations` · `rules` (garantías, precios) |
| **SAT / SHCP** | Fiscal | CFDI de ventas y compras · Importaciones · Nómina digital · ISR/IVA | `regulatory_obligations` · `data_entities` · `components` (emisión de facturas) |
| **COFEPRIS** | Salud y calidad | Si el retailer vende alimentos, medicamentos, cosméticos | `regulatory_obligations` · `capabilities` (cadena de frío, etiquetado FDA-like) |
| **SCT** | Transporte | Regulación de flotilla propia o carga | `regulatory_obligations` (solo si fleet management propio) |
| **IMSS / STPS** | Laboral | Nómina · Contratos de temporada · Alta rotación | `regulatory_obligations` · `stakeholders` |
| **INAI** | Datos personales | LFPDPPP — datos de clientes en CRM y lealtad | `data_entities.sensitivity_level` · `regulatory_obligations` |
| **CNBV** | Prudencial financiero | **Solo si FSV activo** — SOFOM/banco del retailer · tarjeta propia | `regulatory_obligations` · `rules` (tasas activas, reservas de crédito) |
| **CONDUSEF** | Protección financiera | **Solo si FSV activo** — transparencia de crédito · RESBA · Buró | `regulatory_obligations` · `rules` (CAT, tasas, penalidades) |
| **Banxico** | Sistema de pagos | **Solo si FSV activo** — operación de pagos, SPEI, CoDi | `regulatory_obligations` · `components` (procesador de pagos) |
| **CNSF** | Seguros | **Solo si FSV activo** — garantía extendida · seguro de crédito | `regulatory_obligations` · `capabilities` (si tiene ramo propio) |

### Instrumentos Normativos Clave

| Instrumento | Emisor | Impacto en brain.db |
|-------------|--------|---------------------|
| **Ley Federal de Protección al Consumidor (LFPC)** | Congreso · PROFECO | Garantías mínimas (1 año) · precios · publicidad · `rules` y `regulatory_obligations` |
| **CFDI 4.0 (Comprobante Fiscal Digital)** | SAT | Toda transacción de venta genera CFDI · `components` (motor de facturación) · `journeys` (SELL) |
| **NOM-050-SCFI (Etiquetado comercial)** | SE | Información en productos · `regulatory_obligations` (solo Merchandising/Catalog) |
| **LFPDPPP (Datos Personales)** | INAI | CRM · lealtad · cookies · `data_entities.sensitivity_level` |
| **Ley de Infraestructura de la Calidad** | SE | Aplica si el retailer importa o manufactura | `regulatory_obligations` (BUY/SOURCE) |
| **Circulares CNBV (SOFOM/tarjeta)** | CNBV | Solo FSV: tasas máximas, reservas, reporting · `rules` · `regulatory_obligations` |
| **NOM-011-STPS (Seguridad en centros de trabajo)** | STPS | Aplica a CD/tiendas físicas · `stakeholders` (roles de seguridad) |

---

## Cadena de Valor — Retail

### Top-down: Producto → Código

```
products                 ← Categoría (Electrónica · Moda · Hogar · Alimentos) · SKU
    │
    ▼
kpis                     ← GMV · Ticket promedio · Margen bruto · Inventory turn · Net Promoter Score
    │
    ▼
processes                ← PLAN → BUY → MOVE → SELL → SERVE
    │
    ▼
capabilities (ETB L3)    ← "Planeación de demanda" · "Reabasto automático" · "BOPIS" · "Garantía extendida"
    │
    ▼
components/rules         ← APIs de eCommerce · WMS logic · POS flows · CRM rules · motor de precios
    │
    ▼
technology_components    ← SFCC · SAP · Manhattan WMS · BlueYonder · Salesforce CRM · o9 · GCP
    │
    ▼
itom_layer               ← Technology Operations · Customer & Ecosystem Engagement · Delivery
```

### Bottom-up: Infra → KPI

```
itom_layer (technology-operations)
    → technology_components (SFCC · SAP · WMS · POS · GCP)
        → components (APIs de catálogo · engine de pricing · motor de reabasto)
            → rules (reglas de negocio: margen mínimo · reabasto por punto de reorden · garantía)
                → journeys (flujo completo de compra online + devolución en tienda)
                    → processes (SELL · SERVE)
                        → kpis (Conversión · Devoluciones · NPS · GMV)
                            → products (categorías y marcas propias)
```

### Correlación Regulatoria Clave

Una regla que define el proceso de garantía de 1 año en compra de electrónica toca:
- `regulatory_obligations`: PROFECO (LFPC Art. 77 — garantía mínima 1 año)
- `rules.reg`: marcado con LFPC + NOM de la categoría
- Si el cliente pagó con tarjeta del retailer: agrega CONDUSEF (CNBV)
- `knowledge_lineage.tier`: gold (LFPC es ley publicada en DOF)

---

## ITOM — Dominios Predominantes en Retail

| Dominio ITOM | Hemisferio | Sub-capacidades clave en retail | Casos de uso de IA |
|-------------|-----------|--------------------------------|-------------------|
| `customer-engagement` | Ambos | Omnichannel · Demand mgmt · Digital channels · Personalization | Journeys reales de compra → recomendación · churn prediction |
| `technology-operations` | Run | eCommerce ops · WMS ops · POS network · PIM/MDM | RCA en fallas de pago · runbooks de peak season (Hot Sale · Buen Fin) |
| `delivery` | Change | APIs de catálogo · Microservicios eCommerce · CI/CD | Code gen eCommerce · test cases de flujos SELL/SERVE |
| `information-analytics` | Ambos | MDM · Datos de cliente · Reporting financiero · SAT reporting | Linaje de datos producto · automatización CFDI · análisis de margen |
| `it-management` | Ambos | FinOps (cloud retail) · LFPDPPP compliance · Vendor governance | Mapeo PROFECO → reglas de garantía · CRM data governance |

---

## Stack Tecnológico de Referencia en Retail (estate)

| Plataforma | Función | Clientes del estate |
|-----------|---------|---------------------|
| Salesforce Commerce Cloud (SFCC) | eCommerce B2C | Coppel · [Liverpool usa plataforma propia] |
| SAP S/4HANA | ERP (Finance · Procurement · HR) | Liverpool · Coppel |
| Manhattan Associates / BlueYonder | WMS · TMS · Demand Planning | Liverpool |
| o9 Solutions | Demand & Supply Planning | Liverpool |
| Adobe Experience Cloud | Marketing · Personalización | Liverpool |
| Salesforce CRM | Customer data platform | Liverpool |
| GCP | Cloud platform principal | Coppel eCommerce |
| Oracle Retail | Merchandising · Inventory | Liverpool (legacy) |

---

## Cómo Usar en brain.db

### `system_info` (fields específicos de retail)

```sql
industry         = 'retail'               -- vocabulario cerrado (ADR-EB-019)
industry_sme     = 'SME/Industry/Industry Retail/'
capability_model = 'Retail ETB V4 v5.0 (RTL) con overlay FS ETB v1.0 (FSV)'
process_ontology = 'retail-mx'
process_ontology_version = '1.0'
lob_dimension    = NULL                   -- no aplica en retail puro
```

El nombre del brain (`retail-brain`) no es columna de `system_info`: se deriva de
`industry` por la tabla de la Regla B18. El regulador tampoco: cada ontología
trae los suyos en `ontology_bindings.regulators`, y en un retailer con brazo
financiero eso es justamente lo que permite que PROFECO y CNBV convivan sin
contradecirse.

### `ontology_bindings` (retailer con FSV activo — Liverpool pattern)

La columna `ontology` es la llave primaria y lleva el slug del miembro de la
composición (ADR-EB-019). `financial_services` es el nombre de una ontología, no
un `model_type`: su forma de ancla es `etb`, igual que la del retail base.

```sql
-- Retail base — PRIMARIA, slug idéntico a system_info.industry
(ontology='retail', role='primary', model_type='etb',
 catalog='Retail_ETB_V4', catalog_version='5.0',
 industry_sme='SME/Industry/Industry Retail/',
 l3_base=171, l3_extension=61,
 regulators='["PROFECO","SAT","INAI"]')
-- Las 61 extensiones propias ("Newly Added" en Liverpool) NO son otra fila:
-- se cuentan en l3_extension y cada capability las marca con is_extension=1.

-- Financial Services Value (FSV) — overlay financiero
(ontology='financial_services', role='secondary', model_type='etb',
 catalog='FSV_ETB', catalog_version='1.0', l3_base=50,
 regulators='["CNBV","CONDUSEF","Banxico"]')

-- Cadena de valor
(ontology='retail-value-chain', role='secondary', model_type='value-chain',
 catalog='Retail_Value_Chain_MX')

-- TI
(ontology='itom', role='secondary', model_type='itom',
 catalog='ITOM_v9.0', regulators='[]')
```

Exactamente una fila lleva `role='primary'`, y es la que fija el nombre del brain
(Regla B18). Liverpool compone dos ontologías de capabilities y aun así es
`retail-brain`, porque la industria ancla es retail.

---

## Del Estate — Lo que los Brains Reales Usan

| Cliente | model_type(s) | Particularidad |
|---------|--------------|----------------|
| Liverpool | `etb` (Retail_ETB_V4 v5.0: 171 L3 + 61 custom) + `financial_services` (50 L3) + `value-chain` | 61 capabilities propias (is_extension=1) — no están en el ETB base; tarjeta Liverpool activa FSV overlay con CNBV/CONDUSEF |
| Coppel | `etb` + posible FSV | eCommerce Node/Next/Go/SFCC/GCP; BanCoppel es entidad separada (brain independiente `bank-brain`) |

---

*Ontología Base Retail · Enterprise Brain Knowledge Base · v1.1 · 2026-11-27*
