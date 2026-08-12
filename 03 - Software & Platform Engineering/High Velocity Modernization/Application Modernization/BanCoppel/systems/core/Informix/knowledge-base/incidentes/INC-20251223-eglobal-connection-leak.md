# INC-20251223 — eGlobal Connection Leak Identificado · BanCoppel
> **Clasificación**: N5 — Fallo sistémico por agotamiento de conexiones con deuda técnica identificada
> **Duración**: 23 minutos (resolución rápida por reinicio del Autorizador)
> **Fecha**: 2025-12-23 (martes — pre-Navidad)
> **Estado**: Cerrado (resuelto por reinicio)

---

## Resumen ejecutivo

El 23 de diciembre de 2025 ocurrió el incidente de mayor Load Average de toda la serie: **127%** en Informix. La duración fue solo 23 minutos porque el equipo de operaciones identificó y ejecutó un reinicio del Autorizador para liberar las conexiones. La contribución crítica de este incidente a la documentación de la serie es que **el connection leak de e-Global fue identificado explícitamente** como causa raíz — las 25 conexiones directas del Autorizador a Informix no se liberaban correctamente, lo que causaba agotamiento de conexiones incluso a cargas menores.

---

## Contexto

El 23 de diciembre era día laborable pre-Navidad, con volumen elevado (la semana del 23-24 concentra pagos de fin de año):
- E-Global p95: alto (segundo día con mayor volumen de la serie)
- SPEI p78: por encima del promedio

La combinación p95 + p78 con Load Average de 127% superó incluso al 15-DIC en carga de CPU/OS.

---

## Volumetría del día

| Canal | Volumen 23-DIC | Percentil histórico 2025 | Referencia |
|-------|---------------|--------------------------|------------|
| E-Global (pagos totales) | 2,780,709 txn | **p95** | Segundo más alto de la serie |
| SPEI entrantes | 1,774,917 txn | **p78** | Alto |
| Pico por hora (14h CST) | ~340,000 txn | — | — |

---

## Cadena de fallo

```
1. E-Global p95 + SPEI p78 — alta concurrencia
   ↓
2. Load Average Informix alcanza 127%
   (máximo de la serie — supera el 94.55% del 31-DIC)
   ↓
3. Autorizador: las 25 conexiones directas se agotan
   En este incidente se identifica que las conexiones NO se liberan
   tras completar las transacciones — connection leak confirmado
   ↓
4. Queue Mensajes: encolamiento masivo en minutos
   ↓
5. e-Global supera SLA 8 segundos → cancela transacciones
   ↓
6. Equipo de operaciones ejecuta reinicio del Autorizador
   Las 25 conexiones se liberan al reiniciar
   ↓
7. Sistema se recupera en 23 minutos
```

---

## Métricas del incidente

| Métrica | Valor |
|---------|-------|
| Duración total | **23 minutos** |
| Load Average Informix | **127%** (máximo de la serie) |
| Volumen E-Global | p95 (2,780,709 txn) |
| Volumen SPEI | p78 |
| Hora de pico | ~14h CST |
| Severidad | N5 (por identificación de deuda técnica crítica) |

---

## Hallazgo crítico: connection leak identificado

Este es el incidente más importante de la serie para el diagnóstico de la deuda técnica, no por su duración sino por lo que reveló:

**El Autorizador Java tiene un connection leak.** Las 25 conexiones directas a Informix (sin pool, sin self-healing) no se liberan correctamente al finalizar las transacciones. El leak se acumula hasta que las 25 conexiones están "en uso" aunque ninguna transacción activa las esté usando realmente. El único mecanismo de recuperación disponible era el **reinicio manual del Autorizador**.

Las consecuencias de este hallazgo se materializaron plenamente en el incidente del **12 de enero de 2026** (INC-20260112), cuando el sistema falló con Load Average de solo 50% porque el leak se había vuelto permanente.

---

## Causa raíz

**Agotamiento de conexiones del Autorizador por connection leak no corregido.** El Load Average de 127% actuó como detonante que aceleró el leak; pero la deuda técnica subyacente (connection leak + sin pool + sin self-healing) habría producido el mismo resultado en cualquier momento.

---

## Relación con otros incidentes

Este incidente es el punto de inflexión de la serie:
- **Antes del 23-DIC**: los incidentes eran causados por volumen + saturación (picos de carga)
- **Después del 23-DIC**: el sistema era susceptible de fallo incluso a cargas moderadas debido al leak acumulado

Ver también:
- [INC-20251231](INC-20251231-encolamientos-multiples.md) — 8 días después, 5 encolamientos separados
- [INC-20260112](INC-20260112-encolamiento-700-paquetes.md) — confirmación del leak sistémico a carga baja
- [knowledge-base/autorizador/arquitectura-as-is.md](../autorizador/arquitectura-as-is.md) — arquitectura de la capa Autorizador

---

## Implicaciones para la migración

- El connection leak **debe ser corregido antes del cutover** — si se replica el comportamiento del Autorizador Java contra el nuevo backend, el leak continuará y el sistema fallará con las mismas cargas moderadas
- El target debe usar **HikariCP** (o equivalente) con pool de conexiones, timeout de conexión, y validación de estado de conexión antes de uso
- La corrección del leak debe validarse con un test de larga duración (≥ 24 horas con carga P95 sostenida) antes de ir al parallel-run

---

*v1.0.0 · 2026-08-07 · Fuente: análisis de volumetría Excel + diagnóstico arquitectónico enero 2026*
