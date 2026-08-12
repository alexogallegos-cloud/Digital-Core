# D13 · Transferencias Electrónicas de Fondos (TEF) — Reglas de Negocio y Fórmulas

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (extracción directa del código)
- Domain Expert — BanCoppel (validación funcional)
- SME Regulatorio — CNBV (`SME/Regulatory/CNBV/`) — SPEI/TEF, horarios operativos, montos límite
- SME Regulatorio — CONDUSEF (`SME/Regulatory/CONDUSEF/`) — comisiones, reversos, reclamaciones

> Secciones marcadas `[SME-PENDING]` requieren validación antes de BUILD.
---

## Resumen

**Reglas extraídas directamente del código** por análisis estático de los 139 SPs del dominio. Las reglas de alto riesgo de equivalencia están marcadas con 🔴.

---

## BR-D13 · Reglas de validación de entrada (evidencia directa en código)

| ID | SP · línea | Tipo | Código extraído | Riesgo equivalencia |
|----|-----------|------|----------------|---------------------|
| BR-D13-001 | `abono_cta` L47 | VALIDACIÓN_NULL | `if trim(pcuenta) = "" or pcuenta is null` | MEDIO |
| BR-D13-002 | `cargo_cta` L167 | VALIDACIÓN_NULL | `if trim(pcuenta) = "" or pcuenta is null or pnrocheque = "" or pnrocheque < 1` | MEDIO |
| BR-D13-003 | `cons_dev_coppel` L84 | VALIDACIÓN_NULL | `IF pempresa is null or ...` | BAJO |
| BR-D13-004 | `cal_fecha_pre_fh` L30 | VALIDACIÓN_NULL | `IF v_fechai is null THEN` | BAJO |
| BR-D13-005 | `cal_fechapre` L57 | VALIDACIÓN_NULL | `IF pempresa is null or ...` (múltiples parámetros) | BAJO |
| BR-D13-006 | `cal_fechapre` L78 | VALIDACIÓN_NULL | `IF v_paramhora is null THEN` | MEDIO — hora de corte crítica |
| BR-D13-007 | `cal_habil_ant` L30 | VALIDACIÓN_NULL | `IF pfecha is null THEN` | BAJO |

---

## BR-D13 · Reglas de negocio de calendario y días hábiles

| ID | SP · línea | Tipo | Código extraído | Significado |
|----|-----------|------|----------------|-------------|
| BR-D13-010 | `cal_fecha_pre_fh` L59 | FÓRMULA | `LET v_fecha = v_fecha + 1` | Avanza un día si es feriado |
| BR-D13-011 | `cal_fecha_pre_fh` L64 | FÓRMULA | `LET v_fecha = v_fecha + 1` | Avanza un día adicional (sábado → lunes) |
| BR-D13-012 | `cal_fecha_pre_fh` L68 | FÓRMULA | `LET v_fecha = v_fecha + 2` | Avanza dos días (domingo → martes) |
| BR-D13-013 | `cal_fecha_pre_fh` L72 | FÓRMULA | `LET v_fecha = v_fecha + 1` | Día hábil siguiente al feriado |
| BR-D13-014 | `cal_habil_ant` L59 | FÓRMULA | `LET v_fecha = v_fecha - 1` | Retrocede un día para obtener hábil anterior |
| BR-D13-015 | `cal_habil_ant` L64 | FÓRMULA | `LET v_fecha = v_fecha - 1` | Retrocede por sábado |
| BR-D13-016 | `cal_habil_ant` L68 | FÓRMULA | `LET v_fecha = v_fecha - 1` | Retrocede por domingo |
| BR-D13-017 | `cal_habil_ant` L72 | FÓRMULA | `LET v_fecha = v_fecha - 2` | Retrocede por puente |
| BR-D13-018 | `cal_fechapre` L44 | FÓRMULA | `LET v_fecha = to_date(v_fechai,"%m/%d/%Y")` | Conversión de formato de fecha entrada |

> **Nota crítica de equivalencia:** La lógica de días hábiles está distribuida entre `cal_fecha_pre_fh`, `cal_fechapre`, `cal_fecharet` y `cal_habil_ant`. El catálogo de feriados vive en `bdinteg:si_feriado` (cross-DB). Esta lógica debe migrar a un servicio centralizado `CalendarService` en el target. Consultar `SME/Regulatory/CNBV/` para confirmar el calendario oficial de días hábiles bancarios 2026+.

---

## BR-D13 · Reglas de cargo en cuenta (evidencia directa en código de `cargo_cta`)

