# Registro de Riesgos de Migración — Banamex GemCog S500 + S151
> Taxonomía canónica: **N1 Dominio → N2 SubDominio → N3 Capacidad → N4 Proceso → N5 Flujo (Tarea)**
> Sistemas: S500 (Captación/Cargos y Abonos) + S151 (GL — Movimientos Contables) · Unisys ClearPath MCP
> Última actualización: 2026-07-27 · v3.6 · **172 riesgos** · 22/22 capacidades documentadas · GL + ADJ enriquecidos con validación SME (Regulatorio CNBV + Contabilidad Bancaria + SPEI) de los batches P109 y BC-09 Ola 4
> Indexado: ✅ 2026-07-17 — Registro de riesgos de migración

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
| Cap files cubiertos | 22/22 (TAR · GL · REC · SEC · CMP · DEP · HLD · ADJ · ODS · PAY · MQ · SCH · STA · TEL · INT · CFR · ORC · RPT · CPE) |
| Total de riesgos registrados | 172 |
| 🔴 DEFECTO-PROD | 7 |
| 🟠 CRÍTICO | 62 |
| 🟡 ALTO | 63 |
| 🟡 MEDIO | 39 |
| 🟢 BAJO | 1 |

### Distribución por capacidad

| Cap | Capacidad | Riesgos | 🔴 | 🟠 | 🟡A | 🟡M | 🟢 |
|-----|-----------|---------|----|----|-----|-----|-----|
| TAR | 2.2.6 ATM + 2.2.7 PoS | 7 | — | 2 | 3 | 2 | — |
| GL | 7.1.1 Finance (GL) | 11 | 1 | 7 | 1 | 1 | 1 |
| REC | 6.7.1 Financial Reconciliation | 12 | — | 6 | 3 | 3 | — |
| SEC | T.3.5 Security | 10 | 3 | 1 | 3 | 3 | — |
| CMP | 6.5.2 Compliance & Regulation | 10 | — | 4 | 3 | 3 | — |
| DEP | 5.1.1 Deposits | 7 | — | 2 | 2 | 3 | — |
| HLD | 4.1.2 Holdings | 10 | — | 3 | 5 | 2 | — |
| ADJ | 6.7.1+6.7.2 Reconciliation GL Sync | 9 | — | 5 | 3 | 1 | — |
| ODS | 9.1.1 Operational Data Stores | 13 | — | 4 | 4 | 5 | — |
| PAY | 6.1.3 Payments | 2 | — | 1 | 1 | — | — |
| MQ | T.2.3 Async Infrastructure | 1 | — | — | 1 | — | — |
| TEL | 2.1.1 Teller | 4 | — | — | 3 | 1 | — |
| SCH | 8.1.1 Business Scheduling | 7 | — | 3 | 3 | 1 | — |
| STA | 6.1.4 Statements | 5 | — | 1 | 3 | 1 | — |
| INT | 6.1.5 Interest & Fees | 9 | — | 3 | 4 | 2 | — |
| CFR | T.4.1 Regulatory Reporting (CFR) | 11 | 1 | 4 | 3 | 3 | — |
| ORC | 6.7.2 Operational Reconciliation | 11 | 1 | 5 | 3 | 2 | — |
| RPT | T.3.4 Batch Control & Regulatory Extraction | 10 | 1 | 2 | 5 | 2 | — |
| CPE | T.6.1 CPE Mensual | 7 | — | 2 | 2 | 3 | — |
| GOV | Migration Governance (Cross-Cutting) | 16 | — | 7 | 8 | 1 | — |
| **TOTAL** | | **170** | **7** | **57** | **65** | **40** | **1** |

### Distribución por patrón de riesgo

| Patrón | Riesgos | Capacidades afectadas |
|--------|---------|-----------------------|
| HARDCODE | 32 | TAR · GL · REC · SEC · CMP · DEP · HLD · ADJ · ODS · INT · TEL · CFR · ORC · RPT · CPE |
| EQUIVALENCIA | 34 | GL · REC · TAR · DEP · HLD · ADJ · ODS · INT · PAY · SCH · STA · CFR · ORC · RPT · CPE |
| SILENCIOSO | 28 | GL · REC · SEC · CMP · DEP · HLD · ADJ · ORC · RPT · SCH · CFR · INT |
| PROPIETARIO-MCP | 26 | TAR · SEC · CMP · HLD · ADJ · ODS · SCH · STA · TEL · CFR · ORC · RPT · CPE |
| REGULATORIO | 22 | REC · CMP · GL · HLD · ODS · RPT · CFR · INT · DEP · SEC · CPE |
| INTERFAZ | 12 | REC · CMP · GL · DEP · ADJ · ODS · STA · TEL · CPE |
| ATOMICIDAD | 6 | TAR · ADJ · ORC · CPE |
| SEGURIDAD | 5 | SEC · TEL |
| DOCUMENTACIÓN | 3 | MQ · CPE · GOV |

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
| MR-GL-05 | 🟠 CRÍTICO | HARDCODE · REGULATORIO | T-GL-010 | CTA1-CONT=0 → fallback `MOVE 5` y **cereo de BANCA/SECTOR/ACTIVIDAD** (:10922-10925). SME Contable: grupo 5 = resultados deudores (gasto/P&L) → volcar no-resueltos ahí **infla el resultado del período** (mal-clasificación Anexo 33 Serie D) y **degrada la sectorización de Serie R (R04)** | No transpilar el hardcode; externalizar a cuenta transitoria vigilada de "partidas por identificar" conservando dimensiones (ADR contable); tolerancia cero determinística, cada hit del fallback = trigger de divergencia; cuantificar materialidad del saldo histórico como hallazgo pre-cutover |
| MR-GL-06 | 🟠 CRÍTICO | HARDCODE · SILENCIOSO · REGULATORIO | T-GL-014 | Cuenta 1503 (grupo 15 activo transitorio/liquidación; subcuentas 150399/150359) cerea los **6 acumuladores** del cuadre (simple/transitorio/autorizado) y marca paquete vacío. SME Contable: exclusión permanente de la conciliación puede **ocultar descuadre real**; CNBV vigila saldos en tránsito (Art. 144-148) | Excluir solo del cuadre del paquete, nunca de la conciliación contable; conservar solo con proceso explícito de conciliación/depuración con antigüedad de saldos (ADR); verificar saldo neto = 0 por paquete y que ningún movimiento legítimo caiga ahí por error de esquema; externalizar literales de cuenta |
| MR-GL-07 | 🟡 MEDIO | HARDCODE | T-GL-016 | DATALAKE exclusivo para S264/SPEI generado en proceso batch — si SPEI se migra a streaming, este path batch queda obsoleto | Redireccionar al data lake destino; si se migra a streaming SPEI, eliminar el path batch y documentar la decisión como ADR |
| MR-GL-08 | 🟢 BAJO | HARDCODE | T-GL-001 | CSI=12 mapeado a CSI=10 hardcoded — mapeo histórico posiblemente obsoleto | Verificar si CSI 12 sigue activo; si no, eliminar; si sí, externalizar a configuración |
| MR-GL-09 | 🔴 DEFECTO-PROD | SILENCIOSO | CS-GL-06 | P109: `SET MYSELF(STATUS) TO -1` COMENTADO (ln 10009) — ante date-mismatch en header LOG151, el proceso imprime aviso pero continúa generando asientos GL con fecha potencialmente incorrecta | `[HITL URGENTE]` Confirmar con equipo operativo si ocurre en producción; descomentar el abort o implementar mecanismo de alerta + hold del lote; revisar asientos contables de fechas con gap de LOG151 |
| MR-GL-10 | 🟠 CRÍTICO | EQUIVALENCIA | CS-GL-03 · T-GL-012 | MOVCONTASORT excluye STATUS=2 (gate `A00-R01-STATUS=1 AND ORIGEN=1 OR 3` en P109 ln 10618-10619) — movimientos en tránsito (STATUS=2) producen MOVCONTABLES pero NO MOVCONTASORT; el sistema destino que omita esta restricción inyectará movimientos no confirmados en el archivo de sorting contable enviado a S500 | Replicar el gate STATUS=1 AND ORIGEN=1/3 en el servicio target que produce MOVCONTASORT; definir en `equivalencia-strategy.md` si STATUS=2 debe corregirse o preservarse; agregar test de equivalencia específico para registros STATUS=2 |
| MR-GL-11 | 🟠 CRÍTICO | EQUIVALENCIA · REGULATORIO | RN-S151-034 · P109 S264 | SPEI en MXN (S264, MONEDA=1) registra el asiento sin dimensión banco (banco=0); la rama no-MXN (SPID USD o corresponsalía) conserva el banco. Validado SME SPEI: refleja la liquidación RTGS/LBTR de SPEI contra la cuenta única de Banxico (sin posición bilateral en pesos) | Preservar en target; la prueba NO es de conformidad SPEI sino de **cuadre contable (reconciliation parity)**: la pierna MXN consolida con banco=0, la no-MXN conserva banco real, y ambos GL concilian contra los Avisos de Liquidación de Banxico y contra nostro/SPID. Conservar banco en SPEI pesos genera subsaldos fantasma que corrompen el balance |

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
| MR-SEC-10 | 🔴 DEFECTO-PROD | REGULATORIO | vRSM B-02 · cap-tar.md | `B02T-CVV NUMBER(04)` almacenado en claro en S500B02TMOVTOS (BD06 Teletón) — post-autorización el CVV persiste en base junto a PAN (`B02T-CUENTA-TARJ` 16 dígitos) y vencimiento (`B02T-FECVEN-MM/AA`). Violación PCI-DSS v4.0 req. 3.3.2: los SAD no pueden persistir tras la autorización. Escalado a seguridad (H-006). [H-001-CONFIRMADO-vRSM] | Borrar o tokenizar `B02T-CVV` antes de migrar el dataset; auditar si el dato está en backups/snapshots históricos; notificar a CISO Banamex y equipo de compliance PCI antes del cutover |

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

### N1: Enterprise Support Functions — N2: Finance · Reporting

#### N3: CFR Regulatory Reporting — N4: P131 TRADUCTOR CFR→CNBV

> **Fuente:** QC Batch 1 · hallazgo HQ-4 verificado contra COBOL_P131.txt

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-CFR-01 | 🟠 CRÍTICO | HARDCODE | cap-cfr · `A01-TRAD-SETID` | `SETID="BNMEX"` hardcoded en **14 ocurrencias** de P131 (11 activas en código ejecutable + 3 en comentarios), incluyendo asignaciones directas al campo SETID del asiento PeopleSoft en `A01-TRAD-SETID` (ln ~7369) y `A01-TRADFS-SETID` (ln ~7393) — fuera del bloque UNINEG. En la separación Citi/Banamex, todos estos puntos deben cambiar para la entidad destino | Identificar los 11 puntos activos y reemplazar el literal por una variable de configuración `SETID_UNINEG` inyectable por ambiente; validar con el equipo PeopleSoft GL cuántos asientos llevan BNMEX y qué SETID aplica en el banco separado |

---

### N1: Common Services — N2: Reconciliation · Cierre de Lote

#### N3: Operational Reconciliation — N4: P680 GENERACION CIERRE

> **Fuente:** QC Batch 2 · hallazgo ORC-P680-H01 verificado contra COBOL_P680.txt · RN-S151-621

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-ORC-01 | 🔴 DEFECTO-PROD | SILENCIOSO | cap-orc · ORC-P680-H01 · RN-S151-621 | BUG ACTIVO en producción — línea 537 de COBOL_P680.txt: `MOVE SECERRHI TO SECINFHI` copia el contador de registros con error (SECERRHI) en el contador de registros informativos (SECINFHI). Consecuencia: SECINFHI queda sobredeclarado con el total de errores; el contador real de informativos se pierde. P680 es el único punto de restauración del cierre de lote en S151 — no existe programa alternativo ni backup del estado de control de secuencia. | `[HITL URGENTE]` Confirmar con equipo de operaciones si los contadores SECERRHI/SECINFHI son insumo de reportes o auditorías downstream; corregir el MOVE al valor correcto de SECINFHI. En el target: separar explícitamente los contadores de error e informativo; nunca sobreescribir uno con el otro. |

---

### N1: Enterprise Support Functions — N2: Finance · Reporting

#### N3: T.3.4 Batch Control & Regulatory Extraction — N4: P120 EXTRACTOR SAR

> **Fuente:** QC Batch 2 · hallazgo RPT-P120-H01 verificado contra COBOL_P120.txt · RN-S151-228

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-RPT-01 | 🔴 DEFECTO-PROD | SILENCIOSO + REGULATORIO | cap-rpt · RPT-P120-H01 · RN-S151-228 | BUG CONFIRMADO desde 1991 — línea 1198 de COBOL_P120.txt: `ADD B08-GSAR-ANT-INFO TO 77-ANT-ISTE` — variable destino incorrecta (77-ANT-ISTE = acumulado ISSSTE) en vez de 77-ANT-INFO (INFONAVIT). Consecuencia: DET-ANT-INFO imprime siempre 0 en el reporte SAR; DET-ANT-ISTE queda inflado con INFONAVIT + ISSSTE mezclados. Solo afecta valores ANT (saldo anterior) — los ACT (actual) son correctos. El reporte SAR con saldo anterior INFONAVIT incorrecto se ha entregado a Banxico/INFONAVIT durante ~34 años. | `[HITL URGENTE con equipo Tesorería/SAR y área regulatoria]`: (1) Cuantificar la magnitud histórica del error (DET-ANT-INFO siempre = 0); (2) Evaluar si existe obligación de corrección retroactiva ante Banxico/INFONAVIT; (3) Decisión de equivalencia para el target: ¿replicar el bug (equivalencia exacta histórica) o corregir (`ADD B08-GSAR-ANT-INFO TO 77-ANT-INFO`)? Si se corrige, los reportes SAR del target diferirán del histórico legado — documentar como ADR y comunicar al regulador antes del go-live. |

---

### N1: Channels — N2: Assisted Touchpoints · Integraciones

#### N3: 4.x Integraciones CITI/IBM — N4: P151 IBM-CITIBANK TRANSFORMADOR ALR/AHR/OCM

