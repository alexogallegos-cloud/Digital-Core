# Runbook de Observabilidad — D10 bdisuc (Sucursales)

| Campo | Valor |
|---|---|
| Dominio | D10 — bdisuc |
| Nombre funcional | Sucursales |
| Nivel de riesgo | ALTO |
| Wave de migración | Wave 3 |
| Total SPs | 37 |
| LOC totales | 37,901 |
| Instrucciones MONEY | 1,455 |
| Cross-DB edges | 40 |
| God procedures | `sp_consultadatospiezas_bym2` (2,164 LOC, 376 callers), `sp_tipo_servicio_etv2` (1,859 LOC, 82 callers) |
| Versión runbook | 1.0 |
| Última revisión | 2026-07-31 |

> **Nota de verificación:** la lógica interna de `sp_consultadatospiezas_bym2` y `sp_tipo_servicio_etv2` debe validarse en `BCOPCore/source/bdisuc/` antes de confirmar comportamiento bajo carga o ante modificaciones. Los 376 callers de `sp_consultadatospiezas_bym2` representan el mayor fan-in de este dominio y cualquier cambio en su signatura tiene impacto sistémico.

---

## 1. Rol funcional

bdisuc es el dominio de sucursales del core bancario BanCoppel. Con 37 SPs, 37,901 LOC y 1,455 instrucciones MONEY, concentra toda la lógica operativa de caja, POS y cierre de sucursal. Sus dos God procedures son los puntos de mayor riesgo operativo: `sp_consultadatospiezas_bym2` actúa como lookup centralizado de catálogos de piezas utilizado por todas las operaciones de sucursal (376 callers), mientras que `sp_tipo_servicio_etv2` clasifica el tipo de transacción para enrutamiento (82 callers). El pase a contabilidad se realiza vía 11 cross-DB edges hacia bdicont (D12), lo que hace que el cierre de caja dependa de la disponibilidad del dominio contable.

---

## 2. Arquitectura de observabilidad

### 2.1 Namespace de métricas

```
bancoppel.bdisuc.sp.invocations                      — invocaciones totales (37 SPs)
bancoppel.bdisuc.sp.errors                           — errores por SP
bancoppel.bdisuc.sp.duration_ms                      — latencia de ejecución por SP
bancoppel.bdisuc.godproc.consultadatospiezas.calls   — invocaciones de sp_consultadatospiezas_bym2
bancoppel.bdisuc.godproc.consultadatospiezas.errors  — errores de sp_consultadatospiezas_bym2
bancoppel.bdisuc.godproc.tiposervicio.calls          — invocaciones de sp_tipo_servicio_etv2
bancoppel.bdisuc.godproc.tiposervicio.errors         — errores de sp_tipo_servicio_etv2
bancoppel.bdisuc.crossdb.bdinteg.calls               — llamadas cross-DB a bdinteg
bancoppel.bdisuc.crossdb.bdicont.calls               — llamadas cross-DB a bdicont
bancoppel.bdisuc.caja.cierre.success                 — cierres de caja exitosos
bancoppel.bdisuc.caja.cierre.failed                  — cierres de caja fallidos
```

### 2.2 Dependencias cross-DB

| Base de datos destino | Edges | Prioridad de monitoreo |
|---|---|---|
| bdinteg | 27 | ALTA — hub de integración; 67.5% del total de cross-DB edges de este dominio |
| bdicont | 11 | CRITICA — cierre de caja depende de contabilidad; falla = caja no cierra |
| **Total** | **40** | |

---

## 3. God Procedures — perfil de riesgo

### sp_consultadatospiezas_bym2

| Atributo | Valor |
|---|---|
| LOC | 2,164 |
| Callers conocidos | 376 (mayor fan-in del dominio) |
| Función | Lookup centralizado de catálogos de piezas para operaciones de sucursal |
| Riesgo | CRITICO — su caída bloquea POS y caja en todas las sucursales |

### sp_tipo_servicio_etv2

| Atributo | Valor |
|---|---|
| LOC | 1,859 |
| Callers conocidos | 82 |
| Función | Clasificación de tipo de transacción para enrutamiento |
| Riesgo | ALTO — su caída impide que sucursales clasifiquen transacciones |

---

## 4. Umbrales de alarma

| Métrica | Umbral WARNING | Umbral CRITICAL | Acción inmediata |
|---|---|---|---|
| Lambda errors | > 0.1% en ventana de 5 min | > 1% en ventana de 5 min | Escalar a SRE on-call |
| Aurora CPU | > 80% | > 90% | Revisar query plan de God procedures |
| MSK consumer lag | > 10,000 mensajes | > 50,000 mensajes | Verificar throughput de caja |
| `sp_consultadatospiezas_bym2` error rate | > 0.1% | > 0.5% | Activar INC-D10-01 inmediatamente |
| `sp_tipo_servicio_etv2` error rate | > 0.5% | > 2% | Activar INC-D10-02 |
| Cross-DB bdicont latencia p99 | > 500 ms | > 2,000 ms | Activar INC-D10-03 |
| Cierres de caja fallidos | > 0 en ventana de 30 min | > 3 en ventana de 30 min | Escalar a SRE + DBA |

