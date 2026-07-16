# Catálogo de Reglas de Negocio — Sistema S500 (Captación / Cargos y Abonos)

> **Sistema:** S500 — Cargos y Abonos de Cuentas de Cheque · Unisys ClearPath MCP · Banamex
> **Extractor:** Specialist - Business Rules + Specialist - Reverse Engineering (Digital Core)
> **Estado:** ✅ completo — 55 reglas revalidadas contra fuente 2026-07-14
> **Última actualización:** 2026-07-16

---

## Resumen ejecutivo

| Métrica | Valor |
|---------|-------|
| Programas analizados | 5 / ~114 |
| Reglas extraídas | 55 |
| Reglas validadas SME | 55 (revalidadas contra fuente 2026-07-14) |
| Cobertura estimada | ~5% |

## Distribución por programa

| Programa | Proceso | Dominio | Reglas | IDs |
|----------|---------|---------|--------|-----|
| P103 | BATCH | REP — Reportería regulatoria | 8 | RN-S500-001..008 |
| P100 | MIXED | CTL — Control fecha/período | 13 | RN-S500-009..021 |
| P075 | BATCH | CTL — Control proceso auxiliar | 5 | RN-S500-022..026 |
| P655 | BATCH | SEC — Seguridad producción | 10 | RN-S500-027..036 |
| S500P630 | ONLINE | TAR — Tarjetas/Intercambio | 19 | RN-S500-037..055 |

---

## Reglas extraídas

---
### RN-S500-001 — Validación de versión antes de generar reporte FraudLink

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [REPORTE-REGULATORIO] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P103 |
| **Confianza** | alta |

**Descripción:** Antes de generar el reporte diario hacia FraudLink, el programa valida que la versión que se está ejecutando coincida con la registrada en el catálogo central de versiones del banco (librería S100VERSIONES); si no coincide, aborta la tarea y el archivo de salida hacia FraudLink nunca llega a abrirse — no se genera ningún reporte ese día. Técnicamente: la validación ocurre en el paragraph 10000100-TIT-LIBS (PERFORM 10000100-VERSIONES → 20000100-CHECAME-VERSION); IF S000-CTR-CVEERROR < 0 se emite el mensaje "ERROR DE VERSION" y se cancela con CHANGE ATTRIBUTE STATUS OF MYSELF TO -1 (mecanismo de cancelación distinto al CALL SYSTEM DMTERMINATE usado en el resto del programa).

**Trigger:** Si S000-CTR-CVEERROR < 0, el programa emite error de versión y cancela la ejecución antes de abrir el archivo de salida FraudLink.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `S000-CTR-CVEERROR` | Indicador de error | Resultado de la validación de versión contra S100VERSIONES |

**Traza de código:**
```
PROGRAMA: P103 — S500/P103 FraudLink
SECCIÓN/PÁRRAFO: 10000100-TIT-LIBS → 20000100-CHECAME-VERSION
Líneas aproximadas: ~160
Tipo de sentencia: IF
```

**Riesgos de migración:**
- CHANGE ATTRIBUTE STATUS OF MYSELF TO -1 es un mecanismo propietario de Unisys MCP; no tiene equivalente directo en plataformas modernas — debe reemplazarse por un mecanismo de abort/excepción explícito en la plataforma destino.
- La validación depende de la librería centralizada S100VERSIONES; si este catálogo no se migra o se reestructura, la regla queda huérfana en el sistema destino.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-002 — Cancelación si falla lectura del registro de control

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [REPORTE-REGULATORIO] |
| **Base regulatoria** | CNBV |
| **Programa(s)** | P103 |
| **Confianza** | alta |

**Descripción:** Si el registro maestro de control de captación (S500B02CONTROL) no puede leerse correctamente, el proceso cancela antes de abrir el archivo de salida y no se genera el reporte hacia FraudLink/CNBV (S711) ese día. Técnicamente: en 20000100-ABRE-BASE, tras PERFORM 90000002-B02CONTROL-FIND sobre S500B02CONTROL (base de captación S500BD01CAPTACION), IF WS-STATUS-BASE > 0 el proceso cancela vía CALL SYSTEM DMTERMINATE antes de abrir el archivo E03-CVES2001. Ese mismo registro de control aporta B02-NUM-CSI (nodo/instancia) y B02-FECHA-LOTE (fecha de proceso batch, no la fecha de línea), usados como cabecera del archivo.

**Trigger:** Si WS-STATUS-BASE > 0 tras leer S500B02CONTROL, el proceso cancela vía CALL SYSTEM DMTERMINATE antes de abrir el archivo E03-CVES2001.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WS-STATUS-BASE` | Indicador de estado | Resultado de la lectura de S500B02CONTROL; >0 indica error |
| `B02-NUM-CSI` | Dato de control | Nodo/instancia del sistema; se usa como cabecera del archivo de salida |
| `B02-FECHA-LOTE` | Fecha | Fecha de proceso batch (no fecha de línea); se usa como cabecera del archivo de salida |

**Traza de código:**
```
PROGRAMA: P103 — S500/P103 FraudLink
SECCIÓN/PÁRRAFO: 20000100-ABRE-BASE → 90000002-B02CONTROL-FIND
Líneas aproximadas: ~177
Tipo de sentencia: IF
```

**Riesgos de migración:**
- CALL SYSTEM DMTERMINATE es una llamada al sistema operativo Unisys MCP; debe reemplazarse por manejo de excepciones en la plataforma destino; si no se hace correctamente el proceso podría continuar con datos inválidos.
- B02-FECHA-LOTE es la fecha de proceso batch, no la fecha del sistema; si la migración asume la fecha del sistema como equivalente, se rompe la auditoría CNBV para días de reproceso.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-003 — Control de fin de archivo en ciclo de movimientos

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [REPORTE-REGULATORIO] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P103 |
| **Confianza** | alta |

**Descripción:** El programa recorre secuencialmente todos los movimientos del día para evaluarlos como posible reporte a FraudLink; al llegar al final del archivo termina el ciclo de forma normal, pero cualquier otro error de lectura aborta el proceso completo. Técnicamente: en el ciclo principal (50001000-PROCESO), tras cada PERFORM 90000007-B07MOVDIA-FINDN (lectura secuencial de S500B07MOVDIA), IF WS-STATUS-BASE > 0: valor 1 marca W77-EOF-B07 = 1 (fin de archivo, término normal del ciclo UNTIL); cualquier otro valor distinto de cero cancela el proceso vía CALL SYSTEM DMTERMINATE.

**Trigger:** En la lectura secuencial de S500B07MOVDIA, WS-STATUS-BASE = 1 señala fin de archivo (término normal); cualquier otro valor >0 distinto de 1 cancela el proceso completo.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WS-STATUS-BASE` | Indicador de estado | Resultado de cada lectura secuencial de S500B07MOVDIA |
| `W77-EOF-B07` | Indicador booleano | Bandera de fin de archivo; se activa (=1) cuando WS-STATUS-BASE = 1 |

**Traza de código:**
```
PROGRAMA: P103 — S500/P103 FraudLink
SECCIÓN/PÁRRAFO: 50001000-PROCESO → 90000007-B07MOVDIA-FINDN
Líneas aproximadas: ~219
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La distinción exacta entre WS-STATUS-BASE = 1 (EOF normal) y cualquier otro valor >0 (error) es crítica; en plataformas modernas los códigos de retorno de IO tienen semántica diferente — se requiere tabla de mapeo explícita de códigos de estado Unisys MCP a la plataforma destino.
- CALL SYSTEM DMTERMINATE en el ramal de error requiere sustitución por mecanismo de abort/excepción que garantice el cierre limpio de archivos abiertos.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-004 — Exclusión de movimientos con estado 1 del análisis

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [REPORTE-REGULATORIO] |
| **Base regulatoria** | CNBV |
| **Programa(s)** | P103 |
| **Confianza** | alta |

**Descripción:** Ciertos movimientos se excluyen del análisis de fraude antes de evaluar su código de transacción: si el estado del movimiento (B07-STATUS-MOVTO) es igual a 1, se descarta sin generar ningún registro; cualquier otro valor continúa hacia la evaluación de código de transacción (MOV-ORIG, OPERO5-B07, MOVS-B13). Nota de verificación: el catálogo DASDL solo documenta B07-STATUS-MOVTO como "Estado del movimiento en curso", sin enumerar sus valores posibles — no hay confirmación en las fuentes revisadas de que el valor 1 signifique específicamente cancelación o anulación; esa interpretación queda como hipótesis razonable de convención bancaria, no como hecho verificado.

**Trigger:** Si B07-STATUS-MOVTO = 1, el movimiento se descarta sin generar ningún registro en el archivo FraudLink; cualquier otro valor pasa a la evaluación de código de transacción.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `B07-STATUS-MOVTO` | Indicador de estado | Estado del movimiento en curso; valor 1 = excluir del análisis de fraude (hipótesis: cancelado/anulado) |

**Traza de código:**
```
PROGRAMA: P103 — S500/P103 FraudLink
SECCIÓN/PÁRRAFO: 50001000-PROCESO (ciclo principal de evaluación)
Líneas aproximadas: ~229
Tipo de sentencia: IF
```

**Riesgos de migración:**
- El catálogo DASDL no enumera los valores posibles de B07-STATUS-MOVTO; el significado del valor 1 (hipótesis: cancelación/anulación) no está formalmente verificado — si la hipótesis es incorrecta, la migración excluiría movimientos que sí deberían reportarse a CNBV.
- Si la plataforma destino usa un catálogo de estados de movimiento con semántica o valores distintos, el mapeo de la condición de exclusión debe redefinirse explícitamente con base en especificación funcional confirmada.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-005 — Reporte a FraudLink de códigos de transacción monitoreados

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [REPORTE-REGULATORIO] |
| **Base regulatoria** | CNBV |
| **Programa(s)** | P103 |
| **Confianza** | alta |

**Descripción:** Los movimientos con código de transacción 2001, 2444 o 2496 — las claves que el banco monitorea para prevención de fraude — se reportan a FraudLink/CNBV (S711) con sucursal, medio de acceso, fecha, código e importe. Técnicamente (50001100-MOV-ORIG, IF B07-CLAVE-MOVTO = 2001 OR 2444 OR 2496): el registro incluye WKS-SUC-OPE (sucursal, primeros 4 dígitos de B07-AUTORIZACION vía REDEFINES RD-WKS-AUTORIZ-MOV — los otros 2+8 dígitos, caja y secuencia, se descomponen pero no se usan en este registro), B07-MED-ACCESO (medio de acceso; catálogo B07-TIPO-MEDACCES: 0=Contrato,1=Chequera,2=Tarjeta,3=PIN, aunque el campo destino conserva el nombre legado WKS-REG-E03-CHQRA), B02-FECHA-LOTE (fecha de proceso batch), B07-CLAVE-MOVTO (código de transacción) y B07-IMPORTE más B07-REFER-NUME (referencia). WKS-SUC-OPE se calcula una sola vez por movimiento padre (línea 232) y se reutiliza en los registros de sus sub-movimientos B07 y B13.

**Trigger:** Si B07-CLAVE-MOVTO = 2001, 2444 o 2496, se genera un registro en el archivo FraudLink con sucursal, medio de acceso, fecha de lote, código de transacción, importe y referencia.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `B07-CLAVE-MOVTO` | Código de transacción | Clave evaluada; valores 2001/2444/2496 disparan el reporte |
| `WKS-SUC-OPE` | Dato derivado | Sucursal operadora; primeros 4 dígitos de B07-AUTORIZACION vía REDEFINES |
| `B07-AUTORIZACION` | Número de autorización | Fuente del REDEFINES RD-WKS-AUTORIZ-MOV; descompone sucursal, caja y secuencia |
| `B07-MED-ACCESO` | Indicador | Medio de acceso (0=Contrato,1=Chequera,2=Tarjeta,3=PIN); destino: WKS-REG-E03-CHQRA |
| `B02-FECHA-LOTE` | Fecha | Fecha de proceso batch incluida en el registro FraudLink |
| `B07-IMPORTE` | Importe | Monto del movimiento a reportar |
| `B07-REFER-NUME` | Referencia | Referencia del movimiento incluida en el registro FraudLink |

**Traza de código:**
```
PROGRAMA: P103 — S500/P103 FraudLink
SECCIÓN/PÁRRAFO: 50001100-MOV-ORIG
Líneas aproximadas: ~241
Tipo de sentencia: IF
```

**Riesgos de migración:**
- Los códigos de fraude monitoreados (2001, 2444, 2496) están hardcoded en el programa; si el banco extiende el catálogo de claves de fraude, requiere modificación del programa migrado — se recomienda externalizar a tabla de configuración parametrizable.
- WKS-REG-E03-CHQRA es un nombre de campo legado que contiene B07-MED-ACCESO (medio de acceso, no número de chequera); la homonimia puede generar asignaciones incorrectas si el mapeo de campos no se documenta y valida explícitamente en la migración.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-006 — Reporte de hasta 5 sub-movimientos SAD con código de fraude

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [REPORTE-REGULATORIO] |
| **Base regulatoria** | CNBV |
| **Programa(s)** | P103 |
| **Confianza** | alta |

**Descripción:** El monitoreo de fraude no se limita al movimiento principal: cada movimiento puede traer hasta 5 sub-movimientos asociados (grupo "Otros Movimientos SAD"), y cada uno de ellos con código 2001, 2444 o 2496 genera también su propio registro independiente en el archivo FraudLink. Técnicamente (50001200-OPERO5-B07, PERFORM ... 5 TIMES desde 50001000-PROCESO): IF B07-CVE-MOVAD (W77-IND-B07) = 2001 OR 2444 OR 2496, cada sub-movimiento del grupo B07-OTROS-MOVSAD (×5) genera su registro con el mismo WKS-SUC-OPE del movimiento padre pero su propio código/importe/referencia (B07-CVE-MOVAD, B07-IMP-MOVAD, B07-REF-MOVAD indexados por W77-IND-B07).

**Trigger:** Por cada sub-movimiento del grupo B07-OTROS-MOVSAD (hasta 5), si B07-CVE-MOVAD = 2001, 2444 o 2496, se genera un registro FraudLink independiente reutilizando WKS-SUC-OPE del movimiento padre.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `B07-CVE-MOVAD` | Código de transacción | Clave del sub-movimiento SAD; se evalúa contra 2001/2444/2496 |
| `W77-IND-B07` | Índice | Índice de iteración (1–5) sobre el grupo B07-OTROS-MOVSAD |
| `B07-IMP-MOVAD` | Importe | Monto del sub-movimiento; indexado por W77-IND-B07 |
| `B07-REF-MOVAD` | Referencia | Referencia del sub-movimiento; indexada por W77-IND-B07 |
| `WKS-SUC-OPE` | Dato heredado | Sucursal del movimiento padre; reutilizada en cada registro de sub-movimiento |

**Traza de código:**
```
PROGRAMA: P103 — S500/P103 FraudLink
SECCIÓN/PÁRRAFO: 50001200-OPERO5-B07 (invocado 5 TIMES desde 50001000-PROCESO)
Líneas aproximadas: ~254
Tipo de sentencia: IF
```

**Riesgos de migración:**
- El límite de 5 sub-movimientos está hardcoded mediante PERFORM ... 5 TIMES; si la estructura de datos destino permite listas dinámicas de sub-movimientos, este límite fijo puede truncar registros FraudLink y generar una subdeclaración ante CNBV.
- WKS-SUC-OPE se hereda del movimiento padre mediante reutilización de área de trabajo; en la migración debe garantizarse que este valor se propague correctamente a cada sub-movimiento sin sobreescritura prematura.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-007 — Reporte de hasta 10 claves adicionales B13 con código de fraude

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [REPORTE-REGULATORIO] |
| **Base regulatoria** | CNBV |
| **Programa(s)** | P103 |
| **Confianza** | alta |

**Descripción:** El reporte a FraudLink alcanza también un tercer nivel de detalle: cuando el movimiento indica que existen claves de transacción adicionales asociadas al contrato, el programa las revisa una por una (hasta 10) y genera un registro FraudLink adicional por cada una que tenga un código de fraude monitoreado. Técnicamente: si B07-IND-MOVSADS > 0, se ejecuta 50001300-MOVS-B13, que localiza S500B13MOVCVES por B07-NUM-CONTRATO (FK) + B07-AUTORIZACION; si existe (W77-SIN-B13 = 0), recorre hasta 10 veces (50001350-BUSCA-B13) el grupo B13-CLAVES-TRANS×10 de ese contrato/autorización. Cada entrada con B13-CLAVE-MOVTO(idx) = 2001, 2444 o 2496 genera un registro FraudLink adicional con B13-IMPORTE(idx) y B13-REF-MOVAD(idx).

**Trigger:** Si B07-IND-MOVSADS > 0 y existe S500B13MOVCVES para el par contrato/autorización, se recorren hasta 10 entradas del grupo B13-CLAVES-TRANS y se genera un registro FraudLink por cada una con código 2001, 2444 o 2496.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `B07-IND-MOVSADS` | Indicador | Señal de existencia de claves adicionales B13 asociadas al movimiento |
| `B07-NUM-CONTRATO` | Clave FK | Clave de contrato; usada para localizar S500B13MOVCVES |
| `B07-AUTORIZACION` | Clave FK | Número de autorización; usada junto a B07-NUM-CONTRATO como clave de acceso a B13 |
| `W77-SIN-B13` | Indicador de existencia | 0 = existe el registro B13; distinto de 0 = no existe |
| `B13-CLAVE-MOVTO` | Código de transacción | Clave de cada entrada del grupo B13-CLAVES-TRANS×10; evaluada contra 2001/2444/2496 |
| `B13-IMPORTE` | Importe | Monto de la clave B13; indexado por posición en el grupo |
| `B13-REF-MOVAD` | Referencia | Referencia de la clave B13; indexada por posición en el grupo |

**Traza de código:**
```
PROGRAMA: P103 — S500/P103 FraudLink
SECCIÓN/PÁRRAFO: 50001300-MOVS-B13 → 50001350-BUSCA-B13
Líneas aproximadas: ~236
Tipo de sentencia: IF
```

**Riesgos de migración:**
- El límite de 10 claves B13 por contrato/autorización está hardcoded en la estructura B13-CLAVES-TRANS×10; debe verificarse si es un límite estructural del esquema DASDL o solo del programa — un cambio en la definición del registro B13 en el sistema destino podría alterar silenciosamente el número de claves revisadas.
- La FK compuesta B07-NUM-CONTRATO + B07-AUTORIZACION hacia S500B13MOVCVES crea una dependencia referencial entre bases que debe mapearse explícitamente en el modelo de datos destino, garantizando integridad referencial equivalente.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-008 — Acumulación de contador e importe total para trailer de cierre

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [REPORTE-REGULATORIO] |
| **Base regulatoria** | CNBV |
| **Programa(s)** | P103 |
| **Confianza** | alta |

**Descripción:** Cada vez que se escribe un registro en el archivo FraudLink, el programa acumula un conteo de registros y una suma de importes reportados; al cerrar el archivo, ambos totales se escriben como registro de cierre (trailer), permitiendo que FraudLink/CNBV valide que recibió el archivo completo, sin registros perdidos ni duplicados. Técnicamente, la operación se implementa como una pareja de ADD, no como una sentencia COMPUTE (paragraph 50002000-ESC-ARCHIVO, ejecutado por cada registro escrito). Fórmula: WKS-NUM-REG = WKS-NUM-REG + 1 (ADD 1 TO WKS-NUM-REG; contador PIC 9(08), inicia en 0) y WKS-IMP-TOT = WKS-IMP-TOT + WKS-REG-E03-IMPORTE (ADD WKS-REG-E03-IMPORTE TO WKS-IMP-TOT; acumulador PIC 9(12)V99, inicia en 0). Al cerrar (80000000-TERMINA → 20000700-GEN-TRAILER) se escribe el registro tipo "9" WKS-E03-TRAILER con WKS-NUM-REG y WKS-IMP-TOT como total de cierre del archivo. Nota técnica: WKS-REG-E03-IMPORTE es PIC 9(11)V99 (11 enteros) mientras B07-IMPORTE/B13-IMPORTE de origen son NUMBER 14,2 en el DASDL — un importe individual con más de 11 dígitos enteros se truncaría al mover al registro de detalle (riesgo estructural de bajo impacto práctico, no observado como incidente real).

**Trigger:** Por cada registro escrito en el archivo FraudLink se ejecuta ADD 1 TO WKS-NUM-REG y ADD WKS-REG-E03-IMPORTE TO WKS-IMP-TOT; al cierre del archivo se escribe el trailer tipo "9" con ambos acumuladores.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-NUM-REG` | Contador PIC 9(08) | Contador de registros escritos; se incrementa en 1 por cada registro FraudLink |
| `WKS-IMP-TOT` | Acumulador PIC 9(12)V99 | Suma total de importes reportados; se acumula por cada registro FraudLink |
| `WKS-REG-E03-IMPORTE` | Importe PIC 9(11)V99 | Importe del registro de detalle; sumado a WKS-IMP-TOT; limitado a 11 dígitos enteros |
| `WKS-E03-TRAILER` | Registro de cierre | Registro tipo "9" que contiene WKS-NUM-REG y WKS-IMP-TOT como totales de control |

