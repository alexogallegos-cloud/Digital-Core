# Knowledge Base — S500 Cargos & Abonos + S151 Movimientos Contables GL
> Indexado: ✅ 2026-07-17 — Knowledge Base consolidada S500+S151
## Banamex · Unisys ClearPath MCP · Fase DISCOVER

**Generado:** 2026-07-11  
**Fuente canónica:** Source extraído de producción MCP  
**Scope:** 114 archivos S500 + 105 archivos S151 = 219 archivos totales  
**Propósito:** Fuente de verdad para análisis de modernización mainframe. Alimenta portales HTML de análisis.  
**Paths de source:**  
- S500: `Banamex/S500/source/S500/extracted_source/`  
- S151: `Banamex/S151/source/S151/`

---

## RESUMEN EJECUTIVO

| Métrica | S500 | S151 | Total |
|---------|------|------|-------|
| Archivos totales | 114 | 105 | 219 |
| Programas COBOL | 65 | 79 | 144 |
| Programas ALGOL | 15 | 16 | 31 |
| Bases de datos DMSII | 7 | 6 | 13 |
| WFL jobs | 4 | 3 | 7 |
| Includes / copybooks | 11 | 0 | 11 |
| LOC totales (aprox.) | 296,677 | 444,992 | 741,669 |
| Programas ONLINE | ~12 | ~22 | ~34 |
| Programas BATCH | ~53 | ~57 | ~110 |
| Librerías (LIBRARY) | ~15 | ~11 | ~26 |
| Flag CNBV confirmado | Sí (P130, schemas) | Sí (L002, L011) | — |
| Integración cross-system S500→S151 | S151REGISTRA usado en P130, P142, P144 | — | — |
| Versión MTP activa S500 | 24MTP005 (LINEA) / 25MTP003 (REORG) | 25MTP003 (LOTE) / 25MTP003 (LINEA) | — |

**Sistemas externos referenciados por S500:** S000 (utilidades), S006 (LOCSUP/calendarios), S016 (ACCESOBD2K), S050 (saldos), S080 (operaciones/UDIS/tarifas), S100 (versiones), S408 (crédito), S711 (FraudLink/CNBV)  
**Sistemas externos referenciados por S151:** C402, C600, S804 (plataformas host), S707, S203 (Tandem), S028, S115, S264, S084, S151BD* (propio)

---

## ADVERTENCIAS DE FUENTE — ANOMALÍAS DETECTADAS

> CRÍTICO: Leer antes de usar cualquier dato del catálogo.

### ANO-001: WFL S500 con nombres cruzados (swap de archivos)
- `S500_WFL_LOTE.txt` (1,960 LOC) **contiene contenido LINEA**: `BEGIN JOB S500/WFL/LINEA/24MTP005`
- `S500_WFL_LINEA.txt` (49 LOC) **contiene contenido REORG/GARBAGE**: `BEGIN JOB S500/WFL/REORG/GARBAGE/S500BD01CAPTACION/25MTP003` — idéntico a `S500_WFL_REORG_GARBAGE_S500BD01CAPTACION.txt`
- **Consecuencia:** El WFL real de BATCH para S500 NO está en el extracted_source. La clasificación ONLINE de los programas S500 se infirió del archivo mal nombrado `S500_WFL_LOTE.txt`.

### ANO-002: PROGRAM-ID cruzados entre P335 y P400
- `S500_SOURCE_P335.txt` declara `PROGRAM-ID. S500P400.` → El programa compilado como P335 tiene PID de P400
- `S500_SOURCE_P400.txt` declara `PROGRAM-ID. P335-EDOCTA.` → El estado de cuenta (P400) tiene PID de P335
- **Consecuencia:** Los objetos MCP compilados están cruzados. En producción `S500/OBJECT/P335` contiene el ejecutable de P400 y viceversa.

### ANO-003: PROGRAM-ID duplicado — tres programas declaran LINCOMS
- `S500_SOURCE_P010.txt`: `PROGRAM-ID. LINCOMS.` (26,328 LOC — servidor principal de comunicaciones online)
- `S500_SOURCE_P020.txt`: `PROGRAM-ID. LINCOMS.` (22,006 LOC — servidor secundario)
- `S500_SOURCE_P280.txt`: `PROGRAM-ID. LINCOMS.` (1,649 LOC — servidor terciario)
- **Consecuencia:** Son tres programas distintos que posiblemente se cargan como instancias del mismo tipo de servidor COMS. El PID es el nombre del tipo de servidor, no del objeto individual.

### ANO-004: PROGRAM-ID duplicado — P155 y P160 ambos COMPARATIVO
- `S500_SOURCE_P155.txt`: `PROGRAM-ID. COMPARATIVO.`
- `S500_SOURCE_P160.txt`: `PROGRAM-ID. COMPARATIVO.`
- **Consecuencia:** Programas distintos con mismo PID. Verificar en producción cuál objeto es vigente.

### ANO-005: PROGRAM-ID placeholder — P104 es un template
- `S500_SOURCE_P104.txt`: `PROGRAM-ID. S500PXXX.` — PID con XXX como placeholder
- **Consecuencia:** Este archivo puede ser una plantilla de desarrollo o un programa inactivo.

### ANO-006: Archivos binarios detectados — P170 (S500) y P315 (S500)
- `S500_SOURCE_P170.txt` (3,482 LOC): grep detecta como binario — posiblemente source EBCDIC sin conversión completa
- `S500_SOURCE_P315.txt` (2,067 LOC): igual condición
- **Consecuencia:** Contenido no legible como texto ASCII. Requiere conversión de página de código EBCDIC→ASCII específica de MCP.

### ANO-007: Filename con espacio — COBOL_P138 en S151
- El archivo S151 se llama `COBOL_P138 .txt` (espacio antes del punto) — anomalía en extracción
- **Consecuencia:** Herramientas de procesamiento automático pueden fallar al acceder este archivo. Renombrar a `COBOL_P138.txt`.

### ANO-008: WFL S151 correctos — sin anomalías de nombres
- `WFL_LOTE.txt` (7,738 LOC): Contenido BATCH genuino — `BEGIN JOB S151/WFL/LOTE/25MTP003`
- `WFL_LINEA.txt` (1,546 LOC): Contenido LINEA genuino — `BEGIN JOB S151/WFL/LINEA/25MTP003`

### ANO-009: Código CRONOS 2000 (Y2K) presente en múltiples programas
- Patrón `$SET OLDCODE`, `a2k_base_year`, `A2K-SYSTEM-FECHA`, secciones `%INICIA CODIGO DE RENOVACION CRONOS 2000`
- Presente en: S151/ALGOL_L011, ALGOL_L002R*, COBOL_P167, P177, P195, P197 y varios S500
- **Consecuencia:** Código de parche Y2K de año 2000 que puede interferir con lógica de fechas moderna.

### ANO-010: Colisión de PROGRAM-ID en S151 — P010 y P053 ambos LINEA
- `COBOL_P010.txt`: `PROGRAM-ID. LINEA.` — Servidor COMS principal ONLINE
- `COBOL_P053.txt`: `PROGRAM-ID. LINEA.` — Misma situación que S500 con servidores múltiples
- **Consecuencia:** Verificar en producción si son instancias del mismo servidor o programas distintos mal nombrados.

---

## S500 — CATÁLOGO DE PROGRAMAS

> Sistema: Cargos y Abonos (Captación Bancaria)  
> Plataforma: Unisys ClearPath MCP  
> Base de datos principal: DMSII S500BD01CAPTACION

### Bases de Datos DMSII

| Archivo | Base de Datos DMSII | LOC | Descripción | Flags |
|---------|---------------------|-----|-------------|-------|
| S500_DASDL_CAPTACION.txt | S500BD01CAPTACION | 4,168 | BD principal de captación: cuentas de ahorro, cheques, depósitos. BD maestra del sistema. | CNBV |
| S500_DASDL_AUXILIAR.txt | S500BD02AUXILIAR | 931 | BD auxiliar de proceso batch. Tablas de trabajo y staging. | CNBV |
| S500_DASDL_MSGAAPLI.txt | S500BD03MSGAAPLI | 219 | BD de mensajes inter-aplicación (ventana de 24h). Coordinación entre módulos. | — |
| S500_DASDL_TARJETAS.txt | S500BD04TARJETAS | 1,346 | BD de pre-registro de tarjetas. Información de tarjetas de débito asociadas a cuentas. | — |
| S500_DASDL_MAPLI.txt | S500BD05MAPLI | 323 | BD de mapeo librería-aplicación. Control de qué librerías están activas por aplicación. | — |
| S500_DASDL_TELETON.txt | S500BD06TELETON | 355 | BD de registro del proceso Teletons (donaciones especiales). | — |
| S500_DASDL_ATRIBUCTA.txt | S500BD07ATRIBUCTAS | 272 | BD de calificación de atributos de cuenta. | — |

### WFL Jobs

| Archivo | Contenido Real | LOC | Descripción | Anomalía |
|---------|----------------|-----|-------------|---------|
| S500_WFL_LOTE.txt | LINEA (24MTP005) | 1,960 | **ANO-001:** Contiene el WFL ONLINE S500/WFL/LINEA/24MTP005. Inicia servidores COMS: P010, P014, P015, P020, P038, P050, P060, P080, P091, P093. | Nombre incorrecto |
| S500_WFL_LINEA.txt | REORG/GARBAGE | 49 | **ANO-001:** Contiene WFL de reorganización de BD01CAPTACION. Duplicado de S500_WFL_REORG_GARBAGE_S500BD01CAPTACION.txt | Nombre incorrecto |
| S500_WFL_REORG_GARBAGE_S500BD01CAPTACION.txt | REORG BD01 | 46 | Reorganización / garbage collection de S500BD01CAPTACION. | — |
| S500_WFL_REORG_GARBAGE_S500BD04TARJETAS.txt | REORG BD04 | 15,067 | Reorganización / garbage collection de S500BD04TARJETAS. Archivo muy grande (muchos steps). | — |

### Includes y Copybooks

| Archivo | Tipo | LOC | Descripción |
|---------|------|-----|-------------|
| S500_INC_L010.txt | INCLUDE | 1,621 | Include de definiciones para biblioteca L010 (Control) |
| S500_INC_L020.txt | INCLUDE | 73 | Include para biblioteca L020 |
| S500_INC_MAPLI_PRO.txt | INCLUDE | 116 | Definiciones MAPLI para entorno de producción |
| S500_INC_MAPLI_WOR.txt | INCLUDE | 196 | Definiciones MAPLI para entorno de workspace |
| S500_INC_P010_MAS.txt | INCLUDE | 11,891 | Include maestro del servidor P010. Contiene definiciones de todas las pantallas y transacciones online principales. |
| S500_INC_PRO.txt | INCLUDE | 21,748 | Include de producción principal. Shared por múltiples programas batch. |
| S500_INC_PRO_CAN.txt | INCLUDE | 20,446 | Include de producción — cancelaciones. |
| S500_INC_WOR.txt | INCLUDE | 11,990 | Include de workspace (entorno de desarrollo). |
| S500_INC_WOR_CAN.txt | INCLUDE | 9,277 | Include de workspace — cancelaciones. |
| S500_INC_WOR_DAS.txt | INCLUDE | 4,644 | Include de workspace — definiciones DASDL. |
| S500_SOURCE_COPY_ADMWIN.txt | COBOL COPY | 127 | Copybook ADMWIN — Windows de administración online. |

### Librerías (LIBRARY)

