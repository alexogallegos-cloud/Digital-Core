# Reglas DASDL S151 — DICCIONARIO DE DATOS / 6 BASES DE DATOS (con vocabulario)
> **Bases:** BD10 (movimientos diarios) · BD11 (posición GL) · BD12 (movimientos por contrato) · BD13 (protección cobro) · BD99 (control) · BD02 (saldos cliente)
> **ALERTA:** Sucursales 859/100/342/110/511/870 usan KEY=AUTAPL no AUTS151 — queries por AUTS151 no las encuentran [CRÍTICO]
> **ALERTA:** Tripartita BD12 (OK/INFO/ERROR) no puede colapsarse en una sola tabla sin perder volúmenes y SLOs distintos
> **Enriquecido con:** vocabulario vocab-s151.md · ente regulador · nivel de confianza · schema v2 (Fórmula · Excepciones · Capacidad bancaria · Frecuencia · Sistemas downstream)
> **Rango:** RN-S151-491 a RN-S151-525 (35 reglas)
> **Fuentes DASDL:** DASDL_S151BD10MOVDIA151.txt · DASDL_S151BD11SDOS151.txt · DASDL_S151BD12MC001S151.txt · DASDL_S151BD13BIFIN.txt · DASDL_S151BD99CONTROL.txt · DASDL_S151BD02ADSALDO.txt
> **Actualizado:** 2026-07-16
**Indexado:** ✅ 2026-07-17 — correlacionado vocab↔reglas↔capacidad (traceability-matrix.md)

---

## BD10 — Movimientos Diarios (S151B01..B41MOVTOS)

---

### RN-S151-491

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-491 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
dataset_activo = LEER BD99.B01SISDIA.NOMBDSEM
CASE día_semana OF
  1 (lunes)    → acceder S151B01MOVTOS
  2 (martes)   → acceder S151B11MOVTOS
  3 (miércoles)→ acceder S151B21MOVTOS
  4 (jueves)   → acceder S151B31MOVTOS
  5 (viernes)  → acceder S151B41MOVTOS
  sábado       → acceder según NOMBDSEM (reutiliza uno de los 5)
```

**Excepciones documentadas:**
- NOMBDSEM vacío o inválido → falla al seleccionar conjunto activo — sin validación automática en DASDL
- Sábado no tiene conjunto propio: reutiliza el indicado por NOMBDSEM (parametrización externa)
- No existe herencia ni traspaso de datos entre conjuntos diarios — cada uno se trunca al iniciar el nuevo ciclo

**Confianza:** ALTA — estructura explícita en DASDL con 5 bloques idénticos con prefijos B01/B11/B21/B31/B41.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-492

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-492 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
SI COUNT(registros en BxMOVTOS) >= 52,500,000
  → ERROR overflow DATA SET
  → ACCIÓN requerida: reorganización fuera de línea antes del siguiente ciclo
SI COUNT < 52,500,000
  → operación normal; insertar nuevo registro con AUTS151
```

**Excepciones documentadas:**
- Overflow no es manejable en tiempo real — requiere reorganización previa (proceso batch fuera de línea)
- No hay expansión dinámica de POPULATION en DMSII; el techo es fijo en el DASDL
- Picos estacionales (fin de mes, quincena) pueden acercarse al límite — monitorear con alerta a 85% de capacidad

**Confianza:** ALTA — valor numérico explícito en código fuente.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-493

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-493 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
FIND ÚNICO B01SXAUTS151
  WHERE AUTS151 = :param_auts151
  → retorna registro de movimiento O NOT FOUND
SI NOT FOUND Y SUCINI IN (859,100,342,110,511,870)
  → redirigir a B01BXCAJ859 con KEY AUTAPL
```

**Excepciones documentadas:**
- AUTAPL ≠ AUTS151: sucursales especiales (859/100/342/110/511/870) requieren B01BXCAJ859, no este índice
- NOT FOUND legítimo si PROCESO ≥ 15 y se busca en subsets activos (registro ya archivado)
- AUTS151 NUMBER(08) — confundir con AUT-PC(12) produce error de tipo silencioso en migración

**Confianza:** ALTA — definición explícita en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-494

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-494 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
SCAN subset BxBXMOVCAJ / BxBXMOVCTO
  WHERE PROCESO < 15   → movimientos procesables (estados 0-14)
SI PROCESO >= 15
  → movimiento en estado terminal o archivado
  → requiere acceso directo B01SXAUTS151 (no visible en subsets)
```

