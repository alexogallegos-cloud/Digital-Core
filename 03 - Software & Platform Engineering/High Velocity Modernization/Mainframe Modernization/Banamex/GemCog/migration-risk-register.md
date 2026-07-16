# Registro de Riesgos de Migración — Banamex GemCog S500 + S151
> Taxonomía canónica: **N1 Dominio → N2 SubDominio → N3 Capacidad → N4 Proceso → N5 Flujo (Tarea)**
> Sistemas: S500 (Captación/Cargos y Abonos) + S151 (GL — Movimientos Contables) · Unisys ClearPath MCP
> Última actualización: 2026-07-16 · v1.0 · 5/20 cap files cubiertos

---

## Convención de identificadores

| Segmento | Formato | Ejemplo |
|----------|---------|---------|
| ID de riesgo | `MR-{CAP}-{NN}` | `MR-TAR-01` |
| Fuente | `cap-{slug}.md` + tarea `T-{CAP}-{NNN}` | `cap-tar.md · T-TAR-010` |
| Taxonomía | N1 · N2 · N3 · N4 · N5 | ver columnas del catálogo |

**Severidades:**
- 🔴 `DEFECTO-PROD` — defecto activo en código que puede ejecutarse en producción sin control
- 🟠 `CRÍTICO` — riesgo de pérdida de datos, brecha regulatoria o fallo silencioso con impacto financiero
- 🟡 `ALTO` — riesgo de comportamiento incorrecto o pérdida de trazabilidad en migración
- 🟡 `MEDIO` — riesgo de deuda técnica o comportamiento no reproducible en pruebas
- 🟢 `BAJO` — riesgo menor, verificable y mitigable con bajo esfuerzo

**Patrones de riesgo:**
- `HARDCODE` — valor literal en código sin parámetro externo configurable
- `SILENCIOSO` — fallo o descarte sin traza, log ni señal al operador
- `ATOMICIDAD` — ausencia de garantía transaccional entre dos escrituras
- `PROPIETARIO-MCP` — instrucción o mecanismo nativo Unisys ClearPath sin equivalente directo
- `INTERFAZ` — contrato de interfaz frágil ante cambios de layout o texto exacto
- `REGULATORIO` — incumplimiento CNBV/Banxico/PCI-DSS si el riesgo se materializa
- `EQUIVALENCIA` — riesgo de divergencia funcional entre legacy y target en pruebas de equivalencia
- `SEGURIDAD` — defecto que compromete control de acceso o protección de datos PII

---

## Dashboard

| Métrica | Valor |
|---------|-------|
| Cap files cubiertos | 5 / 20 |
| Total de riesgos registrados | 44 |
| 🔴 DEFECTO-PROD | 2 |
| 🟠 CRÍTICO | 14 |
| 🟡 ALTO | 14 |
| 🟡 MEDIO | 13 |
| 🟢 BAJO | 1 |

### Distribución por capacidad

| Cap | Capacidad | Riesgos | 🔴 | 🟠 | 🟡A | 🟡M | 🟢 |
|-----|-----------|---------|----|----|-----|-----|-----|
| TAR | 2.2.6 ATM + 2.2.7 PoS | 7 | — | 2 | 3 | 2 | — |
| GL | 7.1.1 Finance (GL) | 8 | — | 3 | 2 | 2 | 1 |
| REC | 6.7.1 Financial Reconciliation | 10 | — | 4 | 3 | 3 | — |
| SEC | T.3.5 Security | 9 | 2 | 1 | 3 | 3 | — |
| CMP | 6.5.2 Compliance & Regulation | 10 | — | 4 | 3 | 3 | — |

### Distribución por patrón de riesgo

