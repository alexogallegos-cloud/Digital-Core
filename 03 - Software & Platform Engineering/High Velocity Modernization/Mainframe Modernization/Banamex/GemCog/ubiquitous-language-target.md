# Ubiquitous Language del Target — Banamex S500 + S151

> **Gemelo Cognitivo GemCog v2.2 · Capa 6 (Siembra) — Paso 1**
> Deriva de 143 términos canónicos (63 S500 + 80 S151) → naming del target Java/REST/AsyncAPI.
> Producido por: `Specialist - Domain Seeding` · Fecha: 2026-07-14
> Estado: DRAFT — requiere firma de Software Engineering SME + Domain Expert (negocio Banamex)

---

## 1. Propósito

Este documento es la **única fuente de verdad de naming** para el target de modernización S500 + S151. Todo código Java, contrato OpenAPI/AsyncAPI y scaffold Maven DEBE usar los términos definidos aquí. Prohibido usar IDs de programas legacy (P010, L002R2, CAPTACION_BD, NIVLOG) en nombres de API pública.

**Entrada**: `vocab-s500.json` v2.2 (63 términos) + `vocab-s151.json` v2.2 (80 términos) + `boundaries-s500s151.json` (9 BCs · 218 programas · 7R).

---

## 2. Convenciones de Naming

| Contexto de uso | Convención | Ejemplo |
|----------------|------------|---------|
| Java class / entity | PascalCase | `CuentaCaptacion`, `MovimientoContable` |
| Java interface / port | PascalCase + sufijo Port/Repository/Service | `CuentaCaptacionRepository`, `GlPostingPort` |
| Java method / field | camelCase | `saldoCuenta`, `registrarMovimiento()` |
| REST resource (URI) | kebab-case plural | `/cuentas-captacion`, `/movimientos-contables` |
| REST sub-resource | kebab-case | `/cuentas-captacion/{numeroCuenta}/saldo` |
| AsyncAPI topic/channel | dot-notation · sistema.dominio.evento | `s151.movimientos.registrado`, `s500.captacion.saldo-actualizado` |
| Maven artifact / module | kebab-case | `captacion-service`, `movimiento-service` |
| Java package | lowercase · punto-separado · dominio primero | `mx.banamex.captacion`, `mx.banamex.gl.movimientos` |

**Regla de idioma**: el dominio bancario de Banamex está en **español** — los términos del Ubiquitous Language se nombran en español. Solo se usa inglés para patrones técnicos de arquitectura (Service, Repository, Controller, Event, Port, Adapter).

---

## 3. Colisiones Resueltas

Cinco términos del vocabulario legacy tienen el mismo identificador en S500 y S151 pero con significado semánticamente distinto. Se resuelven con **calificador de dominio** en el target (NO con prefijo de sistema — el target no hereda la separación física S500/S151).

### 3.1 SALDO

| Dimensión | S500 (Captación) | S151 (GL) |
|-----------|-----------------|-----------|
| Significado legacy | Posición monetaria disponible de cuenta de captación (operativo) | Posición acumulada de cuenta contable en el libro mayor (contable) |
| BC dueño | BC-01 Cuentas de Captación | BC-05 General Ledger |
| Término target | **`SaldoCuenta`** | **`SaldoContable`** |
| Forma Java (class) | `SaldoCuenta` | `SaldoContable` |
| Forma REST | `/cuentas-captacion/{numeroCuenta}/saldo` | `/cuentas-gl/{cuentaGL}/saldo-contable` |
| Alias legacy | S500 BD01CAPTACION / campo SALDO | S151 BD02ADSALDO + BD11SDOS151 |
| Tipo Java | `BigDecimal` (4 decimales, RoundingMode.HALF_EVEN) — ver ADR-SPE-MM-002 |

**Regla de integración**: `SaldoContable` (S151) NO es la fuente de `SaldoCuenta` (S500); son posiciones independientes que cuadran via BC-04 GL-Posting-Service. Una divergencia entre ambos es un error de reconciliación regulatoria (flag CNBV).

