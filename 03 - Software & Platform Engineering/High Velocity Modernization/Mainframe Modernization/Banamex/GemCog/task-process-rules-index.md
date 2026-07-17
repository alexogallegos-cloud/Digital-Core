# Índice Transversal: Tarea → Proceso → Regla · Banamex GemCog
> Gemelo Cognitivo · Capa 4 (Tareas) + Capa 5 (Casuísticas/Procesos) + referencia a Capa 2 (Reglas)
> Sistemas: S500 (Captación) + S151 (Movimientos Contables GL) · Unisys ClearPath MCP
> Última actualización: 2026-07-16 · v1.0 · Swarm 4 agentes (REC · TAR · SEC · CMP) + coordinador (GL)

---

## Resumen de cobertura

| Slug | Capacidad | ID | Dominio | Sistema | Tareas | Reglas vinculadas | Cap file |
|------|-----------|-----|---------|---------|--------|-------------------|----------|
| TAR | ATM · PoS — Liquidación Tarjetas | 2.2.6 · 2.2.7 | Channels | S500 | 15 | 10 (+9 pend.) | [cap-tar.md](capacidades/cap-tar.md) |
| CMP | Compliance & Regulation — FraudLink | 6.5.2 | Common Services | S500 | 9 | 9 | [cap-cmp.md](capacidades/cap-cmp.md) |
| PAY | Payments — Cargos y Abonos Core | 6.1.3 | Common Services | S500 | 13 | 17 (+3 pend.) | [cap-pay.md](capacidades/cap-pay.md) |
| INT | Interest & Fees — P130 Rendimientos | 6.1.5 | Common Services | S500 | 28 | 29 | [cap-int.md](capacidades/cap-int.md) |
| ORC | Operational Reconciliation — S151REGISTRA | 6.7.2 | Common Services | S500+S151 | 15 | 20 | [cap-orc.md](capacidades/cap-orc.md) |
| REC | Financial Reconciliation — Punteo | 6.7.1 | Common Services | S151 | 16 | 20 | [cap-rec.md](capacidades/cap-rec.md) |
| GL | Finance (GL) — Motor de Asientos | 7.1.1 | Enterprise Support | S151 | 16 | 18 (+22 pend.) | [cap-gl.md](capacidades/cap-gl.md) |
| SCH | Scheduling — Cierre Día + Oracle Fechas | 8.1.1 | Technology Tools | S500+S151 | 15 | 18 | [cap-sch.md](capacidades/cap-sch.md) |
| ODS | Operational Data Stores — Modelo DMSII | 9.1.1 | Insights & Information | S500+S151 | 27 | 35 (+4 pend.) | [cap-ods.md](capacidades/cap-ods.md) |
| SEC | Security — Enmascaramiento PII | T.3.5 | Transversal | S500 | 10 | 11 (+1 pend.) | [cap-sec.md](capacidades/cap-sec.md) |
| RPT | Analytics/Reporting — Ciclo Control + Reporte Regulatorio | T.3.4 | Transversal | S151 | 31 | 70 | [cap-rpt.md](capacidades/cap-rpt.md) |
| ADJ | GL Adjustments & Sync — BC-09 Extracción/Integración Saldos | 7.1.1-bc09 | Enterprise Support | S151 | 38 | 37 | [cap-adj.md](capacidades/cap-adj.md) |
| **Total** | | | | | **233** | **294** | |

**Tipos de tarea:** `validación` · `consulta` · `escritura` · `contable` · `control` · `seguridad` · `reporte`

---

## Dominio 2 — Channels

---

### TAR — ATM · PoS — Liquidación de Tarjetas de Intercambio [S500]
> Dominio: 2 · Channels · Capacidad: 2.2.6 ATM · 2.2.7 PoS
> Programa: S500P630 (TARINTERCAM) · Reglas: RN-S500-037..055

#### Inventario de Tareas

| ID | Tarea | Programa | Componente fuente | Tipo |
|----|-------|----------|-------------------|------|
| T-TAR-001 | Validar versión del programa contra catálogo central CTLVERS | S500P630 | COBOL_S500P630.txt | validación |
| T-TAR-002 | Resolver librería de cálculo de fechas vía DAME_TIT IN CTLVERS | S500P630 | COBOL_S500P630.txt | control |
| T-TAR-003 | Inicializar archivo de salida S244 con cabecera (cadena Teletón) | S500P630 | COBOL_S500P630.txt | escritura |
| T-TAR-004 | Leer siguiente movimiento de tarjeta de S500B02TMOVTOS (LOCK NEXT) | S500P630 | COBOL_S500P630.txt | consulta |
| T-TAR-005 | Clasificar estatus contable del movimiento (00=vigente · 15=Amex · otros=omitir) | S500P630 | COBOL_S500P630.txt | validación |
| T-TAR-006 | Detectar tipo de captura (manual = Base24 vacío/000000 · automática = Base24 válido) | S500P630 | COBOL_S500P630.txt | validación |
| T-TAR-007 | Calcular BIN adquirente por primer dígito de tarjeta (3/4→454061 · otros→543006) | S500P630 | COBOL_S500P630.txt | validación |
| T-TAR-008 | Calcular dígito verificador Luhn para referencia de 23 posiciones (WKS-I04-RE-*) | S500P630 | COBOL_S500P630.txt | validación |
| T-TAR-009 | Calcular día juliano del movimiento vía librería S000LIBFEC (DAME_DIAJUL2K) | S500P630 | COBOL_S500P630.txt | consulta |
| T-TAR-010 | Grabar registro de detalle en archivo S244 (paragraph 930-GRABA-I04) | S500P630 | COBOL_S500P630.txt | escritura |
| T-TAR-011 | Grabar registro de punteo hacia S151 en archivo I08 (paragraph 960-GRABA-I08) | S500P630 | COBOL_S500P630.txt | contable |
| T-TAR-012 | Grabar registro American Express en archivo AMEXMNL → INTELAR | S500P630 | COBOL_S500P630.txt | escritura |
| T-TAR-013 | Acumular contador e importe en variables de cierre (WKS-NUM-REG / WKS-IMP-TOT) | S500P630 | COBOL_S500P630.txt | control |
| T-TAR-014 | Capturar interrupción externa (TASKVALUE) y registrar rastro de auditoría | S500P630 | COBOL_S500P630.txt | control |
| T-TAR-015 | Escribir trailer de cierre en archivo S244 con contadores acumulados | S500P630 | COBOL_S500P630.txt | escritura |

#### Reglas vinculadas

| Tarea | Regla | Descripción |
|-------|-------|-------------|
| T-TAR-001 | RN-S500-038 | Validación de versión autorizada antes de procesar |
| T-TAR-002 | RN-S500-039 | Resolución dinámica de librería de fechas CTLVERS |
| T-TAR-003 | RN-S500-040 | Etiquetado de archivo S244 como cadena Teletón |
| T-TAR-004 | RN-S500-041 | Control de lectura y terminación ante errores DMSII |
| T-TAR-005 | RN-S500-042 | Doble salida vigente hacia S244 y S151 (estatus 00) |
| T-TAR-005 | RN-S500-043 | Ruta diferenciada para movimientos American Express (estatus 15) |
| T-TAR-006 | RN-S500-044 | Clasificación manual o automática por campo Base24 |
| T-TAR-007 | RN-S500-045 | Asignación de BIN adquirente por primer dígito (3/4→454061 · otros→543006) |
| T-TAR-008 | RN-S500-046 | Dígito verificador tipo Luhn para referencia 23 |
| T-TAR-014 | RN-S500-037 | Rastro de auditoría ante interrupción de proceso (TASKVALUE) |

> **RN-S500-047..055** (9 reglas pendientes de mapeo): día juliano, armado campos punteo I08, datos AMEXMNL, contadores cierre.

---

## Dominio 6 — Common Services

---

### CMP — Compliance & Regulation — Reporte Diario FraudLink CNBV [S500]
> Dominio: 6 · Common Services · Capacidad: 6.5.2
> Programa: P103 (FraudLink) · Reglas: RN-S500-001..008

#### Inventario de Tareas

| ID | Tarea | Programa | Componente fuente | Tipo |
|----|-------|----------|-------------------|------|
| T-CMP-001 | Validar versión del programa contra catálogo S100VERSIONES (CHECAME IN CTLVERS); abort con STATUS=-1 si S000-CTR-CVEERROR < 0 — sin abrir archivo de salida | P103 | COBOL_P103.txt | validación |
| T-CMP-002 | Leer registro de control S500B02CONTROL (B02-NUM-CSI + B02-FECHA-LOTE para cabecera); abort vía CALL SYSTEM DMTERMINATE si WS-STATUS-BASE > 0 | P103 | COBOL_P103.txt | consulta |
| T-CMP-003 | Leer secuencialmente movimientos del día desde S500B07MOVDIA (90000007-B07MOVDIA-FINDN): WS-STATUS-BASE=1=EOF normal; otro valor > 0 → DMTERMINATE sin trailer | P103 | COBOL_P103.txt | consulta |
| T-CMP-004 | Filtrar movimientos con B07-STATUS-MOVTO = 1: excluir del análisis sin traza ni contador | P103 | COBOL_P103.txt | validación |
| T-CMP-005 | Evaluar código de transacción principal: si B07-CLAVE-MOVTO = 2001/2444/2496 → generar registro FraudLink con sucursal (WKS-SUC-OPE de REDEFINES B07-AUTORIZACION), B07-MED-ACCESO, B02-FECHA-LOTE, importe y referencia | P103 | COBOL_P103.txt | reporte |
| T-CMP-006 | Evaluar hasta 5 sub-movimientos SAD (B07-OTROS-MOVSAD × PERFORM 5 TIMES): por cada B07-CVE-MOVAD = 2001/2444/2496 → registro FraudLink con WKS-SUC-OPE heredada del movimiento padre | P103 | COBOL_P103.txt | reporte |
| T-CMP-007 | Evaluar hasta 10 claves adicionales B13 (si B07-IND-MOVSADS > 0): buscar S500B13MOVCVES por B07-NUM-CONTRATO + B07-AUTORIZACION; recorrer B13-CLAVES-TRANS × 10; por cada B13-CLAVE-MOVTO = 2001/2444/2496 → registro FraudLink con B13-IMPORTE + B13-REF-MOVAD | P103 | COBOL_P103.txt | reporte |
| T-CMP-008 | Acumular por cada registro escrito: ADD 1 TO WKS-NUM-REG (PIC 9(08)) + ADD WKS-REG-E03-IMPORTE TO WKS-IMP-TOT (PIC 9(12)V99) | P103 | COBOL_P103.txt | control |
| T-CMP-009 | Escribir trailer de cierre tipo "9" (WKS-E03-TRAILER) con WKS-NUM-REG y WKS-IMP-TOT para validación de integridad por FraudLink/CNBV | P103 | COBOL_P103.txt | reporte |

#### Reglas vinculadas

