# Capa 2 — Mapa de las Almas · BCOPCore

> **Gemelo Cognitivo del Sistema** · BanCoppel Application Modernization (SPE-AM-001)
> Generado: 2026-07-11 · Grounding Pass completo: 9,695 SPs · 12 dominios
> Método: [metodologia-gemelo-cognitivo.md](../metodologia-gemelo-cognitivo.md)

---

## ¿Qué es el Mapa de las Almas?

La Capa 2 identifica los **Stored Procedures que son el alma** del sistema — no los que hacen trabajo técnico, sino los que **encarnan un proceso de negocio irreemplazable**. Un "alma" es un SP que, si desaparece o cambia su contrato, algo fundamental del banco deja de funcionar.

Los criterios de selección son:
1. **fan_in alto** → muchos callers dependen de él
2. **LOC alta** → concentra lógica de negocio compleja
3. **Cruce de dominios** → es invocado desde múltiples BDs (cross-domain coupling)
4. **Verdict VERIFICADO o PARCIAL con evidencia DML** → hay código confirmando su propósito

---

## Las 12 Almas de BCOPCore

### Alma 1 — El Portero: `sp_cnsif_confirmaejecutivo`
**Dominio**: D02 · bdinteg · fan_in=**2,400** · VERIFICADO

El SP más llamado de todo BCOPCore. Sin él, ningún ejecutivo BanCoppel puede operar. Es el **gate de autenticación y autorización universal** del sistema — cada acción operativa pasa por aquí antes de ejecutarse.

```
Patrón: GATE DE AUTORIZACIÓN
Dominio propietario: D02 bdinteg
Callers: 2,400 SPs de múltiples dominios
Hermano: sp_cnsif_permisosejecutivo (fan_in=621)
Riesgo modernización: CRÍTICO — cualquier migración que no incluya
    una estrategia de identidad equivalente paraliza el sistema completo.
```

**¿Por qué es un alma?** Ninguna operación de negocio ocurre sin validar al ejecutivo. Es la capa de control de acceso incrustada en el core — no existe un IAM externo: el IAM ES este SP.

---

### Alma 2 — El Bus de Eventos: `sp_registra_evento`
**Dominio**: D09 · bdimnsj · fan_in=**1,404** · VERIFICADO

El event bus implícito del sistema de mensajería. Cada evento significativo — notificación SMS, alerta email, confirmación de operación — se registra a través de este SP. Es el **sistema de observabilidad operativa** de BanCoppel: si un ejecutivo necesita saber qué pasó, está en la bitácora de eventos de mensajería.

```
Patrón: EVENT BUS / AUDIT LOG DE MENSAJERÍA
Dominio propietario: D09 bdimnsj
Callers: 1,404 — el segundo más llamado del ecosistema
Extensión SPEI: sp_registra_evento_tmp_spei (fan_in separado)
Riesgo modernización: ALTO — cualquier gap en equivalencia funcional
    hace invisible una parte de la operación.
```

---

### Alma 3 — El Débito: `cargo_ref`
**Dominio**: D04 · bdicheq · fan_in=**561** · PARCIAL · 1,654 LOC

La **primitiva de débito** de BCOPCore. Todo cargo a cuenta — desde un pago de crédito hasta una comisión — termina aquí. El nombre "ref" indica que siempre lleva una referencia (trazabilidad de origen). Junto con `abono_ref`, forman el par debit/credit que es el API transaccional del sistema.

```
Patrón: PRIMITIVA DE TRANSACCIÓN (DÉBITO)
Dominio propietario: D04 bdicheq
Callers: 561
Gemelo de crédito: abono_ref (fan_in=520, 1,654 LOC)
Hermano negativo: cargon_ref (fan_in=70, cargo negativo/reverso parcial)
Riesgo modernización: MÁXIMO — cualquier pérdida de fidelidad en la
    semántica de cargo_ref destruye la integridad financiera del banco.
    Equivalencia funcional ≥ 99.9999% requerida.
```

**¿Por qué vive en bdicheq (Cheques) y no en bdicred (Crédito)?** BCOPCore fue construido sobre una abstracción de "cheque interno" — toda transacción financiera, independientemente de su naturaleza, es modelada como un cheque cargo o abono. Es la convención contable raíz del sistema.

---

### Alma 4 — El Crédito: `abono_ref`
**Dominio**: D04 · bdicheq · fan_in=**520** · PARCIAL · 1,654 LOC

