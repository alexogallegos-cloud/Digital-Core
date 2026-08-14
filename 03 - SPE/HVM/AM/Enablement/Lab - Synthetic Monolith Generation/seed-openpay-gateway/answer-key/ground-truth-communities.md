# Ground Truth — Comunidades / Bounded Contexts · openpay-gateway

> Particion real plantada por dominio. Modularidad Q = 0.374.
> Q < 1 porque los dominios estan acoplados por hubs y por 18%
> de fuga SERVICE->SERVICE entre dominios — exactamente por que encontrar los *seams*
> del Strangler Fig es dificil en un monolito real.

| Dominio (community) | # clases |
|---------------------|----------|
| payments | 97 |
| finance | 88 |
| risk-fraud | 77 |
| infra | 74 |
| security | 67 |
| compliance | 62 |
| merchants | 59 |
| terminals | 57 |
| channels | 57 |
| obsolete | 22 |
| shared | 12 |

`[BENCHMARK]` Una herramienta de deteccion de comunidades deberia recuperar estos
dominios con alta pureza PERO sufrira en los nodos de fuga (cross-domain) y en los
que cuelgan de los hubs compartidos. La pureza por dominio es la metrica de scoring.
