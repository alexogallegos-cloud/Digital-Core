# Reglas de Negocio — P158 (Generador de Estado de Cuenta S500→S050)
> **Capacidad bancaria:** T.3.4 Analytics/Reporting · Generación de estado de cuenta captación
> **Programa fuente:** COBOL_P158.txt · Autor: ING FRANCISCO JAVIER HERNANDEZ GONZALEZ
> **Frecuencia:** cierre-diario
> **Sistemas downstream:** S050 (clientes) · BNE · TESOFE S701 · REPDEVOL · LOG151/LOG151-COMP
> **Rango:** RN-S151-361 a RN-S151-390 (30 reglas)
> **Actualizado:** 2026-07-16

---

## RN-S151-361
**Identificador:** RN-S151-361
**Tipo:** Estructural
**Confianza:** ALTA
**Regulador:** CNBV / CONDUSEF
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** P158 genera el archivo de movimientos por contrato (MOVSXCONT) para productos S500 (captación) y S066 (cuentas), alimentando S050 para la generación de estados de cuenta. Opera con el parámetro W77-SIST-PARAM que determina el sistema activo. P158 solo corre para sistemas 500, 408, 84, 87, 407, 404 y 017 — cualquier otro sistema genera mensaje de error y STOP RUN.

**Fórmula/pseudocódigo:**
```
ENTRY: W77-SIST-PARAM
IF SIST-PARAM NOT IN (500,408,84,87,407,404,017):
  MOVE "EL P158 NO CORRE PARA ESTE SISTEMA" TO TEXTO-LJ
  STOP RUN
IF SIST-PARAM = 407 OR 408:
  MOVE "408" TO variables (alias de 500)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| W77-SIST-PARAM | Parámetro de entrada del sistema a procesar |
| S050 | Sistema de Clientes — receptor del MOVSXCONT para estado de cuenta |
| S500 | Sistema de Captación — fuente de movimientos del día |
| estado de cuenta | Resumen mensual de movimientos enviado al cliente; obligatorio CNBV |

**Excepciones:** Sistema 407 es alias de 408, que a su vez es alias de 500 en la lógica de catálogos.
**Estado validación:** Verificado en PROCEDURE DIVISION líneas 9195-9373.

---

## RN-S151-362
**Identificador:** RN-S151-362
**Tipo:** Estructural — Archivos de salida
**Confianza:** ALTA
**Regulador:** CNBV
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** P158 genera hasta 9 archivos de salida primarios. Los primeros 6 tienen ancho X(840) y van a S050: MOVSXCONT (principal), MOVSXCONT-500, MOVSXCONTCHEQ, MOVSXCONTCD01, MOVSXCONTCD66, MOVSXCONTINVI. Los últimos 3 tienen ancho reducido X(581): MOVSXCONTESOF (S502 impuestos), MOVSXCONTESOF2 (S701 pagos), MOVSXCONT-087. Adicionalmente: REPDEVOL(PRINTER), TOTAL(PRINTER), LOG151(DISK), LOG151-COMP(DISK), MOVBONIFICA(PRINTER).

**Fórmula/pseudocódigo:**
```
Archivos X(840) → S050:
  MOVSXCONT, MOVSXCONT-500, MOVSXCONTCHEQ
  MOVSXCONTCD01, MOVSXCONTCD66, MOVSXCONTINVI
Archivos X(581) → sistemas especializados:
  MOVSXCONTESOF  → "(S502)S{SIS}/FILE/S502/.../MOV{PROD}/{FEC} ON IMPUESTOS"
  MOVSXCONTESOF2 → "(S701)S{SIS}/FILE/S701/.../MOV{PROD}/{FEC} ON PAGOS"
  MOVSXCONT-087  → "{SIS}/FILE/S050/.../S151MOV{PROD}/{FEC}"
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| MOVSXCONT | Movimientos por contrato principal para S050 — estado de cuenta |
| MOVSXCONTESOF | Archivo S502 para impuestos; X(581) — ancho reducido |
| MOVSXCONTESOF2 | Archivo S701 para pagos; X(581) — TESOFE |
| S502 | Sistema de Impuestos que consume MOVSXCONTESOF |

**Excepciones:** MOVSXCONT-087 usa "/S151MOV" en lugar de "/MOV" — path diferente al resto.
**Estado validación:** Verificado en FILE-CONTROL y WKS-TIT-MOVSXCONT* líneas 509-639.

---

## RN-S151-363
**Identificador:** RN-S151-363
**Tipo:** Funcional — Clave de ordenamiento
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** El archivo de sort ARCH-ORD tiene clave de 9 campos: KEY-SUBNODO(04)+KEY-SUCPROM(04)+KEY-TIPO-PROD(02)+KEY-CONTRATO(16)+KEY-PROD(04)+KEY-INSTRUM(02)+KEY-SUCOPER(04)+KEY-CAJAOPER(02)+KEY-AUTS151(08). Esta clave garantiza que los movimientos del mismo contrato lleguen juntos y en secuencia de cajero+autorización para la generación del estado de cuenta.

**Fórmula/pseudocódigo:**
```
ARCH-ORD sort key (9 campos):
  SUBNODO(4) + SUCPROM(4) + TIPO-PROD(2) + CONTRATO(16)
  + PROD(4) + INSTRUM(2) + SUCOPER(4) + CAJAOPER(2)
  + AUTS151(8)
CUERPO X(739) post-Y2K [vs menor pre-CRONOS2K]
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| KEY-SUBNODO | Nodo de distribución; primer campo de sort — agrupa por región |
| KEY-CONTRATO | Contrato; 16 dígitos — agrupa movimientos del mismo cliente |
| KEY-AUTS151 | Autorización S151; último campo — orden dentro del contrato |
| CUERPO | Datos del movimiento; X(739) post-Y2K |

**Excepciones:** Movimientos del mismo contrato en distintos SUBNODOS quedan en archivos de salida separados.
**Estado validación:** Verificado en ARCH-ORD sort key estructura y WKS-SORT-REG.

---

## RN-S151-364
**Identificador:** RN-S151-364
**Tipo:** Funcional — Condicional S500
**Confianza:** ALTA
**Regulador:** CNBV
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** El archivo MOVSXCONT-500 solo se genera cuando `W77-SIST-PARAM = 500`. Para otros sistemas parametrizados (408, 84, 87, etc.), MOVSXCONT-500 no recibe escrituras. Esto diferencia la salida de captación clásica (S500) de los demás productos. El título usa WKS-TIT-MOVSXCONT-500 con estructura S{SIS}/FILE/S050/{NO}/{ND}/MOV{PROD}/{FEC}.

**Fórmula/pseudocódigo:**
```
IF W77-SIST-PARAM = 500:
  WRITE MOVSXCONT-500
