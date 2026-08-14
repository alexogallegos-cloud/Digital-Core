# S500 — Grupos Funcionales y Segmentación de Dominio
> Análisis multi-señal · Etapa 4 HITL · Reverse Engineering Specialist
> Sistema: SPE-MM-001 (S500 Sistema de Cargos y Abonos — Unisys ClearPath MCP)
> Fecha: 2026-06-30 · Estado: `[DRAFT — PENDIENTE VALIDACIÓN CON SME BANAMEX]`
> Indexado: ✅ 2026-07-17 — Capa 5 — grupos funcionales/dominio

```
┌─ ADVERTENCIA HITL ──────────────────────────────────────────────────────────┐
│ Este documento es el output del Reverse Engineering Specialist (Etapa 4).   │
│ Las hipótesis de dominio DEBEN ser validadas con el SME técnico de Banamex  │
│ antes de usarse para decisiones de diseño o modernización.                  │
│ Items marcados [AMBIGUO] requieren aclaración del banco.                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Metodología

Análisis aplicado sobre **114 archivos fuente · 898,596 LOC** usando 4 señales en fusión:

| Señal | Evidencia extraída |
|-------|--------------------|
| **S1: Acceso DMSII** | $SET record types por programa (formato `NNNNNN$SET` Unisys) |
| **S2: Nomenclatura DASDL** | 57 datasets CAPTACION + 18 TARJETAS + AUXILIAR + MAPLI + TELETON + MSGAAPLI |
| **S3: WFL co-scheduling** | LOTE WFL = job diario LINEA; LINEA WFL = REORG utility (nombres en fichero son inversos al job real) |
| **S4: Nombres de programa** | P010 APLICACION, P014 CONSULTOR, P015 DISPERSADOR, P038 MONITOR, P050 ACTIVA MEDIOS, P080 CUENTA ORDENANTE (documentado en el propio WFL) |

**Corrección crítica:** `BDB04` = `S500B04MOVIMIENTO` en CAPTACION (no BD04-TARJETAS).
Las tarjetas usan prefijo `BDB01M` = `S500B01PCONTROL` en BD04TARJETAS.
Solo P010 y el INC `PRO_CAN` acceden a BD04-TARJETAS directamente; `L039_ACCESOBD04` es la librería ALGOL que los encapsula.

---

## Diccionario de Datasets CAPTACION (BDB → Semántica)

| BDB prefix | Dataset DASDL | Significado funcional |
|------------|---------------|-----------------------|
| BDB00 | S500B00CTRLPASO | Control de paso / administración del sistema |
| BDB01 | S500B01CONTROL | Cuenta: identificador / header (dato maestro) |
| BDB02 | S500B02CONTROL v2 | Cuenta: estado / saldos acumulados / flags de comportamiento |
| BDB03 | S500B03CONTRATOS | Condiciones contractuales (tasa, límites, producto) |
| BDB04 | S500B04MOVIMIENTO | **Registro de transacción individual (cargo o abono)** |
| BDB05 | S500B05INSTRUMEN | Instrumentos financieros |
| BDB06 | S500B06HISTORICO | Movimientos históricos (períodos cerrados) |
| BDB07 | S500B07MOVDIA | Movimientos del día en curso |
| BDB08 | S500B08DEVOLUCION | Devoluciones y reversas |
| BDB09 | S500B09CIFRAS | Cifras estadísticas / sumarios para reportes |
| BDB11 | S500B11FVALOR | Registros de fecha valor |
| BDB12 | S500B12COMPEN | Compensación / clearing |
| BDB13 | S500B13MOVCVES | Movimientos agrupados por clave |
| BDB14 | S500B14TOTCVES | Totales acumulados por clave |
| BDB15 | S500B15ARCHIVO | Registros archivados (cuentas inactivas / cerradas) |
| BDB16 | S500B16TABLAS | Tablas de referencia del sistema |
| BDB17 | S500B17CVESXFUN | Claves por función operativa |
| BDB18 | S500B18CVESXINST | Claves por institución |
| BDB19 | S500B19CANCELA | Registros de cancelación |
| BDB20 | S500B20DEVMENSUAL | Devoluciones mensuales |
| BDB21 | S500B21INTERBANC | Transacciones interbancarias |
| BDB22 | S500B22ESQCONT | Esquema contable de la cuenta |
| BDB23 | S500B23MODULOS | Configuración de módulos del sistema |
| BDB24 | S500B24PAGOSPEND | Pagos pendientes |
| BDB25 | S500B25PGOSPENDPE | Pagos pendientes extendidos (variante) |
| BDB26 | S500B26SDOSBC | Saldos banco central / banco comercial |
| BDB27 | S500B27MOVSBC | Movimientos banco central |
| BDB28–34 | S500B28–34COMICOB | Comisiones de cobro (7 tipos distintos) |
| BDB35 | S500B35NUMTEF | Número de TEF (transferencia electrónica de fondos) |
| BDB36 | S500B36GRUPOCOM | Grupo de comercialización |
| BDB37 | S500B37GRUPOCPE | Grupo CPE `[AMBIGUO: validar significado de CPE con Banamex]` |
| BDB38 | S500B38SUBGPOS | Sub-grupos |
| BDB39 | S500B39CTASCPE | Cuentas CPE |
| BDB40 | S500B40BINGPOPREP | BIN + grupo prepago (Tarjeta Prepagada) |
| BDB41 | S500B41BIN | Bank Identification Number |
| BDB42 | S500B42GPO | Grupo genérico |
| BDB43 | S500B43NUMGPOSOC | Número de grupo sociedad |
| BDB44 | S500B44CTOSEVOL | Costos evolutivos de cuenta |
| BDB45 | S500B45GPOSOCREND | Grupo sociedad / rendimiento |
| BDB46 | S500B46DIALOGO | Registros de diálogo / pantalla interactiva |
| BDB47 | S500B47MOVDIA v2 | Movimientos del día (variante adicional) |
| BDB48 | S500B48CTOSGCE | Costos GCE `[AMBIGUO: validar con Banamex]` |
| BDB49 | S500B49COMPENDEPP | Compensación depósitos pendientes |
| BDB50 | S500B50LIGASTESO | Ligas de tesorería |
| BDB51 | S500B51RCTAORI | Referencia de cuenta de origen |
| BDB52 | S500B52CTRLDEPRET | Control de depósito/retiro |
| BDB53 | S500B53ENVREPLICA | Envío de réplica (replicación) |
| BDB54 | S500B54RECREPLICA | Recepción de réplica |
| BDB55 | S500B55LIMDEPRET | Límite de depósito/retiro |
| BDB56 | S500B56MAKERCHEK | Maker-checker (control dual de aprobación) |
| BDB57 | S500B57PANTASUC | Pantalla de sucursal |
| BDB91 | S500B91REINICIO | Registro de restart batch (punto de recuperación) |
| BDB01M | BD04: S500B01PCONTROL | Tarjetas: control principal (prefix B01M) |

---

## Grupos Funcionales Propuestos

### Resumen Ejecutivo

S500 no es solo un "sistema de cuentas de cheque" — es la **plataforma completa de captación** de Banamex con 10 dominios funcionales distintos, algunos de los cuales tienen implicaciones regulatorias independientes (SPEI, comisiones CONDUSEF, estados de cuenta CNBV). La modernización no puede tratarse como un bloque único.

| Grupo | Dominio | LOC estimado | Programas | Riesgo |
|-------|---------|--------------|-----------|--------|
| DOM-01 | Núcleo Transaccional Online | ~174,000 | 4 COBOL + 1 ALGOL | CRÍTICO |
| DOM-02 | Gestión del Ciclo de Cuenta | ~115,000 | 29 COBOL | ALTO |
| DOM-03 | Movimientos y Registro Contable | ~115,000 | 8 COBOL + 1 ALGOL | CRÍTICO |
| DOM-04 | Lote Nocturno / Estado de Cuenta | ~96,000 | 4 COBOL | ALTO |
| DOM-05 | Pagos e Interbancarios (SPEI) | ~35,000 | 5 COBOL + 2 ALGOL | CRÍTICO `[REGLA-CNBV]` |
| DOM-06 | Productos Especiales CPE/TEF/Prepago | ~57,000 | 10 COBOL | MEDIO |
| DOM-07 | Tarjetas y Medios de Pago (BD04) | ~50,000 | 5 COBOL + 1 ALGOL | ALTO |
| DOM-08 | Comisiones y Cobros | ~12,000 | 3 COBOL | ALTO `[RIESGO-CONDUSEF]` |
| DOM-09 | Tesorería, Replicación y Control Dual | ~30,000 | 6 COBOL | MEDIO |
| DOM-10 | Control Operativo, Utilerías y Sistemas Externos | ~165,000 | 25 COBOL + 9 ALGOL | BAJO–MEDIO |

---

### DOM-01: Núcleo Transaccional Online (LINEA)

**Función**: Dispatcher principal del sistema online. Recibe transacciones de terminales vía COMS/MCS, determina el tipo de operación y orquesta su procesamiento. Punto de entrada de toda operación en línea de S500.

**Señal WFL**: Declarado en LOTE WFL como `P010 ! APLICACION`. Accede a la totalidad de los 57 datasets de CAPTACION + BD04-TARJETAS.

| Programa | Tipo | LOC | Rol |
|---------|------|-----|-----|
| P010 | COBOL | 52,656 | Dispatcher de transacciones — 3 modos (LINEA/LOTE/PARALELISMO); accede a TODOS los datasets CAPTACION + BD04-TARJETAS vía L039 |
| P010_PRO | COBOL | 42,310 | Módulo de procedimientos de P010 (subrutinas de proceso) |
| P010_PAR | COBOL | 11,018 | Parámetros e inicialización de P010 |
| L010_CONTROL | ALGOL | 27,612 | Librería de control: gestión de sesiones COMS, dispatch de mensajes MCS |
| PRO_CAN | INC | 40,892 | Copybook masivo de procedimientos cancelación/reversa (incluido por P010) |

**LOC total**: ~174,000 · **Dependencias**: todos los demás dominios · **Riesgo**: CRÍTICO — cualquier divergencia en P010 impacta la totalidad del sistema.

`[HITL-REQUIRED]` P010 tiene 420+ record types $SET. Necesita revisión line-by-line de su dispatch table para mapear todos los tipos de transacción soportados.

---

### DOM-02: Gestión del Ciclo de Cuenta

**Función**: Alta, modificación, baja y consulta del expediente de cuenta. Incluye actualización de datos contractuales (BDB03), parámetros de producto (costos, grupos, ligas) y consultas de estado.

**Señal DASDL**: Primariamente BDB01 (header) + BDB02 (estado/saldos) + BDB03 (contrato).

| Programa | LOC | BDB clave | Función probable |
|---------|-----|-----------|-----------------|
| P015 | 17,734 | BDB00+BDB02 | DISPERSADOR — distribución de operaciones / alta de cuenta |
| P102 | 9,456 | BDB00-BDB22 | Mantenimiento masivo de cuenta |
| P110 | 10,380 | BDB00+BDB02+BDB91 | Actualización de estado de cuenta |
| P127 | 5,854 | BDB00+BDB22+BDB91 | Esquema contable de cuenta (BDB22=ESQCONT) |
| P120 | 9,540 | BDB00+BDB35/36/43 | Gestión productos especiales por cuenta |
| P191 | 6,130 | BDB00+BDB02 | Consulta / lectura estado de cuenta |
| P170 | 6,964 | BDB00+BDB14+BDB91 | Totales y cifras por cuenta (BDB14=TOTCVES) |
| P109 | 5,690 | BDB00+BDB44 | Costos evolutivos de cuenta (BDB44=CTOSEVOL) |
| P108 | 3,726 | BDB00+BDB44 | Costos evolutivos (variante) |
| P107 | 4,562 | BDB00+BDB50 | Ligas de tesorería (BDB50=LIGASTESO) |
| P115 | 4,662 | BDB00+BDB48 | Costos GCE (BDB48=CTOSGCE) |
| P117 | 4,330 | BDB00+BDB56+BDB57 | Maker-check + pantalla sucursal |
| P160 | 4,204 | BDB00+BDB06+BDB09 | Histórico + cifras |
| P189 | 4,436 | BDB00+BDB06 | Histórico de cuenta |
| P176 | 3,090 | BDB00+BDB06 | Histórico (variante) |
| P161 | 1,102 | BDB00+BDB06 | Histórico pequeño |
| P155 | 3,564 | BDB00+BDB25+BDB91 | Pagos pendientes extendidos |
| P199 | 3,662 | BDB00+BDB06+BDB91 | Histórico + restart |
| P185 | 794 | BDB03+BDB05+BDB06 | Instrumentos + histórico |
| P184 | 782 | BDB02+BDB37+BDB39 | CPE/grupos en cuenta |
| P174 | 2,224 | BDB02+BDB03+BDB91 | Condiciones contractuales |
| P178 | 3,434 | BDB00+BDB28+BDB91 | Comisiones cobro (BDB28=COMICOB) |
| P121 | 932 | BDB00+BDB09+BDB91 | Cifras + restart |
| P100 | 1,186 | BDB02+BDB91 | Estado mínimo |
| P103 | 664 | BDB02+BDB07+BDB13 | Movimientos día + clave |
| P179 | 972 | BDB02 | Solo estado de cuenta |
| P187 | 3,762 | BDB02 | Solo estado de cuenta (mediano) |
| P005 | 5,334 | BDB00+BDB02 archivos | Pre-paso / setup inicial |
| P290 | 5,318 | BDB00+BDB51+BDB91 | Cuenta de origen (BDB51=RCTAORI) |

**LOC total**: ~115,000

`[AMBIGUO]` P015 = DISPERSADOR: ¿dispersión de montos a múltiples cuentas (nómina) o routing de operaciones? Validar con Banamex.

---

### DOM-03: Movimientos y Registro Contable

**Función**: Registro, modificación y consulta de transacciones individuales. Incluye el ciclo de movimientos del día (MOVDIA) y la generación del registro de transacción (MOVIMIENTO).

**Señal DASDL**: BDB04 (MOVIMIENTO) + BDB07 (MOVDIA) + BDB08 (DEVOLUCION) + BDB47 (MOVDIA v2).

| Programa | LOC | BDB clave | Función probable |
|---------|-----|-----------|-----------------|
| P142 | 29,138 | **BDB02 exclusivo** | Batch masivo sobre estado de cuenta (balance recalc o cierre de período) `[AMBIGUO]` |
| P144 | 28,994 | **BDB02 exclusivo** | Batch masivo — probable par de P142 (cargos vs abonos) `[AMBIGUO]` |
| P130 | 31,762 | BDB04+BDB12+BDB35-45 | Procesamiento batch complejo (compensación + productos) |
| P165 | 11,286 | BDB04+BDB24+BDB25+BDB91 | Movimiento + pagos pendientes |
| P180 | 10,076 | BDB04+BDB36+BDB50+BDB91 | Movimiento + grupos comerciales + tesorería |
| P181 | 4,088 | BDB04+BDB50+BDB91 | Movimiento + ligas tesorería |
| L019_SALDOS | 1,146 ALGOL | — | **Librería de cálculo de saldos** (disponible/contable/retenido) |
| P103 | 664 | BDB07+BDB13 | Movimientos del día + claves |

**LOC total**: ~116,000

`[CRÍTICO]` P142 y P144 son programas de 29K LOC cada uno que **únicamente** acceden BDB02 (CONTROL v2 = estado/saldos). Esto sugiere que recalculan o consolidan balances para un universo completo de cuentas en batch. Son candidatos directos al riesgo de equivalencia COMP-3 → BigDecimal.

`[HITL-REQUIRED]` Confirmar con Banamex: ¿P142 = cargos y P144 = abonos, o ambos son procesadores de estado de cuenta de diferentes tipos de producto?

`[REGLA-BANCARIA-MX]` L019_SALDOS es el árbitro de los 4 tipos de saldo (disponible, contable, retenido, saldo para intereses). Su lógica debe reproducirse con precisión absoluta en el sistema moderno.

---

### DOM-04: Lote Nocturno / Estado de Cuenta

**Función**: Procesamiento batch del ciclo diario: generación de estados de cuenta, acumulados CNBV, cierres de período, archive de movimientos.

**Señal WFL**: El job `S500/WFL/LINEA/24MTP005` gestiona el ciclo completo (SUBELINEA/BAJALINEA). El REORG_GARBAGE de BD01CAPTACION menciona datasets clave: B03CONTRATOS, B06HISTORICO, B12COMPEN, B52CTRLDEPRET.

| Programa | LOC | BDB clave | Función probable |
|---------|-----|-----------|-----------------|
| P020 | 44,012 | BDB00+BDB02+BDB52/53/54/55 | **Procesador batch principal** (estado de cuenta / cierre) + control de depósito-retiro + réplicas |
| P105 | 20,556 | BDB04+BDB12+BDB13+BDB14+BDB46 | Compensación + diálogo + claves |
| P130 | 31,762 | Amplio | (Compartido con DOM-03) |
| WOR | 23,980 INC | — | Working storage del batch (área de trabajo principal) |
| WOR_CAN | 18,554 INC | — | Working storage cancelaciones batch |
| WOR_DAS | 9,288 INC | — | Working storage DMSII batch |

**LOC total**: ~95,000

`[RIESGO-CNBV-REPORTE]` P020 accede a BDB52 (CTRLDEPRET) + BDB53 (ENVREPLICA) + BDB54 (RECREPLICA): esto indica que genera o sincroniza datos hacia otro sistema (posiblemente el sistema de reportes regulatorios o un hub). Esta dependencia debe mapearse en el equivalence framework.

---

### DOM-05: Pagos e Interbancarios (SPEI / CIE / TEF)

**Función**: Procesamiento de pagos electrónicos hacia y desde otros bancos. Incluye cuenta ordenante (originating), recepción de beneficiario, y procesamiento asíncrono.

**Señal WFL**: P080 declarado como `CUENTA ORDENANTE` en el propio WFL. Señal BDB: BDB21 (INTERBANC) + BDB24/25 (PAGOSPEND) + BDB35 (NUMTEF).

| Programa | LOC | BDB / Señal | Función probable |
|---------|-----|-------------|-----------------|
| P080 | 18,548 | Sin DMSII directo | **CUENTA ORDENANTE** (SPEI/CIE originating) — usa interfaces externas |
| P164 | 5,262 | BDB24+BDB25+BDB52+BDB53+BDB54 | Pagos pendientes + control depósito + réplicas |
| P200 | 3,106 | Sin DMSII directo | `[AMBIGUO]` — probable recepción SPEI beneficiario o CIE |
| P280 | 3,298 | Sin DMSII directo | `[AMBIGUO]` — probable interfaz pago diferido |
| L091_ASINCRONA | 1,028 ALGOL | — | Librería procesamiento asíncrono (respuestas SPEI) |
| L093_ASINCRONA | 1,030 ALGOL | — | Librería asíncrona variante |
| P091 | 112 | — | Handler asíncrono (pair con L091) |
| P093_ASINCRONO | 114 | — | Handler asíncrono (pair con L093) |

**LOC total**: ~33,000

`[REGLA-CNBV]` El procesamiento SPEI (Sistema de Pagos Electrónicos Interbancarios) tiene tiempos mandatorios de Banxico (< 30 segundos en ventana operativa). El equivalence framework debe validar no solo corrección sino latencia.

`[CONSULTAR→BANCO]` P200 y P280 sin acceso DMSII son sospechosos — ¿son interfaces hacia S100 o hacia PROSA/Banxico? Requiere revisión de sus ENVIRONMENT DIVISION y SELECT statements.

---

### DOM-06: Productos Especiales (CPE / TEF / Grupos / Prepago)

**Función**: Gestión de productos de captación que van más allá de la cuenta de cheque básica: grupos de comercialización, CPE (posiblemente Cuentas de Pago Especial), TEF numérica, sub-grupos, BIN/prepago.

**Señal DASDL**: BDB35–BDB45 (extensión de producto), BDB40/41 (prepago/BIN).

| Programa | LOC | BDB clave | Función probable |
|---------|-----|-----------|-----------------|
| P330 | 15,642 | BDB00+BDB37+BDB38+BDB39 | Gestión grupo CPE + sub-grupos + cuentas CPE |
| P168 | 4,194 | BDB35+BDB36+BDB43+BDB45+BDB91 | TEF + grupos comerciales + rendimientos |
| P120 | 9,540 | BDB35+BDB36+BDB43 | Productos especiales y grupos |
| P130 | 31,762 | BDB35/36/42-45 | (Compartido con DOM-03/04) |
| P335 | 10,198 | BDB00+BDB02+BDB91 | `[AMBIGUO]` alto LOC con acceso básico — posible procesador de producto genérico |
| P400 | 2,068 | BDB37+BDB38+BDB39 | Grupos CPE (variante pequeña) |
| P420 | 1,966 | BDB02+BDB91 | Estado + restart |
| P430 | 2,070 | BDB02+BDB91 | Estado + restart |
| P310 | 2,196 | BDB37+BDB39+BDB06 | CPE + histórico |
| P184 | 782 | BDB37+BDB39 | CPE pequeño |

**LOC total**: ~57,000

`[AMBIGUO]` BDB37 (GRUPOCPE) y BDB39 (CTASCPE): CPE puede ser "Cuentas de Pago Especial" (CNBV), "Cuenta para Personas con Empleo" o un código interno de Banamex. Definición regulatoria impacta si aplica `[REGLA-CNBV]` o solo `[REGLA-BANCO]`.

---

### DOM-07: Tarjetas y Medios de Pago (BD04)

**Función**: Gestión de tarjetas de débito/prepago asociadas a las cuentas de captación. Base de datos independiente BD04TARJETAS con 18 datasets (S500B01P–S500B19P).

**Señal**: Única base de datos separada (BD04TARJETAS vs BD01CAPTACION). Solo P010 accede directamente vía BDB01M; L039 encapsula todo el acceso.

| Programa | LOC | Señal | Función probable |
|---------|-----|-------|-----------------|
| L039_ACCESOBD04 | 23,494 ALGOL | BD04 librería | **Única librería de acceso BD04** — todo card processing pasa por aquí |
| P305 | 3,606 | BDB04+BDB39+BDB48+BDB49+BDB50 | Movimiento + CPE + compensación depósitos pendientes |
| P315 | 4,134 | BDB04+BDB05+BDB06+BDB91 | Movimiento + instrumentos + histórico |
| P629_CARGABD06 | 1,310 | Sin DMSII directo | Cargador de datos en BD06 `[AMBIGUO: BD06 no está en inventario DASDL]` |
| P630_TARINTERCAM | 2,718 | Sin DMSII directo | **Tarjetas de Intercambio** (PROSA/Visa/MC — interchange fee processing) |
| L046_REVOCA | 600 ALGOL | — | **Revocación** de tarjetas / transacciones |
| L040_LIGAS | 742 ALGOL | — | Ligas/vínculos entre registros (navegación DMSII SET/SUBSET) |

**LOC total**: ~36,000

`[CONSULTAR→BANCO]` P629 hace referencia a BD06 que no existe en el inventario DASDL. ¿Es un schema que no fue incluido en el POC extract? ¿O es externo a S500?

`[RIESGO-CONDUSEF]` P630 (intercambio de tarjetas) probablemente contiene cálculo de comisiones de intercambio. Requiere validación con DOM-08 (Comisiones).

---

### DOM-08: Comisiones y Cobros

**Función**: Cálculo, acumulación y cobro de comisiones por servicios bancarios. Los 7 tipos de COMICOB (BDB28–BDB34) sugieren una taxonomía de comisiones con al menos 7 categorías.

**Señal DASDL**: BDB28–BDB34 todos con nombre "COMICOB" (comisiones cobro).

| Programa | LOC | BDB clave | Función probable |
|---------|-----|-----------|-----------------|
| P178 | 3,434 | BDB28+BDB91 | Comisiones cobro tipo 1 |
| P155 | 3,564 | BDB25+BDB91 | Pagos pendientes + posible comisión diferida |
| P115 | 4,662 | BDB48+BDB91 | Costos GCE (posiblemente comisiones GCE) |

**LOC total**: ~12,000 (bajo LOC directo — la lógica real puede estar embebida en DOM-03/DOM-04)

`[RIESGO-CONDUSEF]` Los 7 tipos de COMICOB deben mapearse contra el contrato de adhesión de Banamex y el Registro de Comisiones CONDUSEF. Si cualquiera no está registrado en CONDUSEF, es un compliance gap. Escalar a DOM-08 en regulatory mapping (Fase 2).

`[HITL-REQUIRED]` Identificar cuáles de los BDB28–34 corresponden a qué comisiones del contrato de adhesión. Es muy probable que no todas estén activas.

---

### DOM-09: Tesorería, Replicación y Control Dual

**Función**: Gestión de ligas hacia el sistema de tesorería, control de depósitos/retiros con límites regulatorios, replicación de datos hacia sistemas externos, y maker-checker de aprobación.

**Señal DASDL**: BDB50 (LIGASTESO) + BDB51 (RCTAORI) + BDB52–55 (depret + réplicas) + BDB56 (MAKERCHEK).

| Programa | LOC | BDB clave | Función probable |
|---------|-----|-----------|-----------------|
| P107 | 4,562 | BDB50+BDB49 | Ligas tesorería + compensación depósitos |
| P180 | 10,076 | BDB50+BDB36+BDB91 | Tesorería + grupos |
| P181 | 4,088 | BDB50+BDB91 | Tesorería |
| P290 | 5,318 | BDB51+BDB91 | Cuenta de origen (RCTAORI) |
| P164 | 5,262 | BDB52+BDB53+BDB54 | Control depósito-retiro + réplica envío/recepción |
| P117 | 4,330 | BDB56+BDB57 | Maker-check + pantalla sucursal |

**LOC total**: ~33,000

`[AMBIGUO]` BDB53/BDB54 (ENVREPLICA/RECREPLICA): ¿replica hacia qué sistema? ¿Hub de Banamex? ¿Sistema CNBV? ¿Otro core bancario? Esta pregunta es crítica para el diseño de CDC en Fase 6 (Data Migration).

---

### DOM-10: Control Operativo, Utilerías y Sistemas Externos

**Función**: Todo lo que mantiene el sistema operando sin ser directamente negocio: monitor, tiempos, activación de medios, MAPLI, TELETON, librerías de acceso a bases auxiliares, y utilerías de mantenimiento/pruebas.

**Sub-grupos:**

**Control del sistema (WFL-confirmados):**
| Programa | LOC | Función confirmada / probable |
|---------|-----|-------------------------------|
| P038 | 5,796 | MONITOR (declarado en WFL) |
| P050 | 3,668 | ACTIVA MEDIOS (declarado en WFL) |
| P055 | 3,330 | `[AMBIGUO]` — invocado en WFL |
| P005 | 5,334 | Pre-paso/setup (invocado en WFL antes de P010) |
| L030_TIEMPOS | 1,962 ALGOL | Cálculos de fecha/hora |
| L060_CONSULFOR | 504 ALGOL | `[AMBIGUO]` consulta formas |

**MAPLI y TELETON:**
| Programa | LOC | Función |
|---------|-----|---------|
| L035_MAPLI | 10,802 ALGOL | Librería de acceso a BD MAPLI (sistema de mensajería / aplicaciones?) |
| MAPLI_WOR | 392 INC | Working storage MAPLI |
| MAPLI_PRO | 232 INC | Procedimientos MAPLI |
| L045_TELETON | 144 ALGOL | Acceso BD TELETON (donaciones/fondo de emergencias?) `[AMBIGUO]` |

**Utilerías y programas sin DMSII no clasificados:**
| Programa | LOC | Nota |
|---------|-----|------|
| P104 | 9,022 | Probable tabla de parámetros del sistema |
| P186 | 10,800 | `[AMBIGUO]` alto LOC, sin DMSII |
| P197 | 8,234 | `[AMBIGUO]` |
| P131 | 6,788 | `[AMBIGUO]` |
| P125 | 4,920 | `[AMBIGUO]` |
| P195 | 5,312 | `[AMBIGUO]` |
| P140 | 4,854 | `[AMBIGUO]` |
| P190 | 3,344 | `[AMBIGUO]` |
| P188 | 2,616 | `[AMBIGUO]` |
| P106 | 2,700 | `[AMBIGUO]` |
| P320 | 2,660 | `[AMBIGUO]` |
| P101 | 1,634 | `[AMBIGUO]` |
| P655_SCRAMBLING | 1,720 | **Data masking/scrambling** (utilería de pruebas) |
| L070 | 706 ALGOL | `[AMBIGUO]` (instalado desde WFL como INSTALAL070) |
| L080 | 3,342 ALGOL | `[AMBIGUO]` |
| L081 | 5,600 ALGOL | `[AMBIGUO]` |
| L050 | 12,800 ALGOL | `[AMBIGUO]` gran librería ALGOL sin $SET |

**LOC total**: ~165,000

`[ACCIÓN-REQUERIDA]` Los 13 programas `[AMBIGUO]` sin acceso DMSII con LOC significativo (P104, P186, P197, P131, P125, P195, P140, L050, L080, L081) deben analizarse en Etapa 2 (Static Analysis) para determinar: ¿son interfaces hacia sistemas externos (MCS, PROSA, BANXICO), ¿tablas de parámetros extensas, ¿o lógica de negocio no evidente por ausencia de DMSII?

---

## Distribución de LOC por Dominio

```
DOM-01 Núcleo Transaccional       ████████████████████  174,000  (19%)
DOM-02 Gestión de Cuenta          ██████████████        115,000  (13%)
DOM-03 Movimientos y Contabilidad ██████████████        116,000  (13%)
DOM-04 Lote Nocturno / EDC        ████████████           95,000  (11%)
DOM-10 Control Operativo          ████████████          165,000  (18%) [incluye ambiguos]
DOM-06 Productos Especiales       ███████                57,000   (6%)
DOM-07 Tarjetas BD04              █████                  36,000   (4%)
DOM-05 Pagos e Interbancarios     ████                   33,000   (4%)
DOM-09 Tesorería y Réplicas       ████                   33,000   (4%)
DOM-08 Comisiones                 ██                     12,000   (1%)
INC (shared copybooks)            ███████                62,000   (7%)
DASDL / WFL                       ██                     49,000   (5%) [no modernizable]
                                  ─────────────────────────────
