# Scaffold Report — Target Banamex S500 + S151

> **Gemelo Cognitivo GemCog v2.2 · Capa 6 (Siembra) — Paso 4**
> Estructura de proyectos Maven por Bounded Context.
> Producido por: `Specialist - Domain Seeding` · Fecha: 2026-07-14
> Estado: DRAFT — Naming deriva del `ubiquitous-language-target.md` (firmado pendiente)

---

## 1. Estructura de Directorio Target

```
target/
├── gl-posting-service/              ← Wave 0 · BC-04 · Specialist - Encapsulation (NO este scaffold)
│
├── captacion-service/               ← Wave 1 · BC-01 Cuentas de Captación
├── control-service/                 ← Wave 1 · BC-02 Control Operacional
├── tarjetas-service/                ← Wave 1 · BC-03 Tarjetas Débito
│
├── gl-account-service/              ← Wave 2 · BC-05 General Ledger
├── movimiento-service/              ← Wave 2 · BC-06 Procesamiento de Movimientos
├── ajustes-service/                 ← Wave 2 · BC-09 Ajustes GL
│
└── shared/
    ├── banamex-common/              ← DTOs compartidos + utilidades (BigDecimal, fechas)
    └── banamex-test-support/        ← TestContainers base + golden-master utilities (Capa 7)
```

> **Nota Wave 0**: `gl-posting-service` es producido por `Specialist - Encapsulation`.
> Su naming de paquetes DEBE ser coherente con el Ubiquitous Language de este documento.

---

## 2. Convenciones Globales

| Dimensión | Valor |
|-----------|-------|
| Java version | 21 (LTS) |
| Spring Boot | 3.3.x |
| Build tool | Maven 3.9+ (wrapper incluido) |
| Encoding | UTF-8 |
| Locale del banco | `Locale.forLanguageTag("es-MX")` |
| BigDecimal scale | 4 decimales |
| BigDecimal rounding | `RoundingMode.HALF_EVEN` |
| Fecha base | `java.time.LocalDate` / `LocalDateTime` — NO `java.util.Date` |
| Serialización JSON | Jackson con módulo JavaTime; BigDecimal como String |
| Observabilidad | OpenTelemetry 1.x + Micrometer |
| Logging | Logback (JSON structured) — campo `traceId` en cada log line |

**Regla de BigDecimal**: todo campo monetario que en el legacy era `COMP-3` (packed decimal) se convierte a `BigDecimal(4, RoundingMode.HALF_EVEN)` y se serializa como `String` en JSON. Ver ADR-SPE-MM-002.

**Regla CRONOS2K**: todo código que contenía parche `CRONOS 2000` en el legacy se anota con `@LegacyY2kPatch` y requiere revisión humana de la lógica de fechas antes del cutover.

---

## 3. BC-01 — `captacion-service`

### 3.1 Maven Artifact

```xml
<groupId>mx.banamex</groupId>
<artifactId>captacion-service</artifactId>
<version>0.1.0-SNAPSHOT</version>
```

### 3.2 Estructura de Paquetes