**Traza de código:**
```
PROGRAMA: P103 — S500/P103 FraudLink
SECCIÓN/PÁRRAFO: 50002000-ESC-ARCHIVO (acumulación) → 80000000-TERMINA → 20000700-GEN-TRAILER (escritura trailer)
Líneas aproximadas: ~300
Tipo de sentencia: COMPUTE (implementado como ADD en el fuente)
```

**Riesgos de migración:**
- WKS-REG-E03-IMPORTE es PIC 9(11)V99 mientras los campos origen B07-IMPORTE/B13-IMPORTE son NUMBER 14,2 en DASDL; importes con más de 11 dígitos enteros se truncan silenciosamente al mover al registro de detalle — riesgo estructural identificado que debe resolverse ampliando el PIC o validando el rango de importes históricos.
- WKS-NUM-REG es PIC 9(08), con límite de 99,999,999 registros por ejecución; en escenarios de volumen extremo o reproceso acumulado podría producirse overflow; conviene verificar el volumen histórico máximo de registros diarios FraudLink.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-009 — Detección servidor de desarrollo ACYPBETA

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** El programa identifica si se ejecuta en el servidor de desarrollo (ACYPBETA) y, de ser así, omite la verificación de versión contra el catálogo central de versiones del banco; en cualquier otro servidor la verificación es obligatoria. Aunque el código conserva restos de un "modo de diagnóstico" asociado a este mismo indicador, esas líneas (los DISPLAY condicionados a WKS-ES-DES = 1, líneas 201-207 y 213-216) están comentadas — código inactivo — en la versión actual: el único efecto real del servidor de desarrollo hoy es omitir el checeo de versión. Técnicamente: en 00000000-PRINCIPAL se obtiene ATTRIBUTE HOSTNAME OF MYSELF; IF WKS-MY-HOST = "ACYPBETA. " activa WKS-ES-DES = 1 (indicador de servidor de desarrollo), consultado en la línea 260 (IF WKS-ES-DES = 0 PERFORM 20000050-CHECO-VER) para omitir la verificación solo en ese host.

**Trigger:** Si el hostname del servidor en ejecución es "ACYPBETA. ", el programa activa el indicador de entorno de desarrollo y salta la verificación obligatoria de versión contra el catálogo central.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-MY-HOST` | Alphanumeric | Hostname del servidor donde se ejecuta el programa |
| `WKS-ES-DES` | Numeric (flag) | Indicador de servidor de desarrollo (1 = desarrollo, 0 = producción) |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 00000000-PRINCIPAL
Líneas aproximadas: ~195
Tipo de sentencia: IF condicional
```

**Riesgos de migración:**
- La lógica de bypass por hostname hardcodeado ("ACYPBETA. ") debe eliminarse o reemplazarse por variable de entorno en la plataforma moderna; si se migra el condicional literalmente, una prueba en ambiente con nombre distinto nunca activará el bypass.
- Código de diagnóstico comentado (DISPLAY condicionados a WKS-ES-DES = 1) puede generar confusión: en la plataforma destino puede reactivarse accidentalmente si se hace un "uncomment" sin entender que el flag ya no existe.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-010 — Cancelación por versión de software no vigente

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** Fuera del servidor de desarrollo, el programa valida su versión contra el catálogo central antes de calcular cualquier fecha; si la versión ejecutada no es la vigente, cancela sin devolver la fecha de proceso al workflow que la solicitó (parámetro WS-VAL-FEC). Técnicamente: en 20000050-CHECO-VER (alcanzado solo si WKS-ES-DES = 0), tras PERFORM 20000100-CHECAME-VERSION, IF S000-CTR-CVEERROR < 0 se emite "VER. EJECUTADA DIF. A VERSIONES" y se cancela con CHANGE ATTRIBUTE STATUS OF MYSELF TO -1.

**Trigger:** Cuando el programa corre fuera del servidor de desarrollo y la verificación de versión detecta divergencia (S000-CTR-CVEERROR < 0), cancela la ejecución sin retornar ninguna fecha al workflow solicitante.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-ES-DES` | Numeric (flag) | Guard: solo se verifica si es 0 (producción) |
| `S000-CTR-CVEERROR` | Numeric | Código de error de verificación de versión (< 0 = fallo) |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20000050-CHECO-VER → 20000100-CHECAME-VERSION
Líneas aproximadas: ~273
Tipo de sentencia: IF condicional
```

**Riesgos de migración:**
- El mecanismo de verificación de versión depende del catálogo central Unisys ClearPath (CTLVERS / CHECAME IN CTLVERS); en la plataforma destino debe reemplazarse por un equivalente (ConfigMap, parameter store) o eliminarse si el control de versión pasa al pipeline de CI/CD.
- La cancelación vía CHANGE ATTRIBUTE STATUS OF MYSELF TO -1 es un mecanismo nativo MCP; debe traducirse al mecanismo de error/exit de la plataforma moderna para que el workflow orquestador detecte el fallo correctamente.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-011 — Selección BD04 Tarjetas vs BD01 Captación opción 3

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** Cuando el workflow solicita específicamente la opción 3 sin días de retroceso, el programa consulta la base de Tarjetas en vez de la de Captación, y retorna la fecha del último archivo de prealtas aplicado desde Tarjetas — un dato que se aplica todos los días, incluidos festivos. Cualquier otra combinación de opción/días consulta S500BD01CAPTACION (captación) en su lugar. Técnicamente: la condición IF WKS-VAL-OPCI = 3 AND WKS-VAL-DANT = 0 se evalúa dos veces — en 20001000-ABRO-BASE (línea 285) decide abrir S500BD04TARJETAS en vez de S500BD01CAPTACION; en 20002000-FECHA-PRO (línea 321) decide ejecutar 20002500-FECHA-BD04 en vez de 20002010-FECHA-BD01 — y retorna B01P-ULT-ARCHAPLI junto con B01P-NUM-CSI como nodo.

**Trigger:** Cuando opción=3 y días-retroceso=0, el programa abre la base S500BD04TARJETAS y retorna la fecha del último archivo de prealtas aplicado en lugar de consultar la base S500BD01CAPTACION.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-VAL-OPCI` | Numeric | Opción de cálculo de fecha solicitada por el workflow |
| `WKS-VAL-DANT` | Numeric | Días de retroceso solicitados |
| `B01P-ULT-ARCHAPLI` | Date | Fecha del último archivo de prealtas aplicado (BD04 Tarjetas) |
| `B01P-NUM-CSI` | Numeric | Nodo de procesamiento (retornado como nodo) |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20001000-ABRO-BASE (l.285) → 20002000-FECHA-PRO (l.321) → 20002500-FECHA-BD04
Líneas aproximadas: ~285
Tipo de sentencia: IF condicional (evaluada en dos secciones distintas)
```

**Riesgos de migración:**
- La misma condición (WKS-VAL-OPCI = 3 AND WKS-VAL-DANT = 0) se evalúa en dos puntos del código para decidir apertura de base y ruta de lectura; si en la migración se refactoriza solo uno de los dos bloques, el comportamiento queda inconsistente.
- B01P-ULT-ARCHAPLI proviene de BD04TARJETAS pero se retorna con el mismo nombre que el campo de BD01CAPTACION; verificar que el contrato de salida del servicio moderno diferencie ambas fuentes.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-012 — Cancelación por registro de control vacío o ilegible

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** Si el registro maestro de control (S500B02CONTROL) no puede leerse o está vacío, el programa no tiene forma de calcular ninguna fecha de proceso — de ahí dependen tanto la fecha de línea como el nodo — y cancela la ejecución. Técnicamente: en 20002010-FECHA-BD01, tras PERFORM 90000002-B02CONTROL-FIND, IF WS-STATUS-BASE > 0: valor 1 (registro vacío/inexistente) cancela con "ERROR REG. DE CONTROL VACIO" vía CALL SYSTEM DMTERMINATE; cualquier otro código también cancela.

**Trigger:** Si la lectura del registro maestro S500B02CONTROL falla o devuelve registro vacío (WS-STATUS-BASE > 0), el programa cancela de forma inmediata con DMTERMINATE sin retornar fecha alguna.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WS-STATUS-BASE` | Numeric | Código de estado de lectura de base (0 = OK; > 0 = error/vacío) |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20002010-FECHA-BD01 → 90000002-B02CONTROL-FIND
Líneas aproximadas: ~334
Tipo de sentencia: IF condicional
```