| ID | SP · línea | Tipo | Código extraído | Riesgo equivalencia |
|----|-----------|------|----------------|---------------------|
| BR-D13-020 | `cargo_cta` L366 | FÓRMULA | `let vmotdevol = "09"; -- cuenta bloqueada` | ALTO — bloqueo de cuenta |
| BR-D13-021 | `cargo_cta` L373 | FÓRMULA | `let vmotdevol = "09"; -- cuenta bloqueada` (segunda condición de bloqueo) | ALTO |
| BR-D13-022 | `cargo_cta` L384 | FÓRMULA | `let vmotdevol = "09"; -- cuenta bloqueada` (tercera condición de bloqueo) | ALTO |
| BR-D13-023 | `cargo_cta` L456 | FÓRMULA | `let vmotdevol = "18"; -- se cambio por la 53 a petición de CECOBAN. 30-07-2012. JGP.` | ALTO — código CECOBAN histórico |
| BR-D13-024 | `cargo_cta` L548 | FÓRMULA | `let vfolio = pusuario \|\| to_char(current hour to fraction,"%H%M%S") \|\| substr(pcuenta, length(pcuenta)-3, 4)` | ALTO — algoritmo de folio único |
| BR-D13-025 | `cargo_cta` L661 | FÓRMULA | `LET vMontoDif = pimporte - vsdodisp` | 🔴 MONEY/aritmética financiera |
| BR-D13-026 | `cargo_cta` L673 | FÓRMULA | `let vimportecom = vsdodisp / (1 + viva)` | 🔴 MONEY/cálculo de comisión con IVA |
| BR-D13-027 | `cargo_cta` L674 | FÓRMULA | `let vmontopend = vimporte - vimportecom` | 🔴 MONEY/monto pendiente |
| BR-D13-028 | `cargo_cta` L706 | FÓRMULA | `let viva_cob = trunc((vimportecom * viva),2)` | 🔴 MONEY/truncamiento de IVA a 2 decimales |
| BR-D13-029 | `cargo_cta` L710 | FÓRMULA | `LET viva_cob = vsdodisp - vimportecom` | 🔴 MONEY/cálculo alternativo de IVA |
| BR-D13-030 | `cargo_cta` L776 | FÓRMULA | `let vstatchq = "N"; -- presentado en cam, no pagado` | Estado cheque en cámara |
| BR-D13-031 | `cargo_cta` L785 | FÓRMULA | `let vstatchq = "M"; -- pagado por cámara` | Estado cheque pagado |
| BR-D13-032 | `cargo_cta` L848 | FÓRMULA | `let vimportecom = vsdodisp / (1 + viva)` | 🔴 MONEY/comisión cheque gratis |
| BR-D13-033 | `cargo_cta` L849 | FÓRMULA | `let vmontopend = vcomchqgratis - vimportecom` | 🔴 MONEY/pendiente cheque gratis |
| BR-D13-034 | `cargo_cta` L878 | FÓRMULA | `let viva_cob = trunc((vimportecom * viva),2)` | 🔴 MONEY/IVA truncado |

---

## BR-D13 · Reglas regulatorias TEF/CECOBAN

| ID | Regulador | Regla | Estado |
|----|-----------|-------|--------|
| BR-D13-REG-001 | CNBV | Las transferencias TEF deben procesarse dentro de horarios hábiles definidos por Banxico (típicamente 06:00–18:30 hrs días hábiles) | `[SME-PENDING]` confirmar horario exacto con CNBV |
| BR-D13-REG-002 | CNBV | El folio de operación debe ser único e irrepetible en el día — algoritmo en BR-D13-024 | VERIFICADO en código |
| BR-D13-REG-003 | CNBV | Los archivos de cámara CECOBAN deben seguir los formatos 10, 60, 61, 62, 63 de CECOBAN | VERIFICADO en callgraph |
| BR-D13-REG-004 | CNBV | Los motivos de devolución deben usar los códigos oficiales CECOBAN (ej. "09" = cuenta bloqueada, "18" = motivo cambiado a 53 en 2012) | VERIFICADO en código — BR-D13-023 tiene evidencia histórica de cambio |
| BR-D13-REG-005 | CONDUSEF | Las devoluciones de transferencias por causas imputables al banco deben procesarse en el plazo establecido | `[SME-PENDING]` plazo exacto en días |
| BR-D13-REG-006 | CNBV | La bitácora de operaciones TEF debe conservarse mínimo 5 años (Circular Única de Bancos) | Tabla `tef_bitacora` es el artefacto de cumplimiento |
| BR-D13-REG-007 | CNBV | Las transferencias que implican saldo insuficiente deben rechazarse con código normalizado antes de enviarse a CECOBAN | BR-D13-025 — diferencia de monto calculada |

---

## Reglas por regulador (SME dueño)

- **CNBV** (`SME/Regulatory/CNBV/`) — horarios operativos, formatos CECOBAN, conservación de registros, montos límite
- **CONDUSEF** (`SME/Regulatory/CONDUSEF/`) — comisiones (BR-D13-026 a BR-D13-034), reclamaciones de devoluciones

---

## `[SME-PENDING]` Validación regulatoria

- [ ] Confirmar el horario operativo exacto de TEF con Banxico/CECOBAN (BR-D13-REG-001).
- [ ] Validar el monto límite máximo por transferencia TEF vigente.
- [ ] Confirmar los códigos de devolución CECOBAN vigentes (el código `"53"` reemplazó al `"18"` en 2012 — ¿hay actualizaciones posteriores?).
- [ ] Definir golden master test para cada fórmula financiera de `cargo_cta` (BR-D13-025 a BR-D13-034).
- [ ] Confirmar la tasa de IVA aplicable a comisiones de transferencias (16% estándar o 8% frontera).

---
*Generado por análisis estático de sp-specs-bditef.md · Etapa 3*
