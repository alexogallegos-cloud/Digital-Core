# Runbook de Observabilidad — D11 bdicobranza (Cobranza)

| Campo | Valor |
|---|---|
| Dominio | D11 — bdicobranza |
| Nombre funcional | Cobranza |
| Nivel de riesgo | MEDIO |
| Wave de migración | Wave 2 |
| Total SPs | 82 |
| LOC totales | 113,323 |
| Instrucciones MONEY | 55 |
| Cross-DB edges | 223 |
| God procedures | `fn_formaretiquetaxml` (32,559 LOC, 43 callees), `sp_layout_in_triad_cob` (6,686 LOC), `sp_generafechpagoreestructura` (2,201 LOC) |
| Versión runbook | 1.0 |
| Última revisión | 2026-07-31 |

> **Nota de verificación:** `fn_formaretiquetaxml` es el SP/función más grande de los dominios D07–D12 con 32,559 LOC. Su lógica de generación de XML para integración con Triad debe validarse en `BCOPCore/source/bdicobranza/` antes de cualquier cambio o análisis de refactorización. Los 43 callees internos no han sido validados exhaustivamente en análisis estático.

---

## 1. Rol funcional

bdicobranza gestiona el ciclo completo de recuperación de cartera vencida en BanCoppel. Con 82 SPs y 113,323 LOC, es el dominio con mayor volumen de código en el rango D07–D12. Sus tres God procedures definen su complejidad operativa: `fn_formaretiquetaxml` genera el XML de integración con la agencia de cobranza externa Triad (43 callees internos, 32,559 LOC), `sp_layout_in_triad_cob` procesa el layout de entrada de Triad, y `sp_generafechpagoreestructura` calcula fechas de pago para créditos reestructurados. Con 223 cross-DB edges, bdicobranza tiene el mayor volumen de dependencias externas de los dominios D07–D12: 74 hacia bdicred (D03), 57 hacia bdinteg (D02) y 53 hacia bdimnsj (D09).

---

## 2. Arquitectura de observabilidad

### 2.1 Namespace de métricas

```
bancoppel.bdicobranza.sp.invocations                   — invocaciones totales (82 SPs)
bancoppel.bdicobranza.sp.errors                        — errores por SP
bancoppel.bdicobranza.sp.duration_ms                   — latencia de ejecución por SP
bancoppel.bdicobranza.godproc.xmlgen.calls             — invocaciones de fn_formaretiquetaxml
bancoppel.bdicobranza.godproc.xmlgen.errors            — errores de fn_formaretiquetaxml
bancoppel.bdicobranza.godproc.xmlgen.bytes_generated   — volumen de XML generado (indicador de actividad Triad)
bancoppel.bdicobranza.godproc.triad_layout.calls       — invocaciones de sp_layout_in_triad_cob
bancoppel.bdicobranza.godproc.triad_layout.errors      — errores de sp_layout_in_triad_cob
bancoppel.bdicobranza.godproc.fechapago.calls          — invocaciones de sp_generafechpagoreestructura
bancoppel.bdicobranza.godproc.fechapago.errors         — errores de sp_generafechpagoreestructura
bancoppel.bdicobranza.crossdb.bdicred.calls            — llamadas cross-DB a bdicred
bancoppel.bdicobranza.crossdb.bdinteg.calls            — llamadas cross-DB a bdinteg
bancoppel.bdicobranza.crossdb.bdimnsj.calls            — llamadas cross-DB a bdimnsj (notificaciones)
bancoppel.bdicobranza.triad.xml_sent                   — XMLs entregados a Triad exitosamente
bancoppel.bdicobranza.reestructura.planes_generados    — planes de pago reestructurados generados
```

### 2.2 Dependencias cross-DB

| Base de datos destino | Edges | % del total | Prioridad de monitoreo |
|---|---|---|---|
| bdicred (D03) | 74 | 33.2% | CRITICA — estado del crédito necesario para gestión |
| bdinteg (D02) | 57 | 25.6% | ALTA — hub de integración |
| bdimnsj (D09) | 53 | 23.8% | ALTA — notificaciones a clientes de cobranza |
| Otros | 39 | 17.5% | MEDIA |
| **Total** | **223** | **100%** | |

---

## 3. God Procedures — perfil de riesgo

### fn_formaretiquetaxml

| Atributo | Valor |
|---|---|
| LOC | 32,559 (mayor SP en D07–D12) |
| Callees internos | 43 |
| Función | Generación de XML para integración con agencia de cobranza Triad |
| Riesgo | ALTO — su falla corta el flujo de datos hacia Triad; créditos en gestión activa quedan sin reporte |

### sp_layout_in_triad_cob

