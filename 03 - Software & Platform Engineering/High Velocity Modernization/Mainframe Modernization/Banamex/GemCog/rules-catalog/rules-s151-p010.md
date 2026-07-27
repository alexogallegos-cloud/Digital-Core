# Reglas P010 — GATEWAY ONLINE MOVIMIENTOS S151 (con vocabulario)
**Indexado:** ✅ 2026-07-17 — correlacionado vocab↔reglas↔capacidad (traceability-matrix.md)

> **Program-ID:** LINEA · ~18,943 LOC · Dispatcher online multi-sistema
> **ROL:** Hub que enruta peticiones a ~30 bibliotecas LIB-CONS{NNN}; gestiona fechas, seguridad, bases de datos
> **ALERTA:** Sucursal 859 hardcoded (P24), Y2K pivote año 50, HI 41/42 security toggle sin equivalente en plataformas modernas
> **Enriquecido con:** vocabulario vocab-s151.md · ente regulador · nivel de confianza · schema v2 (capacidad bancaria, frecuencia, sistemas downstream, fórmula, excepciones)
> **Rango:** RN-S151-241 a RN-S151-272 (32 reglas)

---

## Índice rápido

| RN | Título | Tipo | Regulador |
|----|--------|------|-----------|
| RN-241 | P010 como hub dispatcher — no GL | ARQUITECTURA | N/A |
| RN-242 | Tres fechas independientes por sistema (P81) | FECHA | N/A |
| RN-243 | Gate de estatus: STASIS=3/5 para operación | CONTROL-OPERACION | N/A |
| RN-244 | Modelo de autorización de sucursal: FACULTAD 1/2/3 | SEGURIDAD | CNBV |
| RN-245 | Códigos Q015{NNN} hardcodeados por pantalla | SEGURIDAD | CNBV |
| RN-246 | Toggle de seguridad en tiempo real: HI 41/42 | SEGURIDAD | CNBV |
| RN-247 | Panel 17 bloqueado para FACULTAD=1 | CONTROL-ACCESO | N/A |
| RN-248 | Sucursal 859 hardcodeada en Panel 24 | CONTROL-OPERACION | N/A |
| RN-249 | Configuración de BD por TIPBD (1-7) | CONFIGURACION | N/A |
| RN-250 | Ciclo de archivo: hasta 10 fechas históricas por sistema | RETENCION | CNBV |
| RN-251 | Restricción CSI-nodo por sistema (RESCSI) | ARQUITECTURA | N/A |
| RN-252 | MDA como dimensión del movimiento | DATO-NEGOCIO | CNBV |
| RN-253 | Y2K pivote año 50 (CRONOS2K) | DATO-FECHA | N/A |
| RN-254 | Validación de fecha: conjunto {FECCON,FECPRO} ∪ {FECPROC(1..10)} | VALIDACION | N/A |
| RN-255 | Ruteo de mensajes entre nodos CSI | ARQUITECTURA | N/A |
| RN-256 | Sistemas 1 y 66: tratamiento especial (error 99) | CONTROL-OPERACION | N/A |
| RN-257 | Flujo de vida: loop infinito UNTIL W77-FIN=1 | ARQUITECTURA | N/A |
| RN-258 | Inicialización: carga de sistemas activos + 16 CHANGE ATTRIBUTE TITLE | CONFIGURACION | N/A |
| RN-259 | Bitácora de auditoría: before/after (63b+1142b) | AUDITORIA | CNBV |
| RN-260 | Monitor de traza: HI 2/3 → W77-MONITOR=1/0 | OPERACION | N/A |
| RN-261 | Terminación ordenada: SMCOMS DISABLE PROGRAM | OPERACION | N/A |
| RN-262 | Resultado de FACULTAD: mapeo a CVE-RESOL | SEGURIDAD | N/A |
| RN-263 | Campo NIO agregado 2006-07-28 en P12/P14/P18 | DATO-NEGOCIO | N/A |
| RN-264 | Validación numérica via JUSTIFIER IN LOCSUP | VALIDACION | N/A |
| RN-265 | Panel P82: administración de 13 subsistemas de archivos batch | CONFIGURACION | N/A |
| RN-266 | Panel P83: NUMCICDIA/NUMCICMES y BDs de movimientos | CONFIGURACION | N/A |
| RN-267 | Ruteo cuenta corriente a CSI vía S016_L422_CON_XMEDIO | ARQUITECTURA | N/A |
| RN-268 | Control dinámico de bases: HI 40NNN / HI 44NNN | OPERACION | N/A |
| RN-269 | NUMCSI-HOST=32 como nodo especial | ARQUITECTURA | N/A |
| RN-270 | Sistema 264 doble excepción; sistema 501 comentado | CONTROL-OPERACION | N/A |
| RN-271 | Pantalla P01: menú de selección (1-99) | UI | N/A |
| RN-272 | Validación de supervisor (CVE-SUP): error 35 | SEGURIDAD | CNBV |

---

### RN-S151-241 — P010 es hub de consultas multi-sistema, NO motor de posting GL

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-241 |
| **Nombre** | P010 es hub de consultas multi-sistema, NO motor de posting GL |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** LINEA (P010) no registra asientos contables ni genera movimientos en el General Ledger. Su único rol es actuar como **dispatcher online**: recibe el mensaje del terminal, determina sistema y pantalla, y delega la lógica de consulta a la biblioteca LIB-CONS{NNN} correspondiente (ej. LIB-CONS0017, LIB-CONS0084, LIB-CONS0264). No existe lógica GL en su PROCEDURE DIVISION; toda lectura de datos de negocio ocurre en la biblioteca destino.

**Trigger:** Toda petición online al hub S151 que tenga pantalla definida.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-PAN-ENTNUMPAN` | 9(02) | Número de pantalla; determina la biblioteca destino |
| `WKS-ENT-ENTNUMSIS` | 9(03) | Número de sistema; participa en el routing |
| `WKS-TEXTO` | X(1884) | Buffer de mensaje del terminal (header + body) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R00-CSIORI` | CAMPO-NUM | Persistente-BD | Código del sistema origen (2 dígitos) en encabezado R00 |
| `A00-BIT-SISTEMA` | CAMPO-NUM | Efimero | Número del sistema bancario al que pertenece el registro |
| `MOVIMIENTOS` | ENTIDAD | bcop-cruzada | Movimientos contables; consulta por S500 y otros vía S151REGISTRA |

**Fórmula / pseudocódigo:**
```
RECEIVE mensaje de terminal → EXTRAER WKS-ENT-ENTNUMSIS + WKS-PAN-ENTNUMPAN
IF sistema activo (STASIS=3 OR 5) THEN
  CALL "S151LIB030 IN LIB-CONS{WKS-PAN-ENTNUMPAN}" USING WKS-TEXTO
ELSE → rechazar petición sin dispatch
```

**Excepciones documentadas:**
- Pantalla sin LIB-CONS asignado → error de linking en tiempo de ejecución (sin mensaje de negocio al usuario)
- Sistema activo en B04SISTEM pero ausente en lista CHANGE ATTRIBUTE TITLE → biblioteca no cargada en espacio del proceso

**Traza de código:**
- Línea 10824: `PERFORM 200000-PROCESO UNTIL W77-FIN = 1` — loop principal dispatcher
- Líneas 10956–11112: bloque de `CHANGE ATTRIBUTE TITLE OF "LIB-CONS{NNN}"` — catálogo de bibliotecas destino hardcodeado en inicialización
- Líneas 16049–16189: cadena de `IF WKS-SIS-NUME = {NNN}` → `CALL "S151LIB030 IN LIB-CONS{NNN}"` — dispatch en tiempo de ejecución

**Riesgos de migración:** En arquitectura target (microservicios), P010 debe reimplementarse como **API Gateway / BFF** con tabla de routing dinámica; las llamadas `CHANGE ATTRIBUTE TITLE` (enlace tardío Unisys) no tienen equivalente directo — requieren service registry o mapa de routing externo. Los ~30 LIB-CONS son los microservicios de consulta target.

**Estado validación:** pendiente HITL

---

### RN-S151-242 — Tres fechas independientes por sistema: FECPRO, FECCON y FEC151

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-242 |
| **Nombre** | Tres fechas independientes por sistema: FECPRO, FECCON y FEC151 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | FECHA |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada sistema registrado en el hub mantiene **tres fechas de proceso independientes** administradas vía Pantalla 81: (1) `FECPRO` — fecha de proceso del día corriente; (2) `FECCON` — fecha de contabilización oficial del asiento GL; (3) `FEC151` — fecha interna propia del sistema 151. Estas tres fechas pueden diferir entre sí y se gestionan por separado, lo que permite reconciliaciones asíncronas entre el procesamiento operativo y el cierre contable.

**Trigger:** Operador accede a Pantalla P81 (Administración) para actualizar fechas del sistema seleccionado.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-ENT-P81FECCON` | 9(08) | Fecha de contabilización — entrada P81 (línea 1283) |
| `WKS-ENT-P81FEC151` | 9(08) | Fecha interna S151 — entrada P81 (línea 1286) |
| `WKS-ENT-P84FECPRO` | 9(08) | Fecha de proceso — entrada P84 (línea 1405) |
| `WKS-SAL-P81FECCON` | 9(08) | Fecha de contabilización — salida display P81 (línea 2861) |
| `WKS-SAL-P81FEC151` | 9(08) | Fecha interna S151 — salida display P81 (línea 2862) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R01-FECCONT` | CAMPO-COMP | Interfaz-Externo | Fecha contable AAAAMMDD; determina el período contable CNBV |
| `A00-R00-PUN-FECPRO` | CAMPO-COMP | Persistente-BD | Fecha de proceso AAAAMMDD del encabezado inter-sistemas |
| `500-R01-FECPRO` | CAMPO-NUM | Interfaz-Externo | Fecha de proceso del lote en la interfaz S500 |

**Fórmula / pseudocódigo:**
```
P84: operador ingresa FECPRO (fecha operativa del día)
P81: operador ingresa FECCON (fecha contable GL) + FEC151 (fecha interna S151)
     + slots FECARC(1..10) de fechas históricas archivadas
Las tres fechas son independientes y pueden diverger entre sí
```

**Excepciones documentadas:**
- FECCON > FECPRO → asiento contable en período futuro (caso válido de ajuste diferido entre días)
- FEC151 ≠ FECCON → divergencia entre fecha interna S151 y fecha contable oficial; complicación en reconciliación CNBV

**Traza de código:**
- Línea 1283: `WKS-ENT-P81FECCON PIC 9(08)` — campo FECCON en formato de entrada de P81
- Línea 1286: `WKS-ENT-P81FEC151 PIC 9(08)` — campo FEC151 en formato de entrada de P81
- Línea 1405: `WKS-ENT-P84FECPRO PIC 9(08)` — campo FECPRO en formato de P84

**Riesgos de migración:** El manejo de tres fechas desacopladas complica la integridad referencial en target. En arquitectura cloud-native con base de datos relacional, las tres fechas deben modelarse explícitamente en el esquema de cada sistema para evitar asumir que "fecha proceso = fecha contable".

**Estado validación:** pendiente HITL

---

### RN-S151-243 — Gate de estatus de sistema: STASIS=3 para operación normal (STASIS=5 alternativo)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-243 |
| **Nombre** | Gate de estatus de sistema: STASIS=3 para operación normal (STASIS=5 alternativo) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONTROL-OPERACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El hub P010 solo enruta peticiones a sistemas cuyo `WKS-TAB-STASIS` sea igual a **3** (operación normal) o **5** (alternativo activo). Sistemas con STASIS diferente son excluidos del routing online. El valor de estatus se carga desde el dataset `B04SISTEM` durante la inicialización y se puede modificar vía Pantalla P86.

**Trigger:** Cada petición de consulta online; evaluación de STASIS en la tabla de sistemas cargada en memoria.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-TAB-STASIS` | 9(04) COMP | Tabla de estatus por sistema — OCCURS implícito por W77-J (línea 10414) |
| `WKS-ENT-P86STASIS` | 9(02) | Valor de estatus ingresado en P86 — modificación manual (línea 1460) |
| `WKS-B04-ESTATUS` | — | Estatus leído del dataset B04SISTEM |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `PD` | ACCION | dominio | Proceso Diario — ciclo batch que puede alterar el STASIS al cerrar el día |
| `SISTEMA` | — | — | Cada sistema con STASIS propio en B04SISTEM |

**Fórmula / pseudocódigo:**
```
FOR cada sistema S cargado desde B04SISTEM:
  IF WKS-TAB-STASIS(S) = 3 → sistema en operación normal; habilitar routing
  ELSE IF WKS-TAB-STASIS(S) = 5 → modo alternativo activo; habilitar routing
  ELSE → excluir sistema del dispatch online
