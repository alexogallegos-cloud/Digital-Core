# Catálogo de Reglas de Negocio — S151 Contabilidad GL A
**Versión:** 1.0 — 2026-07-17
**Programas fuente:** P107 · P167 · P169 · P115 · P135 · P177 · P110 · P117 · P104 · P172 · P116 · P197 · P111 · P128
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Numeración:** RN-S151-750 a RN-S151-822 (73 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S151-750 — Clasificación contable del movimiento por naturaleza NATS28 (cargo/abono/no contable)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-750 |
| **Nombre** | Clasificación contable del movimiento por naturaleza NATS28 (cargo/abono/no contable) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada movimiento vivo se clasifica contablemente según su naturaleza `RM-NATS28`: valor 1 es CARGO, valor 2 es ABONO, cualquier otro valor se marca "N/C" (no contable). Esta clasificación gobierna en qué acumulador (cargos, abonos o no-contable) suma el importe y es la base del cuadre contable posterior.

**Fórmula/pseudocódigo:**
```
IF RM-ESTATUS = 1
   IF RM-NATS28 = 1   -> concepto "CAR"; num-cargos += 1; imp-cargos += RM-IMPORTE
   ELSE IF RM-NATS28 = 2 -> concepto "ABO"; num-abonos += 1; imp-abonos += RM-IMPORTE
   ELSE               -> concepto "N/C"; num-ncont += 1; imp-ncont += RM-IMPORTE
ELSE
   concepto "ELI" (movimiento eliminado, no acumula)
```

**Vocabulario en la fórmula:** RM-NATS28 · RM-ESTATUS · RM-IMPORTE · CARGO · ABONO

**Excepciones:**
- Si `RM-ESTATUS` ≠ 1 el movimiento se etiqueta "ELI" (eliminado) y no participa en ningún acumulador contable.
- Naturalezas distintas de 1 y 2 caen a "N/C" sin abortar el proceso (tolerancia a datos no clasificados).

**Estado validación:** Verificado fuente líneas 7935-7950

---

## RN-S151-751 — Selección de autorización: nivel operativo vs. autorización de tercer nivel

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-751 |
| **Nombre** | Selección de autorización: nivel operativo vs. autorización de tercer nivel |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La autorización reportada del movimiento en la bitácora depende de si existe autorización de tercer nivel. Si `RM-AUT-3NIVEL` es 0, se usa la autorización aplicativa `RM-AUT-APLIC`; en caso contrario prevalece la autorización de tercer nivel `RM-AUT-3NIVEL`. Refleja el control de segregación de facultades sobre operaciones contables.

**Fórmula/pseudocódigo:**
```
IF RM-AUT-3NIVEL = 0
   WSR-AUTORIZACION = RM-AUT-APLIC
ELSE
   WSR-AUTORIZACION = RM-AUT-3NIVEL
```

**Vocabulario en la fórmula:** RM-AUT-3NIVEL · RM-AUT-APLIC · WSR-AUTORIZACION

**Excepciones:**
- La ausencia de autorización de tercer nivel (valor 0) no invalida el movimiento; simplemente hereda la autorización aplicativa.

**Estado validación:** Verificado fuente líneas 7917-7920

---

## RN-S151-752 — Cuadre contable de la corrida: suma de cargos debe igualar suma de abonos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-752 |
| **Nombre** | Cuadre contable de la corrida: suma de cargos debe igualar suma de abonos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa acumula por proceso los importes de cargos (`WKS-CC-CARGOS`) y abonos (`WKS-CC-ABONOS`) y produce el archivo/reporte de cuadre contable (CUADRECON). La partida doble exige que el total de cargos iguale al total de abonos; una diferencia distinta de cero es un descuadre contable que debe reportarse para no propagar información desbalanceada al libro mayor.

**Fórmula/pseudocódigo:**
```
WKS-CC-CARGOS = Σ importe de movimientos con NATS28 = 1
WKS-CC-ABONOS = Σ importe de movimientos con NATS28 = 2
descuadre = WKS-CC-CARGOS - WKS-CC-ABONOS
cuadre_ok  <=> descuadre = 0
```

**Vocabulario en la fórmula:** WKS-CC-CARGOS · WKS-CC-ABONOS · CUADRECON · partida doble

**Excepciones:**
- Movimientos "N/C" (no contables) y "ELI" (eliminados) no participan del cuadre.
- El descuadre no aborta la corrida: se reporta y se entrega al control de la compensadora.

**Estado validación:** Verificado fuente líneas 4876-4890, 3673

---

## RN-S151-753 — Parametrización del sistema origen (252 / 402 / 600) que rige nomenclatura y servicio

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-753 |
| **Nombre** | Parametrización del sistema origen (252 / 402 / 600) que rige nomenclatura y servicio |
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
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa recibe el número de sistema origen como parámetro (`W77-SISTEMA-PARAM`) y ajusta su comportamiento: si es 252 usa ese sistema como interlocutor con servicio 1; en otro caso opera como S151 (sistema 151) y define el servicio según el origen (402 → servicio 2, 600 → servicio 4). Además, para sistemas 402 o 600 conmuta la nomenclatura de archivos a modo "C" (central), y para el resto a modo "S".

**Fórmula/pseudocódigo:**
```
IF W77-SISTEMA-PARAM = 252 -> WKS-INT-SIS = 252; servicio = 1
ELSE
   WKS-INT-SIS = 151
   IF WKS-SISTEMA = 402 -> WKS-INT-SERV-600 = 2
   IF WKS-SISTEMA = 600 -> WKS-INT-SERV-600 = 4
IF WKS-SISTEMA = 402 OR 600 -> modo archivos = "C"  ELSE modo = "S"
```

**Vocabulario en la fórmula:** W77-SISTEMA-PARAM · WKS-SISTEMA · WKS-INT-SERVICIO · WKS-INT-SERV-600

**Excepciones:**
- Los valores 252, 402, 600 están embebidos en código (números mágicos de ruteo de sistema origen).

**Estado validación:** Verificado fuente líneas 5131-5158

---

## RN-S151-754 — Control de versión de librería contable vía CTLVERS con fallback a librería sin release

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-754 |
| **Nombre** | Control de versión de librería contable vía CTLVERS con fallback a librería sin release |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de procesar, el programa resuelve el título físico de la librería de control contable (`S151L001CTL`) llamando a `DAME_TIT IN CTRLVERS`. Si el estatus de control de versiones es negativo (falla), registra un log de incidente y usa por defecto la librería fija `(S151)S151/OBJECT/L001/CONTROL ON CMEMP` sin release ni MTP; si tiene éxito, usa el título resuelto por CTLVERS.

**Fórmula/pseudocódigo:**
```
CALL DAME_TIT IN CTRLVERS (S151L001CTL) GIVING status
IF status < 0
   log "ERROR EN CTLVERS, USO LIBRERIA DE CONTROL SIN RELEASE NI MTP"
   titulo = "(S151)S151/OBJECT/L001/CONTROL ON CMEMP"
ELSE
   titulo = WKS-CTLVERS-TITULO
```

**Vocabulario en la fórmula:** CTRLVERS · DAME_TIT · S151LIBCONTROL · WKS-CTLVERS-STATUS

**Excepciones:**
- El fallback silencioso a una versión fija puede ejecutar lógica contable desactualizada sin abortar; riesgo de gobierno de versiones.

**Estado validación:** Verificado fuente líneas 5190-5208

---

## RN-S151-755 — Manejo de defaults para datos erróneos y bitácora de rechazos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-755 |
| **Nombre** | Manejo de defaults para datos erróneos y bitácora de rechazos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa está diseñado para no detenerse ante datos erróneos: aplica valores default a los campos inválidos, continúa la actualización de conceptos en `S151BD11SDOS`, y desvía los movimientos con error a un archivo/reporte de rechazos con totales acumulados. La descripción del catálogo se rellena con "DESCONOCIDA" cuando la clave no existe en catálogo.

**Fórmula/pseudocódigo:**
```
IF concepto/clave no está en catálogo
   WSR-DC-CONCEPTO = "DESCONOCIDA"
movimiento con error -> MOVCONERROR / reporte RECHAZOS con acumulación de totales
resto del proceso continúa (no abort)
```

**Vocabulario en la fórmula:** default · WSR-DC-CONCEPTO · MOVCONERROR · RECHAZOS

**Excepciones:**
- La tolerancia a defaults puede enmascarar problemas de calidad de datos; los rechazos requieren revisión manual posterior.

**Estado validación:** Verificado fuente líneas 8144-8146; cabecera 6-10

---

## RN-S151-756 — Generación de saldos de contratos S500 sólo para productos 001 (cheques) y 066 (cuenta maestra)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-756 |
| **Nombre** | Generación de saldos de contratos S500 sólo para productos 001 (cheques) y 066 (cuenta maestra) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P167 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** A partir del archivo de saldos SDOS del S151, el programa genera archivos de saldos de contratos del sistema S500 filtrando exclusivamente los productos 001 (cheques) y 066 (cuenta maestra). Produce `SDO0001` y `SD00066` para el sistema S050 (estados de cuenta), mapeando cada producto a su descripción ("001CHEQUES", "500CTA. MAESTRA").

**Fórmula/pseudocódigo:**
```
para cada saldo SDOS:
   IF producto = 001 -> archivo SDO0001 (CHEQUES)
   IF producto = 066 -> archivo SD00066 (CTA. MAESTRA)
   otros productos -> excluidos
```

**Vocabulario en la fórmula:** producto 001 · producto 066 · cheques · cuenta maestra · SDO0001 · SD00066

**Excepciones:**
- Productos distintos de 001 y 066 no generan salida en este paso.

**Estado validación:** Verificado fuente líneas 10-19, 6456-6457

---

## RN-S151-757 — Interface de saldos hacia CITI (ACC CBII) condicionada por producto e indicador de envío

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-757 |
| **Nombre** | Interface de saldos hacia CITI (ACC CBII) condicionada por producto e indicador de envío |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P167 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa genera adicionalmente el archivo de saldos para CITI (ACC CBII). El envío al archivo CBII se condiciona a que la secuencia de parámetro sea 1 y a que el producto sea de cheques con indicador de envío a cuenta destino en {1, 2}, materializando la separación de la interfaz de saldos hacia el corresponsal Citi.

**Fórmula/pseudocódigo:**
```
IF WKS-PARAM-SECUENCIA = 1 AND
   (A22-R01-PRD = 1 AND (A22-R01-INDENVCTD = 1 OR 2))
   -> generar registro SDOSCBII para CITI
```

**Vocabulario en la fórmula:** WKS-PARAM-SECUENCIA · A22-R01-PRD · A22-R01-INDENVCTD · CBII · CITI

**Excepciones:**
- El indicador de envío (`INDENVCTD`) distinto de 1 o 2 excluye el contrato del envío a Citi.

**Estado validación:** Verificado fuente líneas 7099-7103, 20-22

---

## RN-S151-758 — Resolución de contratos duplicados de cuenta maestra vía parámetro B04XCTODUPLI

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-758 |
| **Nombre** | Resolución de contratos duplicados de cuenta maestra vía parámetro B04XCTODUPLI |
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
| **Programa ejecutor** | P167 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cuentas maestra el programa consulta el parámetro `S016_L422_B04XCTODUPLI` que resuelve contratos duplicados: dado un número de cuenta preferente y número de cuenta, devuelve el producto, clave de instrumento y número de cuenta canónicos, o un código de error de estructura. Evita que un mismo contrato de cuenta maestra genere saldos duplicados en el estado de cuenta y en la interfaz Citi.

**Fórmula/pseudocódigo:**
```
CALL B04XCTODUPLI(151) USING (NUMPREF, NUM)
   -> SALIDA: NUMPROD, CVEINST, NUMPREF, NUM   (contrato canónico)
   -> o SALIDA-ERROR: CTR-ERROR, CTR-ERRORTYPE, CTR-STRUCTURE
```

**Vocabulario en la fórmula:** B04XCTODUPLI · contrato duplicado · cuenta maestra · NUMPROD · CVEINST

**Excepciones:**
- Ante error de estructura (`CTR-ERRORTYPE` ≠ 0) el contrato no se normaliza; requiere tratamiento de excepción.

**Estado validación:** Verificado fuente líneas 5437-5463

---

## RN-S151-759 — Archivo monitor de control de la corrida de saldos S500

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-759 |
| **Nombre** | Archivo monitor de control de la corrida de saldos S500 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P167 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La corrida de generación de saldos produce un archivo MONITOR y un reporte de cifras de control (`R01-CIFRAS`) que registran el conteo de registros leídos del SDOS de entrada y escritos hacia cada salida (S050, Citi). Es el mecanismo de conciliación entrada-vs-salida que permite detectar pérdidas de registros entre sistemas.

**Fórmula/pseudocódigo:**
```
al cierre:
   MONITOR = { leídos SDOS, escritos SDO0001, escritos SD00066, escritos CBII/CITD }
   R01-CIFRAS = reporte impreso de esas cifras de control
```

**Vocabulario en la fórmula:** MONITOR · R01-CIFRAS · cifras de control · conciliación

**Excepciones:**
- Ninguna documentada; el monitor es informativo y no aborta la corrida.

**Estado validación:** Verificado fuente líneas 33-35 (SELECT A06-MONITOR, R01-CIFRAS)

---

## RN-S151-760 — Segregación del saldo en importe cuenta, importe en moneda local y disponible con signo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-760 |
| **Nombre** | Segregación del saldo en importe cuenta, importe en moneda local y disponible con signo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P167 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de saldo hacia Citi (`SDOSCBII-T`) segrega tres importes independientes cada uno con su signo explícito: saldo en la moneda de la cuenta (`ACCI-ACCT-BAL-AMT` + signo), saldo en moneda local (`ACCI-LCY-ACCT-BAL-AMT` + signo) y saldo disponible (`ACCI-DISP-VAL-BAL-AMT` + signo). El signo se transmite en campo separado (X(01)) en lugar de signo embebido, patrón típico de intercambio con core internacional.

**Fórmula/pseudocódigo:**
```
registro CBII:
   ACCT-BAL-AMT  9(15)V99  + ACCT-BAL-AMT-SIGN  X(01)
   LCY-ACCT-BAL-AMT 9(15)V99 + LCY-BAL-AMT-SIGN X(01)
   DISP-VAL-BAL-AMT 9(15)V99 + DISP-BAL-AMT-SIGN X(01)
```

**Vocabulario en la fórmula:** ACCI-ACCT-BAL-AMT · ACCI-LCY-ACCT-BAL-AMT · ACCI-DISP-VAL-BAL-AMT · signo · moneda local

**Excepciones:**
- El signo en campo separado exige mapeo explícito en cualquier reescritura (riesgo de inversión de signo).

**Estado validación:** Verificado fuente líneas 84-89

---

## RN-S151-761 — Doble interfaz de saldos S500: CITI (ACC CITD) y BNE en la misma corrida

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-761 |
| **Nombre** | Doble interfaz de saldos S500: CITI (ACC CITD) y BNE en la misma corrida |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P169 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P169 genera en una sola corrida dos interfaces de saldos de contratos S500 hacia dos destinos distintos: el archivo de saldos para CITI (ACC CITD, registro de 385 bytes) y el archivo de saldos para BNE, cada uno con su propio archivo monitor de control. Comparten el registro base pero se escriben por separado.

**Fórmula/pseudocódigo:**
```
para cada saldo:
   WRITE R05-SDOSCITD  (interfaz CITI ACC CITD)
   si aplica envío BNE -> WRITE R05-SDOSBNE (interfaz BNE)
MONITOR y MONITOR-BNE registran cifras de cada destino
```

**Vocabulario en la fórmula:** SDOSCITD · SDOSBNE · CITD · BNE · MONITOR-BNE

**Excepciones:**
- Cada destino mantiene su propio monitor; la falla de una interfaz no bloquea la otra.

**Estado validación:** Verificado fuente líneas 26-32, 7362, 7786

---

## RN-S151-762 — Envío a BNE condicionado por indicador INDENVBNE y nombre de host

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-762 |
| **Nombre** | Envío a BNE condicionado por indicador INDENVBNE y nombre de host |
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
| **Programa ejecutor** | P169 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de un contrato se replica hacia la interfaz BNE únicamente cuando el indicador de envío a BNE (`A22-R01-INDENVBNE`) es 1 y la condición de nombre de host (`W88-HOSTNAME`) se cumple. Al satisfacerse, el registro CITD se copia como base del registro BNE.

**Fórmula/pseudocódigo:**
```
IF A22-R01-INDENVBNE = 1 AND W88-HOSTNAME
   MOVE R04-SDOSCITD-T TO R04-SDOSBNE-T
   ... WRITE R05-SDOSBNE
```

**Vocabulario en la fórmula:** A22-R01-INDENVBNE · W88-HOSTNAME · SDOSBNE · SDOSCITD-T

**Excepciones:**
- Indicador ≠ 1 o host no coincidente excluye el contrato del envío a BNE (dependencia de ambiente/host embebida).

**Estado validación:** Verificado fuente líneas 6976-6978

---

## RN-S151-763 — Tratamiento de saldo disponible negativo en la interfaz BNE

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-763 |
| **Nombre** | Tratamiento de saldo disponible negativo en la interfaz BNE |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P169 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de escribir el registro de saldo, el programa evalúa el signo del saldo disponible (`ACCI-DISP-VAL-BAL-AMT-BNE-T`). Cuando el disponible es negativo (sobregiro) se ejecuta el tratamiento específico de signo antes de transmitirlo al corresponsal, garantizando que el saldo deudor se represente correctamente en la interfaz.

**Fórmula/pseudocódigo:**
```
IF ACCI-DISP-VAL-BAL-AMT-BNE-T < 0
   marcar signo/indicador de saldo deudor en el registro de salida
```

**Vocabulario en la fórmula:** ACCI-DISP-VAL-BAL-AMT-BNE-T · saldo disponible · sobregiro · signo

**Excepciones:**
- Saldo disponible ≥ 0 se transmite como acreedor sin ajuste de signo.

**Estado validación:** Verificado fuente líneas 7778, 7849

---

## RN-S151-764 — Enriquecimiento de saldos con librería S408 antes de transmitir al corresponsal

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-764 |
| **Nombre** | Enriquecimiento de saldos con librería S408 antes de transmitir al corresponsal |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P169 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa invoca repetidamente la librería/servicio S408 (`300-LLAMA-S408-BNE UNTIL W88-S408-OK`) para completar o validar la información de saldo antes de escribir el registro hacia BNE. El patrón "PERFORM UNTIL OK" implementa un reintento hasta obtener respuesta satisfactoria del servicio externo.

**Fórmula/pseudocódigo:**
```
PERFORM 300-LLAMA-S408-BNE UNTIL W88-S408-OK
PERFORM 320-LEE-BNE-T UNTIL W88-FINLOG
```

**Vocabulario en la fórmula:** S408 · W88-S408-OK · W88-FINLOG · corresponsal

**Excepciones:**
- Un servicio S408 que nunca retorne OK produciría un bucle; no se observa límite de reintentos explícito (riesgo de cuelgue).

**Estado validación:** Verificado fuente líneas 7719-7720

---

## RN-S151-765 — Estructura de header por corresponsal (record type y llave sucursal-cliente)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-765 |
| **Nombre** | Estructura de header por corresponsal (record type y llave sucursal-cliente) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P169 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada archivo de saldos hacia corresponsal se inicializa con un header y la llave de negocio se compone de tipo de registro (`RECORD-TYPE`), número de sucursal (`BRCH-NBR`), cliente general (`GEN-CUST`), código de divisa (`CCY-CODE`), número de cuenta y número de responsabilidad (`LIA-NBR`). Para BNE el cliente general se amplía a 12 dígitos (vs. 11 en CITD), reflejando una llave de cuenta distinta por corresponsal.

**Fórmula/pseudocódigo:**
```
KEY-GRP = BRCH-NBR(3) + GEN-CUST(11 CITD / 12 BNE) + CCY-CODE(3) + ACCT-NBR(11) + LIA-NBR(11)
PERFORM 100-020-INICIALIZA-HEADER-BNE  antes de escribir detalle
```

**Vocabulario en la fórmula:** ACCI-RECORD-TYPE · ACCI-BRCH-NBR · ACCI-GEN-CUST · ACCI-CCY-CODE · ACCI-LIA-NBR

**Excepciones:**
- La diferencia de longitud de `GEN-CUST` entre CITD (11) y BNE (12) es crítica en cualquier reescritura de la interfaz.

**Estado validación:** Verificado fuente líneas 124-129, 6775

---

## RN-S151-766 — Compensación contable regional vs. nacional: dos interfaces de salida diferenciadas

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-766 |
| **Nombre** | Compensación contable regional vs. nacional: dos interfaces de salida diferenciadas |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P115 realiza el control y compensación regional de operaciones en línea, produciendo dos interfaces de compensación contable: una hacia el sistema S028 paso 010 para compensación contable regional, y otra hacia el sistema S030 paso 140 en el CSI corporativo para la compensación contable nacional. La compensación regional agrupa operaciones foráneas; la nacional consolida en el corporativo.

**Fórmula/pseudocódigo:**
```
por cada operación en línea:
   -> interfaz S028 paso 010  (compensación regional)
   si CSI corporativo -> interfaz S030 paso 140 (compensación nacional)
```

**Vocabulario en la fórmula:** compensación regional · compensación nacional · S028 · S030 · CSI corporativo

**Excepciones:**
- La interfaz nacional sólo aplica en el CSI corporativo.

**Estado validación:** Verificado fuente líneas 42-48

---

## RN-S151-767 — Compensación por nodos con acumuladores de cargos y abonos con signo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-767 |
| **Nombre** | Compensación por nodos con acumuladores de cargos y abonos con signo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La compensación se totaliza por nodo/subnodo manteniendo cuatro acumuladores con signo: número de cargos, número de abonos, importe de cargos e importe de abonos (`NUM-CARGOS-COMP`, `NUM-ABONOS-COMP`, `IMP-CARGOS-COMP`, `IMP-ABONOS-COMP`). Cada nodo dependiente del host aporta su información extraída de ICA (Información de Cuentas por Aplicar).

**Fórmula/pseudocódigo:**
```
por (nodo, subnodo):
   NUM-CARGOS-COMP += 1 si cargo ; IMP-CARGOS-COMP += importe
   NUM-ABONOS-COMP += 1 si abono ; IMP-ABONOS-COMP += importe
llave nodo = IS-NODO(2) + IS-SUBNODO(2)
```

**Vocabulario en la fórmula:** NUM-CARGOS-COMP · NUM-ABONOS-COMP · IMP-CARGOS-COMP · IMP-ABONOS-COMP · nodo · subnodo · ICA

**Excepciones:**
- Los importes usan signo `S9(15)V9(02)` permitiendo saldos deudores/acreedores por nodo.

**Estado validación:** Verificado fuente líneas 306-309, 1281-1282

---

## RN-S151-768 — Control de partidas pendientes de aplicar autorizadas en fechas anteriores

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-768 |
| **Nombre** | Control de partidas pendientes de aplicar autorizadas en fechas anteriores |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso controla las partidas pendientes de aplicar que fueron autorizadas en fechas anteriores a la fecha actual de proceso, manteniéndolas en seguimiento hasta su aplicación efectiva y reportándolas por separado. Es un control de operaciones contables en tránsito entre autorización y aplicación.

**Fórmula/pseudocódigo:**
```
IF operación autorizada con fecha-autorización < fecha-proceso
   AND no aplicada
   -> mantener como "pendiente de aplicar" y reportar
```

**Vocabulario en la fórmula:** partida pendiente · fecha de autorización · fecha de proceso · operación en tránsito

**Excepciones:**
- Las partidas del mismo día autorizadas y aplicadas no se reportan como pendientes.

**Estado validación:** Verificado fuente líneas 50-51, 59

---

## RN-S151-769 — Segregación de operaciones foráneas y operaciones eliminadas en la compensación regional

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-769 |
| **Nombre** | Segregación de operaciones foráneas y operaciones eliminadas en la compensación regional |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La compensación regional distingue las operaciones foráneas (realizadas fuera del nodo de origen) que se reportan en el reporte de compensación regional de operaciones foráneas, y las operaciones eliminadas del proceso que se apartan en su propio reporte. Esta segregación asegura trazabilidad de qué operaciones entran a compensación y cuáles se excluyen.

**Fórmula/pseudocódigo:**
```
por operación:
   IF foránea -> reporte "COMPENSACION REGIONAL DE OPERACIONES FORANEAS"
   IF eliminada -> reporte "OPERACIONES ELIMINADAS DEL PROCESO"
```

**Vocabulario en la fórmula:** operación foránea · operación eliminada · compensación regional

**Excepciones:**
- Las operaciones eliminadas no participan en los totales de compensación.

**Estado validación:** Verificado fuente líneas 55-56

---

## RN-S151-770 — Carátula de cifras de control y resumen de transmisión por sistemas

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-770 |
| **Nombre** | Carátula de cifras de control y resumen de transmisión por sistemas |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P115 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al cierre, el programa emite una carátula con cifras de control de los archivos procesados y un resumen de transmisión por sistemas, que permiten conciliar el volumen recibido de cada nodo/sistema contra lo integrado. El parámetro de tipo de transmisión distingue el modo de reporte (por ejemplo valor 2 = reporte por nodo).

**Fórmula/pseudocódigo:**
```
carátula = cifras de control por archivo de entrada
resumen  = totales de transmisión por sistema origen
IF tipo-transmisión = 2 -> reporte por nodo
```

**Vocabulario en la fórmula:** carátula · cifras de control · resumen de transmisión · tipo de transmisión

**Excepciones:**
- El modo de reporte depende del parámetro de transmisión recibido.

**Estado validación:** Verificado fuente líneas 54, 57, 240

---

## RN-S151-771 — Validación obligatoria de fecha de header contra fecha de proceso (aborta si no coincide)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-771 |
| **Nombre** | Validación obligatoria de fecha de header contra fecha de proceso (aborta si no coincide) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [SILENCIOSO-CRÍTICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P135 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En la primera lectura tanto del archivo de movimientos como del archivo de datos adicionales, el programa verifica que la fecha del registro header (`A00-R00-HDR-FCH`) coincida con la fecha de proceso extraída de la base de control (`W77-FEC-PROCESO`). Si no coinciden, emite un mensaje de error y descontinúa el proceso. Es un control anti-reproceso que impide integrar un archivo de fecha equivocada al libro contable.

**Fórmula/pseudocódigo:**
```
al leer primer registro (header):
   IF A00-R00-HDR-FCH  <>  W77-FEC-PROCESO
      mensaje de error
      DESCONTINUAR EL PROCESO (abort)
```

**Vocabulario en la fórmula:** A00-R00-HDR-FCH · W77-FEC-PROCESO · header · fecha de proceso

**Excepciones:**
- Aplica por separado al archivo de movimientos y al de datos adicionales; ambos deben validar.

**Estado validación:** Verificado fuente líneas 25-32, 828, 1897

---

## RN-S151-772 — Verificación de residencia de archivos de movimientos y datos adicionales antes de procesar

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-772 |
| **Nombre** | Verificación de residencia de archivos de movimientos y datos adicionales antes de procesar |
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
| **Programa ejecutor** | P135 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de abrir y procesar, el programa verifica la residencia (existencia física en pack) de los archivos de movimientos y de datos adicionales. El nombre del archivo de movimientos y del archivo de descripciones se extraen dinámicamente de la base de control, tras obtener el número de CSI vía la librería SOPORTECOMS.

**Fórmula/pseudocódigo:**
```
CSI = SOPORTECOMS.obtener_CSI()
nom-movtos = base-control.nombre_archivo_movimientos(sistema)
nom-desc   = base-control.nombre_archivo_descripciones(sistema)
IF NOT residente(nom-movtos) OR NOT residente(nom-desc) -> error
```

**Vocabulario en la fórmula:** residencia · SOPORTECOMS · CSI · base de control · B01SXSISDIA

**Excepciones:**
- La no residencia de cualquiera de los archivos impide continuar.

**Estado validación:** Verificado fuente líneas 10-24

---

## RN-S151-773 — Generación de interfaces de punteo para S253, S263, S264 y S036

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-773 |
| **Nombre** | Generación de interfaces de punteo para S253, S263, S264 y S036 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P135 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P135 recibe el número de sistema por parámetro (3 posiciones numéricas, ej. "500") y genera archivos de interfase de punteo con múltiples aplicaciones: S253 (cuentas móviles), S263, S264 y S036. Cada interfaz lleva su propio header con fecha de proceso descompuesta en AA/MM/DD y registros de detalle con tipo de registro fijo "01".

**Fórmula/pseudocódigo:**
```
parámetro-sistema = 3 dígitos (ej. "500")
para cada movimiento clasificado:
   escribir en interfaces S253, S263, S264, S036 según aplique
header S264 = FECPRO-AA + FECPRO-MM + FECPRO-DD ; TIPREG = "01"
```

**Vocabulario en la fórmula:** S253 · S263 · S264 · S036 · cuentas móviles · TIPREG

**Excepciones:**
- El tipo de registro "01" identifica registros de detalle (movimiento) frente al header.

**Estado validación:** Verificado fuente líneas 19-20, 2740-2755

---

## RN-S151-774 — CSI de origen hardcodeados por socio comercial (Soriana, MPS, CMOV, BCOS)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-774 |
| **Nombre** | CSI de origen hardcodeados por socio comercial (Soriana, MPS, CMOV, BCOS) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P135 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa mantiene variables de CSI de origen específicas por socio o canal comercial (`WKS-CSI-ORI-SORIANA`, `WKS-CSI-ORI-MPS`, `WKS-CSI-ORI-CMOV`, títulos `MOVCSIBCOS`), inicializadas a ceros y resueltas en ejecución. La presencia de nombres de socios comerciales embebidos en la estructura indica ruteo de punteo condicionado por origen específico, con riesgo de mantenimiento al alta de nuevos socios.

**Fórmula/pseudocódigo:**
```
WKS-CSI-ORI-SORIANA / -MPS / -CMOV = <CSI resuelto por origen>
título archivo BCOS = "MOVCSIBCOS/"
ruteo del punteo depende del CSI de origen del socio
```

**Vocabulario en la fórmula:** WKS-CSI-ORI-SORIANA · WKS-CSI-ORI-MPS · WKS-CSI-ORI-CMOV · MOVCSIBCOS · CSI origen

**Excepciones:**
- Nuevos socios comerciales requieren modificación de código (no parametrizable en catálogo).

**Estado validación:** Verificado fuente líneas 1262-1335

---

## RN-S151-775 — Ruteo especial de correspondencia sólo al paso P102 para S264

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-775 |
| **Nombre** | Ruteo especial de correspondencia sólo al paso P102 para S264 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P135 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La interfaz hacia S264 se materializa en el archivo `S264/FILE/INTS/` y lleva una marca de correspondencia atada al paso P102 ("CORRESOLO P102 S264"), indicando que ese flujo de punteo contable sólo se corresponde con la salida del paso P102. Es una dependencia de orquestación entre pasos embebida en literal.

**Fórmula/pseudocódigo:**
```
archivo interfaz S264 = "S264/FILE/INTS/" + fecha
marca de correspondencia = "CORRESOLO P102 S264"
```

**Vocabulario en la fórmula:** S264 · CORRESOLO · P102 · S264/FILE/INTS

**Excepciones:**
- La correspondencia con P102 está fijada por literal; cambiar el paso origen exige modificar código.

**Estado validación:** Verificado fuente líneas 1090, 1229

---

## RN-S151-776 — Ordenamiento de saldos por llave sucursal promotora y contrato

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-776 |
| **Nombre** | Ordenamiento de saldos por llave sucursal promotora y contrato |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P177 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de saldos se ordena ascendentemente por sucursal promotora (`KEY-SALDOS-SUCPROM`) y número de contrato (`KEY-SALDOS-CTA`). Este orden es la llave contable canónica del saldo por cuenta y garantiza que los saldos por contrato queden consolidados y secuenciados para su consumo por estados de cuenta y conciliación.

**Fórmula/pseudocódigo:**
```
SORT SSALDOS ON ASCENDING KEY
     KEY-SALDOS-SUCPROM, KEY-SALDOS-CTA
     USING SALDOS015 GIVING SALDOS015
```

**Vocabulario en la fórmula:** KEY-SALDOS-SUCPROM · KEY-SALDOS-CTA · sucursal promotora · contrato

**Excepciones:**
- El tamaño de memoria y disco del SORT se calcula dinámicamente (`W77-MEMORY-SIZE`, `W77-DISK-SIZE`).

**Estado validación:** Verificado fuente líneas 3406-3413, 79-80

---

## RN-S151-777 — Validación de header presente y archivo de movimientos no vacío

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-777 |
| **Nombre** | Validación de header presente y archivo de movimientos no vacío |
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
| **Programa ejecutor** | P177 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al abrir el archivo LOG151 de movimientos, el programa valida dos condiciones sobre la primera lectura: si no hay registro header emite "ARCHIVO DE MOVTOS SIN HEADER"; si tras el header no hay registros de detalle emite "ARCHIVO VACIO DE MOVTOS". Ambas se registran como incidente informativo con código 020101, protegiendo el proceso de saldos contra archivos incompletos.

**Fórmula/pseudocódigo:**
```
READ LOG151 INTO HDR AT END -> log "ARCHIVO DE MOVTOS SIN HEADER" (I, 020101)
READ LOG151 INTO REGMOV AT END -> log "ARCHIVO VACIO DE MOVTOS" (I, 020101)
```

**Vocabulario en la fórmula:** LOG151 · header · archivo vacío · CODIGO-LJ 020101

**Excepciones:**
- Se registra como tipo "I" (informativo); requiere revisar si debería abortar en vez de continuar.

**Estado validación:** Verificado fuente líneas 3423-3442

---

## RN-S151-778 — Coexistencia de formatos de saldo: SALDOS151 (390) nuevo y SALDOS015 (180) legado

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-778 |
| **Nombre** | Coexistencia de formatos de saldo: SALDOS151 (390) nuevo y SALDOS015 (180) legado |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P177 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa genera en paralelo tres archivos de saldo con longitudes distintas que evidencian evolución de formato: `SALDOS151` de 390 bytes (formato vigente, con historia de comentarios 186→216→390), `SALDOS015` de 180 bytes (formato legado) y `SDOSYMOVS015` de 146 bytes (saldos combinados con movimientos). La coexistencia mantiene compatibilidad hacia atrás con consumidores que aún esperan el layout de 180.

**Fórmula/pseudocódigo:**
```
REG-SALDOS      = X(390)   (vigente; evolución 186 -> 216 -> 390)
REG-SALDOS015   = X(180)   (legado)
REG-SDOSYMOVS015= X(146)   (saldos + movimientos)
```

**Vocabulario en la fórmula:** SALDOS151 · SALDOS015 · SDOSYMOVS015 · formato legado

**Excepciones:**
- Cualquier reescritura debe preservar los tres layouts hasta retirar consumidores del formato 180.

**Estado validación:** Verificado fuente líneas 64-90

---

## RN-S151-779 — Generación de interfaz fiscal S080 (STXC) con conteo de registros tributarios

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-779 |
| **Nombre** | Generación de interfaz fiscal S080 (STXC) con conteo de registros tributarios |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-FISCAL-MX] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | SAT/CNBV |
| **Programa ejecutor** | P177 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Durante la generación de saldos, el programa alimenta la interfaz del sistema S080 relativa a información tributaria (`S080-STXC`), llevando un contador de registros fiscales (`S080-STXC-NUM-REG`) y un índice de impuestos (`WKS-INDTAX`). Esto vincula el saldo contable con la obligación de reporte fiscal por cuenta.

**Fórmula/pseudocódigo:**
```
por registro con implicación fiscal:
   ADD 1 TO S080-STXC-NUM-REG
   ADD 1 TO WKS-INDTAX
   escribir registro en interfaz S080
```

**Vocabulario en la fórmula:** S080-STXC · S080-STXC-NUM-REG · WKS-INDTAX · interfaz fiscal

**Excepciones:**
- Sólo los registros con implicación tributaria incrementan el contador fiscal.

**Estado validación:** Verificado fuente líneas 3309, 3331

---

## RN-S151-780 — Manejo de fecha en formato juliano CCAADDD para saldos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-780 |
| **Nombre** | Manejo de fecha en formato juliano CCAADDD para saldos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P177 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa maneja fechas en formato juliano `CCAADDD` (siglo, año, día del año) descompuesto en siglo (CC), año (AA) y día juliano (DDD). Este formato compacto de 7 dígitos se usa para fechar los saldos y es un patrón Y2K-aware (incluye siglo), heredado del remediation Cronos 2000.

**Fórmula/pseudocódigo:**
```
A2K-FEC-JUL-CADDD-001 = CC(2) + AA(2) + DDD(3)   -> 9(7)
```

**Vocabulario en la fórmula:** CCAADDD · fecha juliana · siglo · día del año · Y2K

**Excepciones:**
- El manejo explícito de siglo (CC) previene ambigüedad Y2K; toda reescritura debe preservar el siglo.

**Estado validación:** Verificado fuente líneas 160-169

---

## RN-S151-781 — Filtro de movimientos para la BIT: función 1, estatus 1 o 2, origen 1 o 3

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-781 |
| **Nombre** | Filtro de movimientos para la BIT: función 1, estatus 1 o 2, origen 1 o 3 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P110 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El movimiento se graba al archivo de la BIT (`MOVSCIG`) sólo cuando su función es 1 o 2, su origen es 1 o 3, y se cumple la coherencia entre tipo y proceso (línea con proceso en línea, o batch con proceso batch). El filtro de origen 1 y 3 fue introducido por el cambio R08-001 (2008) para entregar a la BIT exclusivamente esos orígenes.

**Fórmula/pseudocódigo:**
```
IF (tipo-línea AND proceso-línea) OR (tipo-batch AND proceso-batch)
   IF (A00-R01-FUNCION = 1 OR 2) AND (A00-R01-ORIGEN = 1 OR 3)
      PERFORM 232000-GRABA-MOVSCIG
```

**Vocabulario en la fórmula:** A00-R01-FUNCION · A00-R01-ORIGEN · MOVSCIG · tipo línea · tipo batch

**Excepciones:**
- Orígenes distintos de 1 y 3 se excluyen de la BIT (cambio R08-001, 2008-08-04).

**Estado validación:** Verificado fuente líneas 2882-2888, 25

---

## RN-S151-782 — Insumo desde archivo S016 clasificado en el paso 108

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-782 |
| **Nombre** | Insumo desde archivo S016 clasificado en el paso 108 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P110 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P110 fue creado por incremento de volumen de movimientos para no entregar fuera de horario la información contable que antes producía el paso 108. Consume el archivo del S016 ya clasificado en el paso 108 (`ARCH-S016`, registro con tipo 1 = header, cliente, producto, instrumento, contrato) y lo integra a la generación de la BIT.

**Fórmula/pseudocódigo:**
```
entrada = S151/FILE/S016 clasificado en paso 108
header S016: TIPREG(1) + SISORI(4) + FECPRO(8) + NUMCSI(2)
detalle S016: TIPREG(1) + CLIENTE(12) + PROD(4) + INST(2) + CONTRATO(PREF+NUM)
```

**Vocabulario en la fórmula:** ARCH-S016 · paso 108 · SISORI · NUMCSI · clasificación

**Excepciones:**
- Depende de que el paso 108 haya clasificado correctamente el S016 (dependencia de orquestación).

**Estado validación:** Verificado fuente líneas 10-16, 76-91

---

## RN-S151-783 — Carga de operaciones intercompany para movimientos función 1, estatus 1 o 2

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-783 |
| **Nombre** | Carga de operaciones intercompany para movimientos función 1, estatus 1 o 2 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P110 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cada movimiento con función 1 y estatus 1 o 2 (activo o pendiente), el programa ejecuta la carga intercompany (`231000-CARGA-INTERCOMPANY`), que registra las operaciones entre compañías del grupo. Esto asegura que las partidas contables intergrupo se identifiquen y consoliden aparte para eliminación en la contabilidad del grupo.

**Fórmula/pseudocódigo:**
```
IF A00-R01-FUNCION = 1 AND (A00-R01-STATUS = 1 OR 2)
   PERFORM 231000-CARGA-INTERCOMPANY
```

**Vocabulario en la fórmula:** A00-R01-FUNCION · A00-R01-STATUS · intercompany · partida intergrupo

**Excepciones:**
- Estatus distinto de 1 o 2, o función distinta de 1, no genera carga intercompany.

**Estado validación:** Verificado fuente líneas 2878-2880

---

## RN-S151-784 — Encadenamiento del registro complementario vía APUDES + 1

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-784 |
| **Nombre** | Encadenamiento del registro complementario vía APUDES + 1 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P110 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada registro de movimiento en LOG151 apunta a su registro de datos complementarios mediante `A00-R01-APUDES`. Cuando APUDES es mayor que cero, el programa calcula la llave del complemento como `APUDES + 1` y lee LOG151-COMP por esa llave. Un INVALID KEY marca error de BIT (`W77-ERROR-BIT`), señalando integridad referencial rota entre movimiento y su complemento.

**Fórmula/pseudocódigo:**
```
IF W77-EOF = 0 AND A00-R01-APUDES > 0
   LOG-KEY = A00-R01-APUDES + 1
   READ LOG151-COMP KEY = LOG-KEY
        INVALID KEY -> W77-ERROR-BIT = 1
```

**Vocabulario en la fórmula:** A00-R01-APUDES · LOG151-COMP · LOG-KEY · W77-ERROR-BIT

**Excepciones:**
- APUDES = 0 significa que el movimiento no tiene complemento (no se lee LOG151-COMP).
- El offset `+1` es un ajuste implícito de indexación entre archivos; crítico en reescritura.

**Estado validación:** Verificado fuente líneas 2896-2906

---

## RN-S151-785 — Conmutación de procesamiento en línea vs. batch por coherencia tipo-proceso

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-785 |
| **Nombre** | Conmutación de procesamiento en línea vs. batch por coherencia tipo-proceso |
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
| **Programa ejecutor** | P110 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa sólo procesa un movimiento cuando el tipo del registro coincide con el modo de proceso: registros de tipo línea se procesan en corrida en línea y registros de tipo batch en corrida batch. Esta condición de coherencia evita mezclar movimientos en línea y batch en la misma entrega a la BIT.

**Fórmula/pseudocódigo:**
```
procesar SI (W88-TIPO-LINEA AND W88-PROCESO-LINEA)
           OR (W88-TIPO-BATCH AND W88-PROCESO-BATCH)
```

**Vocabulario en la fórmula:** W88-TIPO-LINEA · W88-PROCESO-LINEA · W88-TIPO-BATCH · W88-PROCESO-BATCH

**Excepciones:**
- Un registro cuyo tipo no coincide con el modo de la corrida se ignora en ese paso.

**Estado validación:** Verificado fuente líneas 2882-2885

---

## RN-S151-786 — Reporte de diferencias contables por CSI para la compensadora nacional

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-786 |
| **Nombre** | Reporte de diferencias contables por CSI para la compensadora nacional |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P117 (S151-P117-DIFERENCIAS) produce un reporte de las diferencias detectadas en las operaciones de los archivos LOG de cada CSI, para control de la compensadora nacional. Compara lo operado contra lo aplicado por CSI y reporta los desbalances, alimentando además un archivo histórico de diferencias en operación/aplicación por CSI.

**Fórmula/pseudocódigo:**
```
por cada CSI:
   diferencia = operado(CSI) - aplicado(CSI)
   IF diferencia <> 0 -> REP-DIFERENCIA + histórico por CSI
```

**Vocabulario en la fórmula:** CSI · LOG-GRAL · REP-DIFERENCIA · operado · aplicado · compensadora nacional

**Excepciones:**
- Sólo se reportan CSIs con diferencia distinta de cero.

**Estado validación:** Verificado fuente líneas 31-33, 124, 144

---

## RN-S151-787 — Códigos de servicio contable: cargo 10, abono 20, elimina-cargo 11, elimina-abono 21

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-787 |
| **Nombre** | Códigos de servicio contable: cargo 10, abono 20, elimina-cargo 11, elimina-abono 21 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El código de servicio de cada operación se interpreta contablemente por valor fijo: 10 es cargo, 20 es abono, 11 es eliminación de cargo y 21 es eliminación de abono. Las eliminaciones (11, 21) revierten un cargo/abono previo y deben netearse contra su original en el cálculo de diferencias.

**Fórmula/pseudocódigo:**
```
COD-SERVICIO:
   10 -> CARGO
   20 -> ABONO
   11 -> ELIMINA CARGO (reversa de 10)
   21 -> ELIMINA ABONO (reversa de 20)
```

**Vocabulario en la fórmula:** RDI-COD-SER-CARGO · RDI-COD-SER-ABONO · RDI-COD-SER-ELIMCARGO · RDI-COD-SER-ELIMABONO

**Excepciones:**
- Códigos fuera de {10, 20, 11, 21} no se clasifican como cargo/abono/eliminación.

**Estado validación:** Verificado fuente líneas 428-431

---

## RN-S151-788 — CSI de origen y destino restringidos a valores válidos {2, 4, 10}

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-788 |
| **Nombre** | CSI de origen y destino restringidos a valores válidos {2, 4, 10} |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los CSI de origen (`WS-RDI-CSI-ORI`) y destino (`WS-RDI-CSI-DES`) se validan contra un conjunto cerrado de valores 2, 4 y 10 (condiciones 88 `RDI-CSI-ORI-VAL` / `RDI-CSI-DES-VAL`). Estos identificadores de centro de servicios informático están embebidos en código, lo que implica que el alta de un nuevo CSI requiere modificación fuente.

**Fórmula/pseudocódigo:**
```
88 RDI-CSI-ORI-VAL VALUES ARE 2, 4, 10
88 RDI-CSI-DES-VAL VALUES ARE 2, 4, 10
válido <=> CSI ∈ {2, 4, 10}
```

**Vocabulario en la fórmula:** WS-RDI-CSI-ORI · WS-RDI-CSI-DES · RDI-CSI-ORI-VAL · CSI

**Excepciones:**
- CSIs fuera de {2, 4, 10} no son reconocidos como válidos en el reporte de diferencias.

**Estado validación:** Verificado fuente líneas 400-404

---

## RN-S151-789 — Llave de diferencia por par CSI origen-destino

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-789 |
| **Nombre** | Llave de diferencia por par CSI origen-destino |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo histórico de diferencias registra cada desbalance por el par CSI origen (`SLOG-CSI-ORI`) y CSI destino (`SLOG-CSI-DES`). La compensación nacional es entre CSIs, por lo que la diferencia se atribuye a la relación origen→destino, permitiendo rastrear entre qué centros de servicio se produjo el descuadre.

**Fórmula/pseudocódigo:**
```
llave histórico = (SLOG-CSI-ORI, SLOG-CSI-DES)
registrar diferencia bajo el par (origen, destino)
```

**Vocabulario en la fórmula:** SLOG-CSI-ORI · SLOG-CSI-DES · par CSI · histórico

**Excepciones:**
- Operaciones intra-CSI (origen = destino) también se registran para trazabilidad.

**Estado validación:** Verificado fuente líneas 157-161

---

## RN-S151-790 — Título dinámico del archivo LOG general por CSI (NOMBRE-LOG-GRAL)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-790 |
| **Nombre** | Título dinámico del archivo LOG general por CSI (NOMBRE-LOG-GRAL) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa abre el archivo LOG general (`LOG-GRAL`, registro de 160 bytes) con título físico resuelto dinámicamente en `NOMBRE-LOG-GRAL`, iterando por cada CSI para leer su LOG respectivo. El nombre del archivo se arma en ejecución en función del CSI en proceso, patrón de acceso multi-archivo por centro de servicio.

**Fórmula/pseudocódigo:**
```
para cada CSI válido:
   NOMBRE-LOG-GRAL = título del LOG de ese CSI
   OPEN INPUT LOG-GRAL (VALUE OF TITLE = NOMBRE-LOG-GRAL)
   procesar sus registros
```

**Vocabulario en la fórmula:** LOG-GRAL · NOMBRE-LOG-GRAL · CSI · título dinámico

**Excepciones:**
- La ausencia física del LOG de un CSI debe manejarse como excepción de residencia.

**Estado validación:** Verificado fuente líneas 90-96

---

## RN-S151-791 — Punteo de dos niveles: totales por clave y, si hay diferencia, detalle por contrato-clave

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-791 |
| **Nombre** | Punteo de dos niveles: totales por clave y, si hay diferencia, detalle por contrato-clave |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P104 concilia (puntea) los totales por clave de transacción entre las aplicaciones que envían movimientos y el S151. Ejecuta primero un punteo de totales por clave; si detecta diferencias (`W77-BAN-DIFSNNN = 1` o `W77-BAN-DIFS151 = 1`) escala a un segundo punteo a detalle por contrato-clave para localizar el contrato específico que causa el descuadre.

**Fórmula/pseudocódigo:**
```
PERFORM 30000-COMPARA-TOTXCVE            (nivel 1: totales por clave)
IF W77-BAN-DIFSNNN = 1 OR W77-BAN-DIFS151 = 1
   PERFORM 40000-SORTEA-ARCHIVO-CONTRATO
   PERFORM 50000-COMPARA-DETALLE         (nivel 2: detalle por contrato-clave)
ELSE
   PERFORM 50000-COMPARA-DETALLE
```

**Vocabulario en la fórmula:** punteo · clave de transacción · contrato-clave · W77-BAN-DIFSNNN · W77-BAN-DIFS151

**Excepciones:**
- El segundo punteo (detalle) sólo se activa por bandera de diferencia; en su ausencia igual se ejecuta detalle acotado.

**Estado validación:** Verificado fuente líneas 6-10, 1709-1715

---

## RN-S151-792 — Comparación de totales por clave entre sistema origen (SNNN) y S151

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-792 |
| **Nombre** | Comparación de totales por clave entre sistema origen (SNNN) y S151 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El punteo compara, para cada clave de transacción, los totales reportados por el sistema origen (archivo `CVETRAN`, referido como SNNN) contra los totales del S151 (archivo `CVETRANS151`). Se levanta la bandera `W77-BAN-DIFSNNN` cuando el origen difiere y `W77-BAN-DIFS151` cuando el S151 difiere, distinguiendo de qué lado está el faltante o sobrante.

**Fórmula/pseudocódigo:**
```
por clave:
   IF total_SNNN(clave) <> total_S151(clave)
      marcar W77-BAN-DIFSNNN / W77-BAN-DIFS151 según el lado
```

**Vocabulario en la fórmula:** CVETRAN · CVETRANS151 · SNNN · total por clave · bandera de diferencia

**Excepciones:**
- Claves presentes en un solo lado se tratan como diferencia total del lado ausente.

**Estado validación:** Verificado fuente líneas 19-25, 1711, 2362

---

## RN-S151-793 — Registro de diferencias en archivos separados por lado (CVESNNNDIF y CVES151DIF)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-793 |
| **Nombre** | Registro de diferencias en archivos separados por lado (CVESNNNDIF y CVES151DIF) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Las diferencias detectadas se escriben en dos archivos separados: `CVESNNNDIF` para las diferencias imputables al sistema origen y `CVES151DIF` para las imputables al S151, además de un reporte impreso de claves (`V00-REP-CVES`). Esta separación permite dirigir cada diferencia al equipo responsable del sistema que la originó.

**Fórmula/pseudocódigo:**
```
OPEN OUTPUT V00-REP-CVES, TOTCVETRAN, CVESNNNDIF, CVES151DIF
diferencia lado origen -> CVESNNNDIF
diferencia lado S151   -> CVES151DIF
```

**Vocabulario en la fórmula:** CVESNNNDIF · CVES151DIF · V00-REP-CVES · TOTCVETRAN

**Excepciones:**
- Ninguna; cada diferencia se enruta al archivo del lado correspondiente.

**Estado validación:** Verificado fuente líneas 2358-2362

---

## RN-S151-794 — Actualización de base B05 sólo para sistemas 804 y 203 en modo alta disponibilidad

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-794 |
| **Nombre** | Actualización de base B05 sólo para sistemas 804 y 203 en modo alta disponibilidad |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Como parte del esquema de alta disponibilidad IBM (introducido 2015-02-06), P104 actualiza la base B05 (`010200-ACTUALIZA-B05`) únicamente cuando el sistema parámetro es 804 o 203 y la fecha propia del programa es 0 (primera corrida del día). Los identificadores 804 y 203 están embebidos en código.

**Fórmula/pseudocódigo:**
```
IF (W77-SISTEMA-PARAM = 804 OR 203) AND ATTRIBUTE VALUE OF MYSELF = 0
   PERFORM 010200-ACTUALIZA-B05
```

**Vocabulario en la fórmula:** W77-SISTEMA-PARAM · 804 · 203 · ACTUALIZA-B05 · alta disponibilidad

**Excepciones:**
- Otros sistemas no actualizan B05; agregar un sistema al esquema HA requiere modificar el literal.

**Estado validación:** Verificado fuente líneas 1718-1722

---

## RN-S151-795 — Llave de punteo por contrato de 16 dígitos entre origen y S151

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-795 |
| **Nombre** | Llave de punteo por contrato de 16 dígitos entre origen y S151 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El punteo a detalle usa como llave el número de contrato de 16 dígitos, tanto del lado origen (`R01-SNNN-CONTRATO`) como del lado S151 (`R01-S151-CONTRATO`). El apareamiento por contrato permite identificar exactamente qué contrato-clave está descuadrado cuando el punteo por totales detectó diferencia.

**Fórmula/pseudocódigo:**
```
llave detalle = CONTRATO 9(16)
aparear R01-SNNN-CONTRATO vs R01-S151-CONTRATO
   no apareado o importe distinto -> diferencia a nivel contrato
```

**Vocabulario en la fórmula:** R01-SNNN-CONTRATO · R01-S151-CONTRATO · S00-PUN-CONTRATO · contrato

**Excepciones:**
- Contratos presentes en un solo archivo se reportan como diferencia de contrato.

**Estado validación:** Verificado fuente líneas 123, 146, 170

---

## RN-S151-796 — Purga de archivos temporales de punteo al cierre

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-796 |
| **Nombre** | Purga de archivos temporales de punteo al cierre |
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
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al terminar, el programa cierra los archivos de trabajo de punteo (`A00-SPUNTEO1`, `A00-SPUNTEO2`) con la cláusula `WITH PURGE`, eliminándolos físicamente del disco. Son archivos intermedios de la conciliación que no deben persistir entre corridas para evitar arrastrar totales del día anterior.

**Fórmula/pseudocódigo:**
```
CLOSE A00-SPUNTEO1 WITH PURGE
CLOSE A00-SPUNTEO2 WITH PURGE
```

**Vocabulario en la fórmula:** SPUNTEO1 · SPUNTEO2 · WITH PURGE · archivo temporal

**Excepciones:**
- La purga es incondicional; no hay opción de conservar los intermedios para auditoría.

**Estado validación:** Verificado fuente líneas 1716-1717

---

## RN-S151-797 — Estado de cuenta EDOCTA: activo genera, cancelado/inactivo condicionan generación de estado

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-797 |
| **Nombre** | Estado de cuenta EDOCTA: activo genera, cancelado/inactivo condicionan generación de estado |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/CONDUSEF |
| **Programa ejecutor** | P172 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo `A02-R01-EDOCTA` del registro de saldos determina si la cuenta genera estado de cuenta: 00 solo es registro de saldos (no genera), 01 activo genera, 02 cancelado en el mes genera, 03 inactivo genera, 04 inactivo no genera. Cuando EDOCTA es mayor a cero, las fechas de inicio y fin de ciclo de corte (`FECINI`, `FECFIN`) son obligatorias.

**Fórmula/pseudocódigo:**
```
EDOCTA: 00 -> solo saldo (no edo cta)
        01 -> ACTIVO, genera edo cta
        02 -> CANCELADO en el mes, genera edo cta
        03 -> INACTIVO, genera edo cta
        04 -> INACTIVO, NO genera edo cta
IF EDOCTA > 0 -> FECINI y FECFIN obligatorias (AAMMDD)
```

**Vocabulario en la fórmula:** A02-R01-EDOCTA · FECINI · FECFIN · estado de cuenta · ciclo de corte

**Excepciones:**
- EDOCTA = 04 es el único caso de cuenta inactiva sin estado de cuenta.
- FECINI/FECFIN ausentes con EDOCTA > 0 es dato inválido.

**Estado validación:** Verificado fuente líneas 1100-1113

---

## RN-S151-798 — Concepto de saldo CVESDO e importe IMPT (0002 = saldo actual)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-798 |
| **Nombre** | Concepto de saldo CVESDO e importe IMPT (0002 = saldo actual) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P172 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada registro de saldo lleva un número de concepto de saldo (`A02-R01-CVESDO`) y su importe (`A02-R01-IMPT`, `9(12)V99`). El concepto 0002 corresponde al saldo actual. Un mismo contrato puede tener múltiples registros de saldo, uno por concepto (saldo actual, disponible, retenido, etc.), identificados por la clave de concepto y su fecha contable de aplicación `FECPRO` (AAMMDD).

**Fórmula/pseudocódigo:**
```
por contrato:
   registro saldo = { CVESDO (ej. 0002 = saldo actual), IMPT 9(12)V99, FECPRO AAMMDD }
   múltiples conceptos por contrato
```

**Vocabulario en la fórmula:** A02-R01-CVESDO · A02-R01-IMPT · A02-R01-FECPRO · concepto de saldo · saldo actual

**Excepciones:**
- Los conceptos distintos de 0002 representan otros saldos (disponible, retenido) no detallados aquí.

**Estado validación:** Verificado fuente líneas 1118-1120, 262

---

## RN-S151-799 — Encadenamiento de saldos por contrato vía STATUS (00 último, 01 continúa)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-799 |
| **Nombre** | Encadenamiento de saldos por contrato vía STATUS (00 último, 01 continúa) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P172 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo `A02-R01-STATUS` encadena los múltiples registros de saldo de un mismo contrato: 00 indica que es el último registro de saldos del contrato, 01 indica que el siguiente registro pertenece al mismo contrato. Este marcador de continuación permite al consumidor agrupar todos los conceptos de saldo de una cuenta sin releer la llave.

**Fórmula/pseudocódigo:**
```
A02-R01-STATUS:
   01 -> siguiente registro es del mismo contrato (continúa)
   00 -> último registro de saldos del contrato (fin de grupo)
```

**Vocabulario en la fórmula:** A02-R01-STATUS · último registro · continuación · contrato

**Excepciones:**
- Un STATUS 00 huérfano (sin registros previos 01) es un contrato con un solo concepto de saldo.

**Estado validación:** Verificado fuente líneas 1114-1117

---

## RN-S151-800 — Generación de interfaz INTELLI e INTELLI-UNI para downstream analítico

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-800 |
| **Nombre** | Generación de interfaz INTELLI e INTELLI-UNI para downstream analítico |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P172 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Además de SALDOS151, P172 genera dos archivos de interfaz `E01-INTELLI` y `E02-INTELLI-UNI` (197 bytes, mismo layout que MOV-GCE), que alimentan el downstream analítico/consolidado. La variante "UNI" corresponde al flujo unificado; ambos comparten estructura con el archivo de movimientos GCE.

**Fórmula/pseudocódigo:**
```
por saldo/movimiento procesado:
   WRITE E01-INTELLI      (interfaz estándar 197 bytes)
   WRITE E02-INTELLI-UNI  (interfaz unificada 197 bytes)
```

**Vocabulario en la fórmula:** E01-INTELLI · E02-INTELLI-UNI · MOV-GCE · interfaz analítica

**Excepciones:**
- Ambas interfaces comparten longitud (197) con GCE; cambios de layout impactan a los tres.

**Estado validación:** Verificado fuente líneas 19-20, 1182-1187

---

## RN-S151-801 — Llave de saldo por sistema, producto, instrumento y cuenta

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-801 |
| **Nombre** | Llave de saldo por sistema, producto, instrumento y cuenta |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P172 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de saldo se identifica por la tupla sistema (`SIS`, ej. 0500), producto (`PRD`, ej. 0066), instrumento (`INS`, ej. 0006) y número de cuenta/contrato (`CTA`). Esta llave jerárquica ubica el saldo dentro del catálogo de productos del banco y es la base para el nombrado del archivo de saldos por concepto (patrón `S151/FILE/S050/SALDOSYYY/AAMMDD`).

**Fórmula/pseudocódigo:**
```
llave saldo = SIS(4) + PRD(4) + INS(4) + CTA
ej. SIS=0500, PRD=0066, INS=0006
archivo = (SXXX)S151/FILE/S050/SALDOSYYY/AAMMDD
```

**Vocabulario en la fórmula:** A02-R01-SIS · A02-R01-PRD · A02-R01-INS · A02-R01-CTA · SALDOSYYY

**Excepciones:**
- El sufijo YYY del nombre de archivo depende del producto/sistema; ruteo por convención de nombre.

**Estado validación:** Verificado fuente líneas 1096-1099, 1175

---

## RN-S151-802 — Header y trailer obligatorios por LOG para detectar pérdida en transmisión XFER

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-802 |
| **Nombre** | Header y trailer obligatorios por LOG para detectar pérdida en transmisión XFER |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P116 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada archivo LOG transmitido vía XFER debe contener al principio un registro header/control (`WS-REG-LOG-CONTROL`: identificador, CSI, fecha contable, clave sistema, fecha y hora) y al final un registro trailer/totalizador (`WS-RG-LOG-TRAILER`). Este control fue introducido en diciembre de 1985 precisamente para detectar la pérdida parcial de un archivo durante la transmisión XFER, que antes pasaba inadvertida.

**Fórmula/pseudocódigo:**
```
LOG válido = HEADER (WS-RLC-*) + N registros detalle + TRAILER (WS-RLT-*)
IF falta header o trailer -> archivo transmitido incompleto (error)
```

**Vocabulario en la fórmula:** WS-REG-LOG-CONTROL · WS-RG-LOG-TRAILER · XFER · CSI · FECONT

**Excepciones:**
- Un LOG sin trailer indica truncamiento en transmisión; no debe concentrarse.

**Estado validación:** Verificado fuente líneas 24-30, 540-553

---

## RN-S151-803 — Trailer totalizador con ocho acumuladores: cargos/abonos operados y aplicados

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-803 |
| **Nombre** | Trailer totalizador con ocho acumuladores: cargos/abonos operados y aplicados |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P116 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro trailer contiene ocho cifras de control por LOG: número e importe de cargos operados (`NCO`, `ICO`), abonos operados (`NAO`, `IAO`), cargos aplicados (`NCA`, `ICA`) y abonos aplicados (`NAA`, `IAA`). La distinción operado vs. aplicado permite conciliar lo que llegó (operado) contra lo que efectivamente se contabilizó (aplicado) en la compensación nacional.

**Fórmula/pseudocódigo:**
```
TRAILER:
   NCO 9(06) / ICO 9(18)V99   (cargos operados)
   NAO 9(06) / IAO 9(18)V99   (abonos operados)
   NCA 9(06) / ICA 9(18)V99   (cargos aplicados)
   NAA 9(06) / IAA 9(18)V99   (abonos aplicados)
```

**Vocabulario en la fórmula:** WS-RLT-NCO · WS-RLT-ICO · WS-RLT-NCA · WS-RLT-ICA · operado · aplicado

**Excepciones:**
- Los importes usan 18 enteros más 2 decimales, capacidad para grandes volúmenes consolidados.

**Estado validación:** Verificado fuente líneas 554-562

---

## RN-S151-804 — Validación del trailer contra el conteo real de registros del LOG

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-804 |
| **Nombre** | Validación del trailer contra el conteo real de registros del LOG |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [SILENCIOSO-CRÍTICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P116 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al concentrar cada LOG, el programa recalcula el conteo y los importes de los registros de detalle leídos y los confronta contra las cifras declaradas en el trailer. Una discrepancia entre lo contado y lo declarado revela que el archivo perdió registros en la transmisión, condición que debe detenerse antes de propagarse a la compensación nacional.

**Fórmula/pseudocódigo:**
```
contados = Σ registros de detalle del LOG (num e importe por cargo/abono)
IF contados <> (NCO, ICO, NAO, IAO ...) del trailer
   -> LOG incompleto / corrupto (error de control)
```

**Vocabulario en la fórmula:** trailer · conteo real · cifras de control · discrepancia

**Excepciones:**
- Coincidencia exacta es requisito para aceptar el LOG en la concentración.

**Estado validación:** Verificado fuente líneas 24-30, 554-562

---

## RN-S151-805 — Archivo de control de fechas corporativo como referencia del proceso de concentración

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-805 |
| **Nombre** | Archivo de control de fechas corporativo como referencia del proceso de concentración |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P116 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P116 lee el archivo de control de fechas corporativo con título físico fijo `(S151)S151/FILE/CONTROL/CORP` (registro de 90 bytes) para determinar la fecha contable de referencia de la concentración. Es la fuente de verdad de la fecha de proceso a nivel corporativo contra la que se validan las fechas de los LOG entrantes.

**Fórmula/pseudocódigo:**
```
OPEN A01-CONTROL (TITLE = "(S151)S151/FILE/CONTROL/CORP")
fecha-referencia = A01-REG-CONTROL.fecha
```

**Vocabulario en la fórmula:** A01-CONTROL · CONTROL/CORP · fecha contable · corporativo

**Excepciones:**
- El título del archivo está embebido como literal; cambio de ruta requiere modificar código.

**Estado validación:** Verificado fuente líneas 67-71

---

## RN-S151-806 — Concentración hacia el archivo de compensación nacional y carátula R/030-140

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-806 |
| **Nombre** | Concentración hacia el archivo de compensación nacional y carátula R/030-140 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P116 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa concentra todos los LOG validados en el archivo indexado de compensación nacional `S151/FILE/COMPENSACION` y emite la carátula "R/030-140/001-CARATULA — COMPENSACION CONTABLE NACIONAL", que incluye el total de registros enviados a CitiDirect. Es el punto de consolidación de la información contable de todos los CSI hacia el proceso nacional.

**Fórmula/pseudocódigo:**
```
para cada LOG válido:
   acumular en COMPENSACION (indexado)
carátula = "R/030-140/001-CARATULA / COMPENSACION CONTABLE NACIONAL"
reportar "TOTAL DE REGISTROS ENVIO CITIDIRECT"
```

**Vocabulario en la fórmula:** COMPENSACION · carátula · R/030-140 · CitiDirect · compensación nacional

**Excepciones:**
- Sólo los LOG que pasaron el control header/trailer se concentran.

**Estado validación:** Verificado fuente líneas 104-111, 315, 571-576

---

## RN-S151-807 — Detección de cierre de mes: el cambio de AAMM dispara el proceso mensual además del diario

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-807 |
| **Nombre** | Detección de cierre de mes: el cambio de AAMM dispara el proceso mensual además del diario |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P197 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** ROTABASE compara el año-mes de hoy (`WKS-FECHOY-AAMM`) contra el año-mes de la siguiente fecha hábil (`WKS-FECMAN-AAMM`). Si son iguales (sigue el mismo mes) sólo ejecuta el proceso diario; si difieren (mañana es otro mes, es decir hoy es cierre de mes) ejecuta el proceso diario, limpia cuenta y además el proceso mensual de rotación de saldos.

**Fórmula/pseudocódigo:**
```
IF WKS-FECHOY-AAMM = WKS-FECMAN-AAMM
   PERFORM PROCESO-DIARIO
ELSE  (cierre de mes)
   PERFORM PROCESO-DIARIO
   PERFORM LIMPIA-CUENTA
   IF WKS-B03-STABDSAL NOT IN {99, 1} -> PERFORM PROCESO-MENSUAL
```

**Vocabulario en la fórmula:** WKS-FECHOY-AAMM · WKS-FECMAN-AAMM · proceso diario · proceso mensual · cierre de mes

**Excepciones:**
- Si el estatus de base de saldos `STABDSAL` es 99 o 1, se omite el proceso mensual aun en cierre de mes.

**Estado validación:** Verificado fuente líneas 1397-1409

---

## RN-S151-808 — Número de sistema obligatorio mayor a cero (aborta con error 051001)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-808 |
| **Nombre** | Número de sistema obligatorio mayor a cero (aborta con error 051001) |
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
| **Programa ejecutor** | P197 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El parámetro de número de sistema es obligatorio y debe ser mayor a cero. Si es cero o inválido, el programa emite un mensaje de error tipo "E" con código 051001 ("EL NUMERO DE SISTEMA DEBE DE SER MAYOR A CERO") y no ejecuta ni el proceso diario ni el mensual, evitando rotar bases sin sistema objetivo.

**Fórmula/pseudocódigo:**
```
IF WKS-PARAM-SISTEMA > 0
   ejecutar proceso diario/mensual
ELSE
   log "E" 051001 "EL NUMERO DE SISTEMA DEBE DE SER MAYOR A CERO"
```

**Vocabulario en la fórmula:** WKS-PARAM-SISTEMA · CODIGO-LJ 051001 · TIPO-LJ "E"

**Excepciones:**
- Es un error tipo "E" (error, no informativo): detiene la lógica de rotación.

**Estado validación:** Verificado fuente líneas 1410-1418

---

## RN-S151-809 — Retención por número de ciclos: borrado de datasets diarios y mensuales

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-809 |
| **Nombre** | Retención por número de ciclos: borrado de datasets diarios y mensuales |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P197 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La política de retención se controla por número de ciclos: `WKS-B03-NUMCICDIA` (ciclos diarios a conservar) y `WKS-B03-NUMCICMES` (ciclos mensuales a conservar). Cuando son mayores a cero, ROTABASE calcula la fecha de borrado y elimina la información de los datasets diarios y mensuales de la base de saldos que exceden la ventana de retención, antes de rotar.

**Fórmula/pseudocódigo:**
```
IF WKS-B03-NUMCICDIA > 0 -> calcular fecha-borrado-diario; borrar datasets diarios vencidos
IF WKS-B03-NUMCICMES > 0 -> calcular fecha-borrado-mensual; borrar datasets mensuales vencidos
```

**Vocabulario en la fórmula:** WKS-B03-NUMCICDIA · WKS-B03-NUMCICMES · fecha de borrado · retención · ciclo

**Excepciones:**
- Con NUMCICDIA o NUMCICMES = 0 no se ejecuta borrado para ese periodo (retención indefinida).

**Estado validación:** Verificado fuente líneas 2095-2120, 2173-2191

---

## RN-S151-810 — Rotación de bases: recreación (CREATE) de datasets de saldos y posición

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-810 |
| **Nombre** | Rotación de bases: recreación (CREATE) de datasets de saldos y posición |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P197 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso de rotación (`01-0590-ROTABASES`) recrea físicamente los datasets DMSII de la base de saldos mediante sentencias `CREATE`, incluyendo saldos mensuales consolidados (`S151B20SDOMENCON`, `S151B21SDMENCON1`) y datasets de posición (`S151B70POSICION`, `S151B71POSDIAAD1`). La rotación reinicializa las estructuras para el nuevo ciclo tras el borrado de información vencida.

**Fórmula/pseudocódigo:**
```
PERFORM 01-0590-ROTABASES:
   CREATE S151B20SDOMENCON
   CREATE S151B21SDMENCON1
   CREATE S151B70POSICION
   CREATE S151B71POSDIAAD1
```

**Vocabulario en la fórmula:** ROTABASES · CREATE · SDOMENCON · POSICION · dataset DMSII

**Excepciones:**
- El CREATE reinicializa la estructura; debe ejecutarse después del borrado para no perder datos vigentes.

**Estado validación:** Verificado fuente líneas 2191, 2486-2699

---

## RN-S151-811 — Actualización de contadores de ciclo vía funciones 6 (diario) y 7 (mensual)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-811 |
| **Nombre** | Actualización de contadores de ciclo vía funciones 6 (diario) y 7 (mensual) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P197 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La base de control expone funciones numeradas para actualizar los contadores de ciclo: la función 6 modifica el campo `NUMCICDIA` (número de ciclo diario) y la función 7 modifica `NUMCICMES` (número de ciclo mensual). ROTABASE invoca estas funciones para avanzar los contadores de ciclo tras completar cada rotación, manteniendo el estado de dónde va la rotación.

**Fórmula/pseudocódigo:**
```
FUNCION 6 -> modifica NUMCICDIA (avanza ciclo diario)
FUNCION 7 -> modifica NUMCICMES (avanza ciclo mensual)
```

**Vocabulario en la fórmula:** FUNCION 6 · FUNCION 7 · NUMCICDIA · NUMCICMES · ciclo

**Excepciones:**
- El uso de funciones numeradas acopla el programa a la interfaz de la librería de control.

**Estado validación:** Verificado fuente líneas 831-839

---

## RN-S151-812 — Selección de movimientos a la base diaria: función 1, estatus 1, feccont ≤ fecha proceso

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-812 |
| **Nombre** | Selección de movimientos a la base diaria: función 1, estatus 1, feccont ≤ fecha proceso |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P111 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P111 actualiza la base semanal/diaria `S151BD10MOVDIA151`. Sólo integra los movimientos cuya función es 1 y estatus es 1 (movimiento vivo y activo) y cuya fecha contable (`FECCONT`) es menor o igual a la fecha de proceso. El filtro excluye movimientos futuros, cancelados y no activos del libro diario.

**Fórmula/pseudocódigo:**
```
IF A00-R01-FUNCION = 1 AND A00-R01-STATUS = 1
   AND A00-R01-FECCONT <= fecha-proceso
   -> integrar a BD10MOVDIA151 (armar registro y grabar)
```

**Vocabulario en la fórmula:** A00-R01-FUNCION · A00-R01-STATUS · A00-R01-FECCONT · fecha de proceso · BD10MOVDIA151

**Excepciones:**
- Movimientos con FECCONT futura no se aplican al día en curso (se difieren).

**Estado validación:** Verificado fuente líneas 18-20, 2164, 2183, 2209

---

## RN-S151-813 — Reclasificación de tipo de proceso para el sistema 500 según claves 3009 y 3036

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-813 |
| **Nombre** | Reclasificación de tipo de proceso para el sistema 500 según claves 3009 y 3036 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P111 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para el sistema 500, el programa normaliza el tipo de proceso: si el tipo original es menor a 15, o es 15/16/17 acompañado de las claves de transacción 3009 o 3036, se fuerza a tipo 1; en cualquier otro caso se fuerza a 11. Las claves 3009 y 3036 están embebidas como excepciones específicas de reclasificación contable.

**Fórmula/pseudocódigo:**
```
IF WKS-PARAM-SIS = 500
   IF TIPO-PROC < 15
      OR (TIPO-PROC IN {15,16,17} AND CVETRAN(1) IN {3009, 3036})
      TIPO-PROC = 1
   ELSE
      TIPO-PROC = 11
```

**Vocabulario en la fórmula:** WKS-PARAM-SIS · A00-R01-TIPO-PROC · A00-R01-CVETRAN · 3009 · 3036

**Excepciones:**
- Las claves 3009 y 3036 son excepciones hardcodeadas; nuevas claves equivalentes requieren cambio de código.

**Estado validación:** Verificado fuente líneas 2155-2161

---

## RN-S151-814 — Exclusión de movimientos Teletón del sistema 500 (tipos 40 a 43)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-814 |
| **Nombre** | Exclusión de movimientos Teletón del sistema 500 (tipos 40 a 43) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P111 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al leer cada registro, para el sistema 500 los movimientos con tipo de proceso 40, 41, 42 o 43 (identificados en comentario como movimientos Teletón) se excluyen de la actualización de la base diaria: no se marcan como registro válido y se saltan. Es una regla de negocio específica que aparta las operaciones de la campaña Teletón del flujo contable estándar.

**Fórmula/pseudocódigo:**
```
IF WKS-PARAM-SIS = 500 AND TIPO-PROC IN {40, 41, 42, 43}
   NEXT SENTENCE   (excluir; no marcar REG-OK)
ELSE
   W77-REG-OK = 1
```

**Vocabulario en la fórmula:** WKS-PARAM-SIS · A00-R01-TIPO-PROC · Teletón · exclusión

**Excepciones:**
- Los tipos 40-43 están embebidos; la definición de "movimiento Teletón" no es parametrizable.

**Estado validación:** Verificado fuente líneas 2198-2204

---

## RN-S151-815 — Registro terminador de archivo: función 99 marca fin de proceso

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-815 |
| **Nombre** | Registro terminador de archivo: función 99 marca fin de proceso |
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
| **Programa ejecutor** | P111 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de movimientos usa el valor de función 99 como registro terminador (trailer lógico). Al leer un registro con `A00-R01-FUNCION = 99`, el programa marca fin de lectura (`W77-LEE-FIN`), cerrando el ciclo de proceso independientemente de si se alcanzó el fin físico del archivo. Es un centinela de fin de datos válidos.

**Fórmula/pseudocódigo:**
```
IF A00-R01-FUNCION = 99
   MOVE 1 TO W77-LEE-FIN   (fin de proceso)
```

**Vocabulario en la fórmula:** A00-R01-FUNCION · 99 · W77-LEE-FIN · registro terminador

**Excepciones:**
- Los registros posteriores al de función 99 se ignoran aunque existan físicamente.

**Estado validación:** Verificado fuente líneas 2206-2207

---

## RN-S151-816 — Armado de hasta 5 conceptos contables por movimiento (clave, esquema, importe)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-816 |
| **Nombre** | Armado de hasta 5 conceptos contables por movimiento (clave, esquema, importe) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P111 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada movimiento puede portar hasta 5 conceptos contables en arreglo. El programa recorre las 5 posiciones (`VARYING W77-IND FROM 1 BY 1 UNTIL > 5`) y arma un registro de saldo por cada posición cuya clave de transacción (`CVETRAN`) es mayor a cero, tomando su esquema contable (`ESQCON`) e importe (`IMPORTE`). Un movimiento genera así múltiples asientos contables (uno por concepto ocupado).

**Fórmula/pseudocódigo:**
```
PERFORM ARMA-REGISTRO VARYING W77-IND FROM 1 BY 1 UNTIL W77-IND > 5:
   IF A00-R01-CVETRAN(W77-IND) > 0
      registro += { CVETRAN(IND), ESQCON(IND), IMPORTE(IND) }
```

**Vocabulario en la fórmula:** A00-R01-CVETRAN · A00-R01-ESQCON · A00-R01-IMPORTE · concepto · esquema contable

**Excepciones:**
- Posiciones con CVETRAN = 0 se omiten (concepto no usado).

**Estado validación:** Verificado fuente líneas 2183-2186, 2214-2219

---

## RN-S151-817 — Asignación de banco origen y destino por sistema (500 real, 403/404 sin cambio, resto default 2)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-817 |
| **Nombre** | Asignación de banco origen y destino por sistema (500 real, 403/404 sin cambio, resto default 2) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P111 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El banco origen y destino del registro de saldo se asigna según el sistema: para el sistema 500 se toman los valores reales del movimiento (`BCO-ORI`, `BCO-DES`); para los sistemas 403 o 404 se conservan sin cambio (NEXT SENTENCE); para cualquier otro sistema se asigna por default el valor 2 tanto a origen como a destino. Refleja que sólo el sistema 500 maneja identificación interbancaria explícita.

**Fórmula/pseudocódigo:**
```
IF WKS-PARAM-SIS = 500
   WKS-RS-BCOORI = BCO-ORI ; WKS-RS-BCODES = BCO-DES
ELSE IF WKS-PARAM-SIS = 403 OR 404
   NEXT SENTENCE  (sin cambio)
ELSE
   WKS-RS-BCOORI = 2 ; WKS-RS-BCODES = 2
```

**Vocabulario en la fórmula:** WKS-PARAM-SIS · WKS-RS-BCOORI · WKS-RS-BCODES · banco origen · banco destino

**Excepciones:**
- El default 2 para sistemas distintos de 500/403/404 es un valor mágico embebido.

**Estado validación:** Verificado fuente líneas 2173-2181

---

## RN-S151-818 — Comparativo contable S264: diferencias entre los envíos a S028 y a S115

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-818 |
| **Nombre** | Comparativo contable S264: diferencias entre los envíos a S028 y a S115 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P128 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P128 produce el reporte de diferencias del S264 comparando lo que se envía al sistema S028 contra lo que se envía al S115, sacando las diferencias contables entre ambos envíos. Acumula el importe destinado a cada sistema en `WKS-IMPORTE-028` y `WKS-IMPORTE-115` y contrasta ambos flujos para detectar inconsistencias entre destinos contables.

**Fórmula/pseudocódigo:**
```
por movimiento S264:
   WKS-IMPORTE-028(i) = importe enviado a S028
   WKS-IMPORTE-115(i) = importe enviado a S115
diferencia = importe_028 - importe_115  (por grupo)
reportar en "DIFERENCIAS DEL S264 ENTRE EL S028 Y S115"
```

**Vocabulario en la fórmula:** WKS-IMPORTE-028 · WKS-IMPORTE-115 · S028 · S115 · S264 · DIFS264

**Excepciones:**
- Entrada: `S151/FILE/MOVS264/AAMMDD`; salida: reporte `S264/LIST/P128`.

**Estado validación:** Verificado fuente líneas 5-8, 1479-1484, 1944

---

## RN-S151-819 — Agrupamiento del comparativo por moneda, sucursal, referencia y clave de transacción

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-819 |
| **Nombre** | Agrupamiento del comparativo por moneda, sucursal, referencia y clave de transacción |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P128 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El comparativo de diferencias se ordena y agrupa por moneda (`S01-MONEDA`), sucursal inicial (`S01-SUC-INIC`), número de referencia (`S01-REFNUM`) y clave de transacción (`S01-CVETRAN`). Esta llave compuesta define el nivel al que se comparan los importes enviados a S028 y S115, permitiendo aislar la diferencia por moneda y operación.

**Fórmula/pseudocódigo:**
```
SORT S01-MOVTOS ON ASCENDING KEY
     S01-MONEDA, S01-SUC-INIC, S01-REFNUM, S01-CVETRAN
     INPUT PROCEDURE 30000-ESCOGE-MOV
     OUTPUT PROCEDURE 40000-REPORTA-MOV
```

**Vocabulario en la fórmula:** S01-MONEDA · S01-SUC-INIC · S01-REFNUM · S01-CVETRAN · agrupamiento

**Excepciones:**
- El procedimiento de entrada (30000-ESCOGE-MOV) filtra los movimientos relevantes antes de ordenar.

**Estado validación:** Verificado fuente líneas 1806-1814

---

## RN-S151-820 — Determinación de cuadre por igualdad de totales de importe S028 vs S115

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-820 |
| **Nombre** | Determinación de cuadre por igualdad de totales de importe S028 vs S115 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P128 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa determina si un grupo cuadra comparando el total de importe enviado a S028 (`W77-TOT-IMP028`) contra el total enviado a S115 (`W77-TOT-IMP115`). Si son iguales el grupo está balanceado; si difieren, se detalla la diferencia listando los importes de ambos lados (028 y 115) en el reporte con sus totales `WSR-TOT-S028` y `WSR-TOT-S115`.

**Fórmula/pseudocódigo:**
```
IF W77-TOT-IMP028 = W77-TOT-IMP115
   grupo cuadrado (no diferencia)
ELSE
   listar detalle: WKS-IMPORTE-028(j) vs WKS-IMPORTE-115(j)
   totales WSR-TOT-S028 / WSR-TOT-S115
```

**Vocabulario en la fórmula:** W77-TOT-IMP028 · W77-TOT-IMP115 · WSR-TOT-S028 · WSR-TOT-S115 · cuadre

**Excepciones:**
- La comparación es por igualdad exacta; no se define tolerancia de redondeo.

**Estado validación:** Verificado fuente líneas 1985, 2036-2045, 1662-1664

---

## RN-S151-821 — Cálculo dinámico de espacio de SORT en función del tamaño de registro y volumen

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-821 |
| **Nombre** | Cálculo dinámico de espacio de SORT en función del tamaño de registro y volumen |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P128 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de ordenar, el programa calcula dinámicamente la memoria y el disco requeridos por el SORT en función del tamaño máximo de registro (`W77-MAXRECSIZE`) y el número de registros (`W77-LASTRECORD`), con conversión a palabras según el framesize del MCP. La memoria se estima como (maxrecsize+3)*2000+1500 y el disco como maxrecsize*lastrecord*3.5, patrón específico de ClearPath MCP.

**Fórmula/pseudocódigo:**
```
IF W77-FRAMESIZE = 8 -> W77-MAXRECSIZE = ceil(maxrecsize / 6)
W77-MEMORY-SIZE = (W77-MAXRECSIZE + 3) * 2000 + 1500
W77-DISK-SIZE   = W77-MAXRECSIZE * W77-LASTRECORD * 3.5
```

**Vocabulario en la fórmula:** W77-MAXRECSIZE · W77-MEMORY-SIZE · W77-DISK-SIZE · W77-FRAMESIZE · MCP

**Excepciones:**
- Los factores 2000, 1500 y 3.5 son constantes de dimensionamiento específicas del entorno Unisys MCP.

**Estado validación:** Verificado fuente líneas 1824-1843

---

## RN-S151-822 — Convención de nombres de archivos de entrada y salida fechados por AAMMDD

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-822 |
| **Nombre** | Convención de nombres de archivos de entrada y salida fechados por AAMMDD |
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
| **Programa ejecutor** | P128 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa consume el archivo de entrada `S151/FILE/MOVS264/AAMMDD` (fechado con año-mes-día) y produce el reporte de salida bajo el prefijo `S264/LIST/P128/` con nombre lógico "001S151DIFS264". La fecha embebida en el nombre del archivo es el mecanismo de particionamiento diario de los movimientos S264, típico del batch contable.

**Fórmula/pseudocódigo:**
```
entrada = "...S151/FILE/MOVS264/" + AAMMDD
salida  = "...S264/LIST/P128/" + ...  ; nombre-reporte = "001S151DIFS264"
```

**Vocabulario en la fórmula:** MOVS264 · DIFS264 · AAMMDD · S264/LIST/P128 · particionamiento diario

**Excepciones:**
- La fecha AAMMDD (sin siglo) en el nombre depende de convención externa de la corrida.

**Estado validación:** Verificado fuente líneas 8, 1450, 1461, 1737
