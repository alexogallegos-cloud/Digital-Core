# Reglas de Negocio — P151 (Transformador IBM-Citibank ALR/AHR/OCM)
> **Capacidad bancaria:** 6.7.1 Financial Reconciliation · Interfaz IBM-Citibank (ALR/AHR/OCM)
> **Programa fuente:** COBOL_P151.txt · Autor: ING. JAVIER MERCADO FLORES
> **Frecuencia:** cierre-diario
> **Sistemas downstream:** ARCH-ALR · ARCH-AHR · ARCH-OCM · MOVSCIG · PUNTEO (ARCH-SAL)
> **Rango:** RN-S151-331 a RN-S151-360 (30 reglas)
> **Actualizado:** 2026-07-16

---

## RN-S151-331
**Identificador:** RN-S151-331
**Tipo:** Estructural
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** P151 transforma movimientos S151 del día en tres archivos de interfaz IBM-Citibank: ALR (Account Ledger), AHR (Account History) y OCM (Order Collection Message). El programa recibe W77-SISTEMA-PARAMETRO como argumento de entrada que controla qué sistema se procesa (500=captación, 701=pagos, etc.).

**Fórmula/pseudocódigo:**
```
ENTRY: W77-SISTEMA-PARAMETRO
IF sistema = 500 → proceso captación (ALR+AHR+OCM)
IF sistema = 701 → proceso pagos
PERFORM 20000-PROCESA-MOVIMIENTOS
PERFORM 40000-GENERA-ARCHIVOS
CALL WFL P940 → FTP a IBM
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| ALR | Account Ledger Record — registro de movimiento en libro contable |
| AHR | Account History Record — historial de cuenta extendido con SAT/SPEI |
| OCM | Order Collection Message — mensaje de cobro a CitiDirect |
| W77-SISTEMA-PARAMETRO | Parámetro de entrada que identifica el sistema a procesar |

**Excepciones:** Sistema ≠ 500/701 no tiene lógica activa — programa termina sin generar archivos.
**Estado validación:** Verificado en PROCEDURE DIVISION línea 12483.

---

## RN-S151-332
**Identificador:** RN-S151-332
**Tipo:** Funcional
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** La condición de generación de ALR es `RMC-IND-SIS = 1`. El campo IND-SIS del registro sort (SMOVTOS-CITICTD) es el enrutador primario: valor 1 genera ALR, valor 1 o 2 genera AHR, y la combinación de IND-SIS=1 + INDCITI=2 + CTACON IN(11,61) genera OCM.

**Fórmula/pseudocódigo:**
```
IF RMC-IND-SIS = 1        → WRITE ALR
IF RMC-IND-SIS = 1 OR 2  → WRITE AHR
IF RMC-IND-SIS = 1 AND
   WKS-PT-INDCITI(CVETRAN)=2 AND
   (IND-CD=2/3 OR IND-BN=1) AND
   RMC-CTACON IN (11, 61) → WRITE OCM
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| RMC-IND-SIS | Indicador de sistema del movimiento Citi; 1=ALR, 1/2=AHR |
| RMC-CTACON | Cuenta contable del movimiento; 11 o 61 habilita OCM |
| WKS-PT-INDCITI | Tabla de categorías Citi por CVETRAN; valor 2 = apto OCM |

**Excepciones:** IND-SIS=0 excluye el movimiento de todos los archivos Citi.
**Estado validación:** Verificado en paragraphs 41000-GRABA-ARCHIVOS-CITI líneas 14268-14392.

---

## RN-S151-333
**Identificador:** RN-S151-333
**Tipo:** Estructural
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** La distribución de ALR/AHR/OCM por región está hardcodeada en archivos separados: VDM (Valle de México), MTY (Monterrey), UNI (Universal). Cada región tiene su propio archivo de salida (A01/A02-MOVS-ALR-VDM, A02-ALR-MTY, etc.). La región se determina por el campo RMC-SUBNODO o WKS-NODO en el sort, no por parametrización.

**Fórmula/pseudocódigo:**
```
ARCH-ALR-VDM  → región Valle de México
ARCH-ALR-MTY  → región Monterrey
ARCH-ALR-UNI  → región Universal
% Título: SNNN{ALR/AHR/OCM}/CO/AAMMDD
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| VDM | Valle de México — región de operación |
| MTY | Monterrey — región de operación |
| UNI | Universal — región sin clasificación geográfica específica |
| SUBNODO | Nodo de distribución de red que determina la región |

**Excepciones:** Subnodo sin mapping a región conocida fallará silenciosamente — movimiento perdido.
**Estado validación:** Verificado en FD declarations líneas 1082-1199.

---

## RN-S151-334
**Identificador:** RN-S151-334
**Tipo:** Funcional — Modificación ISILOA
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** Las variantes BNE (Banamex) fueron añadidas por modificación ISILOA post-base. Se activan por condición `W88-HOSTNAME`. Los archivos BNE son copias paralelas de ALR/AHR/OCM con IND-CD e IND-BN como campos discriminantes (añadidos en SMCI). El cierre de BNE es independiente: `CLOSE ARCH-ALR-BNE WITH SAVE` solo si W88-HOSTNAME es verdadero.

**Fórmula/pseudocódigo:**
```
IF W88-HOSTNAME
   PERFORM 78000-ENVIA-INTELAR-BNE
   CLOSE ARCH-ALR-BNE WITH SAVE
   CLOSE ARCH-AHR-BNE WITH SAVE
   CLOSE ARCH-OCM-BNE WITH SAVE
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| W88-HOSTNAME | Condición 88 que activa rutas BNE — identifica host Banamex |
| IND-CD | Indicador de CitiDirect; RMCI-IND-CD NUMBER(01) |
| IND-BN | Indicador de BNE (Banamex Network); RMCI-IND-BN NUMBER(01) |
| ISILOA | Identificador de la modificación que añadió variantes BNE |

