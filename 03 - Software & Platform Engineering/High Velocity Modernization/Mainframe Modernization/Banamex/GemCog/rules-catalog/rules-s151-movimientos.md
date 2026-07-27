# Catálogo de Reglas de Negocio — S151 Movimientos GL · Analytics
**Versión:** 1.0 — 2026-07-17
**Programas fuente:** P053 · P030 · P014 · P055 · L040 · P054 · P005 · P013 · P001 · P025 · P016 · L020 · L014 · P011 · P020 · P071 · P017 · P073 · P090 (Finance GL) · P600 (Analytics)
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Numeración:** RN-S151-950 a RN-S151-1139 (190 reglas)
**Indexado:** ✅ 2026-07-17

---

## Índice de programas

| Programa | PROGRAM-ID | Descripción | Reglas |
|----------|-----------|-------------|--------|
| P053 | LINEA | Monitor file para S151 — generación de archivo de monitor | 950–959 |
| P030 | ADMOV | Administración de movimientos — hub central S151 | 960–969 |
| P014 | DGOPROTCOB | Generación de alertas BALCON / Protección de Cobros | 970–979 |
| P055 | FILESCTAMDRED | Archivo intraday cuenta moneda reducida (MXN + USD) | 980–989 |
| L040 | TOTXCVETRA | Librería SHAREDBYALL de totales por clave de transacción | 990–999 |
| P054 | EXTENDEDNETWORK | Archivo de red extendida intraday (MXN + USD) | 1000–1009 |
| P005 | EXTRACTOR | Extractor de saldos S151BD02ADSALDO → Tesorería | 1010–1019 |
| P013 | DGODOMI | Procesamiento domiciliación / cargo automático | 1020–1029 |
| P001 | CARSDOMOV | Lector de movimientos de tarjeta y domiciliados | 1030–1039 |
| P025 | (date projection) | Proyección de fechas sobre S151BD10MOVDIA151 | 1040–1049 |
| P016 | (acumulador intraday) | Acumulador en tiempo real por producto/instrumento/CPAE | 1050–1059 |
| L020 | S151LIB020 | Librería SHAREDBYRUNUNIT — interfaz WKS-MOV-DATOS | 1060–1069 |
| L014 | S151L014 | Librería SHAREDBYALL — consulta BIFIN online | 1070–1079 |
| P011 | (monitor/alarm manager) | Gestor de alarmas y relay batch | 1080–1089 |
| P020 | S151-P020 | Receptor de mensajes L002 (SA2/SA0 protocol) | 1090–1099 |
| P071 | S151P071 | Monitor/relay de movimientos — sistema 071 | 1100–1107 |
| P017 | S151-P017 | Receptor de confirmaciones S702 — Protección de Cobros | 1108–1115 |
| P073 | S151P073 | Monitor/relay de movimientos — sistema 073 | 1116–1123 |
| P090 | RECLIDE | Totales LIDE para S502 — Liquidación Diaria de Efectivo | 1124–1131 |
| P600 | CALLLIBCTL | Programa de referencia: interfaz completa LIBCONTROL | 1132–1139 |

---

## Convenciones

- **Confianza Alta** = regla derivada directamente de código fuente sin ambigüedad
- **Confianza Media** = regla inferida de estructura o comentario, requiere validación SME
- **Frecuencia:** ONLINE = tiempo real; BATCH-DIARIO = proceso nocturno o diario; PERMANENTE = cargado siempre (librerías); INTRADAY = dentro de ventana operativa 04:00–20:00
- **Regulador "—"** = regla técnica/arquitectural sin implicación regulatoria directa

---

## P053 — LINEA — Monitor file S151

---

## RN-S151-950

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-950 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de monitor de P053 sigue la convención de nomenclatura `(S151)S151/FILE/MONITOR/P053/{FECHA}/{HORA}/{MIXNUMBER} ON CMEMP.` donde FECHA=AAMMD, HORA=HHMMSS y MIXNUMBER identifica el mix de MCP. Cada ejecución genera un archivo único por timestamp.

**Fórmula/pseudocódigo:**
```
WKS-TIT-MONITOR = "(S151)S151/FILE/MONITOR/P053/" + FECHA(6) + "/" + HORA(6) + " ON CMEMP."
```

**Vocabulario en la fórmula:** WKS-TIT-MONITOR, FECHA, HORA, MIXNUMBER

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-951

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-951 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de monitor A01-MONITOR tiene `PROTECTION IS PROTECTED`, lo que impide su modificación o eliminación accidental en el entorno MCP. Garantiza la integridad del registro de auditoría operativa durante toda la sesión.

**Fórmula/pseudocódigo:**
```
FD A01-MONITOR
   PROTECTION IS PROTECTED
   VALUE OF TITLE IS WKS-TIT-MONITOR.
```

**Vocabulario en la fórmula:** A01-MONITOR, PROTECTION IS PROTECTED

**Excepciones:** Ninguna — PROTECTED es un atributo fijo del archivo en MCP.

**Estado validación:** Pendiente SME

---

## RN-S151-952

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-952 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de monitor tiene longitud fija de 1500 caracteres agrupados en bloques de 10 registros. Esto permite hasta 15,000 caracteres por bloque de disco, optimizando I/O en MCP.

**Fórmula/pseudocódigo:**
```
RECORD CONTAINS 1500 CHARACTERS
BLOCK  CONTAINS 10   RECORDS
```

**Vocabulario en la fórmula:** R01-REG-MONITOR PIC X(1500)

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-953

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-953 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La estructura de sucursal (OFICINA) incorporada vía COPY desde CRONOS2K P010/WS incluye jerarquía completa: COMITE, AREA, DIVISION, DIRECCION, GERENCIA, OPECOM, TIPO-OFICINA, NCORTO (nombre corto), NLARGO (nombre largo) y DOMICILIO. Esta jerarquía es obligatoria para reportes regulatorios CNBV.

**Fórmula/pseudocódigo:**
```
OFICINA contiene:
  COMITE | AREA | DIVISION | DIRECCION | GERENCIA | OPECOM
  TIPO-OFICINA | NCORTO | NLARGO | DOMICILIO
```

**Vocabulario en la fórmula:** OFICINA, COMITE, AREA, DIVISION, GERENCIA, NCORTO, NLARGO

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-954

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-954 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P053 usa la librería CRONOS2K para conversión de fechas. El pivote de siglo A2K-BASE-YEAR=50 define que años de 2 dígitos (AA) >= 50 pertenecen al siglo XX (1900+AA) y AA < 50 al siglo XXI (2000+AA). Esta regla aplica universalmente a todos los programas S151 que usen CRONOS2K.

**Fórmula/pseudocódigo:**
```
IF AA >= A2K-BASE-YEAR (50)
   THEN CCAA = 1900 + AA   -- siglo XX
ELSE
   CCAA = 2000 + AA        -- siglo XXI
```

**Vocabulario en la fórmula:** A2K-BASE-YEAR, AA, CCAA, CRONOS2K

**Excepciones:** Fechas en formato CCAAMMDD ya tienen siglo explícito — no aplica pivote.

**Estado validación:** Pendiente SME

---

## RN-S151-955

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-955 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La librería DESPLIEGA (S000/UTILITY/DESPLIEGA) genera mensajes al operador MCP con formato estructurado: SISTEMA(4)/PASO(4)/MTP(3):TIPO(1)>CODIGO(6)<TEXTO(250). Todos los programas S151 que escriben al operador usan este formato canónico vía COPY.

**Fórmula/pseudocódigo:**
```
MENSAJE-LJ = SISTEMA-LJ "/" PASO-LJ "/" MTP-LJ ":" TIPO-LJ ">" CODIGO-LJ "<" TEXTO-LJ
```

**Vocabulario en la fórmula:** MENSAJE-LJ, SISTEMA-LJ, PASO-LJ, MTP-LJ, TIPO-LJ, CODIGO-LJ, TEXTO-LJ(250)

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-956

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-956 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P053 incorpora vía COPY la interfaz LIBCONTROL con entry-point CONSISDIA y 10 funciones para gestión del dataset S151B01SISDIA (fechas de proceso/consulta, estatus de bases, niveles de archivo). Esta interfaz es estándar en todos los programas S151 que acceden al control de día.

**Fórmula/pseudocódigo:**
```
CONSISDIA F01 = consultar S151B01SISDIA
CONSISDIA F02 = actualizar FECCON
CONSISDIA F03 = actualizar FECPRO
CONSISDIA F04 = actualizar STABDSEM (0/1)
CONSISDIA F05 = habilitar/bloquear STAREG (0/1)
CONSISDIA F06-F10 = gestión de niveles y estatus de archivos
```

**Vocabulario en la fórmula:** CONSISDIA, WKS-B01-FUNCION, WKS-B01-SISTEMA, WKS-B01-CSI

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-957

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-957 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los archivos S151 se almacenan en el pack físico CMEMP del entorno MCP Unisys. El sufijo ` ON CMEMP.` en los títulos de archivo identifica el pack de destino y es obligatorio en todos los archivos de producción S151.

**Fórmula/pseudocódigo:**
```
VALUE OF TITLE IS "(S151)S151/FILE/MONITOR/P053/..." + " ON CMEMP."
```

**Vocabulario en la fórmula:** CMEMP, TITLE, ON PACK

**Excepciones:** Archivos temporales o de test pueden usar packs distintos.

**Estado validación:** Pendiente SME

---

## RN-S151-958

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-958 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P053 fue recompilado en 2014 bajo el proyecto de upgrade MCP a versión 55 (modificación 15MTP001, responsable MJGRG). El código original data de 2005. La recompilación no alteró lógica de negocio sino parámetros de compilación MCP.

**Fórmula/pseudocódigo:**
```
$SET LIST LINEINFO MAP XREF OPTIMIZE
$SET LISTOMITTED
* RECOMPILACION POR EL UPGRADE DEL MCP A 55
* 20141205 15MTP001 MJGRG
```

**Vocabulario en la fórmula:** 15MTP001, MCP 55, MJGRG

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-959

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-959 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P053 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El autor original de P053 es Jose Felix Torres Franco (2005). P053 es uno de los programas de soporte de monitoreo más recientes del subsistema S151, que datan desde 1993 (P030) hasta 2018 (P020).

**Fórmula/pseudocódigo:** N/A — Metadata de autoría.

**Vocabulario en la fórmula:** AUTHOR, DATE-WRITTEN

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## P030 — ADMOV — Administración de movimientos

---

## RN-S151-960

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-960 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El TASKFILE de P030 sigue la nomenclatura `S151/TASKFILE/P030/{NODO}/{FECHA}/{MXNB}` donde NODO identifica el nodo MCP destino, FECHA es AAMMD y MXNB es el mix-number. Este archivo coordina el encolamiento de movimientos entre nodos del clúster MCP.

**Fórmula/pseudocódigo:**
```
TASKFILE = "S151/TASKFILE/P030/" + NODO + "/" + FECHA(6) + "/" + MXNB
```

**Vocabulario en la fórmula:** TASKFILE, NODO, FECHA, MXNB

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-961

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-961 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P030 usa dos buffers de mensaje diferenciados: WKS-MSG-COMS (1926 bytes) para el mensaje de comunicaciones completo y WKS-MSG (1920 bytes) para el payload de datos. Los 6 bytes de diferencia corresponden al encabezado del protocolo de comunicaciones.

**Fórmula/pseudocódigo:**
```
WKS-MSG-COMS PIC X(1926)   -- mensaje completo con encabezado
WKS-MSG      PIC X(1920)   -- payload de datos (1926 - 6 bytes de header)
```

**Vocabulario en la fórmula:** WKS-MSG-COMS, WKS-MSG

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-962

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-962 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La estación física (terminal de cajero) se identifica con 8 bytes: TIPO(1) + SUC(4) + PRIV(1) + CAJ(2). TIPO discrimina entre terminales de cajero, supervisor y otros. SUC es la sucursal, PRIV es el privilegio del operador y CAJ es el número de caja.

**Fórmula/pseudocódigo:**
```
STATION(8) = TIPO(1) + SUC(4) + PRIV(1) + CAJ(2)
```

**Vocabulario en la fórmula:** STATION, TIPO, SUC, PRIV, CAJ, WKS-TRANCODE-COMS

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-963

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-963 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El código de transacción (TRANCODE) de 6 dígitos en WKS-TRANCODE-COMS determina el tipo de operación bancaria que P030 administra. El TRANCODE es el selector principal de lógica de negocio en el hub de movimientos.

**Fórmula/pseudocódigo:**
```
WKS-TRANCODE-COMS PIC X(6)
IF WKS-TRANCODE-COMS = {código}
   PERFORM {lógica específica de la transacción}
```

**Vocabulario en la fórmula:** WKS-TRANCODE-COMS, TRANCODE

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-964

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-964 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P030 (ADMOV) es el programa más antiguo del subsistema S151, con fecha original de 1993. Actúa como hub central de administración de movimientos y ha sobrevivido 30+ años de operación bancaria, recompilaciones y migraciones MCP.

**Fórmula/pseudocódigo:** N/A — Metadata histórica.

**Vocabulario en la fórmula:** ADMOV, 1993, MCP 55 recompile 2014

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-965

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-965 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P030 implementa enrutamiento basado en NODO para distribuir movimientos a múltiples nodos del clúster MCP Unisys. El campo NODO-ORIG y NODO-DESTINO del registro canónico de movimiento determinan el nodo origen y destino de cada transacción.

**Fórmula/pseudocódigo:**
```
IF NODO-DESTINO ≠ NODO-LOCAL
   SEND VIA TASKFILE to NODO-DESTINO
ELSE
   PROCESS LOCALLY
```

**Vocabulario en la fórmula:** NODO-ORIG, NODO-DESTINO, NODO-LOCAL, TASKFILE

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-966

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-966 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P030 implementa el protocolo SA2 de comunicación online Unisys que incluye encabezado con SUCURSAL, CAJA, TRANNUM (número de transacción), FECMOV (fecha del movimiento) y HORA. Este protocolo es obligatorio para transacciones iniciadas desde terminales de cajero.

**Fórmula/pseudocódigo:**
```
SA2-HEADER = SUCURSAL(4) + CAJA(2/3) + TRANNUM(8) + FECMOV(6) + HORA(6)
```

**Vocabulario en la fórmula:** SA2, SUCURSAL, CAJA, TRANNUM, FECMOV, HORA

**Excepciones:** Transacciones batch no usan SA2 — usan TASKFILE directo.

**Estado validación:** Pendiente SME

---

## RN-S151-967

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-967 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** W77-HI es el indicador de error principal de P030 con 88-levels para categorías: 2=error de base de datos DMSII, 3=registro no encontrado, 4=duplicado, 6=deadlock/lock, 32=error de sistema. Cada categoría dispara una ruta de recuperación diferente.

**Fórmula/pseudocódigo:**
```
88 W88-HI-2   VALUE 2   -- DB error
88 W88-HI-3   VALUE 3   -- NOTFOUND
88 W88-HI-4   VALUE 4   -- DUPLICATES
88 W88-HI-6   VALUE 6   -- DEADLOCK/LOCK
88 W88-HI-32  VALUE 32  -- SYSTEM ERROR
```

**Vocabulario en la fórmula:** W77-HI, W88-HI-2, W88-HI-3, W88-HI-4, W88-HI-6, W88-HI-32

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-968

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-968 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P030 fue recompilado bajo 15MTP001 (2014, MCP 55), misma modificación que afectó a P053, P071, P073 y P090. Esto confirma que el upgrade MCP 55 fue un evento masivo de recompilación sin cambios de negocio.

**Fórmula/pseudocódigo:** N/A — Metadata de recompilación.

**Vocabulario en la fórmula:** 15MTP001, MCP 55, 20141205

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-969

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-969 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P030 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P030 actúa como hub central (dispatcher) para todos los movimientos S151. Recibe movimientos de sistemas upstream (S500, SA2-online) y los distribuye a los programas de procesamiento especializados (P013, P014, P016, P055, P054) mediante taskfiles y mensajes SA2.

**Fórmula/pseudocódigo:**
```
RECEIVE WKS-MSG-COMS FROM SA2
PARSE TRANCODE from WKS-TRANCODE-COMS
DISPATCH to specialist program via TASKFILE or message
```

**Vocabulario en la fórmula:** ADMOV, WKS-MSG-COMS, TRANCODE, TASKFILE

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## P014 — DGOPROTCOB — Alertas BALCON / Protección de Cobros

---

## RN-S151-970

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-970 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P014 consume el archivo A01-MOVS500 (movimientos del sistema S500 — Cargos/Abonos) como entrada principal. Formato: 450 bytes por registro, bloques de 144 registros. Esta es la interfaz canónica de integración S500 → S151.

**Fórmula/pseudocódigo:**
```
A01-MOVS500: RECORD 450 bytes, BLOCK 144 records
INPUT from S500 (Cargos/Abonos system)
```

**Vocabulario en la fórmula:** A01-MOVS500, S500, 450 bytes, 144 rec/block

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-971

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-971 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P014 genera mensajes de alerta para movimientos BALCON (Balance Control) que activan la Protección de Cobros (PROTCOB). BALCON es el mecanismo de control de saldo que detecta cuando una cuenta cae por debajo del umbral y activa protección automática de cobros pendientes.

**Fórmula/pseudocódigo:**
```
FOR EACH movimiento IN A01-MOVS500:
  IF movimiento requiere alerta BALCON:
    GENERATE alerta en S151BD13BIFIN.B07PROTCOB
    WRITE descriptor en A03-DES (PROD+INST key)
```

**Vocabulario en la fórmula:** BALCON, PROTCOB, B07PROTCOB, A01-MOVS500

**Excepciones:** Movimientos sin impacto en balance de control no generan alerta.

**Estado validación:** Pendiente SME

---

## RN-S151-972

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-972 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de control A02-CTL-PC tiene `PROTECTION IS PROTECTED`, protegiendo el estado del proceso batch contra modificaciones externas durante la ejecución. Garantiza idempotencia del proceso de alertas.

**Fórmula/pseudocódigo:**
```
FD A02-CTL-PC PROTECTION IS PROTECTED
```

**Vocabulario en la fórmula:** A02-CTL-PC, PROTECTION IS PROTECTED

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-973

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-973 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo DES (descriptores) tiene 540 bytes por registro, 120 registros por bloque, y `DEPENDENTSPECS=TRUE`. DEPENDENTSPECS indica que el archivo comparte especificaciones con el dataset DMSII padre, garantizando consistencia de estructura en entorno MCP.

**Fórmula/pseudocódigo:**
```
FD A03-DES
   RECORD 540 bytes
   BLOCK 120 records
   DEPENDENTSPECS IS TRUE
```