```
src/
├── main/java/mx/banamex/captacion/
│   ├── domain/
│   │   ├── CuentaCaptacion.java           ← aggregate root
│   │   ├── SaldoCuenta.java               ← value object (COLISIÓN: S500 vs S151 UL §3.1)
│   │   ├── VinculoCuenta.java             ← entity (LIGAS/L040)
│   │   ├── AtributoCuenta.java            ← value object (BD07ATRIBUCTAS)
│   │   ├── DispersionFondos.java          ← aggregate (P015/P165)
│   │   ├── EstadoCuenta.java              ← value object (P400/P335-EDOCTA)
│   │   ├── MovimientoCaptacion.java       ← entity (movimiento de captación)
│   │   ├── CierreBatchCaptacion.java      ← entity (COLISIÓN: LOTE S500 UL §3.4)
│   │   └── TipoCuenta.java                ← enum
│   ├── application/
│   │   ├── AbrirCuentaUseCase.java        ← journey: apertura-cuenta (P010)
│   │   ├── ConsultarSaldoUseCase.java     ← journey: consulta-saldo (P010/P020)
│   │   ├── RegistrarDepositoUseCase.java  ← journey: deposito (P010) [FLAGS: CNBV]
│   │   ├── RegistrarRetiroUseCase.java    ← journey: retiro (P010) [FLAGS: CNBV]
│   │   ├── TransferirFondosUseCase.java   ← journey: transferencia (P080) [FLAGS: CNBV, BANXICO]
│   │   ├── IniciarDispersionUseCase.java  ← journey: dispersion-fondos (P015)
│   │   ├── ConsultarDispersionUseCase.java ← journey: resultado-dispersion (P165)
│   │   ├── GenerarEstadoCuentaUseCase.java ← journey: estado-de-cuenta (P400) ANO-002
│   │   ├── ConsultarVinculosUseCase.java  ← journey: vinculos-cuenta (L040)
│   │   └── IniciarCierreBatchUseCase.java ← journey: cierre-batch
│   ├── api/
│   │   ├── CuentaCaptacionController.java ← OpenAPI bc01
│   │   ├── SaldoController.java
│   │   ├── MovimientoController.java
│   │   ├── DispersionController.java
│   │   ├── EstadoCuentaController.java
│   │   ├── VinculoController.java
│   │   └── BatchController.java
│   ├── infrastructure/
│   │   ├── CuentaCaptacionDmsiiAdapter.java  ← adapter BD01CAPTACION (coexistencia)
│   │   ├── AuxiliarBdAdapter.java            ← adapter BD02AUXILIAR (control batch)
│   │   ├── AtributasBdAdapter.java           ← adapter BD07ATRIBUCTAS
│   │   ├── TarjetasBdAdapter.java            ← adapter BD04TARJETAS (ligada a BC-03)
│   │   ├── GlPostingServiceClient.java       ← Feign/gRPC hacia BC-04 GL-Posting-Service
│   │   ├── CalendarioDiasHabilesAdapter.java ← adapter hacia S006/LOCSUP
│   │   └── EnmascaramientoDatosService.java  ← SCRAMBLING (solo QA/UAT)
│   └── config/
│       ├── CaptacionServiceConfig.java
│       └── BigDecimalSerializationConfig.java
│
└── test/java/mx/banamex/captacion/
    ├── domain/
    ├── application/
    ├── api/
    ├── integration/
    │   └── CaptacionServiceIntegrationTest.java  ← Capa 7: golden-master vs S500 real
    └── equivalence/
        └── CaptacionEquivalenceTest.java          ← [GEMCOG-CAPA7] equivalencia ≥ 99.99%
```

### 3.3 Decisiones de Naming Documentadas

| Decisión | Razón |
|----------|-------|
| `SaldoCuenta` (no `Saldo`) | Colisión con S151/SALDO → `SaldoContable`. Calificador semántico requerido (UL §3.1) |
| `CierreBatchCaptacion` (no `Lote`) | Colisión con S151/LOTE → `ProcesoDiarioGL`. Calificador semántico (UL §3.4) |
| `ControlBatchCaptacion` (no `Control`) | Colisión con S151/CONTROL → `ControlLoteGL` (UL §3.2) |
| `DispersionFondos` (no `Dispersion`) | Nombre más descriptivo; DISPERSION es término legacy |
| `EstadoCuenta` (no `EdoCta`) | Nombre full en español; EDOCTA es acrónimo legacy |
| `GlPostingServiceClient` | La dependencia de BC-01 en BC-04 es explícita como client Feign |
| Package `mx.banamex.captacion` | No `mx.banamex.s500` — el target no hereda la nomenclatura del sistema |

---

## 4. BC-02 — `control-service`

```xml
<artifactId>control-service</artifactId>
```

