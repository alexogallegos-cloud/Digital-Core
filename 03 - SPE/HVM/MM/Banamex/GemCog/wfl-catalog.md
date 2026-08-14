# Catálogo WFL — Banamex GemCog · S500 + S151
> Gemelo Cognitivo del Sistema · Work Flow Language · Unisys ClearPath MCP
> Última actualización: 2026-07-20 · v1.0
> Fuente autoritativa de los 7 WFLs de ambos sistemas y su mapeo BIAN.

---

## Resumen ejecutivo

| Métrica | Valor |
|---------|-------|
| WFLs S500 | 4 (2 batch principal + 2 reorg DMSII) |
| WFLs S151 | 3 (2 orquestación + 1 telemetría) |
| Total | **7 WFLs** |
| Estrategia universal | **REEMPLAZAR ORQUESTADOR** — ningún WFL se migra literalmente; se modela como DAG en orquestador del target |
| Capacidades BIAN involucradas | 8.1.1 (Scheduling) · 9.1.1 (ODS) · T.3.4 (Batch Control & Regulatory Extraction) |

---

## S500 — Cargos y Abonos (4 WFLs)

### WFL_LOTE

| Campo | Valor |
|-------|-------|
| Sistema | S500 |
| ID en grafo | `LOTE` |
| BIAN | **8.1.1** Scheduling / Proceso Batch Día |
| Riesgo máximo | CRÍTICO |
| Regla de arquitectura | RN-S500-896 |
| Estrategia | REEMPLAZAR ORQUESTADOR |
| Transpilable | No (orquestador, no lógica de negocio) |

**Función:** Orquesta el arranque diario del sistema S500 (proceso lote). Recibe `STRING PARAMETRO`, declara versiones y ejecuta en secuencia los objetos de aplicación: P010 (aplicación), P014 (consultor), P015 (dispersador), P038 (monitor), P050 (activa medios), P060, P080, P091, P093 y más.

**Dependencias directas (programas que lanza):**

| Programa | Capacidad | Función |
|----------|-----------|---------|
| P010 | 2.1.1 | Aplicación base |
| P014 | 7.1.1 | Consultor |
| P015 | 7.1.1 | Dispersador |
| P038 | 8.1.1 | Monitor |
| P050 | 4.1.2 | Activa medios |
| P060 | 10.1.1 | Control |
| P080 | 6.7.2 | Cuenta ordenante (reconciliación) |
| P091 | T.2.3 | Asíncrona |
| P093 | T.2.3 | Asíncrona |

**Target:** DAG declarativo en Airflow / AWS Step Functions / Control-M. Los parámetros `STRING PARAMETRO` se tipifican en la definición del workflow; los reintentos/abort se mapean a políticas del orquestador.

---

### WFL_LINEA

| Campo | Valor |
|-------|-------|
| Sistema | S500 |
| ID en grafo | `LINEA` |
| BIAN | **8.1.1** Scheduling / Arranque Línea Online |
| Riesgo máximo | CRÍTICO |
| Regla de arquitectura | RN-S500-896 (misma entrada que LOTE, variante línea) |
| Estrategia | REEMPLAZAR ORQUESTADOR |
| Transpilable | No |

**Función:** Variante en línea del WFL_LOTE. Controla el arranque del sistema S500 en modo online (transacciones en tiempo real durante el día operativo).

**Target:** Bootstrap de servicios siempre-activos (orchestración de servicios, no job batch). Dependencias de secuencia y parámetros se externalizan a configuración del target.

---

### WFL_REORG_GARBAGE_S500BD01CAPTACION

| Campo | Valor |
|-------|-------|
| Sistema | S500 |
| ID en grafo | `REORG_GARBAGE_S500BD01CAPTACION` |
| BIAN | **9.1.1** Operational Data Stores DMSII (mantenimiento BD01) |
| Riesgo máximo | DEFECTO-PROD |
| Regla de arquitectura | RN-S500-898 |
| Estrategia | REEMPLAZAR ORQUESTADOR (probablemente eliminar) |
| Transpilable | No |