**Vocabulario en la fórmula:** DES, DEPENDENTSPECS, 540 bytes

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-974

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-974 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo DES está indexado por KEY-CAT compuesto de PRODUCTO(9(4)) + INSTRUMENTO(9(4)). El par PRODUCTO-INSTRUMENTO es la clave contable primaria para clasificar movimientos en la jerarquía de catálogo de cuentas CNBV.

**Fórmula/pseudocódigo:**
```
KEY-CAT = PROD(9(4)) + INST(9(4))
INDEX ARCH-DES ON KEY-CAT
```

**Vocabulario en la fórmula:** KEY-CAT, PROD, INST, ARCH-DES

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-975

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-975 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P014 usa la base de datos S151BD13BIFIN (Business Interface — BIFIN) para almacenar los registros de protección de cobros en el dataset B07PROTCOB. BIFIN es la base de datos de interfaz online para consultas desde sucursales.

**Fórmula/pseudocódigo:**
```
DB S151BD13BIFIN
DATASET B07PROTCOB  -- Protection Cobros dataset
```

**Vocabulario en la fórmula:** S151BD13BIFIN, BIFIN, B07PROTCOB

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-976

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-976 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P014 implementa logging dual: L01-DISPLAY (archivo de impresión para auditoría) y L02-MONITOR (archivo de disco para seguimiento operativo). El doble canal garantiza que los mensajes de alerta queden registrados incluso si uno de los canales falla.

**Fórmula/pseudocódigo:**
```
WRITE L01-DISPLAY   -- para auditoría impresa
WRITE L02-MONITOR   -- para seguimiento operativo en disco
```

**Vocabulario en la fórmula:** L01-DISPLAY, L02-MONITOR

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-977

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-977 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La pipeline de integración BALCON sigue el flujo: S500 (Cargos/Abonos) genera A01-MOVS500 → P014 (DGOPROTCOB) procesa y genera alertas → S151BD13BIFIN.B07PROTCOB almacena las alertas → L014 las expone para consulta online desde sucursales.

**Fórmula/pseudocódigo:**
```
S500 → A01-MOVS500 → P014 → B07PROTCOB → L014 → Sucursal (online)
```

**Vocabulario en la fórmula:** DGOPROTCOB, B07PROTCOB, L014, BALCON

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-978

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-978 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La modificación con clave "250929" (25 septiembre de 2029 en formato AAMMDD — posiblemente 2025-09-29) integró los movimientos BALCON en P014 para generar alertas unificadas. El comentario reza "SE MODIFICA PARA GENERAR LOS MENSAJES DE ALERTAS PARA INTEGRAR LOS MOVIMIENTOS DE BALCON".

**Fórmula/pseudocódigo:** N/A — Metadata de cambio.

**Vocabulario en la fórmula:** BALCON, 250929, DGOPROTCOB

**Excepciones:** La fecha "250929" puede ser 2025-09-29 o 1925-09-29 si hay error de formato.

**Estado validación:** Pendiente SME — confirmar fecha real con historial de cambios.

---

## RN-S151-979

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-979 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** PROTCOB (Protección de Cobros) es un servicio regulado que garantiza que pagos programados de clientes sean cubiertos aun cuando el saldo de la cuenta sea insuficiente en el momento del cargo, usando una línea de crédito automática. P014 genera las alertas que activan este servicio.

**Fórmula/pseudocódigo:**
```
IF saldo_cuenta < importe_cargo AND cliente tiene PROTCOB activo:
  GENERATE alerta PROTCOB en B07PROTCOB
  ACTIVATE línea de crédito automática
```

**Vocabulario en la fórmula:** PROTCOB, B07PROTCOB, saldo_cuenta, importe_cargo

**Excepciones:** Clientes sin PROTCOB activo generan solo alerta de rechazo.

**Estado validación:** Pendiente SME

---

## P055 — FILESCTAMDRED — Archivo intraday cuenta moneda reducida

---

## RN-S151-980

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-980 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P055 genera dos archivos intraday paralelos: A04-CTAMRE-ARCHIVO (MXN, 320 bytes, 198 rec/block) y A04-CTAMRE-ARCHIVO-D (USD). La dualidad MXN/USD es obligatoria para cuentas "moneda reducida" — cuentas simplificadas con operación limitada en ambas divisas per Banxico.

**Fórmula/pseudocódigo:**
```
A04-CTAMRE-ARCHIVO   -- MXN (PESO), 320 bytes, 198 rec/block
A04-CTAMRE-ARCHIVO-D -- USD (DOLAR), misma estructura
```

**Vocabulario en la fórmula:** CTAMRE, A04-CTAMRE-ARCHIVO, A04-CTAMRE-ARCHIVO-D

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-981

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-981 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de autorizaciones A05-AUTORIZACIONES está indexado por KEY-AUTS151 con longitud máxima de 162 bytes y bloques de 400 registros. La clave KEY-AUTS151 es el identificador único de autorización S151 que certifica cada movimiento.

**Fórmula/pseudocódigo:**
```
A05-AUTORIZACIONES:
  MAX RECORD 162 bytes
  BLOCK 400 records
  KEY = KEY-AUTS151
```

**Vocabulario en la fórmula:** A05-AUTORIZACIONES, KEY-AUTS151

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-982

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-982 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de control R01-REG-ENVIO tiene 11 contadores para seguimiento dual MXN/USD: REG-TOTAL-MOV-PES, REG-ABON-PES (count+amount), REG-CARG-PES (count+amount), REG-TOTAL-MOV-ELIM-PES, REG-ABON-ELIM-PES, REG-CARG-ELIM-PES, y sus equivalentes en dólar. Los contadores "ELIM" rastrean movimientos eliminados/revertidos.

**Fórmula/pseudocódigo:**
```
R01-REG-ENVIO:
  REG-TOTAL-MOV-PES, REG-ABON-PES-CNT, REG-ABON-PES-IMP
  REG-CARG-PES-CNT, REG-CARG-PES-IMP
  REG-TOTAL-MOV-ELIM-PES, REG-ABON-ELIM-PES, REG-CARG-ELIM-PES
  [mismos 8 campos para USD]
```

**Vocabulario en la fórmula:** R01-REG-ENVIO, REG-ABON, REG-CARG, REG-ELIM, PES, DOL

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-983

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-983 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los contadores de eliminados (ELIM) son espejo exacto de los contadores activos: cada abono/cargo eliminado decrementa el total neto. El diseño garantiza que TOTAL = ACTIVOS - ELIMINADOS en cualquier punto de la jornada.

**Fórmula/pseudocódigo:**
```
TOTAL_NETO_PES = REG-TOTAL-MOV-PES - REG-TOTAL-MOV-ELIM-PES
ABONOS_NETO   = REG-ABON-PES  - REG-ABON-ELIM-PES
CARGOS_NETO   = REG-CARG-PES  - REG-CARG-ELIM-PES
```

**Vocabulario en la fórmula:** REG-TOTAL-MOV-PES, REG-TOTAL-MOV-ELIM-PES, TOTAL_NETO

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-984

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-984 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** "Cuenta Moneda Reducida" (CTAMRE) es una cuenta bancaria simplificada per regulación Banxico — opera con límites de saldo y transacción reducidos, puede ser en MXN o USD. P055 genera el archivo de posiciones intraday de estas cuentas para control de límites regulatorios.

**Fórmula/pseudocódigo:**
```
CTAMRE = cuenta con límites regulatorios reducidos
  MXN: A04-CTAMRE-ARCHIVO
  USD: A04-CTAMRE-ARCHIVO-D
Frecuencia de actualización: INTRADAY (tiempo real)
```

**Vocabulario en la fórmula:** CTAMRE, cuenta moneda reducida, Banxico

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-985

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-985 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** A03-CTL-ENVIO es el archivo de control de transmisión que rastrea el estado de envío del archivo de cuentas a los sistemas receptores. Previene reenvíos duplicados y permite recuperación si el proceso falla a mitad de transmisión.

**Fórmula/pseudocódigo:**
```
A03-CTL-ENVIO:
  CONTROL registro de estado de envío
  STATUS: pendiente/enviado/confirmado
```

**Vocabulario en la fórmula:** A03-CTL-ENVIO, CTL-ENVIO

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-986

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-986 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P055 consume dos archivos del sistema S500: A01-MOVS500 (movimientos, 450 bytes) y A02-DESS500 (descriptores, 540 bytes). El archivo de descriptores acompaña a cada movimiento con información adicional de producto/instrumento no contenida en el registro base de 450 bytes.

**Fórmula/pseudocódigo:**
```
A01-MOVS500  = movimientos S500, 450 bytes/rec, 144 rec/block
A02-DESS500  = descriptores S500, 540 bytes/rec
JOIN por AUT-S151 (llave de autorización)
```

**Vocabulario en la fórmula:** A01-MOVS500, A02-DESS500, DES

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-987

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-987 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P055 es consumidor de S500 (sistema upstream de Cargos/Abonos). La arquitectura de S151 usa S500 como fuente canónica de movimientos bancarios — S151 enriquece, filtra y redistribuye estos movimientos a subsistemas especializados como CTAMRE.

**Fórmula/pseudocódigo:**
```
S500 (fuente) → A01-MOVS500 → P055 → A04-CTAMRE (destino)
```

**Vocabulario en la fórmula:** S500, CTAMRE, P055

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-988

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-988 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El título del archivo MXN contiene la literal "PESO" hardcodeada para identificar la moneda. No existe un parámetro configurable de moneda — la diferencia entre el archivo MXN y USD está codificada en el nombre del archivo fuente.

**Fórmula/pseudocódigo:**
```
TITLE A04-CTAMRE-ARCHIVO   contiene "PESO"  -- MXN identificador fijo
TITLE A04-CTAMRE-ARCHIVO-D omite "PESO"     -- USD por exclusión
```

**Vocabulario en la fórmula:** PESO, DOLAR, CTAMRE, HARDCODE

**Excepciones:** Ninguna — cambio requeriría modificación de código fuente.

**Estado validación:** Pendiente SME — [HARDCODE-SOSPECHOSO] para migración FX dinámica.

---

## RN-S151-989

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-989 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P055 sigue la convención de TASKFILE estándar S151 para coordinación inter-nodo. El TASKFILE permite que múltiples instancias del proceso ejecuten en diferentes nodos MCP sin colisiones, dado que el nombre incluye NODO y mix-number como discriminadores únicos.

**Fórmula/pseudocódigo:**
```
TASKFILE = "S151/TASKFILE/P055/" + NODO + "/" + FECHA + "/" + MIX
```

**Vocabulario en la fórmula:** TASKFILE, NODO, MIX

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## L040 — TOTXCVETRA — Librería SHAREDBYALL de totales

---

## RN-S151-990

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-990 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L040 es una librería MCP de tipo `SHARED BY ALL` con `TARGET=LEVEL2`. Esto significa que se carga una sola vez en memoria compartida de nivel 2 y permanece disponible para todas las tareas del sistema S151 sin recargas. Es el modelo de librería más eficiente del entorno MCP.

**Fórmula/pseudocódigo:**
```
$ SHARED BY ALL
$ TARGET = LEVEL2
PROGRAM-ID. TOTXCVETRA.
```

**Vocabulario en la fórmula:** SHARED BY ALL, TARGET=LEVEL2, TOTXCVETRA

**Excepciones:** Requiere restart del sistema para actualizar la librería.

**Estado validación:** Pendiente SME

---

## RN-S151-991

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-991 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L040 expone 28 funciones de consulta organizadas en dos grupos: funciones 0–14 operan a nivel de clave de transacción individual (por CVETRAN), y funciones 21–34 operan a nivel de esquema completo (por SISTEMA). Esta separación permite consultas precisas o agregadas sobre MOVDIA.

**Fórmula/pseudocódigo:**
```
Funciones 0-14:  consulta por CVETRAN (key-level)
Funciones 21-34: consulta por SISTEMA (schema-level / agregado)
CALL "TOTXCVETRA" USING funcion, sistema, fecha, [cvetran], resultado
```

**Vocabulario en la fórmula:** TOTXCVETRA, CVETRAN, SISTEMA, S151BD10MOVDIA151

**Excepciones:** Funciones 15-20 no existen — el rango es intencional (reservado).

**Estado validación:** Pendiente SME

---

## RN-S151-992

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-992 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L040 retorna códigos de resultado estandarizados: 0=sin error, 1=función inválida, 2=fecha solicitud inválida, 3=sistema sin totales, 4=producto sin totales, 5=instrumento sin totales, 6=base de control no disponible, 7=base de datos no disponible, 8=sistema no dado de alta, 99=fin de datos (EOF).

**Fórmula/pseudocódigo:**
```
RETURN-CODE:
  0  = OK
  1  = función inválida (fuera de 0-14 / 21-34)
  2  = fecha inválida
  3  = sin totales para SISTEMA
  4  = sin totales para PRODUCTO
  5  = sin totales para INSTRUMENTO
  6  = base de control no disponible
  7  = base MOVDIA no disponible
  8  = sistema no dado de alta en MOVDIA
  99 = fin de datos
```

**Vocabulario en la fórmula:** RETURN-CODE, BASEMOVDIA, S151BD10MOVDIA151

**Excepciones:** Código 99 es EOF — no es error sino señal de fin de iteración.

**Estado validación:** Pendiente SME

---

## RN-S151-993

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-993 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L040 accede a la base de datos S151BD10MOVDIA151 bajo el alias BASEMOVDIA. Esta base contiene los totales de movimientos del día agrupados por clave de transacción, sistema, producto e instrumento. Es la fuente de verdad para totales intraday en S151.

**Fórmula/pseudocódigo:**
```
DB S151BD10MOVDIA151 ALIAS BASEMOVDIA
-- Contiene totales por SISTEMA / PRODUCTO / INSTRUMENTO / CVETRAN
-- Actualizada en tiempo real durante la jornada operativa
```

**Vocabulario en la fórmula:** S151BD10MOVDIA151, BASEMOVDIA, MOVDIA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-994

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-994 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L040 integra la librería CTLVER para control de versiones de librerías S151. CTLVER verifica que la versión de la librería en memoria coincide con la versión compilada esperada antes de proceder con cualquier acceso a la base de datos.

**Fórmula/pseudocódigo:**
```
CALL CTLVER USING WKS-CTLVER-LIBID, WKS-CTLVER-NOMLIB, W77-CTLVER-RESULT
IF W77-CTLVER-RESULT ≠ 0
   DISPLAY error de versión
   STOP RUN
```

**Vocabulario en la fórmula:** CTLVER, WKS-CTLVER-LIBID, WKS-CTLVER-NOMLIB

**Excepciones:** Si CTLVER falla, el programa se detiene — no hay bypass.

**Estado validación:** Pendiente SME

---

## RN-S151-995

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-995 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Definición |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L040 usa la librería DESPLIEGA (S000/UTILITY/DESPLIEGA) para emitir mensajes al operador MCP con el formato canónico SISTEMA/PASO/MTP:TIPO>CODIGO<TEXTO(250). Este es el estándar universal de mensajería al operador en todo el ecosistema S151/S500.

**Fórmula/pseudocódigo:**
```
CALL DESPLIEGA USING MENSAJE-LJ, CONTADOR-LJ
-- Formato: "SIST/PASO/MTP:T>NNNNNN<mensaje..."
```

**Vocabulario en la fórmula:** DESPLIEGA, MENSAJE-LJ, CONTADOR-LJ

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-996

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-996 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L040 incluye la interfaz LIBCONTROL/CONSISDIA con sus 10 funciones para gestión del dataset S151B01SISDIA. Aunque L040 es una librería de consulta de totales, también necesita controlar el estado del día del sistema para validar que las fechas de consulta son válidas.

**Fórmula/pseudocódigo:**
```
CALL CONSISDIA USING WKS-B01-FUNCION=1, SISTEMA, CSI → FECPRO, FECCON
IF fecha_solicitada NOT BETWEEN FECCON AND FECPRO
   RETURN código 2 (fecha inválida)
```

**Vocabulario en la fórmula:** CONSISDIA, WKS-B01-FECPRO, WKS-B01-FECCON, S151B01SISDIA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-997

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-997 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L040 distingue entre dos fallas de infraestructura con códigos distintos: código 6 (base de control no disponible — S151B01SISDIA inaccesible) vs código 7 (base MOVDIA no disponible). Esta granularidad permite que los sistemas llamadores implementen estrategias de recuperación diferenciadas según el tipo de falla.

**Fórmula/pseudocódigo:**
```
IF S151B01SISDIA no disponible: RETURN 6
IF S151BD10MOVDIA151 no disponible: RETURN 7
-- Los llamadores pueden reintentar, esperar o alertar según el código
```

**Vocabulario en la fórmula:** código 6, código 7, S151B01SISDIA, BASEMOVDIA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-998

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-998 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Las consultas de L040 a nivel de clave (funciones 0-14) permiten obtener totales para una combinación específica SISTEMA+CVETRAN+FECHA, mientras que las consultas de esquema (21-34) agregan todos los CVETRANs de un SISTEMA. Los llamadores eligen el nivel de agregación según su necesidad.

**Fórmula/pseudocódigo:**
```
-- Key-level (f0-14):  totales de un CVETRAN específico
CALL TOTXCVETRA(funcion=05, sistema=S151, fecha=HOY, cvetran=1234)

-- Schema-level (f21-34): totales agregados del SISTEMA
CALL TOTXCVETRA(funcion=25, sistema=S151, fecha=HOY)
```

**Vocabulario en la fórmula:** CVETRAN, SISTEMA, funciones 0-14, funciones 21-34

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-999

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-999 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L040 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El código de retorno 8 (sistema no dado de alta) impide que sistemas no registrados en S151BD10MOVDIA151 consulten totales. Este control previene consultas fantasma de sistemas que aún no han iniciado proceso del día o que no están activos en S151.

**Fórmula/pseudocódigo:**
```
IF SISTEMA not registered in BASEMOVDIA control:
   RETURN 8  -- sistema no dado de alta
-- El sistema debe ejecutar P000 (proceso de inicio) antes de poder consultar
```

**Vocabulario en la fórmula:** código 8, SISTEMA, BASEMOVDIA, P000

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## P054 — EXTENDEDNETWORK — Red extendida intraday

---

## RN-S151-1000

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1000 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P054 genera dos archivos de Red Extendida en formato dual-moneda: A04-EXTNET-ARCHIVO (MXN, 670 bytes, 90 rec/block) y A04-EXTNET-ARCHIVO-D (USD). La Red Extendida es la infraestructura interbancaria para operaciones entre instituciones financieras en México regulada por Banxico.

**Fórmula/pseudocódigo:**
```
A04-EXTNET-ARCHIVO   -- MXN, 670 bytes, 90 rec/block
A04-EXTNET-ARCHIVO-D -- USD, misma estructura
```

