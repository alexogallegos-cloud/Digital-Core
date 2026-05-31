# Planted Defects · SISTEMA-CREDITO-LATAM

> Exclusivo del Training - Synthetic Codebase Lab. Cada defecto, su ubicación
> exacta y qué debe detectar quien lo busque. Esta es la lista contra la que se puntúa
> precision/recall en modo benchmark.

| # | Tipo | Ubicación | Detalle | Qué debe detectar |
|---|------|-----------|---------|-------------------|
| D1 | **Dead code** | `cobol/OLDVAL.cbl` | Programa sin CALL entrante ni referencia en JCL | Candidato a dead code → Retire |
| D2 | **Shadow inventory** | `jcl/PROCREDI.jcl` STEP040 `EXEC PGM=BCKPUTI` | BCKPUTI se ejecuta en producción pero no hay fuente en el codebase | Programa fantasma: localizar fuente antes de migrar |
| D3 | **Hardcoded value** | `cobol/CREDVAL.cbl` `WS-MAX-CREDITOS VALUE 3` | RN-001: máximo de créditos fijo en código | Externalizar a config |
| D4 | **Hardcoded value** | `cobol/CREDVAL.cbl` `WS-FACTOR-LIMITE VALUE 5` | RN-002: factor de límite fijo | Externalizar; validar origen del 5 |
| D5 | **Hardcoded value** | `cobol/CREDVAL.cbl` `WS-UMBRAL-SCORE VALUE 600` | RN-004: umbral de score fijo | Externalizar; ¿regulatorio? |
| D6 | **Hardcoded value** | `cobol/LIMCHK.cbl` `WS-LIM-PERSONAL VALUE 500000.00` | RN-005: límite personal fijo | Externalizar |
| D7 | **Hardcoded value** | `cobol/CREDALT.cbl` `WS-MONTO-MINIMO VALUE 1000.00` | RN-008: monto mínimo fijo | Externalizar |
| D8 | **Dynamic CALL** | `cobol/SCOVAL.cbl` `CALL WS-PROG-BURO` | Target ('BUROEXT1') resuelto en runtime | No resoluble por análisis estático → marcar `[AMBIGUO]` |
| D9 | **2-digit date** | `cobol/RPTGEN.cbl` `WS-ANIO-CORTE PIC 9(02) VALUE 26` + `ddl HIST_ANIO` | Año de 2 dígitos, ventana de siglo | Riesgo de ambigüedad 1926/2026 |
| D10 | **COMP-3** | CREDCPY: CRED-MONTO, CRED-TASA; CLICPY: CLI-SALDO-PROM; LIMCPY: LIM-MAXIMO | 4 campos packed decimal | Depack exacto en migración de datos |
| D11 | **GO TO** | `cobol/CREDVAL.cbl` párrafo `6000-DECIDE` (`GO TO 6000-EXIT`) | Salto de control no estructurado | Construct a refactorizar en transpilación |
| D12 | **EVALUATE anidado** | `cobol/CREDVAL.cbl` `5000-EVALUA-RIESGO` | Máquina de decisión por tipo de crédito | Candidato a decision table |
| D13 | **88-level conditions** | CREDCPY (CRED-TIPO, CRED-STATUS), CLICPY (CLI-STATUS) | Valores de dominio implícitos | Enums del dominio destino |

## Conteo para benchmark
- Dead code: **1** · Shadow inventory: **1** · Hardcoded: **5** · Dynamic call: **1**
- 2-digit date: **1** · Campos COMP-3: **4** · GO TO: **1** · EVALUATE anidado: **1** · 88-levels: **3 grupos**

## Cómo puntuar
Correr el RE specialist o una herramienta sobre `source/` (sin este archivo) y comparar
su salida contra D1–D13. Reportar precision/recall por categoría (ver §8 del CLAUDE.md del Specialist).
El shadow inventory (D2) y el dynamic call (D8) son los reveladores más duros.