**Excepciones documentadas:**
- Umbral 15 hardcodeado en DASDL — no configurable en runtime; cambiar requiere redefinición + reorganización de BD
- PROCESO = 14 es el último estado procesable; PROCESO = 15 es el primer estado terminal
- Movimiento no visible en subsets ≠ movimiento eliminado — puede estar archivado con PROCESO ≥ 15 y ser auditable

**Confianza:** ALTA — valores explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-495

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-495 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
SCAN B01BXMOVCAJ
  WHERE PROCESO < 15 AND SUCINI > 0
  KEY (SUCINI, CAJINI, AUTS151)
SI SUCINI = 0 (electrónico/batch)
  → NO aparece en este subset
  → consultar B01BXMOVCTO (sin filtro SUCINI)
```

**Excepciones documentadas:**
- SUCINI = 0 excluido del subset — movimientos electrónicos deben consultarse por B01BXMOVCTO
- BUFFERS 2500 + 100/usuario: agotamiento de buffers en alta concurrencia degrada rendimiento de todos los cajeros simultáneamente
- Sucursales especiales (859/100/342) con SUCINI > 0 — verificar si usan AUTAPL en lugar de AUTS151 como tercera clave

**Confianza:** ALTA — restricción explícita en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-496

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-496 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
SI SUCINI IN (859, 100, 342, 110, 511, 870)
  → acceder BxxBXCAJ859 con KEY (SUCINI, CAJINI, AUTAPL)
SI NO
  → acceder B01BXMOVCAJ con KEY (SUCINI, CAJINI, AUTS151)
% Bifurcación aplica para los 5 conjuntos diarios:
% B01/B11/B21/B31/B41BXCAJ859
```

**Excepciones documentadas:**
- AUTAPL y AUTS151 tienen la misma longitud (8 dígitos) pero espacios de numeración distintos — confusión silenciosa posible
- La lista de 6 sucursales está hardcodeada en DASDL — agregar nueva sucursal especial requiere redefinición + reorganización
- En migración relacional: sin bifurcación explícita, las 6 sucursales quedan sin clave de recuperación correcta — pérdida de trazabilidad CNBV

**Confianza:** ALTA — lista de sucursales y campo de clave explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-497

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-497 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
SI operación es SPEI
  NIO    = ALPHA(16) asignado por Banxico (alfanumérico, no numérico puro)
  CECOBAN = NUMBER(08) referencia de cámara de compensación
SI operación NO es SPEI
  NIO puede quedar en blanco (espacios) — no es error de datos
% En migración: mapear NIO a VARCHAR(16), NO a BIGINT
```

**Excepciones documentadas:**
- NIO alfanumérico no puede compararse con predicado numérico — error de tipo silencioso en migración si se mapea a BIGINT
- NIO vacío (espacios) en operaciones no-SPEI es válido — no confundir con error de integridad
- CECOBAN = 0 puede indicar operación sin compensación interbancaria o dato no capturado

**Confianza:** ALTA — tipos explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-498

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-498 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
FIND S151B02IMPADI
  WHERE AUTS151 = :auts151_del_movimiento_padre
  → 0 o 1 registro (relación hija con BxMOVTOS)
SI NOT FOUND → movimiento sin importes adicionales (caso válido)
SI FOUND     → importe_adicional disponible para presentación al cliente
```

**Excepciones documentadas:**
- COARSE no garantiza latencia constante bajo presión de memoria del sistema — otras BDs compiten por caché
- Cada movimiento tiene 0 o 1 registro IMPADI — relación hija no obligatoria; NOT FOUND es el caso normal
- En migración: IMPADI debe modelarse como tabla hija con FK nullable hacia BxMOVTOS

