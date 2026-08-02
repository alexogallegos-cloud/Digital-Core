# Mapeo BIAN — Sistema S500 (Cargos y Abonos)
> Gemelo Cognitivo · Capa 3 · Generado: 2026-07-17 · 114 programas · 17 capacidades
> Indexado: ✅ 2026-07-17 — Programa→Capacidad — fuente autoritativa de resolución de capacidad
> **Tipo-artefacto:** `Mapa`  
> **Capa-GemCog:** `3`  
> **Propósito:** Mapeo explícito de los 114 programas S500 a capacidades BIAN — permite determinar qué capability owners son impactados por un cambio en S500.  
> **Relacionado-con:** capability-map · capability-model-taxonomy · bian-mapping-s151

## Resumen por capacidad BIAN

| BIAN ID | Capacidad | # Prog | LOC Total | Confianza Prom |
|---------|-----------|--------|-----------|----------------|
| 2.1.1 | Teller | 10 | 258.400 | ALTA |
| 2.2.6 | ATM | 2 | 13.098 | MEDIA |
| 4.1.2 | Holdings | 1 | 1.146 | MEDIA |
| 5.1.1 | Deposits | 19 | 84.980 | BAJA |
| 6.1.3 | Payments | 9 | 116.530 | BAJA |
| 6.1.4 | Statements | 5 | 13.988 | BAJA |
| 6.1.5 | Interest & Fees | 4 | 52.260 | MEDIA |
| 6.5.2 | Compliance & Regulation | 2 | 3.364 | MEDIA |
| 6.6.1 | Financial Servicing | 9 | 87.092 | BAJA |
| 6.7.1 | Financial Reconciliation | 1 | 4.204 | ALTA |
| 6.7.2 | Operational Reconciliation | 14 | 84.910 | BAJA |
| 8.1.1 | Scheduling WFL | 6 | 9.276 | MEDIA |
| 9.1.1 | Operational Data Stores DMSII | 21 | 111.174 | MEDIA |
| 10.1.1 | Access Control | 5 | 42.884 | MEDIA |
| T.1.3 | Payment Schemes SPEI/CLABE | 1 | 11.286 | MEDIA |
| T.2.3 | MQ Async L091-L093 | 4 | 2.284 | ALTA |
| T.3.5 | Security | 1 | 1.720 | ALTA |

### Programas por capacidad

**2.1.1 — Teller** (10 prog · 258.400 LOC)

P010, PRO, P010_PRO, PRO_CAN, WOR, P010_MAS, WOR_CAN, WOR_DAS, P280, L045_TELETON

**2.2.6 — ATM** (2 prog · 13.098 LOC)

P110, P630_TARINTERCAM

**4.1.2 — Holdings** (1 prog · 1.146 LOC)

L019_SALDOS

**5.1.1 — Deposits** (19 prog · 84.980 LOC)

P170, P191, P127, P109, P290, P164, P115, P107, P189, P117, P168, P315, P181, P187, P108, P050, P199, P305, P121

**6.1.3 — Payments** (9 prog · 116.530 LOC)

P020, P142, P144, P155, P178, P176, P174, P161, P179

**6.1.4 — Statements** (5 prog · 13.988 LOC)

P335, P400, P185, P184, L020

**6.1.5 — Interest & Fees** (4 prog · 52.260 LOC)

P130, P330, P320, P310

**6.5.2 — Compliance & Regulation** (2 prog · 3.364 LOC)

P106, P103

**6.6.1 — Financial Servicing** (9 prog · 87.092 LOC)

P105, P015, P045, P180, P120, P102, P005, L046_REVOCA, P046

**6.7.1 — Financial Reconciliation** (1 prog · 4.204 LOC)

P160

**6.7.2 — Operational Reconciliation** (14 prog · 84.910 LOC)

P080, P186, P104, P197, P131, P195, P125, P140, P190, P055, P200, P188, P430, P420

**8.1.1 — Scheduling WFL** (6 prog · 9.276 LOC)

LOTE, L030_TIEMPOS, P101, P100, P075, LINEA

**9.1.1 — Operational Data Stores DMSII** (21 prog · 111.174 LOC)

REORG_GARBAGE_S500BD04TARJETAS, L039_ACCESOBD04, L050, L035_MAPLI, CAPTACION, P038, L081, L080, TARJETAS, AUXILIAR, P629_CARGABD06, L040_LIGAS, TELETON, L070, MAPLI, ATRIBUCTA, L060_CONSULFOR, MSGAAPLI, MAPLI_WOR, MAPLI_PRO, REORG_GARBAGE_S500BD01CAPTACION