ELSE:
  % MOVSXCONT-500 no se genera
% Título: "S{SIS}/FILE/S050/{NODO-ORIGEN}/{NODO-DESTINO}/MOV{PROD}/{FEC}"
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| MOVSXCONT-500 | Archivo de movimientos exclusivo para captación S500 |
| WKS-NODO-ORIGEN-500 | Nodo de distribución origen para rutas S500 |
| WKS-NODO-DESTINO-500 | Nodo de distribución destino para rutas S500 |

**Excepciones:** Sistema 408 (alias de 500) no genera MOVSXCONT-500 a pesar de ser captación — verifica lógica con negocio.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONT-500 línea 509 y condición SIST-PARAM.

---

## RN-S151-365
**Identificador:** RN-S151-365
**Tipo:** Operativo — Log principal
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** LOG151 es un archivo de disco secuencial con registros de 450 bytes que registra cada movimiento procesado. Su nombre externo sigue el patrón "(S151)S151/FILE/MOVS{SIS}/{FEC} ON {PACK}" donde PACK es el nombre del pack de discos activo del día. El pack se lee de BD99 campo NOMPACMOV. El LOG151 es el audit trail principal del procesamiento de P158.

**Fórmula/pseudocódigo:**
```
LOG151: DISK, secuencial
  RECORD = 450 bytes (REG-LOG151 X(450))
  TITLE = "(S151)S151/FILE/MOVS{SIS}/{FEC} ON {PACK}"
  % PACK = WKS-B01-NOMPACMOV ← BD99.B01SISDIA
  % FEC = WKS-151-FECPROC (8 dígitos CCAAMMDD)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| LOG151 | Log secuencial de 450 bytes/registro — audit trail de P158 |
| NOMPACMOV | Nombre del pack del archivo de movimientos; leído de BD99 |
| WKS-PACK-LOG | Variable de trabajo con el nombre del pack activo |
| audit trail | Registro cronológico de cada movimiento procesado |

**Excepciones:** Si NOMPACMOV es SPACES en BD99, el LOG151 se crea en pack default — puede ser incorrecto.
**Estado validación:** Verificado en WKS-TIT-LOG151 líneas 452-460.

---

## RN-S151-366
**Identificador:** RN-S151-366
**Tipo:** Operativo — Log complementario
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** LOG151-COMP es un archivo de disco en acceso RANDOM (540 bytes/registro) accedido por clave. Su nombre externo sigue "(S151)S151/FILE/DESS{SIS}/{FEC} ON {PACK}" — el prefijo DESS lo diferencia de MOVS del LOG principal. Almacena descriptivos adicionales del movimiento (datos que no caben en los 450 bytes del LOG principal). La clave de acceso RANDOM permite consultar cualquier registro directamente.

**Fórmula/pseudocódigo:**
```
LOG151-COMP: DISK, RANDOM
  RECORD = 540 bytes
  TITLE = "(S151)S151/FILE/DESS{SIS}/{FEC} ON {PACK}"
  % DESS = Descriptivos Adicionales
  % Acceso: READ LOG151-COMP KEY = W77-LOG-KEY
  % W77-LOG-KEY apunta al registro complementario del movimiento
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| LOG151-COMP | Log complementario RANDOM de 540 bytes — descriptivos adicionales |
| DESS | Prefijo de archivo: Descriptivos del Sistema S151 |
| W77-LOG-KEY | Clave de acceso RANDOM al registro complementario |
| descriptivo | Texto adicional del movimiento que no cabe en LOG151 principal |

**Excepciones:** Acceso RANDOM con clave inválida en LOG151-COMP genera error de I/O — debe validarse W77-LOG-KEY antes.
**Estado validación:** Verificado en WKS-TIT-LOG151-COMP líneas 465-473 y FD LOG151-COMP.

---

## RN-S151-367
**Identificador:** RN-S151-367
**Tipo:** Funcional — Devoluciones
**Confianza:** ALTA
**Regulador:** CONDUSEF
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** REPDEVOL es un archivo PRINTER que genera el reporte de devoluciones/reversiones del día. Es un archivo condicional — solo se genera cuando existen movimientos de devolución procesados. El reporte tiene ancho X(132) (formato de impresora estándar). CONDUSEF requiere disponibilidad del historial de devoluciones para atención de quejas.

**Fórmula/pseudocódigo:**
```
REPDEVOL: PRINTER, X(132)
  SELECT REPDEVOL ASSIGN TO PRINTER
  % Generación condicional:
  IF hay movimientos de devolución:
    OPEN OUTPUT REPDEVOL
    WRITE REG-REPDEVOL
    CLOSE REPDEVOL
  % Sin devoluciones → REPDEVOL no se abre
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| REPDEVOL | Reporte de devoluciones del día — generación condicional |
| devolución | Reversión de un movimiento aplicado previamente |
| PRINTER | Tipo de archivo de salida para reportes en MCP Unisys |

**Excepciones:** REPDEVOL abierto pero sin registros escritos produce archivo vacío — no error.
**Estado validación:** Verificado en FILE-CONTROL línea 50 y FD REPDEVOL línea 128.

---

## RN-S151-368
**Identificador:** RN-S151-368
**Tipo:** Funcional — Bonificaciones
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** MOVBONIFICA es un archivo PRINTER que genera el reporte de bonificaciones aplicadas. Es separado del estado de cuenta principal y del REPDEVOL. Las bonificaciones son ajustes a favor del cliente (reversión de comisiones, compensaciones). Al igual que REPDEVOL, es un archivo condicional que solo se genera cuando existen bonificaciones en el día.

**Fórmula/pseudocódigo:**
```
MOVBONIFICA: PRINTER
  % Generación condicional:
  IF hay bonificaciones procesadas:
    OPEN OUTPUT MOVBONIFICA
    WRITE REG-MOVBONIFICA
    CLOSE MOVBONIFICA
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| MOVBONIFICA | Reporte de bonificaciones — generación condicional |
| bonificación | Ajuste a favor del cliente aplicado en el período |
| ajuste | Movimiento de corrección sin ser devolución estricta |

