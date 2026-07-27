# Reglas S500 S151REGISTRA · P103 Fraude
**Indexado:** ✅ 2026-07-17 — correlacionado vocab↔reglas↔capacidad (traceability-matrix.md)

> **S151REGISTRA:** Librería contable S500→S151 — TODA la contabilidad de S500 pasa por aquí
> **P103:** Bloqueo de fraude — 664 LOC, 3 claves hardcoded (2001/2444/2496)
> **Rango:** RN-S500-153 a RN-S500-182

---

## Contexto arquitectónico

### S151REGISTRA — naturaleza del artefacto

`S151REGISTRA` no es un archivo fuente independiente: es un **flag de compilación condicional** de Unisys ClearPath MCP COBOL. Cuando un programa S500 declara `$SET S151REGISTRA`, el preprocessor activa los bloques delimitados por `$SET OMIT = NOT S151REGISTRA` / `$POP OMIT` en los includes canónicos:

- **`S500_INC_WOR_CAN.txt`** — define `WS-S151-0101-MOVIMIENTOS` (estructura del mensaje, ~230 campos) y contadores de monitoreo
- **`S500_INC_PRO_CAN.txt`** — implementa `20000151-CARGAMOV1`, `20000151-CARGAMOV1-CALL`, `20000151-CARGAMOV1-IMP`, `20000151-CARGAMOV1-CTES`, `20000151-CARGAMOV1-INI`, `20000151-CARGAMOV1-LIMPIA`

La librería objeto S151 a la que se conecta es: `(S151)S151/OBJECT/L002/REGISTRAS500`, entrypoint `CARGAMOV1 IN REGISTRAS500`.

Programas S500 que activan S151REGISTRA (confirmado por Grep): P102, P105, P107, P110, P120, P127, P130, P131, P142, P144, P168, P178, P180 y al menos 2 includes canónicos (INC_WOR_CAN, INC_PRO_CAN). Total: 15 unidades de compilación.

### P103 — naturaleza del programa

P103 (664 LOC, autor José Luis Ibarra Lara, JUL/2005) es el programa **FRAUDLINK**: extrae diariamente los movimientos con clave de fraude de las bases B07MOVDIA y B13MOVCVES y genera un archivo que se envía al sistema S711 (detección y gestión de fraude). P103 no bloquea transacciones directamente; el bloqueo operativo lo ejecuta S711 basándose en el archivo que P103 genera.

---

## Índice rápido

| ID | Título corto | Tipo | Confianza |
|----|--------------|------|-----------|
| RN-S500-153 | Validación de versión librería S151 | `[CONTROL]` | alta |
| RN-S500-154 | Contrato de interfaz CARGAMOV1 — 8 funciones | `[LÓGICA-CONTABLE]` | alta |
| RN-S500-155 | Dos formatos del mensaje S151 (S151REGISTRA1 vs S151REGISTRA2) | `[RIESGO-EQUIVALENCIA]` | alta |
| RN-S500-156 | Acumulación de hasta 5 CVETRANs por mensaje | `[LÓGICA-CONTABLE]` | alta |
| RN-S500-157 | Auto-flush cuando los 5 slots están llenos | `[RIESGO-EQUIVALENCIA]` | alta |
| RN-S500-158 | Modo contingencia S151 (encolado en archivo) | `[CONTROL]` | alta |
| RN-S500-159 | Manejo de rechazos STATUS > 0 | `[CONTROL]` | alta |
| RN-S500-160 | IND-EDOCTA: instrumento 6 producto 500 excluye estado de cuenta | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-161 | IND-DATOS-ADIC siempre = 1 (performance hardcode) | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-162 | SUCPROM override para CVETRANs 4159/4160 → 342 | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-163 | SUCPROM override CVETRAN 4449/ACNOMINAPORTA → 859 + TRANAUT | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-164 | SUCPROM override CVETRANs 2136/2137/2138 → SUCTRAN | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-165 | SUCS028/CAJS028 hardcode por perfil PIM (CVETRANs 3002/4001/3018/4016) | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-166 | SUCS028 hardcode CVETRAN 3027 (cajero 55, nodo 907/904) | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-167 | SUCS028 hardcode CVETRAN 3047 (cajero 92, sucursal 342) | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-168 | MONEDA=1 para operaciones en pesos (CVETRANs 13/14 + otras) | `[REGLA-BANCARIA-MX]` | alta |
| RN-S500-169 | SGIRO: indicador de sobregiro línea vigente/vencida | `[LÓGICA-CONTABLE]` | alta |
| RN-S500-170 | ORIGEN: clasificación local / foráneo enviado / foráneo recibido | `[LÓGICA-CONTABLE]` | alta |
| RN-S500-171 | Propagación de leyenda para corresponsales (CVETRANs 1119/1120/2200) | `[REGLA-BANCARIA-MX]` | media |
| RN-S500-172 | Contadores de monitoreo de llamadas S151 | `[CONTROL]` | alta |
| RN-S500-173 | FRAUDLINK: objetivo y flujo general de P103 | `[REGLA-BANCARIA-MX]` | alta |
| RN-S500-174 | Trío de claves de fraude hardcoded: 2001 / 2444 / 2496 | `[HARDCODE-SOSPECHOSO]` `[REQUIERE-LEGAL]` | alta |
| RN-S500-175 | Fuentes duales: B07MOVDIA (principal) y B13MOVCVES (adicional) | `[LÓGICA-CONTABLE]` | alta |
| RN-S500-176 | Filtro de status B07: omite movimientos con STATUS = 1 | `[CONTROL]` | alta |
| RN-S500-177 | Escaneo de hasta 10 claves adicionales B13 por movimiento | `[LÓGICA-CONTABLE]` | alta |
| RN-S500-178 | Estructura del registro de salida FRAUDLINK (60 chars) | `[RIESGO-EQUIVALENCIA]` | alta |
| RN-S500-179 | Ruta del archivo de salida S711: S500/FILE/S711/FRAUDLINK/{CSI}/{FECHA} | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-180 | Header (tipo "1") y trailer (tipo "9") del archivo S711 | `[RIESGO-EQUIVALENCIA]` | alta |
| RN-S500-181 | BANCO=0002 hardcoded en todos los registros de salida | `[HARDCODE-SOSPECHOSO]` | alta |
| RN-S500-182 | Sistema receptor S711: feed para detección de fraude | `[REGLA-DISTRIBUIDA]` | media |

---

## BLOQUE 1 — S151REGISTRA (RN-S500-153 a RN-S500-172)

> Fuente primaria: `S500_INC_WOR_CAN.txt` (estructura de datos) + `S500_INC_PRO_CAN.txt` (procedimientos).
> Activado en al menos 15 unidades de compilación S500.

---

### RN-S500-153 — Validación de versión de librería S151

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-153 |
| **Nombre** | Validación de versión de librería S151 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — Control interno de compatibilidad de versiones |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — sección `10000151-REGISTRA` (líneas 807–826) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
10000151-REGISTRA:
  MOVE ZEROS TO S000-CTR-CVEERROR
  MOVE "S151L002R500" TO S000-CTR-LIBID
  PERFORM 20000100-DAME-TIT-VERS          -- llama al gestor de versiones central

  IF S000-CTR-CVEERROR = 0:
    CHANGE ATTRIBUTE TITLE OF "REGISTRAS500" TO S000-CTR-NOMLIB  -- asocia título de librería
  ELSE:
    mensajear("ERROR EN CALL CTLVERS (S151L002REG) RESULT=n")

  MOVE 1 TO WKS-88-REGISTRAS500          -- marca como inicializada
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `S000-CTR-LIBID` | CAMPO-CONTROL | Identificador de librería para el gestor de versiones |
| `S151L002R500` | HARDCODE | ID de la librería S151 de registro para S500 (L002 = lib 002, R500 = para S500) |
| `S000-CTR-CVEERROR` | CAMPO-CONTROL | Resultado del control de versiones (0 = OK) |
| `WKS-88-REGISTRAS500` | FLAG | Indicador de librería REGISTRAS500 inicializada (PIC 99 COMP) |
| `REGISTRAS500` | OBJETO | Nombre del objeto librería Unisys en memoria activa |

