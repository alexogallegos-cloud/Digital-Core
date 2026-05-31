# Ground Truth — Clusters Muertos / Código Inalcanzable · SISTEMA-CORE-UNISYS

> Subsistemas que ya nadie invoca pero siguen en la librería. En un sistema real
> son clusters enteros, no un programa suelto.

- Total no alcanzable desde entry points (WFL + ONLINE): **114**
- Cluster muerto plantado (dominio 'obsolete'): **30** nodos
  (isla ZZDEAD*, con aristas internas pero sin inbound del grafo vivo)
- Otros nodos huérfanos emergentes (sin caller, no plantados): **84**
  → realismo: programas BL que ningún WFL/ONLINE/BL alcanza

`[BENCHMARK]` Distinguir el cluster muerto plantado (ZZDEAD*) de los huérfanos
emergentes es el reto. Ambos son candidatos a Retire, pero los emergentes requieren
validar en logs de producción antes de descartar (shadow execution).
