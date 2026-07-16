# Reglas DASDL S151 — DICCIONARIO DE DATOS / 6 BASES DE DATOS (con vocabulario)
> **Bases:** BD10 (movimientos diarios) · BD11 (posición GL) · BD12 (movimientos por contrato) · BD13 (protección cobro) · BD99 (control) · BD02 (saldos cliente)
> **ALERTA:** Sucursales 859/100/342/110/511/870 usan KEY=AUTAPL no AUTS151 — queries por AUTS151 no las encuentran [CRÍTICO]
> **ALERTA:** Tripartita BD12 (OK/INFO/ERROR) no puede colapsarse en una sola tabla sin perder volúmenes y SLOs distintos
> **Enriquecido con:** vocabulario vocab-s151.md · ente regulador · nivel de confianza · schema v2 (Fórmula · Excepciones · Capacidad bancaria · Frecuencia · Sistemas downstream)
> **Rango:** RN-S151-491 a RN-S151-525 (35 reglas)
> **Fuentes DASDL:** DASDL_S151BD10MOVDIA151.txt · DASDL_S151BD11SDOS151.txt · DASDL_S151BD12MC001S151.txt · DASDL_S151BD13BIFIN.txt · DASDL_S151BD99CONTROL.txt · DASDL_S151BD02ADSALDO.txt
> **Actualizado:** 2026-07-16

---

## BD10 — Movimientos Diarios (S151B01..B41MOVTOS)

### RN-S151-491
**ID:** RN-S151-491
**Título:** BD10 — Rotación semanal: 5 conjuntos diarios independientes
**Descripción:** La base BD10 (movimientos diarios) se materializa en cinco DIRECT DATA SETs paralelos, uno por día hábil de la semana: B01 (lunes), B11 (martes), B21 (miércoles), B31 (jueves), B41 (viernes). Cada conjunto es completamente autónomo — no existe heredar ni partir data entre días. El selector del día activo se gestiona desde BD99 (S151B01SISDIA.NOMBDSEM). El sábado reutiliza uno de los conjuntos según parametrización.
**Ente regulador:** N/A (regla estructural de storage)
**Evidencia DASDL:**
```
S151B01MOVTOS: DIRECT DATA SET ...
  POPULATION IS 52500000.
% Patrón idéntico para S151B11MOVTOS (B11...), S151B21MOVTOS, S151B31MOVTOS, S151B41MOVTOS
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| DATA SET | Unidad lógica de almacenamiento DMSII equivalente a tabla |
| DIRECT | Tipo de DATA SET DMSII con acceso directo por número de registro |
| POPULATION | Cardinalidad declarada del DATA SET — afecta sizing físico |
| BD10 | Base de datos de movimientos diarios del S151 |
| NOMBDSEM | Campo en BD99.B01SISDIA que contiene el nombre del BD activo de la semana |

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
**ID:** RN-S151-492
**Título:** BD10 — Cardinalidad: 52.5 M registros por conjunto diario
**Descripción:** Cada uno de los cinco conjuntos diarios (B01..B41MOVTOS) declara `POPULATION IS 52500000`. Esta cardinalidad define el espacio físico asignado en DMSII y establece el techo de movimientos procesables en un día hábil. Superar esta población causaría error de overflow en el DATA SET. La equivalencia es ~52.5 M autorizaciones diarias máximas.
**Ente regulador:** N/A (sizing operativo)
**Evidencia DASDL:**
```
S151B01MOVTOS: DIRECT DATA SET
  POPULATION IS 52500000.
  KEY IS AUTS151.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| POPULATION | Número máximo de registros declarados; dimensiona el espacio en disco DMSII |
| AUTS151 | Número de autorización del movimiento S151, 8 dígitos numéricos — clave primaria de BD10 |
| DIRECT DATA SET | Organización de acceso directo por número lógico de registro |
| overflow | Condición de error cuando POPULATION se excede; requiere reorganización de BD |

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
**ID:** RN-S151-493
**Título:** BD10 — Acceso directo por AUTS151 vía B01SXAUTS151
**Descripción:** El ACCESS TO `B01SXAUTS151` proporciona lookup de un único registro por el identificador de autorización `AUTS151 NUMBER(08)`. Este es el índice de recuperación individual más eficiente de BD10 — equivale a un lookup por llave primaria. La longitud 8 dígitos es fija y distinta de AUT-PC (12 dígitos en BD13) y AUTAPL (8 dígitos pero uso diferente). AUTS151 es universal para movimientos normales.
**Ente regulador:** CNBV (AUTS151 es el identificador trazable de cada cargo/abono en estados de cuenta supervisables)
**Evidencia DASDL:**
```
B01SXAUTS151: ACCESS TO S151B01MOVTOS
  KEY IS AUTS151.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| AUTS151 | Autorización del movimiento S151; NUMBER(08) — 8 dígitos decimales |
| ACCESS TO | Índice DMSII de acceso a un único registro (equivalente a UNIQUE INDEX) |
| AUT-PC | Autorización de protección de cobro en BD13; NUMBER(12) — diferente longitud |
| AUTAPL | Autorización de aplicación; NUMBER(08) — usada como alternativa en sucursales especiales |
| lookup | Acceso por clave primaria, O(1) en DMSII |

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
**ID:** RN-S151-494
**Título:** BD10 — Filtro PROCESO<15 delimita movimientos activos en subsets
**Descripción:** Los tres subsets principales de movimientos activos (B01BXMOVCAJ, B01BXMOVCTO, B01BXMDA) filtran `WHERE PROCESO < 15`. Este valor 15 es el umbral que separa movimientos procesables de movimientos en estados terminales o archivados. Movimientos con PROCESO >= 15 no aparecen en estos subsets y requieren acceso directo por AUTS151. El valor 15 está hardcodeado en el DASDL.
**Ente regulador:** N/A (regla de estado interno del proceso)
**Evidencia DASDL:**
```
B01BXMOVCAJ: SUBSET OF S151B01MOVTOS
  WHERE PROCESO < 15 AND SUCINI > 0
  KEY IS (SUCINI, CAJINI, AUTS151) ...