**10.1.1 — Access Control** (5 prog · 42.884 LOC)

L010_CONTROL, P010_PAR, L010, P060, COPY_ADMWIN

**T.1.3 — Payment Schemes SPEI/CLABE** (1 prog · 11.286 LOC)

P165

**T.2.3 — MQ Async L091-L093** (4 prog · 2.284 LOC)

L093_ASINCRONA, L091_ASINCRONA, P093_ASINCRONO, P091

**T.3.5 — Security** (1 prog · 1.720 LOC)

P655_SCRAMBLING

---

## Mapeo detallado por programa

_Ordenado por BIAN ID, luego por LOC descendente dentro de cada capacidad._

| Programa | Tipo | LOC | Dominio S500 | BIAN ID | Capacidad BIAN | Rol Funcional | Confianza |
|----------|------|-----|--------------|---------|----------------|---------------|-----------|
| P010 | COBOL | 52.656 | CAPTACION | 2.1.1 | Teller | Hub primario COMS — dispatcher online de todas las transacciones de captación | ALTA |
| PRO | INC | 43.496 | CAPTACION | 2.1.1 | Teller | Copybook de working storage de P010 — define estructuras de datos para transa... | ALTA |
| P010_PRO | COBOL | 42.310 | CONTROL | 2.1.1 | Teller | Variante COBOL de P010 para canal PRO — procesador transaccional de captación... | MEDIA |
| PRO_CAN | INC | 40.892 | CAPTACION | 2.1.1 | Teller | Copybook de P010 para cancelaciones del canal PRO — define estructuras de dat... | ALTA |
| WOR | INC | 23.980 | CAPTACION | 2.1.1 | Teller | Copybook de working storage WOR de P010 — define estructuras de datos del mód... | ALTA |
| P010_MAS | INC | 23.782 | CAPTACION | 2.1.1 | Teller | Copybook masivo de P010 — define estructuras de datos para operaciones bulk d... | ALTA |
| WOR_CAN | INC | 18.554 | CAPTACION | 2.1.1 | Teller | Copybook de cancelaciones WOR para P010 — define estructuras de datos para fl... | ALTA |
| WOR_DAS | INC | 9.288 | CAPTACION | 2.1.1 | Teller | Copybook DAS de P010 — define estructuras de working storage para datos de dí... | ALTA |
| P280 | COBOL | 3.298 | CONTROL | 2.1.1 | Teller | Servidor COMS terciario (LINCOMS) — gateway online de transacciones de captac... | ALTA |
| L045_TELETON ⚠️ NO-TRANSPILABLE | ALGOL | 144 | CAPTACION | 2.1.1 | Teller | Librería de soporte al canal Teletón — procesamiento de depósitos de donación... | MEDIA |
| P110 | COBOL | 10.380 | CAPTACION | 2.2.6 | ATM | Procesador de tarjetas legadas — gestiona tarjetas migradas desde S501/P110 a... | MEDIA |
| P630_TARINTERCAM | COBOL | 2.718 | CONTROL | 2.2.6 | ATM | Gestión de tarjetas intercambiables migradas de S501 — procesamiento de inter... | ALTA |
| L019_SALDOS ⚠️ NO-TRANSPILABLE | ALGOL | 1.146 | CAPTACION | 4.1.2 | Holdings | Consulta de posición de saldo en BD01CAPTACION — librería de balance de cuent... | MEDIA |
| P170 | COBOL | 6.964 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch del ciclo de vida de cuentas de depósito | BAJA |
| P191 | COBOL | 6.130 | CAPTACION | 5.1.1 | Deposits | Operaciones sobre contratos de depósito en BD01CAPTACION | MEDIA |
| P127 | COBOL | 5.854 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — operaciones sobre cuentas de depósito | BAJA |
| P109 | COBOL | 5.690 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — ciclo de vida de cuentas de depósito | BAJA |
| P290 | COBOL | 5.318 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — operaciones especializadas sobre cuentas d... | BAJA |
| P164 | COBOL | 5.262 | CAPTACION | 5.1.1 | Deposits | Actualización de registros de cuenta en BD01CAPTACION — gestión de estado de ... | MEDIA |
| P115 | COBOL | 4.662 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — operaciones de cuenta de depósito | BAJA |
| P107 | COBOL | 4.562 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — operaciones sobre cuentas de depósito | BAJA |
| P189 | COBOL | 4.436 | CAPTACION | **5.1.1 → DEP** | Deposits | Sync activo-activo VDM↔MTY (S084/S087) + desbloqueo implícito vía reinicialización B09PMOTOR + marca STA-BENF Art. 61 LIC (CNBV) + propagación condicional B06 histórico. [Mapeo confirmado 2026-07-22: DEP BAJA confianza pre-reglas → DEP · Validado Mario SME S500] | ALTA |
| P117 | COBOL | 4.330 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — ciclo de vida de contratos de depósito | BAJA |
| P168 | COBOL | 4.194 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — operaciones de ciclo de depósito | BAJA |
| P315 | COBOL | 4.134 | CAPTACION | 5.1.1 | Deposits | Procesamiento de captación — operaciones especializadas en rango 3xx | BAJA |
| P181 | COBOL | 4.088 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — operaciones de depósito en ciclo nocturno | BAJA |
| P187 | COBOL | 3.762 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — operaciones de cuenta de depósito | BAJA |
| P108 | COBOL | 3.726 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — operaciones de depósito en ciclo nocturno | BAJA |
| P050 | COBOL | 3.668 | CONTROL | 5.1.1 | Deposits | Operaciones de captación / tesorería — gestión de cuentas de depósito (clasif... | ALTA |
| P199 | COBOL | 3.662 | CAPTACION | 5.1.1 | Deposits | Procesamiento batch de captación — cierre de operaciones 1xx en ciclo nocturno | BAJA |
| P305 | COBOL | 3.606 | CAPTACION | 5.1.1 | Deposits | Operaciones de captación especializada — cuentas de depósito en Bounded Conte... | ALTA |
| P121 | COBOL | 932 | CAPTACION | 5.1.1 | Deposits | Procesador batch de transacciones de cuentas de captación | MEDIA |
| P020 | COBOL | 44.012 | CAPTACION | 6.1.3 | Payments | Gateway COMS secundario — procesa CARGOS/ABONOS online con 5 copias paralelas... | ALTA |
| P142 | COBOL | 29.138 | CAPTACION | 6.1.3 | Payments | Batch captación-inversiones — extrae contratos BD07 a Teradata (CREDITOS CAN)... | ALTA |
| P144 | COBOL | 28.994 | CAPTACION | 6.1.3 | Payments | Batch reconciliación B01/B03 — genera activaciones masivas BIT-ACTBANDERA par... | ALTA |
| P155 | COBOL | 3.564 | CAPTACION | 6.1.3 | Payments | Procesamiento batch de transacciones de captación (cargos/abonos) — rango 150 | BAJA |
| P178 | COBOL | 3.434 | CAPTACION | 6.1.3 | Payments | Procesamiento batch de transacciones de captación — rango 170-180 | BAJA |
| P176 | COBOL | 3.090 | CAPTACION | 6.1.3 | Payments | Procesamiento de cargos/abonos en BD01CAPTACION via CCW ON PACK — rango 176 | BAJA |
| P174 | COBOL | 2.224 | CAPTACION | 6.1.3 | Payments | Procesamiento batch de transacciones de captación — rango 174 adyacente a P17... | BAJA |
| P161 | COBOL | 1.102 | CAPTACION | 6.1.3 | Payments | Procesamiento batch de transacciones CAPTACION — rango 161 adyacente a P165 (... | BAJA |
| P179 | COBOL | 972 | CAPTACION | 6.1.3 | Payments | Procesamiento CAPTACION con acceso BD01CAPTACION via CCW ON PACK — módulo de ... | BAJA |
| P335 | COBOL | 10.198 | CAPTACION | 6.1.4 | Statements | Generador de estado de cuenta EDOCTA — produce extracto de movimientos y sald... | MEDIA |
| P400 | COBOL | 2.068 | CAPTACION | 6.1.4 | Statements | Generación de estados de cuenta (PID=P335-EDOCTA) — extracto de movimientos y... | ALTA |
| P185 | COBOL | 794 | CAPTACION | 6.1.4 | Statements | Generador batch de extracto o reporte de cuentas de captación | BAJA |
| P184 | COBOL | 782 | CAPTACION | 6.1.4 | Statements | Generador batch de extracto o reporte de cuentas de captación | BAJA |
| L020 | INC | 146 | CAPTACION | 6.1.4 | Statements | Copybook INC de interfaz para consultas de estado de cuenta, movimientos y co... | BAJA |
| P130 | COBOL | 31.762 | CAPTACION | 6.1.5 | Interest & Fees | Motor de cierre de captación — calcula rendimientos, ISR, comisiones mensuale... | ALTA |
| P330 | COBOL | 15.642 | CAPTACION | 6.1.5 | Interest & Fees | Cálculos de productos especiales — calcula rendimientos para inversiones a pl... | MEDIA |
| P320 | COBOL | 2.660 | CONTROL | 6.1.5 | Interest & Fees | Control y cálculo de productos financieros especiales — adyacente a P330 (CAL... | BAJA |
| P310 | COBOL | 2.196 | CAPTACION | 6.1.5 | Interest & Fees | Cálculo de IVA/ISR y comisiones en proceso de captación — rango 310 | MEDIA |
| P106 | COBOL | 2.700 | CONTROL | 6.5.2 | Compliance & Regulation | Reporte o control regulatorio CNBV — proceso de control adyacente a FraudLink... | BAJA |
| P103 | COBOL | 664 | CAPTACION | 6.5.2 | Compliance & Regulation | Generador del archivo FRAUDLINK para reporte regulatorio CNBV (sistema S711) | ALTA |
| P105 | COBOL | 20.556 | CAPTACION | 6.6.1 | Financial Servicing | Programa de servicios de captación — función específica no determinada por ev... | BAJA |
| P015 | COBOL | 17.734 | CAPTACION | 6.6.1 | Financial Servicing | DISPERSADOR de captación — routing online de transacciones COMS al inicio de ... | MEDIA |
| P045 | COBOL | 13.694 | CONTROL | 6.6.1 | Financial Servicing | Programa Teletón — gestiona captación en sucursales especiales (0519/1037/190... | MEDIA |
| P180 | COBOL | 10.076 | CAPTACION | 6.6.1 | Financial Servicing | Programa de servicios de captación — función específica no determinada por ev... | BAJA |
| P120 | COBOL | 9.540 | CAPTACION | 6.6.1 | Financial Servicing | Programa de servicios de captación — función específica no determinada por ev... | BAJA |
| P102 | COBOL | 9.456 | CAPTACION | 6.6.1 | Financial Servicing | Programa auxiliar de captación — función adyacente a P103 (fraude/control) en... | BAJA |
| P005 | COBOL | 5.334 | CAPTACION | 6.6.1 | Financial Servicing | Servicio transversal de fechas valor — validación de días hábiles vía S006 pa... | MEDIA |
| L046_REVOCA ⚠️ NO-TRANSPILABLE | ALGOL | 600 | CAPTACION | 6.6.1 | Financial Servicing | Librería de revocación y cancelación de operaciones bancarias de captación | MEDIA |
| P046 | COBOL | 102 | CONTROL | 6.6.1 | Financial Servicing | Utilitario batch de control de revocación de operaciones (probable companion ... | BAJA |
| P160 | COBOL | 4.204 | CAPTACION | 6.7.1 | Financial Reconciliation | Ajuste y conciliación de diferencias de saldo entre procesos de captación | ALTA |
| P080 | COBOL | 18.548 | CONTROL | 6.7.2 | Operational Reconciliation | Gestor de Cuenta Ordenante ONLINE — administra posición ordenante en transfer... | MEDIA |
| P186 | COBOL | 10.800 | CONTROL | **6.7.2 → ORC** | Operational Reconciliation | Puente S500↔S274: dispatcher Cuenta Global Art. 61 LIC (I01-TRP-CTAGLB → E02-DISP-S274) + tarifas tarjeta IVA/UDIS + trazabilidad R01-CIFCTRL (gate regulatorio CNBV). [Mapeo confirmado 2026-07-22: ORC · Validado Mario SME S500] | ALTA |
| P104 | COBOL | 9.022 | CONTROL | 6.7.2 | Operational Reconciliation | Control operativo batch de mayor LOC en el dominio CONTROL | MEDIA |
| P197 | COBOL | 8.234 | CONTROL | 6.7.2 | Operational Reconciliation | Control operativo batch — cuadratura y verificación de ciclo de captación | MEDIA |
| P131 | COBOL | 6.788 | CONTROL | 6.7.2 | Operational Reconciliation | Control de proceso batch — validación de integridad operativa del lote de cap... | MEDIA |
| P195 | COBOL | 5.312 | CONTROL | 6.7.2 | Operational Reconciliation | Control y cuadratura operativa del batch de captación | MEDIA |
| P125 | COBOL | 4.920 | CONTROL | 6.7.2 | Operational Reconciliation | Control de proceso batch — verificación de integridad operativa | MEDIA |
| P140 | COBOL | 4.854 | CONTROL | 6.7.2 | Operational Reconciliation | Control operativo batch — cuadratura de totales en el ciclo de captación | MEDIA |
| P190 | COBOL | 3.344 | CONTROL | 6.7.2 | Operational Reconciliation | Control de lote — reconciliación y validación operativa de proceso nocturno r... | BAJA |
| P055 | COBOL | 3.330 | CONTROL | 6.7.2 | Operational Reconciliation | Control batch CAPTACION — validación de proceso con acceso BD01CAPTACION via ... | BAJA |
| P200 | COBOL | 3.106 | CONTROL | 6.7.2 | Operational Reconciliation | Control de lote — reconciliación operativa de proceso nocturno rango 200 | BAJA |
| P188 | COBOL | 2.616 | CONTROL | 6.7.2 | Operational Reconciliation | Control de lote — reconciliación operativa de proceso nocturno rango 188 | BAJA |
| P430 | COBOL | 2.070 | CONTROL | 6.7.2 | Operational Reconciliation | Control de lote — proceso de reconciliación operativa rango 430 | BAJA |
| P420 | COBOL | 1.966 | CONTROL | 6.7.2 | Operational Reconciliation | Control de lote — proceso de control adyacente a generación de extractos (P40... | BAJA |
| LOTE | WFL | 3.920 | CONTROL | 8.1.1 | Scheduling WFL | Orquestador del ciclo batch nocturno — secuencia los programas de cierre diar... | ALTA |
| L030_TIEMPOS ⚠️ NO-TRANSPILABLE | ALGOL | 1.962 | CAPTACION | 8.1.1 | Scheduling WFL | Gestión de tiempos de sesión y SLA batch de captación — librería ALGOL de con... | ALTA |
| P101 | COBOL | 1.634 | CONTROL | 8.1.1 | Scheduling WFL | Control de proceso batch — companion de P100 (fecha/período) en secuencia de ... | BAJA |
| P100 | COBOL | 1.186 | CONTROL | 8.1.1 | Scheduling WFL | Control de fecha/período del proceso batch — validación y gestión del día de ... | ALTA |
| P075 | COBOL | 476 | CONTROL | 8.1.1 | Scheduling WFL | Utilitario batch de Cambio-de-Día — control de límite de ciclo EOD | MEDIA |
| LINEA | WFL | 98 | CONTROL | 8.1.1 | Scheduling WFL | Orchestrador WFL del modo de operación en línea — inicia y controla servidore... | ALTA |
| REORG_GARBAGE_S500BD04TARJETAS | WFL | 30.134 | CONTROL | 9.1.1 | Operational Data Stores DMSII | WFL de reorganización y limpieza de BD04TARJETAS — mantenimiento estructural ... | ALTA |
| L039_ACCESOBD04 ⚠️ NO-TRANSPILABLE | ALGOL | 23.494 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Capa de acceso ALGOL a DMSII BD04TARJETAS — encapsula operaciones DASDL sobre... | ALTA |
| L050 ⚠️ NO-TRANSPILABLE | ALGOL | 12.800 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Librería de utilidades generales S500 — funciones compartidas de acceso a dat... | MEDIA |
| L035_MAPLI ⚠️ NO-TRANSPILABLE | ALGOL | 10.802 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | MAPLI — librería de mapa de ligas DMSII para navegación de estructuras relaci... | ALTA |
| CAPTACION | DASDL | 8.336 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Esquema DASDL de la base de datos DMSII S500BD01CAPTACION | ALTA |
| P038 | COBOL | 5.796 | CONTROL | 9.1.1 | Operational Data Stores DMSII | Reorganización de bases de datos DMSII — mantenimiento físico de S500BD01CAPT... | ALTA |
| L081 ⚠️ NO-TRANSPILABLE | ALGOL | 5.600 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Librería de acceso DMSII para consulta de contratos, cuentas y tarjetas en BD... | ALTA |
| L080 ⚠️ NO-TRANSPILABLE | ALGOL | 3.342 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Librería de acceso DMSII (ACCESOBD2K) y señalización INIBATCH de cierre de dí... | MEDIA |
| TARJETAS | DASDL | 2.692 | TARJETAS | 9.1.1 | Operational Data Stores DMSII | Esquema DASDL de BD04TARJETAS — estructura de datos DMSII de tarjetas de débi... | ALTA |
| AUXILIAR | DASDL | 1.862 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Esquema DASDL de BD02AUXILIAR — tablas de trabajo y staging para procesos noc... | ALTA |
| P629_CARGABD06 | COBOL | 1.310 | CONTROL | 9.1.1 | Operational Data Stores DMSII | Carga de datos al esquema BD06 (Teletón) — proceso de inserción a S500BD06TEL... | ALTA |
| L040_LIGAS ⚠️ NO-TRANSPILABLE | ALGOL | 742 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Librería de gestión de vínculos lógicos entre cuentas en BD01CAPTACION | MEDIA |
| TELETON | DASDL | 710 | CONTROL | 9.1.1 | Operational Data Stores DMSII | Esquema DASDL de la BD DMSII S500BD06TELETON (campaña Teletón) | ALTA |
| L070 ⚠️ NO-TRANSPILABLE | ALGOL | 706 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Librería de consulta de parámetros globales del sistema de captación para S127 | BAJA |
| MAPLI | DASDL | 646 | CONTROL | 9.1.1 | Operational Data Stores DMSII | Esquema DASDL de la BD DMSII S500BD05MAPLI (registro de librerías activas) | ALTA |
| ATRIBUCTA | DASDL | 544 | CONTROL | 9.1.1 | Operational Data Stores DMSII | Esquema DASDL de la BD DMSII S500BD07ATRIBUCTAS (atributos de calificación de... | ALTA |
| L060_CONSULFOR ⚠️ NO-TRANSPILABLE | ALGOL | 504 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Librería de consulta de formatos de pantalla y reporte del sistema online de ... | MEDIA |
| MSGAAPLI | DASDL | 438 | CONTROL | 9.1.1 | Operational Data Stores DMSII | Esquema DASDL de la BD DMSII S500BD03MSGAAPLI (mensajes inter-aplicación con ... | ALTA |
| MAPLI_WOR | INC | 392 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Copybook INC de Working Storage para acceso a S500BD05MAPLI (registro de libr... | MEDIA |
| MAPLI_PRO | INC | 232 | CAPTACION | 9.1.1 | Operational Data Stores DMSII | Copybook INC de Procedure Division para acceso a S500BD05MAPLI (registro de l... | MEDIA |
| REORG_GARBAGE_S500BD01CAPTACION | WFL | 92 | CONTROL | 9.1.1 | Operational Data Stores DMSII | WFL de reorganización y garbage collection de BD DMSII S500BD01CAPTACION | ALTA |
| L010_CONTROL ⚠️ NO-TRANSPILABLE | ALGOL | 27.612 | CAPTACION | 10.1.1 | Access Control | Librería de control central del sistema online — verifica W77-FACULTAD, gesti... | ALTA |
| P010_PAR | COBOL | 11.018 | CONTROL | 10.1.1 | Access Control | Variante de parámetros/paralelo de P010 — gestiona configuración de acceso o ... | BAJA |
| L010 | INC | 3.242 | CAPTACION | 10.1.1 | Access Control | Copybook L010_CONTROL — control de acceso, flujo batch y logging de eventos e... | MEDIA |
| P060 | COBOL | 758 | CONTROL | 10.1.1 | Access Control | Módulo online de control de acceso y verificación de estado de cuentas | MEDIA |
| COPY_ADMWIN | COBOL | 254 | CONTROL | 10.1.1 | Access Control | Copybook de ventana administrativa del sistema de control | BAJA |
| P165 | COBOL | 11.286 | CAPTACION | T.1.3 | Payment Schemes SPEI/CLABE | Procesador de resultados de dispersión — procesa output batch de dispersión m... | MEDIA |
| L093_ASINCRONA ⚠️ NO-TRANSPILABLE | ALGOL | 1.030 | CAPTACION | T.2.3 | MQ Async L091-L093 | Mensajería asíncrona L093 — coordinación con Fraud Manager, routing de código... | ALTA |
| L091_ASINCRONA ⚠️ NO-TRANSPILABLE | ALGOL | 1.028 | CAPTACION | T.2.3 | MQ Async L091-L093 | Mensajería asíncrona L091 — procesamiento de cancelaciones y operaciones de l... | ALTA |
| P093_ASINCRONO | COBOL | 114 | CONTROL | T.2.3 | MQ Async L091-L093 | Módulo de procesamiento asíncrono batch para cancelaciones y operaciones de l... | ALTA |
| P091 | COBOL | 112 | CONTROL | T.2.3 | MQ Async L091-L093 | Módulo online de procesamiento asíncrono — gestión de operaciones no bloquean... | ALTA |
| P655_SCRAMBLING | COBOL | 1.720 | CONTROL | T.3.5 | Security | Enmascaramiento (scrambling) de PAN y número de cuenta — activo únicamente en... | ALTA |

---

## Cobertura por dominio S500

| Dominio S500 | Total Programas | BIAN IDs cubiertos |
|--------------|-----------------|-------------------|
| CAPTACION | 72 | 2.1.1, 2.2.6, 4.1.2, 5.1.1, 6.1.3, 6.1.4, 6.1.5, 6.5.2, 6.6.1, 6.7.1, 8.1.1, 9.1.1, 10.1.1, T.1.3, T.2.3 |
| CONTROL | 41 | 2.1.1, 2.2.6, 5.1.1, 6.1.5, 6.5.2, 6.6.1, 6.7.2, 8.1.1, 9.1.1, 10.1.1, T.2.3, T.3.5 |
| TARJETAS | 1 | 9.1.1 |

---

## Programas de baja confianza — requieren revisión SME

_Total: 41 programas con confianza BAJA. Se recomienda revisión HITL con SME de S500 para cada uno._

| Programa | Tipo | LOC | BIAN ID | Capacidad | Justificación (resumen) |
|----------|------|-----|---------|-----------|------------------------|
| P010_PAR | COBOL | 11.018 | 10.1.1 | Access Control | P010_PAR combina el prefijo P010 (gateway de captación) con el sufijo _PAR (parámetros o instancia paralela) |
| COPY_ADMWIN | COBOL | 254 | 10.1.1 | Access Control | Copybook COBOL muy pequeño (254 LOC) en el dominio CONTROL sin escrituras DMSII |
| P170 | COBOL | 6.964 | 5.1.1 | Deposits | Programa COBOL de 6,964 LOC en dominio CAPTACION de S500 |
| P127 | COBOL | 5.854 | 5.1.1 | Deposits | Programa COBOL de 5,854 LOC en dominio CAPTACION |
| P109 | COBOL | 5.690 | 5.1.1 | Deposits | Programa COBOL de 5,690 LOC en dominio CAPTACION |
| P290 | COBOL | 5.318 | 5.1.1 | Deposits | Programa COBOL de 5,318 LOC en dominio CAPTACION, número P290 (rango 2xx) |
| P115 | COBOL | 4.662 | 5.1.1 | Deposits | Programa COBOL de 4,662 LOC en dominio CAPTACION |
| P107 | COBOL | 4.562 | 5.1.1 | Deposits | Programa COBOL de 4,562 LOC en dominio CAPTACION |
| P189 | COBOL | 4.436 | 5.1.1 | Deposits | Programa COBOL de 4,436 LOC en dominio CAPTACION |
| P117 | COBOL | 4.330 | 5.1.1 | Deposits | Programa COBOL de 4,330 LOC en dominio CAPTACION |
| P168 | COBOL | 4.194 | 5.1.1 | Deposits | Programa COBOL de 4,194 LOC en dominio CAPTACION |
| P315 | COBOL | 4.134 | 5.1.1 | Deposits | Programa COBOL de 4,134 LOC en dominio CAPTACION |
| P181 | COBOL | 4.088 | 5.1.1 | Deposits | Programa COBOL de 4,088 LOC en dominio CAPTACION |
| P187 | COBOL | 3.762 | 5.1.1 | Deposits | Programa COBOL de 3,762 LOC en dominio CAPTACION |
| P108 | COBOL | 3.726 | 5.1.1 | Deposits | Programa COBOL de 3,726 LOC en dominio CAPTACION |
| P199 | COBOL | 3.662 | 5.1.1 | Deposits | Programa COBOL de 3,662 LOC en dominio CAPTACION |
| P155 | COBOL | 3.564 | 6.1.3 | Payments | Programa COBOL de dominio CAPTACION con 3,564 LOC |
| P178 | COBOL | 3.434 | 6.1.3 | Payments | Programa COBOL de dominio CAPTACION con 3,434 LOC |
| P176 | COBOL | 3.090 | 6.1.3 | Payments | Vocab confirma que P176 accede S500BD01CAPTACION mediante CCW ON PACK (mismo patrón que P179, P055, P050, P060, P080) |
| P174 | COBOL | 2.224 | 6.1.3 | Payments | Programa COBOL de dominio CAPTACION con 2,224 LOC |
| P161 | COBOL | 1.102 | 6.1.3 | Payments | Programa COBOL de dominio CAPTACION con 1,102 LOC |
| P179 | COBOL | 972 | 6.1.3 | Payments | Vocab confirma que P179 accede S500BD01CAPTACION mediante CCW ON PACK, mismo patrón que P176 y otros programas del clust |
| P185 | COBOL | 794 | 6.1.4 | Statements | P185 es un programa batch pequeño (794 LOC) que solo lee datos de captación (access=read) |
| P184 | COBOL | 782 | 6.1.4 | Statements | P184 comparte perfil exacto con P185 (782 vs 794 LOC, BL, CAPTACION, read) |
| L020 | INC | 146 | 6.1.4 | Statements | L020 es un INC de 146 LOC que define los buffers de interfaz entre el sistema S127 (Cheques) y S500 (Captación) |
| P320 | COBOL | 2.660 | 6.1.5 | Interest & Fees | Programa COBOL de dominio CONTROL con 2,660 LOC |
| P106 | COBOL | 2.700 | 6.5.2 | Compliance & Regulation | Programa COBOL de dominio CONTROL con 2,700 LOC |
| P105 | COBOL | 20.556 | 6.6.1 | Financial Servicing | No se encontraron menciones de P105 en el catálogo de reglas ni en vocab-s500 con evidencia directa de su función |
| P180 | COBOL | 10.076 | 6.6.1 | Financial Servicing | No se encontraron menciones de P180 en el catálogo de reglas ni en vocab-s500 |
| P120 | COBOL | 9.540 | 6.6.1 | Financial Servicing | No se encontraron menciones de P120 en el catálogo de reglas ni en vocab-s500 |
| P102 | COBOL | 9.456 | 6.6.1 | Financial Servicing | P102 no tiene menciones directas en el catálogo de reglas ni en vocab-s500 |
| P046 | COBOL | 102 | 6.6.1 | Financial Servicing | P046 es un programa batch muy pequeño (102 LOC) en CONTROL domain sin escrituras DMSII |
| P186 | COBOL | 10.800 | 6.7.2 | Operational Reconciliation | P186 no tiene menciones en el catálogo de reglas ni en vocab-s500 |
| P190 | COBOL | 3.344 | 6.7.2 | Operational Reconciliation | Programa COBOL de dominio CONTROL con 3,344 LOC |
| P055 | COBOL | 3.330 | 6.7.2 | Operational Reconciliation | Vocab confirma que P055 accede a S500BD01CAPTACION mediante la entidad DASDL 'CCW ON PACK' (miembro de SET del PACK de c |
| P200 | COBOL | 3.106 | 6.7.2 | Operational Reconciliation | Programa COBOL de dominio CONTROL con 3,106 LOC |
| P188 | COBOL | 2.616 | 6.7.2 | Operational Reconciliation | Programa COBOL de dominio CONTROL con 2,616 LOC |
| P430 | COBOL | 2.070 | 6.7.2 | Operational Reconciliation | Programa COBOL de dominio CONTROL con 2,070 LOC |
| P420 | COBOL | 1.966 | 6.7.2 | Operational Reconciliation | Programa COBOL de dominio CONTROL con 1,966 LOC |
| P101 | COBOL | 1.634 | 8.1.1 | Scheduling WFL | Programa COBOL de dominio CONTROL con 1,634 LOC |
| L070 ⚠️ NO-TRANSPILABLE | ALGOL | 706 | 9.1.1 | Operational Data Stores DMSII | L070 expone el entry point S127L070CONGLOBALES: consulta de parámetros globales del sistema S500 invocada desde S127 (si |

---

## Estadísticas globales

| Métrica | Valor |
|---------|-------|
| Total programas | 114 |
| Capacidades BIAN | 17 |
| LOC total | 898.596 |
| Confianza ALTA | 42 (36%) |
| Confianza MEDIA | 31 (27%) |
| Confianza BAJA | 41 (35%) |

### LOC por capacidad BIAN (ranking)

| # | BIAN ID | Capacidad | LOC Total | % del total |
|---|---------|-----------|-----------|------------|
| 1 | 2.1.1 | Teller | 258.400 | 28.8% |
| 2 | 6.1.3 | Payments | 116.530 | 13.0% |
| 3 | 9.1.1 | Operational Data Stores DMSII | 111.174 | 12.4% |
| 4 | 6.6.1 | Financial Servicing | 87.092 | 9.7% |
| 5 | 5.1.1 | Deposits | 84.980 | 9.5% |
| 6 | 6.7.2 | Operational Reconciliation | 84.910 | 9.4% |
| 7 | 6.1.5 | Interest & Fees | 52.260 | 5.8% |
| 8 | 10.1.1 | Access Control | 42.884 | 4.8% |
| 9 | 6.1.4 | Statements | 13.988 | 1.6% |
| 10 | 2.2.6 | ATM | 13.098 | 1.5% |
| 11 | T.1.3 | Payment Schemes SPEI/CLABE | 11.286 | 1.3% |
| 12 | 8.1.1 | Scheduling WFL | 9.276 | 1.0% |
| 13 | 6.7.1 | Financial Reconciliation | 4.204 | 0.5% |
| 14 | 6.5.2 | Compliance & Regulation | 3.364 | 0.4% |
| 15 | T.2.3 | MQ Async L091-L093 | 2.284 | 0.3% |
| 16 | T.3.5 | Security | 1.720 | 0.2% |
| 17 | 4.1.2 | Holdings | 1.146 | 0.1% |
