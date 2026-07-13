# Diccionario de Datos — S500 Sistema Integral de Captación (Banamex Unisys ClearPath MCP)

> **Fuente**: 7 archivos DASDL extraídos del inventario S500 · Release 2025.07_M_MEX_XPR_ALL · SSR 62.0  
> **Propietario**: BANAMEX · **Pack DMSII**: CAPTACION  
> **Estado**: Derivado de ingeniería inversa ETAPA 0 — pendiente validación HITL con SME técnico Banamex  
> **Última actualización**: 2026-06-30

---

## 1. Inventario de Bases de Datos DMSII

S500 opera con 7 bases de datos DMSII independientes, todas físicamente en el pack **CAPTACION**.

| BD física | Nombre lógico | Datasets | Propósito |
|-----------|---------------|----------|-----------|
| S500BD01CAPTACION | CAPTACION | **57** | Base principal OLTP — contratos, movimientos, instrumentos, comisiones |
| S500BD02AUXILIAR | AUXILIAR | **10** | Espejo batch — permite operación LINEA mientras LOTE NOCTURNO modifica CAPTACION |
| S500BD03TELETON | TELETON | **5** | Gestión Tesorería / Teléfono |
| S500BD04TARJETAS | TARJETAS | **19** | Prealtas de tarjetas, TEF, ligas tarjeta-contrato, alertas |
| S500BD05MAPLI | MAPLI (S038) | **4** | Monitoreo de aplicaciones (sistema S038 compartido) |
| S500BD06MSGAAPLI | MSGAAPLI | **2** | Mensajes de aplicaciones / movimientos FM |
| S500BD07ATRIBUCTAS | ATRIBUCTAS | **2** | Atributos de contratos para CAN 2021 (nueva base) |
| **Total** | | **99** | |

> **Nota arquitectónica**: BD02AUXILIAR es el mecanismo de aislamiento que permite al proceso LINEA (online) seguir operando mientras BD01CAPTACION está siendo modificada por el LOTE NOCTURNO (batch). Es el equivalente a un "shadow database" para disponibilidad 24/7.

---

## 2. BD01 — CAPTACION (57 datasets, base principal)

### 2.1 Tabla maestra: S500B03CONTRATOS

**Propósito**: Registro maestro de contratos de cuentas cheque / captación. Es la entidad central de S500.  
**Prefijo de campos**: `B03-`  
**Acceso clave**: `B03SXCTOCLI` KEY(SUC-PROMOTORA, NUM-CONTRATO) — no duplicados

