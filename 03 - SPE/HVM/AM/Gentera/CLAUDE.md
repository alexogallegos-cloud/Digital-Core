# Gentera — Proyecto Application Modernization SAP ABAP RE

> Instancia del solution L4 Application Modernization · Sub-offering HVM · Offering 03 S&PE · Zona: ★ Digital Core
> Specialist activo: [Specialist - SAP ABAP](../Fase%200%20-%20Discover/Specialist%20-%20SAP%20ABAP/CLAUDE.md)

```
┌─[★ Digital Core]────────────────────────────────────┐
│ Gentera · SPE-AM-002                                │
│ SAP ABAP RE · Microfinanzas MX · DISCOVER           │
└─────────────────────────────────────────────────────┘
```

---

## Contexto del Cliente

| Campo | Valor |
|---|---|
| Cliente | **Gentera** (holding de microfinanzas — Compartamos Banco + Compartamos Financiera Perú + AgroAmérica Guatemala) |
| Industria | Servicios financieros — microfinanzas / crédito grupal e individual |
| Regulación aplicable | CNBV · Banxico · CONDUSEF (México) · SBS (Perú) · SIB (Guatemala) |
| Geografía | México (principal) · Perú · Guatemala |
| Monedas | MXN · PEN · GTQ |
| Contacto / DM | `[DATO-REQUERIDO]` |
| Deal Stage | `[DATO-REQUERIDO]` S0 / S1 / S2 |

---

## Componente

| Campo | Valor |
|---|---|
| Component ID | `SPE-AM-002` |
| Nombre | Gentera SAP ABAP Reverse Engineering |
| Tipo | Application Modernization — Análisis RE (Fase DISCOVER) |
| Estado | `[STATE: ACTIVE]` |
| Sub-offering | High Velocity Modernization |
| Solution | Application Modernization |
| Specialist activo | [Specialist - SAP ABAP](../Fase%200%20-%20Discover/Specialist%20-%20SAP%20ABAP/CLAUDE.md) |
| Fecha de inicio | 2026-07-16 |

---

## Landscape SAP — Lo Que Sabemos

| Aspecto | Conocido | Por Confirmar |
|---|---|---|
| Producto SAP | `[DATO-REQUERIDO]` ECC 6.0 / S/4HANA | Confirmar versión exacta (SMSY) |
| Base de datos | `[DATO-REQUERIDO]` Oracle / HANA / MaxDB | Confirmar en SM21 / DBACOCKPIT |
| Módulos activos | `[DATO-REQUERIDO]` FI · CO · HR · MM (típico microfinanzas) | Confirmar lista completa |
| Objetivo de modernización | `[DATO-REQUERIDO]` Migración S/4HANA / reemplazo SAP / análisis previo | Confirmar en primera reunión |
| Volumen de customización | `[DATO-REQUERIDO]` — cantidad de objetos Z/Y | Etapa 0 lo revelará |
| Acceso al sistema | `[DATO-REQUERIDO]` — RFC read-only / GUI / export | Confirmar protocolo de acceso |
| Landscape (DEV/QA/PROD) | `[DATO-REQUERIDO]` | Confirmar con Basis |

**Hipótesis de contexto de negocio:** Gentera opera modelo de microfinanzas basado en crédito grupal (metodología Grameen adaptada) — el dominio de crédito, cobranza de grupo, ciclos de crédito y cálculo de intereses en cartera masiva es probablemente donde vive la mayor parte del código Z custom con lógica de negocio crítica.

---

## Decisión 7R — Estado Inicial

`[DATO-REQUERIDO]` — La decisión 7R por dominio se produce al final de la Etapa 4 del Specialist SAP ABAP. Requiere completar las 5 Etapas de análisis.

Hipótesis inicial (actualizar con evidencia de las Etapas):