| Archivo | Lenguaje | PROGRAM-ID | LOC | Modo | Descripción | Deps |
|---------|----------|-----------|-----|------|-------------|------|
| S500_SOURCE_L010_CONTROL.txt | COBOL | (no PID — incluye-library) | 13,806 | LIBRARY | Librería de control principal del sistema online S500. Gestiona ciclo de vida de transacciones, errores y logging. La más crítica del sistema. | S500BD01CAPTACION, S500BD05MAPLI |
| S500_SOURCE_L019_SALDOS.txt | ALGOL | (ALGOL-BEGIN) | 573 | LIBRARY | Librería de consulta de saldos de cuentas. | S500BD01CAPTACION |
| S500_SOURCE_L030_TIEMPOS.txt | COBOL | (no PID) | 981 | LIBRARY | Librería de gestión de tiempos y control de sesiones. | — |
| S500_SOURCE_L035_MAPLI.txt | COBOL | (no PID) | 5,401 | LIBRARY | Librería MAPLI — mapeo de aplicaciones activas. Administra qué módulos están disponibles en línea. | S500BD05MAPLI |
| S500_SOURCE_L039_ACCESOBD04.txt | ALGOL | (ALGOL-BEGIN) | 11,747 | LIBRARY | Librería de acceso a BD04TARJETAS. Interfaz DMSII para operaciones de tarjetas. | S500BD04TARJETAS |
| S500_SOURCE_L040_LIGAS.txt | ALGOL | (ALGOL-BEGIN) | 371 | LIBRARY | Librería LIGAS — gestión de vínculos entre cuentas. | S500BD01CAPTACION |
| S500_SOURCE_L045_TELETON.txt | ALGOL | (ALGOL-BEGIN) | 72 | LIBRARY | Librería Teleton — manejo de proceso de donaciones especiales. | S500BD06TELETON |
| S500_SOURCE_L046_REVOCA.txt | ALGOL | (ALGOL-BEGIN) | 300 | LIBRARY | Librería de revocación de operaciones. | — |
| S500_SOURCE_L050.txt | ALGOL | (ALGOL-BEGIN) | 6,400 | LIBRARY | Librería de utilidades generales del sistema S500. | — |
| S500_SOURCE_L060_CONSULFOR.txt | ALGOL | (ALGOL-BEGIN) | 252 | LIBRARY | Librería de consulta de formatos — definiciones de pantallas/mensajes. | — |
| S500_SOURCE_L070.txt | ALGOL | (ALGOL-BEGIN) | 353 | LIBRARY | Librería de utilidades 70. | — |
| S500_SOURCE_L080.txt | ALGOL | (ALGOL-BEGIN) | 1,671 | LIBRARY | Librería de utilidades 80 — usada por P075 para notificación de cambio de día. | — |
| S500_SOURCE_L081.txt | ALGOL | (ALGOL-BEGIN) | 2,800 | LIBRARY | Librería de utilidades 81. | — |
| S500_SOURCE_L091_ASINCRONA.txt | ALGOL | (ALGOL-BEGIN) | 514 | LIBRARY | Librería de comunicaciones asíncronas 91. Soporte para P091. | — |
| S500_SOURCE_L093_ASINCRONA.txt | ALGOL | (ALGOL-BEGIN) | 515 | LIBRARY | Librería de comunicaciones asíncronas 93. Soporte para P093. | — |

### Programas ONLINE

| Archivo | Lenguaje | PROGRAM-ID | LOC | Descripción | Flags | DMSII | Deps |
|---------|----------|-----------|-----|-------------|-------|-------|------|
| S500_SOURCE_P010.txt | COBOL | LINCOMS | 26,328 | **Servidor COMS principal.** Gestiona todas las transacciones del sistema de captación en línea. Punto de entrada de usuarios. Mayor programa del sistema por LOC. | CNBV | S500BD01CAPTACION, BD02, BD05 | S006LOCSUP, S000LIBFEC, IBM-CHARITY |
| S500_SOURCE_P010_PAR.txt | COBOL | (partial include) | 5,509 | Módulo de parámetros del servidor P010. Definiciones de parámetros de configuración. | — | — | P010 |
| S500_SOURCE_P010_PRO.txt | COBOL | (process module) | 21,155 | Módulo de proceso del servidor P010. Lógica de negocio de transacciones online. | CNBV | S500BD01CAPTACION | P010 |
| S500_SOURCE_P015.txt | COBOL | DISPERSADOR | 8,867 | **Dispersador de operaciones online.** Distribuye transacciones entrantes a los módulos correspondientes. Punto de routing del sistema COMS. | — | S500BD01CAPTACION | L010, L035 |
| S500_SOURCE_P020.txt | COBOL | LINCOMS | 22,006 | **Servidor COMS secundario.** Segunda instancia del servidor de comunicaciones. Ver ANO-003. | CNBV | S500BD01CAPTACION, BD02 | — |
| S500_SOURCE_P038.txt | COBOL | S500P038 | 2,898 | **Monitor de aplicaciones (CONSULTOR).** Acceso a librería MAPLI para monitoreo del estado de aplicaciones en línea. | — | S500BD05MAPLI | L035 |
| S500_SOURCE_P045.txt | COBOL | S500P045 | 6,847 | **Proceso de donaciones Teleton.** Gestiona cuentas de sucursales especiales 0519, 1037, 1905, 4899 para proceso de donaciones Teleton. | — | S500BD06TELETON | L045 |
| S500_SOURCE_P046.txt | ALGOL | (ALGOL-BEGIN/COMS stub) | 51 | **Stub ONLINE — envío de cancelaciones.** ALGOL: ENABLE(COMSINHDR,"ONLINE"). Llama a procedimiento ENVIA_CANCELACIONES vía librería CTLVER. | — | — | CTLVER, TIME_OUT |
| S500_SOURCE_P050.txt | COBOL | P050LIN | 1,834 | **Activa Medios (ONLINE).** Gestión online de activación de medios de pago. Sufijo LIN = LINEA. | — | S500BD01CAPTACION | L010 |
| S500_SOURCE_P055.txt | COBOL | P055LIN | 1,665 | **Proceso ONLINE 55.** Sufijo LIN confirma modo ONLINE. | — | S500BD01CAPTACION | L010 |
| S500_SOURCE_P060.txt | COBOL | (no PID en primeras líneas) | 379 | **Servidor ECO Transit / TransIT Open.** Gestiona integración con sistema TransIT OLTP para operaciones de captación. | — | — | TransIT |
| S500_SOURCE_P075.txt | COBOL | P075 | 238 | **Notificación de cambio de día.** Envía notificación de cambio de día al P080 a través de librería L080. Proceso de fin de día. | — | — | L080 |
| S500_SOURCE_P080.txt | COBOL | S500P080 | 9,274 | **Gestor de Cuenta Ordenante (ONLINE).** Administra la cuenta ordenante en operaciones de transferencia en línea. | CNBV | S500BD01CAPTACION, BD02 | S080 |
| S500_SOURCE_P091.txt | ALGOL | (ALGOL-BEGIN/COMS) | 56 | **Módulo asíncrono 91.** ALGOL: INPUTHEADER/OUTPUTHEADER COMS. ENABLE(COMSINHDR,"ONLINE"). Llama ENVIA_CANCELACIONES e INICIA. | — | — | CTLVER, SHELL, L091 |
| S500_SOURCE_P093_ASINCRONO.txt | ALGOL | (ALGOL-BEGIN) | 57 | **Módulo asíncrono 93.** Paralelo a P091. Manejo asíncrono de operaciones de cancelación. | — | — | L093 |
| S500_SOURCE_P280.txt | COBOL | LINCOMS | 1,649 | **Servidor COMS terciario.** Tercera instancia del servidor LINCOMS. Ver ANO-003. | — | S500BD01CAPTACION | — |

### Programas BATCH

| Archivo | Lenguaje | PROGRAM-ID | LOC | Descripción | Flags | DMSII | Cross-System |
|---------|----------|-----------|-----|-------------|-------|-------|-------------|
| S500_SOURCE_P005.txt | COBOL | P005 | 2,667 | **Proceso inicial S500.** IBM-CHARITY marcado. Referencias a archivos FILE-DEPTEM, FILE-DEPURADOS, FILE-CONSULTA. Usa S006LOCSUP (calendario), S000LIBFEC (fechas). | — | S500BD01CAPTACION | S006, S000 |
| S500_SOURCE_P100.txt | COBOL | FECHA-DE-PROCESO | 593 | **Obtención y validación de fecha de proceso.** Lee registro de control de fechas y valida integridad. Programa de inicialización de fecha para proceso batch. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P101.txt | COBOL | P101 | 817 | Proceso batch 101. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P102.txt | COBOL | P102 | 4,728 | Manejo de include para base de datos. | — | S500BD01CAPTACION, BD02 | — |
| S500_SOURCE_P103.txt | COBOL | P103 | 332 | **FraudLink — Generación de archivo para S711.** Genera archivo de movimientos con clave 2001, 2444, 2496 desde S500B07MOVDIA y S500B13MOVCVES para el sistema S711 (FraudLink regulatorio). | S711, CNBV | S500BD01CAPTACION | S711 |
| S500_SOURCE_P104.txt | COBOL | S500PXXX | 4,511 | **TEMPLATE/PLACEHOLDER.** PID=S500PXXX indica plantilla de desarrollo. Ver ANO-005. | — | — | — |
| S500_SOURCE_P105.txt | COBOL | S500P105 | 10,278 | Proceso batch 105. Gran programa (~10K LOC). | CNBV | S500BD01CAPTACION, BD02 | — |
| S500_SOURCE_P106.txt | COBOL | MOD-ARCH | 1,350 | **Modificación de archivos.** Programa de mantenimiento de archivos del sistema. | — | — | — |
| S500_SOURCE_P107.txt | COBOL | P107 | 2,281 | Proceso batch 107. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P108.txt | COBOL | P108 | 1,863 | Proceso batch 108. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P109.txt | COBOL | P109 | 2,845 | Proceso batch 109. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P110.txt | COBOL | S500P110 | 5,190 | Proceso batch 110. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P115.txt | COBOL | P115 | 2,331 | Proceso batch 115. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P117.txt | COBOL | P117 | 2,165 | Proceso batch 117. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P120.txt | COBOL | P120 | 4,770 | Proceso batch 120. | — | S500BD01CAPTACION, BD02 | — |
| S500_SOURCE_P121.txt | COBOL | ACTB03 | 466 | **Actualización ACTB03.** Proceso de actualización batch. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P125.txt | COBOL | P125 | 2,460 | Proceso batch 125. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P127.txt | COBOL | P127 | 2,927 | Proceso batch 127. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P130.txt | COBOL | P130 | 15,881 | **Proceso batch principal — integración GL.** Mayor programa batch de S500 (15K+ LOC). Autor: José Luis Ibarra Lara (Jun/1995). Usa $SET S151REGISTRA y S151REGISTRA2 para postear asientos al S151. Accede S500BD01CAPTACION, BD02 y múltiples sets. IBM-CHARITY marcado. | CNBV | S500BD01CAPTACION, BD02 | S151REGISTRA, S151REGISTRA2 (→S151 GL) |
| S500_SOURCE_P131.txt | COBOL | S500P131 | 3,394 | Proceso batch 131. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P140.txt | COBOL | S500BATCH | 2,427 | **Monitor de aplicaciones en modo BATCH.** Código de "EN BATCH S038". Sistema de monitoreo de aplicaciones ejecutado en proceso nocturno. | — | S500BD05MAPLI | — |
| S500_SOURCE_P142.txt | COBOL | P142 | 14,569 | **Proceso batch de crédito-captación.** Gran programa (~14K LOC). Usa S151REGISTRA (→GL). Referencias a S408 (crédito), S016 (ACCESOBD2K), S050 (cobcom/saldos). | CNBV | S500BD01CAPTACION, BD02 | S151REGISTRA (→S151), S408, S016, S050 |
| S500_SOURCE_P144.txt | COBOL | P144 | 14,497 | **Proceso batch de crédito-captación 2.** Gemelo de P142 (~14K LOC). Usa S151REGISTRA (→GL). | CNBV | S500BD01CAPTACION, BD02 | S151REGISTRA (→S151), S408 |
| S500_SOURCE_P155.txt | COBOL | COMPARATIVO | 1,782 | **Comparativo de balances.** PID=COMPARATIVO — duplicado con P160. Ver ANO-004. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P160.txt | COBOL | COMPARATIVO | 2,102 | **Comparativo de balances 2.** PID=COMPARATIVO — duplicado con P155. Ver ANO-004. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P161.txt | COBOL | S500P161 | 551 | Proceso batch 161. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P164.txt | COBOL | P164 | 2,631 | Proceso batch 164. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P165.txt | COBOL | S500P165-RESULTADO-DISPERSION | 5,643 | **Resultado de dispersión.** Procesa resultados del proceso de dispersión masiva de fondos. | — | S500BD01CAPTACION, BD02 | — |
| S500_SOURCE_P168.txt | COBOL | P168 | 2,097 | Proceso batch 168. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P170.txt | BINARIO | (ilegible) | 3,482 | **ARCHIVO BINARIO.** Source EBCDIC sin conversión completa. Ver ANO-006. No analizable en estado actual. | — | — | — |
| S500_SOURCE_P174.txt | COBOL | GENARCHSDOS | 1,112 | **Generación de archivos DOS.** Genera archivos con formato DOS a partir de datos de captación. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P176.txt | COBOL | S500P176 | 1,545 | Proceso batch 176. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P178.txt | COBOL | S500P178 | 1,717 | Proceso batch 178. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P179.txt | COBOL | S500P179 | 486 | Proceso batch 179. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P180.txt | COBOL | REPORTEADOR | 5,038 | **Reporteador general.** Genera reportes de movimientos y saldos del sistema S500. | — | S500BD01CAPTACION, BD02 | — |
| S500_SOURCE_P181.txt | COBOL | P181 | 2,044 | Proceso batch 181. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P184.txt | COBOL | P184-INVCPE | 391 | **Inventario CPE.** Proceso de inventario de Certificados de Participación/Endeudamiento. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P185.txt | COBOL | P185 | 397 | Proceso batch 185. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P186.txt | COBOL | P186 | 5,400 | Proceso batch 186. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P187.txt | COBOL | P187 | 1,881 | Proceso batch 187. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P188.txt | COBOL | P188 | 1,308 | Proceso batch 188. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P189.txt | COBOL | P189 | 2,218 | Proceso batch 189. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P190.txt | COBOL | P190 | 1,672 | Proceso batch 190. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P191.txt | COBOL | S500P191 | 3,065 | Proceso batch 191. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P195.txt | COBOL | P195 | 2,656 | Proceso batch 195. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P197.txt | COBOL | P197 | 4,117 | Proceso batch 197. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P199.txt | COBOL | P199 | 1,831 | Proceso batch 199. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P200.txt | COBOL | P200 | 1,553 | Proceso batch 200. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P290.txt | COBOL | S500P290 | 2,659 | Proceso batch 290. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P305.txt | COBOL | S500P305 | 1,803 | Proceso batch 305. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P310.txt | COBOL | P310-CARGA | 1,098 | **Carga batch 310.** Proceso de carga de datos al sistema S500. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P315.txt | BINARIO | (ilegible) | 2,067 | **ARCHIVO BINARIO.** Source EBCDIC sin conversión. Ver ANO-006. | — | — | — |
| S500_SOURCE_P320.txt | COBOL | P320 | 1,330 | Proceso batch 320. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P330.txt | COBOL | CALCULOS-PROD-ESP | 7,821 | **Cálculos de productos especiales.** Proceso batch de cálculo para productos especiales de captación (inversiones, pagarés, etc.). | CNBV | S500BD01CAPTACION, BD02 | — |
| S500_SOURCE_P335.txt | COBOL | S500P400 (ANOMALÍA) | 5,099 | **ANOMALÍA ANO-002.** Filename=P335 pero PID=S500P400. Contenido es posiblemente el programa P400 real. Ver PROGRAM-ID cruzados. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P400.txt | COBOL | P335-EDOCTA (ANOMALÍA) | 1,034 | **ANOMALÍA ANO-002.** Filename=P400 pero PID=P335-EDOCTA. Estado de cuenta (EDOCTA). Contenido del estado de cuenta de captación. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P420.txt | COBOL | CONCENTRADOR-SALDOSTB | 983 | **Concentrador de saldos para tarjetas.** Une archivos FILE/SALDOTB de tarjetas. Proceso de consolidación. | — | S500BD04TARJETAS | — |
| S500_SOURCE_P430.txt | COBOL | S500P430 | 1,035 | **Batch P430.** Ver. Feb/2006. Cuenta MAX 2da Etapa. | — | S500BD01CAPTACION | — |
| S500_SOURCE_P629_CARGABD06.txt | COBOL | P629 | 655 | **Carga de BD06 TELETON.** Migrado del sistema S501 al S500 (Jun/2016). Carga datos al S500BD06TELETON. | — | S500BD06TELETON | (migrado de S501) |
| S500_SOURCE_P630_TARINTERCAM.txt | COBOL | S500P630 | 1,359 | **Tarjetas intercambiables.** Migrado de S501/P110 a S500/P630 (Jun–Oct 2016). Procesa tarjetas intercambiables. | — | S500BD04TARJETAS | (migrado de S501) |
| S500_SOURCE_P655_SCRAMBLING.txt | COBOL | P655 | 860 | **Scrambling de datos.** Obfuscación/enmascaramiento de datos sensibles de captación. Batch de seguridad. Mar/2004. | — | S500BD01CAPTACION | — |