### 3.2 CONTROL

| Dimensión | S500 (Captación) | S151 (GL) |
|-----------|-----------------|-----------|
| Significado legacy | Módulo de control del ciclo batch de captación (BD02AUXILIAR) | Estado de cada paso del lote batch GL (BD99CONTROL via LIBCONTROL) |
| BC dueño | BC-02 Control Operacional | BC-05 General Ledger (interno) |
| Término target | **`ControlBatchCaptacion`** | **`ControlLoteGL`** |
| Forma REST | `/control-batch` (gestión estado proceso) | Interno al servicio GL — NO expuesto como API pública |
| Alias legacy | S500BD02AUXILIAR · WFL LOTE S500 | BD99CONTROL · LIBCONTROL · WFL LOTE S151 |
| Nota | La gestión de estados de batch de captación se expone via REST para observabilidad | El control GL es encapsulado dentro de `gl-account-service` |

### 3.3 LINEA (modo de procesamiento)

| Dimensión | S500 | S151 |
|-----------|------|------|
| Significado legacy | Modo de procesamiento online de captación (WFL LINEA S500, servidores COMS) | Modo de procesamiento online del GL (WFL LINEA S151, 22 tasks COMS) |
| Término target | **`ModoOnlineCaptacion`** / **`ProcesadorOnlineCaptacion`** | **`ModoOnlineGL`** / **`ProcesadorOnlineGL`** |
| Uso en target | Descriptor de modo de operación (no es un recurso REST) | Descriptor de modo de operación (no es un recurso REST) |
| Nota | En el target, el "modo online" es el default — no se expone como concepto API; es una característica del servicio | Los servicios BC-01, BC-02, BC-03 SON el procesador online de captación |

### 3.4 LOTE (modo de procesamiento batch)

| Dimensión | S500 | S151 |
|-----------|------|------|
| Significado legacy | WFL LOTE captación: secuencia batch nocturna de P130, P142, P144, etc. | WFL LOTE GL: cierre diario contable (PD — Proceso Diario) |
| Término target | **`CierreBatchCaptacion`** | **`ProcesoDiarioGL`** (`ProcesoDiario` en S151) |
| Forma REST (trigger externo) | `POST /cierre-batch/captacion` (si se expone gestión de lotes) | `POST /proceso-diario/trigger` (si se expone) |
| Forma AsyncAPI (evento resultado) | `s500.captacion.cierre-batch.completado` | `s151.gl.proceso-diario.completado` |
| Alias legacy | WFL LOTE S500 | WFL LOTE S151 · PD |

### 3.5 FORZA (reproceso forzado)

| Dimensión | S500 | S151 |
|-----------|------|------|
| Significado legacy | Flag de reproceso: ejecuta batch ya corrido saltando validaciones de doble ejecución en captación | Misma lógica pero en el ciclo batch GL |
| Término target | **`ReprocesoForzadoCaptacion`** | **`ReprocesoForzadoGL`** |
| Forma REST | `POST /cierre-batch/captacion/reproceso` (body: `{forzado: true}`) | `POST /proceso-diario/reproceso` (body: `{forzado: true}`) |
| Alias legacy | FORZA flag S500 | FORZA flag S151 |
| Flag regulatorio | **CNBV**: los reprocesamientos forzados deben quedar en bitácora de auditoría. Operación requiere `Authorization: Bearer` con scope `ops:reproceso` |

---

## 4. Glosario por Bounded Context

### BC-01 — Cuentas de Captación (S500)

