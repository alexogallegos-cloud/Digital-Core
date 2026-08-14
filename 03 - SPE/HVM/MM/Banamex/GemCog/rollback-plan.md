# Plan de Rollback — Banamex S500+S151 Modernización
> Artefacto P0 MANIFEST · Criterios y procedimientos de reversión por wave
> Versión: v0.2-QC · 2026-07-21 · GemCog Capa 5 — Fronteras y Wave Map · QC 2026-07-21: trigger Wave 0-A corregido (BC-04 ACL) · ventanas unificadas (15/60min/4h) · punto no retorno Wave 3
> Owner: Specialist - 7R Assessment · Advisory: Mainframe Migration SME + Regulatory SME

---

## 1. Principios del Rollback

El rollback es la reversión controlada de un wave de migración al sistema de origen Unisys ClearPath MCP/DMSII, con el fin de restaurar la continuidad operativa ante una falla que supera los umbrales tolerables definidos en este documento. Su activación es un acto de gobierno, no de operación, y requiere autorización explícita del Decisor designado.

**Criterios de activación.** El rollback se activa únicamente ante evidencia objetiva y cuantificable: divergencia contable no resuelta, fallo de reporte regulatorio, pérdida de integridad en BD11, o indisponibilidad de interfaces críticas. No se activa por degradación de performance aislada, errores transitorios resueltos dentro del umbral, ni por incertidumbre subjetiva del equipo.

**Autoridad.** El Decisor principal es el Director de Tecnología de Banamex (o su delegado formal). En ausencia de éste, el Arquitecto Líder de Migración puede activar el rollback de emergencia notificando de forma inmediata y por escrito al Decisor principal.

**Ventanas de tiempo del protocolo de rollback.**

| Ventana | Duración | Descripción |
|---------|----------|-------------|
| Detección | ≤ 15 min | Tiempo desde anomalía hasta primer alert |
| Decisión | 30 min (Wave 0-A/0-B) · 60 min (Waves 1-3) | Tiempo máximo para decidir rollback o continuar; vencida la ventana sin decisión, el rollback se activa automáticamente |
| Causa raíz | ≤ 4 horas | Solo para divergencias que NO disparan rollback inmediato — equipo analiza y documenta sin presión de activación automática |

Esta tabla define las tres ventanas del protocolo. La ventana de causa raíz (≤ 4 horas) aplica exclusivamente a divergencias que no alcanzan el umbral de rollback automático; no es la ventana de decisión de rollback. Esta distinción garantiza el cumplimiento del RTO regulatorio establecido por CNBV Circular 29/2010.

---

## 2. Criterios de Activación por Wave

| Wave | Trigger de rollback | Umbral cuantitativo | Tiempo de detección | Decisor |
|------|--------------------|--------------------|---------------------|---------|
| 0-A (BC-04 ACL · S151REGISTRA · L002R2-R5 · GL-Posting-Service) | Divergencia en contadores de asientos aceptados por S151REGISTRA/GL-Posting-Service entre entornos target y legacy, sostenida > 30 min; O tasa de equivalencia BC-04 ACL < 99.99% en el comparator de parallel-run | Tasa de equivalencia BC-04 ACL < 99.99% sostenida > 30 min | ≤ 30 min | Arquitecto Líder |
| 0-B (L030 Platform Services) | Indisponibilidad de capa de plataforma o pérdida de conectividad con BD99 CONTROL | Batch sin confirmación de estado por más de 20 min | ≤ 10 min | Arquitecto Líder |
| 1 (BC-02, BC-03, BC-09) | Divergencia en BD11 B72POSCONTA (SDOANT/CARGOS/ABONOS/SDOACT) no resuelta; fallo de interfaces Citi BRCH-NBR=485/BRANCH=484 | Divergencia > $0 MXN no resuelta en 45 min; interface Citi sin respuesta por más de 15 min | ≤ 20 min | Director de Tecnología |
| 2 (BC-01, BC-06 parcial, BC-08) | Fallo de reporte regulatorio CNBV Serie B; equivalencia GL < 99.99% | Reporte Serie B no generado o rechazado en ventana regulatoria; equivalencia GL sostenida < 99.99% por más de 1 hora | ≤ 30 min | Director de Tecnología |
| 3 (BC-05 General Ledger) | Cualquier divergencia en BD11; fallo de cierre contable CNBV; pérdida de SETID=BNMEX en P131 | Divergencia > $0 MXN en BD11; cierre contable no completado dentro de ventana regulatoria | ≤ 15 min | Director de Tecnología + CFO de Banamex |

