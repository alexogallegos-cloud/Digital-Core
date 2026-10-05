# Digital Twin — Proceso de Importaciones SAP (Módulo ZIM)
> `liverpool-brain/dt/dt-proceso-importaciones-sap/` · Liverpool AM · SPE-AM-003
> Fuente: source/Source Code SAP/ (12 programas ABAP) + Arquitectura_Liverpool_Dashboard_1.html
> Creado: 2026-09-07 · **[STATE: ACTIVE — código fuente disponible]**

## Propósito

Gemelo digital del proceso de importación de mercancía de Liverpool: desde la generación del pedido de compra internacional hasta la contabilización del pago al proveedor, pasando por registro de datos logísticos, pedimentos aduanales, pre-embarque, tracking de entregas y recepción.

Es el DT **más activable del programa**: tenemos el código fuente de los 12 programas ABAP del Módulo de Importaciones (ZIM) — el único sistema con código disponible en esta fase.

## Capa de Arquitectura

**Procesos de Industria** — Capa 1 del AS-IS

## Dominio Principal

R04 — Cadena de Suministro y Logística
R01 — Gestión Comercial (creación y reserva de POs)
R07 — Finanzas y Contabilidad (contabilización de pagos)

## Módulos SAP Involucrados (confirmados por análisis de código fuente)

| Módulo SAP | Rol en el proceso |
|-----------|-----------------|
| **MM-PUR** (Compras) | Motor: EKKO/EKPO son el corazón del módulo. PO creation, reservation, confirmation |
| **MM-MAT** (Maestro Materiales) | MARA/MAKT/MARC — artículos importados, unidades de medida |
| **LE-SHP** (Logística Entregas) | LIKP/LIPS — entregas parciales, tracking por parcial (ZIM_LICH) |
| **FI-GL** (Contabilidad General) | BKPF/BSEG — documentos contables de pago de importación |
| **FI-AP** (Cuentas por Pagar) | BSIK/BSAK — saldos pendientes y pagados a proveedores internacionales |
| **FI** (Multi-sociedad) | T001 — LIV + SBB + Sfera Moda Joven (sociedad 150) |
| **MM/FI** (Maestro Proveedores) | LFA1/LFB1/LFM1 — importadores, brokers, agentes aduanales |
| **SD** (Condiciones Precio) | KONV — aranceles e Incoterms en el cálculo de costo de importación |

## Programas ABAP del Módulo (12 confirmados)

| Programa | Business Name | Fase del proceso | Activo en 2025 |
|---|---|---|---|
| ZIMP_0001 (ZIMPOC003) | Generación de pedidos de importación | 1. Creación PO | — |
| ZIMPOC002 | Registro de datos generales compras/importación | 2. Datos logísticos | — |
| ZIMPOC001 | Reserva de pedidos de importación | 3. Reserva PO | — |
| ZIMPOC007 | Reserva pedidos importación — variante extendida | 3. Reserva (extendida) | — |
| ZIMFIC001 (ZIMPOC005) | Portal de pre-embarques para proveedores | 4. Confirmación proveedor | — |
| ZIMPOB010B | Reporte de pedimentos (batch) | 5. Pedimentos aduanales | — |
| ZRTPOC079 | Validación pedidos de traslado tipo 7 | 5. Entregas traslado | — |
| ZRTPOC079N | Reporte pedidos por tipo de orden (var. N) | 5. Consulta pedidos | **SÍ (abr-2025)** |
| ZIMPOC023 | Reporte de faltantes y sobrantes | 6. Recepción | — |
| ZIMPOC024 | Mantenimiento de POs de importación | 6. Ajustes post-recepción | — |
| ZIMFIC002 | Contabilización solicitudes de pago | 7. Contabilización | — |
| ZRT_PO_REP_EPI_BD | Interfaz pedimentos ECC → POS | 7. Interface POS | **SÍ (oct-2025)** |

## Flujo del Proceso AS-IS (Módulo de Importaciones ZIM)

