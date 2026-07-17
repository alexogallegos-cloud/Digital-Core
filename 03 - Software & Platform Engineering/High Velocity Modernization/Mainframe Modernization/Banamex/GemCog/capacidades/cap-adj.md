# cap-adj — GL Adjustments & Synchronization — Pipeline Extracción e Integración de Saldos [S151]
> Capacidad bancaria: 7.1.1-bc09 · Dominio: 7 — Enterprise Support Functions
> Sistema: S151 (Contabilidad General Ledger) · Unisys ClearPath MCP / DMSII
> Programas: P312 (SALDOS084) · P330 (Extracción DMSII→planos) · P360 (Integración planos→DMSII)
> Reglas: RN-S151-710..718 · RN-S151-720..732 · RN-S151-735..749 (37 reglas)
> Generado: 2026-07-16 · GemCog Capa 3

---

## Contexto funcional

BC-09 Ajustes GL S151 es el pipeline batch que extrae e integra el estado completo del General Ledger entre instancias de S151. Sirve a cuatro casos de uso operacionales: (1) reorganización de base de datos DMSII —cuando el motor de saldos necesita reconstruirse desde cero—, (2) replicación cross-CSI entre centros de cómputo (VDM↔MTY), (3) separación corporativa Citi→Banamex (Divestiture 2024-2026), y (4) ajustes de cierre de período contable. El pipeline extrae el estado completo de seis estructuras DMSII a archivos planos temporales (P330) y las re-integra en la base de saldos destino (P360), usando un pack de disco compartido como área de intercambio.

P312 es un programa satélite que corre en paralelo con la extracción: genera el archivo SALDOS084 con saldos de contratos para el sistema externo S084 Cobertura Monterrey. P312 está dedicado a un único nodo geográfico (nodo=04, Monterrey, hardcoded), un único tipo de producto (PRD=1, INS=3, MON=1) y produce un archivo con estructura Header-Detalle-Trailer (FUNCION 01/02/09). No forma parte del pipeline P330→P360 — comparte la lectura de la misma base de saldos pero escribe a un destino completamente diferente, y solo consume hasta 25 conceptos contables por contrato según una whitelist de 16 valores.

P330 (~2,506 LOC) es el primer paso del pipeline GL: lee las seis estructuras DMSII de la base fuente en modo INQUIRY y escribe cada una a un archivo plano en pack compartido. Las estructuras son: B20 (saldos mensuales por contrato, 10 slots), B21 (saldos mensuales variante con indicador, 12 slots), B70 (posición por CSI/fecha/producto, 10 slots), B71 (posición adicional con indicador, 12 slots), B72 (posición contable con SDOANT/CARGOS/ABONOS/SDOACT) y B80 (estado de cuenta por contrato, blob de 146 bytes). Cada archivo se cierra con `CLOSE WITH LOCK` como barrera de integridad. P360 (~2,538 LOC) lee esos archivos, ordena cada uno por su clave canónica, integra los registros en la base destino mediante operaciones STORE de DMSII, y destruye los archivos temporales con `CLOSE WITH PURGE`. Ambos programas son multi-instancia por parámetro: el mismo ejecutable procesa cualquier instancia de S151 variando el número de sistema.

**Riesgo de modernización crítico**: este pipeline no es migratable as-is. Su función —copiar el estado completo del GL de una instancia a otra— es un mecanismo de compensación por las limitaciones de replicación nativa de DMSII. En la arquitectura destino, el mismo caso de uso debe rediseñarse como sincronización event-driven entre instancias del GL moderno: Change Data Capture (CDC), replicación de eventos de dominio, o streaming de saldos vía Kafka. Los archivos planos intermedios, los mecanismos WITH LOCK / WITH PURGE y el patrón ATTRIBUTE VALUE OF MYSELF son específicos de Unisys MCP y no tienen equivalente directo fuera de ese ecosistema.

---

## Inventario de Tareas

### P312 — Generación de archivo SALDOS084