```

**Excepciones documentadas:**
- STASIS=5 permite ruteo igual que STASIS=3 en algunos paths (línea 17314) pero no en todos los flujos del hub
- Modificación manual vía P86 en producción sin control de cambios puede dejar sistemas fuera de operación sin alerta

**Traza de código:**
- Línea 10414: `WKS-TAB-STASIS PIC 9(04) COMP` — declaración de la tabla de estatus
- Línea 16030: `IF WKS-TAB-STASIS(W77-I) = 3` — condición de operación normal
- Línea 17314: `(WKS-TAB-STASIS(W77-J) = 3 OR 5)` — condición compuesta que permite STASIS alternativo
- Línea 17390, 17544, 17633, 17937, 18115: usos adicionales del mismo gate

**Riesgos de migración:** El concepto de STASIS debe mapearse a un campo de estado en el catálogo de sistemas del target (ej. `system_status: ACTIVE | ALTERNATE | CLOSED`). Los valores 3 y 5 no son auto-descriptivos — su semántica debe documentarse como invariante de negocio antes de la transpilación.

**Estado validación:** pendiente HITL

---

### RN-S151-244 — Modelo de autorización de sucursal: FACULTAD 1/2/3

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-244 |
| **Nombre** | Modelo de autorización de sucursal: FACULTAD 1/2/3 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | SEGURIDAD |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Disposiciones de carácter general aplicables a las instituciones de crédito (CUB) — segregación de funciones y controles de acceso por perfil |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El paragraph `300010-CHECA-ENTIDAD` evalúa el campo `W77-FACULTAD` para determinar el nivel de autorización de la sucursal operadora respecto al sistema consultado: **FACULTAD=1** limita la operación a la propia sucursal de captura; **FACULTAD=2** autoriza consulta cross-sucursal; **FACULTAD=3** niega el acceso con error de seguridad (mensaje 87). El valor de FACULTAD se recupera de las tablas `WKS-TAB-FAC`, `WKS-TAB1-FAC` ... `WKS-TAB4-FAC` indexadas por (sucursal, sistema).

**Trigger:** Cada petición online; se invoca `300010-CHECA-ENTIDAD` desde el procesador de mensaje (línea 11998).

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `W77-FACULTAD` | 9(04) | Nivel de facultad de la sucursal para el sistema — 1/2/3 (línea 10324) |
| `WKS-TAB-FAC` | — | Tabla [sucursal, sistema] → FACULTAD, rango sucursal 1-999 (línea 12196) |
| `WKS-TAB1-FAC` | — | Tabla [sucursal-999, sistema] → FACULTAD, rango 1000-1999 (línea 12202) |
| `WKS-TAB2-FAC` | — | Tabla rango 2000-2999 (línea 12208) |
| `WKS-TAB3-FAC` | — | Tabla rango 3000-3999 (línea 12215) |
| `WKS-TAB4-FAC` | — | Tabla rango 4000-4999 (línea 12221) |
| `W77-CVE-RESOL` | 9(04) | Resultado de la evaluación de FACULTAD (línea 10325) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-BIT-SISTEMA` | CAMPO-NUM | Efimero | Sistema sobre el que aplica la restricción de FACULTAD |
| `POSICION` | ENTIDAD | dominio | Dataset clave SISTEMA+CSI: FACULTAD determina acceso cross-CSI |

**Fórmula / pseudocódigo:**
```
PERFORM 300010-CHECA-ENTIDAD:
  IF FACULTAD = 1 → sucursal propia: CVE-RESOL=1; otra sucursal o P17: CVE-RESOL=3 + MSG=87
  IF FACULTAD = 2 → CVE-RESOL = 1 (cross-sucursal autorizado)
  IF FACULTAD = 3 → CVE-RESOL = 3 + MSG = 87 (denegado)
```

**Excepciones documentadas:**
- Sucursal fuera del rango 1-4999 → sin entrada en tabla WKS-TABn-FAC; FACULTAD con valor indeterminado
- FACULTAD=1 + pantalla ≠ 17 + sucursal propia → acceso permitido (CVE-RESOL=1); combinación válida

**Traza de código:**
- Línea 12139: `300010-CHECA-ENTIDAD.` — paragraph de inicio
- Línea 12174: `IF W77-FACULTAD = 1` → pantalla 17 bloqueada (RN-247) y solo sucursal propia
- Línea 12185: `IF W77-FACULTAD = 2` → `MOVE 1 TO W77-CVE-RESOL` — acceso autorizado
- Línea 12188: `IF W77-FACULTAD = 3` → `MOVE 3 TO W77-CVE-RESOL` + `MOVE 87 TO W77-RES-MSG` — denegado
- Línea 11998: `PERFORM 300010-CHECA-ENTIDAD` — punto de invocación

**Riesgos de migración:** La lógica de FACULTAD está embebida en tablas en memoria de hasta 5000 sucursales × 30 sistemas. En target, debe externalizarse como servicio de autorización (OAuth2 scope / RBAC) con la misma granularidad sucursal×sistema. El mapeo exacto de FACULTAD 1/2/3 a roles target requiere validación HITL con el equipo de seguridad de Banamex.

**Estado validación:** pendiente HITL

---

### RN-S151-245 — Códigos de transacción de seguridad hardcodeados Q015{NNN} por pantalla

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-245 |
| **Nombre** | Códigos de transacción de seguridad hardcodeados Q015{NNN} por pantalla |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | SEGURIDAD |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CUB — registro de facultades y control de acceso por transacción |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada pantalla del hub tiene asignado un código de transacción de seguridad `Q015{NNN}` hardcodeado en el COBOL. Estos códigos son consultados contra el sistema de seguridad `SEGURIDAD` vía `VALIDA_FACULTAD` para determinar si el usuario tiene permiso de operar la pantalla. El catálogo completo cubre pantallas 111–130C (consultas estándar) y pantallas 181A/B/M/C (administración). El código `Q015130C` identifica la pantalla de administración compuesta.

**Trigger:** Por cada pantalla solicitada, antes del dispatch a LIB-CONS{NNN}.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WS-FAC-CVETRAN` | X(08) | Código Q015{NNN} de la transacción de seguridad — MOVE literal (líneas 11552+) |
| `W77-VALIDA-SEG` | 9(02) | Flag de activación de validación de seguridad (línea 10267) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-BIT-CVE-PANTALLA` | — | — | Clave de pantalla almacenada en bitácora para trazabilidad |

**Fórmula / pseudocódigo:**
```
MOVE "Q015{NNN}" TO WS-FAC-CVETRAN según número de pantalla activa
IF W77-VALIDA-SEG = 1 THEN
  CALL "VALIDA_FACULTAD IN SEGURIDAD" USING WS-FAC-CVETRAN
  IF NOT autorizado → denegar acceso a pantalla
```

**Excepciones documentadas:**
- W77-VALIDA-SEG = 2 (toggle HI 42 activo) → código Q015 no se verifica; bypass de seguridad sin trazabilidad
- Pantallas de administración 181A/B/M/C tienen códigos Q015 distintos del rango estándar 111-130

**Traza de código:**
- Línea 11552: `MOVE "Q015111" TO WS-FAC-CVETRAN` — pantalla 11 día actual
- Línea 11576: `MOVE "Q015112" TO WS-FAC-CVETRAN` — pantalla 12
- Línea 11974: `MOVE "Q015130C" TO WS-FAC-CVETRAN` — pantalla compuesta P130C
- Línea 11944–11969: Q015181 (A/B/M/C/186/187/188) — pantallas de administración
- Líneas 16649–16807: segundo bloque de asignaciones Q015 en flujo alternativo

**Riesgos de migración:** Los códigos Q015{NNN} son contratos de seguridad con el sistema `SEGURIDAD` de Banamex. En target, deben mapearse a claims/scopes de autorización. El catálogo completo debe exportarse antes de la transpilación para no perder la cobertura de 25+ pantallas. Riesgo de compliance si algún código se omite en la migración.

**Estado validación:** pendiente HITL

---

### RN-S151-246 — Toggle de seguridad en tiempo de ejecución: HI 41/42 → W77-VALIDA-SEG=1/2

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-246 |
| **Nombre** | Toggle de seguridad en tiempo de ejecución: HI 41/42 → W77-VALIDA-SEG=1/2 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | SEGURIDAD |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CUB — trazabilidad de cambios a controles; riesgo de compliance si se deshabilita en producción |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El operador de sistemas puede habilitar (`HI 41` → `W77-VALIDA-SEG=1`) o deshabilitar (`HI 42` → `W77-VALIDA-SEG=2`) la validación de seguridad en **tiempo de ejecución** sin reinicio del programa. Este mecanismo es una función de soporte operativo que permite bypass de seguridad para pruebas o emergencias, pero representa un riesgo de compliance severo si se usa en producción sin controles compensatorios documentados.

**Trigger:** El operador envía una señal HI (High Interrupt) al proceso online activo.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `W77-VALIDA-SEG` | 9(02) | Flag de estado de seguridad: 1=habilitada, 2=deshabilitada (línea 10267) |
| `W77-HI-INTERRUPT` | — | Variable de interrupción que porta el código HI |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-BIT-TIPO-OPERACION` | CAMPO-ALFA | Efimero | Tipo de operación auditada; debe reflejar si seguridad estaba activa |

**Fórmula / pseudocódigo:**
```
ON HI 41 → MOVE 1 TO W77-VALIDA-SEG  (seguridad habilitada)
ON HI 42 → MOVE 2 TO W77-VALIDA-SEG  (seguridad deshabilitada)
IF W77-VALIDA-SEG = 1 → ejecutar validación Q015 por pantalla (RN-245)
```

**Excepciones documentadas:**
- Toggle no persiste al reiniciar LINEA; valor inicial declarado = 0 (estado sin validación en arranque)
- No hay registro en bitácora de cuándo se activó/desactivó el toggle ni la identidad del operador que lo hizo

**Traza de código:**
- Línea 10267: `77 W77-VALIDA-SEG PIC 9(02)` — declaración
- Línea 10659: `MOVE 1 TO W77-VALIDA-SEG` — habilitar (HI 41)
- Línea 10665: `MOVE 2 TO W77-VALIDA-SEG` — deshabilitar (HI 42)
- Línea 11452: `MOVE 2 TO W77-VALIDA-SEG` / línea 11454: `MOVE 1 TO W77-VALIDA-SEG` — uso en flujo alternativo
- Líneas 10805–10806: `DISPLAY "HI 41 -> HABILITIDA SEGURIDAD"` / `"HI 42 -> DESHABILITA SEGURIDAD"`

**Riesgos de migración:** Plataformas modernas no tienen mecanismo equivalente de HI. En target, si se requiere bypass de seguridad de emergencia, debe implementarse como feature flag auditado con registro en bitácora obligatorio y aprobación de 2 personas (four-eyes). El toggle actual es no trazable en la bitácora operativa.

**Estado validación:** pendiente HITL

---

### RN-S151-247 — Panel 17 (Totales Nacionales): bloqueado para FACULTAD=1

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-247 |
| **Nombre** | Panel 17 (Totales Nacionales): bloqueado para FACULTAD=1 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONTROL-ACCESO |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Control interno — segregación de información por nivel de facultad |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La Pantalla P17 (Totales Nacionales — vista consolidada de movimientos a nivel nacional) está explícitamente bloqueada para operadores con `FACULTAD=1` (acceso solo a sucursal propia). Cuando FACULTAD=1 y el número de pantalla es 17, se establece `W77-CVE-RESOL=3` y se emite el mensaje de error 87 (SEG; NIVEL DE FACULTADES INSUFICIENTE). Esta restricción evita que cajeros o tellers de sucursal accedan a información de totales nacionales.

**Trigger:** Solicitud de pantalla P17 por un usuario con FACULTAD=1.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-PAN-ENTNUMPAN` | 9(02) | Número de pantalla; valor 17 activa el bloqueo |
| `W77-FACULTAD` | 9(04) | Nivel de facultad; valor 1 activa el bloqueo |
| `W77-CVE-RESOL` | 9(04) | Resultado: 3 = acceso denegado |
| `W77-RES-MSG` | — | Código de mensaje: 87 = nivel insuficiente |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `POSICION` | ENTIDAD | dominio | Dataset consolidado; FACULTAD=1 no debe ver posición nacional |

**Fórmula / pseudocódigo:**
```
IF WKS-PAN-ENTNUMPAN = 17 AND W77-FACULTAD = 1 THEN
  MOVE 3 TO W77-CVE-RESOL
  MOVE 87 TO W77-RES-MSG → acceso denegado (totales nacionales)
```

**Excepciones documentadas:**
- FACULTAD=3 también deniega P17 (deniega acceso a toda pantalla del hub)
- No existe excepción de superusuario; solo FACULTAD=2 permite ver P17 sin error 87

**Traza de código:**
- Línea 12174: `IF W77-FACULTAD = 1`
- Línea 12175: `IF WKS-PAN-ENTNUMPAN = 17`
- Línea 12176: `MOVE 3 TO W77-CVE-RESOL`
- Línea 12177: `MOVE 87 TO W77-RES-MSG`

**Riesgos de migración:** En target, esta restricción debe implementarse como control de autorización en la capa de API Gateway antes del dispatch, no en la lógica de negocio del microservicio. El número de pantalla 17 debe mapearse a un recurso/endpoint específico con scope de acceso definido.

**Estado validación:** pendiente HITL

---

### RN-S151-248 — Sucursal 859 hardcodeada en Panel 24 → W77-SUC-CAPTURA=859

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-248 |
| **Nombre** | Sucursal 859 hardcodeada en Panel 24 → W77-SUC-CAPTURA=859 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONTROL-OPERACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Control interno — sucursal especial de proceso centralizado |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando el usuario opera en el Panel P24 (seleccionado por número de sistema específico), el campo `W77-SUC-CAPTURA` se fija al valor **859** directamente en código, sin leer de parámetro ni tabla. La sucursal 859 es presumiblemente un centro de proceso centralizado o sucursal virtual de concentración. Esta asignación hace que para P24, la validación de facultad `FACULTAD=1` (solo sucursal propia) se resuelva siempre en modo centralizado. También aparece en combinación con `SIS-NUME=264` como excepción de enrutamiento (RN-270).

**Trigger:** Selección de pantalla P24 para el sistema correspondiente.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `W77-SUC-CAPTURA` | 9(04) | Sucursal de captura activa — fijada en 859 para P24 (línea 10086) |
| `WKS-ENT-P24SIS` | — | Sistema seleccionado en P24 (línea 11811) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-BIT500-MDA-SUC` | CAMPO-NUM | Efimero | Número de sucursal de moneda; la 859 se configura como sucursal centralizada |

**Fórmula / pseudocódigo:**
```
IF pantalla activa = P24 THEN
  MOVE 859 TO W77-SUC-CAPTURA  (hardcoded; sin parámetro externo)
