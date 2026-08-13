# Informix · Base de Conocimiento del Vocabulario SPL

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base:** IBM Informix IDS 14.10 FC10W2 / POWER-AIX · **Corpus:** 10,144 SPs · 16 dominios (D01-D16)
> **Última actualización:** 2026-08-02 · colaboración swarm de DTs peer (v2)

Documento de referencia curado que explica **cómo leer los nombres de los stored procedures de BanCoppel** y el sistema de vocabulario que los interpreta. Complementa al inventario auto-generado [`vocabulary-inventory-bcop.md`](vocabulary-inventory-bcop.md) (las tablas de términos) con el **conocimiento de dominio** necesario para interpretarlos.

---

## 0 · Contexto de negocio BanCoppel

> Investigado en fuentes públicas (bancoppel.com, CONDUSEF, Banxico) el 2026-07-03 para dar sentido de negocio al vocabulario. Ver **Fuentes** al final.

**Qué es BanCoppel.** Institución de banca múltiple mexicana, subsidiaria de **Grupo Coppel** (Coppel Capital), creada en 2007. Enfoque en **banca de consumo e inclusión financiera** para la base de la pirámide y clase media — *"banca que funciona, sin tecnicismos ni opacidad"*. Escala: **~1,372 sucursales · ~2,203 cajeros propios** · red de depósito/retiro en tiendas Coppel y OXXO. **Afore Coppel** es la 2ª administradora de retiro más grande de México (~14.5M cuentas). Su modelo está entrelazado con la tienda departamental Coppel y su **crédito quincenal**.

**Productos → dominios del core** (así se mapea el negocio al código):

| Producto de negocio | Descripción | Dominio(s) Informix |
|---------------------|-------------|---------------------|
| Cuenta Efectiva Digital · Nómina | Débito, sin comisión, PIN dinámico, retiro sin tarjeta | D04 `bdicheq` · D05 `bdisac` |
| Tarjeta de Crédito (VISA / Básica) | Sin anualidad; MSI 3–24 meses en comercios afiliados y Coppel | D03 `bdicred` |
| Préstamo Personal / Nómina / Digital | Crédito al consumo; Digital hasta ~$47K desde el celular | D03 `bdicred` · D06 `bdisolic` |
| Crédito Coppel (tienda) | Compra a plazos **quincenales** (24–72 quincenas) | D03 · D11 `bdicobranza` |
| Hipoteca digital | Crédito hipotecario (desde 2025) | D03 |
| Afore Coppel | Ahorro para el retiro | externo · `sp_inserta_msjafore` (D02/D04) |
| Remesas internacionales | Western Union / MoneyGram; depósito a cuenta o ventanilla | D04 · externo |
| Inversión | Pagaré / plazo | D05 |
| SPEI · CoDi · TEF · domiciliación | Pagos y transferencias | D08 `bdispei` · D04 |

**Canales:** **BPI** = *Banca Por Internet* (web) · **App BanCoppel** ("BanCoppel Móvil", iOS/Android) · **IVR** (telefónico) · sucursales · cajeros · red Coppel/OXXO. Esto explica los sufijos de canal en los nombres de SP: `_bpi`, `_web`, `_mvl`, `_cel`, `_app`.

---

## 1 · Por qué existe este vocabulario

En un sistema *"base de datos como aplicación"* como Informix, la lógica de negocio vive como **13,223 stored procedures** cuyos nombres son la única pista inmediata de su propósito (no hay capa de servicios documentada). Los nombres son **morfemas concatenados en español** con notación abreviada — `spei_aplicaordenpago`, `sp_cont_cargamovimientob3`, `sp_fal_busca_pagares_cliente`.

El vocabulario ([`sp_vocab.py`](../../generators/sp_vocab.py)) descompone esos nombres en términos con significado, permitiendo **inferir el objetivo de cualquier SP sin leer su código** — y priorizar cuáles sí requieren lectura manual (los ambiguos). Es la base de la Etapa 3 y alimenta el catálogo de journeys y el inventario de términos.

---

## 2 · Anatomía de un nombre de SP