| ID | Tarea | Componente fuente | Tipo |
|----|-------|-------------------|------|
| T-ADJ-P312-001 | Consultar LIBCONTROL vía CONSISDIA y CONSISMEN (sistema 500) para obtener FECCON, FECPRO151 y nombre físico de la base de saldos (WKS-B03-NOMBDSAL) | COBOL_P312.txt | inicialización |
| T-ADJ-P312-002 | Establecer nodo de origen como Cobertura Monterrey (VALUE 04 hardcoded en WKS-NODO-ORIGEN-S084); incrustar en título del archivo WKS-TIT-SDOS084 | COBOL_P312.txt | control-datos |
| T-ADJ-P312-003 | Construir título dinámico del archivo SALDOS084 con fecha AAMMDD (de WKS-FECHA-AAMMDD) vía CHANGE ATTRIBUTE TITLE; abrir con SECURITYTYPE=PUBLIC | COBOL_P312.txt | control-datos |
| T-ADJ-P312-004 | Aplicar filtro fijo producto=1, instrumento=3, moneda=1 en cada búsqueda a B80SXEDOCTA y B20SXSDOMENCON | COBOL_P312.txt | validación |
| T-ADJ-P312-005 | Escribir registro Header en SALDOS084 (FUNCION=01, sisorigen=151, sistema=084, fecha de proceso FECPRO151) | COBOL_P312.txt | escritura |
| T-ADJ-P312-006 | Iterar secuencialmente por contratos en B80SXEDOCTA y leer saldos mensuales B20SXSDOMENCON por cada contrato encontrado | COBOL_P312.txt | lectura |
| T-ADJ-P312-007 | Filtrar conceptos B20 por whitelist W88-CONCEPTOS (16 valores: 02,05..09,13,15,29,30,34..36,43..45) y descartar si saldo=0 Y movimientos=0 | COBOL_P312.txt | validación |
| T-ADJ-P312-008 | Verificar indicador B20-SDO-APUIMP > 0 antes de entrar al loop de lectura de apuntes extendidos B21SXSDMENCON1 | COBOL_P312.txt | control-datos |
| T-ADJ-P312-009 | Calcular código de concepto lineal B21 con fórmula W77-CONCEPTO = B21-SDO-KEYIND × 12 + W77-IND1 - 2; validar contra whitelist; límite 25 conceptos totales | COBOL_P312.txt | cálculo |
| T-ADJ-P312-010 | Escribir registro Detalle por contrato (FUNCION=02, hasta 25 conceptos en WKS-DET-SDOS084); Trailer final (FUNCION=09, total=WKS-CONT-GRAB); cerrar SALDOS084 WITH SAVE | COBOL_P312.txt | escritura |

---

### P330 — Extracción DMSII → Archivos Planos

| ID | Tarea | Componente fuente | Tipo |
|----|-------|-------------------|------|
| T-ADJ-P330-001 | Recibir parámetros WKS-PARAM-SIS (3 dígitos) y WKS-NOMBRE-PACK (12 chars) vía PROCEDURE DIVISION USING; propagar pack a los seis títulos de archivos planos de salida | COBOL_P330.txt | inicialización |
| T-ADJ-P330-002 | Validar tipo de base de saldos: ESTATUS=3 desde B04SISTEMA y TIPBD in(1,2,5,6) desde B03SISMEN vía LIBCONTROL; terminar con STATUS=-1 si cualquier validación falla | COBOL_P330.txt | validación |
| T-ADJ-P330-003 | Determinar fecha de proceso: si ATTRIBUTE VALUE OF MYSELF = 0 → consultar CONSISDIA (WKS-B01-FECPRO); si ≠ 0 → usar atributo de corrida como override para reprocesos | COBOL_P330.txt | control-datos |
| T-ADJ-P330-004 | Convertir fechas de 2 a 4 dígitos con copybook CRONOS2K: AA < 50 → siglo 20 (2000-2049); AA ≥ 50 → siglo 19 (1950-1999); pivote A2K-BASE-YEAR = 50 | COBOL_P330.txt | transformación |
| T-ADJ-P330-005 | Extraer B20SDOMENCON a archivo plano: cursor filtrado KEYAM=AAAAMM / PRD=1 / INS=3 para sistema 500; FIND FIRST completo (sin filtro) para otros sistemas | COBOL_P330.txt | extracción |
| T-ADJ-P330-006 | Extraer B21SDMENCON1 a archivo plano: misma bifurcación S500/otros que B20; diferencia estructural: KEYIND en lugar de KEYMON y array de 12 saldos vs. 10 de B20 | COBOL_P330.txt | extracción |
| T-ADJ-P330-007 | Extraer B70POSICION y B71POSDIAAD1 a archivos planos: lectura completa sin bifurcación por sistema para ambas; B71 tiene KEYIND adicional en la clave y 12 slots vs. 10 de B70 | COBOL_P330.txt | extracción |
| T-ADJ-P330-008 | Extraer B72POSCONTA a archivo plano: registro completo con SDOANT, CARGOS, ABONOS, SDOACT, NATCTA; clave de 10 campos; acumular SDOACT en WS-TOTALB72SDOACT | COBOL_P330.txt | extracción |
| T-ADJ-P330-009 | Extraer B80EDOCTA a archivo plano: forzar WKS-FECPRO-DD=1 (normalizar al primer día del mes) antes de cada FIND; filtro FECCON NOT < fecha normalizada y PRD=1/INS=3 para S500 | COBOL_P330.txt | extracción |
| T-ADJ-P330-010 | Acumular totales de control diferenciados por estructura: SD(2) para B20/B21/B70/B71; SDOACT para B72; solo conteo de registros para B80 (sin importe) | COBOL_P330.txt | control |
| T-ADJ-P330-011 | Manejar errores DMSII en FIND: DMSTATUS(NOTFOUND) → flag WS-EOF-Bxx=1 (fin normal de dataset); cualquier otro código → emitir mensaje LJ + CALL SYSTEM DMTERMINATE (aborto con dump) | COBOL_P330.txt | error |
| T-ADJ-P330-012 | Cerrar cada archivo plano con CLOSE WITH LOCK al completar su extracción; secuencia: R20→R21→R70→R71→R72→R80; base SALDOS cierra sin LOCK (ON EXCEPTION NEXT SENTENCE) | COBOL_P330.txt | control-datos |
| T-ADJ-P330-013 | Ejecutar las seis extracciones en secuencia fija y no paralelizable: B20→B21→B70→B71→B72→B80; un fallo con DMTERMINATE deja las estructuras subsiguientes sin extraer | COBOL_P330.txt | control-datos |

