# DT — Solución Canales CAN · Santander México
> **Proyecto:** CAN · Santander México
> **Fase:** DESIGN / BUILD
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Define los cambios en los canales digitales de Santander (SuperMóvil y Santander Online)
requeridos para el cumplimiento CAN: pantallas de disclosure, captura del mandato digital,
comparativo CAN vs. no-CAN, visualización de prelación y notificaciones regulatorias al cliente.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Software Engineering | Desarrollo de pantallas · API contracts |
| Industry Banking | UX/UI bancaria regulatoria · experiencia del cliente |
| Regulatory/Banxico | Validación de textos legales requeridos por normativa |
| Core Banking Transformation | API backend expuesta a canales |

---

## Obligaciones con Impacto en Canales

| Obligación | Qué debe hacer el canal | Pantalla / flujo |
|-----------|------------------------|-----------------|
| OBL-005 | Capturar mandato del acreditado con autorización expresa CAN | Flujo de solicitud de crédito nómina |
| OBL-007 | Mostrar comparativo CAN vs. crédito no-CAN antes de contratar | Pantalla de oferta de crédito |
| OBL-014 | Informar al cuentahabiente su derecho a designar CANs en su cuenta | Pantalla de cuenta / mis productos |
| OBL-016 | Mostrar prelación de cargos activos en la cuenta | Detalle de cuenta + dashboard |
| OBL-018 | Capturar mandato del cuentahabiente para consultar CANs | Al abrir cuenta o designar como Cuenta Ordenante |

---

## Flujo 1 — Solicitud de Crédito de Nómina CAN (SuperMóvil / Santander Online)

```
[Paso 1] Cliente solicita crédito de nómina
    ↓
[Paso 2] Sistema muestra COMPARATIVO CAN vs. NO-CAN (OBL-007)
    ┌─────────────────────────────────────────────────┐
    │  CRÉDITO DE NÓMINA — COMPARATIVA               │
    │                                                   │
    │  Con CAN          │  Sin CAN (crédito regular)  │
    │  ─────────────    │  ─────────────────────────  │
    │  Tasa: X.XX%      │  Tasa: Y.YY%               │
    │  CAT: X.XX%       │  CAT: Y.YY%                │
    │  Cargo automático │  Pago manual requerido      │
    │  de nómina        │                             │
    │  Prelación en     │  Sin prelación garantizada  │
    │  Cuenta Ordenante │                             │
    └─────────────────────────────────────────────────┘
    ↓ Cliente elige CAN
[Paso 3] Sistema presenta MANDATO DIGITAL (OBL-005)
    ┌─────────────────────────────────────────────────┐
    │  AUTORIZACIÓN PARA CRÉDITO ASOCIADO A NÓMINA   │
    │                                                   │
    │  Autorizo expresamente a Banco Santander México │
    │  para:                                          │
    │  ✓ Solicitar información de mi Cuenta Ordenante │
    │  ✓ Requerir modificación del contrato de depó- │
    │    sito para domiciliar los pagos               │
    │  ✓ Gestionar la domiciliación a mi nombre       │
    │  ✓ Informar a otras instituciones la designa-   │
    │    ción de este crédito como CAN                │
    │                                                   │
    │  [ACEPTAR]      [CANCELAR]                      │
    └─────────────────────────────────────────────────┘
    ↓ Cliente acepta → captura biométrica / firma electrónica
[Paso 4] Sistema registra mandato en backend (→ dt-solucion-datos)
[Paso 5] Crédito CAN activado — se notifica al cliente
```

---

## Flujo 2 — Designación de Cuenta Ordenante (OBL-014 / OBL-018)

```
[Pantalla: Mis Cuentas → Cuenta de Nómina]
    ↓
[Banner informativo]
    ┌─────────────────────────────────────────────────┐
    │  Tu cuenta de nómina es una CUENTA ORDENANTE   │
    │                                                   │
    │  Tienes el derecho de designar tus créditos     │
    │  (con Santander u otras instituciones) para que │
    │  los pagos se descuenten automáticamente de     │
    │  tu nómina.                                     │
    │                                                   │
    │  [ADMINISTRAR MIS CRÉDITOS CAN]                 │
    └─────────────────────────────────────────────────┘
    ↓
[Pantalla: Gestión de CANs en mi cuenta]
    · Listado de CANs activos designados en esta cuenta
    · Prelación actual (orden de cargos) (OBL-016)
    · Botón: Designar nuevo crédito CAN
    · Botón: Cancelar designación CAN
```

---

