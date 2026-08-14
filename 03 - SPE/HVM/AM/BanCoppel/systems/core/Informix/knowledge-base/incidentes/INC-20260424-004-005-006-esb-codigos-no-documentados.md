# INC-20260424-004/005/006 — Códigos de Error ESB No Documentados · Dominios SPEI / TEF / BEI

**IDs:** INC-20260424-004 (SPEI) · INC-20260424-005 (TEF) · INC-20260424-006 (BEI)  
**Fecha captura:** 2026-04-24  
**Portales:** [inc-004-d08-esb-spei.html](../../portal/incidents/inc-004-d08-esb-spei.html) · [inc-005-d13-esb-tef.html](../../portal/incidents/inc-005-d13-esb-tef.html) · [inc-006-d14-esb-bei.html](../../portal/incidents/inc-006-d14-esb-bei.html)  
**Hora de actividad visible:** 00:00–23:00 CST (baseline estable) + pico 18:00–20:00 CST  
**Sistemas afectados:** ESB BanCoppel — transversal a todos los dominios. Dominios de mayor impacto: bdispei (D08), bditef (D13), bdibei (D14)  
**Severidad:** N3 — bloquea avance a RELEASE de waves D08, D13, D14  
**Fuentes analizadas:** `errores_bus_20260424_*.txt` (24 archivos, ventana completa) · risk register P655-R005  
**Estado:** DEUDA TÉCNICA ACTIVA — 6 códigos de error ESB sin documentar en runbooks  
**Runbooks origen:** INC-D08-04, INC-D13-01, INC-D14-01

---

## 1. Síntesis del incidente

El análisis de los logs ESB del 24 de abril de 2026 revela **6 códigos de error activos en producción que no están documentados** en los runbooks de los dominios afectados (`06-exceptions.md`). En conjunto, estos 6 códigos generan **10,393 errores** en la ventana de 24 horas, siendo el código `4395` el de mayor volumen (3,980) — no mencionado en ningún runbook previo.

Los tres archivos de diagnóstico del portal (inc-004, inc-005, inc-006) documentan el mismo conjunto de 5 códigos originalmente identificados (4394, 3743, 3701, 3165, 6233) para los dominios SPEI, TEF y BEI respectivamente. Este INC los unifica y añade el código 4395 descubierto en el análisis directo de logs.

---

## 2. Evidencia cuantitativa de los logs 2026-04-24

### 2.1 Volumen total por código (24 horas, sistema completo)

| Código ESB | Errores/día | Descripción conocida | Documentado |
|-----------|------------|----------------------|-------------|
| **4395** | **3,980** | Sin descripción disponible (nuevo hallazgo) | NO |
| 4394 | 2,452 | IBM MQ MbUserException — fallo de mensajería interna | NO |
| 3743 | 762 | SOAP Handle Timed-out (~30s) | NO |
| 3381 | 3,244 | SFTP auth failure (ACEPTPORTA — ver INC-20260424-008) | NO |
| 3701 | 355 | JNI/Axis2 non-SOAP call error | NO |
| 3165 | 320 | SSL socket error on connect | NO |
| 6233 | 264 | Sin descripción disponible | NO |
| **Total (sin 3381)** | **8,133** | códigos de integración no documentados | — |

> **Nota sobre 3381:** Se contabiliza en este inventario pero tiene análisis dedicado en INC-20260424-008 (ACEPTPORTA). El presente INC se concentra en los demás.

### 2.2 Distribución por servicio — códigos 4394 y 4395 (los de mayor impacto)

**Código 4394 (IBM MQ MbUserException) — 2,452 errores:**

| Servicio ESB | Errores |
|-------------|---------|
| SERVICIO | 747 |
| Caja | 286 |
| Caja2 | 239 |
| Tarjeta | 197 |
| Cliente2 | 175 |
| RemesasAPPRIZAAutomaticas | 127 |
| Cliente | 109 |
| ProdCaptacion | 101 |
| Otros | 471 |

**Código 4395 (sin descripción) — 3,980 errores:**

| Servicio ESB | Errores |
|-------------|---------|
| Huellas442 | 1,440 |
| FabricaPagoServicios | 608 |
| SobresDigitales | 511 |
| CoppelCom | 477 |
| RemesasAPPRIZAAutomaticas | 259 |
| RemesasAPPRIZA | 130 |
| TokenizacionThales | 127 |
| RetiroSinTarjeta | 99 |
| Otros | 329 |

### 2.3 Distribución horaria — pico nocturno 18:00–20:00

| Hora CST | Código 4394 (IBM MQ) | Total errores sistema |
|----------|---------------------|-----------------------|
| 07:00–17:00 | 1–14 / hora | 60–690 / hora |
| 18:00 | **689** | 2,106 |
| 19:00 | **1,629** | 4,306 |
| 20:00 | 85 | 169 |

El pico de 18:00–19:00 (total sistema: **6,412 errores en 2 horas**) corresponde al inicio de procesamiento de batches nocturnos — transacciones masivas de IBM MQ (4394) que saturan la mensajería interna del ESB.

### 2.4 Distribución por dominio bancario