B01BXMOVCTO: SUBSET OF S151B01MOVTOS
  WHERE PROCESO < 15
  KEY IS (NUMCTO, AUTS151) ...
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| PROCESO | Campo numérico en S151B01MOVTOS que indica etapa del ciclo de procesamiento |
| SUBSET OF | Índice DMSII filtrado (equivalente a partial index con WHERE clause) |
| BIT VECTOR | Técnica de indexación DMSII para subsets con filtro booleano — mejora escaneo |
| movimiento activo | Movimiento con PROCESO < 15 disponible en los subsets principales |

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
**ID:** RN-S151-495
**Título:** BD10 — B01BXMOVCAJ requiere SUCINI > 0 para movimientos de cajero
**Descripción:** El subset `B01BXMOVCAJ` agrega la restricción `AND SUCINI > 0` además de `PROCESO < 15`. Esto excluye movimientos sin sucursal inicial asignada (SUCINI = 0), que corresponden a transacciones electrónicas o batch sin cajero físico. La clave de este subset es `(SUCINI, CAJINI, AUTS151)` con BUFFERS=2500+100/usuario — buffers elevados para rendimiento de consultas concurrentes de cajeros.
**Ente regulador:** N/A (regla de operación de cajeros)
**Evidencia DASDL:**
```
B01BXMOVCAJ: SUBSET OF S151B01MOVTOS
  WHERE PROCESO < 15 AND SUCINI > 0
  KEY IS (SUCINI, CAJINI, AUTS151)
  BUFFERS ARE 2500, 100 PER USER.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| SUCINI | Sucursal inicial donde se origina el movimiento; NUMBER(04) |
| CAJINI | Caja/cajero inicial; NUMBER(02) dentro de la sucursal |
| BUFFERS | Páginas de memoria caché asignadas al subset; 2500 globales + 100 por usuario concurrente |
| movimiento electrónico | Movimiento con SUCINI=0 — no pasa por cajero físico |

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
**ID:** RN-S151-496
**Título:** BD10 — HARDCODE CRÍTICO: Sucursales especiales 859/100/342/110/511/870 usan KEY=AUTAPL no AUTS151
**Descripción:** El subset `B01BXCAJ859` cubre las sucursales especiales con `WHERE SUCINI IN (859, 100, 342, 110, 511, 870)` y usa `KEY IS (SUCINI, CAJINI, AUTAPL)` en lugar de AUTS151. Estas sucursales hardcodeadas en el DASDL utilizan el número de autorización de aplicación (AUTAPL NUMBER(08)) como tercera dimensión de la clave, no el AUTS151. Cualquier consulta que asuma AUTS151 como clave universal para cajeros encontrará registros erróneos o vacíos para estas sucursales. El mismo patrón se repite en B11BXCAJ859, B21BXCAJ859, B31BXCAJ859, B41BXCAJ859 (uno por cada día de la semana).
**ALERTA MIGRACIÓN:** [CRÍTICO] Al migrar BD10 a modelo relacional, la clave de cajeros debe bifurcarse: sucursales estándar (AUTS151) vs. sucursales especiales (AUTAPL). Una tabla única sin esta bifurcación perderá la identidad de movimientos de las 6 sucursales especiales.
**Ente regulador:** CNBV (trazabilidad de movimientos de cajero por sucursal, requerida en supervisión CNBV)
**Evidencia DASDL:**
```
B01BXCAJ859: SUBSET OF S151B01MOVTOS
  WHERE SUCINI IN (859, 100, 342, 110, 511, 870)
  KEY IS (SUCINI, CAJINI, AUTAPL).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| AUTAPL | Autorización de aplicación; NUMBER(08) — alternativa a AUTS151 para sucursales especiales |
| sucursal especial | Sucursal con lógica diferenciada hardcodeada: 859, 100, 342, 110, 511, 870 |
| SUCINI | Sucursal inicial del movimiento — criterio de bifurcación de clave |
| hardcode | Valor literal en código fuente sin parametrización — riesgo de deuda técnica en migración |
| bifurcación de clave | Necesidad de usar AUTAPL o AUTS151 según la sucursal del movimiento |

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
**ID:** RN-S151-497
**Título:** BD10 — NIO ALPHA(16) y CECOBAN NUMBER(08) para trazabilidad SPEI/CECOBAN
**Descripción:** El DATA SET principal `S151B01MOVTOS` contiene los campos `NIO ALPHA(16)` (Número de Identificación de Operación Banxico para SPEI) y `CECOBAN NUMBER(08)` (referencia de cámara de compensación CECOBAN). NIO es alfanumérico de 16 caracteres — no numérico puro — lo que implica que comparaciones con campos numéricos producirán errores de tipo en migración. CECOBAN es 8 dígitos numéricos para operaciones de compensación interbancaria.
**Ente regulador:** Banxico (NIO es identificador obligatorio asignado por SPEI para toda transferencia electrónica; CECOBAN para liquidación interbancaria)
**Evidencia DASDL:**
```
S151B01MOVTOS: DIRECT DATA SET ...
  NIO ALPHA(16).
  CECOBAN NUMBER(08).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| NIO | Número de Identificación de Operación; identificador SPEI asignado por Banxico; ALPHA(16) |
| CECOBAN | Centro de Compensación Bancaria — referencia de liquidación interbancaria; NUMBER(08) |
| SPEI | Sistema de Pagos Electrónicos Interbancarios — plataforma Banxico para transferencias |
| ALPHA | Tipo alfanumérico en DASDL — puede contener letras, dígitos y espacios |
| NOM-ORD | Nombre del ordenante; campo complementario al NIO en transferencias SPEI |

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
**ID:** RN-S151-498
**Título:** BD10 — S151B02IMPADI con MEMORY RESIDENT=COARSE para SLA de importes adicionales
**Descripción:** El DATA SET `S151B02IMPADI` (importes adicionales del movimiento, 6M de población) declara `MEMORY RESIDENT = COARSE`. Esta directiva DMSII mantiene las páginas más frecuentemente accedidas en memoria real, reduciendo E/S de disco. COARSE significa residencia parcial determinada por el motor según uso — contrasta con ALL (total en memoria) usado en BD02 para operaciones cruzadas. La elección de COARSE sobre ALL sugiere que IMPADI no tiene la criticidad de latencia de las operaciones en tiempo real de BD02.
**Ente regulador:** N/A (decisión de performance)
**Evidencia DASDL:**
```
S151B02IMPADI: DATA SET ...
  POPULATION IS 6000000.
  MEMORY RESIDENT = COARSE.
  KEY ASCENDING (AUTS151 IN S151B01MOVTOS).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| MEMORY RESIDENT | Directiva DMSII para mantener páginas en memoria principal |
| COARSE | Modalidad de residencia parcial — páginas calientes según uso reciente |
| ALL | Modalidad de residencia total — todas las páginas en memoria (usado en BD02 B14/B15) |
| IMPADI | Importes adicionales del movimiento — segunda tabla de detalle de BD10 |
| importe adicional | Cargo o abono complementario al importe principal del movimiento |

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
**ID:** RN-S151-499
**Título:** BD10 — Totales de cajero y sistema: B03/B04CSISUCCAJ con dimensiones MONEDA+BANCOS+SECREN
**Descripción:** Los DATA SETs `S151B03CSISUCCAJ` y `S151B04CSISUCCAJ` (80K registros cada uno) acumulan totales de cajero. La clave incluye `(SUCINI, CAJINI, MONEDA, BANCOS, MDE, MDA, SECREN)`. El campo `SECREN` (sección de rendición) permite reconciliación de cajas por turno o sesión. `BANCOS` clasifica el tipo de banco/entidad origen. Esta granularidad es suficiente para cuadre de caja por turno con detalle de moneda y medio de acceso (MDE/MDA).
**Ente regulador:** CNBV (cuadre de caja forma parte de los controles internos supervisados)
**Evidencia DASDL:**
```
S151B03CSISUCCAJ: DATA SET ...
  POPULATION IS 80000.
  KEY IS (SUCINI, CAJINI, MONEDA, BANCOS, MDE, SECREN).
S151B04CSISUCCAJ: DATA SET ...
  POPULATION IS 80000.
  KEY IS (SUCINI, CAJINI, MONEDA, BANCOS, MDA, SECREN).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| SECREN | Sección de rendición — identificador de turno/sesión para cuadre de caja |
| MONEDA | Código de moneda del movimiento (MXN, USD, etc.) |
| BANCOS | Clasificación del banco/entidad origen del movimiento |
| MDE | Medio de disposición de efectivo (cajero ATM) |
| MDA | Medio de acceso (tarjeta o instrumento) |
| cuadre de caja | Reconciliación de saldos de caja al cierre del turno |

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
**ID:** RN-S151-500
**Título:** BD10 — Campos regulatorios SAT: NOM-BENEF X(120), RFC-BENEF X(18), RFC-ORD X(13)
**Descripción:** El DATA SET principal `S151B01MOVTOS` contiene campos extendidos para cumplimiento SAT Anexo 20: `NOM-BENEF ALPHA(120)` (nombre del beneficiario, ampliado desde X(50)), `RFC-BENEF ALPHA(18)` (RFC del beneficiario, 18 caracteres incluyendo homoclave), `RFC-ORD ALPHA(13)` (RFC del ordenante, 13 caracteres para personas morales). La diferencia de longitud entre RFC-BENEF (18) y RFC-ORD (13) refleja que el beneficiario puede ser persona física (RFC de 13 chars) con homoclave extendida codificada diferente, o que el campo fue expandido para incluir prefijo internacional. Esta asimetría es una trampa en migración si se asume RFC uniforme de 13 caracteres.
**Ente regulador:** SAT (RFC obligatorio en transferencias electrónicas según Anexo 20 de la RMF; NOM-BENEF para anti-lavado)
**Evidencia DASDL/COBOL:**
```
% En REG-MOVIMIENTOS (P151):
  RM-RFC-ORD     X(13).
  RM-NOM-BENEF   X(120).
  RM-RFC-BENEF   X(18).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| RFC-BENEF | RFC del beneficiario de la transferencia; ALPHA(18) en S151 |
