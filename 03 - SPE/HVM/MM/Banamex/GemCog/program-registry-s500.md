# Registro Canónico de Programas S500 — Gemelo Cognitivo Banamex
> Sistema: S500 · Cargos y Abonos de Cuentas de Cheque · Unisys ClearPath MCP/DMSII
> Creado: 2026-07-23 · **77 programas COBOL P-prefixed** · 14 capacidades BC-XX cubiertas
> Sustituye: `bian-mapping-s500.md` (archivado como `bian-mapping-s500-LEGACY.md`)
> **Tipo-artefacto:** `Catálogo-Programas`
> **Capa-GemCog:** `3`
> **Propósito:** Fuente de verdad única — mapeo de 77 programas COBOL S500 a identificadores canónicos BC-XX. BIAN es referencia, no clave primaria. No incluye: L-librerías ALGOL, WFLs, DASDL, INC (ver LEGACY para contexto completo de 114 artefactos).
> **Relacionado-con:** capability-model-taxonomy · capacidades/cap-*.md · bian-mapping-s500-LEGACY

---

## Resumen por BC-XX

| BC-ID | Capacidad (ES) | # Prog | LOC total | bian_ref |
|-------|----------------|--------|-----------|----------|
| BC-01 | Atención en Ventanilla | 3 | 98.264 | 2.1.1 Teller |
| BC-02 | Cajeros y PoS | 2 | 13.098 | 2.2.6 + 2.2.7 |
| BC-05 | Cuentas de Depósito | 19 | 84.980 | 5.1.1 Deposits |
| BC-05* | Cuentas de Depósito (6.6.1 integrada) | 8 | 87.092 | 6.6.1 Financial Servicing |
| BC-06 | Pagos e Interbancario | 9 | 116.530 | 6.1.3 Payments |
| BC-07 | Estados de Cuenta | 4 | 13.842 | 6.1.4 Statements |
| BC-08 | Intereses y Comisiones | 4 | 52.260 | 6.1.5 Interest & Fees |
| BC-10 | Cumplimiento Regulatorio | 2 | 3.364 | 6.5.2 Compliance |
| BC-11 | Reconciliación Financiera | 1 | 4.204 | 6.7.1 Financial Reconciliation |
| BC-12 | Reconciliación Operacional | 14 | 84.910 | 6.7.2 Operational Reconciliation |
| BC-14 | Programación Batch | 3 | 3.296 | 8.1.1 Scheduling |
| BC-15 | Almacén Operacional DMSII | 2 | 7.106 | 9.1.1 Operational Data Stores |
| BC-16 | Seguridad y Control de Acceso | 3 | 13.496 | 10.1.1 + T.3.5 |
| BC-17 | Mensajería Asíncrona MCP | 2 | 226 | T.2.3 MQ / Async |
| BC-23 | SPEI e Interfaces Banxico *(gap)* | 1 | 11.286 | T.1.3 Payment Schemes |
| **TOTAL** | | **77** | **594.954** | |

> **BC-05\***: los 8 programas de 6.6.1 Financial Servicing no tienen cap propio — integrados en BC-05 (cap-dep.md) hasta que se cree cap-fsr.md.
> **BC-03** (Portafolio del Cliente / 4.1.2 Holdings): sin programas COBOL P-prefix en S500; solo L019_SALDOS (ALGOL), excluido de este registro.

---

## Registro detallado — 77 programas ordenados por BC-XX, LOC descendente

