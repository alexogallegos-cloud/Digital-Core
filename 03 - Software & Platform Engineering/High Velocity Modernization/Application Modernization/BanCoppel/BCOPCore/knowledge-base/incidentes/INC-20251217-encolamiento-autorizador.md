# INC-20251217 — Encolamiento Autorizador · BanCoppel
> **Clasificación**: N4 — Degradación de pagos sin impacto económico documentado
> **Duración**: 5.7 horas
> **Fecha**: 2025-12-17 (miércoles)
> **Estado**: Cerrado (resuelto en sesión)

---

## Resumen ejecutivo

El 17 de diciembre de 2025, dos días después del peor incidente del año (INC-20251215), el sistema volvió a degradarse durante 5.7 horas. A diferencia del 15-DIC, este incidente ocurrió con volúmenes moderados: SPEI entrantes en percentil 28 (volumen normal) y E-Global en percentil 64. Sin embargo, Load Average de Informix llegó a **55-63%** — suficiente para saturar el Autorizador dado el estado degradado del sistema.

---

## Contexto: por qué el 17-DIC generó incidente con volumen moderado

El 17 de diciembre era día 17 de diciembre — sin quincena ni fin de mes. Los volúmenes eran:
- E-Global p64: volumen por encima del promedio pero no extremo
- SPEI p28: volumen claramente por debajo del promedio del año

La hipótesis central de este incidente: **el sistema no se recuperó completamente del INC-20251215** (48 horas antes). La deuda de sesiones abiertas, buffers sin liberar o configuraciones de Informix en estado degradado pueden generar un piso de inestabilidad que permite incidentes con cargas que normalmente serían manejables.

---

## Volumetría del día

| Canal | Volumen 17-DIC | Percentil histórico 2025 | Referencia |
|-------|---------------|--------------------------|------------|
| E-Global (pagos totales) | 2,518,750 txn | **p64** | Moderado-alto |
| SPEI entrantes | 1,334,866 txn | **p28** | Por debajo del promedio |
| Pico por hora (16h CST) | ~347,000 txn | — | — |

La combinación p64 + p28 no debería producir un incidente en un sistema sano. Que lo produjera durante 5.7 horas es una señal de degradación residual del sistema.

---

## Cadena de fallo

```
1. Sistema posiblemente en estado degradado residual del 15-DIC
   (sin recuperación completa en 48 horas)
   ↓
2. E-Global p64 activa el procesamiento normal con buffers comprometidos
   ↓
3. Load Average Informix alcanza 55-63%
   (menor que el 15-DIC pero suficiente para el estado comprometido)
   ↓
4. 193+ buffer waits activos en stored procedures SPL
   ↓
5. Autorizador Java: conexiones directas a Informix no responden en tiempo
   Queue Mensajes entra en encolamiento masivo
   ↓
6. e-Global supera SLA 8 segundos → cancela transacciones
   ↓
7. Degradación sostenida durante 5.7 horas
```

---

## Métricas del incidente

| Métrica | Valor |
|---------|-------|
| Duración total | **5.7 horas** |
| Load Average Informix | **55-63%** |
| Volumen E-Global | p64 (moderado) |
| Volumen SPEI | p28 (bajo) |
| Hora de pico | ~16h CST |
| Severidad | N4 |

---

## Causa raíz

**Encolamiento del Autorizador activado por carga moderada sobre un sistema aún no recuperado del INC-20251215.** La causa raíz subyacente es idéntica a los demás incidentes de la serie (sin connection pool, sin load balancing, forking SPEI), pero la anomalía es que el volumen era insuficiente para producir el incidente si el sistema estuviera en estado nominal.

---

## Hallazgo: patrón de recuperación incompleta

La secuencia 15-DIC (N5, 7.5h) → 17-DIC (N4, 5.7h) con solo 48 horas entre incidentes sugiere que:
1. No se realizó ninguna intervención estructural entre ambos incidentes
2. El sistema Informix no regresa a estado baseline de forma automática después de una saturación extrema
3. Buffer waits y estado de transacciones pendientes pueden persistir entre reinicio y recuperación

---

## Relación con otros incidentes

Ver también:
- [INC-20251215](INC-20251215-hdisk3-io-wait.md) — incidente inmediatamente anterior con p99 SPEI
- [INC-20251221](INC-20251221-encolamiento-3500-paquetes.md) — 4 días después, 3,500 paquetes en cola
- [knowledge-base/autorizador/arquitectura-as-is.md](../autorizador/arquitectura-as-is.md) — cadena de fallo completa

---

## Implicaciones para la migración

- El target debe incluir un proceso de health-check automático post-incidente que valide que el sistema regresó a estado baseline antes de considerarlo "recuperado"
- El runbook del target debe incluir un procedimiento de "cooldown" post-incidente mayor antes de declarar resolución
- El SRE debe instrumentar métricas de "tiempo de recuperación completa" (no solo tiempo hasta restaurar servicio)

---

*v1.0.0 · 2026-08-07 · Fuente: análisis de volumetría Excel + diagnóstico arquitectónico enero 2026*