> **Fuente:** QC Batch 2 · hallazgo INT-P151-H01

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-INT-01 | 🟠 CRÍTICO | HARDCODE + EQUIVALENCIA | cap-int · INT-P151-H01 · RN-S151-336, 341, 342 | Valor **485 hardcodeado en P151 con tres roles semánticamente distintos**: (1) ALRINT-BRCH-NBR en registros ALR (RN-S151-336); (2) OCMIN-COUNTRY-CODE en registros OCM (RN-S151-341); (3) PAY-AGENT-CODE en registros OCM (RN-S151-342). El programa P150 del mismo autor (Javier Mercado Flores) usa BRANCH=484 para un campo conceptualmente análogo. La ambigüedad diseño-vs-bug no puede resolverse por análisis estático — si 485 es incorrecto en alguno de los tres roles, el sistema IBM-CITI recibirá registros con identificadores de sucursal, país o agente incorrectos. | `[HITL OBLIGATORIO con equipo CITI antes del cutover]`: (1) ¿Son 484 y 485 valores distintos por diseño (dos interfaces distintas: P150 vs P151) o uno es error del mismo autor? (2) ¿Es correcto que COUNTRY-CODE=485 y PAY-AGENT-CODE=485 en los registros OCM? (3) Confirmar las tres instancias de 485 individualmente. Sin esta confirmación el target no puede fijar los tres campos correctamente y los tests de equivalencia con el sistema IBM-CITI pueden fallar. |

---

### N1: Common Services — N2: Reconciliation · Saldos

#### N3: Financial Reconciliation — N4: P178 VERIFICACION SALDOS DMSII

> **Fuente:** QC Batch 3A · hallazgos P1-CRITICO #1 y #2 verificados contra COBOL_P178.txt

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-REC-11 | 🟠 CRÍTICO | EQUIVALENCIA | cap-adj · RN-S151-392 | Rama ELSE para sistemas S84/S87/S408 en P178 INPUT PROCEDURE no existe en el código fuente. El pseudocódigo documentaba que esos sistemas envían registros al SORT A02-SORT vía `210200-MUEVE-DATOS-APL`; el fuente real (COBOL_P178.txt L3513-3522) muestra que la tabla WKS-TAB-IMP para S84/S87/S408 se carga por `1520000-CARGA-REL-SALDOS` — ruta paralela, nunca por SORT. Un transpiler siguiendo la regla incorrecta añadiría lógica que envía registros al SORT para sistemas que no deben llegar ahí, generando duplicados en la conciliación de saldos. | Verificar que el rules-catalog fue corregido (QC Batch 3A ya aplicó la corrección). En transpilación: implementar la ruta `1520000-CARGA-REL-SALDOS` como carga directa a tabla; prohibir path al SORT para S84/S87/S408. Prueba de equivalencia obligatoria para los tres sistemas. |
| MR-REC-12 | 🟠 CRÍTICO | EQUIVALENCIA | cap-adj · RN-S151-395 | `WKS-TAB-IMP(prod,inst,mon)` tiene PIC `S9(15)V9(02) COMP` (COBOL_P178.txt L2656) — documentado incorrectamente como `S9(13)V99 COMP`. Diferencia: rango de 9,999,999,999,999.99 → 999,999,999,999,999.99 (100× mayor). En Java/Kotlin la diferencia entre `BigDecimal` de 13 vs 15 dígitos provoca truncamiento silencioso de importes grandes. En un banco de la escala de Banamex, saldos GL de 15 dígitos son posibles para posiciones consolidadas. | Configurar explícitamente `MathContext(17, HALF_UP)` o `BigDecimal(15, 2)` en el target. Ejecutar golden master de P178 al 99.99% con datos representativos de saldos grandes. Validar que ningún importe de la tabla WKS-TAB-IMP supera los 13 dígitos en producción histórica — si sí, el truncamiento ya ocurrió y requiere auditoría. |

---

### N1: Business Operations — N2: Finance · Movimientos Contables

#### N3: 6.1.3 Payments / Movimientos GL — N4: P052 CONVERSOR TIPO DE CAMBIO

> **Fuente:** QC Batch 3B · hallazgos P1-CRITICO #2 y #3 verificados contra COBOL_P052.txt

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-PAY-01 | 🟠 CRÍTICO | EQUIVALENCIA | rules-s151-p050-p052 · RN-S151-311 | `W77-TIPO-CAMBIO` tiene PIC `9(12)V9(06)` (COBOL_P052.txt L7513) — documentado incorrectamente como `9(06)V99`. Diferencia crítica: 12 dígitos enteros y 6 decimales (18 dígitos totales) vs 6 enteros y 2 decimales (8 dígitos). Adicionalmente, la condición de éxito del párrafo `020700-TIPO-CAMBIO` es `= 0 OR 1` (L9922), no solo `= 0` como estaba documentado — status=1 es éxito informativo no detectado. Con la PIC incorrecta en el target, cualquier tipo de cambio con más de 6 dígitos enteros o más de 2 decimales se trunca/desborda silenciosamente en cálculos FX del GL. | Usar `BigDecimal(18, 6)` o equivalente en target. Verificar el manejo de status=1 como condición de éxito (no fallar ni reintentar). Añadir validación de rango en conversión FX: rechazar si el tipo de cambio resultante supera el rango esperado de divisas activas. |
| MR-PAY-02 | 🟡 ALTO | EQUIVALENCIA | rules-s151-p050-p052 · RN-S151-281..282 | `WKS-DIA-HABIL` en P050 tiene semántica **invertida** respecto a su nombre: `VALUE 0 = INHÁBIL` y `≠ 0 = HÁBIL` (verificado COBOL_P050.txt L6381 + L9512-9522). El rules-catalog documentaba la convención al revés (`0=HÁBIL`). La lógica crítica: `IF WKS-DIA-HABIL = 0 → FUN=13` (avanza al siguiente hábil). Un transpiler siguiendo la convención incorrecta invertiría el calendario de días hábiles, programando operaciones en días no laborables y omitiendo procesamiento en días hábiles reales. | Verificar que el rules-catalog fue corregido (QC Batch 3B aplicó la corrección). En transpilación: documentar explícitamente la semántica `0=INHÁBIL` como invariante no-intuitivo en el código target y en el ADR de equivalencia de calendario. Prueba de equivalencia con fechas conocidas (fines de semana, festivos nacionales MX). |

---

### N1: Technology — N2: T.2.3 Async Infrastructure

#### N3: MQ / Async (L091 + L093) — N4: LIBRERÍAS ASINCRONA S500

> **Fuente:** QC Batch 4A · hallazgo P1-CRITICO en cap-mq.md verificado contra S500/source/extracted_source/

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-MQ-01 | 🟡 ALTO | DOCUMENTACIÓN | cap-mq · T-MQ-001..007 | L092 no existe en el inventario S500 ni en los fuentes extraídos. El cap-mq documentaba "L091-L092-L093" en título, contexto funcional, diagrama Mermaid y hallazgo H-MQ-06. El directorio `S500/source/S500/extracted_source/` contiene únicamente `S500_SOURCE_L091_ASINCRONA.txt` y `S500_SOURCE_L093_ASINCRONA.txt`. Si el equipo de transpilación intentara analizar o mapear L092 como módulo independiente, no encontraría el fuente y podría asumir que el binario está ausente o perdido, generando un falso gap en el inventario de componentes. | El cap-mq fue corregido en QC Batch 4A (L092 eliminado de 5 ubicaciones). En el plan de transpilación: confirmar que el scope S500 incluye solo L091 y L093 como librerías async; verificar con el equipo Unisys si L092 existió históricamente o si fue un error de nomenclatura. Si L091/L093 implementan fan-out de 67 llamadores, verificar el failover table (1→03, 2→01, 3→04, 4→02, 5→02) en el target. |

---

### N1: Product Processing — N2: Product Catalogue

#### N3: 5.1.1 Deposits — N4: P144 RECONCILIACIÓN B01↔B03 (BIT-ACTBANDERA) · P142 S408LINCRED

> **Fuente:** cap-dep.md · hallazgos H-DEP-01..06

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-DEP-01 | 🟠 CRÍTICO | INTERFAZ + SILENCIOSO | T-DEP-001 | Error S408=99 ambiguo en P142 — mismo código para saturación (>1M autorizaciones/día) y error DMSII; bloquea disposición/pago de crédito-captación sin diagnóstico diferenciado; no hay retry automático ni alarma proactiva | Diferenciar códigos en el servicio equivalente de S408; separar saturación de contador vs error DMSII; instrumentar alertas diferenciadas; en target: circuit breaker por tipo de error + retry idempotente |
| MR-DEP-02 | 🟡 ALTO | SILENCIOSO | T-DEP-009 | Skip silencioso de contratos cross-CSI con CSI erróneamente asignado — P144 ejecuta NEXT SENTENCE sin registrar error; contrato local con CSI incorrecto queda invisible hasta que proceso downstream lo detecte; sin contador de skips en trailer BIT-ACTBANDERA | Añadir contador de skips cross-CSI en campo adicional del trailer; en target: validar consistencia de CSI al abrir el contrato; implementar trazabilidad de skips en log estructurado |
| MR-DEP-03 | 🟡 ALTO | EQUIVALENCIA | T-DEP-006 | Escaneo secuencial O(n) sobre B01CONTRATOS sin filtro de fecha, estado activo ni producto — complejidad crece linealmente con el portafolio; ventana batch nocturna sin cota de tiempo garantizada | En target: reemplazar escaneo por consulta indexada filtrada por fecha de modificación o por marca "pendiente de reconciliar"; considerar procesamiento incremental basado en timestamps |
| MR-DEP-04 | 🟡 MEDIO | HARDCODE | T-DEP-004 | Tabla de 8 pares host cross-CSI duplicada en P020/P142/P144 sin COPY book centralizado — cambio de topología (nuevo nodo CSI, renombrado) requiere actualizar 3 programas en ventana coordinada; desfase genera divergencia silenciosa en routing de contratos | Centralizar en COPY book único o registro de configuración; en target: service discovery o variable de entorno de nodo/región |
| MR-DEP-05 | 🟡 MEDIO | HARDCODE | T-DEP-011 · T-DEP-012 | SUC-PROMOTORA (VDM=0432/MTY=0366), SUC-PROCESO=0511, CAJA=05 hardcoded — adición de tercer nodo CSI, reubicación de sucursal virtual o expansión geográfica requieren recompilación y despliegue coordinado | Parametrizar en catálogo indexado por CSI; en target: atributos configurables del servicio de nodo/región |
| MR-DEP-06 | 🟡 MEDIO | INTERFAZ | T-DEP-014 | BUG copy-paste: CLOSE-BD07ATRIBUCTA imprime "ERROR AL ABRIR LA BD CAPTACION" en lugar de ATRIBUCTA — operadores pueden investigar la base equivocada durante incidentes nocturnos, elevando MTTR | Corregir el literal `WS-0101-TEXT-MSG` en CLOSE-BD07ATRIBUCTA; en target: códigos de error estructurados con referencia explícita al componente fallido |
| MR-DEP-07 | 🟠 CRÍTICO | REGULATORIO + EQUIVALENCIA | T-INT-022 | **Misclasificación Art. 61 LIC en wave planning:** P155 y P160 referencian Art. 61 en código fuente pero son `[FILTRO-CONTEXTO]` (no ejecutores); ejecutores reales son P130 (T-INT-022 · RN-S500-098) y P186 `[DATO-REQUERIDO]`. Si analista sin contexto SME clasifica P155/P160 como ejecutores → P130/P186 asignados a wave incorrecta → proceso dormidos→cuenta global→beneficencia pública se rompe → sanción CNBV Art. 61 LIC. Fuente: hallazgo Mario (SME S500) 2026-07-21. BR-051 valida que P155/P160 NO son ejecutores | HITL obligatorio antes de wave planning: Mario (SME S500) firma mapa de ejecutores Art. 61 · Documentar reglas de P186 en GemCog (DATO-REQUERIDO) · SME BIAN + Modelo Operativo confirman service domain antes de asignar wave · Ver F-06 en kb-capa4-flujos.md |

---

### N1: Common Customer View — N2: Customer View

#### N3: 4.1.2 Holdings — N4: P050 CONCENTRACIÓN DE SALDOS (COMS 93 func.) · P052 DISTRIBUCIÓN MULTI-DESTINO · P138 POSICIÓN GLOBAL

