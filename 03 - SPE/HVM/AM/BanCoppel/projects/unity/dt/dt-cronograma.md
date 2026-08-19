# DT-Cronograma — Cronograma y Hitos Unity R4

> **Tipo:** Digital Twin — Programa Unity  
> **Versión:** v1.1.0  
> **Estado:** `[STATE: ACTIVE]`  
> **Fuentes:** Minutas R4 (17 docs) · Plan de trabajo R4_v1 Julio.pptx (baseline original) · brain.db v1.0.0  
> **Última actualización:** 2026-08-17

---

## Línea de Tiempo R4

```
[HOY: 2026-08-15]
  
  AGO 2026          SEP 2026          OCT 2026          NOV 2026          DIC 2026         ENE 2027
  │                 │                 │                 │                 │                │
  ├── ANÁLISIS Y DISEÑO (en curso) ──────────────┤ 16 oct             │                 │
  │                                              │ ↑ Cierre análisis   │                 │
  │                                              ├──────────────────────────── SIT ──────┤ 15 dic
  │                                              │ ↑ 15 oct Inicio SIT                   │ ↑ Code Freeze
  │                                              │                     │                 │
  │                                ┌── Dev/UT ───┤ 15 oct              │                 │
  │                                │             ↑ Cierre dev + UT     │                 │
  │                                │                     │             │                 │
  │                                │             ╔═══ RIESGO: CAT inicia aquí optimista  │
  │                                │             │  y 6 User Stories APP cierran en NOV ══════╗   │
  │                                │             │                 │   │               ║   │
  │                                │             │                 ├───┼── Pentest ────╢   │
  │                                │             │                 │ 15 nov Cobranza  ║   │
  │                                │             │                 │   │ 20 nov        ║   │
  │                                │             │                 │   │               ╚═══╡
  │                                │             │                 │                 │   │
  ▼                                │             │                 │                 │   ▼
  [Hoy]                            │             │                 │                 │  [Go-Live ~15 ene]
                                   └─────────────┘                 └─────────────────┘
```

---

## Hitos del Programa

### MS-UNITY-001 — Cierre de Análisis y Diseño

| Campo | Valor |
|-------|-------|
| **Fecha target** | 16 de octubre 2026 |
| **Estado** | `pending` |
| **Componente** | SmartVista / Apolo (últimos en cerrar) |

El análisis y diseño de todos los componentes debe estar cerrado antes de que el SIT de ese componente inicie. El último track en cerrar es SmartVista/Apolo (16 oct). Nota: el SIT inicia simultáneamente el 15 de octubre — hay una superposición de 1 día que debe coordinarse.

---

### MS-UNITY-002 — Cierre de Desarrollo y Unit Testing

| Campo | Valor |
|-------|-------|
| **Fecha target** | 15 de octubre 2026 |
| **Estado** | `pending` |
| **Componente** | Todos los componentes |

Todos los componentes deben cerrar desarrollo y UT antes del inicio del SIT. **Excepción documentada:** 6 User Stories Must Have de APP cierran en noviembre — esto es un riesgo activo (RISK-UNITY-002).

---

### MS-UNITY-003 — Inicio SIT

| Campo | Valor |
|-------|-------|
| **Fecha target** | 15 de octubre 2026 |
| **Estado** | `at_risk` |
| **Componente** | Todos |

Inicio del System Integration Testing del Producto 4900. Duración total: 60 días (15 oct – 15 dic).

**Componentes con riesgo en SIT:**
- CAT: proveedor no contratado — puede no participar desde el inicio
- APP: 6 User Stories Must Have cierran en noviembre — entran tardías al SIT
- SIWEB: bloqueado por APIs — puede no estar listo para el inicio

---

### MS-UNITY-004 — Pentest Cobranza

| Campo | Valor |
|-------|-------|
| **Fecha target** | 15–20 de noviembre 2026 |
| **Estado** | `at_risk` |
| **Componente** | Cobranza Direccionada |

El pentest de seguridad de Cobranza está programado dentro de la ventana de SIT. El riesgo es que el ambiente de Cobranza quede congelado durante el pentest, bloqueando pruebas integrales de cobranza dentro del SIT. Ver RISK-UNITY-003.

---

### MS-UNITY-005 — Fin SIT y Code Freeze

| Campo | Valor |
|-------|-------|
| **Fecha target** | 15 de diciembre 2026 |
| **Estado** | `pending` |
| **Componente** | Todos |

Cierre del SIT y congelamiento definitivo del código. Ningún cambio de código está permitido después de esta fecha sin proceso de excepción (CAB + owner de riesgo).

---

### MS-UNITY-006 — Go-Live Producto 4900

| Campo | Valor |
|-------|-------|
| **Fecha target** | Mediados de enero 2027 (~15 enero) |
| **Estado** | `pending` |
| **Componente** | Todos |

Lanzamiento productivo de la Tarjeta de Crédito Clásica Digital (Producto 4900) en SmartVista. La fecha exacta está sujeta al resultado del SIT.

**Pre-requisitos para Go-Live (identificados en minutas):**
- SIT verde en todos los componentes Must Have
- Pentest de Cobranza completado y remediado
- Connect Direct automatizado (o proceso manual documentado y aceptado)
- IBR / CAT funcionando (o plan de exclusión documentado)
- Proveedor(es) de maquila confirmados (Forza / TGS / Tales)
- eGlobal valida 88 reglas ISO 8583 en SmartVista

---

## Cronograma por Componente