| Campo | Tipo DMSII | Descripción | Valores / Notas |
|-------|------------|-------------|-----------------|
| B03-SUC-PROMOTORA | NUMBER(4) | Sucursal promotora (parte de PK) | REQUIRED |
| B03-NUM-CONTRATO | NUMBER(12) | Número de contrato (PK principal) | REQUIRED |
| B03-NUM-CLIENTE | NUMBER(12) | Número de cliente CIF | |
| B03-NUM-PRODUCTO | NUMBER(4) | Clave de producto bancario | |
| B03-NUM-INSTRUM | NUMBER(4) | Clave de instrumento | |
| B03-MONEDA | NUMBER(3) | Código de moneda | Ej. 001=MXN, 002=USD |
| B03-CTA-CONCENT | NUMBER(2) | Tipo de cuenta | 00=Normal · 05=Nómina personal banco · 08=Recaudadora impuestos · 11=Concentradora · 60-63=TESOFE |
| B03-FEC-APERTURA | NUMBER(8) | Fecha apertura de cuenta | Formato AAAAMMDD |
| B03-DIA-CORTE | NUMBER(2) | Día de corte vigente | |
| B03-DIA-CORTE-ANT | NUMBER(2) | Día de corte anterior | |
| B03-SDO-ANTERIOR | NUMBER(S16,2) | Saldo anterior al último corte | Signed — puede ser negativo |
| B03-SDO-ACTUAL | NUMBER(S16,2) | Saldo actual disponible | Signed — puede ser negativo |
| B03-SDO-PENDIENTE | NUMBER(14,2) | Saldo pendiente de acreditar | |
| B03-FEC-SDOPEN | NUMBER(8) | Fecha del saldo pendiente | AAAAMMDD |
| B03-IMPUESTO-RET | NUMBER(12,2) | Impuesto retenido acumulado | ISR sobre rendimientos |
| B03-SDO-SBC | NUMBER(14,2) | Saldo Stand By Credit total | |
| B03-SBC-LOCAL | NUMBER(14,2) | SBC local (misma plaza) | |
| B03-SBC-FORANEO | NUMBER(14,2) | SBC foráneo (otra plaza) | |
| B03-SDO-X-RECUP | NUMBER(14,2) | Saldo por recuperar | |
| B03-AUT-PENDIENTE | NUMBER(14,2) | Importe de autorizaciones pendientes | |
| B03-SDO-PROTEGIDO | NUMBER(14,2) | Saldo protegido (línea de crédito) | |
| B03-TIPO-PERSONA | NUMBER(2) | Tipo de persona | |
| B03-BANCA | NUMBER(3) | Segmento de banca | |
| B03-SECTOR | NUMBER(2) | Sector económico | |
| B03-FEC-ULTMOV | NUMBER(8) | Fecha último movimiento | AAAAMMDD |
| B03-FEC-ULTACT | NUMBER(8) | Fecha última actualización | AAAAMMDD |
| B03-STATUS | NUMBER(1) | Estado del contrato | 0=Activo · 1=Bloqueado · 2=Cancelado sin corte final · 3=Cancelado con corte final · 4=Cancelado automático · 5=Precancelado (cta básica 66-14) |
| B03-TIPO-BLOQUEO | NUMBER(2) | Subtipo de bloqueo | |
| B03-RESTRICCIONES | NUMBER(2) | Restricciones operativas | |
| B03-REST-CTACONCE | NUMBER(2) | Restricciones cuenta concentradora | |
| B03-NIV-SEGLOGICA | NUMBER(2) | Nivel seguridad lógica cheques | 0=No valida · 1=Cheque pagado · 2=+Inexistente · 3=+No liberado |
| B03-INTS-CAPIT | NUMBER(S12,2) | Intereses capitalizados | Signed |
| B03-SDO-FINCORTE | NUMBER(S16,2) | Saldo al fin de ciclo | Signed |
| B03-FEC-CORTE | NUMBER(8) × 3 | Fechas de corte (3 ciclos) | OCCURS 3 TIMES |
| B03-NOMBRE | ALPHA(36) | Nombre del titular | |
| B03-NUM-TEF | NUMBER(16) | Número de cuenta TEF | 0=Sin TEF · 9(s)=Descalificado |
| B03-FECHA-DEPNOMI | NUMBER(8) | Fecha último depósito nómina × TEF | AAAAMMDD |
| B03-ESQ-TARIFARIO | NUMBER(1) | Esquema de comisiones | 0=Tradicional · 1=Por renta · 2=Por transacción |
| B03-MDA-ASIGNADOS | NUMBER(1) | Medios de acceso asignados | 0=Ninguno · 1=Chequera · 2=Tarjeta · 3=Ambos |
| B03-GEN-EDOCTA | NUMBER(1) | Genera estado de cuenta | 0=Sin info · 1=Mensual · 2=No genera · 3=Bimestral |
| B03-IMP-CGOSDIA | NUMBER(14,2) | Cargos del día acumulados | |
| B03-IMP-ABOSDIA | NUMBER(14,2) | Abonos del día acumulados | |
| B03-CTOS-DETRASP | NUMBER(12) × 3 | Contratos de destino traspaso | OCCURS 3 TIMES |
| B03-IND-PAGOPEND | NUMBER(2) | Indicador pagos pendientes | 01=En B24 · 02=En B25 · 03=Ambos |
| B03-SBC-1DIA | NUMBER(14,2) | SBC de 1 día | |
| B03-IND-SBC-B26 | NUMBER(2) | Indicador SBC en B26 | 00=No · 01=Sí |

---

### 2.2 Tabla de transacciones: S500B04MOVIMIENTO

**Propósito**: Registro histórico de movimientos aplicados al contrato. Es el dataset más accedido de S500.  
**Prefijo**: `B04-` · **Población**: 1,500,000 registros  
**Clave primaria compuesta**: CONTRATO + FEC-MOVTO + AUTORIZACION