```
src/main/java/mx/banamex/control/
├── domain/
│   ├── ModuloActivo.java                  ← MAPLI entity (L035)
│   ├── ValidacionVersion.java             ← CTLVER value object
│   ├── DonacionTeleton.java               ← TELETON entity (P045)
│   ├── ControlBatchCaptacion.java         ← COLISIÓN RESUELTA UL §3.2 (interno BC-02)
│   └── ReprocesoForzadoCaptacion.java     ← FORZA S500 entity (COLISIÓN UL §3.5)
├── application/
│   ├── GestionarModuloActivoUseCase.java  ← MAPLI
│   ├── ValidarVersionUseCase.java         ← CTLVER
│   ├── RegistrarDonacionTetelonUseCase.java ← TELETON
│   └── ForzarReprocesoUseCase.java        ← FORZA S500 [FLAGS: CNBV]
├── api/
│   ├── ModuloActivoController.java
│   ├── ValidacionVersionController.java
│   └── TetelonController.java
└── infrastructure/
    ├── MapliDmsiiAdapter.java             ← adapter BD05MAPLI (coexistencia)
    ├── TetelonDmsiiAdapter.java           ← adapter BD06TELETON
    └── AuxiliarBdAdapter.java             ← adapter BD02AUXILIAR (control batch)
```

---

## 5. BC-03 — `tarjetas-service`

```xml
<artifactId>tarjetas-service</artifactId>
```

```
src/main/java/mx/banamex/tarjetas/
├── domain/
│   ├── TarjetaDebito.java                 ← aggregate root (L039/BD04TARJETAS)
│   ├── TarjetaIntercambio.java            ← entity (TARINTERCAM/P630 · S501 migration)
│   └── EstadoTarjeta.java                 ← enum
├── application/
│   ├── ConsultarTarjetaUseCase.java
│   ├── ActualizarEstadoTarjetaUseCase.java
│   └── ConsultarIntercambioUseCase.java   ← P630
├── api/
│   └── TarjetaController.java
└── infrastructure/
    ├── TarjetaDmsiiAdapter.java           ← adapter L039/BD04TARJETAS (ALGOL RETAIN pool)
    │                                         [RETAIN: L039 ALGOL 11.7K LOC — usar JNI/adapter durante coexistencia]
    └── EnmascaramientoPanService.java     ← SCRAMBLING P655 (solo QA/UAT)
```

**Nota L039 (ALGOL RETAIN)**: la librería L039 tiene 11.7K LOC en ALGOL — está en el RETAIN pool. Durante Wave 1 el adapter Java llama via JNI o HTTP al ALGOL original. Solo se reemplaza cuando haya transpiler para ALGOL o se decida un REWRITE (requiere ADR).

---

## 6. BC-05 — `gl-account-service`

```xml
<artifactId>gl-account-service</artifactId>
```

```
src/main/java/mx/banamex/gl/
├── domain/
│   ├── CuentaGL.java                      ← entity (BD02ADSALDO)
│   ├── SaldoContable.java                 ← value object (COLISIÓN: S151 vs S500 UL §3.1)
│   ├── LibroContable.java                 ← entity (BD12MC001S151)
│   ├── ClaveTrayectoria.java              ← entity CVETRA (L040)
│   ├── PosicionFinanciera.java            ← entity (BD13BIFIN/B02POSICION)
│   ├── ControlLoteGL.java                 ← COLISIÓN RESUELTA UL §3.2 (BD99CONTROL)
│   └── ProcesoDiarioGL.java               ← COLISIÓN RESUELTA UL §3.4 (WFL LOTE S151)
├── application/
│   ├── ConsultarSaldoContableUseCase.java ← P050/P052 [FLAGS: CNBV]
│   ├── ListarCuentasGLUseCase.java
│   ├── ConsultarClaveTrayectoriaUseCase.java ← L040 TOTXCVETRA
│   ├── ConsultarPosicionFinancieraUseCase.java ← BD13BIFIN/L014
│   ├── DisparaProcesoDiarioUseCase.java   ← WFL LOTE S151 [FLAGS: CNBV]
│   └── ForzarReprocesoDiarioUseCase.java  ← FORZA S151 [FLAGS: CNBV]
├── api/
│   ├── CuentaGLController.java
│   ├── SaldoContableController.java
│   ├── LibroContableController.java
│   ├── ClaveTrayectoriaController.java
│   ├── PosicionFinancieraController.java
│   └── ProcesoDiarioController.java
└── infrastructure/
    ├── AdSaldoDmsiiAdapter.java           ← adapter BD02ADSALDO (P050/P052)
    ├── SdosDmsiiAdapter.java              ← adapter BD11SDOS151
    ├── Mc001DmsiiAdapter.java             ← adapter BD12MC001S151
    ├── BifinDmsiiAdapter.java             ← adapter BD13BIFIN (L014)
    ├── ControlDmsiiAdapter.java           ← adapter BD99CONTROL (LIBCONTROL)
    ├── ClaveTrayectoriaAdapter.java       ← adapter L040 TOTXCVETRA
    └── CalendarioDiasHabilesAdapter.java  ← adapter S006/LOCSUP (compartido)
```