---

### P360 — Integración Archivos Planos → DMSII

| ID | Tarea | Componente fuente | Tipo |
|----|-------|-------------------|------|
| T-ADJ-P360-001 | Recibir parámetros WKS-PARAM-SIS y WKS-NOMBRE-PACK vía PROCEDURE DIVISION USING; propagar pack a los seis títulos de archivos planos de entrada | COBOL_P360.txt | inicialización |
| T-ADJ-P360-002 | Resolver fecha de proceso: CONSISDIA (WKS-B01-FECPRO) si ATTRIBUTE VALUE OF MYSELF = 0; override explícito si ≠ 0 (reproceso histórico) | COBOL_P360.txt | control-datos |
| T-ADJ-P360-003 | Validar WKS-B04-ESTATUS = 3 del sistema destino desde B04SISTEM vía LIBCONTROL; emitir mensaje y terminar con STATUS=-1 si distinto | COBOL_P360.txt | validación |
| T-ADJ-P360-004 | Validar WKS-B03-TIPBD in(1,2,5,6) desde B03SISMEN vía CONSISMEN; emitir "EL SISTEMA NO UTILIZA BASE DE SALDOS" y STATUS=-1 si fuera de rango | COBOL_P360.txt | validación |
| T-ADJ-P360-005 | Obtener nombre físico de la base destino (WKS-B03-NOMBDSAL); abrir dinámicamente en modo UPDATE vía CHANGE ATTRIBUTE TITLE OF SALDOS + OPEN UPDATE | COBOL_P360.txt | control-datos |
| T-ADJ-P360-006 | Ordenar B20SDOMENCON ascendente por (AM, CON, PRD, INS, MON) e integrar a DMSII: CREATE + STORE por cada registro con 10 slots CNTMOV/SD; acumular SD(2) en WS-TOTALB20SDOSD2 | COBOL_P360.txt | integración |
| T-ADJ-P360-007 | Ordenar B21SDMENCON1 ascendente por (AM, CON, PRD, INS) e integrar: CREATE + STORE con clave KEYIND y 12 slots CNTMOV/SD; acumular SD(2) en WS-TOTALB21SDOSD2 | COBOL_P360.txt | integración |
| T-ADJ-P360-008 | Ordenar B70POSICION ascendente por (CSI, FEC, PRD, INS, MON) e integrar: saldos S9(15)V9(02) de mayor precisión que B20/B21; acumular SD(2) en WS-TOTALB70SDOSD2 | COBOL_P360.txt | integración |
| T-ADJ-P360-009 | Ordenar B71POSDIAAD1 ascendente por (CSI, FEC, PRD, INS, MON, IND) e integrar: clave extendida con KEYIND, 12 slots; acumular SD(2) en WS-TOTALB71SDOSD2 | COBOL_P360.txt | integración |
| T-ADJ-P360-010 | Ordenar B72POSCONTA por los 10 campos de clave e integrar: STORE con SDOANT, CARGOS, ABONOS, SDOACT, NATCTA como registro contable completo; acumular SDOACT en WS-TOTALB72SDOACT | COBOL_P360.txt | integración |
| T-ADJ-P360-011 | Ordenar B80EDOCTA por (FECCON, CON, PRD, INS) e integrar: STORE con blob DATOS de 146 bytes; solo conteo WS-INTEGRADOS-B80 (sin acumulación de importe) | COBOL_P360.txt | integración |
| T-ADJ-P360-012 | Manejar error en STORE: emitir mensaje operador código 010105, clasificar con WKS-TAB-ERRDMSII (21 tipos), llamar CALL SYSTEM DMTERMINATE (rollback atómico de toda la integración) | COBOL_P360.txt | error |
| T-ADJ-P360-013 | Generar listado de control post-integración (sección 09-0000-PROC-IMPRESION): recuento e importes por estructura (SD(2) para B20/B21/B70/B71; SDOACT para B72; solo count para B80) | COBOL_P360.txt | reporte |
| T-ADJ-P360-014 | Convertir fechas de 2 a 4 dígitos con CRONOS2K (pivote 50) para formatear fecha de corrida en encabezados del listado de control | COBOL_P360.txt | transformación |
| T-ADJ-P360-015 | Ejecutar integración en secuencia canónica B20→B21→B70→B71→B72→B80; cerrar cada archivo con CLOSE WITH PURGE (eliminación destructiva) tras confirmar integración exitosa | COBOL_P360.txt | control-datos |

---

## Casuísticas