**Confianza:** ALTA — directiva explícita en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-499

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-499 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Acumulación en cierre de turno:
ACUMULAR B03CSISUCCAJ (clave: SUCINI, CAJINI, MONEDA, BANCOS, MDE, SECREN)
ACUMULAR B04CSISUCCAJ (clave: SUCINI, CAJINI, MONEDA, BANCOS, MDA, SECREN)
% Cuadre:
total_B03 + total_B04 DEBE = SUM(BxMOVTOS para la caja/turno)
SI diferencia ≠ 0 → ERROR cuadre de caja → auditoría manual
```

**Excepciones documentadas:**
- SECREN = 0 puede indicar turno no iniciado o transacción fuera de turno formal
- Cuadre con diferencia → requiere auditoría manual por cajero/SECREN; no hay mecanismo automático de corrección
- 80K registros: si cajas activas × turnos × monedas supera este techo, overflow del DATA SET

**Confianza:** ALTA — campos de clave explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-500

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-500 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
SI transferencia sujeta a SAT Anexo 20
  RFC-ORD   = ALPHA(13) — persona moral ordenante
  RFC-BENEF = ALPHA(18) — persona física o extendido con prefijo
  NOM-BENEF = ALPHA(120) — nombre completo beneficiario
SI operación interna (no sujeta a Anexo 20)
  → campos pueden quedar en blanco (espacios) — válido
% En migración: NO usar VARCHAR(13) uniforme para RFC — RFC-BENEF es (18)
```

**Excepciones documentadas:**
- RFC-BENEF de 18 chars puede contener prefijo internacional no estándar en registros históricos
- NOM-BENEF vacío en operaciones que no tienen destinatario externo identificado
- Truncar RFC-BENEF a 13 chars en migración produce errores silenciosos de identificación de beneficiario — riesgo SAT

**Confianza:** ALTA — campos presentes en DASDL y en estructura REG-MOVIMIENTOS de P151.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

## BD11 — Saldos y Posición GL (S151B20..B80)

---

### RN-S151-501

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-501 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Por cada movimiento contable del día:
FIND-OR-CREATE B72POSCONTA
  WHERE (KEYCSI, KEYFEC, KEYBCO, KEYMON, KEYFID, KEYPRD, KEYINS, KEYCTA,
         KEYCVEC, KEYSEC) = :dims
ACTUALIZAR:
  CARGOS  += importe SI NATCTA = deudora
  ABONOS  += importe SI NATCTA = acreedora
  SDOACT   = SDOANT + ABONOS - CARGOS
```

**Excepciones documentadas:**
- KEYCVEC incorrecto genera desclasificación de causa — impacta directamente R04C/R27C; no hay validación automática en DASDL
- KEYSEC = 00 puede ser válido (gobierno federal) o indicar falta de clasificación — verificar contra catálogo CNBV vigente
- SDOANT debe ser el SDOACT del día anterior — dependencia temporal; gap de procesamiento rompe reconciliación contable

**Confianza:** ALTA — estructura explícita en DASDL con campo KEYSEC confirmado.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-502

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-502 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Acceso correcto — solo saldos activos:
SCAN B20BXSDOMENCON (subset BIT VECTOR WHERE STAMOV=1)
  KEY (KEYAM, KEYCON, KEYPRD, KEYMON)

% Acceso INCORRECTO — incluye históricos y activos mezclados:
SCAN S151B20SDOMENCON directamente
  → retorna STAMOV={0,1,2,...} — saldos duplicados aparentes en reportes
```

**Excepciones documentadas:**
- Consultar el DATA SET base sin el subset BIT VECTOR produce duplicación aparente de saldos — error silencioso en reportes CNBV
- STAMOV ≠ 1 no significa registro erróneo — puede ser histórico válido para auditoría o reportes de períodos pasados
- En migración: BIT VECTOR no existe en SQL estándar — reemplazar con partial index (WHERE stamov = 1)

**Confianza:** ALTA — filtro explícito en DASDL con BIT VECTOR confirmado.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-503

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-503 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Lecturas masivas en cierre del día:
SCAN B70POSICION / B72POSCONTA con MEMORY RESIDENT=COARSE
  → páginas calientes en memoria, latencia reducida para cierres concurrentes

% Dependencia crítica de storage:
B70POSICION → pack físico S067REMESAS
  → backup de S067 incluye B70POSICION
  → reorg de B70 requiere coordinación con equipo S067