**Excepciones documentadas:**
- Si el control de versiones falla (CVEERROR ≠ 0), el programa emite mensaje pero continúa (no termina). Riesgo: puede operar con librería incompatible.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-154 — Contrato de interfaz CARGAMOV1 (8 funciones operacionales)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-154 |
| **Nombre** | Contrato de interfaz CARGAMOV1 (8 funciones operacionales) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[LÓGICA-CONTABLE]` `[RIESGO-EQUIVALENCIA]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB Serie R (cada función tiene impacto en asientos GL auditables) |
| **Programa ejecutor** | `S500_INC_WOR_CAN.txt` (líneas 4258–4268 — comentario documental del contrato) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
WS-S151-0101-FUNCION define la operación:
  1  (REGMOV)  = ENVIAR movimiento al GL S151
  2  (ELIMOV)  = ELIMINAR movimiento previamente enviado
 11  (INICIO)  = INICIO DE MOVIMIENTO (señal de apertura de grupo)
 12  (FIN)     = FIN DE MOVIMIENTO (señal de cierre de grupo)
 21  (ELIPASO) = BORRA todos los movimientos del paso actual
 22  (ELIAUT)  = BORRA todos los movimientos de la autorización actual
 31  (BLO50)   = REBLOQUEO de 50 registros en S151
 32  (BLO01)   = REBLOQUEO de 1 registro en S151

CALL "CARGAMOV1 IN REGISTRAS500"
    USING    WS-S151-0101-MOVIMIENTOS
    GIVING   WS-S151-0101-STATUS
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-0101-FUNCION` | CAMPO-CLAVE | Código de operación del GL S151 (PIC 9(2) COMP) |
| `WS-S151-0101-MOVIMIENTOS` | ESTRUCTURA | Estructura completa del mensaje S151 (ver RN-S500-155) |
| `WS-S151-0101-STATUS` | CAMPO-RESULTADO | 0 = éxito; > 0 = error de registro en S151 |
| `CARGAMOV1 IN REGISTRAS500` | ENTRYPOINT | Entrypoint Unisys de la librería S151 objeto |

**Excepciones documentadas:**
- Las funciones 11/12 (INICIO/FIN) no llevan importe — son señales de demarcación de un grupo de movimientos atómicos.
- Las funciones 21/22 (ELIPASO/ELIAUT) eliminan en masa; su uso implica que el grupo de movimientos fue rechazado y debe revertirse.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-155 — Dos formatos del mensaje S151: S151REGISTRA1 vs S151REGISTRA2

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-155 |
| **Nombre** | Dos formatos del mensaje S151: S151REGISTRA1 vs S151REGISTRA2 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[RIESGO-EQUIVALENCIA]` `[HARDCODE-SOSPECHOSO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — estructura interna de interfaz; impacto en reportes CNBV si el campo CVETRAN migra de 4 a 6 dígitos |
| **Programa ejecutor** | `S500_INC_WOR_CAN.txt` (líneas 4312–4543 para Format1; 4546–4629+ para Format2) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
Formato 1 (S151REGISTRA1) — campos de CVETRAN de 4 dígitos:
  03 WS-S151-0101-IMPTE1
     05 WS-S151-0101-CVETRAN1   PIC 9(04) COMP      ← 4 dígitos
     05 WS-S151-0101-INDLEY1    PIC 9(02) COMP
     05 WS-S151-0101-ESQCON1    PIC 9(04) COMP
     05 WS-S151-0101-IMPORTE1   PIC 9(14)V99 COMP

Formato 2 (S151REGISTRA2) — campos de CVETRAN de 6 dígitos + CVEDESVIO adicionales:
  03 WS-S151-0101-IMPTE1
     05 WS-S151-0101-CVETRAN1   PIC 9(06) COMP      ← 6 dígitos (amplía catálogo de conceptos)
     05 WS-S151-0101-INDLEY1    PIC 9(02) COMP
     05 WS-S151-0101-ESQCON1    PIC 9(04) COMP
     05 WS-S151-0101-IMPORTE1   PIC 9(16)V99 COMP   ← 16 dígitos (mayor precisión)
     05 WS-S151-0101-CVEDESVIO1 PIC 9(04) COMP      ← campo nuevo en Format2
     05 WS-S151-0101-GUIDESVIO1 PIC 9(04) COMP      ← campo nuevo en Format2
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `CVETRAN` | CAMPO-CLAVE | Clave de transacción contable S151 (4 dígitos en Format1, 6 en Format2) |
| `ESQCON` | CAMPO-CLAVE | Esquema contable (plan de cuentas S151 aplicable) |
| `INDLEY` | CAMPO-CLAVE | Indicador de ley (para partidas fiscales: ISR, IVA) |
| `CVEDESVIO` | CAMPO-NUEVO | Clave de desvío contable (solo Format2 — ampliación regulatoria) |
| `GUIDESVIO` | CAMPO-NUEVO | Guía de desvío contable (solo Format2) |

**Excepciones documentadas:**
- Los programas que usan Format1 no pueden enviar CVETRANs > 9999 a S151. Si S151 amplía el catálogo de conceptos a 6 dígitos, todos los programas Format1 requieren recompilación.
- El campo IMPORTE pasa de 9(14)V99 a 9(16)V99 en Format2 — diferencia en capacidad de desbordamiento para importes muy grandes.
- RIESGO-EQUIVALENCIA critico: cualquier migración de S500 al target debe determinar cuál formato usa cada programa y replicarlo exactamente.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-156 — Acumulación de hasta 5 CVETRANs por mensaje antes de enviar a S151

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-156 |
| **Nombre** | Acumulación de hasta 5 CVETRANs por mensaje antes de enviar a S151 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[LÓGICA-CONTABLE]` `[RIESGO-EQUIVALENCIA]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — optimización de rendimiento; pero el grouping define qué movimientos forman un asiento atómico |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-IMP` (líneas 4152–4253) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
20000151-CARGAMOV1:
  PERFORM 20000151-CARGAMOV1-CTES        -- copia constantes (SISTEMA=500, fechas, cuenta, etc.)
  MOVE WS-S151-SALDO-INI TO WS-S151-SALDO-FIN
  PERFORM 20000151-CARGAMOV1-IMP
    VARYING WS-S151-IND FROM 1 BY 1
    UNTIL WS-S151-IND > 30 OR WS-S151-SW = 1

20000151-CARGAMOV1-IMP (por cada entrada WS-S151-IND):
  IF CVETRAN-I(IND) = 0:
    WS-S151-SW = 1   -- fin de lista de entrada, salir del loop

  IF slot CVETRAN1 libre (= 0):
    llenar CVETRAN1/IMPORTE1/INDLEY1/ESQCON1/LEYENDA1
  ELSE IF CVETRAN2 libre:
    llenar CVETRAN2...
  ELSE IF CVETRAN3 libre:
    llenar CVETRAN3...
  ELSE IF CVETRAN4 libre:
    llenar CVETRAN4...
  ELSE IF CVETRAN5 libre:
    llenar CVETRAN5...
  ELSE:
    -- overflow: los 5 slots están llenos, enviar inmediatamente
    PERFORM 20000151-CARGAMOV1-CALL   -- envía el mensaje actual
    PERFORM 20000151-CARGAMOV1-SUBCVE -- limpia los 5 slots de CVETRANs
    -- luego llenar CVETRAN1 con la entrada actual que no cupo
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-IND` | ÍNDICE | Índice del loop de acumulación (PIC 9(02)) |
| `WS-S151-SW` | FLAG | Switch de fin de lista (1 = salir) |
| `WS-S151-SALDO-INI` | CAMPO-CONTABLE | Saldo inicial del período para el mensaje S151 |
| `WS-S151-SALDO-FIN` | CAMPO-CONTABLE | Saldo final (se actualiza en LIMPIA; se pasa como SALDO-INI al siguiente ciclo) |

**Excepciones documentadas:**
- El loop admite hasta 30 entradas por invocación, pero el mensaje S151 solo tiene 5 slots: un movimiento con más de 5 conceptos genera automáticamente múltiples llamadas a CARGAMOV1.
- El orden de llenado de slots (1→2→3→4→5) determina qué CVETRAN queda como "clave principal" del asiento (CVETRAN1 es el primer registrado, que S151 toma como referencia del asiento).

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-157 — Auto-flush al overflow de 5 slots: segunda llamada encadenada

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-157 |
| **Nombre** | Auto-flush al overflow de 5 slots: segunda llamada encadenada |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[RIESGO-EQUIVALENCIA]` `[LÓGICA-CONTABLE]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB — la atomicidad de asientos en GL es auditada; un flush parcial produce 2 asientos S151 por 1 movimiento S500 |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-IMP` rama ELSE final (líneas 4237–4252) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- overflow: todos los 5 slots llenos y todavía hay más CVETRANs de entrada
PERFORM 20000151-CARGAMOV1-CALL         -- envía mensaje parcial (CVETRANs 1-5)
PERFORM 20000151-CARGAMOV1-SUBCVE       -- limpia slots de CVETRANs, conserva constantes
MOVE WS-S151-SALDO-INI TO WS-S151-0101-SALDO-INI
ADD 1 TO W77-NUM-MOVS-ENV W77-TOT-MOVS-ENV