```
PROVEEDOR                       SAP ECC (Módulo ZIM)                     ADUANAS / FINANZAS
EXTRANJERO
    │
    │  Acuerdo comercial
    ▼
[1] GENERACIÓN PO ──────────── ZIMP_0001 ──────────────────── EKKO/EKPO
    │ Tipo: IM, IP, TIM, TIP   (ME21I interface)              ZIM_RVPO (registro reserva)
    │ Incoterms → KONV
    ▼
[2] REGISTRO DATOS ─────────── ZIMPOC002 ──────────────────── ZIM_CNST (constantes)
    │ Fechas estimadas embarque  Datos logísticos:             ZIM_LICH (tracking parciales)
    │ Broker, agente aduanal     · Puerto embarque             ZIM_AGAD (agentes aduanales)
    │ País origen, Incoterms     · Fecha arribo tienda         ZIM_PTO_ADU_AGE
    ▼
[3] RESERVA PO ─────────────── ZIMPOC001 / ZIMPOC007 ─────── ZIM_RVPO
    │ Control de allocation      · Grupos de compras           ZRT_LEKPO
    │ Auto-allocation flag       · Status_MI tracking          ZIM_EMLG (Event Mgr log)
    │ Event Manager (EM) notifica
    ▼
[4] PRE-EMBARQUE ───────────── ZIMFIC001 (ZIMPOC005) ──────── LFA1 (proveedor)
    │ Portal proveedor           Aceptación/rechazo            ZIM_EKPO_SOL
    │ Confirmación envío         pre-embarque
    ▼
[5] PEDIMENTOS / ADUANA ─────── ZIMPOB010B ──────────────────── ZIM_PEDI / ZIM_PEDIC
    │                            ZRTPOC079 (tipo 7)             ZIM_PEDEM_L
    │ Pedimento = 16 dígitos     ZRT_PO_REP_EPI_BD→POS         ZTASA* (aranceles: IVA,
    │ (modificado oct-2025)                                      IEPS, IGI, DFC, PRV...)
    ▼
[6] RECEPCIÓN / FALTANTES ──── ZIMPOC023 ──────────────────── ZIM_RCBH / ZIM_RCBP
    │                           ZIMPOC024 (mantenimiento)       ZIM_LICH (tracking parcial)
    │ Reconciliación físico vs  Cambio de aduana, contenedor   ZIM_FLTSOB (faltantes)
    │ documental
    ▼
[7] CONTABILIZACIÓN ────────── ZIMFIC002 ──────────────────── BKPF / BSEG
    │ Solicitud de pago          · Conceptos 003/008/016        ZIM_LIPG / ZIM_LDPG
    │ Anticipos, retenciones     · TC fijo / Duty Free          ZIM_LICK / ZIM_LPPG
    │ IVA, IEPS                  · Multi-sociedad               BSIK / BSAK (AP)
    ▼
  PAGO PROVEEDOR INTERNACIONAL
```

## Tablas Z Clave — Lógica de Negocio Liverpool

| Tabla Z | Rol en el proceso | Programas |
|---|---|---|
| `ZIM_RVPO` | Registro maestro de importaciones — estado del PO en el proceso | 7 programas |
| `ZIM_CNST` | Constantes y configuración del módulo (tiempos, grupos, parámetros) | 7 programas |
| `ZIM_LICH` | Tracking de entregas parciales por pedimento | 7 programas |
| `ZZSTATUS_MI` | Máquina de estados del PO en importación (IP=En Proceso, etc.) | 5 programas |
| `ZIM_EMLG` | Log de eventos del Event Manager (EM) — trazabilidad completa | 4 programas |
| `ZIM_SYLOG` | Log del sistema del módulo | 4 programas |
| `ZOLLS_IMP` | Aranceles de importación (tarifas por concepto) | 4 programas |
| `ZTASA*` | Tablas de tasas: IGI, IVA, IEPS, DFC, ISAN, ITV, PRV, REC | ZIMPOB010B |
| `ZIM_AGAD` | Maestro de agentes aduanales | ZIMPOC002 |
| `ZIM_LFA1` | Extensión Z del maestro de proveedores (datos de importación) | 2 programas |

**213 tablas/objetos Z identificados en total** — representan el Módulo de Importaciones completo de Liverpool.