**Nota DISEÑO-GENERICO**: `L030` y `P015 (ASINCRONO GL)` son un componente genérico instanciado 19 veces. En el target de BC-05: implementar como `ComponenteGenericoFactory<T>` o patrón `Strategy`. **Requiere ADR-SPE-MM-003 antes de implementar.** Consultar con Domain Expert del banco para validar que la semántica de "19 sistemas" es estable.

---

## 7. BC-06 — `movimiento-service`

```xml
<artifactId>movimiento-service</artifactId>
```

```
src/main/java/mx/banamex/gl/movimientos/
├── domain/
│   ├── MovimientoContable.java            ← aggregate root (BD10MOVDIA151) [FLAGS: CNBV]
│   ├── DatosAdicionalesMovimiento.java    ← embedded VO (DATOSADIC ON CMEMP)
│   ├── PunteoSaldo.java                   ← value object (PUNTEO ON CMEMP)
│   └── ComponenteGenericoMovimiento.java  ← [DISEÑO-GENERICO] pendiente ADR-SPE-MM-003
├── application/
│   ├── ProcesarMovimientoUseCase.java     ← L030 (DISEÑO-GENERICO) [REGLAS: BR requiere ADR]
│   ├── ConsultarMovimientosUseCase.java   ← L011 [CRONOS2K] [FLAGS: CNBV]
│   ├── AcumularMovimientosUseCase.java    ← P052 ACCIVAL
│   ├── CargarMovimientosSistemaExtUseCase.java ← P122 + P015 (DISEÑO-GENERICO x19)
│   └── MonitoreoSplunkUseCase.java        ← P810 VERSION 0.25.6
├── api/
│   ├── MovimientoEventListener.java       ← Kafka listener (AsyncAPI)
│   └── MovimientoEventProducer.java       ← Kafka producer (AsyncAPI)
└── infrastructure/
    ├── MovdiaDmsiiAdapter.java            ← adapter BD10MOVDIA151 (L030/L011)
    ├── SplunkMonitoringAdapter.java       ← adapter Splunk (P810)
    ├── GlPostingEventConsumer.java        ← consume eventos de BC-04 via Kafka
    └── SistemaExternoEventConsumer.java   ← consume movimientos de 19 sistemas
```

**Nota CRONOS2K en L011**: `L011` (7.2K LOC ALGOL, consulta BD10) contiene código CRONOS2K. Al transpilar, anotar toda la lógica de fechas con `@LegacyY2kPatch` y ejecutar suite de fechas límite (2000-01-01, 1999-12-31, 2038-01-19) en golden-master de Capa 7.

---

## 8. BC-09 — `ajustes-service`

```xml
<artifactId>ajustes-service</artifactId>
```

```
src/main/java/mx/banamex/gl/ajustes/
├── domain/
│   ├── AjusteContable.java                ← aggregate root [FLAGS: CNBV]
│   ├── DiferenciaContable.java            ← entity (P117 DIFERENCIAS) [FLAGS: CNBV]
│   └── ReprocesoForzadoGL.java            ← COLISIÓN RESUELTA UL §3.5
├── application/
│   ├── DetectarDiferenciasUseCase.java    ← P117 DIFERENCIAS [FLAGS: CNBV]
│   ├── RegistrarAjusteUseCase.java        ← P115 COMPENREG [FLAGS: CNBV]
│   ├── AutorizarAjusteUseCase.java        ← flujo de autorización CNBV
│   └── ForzarReprocesoAjustesUseCase.java ← FORZA S151 [FLAGS: CNBV]
├── api/
│   └── AjusteContableController.java
└── infrastructure/
    ├── AjusteRepository.java              ← JPA/JDBC (target no legacy)
    └── DiferenciaDetectorAdapter.java     ← adapter P117 (durante coexistencia)
```

