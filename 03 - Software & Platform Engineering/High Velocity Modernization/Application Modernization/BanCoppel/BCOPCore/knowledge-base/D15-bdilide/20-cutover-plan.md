# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Plan de Cutover

> **Componente:** BCOPCore · SPE-AM-001 · RELEASE Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Declaración de criticidad especial

> `[COMPLIANCE-SIGN-OFF-REQUIRED]` — El cutover de `bdilide` es el evento de mayor riesgo regulatorio de todo el proyecto BCOPCore. Requiere:
> 1. Aprobación formal del CAB estándar de BanCoppel.
> 2. Sign-off explícito del Director del Área de Cumplimiento de BanCoppel.
> 3. **Notificación previa a CNBV y SHCP** — ver sección "Notificación regulatoria" abajo.
> 4. Parallel-run de 3 meses completado y aprobado por QA Lead y Cumplimiento.
> 5. El cutover NO puede ejecutarse durante un período de reporte regulatorio activo.

## Restricciones de ventana de cutover

El cutover de `bdilide` está PROHIBIDO en las siguientes fechas:

| Período prohibido | Razón | Impacto |
|------------------|-------|---------|
| Día 1-10 del mes | Período de cierre y reporte del mes anterior a CNBV/SHCP | Conflicto con generación de reportes regulatorios activos |
| Días 15-20 del mes | Plazo de entrega de reporte de operaciones relevantes a SHCP (día 17) | Riesgo de interrupción del proceso de reporte en curso |
| Enero semana 1 | Cierre fiscal SAT + actualización de UMA | Conflicto con el procesamiento de exentos IDE del año nuevo |
| Diciembre semana 4 | Cierre de año + reportes anuales SAT | Múltiples procesos regulatorios activos |
| Mayo-junio | Período FATCA/CRS del SAT | Conflicto con reportes internacionales |
| Cualquier fecha en que haya una alerta PLD activa | Una alerta PLD activa implica un proceso de investigación en curso | El cutover no puede interrumpir una investigación activa |

**Ventana ideal:** semanas 2-3 de cualquier mes no listado arriba, en un día hábil de martes a jueves, iniciando a las 22:00 CDMX.

## Notificación regulatoria previa al cutover

> `[COMPLIANCE-SIGN-OFF-REQUIRED]` — Confirmar con el Área de Cumplimiento qué notificaciones son obligatorias vs. recomendadas.

| Regulador | Tipo de notificación | Anticipación requerida | Responsable |
|-----------|---------------------|----------------------|------------|
| CNBV | Aviso de cambio en sistema de monitoreo PLD | `[DATO-REQUERIDO]` — verificar si CUB Art. 164 aplica (aviso 60 días) | Área de Cumplimiento BanCoppel |
| SHCP/UIF | Aviso de cambio en sistema de reporte | `[DATO-REQUERIDO]` — consultar con Cumplimiento | Área de Cumplimiento BanCoppel |
| SAT | Notificación de cambio de plataforma de intercambio IDE | `[DATO-REQUERIDO]` | Área de Cumplimiento BanCoppel |
| Buró de Crédito | Aviso de cambio en sistema de consulta | `[DATO-REQUERIDO]` | Área de Cumplimiento + Legal |

## Parallel-run — 3 meses obligatorios

Durante el parallel-run, ambos sistemas deben ejecutar el motor PLD en paralelo y los resultados deben compararse:

| Semana | Actividad de validación |
|--------|------------------------|
| Semanas 1-4 (mes 1) | El target ejecuta el batch PLD en modo shadow — los resultados se comparan contra el legacy pero no tienen efecto real. Umbral: 0 diferencias aceptadas |
| Semanas 5-8 (mes 2) | El target comienza a procesar el 10% del tráfico transaccional (consultas LIDE) — comparación en tiempo real con el legacy. Umbral: 0 diferencias en decisiones LIDE |
| Semanas 9-12 (mes 3) | El target procesa el 50% del tráfico — comparación continua. Se inicia la generación de reportes regulatorios en el target en modo de validación |
| Fin del mes 3 | Go/no-go decision por QA Lead + Área de Cumplimiento. Si no hay diferencias en 3 meses: aprobación para cutover al 100% |

**Criterio de go/no-go:** cero diferencias en cualquier decisión de LIDE (libre/en_lide) y cero diferencias en los reportes regulatorios generados. No se acepta ninguna divergencia en este dominio.

## Runbook de cutover — paso a paso

### T-7 días: preparación final