**Riesgos de migración:**
- CALL SYSTEM DMTERMINATE es una llamada al kernel MCP; en la plataforma moderna debe reemplazarse por un mecanismo explícito de fallo (excepción, exit code, señal al orquestador).
- S500B02CONTROL es la tabla de control central del sistema; su equivalente en la plataforma destino debe tener el mismo contrato de disponibilidad para no disparar esta ruta de cancelación en ambiente destino.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-013 — Retorno de nodo activo sin fecha con opción 31

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** Con la opción "31" (opción 3 y un día de retroceso), el programa no calcula ninguna fecha: solo informa el nodo de procesamiento activo, dejando en ceros el resto de la respuesta. Técnicamente: IF WKS-VAL-OPCI = 3 AND WKS-VAL-DANT = 1, retorna en WS-NODO-S el valor de B02-USO-FUTURO-05 — campo declarado en el DASDL como "reservado para uso futuro" (NUMBER de 2 dígitos), reutilizado operativamente para exponer el nodo de procesamiento activo — y WKS-PARAM100 se llena de ceros.

**Trigger:** Cuando opción=3 y días-retroceso=1, el programa retorna únicamente el nodo de procesamiento activo (B02-USO-FUTURO-05) sin calcular ni retornar fecha alguna.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-VAL-OPCI` | Numeric | Opción de cálculo de fecha (3 en este caso) |
| `WKS-VAL-DANT` | Numeric | Días de retroceso (1 en este caso) |
| `WS-NODO-S` | Alphanumeric | Campo de salida: nodo de procesamiento activo |
| `B02-USO-FUTURO-05` | Numeric (2) | Campo DASDL "reservado para uso futuro", reutilizado operativamente como nodo activo |
| `WKS-PARAM100` | Alphanumeric | Parámetro de salida principal (llenado a ceros en esta opción) |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20002000-FECHA-PRO (rama opción 3 + DANT=1)
Líneas aproximadas: ~346
Tipo de sentencia: IF condicional
```

**Riesgos de migración:**
- B02-USO-FUTURO-05 está documentado en el DASDL como campo reservado pero se usa en producción como nodo activo; en la migración este campo debe ser renombrado y documentado explícitamente en el modelo de datos destino para evitar que sea eliminado por "inutilizado".
- La combinación de parámetros (opci=3, dant=1) como código para "consultar nodo" es un protocolo implícito no documentado formalmente; el API moderno debe exponer esto como un endpoint o parámetro explícito.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-014 — Fallback a fecha de línea por parámetros inválidos

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** Si el workflow solicitante envía una combinación de parámetros inválida — opción y días de retroceso a la vez, o la opción 3 con más de un día de retroceso — el programa no intenta interpretar la intención: simplemente devuelve la fecha de línea tal cual, sin ninguna proyección. Técnicamente: IF (WKS-VAL-OPCI > 0 AND WKS-VAL-DANT > 0) OR (WKS-VAL-OPCI = 3 AND WKS-VAL-DANT > 1), se ejecuta 20002600-FEC-LINEA y retorna B02-FECHA-LINEA directamente.

**Trigger:** Cuando el workflow envía una combinación inválida de opción y días de retroceso, el programa retorna silenciosamente la fecha de línea sin proyección ni mensaje de error al caller.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-VAL-OPCI` | Numeric | Opción de cálculo solicitada |
| `WKS-VAL-DANT` | Numeric | Días de retroceso solicitados |
| `B02-FECHA-LINEA` | Date (AMD) | Fecha de línea operativa del sistema (retornada como fallback) |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20002000-FECHA-PRO → 20002600-FEC-LINEA
Líneas aproximadas: ~352
Tipo de sentencia: IF condicional (OR compuesto)
```

**Riesgos de migración:**
- El fallback silencioso (sin mensaje de error) puede enmascarar errores de integración en el workflow caller; en la plataforma moderna se recomienda retornar un código de advertencia o lanzar excepción para parámetros inválidos.
- Cualquier workflow que "accidentalmente" envíe opción + días juntos recibirá una fecha válida (la de línea), lo que puede llevar a que el error de parámetros nunca sea detectado en producción.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-015 — Captura y validación manual de fecha opción 5

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** La opción 5 permite capturar una fecha manualmente en vez de calcularla: el programa la solicita por teclado y la valida (año entre 1989-2999, mes 1-12, día 1-31); si es inválida, muestra "LA FECHA ESTA MAL TECLEADA" y vuelve a pedirla hasta que el operador ingrese una fecha correcta. La fecha capturada se proyecta después con la misma lógica que las demás opciones (20002200-PROY-FEC). Técnicamente: 20002100-PIDO-FECHA usa ACCEPT FECHA y evalúa IF DIAOK AND MESOK AND ANOOK (niveles 88: AANO 1989-2999, MMES 1-12, DDIA 1-31); si es válida, WS-1VEZ = 1 termina el PERFORM ... UNTIL (línea 375-376).

**Trigger:** Cuando opción=5, el programa entra en un bucle interactivo solicitando al operador una fecha por teclado hasta recibir una fecha con año 1989-2999, mes 1-12 y día 1-31 válidos.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-VAL-OPCI` | Numeric | Opción solicitada (5 en este caso) |
| `WS-1VEZ` | Numeric (flag) | Indicador de fecha válida capturada; controla el PERFORM UNTIL |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20002100-PIDO-FECHA (invocado desde 20002200-PROY-FEC)
Líneas aproximadas: ~419
Tipo de sentencia: IF condicional con PERFORM UNTIL (bucle de validación)
```

**Riesgos de migración:**
- La opción 5 usa ACCEPT (interacción con terminal MCP); en una plataforma moderna batch/API esta funcionalidad no tiene equivalente directo — debe reemplazarse por un parámetro de entrada explícito o un endpoint de override de fecha.
- La validación de día 1-31 (nivel 88 DDIA) no valida días inválidos por mes (ej. 31 de febrero); este mismo riesgo existe en la plataforma destino si se reimplementa sin calendario real.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-016 — Consulta indicador campaña Teletón opción 9

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** La opción 9 no calcula ninguna fecha: se usa para consultar si la campaña Teletón está activa, reutilizando el mismo campo de salida que normalmente lleva la fecha calculada para transportar ese indicador, junto con el nodo de procesamiento. Técnicamente: IF WKS-VAL-OPCI = 9, se limpia WKS-PARAM100 y se mueve B02-ACT-TELETON (campo DASDL "Activación de campaña Teletón") al campo de salida WS-FEC-CALCULADA-AMD, junto con B02-NUM-CSI como nodo en WS-NODO-S.

**Trigger:** Cuando opción=9, el programa retorna el indicador de activación de campaña Teletón (B02-ACT-TELETON) en el campo de salida de fecha, reutilizando el contrato de respuesta estándar para un propósito no relacionado con fechas.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-VAL-OPCI` | Numeric | Opción solicitada (9 en este caso) |
| `WKS-PARAM100` | Alphanumeric | Parámetro de salida principal (limpiado a ceros) |
| `B02-ACT-TELETON` | Alphanumeric/Numeric | Indicador de campaña Teletón activa (campo de S500B02CONTROL) |
| `WS-FEC-CALCULADA-AMD` | Alphanumeric | Campo de salida de fecha, reutilizado para transportar el indicador Teletón |
| `B02-NUM-CSI` | Numeric | Nodo de procesamiento activo |
| `WS-NODO-S` | Alphanumeric | Campo de salida del nodo |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20002000-FECHA-PRO (rama opción 9)
Líneas aproximadas: ~367
Tipo de sentencia: IF condicional
```

**Riesgos de migración:**
- La reutilización del campo de fecha (WS-FEC-CALCULADA-AMD) para transportar un indicador de campaña es un acoplamiento implícito de propósito; el caller debe saber que cuando envía opción=9 el campo no contiene una fecha — en la plataforma moderna esto debe ser un campo o endpoint separado.
- B02-ACT-TELETON es un campo de uso específico de negocio almacenado en el registro de control central; en la migración debe identificarse si sigue siendo necesario y cómo se actualiza.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-017 — Cálculo de último día del mes anterior opción 6

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** La opción 6 calcula el último día del mes anterior a la fecha de línea — útil para procesos de cierre o corte mensual que necesitan referenciar el mes previo completo. Fórmula exacta: partiendo de WS-FEC-DIAMES = B02-FECHA-LINEA, se retrocede un mes (IF WS-FDM-MM = 1 → WS-FDM-MM = 12 y SUBTRACT 1 FROM WS-FDM-AAAA; ELSE SUBTRACT 1 FROM WS-FDM-MM). Luego WS-FDM-DD = WS-T-DIAS-X-MES(WS-FDM-MM), tabla fija de 12 posiciones (31,28,31,30,31,30,31,31,30,31,30,31). Si el mes resultante es 2 (febrero): DIVIDE WS-FDM-AAAA BY 4 GIVING WS-COCIENTE-BI REMAINDER WS-RESIDUO-BI; IF WS-RESIDUO-BI = 0 → WS-FDM-DD = 29 (sustituye el 28 por defecto de la tabla). Resultado: WS-FEC-CALCULADA-AMD = WS-FEC-DIAMES. Hallazgo: el criterio de bisiesto implementado es "divisible entre 4" puro — no aplica la excepción gregoriana de siglo (no bisiesto si divisible entre 100 y no entre 400); dado que el nivel 88 ANOOK permite años 1989-2999, el año 2100 se calcularía incorrectamente como bisiesto (WS-FDM-DD=29 cuando el calendario gregoriano real indica 28). Despachada desde el IF WKS-VAL-OPCI = 6 hacia 20002300-FEC-ULTDIAMES, con la aritmética resuelta en líneas 466-476.

**Trigger:** Cuando opción=6, el programa calcula el último día del mes anterior a la fecha de línea usando una tabla fija de días por mes con ajuste de año bisiesto (divisible entre 4, sin excepción de siglo).

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WS-FEC-DIAMES` | Date (AMD) | Fecha de trabajo, inicializada con B02-FECHA-LINEA |
| `WS-FDM-MM` | Numeric (2) | Componente mes de la fecha de trabajo (decrementado) |
| `WS-FDM-AAAA` | Numeric (4) | Componente año de la fecha de trabajo (decrementado si mes=1) |
| `WS-FDM-DD` | Numeric (2) | Componente día calculado (último día del mes anterior) |
| `WS-T-DIAS-X-MES` | Numeric array (12) | Tabla fija de días por mes (31,28,31,30,31,30,31,31,30,31,30,31) |
| `WS-COCIENTE-BI` | Numeric | Cociente de la división del año entre 4 (cálculo de bisiesto) |
| `WS-RESIDUO-BI` | Numeric | Residuo de la división del año entre 4 (0 = bisiesto) |
| `WS-FEC-CALCULADA-AMD` | Date (AMD) | Fecha resultado de salida |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20002300-FEC-ULTDIAMES (líneas 466-476)
Líneas aproximadas: ~472
Tipo de sentencia: COMPUTE aritmético / IF condicional / DIVIDE
```

**Riesgos de migración:**
- Bug conocido: el criterio de bisiesto no aplica la excepción gregoriana de siglo; el año 2100 se calculará como bisiesto (29 días en febrero) cuando el calendario gregoriano real indica 28. Debe corregirse en la migración.
- La tabla WS-T-DIAS-X-MES es un arreglo estático hardcodeado; en la plataforma destino puede reemplazarse por una función de calendario estándar, eliminando el mantenimiento manual del arreglo.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-018 — Cancelación por fallo de acceso a librería LOCSUP

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** El cálculo de fechas proyectadas depende de una librería externa de calendario bancario (S006LOCSUP), que resuelve la resta de días naturales o hábiles sobre la fecha de línea; si esa librería no puede accesarse, el proceso cancela en vez de devolver una fecha potencialmente incorrecta. Técnicamente: en 40000000-CALL-FECPRO (invocado desde 20002200-PROY-FEC), tras PERFORM 20000006-LOCSUP, IF WS-S006-FUNCION > 0 se arma "ERROR AL ACCESAR LOCSUP" con WS-MSG-RS y se cancela vía CALL SYSTEM DMTERMINATE.

**Trigger:** Si la librería externa S006LOCSUP no es accesible (WS-S006-FUNCION > 0 tras la llamada), el programa cancela con DMTERMINATE en lugar de retornar una fecha de proyección incorrecta.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WS-S006-FUNCION` | Numeric | Código de resultado de la llamada a LOCSUP (> 0 = error de acceso) |
| `WS-MSG-RS` | Alphanumeric | Mensaje de error armado antes de la cancelación |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 40000000-CALL-FECPRO → 20000006-LOCSUP (invocado desde 20002200-PROY-FEC)
Líneas aproximadas: ~533
Tipo de sentencia: IF condicional
```

**Riesgos de migración:**
- S006LOCSUP es una librería de calendario bancario Unisys ClearPath; su equivalente en la plataforma moderna debe ser identificado y la interfaz de llamada (WS-S006-FUNCION, WS-S006-FORMATO, WS-S006-FECHA1/2) debe mapearse al contrato del servicio de calendario sustituto.
- CALL SYSTEM DMTERMINATE debe reemplazarse por un mecanismo de excepción moderno; el workflow caller debe recibir un código de error que le permita reintentar o escalar.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-019 — Retorno del primer día del mes opción 7

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** La opción 7 retorna el primer día calendario del mes de la fecha de línea (año/mes de la fecha de línea, día forzado a 01), tal como documenta el comentario fuente del programa ("SE REGRESA LA FECHA... PRIMER DIA CALENDARIO DEL MES DE LA FECHA DE LINEA"). Técnicamente: PERFORM 20002400-FEC-1ERDIAMES (MOVE 1 TO WS-FDM-DD). Nota de alcance: no hay evidencia en comentarios ni en la lógica del programa de que esta opción esté ligada específicamente a procesos de corte mensual de captación; esa asociación no se confirma como hecho verificado.

**Trigger:** Cuando opción=7, el programa fuerza el componente día a 01 sobre el año/mes de la fecha de línea y retorna esa fecha como el primer día calendario del mes.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-VAL-OPCI` | Numeric | Opción solicitada (7 en este caso) |
| `WS-FDM-DD` | Numeric (2) | Componente día forzado a 01 |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20002400-FEC-1ERDIAMES
Líneas aproximadas: ~386
Tipo de sentencia: IF condicional / MOVE
```

**Riesgos de migración:**
- La lógica es simple (día=01 del año/mes de la fecha de línea) pero el comentario fuente no la asocia a ningún proceso específico de negocio; en la migración debe validarse con el SME cuál es el uso real antes de simplificarla o eliminarla.
- Si en la plataforma destino la fecha de línea tiene huso horario o representación diferente (DateTime vs. Date), forzar día=01 puede producir resultados inesperados en meses con cambio de horario.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-020 — Retorno de fecha de línea sin proyección opción 8

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** La opción 8 devuelve la fecha de línea (la fecha operativa "en línea" del sistema) tal cual, sin ninguna proyección, junto con el nodo de procesamiento. No debe confundirse con la fecha de lote (batch): ambas son campos distintos dentro del mismo registro de control S500B02CONTROL (B02-FECHA-LINEA vs. B02-FECHA-LOTE), y esta opción específicamente entrega la de línea, no la de lote. Técnicamente: PERFORM 20002600-FEC-LINEA retorna B02-FECHA-LINEA junto con B02-NUM-CSI.