| Atributo | Valor |
|---|---|
| LOC | 6,686 |
| Función | Procesamiento del layout de entrada desde Triad |
| Riesgo | ALTO — su falla impide procesar las respuestas de la agencia |

### sp_generafechpagoreestructura

| Atributo | Valor |
|---|---|
| LOC | 2,201 |
| Función | Cálculo de fechas de pago para créditos reestructurados |
| Riesgo | MEDIO-ALTO — errores silenciosos producen planes de pago incorrectos entregados a clientes |

---

## 4. Umbrales de alarma

| Métrica | Umbral WARNING | Umbral CRITICAL | Acción inmediata |
|---|---|---|---|
| Lambda errors | > 0.1% en ventana de 5 min | > 1% en ventana de 5 min | Escalar a SRE on-call |
| Aurora CPU | > 80% | > 90% | Revisar query plan de God procedures |
| MSK consumer lag | > 10,000 mensajes | > 50,000 mensajes | Verificar pipeline de cobranza |
| `fn_formaretiquetaxml` error rate | > 0.1% | > 0.5% | Activar INC-D11-01 |
| `sp_generafechpagoreestructura` error rate | > 0% | > 0.1% | Activar INC-D11-02 — riesgo regulatorio |
| Cross-DB bdicred latencia p99 | > 500 ms | > 2,000 ms | Activar INC-D11-03 |
| XML bytes generados | cae > 30% vs. baseline | cae a cero en ventana batch | Verificar Triad integration |
| Planes de reestructura con fecha inválida | > 0 | > 0 (cero tolerancia) | Escalar a Crédito + Regulatorio |

---

## 5. Patrones de carga (basados en logs de producción)

| Ventana | Tipo | Comportamiento esperado |
|---|---|---|
| 10:00–14:00 CDMX | Peak | Volumen máximo de gestión de cobranza; `fn_formaretiquetaxml` genera el mayor volumen de XML en este bloque; monitorear latencia p99 y CPU de Informix |
| 02:00–06:00 CDMX | Off-peak | Tráfico mínimo; ventana ideal para mantenimiento de God procedures; verificar que no haya procesos batch de reestructura corriendo en este bloque |
| 22:00–02:00 CDMX | Batch window | Procesamiento nocturno de cobranza masiva y generación de layouts Triad; `sp_layout_in_triad_cob` activo; los 74 cross-DB a bdicred deben estar disponibles durante todo este bloque |

---

## 6. Incidentes operativos

---

### INC-D11-01 — Generación de XML para cobranza bloqueada: fn_formaretiquetaxml falla

**Impacto:** la integración con la agencia de cobranza externa Triad queda sin datos. Los créditos en gestión activa no reciben actualizaciones de estado. Si el bloqueo persiste durante la ventana batch (22:00–02:00 CDMX), Triad no recibe el layout del día, lo que puede afectar los SLAs del contrato con la agencia.

**Síntomas:**
- `bancoppel.bdicobranza.godproc.xmlgen.errors` supera umbral CRITICAL
- `bancoppel.bdicobranza.triad.xml_sent` cae a cero
- `bancoppel.bdicobranza.godproc.xmlgen.bytes_generated` cae a cero

**Diagnóstico con brain.py:**

```bash
# Paso 1: revisar el SP y sus 43 callees internos para identificar el punto de falla
python BCOPCore/digital-brain/brain.py sp "fn_formaretiquetaxml" --show-body --show-callees

# Paso 2: verificar si alguno de los callees depende de cross-DB afectados
python BCOPCore/digital-brain/brain.py query "fn_formaretiquetaxml callees crossdb dependencies"

# Paso 3: correlacionar con estado de bdinteg y bdicred
python BCOPCore/digital-brain/brain.py query "bdicobranza xmlgen bdicred bdinteg concurrent errors"
```

**Resolución:**

1. Verificar el log de errores de Informix en bdicobranza. Los errores de `fn_formaretiquetaxml` pueden originarse en alguno de sus 43 callees internos; el log debe indicar el callee exacto que falla.
2. Si el error es de tipo "out of memory" dado el tamaño del SP (32,559 LOC), revisar la configuración de memoria de la sesión Informix y escalar al DBA.
3. Si el error está en un callee que hace cross-DB a bdicred o bdinteg, verificar si esos dominios tienen alarmas activas y coordinar resolución.
4. Una vez restaurado, confirmar que `bancoppel.bdicobranza.triad.xml_sent` retoma valores normales.
5. Si el XML del día no fue entregado a Triad, coordinar con el equipo de cobranza el reproceso del layout y la notificación a la agencia.

**RTO objetivo:** [SME-PENDING]

---

### INC-D11-02 — Fechas de pago en reestructura incorrectas: sp_generafechpagoreestructura produce resultados erróneos