| Dominio probable | Hipótesis 7R | Fundamento |
|---|---|---|
| FI Contabilidad estándar | Replatform (S/4HANA) | Funcionalidad estándar SAP bien cubierta |
| Lógica custom de microfinanzas (crédito grupal, ciclos) | Refactor o Replace | Alta probabilidad de Z-code específico del modelo de negocio |
| HR/Nómina | Replatform (S/4HANA o SuccessFactors) | HR suele migrar a cloud en S/4HANA roadmap |
| Interfaces con core bancario / CNBV | Refactor | Regulatorio — alta sensibilidad |

---

## Estado Actual y Plan de Trabajo

### Fase: DISCOVER · Etapa: 0 (Setup & Inventory) — pendiente de iniciar

**Próximos pasos inmediatos:**

1. Confirmar información faltante (`[DATO-REQUERIDO]` en tabla de Landscape) con Basis de Gentera.
2. Solicitar los insumos del Paso 0.1 del Specialist SAP ABAP.
3. Ejecutar Etapa 0 — producir inventario maestro de objetos Z/Y.
4. Revisar inventario con SME de negocio de Gentera para confirmar módulos críticos.

**DoR para comenzar Etapa 1:**
- [ ] Acceso read-only confirmado (TADIR, TRDIR, TRDIRT, TFDIR, SXC_EXIT, DD02L, DD03L)
- [ ] Versión SAP confirmada
- [ ] Lista de módulos activos confirmada
- [ ] Objetivo de modernización (S/4HANA migration vs. replace) acordado con sponsor

---

## Modelo de Coexistencia — Por Definir

`[DATO-REQUERIDO]` — Se define en el ADR-SPE-AM-002 después del assessment 7R (Etapa 4).

Opciones relevantes para SAP:
- **Strangler-Fig** (si se reemplazan módulos SAP con microservicios): APIs nuevas en paralelo → desviar tráfico gradualmente por dominio.
- **Greenfield S/4HANA** (brownfield migration): upgrade in-place con remediación de Simplification Items — no hay coexistencia larga, la estrategia es diferente.
- **Bluefield / Selective Data Migration**: combina elementos de brownfield y greenfield — copia selectiva de datos, objeto por objeto.

---

## ADRs del Proyecto (pendientes de crear)

- `ADR-SPE-AM-002-001`: Decisión 7R por dominio funcional Gentera SAP — después de Etapa 4.
- `ADR-SPE-AM-002-002`: Patrón de coexistencia / estrategia de migración SAP — después de decisión 7R.
- `ADR-SPE-AM-002-003`: Estrategia de datos (bulk migration · CDC · coexistencia de esquema) — después de Etapa 2.
- `ADR-SPE-AM-002-004`: Target runtime por dominio (microservicio · S/4HANA cloud · SaaS) — después de 7R.

---

## Handoff a SMEs

| Fase | SME | Estado |
|---|---|---|
| DISCOVER (RE execution) | Specialist - SAP ABAP (este proyecto) | Activo |
| DESIGN (target architecture) | Software Engineering SME · TS&T (si architectural decision mayor) | Pendiente |
| BUILD (microservicios target) | Software Engineering SME | Pendiente |
| TEST (equivalence) | Code Quality Assessment + Equivalence Testing SME (HVM-wide) | Pendiente |

---

## DoD Gate — Salida de DISCOVER

- [ ] Inventario completo de objetos Z/Y (Etapa 0).
- [ ] Call graph + mapa de BADís activos (Etapa 1).
- [ ] Data dictionary Z-tables + catálogo de tipos con `[RIESGO-EQUIVALENCIA]` (Etapa 2).
- [ ] Catálogo de reglas de negocio ≥ 30 reglas (Etapa 3).
- [ ] Dominios funcionales + wave map + S/4HANA readiness (Etapa 4).
- [ ] Decisión 7R por dominio firmada por arquitecto + sponsor Gentera.
- [ ] Patrón de coexistencia seleccionado como ADR-SPE-AM-002-002.
- [ ] DoR completa para DESIGN firmada.

---

*Última actualización: 2026-07-16 · v0.1 · Creación del proyecto — Gentera SAP ABAP RE · SPE-AM-002 · Fase DISCOVER Etapa 0 pendiente de iniciar.*