| Patrón | Riesgos | Capacidades afectadas |
|--------|---------|-----------------------|
| HARDCODE | 14 | TAR · GL · REC · SEC · CMP |
| SILENCIOSO | 10 | GL · REC · SEC · CMP |
| REGULATORIO | 8 | REC · CMP · GL |
| PROPIETARIO-MCP | 7 | TAR · SEC · CMP |
| EQUIVALENCIA | 5 | GL · REC · TAR |
| SEGURIDAD | 4 | SEC |
| ATOMICIDAD | 2 | TAR |
| INTERFAZ | 4 | REC · CMP · GL |

---

## Catálogo completo de riesgos

### N1: Channels — N2: Un-Assisted Touchpoints

#### N3: 2.2.6 ATM · 2.2.7 PoS — N4: P630 TARINTERCAM

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-TAR-01 | 🟠 CRÍTICO | ATOMICIDAD | T-TAR-010 + T-TAR-011 | Escritura dual S244 (Teletón) + I08 (S151 punteo) no atómica — si falla I08 después de escribir S244, S244 tiene movimiento sin contraparte en S151 | Garantizar atomicidad (saga outbox, 2PC, o escritura en orden I08 primero con rollback de S244 ante fallo) |
| MR-TAR-02 | 🟠 CRÍTICO | INTERFAZ | T-TAR-010 + T-TAR-012 | Archivos S244 y AMEXMNL son contratos de interfaz no documentados formalmente — schema asumido por sistemas downstream | Documentar schema S244 e INTELAR con versión; validar con equipos S244 e INTELAR antes de migrar |
| MR-TAR-03 | 🟡 ALTO | PROPIETARIO-MCP | T-TAR-001 + T-TAR-002 | CTLVERS (catálogo central de versiones MCP) — 2 llamadas: validación de versión y resolución dinámica de librería de fechas | Reemplazar por ConfigMap / parameter store / service registry en target |
| MR-TAR-04 | 🟡 ALTO | PROPIETARIO-MCP | T-TAR-014 | `USE AS INTERRUPT PROCEDURE` — semántica de interrupción nativa MCP sin equivalente directo | Reemplazar por signal handler / graceful shutdown en runtime target |
| MR-TAR-05 | 🟡 ALTO | PROPIETARIO-MCP | T-TAR-004 | `CALL SYSTEM DMTERMINATE` ante error DMSII — terminación abrupta propietaria | Reemplazar por exit-code no-cero con cierre limpio de archivos abiertos |
| MR-TAR-06 | 🟡 MEDIO | HARDCODE | T-TAR-007 | BINs adquirentes 454061 (Visa 3/4) y 543006 (otros) hardcoded — ISO 7812 puede cambiar rangos | Mover a tabla paramétrica configurable |
| MR-TAR-07 | 🟡 MEDIO | HARDCODE | T-TAR-003 | Nombre "TELETON" e identificadores de cadena (ORI=00, VENTANA=01) hardcoded en cabecera S244 | Parametrizar para soportar múltiples cadenas comerciales |

---

### N1: Enterprise Support Functions — N2: Finance