### CS-ADJ-01: Happy path — extracción completa y re-integración sin errores
**Tipo:** happy-path
**Condición de entrada:** Base fuente disponible con ESTATUS=3, TIPBD válido; parámetros SIS y PACK correctos; 6 estructuras con datos; base destino abierta en UPDATE.
**Resultado:** P330 extrae las 6 estructuras secuencialmente, cada una cerrada con LOCK. P360 ordena, integra y purga cada archivo. El listado de control de P360 cuadra con los totales acumulados por P330. En paralelo, P312 genera SALDOS084 con saldos de contratos PRD=1/INS=3/MON=1 para S084.
**Secuencia:**
```
[P312, paralelo]
  T-ADJ-P312-001 (LIBCONTROL OK) → T-ADJ-P312-002 (nodo=04)
  → T-ADJ-P312-003 (título dinámico) → T-ADJ-P312-005 (Header)
  → T-ADJ-P312-006 (itera B80→B20) → T-ADJ-P312-007 (whitelist)
    → opt T-ADJ-P312-008 (APUIMP>0) → T-ADJ-P312-009 (fórmula B21)
  → T-ADJ-P312-010 (Detalle + Trailer + SAVE)

[P330]
  T-ADJ-P330-001 (params) → T-ADJ-P330-002 (ESTATUS=3, TIPBD OK)
  → T-ADJ-P330-003 (fecha proceso) → T-ADJ-P330-004 (CRONOS2K)
  → T-ADJ-P330-005..009 (extrae B20..B80, 6 LOCK) → T-ADJ-P330-010 (totales)

[P360, tras completar P330]
  T-ADJ-P360-001 (params) → T-ADJ-P360-002..005 (validación + OPEN UPDATE)
  → T-ADJ-P360-006..011 (integra B20..B80, 6 PURGE) → T-ADJ-P360-013 (listado OK)
```

---

### CS-ADJ-02: Fallo durante extracción de B72 — archivos planos parciales sin detección
**Tipo:** error-sistema (crítico)
**Condición de entrada:** P330 completó B20, B21, B70, B71 (4 archivos cerrados con LOCK). Durante la extracción de B72POSCONTA ocurre un error DMSII distinto a NOTFOUND (ej. DMCATEGORY=DEADLOCK).
**Resultado:** P330 llama DMTERMINATE y aborta. B72 y B80 no se extraen. El pack tiene 4 archivos con LOCK y 2 ausentes. Si P360 se ejecuta a continuación (sin validación de completitud), integrará B20..B71 correctamente pero fallará al intentar abrir B72 (no existe). La base destino queda con saldos mensuales y de posición actualizados pero sin posición contable (B72) ni estado de cuenta (B80) — un estado de inconsistencia silenciosa que solo el listado de control revelaría.
**Secuencia:**
```
T-ADJ-P330-005..007 (B20, B21, B70, B71 → LOCK OK)
→ T-ADJ-P330-008 (B72 → DMSII ERROR ≠ NOTFOUND)
  → T-ADJ-P330-011 (DMTERMINATE — aborto P330)
  → B72, B80 sin extraer; pack incompleto
→ [si P360 ejecuta] T-ADJ-P360-006..009 (B20..B71 integrados OK)
  → T-ADJ-P360-010 (intenta abrir B72 → archivo no existe → fallo)
  → T-ADJ-P360-012 (DMTERMINATE — rollback parcial)
```

---

### CS-ADJ-03: Reproceso histórico con fecha explícita vía ATTRIBUTE VALUE OF MYSELF
**Tipo:** flujo-operacional (reproceso)
**Condición de entrada:** Operador pasa fecha histórica (ej. 20260630) como ATTRIBUTE VALUE al ejecutar P330 y P360. Valor ≠ 0 en ambos programas.
**Resultado:** P330 usa la fecha explícita como fecha de proceso en lugar de consultar CONSISDIA (T-ADJ-P330-003). B20/B21 se extraen con filtro KEYAM correspondiente al mes histórico. B80 se filtra por FECCON NOT < primer día del mes histórico. P360 también resuelve la misma fecha explícita (T-ADJ-P360-002) y la usa en el encabezado del listado de control. El resultado es una re-integración del estado GL tal como estaba al cierre del mes histórico.
**Secuencia:**
```
[P330] ATTRIBUTE VALUE OF MYSELF = 20260630
  → T-ADJ-P330-003: WKS-FECHA-PROCESO = 20260630 (override)
  → T-ADJ-P330-005: B20 filtrado KEYAM=202606
  → T-ADJ-P330-009: B80 filtrado FECCON NOT < 20260601 (DD normalizado a 01)
  → Extracción histórica completa

[P360] ATTRIBUTE VALUE OF MYSELF = 20260630
  → T-ADJ-P360-002: WKS-FECHA-PROCESO = 20260630 (override)
  → T-ADJ-P360-013: listado encabezado con fecha 20260630
```

---

