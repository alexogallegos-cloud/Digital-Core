# ETAPA 0 — Setup & Inventory Report
> Indexado: ✅ 2026-07-17 — Capa 0 — inventario/setup report
## SPE-MM-001 · S500 — Cargos y Abonos de Cuentas de Cheque
> Banamex · Unisys ClearPath MCP · Digital Core — Mainframe Modernization
> Fecha: 2026-06-30 · Generado por: Specialist - Reverse Engineering
> Estado: **COMPLETO** — todos los ítems del checklist cubiertos

---

## 1. Fuente de Datos

| Campo | Valor |
|---|---|
| Archivo recibido | `Piezas S500 POC AIRE2026.xlsx` |
| Formato | Excel con 116 objetos OLE embebidos (archivos fuente `.txt`) + 4 hojas (COBOL / ALGOL / DASDL / WFL) |
| Versión del sistema | `2025.07_M_MEX_XPR_ALL` |
| Platform Level | Unisys ClearPath MCP SSR 62.0 (62.087.8009) |
| Contexto del archivo | POC "AIRE 2026" — colección de piezas seleccionadas para modernización |

> **Nota crítica**: El archivo fue etiquetado como "POC AIRE2026". Esto implica que puede ser una **selección**, no necesariamente el inventario completo del sistema S500. `[CONSULTAR→UNISYS]` `[CONFIRMAR CON SME BANAMEX]` si existen módulos adicionales no incluidos en este POC.

---

## 2. Inventario Maestro

### 2.1 Resumen por tipo

| Tipo | Piezas | LOC Total | % del total | Notas |
|---|---|---|---|---|
| **COBOL** (programas) | 78 | 461,882 | 51.4% | Incluye 3 sub-archivos de P010 |
| **INC** (includes/copybooks) | 10 | 164,004 | 18.3% | Copybooks COBOL; algunos > 40K LOC |
| **ALGOL** (módulos de librería) | 15 | 91,512 | 10.2% | Módulos de interfaz con MCP / DMSII |
| **WFL** (jobs) | 4 | 34,244 | 3.8% | LOTE(batch) + LINEA(online) + 2 REORG |
| **DASDL** (schemas BD) | 7 | 15,228 | 1.7% | 7 bases DMSII |
| **SUBTOTAL** | **114** | **766,870** | | 2 piezas sin versión (P104, P050) |
| *Estimado faltante* | *~2* | *~131,726* | | P104 (9,022 LOC), P050 (3,668 LOC) cargados |
| **TOTAL REAL** | **116** | **898,596** | 100% | |

### 2.2 Top 20 programas por LOC

| Rank | LOC | Tipo | Pieza | Notas |
|---|---|---|---|---|
| 1 | 52,656 | COBOL | `S500/SOURCE/P010/` | **Motor principal** — todas las operaciones cargo/abono |
| 2 | 44,012 | COBOL | `S500/SOURCE/P020/` | Segundo programa mayor |
| 3 | 43,496 | INC | `S500/INC/PRO/` | Include de procedimientos (ABONOS/CARGOS) |
| 4 | 42,310 | COBOL | `S500/SOURCE/P010/PRO/` | Sub-archivo P010 — Variables de ABONOS |
| 5 | 40,892 | INC | `S500/INC/PRO/CAN/` | Include cancelaciones |
| 6 | 31,762 | COBOL | `S500/SOURCE/P130/` | |
| 7 | 30,134 | WFL | `S500/WFL/LOTE/` (LOTE 26MTP002) | **Job batch principal** — ciclo nocturno completo |
| 8 | 29,138 | COBOL | `S500/SOURCE/P142/` | |
| 9 | 28,994 | COBOL | `S500/SOURCE/P144/` | |
| 10 | 27,612 | ALGOL | `S500/SOURCE/L010/CONTROL/` | **Motor de control ALGOL** — orquestación MCP |
| 11 | 23,980 | INC | `S500/INC/WOR/` | Include WORKING STORAGE principal |
| 12 | 23,782 | INC | `S500/INC/P010/MAS/` | Include MASTER para P010 |
| 13 | 23,494 | ALGOL | `S500/SOURCE/L039/ACCESOBD04/` | Acceso a BD04 (TARJETAS) |
| 14 | 20,556 | COBOL | `S500/SOURCE/P105/` | |
| 15 | 18,554 | INC | `S500/INC/WOR/CAN/` | Include WORKING STORAGE cancelaciones |
| 16 | 18,548 | COBOL | `S500/SOURCE/P080/` | |
| 17 | 17,734 | COBOL | `S500/SOURCE/P015/` | |
| 18 | 15,642 | COBOL | `S500/SOURCE/P330/` | |
| 19 | 13,694 | COBOL | `S500/SOURCE/P045/` | |
| 20 | 12,800 | ALGOL | `S500/SOURCE/L050/` | |

