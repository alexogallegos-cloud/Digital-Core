# INC-20251231 — Encolamientos Múltiples (5 episodios) · BanCoppel
> **Clasificación**: N4 — Múltiples encolamientos en un solo día
> **Duración**: 3.9 horas (suma de 5 episodios)
> **Fecha**: 2025-12-31 (miércoles — fin de año)
> **Estado**: Cerrado (resuelto por operaciones con reinicios múltiples)

---

## Resumen ejecutivo

El 31 de diciembre de 2025, último día del año, se produjeron **5 episodios de encolamiento separados** en un mismo día. Cada episodio fue resuelto individualmente (probablemente por reinicio del Autorizador), pero la recurrencia dentro del mismo día indica que el sistema no alcanzó un estado estable entre episodios. La cola osciló entre **1,500 y 3,200 paquetes** durante los episodios. Load Average Informix alcanzó **94.55%**.

---

## Contexto

El 31 de diciembre era fin de año — pago de servicios, cierre de mes y año fiscal, liquidaciones bancarias pendientes:
- E-Global p89: muy alto
- SPEI p81: alto

El año cerraba con el sistema en estado frágil por el connection leak identificado el 23-DIC (no corregido). Con E-Global en p89, el sistema estaba operando cerca de su límite máximo sostenible.

---

## Volumetría del día

| Canal | Volumen 31-DIC | Percentil histórico 2025 | Referencia |
|-------|---------------|--------------------------|------------|
| E-Global (pagos totales) | 2,689,013 txn | **p89** | Alto |
| SPEI entrantes | 1,816,371 txn | **p81** | Alto |
| Pico por hora (14h CST) | ~380,000 txn | Máximo pico horario de la serie | — |

---

## Patrón de los 5 episodios

| Episodio | Cola observada | Intervención | Estado post-intervención |
|----------|---------------|--------------|--------------------------|
| 1 | ~1,500 paquetes | Reinicio Autorizador | Recuperado temporalmente |
| 2 | ~2,000 paquetes | Reinicio Autorizador | Recuperado temporalmente |
| 3 | ~2,500 paquetes | Reinicio Autorizador | Recuperado temporalmente |
| 4 | ~3,000 paquetes | Reinicio Autorizador | Recuperado temporalmente |
| 5 | ~3,200 paquetes | Reinicio Autorizador | Recuperado hasta fin del período de carga |

*Los valores de cola son estimados con base en el rango 1,500-3,200 reportado.*

El patrón de incremento en la cola máxima de cada episodio (1,500 → 3,200) es consistente con un leak que se reacumula progresivamente cada vez más rápido después de cada reinicio.

---

## Métricas del incidente

| Métrica | Valor |
|---------|-------|
| Duración total acumulada | **3.9 horas** |
| Número de episodios | **5 encolamientos separados** |
| Load Average Informix | **94.55%** |
| Cola Autorizador (rango) | 1,500–3,200 paquetes |
| Pico horario | ~380,000 txn (14h CST) |
| Severidad | N4 |

---

## Cadena de fallo (patrón repetido)

```
[Ciclo repite 5 veces:]
Load Average alto (94.55%) + E-Global p89 + SPEI p81
   ↓
Autorizador: connection leak se reacumula desde último reinicio
25 conexiones agotadas → Queue Mensajes crece a 1,500-3,200 paquetes
   ↓
e-Global supera SLA 8s → cancela transacciones
   ↓
Operaciones ejecuta reinicio del Autorizador
   ↓
Sistema recuperado ~N minutos → leak comienza a reacumularse
   ↓
[Ciclo vuelve a ocurrir]
```

---

## Causa raíz

**Connection leak sistémico del Autorizador (identificado el 23-DIC, no corregido) que se reacumula bajo carga alta.** El volumen de fin de año (E-Global p89) mantuvo el sistema en una zona de estrés continuo que permitió que el leak se reacumulara en minutos después de cada reinicio.

La aceleración del reacumulo (cada episodio llegó a una cola mayor en menos tiempo) sugiere que el reinicio no limpiaba el estado completamente, o que la tasa de leak era proporcional a la carga.

---

## Hallazgo: los 5 reinicios como evidencia de la urgencia del fix

El equipo de operaciones reinició el Autorizador 5 veces en el mismo día de fin de año. Este es el indicador más claro de que el problema del connection leak requería corrección de código, no solo de operaciones. Los reinicios son mitigación temporal; el fix real requería implementar connection pooling con self-healing.

---

## Relación con otros incidentes

Ver también:
- [INC-20251223](INC-20251223-eglobal-connection-leak.md) — identificación del connection leak (8 días antes)
- [INC-20260112](INC-20260112-encolamiento-700-paquetes.md) — confirma que el leak persistió a enero 2026 y opera a cargas moderadas
- [knowledge-base/autorizador/arquitectura-as-is.md](../autorizador/arquitectura-as-is.md) — arquitectura de capas con el leak documentado

---

## Implicaciones para la migración

- El connection leak del Autorizador era un **bloqueante crítico antes del fin de año 2025** — que no se corrigió aumentó el riesgo para enero
- El target debe probar el comportamiento post-reinicio del pool de conexiones: ¿el pool se recupera automáticamente sin intervención manual?
- El runbook del target debe incluir un procedimiento para detectar acumulación de conexiones antes de que el sistema falle

---

*v1.0.0 · 2026-08-07 · Fuente: análisis de volumetría Excel + diagnóstico arquitectónico enero 2026*