**Excepciones:** Bonificaciones incluidas en el MOVSXCONT principal pero reportadas por separado en MOVBONIFICA — posible doble conteo al reconciliar.
**Estado validación:** Verificado en FILE-CONTROL (SELECT MOVBONIFICA ASSIGN TO PRINTER).

---

## RN-S151-369
**Identificador:** RN-S151-369
**Tipo:** Operativo — Reporte de totales
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** TOTAL es un archivo PRINTER que genera el resumen de totales del proceso diario: número e importe de cargos y abonos por tipo de archivo (ALR, AHR, ACC). Se genera solo cuando `W77-SIST-PARAM = 500 AND WKS-NUMCSI = 10`. WKS-NUMCSI=10 identifica el CSI (Centro de Servicios Integrados) principal de la captación. El TOTAL incluye WKS-TOTALES-ARCHIVO con contadores WKS-NUM-CARCITDT/ABOCITDT.

**Fórmula/pseudocódigo:**
```
IF SIST-PARAM=500 AND NUMCSI=10:
  OPEN OUTPUT TOTALES
  WRITE REG-TOTALES FROM WSR-ENCAB-1 AFTER PAGE
  WRITE REG-TOTALES FROM WSR-ENCAB-2
  WRITE REG-TOTALES FROM WSR-ENCAB-3
  % Por cada archivo ALR/AHR/ACC:
  WRITE WKS-TOTALES-ARCHIVO AFTER 2
CLOSE TOTALES WITH SAVE
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WKS-NUMCSI | Número del CSI activo; 10 = CSI principal de captación |
| WKS-TOTALES-ARCHIVO | Estructura de totales por archivo (cargos+abonos+importes) |
| WKS-NUM-CARCITDT | Contador de cargos enviados a Citi en el día |
| WKS-IMP-CARCITDTT | Importe total de abonos Citi (variante acumulada) |

**Excepciones:** NUMCSI ≠ 10 no genera TOTAL — procesos de CSIs secundarios no tienen reporte consolidado.
**Estado validación:** Verificado en líneas 12590-12638.

---

## RN-S151-370
**Identificador:** RN-S151-370
**Tipo:** Estructural — Y2K
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** El cuerpo del registro de sort ARCH-ORD es X(739) post-CRONOS2K, expandido desde un tamaño menor pre-Y2K. Los campos de fecha en WKS-SORT-REG son de 8 dígitos (FECCONT, FECHVAL, FECOPER) vs 6 dígitos pre-Y2K. Los comentarios `*INICIA/TERMINA CODIGO DE RENOVACION CRONOS 2000` delimitan los cambios. El campo FECDEV(08) en WKS-SORT-REG es nuevo — no existía pre-Y2K.

**Fórmula/pseudocódigo:**
```
% Pre-CRONOS2K:
*  WKS-SORT-FECCONT PIC 9(06) COMP  % AAMMDD
*  WKS-SORT-FECHVAL PIC 9(06) COMP  % AAMMDD
% Post-CRONOS2K:
   WKS-SORT-FECCONT PIC 9(08) COMP  % CCAAMMDD
   WKS-SORT-FECHVAL PIC 9(08) COMP  % CCAAMMDD
   WKS-SORT-FECDEV  PIC 9(08) COMP  % nuevo — devolución
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| CRONOS2K | Proyecto Y2K de S151 — amplió fechas de 6 a 8 dígitos |
| FECCONT | Fecha contable; 8 dígitos CCAAMMDD post-Y2K |
| FECDEV | Fecha de devolución; campo nuevo en Y2K |
| CUERPO X(739) | Datos del movimiento en el sort — expandido por Y2K |

**Excepciones:** Interfaz con sistemas que esperan 6 dígitos de fecha producirá errores de parsing post-Y2K.
**Estado validación:** Verificado en WKS-SORT-REG líneas 694-732.

---

## RN-S151-371
**Identificador:** RN-S151-371
**Tipo:** Funcional — Ordenamiento
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** El sort de 9 campos en ARCH-ORD garantiza que todos los movimientos del mismo contrato (KEY-CONTRATO=16 dígitos) lleguen consecutivos al procesamiento de escritura de MOVSXCONT. El primer campo KEY-SUBNODO segrega por nodo de red antes del contrato, permitiendo que múltiples procesos paralelos (uno por nodo) generen MOVSXCONT sin colisión. KEY-AUTS151 como último campo garantiza orden cronológico dentro del contrato.

