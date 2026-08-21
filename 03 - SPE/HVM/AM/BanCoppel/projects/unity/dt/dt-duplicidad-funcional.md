# DT Duplicidad Funcional — Swarm DT-SWAP · Unity vs Legado
> **Tipo:** Digital Twin de Análisis Arquitectónico  
> **Versión:** 1.0.0 · 2026-08-20  
> **Brain:** `digital-brain/brain.db::functional_duplicity` (23 candidatos)  
> **Estado:** CANDIDATE — ningún escenario es una decisión; todos requieren validación técnica con el DBA IBM Informix, el arquitecto de Unity y el owner de negocio.

---

## Propósito

Este DT coordina un swarm de 8 agentes especializados (DT-SWAP-01..08) que identifican capacidades funcionales duplicadas entre los sistemas del programa Unity (nuevo) y los sistemas legados de BanCoppel. El resultado es un catálogo de **candidatos de duplicidad** — no decisiones — que sirven de punto de partida para:

1. Alinear el plan de decommission de Informix/PISA con los hitos reales del programa
2. Identificar qué decisiones arquitectónicas están bloqueando el decommission
3. Priorizar el análisis técnico detallado por impacto y urgencia

**Regla de oro:** toda entrada en este DT es un `candidate`. El escenario recomendado es el análisis inicial del swarm basado en evidencia documental disponible al 2026-08-20. Antes de registrar un escenario como `decided`, se requiere:
- Validación con el DBA IBM Informix (conteos reales de SPs afectados)
- Análisis de feature-parity entre sistema legado y sistema nuevo
- Sign-off del arquitecto de Unity y el owner de negocio

---

## El Swarm — 8 Agentes DT-SWAP

| Agente | Par de sistemas | DUPs | Blockers |
|--------|----------------|------|----------|
| DT-SWAP-01 | Temenos Transact ↔ SIF/Informix | DUP-001..003 | 2 |
| DT-SWAP-02 | SmartVista (BPC) ↔ Intercard/Macweb + Informix D16 | DUP-004..006 | 1 |
| DT-SWAP-03 | Apolo ↔ SIWEB legacy + Informix D26/D15 | DUP-007..009 | 0 |
| DT-SWAP-04 | App Movil / SIWEB ↔ legacy channels + Informix D01 | DUP-010..012 | 1 |
| DT-SWAP-05 | Atlas GCP ↔ Informix Golden Record + SOC/TASF | DUP-013..015 | 1 |
| DT-SWAP-06 | Apificación/MuleSoft ↔ IBM BUS + InterAct/Syndein | DUP-016..018 | 2 |
| DT-SWAP-07 | Unity Reportes Regulatorios ↔ legacy batch CTM | DUP-019..021 | 1 |
| DT-SWAP-08 | Cobranza Direccionada ↔ Informix D07/D40-D42 | DUP-022..023 | 0 |

**Total: 23 candidatos · 8 migration blockers**

---

## Resumen por Escenario Recomendado

| Escenario | Candidatos | Qué significa |
|-----------|-----------|---------------|
| `coexistence` | 8 | Ambos sistemas operan en dominios distintos indefinidamente o durante un período largo. La duplicidad es el estado esperado y correcto. |
| `complement` | 6 | Los sistemas se complementan: el nuevo no elimina al legado, sino que se apoya en él. Convivencia intencional. |
| `decommission` | 3 | El sistema legado debe apagarse eventualmente; el nuevo lo sustituye completamente. Requiere un plan de cutover. |
| `absorb` | 4 | El sistema nuevo absorbe la funcionalidad del legado (con parallel-run y equivalence check). |
| `tbd` | 1 | Fuera de scope R4; decisión en releases futuros. |
| `migrate` | 1 | El legado se migra al nuevo en una operación planeada (distinto de absorb: la iniciativa es del legado hacia el nuevo). |

---

## 8 Migration Blockers — Decisiones que Bloquean el Decommission

Los siguientes candidatos tienen `migration_blocker=1` — son las decisiones que deben tomarse antes de que el decommission de Informix pueda proceder:

