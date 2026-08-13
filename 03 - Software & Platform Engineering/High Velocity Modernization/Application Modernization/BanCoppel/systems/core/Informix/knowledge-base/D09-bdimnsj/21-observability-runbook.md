# Runbook de Observabilidad — D09 bdimnsj (Mensajería)

| Campo | Valor |
|---|---|
| Dominio | D09 — bdimnsj |
| Nombre funcional | Mensajería |
| Nivel de riesgo | BAJO |
| Wave de migración | Wave 1 |
| Total SPs | 1 |
| LOC totales | 446 |
| Instrucciones MONEY | 73 |
| Cross-DB edges | 22 |
| God procedures | ninguno detectado |
| Versión runbook | 1.0 |
| Última revisión | 2026-07-31 |

> **Nota de verificación:** la lógica de despacho del SP único debe validarse directamente en los fuentes antes de confirmar el comportamiento de idempotencia. Ver `Informix/source/bdimnsj/`.

---

## 1. Rol funcional

bdimnsj es el dominio de mensajería del core bancario BanCoppel. Con un solo SP, actúa como dispatcher centralizado de notificaciones hacia clientes. Los dominios de aclaraciones (bdiaclaracion), cobranza (bdicobranza) y solicitudes (bdisolic) dependen de este dominio para toda comunicación saliente. bdiaclaracion registra 34 llamadas cross-DB hacia bdimnsj, lo que lo convierte en el principal llamador conocido.

---

## 2. Arquitectura de observabilidad

### 2.1 Namespace de métricas

```
bancoppel.bdimnsj.sp.invocations          — invocaciones totales del SP
bancoppel.bdimnsj.sp.errors               — errores del SP
bancoppel.bdimnsj.sp.duration_ms          — latencia de ejecución
bancoppel.bdimnsj.crossdb.bdinteg.calls   — llamadas cross-DB a bdinteg
bancoppel.bdimnsj.crossdb.bdicred.calls   — llamadas cross-DB a bdicred
bancoppel.bdimnsj.crossdb.bdisolic.calls  — llamadas cross-DB a bdisolic
bancoppel.bdimnsj.messages.dispatched     — mensajes despachados exitosamente
bancoppel.bdimnsj.messages.duplicate      — mensajes potencialmente duplicados (reintentos detectados)
```

### 2.2 Dependencias cross-DB

| Base de datos destino | Edges | Prioridad de monitoreo |
|---|---|---|
| bdinteg | 9 | ALTA — hub de integración; si cae, bdimnsj pierde 40.9% de sus rutas |
| bdicred | 7 | MEDIA |
| bdisolic | 3 | MEDIA |
| **Total** | **22** | |

### 2.3 Llamadores conocidos que dependen de bdimnsj

| Dominio llamador | Llamadas cross-DB registradas |
|---|---|
| bdiaclaracion | 34 |

---

## 3. Umbrales de alarma

| Métrica | Umbral WARNING | Umbral CRITICAL | Acción inmediata |
|---|---|---|---|
| Lambda errors | > 0.1% en ventana de 5 min | > 1% en ventana de 5 min | Escalar a SRE on-call |
| Aurora CPU | > 80% | > 90% | Revisar query plan del SP |
| MSK consumer lag | > 10,000 mensajes | > 50,000 mensajes | Verificar throughput del dispatcher |
| SP error rate | > 0.5% | > 2% | Revisar logs Informix bdimnsj |
| Mensajes duplicados | > 0 en ventana de 15 min | > 5 en ventana de 15 min | Activar INC-D09-02 |
| Cross-DB bdinteg latencia p99 | > 500 ms | > 2,000 ms | Activar INC-D09-03 |

---

## 4. Patrones de carga (basados en logs de producción)

| Ventana | Tipo | Comportamiento esperado |
|---|---|---|
| 10:00–14:00 CDMX | Peak | Volumen máximo de mensajería; pico de llamadas desde bdiaclaracion y bdicobranza |
| 02:00–06:00 CDMX | Off-peak | Tráfico mínimo; ideal para mantenimiento del SP o cambios de configuración |
| 22:00–02:00 CDMX | Batch window | Posibles notificaciones de cierre nocturno; verificar que el SP no quede bloqueado por procesos batch de bdicred o bdisolic |

---

## 5. Incidentes operativos

---

### INC-D09-01 — Mensajería caída: el SP no responde

**Impacto:** todos los dominios dependientes de notificaciones a clientes pierden capacidad de envío. bdiaclaracion (34 cross-DB), bdicobranza y bdisolic quedan con mensajería silenciosa sin error explícito hasta que su propio timeout expire.

**Síntomas:**
- `bancoppel.bdimnsj.sp.errors` sube por encima del umbral CRITICAL
- Cero registros en `bancoppel.bdimnsj.messages.dispatched`
- bdiaclaracion reporta timeouts en sus llamadas cross-DB a bdimnsj

**Diagnóstico con brain.py:**

```bash
# Paso 1: verificar estado del SP en el grafo semántico
python Informix/digital-brain/brain.py query "bdimnsj SP status callers"

# Paso 2: identificar todos los dominios que llaman a bdimnsj
python Informix/digital-brain/brain.py edges --target bdimnsj --direction inbound

# Paso 3: revisar el SP único — obtener su definición y dependencias
python Informix/digital-brain/brain.py sp "bdimnsj" --show-body --show-callees
```

**Resolución:**