**Excepciones:** Sin W88-HOSTNAME verdadero, los archivos BNE no se generan — downstream BNE queda sin datos.
**Estado validación:** Verificado en líneas 14218-14223 y comentarios ISILOA.

---

## RN-S151-335
**Identificador:** RN-S151-335
**Tipo:** Formato de interfaz
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** El registro ALR (ALRINT-REC) tiene estructura fija: RECORD-TYPE X(03) + KEY-GRP X(83) que incluye BRCH-NBR(03)+CUST-NBR(12)+CCY-NBR(03)+ACCT-NBR(35)+VAL-DATE(06)+CTRCT-REF-NBR(16)+CURRENT-NO(08). El bloque de texto tiene 5 TEXT-LINEs de X(35) cada una. BLOCK CONTAINS 100 RECORDS.

**Fórmula/pseudocódigo:**
```
ALRINT-REC layout:
  RECORD-TYPE(3) + KEY-GRP(83):
    BRCH-NBR(3) + CUST-NBR(12) + CCY-NBR(3)
    + ACCT-NBR(35) + VAL-DATE(6)
    + CTRCT-REF-NBR(16) + CURRENT-NO(8)
  + TXN-CODE(4) + DR-CR-IND(1) + TXN-AMT(17)
  + TEXT-LINES(175 = 5×35)
  + ORIG-FILE(2)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| ALRINT-REC | Registro ALR — Account Ledger Interface Record |
| BRCH-NBR | Branch Number — hardcodeado a 485 (Banamex) |
| CUST-NBR | Customer Number — mapeado desde RMC-CLIENTE |
| CURRENT-NO | Número de secuencia ALR — W77-CONTADOR-ALR (no AUTS151) |

**Excepciones:** BRCH-NBR siempre es 485 (hardcode) — no varía por sucursal real.
**Estado validación:** Verificado en FD ARCH-ALR líneas 764-822 y lógica 14268-14330.

---

## RN-S151-336
**Identificador:** RN-S151-336
**Tipo:** Funcional — Mapeo de clave
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** El campo ALRINT-CURRENT-NO en el registro ALR recibe W77-CONTADOR-ALR (contador secuencial del programa), NO el campo RMC-AUTS151. Las líneas comentadas en el código muestran que originalmente se usaba AUTS151, pero fue cambiado. Esto implica que el CURRENT-NO en ALR es relativo al proceso de P151 del día, no el identificador universal S151.

**Fórmula/pseudocódigo:**
```
*MOVE RMC-AUTS151 TO ALRINT-CURRENT-NO  % ORIGINAL — COMENTADO
MOVE W77-CONTADOR-ALR TO ALRINT-CURRENT-NO  % ACTUAL
ADD 1 TO W77-CONTADOR-ALR  % previo al WRITE
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| W77-CONTADOR-ALR | Contador secuencial de registros ALR del día — reinicia cada ejecución |
| AUTS151 | Autorización S151 original — no usado en CURRENT-NO (comentado) |
| CURRENT-NO | Secuencia en ALR — no es el identificador bancario real del movimiento |

**Excepciones:** Reconciliación por CURRENT-NO en IBM no tiene correspondencia directa con AUTS151 de BD10.
**Estado validación:** Verificado en código comentado líneas 14285-14286.

---

## RN-S151-337
**Identificador:** RN-S151-337
**Tipo:** Funcional — Signo de importe
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** El importe en ALR se envía con campo separado de signo. `ALRINT-TXN-AMT` contiene el valor absoluto y `ALRINT-DR-CR-IND` (X(01)) contiene 'D' o 'C'. La naturaleza D/C se determina en `41210-VALIDA-NATURALEZA-ALR`. Para OCM, el signo es '+' o '-' directamente en OCMIN-PAY-ORI-SIGN. Los dos formatos son inconsistentes entre sí.

**Fórmula/pseudocódigo:**
```
ALR: ALRINT-TXN-AMT = |importe|, DR-CR-IND = 'D'/'C'
OCM: OCMIN-PAY-ORI-SIGN = '+'/'-' según RMC-IMPORTE < 0
AHR: AHRST-TXN-AMT = |importe|, AHRST-TXN-AMT-SIGN separado
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| ALRINT-DR-CR-IND | Indicador débito/crédito en ALR; X(01) — 'D' o 'C' |
| OCMIN-PAY-ORI-SIGN | Signo del importe en OCM; '+' o '-' literal |
| AHRST-TXN-AMT-SIGN | Signo del importe en AHR — tercer formato |

**Excepciones:** Los tres formatos de signo son distintos — inconsistencia al reconciliar entre ALR, AHR y OCM.
**Estado validación:** Verificado en lógica de escritura de los tres archivos.

---

## RN-S151-338
**Identificador:** RN-S151-338
**Tipo:** Formato de interfaz — SAT
**Confianza:** ALTA
**Regulador:** SAT
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** El registro AHR (AHRST-REC) incluye campos extendidos SAT Anexo 20: NOM-ORD X(120), RFC-ORD X(20), BCO-ORD X(20), CTA-BENEF X(35 con REDEFINES), NOM-BENEF X(120), RFC-BENEF X(20), BCO-BENEF X(20), CVE-RASTREO X(30). Adicionalmente incluye campos de devolución SPEI: SELLO-DIGIT X(400), FEC-DEV(08), HORA-DEV(06), CAUSA-DEV X(120), ID-DEV, INT-DEV(20), FEC-ENV(08), HORA-ENV(08), ESTADO-TRAN X(40).

**Fórmula/pseudocódigo:**
```
AHRST-REC SAT section (AHM INI/FIN):
  CVE-ORD(35): REDEFINES como 9(15) o 9(20)
  NOM-ORD(120) + RFC-ORD(20) + BCO-ORD(20)
  CTA-BENEF(35): REDEFINES como 9(15) o 9(20)
  NOM-BENEF(120) + RFC-BENEF(20) + BCO-BENEF(20)
  CVE-RASTREO(30) + FEC-LIQUID(8) + HORA-LIQUID(8)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| AHRST-CVE-ORD | Clave del ordenante SPEI; X(35) con REDEFINES a numérico |