**Fórmula/pseudocódigo:**
```
Sort primario:  SUBNODO → SUCPROM → TIPO-PROD → CONTRATO
Sort secundario: PROD → INSTRUM → SUCOPER → CAJAOPER → AUTS151
% Resultado: movimientos del mismo contrato, ordenados por cajero y hora
% Permite detección de ruptura de contrato (LLAVE-ACTUAL ≠ LLAVE-ANTERIOR)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WKS-LLAVE-ACTUAL | Llave del registro en proceso — NOD+SUBNODO+SUC+TIPO+CTA+PROD+INST |
| WKS-LLAVE-ANTERIOR | Llave del registro previo — detecta cambio de contrato |
| ruptura de contrato | Cambio de KEY-CONTRATO entre registros consecutivos |
| nodo paralelo | Instancia paralela de P158 procesando un nodo diferente |

**Excepciones:** Movimientos del mismo contrato en diferentes SUCPROM pueden quedar separados en el sort si SUCPROM varía.
**Estado validación:** Verificado en WKS-LLAVE-ACTUAL/ANTERIOR estructura líneas 749-777.

---

## RN-S151-372
**Identificador:** RN-S151-372
**Tipo:** Estructural — Campos de trabajo del sort
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-SORT-REG contiene campos adicionales para el procesamiento: CVECAUSA(04) para la causa contable, FECDEV(08) para fecha de devolución, BCO-ORI(05) y BCO-DES(05) para operaciones interbancarias, CVES-IMP OCCURS 5 [CVE+INDLEY+IMP] para multi-importe. También incluye campos de sub-contrato: IND-SUBC, PRO-SUBC, INST-SUBC, MON-SUBC, CONT-SUBC, CTAMDA-SUBC para cuentas asociadas.

**Fórmula/pseudocódigo:**
```
WKS-SORT-REG campos clave:
  CVECAUSA(4): causa contable para reconciliación GL
  FECDEV(8):   fecha devolución SPEI
  BCO-ORI(5)/BCO-DES(5): bancos en ops interbancarias
  CVES-IMP OCCURS 5: tabla de importes (CVE+INDLEY+IMP)
  *-SUBC: campos del sub-contrato vinculado (MDA, etc.)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WKS-SORT-CVECAUSA | Clave de causa contable; 4 dígitos — linking con BD11 B72POSCONTA |
| WKS-SORT-BCO-ORI/DES | Bancos origen y destino de operaciones interbancarias |
| CONT-SUBC | Contrato sub-cuenta (ej. cuenta MDA asociada al contrato principal) |
| sub-contrato | Cuenta vinculada al contrato principal (MDA, cuenta de cargo) |

**Excepciones:** Campos SUBC vacíos indican movimiento sin sub-contrato — no intentar lookup con CONT-SUBC=ZEROS.
**Estado validación:** Verificado en WKS-SORT-REG líneas 691-744.

---

## RN-S151-373
**Identificador:** RN-S151-373
**Tipo:** Funcional — Productos S087
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-SORT-REF-S087 REDEFINES WKS-SORT-REFERENCIA como PM(02)+NUMERO(14). Esta estructura específica para productos S087 particiona el campo de referencia de 16 dígitos en prefijo de 2 (PM = Producto Medio) y número de 14. El archivo de salida MOVSXCONT-087 tiene ruta especial con "/S151MOV" en lugar de "/MOV", diferenciando la distribución de productos S087 de los demás.

**Fórmula/pseudocódigo:**
```
WKS-SORT-REFERENCIA PIC 9(16) COMP
  REDEFINES → WKS-SORT-REF-S087:
    WKS-SORT-REF-PM(2):     Prefijo Producto Medio
    WKS-SORT-REF-NUMERO(14): Número de referencia S087
% MOVSXCONT-087 title: "{SIS}/FILE/S050/.../S151MOV{PROD}/{FEC}"
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| S087 | Sistema/producto 087 — tipo especial de cuenta con referencia partida |
| WKS-SORT-REF-PM | Prefijo del Producto Medio en la referencia S087; 2 dígitos |
| WKS-SORT-REF-NUMERO | Número principal de referencia S087; 14 dígitos |
| MOVSXCONT-087 | Archivo de salida para productos S087 — ruta distinta |

**Excepciones:** Referencia S087 con PM=00 puede confundirse con referencia vacía — no filtrar PM=00.
**Estado validación:** Verificado en WKS-SORT-REG líneas 708-710 y WKS-TIT-MOVSXCONT-S087.

---

## RN-S151-374
**Identificador:** RN-S151-374
**Tipo:** Estructural — Hora
**Confianza:** MEDIA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-SORT-HORA(06) REDEFINES como HH(02)+MM(02)+DD(02). El nombre del tercer subcampo ("DD") es potencialmente un error de documentación en el código fuente — en un campo de hora, el tercer componente debería ser "SS" (segundos). Este mislabeling puede causar confusión al migrar: el tercer campo probablemente contiene segundos, no días.

**Fórmula/pseudocódigo:**
```
WKS-SORT-HORA PIC 9(06) COMP
  WKS-SORT-HORA-HH PIC 9(02): horas (00-23)
  WKS-SORT-HORA-MM PIC 9(02): minutos (00-59)
  WKS-SORT-HORA-DD PIC 9(02): PROBABLEMENTE SEGUNDOS (00-59)
% Formato real: HHMMSS (no HHMMDD)
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WKS-SORT-HORA | Campo de hora en formato 6-dígitos HHMMSS |
| WKS-SORT-HORA-DD | Subcampo mislabeled — probablemente son segundos, no días |
| mislabeling | Error de nomenclatura en código fuente que puede inducir a error |

**Excepciones:** Al migrar, mapear WKS-SORT-HORA-DD como "segundos" no como "días" — validar con muestra de datos.
**Estado validación:** Identificado en WKS-SORT-REG líneas 715-718 — requiere validación con datos reales.

---

## RN-S151-375
**Identificador:** RN-S151-375
**Tipo:** Funcional — Fechas EDOCTA
**Confianza:** ALTA
**Regulador:** CNBV / CONDUSEF
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** Las variables A2K-BRIDGE-EDOCTA-* son puentes de fecha en formato CCAAMMDD para la generación del estado de cuenta (EDOCTA): FECINI (fecha inicio período), FECFIN (fecha fin período), HDR-FEC-BASE (fecha base del encabezado), HDR-FEC-PROC (fecha de proceso del encabezado), INS-FEC-INI (fecha inicio del instrumento), MOV-FEC-FIN (fecha fin de movimientos), MOV-FECPROC (fecha de proceso de movimientos).