---

## 9. Módulo Compartido — `banamex-common`

```xml
<artifactId>banamex-common</artifactId>
```

```
src/main/java/mx/banamex/common/
├── BigDecimalUtils.java           ← factory de BigDecimal (4 dec, HALF_EVEN)
├── FechasBancarias.java           ← wrapper java.time con Locale es-MX
├── annotations/
│   ├── LegacyY2kPatch.java        ← @LegacyY2kPatch (CRONOS2K marker)
│   ├── LegacyMtpRelease.java      ← @LegacyMtpRelease("25MTP002") (trazabilidad)
│   └── GemcogSource.java          ← @GemcogSource para trazabilidad Capa 7
├── errors/
│   ├── ErrorResponse.java         ← DTO de error unificado
│   └── BanamexException.java      ← base exception
└── serialization/
    └── BigDecimalStringSerializer.java  ← Jackson: BigDecimal → string 4 decimales
```

---

## 10. Módulo de Testing — `banamex-test-support`

```xml
<artifactId>banamex-test-support</artifactId>
<scope>test</scope>
```

```
src/test/java/mx/banamex/test/
├── containers/
│   ├── KafkaTestContainer.java        ← TestContainers Kafka (BC-06)
│   └── PostgresTestContainer.java     ← TestContainers Postgres (target BD)
├── goldenmaster/
│   ├── GoldenMasterAssertion.java     ← comparador S500/S151 vs target (Capa 7)
│   └── EquivalenceThreshold.java      ← constantes: 99.99% threshold
└── fixtures/
    ├── CuentaCaptacionFixture.java    ← datos de prueba BC-01
    └── MovimientoContableFixture.java ← datos de prueba BC-06
```

---

## 11. Resumen de Decisiones de Naming

| Término legacy | Clase Java target | Package | Motivo |
|---------------|------------------|---------|--------|
| CAPTACION (S500) | `CuentaCaptacion` | `mx.banamex.captacion.domain` | Término semántico; CAPTACION es dominio |
| SALDO (S500) | `SaldoCuenta` | `mx.banamex.captacion.domain` | Colisión con S151/SALDO → `SaldoContable` |
| SALDO (S151) | `SaldoContable` | `mx.banamex.gl.domain` | Calificador semántico contable |
| CONTROL (S500) | `ControlBatchCaptacion` | `mx.banamex.control.domain` | Colisión con S151/CONTROL |
| CONTROL (S151) | `ControlLoteGL` | `mx.banamex.gl.domain` | Calificador semántico GL |
| LOTE (S500) | `CierreBatchCaptacion` | `mx.banamex.captacion.domain` | Colisión con S151/LOTE |
| LOTE (S151) / PD | `ProcesoDiarioGL` | `mx.banamex.gl.domain` | Nombre semántico (PD = Proceso Diario) |
| FORZA (S500) | `ReprocesoForzadoCaptacion` | `mx.banamex.control.domain` | Colisión con S151/FORZA |
| FORZA (S151) | `ReprocesoForzadoGL` | `mx.banamex.gl.ajustes.domain` | Calificador semántico GL |
| LINEA (S500) | (modo operativo — no clase) | — | No es entidad de dominio |
| LINEA (S151) | (modo operativo — no clase) | — | No es entidad de dominio |
| MAPLI | `ModuloActivo` | `mx.banamex.control.domain` | Nombre semántico |
| CVETRA | `ClaveTrayectoria` | `mx.banamex.gl.domain` | Nombre semántico |
| S151REGISTRA | `GlPostingPort` | `mx.banamex.captacion.infrastructure` | Port pattern (BC-04 ENCAPSULATE) |
| MOVIMIENTOS | `MovimientoContable` | `mx.banamex.gl.movimientos.domain` | Nombre semántico |
| AJUSTES | `AjusteContable` | `mx.banamex.gl.ajustes.domain` | Nombre semántico |
| TARJETAS | `TarjetaDebito` | `mx.banamex.tarjetas.domain` | Especificidad (débito vs crédito) |
| TARINTERCAM | `TarjetaIntercambio` | `mx.banamex.tarjetas.domain` | Nombre semántico S501 migration |
| LIGAS | `VinculoCuenta` | `mx.banamex.captacion.domain` | Nombre semántico |
| EDOCTA | `EstadoCuenta` | `mx.banamex.captacion.domain` | Nombre completo en español |
| DISPERSION | `DispersionFondos` | `mx.banamex.captacion.domain` | Nombre semántico |
| BIFIN | `BaseIntegracionFinanciera` | `mx.banamex.gl.domain` | Nombre completo |
| POSICION | `PosicionFinanciera` | `mx.banamex.gl.domain` | Nombre semántico |
| BOOK | `LibroContable` | `mx.banamex.gl.domain` | Nombre semántico en español |
| CRONOS2K | `@LegacyY2kPatch` | `mx.banamex.common.annotations` | Solo anotación de trazabilidad |
| 25MTP002 | `@LegacyMtpRelease` | `mx.banamex.common.annotations` | Solo anotación de trazabilidad |