→ validaciones de FACULTAD=1 operan como si sucursal de captura = 859
```

**Excepciones documentadas:**
- SIS-NUME=264 AND SUC-NUME=859 → excepción adicional de enrutamiento cross-CSI (RN-270)
- Valor 859 no parametrizable; cambio de sucursal centralizada requiere recompilación del programa LINEA

**Traza de código:**
- Línea 10086: `77 W77-SUC-CAPTURA PIC 9(04)` — declaración
- Línea 11811: `MOVE WKS-SIS-NUME TO WKS-ENT-P24SIS / W77-SIS-CAPTURA`
- Línea 11813: `MOVE 859 TO W77-SUC-CAPTURA` — hardcode de sucursal
- Línea 16531: `WKS-SIS-NUME = 264 AND WKS-SUC-NUME = 859` — uso en excepción de enrutamiento

**Riesgos de migración:** Valor hardcodeado que debe externalizarse como parámetro de configuración en target. La semántica exacta de la sucursal 859 (¿oficina central? ¿proceso nocturno?) debe validarse con SME de negocio antes de la migración para evitar errores de enrutamiento de cuentas.

**Estado validación:** pendiente HITL

---

### RN-S151-249 — Configuración de bases de datos por TIPBD (1-7): tabla BD10/BD11/BD12/BD13

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-249 |
| **Nombre** | Configuración de bases de datos por TIPBD (1-7): tabla BD10/BD11/BD12/BD13 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONFIGURACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo `WKS-B03-TIPBD` (valores 1-7) determina qué combinación de bases de datos de movimientos (BD10, BD11, BD12, BD13) está activa para cada sistema. La lógica sigue una codificación bit-mask: TIPBD=1 activa las cuatro; TIPBD=2 activa BD10+BD11; TIPBD=3 activa BD10+BD12; TIPBD=4 activa BD10+BD13; TIPBD=5 activa BD10+BD11+BD12; TIPBD=6 activa BD10+BD11+BD13; TIPBD=7 activa BD10+BD12+BD13. BD10 siempre está activa (base de movimientos del día).

**Trigger:** Inicialización del sistema; carga desde dataset B03 vía Pantalla P83.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-B03-TIPBD` | 9(02) | Tipo de BD activas para el sistema (línea 3752) |
| `WKS-TAB-CONFBD10` | 9(01) COMP | Flag BD10 activa por sistema (línea 10440) |
| `WKS-TAB-CONFBD11` | 9(01) COMP | Flag BD11 activa por sistema (línea 10441) |
| `WKS-TAB-CONFBD12` | 9(01) COMP | Flag BD12 activa por sistema (línea 10442) |
| `WKS-TAB-CONFBD13` | 9(01) COMP | Flag BD13 activa por sistema (línea 10443) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `MOVIMIENTOS` | ENTIDAD | bcop-cruzada | BD10MOVDIA151 almacena todos los movimientos del día |
| `SALDO` | ENTIDAD | bcop-cruzada | BD02ADSALDO y BD11SDOS151 almacenan saldos |

**Fórmula / pseudocódigo:**
```
MOVE 1 TO WKS-TAB-CONFBD10  (BD10 siempre activa, sin condición)
IF TIPBD IN (1,2,5,6) → MOVE 1 TO WKS-TAB-CONFBD11
IF TIPBD IN (1,3,5,7) → MOVE 1 TO WKS-TAB-CONFBD12
IF TIPBD IN (1,4,6,7) → MOVE 1 TO WKS-TAB-CONFBD13
```

**Excepciones documentadas:**
- TIPBD=0 o >7 → estado indefinido; ningún IF-ELSE lo cubre; BD11/12/13 quedan en estado inicial (inactivas)
- BD10 no puede desactivarse vía TIPBD (siempre forzada a CONFBD10=1 sin condición)

**Traza de código:**
- Línea 3752: `WKS-B03-TIPBD PIC 9(02)` — campo de configuración en dataset B03
- Línea 11138: `MOVE 1 TO WKS-TAB-CONFBD10(W77-APU-SIS)` — BD10 siempre activa
- Línea 11139: `IF WKS-B03-TIPBD = 1 OR 2 OR 5 OR 6 THEN MOVE 1 TO WKS-TAB-CONFBD11`
- Línea 11142: `IF WKS-B03-TIPBD = 1 OR 3 OR 5 OR 7 THEN MOVE 1 TO WKS-TAB-CONFBD12`
- Línea 11145: `IF WKS-B03-TIPBD = 1 OR 4 OR 6 OR 7 THEN MOVE 1 TO WKS-TAB-CONFBD13`

**Riesgos de migración:** La codificación TIPBD 1-7 es una máscara de bits implícita sin nombre semántico. En target debe mapearse a flags explícitos o configuración de shards de datos. La tabla de configuración en memoria debe reemplazarse por configuración en base de datos con hot-reload.

**Estado validación:** pendiente HITL

---

### RN-S151-250 — Ciclo de archivo: hasta 10 fechas de proceso históricas por sistema (FECARC/NIVARC/NIVBD/STA 1-10)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-250 |
| **Nombre** | Ciclo de archivo: hasta 10 fechas de proceso históricas por sistema (FECARC/NIVARC/NIVBD/STA 1-10) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | RETENCION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Ley de Instituciones de Crédito Art. 56 — retención de información 7 años; CUB sobre archivo de información contable |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El dataset B01 mantiene hasta **10 fechas de proceso archivadas** por sistema (`WKS-B01-FECARCMOV(1..10)`), cada una con su nivel de archivo (`NIVARC`), nivel de base de datos (`NIVBD`) y estatus (`STA`). Esto permite consultas históricas de movimientos a fechas anteriores a la actual, con ventana de hasta 10 días de proceso. Las fechas > ZEROS se cargan en la tabla `WKS-TAB-FECPROC(sistema, fecha_idx)` durante la inicialización.

**Trigger:** Consultas históricas de movimientos en pantallas P02, P04 y similares de "días anteriores".

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-B01-FECARCMOV` | 9(08) OCCURS 10 | Fechas de archivo de movimientos (línea 3394) |
| `WKS-B01-NIVARCMOV` | 9(08) OCCURS 10 | Niveles de archivo (línea 3395) |
| `WKS-B01-NIVBDMOV` | 9(08) OCCURS 10 | Niveles de base de datos (línea 3396) |
| `WKS-TAB-FECPROC` | 9(08) COMP | Tabla bidimensional [sistema, 1..10] de fechas procesadas (línea 10417) |
| `WKS-ENT-P81FECARC` | 9(08) | Campo de entrada de FECARC en P81 — 10 ocurrencias (línea 1304) |
| `WKS-ENT-P81NIVARC` | 9(08) | Campo de entrada NIVARC en P81 (línea 1305) |
| `WKS-ENT-P81NIVBD` | 9(08) | Campo de entrada NIVBD en P81 (línea 1306) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `MOVIMIENTOS` | ENTIDAD | bcop-cruzada | BD10MOVDIA151 almacena movimientos del día; historial en fechas archivadas |
| `PD` | ACCION | dominio | Proceso Diario — genera el ciclo de archivo al cerrar el día |

**Fórmula / pseudocódigo:**
```
FOR j = 1 TO 10:
  IF WKS-B01-FECARCMOV(j) > ZEROS THEN
    MOVE FECARCMOV(j) TO WKS-TAB-FECPROC(sistema, j)
→ ventana de hasta 10 días históricos disponibles por sistema
```

**Excepciones documentadas:**
- Slot con FECARC=0 → no cargado en tabla; consulta de esa fecha histórica devuelve "sin dato" (sin error explícito)
- El límite de 10 fechas es fijo en el OCCURS; un 11° día histórico no tiene slot y no puede consultarse online

**Traza de código:**
- Línea 3394: `WKS-B01-FECARCMOV PIC 9(08)` — primero de los 10 slots de fecha
- Línea 10417: `WKS-TAB-FECPROC PIC 9(08) COMP` — tabla de fechas en memoria
- Línea 11148: `IF WKS-B01-FECARCMOV(W77-J) > ZEROS` — condición de carga
- Línea 11150: `MOVE WKS-B01-FECARCMOV(W77-J) TO WKS-TAB-FECPROC(W77-APU-SIS W77-J)` — carga

**Riesgos de migración:** La ventana de 10 fechas en memoria debe mapearse a una política de retención explícita en el data store target. Las consultas históricas deben resolverse contra particiones o índices de fecha en la BD target, no contra archivos físicos de disco como en Unisys.

**Estado validación:** pendiente HITL

---

### RN-S151-251 — Restricción CSI-nodo por sistema (RESCSI = NUMCSI-HOST)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-251 |
| **Nombre** | Restricción CSI-nodo por sistema (RESCSI = NUMCSI-HOST) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo `WKS-B03-RESCSI` define a qué nodo CSI (Centro de Servicios Informáticos) está restringido cada sistema. Cuando `RESCSI = WKS-NUMCSI-HOST` (nodo local), el sistema solo puede ser consultado desde ese nodo. Este mecanismo implementa la topología distribuida de la red Unisys de Banamex, donde cada CSI es un nodo físico de cómputo. La restricción se evalúa en el routing para determinar si la petición puede ser procesada localmente o debe redirigirse.

**Trigger:** Cada petición online; evaluación de restricción de nodo antes del dispatch.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-B03-RESCSI` | 9(02) | CSI al que está restringido el sistema (línea 3751) |
| `WKS-NUMCSI-HOST` | 9(02) | Número del CSI local donde corre P010 (línea 10136) |
| `WKS-TAB-CSIRES` | — | Tabla de restricciones CSI por sistema (línea 11125) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R00-CSIORI` | CAMPO-NUM | Persistente-BD | CSI de origen en encabezado del mensaje |
| `A00-BIT264-CSI-DEST` | CAMPO-NUM | Efimero | CSI destino de la transacción |
| `POSICION` | ENTIDAD | dominio | Clave incluye CSI: SISTEMA+CSI+FECHA+PRODUCTO+INSTSERV+MONEDA |

**Fórmula / pseudocódigo:**
```
IF WKS-B03-MODSIS = 0 OR WKS-B03-RESCSI = WKS-NUMCSI-HOST THEN
  → sistema disponible localmente; proceder con dispatch
ELSE
  → sistema restringido a otro nodo CSI; redirigir petición
