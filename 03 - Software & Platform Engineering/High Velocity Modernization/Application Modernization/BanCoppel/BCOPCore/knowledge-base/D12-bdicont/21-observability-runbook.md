# Runbook de Observabilidad — D12 bdicont (Contabilidad)

| Campo | Valor |
|---|---|
| Dominio | D12 — bdicont |
| Nombre funcional | Contabilidad |
| Nivel de riesgo | ALTO |
| Wave de migración | Wave 4 |
| Total SPs | 19 |
| LOC totales | 51,885 |
| Instrucciones MONEY | 924 |
| Cross-DB edges | 682 |
| God procedures | `sp_cont_conssaldosdiariosb4` (4,462 LOC, 84 callees), `sp_cont_productotransaccionb5` (3,990 LOC, 72 callees), `sp_cont_cargamovimientob3` (3,693 LOC, 63 callees) |
| Marco regulatorio | CNBV Anexo 33-36 — contabilidad bancaria regulatoria |
| Versión runbook | 1.0 |
| Última revisión | 2026-07-31 |

> **Nota de verificación:** los tres God procedures manejan saldos, transacciones y movimientos contables bajo el marco CNBV Anexo 33-36. Cualquier análisis de lógica contable debe validarse contra los fuentes en `BCOPCore/source/bdicont/` y con el SME de Contabilidad Bancaria CNBV antes de modificar o migrar estos SPs. Una falla en este dominio es un hallazgo CNBV si supera 24 horas.

---

## 1. Rol funcional

bdicont es el dominio de contabilidad bancaria regulatoria de BanCoppel. Con solo 19 SPs concentra 51,885 LOC y 924 instrucciones MONEY, el mayor ratio MONEY/SP del rango D07–D12. Es el dominio regulatorio más crítico del sistema: sus salidas alimentan directamente los reportes CNBV Serie R y los Anexos 33–36 de contabilidad bancaria. Una falla sostenida en bdicont equivale a un hallazgo regulatorio formal.

El dato más relevante de su arquitectura de dependencias es que 639 de sus 682 cross-DB edges (93.7%) apuntan hacia bdicnweb (D01). bdicnweb es un prerequisito duro de bdicont: si D01 cae, D12 pierde prácticamente toda su capacidad operativa. Los 43 edges restantes van hacia bdinteg (D02).

---

## 2. Arquitectura de observabilidad

### 2.1 Namespace de métricas

```
bancoppel.bdicont.sp.invocations                      — invocaciones totales (19 SPs)
bancoppel.bdicont.sp.errors                           — errores por SP
bancoppel.bdicont.sp.duration_ms                      — latencia de ejecución por SP
bancoppel.bdicont.godproc.saldosdiariosb4.calls       — invocaciones de sp_cont_conssaldosdiariosb4
bancoppel.bdicont.godproc.saldosdiariosb4.errors      — errores de sp_cont_conssaldosdiariosb4
bancoppel.bdicont.godproc.productotransaccionb5.calls — invocaciones de sp_cont_productotransaccionb5
bancoppel.bdicont.godproc.productotransaccionb5.errors — errores de sp_cont_productotransaccionb5
bancoppel.bdicont.godproc.cargamovimientob3.calls     — invocaciones de sp_cont_cargamovimientob3
bancoppel.bdicont.godproc.cargamovimientob3.errors    — errores de sp_cont_cargamovimientob3
bancoppel.bdicont.crossdb.bdicnweb.calls              — llamadas cross-DB a bdicnweb (D01)
bancoppel.bdicont.crossdb.bdicnweb.errors             — errores de cross-DB a bdicnweb
bancoppel.bdicont.crossdb.bdinteg.calls               — llamadas cross-DB a bdinteg (D02)
bancoppel.bdicont.saldos.procesados                   — saldos diarios procesados exitosamente
bancoppel.bdicont.movimientos.registrados             — movimientos del día registrados contablemente
bancoppel.bdicont.serie_r.reportes_generados          — reportes Serie R generados
bancoppel.bdicont.cnbv.hallazgo_riesgo                — flag de riesgo regulatorio activo (0/1)
```