---

## S151 — CATÁLOGO DE PROGRAMAS

> Sistema: Movimientos Contables General Ledger  
> Plataforma: Unisys ClearPath MCP  
> Bases de datos: DMSII S151BD02ADSALDO, BD10MOVDIA151, BD11SDOS151, BD12MC001S151, BD13BIFIN, BD99CONTROL  
> Alimentado por: S500 (vía S151REGISTRA), sistemas C402, C600, S804, S707, S203, S264, Citi

### Bases de Datos DMSII S151

| Archivo | Base de Datos DMSII | LOC | Descripción | Flags |
|---------|---------------------|-----|-------------|-------|
| DASDL_S151BD02ADSALDO.txt | S151BD02ADSALDO | 716 | BD de saldos acumulados (saldos por fecha). | CNBV |
| DASDL_S151BD10MOVDIA151.txt | S151BD10MOVDIA151 | 1,203 | BD de movimientos diarios S151. Principal BD transaccional. | — |
| DASDL_S151BD11SDOS151.txt | S151BD11SDOS151 | 333 | BD de saldos S151. | — |
| DASDL_S151BD12MC001S151.txt | S151BD12MC001S151 | 640 | BD contable MC001 del S151. Estructura de cuentas contables. | — |
| DASDL_S151BD13BIFIN.txt | S151BD13BIFIN | 715 | BD BIFIN — información financiera bilateral. | — |
| DASDL_S151BD99CONTROL.txt | S151BD99CONTROL | 538 | BD de control del sistema S151. Fechas, parámetros, estados. | — |

### WFL Jobs S151

| Archivo | Tipo | LOC | Descripción |
|---------|------|-----|-------------|
| WFL_LOTE.txt | BATCH genuino | 7,738 | `BEGIN JOB S151/WFL/LOTE/25MTP003`. Orquesta: P005 (carga arch Tesorería), P101 (valida terminación envío movtos), P103 (control fechas corporativo), P120 (concentrador), P130 (agrupador CFR), P131 (traductor CFR), P138 (posición global), P140 (riesgos), P150 (gen archs ALR/AHR/OCM CITI), P158 (movtos contrato), P160 (acumula movtos sucursal), P000 (proyección fecha BD), P600, P610, P670, P671, P199 (migración saldos S500). |
| WFL_LINEA.txt | ONLINE genuino | 1,546 | `BEGIN JOB S151/WFL/LINEA/25MTP003`. Inicia tasks COMS: T005, T007, T010, T011, T012, T013, T014, T017, T018, T020, T030, T050, T052, T053, T054, T055, T060, T061, T071, T073, T090, T612. |
| WFL_SPLUNK.txt | SPLUNK (moderno) | 98 | `S151/WFL/SPLUNK/25MTP006`. Integración con Splunk para envío de logs de monitoreo. Adición reciente (MTP006 posterior a MTP003). |

### Librerías ALGOL S151

| Archivo | Lenguaje | LOC | Modo | Descripción | Flags | Deps |
|---------|----------|-----|------|-------------|-------|------|
| ALGOL_L001.txt | ALGOL | 3,126 | LIBRARY | **Librería de control de BD S151.** SHARING=SHAREDBYRUNUNIT. Accede S151BD99CONTROL. Gestiona fechas, calendarios via LOCSUP. Define códigos de error 1-13 en comentarios. | — | S151BD99CONTROL, S006LOCSUP |
| ALGOL_L002R2.txt | ALGOL | 4,507 | LIBRARY | **S151REGISTRA versión R2.** SHARING=SHAREDBYALL. Librería de registro de movimientos contables. Usada por S500/P130, P142, P144 para postear al GL. Código CRONOS 2000. | CNBV | S151BD10MOVDIA151 |
| ALGOL_L002R3.txt | ALGOL | 9,355 | LIBRARY | **S151REGISTRA versión R3.** Mayor versión (9K LOC). SHARING=SHAREDBYALL. | CNBV | S151BD10MOVDIA151 |
| ALGOL_L002R4.txt | ALGOL | 7,280 | LIBRARY | **S151REGISTRA versión R4.** SHARING=SHAREDBYALL. $TARGET LEVEL4. | CNBV | S151BD10MOVDIA151 |
| ALGOL_L002R5.txt | ALGOL | 7,414 | LIBRARY | **S151REGISTRA versión R5 (actual).** SHARING=SHAREDBYALL. $TARGET ALL. Versión más reciente del registro GL. | CNBV | S151BD10MOVDIA151 |
| ALGOL_L006.txt | ALGOL | 2,029 | LIBRARY | Librería L006. SHARING=SHAREDBYALL. $TARGET LEVEL6. | — | — |
| ALGOL_L009.txt | ALGOL | 3,276 | LIBRARY | Librería L009. SHARING=SHAREDBYALL. | — | — |
| ALGOL_L010.txt | ALGOL | 573 | LIBRARY | Librería L010. SHARING=PRIVATE. | — | — |
| ALGOL_L011.txt | ALGOL | 7,210 | LIBRARY | **Consulta de movimientos S151BD10MOVDIA.** SHARING=PRIVATE. Código CRONOS 2000 ($SET OLDCODE). Referencia CNBV. Gran librería de consulta (7K LOC). | CNBV | S151BD10MOVDIA151 |
| ALGOL_L012.txt | ALGOL | 7,142 | LIBRARY | Librería L012. SHARING=SHAREDBYALL. | — | — |
| ALGOL_L194.txt | ALGOL | 114 | LIBRARY | Librería L194. Stub pequeño (114 LOC). SHARING=PRIVATE. | — | — |

### Programas ALGOL S151

| Archivo | Lenguaje | LOC | Modo | Descripción | Flags | Deps |
|---------|----------|-----|------|-------------|-------|------|
| ALGOL_P000.txt | ALGOL | 714 | BATCH (WFL_LOTE) | **Control de fechas y prelínea automática.** PROCEDURE PROGRAM(PA). Gestiona proyección de fechas en la BD de control. Include CRONOS2K. | — | S151BD99CONTROL, CPBAS |
| ALGOL_P007.txt | ALGOL | 260 | ONLINE (T007) | **Proceso ONLINE Task T007.** VERSION 00.01.02. Maneja tipos de mensaje 02, 32, 11. Control de duplicados, confirmaciones, no-envíos. | — | — |
| ALGOL_P012.txt | ALGOL | 265 | ONLINE | **Proceso asíncrono 012.** VERSION 00.01.01 (Dic/2004). Similar a P007 con tskval. | — | — |
| ALGOL_P021.txt | ALGOL | 100 | LIBRARY/ONLINE | **Stub de consulta de título.** SHARING=SHAREDBYALL. Llama CTLVERS y DAME_TIT (consulta de títulos). | — | CTLVERS |
| ALGOL_P810.txt | ALGOL | 4,113 | BATCH/MONITOR | **Carga periódica de sistemas y conceptos a BD — Integración Splunk.** VERSION 0.25.6. OBJECTIVE: carga de sistemas y conceptos en BD S151 para consulta de MOVDIA. Programa moderno de monitoreo. | — | S151BD10MOVDIA151 |

### Programas ONLINE COBOL S151

