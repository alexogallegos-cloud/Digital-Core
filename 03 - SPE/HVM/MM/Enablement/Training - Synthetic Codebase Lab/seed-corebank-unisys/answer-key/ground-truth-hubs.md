# Ground Truth — Hubs (fan-in alto) · SISTEMA-CORE-UNISYS

> Los hubs son el corazón del hairball: utilerías llamadas por cientos de programas.
> Una herramienta de RE debe identificarlos como nodos de máximo riesgo de migración
> (tocarlos impacta a todo el sistema).

| # | Programa | Capa | Dominio | Fan-in |
|---|----------|------|---------|--------|
| 1 | ULOGWRT | UTIL | shared | 790 |
| 2 | UDATECONV | UTIL | shared | 453 |
| 3 | UDMSIIWR | UTIL | shared | 329 |
| 4 | UDMSIIRD | UTIL | shared | 271 |
| 5 | UCURRCNV | UTIL | shared | 35 |
| 6 | RPTD0078 | DA | reporting | 23 |
| 7 | UERRHND | UTIL | shared | 22 |
| 8 | UTRACE | UTIL | shared | 21 |
| 9 | PAYD0001 | DA | payments | 16 |
| 10 | CRDD0005 | DA | cards | 15 |
| 11 | PAYD0056 | DA | payments | 15 |
| 12 | CRDD0003 | DA | cards | 14 |
| 13 | CHND0008 | DA | channels | 14 |
| 14 | CHNB0388 | BL | channels | 13 |
| 15 | LONB0391 | BL | loans | 13 |
| 16 | CUSD0041 | DA | customer | 13 |
| 17 | PAYB0134 | BL | payments | 12 |
| 18 | CRDD0010 | DA | cards | 12 |
| 19 | GLD0011 | DA | gl | 12 |
| 20 | GLD0057 | DA | gl | 12 |

`[BENCHMARK]` Los hubs UTIL (DATECONV, ERRHND, DMSIIRD…) deben aparecer en el top.
Quien no los detecte subestimará el blast radius de cualquier cambio.