| Tarea | Regla | Descripción | Base regulatoria |
|-------|-------|-------------|-----------------|
| T-CMP-001 | RN-S500-001 | Validación de versión ante CTLVERS — abort si S000-CTR-CVEERROR < 0 | Control interno |
| T-CMP-002 | RN-S500-002 | Lectura S500B02CONTROL — abort DMTERMINATE si WS-STATUS-BASE > 0; B02-FECHA-LOTE como fecha de proceso | CNBV |
| T-CMP-003 | RN-S500-003 | Control EOF: STATUS=1=normal; otro valor>0=DMTERMINATE sin trailer | Control interno |
| T-CMP-004 | RN-S500-004 | Exclusión silenciosa B07-STATUS-MOVTO=1 (hipótesis: cancelado) — sin traza | CNBV |
| T-CMP-005 | RN-S500-005 | Reporte principal: códigos 2001/2444/2496 hardcoded; WKS-REG-E03-CHQRA=B07-MED-ACCESO | CNBV |
| T-CMP-006 | RN-S500-006 | Hasta 5 SAD (PERFORM 5 TIMES hardcoded); WKS-SUC-OPE heredado del padre | CNBV |
| T-CMP-007 | RN-S500-007 | Hasta 10 claves B13 (estructura×10 hardcoded); FK B07-NUM-CONTRATO+B07-AUTORIZACION | CNBV |
| T-CMP-008 | RN-S500-008 | Acumulación ADD: WKS-NUM-REG PIC 9(08) + WKS-IMP-TOT PIC 9(12)V99; importe truncado a 11 dígitos | CNBV |
| T-CMP-009 | RN-S500-008 | Trailer tipo "9" con totales para validación CNBV de integridad del archivo | CNBV |

---

### REC — Financial Reconciliation — Punteo por Claves de Transacción [S151]
> Dominio: 6 · Common Services · Capacidad: 6.7.1
> Programa: P112 (PUNTEO POR CLAVES DE TRANSACCION) · Reglas: RN-S151-001..020

#### Inventario de Tareas

| ID | Tarea | Programa | Componente fuente | Tipo |
|----|-------|----------|-------------------|------|
| T-REC-001 | Validar que el sistema existe y está activo en BD99CONTROL vía LIBCONTROL | P112 | COBOL_P112.txt | validación |
| T-REC-002 | Determinar fecha de proceso: parámetro WKS-PARAM-FCH prevalece sobre base de control | P112 | COBOL_P112.txt | control |
| T-REC-003 | Convertir fecha a 8 dígitos (AAAAMMDD) desde 6 dígitos (AAMMDD) vía parche CRONOS2K (umbral año ≤50 = siglo XXI) | P112 | COBOL_P112.txt | control |
| T-REC-004 | Cargar catálogo paramétrico PT en memoria: máx 9,999 claves (WKS-PT-CGENTRA, NATS028, INDS151, INDBITA) | P112 | COBOL_P112.txt | control |
| T-REC-005 | Cargar tabla de leyendas TRANS1..4 en memoria: máx 12,000 claves distribuidas en 4 segmentos de 3,000 | P112 | COBOL_P112.txt | control |
| T-REC-006 | Filtrar archivo de entrada: solo FUNCION=1 (alta) AND STATUS=1 (pendiente punteo) | P112 | COBOL_P112.txt | validación |
| T-REC-007 | Normalizar campo de producto: S403/S404→número de fideicomiso (A00-R01-FIDEICO); S087→código 87 hardcoded | P112 | COBOL_P112.txt | validación |
| T-REC-008 | Normalizar moneda y libro para lookup: S403/S404→CAT-MON=0·CAT-LIBRO=0; S264/S703/S018/S017→CAT-MON=01 (MXN) | P112 | COBOL_P112.txt | validación |
| T-REC-009 | Ordenar movimientos filtrados por clave 5-dimensional LIBRO+PRODUCTO+MONEDA+CVETRAN+ESQCON (16 posiciones) | P112 | COBOL_P112.txt | control |
| T-REC-010 | Validar libro contable del movimiento contra tabla interna de 12 libros hardcoded (incluye FOBAPROA) | P112 | COBOL_P112.txt | validación |
| T-REC-011 | Resolver naturaleza contable del movimiento consultando tabla S028: 1=CARGO · 2=ABONO · 3=NEUTRO · 4=COMPENSACION | P112 | COBOL_P112.txt | contable |
| T-REC-012 | Gate de equivalencia INDS151=2: construir KEY-CAT 7 campos (REDEFINES COMP) y buscar en ARCH-CAT | P112 | COBOL_P112.txt | contable |
| T-REC-013 | Validar fondos S403 (FIRA/FONATUR/BANCOMEXT/NAFIN) y 9 productos S404 hardcoded | P112 | COBOL_P112.txt | validación |
| T-REC-014 | Reportar brecha: emitir "REL-TRAN-GUIA CONTABLE INEXISTENTE" en WLI-TIPOERROR → WLI-AFECS115=15 | P112 | COBOL_P112.txt | contable |
| T-REC-015 | Acumular totales en control break 5 niveles (LIBRO › PRODUCTO › MONEDA › CVETRAN › ESQCON) con W77-IMPMOV + W77-NUMMOV | P112 | COBOL_P112.txt | contable |
| T-REC-016 | Paginar reporte: 50 líneas/hoja, encabezado con fecha + número de hoja + "....CONTINUA" al pie | P112 | COBOL_P112.txt | escritura |

#### Reglas vinculadas

| Tarea | Regla | Descripción | Tags |
|-------|-------|-------------|------|
| T-REC-001 | RN-S151-001 | Validación de sistema en BD99CONTROL antes de iniciar | — |
| T-REC-002 | RN-S151-002 | Fecha proceso: parámetro prevalece sobre base de control | — |
| T-REC-003 | RN-S151-019 | CRONOS2K — conversión año 2 dígitos a 4 (umbral 50) | `[HARDCODE-SOSPECHOSO]` |
| T-REC-004 | RN-S151-013 | Límite 9,999 claves en catálogo PT — overflow aborta todo | `[HARDCODE-SOSPECHOSO]` |
| T-REC-005 | RN-S151-012 | Límite 12,000 claves en tablas TRANS1..4 — overflow aborta todo | `[HARDCODE-SOSPECHOSO]` |
| T-REC-006 | RN-S151-003 | Filtro doble FUNCION=1 AND STATUS=1 — silencioso para otros valores | — |
| T-REC-007 | RN-S151-005 | S403/S404 fideicomiso como producto (segmentación CNBV) | `[REGLA-CNBV]` |
| T-REC-007 | RN-S151-006 | S087 producto hardcoded=87 sin leer A00-R01-PRODUCTO | `[HARDCODE-SOSPECHOSO]` |
| T-REC-008 | RN-S151-010 | Normalización MON=0 · LIBRO=0 para S403/S404 antes de ARCH-CAT | — |
| T-REC-008 | RN-S151-011 | S264/S703/S018/S017 solo moneda base MXN (CAT-MON=01) | — |
| T-REC-009 | RN-S151-004 | Sort 5-dimensional: LIBRO+PRODUCTO+MONEDA+CVETRAN+ESQCON | — |
| T-REC-010 | RN-S151-015 | 12 libros contables hardcoded (incl. FOBAPROA residual 1994-1995) | `[HARDCODE-SOSPECHOSO]` `[REGLA-CNBV]` |
| T-REC-011 | RN-S151-007 | Naturaleza S028: 1=CARGO · 2=ABONO · 3=NEUTRO · 4=COMPENSACION | — |
| T-REC-012 | RN-S151-008 | Gate equivalencia: INDS151=2 + match ARCH-CAT → punteo | `[RIESGO-EQUIVALENCIA]` |
| T-REC-012 | RN-S151-009 | Clave ARCH-CAT: 7 campos REDEFINES COMP (frágil ante cambios layout) | — |
| T-REC-013 | RN-S151-016 | S403: fondos válidos hardcoded FIRA/FONATUR/BANCOMEXT/NAFIN | `[HARDCODE-SOSPECHOSO]` |
| T-REC-013 | RN-S151-017 | S404: 9 tipos de producto hardcoded — descarte silencioso si hay 10° | `[HARDCODE-SOSPECHOSO]` |
| T-REC-014 | RN-S151-020 | "REL-TRAN-GUIA CONTABLE INEXISTENTE" — diagnóstico brecha (texto exacto 35 chars) | `[RIESGO-EQUIVALENCIA]` |
| T-REC-015 | RN-S151-014 | 5 niveles de control break — totales jerárquicos del reporte | — |
| T-REC-016 | RN-S151-018 | Paginación 50 líneas/hoja + encabezado + literal "....CONTINUA" | — |

---

### PAY — Payments — Cargos y Abonos Core [S500]
> Dominio: 6 · Common Services · Capacidad: 6.1.3
> Programa: P020 (LINCOMS) · P142 · P144 · Reglas: RN-S500-108..122

#### Inventario de Tareas

| ID | Tarea | Programa | Tipo |
|----|-------|----------|------|
| T-PAY-001 | Clasificación de CVETRAN en rangos NCO / CARGO / ABONO | P020 | validación |
| T-PAY-002 | Validación contra catálogo 174 (CVETXN autorizado) | P020 | validación |
| T-PAY-003 | Enrutamiento de copias COMS y asignación de TIPO-PROC S151 | P020 | control |
| T-PAY-004 | Ordenamiento y generación del archivo posting S02 | P020 | contable |
| T-PAY-005 | Asiento en libro mayor S151 (REGISTRAS500) | P020 | escritura |
| T-PAY-006 | Cálculo de IVA e ISR sobre comisiones y rendimientos | P020 | contable |
| T-PAY-007 | Procesamiento TEF — asignación y reasignación de cuentas | P020 | escritura |
| T-PAY-008 | Replicación cross-CSI del estado TEF (I11-REPLICA) | P020 | control |
| T-PAY-009 | Control de apagado diferenciado del gateway COMS | P020 | control |
| T-PAY-010 | Toggle en caliente de integración S151 (TASKVALUE=3027) | P020 | control |
| T-PAY-011 | Cierre de día contable — cancelación y recarga de librerías | P020 | contable |
| T-PAY-012 | Decomiso EPP — bloque judicial (TASKVALUE=3019) | P020 | escritura |
| T-PAY-013 | Proceso DIVESTITURE Citi→Banamex (TASKVALUE=3016) | P020 | control |

#### Reglas vinculadas

