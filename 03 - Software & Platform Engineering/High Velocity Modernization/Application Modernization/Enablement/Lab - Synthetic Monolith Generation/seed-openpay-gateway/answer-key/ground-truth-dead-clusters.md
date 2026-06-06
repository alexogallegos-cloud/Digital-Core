# Ground Truth — Clusters Muertos / Codigo Inalcanzable · openpay-gateway

> Subsistemas que ya nadie invoca pero siguen empaquetados en el WAR. En un sistema
> real son clusters enteros (paquetes completos), no una clase suelta.

- Total no alcanzable desde entry points (WEB + JOB): **62**
- Cluster muerto plantado (`legacy.oldreports.*`, dominio 'obsolete'): **22** clases
  (isla LegacyReport*, con aristas internas pero sin inbound del grafo vivo)
- Otros nodos huerfanos emergentes (sin caller, no plantados): **40**
  -> realismo: services que ningun controller/job/service alcanza

`[BENCHMARK]` Distinguir el cluster muerto plantado (LegacyReport*) de los huerfanos
emergentes es el reto. Ambos son candidatos a Retire, pero los emergentes requieren
validar en logs de produccion antes de descartar (shadow execution / APM).