La **primitiva de crédito** de BCOPCore. Simétrica a `cargo_ref`. Ver Alma 3 para contexto completo.

---

### Alma 5 — El Parser: `sp_split_cadena`
**Dominio**: D01 · bdicnweb · fan_in=**857** · NO_VERIFICABLE (pura computación)

El SP de parsing de strings más llamado del sistema. Con 857 callers, revela un patrón arquitectónico crítico de BCOPCore: **los datos estructurados se pasan como strings concatenados** entre SPs y entre capas. El sistema no usa parámetros tipados para estructuras complejas — usa strings serializados que `sp_split_cadena` descompone en partes.

```
Patrón: INFRAESTRUCTURA DE SERIALIZACIÓN (string-as-protocol)
Dominio propietario: D01 bdicnweb
Callers: 857 — tercer más llamado del ecosistema
Riesgo modernización: ALTO — los contratos de string deben ser
    documentados como un protocolo explícito antes de migrar.
    "Protocolo de cadenas" es deuda técnica invisible.
```

**Implicación para la migración**: cada caller de `sp_split_cadena` tiene un contrato implícito con un formato específico de string. Ninguno de estos contratos está documentado en el código — viven solo en la lógica de construcción del string en el SP caller y el parsing en el callee. La Capa 4 (Intención) debe mapear todos estos contratos.

---

### Alma 6 — El Scoring: `califica_scoring2_cjunk`
**Dominio**: D06 · bdisolic · fan_in=**167** · PARCIAL · **3,068 LOC**

El motor de scoring crediticio de BanCoppel. Con 3,068 líneas de código y 167 callers, contiene los **algoritmos de decisión de crédito** que determinan si un cliente recibe o no una tarjeta de crédito o préstamo. El sufijo `_cjunk` indica que es la versión de trabajo que nunca fue renombrada — es el motor activo en producción.

```
Patrón: MOTOR DE DECISIÓN CREDITICIA
Dominio propietario: D06 bdisolic (no D03 bdicred — anomalía semántica)
Callers: 167 — desde el flujo de solicitudes
Versiones identificadas: califica_scoring_cjunk (v anterior, fan_in=6)
                          califica_scoring_cjunk_motor (fan_in=1)
                          califica_scoring_cjunk_precal_opt (fan_in=0)
Riesgo modernización: EXTREMO — contiene reglas de negocio reguladas (CNBV).
    Requiere sign-off de Risk Officer + Auditoría Interna + validación CNBV
    antes del cutover. Equivalencia ≥ 99.99%.
```

**¿Por qué está en Solicitudes (D06) y no en Crédito (D03)?** El scoring ocurre en la fase de *originación* (solicitud), antes de que el crédito exista. BanCoppel modela correctamente el scoring como parte del proceso de evaluación, no del ciclo de vida del crédito ya otorgado.

---

### Alma 7 — El Saldo: `sp_consulta_saldos_general`
**Dominio**: D03 · bdicred · fan_in=**435** · VERIFICADO

La consulta de saldos de crédito más llamada del sistema. Es el **oráculo de posición financiera del cliente** — cualquier SP que necesita saber cuánto debe un cliente, qué tiene disponible, o cuál es su posición en algún producto de crédito, pasa por aquí.

```
Patrón: ORÁCULO DE POSICIÓN FINANCIERA
Dominio propietario: D03 bdicred
Callers: 435
Riesgo modernización: ALTO — el SP maneja tipos de datos Informix-específicos
    para montos. La semántica de redondeo y precisión monetaria debe ser
    replicada exactamente. Ver ADR-SPE-AM-006.
```

---

### Alma 8 — El Audit Trail de Cobranza: `sp_inserta_bitacora_cob`
**Dominio**: D11 · bdicobranza · fan_in=**406** · VERIFICADO

El registro audit trail central del dominio de cobranza. Cada acción de gestión de cartera vencida — contacto con cliente, registro de compromiso de pago, acuerdo firmado — se registra aquí. Es el **sistema de evidencia** de cobranza, crítico para compliance regulatorio (CNBV) y para procesos legales de recuperación.

```
Patrón: AUDIT LOG / EVIDENCIA DE COBRANZA
Dominio propietario: D11 bdicobranza
Callers: 406 — cuarto más llamado del ecosistema
Riesgo modernización: ALTO — la evidencia de cobranza tiene implicaciones
    legales. El histórico debe ser preservado y accesible durante el proceso
    de litigio (típicamente 5 años). Plan de migración de datos obligatorio.
```

