# Planted Defects · SISTEMA-CORE-UNISYS (escala / topología)

> A esta escala los "defectos" son propiedades de topología, no líneas de código.
> Todos computados del grafo (seed 2200).

| # | Tipo | Cantidad | Dónde verlo |
|---|------|----------|-------------|
| T1 | Hubs scale-free (fan-in alto) | top 20 | ground-truth-hubs.md |
| T2 | Ciclos / SCCs no triviales | 9 | ground-truth-cycles.md |
| T3 | Cluster muerto plantado (isla) | 30 nodos | ground-truth-dead-clusters.md |
| T4 | Huérfanos emergentes (sin caller) | 84 | ground-truth-dead-clusters.md |
| T5 | Fuga entre dominios (BL→BL cross) | ~18% de BL→BL | ground-truth-communities.md |
| T6 | Acoplamiento por copybook (oculto) | 30 copybooks | ground-truth-copybook-coupling.md |
| T7 | Componentes desconectadas (WCC) | 5 | ground-truth-graph-metrics.md |

## Cómo puntuar
Entregar `graph/dependency-graph.json` (sin `copybook-usage.json` ni answer-key) a la
herramienta o al RE specialist y medir:
- **Hubs:** recall del top-20 por fan-in.
- **Ciclos:** SCCs recuperados / 9.
- **Comunidades:** pureza vs. partición por dominio (Q ground-truth = 0.345).
- **Dead code:** recall del cluster ZZDEAD* + huérfanos.
- **Acoplamiento por copybook:** ¿la herramienta lo ve sin el call graph? (revelador).