| Término legacy | Término canónico target | Clase Java | URI REST | AsyncAPI topic | Colisión | Alias legacy |
|---------------|------------------------|-----------|---------|----------------|----------|-------------|
| CAPTACION | `CuentaCaptacion` | `CuentaCaptacion` | `/cuentas-captacion` | `s500.captacion.cuenta.*` | — | S500BD01CAPTACION |
| SALDO (S500) | `SaldoCuenta` | `SaldoCuenta` | `/cuentas-captacion/{numeroCuenta}/saldo` | — | ✅ ver §3.1 | BD01/SALDO |
| LIGAS | `VinculoCuenta` | `VinculoCuenta` | `/cuentas-captacion/{numeroCuenta}/vinculos` | — | — | L040 / BD01LIGAS |
| EDOCTA | `EstadoCuenta` | `EstadoCuenta` | `/cuentas-captacion/{numeroCuenta}/estado-cuenta` | — | — | P400 / P335-EDOCTA |
| DISPERSION | `DispersionFondos` | `DispersionFondos` | `/dispersiones` | `s500.captacion.dispersion.solicitada` | — | P015 / P165 |
| ATRIBUCTA | `AtributoCuenta` | `AtributoCuenta` | `/cuentas-captacion/{numeroCuenta}/atributos` | — | — | BD07ATRIBUCTAS |
| TARINTERCAM | `TarjetaIntercambio` | `TarjetaIntercambio` | — (sub-entidad de BC-03) | — | — | BD04TARJETAS / S501 |
| LOTE (S500) | `CierreBatchCaptacion` | `CierreBatchCaptacion` | `/cierre-batch/captacion` | `s500.captacion.cierre-batch.completado` | ✅ ver §3.4 | WFL LOTE S500 |
| LINEA (S500) | (modo operativo — no API) | — | — | — | ✅ ver §3.3 | WFL LINEA S500 |
| ASINCRONA (S500) | `OperacionAsincronaCaptacion` | `OperacionAsincronaCaptacion` | `GET /operaciones-asincronas/{id}` | — | — | P091 / P093 |
| MSGAAPLI | `MensajeInterAplicacion` | `MensajeInterAplicacion` | (interno — no exponer como recurso externo) | — | — | BD03MSGAAPLI |
| SCRAMBLING | `EnmascaramientoDatos` | `EnmascaramientoDatosService` | (policy interna QA/UAT — no exponer en PROD) | — | — | P655 |
| LOCSUP | `CalendarioDiasHabiles` | `CalendarioDiasHabilesPort` (port hacia S006) | `GET /dias-habiles/{fecha}` (vía gateway) | — | — | S006 / LOCSUP |

### BC-02 — Control Operacional (S500)

| Término legacy | Término canónico target | Clase Java | URI REST | AsyncAPI topic | Colisión | Alias legacy |
|---------------|------------------------|-----------|---------|----------------|----------|-------------|
| CONTROL (S500) | `ControlBatchCaptacion` | `ControlBatchCaptacion` | `/control-batch` | — | ✅ ver §3.2 | BD02AUXILIAR |
| MAPLI | `RegistroModuloActivo` | `ModuloActivo` | `/modulos-activos` | — | — | BD05MAPLI / L035 |
| CTLVER | `ValidacionVersion` | `ValidacionVersionService` (interno) | — | — | — | CTLVER / CTLVERS |
| TELETON | `ProcesoDonacionTeleton` | `DonacionTeleton` | `/donaciones-teleton` | — | — | P045 / BD06TELETON |
| FORZA (S500) | `ReprocesoForzadoCaptacion` | `ReprocesoForzadoCaptacion` | `POST /cierre-batch/captacion/reproceso` | — | ✅ ver §3.5 | FORZA flag S500 |
| REORG | `ReorganizacionBD` | `ReorganizacionBdJob` (interno) | — | `s500.ops.reorg.completada` | — | WFL REORG |
| GARBAGE | `LiberacionEspacioBD` | `LiberacionEspacioBdJob` (interno) | — | `s500.ops.garbage.completada` | — | WFL GARBAGE |
| AUXILIAR | `BaseDatosAuxiliar` | (adapter interno) | — | — | — | BD02AUXILIAR |
| CRONOS2K | `ParteY2k` | (anotación interna: `@LegacyY2kPatch`) | — | — | — | CRONOS2K / FECHA2000 |
| ADMWIN | `CabeceraComsEnrutamiento` | `CabeceraComsEnrutamiento` (DTO interno) | — | — | — | COPY ADMWIN / 127 LOC |