-- importante: el nuevo mensaje lleva la referencia del asiento anterior
MOVE WS-S151-0101-REFS151 TO WS-S151-0101-REFS151-ANT  -- encadena el asiento nuevo al previo

-- llenar CVETRAN1 con la entrada que no cupo en el mensaje anterior
MOVE CVETRAN-I(IND) TO CVETRAN1
MOVE IMPORTE-I(IND) TO IMPORTE1
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-0101-REFS151` | CAMPO-CLAVE | Referencia del asiento S151 recién enviado (asignada por S151 en el CALL) |
| `WS-S151-0101-REFS151-ANT` | CAMPO-CLAVE | Referencia del asiento S151 anterior — encadena continuaciones |

**Excepciones documentadas:**
- En el sistema target modernizado, un asiento S500 con > 5 CVETRANs genera 2 asientos en el GL target, enlazados por REFS151-ANT. Si el target no implementa este mecanismo de encadenamiento, los asientos quedan "huérfanos" — error de reconciliación contable auditable.
- El encadenamiento es la única señal que S151 tiene de que dos mensajes pertenecen al mismo movimiento de negocio.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-158 — Modo contingencia S151: encolado en archivo cuando S151 no responde

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-158 |
| **Nombre** | Modo contingencia S151: encolado en archivo cuando S151 no responde |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` `[RIESGO-EQUIVALENCIA]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB — continuidad operativa; los movimientos en contingencia deben reprocesarse antes del cierre contable |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CALL` (líneas 3832–3852) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- Solo aplica para modo LINEA (transaccional online):
IF WS-88-SIUSA-S151 AND WS-88-BASE-ORI OR
   (WS-88-ENVIAS151-TRANCTRL AND NOT WS-88-PREBATCH):
  IF NOT WS-88-EN-CONTINGENCIA-S151:
    PERFORM 20000151-CARGAMOV1-INIL030  -- pre-call hook
    CALL "CARGAMOV1 IN REGISTRAS500"
         USING WS-S151-0101-MOVIMIENTOS
         GIVING WS-S151-0101-STATUS
    PERFORM 20000151-CARGAMOV1-FINL030  -- post-call hook

IF WS-88-EN-CONTINGENCIA-S151:
  PERFORM 00000000-GRABA-CONTING-S151   -- encola en archivo de contingencia (no llama S151)

-- Post-call (independiente de contingencia):
IF WS-S151-0101-STATUS > 0:
  PERFORM 00000000-GRABA-RECHAZOS-S151  -- registra el rechazo de S151
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-88-EN-CONTINGENCIA-S151` | FLAG-88 | TRUE = S151 no disponible; modo contingencia activo |
| `WS-88-SIUSA-S151` | FLAG-88 | TRUE = este proceso debe enviar a S151 (configuración) |
| `WS-88-BASE-ORI` | FLAG-88 | TRUE = la base de datos es la original (no réplica) |
| `GRABA-CONTING-S151` | PROCEDIMIENTO | Graba el mensaje en archivo de contingencia para reproceso |
| `GRABA-RECHAZOS-S151` | PROCEDIMIENTO | Registra el rechazo de S151 para auditoría y reproceso |

**Excepciones documentadas:**
- El modo contingencia solo existe en la ruta LINEA (online). El batch no tiene contingencia S151 documentada en este include.
- Los movimientos encolados en contingencia deben reprocesarse antes del cierre contable del día. No existe en el código un mecanismo de expiración automático de la cola de contingencia — es un proceso operativo manual.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-159 — Manejo de rechazos STATUS > 0 de S151

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-159 |
| **Nombre** | Manejo de rechazos STATUS > 0 de S151 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` `[LÓGICA-CONTABLE]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB — un movimiento rechazado por S151 no tiene asiento en el GL; es un gap contable auditable |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — post-CALL (líneas 3857–3891) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
IF WS-S151-0101-STATUS > 0:
  PERFORM 00000000-GRABA-RECHAZOS-S151   -- graba en log de rechazos

-- Adicionalmente en modo BATCHP130 (cierre mensual de captación):
IF WS-S151-0101-STATUS > 0:
  -- escribe mensaje de error al archivo R06 con los 5 CVETRANs e importes:
  para cada i in (1..5):
    MOVE CVETRANi TO WS-0102-CVE-MSG
    MOVE IMPORTEi TO WS-0102-IMP-MSG
    PERFORM 60613000-ESC-MENSAJES        -- escribe línea en R06
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-0101-STATUS` | CAMPO-RESULTADO | Código de resultado de CARGAMOV1 (0 = OK; > 0 = error) |
| `GRABA-RECHAZOS-S151` | PROCEDIMIENTO | Graba el rechazo completo (estructura + status) en log de rechazos |
| `60613000-ESC-MENSAJES` | PROCEDIMIENTO | Escribe mensaje al archivo de reporte R06 (batch P130) |
| `WS-0102-MENSAJE` | BUFFER | Estructura del mensaje de error para R06 |

**Excepciones documentadas:**
- Un rechazo de S151 no revierte la operación en S500 automáticamente. El movimiento de captación queda aplicado pero sin contrapartida en el GL — brecha contable. El reproceso es manual.
- En modo LINEA, el rechazo solo se graba en el log de rechazos; en modo BATCHP130 también se escribe al R06 para el reporte de cierre mensual.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-160 — IND-EDOCTA: instrumento 6 de producto 500 excluye estado de cuenta en S151

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-160 |
| **Nombre** | IND-EDOCTA: instrumento 6 de producto 500 excluye estado de cuenta en S151 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` `[REGLA-BANCARIA-MX]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CONDUSEF — el estado de cuenta es obligatorio para cuentas de captación; esta excepción debe estar documentada |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CTES` (líneas 3288–3292) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- Comentario en el código (líneas 3281-3287):
-- "El S151 envia movimientos al S050 y a Bancanet solo si
--  tiene un 1 en WS-S151-0101-IND-EDOCTA o si el catálogo 8
--  indica que va al estado de cuenta. El S050 ya no puede
--  manejar movimientos de ahorros."

IF WS-S151-0101-PRODUCT-I = 500 AND WS-S151-0101-INSTRUMENTO-I = 6:
  MOVE 0 TO WS-S151-0101-IND-EDOCTA   -- excluye del estado de cuenta
ELSE:
  MOVE 1 TO WS-S151-0101-IND-EDOCTA   -- incluye en estado de cuenta
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-0101-IND-EDOCTA` | CAMPO-INDICADOR | 1 = enviar a estado de cuenta; 0 = no enviar |
| `INSTRUMENTO 6` | HARDCODE | Código de instrumento 6 (tipo de cuenta no especificado en el fuente — requiere catálogo B17) |
| `PRODUCTO 500` | HARDCODE | Código de sistema/producto 500 (S500 = cargos y abonos cheques) |

**Excepciones documentadas:**
- El instrumento 6 del producto 500 es la única excepción hardcoded. Todos los demás instrumentos reciben IND-EDOCTA=1 por default.
- Si S151 introduce un nuevo instrumento que también debe excluirse, esta regla requiere modificación del fuente.
- RIESGO-CNBV: si esta excepción es incorrecta, clientes con instrumento 6 no verían sus movimientos en el estado de cuenta — violación CONDUSEF.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-161 — IND-DATOS-ADIC siempre = 1 (hardcode de optimización de performance)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-161 |
| **Nombre** | IND-DATOS-ADIC siempre = 1 (hardcode de optimización de performance) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — Control interno de performance |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CTES` (línea 3300) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- Comentario en el código (líneas 3296-3300):
-- "060502 - JRS - Se le mueve 1 al indicador de datos adicionales
--  ya que el S151 se basara en este campo para ver si vienen
--  informacion adicional. Esto ayuda a mejorar el performance del S151."

MOVE 1 TO WS-S151-0101-IND-DATOS-ADIC   -- siempre = 1 (ignora el input -I)
-- NOTA: la línea anterior en el fuente (comentada) era:
-- MOVE WS-S151-0101-IND-DATOS-ADIC-I TO WS-S151-0101-IND-DATOS-ADIC
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-0101-IND-DATOS-ADIC` | CAMPO-INDICADOR | Indica a S151 si el mensaje lleva datos adicionales (LEYENDAS, referencias extendidas) |

