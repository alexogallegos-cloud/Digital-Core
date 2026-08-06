# INC-20260424-007 — Huellas Biométricas Stale: Divergencia Informix / PostgreSQL en Autenticación

**ID:** INC-20260424-007  
**Fecha captura:** 2026-04-24  
**Portal:** [inc-007-d02-huellas-stale.html](../../portal/incidents/inc-007-d02-huellas-stale.html)  
**Hora de actividad:** 00:00–23:59 CST (riesgo estructural permanente)  
**Sistemas afectados:** `bdinteg` (D02) — `sp_consulta_huella_actual` · `si_cte_huella` · `postg_huellasemps` (PostgreSQL externo)  
**Severidad:** N2 — riesgo de divergencia en el SP más llamado del sistema (205,079 llamadas/día)  
**Fuentes analizadas:** `errores_bus_20260424_*.txt` (código 4395: 1,440 errores en Huellas442) · risk register P655-R006 · runbook INC-D02-04  
**Estado:** RIESGO ESTRUCTURAL ACTIVO — sistema Huellas migró a PostgreSQL pero el SP sigue leyendo Informix  
**Runbook origen:** INC-D02-04 en `knowledge-base/D02-bdinteg/21-observability-runbook.md`

---

## 1. Síntesis del incidente

`sp_consulta_huella_actual` es el **SP más llamado del sistema BanCoppel**: 205,079 invocaciones/día. Es el punto de entrada de la autenticación biométrica transversal — prácticamente todas las operaciones del canal digital y de caja pasan por este SP para verificar la huella del cliente.

El incidente es estructural: el sistema **Huellas ya migró a PostgreSQL** (`postg_huellasemps`), pero `sp_consulta_huella_actual` sigue consultando la tabla `si_cte_huella` en Informix (`bdinteg`). Si el inventario de huellas en Informix no se sincroniza con el de PostgreSQL, los clientes cuya huella existe en PostgreSQL pero no en Informix obtendrán una **falla de autenticación falso-negativa**: la huella es válida, pero el SP no la encuentra.

El 24 de abril de 2026, el servicio `Huellas442` generó **1,440 errores** con código ESB 4395 — el mayor volumen de ese código en cualquier servicio ESB ese día, correlacionado con este problema estructural.

---

## 2. Evidencia cuantitativa de los logs 2026-04-24

### 2.1 Errores código 4395 — Huellas442 vs. otros servicios

| Servicio ESB | Errores código 4395 |
|-------------|---------------------|
| **Huellas442** | **1,440** |
| FabricaPagoServicios | 608 |
| SobresDigitales | 511 |
| CoppelCom | 477 |
| RemesasAPPRIZAAutomaticas | 259 |
| RemesasAPPRIZA | 130 |
| TokenizacionThales | 127 |
| RetiroSinTarjeta | 99 |
| Otros | 329 |
| **Total sistema** | **3,980** |

`Huellas442` representa el **36.2%** del total del código 4395 — la concentración más alta en un solo servicio. Dado que este código no tiene descripción conocida (ver INC-20260424-004/005/006), la correlación con el problema de sincronización Informix/PostgreSQL es la hipótesis más probable para explicar por qué el servicio de huellas genera tantos errores de este tipo.

### 2.2 Métricas del SP (desde runbook y brain.db)

| Métrica | Valor |
|---------|-------|
| Llamadas/día a `sp_consulta_huella_actual` | 205,079 |
| Rango de impacto potencial | Todos los servicios del canal digital + caja |
| Tabla origen (actual) | `bdinteg:si_cte_huella` (Informix) |
| Sistema destino ya migrado | `postg_huellasemps` (PostgreSQL) |
| Mecanismo de sincronización confirmado | **Desconocido / pendiente verificación** |

### 2.3 Escenario de falla