**Fórmula/pseudocódigo:**
```
A2K-BRIDGE variables (todas PIC 9(8) CCAAMMDD):
  EDOCTA-MOV-FECINI → inicio período del estado de cuenta
  EDOCTA-MOV-FECFIN → fin período del estado de cuenta
  EDOCTA-HDR-FEC-BASE → fecha base del encabezado EDO
  EDOCTA-HDR-FEC-PROC → fecha de procesamiento del encabezado
  EDOCTA-MOV-FECPROC  → fecha de proceso de movimientos
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| A2K-BRIDGE | Prefijo de variables puente post-Y2K para EDOCTA |
| EDOCTA | Estado de cuenta — output final de S050 al cliente |
| FECINI/FECFIN | Fechas de inicio y fin del período del estado de cuenta |
| período | Intervalo mensual cubierto por el estado de cuenta |

**Excepciones:** FECINI > FECFIN produce estado de cuenta con período invertido — validar orden cronológico.
**Estado validación:** Verificado en Working Storage líneas 408-414.

---

## RN-S151-376
**Identificador:** RN-S151-376
**Tipo:** Funcional — Rutas de distribución
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** Los archivos de salida MOVSXCONT incluyen NODO-ORIGEN y NODO-DESTINO en su nombre externo, permitiendo enrutamiento de red. WKS-NODO-ORIGEN y WKS-NODO-DESTINO (2 dígitos cada uno) identifican los nodos de la red MCP Unisys entre los que se distribuye el archivo. Esto implica que múltiples instancias de P158 pueden correr en paralelo, cada una con un par de nodos distinto, generando diferentes particiones del MOVSXCONT.

**Fórmula/pseudocódigo:**
```
WKS-TIT-MOVSXCONT:
  "S{SIS}/FILE/S050/{NODO-ORIGEN}/{NODO-DESTINO}/MOV{PROD}/{FEC}"
% NODO-ORIGEN(02): nodo fuente del proceso
% NODO-DESTINO(02): nodo receptor en S050
% Ej: "S500/FILE/S050/01/02/MOV0660/261014."
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| NODO-ORIGEN | Nodo MCP origen del proceso P158; 2 dígitos |
| NODO-DESTINO | Nodo MCP destino del archivo en S050; 2 dígitos |
| partición | Subconjunto de movimientos asignados a un nodo específico |
| S050 | Sistema de Clientes que consume el MOVSXCONT para estado de cuenta |

**Excepciones:** Nodo incorrecto en el nombre externo envía el archivo al nodo equivocado — S050 no lo encontrará.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONT líneas 544-556.

---

## RN-S151-377
**Identificador:** RN-S151-377
**Tipo:** Funcional — Integración S502 (impuestos)
**Confianza:** ALTA
**Regulador:** SAT
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** MOVSXCONTESOF se envía al sistema S502 con título "(S502)S{SIS}/FILE/S502/{NO}/{ND}/MOV{PROD}/{FEC} ON IMPUESTOS". El sufijo "ON IMPUESTOS" en el título identifica el pack de destino. S502 procesa los datos del estado de cuenta para generación de comprobantes fiscales digitales (CFDI) de movimientos bancarios con relevancia fiscal (ISR/IVA). El archivo tiene ancho reducido X(581) vs X(840) del principal.

**Fórmula/pseudocódigo:**
```
WKS-TIT-MOVSXCONTESOF:
  "(S502)S{SIS}/FILE/S502/{NO}/{ND}/MOV{PROD}/{FEC} ON IMPUESTOS"
  RECORD = X(581)  % ancho reducido
% S502: sistema de impuestos — genera CFDI de movimientos fiscales
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| MOVSXCONTESOF | Archivo para S502 de impuestos; X(581) |
| S502 | Sistema de Impuestos de Banamex — genera CFDI |
| CFDI | Comprobante Fiscal Digital por Internet — requerido por SAT |
| ON IMPUESTOS | Pack de destino del archivo en el sistema de impuestos |

**Excepciones:** Registro X(581) trunca campos del X(840) principal — S502 solo recibe subconjunto de campos.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONTESOF líneas 562-575.

---

## RN-S151-378
**Identificador:** RN-S151-378
**Tipo:** Funcional — Integración S701 (TESOFE/pagos)
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** MOVSXCONTESOF2 se envía al sistema S701 (TESOFE — Tesorería de la Federación) con título "(S701)S{SIS}/FILE/S701/{NO}/{ND}/MOV{PROD}/{FEC} ON PAGOS". S701 procesa pagos gubernamentales (impuestos SAT, IMSS, INFONAVIT) realizados a través de Banamex. El sufijo "ON PAGOS" identifica el pack. También X(581).

**Fórmula/pseudocódigo:**
```
WKS-TIT-MOVSXCONTESOF2:
  "(S701)S{SIS}/FILE/S701/{NO}/{ND}/MOV{PROD}/{FEC} ON PAGOS"
  RECORD = X(581)
% S701: sistema TESOFE — pagos a la Tesorería de la Federación
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| MOVSXCONTESOF2 | Archivo para S701 TESOFE; X(581) |
| S701 | Sistema TESOFE — pagos gubernamentales de Banamex |
| TESOFE | Tesorería de la Federación — receptor final de pagos fiscales |
| ON PAGOS | Pack de destino del archivo de pagos |

**Excepciones:** TESOFE tiene ventanas de recepción — envío fuera de ventana puede causar rechazo del archivo.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONTESOF2 líneas 597-610.

---

## RN-S151-379
**Identificador:** RN-S151-379
**Tipo:** Funcional — Ruta especial S087
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** MOVSXCONT-087 usa el path "{SIS}/FILE/S050/.../S151MOV{PROD}/{FEC}" que incluye el prefijo "S151MOV" en lugar del "/MOV" estándar. Esta distinción en el nombre del archivo permite que S050 identifique y procese los movimientos de productos S087 con lógica separada. El prefijo S151 en el nombre del archivo comunica la fuente del dato a S050.

