# Catálogo de Reglas de Negocio — S500 Deposits A · P170 · P191 · P127 · P109 · P290 · P164 · P115
**Versión:** 1.0 — 2026-07-17
**Programas fuente:** P170 · P191 · P127 · P109 · P290 · P164 · P115
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Numeración:** RN-S500-261 a RN-S500-302 (42 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S500-261 — Validación de versión ejecutada contra maestro de versiones (S100)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-261 |
| **Nombre** | Validación de versión ejecutada contra maestro de versiones (S100) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de procesar, P170 verifica que la versión del ejecutable que está corriendo coincida con la versión registrada en el maestro de versiones S100. Si la versión no coincide (S000-CTR-CVEERROR menor que cero), emite el mensaje "VER. EJECUTADA DIF. A VERSIONES" y aborta el proceso cambiando su atributo STATUS a -1. Esto evita ejecutar código desincronizado del catálogo autorizado de versiones.

**Fórmula/pseudocódigo:**
```
PERFORM CHECAME-VERSION
IF S000-CTR-CVEERROR < 0
   MENSAJE "VER. EJECUTADA DIF. A VERSIONES"
   CHANGE ATTRIBUTE STATUS OF MYSELF TO -1   (aborta)
```

**Vocabulario en la fórmula:** S000-CTR-CVEERROR · S100VERSIONES · STATUS

**Excepciones:**
- Si el maestro de versiones no responde el resultado es indeterminado (no hay rama de timeout explícita).

**Estado validación:** Verificado fuente líneas 1538-1546

---

## RN-S500-262 — Control de secuencia de paso: la base debe ser salida del P160

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-262 |
| **Nombre** | Control de secuencia de paso: la base debe ser salida del P160 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P170 solo procede si el dataset de control indica que los tres contadores de paso (B00-NUM-PASO-01, -02 y -03) valen 160, es decir, que la base quedó como salida del programa previo P160. Si se cumple, los reinicia a 0 y registra su propio avance dentro de una transacción DMSII. Si no, emite "ERROR BASE NO ES SALIDA DEL P160" y termina con DMTERMINATE. Es un candado de encadenamiento estricto del pipeline batch de captación.

**Fórmula/pseudocódigo:**
```
IF B00-NUM-PASO-01 = 160 AND B00-NUM-PASO-02 = 160
   AND B00-NUM-PASO-03 = 160
   MOVE 0 TO B00-NUM-PASO-01/02/03
ELSE
   MENSAJE "ERROR BASE NO ES SALIDA DEL P160"
   CALL SYSTEM DMTERMINATE
BEGIN-TRANSACTION / B00CTRLPASO-STORE / END-TRANSACTIONSYNC
```

**Vocabulario en la fórmula:** B00-NUM-PASO-01 · B00-NUM-PASO-02 · B00-NUM-PASO-03 · DMTERMINATE

**Excepciones:**
- El valor 160 es un hardcode que identifica al programa antecesor; cambiar la secuencia del pipeline requiere recompilar.

**Estado validación:** Verificado fuente líneas 1622-1633

---

## RN-S500-263 — Identificación XATMI obligatoria (TP_IDENTIFY) para diálogo con S408

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-263 |
| **Nombre** | Identificación XATMI obligatoria (TP_IDENTIFY) para diálogo con S408 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para poder consultar totales al S408, P170 debe registrarse primero en el middleware transaccional XATMI mediante TP_IDENTIFY, pasando su nombre de programa "S500P170". Si el resultado del identify es distinto de 0, arma el mensaje "ERROR EN TP_IDENTIFY" con el código de retorno y aborta (STATUS a -1). Sin identificación XATMI no hay canal hacia el S408.

**Fórmula/pseudocódigo:**
```
PERFORM CHANGE-XATMI
MOVE "S500P170" TO WS-XATMI-PROG-NAME
PERFORM CALL-TRANSIT   (TP_IDENTIFY)
IF WS-XATMI-RSLT = 0  → continuar
ELSE  MENSAJE "ERROR EN TP_IDENTIFY " + RSLT ; STATUS = -1
```

**Vocabulario en la fórmula:** WS-XATMI-PROG-NAME · TP_IDENTIFY · WS-XATMI-RSLT · TRANSIT

**Excepciones:**
- Cualquier código distinto de 0 se trata como fatal; no hay reintento automático.

**Estado validación:** Verificado fuente líneas 1551-1562

---

## RN-S500-264 — Reconciliación de cifras de control S500 contra S151 y S408 por clave

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-264 |
| **Nombre** | Reconciliación de cifras de control S500 contra S151 y S408 por clave |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P170 es un cuadre de cifras de control: acumula por clave los totales de cargos y abonos del S500, los consulta al S151 (contabilidad) y al S408 (línea de crédito), y calcula las diferencias (campos sufijo -DIF: importe y número de movimientos de cargos, abonos y no contabilizados). Las diferencias distintas de cero evidencian descuadre entre captación, contabilidad y crédito. Los resultados se imprimen en los reportes de cifras, posición y estadísticas, y se graban en TOTCVE para el sort posterior.

**Fórmula/pseudocódigo:**
```
POR CADA clave:
  WS-IMP-TCAR-DIF = TOTAL-CARGOS(S500) - TOTAL-CARGOS(S151/S408)
  WS-IMP-TABO-DIF = TOTAL-ABONOS(S500) - TOTAL-ABONOS(S151/S408)
  WS-IMP-NCON-DIF = NO-CONTABILIZADOS(S500) - (S151)
  (análogo para conteos WS-NUM-*-DIF)
IMPRIMIR cifras · GRABAR TOTCVE
```

**Vocabulario en la fórmula:** WS-IMP-TCAR-DIF · WS-IMP-TABO-DIF · WS-NUM-TCAR-DIF · WS-IMP-NCON-DIF · TOTCVE

**Excepciones:**
- Diferencias no forzan aborto; quedan documentadas en reporte para revisión manual del operador.

**Estado validación:** Verificado fuente líneas 1990-2000, 2028-2044, 523600-534900

---

## RN-S500-265 — Parámetros fijos de consulta de totales al S408

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-265 |
| **Nombre** | Parámetros fijos de consulta de totales al S408 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La consulta de totales recibidos por el S408 se arma con parámetros constantes embebidos: función 13, paso 170, tipo de proceso 30, más la fecha de proceso y las llaves de producto, instrumento y moneda del registro B09 en curso. Estos literales identifican semánticamente la operación "consulta de totales para P170" ante el S408; cualquier cambio de contrato con el S408 obliga a modificar el código.

**Fórmula/pseudocódigo:**
```
MOVE 13  TO WS-S408-FUNCION
MOVE 170 TO WS-S408-PASO
MOVE 30  TO WS-S408-TIPOPROCESO
MOVE WS-FECHA-PRO TO WS-S408-FECPRO
MOVE B09-NUM-PRODUCTO / B09-NUM-INSTRUM / B09-MONEDA → llaves
CALL-S408
```

**Vocabulario en la fórmula:** WS-S408-FUNCION · WS-S408-PASO · WS-S408-TIPOPROCESO · B09-NUM-PRODUCTO · B09-MONEDA

**Excepciones:**
- Ninguna; valores fijos por diseño de contrato con S408.

**Estado validación:** Verificado fuente líneas 549700-552400

---

## RN-S500-266 — Decisión del operador ante falla de consulta al S408

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-266 |
| **Nombre** | Decisión del operador ante falla de consulta al S408 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Si la consulta de totales al S408 falla, el proceso queda en manos del operador vía ACCEPT interactivo. Si teclea "C" continúa sin el dato del S408 (marca ciclos terminados); si teclea "R" cancela y recarga la librería LINCRED, espera y reintenta el llamado; cualquier otra respuesta se rechaza como "DECISION INVALIDA" y vuelve a pedir. Es un patrón de resiliencia manual dependiente de operación humana en el batch.

**Fórmula/pseudocódigo:**
```
ACCEPT WS-DECIDE1
IF "C" → WS-CICLO4=1, WS-CICLO3=1 (continúa sin S408)
ELSE IF "R" → CANCEL "LINCRED"; WAIT(2); recarga LINCRED; reintenta
ELSE → MENSAJE "DECISION INVALIDA"; repite
```

**Vocabulario en la fórmula:** WS-DECIDE1 · LINCRED · WS-CICLO3 · WS-CICLO4

**Excepciones:**
- La opción "R" depende de que la librería LINCRED pueda recargarse; si vuelve a fallar, reentra al mismo diálogo.

**Estado validación:** Verificado fuente líneas 554800-558400

---

## RN-S500-267 — Selección de modo de proceso: por parámetro (reproceso) o por fecha contable (normal)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-267 |
| **Nombre** | Selección de modo de proceso: por parámetro (reproceso) o por fecha contable (normal) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P191 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P191 decide su modo de ejecución. Si no viene fecha por parámetro (tipo de proceso 8) procesa en modo normal todas las fechas contables pendientes hasta la fecha actual. Si viene fecha por parámetro (tipo 9) intenta reproceso de esa fecha, pero solo la acepta como reproceso válido si la fecha solicitada es mayor que la última fecha ya aplicada registrada en B02 (WKS-B02-ULTIMO-ARC-APLI); en caso contrario neutraliza el reproceso (tipo 0). Es el candado que impide reprocesar fechas ya consolidadas.

**Fórmula/pseudocódigo:**
```
IF sin fecha-parametro → WKS-TIPO-PROCESO = 8 (normal)
ELSE  WKS-FEC-CON-INI/FIN = PARAM-FECHA ; TIPO = 9
      IF PARAM-FECHA > B02-ULTIMO-ARC-APLI → REPROCESO-VAL = 1
      ELSE  TIPO = 0 ; REPROCESO-VAL = 0  (no reprocesa)
Modo normal: PROCESA-X-CONTROL desde FEC-CON-INI hasta FEC-CON-FIN
```

**Vocabulario en la fórmula:** WKS-TIPO-PROCESO · WKS-PARAM-FECHA-CAMD · WKS-B02-ULTIMO-ARC-APLI · W77-REPROCESO-VAL

**Excepciones:**
- Solicitar reproceso de una fecha ya aplicada o anterior es silenciosamente ignorado (no aborta, solo no reprocesa).

**Estado validación:** Verificado fuente líneas 1959-1978

---

## RN-S500-268 — Conciliación S500 contra S054 por movimientos aplicados y diferencias

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-268 |
| **Nombre** | Conciliación S500 contra S054 por movimientos aplicados y diferencias |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P191 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P191 concilia los movimientos del S500 (canales VDM y MTY, tres cadenas cada uno) contra el S054, clasificando el resultado en dos cubetas: transacciones aplicadas (WKS-*-TRA-APLI) y transacciones con diferencia (WKS-*-TRA-DIFE), estas últimas desglosadas en cargos y abonos. Genera un reporte de aplicados (L01) y uno de diferencias (L02) con totales de número e importe por cada cubeta. Es el cuadre punto a punto entre captación y el sistema de liquidación S054.

**Fórmula/pseudocódigo:**
```
POR cada movimiento S500 (VDM C01/C02/C03, MTY C01/C02/C03):
   cotejar contra S054
   SI coincide → acumula TRA-APLI (num, imp)
   SI difiere  → acumula TRA-DIFE (num, imp) + desglose CARGO/ABONO
GENERA reporte L01 aplicados + L02 diferencias con totales
```

**Vocabulario en la fórmula:** WKS-NUM-TOT-TRA-APLI · WKS-IMP-TOT-TRA-APLI · WKS-NUM-TOT-TRA-DIFE · WKS-TOT-TRA-CARGO · WKS-TOT-TRA-ABONO

**Excepciones:**
- Diferencias no bloquean el avance; quedan reportadas para revisión.

**Estado validación:** Verificado fuente líneas 1287-1293, 1884-1958

---

## RN-S500-269 — Leyenda "sin información" cuando totales conciliados son cero

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-269 |
| **Nombre** | Leyenda "sin información" cuando totales conciliados son cero |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P191 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al revisar cifras, si tanto el importe como el número de transacciones aplicadas son cero, P191 imprime en el reporte de aplicados el título de leyenda "sin información". De igual modo, si número e importe de diferencias, cargos y abonos son todos cero, imprime la leyenda "sin información" en el reporte de diferencias. Garantiza que el reporte documente explícitamente la ausencia de movimientos en vez de dejar el bloque en blanco.

**Fórmula/pseudocódigo:**
```
IF IMP-TOT-TRA-APLI = 0 AND NUM-TOT-TRA-APLI = 0
   escribir TITULO + WKS-TOT-TIT-PNT-SININFO en L01
IF (NUM/IMP-DIFE = 0 AND NUM/IMP-CARGO = 0 AND NUM/IMP-ABONO = 0)
   escribir TITULO + WKS-TOT-TIT-PNT-SININFO en L02
```

**Vocabulario en la fórmula:** WKS-IMP-TOT-TRA-APLI · WKS-NUM-TOT-TRA-APLI · WKS-TOT-TIT-PNT-SININFO

**Excepciones:**
- Ninguna.

**Estado validación:** Verificado fuente líneas 1884-1948

---

## RN-S500-270 — Avance de la siguiente fecha hábil solo en proceso normal o reproceso válido

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-270 |
| **Nombre** | Avance de la siguiente fecha hábil solo en proceso normal o reproceso válido |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P191 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Solo cuando el proceso es normal (WKS88-TIPPRO-PRM-NORMAL-OK) o hay reproceso válido (W77-REPROCESO-VAL mayor que 0), P191 calcula la siguiente fecha hábil vía la librería de fechas (clave de semana 65, considerando festivos, clave festivo 1) y actualiza B02CONTROL con la nueva fecha de última aplicación. Esto evita mover el reloj contable cuando la corrida no consolida.

**Fórmula/pseudocódigo:**
```
IF TIPPRO-NORMAL OR W77-REPROCESO-VAL > 0
   OBTEN-SIG-FEC-HABIL:
      W77-LIBFEC-CVESEM = 65 ; CVEFEST = 1
      FECHAIN = (reproceso? FEC-REPROCESO : FEC-CON-INI)
      DAME-SIGHAB2K → FECHAOUT → FEC-CON-INI
   ACTUALIZA-BD02CONTROL (B02-ULT-ARCH-APLI = FEC-CON-INI)
```

**Vocabulario en la fórmula:** W77-LIBFEC-CVESEM · W77-LIBFEC-CVEFEST · WS-LIBFEC-FECHAOUT · B02-ULT-ARCH-APLI

**Excepciones:**
- Corridas que no son normales ni reproceso válido no avanzan la fecha de control.

**Estado validación:** Verificado fuente líneas 1275-1279, 2905-2921

---

## RN-S500-271 — Bloqueo y verificación de vacío de B02CONTROL antes de actualizar

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-271 |
| **Nombre** | Bloqueo y verificación de vacío de B02CONTROL antes de actualizar |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P191 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de actualizar la fecha de última aplicación, P191 posiciona B02CONTROL al inicio y hace LOCK. Si el estado de base es mayor que cero, distingue: estado 1 significa "ERROR B02CONTROL VACIO" y cualquier otro estado arma "ERROR AL HACER LOCK B02" con el status; en ambos casos deriva a la rutina de decisión de fin. Solo si el lock es limpio graba dentro de una transacción DMSII (BEGIN/STORE/END). Protege la integridad del dataset de control contra escrituras sobre base vacía o bloqueada.

**Fórmula/pseudocódigo:**
```
SET B02CONTROL TO BEGINNING ; B02CONTROL-LOCK
IF WS-STATUS-BASE > 0
   IF = 1 → MENSAJE "ERROR B02CONTROL VACIO" ; DECIDE-TIPO-FIN
   ELSE   → MENSAJE "ERROR AL HACER LOCK B02" + STATUS ; DECIDE-TIPO-FIN
MOVE FEC-CON-INI → B02-ULT-ARCH-APLI(14)
BEGIN-TRANSACTION / B02CONTROL-STORE / END-TRANSACTION
```

**Vocabulario en la fórmula:** WS-STATUS-BASE · B02CONTROL-LOCK · B02-ULT-ARCH-APLI

**Excepciones:**
- La reacción concreta depende de la rutina DECIDE-TIPO-FIN (puede terminar o continuar según configuración).

**Estado validación:** Verificado fuente líneas 2043-2065

---

## RN-S500-272 — Validación de versión con terminación dura (DMTERMINATE) en P191

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-272 |
| **Nombre** | Validación de versión con terminación dura (DMTERMINATE) en P191 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P191 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Igual que el resto del pipeline, P191 valida que su versión coincida con el maestro S100. La diferencia respecto a P170 es la severidad de la reacción: si la versión difiere (S000-CTR-CVEERROR menor que cero), emite "VER. EJECUTADA DIF. A VERSIONES" y termina inmediatamente con CALL SYSTEM DMTERMINATE (aborto duro del task), no solo un cambio de status.

**Fórmula/pseudocódigo:**
```
PERFORM CHECAME-VERSION
IF S000-CTR-CVEERROR < 0
   MENSAJE "VER. EJECUTADA DIF. A VERSIONES"
   CALL SYSTEM DMTERMINATE
```

**Vocabulario en la fórmula:** S000-CTR-CVEERROR · DMTERMINATE · S100VERSIONES

**Excepciones:**
- Ninguna; terminación inmediata.

**Estado validación:** Verificado fuente líneas 1248-1252

---

## RN-S500-273 — Validación de encabezado del archivo S408 (origen, destino y fecha)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-273 |
| **Nombre** | Validación de encabezado del archivo S408 (origen, destino y fecha) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P127 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de aplicar el archivo de movimientos del S408, P127 valida su encabezado (registro tipo 00). El sistema origen debe ser "S408" y el sistema destino "S500", y la fecha de proceso del archivo (WKS-E01-R00-FEC-PRO) debe coincidir con la fecha base de la corrida (WKS-FEC-BASE). Si la fecha no coincide o el par origen/destino es incorrecto, escribe el error correspondiente y marca W77-NOHAY-S408 = 1, saltando la aplicación. Impide procesar un archivo del día equivocado o mal ruteado.

**Fórmula/pseudocódigo:**
```
READ header E01-MOVS408
IF FEC-PRO NOT = FEC-BASE → "ERR FECHA E01-MOVS408" ; NOHAY-S408 = 1
IF SISORI = "S408" AND SISDES = "S500" → OK, aplica
ELSE → "ERR E01-MOVS408 NUM-SISTEMAS" ; NOHAY-S408 = 1
```

**Vocabulario en la fórmula:** WKS-E01-R00-SISORI · WKS-E01-R00-SISDES · WKS-E01-R00-FEC-PRO · WKS-FEC-BASE · W77-NOHAY-S408

**Excepciones:**
- Un archivo con encabezado inválido no aborta el programa; solo se omite su aplicación.

**Estado validación:** Verificado fuente líneas 1288-1310

---

## RN-S500-274 — Manejo de archivo S408 vacío frente a archivo de punteo vacío

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-274 |
| **Nombre** | Manejo de archivo S408 vacío frente a archivo de punteo vacío |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P127 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P127 trata de forma asimétrica dos entradas vacías. Si el archivo de movimientos S408 está vacío (AT END en la lectura inicial), lo tolera: escribe "ARCHIVO S408 VACIO", marca W77-NOHAY-S408 = 1 y en el proceso principal escribe la leyenda de sin información sin abortar. En cambio, si el archivo de punteo (I03-PUNTEOIN) está vacío, lo considera fatal: escribe "ARCH PUNTEO VACIO" y termina con CALL SYSTEM DMTERMINATE. El punteo es insumo obligatorio; el S408 del día puede legítimamente no traer movimientos.

**Fórmula/pseudocódigo:**
```
READ E01-MOVS408 AT END → "ARCHIVO S408 VACIO" ; NOHAY-S408 = 1  (continúa)
READ I03-PUNTEOIN AT END → "ARCH PUNTEO VACIO" ; DMTERMINATE  (aborta)
```

**Vocabulario en la fórmula:** W77-NOHAY-S408 · E01-MOVS408 · I03-PUNTEOIN · DMTERMINATE

**Excepciones:**
- Ninguna.

**Estado validación:** Verificado fuente líneas 1283-1286, 1479-1490, 1298-1300

---

## RN-S500-275 — Clasificación de cancelación por clave de sobregiro (CVE-SOB)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-275 |
| **Nombre** | Clasificación de cancelación por clave de sobregiro (CVE-SOB) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P127 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cada movimiento del S408, P127 decide el tratamiento de cancelación según la clave de sobregiro CVE-SOB. Valor 88: cancelación por línea de crédito, marca B03-IND-LINCREDIT = 1, tipo cancelación 2, suma a total no validados. Valor 89: variante de línea de crédito, B03-IND-LINCREDIT = 3, tipo 8, suma a no validados por línea. Valor 01: aviso de próxima cancelación (tipo 3). Valor 02: cancelación efectiva (ver regla especial). Cualquier otra clave: rechazo tipo 6. La clave de sobregiro gobierna toda la lógica de aplicación de bloqueos/cancelaciones.

**Fórmula/pseudocódigo:**
```
IF CVE-SOB = 88 → TPO-CANCEL=2 ; B03-IND-LINCREDIT=1 ; +NVALIC ; ARMALIN
IF CVE-SOB = 89 → TPO-CANCEL=8 ; B03-IND-LINCREDIT=3 ; +NVALCLINEA ; ARMALIN
IF CVE-SOB = 01 → AVISO-PROX-CANCE (TPO-CANCEL=3)
IF CVE-SOB = 02 → (ver RN-S500-277)
ELSE           → TPO-CANCEL=6 ; RECHAZO-CANCELADA
IF WKS-IND-MOV > 0 → ENVIA-MOVSS151
```

**Vocabulario en la fórmula:** WKS-E01-R01-CVE-SOB · W77-TPO-CANCEL · B03-IND-LINCREDIT · MOVSS151

**Excepciones:**
- El aviso de próxima cancelación (01) no cancela; solo notifica.

**Estado validación:** Verificado fuente líneas 1524-1554

---

## RN-S500-276 — Rechazo de cancelación cuando el contrato no existe en la base

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-276 |
| **Nombre** | Rechazo de cancelación cuando el contrato no existe en la base |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P127 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de validar la cancelación de un movimiento S408 (registros distintos de tipo 00 y 99), P127 busca el contrato en la base. Si el contrato no existe (W77-EOF-BASE distinto de 0), no intenta cancelar: asigna tipo de cancelación 5 y ejecuta la rutina de rechazo por cancelada. Solo si el contrato existe suma a autorizados, valida la cancelación y hace STORE en la base. Evita aplicar bloqueos sobre contratos inexistentes.

**Fórmula/pseudocódigo:**
```
IF TPO-REG = 00 OR 99 → ignorar
ELSE
   DAME-BDCONTRATO(CONTRATO)
   IF W77-EOF-BASE = 0 → +AUTORIZ ; VALIDA-CANCELACION ; STORE-BASE
   ELSE → TPO-CANCEL=5 ; RECHAZO-CANCELADA
```

**Vocabulario en la fórmula:** WKS-E01-R01-TPO-REG · WKS-E01-R01-CONTRATO · W77-EOF-BASE · W77-TPO-CANCEL

**Excepciones:**
- Registros de encabezado (00) y cola (99) se saltan sin procesar.

**Estado validación:** Verificado fuente líneas 1502-1521

---

## RN-S500-277 — Cancelación clave 02: rechazo por sociedad funeraria o bloqueo preexistente 66/14

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-277 |
| **Nombre** | Cancelación clave 02: rechazo por sociedad funeraria o bloqueo preexistente 66/14 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P127 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando la clave de sobregiro es 02 (cancelación efectiva), P127 aplica reglas de exclusión. Si la cuenta es de tipo socio-funcionario (WS03-88-TC-SOCFUN), rechaza la cancelación con tipo 4. Si la cuenta ya tiene un bloqueo activo (B03-STATUS = 1) del tipo 66 o del tipo 14, asigna tipo de cancelación 9 (no la vuelve a bloquear). En cualquier otro caso ejecuta la cancelación normal (aviso de cancelación). Protege cuentas de funcionarios y respeta bloqueos preexistentes específicos.

**Fórmula/pseudocódigo:**
```
IF CVE-SOB = 02
   IF WS03-88-TC-SOCFUN → TPO-CANCEL=4 ; RECHAZO-CANCELADA
   ELSE IF (B03-STATUS=1 AND B03-TIPO-BLOQUEO=66)
        OR (B03-STATUS=1 AND B03-TIPO-BLOQUEO=14) → TPO-CANCEL=9
   ELSE → AVISO-CANCELACION
```

**Vocabulario en la fórmula:** WS03-88-TC-SOCFUN · B03-STATUS · B03-TIPO-BLOQUEO · W77-TPO-CANCEL

**Excepciones:**
- Los tipos de bloqueo 66 y 14 son hardcodes que representan bloqueos que ya cubren el efecto de la cancelación.

**Estado validación:** Verificado fuente líneas 1542-1554

---

## RN-S500-278 — Validación de versión con status -1 en P127

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-278 |
| **Nombre** | Validación de versión con status -1 en P127 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P127 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P127 valida su versión contra el maestro S100 en la rutina de títulos y librerías. Si la versión difiere (S000-CTR-CVEERROR menor que cero), emite el mensaje "ERROR DE VERSION" y cambia su atributo STATUS a -1, deteniendo la corrida. Es la misma salvaguarda de versión del pipeline, con literal de mensaje propio.

**Fórmula/pseudocódigo:**
```
PERFORM CHECAME-VERSION
IF S000-CTR-CVEERROR < 0
   MENSAJE "ERROR DE VERSION"
   CHANGE ATTRIBUTE STATUS OF MYSELF TO -1
```

**Vocabulario en la fórmula:** S000-CTR-CVEERROR · STATUS · S100VERSIONES

**Excepciones:**
- Ninguna.

**Estado validación:** Verificado fuente líneas 943-948

---

## RN-S500-279 — Conversión de tasa GBNP de texto a numérico (entero + decimal escalado)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-279 |
| **Nombre** | Conversión de tasa GBNP de texto a numérico (entero + decimal escalado) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P109 lee las tasas de pago de rendimientos enviadas por GBNP como texto y las convierte a numérico. Descompone la cadena I01-TASA-TASA por separadores ("-", "." o "~") para obtener parte entera y parte decimal, y reconstruye la tasa como entero más la fracción decimal escalada por 10 elevado al número de posiciones decimales. El resultado se mueve a WS-I02-RATE para su aplicación. Es la normalización del formato de tasa externo de GBNP al formato interno del S500.

**Fórmula/pseudocódigo:**
```
UNSTRING I01-TASA-TASA por "-" → WS-TASA-ENT, COUNT C-POINTER
IF C-POINTER > 0
   UNSTRING por "." o "~" → parte entera y decimal (WS-TASA-DEC)
   WS-TASA-CONV = WS-TASA-ENT + (WS-TASA-DEC / 10**C-POINTER)
MOVE WS-TASA-CONV-N TO WS-I02-RATE
```

**Vocabulario en la fórmula:** I01-TASA-TASA · WS-TASA-ENT · WS-TASA-DEC · WS-C-POINTER · WS-I02-RATE

**Excepciones:**
- Las validaciones de tasa = 0 (código 1005) y tasa mayor que 24 (código 1012) están comentadas en el fuente actual; no se aplican en producción.

**Estado validación:** Verificado fuente líneas 1619-1643

---

## RN-S500-280 — Validación de versión condicionada al entorno (beta exenta)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-280 |
| **Nombre** | Validación de versión condicionada al entorno (beta exenta) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** A diferencia del resto del pipeline, P109 exime de la validación de versión a los equipos de prueba. Si el nombre del host es "ACYPBETA." o "CACYPBET." (entornos beta), omite el chequeo de versión (NEXT SENTENCE). En cualquier otro host ejecuta CHECAME-VERSION y, si la versión difiere (S000-CTR-CVEERROR menor que cero), emite "ERROR DE VERSION" y cambia STATUS a -1. Permite correr versiones no publicadas en beta sin que el control de versión aborte.

**Fórmula/pseudocódigo:**
```
IF WS-DH-NOM-EQUIPO = "ACYPBETA. " OR "CACYPBET. "
   NEXT SENTENCE   (omite validación)
ELSE
   CHECAME-VERSION
   IF S000-CTR-CVEERROR < 0 → "ERROR DE VERSION" ; STATUS = -1
```

**Vocabulario en la fórmula:** WS-DH-NOM-EQUIPO · S000-CTR-CVEERROR · S100VERSIONES · STATUS

**Excepciones:**
- Los nombres de host beta son hardcodes; renombrar el equipo de pruebas rompe la exención.

**Estado validación:** Verificado fuente líneas 983-991

---

## RN-S500-281 — Contratos clonados (marca clon 2 o 3) se excluyen de la aplicación de tasa

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-281 |
| **Nombre** | Contratos clonados (marca clon 2 o 3) se excluyen de la aplicación de tasa |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al validar cada contrato para aplicar tasa, P109 detecta contratos clonados por B03-MARCA-CLON. Si la marca es 2, marca WKS-CTO-CLO = 1 y omite el procesamiento. Si la marca es 3, además de marcar clon, registra la opción de estadística 6 y suma estadísticos antes de omitir. Solo los contratos no clonados pasan a la validación de instrumento, movimiento de datos B03, validación de tasa y validación de contrato. Los contratos clonados se liberan sin aplicar tasa (FREE del dataset).

**Fórmula/pseudocódigo:**
```
IF B03-MARCA-CLON = 2 → WKS-CTO-CLO = 1  (omite)
ELSE IF B03-MARCA-CLON = 3 → WKS-CTO-CLO = 1 ; SECS-OPCION=6 ; SUMA-ESTADISTICOS
ELSE → VAL-INSTRUME ; MUEVE-B03 ; VALIDA-TASA ; VALIDA-CTO
IF ERR-CODE-NOK OR WKS-CTO-CLO = 1 → FREE B03CONTRATOS
```

**Vocabulario en la fórmula:** B03-MARCA-CLON · WKS-CTO-CLO · WS-SECS-OPCION · S500B03CONTRATOS

**Excepciones:**
- La marca 3 se estadística; la marca 2 se descarta en silencio.

**Estado validación:** Verificado fuente líneas 1671-1692

---

## RN-S500-282 — Catálogo de códigos de error de validación de contrato para tasa

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-282 |
| **Nombre** | Catálogo de códigos de error de validación de contrato para tasa |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P109 asigna un código de error numérico WS-I02-ERR-CODE que clasifica por qué un contrato no puede recibir la tasa. En la validación general contra la base B03: 1007 no encontrado (NOTFOUND), 1006 deadlock, 1011 otro error de find. En la validación de contrato: 1002 contrato cancelado (WS03-88-S-CANCELADA), 1010 indicador de servicio GBNP en cero, 1008 instrumento no operable (B05-NOP). Estos códigos alimentan el reporte de rechazos y determinan qué contratos quedan sin actualizar.

**Fórmula/pseudocódigo:**
```
FIND B03 → status > 0:
   NOTFOUND → 1007 ; DEADLOCK → 1006 ; otro → 1011
VALIDA-CTO:
   IF WS03-88-S-CANCELADA → 1002
   ELSE IF WS03-GBNP-SERV-IND = 0 → 1010
   ELSE IF WS-88-B05-NOP → 1008
```

**Vocabulario en la fórmula:** WS-I02-ERR-CODE · WS03-88-S-CANCELADA · WS03-GBNP-SERV-IND · WS-88-B05-NOP

**Excepciones:**
- Un contrato con cualquier código distinto de OK no se actualiza y libera el registro.

**Estado validación:** Verificado fuente líneas 1698-1702, 1725-1755, 738 (catálogo de literales)

---

## RN-S500-283 — Selección de tasa por coincidencia de fecha de corte (servicio GBNP 1 y 2)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-283 |
| **Nombre** | Selección de tasa por coincidencia de fecha de corte (servicio GBNP 1 y 2) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P109 selecciona los campos de tasa a aplicar según el indicador de servicio GBNP y la coincidencia de la fecha proyectada con la fecha real de corte B06. Para servicio GBNP 1 y 2, cuando la fecha proyectada (WS-FECHA-PROY) coincide con la fecha real de corte (B06-FECREAL-CORTE), toma la tasa bruta de GBNP escalada por 1,000,000 y el rendimiento correspondiente (IPAB o intereses capitalizados). La fecha de corte determina cuál tasa vigente se aplica al pago de rendimientos.

**Fórmula/pseudocódigo:**
```
IF WS03-GBNP-SERV-IND = 1 (o = 2)
   IF WS-FECHA-PROY = B06-FECREAL-CORTE
      WS-I02-RATE-U = WS03-GBNP-TASA-BRUTA * 1000000
      WS-I02-FECH-S = WS03-GBNP-TASA-FEC
      WS-I02-REND-B03 = WS03-RENDIA-IPAB / WS03-INTS-CAPIT
```

**Vocabulario en la fórmula:** WS03-GBNP-SERV-IND · WS-FECHA-PROY · B06-FECREAL-CORTE · WS03-GBNP-TASA-BRUTA · WS03-RENDIA-IPAB

**Excepciones:**
- El factor 1,000,000 es un hardcode de escala de la tasa bruta.

**Estado validación:** Verificado fuente líneas 1802-1839

---

## RN-S500-284 — Cambio de producto en prepagadas requiere existencia en B44 (evolución de contrato)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-284 |
| **Nombre** | Cambio de producto en prepagadas requiere existencia en B44 (evolución de contrato) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando el contrato tiene producto e instrumento nuevo (PRODUCTO-NVO e INSTRUM-NVO mayores que cero) y aplica cambio de producto (B05-MEN), P109 distingue por tipo de inversión. Si es prepagada (WS03-88-PIM-PREPAGADA), busca el contrato en la base de evolución B44: si ya existe asigna error 1001, si no existe (NOTFOUND) actualiza B03, y ante otro error asigna 1014. Si no es prepagada asigna directamente error 1001. Sin cambio de producto actualiza B03 normalmente. Controla la migración de producto de inversiones prepagadas mediante el histórico de evolución.

**Fórmula/pseudocódigo:**
```
IF PRODUCTO-NVO > 0 AND INSTRUM-NVO > 0 AND B05-MEN
   IF PIM-PREPAGADA
      FIND B44SXCTOSEVOL
      IF status = 0 (existe) → 1001
      ELSE IF NOTFOUND → ACTUALIZA-B03
      ELSE → 1014 ("ERR FIND B44CTOSEVOL")
   ELSE → 1001
ELSE → ACTUALIZA-B03
```

**Vocabulario en la fórmula:** WS03-PRODUCTO-NVO · WS03-INSTRUM-NVO · WS03-88-PIM-PREPAGADA · B44CTOSEVOL

**Excepciones:**
- El error 1001 aplica tanto a prepagadas ya existentes en B44 como a no prepagadas con cambio de producto.

**Estado validación:** Verificado fuente líneas 1810-1836 (referencias), 381000-386000

---

## RN-S500-285 — Ventana temporal del proceso de planchado: domingo de la semana 4-10 después de las 16:00

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-285 |
| **Nombre** | Ventana temporal del proceso de planchado: domingo de la semana 4-10 después de las 16:00 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P290 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso de planchado de esquemas de comisiones de P290 solo se ejecuta si es domingo (W77-DSEM = 0), el día del mes está entre 4 y 10 (WS-DIA-DD mayor que 3 y menor que 11, la "semana de planchado") y la hora es posterior a las 15:59:59 (WS-HORA-HMS-N mayor que 155959, es decir a partir de las 4:00 PM). Fuera de esa ventana no procesa, salvo que se invoque con la opción de forzado (W88-TASK-OPC-FUERZA), que permite correr en domingo fuera de horario o incluso en semana que no corresponde. Es una ventana de mantenimiento estricta que evita reprocesar comisiones fuera del ciclo mensual planeado.

**Fórmula/pseudocódigo:**
```
IF W77-DSEM = 0 (domingo)
   IF WS-DIA-DD > 3 AND WS-DIA-DD < 11
      IF WS-HORA-HMS-N > 155959 → PROCESA (NO-PROCESO=1)
      ELSE IF FUERZA → PROCESA
      ELSE → no procesa
   ELSE IF FUERZA → PROCESA ; ELSE no procesa
ELSE (no domingo)
   IF FUERZA → PROCESA ; ELSE no procesa
```

**Vocabulario en la fórmula:** W77-DSEM · WS-DIA-DD · WS-HORA-HMS-N · W88-TASK-OPC-FUERZA · W77-NO-PROCESO

**Excepciones:**
- La opción de forzado saltea todas las validaciones de fecha y hora.
- El umbral 155959 y el rango de días 4-10 son hardcodes del calendario de planchado.

**Estado validación:** Verificado fuente líneas 1145-1226, 1304-1307

---

## RN-S500-286 — Carga de la tabla de esquema de comisiones desde B05 con tope de 30 productos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-286 |
| **Nombre** | Carga de la tabla de esquema de comisiones desde B05 con tope de 30 productos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P290 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P290 carga en una tabla interna el indicador de esquema de comisiones de cada producto leyendo el dataset B05INSTRUMEN. Almacena producto, instrumento, moneda, indicador de esquema (B05-ESQ-COMIS) y nombre por cada entrada. La tabla tiene capacidad fija de 30 productos: si al agregar se supera el índice 30, emite "B05 CON MAS DE 30 PRODUCTOS" y termina con DMTERMINATE. Un error de find distinto de "vacío" (status 1) también aborta con DMTERMINATE. Es un límite estructural que impone una cota dura al catálogo de productos procesable.

**Fórmula/pseudocódigo:**
```
FIND-NEXT B05INSTRUMEN
IF STATUS-BASE > 0:  =1 → fin ; else → "ERROR FIND B05" ; DMTERMINATE
LLENO-TABPRD:
   ADD 1 TO WS-PRD
   IF WS-PRD > 30 → "B05 CON MAS DE 30 PRODUCTOS" ; DMTERMINATE
   ESQCOM-PRD/INS/MON/IND(WS-PRD) = B05-*
```

**Vocabulario en la fórmula:** B05-ESQ-COMIS · WS-ESQCOM-IND · WS-PRD · B05-NUM-PRODUCTO · DMTERMINATE

**Excepciones:**
- El tope de 30 es un hardcode del tamaño de la tabla; catálogos mayores requieren recompilar.

**Estado validación:** Verificado fuente líneas 1415-1435, 1476-1490

---

## RN-S500-287 — Ajuste de calificación de comisión virtual por producto específico

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-287 |
| **Nombre** | Ajuste de calificación de comisión virtual por producto específico |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P290 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al cargar el esquema de comisiones, P290 sobrescribe el indicador (calificación virtual) para productos específicos identificados por combinaciones producto-instrumento-moneda hardcodeadas. Para los productos 0066-0011-001 y 0066-0017-001 fuerza el indicador a 0 (sin comisión virtual). Para el producto 1, o para el conjunto 0066-0006/0007/0016/0026/0027/0028-001 con esquema 1 o 2, fuerza el indicador a 3. Estas excepciones codifican reglas de negocio de comisiones para líneas de producto puntuales que no siguen el esquema declarado en B05.

**Fórmula/pseudocódigo:**
```
IF PRD-0066-0011-001 OR PRD-0066-0017-001 → ESQCOM-IND = 0
IF B05-ESQ-COMIS = 1 OR 2:
   IF B05-NUM-PRODUCTO = 1
   OR PRD-0066-{0006,0007,0016,0026,0027,0028}-001 → ESQCOM-IND = 3
```

**Vocabulario en la fórmula:** WS-ESQCOM-IND · WS05-88-PRD-0066-0011-001 · B05-ESQ-COMIS · B05-NUM-PRODUCTO

**Excepciones:**
- Los identificadores de producto son literales embebidos; agregar o cambiar productos exige modificar el código.

**Estado validación:** Verificado fuente líneas 1459-1470, 199520-200000

---

## RN-S500-288 — Correspondencia de esquema tarifario S016 contra el asignado en el contrato B03

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-288 |
| **Nombre** | Correspondencia de esquema tarifario S016 contra el asignado en el contrato B03 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P290 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P290 determina la tarifa aplicable cotejando el esquema tarifario del catálogo S016 contra el asignado en el contrato B03. Solo procede cuando la opción de esquema S016 es 1 o 2, el rango de moneda S016 es 1, 2 o 3, el esquema tarifario del contrato (B03-ESQ-TARIFARIO) es 1 o 2 y la moneda asignada (B03-MDA-ASIGNADOS) es 1, 2 o 3. La tarifa se aplica cuando coinciden opción de esquema (S016 = B03-ESQ-TARIFARIO) y rango de moneda (S016 = B03-MDA-ASIGNADOS). Alinea la tarifa vigente del catálogo con la configuración específica de cada contrato.

**Fórmula/pseudocódigo:**
```
IF S016-OPC-ESQ = 1 OR 2
   IF S016-RGO-MDAA = 1 OR 2 OR 3
      IF B03-ESQ-TARIFARIO = 1 OR 2
         IF B03-MDA-ASIGNADOS = 1 OR 2 OR 3
            IF S016-OPC-ESQ = B03-ESQ-TARIFARIO
               IF S016-RGO-MDAA = B03-MDA-ASIGNADOS → aplica tarifa
```

**Vocabulario en la fórmula:** WKS-S016-OPC-ESQ · WKS-S016-RGO-MDAA · B03-ESQ-TARIFARIO · B03-MDA-ASIGNADOS

**Excepciones:**
- Contratos con esquema o moneda fuera de los valores 1-3 no reciben la tarifa por esta rama.

**Estado validación:** Verificado fuente líneas 1734-1776

---

## RN-S500-289 — Reactivación de cuentas a la cuenta origen con generación de archivos S084 y S087

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-289 |
| **Nombre** | Reactivación de cuentas a la cuenta origen con generación de archivos S084 y S087 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P290 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Además del planchado, P290 ejecuta el proceso de reactivación a cuenta origen. Genera archivos de cifras de control de reapertura y, si el control general permite procesar (W77-NO-PROCESO-GEN = 0), recorre la base B51, ordena los pendientes (SORT-PTE) y lee el archivo ordenado para reactivar cada cuenta. Produce los archivos de salida hacia S500 (I03), S084 (E01) y S087 (E02) más el pendiente de reapertura (I04). La generación de estos archivos también está condicionada a que sea domingo o a la opción de forzado de generación (W88-TASK-FGEN).

**Fórmula/pseudocódigo:**
```
PROCESO-REACTIVA:
   ABRE bases y archivos (R02-CIFREAPER, I03-ARCHS500, E01-ARCHS084, E02-ARCHS087, I04-PTEREAPE)
   VALIDA-DOMINGO (o W88-TASK-FGEN forzado)
   IF W77-NO-PROCESO-GEN = 0
      LEE-BASE-B51 hasta EOF
      SORT-PTE
      LEE-PTE-REACT (reactiva por cuenta)
```

**Vocabulario en la fórmula:** B51 · E01-ARCHS084 · E02-ARCHS087 · I04-PTEREAPE · W77-NO-PROCESO-GEN · W88-TASK-FGEN

**Excepciones:**
- Si no es domingo y no hay forzado de generación, no se generan los archivos de reactivación.

**Estado validación:** Verificado fuente líneas 2263-2160 (rango 261000-262160)

---

## RN-S500-290 — Validación de versión exenta en entorno de desarrollo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-290 |
| **Nombre** | Validación de versión exenta en entorno de desarrollo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P290 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P290 exime de la validación de versión al entorno de desarrollo. Si la condición W88-ES-DESARROLLO es verdadera, omite el chequeo (NEXT SENTENCE); en cualquier otro entorno ejecuta CHECAME-VERSION contra el maestro S100. Es el mismo patrón de exención por entorno que P109, aquí basado en un flag de desarrollo en vez del nombre de host.

**Fórmula/pseudocódigo:**
```
IF W88-ES-DESARROLLO
   NEXT SENTENCE   (omite validación)
ELSE
   PERFORM CHECAME-VERSION
```

**Vocabulario en la fórmula:** W88-ES-DESARROLLO · S100VERSIONES · CHECAME-VERSION

**Excepciones:**
- El comportamiento ante versión inválida en producción queda delegado a la rutina CHECAME-VERSION.

**Estado validación:** Verificado fuente líneas 1121-1126

---

## RN-S500-291 — Modo de extracción del B52: mensual completo vs diario incremental por fecha de actualización

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-291 |
| **Nombre** | Modo de extracción del B52: mensual completo vs diario incremental por fecha de actualización |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P164 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P164 genera el archivo de la estructura B52 (control de límites de depósito y retiro) para envío a Teradata. El barrido opera en dos modos. En modo mensual (WKS-ES-MENSUAL = 1) exporta todos los registros del B52. En modo diario (incremental) exporta solo los registros cuya fecha de actualización coincide con la fecha base de la corrida (B52-FEC-UPDATE = WKS-FEC-BASE), es decir el delta de límites modificados en el día. Cada registro escrito incrementa el contador. Optimiza el volumen enviado a Teradata replicando solo cambios en el ciclo diario.

**Fórmula/pseudocódigo:**
```
BARRO-B52 (FIND-NEXT B52CTRLDEPRET hasta status 1):
   IF WKS-ES-MENSUAL = 1 → WRITE-ARCHIVO ; +CONTADOR
   ELSE IF B52-FEC-UPDATE = WKS-FEC-BASE → WRITE-ARCHIVO ; +CONTADOR
```

**Vocabulario en la fórmula:** WKS-ES-MENSUAL · B52-FEC-UPDATE · WKS-FEC-BASE · WKS-CONTADOR

**Excepciones:**
- Un error de FIND-NEXT distinto de fin de datos (status 1) aborta con DMTERMINATE.

**Estado validación:** Verificado fuente líneas 1186-1210

---

## RN-S500-292 — Validación del parámetro de fecha en TASKVALUE (año, mes y día)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-292 |
| **Nombre** | Validación del parámetro de fecha en TASKVALUE (año, mes y día) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P164 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P164 recibe su fecha de proceso opcional por el atributo TASKVALUE del task. Si el tipo de proceso es 3 y viene fecha (TSK-FECH mayor que 0) lo considera inválido (combinación no permitida) y aborta. Si viene fecha en otro modo, valida que el año sea mayor que 2009, el mes esté entre 1 y 12 y el día entre 1 y 31; si no cumple, emite "ERROR TASKVALUE" y termina con DMTERMINATE. Protege contra ejecuciones con fechas mal formadas pasadas por el operador.

**Fórmula/pseudocódigo:**
```
TASKVALUE → WKS-TASKVALUE (proceso, fecha AA/MM/DD)
IF WKS-TSK-PROCESO = 3 AND WKS-TSK-FECH > 0 → "ERROR TASKVALUE" ; DMTERMINATE
ELSE IF WKS-TSK-FECH > 0
   IF AA > 2009 AND MM 1..12 AND DD 1..31 → OK
   ELSE → "ERROR TASKVALUE" ; DMTERMINATE
```

**Vocabulario en la fórmula:** WKS-TASKVALUE · WKS-TSK-PROCESO · WKS-TSK-FECH · WKS-TSK-AA · WKS-TSK-MM · WKS-TSK-DD

**Excepciones:**
- El año mínimo 2009 es un hardcode; fechas anteriores se rechazan aunque sean válidas de calendario.

**Estado validación:** Verificado fuente líneas 273-285

---

## RN-S500-293 — Mapeo de host origen y destino para transferencia entre equipos (replica)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-293 |
| **Nombre** | Mapeo de host origen y destino para transferencia entre equipos (replica) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P164 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P164 identifica su host de ejecución y determina el par origen-destino de transferencia de archivos según una tabla de mapeo hardcodeada de nombres de equipo. Por ejemplo VDMBETA transfiere hacia ACYPBETA y viceversa; ACYPGAMA hacia MONALFA; ACYPOMEGA hacia VDMKAPPA; VDMALFA hacia MONBETA; y sus recíprocos. El par se usa con la librería ADMONXFERS para replicar el archivo generado al host contraparte. Codifica la topología de replicación multi-host del entorno ClearPath MCP.

**Fórmula/pseudocódigo:**
```
IF WS-DH-NOM-EQUIPO = "VDMBETA."  → ORIG=VDMBETA  DEST=ACYPBETA
IF = "ACYPBETA."  → ORIG=ACYPBETA  DEST=VDMBETA
IF = "ACYPGAMA."  → ORIG=ACYPGAMA  DEST=MONALFA
IF = "MONALFA."   → ORIG=MONALFA   DEST=ACYPGAMA
IF = "ACYPOMEGA." → ORIG=ACYPOMEGA DEST=VDMKAPPA
IF = "VDMKAPPA."  → ORIG=VDMKAPPA  DEST=ACYPOMEGA
IF = "VDMALFA."   → ORIG=VDMALFA   DEST=MONBETA
IF = "MONBETA."   → ORIG=MONBETA   DEST=VDMALFA
```

**Vocabulario en la fórmula:** WS-DH-NOM-EQUIPO · WKS-HOST-ORIG-XFER-XX · WKS-HOST-DEST-XFER-XX · ADMONXFERS

**Excepciones:**
- Un host no listado en la tabla no obtiene par de transferencia; agregar nodos exige modificar el código.

**Estado validación:** Verificado fuente líneas 1000-1034

---

## RN-S500-294 — Exportación de pagos pendientes B25 filtrada por fecha de último pago con limpieza de nulos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-294 |
| **Nombre** | Exportación de pagos pendientes B25 filtrada por fecha de último pago con limpieza de nulos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P164 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P164 también exporta la estructura B25 (pagos pendientes). Solo escribe los registros cuya fecha de último pago coincide con la fecha base (B25-FECHA-ULTPAGO = WKS-FEC-BASE). Antes de escribir, sanea el campo de referencia alfanumérica (B25-REFER-ALFA): recorre sus 40 posiciones eliminando caracteres nulos vía la rutina VALIDA-NUL para evitar exportar bytes nulos que corromperían la carga en Teradata. Cada registro válido incrementa su contador.

**Fórmula/pseudocódigo:**
```
BARRO-B25 (FIND-NEXT B25PGOSPENDPE):
   IF B25-FECHA-ULTPAGO = WKS-FEC-BASE
      VALIDA-NUL sobre B25-REFER-ALFA (posiciones 1..40) → sin nulos
      WRITE-ARCHIVO-B25 ; +CONT-B25
```

**Vocabulario en la fórmula:** B25-FECHA-ULTPAGO · WKS-FEC-BASE · B25-REFER-ALFA · WS-LEY-SIN-NULOS

**Excepciones:**
- Un error de FIND-NEXT distinto de fin de datos aborta con DMTERMINATE.

**Estado validación:** Verificado fuente líneas 1210-1226

---

## RN-S500-295 — Composición del registro de detalle B52 con límites de depósito y retiro

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-295 |
| **Nombre** | Composición del registro de detalle B52 con límites de depósito y retiro |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P164 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de detalle que P164 escribe hacia Teradata materializa el perfil transaccional de límites del cliente. Incluye número de cliente, CSI de origen, fecha de actualización y de creación, tipo de persona, ubicación geográfica, y los cuatro límites regulatorios/comerciales: límite de depósito diario y mensual (LIM-DEP-DIA, LIM-DEP-MEN) y límite de retiro diario y mensual (LIM-RET-DIA, LIM-RET-MEN), junto con sus fechas de límite, el indicador de bloqueo y su fecha. Estos límites son el insumo del control de retiros y depósitos analizado en Teradata (prevención de lavado y control de riesgo transaccional).

**Fórmula/pseudocódigo:**
```
DET.NUM-CLIENTE   = B52-NUM-CLIENTE
DET.CSI           = WKS-HED-CSI-ORI
DET.LIM-DEP-DIA   = B52-LIM-DEP-DIA
DET.LIM-DEP-MEN   = B52-LIM-DEP-MEN
DET.LIM-RET-DIA   = B52-LIM-RET-DIA
DET.LIM-RET-MEN   = B52-LIM-RET-MEN
DET.IND-BLOQUEO   = B52-IND-BLOQUEO ; DET.FEC-BLOQUEO = B52-FEC-BLOQUEO
```

**Vocabulario en la fórmula:** B52-LIM-DEP-DIA · B52-LIM-DEP-MEN · B52-LIM-RET-DIA · B52-LIM-RET-MEN · B52-IND-BLOQUEO

**Excepciones:**
- Ninguna; el mapeo es directo campo a campo.

**Estado validación:** Verificado fuente líneas 1262-1272, 400000-422000

---

## RN-S500-296 — Validación de versión exenta en host de pruebas (P164)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-296 |
| **Nombre** | Validación de versión exenta en host de pruebas (P164) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P164 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P164 exime de la validación de versión a los hosts de prueba. Solo si el host NO es de pruebas (NOT WS-DH-HOSTNAME-PBA) ejecuta CHECAME-VERSION; si la versión difiere (S000-CTR-CVEERROR menor que cero), emite "ERROR DE VERSION" y cambia STATUS a -1. Es el patrón de exención por entorno, aquí gobernado por el flag de host de pruebas derivado del nombre de equipo.

**Fórmula/pseudocódigo:**
```
IF NOT WS-DH-HOSTNAME-PBA
   PERFORM CHECAME-VERSION
   IF S000-CTR-CVEERROR < 0 → "ERROR DE VERSION" ; STATUS = -1
```

**Vocabulario en la fórmula:** WS-DH-HOSTNAME-PBA · S000-CTR-CVEERROR · STATUS · S100VERSIONES

**Excepciones:**
- Ninguna.

**Estado validación:** Verificado fuente líneas 304-309

---

## RN-S500-297 — Despachador de funciones del informe de saldos (0, 1-4-7, 2-5-8, 3-6-9)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-297 |
| **Nombre** | Despachador de funciones del informe de saldos (0, 1-4-7, 2-5-8, 3-6-9) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P115 es multi-función: un parámetro WKS-FUNCION selecciona qué produce. Función 0 imprime el listado de lo enviado, cuentas marcadas y saldo final. Funciones 1, 4 y 7 generan los archivos de saldos por sitio (I10, I10PS, I10PS2 respectivamente) para VDM y MTY. Funciones 2, 5 y 8 consolidan el archivo unificado con la información de VDM más MTY. Funciones 3, 6 y 9 generan el archivo solo con la información de VDM. Cualquier otro valor produce "ERROR FUNCION INVALIDA". Los tres archivos representan tres cortes de saldo: I10 al fin de día, I10PS después de balanceo, I10PS2 después de rendimientos y comisiones.

**Fórmula/pseudocódigo:**
```
IF WKS-FUNCION = 0        → FUNCION-0 (informe)
ELSE IF = 1 OR 4 OR 7     → FUNCION-1-4-7 (genera VDM/MTY)
ELSE IF = 2 OR 5 OR 8     → FUNCION-2-5-8 (consolida VDM+MTY)
ELSE IF = 3 OR 6 OR 9     → FUNCION-3-6-9 (solo VDM)
ELSE → "ERROR FUNCION INVALIDA"
```

**Vocabulario en la fórmula:** WKS-FUNCION · I10 · I10PS · I10PS2

**Excepciones:**
- Función inválida solo emite mensaje; no aborta con terminación dura.

**Estado validación:** Verificado fuente líneas 723-737, 398-402 (leyendas de archivos)

---

## RN-S500-298 — Apertura de base en UPDATE solo para funciones generadoras

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-298 |
| **Nombre** | Apertura de base en UPDATE solo para funciones generadoras |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P115 abre la base de captación con el modo mínimo necesario. Solo las funciones 1, 4 y 7 (que generan archivos y marcan cuentas actualizando B03) abren en modo UPDATE; todas las demás funciones abren en INQUIRY (solo lectura). Es una salvaguarda de principio de menor privilegio que impide que las funciones de consolidación o informe modifiquen accidentalmente la base.

**Fórmula/pseudocódigo:**
```
IF WKS-FUNCION = 1 OR 4 OR 7
   OPEN UPDATE S500BD01CAPTACION
ELSE
   OPEN INQUIRY S500BD01CAPTACION
```

**Vocabulario en la fórmula:** WKS-FUNCION · S500BD01CAPTACION · UPDATE · INQUIRY

**Excepciones:**
- Ninguna.

**Estado validación:** Verificado fuente líneas 820-823

---

## RN-S500-299 — Clasificación de entorno y validación de TASKVALUE en producción

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-299 |
| **Nombre** | Clasificación de entorno y validación de TASKVALUE en producción |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P115 clasifica el entorno a partir del nombre de host: producción (WS-DH-HOSTNAME-PROD), UAT, o desarrollo (hosts PBA o SIT); un host desconocido se trata como UAT por defecto. Con esa clasificación aplica un candado: si viene un TASKVALUE mayor que cero y el entorno es producción y el valor implica correr sin librería S408 (WKS-SIN-LBS408 mayor que 0), lo considera "VALUE INVALIDO EN PRODUCCION" y cambia STATUS a -1. Impide que en producción se ejecute el modo de prueba que omite la línea de crédito S408.

**Fórmula/pseudocódigo:**
```
IF HOSTNAME-PROD → ES-PRODUCCION=1
ELSE IF HOSTNAME-UAT → ES-UAT=1
ELSE IF HOSTNAME-PBA OR HOSTNAME-SIT → ES-DESARROLLO=1
ELSE → ES-UAT=1
IF WKS-TASKVALUE-PBA > 0 AND ES-PRODUCCION=1 AND WKS-SIN-LBS408 > 0
   MENSAJE "VALUE INVALIDO EN PRODUCCION" ; STATUS = -1
```

**Vocabulario en la fórmula:** WS-DH-HOSTNAME-PROD · W77-ES-PRODUCCION · WKS-TASKVALUE-PBA · WKS-SIN-LBS408

**Excepciones:**
- Un host no reconocido cae a UAT, no a producción (fail-safe conservador).

**Estado validación:** Verificado fuente líneas 753-778

---

## RN-S500-300 — Identificación XATMI: interactiva en desarrollo, aborto en producción

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-300 |
| **Nombre** | Identificación XATMI: interactiva en desarrollo, aborto en producción |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P115 se identifica en XATMI (TP_IDENTIFY con "S500P115") para dialogar con el S408. Si el identify falla (WS-XATMI-RSLT distinto de 0), la reacción depende del entorno: en desarrollo detiene con un STOP interactivo ofreciendo al operador "OK PARA CONTINUAR" o "DS PARA TERMINAR", permitiendo seguir la prueba sin S408; en producción o UAT cambia STATUS a -1 y aborta. Diferencia el rigor operativo entre pruebas y producción.

**Fórmula/pseudocódigo:**
```
CALL "TP_IDENTIFY IN XATMI" USING "S500P115" GIVING WS-XATMI-RSLT
IF WS-XATMI-RSLT NOT = 0
   MENSAJE "ERROR AL IDENTIFICAR XATMI"
   IF W77-ES-DESARROLLO = 1 → STOP "(OK PARA CONTINUAR) O (DS PARA TERMINAR)"
   ELSE → STATUS = -1
```

**Vocabulario en la fórmula:** WS-XATMI-RSLT · TP_IDENTIFY · W77-ES-DESARROLLO · COMSSUPPORT

**Excepciones:**
- El modo interactivo solo existe en desarrollo; en producción la falla es fatal.

**Estado validación:** Verificado fuente líneas 828-841

---

## RN-S500-301 — Acumulación de saldo disponible separada por moneda con escala de decimales

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-301 |
| **Nombre** | Acumulación de saldo disponible separada por moneda con escala de decimales |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al totalizar saldos del archivo I10, P115 procesa solo los registros de detalle (I10-TPOREG = "485") y separa los totales por moneda SWIFT. Si la moneda es "MXN" suma al total en pesos y al contador de cuentas MXN; cualquier otra moneda (USD) va a los totales y contador en dólares. La parte decimal se obtiene dividiendo I10-DEC-SDO-DISP entre 1000 (los decimales vienen en milésimas) y se combina con la parte entera del saldo disponible respetando el signo (I10-SIGNO-SDO-DISP): resta si es negativo, suma si es positivo. Produce un cuadre de saldo disponible bimoneda.

**Fórmula/pseudocódigo:**
```
IF I10-TPOREG = "485"
   IF I10-MONEDASWIFT = "MXN"
      +NUM-CTAS ; IMP-DEC = I10-DEC-SDO-DISP / 1000
      TOT-SDO-DISP += (signo "-"? -(SDO+IMP-DEC) : +(SDO+IMP-DEC))
   ELSE (USD)
      +NUM-CTAS-USD ; IMP-DEC = I10-DEC-SDO-DISP / 1000
      TOT-SDO-DISP-USD += (signo "-"? -(SDO+IMP-DEC) : +(SDO+IMP-DEC))
```

**Vocabulario en la fórmula:** I10-TPOREG · I10-MONEDASWIFT · I10-DEC-SDO-DISP · I10-SIGNO-SDO-DISP · W77-TOT-SDO-DISP · W77-TOT-SDO-DISP-USD

**Excepciones:**
- El literal "485" identifica el registro de detalle y el divisor 1000 es la escala fija de decimales.
- Toda moneda distinta de MXN se agrega al total USD sin distinguir otras divisas.

**Estado validación:** Verificado fuente líneas 1148-1165

---

## RN-S500-302 — Lectura obligatoria del registro de control B02 (fecha de lote y CSI)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-302 |
| **Nombre** | Lectura obligatoria del registro de control B02 (fecha de lote y CSI) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Tras abrir la base, P115 lee el registro de control B02 para obtener la fecha de lote (fecha base de proceso) y el CSI de la instalación. Si el FIND falla (WS-STATUS-BASE mayor que cero) emite "ERR FIND B02CONTROL" con el status y termina con DMTERMINATE. La fecha de lote (B02-FECHA-LOTE) se propaga como fecha base de todos los títulos de los archivos I7, I10, I10PS. Sin el registro de control no hay fecha ni CSI de referencia, por lo que su ausencia es fatal.

**Fórmula/pseudocódigo:**
```
B02CONTROL-FIND
IF WS-STATUS-BASE > 0 → "ERR FIND B02CONTROL" + STATUS ; DMTERMINATE
W77-MY-CSI  = B02-NUM-CSI
WKS-FEC-BASE = B02-FECHA-LOTE  → títulos I7/I10/I10PS
```

**Vocabulario en la fórmula:** B02CONTROL · WS-STATUS-BASE · B02-NUM-CSI · B02-FECHA-LOTE · WKS-FEC-BASE

**Excepciones:**
- Ninguna; el registro de control es obligatorio.

**Estado validación:** Verificado fuente líneas 825-834