```

**Excepciones documentadas:**
- MODSIS=0 sobreride la restricción CSI (sistema configurado sin restricción de nodo activa)
- Sistema sin RESCSI configurado → comportamiento según valor por defecto del campo en B03; riesgo de restricción inválida

**Traza de código:**
- Línea 3751: `WKS-B03-RESCSI PIC 9(02)` — campo de restricción en dataset B03
- Línea 10914: `WKS-B03-RESCSI = WKS-TAB-CSIRES(W77-CTL-SIS)` — comparación de restricción
- Línea 10926: `(WKS-B03-MODSIS = 0 OR WKS-B03-RESCSI = WKS-NUMCSI-HOST)` — condición de operación local
- Línea 11125: `MOVE WKS-B03-RESCSI TO WKS-TAB-CSIRES(W77-APU-SIS)` — carga en tabla

**Riesgos de migración:** El concepto de CSI como nodo físico no tiene equivalente en microservicios cloud. En target, la restricción por CSI debe mapearse a zonas de disponibilidad, regiones o affinity rules del cluster. La topología de red de CSIs debe documentarse antes de la migración para no perder la semántica de localidad.

**Estado validación:** pendiente HITL

---

### RN-S151-252 — MDA (Medio de Acceso) como dimensión del movimiento: CVEMDA(2)+SUCMDA(4)+NUMMDA(16)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-252 |
| **Nombre** | MDA (Medio de Acceso) como dimensión del movimiento: CVEMDA(2)+SUCMDA(4)+NUMMDA(16) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DATO-NEGOCIO |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CUB — desglose por canal en reportes de transacciones; estadísticas de medios de pago |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El "Medio de Acceso" (MDA) es una dimensión de 22 bytes que identifica el canal por el que se originó el movimiento: clave de moneda del medio (`CVEMDA`, 2 dígitos), sucursal del medio (`SUCMDA`, 4 dígitos) y número del medio (`NUMMDA`, 16 dígitos). Esta dimensión aparece en las pantallas P18, P19 y P20 de consulta de movimientos. El MDA permite clasificar transacciones por canal (sucursal, ATM, SPEI, etc.) para fines de reporte regulatorio.

**Trigger:** Consultas de movimientos que incluyen dimensión de canal (P18: movimientos x medio, P19/P20 variantes).

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-ENT-P18CVEMDA` | 9(02) | Clave de moneda del medio — entrada P18 (línea 813) |
| `WKS-ENT-P18SUCMDA` | 9(04) | Sucursal del medio — entrada P18 (línea 816) |
| `WKS-ENT-P18NUMMDA` | 9(16) | Número del medio — entrada P18 (línea 819) |
| `WKS-SAL-P18CVEMDA` | 9(02) | CVEMDA en salida display (línea 2267) |
| `WKS-SAL-P18SUCMDA` | Z(04) | SUCMDA en salida (línea 2268) |
| `WKS-SAL-P18NUMMDA` | Z(16) | NUMMDA en salida (línea 2269) |
| `WKS-ENT-P19CVEMDA` | 9(02) | Variante P19 (línea 863) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-BIT-CVEMDA` | CAMPO-NUM | Efimero | Clave de moneda de abono del movimiento en bitácora GL |
| `A00-BIT264-CVEMDA` | CAMPO-NUM | Efimero | Clave de modalidad de moneda (4 dígitos) en bitácora 264 |
| `A00-BIT500-CVEMDA` | CAMPO-NUM | Efimero | Clave de modalidad de moneda en bitácora S500 |
| `A00-BIT-NUMMDA` | CAMPO-NUM | Efimero | Número de moneda del movimiento (20 dígitos) |

**Fórmula / pseudocódigo:**
```
UNSTRING buffer INTO CVEMDA(2) || SUCMDA(4) || NUMMDA(16)
CALL biblioteca P18/P19/P20 con MDA como filtro de canal de acceso
→ consulta de movimientos filtrada por canal (sucursal/ATM/SPEI)
```

**Excepciones documentadas:**
- NUMMDA(16) puede contener número de tarjeta en canales digitales → riesgo PCI-DSS; requiere análisis antes de migrar
- Tamaños de campos CVEMDA/SUCMDA/NUMMDA pueden diferir entre salidas de P18/P19/P20 (P19 sin NUMMDA full)

**Traza de código:**
- Línea 813: `WKS-ENT-P18CVEMDA PIC 9(02)` — declaración CVEMDA pantalla 18
- Línea 816: `WKS-ENT-P18SUCMDA PIC 9(04)` — declaración SUCMDA
- Línea 819: `WKS-ENT-P18NUMMDA PIC 9(16)` — declaración NUMMDA
- Líneas 11701–11703: `UNSTRING ... INTO ... WKS-ENT-P18CVEMDA-A, WKS-ENT-P18SUCMDA-A, WKS-ENT-P18NUMMDA-A` — parsing del buffer

**Riesgos de migración:** La estructura MDA de 22 bytes debe modelarse como un tipo de dato compuesto en el schema target. El campo NUMMDA de 16 dígitos podría contener el número de tarjeta o cuenta CLABE en canales digitales — requiere análisis de valores reales antes de la migración para determinar si requiere enmascaramiento PCI-DSS.

**Estado validación:** pendiente HITL

---

### RN-S151-253 — Y2K pivote año 50 (CRONOS2K): A2K-BASE-YEAR=50; sentinel 999999=sin fecha

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-253 |
| **Nombre** | Y2K pivote año 50 (CRONOS2K): A2K-BASE-YEAR=50; sentinel 999999=sin fecha |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DATO-FECHA |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — riesgo técnico de migración |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El copybook CRONOS2K implementa la solución Y2K de Unisys con una regla de pivote: años de 2 dígitos (`AA`) menores a **50** se interpretan como siglo 20XX; años ≥ 50 se interpretan como 19XX. Esta lógica se aplica en las rutinas `A2K-CPY-SECTION` de conversión de fechas. Adicionalmente, el valor **999999** (6 dígitos) es el sentinel de "sin fecha" (fecha nula); se mapea a `99999999` en formato de 8 dígitos durante la conversión.

**Trigger:** Toda conversión de fecha de formato corto (AA) a formato largo (CCAA) durante el procesamiento.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `A2K-BASE-YEAR` | 9(02) VALUE 50 | Pivote de siglo — hardcoded (línea 195) |
| `A2K-FEC-YEAR-AA` | 9(02) | Año de 2 dígitos a evaluar (línea 149) |
| `A2K-FEC-YEAR-CC` | 9(02) | Siglo resultante (línea 150) |
| `A2K-FEC-AMD-001` | 9(06) | Fecha en formato AAMMDD (línea 104) |
| `A2K-FEC-CAMD-001` | 9(08) | Fecha en formato CCAAMMDD (línea 65) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R00-PUN-FECPRO` | CAMPO-COMP | Persistente-BD | Fecha de proceso AAAAMMDD — ya en formato largo tras CRONOS2K |
| `500-R01-FECPRO` | CAMPO-NUM | Interfaz-Externo | Fecha de 6 dígitos AAMMDD — sujeta a regla de pivote |

**Fórmula / pseudocódigo:**
```
IF A2K-FEC-AMD-001 = 999999 → MOVE 99999999 TO A2K-FEC-CAMD-001  (sentinel nulo)
ELSE IF A2K-FEC-YEAR-AA < A2K-BASE-YEAR (50) → siglo = 20  (año 20XX)
ELSE → siglo = 19  (año 19XX)
```

**Excepciones documentadas:**
- A partir de 2050: AA=50 → interpretado como 1950 (error de siglo); ventana del sistema se agota en 24 años
- Sentinel 999999→99999999 debe preservarse en migraciones parciales antes de reemplazarse con NULL en BD relacional

**Traza de código:**
- Línea 195: `01 A2K-BASE-YEAR PIC 9(02) VALUE 50` — pivote hardcoded
- Línea 18526: `IF A2K-FEC-YEAR-AA < A2K-BASE-YEAR` — condición de siglo 20
- Línea 18364: `IF A2K-FEC-AMD-001 = 999999` → `MOVE 99999999 TO A2K-FEC-CAMD-001` — sentinel
- Línea 18391: `IF A2K-FEC-MDA-001 = 999999` → `MOVE 99999999 TO A2K-FEC-MDCA-001` — sentinel variante

**Riesgos de migración:** El pivote año 50 generará errores de interpretación de fechas a partir de 2050 (año AA=50 se interpreta como 1950, no 2050). En el target, todas las fechas deben almacenarse en formato AAAAMMDD de 8 dígitos. El sentinel 999999/99999999 debe reemplazarse por NULL en base de datos relacional.

**Estado validación:** pendiente HITL

---

### RN-S151-254 — Validación de fecha: conjunto {FECCON, FECPRO} ∪ {FECPROC(1..10)} — paragraph 420120-VALIDA-NUM-FEC

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-254 |
| **Nombre** | Validación de fecha: conjunto {FECCON, FECPRO} ∪ {FECPROC(1..10)} — paragraph 420120-VALIDA-NUM-FEC |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | VALIDACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Control interno de integridad de datos |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El paragraph `420120-VALIDA-NUM-FEC` valida que la fecha ingresada por el usuario sea miembro del conjunto de fechas válidas: (1) igual a `FECCON` del sistema, (2) igual a `FECPRO` del sistema, o (3) igual a alguna de las 10 fechas procesadas históricas `FECPROC(1..10)` del sistema. Si no pertenece a ninguna de estas, se emite error 19. La validación numérica previa usa `JUSTIFIER IN LOCSUP`.

**Trigger:** Ingreso de fecha en cualquier pantalla de consulta de movimientos (P11–P29 según el número de pantalla < 30).

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-TAB-FECCON` | 9(08) COMP | Fecha de contabilización del sistema en tabla (por W77-I) |
| `WKS-TAB-FECPRO` | 9(08) COMP | Fecha de proceso del sistema en tabla |
| `WKS-TAB-FECPROC` | 9(08) COMP | Tabla bidimensional de fechas históricas [sistema, 1..10] (línea 10417) |
| `WKS-FEC-ALFA` | X | Fecha ingresada por usuario en alfanumérico |
| `WKS-FEC-NUME` | 9(08) | Fecha en numérico tras conversión con JUSTIFIER |
| `W77-RES-MSG` | — | Código de error: 19 = fecha inválida |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R01-FECCONT` | CAMPO-COMP | Interfaz-Externo | Fecha contable AAAAMMDD que determina período contable CNBV |
| `A00-R00-PUN-FECPRO` | CAMPO-COMP | Persistente-BD | Fecha de proceso del encabezado de mensaje inter-sistemas |
| `500-R02-FECCONT` | CAMPO-NUM | Interfaz-Externo | Fecha contable AAAAMMDD en interfaz S500 |

**Fórmula / pseudocódigo:**
```
CALL JUSTIFIER → validar numericidad de WKS-FEC-ALFA
IF fecha = FECCON(sistema) OR fecha = FECPRO(sistema) → válida; continuar
ELSE FOR k=1 TO 10: IF fecha = FECPROC(sistema,k) → válida; continuar
ELSE → MOVE 19 TO W77-RES-MSG (fecha fuera del conjunto válido)
```

**Excepciones documentadas:**
- Fecha numéricamente correcta pero fuera del conjunto válido → error 19 (no es error de formato sino de dominio)
- FECPROC(j)=0 (slot vacío) → nunca coincide con fecha real; no genera error adicional pero reduce ventana disponible

**Traza de código:**
- Línea 16464: `420120-VALIDA-NUM-FEC.` — paragraph de inicio
- Línea 16467: `CALL "JUSTIFIER IN LOCSUP" USING WKS-FEC-ALFA, WKS-FUNCION, WKS-FORMATO` — validación numérica
- Línea 16472: `IF (WKS-FEC-NUME = WKS-TAB-FECCON(W77-I)) OR (WKS-FEC-NUME = WKS-TAB-FECPRO(W77-I))` — fechas actuales
- Línea 16476: `PERFORM 420122-VALIDA-FEC VARYING W77-K FROM 1 BY 1 UNTIL W77-K > 10` — búsqueda histórica
- Línea 16481: `MOVE 19 TO W77-RES-MSG` — error fecha inválida

**Riesgos de migración:** La lógica de "fecha válida" está acoplada a la tabla de fechas de proceso del sistema en memoria. En target, este control debe implementarse como servicio de validación de fecha de proceso con consulta a base de datos, permitiendo actualizaciones sin recompilación.

**Estado validación:** pendiente HITL

---

### RN-S151-255 — Ruteo de mensajes entre nodos CSI: WKS-MSGHDR-RES=2 → redirect; sistema 264 excepción

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-255 |
| **Nombre** | Ruteo de mensajes entre nodos CSI: WKS-MSGHDR-RES=2 → redirect; sistema 264 excepción |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando el campo `WKS-MSGHDR-RES=2` en el header del mensaje, P010 interpreta que la petición debe ser redirigida a otro nodo CSI (routing inter-nodo). En ese caso se modifica `WKS-MSGHDR-RES=3` y se copia el origen en el destino para redirigir. El sistema **264** es una excepción explícita que salta el routing CSI (`NEXT SENTENCE` cuando `SIS-NUME=264`), procesándose siempre localmente. Esta excepción también aplica al bypass de bitácora (ver RN-269).

**Trigger:** Recepción de mensaje con `WKS-MSGHDR-RES=2` y verificación de `NUMCSI-HOST` distinto al CSI requerido.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-MSGHDR-RES` | 9(02) | Código de resultado/routing del header: 2=redirect, 3=local, 11-12=red (línea 368) |
| `WKS-MSGHDR-CCR-ORG` | 9(02) | CCR de origen (línea 362) |
| `WKS-MSGHDR-CCR-DES` | 9(02) | CCR de destino (línea 351) |
| `WKS-NUMCSI-HOST` | 9(02) | Nodo CSI local (línea 10136) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R00-CSIORI` | CAMPO-NUM | Persistente-BD | CSI origen — el que emite el mensaje |
| `A00-BIT264-CSI-ORIG` | CAMPO-NUM | Efimero | CSI origen de la transacción en bitácora 264 |
| `A00-BIT264-CSI-DEST` | CAMPO-NUM | Efimero | CSI destino de la transacción en bitácora 264 |

**Fórmula / pseudocódigo:**
```
IF WKS-MSGHDR-RES = 2 THEN
  IF WKS-SIS-NUME = 264 → NEXT SENTENCE  (proceso local forzado; sin redirect CSI)
  ELSE MOVE 3 TO WKS-MSGHDR-RES; copiar CCR-ORG → CCR-DES; redirect a CSI destino
```

**Excepciones documentadas:**
- Sistema 264 siempre se procesa localmente incluso si MSGHDR-RES=2 (excepción hardcodeada en routing)
- W88-MSGRES-APL VALUE 2,4 → valor 4 también activa ciertos flujos de ruteo; no solo el valor 2

**Traza de código:**
- Líneas 369–375: `88 W88-MSGRES-APL VALUE 2,4` / `W88-MSGRES-RED VALUE 11,12` / `W88-MSGRES-TER VALUE 1` — valores de WKS-MSGHDR-RES
- Línea 12122: `IF WKS-NUMCSI-HOST NOT = 32 AND WKS-MSGHDR-RES NOT = 2` — condición de proceso local
- Línea 16237: `IF WKS-MSGHDR-RES = 2` → `MOVE 3 TO WKS-MSGHDR-RES` + redirect para sistemas 1/66
- Línea 16253: `IF WKS-SIS-NUME = 264` → `NEXT SENTENCE` — excepción: sistema 264 sin redirect

**Riesgos de migración:** El modelo de routing inter-CSI vía header de mensaje debe reemplazarse por service mesh o API Gateway en el target. El comportamiento de "sistema 264 siempre local" debe documentarse como invariante de arquitectura para el microservicio equivalente.

**Estado validación:** pendiente HITL

---

### RN-S151-256 — Sistemas 1 y 66: tratamiento especial (no sucursal → error 99)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-256 |
| **Nombre** | Sistemas 1 y 66: tratamiento especial (no sucursal → error 99) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONTROL-OPERACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Control interno |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los sistemas con número **1** o **66** reciben tratamiento especial en el routing de sucursal: si el campo `WKS-SUC-NUME` tiene valor (sucursal ingresada), se emite el error **99** y se fuerza un redirect de mensaje (cuando WKS-MSGHDR-RES=2). Esto indica que los sistemas 1 y 66 son de tipo "sin sucursal" o de nivel nacional — toda consulta que lleve una sucursal específica es inválida para estos sistemas.

**Trigger:** Consulta con sucursal > 0 sobre sistema 1 o 66.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-SIS-NUME` | 9(04) | Número de sistema evaluado |
| `WKS-SUC-NUME` | 9(04) | Número de sucursal ingresado |
| `W77-RES-MSG` | — | Código de error: 99 = sistema sin sucursal |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `500-R02-SISTEMA` | CAMPO-NUM | Interfaz-Externo | Código de sistema de 4 dígitos que identifica el sistema contable |

**Fórmula / pseudocódigo:**
```
IF WKS-SIS-NUME IN (1, 66) AND WKS-SUC-NUME > ZEROS THEN
  MOVE 99 TO W77-RES-MSG  (sistema sin sucursal)
  IF WKS-MSGHDR-RES = 2 → forzar redirect de mensaje al CSI correcto