**Impacto:** clientes con crédito reestructurado reciben planes de pago con fechas incorrectas. Este incidente tiene riesgo regulatorio ante CONDUSEF: una fecha de pago incorrecta entregada al cliente puede derivar en una queja formal. La tolerancia es cero; cualquier error en este SP debe tratarse como incidente de alta prioridad.

> **Verificar antes de escalar:** confirmar en `BCOPCore/source/bdicobranza/` si el SP tiene validaciones de rango de fechas o si existe algún parámetro de calendario que puede haberse desactualizado (feriados bancarios, criterios de días hábiles Banxico).

**Síntomas:**
- `bancoppel.bdicobranza.godproc.fechapago.errors` > 0 (cero tolerancia)
- Planes de reestructura con fecha inválida (fecha en pasado, fecha en día inhábil no esperado, fecha fuera del rango del crédito)
- Reclamaciones de clientes por discrepancia en plan de pagos

**Diagnóstico con brain.py:**

```bash
# Paso 1: revisar la lógica de cálculo de fechas del SP
python BCOPCore/digital-brain/brain.py sp "sp_generafechpagoreestructura" --show-body --show-callees

# Paso 2: verificar si el SP depende de tablas de calendario o parámetros que pueden estar desactualizados
python BCOPCore/digital-brain/brain.py query "sp_generafechpagoreestructura calendar parameters tables"

# Paso 3: identificar cuántos registros de reestructura fueron procesados con la fecha incorrecta
python BCOPCore/digital-brain/brain.py query "bdicobranza reestructura fecha incorrecta volumen impacto"
```

**Resolución:**

1. Detener inmediatamente la generación de nuevos planes de reestructura hasta confirmar la causa raíz. Coordinar con el equipo de Crédito BanCoppel.
2. Revisar si el error es sistemático (todos los planes incorrectos) o puntual (un subconjunto de créditos).
3. Verificar las tablas de parámetros de calendario utilizadas por el SP: feriados bancarios, criterios de días hábiles. Un año nuevo no cargado o un feriado bancario faltante es una causa común.
4. Corregir los datos de parámetros o el SP según corresponda, siempre con validación en ambiente no productivo antes del despliegue.
5. Reprocesar los planes afectados y notificar proactivamente a los clientes impactados a través del canal correspondiente.
6. Documentar el incidente en el registro regulatorio del proyecto como posible antecedente para CONDUSEF.

**RTO objetivo:** [SME-PENDING]

---

### INC-D11-04 — Perfil de cliente inaccesible: `sp_obtener_datos_cv_web` falla silenciosamente

**Impacto:** Caja2 no puede acceder al perfil del cliente deudor. Con 49,701 fallas/día (97.37%), el proceso de cobranza opera virtualmente a ciegas. Los clientes son omitidos del ciclo de gestión sin ninguna alerta. Riesgo regulatorio CNBV CUB Art. 75.

> **DEFECTO DE CÓDIGO CONOCIDO (P655-R009/R010):** Esta tasa del 97.37% es producida por defectos verificados en `bdicobranza_sp_obtener_datos_cv_web.sql` activos en producción — NO es un incidente de infraestructura.

**Síntomas del estado actual (defecto activo):**
- `bancoppel.bdicobranza.sp.errors` para `sp_obtener_datos_cv_web` sostenido ~97%
- Logs Caja2: `estatus=error` sin código en `errores_bus` — firma de CWE-390 + CHAR(5)
- Si la tasa **baja abruptamente** de 90% sin fix notificado: posible cambio no controlado

**Causa raíz verificada en código:**

```sql
-- P655-R009: CHAR(5) trunca códigos Informix de 6 caracteres
DEFINE cCodRet CHAR(5);    -- debe ser CHAR(6)

-- P655-R010: ON EXCEPTION silencioso (CWE-390)
ON EXCEPTION SET sSqlErr
    LET cCodRet = sSqlErr; -- código truncado, sin bitácora
    RETURN cCodRet, ...;
END EXCEPTION;
```

**Resolución:**

Estado actual (defecto activo en prod):
1. No escalar como incidente nuevo — es estado crónico conocido
2. Para cliente específico afectado: consultar directamente vía sesión DBA Informix
3. Registrar evidencia CNBV de cualquier cliente con impacto confirmado

Post-fix:
1. Cambiar `CHAR(5)` → `CHAR(6)` en declaración de `cCodRet`; agregar logging en `ON EXCEPTION`
2. Verificar P655-R011: espacio en `bdicred: "informix".sp_consulta_saldocortemin`
3. Recalibrar alerta de error_rate a > 5% post-fix (hoy el 97.37% es el baseline)
4. Golden master: id_cliente sin saldo corte → debe retornar `00001`, no error silencioso

**RTO objetivo:** [SME-PENDING] — priorizar con DBA Informix.

