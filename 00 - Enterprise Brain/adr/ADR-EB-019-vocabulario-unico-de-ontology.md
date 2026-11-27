# ADR-EB-019 — Un solo vocabulario para `ontology`, y el slug primario es la industria

> Estado: **APROBADO** · Fecha: 2026-11-27 · Asset: Enterprise Brain · Digital Core


<!-- PROPAGACION
templates/schema.sql :: VOCABULARIO DE `ontology`
canon/brain-rules.md :: El vocabulario de `ontology`
knowledge-base/ontology/banca.md :: ontology='banca'
knowledge-base/ontology/seguros.md :: ontology='seguros-pc'
knowledge-base/ontology/retail.md :: ontology='retail'
dt/dt-brain-auditor/validate.py :: VALID_INDUSTRIES
dt/dt-brain-auditor/CLAUDE.md :: vocabulario de `ontology`
-->

---

## Contexto

ADR-EB-007 creó `ontology_bindings` para declarar la composición de ontologías
de una empresa, y puso una FK lógica hacia ella en las tablas que cargan
conocimiento ontológico. La decisión fue correcta y nunca se fijó el vocabulario
de la columna que une ambos lados.

El resultado es que la misma columna lógica tiene hoy **cuatro definiciones
distintas** dentro del canon, y ninguna es compatible con las otras tres:

| Ruta | Valores declarados | Grano implícito |
|------|-------------------|-----------------|
| `templates/schema.sql` :: `ontology_bindings.ontology` (PK) | `retail`, `financial_services`, `insurance` | familia de industria, en inglés |
| `templates/schema.sql` :: `capabilities.ontology` | `retail`, `financial_services`, `banking`, `insurance` | familia de industria, en inglés, con un valor más |
| `templates/schema.sql` :: `processes.ontology` | `banca-etb`, `pc-etb`, `life-etb`, `retail-valuechain` | industria más catálogo más ramo, en español |
| `templates/schema.sql` :: `source_catalog.ontology` | sin comentario | indefinido |

`canon/mapa-tablas.md` se genera desde el schema, así que propaga los tres
vocabularios contradictorios a la documentación del canon sin que nadie los
haya contrastado.

La deriva no se queda en los comentarios. Las tres ontologías de industria de
`knowledge-base/ontology/` documentan cómo poblar `ontology_bindings` y
**ninguna de las tres declara la columna `ontology`**, que es la llave primaria
de la tabla: sus ejemplos arrancan en `model_type`. Un cargador que siga el
ejemplo al pie de la letra no puede insertar la fila.

Y hay dos colisiones de significado:

- `banca.md` documenta `capabilities.ontology` con los valores
  `'etb' | 'bian' | 'regulatory'`, que son valores de `model_type`, no de
  `ontology`. Las dos columnas quedaron intercambiadas.
- `retail.md` declara `model_type='financial_services'`, que no pertenece al
  conjunto cerrado de siete que el validador exige en `VALID_MODEL_TYPES`.
  `financial_services` es el nombre de la ontología, y su `model_type` es `etb`.

Mientras tanto el Brain Auditor sí contrasta declaración contra carga, pero
**solo para `capabilities`**. `processes.ontology` y `source_catalog.ontology`
pueden apuntar a cualquier cadena sin que nadie se entere, que es exactamente
el hueco que ADR-EB-007 quiso cerrar.

### Por qué importa ahora

Ningún brain del estate declara todavía `industry` ni su composición de
ontologías: son 0 de 16. Eso convierte este momento en el único barato para
fijar el vocabulario, porque no hay datos cargados que migrar. El único dato
real que existe es el de Liverpool, cuya columna `source_etb` lleva `retail` y
`financial_services`, y ambos valores sobreviven intactos a la decisión que
sigue.

---

## Decisión

