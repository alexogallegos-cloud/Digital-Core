# BanCoppel · Modelo Operativo Lógico de un Banco Retail

> **Autor:** SME — Modelo Operativo Bancario (BIAN · capacidades retail banking · cadena de valor)
> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3/4 — Domain Decomposition (input)**
> **Última actualización:** 2026-07-05

Modelo **lógico de negocio** de un banco de consumo mexicano como BanCoppel: las **capacidades** que un banco debe tener para operar, organizadas de forma independiente de la tecnología, y su **mapeo a los 12 dominios técnicos** descubiertos en el core Informix (`bdicheq`, `bdicred`, …).

Este modelo es el marco de referencia para (a) validar que los dominios técnicos corresponden a capacidades reales, (b) nombrar journeys en lenguaje de negocio, y (c) definir los **bounded contexts** del target (Etapa 4). Alineado a **BIAN** (Banking Industry Architecture Network) y a la cadena de valor de banca retail.

---

## 1 · Perfil operativo de BanCoppel

BanCoppel no es un banco universal: es una **banca de consumo / inclusión financiera** ligada al ecosistema Grupo Coppel. Su modelo operativo se distingue por:

- **Base de la pirámide / clase media** — "banca sin tecnicismos", simplicidad.
- **Crédito de consumo como núcleo** — entrelazado con la tienda Coppel (crédito quincenal).
- **Distribución física masiva** — ~1,372 sucursales + red Coppel/OXXO como canal transaccional.
- **Productos ancla:** cuenta de débito/nómina, tarjeta de crédito, préstamos, remesas, Afore Coppel, e hipoteca digital (desde 2025).

Esto define qué capacidades son **core** (crédito, captación, pagos, canales masivos) y cuáles son **de soporte**.

---

## 2 · Cadena de valor (banca retail)

```
   CAPTAR            ORIGINAR          PROCESAR          SERVIR            CUMPLIR
   clientes    →     productos    →    transacciones →   y retener   →    y controlar
   (canales)         (crédito/          (core:            (aclaraciones,    (riesgo,
                      captación/         movimientos,      cobranza,         regulatorio)
                      pagos)             saldos, ledger)   mensajería)
```

---

## 3 · Mapa de capacidades lógicas (6 capas BIAN) → dominios técnicos

### Capa A · CANALES Y EXPERIENCIA  *(Customer Touchpoints)*
| Capacidad de negocio | BIAN Service Domain (ref.) | Dominio técnico BCOPCore |
|----------------------|----------------------------|--------------------------|
| Banca por Internet (BPI) | Channel Activity Analysis | **D01** `bdicnweb` |
| App móvil (BanCoppel Móvil) | Channel Activity Analysis | **D01** `bdicnweb` |
| IVR / telefónico | Contact Center | D01 |
| Sucursal | Branch Location Mgmt | **D10** `bdisuc` |
| Cajeros (ATM) / red Coppel-OXXO | ATM Network Mgmt / Correspondent | D10 |

### Capa B · GESTIÓN DE CLIENTE  *(Party / Customer)*
| Capacidad | BIAN | Dominio técnico |
|-----------|------|-----------------|
| Onboarding / apertura | Customer Onboarding | **D06** `bdisolic` |
| Identificación / KYC (CURP, RFC, biométrico) | Party Authentication / Customer Reference | **D02** `bdinteg` |
| Expediente digital / documentos | Customer Case / Document Mgmt | D06 |
| Autenticación y sesión (2FA, tokens) | Party Authentication | **D02** `bdinteg` |

### Capa C · PRODUCTOS Y OFERTAS  *(Product Directory)*
| Capacidad | BIAN | Dominio técnico |
|-----------|------|-----------------|
| **Captación** — Cuenta Efectiva / Nómina / Inversión | Current Account · Savings · Term Deposit | **D04** `bdicheq` · **D05** `bdisac` |
| **Crédito** — Préstamo personal/nómina/digital, Crédito Coppel, Tarjeta, Hipoteca | Consumer Loan · Credit Facility · Card | **D03** `bdicred` |
| **Pagos y transferencias** — SPEI, CoDi, TEF, domiciliación | Payment Order · ACH · Direct Debit | **D08** `bdispei` |
| **Remesas** — Western Union / MoneyGram | Cross-Border Payment | D08 · externo |
| **Ahorro para el retiro** — Afore Coppel | Investment Portfolio Mgmt | externo (integración) |

### Capa D · CORE BANCARIO  *(Position Keeping & Transaction Engine)*
| Capacidad | BIAN | Dominio técnico |
|-----------|------|-----------------|
| Motor de movimientos (cargo / abono / reversa) | Transaction Engine | **D04** `bdicheq` (`cargo_ref`, `abono_ref`) |
| Gestión de saldos (disponible, consolidado) | Position Keeping | **D05** `bdisac` |
| Contabilidad / ledger / cierre diario | Financial Accounting | **D12** `bdicont` |
| Procesos batch / cierre de período | Operational Batch | D12 · D04 (nocturnos) |

