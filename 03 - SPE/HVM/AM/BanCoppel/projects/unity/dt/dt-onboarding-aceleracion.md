# DT Swarm — Onboarding Aceleración (DT-ONB-01..05)

> **Fuente**: BanCoppel_Plan_Director_Aceleracion_Onboarding_ago-2026 (8 slides, agosto 2026)
> **Tabla brain**: `onboarding_finding_map` + `onboarding_hypotheses`
> **Rebuild**: `python digital-brain/build-brain.py --reset`
> **Versión**: v2.0.0 · 2026-09-03

---

## Contexto

Al 2026-08-31: **863,620 altas totales** Jan-Aug 2026 — 87.3% Sucursal (OFI Tradicional), 12.7% digital.
El programa Unity TDC está en F&F con ~30 clientes piloto. Antes de escalar a mercado abierto se requiere
resolver los bloqueantes estructurales documentados en este swarm.

Canales analizados:
- **OFI** — canal físico (sucursal), VB6 + Windows 7 virtualizado, 45 min promedio de apertura
- **Apolo** — nuevo sistema digital (AppWhere), 16 secciones, ~48 steps, 20 min en piloto
- **DUD** — Autosolicitudes digitales (cliente sin ejecutivo)

---

## Hipótesis de Trabajo (H1-H7)

| ID | Hipótesis | Estado |
|----|-----------|--------|
| H1 | Resolver conexión Coppel-BanCoppel (post-hackeo) | open |
| H2 | Resolver retoma de proceso ante caída en cualquier paso | open |
| H3 | Delegar a procesos nocturnos validaciones no críticas | open |
| H4 | Resolver latencia de Apolo (10-30 seg por step) | open |
| H5 | Levantar proceso operativo detallado en tienda | open |
| H6 | El ejecutivo opera Apolo, no el cliente | open |
| H7 | Microservicios de perfilamiento usando servicios legados | open |

---

## Flujo Apolo — 16 Secciones

| # | Sección | Steps | Sistemas clave |
|---|---------|-------|----------------|
| 01 | Preparación | 1, 1A, 2 | Apolo |
| 02 | Términos y condiciones | 3 | Apolo |
| 03 | Validación teléfono / OTP | 3A-3B | Apolo, OTP |
| 04 | Validación del cliente (INE/RENAPO) | 3D, 5A-7A | RENAPO, INE, Morpho |
| 05 | Validación de correo | 4-5 | Apolo |
| 06 | Perfilamiento | 8, 10 | YUGA, Informix |
| 07 | Validación de domicilio | 12-17A | YUGA, Informix |
| 08 | PEP / KYC | 17C | YUGA, Informix |
| 09 | PLD | 17D-17F | YUGA, Informix |
| 10 | Validación SICs | 18-23 | Buró, Círculo, BRM, YUGA, Informix |
| 11 | Paramétrico | 24-31 | YUGA, Informix |
| 12 | Oferta de Producto | 32-34 | SmartVista |
| 13 | Prueba de vida y video selfie | 37 | Apolo, Morpho |
| 14 | Solicitud de servicios digitales | 39-40 | Apolo |
| 15 | Integración de expediente digital | 41-45 | SmartVista, OS-Digital |
| 16 | Bienvenida | 46-47 | Apolo |

**Concentración legado**: YUGA 46 steps, Informix 27 steps = **73 de ~48 step-instancias** con llamada a legado.
**Checkpoints**: 105 entradas retrieve/initiate/update/execute en todo el flujo.

---

## Diagnóstico Estructural (slide 6)

Tres cuellos de botella críticos identificados:

1. **Step 23 — SICs**: Combina Buró, Círculo, BRM, Informix/YUGA y mocks. Latencia acumulada, rutas
   divergentes y dictámenes inconsistentes.
2. **Steps 42-43 — Alta SmartVista**: Creación, sincronización, firma y carga documental encadenados sin
   idempotencia ni compensación.
3. **Mocks en QA**: OTP, RENAPO, INE y fallback Buró activos. E2E aprueba sin probar proveedores reales.
   7 steps sin campo de obligatoriedad definido.

---

## Agentes del Swarm

### DT-ONB-01 — Canal OFI: Fricción y Obsolescencia (4 entradas)

Foco: OFI VB6 + Windows 7, retoma de proceso, biométrico, inestabilidad de apps.

| ID | Finding | Canal | Sección | Severidad | Blocker para |
|----|---------|-------|---------|-----------|-------------|
| ONB-001 | AUD-FF-001 — OFI VB6+Win7 obsolescencia | ofi | Toda la sesión | CRITICO | ff-escala |
| ONB-002 | AUD-FF-005 — Retoma imposible (SOLTAR) | ofi | Cualquier paso | ALTO | ff-escala |
| ONB-003 | RISK-UNITY-R32 — Biométrico Morpho/TDC | ofi | 04 - Validación cliente | ALTO | ff-escala |
| ONB-004 | AUD-FF-001 — Inestabilidad OFI/TDC Visa | ofi | Transversal | ALTO | ff-escala |

### DT-ONB-02 — Canal Apolo: Arquitectura del Flujo (4 entradas)

Foco: Concentración YUGA/Informix, latencia, checkpoint proliferación, volumen piloto bajo.