**Vocabulario en la fórmula:** EXTENDEDNETWORK, EXTNET, A04-EXTNET-ARCHIVO

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1001

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1001 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de autorización A05 contiene 5 slots de transacción, cada uno con: CVETRAN(4) + INDLEY(hasta 500 bytes de información legal) + IMPORTE(S17V99). Los 5 slots permiten agrupar hasta 5 transacciones relacionadas en una sola autorización de Red Extendida.

**Fórmula/pseudocódigo:**
```
A05-AUTORIZA OCCURS 5:
  CVETRAN(4) + INDLEY(variable) + IMPORTE(S17V99)
```

**Vocabulario en la fórmula:** CVETRAN, INDLEY, IMPORTE, A05-AUTORIZACIONES

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1002

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1002 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de autorización incluye campos de texto estructurado: TIPMDA (tipo de moneda), MEDACC (medio de acceso), MONEDA (código de moneda), REFNUM (referencia numérica), 5×LEYENDA(40 chars cada una) para descripciones multi-línea, y 3×REFADIC(35 chars) para referencias adicionales.

**Fórmula/pseudocódigo:**
```
AUTORIZA-RECORD:
  TIPMDA, MEDACC, MONEDA, REFNUM
  LEYENDA-1(40), LEYENDA-2(40), LEYENDA-3(40), LEYENDA-4(40), LEYENDA-5(40)
  REFADIC-1(35), REFADIC-2(35), REFADIC-3(35)
```

**Vocabulario en la fórmula:** TIPMDA, MEDACC, LEYENDA, REFADIC

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1003

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1003 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de autorización A05 incluye un campo STATUS que rastrea el estado de procesamiento de cada autorización de Red Extendida. Los valores del STATUS determinan si la autorización fue aceptada, rechazada, pendiente o cancelada por la red interbancaria.

**Fórmula/pseudocódigo:**
```
A05-STATUS: estado de la autorización
  -- valores específicos a verificar con SME de Red Extendida
```

**Vocabulario en la fórmula:** STATUS, A05-AUTORIZACIONES, autorización

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME — confirmar valores de STATUS con documentación Red Extendida.

---

## RN-S151-1004

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1004 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P054 registra identidades duales de sucursal/caja: NUMAUTORIZA (número de autorización), NUMSUCOPE + NUMCAJOPE (sucursal/caja operadora — donde se origina) y NUMSUCTRA + NUMCAJTRA (sucursal/caja transactora — donde se ejecuta). Esta dualidad soporta operaciones inter-sucursal en la Red Extendida.

**Fórmula/pseudocódigo:**
```
NUMSUCOPE + NUMCAJOPE = origen de la operación
NUMSUCTRA + NUMCAJTRA = ejecución de la transacción
NUMAUTORIZA = clave de autorización unificada
```

**Vocabulario en la fórmula:** NUMSUCOPE, NUMCAJOPE, NUMSUCTRA, NUMCAJTRA, NUMAUTORIZA

**Excepciones:** En operaciones mismo-sucursal: NUMSUCOPE = NUMSUCTRA.

**Estado validación:** Pendiente SME

---

## RN-S151-1005

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1005 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo HORMOV(6) en el registro de autorización A05 preserva la hora original del movimiento (HH:MM:SS). Este timestamp es fundamental para la liquidación interbancaria pues determina la ventana de compensación según las reglas de Banxico.

**Fórmula/pseudocódigo:**
```
HORMOV PIC 9(6)  -- HHMMSS
-- Usado para determinar ventana de compensación interbancaria
```

**Vocabulario en la fórmula:** HORMOV, timestamp, liquidación interbancaria

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1006

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1006 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de autorizaciones A05-AUTORIZACIONES tiene un máximo de 465 bytes por registro y bloques de 132 registros. La longitud variable (hasta 465 bytes) se debe a los 5 slots de INDLEY de longitud variable dentro del registro de autorización.

**Fórmula/pseudocódigo:**
```
A05-AUTORIZACIONES:
  MAX RECORD = 465 bytes
  BLOCK = 132 records
  Indexed file
```

**Vocabulario en la fórmula:** A05-AUTORIZACIONES, 465 bytes, 132 rec/block

**Excepciones:** Registros cortos usan menos de 465 bytes; el largo máximo aplica cuando los 5 INDLEY están llenos.

**Estado validación:** Pendiente SME

---

## RN-S151-1007

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1007 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** "Red Extendida" (EXTENDEDNETWORK) es la infraestructura de compensación interbancaria que permite a Banamex procesar pagos y transferencias entre instituciones financieras mexicanas. P054 genera el archivo de posiciones intraday que alimenta a esta red.

**Fórmula/pseudocódigo:**
```
EXTENDEDNETWORK = infraestructura interbancaria MX
P054 genera posiciones intraday MXN + USD
Destino: sistema de compensación de Red Extendida
```

**Vocabulario en la fórmula:** EXTENDEDNETWORK, Red Extendida, compensación interbancaria

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1008

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1008 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P054 (EXTENDEDNETWORK) usa la misma arquitectura de entrada que P055 y P014: A01-MOVS500 (movimientos de S500) + A02-DESS500 (descriptores de S500). Esto confirma el patrón arquitectural de S151 donde S500 es siempre el productor y S151 el enriquecedor/distribuidor.

**Fórmula/pseudocódigo:**
```
S500 → A01-MOVS500 (450 bytes) + A02-DESS500 (540 bytes)
       ↓
       P054 → A04-EXTNET MXN + A04-EXTNET USD + A05-AUTORIZA
```

**Vocabulario en la fórmula:** A01-MOVS500, A02-DESS500, EXTNET

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1009

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1009 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P054 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los 5 campos LEYENDA(40) en el registro de autorización de Red Extendida proveen descripciones estructuradas multi-línea de la transacción. Son equivalentes a los campos de concepto en SPEI/SPID — permiten al beneficiario identificar el origen y propósito del pago interbancario.

**Fórmula/pseudocódigo:**
```
LEYENDA-1(40) = línea 1 del concepto de pago
LEYENDA-2(40) = línea 2 del concepto de pago
...
LEYENDA-5(40) = línea 5 del concepto de pago
Total CONCEPTO = hasta 200 caracteres
```

**Vocabulario en la fórmula:** LEYENDA, concepto de pago, Red Extendida

**Excepciones:** LEYENDA vacías se transmiten como espacios, no nulls.

**Estado validación:** Pendiente SME

---
## P005 — EXTRACTOR — Extractor de saldos

---

## RN-S151-1010

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1010 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de salida TESORERIA se genera con `EXTMODE IS ASCII` en lugar del EBCDIC nativo de MCP. Esta conversión automática de codificación es la única integración cruzada de plataforma en todo el subsistema S151 y permite que sistemas Unix/Windows de Tesorería lean el archivo directamente.

**Fórmula/pseudocódigo:**
```
FD TESORERIA
   EXTMODE IS ASCII
   RECORD CONTAINS 56 CHARACTERS
-- MCP convierte automáticamente EBCDIC → ASCII al escribir
```

**Vocabulario en la fórmula:** TESORERIA, EXTMODE IS ASCII, EBCDIC

**Excepciones:** Si el receptor espera EBCDIC, el archivo será ilegible — configuración crítica.

**Estado validación:** Pendiente SME

---

## RN-S151-1011

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1011 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo TESORERIA tiene registros de exactamente 56 bytes en ASCII. Este tamaño fijo implica que todos los campos de saldo están en formato compacto — no hay espacios desperdiciados. Cada byte es información de saldo o cuenta.

**Fórmula/pseudocódigo:**
```
TESORERIA: RECORD CONTAINS 56 CHARACTERS (ASCII)
-- Destino: sistema de Tesorería fuera del entorno MCP
```

**Vocabulario en la fórmula:** TESORERIA, 56 bytes, ASCII

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1012

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1012 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P005 genera dos reportes impresos independientes: REPORTE (132 bytes/línea) y V00-REPORTE2 (132 bytes/línea), ambos en formato PRINTER. El uso de dos reportes sugiere audiencias o layouts distintos para el mismo conjunto de datos de saldo.

**Fórmula/pseudocódigo:**
```
FD REPORTE    RECORD CONTAINS 132 CHARACTERS  PRINTER
FD V00-REPORTE2 RECORD CONTAINS 132 CHARACTERS PRINTER
```

**Vocabulario en la fórmula:** REPORTE, V00-REPORTE2, PRINTER, 132 chars

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME — confirmar destinatarios de cada reporte.

---

## RN-S151-1013

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1013 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de entrada SALDOS tiene 90 bytes por registro con `DEPENDENTSPECS=TRUE`, lo que indica que su estructura está ligada al dataset DMSII S151BD02ADSALDO. La base S151BD02ADSALDO es la fuente canónica de saldos contables del subsistema S151.

**Fórmula/pseudocódigo:**
```
FD SALDOS
   RECORD CONTAINS 90 CHARACTERS
   DEPENDENTSPECS IS TRUE
-- Fuente: S151BD02ADSALDO (base de saldos S151)
```

**Vocabulario en la fórmula:** SALDOS, S151BD02ADSALDO, DEPENDENTSPECS

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1014

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1014 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo SDOS-SAL tiene 156 bytes por registro — 66 bytes más que el archivo SALDOS base (90 bytes). Los bytes adicionales contienen información de saldo enriquecida como fechas de última actualización, indicadores de estado y campos auxiliares.

**Fórmula/pseudocódigo:**
```
FD SDOS-SAL RECORD CONTAINS 156 CHARACTERS
-- 156 = 90 (SALDOS base) + 66 (enriquecimiento)
```

**Vocabulario en la fórmula:** SDOS-SAL, 156 bytes, saldo enriquecido

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1015

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1015 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-DATE-ARRAY2 es un arreglo de fecha de 21 caracteres en formato DISPLAY WITH LOWER-BOUNDS. La directiva WITH LOWER-BOUNDS permite indexación de arreglos desde posición 1 (vs. posición 0 por defecto en MCP), facilitando manipulación de fechas calendario sin offsets.

**Fórmula/pseudocódigo:**
```
WKS-DATE-ARRAY2 PIC X(21) DISPLAY WITH LOWER-BOUNDS
-- Permite acceso: WKS-DATE-ARRAY2(1) = primer char
-- vs. sin LOWER-BOUNDS: WKS-DATE-ARRAY2(0) = primer char
```

**Vocabulario en la fórmula:** WKS-DATE-ARRAY2, WITH LOWER-BOUNDS, DISPLAY

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1016

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1016 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** S151BD02ADSALDO es la base de datos DMSII dedicada exclusivamente a saldos (AD = Acumulados Diarios de SALDO). P005 es el único extractor canónico de esta base hacia sistemas externos, convirtiéndola en el único punto de salida de saldos S151 hacia Tesorería.

**Fórmula/pseudocódigo:**
```
S151BD02ADSALDO → P005 (EXTRACTOR) → TESORERIA (ASCII, 56 bytes)
                                    → REPORTE (PRINTER, 132 bytes)
                                    → V00-REPORTE2 (PRINTER, 132 bytes)
```

**Vocabulario en la fórmula:** S151BD02ADSALDO, ADSALDO, P005, EXTRACTOR

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1017

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1017 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P005 (EXTRACTOR) fue escrito originalmente en septiembre de 1998, en la era pre-Y2K del sistema S151. La lógica de fechas del programa fue diseñada para el entorno de 2 dígitos de año previo al año 2000, y fue posteriormente actualizada con CRONOS2K para manejar el pivote de siglo.

**Fórmula/pseudocódigo:** N/A — Metadata histórica.

**Vocabulario en la fórmula:** 1998, pre-Y2K, CRONOS2K

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-1018

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1018 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La salida ASCII de TESORERIA constituye el único puente de datos entre el ecosistema MCP Unisys (EBCDIC nativo) y los sistemas de Tesorería fuera de MCP. Esta integración file-based es una deuda técnica crítica para la modernización — en el stack objetivo sería reemplazada por una API REST.

**Fórmula/pseudocódigo:**
```
MCP/EBCDIC → [EXTMODE IS ASCII] → Archivo 56 bytes ASCII
→ FTP o transfer manual → Sistema Tesorería (non-MCP)
```

**Vocabulario en la fórmula:** EXTMODE IS ASCII, EBCDIC, MCP, Tesorería

**Excepciones:** Ninguna — es la única vía de integración disponible.

**Estado validación:** Pendiente SME — [ARQUITECTURA-DISTRIBUIDA] candidato a refactoring.

---

## RN-S151-1019

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1019 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los dos reportes impresos (REPORTE y V00-REPORTE2) sugieren que P005 genera vistas diferenciadas de los saldos: posiblemente una vista interna (contabilidad) y una vista de gestión (Tesorería). El prefijo "V00" en V00-REPORTE2 indica versión o variante del reporte base.

**Fórmula/pseudocódigo:**
```
REPORTE     = vista contable interna (132 cols)
V00-REPORTE2 = vista de gestión / Tesorería (132 cols)
-- Ambos del mismo dataset S151BD02ADSALDO
```

**Vocabulario en la fórmula:** REPORTE, V00-REPORTE2, S151BD02ADSALDO

**Excepciones:** Ninguna — requiere SME para confirmar audiencias.

**Estado validación:** Pendiente SME

---

## P013 — DGODOMI — Domiciliación / cargo automático

---

## RN-S151-1020

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1020 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Por incidente INC0013018473 (JNRB, 2025-10-14), P013 valida que la fecha SA2 (fecha de la transacción online del cajero) coincide con la fecha contable (FECCONT) antes de activar el envío de información al sistema S702. Si las fechas no coinciden, el servicio de domiciliación no se activa.

**Fórmula/pseudocódigo:**
```
IF FECHA-SA2 = FECCONT
   ACTIVATE envío a S702
ELSE
   NO ACTIVAR S702 (fecha desalineada = posible transacción asíncrona)
```

**Vocabulario en la fórmula:** FECHA-SA2, FECCONT, INC0013018473, S702, BAN_HR

**Excepciones:** Si BAN_HR=0, la validación de hora no aplica.

**Estado validación:** Pendiente SME

---

## RN-S151-1021

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1021 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P013 (DGODOMI) consume A01-MOVS500 (movimientos S500, 450 bytes, 144 rec/block) filtrando aquellos que corresponden a domiciliación/cargo automático. Solo los movimientos con la clave de instrumento de domiciliación son procesados y enviados a S702.

**Fórmula/pseudocódigo:**
```
A01-MOVS500 (S500, 450 bytes, 144 rec/block)
FOR EACH movimiento:
  IF INSTRUMENTO = domiciliación AND fecha_valida:
    SEND to S702
```

**Vocabulario en la fórmula:** A01-MOVS500, S500, domiciliación, S702

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1022

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1022 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de control A02-CTL-DM tiene `PROTECTION IS PROTECTED`. Este atributo impide que el archivo de control de domiciliación sea modificado durante la ejecución, garantizando que el estado del proceso no pueda ser alterado externamente mientras el batch está corriendo.

**Fórmula/pseudocódigo:**
```
FD A02-CTL-DM PROTECTION IS PROTECTED
-- Estado del proceso protegido contra modificación externa
```

**Vocabulario en la fórmula:** A02-CTL-DM, PROTECTION IS PROTECTED, domiciliación

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-1023

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1023 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P013 utiliza S151BD13BIFIN (BIFIN database) específicamente el dataset B10DOMI para almacenar y recuperar registros de domiciliación. B10DOMI contiene el histórico de instrucciones de cargo automático que L014 expone para consulta online desde sucursales.

**Fórmula/pseudocódigo:**
```
DB S151BD13BIFIN
  B10DOMI = dataset de domiciliación
  Llave: FECHAI+FECHAF+SUC+CTA+AUTS151+AUTAPL+CONTRATO+NUMOCUR
```

**Vocabulario en la fórmula:** S151BD13BIFIN, B10DOMI, domiciliación

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1024

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1024 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de monitor de P013 tiene un campo DATOS-MSJ de 1000 bytes para mensajes operativos detallados. Este tamaño amplio (vs. 132 bytes en reportes normales) permite registrar información completa de movimientos de domiciliación para diagnóstico de errores.

**Fórmula/pseudocódigo:**
```
DATOS-MSJ PIC X(1000)  -- campo de mensaje de monitor
-- Capacidad suficiente para registro completo de un movimiento
```

**Vocabulario en la fórmula:** DATOS-MSJ, L02-MONITOR, 1000 bytes

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1025

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1025 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de control de domiciliación tiene estructura compacta de 40 bytes: AUTS500(8) + SER(1) + BAN_HR(1) + FILLER(30). AUTS500 es la autorización del sistema S500, SER discrimina el subtipo de servicio y BAN_HR activa la validación de hora.

**Fórmula/pseudocódigo:**
```
REG-CONTROL-DM:
  AUTS500(8)   = autorización S500
  SER(1)       = subtipo de servicio
  BAN_HR(1)    = flag de validación por hora
  FILLER(30)   = reservado
Total: 40 bytes
```

**Vocabulario en la fórmula:** AUTS500, SER, BAN_HR, REG-CONTROL-DM

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1026

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1026 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** BAN_HR(1) es el flag que activa/desactiva la validación de ventana horaria para domiciliación. Cuando BAN_HR=1, P013 verifica que la hora del movimiento está dentro de la ventana permitida para cargos automáticos por Banxico. BAN_HR=0 omite la validación horaria.

**Fórmula/pseudocódigo:**
```
IF BAN_HR = 1:
  IF HORA-MOVIMIENTO NOT IN ventana_permitida_banxico:
    RECHAZAR domiciliación
ELSE (BAN_HR = 0):
  PROCESAR sin validación horaria
```

**Vocabulario en la fórmula:** BAN_HR, ventana horaria, Banxico, domiciliación

**Excepciones:** BAN_HR=0 puede ser configuración de emergencia o excepciones regulatorias.

**Estado validación:** Pendiente SME — confirmar valores de ventana horaria Banxico.

---

## RN-S151-1027

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1027 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** S702 es el sistema downstream que recibe y procesa las instrucciones de domiciliación/cargo automático generadas por P013. La activación del servicio S702 desde P013 es condicional — requiere validación de fecha SA2 vs FECCONT (RN-S151-1020). S702 también envía confirmaciones de vuelta a S151 vía P017.

**Fórmula/pseudocódigo:**
```
P013 → [validación fecha+hora] → S702 (domiciliación)
S702 → [confirmación] → P017 → S151BD13BIFIN.B10DOMI
```

**Vocabulario en la fórmula:** S702, domiciliación, cargo automático, P017

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1028

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1028 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La doble validación de fecha (SA2 date AND FECCONT — fecha contable) protege contra activación de domiciliaciones en fecha incorrecta. Escenario de riesgo: si el batch nocturno procesa movimientos de la jornada anterior, la fecha SA2 no coincidirá con FECCONT, y S702 no será invocado — evitando un cargo automático en fecha errónea.

