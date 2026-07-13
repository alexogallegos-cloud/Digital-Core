# BCOPCore · Base de Conocimiento del Vocabulario SPL

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base:** IBM Informix IDS 14.10 FC10W2 / POWER-AIX · **Corpus:** 3,761 SPs conectados (de 13,223)
> **Última actualización:** 2026-07-03

Documento de referencia curado que explica **cómo leer los nombres de los stored procedures de BanCoppel** y el sistema de vocabulario que los interpreta. Complementa al inventario auto-generado [`vocabulary-inventory-bcop.md`](vocabulary-inventory-bcop.md) (las tablas de términos) con el **conocimiento de dominio** necesario para interpretarlos.

---

## 0 · Contexto de negocio BanCoppel

> Investigado en fuentes públicas (bancoppel.com, CONDUSEF, Banxico) el 2026-07-03 para dar sentido de negocio al vocabulario. Ver **Fuentes** al final.

**Qué es BanCoppel.** Institución de banca múltiple mexicana, subsidiaria de **Grupo Coppel** (Coppel Capital), creada en 2007. Enfoque en **banca de consumo e inclusión financiera** para la base de la pirámide y clase media — *"banca que funciona, sin tecnicismos ni opacidad"*. Escala: **~1,372 sucursales · ~2,203 cajeros propios** · red de depósito/retiro en tiendas Coppel y OXXO. **Afore Coppel** es la 2ª administradora de retiro más grande de México (~14.5M cuentas). Su modelo está entrelazado con la tienda departamental Coppel y su **crédito quincenal**.

**Productos → dominios del core** (así se mapea el negocio al código):

| Producto de negocio | Descripción | Dominio(s) BCOPCore |
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

En un sistema *"base de datos como aplicación"* como BCOPCore, la lógica de negocio vive como **13,223 stored procedures** cuyos nombres son la única pista inmediata de su propósito (no hay capa de servicios documentada). Los nombres son **morfemas concatenados en español** con notación abreviada — `spei_aplicaordenpago`, `sp_cont_cargamovimientob3`, `sp_fal_busca_pagares_cliente`.

El vocabulario ([`sp_vocab.py`](sp_vocab.py)) descompone esos nombres en términos con significado, permitiendo **inferir el objetivo de cualquier SP sin leer su código** — y priorizar cuáles sí requieren lectura manual (los ambiguos). Es la base de la Etapa 3 y alimenta el catálogo de journeys y el inventario de términos.

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

**Estado actual:** 438 términos clasificados — 🟢 348 · 🟡 54 · 🔴 36 · con ~80 candidatos pendientes.

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
sp_vocab.py  (fuente única del vocabulario — editar aquí)
   │
   ├─ python extract-journeys.py        → journeys-data.json (journeys + objetivos)
   ├─ python mine-source.py             → enriquece con evidencia del código fuente
   ├─ python build-catalog.py           → journeys-catalog-bcop.md
   ├─ python build-vocab-inventory.py   → vocabulary-inventory-bcop.md + .json
   └─ python build-vocab-report.py      → vocabulary-report-bcop.html (reporte visual)
