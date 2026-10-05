# DT — Impacto en Sistemas Santander (CAN)
> **Proyecto:** CAN · Santander México
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Mapea qué sistemas de Santander México están en scope de la normativa CAN.
Identifica las capacidades requeridas vs. las existentes en `loans`, `core-banking`
y `payments-engine`. Este es el análisis **SANTANDER-ESPECÍFICO** del proyecto CAN.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Industry Banking | Validación de productos de nómina en scope CAN |
| Core Banking Transformation | Análisis de capacidades del core bancario Santander |
| Industry Payments → SPEI | OBL-006 (SPEI en refinanciamiento) + OBL-009 (Clave Básica Estandarizada) |
| Software Engineering | Arquitectura técnica de `loans` y `core-banking` |

## Diferencia vs. BanCoppel

| Dimensión | BanCoppel | Santander |
|-----------|-----------|-----------|
| Sistema de nómina | `bdiadminnomina` (Informix SPL — CONOCIDO) | `loans` + `core-banking` (SCAFFOLD — por confirmar) |
| Lenguaje/stack | Informix SPL · COBOL-like | Por confirmar (Java probable) |
| Análisis técnico | BCOPBrain queries sobre SPs conocidos | Requiere discovery del sistema `loans` |
| Mecanismo CTM | Control-M orquesta batch nómina | Por confirmar (scheduler desconocido) |

## Sistemas en Scope (Santander)

| Sistema | Obligaciones CAN que impactan |
|---------|-------------------------------|
| `loans` | OBL-001 al OBL-023 (scope completo — módulo de crédito) |
| `core-banking` | OBL-003 (cuenta domicilio), OBL-016 (prelación cargos), OBL-019 (saldo) |
| `payments-engine` | OBL-006 (SPEI refinanciamiento), OBL-009 (Clave Básica) |
| `banxico-spei` | OBL-006, OBL-009, OBL-023 (timing ≤ 17:00 DHB) |
| `supermovil` / `santander-online` | OBL-014 (disclosure al acreditado), OBL-016 (consulta prelación) |
| `cnbv-reporting` | OBL-020, OBL-021, OBL-022 (reportes regulatorios) |
| `call-center` | Art. 81 Bis 1 (atención portabilidad nómina) |

## Preguntas de Discovery

Para completar este DT se requiere acceso a:

1. **¿Cuál es el sistema `loans` de Santander?** — nombre real, stack, proveedor
2. **¿Cómo se procesa la deducción de nómina?** — ¿por CECOBAN domiciliación, deducción directa, o SPEI?
3. **¿Existe un módulo de prelación de cargos?** — OBL-016 requiere orden configurable
4. **¿Hay capacidades de portabilidad de domicilio?** — Art. 63 Bis 3 Mecanismo CAN
5. **¿Cómo se genera la Clave Básica Estandarizada?** — OBL-009

## Metodología

1. Cargar obligaciones de dt-normativa-can
2. Entrevistar al equipo técnico de Santander (loans, core, pagos)
3. Mapear cada obligación → sistema → capacidad existente / faltante
4. Documentar evidencia de cumplimiento parcial o total
5. Producir la lista de capacidades que alimenta dt-brecha-compliance

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Sistemas en scope | `knowledge-base/rules/sistemas-en-scope-can.md` |
| Capacidades existentes por obligación | `knowledge-base/rules/capacidades-existentes-can.md` |
| Capacidades faltantes (input para brecha) | `knowledge-base/rules/capacidades-faltantes-can.md` |

## Dependencias

- `[DEPENDS-ON: dt-normativa-can]` — obligaciones catalogadas
- `[DATO-REQUERIDO]` — Discovery técnico de `systems/core/loans` y `systems/core/core-banking`

*v0.1.0 · 2026-09-17*