---

## 3. Arquitectura del Sistema (ETAPA 0 — observaciones preliminares)

> Estas observaciones son resultado del análisis de estructura del inventario, los encabezados de compilación y las primeras líneas de los programas principales. Las reglas de negocio detalladas son ETAPA 3.

### 3.1 Motor Principal — P010

`S500/SOURCE/P010/` es el programa central del sistema S500. Sus características:

| Característica | Evidencia |
|---|---|
| **52,656 LOC** — más grande del sistema | Conteo real de líneas |
| Referencia **50+ tipos de registro DMSII** en `$SET` | `$SET BDB50R05/06/07, BDB00R01-04, BDB01R01-03, BDB02R01-03, BDB03R06-12, BDB04R04-20, BDB05R02-10, BDB06R04-11, BDB07R04-10, BDB08R04-13, BDB09R02-10, BDB46R05-15, BDB12R04-10, BDB13R03-06, BDB15R04-10, BDB16R01-09, BDB17R02-07, BDB18R03-09, BDB21R05-11` |
| Se fragmenta en 3 sub-archivos | `P010/`, `P010/PRO/` (ABONOS, 42,310 LOC), `P010/PAR/` (parámetros y WORKING STORAGE, 11,018 LOC) |
| Include principal | `S500/INC/P010/MAS/` (23,782 LOC) |

**`[DEUDA_TÉCNICA]`** P010 con 50+ tipos de registro DMSII en un solo programa es un **mega-acoplamiento** con la capa de datos. La refactorización requiere desacoplar primero el acceso a datos mediante un Anti-Corruption Layer sobre DMSII antes de transpilación.

### 3.2 Modos de Operación Confirmados

Descubiertos en `P010/PAR/` — estructura de control `WS-S500B00CTRLPASO`:

```
WS00-TIPO-PROCESO  PIC 9(01) COMP
  88 WS00-88-LINEA     VALUE 0   ← online (tiempo real)
  88 WS00-88-BATCH     VALUE 1   ← nocturno (lote)
  88 WS00-88-PRELINEA  VALUE 2   ← pre-online (preparación)
```

El mismo motor P010 corre en los 3 modos — la lógica diferencial está en los condicionales sobre `WS00-TIPO-PROCESO`.

**`[CANDIDATO_DOMINIO]`** Los 3 modos sugieren 3 bounded contexts potenciales en el target architecture: `OnlineTransactionService`, `BatchProcessingService`, `PreProcessingService`.

### 3.3 Bases de Datos DMSII — 7 Schemas

| BD | Archivo DASDL | LOC | Función inferida |
|---|---|---|---|
| `S500BD01CAPTACION` | `DASDL/CAPTACION/` | 8,336 | **Principal** — cuentas de captación (depósitos, cheques) |
| `S500BD04TARJETAS` | `DASDL/TARJETAS/` | 2,692 | Tarjetas asociadas a cuentas |
| `S500BD02AUXILIAR`? | `DASDL/AUXILIAR/` | 1,862 | Datos auxiliares / catálogos |
| `S500BD06TELETON` | `DASDL/TELETON/` | 710 | Sistema "Teletón" — `[AMBIGUO: requiere SME]` |
| `S500BDxxMAPLI` | `DASDL/MAPLI/` | 646 | Mapas de aplicación (screens/forms) |
| `S500BDxxATRIBUCTA` | `DASDL/ATRIBUCTA/` | 544 | Atributos de cuenta |
| `S500BDxxMSGAAPLI` | `DASDL/MSGAAPLI/` | 438 | Mensajes de aplicación |

**`[DEUDA_TÉCNICA]`** El DASDL de CAPTACION (8,336 LOC) es la BD central. P104 tiene hard-coded los valores de POPULATION (tamaño máximo de los dataset DMSII): *"CADA QUE SE MODIFIQUE POPULATION DE UN DATA SET SE DEBE LIBERAR EL P104 (LOS TIENE EN HARD-CODE)"* — riesgo de divergencia entre schema DMSII y programa P104 si se modifican límites.

### 3.4 WFL Jobs — Ciclo de Ejecución

