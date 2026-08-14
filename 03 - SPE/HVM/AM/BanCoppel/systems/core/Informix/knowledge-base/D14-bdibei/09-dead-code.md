# D14 · Banca Electrónica Institucional (BEI) — Código Muerto y SPs Aislados

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático de dead code)
- Specialist — Code Quality Assessment (ISO 5055 — decisión de migrar o retirar)
- Domain Expert — BanCoppel (validación funcional de SPs candidatos a retiro)
- DBA — IBM Informix IDS (verificación de uso real en producción — Etapa 2)

> `[SME-PENDING]` = requiere validación del Domain Expert antes de clasificar como dead code definitivo.
---

## Contexto — La anomalía de los SPs aislados

El dominio `bdibei` presenta la situación más inusual del proyecto Informix:

| Métrica | Valor | Comparación con promedio Informix |
|---------|-------|----------------------------------|
| SPs totales | 336 | Alto |
| SPs en callgraph (observados en logs) | 42 | 12.5% del total |
| SPs aislados (no observados) | 294 | **87.5% del total** — anomalía |
| SPs con propósito verificado | 248 | 73.8% |
| SPs con propósito parcial | 86 | 25.6% |
| SPs NO_VERIFICABLE | 2 | 0.6% |
| SPs con tokens sintéticos | 240 | 71.4% |

Esta anomalía puede explicarse por alguna de estas causas (no excluyentes):

1. **Funcionalidad batch infrecuente:** los jobs de nómina solo se ejecutan quincenalmente. Los logs del 2026-04-24 pueden no haber capturado el día de ejecución del batch.
2. **Funcionalidad administrativa interna:** SPs de gestión de convenios, mantenimiento de catálogos, reportes regulatorios — usados por operadores BEI, no por canales digitales masivos.
3. **Dead code real:** versiones anteriores de procesos BEI que quedaron en el esquema sin ser eliminadas.
4. **Funcionalidad estacional:** procesos de cierre anual, auditoría CNBV, reportes de fin de año.

**Implicación para la migración:** NO asumir que los 294 SPs aislados son dead code. Clasificar primero con Domain Expert, luego aplicar ISO 5055.

---

## Clasificación de candidatos a dead code (análisis preliminar)

### Grupo A — Candidatos de alta probabilidad a dead code

Estos SPs tienen características que sugieren código inactivo o deprecado:

| Patrón de nombre | Ejemplo | Razón de sospecha |
|-----------------|---------|------------------|
| `*_old`, `*_bkp`, `*_backup` | `[DATO-REQUERIDO]` | Nombres explícitos de backup |
| `*_v1`, `*_anterior` | `[DATO-REQUERIDO]` | Versiones previas sin remover |
| `*_test`, `*_prueba` | `[DATO-REQUERIDO]` | SPs de desarrollo dejados en producción |
| LOC ≤ 9 sin DML | `desbloque` (9 LOC, no verificable) | SP minimal sin evidencia de uso |

> **Nota sobre `desbloque`:** con 9 LOC, sin parámetros declarados y `NO_VERIFICABLE`, es el candidato más claro a dead code o wrapper trivial. Sin embargo, el nombre sugiere una función operacional crítica ("desbloqueo de cuenta/convenio"). Requiere validación con Domain Expert antes de catalogar como dead code.

---

### Grupo B — SPs de batch que parecen aislados pero son activos

Estos SPs probablemente son activos pero no aparecen en los logs del 2026-04-24 porque sus ventanas de ejecución son quincenal o mensual:

| Patrón de nombre probable | Proceso | Frecuencia esperada |
|--------------------------|---------|-------------------|
| `*_nomina*`, `*_dispersion*` | Batch de nómina / dispersión quincenal | 2 veces/mes |
| `*_cierre*`, `*_concilia*` | Conciliación y cierre diario BEI | Diario (nocturno) |
| `*_reporte*` | Reportes regulatorios para CNBV | Mensual |
| `*_comision*` | Cálculo de comisiones | Mensual o quincenal |
| `*_convenio*`, `*_empresa*` | Gestión de convenios empresa | Bajo volumen, continuo |

