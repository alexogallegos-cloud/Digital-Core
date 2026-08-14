# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Riesgos de Equivalencia

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Perfil de riesgo del dominio

| Dimensión | Valor | Nivel |
|-----------|-------|-------|
| Riesgo global | CRÍTICO | — |
| Wave de migración | Wave 4 | — |
| SPs en el dominio | 101 | — |
| SPs en callgraph | 5 | — |
| SPs aislados sin análisis previo | 96 | 🔴 CRÍTICO |
| SPs con tokens SINTÉTICOS | 93 | 🟠 ALTO |
| Ocurrencias de MONEY | `[DATO-REQUERIDO]` | — |
| Llamadas cross-DB salientes | 9 tablas en 4 bases | 🟠 ALTO |
| Equivalencia funcional requerida | ≥ 99.99% | 🔴 CRÍTICO — por encima del estándar AM |
| Reguladores que auditan este dominio | CNBV, SHCP, SAT, UIF | 🔴 CRÍTICO |

## R01 — Riesgo regulatorio: motor PLD auditable

**Nivel:** 🔴 CRÍTICO (máximo del proyecto)

El motor PLD de BanCoppel es el sistema más auditado por los reguladores en Informix. Cualquier diferencia de comportamiento entre el sistema legacy y el sistema target después del cutover puede constituir un incumplimiento de la CUB (CNBV) o de la LFPIORPI. La CNBV tiene facultad de imponer sanciones por millones de pesos por falla en el sistema de monitoreo PLD.

**Criterio go/no-go específico para D15:** equivalencia funcional ≥ 99.99% en todos los SPs regulatorios. Si el QA Lead detecta cualquier divergencia en reportes regulatorios, el cutover se detiene independientemente del progreso del proyecto.

**Mitigación:**
- Parallel-run mínimo de 3 meses (vs. 1 mes estándar en AM) antes del cutover definitivo.
- Comparación byte-a-byte de todos los archivos de reporte generados por el sistema legacy vs. el target.
- Sign-off del Área de Cumplimiento de BanCoppel antes de aprobar el cutover.
- Notificación previa a CNBV/SHCP antes del cutover (ver `20-cutover-plan.md`).

## R02 — Riesgo de cobertura: 96 SPs aislados no analizados en journeys

**Nivel:** 🔴 CRÍTICO

El 95% de los SPs del dominio no fueron capturados en los journeys del callgraph. Esto significa que una proporción significativa de la lógica PLD no está documentada en el knowledge base de los journeys previos. Los SPs aislados incluyen probablemente:

- Reportes regulatorios formales (CNBV, SHCP, SAT)
- Procesos de screening de listas (LIDE, OFAC, ONU)
- Lógica de generación de alertas de operaciones inusuales
- Procesos de mantenimiento de la lista LIDE interna

**Mitigación:**
- Análisis manual de cada uno de los 96 SPs aislados por el Área de Cumplimiento y el SME regulatorio CNBV.
- No iniciar BUILD hasta tener el 100% de los SPs categorizados como "regulatorio" o "utilitario".
- Estimación de esfuerzo adicional: 96 SPs × 2-4 horas/SP = 192-384 horas de análisis adicional.

## R03 — Riesgo financiero: tipo MONEY y redondeo IDE

**Nivel:** 🔴 CRÍTICO

La fórmula `vmMontoRecaudar = ROUND(vmMontoRecaudar - 0.01)` en `sp_acumulacionoperaciones` es un ajuste histórico explícito cuyo origen exacto no está documentado en el código. Este ajuste afecta directamente el monto reportado al SAT como recaudación IDE.

**Mitigación:**
- Validar con el Área de Cumplimiento si este ajuste está documentado en alguna circular o acuerdo con el SAT.
- Reproducir exactamente la fórmula en el target — no intentar "corregirla" sin sign-off del regulador.
- Generar ≥ 500 casos de prueba con valores de borde para la acumulación de operaciones.
- `[COMPLIANCE-SIGN-OFF-REQUIRED]`

## R04 — Riesgo de acoplamiento cross-DB: 4 bases de datos dependientes

**Nivel:** 🟠 ALTO

