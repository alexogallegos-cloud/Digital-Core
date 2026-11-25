# BanCoppel Bank Brain — Agente Federado del Programa

> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`
> **Rol**: Inteligencia federada del programa — agrega, conecta y gobierna el conocimiento de todos los sistemas del cliente.
> **Ruta canónica**: `BanCoppel/bank-brain/`
> **Hereda**: `Application Modernization/CLAUDE.md` (Reglas B + Reglas V)

---

## QUÉ ES EL BANK-BRAIN

El `bank-brain` es el sistema de segundo orden del programa: no analiza código, sino los brains de los sistemas que sí analizan código. Su conocimiento tiene tres capas ortogonales:

| Capa | Qué contiene | `maturity` |
|------|-------------|-----------|
| **HOY** | Conocimiento verificado del AS-IS — extraído de código, logs, artefactos operativos | `live` |
| **AYER** | Historia del sistema — por qué el sistema llegó a ser lo que es (decisiones, incidentes, deuda) | `live` |
| **MAÑANA** | Escenarios, ideas, minutas, decisiones en maduración — el pipeline de transformación | `idea` · `exploring` · `decided` · `implementing` |

El campo `maturity` es la dimensión que separa estas capas **dentro del mismo brain** — sin bases de datos separadas, sin carpetas alternativas. Los queries filtran por `maturity` para obtener el corte deseado.

---

## ESTRUCTURA

```
bank-brain/
├── digital-brain/
│   ├── bank-brain.db          ← SQLite federado (gitignored)
│   ├── bank-brain.py          ← Agent API
│   └── build-bank-brain.py    ← pipeline de construcción
├── generators/                ← scripts de federación y enriquecimiento
├── knowledge-base/
│   ├── vocab/                 ← vocabulario canónico del banco (Regla V1)
│   ├── rules/                 ← reglas cross-sistema
│   ├── ontology/              ← taxonomía BanCoppel completa (ABB→SBB, BIAN)
│   └── manana/                ← documentos MAÑANA (ideas, minutas, escenarios)
├── dt/                        ← Digital Twins de programa (cross-sistema)
├── portal/                    ← vistas cross-sistema
├── source/                    ← minutas, contratos, docs del programa
└── old/                       ← archivados
```

---

## VOCABULARIO EMPRESARIAL — REGLA V1 (instancia de proyecto)

> Implementación de la Regla V1 de `Application Modernization/CLAUDE.md`.

El vocabulario canónico del banco vive en:
```
knowledge-base/vocab/vocab-bancoppel-v{N}.json
```

**Versión actual**: `v1.0` — 634 términos (fuente: Informix · 2026-08-13)
- `enterprise`: 422 términos confirmados como vocabulario del banco
- `review`: 204 términos pendientes de curaduría
- `system`: 8 términos específicos de Informix (no aplicables a otros sistemas)

### Cómo usa el vocabulario cada sistema nuevo

Cuando se incorpora un sistema nuevo al programa (Apolo, Transact, canal digital, etc.), su pipeline de extracción de vocabulario **debe**:

```python
# En {sistema}/generators/build-vocab-sistema.py
import json
from pathlib import Path

# 1. Cargar vocabulario empresarial como referencia
BANK_VOCAB = Path(__file__).parents[4] / "bank-brain/knowledge-base/vocab/vocab-bancoppel-v1.json"
enterprise_terms = {t["term"]: t for t in json.loads(BANK_VOCAB.read_text())["terms"]
                    if t["scope"] == "enterprise"}

# 2. Para cada término extraído del sistema:
#    - Si está en enterprise_terms → confirmar (misma semántica) o marcar conflicto
#    - Si no está → agregar a proposals con scope="proposed"
```

### Proceso de evolución del vocabulario

```
Sistema nuevo extrae términos
        ↓
Cruce contra vocab-bancoppel-v{N}.json
        ↓
  ┌─────────────────────────────────────┐
  │ Confirmar   Enriquecer   Proponer   │
  │ (ya existe) (nuevo ctx)  (nuevo)    │
  └─────────────────────────────────────┘
        ↓
Industry Banking SME revisa propuestos
        ↓
vocab-bancoppel-v{N+1}.json   (nueva versión)
        ↓