#### N3: 7.1.1 Finance (GL) — N4: P109 GL POSTING ENGINE

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-GL-01 | 🟠 CRÍTICO | EQUIVALENCIA | T-GL-001 | P109 procesa 15+ sistemas en un solo binario (W77-SISTEMA-PARAMETRO) — equivalencia debe probarse sistema por sistema | Descomponer en microservicio por sistema origen o parametrizar vía configuración externa; equivalencia ≥ 99.99% por sistema |
| MR-GL-02 | 🟠 CRÍTICO | SILENCIOSO | T-GL-008 | Cadena ESQCON en 3 catálogos (INDS250→CAT7→ESQCON) — "ESQUEMA NO EXISTE" produce gap silencioso en GL sin movimiento contable | Migrar como servicio de resolución de cuentas; cualquier gap debe lanzar excepción auditable, nunca descarte silencioso |
| MR-GL-03 | 🟠 CRÍTICO | SILENCIOSO | T-GL-010 | Partida doble solo garantizada si NAT-MOV = 1 o 2 — NAT-MOV ≠ 1/2 → asiento descartado silenciosamente, sin registro en GL | Implementar validación de NAT-MOV antes de procesar; loggear y alertar cualquier descarte; auditar calidad del catálogo ESQCON |
| MR-GL-04 | 🟡 ALTO | EQUIVALENCIA | T-GL-012 | Clave 11-dimensional (FILIAL·ORIGEN·MONEDA·BANCO·SUC-PROM·FECVEN·PRODUCTO·INSTRUMENTO·SECTOR·CVETRAN·ESQCON) — granularidad mínima del GL que el target debe preservar | Target GL debe soportar exactamente las 11 dimensiones; verificar con regulador si el catálogo CNBV cambia alguna dimensión |
| MR-GL-05 | 🟡 ALTO | HARDCODE | T-GL-010 | CTA1-CONT=0 → fallback prefijo 5 hardcoded — el prefijo 5 puede no ser válido en el nuevo plan de cuentas CNBV | Auditar ESQCON para eliminar entradas CTA=0; si quedan, externalizar el prefijo como parámetro configurable |
| MR-GL-06 | 🟡 MEDIO | HARDCODE | T-GL-014 | Cuenta 1503 excluida hardcode del cálculo de cuadre contable — puede no ser válida en el nuevo plan de cuentas | Validar con equipo contable si la exclusión sigue siendo válida; mover a catálogo configurable de exclusiones |
| MR-GL-07 | 🟡 MEDIO | HARDCODE | T-GL-016 | DATALAKE exclusivo para S264/SPEI generado en proceso batch — si SPEI se migra a streaming, este path batch queda obsoleto | Redireccionar al data lake destino; si se migra a streaming SPEI, eliminar el path batch y documentar la decisión como ADR |
| MR-GL-08 | 🟢 BAJO | HARDCODE | T-GL-001 | CSI=12 mapeado a CSI=10 hardcoded — mapeo histórico posiblemente obsoleto | Verificar si CSI 12 sigue activo; si no, eliminar; si sí, externalizar a configuración |

---

### N1: Common Services — N2: Reconciliation