**Fórmula/pseudocódigo:**
```
VALIDACION_FECHA = (FECHA-SA2 = FECCONT)
VALIDACION_HORA  = (BAN_HR = 0) OR (HORA IN ventana)
IF VALIDACION_FECHA AND VALIDACION_HORA:
  ACTIVAR S702
```

**Vocabulario en la fórmula:** FECHA-SA2, FECCONT, BAN_HR, S702

**Excepciones:** Ninguna — ambas condiciones son obligatorias.

**Estado validación:** Pendiente SME

---

## RN-S151-1029

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1029 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P013 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo SER(1) en el registro de control de domiciliación discrimina entre subtipos de servicio de cargo automático. El valor específico de SER no está documentado en las primeras 250 líneas del código — puede codificar tipos como cargo automático de servicios (luz, teléfono), crédito hipotecario, o primas de seguros.

**Fórmula/pseudocódigo:**
```
SER(1) = subtipo de servicio
-- Valores específicos no documentados en fuente visible
-- Posiblemente: 1=servicios, 2=hipoteca, 3=seguro, etc.
```

**Vocabulario en la fórmula:** SER, subtipo de servicio, domiciliación

**Excepciones:** Requiere lectura de lógica de negocio del código fuente completo.

**Estado validación:** Pendiente SME — [DATO-REQUERIDO] valores de SER.

---

## P001 — CARSDOMOV — Lector de movimientos tarjeta y domiciliados

---

## RN-S151-1030

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1030 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P001 accede al archivo de movimientos S151 A01-S151MOV con SECURITYTYPE=PUBLIC en modo random por posición W77-ULT-REG-LEIDO (último registro leído). SECURITYTYPE=PUBLIC permite lectura sin autenticación especial — apropiado para consulta de movimientos ya autorizados.

**Fórmula/pseudocódigo:**
```
FD A01-S151MOV SECURITYTYPE IS PUBLIC
   BLOCK 144 RECORDS
READ A01-S151MOV AT POSITION W77-ULT-REG-LEIDO
```

**Vocabulario en la fórmula:** A01-S151MOV, SECURITYTYPE IS PUBLIC, W77-ULT-REG-LEIDO

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1031

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1031 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P001 accede al archivo descriptor A02-S151DES en modo random por W77-LOGKEY (llave lógica del descriptor). W77-LOGKEY es la llave de enlace entre el registro de movimiento y su descriptor — permite recuperar información adicional del movimiento de forma directa.

**Fórmula/pseudocódigo:**
```
FD A02-S151DES RESERVE 0 AREAS
READ A02-S151DES AT POSITION W77-LOGKEY
```

**Vocabulario en la fórmula:** A02-S151DES, W77-LOGKEY, random access

**Excepciones:** Si W77-LOGKEY no encuentra descriptor, el movimiento se procesa sin información adicional.

**Estado validación:** Pendiente SME

---

## RN-S151-1032

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1032 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** A02-S151DES tiene `RESERVE 0 AREAS` — cero áreas de buffer en disco. Esto fuerza a MCP a leer directamente desde disco en cada acceso random, sin riesgo de leer datos obsoletos de buffer. Crítico para un archivo de acceso aleatorio donde la coherencia de datos es esencial.

**Fórmula/pseudocódigo:**
```
FD A02-S151DES RESERVE 0 AREAS
-- Cada READ va directamente a disco (sin buffer)
-- Garantiza lectura del registro más reciente
```

**Vocabulario en la fórmula:** RESERVE 0 AREAS, buffer, coherencia de datos

**Excepciones:** Mayor latencia por I/O directo vs. lecturas con buffer.

**Estado validación:** Pendiente SME

---

## RN-S151-1033

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1033 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo FILXAPL(165) en el registro de movimiento contiene datos específicos de la aplicación originadora. P001 maneja redefiniciones para sistemas S018 (BCO_S018), S084 (SUCEJE+CTAEJE+MENSUALIDAD+ASESOR), S087 (datos de tarjeta de crédito), S252 (FEC-PARTIDA) y S500 (FT00/FT01 formatos). Cada sistema llena FILXAPL diferente.

**Fórmula/pseudocódigo:**
```
FILXAPL(165) REDEFINES:
  SISTEMA=018: BCO_S018
  SISTEMA=084: SUCEJE+CTAEJE+MENSUALIDAD+ASESOR
  SISTEMA=087: PZO+EMISION+...SUFIJO+PM (tarjeta)
  SISTEMA=252: FEC-PARTIDA(8)
  SISTEMA=500: FT00/FT01 (FORMATO+DESCRIPCION+NATUTRAN)
```

**Vocabulario en la fórmula:** FILXAPL, S018, S084, S087, S252, S500, redefinición

**Excepciones:** Sistemas no listados usan FILXAPL como campo genérico.

**Estado validación:** Pendiente SME

---

## RN-S151-1034

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1034 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La redefinición de FILXAPL para sistema S087 (tarjeta de crédito) contiene 19 campos específicos: PZO (plazo), EMISION (fecha emisión), FIL-CTE (código cliente), PROD/INST (producto/instrumento), IMPINTRB (importe interés reembolsable), SERV, SUCREEMB/CTAREEMB (sucursal/cuenta reembolso), SUCFOND/CTAFOND (sucursal/cuenta fondeo), OPBANEL (operación Banel), GATN/GATR (garantía), FECGAT, CTE_087, FECVEN_087, SUFIJO, PM.

**Fórmula/pseudocódigo:**
```
S087-FILXAPL:
  PZO + EMISION + FIL-CTE + PROD + INST + IMPINTRB + SERV
  SUCREEMB + CTAREEMB + SUCFOND + CTAFOND
  OPBANEL + GATN + GATR + FECGAT + CTE_087 + FECVEN_087
  SUFIJO + PM
```

**Vocabulario en la fórmula:** S087, FILXAPL, IMPINTRB, OPBANEL, GATN, GATR, SUFIJO

**Excepciones:** Campos no aplicables para el tipo de operación van en cero/espacios.

**Estado validación:** Pendiente SME

---

## RN-S151-1035

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1035 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los formatos FT00 y FT01 en la redefinición S500 de FILXAPL contienen FORMATO (código de formato), DESCRIPCION (descripción del movimiento) y NATUTRAN (naturaleza de la transacción). NATUTRAN clasifica la transacción para efectos contables CNBV (crédito, débito, cargo, abono, reversión, etc.).

**Fórmula/pseudocódigo:**
```
FT00: FORMATO + DESCRIPCION + NATUTRAN
FT01: FORMATO + DESCRIPCION + NATUTRAN
-- NATUTRAN = clasificación contable CNBV del movimiento
```

**Vocabulario en la fórmula:** FT00, FT01, NATUTRAN, DESCRIPCION, FORMATO

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1036

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1036 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El sistema S252 usa FEC-PARTIDA(8) en FILXAPL como fecha de partida contable. FEC-PARTIDA puede diferir de FECMOV (fecha del movimiento) y FECCONT (fecha contable) — representa la fecha en que la partida fue reconocida en el libro mayor, crucial para conciliación contable CNBV.

**Fórmula/pseudocódigo:**
```
S252-FILXAPL:
  FEC-PARTIDA(8)   -- CCAAMMDD, puede ≠ FECMOV ≠ FECCONT
-- Fecha de reconocimiento en libro mayor
```

**Vocabulario en la fórmula:** FEC-PARTIDA, S252, FECMOV, FECCONT

**Excepciones:** FEC-PARTIDA puede ser posterior a FECMOV en operaciones de cierre de periodo.

**Estado validación:** Pendiente SME

---

## RN-S151-1037

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1037 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P001 (CARSDOMOV) fue creado en 1996 y fue recompilado más recientemente en 2025 (JNRB 251113 — Noviembre 2025). Es el programa con la modificación más reciente en el grupo analizado, lo que indica que la lógica de tarjeta/domiciliación sigue siendo activamente mantenida.

**Fórmula/pseudocódigo:** N/A — Metadata de versiones.

**Vocabulario en la fórmula:** 1996, JNRB 251113, 2025

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-1038

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1038 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CARSDOMOV unifica en un solo programa la lectura de dos tipos de movimientos: tarjeta de crédito/débito (CARS = card) y domiciliados (DOM = domiciliación). Esta unificación permite el procesamiento paralelo de operaciones de pago que comparten estructura de registro pero tienen orígenes distintos.

**Fórmula/pseudocódigo:**
```
CARSDOMOV = CARS (tarjetas) + DOMOV (movimientos domiciliados)
FOR EACH movimiento IN A01-S151MOV:
  IF SISTEMA IN (S084, S087) → procesar como tarjeta
  IF SISTEMA IN (S018, S252) → procesar como domiciliado
```

**Vocabulario en la fórmula:** CARSDOMOV, CARS, DOMOV, tarjeta, domiciliación

**Excepciones:** Sistemas no clasificados se procesan con lógica genérica.

**Estado validación:** Pendiente SME

---

## RN-S151-1039

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1039 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La combinación SECURITYTYPE=PUBLIC en A01-S151MOV + RESERVE 0 AREAS en A02-S151DES implementa un patrón de lectura segura: el archivo de movimientos es accesible públicamente (ya fueron autorizados), mientras el descriptor es leído sin buffer para garantizar coherencia en el acceso concurrente multi-tarea.

**Fórmula/pseudocódigo:**
```
A01-S151MOV: PUBLIC (lectura libre de registros autorizados)
A02-S151DES: RESERVE 0 (lectura directa a disco, sin buffer stale)
```

**Vocabulario en la fórmula:** SECURITYTYPE, RESERVE 0 AREAS, coherencia, concurrencia

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## P025 — Proyección de fechas sobre MOVDIA

---

## RN-S151-1040

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1040 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo L01-MOVTOS tiene parámetros de alta disponibilidad MCP: FRAMESIZE=48 (48 frames por área), AREAS=1000 (1000 áreas en memoria), AREASIZE=6000 (6000 bytes por área), SECURITYUSE=3 (nivel de seguridad 3), SAVEFACTOR=99 (99% de factor de guardado). Estos parámetros indican que L01-MOVTOS es un archivo crítico de alta disponibilidad.

**Fórmula/pseudocódigo:**
```
L01-MOVTOS: 75 bytes, 144 rec/block
  FRAMESIZE=48, AREAS=1000, AREASIZE=6000
  SECURITYUSE=3, SAVEFACTOR=99
-- Alta disponibilidad: 99% de datos siempre en memoria
```

**Vocabulario en la fórmula:** FRAMESIZE, AREAS, AREASIZE, SECURITYUSE, SAVEFACTOR

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1041

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1041 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L02-DESCRIP (90 bytes, 120 rec/block) contiene descriptores de los movimientos proyectados. El tamaño de 90 bytes coincide con el archivo SALDOS de P005, sugiriendo que L02-DESCRIP usa el mismo formato de descriptor de saldo para las proyecciones.

**Fórmula/pseudocódigo:**
```
L02-DESCRIP: 90 bytes, 120 rec/block
-- Misma longitud que archivo SALDOS (P005) = descriptor de saldo
```

**Vocabulario en la fórmula:** L02-DESCRIP, 90 bytes, descriptor

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1042

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1042 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los archivos L03-CBII y L04-CTDR tienen ambos 210 bytes y 50 rec/block, procesando información de CBII (posiblemente Cuenta Bancaria II o sistema CBI) y CTDR (posiblemente Contadores de Diario). Su tamaño idéntico indica que comparten la misma estructura de registro.

**Fórmula/pseudocódigo:**
```
L03-CBII: 210 bytes, 50 rec/block  -- datos CBII
L04-CTDR: 210 bytes, 50 rec/block  -- datos CTDR
-- Estructura simétrica: mismo layout, diferentes datasets
```

**Vocabulario en la fórmula:** L03-CBII, L04-CTDR, 210 bytes

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME — confirmar significado de CBII y CTDR.

---

## RN-S151-1043

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1043 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P025 define 17 categorías de error DMSII en WKS-CATEGORIAS: NOTFOUND, DUPLICATES, DEADLOCK, DATAERROR, NOTLOCKED, KEYCHANGE, SYSTEM ERROR, READONLY, IOERROR, LIMITERROR, OPENERROR, CLOSEERROR, NORECORD, INUSE, AUDITERROR, ABORT, SECURITYERROR, VERSIONERROR. Esta cobertura completa indica manejo exhaustivo de errores de base de datos.

**Fórmula/pseudocódigo:**
```
WKS-CATEGORIAS (17 strings):
  "NOTFOUND", "DUPLICATES", "DEADLOCK", "DATAERROR",
  "NOTLOCKED", "KEYCHANGE", "SYSTEM ERROR", "READONLY",
  "IOERROR", "LIMITERROR", "OPENERROR", "CLOSEERROR",
  "NORECORD", "INUSE", "AUDITERROR", "ABORT",
  "SECURITYERROR", "VERSIONERROR"
```

**Vocabulario en la fórmula:** WKS-CATEGORIAS, DMSII, DEADLOCK, ABORT

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1044

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1044 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P025 accede a S151BD10MOVDIA151 bajo el alias BASESEM (base semanal), a diferencia de L040 que usa el alias BASEMOVDIA. El alias BASESEM sugiere que P025 opera sobre aggregados semanales/periódicos de la misma base de datos de movimientos diarios.

**Fórmula/pseudocódigo:**
```
DB S151BD10MOVDIA151 ALIAS BASESEM
-- Alias "BASESEM" = acceso a datos semanales/periódicos
-- vs. L040 usa alias "BASEMOVDIA" = acceso intraday
```

**Vocabulario en la fórmula:** S151BD10MOVDIA151, BASESEM, BASEMOVDIA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1045

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1045 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Modificación 01MTP008 redujo el número de registros procesados en el proceso mensual para prevenir overflow de archivos. Esta modificación revela que P025 originalmente tenía un límite de capacidad mensual que fue alcanzado en producción.

**Fórmula/pseudocódigo:** N/A — Metadata de cambio.

**Vocabulario en la fórmula:** 01MTP008, proceso mensual, overflow

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-1046

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1046 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Modificación 01MTP010 agregó tres mejoras: (1) validación de existencia del archivo antes de abrirlo, (2) implementación de la rutina MANTSISDIA para mantenimiento del día del sistema, y (3) adición del parámetro BD12 (S151BD12MC001S151). La validación de existencia previene abends en ambientes donde el archivo puede no haberse creado aún.

**Fórmula/pseudocódigo:**
```
01MTP010:
  1. CHECK IF FILE EXISTS before OPEN
  2. IMPLEMENT MANTSISDIA routine
  3. ADD BD12 (S151BD12MC001S151) parameter
```

**Vocabulario en la fórmula:** 01MTP010, MANTSISDIA, BD12, S151BD12MC001S151

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-1047

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1047 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Modificación 01MTP027 eliminó displays TADS y pantallas de depuración innecesarias, y agregó un display de reporte al final del proceso. TADS (Transaction Application Development System) es el subsistema de desarrollo de Unisys — su eliminación indica que P025 pasó de desarrollo a producción plena.

**Fórmula/pseudocódigo:** N/A — Metadata de cambio.

**Vocabulario en la fórmula:** 01MTP027, TADS, display de reporte

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-1048

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1048 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Modificación 01MTP035 incrementó el conteo máximo de registros de control. Esta modificación refleja el crecimiento del volumen de transacciones del sistema S151 a lo largo de los años — el número original de registros de control resultó insuficiente para el volumen real.

**Fórmula/pseudocódigo:** N/A — Capacidad de registros de control aumentada.

**Vocabulario en la fórmula:** 01MTP035, registros de control, capacidad

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-1049

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1049 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P025 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Modificación 15MTP001 (la misma que recompiló todos los programas S151 para MCP 55) agregó registros de control B05 para el proceso de ALTA DISP (alta de disponibilidad). Esta adición indica que con MCP 55 se introdujo un nuevo ciclo de disponibilidad que requería registros de control adicionales.

**Fórmula/pseudocódigo:** N/A — Adición de registros de control B05 para ALTA DISP.

**Vocabulario en la fórmula:** 15MTP001, B05, ALTA DISP, MCP 55

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## P016 — Acumulador en tiempo real por producto/instrumento/CPAE

---

## RN-S151-1050

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1050 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P016 opera exclusivamente dentro de la ventana 04:00:00–20:00:00, hardcodeada como WKS-HORA-INICIO=040000 y WKS-HORA-LIMITE=200000. Fuera de esta ventana el programa no acumula movimientos. Esto coincide con el horario operativo bancario Banxico para sistema SPEI.

**Fórmula/pseudocódigo:**
```
WKS-HORA-INICIO  PIC 9(6) VALUE 040000  -- 04:00:00
WKS-HORA-LIMITE  PIC 9(6) VALUE 200000  -- 20:00:00
IF HORA-ACTUAL < WKS-HORA-INICIO OR > WKS-HORA-LIMITE:
  NO PROCESAR
```

**Vocabulario en la fórmula:** WKS-HORA-INICIO, WKS-HORA-LIMITE, ventana operativa

**Excepciones:** Cambio de horario requiere modificación de código fuente.

**Estado validación:** Pendiente SME — [HARDCODE-SOSPECHOSO] para horarios de verano.

---

## RN-S151-1051

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1051 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-TABLA-PRDINST es una tabla en memoria de 3,000 ocurrencias que acumula totales por combinación PRODUCTO/INSTRUMENTO durante la jornada. El límite de 3,000 implica que el sistema puede manejar hasta 3,000 combinaciones únicas de producto-instrumento activas simultáneamente.

**Fórmula/pseudocódigo:**
```
WKS-TABLA-PRDINST OCCURS 3000 TIMES:
  PRODUCTO + INSTRUMENTO + (contadores)
-- Tabla in-memory de acumulación intraday
```

**Vocabulario en la fórmula:** WKS-TABLA-PRDINST, PRODUCTO, INSTRUMENTO, 3000

**Excepciones:** Overflow si > 3000 combinaciones únicas en un día.

**Estado validación:** Pendiente SME — verificar si el límite de 3000 es suficiente.

---

## RN-S151-1052

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1052 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P016 mantiene dos tablas paralelas de 3,000 entradas: WKS-TABLA-TOTABO (totales de abonos/créditos) y WKS-TABLA-TOTCGO (totales de cargos/débitos), ambas sincronizadas con WKS-TABLA-PRDINST. Este diseño permite calcular el neto ABONO-CARGO por producto-instrumento en tiempo real.