| # | Programa | LOC | Dominio S500 | BC-ID | Capacidad (ES) | bian_ref | Rol funcional | Confianza | Validado por |
|---|----------|-----|--------------|-------|----------------|----------|---------------|-----------|--------------|
| 1 | P010 | 52.656 | CAPTACION | BC-01 | Atención en Ventanilla | 2.1.1 | Hub primario COMS — dispatcher online de todas las transacciones de captación | ALTA | Swarm RE |
| 2 | P010_PRO | 42.310 | CONTROL | BC-01 | Atención en Ventanilla | 2.1.1 | Variante COBOL de P010 para canal PRO — procesador transaccional de captación | MEDIA | Swarm RE |
| 3 | P280 | 3.298 | CONTROL | BC-01 | Atención en Ventanilla | 2.1.1 | Servidor COMS terciario (LINCOMS) — gateway online de transacciones de captación | ALTA | Swarm RE |
| 4 | P110 | 10.380 | CAPTACION | BC-02 | Cajeros y PoS | 2.2.6 | Procesador de tarjetas legadas — gestiona tarjetas migradas desde S501/P110 | MEDIA | Swarm RE |
| 5 | P630_TARINTERCAM | 2.718 | CONTROL | BC-02 | Cajeros y PoS | 2.2.6 | Gestión de tarjetas intercambiables migradas de S501 | ALTA | Swarm RE |
| 6 | P170 | 6.964 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch del ciclo de vida de cuentas de depósito | BAJA | Swarm RE |
| 7 | P191 | 6.130 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Operaciones sobre contratos de depósito en BD01CAPTACION | MEDIA | Swarm RE |
| 8 | P127 | 5.854 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — operaciones sobre cuentas de depósito | BAJA | Swarm RE |
| 9 | P109 | 5.690 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — ciclo de vida de cuentas de depósito | BAJA | Swarm RE |
| 10 | P290 | 5.318 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — operaciones especializadas sobre cuentas | BAJA | Swarm RE |
| 11 | P164 | 5.262 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Actualización de registros de cuenta en BD01CAPTACION | MEDIA | Swarm RE |
| 12 | P115 | 4.662 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — operaciones de cuenta de depósito | BAJA | Swarm RE |
| 13 | P107 | 4.562 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — operaciones sobre cuentas de depósito | BAJA | Swarm RE |
| 14 | P189 | 4.436 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Sync activo-activo VDM↔MTY (S084/S087) + STA-BENF Art. 61 LIC (CNBV) + propagación condicional B06 | ALTA | Mario SME S500 · 2026-07-22 |
| 15 | P117 | 4.330 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — ciclo de vida de contratos de depósito | BAJA | Swarm RE |
| 16 | P168 | 4.194 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — operaciones de ciclo de depósito | BAJA | Swarm RE |
| 17 | P315 | 4.134 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento de captación — operaciones especializadas en rango 3xx | BAJA | Swarm RE |
| 18 | P181 | 4.088 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — operaciones de depósito en ciclo nocturno | BAJA | Swarm RE |
| 19 | P187 | 3.762 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — operaciones de cuenta de depósito | BAJA | Swarm RE |
| 20 | P108 | 3.726 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch de captación — operaciones de depósito en ciclo nocturno | BAJA | Swarm RE |
| 21 | P050 | 3.668 | CONTROL | BC-05 | Cuentas de Depósito | 5.1.1 | Operaciones de captación / tesorería — gestión de cuentas de depósito | ALTA | Swarm RE |
| 22 | P199 | 3.662 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesamiento batch — cierre de operaciones 1xx en ciclo nocturno | BAJA | Swarm RE |
| 23 | P305 | 3.606 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Operaciones de captación especializada — cuentas de depósito en Bounded Context | ALTA | Swarm RE |
| 24 | P121 | 932 | CAPTACION | BC-05 | Cuentas de Depósito | 5.1.1 | Procesador batch de transacciones de cuentas de captación | MEDIA | Swarm RE |
| 25 | P105 | 20.556 | CAPTACION | BC-05* | Cuentas de Depósito (6.6.1) | 6.6.1 | Programa de servicios de captación — función específica pendiente de validación SME | BAJA | Pendiente SME |
| 26 | P015 | 17.734 | CAPTACION | BC-05* | Cuentas de Depósito (6.6.1) | 6.6.1 | DISPERSADOR de captación — routing online de transacciones COMS al inicio del ciclo | MEDIA | Swarm RE |
| 27 | P045 | 13.694 | CONTROL | BC-05* | Cuentas de Depósito (6.6.1) | 6.6.1 | Programa Teletón — captación en sucursales especiales (0519/1037/190x) | MEDIA | Swarm RE |
| 28 | P180 | 10.076 | CAPTACION | BC-05* | Cuentas de Depósito (6.6.1) | 6.6.1 | Programa de servicios de captación — función específica pendiente de validación SME | BAJA | Pendiente SME |
| 29 | P120 | 9.540 | CAPTACION | BC-05* | Cuentas de Depósito (6.6.1) | 6.6.1 | Programa de servicios de captación — función específica pendiente de validación SME | BAJA | Pendiente SME |
| 30 | P102 | 9.456 | CAPTACION | BC-05* | Cuentas de Depósito (6.6.1) | 6.6.1 | Programa auxiliar de captación — función adyacente a P103 (fraude/control) | BAJA | Pendiente SME |
| 31 | P005 | 5.334 | CAPTACION | BC-05* | Cuentas de Depósito (6.6.1) | 6.6.1 | Servicio transversal de fechas valor — validación días hábiles vía S006 | MEDIA | Swarm RE |
| 32 | P046 | 102 | CONTROL | BC-05* | Cuentas de Depósito (6.6.1) | 6.6.1 | Utilitario batch de control de revocación de operaciones | BAJA | Pendiente SME |
| 33 | P020 | 44.012 | CAPTACION | BC-06 | Pagos e Interbancario | 6.1.3 | Gateway COMS secundario — procesa CARGOS/ABONOS online con 5 copias paralelas | ALTA | Swarm RE |
| 34 | P142 | 29.138 | CAPTACION | BC-06 | Pagos e Interbancario | 6.1.3 | Batch captación-inversiones — extrae contratos BD07 a Teradata (CREDITOS CAN) | ALTA | Swarm RE |
| 35 | P144 | 28.994 | CAPTACION | BC-06 | Pagos e Interbancario | 6.1.3 | Batch reconciliación B01/B03 — genera activaciones masivas BIT-ACTBANDERA | ALTA | Swarm RE |
| 36 | P155 | 3.564 | CAPTACION | BC-06 | Pagos e Interbancario | 6.1.3 | Procesamiento batch de transacciones de captación (cargos/abonos) — rango 150 | BAJA | Swarm RE |
| 37 | P178 | 3.434 | CAPTACION | BC-06 | Pagos e Interbancario | 6.1.3 | Procesamiento batch de transacciones de captación — rango 170-180 | BAJA | Swarm RE |
| 38 | P176 | 3.090 | CAPTACION | BC-06 | Pagos e Interbancario | 6.1.3 | Procesamiento de cargos/abonos en BD01CAPTACION via CCW ON PACK — rango 176 | BAJA | Swarm RE |
| 39 | P174 | 2.224 | CAPTACION | BC-06 | Pagos e Interbancario | 6.1.3 | Procesamiento batch de transacciones de captación — rango 174 | BAJA | Swarm RE |
| 40 | P161 | 1.102 | CAPTACION | BC-06 | Pagos e Interbancario | 6.1.3 | Procesamiento batch de transacciones CAPTACION — rango 161 | BAJA | Swarm RE |
| 41 | P179 | 972 | CAPTACION | BC-06 | Pagos e Interbancario | 6.1.3 | Procesamiento CAPTACION con acceso BD01CAPTACION via CCW ON PACK | BAJA | Swarm RE |
| 42 | P335 | 10.198 | CAPTACION | BC-07 | Estados de Cuenta | 6.1.4 | Generador de estado de cuenta EDOCTA — produce extracto de movimientos y saldo | MEDIA | Swarm RE |
| 43 | P400 | 2.068 | CAPTACION | BC-07 | Estados de Cuenta | 6.1.4 | Generación de estados de cuenta (PID=P335-EDOCTA) | ALTA | Swarm RE |
| 44 | P185 | 794 | CAPTACION | BC-07 | Estados de Cuenta | 6.1.4 | Generador batch de extracto o reporte de cuentas de captación | BAJA | Swarm RE |
| 45 | P184 | 782 | CAPTACION | BC-07 | Estados de Cuenta | 6.1.4 | Generador batch de extracto o reporte de cuentas de captación | BAJA | Swarm RE |
| 46 | P130 | 31.762 | CAPTACION | BC-08 | Intereses y Comisiones | 6.1.5 | Motor de cierre de captación — calcula rendimientos, ISR, comisiones mensuales | ALTA | Swarm RE |
| 47 | P330 | 15.642 | CAPTACION | BC-08 | Intereses y Comisiones | 6.1.5 | Cálculos de productos especiales — rendimientos para inversiones a plazo | MEDIA | Swarm RE |
| 48 | P320 | 2.660 | CONTROL | BC-08 | Intereses y Comisiones | 6.1.5 | Control y cálculo de productos financieros especiales — adyacente a P330 | BAJA | Swarm RE |
| 49 | P310 | 2.196 | CAPTACION | BC-08 | Intereses y Comisiones | 6.1.5 | Cálculo de IVA/ISR y comisiones en proceso de captación — rango 310 | MEDIA | Swarm RE |
| 50 | P106 | 2.700 | CONTROL | BC-10 | Cumplimiento Regulatorio | 6.5.2 | Reporte o control regulatorio CNBV — proceso de control adyacente a FraudLink | BAJA | Swarm RE |
| 51 | P103 | 664 | CAPTACION | BC-10 | Cumplimiento Regulatorio | 6.5.2 | Generador del archivo FRAUDLINK para reporte regulatorio CNBV (S711) | ALTA | Swarm RE |
| 52 | P160 | 4.204 | CAPTACION | BC-11 | Reconciliación Financiera | 6.7.1 | Ajuste y conciliación de diferencias de saldo entre procesos de captación | ALTA | Swarm RE |
| 53 | P080 | 18.548 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Gestor de Cuenta Ordenante ONLINE — administra posición ordenante en transferencias | MEDIA | Swarm RE |
| 54 | P186 | 10.800 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Puente S500↔S274: dispatcher Cuenta Global Art. 61 LIC + tarifas IVA/UDIS + R01-CIFCTRL (gate CNBV) | ALTA | Mario SME S500 · 2026-07-22 |
| 55 | P104 | 9.022 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control operativo batch de mayor LOC en el dominio CONTROL | MEDIA | Swarm RE |
| 56 | P197 | 8.234 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control operativo batch — cuadratura y verificación de ciclo de captación | MEDIA | Swarm RE |
| 57 | P131 | 6.788 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control de proceso batch — validación de integridad operativa del lote | MEDIA | Swarm RE |
| 58 | P195 | 5.312 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control y cuadratura operativa del batch de captación | MEDIA | Swarm RE |
| 59 | P125 | 4.920 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control de proceso batch — verificación de integridad operativa | MEDIA | Swarm RE |
| 60 | P140 | 4.854 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control operativo batch — cuadratura de totales en el ciclo de captación | MEDIA | Swarm RE |
| 61 | P190 | 3.344 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control de lote — reconciliación y validación operativa de proceso nocturno | BAJA | Swarm RE |
| 62 | P055 | 3.330 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control batch CAPTACION — validación de proceso con acceso BD01CAPTACION | BAJA | Swarm RE |
| 63 | P200 | 3.106 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control de lote — reconciliación operativa de proceso nocturno rango 200 | BAJA | Swarm RE |
| 64 | P188 | 2.616 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control de lote — reconciliación operativa de proceso nocturno rango 188 | BAJA | Swarm RE |
| 65 | P430 | 2.070 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control de lote — proceso de reconciliación operativa rango 430 | BAJA | Swarm RE |
| 66 | P420 | 1.966 | CONTROL | BC-12 | Reconciliación Operacional | 6.7.2 | Control de lote — proceso de control adyacente a generación de extractos | BAJA | Swarm RE |
| 67 | P101 | 1.634 | CONTROL | BC-14 | Programación Batch | 8.1.1 | Control de proceso batch — companion de P100 (fecha/período) | BAJA | Swarm RE |
| 68 | P100 | 1.186 | CONTROL | BC-14 | Programación Batch | 8.1.1 | Control de fecha/período del proceso batch — validación y gestión del día | ALTA | Swarm RE |
| 69 | P075 | 476 | CONTROL | BC-14 | Programación Batch | 8.1.1 | Utilitario batch de Cambio-de-Día — control de límite de ciclo EOD | MEDIA | Swarm RE |
| 70 | P038 | 5.796 | CONTROL | BC-15 | Almacén Operacional DMSII | 9.1.1 | Reorganización de bases de datos DMSII — mantenimiento físico de S500BD01CAPT | ALTA | Swarm RE |
| 71 | P629_CARGABD06 | 1.310 | CONTROL | BC-15 | Almacén Operacional DMSII | 9.1.1 | Carga de datos al esquema BD06 (Teletón) — inserción a S500BD06TELETON | ALTA | Swarm RE |
| 72 | P010_PAR | 11.018 | CONTROL | BC-16 | Seguridad y Control de Acceso | 10.1.1 | Variante de parámetros/paralelo de P010 — gestiona configuración de acceso online | BAJA | Swarm RE |
| 73 | P060 | 758 | CONTROL | BC-16 | Seguridad y Control de Acceso | 10.1.1 | Módulo online de control de acceso y verificación de estado de cuentas | MEDIA | Swarm RE |
| 74 | P655_SCRAMBLING | 1.720 | CONTROL | BC-16 | Seguridad y Control de Acceso | T.3.5 | Enmascaramiento (scrambling) de PAN y número de cuenta — activo solo en PROD | ALTA | Swarm RE |
| 75 | P093_ASINCRONO | 114 | CONTROL | BC-17 | Mensajería Asíncrona MCP | T.2.3 | Módulo de procesamiento asíncrono batch para cancelaciones y operaciones | ALTA | Swarm RE |
| 76 | P091 | 112 | CONTROL | BC-17 | Mensajería Asíncrona MCP | T.2.3 | Módulo online de procesamiento asíncrono — gestión de operaciones no bloqueantes | ALTA | Swarm RE |
| 77 | P165 | 11.286 | CAPTACION | BC-23 | SPEI e Interfaces Banxico | T.1.3 | Procesador de resultados de dispersión — procesa output batch de dispersión masiva | MEDIA | Swarm RE |