**Función:** Reorganización y garbage collection del data set DMSII de captación (BD01 — contratos, control, MOVDIA, pagos pendientes, CPE). Opera **ON-LINE** — requisito crítico: el motor target debe soportar mantenimiento sin downtime.

**Databases afectados:** S500BD01CAPTACION → S500B03CONTRATOS, S500B02CONTROL, S500B07MOVDIA, S500B25PGOSPENDPE, S500B39CTASCPE, S500B56MAKERCHEK, S500B57PANTASUC.

**Target:** Tarea de mantenimiento nativa del motor destino (VACUUM / rebuild de índices / compactación), orquestada por el scheduler del target. La reorganización física DMSII probablemente sea obsoleta si el motor target gestiona espacio automáticamente. **Evaluar retiro antes de migrar.**

---

### WFL_REORG_GARBAGE_S500BD04TARJETAS

| Campo | Valor |
|-------|-------|
| Sistema | S500 |
| ID en grafo | `REORG_GARBAGE_S500BD04TARJETAS` |
| BIAN | **9.1.1** Operational Data Stores DMSII (mantenimiento BD04) |
| Riesgo máximo | DEFECTO-PROD |
| Regla de arquitectura | RN-S500-897 |
| Estrategia | REEMPLAZAR ORQUESTADOR (probablemente eliminar) |
| Transpilable | No |

**Función:** Reorganización y garbage collection del data set DMSII de tarjetas (BD04 — plásticos, intercambio, cargos). Equivalente al de BD01 pero sobre el dominio de tarjetas.

**Target:** Misma estrategia que BD01. Coordinar con la DAL L039_ACCESOBD04 (RN-S500-885) para no romper contratos de acceso durante el periodo de coexistencia.

---

## S151 — Movimientos Contables GL (3 WFLs)

### WFL_LOTE

| Campo | Valor |
|-------|-------|
| Sistema | S151 |
| ID en grafo | `LOTE` |
| BIAN | **8.1.1** Scheduling / Proceso Batch GL |
| Riesgo máximo | CRÍTICO |
| Regla de arquitectura | RN-S151-1161 |
| Estrategia | REEMPLAZAR ORQUESTADOR |
| Transpilable | No |

**Función:** Orquesta el proceso batch (LOTE) del sistema S151 de movimientos contables. Declara familia de disco `CMEMP`, recibe `STRING PARAMETRO` y ejecuta la secuencia de programas del cierre/proceso por lote (incluye P602 para validación de corresponsal).

**Versiones diferenciadas:** VDM (RELVDM) y Regional (RELREG) — deben gestionarse por configuración en el target, no por bifurcaciones del WFL.

**Dependencias clave:** P602 (Corresponsal), programas P6xx del batch GL.

**Target:** DAG en orquestador del target. Las versiones VDM/regional se parametrizan como perfil de ejecución. Abort/reintento → políticas del orquestador.

---

### WFL_LINEA

| Campo | Valor |
|-------|-------|
| Sistema | S151 |
| ID en grafo | `LINEA` |
| BIAN | **8.1.1** Scheduling / Arranque Línea GL |
| Riesgo máximo | CRÍTICO |
| Regla de arquitectura | RN-S151-1162 |
| Estrategia | REEMPLAZAR ORQUESTADOR |
| Transpilable | No |

**Función:** Orquesta el arranque del sistema S151 en línea. Coordina con P000 (control de fechas / prelínea automática) para determinar `fecha_proceso` y luego levanta los programas de proceso online de movimientos contables.

**Dependencia crítica:** P000 (RN-S151-1157) — control de fechas. Debe estar disponible antes del arranque de la línea.

