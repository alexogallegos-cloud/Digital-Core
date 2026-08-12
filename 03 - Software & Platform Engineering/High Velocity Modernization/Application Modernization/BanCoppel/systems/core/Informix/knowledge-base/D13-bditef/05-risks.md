# D13 · Transferencias Electrónicas de Fondos (TEF) — Registro de Riesgos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — Core Banking Transformation (riesgos de migración)
- SME — DBA IBM Informix (riesgos técnicos de datos)
- SME Regulatorio — CNBV (riesgos regulatorios)
- Risk Officer — Modernización BCOPCore

---

## Escala de severidad

| Nivel | Descripción |
|-------|-------------|
| 🔴 CRÍTICO | Puede causar pérdida financiera, incumplimiento regulatorio o interrupción del servicio bancario |
| 🟠 ALTO | Impacta la equivalencia funcional o el plan de cutover |
| 🟡 MEDIO | Requiere decisión de diseño o validación adicional |
| 🟢 BAJO | Deuda técnica o mejora sugerida |

---

## Riesgos activos

### RSK-D13-001 · SPs aislados sin mapeo funcional
- **Severidad:** 🔴 CRÍTICO
- **Descripción:** 71 de los 139 SPs del dominio no aparecen en el callgraph y por tanto no fueron incluidos en los journeys, reglas ni vocabulario previo. Existe el riesgo de que alguno de ellos sea invocado por canales o jobs no documentados en el análisis actual.
- **Impacto:** Funcionalidad de producción que queda fuera del scope del target — potencial regresión post-cutover.
- **Mitigación:** Analizar cada SP aislado contra logs de producción para confirmar si tiene llamadas activas. Ver `09-dead-code.md` para clasificación detallada.
- **Estado:** ABIERTO

### RSK-D13-002 · Dependencias cross-DB con `bdicheq` (Wave 3 simultánea)
- **Severidad:** 🔴 CRÍTICO
- **Descripción:** `bditef` tiene múltiples dependencias cross-DB con `bdicheq` (cheques): tablas `sc_maechq`, `sc_fechas`, `sc_movdia`, `sc_movhis`, `sc_comisiones`, `sc_ctabloqueo`, y llamadas a SPs `abono_ref` y `cargo_ref`. Ambas bases de datos están en Wave 3.
- **Impacto:** Si `bdicheq` migra antes o después de `bditef`, el período de convivencia expone inconsistencias de tipos, encoding y transacciones distribuidas.
- **Mitigación:** Coordinar migración simultánea de `bditef` y `bdicheq` en el mismo sprint de cutover o implementar API adapter layer. Ver `13-external-dependencies.md`.
- **Estado:** ABIERTO

### RSK-D13-003 · Código ESB — 5 códigos de error sin runbook (INC-005)
- **Severidad:** 🔴 CRÍTICO
- **Descripción:** Los códigos ESB 4394, 3743, 3701, 3165 y 6233 afectan el flujo TEF y no tienen runbook ni mapeo en el target. Frecuencia combinada estimada de ~4,150 errores/día en el bus.
- **Impacto:** Post-migración, el microservicio `TransferenciasService` no tendrá contrato de errores definido para estos casos.
- **Mitigación:** Documentar en `06-exceptions.md`. Definir errores tipados en el API contract antes de BUILD. Ver `16-api-contract.md`.
- **Estado:** ABIERTO · Ver `06-exceptions.md`

### RSK-D13-004 · Aritmética financiera en Informix `money` vs. PostgreSQL `numeric`
- **Severidad:** 🟠 ALTO
- **Descripción:** `cargo_cta` tiene 8 fórmulas financieras con tipo `money` de Informix (BR-D13-025 a BR-D13-034). El tipo `money` de Informix usa reglas de redondeo/truncamiento específicas (`trunc(...,2)`) que pueden diferir del comportamiento por defecto de PostgreSQL `numeric`.
- **Impacto:** Divergencia de centavos en comisiones e IVA — riesgo de diferencia en cuadraturas contables y reporte regulatorio.
- **Mitigación:** Crear golden master test con valores de producción conocidos para cada fórmula antes de migrar. Ver `10-test-strategy.md`.
- **Estado:** ABIERTO

