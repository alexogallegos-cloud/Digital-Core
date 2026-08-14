# Mapa de Integración AS-IS — Banamex GemCog · S500 + S151
> Gemelo Cognitivo del Sistema · Transversal · Fronteras Externas
> Versión: 1.0 · 2026-07-20 · Derivado de análisis estático de 1,550 reglas
> Fuente: rules-catalog/*.md · capacidades/cap-*.md · bian-mapping-s500.md · bian-mapping-s151.md
> **Tipo-artefacto:** `Mapa`  
> **Capa-GemCog:** `Transversal`  
> **Propósito:** Inventario de los 19 sistemas externos AS-IS con mecanismos, direccionalidad y riesgos de separación Citi/Banamex — input para el diseño del Anti-Corruption Layer.  
> **Relacionado-con:** kb-capa5-fronteras · bian-mapping-s500 · bian-mapping-s151

---

## Resumen ejecutivo

| Categoría | # Sistemas | Dirección dominante |
|-----------|------------|---------------------|
| Redes de pago | 2 | BIDIRECCIONAL |
| Autoridades regulatorias | 6 | OUTBOUND |
| Sistemas corporativos Citi | 4 | BIDIRECCIONAL |
| Analytics / Observabilidad | 3 | OUTBOUND |
| Mensajería | 1 | BIDIRECCIONAL |
| Pagos internacionales + antifraude | 2 | BIDIRECCIONAL |
| **Total sistemas externos** | **19** | |

Adicionalmente: **13 sistemas Banamex internos** con dependencias cross-sistema (S016, S264, S087, S084, S702, S067, S440, S408, S501, S502, S017/S018, S701, S711).

**Mecanismos de entrega principales:** INTELARSND/ADMONXFERS (fichero Unisys MCP) · IBM MQ vía L091/L093 · I11-REPLICA cross-CSI · XFER (Unisys) · DMSII PAQUETECONTABLE file · THECALENDAR library (calendario Banxico)

---

## 1. Redes de Pago

### 1.1 SPEI / Banxico (Sistema de Pagos Electrónicos Interbancarios)

| Campo | Detalle |
|-------|---------|
| **Sistema** | SPEI — red de pagos interbancarios en tiempo real · Banco de México |
| **Regulación** | Circular 14/2017 Banxico · CLABE ISO 13616 |
| **Dirección** | BIDIRECCIONAL |
| **Naturaleza** | Red de pagos en tiempo real; Banxico también provee calendario operativo (THECALENDAR) |

**Programas de conexión:**

| Programa | Sistema | Función de integración |
|----------|---------|----------------------|
| L091_ASINCRONA ⚠️ NO-XP | S500 | Inbound: recibe instrucciones SPEI de la switch via IBM MQ |
| L093_ASINCRONA ⚠️ NO-XP | S500 | Outbound: envía confirmaciones SPEI; coordina con Fraud Manager via TIPO-PROC |
| P020 / LINCOMS | S500 | CVETRAN 4449 = SPEI interbancario; override sucursal 859 + cajero 40 hardcodeados |
| P165 | S500 | Batch SPEI/CLABE (11,286 LOC) · T.1.3 Payment Schemes |
| P677 | S151 | Valida calendario operativo Banxico via THECALENDAR F18 |
| P109 | S151 | W77-SISTEMA-PARAMETRO=264 → path SPEI; genera archivo DATALAKE exclusivo para S264 |

**Reglas clave:** RN-S500-108..122 (cálculos pago/SPEI en P020), RN-S151-034 (BANCO=0 para MXN), RN-S151-037 (DATALAKE exclusivo S264), RN-S151-263 (NIO X(16) en paneles online), RN-S151-477 (P677 calendario Banxico)

**Riesgos de separación:**
- NIO (16 chars) es el identificador único Banxico — debe preservarse en el target
- I11-REPLICA WAIT 1200s hardcodeado (replicación VDM↔MTY SPEI) — riesgo de timeout en target cloud

---

### 1.2 CECOBAN / ICA / TANDEM (Cámara de Compensación)

| Campo | Detalle |
|-------|---------|
| **Sistema** | Centro de Compensación Bancaria — cheques y compensación interbancaria |
| **Regulación** | Banxico supervisado |
| **Dirección** | OUTBOUND |
| **Naturaleza** | Generación y transmisión de archivo TANDEM/ICA para compensación interbancaria |

**Programas de conexión:**

| Programa | Sistema | Función de integración |
|----------|---------|----------------------|
| P610 F09 | S151 | Genera archivo TANDEM/ICA; APL-ORI=0236, APL-DES=0264, COD-SER=20 hardcodeados |
| L020 | S500 | Buffer S127 Cheques ↔ S500 para movimientos de cheques |

**Reglas clave:** RN-S151-460 (procesamiento ICA/TANDEM), RN-S151-461 (estructura archivo ICA), RN-S151-462 (XFER a INFOICA/CECOBAN)

**Riesgos:** APL-ORI=0236 es el código de institución Banamex — crítico post-separación; mecanismo XFER Unisys requiere equivalente en el target.

---

## 2. Autoridades Regulatorias

### 2.1 CNBV — Serie B (Reporte Prudencial)

| Campo | Detalle |
|-------|---------|
| **Sistema** | Comisión Nacional Bancaria y de Valores — reportes B-0111A (balances) + B-0111B (movimientos) |
| **Dirección** | OUTBOUND (S151 → PAQUETECONTABLE → S254 → CNBV) |
| **Cadena de entrega** | P130 (agrupador) → P131 (traductor) → PAQUETECONTABLE (90 bytes/registro) → S254/PeopleSoft → CNBV |

**Programas de conexión:**

| Programa | Sistema | Función de integración |
|----------|---------|----------------------|
| P130 / 17MTP001 | S151 | Agrupa movimientos LOG151 por sistema/libro/moneda/clave; genera MOVSCIG → SCIG |
| P131 / 15MTP007 | S151 | Traduce a PAQUETECONTABLE; SETID="BNMEX" **14 veces** hardcodeado |
| P109 | S151 | Genera S115 con mapeo CUB (Catálogo Único de Bolsas) para CNBV Serie B |
| P108 | S151 | Normalización sector CNBV; **BUG**: sector 15 → sector 11 siempre (RN-S151-124) |
| P610 F03 | S151 | Señal regulatoria FUNCION=98 a L002 REGISTRA como cierre de día CNBV |

**Reglas clave:** RN-S151-061..080 (P130 completo), RN-S151-091..112 (P131: SETID=BNMEX, FOBAPROA, PAQUETECONTABLE), RN-S151-103 (estructura PAQUETECONTABLE), RN-S151-110 (entrega a S254), RN-S151-139 (S115 CUB mapping), RN-S151-124+376 (bug sector CNBV)

**Riesgos críticos:**
- `SETID="BNMEX"` en P131: 14 ocurrencias — **punto de separación Citi/Banamex #1**
- Bug CNBV sector 15→11 en P108 — defecto en producción desde creación
- Loop DREG-FOBA en P131 — obligación regulatoria FOBAPROA desde 1994-1999 embebida en código

---

### 2.2 CNBV — FraudLink / S711 (Reporte Diario de Fraude)

| Campo | Detalle |
|-------|---------|
| **Sistema** | S711 (sistema Fraude Banamex) + reporte CNBV de movimientos fraudulentos |
| **Dirección** | OUTBOUND |
| **Naturaleza** | Reporte diario batch de movimientos con claves de fraude 2001/2444/2496 |

**Programas:** P103 (S500) → archivo `S500/FILE/S711/FRAUDLINK/{CSI}/{FECHA}` → S711 via INTELARSND

**Reglas clave:** RN-S500-153..182 (P103 completo), BANCO=0002 hardcodeado (código Banamex en sistema regulatorio CNBV)

---

### 2.3 SAT / Anexo 20 (Comprobantes Fiscales)

| Campo | Detalle |
|-------|---------|
| **Sistema** | Servicio de Administración Tributaria — CFDI XML Anexo 20 (retenciones SPEI) |
| **Dirección** | OUTBOUND (campos RFC persistidos en DMSII para reporte downstream) |
| **Naturaleza** | Cumplimiento fiscal — retención IVA/ISR en tiempo de transacción; campos RFC en BD10 |

**Programas:**

| Programa | Sistema | Campo / Función |
|----------|---------|-----------------|
| P020, P010, P142, P144 | S500 | IVA 16% / 11% (fronterizo) / ISR 0.50% hardcodeados como constantes |
| BD10 (DMSII S151) | S151 | RFC-ORD ALPHA(13) · RFC-BENEF ALPHA(18) · NOM-BENEF ALPHA(120) persistidos para Anexo 20 |

**Reglas clave:** RN-S500-108..122 (cálculos IVA/ISR), RN-S151-500 (BD10 campos RFC/SAT)

**Riesgo:** Tasas IVA/ISR hardcodeadas en código — si SAT modifica tasas, requiere recompilación urgente.

---

### 2.4 CONSAR / SAR / Afore (Sistema de Ahorro para el Retiro)

| Campo | Detalle |
|-------|---------|
| **Sistema** | CONSAR — regulador Afore; reportes enviados vía Banxico como custodio |
| **Dirección** | OUTBOUND |
| **Naturaleza** | Reportes de saldos SAR por fondo (IMSS, ISSSTE, INFONAVIT, FOVISSSTE, PEMEX) |

**Programas:**

| Programa | Sistema | Función |
|----------|---------|---------|
| P120 EXTRACTOR SAR | S151 | Genera 4 reportes regulatorios SAR → Banxico; incluye saldos IMSS/ISSSTE/INFONAVIT |
| P052 | S151 | Genera archivo SAR; también envía a S440 (Factoraje) |
| BD02.B08GLOSAR | S151 | Base DMSII saldos SAR por fondo |

**Reglas clave:** RN-S151-221..232 (P120 SAR completo), **RN-S151-228 (BUG CRÍTICO: INFONAVIT ANT=0 siempre desde 1991 — variable incorrecta en acumulador)**

**Riesgo:** Bug INFONAVIT desde 1991 produce reportes CONSAR incorrectos para antigüedad de ahorro INFONAVIT.

---

### 2.5 CONDUSEF (Protección al Consumidor Financiero)

| Campo | Detalle |
|-------|---------|
| **Sistema** | CONDUSEF — estados de cuenta y reportes de protección al consumidor |
| **Dirección** | OUTBOUND |

**Programas:** P010/LINEA (S151) → P17 panel (requiere FACULTAD=2 para totales nacionales), P158 (estados de cuenta con divulgaciones CONDUSEF)

**Reglas clave:** RN-S151-247 (gate FACULTAD=2 para reports nacionales CONDUSEF)

---

### 2.6 Banxico — Reconciliación Interbancaria

| Campo | Detalle |
|-------|---------|
| **Sistema** | Banxico — reporte de diferencias de posición interbancaria |
| **Dirección** | OUTBOUND (condicional — solo cuando DIFGLO≠0) |

**Programas:** BD02.B14CONOPECRUZ (S151) — tabla DMSII de reconciliación; DIFGLO≠0 dispara reporte a Banxico

**Reglas clave:** RN-S151-524 (diferencia reconciliación → trigger reporte Banxico)

---

## 3. Sistemas Corporativos Citi / Banamex

### 3.1 SCIG (Sistema Contable Integral Gráfico)

| Campo | Detalle |
|-------|---------|
| **Sistema** | Plataforma de contabilidad corporativa Citibank |
| **Dirección** | OUTBOUND |
| **Mecanismo** | INTELARSND (ADMONXFERS Unisys MCP) → SCIG |

**Programas:** P130/AGRUPADOR (S151) → genera MOVSCIG + MOVSCIG1; P109 → headers CIG específicos para S264/SPEI (WKS-HD264-CIG, WKS-TR264-CIG)

**Reglas clave:** RN-S151-073 (generación MOVSCIG + entrega SCIG)

**Riesgo:** Sistema Citi — post-separación este canal debe ser desactivado o redirigido al sistema contable Banamex independiente.

---

### 3.2 S254 / PeopleSoft (ERP GL Corporativo)

| Campo | Detalle |
|-------|---------|
| **Sistema** | PeopleSoft ERP (código S254) — GL corporativo downstream de S151 |
| **Dirección** | OUTBOUND (S151 → PAQUETECONTABLE → S254 → CNBV) |

**Programas:** P131/TRADUCTOR (S151) → PAQUETECONTABLE (90 bytes, 2 registros por movimiento GL)

**Reglas clave:** RN-S151-103 (estructura PAQUETECONTABLE), RN-S151-110 (entrega a S254)

**Riesgo:** SETID="BNMEX" identifica entidad Banamex en PeopleSoft — **punto de separación Citi/Banamex #2**. S254 es el repositorio intermedio entre S151 y regulador CNBV.

---

### 3.3 CitiDirect (Cash Management Corporativo)

| Campo | Detalle |
|-------|---------|
| **Sistema** | Portal corporativo Citi de gestión de tesorería/cash para clientes institucionales |
| **Dirección** | OUTBOUND |

**Programas:** BD13.B04CTLCITIDIR (S151 DMSII ~16M registros) — tabla de control de transacciones CitiDirect; campos ESTATUS + REINTENTOS + NIO SPEI

**Reglas clave:** RN-S151-517 (estado y reintentos CitiDirect), RN-S151-806 (referencia CITIDIRECT vocab)

**Riesgo:** Sistema Citi — tabla B04CTLCITIDIR deberá migrarse o desacoplarse post-separación; NIO SPEI liga transacciones CitiDirect con Banxico.

---

### 3.4 Citi ALR/AHR/OCM (Interface GL Pre-Separación)

| Campo | Detalle |
|-------|---------|
| **Sistema** | Citi GL legacy: ALR (Account Ledger Records) · AHR (Account History) · OCM (One Cash Mgmt) |
| **Dirección** | BIDIRECCIONAL |
| **Naturaleza** | Interface GL Citi↔Banamex activa durante periodo de coexistencia pre-divestiture |

**Programas:**

| Programa | Sistema | Función |
|----------|---------|---------|
| P150 | S151 | Interface ALR/AHR/OCM; **BRANCH=484 hardcodeado** (ID Banamex en jerarquía Citi) |
| P151 | S151 | Transformador IBM-Citibank ALR/AHR/OCM; sufijo BNE en campos SWIFT (ALRINT-SWIFT-CCY-CODE-BNE) |

**Riesgos críticos:**
- `BRANCH=484` en P150: identificador de sucursal Banamex en estructura Citi — **punto de separación Citi/Banamex #3**
- Interface activa mientras Citi y Banamex compartan infraestructura GL → debe desactivarse post-divestiture

---

## 4. Analytics y Observabilidad

### 4.1 Splunk (Observabilidad Operacional)

| Campo | Detalle |
|-------|---------|
| **Sistema** | Splunk — gestión de logs y dashboarding operacional |
| **Dirección** | OUTBOUND |
| **Acoplamiento** | WFL_SPLUNK acopla directamente la app con Splunk como destino — patrón a eliminar |

**Programas:** P810/STSTOTALES (S151 ALGOL) → agrega totales por sucursal/caja/banco/moneda de MOVDIA; WFL_SPLUNK (S151) → orquesta transmisión

**Reglas clave:** RN-S151-1163 (WFL_SPLUNK), RN-S151-1160 (P810 STSTOTALES)

**Riesgo target:** Reemplazar WFL_SPLUNK por pipeline OpenTelemetry nativo; P810 debe reimplementarse como servicio de reporting desacoplado del destino de observabilidad.

---

### 4.2 Teradata (Data Warehouse de Analytics)

| Campo | Detalle |
|-------|---------|
| **Sistema** | Teradata — data warehouse de analytics de crédito y cartera |
| **Dirección** | OUTBOUND |

**Programas:** P142/S408LINCRED (S500) → extrae cartera de contratos B01CONTRATOS para carga batch en Teradata

**Reglas clave:** RN-S500-134 (P142 S408LINCRED interface), RN-S500-136 (extracción Teradata de B01CONTRATOS)

---

### 4.3 DATALAKE (Trazabilidad SPEI — plataforma moderna)

| Campo | Detalle |
|-------|---------|
| **Sistema** | Data lake moderno — solo para trazabilidad SPEI/S264 actualmente |
| **Dirección** | OUTBOUND (condicional — exclusivo S264) |

**Programas:** P109 (S151) → genera archivo DATALAKE **solo cuando W77-SISTEMA-PARAMETRO=264** (SPEI); no escribe para ningún otro sistema

**Reglas clave:** RN-S151-037 (DATALAKE exclusivo S264)

**Nota:** La exclusividad S264 sugiere integración moderna incipiente para trazabilidad de pagos; en el target, todos los sistemas deberían alimentar el data lake.

---

## 5. Mensajería

### 5.1 IBM MQ / WebSphere (Mensajería Asíncrona)

| Campo | Detalle |
|-------|---------|
| **Sistema** | IBM Message Queue / WebSphere — interfaz vía conectores propietarios Unisys |
| **Dirección** | BIDIRECCIONAL |
| **HA** | Arquitectura 5 copias COMS; replicación I11-REPLICA VDM↔MTY (WAIT 1200s hardcodeado) |

**Programas:** L091_ASINCRONA (S500) → inbound SPEI; L093_ASINCRONA (S500) → outbound + coordinación Fraud Manager via TIPO-PROC

**Reglas clave:** RN-S500-894/895 (núcleo asíncrono), RN-S500-114 (coordinación Fraud Manager), buffer circular MEM[0:2015] con vencimiento/dead-letter propietario

**Riesgo target:** Sustituir buffer en memoria propietario por broker con TTL/DLQ nativo (Kafka, SQS, etc.); eliminar WAIT 1200s hardcodeado.

---

## 6. Pagos Internacionales y Antifraude

### 6.1 SWIFT / S703 (Pagos Internacionales)

| Campo | Detalle |
|-------|---------|
| **Sistema** | SWIFT (BIC ISO 9362; monedas ISO 4217); S703 = código sistema Banamex para movimientos SWIFT |
| **Dirección** | BIDIRECCIONAL |
| **Naturaleza** | Pagos internacionales; BIC codes en registros S422 (cliente y control) |

**Programas:**

| Programa | Sistema | Campos SWIFT |
|----------|---------|--------------|
| P109 | S151 | W77-SISTEMA-PARAMETRO=703 → path SWIFT; RMS-BANCO=A00-R01-BCOS para S703 |
| P150, P151 | S151 | ACCI-SWIFT-CCY-CODE, ALRINT-SWIFT-CCY-CODE-BNE (ISO 4217 en interfaces Citi) |
| P010, P050, P052, P053, P158, P167, P169 | S151 | S422: CTE-SWIFT (11c) · CTR-CODSWIFT (12c) — BIC codes clientes y contrapartes |
| P115, P330 | S500 | I10-MONEDASWIFT (ISO currency) · S422-19-CTE-SWIFT, S422-79-CTE-SWIFT |

**Reglas clave:** RN-S151-1327 (routing banco S703 vs S264 vs S017/S018)

---

### 6.2 Fraud Manager / FICO (Antifraude en Tiempo Real)

| Campo | Detalle |
|-------|---------|
| **Sistema** | FICO Fraud Manager — motor de scoring en tiempo real |
| **Dirección** | OUTBOUND (S500 → Fraud Manager via L093 en path online) |
| **Naturaleza** | TIPO-PROC identifica origen del movimiento: 33-37 (copias COMS P020) · 28-32 (P010) |

**Programas:** L093_ASINCRONA (S500) → routing TIPO-PROC a Fraud Manager para scoring; P103 (S500) → batch FRAUDLINK diario

**Reglas clave:** RN-S500-114 (coordinación Fraud Manager online), RN-S500-119 (TIPO-PROC routing)

---

## 7. Dependencias Cross-Sistema Internas Banamex

| Sistema | Código | Programas conector | Dirección | Naturaleza |
|---------|--------|--------------------|-----------|------------|
| S016 Customer | S016 | P109 (memoria/disco ≤4,500 registros), P050/P052/P010 via L422 | INBOUND | Contratos, comisiones, routing MDA/CSI |
| S264 SPEI | S264 | P109 (W77=264), P020, L091/L093 | INBOUND | Feed SPEI al GL; único sistema que genera DATALAKE |
| S087 Cheques | S087 | P109 (W77=87), L020 | INBOUND | Compensación cheques; PRODUCTO=087 forzado |
| S084 Tarjetas | S084 | P109 (W77=84), P312 (SALDOS084) | BIDIRECCIONAL | GL tarjetas inbound; SALDOS084 outbound; nodo=04 hardcodeado |
| S702 Domiciliación | S702 | P109 (W77=702), BD13.B10DOMI | BIDIRECCIONAL | Cobros domiciliados; CUADRE forzado; RECHAZOS suprimidos |
| S067 Remesas | S067 | BD11.B70POSICION | DEPENDENCIA FÍSICA | Tabla posición S151 reside en pack S067REMESAS |
| S440 Factoraje | S440 | P052 (S151) | OUTBOUND | S151 envía datos de factoraje a S440 |
| S408 Crédito | S408 | P142 (S408LINCRED, 30+ funciones) | BIDIRECCIONAL | Interface crédito; lee B01CONTRATOS; escribe a S408 |
| S501/S502 Nómina | S501/S502 | P109 (W77=501/502) | INBOUND | Posting GL nómina; S502 suprime RECHAZOS + fuerza CUADRE |
| S017/S018 Otros | S017/S018 | P109 (W77=17/18) | INBOUND | Posting GL banca; código banco de A00-R01-BCO-S018 |
| S701 Hacienda | S701 | P109 (W77=701) | INBOUND | Movimientos GL gobierno/tesorería |
| S711 FraudLink | S711 | P103 via INTELARSND | OUTBOUND | Receptor reporte fraude diario CNBV |
| S127 Cheques (bridge) | — | P199/CTASMIGCAP; filtro SUCTRAN=342/CAJATRAN=36 | INBOUND | Bridge migración S500→S151; BD13.B08TDMIGCAP |

---

## 8. Mecanismos de Entrega

| Mecanismo | Programas que lo usan | Destinos |
|-----------|----------------------|----------|
| **INTELARSND / ADMONXFERS** (distribución ficheros Unisys MCP) | P130 (MOVSCIG→SCIG), P103 (FRAUDLINK→S711), P130/P131 (LOG151-ETL/LOG151-GEN→LATAM S404) | SCIG, S711, sistemas LATAM |
| **IBM MQ** via L091/L093 | P020, L091_ASINCRONA, L093_ASINCRONA | Switch SPEI, Fraud Manager |
| **I11-REPLICA** (replicación cross-CSI) | P020 / COPIA-5 | VDM↔MTY HA SPEI |
| **XFER** (transferencia Unisys) | P610 F09 | INFOICA (CECOBAN) |
| **PAQUETECONTABLE file** (DMSII) | P131 | S254/PeopleSoft |
| **THECALENDAR** (librería Unisys) | P677 | Calendario operativo Banxico |
| **DATALAKE file** | P109 (solo S264) | Data lake moderno |

---

## 9. Riesgos Críticos de Separación Citi/Banamex

| Riesgo | Programa | Regla | Detalle |
|--------|----------|-------|---------|
| **SETID="BNMEX" x14** | P131 TRADUCTOR | RN-S151-091..112 | Identificador Banamex en PeopleSoft — punto separación #1 |
| **BRANCH=484** | P150 | 6.7.1 mapping | ID sucursal Banamex en jerarquía Citi — punto separación #2 |
| **APL-ORI=0236** | P610 F09 | RN-S151-461 | Código institución Banamex en CECOBAN — punto separación #3 |
| **BANCO=0002** | P103 | RN-S500-153..182 | Código Banamex en sistema regulatorio CNBV Fraude |
| **IVA/ISR hardcodeados** | P020, P010, P142, P144 | RN-S500-108..122 | 16%, 11%, 0.50% — riesgo ante cambio legislativo |
| **INFONAVIT ANT=0** | P120 SAR | RN-S151-228 | Bug desde 1991 en reporte CONSAR INFONAVIT |
| **CNBV Sector 15→11** | P108 | RN-S151-124/376 | Defecto en clasificación sectorial CNBV |
| **FOBAPROA loop** | P131 DREG-FOBA | RN-S151-091..112 | Obligación regulatoria 1994-1999 embebida en código |
| **WFL_SPLUNK acoplado** | P810/WFL_SPLUNK | RN-S151-1163 | App acoplada directamente a Splunk — eliminar patrón |
| **DATALAKE solo S264** | P109 | RN-S151-037 | Solo SPEI va al data lake — inconsistencia con target data strategy |

---

*Referencias: [wfl-catalog.md](wfl-catalog.md) · [bian-mapping-s500.md](bian-mapping-s500.md) · [bian-mapping-s151.md](bian-mapping-s151.md) · [capacidades/cap-cfr.md](capacidades/cap-cfr.md) · [capacidades/cap-pay.md](capacidades/cap-pay.md) · [capacidades/cap-mq.md](capacidades/cap-mq.md) · [kb-capa5-fronteras.md](kb-capa5-fronteras.md) · [traceability-matrix.md](traceability-matrix.md)*