```
□ Verificar que el CDC está activo y el lag de replicación es < 1 minuto
□ Confirmar que los archivos regulatorios del mes anterior fueron enviados exitosamente
□ Confirmar que no hay alertas PLD activas en investigación
□ Obtener firma del Director de Cumplimiento en el plan de cutover
□ Notificar a CNBV/SHCP (si aplica) con la fecha del cutover
□ Confirmar que no hay reportes regulatorios pendientes para el período actual
```

### T-48 horas: verificación previa

```
□ Ejecutar el batch PLD completo en el target en modo shadow
□ Comparar resultados byte-a-byte con el legacy
□ Verificar sl_parametros: vmMontLimite y viPorcaRecau tienen los valores correctos
□ Confirmar que sl_movefec_his está 100% migrado y verificado
□ Prueba de carga en el LideService: 1,000 consultas simultáneas < 50ms p99
□ Confirmar que los certificados de conexión con Buró de Crédito y SAT son válidos
□ Confirmar backups de Aurora actualizados (dentro de las últimas 2 horas)
```

### T-día del cutover (22:00 CDMX)

```
22:00 — INICIO VENTANA DE CUTOVER

22:00 □ Freeze de escrituras en bdilide Informix
        (Los sistemas D01, D02, D03 son notificados del inicio de la ventana)

22:05 □ Sincronización delta final: CDC captura los últimos cambios

22:30 □ Verificar que CDC lag = 0 (todas las tablas sincronizadas)

22:35 □ Ejecutar script de verificación de integridad en Aurora:
        - COUNT(*) de todas las tablas sl_* debe coincidir con Informix
        - Verificar sl_parametros: valores correctos

22:45 □ Cambiar AppConfig feature flag del LideService al 100% target
        - Monitor: primeras 100 consultas deben responder < 50ms

23:00 □ Activar PldBatchService: programar ejecutor_diario en EventBridge

23:30 □ Ejecutar ejecutor_diario en el target (primer batch real)
        - Monitor: verificar que actualiza si_fechas, sc_fechas, sd_fechas correctamente

00:00 □ Ejecutar sp_acumulacionoperaciones en el target (primer batch de acumulación real)
        - Monitor: comparar conteo de sl_retlide generados con el baseline del mes anterior

03:00 □ (Esperado) Fin de sp_acumulacionoperaciones
        - Verificar que sl_procesos muestra status exitoso
        - Verificar que conteo de sl_retlide es razonable

VENTANA DE ÉXITO: si todos los checks anteriores pasan, el cutover es exitoso
Informix bdilide puede ponerse en modo READ-ONLY (no apagar por 3 meses)
```

### Criterios de rollback automático

Si alguno de los siguientes eventos ocurre, el cutover se detiene inmediatamente:

```
□ ROLLBACK AUTOMÁTICO si:
  - Cualquier consulta LIDE retorna resultado diferente al legacy en el parallel-run
  - sp_acumulacionoperaciones retorna código de error (distinto de 000)
  - Diferencia en el conteo de sl_retlide > 0 registros
  - El batch no termina dentro de la ventana de ejecución esperada
  - Falla de conexión con Buró de Crédito o SAT después del cutover
  - Cualquier alerta CRÍTICA en CloudWatch durante la primera hora

Acción: AppConfig feature flag al 0% (100% tráfico al legacy) — < 5 minutos
Escalar a: SRE Lead + Domain Expert BanCoppel + Director de Cumplimiento
Notificar a: CNBV/SHCP (si ya fueron notificados del cutover)
```

## Post-cutover — obligaciones regulatorias inmediatas

```
T+1 día:
  □ Verificar que el reporte del día fue generado correctamente
  □ Comparar sl_retlide generado por el target vs. el legacy (debe ser idéntico)

T+7 días:
  □ Si es fecha de reporte mensual, el primer reporte regulatorio oficial debe
    generarse con el sistema target y ser revisado por Cumplimiento antes del envío

T+30 días:
  □ Primer reporte mensual completo generado y enviado al SHCP/CNBV
  □ Área de Cumplimiento firma la conformidad del primer mes de operación target

T+90 días:
  □ Apagar el legacy bdilide Informix (previa aprobación de Cumplimiento)
  □ Archivar los datos del legacy en S3 Glacier (retención 10 años)
```

## `[SME-PENDING]`

- [ ] Área de Cumplimiento: confirmar si CUB Art. 164 aplica y el plazo de notificación a CNBV.
- [ ] Confirmar con SHCP y SAT el procedimiento de notificación de cambio de plataforma.
- [ ] Definir el responsable del cutover (Incident Manager de BanCoppel + SRE Lead de Accenture).
- [ ] Confirmar que los sistemas D01, D02 y D03 tienen mecanismo de tolerancia a fallas durante la ventana de cutover.

---
*Generado: SRE & AIOps + SME Regulatorio CNBV + Core Banking Transformation · 2026-08-03*