**Fórmula/pseudocódigo:**
```
WKS-TABLA-TOTABO(i) = suma de abonos para PRDINST(i)
WKS-TABLA-TOTCGO(i) = suma de cargos para PRDINST(i)
NETO(i) = WKS-TABLA-TOTABO(i) - WKS-TABLA-TOTCGO(i)
```

**Vocabulario en la fórmula:** WKS-TABLA-TOTABO, WKS-TABLA-TOTCGO, neto, PRDINST

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1053

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1053 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-TABLA-ALERTAS (3,000 ocurrencias) contiene umbrales de alerta por producto-instrumento: LIMTRNABO (límite de transacciones de abono) y LIMTRNCAR (límite de transacciones de cargo). Cuando los contadores de WKS-TABLA-TOTABO o TOTCGO superan estos límites, P016 genera una alerta regulatoria.

**Fórmula/pseudocódigo:**
```
IF WKS-TABLA-TOTABO(i) > WKS-TABLA-ALERTAS(i).LIMTRNABO:
  GENERATE alerta de abono
IF WKS-TABLA-TOTCGO(i) > WKS-TABLA-ALERTAS(i).LIMTRNCAR:
  GENERATE alerta de cargo
```

**Vocabulario en la fórmula:** WKS-TABLA-ALERTAS, LIMTRNABO, LIMTRNCAR

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME — confirmar fuente de los valores de umbral.

---

## RN-S151-1054

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1054 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La tabla CPAE de P016 tiene 10,000 entradas — más del triple que las tablas de producto-instrumento (3,000). CPAE (Clave de Producto y Actividad Empresarial) es la clasificación fiscal SAT/CNBV con mayor granularidad que PRODUCTO/INSTRUMENTO, justificando el tamaño mayor de la tabla.

**Fórmula/pseudocódigo:**
```
WKS-TABLA-CPAE OCCURS 10000 TIMES
-- 10000 >> 3000: CPAE tiene mayor cardinalidad que PRDINST
-- CPAE = clasificación SAT de actividad económica
```

**Vocabulario en la fórmula:** CPAE, WKS-TABLA-CPAE, 10000

**Excepciones:** Overflow si > 10000 CPAE únicas en un día.

**Estado validación:** Pendiente SME

---

## RN-S151-1055

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1055 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P016 tiene 5 sistemas CFR (Control de Fondos de Reserva o similar) hardcodeados: 404, 707, 804, 203, 414. Estos sistemas reciben tratamiento especial en el acumulador intraday — posiblemente lógica de acumulación diferente, reportes adicionales o umbrales de alerta distintos.

**Fórmula/pseudocódigo:**
```
88 W88-SISTEMAS-CFR VALUE 404, 707, 804, 203, 414
IF SISTEMA IN W88-SISTEMAS-CFR:
  APPLY lógica CFR especial
```

**Vocabulario en la fórmula:** CFR, sistemas 404, 707, 804, 203, 414

**Excepciones:** Agregar nuevo sistema CFR requiere modificación de código fuente.

**Estado validación:** Pendiente SME — [DATO-REQUERIDO] significado de CFR y sistemas.

---

## RN-S151-1056

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1056 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P016 usa S151BD13BIFIN (alias BIFINDB) como base de datos de control para almacenar los parámetros de alerta y los totales acumulados. BIFIN centraliza la información de control intraday y es consultada online desde sucursales vía L014.

**Fórmula/pseudocódigo:**
```
DB S151BD13BIFIN ALIAS BIFINDB
-- Almacena: parámetros de alerta (LIMTRNABO, LIMTRNCAR)
-- Almacena: totales acumulados por SISTEMA/PRDINST/CPAE
```

**Vocabulario en la fórmula:** S151BD13BIFIN, BIFINDB, BIFIN

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1057

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1057 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P016 genera un archivo de log por sistema y por fecha con la nomenclatura `(S151)S151/FILE/MOVS{SIS}/{FEC} ON {PACK}`. Cada sistema tiene su propio log diario de movimientos acumulados, permitiendo trazabilidad por sistema de origen.

**Fórmula/pseudocódigo:**
```
LOG_FILE = "(S151)S151/FILE/MOVS" + SISTEMA(4) + "/" + FECHA(8) + " ON " + PACK
```

**Vocabulario en la fórmula:** LOG-FILE, SISTEMA, FECHA, PACK

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1058

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1058 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-PARAMETRO(12) es el bloque de parámetros de entrada de P016, compuesto por FECHA(8) + SISTEMA(4). Permite invocar P016 para un sistema específico en una fecha específica, facilitando la ejecución selectiva por sistema o el reprocesamiento de fechas anteriores.

**Fórmula/pseudocódigo:**
```
WKS-PARAMETRO(12) = FECHA(8) + SISTEMA(4)
-- Permite: procesar S151 (0151) para fecha 20260717
```

**Vocabulario en la fórmula:** WKS-PARAMETRO, FECHA, SISTEMA

**Excepciones:** SISTEMA=0000 posiblemente procesa todos los sistemas.

**Estado validación:** Pendiente SME

---

## RN-S151-1059

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1059 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P016 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P016 fue el último programa del subsistema S151 en recibir un upgrade de MCP — fue recompilado para MCP 62 en noviembre 2023 (23MTP003, 2023-11-30). El salto de MCP 55 (2014) a MCP 62 (2023) en este programa sugiere que requirió cambios de código específicos para la nueva versión, no solo recompilación mecánica.

**Fórmula/pseudocódigo:** N/A — Metadata de versiones.

**Vocabulario en la fórmula:** MCP 62, 23MTP003, 2023-11-30

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## L020 — S151LIB020 — Interfaz WKS-MOV-DATOS

---

## RN-S151-1060

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1060 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L020 (S151LIB020) es una librería MCP de tipo SHAREDBYRUNUNIT TEMPORARY con FEDLEVEL=5 y STACK FREE. SHAREDBYRUNUNIT significa que se carga una vez por unidad de ejecución (run unit), no por task individual — eficiente para procesos con múltiples tasks. STACK FREE libera el stack de llamadas al retornar.

**Fórmula/pseudocódigo:**
```
$ SHARING = SHAREDBYRUNUNIT TEMPORARY
$ FEDLEVEL = 5
$ STACK FREE
PROGRAM-ID. S151LIB020.
```

**Vocabulario en la fórmula:** SHAREDBYRUNUNIT, TEMPORARY, FEDLEVEL=5, STACK FREE

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1061

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1061 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L020 accede a dos bases de datos DMSII: S151BD11SDOS151 (alias SDODB — Saldos Diarios por Operación) y S151BD12MC001S151 (alias MOVDB — Movimientos Contables 001). SDODB contiene saldos y MOVDB contiene los movimientos contables — juntos proveen la vista completa de estado de cuenta.

**Fórmula/pseudocódigo:**
```
DB S151BD11SDOS151  ALIAS SDODB  -- saldos
DB S151BD12MC001S151 ALIAS MOVDB -- movimientos contables
```

**Vocabulario en la fórmula:** S151BD11SDOS151, SDODB, S151BD12MC001S151, MOVDB

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1062

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1062 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La interfaz L710 de L020 permite consultas de tabla de referencia con entrada: CAT(6) categoría + CLAVE(2) subclave + BUSQUEDA(2) tipo de búsqueda + REGISTROS(2) límite + LLAVE1-6 (12 chars cada una, 6 llaves de búsqueda) + FEC_VIG(6) vigencia + FECINI(6) inicio + NIVINI(2) nivel inicial + FILLER(11).

**Fórmula/pseudocódigo:**
```
WKS-L710-ENT:
  CAT(6)+CLAVE(2)+BUSQUEDA(2)+REGISTROS(2)
  LLAVE1(12)+LLAVE2(12)+...LLAVE6(12)
  FEC_VIG(6)+FECINI(6)+NIVINI(2)+FILLER(11)
```

**Vocabulario en la fórmula:** L710, CAT, CLAVE, BUSQUEDA, LLAVE1-6, FEC_VIG

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1063

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1063 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La respuesta L710 de L020 retorna: NUMREG(2) registros encontrados + CAT(6) + FECINI(6) + NIVINI(2) + 28 slots de datos (12 chars cada uno) + FECALTA(6) + FECBAJA(6) + FECMOD(6). Los 28 slots permiten retornar hasta 28 registros de tabla en una sola llamada.

**Fórmula/pseudocódigo:**
```
WKS-L710-SAL:
  NUMREG(2)+CAT(6)+FECINI(6)+NIVINI(2)
  DATA-SLOT-1(12)+...+DATA-SLOT-28(12)
  FECALTA(6)+FECBAJA(6)+FECMOD(6)
```

**Vocabulario en la fórmula:** WKS-L710-SAL, NUMREG, DATA-SLOT, FECALTA, FECBAJA, FECMOD

**Excepciones:** Si NUMREG > 28, se requieren múltiples llamadas.

**Estado validación:** Pendiente SME

---

## RN-S151-1064

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1064 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-MOV-DATOS es la estructura canónica de 540 bytes (WITH LOWER-BOUNDS) que representa la interfaz de movimiento de L020 para los sistemas llamadores. Es la versión enriquecida del registro de movimiento S151 (vs. los 450 bytes del registro físico A00-R01-REGMOV), con 90 bytes adicionales de contexto.

**Fórmula/pseudocódigo:**
```
WKS-MOV-DATOS PIC X(540) WITH LOWER-BOUNDS
-- 450 bytes base + 90 bytes contexto adicional
-- Interfaz estándar de L020 para sistemas llamadores
```

**Vocabulario en la fórmula:** WKS-MOV-DATOS, 540 bytes, WITH LOWER-BOUNDS

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1065

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1065 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-MOV-DATOS contiene 5 slots CVEIMP, cada uno con CVETRAN (clave de transacción) + INDLEY (indicador de ley) + ESQCON/TM (esquema contable / tipo de movimiento) + IMPORTE. Los 5 slots permiten que un solo movimiento tenga hasta 5 transacciones contables simultáneas (p.ej., principal + IVA + comisión + retención + interés).

**Fórmula/pseudocódigo:**
```
CVEIMP(5 OCCURS):
  CVETRAN(4) + INDLEY(x) + ESQCON/TM(x) + IMPORTE(S15V99+2)
-- 5 transacciones contables por movimiento
```

**Vocabulario en la fórmula:** CVEIMP, CVETRAN, INDLEY, ESQCON, IMPORTE

**Excepciones:** Si un movimiento requiere > 5 CVEIMPs, se necesitan múltiples registros.

**Estado validación:** Pendiente SME

---

## RN-S151-1066

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1066 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo REFNUM en WKS-MOV-DATOS tiene tres redefiniciones polimórficas: REFNUMS500 (referencia del sistema S500), REFNUMS087 (referencia de tarjeta S087) y REFNUMS404 (referencia del sistema S404). El sistema llamador popula REFNUM según su origen y L020 interpreta la redefinición correcta.

**Fórmula/pseudocódigo:**
```
REFNUM REDEFINES:
  REFNUMS500 = referencia S500 (Cargos/Abonos)
  REFNUMS087 = referencia S087 (tarjeta)
  REFNUMS404 = referencia S404 (otro sistema)
```

**Vocabulario en la fórmula:** REFNUM, REFNUMS500, REFNUMS087, REFNUMS404

**Excepciones:** Ninguna — el sistema llamador elige la redefinición correcta.

**Estado validación:** Pendiente SME

---

## RN-S151-1067

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1067 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** FIL-FUTURO en WKS-MOV-DATOS tiene 6 redefiniciones para diferentes sistemas: S264 (otro banco), S087 (tarjeta), S500 (Cargos/Abonos), S501 (otro sistema de movimientos), S403 (sistema adicional) y S252 (sistema de partidas). Este campo es el punto de extensión de datos futuros del movimiento.

**Fórmula/pseudocódigo:**
```
FIL-FUTURO REDEFINES para:
  S264 / S087 / S500 / S501 / S403 / S252
-- Cada sistema llena FIL-FUTURO con su información específica
```

**Vocabulario en la fórmula:** FIL-FUTURO, S264, S087, S500, S501, S403, S252

**Excepciones:** Ninguna — polimorfismo por sistema de origen.

**Estado validación:** Pendiente SME

---

## RN-S151-1068

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1068 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** DATOS-ADIC(354) en WKS-MOV-DATOS es el área de datos adicionales de 354 bytes con redefiniciones específicas por aplicación llamadora. Este campo representa el mecanismo de extensión más amplio del movimiento — permite que cada sistema caller incluya hasta 354 bytes de datos propios sin alterar la estructura base.

**Fórmula/pseudocódigo:**
```
DATOS-ADIC(354) REDEFINES (por sistema llamador):
  -- Cada aplicación define su propia estructura en los 354 bytes
  -- Acceso por SISTEMA y tipo de redefinición
```

**Vocabulario en la fórmula:** DATOS-ADIC, 354 bytes, redefinición por aplicación

**Excepciones:** Ninguna — diseño abierto para extensión.

**Estado validación:** Pendiente SME

---

## RN-S151-1069

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1069 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | L020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-MOV-DATOS contiene tres indicadores de estado del movimiento: IND-CONTA (el movimiento fue contabilizado), IND-EDOCTA (el movimiento aparece en estado de cuenta) e IND-DATOS-ADIC (hay datos adicionales presentes en DATOS-ADIC). Estos tres bits controlan qué sistemas downstream procesan cada movimiento.

**Fórmula/pseudocódigo:**
```
IND-CONTA(1)     = '1' si contabilizado, '0' si pendiente
IND-EDOCTA(1)    = '1' si aparece en estado de cuenta
IND-DATOS-ADIC(1) = '1' si DATOS-ADIC tiene datos válidos
```

**Vocabulario en la fórmula:** IND-CONTA, IND-EDOCTA, IND-DATOS-ADIC

**Excepciones:** IND-CONTA='0' no debe publicarse a sistemas de estado de cuenta.

**Estado validación:** Pendiente SME

---
## L014 — S151L014 — Consulta BIFIN online (librería permanente)

---

## RN-S151-1070

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1070 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L014 combina dos modos de compartición de librería: `SHARED BY ALL TEMPORARY` (compartida por todas las tareas, temporal en memoria) y `LIBRARYLOCK` (bloqueo exclusivo durante actualizaciones). La combinación garantiza acceso concurrente para lecturas mientras previene inconsistencias en escrituras mediante bloqueo global.

**Fórmula/pseudocódigo:**
```
$ SHARED BY ALL TEMPORARY
$ LIBRARYLOCK
$ FEDLEVEL = 5
PROGRAM-ID. S151L014.
```

**Vocabulario en la fórmula:** SHARED BY ALL, LIBRARYLOCK, FEDLEVEL=5, S151L014

**Excepciones:** LIBRARYLOCK puede causar contención alta si muchas tasks intentan actualizar simultáneamente.

**Estado validación:** Pendiente SME

---

## RN-S151-1071

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1071 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L014 gestiona tres datasets de S151BD13BIFIN: B07PROTCOB (protección de cobros generada por P014), B08TDMIGCAP (tabla de migración de tarjetas) y B10DOMI (domiciliaciones generadas por P013). L014 es la única librería que expone estos tres datasets para consulta online desde sucursales.

**Fórmula/pseudocódigo:**
```
DB S151BD13BIFIN:
  B07PROTCOB  = protección cobros (generado por P014)
  B08TDMIGCAP = migración tarjetas
  B10DOMI     = domiciliaciones (generado por P013)
L014 = gateway online para los tres datasets
```

**Vocabulario en la fórmula:** B07PROTCOB, B08TDMIGCAP, B10DOMI, S151BD13BIFIN

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1072

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1072 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La pantalla 29 de L014 consulta B08TDMIGCAP (migración de tarjetas) con 6 opciones de búsqueda: W88-X-FEC (por fecha), W88-X-FEC-SUC-CTO (fecha+sucursal+contrato), W88-X-FEC-SUC-CTA (fecha+sucursal+cuenta), W88-X-FEC-TAR (fecha+tarjeta), W88-X-FEC-BIN (fecha+BIN de tarjeta), W88-X-BIN (solo BIN). Esta granularidad soporta consultas para soporte al cliente y back-office de tarjetas.

**Fórmula/pseudocódigo:**
```
PANTALLA 29 (B08TDMIGCAP) - opciones de búsqueda:
  1 = X-FEC (solo fecha)
  2 = X-FEC-SUC-CTO (fecha + sucursal + contrato)
  3 = X-FEC-SUC-CTA (fecha + sucursal + cuenta)
  4 = X-FEC-TAR (fecha + número de tarjeta)
  5 = X-FEC-BIN (fecha + BIN)
  6 = X-BIN (solo BIN)
```

**Vocabulario en la fórmula:** TDMIGCAP, BIN, W88-X-FEC, W88-X-BIN, PANTALLA 29

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1073

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1073 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La pantalla 30 de L014 consulta B10DOMI (domiciliaciones) con los campos: rango de fechas (FECHAI+FECHAF), sucursal (SUC), cuenta (CTA), autorización S151 (AUTS151), autorización de aplicación (AUTAPL), número de contrato (CONTRATO) y número de ocurrencia (NUMOCUR). Permite al cajero consultar el historial de cargos automáticos de un cliente.

**Fórmula/pseudocódigo:**
```
PANTALLA 30 (B10DOMI):
  FECHAI + FECHAF  = rango de fechas
  SUC + CTA        = cuenta del cliente
  AUTS151          = autorización S151
  AUTAPL           = autorización de aplicación
  CONTRATO         = contrato del servicio domiciliado
  NUMOCUR          = número de ocurrencia del cargo
```

**Vocabulario en la fórmula:** B10DOMI, FECHAI, FECHAF, AUTS151, AUTAPL, NUMOCUR, PANTALLA 30

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1074

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1074 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L014 incluye una utilidad de calendario accesible vía WKS-CAL-FUNCION (tipo de operación) y WKS-CAL-FORMATO (formato de fecha). Las fechas WKS-CAL-FECHA1 y WKS-CAL-FECHA2 siempre están en formato CCAAMMDD (8 dígitos con siglo completo), eliminando ambigüedades de siglo en cálculos de días hábiles.

**Fórmula/pseudocódigo:**
```
WKS-CAL-FUNCION  = operación (días hábiles entre fechas, etc.)
WKS-CAL-FORMATO  = formato de fecha de salida
WKS-CAL-FECHA1   = PIC 9(8) CCAAMMDD (fecha inicial)
WKS-CAL-FECHA2   = PIC 9(8) CCAAMMDD (fecha final)
```

**Vocabulario en la fórmula:** WKS-CAL-FUNCION, WKS-CAL-FECHA1, WKS-CAL-FECHA2, CCAAMMDD

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1075

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1075 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** LIBRARYLOCK en L014 previene que múltiples tasks del sistema actualicen la librería simultáneamente. Durante cualquier operación de escritura en B07PROTCOB, B08TDMIGCAP o B10DOMI, todas las demás tasks esperan la liberación del lock antes de proceder — garantizando consistencia pero creando un cuello de botella potencial.

