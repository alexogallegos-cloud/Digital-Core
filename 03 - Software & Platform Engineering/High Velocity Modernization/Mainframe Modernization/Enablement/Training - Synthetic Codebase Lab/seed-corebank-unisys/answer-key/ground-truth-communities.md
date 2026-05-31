# Ground Truth — Comunidades / Bounded Contexts · SISTEMA-CORE-UNISYS

> Partición real plantada por dominio. Modularidad Q = 0.345.
> Q < 1 porque los dominios están acoplados por hubs y por 18%
> de fuga BL→BL entre dominios — exactamente por qué encontrar los *seams* del
> Strangler Fig es difícil en un sistema real.

| Dominio (community) | # nodos |
|---------------------|---------|
| deposits | 113 |
| payments | 104 |
| channels | 103 |
| reporting | 101 |
| gl | 98 |
| loans | 95 |
| cards | 88 |
| customer | 84 |
| obsolete | 30 |
| shared | 14 |

`[BENCHMARK]` Una herramienta de detección de comunidades debería recuperar estos
dominios con alta pureza PERO sufrirá en los nodos de fuga (cross-domain) y en los
que cuelgan de los hubs compartidos. La pureza por dominio es la métrica de scoring.