### 2.2 Dependencias cross-DB

| Base de datos destino | Edges | % del total | Prioridad de monitoreo |
|---|---|---|---|
| bdicnweb (D01) | 639 | **93.7%** | CRITICA — prerequisito duro; si D01 cae, D12 opera al 6.3% |
| bdinteg (D02) | 43 | 6.3% | ALTA |
| **Total** | **682** | **100%** | |

**Regla de operación:** la disponibilidad de bdicnweb (D01) es condición necesaria para la operación de bdicont. El monitoreo de D01 es parte integral del runbook de D12.

---

## 3. God Procedures — perfil de riesgo

### sp_cont_conssaldosdiariosb4

| Atributo | Valor |
|---|---|
| LOC | 4,462 |
| Callees internos | 84 |
| Función | Consulta y consolidación de saldos diarios del batch nocturno |
| Regulación | CNBV Anexo 33-36 — saldos diarios son dato primario de los reportes regulatorios |
| Riesgo | CRITICO — su falla en el batch nocturno produce saldos incompletos; hallazgo CNBV si persiste >24h |

### sp_cont_productotransaccionb5

| Atributo | Valor |
|---|---|
| LOC | 3,990 |
| Callees internos | 72 |
| Función | Clasificación y registro del producto de cada transacción contable |
| Regulación | CNBV Anexo 33-36 |
| Riesgo | ALTO — errores en clasificación de transacciones producen inconsistencias en reportes Serie R |

### sp_cont_cargamovimientob3

| Atributo | Valor |
|---|---|
| LOC | 3,693 |
| Callees internos | 63 |
| Función | Carga y registro de movimientos del día en el libro contable |
| Regulación | CNBV Anexo 33-36 — movimientos del día alimentan la Serie R |
| Riesgo | ALTO — su falla impide el registro contable de los movimientos; impacto directo en reportes regulatorios |

---

## 4. Umbrales de alarma

| Métrica | Umbral WARNING | Umbral CRITICAL | Acción inmediata |
|---|---|---|---|
| Lambda errors | > 0.1% en ventana de 5 min | > 1% en ventana de 5 min | Escalar a SRE on-call |
| Aurora CPU | > 80% | > 90% | Revisar query plan de God procedures |
| MSK consumer lag | > 10,000 mensajes | > 50,000 mensajes | Verificar pipeline contable |
| `sp_cont_conssaldosdiariosb4` error rate | > 0% | > 0% (cero tolerancia en batch) | Activar INC-D12-01 |
| `sp_cont_cargamovimientob3` error rate | > 0% | > 0% (cero tolerancia) | Activar INC-D12-02 |
| Cross-DB bdicnweb disponibilidad | < 99.9% | bdicnweb inaccesible | Activar INC-D12-03 INMEDIATAMENTE |
| Cross-DB bdicnweb latencia p99 | > 500 ms | > 2,000 ms | Escalar a SRE + Core Banking |
| `bancoppel.bdicont.cnbv.hallazgo_riesgo` | = 1 | = 1 por > 1h | Escalar a CNBV team + Dirección de Riesgo |
| Saldos diarios procesados | < 95% del baseline | 0 en ventana batch | Activar INC-D12-01 |
| Movimientos sin registro contable | > 0 al cierre del batch | > 0 en el reporte del día | Activar INC-D12-02 |

---

## 5. Patrones de carga (basados en logs de producción)

