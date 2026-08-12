# D13 · Transferencias Electrónicas de Fondos (TEF) — Procesos Batch

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Domain Expert — BanCoppel (horarios y frecuencias operativas)
- SME — Core Banking Transformation (migración de jobs)
- SME — DBA IBM Informix (scheduler actual y configuración)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert de BanCoppel. Los horarios son estimados basados en el contexto regulatorio CNBV/CECOBAN.
---

## Descripción

Los procesos batch de `bditef` constituyen el ciclo operativo de la cámara de compensación CECOBAN. Son procesos críticos con ventanas horarias estrictas definidas por Banxico y CECOBAN. Su migración al target requiere un scheduler equivalente (AWS EventBridge o similar).

---

## Catálogo de procesos batch identificados

### BATCH-D13-001 · Ciclo de Presentación CECOBAN (Presentador)

| Atributo | Valor |
|----------|-------|
| **SP principal** | `sp_tef_presentador_g` |
| **Propósito** | Genera los archivos de cámara con las transferencias a presentar en CECOBAN |
| **Frecuencia** | `[SME-PENDING]` — estimado: 1 a 3 veces por día hábil |
| **Horario de corte** | `[SME-PENDING]` — regulatorio: antes del corte CECOBAN (estimado 17:00 hrs) |
| **SPs involucrados** | `sp_tef_presentador_g` → `sp_tef_generararchivo60` / `sp_tef_generararchivo62` / `sp_tef_generararchivo63` → `sp_tef_subirarchivos` |
| **Destino del archivo** | SFTP CECOBAN |
| **Dependencia previa** | Operaciones TEF del día capturadas en `tef_operaciones` |

---

### BATCH-D13-002 · Ciclo de Recepción CECOBAN (Presentador)

| Atributo | Valor |
|----------|-------|
| **SP principal** | `sp_tef_presentador_r` |
| **Propósito** | Procesa la respuesta de CECOBAN para las transferencias presentadas |
| **Frecuencia** | `[SME-PENDING]` — posterior al ciclo de presentación |
| **SPs involucrados** | `sp_tef_presentador_r` → `sp_tef_procesararchivo10` / `sp_tef_procesararchivo60` |
| **Dependencia previa** | BATCH-D13-001 completado y respuesta CECOBAN disponible |

---

### BATCH-D13-003 · Ciclo de Recepción CECOBAN (Receptor)

| Atributo | Valor |
|----------|-------|
| **SP principal** | `sp_tef_receptor_g` |
| **Propósito** | Recibe y procesa transferencias destinadas a cuentas BanCoppel enviadas por otros bancos |
| **Frecuencia** | `[SME-PENDING]` — según ciclo CECOBAN |
| **SPs involucrados** | `sp_tef_receptor_g` → `sp_tef_obt_arch_cam_recib41` / `sp_tef_obt_arch_cam_recibyprest40y41` → `sp_tef_procesararchivo61` / `sp_tef_procesararchivo62` / `sp_tef_procesararchivo63` |
| **Dependencia previa** | Archivos de cámara disponibles en SFTP CECOBAN |

---

### BATCH-D13-004 · Generación de Reporte Lista Negra

| Atributo | Valor |
|----------|-------|
| **SP principal** | `sp_tef_generareplistnegra` |
| **Propósito** | Genera el reporte de cuentas restringidas para transferencias TEF |
| **Frecuencia** | `[SME-PENDING]` — estimado: diario |
| **Destino** | `[SME-PENDING]` — directorio de reportes regulatorios |
| **Regulación** | CNBV — prevención de lavado de dinero |

---

### BATCH-D13-005 · Archivado a Histórico

| Atributo | Valor |
|----------|-------|
| **SP principal** | `sp_tef_moverregistroshist` |
| **Propósito** | Mueve registros de operaciones procesadas al histórico para liberar espacio operativo |
| **Frecuencia** | `[SME-PENDING]` — estimado: diario (nocturno) |
| **Horario** | `[SME-PENDING]` — fuera de ventana operativa CECOBAN |
| **Tablas afectadas** | `tef_operaciones` → tabla histórica `[DATO-REQUERIDO]` |
| **Regulación** | CNBV — retención de datos 5 años mínimo |

