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
| REC | Financial Reconciliation — Punteo | 6.7.1 | Common Services | S151 | 16 | 20 | [cap-rec.md](capacidades/cap-rec.md) |
| GL | Finance (GL) — Motor de Asientos | 7.1.1 | Enterprise Support | S151 | 16 | 18 (+22 pend.) | [cap-gl.md](capacidades/cap-gl.md) |
| SEC | Security — Enmascaramiento PII | T.3.5 | Transversal | S500 | 10 | 11 (+1 pend.) | [cap-sec.md](capacidades/cap-sec.md) |
| **Total** | | | | | **66** | **68** | |

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

## Pendientes de vinculación (resumen)

| Capacidad | Reglas sin mapear | Descripción |
|-----------|-------------------|-------------|
| GL | RN-S151-039..060 (22) | Validación importe, banco/sector, BD11SDOS151, cierre |
| TAR | RN-S500-047..055 (9) | Día juliano, campos punteo I08, AMEXMNL, cierre |
| SEC | T-SEC-007 (1 regla sin ID) | Shuffling B03CONTRATOS — pendiente numeración |

---

*task-process-rules-index.md · v1.0 · 2026-07-16*
*Fuente: capacidades/cap-gl.md · cap-rec.md · cap-tar.md · cap-sec.md · cap-cmp.md*
*Swarm: 4 agentes en paralelo + coordinador · Total: 66 tareas · 68 reglas vinculadas*