```
sp_cont_cargamovimientob3
│  │    │            └─ sufijo técnico (versión/bloque — AMBIGUO)
│  │    └─ ACCIÓN + ENTIDAD  (carga + movimiento)
│  └─ PREFIJO de familia    (cont = contabilidad)
└─ PREFIJO de tipo          (sp = stored procedure)

REGLA DE COMPOSICIÓN DEL OBJETIVO:
  [ACCIÓN principal] + [ENTIDAD(es)] + ([MODIFICADOR(es)]) + [· REGULATORIO]

Ejemplos:
  spei_aplicaordenpago              → "aplica orden de pago" (SPEI)
  sp_fal_busca_pagares_cliente      → "busca pagarés + cliente"
  sp_consreportesctasinactivasart61 → "consulta reportes cuentas inactivas · Art.61 LIC"
  cargo_ref                         → "cargo / débito"
```

Los términos se clasifican en **6 categorías**: `PREFIJO` (familia), `ACCION` (verbo), `ENTIDAD` (objeto de negocio), `MODIF` (modificador), `REG` (regulatorio), `AMBIGUO` (requiere SME).

---

## 3 · Prefijos de familia (mapean a dominio)

El segundo token suele indicar la familia funcional / dominio dueño:

| Prefijo | Familia | Dominio | Confiab. |
|---------|---------|---------|:--:|
| `sp_` / `fn_` | SP genérico / función | — | 🟢 |
| `spei_` | pagos SPEI interbancarios | D08 | 🟢 |
| `sp_cont_` | contabilidad general | D12 | 🟢 |
| `sp_cam_` | cámara / captura contable | D12 | 🟡 |
| `sp_acl_` | aclaraciones y disputas | D07 | 🟢 |
| `sp_fal_` | faltantes / documentación de expediente | D07 | 🟡 |
| `sp_ciloc` | consulta local de cobranza | D11 | 🟡 |
| `sp_cnsif_` | consulta SIF (bus de integración) | D02 | 🟡 |
| `sp_cac_` | originación / evaluación de crédito | D03 | 🟡 |
| `sp_mon_` | monitor / módulo de consulta | varios | 🟡 |
| `sp_dicta_` | dictamen (crédito / aclaración) | D03/D07 | 🟡 |
| `sp_soe_` | prefijo SOE (bdibei) | — | 🔴 `[CONSULTAR→NEGOCIO]` |

---

## 4 · Notación húngara en parámetros

Los parámetros usan un prefijo de **1 letra que codifica el tipo Informix** — clave para minar el vocabulario desde las firmas (`mine-source.py` lo remueve para extraer el morfema):

| Prefijo | Tipo Informix | Ejemplo |
|:--:|---|---|
| `p` | **parámetro** (todos lo llevan) | `pcuenta`, `pmonto` |
| `c` | `CHAR` / `VARCHAR` | `cCveRastreo` |
| `v` | variable / `VARCHAR` | `vsaldo`, `vchr…` |
| `i` | `INTEGER` / `SMALLINT` | `iContador`, `iExiste` |
| `m` | `MONEY` | `mMonto` |
| `d` / `dt` | `DATE` / `DATETIME` | `dFechaVal` |
| `w` | variable de **w**ork (trabajo) | `wvchrcuentaord` |
| `n` | numérico | `nImporte` |

> Los tokens `pvchr`, `pchr`, `pint` que aparecen como "candidatos" en el inventario son artefactos de esta notación (prefijo `p` + tipo `vchr`/`chr`/`int`) — no son términos de negocio.

---

## 5 · Glosario de acrónimos bancarios MX

Conocimiento de dominio curado — los acrónimos que aparecen embebidos en nombres y que **no son obvios fuera de banca mexicana**:

| Acrónimo | Significado | Contexto |
|----------|-------------|----------|
| **SPEI** | Sistema de Pagos Electrónicos Interbancarios | Banxico · irrevocable · D08 |
| **TEF** | Transferencia Electrónica de Fondos | interna / entre bancos |
| **CoDi** | Cobro Digital (QR) | Banxico |
| **CLABE** | Clave Bancaria Estandarizada (18 díg.) | interbancaria |
| **TDC / TDD** | Tarjeta de Crédito / Débito | — |
| **MSI** | Meses Sin Intereses | promociones crédito |
| **AFORE** | Administradora de Fondos para el Retiro | `sp_inserta_msjafore` |
| **UDI** | Unidad de Inversión | cobertura IPAB (400K UDIs) |
| **RECO** | Registro de Contratos de Adhesión | CONDUSEF · comisiones |
| **CAT** | **Costo Anual Total** | ⚠ CONDUSEF — *no confundir con `cat`=catálogo* |
| **GAT** | Ganancia Anual Total | inversión / ahorro |
| **SBC** | Saldo Básico de Cuenta | `[CONSULTAR→NEGOCIO]` (¿o Saldo Bloqueado?) |
| **BTS** | Beneficiarios de Transferencias | nómina gobierno · `sp_validanombenefbts` |
| **RFC / CURP** | identificadores fiscal / poblacional | KYC · SAT |
| **IVR** | Interactive Voice Response | canal telefónico |
| **POS / ATM** | punto de venta / cajero automático | canales físicos |
| **SOC** | **Sistema Operativo Central** | sufijo `_soc` = SP que interactúa con el SOC · confirmado SME 2026-07-03 |
| **BPI** | **Banca Por Internet** (canal web) | confirmado web BanCoppel · sufijo `_bpi` |
| **CEP** | Comprobante Electrónico de Pago | SPEI · Banxico · rastreo de transferencia |
| **Clave de rastreo** | ID de hasta 30 posiciones alfanuméricas de una orden SPEI | Banxico |
| **N° de referencia** | número de hasta 7 dígitos que elige el usuario en un pago | Banxico |
| **BYM** | *hipótesis:* Billetes y Monedas (manejo de efectivo en sucursal) | 🔴 `[CONSULTAR→NEGOCIO]` — visto en `sp_consultadatospiezas_bym3` (D10) |
| **Coppel Max** | programa de recompensas/cashback por compras y abonos | posible lectura de `max` (vs. límite máximo) |

**Reguladores** (marcan un término como `REG`): **CNBV** · **Banxico** · **CONDUSEF** · **SAT** · **TESOFE** · **IPAB**.

**Términos regulatorios embebidos detectados:** `art61` (Art.61 LIC — cuentas inactivas 3 años → beneficencia), `codi`, `comision` (RECO CONDUSEF), `iva`/`impuesto` (SAT), `spei`/`rastreo` (Banxico).

---

## 6 · Niveles de confiabilidad

Cada término tiene un estado que refleja **qué tan seguro es su significado**:

| Nivel | Estado interno | Criterio | Acción |
|-------|:--:|----------|--------|
| 🟢 **Alta** | `conf` | Confirmado por código (aparece como parámetro explícito frecuente) o significado inequívoco | Usar directo |
| 🟡 **Media** | `inf` | Inferido por convención de nomenclatura, sin confirmación de código | Usar con reserva |
| 🔴 **Ambigua** | `gap` | Múltiples significados posibles | `[CONSULTAR→NEGOCIO/DBA]` |
| ⚪ **Candidato** | — | Fragmento frecuente aún sin clasificar | Próxima iteración |

> **La evidencia dura es la columna `frec-par`** del inventario: un término que aparece como *parámetro* muchas veces (ej. `numcliente` con 131) está confirmado por el código, no adivinado. Un término que solo aparece en *nombres* (`frec-nom`) es inferencia.

**Estado actual:** 707 términos — 586 atómicos · 61 compuestos · 60 candidatos. Evidencia dura (frec-par > 0) en ~290 términos. Las secciones 11-14 de este documento incorporan contribuciones del swarm de DTs peer.

---

## 7 · Ambigüedades conocidas `[CONSULTAR→NEGOCIO/DBA]`

Términos que **no se deben resolver sin el SME de BanCoppel** — cada uno tiene ≥2 lecturas plausibles:

| Término | Lecturas posibles |
|---------|-------------------|
| `cat` | catálogo **vs** CAT (Costo Anual Total, CONDUSEF) — el contexto decide |
| `sbc` | Saldo Básico de Cuenta **vs** Saldo Bloqueado |
| `trans` | transacción **vs** transferencia |
| `cap` | captura **vs** captación **vs** capacidad |
| `seg` | seguro **vs** seguridad **vs** segundo |
| `b3` / `b4` / `b5` | versión de release **vs** número de bloque **vs** fase contable |
| `bym` / `bym2` / `bym3` | acrónimo de módulo (sucursales) sin expansión |
| `imp` | importe **vs** impuesto **vs** impresión |
| `mesa` | mesa de control **vs** mesa de dinero |
| `pba` · `tco` · `bpi` · `mc` · `adn` | acrónimos sin expansión confirmada |