**1. `ontology` tiene un solo vocabulario en las cuatro tablas.** Es el slug de
un miembro de la composición de la empresa, nunca el catálogo ni el ramo. El
catálogo vive en `ontology_bindings.catalog`, la versión en `catalog_version`,
la forma del ancla en `model_type` y el ramo en la columna `lob` de la tabla
que lo necesite.

**2. El slug de la ontología primaria es idéntico a `system_info.industry`.**
No hay traducción ni tabla de equivalencias entre una columna y la otra:

| `system_info.industry` | Slug de la ontología primaria | Brain (Regla B18) | Archivo de ontología |
|------------------------|-------------------------------|-------------------|----------------------|
| `banca` | `banca` | `bank-brain` | `knowledge-base/ontology/banca.md` |
| `seguros` | `seguros` | `insurance-brain` | `knowledge-base/ontology/seguros.md` |
| `retail` | `retail` | `retail-brain` | `knowledge-base/ontology/retail.md` |

El vocabulario de `industry` es cerrado y lo define qué archivos existen en
`knowledge-base/ontology/`. Agregar una industria es escribir su archivo, no
inventar un valor: una industria sin ontología base documentada no tiene de
dónde sacar capabilities, procesos ni regulador.

**2b. La industria con eje de ramo califica el slug con el ramo.** Cuando
`system_info.lob_dimension` no es NULL, el slug primario es `{industria}-{lob}`
en lugar de `{industria}` a secas. La excepción no es cosmética y sale de la
evidencia que ya traía ADR-EB-007: en seguros cada ramo tiene su **propio
catálogo con su propia versión** — P&C Insurance ETB v3.0 y Life Insurance ETB
v2.0 son documentos distintos — y `ontology_bindings` lleva un solo
`catalog_version` por fila. Colapsar los cuatro ramos en un slug `seguros`
obligaría a tirar la versión de tres de ellos.

| Slug | Ramo | Catálogo |
|------|------|----------|
| `seguros-pc` | Daños | Insurance_ETB_PC_v3.0 |
| `seguros-vida-ap` | Vida y Accidentes | Insurance_ETB_Life_v2.0 |
| `seguros-gmm` | Gastos Médicos Mayores | Insurance_ETB_Life_v2.0 |
| `seguros-fianzas` | Fianzas | catálogo del ramo |

Sigue habiendo **exactamente una fila con `role='primary'`**: la del ramo
dominante del cliente, que es la que fija el nombre del brain. Para AXA es
`seguros-pc`, y los otros ramos son secundarios sin que eso los haga menos
importantes para el negocio: el rol declara cuál ancla la semántica, no cuál
factura más. Banca y retail no usan esta forma porque no tienen eje de ramo, y
no se les inventa uno.

El nombre del brain sigue siendo una tabla de tres filas y no una concatenación.
`banca` da `bank-brain`, no `banca-brain`. La regla B18 nombra por industria; no
promete que el nombre se derive pegando cadenas.

**3. Las ontologías secundarias usan slugs reservados.** Se eligen de esta lista
antes de inventar uno nuevo, para que dos brains del mismo tipo no nombren
distinto lo mismo:

| Slug | Qué es | `model_type` típico |
|------|--------|---------------------|
| `financial_services` | Overlay de servicios financieros dentro de una empresa que no es banco (patrón Liverpool) | `etb` |
| `bian` | BIAN Service Landscape adoptado por el cliente | `bian` |
| `itom` | Modelo de operación de TI que ancla el lado Run | `itom` |
| `{regulador}-{instrumento}` | Ancla regulatoria, en minúsculas y con guiones: `banxico-can`, `cnbv-cub` | `regulatory` |
| `{cliente}-operating-model` | Modelo operativo lógico propio del cliente (patrón AXA) | `client-logical` |

**4. Las cuatro columnas son FK lógica a `ontology_bindings.ontology`.** Toda
cadena que aparezca en `capabilities.ontology`, `processes.ontology` o
`source_catalog.ontology` tiene que resolver contra una fila declarada. Una
ontología cargada sin declarar es semántica no gobernada, y da igual en cuál de
las tres tablas aparezca.