#### N3: 6.7.1 Financial Reconciliation — N4: P112 PUNTEO POR CLAVES DE TRANSACCION

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-REC-01 | 🟠 CRÍTICO | INTERFAZ | T-REC-012 | Catálogo ARCH-CAT como fuente única de equivalencia S500↔S151 — cualquier cambio en guía contable rompe la reconciliación diaria | Externalizar ARCH-CAT a base de datos versionada y configurable; implementar pruebas de equivalencia al 100% de combinaciones antes de go-live |
| MR-REC-02 | 🟠 CRÍTICO | INTERFAZ | T-REC-012 | Clave KEY-CAT 7 campos con REDEFINES COMP — extremadamente frágil ante cambios de layout; un campo nuevo requiere recompilación de todos los programas que acceden ARCH-CAT | Reescribir acceso como consulta parametrizada con 7 columnas explícitas; nunca replicar REDEFINES en target |
| MR-REC-03 | 🟠 CRÍTICO | HARDCODE | T-REC-004 + T-REC-005 | Límites hardcoded: catálogo PT 9,999 registros y tabla leyendas 12,000 claves — overflow aborta la reconciliación completa del día sin procesar ningún movimiento | Eliminar límites hardcoded; usar estructuras dinámicas (List/Map) en target; monitorear crecimiento del catálogo |
| MR-REC-04 | 🟠 CRÍTICO | INTERFAZ | T-REC-014 | Texto exacto de 35 chars "REL-TRAN-GUIA CONTABLE INEXISTENTE" — parsers downstream del sistema 115 y auditoría dependen del texto literal | Documentar como contrato de interfaz versionado; implementar código de error estructurado (no texto libre) en target; mantener compatibilidad si hay parsers existentes |
| MR-REC-05 | 🟡 ALTO | HARDCODE + REGULATORIO | T-REC-010 | 12 libros contables hardcoded incl. FOBAPROA (residual 1994) — nuevo libro regulatorio CNBV requiere modificación de código fuente | Mover catálogo de libros a tabla configurable en base de datos; gestionar vía configuración sin recompilación |
| MR-REC-06 | 🟡 ALTO | HARDCODE + SILENCIOSO | T-REC-007 | S087 producto hardcoded=87 sin leer A00-R01-PRODUCTO — nuevos productos S087 se clasifican bajo código 87 silenciosamente | Reemplazar por lectura real de A00-R01-PRODUCTO; validar con equipo S087 el catálogo de productos actual |
| MR-REC-07 | 🟡 ALTO | HARDCODE | T-REC-003 | CRONOS2K — conversión año 2 dígitos con umbral 50 — datos con año > 50 interpretados como siglo XX; bomba de tiempo activa en 2051 | Eliminar lógica CRONOS2K; usar tipo DATE nativo con 4 dígitos de año en todo el target |
| MR-REC-08 | 🟡 MEDIO | SILENCIOSO | T-REC-006 | Filtro FUNCION=1 AND STATUS=1 descarta silenciosamente sin traza — STATUS=0 nunca procesado; FUNCION=2/3 ignorados aunque sean operaciones válidas | Agregar contadores y log estructurado de registros descartados por filtro; loggear causa de exclusión |
| MR-REC-09 | 🟡 MEDIO | SILENCIOSO + HARDCODE | T-REC-008 | S264/S703/S018/S017 restringidos a MXN (CAT-MON=01 hardcoded) — movimiento en divisa extranjera produce brecha silenciosa sin indicar la causa real | Emitir código de error específico "RESTRICCION-MONEDA-BASE" en lugar de caer en la brecha genérica |
| MR-REC-10 | 🟡 MEDIO | HARDCODE + REGULATORIO | T-REC-013 | S403 fondos (FIRA/FONATUR/BANCOMEXT/NAFIN) y S404 productos (9 tipos) hardcoded — nuevos fondos/productos descartados silenciosamente ante CNBV | Externalizar listas de fondos y productos a catálogos configurables en base de datos |

---

### N1: Transversal — N2: Security