Si no existe sincronización activa entre `postg_huellasemps` y `si_cte_huella`:
- Clientes cuya huella se enrolaron después de la migración del sistema Huellas a PostgreSQL → **no tienen registro en `si_cte_huella`**
- `sp_consulta_huella_actual` no encuentra la huella → retorna fallo de autenticación
- El cliente es rechazado en operaciones que requieren biometría → falso negativo

La magnitud del problema depende de la fecha en que el sistema Huellas migró a PostgreSQL y si desde entonces existe sincronización hacia Informix.

---

## 3. Causa raíz (hipótesis estructural)

El sistema Huellas fue migrado a PostgreSQL (`postg_huellasemps`) pero el SP Informix `sp_consulta_huella_actual` no fue actualizado para consultar la nueva fuente de datos. Si no hay un proceso de sincronización que mantenga `si_cte_huella` actualizado desde `postg_huellasemps`, cualquier enrolamiento de huella posterior a la migración solo existe en PostgreSQL.

**Cadena de riesgo:**
```
1. Cliente nuevo enrola huella → va a postg_huellasemps (PostgreSQL)
2. Sin sincronización → si_cte_huella en bdinteg (Informix) NO se actualiza
3. sp_consulta_huella_actual consulta si_cte_huella → no encuentra la huella
4. Retorna fallo de autenticación → cliente rechazado (falso negativo)
5. Con 205,079 llamadas/día, incluso un 1% de divergencia = 2,050 autenticaciones fallidas/día
```

---

## 4. Riesgo para la migración (prerrequisito del parallel-run)

Antes de iniciar el parallel-run de bdinteg, la siguiente pregunta debe responderse con evidencia:

> **¿El inventario de huellas en `si_cte_huella` (Informix) es idéntico al de `postg_huellasemps` (PostgreSQL)?**

Si no hay sincronización y los datos difieren, el parallel-run tendrá una tasa de divergencia crónica en autenticaciones que no es un error del target — es un defecto de datos del AS-IS. Esto debe documentarse como condición de equivalencia en el `ADR-SPE-AM-XXX` antes del cutover.

---

## 5. Patrones de riesgo para la migración

### Patrón 1 — Sistema parcialmente migrado como fuente de verdad
La migración de Huellas a PostgreSQL ya ocurrió, pero el SP Informix no fue actualizado. Este es un **anti-patrón de migración incremental sin Anti-Corruption Layer**: el sistema destino ya existe, el sistema origen sigue siendo la fuente de verdad para el SP, y no hay un mecanismo formal de sincronización documentado.

### Patrón 2 — SP de mayor volumen con dependencia en datos potencialmente stale
`sp_consulta_huella_actual` (205,079 llamadas/día) es el SP con mayor fanout de impacto en el sistema. Un error del 1% en este SP propaga 2,050 autenticaciones fallidas/día hacia todos los canales. El parallel-run comparator debe medir especialmente la tasa de éxito de autenticación, no solo la latencia.

---

## 6. Acciones requeridas

**Antes del parallel-run de D02-bdinteg:**
1. Coordinar con el equipo de Huellas (owner de `postg_huellasemps`) para verificar si existe mecanismo de sincronización hacia `si_cte_huella`.
2. Si no hay sincronización: **ejecutar reconciliación de datos** entre las dos tablas y documentar el delta.
3. Decidir en `ADR-SPE-AM-XXX`: ¿el target de bdinteg apunta a `postg_huellasemps` directamente o mantiene `si_cte_huella` como capa intermedia?
4. Investigar el código 4395 en `Huellas442` (1,440 errores/día) — confirmar si está relacionado con la divergencia de datos o es un error diferente.
5. Registrar como prerequisito de parallel-run: tasa de autenticación exitosa del target debe ser ≥ baseline legacy.

---

*Fuentes: `source/logs/2026-04-24/errores_bus_*.txt` (código 4395, servicio Huellas442) · risk register P655-R006 · runbook INC-D02-04.*  
*Creado: 2026-08-06 | BCOPCore Gemelo Cognitivo — DISCOVER Etapa 1*
