# BC-04 ACL GL Interface — Contrato de Interfaz Unificado
> Anti-Corruption Layer entre S500 (Cargos y Abonos) y S151 (Movimientos Contables GL)
> Síntesis: S500-side (RN-S500-153..182) + S151-side (RN-S151-633..689) + dispatch table kb-capa5-fronteras.md
> Generado: 2026-07-21 · Fuentes: rules-s500-s151registra-p103fraude.md · rules-s151-l002r3-r4-r5.md · kb-capa5-fronteras.md
> **Indexado:** ✅ 2026-07-21 — Documento de síntesis BC-04 — NO remplaza los archivos fuente

---

## 1. Contexto arquitectónico

BC-04 es el Bounded Context más crítico del engagement. **TODA la contabilidad de S500 pasa por aquí** — cada cargo o abono de captación de Banamex que genera un asiento en el GL pasa por este ACL. No hay camino alternativo.

La interfaz funciona mediante un **flag de compilación condicional**: cuando un programa S500 declara `$SET S151REGISTRA`, el pre-procesador Unisys ClearPath MCP activa bloques en los includes canónicos que implementan la lógica de llamada a la librería ALGOL S151. La librería objeto es `(S151)S151/OBJECT/L002/REGISTRAS500`, entrypoint `CARGAMOV1 IN REGISTRAS500`.

### Diagrama AS-IS

```
┌─ S500 (COBOL) ─────────────────────────────────────────────────┐
│  P142 (CAPTACION)  ──CALL ENLACE_8D──→ L002R2 [S151REGISTRA]  │
│  P144 (CAPTACION)  ──CALL ENLACE_8D──→ L002R3 [S151REGISTRA]  │
│  P010 (TELLER)     ──CALL ENLACE_8D──→ L002R4 [S151REGISTRA]  │
│  P102/P105/P107/P110/P120/P127/P130/  ──────→ L002R5 [S151REGISTRA] │
│  P131/P168/P178/P180 + INC_WOR/PRO_CAN                        │
│  (15 unidades de compilación)                                  │
└────────────────────────────────────────────────────────────────┘
                          │  CARGAMOV1(WS-S151-0101-MOVIMIENTOS)
                          ▼
┌─ S151 (ALGOL ClearPath MCP) ───────────────────────────────────┐
│  L002R3 (9,355 LOC) — multi-canal base · SIST_LIB=500         │
│  L002R4 (7,280 LOC) — dispatch explícito · SIST_LIB=151/500/403/404 │
│  L002R5 (7,414 LOC) — enriquecido · lanzamiento directo P015/P016 │
│                                                                │
│  → 10 archivos MOV/DES/SDO por canal (LOGS[0:9], DESS[0:9], SDOS[0:9]) │
│  → BD10 (S151BD10MOVDIA151) = LOG de movimientos (feed a BD11) │
│  → BD11 (S151BD11SDOS151) = Libro Mayor (B72POSCONTA = posición contable) │
└────────────────────────────────────────────────────────────────┘
```

---

## 2. Tabla de dispatch: Programa S500 → Versión L002Rx

| Programa S500 | Tipo | LOC | Canal | L002Rx destino | Justificación |
|---------------|------|-----|-------|----------------|---------------|
| P142 | COBOL | ~7K | Batch captación | L002R2 | Enlace_8D → L002R2 (dispatch explícito en kb-capa5) |
| P144 | COBOL | ~7K | Batch captación | L002R3 | Enlace_8D → L002R3 (dispatch explícito en kb-capa5) |
| P010 | COBOL | 18,943 | Online/Teller | L002R4 | Enlace_8D → L002R4 (dispatch explícito en kb-capa5) |
| P102, P105, P107 | COBOL | varios | Varios | L002R5 | $SET S151REGISTRA → L002R5 (remaining pool) |
| P110, P120, P127 | COBOL | varios | Varios | L002R5 | $SET S151REGISTRA |
| P130, P131, P168 | COBOL | varios | Varios | L002R5 | $SET S151REGISTRA |
| P178, P180 | COBOL | varios | Varios | L002R5 | $SET S151REGISTRA |
| INC_WOR_CAN (include) | INC | — | All | activación | Define WS-S151-0101-MOVIMIENTOS (~230 campos) |
| INC_PRO_CAN (include) | INC | — | All | activación | Implementa 20000151-CARGAMOV1* (6 procedimientos) |