### RSK-D13-005 · Folio de operación — algoritmo dependiente de hora del servidor
- **Severidad:** 🟠 ALTO
- **Descripción:** El folio único se construye como `pusuario || hora_actual || ultimos_4_digitos_cuenta` (BR-D13-024). En el target distribuido con múltiples instancias, la hora del servidor ya no es un elemento suficiente para garantizar unicidad.
- **Impacto:** Riesgo de colisión de folios en escenarios de alta concurrencia.
- **Mitigación:** Diseñar generador de folios idempotente en `TransferenciasService` (UUID v4 o secuencia distribuida). Documentar en `16-api-contract.md`.
- **Estado:** ABIERTO

### RSK-D13-006 · Conversión de formato de fecha `%m/%d/%Y` → `date` PostgreSQL
- **Severidad:** 🟡 MEDIO
- **Descripción:** Múltiples SPs reciben fechas como `char(10)` con formato `%m/%d/%Y` (americano) y las convierten internamente con `to_date(v_fechai,"%m/%d/%Y")`. El target debe manejar la misma convención o transformar en la capa de API.
- **Impacto:** Error de parseo de fechas en casos de migración o llamadas a la API del target con formato diferente.
- **Mitigación:** Definir contrato de formato de fecha en el API contract. Ver `16-api-contract.md`.
- **Estado:** ABIERTO

### RSK-D13-007 · Token SINTÉTICO `?_pre_fh` y `?ret` sin grounding
- **Severidad:** 🟡 MEDIO
- **Descripción:** Los tokens `?_pre_fh` (en `cal_fecha_pre_fh`, `cal_fecha_pre_fh_web`, `cal_fechapre`) y `?ret` (en `cal_fecharet`) no tienen evidencia en el vocab ni en el cuerpo del código. Su significado exacto es incierto.
- **Impacto:** Posible malinterpretación del comportamiento de cálculo de fechas.
- **Mitigación:** Sesión de validación con Domain Expert BanCoppel.
- **Estado:** ABIERTO

### RSK-D13-008 · Código de devolución CECOBAN `"18"` potencialmente obsoleto
- **Severidad:** 🟡 MEDIO
- **Descripción:** El comentario en `cargo_cta` L456 indica que el motivo `"18"` fue cambiado al `"53"` en 2012 por petición de CECOBAN. El código puede haber sufrido más cambios en los 14 años posteriores.
- **Impacto:** Envío de códigos de devolución incorrectos a CECOBAN post-migración — rechazo de operaciones.
- **Mitigación:** Validar catálogo vigente de códigos CECOBAN con SME Regulatorio CNBV antes de BUILD.
- **Estado:** ABIERTO

### RSK-D13-009 · Dependencia de `bdinteg:si_feriado` para calendario hábil
- **Severidad:** 🟡 MEDIO
- **Descripción:** La lógica de días hábiles depende del catálogo `bdinteg:si_feriado` (cross-DB). Si este catálogo no se migra o no se mantiene actualizado en el target, las transferencias podrían habilitarse en días no operativos.
- **Impacto:** Envío de transferencias en días no hábiles — rechazo por CECOBAN y posible multa regulatoria.
- **Mitigación:** Incluir `bdinteg:si_feriado` en el plan de migración de datos maestros. Ver `17-data-migration-plan.md`.
- **Estado:** ABIERTO

---

## Matriz de riesgos

| ID | Probabilidad | Impacto | Severidad | Propietario |
|----|-------------|---------|-----------|-------------|
| RSK-D13-001 | ALTA | MUY ALTO | 🔴 CRÍTICO | Specialist Informix SPL |
| RSK-D13-002 | ALTA | MUY ALTO | 🔴 CRÍTICO | Architect Target |
| RSK-D13-003 | ALTA | ALTO | 🔴 CRÍTICO | SME Core Banking |
| RSK-D13-004 | MEDIA | ALTO | 🟠 ALTO | Data Architect |
| RSK-D13-005 | MEDIA | ALTO | 🟠 ALTO | Architect Target |
| RSK-D13-006 | BAJA | MEDIO | 🟡 MEDIO | API Designer |
| RSK-D13-007 | BAJA | MEDIO | 🟡 MEDIO | Domain Expert BanCoppel |
| RSK-D13-008 | MEDIA | MEDIO | 🟡 MEDIO | SME CNBV |
| RSK-D13-009 | BAJA | ALTO | 🟡 MEDIO | Data Architect |

---
*Generado por análisis de sp-specs-bditef.md + INC-005 + análisis de dependencias cross-DB*