| RFC-ORD | RFC del ordenante; ALPHA(13) — longitud de persona moral estándar |
| NOM-BENEF | Nombre completo del beneficiario; expandido a X(120) por SAT Anexo 20 |
| SAT Anexo 20 | Anexo del SAT que define campos obligatorios en comprobantes digitales y transferencias |
| homoclave | Sufijo del RFC que diferencia personas con mismos datos (2-3 chars adicionales) |

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

### RN-S151-501
**ID:** RN-S151-501
**Título:** BD11 — B72POSCONTA: clave contable de 10 dimensiones GL
**Descripción:** El DATA SET `S151B72POSCONTA` (posición contable GL) usa una clave de 10 dimensiones: `(KEYCSI, KEYFEC, KEYBCO, KEYMON, KEYFID, KEYPRD, KEYINS, KEYCTA, KEYCVEC, KEYSEC)` donde KEYCVEC es la clave de causa (6 dígitos) y KEYSEC es el sector regulatorio (2 dígitos). Esta granularidad de 10 dimensiones permite generación de reportes CNBV R04C y R27C directamente desde esta posición sin necesidad de joins adicionales. La dimensión SECTOR (KEYSEC) es obligatoria para clasificación regulatoria de portafolios.
**Ente regulador:** CNBV (R04C/R27C requieren desagregación por cuenta contable, causa, sector y moneda; CUB Anexo 33)
**Evidencia DASDL:**
```
S151B72POSCONTA: DATA SET ...
  MEMORY RESIDENT = COARSE.
  KEY IS (KEYCSI, KEYFEC, KEYBCO, KEYMON, KEYFID, KEYPRD, KEYINS, KEYCTA,
          KEYCVEC, KEYSEC).
  FIELDS:
    KEYCVEC NUMBER(06). % CAUSA contable 6 dígitos
    KEYSEC  NUMBER(02). % SECTOR regulatorio 2 dígitos
    NATCTA  ...         % Naturaleza de cuenta (deudora/acreedora)
    SDOANT, CARGOS, ABONOS, SDOACT. % Movimientos del día
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B72POSCONTA | DATA SET de posición contable GL — 10 dimensiones |
| KEYCVEC | Clave de causa contable; 6 dígitos — motivo del movimiento contable |
| KEYSEC | Sector regulatorio; 2 dígitos — clasificación CNBV de contraparte |
| SECTOR | Dimensión regulatoria que clasifica la contraparte según CUB Anexo 33 |
| NATCTA | Naturaleza de la cuenta contable (deudora o acreedora) |
| R04C/R27C | Reportes regulatorios CNBV de cartera y captación con desagregación contable |
| SDOANT | Saldo anterior al día de proceso |
| SDOACT | Saldo actual al cierre del proceso del día |

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
**ID:** RN-S151-502
**Título:** BD11 — STAMOV=1 es el filtro obligatorio de saldos activos en B20BXSDOMENCON
**Descripción:** El DATA SET `S151B20SDOMENCON` (saldos mensuales por domicilio/contrato, 12M registros) contiene registros con múltiples estados. El subset `B20BXSDOMENCON` aplica `WHERE STAMOV = 1` con implementación BIT VECTOR, filtrando solo registros activos. Consultar S151B20SDOMENCON directamente sin este filtro devolverá registros históricos o inactivos y producirá duplicación aparente de saldos. El BIT VECTOR es una estructura de indexación DMSII eficiente para filtros booleanos en poblaciones grandes.
**Ente regulador:** CNBV (saldos reportados deben corresponder solo a cuentas activas)
**Evidencia DASDL:**
```
B20BXSDOMENCON: SUBSET OF S151B20SDOMENCON
  WHERE STAMOV = 1
  BIT VECTOR.
  KEY IS (KEYAM, KEYCON, KEYPRD, KEYMON).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| STAMOV | Estado del movimiento/saldo; valor 1 = activo |