| AHRST-SELLO-DIGIT | Sello digital del CFDi; X(400) |
| AHRST-ESTADO-TRAN | Estado de la transacción SPEI; X(40) |
| SAT Anexo 20 | Regulación SAT para campos de transferencias electrónicas |

**Excepciones:** RFC en AHR es X(20) mientras que en REG-MOVIMIENTOS es X(13)/X(18) — requiere padding en mapeo.
**Estado validación:** Verificado en FD ARCH-AHR líneas 992-1077 con marcadores AHM INI/FIN.

---

## RN-S151-339
**Identificador:** RN-S151-339
**Tipo:** Funcional — Validación SAT
**Confianza:** ALTA
**Regulador:** SAT
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** P151 ejecuta `PERFORM 100-27937-VALIDA-SAT` y `PERFORM 100-27938-VAL-DFTPY` antes de escribir el AHR. Estos paragraphs validan los campos del SAT Anexo 20. El campo AHRST-PRIME-DELIMETER recibe el valor literal "X" como separador antes del write. La validación de DFTPY controla el tipo de pago default (AHRST-DFT-PAYMENT-TYPE).

**Fórmula/pseudocódigo:**
```
PERFORM 100-27937-VALIDA-SAT    % Valida RFC, NOM, CVE-ORD
PERFORM 100-27938-VAL-DFTPY     % Valida tipo de pago
MOVE "X" TO AHRST-PRIME-DELIMETER OF ARCH-AHR
PERFORM 41300-ARCHIVO-AHR       % Distribuye a región VDM/MTY/UNI/BNE
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| 100-27937-VALIDA-SAT | Paragraph de validación de campos SAT Anexo 20 |
| AHRST-DFT-PAYMENT-TYPE | Tipo de pago default en AHR; 9(01) |
| AHRST-PRIME-DELIMETER | Separador primario en AHR; valor fijo "X" |

**Excepciones:** Fallo en validación SAT puede dejar campos vacíos en AHR, generando rechazo en IBM.
**Estado validación:** Verificado en líneas 14372-14374.

---

## RN-S151-340
**Identificador:** RN-S151-340
**Tipo:** Funcional — Devolución SPEI
**Confianza:** ALTA
**Regulador:** Banxico
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** AHRST-REVRS-IND X(01) identifica reversiones/devoluciones SPEI en el AHR. El campo AHRST-FEC-DEV(08) y AHRST-HORA-DEV(06) registran la fecha y hora de devolución. AHRST-CAUSA-DEV X(120) contiene la descripción de la causa. La combinación de estos campos permite a IBM-Citibank identificar y procesar devoluciones sin ambigüedad. En el ALR, el campo equivalente es ALRINT-REVRS-IND X(01).

**Fórmula/pseudocódigo:**
```
MOVE SPACE TO ALRINT-REVRS-IND OF ARCH-ALR  % Normal
MOVE SPACE TO AHRST-REVRS-IND  OF ARCH-AHR  % Normal
% Para reversión SPEI:
% REVRS-IND ≠ SPACE → fecha/hora/causa de devolución activos
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| AHRST-REVRS-IND | Indicador de reversa/devolución en AHR; SPACE=normal |
| AHRST-FEC-DEV | Fecha de devolución SPEI en AHR; 8 dígitos CCAAMMDD |
| AHRST-CAUSA-DEV | Causa de devolución SPEI; X(120) |
| devolución SPEI | Retorno de transferencia por cuenta inválida u otras causas |

**Excepciones:** REVRS-IND=SPACE inicializado explícitamente — no usar el valor de memoria anterior.
**Estado validación:** Verificado en líneas 14315/14363 y estructura AHRST-REC.

---

## RN-S151-341
**Identificador:** RN-S151-341
**Tipo:** Formato de interfaz
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** El registro OCM (OCMIN-REC) tiene TRANS-ID X(13) compuesto por CODE-SYSTEM-BM(02)+TRANS-DATE(05)+SEQ-NUMBER(06). CODE-SYSTEM-BM recibe el literal "BM" (Banamex). TRANS-DATE(05) es formato Julian. COUNTRY-CODE recibe 485 (México). MESSAGE-TYPE recibe "B" y TRANS-TYPE recibe "A" — hardcodes de protocolo OCM.

**Fórmula/pseudocódigo:**
```
OCMIN-TRANS-ID:
  CODE-SYSTEM-BM = "BM"
  TRANS-DATE(5) = FECOPER formato juliano via THECALENDAR
  SEQ-NUMBER(6) = W77-CONTADOR-OCM
OCMIN-COUNTRY-CODE = 485  % México
OCMIN-MESSAGE-TYPE = "B"
OCMIN-TRANS-TYPE   = "A"
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| OCMIN-TRANS-ID | Transaction ID del OCM: "BM"+fecha_juliana+secuencia |
| W77-CONTADOR-OCM | Contador secuencial de registros OCM del día |
| THECALENDAR | Función LOCSUP para conversión de fechas (función 5, formato 13) |
| CODE-SYSTEM-BM | Código del sistema emisor; "BM" = Banamex |

**Excepciones:** COUNTER-OCM reinicia cada ejecución — no es correlativo cross-day.
**Estado validación:** Verificado en líneas 14393-14418.

---

## RN-S151-342
**Identificador:** RN-S151-342
**Tipo:** Formato de interfaz
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** OCMIN-PAYMENT-DET X(1,243) contiene hasta 10 cheques con sus datos (CLEAR-CODE+CHECK-NO+CRED-DATE+SIGN+AMOUNT+CHEQ-STA+BANK-CODE+BRANCH-COD+BANK-BRAN cada uno) seguidos de 10 TITLE-NOs(14). En P151, solo el primer cheque se popula (OCMIN-PAY-CHECK-AMO-1 = RMC-IMPORTE), el resto queda en ceros. PAY-AGENT-CODE recibe 485.

**Fórmula/pseudocódigo:**
```
PAY-PORTFOLIO = 0
PAY-NUMBER    = 0
PAY-ORI-AMOUNT = PAY-CRED-AMOUNT = PAY-CHECK-AMO-1 = RMC-IMPORTE
PAY-CRED-DATE  = RMC-FECCONT
PAY-TITLE-STA  = 11
PAY-AGENT-CODE = 485
CHEQUES 2..10  = ZEROS (no poblados)
SIGN = '+' si IMPORTE ≥ 0, '-' si IMPORTE < 0
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| OCMIN-PAY-AGENT-CODE | Código del agente cobrador; 485 = Banamex |
| OCMIN-PAY-TITLE-STA | Estado del título; 11 = activo para cobro |
| OCMIN-PAY-NUMBER | Número de cheque dentro del mensaje; 0 = primer cheque |