**Trigger:** Cuando opción=8, el programa retorna la fecha de línea operativa (B02-FECHA-LINEA) del registro de control S500B02CONTROL sin aplicar ninguna proyección, junto con el nodo de procesamiento activo.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-VAL-OPCI` | Numeric | Opción solicitada (8 en este caso) |
| `B02-FECHA-LINEA` | Date (AMD) | Fecha de línea operativa del sistema (campo de S500B02CONTROL) |
| `B02-FECHA-LOTE` | Date (AMD) | Fecha de lote batch (campo distinto en S500B02CONTROL; no retornado en esta opción) |
| `B02-NUM-CSI` | Numeric | Nodo de procesamiento activo |
| `WS-NODO-S` | Alphanumeric | Campo de salida del nodo |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20002600-FEC-LINEA
Líneas aproximadas: ~391
Tipo de sentencia: IF condicional / PERFORM
```

**Riesgos de migración:**
- La distinción entre fecha de línea (B02-FECHA-LINEA) y fecha de lote (B02-FECHA-LOTE) es crítica; en la plataforma moderna ambas deben estar disponibles como atributos separados del contexto de ejecución para evitar confusiones en los consumers.
- Si el registro S500B02CONTROL se reemplaza por una fuente de fecha centralizada en la plataforma destino, debe garantizarse que tanto la fecha de línea como la de lote estén disponibles con la misma semántica.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-021 — Proyección por defecto de fecha hacia atrás

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P100 |
| **Confianza** | alta |

**Descripción:** Esta es la ruta de cálculo por defecto del programa: cuando el workflow solicitante no pide una opción especial (o pide las opciones 0, 1, 2 o 4), el programa proyecta la fecha de línea hacia atrás un número de días que depende de la opción recibida, usando la misma librería externa de calendario bancario. Fórmula: WS-S006-FECHA2 (días a proyectar hacia atrás desde B02-FECHA-LINEA) = WKS-VAL-DANT si WKS-VAL-DANT > 0; si no, = 1 si WKS-VAL-OPCI = 1; en cualquier otro caso (opciones 0, 2, 4) = 2. Con WS-S006-FORMATO = 12 y WS-S006-FUNCION = 15 se invoca la librería externa S006LOCSUP (vía 40000000-CALL-FECPRO) para restar esos días a B02-FECHA-LINEA; el resultado regresa en WS-S006-FECHA1 → WS-FEC-CALCULADA-AMD. Si WKS-VAL-OPCI = 5, este resultado se descarta y se sustituye por la fecha capturada manualmente (FECHA, vía 20002100-PIDO-FECHA). Técnicamente, esta ruta se resuelve en 20002200-PROY-FEC (invocada por la opción 0 sin parámetros, las opciones 1/2/4, y cualquier opción "01"-"09").

**Trigger:** Para las opciones 0/1/2/4 (y opción 5 como override), el programa proyecta la fecha de línea hacia atrás 1 o 2 días hábiles/naturales usando S006LOCSUP con función 15, siendo 2 días el valor por defecto cuando no se especifica retroceso explícito.

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-VAL-OPCI` | Numeric | Opción solicitada (0,1,2,4,5 en esta ruta) |
| `WKS-VAL-DANT` | Numeric | Días de retroceso explícitos (si > 0 prevalece sobre el default) |
| `WS-S006-FECHA2` | Numeric | Días a proyectar hacia atrás (entrada a S006LOCSUP) |
| `WS-S006-FORMATO` | Numeric | Formato de fecha (12 = AMD) |
| `WS-S006-FUNCION` | Numeric | Código de función LOCSUP (15 = proyección de días) |
| `B02-FECHA-LINEA` | Date (AMD) | Fecha de línea operativa (punto de partida de la proyección) |
| `WS-S006-FECHA1` | Date (AMD) | Fecha resultado retornada por S006LOCSUP |
| `WS-FEC-CALCULADA-AMD` | Date (AMD) | Campo de salida final (recibe WS-S006-FECHA1 o la fecha manual de opción 5) |

**Traza de código:**
```
PROGRAMA: P100 — S500/P100 Fecha-de-Proceso
SECCIÓN/PÁRRAFO: 20002200-PROY-FEC → 40000000-CALL-FECPRO
Líneas aproximadas: ~443
Tipo de sentencia: COMPUTE aritmético / IF condicional / CALL
```

**Riesgos de migración:**
- La función 15 de S006LOCSUP (WS-S006-FUNCION = 15) es el contrato de integración clave; el servicio de calendario sustituto debe implementar exactamente la misma semántica de "restar N días hábiles/naturales" para producir fechas equivalentes.
- El default implícito de 2 días (opciones 0/2/4 sin WKS-VAL-DANT explícito) es una regla de negocio oculta en la lógica de la fórmula; debe documentarse explícitamente en el API de la plataforma moderna para evitar que los consumers asuman el valor sin conocerlo.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-022 — Validación de versión sin corte de ejecución

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P075 |
| **Confianza** | alta |

**Descripción:** Al arrancar, el programa valida contra el catálogo central de versiones del banco (CHECAME IN CTLVERS, PERFORM 20000100-CHECAME-VERSION) que su propia versión de software (identificada como "S500P075", versión "25MTP003") sigue vigente y autorizada para ejecutarse. Si la validación falla (S000-CTR-CVEERROR negativo), registra el mensaje "ERROR DE VERSION" y marca el estatus de terminación del programa como fallido (CHANGE ATTRIBUTE STATUS OF MYSELF = -1) — pero esta marca de error NO detiene el flujo: no hay STOP RUN ni salto de párrafo asociado, así que el programa continúa de inmediato con la resolución de la librería central L080 (PERFORM 100000-L080), la cual reinicia el indicador de error a cero y evalúa de forma independiente su propia llamada (DAME_TIT). En consecuencia, un fallo de versión aquí deja el estatus final del run marcado como error, pero por sí solo no impide que se intente la notificación de cambio de día a P080 (ver regla línea 160).

**Trigger:** El programa arranca e invoca CHECAME IN CTLVERS para validar que la versión "S500P075"/"25MTP003" sigue autorizada.

**Traza de código:**
```
PROGRAMA: P075 — S500/P075 Cambio-de-Dia
Líneas aproximadas: ~154
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La marca de error en el estatus no corta la ejecución; en migración, si se introduce un guard explícito post-validación, el comportamiento observable cambiará y P080 ya no recibirá la notificación de cambio de día aunque la versión sea inválida.
- El reinicio del indicador S000-CTR-CVEERROR a cero dentro de L080 oculta el error de versión para el resto del flujo; el componente moderno debe preservar este estado de forma explícita si se requiere auditoría.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-023 — Notificación de cierre condicional a L080 y parámetro

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P075 |
| **Confianza** | alta |

**Descripción:** El aviso de cierre del día bancario hacia el procesador central (PERFORM 200000-INIBATCH) solo se dispara si se cumplen dos condiciones anidadas: que la resolución de la librería central L080 haya sido exitosa (S000-CTR-CVEERROR = 0, ver regla línea 177) y, dentro de esa rama, que el parámetro recibido en la ejecución (W77-PARAM-WFL, RECEIVED BY CONTENT) sea exactamente 1. Si la librería se resolvió bien pero ese parámetro no es 1, el programa arma el mensaje "VALUE ERRONEO PARA EJECUTAR P075 <valor>" con el valor recibido (WS-MSG-N-04), lo registra (70000050-MENSAJE) y marca su estatus de terminación como fallido; en ambos casos el programa termina con el mismo STOP RUN final (línea 169), ya que no existe una ruta de cancelación anticipada distinta entre ellos.

**Trigger:** Tras resolver L080 exitosamente, el programa evalúa W77-PARAM-WFL = 1 para decidir si invocar INIBATCH o registrar error de parámetro.

**Traza de código:**
```
PROGRAMA: P075 — S500/P075 Cambio-de-Dia
Líneas aproximadas: ~160
Tipo de sentencia: IF
```

**Riesgos de migración:**
- El parámetro W77-PARAM-WFL se recibe por contenido (RECEIVED BY CONTENT) desde el WFL/JCL; en migración, el mecanismo de paso de parámetros debe preservar el valor exacto 1 o el proceso de cierre del día quedará inhibido sin alarma obvia en el orquestador.
- La doble condición anidada (éxito de L080 AND parámetro = 1) puede colapsarse incorrectamente en una sola guarda durante la transpilación; ambas ramas de error deben mantenerse separadas.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-024 — Resolución dinámica de L080 con falla silenciosa

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P075 |
| **Confianza** | alta |

**Descripción:** Antes de avisar el cierre del día bancario, el programa necesita ubicar la versión física correcta y vigente del procesador central (librería lógica "S500L080CTRL", S000-CTR-LIBID), y la resuelve dinámicamente contra el catálogo central de versiones (DAME_TIT IN CTLVERS, PERFORM 20000100-DAME-TIT-VERS), aplicando el título resuelto con CHANGE ATTRIBUTE TITLE OF "S500L080CTRL" para que la llamada posterior a INIBATCH (línea 195) apunte a la versión correcta. Si esta resolución falla (S000-CTR-CVEERROR distinto de 0), el programa registra el mensaje "ERROR EN CALL CTLVERS S500L080 RESULT=<código>", pero SIN marcar el estatus de terminación como fallido. El efecto práctico es silencioso: al fallar la resolución, la condición de la regla anterior (línea 160) queda en falso y el programa omite el aviso de cambio de día a P080, terminando por STOP RUN sin notificarlo y sin ninguna señal de error en el estatus de salida del programa.

**Trigger:** El programa invoca DAME_TIT IN CTLVERS para resolver el título físico de S500L080CTRL antes de llamar a INIBATCH.

**Traza de código:**
```
PROGRAMA: P075 — S500/P075 Cambio-de-Dia
Líneas aproximadas: ~177
Tipo de sentencia: CALL
```

**Riesgos de migración:**
- La falla de resolución no produce estatus de error en el run; en migración, si no se instrumenta esta ruta explícitamente, un fallo en la resolución del servicio equivalente a L080 pasará completamente desapercibido en el orquestador moderno.
- El mecanismo CHANGE ATTRIBUTE TITLE (resolución dinámica de librería en MCP/Unisys) no tiene equivalente directo en Java/cloud; debe reemplazarse con service discovery o configuración externalizada con la misma semántica de versionado.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-025 — Llamada INIBATCH notifica cierre del día bancario

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P075 |
| **Confianza** | alta |

**Descripción:** Este es el paso que efectivamente notifica al procesador central que el día bancario concluyó: el programa invoca el entry point de inicialización de lote (INIBATCH) de la librería central L080 (resuelta dinámicamente en el paso anterior, línea 177) mediante CALL "S500L080INIBATCHP080 IN S500L080CTRL" GIVING WKS-L080-RESULT (párrafo 205000-INIBATCH-CALL). El código de resultado queda en WKS-L080-RESULT y se evalúa de inmediato al retornar de esta llamada (ver regla línea 189).

**Trigger:** Una vez que L080 está resuelta y el parámetro es válido, el programa ejecuta CALL "S500L080INIBATCHP080 IN S500L080CTRL" para señalizar el cierre del día a P080.

**Traza de código:**
```
PROGRAMA: P075 — S500/P075 Cambio-de-Dia
Líneas aproximadas: ~195
Tipo de sentencia: CALL
```

**Riesgos de migración:**
- El nombre hardcoded "S500L080INIBATCHP080 IN S500L080CTRL" identifica simultáneamente el entry point y la librería contenedora; en migración, ambos deben mapearse al servicio moderno equivalente y el contrato del resultado WKS-L080-RESULT debe preservarse.
- La evaluación del resultado ocurre en el párrafo siguiente (regla RN-S500-026); si el flujo se reorganiza, la evaluación debe mantenerse inmediatamente post-CALL para no alterar la lógica de error.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-026 — Falla INIBATCH marca estatus de error visible

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | CONTROL-PROCESO |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P075 |
| **Confianza** | alta |

**Descripción:** Si el procesador central rechaza o falla al reconocer el cierre del día bancario (WKS-L080-RESULT > 0 tras el llamado a INIBATCH), el programa registra el mensaje "ERROR EN LLAMADO INIBATCH" (70000050-MENSAJE) y marca su estatus de terminación como fallido (CHANGE ATTRIBUTE STATUS OF MYSELF = -1). A diferencia de la validación de versión (línea 154), aquí sí hay consecuencia real: esta es la última acción antes de retornar al módulo de control (000000-MODULO-DE-CONTROL), cuya única instrucción restante es el STOP RUN final — es decir, el run sí termina con estatus de fallo visible, señalando correctamente que el procesador central no reconoció el cierre del día bancario.

**Trigger:** Al retornar de la llamada a INIBATCH, el programa evalúa WKS-L080-RESULT > 0 para determinar si el procesador central confirmó el cierre del día.

**Traza de código:**
```
PROGRAMA: P075 — S500/P075 Cambio-de-Dia
Líneas aproximadas: ~189
Tipo de sentencia: IF
```

**Riesgos de migración:**
- El estatus de fallo se propaga al orquestador (WFL/scheduler) mediante CHANGE ATTRIBUTE STATUS OF MYSELF = -1 seguido de STOP RUN; en migración, el componente moderno debe retornar un exit code no cero equivalente para que el orquestador cloud detecte el fallo y no avance al siguiente paso del batch.
- A diferencia de RN-S500-022, aquí la marca de error sí es operacionalmente significativa; cualquier simplificación del manejo de errores que iguale ambas rutas producirá pérdida de visibilidad sobre fallos reales del cierre de día.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-027 — Clasificación de servidor productivo o de prueba

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** Al arrancar, el programa determina si se está ejecutando en un servidor productivo o de prueba del banco, obteniendo el nombre del servidor (ATTRIBUTE HOSTNAME OF MYSELF, WKS-MY-HOST) y comparándolo contra dos listas cerradas de nombres exactos: "VDMALFA." o "MONBETA." se clasifican como producción (W77-ES-PRODUCCION); "VDMBETA.", "ACYPGAMA.", "ACYPBETA.", "MONALFA." o "ACYPOMEGA." se clasifican como prueba (W77-ES-PRUEBA), y específicamente "ACYPBETA." se marca además como prueba interna (W77-ES-PBA-INTERNA — el nombre de campo es "PBA-INTERNA", de PRUEBA, no "desarrollo interno"). Esta clasificación es la que gobierna el intento de bloqueo de producción evaluado en la siguiente regla (línea 304).