| Archivo | Lenguaje | PROGRAM-ID | LOC | Descripción | Flags | Deps |
|---------|----------|-----------|-----|-------------|-------|------|
| COBOL_P010.txt | COBOL | LINEA | 18,943 | **Servidor COMS principal S151.** PID=LINEA. Mayor programa online (~19K LOC). Punto de entrada para todas las transacciones online del GL. Ver ANO-010 (colisión con P053). | — | S151BD99CONTROL, BD10MOVDIA151 |
| COBOL_P011.txt | COBOL | P011 | 2,356 | Proceso online Task T011. | — | S151BD10MOVDIA151 |
| COBOL_P013.txt | COBOL | DGODOMI | 3,626 | **DGODOM — Proceso LINEA T013.** PID=DGODOMI. | — | — |
| COBOL_P014.txt | COBOL | DGOPROTCOB | 5,429 | **Protocolo cobros LINEA T014.** PID=DGOPROTCOB. | — | — |
| COBOL_P015.txt | COBOL | ASINCRONO | 12,003 | **Servidor asíncrono S151.** PID=ASINCRONO. Gran programa (12K LOC). Gestiona operaciones asíncronas del sistema GL. | — | S151BD10MOVDIA151 |
| COBOL_P016.txt | COBOL | P016 | 2,801 | Proceso online P016. | — | — |
| COBOL_P017.txt | COBOL | S151-P017 | 1,935 | Proceso online P017. | — | — |
| COBOL_P020.txt | COBOL | S151-P020 | 2,139 | Proceso online Task T020. | — | S151BD10MOVDIA151 |
| COBOL_P025.txt | COBOL | CARSDOMOV | 3,142 | **Carga de movimientos S151.** PID=CARSDOMOV. | — | S151BD10MOVDIA151 |
| COBOL_P030.txt | COBOL | ADMOV | 5,969 | **Administración de movimientos T030.** PID=ADMOV. | — | S151BD10MOVDIA151 |
| COBOL_P050.txt | COBOL | P050ADSALDOS | 15,722 | **Acceso a saldos T050.** PID=P050ADSALDOS. Gran programa (15K LOC). Gestiona acceso y actualización de saldos en BD02ADSALDO. | — | S151BD02ADSALDO, BD10MOVDIA151 |
| COBOL_P052.txt | COBOL | ACCIVAL | 13,708 | **Acumulación / Validación T052.** PID=ACCIVAL. Gran programa (13K LOC). | — | S151BD02ADSALDO |
| COBOL_P053.txt | COBOL | LINEA | 12,817 | **LINEA T053.** PID=LINEA (ver ANO-010, colisión con P010). | — | S151BD10MOVDIA151 |
| COBOL_P054.txt | COBOL | EXTENDEDNETWORK | 4,098 | **Red extendida T054.** PID=EXTENDEDNETWORK. Procesa operaciones de red extendida (corresponsales). | — | — |
| COBOL_P055.txt | COBOL | FILESCTAMDRED | 4,235 | **Files de cuenta MdRed T055.** PID=FILESCTAMDRED. Gestiona archivos de cuentas en red de medios. | — | — |
| COBOL_P071.txt | COBOL | S151P071 | 2,022 | Proceso online Task T071. | — | — |
| COBOL_P073.txt | COBOL | S151P073 | 1,782 | Proceso online Task T073. | — | — |
| COBOL_P090.txt | COBOL | RECLIDE | 1,077 | **Reclamaciones / Diferidos T090.** PID=RECLIDE. | — | — |
| COBOL_P612.txt | COBOL | (no PID extendido) | 86 | **Stub minimal T612.** Programa muy pequeño (86 LOC). Task ONLINE T612. Uso de OPTIMIZE/TADS. | — | — |

### Programas BATCH COBOL S151

| Archivo | Lenguaje | PROGRAM-ID | LOC | Descripción | Flags | Cross-System |
|---------|----------|-----------|-----|-------------|-------|-------------|
| COBOL_P001.txt | COBOL | (no PID ext.) | 3,585 | Proceso batch inicial S151. | — | — |
| COBOL_P005.txt | COBOL | EXTRACTOR | 3,641 | **Extractor — carga archivos Tesorería (WFL_LOTE).** PID=EXTRACTOR. Carga archivos para proceso de tesorería. | TESOFE | — |
| COBOL_P102.txt | COBOL | CALLLIBCTL | 856 | **Llamada a librería de control.** PID=CALLLIBCTL. Programa de ejemplo/interfaz con lib. de control. | — | — |
| COBOL_P103.txt | COBOL | (no PID ext.) | 562 | **Control de fechas en corporativo (WFL_LOTE).** | — | — |
| COBOL_P104.txt | COBOL | (no PID ext.) | 3,345 | Proceso batch 104. | — | — |
| COBOL_P107.txt | COBOL | (no PID ext.) | 9,759 | Proceso batch 107 (9K LOC). | — | — |
| COBOL_P108.txt | COBOL | (no PID ext.) | 14,572 | **Proceso batch 108.** Gran programa (14K LOC). | — | — |
| COBOL_P109.txt | COBOL | (no PID ext.) | 19,381 | **Proceso batch 109.** El mayor programa del sistema S151 por LOC (19K). | CNBV | — |
| COBOL_P110.txt | COBOL | S151-P110 | 3,798 | **Proceso batch P110.** | — | — |
| COBOL_P111.txt | COBOL | P111 | 2,374 | Proceso batch 111. | — | — |
| COBOL_P112.txt | COBOL | P112 | 3,326 | Proceso batch 112. | — | — |
| COBOL_P113.txt | COBOL | PFORANEOS | 2,123 | **Foráneos.** PID=PFORANEOS. Proceso de movimientos foráneos (corresponsalía). | — | — |
| COBOL_P114.txt | COBOL | S151-P114-EXTRAEICA | 2,153 | **Extracción ICA.** Proceso de extracción de información ICA. | — | — |
| COBOL_P115.txt | COBOL | S151-P115-COMPENREG | 7,050 | **Compensación / Registro.** Proceso de compensación y registro contable (7K LOC). | CNBV | — |
| COBOL_P116.txt | COBOL | S151-P116-CONCENTRA | 3,244 | **Concentrador.** Proceso de concentración de movimientos. | — | — |
| COBOL_P117.txt | COBOL | S151-P117-DIFERENCIAS | 3,394 | **Diferencias.** Proceso de detección y manejo de diferencias contables. | CNBV | — |
| COBOL_P120.txt | COBOL | EXTRACTOR | 1,317 | **Concentrador batch (WFL_LOTE).** PID=EXTRACTOR (mismo que P005). Proceso concentrador principal. | — | — |
| COBOL_P122.txt | COBOL | (no PID — empieza IDENT DIV) | 2,218 | **Carga de movimientos de C402, C600, S804, S707, S203.** Toma archivos de sistemas CBII y Tandem, llama L002 para generar archivos de movimientos/descripciones del S151 (LOGS). MTP008. | — | C402, C600, S804, S707, S203 (Tandem) |
| COBOL_P128.txt | COBOL | (no PID) | 2,346 | **Diferencias S264.** Comparativo entre lo enviado a S028 y S115. Diferencias contables entre ambos envíos. Procesa archivo S151/FILE/MOVS264/AAMMDD. | — | S264, S028, S115 |
| COBOL_P130.txt | COBOL | (no PID ext.) | 13,360 | **Proceso concentrador S151 (WFL_LOTE — P120).** Gran programa batch (13K LOC). | — | S151BD10MOVDIA151 |
| COBOL_P131.txt | COBOL | (no PID ext.) | 11,833 | **Agrupador contable esquema CFR (WFL_LOTE).** Gran programa (11K LOC). | — | S151BD10MOVDIA151, BD12MC001S151 |
| COBOL_P135.txt | COBOL | P135 | 6,816 | Proceso batch 135. | — | — |
| COBOL_P138 .txt | COBOL | REPORTECSIS | 1,240 | **Posición global / Reporte CSIS (WFL_LOTE — P138).** PID=REPORTECSIS. **Anomalía ANO-007:** filename tiene espacio antes del punto. | — | — |
| COBOL_P150.txt | COBOL | (no PID ext.) | 12,746 | **Generación archivos ALR, AHR y OCM CITI (WFL_LOTE).** Toma archivo con movimientos de Citibank para generar reportes CITI. Gran programa (12K LOC). | — | CITI (Citibank) |
| COBOL_P151.txt | COBOL | (no PID ext.) | 17,370 | **Generación archivos CITI 2.** Continuación/complemento de P150 (17K LOC). Movimientos Citibank para reportes regulatorios. | — | CITI |
| COBOL_P152.txt | COBOL | P152 | 2,193 | Proceso batch 152. | — | — |
| COBOL_P153.txt | COBOL | P153 | 1,572 | Proceso batch 153. | — | — |
| COBOL_P158.txt | COBOL | (no PID ext.) | 13,694 | **Movimientos por contrato (WFL_LOTE).** Genera reporte único de movimientos por contrato (13K LOC). | — | S151BD10MOVDIA151 |
| COBOL_P167.txt | COBOL | (no PID — CRONOS 2000) | 7,860 | **Saldos de contratos S500 prod 001 y 066.** Genera archivo con saldos de contratos del S500 por producto 001 (cheques) y 066 (cuenta maestra). Código CRONOS 2000. | Y2K | S500 (→lectura archivo) |
| COBOL_P168.txt | COBOL | (no PID ext.) | 2,171 | **Punteo de saldos archivos CBII.** Genera punteo de saldos entre archivos CBII. | — | CITI/CBII |
| COBOL_P169.txt | COBOL | (no PID ext.) | 7,852 | **Saldos contratos S500 prod 001/066 — versión 2.** Similar a P167. Procesa archivos de saldos S151. | — | S500 (→archivo), S151BD11SDOS151 |
| COBOL_P170.txt | COBOL | (no PID ext.) | 1,437 | **Impresión backups del P158.** Toma archivo generado por P158, imprime backups grabados. Acepta número de sistema y nombre por parámetro. | — | — |
| COBOL_P171.txt | COBOL | (no PID ext.) | 1,960 | **Punteo saldos Citidirect.** Genera punteo de saldos entre archivos CitiDirect. | — | CITI |
| COBOL_P172.txt | COBOL | (no PID ext.) | 3,283 | Proceso batch 172. Recompilado por upgrade MCP a versión 55. | — | — |
| COBOL_P177.txt | COBOL | (no PID — CRONOS 2000) | 4,197 | Proceso batch 177. Código CRONOS 2000 presente. | Y2K | — |
| COBOL_P178.txt | COBOL | (no PID — CRONOS 2000) | 4,865 | Proceso batch 178. Código CRONOS 2000 presente. | Y2K | — |
| COBOL_P194.txt | COBOL | (no PID ext.) | 854 | **Eliminación de archivos.** Felix Torres Dic/2016. Proceso de limpieza/purga de archivos del sistema. | — | — |
| COBOL_P195.txt | COBOL | (no PID — CRONOS 2000) | 1,561 | **Generación de archivos desde BD de control.** Genera archivos a partir de la BD de control. Código CRONOS 2000. | Y2K | S151BD99CONTROL |
| COBOL_P196.txt | COBOL | (no PID ext.) | 1,136 | **Depuración de B05 de control.** Depura las B05 de control creadas en el lote. | — | S151BD99CONTROL |
| COBOL_P197.txt | COBOL | (no PID — CRONOS 2000) | 3,195 | **Actualización de saldos mensuales.** OBJETIVO: actualizar saldos mensuales, saldos por día. Código CRONOS 2000. | Y2K | S151BD02ADSALDO, BD11SDOS151 |
| COBOL_P199.txt | COBOL | (no PID ext.) | 2,752 | **Migración saldos S500 (WFL_LOTE).** Proceso de migración de saldos desde el S500 al S151. | — | S500 (→archivos) |
| COBOL_P312.txt | COBOL | (no PID ext.) | 1,211 | **Archivo de saldos para S084.** OBJETIVO: proporcionar archivo de saldos para el sistema S084. $SET OPTIMIZE FEDLEVEL=5. | — | S084 |
| COBOL_P330.txt | COBOL | (no PID ext.) | 2,506 | **Extracción estructuras B20, B21.** FUNCION: extracción de estructuras B20, B21 del S151. | — | S151BD10MOVDIA151 |
| COBOL_P360.txt | COBOL | (no PID ext.) | 2,538 | **Integración estructuras B20, B21.** FUNCION: integración de estructuras B20, B21. Complemento de P330. | — | S151BD10MOVDIA151 |

### Programas BATCH COBOL S151 — Grupo Reportes (P600-P690)