| Ventana | Tipo | Comportamiento esperado |
|---|---|---|
| 10:00–14:00 CDMX | Peak | Carga de movimientos en tiempo real durante horario bancario; `sp_cont_cargamovimientob3` activo; los 639 cross-DB a bdicnweb deben tener latencia p99 < 500 ms en esta ventana |
| 02:00–06:00 CDMX | Off-peak | Tráfico mínimo; única ventana segura para mantenimiento planificado en bdicont; comunicar a bdisuc (D10) ya que su cierre de caja depende de bdicont |
| 22:00–02:00 CDMX | Batch window | Ventana crítica regulatoria. `sp_cont_conssaldosdiariosb4` procesa los saldos del día. Cualquier falla en este bloque que no se resuelva antes de las 06:00 CDMX del día siguiente es candidata a hallazgo CNBV. bdicnweb (D01) debe estar 100% disponible durante todo este bloque. |

---

## 6. Incidentes operativos

---

### INC-D12-01 — Saldos diarios no procesados: sp_cont_conssaldosdiariosb4 falla en batch nocturno

**Impacto:** los saldos del día siguiente están incompletos. Si la situación persiste más de 24 horas, es un hallazgo CNBV formal bajo Anexo 33-36. Este incidente tiene la mayor urgencia regulatoria del core bancario BanCoppel.

**Protocolo de escalamiento:** este incidente debe notificarse al equipo de CNBV / Regulatorio BanCoppel en el momento en que se confirma la falla en batch, sin esperar a que supere las 24 horas.

**Síntomas:**
- `bancoppel.bdicont.godproc.saldosdiariosb4.errors` > 0 durante la ventana batch (22:00–02:00 CDMX)
- `bancoppel.bdicont.saldos.procesados` cae por debajo del 95% del baseline o llega a cero
- `bancoppel.bdicont.cnbv.hallazgo_riesgo` se activa a 1
- Ausencia de registros de saldo en los reportes del día siguiente

**Diagnóstico con brain.py:**

```bash
# Paso 1: revisar el SP y sus 84 callees para identificar el punto exacto de falla
python BCOPCore/digital-brain/brain.py sp "sp_cont_conssaldosdiariosb4" --show-body --show-callees

# Paso 2: verificar si la falla está correlacionada con bdicnweb
python BCOPCore/digital-brain/brain.py query "bdicont conssaldos bdicnweb correlation batch"

# Paso 3: identificar cuántos saldos fueron procesados antes de la falla
python BCOPCore/digital-brain/brain.py query "bdicont saldos batch progress checkpoint"
```

**Resolución:**

1. Verificar inmediatamente el estado de bdicnweb (D01): si D01 tiene una alarma activa, ese es el primer frente de resolución dado el 93.7% de dependencia.
2. Si bdicnweb está disponible, revisar el log de errores de Informix en bdicont para identificar el callee exacto dentro de `sp_cont_conssaldosdiariosb4` que falla.
3. Evaluar si el batch puede reanudarse desde un checkpoint o si debe ejecutarse completo; revisar en `BCOPCore/source/bdicont/` si el SP tiene manejo de checkpoint.
4. Notificar al equipo de CNBV / Regulatorio BanCoppel con timestamp de la falla y ETA de restauración para gestión de riesgo regulatorio.
5. Una vez restaurado, confirmar que `bancoppel.bdicont.saldos.procesados` alcanza el 100% del baseline y que `bancoppel.bdicont.cnbv.hallazgo_riesgo` vuelve a 0.
6. Registrar el incidente en el registro regulatorio del proyecto con causa raíz, duración y acciones tomadas.

**RTO objetivo:** [SME-PENDING]

---

### INC-D12-02 — Carga de movimiento bloqueada: sp_cont_cargamovimientob3 falla

**Impacto:** los movimientos del día no se registran contablemente. Impacto directo en la Serie R y en los reportes regulatorios CNBV. Cada movimiento no registrado es una discrepancia entre el estado operativo del banco y sus libros contables.

**Síntomas:**
- `bancoppel.bdicont.godproc.cargamovimientob3.errors` > 0
- `bancoppel.bdicont.movimientos.registrados` cae por debajo del baseline
- `bancoppel.bdicont.serie_r.reportes_generados` muestra valores inconsistentes
- bdisuc (D10) puede reportar errores en pase a contabilidad de manera concurrente