```

**Excepciones documentadas:**
- Caída del pack S067REMESAS hace inaccesible B70POSICION aunque S151 esté en línea — dependencia crítica cross-sistema
- COARSE puede degradar bajo presión de memoria del sistema (otras BDs compiten por caché en cierre del día)
- Migración de S151 sin S067: B70POSICION queda huérfana de su pack — debe reasignarse a pack propio antes del cutover

**Confianza:** ALTA — directivas explícitas en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-504

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-504 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Acceso a saldo adicional por índice:
FIND S151B21SDMENCON1
  WHERE (KEYAM, KEYCON, KEYPRD, KEYINS, KEYMON, KEYIND) = :params
  → hasta 12 ocurrencias por combinación de clave
% Iteración completa de todos los períodos:
FOR KEYIND = 0 TO 11
  FIND registro → procesar ocurrencia de saldo del período
```

**Excepciones documentadas:**
- Significado exacto de KEYIND (0-11 = ene-dic, o tipo de saldo adicional) no está en DASDL — requiere análisis del programa que puebla este DATA SET
- En migración relacional: OCCURS 12 debe exploderse en 12 filas (normalización) o 12 columnas (desnormalización) — decisión de diseño con impacto en performance
- KEYIND fuera de rango (> 11) no tiene validación en DASDL — posible dato corrupto en histórico

**Confianza:** MEDIA — estructura inferida del patrón; el significado exacto de las 12 ocurrencias requiere análisis de programas clientes.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-505

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-505 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Lógica de P158 — generación de estado de cuenta:
FIND S151B80EDOCTA
  WHERE (FECCON, PRD, INS, KEYCONT) = :params
SI FOUND Y estado = activo
  → P158 genera estado de cuenta para este contrato/período
SI NOT FOUND
  → P158 omite el contrato — NO genera estado de cuenta (falla silenciosa al cliente)
```

**Excepciones documentadas:**
- NOT FOUND en B80EDOCTA → estado de cuenta no generado — falla silenciosa para el cliente; no hay error visible en el sistema
- FECCON incorrecta → estado de cuenta generado en período equivocado — incumplimiento regulatorio CNBV/CONDUSEF
- 5M registros: si el número de contratos activos supera este techo, overflow en DATA SET — no se generan estados de cuenta

**Confianza:** ALTA — estructura explícita en DASDL; relación con P158 confirmada por análisis de P158.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-506

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-506 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Lectura de fecha de proceso (post-CRONOS2K):
FEC = LEER B00.FEC NUMBER(08)  % CCAAMMDD — 8 dígitos
siglo = FEC / 1000000          % primeros 2 dígitos (20)
año   = (FEC / 10000) MOD 100
mes   = (FEC / 100) MOD 100
día   = FEC MOD 100
% Programas que asumen 6 dígitos truncan el siglo silenciosamente
```

**Excepciones documentadas:**
- Programas que leen FEC como NUMBER(06) truncan el siglo — "2026" → "26" interpretado como 1926 en lógica de fecha
- Fechas históricas en backups pre-2000 pueden tener 6 dígitos — incompatibilidad al restaurar en sistema post-CRONOS2K
- Buscar *INICIA / *TERMINA CODIGO DE RENOVACION CRONOS 2000 para identificar todos los programas afectados

**Confianza:** ALTA — comentarios de renovación explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-507

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-507 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Toda operación I/O en S151B70POSICION accede al pack S067REMESAS:
backup S067    → incluye implícitamente B70POSICION de S151
reorg B70      → coordinar ventana con equipo S067
migración S151 → B70POSICION NO migra de forma independiente
  → reasignar PACKNAME a pack propio S151 antes del cutover
```

**Excepciones documentadas:**
- Mantenimiento programado de S067 hace inaccesible B70POSICION aunque S151 esté en línea
- Si S067 cambia naming del pack, la referencia PACKNAME en DASDL S151 queda desactualizada — requiere redefinición coordinada de ambos sistemas
- En migración sin S067: B70POSICION queda huérfana de su pack — debe reasignarse a pack propio antes del cutover

**Confianza:** ALTA — directiva explícita en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

## BD12 — Movimientos por Contrato Tripartita (OK / INFO / ERROR)

---

### RN-S151-508

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-508 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
CASE tipo_resultado OF
  OK    → escribir en S151B01MOVCTO    (25M)
  INFO  → escribir en S151B11MOVINFCTO  (5M)
  ERROR → escribir en S151B51MOVERRCTO  (5M)
% Migración relacional — opción A (tabla única):
  movimiento_contrato (tipo_resultado VARCHAR(5))
  + CHECK (tipo_resultado IN ('OK','INFO','ERROR'))
% Migración relacional — opción B (tres tablas):
  tablas físicas separadas con SLOs distintos por tipo
```