**Trigger:** Al arrancar el proceso batch, el programa lee el nombre del servidor (ATTRIBUTE HOSTNAME) y lo compara contra siete nombres exactos conocidos para clasificar el ambiente como producción, prueba o prueba interna.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~291
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La lista cerrada de hostnames puede quedar desactualizada si se incorporan nuevos nodos al banco; una ejecución en host no contemplado clasifica el ambiente de forma incorrecta sin advertencia alguna.
- La lógica de clasificación de ambiente debe reemplazarse por un mecanismo basado en parámetro externo o variable de entorno, no en hardcoding de nombres de servidor.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-028 — Bloqueo de producción sin corte de ejecución real

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** El programa detecta si se ejecuta en un servidor productivo del banco (indicador W77-ES-PRODUCCION) y, de ser así, arma el mensaje de error "NO CORRE EN PRODUCCION; HOST: <hostname>", lo registra (70000050-MENSAJE) y marca su estatus de terminación como fallido (CHANGE ATTRIBUTE STATUS OF MYSELF = -1). Sin embargo, esta señal de error NO detiene la ejecución: la instrucción no incluye STOP RUN ni GOBACK, y el párrafo no tiene una ruta de salida anticipada, por lo que el programa continúa incondicionalmente, abre la base de datos productiva y ejecuta el enmascaramiento de nombres y domicilios de titulares (B03CONTRATOS/B37GRUPOCPE/B39CTASCPE) igual que en cualquier otro ambiente. En la práctica, el único control real de "no correr en producción" es que el job/WFL no programe este proceso en los servidores productivos (VDMALFA o MONBETA) — el código en sí no tiene un corte de ejecución que lo impida.

**Trigger:** Si el indicador W77-ES-PRODUCCION está activo, el programa genera un mensaje de error y marca estatus fallido, pero no ejecuta STOP RUN ni GOBACK, por lo que el enmascaramiento de datos continúa incondicionalmente sobre la base productiva.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~304
Tipo de sentencia: IF
```

**Riesgos de migración:**
- El control de ambiente es inefectivo en el código fuente; el servicio equivalente en la plataforma destino debe implementar un mecanismo real de corte (exception/exit) ante ejecución en producción, no solo una señal de error ignorada.
- Una refactorización directa que replique el patrón original reproduciría el defecto de seguridad si el desarrollador interpreta el mensaje de error como un control efectivo sin analizar el flujo completo.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-029 — Tamaño de bloque variable según hora de arranque

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** El tamaño del bloque de contratos que se intercambiarán entre sí en cada ciclo de enmascaramiento no es fijo: se calcula a partir de la hora exacta de arranque del proceso batch (ACCEPT WKS-TIME-MAQ FROM TIME, línea 286), precisamente para que el tamaño de bloque no sea predecible entre corridas. Fórmula exacta: si el host es "ACYPBETA." (ambiente de prueba interna), `W77-CONTA-01 = 200 - WKS-TIME-HH - WKS-TIME-MM - WKS-TIME-SS`; en cualquier otro host (VDMBETA, ACYPGAMA, MONALFA, ACYPOMEGA, o cualquier hostname no reconocido — la rama ELSE no tiene condición adicional), `W77-CONTA-01 = 1800 - WKS-TIME-HH - WKS-TIME-MM - WKS-TIME-SS`, donde WKS-TIME-HH/MM/SS son la hora, minuto y segundo del reloj del sistema al arrancar el batch. El resultado (W77-CONTA-01, PIC 9(06)) se ajusta después a un número par (ver regla línea 327): si el residuo de dividirlo entre 2 no es cero, se le resta 1.

**Trigger:** Al iniciar cada corrida, el programa captura la hora exacta del sistema (ACCEPT FROM TIME) y aplica una fórmula diferenciada por hostname que produce un tamaño de bloque de intercambio distinto en cada ejecución.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~321
Tipo de sentencia: COMPUTE
```

**Riesgos de migración:**
- El tamaño de bloque variable según hora de arranque dificulta reproducir en pruebas el comportamiento exacto de producción; la plataforma destino debe definir si este comportamiento aleatorio es un requerimiento funcional o puede reemplazarse por un parámetro fijo.
- La fórmula diferenciada por hostname (200 vs 1800) introduce dos caminos de prueba independientes que deben cubrirse explícitamente en las pruebas de equivalencia.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-030 — Ajuste de paridad par del bloque de intercambio

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** El tamaño de bloque calculado (fórmula de la regla línea 321) debe ser siempre un número par, para que el intercambio de nombres entre titulares (50002000-MODIF-NOMBRE) sea simétrico y ningún contrato quede sin nombre asignado dentro del bloque. Para garantizarlo, el programa divide W77-CONTA-01 entre 2 (DIVIDE W77-CONTA-01 BY 2 GIVING W77-TOT-DIV REMAINDER W77-DIV-RESTO); si el residuo no es cero (tamaño impar), le resta 1 (SUBTRACT 1 FROM W77-CONTA-01).

**Trigger:** Después de calcular W77-CONTA-01, el programa verifica su paridad dividiendo entre 2; si el residuo es distinto de cero, resta 1 para garantizar que todos los intercambios de nombre dentro del bloque sean simétricos.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~327
Tipo de sentencia: IF
```

**Riesgos de migración:**
- Una implementación que omita el ajuste de paridad dejará el último contrato de cada bloque sin pareja de intercambio, produciendo un campo de nombre sin modificar o en blanco en la base de datos destino.
- En lenguajes destino con semántica de división entera diferente a COBOL, el comportamiento del REMAINDER debe validarse explícitamente para confirmar equivalencia.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-031 — Reanudación del proceso desde checkpoint previo

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** El proceso de enmascaramiento puede reanudarse desde donde quedó si se interrumpió una corrida anterior, en vez de reiniciar desde cero cada vez. Para decidir esto, el programa verifica si ya existe en disco un archivo de control/checkpoint específico de esta corrida ("S500/FILE/SCRBLING/<CSI>/<fecha>.", con CSI = W77-MY-CSI tomado de B02-NUM-CSI, y fecha = B02-FECHA-LOTE). Si existe, lo abre en modo I-O, lee su registro de encabezado (20000400-LEE-ARCH) y evalúa si corresponde a una reanudación válida (20000500-REINICIO, ver regla línea 441). Si no existe, lo crea desde cero: escribe un encabezado inicial con el contador en cero (WKS-I99-HEAD-CTO = ZERO, párrafo 20000300-GEN-ARCH), lo cierra y reabre en modo I-O, y continúa el proceso como una corrida nueva, sin punto de reanudación.

**Trigger:** Al abrir el proceso de enmascaramiento, el programa busca en disco un archivo de checkpoint identificado por CSI y fecha de lote; si existe, intenta reanudar desde el contrato registrado; si no existe, crea uno nuevo y empieza desde cero.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~392
Tipo de sentencia: IF
```

**Riesgos de migración:**
- El mecanismo de checkpoint usa un nombre de archivo compuesto por CSI y fecha en formato Unisys; un cambio en el formato de estos valores durante la migración puede impedir que el archivo de reanudación sea encontrado y forzar que cada corrida empiece desde cero.
- La dependencia de un archivo físico en disco (namespace "S500/FILE/SCRBLING/...") debe migrarse a un mecanismo de persistencia equivalente en la plataforma destino (base de datos, blob storage u otro).

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-032 — Validación y restauración del estado de checkpoint

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** Para decidir si la reanudación desde el checkpoint es válida, el programa compara el encabezado leído del archivo de control (tipo de registro, identificador de nodo/CSI, fecha de proceso y contador de contrato — WKS-I99-HEAD-TPO, WKS-I99-HEAD-CSI, WKS-I99-HEAD-FEC, WKS-I99-HEAD-CTO) contra los valores de la corrida actual (CSI del nodo — W77-MY-CSI, tomado de B02-NUM-CSI — y fecha de proceso — WKS-FECHA-PROCESO, tomada de B02-FECHA-LOTE). Si coinciden y el contador de contrato es mayor a cero, el proceso retoma desde ese número de contrato (WS-NUM-CONTRATO/WS-MSG-CTO) y restaura el tamaño de bloque calculado en la corrida anterior (WKS-I99-HEAD-BLQ sobreescribe el W77-CONTA-01 recién calculado al arrancar, ver regla línea 321), buscando el punto exacto de reanudación (20000600-BUSCA-REINICIO). Si el nodo, la fecha o el contrato no coinciden, se descarta el encabezado existente y se regenera desde cero (20000300-GEN-ARCH), como corrida nueva. Adicionalmente, si al buscar el punto de reanudación el contrato correspondiente ya no se encuentra o no puede bloquearse en la tabla de contratos (B03CONTRATOS), el mecanismo de reanudación se abandona: el contador (WKS-I99-HEAD-CTO) se reinicia a cero y ambos cursores de lectura (S500B03CONTRATOS y S500B03CONTRATOSW) regresan al inicio del archivo (BEGINNING) — es decir, el proceso reanuda desde el principio en vez de fallar.

**Trigger:** Cuando se encuentra un archivo de checkpoint, el programa compara tipo, CSI, fecha y contador contra los valores de la corrida actual; si todos coinciden y el contador es mayor a cero, restaura el estado anterior incluyendo el tamaño de bloque original calculado en la corrida interrumpida.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~441
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La sobreescritura del tamaño de bloque (W77-CONTA-01) por el valor almacenado en el checkpoint puede generar comportamiento inesperado si la fórmula de cálculo cambia entre versiones del programa; la migración debe decidir explícitamente si el bloque se recalcula siempre o se restaura desde el checkpoint.
- El fallback a reinicio completo cuando el contrato no puede bloquearse en B03CONTRATOS enmascara posibles errores de integridad en la tabla; en la plataforma destino este caso debe manejarse con un error explícito en lugar de reinicio silencioso.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-033 — Enmascaramiento de último bloque con cantidad impar

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** Como el enmascaramiento de nombres funciona intercambiando el nombre de un contrato por el de otro dentro del mismo bloque, un bloque con número impar de contratos dejaría uno sin pareja. Esta lógica (50002060-VAL-REGS) resuelve ese caso, y solo aplica al ÚLTIMO bloque de la corrida — el que cierra por fin de archivo del cursor de contratos (W77-EOF-B03 = 1 en 50000200-ACT-B03) — ya que todos los bloques "completos" anteriores tienen por construcción un tamaño par (ver regla línea 327) y nunca la necesitan. En ese último bloque parcial, si el conteo de contratos leídos es impar (DIVIDE W77-LEIDOS BY 2 GIVING W77-TOT-DIV REMAINDER W77-DIV-RESTO, residuo distinto de cero), se calcula la posición central (COMPUTE W77-REG-MEDIO = W77-TOT-DIV + 1). En 50002000-MODIF-NOMBRE, al contrato en esa posición central (W77-IND-BXX = W77-REG-MEDIO) no se le asigna el nombre de otro contrato del bloque: recibe el nombre ya enmascarado (con sufijo " PRUEBA") del PRIMER contrato leído en todo el archivo (W77-NOMBRE-PTE, capturado una sola vez en 50002000-SUBE-TABLA cuando W77-TOT-LEIDOS = 1) — no un texto sintético genérico. El resto de los contratos del bloque sí reciben el nombre de otro contrato de la tabla por índice (WKS-TB-NOM-PREF), completando el intercambio normal.

**Trigger:** Al detectar fin de archivo en el cursor de contratos, el programa verifica si el último bloque tiene un número impar de contratos y, de ser así, asigna al contrato central el nombre ya enmascarado del primer contrato leído en todo el archivo en lugar del de otro contrato del bloque.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~585
Tipo de sentencia: IF
```

**Riesgos de migración:**
- El tratamiento del contrato central depende de W77-NOMBRE-PTE, un estado global capturado una sola vez al inicio del archivo; en la plataforma destino este estado debe preservarse explícitamente durante toda la corrida y no puede calcularse de nuevo al momento del último bloque.
- Si el último bloque contiene exactamente un contrato, la lógica asigna a ese único contrato el nombre del primero del archivo, generando una mezcla de datos entre registros que debe documentarse como comportamiento esperado y cubrirse en pruebas de equivalencia.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-034 — Enmascaramiento de representante y domicilio en grupos CPE

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** Para cada grupo CPE (Cuenta Pago Empresa, según el catálogo DASDL) del archivo S500B37GRUPOCPE, recorrido secuencialmente vía LOCK NEXT hasta fin de archivo (50001000-ACT-B37), el programa reemplaza el nombre del representante legal por el texto sintético "REPRESENTANTE LEGAL GRUPO <número de grupo>" (campo B37-REPRES, 36 caracteres exactos) y el domicilio por "DOMICILIO DEL GRUPO <número de grupo>" (campo B37-DOMICILIO, 30 de los 40 caracteres del campo, resto en blanco), ambos indexados por el mismo número de grupo (WS-B37-NGPO/WS-B37-DGPO) para mantener la correlación entre los dos campos sintéticos. El nombre o razón social propio del grupo (B37-NOMBRE) NO se toca — solo se enmascaran el representante legal y el domicilio.

**Trigger:** Para cada grupo CPE encontrado en S500B37GRUPOCPE, el programa sustituye el nombre del representante legal y el domicilio por valores sintéticos indexados por número de grupo, dejando intacto el nombre o razón social del grupo.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~609
Tipo de sentencia: MOVE
```

**Riesgos de migración:**
- El tamaño exacto de los campos destino (B37-REPRES 36 chars, B37-DOMICILIO 30/40 chars) debe respetarse en el esquema equivalente de la plataforma destino; diferencias de longitud producirán truncamiento o padding incorrecto en los valores sintéticos generados.
- La semántica de LOCK NEXT (lectura secuencial con bloqueo optimista) debe mapearse al mecanismo de cursor equivalente de la plataforma destino garantizando el mismo orden de procesamiento.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-035 — Consistencia de nombre enmascarado en cuentas CPE

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** Para cada cuenta CPE (S500B39CTASCPE, procesadas en 50002100-NOMB-B39), el programa busca el contrato de captación vinculado a esa cuenta (B39-CONTRATO) dentro de los contratos ya procesados en B03CONTRATOS (90000003-B03SXCTOW-FIND). Si lo encuentra (W77-NO-B03 = 0), copia el nombre YA enmascarado de ese contrato hacia la cuenta CPE (MOVE B03-NOMBRE OF S500B03CONTRATOSW TO B39-NOMBRE), garantizando que el nombre de la cuenta sea consistente con el de su contrato vinculado. Si no lo encuentra, genera un nombre sintético secuencial en su lugar: incrementa un contador (W77-SEQ-NOMB, arranca en 10000, incrementa de 12 en 12) y construye el nombre como "NOMBRE DE PRUEBA <secuencia>", evitando dejar el campo en blanco. Este procesamiento ocurre después de haber terminado B03 y B37, en ese orden (50000000-PROCESOS), precisamente para que el nombre de B03 ya esté enmascarado cuando B39 lo copia.