### CS-ADJ-04: Reorganización BD — misma instancia S151, distinto volumen DMSII
**Tipo:** flujo-operacional (reorganización)
**Condición de entrada:** La base de saldos de la instancia XXX necesita ser reconstruida en un volumen nuevo (CMEMP2) por fragmentación o fallo de disco. La instancia fuente y destino tienen el mismo número de sistema XXX pero nombres físicos de BD distintos.
**Resultado:** P330 extrae de la base en CMEMP1 (nombre en B03SISMEN actualizado a la BD vieja). Antes de ejecutar P360, el operador actualiza B03SISMEN para que el nombre de la BD apunte a la nueva ubicación en CMEMP2. P360 abre dinámicamente la BD nueva (T-ADJ-P360-005), integra las 6 estructuras y la base reconstruida queda operativa. El número de sistema es el mismo en P330 y P360.
**Secuencia:**
```
[Operador] Actualiza B03SISMEN: NOMBDSAL → BD en CMEMP2
[P330] SIS=XXX, PACK=PACKXXX → extrae de CMEMP1 → 6 archivos LOCK
[P360] SIS=XXX, PACK=PACKXXX → CONSISMEN devuelve NOMBDSAL en CMEMP2
  → T-ADJ-P360-005: CHANGE ATTRIBUTE TITLE OF SALDOS TO CMEMP2
  → integra B20..B80 en BD nueva → 6 PURGE → BD reconstruida
```

---

### CS-ADJ-05: Replicación cross-CSI — fuente VDM, destino MTY
**Tipo:** flujo-operacional (replicación)
**Condición de entrada:** Se necesita sincronizar el GL de la instancia VDM (número de sistema=VDM) hacia la instancia MTY (número de sistema=MTY) para operación en contingencia.
**Resultado:** P330 se ejecuta con SIS=VDM y extrae las 6 estructuras incluyendo B70/B71 que contienen el campo KEYCSI. La clave CSI se extrae tal como está, sin transformación. P360 se ejecuta con SIS=MTY y carga esos mismos registros (con KEYCSI original de VDM) en la base MTY. La base MTY queda con datos de VDM — el campo KEYCSI no se remapea automáticamente, lo que puede causar inconsistencias semánticas si los CSIs de VDM no existen en MTY.
**Secuencia:**
```
[P330] SIS=VDM, PACK=PACKREPL → extrae B70/B71 con KEYCSI=VDM
[P360] SIS=MTY, PACK=PACKREPL → integra B70/B71 con KEYCSI=VDM (sin transformar)
  → [Riesgo] KEYCSI de VDM en base MTY: puede causar descuadres en reportes CSI
```

---

### CS-ADJ-06: Sistema destino bloqueado — ESTATUS ≠ 3 en P360
**Tipo:** error-operacional
**Condición de entrada:** P330 completó extracción exitosamente (6 archivos en pack con LOCK). Al ejecutar P360, el sistema destino tiene ESTATUS ≠ 3 en B04SISTEM (ej. ESTATUS=2, en proceso de cierre).
**Resultado:** P360 detecta ESTATUS ≠ 3 en T-ADJ-P360-003, emite mensaje de error al operador y termina con STATUS=-1. Ninguna de las 6 estructuras se integra. Los archivos del pack quedan sin PURGE — permanecen en el pack con LOCK hasta que el operador los elimine manualmente o reintente P360. Si no se limpian, una re-ejecución de P330 intentará escribir archivos que ya existen en el pack, causando conflicto de títulos.
**Secuencia:**
```
[P330] OK → 6 archivos LOCK en PACK
[P360] T-ADJ-P360-003: B04SISTEM → WKS-B04-ESTATUS ≠ 3
  → CHANGE ATTRIBUTE STATUS OF MYSELF TO -1
  → WFL: abort (6 archivos en pack sin PURGE, requieren limpieza manual)
```

---

## Diagrama