> **Fuente:** cap-hld.md · hallazgos P050/P052 H1..H10 + P138-H1..H2

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-HLD-01 | 🟠 CRÍTICO | EQUIVALENCIA + SILENCIOSO | T-HLD-012 | Fallback TC=10 en P052 ante fallo de S080 (L700_RAF_TAR) — produce tipo de cambio efectivo 1.0; todas las transacciones USD del día se convierten a MXN con tasa 1:1 sin alerta; error contable masivo silencioso | Eliminar el fallback completamente; si S080 no disponible → abortar el proceso con alarma P1 inmediata; implementar circuit breaker contra API FIX de Banxico |
| MR-HLD-02 | 🟠 CRÍTICO | PROPIETARIO-MCP | T-HLD-001 · T-HLD-011 | LIB-L006 propietaria Unisys — gestiona BD02ADSALDO (FUN=10 inicialización, FUN=01 lectura, FUN=06 eliminación irreversible); no hay documentación pública del protocolo; bloquea toda la funcionalidad de saldos de P050 | Encapsular LIB-L006 en capa de abstracción de persistencia (repositorio); cubrir todas las funciones en fase de reverse engineering; asegurar cobertura de FUN=06 (eliminación irreversible) |
| MR-HLD-03 | 🟠 CRÍTICO | EQUIVALENCIA | T-HLD-025 | Acumuladores S9(16)V99 COMP en P138 para subtotales de 3 niveles jerárquicos — `long` de Java desborda para saldos bancarios consolidados a la escala de Banamex; resultado incorrecto silencioso en posición global | Usar BigDecimal en todos los acumuladores de los 3 niveles; implementar break-control como state machine; validar con golden-master del mes de mayor volumen |
| MR-HLD-04 | 🟡 ALTO | EQUIVALENCIA | T-HLD-002 · T-HLD-014 | Convención invertida THECALENDAR FUN=18 (retorno 0=hábil, ≠0=inhábil) — contraintuitiva; transpilador que asuma 0=inhábil invierte el calendario bancario; restricción CSI=4/10 hardcoded; FUN=2 en P052 cuenta días calendario, no hábiles | Documentar explícitamente la semántica invertida como invariante; externalizar lista de CSI con calendario a configuración; reemplazar THECALENDAR con servicio de calendario Banxico |
| MR-HLD-05 | 🟡 ALTO | EQUIVALENCIA | T-HLD-003 | 93 funciones COMS en evaluación secuencial (240-MANEJA-MSG) — mínimo 93 casos de prueba de equivalencia funcional requeridos; sin tabla de salto, latencia crece con posición de la función en la cadena EVALUATE | Reemplazar dispatcher con router REST/gRPC con contrato OpenAPI; documentar las 93 funciones como endpoints; ordenar por frecuencia de uso |
| MR-HLD-06 | 🟡 ALTO | HARDCODE + REGULATORIO | T-HLD-008 | Umbral de dormancia 180 días hardcoded como fallback (Ley IC Art. 61) — si S080 no responde, el fallback queda activo sin advertencia; si CNBV modifica el plazo, el hardcode queda desactualizado | Migrar exclusivamente a catálogo configurable; eliminar fallback hardcodeado; disparar alerta si catálogo S080 no responde en lugar de usar valor default |
| MR-HLD-07 | 🟡 ALTO | REGULATORIO | T-HLD-017 | CONLI CNBV R10: 5 condiciones AND obligatorias (FUNCION=1, STATUS=1, PRODUCTO=1, INSTRUMENTO=30, ORIGEN=1 OR 3); layout fijo 160+12+8+4 chars; cualquier variación en condiciones o layout = incumplimiento regulatorio automático | Implementar como regla de negocio explícita con prueba de regresión regulatoria; validar layout con banco receptor interbancario antes del go-live |
| MR-HLD-08 | 🟡 ALTO | PROPIETARIO-MCP | T-HLD-027 | THECALENDAR FUN=13 propietaria Unisys MCP en P138 para proyección de fechas hábiles multi-iteración — no existe en cloud/Java; su ausencia bloquea el modo multi-fecha de P138 | Implementar servicio de calendario con festivos Banxico/CNBV actualizables vía configuración; usar java.time.LocalDate + tabla de festivos |
| MR-HLD-09 | 🟡 MEDIO | HARDCODE | T-HLD-001 · T-HLD-010 · T-HLD-013 | Múltiples hardcoded sin catálogo: 8 sistemas financieros, 5 nodos CSI, 32 sucursales excluidas MEX, ventana 08:00-14:05, CVETRANs privilegiados 618/619/708/720, CVETRANs SECORE 3002/4001, sucursales factoraje 519/870/869 — cada cambio operacional requiere recompilación | Migrar todos a tablas de parámetros configurables antes del cutover; priorizar sucursales (pueden cambiar post-separación Citi) y ventana horaria (SPEI modifica horarios periódicamente) |
| MR-HLD-10 | 🟡 MEDIO | INTERFAZ | T-HLD-006 · T-HLD-007 | L422 dependencia cross-sistema S016 para consulta de saldo cliente (Entry 84, fatal) y nombre de cliente (OPCION=2, no-fatal) — indisponibilidad de S016 degrada o bloquea la funcionalidad Holdings | Encapsular L422 como API REST interna de S016; implementar caché de nombres de cliente con TTL |

---

### N1: Common Services — N2: Reconciliation / Operational GL Sync

#### N3: 6.7.1+6.7.2 Financial/Operational Reconciliation — N4: P330 EXTRACCIÓN DMSII · P360 INTEGRACIÓN DMSII · P312 SALDOS084

> **Fuente:** cap-adj.md · hallazgos H-ADJ-01..08

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-ADJ-01 | 🟠 CRÍTICO | EQUIVALENCIA | T-ADJ-P330-013 · T-ADJ-P360-015 | Pipeline P330→P360 no migratable as-is — copia completa del GL entre instancias es workaround a limitaciones de replicación nativa DMSII; mecanismos WITH LOCK/WITH PURGE y ATTRIBUTE VALUE son propietarios Unisys MCP sin equivalente en Java/Linux | Rediseñar como Change Data Capture (CDC) sobre el GL moderno; eliminar "extracción en archivos planos" como mecanismo de integración GL-a-GL; incluir como milestone 0 obligatorio en el plan de migración |
| MR-ADJ-02 | 🟠 CRÍTICO | ATOMICIDAD | T-ADJ-P360-015 · T-ADJ-P360-012 | CLOSE WITH PURGE en P360 destruye cada archivo fuente tras integrarlo — si P360 falla durante integración de B72, los archivos B20..B71 ya purgados son irrecuperables sin reejecutar P330 completo; base destino en estado inconsistente | En target: no destruir archivos hasta confirmar commit de toda la integración; implementar patrón transactional outbox; mantener archivos en almacenamiento inmutable hasta confirmar integración de las 6 estructuras |
| MR-ADJ-03 | 🟠 CRÍTICO | INTERFAZ | T-ADJ-P330-013 · T-ADJ-P360-001 | P330 aborta en B72 dejando 4 archivos completos + B72/B80 ausentes sin detección automática — P360 ejecutado a continuación integra B20..B71 pero falla al intentar abrir B72; base destino queda con saldos mensuales actualizados pero sin posición contable ni estado de cuenta; inconsistencia silenciosa | Implementar manifesto de extracción (archivo de control con 6 estructuras + checksums + conteos); P360 debe validar completitud del set antes de iniciar cualquier integración |
| MR-ADJ-04 | 🟡 ALTO | PROPIETARIO-MCP | T-ADJ-P330-003 · T-ADJ-P360-002 | ATTRIBUTE VALUE OF MYSELF — mecanismo propietario Unisys MCP para override de fecha de proceso en reprocesos históricos; no tiene equivalente directo en Java/Linux/cloud | Reemplazar por parámetro explícito de línea de comandos (`--fecha-proceso`) o variable de entorno `S151_FECHA_PROCESO`; fallback a consulta de tabla de control cuando el parámetro no se provee |
| MR-ADJ-05 | 🟡 ALTO | PROPIETARIO-MCP | T-ADJ-P360-012 | CALL SYSTEM DMTERMINATE en P360 hace rollback atómico de toda la integración ante fallo de STORE — en JDBC/JPA no existe equivalente directo; múltiples transacciones independientes no son equivalentes | Envolver las 6 integraciones (B20..B80) en una sola transacción JTA; ante excepción no recuperable: rollback + log estructurado + notificación operacional |
| MR-ADJ-06 | 🟡 ALTO | EQUIVALENCIA | T-ADJ-P330-013 | 6 extracciones en secuencia fija en P330 (B20→B21→B70→B71→B72→B80) — pueden paralelizarse en target si se confirma independencia de datos; en mainframe toma N×tiempo_lectura sin paralelismo | Analizar con SME si existe dependencia de datos entre las 6 estructuras; si son independientes: paralelizar con hilos/async + barrera de sincronización (CountDownLatch o CompletableFuture.allOf) |
| MR-ADJ-07 | 🟠 CRÍTICO | SILENCIOSO · REGULATORIO | T-ADJ-P360-010 · T-ADJ-P330-008 | B72POSCONTA: identidad contable SDOACT = SDOANT + CARGOS - ABONOS **no se valida en ningún punto de la cadena** (P330 extrae asumiendo que el origen cuadra, P360 reescribe sin validar) — insumo directo de R04C/R27C CNBV. SME Contable: el signo depende de NATCTA (1=deudora/2=acreedora, `[DATO-REQUERIDO]`); es antipatrón de control interno no tener cuadre en el punto de reescritura del saldo (Art. 144-148) | Agregar la validación de cuadre por cuenta (KEYCTA) respetando NATCTA como **gate de carga en el target** (control que el AS-IS no tiene); toda fila que no cuadre detiene la carga y genera asiento de ajuste auditable; regresión regulatoria CNBV |
| MR-ADJ-08 | 🟡 MEDIO | HARDCODE | T-ADJ-P312-002 · T-ADJ-P312-004 | Nodo 04 (Monterrey) y filtro PRD=1/INS=3/MON=1 hardcoded en P312 — nuevos productos, instrumentos o coberturas para S084 Cobertura Monterrey requieren recompilación | Externalizar nodo, producto, instrumento y moneda como parámetros de configuración; documentar significado financiero de PRD=1/INS=3/MON=1 con SME de S084 antes de migrar |
| MR-ADJ-09 | 🟠 CRÍTICO | EQUIVALENCIA · ATOMICIDAD | T-ADJ-P360-001 · T-ADJ-P360-012 | P360 reintegra con `CREATE + STORE` sobre la base DMSII destino — **no es idempotente**: re-ejecutar (RN-736 permite fecha explícita para reproceso) sobre una base ya integrada arriesga **duplicación** de saldos (si STORE inserta) o **pérdida del anterior** (si sobreescribe sin preservar). SME Contable: el riesgo dominante depende de la política de reproceso `[DATO-REQUERIDO]` (truncate-and-load vs upsert) | Definir y documentar la política de reproceso; en target hacer la carga idempotente (upsert por clave o truncate-por-período transaccional); la prueba de equivalencia debe probar **explícitamente el escenario de re-ejecución**, no solo la carga limpia |

---

### N1: Insights & Information — N2: Operational Data Management

#### N3: 9.1.1 Operational Data Stores — N4: DASDL BD10·BD11·BD12·BD13·BD99·BD02 · L030 S151LIB030 · P606 LEE-ARCHMOVYDES

> **Fuente:** cap-ods.md · hallazgos H-ODS-01..15 + ODS-L030-H01..H03 + ODS-P606-H01..H02

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-ODS-01 | 🟠 CRÍTICO | EQUIVALENCIA | T-ODS-004 | Sucursales 859/100/342/110/511/870 indexan por AUTAPL(08) en lugar de AUTS151(08) — misma longitud, espacios de numeración distintos; sin bifurcación: movimientos de esas 6 sucursales producen NOT FOUND silencioso; trazabilidad CNBV perdida para esas sucursales | Bifurcar clave en modelo relacional con columna discriminante o función de índice parcial por sucursal; validar lista con catálogo CNBV de trazabilidad antes del go-live |
| MR-ODS-02 | 🟠 CRÍTICO | INTERFAZ | T-ODS-017 | AUT-PC NUMBER(12) ≠ AUTS151 NUMBER(08) — la FK entre BD13.B07PROTCOB (150M registros de protección de cobro) y BD10 no puede establecerse directamente; son identificadores de sistemas distintos con distinta longitud | Crear tabla de equivalencia `protcob_mov_xref(aut_pc NUMBER(12), auts151 NUMBER(08))` o campo de cruce explícito; validar relación semántica con equipo de negocio antes de modelar |
| MR-ODS-03 | 🟠 CRÍTICO | EQUIVALENCIA | T-ODS-013 · T-ODS-014 | Tripartita BD12: colapsar OK(~25M)/INFO(~5M)/ERROR(~5M) en tabla única sin discriminante pierde SLOs diferenciados y semántica de estados; 9 tablas (3 principales + 6 extensiones con FK por tipo) deben preservar su separación lógica | Tres tablas físicas separadas con índices propios, o tabla única con columna `tipo_resultado VARCHAR(5) CHECK IN ('OK','INFO','ERROR')` y partial indexes por tipo; modelar las 6 tablas de extensión con FK tipada |
| MR-ODS-04 | 🟠 CRÍTICO | PROPIETARIO-MCP | T-ODS-028 · T-ODS-035 | L030 (S151LIB030, 19,253 LOC) NO es transpilable — usa CHANGE ATTRIBUTE TITLE/LIBACCESS/FUNCTIONNAME, patrón CANCEL de Unisys MCP (carga dinámica de librerías), OPEN INQUIRY DMSII; TODOS los programas S151 dependen de L030 en runtime | No transpilir L030; diseñar los 6 microservicios de plataforma (sistema-fechas, catálogo-transacciones, control-batch, consulta-movimientos, estructura-organizacional, cliente-enrichment) como Milestone 0 de la migración S151 |
| MR-ODS-05 | 🟡 ALTO | EQUIVALENCIA | T-ODS-005 | NIO ALPHA(16) mapeado a tipo numérico — NIO es alfanumérico; mapearlo a BIGINT produce error silencioso en operaciones SPEI con caracteres no-dígito; valor crítico para referencia Banxico | Mapear `NIO → VARCHAR(16)`; nunca a tipo numérico; validar registros históricos con caracteres no-dígito antes del cutover |
| MR-ODS-06 | 🟡 ALTO | EQUIVALENCIA | T-ODS-007 | RFC-BENEF ALPHA(18) vs RFC-ORD ALPHA(13) — asumir longitud uniforme de 13 trunca RFC-BENEF silenciosamente; error de identificación de beneficiario reportable al SAT (Anexo 20) | `RFC_ORD → VARCHAR(13)`, `RFC_BENEF → VARCHAR(18)`; no crear columna RFC genérica unificada en modelo destino |
| MR-ODS-07 | 🟡 ALTO | EQUIVALENCIA | T-ODS-010 · T-ODS-023 | OCCURS en BD11 y BD99 sin equivalente SQL directo — B21SDMENCON1 OCCURS 12 (saldos por período de 12 meses); B12POSICION OCCURS 5 (CARGO/ABONO por día hábil); colapsar en columnas produce estructura no escalable | Explotar OCCURS 12 → 12 filas con columna `indice_periodo (1-12)`; OCCURS 5 → 5 filas con columna `dia_habil (1-5)`; evaluar impacto en performance con volumetría real antes de decidir |
| MR-ODS-08 | 🟡 ALTO | INTERFAZ | T-ODS-009 | B70POSICION reside físicamente en PACKNAME=S067REMESAS — caída del pack S067 hace inaccesible B70POSICION aunque S151 esté en línea; dependencia cross-sistema no controlada por S151 | Reasignar PACKNAME a pack propio de S151 antes del cutover; coordinar ventana con equipo S067; incluir en plan de contingencia |
| MR-ODS-09 | 🟡 MEDIO | EQUIVALENCIA | T-ODS-018 | STATUS ALPHA(02) en B08TDMIGCAP ('AC'/'CA') vs STATUS NUMBER(02) en B07PROTCOB (0-5) — no intercambiables; unificar en columna STATUS genérica produce comparaciones inválidas; comparaciones ALPHA son case-sensitive | Mantener tipos distintos: `status_protcob SMALLINT CHECK IN (0,1,2,3,4,5)` vs `status_tarjeta VARCHAR(2) CHECK IN ('AC','CA')`; no fusionar en columna STATUS transversal |
| MR-ODS-10 | 🟡 MEDIO | EQUIVALENCIA | T-ODS-012 | FEC NUMBER(06) vs NUMBER(08) post-CRONOS2K — programas que leen FEC como NUMBER(06) truncan el siglo silenciosamente: "2026" → "26", interpretado como 1926 en lógica de fechas | Auditar programas que referencian FEC buscando marcador `*INICIA CODIGO DE RENOVACION CRONOS 2000`; en destino: DATE nativo o columna YYYYMMDD INTEGER(8); nunca INTEGER(6) para fechas post-2000 |
| MR-ODS-11 | 🟡 MEDIO | HARDCODE | T-ODS-016 | SECOK/SECINF/SECERR NUMBER(08) en BD12 — techo absoluto 99,999,999; si un período procesa más de 100M movimientos, desbordamiento silencioso de contadores de secuencia; gaps en SEC indican movimientos eliminados | En target: BIGINT para contadores de secuencia; alerta a 80% del techo (79.9M) durante coexistencia; auditar gaps de SEC en históricos como indicadores de movimientos eliminados |
| MR-ODS-12 | 🟡 MEDIO | EQUIVALENCIA | T-ODS-010 · T-ODS-024 | BIT VECTOR DMSII — subsets WHERE STAMOV=1 (saldos activos) y WHERE STAARC=1 (archivos procesados) no tienen equivalente SQL directo; consultar la base sin el BIT VECTOR incluye registros históricos e introduce duplicación aparente | Reemplazar con partial index: `CREATE INDEX idx_saldos_activos ON sdomencon WHERE stamov = 1`; validar cardinalidad antes del cutover |
| MR-ODS-13 | 🟡 MEDIO | INTERFAZ | T-ODS-025 | NUMERO1+NUMERO2 (clave cliente 20 dígitos en B03SDOCTE, BD02) — partición artificial en dos NUMBER(10); significado semántico de cada mitad no está documentado en el DASDL; clave lógica de 20 dígitos no estándar en bancos MX | Validar con equipo de negocio el significado antes de mapear; usar `LPAD(numero1,10,'0') || LPAD(numero2,10,'0')` como clave transitoria durante migración; documentar en glosario de migración |

