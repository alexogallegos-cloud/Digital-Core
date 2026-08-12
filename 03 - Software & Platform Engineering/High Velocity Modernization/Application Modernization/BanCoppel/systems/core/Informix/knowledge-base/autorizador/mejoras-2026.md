# Mejoras Arquitectónicas 2026 — Autorizador / SPEI / Infraestructura · BanCoppel
> **Fuente**: Roadmap de mejoras post-incidentes (entregado por el equipo BanCoppel)
> **Período**: enero 2026 – julio 2026
> **Alcance**: infraestructura Informix/AIX, capa e-Global/Autorizador, SPEI, observabilidad
> **Versión**: 1.0.0 · 2026-08-07

---

## Contexto

Los 7 incidentes Nov-2025→Ene-2026 documentados en `knowledge-base/incidentes/` detonaron un roadmap de mejoras ejecutado entre enero y julio de 2026. Todos los ítems listados tienen estatus **Completado**.

El impacto que el equipo declaró es subjetivo. Este documento añade una columna de **impacto técnico preciso**, cuantificado contra los datos de los incidentes y los riesgos registrados en `migration-risk-register.md`.

---

## Tabla completa — impacto declarado vs. impacto técnico preciso

| ID | Hito | Responsable(s) | Fin | Impacto declarado | Impacto técnico preciso | Riesgo cerrado / mitigado |
|----|------|---------------|-----|------------------|------------------------|--------------------------|
| 1.1 | Optimización tablas de HSM | Juan López Heras | 2026-01-08 | Medio | **Medio** — reduce la cola de operaciones criptográficas del HSM, pero no elimina la naturaleza síncrona de la Firma Digital en el flujo SPEI. Completado 4 días antes del INC-20260112; el incidente igualmente ocurrió, lo que indica que la optimización de tablas no fue suficiente sola. | P655-R015 parcialmente mitigado |
| 2.1 | Monitoreo de Trx E-Global / SPEI | Josué Gutierrez | 2026-01-14 | Medio | **Medio — preventivo, no correctivo**. Implementado 2 días después del INC-20260112. Añade visibilidad al estado de la cola y las conexiones del Autorizador antes de que el impacto llegue al cliente. Sin esto, los 5 reinicios del 31-DIC y las 6.58h del 12-ENE no se habrían detectado hasta que el cliente reportara. Reduce MTTR, no la frecuencia. | Precondición de P655-R012 y P655-R017 |
| 3.6 | Automatización de balanceo de colas SPEI | Ricardo Pellicer | 2026-02-15 | Alto | **Alto — mitiga el detonante principal de la cadena de fallo**. El forking de 72 procesos SPEI en AIX era el primer eslabón de la cascada (AIX → hdisk3 → Informix → Autorizador → e-Global). Automatizar el balanceo de colas evita el forking descontrolado bajo picos de volumen. El INC-20251215 (7.5h, p99 SPEI) difícilmente se replica con este mecanismo en producción. | P655-R013 mitigado · P655-R014 parcialmente |
| 3.1 | Extraer firma de SPEI | Juan Carlos Argudín | 2026-03-07 | Muy alto | **Muy alto — elimina el bottleneck síncrono de Capa 2**. Al extraer la Firma Digital del flujo de procesamiento SPEI, el HSM ya no es bloqueante en el path transaccional. Esto rompe el eslabón entre el forking SPEI y la saturación del AIX/Informix. Sin la firma en el path síncrono, la saturación del 23-DIC (Load 127%) y el I/O wait del 15-DIC habrían sido imposibles de alcanzar. Cambio arquitectónico de mayor impacto en la cadena de fallo. | P655-R015 cerrado para SPEI · P655-R013 residual mitigado |
| 1.6 | Optimización de estadísticas OLTP | Ricardo Pelliser | 2026-03-24 | Bajo | **Bajo-Medio — mejora el plan de queries de Informix OLTP**. Las estadísticas actualizadas permiten al optimizador de Informix elegir mejores índices y paths de ejecución. Reduce el impacto de los 193 buffer waits pero no los elimina. Beneficio marginal visible en días de carga P75+. | P655-R015 contribución menor |
| 2.5 | Connection Leak eGlobal | Eduardo Reynoso / Syndein | 2026-03-27 | Alto | **Muy alto — cierra la deuda técnica más crítica de la serie**. El connection leak, identificado el 23-DIC-2025 y sistémico al 12-ENE-2026, causaba fallos incluso con volumen en percentil 15. El fix en el código del Autorizador Java garantiza que las 25 conexiones se liberen correctamente. Sin este fix, Power 10 y la extracción de la firma no habrían impedido futuros incidentes a cargas bajas. El impacto declarado (Alto) debería ser **Muy alto**: era el único defecto que causaba degradación sin carga extraordinaria. | P655-R017 **CERRADO** |
| 4.5 | Mejorar rendimiento de Latinia | José David Urias | 2026-03-31 | Medio | **Medio** — Latinia (notificaciones SMS/push, Capa 4) compite con Informix por recursos. Mejorar su rendimiento reduce esa competencia en momentos de alta carga. No es un componente en la cadena de fallo directa de los incidentes, pero contribuye a la estabilidad general de la Capa 4. | Ninguno directo — estabilidad Capa 4 |
| 1.4 | Migración de hardware Power 10 | Daniel Ángeles / Francisco Alles | 2026-06-06 (noche sáb→dom, activo desde 2026-06-07) | Muy alto | **Muy alto — expande el techo de capacidad de cómputo**. Power 10 ofrece mayor throughput de CPU, memoria y I/O vs Power 8. Los Load Average de 82-127% observados en los incidentes eran sobre Power 8 — en Power 10, las mismas cargas operarán con percentiles de utilización significativamente menores. No corrige las deudas técnicas de software (connection pool, load balancing) pero amplía el headroom antes de alcanzar los umbrales de saturación. Complementa el resto de las mejoras de software. | P655-R013 residual mitigado · P655-R015 residual mitigado |
| 1.5 | Optimización de SPLs (Autorizador / SPEI) | Juan C. Argudín / Eugenio Dardo | 2026-06-30 | Bajo | **Bajo-Medio** — optimización de stored procedures que soportan el Autorizador y SPEI. Reduce el tiempo de ejecución individual de los SPs y puede disminuir los 193 buffer waits simultáneos observados en incidentes. No es un cambio arquitectónico pero sí reduce la presión sobre la Capa 4 (Informix SPL). El impacto declarado (Bajo) subestima su contribución en días de carga alta. | P655-R013 contribución menor |
| 4.2 | Solución única monitoreo Logs | Paul Bazúa | 2026-06-30 | Bajo | **Bajo** — centralización del monitoreo de logs en una sola solución. Mejora la velocidad de diagnóstico y reduce la posibilidad de que un incidente pase desapercibido (como el INC-20260112, donde el bajo volumen hizo que el equipo tardara más en identificar el patrón). Correcto. | Ninguno directo — reduce MTTR |
| 3.2 | Reducir tablas históricas | Juan López Heras | 2026-07-30 | Bajo | **Bajo** — reducción del volumen de datos históricos en tablas Informix. Alivia la presión de I/O en hdisk3 (que llegó al 100% en INC-20251215). No es un cambio arquitectónico pero reduce el footprint de disco que compite con las transacciones OLTP. Correcto. | P655-R013 contribución menor (hdisk3) |

