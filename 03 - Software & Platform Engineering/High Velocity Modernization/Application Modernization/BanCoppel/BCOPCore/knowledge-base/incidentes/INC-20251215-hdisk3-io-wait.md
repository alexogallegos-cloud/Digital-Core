# INC-20251215 — Saturación hdisk3 + Encolamiento SPEI/Autorizador · BanCoppel
> **Clasificación**: N5 — Servicio de pagos fuera de SLA con saturación total de disco
> **Duración**: 7.5 horas (el más largo de la serie Nov-Dic 2025)
> **Fecha**: 2025-12-15 (lunes — quincena)
> **Estado**: Cerrado (resuelto en sesión)

---

## Resumen ejecutivo

El 15 de diciembre de 2025 ocurrió el incidente de mayor duración de la serie: 7.5 horas de degradación de pagos. La fecha coincidió con el pago de **quincena** (día 15 de diciembre), el pico de SPEI más alto del año — el volumen de SPEI entrantes llegó al **percentil 99** del año (2,543,037 transacciones). El diferenciador de este incidente fue la saturación de disco: `hdisk3` llegó al **100% de I/O wait**, que provocó que el subsistema de almacenamiento Informix bloqueara completamente las operaciones transaccionales.

---

## Contexto: por qué el 15-DIC era el día de mayor riesgo del año

El 15 de diciembre coincidió con:
- **Quincena de diciembre** — el pago de nómina más grande del año; todos los empleados de México reciben pago ese día
- **Aguinaldo en proceso** — muchos patrones pagan la primera quincena del aguinaldo el 15 de diciembre
- **Volumen SPEI históricamente más alto del año** — confirmado en datos: p99 del 2025

---

## Volumetría del día

| Canal | Volumen 15-DIC | Percentil histórico 2025 | Referencia |
|-------|---------------|--------------------------|------------|
| E-Global (pagos totales) | 2,673,498 txn | **p87** | — |
| SPEI entrantes | 2,543,037 txn | **p99** | Top 1% del año — pico máximo de la serie |
| Pico por hora (17h CST) | ~369,000 txn | Mayor pico horario observado | — |

El p99 de SPEI es el umbral donde el forking de procesos AIX alcanza su máximo observado (72 procesos). Ningún incidente de la serie superó este nivel de SPEI.

---

## Cadena de fallo

```
1. SPEI quincena-diciembre: volumen p99 del año (2.54M txn)
   ↓
2. SPEI forkea 72 procesos en AIX (vs 1-5 nominal)
   ↓
3. hdisk3 satura al 100% de I/O wait
   Las operaciones de escritura Informix se bloquean en cola de I/O
   ↓
4. AIX OS + Firma Digital alcanzan saturación total
   Load Average Informix: 82-92%
   ↓
5. Informix OLTP no puede completar ninguna transacción:
   193+ buffer waits simultáneos en stored procedures SPL
   Toda la actividad transaccional queda en espera de I/O
   ↓
6. Autorizador Java agota sus 25 conexiones directas a Informix
   Queue Mensajes: encolamiento masivo
   ↓
7. e-Global supera SLA 8 segundos → cancela transacciones masivamente
   ↓
8. Degradación sostenida durante 7.5 horas
```

---

## Métricas del incidente

| Métrica | Valor |
|---------|-------|
| Duración total | **7.5 horas** (máximo de la serie) |
| Load Average Informix | **82-92%** |
| Saturación hdisk3 | **100% I/O wait** |
| Hora de pico | ~17h CST |
| Volumen SPEI | p99 del año (2,543,037 txn) |
| Severidad | N5 |

---

## Causa raíz

**Saturación de disco hdisk3 por la combinación de SPEI quincena (p99) + Eglobal (p87) en concurrencia.** El I/O wait de hdisk3 al 100% fue el elemento diferenciador de este incidente frente a los demás: no era solo un problema de CPU o memoria, sino que el subsistema de almacenamiento se convirtió en el cuello de botella total, bloqueando toda operación transaccional de Informix.

Factores estructurales que amplificaron:
1. El SPEI forking lleva cargas de I/O adicionales sobre los mismos discos AIX
2. La Firma Digital genera I/O adicional en operaciones criptográficas
3. hdisk3 no tiene I/O distribuido ni SSD — es un disco compartido en el servidor POWER-AIX

---

## Hallazgo post-incidente: correlación hdisk3 y quincenas

La saturación de hdisk3 solo se manifestó en el incidente del 15-DIC porque fue el único día con SPEI p99. En días de quincena con menor volumen SPEI (p78-p93), el disco llegó al límite pero no al 100% — por eso la duración fue de 1.5 a 4.5 horas en esos casos, no 7.5 horas.

---

## Relación con otros incidentes

Este incidente es el máximo de la serie en duración y en volumen SPEI. Los días 17-DIC, 21-DIC y 23-DIC mostraron patrones similares pero con menor volumen de SPEI, lo que resultó en duraciones más cortas. La cadena de fallo es idéntica — la diferencia es el nivel de saturación.

Ver también:
- [INC-20251129](INC-20251129-encolamiento-autorizador-spei.md) — incidente anterior que estableció el patrón
- [INC-20251223](INC-20251223-eglobal-connection-leak.md) — identificación del connection leak que agravó los incidentes posteriores
- [knowledge-base/autorizador/arquitectura-as-is.md](../autorizador/arquitectura-as-is.md) — cadena de fallo completa con contexto de capas

---

## Implicaciones para la migración

- hdisk3 es un punto único de fallo de I/O — el target en AWS Aurora PostgreSQL distribuye I/O por diseño (multi-AZ, storage layer EBS gp3 con IOPS configurables)
- El parallel-run durante quincenas de diciembre del año de migración debe planificarse con un plan de rollback de 30 minutos (no 7.5 horas)
- Los tests de performance del target deben validar el escenario p99 de SPEI explícitamente — la quincena de diciembre es el golden test de capacidad

---

*v1.0.0 · 2026-08-07 · Fuente: análisis de volumetría Excel (Master_Transacciones + Medios_de_Pago) + diagnóstico arquitectónico enero 2026*