---

## Programas con validación SME confirmada

| Programa | BC-ID | Validado por | Fecha | Notas |
|----------|-------|--------------|-------|-------|
| P189 | BC-05 | Mario SME S500 | 2026-07-22 | STA-BENF Art. 61 LIC + sync VDM↔MTY; confianza elevada de BAJA → ALTA |
| P186 | BC-12 | Mario SME S500 | 2026-07-22 | Movido de BC-08/INT a BC-12/ORC; R01-CIFCTRL gate regulatorio CNBV |

---

## Programas que requieren validación SME (confianza BAJA)

| # | Programa | LOC | BC-ID | Capacidad | Justificación de baja confianza |
|---|----------|-----|-------|-----------|----------------------------------|
| 1 | P010_PAR | 11.018 | BC-16 | Seguridad | P010_PAR combina prefijo P010 (gateway captación) con sufijo _PAR |
| 2 | P170 | 6.964 | BC-05 | Depósito | COBOL 6,964 LOC en CAPTACION — función exacta no determinada |
| 3 | P127 | 5.854 | BC-05 | Depósito | COBOL 5,854 LOC en CAPTACION — función exacta no determinada |
| 4 | P109 | 5.690 | BC-05 | Depósito | COBOL 5,690 LOC en CAPTACION — función exacta no determinada |
| 5 | P290 | 5.318 | BC-05 | Depósito | COBOL 5,318 LOC en CAPTACION rango 2xx |
| 6 | P115 | 4.662 | BC-05 | Depósito | COBOL 4,662 LOC en CAPTACION |
| 7 | P107 | 4.562 | BC-05 | Depósito | COBOL 4,562 LOC en CAPTACION |
| 8 | P117 | 4.330 | BC-05 | Depósito | COBOL 4,330 LOC en CAPTACION |
| 9 | P168 | 4.194 | BC-05 | Depósito | COBOL 4,194 LOC en CAPTACION |
| 10 | P315 | 4.134 | BC-05 | Depósito | COBOL 4,134 LOC en CAPTACION rango 3xx |
| 11 | P181 | 4.088 | BC-05 | Depósito | COBOL 4,088 LOC en CAPTACION |
| 12 | P187 | 3.762 | BC-05 | Depósito | COBOL 3,762 LOC en CAPTACION |
| 13 | P108 | 3.726 | BC-05 | Depósito | COBOL 3,726 LOC en CAPTACION |
| 14 | P199 | 3.662 | BC-05 | Depósito | Cierre de operaciones 1xx en ciclo nocturno |
| 15 | P155 | 3.564 | BC-06 | Pagos | COBOL 3,564 LOC en CAPTACION rango 150 |
| 16 | P178 | 3.434 | BC-06 | Pagos | COBOL 3,434 LOC en CAPTACION rango 170-180 |
| 17 | P176 | 3.090 | BC-06 | Pagos | Accede BD01CAPTACION via CCW ON PACK |
| 18 | P174 | 2.224 | BC-06 | Pagos | COBOL 2,224 LOC en CAPTACION rango 174 |
| 19 | P161 | 1.102 | BC-06 | Pagos | COBOL 1,102 LOC en CAPTACION rango 161 |
| 20 | P179 | 972 | BC-06 | Pagos | BD01CAPTACION via CCW ON PACK |
| 21 | P185 | 794 | BC-07 | Estados de Cuenta | Batch pequeño (794 LOC) — solo lectura de datos de captación |
| 22 | P184 | 782 | BC-07 | Estados de Cuenta | Perfil exacto igual a P185 |
| 23 | P320 | 2.660 | BC-08 | Intereses | CONTROL 2,660 LOC adyacente a P330 |
| 24 | P106 | 2.700 | BC-10 | Cumplimiento | CONTROL 2,700 LOC adyacente a FraudLink |
| 25 | P105 | 20.556 | BC-05* | Serv. Financiero | Sin menciones en catálogo de reglas — **Pendiente validación SME** |
| 26 | P180 | 10.076 | BC-05* | Serv. Financiero | Sin menciones en catálogo de reglas — **Pendiente validación SME** |
| 27 | P120 | 9.540 | BC-05* | Serv. Financiero | Sin menciones en catálogo de reglas — **Pendiente validación SME** |
| 28 | P102 | 9.456 | BC-05* | Serv. Financiero | Función adyacente a P103 — **Pendiente validación SME** |
| 29 | P046 | 102 | BC-05* | Serv. Financiero | Utilitario batch muy pequeño (102 LOC) — **Pendiente validación SME** |
| 30 | P186 | 10.800 | BC-12 | ORC | **Resuelto 2026-07-22: Mario SME S500 confirmó BC-12 (ORC)** |
| 31 | P190 | 3.344 | BC-12 | ORC | CONTROL 3,344 LOC |
| 32 | P055 | 3.330 | BC-12 | ORC | Accede BD01CAPTACION via CCW ON PACK |
| 33 | P200 | 3.106 | BC-12 | ORC | CONTROL 3,106 LOC rango 200 |
| 34 | P188 | 2.616 | BC-12 | ORC | CONTROL 2,616 LOC rango 188 |
| 35 | P430 | 2.070 | BC-12 | ORC | CONTROL 2,070 LOC rango 430 |
| 36 | P420 | 1.966 | BC-12 | ORC | Adyacente a generación de extractos (P400) |
| 37 | P101 | 1.634 | BC-14 | Batch | CONTROL 1,634 LOC adyacente a P100 |