#### N3: T.3.5 Security — N4: P655 SCRAMBLING

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-SEC-01 | 🔴 DEFECTO-PROD | SEGURIDAD + SILENCIOSO | T-SEC-001 | Fail-open ante hostname no reconocido — P655 ejecuta enmascaramiento completo sobre DMSII sin saber si el ambiente es productivo | Reemplazar lista hardcoded por mecanismo fail-closed: variable de entorno `ENV=PROD/TEST` verificada al inicio; si no confirmada → abort real |
| MR-SEC-02 | 🔴 DEFECTO-PROD | SEGURIDAD | T-SEC-002 | "Bloqueo" de producción sin STOP RUN — STATUS=-1 marcado pero el programa continúa y ejecuta el enmascaramiento sobre datos reales | Implementar `throw SecurityException` / exit-code inmediato en target ante `ENV=PROD`; nunca continuar post-detección |
| MR-SEC-03 | 🟠 CRÍTICO | EQUIVALENCIA | T-SEC-003 | Tamaño de bloque calculado por hora de arranque (1800 - HH-MM-SS) — no reproducible entre corridas para pruebas de equivalencia | Definir en ADR si el shuffle es requerimiento funcional o puede reemplazarse por orden determinístico + seed configurable |
| MR-SEC-04 | 🟡 ALTO | PROPIETARIO-MCP | T-SEC-005 | Checkpoint nombrado con path Unisys "S500/FILE/SCRBLING/<CSI>/<fecha>" — no portable a plataformas modernas | Migrar checkpoint a base de datos (tabla de estado) o blob storage con clave estructurada (CSI, fecha) |
| MR-SEC-05 | 🟡 ALTO | EQUIVALENCIA | T-SEC-008 | W77-NOMBRE-PTE (nombre del primer contrato) capturado una sola vez al inicio del archivo — en reanudación desde checkpoint este estado se pierde | Persistir W77-NOMBRE-PTE en el checkpoint; no asumir que el primer contrato es siempre el mismo entre corridas interrumpidas |
| MR-SEC-06 | 🟡 ALTO | EQUIVALENCIA | T-SEC-010 | Orden de procesamiento B03→B37→B39 como dependencia implícita — B39 depende de que B03 esté completamente enmascarado | Documentar como restricción explícita de pipeline en target; prohibir paralelismo entre los tres flujos |
| MR-SEC-07 | 🟡 MEDIO | EQUIVALENCIA | T-SEC-010 | Secuencia W77-SEQ-NOMB (inicio 10000, paso 12) se reinicia en cada corrida — inconsistencia entre ejecuciones si hay reanudación | Persistir la secuencia en el checkpoint o usar UUID para nombres sintéticos de cuentas sin contrato vinculado |
| MR-SEC-08 | 🟡 MEDIO | HARDCODE | T-SEC-001 | Lista de 7 hostnames desactualizable — VDMKAPPA no está contemplado aunque pertenece al mismo par de nodos que ACYPOMEGA | Confirmar topología real del banco antes de migrar; la lista está incompleta en el código fuente actual |
| MR-SEC-09 | 🟡 MEDIO | PROPIETARIO-MCP | T-SEC-001 | `ATTRIBUTE HOSTNAME OF MYSELF` — instrucción propietaria Unisys MCP para leer el nombre del servidor | Reemplazar por lectura de variable de entorno `HOSTNAME` o label de pod/contenedor en target |

---

### N1: Common Services — N2: Compliance & Regulation