**Excepciones documentadas:**
- El campo se fuerza a 1 incluso cuando no hay datos adicionales reales. Esto hace que S151 siempre procese el bloque de datos adicionales, con impacto de performance en S151.
- El original parametrizado (comentado) fue reemplazado por razones de performance de S151 en 2006. La lógica inversa: el hardcode genera trabajo extra en S151 (lo contrario al objetivo). Esta inconsistencia es un candidato a revisión.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-162 — SUCPROM override para CVETRANs 4159/4160 → sucursal 342

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-162 |
| **Nombre** | SUCPROM override para CVETRANs 4159/4160 → sucursal 342 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` `[REGLA-BANCARIA-MX]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV — la sucursal promotora determina el libro contable de captación en el GL |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CTES` (líneas 3388–3389) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- Solo aplica para modo LINEA:
IF WS-S151-0101-CVETRAN-I(1) = 4159 OR 4160:
  MOVE 342 TO WS-S151-0101-SUCPROM   -- override de sucursal promotora

-- Comentario en el código: "CON ESTAS CLAVES SE DEBE DE AFECTAR A RESULTADOS
-- DE LA SUCURSAL 350 EN LUGAR DE LA PROMOTORA DE LA CUENTA. ESTAS CLAVES
-- SERAN CARGADAS EN B17 PARA QUE SOLO LAS PUEDA TRANSMITIR LA SUCURSAL 350"
-- NOTA: el comentario dice "350" pero el código mueve "342" → discrepancia a validar con negocio
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-0101-SUCPROM` | CAMPO-CLAVE | Sucursal promotora de la cuenta para el asiento S151 |
| `CVETRAN 4159/4160` | HARDCODE | Claves de transacción que fuerzan imputación a sucursal 342 |
| `342` | HARDCODE | Código de sucursal hardcoded (sucursal especial para comisiones o cargos corporativos) |

**Excepciones documentadas:**
- DISCREPANCIA: el comentario en el código menciona "sucursal 350" pero el valor hardcoded es "342". Requiere validación con operaciones o configuración de B17. Esta discrepancia es un riesgo de migración.
- Solo aplica en modo LINEA; en batch el SUCPROM proviene de la cuenta en la base de datos.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]` `[AMBIGUO-SME]` (discrepancia 342 vs 350)

---

### RN-S500-163 — SUCPROM/SUCTRAN override CVETRAN 4449/ACNOMINAPORTA → sucursal 859 + cajero 40

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-163 |
| **Nombre** | SUCPROM/SUCTRAN override CVETRAN 4449/ACNOMINAPORTA → sucursal 859 + cajero 40 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` `[REGLA-BANCARIA-MX]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV — SPEI (Sistema de Pagos Electrónicos Interbancarios) tiene requerimientos de registro por punto de entrada |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CTES` (líneas 3399–3408) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- Solo aplica para modo LINEA:
IF WS-S151-0101-CVETRAN-I(1) = 4449 OR WS-CVE-ACNOMINAPORTA-PG:
  MOVE 859 TO WS-S151-0101-SUCPROM
              WS-S151-0101-SUCTRAN
              WS-S151-0101-SUCS028
  MOVE 40  TO WS-S151-0101-CAJOPER
              WS-S151-0101-CAJTRAN
              WS-S151-0101-CAJS028
-- Comentario: "CUT SPEI (01/SEP/2018) PCB"
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `CVETRAN 4449` | HARDCODE | Clave de transacción SPEI (pago interbancario electrónico) |
| `WS-CVE-ACNOMINAPORTA-PG` | CAMPO-DINÁMICO | Clave configurada dinámicamente para nómina portable SPEI |
| `859` | HARDCODE | Código de sucursal SPEI/interbancaria (punto de acceso SPEI de Banamex) |
| `40` | HARDCODE | Código de cajero/terminal para operaciones SPEI |

**Excepciones documentadas:**
- El override afecta SUCPROM, SUCTRAN, SUCS028, CAJOPER, CAJTRAN y CAJS028 en un solo bloque — 6 campos hardcodeados simultáneamente.
- En el target modernizado, estos 6 valores deben ser parametrizables en catálogo de operaciones SPEI, no hardcoded.
- WS-CVE-ACNOMINAPORTA-PG es un campo dinámico (no hardcode puro) que carga su valor en runtime desde configuración.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-164 — SUCPROM override CVETRANs 2136/2137/2138 → SUCTRAN de la operación

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-164 |
| **Nombre** | SUCPROM override CVETRANs 2136/2137/2138 → SUCTRAN de la operación |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` `[REGLA-BANCARIA-MX]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV — asignación de P&L por sucursal operadora vs. promotora |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CTES` (líneas 3395–3396) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
IF WS-S151-0101-CVETRAN-I(1) = 2136 OR 2137 OR 2138:
  MOVE WS-S151-0101-SUCTRAN-I TO WS-S151-0101-SUCPROM
  -- imputar los resultados a la sucursal que operó, no a la promotora de la cuenta
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `CVETRAN 2136/2137/2138` | HARDCODE | Claves de transacción especiales (naturaleza exacta requiere catálogo B17) |
| `WS-S151-0101-SUCTRAN` | CAMPO-CLAVE | Sucursal que realizó la transacción (operadora) |
| `WS-S151-0101-SUCPROM` | CAMPO-CLAVE | Sucursal promotora de la cuenta (receptora de P&L normalmente) |

**Excepciones documentadas:**
- Este es el único caso donde SUCPROM = SUCTRAN (override dinámico, no hardcode numérico).
- El significado de negocios de los CVETRANs 2136/2137/2138 no está documentado en el fuente; requiere consulta del catálogo B17 de Banamex.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-165 — SUCS028/CAJS028 hardcode por perfil PIM (CVETRANs 3002/4001/3018/4016)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-165 |
| **Nombre** | SUCS028/CAJS028 hardcode por perfil PIM (CVETRANs 3002/4001/3018/4016) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` `[REGLA-BANCARIA-MX]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV — la sucursal del asiento S028 determina el registro de movimiento en el libro de captación especial |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CTES` (líneas 3413–3444) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
IF CVETRAN-I(1) = 3002 OR 4001 OR 3018 OR 4016:
  IF perfil PIM (WS03-88-PIM-CTAMAE OR WS03-88-PIM-CTAMAEOP OR WS03-88-PIM-CTAMAEDL
                 OR WS03-88-PIM-CTAPERDLS OR WS03-88-PIM-CITI-ONEPREMIUM OR ...
                 OR WS03-88-PIM-PREPAGADA):
    MOVE 94 TO WS-S151-0101-CAJS028
    IF NODORI = 10:
      MOVE 907 TO WS-S151-0101-SUCS028
    ELSE:
      MOVE 904 TO WS-S151-0101-SUCS028
  ELSE:  -- cuenta no PIM
    MOVE 79 TO WS-S151-0101-CAJS028
    IF NODORI = 10:
      MOVE 907 TO WS-S151-0101-SUCS028
    ELSE:
      MOVE 904 TO WS-S151-0101-SUCS028
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS03-88-PIM-*` | FLAGS-88 | Perfil de cliente PIM (Priority Banking México) — múltiples tipos: CtaMae, CitiOnePremium, Prepagada, etc. |
| `CVETRAN 3002/4001/3018/4016` | HARDCODE | CVETRANs de abono/cargo especial para cuentas PIM (tipo "traspaso") |
| `CAJS028 94 / 79` | HARDCODE | Cajero virtual PIM (94) vs. cajero estándar (79) para asiento S028 |
| `SUCS028 907 / 904` | HARDCODE | Sucursal S028 según nodo de origen: 10=nodo especial→907, otros→904 |
| `NODORI` | CAMPO-CLAVE | Nodo de origen de la operación (nodo 10 = operaciones de ciertos canales especiales) |

**Excepciones documentadas:**
- La lista de perfiles PIM en las condiciones 88 es extensa (~10 perfiles). Cualquier nuevo perfil PIM requiere agregar un nuevo 88 en el include y recompilación.
- SUCS028 depende de NODORI=10 independientemente del perfil PIM — la misma lógica de nodo aplica a PIM y no-PIM.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-166 — SUCS028 hardcode para CVETRAN 3027 (cajero 55, sucursal nodo-dependiente)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-166 |
| **Nombre** | SUCS028 hardcode para CVETRAN 3027 (cajero 55, sucursal nodo-dependiente) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — regla de routing interno del libro S028 |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CTES` (líneas 3446–3451) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
IF WS-S151-0101-CVETRAN-I(1) = 3027:
  MOVE 55 TO WS-S151-0101-CAJS028
  IF WS-S151-0101-NODORI = 10:
    MOVE 907 TO WS-S151-0101-SUCS028
  ELSE:
    MOVE 904 TO WS-S151-0101-SUCS028
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `CVETRAN 3027` | HARDCODE | Clave de transacción 3027 (naturaleza exacta en catálogo B17) |
| `55` | HARDCODE | Código de cajero virtual específico para CVETRAN 3027 |