```

**Excepciones documentadas:**
- SUC-NUME = 0 → consulta nacional válida para sistemas 1 y 66 (ausencia de sucursal es el caso correcto)
- No hay validación inversa: otros sistemas no son obligados a incluir sucursal en la petición

**Traza de código:**
- Línea 16234: `IF WKS-SUC-NUME > ZEROS`
- Línea 16235: `IF WKS-SIS-NUME = 1 OR 66`
- Línea 16236: `MOVE 99 TO W77-RES-MSG` — error sistema sin sucursal
- Línea 16237–16240: lógica de redirect si MSGHDR-RES=2

**Riesgos de migración:** Los sistemas 1 y 66 deben catalogarse explícitamente en el target como "sistemas nacionales sin sucursal". La validación de sucursal=0 para estos sistemas debe implementarse en la capa de validación de input del microservicio de routing.

**Estado validación:** pendiente HITL

---

### RN-S151-257 — Flujo de vida: loop infinito PERFORM UNTIL W77-FIN=1; HI 4=fin normal, HI 6=emergencia

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-257 |
| **Nombre** | Flujo de vida: loop infinito PERFORM UNTIL W77-FIN=1; HI 4=fin normal, HI 6=emergencia |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa LINEA se ejecuta como un proceso online persistente (daemon) en el nodo Unisys. El loop principal `PERFORM 200000-PROCESO UNTIL W77-FIN = 1` mantiene el programa activo indefinidamente, esperando mensajes. La terminación se activa mediante interrupciones del operador: `HI 4` = fin normal (cierre ordenado), `HI 6` = terminación de emergencia. Ambas rutas convergen en `PERFORM 999999-FIN` que ejecuta `SMCOMS DISABLE PROGRAM`.

**Trigger:** Señal HI del operador de sistemas o condición de fin de proceso.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `W77-FIN` | 9(02) COMP VALUE ZEROS | Flag de terminación del loop (línea 10262) |
| `W77-HI-INTERRUPT` | — | Código de la interrupción HI recibida |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `PD` | ACCION | dominio | Proceso Diario — interactúa con el proceso online durante el cierre del día |

**Fórmula / pseudocódigo:**
```
PERFORM 200000-PROCESO UNTIL W77-FIN = 1
ON HI 4 → MOVE 1 TO W77-FIN  (fin normal)
ON HI 6 → MOVE 1 TO W77-FIN  (terminación de emergencia)
PERFORM 999999-FIN → SMCOMS DISABLE PROGRAM + STOP RUN
```

**Excepciones documentadas:**
- HI 4 y HI 6 producen el mismo resultado (W77-FIN=1); la diferencia es solo el DISPLAY de diagnóstico
- Error fatal en el procesamiento también puede llamar 999999-FIN directamente (línea 18289), sin pasar por HI

**Traza de código:**
- Línea 10262: `77 W77-FIN PIC 9(02) COMP VALUE ZEROS`
- Línea 10824: `PERFORM 200000-PROCESO UNTIL W77-FIN = 1` — loop principal
- Línea 10802: `DISPLAY "HI 4 -> FIN NORMAL POR OPERADOR"`
- Línea 10803: `DISPLAY "HI 6 -> TERMINACION DE EMERGENCIA"`
- Línea 17118: `MOVE 1 TO W77-FIN` — activación de fin en handler HI 4/6
- Línea 10825: `PERFORM 999999-FIN` — cierre posterior al loop

**Riesgos de migración:** El modelo de proceso persistente (daemon) debe reimplementarse como un servicio con graceful shutdown en Kubernetes (SIGTERM handler). La distinción entre HI 4 (normal) y HI 6 (emergencia) debe mapearse a señales SIGTERM/SIGKILL con lógica de limpieza apropiada.

**Estado validación:** pendiente HITL

---

### RN-S151-258 — Inicialización: carga de todos los sistemas activos (B04SISTEM FUN=02); CHANGE ATTRIBUTE TITLE para 16+ sistemas hardcoded

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-258 |
| **Nombre** | Inicialización: carga de todos los sistemas activos (B04SISTEM FUN=02); CHANGE ATTRIBUTE TITLE para 16+ sistemas hardcoded |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONFIGURACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Durante la inicialización (paragraph `110000-CARGA-SISTEMAS`), P010 invoca `B04SISTEM IN LIB-CONTROL` para cargar todos los sistemas activos del catálogo. Posterior a esta carga, ejecuta un bloque de `CHANGE ATTRIBUTE TITLE OF "LIB-CONS{NNN}"` hardcodeados para 16+ sistemas específicos (S017, S018, S711, S500, S502, S335, S336, S084, S087, S151, S203, S252, S264, S402, S403, S404, S408, S414, S600, S701, S702, S703, S707, S804, S1151). Este mecanismo Unisys carga las bibliotecas de consulta en el espacio de proceso del nodo.

**Trigger:** Startup del programa LINEA (P010); una sola vez al inicio.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-B04SISTEMA` | — | Estructura de datos del dataset B04SISTEM (línea 3679) |
| `WKS-B04-SISTEMA` | 9(04) | Número de sistema leído de B04SISTEM (línea 10955+) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `MOVIMIENTOS` | ENTIDAD | bcop-cruzada | Cada sistema tiene su propia colección de movimientos |
| `BOOK` | ENTIDAD | dominio | Estructura DMSII que agrupa movimientos por tipo de cuenta |

**Fórmula / pseudocódigo:**
```
CALL B04SISTEM FUN=02 → cargar todos los sistemas activos en catálogo
FOR cada sistema en lista hardcoded (16+):
  CHANGE ATTRIBUTE TITLE OF "LIB-CONS{NNN}"  (linking tardío Unisys)
→ bibliotecas de consulta disponibles en espacio del proceso
```

**Excepciones documentadas:**
- Sistema 501 comentado (`*CHANGE ATTRIBUTE TITLE OF "LIB-CONS0501"`) → no se carga (excluido deliberadamente)
- Sistema activo en B04SISTEM pero ausente en lista hardcoded → sin CHANGE ATTRIBUTE TITLE; dispatch fallará en runtime

**Traza de código:**
- Línea 10879: `MOVE LOW-VALUES TO WKS-B04SISTEMA`
- Línea 10885: `CALL "B04SISTEM IN LIB-CONTROL" USING WKS-B04SISTEMA` — carga de catálogo
- Línea 10956: `CHANGE ATTRIBUTE TITLE OF "LIB-CONS0017"` — inicio del bloque hardcoded
- Línea 11112: `CHANGE ATTRIBUTE TITLE OF "LIB-CONS1151"` — último sistema hardcoded
- Línea 10986/10988: sistemas S501 comentados (excluidos — ver RN-270)

**Riesgos de migración:** El bloque de CHANGE ATTRIBUTE TITLE es equivalente a un mapa de routing estático. En target, debe reemplazarse por service discovery dinámico (ej. Kubernetes Service o API Gateway routing table). La lista de 16+ sistemas hardcodeados debe mantenerse en configuración externa (ConfigMap o tabla de BD) para facilitar el alta/baja de sistemas sin redeployment.

**Estado validación:** pendiente HITL

---

### RN-S151-259 — Bitácora de auditoría: GRABA_BITACORA IN S151L010 con before/after (MSG-ANT=63b, MSG-POST=1142b); excepción CSI=32 AND RES=2

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-259 |
| **Nombre** | Bitácora de auditoría: GRABA_BITACORA IN S151L010 con before/after (MSG-ANT=63b, MSG-POST=1142b); excepción CSI=32 AND RES=2 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | AUDITORIA |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | LIC Art. 52 + CUB Circular Única de Bancos — pistas de auditoría para operaciones administrativas; registro before/after de cambios en parámetros del sistema |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P010 llama a `GRABA_BITACORA IN S151L010` para registrar toda operación administrativa (cambios en fechas, estatus, parámetros de BD) con el estado anterior (`WKS-BIT-MSG-ANT`, 63 bytes) y posterior (`WKS-BIT-MSG-POST`, 1142 bytes). La bitácora incluye: nómina del operador, fecha/hora de inicio y fin, estación, sistema, pantalla y código de resultado. **Excepción**: cuando `NUMCSI-HOST=32 AND MSGHDR-RES=2`, la bitácora se omite (nodo especial CSI=32 sin registro).

**Trigger:** Toda operación administrativa en pantallas P81, P82, P83, P84, P86 que modifique parámetros del sistema.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-BIT-NOMINA` | 9(08) | Nómina del operador que realiza la operación (línea 319) |
| `WKS-BIT-FECHA` | 9(08) (DD/MM/AAAA) | Fecha de la operación (línea 320) |
| `WKS-BIT-HORA` | HH:MM:SS | Hora de inicio (línea 324) |
| `WKS-BIT-HORA-FIN` | HH:MM:SS | Hora de fin de operación (línea 337) |
| `WKS-BIT-ESTACION` | X(08) | Terminal donde se opera (línea 330) |
| `WKS-BIT-SISTEMA` | X(04) | Sistema afectado (línea 331) |
| `WKS-BIT-CVE-PANTALLA` | X(08) | Pantalla de la operación (línea 332) |
| `WKS-BIT-TIPO-OPERACION` | X(01) | Tipo: A=alta, M=modificación, B=baja (línea 333) |
| `WKS-BIT-MSG-ANT` | X(63) | Estado anterior del registro (línea 334) |
| `WKS-BIT-MSG-POST` | X(1142) | Estado posterior del registro (línea 335) |
| `WKS-BIT-CVE-RESULT` | 9(02) | Código de resultado de la operación (línea 343) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-BIT-FECCONT` | CAMPO-NUM | Efimero | Fecha contable en bitácora GL |
| `A00-BIT-SISTEMA` | CAMPO-NUM | Efimero | Sistema al que pertenece el registro de bitácora |
| `A00-BIT-CVEMDA` | CAMPO-NUM | Efimero | Clave de moneda en bitácora |

**Fórmula / pseudocódigo:**
```
MOVE datos_operador/fecha/hora/pantalla/sistema TO WKS-REG-BITACORA
MOVE estado_antes(63b) TO WKS-BIT-MSG-ANT
MOVE estado_nuevo(1142b) TO WKS-BIT-MSG-POST
IF NOT (CSI-HOST=32 AND MSGHDR-RES=2) → CALL GRABA_BITACORA IN S151L010
```

**Excepciones documentadas:**
- CSI-HOST=32 AND MSGHDR-RES=2 → bitácora omitida; gap de auditoría CNBV en el nodo especial
- Solo cubre operaciones administrativas en P81-P86; consultas normales de movimientos no generan bitácora

**Traza de código:**
- Línea 315: `* ENTRY-POINT GRABA_BITACORA` — definición del entry point de bitácora
- Línea 318: `01 WKS-REG-BITACORA WITH LOWER-BOUNDS` — estructura del registro
- Líneas 11535–11540: carga de fecha/hora en campos de bitácora antes del CALL
- Línea 12011: `MOVE W77-CVE-RESOL TO WKS-BIT-CVE-RESULT` — resultado en bitácora
- Línea 11384: `IF WKS-NUMCSI-HOST = 32` → lógica de excepción de bitácora (RN-269)

**Riesgos de migración:** El registro before/after de 63+1142 bytes debe reemplazarse por un sistema de audit log estructurado (JSON) con retención en almacenamiento inmutable (ej. Cloud Storage con WORM). La excepción CSI=32 sin bitácora debe evaluarse con el equipo de compliance — puede representar un gap de auditoría en el target.

**Estado validación:** pendiente HITL

---

### RN-S151-260 — Monitor de traza: HI 2/3 → W77-MONITOR=1/0 (debug mode producción)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-260 |
| **Nombre** | Monitor de traza: HI 2/3 → W77-MONITOR=1/0 (debug mode producción) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | OPERACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa incluye un modo de trazado/debug activable en tiempo de ejecución mediante interrupciones del operador: `HI 2` activa el monitor (`W77-MONITOR=1`) y `HI 3` lo desactiva (`W77-MONITOR=0`). Cuando el monitor está activo, el programa ejecuta bloques de `DISPLAY` adicionales con información de diagnóstico. Este es un mecanismo de troubleshooting de producción propio de la arquitectura Unisys MCP, sin equivalente directo en plataformas modernas.

**Trigger:** Señal HI 2 u HI 3 del operador durante la operación del proceso online.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `W77-MONITOR` | 9(02) COMP VALUE ZEROS | Flag de modo monitor: 0=apagado, 1=encendido (línea 10271) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `PD` | ACCION | dominio | Proceso batch que también usa trazado para diagnóstico nocturno |

**Fórmula / pseudocódigo:**
```
ON HI 2 → MOVE 1 TO W77-MONITOR  (debug activado)
ON HI 3 → MOVE 0 TO W77-MONITOR  (debug desactivado)
IF W77-MONITOR = 1 → ejecutar DISPLAYs de diagnóstico adicionales en el flujo
```

**Excepciones documentadas:**
- Estado del monitor no persiste al reiniciar LINEA; W77-MONITOR VALUE ZEROS (apagado por defecto)
- DISPLAY en producción genera overhead de I/O en nodo Unisys MCP; activar solo para troubleshooting puntual

