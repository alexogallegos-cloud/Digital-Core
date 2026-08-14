# Source — openpay-gateway (monolito Java sintetico)

> Cero IP de cliente. Estructura inspirada en la topologia de un gateway de pagos
> fintech LATAM. Material **interno** de pursuit/training (no citar como diferenciador ACN).

A escala (~670 clases) este monolito se modela como **graph-as-data**: el sistema
completo vive como grafo en `../graph/dependency-graph.json` (el contrato con el
`Specialist - Reverse Engineering`). El codigo Java NO se escribe entero a mano.

Hay dos niveles de source:

| Carpeta | Que es | Cuando usarlo |
|---------|--------|---------------|
| `skeleton/` | Un `.java` **generado por nodo** (672 clases), coherente con el grafo: sus `import` = acoplamiento por DTO (`dto-coupling.json`), sus campos colaboradores = aristas del grafo. Lo emite `generator/generate_monolith.py`. | Navegacion: el visor "ver codigo fuente" del `monolith-graph-view.html` enlaza a estos. |
| `representative/` | Ejemplares **escritos a mano** de los hubs y de 2 bounded contexts enabler (tokenization PCI + config), con los **defectos plantados visibles** en codigo real. | Credibilidad del demo: mostrar como se ve realmente el tangle (god DTO, hardcoded values, ciclo Spring, acoplamiento por dato). |

## El stack (sintetico)

Java 8 · Spring MVC 4 · Apache Tomcat 8 · MySQL Aurora · empaquetado en **5 WARs**
(deployment components): `API`, `Dashboard`, `Manager`, `Vault`, `Paynet`.

## Lo que el discovery de Fase 0 debe encontrar (ver `../answer-key/`)

- **Hubs** (max blast radius): utilerias estaticas (`JsonUtils`, `MoneyUtils`, `AuditLogger`,
  los gateways JDBC) + los **9 `@Service` enabler** nombrados.
- **9 seams enabler** con fan-in = `regression_scope` del `fanout-graph.json`
  (RBAC 74, Config 68, Notifications 67, User 48, Vault 38, Tokenization 31,
  Document 28, BinManager 24, ApiKey 22) → lo que la Fase 1 extrae en waves.
- **Ciclos** entre `@Service` (circular bean deps parcheadas con `@Lazy`).
- **Cluster muerto** `legacy.oldreports.*` (empaquetado en el WAR, nadie lo llama).
- **Acoplamiento por DTO compartido** (`TransactionDTO`, `MoneyAmount`, `AccountingEntry`):
  el hairball oculto, invisible en el call graph.
- **CQRS**: clases read-only (wave temprana, bajo riesgo) vs update (nucleo ACID tardio).

## Regenerar

```
python generator/generate_monolith.py          # grafo + answer-key + skeleton
python "../../../Fase 0 - Discover/Specialist - Reverse Engineering/graph-viz/render_graph.py" \
       --graph graph/dependency-graph.json --out monolith-graph-view.html
```