| Campo | Tipo DMSII | Descripción | Notas |
|-------|------------|-------------|-------|
| B04-NUM-CONTRATO | NUMBER(12) | Contrato FK → B03 | REQUIRED |
| B04-FEC-MOVTO | NUMBER(8) | Fecha del movimiento AAAAMMDD | REQUIRED |
| B04-AUTORIZACION | NUMBER(14) | Número de autorización | REQUIRED |
| B04-AUT-S151 | NUMBER(8) | Autorización en S151 (Contabilidad) | Correlación S500↔S151 |
| B04-FEC-VALOR | NUMBER(8) | Fecha valor (puede diferir de FEC-MOVTO) | AAAAMMDD |
| B04-NUM-PRODUCTO | NUMBER(4) | Producto | |
| B04-NUM-INSTRUM | NUMBER(4) | Instrumento | |
| B04-MONEDA | NUMBER(3) | Moneda | |
| B04-SUC-TRANSMITE | NUMBER(4) | Sucursal que transmite el movimiento | |
| B04-CAJ-TRANSMITE | NUMBER(2) | Cajero / terminal que transmite | |
| B04-HORA-MOVTO | NUMBER(6) | Hora HHMMSS | |
| B04-SUC-PROMOTORA | NUMBER(4) | Sucursal promotora (dueña del contrato) | |
| B04-CLAVE-MOVTO | NUMBER(4) | Clave tipo de movimiento (código de transacción) | Catálogo en B17/B18 |
| B04-IMPORTE | NUMBER(12,2) | Importe del movimiento | |
| B04-STATUS-MOVTO | NUMBER(2) | Estado del movimiento | |
| B04-SDO-ANTERIOR | NUMBER(14,2) | Saldo antes del movimiento | |
| B04-SDO-ACTUAL | NUMBER(14,2) | Saldo después del movimiento | |
| B04-INTS-CANCEL | NUMBER(12,2) | Intereses cancelados por este movimiento | |
| B04-ORIGEN-MOVTO | NUMBER(1) | Origen del movimiento | |

**Índices DMSII**:

| Set | Clave | Duplicados | Uso |
|-----|-------|-----------|-----|
| B04SXCTOFEC | (CONTRATO, FEC-MOVTO) | Sí | Consulta histórico por contrato+fecha |
| B04SXCTOFVAL | (CONTRATO, FEC-VALOR) | Sí | Consulta por fecha valor |
| B04SXFECCTOAUT | (FEC-MOVTO, CONTRATO, AUTORIZACION) | No | Lookup único por fecha+autorización |

---

### 2.3 Movimientos del día: S500B07MOVDIA

**Propósito**: Detalle enriquecido del movimiento online durante el día (más campos que B04). Se purga al cierre de LOTE.  
**Prefijo**: `B07-` · Contiene campos específicos de canal (tipo de medio de acceso, referencia alfanumérica)

| Campo | Tipo DMSII | Descripción |
|-------|------------|-------------|
| B07-NUM-CONTRATO | NUMBER(12) | FK → B03 · REQUIRED |
| B07-AUTORIZACION | NUMBER(14) | Número autorización · REQUIRED (contiene SUC+CAJ+AUT) |
| B07-AUT-S151 | NUMBER(8) | Autorización S151 |
| B07-FEC-VALOR | NUMBER(8) | Fecha valor |
| B07-CLAVE-MOVTO | NUMBER(4) | Tipo de movimiento |
| B07-CLAVE-ORIGEN | NUMBER(4) | Origen del movimiento |
| B07-IMPORTE | NUMBER(14,2) | Importe principal |
| B07-2DO-IMPORTE | NUMBER(14,2) | Segundo importe (ej. neto vs bruto) |
| B07-IND-IVA | NUMBER(1) | IVA aplicado · 0=No · 1=10% · 2=15% |
| B07-TIPO-CGIROS | NUMBER(2) | Tipo de cargo/abono · 1=Dep BNM · 2=Dep otros bancos · 3=Mixto · 4=Bonif · 5=Dev BNM · 6=Dev otros |
| B07-MOV-SOBREGIRO | NUMBER(2) | Requirió línea de crédito · 0=No · 1=Sí |
| B07-STATUS-MOVTO | NUMBER(2) | Estado del movimiento |
| B07-REFER-ALFA | ALPHA(40) | Referencia alfanumérica (ej. concepto, nombre pagador) |
| B07-REFER-NUME | NUMBER(12) | Referencia numérica |
| B07-TIPO-MEDACCES | NUMBER(2) | Tipo de medio · 0=Solo contrato · 1=Chequera · 2=Tarjeta · 3=PIN |
| B07-ORIGEN-MOVTO | NUMBER(1) | Origen · 1=Local · 3=Foráneo recibido |
| B07-OTROS-MOVSAD | GROUP × 5 | Movimientos adicionales del mismo evento |
| B07-COMIS-PEND | GROUP × 4 | Comisiones pendientes por aplicar |