---

### Alma 9 — El Onboarding Digital: `sp_ctedigital_validaclientes`
**Dominio**: D02 · bdinteg · fan_in=**0** (llamado desde app layer) · PARCIAL · **16,406 LOC** · 39 tablas

El SP de negocio más grande del sistema. Toda la lógica de validación para abrir una **cuenta digital BanCoppel** — KYC, validación de identidad, consulta de buró, asignación de producto — está concentrada aquí. fan_in=0 porque es un entry point del canal digital (app móvil/web), no un SP llamado desde otros SPs.

```
Patrón: ORQUESTADOR DE ONBOARDING DIGITAL
Dominio propietario: D02 bdinteg
Callers: 0 SPs internos (llamado directo desde capa de aplicación)
LOC: 16,406 — el SP de negocio más grande del ecosistema
Tablas accedidas: 39 — mayor acoplamiento de datos del sistema
Riesgo modernización: EXTREMO — monolito funcional en un solo SP.
    Candidato a descomposición en microservicios (KYC Service, Credit Check
    Service, Product Assignment Service). Requiere análisis de equivalencia
    funcional por fase del flujo de onboarding.
```

**Implicación arquitectónica**: este SP es un anti-patrón de microservicios embebido en el core. Es la pieza más compleja de migrar porque no tiene callers internos — su interfaz es con la capa de aplicación, que debe ser coordinada en el plan de cutover.

---

### Alma 10 — La Portabilidad de Nómina: `sp_notif_cambios_portacec`
**Dominio**: D04 · bdicheq · fan_in=**1** · PARCIAL · **11,423 LOC**

El SP regulatorio más grande del sistema. Notifica cambios de portabilidad de nómina al CEC (Centro de Envíos Coppel) conforme al estándar Banxico. Con 11,423 líneas y un solo caller, es un **proceso batch regulatorio** que se ejecuta una vez por ciclo. Su complejidad (11K LOC) es el resultado de manejar todos los escenarios de portabilidad definidos por Banxico.

```
Patrón: PROCESO BATCH REGULATORIO
Dominio propietario: D04 bdicheq
Callers: 1 (proceso batch programado)
LOC: 11,423 — segundo SP más grande del ecosistema
Regulación: Banxico — Circular de portabilidad de nómina
Riesgo modernización: ALTO — cambio regulatorio requiere re-certificación
    con Banxico. El formato de archivo es normativo y no puede cambiar
    sin autorización regulatoria explícita.
```

---

### Alma 11 — Los Bienes: `sp_consultadatospiezas_bym3`
**Dominio**: D10 · bdisuc · fan_in=**381** · VERIFICADO

El alma del sistema de Bienes y Mercancías (BYM) en sucursales. Cada visita a sucursal Coppel que involucra bienes usados — tasación, compra-venta, garantía — llama a este SP. Con fan_in=381 (y hermanos con fan_in=375-378), el sistema BYM es la funcionalidad más transaccional de las sucursales.

```
Patrón: ORÁCULO DE BIENES / VALUACIÓN
Dominio propietario: D10 bdisuc
Callers: 381 (versión 3), 376 (versión 2), 376 (totales), 375 (catálogo estatus)
Hermano dictamen: sp_consutacat_dictamen_bym (fan_in=378)
Riesgo modernización: MEDIO — el negocio de bienes es periférico al
    negocio bancario core. Candidato a modernización independiente o
    a replatform de baja prioridad.
```

---

### Alma 12 — El Motor de Regex: `regex_*` (INFRAESTRUCTURA)
**Dominio**: D02 · bdinteg · 8 SPs · **~34 MB total** · EXCLUIR DE ANÁLISIS DE NEGOCIO

No es un alma de negocio — es infraestructura. La implementación del motor de regex POSIX en Informix SPL (8 procedimientos, ~4 MB cada uno) usado por la capa de integración para validación y parsing de mensajes. Es el único componente de BCOPCore sin valor de negocio directo — su función es completamente reemplazable por regex nativo en cualquier lenguaje target.