```

---

## 9 · Artefactos relacionados

| Archivo | Contenido |
|---------|-----------|
| [`sp_vocab.py`](sp_vocab.py) | **Fuente del vocabulario** (438 términos) + funciones `segment` / `compose` |
| [`vocabulary-inventory-bcop.md`](vocabulary-inventory-bcop.md) | Inventario tabular: átomos, compuestos, candidatos, confiabilidad |
| [`vocabulary-inventory.json`](vocabulary-inventory.json) | Mismo inventario para uso programático |
| [`vocabulary-report-bcop.html`](vocabulary-report-bcop.html) | **Reporte visual** de todo el vocabulario (filtros por confiabilidad/evidencia, búsqueda, orden) — autocontenido |
| [`sme-validation-worklist-bcop.md`](sme-validation-worklist-bcop.md) | **Lista priorizada de validación SME** — términos sin evidencia dura, ordenados por impacto |
| [`flow-bcop.html`](flow-bcop.html) | **Vista de flujo de control** — secuencia real de cada journey (orden + IF + bucles), del código SPL |
| [`orchestrators-complexity-bcop.md`](orchestrators-complexity-bcop.md) | Ranking de **orquestadores complejos** (deuda técnica de refactor) |
| [`business-rules-bcop.md`](business-rules-bcop.md) | **Catálogo de reglas de negocio y fórmulas** — con SME regulador dueño + riesgo de equivalencia |
| [`rules-report-bcop.html`](rules-report-bcop.html) | **Reporte visual de reglas** — filtrable por regulador / dominio / tipo / riesgo |
| [`regulatory-validation-packets-bcop.md`](regulatory-validation-packets-bcop.md) | **Paquetes `[INVOKE]` por SME regulador** — reglas + preguntas de validación para sesión HITL |
| [`dataflow-scope-bcop.md`](dataflow-scope-bcop.md) | **Análisis de scope** — términos que trascienden (contrato API/BD) vs. efímeros (efímeras de cálculo = reglas) |
| [`timeline-code-bcop.md`](timeline-code-bcop.md) | **Línea temporal** — creación/modificación por SP y dominio (de comentarios del código) |
| [`evolution-bcop.html`](evolution-bcop.html) | **Mapa evolutivo** ("vetas del árbol") — crecimiento del código por dominio y año + productos bancarios |
| [`banking-operating-model-bcop.md`](banking-operating-model-bcop.md) | **Modelo operativo lógico** (SME Modelo Operativo Bancario · BIAN) — capacidades bancarias ↔ dominios técnicos |
| [`banking-model-bcop.html`](banking-model-bcop.html) | **Mapa de capacidades** — modelo lógico de BanCoppel en 6 capas, heat por cobertura |
| [`capability-model-bcop.html`](capability-model-bcop.html) | **Modelo de capacidades de referencia** (agnóstico, 10 áreas) con cobertura BanCoppel marcada — muestra gaps |
| [`journeys-catalog-bcop.md`](journeys-catalog-bcop.md) | 131 journeys con objetivos compuestos + catálogo de términos |
| [`journeys-bcop.html`](journeys-bcop.html) | Vista visual de journeys con evidencia del código |
| [`journeys-data.json`](journeys-data.json) | Journeys + cadenas de llamadas + evidencia (`src`) |

---

## 10 · Límites honestos

- La **segmentación es greedy longest-match**, no un lematizador — genera fragmentos-ruido (`cion`, `ero`, `tura`) al partir palabras largas sin match completo. Se reducen agregando la palabra completa al vocabulario.
- El **objetivo compuesto es una hipótesis**; la estructura (secuencia de SPs) es real, pero el nombre de negocio final requiere validación SME (`[CONSULTAR→NEGOCIO]`).
- El análisis estático **no ve triggers ni `EXECUTE PROCEDURE` dinámico** — puede haber lógica no capturada.
- Cobertura actual: **3,761 SPs conectados** de 13,223 totales. Los 9,462 restantes son SPs sin conexiones en el call graph (hojas aisladas, dead code candidato, o utilidades).

---

---

## Fuentes (investigación de negocio · 2026-07-03)

- [BanCoppel — Banca por Internet y productos](https://www.bancoppel.com/) · [Cuenta Efectiva Digital](https://www.bancoppel.com/descubre-mas/cuenta-efectiva-digital/) · [Cuenta Nómina](https://www.bancoppel.com/descubre-mas/cuenta-nomina-bancoppel/) · [Préstamo Digital](https://www.bancoppel.com/prestamo-digital/index.html) · [BanCoppel Clic](https://www.bancoppel.com/ahorro_bcopp/bancoppel_clic.html)
- [¿Qué es BanCoppel? (Finmart)](https://finmart.mx/organizacion/banco/bancoppel/) · [Productos BanCoppel (Global66)](https://www.global66.com/blog/productos-de-bancoppel/) · [Afore Coppel](https://aforecoppel.com/)
- [Glosario Económico y Financiero — CONDUSEF (PDF)](https://webappsos.condusef.gob.mx/EducaTuCartera/cuadernos-videos/pdf/Glosario%20Economico%20y%20Financiero.pdf) · [Glosario Banxico](https://contigo.banxico.org.mx/glosario.html)
- [SPEI — Banco de México](https://www.banxico.org.mx/servicios/sistema-pagos-electronicos-in.html) · [Comprobante Electrónico de Pago (CEP)](https://www.banxico.org.mx/cep/)

> ⚠ Los mapeos producto→dominio son **hipótesis de negocio** basadas en fuentes públicas + nombres de SP; requieren validación con el Domain Expert de BanCoppel (`[CONSULTAR→NEGOCIO]`). `BYM` y `Coppel Max` siguen sin confirmar.

*Base de conocimiento curada por Specialist — Informix SPL Analysis · Etapa 3 · SPE-AM-001 · complementa el inventario auto-generado.*