| Archivo | Lenguaje | PROGRAM-ID | LOC | Descripción | Deps |
|---------|----------|-----------|-----|-------------|------|
| COBOL_P600.txt | COBOL | CALLLIBCTL | 903 | **Ejemplo llamado a lib. de control (WFL_LOTE — P600).** PID=CALLLIBCTL. Programa ejemplo/orquestador que llama librería de control. | L001 |
| COBOL_P602.txt | COBOL | CALLLIBCTL | 749 | **Cambio de estatus en BD.** PID=CALLLIBCTL. FUNCION: efectúa cambio en dato ESTATUS en BD de control. | S151BD99CONTROL |
| COBOL_P606.txt | COBOL | LEE-ARCHMOVYDES | 2,674 | **Lectura de archivos de movimientos y descripciones.** PID=LEE-ARCHMOVYDES. $TARGET=LEVEL2. | S151BD10MOVDIA151 |
| COBOL_P610.txt | COBOL | CALLLIBCTL | 1,767 | **Ejemplo llamado lib. control (WFL_LOTE — P610).** PID=CALLLIBCTL. | L001 |
| COBOL_P612.txt | COBOL | (no PID — stub) | 86 | **Stub WFL Task T612.** 86 LOC — mínimo. Punto de entrada ONLINE. | — |
| COBOL_P620.txt | COBOL | (no PID ext.) | 210 | **Modificación del archivo de directorios.** FUNCION: modificar el archivo de directorios. | — |
| COBOL_P630.txt | COBOL | LEE-MOVSNNN | 489 | **Lectura de movimientos NNN.** PID=LEE-MOVSNNN. | S151BD10MOVDIA151 |
| COBOL_P655.txt | COBOL | CALLLIBCTL | 770 | **Proceso de control 655.** PID=CALLLIBCTL. | L001 |
| COBOL_P670.txt | COBOL | (no PID ext.) | 1,487 | **Listados P670 (WFL_LOTE).** FUNCION: toma archivo generado por P106, P108, P109 o P670 y genera listados. | — |
| COBOL_P671.txt | COBOL | LEE-PROT-DOM-ALER | 562 | **Lecturas de protocolos domiciliación alertas (WFL_LOTE — eventual).** PID=LEE-PROT-DOM-ALER. | — |
| COBOL_P677.txt | COBOL | (no PID ext.) | 1,093 | **Generación de archivos de datasets desde BD de control.** FUNCION: generar archivos con información de datasets B01SISDIA, B02ARCINTER, B03SISMEN, B04SISTEM. | S151BD99CONTROL |
| COBOL_P680.txt | COBOL | (no PID ext.) | 687 | **Generación datasets desde BD control (variante).** Similar a P677. B01SISDIA, B02ARCINTER, B03SISMEN, B04SISTEM. | S151BD99CONTROL |
| COBOL_P690.txt | COBOL | LEE-MOVSNNN | 824 | **Lectura movimientos NNN — variante.** PID=LEE-MOVSNNN. | S151BD10MOVDIA151 |

### Librerías COBOL S151

| Archivo | Lenguaje | PROGRAM-ID | LOC | Descripción | Deps |
|---------|----------|-----------|-----|-------------|------|
| COBOL_L014.txt | COBOL | S151L014 | 2,561 | Librería COBOL L014 del S151. | — |
| COBOL_L020.txt | COBOL | S151LIB020 | 2,712 | Librería COBOL L020 del S151. | — |
| COBOL_L030.txt | COBOL | S151LIB030 | 19,253 | **Mayor librería COBOL del S151 (19K LOC).** Librería compartida de gran tamaño. | S151BD10MOVDIA151 |
| COBOL_L040.txt | COBOL | TOTXCVETRA | 4,110 | **Totales por clave de trayectoria.** PID=TOTXCVETRA. | — |

---

## ÍNDICE RÁPIDO POR PROGRAM-ID

### S500 — Índice PID → Archivo

| PROGRAM-ID | Archivo(s) | Notas |
|-----------|-----------|-------|
| LINCOMS | P010, P020, P280 | ANO-003: tres programas con mismo PID |
| DISPERSADOR | P015 | — |
| S500P038 | P038 | — |
| S500P045 | P045 | — |
| P050LIN | P050 | Sufijo LIN = online |
| P055LIN | P055 | Sufijo LIN = online |
| S500P080 | P080 | — |
| P005 | P005 | — |
| FECHA-DE-PROCESO | P100 | — |
| P101 | P101 | — |
| P102 | P102 | — |
| P103 | P103 | — |
| S500PXXX | P104 | ANO-005: TEMPLATE |
| S500P105 | P105 | — |
| MOD-ARCH | P106 | — |
| P107 | P107 | — |
| P108 | P108 | — |
| P109 | P109 | — |
| S500P110 | P110 | — |
| P115 | P115 | — |
| P117 | P117 | — |
| P120 | P120 | — |
| ACTB03 | P121 | — |
| P125 | P125 | — |
| P127 | P127 | — |
| P130 | P130 | — |
| S500P131 | P131 | — |
| S500BATCH | P140 | — |
| P142 | P142 | S151REGISTRA |
| P144 | P144 | S151REGISTRA |
| COMPARATIVO | P155, P160 | ANO-004: PID duplicado |
| S500P161 | P161 | — |
| P164 | P164 | — |
| S500P165-RESULTADO-DISPERSION | P165 | — |
| P168 | P168 | — |
| GENARCHSDOS | P174 | — |
| S500P176 | P176 | — |
| S500P178 | P178 | — |
| S500P179 | P179 | — |
| REPORTEADOR | P180 | — |
| P181 | P181 | — |
| P184-INVCPE | P184 | — |
| P185 | P185 | — |
| P186 | P186 | — |
| P187 | P187 | — |
| P188 | P188 | — |
| P189 | P189 | — |
| P190 | P190 | — |
| S500P191 | P191 | — |
| P195 | P195 | — |
| P197 | P197 | — |
| P199 | P199 | — |
| P200 | P200 | — |
| S500P290 | P290 | — |
| S500P305 | P305 | — |
| P310-CARGA | P310 | — |
| P320 | P320 | — |
| CALCULOS-PROD-ESP | P330 | — |
| **S500P400** | **P335** | **ANO-002: PID cruzado** |
| **P335-EDOCTA** | **P400** | **ANO-002: PID cruzado** |
| CONCENTRADOR-SALDOSTB | P420 | — |
| S500P430 | P430 | — |
| P629 | P629_CARGABD06 | — |
| S500P630 | P630_TARINTERCAM | — |
| P655 | P655_SCRAMBLING | — |

### S151 — Índice PID → Archivo

| PROGRAM-ID | Archivo(s) | Notas |
|-----------|-----------|-------|
| **LINEA** | **P010, P053** | **ANO-010: PID duplicado (online servers)** |
| ASINCRONO | P015 | Servidor asíncrono |
| P011 | P011 | — |
| DGODOMI | P013 | — |
| DGOPROTCOB | P014 | — |
| P016 | P016 | — |
| S151-P017 | P017 | — |
| S151-P020 | P020 | — |
| CARSDOMOV | P025 | — |
| ADMOV | P030 | — |
| P050ADSALDOS | P050 | — |
| ACCIVAL | P052 | — |
| EXTENDEDNETWORK | P054 | — |
| FILESCTAMDRED | P055 | — |
| S151P071 | P071 | — |
| S151P073 | P073 | — |
| RECLIDE | P090 | — |
| CALLLIBCTL | P102, P600, P602, P610, P655 | Múltiples programas |
| EXTRACTOR | P005, P120 | Dos programas batch |
| CARSDOMOV | P025 | — |
| P111 | P111 | — |
| P112 | P112 | — |
| PFORANEOS | P113 | — |
| S151-P114-EXTRAEICA | P114 | — |
| S151-P115-COMPENREG | P115 | — |
| S151-P116-CONCENTRA | P116 | — |
| S151-P117-DIFERENCIAS | P117 | — |
| P135 | P135 | — |
| REPORTECSIS | P138 (espacio ANO-007) | — |
| P152 | P152 | — |
| P153 | P153 | — |
| LEE-ARCHMOVYDES | P606 | — |
| LEE-MOVSNNN | P630, P690 | Dos programas |
| LEE-PROT-DOM-ALER | P671 | — |
| S151L014 | L014 | — |
| S151LIB020 | L020 | — |
| S151LIB030 | L030 | — |
| TOTXCVETRA | L040 | — |

---

## ÍNDICE — PROGRAMAS BATCH (WFL_LOTE)

### S500 BATCH (inferido — WFL real no disponible en extracted_source)

> **Nota:** El WFL de LOTE de S500 no está en el extracted_source. La siguiente lista se infiere de la convención de naming y análisis del source. Todos los programas no marcados como ONLINE se clasifican tentativamente como BATCH.

| Programa | PROGRAM-ID | LOC | Función |
|---------|-----------|-----|---------|
| P005 | P005 | 2,667 | Proceso inicial / depuración |
| P100 | FECHA-DE-PROCESO | 593 | Obtención de fecha de proceso |
| P101 | P101 | 817 | Proceso batch 101 |
| P102 | P102 | 4,728 | Manejo de include BD |
| P103 | P103 | 332 | FraudLink → S711 |
| P104 | S500PXXX | 4,511 | TEMPLATE (inactivo?) |
| P105 | S500P105 | 10,278 | Proceso batch grande |
| P106 | MOD-ARCH | 1,350 | Modificación de archivos |
| P107-P109 | P107/P108/P109 | 2K-3K | Procesos batch |
| P110 | S500P110 | 5,190 | Proceso batch |
| P115, P117 | P115/P117 | 2K | Procesos batch |
| P120, P121 | P120/ACTB03 | 4K-0.5K | Concentración / actualización |
| P125, P127 | P125/P127 | 2K-3K | Procesos batch |
| **P130** | **P130** | **15,881** | **Principal batch — GL (S151REGISTRA)** |
| P131 | S500P131 | 3,394 | Batch 131 |
| P140 | S500BATCH | 2,427 | Monitor aplicaciones batch |
| **P142** | **P142** | **14,569** | **Batch crédito-captación (S151REGISTRA)** |
| **P144** | **P144** | **14,497** | **Batch crédito-captación 2 (S151REGISTRA)** |
| P155, P160 | COMPARATIVO | 1.8K-2K | Comparativo balances (PID duplicado) |
| P161-P200 | varios | 400-5K | Procesos batch varios |
| P280 | LINCOMS | 1,649 | Servidor COMS terciario (online clasificado aquí por ubicación numérica) |
| P290-P330 | varios | 1K-8K | Procesos batch avanzados |
| P335/P400 | ANO-002 | 5K-1K | PID cruzado — verificar en producción |
| P420-P655 | varios | 655-1.4K | Procesos especiales/tarjetas/scrambling |

### S151 BATCH (confirmado desde WFL_LOTE.txt)

| Step WFL | Programa | PROGRAM-ID | LOC | Descripción en WFL |
|----------|---------|-----------|-----|-------------------|
| P005 | COBOL_P005 | EXTRACTOR | 3,641 | CARGA DE ARCHIVOS PARA TESORERIA |
| P101 | COBOL_P101 (no en listado — ver nota) | — | — | VALIDA TERMINACION DE ENVIO DE MOVTOS |
| P103 | COBOL_P103 | — | 562 | CONTROL DE FECHAS EN CORPORATIVO |
| P120 | COBOL_P120 | EXTRACTOR | 1,317 | PROCESO CONCENTRADOR |
| P130 | COBOL_P130 | — | 13,360 | AGRUPADOR CONTABLE ESQ. CFR |
| P131 | COBOL_P131 | — | 11,833 | TRADUCTOR CONTABLE ESQ. CFR |
| P138 | COBOL_P138 .txt | REPORTECSIS | 1,240 | POSICION GLOBAL |
| P140 | COBOL (P140) | — | — | RIESGOS Y EXCEPCIONES |
| P150 | COBOL_P150 | — | 12,746 | GEN. DE ARCHS. ALR, AHR Y OCM CITI |
| P158 | COBOL_P158 | — | 13,694 | MOVIMIENTOS POR CONTRATO |
| P160 | COBOL_P160 (no en listado) | — | — | ACUMULA MOVIMIENTOS POR SUCURSAL |
| P000 | ALGOL_P000 | PROGRAM(PA) | 714 | PROYECCION DE FECHA EN LA B.D. |
| P600 | COBOL_P600 | CALLLIBCTL | 903 | (listado en WFL) |
| P610 | COBOL_P610 | CALLLIBCTL | 1,767 | (listado en WFL) |
| P670 | COBOL_P670 | — | 1,487 | LISTADOS P670 |
| P671 | COBOL_P671 | LEE-PROT-DOM-ALER | 562 | EVENTUAL P671 |
| P199 | COBOL_P199 | — | 2,752 | MIGRACION SALDOS 500 |