---

### 2.4 Instrumentos / Productos: S500B05INSTRUMEN

**Propósito**: Catálogo de productos-instrumentos-moneda con sus reglas de comisión y parámetros operativos.  
**Prefijo**: `B05-` · Clave: (PRODUCTO, INSTRUMENTO, MONEDA)

| Campo | Tipo DMSII | Descripción |
|-------|------------|-------------|
| B05-NUM-PRODUCTO | NUMBER(4) | PK — clave producto · REQUIRED |
| B05-NUM-INSTRUM | NUMBER(4) | PK — clave instrumento · REQUIRED |
| B05-MONEDA | NUMBER(3) | PK — moneda · REQUIRED |
| B05-IND-PAGOREND | NUMBER(1) | Paga rendimientos · 0=No · 1=Sí |
| B05-NOMBRE-PROD | ALPHA(40) | Nombre del producto |
| B05-FEC-ALTA | NUMBER(8) | Fecha alta del producto |
| B05-FEC-ULTMODIF | NUMBER(8) | Fecha última modificación |
| B05-CVE-RETIMP | NUMBER(4) | Clave retención de impuesto |
| B05-IND-DIACORTE | NUMBER(2) | Día de corte · 0=Cualquier día · 1=Fin de mes |
| B05-MA-CHEQUERA | NUMBER(1) | Permite chequera · 0=No · 1=Sí |
| B05-MA-TARJETA | NUMBER(1) | Permite tarjeta · 0=No · 1=Sí |
| B05-DIAS-FECHAVAL | NUMBER(2) | Días para fecha valor |
| B05-CLAVE-TARIF | NUMBER(3) × 60 | Claves de tarifa por tipo de comisión (60 ocurrencias) |
| B05-CLAVE-COMIS | NUMBER(4) × 60 | Claves de comisión correspondientes (60 ocurrencias) |

**Tabla de comisiones (OC 1-60 parcial)**:
OC1=Apertura · OC2=Cheque girado · OC3=Banca electrónica · OC5=Manejo de cuenta · OC8=Retiro cajero permanente · OC9=Disp ventanilla con tarjeta · OC10=Consulta saldo · OC17=Dev ventanilla · OC18=Dev sin fondos · OC19=Retiro cajero red · OC26=Cajero exterior · OC32=Anualidad tarjeta titular · OC33=Anualidad tarjeta adicional · OC34=Administración mensual

---

### 2.5 Histórico de corte: S500B06HISTORICO

**Propósito**: Estado del contrato al cierre del último ciclo (corte de estado de cuenta).  
**Prefijo**: `B06-`

| Campo clave | Tipo | Descripción |
|-------------|------|-------------|
| B06-NUM-CONTRATO | NUMBER(12) | FK → B03 · REQUIRED |
| B06-FEC-BLOQUEO | NUMBER(8) | Fecha bloqueo si aplica |
| B06-FEC-CANCEL | NUMBER(8) | Fecha cancelación si aplica |
| B06-FEC-CICLOANT | NUMBER(8) | Fecha inicio ciclo anterior |
| B06-DIAS-CICLO | NUMBER(2) | Días del ciclo |
| B06-ACUM-PROMANU | NUMBER(16,2) | Acumulado promedio anual |
| B06-ACUM-INTSANU | NUMBER(14,2) | Acumulado intereses anuales |
| B06-SDO-ANT-ANT | NUMBER(16,2) | Saldo antepenúltimo corte |
| B06-CONT-COMIS | NUMBER(6) × 50 | Contador comisiones del ciclo (50 tipos) |
| B06-DEPS-DIA | NUMBER(16,2) × 31 | Depósitos por día del ciclo |
| B06-RETS-DIA | NUMBER(16,2) × 31 | Retiros por día del ciclo |
| B06-IMPUESTO-RET | NUMBER(10,2) | Impuesto retenido en el ciclo |
| B06-TASA-BRUTA | NUMBER(7,3) | Tasa de interés bruta |
| B06-SDOFONDOS | NUMBER(14,2) | Saldo de fondos |
| B06-SDOBCAINV | NUMBER(14,2) | Saldo banca-inversiones |
| B06-SDOINVPLA | NUMBER(14,2) | Saldo inversión a plazo |