**Excepciones:** Campos 2..10 en ceros — si IBM espera múltiples cheques, la lógica de lectura downstream los ignorará.
**Estado validación:** Verificado en líneas 14422-14453.

---

## RN-S151-343
**Identificador:** RN-S151-343
**Tipo:** Estructural — Sort input Citi
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** El archivo de sort ARCH-CITICTD (SMOVTOS-CITICTD) tiene estructura con prefijo SMCI-/RMC- equivalente a REG-MOVIMIENTOS pero en 60→106 bytes post-Y2K. Tiene un solo LEYENDA X(40) con REDEFINES en 35+5 bytes (vs 5 leyendas del registro principal). Los campos IND-CD e IND-BN fueron añadidos por ISILOA. El sort MOVTOS-CITICTD ordena los movimientos antes de procesarlos en 41000-GRABA-ARCHIVOS-CITI.

**Fórmula/pseudocódigo:**
```
SMOVTOS-CITICTD sort key: % por definir en sort statement
RMC-LEYENDA X(40) REDEFINES:
  RMC-LEYENDA-35 X(35)  % primeros 35 bytes
  RMC-LEYENDA-05 X(05)  % últimos 5 bytes
SMCI-IND-CD NUMBER(01)  % ISILOA
SMCI-IND-BN NUMBER(01)  % ISILOA
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| SMOVTOS-CITICTD | Sort file de movimientos Citi — ordena antes de generar ALR/AHR/OCM |
| RMC-LEYENDA-35/05 | Leyenda partida en 35+5 para compatibilidad con campos ALR/OCM |
| MOVTOS-CITICTD | Sort file de movimientos Citi pre-BNE |

**Excepciones:** LEYENDA de solo 1 (vs 5 del registro principal) — movimientos con LEY2-5 las pierden en el archivo Citi.
**Estado validación:** Verificado en SD SMOVTOS-CITICTD línea 729.

---

## RN-S151-344
**Identificador:** RN-S151-344
**Tipo:** Funcional — Carga inicial
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** El flujo principal de P151 para sistema 500 incluye: (1) cargar catálogos `12000-CARGA-CATALOGOS` dos veces (sistema 500 y sistema 408), (2) buscar clave SBC `15000-BUSCA-CVE-SBC`, (3) procesar movimientos `20000-PROCESA-MOVIMIENTOS`, (4) selección de movimientos `30000-SELECCION-MOVIMIENTOS`, (5) ordenar por hora `35000-SORTEA-MOVTOS-HORA`, (6) generar archivos `40000-GENERA-ARCHIVOS`.

**Fórmula/pseudocódigo:**
```
1. PERFORM 12000-CARGA-CATALOGOS (sistema=500)
2. PERFORM 12000-CARGA-CATALOGOS (sistema=408)
3. PERFORM 15000-BUSCA-CVE-SBC
4. PERFORM 20000-PROCESA-MOVIMIENTOS → sort input
5. PERFORM 30000-SELECCION-MOVIMIENTOS
6. PERFORM 35000-SORTEA-MOVTOS-HORA
7. PERFORM 40000-GENERA-ARCHIVOS → ALR/AHR/OCM
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| 12000-CARGA-CATALOGOS | Carga tablas de referencia de S151 (BD99 catálogos) |
| 15000-BUSCA-CVE-SBC | Busca clave de la Sucursal de Bancos Centrales |
| 20000-PROCESA-MOVIMIENTOS | Lee BD10 y llena sort input MOVIMIENTOSCTD |
| 35000-SORTEA-MOVTOS-HORA | Sort secundario por hora de operación |

**Excepciones:** La doble carga de catálogos (500 y 408) implica que sistema 408 es un alias de 500 para catalogación.
**Estado validación:** Verificado en líneas 12575-12584.

---

## RN-S151-345
**Identificador:** RN-S151-345
**Tipo:** Funcional — Punteo
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** ARCH-SAL es un archivo INDEXED con acceso RANDOM por KEY-CTO usado en la sección VML (Virtual Machine Ledger). Funciona como "saldo virtual" del contrato durante el procesamiento del día. El archivo de título WKS-TIT-SALS500 sigue el patrón "S151/FILE/S{SIS}/PBATCH/{CSI}/{FEC}". Este archivo implementa la función de punteo (reconciliación intradiaria de saldos) con S500.