> **Nota:** Programas referenciados en WFL_LOTE que no tienen archivo de source en S151/source/S151/: P101 (valida terminación envío), P160 (acumula movtos sucursal). Pueden estar bajo otro nombre o no estar incluidos en el extracto.

---

## ÍNDICE — PROGRAMAS ALGOL

### ALGOL S500

| Archivo | LOC | Tipo | Descripción |
|---------|-----|------|-------------|
| S500_SOURCE_L019_SALDOS.txt | 573 | LIBRARY | Saldos — acceso a balances |
| S500_SOURCE_L039_ACCESOBD04.txt | 11,747 | LIBRARY | Acceso BD04 Tarjetas |
| S500_SOURCE_L040_LIGAS.txt | 371 | LIBRARY | Ligas entre cuentas |
| S500_SOURCE_L045_TELETON.txt | 72 | LIBRARY | Proceso Teleton |
| S500_SOURCE_L046_REVOCA.txt | 300 | LIBRARY | Revocación de operaciones |
| S500_SOURCE_L050.txt | 6,400 | LIBRARY | Utilidades generales |
| S500_SOURCE_L060_CONSULFOR.txt | 252 | LIBRARY | Consulta de formatos |
| S500_SOURCE_L070.txt | 353 | LIBRARY | Utilidades 70 |
| S500_SOURCE_L080.txt | 1,671 | LIBRARY | Utilidades 80 (notif. cambio día) |
| S500_SOURCE_L081.txt | 2,800 | LIBRARY | Utilidades 81 |
| S500_SOURCE_L091_ASINCRONA.txt | 514 | LIBRARY | Async 91 |
| S500_SOURCE_L093_ASINCRONA.txt | 515 | LIBRARY | Async 93 |
| S500_SOURCE_P046.txt | 51 | ONLINE STUB | ENABLE(COMSINHDR,"ONLINE") — cancelaciones |
| S500_SOURCE_P091.txt | 56 | ONLINE COMS | INPUTHEADER/OUTPUTHEADER COMS |
| S500_SOURCE_P093_ASINCRONO.txt | 57 | ONLINE ASYNC | Async 93 |

### ALGOL S151

| Archivo | LOC | Tipo | Descripción | Flags |
|---------|-----|------|-------------|-------|
| ALGOL_L001.txt | 3,126 | LIBRARY | Control BD S151, calendarios LOCSUP | — |
| ALGOL_L002R2.txt | 4,507 | LIBRARY | **S151REGISTRA R2** — interfaz GL cross-system | CNBV |
| ALGOL_L002R3.txt | 9,355 | LIBRARY | **S151REGISTRA R3** — versión mayor | CNBV |
| ALGOL_L002R4.txt | 7,280 | LIBRARY | **S151REGISTRA R4** | CNBV |
| ALGOL_L002R5.txt | 7,414 | LIBRARY | **S151REGISTRA R5** — versión actual | CNBV |
| ALGOL_L006.txt | 2,029 | LIBRARY | Librería L006 | — |
| ALGOL_L009.txt | 3,276 | LIBRARY | Librería L009 | — |
| ALGOL_L010.txt | 573 | LIBRARY | Librería L010 | — |
| ALGOL_L011.txt | 7,210 | LIBRARY | Consulta movimientos MOVDIA, CRONOS 2000 | CNBV, Y2K |
| ALGOL_L012.txt | 7,142 | LIBRARY | Librería L012 | — |
| ALGOL_L194.txt | 114 | LIBRARY | Stub pequeño L194 | — |
| ALGOL_P000.txt | 714 | BATCH | Control fechas / prelínea automática | — |
| ALGOL_P007.txt | 260 | ONLINE | Task T007 — mensajes 02/32/11 | — |
| ALGOL_P012.txt | 265 | ONLINE | Async 012 — mensajes | — |
| ALGOL_P021.txt | 100 | LIBRARY | Consulta de títulos — DAME_TIT | — |
| ALGOL_P810.txt | 4,113 | BATCH/MONITOR | Carga sistemas/conceptos a BD — integración Splunk | — |

---

## MAPA DE INTEGRACIÓN CROSS-SYSTEM

```
S500 (Cargos & Abonos)  ──────────────────────────────────────────────────►  S151 (GL)
                                  S151REGISTRA (ALGOL L002R2-R5)
         P130 (15,881 LOC) ──► $SET S151REGISTRA, S151REGISTRA2 ──────────► S151BD10MOVDIA151
         P142 (14,569 LOC) ──► $SET S151REGISTRA ────────────────────────► S151BD10MOVDIA151
         P144 (14,497 LOC) ──► $SET S151REGISTRA ────────────────────────► S151BD10MOVDIA151

S500 ──► S711 (FraudLink / CNBV)
         P103 genera archivo de movimientos clave 2001/2444/2496 para S711

S500 ──► S080 (Operaciones / UDIS / Tarifas) — P080 referencia
S500 ──► S408 (Crédito) — P142, P144 referencia  
S500 ──► S016 (ACCESOBD2K) — P142 referencia
S500 ──► S050 (Saldos COBCOM) — P142 referencia
S500 ──► S006 (LOCSUP / Calendarios) — P005, L010
S500 ──► S000 (Utilidades Fechas) — P005, P010

S151 ──► C402, C600, S804 (plataformas host) — P122 carga archivos
S151 ──► S707, S203 (Tandem) — P122 carga archivos
S151 ──► S264, S028, S115 — P128 diferencias contables
S151 ──► S084 — P312 saldos para S084
S151 ──► CITI (Citibank) — P150, P151, P168, P171 reportes
S151 ──► Splunk — WFL_SPLUNK.txt / P810 integración moderna
```

---

## PATRONES DMSII DETECTADOS

### S500 — Acceso DMSII
Todos los programas SOURCE_P de S500 que tienen DATA-BASE SECTION en su COBOL acceden DMSII vía verbos FIND, GET, STORE, MODIFY. Las bases accedidas son:

| Programa(s) | BDs accedidas | Verbo principal |
|------------|---------------|-----------------|
| P010, P015, P020, P050, P080 | S500BD01CAPTACION, BD02 | FIND, GET, MODIFY |
| P130 | S500BD01CAPTACION, BD02 + múltiples sets | FIND, GET, STORE, MODIFY, ACTUAL KEY |
| P142, P144 | S500BD01CAPTACION, BD02 | FIND, GET, STORE, MODIFY |
| P420 | S500BD04TARJETAS | FIND, GET, STORE |
| P629 | S500BD06TELETON | STORE, MODIFY |
| L035_MAPLI | S500BD05MAPLI | FIND, GET |
| L039_ACCESOBD04 | S500BD04TARJETAS | FIND, GET, STORE |

### S151 — Acceso DMSII

| Programa(s) / Librería | BD accedida | Propósito |
|------------------------|-------------|-----------|
| L001 | S151BD99CONTROL | Parámetros y fechas de control |
| L002R2-R5 (S151REGISTRA) | S151BD10MOVDIA151 | Registro de movimientos GL |
| L011 | S151BD10MOVDIA151 | Consulta de movimientos diarios |
| **L014** | **S151BD13BIFIN** | **Pantallas online 28/29/30: B07PROTCOB, B08TDMIGCAP, B10DOMI** |
| P050 | S151BD02ADSALDO, BD10MOVDIA151 | Saldos acumulados |
| P052 | S151BD02ADSALDO | Acumulación de saldos |
| P130 (S151) | S151BD10MOVDIA151 | Concentrador |
| P131 (S151) | S151BD10MOVDIA151, BD12MC001S151 | Agrupador contable |
| P197 | S151BD02ADSALDO, BD11SDOS151 | Saldos mensuales |
| P602, P677, P680 | S151BD99CONTROL | Mantenimiento de control |
| P606, P630, P690 | S151BD10MOVDIA151 | Lectura de movimientos |

### S151BD13BIFIN — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `DASDL_S151BD13BIFIN.txt` (715 LOC). BD de integración financiera multi-sistema.
> AREAS=150, AREASIZE=100, BLOCKSIZE=1800. Opción INDEPENDENTTRANS activa.

| Dataset DMSII | Función (literal del DASDL) | Clave principal | Accedido por |
|---|---|---|---|
| B00 (global) | CSI, STAPROC, FECPROC, FECOPER, CTL-BIFIN, CTL-CITIDIR, CONS-BIFIN | — (global) | — |
| S151B01TOTPROD | Totales por producto: num/imp cargos y abonos × sistema | SISTEMA+CSI+FECHA+PRODUCTO+INSTSERV+MONEDA+CPAE+T | Batch GL |
| S151B02POSICION | Posición financiera: saldo inicial/final número e importe, STA-ENVIO | SISTEMA+CSI+FECHA+PRODUCTO+INSTSERV+MONEDA | Batch GL |
| S151B03ALARMAS | Alarmas: sucursal/cuenta, hora transmisión, autorizaciones 3 niveles | SISTEMA+CSI+FECHA+PRODUCTO+INSTSERV+MONEDA | L014 (pantalla 28) |
| S151B04CTLCITIDIR | Control CitiDirect: dos índices (SISTEMA+FECHA y FECHA_ENVIO) | SISTEMA+FECHA / FECHA_ENVIO | P150/P171 CITI batch |
| S151B05BATCH | Totales batch por sistema y producto | SISTEMA+PRODUCTO | Batch GL |
| S151B06CTLENVIO | Control de envíos a sistemas externos (key=NUM_MENS) | NUM_MENS | Batch envíos |
| S151B07PROTCOB | Protección de cobros: 4 SETs + 2 SUBSETs (fecha, auto, proceso, cliente) | NUM_ID+FECHA | L014 (pantalla 28) |
| S151B08TDMIGCAP | Migración captación — pantalla 29: 7 índices (fecha, BIN, tarjeta, autorización) | FECHA+SUC+CTO / FECHA+TAR / BIN | L014 (pantalla 29) |
| S151B09TICKETSBN | Tickets banco: fecha+máquina, cuenta+total+ticket | FECHA+MAQ / CTA+TOT+TK | — |
| S151B99REINICTL | **RESTART DATA SET** — `%PREFIJO S151B19REINICTL`. B99-REI-PROGRAM (NUMBER 8) + B99-REI-USERINFO (ALPHA 176). POPULATION=100 | — (restart) | Recovery/restart |
| S151B10DOMI | Domiciliación — pantalla 30 (declarado en L014, en BD13BIFIN) | — | L014 (pantalla 30) |

### S151BD02ADSALDO — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `DASDL_S151BD02ADSALDO.txt` (716 LOC). BD de saldos acumulados.
> DEFAULTS: PACK=S067REMESAS (pack externo compartido con BD11 y BD12).
> Globals B92: CSI, FECHA, FECHA-FIL, FECHA-CAR, SISTEMA, SISFILE, CSIOK, SUCOK, ARRIBO.

| Dataset DMSII | Descripción literal DASDL | Tipo | POPULATION |
|---|---|---|---|
| S151B91REINICIO | RESTART DATA SET | RESTART | 100 |
| S151B01SDOGLOB | SALDOS GLOBALES POR SISTEMA | STANDARD | 1,000 |
| S151B02SDOSUC | SALDOS GLOBALES POR SUCURSAL | STANDARD | 4,000 |
| S151B03SDOCTE | SALDOS GLOBALES POR SUC/CTE | STANDARD | 500,000 |
| S151B04SDOEXC | SALDOS POR EXCEPCION — **$SET OMIT: deshabilitado en compilación** | STANDARD | 1,000 |
| S151B05SDOCNC | SALDOS POR CONCEPTOS | STANDARD | 500,000 |
| S151B06SDOCNCCSI | SALDOS POR CONCEPTOS TOT CSI | STANDARD | 500,000 |
| S151B07TOTSDO | SALDOS POR CONCEPTOS S.A.R. | STANDARD | 1,000 |
| S151B08GLOSAR | SALDOS GLOBALES S.A.R | STANDARD | 500,000 |
| S151B09RECIMP | SALDOS RECEPCION IMPUESTOS — **$SET OMIT: deshabilitado en compilación** | STANDARD | — |
| S151B10FECHVAL | SALDOS FECHA VALOR | STANDARD | 500,000 |
| S151B11CANFVAL | CANCELACION DE SALDOS F. VALOR | STANDARD | 500,000 |
| S151B12CVIGVEN | SDOS. CARTERA VIGENTE Y VENCIDA — **$SET OMIT: deshabilitado en compilación** | STANDARD | — |
| S151B13AUDITORIA | (sin título literal en source) | DATA SET | 500 |
| S151B14CONOPECRUZ | (sin título literal en source) | DATA SET | 100,000 · MEMORY RESIDENT=ALL |
| S151B15MOVOPECRUZ | (sin título literal en source) | DATA SET | 100,000 · MEMORY RESIDENT=ALL |