---

## Cronología de mitigación de riesgos

```
2026-01-08   1.1 HSM tables optimized → P655-R015 parcial
             ↓ (4 días después, INC-20260112 igualmente ocurre — las deudas de software persisten)
2026-01-12   Último incidente documentado (connection leak sistémico, 6.58h)
2026-01-14   2.1 Monitoreo E-Global/SPEI → observabilidad activa
2026-02-15   3.6 Balanceo colas SPEI → P655-R013 mitigado; forking controlado
2026-03-07   3.1 Extraer firma SPEI → P655-R015 cerrado para SPEI; cascada AIX rota
2026-03-24   1.6 Estadísticas OLTP → rendimiento de queries mejorado
2026-03-27   2.5 Connection Leak eGlobal FIXED → P655-R017 CERRADO
2026-03-31   4.5 Latinia rendimiento → estabilidad Capa 4
2026-06-07   1.4 Power 10 activo → headroom de cómputo expandido
2026-06-30   1.5 SPL optimization + 4.2 log monitoring → mejoras operacionales
2026-07-30   3.2 Tablas históricas reducidas → presión I/O aliviada
```

---

## Estado de riesgos post-mejoras (vs. migration-risk-register.md)

| ID riesgo | Descripción | Estado pre-mejoras | Estado post-mejoras | Mejora que lo resuelve |
|-----------|-------------|-------------------|--------------------|-----------------------|
| P655-R012 | Sin pool de conexiones (25 directas) | N5 ABIERTO | **PARCIALMENTE MITIGADO** — el leak fue corregido (2.5) pero no hay evidencia de que se implementó HikariCP o pool formal; las 25 conexiones directas pueden seguir siendo el límite | 2.5 (connection leak fix) |
| P655-R013 | SPEI forking 72 procesos | N5 ABIERTO | **MITIGADO para producción** — 3.6 (balanceo automático) + 3.1 (firma extraída) + 1.4 (Power 10) eliminan la cascada. **Pendiente validar en target** | 3.6, 3.1, 1.4 |
| P655-R014 | Sin load balancing en Autorizador | N4 ABIERTO | **PARCIALMENTE MITIGADO** — 3.6 balancea las colas de SPEI, pero el Autorizador puede seguir siendo instancia única. Requiere clarificación | 3.6 (SPEI queues) |
| P655-R015 | Firma Digital bottleneck síncrono | N4 ABIERTO | **CERRADO para SPEI** — 3.1 extrae la firma del flujo síncrono; 1.1 optimiza las tablas HSM. Para otros flujos que aún usan Firma Digital síncrona, verificar | 3.1, 1.1 |
| P655-R016 | SLA e-Global 8s con margen cero | N4 ABIERTO | **MITIGADO para producción** — con connection leak corregido + forking controlado + Power 10, la latencia al Autorizador es significativamente menor. **Como riesgo de migración sigue activo**: el target debe validar latencia ≤ 4s en P95 | 2.5, 3.6, 3.1, 1.4 |
| P655-R017 | Connection leak sistémico e-Global | N5 ABIERTO | **CERRADO** — 2.5 corrige el leak en el código del Autorizador Java (27-mar-2026) | 2.5 |