**Trigger:** Al procesar cada cuenta CPE de S500B39CTASCPE, el programa busca el contrato vinculado en los contratos ya enmascarados de B03CONTRATOS para copiar su nombre; si no lo encuentra, genera un nombre sintético secuencial con contador incremental para no dejar el campo en blanco.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~631
Tipo de sentencia: IF
```

**Riesgos de migración:**
- El contador secuencial W77-SEQ-NOMB (arranca en 10000, incrementa de 12 en 12) es una variable en memoria que se reinicia en cada corrida; si la corrida se interrumpe y se reanuda desde checkpoint, las cuentas sin contrato vinculado recibirán secuencias distintas entre ejecuciones, rompiendo la consistencia entre corridas.
- La dependencia del orden de procesamiento (B03 completado antes de B37, B37 antes de B39) debe documentarse como restricción explícita del pipeline en la plataforma destino para evitar condiciones de carrera en procesamiento paralelo.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-036 — Riesgo de fail-open ante hostname no reconocido

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [SEGURIDAD] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | P655 |
| **Confianza** | alta |

**Descripción:** La lista cerrada de nombres de servidor que el programa reconoce (líneas 291-300, ver regla línea 291) no cubre toda la topología real de nodos del banco, y esto abre un riesgo de seguridad: P655 reconoce ambos nombres de los pares VDMALFA/MONBETA (producción), ACYPGAMA/MONALFA (prueba) y VDMBETA/ACYPBETA (prueba), pero NUNCA compara contra "VDMKAPPA." — el nombre pasivo del par ACYPOMEGA/VDMKAPPA. Si el programa se ejecutara en un host no contemplado en esta lista fija de 7 nombres (por ejemplo, tras un failover a VDMKAPPA, o ante un nodo nuevo), ni la clasificación de producción (W77-ES-PRODUCCION) ni la de prueba (W77-ES-PRUEBA) se activarían, y el intento de bloqueo de producción (regla línea 304 — que de por sí tampoco detiene la ejecución) nunca se dispararía siquiera: el programa trataría un host desconocido como no-productivo y continuaría el enmascaramiento de datos sin ninguna advertencia. El control de ambiente es, por diseño, una lista cerrada de nombres exactos que falla en modo abierto (fail-open) ante cualquier host no anticipado, en lugar de ser una clasificación de producción validada externamente.

**Trigger:** Cuando el programa recibe un hostname que no está en ninguna de las siete cadenas reconocidas, ninguna clasificación de ambiente se activa, el intento de bloqueo de producción no se dispara y el enmascaramiento de datos procede sin ninguna advertencia sobre el ambiente de ejecución.

**Traza de código:**
```
PROGRAMA: P655 — S500/P655 Scrambling
Líneas aproximadas: ~291
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La plataforma destino debe implementar la clasificación de ambiente mediante un mecanismo fail-closed (deny-by-default) que rechace la ejecución si el ambiente no puede verificarse positivamente, eliminando el patrón fail-open heredado del código fuente original.
- Cualquier refactorización que mantenga la lista hardcodeada de hostnames hereda el mismo defecto de seguridad y no es aceptable como solución de migración; el mecanismo debe basarse en configuración externa verificable.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-037 — Rastro de auditoría ante interrupción de proceso

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Si el proceso batch de tarjetas Teletón es interrumpido externamente (interrupción tipo HI, cambio del atributo TASKVALUE) mientras procesa un movimiento, el programa deja un rastro de auditoría antes de continuar: registra en el log de operación el número de autorización de la transacción que se estaba procesando en ese momento, permitiendo reconstruir en qué movimiento se encontraba el proceso al momento de la interrupción. Implementado en la sección declarativa INTERRUPT-SECCION (USE AS INTERRUPT PROCEDURE): deshabilita nuevas interrupciones (DISALLOW INTERRUPT), captura el nuevo valor (W77-MY-VALUE), registra la autorización (STRING "AUTORIZACION ", WKS-AUTORIZACION) y, al terminar, vuelve a habilitar interrupciones (ALLOW INTERRUPT).

**Trigger:** Cuando el proceso batch recibe una interrupción externa tipo HI durante el procesamiento de un movimiento Teletón.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~172
Tipo de sentencia: PERFORM
```

**Riesgos de migración:**
- La semántica `USE AS INTERRUPT PROCEDURE` es nativa de MCP COBOL y no tiene equivalente directo en plataformas modernas; requiere implementar un mecanismo de señal o manejo de excepciones en el runtime destino.
- Las primitivas `DISALLOW INTERRUPT` / `ALLOW INTERRUPT` son construcciones propietarias Unisys que deben reemplazarse por mecanismos de sincronización del lenguaje/runtime destino.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-038 — Validación de versión autorizada antes de procesar

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Antes de procesar cualquier movimiento de tarjeta de la campaña Teletón, el programa valida que su propia versión esté autorizada para ejecutarse, evitando que una versión no vigente procese cargos o el punteo contable. En los hosts de prueba ("ACYPBETA. " o "VDMBETA.  ") esta validación se omite y se asume estatus OK; en cualquier otro host (producción) se llama a "CHECAME IN CTLVERS" para validar el par programa/versión (W77-S000-MY-ID="S500P630", W77-S000-MY-VERSION="25MTP004") contra el catálogo central de versiones del banco (librería CTLVERS). Si el resultado es negativo, el programa se marca con estatus -1 (terminación forzada) sin procesar movimiento alguno.

**Trigger:** Al inicio del programa, antes de procesar el primer movimiento de tarjeta Teletón.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~175
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La llamada a `CTLVERS` (catálogo central de versiones del banco) es un servicio propietario MCP; debe reemplazarse por un mecanismo equivalente de gestión de versiones en la plataforma destino.
- La distinción de host por nombre (`ACYPBETA`/`VDMBETA`) para omitir la validación en pruebas está hardcodeada; debe externalizarse como variable de entorno o perfil de configuración en la nueva plataforma.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-039 — Resolución dinámica de librería de fechas CTLVERS

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** El programa resuelve en tiempo de ejecución — no de forma fija — la ubicación de la librería bancaria de cálculo de fechas que usará más adelante para obtener el día juliano de cada movimiento (párrafo 935-ARMA-REF23, llamada a DAME_DIAJUL2K, ver regla de la línea 199), lo que permite actualizar esa librería sin recompilar S500P630. Para ello llama a "DAME_TIT IN CTLVERS" con la clave "S000LIBFEC" y obtiene el título vigente (WKS-LIBVER-TITULO) del catálogo central de versiones. Si la consulta falla (WKS-LIBVER-STATUS<0), registra el error en el log y usa como respaldo la ruta fija "(S000)S000/CALCULA/FECHAS/OBJ/LIB ON PACK."; si tiene éxito, usa el título devuelto por CTLVERS.

**Trigger:** Al inicio del programa en la fase de inicialización, para determinar la librería de cálculo de fechas activa.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~176
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La resolución dinámica de librería vía `CTLVERS` es un patrón propietario MCP; en la plataforma destino debe implementarse como configuración externalizada (registro de servicios, variable de entorno, feature flag).
- La ruta de respaldo hardcodeada `(S000)S000/CALCULA/FECHAS/OBJ/LIB ON PACK.` debe mapearse a la ubicación equivalente en la nueva plataforma, o eliminarse si el mecanismo de resolución destino garantiza disponibilidad permanente.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-040 — Etiquetado de archivo S244 como cadena Teletón

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Todo archivo de cargos que S500P630 entrega al sistema S244 queda etiquetado como proveniente de la cadena comercial Teletón, para que S244 identifique y procese correctamente su origen. El archivo (dataset I04-MOVS244) se abre en modo salida y su registro de cabecera (WKS-I04-R-00-HEADER) se graba con WKS-I04-SIST-DESTINO="S244", WKS-I04-NOM-CADENA="TELETON", WKS-I04-ORI-CADENA=00 y WKS-I04-NUM-VENTANA=01, usando la fecha de línea vigente (B00T-FEC-LINEA) como fecha de proceso.

**Trigger:** Al abrir el archivo de salida I04-MOVS244 al inicio del proceso, antes de grabar el primer registro de detalle.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~182
Tipo de sentencia: MOVE
```

**Riesgos de migración:**
- Los valores hardcodeados `WKS-I04-NOM-CADENA="TELETON"`, `WKS-I04-ORI-CADENA=00` y `WKS-I04-NUM-VENTANA=01` son constantes de negocio que deben parametrizarse en la plataforma destino para soportar futuras campañas o cadenas adicionales.
- El formato del registro de cabecera del dataset I04-MOVS244 debe documentarse como contrato de interfaz con S244 y validarse con el equipo receptor antes de la migración.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-041 — Control de lectura y terminación ante errores DMSII

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** El proceso batch de tarjetas Teletón determina cuándo dejar de leer movimientos pendientes (S500B02TMOVTOS) según tres desenlaces posibles en cada lectura: si no hay error, continúa con el siguiente movimiento; si llegó al final de los datos (NOTFOUND), concluye la lectura normalmente (W77-EOF-BASE=1); si ocurre cualquier otro error de base de datos, registra el problema en el log (999-MGS-DMSII) y fuerza la terminación del proceso (CALL SYSTEM DMTERMINATE) en vez de continuar con datos potencialmente inconsistentes. Implementado en el ciclo principal 900-LEE-B02, evaluando el estatus (W88-DB-NOTERROR / NOTFOUND / otro) tras cada PERFORM 997-S500B02TMOVTOS-FINDN.

**Trigger:** En cada iteración del ciclo principal 900-LEE-B02, tras leer un registro de la base DMSII S500B02TMOVTOS.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~189
Tipo de sentencia: IF
```

**Riesgos de migración:**
- `CALL SYSTEM DMTERMINATE` es una llamada propietaria DMSII para terminación forzada; debe reemplazarse por el mecanismo de manejo de errores fatales del ORM/conector de BD de la plataforma destino.
- La semántica `NOTFOUND` de DMSII puede diferir del comportamiento de fin de cursor en SQL; verificar el mapeo correcto para evitar bucles infinitos o terminaciones prematuras en la nueva plataforma.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-042 — Doble salida vigente hacia S244 y S151

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Cada movimiento de tarjeta vigente (estatus contable 00, según catálogo DASDL) genera dos salidas: un registro de detalle hacia el archivo S244/Teletón (PERFORM 930-GRABA-I04) y un registro de punteo contra el Libro Mayor S151 (PERFORM 960-GRABA-I08), de modo que el cargo queda reflejado tanto en la cadena comercial como en la contabilidad. Los movimientos con estatus distinto de 00 (vigente) o 15 (Amex) no generan ningún archivo de salida.

**Trigger:** En el cuerpo del ciclo principal, al evaluar el estatus contable de cada movimiento leído y encontrar estatus 00 (vigente).

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~192
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La lógica de doble salida (S244 + S151) debe preservarse íntegramente en la nueva plataforma; un refactor que consolide ambas salidas en un solo flujo puede romper la trazabilidad contable.
- El estatus contable 00 como "vigente" está definido en el catálogo DASDL; debe documentarse explícitamente en el modelo de dominio destino para evitar interpretaciones incorrectas durante la migración.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-043 — Ruta diferenciada para movimientos American Express

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Los movimientos American Express (estatus contable 15 — "no contable referido" según catálogo DASDL) se liquidan por una vía distinta a la cadena comercial Teletón: no entran al archivo S244, pero sí generan el punteo contra el Libro Mayor (PERFORM 960-GRABA-I08) y un registro en el archivo AMEXMNL que se transmite a INTELAR (PERFORM 991-ASIGNA-VALORES-DETALLE y 991-ESCRIBE-AMEXMN).

**Trigger:** En el cuerpo del ciclo principal, al evaluar el estatus contable de cada movimiento leído y encontrar estatus 15 (American Express).

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~192
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La bifurcación Amex vs. Teletón implica dos destinos de salida distintos (INTELAR vs. S244); un refactor incorrecto puede duplicar o perder registros American Express con impacto directo en conciliación.
- El archivo AMEXMNL y la integración con INTELAR son interfaces propietarias que requieren mapeo a servicios equivalentes en la plataforma destino antes de migrar.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-044 — Clasificación manual o automática por campo Base24

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Cada cargo reportado a S244 se clasifica como captura manual o automática según si el movimiento tiene o no una autorización electrónica de Base24: sin número de autorización (campo B02T-AUT-B24 en "000000" o espacios) se marca como manual (WKS-I04-TIPO-TRAN=1); con un número de autorización de Base24 válido, se marca como automática (WKS-I04-TIPO-TRAN=0). Determinado en el párrafo 930-GRABA-I04.

**Trigger:** En el párrafo 930-GRABA-I04, al armar el registro de detalle para el archivo S244 de cada movimiento vigente.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~194
Tipo de sentencia: IF
```

**Riesgos de migración:**
- La condición `B02T-AUT-B24 en "000000" o espacios` como indicador de captura manual es una convención implícita de Base24 que debe validarse con el equipo de autorización y documentarse en el modelo de dominio destino.
- `WKS-I04-TIPO-TRAN=0/1` es un indicador binario de tipo de captura; el schema del sistema S244 destino debe preservar esta semántica o documentar la equivalencia explícita.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-045 — Asignación de BIN adquirente por primer dígito

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Para los movimientos de tarjeta vigentes (no aplica a American Express, que sigue una ruta de procesamiento aparte), el BIN adquirente que se asigna a la referencia de 23 posiciones depende del primer dígito del número de tarjeta: dígitos 3 o 4 reciben el BIN 454061; cualquier otro primer dígito recibe el BIN 543006. Esta segmentación de BIN es independiente de la franquicia Amex: el párrafo que la calcula (935-ARMA-REF23, campo WKS-I04-RE-BINADQ a partir del primer dígito WKS-I04-DIG-TARJ) solo se ejecuta para movimientos con estatus contable 00, por lo que los movimientos Amex (estatus 15) nunca llegan a esta rutina — el dígito 3 aquí no identifica tarjetas Amex, sino otra segmentación de BIN dentro del universo de tarjetas vigentes.