| Componente | Cierre Análisis | Cierre Dev/UT | Entrada SIT | Go-Live |
|------------|----------------|---------------|-------------|---------|
| SmartVista | 16-oct | 15-oct | 15-oct | ene-2027 |
| APOLO | 16-oct | 15-oct | 15-oct | ene-2027 |
| APP | — | nov-2026 ⚠️ | oct-2026 (parcial) | ene-2027 |
| CAT | — | TBD ⚠️ | TBD ⚠️ | ene-2027 |
| SIWEB | — | TBD ⚠️ | TBD ⚠️ | ene-2027 |
| Cobranza | — | 15-oct | 15-oct | ene-2027 |
| Apificación | Transversal | Transversal | Transversal | ene-2027 |

⚠️ = componente en riesgo o con fecha no confirmada

---

## Riesgos que Impactan el Cronograma

| Riesgo | Hito afectado | Impacto |
|--------|--------------|---------|
| RISK-001 (CAT sin proveedor) | MS-003, MS-006 | CAT puede no estar en SIT ni en Go-Live |
| RISK-002 (6 User Stories APP en nov) | MS-003, MS-005 | APP entra parcial al SIT |
| RISK-003 (Pentest Cobranza) | MS-003, MS-004 | Cobranza bloqueada 1 semana en SIT |
| RISK-009 (Ambiente IBR) | MS-003 | IBR no disponible para pruebas CAT |
| RISK-004 (APIs SIWEB) | MS-002, MS-003 | SIWEB no puede desarrollar ni entrar a SIT |
| RISK-008 (Latencia Apolo) | MS-003, MS-006 | Performance gate en SIT puede bloquear |

---

## Baseline Original — Plan de trabajo Julio 2026

> Fuente: `Plan de trabajo R4_v1 Julio.pptx` (procesado 2026-08-17). Establece el point-in-time de compromisos originales para medir la desviación actual.

### Scope comprometido en Julio

| Canal / Plataforma | Funcionalidades TDC R4 | Nota |
|-------------------|------------------------|------|
| SmartVista (BPC) | 7 | Procesador de tarjeta |
| App Móvil (AppWhere) | 7 | Canal digital |
| CAT | 3 | Canales adicionales transaccionales |
| **Promotoría** | **1** | Canal de fuerza de ventas ⚠️ ver abajo |
| **Total TDC** | **18** | Tarjeta de Crédito Clásica Digital |
| Onboarding Digital (Apolo) | 27 | Proceso de alta de cliente nuevo |
| **Total R4** | **45** | TDC + Onboarding Digital |

> ⚠️ **Promotoría**: canal con 1 funcionalidad en el scope original que **no aparece en el track_rag actual** (5 tracks). Requiere verificación con PMO: ¿fue absorbido por otro track, diferido a R5, o descartado? Hasta confirmar, es un riesgo de scope invisible.

### Funcionalidades explícitamente fuera de scope R4

Las siguientes funcionalidades fueron **confirmadas como out-of-scope** en el Plan de Julio y no deben incluirse en la medición de avance:
- Disposición de efectivo en cajeros ATM (se trabaja en SV; R5 la consume desde APP)
- MCI — Motor de Crédito Institucional (ídem — R5)
- Tarjetas adicionales
- Incrementos de línea de crédito
- Pago en corresponsales

> SmartVista trabaja Disposición de efectivo y MCI en R4 para que en **R5** la APP los consuma. Esto confirma la dependencia SV→APP entre releases.

### Funcionalidades Apolo diferidas a R5

- Cliente prospecto (alta de prospectos sin crédito aprobado)
- Retoma de solicitud (solicitudes abandonadas o en proceso incompleto)

### Compromisos de análisis firmados en Junio

| Stakeholder | Fecha compromiso | Alcance |
|-------------|-----------------|---------|
| Luis Barragán | 12-jun-2026 | Cierre de análisis fase 1 (tracks comprometidos) |
| Octavio Vázquez | 12-jun-2026 | Validación funcional canal App |
| Pablo Madinaveitia | 19-jun-2026 | Revisión de arquitectura / integraciones |
| José Luis Bueno | 12-jun-2026 | Sign-off funcional negocio TDC |

> Estos son los stakeholders con compromisos formales al inicio del R4. Su visibilidad es importante para la gestión de bloqueadores actuales.

### Riesgos identificados en Julio (verificación al corte actual)

| Riesgo identificado en Jul-2026 | ID actual | Estado al 2026-08-17 |
|--------------------------------|-----------|-----------------------|
| Tiempo de mesas de trabajo para generación de DTMs y DTCs | RISK-UNITY-R01 | 🔴 ABIERTO — bloqueador crítico activo |
| Salir a Mercado Abierto sin retoma/recovery compromete tasa de conversión | RISK-UNITY-R06 | 🟡 ABIERTO — sin plan formal |

> Los riesgos identificados hace **6 semanas** en el Plan de Julio permanecen abiertos sin cierre. Esto evidencia que el programa no tiene mecanismo de cierre de riesgos cross-track.

---

## Semáforo del Programa (al 2026-08-15)

| Dimensión | Estado |
|-----------|--------|
| Cronograma general | 🟡 EN RIESGO |
| Cobertura de canales | 🔴 CRÍTICO (CAT sin proveedor) |
| Integraciones | 🟡 EN RIESGO (inventario incompleto) |
| Calidad / Performance | 🟡 EN RIESGO (Apolo latencia) |
| Seguridad | 🟡 EN RIESGO (Pentest vs SIT) |
| Gobierno / Sign-off | 🔴 CRÍTICO (sin sign-off formal negocio) |

---

*Generado desde: minutas R4 · brain.db v1.0.0 · Plan de trabajo R4_v1 Julio.pptx (baseline original)*  
*Versión: v1.1.0 · Actualizado: 2026-08-17 · Añadido: Baseline Original Julio 2026 (scope 45 User Stories, Promotoría, stakeholders, riesgos Jul aún abiertos)*