```
Patrón: INFRAESTRUCTURA REEMPLAZABLE (zero business logic)
Componentes: regex_match, regex_extract, regex_replace, regex_set_trace,
             regex_copts, regex_eopts, regex_htr, regex_release
Riesgo modernización: MUY BAJO — eliminación directa.
    Reemplazar con java.util.regex / re (Python) / similar.
    Cero riesgo de pérdida de lógica de negocio.
```

---

## Mapa de Dependencias entre Almas

```
                    ┌─────────────────────────────────────────┐
                    │   CAPA DE APLICACIÓN (app móvil/web)    │
                    └───────────────┬─────────────────────────┘
                                    │ (directo, sin SP intermediario)
                                    ▼
                    ┌───────────────────────────────┐
                    │  Alma 9: sp_ctedigital_       │  (onboarding digital)
                    │  validaclientes [D02 bdinteg] │  16,406 LOC · 39 tablas
                    └───────────────────────────────┘

    ┌──────────────────────────────────────────────────────────────┐
    │              GATE UNIVERSAL DE AUTENTICACIÓN                 │
    │  Alma 1: sp_cnsif_confirmaejecutivo [D02] · fan_in=2,400    │
    └──────────┬───────────────────────────────────────────────────┘
               │ (todo ejecutivo pasa por aquí antes de operar)
               ▼
    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
    │  SOLICITUDES    │    │  SCORING         │    │  SALDOS         │
    │  D06 bdisolic   │───▶│  Alma 6:         │    │  Alma 7:        │
    │  sp_asigna_soc  │    │  califica_       │    │  sp_consulta_   │
    │  (fan_in=236)   │    │  scoring2_cjunk  │    │  saldos_general │
    └────────┬────────┘    │  (fan_in=167)    │    │  (fan_in=435)   │
             │             └─────────────────┘    └────────┬────────┘
             ▼                                             │
    ┌─────────────────────────────────────────────────────▼────────┐
    │              MOTOR TRANSACCIONAL (bdicheq)                    │
    │  Alma 3: cargo_ref (fan_in=561)  ←→  Alma 4: abono_ref (520) │
    │  Alma 10: sp_notif_cambios_portacec (batch, 11,423 LOC)      │
    │  reversion (fan_in=377) · bloqueo_cta (fan_in=184)           │
    └──────────────────────────────┬───────────────────────────────┘
                                   │ (toda transacción genera evento)
                                   ▼
    ┌─────────────────────────────────────────────────────────────┐
    │              EVENT BUS DE MENSAJERÍA (bdimnsj)              │
    │         Alma 2: sp_registra_evento · fan_in=1,404           │
    └──────────────────────────────┬──────────────────────────────┘
                                   │ (genera notificaciones)
                     SMS/Email → cliente / ejecutivo

    ┌─────────────────┐                    ┌─────────────────────┐
    │  COBRANZA       │                    │  SPEI               │
    │  D11 bdicopranza│                    │  D08 bdispei        │
    │  Alma 8:        │                    │  spei_recliquidacion│
    │  sp_inserta_    │                    │  spei_recerrorescodi│
    │  bitacora_cob   │                    │  (fan_in=27)        │
    │  (fan_in=406)   │                    └─────────────────────┘
    └─────────────────┘

    ┌─────────────────┐                    ┌─────────────────────┐
    │  CONTABILIDAD   │◀── (D11 genera) ── │  COBRANZA           │
    │  D12 bdicont    │                    │  sp_ctbcpl_gen_*    │
    │  libromayor_*   │                    │  (interfaz D11→D12) │
    │  balanza_*      │                    └─────────────────────┘
    └─────────────────┘

    ┌────────────────────────────────────────────────────────────┐
    │  INFRAESTRUCTURA TRANSVERSAL (D01 bdicnweb)                │
    │  Alma 5: sp_split_cadena (fan_in=857) — string protocol    │
    │  sp_generararchivo_rst (fan_in=345)                        │
    │  sp_ope_consultarutalmacenamientoxml (fan_in=372) — XML    │
    │  sp_fc_bitacorahuellas — biometría (huella dactilar)       │
    └────────────────────────────────────────────────────────────┘
```

---

## Integraciones Externas Confirmadas en Código

