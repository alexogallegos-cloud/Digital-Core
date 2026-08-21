# DT — SIWEB / Sistema de Sucursales (Canal Ventanilla)
> Digital Twin del track SIWEB (Sistema de Banca por Internet / Sucursales) para la Tarjeta de Crédito R4 (Producto 4900).
> Fuente primaria: `20260805 - R4 SIWEB - Analisis detallado HDUs e Integraciones.docx`
> Fuente secundaria: `Consolidacion y priorizacion_HUs_R4_v2.xlsx`
> Sesión de análisis: 2026-08-05
> Última actualización: 2026-08-20 · v1.0.0

---

## Resumen del Track

| Campo | Valor |
|-------|-------|
| Track ID | `siweb` |
| Tipo | channel (Sistema de Sucursales — ventanillas y caja) |
| Proveedor | Interno BanCoppel |
| Status | 🟡 Bloqueado (sin APIs de Apificación) |
| User Stories totales | 5 |
| MoSCoW | 0 Must · 5 Should · 0 Could · 0 Won't |
| RAG | 🟡 YELLOW (general y solución) · 🔴 RED (integraciones) |
| Sesión de análisis | 2026-08-05 |
| Source doc | `20260805 - R4 SIWEB - Analisis detallado HDUs e Integraciones.docx` |

> **Perfil del track:** SIWEB es el canal de menor alcance en R4 — las 5 User Stories son todas Should y gestionan operaciones de compras diferidas (MCI/MSI) desde sucursal (caja/ventanilla). El proveedor es interno BanCoppel, lo que elimina el riesgo de contratación. El riesgo dominante es la dependencia de los DTMs de Apificación (Appwhere) para confirmar fechas de implementación.

> **Nota de nomenclatura:** "SIWEB" se refiere al sistema de operaciones en sucursal (ventanilla/caja), no a un portal de banca por internet para clientes. Las User Stories son operaciones que ejecutan los cajeros de sucursal, no el titular de la tarjeta.

---

## MoSCoW del Track

| MoSCoW | Cuenta | Notas |
|--------|--------|-------|
| Must | 0 | Ninguna User Story es Must en R4 |
| Should | 5 | Todo el alcance SIWEB es Should |
| Could | 0 | — |
| Won't | 0 | — |
| **Total** | **5** | Menor alcance del programa |

> Las 5 User Stories son Should Have. Si hay presión de cronograma, SIWEB es el primer candidato a diferir. Sin embargo, la cancelación de planes diferidos (HDU-R4-03) requiere el módulo DPP que tampoco está contratado — lo que convierte ese User Story en Not Covered por licencia, independientemente del MoSCoW.

### Distribución por Tipo de Solución y Complejidad

| Tipo | Cuenta | Complejidad | Cuenta |
|------|--------|-------------|--------|
| Solución e Integración | 5 | Media | 5 |
| Nuevo Desarrollo (<20% reutilización) | 5 | Alta | 0 |

---

## User Stories (hdu_catalog) — 5 User Stories

Cobertura: **3 partial + 1 not_covered + 1 tbd** = 5 total.

### SIWEB-MF-01 — Operaciones de Compras Diferidas en Sucursal

| ID | Narrativa corta | Capability | PreGame | Notas |
|----|----------------|-----------|---------|-------|
| HDU-SIWEB-R4-01 | Consultar saldos y movimientos de TDC en SIWEB (`getInstantCreditStatement`) | CAP-BALANCE-STATEMENT | partial | APIs SVIP disponibles; UI SIWEB a construir; distinción `amountHoldPlaced` |
| HDU-SIWEB-R4-02 | Procesar compras diferidas MCI/MSI en SIWEB (Transacción 623) | CAP-DEFERRED-PURCHASE | partial | MCI via SmartVista DPP; MSI via E-Global; cierre automático depende de módulo DPP no contratado |
| HDU-SIWEB-R4-03 | Cancelar plan de compras diferidas desde SIWEB | CAP-DEFERRED-PURCHASE | **not_covered** | **GAP CRÍTICO:** módulo DPP no contratado — cancelación automática no disponible en R4 |
| HDU-SIWEB-R4-04 | Registrar efectos contables de compras diferidas (TRNT SmartVista-SIWEB-PISA) | CAP-ACCOUNTING-INTEGRATION | partial | Guía contable formal pendiente (BanCoppel); Grupo 13; NO cuenta 2402/E-Global |

