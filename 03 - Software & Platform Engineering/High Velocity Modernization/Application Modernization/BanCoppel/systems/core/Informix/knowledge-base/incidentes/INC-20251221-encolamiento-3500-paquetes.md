# INC-20251221 — Encolamiento 3,500 Paquetes · BanCoppel
> **Clasificación**: N3 — Degradación transitoria de pagos (1.5h)
> **Duración**: 1.5 horas
> **Fecha**: 2025-12-21 (domingo)
> **Estado**: Cerrado (resuelto en sesión)

---

## Resumen ejecutivo

El 21 de diciembre de 2025, la cola del Autorizador alcanzó **3,500 paquetes** (vs umbral diseñado de 2). La duración fue de 1.5 horas — la más corta de los incidentes con encolamiento masivo de la serie. La resolución más rápida puede explicarse por la intervención del equipo de operaciones, que posiblemente reinició el Autorizador o liberó las conexiones manualmente, o porque el volumen se disipó naturalmente al ser domingo por la tarde.

---

## Contexto

El 21 de diciembre era domingo, período de aguinaldo (semana previa a Navidad). Los volúmenes fueron:
- E-Global p59: volumen moderado, por debajo del promedio
- SPEI p35: volumen bajo

La combinación p59 + p35 produjo un incidente de 1.5 horas y 3,500 paquetes en cola. La diferencia de resolución rápida (vs 5.7h del 17-DIC con p64 similar) sugiere que o la intervención fue más rápida, o el estado del sistema era mejor que el 17-DIC.

---

## Volumetría del día

| Canal | Volumen 21-DIC | Percentil histórico 2025 | Referencia |
|-------|---------------|--------------------------|------------|
| E-Global (pagos totales) | 2,502,902 txn | **p59** | Moderado |
| SPEI entrantes | 1,395,921 txn | **p35** | Bajo |
| Pico por hora (14h CST) | ~288,000 txn | — | — |

---

## Métricas del incidente

| Métrica | Valor |
|---------|-------|
| Duración total | **1.5 horas** |
| Cola Autorizador pico | **3,500 paquetes** (vs umbral=2) |
| Hora de pico | ~14h CST |
| Volumen E-Global | p59 |
| Volumen SPEI | p35 |
| Severidad | N3 |

---

## Causa raíz

**Encolamiento del Autorizador por el mismo mecanismo estructural de los incidentes anteriores** — sin connection pool, sin load balancing. La resolución más rápida se atribuye a menor volumen concurrente o a intervención activa del equipo de operaciones.

---

## Relación con otros incidentes

Este es el incidente de menor severidad de la serie. Su relevancia está en que confirma el patrón: **cualquier día con más de p50 en E-Global produce riesgo de encolamiento**, independientemente del volumen SPEI.

Ver también:
- [INC-20251223](INC-20251223-eglobal-connection-leak.md) — 2 días después, connection leak identificado explícitamente
- [knowledge-base/autorizador/arquitectura-as-is.md](../autorizador/arquitectura-as-is.md) — cadena de fallo completa

---

## Implicaciones para la migración

- El umbral de la cola diseñado en 2 paquetes es evidentemente erróneo para las cargas actuales — el target debe redimensionarlo con base en los percentiles P95-P99 reales (3,272-3,400 txn/min para SPEI; 3,400 para E-Global)
- La instrumentación de alerta debe disparar a 10% del umbral real (no del umbral de diseño), para permitir intervención preventiva

---

*v1.0.0 · 2026-08-07 · Fuente: análisis de volumetría Excel + diagnóstico arquitectónico enero 2026*