---

## 8 · Cómo extender el vocabulario

El vocabulario es **iterativo y colaborativo**. Ciclo de mejora:

```
1. Revisar Sección C del inventario (candidatos sin clasificar, ordenados por frecuencia)
2. Validar significado con el SME de negocio / DBA
3. Agregar el término a sp_vocab.py:
      "termino": ("CATEGORIA", "significado", "conf|inf|gap"),
4. Re-correr el pipeline (abajo) → journeys, catálogo e inventario se actualizan
```

Cada candidato clasificado **sube la cobertura de todos los SPs que lo contienen** y reduce el ruido de fragmentación (ej. agregar `expediente` elimina el fragmento `pediente`).

### Pipeline reproducible (orden de ejecución)

```
sp_vocab.py  (fuente única del vocabulario — editar aquí; en root de Informix)
   │
   ├─ python extract-journeys.py        → journeys-data.json (journeys + objetivos)
   ├─ python mine-source.py             → enriquece con evidencia del código fuente
   ├─ python build-catalog.py           → journeys-catalog-bcop.md
   ├─ python build-vocab-inventory.py   → knowledge-base/vocabulary/vocabulary-inventory-bcop.md
   │                                       vocabulary-inventory.json  ← root (contrato de pipeline)
   ├─ python build-vocab-report.py      → vocabulary-report-bcop.html (reporte v1)
   └─ python build-vocab-report-v2.py   → vocabulary-report-bcop-v2.html (reporte v2 — BC + aggregate roots)
```

---

## 9 · Artefactos relacionados

| Archivo | Contenido |
|---------|-----------|
| [`sp_vocab.py`](../../generators/sp_vocab.py) | **Fuente del vocabulario** (438 términos) + funciones `segment` / `compose` |
| [`vocabulary-inventory-bcop.md`](vocabulary-inventory-bcop.md) | Inventario tabular: átomos, compuestos, candidatos, confiabilidad |
| [`vocabulary-inventory.json`](../vocabulary-inventory.json) | Mismo inventario para uso programático |
| [`vocabulary-report-bcop.html`](../../old/vocabulary-report-bcop.html) | **Reporte visual v1** — filtros por confiabilidad/evidencia, búsqueda, orden; autocontenido |
| [`vocabulary-report-bcop-v2.html`](../../portal/vocabulary-report-bcop-v2.html) | **Reporte visual v2** — añade dimensión Bounded Context, aggregate roots destacados, contribuciones de DTs peer, filtro por BC; generado por `build-vocab-report-v2.py` |
| [`sme-validation-worklist-bcop.md`](sme-validation-worklist-bcop.md) | **Lista priorizada de validación SME** — términos sin evidencia dura, ordenados por impacto |
| [`vocab-audit-bcop.md`](vocab-audit-bcop.md) | **Auditoría exhaustiva de falsos positivos** — 10 tokens ruido identificados (os, rec, emp, chi, tar…) |
| [`flow-bcop.html`](../../old/flow-bcop.html) | **Vista de flujo de control** — secuencia real de cada journey (orden + IF + bucles), del código SPL |
| [`orchestrators-complexity-bcop.md`](../cross-reference/orchestrators-complexity-bcop.md) | Ranking de **orquestadores complejos** (deuda técnica de refactor) |
| [`business-rules-bcop.md`](../rules/business-rules-bcop.md) | **Catálogo de reglas de negocio y fórmulas** — con SME regulador dueño + riesgo de equivalencia |
| [`rules-report-bcop.html`](../../old/rules-report-bcop.html) | **Reporte visual de reglas** — filtrable por regulador / dominio / tipo / riesgo |
| [`regulatory-validation-packets-bcop.md`](../rules/regulatory-validation-packets-bcop.md) | **Paquetes `[INVOKE]` por SME regulador** — reglas + preguntas de validación para sesión HITL |
| [`dataflow-scope-bcop.md`](dataflow-scope-bcop.md) | **Análisis de scope** — términos que trascienden (contrato API/BD) vs. efímeros (efímeras de cálculo = reglas) |
| [`timeline-code-bcop.md`](../cross-reference/timeline-code-bcop.md) | **Línea temporal** — creación/modificación por SP y dominio (de comentarios del código) |
| [`evolution-bcop.html`](../../old/evolution-bcop.html) | **Mapa evolutivo** ("vetas del árbol") — crecimiento del código por dominio y año + productos bancarios |
| [`banking-operating-model-bcop.md`](../../dt/dt-modelo-dominio/banking-operating-model-bcop.md) | **Modelo operativo lógico** (SME Modelo Operativo Bancario · BIAN) — capacidades bancarias ↔ dominios técnicos |
| `banking-model-bcop.html` [PENDIENTE] | **Mapa de capacidades** — modelo lógico de BanCoppel en 6 capas, heat por cobertura |
| [`capability-model-bcop.html`](../../old/capability-model-bcop.html) | **Modelo de capacidades de referencia** (agnóstico, 10 áreas) con cobertura BanCoppel marcada — muestra gaps |
| [`journeys-catalog-bcop.md`](../../dt/dt-journeys/journeys-catalog-bcop.md) | 166 journeys con objetivos compuestos + catálogo de términos |
| [`journeys-bcop.html`](../../old/journeys-bcop.html) | Vista visual de journeys con evidencia del código |
| [`journeys-data.json`](../../portal/data/journeys-data.json) | Journeys + cadenas de llamadas + evidencia (`src`) |