> **Nota:** L002R2 existe pero sus reglas de negocio aún no han sido extraídas. Esta es una brecha en el catálogo — ver Pendiente §8.

---

## 3. Lado S500 — Contrato de llamada (RN-S500-153..182)

**Archivo fuente:** `rules-catalog/rules-s500-s151registra-p103fraude.md`
**Rango:** RN-S500-153..182 (30 reglas)

### 3.1 Inicialización de la librería (RN-S500-153)

Una sola vez por sesión, el programa S500 ejecuta `10000151-REGISTRA`:
- Identifica la librería con `S151L002R500` en el gestor central de versiones
- Asigna el título a `REGISTRAS500` via `CHANGE ATTRIBUTE TITLE`
- Levanta el flag `WKS-88-REGISTRAS500 = 1`
- **Riesgo:** Si el control de versiones falla (CVEERROR ≠ 0), el programa continúa sin terminar — puede operar con librería incompatible

### 3.2 Contrato de las 8 funciones CARGAMOV1 (RN-S500-154)

```
WS-S151-0101-FUNCION:
  1  = REGMOV  — enviar movimiento al GL S151
  2  = ELIMOV  — eliminar movimiento enviamente enviado
 11  = INICIO  — apertura de grupo de movimientos
 12  = FIN     — cierre de grupo de movimientos
 21  = ELIPASO — borra todos los movimientos del paso actual
 22  = ELIAUT  — borra todos los movimientos de la autorización
 31  = BLO50   — rebloqueo de 50 registros en S151
 32  = BLO01   — rebloqueo de 1 registro en S151

CALL "CARGAMOV1 IN REGISTRAS500"
     USING    WS-S151-0101-MOVIMIENTOS
     GIVING   WS-S151-0101-STATUS      ← 0=OK / >0=error
```

### 3.3 Dos formatos de mensaje — BREAKING DIFFERENCE (RN-S500-155)

| Campo | Format 1 (S151REGISTRA1) | Format 2 (S151REGISTRA2) |
|-------|--------------------------|--------------------------|
| CVETRAN | PIC 9(04) — 4 dígitos | PIC 9(06) — 6 dígitos |
| IMPORTE | PIC 9(14)V99 | PIC 9(16)V99 |
| CVEDESVIO | No existe | PIC 9(04) |
| GUIDESVIO | No existe | PIC 9(04) |

El formato se selecciona en **tiempo de compilación** por flag. Si S151 amplía catálogo de CVETRANs a 6 dígitos, todos los programas Format1 requieren recompilación.

### 3.4 Mecanismo de batching — acumulación de 5 CVETRANs (RN-S500-156..157)

El include implementa un buffer de 5 slots:
- Si hay espacio: llena CVETRAN1..5 progresivamente
- Si overflow (5 slots llenos y más CVETRANs): **auto-flush** — envía el mensaje parcial, limpia slots, encadena el nuevo asiento via `WS-S151-0101-REFS151-ANT`
- El mecanismo de **encadenamiento REFS151-ANT** es obligatorio para preservar la atomicidad de asientos con >5 CVETRANs

### 3.5 Modo contingencia (RN-S500-158)

```
IF WS-88-EN-CONTINGENCIA-S151:
  PERFORM 00000000-GRABA-CONTING-S151   ← encola en archivo, no llama S151
ELSE:
  CALL "CARGAMOV1 IN REGISTRAS500"
```
Solo en modo LINEA (online). No existe contingencia equivalente en modo batch documentado.

### 3.6 Hardcodes críticos en el side S500 (RN-S500-160..168)

| ID | Hardcode | Riesgo |
|----|----------|--------|
| RN-S500-160 | Instrumento 6 / Producto 500 → IND-EDOCTA=0 (excluye estado de cuenta) | CNBV CONDUSEF si incorrecto |
| RN-S500-161 | IND-DATOS-ADIC siempre = 1 (nunca parametrizado) | Performance S151 innecesaria |
| RN-S500-162 | CVETRAN 4159/4160 → SUCPROM=342 (comentario dice 350 — discrepancia) | Asiento en sucursal incorrecta |
| RN-S500-163 | CVETRAN 4449/ACNOMINAPORTA → SUCPROM=SUCTRAN=SUCS028=859, CAJOPER=40 (CUT SPEI 2018) | 6 campos hardcoded |
| RN-S500-165 | PIM CVETRANs 3002/4001/3018/4016 → CAJS028=94(PIM)/79(no-PIM), SUCS028=907/904 según NODORI | Larga lista de perfiles 88 |
| RN-S500-168 | MONEDA=1 para CVETRANs 13/14 (pesos hardcoded) | Multidivisa futura |