---

### 2.6 Cifras / Totales interbancarios: S500B09CIFRAS

**Propósito**: Totales agregados por combinación banco-origen / banco-destino / producto / instrumento / moneda. Base de conciliación con SPEI y sistemas interbancarios.  
**Clave**: (LLAVE-BANCOS, PRODUCTO, INSTRUM, MONEDA)

| Campo | Descripción |
|-------|-------------|
| B09-LLAVE-BANCOS | NUMBER(6) = 3 dígitos banco origen + 3 dígitos banco destino (002=Banamex, 012=BBVA) |
| B09-S028L/B-CARGOS/ABONOS | Cargos/abonos por sistema S028 (compensación cheques) local y batch |
| B09-POSIL/B-CARGOS/ABONOS | Cargos/abonos posición local y batch |
| B09-S408L/B-CARGOS/ABONOS | Cargos/abonos SPEI local y batch |
| B09-SDO-ACTUAL | NUMBER(S17,2) | Saldo actual total (Signed) |
| B09-NUM-APERTURAS | Contador de aperturas del día |
| B09-NUM-CANCELAC | Contador de cancelaciones |

---

### 2.7 Datasets de control operativo

| Dataset | Prefijo | Descripción clave |
|---------|---------|-------------------|
| S500B00CTRLPASO | B00 | Control de pasos procesados del LOTE (flags de etapas) |
| S500B01CONTROL | B01 | Fechas sistema: LINEA, LOTE, autorización, S151, S408. **DIRECT** (acceso aleatorio) |
| S500B02CONTROL | B02 | Control operativo extendido: tipo de cambio diario, archivos aplicados (30 slots), status SPEI/SBC/CASC, ventanas horarias |
| S500B08DEVOLUCION | B08 | Devoluciones de cheques interbancarios |
| S500B11FVALOR | B11 | Tablas de fechas valor por instrumento |
| S500B12COMPEN | B12 | Compensación de cheques (clearing) |
| S500B21INTERBANC | B21 | Control de mensajería interbancaria SPEI/BANXICO. **DIRECT** |

---

### 2.8 Datasets de comisiones (B28–B34)

7 datasets homólogos con estructura idéntica — acumuladores de comisiones cobradas por tipo/período:

| Dataset | Tipo de comisión |
|---------|-----------------|
| S500B28COMICOB | Comisión cobrada tipo 1 |
| S500B29COMICOB | Comisión cobrada tipo 2 |
| S500B30COMICOB | Comisión cobrada tipo 3 |
| S500B31COMICOB | Comisión cobrada tipo 4 |
| S500B32COMICOB | Comisión cobrada tipo 5 |
| S500B33COMICOB | Comisión cobrada tipo 6 |
| S500B34COMICOB | Comisión cobrada tipo 7 |

> **Riesgo regulatorio CONDUSEF**: Estos 7 datasets son los inputs primarios de los reportes de comisiones CONDUSEF. DOM-08 (P178) los escribe exclusivamente — cualquier divergencia post-modernización genera incumplimiento.

---

### 2.9 Datasets CPE / TEF / Grupos (DOM-06 / DOM-07)

| Dataset | Prefijo | Descripción |
|---------|---------|-------------|
| S500B35NUMTEF | B35 | Tabla de números TEF (transferencia electrónica de fondos) |
| S500B36GRUPOCOM | B36 | Grupos de comisiones |
| S500B37GRUPOCPE | B37 | Grupos de Cuenta Pago Empresa (CPE) |
| S500B38SUBGPOS | B38 | Subgrupos de CPE |
| S500B39CTASCPE | B39 | Cuentas CPE activas |
| S500B40BINGPOPREP | B40 | BIN-Grupo preparación (productos prémium) |
| S500B41BIN | B41 | Tabla BIN (Bank Identification Numbers) de tarjetas |
| S500B42GPO | B42 | Grupos de cuentas |
| S500B43NUMGPOSOC | B43 | Número de grupo socio |
| S500B44CTOSEVOL | B44 | Contratos en evolución (cambio de producto) |
| S500B45GPOSOCREND | B45 | Grupo socio rendimiento |