**Target:** Bootstrap/orchestración de servicios always-on. En el target puede convertirse en un proceso de inicialización de microservicios GL, no un job batch tradicional.

---

### WFL_SPLUNK

| Campo | Valor |
|-------|-------|
| Sistema | S151 |
| ID en grafo | `SPLUNK` |
| BIAN | **T.3.4** Batch Control & Regulatory Extraction — Observabilidad Splunk |
| Riesgo máximo | DEFECTO-PROD |
| Regla de arquitectura | RN-S151-1163 |
| Estrategia | REEMPLAZAR ORQUESTADOR (eliminar acoplamiento a Splunk) |
| Transpilable | No |

**Función:** Orquesta el envío de información del S151 a Splunk: dispara P810 STSTOTALES (RN-S151-1160), que agrega totales por sucursal/caja/banco/moneda consultando MOVDIA, y transmite en línea a Splunk.

**Acoplamiento crítico:** El WFL acopla directamente la app de negocio con Splunk como destino de telemetría. Este patrón debe eliminarse: el negocio no debe conocer el destino de observabilidad.

**Target:** Pipeline de observabilidad nativo (exportador de métricas/eventos con OpenTelemetry → Splunk o cualquier backend). El WFL se retira; P810 se reimplementa como servicio de reporting que publica eventos a un topic/stream, desacoplado del consumidor.

---

## Matriz consolidada de WFLs

| ID Grafo | Sistema | BIAN | Capacidad | Riesgo | Regla Arq | Wave |
|----------|---------|------|-----------|--------|-----------|------|
| LOTE | S500 | 8.1.1 | Scheduling | CRÍTICO | RN-S500-896 | W2 |
| LINEA | S500 | 8.1.1 | Scheduling | CRÍTICO | RN-S500-896 | W2 |
| REORG_GARBAGE_S500BD01CAPTACION | S500 | 9.1.1 | ODS/BD01 | DEFECTO-PROD | RN-S500-898 | W2 |
| REORG_GARBAGE_S500BD04TARJETAS | S500 | 9.1.1 | ODS/BD04 | DEFECTO-PROD | RN-S500-897 | W2 |
| LOTE | S151 | 8.1.1 | Scheduling | CRÍTICO | RN-S151-1161 | W2 |
| LINEA | S151 | 8.1.1 | Scheduling | CRÍTICO | RN-S151-1162 | W2 |
| SPLUNK | S151 | T.3.4 | Batch Control & Regulatory Extraction | DEFECTO-PROD | RN-S151-1163 | W2 |

**Todos en Wave 2** (high-risk). Los WFLs de reorg DMSII son candidatos a retiro directo, no migración.

---

## Decisiones de arquitectura pendientes

| Decisión | Opciones | Impacto |
|----------|----------|---------|
| Orquestador target | Airflow / AWS Step Functions / Control-M | Afecta a todos los WFLs de batch |
| Estrategia WFLs LINEA en S151 | Servicios always-on vs. job de arranque | Cambia modelo operativo |
| WFLs REORG DMSII | Migrar como tarea de mantenimiento vs. retirar | Depende de capacidad auto-mantenimiento del motor target |
| Desacoplamiento Splunk en WFL_SPLUNK | OTel pipeline vs. exportador Splunk nativo | Afecta a arquitectura de observabilidad del target |

---

*Referencias: [rules-catalog/rules-s500-algol-wfl-stubs.md](rules-catalog/rules-s500-algol-wfl-stubs.md) · [rules-catalog/rules-s151-algol-wfl-stubs.md](rules-catalog/rules-s151-algol-wfl-stubs.md) · [bian-mapping-s500.md](bian-mapping-s500.md) · [bian-mapping-s151.md](bian-mapping-s151.md) · [data/S500/enriched-dependency-graph-s500.json](data/S500/enriched-dependency-graph-s500.json) · [data/S151/enriched-dependency-graph-s151.json](data/S151/enriched-dependency-graph-s151.json)*
