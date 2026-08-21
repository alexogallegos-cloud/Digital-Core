# DT — Cobranza Direccionada (Enabler Cross-Canal)
> Digital Twin del componente Cobranza Direccionada para la Tarjeta de Crédito R4 (Producto 4900).
> Fuente primaria: `20260806 - Unity R4 - Cobranza - Resumen Detallado.docx` (binario, no legible en CLI)
> Sesión de análisis: 2026-08-06
> Última actualización: 2026-08-20 · v1.0.0

---

## Resumen del Componente

| Campo | Valor |
|-------|-------|
| Componente ID | `cobranza` |
| Tipo | enabler (cross-canal) |
| Proveedor principal | Interno BanCoppel |
| Soporte tecnológico | BPC Banking Technologies |
| Status | En desarrollo |
| User Stories totales estimadas | 45 (rango documentado: 37-50 User Stories) |
| RAG actual | 🔴 RED |
| Sesión de análisis | 2026-08-06 |
| Source doc | `20260806 - Unity R4 - Cobranza - Resumen Detallado.docx` |

> **Naturaleza del componente:** Cobranza Direccionada no es un canal de cara al cliente; es un componente
> habilitador que configura reglas en SmartVista y BPC para controlar el comportamiento de los canales
> (App, CAT, SIWEB) según el nivel de mora del titular. Impacta transversalmente a tres canales.

---

## Alcance Técnico

| Categoría | Descripción |
|-----------|-------------|
| Adecuaciones BPC | Configuración de reglas de cobranza en BPC Banking Technologies |
| Evolución modelo de datos | Cambios en el esquema SmartVista para soportar `agingPeriod` y CSTS |
| Construcción componentes SmartVista | Nuevos servicios/tablas en SmartVista para exponer estado de mora a canales |
| Integraciones | Cargas de datos (data ingestion), **no microservicios tradicionales** |

> **Importante:** Las "integraciones" de Cobranza son procesos de carga de datos, no APIs en tiempo real.
> Por esta razón tienen 0 registros en `r4_integrations` (inventario orientado a microservicios).
> El inventario de carga de datos de Cobranza está pendiente de documentar.

---

## Capabilities Impactadas

### CAP-COLLECTIONS-ENGINE — Motor de Reglas de Cobranza

| Campo | Valor |
|-------|-------|
| Capability ID | `CAP-COLLECTIONS-ENGINE` |
| Status | `partial` |
| Build status | `not_built` |
| User Stories pendientes | 37-50 (rango sin confirmar; working assumption: 45) |
| Bloqueante | RISK-UNITY-R06 (plan sin formalizar) |
| Componentes que la implementan | cobranza, smartvista, app, cat |

Notas: Construcción y Unit Testing planificados para fin de agosto – mediados de septiembre 2026.
El motor de CAP-COLLECTIONS-ENGINE es prerrequisito para CAP-COLLECTIONS-AGING.

### CAP-COLLECTIONS-AGING — Restricciones Visibles por Mora

| Campo | Valor |
|-------|-------|
| Capability ID | `CAP-COLLECTIONS-AGING` |
| Status | `partial` |
| Build status | `not_built` |
| SLO disponibilidad | 99.5% (mensual) |
| SLO latencia p95 | 5,000 ms |
| SLO tasa de error | 0.5% |

Define los niveles de restricción que los canales App y CAT aplican al titular según su `agingPeriod`:

| Nivel | Días de mora | Restricción aplicada |
|-------|-------------|----------------------|
| E1 | 0-30 días (0-1 mes) | Sin restricción — operación normal |
| E2 | 31-90 días (2-3 meses) | Restricción parcial — algunas operaciones bloqueadas |
| E3 | 91+ días (4 o más meses) | Bloqueo mayoritario — solo operaciones de pago permitidas |

El `agingPeriod` es expuesto por SmartVista en el endpoint `getInstantCreditStatement`
y consumido por App (HDU-APP-R4-17) y CAT (HDU-CAT-R4-10).

---

## User Stories Impactadas en Otros Tracks

Cobranza Direccionada no tiene User Stories propios en `hdu_catalog` — opera como habilitador.
Los siguientes User Stories de otros canales dependen de que Cobranza construya sus componentes primero:

| User Story ID | Canal | Narrativa | Capability | PreGame |
|--------|-------|-----------|-----------|---------|
| HDU-APP-R4-03 | App | Operar botones de acción por estatus CSTS de tarjeta | CAP-COLLECTIONS-AGING | partial |
| HDU-APP-R4-17 | App | Mostrar restricciones por mora (`agingPeriod E1/E2/E3`) en App | CAP-COLLECTIONS-AGING | partial |
| HDU-CAT-R4-10 | CAT | Gestionar opciones de autoservicio IVR por nivel de mora (`agingPeriod`) | CAP-COLLECTIONS-AGING | not_covered |

> **Dependencia crítica:** Los tres User Stories anteriores no pueden completarse en SIT sin que
> SmartVista exponga `agingPeriod` y `CSTS`, lo que depende de los componentes de Cobranza.

---

## Integraciones

| Campo | Valor |
|-------|-------|
| Integraciones en inventario R4 | 0 (no aplica inventario de microservicios) |
| Tipo de integración real | Cargas de datos (data ingestion) vía BPC |
| Inventario de cargas de datos | Pendiente de documentar |

> El inventario de integraciones R4 (`Inventario de Integraciones_HUs_ R4_v1.0.xlsx`) captura
> microservicios API/Batch entre sistemas. Las cargas de datos de Cobranza Direccionada son un
> proceso diferente (ingesta BPC → SmartVista) y requieren un artefacto separado.

