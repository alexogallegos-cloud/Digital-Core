# INC-20251129 — Encolamiento Autorizador + SPEI · BanCoppel
> **Clasificación**: N5 — Impacto en producción con afectación económica documentada
> **Duración**: 4.5 horas
> **Fecha**: 2025-11-29 (sábado — fin de mes)
> **Estado**: Cerrado (resuelto en sesión)

---

## Resumen ejecutivo

El 29 de noviembre de 2025, BanCoppel experimentó una degradación severa del servicio de pagos durante 4.5 horas. El 69.71% de las transacciones de pago fueron declinadas. El impacto económico documentado fue de **$663 millones de pesos MXN**. La causa raíz fue la saturación del sistema Informix ante una combinación de alto volumen de pagos e-global (percentil 94 del año) y SPEI entrantes (percentil 93), que colapsó la cadena de autorización.

---

## Contexto: por qué el 29-NOV era un día de riesgo

El 29 de noviembre de 2025 coincidió con:
- **Fin de mes** — pago de servicios, nómina rezagada, liquidaciones bancarias
- **Sábado** — sin ventana de mantenimiento disponible
- El sistema no tenía mecanismos de protección ante picos de volumen: sin circuit breakers, sin load balancing, sin connection pool en el Autorizador

---

## Volumetría del día

| Canal | Volumen 29-NOV | Percentil histórico 2025 | Referencia |
|-------|---------------|--------------------------|------------|
| E-Global (pagos totales) | 2,774,814 txn | **p94** | Top 6% de días del año |
| SPEI entrantes | 2,099,188 txn | **p93** | Top 7% de días del año |
| Pico por hora (18h CST) | ~348,000 txn | Pico de tarde | Hora de mayor actividad |

La combinación simultánea de p94 (Eglobal) + p93 (SPEI) fue el detonante. Ambos canales compiten por los mismos recursos Informix — su concurrencia multiplicó la presión.

---

## Cadena de fallo

```
1. Volumen e-Global + SPEI entrantes simultáneamente altos (p94 + p93)
   ↓
2. SPEI forkea procesos en AIX: 72 procesos vs 1-5 nominal
   ↓
3. AIX OS y Firma Digital se saturan
   ↓
4. Informix OLTP degrada:
   Load Average: elevado (dato preciso no disponible para este incidente)
   193+ buffer waits en stored procedures SPL
   ↓
5. Autorizador Java agota sus 25 conexiones directas a Informix
   (sin pool de conexiones — sin mecanismo de self-healing)
   Queue Mensajes escala de umbral=2 hacia encolamiento masivo
   ↓
6. e-Global supera SLA 8 segundos → cancela transacciones automáticamente
   ↓
7. 69.71% de transacciones declinadas · $663 MDP de impacto
```

---

## Métricas del incidente

| Métrica | Valor |
|---------|-------|
| Duración total | 4.5 horas |
| Transacciones declinadas | **69.71%** |
| Impacto económico | **$663 millones MXN** |
| Hora de inicio estimada | ~17-18h CST (hora pico del día) |
| Severidad | N5 |

---

## Causa raíz

**Fallo de la cadena de autorización por sobresaturación de Informix ante concurrencia de flujos SPEI + e-Global.** Los puntos de fallo estructurales que amplificaron el impacto:

1. Sin connection pool en el Autorizador (25 conexiones fijas sin self-healing)
2. Sin load balancing en la capa de autorización
3. Forking excesivo de procesos SPEI en AIX
4. Sin circuit breaker que limitara el caudal entrante antes de la saturación

---

## Relación con otros incidentes

Este incidente estableció el patrón que se repetiría durante diciembre 2025. El sistema llegó al 29-NOV ya acumulando deuda técnica; los incidentes de diciembre confirman que no hubo mitigación estructural entre el 29-NOV y el fin de año.

Ver también:
- [INC-20251215](INC-20251215-hdisk3-io-wait.md) — 15 días después, con hdisk3 saturado
- [INC-20251223](INC-20251223-eglobal-connection-leak.md) — identificación explícita del connection leak
- [knowledge-base/autorizador/arquitectura-as-is.md](../autorizador/arquitectura-as-is.md) — arquitectura de capas y cadena de fallo completa

---

## Implicaciones para la migración

- El target debe demostrar que el mismo volumen p94+p93 no produce degradación — prerequisito del parallel-run
- El SLA de 8 segundos de e-Global con el nuevo backend debe mantenerse (≤ 4s en P95 para dejar margen)
- La aprobación del cutover requiere que el connection pool esté implementado y probado bajo carga antes de ir a producción

---

*v1.0.0 · 2026-08-07 · Fuente: análisis de volumetría Excel (Master_Transacciones + Medios_de_Pago) + diagnóstico arquitectónico enero 2026 · Datos económicos confirmados por el equipo BanCoppel*