**Excepciones documentadas:**
- El patrón NODORI=10 → 907 / resto → 904 es idéntico al de la regla RN-S500-165. Sugiere una lógica de sucursal S028 centralizada que podría refactorizarse en el target.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-167 — SUCS028 hardcode para CVETRANs 3047 y 1153 (cajeros especiales)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-167 |
| **Nombre** | SUCS028 hardcode para CVETRANs 3047 y 1153 (cajeros especiales) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — routing S028 interno |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CTES` (líneas 3453–3467) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- CVETRAN 3047 (REQ3):
IF WS-S151-0101-CVETRAN-I(1) = 3047:
  MOVE 92  TO WS-S151-0101-CAJS028
  MOVE 342 TO WS-S151-0101-SUCS028

-- CVETRAN 1153 con BIN específico (Evolución):
IF WS-S151-0101-CVETRAN-I(1) = 1153:
  IF WS-GEN-MDA-BIN = 554492:
    MOVE 60   TO WS-S151-0101-CAJS028
    MOVE 7532 TO WS-S151-0101-SUCS028
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `CVETRAN 3047` | HARDCODE | Clave transacción REQ3 (proyecto P07-120) |
| `CVETRAN 1153` | HARDCODE | Clave transacción Evolución (proyecto P07-410) |
| `BIN 554492` | HARDCODE | BIN de tarjeta específico del producto Evolución |
| `7532` | HARDCODE | Sucursal S028 del producto Evolución |

**Excepciones documentadas:**
- La condición del BIN 554492 hace que CVETRAN 1153 solo aplique el override para tarjetas Evolución con ese BIN específico. Otros BINs con CVETRAN 1153 no aplican este override.
- CVETRAN 2534 también tiene un override (SUCS028=511) documentado en línea 3465–3466, sin condición de perfil adicional.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-168 — MONEDA=1 para operaciones en pesos (hardcode por CVETRAN)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-168 |
| **Nombre** | MONEDA=1 para operaciones en pesos (hardcode por CVETRAN) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-BANCARIA-MX]` `[HARDCODE-SOSPECHOSO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB — la moneda del asiento GL debe corresponder a la moneda de la operación |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CTES` (líneas 3481–3495) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- Forzar MONEDA=1 (pesos MXN) para CVETRANs conocidos de operaciones en pesos:
IF WS-S151-0101-CVETRAN-I(1) = WS-CVE-DDISPNOEFECMN OR
                                WS-CVE-RNEGAFILMN    OR
                                WS-CVE-RDISPEFECAJMN OR
                                WS-CVE-RDISPEFEREDMN OR
                                13 OR 14:
  MOVE 1 TO WS-S151-0101-MONEDA

-- Perfiles dólares (BSR): adicional para cuentas CTAPERDLS:
IF WS03-88-PIM-CTAPERDLS AND
   WS17-MN-CLAVE-TRANS = WS-S151-0101-CVETRAN-I(1) AND
   (WS17-MN-CLAVE-TRX-DLS > 0 OR CVETRAN = 13 OR CVETRAN = 14):
  MOVE 1 TO WS-S151-0101-MONEDA    -- también pesos para este caso
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-0101-MONEDA` | CAMPO-CLAVE | Código de moneda del asiento S151 (1=MXN, 2=USD, etc.) |
| `CVETRAN 13/14` | HARDCODE | Claves de transacciones en pesos forzadas (natureza en catálogo B17) |
| `WS-CVE-DDISPNOEFECMN` | CAMPO-DINÁMICO | Clave disposición no efectivo MN (cargada en runtime) |

**Excepciones documentadas:**
- Los CVETRANs 13 y 14 son los únicos hardcoded literalmente; el resto se acceden a través de campos WS-CVE-* que se cargan desde configuración en runtime.
- El código de moneda 1=MXN es un hardcode implícito; si Banamex amplia el catálogo de monedas, este valor debe revisarse.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-169 — SGIRO: indicador de sobregiro con distinción línea vigente vs. vencida

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-169 |
| **Nombre** | SGIRO: indicador de sobregiro con distinción línea vigente vs. vencida |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[LÓGICA-CONTABLE]` `[REGLA-BANCARIA-MX]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB — el sobregiro en líneas de crédito vigentes vs. vencidas tiene tratamiento contable diferente (provisiones IFRS 9) |
| **Programa ejecutor** | `S500_INC_WOR_CAN.txt` — comentario del contrato CARGAMOV1 (línea ~406700) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- Valores documentados en el comentario del contrato CARGAMOV1:
WS-S151-0101-SGIRO-I:
  0 = no genera sobregiro
  1 = genera sobregiro en línea VIGENTE (TIPO-PROC=1, líneas con números 1)
  2 = genera sobregiro en línea VENCIDA (TIPO-PROC=10, líneas con números 10/20)

-- TIPO-PROC complementa el SGIRO:
WS-S151-0101-TIPO-PROC-I:
  1   = operación en línea activa
  10  = operación batch mensual
  20  = operación mensual alternativa
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-0101-SGIRO` | CAMPO-INDICADOR | Indicador de tipo de sobregiro (0=no/1=vigente/2=vencida) |
| `WS-S151-0101-TIPO-PROC` | CAMPO-INDICADOR | Tipo de proceso (1=línea/20=mensual/30=mensual-alt) |

**Excepciones documentadas:**
- SGIRO solo aplica en cargos que afectan líneas de crédito asociadas a cuentas de captación. No aplica a cuentas sin línea de crédito.
- La distinción vigente/vencida (SGIRO=1 vs 2) tiene impacto en las provisiones IFRS 9 en el GL — riesgo regulatorio si se pierde en la migración.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-170 — ORIGEN: clasificación de operaciones local / foráneo enviado / foráneo recibido

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-170 |
| **Nombre** | ORIGEN: clasificación de operaciones local / foráneo enviado / foráneo recibido |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[LÓGICA-CONTABLE]` `[REGLA-BANCARIA-MX]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB — operaciones foráneas tienen tratamiento contable diferente (comisiones interbancarias, conciliación) |
| **Programa ejecutor** | `S500_INC_WOR_CAN.txt` — campos 88 de ORIGEN (líneas ~4397–4400) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
WS-S151-0101-ORIGEN (PIC 9(02) COMP):
  88 WS-S151-0101-LOCAL   VALUE 1   -- operación local (misma sucursal/red Banamex)
  88 WS-S151-0101-FORENV  VALUE 2   -- foráneo enviado (Banamex envía a otro banco)
  88 WS-S151-0101-FORREC  VALUE 3   -- foráneo recibido (Banamex recibe de otro banco)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WS-S151-0101-ORIGEN` | CAMPO-CLAVE | Clasificación de origen de la operación para S151 |

**Excepciones documentadas:**
- ORIGEN es el campo que diferencia operaciones interbancarias en el GL. Si se pierde en la migración, los movimientos foráneos quedan registrados como locales — error de conciliación con el sistema de compensación (CECOBAN, SPEI, SWIFT).

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-171 — Propagación de leyenda para corresponsales (CVETRANs 1119/1120/2200)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-171 |
| **Nombre** | Propagación de leyenda para corresponsales (CVETRANs 1119/1120/2200) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-BANCARIA-MX]` |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CONDUSEF — las leyendas en el estado de cuenta deben reflejar la naturaleza real de la operación |
| **Programa ejecutor** | `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-IMP` / `20000151-CLAVES-CORRESP` (líneas 4260–4267) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- "Este cambio se hizo para atender una petición de corresponsales,
--  en el que en las claves adicionales tienen la misma leyenda que la clave original."

20000151-CLAVES-CORRESP:
  IF CVETRAN-I(1) = 1119 OR 1120 OR 2200:
    IF CVETRAN-I(IND) = 1121 OR 2200 OR 2201:
      MOVE INDLEY-I(1)   TO INDLEY-I(IND)
      MOVE LEYENDA-I(1)  TO LEYENDA-I(IND)
      -- la clave adicional hereda la leyenda de la clave principal
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `CVETRAN 1119/1120/2200` | HARDCODE | CVETRANs de corresponsales bancarios que requieren leyenda unificada |
| `CVETRAN 1121/2201` | HARDCODE | CVETRANs adicionales de corresponsal que heredan la leyenda de la principal |
| `LEYENDA-I` | CAMPO-TEXTO | Texto descriptivo de 40 chars que aparece en el estado de cuenta |
| `INDLEY-I` | CAMPO-INDICADOR | Índice de leyenda (referencia al catálogo de leyendas de S151) |