| Sistema externo | SP de integración | Dominio | Evidencia |
|-----------------|------------------|---------|-----------|
| **Banxico — SPEI** | `spei_*` family | D08 bdispei | CÓDIGO (DML confirmado) |
| **Banxico — CoDi** | `spei_devcodi`, `spei_recerrorescodi` | D08 bdispei | CÓDIGO |
| **Banxico — Portabilidad nómina** | `sp_notif_cambios_portacec` | D04 bdicheq | CÓDIGO (11,423 LOC) |
| **Buró de Crédito** | `sp_mon_buro_conssolcredlincred2` | D03 bdicred | CÓDIGO (fan_in=325) |
| **Círculo de Crédito** | `cal_circulocredito*` | D06 bdisolic | CÓDIGO |
| **Western Union** | `sp_validabts`, `sp_consinfobtssif` | D05 bdisac | CÓDIGO (fan_in=182-243) |
| **OXXO** | `spei_entordenespago_oxo` | D08 bdispei | CÓDIGO |
| **MIB** (interbancario) | `spei_*mib*` | D08 bdispei | CÓDIGO |
| **TRIAD** (cobranza) | `sp_layout_in_triad_cob` | D11 bdicobranza | CÓDIGO (4,014 LOC) |
| **Biometría** | `sp_fc_bitacorahuellas` | D01 bdicnweb | CÓDIGO |

---

## Hallazgos de Deuda Técnica (Input para 7R / Pricing)

### Deuda Estructural
| Patrón | Instancias | Impacto |
|--------|-----------|---------|
| SP copy-paste con sufijo `_cjunk` | ~42+ en D06 | Versionado implícito, múltiples "verdades" en producción |
| SP copy-paste con sufijo `_rodo`, `_jlh` | ~15+ en D06 | Código de desarrollador en producción sin renombrar |
| SP mayor de 3,000 LOC | 8+ SPs | Imposibles de revisar manualmente; alto riesgo de equivalencia |
| String-as-protocol (`sp_split_cadena`) | 857 callers | Contratos implícitos invisibles — deuda de documentación |
| Motor regex en SPL (34 MB) | 8 SPs | Dependencia de infraestructura reemplazable |

### SPs Aislados (candidatos a dead code)
| Dominio | Aislados | % |
|---------|---------|---|
| D04 bdicheq | 1,425 | 93% |
| D01 bdicnweb | 63 | 3% |
| D03 bdicred | 1,273 | 77% |
| D06 bdisolic | 457 | 84% |

Los SPs aislados de D04 y D03 son candidatos a retiro (7R = **Retire**) — no son llamados desde ningún otro SP conocido. Requieren validación contra logs de ejecución antes del decommission.

---

## Vocabulario Canónico del Sistema (resumen Capa 1)

**103 términos añadidos al sp_vocab.py en esta sesión** (8 rondas de enriquecimiento).

Los tokens más significativos para el negocio:

| Categoría | Tokens clave |
|-----------|-------------|
| Transacción | `cargo`, `abono`, `reversion`, `bloqueo` |
| Crédito | `tc`, `circulo`, `buro`, `scoring`, `califica`, `reevaluacion` |
| Pagos | `spei`, `codi`, `clabe`, `nomina`, `portab`, `dispersion` |
| Cobranza | `cob`, `cobranza`, `compromiso`, `acuerdo` |
| Contabilidad | `libro`, `auxiliar`, `balanza`, `ctb` |
| Mensajería | `mnsj`, `chi`, `innovattia`, `wu` (Western Union) |
| Sucursal | `bym`, `piezas`, `dictamen`, `suc` |
| Integración | `cnsif`, `sif`, `fal`, `sac`, `dicta` |
| Infraestructura | `split`, `cadena`, `regex`, `online`, `masivo` |

---

## Estado del Grounding Pass

| Fase | Estado |
|------|--------|
| Capa 1 — Lenguaje (sp_vocab.py) | ✅ COMPLETO — 103 términos añadidos |
| Capa 2 — Mapa de las Almas | ✅ COMPLETO — este documento |
| sp-specs-*.md por dominio (12) | ✅ COMPLETO — todos generados |
| sp-validation-*.json (12) | ✅ COMPLETO — todos generados |
| Capa 3 — Biografía (evolución temporal) | ⏳ PENDIENTE |
| Capa 4 — Intención (contratos implícitos) | ⏳ PENDIENTE |
| Portal HTML del Gemelo Cognitivo | ⏳ PENDIENTE — vocab y almas a integrar |

---

*Capa 2 generada: 2026-07-11 · Grounding Pass Round 1–8 completado · SPE-AM-001 BanCoppel*