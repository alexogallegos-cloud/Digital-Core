# Digital Twin — Mainframe Core (IBM z/OS)
> `liverpool-brain/dt/dt-mainframe-core/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-08
> **[STATE: ACTIVE — scaffold; fuente de datos pendiente]**

## Propósito

Gemelo digital de los procesos que corren sobre el mainframe IBM z/OS de Liverpool: gestión de órdenes de entrega (SOMS), backoffice de LiverpoolCard (VPL Vision Plus), contabilidad de clientes, y scheduling batch (Control-D). Es el sistema de mayor antigüedad del landscape y el que más dependencias ocultas acumula.

Sin este DT, cualquier decisión 7R sobre SAP, Sterling OMS o VPL Vision Plus está incompleta: el mainframe es el nodo de convergencia de tres dominios críticos (finanzas, logística y operaciones de tienda).

## Capa de Arquitectura

**Core (SoR alta criticidad)** — Capa 1 del AS-IS

## Dominios Principales

R03 — Servicios Financieros (backoffice LiverpoolCard)
R04 — Cadena de Suministro y Logística (SOMS — órdenes de entrega)
R06 — Operaciones de Tienda (contabilidad y cierre de caja)

## Sistemas Involucrados

| Sistema | Vendor | Rol en el mainframe |
|---------|--------|---------------------|
| **VPL Vision Plus** | FIS Global | Core LiverpoolCard 24×7 — autorizaciones, estados de cuenta, pagos |
| **SOMS** | Sterling (IBM) | Gestión de órdenes de entrega: picking, packing, despacho |
| **Mainframe Clientes** | Liverpool interno | Contabilidad de clientes — balances, movimientos, cargos |
| **Control-D** | BMC Software | Scheduler batch: orquesta jobs nocturnos de cierre, reconciliación, reportes |

## Flujo del Proceso AS-IS (Mainframe)

```
CANAL (tienda / web / app)
    │
    ▼
[BRIDGECORE / STERLING OMS]  ──→  SOMS (z/OS)
    │                                │
    │  Orden de entrega              │  Picking list → WMS (SAP EWM)
    │                                │  Despacho → actualización estado
    │                                ▼
    │                         CONTABILIDAD CLIENTES (z/OS)
    │                                │
    ▼                                │  Cargo al cliente
[VPL VISION PLUS] (z/OS)            │  Reporte financiero diario
    │                                ▼
    │  Autorización 24×7      CONTROL-D (z/OS)
    │  Estado de cuenta              │
    │  Pago mínimo                   │  Jobs nocturnos:
    │  Cobranza interface            │  · Cierre contable
    ▼                                │  · Reconciliación VPL↔SAP FI
MAINFRAME CLIENTES (z/OS)           │  · Extracción a BW
                                     │  · Interface SAT/CONDUSEF
                                     ▼
                              OUTPUT: Reportes + Interfaces regulatorias
```

## Señales del AS-IS

| Señal | Impacto | Sistema |
|-------|---------|---------|
| VPL Vision Plus 24×7 | SLA de disponibilidad LiverpoolCard depende del mainframe — cualquier ventana de mantenimiento tiene restricción regulatoria (Banxico) | VPL |
| SOMS con 96.69% órdenes "pendiente" | El backlog de órdenes sin procesar en SOMS es el síntoma más crítico del programa. El mainframe procesa pero el OMS upstream no libera | SOMS |
| Control-D como único orquestador batch | No hay visibilidad de dependencias entre jobs — riesgo de cascada en fallos nocturnos | Control-D |
| Mainframe Clientes como sistema de registro | Si SAP FI y Mainframe Clientes divergen en saldo de cliente, la versión correcta no está documentada | Clientes |

## Hipótesis 7R para Este Módulo

| Hipótesis | Sistema | Fundamento |
|-----------|---------|-----------|
| **Encapsulate + API-fy** | VPL Vision Plus | FIS Global tiene APIs modernas para VPL — exponer como servicios sin reescribir. Prerequisito para commercetools. |
| **Repurchase** | SOMS | IBM Sterling OMS 10 en mainframe → migrar a Sterling OMS en cloud o a Order Management de commercetools. La señal de 96.69% pendiente hace este cambio urgente. |
| **Migrate + Retire** | Mainframe Clientes | Consolidar en SAP FI/CO como sistema único de contabilidad de clientes. |
| **Retain + Automate** | Control-D | Migrar scheduling a AWS Step Functions o Google Cloud Workflows a medida que los sistemas que orquesta se modernicen. |

## Estado

`[STATE: ACTIVE — scaffold]` — DT creado 2026-09-08.
Fuente de datos primaria (`[DATO-REQUERIDO]`): inventario de jobs Control-D, manual de SOMS, esquema de Mainframe Clientes, documentación VPL.

## Fuentes de Datos Disponibles

- [x] Dashboard AS-IS (confirmación de existencia y rol de los 4 sistemas)
- [ ] Inventario de jobs Control-D (volumen, frecuencia, dependencias)
- [ ] Esquema de datos de Mainframe Clientes (tablas, campos, volumetría)
- [ ] Documentación SOMS en z/OS (versión, configuración, interfaces)
- [ ] SLA y ventanas de mantenimiento VPL Vision Plus
- [ ] Interfaces regulatorias: SAT, Banxico, CONDUSEF desde mainframe

## Dependencias Cross-DT

- `dt-liverpoolcard` → VPL Vision Plus es la cara financiera; este DT es la ejecución z/OS
- `dt-pedido-omnicanal` → SOMS es el motor de fulfillment; la señal de 96.69% pendiente tiene raíz aquí
- `dt-bus-integracion` → Control-D orquesta jobs que alimentan IBM IIB y Tumbleweed
- `dt-sap-doble-landscape` → Mainframe Clientes y SAP FI deben reconciliarse; la migración SAP impacta al mainframe
- `dt-analitica-sap-bw` → Control-D extrae datos del mainframe hacia SAP BW nocturnamente