### BC-03 — Tarjetas Débito (S500)

| Término legacy | Término canónico target | Clase Java | URI REST | AsyncAPI topic | Colisión | Alias legacy |
|---------------|------------------------|-----------|---------|----------------|----------|-------------|
| TARJETAS | `TarjetaDebito` | `TarjetaDebito` | `/tarjetas` | `s500.captacion.tarjeta.*` | — | BD04TARJETAS |
| TARINTERCAM | `TarjetaIntercambio` | `TarjetaIntercambio` | `/tarjetas/{pan}/intercambio` | — | — | BD04 / S501 / P630 |
| ACCESOBD04 | `AccesoBdTarjetas` | `TarjetaRepository` (adapter) | — | — | — | L039 / 11.7K LOC ALGOL |
| SCRAMBLING | `EnmascaramientoDatos` | `EnmascaramientoDatosService` | (QA/UAT únicamente) | — | — | P655 / Mar-2004 |

### BC-04 — ACL GL Interface (BC-04 · Specialist - Encapsulation)

> **Este BC es territorio exclusivo del `Specialist - Encapsulation`. No producir naming aquí.**
> El GL-Posting-Service con operaciones `GrabaLog`, `DfElimina`, `GrabaSdo` es producido y mantenido por ese specialist.
> Referencia: `openapi-bc04-gl-posting-service.yaml` (Wave 0 bloqueante).

Excepción de coordinación: los DTOs de BC-04 DEBEN usar los mismos términos base del Ubiquitous Language.
- `AsientoContable` — DTO de entrada a `POST /gl/entries`
- `EntradaGL` — sinónimo de `AsientoContable` aceptable

### BC-05 — General Ledger (S151)

| Término legacy | Término canónico target | Clase Java | URI REST | AsyncAPI topic | Colisión | Alias legacy |
|---------------|------------------------|-----------|---------|----------------|----------|-------------|
| CONTABILIDAD | `CuentaGL` / `LibroMayor` | `CuentaGL`, `LibroMayor` | `/cuentas-gl`, `/libro-mayor` | — | — | S151 BD general |
| BOOK | `LibroContable` | `LibroContable` | `/libros-contables` | — | — | BD12MC001S151 |
| CVETRA | `ClaveTrayectoria` | `ClaveTrayectoria` | `/claves-trayectoria` | — | — | L040 / TOTXCVETRA |
| SALDO (S151) | `SaldoContable` | `SaldoContable` | `/cuentas-gl/{cuentaGL}/saldo-contable` | — | ✅ ver §3.1 | BD02ADSALDO + BD11SDOS151 |
| AJUSTES | `AjusteContable` | `AjusteContable` | `/ajustes-contables` (BC-09 dueño) | — | — | P117 / flag CNBV |
| CONTROL (S151) | `ControlLoteGL` | `ControlLoteGL` | (interno) | — | ✅ ver §3.2 | BD99CONTROL / LIBCONTROL |
| LOTE (S151) | `ProcesoDiarioGL` | `ProcesoDiarioGL` | `/proceso-diario/trigger` | `s151.gl.proceso-diario.completado` | ✅ ver §3.4 | WFL LOTE S151 / PD |
| PD | `ProcesoDiario` | `ProcesoDiario` | `/procesos-diario/{fecha}` | — | — | PD = Proceso Diario S151 |
| LOCSUP (S151) | `CalendarioDiasHabiles` | `CalendarioDiasHabilesPort` | — (compartido con S500) | — | — | S006 |
| BIFIN | `BaseIntegracionFinanciera` | `IntegracionFinancieraAdapter` (adapter BD13BIFIN) | — | — | — | BD13BIFIN |
| POSICION | `PosicionFinanciera` | `PosicionFinanciera` | `/posicion-financiera` | — | — | B02POSICION |
| PROTCOB | `ProteccionCobros` | `ProteccionCobros` | `/proteccion-cobros` | — | — | B07PROTCOB |
| CTLCITIDIR | `ControlEnvioCiti` | `ControlEnvioCitiAdapter` (interno) | — | — | — | B04CTLCITIDIR |
| ALARMAS | `AlarmaGl` | `AlarmaGl` | `/alarmas` | `s151.gl.alarma.detectada` | — | B03ALARMAS |
| DOMI | `ControlDomiciliacion` | `ControlDomiciliacion` | `/domiciliaciones` | — | — | B10DOMI / pantalla 30 |
| TDMIGCAP | `MigracionCaptacion` | `MigracionCaptacionAdapter` | — | — | — | B08TDMIGCAP / pantalla 29 |