**Fórmula/pseudocódigo:**
```
WKS-TIT-MOVSXCONT-S087:
  "S{SIS}/FILE/S050/{NO}/{ND}/S151MOV{PROD}/{FEC}"
vs estándar:
  "S{SIS}/FILE/S050/{NO}/{ND}/MOV{PROD}/{FEC}"
% Diferencia: "S151MOV" vs "MOV" en el nombre
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| MOVSXCONT-087 | Archivo de movimientos para productos S087 — path especial |
| S151MOV | Prefijo en nombre de archivo que indica origen S151 |
| S087 | Producto/sistema 087 con lógica de estado de cuenta diferenciada |

**Excepciones:** S050 debe tener lógica de lectura para ambos patrones: "MOV" y "S151MOV" — si solo lee uno, perderá movimientos.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONT-S087 líneas 526-539.

---

## RN-S151-380
**Identificador:** RN-S151-380
**Tipo:** Funcional — Punteo con S500
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-TIT-SALS500 define el archivo de punteo S500 "S151/FILE/S{SIS}/PBATCH/{CSI}/{FEC}" donde PBATCH indica procesamiento batch de punteo. Este archivo valida la residencia del batch P158 respecto a S500. El CSI (2 dígitos) en el path diferencia la instancia por Centro de Servicios Integrados. La función es verificar que S500 y P158 están en el mismo pack para garantizar consistencia.

**Fórmula/pseudocódigo:**
```
WKS-TIT-SALS500:
  "S151/FILE/S{SIS}/PBATCH/{CSI}/{FEC}."
% PBATCH: área de punteo batch
% CSI(2) = WKS-DH-NUMCSI — identificador del centro
% FEC(6) = AAMMDD formato de fecha
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| SALS500 | Archivo de punteo (saldo) S500 — reconciliación con captación |
| PBATCH | Área de punteo batch en el filesystem MCP |
| WKS-DH-NUMCSI | Número de CSI del host — identifica la instancia de proceso |
| punteo | Reconciliación de saldos entre dos sistemas |

**Excepciones:** CSI incorrecto en la ruta genera un archivo en ubicación equivocada — S500 no encontrará el punteo.
**Estado validación:** Verificado en WKS-TIT-SALS500 líneas 615-622.

---

## RN-S151-381
**Identificador:** RN-S151-381
**Tipo:** Operativo — Validación P170
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-TIT-INMOV define el archivo de validación de residencia del P170 en nodo CMEMP: "(S151)S{SIS}/FILE/I01/S151/MOVXCONT/{FEC} ON CMEMP". El sufijo "ON CMEMP" identifica el nodo CMEMP como destino. P158 verifica que el P170 (un programa relacionado) esté disponible en ese nodo antes de continuar. Si el archivo no está presente, P158 espera o falla.

**Fórmula/pseudocódigo:**
```
WKS-TIT-INMOV:
  "(S151)S{SIS}/FILE/I01/S151/MOVXCONT/{FEC} ON CMEMP"
% CMEMP: nodo de centro de procesamiento
% I01: identificador de archivo de intercambio
% MOVXCONT: tipo de archivo esperado en ese nodo
% P158 valida residencia: PERFORM 77000-VALIDA-RESIDENCIA
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WKS-TIT-INMOV | Título del archivo de validación de residencia |
| CMEMP | Nodo de Centro de Empleados o nodo de procesamiento MCP |
| I01 | Área de intercambio internode del S151 |
| P170 | Programa relacionado cuya residencia verifica P158 antes de continuar |

**Excepciones:** Si P170 no está en CMEMP, P158 puede entrar en espera indefinida — debe configurarse timeout.
**Estado validación:** Verificado en WKS-TIT-INMOV líneas 658-667.

---

## RN-S151-382
**Identificador:** RN-S151-382
**Tipo:** Operativo — Auto-submisión WFL
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** P158 genera dinámicamente un WFL (Workflow Language) job para invocar P170 y generar listados de movimientos. WKS-LIS-WFL construye el string "BEGIN JOB; RUN {PROG} ("{SIS}{NOM}"); VALUE = {FP170}; END JOB." El valor FP170 (WKS-LIST-FP170 PIC 9(08)) es la fecha de proceso de 8 dígitos. Este mecanismo de auto-submisión es característico de MCP Unisys — el programa genera su propio job.

**Fórmula/pseudocódigo:**
```
WKS-LIS-WFL = "BEGIN JOB; RUN " + WKS-LIST-PROG
             + " (" + QUOTES + WKS-LIST-SIS + WKS-LIST-NOM + QUOTES
             + "); VALUE = " + WKS-LIST-FP170 + "; END JOB."
CALL SYSTEM WFL USING WKS-LIS-WFL
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WFL | Workflow Language de MCP Unisys — lenguaje de control de jobs |
| CALL SYSTEM WFL | Instrucción COBOL MCP para invocar un job WFL dinámicamente |
| WKS-LIST-FP170 | Fecha de proceso pasada como VALUE al job P170 |
| auto-submisión | Patrón de MCP donde un programa genera y envía su propio job |

**Excepciones:** WFL con sintaxis incorrecta (PROG name mal formado) produce error de compilación en tiempo de ejecución.
**Estado validación:** Verificado en WKS-LIS-WFL líneas 480-492.

---

## RN-S151-383
**Identificador:** RN-S151-383
**Tipo:** Funcional — Historial de productos
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** P158 tiene historial de modificaciones por producto documentado en comentarios: 66/8 Softtek, 66/9 Perfiles Universitario, 66/10 Cuenta Uno + 500/1 Perfil Ejecutivo, 66/11 Prepagada, 66/12 Cuenta de Ahorro, 66/14 Cuenta Base Banamex, 66/90 Cuenta Global, 66/15 Perfiles Dólares. Cada producto puede tener lógica de estado de cuenta diferente. Los productos con código 66/N corresponden a subcódigos del instrumento 66 en S500.