El análisis de logs no permite aislar directamente los errores por dominio (bdispei/bditef/bdibei) porque el ESB registra el `sistemaOrigen` del canal de origen (Caja, Tarjeta, SERVICIO), no el SP Informix destino. La distribución por dominio requiere cruzar con la tabla de ruteo ESB (fuente no disponible en este corpus).

**Estimación de impacto SPEI (D08):** Los SPs de bdispei sirven exclusivamente las integraciones con Banxico. Los errores 3165 (SSL, 320/día) tienen alta probabilidad de impacto en D08 dado que SPEI usa conexión SSL con Banxico. El código 3743 (SOAP timeout, 762/día) también afecta integraciones SPEI síncronas.

**Estimación de impacto TEF (D13) y BEI (D14):** El código 4394 (IBM MQ, 2,452/día) afecta principalmente servicios de mensajería asíncrona. Las transferencias electrónicas (TEF) y los pagos institucionales (BEI) usan MQ para procesamiento batch nocturno — correlacionado con el pico de las 19:00.

---

## 3. Causa raíz

Los 6 códigos de error son generados por el middleware ESB BanCoppel (IBM DataPower / WebSphere Message Broker) y representan condiciones de error operativas que el sistema experimenta con regularidad. Su ausencia en los runbooks de los dominios no es una anomalía del sistema — es una deuda de documentación que impide:

1. Distinguir errores esperados (ruido de fondo) de errores anómalos (incidentes reales)
2. Crear alarmas calibradas en CloudWatch para el target
3. Mapear los códigos ESB a sus equivalentes en el middleware target (MSK/Lambda)

**El código 4395 es el de mayor riesgo:** con 3,980 errores/día afectando principalmente `Huellas442` (1,440) y servicios transaccionales, su causa raíz no está identificada. La correlación con `Huellas442` también enlaza con INC-20260424-007 (huellas biométricas stale).

---

## 4. Defectos identificados

| ID | Dominio | Descripción |
|----|---------|-------------|
| P655-R005-D1 | D08 SPEI | Códigos 4394, 3743, 3165, 3701, 6233, 4395 sin documentar en `06-exceptions.md` de bdispei |
| P655-R005-D2 | D13 TEF | Mismos 6 códigos sin documentar en `06-exceptions.md` de bditef |
| P655-R005-D3 | D14 BEI | Mismos 6 códigos sin documentar en `06-exceptions.md` de bdibei |
| P655-R005-D4 | ESB global | Código 4395 sin descripción ni causa raíz identificada — nuevo hallazgo del análisis de logs |
| P655-R005-D5 | Batch nocturno | Pico 18:00–19:00 de IBM MQ (4394) indica batch masivo sin circuit breaker — riesgo en migración |

---

## 5. Patrones de riesgo para la migración

### Patrón 1 — Errores ESB sin mapeo al target
En el target (MSK/Lambda), los códigos de error de IBM DataPower no existirán. Si no se mapean a equivalentes de AWS antes del cutover, el parallel-run comparator no sabrá si una divergencia es un error real o un cambio de código esperado.

### Patrón 2 — Batch nocturno con IBM MQ
El pico de 18:00–19:00 (1,629 errores 4394 en 1 hora) indica un batch masivo que usa IBM MQ de forma asíncrona. En el target, este batch debe migrarse a MSK (Kafka) con particionado adecuado para absorber el volumen sin saturar un solo consumidor.

### Patrón 3 — Código 4395 desconocido en Huellas442
Con 1,440 errores/día en el servicio de autenticación biométrica, el código 4395 puede estar correlacionado con el problema de huellas stale (INC-20260424-007). Requiere análisis conjunto antes del cutover.

### Patrón 4 — SSL (código 3165) con SPEI
Los 320 errores/día de SSL pueden indicar un certificado próximo a expirar en la conexión con Banxico. En producción Informix este error puede ser tolerado (retry automático); en el target cloud, la gestión de certificados debe ser explícita (ACM).

---

## 6. Acciones requeridas

**Pre-cutover waves D08 / D13 / D14:**
1. Documentar los 6 códigos en `knowledge-base/D08-bdispei/06-exceptions.md`, `D13-bditef/06-exceptions.md`, `D14-bdibei/06-exceptions.md`.
2. Investigar código 4395: revisar documentación de IBM DataPower/WebSphere MQ para identificar la condición de error.
3. Mapear cada código ESB a su equivalente en MSK/Lambda target.
4. Verificar si código 3165 (SSL) está relacionado con INC-D05-04 (APPRIZA SSL — mismo código).
5. Implementar CloudWatch filter: ruido de fondo para errores esperados · alarma para volúmenes anómalos.
6. Para el batch nocturno (código 4394 pico 19:00): diseñar topic MSK con particionado que absorba el volumen máximo observado (1,629 mensajes/hora).

---

*Fuentes: `source/logs/2026-04-24/errores_bus_*.txt` (24 archivos, ventana completa 00:00–23:59 CST) · risk register `migration-risk-register.md` P655-R005 · runbooks INC-D08-04, INC-D13-01, INC-D14-01.*  
*Creado: 2026-08-06 | Informix Gemelo Cognitivo — DISCOVER Etapa 1*