**Fórmula/pseudocódigo:**
```
ARCH-SAL: INDEXED, RANDOM
  KEY = KEY-CTO (número de contrato)
  TITLE = "S151/FILE/S{SIS}/PBATCH/{CSI}/{FEC}"
  USO: leer saldo actual → actualizar → reescribir
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| ARCH-SAL | Archivo de saldo virtual por contrato — punteo intradiario |
| KEY-CTO | Clave de contrato como llave de ARCH-SAL indexed |
| punteo | Reconciliación de saldos entre S151 y S500 en tiempo real |
| VML | Virtual Machine Ledger — sección de procesamiento de saldos virtuales |

**Excepciones:** Contrato sin registro en ARCH-SAL falla el lookup RANDOM — requiere inicialización previa.
**Estado validación:** Verificado en WKS-TIT-SALS500 línea 615 y análisis de FILE-CONTROL.

---

## RN-S151-346
**Identificador:** RN-S151-346
**Tipo:** Funcional — Log complementario
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** LOG151-COMP es un archivo de disco en acceso RANDOM (540 bytes/registro) accedido por W77-LOG-KEY. Su nombre externo sigue el patrón "(S151)S151/FILE/DESS{SIS}/{FEC} ON {PACK}". Complementa al LOG151 secuencial (450 bytes) con descriptivos adicionales. El close requiere `WKS-CIERRA-DESC` con FUNCION+LOGDESC1+LOGDESC2 para cerrar correctamente el descriptor.

**Fórmula/pseudocódigo:**
```
LOG151-COMP: DISK, RANDOM
  KEY = W77-LOG-KEY
  RECORD = 540 bytes
  TITLE = "(S151)S151/FILE/DESS{SIS}/{FEC} ON {PACK}"
CLOSE: MOVE FUNCION/LOGDESC1/LOGDESC2 TO WKS-CIERRA-DESC
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| LOG151-COMP | Log complementario de descriptivos; 540 bytes, RANDOM |
| W77-LOG-KEY | Llave de acceso random al LOG151-COMP |
| WKS-CIERRA-DESC | Estructura de cierre del descriptor del LOG complementario |
| DESS | Prefijo del archivo de descriptivos complementario |

**Excepciones:** Close sin WKS-CIERRA-DESC correcto puede dejar el LOG en estado inconsistente.
**Estado validación:** Verificado en WKS-TIT-LOG151-COMP líneas 465-473.

---

## RN-S151-347
**Identificador:** RN-S151-347
**Tipo:** Regulatorio
**Confianza:** ALTA
**Regulador:** SAT
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** Los campos RFC en REG-MOVIMIENTOS tienen longitudes asimétricas: RM-RFC-ORD X(13) (persona moral estándar) y RM-RFC-BENEF X(18) (incluye homoclave extendida o prefijo adicional). En el AHR, ambos campos son X(20). Esta asimetría requiere padding diferenciado al mapear de REG-MOVIMIENTOS a AHRST-REC: RFC-ORD requiere 7 bytes de padding, RFC-BENEF requiere 2 bytes.

**Fórmula/pseudocódigo:**
```
REG-MOVIMIENTOS → AHRST-REC (padding):
  RM-RFC-ORD(13)   → AHRST-RFC-ORD(20):   +7 bytes SPACES
  RM-RFC-BENEF(18) → AHRST-RFC-BENEF(20): +2 bytes SPACES
% En DASDL BD10: RFC-ORD X(13), RFC-BENEF X(18)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| RM-RFC-ORD | RFC del ordenante en REG-MOVIMIENTOS; X(13) |
| RM-RFC-BENEF | RFC del beneficiario en REG-MOVIMIENTOS; X(18) |
| AHRST-RFC-ORD | RFC del ordenante en AHR; X(20) — mayor longitud |
| padding | Relleno de spaces para igualar longitudes en el mapeo de campos |

**Excepciones:** Un RFC de persona física es X(13) con posición 10-13 libre — no confundir con RFC-BENEF(18).
**Estado validación:** Verificado en estructura REG-MOVIMIENTOS líneas 224-370 y AHR layout.

---

## RN-S151-348
**Identificador:** RN-S151-348
**Tipo:** Regulatorio — Ampliación
**Confianza:** ALTA
**Regulador:** SAT
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** NOM-BENEF fue ampliado de X(50) a X(120) por regulación SAT Anexo 20. En REG-MOVIMIENTOS el campo es RM-NOM-BENEF X(120). En AHRST-REC el campo AHRST-NOM-BENEF también es X(120). Esta amplitud máxima de nombre es mayor que la mayoría de bases de datos cliente que almacenan 60-80 caracteres — el campo puede truncarse al almacenar si el sistema destino no tiene capacidad equivalente.

**Fórmula/pseudocódigo:**
```
RM-NOM-BENEF X(120) ← ampliado desde X(50) por SAT
AHRST-NOM-BENEF X(120) = NOM-BENEF completo
% DASDL BD10: NOM-BENEF ALPHA(120)
% Riesgo: sistemas destino con < 120 chars truncan silenciosamente
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| NOM-BENEF | Nombre del beneficiario de la transferencia; X(120) post-SAT |
| truncamiento | Corte silencioso del nombre si el destino tiene menor capacidad |
| SAT Anexo 20 | Norma que amplió NOM-BENEF de 50 a 120 caracteres |

**Excepciones:** Nombre con caracteres especiales (acentos, ñ) puede corromper en sistemas ASCII estrictos.
**Estado validación:** Verificado en campo RM-NOM-BENEF línea 260 (aprox) del DATA DIVISION.

---

## RN-S151-349
**Identificador:** RN-S151-349
**Tipo:** Regulatorio — SPEI
**Confianza:** ALTA
**Regulador:** Banxico
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** RM-NIO X(16) en REG-MOVIMIENTOS transporta el Número de Identificación de Operación SPEI asignado por Banxico. Es alfanumérico de 16 caracteres — no numérico. En el AHR se mapea a AHRST-CVE-RASTREO X(30) que lo contiene más extensión. En BD10, el campo es NIO ALPHA(16). NIO vacío (espacios) indica movimiento no-SPEI.