```mermaid
sequenceDiagram
    participant WFL as WFL LOTE
    participant P312 as P312 (SALDOS084)
    participant P330 as P330 (Extracción)
    participant LIBCON as LIBCONTROL
    participant BASESDO as BD11SDOSfuente (DMSII)
    participant PACK as Pack Disco (6 archivos planos)
    participant P360 as P360 (Integración)
    participant DMDEST as BD11SDOSdestino (DMSII)
    participant S084 as Sistema S084 MTY

    WFL->>P312: INITIATE (nodo=04, sistema=500)
    WFL->>P330: INITIATE (SIS=xxx, PACK=packname)

    par Pipeline S084 independiente
        P312->>LIBCON: CONSISDIA + CONSISMEN (sistema 500)
        LIBCON-->>P312: FECCON · FECPRO151 · NOMBDSAL
        P312->>P312: Construye título SALDOS084 (nodo 04 hardcoded + fecha AAMMDD)
        P312->>BASESDO: OPEN INQUIRY
        P312->>S084: WRITE Header (FUNCION=01)
        loop Por cada contrato en B80SXEDOCTA (PRD=1·INS=3)
            P312->>BASESDO: FIND B20SXSDOMENCON → filtra whitelist 16 conceptos
            opt B20-SDO-APUIMP > 0
                P312->>BASESDO: FIND B21SXSDMENCON1
                P312->>P312: Calcula W77-CONCEPTO = KEYIND×12+IND1-2
            end
            P312->>S084: WRITE Detalle (FUNCION=02 · ≤25 conceptos)
        end
        P312->>S084: WRITE Trailer (FUNCION=09 · WKS-CONT-GRAB) + CLOSE WITH SAVE

    and Pipeline GL P330→P360
        P330->>LIBCON: B04SISTEMA + CONSISMEN (SIS=xxx)
        LIBCON-->>P330: ESTATUS · TIPBD · NOMBDSAL
        alt ESTATUS≠3 or TIPBD not in 1,2,5,6
            P330->>WFL: STATUS=-1 (abort — sin extracción)
        else OK
            P330->>BASESDO: OPEN INQUIRY (nombre dinámico de B03SISMEN)
            Note over P330: ATTRIBUTE VALUE=0 → fecha de CONSISDIA<br/>ATTRIBUTE VALUE≠0 → fecha de override (reproceso)
            P330->>PACK: Extrae B20SDOMENCON (S500: filtro PRD·INS·KEYAM) → CLOSE WITH LOCK
            P330->>PACK: Extrae B21SDMENCON1 (S500: filtro PRD·INS·KEYAM; KEYIND+12 slots) → CLOSE WITH LOCK
            P330->>PACK: Extrae B70POSICION (completo, sin filtro) → CLOSE WITH LOCK
            P330->>PACK: Extrae B71POSDIAAD1 (completo, KEYIND adicional) → CLOSE WITH LOCK
            P330->>PACK: Extrae B72POSCONTA (SDOANT·CARGOS·ABONOS·SDOACT·NATCTA) → CLOSE WITH LOCK
            P330->>PACK: Extrae B80EDOCTA (FECCON≥día1·PRD=1·INS=3 para S500) → CLOSE WITH LOCK
            P330->>WFL: OK — 6 archivos disponibles con LOCK

            WFL->>P360: INITIATE (SIS=xxx, PACK=packname)
            P360->>LIBCON: B04SISTEM + CONSISMEN (validación destino)
            alt ESTATUS≠3 or TIPBD inválido
                P360->>WFL: STATUS=-1 (abort — archivos sin PURGE; requieren limpieza manual)
            else OK
                P360->>DMDEST: CHANGE ATTRIBUTE TITLE + OPEN UPDATE (nombre dinámico)
                Note over P360: ATTRIBUTE VALUE=0 → fecha de CONSISDIA<br/>ATTRIBUTE VALUE≠0 → override
                P360->>PACK: Lee B20 → SORT(AM·CON·PRD·INS·MON) → STORE×n → CLOSE WITH PURGE
                P360->>PACK: Lee B21 → SORT(AM·CON·PRD·INS) → STORE×n (12 slots) → CLOSE WITH PURGE
                P360->>PACK: Lee B70 → SORT(CSI·FEC·PRD·INS·MON) → STORE×n → CLOSE WITH PURGE
                P360->>PACK: Lee B71 → SORT(CSI·FEC·PRD·INS·MON·IND) → STORE×n → CLOSE WITH PURGE
                P360->>PACK: Lee B72 → SORT(10 campos) → STORE×n (SDOANT·CARGOS·ABONOS·SDOACT) → CLOSE WITH PURGE
                P360->>PACK: Lee B80 → SORT(FECCON·CON·PRD·INS) → STORE×n (blob 146B) → CLOSE WITH PURGE
                P360->>WFL: Listado de control OK (recuentos + totales por estructura)
            end
        end
    end
```

---

## Reglas vinculadas