**Excepciones documentadas:**
- La propagación de leyenda solo aplica para la combinación específica de CVETRANs listados. Nuevos tipos de corresponsal requieren agregar nuevas condiciones.
- Confianza MEDIA porque no se ha verificado si hay otros CVETRANs de corresponsal que deberían incluirse pero no están.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-172 — Contadores de monitoreo de llamadas S151

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-172 |
| **Nombre** | Contadores de monitoreo de llamadas S151 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | Consulta SME Mainframe Migration |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — monitoreo interno operativo |
| **Programa ejecutor** | `S500_INC_WOR_CAN.txt` (líneas 4242–4248) + `S500_INC_PRO_CAN.txt` — `20000151-CARGAMOV1-CALL` (línea 3810) + `20000151-CARGAMOV1-IMP` (líneas 4174–4241) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
Contadores declarados (Working Storage):
  77 WKS-88-REGISTRAS500  PIC 99     COMP VALUE 0  -- librería inicializada (1=sí)
  77 W77-NUM-MOVS-GEN     PIC 9(02)  COMP VALUE 0  -- movimientos generados en la sesión
  77 W77-NUM-MOVS-ENV     PIC 9(02)  COMP VALUE 0  -- movimientos enviados a S151 (por llamada actual)
  77 W77-TOT-MOVS-GEN     PIC 9(08)  COMP VALUE 0  -- total movimientos generados (acumulado)
  77 W77-TOT-MOVS-ENV     PIC 9(08)  COMP VALUE 0  -- total movimientos enviados (acumulado)
  77 W77-NUM-CALL-S151    PIC 9(06)  COMP VALUE 0  -- número de llamadas a CARGAMOV1

Incremento en CARGAMOV1-CALL:
  ADD 1 TO W77-NUM-CALL-S151

Incremento en CARGAMOV1-IMP (por cada CVETRAN procesado):
  ADD 1 TO W77-NUM-MOVS-ENV W77-TOT-MOVS-ENV
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `W77-NUM-CALL-S151` | CONTADOR | Número de llamadas a CARGAMOV1 en el proceso actual |
| `W77-TOT-MOVS-ENV` | CONTADOR | Total de CVETRANs enviados a S151 (acumulado global del proceso) |
| `W77-NUM-MOVS-ENV` | CONTADOR | CVETRANs enviados en la llamada actual (se resetea en LIMPIA) |

**Excepciones documentadas:**
- W77-NUM-MOVS-ENV (PIC 9(02)) se desborda si un solo movimiento genera más de 99 CVETRANs — prácticamente imposible dado el límite de 30 entradas y 5 salidas por mensaje.
- W77-TOT-MOVS-ENV (PIC 9(08)) permite hasta 99,999,999 CVETRANs totales — suficiente para operaciones batch masivas.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

## BLOQUE 2 — P103 FRAUDLINK (RN-S500-173 a RN-S500-182)

> Fuente primaria: `S500_SOURCE_P103.txt` (664 LOC).
> Programa: FRAUDLINK — extrae movimientos con clave fraude y genera archivo para S711.
> Autor: José Luis Ibarra Lara. Fecha: JUL/2005. Banco Nacional de México, S.N.C.

---

### RN-S500-173 — FRAUDLINK: objetivo y flujo general de P103

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-173 |
| **Nombre** | FRAUDLINK: objetivo y flujo general de P103 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-BANCARIA-MX]` `[CONTROL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV — detección y control de fraude es obligación regulatoria; el feed a S711 soporta el proceso de bloqueo |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — `00000000-MAIN-PARAGRAPH` (líneas 127500–128500) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
00000000-MAIN-PARAGRAPH:
  PERFORM 10000000-INICIO           -- inicializa IDs y versiones
  PERFORM 10000100-TIT-LIBS         -- valida versión de librerías
  PERFORM 20000100-ABRE-BASE        -- abre BD S500BD01CAPTACION + archivo de salida
  PERFORM 50001000-PROCESO          -- procesa todos los movimientos B07
    UNTIL W77-EOF-B07 = 1
  PERFORM 80000000-TERMINA          -- escribe trailer + cierra archivos

-- Llamadores del programa (documentados en el comentario inicial):
--   S500B07MOVDIA  (batch diario de movimientos)
--   S500B13MOVCVES (batch de claves adicionales de movimientos)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `FRAUDLINK` | NOMBRE-PROGRAMA | Nombre funcional de P103 (nombre del archivo de salida) |
| `S500BD01CAPTACION` | BASE-DATOS | Base de datos DMSII de captación S500 |
| `S711` | SISTEMA-DOWNSTREAM | Sistema de fraude receptor del archivo FRAUDLINK |
| `S500B07MOVDIA` | SET-DATOS | Dataset de movimientos del día (fuente principal) |
| `S500B13MOVCVES` | SET-DATOS | Dataset de claves adicionales de movimientos (fuente secundaria) |

**Excepciones documentadas:**
- P103 NO bloquea transacciones directamente. Solo genera el archivo que S711 utiliza para ejecutar el bloqueo. La cadena es: S500 procesa → P103 extrae → S711 bloquea.
- Si P103 no se ejecuta un día, S711 no recibe el feed de fraude → riesgo de omisión de bloqueo.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-174 — Trío de claves de fraude hardcoded: 2001 / 2444 / 2496

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-174 |
| **Nombre** | Trío de claves de fraude hardcoded: 2001 / 2444 / 2496 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` `[REQUIERE-LEGAL]` `[REGLA-BANCARIA-MX]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV — las claves de fraude son parte del catálogo regulatorio de tipos de movimiento; cambios requieren aprobación |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — `50001100-MOV-ORIG` |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- En el movimiento principal (B07):
50001100-MOV-ORIG:
  IF B07-CLAVE-MOVTO = 2001 OR 2444 OR 2496:
    -- armar registro de salida con este movimiento
    PERFORM 50002000-ESC-ARCHIVO

-- En las claves adicionales B07 (hasta 5):
50001200-OPERO5-B07 (ejecutado 5 veces):
  IF B07-CVE-MOVAD(IND) = 2001 OR 2444 OR 2496:
    -- armar registro de salida con la clave adicional
    PERFORM 50002000-ESC-ARCHIVO

-- En las claves de B13 (hasta 10):
50001350-BUSCA-B13:
  IF B13-CLAVE-MOVTO(IND) = 2001 OR 2444 OR 2496:
    -- armar registro de salida con la clave B13
    PERFORM 50002000-ESC-ARCHIVO
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `B07-CLAVE-MOVTO` | CAMPO-CLAVE | Clave de movimiento principal en B07MOVDIA |
| `B07-CVE-MOVAD(n)` | CAMPO-CLAVE | Clave de movimiento adicional (hasta 5 en B07) |
| `B13-CLAVE-MOVTO(n)` | CAMPO-CLAVE | Clave de movimiento en B13MOVCVES (hasta 10 por movimiento) |
| `2001` | HARDCODE-FRAUDE | Clave de fraude 1: naturaleza exacta requiere catálogo B17 regulatorio |
| `2444` | HARDCODE-FRAUDE | Clave de fraude 2: naturaleza exacta requiere catálogo B17 regulatorio |
| `2496` | HARDCODE-FRAUDE | Clave de fraude 3: naturaleza exacta requiere catálogo B17 regulatorio |

**Excepciones documentadas:**
- Las tres claves están hardcoded en el fuente. Si el área de Seguridad/Fraude de Banamex agrega una nueva clave de fraude, P103 requiere modificación del fuente y recompilación.
- REQUIERE-LEGAL: el significado exacto de 2001/2444/2496 (tipo de fraude que representan) no está en el código. Debe obtenerse del catálogo B17 del área de operaciones de fraude de Banamex.
- La misma condición se repite en 3 lugares del código (MOV-ORIG, OPERO5-B07, BUSCA-B13) — si se agrega una nueva clave, debe actualizarse en los 3 lugares.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]` `[REQUIERE-LEGAL]`

---

### RN-S500-175 — Fuentes duales: B07MOVDIA (principal) y B13MOVCVES (adicional)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-175 |
| **Nombre** | Fuentes duales: B07MOVDIA (principal) y B13MOVCVES (adicional) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[LÓGICA-CONTABLE]` `[REGLA-DISTRIBUIDA]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV — la completitud del reporte de fraude requiere cubrir tanto el movimiento principal como sus conceptos adicionales |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — flujo `50001000-PROCESO` → `50001300-MOVS-B13` (líneas 139500–153700) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
50001000-PROCESO:
  -- Leer siguiente movimiento B07:
  PERFORM 90000007-B07MOVDIA-FINDN
  IF EOF: W77-EOF-B07 = 1 → salir

  IF B07-STATUS-MOVTO ≠ 1:  -- solo procesar movimientos aplicados
    MOVE B07-AUTORIZACION TO WKS-AUTORIZ-MOV

    -- (1) Evaluar la clave PRINCIPAL del movimiento B07:
    PERFORM 50001100-MOV-ORIG

    -- (2) Evaluar hasta 5 claves ADICIONALES en B07 mismo:
    PERFORM 50001200-OPERO5-B07 5 TIMES

    -- (3) Si el movimiento tiene subregistros en B13, evaluar hasta 10:
    IF B07-IND-MOVSADS > 0:
      PERFORM 50001300-MOVS-B13
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `B07-STATUS-MOVTO` | CAMPO-CONTROL | Status del movimiento en B07 (1=en proceso/pendiente; otro=aplicado) |
| `B07-IND-MOVSADS` | CAMPO-INDICADOR | Indicador de existencia de movimientos adicionales en B13 (>0 = hay B13) |
| `B07-AUTORIZACION` | CAMPO-CLAVE | Número de autorización del movimiento — llave para buscar en B13 |
| `B07-NUM-CONTRATO` | CAMPO-CLAVE | Número de contrato del movimiento — llave compuesta con autorización para B13 |

**Excepciones documentadas:**
- La búsqueda en B13 se activa solo si B07-IND-MOVSADS > 0. Si el flag está corrupto o desactualizado, P103 puede omitir claves adicionales de fraude en B13.
- B07 tiene hasta 5 claves adicionales internas (OPERO5-B07); B13 tiene hasta 10 registros adicionales externos (BUSCA-B13). Total por movimiento: 1 (principal) + 5 (B07) + 10 (B13) = 16 posibles registros de fraude.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-176 — Filtro de status B07: omite movimientos con STATUS-MOVTO = 1

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-176 |
| **Nombre** | Filtro de status B07: omite movimientos con STATUS-MOVTO = 1 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` `[REGLA-BANCARIA-MX]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — control interno de integridad de datos |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — `50001000-PROCESO` (líneas 142110–142300) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
50001000-PROCESO:
  IF B07-STATUS-MOVTO = 1:
    NEXT SENTENCE              -- omitir este movimiento (en proceso / no aplicado)
  ELSE:
    -- procesar el movimiento (evaluar claves de fraude)
    PERFORM 50001100-MOV-ORIG
    ...
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `B07-STATUS-MOVTO` | CAMPO-CONTROL | Status del movimiento: 1 = en proceso / pendiente de aplicación; 0 u otro = aplicado |

**Excepciones documentadas:**
- El valor "1" para status "en proceso" es un hardcode. Si la semántica del campo cambia o se añaden nuevos estados, esta condición puede generar falsos negativos (movimientos de fraude omitidos).
- No hay documentación en el código sobre qué significa exactamente STATUS=1 (¿reversión? ¿autorización pendiente? ¿limbo de error?). Requiere validación con el equipo de operaciones de S500.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]` `[AMBIGUO-SME]`