---

## 5. Patrones de carga (basados en logs de producción)

| Ventana | Tipo | Comportamiento esperado |
|---|---|---|
| 10:00–14:00 CDMX | Peak | Volumen máximo de operaciones de sucursal; `sp_consultadatospiezas_bym2` recibe la carga más alta — monitorear latencia p99 en este bloque |
| 02:00–06:00 CDMX | Off-peak | Tráfico mínimo de sucursales; ventana ideal para mantenimiento de God procedures con bajo impacto |
| 22:00–02:00 CDMX | Batch window | Procesamiento de cierre de caja; los 11 cross-DB a bdicont deben estar disponibles durante todo este bloque; un fallo en bdicont después de las 22:00 es un incidente de severidad alta |

---

## 6. Incidentes operativos

---

### INC-D10-01 — Consulta de piezas caída: sp_consultadatospiezas_bym2 falla

**Impacto:** con 376 callers, la caída de este SP es equivalente a la caída del dominio completo de sucursales. Todas las operaciones de POS y caja que requieren consultar catálogos de piezas quedan bloqueadas. Este es el incidente de mayor impacto operativo en D10.

**Síntomas:**
- `bancoppel.bdisuc.godproc.consultadatospiezas.errors` supera umbral CRITICAL
- Múltiples SPs de bdisuc generan errores en cascada al no obtener respuesta del lookup
- Reportes de POS inoperables en red de sucursales

**Diagnóstico con brain.py:**

```bash
# Paso 1: confirmar el estado del SP y su posición en el grafo de dependencias
python BCOPCore/digital-brain/brain.py sp "sp_consultadatospiezas_bym2" --show-body --show-callers --show-callees

# Paso 2: identificar los 376 callers para dimensionar el impacto
python BCOPCore/digital-brain/brain.py edges --target sp_consultadatospiezas_bym2 --direction inbound --count

# Paso 3: verificar si la falla es aislada al SP o se extiende a bdisuc completo
python BCOPCore/digital-brain/brain.py query "bdisuc health status godproc"
```

**Resolución:**

1. Verificar en el servidor AIX si la instancia Informix de bdisuc tiene sesiones bloqueantes sobre el objeto que usa `sp_consultadatospiezas_bym2`. Usar `onstat -g ses` y `onstat -g loc`.
2. Si el SP tiene un lock prolongado, identificar la sesión origen con autorización del DBA Informix BanCoppel antes de forzar kill.
3. Si el error es de tipo "routine not found" o "out of memory", escalar inmediatamente al DBA; puede requerir recompilación del SP.
4. Una vez restaurado, confirmar que `bancoppel.bdisuc.godproc.consultadatospiezas.calls` vuelve a valores normales y que los errores en cascada de los otros SPs se detienen.
5. Notificar a red de sucursales y al equipo de POS la restauración del servicio.

**RTO objetivo:** [SME-PENDING]

---

### INC-D10-02 — Tipo de servicio indisponible: sp_tipo_servicio_etv2 falla

**Impacto:** 82 callers no pueden clasificar el tipo de transacción. Las sucursales no pueden enrutar operaciones correctamente, lo que puede generar transacciones sin clasificar o rechazadas.

**Síntomas:**
- `bancoppel.bdisuc.godproc.tiposervicio.errors` supera umbral CRITICAL
- Transacciones quedan en estado indeterminado sin tipo asignado
- Posibles rechazos de operaciones en POS por falta de clasificación

**Diagnóstico con brain.py:**

```bash
# Paso 1: revisar el SP y sus dependencias de datos
python BCOPCore/digital-brain/brain.py sp "sp_tipo_servicio_etv2" --show-body --show-callers --show-callees

# Paso 2: verificar si hay dependencia de tablas de catálogo que pueden estar corruptas o bloqueadas
python BCOPCore/digital-brain/brain.py query "sp_tipo_servicio_etv2 tables catalog dependencies"

# Paso 3: correlacionar con otros incidentes activos en bdisuc
python BCOPCore/digital-brain/brain.py query "bdisuc active incidents concurrent errors"
```

**Resolución:**

1. Revisar el log de errores de Informix en bdisuc para el SP. Un error de acceso a tabla de catálogo es el origen más común según el análisis estático.
2. Verificar si las tablas de catálogo de tipo de servicio tienen registros vigentes; una tabla de catálogo vacía o con datos corruptos puede causar este incidente.
3. Si el SP fue modificado recientemente, comparar con la versión anterior en el repositorio BCOPCore y evaluar rollback.
4. Confirmar resolución verificando que `bancoppel.bdisuc.godproc.tiposervicio.calls` retorna a valores normales sin errores.