TOTAL                             898,596
```

---

## Riesgos Críticos por Dominio

| Riesgo | Dominio | Prioridad |
|--------|---------|-----------|
| P142/P144 (58K LOC, solo BDB02): naturaleza exacta de proceso desconocida | DOM-03 | CRÍTICO |
| P010 (52K LOC) accede a 420+ record types: dispatch table no mapeada | DOM-01 | CRÍTICO |
| L019_SALDOS: lógica de saldos disponible/contable/retenido puede tener edge cases COMP-3 | DOM-03 | CRÍTICO |
| P080 sin DMSII: interfaz SPEI no visible en código | DOM-05 | CRÍTICO |
| BDB53/54 ENVREPLICA/RECREPLICA: receptor desconocido, puede ser sistema regulatorio | DOM-09 | ALTO |
| BDB28–34 (7 COMICOB): mapeo contra Registro CONDUSEF pendiente | DOM-08 | ALTO |
| P186/P197/L050/L080/L081 (35K LOC combinados): función desconocida | DOM-10 | ALTO |
| BD06 (P629): schema no en inventario | DOM-07 | ALTO |
| `SISTEMA/FORZA` en WFL: reorganización DMSII — dependencia de schedule nocturno | DOM-04 | MEDIO |

---

## Propuesta de Waves de Modernización

Basado en dependencias de delivery (no en prioridad de negocio — esa la define Banamex):

```
Wave 0 (Etapas 1-3 RE) ──→  Análisis completo antes de cualquier build
Wave 1 (DOM-02)         ──→  Gestión de Cuenta (menor riesgo de equivalencia,
                              BDB01/02/03 con semántica clara)
