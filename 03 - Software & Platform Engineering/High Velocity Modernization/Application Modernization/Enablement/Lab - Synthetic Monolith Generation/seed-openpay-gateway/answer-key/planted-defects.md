# Planted Defects · openpay-gateway (escala / topologia)

> A esta escala los "defectos" son propiedades de topologia, no lineas de codigo.
> Todos computados del grafo (seed 920).

| # | Tipo | Cantidad | Donde verlo |
|---|------|----------|-------------|
| T1 | Hubs scale-free (god utils + enablers) | top 20 | ground-truth-hubs.md |
| T2 | Ciclos / SCCs no triviales (Spring circular deps) | 12 | ground-truth-cycles.md |
| T3 | Cluster muerto plantado (legacy.oldreports) | 22 clases | ground-truth-dead-clusters.md |
| T4 | Huerfanos emergentes (sin caller) | 40 | ground-truth-dead-clusters.md |
| T5 | Fuga entre dominios (SERVICE->SERVICE cross) | ~18% de SERVICE->SERVICE | ground-truth-communities.md |
| T6 | Acoplamiento por DTO compartido (oculto) | 33 DTOs | ground-truth-dto-coupling.md |
| T7 | Componentes desconectadas (WCC) | 4 | ground-truth-graph-metrics.md |
| T8 | 9 enablers seam (hubs nombrados) | 9 | ground-truth-enabler-seams.md |

## Como puntuar
Entregar `graph/dependency-graph.json` (sin `dto-coupling.json` ni answer-key) a la
herramienta de discovery o al RE specialist y medir:
- **Hubs:** recall del top-20 por fan-in (incluye los 9 enablers).
- **Ciclos:** SCCs recuperados / 12.
- **Comunidades:** pureza vs. particion por dominio (Q ground-truth = 0.374).
- **Dead code:** recall del cluster LegacyReport* + huerfanos.
- **Acoplamiento por DTO:** la herramienta lo ve sin el call graph? (revelador).
- **Enablers:** recupera los 9 seams y los ordena por blast radius? (cose con Fase 1).
