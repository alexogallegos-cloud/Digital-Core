# Flujos del Mecanismo CAN — Art. 63 Bis 3 (Cecoban)
> **Fuente:** Documento de Entendimiento CAN v4.2 · 25/08/2026 · GT de CAN - ABM · Cecoban
> **Versión:** 1.0.0 · 2026-09-17 · dt-de-can

---

## Principios del mecanismo

1. **Cecoban es el único intermediario** — ningún banco se comunica directamente con otro banco para CAN.
2. **UUID es la llave del ciclo de vida** — Cecoban asigna un UUID en el C-50; ese UUID debe preservarse en todos los mensajes del mismo ciclo.
3. **La prelación es exclusiva de Cecoban** — los bancos nunca calculan prelación; solo la aplican.
4. **CURP + CLABE identifican al nominado** — cada registro en Cecoban está ligado al CURP del nominado y a la CLABE de su cuenta ordenante.
5. **TLS 1.3 + Certificados Cecoban** — toda comunicación requiere el certificado emitido por Cecoban para el ambiente correspondiente.

---

## Flujo 1: Solicitud CAN Interbancario (nuevo)

**Descripción:** Santander desea otorgar un CAN a un nominado que tiene su cuenta de nómina en otro banco.

```
Santander (Acreedora)          Cecoban                    Banco Ordenante
        │                         │                               │
        │── C-50 (POST) ─────────→│                               │
        │   CURP, RFC, CLABE       │                               │
        │   nominado, banco ord    │                               │
        │   Folio, UUID=∅          │                               │
        │                         │── UUID asignado               │
        │                         │── C-50 (retransmite) ────────→│
        │                         │                               │ ← 30 seg máx
        │                         │←── C-51 (respuesta) ─────────│
        │                         │   Info nominado + 6 meses     │
        │                         │   Créditos Mis to Mis          │
        │                         │   Periodicidad / Frecuencia   │
        │←── C-51 (retransmite) ──│                               │
        │                         │                               │
        │ [Análisis crédito 48h]  │                               │
        │                         │                               │
        │── C-52 (otorgamiento) ──→│                               │
        │   UUID mismo, crédito #  │                               │
        │   Monto, tasa, plazo     │                               │
        │                         │── C-53 (prelación) ──────────→│
        │                         │   Orden completo CANs         │
        │                         │   del nominado                │
```

**SLAs:**
- C-51: Banco Ordenante debe responder en **30 segundos**
- C-52: Santander (Acreedora) tiene **48 horas** para enviar o desistir
- Cecoban procesa cada mensaje en **30 segundos**

**Impacto Santander como Acreedora:**
- El sistema de originación de crédito debe disparar el C-50 al momento de la solicitud del cliente
- Debe esperar el C-51 (máx 48h + tiempo procesamiento Cecoban)
- Tiene 48 horas para decidir si envía C-52 o abandona la solicitud

**Impacto Santander como Depositaria (cuando el otro banco solicita):**
- El middleware de integración Cecoban recibe el C-50 del otro banco
- Debe consultar core bancario Santander en tiempo real y responder C-51 en **30 segundos**
- Al recibir C-52, actualiza el registro de prelación (sin validación — solo registra)
- Al recibir C-53, actualiza el orden de prelación en core bancario Santander

---

## Flujo 2: Actualización de crédito CAN (Banco Acreedora)

**Descripción:** Santander modifica condiciones de un CAN existente (nuevo monto, baja, etc.)

```
Santander (Acreedora)          Cecoban                    Banco Ordenante
        │                         │                               │
        │── C-55 (actualización) ─→│                               │
        │   UUID, crédito #         │                               │
        │   Nuevo estatus           │                               │
        │   (02=Baja liq, 06=Cond) │                               │
        │                         │                               │
        │                         │ [Si estatus 02 ó 03]          │
        │                         │── C-53 (nueva prelación) ────→│
```

**Estatus que generan C-53:** 02 (baja liquidación) y 03 (baja sustitución) — al removerse un crédito de la prelación, Cecoban recalcula y transmite el nuevo orden.

---