| Tarea | Regla | Programa | Descripción | Tags |
|-------|-------|----------|-------------|------|
| T-ADJ-P312-001 | RN-S151-717 | P312 | Consulta LIBCONTROL: CONSISDIA + CONSISMEN sistema 500 — obtiene fechas y nombre de BD | — |
| T-ADJ-P312-002 | RN-S151-711 | P312 | Nodo origen 04 (Monterrey) hardcoded en WKS-NODO-ORIGEN-S084 VALUE 04 | `[HARDCODE-SOSPECHOSO]` |
| T-ADJ-P312-003 | RN-S151-712 | P312 | Título dinámico SALDOS084: prefijo fijo + nodo + "/" + fecha AAMMDD + "." | — |
| T-ADJ-P312-004 | RN-S151-713 | P312 | Filtro fijo PRD=1 / INS=3 / MON=1 aplicado en B80SXEDOCTA y B20SXSDOMENCON | `[HARDCODE-SOSPECHOSO]` |
| T-ADJ-P312-005 | RN-S151-716 | P312 | Estructura tres segmentos SALDOS084: Header FUNCION=01 con sisorigen=151 / sistema=084 | — |
| T-ADJ-P312-006 | RN-S151-710 | P312 | Generación batch completa: iteración B80SXEDOCTA → B20 → B21 → SALDOS084 | — |
| T-ADJ-P312-007 | RN-S151-714 | P312 | Whitelist 16 conceptos W88-CONCEPTOS; descarta si SD=0 Y CNTMOV=0 | `[HARDCODE-SOSPECHOSO]` |
| T-ADJ-P312-008 | RN-S151-718 | P312 | APUIMP > 0 como gate para procesamiento B21; optimización acceso DMSII | — |
| T-ADJ-P312-009 | RN-S151-715 | P312 | Fórmula B21: W77-CONCEPTO = W77-IND × 12 + W77-IND1 - 2; límite 25 conceptos/registro | — |
| T-ADJ-P312-010 | RN-S151-716 | P312 | Detalle FUNCION=02 (hasta 25 conceptos) + Trailer FUNCION=09 + CLOSE WITH SAVE | — |
| T-ADJ-P330-001 | RN-S151-720 | P330 | Parametrización multi-instancia: SIS (1-999) + pack de disco → 6 títulos de archivos | — |
| T-ADJ-P330-002 | RN-S151-721 | P330 | Validación ESTATUS=3 y TIPBD in(1,2,5,6) vía B04SISTEMA + B03SISMEN antes de abrir | — |
| T-ADJ-P330-003 | RN-S151-722 | P330 | Fecha proceso: CONSISDIA si ATTRIBUTE VALUE OF MYSELF = 0; override si ≠ 0 | — |
| T-ADJ-P330-004 | RN-S151-731 | P330 | CRONOS2K: A2K-BASE-YEAR=50; AA<50→CC=20; AA≥50→CC=19 | — |
| T-ADJ-P330-005 | RN-S151-723 | P330 | B20SDOMENCON: S500 → cursor filtrado KEYAM+PRD+INS; otros → completo | — |
| T-ADJ-P330-006 | RN-S151-724 | P330 | B21SDMENCON1: S500 → filtrado; otros → completo; KEYIND + 12 slots vs 10 de B20 | — |
| T-ADJ-P330-007 | RN-S151-725 | P330 | B70POSICION: extracción completa siempre; B71 patrón análogo con KEYIND adicional | — |
| T-ADJ-P330-008 | RN-S151-727 | P330 | B72POSCONTA: única estructura con desglose SDOANT/CARGOS/ABONOS/SDOACT explícitos | `[RIESGO-CNBV]` |
| T-ADJ-P330-009 | RN-S151-726 | P330 | B80EDOCTA: WKS-FECPRO-DD=1 forzado; filtro NOT < día 1 del mes; PRD=1/INS=3 para S500 | — |
| T-ADJ-P330-010 | RN-S151-728 | P330 | Acumulación diferenciada: SD(2) para B20/B21/B70/B71; SDOACT para B72; count para B80 | — |
| T-ADJ-P330-011 | RN-S151-729 | P330 | NOTFOUND → WS-EOF-Bxx=1 (fin normal); otro → mensaje LJ + DMTERMINATE (aborto) | — |
| T-ADJ-P330-012 | RN-S151-730 | P330 | CLOSE WITH LOCK: barrera de integridad al completar cada extracción | `[RIESGO-PIPELINE]` |
| T-ADJ-P330-013 | RN-S151-732 | P330 | Secuencia fija B20→B21→B70→B71→B72→B80; aborto en cualquier punto deja estructuras sin extraer | `[RIESGO-PIPELINE]` |
| T-ADJ-P360-001 | RN-S151-735 | P360 | Parámetros SIS + PACK → propagados a los 6 títulos de archivos de entrada | — |
| T-ADJ-P360-002 | RN-S151-736 | P360 | Fecha proceso: CONSISDIA vs ATTRIBUTE VALUE OF MYSELF (misma lógica que P330) | — |
| T-ADJ-P360-003 | RN-S151-737 | P360 | Validar WKS-B04-ESTATUS = 3 desde B04SISTEM; STATUS=-1 si distinto | — |
| T-ADJ-P360-004 | RN-S151-738 | P360 | Validar TIPBD in(1,2,5,6) desde B03SISMEN; "EL SISTEMA NO UTILIZA BASE DE SALDOS" + STATUS=-1 | — |
| T-ADJ-P360-005 | RN-S151-739 | P360 | Apertura dinámica de base destino: CHANGE ATTRIBUTE TITLE OF SALDOS + OPEN UPDATE | — |
| T-ADJ-P360-006 | RN-S151-740 | P360 | B20SDOMENCON: sort (AM,CON,PRD,INS,MON) + STORE + acumula SD(2); 10 slots CNTMOV/SD | — |
| T-ADJ-P360-007 | RN-S151-741 | P360 | B21SDMENCON1: sort (AM,CON,PRD,INS) + STORE; KEYIND en lugar de KEYMON; 12 slots | — |
| T-ADJ-P360-008 | RN-S151-742 | P360 | B70POSICION: sort 5 claves (CSI,FEC,PRD,INS,MON); SD S9(15)V9(02) de mayor magnitud | — |
| T-ADJ-P360-009 | RN-S151-743 | P360 | B71POSDIAAD1: sort 6 claves (CSI,FEC,PRD,INS,MON,IND); 12 slots; complemento de B70 | — |
| T-ADJ-P360-010 | RN-S151-744 | P360 | B72POSCONTA: sort 10 claves; STORE con SDOANT/CARGOS/ABONOS/SDOACT/NATCTA | `[RIESGO-CNBV]` |
| T-ADJ-P360-011 | RN-S151-745 | P360 | B80EDOCTA: sort (FECCON,CON,PRD,INS); blob DATOS 146 bytes; PURGE al cierre | — |
| T-ADJ-P360-012 | RN-S151-746 | P360 | STORE error → msg 010105 + WKS-TAB-ERRDMSII (21 tipos) + DMTERMINATE (rollback atómico) | `[RIESGO-ATOMICIDAD]` |
| T-ADJ-P360-013 | RN-S151-747 | P360 | Listado control post-integración: recuento e importes por las 6 estructuras | — |
| T-ADJ-P360-014 | RN-S151-748 | P360 | CRONOS2K pivote 50 para fechas de encabezado del listado de control | — |
| T-ADJ-P360-015 | RN-S151-749 | P360 | Secuencia canónica B20→B21→B70→B71→B72→B80 + CLOSE WITH PURGE (eliminación destructiva) | `[RIESGO-PIPELINE]` |