| BIT VECTOR | Estructura de índice DMSII para subsets booleanos — bitmap index equivalente |
| B20SDOMENCON | DATA SET de saldos mensuales por domicilio y contrato (12M registros) |
| saldo duplicado | Error resultante de consultar sin filtro STAMOV=1 — incluye registros históricos |
| domicilio | Unidad de agrupación de cuentas bajo un cliente o contrato |

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
**ID:** RN-S151-503
**Título:** BD11 — MEMORY RESIDENT=COARSE en B70POSICION y B72POSCONTA para SLA de posición
**Descripción:** Los DATA SETs de posición diaria `S151B70POSICION` y `S151B72POSCONTA` declaran `MEMORY RESIDENT = COARSE`. Esto garantiza que las consultas de posición en procesos de cierre del día (que son masivos y concurrentes) tengan latencia reducida por residencia en memoria. B70POSICION adicionalmente tiene `PACKNAME = S067REMESAS`, indicando que el pack físico de almacenamiento pertenece al sistema S067 (Remesas) — dependencia de storage entre sistemas.
**Ente regulador:** N/A (decisión de performance para SLA de cierre contable)
**Evidencia DASDL:**
```
S151B70POSICION: DATA SET ...
  MEMORY RESIDENT = COARSE.
  PACKNAME = S067REMESAS.
  KEY IS (KEYCSI, KEYFEC, KEYPRD, KEYINS, KEYMON).
S151B72POSCONTA: DATA SET ...
  MEMORY RESIDENT = COARSE.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B70POSICION | DATA SET de posición diaria por CSI/fecha/producto/instrumento/moneda |
| PACKNAME | Nombre del pack físico de discos donde reside el DATA SET |
| S067REMESAS | Sistema de Remesas que es propietario del pack físico de B70POSICION |
| posición diaria | Acumulado de cargos y abonos del día por dimensiones de clasificación |
| CSI | Centro de Servicios Integrados — unidad organizativa del S151 |

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
**ID:** RN-S151-504
**Título:** BD11 — B21SDMENCON1: índice KEYIND para saldos adicionales con 12 OCCURS
**Descripción:** El DATA SET `S151B21SDMENCON1` extiende B20SDOMENCON con un índice adicional `KEYIND` (consecutivo) que permite múltiples registros de saldo para el mismo domicilio/contrato. El registro contiene `OCCURS 12` para acomodar hasta 12 períodos o tipos de saldo por combinación de clave. Esta estructura de 12 ocurrencias sugiere saldos mensuales en un ciclo anual, pero el significado exacto de cada ocurrencia requiere análisis del programa que lo puebla.
**Ente regulador:** CNBV (saldos históricos mensuales requeridos para reportes de captación)
**Evidencia DASDL:**
```
S151B21SDMENCON1: DATA SET ...
  POPULATION IS 12000000.
  KEY IS (KEYAM, KEYCON, KEYPRD, KEYINS, KEYMON, KEYIND).
  FIELDS:
    KEYIND NUMBER(03). % consecutivo de saldo adicional
    % 12 OCCURS de campos de saldo
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| KEYIND | Índice consecutivo dentro de un grupo de saldos — tercer nivel de agrupación |
| OCCURS | Declaración DASDL de arreglo de campos repetidos dentro del registro |
| saldo adicional | Detalle de saldo que complementa el saldo principal en B20SDOMENCON |
| período | Cada ocurrencia del OCCURS 12 puede representar un mes del año fiscal |

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
**ID:** RN-S151-505
**Título:** BD11 — B80EDOCTA: control del estado de cuenta por contrato (5M registros)
**Descripción:** El DATA SET `S151B80EDOCTA` (5M registros, `MEMORY RESIDENT = COARSE`) controla la generación de estados de cuenta. La clave es `(FECCON, PRD, INS, KEYCONT)` donde FECCON es la fecha de corte contractual. Este DATA SET es la fuente de control para P158 — determina qué contratos tienen estado de cuenta pendiente de generación y para qué período. Sin un registro activo en B80EDOCTA, P158 no genera el estado de cuenta del contrato correspondiente.
**Ente regulador:** CNBV (estados de cuenta obligatorios conforme a CUB; CONDUSEF requiere disponibilidad a cliente)
**Evidencia DASDL:**
```
S151B80EDOCTA: DATA SET ...
  POPULATION IS 5000000.
  MEMORY RESIDENT = COARSE.
  KEY IS (FECCON, PRD, INS, KEYCONT).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B80EDOCTA | DATA SET de control de estado de cuenta — governa generación por contrato |
| FECCON | Fecha de corte contractual — determina el período del estado de cuenta |
| KEYCONT | Clave del contrato — 16 dígitos numéricos en S151 |
| estado de cuenta | Documento de movimientos por período enviado al cliente; obligatorio CNBV/CONDUSEF |
| período de corte | Intervalo (usualmente mensual) cubierto por el estado de cuenta |

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
**ID:** RN-S151-506
**Título:** BD11 — Fechas de 8 dígitos post-CRONOS2K en B00 global
**Descripción:** El campo `FEC` en el B00 global de BD11 tiene 8 dígitos (CCAAMMDD) después de la renovación CRONOS2K. Antes de la renovación era 6 dígitos (AAMMDD). Los comentarios `*INICIA CODIGO DE RENOVACION CRONOS 2000` y `*TERMINA CODIGO DE RENOVACION CRONOS 2000` delimitan los cambios. Cualquier programa que lea FEC con formato de 6 dígitos producirá errores silenciosos de fecha. El campo B00.FEC controla la fecha de proceso vigente de la BD.
**Ente regulador:** N/A (corrección de año 2000 — administrativa)
**Evidencia DASDL:**
```
% Antes CRONOS2K:
*  FEC NUMBER(06). % AAMMDD
% Después CRONOS2K:
   FEC NUMBER(08). % CCAAMMDD
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| CRONOS2K | Proyecto de renovación Y2K del sistema S151 — cambio de fechas 6→8 dígitos |
| FEC | Fecha de proceso vigente en el bloque global B00 de la BD |
| B00 | Bloque global de control de la base de datos DMSII — un solo registro |
| CCAAMMDD | Formato de fecha de 8 dígitos: siglo+año+mes+día |
| AAMMDD | Formato de fecha de 6 dígitos pre-Y2K: año(2)+mes+día — obsoleto en S151 |

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
**ID:** RN-S151-507
**Título:** BD11 — PACKNAME=S067REMESAS: dependencia de storage entre S151 y S067
**Descripción:** El DATA SET `S151B70POSICION` referencia `PACKNAME = S067REMESAS`, indicando que los datos de posición diaria de S151 residen físicamente en los discos del pack del sistema S067 (Remesas). Esta dependencia de storage entre sistemas implica que: (1) el schedule de respaldo de S067 afecta a S151 B70; (2) la reorganización de BD70 requiere coordinación con el equipo de S067; (3) en un escenario de migración, B70POSICION no puede migrarse de forma independiente sin acordar la separación del pack con S067.
**Ente regulador:** N/A (dependencia arquitectónica de storage)
**Evidencia DASDL:**
```
S151B70POSICION: DATA SET ...
  PACKNAME = S067REMESAS.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| PACKNAME | Nombre del grupo de discos físicos (pack) donde el DATA SET reside |
| S067 | Sistema de Remesas — propietario del pack físico S067REMESAS |
| S067REMESAS | Identificador del pack de discos — convención de nombrado S151: sistema+propósito |
| dependencia de storage | Acoplamiento entre sistemas a nivel de almacenamiento físico |
| reorganización | Proceso DMSII de reconstrucción de índices y reempaquetado de datos |

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

### RN-S151-508
**ID:** RN-S151-508
**Título:** BD12 — Tres conjuntos paralelos independientes: OK(25M), INFO(5M), ERROR(5M)
**Descripción:** La base BD12 implementa un patrón tripartita: `S151B01MOVCTO` (OK, 25M), `S151B11MOVINFCTO` (INFO, 5M), `S151B51MOVERRCTO` (ERROR, 5M). Estos tres conjuntos son estructuralmente idénticos pero físicamente independientes — cada uno con su propia población, índices y tablas de extensión (IMPADI, DATADI, CONDATADI). La distribución de población refleja la tasa esperada de resultados: ~71% OK, ~14% INFO, ~14% ERROR. No pueden colapsarse en una sola tabla sin perder los SLOs diferenciados y la semántica de cada conjunto.
**ALERTA MIGRACIÓN:** [CRÍTICO] En modelo relacional, la tripartita debe implementarse con una columna discriminante (`tipo_resultado` = OK/INFO/ERROR) o con tres tablas físicas separadas. Una sola tabla unificada con índice en `tipo_resultado` puede cumplir la semántica, pero los volúmenes diferenciados (25M vs 5M) sugieren tablas separadas para performance.
**Ente regulador:** CNBV (movimientos INFO y ERROR requieren gestión y reporte separado de excepciones)
**Evidencia DASDL:**
```
S151B01MOVCTO:     DIRECT DATA SET POPULATION IS 25000000.  % OK
S151B11MOVINFCTO:  DIRECT DATA SET POPULATION IS  5000000.  % INFO
S151B51MOVERRCTO:  DIRECT DATA SET POPULATION IS  5000000.  % ERROR
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| tripartita | Patrón de BD12 con tres conjuntos paralelos por tipo de resultado (OK/INFO/ERROR) |
| B01MOVCTO | Conjunto OK de movimientos por contrato — 25M registros exitosos |
| B11MOVINFCTO | Conjunto INFO — 5M movimientos con información adicional requerida |
| B51MOVERRCTO | Conjunto ERROR — 5M movimientos con error de procesamiento |
| discriminante | Columna que identifica el tipo de registro en una tabla unificada equivalente |
| SLO diferenciado | Acuerdo de nivel de servicio distinto por tipo de conjunto |

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
**ID:** RN-S151-509
**Título:** BD12 — SECTOR NUMBER(02) y BANCA NUMBER(02): dimensiones regulatorias obligatorias
**Descripción:** El DATA SET `S151B01MOVCTO` (y sus equivalentes INFO/ERROR) contiene los campos `SECTOR NUMBER(02)` y `BANCA NUMBER(02)` dentro del registro principal. SECTOR clasifica la contraparte según el catálogo regulatorio CNBV (instituciones financieras, gobierno, empresas, personas físicas, etc.). BANCA clasifica la línea de negocio bancaria. Ambos campos son necesarios para los reportes regulatorios R04C y R27C de la CNBV. Su ausencia o valor incorrecto invalida la clasificación del portafolio en los reportes.
**Ente regulador:** CNBV (SECTOR y BANCA son campos obligatorios en CUB Anexo 33 para clasificación de contraparte y línea de negocio)
**Evidencia DASDL:**
```
S151B01MOVCTO: DATA SET ...
  SECTOR NUMBER(02).
  BANCA  NUMBER(02).
  STAMOV NUMBER(02). % Estado del movimiento
  INDIMP NUMBER(02). % Indicador de impuesto
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| SECTOR | Sector económico de la contraparte; 2 dígitos según catálogo CNBV |
| BANCA | Línea de negocio bancaria; 2 dígitos |
| STAMOV | Estado del movimiento por contrato (activo/histórico) en BD12 |
| INDIMP | Indicador de impuesto aplicable al movimiento |
| R04C | Reporte de captación CNBV con desagregación por sector |
| CUB Anexo 33 | Catálogo de sectores y clasificaciones de contraparte de la CNBV |

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
**ID:** RN-S151-510
**Título:** BD12 — Claves de acceso: por contrato-secuencia y por fecha-valor
**Descripción:** El conjunto OK de BD12 tiene dos índices primarios: `B01SXMOVCTO` con clave `(FECCON, KEYCONT, SEC)` para acceso por contrato en fecha de corte, y `B01SXFCHVAL` con clave `(PRD, INS, KEYCONT, FECVAL, SEC)` para acceso por fecha de valor. Un tercer índice `B01SXMOVSEC` accede directamente por `SEC` (secuencial global). El campo SEC es el número de secuencia del movimiento dentro del conjunto OK — es diferente al AUTS151 de BD10. La combinación FECCON+KEYCONT+SEC garantiza unicidad dentro del período de corte.
**Ente regulador:** N/A (regla estructural de acceso)
**Evidencia DASDL:**
```
B01SXMOVCTO: ACCESS TO S151B01MOVCTO
  KEY IS (FECCON, KEYCONT, SEC).