**Excepciones documentadas:**
- Colapsar en tabla única sin discriminante hace imposible mantener SLOs diferenciados por tipo de resultado
- Mezcla entre conjuntos imposible en DMSII (físicamente separados) — en SQL debe imponerse con CHECK constraint
- 9 tablas totales en BD12 (3 principales + 6 de extensión): deben modelarse con FK por tipo de resultado en migración

**Confianza:** ALTA — poblaciones explícitas en DASDL; análisis de patrón confirmado.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-509

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-509 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Al registrar el movimiento en BD12:
SECTOR = catálogo CNBV (2 dígitos) — determinado al momento del movimiento
BANCA  = clasificación de línea de negocio (2 dígitos)
% Ambos campos son inmutables una vez registrado el movimiento
% Para reportes R04C / R27C:
GROUP BY SECTOR, BANCA → clasificación del portafolio
```

**Excepciones documentadas:**
- SECTOR = 00 puede ser válido (gobierno federal) o indicar falta de clasificación — verificar contra catálogo CNBV vigente
- Recatalogación posterior de un movimiento ya registrado afecta reportes históricos R04C/R27C — los valores son fijos al momento del registro
- BANCA incorrecto invalida la clasificación de línea de negocio en reportes — error de captura no detectable automáticamente

**Confianza:** ALTA — campos explícitos en DASDL de BD12.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-510

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-510 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Por contrato en período de corte:
FIND B01SXMOVCTO WHERE (FECCON, KEYCONT, SEC) = :params
% Por fecha valor:
SCAN B01SXFCHVAL WHERE (PRD, INS, KEYCONT, FECVAL, SEC) = :params
% Acceso directo por secuencia global:
FIND B01SXMOVSEC WHERE SEC = :sec_global
```

**Excepciones documentadas:**
- SEC del conjunto OK ≠ SEC del conjunto INFO ≠ SEC del conjunto ERROR — son espacios de numeración independientes por conjunto
- FECCON diferente a FECVAL para operaciones con fecha valor futura (depósitos a plazo) — frecuente en captación
- En migración: SEC no equivale a AUTS151 de BD10 — son identificadores de sistemas distintos (BD12 vs BD10)

**Confianza:** ALTA — índices explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-511

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-511 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Para construir leyenda completa de un movimiento OK:
(1) FIND B01MOVCTO (registro principal)
(2) FIND B02IMPADI WHERE AUTS151 = :auts151 → importes adicionales
(3) FIND B03DATADI WHERE AUTS151 = :auts151 → LEY1, REFLOCBNM
(4) FIND B04CONDATADI WHERE AUTS151 = :auts151 → LEY2..LEY5
% Leyenda completa = CONCAT(LEY1, LEY2, LEY3, LEY4, LEY5)
```

**Excepciones documentadas:**
- Un movimiento puede tener 0 extensiones (IMPADI/DATADI/CONDATADI son opcionales) — NOT FOUND es caso normal, no error
- Leyenda incompleta si faltan registros de extensión — NOT FOUND silencioso; presentar leyenda parcial al cliente
- REFLOCBNM vacío para movimientos internos sin referencia en sistema origen

**Confianza:** ALTA — estructura explícita en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-512

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-512 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Para movimientos INFO — extensiones propias:
FIND B12IMPINFADI / B13DATINFADI / B14CONDATADI
  WHERE SEC_INFO = :sec_info

% Para movimientos ERROR — extensiones propias:
FIND B52IMPADIERR / B53DATADIERR / B54CONDATERR
  WHERE SEC_ERROR = :sec_error

% NUNCA mezclar extensiones entre conjuntos:
% IMPADI de OK ≠ IMPINFADI de INFO ≠ IMPADIERR de ERROR
```

**Excepciones documentadas:**
- FK entre extensiones e INFO/ERROR debe verificarse por tipo_resultado — extensión de OK no puede enlazarse con registro INFO o ERROR
- En migración relacional: 9 tablas con sus FK por tipo deben modelarse explícitamente — riesgo de FK cruzadas entre conjuntos
- Población menor (2.5M vs 12.5M) sugiere que INFO y ERROR tienen menos extensiones por registro — validar en datos reales antes de migrar

