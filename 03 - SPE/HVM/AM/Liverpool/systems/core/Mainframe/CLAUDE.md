# Mainframe — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · Mainframe Modernization L4 también aplicable
> Specialist activo: Mainframe Modernization Specialist - Reverse Engineering `[STATE: PROPOSED]`
> **ROL CONFIRMADO** — fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16)

```
# togaf_type: core
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: mainframe-transaction-core
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | IBM z/OS + aplicaciones nativas (VPL Vision Plus, SOMS, Mainframe Clientes, MARC 90) |
| Plataforma | IBM z/OS (Triara MTY — data center propio) |
| Lenguaje principal | COBOL / JCL + aplicaciones vendor (FIS Vision Plus) |
| Rol | Core de procesamiento LiverpoolCard + gestión de órdenes de entrega (SOMS) + contabilidad clientes |
| TOGAF Type | `core` (System of Record — alto riesgo de migración) |
| Dominios retail | R03 Servicios Financieros · R06 Operaciones de Tienda · R04 Cadena de Suministro |
| Estado | `[STATE: SCAFFOLD]` — rol confirmado, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Aplicaciones que Corren en el Mainframe (Confirmado)

| Aplicación | Rol | Criticidad |
|-----------|-----|-----------|
| **VPL Vision Plus** (FIS Global) | Core LiverpoolCard — autorizaciones, estados de cuenta, cargos, intereses | CRÍTICO 24x7 |
| **SOMS** | Administración de órdenes de entrega — gestión de remisiones y órdenes | CRÍTICO |
| **Mainframe Clientes** | Contabilidad y accounting de clientes LiverpoolCard | CRÍTICO |
| **MARC 90** | Devoluciones de mercancía (merchandise returns) | Operativo |
| **Control-D** (BMC) | Scheduler de batch + distribución de outputs (estados de cuenta, manifiestos) | Operativo |

> VPL Vision Plus tiene su propia estructura en `systems/processors/VPL-Vision-Plus/` para el brain especializado.
> SOMS y Mainframe Clientes son componentes nativos de este sistema.

---

## Dependencias Confirmadas

### Inbound (recibe de):
- **Base 24** — autorizaciones entrantes para VPL Vision Plus
- **IBM IIB (Broker)** — bus de mensajes corporativo
- **Tumbleweed** — transferencias de archivos MFT (batch)
- **SAP ECC** — interfaces de inventario y finanzas

### Outbound (envía a):
- **OpenText Exstream** — datos para generación de estados de cuenta
- **Cyberfinancial** — datos de cartera para cobranza
- **SAP BW** — reporting financiero
- **Control-D** — distribución de outputs generados
- **IBM IIB** — mensajes a sistemas downstream

---

## Corrección vs Hipótesis Inicial

| Hipótesis inicial | Realidad confirmada |
|------------------|---------------------|
| "batch, POS legacy, cierres (PENDIENTE)" | VPL Vision Plus = core LiverpoolCard (no solo batch) |
| "Oracle PL-SQL procesa LiverpoolCard" | INCORRECTO — VPL Vision Plus (Mainframe) + FICO TRIAD + Base 24 |
| "rol mínimo legacy" | ROL CENTRAL — toda autorización LiverpoolCard pasa por aquí |

---

## Decisión 7R (Hipótesis Actualizada)

- **VPL Vision Plus**: Encapsulate (API-fy) → Refactor | requiere parallel-run ≥ 3 meses — SLA LiverpoolCard 24x7
- **SOMS**: Refactor (migrar a Sterling OMS moderno o PAO) | dependencias con EWM y TMS
- **Mainframe Clientes**: Encapsulate → Refactor | datos contables sensibles
- **MARC 90**: Retire (funcionalidad simple) o Absorb en nuevo OMS

---

## Estructura

```
systems/core/Mainframe/
├── source/code/     ← programas COBOL, copybooks, JCL, config VPL
├── source/docs/     ← docs técnicos mainframe, IPLs, RACF
├── source/ops/      ← JCL producción, scripts operations
├── digital-brain/seeds/
├── knowledge-base/rules/, vocab/, ontology/, regulacion/
├── generators/
├── dt/
├── portal/data/
└── old/
```

---

*Actualizado 2026-09-02 · Rol CONFIRMADO desde Arquitectura_Liverpool_Dashboard_1.html · VPL Vision Plus + SOMS + Mainframe Clientes + MARC 90 + Control-D · SPE-AM-003*
