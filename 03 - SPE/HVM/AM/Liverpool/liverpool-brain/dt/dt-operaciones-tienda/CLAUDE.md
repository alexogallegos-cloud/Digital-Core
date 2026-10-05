# Digital Twin — Operaciones de Tienda (Bridgecore + POS)
> `liverpool-brain/dt/dt-operaciones-tienda/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-08
> **[STATE: ACTIVE — scaffold; fuente de datos pendiente]**

## Propósito

Gemelo digital de las operaciones en el piso de venta de las ~130 tiendas Liverpool: Bridgecore como gateway POS exclusivo de Liverpool, los terminales punto de venta, Base24 como switch transaccional para autorizaciones de tarjeta, y la integración con SAP ECC y Mainframe para contabilización.

Bridgecore es el sistema más desconocido y con mayor riesgo de lock-in del landscape: es un desarrollo exclusivo de Liverpool o un vendor de nicho, con dependencias directas hacia SAP, Mainframe y Servicios Financieros. Sin este DT, la modernización del retail físico (el canal donde Liverpool genera la mayor parte de sus ingresos) es incompleta.

## Capa de Arquitectura

**Channels (SoD)** — Canal físico de venta

## Dominios Principales

R06 — Operaciones de Tienda
R03 — Servicios Financieros (transacciones con tarjeta)
R07 — Finanzas y Contabilidad (cierre de caja, contabilización de ventas)

## Sistemas Involucrados

| Sistema | Vendor | Rol |
|---------|--------|-----|
| **Bridgecore** | Bridgecore (exclusivo LIV) | Gateway POS — intermedia entre terminales de tienda y SAP/Mainframe |
| **Base24** | ACI Worldwide | Switch transaccional — autorización de pagos con tarjeta (POS, ATM) |
| **SAP ECC (SD/FI)** | SAP | Receptor de ventas de tienda — pedidos, facturas, contabilización |
| **VPL Vision Plus** | FIS Global | Autorización LiverpoolCard en POS (vía Base24) |

## Flujo del Proceso AS-IS (Tienda)

```
CLIENTE EN TIENDA
    │
    │  Presenta producto en caja
    ▼
TERMINAL POS (tienda)
    │
    │  Venta / pago
    ▼
BRIDGECORE (Gateway POS)
    │
    ├── Si pago con tarjeta:
    │     │
    │     ▼
    │   BASE24 (switch)
    │     │
    │     ├── LiverpoolCard → VPL Vision Plus → autorización
    │     ├── Visa/MC/Amex → red interbancaria → autorización
    │     └── Débito → PROSA → autorización
    │
    ├── Independiente del pago:
    │     │
    │     ▼
    │   SAP ECC (SD)
    │     │  · Creación de orden de venta
    │     │  · Actualización de inventario (MM)
    │     │  · Contabilización (FI)
    │     └── Envío a BW LIV (extractores)
    │
    └── Si venta con puntos Liverpool:
          │
          ▼
        SIEBEL CRM (redención de puntos)

CIERRE DE CAJA (nocturno):
  Bridgecore → Control-D (batch) → SAP FI (conciliación) → Mainframe Clientes
```

## Señales del AS-IS

| Señal | Impacto | Evidencia |
|-------|---------|-----------|
| Bridgecore exclusivo de LIV (no SBB) | Suburbia tiene una arquitectura POS diferente — cualquier unificación de canal físico LIV+SBB requiere resolver esta divergencia | Dashboard AS-IS |
| Dependencia crítica: Bridgecore ↔ SAP | Una migración SAP ECC → S/4HANA que cambie las APIs de SD/FI impacta directamente a Bridgecore — esfuerzo no cuantificado | Arquitectura AS-IS |
| Base24 como switch único | Todos los pagos de tienda pasan por Base24 — SLA de disponibilidad de tienda depende de este sistema | Dashboard AS-IS |
| ~130 tiendas Liverpool | Cualquier rollout tecnológico en tienda requiere gestión de cambio y logística para 130 ubicaciones | Información pública Liverpool |

## Hipótesis 7R para Este Módulo

| Sistema | Hipótesis | Fundamento |
|---------|-----------|-----------|
| **Bridgecore** | **Repurchase** | Si Bridgecore es un vendor de nicho, el riesgo de soporte a largo plazo es alto. Opciones: Oracle Retail Xstore POS, Manhattan Active POS, o solución basada en commercetools POS. Requiere validar si Bridgecore es vendor externo o desarrollo interno Liverpool. |
| **Bridgecore** | **Retain + API-fy** | Si Liverpool tiene IP sobre Bridgecore, podría exponerlo como servicio vía Apigee y mantenerlo a mediano plazo mientras madura el stack digital. |
| **Base24** | **Retain** | Switch transaccional con certificación PCI-DSS — altísimo costo y riesgo de reemplazar. La estrategia es Retain y modernizar las interfaces hacia Apigee. |
| **Integración Bridgecore ↔ SAP** | **Replatform** | La interfaz actual es directa; post-migración S/4HANA debe pasar por Apigee como API Gateway para desacoplar. |

**`[DATO-REQUERIDO]`**: ¿Bridgecore es un producto de un vendor externo o un desarrollo interno de Liverpool? Esta pregunta determina completamente la estrategia 7R.

## Estado

`[STATE: ACTIVE — scaffold]` — DT creado 2026-09-08.
Fuentes de datos primarias (`[DATO-REQUERIDO]`): documentación Bridgecore (vendor, versión, interfaces), inventario de terminales POS, volumen de transacciones diarias, SLA de disponibilidad en tienda.

## Fuentes de Datos Disponibles

- [x] Dashboard AS-IS (existencia y rol de Bridgecore + Base24)
- [ ] Identificación del vendor de Bridgecore (¿externo o desarrollo propio?)
- [ ] Volumen de transacciones: ventas/día por tienda, pico (Buen Fin, navidad)
- [ ] Interfaces activas: Bridgecore ↔ SAP, Bridgecore ↔ Base24, Bridgecore ↔ Mainframe
- [ ] SLA de disponibilidad en tienda (uptime requerido en horario comercial)
- [ ] Arquitectura POS de Suburbia (para comparar con LIV y evaluar unificación)
- [ ] Certificaciones PCI-DSS: alcance de Base24 y Bridgecore

## Dependencias Cross-DT

- `dt-sap-doble-landscape` → la migración SAP ECC → S/4HANA cambia las APIs de SD/FI que consume Bridgecore — es una dependencia crítica que puede bloquear el cutover SAP
- `dt-mainframe-core` → el cierre de caja de Bridgecore alimenta Mainframe Clientes vía Control-D batch nocturno
- `dt-liverpoolcard` → Base24 autentica LiverpoolCard en POS — la disponibilidad de VPL Vision Plus impacta directamente la experiencia de pago en tienda
- `dt-bus-integracion` → la estrategia de convergencia IBM IIB → Apigee debe considerar las interfaces de Bridgecore; si Bridgecore conecta directo a SAP (sin IIB), el blast radius de la migración IIB→Apigee es menor
- `dt-ecommerce-transicion` → commercetools POS (si Liverpool lo elige) reemplazaría a Bridgecore — la decisión de Bridgecore 7R debe coordinarse con el roadmap de commercetools