---

### N1: Channels — N2: Assisted Touchpoints

#### N3: 2.1.1 Teller — N4: P010 LINEA (gateway online persistente)

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-TEL-01 | 🟡 ALTO | HARDCODE | T-TEL-001 | ~30 bibliotecas `LIB-CONS{NNN}` hardcoded en el dispatcher P010 — cada nueva pantalla de teller requiere recompilación del gateway; el enrutamiento de transacciones no es dinámico ni configurable en producción | Extraer la tabla de enrutamiento a catálogo externo (config service / base de datos); el gateway debe cargar la tabla en arranque y soportar recarga sin redeployment |
| MR-TEL-02 | 🟡 ALTO | SEGURIDAD | T-TEL-003 | `Q015{NNN}` códigos de seguridad por pantalla hardcodeados en P010 — cualquier cambio de permisos de pantalla requiere recompilación y despliegue; no hay modelo de autorización dinámico ni auditoría de cambios de permiso | Sustituir por modelo RBAC/ABAC con catálogo de permisos por pantalla en base de datos auditada; los cambios de permiso deben quedar en log con user+timestamp |
| MR-TEL-03 | 🟡 ALTO | PROPIETARIO-MCP | T-TEL-002 | Daemon persistente con loop `PERFORM UNTIL W77-FIN=1` controlado por señales `HI-4/HI-6` (interrupciones propietarias Unisys MCP) — sin graceful shutdown, health check ni capacidad de actualización sin corte del gateway | Reemplazar por proceso long-running con endpoints de health/liveness/readiness (Kubernetes probes); implementar graceful shutdown con draining de transacciones en vuelo antes de terminar |
| MR-TEL-04 | 🟡 MEDIO | INTERFAZ | T-TEL-010 | Sistema S016 para consultas MDA (módulos P18/P19/P20) — indisponibilidad de S016 degrada o bloquea completamente las consultas de teller; no hay circuit breaker ni modo degradado documentado | Implementar circuit breaker con timeout configurable; definir modo degradado explícito (retornar datos en caché o error informativo al operador); no bloquear otras transacciones de teller si S016 no responde |

---

### N1: Product Processing — N2: Operational Support

#### N3: 8.1.1 Business Scheduling — N4: P075 CambioDia + P100 Fecha-de-Proceso + P103 Corporativo

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-SCH-01 | 🟠 CRÍTICO | SILENCIOSO | T-SCH-002 | P075 invoca `DAME_TIT` (librería L080) para cerrar el día bancario; si DAME_TIT falla, `STATUS` no se establece en -1 — el loop batch continúa sin detectar el fallo; el cierre del día queda omitido sin ninguna señal al orquestador | Implementar health-check explícito de L080 antes de invocar; registrar cada invocación con resultado; cualquier status ≠ 0 debe abortar y alertar en el orquestador del target |
| MR-SCH-02 | 🟠 CRÍTICO | PROPIETARIO-MCP | T-SCH-002, T-SCH-004 | `CHANGE ATTRIBUTE TITLE` resuelve dinámicamente la librería L080/INIBATCH en runtime MCP construyendo el nombre como string — mecanismo sin equivalente en Java/cloud; si el nombre no se resuelve, P075 falla silenciosamente | Reemplazar por inyección de dependencia configurable (spring bean / service locator) en el target; registrar en ADR la semántica exacta del name-building dinámico |
| MR-SCH-03 | 🟠 CRÍTICO | PROPIETARIO-MCP | T-SCH-020 | P103 invoca `THECALENDAR IN LOCSUP` (FUNCION=13) para calcular el siguiente día hábil bancario antes de avanzar FECPRO — biblioteca propietaria Unisys MCP; bloquea el avance de la fecha de proceso si no se reemplaza por completo antes de la migración | Reemplazar con servicio de calendario Banxico (circular electrónica de días inhábiles); equivalencia debe probarse contra el historial de días inhábiles bancarios de al menos 3 años anteriores |
| MR-SCH-04 | 🟡 ALTO | PROPIETARIO-MCP | T-SCH-004, T-SCH-008 | `CALL SYSTEM DMTERMINATE` en P075 y P100 como mecanismo de abort ante error DMSII — terminación abrupta propietaria Unisys; en el target el proceso quedaría huérfano sin rollback de recursos abiertos | Reemplazar por `throw RuntimeException` con código de salida no-cero y cierre explícito de conexiones antes de abortar; definir exit-code canónico para fallo de SCH |
| MR-SCH-05 | 🟡 ALTO | SILENCIOSO | T-SCH-012 | P100 retorna una fecha válida (día anterior) ante parámetros de entrada inválidos — el caller no detecta la anomalía; un parámetro corrupto produce una fecha de proceso silenciosamente incorrecta propagada a todos los programas del día | Retornar error explícito (excepción o status distinguible) cuando los parámetros de entrada no cumplan las precondiciones; loggear el intento de uso con parámetros inválidos |
| MR-SCH-06 | 🟡 ALTO | EQUIVALENCIA | T-SCH-009 | S006LOCSUP func=15 es el único proveedor del calendarizador bancario para P100 — contrato de función no documentado; una reimplementación que no replique exactamente el comportamiento de días hábiles produciría desvíos de fechas en operaciones programadas y vencimientos | Documentar el contrato completo de S006LOCSUP func=15 (zona horaria, festivos vigentes, comportamiento en fronteras de año); crear test de equivalencia con calendar oracle conocido |
| MR-SCH-07 | 🟡 MEDIO | SILENCIOSO | T-SCH-021 | Re-ejecución del modo PROYECTA de P103 avanza FECPRO en dos días hábiles consecutivos sin detectar "ya ejecutado hoy" — sin idempotencia; en el target un retry por fallo de red ejecutaría el avance dos veces, adelantando la fecha de proceso un día de más | Agregar checkpoint de idempotencia (FECPRO ya adelantada para esta fecha de negocio → no avanzar); loggear el intento de doble avance como advertencia |

---

### N1: Product Processing — N2: Customer Management

#### N3: 6.1.4 Statements — N4: P158 MOVSXCONT

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-STA-01 | 🟠 CRÍTICO | PROPIETARIO-MCP | T-STA-007 | P158 genera dinámicamente un job WFL para invocar P170 (sort masivo) usando auto-submisión de tarea propia — mecanismo propietario Unisys MCP sin equivalente en arquitecturas cloud-native; si el WFL no arranca, P158 no detecta el fallo | Reemplazar por invocación directa de servicio de sorting en el target (Spark sort / Step Functions) o por orquestador de jobs; documentar la semántica de auto-submisión en ADR |
| MR-STA-02 | 🟡 ALTO | EQUIVALENCIA | T-STA-010 | SORT sobre 9 campos de ARCH-ORD determina el orden de movimientos en el estado de cuenta entregado al cliente — si el target ordena con semántica diferente, el cliente recibe movimientos en orden distinto, generando diferencias con el extracto histórico y potenciales reclamaciones CONDUSEF | Reproducir exactamente la semántica de los 9 campos de sort; crear test de equivalencia con extracto de movimientos conocidos y verificar orden contra P158 original |
| MR-STA-03 | 🟡 ALTO | INTERFAZ | T-STA-008 | `NODO-ORIGEN` y `NODO-DESTINO` están embebidos en el nombre externo del archivo de estado de cuenta — el particionamiento multi-instancia depende de naming propietario MCP no portable a rutas cloud | Diseñar en el target una convención de naming portable (prefijo/sufijo configurable por entorno); documentar el mapeo NODO-ORIGEN/NODO-DESTINO → bucket/topic path en el ADR de interfaz |
| MR-STA-04 | 🟡 ALTO | PROPIETARIO-MCP | T-STA-005 | P158 depende de THECALENDAR a través de BD99/CONSISDIA para determinar la fecha del estado de cuenta — si el calendario falla, los estados de cuenta se generan con fecha equivocada; potencial reclamación regulatoria ante CONDUSEF | Reemplazar con servicio de fecha de proceso canónico (mismo que SCH); el servicio debe ser accesible sincrónicamente antes del inicio del sort; configurar failover con caché persistente |
| MR-STA-05 | 🟡 MEDIO | EQUIVALENCIA | T-STA-013 | `A2K-BASE-YEAR=50` en CRONOS2K: años < 50 → 2000+, ≥ 50 → 1900+ — la librería expira en 2050; estados de cuenta generados con fecha posterior a 2050 mostrarán año en siglo XIX en el extracto del cliente | Sustituir CRONOS2K por la API estándar de fecha del target; validar que ningún cálculo de plazo, aniversario o vencimiento use la convención de 2 dígitos |

---

### N1: Product Processing — N2: Interest & Fees