---

### 2.10 Datasets de réplica y control (DOM-09)

| Dataset | Prefijo | Descripción |
|---------|---------|-------------|
| S500B50LIGASTESO | B50 | Ligas de tesorería entre contratos |
| S500B51RCTAORI | B51 | Réplica cuenta origen (para tesorería) |
| S500B52CTRLDEPRET | B52 | Control de depósitos y retiros |
| S500B53ENVREPLICA | B53 | **DIRECT** — Envío de réplica a sistemas externos |
| S500B54RECREPLICA | B54 | **DIRECT** — Recepción de réplica |
| S500B55LIMDEPRET | B55 | Límites de depósitos y retiros |

---

### 2.11 Datasets de pagos pendientes

| Dataset | Prefijo | Descripción |
|---------|---------|-------------|
| S500B24PAGOSPEND | B24 | Pagos pendientes estándar |
| S500B25PGOSPENDPE | B25 | Pagos pendientes PE (periódicos externos) |

---

### 2.12 Datasets SBC (Stand By Credit)

| Dataset | Prefijo | Descripción |
|---------|---------|-------------|
| S500B26SDOSBC | B26 | Saldos Stand By Credit |
| S500B27MOVSBC | B27 | Movimientos SBC |

---

### 2.13 Nuevas estructuras 2025

| Dataset | Descripción |
|---------|-------------|
| S500B47MOVDIA | Movimientos diarios complementarios |
| S500B48CTOSGCE | Contratos GCE |
| S500B49COMPENDEPP | Compensación DEPP |
| S500B56MAKERCHEK | Control Maker-Checker (autorización de 4 ojos) |
| S500B57PANTASUC | Pantalla sucursal (configuración por sucursal) |

---

## 3. BD02 — AUXILIAR (10 datasets)

**Propósito**: Copia espejo de los datasets críticos de BD01 para permitir operación LINEA durante el procesamiento LOTE NOCTURNO. P020 (Batch) escribe en AUXILIAR; LINEA lee de CAPTACION mientras AUXILIAR se consolida.

| Dataset | Espejo de | Descripción |
|---------|-----------|-------------|
| S500B01ACONTROL | B01CONTROL | Control fechas (DIRECT) |
| S500B02ACONTROL | B02CONTROL | Control operativo auxiliar |
| S500B03AUXCTOS | B03CONTRATOS | Contratos auxiliar (lectura durante batch) |
| S500B04AUXMOVTOS | B04MOVIMIENTO | Movimientos auxiliar |
| S500B13AMOVCVES | B13MOVCVES | Movimientos por clave auxiliar |
| S500B21AUXINTBCO | B21INTERBANC | Interbancario auxiliar (DIRECT) |
| S500B26AUXSDOSBC | B26SDOSBC | Saldos SBC auxiliar |
| S500B46AUXDIAL | B46DIALOGO | Diálogo auxiliar (DIRECT) |
| S500B47AUXMOVDIA | B47MOVDIA | Movimientos diarios auxiliar |
| S500B52AUXCTLDEPR | B52CTRLDEPRET | Control depósitos/retiros auxiliar |

---

## 4. BD04 — TARJETAS (19 datasets)

**Propósito**: Gestión de prealtas de tarjetas (producto 66-11), control de ligas tarjeta↔contrato, TEF, y mensajería de archivos externos (S111, S016, S999).  
**Nota**: Físicamente en el pack CAPTACION, pero base separada. El prefijo de los campos es `B0xP-` (P = Tarjetas).