**Fórmula/pseudocódigo:**
```
Productos cubiertos (PRODUCTO/INSTRUMENTO):
  66/8:  Cuenta Softtek (mod por Softtek)
  66/9:  Perfiles Universitario
  66/10: Cuenta Uno
  500/1: Perfil Ejecutivo
  66/11: Prepagada
  66/12: Cuenta de Ahorro
  66/14: Cuenta Base Banamex
  66/90: Cuenta Global
  66/15: Perfiles Dólares
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| 66/N | Producto 66, instrumento N — codificación de tipo de cuenta captación |
| Perfil Ejecutivo | Producto 500/1 — cuenta de nómina/ejecutivo |
| Cuenta Global | Producto 66/90 — cuenta multimoneda o multi-producto |
| instrumento | Subclasificación dentro del producto; 2 dígitos |

**Excepciones:** Productos no listados en el historial pueden no tener lógica diferenciada — usan el flujo genérico.
**Estado validación:** Verificado en comentarios de FILE-CONTROL y Working Storage de P158.

---

## RN-S151-384
**Identificador:** RN-S151-384
**Tipo:** Funcional — Control de procesos
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** P158 consulta BD99 (S151LIBCONTROL) al inicio para obtener parámetros de proceso: fecha de proceso, nombres de packs y configuración del CSI. La llamada "CONSISDIA IN S151LIBCONTROL" retorna WKS-S151B01SISDIA. Si ATTRIBUTE VALUE OF MYSELF = 0 (valor del día), usa la fecha del registro de control; de lo contrario, usa ATTRIBUTE VALUE (fecha de la máquina). Esta lógica de doble fuente de fecha permite reejecutar para fechas pasadas.

**Fórmula/pseudocódigo:**
```
CALL "CONSISDIA IN S151LIBCONTROL" USING WKS-S151B01SISDIA
IF ATTRIBUTE VALUE OF MYSELF = 0:
  % Usa fecha del control BD99
  MOVE WKS-B01-FECPRO TO WKS-151-FECPROC
ELSE:
  % Usa fecha actual de la máquina
  MOVE ATTRIBUTE VALUE OF MYSELF TO WKS-151-FECPROC
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| CONSISDIA | Función de BD99 que retorna datos del día de proceso |
| S151LIBCONTROL | Librería de control que expone funciones de BD99 |
| ATTRIBUTE VALUE OF MYSELF | Valor de la fecha de la máquina MCP en formato CCAAMMDD |
| WKS-B01-FECPRO | Fecha de proceso leída de BD99 — puede diferir de la máquina |

**Excepciones:** Si BD99 tiene fecha de control en el futuro, P158 procesará movimientos del futuro — valida FECPRO ≤ hoy.
**Estado validación:** Verificado en líneas 9260-9288.

---

## RN-S151-385
**Identificador:** RN-S151-385
**Tipo:** Estructural — Clave de cuenta
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-LLAVE-CTA (16 dígitos) tiene REDEFINES como CTA-1(15)+CTA-2(01). Esta partición permite acceder al número de cuenta de 16 dígitos como un campo de 15 más un dígito de control/paridad. La misma clave usa NOD(02)+SUBNODO(02) como prefijo de nodo en WKS-LLAVE-NOD antes de la clave de cuenta. La estructura permite validación de integridad del número de cuenta sin modificar el campo de 16 dígitos.

**Fórmula/pseudocódigo:**
```
WKS-LLAVE-CTA PIC 9(16) COMP
  REDEFINES:
    WKS-LLAVE-CTA-1 PIC 9(15) COMP  % número de cuenta
    WKS-LLAVE-CTA-2 PIC 9(01) COMP  % dígito de control
WKS-LLAVE-NOD:
  WKS-NODO-LL    PIC 9(02)  % nodo
  WKS-SUBNODO-LL PIC 9(02)  % sub-nodo
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WKS-LLAVE-CTA | Clave de cuenta de 16 dígitos en el sort de P158 |
| WKS-LLAVE-CTA-2 | Dígito de control/verificación de la cuenta; 1 dígito |
| WKS-NODO-LL | Nodo de distribución en la llave de proceso |
| dígito de control | Último dígito del número de cuenta para detección de errores |

**Excepciones:** CTA-1(15) con ceros iniciales puede perder ceros al hacer operaciones numéricas — usar como alfanumérico.
**Estado validación:** Verificado en WKS-LLAVE-ACTUAL líneas 749-765.

---

## RN-S151-386
**Identificador:** RN-S151-386
**Tipo:** Operativo — Cierre de descriptor
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-CIERRA-DESC controla el cierre del archivo LOG151-COMP (descriptivos). Tiene tres campos: FUNCION(04), LOGDESC1(01) y LOGDESC2(01). Al cerrar el LOG complementario, P158 primero actualiza WKS-CIERRA-DESC con los indicadores de estado antes del CLOSE. Un cierre sin esta estructura puede dejar el archivo de descriptivos en estado inconsistente, impidiendo lecturas posteriores.

**Fórmula/pseudocódigo:**
```
WKS-CIERRA-DESC:
  CIERRA-FUNCION   PIC 9(04): función de cierre
  CIERRA-LOGDESC1  PIC 9(01): indicador descriptor 1
  CIERRA-LOGDESC2  PIC 9(01): indicador descriptor 2
% Antes del CLOSE LOG151-COMP:
%   MOVE FUNCION/LOGDESC1/LOGDESC2 TO WKS-CIERRA-DESC
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WKS-CIERRA-DESC | Estructura de control para cierre del LOG complementario |
| CIERRA-FUNCION | Función de cierre del descriptor; 4 dígitos |
| CIERRA-LOGDESC1/2 | Indicadores de estado de los descriptores al cerrar |
| estado inconsistente | Condición de archivo parcialmente escrito o sin marca de EOF |

**Excepciones:** LOGDESC1=0 y LOGDESC2=0 puede indicar sin descriptivos escritos — validar antes del cierre.
**Estado validación:** Verificado en WKS-CIERRA-DESC estructura líneas 855-858.

---

## RN-S151-387
**Identificador:** RN-S151-387
**Tipo:** Funcional — Control de archivos diarios
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-LIBCONTROL (estructura de control de BD99) incluye OCC-FECHAS OCCURS 10 con (WS-CON-FECARCM(08)+WS-CON-NIVARCM(08)+WS-CON-NIVBDM(08)). Las 10 ocurrencias representan los 10 ciclos de archivo de movimientos históricos en BD99. Cada ciclo tiene fecha, nivel de archivo y nivel de BD. P158 itera sobre estas 10 ocurrencias para encontrar el last record (`000-006-OBTEN-LASTRECORD`).