---

## LOC por BC-XX (ranking)

| # | BC-ID | Capacidad (ES) | LOC total | % |
|---|-------|----------------|-----------|---|
| 1 | BC-06 | Pagos e Interbancario | 116.530 | 19.6% |
| 2 | BC-05* | Serv. Financiero (6.6.1 integrada) | 87.092 | 14.6% |
| 3 | BC-05 | Cuentas de Depósito | 84.980 | 14.3% |
| 4 | BC-12 | Reconciliación Operacional | 84.910 | 14.3% |
| 5 | BC-01 | Atención en Ventanilla | 98.264 | 16.5% |
| 6 | BC-08 | Intereses y Comisiones | 52.260 | 8.8% |
| 7 | BC-16 | Seguridad y Control de Acceso | 13.496 | 2.3% |
| 8 | BC-07 | Estados de Cuenta | 13.842 | 2.3% |
| 9 | BC-23 | SPEI e Interfaces Banxico | 11.286 | 1.9% |
| 10 | BC-02 | Cajeros y PoS | 13.098 | 2.2% |
| 11 | BC-15 | Almacén Operacional DMSII | 7.106 | 1.2% |
| 12 | BC-11 | Reconciliación Financiera | 4.204 | 0.7% |
| 13 | BC-10 | Cumplimiento Regulatorio | 3.364 | 0.6% |
| 14 | BC-14 | Programación Batch | 3.296 | 0.6% |
| 15 | BC-17 | Mensajería Asíncrona MCP | 226 | 0.04% |

---

## Artefactos excluidos (no COBOL P-prefix) — referencia en LEGACY

> Completo en `bian-mapping-s500-LEGACY.md`. Resumen:

| Tipo | Cantidad | Ejemplos |
|------|----------|---------|
| INC / COPY | 11 | PRO, WOR, P010_MAS, L020, MAPLI_WOR, COPY_ADMWIN |
| ALGOL L-libs | 15 | L010_CONTROL, L019_SALDOS, L039_ACCESOBD04, L050, L091_ASINCRONA |
| WFL | 4 | LOTE, LINEA, REORG_GARBAGE_S500BD04TARJETAS, REORG_GARBAGE_S500BD01CAPTACION |
| DASDL | 7 | CAPTACION, TARJETAS, AUXILIAR, TELETON, MAPLI, ATRIBUCTA, MSGAAPLI |
| **Total excluidos** | **37** | |

---

*Generado: 2026-07-23 · v1.0 · Opción A — modelo canónico BC-XX. Sustituye bian-mapping-s500.md (LEGACY).*
*Cross-referencia: `capability-model-taxonomy.md` § Catálogo Canónico BC-XX · `capacidades/cap-*.md` headers.*