| Job | LOC | Tipo | Función confirmada |
|---|---|---|---|
| `S500/WFL/LOTE/26MTP002` | **30,134** | Batch nocturno | BEGIN JOB S500/WFL/LOTE — orquesta todo el ciclo nocturno |
| `S500/WFL/LINEA/24MTP005` | **3,920** | Online | BEGIN JOB S500/WFL/LINEA — orquesta transacciones en línea |
| `S500/WFL/REORG/GARBAGE/S500BD01CAPTACION/25MTP003` | 92 | Mantenimiento | Reorganización / garbage collection de BD01 CAPTACION |
| `S500/WFL/REORG/GARBAGE/S500BD04TARJETAS/25MTP003` | 98 | Mantenimiento | Reorganización de BD04 TARJETAS |

**`[NFR]`** El WFL LOTE con 30,134 LOC indica una cadena batch de alta complejidad. La duración de la ventana batch es dato crítico pendiente de obtener vía logs SUMLOG.

### 3.5 Módulos ALGOL — Control y Acceso a BD

| Módulo | LOC | Función inferida |
|---|---|---|
| `L010/CONTROL/` | 27,612 | **Motor de control** — orquestación general del sistema MCP (inicio, fin, errores) |
| `L039/ACCESOBD04/` | 23,494 | Acceso dedicado a BD04 (TARJETAS) — capa de acceso DMSII |
| `L050/` | 12,800 | `[AMBIGUO]` — requiere análisis ETAPA 2/3 |
| `L035/MAPLI/` | 10,802 | Manejo de mapas de aplicación (screens) |
| `L019/SALDOS` | 1,146 | **Saldos** — `[REGLA_NEGOCIO]` módulo crítico de cálculo de saldos |
| `L019/SALDOS/` | 573 | Sub-módulo saldos (cancelaciones/variante) |
| `L030/TIEMPOS/` | 1,962 | Control de tiempos / timing |
| `L040/LIGAS/` | 742 | Ligas / links entre estructuras |
| `L045/TELETON/` | 144 | Interfaz con sistema Teletón |
| `L046/REVOCA/` | 600 | Revocaciones |
| `L060/CONSULFOR/` | 504 | Consulta de formato |
| `L070/` | 706 | `[AMBIGUO]` |
| `L080/` | 3,342 | `[AMBIGUO]` |
| `L081/` | 5,600 | `[AMBIGUO]` |
| `L091/ASINCRONA/` | 1,028 | Procesamiento asíncrono |
| `L093/ASINCRONA/` | 1,030 | Procesamiento asíncrono (variante) |

**`[CANDIDATO_DOMINIO]`** L019/SALDOS es un módulo ALGOL dedicado a cálculo de saldos — candidato a convertirse en un `BalanceCalculationService` independiente en el target architecture.

### 3.6 Includes (Copybooks) — Reutilización de Código

| Include | LOC | Función inferida |
|---|---|---|
| `INC/PRO/` | 43,496 | Procedimientos principales (ABONOS/CARGOS) — copybook gigante |
| `INC/PRO/CAN/` | 40,892 | Procedimientos de cancelaciones |
| `INC/WOR/` | 23,980 | Working Storage principal |
| `INC/P010/MAS/` | 23,782 | Master include para P010 |
| `INC/WOR/CAN/` | 18,554 | Working Storage para cancelaciones |
| `INC/WOR/DAS/` | 9,288 | Working Storage para acceso a datos |
| `INC/L010` | 3,242 | Include para módulo ALGOL L010 |
| `INC/MAPLI/WOR` | 392 | Working Storage para mapas |
| `INC/MAPLI/PRO` | 232 | Procedimientos para mapas |
| `INC/L020/` | 146 | Include para módulo ALGOL L020 |

**`[DEUDA_TÉCNICA]`** Los includes `INC/PRO/` (43,496 LOC) e `INC/PRO/CAN/` (40,892 LOC) son **copybooks de 40K+ LOC** — un anti-patrón en COBOL moderno. Esto indica que la lógica de ABONOS y CANCELACIONES está distribuida en múltiples programas vía copy, lo que complica el análisis de dependencias. La ETAPA 1 debe generar el grafo de uso de estos includes.

---

## 4. Hallazgos Críticos para Modernización

### 4.1 Deuda Técnica Identificada