## Señales del AS-IS

| Señal | Impacto | Evidencia |
|---|---|---|
| 2 programas activos en 2025 | Módulo bajo mantenimiento activo en producción | ZRTPOC079N (abr-2025), ZRT_PO_REP_EPI_BD (oct-2025) |
| Multi-sociedad (T001) | LIV + SBB + Sfera (150) — 3 landscapes comparten el módulo | ZIMPOC007, ZIMPOB010B, ZIMPOC023 |
| Pedimento de 14→16 dígitos (oct-2025) | Cambio regulatorio reciente absorbido en el código | ZRT_PO_REP_EPI_BD |
| Agente aduanal en tabla propia (ZIM_AGAD) | Proceso complejo de selección de agentes — posible lógica de scoring | ZIMPOC002, ZIMPOC024 |
| 33 Function Modules Z propios | API interna del módulo — no usa BAPIs estándar de SAP | ZRTPOC079, ZIMPOC002, etc. |

## Hipótesis 7R para Este Módulo

| Hipótesis | Fundamento |
|---|---|
| **Replatform** (brownfield ECC→S/4HANA) | Opción de menor riesgo. Las 213 tablas Z migran como están. Deuda técnica persiste. |
| **Repurchase a SAP GTS** | SAP Global Trade Services es el módulo estándar para importaciones/pedimentos en S/4HANA. Elimina las 213 tablas Z — alto beneficio, alta complejidad de migración. |
| **Refactor a microservicio** | Extraer la lógica de importaciones como servicio independiente. Consume MM-PUR APIs de S/4HANA y expone API REST/evento. Mayor flexibilidad a largo plazo. |

**Señal regulatoria**: el cambio de 14→16 dígitos en pedimentos (oct-2025) muestra que el módulo absorbe cambios del SAT directamente — en SAP GTS esto sería estándar. Es argumento a favor de Repurchase.

## Estado

`[STATE: ACTIVE]` — código fuente disponible y analizado (2026-09-07).
Análisis de módulos SAP, tablas Z, function modules y flujo de proceso completados.
Pendiente: extracción de reglas de negocio detalladas (fórmulas de cálculo de aranceles en ZTASA*, máquina de estados ZZSTATUS_MI, lógica de auto-allocation).

## Fuentes de Datos Disponibles

- [x] 12 programas ABAP fuente (`source/Source Code SAP/`)
- [x] Análisis módulos SAP (MM-PUR, LE-SHP, FI-GL, FI-AP)
- [x] 213 tablas Z identificadas
- [x] 33 function modules Z propios mapeados
- [x] Flujo de proceso AS-IS reconstruido desde código
- [ ] Datos de volumetría (N pedimentos/mes, N POs activos)
- [ ] Configuración EM (Event Manager) — eventos ZIM_EMLG
- [ ] Datos de las tablas ZTASA* (tasas vigentes por concepto)
- [ ] Interfaces con la Aduana / Sistema del SAT

## Próximas Acciones de Análisis

1. **Extraer reglas de negocio** de ZIMFIC002 (lógica de contabilización — cálculo de retenciones, IVA, anticipos)
2. **Reconstruir la máquina de estados** ZZSTATUS_MI (flujo de estados IP, IM, etc.)
3. **Mapear tablas ZTASA\*** (aranceles) — potencial candidato a migración a SAP GTS
4. **Analizar ZIMPOC002** (el programa más grande: 151KB) — lógica de registro de datos y fechas

## Dependencias Cross-DT

- `dt-sap-doble-landscape` → el Módulo de Importaciones corre en SAP ECC LIV (no SBB); la migración a S/4HANA requiere validar compatibilidad de las 213 tablas Z
- `dt-maestros-datos` → LFA1 + ZIM_LFA1 + ZIM_AGAD son la base de datos de proveedores internacionales de este proceso
- `dt-bus-integracion` → IBM IIB conecta SAP MM con los sistemas de aduana y con el POS (ZRT_PO_REP_EPI_BD)
- `dt-catalogo-producto` → MARA/MAKT son el maestro de materiales que origina la compra; el planning de surtido (Size Scaling) alimenta los POs de importación