**Diagnóstico con brain.py:**

```bash
# Paso 1: revisar el SP y sus 63 callees
python BCOPCore/digital-brain/brain.py sp "sp_cont_cargamovimientob3" --show-body --show-callees

# Paso 2: verificar si el bloqueo es en la carga (insert) o en la validación previa
python BCOPCore/digital-brain/brain.py query "sp_cont_cargamovimientob3 insert validation error type"

# Paso 3: correlacionar con bdisuc para ver si hay un origen específico de movimientos fallidos
python BCOPCore/digital-brain/brain.py query "bdisuc bdicont cargamovimiento concurrent errors"
```

**Resolución:**

1. Determinar si el error es sistemático (todos los movimientos fallan) o selectivo (solo ciertos tipos de movimiento). Revisar el log de errores de Informix en bdicont con el detalle del tipo de movimiento afectado.
2. Si el error está en la validación de datos del movimiento, identificar el dominio origen (bdicnweb, bdisuc, bdinteg) que envía el dato inválido y coordinar la corrección en el origen.
3. Si el error es de bloqueo de tabla, identificar la sesión bloqueante con `onstat -g loc` y coordinar con el DBA Informix BanCoppel.
4. Los movimientos no registrados deben identificarse y encolarse para reproceso. Revisar si `sp_cont_cargamovimientob3` tiene manejo de queue o si el reproceso es manual.
5. Una vez restaurado, ejecutar el reproceso de movimientos pendientes y verificar que `bancoppel.bdicont.serie_r.reportes_generados` refleja los valores correctos.
6. Notificar al equipo de Contabilidad BanCoppel y, si el impacto supera 1 hora, al equipo regulatorio.

**RTO objetivo:** [SME-PENDING]

---

### INC-D12-03 — bdicnweb caído: pérdida casi total de capacidad operativa en bdicont

**Impacto:** 639 de 682 cross-DB calls (93.7%) de bdicont van a bdicnweb (D01). Si D01 cae, bdicont pierde prácticamente toda su capacidad de operación. Este es el incidente de mayor impacto sistémico en D12 y debe escalar de manera inmediata y simultánea a SRE, Core Banking y el equipo de CNBV.

**Protocolo de escalamiento de triple canal — activar simultáneamente:**
1. SRE on-call BanCoppel
2. Equipo Core Banking (responsables de bdicnweb D01)
3. Equipo CNBV / Regulatorio BanCoppel

**Síntomas:**
- `bancoppel.bdicont.crossdb.bdicnweb.errors` sube abruptamente
- `bancoppel.bdicont.crossdb.bdicnweb.calls` cae a cero o reporta timeouts masivos
- Todos los God procedures de bdicont generan errores en cascada
- `bancoppel.bdicont.cnbv.hallazgo_riesgo` se activa a 1
- Alarmas concurrentes activas en el dominio D01 — bdicnweb

**Diagnóstico con brain.py:**

```bash
# Paso 1: confirmar que el origen del incidente es bdicnweb y no bdicont
python BCOPCore/digital-brain/brain.py query "bdicnweb health status incidents active"

# Paso 2: mapear todos los SPs de bdicont que dependen de bdicnweb para dimensionar el impacto completo
python BCOPCore/digital-brain/brain.py edges --source bdicont --target bdicnweb --detail

# Paso 3: identificar los 43 edges hacia bdinteg para evaluar si alguna función puede continuar sin bdicnweb
python BCOPCore/digital-brain/brain.py query "bdicont bdinteg independent flows bdicnweb down"
```

**Resolución:**