**Confianza:** ALTA — poblaciones y nombres explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-513

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-513 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Asignación atómica de SEC:
LOCK B00
  SECOK = SECOK + 1
  nuevo_SEC_OK = SECOK
UNLOCK B00
% Mismo patrón para SECINF y SECERR
% Reconciliación:
COUNT(OK en B01MOVCTO) DEBE ≤ SECOK (gaps = movimientos eliminados)
```

**Excepciones documentadas:**
- SECOK no retrocede automáticamente al inicio del período — requiere reinicio explícito al inicio del corte; sin esto, SEC crece indefinidamente
- Gap en secuencia (SEC no consecutivo) indica movimiento eliminado o error de asignación — debe auditarse
- Contadores NUMBER(08) tienen techo de 99,999,999 — si un período procesa más de 100M movimientos, desbordamiento silencioso

**Confianza:** ALTA — campos explícitos en DASDL con análisis de patrón de uso.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

## BD13 — BIFIN / Protección de Cobro / Domiciliación

---

### RN-S151-514

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-514 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Acceso a protección de cobro:
FIND B07PROTCOB WHERE B07-AUT-PC = :aut_pc_12_digitos

% INCORRECTO — AUT-PC ≠ AUTS151:
FIND B07PROTCOB WHERE B07-AUT-PC = :auts151_8_digitos
  → NOT FOUND o match incorrecto silencioso

% En migración: FK entre B07PROTCOB y BD10
  → requiere campo de cruce explícito o tabla de equivalencia
  → NO es: B07-AUT-PC = AUTS151
```

**Excepciones documentadas:**
- AUT-PC(12) y AUTS151(08): misma semántica conceptual (autorización) pero espacios de numeración completamente distintos — confusión silenciosa posible
- Los 12 dígitos de AUT-PC incluyen prefijos del sistema de protección de cobro ausentes en AUTS151
- 150M registros: DATA SET de alta población — cualquier índice incorrecto en migración afecta a todo el histórico de domiciliaciones

**Confianza:** ALTA — longitudes explícitas en DASDL; diferencia confirmada en análisis.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-515

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-515 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Ciclo de vida de instrucción de protección de cobro:
STATUS 0 (pendiente) → enviar al banco receptor
  → STATUS = 1 (enviado)
STATUS 1 → esperar confirmación del banco receptor
  → STATUS = 2 (confirmado) O iniciar reversa → STATUS = 3
STATUS 3 (enviado reversa) → esperar confirmación reversa
  → STATUS = 4 (reversa confirmada)
% Procesables (via B07SXAUTPROC): STATUS IN (0, 1, 2)
```

**Excepciones documentadas:**
- STATUS 3 y 4 (reversa) tienen tiempo máximo de procesamiento regulatorio — exceder el plazo requiere reporte a Banxico
- STATUS 5 (eliminado sin enviar) en alto volumen puede indicar error de parametrización — requiere auditoría
- Transición STATUS inválida (ej. 0→4 sin pasar por 1,2,3) no tiene validación en DASDL — debe implementarse en programa

**Confianza:** ALTA — valores de STATUS explícitos en DASDL y comentarios.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-516

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-516 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Conversión de fecha juliana a gregoriana:
AUTD-FECJUL NUMBER(07) → fecha_gregoriana = fecha_base + AUTD-FECJUL días
% (fecha_base es constante del sistema — no en DASDL)

% Cross-reference con S702:
FIND B10SXFAUTAP702
  WHERE AUTD-AUT702 = :aut702_de_s702
  → localizar instrucción de domiciliación cruzada
```

**Excepciones documentadas:**
- EXTENDED=TRUE requerido para 150M registros — sin esta directiva en versiones DMSII antiguas, límite es 65,535
- Fecha juliana sin conocer la fecha base del sistema es ininterpretable — requiere constante documentada del sistema
- Si S702 no está disponible en migración, AUTD-AUT702 queda como referencia huérfana — tabla de equivalencia necesaria