B01SXFCHVAL: SET OF S151B01MOVCTO
  KEY IS (PRD, INS, KEYCONT, FECVAL, SEC).
B01SXMOVSEC: ACCESS TO S151B01MOVCTO
  KEY IS SEC.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| FECCON | Fecha de corte contractual — período al que pertenece el movimiento en BD12 |
| KEYCONT | Clave del contrato; 16 dígitos en BD12 |
| SEC | Número de secuencia del movimiento en el conjunto OK — diferente a AUTS151 |
| FECVAL | Fecha valor — fecha en que el movimiento tiene efecto económico |
| SET OF | Índice DMSII que permite múltiples registros por clave (equivalente a non-unique index) |

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
**ID:** RN-S151-511
**Título:** BD12 — Extensiones del registro OK: IMPADI + DATADI (LEY1+REFLOCBNM) + CONDATADI (LEY2-5)
**Descripción:** Cada movimiento OK en `S151B01MOVCTO` puede tener hasta tres registros de extensión: `S151B02IMPADI` (importes adicionales, 12.5M), `S151B03DATADI` (datos adicionales con `LEY1 ALPHA(40)`, `REFLOCBNM` y `FILXAPL`, 12.5M), y `S151B04CONDATADI` (leyendas 2-5: `LEY2..LEY5 ALPHA(40)`, 12.5M). La leyenda completa de un movimiento requiere ensamblar hasta 5 leyendas (LEY1 de DATADI + LEY2-5 de CONDATADI). El campo `REFLOCBNM` es la referencia local del banco emisor — identificador de la transacción en el sistema origen.
**Ente regulador:** CNBV (leyendas de transacción son parte del comprobante de operación)
**Evidencia DASDL:**
```
S151B03DATADI: DATA SET
  POPULATION IS 12500000.
  FIELDS: LEY1 ALPHA(40), REFLOCBNM, FILXAPL.
S151B04CONDATADI: DATA SET
  POPULATION IS 12500000.
  FIELDS: LEY2..LEY5 ALPHA(40 each).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| IMPADI | Importes adicionales del movimiento OK en BD12 (12.5M registros) |
| DATADI | Datos adicionales con la primera leyenda y referencias del movimiento |
| CONDATADI | Leyendas adicionales 2-5 del movimiento |
| REFLOCBNM | Referencia local del banco emisor — identificador en sistema origen |
| FILXAPL | Filigrana o identificador de aplicación del movimiento |
| LEY1..LEY5 | Leyendas de descripción de la transacción; X(40) cada una |

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
**ID:** RN-S151-512
**Título:** BD12 — INFO y ERROR tienen sus propias extensiones con menor población (2.5M c/u)
**Descripción:** Los conjuntos INFO (`S151B11MOVINFCTO`) y ERROR (`S151B51MOVERRCTO`) tienen sus propias tablas de extensión independientes: INFO usa `B12IMPINFADI` + `B13DATINFADI` + `B14CONDATADI` (2.5M cada una); ERROR usa `B52IMPADIERR` + `B53DATADIERR` + `B54CONDATERR` (2.5M cada una). Las poblaciones menores (2.5M vs 12.5M en OK) reflejan que INFO y ERROR tienen menor tasa de extensiones por registro. En migración, las 9 tablas de BD12 (3 principales + 6 de extensión) deben modelarse con sus relaciones de FK correctas por tipo de resultado.
**Ente regulador:** N/A (regla de storage diferenciado por tipo de resultado)
**Evidencia DASDL:**
```
% INFO:
S151B12IMPINFADI: DATA SET POPULATION IS 2500000.
S151B13DATINFADI: DATA SET POPULATION IS 2500000.
S151B14CONDATADI: DATA SET POPULATION IS 2500000.
% ERROR:
S151B52IMPADIERR: DATA SET POPULATION IS 2500000.
S151B53DATADIERR: DATA SET POPULATION IS 2500000.
S151B54CONDATERR: DATA SET POPULATION IS 2500000.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B12IMPINFADI | Importes adicionales del conjunto INFO |
| B52IMPADIERR | Importes adicionales del conjunto ERROR |
| movimiento INFO | Movimiento que requiere información adicional antes de ser aplicado definitivamente |
| movimiento ERROR | Movimiento que falló en validación y requiere corrección o reproceso |
| FK | Foreign Key — relación referencial de extensión hacia el registro principal |

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
**ID:** RN-S151-513
**Título:** BD12 — Contadores SECOK/SECINF/SECERR en B00 global para trazabilidad de secuencias
**Descripción:** El bloque global B00 de BD12 mantiene tres contadores de secuencia: `SECOK` (últimas secuencias OK asignadas), `SECINF` (INFO) y `SECERR` (ERROR). Estos contadores garantizan la unicidad de SEC dentro de cada conjunto y permiten reconstruir la secuencia de procesamiento de movimientos al auditar. En un día de operación, SECOK crece más rápidamente que SECINF y SECERR. Los contadores son reiniciados al inicio de cada período de corte según la lógica del B00.
**Ente regulador:** CNBV (secuencias de movimiento son parte del trail de auditoría requerido)
**Evidencia DASDL:**
```
% En B00 de BD12:
  SECOK  NUMBER(08). % Último SEC asignado a movimientos OK
  SECINF NUMBER(08). % Último SEC asignado a movimientos INFO
  SECERR NUMBER(08). % Último SEC asignado a movimientos ERROR
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| SECOK | Contador de secuencia de movimientos OK en BD12 — controla unicidad de SEC |
| SECINF | Contador de secuencia de movimientos INFO |
| SECERR | Contador de secuencia de movimientos ERROR |
| B00 | Registro único de control global de la BD DMSII |
| audit trail | Secuencia trazable de operaciones — requerido por CNBV para auditoría |

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

### RN-S151-514
**ID:** RN-S151-514
**Título:** BD13 — AUT-PC NUMBER(12) en B07PROTCOB es diferente a AUTS151 NUMBER(08) [CRÍTICO]
**Descripción:** El DATA SET `S151B07PROTCOB` (Protección de Cobro, 150M registros) usa el campo `B07-AUT-PC NUMBER(12)` como identificador de autorización — 12 dígitos versus los 8 dígitos de AUTS151 en BD10. Estos son espacios de numeración completamente diferentes. No existe una relación directa 1:1 entre AUT-PC y AUTS151 para el mismo movimiento. AUT-PC es asignado por el sistema de protección de cobro, mientras que AUTS151 es asignado por el motor de movimientos S151. Asumir que tienen el mismo valor o longitud produce errores de lookup silenciosos.
**ALERTA MIGRACIÓN:** [CRÍTICO] En modelo relacional, la FK entre B07PROTCOB y BD10 no puede ser por AUT-PC = AUTS151 directamente. Requiere campo de cruce explícito o tabla de equivalencia.
**Ente regulador:** Banxico (protección de cobro es parte del servicio de domiciliación regulado)
**Evidencia DASDL:**
```
S151B07PROTCOB: DATA SET
  POPULATION IS 150000000.
  KEY IS B07-AUT-PC.
  B07-AUT-PC NUMBER(12). % 12 dígitos — diferente de AUTS151(08)
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| AUT-PC | Autorización de protección de cobro; NUMBER(12) — diferente longitud que AUTS151 |
| B07PROTCOB | DATA SET de Protección de Cobro — 150M registros, índices múltiples |
| protección de cobro | Servicio que garantiza el cobro de pagos domiciliados aunque la cuenta no tenga fondos |
| AUTS151 | Autorización S151 estándar; NUMBER(08) — no equivalente a AUT-PC |
| espacio de numeración | Rango de valores válidos para un identificador — AUT-PC y AUTS151 son espacios distintos |

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
**ID:** RN-S151-515
**Título:** BD13 — B07PROTCOB STATUS: 6 valores que codifican el ciclo de vida de protección
**Descripción:** El campo STATUS en `S151B07PROTCOB` tiene 6 valores válidos que representan el ciclo completo de vida de una instrucción de protección de cobro: 0=pendiente de envío, 1=enviado a banco receptor, 2=confirmado por banco receptor, 3=enviado para reversa, 4=reversa confirmada, 5=eliminado sin enviar. El subset `B07SXAUTPROC` filtra `WHERE STATUS IN (0, 1, 2)` — los estados procesables activos. Estados 3-5 son estados terminales o de reversa. La población de 150M refleja el histórico acumulado de instrucciones.
**Ente regulador:** Banxico (el ciclo de vida de instrucciones de domiciliación tiene requerimientos de retención y auditoría regulatoria)
**Evidencia DASDL:**
```
S151B07PROTCOB: DATA SET POPULATION IS 150000000.
  STATUS NUMBER(02).
  % 0=pendiente, 1=enviado, 2=confirmado, 3=enviado_rev, 4=conf_rev, 5=elim_no_env
B07SXAUTPROC: SUBSET OF S151B07PROTCOB
  WHERE STATUS IN (0, 1, 2).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| STATUS | Estado de la instrucción de protección de cobro; 6 valores posibles |
| B07SXAUTPROC | Subset de instrucciones procesables (STATUS 0, 1, 2) |
| reversa | Instrucción de cancelación o devolución de una protección de cobro |
| TYPE-MOV | Tipo de movimiento en B07: 1=alta, 2=eliminación |
| ciclo de vida | Secuencia de estados válidos que atraviesa una instrucción de protección |

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
**ID:** RN-S151-516
**Título:** BD13 — B10DOMI (Domiciliación, 150M, EXTENDED=TRUE): fecha juliana y cross-reference S702
**Descripción:** El DATA SET `S151B10DOMI` (domiciliación, 150M registros, `EXTENDED = TRUE`) contiene `AUTD-FECJUL` (fecha en formato juliano) y `AUTD-AUT702` (autorización del sistema S702 para domiciliación). La directiva `EXTENDED = TRUE` permite que B10DOMI tenga más de 65,536 registros en la versión de DMSII del S151. El campo AUTD-AUT702 permite el cross-reference con el sistema S702 (servicio de domiciliación externa), habilitado por el subset `B10SXFAUTAP702`. Esta relación cruzada con S702 debe modelarse como FK en migración.
**Ente regulador:** Banxico (domiciliación bancaria regulada por Banxico en el marco del servicio de pagos domiciliados)
**Evidencia DASDL:**
```
S151B10DOMI: DATA SET
  POPULATION IS 150000000.
  EXTENDED = TRUE.
  AUTD-FECJUL  NUMBER(07). % Fecha juliana
  AUTD-AUT702  NUMBER(08). % Autorización en S702