### BLOCKER-1 · DUP-001: Golden Record en Informix (DT-SWAP-01)
**El problema:** La carga inicial Informix→Atlas no aparece en ningún documento del programa. Sin ella, el Golden Record del cliente permanece en Informix indefinidamente.  
**Decisión necesaria:** ADR sobre cuándo y cómo migrar el Golden Record. Prerequisito para Exodus Ola 6 (2029-H2).

### BLOCKER-2 · DUP-003: RETURN WITH RESUME en D05 (DT-SWAP-01)
**El problema:** D05 Saldos usa el patrón producer RETURN WITH RESUME (5,433 SPs producers en todo Informix). El patrón no existe en SQL estándar — requiere refactorización en Transact.  
**Decisión necesaria:** Estrategia de parallel-run para D05: shadow mode o feature flag por segmento.

### BLOCKER-3 · DUP-004: 3 millones de tarjetas en Intercard (DT-SWAP-02)
**El problema:** ~3M tarjetas activas en el CMS legacy (Intercard, producto 6001). La migración de portafolio no tiene fecha confirmada ni plan técnico documentado.  
**Decisión necesaria:** Timing y estrategia de migración de portafolio: batch masiva vs. corte por segmento, rollback.

### BLOCKER-4 · DUP-010: 49 SPs Informix desde App Movil (DT-SWAP-04)
**El problema:** 49 SPs de Informix son llamados desde el App Movil legacy. La nueva App necesita exponer los mismos endpoints (o equivalentes) antes de desconectar el legado.  
**Decisión necesaria:** Inventario de feature-parity: qué de los 49 SPs va a Transact, SmartVista, u otro sistema.

### BLOCKER-5 · DUP-013: Tres candidatos al Golden Record simultáneos (DT-SWAP-05)
**El problema:** Informix (autoridad hoy), Atlas (Fase 2 sin diseño) y Transact (nunca activado para GR) son tres candidatos simultáneos al Golden Record. Sin decisión formal.  
**Decisión necesaria:** ADR obligatorio: sistema autoritativo + plan de migración. Prerequisito de Regla B7 (capability_gap=0 antes de decommission).

### BLOCKER-6 · DUP-016: IBM BUS sin inventario de APIs (DT-SWAP-06)
**El problema:** IBM BUS es una de las 3 únicas vías al core Informix. No se puede decomisionar hasta que todas sus rutas estén en MuleSoft. El Plan Director admite que "no tiene plan ni inventario de APIs documentado".  
**Decisión necesaria:** Inventario completo de rutas IBM BUS. Resolver contradicción Plan Director (MuleSoft) vs Exodus Ola 1 (Apigee).

### BLOCKER-7 · DUP-017: InterAct acoplado al fate de Informix (DT-SWAP-06)
**El problema:** InterAct/Syndein es la segunda vía de middleware transaccional al core. Su decommission es consecuencia del decommission de Informix — no es independiente.  
**Decisión necesaria:** Alinear el timeline de InterAct con Exodus Ola 6. No bloquea R4, pero sí el decommission final.

### BLOCKER-8 · DUP-019: Bajaware en decomiso Q1-2027 (DT-SWAP-07)
**El problema:** Bajaware está en proceso de baja en Q1-2027 pero la arquitectura declarada ante la CNBV lo lista como motor de generación de reportes regulatorios. Nadie ha definido quién lo reemplaza.  
**Decisión necesaria:** Plan de remplazo de Bajaware URGENTE. Actualización de la documentación ante CNBV (hallazgos formales APO_F01 + SMA_F01).

---

## Mapa de Dependencias entre DUPs

Los siguientes DUPs están relacionados y deben resolverse en orden:

```
DUP-013 (Golden Record)
    └─ DUP-001 (Captacion)       — Transact funciona; Golden Record bloquea migración completa
    └─ DUP-014 (Deduplicacion)   — Atlas absorbe sp_compara_nombres cuando DUP-013 se resuelva

DUP-004 (Portafolio 3M TDC)
    └─ DUP-005 (Autorizacion)    — D16 se decommission cuando DUP-004 se resuelva
    └─ DUP-020 (Reportes TDC)    — D32 se decommission cuando DUP-004 se resuelva
    └─ DUP-022 (Cobranza)        — Cobranza D. absorbe D40-D42 cuando portafolio migre

DUP-016 (IBM BUS) + DUP-017 (InterAct)
    └─ Son consecuencia del decommission de Informix, no prerequisitos de R4
```