**Fórmula/pseudocódigo:**
```
RM-NIO X(16) ← del registro de movimiento BD10
AHRST-CVE-RASTREO X(30) ← contiene NIO + info adicional
% NIO SPACES → movimiento no-SPEI (ventanilla, cajero, etc.)
% NIO ≠ SPACES → operación SPEI con rastreo Banxico
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| NIO | Número de Identificación de Operación SPEI; ALPHA(16) — alfanumérico |
| AHRST-CVE-RASTREO | Clave de rastreo en AHR; X(30) — NIO más posibles sufijos |
| SPEI | Sistema de Pagos Electrónicos Interbancarios Banxico |

**Excepciones:** NIO numérico con ceros iniciales debe preservarse como ALPHA — conversión numérica elimina ceros.
**Estado validación:** Verificado en RM-NIO en DATA DIVISION y NIO ALPHA(16) en DASDL BD10.

---

## RN-S151-350
**Identificador:** RN-S151-350
**Tipo:** Funcional — Mapeo de referencias por sistema origen
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** El paragraph `41100-VALIDA-REFERENCIAS-ALR` implementa lógica condicional por combinación RMC-SIST-ORIG + RMC-CVETRAN para mapear campos de referencia a las TEXT-LINEs del ALR. Sistema 15 con CVETRANs 1009/1019/3009/3036 usa REFNUM-16C en LINE-1. Sistema 264 con CVETRANs 1134-1137/2227/2266/2267 usa LEYENDA en LINE-2. CVETRAN 1117 usa REFNUM-16C en LINE-1 con REFERENCIA2 en LINE-2.

**Fórmula/pseudocódigo:**
```
IF SIST-ORIG=15 AND CVETRAN IN (1009,1019,3009,3036):
  LINE-1=REFNUM-16C, LINE-2=LEYENDA-35, LINE-3=LEYENDA-05
IF SIST-ORIG=264 AND CVETRAN IN (1134..1137,2227,2266,2267):
  LINE-2=LEYENDA, LINE-3=REF3, LINE-4=REF4, LINE-5=REF5
IF CVETRAN=1117:
  LINE-1=REFNUM-16C, LINE-2=REF2, LINE-3=REF3
IF CVETRAN IN (1133,1138,1139,1140,2226,2228,2229,2230):
  LINE-1..5=REF1..5
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| RMC-SIST-ORIG | Sistema origen del movimiento; 15=SPEI, 264=CECOBAN |
| RMC-CVETRAN | Clave de transacción; determina tipo de operación |
| REFNUM-16C | REFNUM formateado a 16 caracteres alfanuméricos |
| TEXT-LINE-1..5 | Líneas de texto del ALR — referencias e información adicional |

**Excepciones:** Combinación SIST-ORIG/CVETRAN sin case definido usa el ELSE por defecto — puede producir líneas vacías.
**Estado validación:** Verificado en 41100-VALIDA-REFERENCIAS-ALR líneas 14464-14509.

---

## RN-S151-351
**Identificador:** RN-S151-351
**Tipo:** Estructural — Multi-importe
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** REG-MOVIMIENTOS incluye `RM-TAB-CVES-IMPS OCCURS 5` con [RM-CVETRAN(04)+RM-INDLEY(02)+RM-ESQCON(04)+RM-IMPORTE(14V99)] por ocurrencia. Solo la primera ocurrencia (slot 1) es la transacción principal; slots 2-5 son importes adicionales (comisiones, impuestos, cargos secundarios). El campo RM-CVETRAN de cada slot determina el tipo de importe adicional.

**Fórmula/pseudocódigo:**
```
RM-TAB-CVES-IMPS(1): importe principal
  CVETRAN=tipo_principal, INDLEY=ley, IMPORTE=monto
RM-TAB-CVES-IMPS(2..5): importes adicionales
  CVETRAN=tipo_adicional (comisión/IVA/etc.)
  IMPORTE=monto_adicional
% W88-CVE-COMIS: CVETRAN 4000-4999 = comisión
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| RM-TAB-CVES-IMPS | Tabla de importes; OCCURS 5 — hasta 5 tipos de cargo por movimiento |
| RM-INDLEY | Indicador de ley aplicable al importe |
| RM-ESQCON | Esquema contable del importe |
| W88-CVE-COMIS | Condition 88 para CVETRANs 4000-4999 = comisión |

**Excepciones:** Slots 2-5 pueden estar en ceros si el movimiento solo tiene un importe — no iterar sobre ceros.
**Estado validación:** Verificado en DATA DIVISION REG-MOVIMIENTOS.

---

## RN-S151-352
**Identificador:** RN-S151-352
**Tipo:** Estructural — Leyendas
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** REG-MOVIMIENTOS contiene `RM-LEYENDAS OCCURS 5` con X(40) cada una, totalizando hasta 5 leyendas de 40 caracteres por movimiento. En el sort ARCH-CITICTD solo hay espacio para 1 leyenda con REDEFINES 35+5 bytes. El AHR tiene 5 TEXT-LINEs de X(35). El mismatch de longitud (40 vs 35) requiere truncamiento de 5 caracteres por leyenda al mapear a ALR/AHR.

**Fórmula/pseudocódigo:**
```
REG-MOVIMIENTOS: RM-LEYENDAS(1..5) X(40)
ARCH-CITICTD:    RMC-LEYENDA X(40) → REDEFINES 35+5
ALR TEXT-LINES:  ALRINT-TEXT-LINE-1..5 X(35)  [trunca 5 chars]
% 41100-VALIDA-REFERENCIAS-ALR: RMC-LEYENDA-35 → LINE-2
%                                RMC-LEYENDA-05 → LINE-3 (resto)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| RM-LEYENDAS | Arreglo de 5 leyendas de descripción; X(40) cada una |
| RMC-LEYENDA-35 | Primeros 35 chars de la leyenda para ALR TEXT-LINE |
| RMC-LEYENDA-05 | Últimos 5 chars de la leyenda — se envían en siguiente LINE |
| truncamiento | Pérdida de los últimos 5 chars al mapear 40→35 en ALR |

**Excepciones:** Leyendas con texto en posiciones 36-40 se cortan si solo se usa LEYENDA-35.
**Estado validación:** Verificado en SD SMOVTOS-CITICTD REDEFINES y 41100-VALIDA-REFERENCIAS-ALR.

---