### S151BD10MOVDIA151 — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `DASDL_S151BD10MOVDIA151.txt` (1,204 LOC). BD principal de movimientos diarios. Volumen máximo: 5 días × 52.5M movimientos = 262.5M registros por semana.
> Los sets MOVTOS son DIRECT DATA SET (acceso directo por clave). Patrón por día: B_1MOVTOS + B_2IMPADI + B_3CSISUCCAJ + B_4CSISUCCAJ.

| Dataset DMSII | Descripción literal DASDL | Tipo | POPULATION |
|---|---|---|---|
| S151B01MOVTOS | DIA LUNES semana 1 | DIRECT DATA SET | 52,500,000 |
| S151B02IMPADI | (sin título literal en source) | DATA SET | 6,000,000 |
| S151B03CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B04CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B11MOVTOS | DIA MARTES semana 1 | DIRECT DATA SET | 52,500,000 |
| S151B12IMPADI | (sin título literal en source) | DATA SET | 6,000,000 |
| S151B13CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B14CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B21MOVTOS | DIA MIERCOLES semana 1 | DIRECT DATA SET | 52,500,000 |
| S151B22IMPADI | (sin título literal en source) | DATA SET | 6,000,000 |
| S151B23CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B24CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B31MOVTOS | DIA JUEVES semana 1 | DIRECT DATA SET | 52,500,000 |
| S151B32IMPADI | (sin título literal en source) | DATA SET | 6,000,000 |
| S151B33CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B34CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B41MOVTOS | DIA VIERNES semana 1 | DIRECT DATA SET | 52,500,000 |
| S151B42IMPADI | (sin título literal en source) | DATA SET | 6,000,000 |
| S151B43CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B44CSISUCCAJ | (sin título literal en source) | DATA SET | 80,000 |
| S151B50TOTXCVE | (sin título literal en source) | DATA SET | 80,000 |
| S151B99REINICIO | **RESTART DATA SET** — B99-REI-PGM (ALPHA 18) + B99-REI-USER-INFO (ALPHA 162) | RESTART | 100 |

### S151BD11SDOS151 — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `DASDL_S151BD11SDOS151.txt` (333 LOC). BD de saldos S151.
> DEFAULTS: PACK=S067REMESAS. Globals: CSI, FEC, STA, NIVACTDIA (OCCURS 31 TIMES).
> Nota: B99 RESTART declarado pero bajo $SET OMIT — deshabilitado en compilación.

| Dataset DMSII | Descripción literal DASDL | Tipo | POPULATION |
|---|---|---|---|
| S151B20SDOMENCON | (sin título literal en source — campo B20-SDO-KEYAM ampliado a 6 dígitos tras CRONOS 2000) | DATA SET | 12,000,000 |
| S151B21SDMENCON1 | (sin título literal en source) | DATA SET | 12,000,000 |
| S151B70POSICION | (sin título literal en source) | DATA SET | 1,000,000 · PACKNAME=S067REMESAS |
| S151B71POSDIAAD1 | (sin título literal en source) | DATA SET | 1,000,000 · PACKNAME=S067REMESAS |
| S151B72POSCONTA | (sin título literal en source) | DATA SET | 1,000,000 · PACKNAME=S067REMESAS |
| S151B80EDOCTA | estado de cuenta por contrato | DATA SET | 5,000,000 |

### S151BD12MC001S151 — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `DASDL_S151BD12MC001S151.txt` (640 LOC). BD contable de movimientos por contrato.
> DEFAULTS: PACK=S067REMESAS. Tres grupos: ciclo activo (B01-B04), informativos (B11-B14), en error (B51-B54).

| Dataset DMSII | Descripción literal DASDL | Tipo | POPULATION |
|---|---|---|---|
| S151B01MOVCTO | movimientos por contrato ciclo activo | DIRECT DATA SET | 25,000,000 |
| S151B02IMPADI | importes adicionales ciclo activo | DATA SET | 12,500,000 |
| S151B03DATADI | datos adicionales ciclo activo | DATA SET | 12,500,000 |
| S151B04CONDATADI | continuación datos adicionales | DATA SET | 12,500,000 |
| S151B11MOVINFCTO | movimientos informativos por contrato | DIRECT DATA SET | 5,000,000 |
| S151B12IMPINFADI | (sin título literal en source) | DATA SET | 2,500,000 |
| S151B13DATINFADI | (sin título literal en source) | DATA SET | 2,500,000 |
| S151B14CONDATADI | (sin título literal en source) | DATA SET | 2,500,000 |
| S151B51MOVERRCTO | movimientos en error por contrato | DIRECT DATA SET | 5,000,000 |
| S151B52IMPADIERR | (sin título literal en source) | DATA SET | 2,500,000 |
| S151B53DATADIERR | (sin título literal en source) | DATA SET | 2,500,000 |
| S151B54CONDATERR | (sin título literal en source) | DATA SET | 2,500,000 |

### S151BD99CONTROL — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `DASDL_S151BD99CONTROL.txt` (538 LOC). BD de control del sistema S151.
> Globals B00: B00-GLO-CSI, B00-GLO-STAPROC, B00-GLO-FECPROC, B00-GLO-FECOPER, B00-GLO-FECULTACT (campos CRONOS 2000), B00-GLO-CONTROL1, B00-GLO-DIREC (OCCURS 20 TIMES: SISTEMA + STATUS + FEC-SIST + STATSIST).

| Dataset DMSII | Descripción literal DASDL | Tipo | POPULATION |
|---|---|---|---|
| S151B01SISDIA | información sistema por día | DATA SET | 999 |
| S151B02ARCINTER | archivos de interfaz — S028, S250, S030, S015, S050, S253, S264, S275, SSIG, S750, S136 | DATA SET | 999 |
| S151B03SISMEN | información sistema mensual — CTL-MEN (OCCURS 500 TIMES) | DATA SET | 999 |
| S151B04SISTEM | sistemas/productos/instrumentos | DATA SET | 999 |
| S151B05PROCESOS | procesos ejecutados por sistema | DATA SET | 5,000 |
| S151B09CONXSIS | conceptos por sistema | DATA SET | 999 |
| S151B10MOVPORSUC | movimientos por sucursal/caja/producto/transacción | DATA SET | 8,000,000 |
| S151B11MOVPORCTE | movimientos por cliente | DATA SET | 10,000,000 |
| S151B12POSICION | posición contable | DATA SET | 9,000 |
| S151B13AUDITORIA | auditoría — tipo búsqueda/sistema/moneda/importe/días | DATA SET | 100 |
| S151B14ARCDIAORI | archivos diarios origen | DATA SET | 100,000 |
| S151B15ARCDIADES | archivos diarios destino | DATA SET | 100 |
| S151B99REINICTL | **RESTART DATA SET** — B99-REI-PROGRAM (NUMBER 8) + B99-REI-USERINFO (ALPHA 176) | RESTART | 100 |

### S500BD01CAPTACION — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `S500_DASDL_CAPTACION.txt` (4,168 LOC). BD principal de captación. Archivo DASDL más grande de ambos sistemas.
> Nota: No existe B10 (salto B09→B11). No existe B49 (salto B48→B50). B28-B34 todos nombrados COMICOB con distintos STRUCTURE numbers.

| Dataset DMSII | Tipo | PREFIX / STRUCTURE (literal DASDL) |
|---|---|---|
| S500B00CTRLPASO | DATA SET | B00 / STR 77 |
| S500B01CONTROL | DIRECT DATA SET | B01 / STR 02 |
| S500B02CONTROL | DATA SET | B02 / STR 04 |
| S500B03CONTRATOS | DATA SET | B03 / STR 06 |
| S500B04MOVIMIENTO | DATA SET | B04 / STR 08 |
| S500B05INSTRUMEN | DATA SET | B05 / STR 12 |
| S500B06HISTORICO | DATA SET | B06 / STR 14 |
| S500B07MOVDIA | DATA SET | B07 / STR 16 |
| S500B08DEVOLUCION | DATA SET | B08 / STR 18 |
| S500B09CIFRAS | DATA SET | B09 / STR 20 |
| S500B11FVALOR | DATA SET | B11 / STR 25 |
| S500B12COMPEN | DATA SET | B12 / STR 27 |
| S500B13MOVCVES | DATA SET | B13 / STR 29 |
| S500B14TOTCVES | DATA SET | B14 / STR 31 |
| S500B15ARCHIVO | DATA SET | B15 / STR 33 |
| S500B16TABLAS | DATA SET | B16 / STR 35 |
| S500B17CVESXFUN | DIRECT DATA SET | B17 / STR 37 |
| S500B18CVESXINST | DATA SET | B18 / STR 39 |
| S500B19CANCELA | DATA SET | B19 / STR 44 |
| S500B20DEVMENSUAL | DATA SET | B20 / STR 19 |
| S500B21INTERBANC | DIRECT DATA SET | B21 / STR 26 |
| S500B22ESQCONT | DATA SET | B22 / STR 50 |
| S500B23MODULOS | DIRECT DATA SET | B23 / STR 52 |
| S500B24PAGOSPEND | DATA SET | B24 / STR 54 |
| S500B25PGOSPENDPE | DATA SET | B25 / STR 56 |
| S500B26SDOSBC | DATA SET | B26 / STR 59 |
| S500B27MOVSBC | DATA SET | B27 / STR 61 |
| S500B28COMICOB | DATA SET | B28 / STR 63 |
| S500B29COMICOB | DATA SET | B29 / STR 65 |
| S500B30COMICOB | DATA SET | B30 / STR 67 |
| S500B31COMICOB | DATA SET | B31 / STR 69 |
| S500B32COMICOB | DATA SET | B32 / STR 71 |
| S500B33COMICOB | DATA SET | B33 / STR 73 |
| S500B34COMICOB | DATA SET | B34 / STR 75 |
| S500B35NUMTEF | DATA SET | B35 / STR 79 |
| S500B36GRUPOCOM | DATA SET | B36 / STR 81 |
| S500B37GRUPOCPE | DATA SET | B37 / STR 83 |
| S500B38SUBGPOS | DATA SET | B38 / STR 86 |
| S500B39CTASCPE | DATA SET | B39 / STR 88 |
| S500B40BINGPOPREP | DATA SET | B40 / STR 93 |
| S500B41BIN | DATA SET | B41 / STR 95 |
| S500B42GPO | DATA SET | B42 / STR 97 |
| S500B43NUMGPOSOC | DATA SET | B43 / STR 99 |
| S500B44CTOSEVOL | DATA SET | B44 / STR 101 |
| S500B45GPOSOCREND | DATA SET | B45 / STR 103 |
| S500B46DIALOGO | DIRECT DATA SET | B46 / STR 105 |
| S500B47MOVDIA | DATA SET | B47 / STR 108 |
| S500B48CTOSGCE | DATA SET | B48 / STR 22 |
| S500B50LIGASTESO | DATA SET | B50 / STR 115 |
| S500B51RCTAORI | DATA SET | B51 / STR 118 |
| S500B52CTRLDEPRET | DATA SET | B52 / STR 120 |
| S500B53ENVREPLICA | DIRECT DATA SET | B53 / STR 123 |
| S500B54RECREPLICA | DIRECT DATA SET | B54 / STR 126 |
| S500B55LIMDEPRET | DATA SET | B55 / STR 129 |
| S500B56MAKERCHEK | DATA SET | (sin prefijo/estructura en source) |
| S500B57PANTASUC | DATA SET | (sin prefijo/estructura en source) |
| S500B91REINICIO | RESTART DATA SET | B91 / STR 41 |

### S500BD02AUXILIAR — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `S500_DASDL_AUXILIAR.txt` (931 LOC). BD auxiliar de proceso batch — tablas de trabajo y staging.
> Los datasets replican estructura de BD01CAPTACION con sufijo "A" en el prefijo (B01A, B02A, B03A, B21A, B26A, B46A, B47A).