---

## Candidatos por Agente

### DT-SWAP-01 · Core Bancario Transaccional

| DUP | Capacidad | Legacy | Nuevo | Overlap | Escenario | Blocker |
|-----|-----------|--------|-------|---------|-----------|---------|
| DUP-001 | Captación de cuentas | SIF/Informix D04/D05 | Transact | full | coexistence | SI |
| DUP-002 | Crédito Simple Empresarial | D03 Créditos + Orión/TASF | Transact | partial | complement | no |
| DUP-003 | Saldos y movimientos | D05 Saldos (563 SPs) | Transact | full | absorb | SI |

### DT-SWAP-02 · Gestión de Tarjetas

| DUP | Capacidad | Legacy | Nuevo | Overlap | Escenario | Blocker |
|-----|-----------|--------|-------|---------|-----------|---------|
| DUP-004 | CMS ciclo de vida TDC | Intercard + D16 (3M TDC) | SmartVista | full | decommission | SI |
| DUP-005 | Autorización TDC | D16 + Intercard autorizador | SmartVista | partial | absorb | no |
| DUP-006 | Meses con intereses (MCI) | D03/D07 legacy MCI | SmartVista R4.5 | potential | coexistence | no |

### DT-SWAP-03 · Originación y Onboarding

| DUP | Capacidad | Legacy | Nuevo | Overlap | Escenario | Blocker |
|-----|-----------|--------|-------|---------|-----------|---------|
| DUP-007 | Onboarding digital TDC | SIWEB + D26 Prospectos | Apolo | partial | complement | no |
| DUP-008 | Validación KYC/PLD | D15 PLD + D26 KYC | Apolo (orquesta) | potential | coexistence | no |
| DUP-009 | Gestión documental contratos | OnBase-Prometeo + D14 | Apolo | partial | complement | no |

### DT-SWAP-04 · Canales Digitales y Sucursales

| DUP | Capacidad | Legacy | Nuevo | Overlap | Escenario | Blocker |
|-----|-----------|--------|-------|---------|-----------|---------|
| DUP-010 | App movil — consulta/operaciones | 49 SPs Informix D01/D05 | App Movil | full | absorb | SI |
| DUP-011 | Operaciones de sucursal | SIWEB legacy + D01/D14 | SIWEB nuevo | partial | coexistence | no |
| DUP-012 | Canal ATM (futuro R5) | D15 ATM + InterAct | SmartVista R5 | potential | tbd | no |

### DT-SWAP-05 · MDM y Golden Record

| DUP | Capacidad | Legacy | Nuevo | Overlap | Escenario | Blocker |
|-----|-----------|--------|-------|---------|-----------|---------|
| DUP-013 | Golden Record del cliente | Informix (autoridad HOY) | Atlas GCP | full | absorb | SI |
| DUP-014 | Deduplicación de clientes | sp_compara_nombres D01 | Atlas Vertex AI | partial | absorb | no |
| DUP-015 | MDM Grupo cross-empresa | SOC/TASF + D04 | Atlas GCP | partial | complement | no |

### DT-SWAP-06 · Capa de Integración

| DUP | Capacidad | Legacy | Nuevo | Overlap | Escenario | Blocker |
|-----|-----------|--------|-------|---------|-----------|---------|
| DUP-016 | ESB routing/mediación | IBM BUS/ACE | Apificación/MuleSoft | full | decommission | SI |
| DUP-017 | Middleware transaccional | InterAct/Syndein | Apificación | full | coexistence | SI |
| DUP-018 | Pagos SPEI/CoDi | D13 TEF (628 SPs) | Apificación + SmartVista | partial | coexistence | no |

### DT-SWAP-07 · Reportería Regulatoria