| ID | Finding | Canal | Sección | Severidad | Blocker para |
|----|---------|-------|---------|-----------|-------------|
| ONB-005 | AUD-FF-003 — YUGA(46)+Informix(27)=73 steps | apolo | Transversal | CRITICO | mercado-abierto |
| ONB-006 | RISK-UNITY-R30 — Latencia 10-30 seg/step | apolo | Transversal | ALTO | ff-escala |
| ONB-007 | AUD-FF-003 — 105 checkpoints | apolo | Transversal | ALTO | go-live |
| ONB-008 | AUD-FF-004 — Piloto ~30 clientes | todos | Transversal | MEDIO | ff-escala |

### DT-ONB-03 — Integraciones Críticas (5 entradas)

Foco: Mocks OTP/RENAPO/INE/Buró, alta parcial SmartVista, foliador OS.

| ID | Finding | Canal | Sección | Severidad | Blocker para |
|----|---------|-------|---------|-----------|-------------|
| ONB-009 | RISK-UNITY-R28 — Mock OTP | apolo | 03 - OTP (Steps 3A-3B) | CRITICO | sit |
| ONB-010 | RISK-UNITY-R28 — Mock RENAPO+INE | apolo | 04 - Validación cliente | CRITICO | sit |
| ONB-011 | RISK-UNITY-R28 — Mock Buró fallback | apolo | 10 - SICs (Step 23) | CRITICO | sit |
| ONB-012 | RISK-UNITY-R29 — Alta parcial SmartVista | apolo | 15 - Expediente (Steps 42-43) | CRITICO | go-live |
| ONB-013 | RISK-UNITY-R31 — Foliador OS límite 10M | apolo | 15 - Expediente (Steps 41-45) | ALTO | mercado-abierto |

### DT-ONB-04 — Brechas Regulatorias y KYC (4 entradas)

Foco: INE omitida en DUD, datos regulatorios faltantes en cierre, dictámenes inconsistentes SICs.

| ID | Finding | Canal | Sección | Severidad | Blocker para |
|----|---------|-------|---------|-----------|-------------|
| ONB-014 | AUD-FF-002 — INE omitida en DUD | dud | 04 - Validación cliente | CRITICO | mercado-abierto |
| ONB-015 | AUD-FF-002 — Datos regulatorios faltantes en cierre | todos | 15 - Expediente | ALTO | mercado-abierto |
| ONB-016 | AUD-FF-002 — Sin huella gerente con ID alt. | ofi | 04 - Validación cliente | MEDIO | ff-escala |
| ONB-017 | AUD-FF-003 — Dictámenes inconsistentes SICs | apolo | 10 - SICs (Step 23) | CRITICO | mercado-abierto |

### DT-ONB-05 — Calidad y Testing (3 entradas)

Foco: Cobertura E2E bloqueada por mocks, idempotencia steps 42-43, vacíos documentación.

| ID | Finding | Canal | Sección | Severidad | Blocker para |
|----|---------|-------|---------|-----------|-------------|
| ONB-018 | RISK-UNITY-R28 — E2E sin proveedores reales | apolo | Transversal | CRITICO | sit |
| ONB-019 | RISK-UNITY-R29 — Idempotencia steps 42-43 | apolo | 15 - Expediente | CRITICO | sit |
| ONB-020 | AUD-FF-003 — 7 steps sin obligatoriedad | apolo | Transversal | MEDIO | sit |

---

## Mapa de Bloqueantes por Gate

| Gate | Entradas ONB bloqueantes | Acción mínima |
|------|--------------------------|---------------|
| **sit** | ONB-009, ONB-010, ONB-011, ONB-018, ONB-019, ONB-020 | Desactivar mocks + definir idempotencia steps 42-43 |
| **ff-escala** | ONB-001, ONB-002, ONB-003, ONB-004, ONB-006, ONB-008 | Resolver biométrico + latencia + retoma + infraestructura OFI |
| **mercado-abierto** | ONB-005, ONB-013, ONB-014, ONB-015, ONB-017 | Resolver YUGA/Informix + INE DUD + SICs + foliador |
| **go-live** | ONB-007, ONB-012 | Idempotencia alta SmartVista + simplificación checkpoints |

---

## Queries de Referencia

```sql
-- Todos los bloqueantes de SIT (gate previo a escala F&F)
SELECT id, finding_id, flow_section_name, system_primary, severity
FROM onboarding_finding_map WHERE blocker_for = 'sit' ORDER BY severity;

-- Entradas por agente DT
SELECT dt_agent, COUNT(*) as total, severity
FROM onboarding_finding_map GROUP BY dt_agent, severity ORDER BY dt_agent, severity;

-- Sistemas más afectados
SELECT system_primary, COUNT(*) as total
FROM onboarding_finding_map GROUP BY system_primary ORDER BY total DESC;

-- Hipótesis sin mapeo (H con 0 entradas)
SELECT h.id, h.title FROM onboarding_hypotheses h
WHERE h.id NOT IN (
  SELECT DISTINCT value FROM onboarding_finding_map, json_each('["' || replace(hypothesis_ref,',','","') || '"]')
  WHERE hypothesis_ref IS NOT NULL);
```