| Dataset | Prefijo | Descripción |
|---------|---------|-------------|
| S500B01PCONTROL | B01P | Control general de archivos de tarjetas |
| S500B03PREALTAS | B03P | **Pre-altas de tarjetas** — TARJETA(16) + CONTRATO(12) · 15M registros |
| S500B04PTEF | B04P | Tarjetas TEF por número — TARJETA(16) · 5M registros |
| S500B05PHISCTAGLB | B05P | Histórico traspasos a cuentas globales (Art. 61 CONDUSEF) |
| S500B06PCTRLARCH | B06P | Control de archivos recibidos |
| S500B07PARCHIVOS | B07P | Archivos pendientes de aplicar |
| S500B08PCTRARRIBO | B08P | Control de arribo de archivos |
| S500B09PMOTOR | B09P | Motor de decisión (último movimiento por cliente S084/S087/S500) |
| S500B10PDEPURA | B10P | Depuración de prealtas |
| S500B11PCVETRAARC | B11P | Clave trámite-archivo |
| S500B12PCLONNING | B12P | Control de clonación de tarjetas |
| S500B13PREGCOMEPP | B13P | Pre-registro comisiones EPP |
| S500B14PREGREWEPP | B14P | Pre-registro recompensas EPP |
| S500B15PCTLBUCKET | B15P | Control de bucket (límites) |
| S500B16PLIGCTOTAJ | B16P | Liga contrato↔tarjeta↔contrato |
| S500B17PCTLALERTA | B17P | Control de alertas de tarjeta |
| S500B18PENVIOSDOS | B18P | Envío de saldos a SdoS |
| S500B19PSDOTAR111 | B19P | Saldo de tarjeta S111 |

**Campos clave de S500B03PREALTAS** (alta densidad regulatoria):

| Campo | Tipo | Descripción |
|-------|------|-------------|
| B03P-TARJETA | NUMBER(16) | Número de tarjeta · REQUIRED · PK |
| B03P-CONTRATO | NUMBER(12) | Contrato asociado · REQUIRED · PK |
| B03P-SUC-PROM | NUMBER(4) | Sucursal promotora |
| B03P-NUM-CSI | NUMBER(2) | CSI (instancia de sistema) |
| B03P-FEC-PREALTA | NUMBER(8) | Fecha pre-alta AAAAMMDD |

---

## 5. BD03 — TELETON (5 datasets)

**Propósito**: Operaciones de tesorería vía Telón — productos de inversión y captación especiales.

| Dataset | Prefijo | Descripción |
|---------|---------|-------------|
| S500B00TGLOBAL | B00T | Registro global de parámetros Teléfono/Tesorería |
| S500B01TCONTROL | B01T | Control de fechas y estado |
| S500B02TMOVTOS | B02T | Movimientos Tesorería |
| S500B04TBINES | B04T | Tabla de BINes para Tesorería |
| S500B05TDIALOGO | B05T | Diálogo Tesorería **DIRECT** |

---

## 6. BD05 — MAPLI / S038 (4 datasets)

**Propósito**: Monitoreo de aplicaciones en tiempo real — registra programas activos, usuarios, actividades y tiempos de proceso. Sistema compartido S038, accedido por L035.

| Dataset | Prefijo | Descripción |
|---------|---------|-------------|
| S038B01CONTROL | B01 | Control de sesiones y estados |
| S038B02PROGRAMAS | B02 | Registro de programas activos (usuario × programa × copia) |
| S038B03ACTIVIDAD | B03 | Actividades en proceso (inicio/fin, elapsed time) |
| S038B91REINICIO | B91 | RESTART — punto de reinicio tras falla |

---

## 7. BD06 — MSGAAPLI (2 datasets)

**Propósito**: Mensajes de aplicaciones — bitácora de mensajes y movimientos FM (Front-end Messaging).

| Dataset | Prefijo | Descripción |
|---------|---------|-------------|
| S500B00MCONTROL | B00M | Control de mensajes de aplicación |
| S500B01MMOVSFM | B01 | Movimientos Front-end Messaging **DIRECT** |

---

## 8. BD07 — ATRIBUCTAS (2 datasets)

**Propósito**: Base nueva (CAN 2021) para calificar atributos de contratos que aún no existen en S500 — específicamente la identificación de Cuenta Ordenante para regulación SPEI/BANXICO.

| Dataset | Prefijo | Descripción |
|---------|---------|-------------|
| S500B01CONTRATOS | B01 | Registro de contratos con atributos extendidos |
| S500B02CONTROL | B02 | Control de versiones y estado |

**Campos clave de S500B01CONTRATOS (ATRIBUCTAS)**:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| B01-CSI-CONTRATO | NUMBER(2) | CSI del contrato |
| B01-NUM-CONTRATO | NUMBER(12) | FK → B03CONTRATOS · PK · REQUIRED |
| B01-FEC-PROALT | NUMBER(8) | Fecha proceso alta |
| B01-FEC-MAQALT | NUMBER(8) | Fecha máquina alta |
| B01-GRP-NUMERICO | GROUP × 5 | 5 atributos numéricos con fechas |
| B01-GRP-ALFA | GROUP × 5 | 5 atributos alfanuméricos con fechas |
| B01-IND-PANTALLA | NUMBER(4) | Pantalla de referencia |
| B01-FILLER-ALFA | ALPHA(100) | Extensión futura · Población: 30M registros |