1. Confirmar con el equipo de Core Banking que el incidente está activo en bdicnweb (D01) y obtener ETA de restauración.
2. Suspender de inmediato todos los procesos contables de bdicont para evitar errores en cadena y corrupción de registros parciales. Esta decisión debe tomarse en conjunto con el equipo de Contabilidad BanCoppel.
3. Activar el protocolo de comunicación regulatoria: notificar al equipo CNBV con timestamp, alcance y ETA. Si la falla ocurre dentro de la ventana batch (22:00–02:00 CDMX), el riesgo de hallazgo regulatorio es inmediato.
4. Evaluar si los 43 edges hacia bdinteg permiten mantener alguna función mínima de registro; revisar en `BCOPCore/source/bdicont/` cuáles SPs solo usan bdinteg.
5. Una vez bdicnweb restaurado, reanudar bdicont en orden: primero `sp_cont_cargamovimientob3` para registrar movimientos pendientes, luego `sp_cont_productotransaccionb5`, y finalmente `sp_cont_conssaldosdiariosb4` si el batch nocturno quedó incompleto.
6. Ejecutar una validación de consistencia contable post-restauración antes de declarar el incidente cerrado: verificar que `bancoppel.bdicont.serie_r.reportes_generados` y `bancoppel.bdicont.saldos.procesados` reflejan valores completos.
7. Documentar el incidente en el registro regulatorio del proyecto con cronología completa, impacto cuantificado y acciones tomadas para la eventual revisión CNBV.

**RTO objetivo:** [SME-PENDING]

---

## 7. SLOs

| SLO | Objetivo | Estado |
|---|---|---|
| Disponibilidad en ventana batch (saldos diarios) | [SME-PENDING] | Pendiente validación SME — tolerancia cero regulatoria |
| Tasa de movimientos registrados sin error | [SME-PENDING] | Pendiente validación SME |
| Disponibilidad global del dominio | [SME-PENDING] | Pendiente validación SME |
| Latencia p99 de cross-DB a bdicnweb | [SME-PENDING] | Pendiente validación SME |
| Tiempo máximo de recuperación ante falla de bdicnweb | [SME-PENDING] | Pendiente validación SME — limitado por ventana regulatoria de 24h CNBV |

---

## 8. Contactos de escalamiento

| Rol | Cuándo escalar |
|---|---|
| SRE on-call BanCoppel | Cualquier CRITICAL en métricas `bancoppel.bdicont.*`; siempre el primer contacto |
| Equipo Core Banking — bdicnweb D01 | INC-D12-03 activo; cualquier degradación de bdicnweb |
| DBA Informix BanCoppel | Locks, errores de instancia, problemas de memoria en God procedures |
| Equipo CNBV / Regulatorio BanCoppel | INC-D12-01 confirmado (saldos); INC-D12-03 activo; cualquier activación de `bancoppel.bdicont.cnbv.hallazgo_riesgo` |
| Equipo de Contabilidad BanCoppel | INC-D12-02 (movimientos); decisiones de suspensión y reproceso contable |
| SME Contabilidad Bancaria CNBV (Accenture) | Validación de lógica contable en fuentes; análisis de impacto regulatorio pre-migración Wave 4 |
| Arquitecto Wave 4 | Cambios a God procedures, decisiones de refactorización con impacto regulatorio |
| Equipo bdisuc D10 | Coordinación cuando INC-D12-03 genera impacto en cierre de caja de sucursales |

---

## 9. Interdependencias críticas hacia otros dominios

bdicont es un dominio receptor de información pero también un proveedor implícito de cierre: bdisuc (D10) depende de bdicont para el cierre de caja (11 cross-DB). Una falla en bdicont propaga indirectamente hacia bdisuc durante la ventana batch.

| Dominio | Tipo de dependencia | Impacto si bdicont falla |
|---|---|---|
| bdicnweb (D01) | Prerequisito duro (93.7% cross-DB) | Si D01 cae, D12 opera al 6.3% |
| bdinteg (D02) | Complementario (6.3% cross-DB) | Funciones parciales disponibles sin D01 |
| bdisuc (D10) | bdicont es dependencia de D10 | Cierre de caja de sucursal bloqueado |

---

*Generado por BCOPCore — DISCOVER Etapa 1 · BanCoppel Application Modernization · Accenture México*