---

## 10 · Límites honestos

- La **segmentación es greedy longest-match**, no un lematizador — genera fragmentos-ruido (`cion`, `ero`, `tura`) al partir palabras largas sin match completo. Se reducen agregando la palabra completa al vocabulario.
- El **objetivo compuesto es una hipótesis**; la estructura (secuencia de SPs) es real, pero el nombre de negocio final requiere validación SME (`[CONSULTAR→NEGOCIO]`).
- El análisis estático **no ve triggers ni `EXECUTE PROCEDURE` dinámico** — puede haber lógica no capturada.
- Cobertura actual (BCOPBrain 2026-08-02): **10,144 SPs** en 16 dominios D01-D16, con 34,279 edges en el call graph. Los ~3,079 restantes (de 13,223) son SPs sin conexiones — predominan en D13-D16 (catálogos, utilidades, dead code candidato).

---

## 11 · Corpus actualizado — grounding pass D01-D16 (2026-08-02)

Con el análisis completo de los 16 dominios (D13-D16 incorporados al BCOPBrain), las métricas del corpus se actualizaron respecto a la versión inicial de julio:

| Métrica | Anterior (jul-2026) | Actualizado |
|---------|---------------------|-------------|
| SPs en BCOPBrain | 3,761 (call graph D01-D12) | **10,144** (16 dominios) |
| Dominios cubiertos | 12 (D01-D12) | **16 (D01-D16)** |
| Términos atómicos | 438 | **586** |
| Términos compuestos | — | **61** |
| Candidatos sin clasificar | ~80 | **60** |
| Total inventario | 438 | **707** |

Los datos actualizados viven en `vocabulary-inventory-bcop.md` y `vocabulary-inventory.json`. La fuente de la verdad sigue siendo `sp_vocab.py` — editar ahí y re-correr el pipeline para propagar cambios.

---

## 12 · Vocabulario característico de D13-D16

Los cuatro dominios nuevos aportan patrones de nomenclatura propios que extienden el vocabulario base:

### D13 — bditef (TEF — Transferencia Electrónica de Fondos)

- **Prefijo**: ninguno exclusivo — usa `sp_` genérico
- **Términos dominantes**: `tef`, `transfer`, `transferencia`, `terceros`, `propias`, `cuentasf` (cuentas fondeo), `beneficiario`, `valida`, `monto`
- **Particularidad**: 139 SPs · ~51% aislados en el call graph · arquitectura más plana que D08 (SPEI); no tiene protocolo Banxico — es transferencia interna o entre cuentas propias del cliente
- **Ambigüedad clave**: `tef` en D13 = transferencia interna; en D08 el mismo fragmento puede aparecer en SPs de consulta de estado de transferencias externas — el prefijo de base de datos (`bditef` vs `bdispei`) es el discriminador