---

## 4. Lado S151 — Librería ALGOL REGISTRAS (RN-S151-633..689)

**Archivo fuente:** `rules-catalog/rules-s151-l002r3-r4-r5.md`
**Rango:** RN-S151-633..689 (57 reglas)

### 4.1 Tabla comparativa de versiones

| Característica | L002R3 (9,355 LOC) | L002R4 (7,280 LOC) | L002R5 (7,414 LOC) |
|----------------|--------------------|--------------------|---------------------|
| SIST_LIB soportados | 500 | 151, 500, 403, 404 | 151, 500, 403, 404 |
| Dispatch FUNCION | Implícito (CARGAMEMORY) | CASE 10 funciones | CASE 10 funciones |
| REBLOCKADE (31/32) | No | Sí | Sí |
| Lanzamiento P015/P016 | PROC_CONTROL/LEVANTA_PASOS | PROC_CONTROL | Directo desde CARGAMOV |
| Lanzamiento P025 | PROC_CONTROL | PROC_CONTROL | CARGAMOV (TIPPROC>15) |
| FILLERXAPL 165w | No | No | Sí |
| LYENDA1-5 (400 bytes) | No | No | Sí |
| COMMPOST/CPOST | No | Sí (comentado) | Sí (comentado) |
| B05 registro | No | Sí (FUNCION=19) | Sí |
| Validación sistema | IDFSISTFAN | IDFSISTFAN | IDFSISTEMA |
| Offsets BCO_ORIG/DEST | — | 342+345 (3 dig) | 262+267 (5 dig) |

> **DIFERENCIA CRÍTICA (RN-S151-685):** Los record layouts de L002R4 (offset 342+345, 3 dígitos) y L002R5 (offset 262+267, 5 dígitos) son **incompatibles**. No se pueden intercambiar.

### 4.2 Las 10 funciones del dispatch (L002R4/R5) (RN-S151-660/675)

| FUNCION | Procedimiento | Descripción |
|---------|---------------|-------------|
| 1 | CARGAMEMORY | Inserción de registro MOV |
| 2 | ELIMINA | Borrado lógico |
| 11 | INICIA | Inicio de canal |
| 12 | TERMINA | Fin de canal |
| 21 | ELIMXPROC | Elimina por proceso |
| 22 | ELIMXAUT | Elimina por autorización |
| 31 | REBLOCKADE | Re-bloqueo alta capacidad (blocksize 10800) |
| 32 | REBLOCKADE | Re-bloqueo normal (blocksize 150, SYNCHRONIZE=OUT) |
| 97 | PREFINAL | Pre-cierre (sin sync L001) |
| 98 | FINAL | Cierre final (con sync L001, hasta 3 reintentos) |

FUNCION inválida → RESULT=2, GRABAMOV=FALSE, error "FUNCION NO VALIDA".

### 4.3 Arquitectura de multi-canal con 10 canales (RN-S151-633)

L002R3/R4/R5 mantienen **10 canales paralelos**:
- Arrays: `LOGS[0:9]` (MOV), `DESS[0:9]` (descriptores), `SDOS[0:9]` (saldos), `CBII[0:9]` (S500), `CDIR[0:9]` (S500)
- `NUMDIAC1` = canal activo (seleccionado por fecha contable IDFFECCONT)
- Cada canal tiene su propio write pointer `NIVLOG_A[i]`, fecha `FEC_DIA[i]` y contador `REG_X_BLOCK[i]`
- CBII y CDIR solo existen para `SIST_LIB=500`

### 4.4 Timer de 30 segundos para flush automático (RN-S151-638)

```
WAITANDRESET((30), MYSELF.EXCEPTIONEVENT, BLOCK_LLENO, LEVANTA_PASOS, ...)
```
Cada 30 segundos: cierra canales con `REG_X_BLOCK[i] > 0 AND FEC_DIA[i] >= FEC_PRO_BASE`. En migración: flush periódico con el mismo SLA temporal.

### 4.5 Prerequisitos para ejecutar P169 (RN-S151-643)