---

## 3. Procedimiento de Rollback por Wave

El procedimiento aplica a todos los waves con adaptaciones específicas indicadas.

**Paso 1 — Aislamiento del tráfico.** Redirigir el tráfico entrante al sistema legacy MCP mediante el switch de enrutamiento del middleware de integración. Confirmación requerida: cero transacciones nuevas ingresando al sistema moderno. Tiempo objetivo: ≤ 5 minutos.

**Paso 2 — Reconexión al sistema legacy MCP.** Restablecer las conexiones DMSII, reactivar los JCL/WFL correspondientes al wave en rollback, y confirmar que los procesos batch del legacy están en estado operativo. Para Wave 1 y posteriores, reactivar explícitamente las interfaces Citi (BRCH-NBR=485 y BRANCH=484) si fueron desconectadas durante el wave. Para Wave 3, verificar que SETID=BNMEX en P131 (14 ocurrencias) esté revertido a su valor original. Tiempo objetivo: ≤ 15 minutos.

**Paso 3 — Reconciliación de datos divergentes.** Comparar BD10 MOVDIA151 (Transaction Register) entre el sistema moderno y el legacy para identificar transacciones procesadas en el sistema nuevo durante el período de co-existencia. Toda transacción sin contrapartida confirmada en el legacy debe ser replicada manualmente o marcada para reconciliación manual supervisada. Ninguna transacción puede quedar sin estado resuelto.

**Paso 4 — Validación de integridad contable (BD11).** Ejecutar el script de validación sobre BD11 B72POSCONTA verificando que SDOANT + CARGOS − ABONOS = SDOACT para cada cuenta. BD11 es inmutable durante el rollback: si el saldo calculado no coincide, se escala inmediatamente al equipo de Contabilidad de Banamex antes de reanudar operaciones. No se declara el rollback como exitoso hasta que BD11 pase validación completa.

**Paso 5 — Notificación interna y regulatoria.** Notificar al comité interno de crisis dentro de los 30 minutos posteriores a la activación del rollback. Si el rollback afecta la generación de reportes regulatorios CNBV Serie B o implica downtime superior a 4 horas en sistemas core, se activa el proceso de notificación a CNBV descrito en la Sección 6.

---

## 4. Datos Críticos a Preservar Durante el Rollback

| Dataset | Contenido | Acción durante rollback |
|---------|-----------|------------------------|
| BD11 SDOS151 (GL Balance) | Saldos contables: SDOANT, CARGOS, ABONOS, SDOACT | Inmutable. Solo lectura. Punto de validación obligatorio post-rollback. |
| BD10 MOVDIA151 (Transaction Register) | Registro de movimientos del día | Punto de reconciliación. Comparación sistema moderno vs. legacy línea por línea. |
| BD99 CONTROL | Estado del batch y flags de control de proceso | Verificar flags antes de reactivar batch legacy para evitar doble procesamiento. |
| Archivos CFR del parallel-run | Comprobantes de transferencia generados durante co-existencia | Preservar en almacenamiento inmutable. Insumo para auditoría post-rollback. |

---

## 5. RTO/RPO por Wave