### D14 — bdibei (BEI — Banca En Internet Empresarial)

- **Prefijo dominante**: `sps_` en lugar de `sp_` — convención local del equipo BEI
- **Términos dominantes**: `bei`, `soe`, `manco` (mancomunidad — firmas requeridas), `admin`, `empresarial`, `sol` (solicitud), `token`, `autoriza`, `firmante`
- **Módulo SOE confirmado**: Soporte Operativo EmpresaNet — gestiona autenticación y flujos de autorización multi-firma para cuentas empresariales; confirmado por SME (Jorge Isaac Díaz, 2026-07-09)
- **Particularidad B2B**: 336 SPs · portal empresarial con flujos de firma mancomunada distintos a la banca personal; vocabulario más formal (`mancomunidad`, `firmante`, `autorizante`)

### D15 — bdilide (LIDE / PLD — Prevención de Lavado de Dinero)

- **Prefijos dominantes**: `sp_pld_` (reglas AML), `sp_ftc_` (filtros de transferencia), `sp_lide_` (lista negra CNBV)
- **Términos dominantes**: `pld`, `lide` (Lista de Inhabilitados y Declaraciones Especiales), `fatca`, `lista`, `inhabilitado`, `alerta`, `ftc`, `reporte`, `uif`
- **Vocabulario regulatorio más denso del sistema**: la práctica totalidad de SPs mapea a UIF / CNBV / SAT / IRS — requiere validación del SME Regulatorio antes de migrar cualquier SP
- **FATCA**: SPs de reporte de cuentas de residentes fiscales de EE.UU. para SAT/IRS — plazo y formato regulado (Circular 4/2012 SAT)
- **Ambigüedad clave**: `alerta` en D15 = alerta AML (riesgo regulatorio); en D09 = mensaje de notificación al cliente — el contexto de dominio es esencial para no confundirlos en el modelo target

### D16 — intercard (Tarjetas Coppel — procesamiento Syndein)

- **Prefijos dominantes**: `sp_synmotor_` (integración con procesador Syndein), `sp_cnc_` (configuración de tarjeta)
- **Términos dominantes**: `intercard`, `synmotor`, `cnc`, `stat06`, `tco` (Tarjetas Coppel), `platino`, `oro`, `bloqueo`, `parametro`, `proceso`
- **SynMotor**: motor de procesamiento del fintech Syndein — los SPs `sp_synmotor_*` son wrappers de llamadas a API/WSDL externas, no lógica bancaria propia de BanCoppel
- **Implicación para migración**: la lógica crítica de autorización de tarjetas vive en Syndein, no en Informix — el alcance debe delimitar explícitamente qué queda en el target y qué sigue en el procesador externo
- **stat06**: código de estado de tarjeta — probablemente estatus 06 (bloqueada por reporte de fraude); `[CONFIRMAR→DBA]`

---

## 13 · Contribuciones de los DTs peer al vocabulario semántico

Los DTs peer del Gemelo Cognitivo aportan capas de vocabulario que no existen en los nombres de SPs. La colaboración de los 7 DTs completa el cuadro semántico del sistema:

| DT | Capa del Gemelo | Tipo de vocabulario | Términos representativos |
|----|----------------|---------------------|--------------------------|
| **DT-Almas** | Capa 2 | Nombres de los 16 módulos funcionales — la identidad informal del sistema | Canal Digital, Integración/Auth, Créditos, Cheques/Cuentas, Saldos, Solicitudes, Aclaraciones, SPEI, Mensajería, Sucursales, Cobranza, Contabilidad, TEF, BEI, LIDE/PLD, Tarjetas |
| **DT-Journeys** | Capa 3 | Verbos de proceso bancario más sustantivos de entidad — nombres de los 131 journeys | apertura de cuenta, aplicación de cargo diferido, dictamen de crédito, cobranza domiciliada, aplicación de orden SPEI, generación de estado de cuenta, portabilidad de nómina, pago de servicio CoDi |
| **DT-Reglas** | Capa 4 | Entidades y condiciones SBVR de las 1,308 reglas — sujetos, objetos, umbrales | saldo disponible, monto mínimo, mora temprana, mora tardía, impago consecutivo, reserva CNBV, Art.61 LIC, IPAB, cartera vencida, cierre contable diario |
| **DT-Modelo-Dominio** | Modelo lógico | 23 Bounded Contexts más 8 aggregate roots — identificadores canónicos del target | num_cliente, num_cuenta, num_credito, folio (pago), PAN (tarjeta), folio_contable, num_aclaracion, id_alerta |
| **DT-Capacidades** | Mapa ETB | 57 subdominios BIAN L2 con cobertura BanCoppel — terminología de la industria bancaria | Lending, Deposits, Payments, Customer Management, Financial Reporting, Fraud Risk |
| **DT-Riesgos** | Risk register | Categorías y entidades de riesgo de migración N1-N5 | DEFECTO-PROD, divergencia de equivalencia, ventana de coexistencia, rollback, parallel-run |