Solo para `SIST_LIB=500`: P169 (fase final GL nocturna) se ejecuta si y solo si:
```
FIN_S408 AND FIN_S500 AND FUNCION_82 AND FUNCION_83   ← 4 flags simultáneos
```
Esta es la señal de sincronización que indica "todos los subsistemas de captación completaron".

### 4.6 Lanzamiento P015/P016 diferencial entre versiones (RN-S151-676)

- **L002R3:** PROC_CONTROL → LEVANTA_PASOS (event-driven, indirecto)
- **L002R4:** PROC_CONTROL (similar a R3)
- **L002R5:** **directo desde CARGAMOV** tras cada escritura FUNCION=1. Si P015 y P016 disponibles AND HORA < 200000 → VERSION → WAIT(3) → EXTERNO. Cada inserción puede disparar un proceso externo.

### 4.7 Ciclo de vida del canal — protocolo AMBIENTA (RN-S151-641)

Evento AMBIENTA (fin de día):
1. DCKEYIN `"{NUM_MIX_P015(L)} HI 4"` a todos los canales P015 activos
2. DCKEYIN `"{NUM_MIX_P016(L)} HI 4"` a todos los canales P016 activos
3. WAIT(2) — espera procesamiento del halt
4. CIERRALOG para L=0..9
5. CLOSE(ERRORES1, LOCK)
6. LEVANTA_P015 = FALSE, ACTIVA_P015 = ACTIVA_P016 = FALSE
7. Valida S151LOTE en CTLVERS

---

## 5. Hardcodes y diferencias críticas entre versiones

### Validación del sistema de origen

| Versión | Campo de validación | Campo ALGOL |
|---------|--------------------|-----------------------|
| L002R3 | IDFSISTFAN | Identificador de fan/subsistema fuente |
| L002R4 | IDFSISTFAN | Mismo que R3 |
| L002R5 | **IDFSISTEMA** | Campo diferente — identificador del sistema principal |

SME debe confirmar la diferencia entre IDFSISTEMA e IDFSISTFAN en el record layout.

### Offsets incompatibles entre R4 y R5 (RN-S151-685 vs RN-S151-669)

| Versión | Offset BCO_ORIG | Offset BCO_DEST | Dígitos |
|---------|----------------|----------------|---------|
| L002R4 | +342 | +345 | 3 dígitos |
| L002R5 | +262 | +267 | 5 dígitos |

Para `SIST_LIB ≠ 500/403/404`, ambas versiones sobrescriben estos campos con valor 2 — pero en posiciones y longitudes distintas. Los programas S500 que llaman L002R4 vs L002R5 no son intercambiables.

### FILLERXAPL — buffer polimórfico (RN-S151-682)

Presente solo en L002R5. `REPLACE POINTER(FILLERXAPL, 4) FOR 330` copia 165 words (330 halfwords) de datos de sistemas "aplicativos". Tiene 15+ REDEFINES según sistema de origen. Identificado en el audit report como **"máxima complejidad equivalencia"**. No es un filler vacío.

---

## 6. Riesgos de migración BC-04

| ID | Riesgo | Severidad | Referencia |
|----|--------|-----------|------------|
| MR-NOM-01 | Nomenclatura inconsistente: BC-04 vs BCO-04 vs ACL-GL entre documentos | MEDIO | migration-risk-register.md |
| — | Encadenamiento REFS151-ANT no replicado → asientos huérfanos >5 CVETRANs | 🔴 ALTA | RN-S500-157 |
| — | FILLERXAPL sin mapear → pérdida de datos aplicativos en L002R5 | 🔴 ALTA | RN-S151-682 |
| — | Record layouts R4 vs R5 incompatibles → corrupción si se intercambian | 🔴 ALTA | RN-S151-685 |
| — | FIN_S408 AND FIN_S500 AND FUNCION_82 AND FUNCION_83 no replicado → P169 no ejecuta | 🔴 ALTA | RN-S151-643 |
| — | Modo contingencia S151 solo existe en modo LINEA; batch sin fallback | 🟡 MEDIO | RN-S500-158 |
| — | SUCPROM=342 vs comentario "350" (RN-S500-162) — discrepancia no resuelta | 🟡 MEDIO `[AMBIGUO-SME]` | RN-S500-162 |
| — | L002R2 sin reglas extraídas → 1 de 4 dispatch paths sin documentar | 🔴 ALTA | kb-capa5-fronteras.md §6 |
| MR-COX-03 | BC-04 dual-mode: ENLACE_8D hacia legacy S151 + GL-Posting-Service nueva | CRÍTICO | migration-risk-register.md |