| Dataset DMSII | Tipo | PREFIX / STRUCTURE (literal DASDL) |
|---|---|---|
| S500B01ACONTROL | DIRECT DATA SET | B01A / STR 02 |
| S500B02ACONTROL | DATA SET | B02A / STR 04 |
| S500B03AUXCTOS | DATA SET | B03A / STR 06 |
| S500B04AUXMOVTOS | DATA SET | B04 / STR 08 |
| S500B13AMOVCVES | DATA SET | B13 / STR 13 |
| S500B21AUXINTBCO | DIRECT DATA SET | B21A / STR 17 |
| S500B26AUXSDOSBC | DATA SET | B26A / STR 20 |
| S500B46AUXDIAL | DIRECT DATA SET | B46A / STR 22 |
| S500B47AUXMOVDIA | DATA SET | B47A / STR 25 |
| S500B52AUXCTLDEPR | DATA SET | B52 / STR 10 |
| S500B91AUXREIN | RESTART DATA SET | B91 / STR 15 |

### S500BD03MSGAAPLI — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `S500_DASDL_MSGAAPLI.txt` (219 LOC). BD de mensajes inter-aplicación (ventana de 24h).

| Dataset DMSII | Tipo | PREFIX / STRUCTURE (literal DASDL) |
|---|---|---|
| S500B00MCONTROL | DATA SET | B00M / STR 02 |
| S500B01MMOVSFM | DIRECT DATA SET | B01 / STR 04 |
| S500B91MSGREIN | RESTART DATA SET | B91 / STR 08 |

### S500BD04TARJETAS — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `S500_DASDL_TARJETAS.txt` (1,346 LOC). BD de pre-registro de tarjetas de débito.
> Nota: No existe B02P (salto de B01 a B03). Prefijos con sufijo "P" (tarjetas). B01PCONTROL usa prefijo B01M, no B01P.

| Dataset DMSII | Tipo | PREFIX / STRUCTURE (literal DASDL) |
|---|---|---|
| S500B01PCONTROL | DATA SET | B01M / STR 02 |
| S500B03PREALTAS | DATA SET | B03P / STR 03 |
| S500B04PTEF | DATA SET | B04P / STR 08 |
| S500B05PHISCTAGLB | DATA SET | B05P / STR 10 |
| S500B06PCTRLARCH | DATA SET | B06P |
| S500B07PARCHIVOS | DATA SET | B07P |
| S500B08PCTRARRIBO | DATA SET | B08P |
| S500B09PMOTOR | DATA SET | B09P |
| S500B10PDEPURA | DATA SET | B10P |
| S500B11PCVETRAARC | DATA SET | B11P |
| S500B12PCLONNING | DATA SET | (sin prefijo/estructura en source) |
| S500B13PREGCOMEPP | DATA SET | (sin prefijo/estructura en source) |
| S500B14PREGREWEPP | DATA SET | (sin prefijo/estructura en source) |
| S500B15PCTLBUCKET | DATA SET | (sin prefijo/estructura en source) |
| S500B16PLIGCTOTAJ | DATA SET | (sin prefijo/estructura en source) |
| S500B17PCTLALERTA | DATA SET | (sin prefijo/estructura en source) |
| S500B18PENVIOSDOS | DATA SET | (sin prefijo/estructura en source) |
| S500B19PSDOTAR111 | DATA SET | (sin prefijo/estructura en source) |
| S500B91PREINICIO | RESTART DATA SET | B91P / STR 06 |

### S500BD05MAPLI — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `S500_DASDL_MAPLI.txt` (323 LOC). BD de mapeo librería-aplicación. Objetivo: registro de información por paso para monitoreo de actividad.
> NOTA CRÍTICA: los datasets usan prefijo S038 (sistema MAPLI compartido con usercode S038), no S500B. PHYSICAL DATABASE: S500BD05MAPLI.

| Dataset DMSII | Descripción literal DASDL | Tipo | POPULATION |
|---|---|---|---|
| S038B01CONTROL | REGISTRO DE CONTROL — B01-NUM-NODO (NUMBER 2), B01-FEC-PROCESO (NUMBER 8), B01-NOM-EQUIPO (ALPHA 20) | DATA SET · MEMORY RESIDENT=ALL | 5 |
| S038B02PROGRAMAS | DETALLE DE PROGRAMAS — tipo/nombre/estatus PGM, tiempos inicio/fin, corrida, MIX | DATA SET · MEMORY RESIDENT=ALL | 15,000 |
| S038B03ACTIVIDAD | DETALLE DE ACTIVIDADES DE CADA PROGRAMA — B03-NOM-ACTIVIDAD (ALPHA 40), estatus, registros a procesar, tiempos | DATA SET | 300,000 |
| S038B91REINICIO | RESTART DATA SET — B91-IDPROG (ALPHA 4) + B91-USERINFO (ALPHA 26) | RESTART | 1,000 |

### S500BD06TELETON — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `S500_DASDL_TELETON.txt` (355 LOC). BD del proceso Teleton — donativos con tarjeta, evento Teleton 2016.
> Nota: No existe B03T (salto de B02T a B04T). B00T y B01T tienen MEMORY RESIDENT=ALL.

| Dataset DMSII | Descripción literal DASDL | Tipo | POPULATION |
|---|---|---|---|
| S500B00TGLOBAL | REGISTRO DE GLOBALES — B00T-NUM-CSI, B00T-FEC-LINEA, B00T-IMP-AUTORI, B00T-IMP-SUPERV, B00T-NUM-DIALOGO, B00T-PASO-ENTRA/SALE | DATA SET · MEMORY RESIDENT=ALL | 10 |
| S500B01TCONTROL | REGISTRO DE CONTROL POR CADA COPIA — B01T-NUM-COPIA, B01T-ULT-LOG, B01T-ULT-AUTS151 | DATA SET · MEMORY RESIDENT=ALL | 10 |
| S500B02TMOVTOS | DETALLE DE MOVIMIENTOS — B02T-CUENTA-TARJ, B02T-AUTORIZA, B02T-FEC-MAQUINA, B02T-CLAVE-MOVTO, B02T-IMPORTE, B02T-STA-MOVTO (00=vigente, 01=cancelado, 15=nocontable referido) | DATA SET | 1,000,000 |
| S500B04TBINES | BINES VALIDOS DE TARJETAS — B04T-NUM-BIN, B04T-NUM-EMISOR, B04T-NUM-NEGOCIO, B04T-VALIDO-TELE | DATA SET · MEMORY RESIDENT=ALL | 2,000 |
| S500B05TDIALOGO | MENSAJES ENVIADOS AL S500 O S036 (BASE 24, AUTORIZADOR) — B05T-STATUS (01-08), B05T-ORIGEN, B05T-HEADER (ALPHA 36), B05T-TEXTO (ALPHA 424) | DIRECT DATA SET | 2,000,000 |
| S500B91TREINICIO | RESTART DATA SET — B91T-PROGNAME (ALPHA 6) + B91T-JOBNO (NUMBER 4) + B91T-TASKNO (NUMBER 4) + B91T-USERINFO (ALPHA 152) | RESTART | (sin POPULATION literal) |

### S500BD07ATRIBUCTAS — Catálogo de Datasets (DASDL verificado en source)

> Archivo fuente: `S500_DASDL_ATRIBUCTA.txt` (272 LOC). BD para calificar atributos a contratos que aún no existen en S500 como cuenta ordenante — proyecto CAN 2021.
> Nota: El nombre en DMSUPPORT es S500BD07ATRIBUCTA (sin 'S' final); el nombre de registro DMSII es S500BD07ATRIBUCTA.

| Dataset DMSII | Descripción literal DASDL | Tipo | POPULATION |
|---|---|---|---|
| S500B01CONTRATOS | REGISTRO DE CONTRATOS — B01-NUM-CONTRATO (NUMBER 12), B01-GRP-NUMERICO (GROUP OCCURS 5 TIMES), B01-GRP-ALFA (GROUP OCCURS 5 TIMES), B01-IND-PANTALLA (NUMBER 4) | DATA SET · MEMORY RESIDENT=ALL | 30,000,000 |
| S500B02CONTROL | REGISTRO DE CONTROL — B02-NUM-TIPREG (NUMBER 2), B02-NUM-CSI (NUMBER 2), B02-GRP-ARC (GROUP OCCURS 5 TIMES: STA-PROCESO + FECHA-ARC + SEC-ARC + REG-ARC + ALFA-FILLER) | DATA SET | 100 |
| S500B91REINICIO | RESTART DATA SET — B91-IDPROG (ALPHA 4) + B91-USERINFO (ALPHA 26) | RESTART | 1,000 |

### ADMWIN — Header COMS de S500 (archivo: S500_SOURCE_COPY_ADMWIN.txt)

> COPY member de 127 LOC incluido en programas ONLINE de S500. Define la estructura de enrutamiento COMS entre sistemas.

Campos clave:
- `MYSELF-USERCODE`: identifica S500 como sistema origen ("S" + 500)
- `COMS-HDR-APLDES`: aplicación destino
- `COMS-HDR-CSIDES`: CSI destino (Communication System Identifier)
- `COMS-HDR-SCREEN`: pantalla destino (5 chars — ej. "15112", "00028", "00030")
- `COMS-HDR-STASUC`: sucursal origen
- `COMS-HDR-STACAJ`: caja origen
- `COMS-AMP-DESSIS`: sistema destino (3 dígitos — enruta a cualquiera de los 19 sistemas)
- `COMS-AMP-PASSER` (VA 70): número de pantalla de paso (Sistema 100 → Paso 10)

**Arquitectura de 19 sistemas**: S500 usa ADMWIN + COMS para dialogar con S151 y otros sistemas. El campo `COMS-AMP-DESSIS` (3 dígitos) permite routing a sistemas 001-999. S151 sirve como concentrador GL de los 19 sistemas origen.

---

## ESTADÍSTICAS FINALES

### Distribución LOC por categoría

| Categoría | S500 | S151 |
|-----------|------|------|
| Programas ONLINE | ~112,000 | ~103,000 |
| Programas BATCH | ~113,000 | ~236,000 |
| Librerías (fuente ALGOL/COBOL) | ~47,000 | ~57,000 |
| Includes/Copybooks | ~81,000 | — |
| DASDL | ~7,600 | ~4,100 |
| WFL | ~17,100 | ~9,400 |
| **TOTAL** | **~296,700** | **~444,900** |

### Top 10 programas por LOC

| Rank | Sistema | Archivo | LOC | Modo |
|------|---------|---------|-----|------|
| 1 | S151 | COBOL_P109 | 19,381 | BATCH |
| 2 | S151 | COBOL_P010 | 18,943 | ONLINE |
| 3 | S151 | COBOL_L030 | 19,253 | LIBRARY |
| 4 | S151 | COBOL_P151 | 17,370 | BATCH |
| 5 | S500 | S500_SOURCE_P010 | 26,328 | ONLINE |
| 6 | S500 | S500_SOURCE_P130 | 15,881 | BATCH |
| 7 | S151 | COBOL_P050 | 15,722 | ONLINE |
| 8 | S151 | COBOL_P158 | 13,694 | BATCH |
| 9 | S500 | S500_SOURCE_P142 | 14,569 | BATCH |
| 10 | S500 | S500_SOURCE_P144 | 14,497 | BATCH |

---

## NOTAS SOBRE VERSIONES MTP

| Sistema | Componente | Versión MTP | Observación |
|---------|-----------|-------------|-------------|
| S500 | WFL/LINEA (en archivo LOTE) | 24MTP005 | Versión activa del job de línea |
| S500 | WFL/REORG/GARBAGE (en archivo LINEA) | 25MTP003 | Versión de reorganización |
| S500 | WFL_REORG BD04TARJETAS | 25MTP003 | — |
| S151 | WFL/LOTE | 25MTP003 | Versión batch activa |
| S151 | WFL/LINEA | 25MTP003 | Versión online activa |
| S151 | WFL/SPLUNK | 25MTP006 | Versión más nueva — Splunk posterior a MTP003 |
| S151 | ALGOL_P810 | v0.25.6 | Versión semántica propia |

---

*Fin del documento — knowledge-base-s500-s151.md*  
*Generado por Claude Sonnet 4.6 · Accenture México · Digital Core / Software & Platform Engineering*  
*Fuente: source code extraído de producción MCP Banamex · 2026-07-11*