### Vocabulario de capa superior no cubierto en sp_vocab.py

Estos términos existen en el sistema pero **no aparecen en nombres ni parámetros de SPs** — viven en la semántica de procesos y reglas aportados por los DTs peer. Se recomiendan como **compuestos nuevos** a agregar en `sp_vocab.py` como `("COMPUESTO", "definición", "inf")`:

| Término compuesto | DT que lo introduce | Por qué no está en sp_vocab.py |
|-------------------|---------------------|-------------------------------|
| `mora temprana` | DT-Reglas | `sp_ciloc_mora_temp` existe pero el inventario tiene `mora` como átomo; la composición como concepto unitario falta |
| `mora tardía` | DT-Reglas | `tardi` no es un morfema frecuente de SP; la composición es regulatoria |
| `dictamen de crédito` | DT-Journeys | `sp_dicta_*` existe; el proceso completo como concepto unificado es semántico |
| `estado de cuenta` | DT-Journeys | `edocta` aparece como token comprimido; el concepto completo falta como entrada del inventario |
| `impago consecutivo` | DT-Reglas | `imp` y `consecutivo` aparecen separados; la composición pertenece al modelo de scoring crediticio |
| `cartera vencida` | DT-Reglas | `cartera` existe; `vencida` no tiene token propio en el código |
| `cierre contable diario` | DT-Reglas | Proceso D12 — `cierre` más `diario` están separados; la composición es de proceso contable |
| `portabilidad de nómina` | DT-Journeys | `portabilidad` más `nomina` existen; la composición como proceso falta |

---

## 14 · Bounded Contexts y términos canónicos (dt-modelo-dominio)

El modelo lógico de negocio (v0.1.0 · 2026-08-02) define 23 Bounded Contexts con **aggregate roots**. Estos son los identificadores más críticos del vocabulario — en el AS-IS existen con 4-6 variantes por concepto por falta de contrato de API; en el target deben converger en el identificador canónico.

### Aggregate Roots — términos canónicos confirmados

| BC | Aggregate Root | Identificador canónico (target) | Dominio AS-IS | Variantes en sp_vocab.py |
|----|---------------|--------------------------------|---------------|--------------------------|
| BC-7.1 Customer | **Cliente** | `num_cliente` · CURP | D02, D06 | `cliente`, `cte`, `ctes`, `numcliente`, `numcte` |
| BC-3.2 Accounts | **Cuenta** | `num_cuenta` (16 dígitos) | D04, D05 | `cuenta`, `cta`, `ctas`, `numcuenta` |
| BC-3.3 Lending | **Crédito** | `num_credito` | D03, D11 | `credito`, `cred`, `cre`, `numcredito` |
| BC-3.4 Payments | **Transacción de Pago** | `folio` (transaccional) | D08, D13 | `folio`, `pago`, `orden`, `tef` |
| BC-3.5 Cards | **Tarjeta** | PAN tokenizado | D16 | `tarjeta`, `tdc`, `tdd`, `numtarjeta` |
| BC-5.4 Finance | **Asiento Contable** | `folio_contable` + fecha | D12 | `poliza`, `asiento`, `folio` |
| BC-3.18 Disputes | **Aclaración** | `num_aclaracion` | D07 | `aclaracion`, `acl` |
| BC-5.8 AML/Fraud | **Alerta AML** | `id_alerta` | D15 | `alerta`, `alertas`, `pld` |

