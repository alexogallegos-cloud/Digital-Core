# Ground Truth — Consulta vs Actualización · SISTEMA-CORE-UNISYS

> ¿Cómo se sabe qué transacciones son de **solo consulta** y cuáles de **actualización**?
> Por análisis estático de los verbos de acceso a datos. Un programa es de
> **actualización** si su cierre de llamadas alcanza una escritura al sistema de
> registro (aquí, el wrapper `UDMSIIWR`); de **consulta** si alcanza lectura
> (`UDMSIIRD`) pero **nunca** una escritura; `none` si no toca la base.

## Resumen del sistema
| Tipo | Programas |
|------|-----------|
| Consulta (read-only) | 357 |
| Actualización (transaccional) | 461 |
| Sin acceso a datos (compute/util) | 12 |

## Por capa
| Capa | Consulta | Actualización | Sin acceso | Total |
|------|---------:|--------------:|-----------:|------:|
| WFL | 26 | 50 | 0 | 76 |
| ONLINE | 89 | 51 | 0 | 140 |
| BL | 190 | 300 | 0 | 490 |
| DA | 51 | 59 | 0 | 110 |
| UTIL | 1 | 1 | 12 | 14 |

## Por dominio
| Dominio | Consulta | Actualización | Sin acceso | Total |
|---------|---------:|--------------:|-----------:|------:|
| cards | 39 | 49 | 0 | 88 |
| channels | 55 | 48 | 0 | 103 |
| customer | 34 | 50 | 0 | 84 |
| deposits | 57 | 56 | 0 | 113 |
| gl | 41 | 57 | 0 | 98 |
| loans | 35 | 60 | 0 | 95 |
| payments | 53 | 51 | 0 | 104 |
| reporting | 42 | 59 | 0 | 101 |

## Transacciones ONLINE (la capa de cara al usuario)
De **140** transacciones ONLINE: **89** son de consulta y
**51** de actualización. Esa separación es la base del análisis CQRS.

## Implicación de migración
| Tipo | Riesgo | Estrategia destino | Cuándo migrar |
|------|--------|--------------------|---------------|
| **Consulta** | Bajo | CQRS read-model · réplica de lectura · caché · API facade de solo lectura | Temprano (waves iniciales) — bajo riesgo, valor rápido |
| **Actualización** | Alto | Núcleo transaccional ACID · saga/outbox · doble escritura controlada | Tardío — requiere shadow period y validación regulatoria |

`[BENCHMARK]` Recuperar esta clasificación = recall sobre los 461
programas de actualización (no perder ninguno: un escritor mal clasificado como
consulta corrompe datos). El falso-positivo barato es marcar consulta como
actualización; el caro y peligroso es lo contrario.

`[OBSERVACIÓN]` En un sistema real el escritor no es un solo wrapper: hay WRITE a
archivos secuenciales, puts a MQ, llamadas a otros sistemas de registro. El
análisis debe rastrear **todos** los sumideros de escritura, no uno.