### BC-06 — Procesamiento de Movimientos (S151, event-driven)

| Término legacy | Término canónico target | Clase Java | AsyncAPI topic | Colisión | Alias legacy |
|---------------|------------------------|-----------|----------------|----------|-------------|
| MOVIMIENTOS | `MovimientoContable` | `MovimientoContable` (aggregate root) | `s151.movimientos.registrado` | — | BD10MOVDIA151 |
| MOVIMIENTO | `MovimientoContable` | `MovimientoContable` (singular = mismo aggregate) | — | — | MOVTOS |
| DATOSADIC | `DatosAdicionalesMovimiento` | `DatosAdicionalesMovimiento` (embedded VO) | — | — | DATOSADIC ON CMEMP |
| MOVDB | `RegistroMovimiento` | `registrarMovimiento()` (método, no clase) | — | — | MOVDB |
| MONITOREO | `MonitoreoMovimientos` | `MonitoreoMovimientosPort` (→ Splunk/P810) | `s151.movimientos.monitoreo.evento` | — | P810 / Splunk |
| SPLUNK | `ObservabilidadGL` | (adapter hacia Splunk — no en dominio) | — | — | WFL_SPLUNK / P810 |
| CITI | `SistemaConciliacionCiti` | `ConciliacionCitiAdapter` | — | — | P150 / P151 / BD13BIFIN |
| MENSAJE | `MensajeGL` | `MensajeGL` | — | — | mensajes inter-proceso |

### BC-08 — Reportería GL (S151)

| Término legacy | Término canónico target | Clase Java | URI REST | AsyncAPI topic | Colisión | Alias legacy |
|---------------|------------------------|-----------|---------|----------------|----------|-------------|
| REPORTES | `ReporteRegulatorio` | `ReporteRegulatorio` | `/reportes` | — | — | P150/P151/P155 |
| TESOFE | `ReporteTesofe` | `ReporteTesofe` | `/reportes/tesofe` | — | — | P005 / TESOFE |
| FULL-SUITE | `InterfazContableFullSuite` | `InterfazContableFullSuite` | `/reportes/full-suite` | — | — | P108 / FULL-SUITE |
| ALFA | `InterfazContableAlfa` | `InterfazContableAlfa` | `/reportes/alfa` | — | — | P131 ALFA |
| CPESEC | `ReporteCuentaEspecial` | `ReporteCuentaEspecial` | `/reportes/cpesec` | — | — | P155 / ISR 0.50% |
| DISPLAY | `FormatoVisualizacion` | (interno — render layer) | — | — | — | DISPLAY ON CMEMP |
| PUNTEO | `PunteoSaldo` | `PunteoSaldo` | (interno al cierre) | — | — | PUNTEO ON CMEMP |

### BC-09 — Ajustes GL (S151)