#### N3: 6.1.5 Interest & Fees — N4: P130 INTERES + WFL LINEA

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-INT-01 | 🟠 CRÍTICO | EQUIVALENCIA | rules-s151-p050-p052 · RN-S151-311 | `W77-TIPO-CAMBIO` tiene `PIC 9(12)V9(06)` — documentado incorrectamente como `9(06)V99`; con la PIC incorrecta en el target, tipos de cambio con más de 6 dígitos enteros o más de 2 decimales se truncan silenciosamente en cálculos FX del GL; adicionalmente, `status=1` en `020700-TIPO-CAMBIO` es éxito informativo no detectado | Usar `BigDecimal(18,6)` en el target; verificar `status=1` como condición de éxito (no reintentar); añadir validación de rango en conversión FX |
| MR-INT-02 | 🟠 CRÍTICO | SILENCIOSO | T-INT-005 | `WKS-SIN-LBS151`: si activo, los tres asientos GL (CVE 3000 rendimiento neto / CVE 4009 ISR / CVE 809 bruto CNBV) no se generan — rendimientos e ISR aplicados en S500 sin asiento contable en GL; brecha contable silenciosa sin alerta ni desvío en el balanceo del lote | Convertir `WKS-SIN-LBS151` en flag de emergencia con log de auditoría obligatorio; en el target, cualquier activación debe generar alerta P1 y aparecer en el dashboard de control |
| MR-INT-03 | 🟠 CRÍTICO | EQUIVALENCIA | T-INT-011..016 | Librería CAPITALIZA propietaria calcula el rendimiento neto e ISR sobre depósitos — contrato de función no documentado; una divergencia de centavos en la tasa o en el cálculo de ISR produce discrepancia en la Serie R CNBV (reporte de rendimientos) | Documentar el contrato completo de CAPITALIZA (inputs, outputs, fórmulas, redondeo); implementar en el target con test de equivalencia contra al menos 1,000 cuentas reales de UAT; obtener validación del equipo contable antes del cutover |
| MR-INT-04 | 🟡 ALTO | REGULATORIO | T-INT-020 | Art. 96 CONDUSEF: cancelación automática de cuenta por saldo promedio mínimo insuficiente — si la lógica de umbral temporal y el cálculo de saldo promedio no se replican exactamente, cuentas elegibles permanecen activas generando infracción CONDUSEF | Replicar la lógica Art. 96 con el mismo umbral temporal y la misma fórmula de saldo promedio; crear test regulatorio con cuentas que bordeen el umbral; coordinar con Compliance la fecha de vigencia post-migración |
| MR-INT-05 | 🟡 ALTO | REGULATORIO | T-INT-022 | Art. 61 CUB: traspaso automático a cuenta de beneficencia por inactividad prolongada — la condición temporal (N años sin movimiento) y el monto exacto a traspasar deben replicarse; un error produce responsabilidad regulatoria ante Banxico | Replicar la condición Art. 61 CUB con el mismo período de inactividad y la misma lógica de monto; crear test con fechas de última operación conocidas para verificar la activación correcta del traspaso |
| MR-INT-06 | 🟡 ALTO | SILENCIOSO | T-INT-014..016 | Invariante `CVE 809 = CVE 3000 + CVE 4009` (bruto = neto + ISR) no se valida explícitamente en el código — si el target implementa los tres asientos independientemente y uno diverge por error de redondeo, el reporte Serie R-04 CNBV queda descuadrado sin alerta | Implementar la validación como postcondición del servicio de intereses; si CVE 809 ≠ CVE 3000 + CVE 4009 (tolerancia 1 centavo), lanzar excepción y no emitir los asientos |
| MR-INT-07 | 🟡 ALTO | EQUIVALENCIA | T-INT-023..025 | `DAME-COMISION OCCURS 210`: tabla de comisiones indexada por tipo de persona (PF/PM) e instrumento, cargada desde S080 — hasta 15 comisiones mensuales acumuladas por cuenta; en el target, el servicio de comisiones debe replicar la lógica de lookup incluyendo el fallback cuando el slot está vacío | Documentar la semántica del array DAME-COMISION incluyendo valores de fallback; en el target, implementar como servicio de tarifa con caché por sesión de cálculo; crear test con los 15 slots llenos y con slots vacíos intercalados |
| MR-INT-08 | 🟡 MEDIO | HARDCODE | T-INT-001 | Flags `DIA30/DIA15/DIA1MES` calculados por WFL LINEA — la lógica de "último/primer día hábil del mes" está hardcodeada en el WFL MCP; en el target estos flags deben provenir del servicio de calendario bancario canónico (mismo que SCH y STA) | Migrar el cálculo de DIA30/DIA15/DIA1MES al servicio de calendario; asegurar que el servicio expone una API de "es primer/último día hábil del mes" para consumo del orquestador de intereses |
| MR-INT-09 | 🟡 MEDIO | EQUIVALENCIA | T-INT-017 | Conversión USD→MXN con `ROUNDED` de COBOL usa semántica half-up — en Java, `RoundingMode.HALF_EVEN` (Banker's rounding, el default) no es equivalente; diferencias de 1 centavo acumuladas en cálculo de ISR producen discrepancias en el reporte Serie R | Especificar `RoundingMode.HALF_UP` explícitamente en todos los cálculos de conversión de moneda en el target; añadir test de equivalencia con tipos de cambio con decimales en el quinto dígito |

---

### N1: Product Processing — N2: CPE Mensual

#### N3: T.6.1 CPE — N4: P310-CARGA · P330-CALCULOS-PROD-ESP · P335/S500P400

> **Fuente:** cap-cpe.md · hallazgos de migración H-CPE-01..07

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-CPE-01 | 🟡 MEDIO | PROPIETARIO-MCP | T-CPE-002 | Bucle activo `WHILE NOT RCPESEC · WAIT(15 seg)` para esperar el archivo de control CPESEC — patrón de polling propietario MCP que consume CPU y no tiene equivalente directo en arquitecturas cloud-native; no hay timeout ni alarma si el archivo no aparece | Reemplazar por trigger event-driven (S3 event, Pub/Sub, Kafka message) cuando el archivo esté disponible; implementar timeout con alerta P2 si CPESEC no aparece en N minutos tras inicio del ciclo CPE |
| MR-CPE-02 | 🟡 ALTO | REGULATORIO + HARDCODE | T-CPE-003 | Factores ISR cargados desde catálogos S080 — las tasas ISR (retención sobre rendimientos de captación) cambian anualmente por decreto SAT; si el catálogo S080 no se actualiza con el decreto vigente, P310 aplica tasas del año anterior a todos los contratos CPE del ciclo mensual | Externalizar como configuración con versionado anual; incorporar el proceso de actualización de tasas ISR en el ciclo regulatorio SAT; generar alerta si el catálogo S080 no fue actualizado tras la publicación del decreto |
| MR-CPE-03 | 🟡 ALTO | REGULATORIO + INTERFAZ + HARDCODE | T-CPE-004 | Formato ARCHISAT para declaración fiscal SAT especificado por la autoridad fiscal — el layout del archivo es un contrato externo con el SAT; cualquier cambio en el target (nombre de campo, longitud, encoding) sin aprobación regulatoria genera rechazo de la declaración fiscal del ciclo mensual CPE. **BLOQUEADOR DE CUTOVER**: `SAT-IDSISTEMA="S152"` está hardcodeado en el header del ARCHISAT (RN-S500-197); si este ID es asignado por el SAT al sistema legacy, el sistema modernizado requerirá un ID diferente negociado con el SAT antes del go-live; durante la coexistencia paralela, ambos sistemas emitiendo con el mismo ID generarían conflicto en las declaraciones fiscales | Verificar con el área fiscal si `SAT-IDSISTEMA="S152"` es autoasignado o registrado ante el SAT; si es SAT-asignado, iniciar el proceso de registro del sistema modernizado previo al cutover (lead time regulatorio estimado: semanas); durante parallel-run, definir si legacy y nuevo pueden coexistir con el mismo ID o requieren IDs distintos; documentar el layout exacto del ARCHISAT como contrato de salida con versión; implementar validación de schema antes de enviar |
| MR-CPE-04 | 🟠 CRÍTICO | EQUIVALENCIA + REGULATORIO | T-CPE-006 · T-CPE-007 | Tablas TIIE y PLUS de 81 rangos con aritmética packed decimal en escalas `PIC 9(04)V9(04)` — el redondeo de tasas de interés en transpilación puede producir divergencias de centavos por contrato; acumulado en miles de contratos CPE, el error afecta el ISR retenido reportado al SAT y la tasa CNBV de rendimiento | Golden master tests con 100% de contratos CPE de producción; especificar `RoundingMode.HALF_UP` y `BigDecimal(8,4)` en el target para replicar la aritmética packed decimal; validar rounding contra referencia Banxico TIIE |
| MR-CPE-05 | 🟠 CRÍTICO | EQUIVALENCIA | T-CPE-007 | P330 (CALCULOS-PROD-ESP) es el programa de mayor riesgo del ciclo CPE — implementación original de A. Pulido Vega (1989), modificada por Stefanini (2022, CPE 2022R07M); el cálculo de rendimiento mensual neto e ISR sobre saldo mínimo diario por región acumula 33 años de ajustes; equivalencia exacta ≥ 99.99% obligatoria; una divergencia de 0.01% en el rendimiento de un portafolio CPE grande puede representar millones de MXN | Parallel-run mínimo 3 meses con 100% de contratos CPE activos; CFO y equipo de riesgo deben firmar sign-off por cualquier divergencia > 0.01%; documentar cada ajuste histórico de P330 como invariante en el ADR de equivalencia CPE |
| MR-CPE-06 | 🟡 MEDIO | DOCUMENTACIÓN | T-CPE-010 | Anomalía de naming en P335: el archivo extraído `S500_SOURCE_P335.txt` tiene `PROGRAM-ID: S500P400` y comentario `"CODIGO DE BATCH P400"`, pero el WFL lo ejecuta como `RUN #P335 [T335]` — en Unisys MCP el PROGRAM-ID puede diferir del nombre del objeto compilado; sin confirmación, el equipo de transpilación puede buscar el objeto incorrecto en el repositorio de producción | Confirmar en producción que el objeto compilado `S500/OBJECT/P335` existe y corresponde a este fuente antes de transpilación; documentar la discrepancia PROGRAM-ID/nombre-de-objeto en el inventario de fuentes S500 |
| MR-CPE-07 | 🟡 MEDIO | ATOMICIDAD | T-CPE-009 | `START #JWFLLOTE("DISPERSACPE")` lanza el job WFL DISPERSACPE de forma asíncrona — no hay `WAIT` explícito de su completación antes de ejecutar P335; si DISPERSACPE falla o se retrasa, P335 procesa las cuentas CPE ligadas a tarjeta sin que los resultados CPE estén dispersados entre nodos | En el target: definir explícitamente el punto de sincronización entre DISPERSACPE y P335; implementar gate de verificación de completación de DISPERSACPE antes de iniciar P335; considerar patrón fan-out/fan-in con barrier |

---

### N1: Technology Support — N2: Regulatory Reporting

#### N3: T.4.1 Regulatory Reporting (CFR) — N4: P130 AGRUPADOR + P131 TRADUCTOR

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-CFR-01 | 🟠 CRÍTICO | HARDCODE | T-CFR-001 | `SETID="BNMEX"` hardcodeado 14 veces en P131 (11 activas + 3 comentadas) — identificador de institución financiera que cambia en la separación Citi/Banamex; en el target post-separación, cualquier instancia no actualizada enviaría registros CFR con el SETID incorrecto ante CNBV | Parametrizar SETID como variable de entorno / secreto de vault; auditar todas las ocurrencias antes del cutover; añadir test de regresión que verifique el SETID en el archivo de salida CFR |
| MR-CFR-02 | 🟠 CRÍTICO | EQUIVALENCIA | T-CFR-025 | Campo `FIDEICOMISO` del PAQUETECONTABLE recibe el valor de `AREA` del movimiento (asignación original a fideicomiso comentada en código — RN-S151-112) — mapearlo por nombre de campo produce error semántico silencioso en S254/PeopleSoft que asigna el área como fideicomiso | Documentar la asignación `FIDEICOMISO←AREA` como invariante de transformación; crear test de equivalencia que verifique el valor correcto en el output PAQUETECONTABLE; coordinar con equipo S254 el significado de negocio |
| MR-CFR-03 | 🟠 CRÍTICO | REGULATORIO | T-CFR-015..027 | 9 catálogos de traducción hard-linked al binario (COPC/CCFI/PNPA/CXEV/COCO/DREG-FOBA/ARCH-CAT/SIUN/ARCH-INTE) — cualquier actualización regulatoria de catálogos CNBV requiere coordinación de despliegue con cambio de código; sin versioning de reglas | Externalizar los 9 catálogos a base de datos parametrizable con versioning; el sistema debe poder cargar una versión específica del catálogo para reprocesar periodos históricos bajo las reglas vigentes en esa fecha |
| MR-CFR-04 | 🟠 CRÍTICO | REGULATORIO | T-CFR-023 | DREG-FOBA: doble registro contable para cuentas FOBAPROA es requerimiento regulatorio histórico vigente — si la lógica de loop CTA-ORIG+OCURRENCIA no se replica exactamente, el archivo CFR queda con asientos incompletos generando observación CNBV en revisión de cartera | Replicar el loop FOBAPROA incluyendo el campo ARCH-DREG-FOBA completo; crear test de equivalencia con cuentas FOBAPROA reales de UAT y verificar el par de asientos en el output |
| MR-CFR-05 | 🟡 ALTO | EQUIVALENCIA | T-CFR-020 | Loop CONSEC CXEV→SIUN→COCO: un registro de entrada genera N pares contables en PAQUETECONTABLE (expansión 1→N por número de consecutivos) — el sistema destino debe soportar cardinalidad variable y garantizar que el total del trailer sea coherente con la suma de los N registros generados | Diseñar el servicio destino con capacidad 1→N; añadir validación de cuadre total-de-registros vs sum-de-importes antes de emitir el archivo CFR; crear test de expansión con N=1, N=3, N=10 |
| MR-CFR-06 | 🟡 ALTO | HARDCODE | T-CFR-001 | CPPS L710: parámetros de desvío (SUCINI/CVETRA/TC/LIBRO) son distintos por sistema origen — si el target trata todos los sistemas con los mismos valores, los desvíos masivos o la pérdida silenciosa de movimientos pueden pasar desapercibidos hasta el balance diario | Documentar los valores CPPS por sistema en catálogo parametrizable; el servicio debe cargar el perfil correcto según el sistema origen de cada movimiento |
| MR-CFR-07 | 🟡 ALTO | PROPIETARIO-MCP | T-CFR-011 | ESENDAUTO OUTBOARD (distribución de alertas) e INTELARSND (distribución ETL) son servicios propietarios MCP — el comportamiento "primera ocurrencia por tipo" de ESENDAUTO no tiene equivalente directo en plataformas cloud | Mapear ESENDAUTO a servicio de notificación cloud (SNS/EventBridge) con deduplicación por tipo de alerta; documentar en ADR la semántica de "primera ocurrencia" y su equivalente en el target |
| MR-CFR-08 | 🟡 MEDIO | SILENCIOSO | T-CFR-002 | Filtro de FUNCION silencioso: valores distintos de 1/2/99 no generan error ni desvío — movimientos con un código de FUNCION no previsto se pierden silenciosamente sin traza ni contador de exclusión | Implementar contador de exclusiones por código FUNCION desconocido; lanzar alerta si el contador supera cero en cualquier ejecución; registrar en log los registros excluidos con su FUNCION |
| MR-CFR-09 | 🟡 MEDIO | HARDCODE | T-CFR-018 | `LIBCON="CONTABLE  "` (10 chars con trailing spaces) hardcodeado en P131 — contrato de interfaz con S254/PeopleSoft que puede cambiar post-separación Citi/Banamex | Parametrizar LIBCON como configuración de entorno; verificar con equipo S254 si el valor es estable post-separación |
| MR-CFR-10 | 🟡 MEDIO | HARDCODE | T-CFR-025 | `IDASIEN-VERS=1` y conversión `CVE-REG "05"→"01"` hardcodeados en PAQUETECONTABLE — valores de protocolo del interfaz con S254 embebidos en código; cualquier actualización de versión del protocolo PeopleSoft requiere recompilación | Externalizar la versión del protocolo y la conversión CVE-REG a configuración; añadir test de contrato que detecte cambios de versión en S254 antes de desplegar |
| MR-CFR-11 | 🔴 DEFECTO-PROD | HARDCODE + REGULATORIO | cap-cfr · P108 CUIF extractor | P108 CUIF extractor — campo SECTOR hardcoded con valor 15 en lugar de 11 (sector correcto para depósitos a la vista según catálogo CNBV). El reporte CUIF enviado a CNBV clasifica incorrectamente el portafolio de captación; todos los asientos de P108 declaran sector 15 (préstamos) cuando el correcto es 11 (depósitos). Defecto con impacto directo en estadísticas macroeconómicas del sistema bancario mexicano. | `[HITL URGENTE con área Regulatoria y Compliance]`: (1) Determinar periodos afectados y volumen de asientos mal clasificados; (2) Evaluar obligación de corrección retroactiva del CUIF ante CNBV; (3) En el target: sector debe provenir de catálogo parametrizable por instrumento/producto — nunca literal hardcodeado. Coordinar notificación a CNBV antes del cutover de P108. |

---

### N1: Common Services — N2: Reconciliation

#### N3: 6.7.2 Operational Reconciliation — N4: S151REGISTRA + P021 ALGOL + P602/P620/P630/P655/P670/P680/P690

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-ORC-01 | 🔴 DEFECTO-PROD | SILENCIOSO | T-ORC-028 | P680 línea 537: `SECERRHI` se copia en `SECINFHI` (sobreescribe la sección de información alta con la de errores altos) — en reconciliación mensual, el auditor ve ceros en SECERRHI del reporte donde deberían aparecer errores reales | `[HITL URGENTE]` Corrección de una línea en P680 antes del próximo cierre mensual; verificar si el defecto ya afectó cierres previos comparando SECERRHI vs respaldos históricos |
| MR-ORC-02 | 🟠 CRÍTICO | EQUIVALENCIA | T-ORC-008, T-ORC-011 | Incompatibilidad REGISTRA1 (`CVETRAN PIC 9(04)`) vs REGISTRA2 (`CVETRAN PIC 9(06)` + CVEDESVIO+GUIDESVIO): si el target unifica en un solo formato, los 15 programas S500 compilados con REGISTRA1 enviarían un layout incorrecto al GL | Mantener ambos variantes de layout hasta que todos los programas S500 migren; en el target, el endpoint GL debe aceptar ambos formatos y seleccionar el parser correcto según el header de versión |
| MR-ORC-03 | 🟠 CRÍTICO | ATOMICIDAD | T-ORC-010 | `REFS151-ANT`: encadenamiento de asientos por overflow de 5 slots CVETRAN usa un campo de referencia circular — si el target no implementa el campo, movimientos con más de 5 CVETRANs generan asientos GL huérfanos; la brecha es indetectable en S500 y solo visible en reconciliación CNBV | Implementar el mecanismo de encadenamiento REFS151-ANT; crear test con casos de 1, 5 y 6+ CVETRANs por movimiento; verificar que el total de asientos en GL cierra contra el total de movimientos en S500 |
| MR-ORC-04 | 🟠 CRÍTICO | PROPIETARIO-MCP | T-ORC-016..019 | P021 ALGOL no transpilable: envía señales HI a pasos S500 vía `DCKEYIN` (primitiva de consola MCP) para orquestar el cierre diario — reescritura completa obligatoria como job step en orquestador moderno | Reescribir P021 como DAG (Airflow / Step Functions) con las mismas dependencias y señales; verificar que los pasos 9, 12 y 2 de la secuencia del cierre se replican con la misma cardinalidad |
| MR-ORC-05 | 🟠 CRÍTICO | PROPIETARIO-MCP | T-ORC-020 | `CHANGE ATTRIBUTE TITLE/BYFUNCTION` en P602 para resolución dinámica de LIBCTL — S151L001CTL es el hub central con fan-in P602/P610/P630/P655; sin este mecanismo el routing dinámico de librerías no funciona | Reemplazar por inyección de dependencia (service locator / spring profiles) con la misma tabla de routing; el hub S151L001CTL debe convertirse en un servicio de routing configurable |
| MR-ORC-06 | 🟠 CRÍTICO | PROPIETARIO-MCP | T-ORC-023 | `CLOSE WITH SAVE/RELEASE/PURGE` en P630 — semántica de persistencia DMSII MCP sin equivalente directo en JDBC/JPA; transpilación incorrecta produce archivos sin persistencia (`SAVE`) o sin borrado del registro anterior (`PURGE`) | Documentar la semántica exacta de cada CLOSE variant en el ADR de equivalencia DMSII; en el target, implementar como transacción + delete explícito según el variant; crear test de idempotencia |
| MR-ORC-07 | 🟡 ALTO | ATOMICIDAD | T-ORC-013 | Rechazo de S151 no revierte S500: un movimiento rechazado por el GL queda aplicado en S500 sin asiento contable — brecha contable que solo se detecta en el log de rechazos del lote nocturno; sin alerta en tiempo real | Implementar saga con compensating transaction: si GL rechaza, emitir asiento de reverso en S500 antes de marcar el movimiento como rechazado; loggear y alertar cada brecha |
| MR-ORC-08 | 🟡 ALTO | SILENCIOSO | T-ORC-012 | Modo contingencia: mensajes encolados durante indisponibilidad de S151 requieren reproceso manual antes del cierre contable — si el operador olvida el reproceso, los mensajes quedan en la cola permanentemente sin alerta automática | Implementar alerta automática si la cola supera N mensajes o si transcurre X minutos sin draining antes del cierre contable; documentar el SLA de reproceso en el runbook |
| MR-ORC-09 | 🟡 ALTO | SILENCIOSO | T-ORC-001 | La validación de versión de librería S151 continúa aunque `CVEERROR≠0` — el sistema puede operar con una versión incompatible de la librería S151 sin señal al caller; los errores downstream se atribuyen a datos, no a incompatibilidad de versión | Convertir CVEERROR≠0 en error fatal al inicio del proceso; registrar la versión esperada vs la encontrada en el log de arranque; añadir health check de versión al endpoint de readiness |
| MR-ORC-10 | 🟡 MEDIO | HARDCODE | T-ORC-003..004 | Múltiples hardcoded de sucursales/cajas: 342 vs 350 (discrepancia comentario/código), SUC-SPEI=859/CAJ-SPEI=40, SUC-CAJA=342/CAJ-CAJA=36, perfiles PIM — cada nuevo canal de pago requiere recompilación de los 15 programas S500 | Externalizar la tabla de sucursal/caja por canal (SPEI, PIM, CAJA, FOBAPROA) a catálogo configurable; resolver la discrepancia 342 vs 350 con equipo de operaciones antes del cutover |
| MR-ORC-11 | 🟡 MEDIO | EQUIVALENCIA | T-ORC-006..007 | `SGIRO` (0/1/2) y `ORIGEN` (1/2/3) como clasificadores contables de S151 — sin implementación explícita en el target, movimientos quedan sin clasificación de sobregiro y origen interbancario; impacto en clasificación IFRS 9 (SGIRO) y en reconciliación CECOBAN (ORIGEN) | Documentar el catálogo SGIRO y ORIGEN en el glosario de migración; implementar en el target como enumerados tipados con test de cobertura de todos los valores |

---

### N1: Technology Support — N2: Batch Control & Regulatory Extraction

#### N3: T.3.4 Batch Control & Regulatory Extraction — N4: P199 CTASMIGCAP + P610 CALLLIBCTL + P612 + P677

| ID | Severidad | Patrón | N5: Tarea(s) | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------------|----------------------|------------------|
| MR-RPT-01 | 🔴 DEFECTO-PROD | HARDCODE | T-RPT-005 | `INFONAVIT ANT=0` hardcodeado en P120 — la antigüedad siempre se reporta como cero en los registros INFONAVIT del SAR; trabajadores con antigüedad real ven su registro de ahorro corrompido | `[HITL URGENTE]` Calcular ANT desde la fecha de apertura de cuenta antes del siguiente ciclo de generación SAR; validar contra registros históricos de INFONAVIT para identificar registros ya afectados |
| MR-RPT-02 | 🟠 CRÍTICO | EQUIVALENCIA | T-RPT-001 | P199 no migratable as-is: es el puente de integración S500→S151 donde ambos sistemas se reemplazan simultáneamente — toda la lógica de deduplicación (CTLP199), cancelaciones por rango, alta/baja individual y clasificación NATC=9 Banxico debe re-implementarse como integración event-driven entre los dos sistemas modernos | Rediseñar P199 como consumer de eventos S500 que publica al topic S151 del target; preservar la deduplicación, las cancelaciones masivas por rango, y la clasificación NATC=9; validar con Banxico Circular 3/2012 |
| MR-RPT-03 | 🟠 CRÍTICO | PROPIETARIO-MCP | T-RPT-026..031 | THECALENDAR F18 (día hábil bancario) en P677: si el servicio de calendario falla, P677 no libera el lock de inicio de día y ningún programa S151 puede ejecutar ese ciclo — es el gate-keeper equivalente a L030 para el arranque diario de S151 | Reemplazar THECALENDAR F18 por servicio de calendario Banxico (mismo que SCH/STA); implementar failover con calendario en caché persistente para al menos 30 días; definir SLA de disponibilidad ≥ 99.99% |
| MR-RPT-04 | 🟡 ALTO | SILENCIOSO | T-RPT-004 | Filtro hardcodeado `SUC=342/CAJ=36` en P199: cualquier otra sucursal o caja se descarta silenciosamente sin log ni contador de exclusión — en el target, sucursales nuevas o migraciones de punto de captación quedarían excluidas del reporte SAR sin detección | Parametrizar el filtro de sucursal/caja; implementar contador de registros excluidos y alerta si supera cero; auditar historial de exclusiones vs transacciones de S500 |
| MR-RPT-05 | 🟡 ALTO | REGULATORIO | T-RPT-010 | `NATC=9` (sobregiro) Banxico Circular 3/2012: la clasificación del registro R01-TOTALES con esta base regulatoria es obligatoria — si NATC no se mapea correctamente, el reporte de totales por BIN es incorrecto ante Banxico | Implementar la clasificación NATC como enumerado con valor 9 explícito para sobregiro; crear test regulatorio que verifique NATC=9 en todos los movimientos de sobregiro en el output del reporte |
| MR-RPT-06 | 🟡 ALTO | REGULATORIO | T-RPT-017 | P610 F03 señal fin de día CNBV: lista hardcodeada de sistemas con formato 6DIG (84/87/335/336/408/703/711) vs 8DIG (resto) — cualquier sistema nuevo post-separación puede quedar en el formato incorrecto sin error en runtime | Externalizar la tabla de formato por sistema a catálogo configurable; añadir validación de longitud antes de emitir la señal CNBV; crear test de regresión con lista completa de sistemas activos |
| MR-RPT-07 | 🟡 ALTO | HARDCODE | T-RPT-020 | F09 TANDEM ICA para Banxico: `APL-ORI=0236`, `APL-DES=0264`, `COD-SER=20`, `IMP=1.1` hardcodeados — parámetros interbancarios Banxico/CECOBAN que pueden cambiar por circular sin previo aviso | Parametrizar los 4 valores como configuración de entorno; suscribirse al RSS de circulares Banxico para detectar cambios; añadir test de contrato que falle si algún parámetro ICA cambia |
| MR-RPT-08 | 🟡 ALTO | EQUIVALENCIA | T-RPT-011 | Commit por lotes de 20,000 registros con retry 6×10 s en P199: en JDBC/JPA la semántica de commit por lotes DMSII no es directamente equivalente — una granularidad de checkpoint diferente puede producir reprocesamiento incompleto o duplicado ante fallo | Documentar la granularidad de checkpoint en el ADR de equivalencia P199; en el target, implementar commit por lotes configurable con el mismo tamaño como default; crear test de reanudación ante fallo a mitad de lote |
| MR-RPT-09 | 🟡 MEDIO | SILENCIOSO | T-RPT-025 | P612 marca `STATUS="1"` aunque el WFL de lanzamiento falle (sin `ON EXCEPTION`) — el lanzamiento erróneo queda permanentemente marcado como "ejecutado"; no puede relanzarse sin intervención manual | Implementar manejo de excepción en el lanzamiento WFL; si falla, registrar `STATUS="E"` distinguible; alertar al operador en dashboard de estado de jobs |
| MR-RPT-10 | 🟡 MEDIO | PROPIETARIO-MCP | T-RPT-021 | `CANCEL` de SOPORTECOMS y CTLVER al finalizar P610 — liberación de memoria de tarea MCP propietaria; en Java/cloud la gestión de memoria es automática (GC) pero el patrón de retención de handles puede diferir | Verificar que los recursos equivalentes en el target (connection pools, buffers) se liberan explícitamente al finalizar P610; implementar try-finally para garantizar liberación ante cualquier path de salida |

---

### N1: Migration Governance — Riesgos Cross-Cutting (Coexistencia · Separación · Calendario · Rollback · Regulatorio)

> **Fuente:** Auditoría de gobernanza 2026-07-21 — coexistence-model.md · rollback-plan.md · migration-calendar-constraints.md · cnbv-regulatory-impact-assessment.md
> Riesgos transversales sin capacidad BIAN individual asignable. ID prefix: MR-COX · MR-SEP · MR-CAL · MR-ROL · MR-REG · MR-EXT · MR-NOM.

#### Coexistence Model (MR-COX)

| ID | Severidad | Patrón | Fuente | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------|----------------------|------------------|
| MR-COX-01 | 🟠 CRÍTICO | ATOMICIDAD + SILENCIOSO | coexistence-model.md §3 | SCIG/PAQUETECONTABLE mutex no enforced en tiempo de ejecución — si ambas rutas GL (flag `$SET S151REGISTRA` de S500 y PAQUETECONTABLE de S151 modernizado) están activas simultáneamente durante coexistencia, el mismo movimiento genera doble asiento contable en GL sin alarma. La ventana de riesgo es cualquier instante en que el feature flag de migración esté en estado intermedio entre corridas de compilación. | Implementar mutex hard a nivel de configuración de despliegue: el flag `S151REGISTRA` debe compilarse OFF en todos los programas S500 antes de activar el PAQUETECONTABLE route del target GL. Definir protocolo de verificación pre-cutover con checklist de programas y flags compilados activos. |
| MR-COX-02 | 🟠 CRÍTICO | EQUIVALENCIA + SILENCIOSO | coexistence-model.md §2 | BD10/BD11 como SOR durante coexistencia — cualquier divergencia entre el registro de movimientos de S500 y el GL de S151 (BD11) mayor a 30 minutos sin detección activa es una brecha contable silenciosa en el período de parallel-run. No existe actualmente un comparator automático definido entre S500 y BD11. | Implementar comparator automático S500↔BD11 con alerting a <30 min de latencia; dashboard de divergencia en tiempo real durante todo el período de coexistencia; reconciliación manual nocturna como fallback de auditoría. |
| MR-COX-03 | 🟠 CRÍTICO | INTERFAZ | coexistence-model.md §2 · kb-capa5-fronteras.md §BC-04 | BC-04 ACL dual-mode traffic split sin enforcement — durante Wave 0-A, los 15 programas S500 deben usar ÚNICAMENTE el nuevo GL-Posting-Service; si algún programa sigue apuntando a la librería ALGOL L002Rx (REGISTRAS500) y también al servicio moderno, los asientos se duplican. No hay mecanismo de verificación automática del routing activo post-activación. | Instrumentar cada llamada a CARGAMOV1/REGISTRAS500 con un flag de destino (ALGOL vs REST); generar alerta si se detectan llamadas al destino legacy post-activación Wave 0-A; incluir en el go/no-go checklist de Wave 0-A la verificación de tráfico cero hacia REGISTRAS500 ALGOL. |
| MR-COX-04 | 🟡 ALTO | EQUIVALENCIA | rollback-plan.md §7 | Gate de re-entrada post-rollback sin criterios formales — el rollback-plan define cómo revertir, pero no define cuáles métricas de estabilidad deben cumplirse para autorizar un segundo intento de activación del target. Sin gate formal, el equipo puede intentar re-activación prematura generando un segundo rollback en la misma ventana de procesamiento. | Documentar en rollback-plan.md §7 los criterios de gate de re-entrada: mínimo 72 horas de estabilidad en legacy post-rollback, análisis de causa raíz firmado, y aprobación del Architecture Review Board antes de re-activar el target. |

#### Citi/Banamex Separation (MR-SEP)

| ID | Severidad | Patrón | Fuente | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------|----------------------|------------------|
| MR-SEP-01 | 🟠 CRÍTICO | HARDCODE + REGULATORIO | migration-calendar-constraints.md §4 | SETID=BNMEX en programas más allá de P131 — se conocen 14 ocurrencias en P131 (MR-CFR-01), pero el identificador de entidad financiera puede estar hardcoded en otros programas del ecosistema S500/S151 no auditados. Post-separación Citi/Banamex, cualquier programa que envíe BNMEX a PeopleSoft GL o a reguladores con el SETID incorrecto genera reportes inválidos ante CNBV. | Ejecutar grep exhaustivo de "BNMEX" en todos los fuentes S500+S151; identificar cada ocurrencia, clasificar como activa/comentada, y parametrizar vía variable de entorno `SETID_UNINEG`; incluir en el test de regresión pre-cutover verificación del SETID en todos los archivos de salida a reguladores. |
| MR-SEP-02 | 🟡 ALTO | INTERFAZ + HARDCODE | migration-calendar-constraints.md §4 · MR-INT-01 | BRANCH=484 (P150) vs BRCH-NBR=485 (P151) — P150 y P151 son programas del mismo autor con campos análogos pero nombres distintos para el identificador de sucursal Citi. Un transpilador que trate BRANCH y BRCH-NBR como alias genera registros ALR/OCM con identificadores de sucursal incorrectos en el sistema IBM-CITI post-separación. Ya registrado parcialmente en MR-INT-01; el riesgo de nomenclatura inter-programa requiere cobertura explícita. | Documentar como ADR de equivalencia de interfaz; crear test de contrato IBM-CITI que verifique BRANCH=484 en P150 y BRCH-NBR=485 en P151 independientemente; prohibir tratamiento como alias en el código target. |

#### Calendar Dependencies (MR-CAL)

| ID | Severidad | Patrón | Fuente | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------|----------------------|------------------|
| MR-CAL-01 | 🟠 CRÍTICO | PROPIETARIO-MCP | migration-calendar-constraints.md §3 · MR-SCH-03, MR-HLD-04, MR-STA-04, MR-RPT-03 | THECALENDAR sin equivalente cloud aprobado — la librería propietaria Unisys MCP de calendario bancario es usada por al menos 5 capacidades (P103-SCH, P138-HLD, P158-STA, P677-RPT, P075-SCH). No existe aún un servicio de calendario Banxico aprobado y desplegado como reemplazo transversal. Si el servicio de calendario no está listo antes de Wave 0-B, la migración de cualquier capacidad que use THECALENDAR está bloqueada. | Designar el Servicio de Calendario Banxico (festivos CNBV + días hábiles) como Milestone 0-C del plan de migración; definir SLA ≥ 99.99% y failover con caché de 30 días; integrar en Wave 0-B como prerequisito bloqueante antes de Wave 1. Riesgo transversal que agrega a MR-SCH-03, MR-HLD-04, MR-STA-04 y MR-RPT-03. |
| MR-CAL-02 | 🟡 ALTO | PROPIETARIO-MCP + HARDCODE | cap-orc · I11-REPLICA | WAIT 1200s (COPIA-5) en I11-REPLICA — la replicación intra-day de S151 usa un busy-wait de 20 minutos sin polling de estado. Este patrón bloquea threads en arquitecturas cloud durante 20 minutos, es incompatible con el modelo event-driven del target y aumenta la latencia de propagación de movimientos durante la coexistencia. | Reemplazar por suscriptor event-driven (Kafka consumer / SQS listener) con acknowledgment explícito por movimiento; eliminar completamente el WAIT hardcodeado; el latency target de replicación debe ser menor a 30 segundos en el target. |

#### Rollback Coverage (MR-ROL)

| ID | Severidad | Patrón | Fuente | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------|----------------------|------------------|
| MR-ROL-01 | 🟠 CRÍTICO | REGULATORIO | rollback-plan.md §4 · coexistence-model.md §7 | Punto de no retorno Wave 3 a las 16:00 — el RTO de 2 horas para el GL (Wave 3) más la ventana de decisión de 60 minutos implica que cualquier rollback iniciado después de las 16:00 no puede completarse antes del cierre contable de las 19:00. Un fallo detectado post-16:00 obliga a operar sin cierre GL completo ese día, generando un gap regulatorio ante CNBV. | Definir explícitamente el protocolo post-16:00: (a) notificación inmediata a CNBV; (b) generación manual de asientos de ajuste en S151 legacy; (c) acuerdo previo con CNBV sobre la ventana de emergencia aceptable. Coordinar aprobación del protocolo con área Regulatoria antes del cutover Wave 3. |
| MR-ROL-02 | 🟡 ALTO | EQUIVALENCIA | rollback-plan.md §7 | Wave 4 WFL REPLATFORM sin cobertura de rollback — el rollback-plan.md documenta explícitamente que la sección Wave 4 está pendiente. El WFL REPLATFORM tiene complejidad distinta a los waves transaccionales (orquestación de jobs vs. servicios online) y sus mecanismos de rollback involucran estado de jobs en vuelo que no tiene equivalente en los Waves 0-3. | Completar la sección Wave 4 del rollback-plan antes de iniciar planificación de Wave 4; documentar: trigger de rollback, ventana de decisión, procedimiento de re-activación del WFL REPLATFORM legacy, y verificación de jobs en curso al momento del rollback. |

#### Regulatory Governance (MR-REG)

| ID | Severidad | Patrón | Fuente | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------|----------------------|------------------|
| MR-REG-01 | 🟠 CRÍTICO | REGULATORIO | cnbv-regulatory-impact-assessment.md §7 · migration-calendar-constraints.md §5 | CNBV Circular 29/2010 — 30 días hábiles de notificación sin mecanismo de tracking activo. No existe actualmente un sistema que dispare automáticamente el reloj de notificación al aprobarse el gate de diseño de cada wave, ni que alerte cuando se acerca el vencimiento. Una activación de wave sin la notificación completa es incumplimiento regulatorio directo. | Incorporar el tracking de notificaciones CNBV en el sistema de gestión del proyecto: al cerrar el gate de diseño de cada wave en CAB, crear automáticamente un ticket de notificación con vencimiento a 30 días hábiles; bloquear el gate de RELEASE hasta recibir confirmación de acuse de recibo CNBV. |
| MR-REG-02 | 🟡 ALTO | REGULATORIO | cnbv-regulatory-impact-assessment.md §3 | Parallel-run mínimo de 6 meses (Wave 3) vs. timeline del proyecto — el estándar más conservador adoptado (Serie B: 6 meses de parallel-run con GL legacy) puede ser incompatible con el delivery schedule si las waves anteriores se extienden. El riesgo es comprimir el parallel-run de Wave 3 por presión de fecha, incumpliendo el estándar regulatorio mínimo declarado. | Establecer la fecha de inicio del parallel-run Wave 3 como milestone no-compresible en el plan de proyecto; cualquier retraso en waves previas debe absorberse antes del inicio de Wave 3, no acortando el parallel-run. Documentar como restricción regulatoria hard en migration-calendar-constraints.md. |
| MR-REG-03 | 🟡 ALTO | REGULATORIO + INTERFAZ | cnbv-regulatory-impact-assessment.md §5 · migration-calendar-constraints.md | Certificación CECOBAN no planificada — reemplazar BC-04 ACL (S151REGISTRA/REGISTRAS500) como interfaz de transferencia electrónica puede requerir re-certificación como participante CECOBAN (Centro de Compensación Bancaria). Este trámite no está incluido en migration-calendar-constraints.md ni en ningún wave del plan. | Consultar con el área de Operaciones Bancarias si el cambio de BC-04 ACL requiere trámite CECOBAN; si sí, incluir la certificación como prerequisito bloqueante de Wave 0-A go-live e incorporar en migration-calendar-constraints.md §5. |

#### External Dependencies (MR-EXT)

| ID | Severidad | Patrón | Fuente | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------|----------------------|------------------|
| MR-EXT-01 | 🟡 ALTO | INTERFAZ + SILENCIOSO | cap-ods · L030 S151LIB030 · coexistence-model.md §2 | S016 Customer Profile como dependencia no-controlada de Wave 0-B — L030 (librería maestra S151, 19,253 LOC) llama a S016 para enrichment de cliente; S016 es un sistema externo a S151 que puede no seguir el mismo timeline de modernización. Si S016 no está disponible durante la migración de L030 a 6 microservicios de plataforma, todos los programas S151 que dependan de enrichment de cliente fallan silenciosamente. | Inventariar todas las llamadas a S016 desde L030 y los 6 microservicios de plataforma; definir circuit breaker con modo degradado explícito (respuesta parcial sin enrichment) para las llamadas a S016; coordinar disponibilidad y SLA de S016 con su equipo propietario como prerequisito de Wave 0-B. |

#### Nomenclature & Naming (MR-NOM)

| ID | Severidad | Patrón | Fuente | Descripción del riesgo | Acción requerida |
|----|-----------|--------|--------|----------------------|------------------|
| MR-NOM-01 | 🟡 MEDIO | INTERFAZ | kb-capa5-fronteras.md · coexistence-model.md · rules-s500-s151registra-p103fraude.md | Nomenclatura inconsistente de BC-04 ACL en la KB — el mismo componente se refiere como: "REGISTRAS500/CARGAMOV1" (fuente ALGOL), "GL-Posting-Service" (coexistence-model), "BC-04 ACL" (kb-capa5-fronteras), "S151REGISTRA" (reglas compilación). Esta ambigüedad puede causar que el equipo de transpilación entienda erróneamente que son componentes distintos, resultando en doble implementación o en que algún destino quede sin implementar. | Establecer el nombre canónico en el glosario de migración: **"BC-04 GL-Posting-Service"** (nombre target) con aliases documentados; actualizar coexistence-model.md y las caps que lo referencian para usar el nombre canónico de forma consistente. |
| MR-GOV-16 | 🟡 ALTO | DOCUMENTACIÓN | WFL S500 — extracción 2026-07-21 · cap files corregidos | Inversión de nombres en WFLs extraídos de S500: `S500_WFL_LOTE.txt` contiene `BEGIN JOB S500/WFL/LINEA/24MTP005` (WFL LINEA) y `S500_WFL_REORG_GARBAGE_S500BD04TARJETAS.txt` contiene `BEGIN JOB S500/WFL/LOTE/26MTP002` (WFL LOTE). Los nombres de archivo y el contenido real del `BEGIN JOB` están invertidos. Cualquier análisis basado en el nombre del archivo extraído —en lugar del `BEGIN JOB` interno— atribuye incorrectamente las reglas, tareas y hallazgos a la capacidad equivocada. Errores de atribución detectados y corregidos en múltiples cap files el 2026-07-21. | En todos los análisis futuros de WFL: usar SIEMPRE el nombre del `BEGIN JOB` como identificador canónico del WFL, nunca el nombre del archivo extraído. Documentar la inversión en la guía de extracción de WFLs de S500; añadir validación automática que compare el nombre del archivo con el nombre del `BEGIN JOB` y alerte ante discrepancias; verificar si existen otras inversiones de naming en WFLs no auditados. |

---

## Vistas cruzadas

### Riesgos 🔴 DEFECTO-PROD — acción inmediata antes de cualquier ambiente de prueba

| ID | Capacidad | N4: Proceso | N5: Tarea | Descripción |
|----|-----------|-------------|-----------|-------------|
| MR-SEC-01 | T.3.5 Security | P655 SCRAMBLING | T-SEC-001 | Fail-open ante hostname no reconocido — enmascaramiento sin control de ambiente |
| MR-SEC-02 | T.3.5 Security | P655 SCRAMBLING | T-SEC-002 | Bloqueo producción sin STOP RUN — enmascaramiento de datos reales continúa |
| MR-GL-09 | 7.1.1 Finance GL | P109 GL POSTING ENGINE | CS-GL-06 | Abort de date-mismatch LOG151 comentado — asientos con fecha errónea sin señal al operador |
| MR-ORC-01 | Operational Reconciliation | P680 GENERACION CIERRE | ORC-P680-H01 | SECERRHI copiado en SECINFHI (ln 537) — contador informativo sobredeclarado; único punto de restauración del cierre lote S151 |
| MR-RPT-01 | T.3.4 Batch Control & Regulatory Extraction | P120 EXTRACTOR SAR | RPT-P120-H01 | INFONAVIT ANT siempre = 0 desde 1991 — reporte SAR entregado a Banxico/INFONAVIT con saldo anterior INFONAVIT incorrecto durante ~34 años |

### Riesgos regulatorios (CNBV/Banxico/SAT) consolidados

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
| MR-RPT-01 | T.3.4 Batch Control & Regulatory Extraction | Banxico/INFONAVIT | RPT-P120-H01 | INFONAVIT ANT=0 en reporte SAR — saldo anterior INFONAVIT reportado como 0 durante ~34 años |
| MR-HLD-06 | 4.1.2 Holdings | CNBV/CONDUSEF | T-HLD-008 | Dormancia 180 días hardcoded fallback (Ley IC Art. 61) — si catálogo S080 no responde, valor hardcodeado queda activo sin advertencia; si CNBV modifica el plazo, el código queda desactualizado |
| MR-HLD-07 | 4.1.2 Holdings | CNBV | T-HLD-017 | CONLI R10: 5 condiciones AND obligatorias (FUNCION=1/STATUS=1/PRODUCTO=1/INSTRUMENTO=30/ORIGEN=1 OR 3); layout fijo 160+12+8+4 chars — cualquier variación = incumplimiento automático |
| MR-ADJ-07 | 6.7.1+6.7.2 Reconciliation GL | CNBV | T-ADJ-P360-010 | B72POSCONTA: SDOACT=SDOANT+CARGOS-ABONOS no validada — insumo directo de R04C/R27C; descuadre contable no detectado antes de reportar |
| MR-ODS-06 | 9.1.1 Operational Data Stores | SAT/Anexo 20 | T-ODS-007 | RFC-BENEF ALPHA(18) vs RFC-ORD ALPHA(13) — asumir longitud 13 para ambas trunca RFC-BENEF; error de identificación de beneficiario reportable al SAT |
| MR-CFR-03 | T.4.1 Regulatory Reporting (CFR) | CNBV | T-CFR-015..027 | 9 catálogos hard-linked al binario (COPC/CCFI/PNPA/CXEV/COCO/DREG-FOBA/ARCH-CAT/SIUN/ARCH-INTE) — actualización regulatoria requiere recompilación y despliegue coordinado; sin versioning de reglas |
| MR-CFR-04 | T.4.1 Regulatory Reporting (CFR) | CNBV | T-CFR-023 | DREG-FOBA: doble registro FOBAPROA es requerimiento vigente — omisión produce observación CNBV en revisión de cartera |
| MR-RPT-05 | T.3.4 Batch Control & Regulatory Extraction | Banxico Circular 3/2012 | T-RPT-010 | NATC=9 (sobregiro) en R01-TOTALES — si NATC no se mapea correctamente, el reporte de totales por BIN es incorrecto ante Banxico |
| MR-RPT-06 | T.3.4 Batch Control & Regulatory Extraction | CNBV | T-RPT-017 | P610 F03 señal fin de día: lista hardcodeada 6DIG vs 8DIG — sistema nuevo post-separación puede quedar en formato incorrecto sin error en runtime |
| MR-INT-04 | 6.1.5 Interest & Fees | CONDUSEF Art. 96 | T-INT-020 | Cancelación automática por saldo promedio mínimo — si la lógica de umbral no se replica exactamente, cuentas elegibles permanecen activas generando infracción CONDUSEF |
| MR-INT-05 | 6.1.5 Interest & Fees | Banxico Art. 61 CUB | T-INT-022 | Traspaso automático a cuenta de beneficencia por inactividad — la condición temporal y el monto exacto deben replicarse; error produce responsabilidad regulatoria ante Banxico |

### Riesgos de patrón SILENCIOSO — impacto en reconciliación y auditoría

| ID | Capacidad | N5: Tarea | Consecuencia del silencio |
|----|-----------|-----------|--------------------------|
| MR-GL-02 | 7.1.1 Finance GL | T-GL-008 | ESQUEMA NO EXISTE → movimiento no contabilizado, sin alerta |
| MR-GL-03 | 7.1.1 Finance GL | T-GL-010 | NAT-MOV ≠ 1/2 → asiento descartado sin registro |
| MR-GL-09 | 7.1.1 Finance GL | CS-GL-06 | Date-mismatch LOG151 → asientos GL con fecha incorrecta sin abort ni alerta |
| MR-SEC-01 | T.3.5 Security | T-SEC-001 | Hostname no reconocido → enmascaramiento sin validación |
| MR-REC-08 | 6.7.1 Reconciliation | T-REC-006 | STATUS=0 nunca procesado sin traza |
| MR-REC-09 | 6.7.1 Reconciliation | T-REC-008 | Brecha de moneda sin diagnóstico de causa |
| MR-CMP-04 | 6.5.2 Compliance | T-CMP-003 | Abort sin trailer → archivo CNBV incompleto |
| MR-CMP-08 | 6.5.2 Compliance | T-CMP-004 | STATUS-MOVTO=1 descartado sin counter ni log |
| MR-REC-11 | 6.7.1 Fin. Reconciliation | RN-S151-392 | Rama ELSE P178 inexistente → duplicados silenciosos en conciliación S84/S87/S408 |
| MR-REC-12 | 6.7.1 Fin. Reconciliation | RN-S151-395 | WKS-TAB-IMP PIC subestimada 13→15 dígitos → truncamiento silencioso de saldos GL grandes |
| MR-PAY-01 | 6.1.3 Payments | RN-S151-311 | W77-TIPO-CAMBIO PIC 6→12 dígitos enteros → desbordamiento FX silencioso en conversión |
| MR-DEP-01 | 5.1.1 Deposits | T-DEP-001 | S408=99 ambiguo → saturación de contador vs error DMSII indistinguibles; bloqueo de disposición sin diagnóstico |
| MR-DEP-02 | 5.1.1 Deposits | T-DEP-009 | Skip cross-CSI con CSI erróneo → contrato local ignorado sin registro ni contador en trailer |
| MR-HLD-01 | 4.1.2 Holdings | T-HLD-012 | TC=10 fallback → todas las transacciones USD del día valuadas a tasa 1:1; error contable masivo sin alerta |
| MR-ADJ-03 | 6.7.1+6.7.2 Reconciliation GL | T-ADJ-P330-013 | Archivos planos parciales sin manifesto de completitud → P360 integra set incompleto; GL destino inconsistente sin notificación |
| MR-ADJ-07 | 6.7.1+6.7.2 Reconciliation GL | T-ADJ-P360-010 | B72POSCONTA cuadratura SDOACT≠SDOANT+CARGOS-ABONOS no validada → descuadre en insumo R04C/R27C CNBV pasa sin detección |
| MR-ODS-01 | 9.1.1 Operational Data Stores | T-ODS-004 | AUTAPL vs AUTS151 — movimientos de 6 sucursales NOT FOUND silencioso; trazabilidad CNBV perdida |
| MR-SCH-01 | 8.1.1 Business Scheduling | T-SCH-002 | DAME_TIT falla sin STATUS=-1 → cierre del día bancario omitido; loop batch continúa sin señal al orquestador |
| MR-SCH-05 | 8.1.1 Business Scheduling | T-SCH-012 | P100 retorna fecha válida con parámetros inválidos → fecha de proceso silenciosamente incorrecta propagada a todos los programas del día |
| MR-SCH-07 | 8.1.1 Business Scheduling | T-SCH-021 | Re-ejecución PROYECTA avanza FECPRO dos veces → fecha de proceso adelantada un día de más sin detección |
| MR-CFR-08 | T.4.1 CFR Regulatory Reporting | T-CFR-002 | FUNCION desconocida → movimiento descartado sin traza ni contador de exclusión |
| MR-ORC-08 | 6.7.2 Operational Reconciliation | T-ORC-012 | Cola de mensajes contingencia sin alerta de reproceso → brecha contable permanente si operador no interviene antes del cierre |
| MR-ORC-09 | 6.7.2 Operational Reconciliation | T-ORC-001 | Versión incompatible de librería S151 continúa sin señal → errores downstream atribuidos a datos, no a incompatibilidad de versión |
| MR-RPT-04 | T.3.4 Batch Control & Regulatory Extraction | T-RPT-004 | SUC=342/CAJ=36 → otras sucursales descartadas sin log; sucursales nuevas post-migración excluidas del reporte SAR |
| MR-RPT-09 | T.3.4 Batch Control & Regulatory Extraction | T-RPT-025 | P612 marca STATUS="1" aunque el WFL falle → lanzamiento erróneo queda marcado como ejecutado permanentemente |
| MR-INT-02 | 6.1.5 Interest & Fees | T-INT-005 | WKS-SIN-LBS151 bypass → 3 asientos GL (CVE 3000/4009/809) omitidos; rendimientos e ISR sin contabilizar |
| MR-INT-06 | 6.1.5 Interest & Fees | T-INT-014..016 | Invariante CVE 809 = CVE 3000 + CVE 4009 no validada → descuadre en Serie R-04 CNBV sin alerta |

### Riesgos de patrón PROPIETARIO-MCP — requieren reemplazo arquitectónico

| ID | Capacidad | N5: Tarea | Instrucción Unisys | Reemplazo target |
|----|-----------|-----------|-------------------|-----------------|
| MR-TAR-03 | ATM/PoS | T-TAR-001+002 | `CHECAME / DAME_TIT IN CTLVERS` | ConfigMap / service registry |
| MR-TAR-04 | ATM/PoS | T-TAR-014 | `USE AS INTERRUPT PROCEDURE` | Signal handler / graceful shutdown |
| MR-TAR-05 | ATM/PoS | T-TAR-004 | `CALL SYSTEM DMTERMINATE` | Exit-code no-cero + cierre limpio |
| MR-SEC-09 | Security | T-SEC-001 | `ATTRIBUTE HOSTNAME OF MYSELF` | Variable de entorno `HOSTNAME` |
| MR-SEC-04 | Security | T-SEC-005 | Path archivo Unisys `S500/FILE/SCRBLING/` | DB o blob storage |
| MR-CMP-09 | Compliance | T-CMP-001..003 | `DMTERMINATE` + `CHANGE ATTRIBUTE STATUS` | Exception + exit-code orquestador |
| MR-HLD-02 | 4.1.2 Holdings | T-HLD-001 | `LIB-L006` — protocolo propietario para BD02ADSALDO | Repositorio con contrato explícito (LEER/INICIALIZAR/ELIMINAR) |
| MR-HLD-08 | 4.1.2 Holdings | T-HLD-027 | `THECALENDAR FUN=13` — proyección fechas hábiles P138 | Servicio de calendario con festivos Banxico/CNBV configurables |
| MR-ADJ-04 | 6.7.1+6.7.2 Reconciliation GL | T-ADJ-P330-003 | `ATTRIBUTE VALUE OF MYSELF` — override fecha de proceso | Parámetro `--fecha-proceso` o env var `S151_FECHA_PROCESO` |
| MR-ADJ-05 | 6.7.1+6.7.2 Reconciliation GL | T-ADJ-P360-012 | `CALL SYSTEM DMTERMINATE` — rollback atómico DMSII | Transacción JTA única para las 6 integraciones B20..B80 |
| MR-ODS-04 | 9.1.1 Operational Data Stores | T-ODS-028 | `CANCEL` + `CHANGE ATTRIBUTE` L030 — carga dinámica Unisys | 6 microservicios de plataforma (Milestone 0 migración S151) |
| MR-SCH-02 | 8.1.1 Business Scheduling | T-SCH-002+004 | `CHANGE ATTRIBUTE TITLE` (resolución dinámica L080/INIBATCH) | Inyección de dependencia configurable (spring bean / service locator) |
| MR-SCH-03 | 8.1.1 Business Scheduling | T-SCH-020 | `THECALENDAR IN LOCSUP` (FUNCION=13) — calendario bancario P103 | Servicio de calendario Banxico con historial 3+ años |
| MR-SCH-04 | 8.1.1 Business Scheduling | T-SCH-004+008 | `CALL SYSTEM DMTERMINATE` (P075/P100 abort) | Exit-code no-cero + cierre explícito de conexiones |
| MR-STA-01 | 6.1.4 Statements | T-STA-007 | WFL auto-submisión dinámica de job (P158→P170 sort) | Orquestador de jobs (Step Functions / Airflow) o servicio de sorting directo |
| MR-STA-04 | 6.1.4 Statements | T-STA-005 | `THECALENDAR` via BD99/CONSISDIA — fecha del estado de cuenta | Servicio de fecha de proceso canónico + failover con caché persistente |
| MR-TEL-03 | 2.1.1 Teller | T-TEL-002 | `HI-4/HI-6` daemon loop (P010 gateway persistente) | Proceso long-running con probes liveness/readiness + graceful shutdown |
| MR-CFR-07 | T.4.1 CFR Regulatory Reporting | T-CFR-011 | `ESENDAUTO OUTBOARD` + `INTELARSND` (distribución propietaria MCP) | SNS/EventBridge con deduplicación por tipo de alerta |
| MR-ORC-04 | 6.7.2 Operational Reconciliation | T-ORC-016..019 | `DCKEYIN` ALGOL (P021) — señales HI a pasos S500 de consola MCP | DAG (Airflow / Step Functions) con mismas dependencias y señales |
| MR-ORC-05 | 6.7.2 Operational Reconciliation | T-ORC-020 | `CHANGE ATTRIBUTE TITLE/BYFUNCTION` (P602 → hub S151L001CTL) | Service locator / spring profiles con tabla de routing configurable |
| MR-ORC-06 | 6.7.2 Operational Reconciliation | T-ORC-023 | `CLOSE WITH SAVE/RELEASE/PURGE` (P630 — semántica DMSII) | Transacción + delete explícito según el variant; test de idempotencia |
| MR-RPT-03 | T.3.4 Batch Control & Regulatory Extraction | T-RPT-026..031 | `THECALENDAR F18` (P677 gate-keeper diario S151) | Servicio de calendario Banxico + caché 30 días; SLA ≥ 99.99% |
| MR-RPT-10 | T.3.4 Batch Control & Regulatory Extraction | T-RPT-021 | `CANCEL` SOPORTECOMS/CTLVER (liberación memoria tarea MCP) | try-finally para liberar connection pools/buffers; GC automático en Java |

---

## Notas de mantenimiento

- Este registro se actualiza al generar cada nuevo `cap-{slug}.md`.
- Los IDs `MR-{CAP}-{NN}` son estables — no renumerar al agregar nuevas capacidades.
- Las vistas cruzadas se recalculan al agregar cada bloque de capacidad.
- **Cobertura completa alcanzada:** 22/22 capacidades del mapa GemCog están documentadas, incluyendo T.6.1 CPE (Captación Productiva Especial) agregada en sesión 2026-07-21. Adicionalmente, 16 riesgos cross-cutting de gobernanza de migración (MR-COX · MR-SEP · MR-CAL · MR-ROL · MR-REG · MR-EXT · MR-NOM · MR-GOV) y 1 defecto regulatorio adicional (MR-CFR-11) documentados en auditoría 2026-07-21.

---

*migration-risk-register.md · v3.4 · 2026-07-21 — CPE(7) + MR-GOV-16 = +8 riesgos · 170 riesgos totales · 22/22 capacidades BIAN + riesgos de gobernanza de migración*
*Total: 170 riesgos · 🔴 DEFECTO-PROD: 7 · 🟠 CRÍTICO: 57 · 🟡 ALTO: 65 · 🟡 MEDIO: 40 · 🟢 BAJO: 1*
*Cobertura: TAR · GL · REC · SEC · CMP · DEP · HLD · ADJ · ODS · PAY · MQ · SCH · STA · TEL · INT · CFR · ORC · RPT · CPE*
*Fuentes: cap-{tar,gl,rec,sec,cmp,dep,hld,adj,ods,pay,mq,cfr,orc,rpt,int,cpe}.md · rules-catalog/*
*Taxonomía: N1 Dominio → N2 SubDominio → N3 Capacidad → N4 Proceso → N5 Flujo (Tarea)*