build-vocab-v{N+1}.py recarga bank-brain.db
```

### Poder real de la Regla V1

El vocabulario empresarial es el **Rosetta Stone** del programa. Cuando el mismo concepto aparece en distintos sistemas con distintos nombres, el vocabulario lo alinea:

| Sistema | Nombre interno | Término empresarial |
|---------|---------------|---------------------|
| Informix (SPL) | `vSaldoVigente` | `saldo` |
| Apolo (Java) | `currentBalance` | `saldo` |
| Transact (propietario) | `BAL_CURR` | `saldo` |

Sin vocabulario empresarial: tres nombres para el mismo concepto, imposible comparar reglas entre sistemas.
Con vocabulario empresarial: `business_name = "Saldo vigente"` en los tres sistemas. Los journeys, las reglas y las capacidades se vuelven comparables.

---

## CAPAS HOY / AYER / MAÑANA

### HOY — AS-IS verificado

- Fuente: brains de sistemas individuales (Informix, Apolo, etc.)
- `maturity: "live"` en todos los artefactos
- Nunca modificar directamente — se actualiza reconstruyendo el brain del sistema origen

### AYER — Historia del programa

Documentos en `source/` con `maturity: "history"`:
- Minutas de decisiones pasadas
- Post-mortems de incidentes que dieron forma al sistema
- ADRs implícitos que explican por qué el código es como es

### MAÑANA — Pipeline de transformación

Documentos en `knowledge-base/manana/` con maturity progresiva:

| Etapa | `maturity` | Descripción |
|-------|-----------|-------------|
| Idea inicial | `idea` | Observación, intuición, propuesta sin análisis |
| En exploración | `exploring` | Se está investigando — opciones, evidencia, trade-offs |
| Decidido | `decided` | Dirección elegida, no implementada aún |
| En implementación | `implementing` | SME ejecutando — Sprint activo |
| Vivo | `live` | Implementado y verificado → graduado a HOY |
| Descartado | `rejected` | Explorado y abandonado — se preserva para no repetir |

**Frontera HOY/MAÑANA**: un ítem de MAÑANA se gradúa a HOY únicamente cuando el sistema origen reconstruye su brain con el artefacto real en producción. La graduación la ejecuta `build-bank-brain.py`, no un cambio manual de campo.

---

## HANDOFFS CANÓNICOS

| Trigger | Destino |
|---------|---------|
| Conflicto de vocabulario entre sistemas | Industry Banking SME → resolución semántica |
| Término nuevo en `review` → enterprise | Industry Banking SME → curación |
| Ítem MAÑANA `decided` → `implementing` | SME técnico del sistema target |
| Capability gap detectado pre-decommission | Regla B7 → Core Banking Transformation SME |
| Término regulatorio nuevo | Regulatory SME correspondiente (Banxico · CNBV · CONSAR) |

---

## FEDERACIÓN DE LA FLOTA — REGLA B4 Y SU TECHO

La Regla B4 dice federar por `ATTACH` y no por un servidor de API, y eso sigue siendo correcto. Lo que no preveía es el techo: SQLite viene compilado con `SQLITE_MAX_ATTACHED = 10` y `Connection.setlimit()` no puede subirlo, porque es un límite de compilación y no de ejecución. Con 36 brains en el árbol, la flota no cabe junta en una conexión.

La federación recorre en lotes de nueve, abre cada brain en modo lectura y agrega en Python en vez de en un `UNION` de SQL. El resultado es el mismo que pide B4; lo que cambia es que escala más allá de diez sistemas.

**El id de un brain lo declara el brain, no la carpeta.** La carpeta dice `CajeroATM` y el sistema se llama `cajero-atm`; dice `EGlobal` y se llama `e-global`. El registro lee `system_info.slug` y sólo cae a la carpeta normalizada contra `dep_aliases` en los cinco brains que todavía no tienen esa tabla.

**La flota es heterogénea y la consulta se arma por brain.** Sólo cuatro brains llevan `etb_l3` y treinta y tres llevan `cross_dependencies`, con tres esquemas distintos: el de la Regla B12 dice `relationship` y `other_system`, los hechos a mano antes de esa regla dicen `dependency_type`, y AppMovil parte el par en `source_system` y `target_system`. Una lista fija de columnas dejaba fuera a Informix, ControlM y AppMovil, que son justo los que más aristas declaran, y los dejaba fuera en silencio. Ahora lo que no se puede leer queda en `fed.saltados`.

| Método | Qué responde |
|--------|--------------|
| `brains()` | Qué brains alcanza el federador y qué aporta cada uno |
| `capabilities_consolidated()` | Qué capacidad ETB cubre qué sistema, en toda la flota |
| `capability_gap()` | Capacidades que ningún brain cubre — el gate de decommission de B7 |
| `capability_alignment()` | Versión del catálogo ETB por brain — la desalineación de B3 |
| `fleet_dependencies()` | Lo que cada brain declara de su lado, sin pasar por la tabla curada |

`fleet_dependencies()` y `system_dependencies()` no son lo mismo y conviene no confundirlas. La segunda es la tabla curada a mano dentro de esta base, con 16 filas. La primera lee la fuente: 71 aristas que los brains declaran de sí mismos. Cuando discrepan manda el brain del sistema, y la tabla curada se corrige.

**`NOT_ASSESSED` no es cobertura.** Un brain que todavía no evaluó el catálogo no tapa un hueco, sólo deja de opinar. El hueco federado de hoy son 198 capacidades; mientras `capability_gap()` leía únicamente el brain del core eran 199, porque `3.5.6 Switching` figuraba como hueco siendo que la cubren e-global e InterAct. Un gate de decommission que mira a un solo sistema inventa huecos que no existen.

---

## CATÁLOGO DE ACCIONES — REGLA B39

Qué puede hacer el brain por su cuenta sobre este programa y qué tiene que pedir. El nivel no lo decide la intención sino la naturaleza de la acción: A0 observar, A1 proponer en estado silver, A2 ejecutar preautorizado, A3 ejecutar con aprobación explícita del rol accountable.

| Tabla | Qué contiene |
|-------|--------------|
| `action_catalog` | La política: qué tipo de acción está preautorizada y hasta qué nivel |
| `actions` | El linaje: una fila por ejecución, con su nivel, el conocimiento que la sustentó y cómo salió |

Se siembra con `generators/load-action-catalog.py`, encadenado al final de `build-bank-brain.py` porque esta base se borra y se recrea en cada corrida. Si no se vuelve a sembrar, el dictamen de autonomía se pierde y la regla regresa a ser intención.

**Cuatro tipos de acción nunca bajan de A3**, sin importar el historial: cambio en producción, decommission de un sistema, cambio de configuración de seguridad e impacto financiero directo al cliente.

Conviene decir completo por qué, porque llamarlos "irreversibles" a secas confunde. El canon da **dos razones, no una**: o el efecto sobre lo que ya ocurrió no se recupera, o hay consecuencia regulatoria directa. La mayoría de estas acciones **sí se deshacen** en lo técnico: el parámetro 150 se revierte con otro UPDATE en segundos. Lo que no se deshace es el tiempo que estuvo vigente. Mientras estuvo puesto, los cajeros operaron con ese comportamiento y los clientes se fueron con lo que les pasó; revertir la configuración no revierte esas operaciones. Por eso la columna se llama `never_below_a3`, que describe la consecuencia, y no "irreversible", que describe mal la causa.

Cada acción del catálogo declara en su descripción cuál de las dos razones le aplica, en vez de heredar una etiqueta genérica.

### Primer caso catalogado: el workaround de capacidad de Caja

| Acción | Nivel | Siempre exige firma | Rol accountable |
|--------|-------|---------------------|-----------------|
| `ACT-BCOP-alertas-plugin` | A2 | No | Capacity and Availability Manager |
| `ACT-BCOP-dimensionar-eg-caja` | A3 | Sí | Change Manager |
| `ACT-BCOP-entitlement-ihs` | A3 | Sí | Change Manager |
| `ACT-BCOP-param150-reintentos` | A3 | Sí | Change Manager |
| `ACT-BCOP-param151-mensaje` | A3 | Sí | Change Manager |
| `ACT-BCOP-param916-huella` | A3 | Sí | Change Manager |
| `ACT-BCOP-permiso-cluster27` | A3 | Sí | IT Risk Manager |

Seis de siete quedan fijas en A3 y sólo las alertas pueden ir preautorizadas. Cinco lo son por cambio en producción y una, el permiso de `Cluster_27`, por consecuencia regulatoria: tocar permisos de red entra en el alcance de PCI-DSS. **Sin despliegue no compra autonomía**: seis de siete necesitan la misma firma que necesitaría un despliegue, y lo que se ahorra es riesgo de ejecución y tiempo de reversa, no gobierno.

Hoy las siete están registradas en `actions` con nivel **A1**, porque A2 y A3 exigen conocimiento gold y el sustento es silver: sale de leer el fuente de CPlaSu y el diagnóstico de performance de octubre de 2026. **Leer en DB2 el valor vigente del parámetro 150 es lo que promueve el conocimiento a gold** y lo único que desbloquea A3 para las otras seis. No es una buena práctica sugerida de pasada, es el gate.

`ACT-BCOP-dimensionar-eg-caja` merece atención aparte: vive del lado del broker IIB y **no es el plugin del IHS**. Son artefactos y equipos distintos, y es la única acción que ataca la latencia, que es el motor real del techo de conexiones. Queda pendiente confirmar si también está bloqueada o si sólo lo está el plugin.

Los `accountable_role` traen el nombre del rol canónico. Cuando esta base tenga tabla `stakeholders` con los roles reales de BanCoppel, estas filas apuntan a su id.

---

## GRAFO DE DEPENDENCIAS DE LA FLOTA

La vista global que esta base existe para dar. Cada brain declara su lado de la relación; el grafo los contrasta y deja una sola afirmación por par, con la procedencia de cada una.

Vive dentro de `bank-brain.db` con prefijo `dep_`, no en una base aparte, porque este documento lo pide así. Se construye al final de `build-bank-brain.py`, que borra y recrea su base en cada corrida, y también puede correrse solo cuando cambia un brain de sistema.

| Tabla | Qué contiene |
|-------|--------------|
| `dep_nodes` | Los sistemas del ecosistema, con su carpeta, su brain y cuánto declaran |
| `dep_edges` | Una fila por afirmación. La misma relación dicha por dos brains son dos filas |
| `dep_graph` | El grafo deduplicado, un par dirigido por fila, con cuántas fuentes lo sostienen |
| `dep_conflicts` | Donde dos fuentes no coinciden, o donde el sentido nadie lo declaró |
| `dep_orphans` | Sistemas que alguien cita y no tienen carpeta. Candidatos de Regla B9 |
| `dep_aliases` | Un sistema, un nombre. Resuelve `pisa` y `informix`, `eglobal` y `e-global` |
| `dep_catalog` | Las 211 interfaces del Anexo 5 sin colapsar, con protocolo, sincronía y confianza por fila |

Cinco fuentes alimentan el grafo, y el grafo recuerda cuál fue cada una: el `cross_dependencies` de cada brain de sistema, los seeds que se emiten entre brains, el `system_dependencies` de esta base, su tabla `interfaces` y el Catálogo de Interfaces AS-IS del Anexo 5.

La quinta es distinta de las otras cuatro: declara el sentido de cada relación fila por fila, en columnas separadas de origen y destino, y trae su propia confianza. Por eso es la que arbitra. Su metodología lo dice sin rodeos, y el dato lo confirma en las 211 filas: **las bases de datos son siempre destino, nunca origen**. Informix aparece 70 veces como destino y ninguna como origen.

El catálogo habla de 129 aplicaciones y el grafo de 43 sistemas, así que no son la misma capa. El nodo `informix` cubre la base, el SOC que corre sobre ella y los módulos SPL del core, que el Anexo 5 lista por separado; sólo se mapea lo que el inventario sostiene y el resto queda en `dep_catalog` sin inventar aristas. Las aplicaciones que el grafo no modela se consultan con `gaps`: hoy son 95, encabezadas por el Motor de Pago de Servicios con 12 interfaces.

**Una afirmación no es un hecho.** Un brain semilla repite, invertida, lo que le sembró el brain que lo descubrió, así que no confirma nada por sí solo: el grafo lo marca como fuente derivada y no como confirmación. Cuando ninguna fuente primaria declara el sentido de una dependencia, el par queda con `dir_confianza = 'inferida'` en vez de aparentar certeza.

**Reorientar no es borrar evidencia.** Cuando una fuente declara el sentido de un par y las demás afirmaciones sobre ese mismo par no lo declaran, esas afirmaciones se giran para apuntar donde la fuente dice, conservando intactas su descripción y su evidencia. Lo que cambia es un sentido que su fuente nunca afirmó. Quedan marcadas con `reorientada = 1` y `orientada_por`, de modo que `evidence` muestra quién las giró. Si dos fuentes declaran sentidos opuestos, eso es un desacuerdo real y el grafo no lo resuelve: lo marca como conflicto de dirección.

Consulta con la API de Regla B1:

```bash
python digital-brain/dependency-brain.py                      # estado del grafo
python digital-brain/dependency-brain.py neighbors informix   # quién depende de quién
python digital-brain/dependency-brain.py evidence siweb informix
python digital-brain/dependency-brain.py rules                # invariantes B9, B10, B11
python digital-brain/dependency-brain.py conflicts
python digital-brain/dependency-brain.py orphans
python digital-brain/dependency-brain.py catalog siweb   # las interfaces de un sistema
python digital-brain/dependency-brain.py gaps            # apps del Anexo 5 sin nodo
```

---

## PIPELINE CANÓNICO DE REBUILD

```bash
# 1. Reconstruir vocabulario (cuando hay términos nuevos)
python generators/build-vocab-v1.py

# 2. Reconstruir bank-brain federado, que cierra construyendo el grafo
python digital-brain/build-bank-brain.py

# 3. Inicializar seed brains de sistemas descubiertos
python generators/initialize-seed-brains.py

# 4. Enriquecimiento estratégico (minutas, decisiones)
python generators/extract-strategic.py
python generators/enrich-strategic.py   # requiere ANTHROPIC_API_KEY

# El grafo solo, cuando cambió un brain de sistema y no hace falta rehacer todo
python generators/build-dependency-graph.py

# El catálogo de acciones solo, cuando cambia una autorización y no la base entera
python generators/load-action-catalog.py
```

---

*Última actualización: 2026-11-04 · v1.2 · Catálogo de Interfaces AS-IS como quinta fuente del grafo, con reorientación de las direcciones que ninguna fuente declaraba. v1.1: grafo de dependencias de la flota dentro de bank-brain.db. v1.0: estructura canónica, Regla V1 de vocabulario y capas HOY/AYER/MAÑANA.*