---

## Hallazgos de migración

| Hallazgo | Tareas | Severidad | Acción requerida |
|----------|--------|-----------|-----------------|
| Pipeline no migratable as-is: la copia completa del GL entre instancias es un workaround a limitaciones de DMSII — en modernización rediseñar como sincronización event-driven (CDC/Kafka) entre instancias del GL moderno | T-ADJ-P330-013 · T-ADJ-P360-015 | 🔴 BLOQUEADOR | Rediseñar como Change Data Capture sobre el GL moderno; eliminar el concepto de "extracción en archivos planos" como mecanismo de integración |
| CLOSE WITH PURGE: P360 destruye los archivos fuente tras integrarlos — si P360 falla a mitad de integración (ej. DMTERMINATE en B72), los archivos ya purgados (B20..B71) son irrecuperables sin reejecutar P330 completo | T-ADJ-P360-015 · T-ADJ-P360-012 | 🔴 CRÍTICO | En arquitectura destino: no destruir archivos hasta confirmar commit de base de datos; implementar patrón transactional outbox o similar; mantener archivos en almacenamiento inmutable hasta confirmar integración total |
| Archivos planos parciales sin detección automática: si P330 aborta en B72, P360 puede ejecutarse con 4 estructuras completas y 2 ausentes sin que exista un mecanismo automático de validación de completitud del conjunto | T-ADJ-P330-013 · T-ADJ-P360-001 | 🟠 CRÍTICO | Implementar manifesto de extracción (archivo de control que lista las 6 estructuras + checksums + conteos); P360 debe validar la completitud del set antes de iniciar cualquier integración |
| ATTRIBUTE VALUE OF MYSELF: mecanismo propietario Unisys MCP sin equivalente en Java/Linux — reemplazar en migración | T-ADJ-P330-003 · T-ADJ-P360-002 | 🟠 ALTO | Reemplazar por parámetro explícito de línea de comandos (`--fecha-proceso`) o variable de entorno `S151_FECHA_PROCESO`; mantener lógica de fallback a tabla de control cuando el parámetro no se provee |
| DMTERMINATE en P360: aborto propietario DMSII que hace rollback atómico — en JDBC/JPA no existe equivalente directo | T-ADJ-P360-012 | 🟠 ALTO | Envolver las 6 integraciones (B20..B80) en una sola transacción JTA; ante cualquier excepción no recuperable: `transaction.rollback()` + log estructurado + notificación operacional; nunca usar múltiples transacciones independientes |
| Secuencialidad de las 6 extracciones en P330: pueden paralelizarse en la arquitectura destino si se confirma independencia de datos (que parece ser el caso) — en el mainframe esto tomaría ~N×tiempo_lectura | T-ADJ-P330-013 | 🟠 ALTO | Analizar con SME si existe dependencia de datos entre las 6 estructuras; si son independientes, paralelizar con hilos/async en la arquitectura destino; implementar barrera de sincronización (CountDownLatch o CompletableFuture.allOf) antes de confirmar completitud |
| B72POSCONTA (CNBV): identidad contable SDOACT = SDOANT + CARGOS - ABONOS no se valida en ninguno de los dos programas (P330 extrae, P360 integra) — un descuadre en datos originales pasa silencioso | T-ADJ-P360-010 · T-ADJ-P330-008 | 🟡 ALTO | Agregar validación de cuadratura contable en el servicio equivalente de P360; reportar registros donde SDOACT ≠ SDOANT + CARGOS - ABONOS ajustado por NATCTA; estos representan errores contables que deben escalarse a Contabilidad |
| Nodo 04 (Monterrey) y filtro PRD=1/INS=3/MON=1 hardcoded en P312: parámetros de negocio embebidos en código — nuevos productos, instrumentos o coberturas requieren recompilación | T-ADJ-P312-002 · T-ADJ-P312-004 | 🟡 MEDIO | Externalizar nodo, producto, instrumento y moneda como parámetros de configuración del servicio equivalente; documentar el significado financiero de PRD=1/INS=3/MON=1 con el SME de S084 antes de migrar |

---

*cap-adj.md · v1.0 · 2026-07-16 · GemCog Capa 3 — Inventario de Tareas + Casuísticas + Diagrama*
*Capacidad: 7.1.1-bc09 GL Adjustments & Synchronization · Sistema: S151 · Programas: P312 · P330 · P360*
*Cross-referencia: RN-S151-710..718 · RN-S151-720..732 · RN-S151-735..749 · rules-catalog/rules-s151-p312-p330-p360.md · kb-capa3-capacidades.md*