| DUP | Capacidad | Legacy | Nuevo | Overlap | Escenario | Blocker |
|-----|-----------|--------|-------|---------|-----------|---------|
| DUP-019 | Reportes regulatorios CNBV/Banxico | ~20 jobs CTM + Bajaware | Unity Reportes Reg. | partial | coexistence | SI |
| DUP-020 | Reportes portafolio TDC | D16/D32 VISA/MC/CNBV | SmartVista 18 reportes | partial | complement | no |
| DUP-021 | Contabilidad y asientos | D07/D08 + legacy libro mayor | Transact | partial | coexistence | no |

### DT-SWAP-08 · Cobranza y Recuperación

| DUP | Capacidad | Legacy | Nuevo | Overlap | Escenario | Blocker |
|-----|-----------|--------|-------|---------|-----------|---------|
| DUP-022 | Motor de cobranza | D07/D08/D40/D41/D42 Informix | Cobranza Direccionada | partial | complement | no |
| DUP-023 | Reglas BRM cobranza | Experian/WebMethods/BRM Coppel | SmartVista + Cobranza D. | potential | coexistence | no |

---

## Contradicciones Críticas Detectadas

El swarm identificó tres contradicciones entre programas y documentos que deben resolverse antes de tomar decisiones de decommission:

1. **SIWEB: ¿deprecar o mantener?** — Exodus/APO clasifica SIWEB como "Eliminar (Deprecar)" pero Unity R4 tiene 5 User Stories activas para SIWEB (DUP-011).

2. **API Gateway: MuleSoft vs Apigee** — El Plan Director declara migración a MuleSoft (Apigee con EOL 2027). Exodus Ola 1 va en sentido opuesto: "Mantener y migrar su gateway a Apigee". Son DOS migraciones simultáneas de gateway en sentidos contrarios (DUP-016).

3. **Golden Record: Informix vs Atlas vs Transact** — Tres sistemas candidatos simultáneos sin decisión formal. El documento CNBV es claro: hoy es Informix. Atlas Fase 2 no tiene diseño. Transact nunca fue activado para Golden Record (DUP-013).

---

## Queries de Consulta

```python
from digital_brain.brain import UnityBrain

b = UnityBrain()

# Ver todos los candidatos con blocker
blockers = b.con.execute(
    "SELECT id, capability_domain, legacy_system, new_system, blocker_description "
    "FROM functional_duplicity WHERE migration_blocker=1 ORDER BY id"
).fetchall()

# Ver distribución por escenario recomendado
by_scenario = b.con.execute(
    "SELECT recommended_scenario, COUNT(*) as n "
    "FROM functional_duplicity GROUP BY recommended_scenario ORDER BY n DESC"
).fetchall()

# Buscar por dominio funcional
matches = b.con.execute(
    "SELECT id, dt_agent, capability_domain, recommended_scenario "
    "FROM functional_duplicity_fts WHERE functional_duplicity_fts MATCH 'tarjeta'"
).fetchall()
```

---

## Próximos Pasos del Swarm

| Prioridad | Acción | Owner | Plazo |
|-----------|--------|-------|-------|
| 1 | ADR Golden Record: sistema autoritativo + plan migración Informix→Atlas | Arquitecto Unity | Sep-2026 |
| 2 | Inventario rutas IBM BUS completo | Apificación Lead | Sep-2026 |
| 3 | Plan reemplazo Bajaware (Q1-2027 deadline) | Reportes Reg. Owner | Sep-2026 |
| 4 | Inventario feature-parity: 49 SPs App Movil vs endpoints nuevos | DT-APP Lead | Oct-2026 |
| 5 | Fecha y estrategia migración portafolio 3M tarjetas | SmartVista Lead | Post go-live R4 |
| 6 | Inventario 30-50 HUs Cobranza Direccionada (ISSUE-R4-005) | Marksey Sanvicente | VENCIDO |
| 7 | Desambiguar BRM (WebMethods vs Experian vs BRM Coppel) en arquitectura | Arquitecto Unity | Oct-2026 |
| 8 | Resolver contradicción SIWEB: deprecar (Exodus) vs mantener (Unity R4) | PMO Unity + Exodus | Oct-2026 |

---

*Creado: 2026-08-20 · v1.0.0 · Swarm DT-SWAP-01..08 — 23 candidatos, 8 blockers de migración.*  
*Fuente: brain.db::functional_duplicity. Rebuild: `python digital-brain/build-brain.py --reset` desde unity/.*