B10SXFAUTAP702: SET OF S151B10DOMI
  KEY IS (AUTD-AUT702, STATUS, ...).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B10DOMI | DATA SET de instrucciones de domiciliación — 150M registros |
| EXTENDED | Directiva DMSII que permite más de 65K registros en datasets pre-64bit |
| AUTD-FECJUL | Fecha en formato juliano (días desde una fecha base) — compacto para cálculos |
| AUTD-AUT702 | Referencia cruzada con el sistema S702 de domiciliación |
| S702 | Sistema externo de procesamiento de domiciliación bancaria |
| domiciliación | Instrucción permanente de cargo automático a cuenta bancaria |

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
**ID:** RN-S151-517
**Título:** BD13 — B04CTLCITIDIR: 16M registros de control de envíos CitiDirect con reintento
**Descripción:** El DATA SET `S151B04CTLCITIDIR` (16M registros) controla los envíos de mensajes a CitiDirect (la plataforma de cash management de Citibank). Contiene `NIO ALPHA(16)` (identificador SPEI), `ESTATUS` y `REINTENTOS` (contador de intentos de envío). Los dos índices — `B04SXSISTFEC` (por sistema+fecha) y `B04SXCTLENVIO` (por control de envío) — permiten reproceso de mensajes fallidos. El campo REINTENTOS es crítico para identificar mensajes en loop de reintento que requieren intervención manual.
**Ente regulador:** Banxico (NIO presente indica que estos mensajes incluyen operaciones SPEI sujetas a reporte)
**Evidencia DASDL:**
```
S151B04CTLCITIDIR: DATA SET
  POPULATION IS 16000000.
  NIO       ALPHA(16).
  ESTATUS   NUMBER(02).
  REINTENTOS NUMBER(03).
B04SXSISTFEC:   SET OF S151B04CTLCITIDIR KEY IS (SISTEMA, FECHA, ...).
B04SXCTLENVIO:  SET OF S151B04CTLCITIDIR KEY IS (...).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B04CTLCITIDIR | Control de envíos a CitiDirect — 16M registros de mensajes |
| CitiDirect | Plataforma de cash management de Citibank — destino de mensajes OCM/BIFIN |
| REINTENTOS | Contador de intentos de envío fallidos — trigger de intervención manual |
| ESTATUS | Estado del envío del mensaje CitiDirect |
| NIO | Identificador SPEI presente en mensajes de transferencia a CitiDirect |

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
**ID:** RN-S151-518
**Título:** BD13 — B08TDMIGCAP: 100M tarjetas débito migradas con STATUS ALPHA(02)
**Descripción:** El DATA SET `S151B08TDMIGCAP` (100M registros) contiene las tarjetas débito migradas al sistema S151 durante el proceso de migración de cuentas. El campo `STATUS ALPHA(02)` toma valores `AC` (activa) o `CA` (cancelada). A diferencia de los demás campos STATUS en BD13 que son numéricos, este es alfanumérico de 2 caracteres. La migración de 100M tarjetas es consistente con la escala del portafolio de cuentas de captación de Banamex. Este DATA SET es de referencia histórica — no crece diariamente sino en eventos de migración masiva.
**Ente regulador:** CNBV (tarjetas activas forman parte del inventario de instrumentos supervisado)
**Evidencia DASDL:**
```
S151B08TDMIGCAP: DATA SET
  POPULATION IS 100000000.
  STATUS ALPHA(02). % 'AC'=activa, 'CA'=cancelada
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B08TDMIGCAP | Tarjetas débito migradas al S151 — 100M registros históricos |
| STATUS ALPHA(02) | Estado de la tarjeta: AC=activa, CA=cancelada — tipo alfanumérico distinto a STATUS numérico |
| tarjeta débito | Instrumento de pago asociado a cuenta de captación |
| migración masiva | Proceso de carga inicial de datos desde sistema origen al S151 |
| AC/CA | Códigos de estado de tarjeta: Active/Cancelled en terminología del sistema |

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

