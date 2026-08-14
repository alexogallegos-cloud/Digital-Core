# Ground Truth — Metricas de Grafo · openpay-gateway

> Computado del grafo generado (seed 920). El grafo es la fuente de verdad.

| Metrica | Valor |
|---------|-------|
| Nodos (clases) | 672 |
| Aristas (dependencias de llamada) | 3335 |
| Densidad | 0.00740 |
| Grado de salida promedio | 4.96 |
| Fan-in maximo (top hub: JsonUtils) | 493 |
| SCCs no triviales (ciclos) | 12 |
| Componentes debilmente conexas (WCC) | 4 |
| Nodos no alcanzables desde entry points | 62 |
| Modularidad Q (particion por dominio) | 0.374 |

**Lectura:** densidad baja pero fan-in altisimo concentrado en pocos hubs = firma
scale-free. Q ~ 0.3-0.5 indica comunidades reales pero con fuga (no es 1.0 porque
los dominios se acoplan via hubs y leakage). 4 WCC => hay al menos una
isla desconectada (cluster muerto legacy.oldreports).