> **Estos SPs son críticos para la migración aunque no aparezcan en logs de un día de producción.**

---

### Grupo C — SPs no verificables

| SP | LOC | Razón de no verificabilidad |
|----|-----|---------------------------|
| `desbloque` | 9 | Sin parámetros, sin evidencia DML, sin logs |
| `[DATO-REQUERIDO]` | — | Segundo SP NO_VERIFICABLE de sp-specs |

---

## Proceso de clasificación recomendado (Etapa 2)

```
Para cada uno de los 294 SPs aislados:

1. ANÁLISIS ESTÁTICO (Specialist SPL Analysis):
   a. ¿Tiene DML? (SELECT/INSERT/UPDATE/DELETE) → si NO → candidato dead code
   b. ¿Tiene cross-DB calls? → si SÍ → probablemente activo
   c. ¿Nombre sugiere batch/nomina/dispersion/cierre? → si SÍ → probablemente activo batch

2. ANÁLISIS DE NOMBRE (Domain Expert BanCoppel):
   a. ¿Reconoce el proceso de negocio? → si SÍ → activo
   b. ¿Es una versión anterior de otro SP? → si SÍ → candidato a deprecar

3. ANÁLISIS DE USO EN PRODUCCIÓN (DBA Informix):
   a. ¿Aparece en logs históricos más allá del 2026-04-24?
   b. ¿Tiene estadísticas en sysmaster?
   
4. DECISIÓN FINAL:
   - MIGRAR: SP activo → incluir en scope BUILD
   - RETIRAR: Dead code confirmado → documentar y no migrar (retiro formal post-cutover)
   - CONDICIONAL: SP de función desconocida → migrar como precaución con flag de monitoreo
```

---

## Métricas de tokens sintéticos

Un token "sintético" en el análisis de sp-specs significa que el término en el nombre del SP no tiene correspondencia en el vocabulario verificado del dominio BEI. 240 de 336 SPs (71.4%) tienen al menos un token sintético.

**Interpretación:** no implica necesariamente dead code — puede ser vocabulario interno de BanCoppel no capturado en el vocabulario Capa 1. Requiere sesión con Domain Expert para completar el vocabulario con los términos BEI.

**Acción:** enriquecer el vocabulario BEI con los términos detectados como sintéticos antes de concluir la clasificación de dead code.

---

## Herramienta de verificación DBA

Para confirmar si un SP ha sido llamado recientemente en producción:

```sql
-- En sysmaster — historial de ejecución (si IDS tiene audit activado):
SELECT st.tabname, sm.sqlerr
FROM sysmaster:sysmtables sm, sysmaster:systabnames st
WHERE sm.tableid = st.tableid;

-- Alternativa: revisar el plan de ejecución de los jobs conocidos
-- y verificar si el SP aparece en algún batch job del scheduler AIX
```

---

## Tabla resumen de decisiones (a completar en Etapa 2)

| SP | LOC | DML | Cross-DB | Domain Expert | Clasificación | Acción |
|----|-----|-----|---------|--------------|--------------|--------|
| `desbloque` | 9 | No detectado | No | `[SME-PENDING]` | `[SME-PENDING]` | — |
| `getrandomcode` | 70 | systables (entropía) | No | Activo (OTP) | ACTIVO | Migrar (reemplazar LCG) |
| 292 SPs restantes | — | — | — | `[SME-PENDING]` | `[SME-PENDING]` | — |

> **Total estimado de dead code real:** `[SME-PENDING]`. La experiencia en dominios similares sugiere 10-20% del total (30-60 SPs). Los 240-260 restantes serán activos de uso infrecuente.

---
*Generado por: Specialist — Informix SPL Analysis + Specialist — Code Quality Assessment · 2026-08-03 · Fuente: sp-specs-bdibei.md (336 SPs analizados) + análisis de anomalía de SPs aislados*