| Término legacy | Término canónico target | Clase Java | URI REST | AsyncAPI topic | Colisión | Alias legacy |
|---------------|------------------------|-----------|---------|----------------|----------|-------------|
| AJUSTES | `AjusteContable` | `AjusteContable` | `/ajustes-contables` | `s151.gl.ajuste.registrado` | — | P117 |
| FORZA (S151) | `ReprocesoForzadoGL` | `ReprocesoForzadoGL` | `POST /proceso-diario/reproceso` | — | ✅ ver §3.5 | FORZA S151 |

---

## 5. Términos Transversales (no dueño de BC específico)

| Término legacy | Término canónico target | Forma Java | Notas |
|---------------|------------------------|-----------|-------|
| S151REGISTRA / L002R2-R5 | `GlPostingAdapter` | `GlPostingPort` + `GlPostingAdapter` | BC-04 lo encapsula; los demás BCs acceden via el port — NUNCA directamente |
| S711 / FRAUDLINK | `ReporteFraudeCNBV` | `ReporteFraudeCNBVAdapter` | Genera archivo CNBV S711; flag regulatorio CNBV obligatorio |
| LOCSUP / S006 | `CalendarioDiasHabiles` | `CalendarioDiasHabilesPort` | Compartido BC-01 y BC-05; anti-corruption layer hacia S006 |
| LIBLJ | `UtilJobsUnisys` | (internal — wrapper para coexistencia) | Eliminado en target cuando el WFL sea reemplazado por Argo/Step Functions |
| DMSII | (adapter pattern por BD) | `{Entidad}DmsiiRepository` durante coexistencia | Se reemplaza por JPA + Spring Data en target; durante coexistencia = adapter |
| WFL | `OrquestadorBatch` | `BatchJobOrchestrator` (Wave 4 → Argo Workflows) | No exponer como entidad de dominio |
| MTP / 25MTP002 | (release marker interno) | `@LegacyMtpRelease("25MTP002")` (anotación de trazabilidad) | Solo para documentar origen del código transpilado |
| CRONOS2K | `ParteY2k` | `@LegacyY2kPatch` | Anotación obligatoria en código que contenía parche CRONOS — revisión humana antes de cutover |
| DISEÑO-GENERICO | `ComponenteGenerico` | `{Dominio}GenericComponentFactory` | Patrón S151: 1 componente instanciado 19 veces por sistema. En target: factory o estrategia. Requiere ADR antes de implementar |
| ETL-LTL | `TraductorContable` | `TraductorContableAdapter` | Interfaz hacia sistemas que no alimentan directamente el GL (S087 y similares). Pendiente confirmar en source S151 |
| S702 | `SistemaProteccionCobros` | `S702Adapter` | Sistema externo de confirmación de domiciliación; anti-corruption layer |
| INTELLIMATCH | `SistemaConciliacionIntelli` | `IntelliMatchAdapter` | Conciliación automática; pendiente validación SME |

---

## 6. Términos Prohibidos en API Pública

Los siguientes términos son **identificadores de programas o entidades técnicas legacy** — jamás deben aparecer como nombre de clase, endpoint URI, topic de mensaje o campo de API pública.

| Término prohibido | Categoría | Reemplazar por |
|-------------------|-----------|----------------|
| P010, P015, P020, P130, P131, P142, P144, P165, P280, P330, P630 | IDs de programa COBOL | Término semántico del BC dueño |
| L002R2, L002R3, L002R4, L002R5 | IDs de librería ALGOL | `GlPostingAdapter` / `GlPostingPort` |
| L010, L011, L019, L030, L035, L039, L040, L050 | IDs de librería | Nombre semántico del adapter |
| BD01CAPTACION, BD02AUXILIAR, BD03MSGAAPLI, etc. | Nombres de BD DMSII | Nombre del aggregate / repository |
| CAPTACION_BD, NIVLOG, MOVTOS ON CMEMP, CCW ON PACK | Entidades DASDL | Nombre del aggregate (ej. `CuentaCaptacion`) |
| S151REGISTRA, S151REGISTRA2 | ID de librería ACL | `GlPostingPort` (via BC-04) |
| 25MTP002, 25MTP003, MTP006 | Release markers Unisys | `@LegacyMtpRelease` (solo en anotaciones internas) |
| COMS, LINCOMS | Tipo de servidor Unisys | (no exponer — es infrastructure legacy) |
| DMSII, DASDL, ALGOL, WFL | Tecnologías Unisys | (no exponer en domain layer) |
| S500, S151 | Nombres de sistemas legacy | Nombre del BC (ej. `captacion-service`, `gl-account-service`) |