**Traza de código:**
- Línea 10271: `77 W77-MONITOR PIC 9(02) COMP VALUE ZEROS`
- Línea 10577: `MOVE 1 TO W77-MONITOR` — activación vía HI 2
- Línea 10587: `MOVE ZEROS TO W77-MONITOR` — desactivación vía HI 3
- Línea 10800: `DISPLAY "HI 2 -> PRENDE MONITOR"`
- Línea 10801: `DISPLAY "HI 3 -> APAGA MONITOR"`
- Línea 16043: `IF W77-MONITOR = 1` — guarda de debug
- Línea 17384: `IF W77-MONITOR = 1` — uso en flujo de routing

**Riesgos de migración:** En target, el debug mode debe implementarse como un nivel de logging dinámico (ej. log level DEBUG activable vía actuator endpoint o feature flag) con trazabilidad de quién lo activó y cuándo. El mecanismo HI no tiene equivalente en Kubernetes/cloud; el proceso debe responder a cambios de log level vía API de administración.

**Estado validación:** pendiente HITL

---

### RN-S151-261 — Terminación ordenada: SMCOMS DISABLE PROGRAM al apagado (HI 4 o HI 6)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-261 |
| **Nombre** | Terminación ordenada: SMCOMS DISABLE PROGRAM al apagado (HI 4 o HI 6) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | OPERACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al recibir HI 4 (fin normal) o HI 6 (emergencia), P010 ejecuta el paragraph `999999-FIN` que invoca `SMCOMS OF SOPORTECOMS` con el comando `"DISABLE PROGRAM"`. Este comando Unisys MCP desregistra el programa del sistema de comunicaciones (COMS) para que no reciba más mensajes, antes de terminar la ejecución. Si SMCOMS retorna error, se registra en el log operativo pero la terminación continúa.

**Trigger:** Recepción de HI 4 o HI 6; también llamado desde condición de error fatal (línea 18289).

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-SMCOMS-STRING1` | X | Buffer con "DISABLE PROGRAM " (línea 18303) |
| `WKS-SMCOMS-STRING2` | X | Nombre del programa actual (línea 18304) |
| `WKS-SMCOMS-COMANDO` | X | Comando completo para SMCOMS |
| `W77-SMCOMS-RESULT` | — | Resultado de la operación SMCOMS |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `PD` | ACCION | dominio | El PD batch puede disparar terminación de proceso online durante el cierre del día |

**Fórmula / pseudocódigo:**
```
999999-FIN:
  MOVE "DISABLE PROGRAM " TO WKS-SMCOMS-STRING1
  CALL "SMCOMS OF SOPORTECOMS" USING WKS-SMCOMS-COMANDO GIVING W77-SMCOMS-RESULT
  IF NOT W88-SMCOMS-OK → log error (terminación continúa igual)
  STOP RUN
```

**Excepciones documentadas:**
- Error en SMCOMS → se registra en log pero no detiene la terminación (fail-safe hacia STOP RUN)
- 999999-FIN es invocado tanto por HI 4/6 como directamente por condición de error fatal (línea 18289)

**Traza de código:**
- Línea 18301: `999999-FIN SECTION.`
- Línea 18303: `MOVE "DISABLE PROGRAM " TO WKS-SMCOMS-STRING1`
- Línea 18305: `CALL "SMCOMS OF SOPORTECOMS" USING WKS-SMCOMS-COMANDO, WKS-SMCOMS-TRABAJO GIVING W77-SMCOMS-RESULT`
- Línea 18309: `IF W88-SMCOMS-OK` → `NEXT SENTENCE` / ELSE → log de error
- Línea 18289: `PERFORM 999999-FIN` — llamada adicional desde condición de error

**Riesgos de migración:** `SMCOMS DISABLE PROGRAM` es un mecanismo exclusivo de Unisys MCP sin equivalente directo. En target (Kubernetes), el graceful shutdown se implementa mediante SIGTERM + liveness/readiness probes. El desregistro del gateway de mensajes debe coordinarse con el API Gateway o service mesh que reemplace al sistema COMS.

**Estado validación:** pendiente HITL

---

### RN-S151-262 — Resultado de FACULTAD: mapeo código → CVE-RESOL (0/1→OK; 3→denegado con error 87; -9→suspendido)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-262 |
| **Nombre** | Resultado de FACULTAD: mapeo código → CVE-RESOL (0/1→OK; 3→denegado con error 87; -9→suspendido) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | SEGURIDAD |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Control interno |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La evaluación de FACULTAD en `300010-CHECA-ENTIDAD` produce tres posibles resultados en `W77-CVE-RESOL`: **0** = no evaluado (inicial), **1** = acceso autorizado (FACULTAD=1 en propia sucursal, o FACULTAD=2 cross-sucursal), **3** = acceso denegado con error 87 (FACULTAD=1 en otra sucursal o FACULTAD=3). El paragraph `420300-CALL-FACULTAD` invoca `VALIDA_FACULTAD IN SEGURIDAD` para casos de validación externa; sus códigos negativos (-9=suspendido, -11..-2=error de validación) se mapean al campo `W77-RES-MSG` con código 78.

**Trigger:** Por cada petición; tras `300010-CHECA-ENTIDAD` (inline) o `420300-CALL-FACULTAD` (externo).

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `W77-CVE-RESOL` | 9(04) | Resultado de evaluación de FACULTAD: 0/1/3 (línea 10325) |
| `W77-FACULTAD` | 9(04) | Nivel de facultad: 1/2/3 (línea 10324) |
| `W77-RES-MSG` | — | Código de mensaje de error asociado al resultado |
| `WKS-BIT-CVE-RESULT` | 9(02) | W77-CVE-RESOL copiado a bitácora (línea 12011) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-BIT-SISTEMA` | CAMPO-NUM | Efimero | Sistema sobre el que se evalúa la facultad |

**Fórmula / pseudocódigo:**
```
MOVE ZERO TO W77-CVE-RESOL  (inicializar)
IF FACULTAD=1 AND sucursal_propia → CVE-RESOL=1
IF FACULTAD=1 AND otra_sucursal/P17 → CVE-RESOL=3 + MSG=87
IF FACULTAD=2 → CVE-RESOL=1; IF FACULTAD=3 → CVE-RESOL=3 + MSG=87
```

**Excepciones documentadas:**
- VALIDA_FACULTAD externo retorna -9 (usuario suspendido) → mapeo a MSG=78 (no MSG=87)
- Códigos -11..-2 del sistema SEGURIDAD → error genérico de validación; mapeo a MSG=78

**Traza de código:**
- Línea 12173: `MOVE ZERO TO W77-CVE-RESOL` — inicialización
- Línea 12174–12190: evaluación de FACULTAD 1/2/3 → valores 1 o 3 de CVE-RESOL
- Línea 12180: `MOVE 1 TO W77-CVE-RESOL` — autorizado (sucursal propia, FACULTAD=1)
- Línea 12182/12189: `MOVE 3 TO W77-CVE-RESOL` + `MOVE 87 TO W77-RES-MSG` — denegado
- Línea 12186: `MOVE 1 TO W77-CVE-RESOL` — autorizado cross-sucursal, FACULTAD=2
- Línea 17058: `420300-CALL-FACULTAD.` — paragraph de validación externa
- Línea 17068: `CALL "VALIDA_FACULTAD IN SEGURIDAD"` — llamada al sistema de seguridad

**Riesgos de migración:** El mapeo FACULTAD→CVE-RESOL debe reproducirse exactamente en el sistema de autorización target (RBAC/claims). Los códigos -9 y -11..-2 del sistema SEGURIDAD externo deben mapearse a respuestas HTTP 401/403 con códigos de error específicos en el API target.

**Estado validación:** pendiente HITL

---

### RN-S151-263 — Campo NIO agregado 2006-07-28 en P12/P14/P18 — posible identificador SPEI/Banxico

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-263 |
| **Nombre** | Campo NIO agregado 2006-07-28 en P12/P14/P18 — posible identificador SPEI/Banxico |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DATO-NEGOCIO |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A — posible vinculación con Banxico SPEI (NIO = Número de Instrucción de Operación) |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El 2006-07-28 (FTF — Fábrica de Software) se agregó el campo `NIO` (Número de Identificación de Operación) en las pantallas P12, P14 y P18. El campo tiene tamaño X(01) en entrada y X(16) en salida, consistente con el NIO de 16 caracteres del sistema SPEI de Banxico para identificación única de instrucciones de transferencia. La confianza es media porque la anotación en el código solo dice "campo para NIO" sin precisar el sistema fuente.

**Trigger:** Consulta de movimientos en pantallas P12, P14 y P18.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-ENT-P12NIO` | X(01) | Campo NIO de entrada en P12 (línea 562) |
| `WKS-ENT-P14NIO` | X(01) | Campo NIO de entrada en P14 (línea 651) |
| `WKS-ENT-P18NIO` | X(01) | Campo NIO de entrada en P18 (línea 823) |
| `WKS-SAL-P11NIO` | X(16) | Campo NIO en salida P11 (línea 1854) |
| `WKS-SAL-P12NIO` | X(01) | Campo NIO en salida P12 (línea 1899) |
| `WKS-SAL-P12REFNIO` | X(16) | Redefinición para NIO en referencia P12 (línea 1928) |
| `WKS-SAL-P14NIO` | X(01) | Campo NIO en salida P14 (línea 2041) |
| `WKS-SAL-P18NIO` | X(01) | Campo NIO en salida P18 (línea 2271) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R01-NIO` | CAMPO-ALFA | Interfaz-Externo | Número de identificación de operación del registro R01; referencia única de 16 chars |
| `A00-R01-S050-NIO` | CAMPO-ALFA | Persistente-BD | NIO SPEI asignado por Banxico a cada instrucción SPEI |
| `A00-BIT264-AUT-NIO` | CAMPO-ALFA | Efimero | NIO de autorización en bitácora 264 |
| `A00-BITNF-AUT-NIO-S500` | CAMPO-ALFA | Efimero | NIO del sistema S500 en bitácora NF |

**Fórmula / pseudocódigo:**
```
* FTF 20060728: se agrega NIO en P12/P14/P18
MOVE WKS-ENT-P{NN}NIO al buffer de consulta de movimientos
DISPLAY WKS-SAL-P11NIO (X(16)) en pantalla de resultados
→ identificador único de operación asociado al movimiento
```

**Excepciones documentadas:**
- WKS-ENT-P12NIO es X(01) en entrada vs WKS-SAL-P12REFNIO X(16) en salida — asimetría de tamaño entre entrada y salida
- Confianza media: semántica exacta (NIO interno vs NIO Banxico SPEI) no confirmada en código; requiere validación con SME

**Traza de código:**
- Línea 561: `*Inicia FTF 20060728 Se agrega campo para NIO`
- Línea 562: `04 WKS-ENT-P12NIO PIC X(01)` — entrada P12
- Línea 650: `*Inicia FTF 20060728 Se agrega campo para NIO`
- Línea 651: `04 WKS-ENT-P14NIO PIC X(01)` — entrada P14
- Línea 822: `*Inicia FTF 20060728 Se agrega campo para NIO`
- Línea 823: `04 WKS-ENT-P18NIO PIC X(01)` — entrada P18
- Línea 1854: `04 WKS-SAL-P11NIO PIC X(16)` — salida P11 (tamaño completo)

**Riesgos de migración:** El campo NIO de 16 caracteres es clave para trazabilidad SPEI. En el target debe preservarse como campo de referencia cruzada obligatorio y mapearse al campo `NIO` del sistema SPEI en el modelo de datos. La confianza media se debe a que la semántica exacta (¿es el NIO de Banxico o uno interno?) debe validarse con SME de negocio.

**Estado validación:** pendiente HITL

---

### RN-S151-264 — Validación numérica universal via JUSTIFIER IN LOCSUP — catálogo de 25+ procedimientos con códigos de error

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-264 |
| **Nombre** | Validación numérica universal via JUSTIFIER IN LOCSUP — catálogo de 25+ procedimientos con códigos de error |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | VALIDACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Control interno de integridad de datos |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P010 usa la rutina `JUSTIFIER IN LOCSUP` (biblioteca S006) como mecanismo estándar de validación numérica de campos alfanuméricos ingresados por el usuario. La llamada recibe el campo en formato alfanumérico y retorna el resultado en `WKS-FUNCION`: si `WKS-FUNCION > ZEROS`, el campo contiene caracteres no numéricos. El catálogo de procedimientos que invocan JUSTIFIER incluye validación de fechas (420120), nóminas (420110), números de proceso (420130), sistemas, sucursales y más — más de 25 llamadas en total.

**Trigger:** Ingreso de cualquier campo numérico en pantallas de consulta o administración.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-FUNCION` | 9(02) | Código de función/resultado JUSTIFIER: >0=error numérico |
| `WKS-FORMATO` | 9(02) | Formato de validación (0=numérico simple) |
| `WKS-FEC-ALFA` | X | Campo fecha en alfanumérico para validar |
| `WKS-NOMINA-ALFA` | X | Campo nómina en alfanumérico para validar |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R01-FECCONT` | CAMPO-COMP | Interfaz-Externo | Fecha contable — uno de los campos que pasa por validación JUSTIFIER |

**Fórmula / pseudocódigo:**
```
CALL "JUSTIFIER IN LOCSUP" USING campo_alfa, WKS-FUNCION, WKS-FORMATO
IF WKS-FUNCION > ZEROS → campo no numérico; emitir error específico del paragraph
ELSE → campo válido; convertir a numérico para procesamiento
```

**Excepciones documentadas:**
- WKS-FUNCION=0 no distingue "correcto" de "no evaluado" → riesgo de skip silencioso de validación
- Más de 25 paragraphs dependen de LOCSUP; fallo en la biblioteca afecta toda validación numérica del hub