**Confianza:** ALTA — directivas y campos explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-517

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-517 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Flujo de envío y reintento:
FIND B04CTLCITIDIR por control de envío
SI ESTATUS = error → REINTENTOS = REINTENTOS + 1
SI REINTENTOS > umbral_maximo → ALERTA intervención manual
SI ESTATUS = confirmado → mensaje entregado exitosamente
% NIO alfanumérico: mapear a VARCHAR(16), NO a BIGINT
```

**Excepciones documentadas:**
- Umbral máximo de REINTENTOS no está en DASDL — hardcodeado en programa cliente; debe documentarse
- Loop infinito si ESTATUS nunca pasa a confirmado y REINTENTOS no tiene techo en el programa
- NIO alfanumérico vacío para mensajes no-SPEI — no confundir con error de integridad

**Confianza:** ALTA — campos explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-518

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-518 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
FIND S151B08TDMIGCAP por clave de tarjeta
SI STATUS = 'AC' → tarjeta activa, procesar operación
SI STATUS = 'CA' → tarjeta cancelada, rechazar operación
% ALERTA: STATUS aquí es ALPHA(02), NO NUMBER(02) como en B07PROTCOB
% Comparaciones deben usar predicado ALPHA (case-sensitive)
```

**Excepciones documentadas:**
- STATUS ALPHA(02) semánticamente distinto a STATUS NUMBER(02) de B07PROTCOB — no intercambiables en código de migración
- 'AC'/'CA' sensibles a espacios o mayúsculas en comparaciones ALPHA — 'ac' ≠ 'AC' en DMSII
- DATA SET de referencia histórica: no crece diariamente — cualquier crecimiento anómalo indica evento de migración no documentado

**Confianza:** ALTA — campo y valores explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

## BD99 — Control del Sistema

---

### RN-S151-519

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-519 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Acumulación por sucursal en cierre del día:
ACUMULAR B10MOVPORSUC
  BY (SISTEMA, PRODUCTO, MONEDA, INSTRUMENTO, SUCURSAL, TIPO, SECTOR, ...)
% Lectura secuencial para reportes:
SCAN secuencial B10MOVPORSUC → BLOCKSIZE=4 × REBLOCKFACTOR=5
  → bloques efectivos de 20 páginas — optimizado para scan masivo
```

**Excepciones documentadas:**
- REBLOCKFACTOR ≠ 1 requiere consideración especial en reorganización de BD — proceso más lento por empaquetado denso
- Lectura por clave individual (no secuencial) no se beneficia del REBLOCKFACTOR — latencia similar a BD sin densificación
- SECTOR en clave de 9 dimensiones es obligatorio para reportes CNBV — faltante causa agrupación incorrecta por sucursal

**Confianza:** ALTA — parámetros explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-520

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-520 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Acumulación por cliente en cierre del día:
ACUMULAR B11MOVPORCTE BY clave_cliente
% BLOCKSIZE=7 > BLOCKSIZE=4 de B10MOVPORSUC
  → registros por cliente más grandes que registros por sucursal
% Comparación de poblaciones:
  10M clientes únicos > 8M sucursales activas
  → más granularidad por cliente que por sucursal
```

**Excepciones documentadas:**
- BLOCKSIZE diferente entre B10(4) y B11(7) implica que reorganizaciones simultáneas tienen perfiles de I/O distintos — planificar ventanas separadas
- 10M registros: si el número de clientes activos supera este techo, overflow — clientes sin acumulado en BD99
- Análisis de concentración por cliente requiere COARSE para latencia aceptable en reportes masivos

**Confianza:** ALTA — parámetros explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-521

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-521 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Por cada movimiento, acumular en el día correspondiente:
DIAS-SEM[día_hábil].CARGO += importe_cargo
DIAS-SEM[día_hábil].ABONO += importe_abono
% día_hábil = 1..5 (lunes..viernes)
% Posición neta de la semana:
posición_neta = SUM(ABONO[1..5]) - SUM(CARGO[1..5])
```

**Excepciones documentadas:**
- OCCURS 5 corresponde a 5 días hábiles — sábado y domingo no tienen ocurrencia dedicada; transacciones de fin de semana acumular en día lunes o viernes según parametrización
- Rollup semanal → mensual requiere suma de múltiples registros B12 (uno por semana del mes)
- En migración: OCCURS 5 debe exploderse en 5 filas (con día_hábil como FK) o 5 pares de columnas — impacto en modelo relacional

**Confianza:** ALTA — estructura y ocurrencias explícitas en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-522

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-522 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Identificar archivos pendientes de procesar:
SCAN subset BIT VECTOR WHERE STAARC = 1
  → archivos activos/pendientes
% Al completar procesamiento:
ACTUALIZAR STAARC = 0 (o valor terminal)
  → archivo desaparece del subset activo
SI STAARC queda en 1 tras proceso exitoso → error de actualización
  → riesgo de reproceso del archivo ya procesado
```