---

### RN-S500-177 — Escaneo de hasta 10 claves adicionales B13 por movimiento

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-177 |
| **Nombre** | Escaneo de hasta 10 claves adicionales B13 por movimiento |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[LÓGICA-CONTABLE]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — exhaustividad de cobertura de fraude |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — `50001300-MOVS-B13` + `50001350-BUSCA-B13` (líneas 149500–156300) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
50001300-MOVS-B13:
  MOVE B07-NUM-CONTRATO TO WS-NUM-CONTRATO
  MOVE B07-AUTORIZACION TO WS-AUTORIZACION
  PERFORM 90000013-B13SXCTOAUT-FIND    -- buscar primer B13 para este contrato/autorización
  IF STATUS = 1: W77-SIN-B13 = 1 → no hay B13

  IF W77-SIN-B13 = 0:
    MOVE ZERO TO W77-IND-B13
    PERFORM 50001350-BUSCA-B13 10 TIMES  -- escanear hasta 10 registros B13

50001350-BUSCA-B13:
  ADD 1 TO W77-IND-B13
  IF B13-CLAVE-MOVTO(IND) = 2001 OR 2444 OR 2496:
    armar registro de salida (banco=0002, suc-ope, med-acceso, fecha, clave, importe, refnum)
    PERFORM 50002000-ESC-ARCHIVO
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `W77-IND-B13` | ÍNDICE | Contador de registros B13 procesados (1..10) |
| `W77-SIN-B13` | FLAG | 1 = no hay registros B13 para este movimiento |
| `B13-CLAVE-MOVTO(n)` | CAMPO-CLAVE | Clave de movimiento en la posición n del arreglo B13 |
| `B13-IMPORTE(n)` | CAMPO-MONTO | Importe del movimiento adicional en posición n de B13 |
| `B13-REF-MOVAD(n)` | CAMPO-REFERENCIA | Referencia del movimiento adicional en posición n de B13 |

**Excepciones documentadas:**
- El límite de 10 es un hardcode. Si un movimiento tiene más de 10 registros B13 con claves de fraude, los registros 11+ son ignorados silenciosamente.
- La búsqueda en B13 usa la clave compuesta (NUM-CONTRATO + AUTORIZACION). Si B13 no tiene un índice eficiente por esta clave, puede ser costoso en volumen.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-178 — Estructura del registro de salida FRAUDLINK (60 caracteres fijos)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-178 |
| **Nombre** | Estructura del registro de salida FRAUDLINK (60 caracteres fijos) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[RIESGO-EQUIVALENCIA]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — contrato de interfaz con S711 |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — `WKS-REG-E03-CVES` (líneas 119100–120700) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
01 WKS-REG-E03-CVES (60 chars):
  02 WKS-REG-E03-TPO      PIC 9(01)       -- tipo de registro (2=detalle)
  02 WKS-REG-E03-BCO      PIC 9(04)       -- código de banco (siempre 0002)
  02 WKS-REG-E03-SUC-OPE  PIC 9(04)       -- sucursal operadora
  02 WKS-REG-E03-CHQRA    PIC 9(16)       -- número de cuenta/cheque/tarjeta (MED-ACCESO)
  02 WKS-REG-E03-CVE      PIC 9(04)       -- clave de movimiento (2001/2444/2496)
  02 WKS-REG-E03-FECHA    PIC 9(08)       -- fecha del movimiento (AAAAMMDD)
  02 WKS-REG-E03-IMPORTE  PIC 9(11)V99    -- importe (11 enteros + 2 decimales)
  02 WKS-REG-E03-REFNUM   PIC 9(10)       -- número de referencia

Bloque: 540 registros de 60 chars = 32,400 bytes por bloque
Areas: 1,000 bloques = 32,400,000 bytes máximo por archivo
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `E03-CVES2001` | ARCHIVO | Nombre del archivo de salida FRAUDLINK (CVES2001 = claves 2001) |
| `WKS-REG-E03-TPO` | CAMPO-CONTROL | Tipo de registro: 1=header, 2=detalle, 9=trailer |
| `WKS-REG-E03-CHQRA` | CAMPO-CLAVE | Número de cuenta/cheque/tarjeta del movimiento de fraude |
| `WKS-REG-E03-REFNUM` | CAMPO-REFERENCIA | Referencia numérica del movimiento (B07-REFER-NUME o B13-REF-MOVAD) |

**Excepciones documentadas:**
- El campo IMPORTE es PIC 9(11)V99 — máximo 99,999,999,999.99. Suficiente para captación retail pero podría desbordarse en operaciones corporativas muy grandes.
- RIESGO-EQUIVALENCIA crítico: el contrato de 60 caracteres con S711 es fijo. Cualquier cambio en el formato requiere coordinación con S711 (sistema de fraude).
- El nombre del archivo incluye "CVES2001" aunque el archivo contiene también las claves 2444 y 2496 — el nombre es histórico del nombre original de la función.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-179 — Ruta del archivo de salida S711: S500/FILE/S711/FRAUDLINK/{CSI}/{FECHA}

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-179 |
| **Nombre** | Ruta del archivo de salida S711: S500/FILE/S711/FRAUDLINK/{CSI}/{FECHA} |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — convenio de naming con S711 |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — `WKS-TIT-E03-CVES` (líneas 115500–116700) + `20000100-ABRE-BASE` (líneas 137800–138900) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
01 WKS-TIT-E03-CVES:
  02 FILLER           PIC X(25) VALUE "S500/FILE/S711/FRAUDLINK/"  -- path raíz hardcoded
  02 WKS-TIT-E03-CSI  PIC 9(02)                                   -- CSI (nodo) actual
  02 FILLER           PIC X(01) VALUE "/"
  02 WKS-TIT-E03-FECH PIC 9(08)                                   -- fecha del lote (AAAAMMDD)
  02 FILLER           PIC X(01) VALUE "."

-- Asignación en ABRE-BASE:
MOVE B02-NUM-CSI    TO WKS-TIT-E03-CSI    -- del registro de control B02
MOVE B02-FECHA-LOTE TO WKS-TIT-E03-FECH   -- fecha del lote del día

-- Resultado: "S500/FILE/S711/FRAUDLINK/nn/AAAAMMDD."
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `S500/FILE/S711/FRAUDLINK/` | HARDCODE-PATH | Directorio MCP de entrega a S711 (Unisys filesystem path) |
| `B02-NUM-CSI` | CAMPO-DINÁMICO | Número de CSI (nodo de control) leído de la base B02CONTROL |
| `B02-FECHA-LOTE` | CAMPO-DINÁMICO | Fecha del lote del día leída de la base B02CONTROL |