**RTO objetivo:** [SME-PENDING]

---

### INC-D10-03 — Pase a contabilidad bloqueado: bdicont (D12) caído

**Impacto:** bdisuc realiza 11 cross-DB edges hacia bdicont. Si D12 está caído, el cierre de caja de sucursal no puede registrarse contablemente. Este incidente tiene ventana crítica durante el batch de cierre (22:00–02:00 CDMX): si no se resuelve antes de las 02:00, los saldos del día siguiente pueden quedar incompletos con posible hallazgo CNBV derivado del incidente de contabilidad.

**Síntomas:**
- `bancoppel.bdisuc.crossdb.bdicont.calls` cae a cero o aumenta en errores
- `bancoppel.bdisuc.caja.cierre.failed` aumenta durante la ventana batch
- Alarmas concurrentes activas en el dominio D12 — bdicont

**Diagnóstico con brain.py:**

```bash
# Paso 1: verificar el estado de bdicont y confirmar si el incidente es en D12
python BCOPCore/digital-brain/brain.py query "bdicont health status incidents"

# Paso 2: mapear cuáles SPs de bdisuc dependen de bdicont para el cierre de caja
python BCOPCore/digital-brain/brain.py edges --source bdisuc --target bdicont --detail

# Paso 3: verificar cuántos cierres de caja están pendientes
python BCOPCore/digital-brain/brain.py query "bdisuc caja cierre pending bdicont"
```

**Resolución:**

1. Confirmar si bdicont (D12) tiene una alarma CRITICAL activa. Si es así, escalar al equipo responsable de D12 y coordinar resolución conjunta.
2. Verificar si existe un procedimiento de cierre diferido en bdisuc que permita registrar el cierre de caja cuando bdicont se restaure. Revisar en `BCOPCore/source/bdisuc/`.
3. Si no existe modo diferido, documentar los cierres de caja pendientes con timestamp para reproceso manual una vez bdicont esté disponible.
4. Una vez bdicont restaurado, ejecutar el reproceso de cierres pendientes y confirmar que `bancoppel.bdisuc.caja.cierre.success` los registra correctamente.
5. Reportar el incidente al equipo de contabilidad y, si la ventana batch fue afectada, evaluar con el equipo regulatorio la necesidad de notificación.

**RTO objetivo:** [SME-PENDING]

---

## 7. SLOs

| SLO | Objetivo | Estado |
|---|---|---|
| Disponibilidad de sp_consultadatospiezas_bym2 | [SME-PENDING] | Pendiente validación SME |
| Disponibilidad de sp_tipo_servicio_etv2 | [SME-PENDING] | Pendiente validación SME |
| Latencia p99 de operaciones de caja | [SME-PENDING] | Pendiente validación SME |
| Tasa de cierres de caja exitosos | [SME-PENDING] | Pendiente validación SME |
| Disponibilidad global del dominio | [SME-PENDING] | Pendiente validación SME |

---

## 8. Contactos de escalamiento

| Rol | Cuándo escalar |
|---|---|
| SRE on-call BanCoppel | Cualquier CRITICAL en métricas `bancoppel.bdisuc.*`, especialmente God procedures |
| DBA Informix BanCoppel | Locks, errores de instancia, corrupción de catálogos en bdisuc |
| Equipo D12 — bdicont | Cuando INC-D10-03 esté activo; coordinación de cierre de caja vs. contabilidad |
| Arquitecto Wave 3 | Cambios a God procedures, decisiones de refactorización de sp_consultadatospiezas_bym2 |
| Red de Sucursales / POS Owner | Notificación de impacto operativo en caja y POS durante INC-D10-01 |
| Equipo Regulatorio BanCoppel | Si el batch de cierre falla y existe riesgo de hallazgo CNBV por datos contables incompletos |

---

*Generado por BCOPCore — DISCOVER Etapa 1 · BanCoppel Application Modernization · Accenture México*

<!-- LOG-DATA-BEGIN -->
## Patrones de incidente observados — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Error rate del dominio:** 1.68% (Normal)

### Acciones por código de error

| Código | Vol/día | Prioridad | Acción inmediata |
|--------|---------|-----------|-----------------|
| `4394` | 19 | BAJA | Revisar MbUserException en IIB — validar que el SP devuelve el tipo es |
| `3743` | 18 | BAJA | Aumentar timeout en configuración del canal ESB — verificar disponibil |

### SPs críticos para monitoring

| SP | Llamadas/día | Error% | Alerta sugerida |
|----|-------------|--------|-----------------|
| `Sp_validadotaatm_web` | 112 | 84.82% | Alerta si error_rate > 42.4% en 5 min |
| `sp_faltsob_atm_ofi_web` | 706 | 11.05% | Alerta si error_rate > 5.5% en 5 min |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
