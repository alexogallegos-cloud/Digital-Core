# Ground Truth — Métricas de Grafo · SISTEMA-CORE-UNISYS

> Computado del grafo generado (seed 2200). El grafo es la fuente de verdad.

| Métrica | Valor |
|---------|-------|
| Nodos (programas/objetos) | 830 |
| Aristas (dependencias de llamada) | 4061 |
| Densidad | 0.00590 |
| Grado de salida promedio | 4.89 |
| Fan-in máximo (top hub: ULOGWRT) | 790 |
| SCCs no triviales (ciclos) | 9 |
| Componentes débilmente conexas (WCC) | 5 |
| Nodos no alcanzables desde entry points | 114 |
| Modularidad Q (partición por dominio) | 0.345 |

**Lectura:** densidad baja pero fan-in altísimo concentrado en pocos hubs = firma
scale-free. Q ~ 0.3-0.5 indica comunidades reales pero con fuga (no es 1.0 porque
los dominios se acoplan vía hubs y leakage). 5 WCC => hay al menos una
isla desconectada (cluster muerto).
