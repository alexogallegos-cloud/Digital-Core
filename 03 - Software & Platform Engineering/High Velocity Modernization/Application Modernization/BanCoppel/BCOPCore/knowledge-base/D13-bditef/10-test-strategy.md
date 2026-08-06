# D13 · Transferencias Electrónicas de Fondos (TEF) — Estrategia de Pruebas

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- QA Lead — Equivalencia Funcional BCOPCore
- Specialist — Informix SPL Analysis (golden master)
- SME Regulatorio — CNBV (escenarios de prueba regulatorios)
- Domain Expert — BanCoppel (escenarios de negocio)

---

## Enfoque shift-left

Los casos de prueba se identifican en la fase DISCOVER/DESIGN antes de BUILD. La estrategia de equivalencia funcional es el criterio go/no-go del cutover.

---

## Niveles de prueba

### Nivel 1 — Pruebas unitarias de SP (golden master)

Para cada SP del callgraph activo se debe capturar un snapshot de entrada → salida desde producción antes de la migración.

**Criterio de cobertura mínima:** 100% de los 30 procesos de negocio del catálogo (`00-business-process-catalog.md`).

**Casos prioritarios de golden master:**

| Caso | SP | Escenario | Tipo de prueba |
|------|----|-----------|---------------|
| TC-D13-001 | `cargo_cta` | Cargo exitoso con saldo suficiente — sin comisión | Golden Master |
| TC-D13-002 | `cargo_cta` | Cargo con saldo insuficiente (BR-D13-025) | Golden Master |
| TC-D13-003 | `cargo_cta` | Cargo rechazado por cuenta bloqueada (BR-D13-020 a BR-D13-022) | Golden Master |
| TC-D13-004 | `cargo_cta` | Cargo con comisión — cálculo IVA completo (BR-D13-026 a BR-D13-034) | Golden Master 🔴 |
| TC-D13-005 | `abono_cta` | Abono exitoso con cuenta válida | Golden Master |
| TC-D13-006 | `abono_cta` | Abono rechazado por cuenta nula (BR-D13-001) | Golden Master |
| TC-D13-007 | `cal_fecha_pre_fh` | Cálculo de fecha hábil — día normal | Golden Master |
| TC-D13-008 | `cal_fecha_pre_fh` | Cálculo de fecha hábil — viernes (saltar a lunes) | Golden Master |
| TC-D13-009 | `cal_fecha_pre_fh` | Cálculo de fecha hábil — día feriado | Golden Master |
| TC-D13-010 | `cal_habil_ant` | Cálculo de día hábil anterior — lunes (retrocede a viernes) | Golden Master |
| TC-D13-011 | `sp_tef_grabaoperacion` | Registro exitoso de operación TEF | Golden Master |
| TC-D13-012 | `sp_tef_reversoperacion` | Reverso exitoso de operación en el mismo día | Golden Master |
| TC-D13-013 | `sp_tef_validahorario` | Transferencia dentro del horario hábil | Golden Master |
| TC-D13-014 | `sp_tef_validahorario` | Transferencia fuera del horario hábil (rechazo) | Golden Master |
| TC-D13-015 | `sp_tef_valida_datos` | Validación con datos completos y válidos | Golden Master |
| TC-D13-016 | `sp_tef_valida_datos` | Validación con banco destino inválido | Golden Master |
| TC-D13-017 | `sp_tef_procesararchivo60` | Procesamiento de archivo formato 60 válido | Golden Master Batch |
| TC-D13-018 | `sp_tef_generararchivo60` | Generación de archivo formato 60 | Golden Master Batch |
| TC-D13-019 | `sp_consultarepop_tef` | Consulta de operaciones por rango de fecha | Golden Master |
| TC-D13-020 | `sp_tef_moverregistroshist` | Archivado de registros históricos | Golden Master Batch |

---

### Nivel 2 — Pruebas de equivalencia funcional

Comparación entrada/salida entre el sistema legacy Informix y el microservicio target `TransferenciasService`. Criterio: resultados idénticos hasta el centavo.

**Casos de equivalencia financiera (🔴 riesgo alto — obligatorios):**