## Flujo 3 — Vista de Prelación (OBL-016)

```
[Pantalla: Detalle de Cuenta Ordenante]

  ORDEN DE CARGOS EN TU NÓMINA
  ─────────────────────────────────────────────────────────
  1 │ Crédito Hipotecario Santander ···· $5,200.00 │ no-CAN
  ─────────────────────────────────────────────────────────
  2 │ Crédito Nómina CAN — Santander ··· $3,500.00 │ CAN ✓
    │  Designado el: 15-mar-2026
  ─────────────────────────────────────────────────────────
  3 │ Crédito Nómina CAN — Banco X ····· $2,100.00 │ CAN ✓
    │  Designado el: 20-mar-2026
  ─────────────────────────────────────────────────────────
  4 │ Domiciliación — CFE ·············· $850.00   │ servicio
  ─────────────────────────────────────────────────────────

  [¿Cómo funciona la prelación?] [i]
```

---

## Especificación de Pantallas

### Pantalla CAN-001 — Comparativo (OBL-007)

| Elemento | Especificación |
|---------|---------------|
| Trigger | Al seleccionar "Crédito de Nómina" en oferta de crédito |
| Contenido mínimo | Tasa, CAT, monto cuota, diferencias clave CAN vs no-CAN |
| Texto legal | Conforme a CONDUSEF (comunicación financiera) |
| Acción requerida | Cliente debe confirmar que vio la comparativa antes de continuar |
| `[DATO-REQUERIDO]` | Plantilla de texto aprobada por Legal/Compliance Santander |

### Pantalla CAN-002 — Mandato Digital (OBL-005)

| Elemento | Especificación |
|---------|---------------|
| Trigger | Después de aceptar oferta CAN |
| Contenido mínimo | Los 4 alcances del mandato per Art. 63 Bis párrafo 4 |
| Captura de consentimiento | Firma biométrica o token OTP + timestamp |
| PDF generado | Descargable por cliente + copia en backend |
| `[DATO-REQUERIDO]` | Texto legal validado por Legal Santander + Banxico |

### Pantalla CAN-003 — Derecho a designar (OBL-014)

| Elemento | Especificación |
|---------|---------------|
| Trigger | Al ingresar al detalle de Cuenta de Nómina |
| Contenido | Explicación del derecho + listado de CANs activos |
| CTA principal | "Administrar mis CANs" |
| Estado vacío | "No tienes créditos designados como CAN todavía" |

### Pantalla CAN-004 — Prelación (OBL-016)

| Elemento | Especificación |
|---------|---------------|
| Trigger | Desde Cuenta Ordenante → "Orden de cargos de nómina" |
| Contenido | Lista ordenada de todos los cargos (no-CAN previos + CANs por fecha + domiciliaciones) |
| Editable | El cliente NO puede cambiar el orden (lo define la normativa) |
| Informativo | Tooltip explicando la prelación legal |

---

## API Contracts (Backend → Canales)

```
GET  /api/v1/cuentas/{clabe}/cans
     → Lista de CANs designados + prelación

POST /api/v1/creditos/{id}/designar-can
     → Inicia flujo de designación CAN

POST /api/v1/mandatos
     → Registra mandato digital (OBL-005 / OBL-018)
     body: { tipo, pdf_base64, timestamp, canal, firma }

GET  /api/v1/cuentas/{clabe}/prelacion
     → Vista detallada de prelación para la cuenta

POST /api/v1/cuentas/{clabe}/cancelar-can
     → Cancela designación CAN (inicia flujo OBL-020)
```

---

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Wireframes / mockups pantallas CAN | `source/docs/canales/wireframes-can/` |
| Textos legales de mandato (OBL-005 / OBL-018) | `knowledge-base/rules/textos-mandato-can.md` |
| API contracts (OpenAPI) | `knowledge-base/rules/api-canales-can.yaml` |
| User Stories de canales | → alimenta `dt-roadmap-cambios` (US-SANT-CAN-007) |

## Dependencias

- `[DEPENDS-ON: dt-solucion-datos]` — estructura del mandato digital + prelación
- `[DEPENDS-ON: dt-solucion-arquitectura]` — API gateway y rutas
- `[DATO-REQUERIDO]` — Confirmar si SuperMóvil y Santander Online tienen un design system existente
- `[DATO-REQUERIDO]` — Textos legales validados por Legal / Compliance Santander
- `[DATO-REQUERIDO]` — Stack tecnológico de SuperMóvil (React Native / iOS nativo / Flutter)

*v0.1.0 · 2026-09-17 · fase DESIGN*