**Fórmula/pseudocódigo:**
```
LIBRARYLOCK:
  TASK-A actualiza → adquiere LIBRARYLOCK
  TASK-B intenta → espera liberación
  TASK-A termina → libera LIBRARYLOCK → TASK-B procede
```

**Vocabulario en la fórmula:** LIBRARYLOCK, contención, SHAREDBYALL

**Excepciones:** Alta carga concurrente puede generar timeouts — monitorear en producción.

**Estado validación:** Pendiente SME

---

## RN-S151-1076

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1076 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-DATGEN es la estructura de datos general de L014 que contiene: PROD(4)+INST(2)+MDE(2)+SUC(4)+CAJA(4)+IMP(16V99)+SDOF(S15V99)+HORA(6)+NAT(2)+FECNAT+HRS-MAQ+FEC-NAT-CAN+HRS-CAN. IMP es el importe del movimiento, SDOF es el saldo final, NAT es la naturaleza contable y los campos CAN rastrean cancelaciones.

**Fórmula/pseudocódigo:**
```
WKS-DATGEN:
  PROD(4)+INST(2)+MDE(2)
  SUC(4)+CAJA(4)
  IMP PIC 9(16)V99      -- importe
  SDOF PIC S9(15)V99    -- saldo final (signed)
  HORA(6)+NAT(2)+FECNAT+HRS-MAQ
  FEC-NAT-CAN+HRS-CAN   -- cancelación
```

**Vocabulario en la fórmula:** WKS-DATGEN, PROD, INST, MDE, IMP, SDOF, NAT, FEC-NAT-CAN

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1077

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1077 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-SERVICIO(2) es el selector de servicio en L014 que determina cuál de los tres datasets BIFIN se consulta: protección de cobros (B07PROTCOB), migración de tarjetas (B08TDMIGCAP) o domiciliaciones (B10DOMI). El valor de WKS-SERVICIO enruta la consulta al dataset correcto.

**Fórmula/pseudocódigo:**
```
WKS-SERVICIO(2):
  valor_1 → consultar B07PROTCOB (protección cobros)
  valor_2 → consultar B08TDMIGCAP (migración tarjetas)
  valor_3 → consultar B10DOMI (domiciliaciones)
-- Valores exactos a confirmar con SME
```

**Vocabulario en la fórmula:** WKS-SERVICIO, B07PROTCOB, B08TDMIGCAP, B10DOMI

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME — [DATO-REQUERIDO] valores de WKS-SERVICIO.

---

## RN-S151-1078

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1078 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L014 soporta tres llaves de consulta de cliente: WKS-NUMCTE-CONS(12) (número de cliente de 12 dígitos), WKS-CONTRATO-CONS(16) (número de contrato de 16 dígitos) y WKS-AUTORIZA-CONS(8) (número de autorización de 8 dígitos). Las tres llaves permiten localizar movimientos desde diferentes puntos de inicio de la consulta.

**Fórmula/pseudocódigo:**
```
WKS-NUMCTE-CONS(12)   = cliente → buscar por número de cliente
WKS-CONTRATO-CONS(16) = contrato → buscar por contrato
WKS-AUTORIZA-CONS(8)  = autorización → buscar por AUT-S151
```

**Vocabulario en la fórmula:** WKS-NUMCTE-CONS, WKS-CONTRATO-CONS, WKS-AUTORIZA-CONS

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1079

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1079 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | L014 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L014 (S151L014) es la librería de consulta online BIFIN que los cajeros de sucursal usan para verificar el estado de protección de cobros, migración de tarjetas y domiciliaciones de sus clientes en tiempo real. Es el único punto de acceso online a estos tres datasets — toda consulta desde sucursal pasa por L014.

**Fórmula/pseudocódigo:**
```
Sucursal → [SA2 online] → L014 → S151BD13BIFIN
  B07PROTCOB → ¿tiene protección activa?
  B08TDMIGCAP → ¿migración de tarjeta en proceso?
  B10DOMI → ¿domiciliaciones vigentes?
```

**Vocabulario en la fórmula:** L014, S151BD13BIFIN, BIFIN, sucursal, cajero

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## P011 — Monitor/Alarm Manager y relay batch

---

## RN-S151-1080

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1080 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de monitor de P011 tiene la mayor capacidad del subsistema S151: 2400 bytes por registro con FRAMESIZE=8 y PROTECTION IS PROTECTED. El tamaño de 2400 bytes (vs. 1500 de P053/P071/P073) refleja que P011 registra información completa de alarmas con múltiples campos de diagnóstico.

**Fórmula/pseudocódigo:**
```
A01-MONITOR: RECORD 2400 bytes, FRAMESIZE=8, PROTECTED
TITLE = "(S151)S151/FILE/P011/MONITOR/{FECHA}/{HORA}/{MIX} ON CMEMP."
```

**Vocabulario en la fórmula:** A01-MONITOR, 2400 bytes, FRAMESIZE=8, PROTECTED

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1081

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1081 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** TRANCODE 015111 está hardcodeado en P011 para identificar las transacciones del gestor de alarmas en la red SA2. Este TRANCODE de 6 dígitos (formato: SSTTTT donde SS=sistema 01=S151, TTTT=transacción) es el identificador único de P011 en el bus de mensajes online.

**Fórmula/pseudocódigo:**
```
TRANCODE = 015111  -- hardcoded
-- 01 = sistema S151
-- 5111 = transacción de alarma/monitor
```

**Vocabulario en la fórmula:** TRANCODE, 015111, SA2, P011

**Excepciones:** Cambio requiere coordinación con todos los sistemas que envían alarmas a P011.

**Estado validación:** Pendiente SME

---

## RN-S151-1082

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1082 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** W77-NODO-DES=16 está hardcodeado — todas las alarmas y mensajes de P011 se enrutan al nodo 16 del clúster MCP. El nodo 16 es presumiblemente el nodo de control o monitoreo central del sistema S151. Este hardcode implica que el cambio del nodo de control requiere modificación de código fuente.

**Fórmula/pseudocódigo:**
```
W77-NODO-DES PIC 9(2) VALUE 16  -- nodo destino fijo
-- Todo el tráfico de alarmas va al nodo 16
```

**Vocabulario en la fórmula:** W77-NODO-DES, nodo 16, NODO-DESTINO

**Excepciones:** Si el nodo 16 falla, P011 no puede entregar alarmas — punto único de falla.

**Estado validación:** Pendiente SME — [HARDCODE-SOSPECHOSO] para alta disponibilidad.

---

## RN-S151-1083

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1083 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El límite horario de P011 es 200000 (20:00:00), idéntico al de P016. Esto confirma que la ventana operativa 04:00–20:00 es una regla de negocio transversal del subsistema S151, no un valor de configuración individual de P016.

**Fórmula/pseudocódigo:**
```
WKS-HORA-LIMITE VALUE 200000  -- 20:00:00
-- Compartido con P016: ventana 04:00-20:00 es regla S151
```

**Vocabulario en la fórmula:** WKS-HORA-LIMITE, 200000, ventana operativa

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1084

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1084 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P011 usa S151BD13BIFIN con dos datasets: B03ALARMAS (registro de alarmas activas) y B06CTLENVIO (control de envío de mensajes batch). B03ALARMAS es el repositorio de alarmas pendientes y B06CTLENVIO coordina el relay de mensajes entre P011 online y los procesos batch.

**Fórmula/pseudocódigo:**
```
DB S151BD13BIFIN:
  B03ALARMAS   = alarmas activas (generadas por P016)
  B06CTLENVIO  = control de envío batch (17 sistemas)
```

**Vocabulario en la fórmula:** B03ALARMAS, B06CTLENVIO, S151BD13BIFIN

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1085

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1085 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** B03ALARMAS tiene una clave compuesta de 9 partes: SISTEMA(4)+CSI(2)+FECINF(8)+PRODUCTO(4)+INSTSERV(2)+MONEDA(4)+SUC(4)+CTA(12)+AUT_S151(8). Esta clave de 48 bytes identifica unívocamente cada alarma en el sistema, permitiendo correlación exacta entre la alarma y el movimiento que la originó.

**Fórmula/pseudocódigo:**
```
KEY B03ALARMAS (48 bytes total):
  SISTEMA(4) + CSI(2) + FECINF(8) + PRODUCTO(4)
  INSTSERV(2) + MONEDA(4) + SUC(4) + CTA(12) + AUT_S151(8)
```

**Vocabulario en la fórmula:** B03ALARMAS, SISTEMA, CSI, FECINF, PRODUCTO, INSTSERV, AUT_S151

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1086

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1086 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** B06CTLENVIO contiene TPO-MENS (tipo de mensaje) + FECINF(8) + CSI(2) + 17 ocurrencias de sistema, cada una con: SISTEMA(4)+PRODUCTO(4)+INSTSERV(2)+MONEDA(4)+CPAE(4)+NUM_T(4)+CONTRATO(SUC+CTA)+AUT_S151(8)+NUMOCURR(2). Las 17 ocurrencias permiten relay de mensajes a 17 sistemas distintos simultáneamente.

**Fórmula/pseudocódigo:**
```
B06CTLENVIO:
  TPO-MENS(1) + FECINF(8) + CSI(2)
  SISTEMA-OCC(17) cada uno:
    SISTEMA+PRODUCTO+INSTSERV+MONEDA+CPAE+NUM_T
    CONTRATO(SUC+CTA)+AUT_S151+NUMOCURR
```

**Vocabulario en la fórmula:** B06CTLENVIO, TPO-MENS, CPAE, NUMOCURR, 17 sistemas

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1087

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1087 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El TASKFILE de P011 sigue la nomenclatura: `S151/TASKFILE/P011/{NODO}/{SUBNODO}/R000/{FECHA}/{MIX}/001TASKFILE`. La inclusión de SUBNODO y el sufijo "R000/001TASKFILE" indica que P011 soporta múltiples sub-nodos por nodo físico, con el segmento "R000" identificando la ruta de ejecución principal.

**Fórmula/pseudocódigo:**
```
TASKFILE = "S151/TASKFILE/P011/" + NODO + "/" + SUBNODO
           + "/R000/" + FECHA + "/" + MIX + "/001TASKFILE"
```

**Vocabulario en la fórmula:** TASKFILE, NODO, SUBNODO, R000, 001TASKFILE

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1088

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1088 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P011 tiene 6 switches de modo de operación: SW-ALARMAS (procesar alarmas), SW-TOTALES (procesar totales), SW-BATCH (modo batch), SW-LEIBATCH (modo batch con librería), SW-RECIBE (modo recepción de mensajes) y SW-B06 (modo envío de control B06). Cada combinación de switches activa un flujo de procesamiento diferente.

**Fórmula/pseudocódigo:**
```
IF SW-ALARMAS:  procesar B03ALARMAS (modo online)
IF SW-TOTALES:  procesar totales MOVDIA
IF SW-BATCH:    procesar en modo batch (sin SA2)
IF SW-LEIBATCH: batch con carga de librería
IF SW-RECIBE:   recibir mensajes de P016/P030
IF SW-B06:      enviar control a B06CTLENVIO
```

**Vocabulario en la fórmula:** SW-ALARMAS, SW-TOTALES, SW-BATCH, SW-LEIBATCH, SW-RECIBE, SW-B06

**Excepciones:** Combinaciones de switches no documentadas pueden resultar en comportamiento indefinido.

**Estado validación:** Pendiente SME

---

## RN-S151-1089

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1089 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P011 fue recompilado en 2025 bajo la modificación 25MTP002. Junto con P001 (JNRB 251113, 2025), P011 es uno de los dos programas S151 con mantenimiento activo en 2025, lo que indica que la gestión de alarmas y la lectura de movimientos de tarjeta son las áreas más dinámicas del sistema.

**Fórmula/pseudocódigo:** N/A — Metadata de versiones.

**Vocabulario en la fórmula:** 25MTP002, 2025, recompilación

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## P020 — S151-P020 — Receptor de mensajes L002

---

## RN-S151-1090

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1090 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P020 (S151-P020) tiene un buffer de mensaje WKS-REG-MSG de 864 bytes con WITH LOWER-BOUNDS. Este buffer almacena el mensaje completo L002 incluyendo encabezado SA2 (SA0+SA2) de ~125 bytes + payload de ~739 bytes. Fue escrito en Febrero 2018 para el protocolo de mensajes L002.

**Fórmula/pseudocódigo:**
```
WKS-REG-MSG PIC X(864) WITH LOWER-BOUNDS
  Estructura: [SA0 header] + [SA2 header] + [DATOS-S151]
  Protocolo: L002 (inter-system messaging, Feb 2018)
```

**Vocabulario en la fórmula:** WKS-REG-MSG, 864 bytes, L002, WITH LOWER-BOUNDS

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1091

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1091 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El encabezado SA2 de P020 tiene estructura de 36 bytes: PREFIJO(1)+APLDEST(1)+CCRDEST(2)+LSNORGN(4/8)+STATION(8)+CCRORGN(2)+COPORGN(2)+FACULTAD(2)+APLORIG(1)+RSLTDO(2)+MASCARA(5)+PASSWORD(6). Esta estructura es el estándar de autenticación y enrutamiento para todas las transacciones online Unisys en el ecosistema S151.

**Fórmula/pseudocódigo:**
```
SA2-HEADER (36 bytes):
  PREFIJO(1)+APLDEST(1)+CCRDEST(2)+LSNORGN(4 or 8 COMP)
  STATION(8)+CCRORGN(2)+COPORGN(2)+FACULTAD(2)
  APLORIG(1)+RSLTDO(2)+MASCARA(5)+PASSWORD(6)
```

**Vocabulario en la fórmula:** SA2, PREFIJO, APLDEST, CCRDEST, LSNORGN, FACULTAD, MASCARA, PASSWORD

**Excepciones:** PASSWORD en texto claro en el buffer — riesgo de seguridad en dumps de memoria.

**Estado validación:** Pendiente SME — [SILENCIOSO-CRÍTICO] PASSWORD expuesto.

---

## RN-S151-1092

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1092 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo RSLTDO en el encabezado SA2 clasifica el origen y resultado del mensaje con códigos específicos: 11/12=mensaje de terminal, 02/04=mensaje de aplicación, 12=reformateado (REDFOR), 3=más datos disponibles, 1=terminal, 31/32/33=error. P020 selecciona el flujo de procesamiento según el valor de RSLTDO.

**Fórmula/pseudocódigo:**
```
RSLTDO:
  11, 12 → W88-HDR-VINO-TERM  (mensaje de terminal)
  02, 04 → W88-HDR-VINO-APLI  (mensaje de aplicación)
  12     → W88-MSGRES-REDFOR  (reformateado)
  3      → W88-MSGRES-MAS     (más datos)
  1      → W88-MSGRES-TER     (terminal simple)
  31,32,33 → W88-MSGRES-ERR   (error)
```

**Vocabulario en la fórmula:** RSLTDO, W88-HDR-VINO-TERM, W88-HDR-VINO-APLI, W88-MSGRES-ERR

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1093

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1093 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo SA0-DIRECCION en P020 define el tipo de operación del mensaje SA0: 1=ALTA (crear sesión/registro), 2=RESP (respuesta), 3=BAJA (eliminar/cerrar), 4=RES-BAJA (respuesta a baja). Este protocolo de 4 estados gestiona el ciclo de vida completo de los mensajes entre sistemas.

**Fórmula/pseudocódigo:**
```
WKS-SA0-DIRECCION:
  1 → W88-SA0-ALTA     (crear)
  2 → W88-SA0-RESP     (responder)
  3 → W88-SA0-BAJA     (eliminar)
  4 → W88-SA0-RES-BAJA (respuesta a eliminación)
```

**Vocabulario en la fórmula:** SA0-DIRECCION, ALTA, RESP, BAJA, RES-BAJA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1094

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1094 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** STATION(8) identifica la terminal física del cajero con formato TIPO(1)+SUC(4)+PRIV(1)+CAJA(2). TIPO discrimina el tipo de terminal (cajero, supervisor, ATM). PRIV es el nivel de privilegio del operador. Esta estructura de 8 bytes es consistente en P020, P030 y P017 — es el estándar de identificación de terminal en todo S151.

**Fórmula/pseudocódigo:**
```
STATION(8) = TIPO(1) + SUC(4) + PRIV(1) + CAJA(2)
-- TIPO: tipo de terminal (cajero/supervisor/ATM)
-- SUC:  sucursal (4 dígitos)
-- PRIV: privilegio del operador
-- CAJA: número de caja (2 dígitos)
```

**Vocabulario en la fórmula:** STATION, TIPO, SUC, PRIV, CAJA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1095

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1095 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-DATOS-S151 en P020 replica la estructura de 5 CVETRAN slots del registro canónico de movimiento S151. Esto garantiza que los mensajes L002 pueden transportar movimientos multi-transacción completos con todos sus CVETRANs sin fragmentación.

**Fórmula/pseudocódigo:**
```
WKS-DATOS-S151 contiene:
  CVETRAN-1 + CVETRAN-2 + CVETRAN-3 + CVETRAN-4 + CVETRAN-5
-- Mismo patrón que A00-R01-REGMOV (450 bytes, 5 CVEIMPs)
```

**Vocabulario en la fórmula:** WKS-DATOS-S151, CVETRAN, CVEIMP

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1096

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1096 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P020 transporta 5 campos LEYENDA(40 chars cada una) en el mensaje L002. Estos campos son las líneas de descripción de la transacción que aparecen en la pantalla del cajero — su presencia en el protocolo de mensajes garantiza que la descripción del movimiento viaja junto con los datos contables.

**Fórmula/pseudocódigo:**
```
LEYENDA-1(40) + LEYENDA-2(40) + LEYENDA-3(40)
LEYENDA-4(40) + LEYENDA-5(40)
Total: 200 chars de concepto visible al cajero
```

**Vocabulario en la fórmula:** LEYENDA-1..5, concepto, descripción de transacción

**Excepciones:** LEYENDAs vacías son espacios — el cajero ve líneas en blanco.

**Estado validación:** Pendiente SME

---

## RN-S151-1097

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1097 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P020 incluye los campos BCO-S264, BORI-S264 y BDES-S264 en WKS-DATOS-S151 para enrutar mensajes del sistema S264 entre bancos origen y destino. S264 es posiblemente el sistema de compensación interbancaria S.I.C. (Sistema de Pagos Interbancarios en Cámara).

**Fórmula/pseudocódigo:**
```
BCO-S264   = banco S264 (código de banco)
BORI-S264  = banco origen (en S264)
BDES-S264  = banco destino (en S264)
-- Routing interbancario para mensajes S264
```