| Caso | Escenario | Tolerancia aceptada |
|------|-----------|---------------------|
| TC-D13-EQ-001 | Comisión con IVA completo — `vimportecom = vsdodisp / (1 + viva)` | Cero diferencia |
| TC-D13-EQ-002 | Truncamiento de IVA a 2 decimales — `trunc((vimportecom * viva),2)` | Cero diferencia |
| TC-D13-EQ-003 | Monto diferencia por saldo insuficiente — `pimporte - vsdodisp` | Cero diferencia |
| TC-D13-EQ-004 | Cálculo alternativo de IVA cobrado — `viva_cob = vsdodisp - vimportecom` | Cero diferencia |
| TC-D13-EQ-005 | Folio único generado — misma lógica de concatenación | Misma longitud y formato |

---

### Nivel 3 — Pruebas de integración cross-DB

Validan que el microservicio target acceda correctamente a los datos migrados de `bdicheq` y `bdinteg`.

| Caso | Descripción |
|------|-------------|
| TC-D13-INT-001 | `cargo_cta` → consulta `sc_maechq` en target PostgreSQL: resultados equivalentes |
| TC-D13-INT-002 | `cargo_cta` → consulta `sc_ctabloqueo` en target: cuentas bloqueadas correctamente identificadas |
| TC-D13-INT-003 | `cal_fecha_pre_fh` → consulta `si_feriado` en target: calendario hábil correcto |
| TC-D13-INT-004 | `abono_cta` → consulta `sc_fechas` en target: fecha de proceso correcta |

---

### Nivel 4 — Pruebas de regresión ESB

Validan los 5 códigos de error INC-005 con el sistema de monitoreo del target.

| Caso | Código ESB | Escenario a simular |
|------|-----------|---------------------|
| TC-D13-ESB-001 | 4394 | IBM MQ no disponible — `TransferenciasService` lanza `MQUnavailableException` |
| TC-D13-ESB-002 | 3743 | Sistema TEF timeout — circuit breaker activa y retorna `TimeoutException` |
| TC-D13-ESB-003 | 3701 | Error JNI/Axis2 — `TransferenciasService` retorna error tipado |
| TC-D13-ESB-004 | 3165 | SSL error — alerta en runbook operacional |
| TC-D13-ESB-005 | 6233 | `[SME-PENDING]` — hasta identificar causa raíz |

---

### Nivel 5 — Pruebas de aceptación regulatoria (UAT)

Requieren participación de SME Regulatorio CNBV y Domain Expert BanCoppel.

| Caso | Regulación | Escenario |
|------|-----------|-----------|
| TC-D13-UAT-001 | CNBV | Formato de archivo CECOBAN 60 generado cumple especificación vigente |
| TC-D13-UAT-002 | CNBV | Horario de corte TEF respetado — operaciones fuera de horario rechazadas |
| TC-D13-UAT-003 | CNBV | Bitácora `tef_bitacora` contiene todos los campos regulatorios requeridos |
| TC-D13-UAT-004 | CONDUSEF | Devoluciones procesadas dentro del plazo establecido |
| TC-D13-UAT-005 | CNBV | Códigos de devolución CECOBAN vigentes utilizados en reversos |

---

## Criterios go/no-go para cutover

| Criterio | Umbral mínimo |
|----------|--------------|
| Golden master unitario | 100% de los 20 casos TC-D13-001 a TC-D13-020 pasan |
| Equivalencia financiera | 100% de los 5 casos EQ — tolerancia cero en centavos |
| Integración cross-DB | 100% de los 4 casos INT pasan |
| Pruebas de regresión ESB | TC-D13-ESB-001 a ESB-004 pasan (ESB-005 pendiente de identificar código 6233) |
| UAT regulatoria | 100% de TC-D13-UAT-001 a UAT-003 — críticos CNBV |

---

## `[SME-PENDING]`

- [ ] Obtener datos de producción para construir golden master de `cargo_cta` con comisiones.
- [ ] Definir entorno de pruebas con snapshot de `bdicheq:sc_maechq` representativo.
- [ ] Confirmar plazo de ejecución de UAT con BanCoppel antes del cutover Wave 3.
- [ ] Identificar representante de CNBV/CECOBAN para validación de formato de archivos.

---
*Generado con shift-left QA · identificación de casos en DISCOVER/DESIGN antes de BUILD*