**Traza de código:**
- Línea 3949: `* LIBRERIA LOCSUP (S006)` — referencia de la biblioteca de validación
- Línea 11155: `CHANGE ATTRIBUTE LIBACCESS OF "LOCSUP" TO BYFUNCTION` — configuración de acceso
- Línea 16460: `CALL "JUSTIFIER IN LOCSUP" USING WKS-NOMINA-ALFA, WKS-FUNCION, WKS-FORMATO` — validación de nómina
- Línea 16467: `CALL "JUSTIFIER IN LOCSUP" USING WKS-FEC-ALFA, WKS-FUNCION, WKS-FORMATO` — validación de fecha
- Línea 16488: `CALL "JUSTIFIER IN LOCSUP" USING WKS-FEC-ALFA, WKS-FUNCION, WKS-FORMATO` — variante 420125
- Líneas 420000+: múltiples paragraphs 420{NNN}-VALIDA-* usan el mismo patrón

**Riesgos de migración:** JUSTIFIER IN LOCSUP es una biblioteca propietaria de Unisys/S006. En el target, esta validación debe reemplazarse por validadores de tipo de dato estándar (Bean Validation en Java, Pydantic en Python). El catálogo de >25 procedimientos de validación debe mapearse a un framework de validación centralizado.

**Estado validación:** pendiente HITL

---

### RN-S151-265 — Panel P82: administración de 13 subsistemas de archivos batch (NOMARC/NOMPAC por sistema)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-265 |
| **Nombre** | Panel P82: administración de 13 subsistemas de archivos batch (NOMARC/NOMPAC por sistema) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONFIGURACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La Pantalla P82 permite administrar los nombres de archivos (`NOMARC`) y paquetes (`NOMPAC`) de los subsistemas batch de S151. Cada subsistema tiene un par NOMARC (34 chars, nombre del archivo) + NOMPAC (17 chars, nombre del paquete). El panel soporta al menos 13 subsistemas identificados por sufijos: 028, 250, 030, 015, 050SDO, 050MOV, y otros. Estos son los archivos del ciclo batch nocturno (PD) que cierran el día contable.

**Trigger:** Acceso a pantalla P82 por operador con perfil de administración (FACULTAD=2 o 3 en sistema S151).

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-ENT-P82NOMARC028` | X(34) | Nombre archivo subsistema 028 (línea 1323) |
| `WKS-ENT-P82NOMPAC028` | X(17) | Nombre paquete subsistema 028 (línea 1324) |
| `WKS-ENT-P82NOMARC250` | X(34) | Nombre archivo subsistema 250 (línea 1325) |
| `WKS-ENT-P82NOMPAC250` | X(17) | Nombre paquete subsistema 250 (línea 1326) |
| `WKS-ENT-P81NOMARCMOV` | X(34) | Nombre archivo movimientos en P81 (línea 1290) |
| `WKS-ENT-P81NOMPACMOV` | X(17) | Nombre paquete movimientos en P81 (línea 1291) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `PD` | ACCION | dominio | Proceso Diario batch — los archivos administrados en P82 son los del PD |
| `MOVIMIENTOS` | ENTIDAD | bcop-cruzada | BD10MOVDIA151 — archivo de movimientos del día configurable en P82 |

**Fórmula / pseudocódigo:**
```
ACCESO P82 → PERFORM 420100-VALIDA-CVE-SUP  (doble control, RN-272)
IF CVE-SUP válida THEN
  MOVE nuevo NOMARC(34)/NOMPAC(17) TO estructura B01 por subsistema
  WRITE B01 → actualizar nombres de archivos batch en dataset
```

**Excepciones documentadas:**
- Sin validación de existencia del archivo NOMARC en el filesystem Unisys antes de escribir B01
- Subsistemas 050SDO/050MOV comparten prefijo 050 con tipos distintos (saldos vs movimientos); confusión posible

**Traza de código:**
- Línea 1323: `WKS-ENT-P82NOMARC028 PIC X(34)` — primer par de nombre de archivo
- Línea 1324: `WKS-ENT-P82NOMPAC028 PIC X(17)` — primer par de nombre de paquete
- Líneas 1325–1334: pares NOMARC/NOMPAC para subsistemas 250, 030, 015, 050SDO, 050MOV

**Riesgos de migración:** Los nombres de archivos NOMARC/NOMPAC son paths del filesystem Unisys DMSII/MCP. En el target, deben reemplazarse por referencias a datasets en cloud storage (GCS, S3) o nombres de tópicos Kafka. La semántica de "subsistema 028/250/030/015" debe mapearse a los componentes batch equivalentes en el target.

**Estado validación:** pendiente HITL

---

### RN-S151-266 — Panel P83: NUMCICDIA/NUMCICMES, BD de saldos, 4 slots BD de movimientos rotativas

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-266 |
| **Nombre** | Panel P83: NUMCICDIA/NUMCICMES, BD de saldos, 4 slots BD de movimientos rotativas |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONFIGURACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La Pantalla P83 configura los ciclos de proceso del sistema: `NUMCICDIA` (número de ciclos por día, máx definido en dataset B03) y `NUMCICMES` (número de ciclos del mes). Además administra el tipo de BD a usar (`BDUSAR`, que alimenta a `TIPBD`, ver RN-249) y los 4 slots de bases de datos de movimientos rotativas. El ciclo mensual determina cuántas iteraciones del proceso nocturno se ejecutan antes de rotar la BD de movimientos histórica.

**Trigger:** Acceso a pantalla P83 por operador con perfil de administración del sistema.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-ENT-P83BDUSAR` | 9(02) | Tipo de BD a usar — alimenta TIPBD (línea 1370) |
| `WKS-ENT-P83NUMCICDIA` | 9(04) | Número de ciclos por día (línea 1371) |
| `WKS-ENT-P83NUMCICMES` | 9(04) | Número de ciclos del mes (línea 1372) |
| `WKS-B03-NUMCICDIA` | 9(04) | Valor actual de ciclos día en dataset B03 (línea 3753) |
| `WKS-B03-NUMCICMES` | 9(04) | Valor actual de ciclos mes en dataset B03 (línea 3754) |
| `WKS-SAL-P83BDUSAR` | 9(02) | BDUSAR en salida display (línea 2942) |
| `WKS-SAL-P83NUMCICDIA` | 9(04) | NUMCICDIA en salida display (línea 2943) |
| `WKS-SAL-P83NUMCICMES` | 9(04) | NUMCICMES en salida display (línea 2944) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `PD` | ACCION | dominio | Proceso Diario — NUMCICDIA controla cuántos PD se ejecutan antes de rotar BD |
| `SALDO` | ENTIDAD | bcop-cruzada | BD11SDOS151 — BD de saldos configurable vía P83 |
| `MOVIMIENTOS` | ENTIDAD | bcop-cruzada | BD10MOVDIA151 — BD de movimientos principal |

**Fórmula / pseudocódigo:**
```
ACCESO P83 → PERFORM 420100-VALIDA-CVE-SUP  (doble control)
IF BDUSAR ≠ B03-TIPBD → log de cambio de tipo de BD
MOVE nuevo NUMCICDIA/NUMCICMES/BDUSAR TO B03
WRITE B03 → actualizar ciclos de proceso en dataset
```

**Excepciones documentadas:**
- NUMCICDIA máximo no documentado en código visible; límite implícito en estructura del campo B03 (9(04) = máx 9999)
- Cambio de BDUSAR (TIPBD) afecta qué BDs están disponibles para consultas de movimientos (ver RN-249)

**Traza de código:**
- Línea 1370: `WKS-ENT-P83BDUSAR PIC 9(02)` — tipo BD
- Línea 1371: `WKS-ENT-P83NUMCICDIA PIC 9(04)` — ciclos día
- Línea 1372: `WKS-ENT-P83NUMCICMES PIC 9(04)` — ciclos mes
- Línea 15443: `IF WKS-ENT-P83BDUSAR NOT = WKS-B03-TIPBD` — detección de cambio con log
- Línea 15583: `MOVE WKS-B03-TIPBD TO WKS-SAL-P83BDUSAR` — carga de valores actuales en display

**Riesgos de migración:** NUMCICDIA y NUMCICMES controlan la rotación de BDs físicas Unisys. En el target (particionamiento por fecha en BD relacional o lakehouse), esta lógica debe traducirse a políticas de particionamiento y retención automática, no a ciclos manuales configurados por pantalla.

**Estado validación:** pendiente HITL

---

### RN-S151-267 — Ruteo de cuenta corriente a CSI vía S016_L422_CON_XMEDIO — error 10→sin cuenta

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-267 |
| **Nombre** | Ruteo de cuenta corriente a CSI vía S016_L422_CON_XMEDIO — error 10→sin cuenta |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para consultas de movimientos por medio de acceso (pantallas P18/P19/P20), P010 llama al entry point `S016_L422_CON_XMEDIO` del sistema S016 (sistema de cuenta corriente/clientes) para obtener el CSI de la cuenta. Si el retorno del sistema es error **10**, significa que la cuenta no existe (`sin cuenta`). Esta dependencia con S016 introduce un acoplamiento runtime con el sistema de clientes de Banamex.

**Trigger:** Consulta de movimientos por MDA (medio de acceso) en pantallas P18, P19, P20.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-CSI-CTES` | 9(02) | CSI de la cuenta corriente retornado por S016 (línea 13164) |
| `WKS-NUMCSI-HOST` | 9(02) | CSI local; comparado con CSI de S016 para decidir ruteo |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R00-CSIORI` | CAMPO-NUM | Persistente-BD | CSI origen; el retornado por S016 determina el CSI de la cuenta |
| `A00-BIT264-CSI-ORIG` | CAMPO-NUM | Efimero | CSI origen en bitácora 264 |
| `POSICION` | ENTIDAD | dominio | Clave incluye CSI; el CSI de S016 determina qué partición consultar |

**Fórmula / pseudocódigo:**
```
CALL S016_L422_CON_XMEDIO USING parámetros_MDA
IF resultado = 10 → ACCOUNT_NOT_FOUND (error de negocio)
ELSE MOVE WKS-CSI-CTES a tabla de routing
IF CSI_cuenta ≠ CSI_local → redirect cross-CSI para consulta
```

**Excepciones documentadas:**
- CSI-HOST=32 → MOVE NUMCSI-HOST TO WKS-CSI-CTES (override; ignora CSI de S016; ver RN-269)
- Error distinto de 10 en S016 → comportamiento no documentado en código visible; confianza media

**Traza de código:**
- Línea 4553: `***PARAMETROS PARA EL ENTRY POINT S016_L422_MEDIOS (06)***` — definición del entry point de medios de acceso
- Línea 5296: `**** PARAMETROS DEL ENTRY POINT S016_L422_CONS_XMEDIO (20)` — definición del entry point de consulta por medio
- Línea 13164: `MOVE WKS-NUMCSI-HOST TO WKS-CSI-CTES` — asignación del CSI de cuenta
- Línea 13194: `IF WKS-NUMCSI-HOST NOT = 32 AND WKS-MSGHDR-RES NOT = 2` — condición de ruteo post-S016

**Riesgos de migración:** La dependencia síncrona con S016 durante la consulta de movimientos introduce latencia y punto de fallo. En el target, esta consulta debe resolverse mediante un cliente REST/gRPC hacia el microservicio de cuentas, con timeout y circuit breaker. El error 10 debe mapearse a una excepción de negocio específica (`AccountNotFoundException`).

**Estado validación:** pendiente HITL

---

### RN-S151-268 — Control dinámico de bases: HI 40NNN (BD10 toggle) y HI 44NNN (todas las BDs toggle)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-268 |
| **Nombre** | Control dinámico de bases: HI 40NNN (BD10 toggle) y HI 44NNN (todas las BDs toggle) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | OPERACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El operador puede abrir o cerrar bases de datos en tiempo de ejecución mediante interrupciones HI: `HI 40NNN` (donde NNN es el número de sistema) abre/cierra la BD10 específica de ese sistema; `HI 44NNN` abre/cierra todas las BDs (BD10, BD11, BD12, BD13) del sistema NNN; `HI 45` opera sobre todas las bases de todos los sistemas. Este mecanismo permite el mantenimiento de bases sin detener el proceso online completo.

**Trigger:** Señal HI 40NNN, HI 44NNN o HI 45 del operador durante la operación online.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `W88-HI-IO-BD10` | VALUE 40 | Flag de valor HI 40 para BD10 (línea 9915) |
| `WKS-TAB-STABD10` | 9(01) COMP | Estatus de BD10 por sistema (línea 10445) |
| `WKS-TAB-STABD11` | 9(01) COMP | Estatus de BD11 (línea 10446) |
| `WKS-TAB-STABD12` | 9(01) COMP | Estatus de BD12 (línea 10447) |
| `WKS-TAB-STABD13` | 9(01) COMP | Estatus de BD13 (línea 10448) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `MOVIMIENTOS` | ENTIDAD | bcop-cruzada | BD10MOVDIA151 — la BD primaria controlada por HI 40NNN |
| `SALDO` | ENTIDAD | bcop-cruzada | BD11/BD12/BD13 controladas por HI 44NNN |

**Fórmula / pseudocódigo:**
```
ON HI 40NNN → toggle WKS-TAB-STABD10(NNN): 1↔0  (solo BD10 del sistema NNN)
ON HI 44NNN → toggle WKS-TAB-STABD10..13(NNN): todas las 4 BDs del sistema NNN
ON HI 45   → toggle TODAS las BDs de TODOS los sistemas activos
```

**Excepciones documentadas:**
- NNN fuera del rango de la tabla de sistemas → comportamiento indefinido (no hay validación de rango)
- Toggle es secuencial y alternante: HI 40NNN en secuencia produce abre→cierra→abre; no idempotente