#### N3: 6.5.2 Compliance & Regulation — N4: P103 FraudLink

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-CMP-01 | 🟠 CRÍTICO | HARDCODE + REGULATORIO | T-CMP-005 + T-CMP-006 + T-CMP-007 | Códigos de fraude 2001/2444/2496 hardcoded — extensión del catálogo de fraude CNBV requiere recompilación del programa | Externalizar a tabla de configuración parametrizable; agregar un código nuevo no debe requerir cambio de código fuente |
| MR-CMP-02 | 🟠 CRÍTICO | HARDCODE + REGULATORIO | T-CMP-006 | Límite 5 sub-movimientos SAD hardcoded (PERFORM 5 TIMES) — si la estructura B07-OTROS-MOVSAD tiene más de 5 entradas, se trunca el reporte CNBV sin advertencia | Verificar si el límite es estructural del DASDL o solo del programa; en target usar colección dinámica |
| MR-CMP-03 | 🟠 CRÍTICO | HARDCODE + REGULATORIO | T-CMP-007 | Límite 10 claves B13 hardcoded (B13-CLAVES-TRANS×10) — puede truncar claves adicionales y generar subdeclaración ante CNBV | Verificar en DASDL si B13 admite más de 10 entradas; si sí, migrar a colección dinámica |
| MR-CMP-04 | 🟠 CRÍTICO | SILENCIOSO + REGULATORIO | T-CMP-003 | Abort con DMTERMINATE ante error I/O en S500B07MOVDIA — archivo FraudLink queda incompleto sin trailer de control; CNBV recibe archivo inválido | Implementar manejo de excepciones que escriba el trailer incluso ante error, o mecanismo de reinicio desde último registro exitoso |
| MR-CMP-05 | 🟡 ALTO | HARDCODE | T-CMP-002 | B02-FECHA-LOTE (fecha del batch) usada como fecha del reporte — en días de reproceso la fecha difiere de la fecha de ejecución real | Documentar en el API target que la fecha de proceso viene del parámetro de control, no del sistema; exponerla como campo explícito |
| MR-CMP-06 | 🟡 ALTO | HARDCODE + INTERFAZ | T-CMP-008 | WKS-REG-E03-IMPORTE PIC 9(11)V99 vs origen NUMBER 14,2 — importes con más de 11 dígitos enteros se truncan silenciosamente al armar el registro FraudLink | Ampliar el campo a PIC 9(14)V99 en el target; validar rango histórico de importes antes de go-live |
| MR-CMP-07 | 🟡 ALTO | INTERFAZ | T-CMP-005 | Campo WKS-REG-E03-CHQRA contiene B07-MED-ACCESO (medio de acceso), no un número de chequera — homonimia engañosa que puede generar asignaciones incorrectas | Renombrar a MED_ACCESO o CANAL_ACCESO en target; actualizar documentación del contrato CNBV |
| MR-CMP-08 | 🟡 MEDIO | SILENCIOSO | T-CMP-004 | B07-STATUS-MOVTO=1 excluye movimientos sin traza — significado del valor 1 no formalmente documentado en DASDL | Agregar contador de exclusiones + log estructurado; verificar con SME el significado exacto del valor 1 antes de migrar |
| MR-CMP-09 | 🟡 MEDIO | PROPIETARIO-MCP | T-CMP-001 + T-CMP-002 + T-CMP-003 | `CALL SYSTEM DMTERMINATE` y `CHANGE ATTRIBUTE STATUS OF MYSELF TO -1` — primitivas propietarias Unisys para cancelación y señalización de error | Reemplazar por exception handling + exit codes en target; garantizar que el orquestador recibe el fallo |
| MR-CMP-10 | 🟡 MEDIO | INTERFAZ | T-CMP-007 | FK compuesta B07-NUM-CONTRATO + B07-AUTORIZACION → S500B13MOVCVES — dependencia referencial implícita no enforceada en DMSII | Documentar la FK como restricción referencial explícita en el modelo de datos target; implementar validación previa o integridad referencial |

---

## Vistas cruzadas

### Riesgos 🔴 DEFECTO-PROD — acción inmediata antes de cualquier ambiente de prueba

| ID | Capacidad | N4: Proceso | N5: Tarea | Descripción |
|----|-----------|-------------|-----------|-------------|
| MR-SEC-01 | T.3.5 Security | P655 SCRAMBLING | T-SEC-001 | Fail-open ante hostname no reconocido — enmascaramiento sin control de ambiente |
| MR-SEC-02 | T.3.5 Security | P655 SCRAMBLING | T-SEC-002 | Bloqueo producción sin STOP RUN — enmascaramiento de datos reales continúa |

### Riesgos regulatorios (CNBV/Banxico) consolidados

| ID | Capacidad | Regulador | N5: Tarea | Descripción |
|----|-----------|-----------|-----------|-------------|
| MR-REC-01 | 6.7.1 Fin. Reconciliation | CNBV | T-REC-012 | ARCH-CAT como fuente de equivalencia — cambio en guía contable rompe reconciliación diaria |
| MR-REC-04 | 6.7.1 Fin. Reconciliation | CNBV | T-REC-014 | Texto exacto 35 chars como contrato de interfaz con sistema 115 |
| MR-REC-05 | 6.7.1 Fin. Reconciliation | CNBV | T-REC-010 | 12 libros hardcoded incl. FOBAPROA — nuevo libro CNBV requiere recompilación |
| MR-REC-10 | 6.7.1 Fin. Reconciliation | CNBV/Banxico | T-REC-013 | S403 fondos y S404 productos hardcoded — nuevos fondos ignorados ante CNBV |
| MR-CMP-01 | 6.5.2 Compliance | CNBV | T-CMP-005..007 | Códigos de fraude 2001/2444/2496 hardcoded |
| MR-CMP-02 | 6.5.2 Compliance | CNBV | T-CMP-006 | Límite 5 SAD — truncamiento silencioso del reporte CNBV |
| MR-CMP-03 | 6.5.2 Compliance | CNBV | T-CMP-007 | Límite 10 B13 — subdeclaración potencial ante CNBV |
| MR-CMP-04 | 6.5.2 Compliance | CNBV | T-CMP-003 | Abort sin trailer — archivo FraudLink inválido enviado a CNBV |