### SIWEB-MF-02 — Control de Saldo a Favor en Caja

| ID | Narrativa corta | Capability | PreGame | Notas |
|----|----------------|-----------|---------|-------|
| HDU-SIWEB-R4-05 | Validar límite de saldo a favor en transacciones de caja (ventanilla) | CAP-OVERPAYMENT | **tbd** | Bloqueado por ticket BYU0039 — misma dependencia que SMART-R4-13 |

---

## User Stories Inventory (USI v2) — 5 User Stories

Fuente: `Consolidacion y priorizacion_HUs_R4_v2.xlsx`

| ID | Título USI | MoSCoW | Complejidad | Tipo |
|----|-----------|--------|-------------|------|
| HDU-SIWEB-R4-01 | Adelantar pago parcial en SIWEB | Should | Media | Sol. e Integración |
| HDU-SIWEB-R4-02 | Liquidar compra diferida en SIWEB | Should | Media | Sol. e Integración |
| HDU-SIWEB-R4-03 | Cancelar compra diferida en SIWEB | Should | Media | Sol. e Integración |
| HDU-SIWEB-R4-04 | Registrar efectos contables de pagos fijos | Should | Media | Sol. e Integración |
| HDU-SIWEB-R4-05 | Validar el límite de saldo a favor en transacciones de caja | Should | Media | Sol. e Integración |

> **Discrepancia de títulos documentada:** los títulos en USI v2 difieren de las narrativas en hdu_catalog. Ejemplo: HDU-SIWEB-R4-01 dice "Adelantar pago parcial" en USI y "Consultar saldos y movimientos" en hdu_catalog. Ambos son válidos — el hdu_catalog refleja el delta técnico; la USI refleja la acción de negocio desde la perspectiva del cajero.

---

## Integraciones del Track SIWEB

El inventario de integraciones R4 (`Inventario de Integraciones_HUs_ R4_v1.0.xlsx`) registra las integraciones SIWEB dentro del **track SmartVista** (ISV03–ISV07). Las 4 integraciones que involucran SIWEB son:

| ID | Nombre | Origen | Destino | Tipo | Estado | User Story SIWEB |
|----|--------|--------|---------|------|--------|-----------|
| ISV03 | Consulta de lotes por sucursal y lote | SIWEB | SMARTVISTA | API | Modificar | R4-01 |
| ISV04 | Visualización nombres normativos de comisiones — SIWEB | SMARTVISTA | SIWEB | API | Modificar | R4-01 |
| ISV06 | `GetDPP` — Selección de transacciones DPP | SMARTVISTA | SIWEB | API | Nueva | R4-02/03 |
| ISV07 | Clearing Operation — Pago Anticipado | SMARTVISTA | SIWEB | API | Modificar | R4-02 |

> **Nota:** el número total de integraciones específicas de SIWEB está pendiente de confirmar. Apificación entregó DTMs el 2026-08-18; la sesión técnica de cierre de brechas estaba acordada para la semana del 2026-08-10. Los 4 IDs anteriores son los registrados en el inventario, pero pueden existir integraciones adicionales no listadas aún.

---

## Capabilities Impactadas

| Capability | Cobertura | Build | Bloqueante | Notas |
|-----------|----------|-------|-----------|-------|
| CAP-DEFERRED-PURCHASE | partial | not_built | DPP-GAP (módulo no contratado) | HDU-03 (cancelación) requiere módulo DPP no licenciado; HDU-02 (liquidación) avanza parcialmente |
| CAP-BALANCE-STATEMENT | partial | not_built | — | APIs SVIP disponibles; UI SIWEB pendiente |
| CAP-ACCOUNTING-INTEGRATION | partial | not_built | — | TRNT 623 = "PAGO CGO A CTA DE CREDISOLUCIONES"; guía contable BanCoppel pendiente |
| CAP-OVERPAYMENT | tbd | dependency | BYU0039 | Ticket SmartVista bloqueando validación en runtime; reutiliza validación centralizada SVIP |
| CAP-ERROR-CATALOG | partial | not_built | — | SIWEB debe consumir catálogo SV dinámicamente en lugar de valores hardcodeados |
| CAP-CHANNEL-SELFSERVICE | not_covered | not_built | RISK-001 | CAT bloqueado; SIWEB es parte del canal pero no el crítico |