### RN-S151-519
**ID:** RN-S151-519
**Título:** BD99 — B10MOVPORSUC: movimientos por sucursal con MEMORY RESIDENT=COARSE y bloques optimizados
**Descripción:** El DATA SET `S151B10MOVPORSUC` (8M registros, `MEMORY RESIDENT = COARSE`) acumula movimientos clasificados por sucursal. La clave tiene 9 campos (incluyendo dimensiones de sistema, producto, instrumento, moneda, sucursal, tipo y sector). Los parámetros físicos `BLOCKSIZE = 4` y `REBLOCKFACTOR = 5` optimizan el almacenamiento para lectura secuencial masiva en reportes de cierre. REBLOCKFACTOR=5 indica que el tamaño efectivo del bloque en disco es 5× el BLOCKSIZE — técnica de densificación de páginas en DMSII.
**Ente regulador:** CNBV (reportes de movimientos por sucursal forman parte del reporte de operaciones)
**Evidencia DASDL:**
```
S151B10MOVPORSUC: DATA SET
  POPULATION IS 8000000.
  MEMORY RESIDENT = COARSE.
  BLOCKSIZE = 4.
  REBLOCKFACTOR = 5.
  KEY IS (SISTEMA, PRODUCTO, MONEDA, INSTRUMENTO, SUCURSAL, TIPO, SECTOR, ...). % 9 campos
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B10MOVPORSUC | Acumulado de movimientos por sucursal en BD99 |
| BLOCKSIZE | Tamaño del bloque DMSII en páginas de disco |
| REBLOCKFACTOR | Multiplicador del bloque efectivo para densificación de storage |
| densificación | Técnica de empaquetado de registros en menos bloques físicos para mejorar lectura secuencial |
| movimiento por sucursal | Agregado de cargos y abonos clasificado por sucursal de operación |

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
**ID:** RN-S151-520
**Título:** BD99 — B11MOVPORCTE: movimientos por cliente (10M, COARSE, BLOCKSIZE=7)
**Descripción:** El DATA SET `S151B11MOVPORCTE` (10M registros, `MEMORY RESIDENT = COARSE`) acumula movimientos clasificados por cliente. Con `BLOCKSIZE = 7` y `REBLOCKFACTOR = 5`, tiene mayor densidad de bloque que B10MOVPORSUC (BLOCKSIZE=4) — refleja que los registros por cliente son más grandes. La mayor población (10M vs 8M de B10) indica que hay más clientes únicos que sucursales activas en la clasificación. Este DATA SET es insumo para reportes de clientes VIP y análisis de comportamiento de cartera.
**Ente regulador:** CNBV (movimientos por cliente son base de estados de cuenta y reportes de concentración)
**Evidencia DASDL:**
```
S151B11MOVPORCTE: DATA SET
  POPULATION IS 10000000.
  MEMORY RESIDENT = COARSE.
  BLOCKSIZE = 7.
  REBLOCKFACTOR = 5.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B11MOVPORCTE | Acumulado de movimientos por cliente en BD99 |
| cliente | Entidad natural o jurídica con uno o más contratos en S151 |
| BLOCKSIZE=7 | Bloque más grande que B10 (4) — registros por cliente tienen más campos |
| concentración de cartera | Análisis de exposición por cliente — insumo para límites regulatorios CNBV |

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
**ID:** RN-S151-521
**Título:** BD99 — B12POSICION: acumulado de posición con SECTOR y DIAS-SEM(5 ocurrencias)
**Descripción:** El DATA SET `S151B12POSICION` (MEMORY RESIDENT = COARSE) acumula posición por `SISTEMA + PRODUCTO + MONEDA + INSTRUMENTO + CUENTA + SECTOR`. La dimensión SECTOR es obligatoria para clasificación regulatoria. El campo `DIAS-SEM` tiene `OCCURS 5` con subcampos `CARGO` y `ABONO` por cada día — esto permite un mini-histórico de 5 días hábiles de movimientos dentro de un solo registro de posición. Esta estructura evita múltiples lecturas para reconciliar la semana.
**Ente regulador:** CNBV (posición por sector es base para reportes de capital y reservas)
**Evidencia DASDL:**
```
S151B12POSICION: DATA SET
  MEMORY RESIDENT = COARSE.
  KEY IS (SISTEMA, PRODUCTO, MONEDA, INSTRUMENTO, CUENTA, SECTOR).
  DIAS-SEM OCCURS 5 TIMES.
    CARGO  NUMBER(14)V99.
    ABONO  NUMBER(14)V99.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B12POSICION | Acumulado de posición en BD99 con historial de 5 días |
| DIAS-SEM | Arreglo de 5 días hábiles de la semana con cargos y abonos por día |
| posición | Saldo neto acumulado por las dimensiones de clasificación |
| SECTOR | Clasificación regulatoria de la contraparte (2 dígitos, catálogo CNBV) |
| mini-histórico | Retención de 5 días de movimientos en un solo registro — evita lecturas adicionales |

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
**ID:** RN-S151-522
**Título:** BD99 — B14/B15ARCDIA: tracking de archivos origen/destino con filtro BIT VECTOR STAARC=1
**Descripción:** Los DATA SETs `S151B14ARCDIAORI` y `S151B15ARCDIADES` rastrean los archivos de entrada (origen) y salida (destino) del procesamiento diario. Los subsets con `WHERE STAARC = 1` (BIT VECTOR) filtran solo los archivos activos/pendientes de procesar. Los archivos procesados tienen STAARC ≠ 1 y no aparecen en el subset. Esta estructura permite a los programas de control identificar qué archivos faltan o están pendientes sin escanear el DATA SET completo.
**Ente regulador:** N/A (control operativo de procesamiento de archivos)
**Evidencia DASDL:**
```
S151B14ARCDIAORI: DATA SET ...
  STAARC NUMBER(02).
  % Subset activos:
  WHERE STAARC = 1 BIT VECTOR.