**Trigger:** En el párrafo 935-ARMA-REF23, al construir los campos de la referencia de 23 posiciones para cada movimiento con estatus contable 00.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~197
Tipo de sentencia: IF
```

**Riesgos de migración:**
- Los BINs 454061 y 543006 están hardcodeados; deben migrarse a una tabla de parámetros configurable para soportar cambios de franquicia o incorporación de nuevos rangos de tarjetas.
- La lógica de primer dígito como proxy de franquicia es una simplificación del estándar ISO 7812 que puede quedar obsoleta con nuevos rangos de BIN; debe validarse con el equipo de adquirencia antes de la migración.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-046 — Dígito verificador tipo Luhn para referencia 23

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** La referencia de 23 posiciones que identifica cada movimiento de tarjeta Teletón (usada para trazabilidad y conciliación) incluye un dígito verificador de control, calculado con una técnica tipo Luhn módulo 10 sobre los primeros 22 dígitos de la referencia, que permite detectar errores de captura o transcripción. Fórmula exacta (párrafo 940-CALCULA-DIGITO): para cada uno de los primeros 22 dígitos (WKS-DIG-REF23(1) a WKS-DIG-REF23(22), redefinición de WKS-NUM-REF23/WKS-I04-REF-23), se calcula WKS-RS-PESO(i) = WKS-DIG-REF23(i) × peso(i), con peso(i)=1 si i es impar (1,3,...,21) y peso(i)=2 si i es par (2,4,...,22) — 22 sentencias COMPUTE independientes escritas una por una, no un loop. Cada WKS-RS-PESO(i) (rango 0-18) se redefine en dos dígitos WKS-DG1-PESO(i) (decena) y WKS-DG2-PESO(i) (unidad), y ambos se acumulan en WKS-SUMA-RS-PESO = suma de (WKS-DG1-PESO(i)+WKS-DG2-PESO(i)) para i=1..22 — equivalente a sumar los dígitos del producto cuando este es mayor o igual a 10 (ej. producto 18 aporta 1+8=9). Luego DIVIDE WKS-SUMA-RS-PESO BY 10 GIVING WKS-SUMA-RS-PESO REMAINDER WKS-REMAINDER obtiene el residuo, y COMPUTE WKS-DIGITO-CALCULADO = 10 - WKS-REMAINDER da el dígito verificador. Caso límite verificado en el fuente: si WKS-REMAINDER=0, el resultado aritmético es 10, pero WKS-DIGITO-CALCULADO es PIC 9 (un solo dígito, sin cláusula ON SIZE ERROR), por lo que el valor trunca a 0 — el dígito verificador válido cuando el residuo es cero es 0, no 10. El resultado se coloca en la posición 23 de la referencia (WKS-I04-RE-DIGVER), posición que no participa en el cálculo.

**Trigger:** En el párrafo 940-CALCULA-DIGITO, invocado desde 935-ARMA-REF23 al construir la referencia de 23 posiciones de cada movimiento vigente.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~199
Tipo de sentencia: COMPUTE
```

**Riesgos de migración:**
- Los 22 COMPUTE independientes (no un loop) son un antipatrón de rendimiento; cualquier refactor debe preservar el caso límite `WKS-REMAINDER=0 → dígito=0` (no 10), ya que PIC 9 trunca silenciosamente el valor 10 sin ON SIZE ERROR.
- Si se decide corregir el truncamiento en el caso límite, el cambio rompe la compatibilidad con todos los sistemas que validan la referencia de 23 posiciones actualmente; debe coordinarse con los equipos de conciliación y S244 antes de aplicarlo.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-047 — Día juliano en referencia Teletón vía librería bancaria

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** La referencia de 23 posiciones de cada movimiento Teletón incluye un componente de 3 dígitos de día juliano que la ubica temporalmente. Ese día juliano se obtiene convirtiendo la fecha de proceso del movimiento (B02T-FEC-MAQUINA, vía W77-LIB-FEC-IN-2K) mediante la llamada "DAME_DIAJUL2K IN FECHAS" (librería bancaria de cálculo de fechas, resuelta dinámicamente vía CTLVERS al inicio del programa — ver regla de la línea 176), y el resultado (WKS-LF-OUT-DIA) se coloca en WKS-I04-RE-DIAJUL dentro de la referencia (935-ARMA-REF23).

**Trigger:** Cada vez que se arma la referencia de 23 posiciones para un movimiento Teletón (párrafo 935-ARMA-REF23), se invoca DAME_DIAJUL2K para obtener el día juliano de la fecha de proceso.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~199
Tipo de sentencia: CALL
```

**Riesgos de migración:**
- La librería FECHAS se resuelve dinámicamente vía CTLVERS; la migración debe replicar la resolución dinámica del título y sustituir la función DAME_DIAJUL2K por un equivalente en la plataforma destino.
- El campo WKS-I04-RE-DIAJUL dentro de la referencia de 23 posiciones debe conservar exactamente 3 dígitos de día juliano para mantener la trazabilidad y conciliación.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-048 — Proceso Teletón genera solo cargos nunca abonos

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** El proceso Teletón es un mecanismo de recaudación unidireccional: únicamente genera cargos (donativos vía tarjeta) hacia el sistema S244, nunca abonos. Por eso el registro trailer del archivo S244 (970-GRABA-TRAILERS) reporta el contador y suma de cargos acumulados durante el proceso (WKS-I04-NUM-CARGOS/WKS-I04-IMP-CARGOS, acumulados de B02T-IMPORTE de cada movimiento grabado en 930-GRABA-I04), pero siempre fija en cero los campos de abonos (WKS-I04-NUM-ABONOS=0, WKS-I04-IMP-ABONOS=0).

**Trigger:** Al grabar el trailer del archivo S244 al concluir el proceso (párrafo 970-GRABA-TRAILERS), se fijan WKS-I04-NUM-ABONOS=0 y WKS-I04-IMP-ABONOS=0 sin condición.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~205
Tipo de sentencia: MOVE
```

**Riesgos de migración:**
- La fijación en cero de abonos está hardcodeada en la lógica del trailer; cualquier extensión futura que introduzca abonos requerirá cambios en la estructura del archivo S244 y en el párrafo 970-GRABA-TRAILERS.
- Al migrar, el contrato de interfaz con S244 debe preservar explícitamente la semántica unidireccional del proceso Teletón.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-049 — AMEX Teletón reportado a INTELAR con establecimiento fijo

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Todo donativo Teletón realizado con tarjeta American Express se reporta a INTELAR bajo un mismo número de establecimiento/negocio fijo, como transacción regular en moneda nacional, de crédito y sin meses sin intereses — valores fijos WKS-R00-NUM-EST=9355195968, WKS-R00-IND-MON="MNX ", WKS-R00-TIPO-TRANS="REGULAR ", WKS-R00-CUOTAS=0 y WKS-R00-TIPO-TARJ="CREDITO   ", asignados en 991-ASIGNA-VALORES-DETALLE para el registro AMEXMNL. El número de tarjeta y el importe del donativo se toman de B02T-CUENTA-TARJ y B02T-IMPORTE respectivamente, este último formateado en el subproceso 993-BUSCA-IMPORTE/993-EDITA-IMPORTE (ver regla línea 210).

**Trigger:** Al procesar cada movimiento con estatus contable 15 (Amex), se ejecuta el párrafo 991-ASIGNA-VALORES-DETALLE asignando los valores fijos del registro AMEXMNL antes de escribirlo en 991-ESCRIBE-AMEXMN.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~207
Tipo de sentencia: MOVE
```

**Riesgos de migración:**
- El número de establecimiento INTELAR (9355195968) y los atributos de transacción están hardcodeados; un cambio de contrato con AMEX requiere modificación directa del código migrado.
- El layout del registro AMEXMNL debe replicarse exactamente para que INTELAR acepte los archivos transmitidos desde la plataforma destino.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-050 — Importe AMEX formateado sin ceros con decimal explícito

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** El importe del donativo que se envía a American Express (campo WKS-R00-IMP-TRAN, 13 caracteres) debe llegar sin ceros de relleno y con punto decimal explícito, tal como lo exige el layout plano de intercambio con Amex. Para lograrlo, el importe numérico B02T-IMPORTE (PIC 9(10)V99, movido a WS-IMPORTE-N) se recorre carácter por carácter: 993-BUSCA-IMPORTE avanza el índice W77-I mientras encuentra ceros a la izquierda; 993-EDITA-IMPORTE copia los dígitos restantes a WKS-IMP-AMEX, insertando el punto decimal justo antes de la posición 11 (donde inician los 2 dígitos decimales del PIC V99).

**Trigger:** Antes de escribir cada registro AMEXMNL (párrafo 991-ESCRIBE-AMEXMN), se invoca la secuencia 993-BUSCA-IMPORTE / 993-EDITA-IMPORTE para formatear el importe.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~210
Tipo de sentencia: PERFORM
```

**Riesgos de migración:**
- La lógica de formateo es procedural artesanal (recorrido carácter a carácter); la posición del punto decimal está hardcodeada a la posición 11, dependiente del PIC 9(10)V99 exacto de B02T-IMPORTE.
- Al migrar a un lenguaje con tipos numéricos nativos, la serialización del importe debe replicar exactamente este formato para que INTELAR no rechace los archivos.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-051 — Formato de autorización en punteo según canal de origen

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** El número de autorización que se reporta al Libro Mayor en el punteo contable (WKS-I08-PUN-AUTAPL) se arma en uno de dos formatos, según el canal de origen de la transacción (B02T-TCODE-ORIG, catálogo DASDL): si el movimiento viene del código de transacción 500, se usa el formato "AUT emulador" (WKS-AUTORIZ10: prefijo de 2 + autorización de 10 dígitos); para cualquier otro código de origen, se usa el formato "AUT C218" (WKS-AUTORIZ: sucursal-trans 4 + caja-trans 2 + autorización 6 dígitos). Ambos son redefiniciones de B02T-AUTORIZA/WKS-AUTORIZACION documentadas en el catálogo DASDL. Implementado en 960-GRABA-I08.

**Trigger:** Al grabar cada registro de punteo en el Libro Mayor (párrafo 960-GRABA-I08), se evalúa B02T-TCODE-ORIG para seleccionar el formato de autorización.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~214
Tipo de sentencia: IF
```

**Riesgos de migración:**
- Las redefiniciones de campos (WKS-AUTORIZ10 / WKS-AUTORIZ) están definidas en el catálogo DASDL; al migrar, las estructuras de datos equivalentes deben replicar ambos formatos de autorización.
- La lógica de selección por B02T-TCODE-ORIG=500 es un condicional hardcodeado; un cambio en los códigos de transacción requiere actualización del código migrado.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-052 — Punteo S151 etiquetado con producto 500 y moneda MXN

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Para que el Libro Mayor (S151) pueda identificar y conciliar todos los movimientos de tarjetas de la campaña Teletón, cada registro de punteo (960-GRABA-I08) se etiqueta con producto y moneda fijos: WKS-I08-PUN-PRODUCTO=500 (producto Teletón), WKS-I08-PUN-MONEDA=1 (peso mexicano), WKS-I08-PUN-LIBRO=0 y WKS-I08-PUN-INST=1 (institución). La sucursal y caja de origen (WKS-I08-PUN-SUCINI/CAJAINI) se toman de B02T-SUC-S028/B02T-CAJ-S028 (sistema S028, catálogo DASDL) y la caja convertida (WKS-I08-PUN-CAJA-500) de B02T-CAJA-CONV.

**Trigger:** Al grabar cada registro de punteo (párrafo 960-GRABA-I08), se asignan los valores fijos de clasificación antes de escribir el registro en el Libro Mayor.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~214
Tipo de sentencia: MOVE
```

**Riesgos de migración:**
- Los valores fijos de producto (500), moneda (1), libro (0) e institución (1) están hardcodeados; la interfaz de punteo con S151 debe preservar exactamente estos valores para la conciliación del Libro Mayor.
- Los campos de sucursal y caja se toman del sistema S028 vía catálogo DASDL; la migración debe garantizar la disponibilidad de B02T-SUC-S028, B02T-CAJ-S028 y B02T-CAJA-CONV en el nuevo modelo de datos.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-053 — Transmisión AMEX a INTELAR con reintento ante falla transitoria

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** El archivo de movimientos American Express se transmite a INTELAR con un reintento automático ante fallas transitorias, sin detener el proceso batch si la transmisión no se logra. El envío (archivo identificado por WKS-TIT-I09-INTELAR, movido a WS-ID-ARCHI) se hace llamando a "INTELARSND IN ADMONXFERS" (párrafo 999-0080-CALL-INTELAR); si el resultado WS-RSLT-SNT indica error (mayor a cero), el proceso espera 3 segundos (WAIT(3)) y reintenta una sola vez; si el segundo intento también falla, se registra "NO SE ENVIO A INTELAR=>" con el nombre del archivo en el log de operación (TEXTO-LJ), pero el proceso continúa. Esta llamada solo ocurre si el proceso terminó en forma normal (W77-FIN-ANORMAL=0).

**Trigger:** Al finalizar normalmente el proceso (W77-FIN-ANORMAL=0), el párrafo 999-0080-CALL-INTELAR invoca INTELARSND para transmitir el archivo AMEX, con un reintento único tras 3 segundos de espera si falla.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~222
Tipo de sentencia: CALL
```

**Riesgos de migración:**
- El tiempo de espera (3 segundos) y el límite de un solo reintento son valores hardcodeados; la lógica best-effort (el proceso continúa aunque INTELAR falle) debe replicarse explícitamente y documentarse en la operación.
- La librería ADMONXFERS es específica del entorno Unisys MCP; la migración debe sustituir INTELARSND por un mecanismo de transferencia equivalente con la misma semántica de reintento y tolerancia a fallo.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-054 — Registro de resultado en diálogo BD06TELETON al concluir

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Al concluir, el programa deja constancia del resultado en el flujo de diálogo BD06TELETON: si terminó de forma anormal (W77-FIN-ANORMAL=1), registra "TERMINACION ANORMAL" en el log y se marca a sí mismo con estatus -1 (CHANGE ATTRIBUTE STATUS OF MYSELF TO -1); si terminó normalmente (W77-FIN-ANORMAL=0), confirma el avance del diálogo bloqueando S500B00TGLOBAL (LOCK) y actualizando B00T-PASO-ENTRA/B00T-PASO-SALE a 630 (paso de entrada/salida del flujo, catálogo DASDL, coincide con el número de programa S500P630) dentro de una transacción BEGIN/END-TRANSACTION SYNC. Implementado en el párrafo 999999-FIN.

**Trigger:** Al ejecutar el párrafo 999999-FIN, el programa evalúa W77-FIN-ANORMAL para determinar si registra terminación anormal o actualiza el paso del diálogo BD06TELETON.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~227
Tipo de sentencia: IF
```

**Riesgos de migración:**
- Las primitivas CHANGE ATTRIBUTE STATUS OF MYSELF y LOCK sobre BD06TELETON son mecanismos nativos Unisys MCP/DMSII sin equivalente directo; la migración debe reemplazarlos por un patrón de estado transaccional (flag de estado + transacción distribuida o saga pattern).
- El campo B00T-PASO-ENTRA/SALE con valor 630 es un identificador de paso en el catálogo DASDL; el mecanismo de avance del diálogo debe preservarse para mantener la integridad del flujo nocturno BD06TELETON.

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-055 — Transferencia archivos a S006 mediante job WFL heredado

| Campo | Valor |
|-------|-------|
| **Sistema** | S500 |
| **Tipo** | [LOGICA-TARJETAS] |
| **Base regulatoria** | N/A — control interno |
| **Programa(s)** | S500P630 |
| **Confianza** | alta |

**Descripción:** Si el proceso terminó normalmente, los archivos generados (S244 Teletón y AMEX) se transfieren automáticamente al host S006 mediante un job de workflow: el proceso arma WKS-LANZA-TX940 con la llave WKS-TX940-LLAVE="S501T01" y la fecha de línea (B00T-FEC-LINEA), y ejecuta CALL SYSTEM WFL para lanzar el job "BEGIN JOB S500/WFL/COPIARCH/01MTP001", que transfiere los archivos vía XFER hacia el host S006 (START (S006)S006/WFL/P940/01MTP001). La llave "S501T01" es un nombre heredado del programa origen S501/P110, previo a la migración jun-oct 2016 a S500/P630, que no se actualizó al migrar. En el host de prueba ACYPBETA se usa un código de acceso alterno (WKS-ACCESS-ACYPBETA) para esa transferencia. Implementado en 999999-TRANSFIERE-P940 (solo si W77-FIN-ANORMAL=0).