> **Deuda de nombrado**: el AS-IS usa 5+ variantes del mismo identificador (ej. `cte`/`cliente`/`numcliente`/`numcte`) porque Informix sin capa de servicios no tenía contrato de API — cada DB usaba la abreviación del equipo. El reporte v2 marca estas variantes como sinónimos del aggregate root.

### Mapa Dominio → Bounded Context primario

| Dominio | BC primario | Vocabulario principal |
|---------|------------|----------------------|
| D01 bdicnweb | BC-1.1 Canal Digital | `bpi`, `web`, `app`, `cel`, `banca_digital` |
| D02 bdinteg | BC-7.1 Customer | `cliente`, `autenticacion`, `token`, `cnsif` |
| D03 bdicred | BC-3.3 Lending | `credito`, `scoring`, `buro`, `cam`, `pagare` |
| D04 bdicheq | BC-3.2 Accounts | `cheque`, `cuenta`, `cce`, `portanom`, `ctamec` |
| D05 bdisac | BC-3.2 Accounts | `saldo`, `sac`, `remesa`, `appriza` |
| D06 bdisolic | BC-7.1 Customer | `solicitud`, `scoring`, `dictamen` |
| D07 bdiaclaracion | BC-3.18 Disputes | `aclaracion`, `acl`, `fal`, `oficio` |
| D08 bdispei | BC-3.4 Payments | `spei`, `codi`, `orden`, `rastreo`, `cep` |
| D09 bdimnsj | BC-2.7 Messaging | `mensaje`, `sms`, `notifica` |
| D10 bdisuc | BC-1.2 Canal Físico | `sucursal`, `caja`, `bym`, `atm` |
| D11 bdicobranza | BC-3.3 Lending (Cobranza) | `cobranza`, `mora`, `compac`, `camp`, `ciloc` |
| D12 bdicont | BC-5.4 Finance | `cont`, `poliza`, `mayor`, `asiento`, `cfdi` |
| D13 bditef | BC-3.4 Payments (TEF) | `tef`, `transfer`, `terceros` |
| D14 bdibei | BC-7.1 Customer (BEI) | `bei`, `soe`, `manco`, `empresarial` |
| D15 bdilide | BC-5.8 AML/PLD | `pld`, `lide`, `fatca`, `inhabilitado`, `ftc` |
| D16 intercard | BC-3.5 Cards | `intercard`, `synmotor`, `tco`, `cnc` |

---

---

## Fuentes (investigación de negocio · 2026-07-03)

- [BanCoppel — Banca por Internet y productos](https://www.bancoppel.com/) · [Cuenta Efectiva Digital](https://www.bancoppel.com/descubre-mas/cuenta-efectiva-digital/) · [Cuenta Nómina](https://www.bancoppel.com/descubre-mas/cuenta-nomina-bancoppel/) · [Préstamo Digital](https://www.bancoppel.com/prestamo-digital/index.html) · [BanCoppel Clic](https://www.bancoppel.com/ahorro_bcopp/bancoppel_clic.html)
- [¿Qué es BanCoppel? (Finmart)](https://finmart.mx/organizacion/banco/bancoppel/) · [Productos BanCoppel (Global66)](https://www.global66.com/blog/productos-de-bancoppel/) · [Afore Coppel](https://aforecoppel.com/)
- [Glosario Económico y Financiero — CONDUSEF (PDF)](https://webappsos.condusef.gob.mx/EducaTuCartera/cuadernos-videos/pdf/Glosario%20Economico%20y%20Financiero.pdf) · [Glosario Banxico](https://contigo.banxico.org.mx/glosario.html)
- [SPEI — Banco de México](https://www.banxico.org.mx/servicios/sistema-pagos-electronicos-in.html) · [Comprobante Electrónico de Pago (CEP)](https://www.banxico.org.mx/cep/)

> ⚠ Los mapeos producto→dominio son **hipótesis de negocio** basadas en fuentes públicas + nombres de SP; requieren validación con el Domain Expert de BanCoppel (`[CONSULTAR→NEGOCIO]`). `BYM` y `Coppel Max` siguen sin confirmar.

*Base de conocimiento curada por Specialist — Informix SPL Analysis · Etapa 3 · SPE-AM-001 · complementa el inventario auto-generado.*