---

## Timeline y Milestones

| Evento | Fecha | Status |
|--------|-------|--------|
| Sesión de análisis Cobranza R4 | 2026-08-06 | Completado |
| Formalización del plan de trabajo (RISK-R06) | 2026-07-30 | 🔴 VENCIDO |
| Cierre construcción / Unit Testing | 2026-09-15 (est.) | Pendiente |
| Inicio SIT (todos los componentes) | 2026-10-15 | En riesgo |
| **Pentest Cobranza** | 2026-11-15 al 2026-11-20 | 🔴 CONFLICTO CON SIT |
| Fin SIT / Code Freeze | 2026-12-15 | Pendiente |
| Go-Live Producto 4900 | 2027-01-15 | Pendiente |

### Conflicto Crítico de Calendario

El **Pentest de Cobranza** (15-20 noviembre 2026) coincide con el período activo de SIT
(oct–dic 2026). Durante el Pentest, el ambiente de Cobranza puede quedar congelado, bloqueando
las pruebas de integración de los tres canales dependientes (App, CAT, SIWEB).

**Opciones de mitigación a evaluar:**
- Adelantar el Pentest a octubre (antes de inicio SIT)
- Segmentar el ambiente: Pentest en un ambiente separado, SIT en productivo de pruebas
- Diferir las User Stories de Cobranza que requieran el ambiente congelado a una iteración posterior

---

## Riesgos del Componente

| Riesgo ID | Descripción | Due Date | Status | Owner |
|-----------|-------------|----------|--------|-------|
| RISK-UNITY-R06 | Plan de trabajo Cobranza sin formalizar — sin inventario detallado de User Stories ni cronograma por actividad | 2026-07-30 | 🔴 VENCIDO | Ma. Fernanda Barbosa (PMO) |
| MS-UNITY-004 | Pentest Cobranza 15-20 nov 2026 puede congelar el ambiente en pleno SIT | 2026-11-15 | 🔴 En riesgo | PMO Unity |

**Mitigación RISK-R06:** Validar con Marksey Sanvicente (BanCoppel accountable) el inventario
definitivo de User Stories y el cronograma de construcción. Objetivo: inventario consolidado antes de
fin de agosto 2026.

---

## Stakeholders

| Rol | Nombre | Empresa |
|-----|--------|---------|
| Accountable BanCoppel (Track Owner) | Marksey Sanvicente | BanCoppel |
| PMO Unity (gestión de riesgo R06) | Ma. Fernanda Barbosa | BanCoppel / PMO |
| Soporte tecnológico | BPC Banking Technologies | BPC |
| Proveedor delivery | Interno BanCoppel | BanCoppel |

---

## User Stories Inventory

| Campo | Valor |
|-------|-------|
| Filas en `user_stories_inventory` (cobranza) | 0 — pendiente de inventariar |
| Estimación working assumption | 45 User Stories (rango fuente: 37-50) |
| MoSCoW breakdown | Sin definir — pendiente sesión de priorización |

> El inventario de User Stories de Cobranza no está capturado en el brain v1.4.0.
> Requiere una sesión de análisis adicional con Marksey Sanvicente para descomponer
> las 45 User Stories en historias individuales con MoSCoW, complejidad y trazabilidad.

---

## Plan de Testing

| Tipo | Incluido | Status | Notas |
|------|---------|--------|-------|
| Unit Testing | Sí | Planificado (ago-sep 2026) | BanCoppel interno |
| SIT | Sí | Planificado (oct-dic 2026) | En riesgo por Pentest nov |
| UAT | Sí | Planificado | Firmante por confirmar |
| Pentest | Sí | 2026-11-15 al 2026-11-20 | Conflicto activo con SIT |

---

## Gaps Críticos

| Gap ID | Descripción | Impacto | Status |
|--------|-------------|---------|--------|
| GAP-COB-01 | Inventario de User Stories sin desglose individual (45 User Stories no desglosadas) | Sin trazabilidad de entrega por historia | 🔴 Abierto |
| GAP-COB-02 | Inventario de cargas de datos (integraciones BPC) no documentado | No se puede planificar el volumen real de trabajo de integración | 🔴 Abierto |
| GAP-COB-03 | 0 User Stories propios en `hdu_catalog` — sin visibilidad técnica detallada | 3 User Stories dependientes (APP-03, APP-17, CAT-10) sin prerrequisito claro | 🟡 Documentado |
| GAP-COB-04 | Plan de trabajo sin formalizar (RISK-R06 vencido) | Sin cronograma comprometido de construcción | 🔴 Vencido |
| GAP-COB-05 | MoSCoW de las 45 User Stories sin definir | No se pueden establecer compromisos de entrega parcial | 🔴 Abierto |

---

## Pendientes

- [ ] Sesión con Marksey Sanvicente: descomponer las 45 User Stories en historias individuales con MoSCoW
- [ ] Documentar inventario de cargas de datos BPC → SmartVista (separado del inventario de microservicios)
- [ ] Resolver conflicto de calendario Pentest (15-20 nov) vs SIT (oct-dic)
- [ ] Formalizar plan de trabajo con cronograma de construcción y UT (RISK-R06)
- [ ] Confirmar firmante UAT por parte de BanCoppel
- [ ] Actualizar `user_stories_inventory` en brain.db cuando se tenga el desglose de User Stories
- [ ] Confirmar si las cargas de datos BPC → SmartVista requieren integraciones adicionales hacia App/CAT

---

*Creado: 2026-08-20 · v1.0.0 · Fuente: brain.db v1.4.0 + sesión análisis 2026-08-06*