| Wave | RTO target | RPO target | Cumple Circular 29/2010 | Cómo se mide |
|------|-----------|-----------|------------------------|--------------|
| 0-A (BC-04 ACL) | ≤ 2 horas | ≤ 30 minutos | Sí | Tiempo entre activación del trigger y confirmación de operación legacy |
| 0-B (L030 Platform) | ≤ 2 horas | ≤ 30 minutos | Sí | Confirmación de batch legacy activo y BD99 CONTROL en estado válido |
| 1 (BC-02, BC-03, BC-09) | ≤ 3 horas | ≤ 1 hora | Sí | Validación BD11 completa y interfaces Citi activas |
| 2 (BC-01, BC-06, BC-08) | ≤ 4 horas | ≤ 1 hora | Sí (límite) | Generación exitosa de reporte Serie B dentro de ventana regulatoria |
| 3 (BC-05 GL) | ≤ 2 horas | ≤ 15 minutos | Sí — RTO reforzado | Validación BD11 + cierre contable completado; cualquier desvío se reporta a CNBV |

El Wave 3 (BC-05 General Ledger) opera con RTO reforzado porque cualquier downtime superior a 2 horas en GL impacta directamente el cierre contable y los reportes regulatorios de fin de día de la CNBV.

**Punto de no retorno Wave 3**: Si a las 16:00 hrs la validación de equivalencia no ha completado con resultado verde, el procedimiento por defecto es iniciar rollback inmediatamente. Esta hora es el límite calculado como: 19:00 (deadline rollback) − 2h RTO − 60 min ventana de decisión = 16:00 máximo para detección y decisión.

---

## 6. Notificación a CNBV

**Umbral de notificación.** Se notifica a la CNBV cuando: (a) el downtime de sistemas core supera 4 horas, conforme a Circular 29/2010; (b) el reporte regulatorio Serie B no puede generarse en la ventana establecida; o (c) existe una divergencia contable en BD11 que no puede resolverse antes del cierre contable del día.

**Formato de notificación.** La notificación sigue el esquema de reporte de incidentes establecido en la Circular 29/2010 Anexo II: descripción del evento, sistemas afectados, impacto en clientes, hora de inicio, hora de restablecimiento estimado o confirmado, y acciones correctivas tomadas. El documento se envía firmado electrónicamente por el Director de Tecnología de Banamex.

**Responsable interno.** El Oficial de Riesgo Tecnológico de Banamex es el punto de contacto con CNBV. El Arquitecto Líder de Migración provee la evidencia técnica de soporte al Oficial de Riesgo dentro de los 30 minutos de activado el proceso de notificación.

---

## 7. Lecciones Aprendidas Post-Rollback

Dentro de las 48 horas posteriores a la conclusión de un rollback, el equipo de migración conduce un análisis de causa raíz estructurado. El análisis cubre: la cadena de eventos que llevó al trigger, la efectividad del procedimiento de rollback ejecutado, los datos que requirieron reconciliación manual y su volumen, y las brechas detectadas en los criterios de activación o en los procedimientos documentados en este plan.

**Gate de re-entrada.** Ningún wave puede reiniciarse después de un rollback sin cumplir los siguientes requisitos: (1) causa raíz documentada y aprobada por el Arquitecto Líder; (2) medidas correctivas implementadas y validadas en ambiente de pre-producción; (3) aprobación formal del Director de Tecnología; (4) notificación a CNBV cerrada o en estado confirmado por la autoridad regulatoria.

**Documentación requerida antes de reintentar.** El equipo debe actualizar este documento con las lecciones aprendidas del rollback, ajustar los umbrales cuantitativos si los datos de incidente así lo indican, y generar un registro de incidente formal en el artefacto `incident-log-s500-s151.md` antes de solicitar la autorización de re-entrada.

---

*Próxima revisión: antes del inicio de Wave 0-A · Requiere validación de Mainframe Migration SME + Regulatory SME · Documento vivo sujeto a actualización post cada rollback.*
