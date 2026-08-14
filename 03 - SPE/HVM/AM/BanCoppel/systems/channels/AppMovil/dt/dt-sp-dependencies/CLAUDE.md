# DT-SP-Dependencies — Digital Twin · AppMovil
> **Artefacto propietario**: Inventario completo del puente JDBC de AppMovil a SPs Informix
> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`
> **Versión**: 0.2.0
> **Vigencia**: Activo desde 2026-08-13 · Actualizado 2026-08-14 (brain.db build)
> **Fase**: DISCOVER

---

## IDENTIDAD

Soy el Digital Twin **más crítico para la planificación de la migración** del canal móvil BanCoppel. Documento el **inventario exhaustivo de todos los Stored Procedures de Informix que son invocados directamente por microservicios Java de AppMovil vía JDBC** (`CallableStatement` / `@HandledProcedure`).

Este puente directo Java → Informix vía JDBC es la dependencia técnica más importante del sistema: sin mapear cada SP que se llama, no es posible definir el orden de migración, estimar el impacto regulatorio (SPEI, CoDi) ni planificar el re-plataformado.

> **v0.2.0** — Inventario actualizado con los resultados del primer build de `digital-brain/brain.db`. Se descubrieron **6 bases de datos Informix** (vs. 3 que se tenían identificadas) y **15 SPs confirmados** desde código y properties.

---

## El mecanismo de llamada (evidencia del código fuente)

Los microservicios de **capa D** (`msaXX-d-*`) invocan SPs Informix usando el patrón:

```java
// Anotación AOP propia de BanCoppel — marca el método como llamada a SP
@HandledProcedure(name = Constants.DATABASE_CALL_INTRABANK, ignoreExceptions = {...})
public SpResponse transaction(Payment payment) {
    Session session = entityManager.unwrap(Session.class);
    return session.doReturningWork((Connection conn) -> {
        // Firma: conn.prepareCall("{call db:sp_name(?,?,...,?)}")
        CallableStatement cstm = conn.prepareCall(Constants.SPCTRANSCTASPROPIASCODI_BEX);
        // Parámetros posicionales vía Map<Integer,Object>
        cstm.setObject(Numbers.ONE.ordinal(), payment.getBusiness());
        // ... hasta 38 parámetros
        cstm.execute();
        // Resultado vía getResultSet() con columnas por ordinal (firstCode, secondCode)
        ResultSet rs = cstm.getResultSet();
    });
}
```

**Dos variantes de firma de SP encontradas en el corpus:**

| Variante | Ejemplo | Observación |
|---------|---------|-------------|
| `{call db:sp_name(?,?)}` — sin schema | `{call bdicheq:spsctransctaspropiascodi_bex(...)}` | La mayoría de SPs del canal |
| `{CALL db:informix.sp_name(?,?)}` — con schema `informix.` | `{CALL bdicred:informix.comdistdc(?,?,?,?)}` | SPs de crédito — schema explícito |
| `db:sp_name` — solo el nombre (en properties) | `bdicheq:cargo_ref` | Usado en `constants.api.name.*` |

---

## Bases de datos Informix accedidas por el canal (confirmadas por brain.db)

El primer build del brain descubrió **6 bases de datos Informix** — 3 más de las identificadas inicialmente:

| Base | Dominio Informix | Función | SPs confirmados | ¿Conocida antes? |
|------|-----------------|---------|-----------------|-----------------|
| `bdicheq` | D04 Cheques y Cuentas | Cargo, abono, transferencia, MTU, CoDi intrabank | 5 | ✓ |
| `bdispei` | D08 SPEI | Transferencias interbancarias SPEI y CoDi interbank | 2 | ✓ |
| `bdicred` | D03 Crédito | Consulta crédito, amortización, distribución, pago con tarjeta | 3 | ✓ |
| `bdimnsj` | — Mensajería | Registro de eventos de mensajería (26 params) | 1 | **NUEVO** |
| `bdiprog` | — Programas | Validación de beneficios/programas (SKY?) | 1 | **NUEVO** |
| `bdisac` | — Atención al Cliente | Cálculo de valores de SAC | 1 | **NUEVO** |
| `bdisolic` | — Solicitudes | Proyección de préstamos | 1 | **NUEVO** |

> `bdimnsj` (mensajería), `bdiprog` (programas), `bdisac` (SAC/atención al cliente) y `bdisolic` (solicitudes) **no estaban en el inventario inicial**. Su descubrimiento amplía el alcance del proyecto AM.

---

## Inventario de SPs confirmados (build brain.db — 2026-08-14)

### Tabla maestra — 15 SPs identificados

| Base Informix | SP | Params | Microservicio AppMovil | Tipo de operación | Criticidad |
|---------------|----|---------|-----------------------|-------------------|------------|
| `bdicheq` | `spsctransctaspropiascodi_bex` | 38 | `msapy-d-domain-codi-payment` | CoDi intrabank — cargo + abono mismo banco | CRÍTICO |
| `bdicheq` | `spsctransctaspropias_bex` | — | `msapy-d-domain-codi-payment` | Transferencia intrabank (sin CoDi) | ALTO |
| `bdicheq` | `cargo_ref` | — | `msapy-d-domain-codi-payment` | Cargo con referencia — débito a cuenta origen | ALTO |
| `bdicheq` | `abono_ref` | — | `msapy-d-domain-codi-payment` | Abono con referencia — crédito a cuenta destino | ALTO |
| `bdicheq` | `reversion` | — | `msapy-d-domain-codi-payment` | Reversión automática (tipo `A`) de transacción | ALTO |
| `bdicheq` | `sp_validacionmtu_bpi` | 4 | `msapy-d-domain-codi-payment` | Validación de límite MTU pre-pago | MEDIO |
| `bdicheq` | `sp_bitacoramtu_bpi` | 9 | `msapy-d-domain-codi-payment` | Bitácora de operaciones para control MTU | MEDIO |
| `bdispei` | `sp_regordenctecte_bex_codi` | 35 | `msapy-d-domain-codi-payment` | CoDi interbank — instrucción SPEI con metadatos CoDi | CRÍTICO |
| `bdispei` | `sp_regordenctecte_bex` | — | `msasr-*` (por confirmar) | SPEI saliente sin CoDi — transferencia pura | CRÍTICO |
| `bdicred` | `spsdpagotarcredpropia` | 16 | `msapy-d-domain-intrabank-card-payment` | Pago con tarjeta de crédito propia intrabank | ALTO |
| `bdicred` | `sp_obtiene_tabla_amortizacion` | 4 | `msaxd-*` (por confirmar) | Tabla de amortización de crédito | MEDIO |
| `bdicred` | `comdistdc` | 4 | (por confirmar) | Distribución de comisión de crédito | MEDIO |
| `bdimnsj` | `sp_registra_evento` | 26 | (por confirmar) | Registro de evento de mensajería — log transaccional | MEDIO |
| `bdiprog` | `sp_validasky` | 1 | `msasr-d-domain-services-payment-validation` | Validación de beneficio/programa SKY | BAJO |
| `bdisac` | `sp_calculadv` | 1 | `msasr-d-domain-services-payment-validation` | Cálculo de valor SAC/atención al cliente | BAJO |
| `bdisolic` | `sp_proyecta_prestamos` | — | (por confirmar) | Proyección de montos de préstamo | MEDIO |

> **Nota sobre `bdicheq:spsctransctaspropias_bex` vs `bdicheq:spsctransctaspropiascodi_bex`**: son dos SPs distintos. El primero es transferencia intrabank general; el segundo es la variante específica para CoDi (lleva metadatos adicionales del cobro QR).

> **Nota sobre `bdispei:sp_regordenctecte_bex`**: es la variante sin CoDi de `sp_regordenctecte_bex_codi`. Aplica para transferencias SPEI salientes iniciadas directamente (no por QR CoDi).

---

## Hallazgo crítico: dominio `ch` sin conexiones JDBC directas

El brain.db confirma que **ninguno de los 49 microservicios del dominio `ch` (Canal)** tiene dependencia JDBC con Informix. El dominio `ch` es puro orquestador — consume MongoDB (`bdibex`) y Redis para gestión de sesión y mensajes sensoriales, pero **delega toda la ejecución transaccional** a los dominios `py`, `dp`, `sr`, `cr`, `lo` y `xd`.

| Dominio | MSAs con JDBC Informix | MSAs totales | % con Informix |
|---------|----------------------|-------------|----------------|
| `sr` (Servicios/ATM) | 20 | 29 | 69% |
| `dp` (Depósito) | 12 | 25 | 48% |
| `cm` (Cliente) | 9 | 27 | 33% |
| `lo` (Préstamos) | 8 | 13 | 62% |
| `cr` (Crédito) | 8 | 12 | 67% |
| `xd` (Cross-domain) | 6 | 9 | 67% |
| `py` (Pagos) | 5 | 7 | 71% |
| `ch` (Canal) | **0** | 49 | **0%** |
| `mg` (Mensajería) | 0 | 4 | 0% |
| `cm/im` (Infra) | 0 | 1+1 | 0% |

**Implicación para migración**: el dominio `ch` se puede migrar de forma independiente a Informix — sus únicos acoplamientos externos son MongoDB Atlas y Redis. Los dominios `sr`, `cr`, `lo` y `xd` son los de mayor riesgo (>60% de sus MSAs tienen JDBC Informix).

---

## Análisis de criticidad regulatoria

| SP | Base | Tipo transacción | Regulación | SLA | Estado |
|----|------|-----------------|------------|-----|--------|
| `spsctransctaspropiascodi_bex` | bdicheq | CoDi intrabank | Banxico CoDi | Inmediato | CONFIRMADO en código |
| `sp_regordenctecte_bex_codi` | bdispei | CoDi interbank SPEI | Banxico CoDi + SPEI | ≤ 30 seg | CONFIRMADO en código |
| `sp_regordenctecte_bex` | bdispei | SPEI saliente puro | Banxico SPEI | ≤ 30 min | CONFIRMADO en properties |
| `spsctransctaspropias_bex` | bdicheq | Transferencia intrabank | CNBV | Inmediato | CONFIRMADO en properties |
| `spsdpagotarcredpropia` | bdicred | Pago tarjeta crédito propia | CNBV | Inmediato | CONFIRMADO en código |
| `sp_validacionmtu_bpi` | bdicheq | Validación límite MTU | CNBV | Pre-transacción | CONFIRMADO en properties |
| `cargo_ref` / `abono_ref` | bdicheq | Cargo / Abono | CNBV | Inmediato | CONFIRMADO en properties |
| `reversion` | bdicheq | Reversión automática | CNBV | Inmediato | CONFIRMADO en properties |
| `sp_registra_evento` | bdimnsj | Registro evento mensajería | CNBV trazabilidad | Asíncrono | PENDIENTE microservicio origen |

---

## Impacto de migración por SP

Cada SP que migra del Informix actual al sistema target requiere:

1. **Actualizar el microservicio de capa D**: cambiar el `prepareCall` por llamada a API o evento del sistema target
2. **Re-implementar la lógica del SP**: el sistema target recibe los mismos parámetros y debe retornar el mismo schema de respuesta
3. **Mantener la compatibilidad de la firma**: los `param_count` están hardcoded por posición — si el sistema target expone una API, el microservicio de canal requiere refactor
4. **Certificación regulatoria**: los SPs `sp_regordenctecte_bex_codi`, `sp_regordenctecte_bex` y `spsctransctaspropiascodi_bex` requieren certificación de Banxico post-migración
5. **PCI-DSS**: `spsdpagotarcredpropia` (pago con tarjeta) requiere revisión PCI-DSS del nuevo procesador

**Orden de migración recomendado (por criticidad decreciente):**

| Ola | SPs | Criterio |
|-----|-----|---------|
| 1 — Crítico regulatorio | `spsctransctaspropiascodi_bex`, `sp_regordenctecte_bex_codi`, `sp_regordenctecte_bex` | No pueden tener brecha de servicio — SPEI/CoDi |
| 2 — Transaccional alto | `cargo_ref`, `abono_ref`, `reversion`, `spsctransctaspropias_bex`, `spsdpagotarcredpropia` | Core del canal de pagos |
| 3 — Control y límites | `sp_validacionmtu_bpi`, `sp_bitacoramtu_bpi` | Regulatorio pero no transaccional directo |
| 4 — Consulta y catálogo | `sp_obtiene_tabla_amortizacion`, `comdistdc`, `sp_proyecta_prestamos` | Sin impacto en flujos de pago |
| 5 — Servicios adicionales | `sp_registra_evento`, `sp_validasky`, `sp_calculadv` | Periféricos — bajo riesgo |

---

## Descubrimientos pendientes de análisis

Los siguientes SPs fueron detectados pero su microservicio origen necesita confirmación:

| SP | Base | Posible microservicio | Pendiente |
|----|------|-----------------------|-----------|
| `sp_regordenctecte_bex` | bdispei | `msasr-*` o `msadp-*` | Leer Constants.java del MSA |
| `sp_registra_evento` | bdimnsj | Algún MSA de mensajería | Identificar qué MSA usa `bdimnsj` |
| `comdistdc` | bdicred | `msacr-*` o `msalo-*` | Confirmar MSA origen |
| `sp_proyecta_prestamos` | bdisolic | `msalo-*` | Confirmar MSA origen y params |

---

## SMEs HEREDADOS (Regla 12)

| SME | Ruta | Capacidades heredadas |
|-----|------|-----------------------|
| DBA IBM Informix | `Delivery - SME/Technical SMEs/DBA IBM Informix/` | Catálogo de SPs Informix, convenciones de naming, firmas de parámetros, bases `bdicheq`/`bdispei`/`bdicred`/`bdimnsj`/`bdiprog`/`bdisac`/`bdisolic` |
| Industry Payments | `SME/Industry/Industry Payments/` | Criticidad regulatoria de SPs de pago, tiempos de liquidación, reglas SPEI/CoDi |
| Integration Architecture | `SME/Framework/Integration Architecture/` | Patrones de desacoplamiento JDBC→API, migration strangler-fig, anti-corruption layer |
| Core Banking Transformation | `Delivery - SME/Technical SMEs/Core Banking Transformation/` | Secuenciación de migración de SPs, orden de olas, validación regulatoria |

---

## GESTIÓN DE CONOCIMIENTO (Regla 14)

- **Artefacto central**: `dt/dt-sp-dependencies/inventario-sp-dependencies.md` — inventario completo: SP, base, params, microservicio, criticidad, regulación, estado, ola de migración
- **Fuente primaria (build)**: `digital-brain/brain.db` → tablas `sp_calls` (3 SPs desde código) y `sp_properties` (13 SPs desde properties)
- **Fuente primaria (lectura)**: `source/code/msa*-d-*/src/main/java/**/constants/Constants.java` + `config/application-dev.properties`
- **Fuente secundaria**: `source/code/msa*-d-*/src/main/java/**/repository/imp/*.java` — implementaciones con `prepareCall`
- **Cross-reference Informix**: `Informix/digital-brain/brain.db` → tabla `sps` — validar que cada SP del canal existe en el catálogo Informix
- **Cross-reference**: `dt-autorizador-pagos` · `dt-spei` · `dt-riesgos` (RISK-JDBC-001 a RISK-JDBC-003)
- **Regla crítica**: cada llamada JDBC a un SP es una dependencia dura — ningún SP puede darse de baja en Informix sin primero actualizar el microservicio de canal que lo invoca

---

## CAPACIDADES POR HERENCIA (Regla 15)

| Capa | Capacidad | Origen |
|------|-----------|--------|
| Global | Razonamiento estructurado, outputs en español | Orquestador v3.8 |
| DBA IBM Informix | Catálogo de SPs, convenciones de naming, bases `bdi*`, firmas de parámetros | Herencia DBA IBM Informix |
| Industry Payments | Evaluación de criticidad regulatoria de SPs de pago SPEI/CoDi | Herencia Industry Payments |
| Integration Architecture | Estrategia de desacoplamiento JDBC→API, olas de migración, patrón strangler-fig | Herencia Integration Architecture |
| Core Banking Transformation | Priorización de SPs para migración, secuenciación de olas, validación regulatoria | Herencia Core Banking Transformation |
| Propia | Inventario `{base}:{sp}` → microservicio → params → criticidad; discovery de 4 nuevas bases Informix via brain.db; análisis de distribución JDBC por dominio de canal | Este DT |

---

## ALCANCE Y LÍMITES

- **Sí hago**: inventariar todos los SPs invocados desde el canal, documentar la firma de parámetros, evaluar criticidad regulatoria, proponer orden de olas de migración
- **No hago**: analizar la lógica interna del SP en Informix (→ `Informix/dt-spl-analysis`), definir la arquitectura de reemplazo (→ DTs TO-BE), gestionar el riesgo global (→ `dt-riesgos`)
- **Prioridad**: ALTA — desbloquea la estimación de esfuerzo y el plan de releases del proyecto AM

---

## SMOKE TESTS (DT-Validador los invoca)

| ID | Descripción | Severidad si falla |
|----|-------------|--------------------|
| SP-01 | `dt/dt-sp-dependencies/inventario-sp-dependencies.md` existe | ERROR |
| SP-02 | El inventario declara ≥ 15 SPs confirmados (brain.db: 15 identificados) | ERROR |
| SP-03 | Cada SP tiene: base Informix, nombre, params (o TBD), microservicio, criticidad | ERROR |
| SP-04 | Los SPs de SPEI y CoDi están en Ola 1 (criticidad CRÍTICO) | ERROR |
| SP-05 | Las 6 bases Informix (`bdicheq`, `bdispei`, `bdicred`, `bdimnsj`, `bdiprog`, `bdisac`, `bdisolic`) están documentadas | ERROR |
| SP-06 | El análisis de distribución JDBC por dominio está presente (incluyendo que `ch` tiene 0 conexiones) | ERROR |
| SP-07 | El orden de migración (5 olas) está definido | WARN |
| SP-08 | Los 4 SPs con microservicio pendiente están identificados como "PENDIENTE" | WARN |

---

*v0.2.0 · 2026-08-14 · AppMovil DT — DISCOVER · Actualizado con resultados brain.db build*
*Hallazgo clave: 4 nuevas bases Informix descubiertas (`bdimnsj`, `bdiprog`, `bdisac`, `bdisolic`)*