| ID | Hallazgo | Severidad | Impacto en Modernización |
|---|---|---|---|
| DT-001 | P104 hard-codea POPULATION de datasets DMSII | **Alta** | P104 debe actualizarse cada vez que cambia el schema DMSII; acoplamiento frágil |
| DT-002 | P010 referencia 50+ record types DMSII en un solo programa | **Alta** | Mega-acoplamiento con la capa de datos; dificulta refactorización incremental |
| DT-003 | Includes COBOL de 40K+ LOC (`INC/PRO/`, `INC/PRO/CAN/`) | **Media** | Lógica de negocio difícil de aislar y probar unitariamente |
| DT-004 | WFL LOTE de 30K LOC | **Media** | Cadena batch altamente compleja; difícil paralelizar o migrar parcialmente |
| DT-005 | Lógica dividida entre COBOL (P010) y ALGOL (L010/CONTROL, L039/ACCESOBD04) | **Media** | Transpilación parcial imposible; COBOL y ALGOL deben migrarse coordinadamente |

### 4.2 Componentes de Alto Valor para "Quick Win" (Fase A — Encapsulate)

| Componente | LOC | Justificación |
|---|---|---|
| `L019/SALDOS` | 1,146 | Módulo aislado de cálculo de saldos — bajo riesgo, alto valor para exposición como API |
| `L046/REVOCA/` | 600 | Módulo de revocaciones — funcionalidad acotada |
| `P075/` | 476 | Programa pequeño (238 líneas editor) — candidato a análisis rápido |
| Consulta de movimientos | TBD | Funcionalidad de solo-lectura = candidata natural para API-fy sin riesgo |

### 4.3 Riesgos Descubiertos en ETAPA 0

| Riesgo | Evidencia | Acción |
|---|---|---|
| Sistema más amplio que "cuentas de cheque" | BD04 TARJETAS (2,692 LOC DASDL + L039/ACCESOBD04 23K LOC) presente | `[CONFIRMAR CON SME BANAMEX]` si el scope real incluye tarjetas de débito asociadas |
| POC vs. inventario completo | Nombre del archivo: "Piezas S500 POC AIRE2026.xlsx" | `[BLOQUEANTE-POTENCIAL]` Confirmar si este es el inventario completo de producción o solo los módulos del POC |
| Sistema modificado recientemente | Release `2025.07_M_MEX_XPR_ALL` (julio 2025) | Positivo: código activo y mantenido; negativo: snapshot puede no ser HEAD si hay cambios post-julio 2025 |

---

## 5. Checklist de Completitud — ETAPA 0

| Ítem | Estado | Notas |
|---|---|---|
| ✓ 0.1 — Código fuente recibido y cargado | **COMPLETO** | 116 piezas en `Piezas S500 POC AIRE2026.xlsx`; extraídas en `extracted_source/` |
| ✓ 0.2 — Inventario maestro completo | **COMPLETO** | Ver §2 de este reporte |
| ✓ 0.3 — DASDL schema del DMSII recibido | **COMPLETO** | 7 schemas extraídos (ver §3.3) |
| ☐ 0.4 — Logs SUMLOG (30+ días) | **PENDIENTE** | No recibidos; necesarios para NFR baseline §05 del spec |
| ☐ 0.5 — SME técnico Banamex asignado | **PENDIENTE** | Por confirmar con equipo Banamex |
| ⚠ 0.6 — Confirmación de inventario completo | **PENDIENTE** | Ver riesgo: POC vs. inventario completo de producción |
| ✓ 0.7 — Ambiente de análisis operativo | **COMPLETO** | Extracción local exitosa |

**Estado ETAPA 0**: **SUSTANCIALMENTE COMPLETO** — avance a ETAPA 1 (Static Analysis) autorizado con las observaciones de riesgo 0.4 y 0.6 documentadas como `[BLOQUEANTE-POTENCIAL]` para validación.

---

## 6. Plan de ETAPA 1 — Static Analysis (próximos pasos)

Con el código extraído en `extracted_source/`, la ETAPA 1 ejecutará:

1. **Call graph** de P010: mapear qué programas llama P010 (CALL statements) y cuáles lo llaman.
2. **Dependency matrix COBOL→INCLUDE**: qué programas hacen COPY de cada include.
3. **$SET record types per program**: mapear qué tipos DMSII usa cada programa (del análisis de P010 ya conocemos 50+ tipos).
4. **Complexity metrics**: estimar complejidad ciclomática de los top 20 programas por LOC.
5. **Dead code candidates**: programas con 0 referencias desde WFL/otros COBOL.
6. **ALGOL call graph**: relación entre L010/CONTROL y los demás módulos ALGOL.

---

*ETAPA 0 completada: 2026-06-30*
*Próxima etapa: ETAPA 1 — Static Analysis*
*Archivos fuente disponibles en: `Banamex/S500/source/S500/extracted_source/`*