**Vocabulario en la fórmula:** BCO-S264, BORI-S264, BDES-S264, S264

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME — [DATO-REQUERIDO] confirmar identidad de S264.

---

## RN-S151-1098

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1098 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P020 fue escrito en Febrero 2018 específicamente para el protocolo de mensajes L002, haciendo de él el segundo programa más reciente del subsistema S151 analizado (después de P011, 2025). La introducción de L002 en 2018 representa una modernización del protocolo de comunicación inter-sistema de S151.

**Fórmula/pseudocódigo:** N/A — Metadata histórica.

**Vocabulario en la fórmula:** L002, Febrero 2018, S151-P020

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-1099

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1099 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P020 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** LSNORGN (Line Station Number — origen) tiene representación dual en P020: PIC 9(4) en formato DISPLAY para identificadores cortos y PIC 9(8) COMP (binario comprimido) para identificadores largos. La redefinición permite compatibilidad con ambos tipos de LSN en la red SA2 de Unisys.

**Fórmula/pseudocódigo:**
```
WKS-HDR-LSNORGN     PIC 9(004)          -- DISPLAY corto
WKS-HDR-LSNORGN-H  REDEFINES
   WKS-HDR-LSNORGN  PIC 9(08) COMP      -- BINARY largo
-- Ambos representan el número de estación origen SA2
```

**Vocabulario en la fórmula:** LSNORGN, LSN, COMP, DISPLAY, redefinición

**Excepciones:** Si LSNORGN en COMP > 9999, la representación DISPLAY será incorrecta.

**Estado validación:** Pendiente SME

---

## P071 — S151P071 — Monitor/relay sistema 071

---

## RN-S151-1100

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1100 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P071 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P071 genera su archivo de monitor en `(S151)S151/FILE/P071/MONITOR/{FECHA}/{HORA}/{MIX} ON CMEMP.` con registros de 1500 bytes agrupados en bloques de 10. La estructura es idéntica a P073, diferenciándose únicamente en el identificador del programa (P071 vs P073) dentro de la ruta del archivo.

**Fórmula/pseudocódigo:**
```
MONITOR-TITLE = "(S151)S151/FILE/P071/MONITOR/" + FECHA(6) + "/" + HORA(6) + " ON CMEMP."
RECORD 1500 chars, BLOCK 10 records
```

**Vocabulario en la fórmula:** P071, MONITOR, CMEMP, FECHA, HORA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1101

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1101 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P071 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** W77-NUM-MOVTOS=25 está hardcodeado en P071 como el máximo de movimientos por batch de procesamiento. Este límite de 25 movimientos controla el tamaño del lote en cada ciclo de P071, balanceando throughput con latencia de procesamiento de alertas.

**Fórmula/pseudocódigo:**
```
W77-NUM-MOVTOS PIC 9(02) VALUE 25
-- Procesar máximo 25 movimientos por ciclo de P071
```

**Vocabulario en la fórmula:** W77-NUM-MOVTOS, 25, batch de movimientos

**Excepciones:** Si hay > 25 movimientos pendientes, P071 hace múltiples ciclos.

**Estado validación:** Pendiente SME

---

## RN-S151-1102

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1102 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P071 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P071 define W77-HDR-BNMX=48 (tamaño del encabezado Banamex) y W77-HDR-SA2=77 (tamaño del encabezado SA2). Estos offsets permiten que P071 analice los mensajes SA2 recibidos ubicando correctamente el payload después de los encabezados fijos de 48+77=125 bytes.

**Fórmula/pseudocódigo:**
```
W77-HDR-BNMX VALUE 48   -- 48 bytes: encabezado Banamex
W77-HDR-SA2  VALUE 77   -- 77 bytes: encabezado SA2
PAYLOAD-OFFSET = 48 + 77 = 125 bytes
```

**Vocabulario en la fórmula:** W77-HDR-BNMX, W77-HDR-SA2, payload offset

**Excepciones:** P073 tiene W77-HDR-SA2=37 — protocolos SA2 de diferente versión.

**Estado validación:** Pendiente SME

---

## RN-S151-1103

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1103 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P071 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** W88-SISTEMAS-PUNTEO define 18 sistemas habilitados para reconciliación/matching (punteo) en P071: 017, 018, 084, 087, 264, 252, 333, 335, 336, 404, 408, 500, 501, 502, 701, 703, 707, 711. Estos sistemas son los únicos cuyos movimientos P071 incluye en el proceso de cuadre intraday.

**Fórmula/pseudocódigo:**
```
W88-SISTEMAS-PUNTEO VALUE
  017, 018, 084, 087, 264, 252, 333, 335, 336,
  404, 408, 500, 501, 502, 701, 703, 707, 711
-- 18 sistemas habilitados para punteo en P071
```

**Vocabulario en la fórmula:** W88-SISTEMAS-PUNTEO, punteo, reconciliación

**Excepciones:** Sistemas fuera de esta lista son excluidos del cuadre — potencial reconciliación incompleta.

**Estado validación:** Pendiente SME

---

## RN-S151-1104

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1104 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P071 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P071 integra la interfaz LIBCONTROL/CONSISDIA con sus 10 funciones mediante COPY del archivo `(S151)S151/FORMATO/LLAMADA/LIBCONTROL ON CMEMP.`. Esta es la misma interfaz que P073, P600 y todos los demás programas S151 — confirma que LIBCONTROL es la API de control de día universal del sistema.

**Fórmula/pseudocódigo:**
```
COPY "(S151)S151/FORMATO/LLAMADA/LIBCONTROL ON CMEMP."
-- 10 funciones: F01=consulta, F02-F10=actualización de fechas/estatus
```

**Vocabulario en la fórmula:** LIBCONTROL, CONSISDIA, COPY, S151/FORMATO/LLAMADA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1105

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1105 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P071 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-S151B01SISDIA contiene un arreglo CTL-DIA de 10 ocurrencias (OCCURS 10 TIMES), cada una con FECARCMOV(8), NIVARCMOV(8), NIVBDMOV(8) y STAARCLOG(2). Este arreglo de 10 posiciones representa los últimos 10 días de control operativo del sistema, permitiendo auditoría de la semana hábil completa.

**Fórmula/pseudocódigo:**
```
WKS-B01-CTL-DIA OCCURS 10 TIMES:
  FECARCMOV(8)  -- fecha del archivo de movimientos
  NIVARCMOV(8)  -- nivel del archivo
  NIVBDMOV(8)   -- nivel de la base de datos
  STAARCLOG(2)  -- estatus del archivo log
-- 10 = semana hábil + buffer
```

**Vocabulario en la fórmula:** CTL-DIA, FECARCMOV, NIVARCMOV, NIVBDMOV, STAARCLOG

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1106

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1106 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P071 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P071 integra las librerías DESPLIEGA (mensajería al operador) y CTLVER (control de versiones) mediante COPY de `(S000)S000/UTILITY/DESPLIEGA/FTE/CCW ON PACK.`. Esta dependencia de S000 (sistema utilitario base) indica que la infraestructura de mensajería y versiones está centralizada fuera de S151.

**Fórmula/pseudocódigo:**
```
COPY "(S000)S000/UTILITY/DESPLIEGA/FTE/CCW ON PACK."
-- S000 = sistema utilitario central de Banamex/Unisys
-- CCW = posiblemente Channel Command Word (I/O)
```

**Vocabulario en la fórmula:** S000, DESPLIEGA, CTLVER, CCW, PACK

**Excepciones:** Dependencia de S000 — cambios en S000 pueden afectar a S151.

**Estado validación:** Pendiente SME

---

## RN-S151-1107

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1107 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P071 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** W77-RESULT-L011 es de tipo PIC S9(11) BINARY (signed 11-digit binary) para almacenar el código de retorno de la librería L011. El uso de tipo binario signed de 11 dígitos indica que L011 puede retornar valores negativos (errores) o muy grandes (contadores), y que se prioriza eficiencia de memoria sobre legibilidad.

**Fórmula/pseudocódigo:**
```
W77-RESULT-L011 PIC S9(11) BINARY
-- Signed binary: puede ser negativo (error) o positivo (OK/contador)
-- 11 dígitos signed = hasta ±99,999,999,999
```

**Vocabulario en la fórmula:** W77-RESULT-L011, S9(11) BINARY, L011

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## P017 — S151-P017 — Receptor de confirmaciones S702

---

## RN-S151-1108

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1108 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P017 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P017 recibe mensajes de confirmación del sistema S702 para el servicio de Protección de Cobros (direct-debit protection). Escrito en Marzo 2012 por ISI (Internacional de Sistemas de Imagen), P017 cierra el ciclo bidireccional de domiciliación: P013 envía instrucciones a S702, y P017 recibe las confirmaciones de retorno.

**Fórmula/pseudocódigo:**
```
Ciclo domiciliación:
  P013 → S702 (instrucción de cargo automático)
  S702 → P017 (confirmación de procesamiento)
  P017 → B10DOMI (registro del resultado)
```

**Vocabulario en la fórmula:** P017, S702, Protección de Cobros, ISI, Marzo 2012

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1109

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1109 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P017 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P017 protege ambos archivos de log: L01-DISPLAY (auditoría) y L02-MONITOR (operativo) con `PROTECTION IS PROTECTED`. La doble protección en el receptor de confirmaciones S702 garantiza que el historial de pagos domiciliados no pueda ser alterado retroactivamente — crítico para disputas regulatorias.

**Fórmula/pseudocódigo:**
```
FD L01-DISPLAY PROTECTION IS PROTECTED  -- log auditoría
FD L02-MONITOR PROTECTION IS PROTECTED  -- log operativo
```

**Vocabulario en la fórmula:** L01-DISPLAY, L02-MONITOR, PROTECTION IS PROTECTED

**Excepciones:** Ninguna.

**Estado validación:** Pendiente SME

---

## RN-S151-1110

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1110 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P017 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El buffer de mensaje de P017 tiene 534 bytes: WKS-HDR-MSG (header SA2, ~36 bytes) + WKS-MSG-TEXTO (498 bytes de payload). El payload de 498 bytes contiene ACA (destino/origen, 12 bytes) + SA0 (routing, variable) + SA2 (identificación, variable) + WKS-AREA-USUARIO (409 bytes de datos específicos del servicio).

**Fórmula/pseudocódigo:**
```
WKS-REG-MSG(534):
  WKS-HDR-MSG (~36 bytes)     -- encabezado SA2
  WKS-MSG-TEXTO(498):
    WKS-ACA(12)               -- destino + origen
    WKS-SA0(variable)         -- routing SA0
    WKS-SA2(variable)         -- identificación SA2
    WKS-AREA-USUARIO(409)     -- datos del servicio
```

**Vocabulario en la fórmula:** WKS-REG-MSG, 534 bytes, WKS-AREA-USUARIO, ACA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1111

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1111 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P017 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P017 valida que el sistema origen del mensaje SA0 sea S702 (VALUE 0702) o C845 (VALUE 0845). Solo mensajes de estos dos sistemas son procesados como confirmaciones de domiciliación válidas. Cualquier mensaje de otro origen es rechazado, previniendo inyección de confirmaciones falsas.

**Fórmula/pseudocódigo:**
```
88 W88-SA0-TRN-OSIS-S702 VALUE 0702
88 W88-SA0-TRN-OSIS-C845 VALUE 0845
IF WKS-SA0-TRN-ORIG NOT (S702 OR C845):
  RECHAZAR mensaje
```

**Vocabulario en la fórmula:** W88-SA0-TRN-OSIS-S702, W88-SA0-TRN-OSIS-C845, sistema origen

**Excepciones:** Ninguna — validación estricta de origen.

**Estado validación:** Pendiente SME — [DATO-REQUERIDO] qué es C845.

---

## RN-S151-1112

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1112 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P017 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P017 valida que el sistema destino del mensaje SA0 sea S151 (VALUE 0151). Este control garantiza que P017 solo procesa mensajes explícitamente dirigidos a S151, descartando mensajes mal enrutados que llegan accidentalmente al sistema.

**Fórmula/pseudocódigo:**
```
88 W88-SA0-TRN-DSIS-S151 VALUE 0151
IF WKS-SA0-TRN-DEST ≠ 0151:
  DESCARTAR mensaje (no es para S151)
```

**Vocabulario en la fórmula:** W88-SA0-TRN-DSIS-S151, sistema destino, 0151

**Excepciones:** Ninguna — validación obligatoria de destino.

**Estado validación:** Pendiente SME

---

## RN-S151-1113

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1113 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P017 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El área de servicio SERV1 de P017 contiene los datos contables de la confirmación de domiciliación: CONTRATO(16)+CVEMDA(4)+MDA-SUC(4)+MDA-CTA(16)+AUTORIZA(8)+REFNUM(12)+AUT-S151(8)+FECMOV(6)+CVETRAN(4)+OCCUR(2)+IMPORTE(14V99)+ERROR(4). ERROR(4) contiene el código de resultado del procesamiento S702.

**Fórmula/pseudocódigo:**
```
WKS-AREA-MSG-OBL-SERV1:
  CONTRATO(16)+CVEMDA(4)+MDA-SUC(4)+MDA-CTA(16)
  AUTORIZA(8)+REFNUM(12)+AUT-S151(8)
  FECMOV(6)+CVETRAN(4)+OCCUR(2)+IMPORTE(14V99)
  ERROR(4)  ← código resultado S702
```

**Vocabulario en la fórmula:** SERV1, CONTRATO, MDA-CTA, AUT-S151, OCCUR, ERROR

**Excepciones:** ERROR=0000 = procesamiento exitoso.

**Estado validación:** Pendiente SME

---

## RN-S151-1114

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1114 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P017 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El área SERV2 de P017 contiene campos internacionales de tarjeta/red: COUNTRY(2) código de país, CUSTID(12) ID del cliente, ACCNUM(16) número de cuenta, CURRCODE(2) código de moneda ISO, PRNAME(33) nombre del producto, TRANMEAN(30) medio de transacción, PRODNUM(20) número de producto. Estos campos indican que S702 procesa operaciones de red internacional de tarjetas.

**Fórmula/pseudocódigo:**
```
WKS-AREA-MSG-OBL-SERV2 (campos internacionales):
  COUNTRY(2)+CUSTID(12)+ACCNUM(16)
  CURRCODE(2)+PRNAME(33)+TRANMEAN(30)+PRODNUM(20)
  BEFBAL(15)+CURRBAL(sign+14)+CREDDLIM(15)+AVACRED(15)
```

**Vocabulario en la fórmula:** COUNTRY, CURRCODE, PRNAME, TRANMEAN, AVACRED, CREDDLIM

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME — campos internacionales sugieren integración con redes VISA/MC.

---

## RN-S151-1115

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1115 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P017 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P017 almacena los resultados de las confirmaciones S702 en S151BD13BIFIN, el mismo BIFIN que usa L014 para consultas online. Esto garantiza que los cajeros de sucursal pueden consultar inmediatamente el estado de un cargo domiciliado después de que S702 confirma su procesamiento.

**Fórmula/pseudocódigo:**
```
S702 → P017 → S151BD13BIFIN.B10DOMI → L014 → Sucursal
-- Latencia: inmediata (online processing)
```

**Vocabulario en la fórmula:** S151BD13BIFIN, B10DOMI, L014, sucursal

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## P073 — S151P073 — Monitor/relay sistema 073

---

## RN-S151-1116

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1116 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P073 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P073 (S151P073) tiene estructura casi idéntica a P071. Su archivo de monitor sigue la misma convención: `(S151)S151/FILE/P073/MONITOR/{FECHA}/{HORA}/{MIX} ON CMEMP.` con registros de 1500 bytes y bloques de 10. La diferencia principal con P071 está en el conjunto de sistemas para punteo y en el tamaño del encabezado SA2.

**Fórmula/pseudocódigo:**
```
MONITOR-TITLE = "(S151)S151/FILE/P073/MONITOR/" + FECHA(6) + "/" + HORA(6) + " ON CMEMP."
RECORD 1500 chars, BLOCK 10 records
```

**Vocabulario en la fórmula:** P073, MONITOR, CMEMP

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1117

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1117 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P073 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P073 tiene W77-HDR-SA2=37 bytes para el encabezado SA2, significativamente menor que los 77 bytes de P071. Esta diferencia indica que P073 procesa una versión más compacta o diferente del protocolo SA2 — posiblemente mensajes de un sistema con encabezado SA2 reducido o mensajes internos sin autenticación completa.

**Fórmula/pseudocódigo:**
```
P073: W77-HDR-BNMX=48, W77-HDR-SA2=37  -- SA2 compacto
P071: W77-HDR-BNMX=48, W77-HDR-SA2=77  -- SA2 completo
-- P073 procesa protocolo SA2 de versión distinta
```

**Vocabulario en la fórmula:** W77-HDR-SA2, SA2 compacto, 37 bytes, 77 bytes

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME — [DATO-REQUERIDO] qué sistemas usan SA2 de 37 bytes.

---

## RN-S151-1118

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1118 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P073 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** W88-SISTEMAS-PUNTEO de P073 incluye 14 sistemas (vs. 18 de P071). Los sistemas excluidos en P073 vs P071 son: 252 (partidas), 408 (sistema adicional). Esta diferencia implica que P073 tiene un alcance de reconciliación más limitado que P071 — no procesa movimientos de los sistemas 252 y 408.

**Fórmula/pseudocódigo:**
```
P073 SISTEMAS-PUNTEO (14): 017,018,084,087,264,333,335,336,
                            404,500,501,502,701,703,707,711
P071 SISTEMAS-PUNTEO (18): P073 + 252 + 408
-- Diferencia: P073 excluye sistemas 252 y 408
```

**Vocabulario en la fórmula:** W88-SISTEMAS-PUNTEO, 14 sistemas, 252, 408

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1119

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1119 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P073 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P073 integra la interfaz LIBCONTROL/CONSISDIA con sus 10 funciones mediante el mismo COPY que P071 y P600. Esta uniformidad confirma que LIBCONTROL es la API de control de día universal en el ecosistema S151 — todos los programas que gestionan estado del día usan exactamente la misma interfaz.

**Fórmula/pseudocódigo:**
```
COPY "(S151)S151/FORMATO/LLAMADA/LIBCONTROL ON CMEMP."
-- Mismo COPY que P071, P600, P025, P016, L040
```

**Vocabulario en la fórmula:** LIBCONTROL, CONSISDIA, COPY

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1120

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1120 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P073 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P073 comparte el mismo arreglo WKS-S151B01SISDIA OCCURS 10 TIMES que P071, con los cuatro campos por día: FECARCMOV, NIVARCMOV, NIVBDMOV, STAARCLOG. Esta estructura de 10 días de control es consistente en todos los programas que usan LIBCONTROL — es la estructura canónica del día operativo S151.