## Flujo 3: Cancelación de domiciliación por el nominado

**Descripción:** El nominado en Santander solicita que ya no se descuenten los CANs de su nómina.

```
Santander (Depositaria)        Cecoban                    Banco(s) Otorgante(s)
        │                         │                               │
        │── C-54 (estatus 04) ───→│                               │
        │   CURP nominado          │                               │
        │   Cancelación domicil.  │                               │
        │                         │                               │
        │                         │── C-55 generado? ────────────→│
        │                         │   (Cecoban notifica a         │
        │                         │   Banco(s) Otorgante)         │
```

> **Nota:** Al recibir C-54 con estatus 04, Cecoban notifica a todos los bancos otorgantes que tienen CANs activos sobre la cuenta de ese nominado. Los bancos otorgantes reciben de manera implícita que deben actualizar sus registros.

---

## Flujo 4: Cuenta Ordenante bloqueada o cerrada

**Descripción:** Santander detecta que la cuenta de nómina de un nominado fue bloqueada o cerrada.

```
Santander (Depositaria)        Cecoban
        │                         │
        │── C-54 (estatus 08) ───→│  [Cuenta bloqueada]
        │   CURP nominado          │
        │── C-54 (estatus 07) ───→│  [Cuenta cerrada]
        │── C-54 (estatus 05) ───→│  [Sin depósitos ≥ 2 meses]
```

**Triggers para ControlM (jobs batch):**
- Cierre de cuenta → disparar C-54 (estatus 07) ese mismo día
- Bloqueo de cuenta → disparar C-54 (estatus 08)
- Detección de 2 meses consecutivos sin depósito de nómina → C-54 (estatus 05)

---

## Flujo 5: Cambio de Banco Ordenante

**Descripción:** Un nominado con CANs activos cambia su cuenta de nómina a Santander.

```
Santander (Nuevo Depositaria)  Cecoban               Bancos Otorgantes (varios)
        │                         │                               │
        │── C-56 (cambio banco) ──→│                               │
        │   CURP, CLABE anterior   │                               │
        │   CLABE nueva en BanCop  │                               │
        │   RFC patrón, fecha alta │                               │
        │                         │                               │
        │                         │── C-57 (info créditos) ──────→│ (a CADA Banco Otorgante)
        │                         │   Todos los CANs activos      │
        │                         │   del nominado                │
        │←── C-57 (mismo) ────────│                               │
        │   (Santander también     │                               │
        │   recibe si es Acreedora)│                               │
        │                         │                               │
        │←── C-53 (nueva prelación)│                               │
        │   con CLABE de Santander │                               │
```

**Impacto para Santander como Nuevo Banco Ordenante:**
- Al dar de alta la dispersión de nómina de un nominado que viene de otro banco, debe enviarse C-56
- Cecoban retorna C-57 con todos los CANs activos → Santander los registra en core bancario Santander
- Cecoban envía C-53 con la prelación aplicable → Santander aplica el orden de descuento

---

## Flujo 6: CAN Propio (Santander Acreedora y Depositaria)

**Descripción:** Santander otorga un CAN a un nominado que tiene su nómina en Santander.

```
Santander (Acreedora + Depositaria)     Cecoban
        │                                  │
        │── C-58 (CAN propio) ────────────→│
        │   CURP, crédito #                 │
        │   Monto, tasa, plazo             │
        │   CLABE crédito + CLABE ordenante │
        │                                  │
        │                                  │ [Cecoban registra en DB]
        │                                  │ [No transmite a otros bancos]
        │                                  │
        │←── C-53 (prelación actualizada) ─│
        │   Si hay otros CANs del nominado  │
```

**Implicaciones:**
- Los CANs propios existentes deben registrarse en Cecoban al arrancar el proyecto (migración inicial)
- El C-58 es solo registro; no genera ninguna transmisión a terceros
- Cecoban mantiene la prelación global aunque sea CAN propio

---

## Flujo 7: Reconsulta de información del nominado

**Descripción:** Si los datos del C-51 son insuficientes o cambiaron, el Banco Otorgante puede volver a consultar.