---

## 12. ADRs Requeridos (identificados en este scaffold)

| ADR | Tema | Bloqueado por |
|-----|------|--------------|
| ADR-SPE-MM-002 | Stack Java target: tipos COBOL→Java, BigDecimal, fechas | `Specialist - Transpilation` — en progreso |
| ADR-SPE-MM-003 | DISEÑO-GENERICO S151: factory vs strategy para 19 sistemas (L030, P015) | BC-06 `movimiento-service` — **bloqueante** |
| ADR-SPE-MM-004 | Adapter ALGOL RETAIN: JNI vs HTTP vs REWRITE para L039 (11.7K LOC) | BC-03 `tarjetas-service` — Wave 1 |

---

## 13. Estado por BC

| BC | Servicio | Wave | Contrato API | Scaffold | ADR pendiente |
|----|---------|------|-------------|---------|--------------|
| BC-04 | `gl-posting-service` | 0 | `Specialist - Encapsulation` | `Specialist - Encapsulation` | — |
| BC-01 | `captacion-service` | 1 | ✅ `openapi-bc01-captacion-service.yaml` | ✅ definido | ADR-SPE-MM-002 |
| BC-02 | `control-service` | 1 | ✅ `openapi-bc02-control-service.yaml` | ✅ definido | ADR-SPE-MM-002 |
| BC-03 | `tarjetas-service` | 1 | ✅ `openapi-bc03-tarjetas-service.yaml` | ✅ definido | ADR-SPE-MM-004 (L039 ALGOL) |
| BC-05 | `gl-account-service` | 2 | ✅ `openapi-bc05-gl-account-service.yaml` | ✅ definido | ADR-SPE-MM-003 (DISEÑO-GENERICO) |
| BC-06 | `movimiento-service` | 2 | ✅ `asyncapi-bc06-movimiento-service.yaml` | ✅ definido | ADR-SPE-MM-003 (DISEÑO-GENERICO) **bloqueante** |
| BC-09 | `ajustes-service` | 2 | ✅ `openapi-bc09-ajustes-service.yaml` | ✅ definido | ADR-SPE-MM-002 |

---

## 14. Próximos Pasos (Capa 7 — Equivalencia)

1. **Gate de Capa 6**: obtener firma en `ubiquitous-language-target.md` (SME + Domain Expert).
2. **ADR-SPE-MM-003** (DISEÑO-GENERICO): decisión de factory vs strategy — bloqueante para BC-06.
3. **Lint de specs**: ejecutar `openapi-generator lint` en los 5 specs OpenAPI + AsyncAPI.
4. **Entregar specs a `Specialist - Equivalence Testing`** (Capa 7) como golden-master.
5. **Entregar Ubiquitous Language a `Specialist - Transpilation`** para alineación de naming Java.
6. **Actualizar `Specialist - GemCog Chatbot`** con artifacts de Capa 6 (UL + specs).

---

*GemCog v2.2 · Capa 6 Paso 4 · Banamex S500+S151 · Specialist - Domain Seeding · 2026-07-14*