---

## 7. Target (TO-BE) — GL Posting Service

Referencia: `kb-capa5-fronteras.md §6 Target (TO-BE)`.

```
[S500 modernizado] ──HTTP/gRPC──→ GL-Posting-Service ──→ [S151 ALGOL intacto o modernizado]
                                         │
                                  Contrato OpenAPI 3.1:
                                  POST   /gl/entries        (CARGAMOV FUNCION=1)
                                  DELETE /gl/entries/{id}   (CARGAMOV FUNCION=2)
                                  POST   /gl/tesofe         (GRABASDO — SEPARA_S500)
```

**Contratos de equivalencia obligatorios para BC-04:**
- Toda llamada a GL-Posting-Service debe producir exactamente el mismo asiento que la llamada directa a ENLACE_8D
- Equivalencia ≥ **99.99%** — asiento contable es el registro más auditable del banco
- El comparator del parallel-run debe correr en **tiempo real** (no batch): cada transacción S500 que llame a BC-04 se reconcilia en el mismo día hábil
- ADR requerido: `ADR-SPE-MM-004` — Data sync strategy BC-04 (dual-write mientras S151 ALGOL sigue en MCP)

---

## 8. Wave plan y secuencia de delivery

BC-04 ACL es **Wave 0-A** — el primer componente modernizado, prerequisito de todas las demás waves.

| Wave | Bounded Context | Dependencia de BC-04 |
|------|----------------|----------------------|
| **0-A** | **BC-04 ACL GL Interface** | — (primer wave) |
| 0-B | S151 Platform Services (L030) | BC-04 estabilizado |
| 1 | BC-02/03/09 | BC-04 activo + parallel-run verde |
| 2 | BC-01/06/07/08 | Wave 1 cerrada |
| 3 | BC-05 GL | ÚLTIMO — mayor riesgo contable |
| 4 | WFL Replatform | T.5.1 — batch orchestrator |

**Punto de no retorno Wave 0-A:** 16:00 hrs del día de cutover (RTO ≤ 2h).

---

## 9. Pendientes y brechas documentales

| ID | Brecha | Prioridad |
|----|--------|-----------|
| HITL-BC04-01 | L002R2 — reglas no extraídas (P142 lo llama directamente según dispatch table) | Alta |
| HITL-BC04-02 | SUCPROM discrepancia 342 vs 350 en RN-S500-162 — requiere validación con operaciones Banamex | Media |
| HITL-BC04-03 | IDFSISTEMA vs IDFSISTFAN — SME debe confirmar diferencia en record layout | Media |
| HITL-BC04-04 | Sistemas 403 y 404 (L002R4/R5) no documentados en el inventario de sistemas S151 | Alta |
| HITL-BC04-05 | ACNIVEL / CONSISDIA con L001 comentado en L002R3 — ¿bug latente o desactivado definitivamente? | Media |
| HITL-BC04-06 | Equivalencia del mecanismo de contingencia en batch (no existe en código actual) | Alta |

---

## 10. Archivos fuente — índice de referencias cruzadas

| Archivo | Contenido | Rango |
|---------|-----------|-------|
| `rules-catalog/rules-s500-s151registra-p103fraude.md` | S151REGISTRA (S500 side) + P103 FraudLink | RN-S500-153..182 (30 reglas) |
| `rules-catalog/rules-s151-l002r3-r4-r5.md` | L002R3 + L002R4 + L002R5 (S151 side) | RN-S151-633..689 (57 reglas) |
| `kb-capa5-fronteras.md` §6 | Dispatch table AS-IS + Target TO-BE | lines 298-334 |
| `capacidades/cap-orc.md` | P021 — control de shutdown S500 vía DCKEYIN (BC-04 adjacent) | RN-S151-181..185 |
| `rules-catalog/rules-s151-p021-p120.md` | P021 + P120 SAR | RN-S151-181..232 |
| `migration-risk-register.md` §MR-COX-03 | Riesgo dual-mode BC-04 durante coexistencia | — |
| `coexistence-model.md` | Modelo de coexistencia Wave 0-A | — |
