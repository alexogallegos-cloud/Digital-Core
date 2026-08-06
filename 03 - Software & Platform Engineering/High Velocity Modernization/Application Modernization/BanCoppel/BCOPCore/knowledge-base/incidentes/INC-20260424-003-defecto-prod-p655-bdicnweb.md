# INC-20260424-003 — Defectos PROD Activos en Componente P655 · Canal Digital Web (D01)

**ID:** INC-20260424-003  
**Fecha captura:** 2026-04-24  
**Portal:** [inc-003-d01-defecto-prod.html](../../portal/incidents/inc-003-d01-defecto-prod.html)  
**Sistemas afectados:** `bdicnweb` (D01) — Canal Digital Web BanCoppel  
**Severidad:** N5 (máxima) — 2 defectos activos en producción clasificados como BLOQUEANTE en el risk register  
**Fuentes analizadas:** `migration-risk-register.md` · runbook INC-D01-04 · risk register P655-R001/R002  
**Estado:** BLOQUEANTE — ninguna wave de D01 puede avanzar a DESIGN hasta resolución  
**Runbook origen:** INC-D01-04 en `knowledge-base/D01-bdicnweb/21-observability-runbook.md`

---

## 1. Síntesis del incidente

El componente P655 del dominio `bdicnweb` (Canal Digital Web) tiene **2 defectos activos en producción** clasificados como N5 en el risk register de migración. Estos defectos bloquean el avance a la fase DESIGN de la wave D01 — ningún trabajo de arquitectura target puede iniciarse hasta que los defectos tengan un plan de mitigación documentado y aprobado.

A diferencia de los demás incidentes del 2026-04-24 (que tienen causa raíz técnica confirmada), P655-R001 y P655-R002 tienen sus detalles técnicos **pendientes de sesión de validación** con el DBA IBM Informix y el equipo de Core Banking Transformation. La clasificación N5 proviene del análisis del risk register; el alcance de impacto por SP está sin mapear.

---

## 2. Estado del risk register

### 2.1 Defectos registrados

| Risk ID | Componente | Tipo | Estado | Severidad |
|---------|-----------|------|--------|-----------|
| P655-R001 | bdicnweb — P655 | DEFECTO-PROD | PENDIENTE sesión validación | **N5** |
| P655-R002 | bdicnweb — P655 | DEFECTO-PROD | PENDIENTE sesión validación | **N5** |

Categoría ambos: TAR (Target Architecture Risk) — los defectos en producción afectan la capacidad de diseñar una arquitectura target correcta sin conocer su impacto actual.

### 2.2 Regla de bloqueo

> **Regla del risk register:** ninguna wave del dominio D01 puede progresar más allá de DISCOVER mientras existan defectos N5 activos sin plan de mitigación aprobado. Los defectos P655-R001 y P655-R002 son BLOQUEANTES para el inicio de DESIGN de D01.

### 2.3 Detalles pendientes de identificar

Los siguientes elementos están sin resolver y son prerequisito para desbloquear la wave D01:

| Elemento | Estado |
|---------|--------|
| SPs afectados de bdicnweb | Pendiente sesión DBA IBM Informix |
| Impacto en producción actual (usuarios, transacciones) | Pendiente |
| Causa raíz técnica de cada defecto | Pendiente |
| Plan de mitigación pre-migración | Pendiente |
| Ventana de corrección en producción actual | Pendiente |

---

## 3. Contexto de riesgo

El dominio D01-bdicnweb es el Canal Digital Web de BanCoppel — el punto de entrada de todas las transacciones del canal web (consultas de cuenta, pagos, transferencias, solicitudes de crédito). Con 2 defectos activos N5 en producción, cualquier análisis de la arquitectura AS-IS de D01 tiene el riesgo de modelar un estado inestable como baseline.

La relación con los demás incidentes del 2026-04-24 es transversal: los errores ESB no documentados (INC-20260424-004/005/006), el problema de huellas biométricas (INC-20260424-007) y el ACEPTPORTA (INC-20260424-008) todos transitan por el Canal Digital Web antes de llegar a sus dominios respectivos.

---

## 4. Patrones de riesgo para la migración

### Patrón 1 — Defecto en producción como baseline del parallel-run
Si los defectos P655-R001/R002 no se corrigen antes del parallel-run, el comparator de equivalencia funcional tendrá dos opciones igualmente malas: (a) considerar el comportamiento defectuoso como "correcto" y marcar el fix en el target como "divergencia", o (b) ignorar el defecto y perder cobertura de equivalencia. Ninguna opción es aceptable. Los defectos deben corregirse antes del cutover a parallel-run.

### Patrón 2 — N5 sin detalles técnicos
Una clasificación N5 sin detalle de causa raíz es una señal de que el análisis del AS-IS está incompleto. Antes de diseñar el target de D01, el equipo necesita ejecutar la sesión de validación con DBA IBM Informix y documentar los hallazgos en este INC file.

---

## 5. Acciones requeridas

1. **Convocar sesión de validación** con DBA IBM Informix IDS y Core Banking Transformation SME.
2. Identificar los SPs afectados por P655-R001 y P655-R002.
3. Documentar la causa raíz técnica de cada defecto y actualizar este INC con los resultados.
4. Crear plan de mitigación aprobado → condición de desbloqueo para el avance a DESIGN de D01.
5. Actualizar el risk register (`migration-risk-register.md`) con los hallazgos.

---

*Fuentes: `migration-risk-register.md` P655-R001/R002 · runbook INC-D01-04.*  
*Creado: 2026-08-06 | BCOPCore Gemelo Cognitivo — DISCOVER Etapa 1*