| Tarea | Regla | Componente fuente | Descripción |
|-------|-------|-------------------|-------------|
| T-PAY-001 | RN-S500-115 | P020 — WKS-CVETXN-NCO/ABO/CAR | Clasificación CVETRAN en rangos NCO (0-999), ABONO (1000-1999, 3000-3999), CARGO (2000-2999) |
| T-PAY-002 | RN-S500-116 | P020 — WKS-CAT174-CVETXN | Validación CVETXN catálogo 174 dinámico; recargable en caliente |
| T-PAY-003 | RN-S500-108 | P020 — WS-S151-TIPO-PROC | Asignación tipo-proceso S151 por copia: 1→33, 2→34, 3→35, 4→36, 5→37 |
| T-PAY-003 | RN-S500-109 | P020 — WKS-SIGUIENTE | Tabla fija de failover de copias: 1→03, 2→01, 3→04, 4→02, 5→02 |
| T-PAY-004 | RN-S500-117 | P020 — S02-KEY-CVETXN | Clave S02: CVETXN(4)+SUC+CTO+IMP+PROD+INST+MON; rechazos → I10-POSTING-E |
| T-PAY-005 | RN-S500-108 | P020 — REGISTRAS500 | Posting GL S151 con TIPO-PROC diferenciado por copia |
| T-PAY-005 | RN-S500-114 | P020 — WS-UTILIZA-S151-VA | Toggle en caliente S151 vía TASKVALUE=3027 |
| T-PAY-006 | RN-S500-122 | P020 — WS-IVA-GRAL, WS-ISR-0 | IVA 16%/11% + ISR factor 0.50 hardcodeado en P020+P010+P142+P144 |
| T-PAY-007 | RN-S500-110 | P020 — WS-SOLO-VDM | Hostname MTY: solo copias 1/2/3 VDM para TEF |
| T-PAY-007 | RN-S500-121 | P020 — WS-88-ASIGNA-TEF | TEF CVETRANs: 759/760/761/762 (masivos vs simples) |
| T-PAY-008 | RN-S500-111 | P020 — WKS-HOST-ORIG/DEST-XFER | 8 pares host cross-CSI hardcodeados para replicación TEF VDM↔MTY |
| T-PAY-008 | RN-S500-112 | P020 — 50201400-I11-REPLICA | COPIA-5 modo LINEA: WAIT 1200s antes de replicar |
| T-PAY-009 | RN-S500-113 | P020 — SMCOMS-DISABLE | TASKVALUE=3004 apaga cualquier copia; 3104 apaga solo COPIA-1 |
| T-PAY-010 | RN-S500-114 | P020 — WS-UTILIZA-S151-VA | Toggle S151 — mismo mecanismo que T-PAY-005 |
| T-PAY-011 | RN-S500-119 | P020 — CAMBIA-DIA-CONTABLE | Cancela 7 librerías + espera 5s + recarga; COPIA-3 cancela S500L050DYR |
| T-PAY-012 | RN-S500-118 | P020 — DECOMISO-S111 | TASKVALUE=3019; CVETXN 534+575 reversión EPP |
| T-PAY-013 | RN-S500-120 | P020 — WFL23 | TASKVALUE=3016 → bloque *INI/*FIN DIVESTITURE extraíble sin reiniciar |

> **Pendientes**: recarga catálogo 174 (TASKVALUE no identificado) · estado DIVESTITURE pendiente confirmación legal · P142/P144 reglas propias no capturadas en este cap.

---

### INT — Interest & Fees — Rendimientos e ISR [S500]
> Dominio: 6 · Common Services · Capacidad: 6.1.5
> Programa: S500/P130 · WFL LINEA · Reglas: RN-S500-079..107

#### Inventario de Tareas

| ID | Tarea | Programa | Componente fuente | Tipo |
|----|-------|----------|-------------------|------|
| T-INT-001 | Calcular flags de calendario del día (DIA30 / DIA15 / DIA1MES) | WFL LINEA | S500_WFL_LOTE.txt | control |
| T-INT-002 | Habilitar LINCOMS y programas online en COMS (SUBETODOS) | WFL LINEA | S500_WFL_LOTE.txt | control |
| T-INT-003 | Detectar modo de proceso mensual (WKS-ES-MENSUAL = 0/1) | P130 | S500_SOURCE_P130.txt | control |
| T-INT-004 | Inicializar identificador de asiento GL hacia S151 (W77-ID-P-S151 = 30/31/32) | P130 | S500_SOURCE_P130.txt | control |
| T-INT-005 | Controlar bypass de emergencia de librería S151 (WKS-SIN-LBS151) | P130 | S500_SOURCE_P130.txt | control |
| T-INT-006 | Validar tasas CETES/LIBOR como gate de proceso (VAL-CETES-LIBOR) | P130 | S500_SOURCE_P130.txt | validación |
| T-INT-007 | Calcular saldo promedio anual por contrato (WKS-PROM-ANUAL) | P130 | S500_SOURCE_P130.txt | consulta |
| T-INT-008 | Ajustar días del período por cancelación o cambio de producto (-1 día) | P130 | S500_SOURCE_P130.txt | validación |
| T-INT-009 | Calcular saldo promedio extendido para ciclos parciales (WKS-PROM-ANUAL-EXT) | P130 | S500_SOURCE_P130.txt | consulta |
| T-INT-010 | Evaluar capitalización por estado del contrato (50116000-ANALIZA-CAPITALIZ) | P130 | S500_SOURCE_P130.txt | control |
| T-INT-011 | Capitalizar rendimiento periódico al vencimiento del ciclo (IND-RENDDIA = 0) | P130 | S500_SOURCE_P130.txt | escritura |
| T-INT-012 | Acumular rendimiento diario y calcular tasa promedio en cierre mensual (IND-RENDDIA = 1) | P130 | S500_SOURCE_P130.txt | escritura |
| T-INT-013 | Completar ISR valorizado de cancelación en línea USD (B06-IMPTO-VALMN · P010→P130) | P130 | S500_SOURCE_P130.txt | escritura |
| T-INT-014 | Generar asiento GL rendimiento neto hacia S151 (CVE-COMUN 3000) | P130 | S500_SOURCE_P130.txt | contable |
| T-INT-015 | Generar asiento GL ISR retenido hacia S151 (CVE-COMUN 4009) | P130 | S500_SOURCE_P130.txt | contable |
| T-INT-016 | Generar asiento GL rendimiento bruto hacia S151 (CVE-COMUN 809) | P130 | S500_SOURCE_P130.txt | contable |
| T-INT-017 | Convertir rendimientos e ISR USD a MXN para asientos GL (W77-TCAMBIO-VTA · ROUNDED) | P130 | S500_SOURCE_P130.txt | contable |
| T-INT-018 | Clasificar contrato en archivo de rendimientos I05 por esquema ESQ-REND (TARIFA + REGION) | P130 | S500_SOURCE_P130.txt | escritura |
| T-INT-019 | Registrar ISR de plan de ahorro EPP en cierre mensual (50120000-SALIDA-IMPUESTO) | P130 | S500_SOURCE_P130.txt | contable |
| T-INT-020 | Evaluar pre-cancelación por saldo promedio mínimo insuficiente (50116650-VE-PRECANCEL) | P130 | S500_SOURCE_P130.txt | control |
| T-INT-021 | Cobrar comisión por exceso de depósitos en el ciclo (50116660-VE-IMPDEPCICLO) | P130 | S500_SOURCE_P130.txt | contable |
| T-INT-022 | Ejecutar traspaso automático a cuenta de beneficencia Art. 61 CUB (50113600-TRASP-BENEF) | P130 | S500_SOURCE_P130.txt | control |
| T-INT-023 | Consultar comisión aplicable en catálogo S080 (DAME-COMISION) | P130 | S500_SOURCE_P130.txt | consulta |
| T-INT-024 | Resolver esquema de comisión por tipo de persona PF/PM (20530130-DAME-ESQCOMI) | P130 | S500_SOURCE_P130.txt | consulta |
| T-INT-025 | Despachar hasta 15 comisiones mensuales por contrato (20530000-COMIS-MENSUAL) | P130 | S500_SOURCE_P130.txt | control |
| T-INT-026 | Cobrar comisión de manejo de cuenta con exención por SBC o nómina (tariff #018) | P130 | S500_SOURCE_P130.txt | contable |
| T-INT-027 | Cobrar comisión de aniversario en fecha de vencimiento anual (tariff #017 · slot 4) | P130 | S500_SOURCE_P130.txt | contable |
| T-INT-028 | Activar condicionalmente programas Telethon P045/P046 por archivo de control DMSII | WFL LINEA | S500_WFL_LOTE.txt | control |

#### Reglas vinculadas

| Tarea | Regla | Componente fuente | Descripción |
|-------|-------|-------------------|-------------|
| T-INT-001 | RN-S500-104 | S500_WFL_LOTE.txt | Detección último día hábil del mes (DIA30): IFECHAPROX MOD 100 = 1 |
| T-INT-001 | RN-S500-105 | S500_WFL_LOTE.txt | Detección quincenal (DIA15) — activa también cuando DIA30=TRUE |
| T-INT-002 | RN-S500-107 | S500_WFL_LOTE.txt | Habilitación LINCOMS al inicio del día (SUBETODOS) |
| T-INT-003 | RN-S500-079 | S500_SOURCE_P130.txt | Modo mensual: WKS-ES-MENSUAL=1 si DIA30 |
| T-INT-004 | RN-S500-080 | S500_SOURCE_P130.txt | W77-ID-P-S151 = 30/31/32 para tipo de asiento S151 |
| T-INT-005 | RN-S500-081 | S500_SOURCE_P130.txt | Bypass emergencia S151 (WKS-SIN-LBS151): omite todos los asientos GL |
| T-INT-006 | RN-S500-082 | S500_SOURCE_P130.txt | Gate CETES/LIBOR: ABORT si fuera de rango |
| T-INT-007 | RN-S500-083 | S500_SOURCE_P130.txt | Saldo promedio anual: WKS-PROM-ANUAL = B06-ACUM-PROMANU / W77-DIAS-ANUAL |
| T-INT-008 | RN-S500-084 | S500_SOURCE_P130.txt | Ajuste -1 día si B03-STATUS=2 (cancelado) o cambio de producto |
| T-INT-009 | RN-S500-085 | S500_SOURCE_P130.txt | Saldo promedio extendido WKS-PROM-ANUAL-EXT para ciclo parcial |
| T-INT-010 | RN-S500-086 | S500_SOURCE_P130.txt | Switch capitalización por B03-STATUS (0/1/5=vigente, 2=cancelado) |
| T-INT-011 | RN-S500-087 | S500_SOURCE_P130.txt | Capitalización: B03-SDO-ACTUAL += WS-CAP-RENDNETO al vencimiento del ciclo |
| T-INT-012 | RN-S500-088 | S500_SOURCE_P130.txt | Acumulación diaria: tasa = B03-INTS-CAPIT / WKS-SDOPROM-RENDIA × 36000 / B06-DIAPAG-RENDIA |
| T-INT-013 | RN-S500-089 | S500_SOURCE_P130.txt | ISR valorizado no acumulado cancelación USD: compensación P010→P130 en B06-IMPTO-VALMN |
| T-INT-014 | RN-S500-091 | S500_SOURCE_P130.txt | Asiento CVE 3000 (rendimiento neto) hacia S151REGISTRA |
| T-INT-015 | RN-S500-092 | S500_SOURCE_P130.txt | Asiento CVE 4009 (ISR retenido) — 4 líneas GL para USD (partida doble MXN+USD) |
| T-INT-016 | RN-S500-093 | S500_SOURCE_P130.txt | Asiento CVE 809 (rendimiento bruto = neto + ISR); base reportes Serie R-04 CNBV |
| T-INT-017 | RN-S500-094 | S500_SOURCE_P130.txt | Conversión USD→MXN con W77-TCAMBIO-VTA y ROUNDED (half-up) |
| T-INT-018 | RN-S500-095 | S500_SOURCE_P130.txt | Clasificación I05-RENDIMIENTOS: TARIFA 1-7 / REGION según B03-ESQ-REND |
| T-INT-019 | RN-S500-090 | S500_SOURCE_P130.txt | ISR EPP en B06-ISR-RET-EPP; liberado a S151 solo en cierre mensual |
| T-INT-020 | RN-S500-096 | S500_SOURCE_P130.txt | Pre-cancelación saldo mínimo: 50116650-VE-PRECANCEL en día de corte |
| T-INT-021 | RN-S500-097 | S500_SOURCE_P130.txt | Comisión depósitos excedentes: 50116660-VE-IMPDEPCICLO en día de corte |
| T-INT-022 | RN-S500-098 | S500_SOURCE_P130.txt | Traspaso Art. 61 CUB: primer viernes aniversario, MXN, STA-BENEF IN 3 8 |
| T-INT-023 | RN-S500-099 | S500_SOURCE_P130.txt | Consulta DAME-COMISION en S080 (OCCURS 210 esquemas) |
| T-INT-024 | RN-S500-103 | S500_SOURCE_P130.txt | PF (WS-IND-PERS=1) vs PM (WS-IND-PERS=2) — DAME-ESQCOMI |
| T-INT-025 | RN-S500-100 | S500_SOURCE_P130.txt | Despachador hasta 15 comisiones mensuales (COMIS-MENSUAL) |
| T-INT-026 | RN-S500-101 | S500_SOURCE_P130.txt | Comisión manejo cuenta con exención SBC o nómina (Circular Banxico) |
| T-INT-027 | RN-S500-102 | S500_SOURCE_P130.txt | Comisión aniversario (tariff #017, slot 4 BD05); notificación CONDUSEF 30 días antes |
| T-INT-028 | RN-S500-106 | S500_WFL_LOTE.txt | Activación P045/P046 Telethon por archivo S500BD06TELETON/CONTROL en DMSII |

---

### ORC — Operational Reconciliation — Registro S151 Condicional [S500+S151]
> Dominio: 6 · Common Services · Capacidad: 6.7.2
> Programa: 15 programas S500 (P102..P180) + INC_WOR_CAN + INC_PRO_CAN · Reglas: RN-S500-153..172

#### Inventario de Tareas

| ID | Tarea | Programa / Componente | Tipo |
|----|-------|-----------------------|------|
| T-ORC-001 | Validar versión de librería REGISTRAS500 (CTLVERS S151L002R500) — marcar WKS-88-REGISTRAS500=1 | S500_INC_PRO_CAN.txt | control |
| T-ORC-002 | Inicializar constantes del mensaje S151: SISTEMA=500, fechas, CUENTA, SALDO-INI, IND-EDOCTA, IND-DATOS-ADIC | S500_INC_PRO_CAN.txt | control |
| T-ORC-003 | Aplicar overrides de SUCPROM por CVETRAN (4159/4160→342; 4449→859; 2136/2137/2138→SUCTRAN) | S500_INC_PRO_CAN.txt | contable |
| T-ORC-004 | Aplicar overrides de SUCS028/CAJS028 por perfil PIM y CVETRAN (3002/4001/3018/4016/3027/3047/1153) | S500_INC_PRO_CAN.txt | contable |
| T-ORC-005 | Asignar código de moneda (MONEDA=1 para pesos MXN) por CVETRAN específico | S500_INC_PRO_CAN.txt | contable |
| T-ORC-006 | Clasificar sobregiro (SGIRO=0/1/2) y tipo de proceso (TIPO-PROC=1/10/20) | S500_INC_WOR_CAN.txt | validación |
| T-ORC-007 | Clasificar origen de operación (ORIGEN=1 local / 2 foráneo-enviado / 3 foráneo-recibido) | S500_INC_WOR_CAN.txt | validación |
| T-ORC-008 | Acumular CVETRANs de entrada en slots 1..5 del mensaje (loop hasta 30 entradas, WS-S151-IND) | S500_INC_PRO_CAN.txt | contable |
| T-ORC-009 | Propagar leyenda de clave principal a claves adicionales de corresponsales (CVETRAN 1119/1120/2200) | S500_INC_PRO_CAN.txt | escritura |
| T-ORC-010 | Auto-flush al overflow: enviar mensaje parcial (slots 1-5 llenos) y encadenar con REFS151-ANT | S500_INC_PRO_CAN.txt | contable |
| T-ORC-011 | Llamar CARGAMOV1 IN REGISTRAS500 con el mensaje acumulado (modo LINEA online) | S500_INC_PRO_CAN.txt | escritura |
| T-ORC-012 | Modo contingencia: encolar mensaje en archivo cuando WS-88-EN-CONTINGENCIA-S151=TRUE | S500_INC_PRO_CAN.txt | control |
| T-ORC-013 | Manejar rechazo STATUS > 0: grabar log de rechazos; en modo BATCHP130 escribir al R06 | S500_INC_PRO_CAN.txt | control |
| T-ORC-014 | Limpiar slots de CVETRANs y actualizar SALDO-FIN → SALDO-INI del siguiente ciclo | S500_INC_PRO_CAN.txt | control |
| T-ORC-015 | Actualizar contadores de monitoreo (W77-NUM-CALL-S151, W77-TOT-MOVS-ENV, W77-NUM-MOVS-ENV) | S500_INC_PRO_CAN.txt | control |

#### Reglas vinculadas

| Tarea | Regla | Componente fuente | Descripción |
|-------|-------|-------------------|-------------|
| T-ORC-001 | RN-S500-153 | S500_INC_PRO_CAN.txt | Validación versión S151 (CTLVERS S151L002R500); continúa aunque CVEERROR≠0 |
| T-ORC-002 | RN-S500-154 | S500_INC_WOR_CAN.txt | Contrato CARGAMOV1: 8 funciones (REGMOV/ELIMOV/INICIO/FIN/ELIPASO/ELIAUT/BLO50/BLO01) |
| T-ORC-002 | RN-S500-155 | S500_INC_WOR_CAN.txt | REGISTRA1 (CVETRAN 4 dígitos) vs REGISTRA2 (CVETRAN 6 dígitos + CVEDESVIO) |
| T-ORC-002 | RN-S500-161 | S500_INC_PRO_CAN.txt | IND-DATOS-ADIC siempre=1 (hardcode de performance; trabajo extra en S151) |
| T-ORC-002 | RN-S500-160 | S500_INC_PRO_CAN.txt | IND-EDOCTA: instrumento 6 de producto 500 → IND-EDOCTA=0; resto=1 |
| T-ORC-003 | RN-S500-162 | S500_INC_PRO_CAN.txt | SUCPROM override 4159/4160→342 (comentario dice 350, código mueve 342 — discrepancia) |
| T-ORC-003 | RN-S500-163 | S500_INC_PRO_CAN.txt | SUCPROM/SUCTRAN/SUCS028 override CVETRAN 4449/ACNOMINAPORTA→suc859, caj40 (SPEI CUT 2018) |
| T-ORC-003 | RN-S500-164 | S500_INC_PRO_CAN.txt | SUCPROM override 2136/2137/2138→SUCTRAN (P&L a sucursal operadora) |
| T-ORC-004 | RN-S500-165 | S500_INC_PRO_CAN.txt | SUCS028/CAJS028 por perfil PIM: CVETRANs 3002/4001/3018/4016 |
| T-ORC-004 | RN-S500-166 | S500_INC_PRO_CAN.txt | SUCS028 hardcode CVETRAN 3027: cajero 55 |
| T-ORC-004 | RN-S500-167 | S500_INC_PRO_CAN.txt | SUCS028 hardcode CVETRANs 3047 (caj92, suc342) y 1153+BIN554492 (caj60, suc7532) |
| T-ORC-005 | RN-S500-168 | S500_INC_PRO_CAN.txt | MONEDA=1 (MXN) para CVETRANs 13/14 + WS-CVE-DDISPNOEFECMn, RNEGAFILMN, RDISPEFECAJMN |
| T-ORC-006 | RN-S500-169 | S500_INC_WOR_CAN.txt | SGIRO: 0=no sobregiro · 1=línea vigente · 2=línea vencida (impacto IFRS 9) |
| T-ORC-007 | RN-S500-170 | S500_INC_WOR_CAN.txt | ORIGEN: 1=local · 2=foráneo enviado · 3=foráneo recibido |
| T-ORC-008 | RN-S500-156 | S500_INC_PRO_CAN.txt | Acumulación hasta 5 CVETRANs por mensaje (loop 30 entradas; slots 1→5) |
| T-ORC-009 | RN-S500-171 | S500_INC_PRO_CAN.txt | Propagación LEYENDA/INDLEY clave principal → claves adicionales corresponsales |
| T-ORC-010 | RN-S500-157 | S500_INC_PRO_CAN.txt | Auto-flush overflow: CALL parcial; REFS151→REFS151-ANT; slot 1 = CVETRAN desbordado |
| T-ORC-011 | RN-S500-158 | S500_INC_PRO_CAN.txt | Contingencia S151: encolar en archivo si WS-88-EN-CONTINGENCIA-S151=TRUE |
| T-ORC-013 | RN-S500-159 | S500_INC_PRO_CAN.txt | Rechazos STATUS>0: log + R06 en BATCHP130 (5 CVETRANs e importes) |
| T-ORC-015 | RN-S500-172 | S500_INC_WOR_CAN.txt | Contadores monitoreo: NUM-CALL(6d) · TOT-MOVS-ENV(8d) · NUM-MOVS-ENV(2d) |

---

## Dominio 7 — Enterprise Support Functions

---

### GL — Finance (GL) — Motor de Asientos Contables [S151]
> Dominio: 7 · Enterprise Support Functions · Capacidad: 7.1.1
> Programa: P109 (GL POSTING ENGINE) · Reglas: RN-S151-021..060

#### Inventario de Tareas

| ID | Tarea | Programa | Componente fuente | Tipo |
|----|-------|----------|-------------------|------|
| T-GL-001 | Inicializar sistema: leer W77-SISTEMA-PARAMETRO, resolver CSI (mapeo 12→10), cargar parámetros S080 | P109 | COBOL_P109.txt | control |
| T-GL-002 | Cargar tabla INDS250 en memoria (índice CVETRAN → agrupación contable) | P109 | COBOL_P109.txt | consulta |
| T-GL-003 | Determinar estrategia de acceso tabla S016 (memoria si <4500 registros, disco si ≥4500) | P109 | COBOL_P109.txt | control |
| T-GL-004 | Validar cabecera LOG151 (HDR-HD="HD" y WKS-FECHA-PROCESO = HDR-FCH) | P109 | COBOL_P109.txt | validación |
| T-GL-005 | Leer registro LOG151 y detectar centinela EOF (FUNCION=99 → W77-EOF=1) | P109 | COBOL_P109.txt | consulta |
| T-GL-006 | Filtrar movimiento por FUNCION=1 (contabilizable) y STATUS=1 o 2 (autorizado/en proceso) | P109 | COBOL_P109.txt | validación |
| T-GL-007 | Expandir hasta 5 CVETRANs por movimiento (CVETRAN1..5, IMPORTE1..5, ESQCON1..5) | P109 | COBOL_P109.txt | validación |
| T-GL-008 | Resolver cuenta GL: cadena CVETRAN → INDS250 → CAT7 → ESQCON → (NAT-MOV, CUENTA, CAUSA) | P109 | COBOL_P109.txt | contable |
| T-GL-009 | Aplicar enrutamiento por sistema origen (banco, sector, datos SPEI, tabla cheques S087, etc.) | P109 | COBOL_P109.txt | control |
| T-GL-010 | Generar asiento partida doble: NAT-MOV=1 (débito) o NAT-MOV=2 (crédito) en MOVCONTABLES | P109 | COBOL_P109.txt | contable |
| T-GL-011 | Grabar retroalimentación PUNTEO al sistema origen (solo STATUS=1) | P109 | COBOL_P109.txt | escritura |
| T-GL-012 | Acumular importes por clave compuesta 11-dimensional en SMOVCONTASORT (ADD RMS-IMPORTE) | P109 | COBOL_P109.txt | contable |
| T-GL-013 | Escribir registro acumulado MOVCONTABLES al detectar cambio de clave 11-dimensional | P109 | COBOL_P109.txt | escritura |
| T-GL-014 | Generar cuadre contable (sección 40000): negación de cargos (×−1), exclusión cuenta 1503 | P109 | COBOL_P109.txt | contable |
| T-GL-015 | Actualizar base de datos POSICION si WKS-B03-TIPBD = 1/2/5/6 (sección 50000) | P109 | COBOL_P109.txt | escritura |
| T-GL-016 | Generar output DATALAKE exclusivo para S264/SPEI (trazabilidad de pagos) | P109 | COBOL_P109.txt | escritura |

#### Reglas vinculadas

| Tarea | Regla | Descripción |
|-------|-------|-------------|
| T-GL-001 | RN-S151-029 | Mapeo hardcoded CSI=12 → CSI=10 |
| T-GL-001 | RN-S151-032 | Enrutamiento por sistema (W77-SISTEMA-PARAMETRO, 15+ sistemas) |
| T-GL-003 | RN-S151-030 | Umbral memoria/disco para tabla S016 (<4500 → memoria) |
| T-GL-004 | RN-S151-021 | Validación de cabecera LOG151 (HDR-HD + fecha) |
| T-GL-005 | RN-S151-022 | Centinela de fin de archivo FUNCION=99 |
| T-GL-006 | RN-S151-023 | Filtro de selección: FUNCION=1 y STATUS=1/2 |
| T-GL-007 | RN-S151-024 | Hasta 5 CVETRANs por movimiento (expansión 1:N) |
| T-GL-008 | RN-S151-025 | Cadena de resolución ESQCON (corazón del motor GL) |
| T-GL-009 | RN-S151-033 | Mapeo instrumento→S016-INST para S087 (tabla hardcoded) |
| T-GL-009 | RN-S151-034 | S264 MONEDA=1 → BANCO=0 (SPEI pesos sin dimensión banco) |
| T-GL-009 | RN-S151-035 | Gate de actualización POSICION por tipo BD |
| T-GL-009 | RN-S151-036 | Generación cuadre S502/S702 + condición NOMBDSAL |
| T-GL-010 | RN-S151-026 | Partida doble: NAT-MOV=1 (débito) / NAT-MOV=2 (crédito) |
| T-GL-010 | RN-S151-027 | Cuenta contable por defecto cuando CTA1-CONT=0 (fallback prefijo 5) |
| T-GL-012 | RN-S151-031 | Clave de acumulación MOVCONTASORT (11 dimensiones) |
| T-GL-014 | RN-S151-028 | Exclusión de cuenta 1503 del cuadre (hardcode) |
| T-GL-014 | RN-S151-038 | Negación de cargos en cuadre (CARGOS = TCP-CARGOS × −1) |
| T-GL-016 | RN-S151-037 | Salida DATALAKE exclusiva para S264 (SPEI) |

> **RN-S151-039..060** (22 reglas pendientes de vincular): validación importe MOVCONTASORT, banco/sector por sistema, actualización BD11SDOS151, cierre del proceso.

---

## Dominio 8 — Technology Tools

---

### SCH — Business Scheduling — Cierre de Día y Oracle de Fechas [S500+S151]
> Dominio: 8 · Technology Tools · Capacidad: 8.1.1
> Programa: P075 · P100 · Reglas: RN-S500-009..026

#### Inventario de Tareas

| ID | Tarea | Programa | Componente fuente | Tipo |
|----|-------|----------|-------------------|------|
| T-SCH-001 | Validar versión de P075 contra catálogo central CTLVERS (CHECAME) | P075 | COBOL_P075.txt | validación |
| T-SCH-002 | Resolver título físico de librería L080 vía DAME_TIT IN CTLVERS | P075 | COBOL_P075.txt | control |
| T-SCH-003 | Verificar parámetro de ejecución W77-PARAM-WFL = 1 antes de notificar cierre | P075 | COBOL_P075.txt | validación |
| T-SCH-004 | Invocar INIBATCH de S500L080CTRL para notificar cierre del día bancario a P080 | P075 | COBOL_P075.txt | control |
| T-SCH-005 | Evaluar WKS-L080-RESULT y marcar estatus de fallo si INIBATCH falla | P075 | COBOL_P075.txt | control |
| T-SCH-006 | Detectar entorno de ejecución por hostname (ACYPBETA vs producción) | P100 | COBOL_P100.txt | control |
| T-SCH-007 | Validar versión de P100 contra catálogo central CTLVERS (en producción) | P100 | COBOL_P100.txt | validación |
| T-SCH-008 | Consultar S500B02CONTROL para obtener fecha de línea, fecha de lote y nodo activo | P100 | COBOL_P100.txt | consulta |
| T-SCH-009 | Proyectar fecha de proceso hacia atrás N días hábiles/naturales vía S006LOCSUP función 15 | P100 | COBOL_P100.txt | control |
| T-SCH-010 | Calcular último día del mes anterior a la fecha de línea (opción 6) | P100 | COBOL_P100.txt | control |
| T-SCH-011 | Calcular primer día del mes de la fecha de línea (opción 7) | P100 | COBOL_P100.txt | control |
| T-SCH-012 | Retornar fecha de línea sin proyección (opción 8 / fallback de parámetros inválidos) | P100 | COBOL_P100.txt | consulta |
| T-SCH-013 | Consultar indicador de campaña Teletón activo en S500B02CONTROL (opción 9) | P100 | COBOL_P100.txt | consulta |
| T-SCH-014 | Capturar y validar fecha manual por teclado (opción 5) con bucle de reintentos | P100 | COBOL_P100.txt | validación |
| T-SCH-015 | Retornar nodo activo (B02-USO-FUTURO-05) sin fecha (opción 31) | P100 | COBOL_P100.txt | consulta |

#### Reglas vinculadas

| Tarea | Regla | Componente fuente | Descripción |
|-------|-------|-------------------|-------------|
| T-SCH-001 | RN-S500-022 | COBOL_P075.txt | Validación de versión sin corte de ejecución |
| T-SCH-002 | RN-S500-024 | COBOL_P075.txt | Resolución dinámica de L080 con falla silenciosa |
| T-SCH-003 | RN-S500-023 | COBOL_P075.txt | Notificación de cierre condicional a L080 por parámetro |
| T-SCH-004 | RN-S500-025 | COBOL_P075.txt | Llamada INIBATCH notifica cierre del día bancario a P080 |
| T-SCH-005 | RN-S500-026 | COBOL_P075.txt | Falla INIBATCH marca estatus de error visible |
| T-SCH-006 | RN-S500-009 | COBOL_P100.txt | Detección servidor de desarrollo ACYPBETA |
| T-SCH-007 | RN-S500-010 | COBOL_P100.txt | Cancelación por versión de software no vigente |
| T-SCH-008 | RN-S500-012 | COBOL_P100.txt | Cancelación por registro de control vacío o ilegible |
| T-SCH-009 | RN-S500-021 | COBOL_P100.txt | Proyección por defecto de fecha hacia atrás (S006LOCSUP func=15) |
| T-SCH-009 | RN-S500-018 | COBOL_P100.txt | Cancelación por fallo de acceso a librería LOCSUP |
| T-SCH-010 | RN-S500-017 | COBOL_P100.txt | Cálculo de último día del mes anterior (opción 6) |
| T-SCH-011 | RN-S500-019 | COBOL_P100.txt | Retorno del primer día del mes (opción 7) |
| T-SCH-012 | RN-S500-020 | COBOL_P100.txt | Retorno de fecha de línea sin proyección (opción 8) |
| T-SCH-012 | RN-S500-014 | COBOL_P100.txt | Fallback a fecha de línea por parámetros inválidos |
| T-SCH-013 | RN-S500-016 | COBOL_P100.txt | Consulta indicador campaña Teletón (opción 9) |
| T-SCH-014 | RN-S500-015 | COBOL_P100.txt | Captura y validación manual de fecha (opción 5) |
| T-SCH-015 | RN-S500-013 | COBOL_P100.txt | Retorno de nodo activo sin fecha (opción 31) |
| T-SCH-015 | RN-S500-011 | COBOL_P100.txt | Selección BD04 Tarjetas vs BD01 Captación (opción 3) |

---

## Dominio 9 — Insights & Information

---

### ODS — Operational Data Stores — Modelo DMSII [S500+S151]
> Dominio: 9 · Insights & Information · Capacidad: 9.1.1
> Programa: DASDL S151BD10..BD02 · Reglas: RN-S151-491..525

#### BD10 — Movimientos Diarios

| ID | Tarea | Tipo | Reglas fuente |
|----|-------|------|---------------|
| T-ODS-001 | Selección del conjunto diario activo de BD10: leer `BD99.B01SISDIA.NOMBDSEM` y enrutar a B01/B11/B21/B31/B41MOVTOS según día hábil | control | RN-S151-491, RN-S151-492 |
| T-ODS-002 | Lookup de movimiento individual por AUTS151 NUMBER(08) vía índice `B01SXAUTS151`; si PROCESO ≥ 15, acceso directo requerido | consulta | RN-S151-493, RN-S151-494 |
| T-ODS-003 | Consulta movimientos cajero estándar (SUCINI > 0, PROCESO < 15) vía `B01BXMOVCAJ`, BUFFERS=2500+100/usuario | consulta | RN-S151-494, RN-S151-495 |
| T-ODS-004 | Consulta movimientos sucursales especiales (859/100/342/110/511/870) vía `B01BXCAJ859` con clave KEY=AUTAPL (no AUTS151) | consulta | RN-S151-496 |
| T-ODS-005 | Validación tipo/formato campo NIO: ALPHA(16) SPEI / CECOBAN NUMBER(08) / vacío válido en no-SPEI | validación | RN-S151-497 |
| T-ODS-006 | Cuadre de caja por turno en B03CSISUCCAJ (clave MDE) y B04CSISUCCAJ (clave MDA) | contable | RN-S151-499 |
| T-ODS-007 | Validación campos SAT Anexo 20: RFC-ORD ALPHA(13), RFC-BENEF ALPHA(18), NOM-BENEF ALPHA(120) | validación | RN-S151-500 |
| T-ODS-008 | Consulta importes adicionales vía `S151B02IMPADI` (MEMORY=COARSE, 6M registros); NOT FOUND = caso normal | consulta | RN-S151-498 |

#### BD11 — Saldos y Posición GL

| ID | Tarea | Tipo | Reglas fuente |
|----|-------|------|---------------|
| T-ODS-009 | Actualización posición contable GL en `B72POSCONTA` (MEMORY=COARSE): clave 10 dimensiones; insumo R04C/R27C CNBV | contable | RN-S151-501, RN-S151-503, RN-S151-507 |
| T-ODS-010 | Consulta saldos mensuales activos: acceder siempre al subset `B20BXSDOMENCON` (WHERE STAMOV=1, BIT VECTOR) | consulta | RN-S151-502, RN-S151-504 |
| T-ODS-011 | Control generación estado de cuenta vía `S151B80EDOCTA` (MEMORY=COARSE, 5M): NOT FOUND → P158 omite estado de cuenta (falla silenciosa) | control | RN-S151-505 |
| T-ODS-012 | Validación fecha de proceso: leer `B00.FEC NUMBER(08)` en formato CCAAMMDD (post-CRONOS2K) | validación | RN-S151-506 |

#### BD12 — Movimientos por Contrato Tripartita

| ID | Tarea | Tipo | Reglas fuente |
|----|-------|------|---------------|
| T-ODS-013 | Escritura movimiento tripartita al conjunto correcto: OK → `S151B01MOVCTO` (25M); INFO → `B11MOVINFCTO` (5M); ERROR → `B51MOVERRCTO` (5M) | escritura | RN-S151-508, RN-S151-509, RN-S151-512 |
| T-ODS-014 | Consulta movimiento OK por contrato y período: índice `B01SXMOVCTO` (FECCON+KEYCONT+SEC) o `B01SXFCHVAL` (FECVAL) | consulta | RN-S151-510 |
| T-ODS-015 | Ensamblaje leyenda completa OK: B01MOVCTO + B02IMPADI + B03DATADI (LEY1+REFLOCBNM) + B04CONDATADI (LEY2-5) | consulta | RN-S151-511, RN-S151-512 |
| T-ODS-016 | Trazabilidad secuencias: leer/actualizar SECOK/SECINF/SECERR NUMBER(08) en B00; gaps = movimientos eliminados | control | RN-S151-513 |

#### BD13 — BIFIN / Protección / Domiciliación

| ID | Tarea | Tipo | Reglas fuente |
|----|-------|------|---------------|
| T-ODS-017 | Consulta protección de cobro en `S151B07PROTCOB` (150M) por clave `B07-AUT-PC NUMBER(12)` ≠ AUTS151 NUMBER(08) | consulta | RN-S151-514 |
| T-ODS-018 | Gestión ciclo vida protección: STATUS 0→1→2 (procesable) / 3→4 (reversa) / 5 (eliminado); subset `B07SXAUTPROC` | control | RN-S151-515, RN-S151-518 |
| T-ODS-019 | Control domiciliación `S151B10DOMI` (EXTENDED=TRUE, 150M): fecha juliana `AUTD-FECJUL NUMBER(07)` + cross-ref S702 | control | RN-S151-516 |
| T-ODS-020 | Control envíos CitiDirect `S151B04CTLCITIDIR` (16M): ESTATUS + REINTENTOS NUMBER(03); alerta si REINTENTOS > umbral | control | RN-S151-517 |

#### BD99 — Control del Sistema

| ID | Tarea | Tipo | Reglas fuente |
|----|-------|------|---------------|
| T-ODS-021 | Acumulación movimientos por sucursal `S151B10MOVPORSUC` (8M, MEMORY=COARSE, BLOCKSIZE=4): clave 9 dims incluyendo SECTOR CNBV | contable | RN-S151-519 |
| T-ODS-022 | Acumulación movimientos por cliente `S151B11MOVPORCTE` (10M, MEMORY=COARSE, BLOCKSIZE=7): mayor granularidad que por sucursal | contable | RN-S151-520 |
| T-ODS-023 | Posición semanal `S151B12POSICION` (MEMORY=COARSE): DIAS-SEM OCCURS 5 (CARGO/ABONO por día hábil) | contable | RN-S151-521 |
| T-ODS-024 | Tracking archivos diarios: BIT VECTOR WHERE STAARC=1 en B14ARCDIAORI/B15ARCDIADES; STAARC=1 tras proceso = riesgo reproceso con duplicados | control | RN-S151-522 |

#### BD02 — Saldos Tesorería

| ID | Tarea | Tipo | Reglas fuente |
|----|-------|------|---------------|
| T-ODS-025 | Consulta saldos tesorería por cliente `S151B03SDOCTE` (500K): clave compuesta LPAD(NUMERO1,10)+LPAD(NUMERO2,10) — validar semántica con negocio | consulta | RN-S151-523 |
| T-ODS-026 | Conciliación interbancaria en tiempo real `B14CONOPECRUZ` (100K, MEMORY=ALL): LIQ = BNM_abonos − OTR_cargos; DIFGLO≠0 → reporte Banxico | contable | RN-S151-524 |
| T-ODS-027 | Saldos SAR `S151B08GLOSAR`: desglose por organismo (IMSS/ISSSTE/INFONAVIT/FOVISSSTE/PEMEX) + 7 subcampos de tipo | consulta | RN-S151-525 |

#### Reglas vinculadas (resumen consolidado)

| Tarea | Regla | Componente fuente | Descripción |
|-------|-------|-------------------|-------------|
| T-ODS-001 | RN-S151-491 | DASDL_S151BD10MOVDIA151.txt | 5 conjuntos diarios independientes; selector por NOMBDSEM en BD99 |
| T-ODS-001 | RN-S151-492 | DASDL_S151BD10MOVDIA151.txt | Cardinalidad 52.5M por conjunto; overflow sin reorganización si se supera |
| T-ODS-002 | RN-S151-493 | DASDL_S151BD10MOVDIA151.txt | Lookup O(1) por AUTS151 vía B01SXAUTS151 |
| T-ODS-002 | RN-S151-494 | DASDL_S151BD10MOVDIA151.txt | Filtro PROCESO<15 delimita movimientos activos en subsets |
| T-ODS-003 | RN-S151-495 | DASDL_S151BD10MOVDIA151.txt | B01BXMOVCAJ: SUCINI>0 + PROCESO<15; BUFFERS=2500+100/usuario |
| T-ODS-004 | RN-S151-496 | DASDL_S151BD10MOVDIA151.txt | [CRÍTICO] Sucursales 859/100/342/110/511/870: KEY=AUTAPL en BxxBXCAJ859 |
| T-ODS-005 | RN-S151-497 | DASDL_S151BD10MOVDIA151.txt | NIO ALPHA(16) ≠ numérico; CECOBAN NUMBER(08); NIO vacío válido en no-SPEI |
| T-ODS-006 | RN-S151-499 | DASDL_S151BD10MOVDIA151.txt | Cuadre caja: B03/B04CSISUCCAJ con MONEDA+BANCOS+MDE/MDA+SECREN |
| T-ODS-007 | RN-S151-500 | DASDL_S151BD10MOVDIA151.txt | RFC-ORD(13) ≠ RFC-BENEF(18): asimetría SAT intencional |
| T-ODS-008 | RN-S151-498 | DASDL_S151BD10MOVDIA151.txt | IMPADI MEMORY=COARSE; relación 0..1 con BxMOVTOS; NOT FOUND es caso normal |
| T-ODS-009 | RN-S151-501 | DASDL_S151BD11SDOS151.txt | B72POSCONTA: clave 10 dims GL; insumo R04C/R27C CNBV |
| T-ODS-009 | RN-S151-503 | DASDL_S151BD11SDOS151.txt | B70POSICION + B72POSCONTA MEMORY=COARSE para SLA de cierre contable |
| T-ODS-009 | RN-S151-507 | DASDL_S151BD11SDOS151.txt | B70POSICION en PACKNAME=S067REMESAS: dependencia física cross-sistema |
| T-ODS-010 | RN-S151-502 | DASDL_S151BD11SDOS151.txt | STAMOV=1 BIT VECTOR en B20BXSDOMENCON; consultar base directa produce duplicación aparente |
| T-ODS-010 | RN-S151-504 | DASDL_S151BD11SDOS151.txt | B21SDMENCON1: KEYIND consecutivo + OCCURS 12 para hasta 12 períodos de saldo |
| T-ODS-011 | RN-S151-505 | DASDL_S151BD11SDOS151.txt | B80EDOCTA (5M, COARSE): NOT FOUND → P158 omite estado de cuenta (falla silenciosa) |
| T-ODS-012 | RN-S151-506 | DASDL_S151BD11SDOS151.txt | FEC NUMBER(08) post-CRONOS2K: leer como (06) trunca el siglo silenciosamente |
| T-ODS-013 | RN-S151-508 | DASDL_S151BD12MC001S151.txt | [CRÍTICO] Tripartita OK/INFO/ERROR: físicamente independientes, SLOs distintos |
| T-ODS-013 | RN-S151-509 | DASDL_S151BD12MC001S151.txt | SECTOR NUMBER(02) + BANCA NUMBER(02): obligatorios en R04C/R27C |
| T-ODS-013 | RN-S151-512 | DASDL_S151BD12MC001S151.txt | INFO y ERROR tienen extensiones propias (B12/B13/B14 y B52/B53/B54) |
| T-ODS-014 | RN-S151-510 | DASDL_S151BD12MC001S151.txt | Índices B01SXMOVCTO (FECCON+KEYCONT+SEC) y B01SXFCHVAL (FECVAL) |
| T-ODS-015 | RN-S151-511 | DASDL_S151BD12MC001S151.txt | Leyenda completa OK: B01+B02+B03(LEY1+REFLOCBNM)+B04(LEY2-5) |
| T-ODS-016 | RN-S151-513 | DASDL_S151BD12MC001S151.txt | SECOK/SECINF/SECERR NUMBER(08): techo 99.999.999; gaps = movimientos eliminados |
| T-ODS-017 | RN-S151-514 | DASDL_S151BD13BIFIN.txt | [CRÍTICO] AUT-PC NUMBER(12) ≠ AUTS151 NUMBER(08): FK entre B07PROTCOB y BD10 no es directa |
| T-ODS-018 | RN-S151-515 | DASDL_S151BD13BIFIN.txt | STATUS 6 valores: 0-2 procesables, 3-4 reversa, 5 eliminado sin enviar |
| T-ODS-018 | RN-S151-518 | DASDL_S151BD13BIFIN.txt | B08TDMIGCAP (100M): STATUS ALPHA(02) 'AC'/'CA' — tipo distinto al STATUS NUMBER de B07 |
| T-ODS-019 | RN-S151-516 | DASDL_S151BD13BIFIN.txt | B10DOMI EXTENDED=TRUE (150M): AUTD-FECJUL juliana; AUTD-AUT702 cross-ref S702 |
| T-ODS-020 | RN-S151-517 | DASDL_S151BD13BIFIN.txt | B04CTLCITIDIR (16M): REINTENTOS NUMBER(03); NIO ALPHA(16) en mensajes SPEI |
| T-ODS-021 | RN-S151-519 | DASDL_S151BD99CONTROL.txt | B10MOVPORSUC (8M): BLOCKSIZE=4, REBLOCKFACTOR=5; clave 9 dims incluyendo SECTOR |
| T-ODS-022 | RN-S151-520 | DASDL_S151BD99CONTROL.txt | B11MOVPORCTE (10M): BLOCKSIZE=7, REBLOCKFACTOR=5 |
| T-ODS-023 | RN-S151-521 | DASDL_S151BD99CONTROL.txt | B12POSICION: DIAS-SEM OCCURS 5 (CARGO/ABONO por día hábil) |
| T-ODS-024 | RN-S151-522 | DASDL_S151BD99CONTROL.txt | B14/B15ARCDIAORI/ARCDIADES: BIT VECTOR STAARC=1; falla → reproceso con duplicados |
| T-ODS-025 | RN-S151-523 | DASDL_S151BD02ADSALDO.txt | [SOSPECHOSO] B03SDOCTE NUMERO1(10)+NUMERO2(10): requiere validación negocio |
| T-ODS-026 | RN-S151-524 | DASDL_S151BD02ADSALDO.txt | B14CONOPECRUZ/B15MOVOPECRUZ MEMORY=ALL (100K); DIFGLO≠0 → reporte Banxico |
| T-ODS-027 | RN-S151-525 | DASDL_S151BD02ADSALDO.txt | B08GLOSAR: saldos SAR por IMSS/ISSSTE/INFONAVIT/FOVISSSTE/PEMEX |

> **Pendientes ODS**: T-ODS-025 NUMERO1+NUMERO2 requiere validación de negocio · T-ODS-019 fecha base juliana no documentada en DASDL · T-ODS-009 B70POSICION en PACKNAME=S067REMESAS requiere coordinación cross-equipo · Advertencia operativa: sucursales 859/100/342/110/511/870 usan AUTAPL (no AUTS151) en BD10.

---

## Dominio T — Transversal

---

### SEC — Security — Enmascaramiento de Datos PII [S500]
> Dominio: T · Transversal · Capacidad: T.3.5 Security (cubre parcialmente 10.1.1 Access Control)
> Programa: P655 (SCRAMBLING) · Reglas: RN-S500-027..036

#### Inventario de Tareas

| ID | Tarea | Programa | Componente fuente | Tipo |
|----|-------|----------|-------------------|------|
| T-SEC-001 | Clasificar ambiente por hostname: comparar ATTRIBUTE HOSTNAME contra lista cerrada de 7 nombres (VDMALFA/MONBETA=producción; VDMBETA/ACYPGAMA/ACYPBETA/MONALFA/ACYPOMEGA=prueba) | P655 | COBOL_P655.txt | validación |
| T-SEC-002 | Detectar ejecución en producción: emitir mensaje "NO CORRE EN PRODUCCION; HOST: <hostname>", marcar STATUS=-1 — sin STOP RUN (fail-open) | P655 | COBOL_P655.txt | validación |
| T-SEC-003 | Calcular tamaño de bloque de intercambio variable por hora de arranque: ACYPBETA→200-HH-MM-SS; otros→1800-HH-MM-SS | P655 | COBOL_P655.txt | control |
| T-SEC-004 | Ajustar paridad par del bloque: si W77-CONTA-01 MOD 2 ≠ 0, restar 1 para garantizar intercambios simétricos | P655 | COBOL_P655.txt | control |
| T-SEC-005 | Verificar checkpoint en disco ("S500/FILE/SCRBLING/<CSI>/<fecha>"): si existe → intentar reanudación; si no → crear nuevo y arrancar desde cero | P655 | COBOL_P655.txt | control |
| T-SEC-006 | Validar checkpoint (tipo + CSI + fecha + contador): si coincide y contador > 0 → restaurar tamaño de bloque previo (WKS-I99-HEAD-BLQ sobreescribe W77-CONTA-01) y reanudar desde contrato N; si no coincide → regenerar y arrancar desde cero | P655 | COBOL_P655.txt | control |
| T-SEC-007 | Enmascarar nombres de contratos B03CONTRATOS: intercambiar nombres entre pares de contratos dentro del bloque (shuffling por posición de índice WKS-TB-NOM-PREF) | P655 | COBOL_P655.txt | seguridad |
| T-SEC-008 | Manejar último bloque con cantidad impar: al contrato en posición central asignar nombre ya enmascarado del primer contrato leído en el archivo (W77-NOMBRE-PTE) | P655 | COBOL_P655.txt | seguridad |
| T-SEC-009 | Enmascarar representante legal y domicilio de grupos CPE (B37GRUPOCPE): sustituir B37-REPRES por "REPRESENTANTE LEGAL GRUPO <N>" y B37-DOMICILIO por "DOMICILIO DEL GRUPO <N>" | P655 | COBOL_P655.txt | seguridad |
| T-SEC-010 | Enmascarar nombres de cuentas CPE (B39CTASCPE): si contrato vinculado encontrado en B03 → copiar nombre ya enmascarado; si no → generar "NOMBRE DE PRUEBA <seq>" con contador incremental (inicio=10000, paso=12) | P655 | COBOL_P655.txt | seguridad |

#### Reglas vinculadas

| Tarea | Regla | Descripción |
|-------|-------|-------------|
| T-SEC-001 | RN-S500-027 | Clasificación ambiente por hostname — lista cerrada 7 nombres |
| T-SEC-002 | RN-S500-028 | Bloqueo de producción sin STOP RUN — fail-open activo |
| T-SEC-003 | RN-S500-029 | Tamaño de bloque variable por hora de arranque (200/1800 - HH-MM-SS) |
| T-SEC-004 | RN-S500-030 | Ajuste de paridad par del bloque (MOD 2 → restar 1 si impar) |
| T-SEC-005 | RN-S500-031 | Checkpoint en disco — nombre Unisys "S500/FILE/SCRBLING/<CSI>/<fecha>" |
| T-SEC-006 | RN-S500-032 | Validación checkpoint (tipo+CSI+fecha+contador) y restauración de bloque |
| T-SEC-007 | — | Intercambio de nombres en B03CONTRATOS por bloques (shuffling) — regla pendiente de numeración |
| T-SEC-008 | RN-S500-033 | Último bloque impar: contrato central recibe nombre del primer contrato (W77-NOMBRE-PTE) |
| T-SEC-009 | RN-S500-034 | Enmascaramiento B37GRUPOCPE: REPRES + DOMICILIO sintéticos indexados por número de grupo |
| T-SEC-010 | RN-S500-035 | Enmascaramiento B39CTASCPE: copia nombre de B03 o genera "NOMBRE DE PRUEBA <seq>" |
| T-SEC-001 / T-SEC-002 | RN-S500-036 | Fail-open ante hostname no reconocido — enmascaramiento sin control de ambiente |

> Pendiente: T-SEC-007 no tiene RN-S500 asignada — numeración pendiente en próxima iteración del catálogo.

---

### RPT — Analytics/Reporting — Ciclo de Control + Migración Regulatoria [S151]
> Dominio: T · Transversal · Capacidad: T.3.4
> Programas: P199 (CTASMIGCAP) · P610 (CALLLIBCTL) · P612 (WFL Dispatcher) · P677 (Control Generator)
> Reglas: RN-S151-421..490 (70 reglas)

#### Inventario de Tareas

##### P199 — CTASMIGCAP: Puente Migración S500→S151

| ID | Tarea | Componente fuente | Tipo |
|----|-------|-------------------|------|
| T-RPT-001 | Validar y cargar gate de migración desde catálogo 1565 de S080BD01CON (WKS-IND-MIGRACION) | P199 | control |
| T-RPT-002 | Cargar catálogo CVETRAN (CAT6, tipos 4/5/6) desde S080BD01CON vía L710 paginado | P199 | control |
| T-RPT-003 | Posicionar SEEK en MOVS500 al último AUT-S500 procesado +1 (reanudación por checkpoint CTLP199) | P199 | control |
| T-RPT-004 | Filtrar registros por SUCTRAN=342 / CAJATRAN=36 (hardcodeado) | P199 | validación |
| T-RPT-005 | Alta de movimiento en B08TDMIGCAP (FUNCION=1, condición triple: no-duplicado + CAT6 + filtro) | P199 | escritura |
| T-RPT-006 | Cancelación de movimiento por autorización S151 (FUNCION=2, STATUS="CA") | P199 | escritura |
| T-RPT-007 | Cancelación masiva por tipo de proceso (FUNCION=21, LOCK FIRST/NEXT B08SXFECNUMPRO) | P199 | escritura |
| T-RPT-008 | Cancelación por rango de autorización (FUNCION=22, AUT-S151 > límite en B08SXFECAUT) | P199 | escritura |
| T-RPT-009 | Acumular totales por BIN en tabla de memoria (máx 10 BINs; clasificar NATC=9 vs resto) | P199 | contable |
| T-RPT-010 | Generar reporte R01-TOTALES (CEROS / CON ABONO / SOBREGIRO por BIN) al fin de ejecución | P199 | reporte |
| T-RPT-011 | Commit por lotes de 20,000 registros (END-TRANSACTION AUDIT S151B99REINICTL + actualizar CTLP199) | P199 | control |
| T-RPT-012 | Abrir S151BD13BIFIN UPDATE con retry hasta 6 intentos (WAIT 10s entre intentos) | P199 | control |
| T-RPT-013 | Manejar duplicados B08 como no-fatal: log + continuar; otros errores → DMTERMINATE | P199 | control |

##### P610 — CALLLIBCTL: Dispatcher LibCtl

| ID | Tarea | Componente fuente | Tipo |
|----|-------|-------------------|------|
| T-RPT-014 | F01 — Grabar tamaño de ciclo actual en B03SISMEN | P610 | control |
| T-RPT-015 | F02 — Desactivar base completa (STABDSAL=99) | P610 | control |
| T-RPT-016 | F03 — Enviar señal fin de día a L002 (selección formato 6DIG vs 8DIG por sistema) | P610 | control |
| T-RPT-017 | F04 — Desactivar ciclo (STABDSAL=1) | P610 | control |
| T-RPT-018 | F05 — Grabar STABDSAL con valor explícito (1 / 3 / 5 / 99) | P610 | control |
| T-RPT-019 | F06 — Actualizar ESTATUS en B04SISTEM (rango válido 2-4) | P610 | control |
| T-RPT-020 | F07 — Crear archivo S804-E01-MOV vacío con cabecera HDR + trailer TLR | P610 | escritura |
| T-RPT-021 | F08 — Actualizar fechas FECPRO/FECCON/FECPRO151 en registros CONTROL y CORP | P610 | escritura |
| T-RPT-022 | F09 — Generar archivo TANDEM para ICA (destino Banxico, ruta XFER hardcodeada) | P610 | reporte |

##### P612 — WFL Dispatcher Online

| ID | Tarea | Componente fuente | Tipo |
|----|-------|-------------------|------|
| T-RPT-023 | Escanear archivos EJECUCIONWFL 01-99 por OPCION y STATUS=0 (primera coincidencia) | P612 | control |
| T-RPT-024 | Despachar WFL sin parámetro (START simple) | P612 | control |
| T-RPT-025 | Despachar WFL con parámetro (START con comillas, valor entre comillas dobles) | P612 | control |
| T-RPT-026 | Marcar STATUS=1 en EJECUCIONWFL para prevenir re-ejecución del mismo WFL | P612 | control |

##### P677 — Generador Datasets Control

| ID | Tarea | Componente fuente | Tipo |
|----|-------|-------------------|------|
| T-RPT-027 | Gate inicial CONSISDIA F01 — validar consistencia del día antes de generar | P677 | validación |
| T-RPT-028 | Validar día hábil y calcular número de día en ciclo (THECALENDAR F18 y F06) | P677 | control |
| T-RPT-029 | Poblar FECARCMOV para días hábiles del período (tabla de fechas de archivo) | P677 | escritura |
| T-RPT-030 | Gestionar buffer circular B03SISMEN — reemplazar ciclo más antiguo (MANTSISMEN F37) | P677 | control |
| T-RPT-031 | Generar archivos de control F10-F19 (loop computado) solo cuando ESTATUS=3; cargar LIB-L002 | P677 | escritura |

#### Reglas vinculadas

| Tarea | Regla | Componente fuente | Descripción |
|-------|-------|-------------------|-------------|
| T-RPT-001 | RN-S151-421 | P199 | CTASMIGCAP: identidad como puente cross-system S500→S151 |
| T-RPT-001 | RN-S151-422 | P199 | Gate catálogo 1565 — habilita/bloquea migración del día |
| T-RPT-001 | RN-S151-444 | P199 | Override de fecha por TASKVALUE |
| T-RPT-001 | RN-S151-445 | P199 | CSI routing: VDM vs MTY según NUMCSI-HOST |
| T-RPT-001 | RN-S151-447 | P199 | Inicialización CTLP199 si no existe |
| T-RPT-001 | RN-S151-448 | P199 | Ruta dinámica MOVS500 por sistema y fecha |
| T-RPT-001 | RN-S151-449 | P199 | Ruta dinámica CTLP199 en pack CMEMP |
| T-RPT-001 | RN-S151-450 | P199 | S080L710: catálogos CAT6 y CAT1565 por paginación |
| T-RPT-002 | RN-S151-425 | P199 | Catálogo CVETRAN (CAT6) cargado de S080BD01CON al inicio |
| T-RPT-002 | RN-S151-426 | P199 | Solo tipos 4/5/6 del CAT6 son cargados al catálogo de migración |
| T-RPT-003 | RN-S151-423 | P199 | Reanudación por posición: SEEK al registro AUT-S500+1 |
| T-RPT-003 | RN-S151-446 | P199 | Display file: rotación al superar 6,500 registros |
| T-RPT-004 | RN-S151-424 | P199 | Filtro hardcodeado: SUCTRAN=342, CAJATRAN=36 |
| T-RPT-004 | RN-S151-427 | P199 | Loop de 5 ocurrencias CVETRAN/IMPORTE por registro MOVS500 |
| T-RPT-005 | RN-S151-428 | P199 | Función 1: alta de movimiento en B08 (condición triple) |
| T-RPT-005 | RN-S151-432 | P199 | Estructura del registro B08TDMIGCAP |
| T-RPT-005 | RN-S151-433 | P199 | STATUS "AC"/"CA": ciclo de vida del registro migrado |
| T-RPT-005 | RN-S151-438 | P199 | Índices DMSII: tres sets sobre B08TDMIGCAP |
| T-RPT-006 | RN-S151-429 | P199 | Función 2: cancelación por (FEC-MIG, AUT-S151) |
| T-RPT-007 | RN-S151-430 | P199 | Función 21: cancelación masiva por tipo de proceso |
| T-RPT-008 | RN-S151-431 | P199 | Función 22: cancelación por rango de autorización |
| T-RPT-009 | RN-S151-434 | P199 | Acumulación por BIN: tabla de hasta 10 entradas en memoria |
| T-RPT-009 | RN-S151-435 | P199 | Clasificación importe por NATC: saldo/alta/cero |
| T-RPT-010 | RN-S151-441 | P199 | Reporte R01-TOTALES: tres categorías por BIN |
| T-RPT-011 | RN-S151-436 | P199 | Commit transaccional por lotes de 20,000 registros |
| T-RPT-011 | RN-S151-439 | P199 | Auditoría DMSII vía S151B99REINICTL (NO-AUDIT/AUDIT) |
| T-RPT-012 | RN-S151-437 | P199 | DMSII S151BD13BIFIN: apertura con retry hasta 6 intentos |
| T-RPT-013 | RN-S151-440 | P199 | Duplicados B08: no fatal, log y continúa |
| T-RPT-013 | RN-S151-442 | P199 | Interrupción HI-4: parada controlada |
| T-RPT-013 | RN-S151-443 | P199 | Interrupción HI-6: parada de emergencia sin checkpoint |
| T-RPT-014 | RN-S151-452 | P610 | F01: graba tamaño de ciclo en B03SISMEN |
| T-RPT-015 | RN-S151-453 | P610 | F02: desactiva base con STABDSAL=99 |
| T-RPT-016 | RN-S151-455 | P610 | F03: envía señal fin de día a L002 (Función 98) |
| T-RPT-016 | RN-S151-456 | P610 | F03: selección formato 6DIG vs 8DIG por sistema |
| T-RPT-017 | RN-S151-454 | P610 | F04: desactiva ciclo con STABDSAL=1 |
| T-RPT-018 | RN-S151-457 | P610 | F05: graba STABDSAL (valores 1, 3, 5, 99) |
| T-RPT-019 | RN-S151-458 | P610 | F06: actualiza ESTATUS en B04SISTEM (rango 2-4) |
| T-RPT-020 | RN-S151-459 | P610 | F07: crea archivo S804-E01-MOV vacío (HDR+TLR) |
| T-RPT-021 | RN-S151-460 | P610 | F08: actualiza fechas en CONTROL/CORP |
| T-RPT-022 | RN-S151-461 | P610 | F09: genera archivo TANDEM para ICA (Banxico) |
| T-RPT-022 | RN-S151-462 | P610 | F09: ruta XFER del archivo ICA (destino hardcodeado) |
| T-RPT-014 | RN-S151-451 | P610 | P610 es CALLLIBCTL: dispatcher de 9 funciones |
| T-RPT-013 | RN-S151-463 | P610 | P610: función inválida → terminación anormal |
| T-RPT-013 | RN-S151-464 | P610 | P610: carga de LIBCTL via CTLVERS con fallback |
| T-RPT-013 | RN-S151-465 | P610 | P610: CANCEL de SOPORTECOMS y CTLVER post-uso |
| T-RPT-023 | RN-S151-466 | P612 | P612: dispatcher WFL para LINEA online |
| T-RPT-023 | RN-S151-467 | P612 | P612: escaneo de archivos EJECUCIONWFL 01-99 |
| T-RPT-023 | RN-S151-468 | P612 | P612: match por OPCION y STATUS=0 |
| T-RPT-024 | RN-S151-469 | P612 | P612: WFL sin parámetro — START simple |
| T-RPT-025 | RN-S151-470 | P612 | P612: WFL con parámetro — START con comillas |
| T-RPT-026 | RN-S151-471 | P612 | P612: STATUS=1 previene re-ejecución |
| T-RPT-023 | RN-S151-472 | P612 | P612: primera coincidencia — solo un WFL por llamada |
| T-RPT-025 | RN-S151-473 | P612 | P612: open I-O para escritura de STATUS |
| T-RPT-023 | RN-S151-474 | P612 | P612: sin manejo de error de WFL (sin verificación post-START) |
| T-RPT-023 | RN-S151-475 | P612 | P612: sin librerías externas — dispatcher puro |
| T-RPT-027 | RN-S151-476 | P677 | P677: generador de datasets de control de sistema |
| T-RPT-028 | RN-S151-477 | P677 | P677: validación de día hábil (THECALENDAR F18) |
| T-RPT-028 | RN-S151-478 | P677 | P677: número de día en ciclo (THECALENDAR F06) |
| T-RPT-029 | RN-S151-479 | P677 | P677: población de FECARCMOV para días hábiles |
| T-RPT-029 | RN-S151-480 | P677 | P677: tres fechas igualadas a WKS-PARAM-FECHA |
| T-RPT-027 | RN-S151-481 | P677 | P677: CONSISDIA F01 como gate inicial |
| T-RPT-030 | RN-S151-482 | P677 | P677: B03SISMEN — búsqueda por AAMM actual |
| T-RPT-030 | RN-S151-483 | P677 | P677: reemplazo del ciclo más antiguo (circular buffer) |
| T-RPT-030 | RN-S151-484 | P677 | P677: MANTSISMEN F37 commit condicional |
| T-RPT-027 | RN-S151-485 | P677 | P677: B04SISTEM — lectura con PRODUCTO=0, INSTRUM=0 |
| T-RPT-031 | RN-S151-486 | P677 | P677: ESTATUS=3 dispara generación de archivos |
| T-RPT-031 | RN-S151-487 | P677 | P677: cierre de archivos F10-F19 (loop computado) |
| T-RPT-031 | RN-S151-488 | P677 | P677: LIB-L002 cargada solo con ESTATUS=3 |
| T-RPT-027 | RN-S151-489 | P677 | P677: patrón de error universal → STATUS=-1 |
| T-RPT-027 | RN-S151-490 | P677 | P677: parámetros de entrada sistema y fecha |

> **Nota P199**: `[RIESGO-EQUIVALENCIA]` — P199 es el único puente S500↔S151 y debe rediseñarse (no migrarse) en la modernización. La lógica de transformación debe mapearse a integración event-driven entre los sistemas modernos equivalentes.

---

## Pendientes de vinculación (resumen)

| Capacidad | Reglas sin mapear | Descripción |
|-----------|-------------------|-------------|
| GL | RN-S151-039..060 (22) | Validación importe, banco/sector, BD11SDOS151, cierre |
| TAR | RN-S500-047..055 (9) | Día juliano, campos punteo I08, AMEXMNL, cierre |
| SEC | T-SEC-007 (1 regla sin ID) | Shuffling B03CONTRATOS — pendiente numeración |
| ODS | T-ODS-025 (semántica B03SDOCTE), T-ODS-019 (fecha juliana), T-ODS-009 (cross-equipo S067) | Pendientes de validación con negocio / operaciones |
| PAY | Catálogo 174 recarga (TASKVALUE no identificado), estado DIVESTITURE | Pendientes de confirmación regulatoria / legal |

---

*task-process-rules-index.md · v1.3 · 2026-07-16*
*Fuente: cap-gl · cap-rec · cap-tar · cap-sec · cap-cmp · cap-pay · cap-int · cap-orc · cap-sch · cap-ods · cap-rpt · cap-adj*
*Swarm: 12 agentes en paralelo + coordinador · Total: 233 tareas · 294 reglas vinculadas · 826 reglas en catálogo*
