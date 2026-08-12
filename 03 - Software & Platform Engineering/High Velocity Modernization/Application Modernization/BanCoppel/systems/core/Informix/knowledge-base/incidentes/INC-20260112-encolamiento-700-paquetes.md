# INC-20260112 — Encolamiento Sistémico a Carga Baja · BanCoppel
> **Clasificación**: N4 — Connection leak sistémico que opera a cargas moderadas
> **Duración**: 6.58 horas (segunda más larga de la serie)
> **Fecha**: 2026-01-12 (lunes)
> **Estado**: Cerrado

---

## Resumen ejecutivo

El 12 de enero de 2026 ocurrió el incidente más significativo para el diagnóstico de la deuda técnica: el sistema falló durante **6.58 horas** con un **Load Average de apenas 50%** y un volumen de E-Global en el **percentil 15** del año. La cola del Autorizador alcanzó solo 700 paquetes (vs 3,285 en incidentes anteriores), pero el sistema tardó casi 7 horas en recuperarse.

Este incidente confirma que el **connection leak de e-Global se había vuelto sistémico**: el Autorizador ya no necesitaba cargas altas para fallar — agotaba sus 25 conexiones directas a Informix incluso en días de bajo volumen.

---

## Contexto: por qué el 12-ene es el incidente más revelador

En todos los incidentes anteriores de la serie (Nov-Dic 2025), existía una correlación entre alto volumen y la degradación. El 12 de enero rompe ese patrón:

| Incidente | Load Avg | E-Global percentil | SPEI percentil | Duración |
|-----------|----------|-------------------|----------------|----------|
| 15-DIC (peor volumen) | 82-92% | p87 | **p99** | 7.5 h |
| 23-DIC (mayor load avg) | **127%** | p95 | p78 | 23 min |
| **12-ENE (menor volumen)** | **50%** | **p15** | **p48** | **6.58 h** |

El 12-ene tuvo la menor carga de la serie y la segunda duración más larga. La desconexión entre carga y duración es la evidencia definitiva de degradación sistémica.

---

## Volumetría del día

| Canal | Volumen 12-ENE | Percentil histórico | Referencia |
|-------|---------------|---------------------|------------|
| E-Global (pagos totales) | 2,289,073 txn | **p15** | Bottom 15% del año — día de bajo volumen |
| SPEI entrantes | 1,489,676 txn | **p48** | Cerca del promedio histórico |
| Cola Autorizador | 700 paquetes | — | Baja vs 3,285 del pico Nov-Dic |
| Load Average Informix | **50%** | — | Mitad de la capacidad nominal |

---

## Cadena de fallo

```
1. Sistema abre el día-12 con connection leak acumulado desde dic-2025
   (no hubo fix de código entre 23-DIC y 12-ENE)
   ↓
2. E-Global p15 comienza a procesar transacciones normales
   Cada transacción solicita una conexión → el leak no libera correctamente
   ↓
3. 25 conexiones directas Autorizador→Informix se agotan
   En un sistema sano esto requería carga p80-p99
   En este estado, ocurrió con carga p15
   ↓
4. Queue Mensajes llega a 700 paquetes
   (menor que Nov-Dic pero suficiente para superar el SLA de 8s)
   ↓
5. e-Global cancela transacciones → degradación del servicio
   ↓
6. Sistema tarde 6.58 horas en recuperarse
   (posiblemente porque el equipo de operaciones no detectó el patrón
   de bajo volumen con mismo síntoma, o porque el leak requirió
   múltiples reinicios para estabilizarse)
```

---

## Métricas del incidente

| Métrica | Valor |
|---------|-------|
| Duración total | **6.58 horas** |
| Load Average Informix | **50%** |
| Cola Autorizador | 700 paquetes |
| Volumen E-Global | p15 (2,289,073 txn) — bajo |
| Volumen SPEI | p48 (1,489,676 txn) — promedio |
| Severidad | N4 |

---

## Causa raíz

**Connection leak sistémico en el Autorizador: las 25 conexiones directas a Informix se agotan independientemente del volumen de transacciones.** El leak se había vuelto permanente entre el 23-DIC y el 12-ENE: el Autorizador ya no podía atender ningún volumen sostenido sin agotar sus conexiones.

La duración de 6.58 horas con solo 700 paquetes en cola (vs 23 minutos con 127% Load Average el 23-DIC) sugiere que:
1. El equipo de operaciones tardó más en identificar el síntoma (bajo volumen = no coincide con el patrón conocido)
2. El estado del leak era más profundo — requirió más tiempo o más reinicios para estabilizar

---

## Hallazgo: el punto de inflexión hacia fallo continuo

Este incidente marcó el inicio de una nueva fase del problema: **el sistema era inestable por diseño**, no solo en días de alta carga. Sin corrección del connection leak, cualquier día laborable con E-Global por encima de p15 era candidato a incidente.

Los datos de enero-julio 2026 (Medios_de_Pago.xlsx) muestran crecimiento del 12% en volumen E-Global — lo que significa que el umbral de fallo sistémico se alcanzaría cada vez más frecuente si no se corrigía la deuda técnica.

---

## Relación con otros incidentes

Este es el último incidente documentado en la serie. Su importancia es que establece:
- El connection leak era la causa raíz primaria desde al menos el 23-DIC
- El sistema era funcionalmente inestable en enero 2026
- La corrección urgente era el connection pooling en el Autorizador Java

Ver también:
- [INC-20251223](INC-20251223-eglobal-connection-leak.md) — identificación del connection leak
- [INC-20251231](INC-20251231-encolamientos-multiples.md) — 5 episodios el 31-DIC
- [knowledge-base/cross-reference/performance-baseline-autorizador-spei.md](../cross-reference/performance-baseline-autorizador-spei.md) — baseline de capacidad y contexto de crecimiento

---

## Implicaciones para la migración

Este incidente define los **requisitos no negociables del target**:

1. **Connection pooling con self-healing es requisito de entrada al BUILD** del Autorizador Java modernizado. Sin este fix, el nuevo backend heredará el mismo comportamiento
2. El **parallel-run debe incluir un test de duración de 72 horas** bajo carga sostenida P50 para confirmar que el pool no desarrolla un leak similar
3. El **runbook del target debe incluir métricas de conexiones activas en pool** como SLO operacional (alertar si conexiones activas > 80% del pool durante > 5 minutos)
4. La corrección del leak debe **certificarse antes de iniciar el parallel-run** — no puede ser un hallazgo durante el parallel-run

---

*v1.0.0 · 2026-08-07 · Fuente: análisis de volumetría Excel (Master_Transacciones + Medios_de_Pago) + diagnóstico arquitectónico enero 2026 · Incidente de diagnóstico más relevante de la serie*