## RN-S151-353
**Identificador:** RN-S151-353
**Tipo:** Estructural — Referencias
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** REG-MOVIMIENTOS contiene `RM-REFERENCIAS OCCURS 5` con X(35) cada una — referencias de la transacción. A diferencia de las leyendas (X(40)), las referencias ya tienen el tamaño exacto de los TEXT-LINEs del ALR (X(35)), por lo que no requieren truncamiento. Las referencias se usan directamente en los TEXT-LINEs según la lógica de 41100-VALIDA-REFERENCIAS-ALR.

**Fórmula/pseudocódigo:**
```
RM-REFERENCIAS(1..5) X(35)
ALR TEXT-LINE-1..5  X(35)
% Mapeo directo sin truncamiento:
MOVE RM-REFERENCIA1 TO ALRINT-TEXT-LINE-1 OF ARCH-ALR
% vs leyendas que requieren REDEFINES 35+5
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| RM-REFERENCIAS | Arreglo de 5 referencias; X(35) — tamaño exacto de TEXT-LINE |
| RMC-REFERENCIA1..5 | Referencias en el sort MOVTOS-CITICTD |
| referencia | Dato identificador de la transacción (número, clave, folio) |

**Excepciones:** Referencia vacía (SPACES) mapeada a TEXT-LINE produce línea en blanco en el ALR.
**Estado validación:** Verificado en DATA DIVISION y 41100-VALIDA-REFERENCIAS-ALR.

---

## RN-S151-354
**Identificador:** RN-S151-354
**Tipo:** Funcional — Selector de formato
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** RM-FORMATO X(02) en REG-MOVIMIENTOS es un campo selector del formato de salida del movimiento en los archivos Citi. Determina la compatibilidad del layout cuando el formato evolucionó (p.ej., pre-SAT vs post-SAT). Los registros con formato diferente al esperado por 41000-GRABA-ARCHIVOS-CITI pueden producir campos mal mapeados en el AHR SAT.

**Fórmula/pseudocódigo:**
```
RM-FORMATO X(02): selector de versión de layout
% Valores: dependen de la versión del sistema S151
% Determina si se populan campos SAT Anexo 20 extendidos
% en AHR (SELLO-DIGIT, FEC-DEV, CAUSA-DEV, etc.)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| RM-FORMATO | Selector del formato de salida del movimiento; X(02) |
| versión de layout | Estructura del registro Citi que varía por período regulatorio |
| campo SAT extendido | Campos AHR añadidos por SAT: SELLO-DIGIT, FEC-DEV, CAUSA-DEV |

**Excepciones:** FORMATO no reconocido puede saltar validaciones SAT, generando AHR con campos vacíos.
**Estado validación:** Campo identificado en DATA DIVISION REG-MOVIMIENTOS.

---

## RN-S151-355
**Identificador:** RN-S151-355
**Tipo:** Funcional — Saldo
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** RM-SALDO S15V99 en REG-MOVIMIENTOS contiene el saldo final del contrato tras aplicar el movimiento. En AHR se mapea a AHRST-LDGR-AMT (Ledger Amount) con su signo en AHRST-LDGR-AMT-SIGN. La validación `41210-VALIDA-SALDO-AHR` verifica el saldo antes de escribir. El saldo con signo negativo (S15V99 permite valores negativos) debe manejarse correctamente para no producir corrupción de datos en IBM.

**Fórmula/pseudocódigo:**
```
RM-SALDO S15V99 → AHRST-LDGR-AMT
PERFORM 41210-VALIDA-SALDO-AHR  % verifica signo y magnitud
MOVE RM-SALDO TO AHRST-LDGR-AMT OF ARCH-AHR
% S = signed; 15 digits + 2 decimals
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| RM-SALDO | Saldo final del contrato post-movimiento; S15V99 signed |
| AHRST-LDGR-AMT | Ledger Amount en AHR — equivalente al saldo final |
| 41210-VALIDA-SALDO-AHR | Paragraph de validación del saldo antes del WRITE AHR |

**Excepciones:** Saldo negativo en cuenta de captación puede ser válido (sobregiro autorizado) — no filtrar.
**Estado validación:** Verificado en líneas 14354-14356.

---

## RN-S151-356
**Identificador:** RN-S151-356
**Tipo:** Estructural — Densidad de bloque
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** Los tres archivos principales tienen distintas densidades de bloque: ARCH-ALR BLOCK CONTAINS 100 RECORDS (registros más compactos), ARCH-OCM BLOCK CONTAINS 50 RECORDS (registros de 1,300+ bytes), ARCH-AHR BLOCK CONTAINS 45 RECORDS (registros más grandes por campos SAT extendidos). AREASIZE 3000 es consistente en los tres. La densidad refleja el tamaño promedio de cada tipo de registro.

**Fórmula/pseudocódigo:**
```
ARCH-ALR: BLOCK=100, AREAS=1000, AREASIZE=3000  % ~347 bytes/reg
ARCH-OCM: BLOCK=50,  AREAS=1000, AREASIZE=3000  % ~1,300 bytes/reg
ARCH-AHR: BLOCK=45,  AREAS=1000, AREASIZE=3000  % ~1,368 bytes/reg
% AHR más grande por SELLO-DIGIT(400)+CAUSA-DEV(120)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| BLOCK CONTAINS | Número de registros lógicos por bloque físico del archivo |
| AREAS | Número de áreas de 3000 bytes asignadas al archivo |
| AREASIZE | Tamaño en bytes de cada área del archivo |

**Excepciones:** Cambiar BLOCK sin ajustar receptor en IBM produce errores de lectura en el FTP downstream.
**Estado validación:** Verificado en FD declarations líneas 764, 825, 992.

---

## RN-S151-357
**Identificador:** RN-S151-357
**Tipo:** Operativo — Naming
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** Los títulos de los archivos de interfaz IBM siguen la convención "SNNN{ALR/AHR/OCM}/CO/AAMMDD" donde NNN=sistema (500, 701, etc.), /CO/ es el directorio de comunicaciones y AAMMDD es la fecha de proceso. El WFL P940 en S006 ejecuta el FTP. El proceso P940 se invoca con `CALL SYSTEM WFL USING WKS-TIT-WFL` después de generar cada tipo de archivo.