**Trigger:** Al finalizar normalmente el proceso (W77-FIN-ANORMAL=0), el párrafo 999999-TRANSFIERE-P940 lanza el job WFL "S500/WFL/COPIARCH/01MTP001" para transferir los archivos generados al host S006.

**Traza de código:**
```
PROGRAMA: S500P630 — S500/P630 Tarjetas/Intercambio
Líneas aproximadas: ~229
Tipo de sentencia: CALL
```

**Riesgos de migración:**
- La llave "S501T01" es un nombre heredado de S501/P110 no actualizado al migrar en 2016; su uso en el job WFL debe documentarse y validarse contra el catálogo de llaves vigente antes de migrar.
- El mecanismo CALL SYSTEM WFL para lanzar jobs es específico de Unisys MCP y no tiene equivalente directo en plataformas modernas; la migración debe sustituirlo por un orquestador de workflows (BPEL, Airflow, Step Functions u equivalente).

**Estado validación:** revalidado contra fuente 2026-07-14

---

### RN-S500-056 — Header Libro Mayor del Día (NIVLOG=0)
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/L002R2 |
| **Frecuencia** | cierre-diario |
**Fórmula:** Al NIVLOG=0 (inicio de jornada), escribe registro "HD"+fecha(CCAAMMDD)+autorización(0)+estado(0). Es el punto de entrada de todos los asientos GL del día; invocado desde S500/P142 vía ENLACE_8D.
**Estado:** pendiente HITL

---

### RN-S500-057 — Descriptor Extendido de Asiento GL
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/L002R2 |
| **Frecuencia** | por-transacción |
**Fórmula:** IDFFUNCION=1 → escanea 530 bytes offset+445; si LEN_REG>0 escribe DES[NIVDES+1] con 1,060 bytes de texto. BLOG = 890 bytes de DFFUNCION + APUN_DESC(8 dígitos) + %STA(2 dígitos).
**Estado:** pendiente HITL

---

### RN-S500-058 — Eliminación de Asiento GL (6 Condiciones en Cascada)
| Campo | Valor |
|-------|-------|
| **Tipo** | EVALUATE |
| **Confianza** | alta |
| **Regulador** | CNBV |
| **Programa** | S151/L002R2 |
| **Frecuencia** | por-transacción |
**Fórmula:** 6 validaciones: nivel>NIVLOG→err15; falla lectura→err9; sistema origen distinto→err9; función≠1→err11; autorización eliminación=0→err12; estado ya=2→err13. Si pasa todas: marca estado=2 en todos los niveles y agrega registro de evento de cancelación en NIVLOG+1.
**Estado:** pendiente HITL

---

### RN-S500-059 — Cancelación en Cascada de Niveles del Asiento GL
| Campo | Valor |
|-------|-------|
| **Tipo** | PERFORM |
| **Confianza** | alta |
| **Regulador** | CNBV |
| **Programa** | S151/L002R2 |
| **Frecuencia** | por-transacción |
**Fórmula:** Recorre vía IDFAUTANT todos los niveles anteriores marcando estado=2. Si AUT_ANTER = IDFAUTANT(BLOG) tras lectura (auto-referencia), limpia DFAUTANT a 00 para cortar el ciclo y evitar recursión infinita.
**Estado:** pendiente HITL

---

### RN-S500-060 — Reporte Regulatorio Saldos TESOFE/SAT (10 Canales SDO)
| Campo | Valor |
|-------|-------|
| **Tipo** | COMPUTE |
| **Confianza** | alta |
| **Regulador** | SAT |
| **Programa** | S151/L002R2 |
| **Frecuencia** | cierre-diario |
**Fórmula:** Escribe en SDO1–SDO10 (65 palabras Unisys = 390 bytes/registro). DETALLE: función(2)+sistema(4)+producto(4)+instrumento(4)+contrato(20)+edcta(2)+fecproceso(8)+fecini(8)+fecfin(8)+fecult(8)+saldo(offset+68). HEADER: "HD"+FECDIA(8)+8 ceros+relleno(356).
**Estado:** pendiente HITL

---

### RN-S500-061 — Clasificación Cuenta Crédito/Captación por Número de Sistema
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | cierre-diario |
**Fórmula:** Sistemas 402(BIVA) y 600(crédito especial) → WKS-SISTEMA-LETRA="C"; todos los demás → "S" (savings/captación). La letra se propaga a WKS-START-S-C, WKS-SIS-S-C, WKS-MC-S-C, WKS-DES-S-C, WKS-ERR-S-C y campos de agrupación.
**Estado:** pendiente HITL

---

### RN-S500-062 — Resolución de CSI por Sistema y Nodo de Ejecución
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | cierre-diario |
**Fórmula:** Sistemas 404/414: nodo ACYPBETA o VDMBETA → CSI=04 (otro nodo no reasigna). Sistema 403: ACYPBETA/VDMBETA → CSI=04, cualquier otro → CSI=10. W77-CSI-PROCESO se propaga a WKS-AG-CSI, WKS-CSI-OR, WKS-HD-CSI, WKS-ERR-CSI.
**Estado:** pendiente HITL

---

### RN-S500-063 — Resolución Librería LIB-REGISTRA y Cierre de Descripciones
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | cierre-diario |
**Fórmula:** CALL "DAME_TIT IN CTRLVERS": status≥0 → usa WKS-CTLVERS-TITULO; status<0 → aviso + ruta fija "(S151)S151/OBJECT/L002/REGISTRA ON CMEMP". Seguido de CALL "CONTROLES IN LIB-REGISTRA" para cerrar archivos de movimientos y descripciones del sistema en proceso.
**Estado:** pendiente HITL

---

### RN-S500-064 — Carga Catálogo 1077 Intercompañía (Sistemas 84/87/403/500)
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | cierre-diario |
**Fórmula:** Sistemas 84, 87, 403 y 500 cargan catálogo 1077 "REL INTER VS U NEGOC" vía CPPE-CATALOGO → 15500-ARMA-1ER-LLAMADA-L710-CP → 14900-CARGA-INTERCOMPANY. Mapea corporativo a unidades de negocio para segregación contable entre entidades legales del grupo Banamex-Citigroup.
**Estado:** pendiente HITL

---

### RN-S500-065 — Validación Código de Moneda (Rango 1–99)
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | cierre-diario |
**Fórmula:** W77-IND (de CDPS-CVE-REGISTRO vía catálogo L700) debe ser 1–99; fuera de rango → 98200-ERROR-EN-LIMITE-CD y el lote se detiene. Peso mexicano = código 1; GL soporta hasta 99 tipos de moneda.
**Estado:** pendiente HITL

---

### RN-S500-066 — Validación y Carga de Atributos Tipo de Transacción (Rango 1–10,000)
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | cierre-diario |
**Fórmula:** W77-IND rango 1–10,000; fuera de rango → 98400-ERROR-EN-LIMITE-CP. Por tipo válido carga: WKS-PT-EXISTE, NUM-LEYEN, EVENTO, CGENTRA, NATS028 (interfaz S028), INDS254 (centralizar sucursal promotora en crédito), INDBITA (bitácora operativa).
**Estado:** pendiente HITL

---

### RN-S500-067 — Carga Catálogo 209 BIVA para Sistema 402
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | CNBV |
| **Programa** | S151/P130 |
| **Frecuencia** | cierre-diario |
**Fórmula:** Sistema 402 (BIVA) carga exclusivamente catálogo 209 "ESTR.REG.BIVA" desde L710 vía 14600-CARGA-CAT-209. Define estructura de registros de posición de valores para liquidación en bolsa; discrepancia con formato exacto provoca rechazo CNBV y falta de liquidación.
**Estado:** pendiente HITL

---

### RN-S500-068 — Nodo de Impresión por Defecto (CSI × 100)
| Campo | Valor |
|-------|-------|
| **Tipo** | COMPUTE |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | por-transacción |
**Fórmula:** Si CALL "LIBEST IN ESTRUCTURA" falla o WKS-EST-NODO-IMP ≤ 0: WKS-SUC-NODO-IMP(W77-IND) = W77-CSI-PROCESO × 100. Si WKS-EST-NODO-IMP > 0, se usa ese valor. Mismo patrón para RM-NODO-IMP (línea 8453).
**Estado:** pendiente HITL

---

### RN-S500-069 — Bandeo de Leyendas en 4 Tablas Paralelas
| Campo | Valor |
|-------|-------|
| **Tipo** | COMPUTE |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | cierre-diario |
**Fórmula:** IND>9000 → IND-9000 → WS-LEY-TRAN4; IND>6000 → IND-6000 → WS-LEY-TRAN3; IND>3000 → IND-3000 → WS-LEY-TRAN2; IND≤3000 → WS-LEY-TRAN1. Rango 1–10,000; fuera de rango → error 98200. Mismo patrón de bandas repetido en 3 puntos más del programa.
**Estado:** pendiente HITL

---

### RN-S500-070 — Lectura Descriptores Encadenados del Log GL
| Campo | Valor |
|-------|-------|
| **Tipo** | COMPUTE |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | por-transacción |
**Fórmula:** Si A00-R01-APUDES > 0: W77-APUDES = A00-R01-APUDES + 1; READ LOG151-COMP INTO A01-R01-DATOS. A00-R01-APUDES es el APUN_DESC que S151/L002R2 (ALGOL) escribe al postear el asiento; P130 (COBOL) lo consume en la agrupación nocturna.
**Estado:** pendiente HITL

---

### RN-S500-071 — Cálculo Memoria/Disco para SORT de Movimientos Contables
| Campo | Valor |
|-------|-------|
| **Tipo** | COMPUTE |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P130 |
| **Frecuencia** | cierre-diario |
**Fórmula:** W77-TOT-MEMORIA = (17+3)×2000+1500 palabras; W77-TOT-DISCO = 17×LASTRECORD(MOVIMIENTOS)×2.25 palabras. Ordena por SM-NODO-IMP/SM-SUC-INIC/SM-CAJA-INIC/SM-FONDO/SM-TIPO-CRED/SM-AUT-S151. Factor fijo 17 varía en otros SORTs del programa (31 y 8).
**Estado:** pendiente HITL

---

### RN-S500-072 — Mapeo de Parámetro de Entrada a Día de la Semana (≤10 Instancias)
| Campo | Valor |
|-------|-------|
| **Tipo** | EVALUATE |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P015 |
| **Frecuencia** | cierre-diario |
**Fórmula:** WKS-ENTRY-PARAM → W77-DIA-SEM: 1/6→día 1(lun); 2/7→día 2(mar); 3/8→día 3(mié); 4/9→día 4(jue); 5/10→día 5(vie). Permite hasta 10 instancias paralelas procesando los 5 días laborables del ciclo contable semanal BD10MOVDIA151.
**Estado:** pendiente HITL

---

### RN-S500-073 — Control Anti-Duplicación de Asientos en Reprocesos Nocturnos
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P015 |
| **Frecuencia** | cierre-diario |
**Fórmula:** B00-GLOB-NIV-BASE(W77-DIA-SEM) > 0 → ejecuta 000050-VERIFICA-DATOS (valida primera entrada en B01/B11/B21-SXAUTS151) antes de agregar. Si = 0, día sin inicializar → agrega directamente sin verificación previa.
**Estado:** pendiente HITL

---

### RN-S500-074 — Continuidad Batch si CTLVERS No Resuelve S151LIBCONTROL
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P015 |
| **Frecuencia** | cierre-diario |
**Fórmula:** CALL "DAME_TIT IN CTRLVERS" clave "S151L001CTL": status<0 → aviso informativo + ruta fija "(S151)S151/OBJECT/L001/CONTROL ON CMEMP." (sin release/MTP). Status≥0 → usa WKS-CTLVERS-TITULO. Garantiza continuidad del batch nocturno aunque la librería no esté auditada.
**Estado:** pendiente HITL

---

### RN-S500-075 — Control Anti-Duplicación de Interrupción HI-4 en Cierre Batch
| Campo | Valor |
|-------|-------|
| **Tipo** | IF |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P015 |
| **Frecuencia** | cierre-diario |
**Fórmula:** 1ª HI-4 → registra "TERMINACION DEL ASIN1 POR HI 4" y continúa; 2ª HI-4 (W88-DOBLEHI4 activo) → suprime mensaje para evitar recursión infinita. HI-20 → solo reporta W77-NIV-BASE sin detener proceso. W77-DOBLEHI4=1 al alcanzar fin normal.
**Estado:** pendiente HITL

---

### RN-S500-076 — Clave de Posicionamiento Secuencial W77-LLAVE = NIV-BASE + 2
| Campo | Valor |
|-------|-------|
| **Tipo** | COMPUTE |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P015 |
| **Frecuencia** | por-transacción |
**Fórmula:** W77-LLAVE = W77-NIV-BASE + 2; usado en SEEK L01-DATOS RECORD / SEEK L02-DATOS RECORD antes de READ … INTO A00-R01-REGMOV. Es el equivalente COBOL del esquema NIVLOG+1 del ACL ALGOL (L002R2). Mismo patrón +2 repetido en varios puntos del programa.
**Estado:** pendiente HITL

---

### RN-S500-077 — Auto-Corrección de Sincronización con Log GL de L002R2
| Campo | Valor |
|-------|-------|
| **Tipo** | COMPUTE |
| **Confianza** | alta |
| **Regulador** | CNBV |
| **Programa** | S151/P015 |
| **Frecuencia** | cierre-diario |
**Fórmula:** CALL "CONTROLES IN LIB-L002" → W77-NIV-BASE-L002 = resultado - 2. Si W77-NIV-BASE-L002 > W77-NIV-BASE: avanza leyendo registros (002000-LEE-NEXT, llave W77-NIV-BASE+2) hasta igualar niveles con el log autoritativo de S151/L002R2.
**Estado:** pendiente HITL

---

### RN-S500-078 — Descuento de Totales Acumulados por Sucursal-Caja en Semana Contable
| Campo | Valor |
|-------|-------|
| **Tipo** | COMPUTE |
| **Confianza** | alta |
| **Regulador** | N/A |
| **Programa** | S151/P015 |
| **Frecuencia** | cierre-diario |
**Fórmula:** B03-NUM-AB(W77-SUMA) = B03-NUM-AB(W77-SUMA) - WKS-SUC-NUM-ABO(W77-REM,W77-SUMA). Mismo patrón de 4 restas (NUM-AB/NUM-CR/IMP-AB/IMP-CR) repetido para pares B03/B04(lun) → B13/B14(mar) → B23/B24(mié) → B33/B34(jue) → B43/B44(vie).
**Estado:** pendiente HITL

---