```
Santander (Acreedora)          Cecoban                    Banco Ordenante
        │                         │                               │
        │── C-50 (reconsulta) ───→│                               │
        │   Mismo CURP, nuevo folio│                               │
        │                         │── C-50 (retransmite) ────────→│
        │                         │←── C-51 (respuesta nueva) ───│
        │←── C-51 (retransmite) ──│                               │
```

**Regla:** La ventana de reconsulta es de **48 horas** desde el C-51 original. Fuera de ese plazo, se debe iniciar un nuevo ciclo con C-50.

---

## Estados del crédito CAN en Cecoban

```
[C-52] Otorgamiento ──────────────────────────────→ Estatus 01: ACTIVO
                                                            │
                    ┌───────────────────────────────────────┤
                    │                                       │
            [C-55 estatus 02]                    [C-55 estatus 06]
            Baja por liquidación                Actualización condiciones
                    │                                       │
                    ↓                                       ↓
            Estatus 02: BAJA LIQ                Estatus 01: ACTIVO (nuevo monto)
                    
[C-55 estatus 03] → Estatus 03: BAJA SUSTITUCIÓN
[C-55 estatus 04] → Estatus 04: CANCELACIÓN DOMICILIACIÓN
[C-54 estatus 04] → Cecoban notifica → Banco Otorgante puede enviar C-55 estatus 04
```

---

## Environments requeridos por Santander

| Ambiente | Propósito | Certificado Cecoban |
|----------|-----------|---------------------|
| **Desarrollo** | Desarrollo y pruebas unitarias | Certificado DEV (Cecoban) |
| **QA** | Pruebas de integración interna | Certificado QA (Cecoban) |
| **UAT** | Pruebas de aceptación con Cecoban | Certificado UAT (Cecoban) |
| **Producción** | Operación real | Certificado PROD (Cecoban) |
| **DRP** | Contingencia (Disaster Recovery) | Certificado DRP (Cecoban) |

> Santander debe solicitar a Cecoban los 5 certificados. Si se usa el enlace existente de la Cámara de Compensación (SPEI), verificar si acepta el mismo enlace o requiere uno independiente.

---

## Checklist de integración Cecoban — Santander

### Pre-requisitos técnicos
- [ ] Contrato de adhesión al servicio CAN firmado con Cecoban
- [ ] Definición de enlace: usar existente (SPEI/DOMI) o nuevo enlace dedicado
- [ ] Solicitud de certificados TLS 1.3 para los 5 ambientes
- [ ] Alta de IP fija de Santander en Cecoban (whitelisting)
- [ ] Definición de URLs endpoint (Cecoban publica los endpoints por ambiente)

### Pre-requisitos funcionales
- [ ] Stored Procedure en core bancario Santander para historial de 6 meses de abonos por CURP
- [ ] SP de consulta de CANs y créditos Mis to Mis vigentes por nominado
- [ ] SP de consulta de periodicidad y frecuencia de dispersión por cuenta
- [ ] Validación de que CURP está registrado para todas las cuentas con dispersión activa
- [ ] Definición del proceso de alta de C-58 para CANs propios existentes (migración inicial)
- [ ] Proceso batch para generar C-54 cuando eventos de cuenta se presentan

### Pruebas con Cecoban (UAT)
- [ ] Prueba de C-50/C-51 con datos de nominado sandbox de Cecoban
- [ ] Validación de SLA C-51 ≤ 30 segundos bajo carga
- [ ] Prueba de C-52/C-53 (otorgamiento + prelación)
- [ ] Prueba de C-54 para cada estatus (04, 05, 07, 08, 10, 11)
- [ ] Prueba de C-55 (actualización condiciones y bajas)
- [ ] Prueba de C-56 (cambio de banco ordenante)
- [ ] Prueba de C-58 (CAN propio)
- [ ] Prueba de rechazo: C-51 fuera de 30 segundos (causa 36)
- [ ] Prueba de rechazo: UUID incorrecto (causa 02)

---

*v1.0.0 · 2026-09-17 · DE CAN v4.2 (GT de CAN - ABM, Cecoban) · dt-de-can*
