# Ground Truth — Consulta vs Actualizacion (CQRS) · openpay-gateway

> Como se sabe que endpoints son de **solo consulta** y cuales de **actualizacion**?
> Por analisis estatico del cierre de llamadas: una clase es de **actualizacion** si
> su cierre alcanza una escritura al sistema de registro (`JdbcWriteGateway` /
> `repository.save()`); de **consulta** si alcanza lectura (`JdbcReadGateway`) pero **nunca**
> una escritura; `none` si no toca datos.

## Resumen del sistema
| Tipo | Clases |
|------|--------|
| Consulta (read-only) | 261 |
| Actualizacion (transaccional) | 379 |
| Sin acceso a datos (compute/util) | 32 |

## Por capa
| Capa | Consulta | Actualizacion | Sin acceso | Total |
|------|---------:|--------------:|-----------:|------:|
| JOB | 34 | 85 | 0 | 119 |
| WEB | 66 | 54 | 0 | 120 |
| SERVICE | 117 | 192 | 22 | 331 |
| REPO | 43 | 47 | 0 | 90 |
| UTIL | 1 | 1 | 10 | 12 |

## Por dominio
| Dominio | Consulta | Actualizacion | Sin acceso | Total |
|---------|---------:|--------------:|-----------:|------:|
| channels | 23 | 34 | 0 | 57 |
| compliance | 22 | 40 | 0 | 62 |
| finance | 29 | 59 | 0 | 88 |
| infra | 28 | 46 | 0 | 74 |
| merchants | 23 | 36 | 0 | 59 |
| payments | 40 | 57 | 0 | 97 |
| risk-fraud | 36 | 41 | 0 | 77 |
| security | 34 | 33 | 0 | 67 |
| terminals | 25 | 32 | 0 | 57 |

## Endpoints WEB (la capa de cara al usuario)
De **120** controllers: **66** son de consulta y **54**
de actualizacion. Esa separacion es la base del analisis CQRS.

## Implicacion de migracion
| Tipo | Riesgo | Estrategia destino | Cuando migrar |
|------|--------|--------------------|---------------|
| **Consulta** | Bajo | CQRS read-model · replica de lectura · cache · API facade read-only | Temprano (waves iniciales) — bajo riesgo, valor rapido |
| **Actualizacion** | Alto | Nucleo transaccional ACID · saga/outbox · doble escritura controlada | Tardio — requiere shadow period y validacion regulatoria |

`[BENCHMARK]` Recuperar esta clasificacion = recall sobre las 379
clases de actualizacion (no perder ninguna: un escritor mal clasificado como
consulta corrompe datos). El falso-positivo barato es marcar consulta como
actualizacion; el caro y peligroso es lo contrario.