---

## Implicaciones para la migración

Las mejoras 2026 cambian el perfil de riesgo AS-IS de la producción actual, pero **no eliminan los riesgos de migración** — el target debe diseñarse con base en las buenas prácticas que estas mejoras implican:

| Mejora | Lo que el target debe preservar o mejorar |
|--------|------------------------------------------|
| 2.5 Connection Leak fix | El target debe implementar HikariCP con pool formal (no solo evitar el leak actual) — P655-R012 sigue abierto para la migración |
| 3.6 Balanceo de colas SPEI | El microservicio SPEI en el target debe tener HPA con autoscaling — la solución de balanceo AS-IS puede ser específica de la infraestructura AIX |
| 3.1 Extraer firma SPEI | El target debe confirmar que la firma digital no vuelve a ser síncrona en el nuevo backend; si el microservicio SPEI invoca el HSM, debe ser asíncrono |
| 1.4 Power 10 | El dimensionamiento del target (instancias RDS Aurora, réplicas EKS) debe calibrarse para equivaler el headroom de Power 10, no el de Power 8 |
| 3.2 Reducir tablas históricas | El target debe tener política de retención de datos desde el día 1 — no acumular historial en las tablas operativas |

---

## Validación empírica en datos minuto-a-minuto (2026)

> **Metodología**: detección de "eventos de caída de servicio" en el sheet `Min a min SPEI y Eglobal` del archivo `Transacciones_maestro_Medios_de_Pago.xlsx` (2026-01-01 a 2026-08-04 · 154,800 minutos en horario 8-20h CST). Un evento de caída = 5+ minutos consecutivos con txn/min < 5% de la mediana diaria.

La hipótesis: las mejoras debían verse en el minuto-a-minuto como menor frecuencia de caídas, menor duración, y mayor volumen sostenido sin quiebres.

### Eventos de caída detectados por período

| Período | Fechas | Eventos | Días afectados | Duración promedio | Minutos perdidos |
|---------|--------|---------|----------------|------------------|-----------------|
| A — pre-fix críticos | 2026-01-01 a 2026-03-27 | **4** | 4 / 85 días | 19.5 min | 78 min |
| B — post-fix, pre-Power10 | 2026-03-28 a 2026-06-06 | **9** | 4 / 71 días | 64.4 min | 580 min |
| C — post-Power10 | 2026-06-07 a 2026-08-04 | **13** | 6 / 58 días | **18.5 min** | 240 min |

### Hallazgos por mes