---

## 9. Relaciones entre datasets clave

```
S500B05INSTRUMEN (PRODUCTO, INSTRUM, MONEDA)
        │ define parámetros de
        ▼
S500B03CONTRATOS (NUM-CONTRATO PK)
        │ 1:N
        ├──▶ S500B04MOVIMIENTO  (movimientos históricos)
        ├──▶ S500B06HISTORICO   (histórico por corte)
        ├──▶ S500B07MOVDIA      (movimientos del día)
        ├──▶ S500B08DEVOLUCION  (devoluciones cheques)
        ├──▶ S500B24PAGOSPEND   (pagos pendientes)
        ├──▶ S500B25PGOSPENDPE  (pagos periódicos)
        ├──▶ S500B26SDOSBC      (saldos SBC)
        ├──▶ S500B44CTOSEVOL    (cambio de producto)
        └──▶ BD07.B01CONTRATOS  (atributos CAN 2021)

S500B03PREALTAS (TARJETAS) — TARJETA(16)
        │ liga a
        └──▶ S500B03CONTRATOS vía B03P-CONTRATO

S500B01CONTROL — fechas sistema (LINEA date, LOTE date, S151 date)
        │ controla ventana de proceso de
        └──▶ todos los datasets de BD01

BD01 ←→ BD02 (AUXILIAR): espejo para alta disponibilidad durante batch
```

---

## 10. Tipos de datos DMSII — Referencia rápida

| Tipo DMSII | Equivalente SQL | Notas |
|------------|----------------|-------|
| `NUMBER(n)` | DECIMAL(n,0) | Entero decimal compactado |
| `NUMBER(n,d)` | DECIMAL(n+d, d) | Decimal con d decimales |
| `NUMBER(Sn,d)` | DECIMAL signed | Signed — admite negativos |
| `ALPHA(n)` | CHAR(n) | Alfanumérico EBCDIC blancos |
| `BOOLEAN` | BIT / BOOLEAN | TRUE/FALSE |
| `REAL` | FLOAT | Punto flotante |
| `GROUP ... OCCURS n TIMES` | ARRAY[1..n] | Array de registros |
| `DIRECT DATA SET` | Heap Table + hash | Acceso aleatorio directo |
| `SET ... KEY(...)` | INDEX | Índice secundario tipo B-tree o hash |

---

## 11. Gaps pendientes de validación HITL

Los siguientes ítems requieren confirmación con el SME técnico de Banamex antes de usar este diccionario en diseño de target:

1. **Catálogo de CLAVE-MOVTO (B04/B07)**: los códigos de transacción (ej. depósito, retiro, comisión, SPEI) están en B17CVESXFUN / B18CVESXINST — no se han leído completamente.
2. **Significado exacto de B03-BANCA y B03-SECTOR**: segmentos de clientes (retail / empresas / gobierno).
3. **Validez de B05INSTRUMEN como catálogo único**: confirmar si hay instrumentos no-S500 que impactan reglas.
4. **B02-ULT-ARCH-APLI (slots 1-30)**: confirmar qué sistemas envían cada slot — crítico para secuencia de integración.
5. **Relación entre B04-AUTORIZACION y el número externo SPEI/BANXICO**: ¿hay campo adicional en B07 o B21?
6. **Archivos de entrada no-DMSII**: S087 (cheques), S016 (bloqueos), S111 (tarjetas), S999, S084, S408 — sus estructuras no están en estos DASDL.
7. **Población real de BD04TARJETAS B03PREALTAS**: POPULATION=15M — ¿es el volumen actual o el límite técnico?

---

*Fuente primaria: `S500_DASDL_CAPTACION.txt`, `S500_DASDL_TARJETAS.txt`, `S500_DASDL_AUXILIAR.txt`, `S500_DASDL_ATRIBUCTA.txt`, `S500_DASDL_TELETON.txt`, `S500_DASDL_MAPLI.txt`, `S500_DASDL_MSGAAPLI.txt`*  
*Generado: 2026-06-30 · ETAPA 0 — pendiente validación HITL*