**Fórmula/pseudocódigo:**
```
WKS-LIBCONTROL.OCC-FECHAS OCCURS 10:
  WS-CON-FECARCM(08): fecha del ciclo de archivo (CCAAMMDD)
  WS-CON-NIVARCM(08): nivel del archivo de movimientos
  WS-CON-NIVBDM(08):  nivel de la base de datos de movimientos
% PERFORM 000-006-OBTEN-LASTRECORD
%   VARYING W77-IND3 FROM 1 BY 1 UNTIL W77-IND3 > 10 OR W77-ENCONTRADO=1
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| OCC-FECHAS | Arreglo de 10 ciclos de archivos históricos |
| WS-CON-NIVARCM | Nivel del archivo de movimientos — identifica la versión activa |
| WS-CON-NIVBDM | Nivel de la base de datos de movimientos activa |
| W77-IND3 | Índice de iteración sobre las 10 ocurrencias |

**Excepciones:** Si W77-ENCONTRADO nunca se activa en las 10 iteraciones, usa el último ciclo por default.
**Estado validación:** Verificado en WKS-LIBCONTROL líneas 864-899 y PERFORM 000-006 línea 9276.

---

## RN-S151-388
**Identificador:** RN-S151-388
**Tipo:** Operativo — Tabla de meses
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-TABLA-MESES contiene los nombres de los 12 meses en español abreviados a 3 caracteres: "ENEFEBMARABRMAYJUNJULAGOSEPOCTNOVDIC" como X(36) con REDEFINES WKS-TAB-MES OCCURS 12 de X(03). Esta tabla se usa en los encabezados de reportes PRINTER (REPDEVOL, TOTAL, MOVBONIFICA) para formatear la fecha. Es una tabla hardcodeada que no cambia con locale o configuración.

**Fórmula/pseudocódigo:**
```
WKS-TABLA-MESES X(36):
  "ENE FEB MAR ABR MAY JUN JUL AGO SEP OCT NOV DIC"
  (sin espacios, 3 chars por mes)
WKS-TAB-MES(MM) → nombre del mes MM (1-12)
% Uso: MOVE WKS-TAB-MES(W77-MES) TO CAMPO-FECHA-REPORTE
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WKS-TABLA-MESES | Tabla hardcodeada de nombres de meses en español abreviados |
| WKS-TAB-MES | Elemento del arreglo de meses; X(03) |
| hardcoded table | Tabla con valores fijos en código fuente — no configurable |

**Excepciones:** Si W77-MES está fuera de rango 1-12, WKS-TAB-MES referencia memoria fuera del array — riesgo de corrupción.
**Estado validación:** Verificado en WKS-TABLA-MESES líneas 807-811.

---

## RN-S151-389
**Identificador:** RN-S151-389
**Tipo:** Estructural — Y2K pivote
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** A2K-BASE-YEAR VALUE 50 es el pivote del algoritmo Y2K de conversión de año 2-dígitos a 4-dígitos. Años de 2 dígitos < 50 se interpretan como 2000-2049 (2000+AA), años >= 50 se interpretan como 1950-1999 (1900+AA). Este pivote expirará en el año 2049 — cualquier fecha con AA >= 50 post-2050 se interpretará incorrectamente como siglo 20.

**Fórmula/pseudocódigo:**
```
A2K-BASE-YEAR VALUE 50.
IF AA < 50:
  CCYY = 2000 + AA  % 2000-2049
ELSE:
  CCYY = 1900 + AA  % 1950-1999
% RIESGO: AA=50 en 2050 se interpretará como 1950, no 2050
% EXPIRACIÓN DEL FIX Y2K en 2049
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| A2K-BASE-YEAR | Pivote para conversión de año 2→4 dígitos; valor 50 |
| pivote Y2K | Umbral para distinguir siglo 20 de siglo 21 |
| año 2-dígitos | Representación pre-Y2K de años sin el siglo |
| expiración | El fix Y2K caduca en 2049 cuando AA=50 representa 2050 |

**Excepciones:** Cualquier referencia a fechas >= 2050 producirá interpretación incorrecta del siglo.
**Estado validación:** Verificado en Working Storage A2K-BASE-YEAR línea 447.

---

## RN-S151-390
**Identificador:** RN-S151-390
**Tipo:** Funcional — Estados de proceso
**Confianza:** ALTA
**Regulador:** N/A
**Capacidad bancaria:** T.3.4 Analytics/Reporting

**Descripción:** WKS-151-DATOS tiene STATUS1, STATUS2, STATUS3 con sus correspondientes FECBASE1, FECBASE2, FECBASE3 (8 dígitos cada una). Esta estructura soporta hasta 3 bases de fecha de aplicación activas simultáneamente por ciclo de proceso. Cada par STATUS/FECBASE representa un estado de procesamiento diferente (p.ej., proceso actual, reproceso, conciliación). STATUS=0 indica base inactiva o no usada en ese ciclo.

**Fórmula/pseudocódigo:**
```
WKS-151-DATOS:
  NUMBASE(02): número de base activa (1-3)
  CSI(02):     identificador del CSI
  FECPROC(08): fecha de proceso (CCAAMMDD)
  FECBASE1/2/3(08): fechas de las 3 bases posibles
  STATUS1/2/3(01): estado de cada base (0=inactiva)
% Solo las bases con STATUS ≠ 0 se procesan
```

**Vocabulario:**

| Término | Definición |
|---------|-----------|
| WKS-151-DATOS | Estructura de control de estado del proceso de P158 |
| STATUS1/2/3 | Estado de cada una de las 3 bases de proceso; 1=activa |
| FECBASE1/2/3 | Fecha de aplicación de cada base; CCAAMMDD 8 dígitos |
| base | Ciclo de aplicación de movimientos — puede haber hasta 3 simultáneos |

**Excepciones:** Si NUMBASE > 3, la iteración sobre bases accede a memoria fuera de estructura — validar NUMBASE IN (1,2,3).
**Estado validación:** Verificado en WKS-151-DATOS estructura líneas 813-854.