---

### INC-D11-03 — Cascada cobranza a crédito: bdicred (D03) degradado

**Impacto:** bdicobranza tiene 74 cross-DB edges hacia bdicred (D03), el mayor volumen de dependencia externa del dominio (33.2% del total). Si bdicred está degradado, cobranza no puede acceder al estado del crédito para ejecutar la gestión: saldos, morosidad, historial de pagos. La gestión de cobranza activa queda paralizada.

**Síntomas:**
- `bancoppel.bdicobranza.crossdb.bdicred.calls` cae o aumenta en errores
- Latencia p99 de cross-DB a bdicred supera umbral CRITICAL
- Alarmas concurrentes activas en el dominio D03 — bdicred

**Diagnóstico con brain.py:**

```bash
# Paso 1: confirmar el estado de bdicred
python BCOPCore/digital-brain/brain.py query "bdicred health status incidents"

# Paso 2: mapear cuáles SPs de bdicobranza dependen de bdicred y en qué flujos
python BCOPCore/digital-brain/brain.py edges --source bdicobranza --target bdicred --detail

# Paso 3: evaluar si hay flujos de cobranza que pueden ejecutarse sin bdicred (modo degradado)
python BCOPCore/digital-brain/brain.py query "bdicobranza bdicred independent flows degraded mode"
```

**Resolución:**

1. Confirmar con el equipo responsable de bdicred (D03) el estado y ETA de restauración.
2. Suspender los flujos de gestión que requieren datos de bdicred para evitar errores en cascada hacia otras dependencias (bdimnsj, bdinteg).
3. Verificar si existen flujos de cobranza que no requieren consultar el estado del crédito en tiempo real y pueden continuar operando; revisar en `BCOPCore/source/bdicobranza/`.
4. Una vez bdicred restaurado, reanudar la gestión en orden de prioridad: créditos en mayor nivel de morosidad primero.
5. Verificar que los 53 cross-DB a bdimnsj (notificaciones) también retoman normalidad, ya que la cobranza genera notificaciones a clientes que pueden haberse encolado.

**RTO objetivo:** [SME-PENDING]

---

## 7. SLOs

| SLO | Objetivo | Estado |
|---|---|---|
| Disponibilidad de fn_formaretiquetaxml | [SME-PENDING] | Pendiente validación SME |
| Tasa de planes de reestructura sin errores de fecha | [SME-PENDING] | Pendiente validación SME — tolerancia cero recomendada |
| Disponibilidad global del dominio | [SME-PENDING] | Pendiente validación SME |
| Latencia p99 de integración con Triad | [SME-PENDING] | Pendiente validación SME |
| Cobertura de gestión de cartera vencida | [SME-PENDING] | Pendiente validación SME |

---

## 8. Contactos de escalamiento

| Rol | Cuándo escalar |
|---|---|
| SRE on-call BanCoppel | Cualquier CRITICAL en métricas `bancoppel.bdicobranza.*` |
| DBA Informix BanCoppel | Errores de memoria, locks o corrupción en fn_formaretiquetaxml y God procedures |
| Equipo D03 — bdicred | Cuando INC-D11-03 esté activo; coordinación de gestión vs. estado del crédito |
| Equipo de Cobranza BanCoppel | Impacto operativo en gestión activa; notificación a agencia Triad |
| Equipo de Crédito BanCoppel | INC-D11-02 — planes de reestructura incorrectos; decisión de detener proceso |
| Equipo Regulatorio / CONDUSEF | INC-D11-02 persistente o confirmado con impacto a clientes con crédito reestructurado |
| Arquitecto Wave 2 | Cambios a God procedures, decisiones de refactorización de fn_formaretiquetaxml |

---

*Generado por BCOPCore — DISCOVER Etapa 1 · BanCoppel Application Modernization · Accenture México*

<!-- LOG-DATA-BEGIN -->
## Patrones de incidente observados — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Error rate del dominio:** 90.77% (CRÍTICO — revisar)


### SPs críticos para monitoring

| SP | Llamadas/día | Error% | Mecanismo | Alerta sugerida |
|----|-------------|--------|-----------|-----------------|
| `sp_obtener_datos_cv_web` | 51,043 | 97.37% | DEFECTO: CHAR(5) + CWE-390 (P655-R009/R010) | 97.37% es baseline con defecto activo. Ver INC-D11-04. Alertar si error_rate **baja** de 90% sin fix notificado (indicaría cambio no controlado). Post-fix: alertar si > 5%. |

*Generado por generate-kb-from-logs.py · 2026-08-01*
*Actualizado: DT-Riesgos · 2026-08-01 · Mecanismo verificado; INC-D11-04 agregado*
<!-- LOG-DATA-END -->
