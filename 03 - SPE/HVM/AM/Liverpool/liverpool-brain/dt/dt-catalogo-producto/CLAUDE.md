# Digital Twin — Catálogo de Producto y Merchandising
> `liverpool-brain/dt/dt-catalogo-producto/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-02

## Propósito

Gemelo digital del ciclo de vida del producto: desde la creación del artículo en PIM hasta su publicación en canales digitales, pasando por la planificación de surtido, el pricing, la asignación de tallas y la sincronización con los sistemas de venta.

Este DT es **prerequisito técnico** para el diseño TO-BE de eCommerce: sin entender cómo fluye el catálogo hoy (PIM-STEP → SAP → ATG-Endeca), es imposible diseñar correctamente la migración a commercetools.

## Dominio Principal
R01 — Gestión Comercial

## Sistemas Involucrados

| Sistema | togaf_type | Rol en el catálogo |
|---------|-----------|-------------------|
| PIM-STEP (Stibo Systems) | processors | Master de información de producto LIV+SBB — fuente de verdad del artículo |
| SAP PDM/PDTA | core | Gestión del ciclo de vida del producto en SAP + datos de artículo |
| Oracle PL-SQL (Size Scaling + Allocation) | processors | Planning de surtido: escalado de tallas (Size Scaling) + asignación tienda-artículo (Allocation) |
| SAP PMR | core | Planificación de compras y reposición |
| ATG-Endeca | channels | Publicación catálogo en liverpool.com.mx + suburbia.com + búsqueda Endeca |
| Digital-Platform (GCP) | channels | Apps modernas que consumen catálogo (XD/App Surtido) |
| Bridgecore (POS) | channels | Catálogo en punto de venta tienda física |
| SAP ECC | core | Artículo SAP (MARA/MARC) — datos de compra, inventario, precio |

## Flujos Clave a Modelar

1. **Alta de artículo**: Creación en PIM-STEP → enriquecimiento de atributos → sincronización SAP PDM → SAP ECC (MARA)
2. **Planning de surtido**: SAP PMR (compra) → Oracle PL/SQL Size Scaling (escalado tallas) → Oracle PL/SQL Allocation (asignación tienda) → SAP ECC (MARC)
3. **Publicación digital**: PIM-STEP / SAP → ATG-Endeca (catálogo web) → indexación Endeca (búsqueda) → liverpool.com.mx
4. **Sincronización POS**: SAP ECC → Bridgecore (artículos + precios tienda física)
5. **Gestión de precios**: SAP ECC pricing → ATG (precio web) → Bridgecore (precio tienda) — sincronización y gobernanza

## Señales Activas (del Dashboard)

- **2 servicios** con `p:"PIM"` — PIM-STEP cubre LIV y SBB (ambas sociedades)
- **2 servicios** con `p:"Planning"` — Oracle PL/SQL Size Scaling + Allocation
- **SAP PDM/PDTA**: múltiples servicios en `p:"SAP PDM/PDTA"` con gestión del ciclo de vida del producto
- **17 servicios** en R01 (Gestión Comercial) — dominio de merchandise

## Preguntas Estratégicas que Responde

1. ¿Cómo fluye el artículo desde PIM-STEP hasta ATG-Endeca hoy? ¿Qué transformaciones sufre?
2. ¿Qué lógica vive en Oracle PL/SQL (Size Scaling + Allocation) que debe migrar a commercetools o mantenerse?
3. ¿Cuál es el modelo de datos de producto que commercetools debe absorber?
4. ¿Cómo se sincronizan precios y stock entre web (ATG) y tienda (Bridgecore/SAP)? ¿Hay inconsistencias?
5. ¿Qué impacto tiene en el catálogo el doble landscape SAP (ECC LIV vs S/4 SBB)?

## Estado

`[STATE: SCAFFOLD]` — estructura creada 2026-09-02.
Pendiente: mapear el modelo de datos de PIM-STEP + interfaces de sincronización con SAP y ATG.

## Fuentes de Datos Necesarias para Activar

- [ ] Schema PIM-STEP (Stibo STEP) — estructura de atributos, jerarquías, canales de publicación
- [ ] Interfaces SAP PDM/PDTA + MARA/MARC en SAP ECC
- [ ] Código Oracle PL/SQL Size Scaling y Allocation (lógica de planning)
- [ ] Interfaces ATG-Endeca para carga de catálogo (batch/near-real-time)
- [ ] Configuración Bridgecore para sincronización de artículos/precios POS

## Dependencias Cross-DT

- `dt-ecommerce-transicion` → el modelo de catálogo de PIM-STEP define lo que commercetools debe absorber
- `dt-sap-doble-landscape` → el artículo SAP tiene representación distinta en ECC (LIV) vs S/4HANA (SBB)
- `dt-bus-integracion` → IIB orquesta las sincronizaciones PIM→SAP→ATG→Bridgecore