### Gap de Licencia — Módulo DPP

El módulo **DPP (Deferred Payment Plan)** de SmartVista no está contratado para BanCoppel. Este módulo es necesario para:
- HDU-SIWEB-R4-03: cancelación automática de planes diferidos
- Cierre automático del pago fijo en HDU-SIWEB-R4-02

**Opciones a resolver:**
1. Contratar módulo DPP con BPC (SmartVista)
2. Desarrollar alternativa propia (mayor riesgo y esfuerzo)
3. Diferir HDU-SIWEB-R4-03 a R4.5 como Won't

Decisión accountable: PMO BanCoppel.

### Dependencia BYU0039

Ticket activo en SmartVista que bloquea la validación del límite de saldo a favor en runtime. Afecta simultáneamente SIWEB-R4-05 y SMART-R4-13. Hasta que BYU0039 no se resuelva, la cobertura de CAP-OVERPAYMENT permanece como `tbd`.

---

## Riesgos del Track

| ID | Descripción | Impacto | Prob. | Due Date | Status | Owner |
|----|-------------|---------|-------|----------|--------|-------|
| RISK-UNITY-R01 | Retraso DTMs Appware bloquea construcción en SIWEB (54% de User Stories sin delta técnico cerrado) | Alto | Alto | 2026-08-10 | 🟡 En seguimiento | Alfredo Aguilar (Appwhere) |
| RISK-UNITY-R07 | QA sin capacidad coordinada entre canales — SIWEB/CAT/SmartVista convergen sin calendario integrado | Medio | Alto | 2026-07-26 | 🔴 Vencido | Testing R4 |
| RISK-UNITY-R16 | Incompatibilidad SmartVista y legado detectada tarde en pruebas | Medio | Medio | Sin fecha | 🟡 Abierto | Armando Garcia (BanCoppel) |
| DPP-GAP | Módulo DPP no contratado — cancelación automática de diferidos bloqueada | Alto | Alto | — | 🔴 Abierto | PMO BanCoppel |
| BYU0039 | Ticket SmartVista sin resolver bloquea validación límite de saldo a favor (SIWEB + App) | Alto | Alto | — | 🔴 Abierto | Armando Garcia (BanCoppel) |

---

## Stakeholders

| Rol | Nombre | Empresa | Área |
|-----|--------|---------|------|
| Proveedor / Delivery | Interno BanCoppel | BanCoppel | Sucursales |
| DTMs (Apificación) | Alfredo Aguilar | Appwhere | Apificación SmartVista |
| SME Accenture | Core Banking Transformation | Accenture | DPP, saldos, integración |
| SME Contabilidad | Industry Banking Accounting | Accenture | TRNT 623, Grupo 13 |
| SME Infraestructura | DBA IBM Informix | Accenture | PISA, flujo TRNT→PISA |
| PM SmartVista (escalación DPP/BYU0039) | Armando Garcia | BanCoppel | SmartVista |
| Apificación (APIs) | Oscar Melo | Accenture | Integración SVIP |
| Contabilidad BanCoppel | J.A. Valverde / G. Martinez / S. Melo | BanCoppel | Guía contable TDC |

---

## Timeline

| Evento | Fecha | Status |
|--------|-------|--------|
| Sesión de análisis SIWEB R4 | 2026-08-05 | Completado |
| Sesión técnica Apificación + APIs SIWEB | ~2026-08-10 | Completado (tentativo) |
| Entrega DTMs por Apificación | 2026-08-18 | Esperado |
| Inicio construcción (desde DTMs) | ~2026-08-18 | Condicional |
| Fin construcción + UT (10 semanas desde 18-ago) | ~2026-10-29 | 🔴 2 semanas después del cierre |
| Inicio SIT (todos los componentes) | 2026-10-15 | En riesgo |
| Fin SIT / Code Freeze | 2026-12-15 | Pendiente |
| Go-Live Producto 4900 | 2027-01-15 | Pendiente |