**Excepciones documentadas:**
- El path raíz `S500/FILE/S711/FRAUDLINK/` es un hardcode de 25 caracteres. En el sistema target modernizado, este path debe externalizarse como parámetro de configuración.
- El archivo incluye el CSI y la fecha en el nombre → no puede haber dos ejecuciones de P103 para el mismo CSI/fecha sin que la segunda sobreescriba a la primera (no hay versionado).

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-180 — Header (tipo "1") y trailer (tipo "9") del archivo S711

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-180 |
| **Nombre** | Header (tipo "1") y trailer (tipo "9") del archivo S711 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[RIESGO-EQUIVALENCIA]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — formato de intercambio con S711 |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — `WKS-E03-HEADER` + `WKS-E03-TRAILER` + `20000600-GEN-HEADER` + `20000700-GEN-TRAILER` (líneas 117100–139270) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
Header (tipo "1", 60 chars):
  02 FILLER       PIC X(01) VALUE "1"    -- tipo registro = header
  02 FILLER       PIC X(04) VALUE "S500" -- sistema origen
  02 FILLER       PIC X(04) VALUE "S711" -- sistema destino
  02 WKS-HEAD-CSI PIC 9(02)              -- CSI del día
  02 FILLER       PIC X(01) VALUE " "
  02 WKS-HEAD-FECH PIC 9(08)             -- fecha del lote
  02 FILLER       PIC X(40) VALUE " "    -- padding

Trailer (tipo "9", 60 chars):
  02 FILLER       PIC X(01) VALUE "9"    -- tipo registro = trailer
  02 WKS-NUM-REG  PIC 9(08) VALUE 0     -- conteo de registros de detalle
  02 WKS-IMP-TOT  PIC 9(12)V99 VALUE 0  -- suma de importes de todos los registros
  02 FILLER       PIC X(37) VALUE " "    -- padding

-- En 50002000-ESC-ARCHIVO (por cada registro de detalle):
  ADD 1                    TO WKS-NUM-REG
  ADD WKS-REG-E03-IMPORTE  TO WKS-IMP-TOT
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WKS-NUM-REG` | CONTADOR | Número de registros de detalle escritos en el archivo |
| `WKS-IMP-TOT` | ACUMULADOR | Suma total de importes de los registros de fraude (PIC 9(12)V99) |

**Excepciones documentadas:**
- El trailer incluye importe total (WKS-IMP-TOT) que S711 puede usar para validar integridad del archivo. Si hay discrepancia entre el total calculado y la suma real de registros, indica corrupción del archivo.
- WKS-NUM-REG es PIC 9(08) → máximo 99,999,999 registros. Suficiente para cualquier volumen de fraude diario esperado.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-181 — BANCO=0002 hardcoded en todos los registros de salida

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-181 |
| **Nombre** | BANCO=0002 hardcoded en todos los registros de salida |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[HARDCODE-SOSPECHOSO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV — el código de banco identifica la institución en el reporte de fraude |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — `50001100-MOV-ORIG` |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- En los 3 puntos donde se arma el registro de salida:
MOVE 0002 TO WKS-REG-E03-BCO     -- banco = 0002 (Banamex) hardcoded
-- misma instrucción en MOV-ORIG, OPERO5-B07 y BUSCA-B13
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `WKS-REG-E03-BCO` | CAMPO-BANCO | Código de banco en el registro de salida (PIC 9(04)) |
| `0002` | HARDCODE | Código CNBV de Banamex (Banco Nacional de México, S.N.C.) |

**Excepciones documentadas:**
- En el contexto de separación Citi-Banamex (2024+), el código de banco 0002 podría cambiar. Este hardcode en 3 lugares del código requeriría actualización sincronizada.
- Si S711 procesa archivos de múltiples bancos (escenario de grupo bancario), el hardcode 0002 imposibilita reutilizar P103 para otras entidades del grupo sin modificar el fuente.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-182 — Destino S711: feed para bloqueo operativo por fraude

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-182 |
| **Nombre** | Destino S711: feed para bloqueo operativo por fraude |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-DISTRIBUIDA]` `[REQUIERE-LEGAL]` |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV — el bloqueo de cuentas por fraude tiene plazos y procedimientos regulatorios específicos |
| **Programa ejecutor** | `S500_SOURCE_P103.txt` — comentario inicial (líneas 100500–100700) + `S500_INC_PRO_CAN.txt` — `20000006-ADMONXFERS` (líneas 1061–1084) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
-- Comentario en P103 (línea 100500):
-- "PARA GENERAR ARCHIVO PARA S711 DE MOVIMIENTOS CON CLAVE 2001, 2444, 2496,
--  SE GENERA DESDE S500B07MOVDIA Y S500B13MOVCVES"

-- El envío a S711 es via INTELAR (system ADMONXFERS en S500_INC_PRO_CAN.txt):
20000006-ADMONXFERS:
  CALL "INTELARSND IN ADMONXFERS" USING WS-ARCH-TRANSF GIVING WS77-INTELAR-RESULT
  IF WS77-INTELAR-RESULT NOT = 0:
    WAIT(03)  -- retry una vez con 3 segundos de espera
    CALL "INTELARSND IN ADMONXFERS" USING...
    IF still ERROR: emitir mensaje "ERROR AL ENVIAR ARCHIVO S711"
  ELSE: emitir mensaje "ARCHIVO S711 ENVIADO"
```

**Vocabulario en la fórmula:**
| Término | Categoría | Significado |
|---------|-----------|-------------|
| `S711` | SISTEMA | Sistema de gestión de fraude de Banamex (receptor del archivo FRAUDLINK) |
| `INTELAR` | MIDDLEWARE | Sistema de mensajería inter-subsistemas Unisys de Banamex (equivalente a MQ) |
| `INTELARSND` | FUNCIÓN | Función de envío de archivo via INTELAR |
| `WS77-INTELAR-RESULT` | CAMPO-RESULTADO | Resultado del envío INTELAR (0=OK; otro=error) |

**Excepciones documentadas:**
- Confianza MEDIA: el mecanismo de bloqueo en S711 no está documentado en el fuente de P103 ni de S500. Lo que se confirma es que P103 genera el archivo y que S711 es el destinatario.
- REQUIERE-LEGAL: la normativa de bloqueo (plazos, causales, procedimiento de desbloqueo) está en el área de Prevención de Fraude de Banamex — fuera del alcance de este análisis de código.
- El retry de INTELAR tiene un solo intento adicional (con WAIT 3s). Si el segundo intento falla, se emite un mensaje de error pero el proceso continúa. El archivo no se vuelve a intentar enviar automáticamente.
- RIESGO-EQUIVALENCIA: en el sistema modernizado, S711 puede ser reemplazado por una plataforma de fraude moderna (Featurespace, FICO Falcon, etc.). El contrato del archivo (60 chars, claves 2001/2444/2496) debe renegociarse con el nuevo sistema.

**Estado validación:** `[EXTRAÍDA-PENDIENTE-HITL]` `[REQUIERE-LEGAL]`

---

## Resumen de extracción

| Sección | Programas/artefactos | Reglas extraídas | IDs | Hardcodes críticos |
|---------|---------------------|-----------------|-----|-------------------|
| S151REGISTRA | INC_WOR_CAN + INC_PRO_CAN (15 programas activadores) | 20 | 153–172 | 9 (IND-EDOCTA, IND-DATOS-ADIC, SUCPROM overrides × 4, SUCS028 × 3) |
| P103 FRAUDLINK | S500_SOURCE_P103.txt | 10 | 173–182 | 5 (claves 2001/2444/2496, BANCO=0002, path S711) |
| **TOTAL** | | **30** | **153–182** | **14** |

**Items para validación HITL prioritaria:**
1. `RN-S500-162` — discrepancia comentario "350" vs código "342" para SUCPROM (riesgo de bug)
2. `RN-S500-174` — significado de las claves 2001/2444/2496 (requiere catálogo B17 + Legal)
3. `RN-S500-176` — semántica exacta de STATUS-MOVTO=1 (requiere entrevista con operaciones)
4. `RN-S500-158` — proceso de reproceso de contingencia S151 (no visible en el código analizado)
5. `RN-S500-182` — normativa de bloqueo en S711 (fuera del alcance del código S500)

---

*Extracción: 2026-07-16 · Business Rules Champion (Digital Core · Gemelo Cognitivo Capa 2) · Wave 2b — S151REGISTRA + P103 Fraude · Formato canónico v2 · Estado: `[EXTRAÍDA-PENDIENTE-HITL]`*
