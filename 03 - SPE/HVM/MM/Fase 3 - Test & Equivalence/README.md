# Fase 3 — Test & Equivalence Framework
> Carpeta-puntero · Mainframe Modernization · HVM · 03 S&PE

```
┌─ CARPETA-PUNTERO ──────────────────────────────────────────┐
│ Esta fase NO tiene specialist local en Digital Core.        │
│ La ejecutan dos SMEs externos en coordinación.              │
└─────────────────────────────────────────────────────────────┘
```

## Quiénes ejecutan esta fase

| SME | Rol en la fase |
|---|---|
| `SME/Technology/Software Engineering/Specialist - Equivalence Testing/` | Golden master framework · comparator · métricas de drift · DoD-SPE-MM-01 ≥ 99.99% |
| `SME/Technology/Data & ML/Specialist - Test Data Management/` | Dataset de regresión (6 meses producción) · anonimización · versionado de datos de prueba |

Ambos SMEs deben trabajar en coordinación: Test Data Management provee el dataset; Equivalence Testing lo consume para construir el comparator.

## Objetivo de la fase

Construir el framework de equivalencia funcional que permite demostrar, de forma cuantificable y auditada, que el sistema moderno produce los mismos resultados que el sistema legacy para el mismo conjunto de entradas.

**`[CRÍTICO]` Para banca CNBV: la equivalencia mínima es ≥ 99.99% (DoD-SPE-MM-01).** Una divergencia de un centavo en un asiento contable = error de auditoría. El framework debe ser capaz de detectar divergencias en aritmética packed-decimal, rounding de tasas, y manejo de fechas juliano/Gregoriano.

## Prerequisitos de entrada

- `[ARTEFACTO]` Data Lineage Map v1.0 (Etapa 2 del RE) — qué datos se leen/escriben por programa
- `[ARTEFACTO]` Especificaciones Funcionales (Etapa 3 del RE) — qué hace cada programa con los datos
- `[ARTEFACTO]` regulatory-map (Fase 2) — qué reglas son regulatorias (mayor rigor de equivalencia)
- Acceso a logs de producción del sistema legacy (mínimo 6 meses de transacciones)
- Autorización del banco para extraer y anonimizar datos de producción

## Outputs canónicos

| Artefacto | Descripción |
|---|---|
| `test-dataset-{sistema}-v{N}.md` | Inventario del dataset de regresión: períodos cubiertos, volumen, estratificación por tipo de movimiento |
| `equivalence-framework-{sistema}.md` | Arquitectura del comparator: qué se compara, cómo, métricas de drift, thresholds de alerta |
| `golden-master-spec-{sistema}.md` | Especificación del golden master: outputs esperados del legacy para cada subset del dataset |
| `packed-decimal-test-plan-{sistema}.md` | Plan específico para aritmética financiera: casos de borde en COMP-3 → BigDecimal |

## Packet `[INVOKE]` — Equivalence Testing

```
[INVOKE: SME/Technology/Software Engineering/Specialist - Equivalence Testing/]
COMPONENTE      : SPE-MM-{NNN} — {nombre del sistema}
EQUIVALENCIA    : DoD-SPE-MM-01 ≥ 99.99% — banca CNBV reconciliación contable
STACK-LEGACY    : Unisys ClearPath MCP · COBOL · DMSII · aritmética COMP-3
STACK-TARGET    : Java 21 + Spring Boot · PostgreSQL · BigDecimal
RIESGO-CRITICO  : Packed decimal rounding · fechas julianas → java.time · saldos múltiples
INSUMOS         : Data Lineage Map · Specs Funcionales · regulatory-map · dataset de regresión
DELIVERABLE     : equivalence-framework + golden-master-spec + packed-decimal-test-plan
```

## Packet `[INVOKE]` — Test Data Management

```
[INVOKE: SME/Technology/Data & ML/Specialist - Test Data Management/]
COMPONENTE      : SPE-MM-{NNN} — {nombre del sistema}
DATOS-FUENTE    : DMSII {schemas: CAPTACION · BD04TARJETAS · ...} + logs SUMLOG 6 meses
RESTRICCIONES   : PII bancario · datos de producción · CNBV retención 10 años
ANONIMIZACION   : requerida para ambiente de pruebas · preservar distribución estadística
VOLUMEN-ESTIMADO: {N} transacciones · {N} cuentas · período {fechas}
DELIVERABLE     : test-dataset (inventario + acceso) + política de versionado de datos
```

## Posición en el ciclo metodológico

```
Fase 2 (Regulatory) → FASE 3 TEST & EQUIVALENCE → Fase DESIGN → BUILD → parallel-run

                              ↓
                    Framework construido ANTES de BUILD
                    Parallel-run = activación del comparator
                    en producción shadow durante ≥ 3 meses
```

*Última actualización: 2026-06-30 · v1.0 · Fase creada como carpeta-puntero per REORG de fases MM.*