**Excepciones documentadas:**
- STAARC quedado en 1 tras procesamiento exitoso indica error de actualización — reintento del archivo ya procesado genera duplicados
- STAARC = 1 en B15ARCDIADES (destino) puede indicar archivo de salida no confirmado como recibido por el sistema consumidor
- BIT VECTOR no disponible en SQL estándar — reemplazar con partial index WHERE staarc = 1 en migración

**Confianza:** ALTA — directiva BIT VECTOR y campo STAARC explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

## BD02 — Saldos Tesorería (ADSALDO)

---

### RN-S151-523

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-523 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Reconstrucción de clave de cliente de 20 dígitos:
clave_cliente_20 = LPAD(NUMERO1, 10, '0') || LPAD(NUMERO2, 10, '0')
% En migración:
  mapear clave_cliente_20 → identificador natural del cliente en sistema destino
  → requiere validación con negocio: ¿qué representa cada mitad?
```

**Excepciones documentadas:**
- Si NUMERO2 = 0, la clave efectiva puede ser solo NUMERO1 (10 dígitos) — verificar con negocio si es caso válido o dato incompleto
- La longitud 20 puede no ser universalmente válida para todos los sistemas destino — identificar el identificador natural equivalente
- Clave partida en dos campos NUMBER(10) puede generar confusión en joins si se usa uno solo de los campos

**Confianza:** ALTA — campos explícitos en DASDL; calificación SOSPECHOSO por necesidad de validación semántica.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-524

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-524 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Por cada operación interbancaria en tiempo real:
ESCRIBIR B14CONOPECRUZ (concentrado: BCO_ORI, BCO_DES, HORA, FECHA_MQ)
  BNM_cargos/abonos ← movimientos de Banamex
  OTR_cargos/abonos ← movimientos de banco contraparte
  LIQ = BNM_abonos - OTR_cargos  % liquidación neta
  DIFGLO = SUM(DIF individuales)  % diferencia global acumulada
ESCRIBIR B15MOVOPECRUZ (detalle individual)
% Reconciliación al cierre:
SI DIFGLO ≠ 0 → reportar discrepancia a Banxico
```

**Excepciones documentadas:**
- MEMORY RESIDENT=ALL en tabla de 100K registros — cualquier crecimiento de población más allá de lo que cabe en memoria requiere re-evaluar si sigue cabiendo en ALL
- DIF ≠ 0 al cierre del día → discrepancia que debe reportarse a Banxico dentro del plazo regulatorio
- AUTS151 en B14CONOPECRUZ permite rastrear el movimiento origen en BD10 — clave de trazabilidad cross-BD

**Confianza:** ALTA — directiva MEMORY RESIDENT=ALL y campos explícitos en DASDL.

**Capacidad bancaria:** 7.1.1 Finance (GL) — Diccionario de Datos
**Frecuencia:** N/A — definición estructural
**Sistemas downstream:** Todos los programas S151 que usan las 6 BDs (P108, P109, P112, P120, P130, P131, P150, P021, P103)

---

### RN-S151-525

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-525 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | — |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / pseudocódigo:**
```
% Actualización de saldo SAR por organismo:
FOR cada organismo IN (IMSS, ISSSTE, INFONAVIT, FOVISSSTE, PEMEX)
  saldo_act = saldo_ant + obligatoria + voluntaria + inflacion
              + intereses - recargos
% Reporte CONSAR:
SUM(saldo_act) por organismo sobre todos los contratos activos
```

**Excepciones documentadas:**
- PEMEX tiene fondo SAR administrado de forma diferente a IMSS/ISSSTE — validar reglas de actualización por separado antes de migrar
- saldo_ant del día de proceso debe ser el saldo_act del día anterior — dependencia temporal; gap de procesamiento rompe reconciliación SAR
- Recargos negativos pueden indicar corrección de aportación — validar que el modelo relacional soporta subcampos negativos

**Confianza:** ALTA — campos explícitos en DASDL con análisis de dominio SAR.