---

### BATCH-D13-006 · Actualización Reporte SICAM

| Atributo | Valor |
|----------|-------|
| **SP principal** | `sp_tef_act_rep_sicam` |
| **Propósito** | Actualiza el sistema de cámara SICAM con el estado de las operaciones TEF del día |
| **Frecuencia** | `[SME-PENDING]` — estimado: diario al cierre operativo |
| **Regulación** | CNBV — reporte regulatorio de cámara |

---

### BATCH-D13-007 · Reporte de Dominiciliación (30 y 60 días)

| Atributo | Valor |
|----------|-------|
| **SP principal** | `sp_tef_domi_genrep30y60` |
| **Propósito** | Genera reporte de domiciliaciones vencidas a 30 y 60 días |
| **Frecuencia** | `[SME-PENDING]` — estimado: mensual o semanal |
| **Destino** | `[SME-PENDING]` — reporte para seguimiento de domiciliaciones |

---

### BATCH-D13-008 · Reporte Libro SIF

| Atributo | Valor |
|----------|-------|
| **SP principal** | `sp_tef_rep_lib_sif` |
| **Propósito** | Genera el libro de operaciones para el Sistema de Información Financiera (SIF) |
| **Frecuencia** | `[SME-PENDING]` — estimado: mensual |
| **Regulación** | CNBV — reportes regulatorios periódicos |

---

## Ventana operativa TEF — referencia regulatoria

| Período | Ventana estimada | Fuente |
|---------|-----------------|--------|
| Operaciones TEF (envío/recepción) | 06:00 – 18:30 hrs días hábiles | `[SME-PENDING]` — Banxico/CECOBAN |
| Corte CECOBAN para presentación | `[SME-PENDING]` | CECOBAN |
| Ventana de archivado nocturno | 21:00 – 05:00 hrs | `[SME-PENDING]` |
| Días hábiles bancarios | Lunes a viernes (excl. feriados en `si_feriado`) | CNBV |

---

## Dependencias críticas de orquestación

```
[DIURNO — día hábil]
  06:00 → BATCH-D13-001 (Presentación) → CECOBAN recibe
  [durante el día] → Operaciones en línea capturadas
  17:00 → BATCH-D13-002 (Respuesta de presentación)
  [durante el día] → BATCH-D13-003 (Recepción de otros bancos)

[NOCTURNO]
  20:00 → BATCH-D13-005 (Archivado histórico)
  21:00 → BATCH-D13-006 (Actualización SICAM)

[PERIÓDICO]
  [SME-PENDING] → BATCH-D13-004 (Lista negra)
  [SME-PENDING] → BATCH-D13-007 (Dominiciliación)
  [SME-PENDING] → BATCH-D13-008 (Libro SIF)
```

---

## Target — diseño de orquestación en AWS

| Componente batch | Equivalente AWS recomendado |
|-----------------|---------------------------|
| Scheduler de jobs (actual) | Amazon EventBridge Scheduler |
| Subida de archivos SFTP a CECOBAN | AWS Transfer Family (SFTP) |
| Procesamiento de archivos de cámara | AWS Batch o ECS Tasks |
| Monitoreo de ventana operativa | CloudWatch Alarms + SNS |
| Archivado histórico | Lambda + S3 + RDS Aurora |

---

## `[SME-PENDING]`

- [ ] Horario exacto de cada batch con el Domain Expert BanCoppel.
- [ ] Confirmar herramienta de scheduling actual (cron, Control-M, otro).
- [ ] Confirmar si `sp_tef_subirarchivos` usa SFTP directo o va por el ESB.
- [ ] Definir ventana de mantenimiento para BATCH-D13-005 (archivado) sin impacto operativo.
- [ ] Confirmar frecuencia real de BATCH-D13-007 y BATCH-D13-008 con el área de regulación.

---
*Generado por análisis de SPs batch en callgraph bditef · Etapa 3*
