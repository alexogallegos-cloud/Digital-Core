# D14 · Banca Electrónica Institucional (BEI) — Reglas de Negocio y Fórmulas

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (extracción de reglas desde código SPL)
- Domain Expert — BanCoppel (validación funcional de reglas BEI)
- Industry Banking (BIAN Service Domains · banca electrónica institucional)
- SME Regulatorio — CNBV (`SME/Regulatory/CNBV/`) — límites de dispersión
- SME Regulatorio — CONDUSEF (`SME/Regulatory/CONDUSEF/`) — comisiones BEI
- SME Regulatorio — SAT (`SME/Regulatory/SAT/`) — IVA sobre comisiones

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---

## Resumen

**4 fórmulas verificadas** + **estimadas: 15-20 validaciones adicionales en los 294 SPs aislados** (pendientes de análisis Etapa 2). Reguladores con reglas: CNBV (límites y autorizaciones), CONDUSEF (comisiones), SAT (IVA).

## Fórmulas verificadas en código (sp-specs-bdibei.md)

| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-BEI-001 | `getrandomcode` L46 | operacional (seguridad) | `LET x = (a * x) + c` — LCG paso 1 | ALTO — semilla no criptográfica |
| BR-BEI-002 | `getrandomcode` L48 | operacional (seguridad) | `LET _x = x / m` — LCG módulo | ALTO |
| BR-BEI-003 | `getrandomcode` L50 | operacional (seguridad) | `LET y = 65 + (_x * (116 - 65))` — mapeo ASCII 65-116 (A-t) | MEDIO — rango fijo |
| BR-BEI-004 | `getrandomcode` L62 | operacional | `LET iRows = iRows + 1` — contador iteración | BAJO |

## Reglas de negocio inferidas del patrón BEI (pendientes de verificación en código)

> Estas reglas derivan del modelo operativo de banca electrónica institucional en México (CNBV, práctica de mercado) y deben verificarse contra el código de los 294 SPs aislados en Etapa 2.

| ID | Origen | Tipo | Regla | Regulador | `[SME-PENDING]` |
|----|--------|------|-------|-----------|:---:|
| BR-BEI-010 | Inferida (CNBV) | Límite | Monto máximo por dispersión individual definido en convenio empresa — no superable sin autorización adicional | CNBV | ✓ |
| BR-BEI-011 | Inferida (CNBV) | Límite | Suma de dispersiones del día no puede superar `monto_max_mensual` del convenio | CNBV | ✓ |
| BR-BEI-012 | Inferida (práctica) | Validación | CLABE de beneficiario debe tener exactamente 18 dígitos y dígito verificador correcto | Banxico (SPEI) | ✓ |
| BR-BEI-013 | Inferida (práctica) | Validación | RFC de empresa debe ser válido (estructura SAT — 12 chars persona moral) | SAT | ✓ |
| BR-BEI-014 | Inferida (práctica) | Control | No se puede dispersar en convenio con `ind_activo = 'B'` (bloqueado) | CNBV | ✓ |
| BR-BEI-015 | Inferida (práctica) | Control | La dispersión no puede ejecutarse después del `horario_max_dispersion` del convenio | operacional | ✓ |
| BR-BEI-016 | Inferida (práctica) | Cálculo | Comisión BEI = monto_dispersion × tasa_comisión_convenio / 100 | CONDUSEF | ✓ |
| BR-BEI-017 | Inferida (SAT) | Cálculo | IVA_comisión = comisión_BEI × (tasa_iva / 100); tasa=16% general / 8% frontera | SAT | ✓ |
| BR-BEI-018 | Inferida (Banxico) | Validación | Banco destino debe estar en catálogo SPEI activo de Banxico | Banxico | ✓ |
| BR-BEI-019 | Inferida (práctica) | Control | Archivo de nómina cargado no puede contener el mismo folio dos veces (idempotencia) | operacional | ✓ |
| BR-BEI-020 | Inferida (CONDUSEF) | Reverso | Reverso de dispersión solo aplicable dentro del día hábil de operación | CONDUSEF | ✓ |

## Regla crítica — OTP con LCG no criptográfico (BR-BEI-001 a 004)

El algoritmo en `getrandomcode` implementa un **generador congruencial lineal (LCG)**, que es determinístico y predecible con parámetros conocidos. Los parámetros `a`, `c`, `m` son constantes definidas en el SP.

**Riesgo de seguridad:** un atacante que conozca el último código generado puede calcular el siguiente. En autenticación bancaria, esto viola PCI-DSS requisito 8.3 (autenticación fuerte) y CNBV CUB Sec-III sobre mecanismos de autenticación.

**Recomendación para target:** reemplazar con `java.security.SecureRandom` (CSPRNG). El LCG no debe portarse al microservicio target. Ver `18-pii-security-assessment.md §BR-BEI-001`.

## Reglas por regulador

- **CNBV** — límites de dispersión, bloqueo de convenio, control operativo de empresa.
- **CONDUSEF** — comisiones BEI deben estar registradas y ser transparentes (LTOSF Art.17).
- **SAT** — IVA sobre comisiones de servicios financieros.
- **Banxico** — validación de CLABE y catálogo SPEI.

## `[SME-PENDING]` Validación regulatoria pendiente

- [ ] Verificar en código de los 294 SPs aislados todas las fórmulas de comisión y límite.
- [ ] Confirmar tasa de comisión BEI actual (varía por tamaño de empresa y volumen).
- [ ] Confirmar parámetros LCG de `getrandomcode` (constantes `a`, `c`, `m`, `k`).
- [ ] Validar si hay reglas de TESOFE para pagos de gobierno procesados vía BEI.
- [ ] Identificar reglas de reconciliación diaria de dispersiones (cierre de día).
- [ ] Verificar regla de corte horario para liquidación SPEI de dispersiones (típicamente: envío a Banxico antes de 17:00 h).

---
*Generado por: Specialist — Informix SPL Analysis · 2026-08-03 · Fuente: sp-specs-bdibei.md (BR-BEI-001..004 verificadas) + modelo operativo BEI inferido. Reglas BR-BEI-010..020 requieren verificación en código Etapa 2.*