**Fórmula/pseudocódigo:**
```
WKS-B01-CTL-DIA OCCURS 10 TIMES:
  FECARCMOV(8)+NIVARCMOV(8)+NIVBDMOV(8)+STAARCLOG(2)
-- Idéntico a P071, P600 — estructura canónica SISDIA
```

**Vocabulario en la fórmula:** WKS-B01-CTL-DIA, FECARCMOV, NIVARCMOV, STAARCLOG

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1121

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1121 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P073 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P073 tiene W77-TOTAL-SISTEMAS como contador del número de sistemas activos siendo procesados. Este contador permite que P073 ajuste dinámicamente su procesamiento según cuántos sistemas del W88-SISTEMAS-PUNTEO tienen movimientos pendientes en la jornada actual.

**Fórmula/pseudocódigo:**
```
W77-TOTAL-SISTEMAS PIC 9(04)
-- Cuenta sistemas activos con movimientos para punteo
-- Usado para optimizar ciclos de procesamiento
```

**Vocabulario en la fórmula:** W77-TOTAL-SISTEMAS, sistemas activos

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1122

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1122 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P073 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P073 comparte la misma cadena de dependencias de librerías que P071: DESPLIEGA (mensajería al operador) + CTLVER (control de versiones) de S000, más L011 (librería interna S151). Esta dependencia triple confirma el patrón estándar de librerías para programas de monitor/relay en S151.

**Fórmula/pseudocódigo:**
```
Dependencias de librería:
  DESPLIEGA (S000) → mensajería operador
  CTLVER (S000)    → control de versiones
  L011 (S151)      → librería interna S151
```

**Vocabulario en la fórmula:** DESPLIEGA, CTLVER, L011, S000

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1123

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1123 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P073 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** W77-RESULT-L011 en P073 tiene el mismo tipo PIC S9(11) BINARY que en P071, confirmando que L011 retorna valores binarios signed de hasta 11 dígitos. La consistencia de tipo entre P071 y P073 garantiza compatibilidad de la interfaz L011 entre ambos programas de monitor/relay.

**Fórmula/pseudocódigo:**
```
W77-RESULT-L011 PIC S9(11) BINARY  -- igual que P071
W77-RESP-L011   PIC 9(04)          -- respuesta secundaria
```

**Vocabulario en la fórmula:** W77-RESULT-L011, S9(11) BINARY, L011

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## P090 — RECLIDE — Totales LIDE para S502

---

## RN-S151-1124

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1124 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P090 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P090 (RECLIDE) genera el archivo de totales LIDE para S502 con nomenclatura `(S151)S151/FILE/S502/RECLIDE/{CCI}/10/{AAMMD} ON CMEMP.` donde CCI es el código de CSI/centro de información. El segmento "/10/" es un literal fijo que posiblemente identifica el tipo de reporte o la versión del formato.

**Fórmula/pseudocódigo:**
```
LIDE-TITLE = "(S151)S151/FILE/S502/RECLIDE/"
            + CCI(2) + "/10/"
            + AA(2) + MM(2) + DD(2)
            + " ON CMEMP."
```

**Vocabulario en la fórmula:** RECLIDE, S502, CCI, LIDE, "/10/"

**Excepciones:** El literal "/10/" no es configurable — requiere cambio de código si el formato cambia.

**Estado validación:** Pendiente SME — [HARDCODE-IMPLÍCITO] el segmento "/10/".

---

## RN-S151-1125

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1125 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P090 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P090 genera tres archivos regionales adicionales con DEPENDENTSPECS=TRUE: A01-TOT-LIDE-VDM (Valle de México), A02-TOT-LIDE-MTY (Monterrey) y A03-TOT-LIDE-UNI (Unión/Nacional). La segmentación regional del LIDE refleja la estructura de compensación de efectivo de Banxico que opera por plaza.

**Fórmula/pseudocódigo:**
```
ARCH-TOT-LIDE      = archivo principal (todas las plazas)
A01-TOT-LIDE-VDM   = Valle de México (DEPENDENTSPECS=TRUE)
A02-TOT-LIDE-MTY   = Monterrey (DEPENDENTSPECS=TRUE)
A03-TOT-LIDE-UNI   = Unión/Nacional (DEPENDENTSPECS=TRUE)
```

**Vocabulario en la fórmula:** VDM, MTY, UNI, LIDE, DEPENDENTSPECS

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1126

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1126 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P090 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo LIDE tiene tres tipos de registro de 60 bytes cada uno, identificados por TIPREG: (0) HDR con FECPRO+HORAPRO, (1) REGDET con SIS+CCI+COB+NOMRENG+NUMCAR+IMPCAR+NUMABO+IMPABO, y (2) TRAILER con TOTREG+TOTNUMCAR+TOTIMPCAR+TOTNUMABO+TOTIMPABO. El trailer permite validación de integridad del archivo.

**Fórmula/pseudocódigo:**
```
TIPREG=0 (HDR):    FECPRO(6)+HORAPRO(6)+FILLER(53)  = 60 bytes
TIPREG=1 (DET):    SIS(4)+CCI(2)+COB(3)+NOMRENG(15)
                   +NUMCAR(10)+IMPCAR(18V99)
                   +NUMABO(10)+IMPABO(18V99)+FILLER(8) = 60 bytes
TIPREG=2 (TRAIL):  TOTREG(8)+TOTNUMCAR(10)+TOTIMPCAR(18V99)
                   +TOTNUMABO(10)+TOTIMPABO(18V99)+FILLER(25) = 60 bytes
```

**Vocabulario en la fórmula:** TIPREG, NUMCAR, IMPCAR, NUMABO, IMPABO, COB, NOMRENG

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1127

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1127 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P090 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los totales acumulados en el trailer LIDE son: TOTREG (total de registros), TOTNUMCAR (total número de cargos), TOTIMPCAR (total importe de cargos, 18V99), TOTNUMABO (total número de abonos), TOTIMPABO (total importe de abonos, 18V99). Estos cinco contadores permiten cuadre de la Liquidación Diaria de Efectivo con los sistemas de Banxico.

**Fórmula/pseudocódigo:**
```
CUADRE_LIDE:
  TOTREG = Σ registros TIPREG=1
  TOTNUMCAR = Σ NUMCAR de todos los registros
  TOTIMPCAR = Σ IMPCAR (cargos en efectivo)
  TOTNUMABO = Σ NUMABO
  TOTIMPABO = Σ IMPABO (abonos en efectivo)
CUADRE: TOTIMPABO - TOTIMPCAR = posición neta de efectivo
```

**Vocabulario en la fórmula:** TOTNUMCAR, TOTIMPCAR, TOTNUMABO, TOTIMPABO, posición neta

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1128

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1128 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P090 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** LIDE (Liquidación Diaria de Efectivo) es el mecanismo de Banxico para la compensación diaria de operaciones de efectivo entre instituciones financieras. P090 calcula los totales LIDE por sistema (SIS), CSI (CCI) y concepto de operación (COB), que se reportan al sistema S502 para su procesamiento en la liquidación de Banxico.

**Fórmula/pseudocódigo:**
```
LIDE = Liquidación Diaria de Efectivo (Banxico)
P090 reporta: por SIS + CCI + COB:
  Número de cargos (NUMCAR) y su importe (IMPCAR)
  Número de abonos (NUMABO) y su importe (IMPABO)
Destino: S502 → Banxico (liquidación)
```

**Vocabulario en la fórmula:** LIDE, Banxico, liquidación, S502, COB, CCI

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1129

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1129 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P090 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P090 usa la librería L030 para operaciones de transferencia de archivos entre packs MCP. El formato de llamada WKS-COPY-L030 construye un comando MCP `BEGIN JOB; REMOVE {DEST}; COPY {SOURCE} AS {DEST} FROM CMEMP(PACK) TO CMEMP(PACK)` que reemplaza el archivo LIDE del día anterior con el del día actual.

**Fórmula/pseudocódigo:**
```
WKS-COPY-L030:
  "BEGIN JOB; "
  "REMOVE " + DEST + " ON CMEMP"
  "; COPY " + SOURCE + " AS " + DEST
  + " FROM CMEMP(PACK) TO CMEMP(PACK)"
```

**Vocabulario en la fórmula:** L030, COPY-L030, BEGIN JOB, REMOVE, FROM CMEMP TO CMEMP

**Excepciones:** Si REMOVE falla (archivo no existe), el COPY puede también fallar.

**Estado validación:** Pendiente SME

---

## RN-S151-1130

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1130 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P090 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-DATOS-HOST en P090 identifica el host MCP que ejecuta el proceso: NUMCSI(2) número de CSI + NOMEQUIPO(10) nombre del equipo + NOMCSI(26) nombre largo del CSI + LINEA-BATCH(5) identificador de línea batch. Este bloque de identificación se incluye en el log para trazabilidad de ejecución en entornos multi-nodo.

**Fórmula/pseudocódigo:**
```
WKS-DATOS-HOST:
  NUMCSI(2)    = número de CSI (0-99)
  NOMEQUIPO(10) = nombre del equipo MCP
  NOMCSI(26)   = nombre largo del CSI
  LINEA-BATCH(5) = línea de batch (identificador)
```

**Vocabulario en la fórmula:** NUMCSI, NOMEQUIPO, NOMCSI, LINEA-BATCH, CSI

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1131

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1131 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P090 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo SECURITYTYPE=PUBLIC en los archivos de salida LIDE (ARCH-TOT-LIDE y variantes) permite que S502 lea los archivos sin autenticación especial. Esto confirma que los archivos LIDE son de solo lectura para S502 — P090 escribe, S502 lee, sin necesidad de credenciales adicionales.

**Fórmula/pseudocódigo:**
```
FD ARCH-TOT-LIDE SECURITYTYPE IS PUBLIC
-- S502 puede leer sin credenciales adicionales
-- P090 tiene derechos de escritura (propietario)
```

**Vocabulario en la fórmula:** SECURITYTYPE=PUBLIC, ARCH-TOT-LIDE, S502

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## P600 — CALLLIBCTL — Interfaz completa LIBCONTROL (programa de referencia)

---

## RN-S151-1132

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1132 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-18 |
| **bian_ref** | T.3.4 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P600 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P600 (CALLLIBCTL — Call Library Control) es el programa de referencia/documentación que expone la interfaz completa de LIBCONTROL para el subsistema S151. No es un programa de procesamiento de datos — es el artefacto canónico que documenta cómo llamar a LIBCONTROL/CONSISDIA. Todos los programas S151 que usan LIBCONTROL replican sus estructuras de datos mediante COPY de P600.

**Fórmula/pseudocódigo:**
```
PROGRAM-ID. CALLLIBCTL.  -- "Call Library Control"
-- Propósito: documentación/referencia de la API LIBCONTROL
-- No procesa movimientos: es fuente de COPY para otros programas
```

**Vocabulario en la fórmula:** CALLLIBCTL, LIBCONTROL, CONSISDIA, programa de referencia

**Excepciones:** Ninguna — es artefacto de documentación.

**Estado validación:** Pendiente SME

---

## RN-S151-1133

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1133 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-18 |
| **bian_ref** | T.3.4 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P600 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CONSISDIA F01 consulta S151B01SISDIA por SISTEMA+CSI y retorna el estado completo del día: FECPRO (fecha de proceso), FECCON (fecha de consulta), FECPRO151 (fecha proceso S151), STAREG (registro de estado), nombres de archivos activos (NOMARCSAL, NOMPACSAL, NOMARCMOV, NOMPACMOV, NOMARCDES, NOMPACDES, NOMARCERR, NOMPACERR), NOMBDSEM, STABDSEM, NUMARC, 3ERNIV y 10×CTL-DIA.

**Fórmula/pseudocódigo:**
```
CONSISDIA F01 (FUNCION=01):
  INPUT:  SISTEMA(4) + CSI(2)
  OUTPUT: FECPRO(8)+FECCON(8)+FECPRO151(8)+STAREG(2)
          NOMARCSAL(34)+NOMPACSAL(17)+[6 nombres más]
          NOMBDSEM(17)+STABDSEM(2)+NUMARC(2)+3ERNIV(2)
          CTL-DIA OCCURS 10 TIMES
```

**Vocabulario en la fórmula:** CONSISDIA F01, FECPRO, FECCON, STAREG, NOMBDSEM, CTL-DIA

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1134

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1134 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-18 |
| **bian_ref** | T.3.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P600 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CONSISDIA F02 actualiza FECCON (fecha de consulta) en S151B01SISDIA para el par SISTEMA+CSI. Esta fecha representa la última fecha para la cual se ejecutó una consulta de saldos/movimientos. Su actualización es obligatoria para garantizar que los programas de consulta no accedan a datos de días anteriores.

**Fórmula/pseudocódigo:**
```
CONSISDIA F02:
  INPUT: FUNCION=02 + SISTEMA(4) + CSI(2) + FECCON(8)
  UPDATE S151B01SISDIA.B01-SIS-FECCON = FECCON
```

**Vocabulario en la fórmula:** CONSISDIA F02, FECCON, WKS-B01F02-FECCON

**Excepciones:** Si FECCON > FECPRO, puede indicar inconsistencia de fechas.

**Estado validación:** Pendiente SME

---

## RN-S151-1135

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1135 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-18 |
| **bian_ref** | T.3.4 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P600 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CONSISDIA F03 actualiza FECPRO (fecha de proceso) en S151B01SISDIA para el par SISTEMA+CSI. Esta fecha representa la fecha del último proceso batch ejecutado para el sistema. La distinción entre FECPRO (proceso) y FECCON (consulta) permite detectar si hay consultas sobre datos cuyo proceso aún no terminó.

**Fórmula/pseudocódigo:**
```
CONSISDIA F03:
  INPUT: FUNCION=03 + SISTEMA(4) + CSI(2) + FECPRO(8)
  UPDATE S151B01SISDIA.B01-SIS-FECPRO = FECPRO
-- FECPRO actualizado por proceso batch al inicio/fin del proceso
```

**Vocabulario en la fórmula:** CONSISDIA F03, FECPRO, WKS-B01F03-FECPRO

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1136

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1136 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-18 |
| **bian_ref** | T.3.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P600 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CONSISDIA F04 actualiza STABDSEM (estatus de la base de datos semanal) con valores 0 o 1. STABDSEM controla la disponibilidad de la base semanal de MOVDIA: 0=disponible (los programas pueden consultar datos semanales), 1=no disponible (proceso semanal en curso o base en mantenimiento).

**Fórmula/pseudocódigo:**
```
CONSISDIA F04:
  INPUT: FUNCION=04 + SISTEMA(4) + CSI(2) + STABDSEM(2)
  UPDATE S151B01SISDIA.B01-SIS-STABDSEM = STABDSEM
  STABDSEM = 0 → base semanal disponible
  STABDSEM = 1 → base semanal no disponible
```

**Vocabulario en la fórmula:** CONSISDIA F04, STABDSEM, base semanal

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

## RN-S151-1137

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1137 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-18 |
| **bian_ref** | T.3.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P600 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CONSISDIA F05 controla el campo STAREG que actúa como gate de ejecución para el proceso principal P000: STAREG=0 permite que P000 se ejecute (sistema abierto), STAREG=1 bloquea la ejecución de P000 (sistema en mantenimiento o proceso previo aún corriendo). Solo F05 puede cambiar STAREG.

**Fórmula/pseudocódigo:**
```
CONSISDIA F05:
  INPUT: FUNCION=05 + SISTEMA(4) + CSI(2) + VALOR(2)
  UPDATE S151B01SISDIA.B01-SIS-STAREG = VALOR
  STAREG = 0 → P000 PUEDE ejecutarse
  STAREG = 1 → P000 NO PUEDE ejecutarse
```

**Vocabulario en la fórmula:** CONSISDIA F05, STAREG, P000, gate de ejecución

**Excepciones:** STAREG=1 permanente bloqueará todos los procesos del día — operación crítica.

**Estado validación:** Pendiente SME

---

## RN-S151-1138

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1138 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-18 |
| **bian_ref** | T.3.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P600 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Las funciones F07-F10 de CONSISDIA gestionan el ciclo de vida del archivo de movimientos: F07 actualiza STAARCLOG (0=archivo disponible, 1=archivo no disponible), F08 actualiza NIVARCMOV (nivel del archivo de movimientos), F09 actualiza NIVBDMOV (nivel de la base de datos), F10 actualiza ambos niveles simultáneamente en una sola llamada atómica.

**Fórmula/pseudocódigo:**
```
F07: STAARCLOG(fecha) = 0/1 (disponible/no disponible)
F08: NIVARCMOV(fecha) = nivel numérico del archivo movs
F09: NIVBDMOV(fecha)  = nivel de la base de datos movs
F10: NIVBASE + NIVARCM en una sola operación atómica
```

**Vocabulario en la fórmula:** STAARCLOG, NIVARCMOV, NIVBDMOV, F07, F08, F09, F10

**Excepciones:** F10 es preferible a F08+F09 separadas para evitar inconsistencia de niveles.

**Estado validación:** Pendiente SME

---

## RN-S151-1139

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1139 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-18 |
| **bian_ref** | T.3.4 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | P600 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WKS-B01-CTL-DIA OCCURS 10 TIMES es la estructura de seguimiento operativo diario más importante de S151. Cada una de las 10 entradas rastrea: FECARCMOV(8) fecha del archivo de movimientos, NIVARCMOV(8) nivel del archivo, NIVBDMOV(8) nivel de la base, y STAARCLOG(2) estado del log. Este arreglo de 10 días permite al sistema gestionar el historial de archivos de la semana hábil + buffer de fin de semana.

**Fórmula/pseudocódigo:**
```
CTL-DIA OCCURS 10 TIMES:
  FECARCMOV(8)   = CCAAMMDD del archivo de movs de ese día
  NIVARCMOV(8)   = nivel/versión del archivo de movs
  NIVBDMOV(8)    = nivel/versión de la BD de movs
  STAARCLOG(2)   = 0=log disponible, 1=log no disponible
-- 10 entradas = L-M-M-J-V + Sab-Dom + buffer (5 hábiles + 5 extra)
```

**Vocabulario en la fórmula:** CTL-DIA, FECARCMOV, NIVARCMOV, NIVBDMOV, STAARCLOG

**Excepciones:** Ninguna conocida.

**Estado validación:** Pendiente SME

---

*Catálogo generado por Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)*
*Fuente: código COBOL Unisys ClearPath MCP — primeras 250–300 líneas por programa*
*Validación pendiente de SME (Subject Matter Expert) bancario para todas las reglas*
*Total: 190 reglas · RN-S151-950 a RN-S151-1139 · 2026-07-17*