**5. El Brain Auditor gana tres aserciones** dentro de la dimensión de
cross-references:

| Aserción | Severidad |
|----------|-----------|
| `system_info.industry` fuera del vocabulario cerrado | bloqueante |
| El slug de la fila `role='primary'` no es `industry` ni `{industry}-{lob}` | bloqueante |
| Un valor de `ontology` en `processes` o en `source_catalog` que no resuelve contra `ontology_bindings` | bloqueante |

La tercera extiende a dos tablas más el contraste que ya existía para
`capabilities`, con el mismo criterio y el mismo mensaje.

---

## Consecuencias

**Positivas**

- La columna que une la declaración con la carga significa lo mismo en las
  cuatro tablas, y el contraste declaración contra carga pasa de una tabla a
  tres.
- La invariante de la ontología primaria es de una línea y la verifica una
  máquina, en lugar de ser una convención que cada brain interpreta.
- `canon/mapa-tablas.md` deja de publicar tres vocabularios contradictorios en
  cuanto se regenera.
- Los dos valores reales del estate, los de Liverpool, quedan válidos sin
  tocarlos.

**Negativas / costo asumido**

- Las tres ontologías de industria necesitan corrección en sus ejemplos de
  carga: agregar la columna `ontology`, sacar `model_type='financial_services'`,
  devolver `capabilities.ontology` a su significado y quitar los campos que el
  schema no tiene. Son ejemplos documentales; no hay datos que migrar.
- El vocabulario de `industry` queda acotado a tres valores, y abrirlo a una
  cuarta industria obliga a escribir antes su ontología base. Es el costo
  buscado: evita brains que declaran una industria de la que el asset no sabe
  nada.

**Neutras**

- El nombre de los archivos de ontología se queda en español y coincide con el
  slug, así que la ruta se resuelve desde `industry` sin tabla intermedia. Los
  DTs de BanCoppel que ya citan `knowledge-base/ontology/banca.md` por ruta no
  se tocan.

---

## Alternativas consideradas

- **Pasar todo el vocabulario al inglés (`banking`, `insurance`, `retail`).**
  Rechazada por costo sin beneficio: obliga a cambiar el valor de `industry` en
  las tres ontologías, rompe la coincidencia con el nombre de archivo y no hace
  más mecánica la Regla B18, porque `banking` tampoco da `bank-brain` pegando
  cadenas. El único argumento a favor era la consistencia con los demás
  vocabularios cerrados del schema, y no alcanza para mover tres archivos.

- **Dejar que `ontology` cargue también el catálogo, como hacía el comentario de
  `processes` (`pc-etb`, `life-etb`).** Rechazada: el catálogo cambia de versión
  sin que cambie la ontología, así que meterlo en la llave primaria convierte
  cada bump de versión en una migración de datos. El catálogo vive en `catalog`
  y la versión en `catalog_version`, que es para lo que existen. El ramo sí
  califica el slug, pero por la razón del punto 2b y no por traer catálogo.

- **Colapsar los ramos de seguros en un solo slug `seguros`.** Rechazada: los
  cuatro ramos tienen catálogos y versiones distintos, y `ontology_bindings`
  lleva un `catalog_version` por fila. Un solo slug obligaría a declarar una
  versión y perder las otras tres, o a inventar una columna para guardarlas.

- **Vocabulario abierto, con convención de nombres pero sin conjunto cerrado.**
  Rechazada para `industry`, aceptada para los slugs secundarios. En `industry`
  el valor decide qué Industry SME suministra la semántica y qué archivo de
  ontología se carga, así que un valor libre es un brain sin semántica
  resoluble. En los secundarios el conjunto no se puede cerrar de antemano
  porque cada ancla regulatoria trae su propio instrumento.

---

*Relacionado: ADR-EB-007 (la industria determina la semántica) · ADR-EB-014
(catálogo de fuentes) · Reglas B18, B19, B20, B21*