> **Riesgo cronograma:** si la construcción inicia el 2026-08-18 y toma 10 semanas, termina el 2026-10-29 — 14 días después del arranque de SIT (2026-10-15). SIWEB entraría a SIT sin haber cerrado su construcción.

---

## Integración Contable — Flujo TRNT 623

El HDU-SIWEB-R4-04 registra los efectos contables de compras diferidas siguiendo este flujo:

```
SmartVista (evento diferido)
    ↓ TRNT 623 "PAGO CGO A CTA DE CREDISOLUCIONES"
SIWEB (registra operación en sucursal)
    ↓ integración contable
PISA / Informix (libro contable BanCoppel)
```

**Clasificación contable correcta:**
- Grupo 13 (compras diferidas MCI)
- **NO** cuenta 2402 / E-Global — esa aplica a MSI interchange, no a MCI

Guía contable formal de BanCoppel está pendiente como DATO-REQUERIDO (RISK-UNITY-R08, owner: J.A. Valverde).

---

## Gaps Críticos

| Gap ID | Descripción | Impacto | Status |
|--------|-------------|---------|--------|
| GAP-SIWEB-01 | Módulo DPP no contratado — HDU-R4-03 (cancelación) no ejecutable en R4 | Cajeros no pueden cancelar planes diferidos | 🔴 Abierto |
| GAP-SIWEB-02 | BYU0039 sin resolver — HDU-R4-05 en estado `tbd` | Validación de límite de saldo a favor en caja bloqueada | 🔴 Abierto |
| GAP-SIWEB-03 | Guía contable formal pendiente — HDU-R4-04 parcialmente indefinido | TRNT 623 sin instrucciones contables validadas por BanCoppel | 🟡 En seguimiento |
| GAP-SIWEB-04 | Número real de integraciones sin confirmar — inventario incompleto | No se puede planificar el esfuerzo completo de integración | 🟡 Esperando DTMs |
| GAP-SIWEB-05 | Construcción de 10 semanas desde 18-ago termina 2 semanas después del inicio de SIT | SIWEB entraría a SIT sin UT completo | 🔴 Riesgo cronograma |

---

## Relación con Otros Tracks

| Track | Dependencia |
|-------|------------|
| SmartVista | Las integraciones SIWEB (ISV03-07) se gestionan en el track SmartVista — Apificación es el puente. SIWEB depende de que SmartVista exponga los APIs de DPP, consulta de lotes y comisiones |
| E-Global | HDU-R4-02 (MSI) requiere integración con E-Global para el tramo de diferidos MSI — separado del tramo MCI (SmartVista) |
| Apolo | Sin dependencia directa en R4 — SIWEB opera con crédito 18 dígitos de SmartVista |
| Cobranza | Sin dependencia directa en R4 — cajero no gestiona cobranza |

---

## Pendientes

- [ ] Confirmar número total de integraciones SIWEB con Apificación (post-DTMs 18-ago)
- [ ] Resolver DPP-GAP: contratar módulo DPP, desarrollar alternativa, o diferir HDU-R4-03 a R4.5
- [ ] Resolver BYU0039 con Armando Garcia / BPC para desbloquear HDU-R4-05
- [ ] Obtener guía contable formal de BanCoppel (J.A. Valverde) para TRNT 623
- [ ] Revisar cronograma: inicio construcción 18-ago + 10 semanas = 29-oct es inviable para SIT 15-oct — definir plan de contingencia
- [ ] Confirmar si Appwhere está formalmente comprometido con DTMs/DTCs de SIWEB en R4

---

*Creado: 2026-08-20 · v1.0.0 · Fuente: `20260805 - R4 SIWEB - Analisis detallado HDUs e Integraciones.docx` + brain.db v1.4.0*