Wave 2 (DOM-07)         ──→  Tarjetas BD04 (base de datos separada = aislamiento natural)
Wave 3 (DOM-03)         ──→  Movimientos (alta equivalencia requerida, parallel-run ≥ 3 meses)
Wave 4 (DOM-04)         ──→  Lote Nocturno / EDC (depende de Wave 3)
Wave 5 (DOM-05)         ──→  Pagos/SPEI (regulatorio — sign-off Banxico antes del wave)
Wave 6 (DOM-01)         ──→  Núcleo Transaccional (último — depende de todos los anteriores)
Wave 7 (DOM-06, 08, 09) ──→  Productos especiales + Comisiones + Tesorería
DOM-10                  ──→  Paralelo con cada wave (utilerías, control, sistemas externos)
```

`[ACCIÓN-REQUERIDA]` Esta secuencia debe validarse con Banamex (dependencias de negocio y prioridades regulatorias pueden reordenar las waves).

---

## Agenda de Validación HITL con SME Banamex

Items mínimos para validación antes de cerrar Etapa 4:

| # | Pregunta | Dominio | Urgencia |
|---|---------|---------|---------|
| 1 | ¿Qué hace exactamente P142? ¿Y P144? ¿Son cargo vs abono del batch? | DOM-03 | CRÍTICA |
| 2 | ¿Qué es CPE? ¿Cuenta de Pago Especial regulatoria o código interno? | DOM-06 | ALTA |
| 3 | ¿P080 se conecta directamente a Banxico SPEI o pasa por un hub intermedio? | DOM-05 | ALTA |
| 4 | ¿Qué sistemas reciben la réplica de BDB53/BDB54? | DOM-09 | ALTA |
| 5 | ¿P186, P197, L050 tienen función de negocio o son infraestructura? | DOM-10 | ALTA |
| 6 | ¿BD06 existe en producción? ¿Por qué no está en el inventario DASDL? | DOM-07 | ALTA |
| 7 | ¿P015 (DISPERSADOR) procesa nómina, o es routing de operaciones? | DOM-02 | MEDIA |
| 8 | ¿Los 7 tipos de COMICOB (BDB28–34) están todos activos? ¿Mapean a la tabla CONDUSEF? | DOM-08 | ALTA |
| 9 | ¿L035_MAPLI es un sistema de mensajería interna de Banamex o un framework externo? | DOM-10 | MEDIA |
| 10 | Confirmar que el inventario de 114 archivos = totalidad de S500 producción (no subset POC) | ETAPA 0 | CRÍTICA |

---

*Última actualización: 2026-06-30 · v0.1 DRAFT · Análisis multi-señal completado (4 señales fusionadas). Pendiente validación HITL con SME técnico Banamex.*
*Siguiente paso: Etapa 1 Static Analysis — call graph completo de P010, dependency matrix, métricas de complejidad ciclomática.*