### Riesgos de patrón SILENCIOSO — impacto en reconciliación y auditoría

| ID | Capacidad | N5: Tarea | Consecuencia del silencio |
|----|-----------|-----------|--------------------------|
| MR-GL-02 | 7.1.1 Finance GL | T-GL-008 | ESQUEMA NO EXISTE → movimiento no contabilizado, sin alerta |
| MR-GL-03 | 7.1.1 Finance GL | T-GL-010 | NAT-MOV ≠ 1/2 → asiento descartado sin registro |
| MR-SEC-01 | T.3.5 Security | T-SEC-001 | Hostname no reconocido → enmascaramiento sin validación |
| MR-REC-08 | 6.7.1 Reconciliation | T-REC-006 | STATUS=0 nunca procesado sin traza |
| MR-REC-09 | 6.7.1 Reconciliation | T-REC-008 | Brecha de moneda sin diagnóstico de causa |
| MR-CMP-04 | 6.5.2 Compliance | T-CMP-003 | Abort sin trailer → archivo CNBV incompleto |
| MR-CMP-08 | 6.5.2 Compliance | T-CMP-004 | STATUS-MOVTO=1 descartado sin counter ni log |

### Riesgos de patrón PROPIETARIO-MCP — requieren reemplazo arquitectónico

| ID | Capacidad | N5: Tarea | Instrucción Unisys | Reemplazo target |
|----|-----------|-----------|-------------------|-----------------|
| MR-TAR-03 | ATM/PoS | T-TAR-001+002 | `CHECAME / DAME_TIT IN CTLVERS` | ConfigMap / service registry |
| MR-TAR-04 | ATM/PoS | T-TAR-014 | `USE AS INTERRUPT PROCEDURE` | Signal handler / graceful shutdown |
| MR-TAR-05 | ATM/PoS | T-TAR-004 | `CALL SYSTEM DMTERMINATE` | Exit-code no-cero + cierre limpio |
| MR-SEC-09 | Security | T-SEC-001 | `ATTRIBUTE HOSTNAME OF MYSELF` | Variable de entorno `HOSTNAME` |
| MR-SEC-04 | Security | T-SEC-005 | Path archivo Unisys `S500/FILE/SCRBLING/` | DB o blob storage |
| MR-CMP-09 | Compliance | T-CMP-001..003 | `DMTERMINATE` + `CHANGE ATTRIBUTE STATUS` | Exception + exit-code orquestador |

---

## Notas de mantenimiento

- Este registro se actualiza al generar cada nuevo `cap-{slug}.md`.
- Los IDs `MR-{CAP}-{NN}` son estables — no renumerar al agregar nuevas capacidades.
- Las vistas cruzadas se recalculan al agregar cada bloque de capacidad.
- **Capacidades pendientes con riesgos esperados de alta densidad:** SCH (P075 cierre de día), INT (P130 rendimientos/ISR), ORC (S151REGISTRA — flag compilación condicional), PAY (P020 LINCOMS + DIVESTITURE flag).

---

*migration-risk-register.md · v1.0 · 2026-07-16*
*Cobertura: 5/20 capacidades (TAR · GL · REC · SEC · CMP)*
*Fuentes: cap-tar.md · cap-gl.md · cap-rec.md · cap-sec.md · cap-cmp.md · rules-catalog/*
*Taxonomía: N1 Dominio → N2 SubDominio → N3 Capacidad → N4 Proceso → N5 Flujo (Tarea)*