---

## 7. Package Structure por BC

```
mx.banamex.captacion.*          ← BC-01 Cuentas de Captación
mx.banamex.control.*            ← BC-02 Control Operacional
mx.banamex.tarjetas.*           ← BC-03 Tarjetas Débito
  (BC-04 = gl-posting-service   → Specialist Encapsulation)
mx.banamex.gl.*                 ← BC-05 General Ledger
mx.banamex.gl.movimientos.*     ← BC-06 Procesamiento de Movimientos
mx.banamex.gl.reportes.*        ← BC-08 Reportería GL
mx.banamex.gl.ajustes.*         ← BC-09 Ajustes GL

Estructura interna por BC:
  mx.banamex.{bc}.domain.*        ← aggregates, entities, value objects
  mx.banamex.{bc}.application.*   ← use cases (un use case por journey)
  mx.banamex.{bc}.api.*           ← controllers REST / listeners AsyncAPI
  mx.banamex.{bc}.infrastructure.*← adapters hacia legacy MCP en coexistencia
  mx.banamex.{bc}.config.*        ← Spring @Configuration
```

---

## 8. Notas de Trazabilidad para Equivalencia (Capa 7)

Cada término del Ubiquitous Language que mapea a un aggregate o use case DEBE incluir anotación de trazabilidad en el código:

```java
// Formato requerido (generado por scaffold — no editarlo manualmente):
// [GEMCOG-SOURCE: {sistema}/{programa-id} · BC-{id} · vocab: {termino_canonico_legacy}]
// [REGLAS: {BR-001}, {BR-002}] [FLAGS: {CNBV|BANXICO|...}]
// [JOURNEY: {nombre-journey}]
//
// Ejemplo:
// [GEMCOG-SOURCE: S500/P130 · BC-01 · vocab: LOTE, SALDO]
// [REGLAS: BR-005, BR-007] [FLAGS: CNBV]
// [JOURNEY: cierre-batch-captacion]
public final class CierreBatchCaptacion { ... }
```

Esta anotación es el input del `Specialist - Equivalence Testing` para construir el golden-master de Capa 7.

---

## 9. Firma Requerida

Este documento NO es definitivo hasta recibir ambas firmas. Pending → DRAFT. Firmado → APROBADO para uso en código productivo.

| Rol | Nombre | Fecha | Firma |
|-----|--------|-------|-------|
| Software Engineering SME (Accenture) | ___________________ | ___ / ___ / 2026 | ___ |
| Domain Expert — Negocio Banamex | ___________________ | ___ / ___ / 2026 | ___ |
| Regulatory Review (CNBV-flagged terms) | ___________________ | ___ / ___ / 2026 | ___ |

**Alcance de la revisión**:
- SME: validar convenciones técnicas de naming y coherencia con ADR-SPE-MM-002 (stack Java).
- Domain Expert: validar que los términos del target reflejan el lenguaje del negocio del banco, no del sistema legacy.
- Regulatory: validar que los términos con flag CNBV/Banxico tienen los `x-regulatory-flags` correctos en los specs OpenAPI correspondientes.

---

*GemCog v2.2 · Capa 6 Paso 1 · Banamex S500+S151 · Specialist - Domain Seeding · 2026-07-14*
*Próximo paso: `openapi-bc01-captacion-service.yaml` (Paso 2 — contratos OpenAPI por BC, Wave 1 primero)*