### Capa E · RIESGO Y CUMPLIMIENTO  *(Risk & Regulatory)*
| Capacidad | BIAN | Dominio técnico |
|-----------|------|-----------------|
| Scoring / evaluación crediticia (Buró) | Credit Risk / Customer Credit Rating | **D03** `bdicred` (`califica_scoring*`) |
| Cobranza / recuperación | Collections / Loan Recovery | **D11** `bdicobranza` |
| Prevención de fraude / PLD | Fraud Detection / Financial Crime | transversal (D02, D08) |
| Cumplimiento regulatorio | Regulatory Compliance | **SMEs:** CNBV · Banxico · CONDUSEF · SAT · TESOFE · IPAB |
| Retención fiscal (ISR/IVA) | Tax Handling | D04 · D12 (`calc_isr`) |

### Capa F · SERVICIO Y SOPORTE  *(Servicing & Case Mgmt)*
| Capacidad | BIAN | Dominio técnico |
|-----------|------|-----------------|
| Aclaraciones / disputas (CONDUSEF) | Customer Case / Dispute Mgmt | **D07** `bdiaclaracion` |
| Mensajería / notificaciones (Latinia) | Customer Communication / Notification | **D09** `bdimnsj` |
| Consulta de estado / posición | Customer Position | D01 · D05 |

---

## 4 · Vista consolidada — los 12 dominios en el modelo lógico

```
┌─ CANALES ────────────────────────────────────────────────────────────┐
│  D01 Canal Digital (BPI/App/IVR)      D10 Sucursales (ATM/Coppel-OXXO) │
└───────────────────────────────────────────────────────────────────────┘
┌─ CLIENTE ─────────────────┐  ┌─ PRODUCTOS ──────────────────────────────┐
│  D06 Solicitudes (onboard)│  │ D04 Cheques/Cuentas  D03 Créditos        │
│  D02 Integración/Auth     │  │ D05 Saldos           D08 SPEI/Pagos      │
└───────────────────────────┘  └───────────────────────────────────────────┘
┌─ CORE BANCARIO ───────────────────────┐  ┌─ RIESGO & CUMPLIMIENTO ────────┐
│  D04 Movimientos  D05 Saldos          │  │ D03 Scoring  D11 Cobranza      │
│  D12 Contabilidad/Ledger              │  │ Reguladores (6 SMEs)           │
└───────────────────────────────────────┘  └─────────────────────────────────┘
┌─ SERVICIO & SOPORTE ──────────────────────────────────────────────────┐
│  D07 Aclaraciones (CONDUSEF)     D09 Mensajería (Latinia)             │
└───────────────────────────────────────────────────────────────────────┘
```

**Observación clave:** algunos dominios técnicos son **multi-capacidad**: `D04 bdicheq` es a la vez *producto* (captación) y *core* (motor de movimientos `cargo_ref`/`abono_ref`); `D03 bdicred` es *producto* (crédito) y *riesgo* (scoring). Esto es típico de un core monolítico y **debe descomponerse** en el target (Etapa 4).

---

## 5 · Gaps y observaciones del modelo operativo

- **`D02 Integración/Auth` es transversal, no una capacidad de negocio** — es plataforma. En el target debería ser un servicio de identidad, no un dominio de negocio.
- **Afore, PLD/Fraude y Fiscal** son capacidades del modelo que **no tienen dominio técnico dedicado** en el core (viven en externos o embebidas). Confirmar con el Domain Expert dónde residen.
- **`D04` y `D03` mezclan capacidades** (producto + core / producto + riesgo) → candidatos a split de bounded context.
- **Remesas** (capacidad ancla de BanCoppel) no tiene dominio propio visible — ¿embebida en D08/D04? `[CONSULTAR→NEGOCIO]`.

---

## 6 · Uso para la modernización (Etapa 4 — Domain Decomposition)

Este modelo lógico es el **contrato de negocio** contra el que se validan los bounded contexts del target:

1. **Cada capacidad = un microservicio candidato** (o un grupo). El motor de movimientos (D04-core) se separa de la cuenta como producto (D04-producto).
2. **El scoring crediticio** (D03-riesgo, los `califica_scoring*` complejos) se extrae como servicio de decisión independiente del producto crédito.
3. **La identidad/auth** (D02) se vuelve plataforma transversal, no dominio.
4. **Las capacidades regulatorias** se implementan como *policies* validadas por los 6 SMEs reguladores.

> **`[SME-PENDING]` Validación con Domain Expert BanCoppel + este SME:** confirmar el mapeo capacidad↔dominio, resolver los gaps (Afore, remesas, PLD, fiscal) y priorizar los splits de bounded context.

---

*Producido por SME — Modelo Operativo Bancario · alineado a BIAN + banca retail MX · cruza con los 12 dominios técnicos de BCOPCore · complementa `component-map`, `journeys` y `business-rules`.*