**Fórmula/pseudocódigo:**
```
WKS-TIT-ARCH-ALR = "SNNN{ALR}/CO/AAMMDD"
CALL SYSTEM WFL USING "(S006)S006/WFL/P940/01MTP001 ON XFER"
  SISTEMA = W77-SISTEMA-PARAMETRO
  ARCH = "ALR"/"AHR"/"ACC"
  FEC  = W77-FECHA-PROCESO
  CSI  = WKS-NUMCSI
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| P940 | Programa WFL de FTP que transfiere archivos a IBM |
| WKS-TIT-WFL | Título del WFL job para invocar P940 |
| /CO/ | Directorio de comunicaciones en DMSII — área de intercambio con IBM |
| XFER | Pack de transferencia en la MCP Unisys |

**Excepciones:** Si P940 falla (red, credenciales), los archivos quedan en /CO/ sin transferir — P151 no detecta este error.
**Estado validación:** Verificado en líneas 12605-12612.

---

## RN-S151-358
**Identificador:** RN-S151-358
**Tipo:** Estructural — Movimientos vivos
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** MOVTOS-VIVOSCTD y su sort file SMOVTOS-VIVOSCTD contienen "movimientos vivos" — los activos del día que aún no han sido enviados a IBM. Tienen campos adicionales RMV-HR-REAL(06) (hora real de captura) y RMV-IND-SIS(02) (indicador de sistema) respecto al sort estándar. La distinción entre MOVIMIENTOSCTD (todos) y MOVTOS-VIVOSCTD (pendientes) es crítica para no reenviar movimientos ya transmitidos.

**Fórmula/pseudocódigo:**
```
MOVIMIENTOSCTD: todos los movimientos del día
MOVTOS-VIVOSCTD: solo los pendientes de envío a Citi
  RMV-HR-REAL(06) = hora real de captura ≠ HOROPER
  RMV-IND-SIS(02) = indicador si ya enviado
% PERFORM 51000-ESCOGE-MOVS: lee MOVTOS-VIVOSCTD
% PERFORM 71000-GRABA-ARCHIVO-CITI: genera salida para vivos
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| MOVTOS-VIVOSCTD | Sort de movimientos vivos pendientes de envío a IBM |
| RMV-HR-REAL | Hora real de captura del movimiento (vs HOROPER = hora de operación) |
| RMV-IND-SIS | Indicador de sistema para filtrado de movimientos ya enviados |

**Excepciones:** Si HR-REAL > HOROPER, el movimiento fue capturado fuera de horario — puede afectar el sort por hora.
**Estado validación:** Verificado en SD SMOVTOS-VIVOSCTD y PERFORM 51000/71000.

---

## RN-S151-359
**Identificador:** RN-S151-359
**Tipo:** Funcional — Comisiones
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** La condición de nivel 88 `W88-CVE-COMIS` se activa para CVETRANs en rango 4000-4999. Este rango identifica comisiones bancarias. Los movimientos de comisión reciben tratamiento diferenciado en la generación de ALR/AHR (pueden ir a un slot distinto o con lógica de signo inversa). Las comisiones con CVETRAN 730-746 reciben limpieza especial del campo importe antes del procesamiento.

**Fórmula/pseudocódigo:**
```
88 W88-CVE-COMIS VALUE 4000 THRU 4999.
IF RMC-CVETRAN > 730 AND RMC-CVETRAN < 747:
  MOVE SPACES TO WKS-DATO-IMPORTE
  MOVE RMC-IMPORTE TO WKS-DATO-IMP-EDIT
  MOVE ZEROS TO RMC-IMPORTE  % limpia para procesamiento
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| W88-CVE-COMIS | Condition 88 para CVETRANs 4000-4999 = comisión bancaria |
| CVETRAN 730-746 | Rango de transacciones con importe que requiere limpieza previa |
| WKS-DATO-IMP-EDIT | Campo de trabajo para importe editado (formato display) |

**Excepciones:** Zeroing del importe en ciertas comisiones significa que no se reporta el monto al archivo Citi.
**Estado validación:** Verificado en líneas 14250-14253.

---

## RN-S151-360
**Identificador:** RN-S151-360
**Tipo:** Regulatorio
**Confianza:** ALTA
**Regulador:** CNBV
**Capacidad bancaria:** 6.7.1 Financial Reconciliation

**Descripción:** RM-IND-CONTA X(02) en REG-MOVIMIENTOS indica si el movimiento genera asiento contable en BD11. Valor distinto de cero activa la contabilización. En AHR el campo equivalente es AHRST-... no presente explícitamente pero la selección de movimientos para AHR (IND-SIS=1 OR 2) implícitamente incluye los contables. En el sort WKS-SORT-REG, el campo INDCTACON-SUBC corresponde a IND-CONTA.

**Fórmula/pseudocódigo:**
```
RM-IND-CONTA X(02):
  = 0 → no genera asiento contable en BD11
  ≠ 0 → genera asiento contable (B72POSCONTA actualizado)
WKS-SORT-INDCTACON-SUBC = RM-IND-CONTA en sort
% Movimientos IND-CONTA=0 aún pueden ir a ALR/AHR (movimientos de caja)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| RM-IND-CONTA | Indicador de contabilización del movimiento; X(02) |
| asiento contable | Registro en BD11 B72POSCONTA de cargo/abono contable |
| INDCTACON-SUBC | Copia de IND-CONTA en el registro de sort |
| contabilización | Proceso de registro contable del movimiento en el GL |

**Excepciones:** Movimientos no contables (IND-CONTA=0) en ALR pueden generar diferencias de cuadre con el libro mayor.
**Estado validación:** Verificado en DATA DIVISION RM-IND-CONTA y WKS-SORT-REG campo INDCTACON-SUBC.