S151B15ARCDIADES: DATA SET ...
  STAARC NUMBER(02).
  WHERE STAARC = 1 BIT VECTOR.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B14ARCDIAORI | Tracking de archivos de entrada procesados/pendientes en BD99 |
| B15ARCDIADES | Tracking de archivos de salida generados/pendientes |
| STAARC | Estado del archivo; 1=activo/pendiente |
| BIT VECTOR | Índice bitmap para filtros booleanos — eficiente para STAARC=1 |
| archivo origen | Archivo de entrada al procesamiento diario del S151 |
| archivo destino | Archivo de salida generado por el procesamiento diario |

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

### RN-S151-523
**ID:** RN-S151-523
**Título:** BD02 — HARDCODE-SOSPECHOSO: B03SDOCTE usa NUMERO1(10)+NUMERO2(10) para clave de cliente de 20 dígitos
**Descripción:** El DATA SET `S151B03SDOCTE` (saldos por cliente, 500K registros) divide la clave del cliente en dos campos: `NUMERO1 NUMBER(10)` y `NUMERO2 NUMBER(10)`, formando una clave de 20 dígitos totales. Esta partición artificial sugiere que el campo lógico de 20 dígitos no cabía en un solo tipo numérico de DMSII (los campos numéricos DMSII tienen límites de precisión). En migración, NUMERO1 y NUMERO2 deben concatenarse o reconstruirse como un único identificador de cliente de 20 dígitos antes de mapear a cualquier clave natural del sistema destino.
**ALERTA MIGRACIÓN:** [SOSPECHOSO] Una clave de 20 dígitos de cliente no es estándar en sistemas bancarios mexicanos. Podría ser el número de cuenta extendido, un identificador compuesto (sucursal+cuenta), o herencia de un sistema origen con numeración diferente. Requiere validación con el equipo de negocio.
**Ente regulador:** N/A (regla de storage interno)
**Evidencia DASDL:**
```
S151B03SDOCTE: DATA SET
  POPULATION IS 500000.
  KEY IS (MONEDA, SUCURSAL, SISTEMA, NUMERO1, NUMERO2, INST).
  NUMERO1 NUMBER(10). % Primeros 10 dígitos de la clave de cliente
  NUMERO2 NUMBER(10). % Siguientes 10 dígitos de la clave de cliente
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| NUMERO1 | Primera mitad de la clave de cliente de 20 dígitos; NUMBER(10) |
| NUMERO2 | Segunda mitad de la clave de cliente de 20 dígitos; NUMBER(10) |
| B03SDOCTE | Saldos por cliente en BD02 — 500K registros de tesorería |
| clave compuesta | Identificador formado por concatenación de múltiples campos |
| saldo de tesorería | Posición de efectivo disponible en ventanilla/teller por cliente |

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
**ID:** RN-S151-524
**Título:** BD02 — B14CONOPECRUZ/B15MOVOPECRUZ: MEMORY RESIDENT=ALL para operaciones interbancarias en tiempo real
**Descripción:** Los DATA SETs `S151B14CONOPECRUZ` (concentrado de operaciones cruzadas, 100K registros) y `S151B15MOVOPECRUZ` (movimientos individuales de operaciones cruzadas) usan `MEMORY RESIDENT = ALL` — la totalidad de sus páginas permanece en memoria principal. Esto contrasta con el COARSE usado en otros DATA SETs. El uso de ALL indica que estas operaciones cruzadas entre bancos tienen requerimientos de latencia ultra-baja que justifican la memoria completa. Los campos `BNM/OTR cargos/abonos/LIQ/DIF` y `AUTS151` permiten reconciliación interbancaria en tiempo real.
**Ente regulador:** Banxico (operaciones interbancarias en tiempo real son parte del SPEI y requieren disponibilidad inmediata)
**Evidencia DASDL:**
```
S151B14CONOPECRUZ: DATA SET
  POPULATION IS 100000.
  MEMORY RESIDENT = ALL.
  KEY IS (BCO_ORI, BCO_DES, HORA, FECHA_MQ).
  FIELDS: BNM cargos/abonos, OTR cargos/abonos, LIQ, DIF, DIFGLO, AUTS151.

S151B15MOVOPECRUZ: DATA SET
  MEMORY RESIDENT = ALL.
  KEY IS (HORA, FECHA_MQ, ...).
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B14CONOPECRUZ | Concentrado de operaciones interbancarias cruzadas — 100K registros |
| B15MOVOPECRUZ | Detalle individual de cada operación cruzada interbancaria |
| MEMORY RESIDENT=ALL | Todas las páginas del DATA SET permanecen en memoria — latencia mínima |
| BCO_ORI / BCO_DES | Banco origen y destino de la operación interbancaria |
| LIQ | Importe de liquidación neta de la operación cruzada |
| DIF / DIFGLO | Diferencias individuales y globales de conciliación interbancaria |
| operación cruzada | Transacción que involucra dos bancos (Banamex + contraparte) |

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
**ID:** RN-S151-525
**Título:** BD02 — B08GLOSAR: saldos SAR globales con desglose por fondo y tipo de aportación
**Descripción:** El DATA SET `S151B08GLOSAR` contiene saldos globales del Sistema de Ahorro para el Retiro (SAR) con desglose completo: `IMSS`, `ISSSTE`, `INFONAVIT`, `FOVISSSTE`, `PEMEX` como organismos de aportación; y por tipo: `obligatoria`, `voluntaria`, `inflación`, `intereses`, `saldo_anterior`, `saldo_actual`, `recargos`. Este DATA SET es el insumo para los reportes de coordinación de pensiones con los institutos de seguridad social. La presencia en BD02 (tesorería) indica que S151 gestiona los flujos SAR a través de la tesorería del banco.
**Ente regulador:** CNBV + Banxico (SAR es regulado por CONSAR pero los flujos bancarios son supervisados por CNBV y Banxico; IMSS/ISSSTE son obligaciones regulatorias de las cuentas individuales)
**Evidencia DASDL:**
```
S151B08GLOSAR: DATA SET ...
  FIELDS:
    IMSS, ISSSTE, INFONAVIT, FOVISSSTE, PEMEX. % Por organismo
    % Subcampos: obligatoria, voluntaria, inflacion, intereses,
    %            saldo_ant, saldo_act, recargos.
```
**Vocabulario relacionado:**

| Término | Definición |
|---------|-----------|
| B08GLOSAR | Saldos globales SAR en BD02 tesorería |
| SAR | Sistema de Ahorro para el Retiro — cuentas individuales de pensión |
| IMSS | Instituto Mexicano del Seguro Social — organismo de aportación principal |
| ISSSTE | Instituto de Seguridad Social al Servicio de los Trabajadores del Estado |
| INFONAVIT | Instituto del Fondo Nacional de la Vivienda para los Trabajadores |
| FOVISSSTE | Fondo de la Vivienda del ISSSTE |
| PEMEX | Petróleos Mexicanos — con fondo SAR propio |
| CONSAR | Comisión Nacional del Sistema de Ahorro para el Retiro — regulador del SAR |
| aportación obligatoria | Contribución patronal y del trabajador mandatada por ley |
| aportación voluntaria | Contribución adicional discrecional del trabajador |

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