1. Confirmar si el proceso Informix de bdimnsj está activo: revisar el log de instancia en el servidor AIX correspondiente.
2. Si el SP está bloqueado por un lock de otra sesión, identificar la sesión bloqueante con `onstat -g loc` y evaluar kill solo con autorización del DBA Informix BanCoppel.
3. Si el SP arrojó error de compilación tras un cambio reciente, revertir al último release estable y notificar al equipo de modernización.
4. Confirmar restauración verificando que `bancoppel.bdimnsj.messages.dispatched` vuelve a incrementarse.
5. Notificar a bdiaclaracion, bdicobranza y bdisolic que mensajería fue restaurada para que reintenten sus colas pendientes.

**RTO objetivo:** [SME-PENDING]

---

### INC-D09-02 — Mensajes duplicados

**Impacto:** clientes reciben notificaciones repetidas. Dado que el SP no tiene lógica de idempotencia visible en el análisis estático, cualquier reintento de un dominio llamador puede generar un despacho duplicado.

> **Verificar antes de asumir:** revisar el cuerpo del SP en `Informix/source/bdimnsj/` para confirmar si existe algún mecanismo de deduplicación no detectado en el análisis estático.

**Síntomas:**
- `bancoppel.bdimnsj.messages.duplicate` > 0
- Quejas de clientes por SMS/email duplicado
- Trazas de bdiaclaracion o bdicobranza con múltiples llamadas al mismo message-id en el mismo intervalo

**Diagnóstico con brain.py:**

```bash
# Paso 1: identificar patrones de reintento desde los dominios llamadores
python Informix/digital-brain/brain.py query "bdimnsj duplicate retry caller pattern"

# Paso 2: revisar la lógica del SP para encontrar mecanismos de deduplicación
python Informix/digital-brain/brain.py sp "bdimnsj" --show-body --show-callees

# Paso 3: correlacionar con el caller que genera el reintento
python Informix/digital-brain/brain.py edges --target bdimnsj --direction inbound --detail
```

**Resolución:**

1. Identificar cuál dominio genera el reintento: revisar logs de bdiaclaracion y bdicobranza en la misma ventana de tiempo.
2. Si el reintento viene de un timeout mal configurado en el dominio llamador, ajustar el timeout para que sea mayor que la latencia p99 del SP (ver `bancoppel.bdimnsj.sp.duration_ms`).
3. Como mitigación temporal: implementar una tabla de idempotencia en bdimnsj o en el dominio llamador. Esta decisión requiere aprobación del arquitecto de modernización ya que afecta el SP de producción.
4. Registrar el patrón como deuda técnica en el backlog de Wave 1 para agregar idempotencia nativa al SP modernizado.

**RTO objetivo:** [SME-PENDING]

---

### INC-D09-03 — Cross-DB a bdinteg bloqueado

**Impacto:** 9 de los 22 cross-DB edges de bdimnsj apuntan a bdinteg (D02). Si bdinteg está degradado o caído, mensajería no puede enrutar aproximadamente el 40.9% de sus flujos.

**Síntomas:**
- `bancoppel.bdimnsj.crossdb.bdinteg.calls` cae a cero o aumenta en errores
- Latencia p99 de cross-DB a bdinteg supera umbral CRITICAL (2,000 ms)
- Mensajes que dependen de rutas via bdinteg quedan en cola sin despacho

**Diagnóstico con brain.py:**

```bash
# Paso 1: verificar estado de bdinteg y sus dependencias
python Informix/digital-brain/brain.py query "bdinteg health status dependencies"

# Paso 2: mapear cuáles flujos de bdimnsj requieren bdinteg
python Informix/digital-brain/brain.py edges --source bdimnsj --target bdinteg --detail

# Paso 3: verificar si hay ruta alternativa para los mensajes afectados
python Informix/digital-brain/brain.py query "bdimnsj routing alternative bdinteg down"
```

**Resolución:**

1. Confirmar con el equipo SRE si bdinteg (D02) tiene una alarma activa.
2. Si bdinteg está en mantenimiento planificado, verificar si existe modo degradado documentado para mensajería. Si no existe, escalar al arquitecto de Wave 1.
3. Una vez bdinteg restaurado, verificar que `bancoppel.bdimnsj.crossdb.bdinteg.calls` vuelve a valores normales y que los mensajes encolados se despachan.
4. Si la degradación de bdinteg es recurrente, registrar en el risk register del proyecto como riesgo de dependencia crítica.

**RTO objetivo:** [SME-PENDING]

---

## 6. SLOs

| SLO | Objetivo | Estado |
|---|---|---|
| Disponibilidad del SP | [SME-PENDING] | Pendiente validación SME |
| Latencia p99 de despacho | [SME-PENDING] | Pendiente validación SME |
| Tasa de mensajes duplicados | [SME-PENDING] | Pendiente validación SME |

---

## 7. Contactos de escalamiento

| Rol | Cuándo escalar |
|---|---|
| SRE on-call BanCoppel | Cualquier CRITICAL en las métricas del namespace `bancoppel.bdimnsj.*` |
| DBA Informix BanCoppel | Locks o errores de instancia Informix en bdimnsj |
| Arquitecto Wave 1 | Cambios al SP, decisiones de idempotencia, modo degradado sin bdinteg |
| Equipo de Modernización Informix | Defectos encontrados durante análisis de fuentes en `Informix/source/bdimnsj/` |

---

*Generado por Informix — DISCOVER Etapa 1 · BanCoppel Application Modernization · Accenture México*

<!-- LOG-DATA-BEGIN -->
## Patrones de incidente observados — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Error rate del dominio:** 0.0% (Normal)

### Acciones por código de error

| Código | Vol/día | Prioridad | Acción inmediata |
|--------|---------|-----------|-----------------|
| `3165` | 320 | MEDIA | Verificar certificado TLS del endpoint externo — puede estar vencido o |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