`bdilide` tiene dependencias de escritura hacia `bdinteg`, `bdicheq` y `bdicred`. En Informix estas escrituras son intra-proceso y transaccionales. En el target distribuido, una falla en cualquiera de estos dominios puede dejar inconsistente el registro PLD.

| Dependencia crítica | Riesgo |
|--------------------|--------|
| `ejecutor_diario` → UPDATE en `bdinteg`, `bdicred`, `bdicheq` | Si falla a mitad del batch, las fechas de proceso quedan inconsistentes entre dominios |
| `sp_acumulacionoperaciones` → INSERT en `bdinteg.sx_contproc` | El registro de control de proceso puede perderse si `bdinteg` no está disponible |
| Lectura de `si_cliente` desde `bdinteg` | El motor PLD necesita datos del cliente en tiempo real |

**Mitigación:**
- Diseñar patrón Saga para las escrituras cross-dominio del ejecutor diario.
- Implementar compensating transactions para los INSERTs en `sx_contproc`.
- Coordinar migración de `bdilide` con `bdinteg`, `bdicheq` y `bdicred` — no migrar en aislamiento.

## R05 — Riesgo de integridad de archivos regulatorios

**Nivel:** 🔴 CRÍTICO

Los SPs `sp_cargainformesat` y `sp_cargaresultadosat` ejecutan comandos shell del sistema operativo AIX (`sed`, `rm -rf`) directamente desde el SPL para manipular archivos de intercambio con el SAT. Esta arquitectura no tiene equivalente directo en el target AWS.

```sql
-- Fragmento real del código (sp_cargainformesat L87):
LET cSQL = "sed -e 's/EOF$//g' " || TRIM(cDirectorio) || TRIM(cNombreArchivo) || " > " || ...
```

**Mitigación:**
- Reemplazar los comandos shell con lógica equivalente en Java/Python dentro del microservicio target.
- Validar con el SAT que el formato del archivo generado por el nuevo sistema es idéntico byte-a-byte al del legacy.
- Los archivos de intercambio deben almacenarse en S3 con Object Lock para auditoría.
- `[COMPLIANCE-SIGN-OFF-REQUIRED]`

## R06 — Riesgo de retención de datos regulatorios

**Nivel:** 🔴 CRÍTICO

La LFPIORPI (Art. 19) exige conservar los registros PLD durante mínimo 10 años. La tabla `sl_movefec_his` es el archivo histórico del dominio. Su migración debe ser íntegra y verificable.

**Mitigación:**
- Plan de migración con verificación de registros históricos (recuento + hash por período).
- Almacenamiento en Aurora con backup en S3 Glacier para el archivo histórico (costo optimizado, retención garantizada).
- El cutover plan debe incluir verificación de integridad del histórico antes de apagar el legacy.

## R07 — Riesgo de tokens SINTÉTICOS: 93 SPs con lógica no verificada

**Nivel:** 🟠 ALTO

El 92% de los SPs analizados tienen tokens SINTÉTICOS (nombres de SP con componentes no reconocidos en el vocabulario del dominio). Esto indica que el análisis automático no pudo verificar completamente el propósito de estos SPs. Algunos pueden contener lógica regulatoria crítica maquillada bajo nombres opacos.

**Mitigación:**
- Revisión manual de los 93 SPs con tokens SINTÉTICOS por el SME de dominio (Área de Cumplimiento).
- Priorizar los SPs que acceden a tablas `sl_*` con operaciones INSERT/UPDATE sobre los de solo SELECT.

## R08 — Riesgo de versiones PBA: SPs de pruebas en producción

**Nivel:** 🟠 MEDIO

Se detectaron SPs con sufijo `_pba` (p. ej. `sp_actualizarfclide_pba`). El sufijo PBA fue confirmado como "SPs para Pruebas" por SME interno. Sin embargo, la presencia de tablas reales de `bdilide` en estos SPs indica que podrían ejecutarse contra datos de producción en ciertos contextos.

**Mitigación:**
- `[DATO-REQUERIDO]` — DBA Informix: confirmar si los SPs `_pba` tienen permisos de ejecución en el ambiente de producción.
- Si están activos en producción, deben migrarse junto con sus contrapartes.
- Si son solo para pruebas, documentar y excluir del scope de migración.

---
*Generado: Specialist — Informix SPL Analysis + SME Regulatorio CNBV · 2026-08-03*