**Traza de código:**
- Línea 9915: `88 W88-HI-IO-BD10 VALUE 40` — identificador de HI 40
- Línea 10637: `IF W88-HI-IO-BD10` — procesamiento de HI 40 en handler
- Línea 10809: `DISPLAY "HI 40NNN -> ABRE/CIERRA BASE 10"`
- Línea 10810: `DISPLAY "HI 44NNN -> ABRE/CIERRA B.D. POR SISTEMA"`
- Línea 17957: `IF W88-HI-IO-BD10` — uso secundario en flujo de routing
- Línea 17986: `IF WKS-TAB-CONFBD10(W77-IND-SIS) = 1` — evaluación de estado BD10

**Riesgos de migración:** El control dinámico de BD vía HI no tiene equivalente en cloud. En target, la habilitación/deshabilitación de conexiones a BD debe implementarse mediante circuit breakers y feature flags de disponibilidad de dataset, con API de administración auditada.

**Estado validación:** pendiente HITL

---

### RN-S151-269 — NUMCSI-HOST=32 como nodo especial: override CSI de cuenta + sin bitácora

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-269 |
| **Nombre** | NUMCSI-HOST=32 como nodo especial: override CSI de cuenta + sin bitácora |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El nodo CSI número **32** recibe tratamiento especial en múltiples puntos del código: (1) en la inicialización, si `NUMCSI-HOST=32`, se omite la carga de entidades de sucursal (`130050-CARGA-ENTSUC`); (2) en el routing de mensajes, CSI=32 fuerza el número de CSI de la cuenta al valor del host; (3) en la bitácora, CSI=32 con `RES=2` omite el registro de auditoría (ver RN-259). El nodo 32 parece ser un nodo centralizado de desarrollo, QA o proceso especial que no sigue las reglas de negocio estándar.

**Trigger:** Toda operación cuando el programa corre en el nodo CSI=32.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-NUMCSI-HOST` | 9(02) | Número CSI del nodo local; valor 32 activa tratamientos especiales (línea 10136) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R00-CSIORI` | CAMPO-NUM | Persistente-BD | CSI origen; el nodo 32 se comporta diferente como origen |
| `POSICION` | ENTIDAD | dominio | Clave incluye CSI; el nodo 32 puede tener datos de posición propios |

**Fórmula / pseudocódigo:**
```
IF NUMCSI-HOST = 32 THEN
  SKIP PERFORM 130050-CARGA-ENTSUC  (no carga entidades de sucursal)
  OVERRIDE CSI de cuenta: MOVE NUMCSI-HOST TO WKS-NUM-CSI(W77-I)
  SKIP bitácora cuando MSGHDR-RES=2  (gap de auditoría)
```

**Excepciones documentadas:**
- Tres bypasses independientes activados por el mismo valor 32 → riesgo de regla de negocio oculta no documentada
- No existe mecanismo para deshabilitar el tratamiento especial del nodo 32 sin recompilación

**Traza de código:**
- Línea 10136: `03 WKS-NUMCSI-HOST PIC 9(02)` — declaración
- Línea 10865: `IF WKS-NUMCSI-HOST = 32` → `NEXT SENTENCE` ELSE `PERFORM 130050-CARGA-ENTSUC` — omisión de carga de sucursales
- Línea 11384: `IF WKS-NUMCSI-HOST = 32` → `MOVE WKS-NUMCSI-HOST TO WKS-NUM-CSI(W77-I)` — override de CSI
- Línea 11451: `IF WKS-NUMCSI-HOST = 32` — condición de seguridad toggle (RN-246)
- Línea 12122: `IF WKS-NUMCSI-HOST NOT = 32 AND WKS-MSGHDR-RES NOT = 2` — exclusión de bitácora

**Riesgos de migración:** El nodo CSI=32 es un nodo especial con comportamiento divergente del estándar. En la migración target, estos bypasses deben eliminarse o formalizarse como configuración de entorno (dev/QA vs producción). La omisión de bitácora para CSI=32 puede ser un gap de auditoría en producción que debe resolverse.

**Estado validación:** pendiente HITL

---

### RN-S151-270 — Sistema 264 doble excepción: sin ruteo CSI + CHANGE ATTRIBUTE TITLE; sistema 501 comentado (fue incluido, luego excluido)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-270 |
| **Nombre** | Sistema 264 doble excepción: sin ruteo CSI + CHANGE ATTRIBUTE TITLE; sistema 501 comentado (fue incluido, luego excluido) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONTROL-OPERACION |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El sistema **264** tiene dos excepciones hardcodeadas: (1) en el routing CSI, se salta el ruteo estándar (`NEXT SENTENCE`) procesándose siempre localmente; (2) en la inicialización, recibe `CHANGE ATTRIBUTE TITLE` propio (LIB-CONS0264). Adicionalmente, en la inicialización hay código comentado para el sistema **501** (`*CHANGE ATTRIBUTE TITLE OF "LIB-CONS0501"`), lo que indica que el sistema 501 estuvo incluido y fue excluido deliberadamente en una versión posterior — riesgo de historia de cambios incompleta.

**Trigger:** Petición online para sistema 264 (siempre se procesa localmente sin ruteo CSI).

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-B04-SISTEMA` | 9(04) | Número de sistema; valor 264 activa ambas excepciones |
| `WKS-SIS-NUME` | 9(04) | Número de sistema en el mensaje activo |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-BIT264-SISTEMA` | CAMPO-NUM | Efimero | Código del sistema contable en bitácora formato 264 |
| `A00-BIT264-CSI-DEST` | CAMPO-NUM | Efimero | CSI destino en bitácora 264 — no aplica routing estándar |

**Fórmula / pseudocódigo:**
```
IF SISTEMA = 264 THEN
  CHANGE ATTRIBUTE TITLE OF "LIB-CONS0264"  (inicialización especial)
  EN ROUTING: NEXT SENTENCE → sin redirect CSI (siempre proceso local)
* Sistema 501: comentado; LIB-CONS0501 no se carga; tampoco NEXT SENTENCE
```

**Excepciones documentadas:**
- LIB-CONS0501 puede existir en el sistema Unisys pero nunca se carga en P010 (excluido deliberadamente)
- `* OR 501` comentado en NEXT SENTENCE → sistema 501 sigue el ruteo CSI estándar si aparece en un mensaje

**Traza de código:**
- Línea 11039: `IF WKS-B04-SISTEMA = 264` → `CHANGE ATTRIBUTE TITLE OF "LIB-CONS0264"` — inicialización especial
- Línea 10986: `*CHANGE ATTRIBUTE TITLE OF "LIB-CONS0501"` — sistema 501 comentado (excluido)
- Línea 10988: `*CHANGE ATTRIBUTE TITLE OF "LIB-L002S501"` — confirmación de exclusión de 501
- Línea 16253: `IF WKS-SIS-NUME = 264` → `NEXT SENTENCE` — excepción de ruteo CSI
- Línea 16254: `* OR 501` — sistema 501 también fue excluido del NEXT SENTENCE

**Riesgos de migración:** La historia del sistema 501 (incluido → excluido → comentado) indica un cambio de funcionalidad que puede no estar documentado. Antes de la migración, debe validarse con SME si el sistema 501 debe incluirse en el target o si su exclusión es permanente. El sistema 264 requiere su propio microservicio de consulta en el target.

**Estado validación:** pendiente HITL

---

### RN-S151-271 — Pantalla P01: menú de selección (WKS-ENT-P01NUMTRA 1-99)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-271 |
| **Nombre** | Pantalla P01: menú de selección (WKS-ENT-P01NUMTRA 1-99) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | UI |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | N/A |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La Pantalla P01 es el menú de entrada del hub S151 para consultas de sucursales del día. El usuario ingresa un número de transacción (`WKS-ENT-P01NUMTRA`, 1-99) que determina la pantalla a activar. El código valida que el número ingresado esté dentro de los valores permitidos (11, 12, 13, 15, 18, 19, y otros) antes de realizar el dispatch. Números fuera del rango válido retornan error.

**Trigger:** Primera pantalla que ve el usuario al conectar al hub S151 (MENÚ DE SUCURSALES TRANSACCIONES DEL DIA).

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `WKS-ENT-P01NUMTRA` | 9(02) | Número de transacción seleccionada (1-99) (línea 444) |
| `WKS-ENT-P01-DAT` | X(80) | Buffer de datos de la pantalla P01 (línea 442) |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `MOVIMIENTOS` | ENTIDAD | bcop-cruzada | Los movimientos son el objeto de consulta que el menú P01 da acceso |

**Fórmula / pseudocódigo:**
```
DISPLAY pantalla P01 (MENÚ DE SUCURSALES TRANSACCIONES DEL DIA)
RECEIVE WKS-ENT-P01NUMTRA (1-99)
IF NUMTRA IN (11,12,13,15,18,19,...) → dispatch a pantalla correspondiente
ELSE → error: número de transacción inválido
```

**Excepciones documentadas:**
- Valores fuera del catálogo válido → comportamiento del IF-ELSE en cascada; puede no tener mensaje de error específico
- Error en P01 bloquea acceso completo al hub S151 para ese terminal; no hay pantalla de recuperación alternativa

**Traza de código:**
- Línea 438: `** PANTALLA 01 (MENU DE SUCURSALES TRANSACCIONES DEL DIA)`
- Línea 442: `02 WKS-ENT-P01 REDEFINES WKS-ENT-TEXTO`
- Línea 444: `04 WKS-ENT-P01NUMTRA PIC 9(02)` — número de transacción 1-99
- Línea 12222: `310001-PANTALLA-01.` — paragraph de procesamiento de P01
- Línea 12228: `IF WKS-ENT-P01NUMTRA = 11 OR 12 OR 13 OR 15 OR 18 OR 19 OR ...` — validación de valores permitidos

**Riesgos de migración:** En el target, el menú P01 debe reemplazarse por una API de routing donde el "número de transacción" se mapea a un endpoint específico. El catálogo de números válidos (11-19, 21-29, etc.) debe externalizarse como tabla de routing en lugar de estar hardcodeado en un IF-ELSE en cascada.

**Estado validación:** pendiente HITL

---

### RN-S151-272 — Validación de supervisor (CVE-SUP): error 35 si inválido → doble control en P81/P82/P83

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-272 |
| **Nombre** | Validación de supervisor (CVE-SUP): error 35 si inválido → doble control en P81/P82/P83 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-01 |
| **bian_ref** | 2.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | SEGURIDAD |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CUB — doble control para operaciones administrativas de alto impacto; segregación de funciones en modificación de parámetros de sistema |
| **Programa ejecutor** | P010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Toda operación en las pantallas de administración del sistema (P81, P82, P83 y similares) requiere la validación de una clave de supervisor (`CVE-SUP`) mediante el paragraph `420100-VALIDA-CVE-SUP`. Si la clave no es válida (campo no numérico o igual a cero — condición `NOT W88-NUM-SUP`), se emite el código de error **35** (`ERR035`). Este mecanismo implementa el principio de doble control: el operador ingresa la operación y el supervisor la autoriza con su clave.

**Trigger:** Toda operación de alta, modificación o baja en pantallas P81, P82, P83, P84, P86.

**Campos involucrados:**
| Campo COBOL | PIC | Rol |
|-------------|-----|-----|
| `ERR035` | X(50) | Mensaje de error para clave de supervisor inválida (línea 4106) |
| `W77-RES-MSG` | — | Código de error: 35 = supervisor inválido |
| `W88-NUM-SUP` | — | Condición 88 que valida que CVE-SUP es numérico y > 0 |
| `WKS-NOMINA-ALFA` | X | Nómina del supervisor en alfanumérico para validación |
| `WKS-NOMINA-NUME` | 9 | Nómina del supervisor en numérico tras JUSTIFIER |

**Vocabulario relacionado (vocab-s151.md):**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-BIT-TIPO-OPERACION` | CAMPO-ALFA | Efimero | Tipo de operación auditada en bitácora — las operaciones con CVE-SUP se registran |
| `A00-BIT-SISTEMA` | CAMPO-NUM | Efimero | Sistema sobre el que se aplica el doble control administrativo |

**Fórmula / pseudocódigo:**
```
420100-VALIDA-CVE-SUP:
  CALL JUSTIFIER USING WKS-NOMINA-ALFA → validar numericidad
  IF NOT W88-NUM-SUP (no numérico O campo = 0) THEN
    MOVE 35 TO W77-RES-MSG → bloquear operación administrativa
```

**Excepciones documentadas:**
- W88-NUM-SUP valida solo numericidad y >0; no verifica que la nómina exista en el sistema IAM del banco
- Invocado desde 6+ puntos en P81/P82/P83; cada modificación individual requiere re-validación de supervisor

**Traza de código:**
- Línea 4106: `03 ERR035 PIC X(50)` — mensaje de error 35
- Línea 16454: `420100-VALIDA-CVE-SUP.`
- Línea 16455: `IF NOT W88-NUM-SUP`
- Línea 16456: `MOVE 35 TO W77-RES-MSG` — error: supervisor inválido
- Línea 14215: `PERFORM 420100-VALIDA-CVE-SUP` — invocación desde P81
- Línea 14277: `PERFORM 420100-VALIDA-CVE-SUP` — invocación adicional desde P81
- Línea 14375: `PERFORM 420100-VALIDA-CVE-SUP` — invocación desde P82
- Línea 14462, 14531, 14640: invocaciones adicionales desde P82 y P83

**Riesgos de migración:** El doble control operador+supervisor debe replicarse en el target como flujo de aprobación (4-eyes principle): la operación administrativa queda en estado PENDIENTE hasta que un usuario con rol SUPERVISOR la aprueba. Este patrón puede implementarse con un workflow engine o con un endpoint de aprobación separado. La nómina del supervisor debe mapearse a un ID de usuario en el sistema IAM del target.

**Estado validación:** pendiente HITL