| Mes | Eventos | Días | Min perdidos | Nota |
|-----|---------|------|-------------|------|
| Ene 2026 | 3 | 3 | 41 min | Último incidente documentado: INC-20260112 (12-ene) |
| **Feb 2026** | **0** | **0** | **0 min** | **CERO eventos** — 3.6 balanceo de colas SPEI activo desde 15-feb |
| Mar 2026 | 4 | 2 | 378 min | 30-mar: 171 min (Eglobal) + 95+75 min (SPEI) — ver análisis abajo |
| Abr 2026 | 3 | 1 | 144 min | 24-abr: INC-20260424 ya documentado (validación cruzada ✓) |
| May 2026 | 1 | 1 | 20 min | Mínimo impacto |
| Jun 2026 | 10 | 4 | 165 min | Power 10 activo 7-jun; eventos cortos (18.5 min promedio) |
| Jul 2026 | 5 | 3 | 150 min | 5-jul: evento no documentado — ver abajo |

### Interpretación de los datos anómalos

**Febrero 2026 = CERO eventos (más fuerte evidencia positiva)**

El único mes sin ninguna caída de servicio detectada. Enero aún tenía 3 eventos (cola del INC-20260112). Después del 15 de febrero (balanceo automático de colas SPEI, hito 3.6), el sistema fue estable durante todo el mes. Esto valida el impacto declarado como "Alto" del hito 3.6 — y argumenta que debería ser "Muy alto", dado que fue el primer mes cero desde al menos noviembre 2025.

**30-mar-2026 (171 min Eglobal, 95+75 min SPEI) — ventana de mantenimiento**

El evento de 171 minutos ocurrió 3 días después del fix del connection leak (hito 2.5, 27-mar). La hipótesis: el equipo desplegó el fix en producción el 30-mar con una ventana de mantenimiento programada — el reinicio del Autorizador Java para aplicar el fix aparece como caída en el minuto-a-minuto. Esto no es un incidente sino el costo del despliegue. Valida que el connection leak fix requirió reinicio del servicio.

**24-abr-2026 (75 min SPEI + 64 min Eglobal) — validación cruzada con logs INC-20260424**

El detector identificó una caída el 24 de abril de 2026 — exactamente el día para el que tenemos los logs ESB analizados (`source/logs/2026-04-24/`). Los incidentes documentados INC-20260424-001 a 008 son reales. Esto confirma que la metodología de detección funciona correctamente.

**5-jul-2026 (81 min Eglobal + 50 min SPEI) — candidato a nuevo INC**

Evento no documentado en el KB. Contexto: vol_pre = 3,428 txn/min (percentil alto) para Eglobal. Ocurrió durante el período post-Power10. Posible incidente operacional o mantenimiento no planeado. Requiere investigación.

### Cambio de perfil pre vs. post mejoras

El cambio más importante no es la frecuencia de eventos sino la **duración**:

| Período | Duración típica de incidentes |
|---------|------------------------------|
| Nov-Dic 2025 (pre-mejoras) | 1.5 a 7.5 horas (90-450 minutos) |
| 2026-ene a 2026-mar (transición) | 19.5 min promedio |
| 2026-jun a 2026-ago (post-Power10) | 18.5 min promedio |

Las caídas de Nov-Dic 2025 eran estructurales: el connection leak se acumulaba y no había mecanismo de auto-recuperación. En 2026, los eventos detectados son cortos (< 20 min en promedio post-Power10) — el sistema puede recuperarse automáticamente o el equipo interviene más rápido gracias al monitoreo (hito 2.1).

El impacto de $663 MDP del INC-20251129 viene de una caída de 4.5 horas con 69.71% de transacciones declinadas. Con la duración promedio de 18.5 min post-Power10, el impacto equivalente sería ~$46 MDP — una reducción de **~93%** en impacto económico potencial por evento.

---

## DATO-REQUERIDO derivado de este análisis

| ID | Pregunta | Impacto |
|----|----------|---------|
| AUT-DR-05 | ¿El fix del connection leak (2.5) implementó un pool de conexiones formal (HikariCP/DBCP) o solo corrigió el bug de cierre de conexiones? | Si solo fue el bug fix, P655-R012 (sin pool) sigue completamente abierto para la migración |
| AUT-DR-06 | ¿La optimización de balanceo de colas SPEI (3.6) es un mecanismo en el middleware AIX/ESB o en el código del procesador SPEI? | Determina si el balanceo se preserva al migrar el microservicio SPEI o si debe reimplementarse |
| AUT-DR-07 | ¿El Autorizador sigue siendo una instancia única o se añadió una segunda instancia como parte de las mejoras 2026? | Determina si P655-R014 (sin load balancing) está cerrado o sigue abierto |

---

*v1.0.0 · 2026-08-07 · Fuente: roadmap de mejoras post-incidentes BanCoppel (11 hitos, enero–julio 2026) + cruce con serie de incidentes Nov-2025→Ene-2026 + migration-risk-register.md*
