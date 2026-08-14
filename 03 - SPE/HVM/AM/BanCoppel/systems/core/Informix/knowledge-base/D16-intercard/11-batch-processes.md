# D16 · Intercard (Tarjetas) — Procesos Batch

> **Componente:** Informix · SPE-AM-001
> **Base de datos:** `intercard`
> **Última actualización:** 2026-08-03

---

## Inventario de batch identificados

| ID | SP | LOC | Rules | Patrón | Criticidad |
|----|-----|----:|------:|--------|------------|
| BATCH-D16-01 | `sp_carga_ctes_enrola` | 1,778 | 16 | Carga masiva desde archivo/tabla | Alta |
| BATCH-D16-02 | `sp_contacto_vencimiento_credito` | 1,011 | 49 | Procesamiento por cursor, notificación | Alta |
| BATCH-D16-03 | `sp_contacto_vencimiento_debito` | 998 | 46 | Procesamiento por cursor, notificación | Alta |
| BATCH-D16-04 | `sp_rst_notificacion_clientes` | — | 0 | Notificación RST masiva | Media |
| BATCH-D16-05 | `sp_inter_cuadrar_inventario_tarjetas` | — | 3 | Cuadre de inventario de plásticos | Media |
| BATCH-D16-06 | `sp_camp_registrar_notificaciones_pru1` | — | 5 | Registro de notificaciones de campaña | Baja |
| BATCH-D16-07 | `sp_descarga_info_horasazules` | — | 4 | Descarga de info para Horas Azules | Media |

---

## BATCH-D16-01 · Enrolamiento de clientes (`sp_carga_ctes_enrola`)

**Descripción:** Carga masiva de clientes nuevos o actualizaciones de perfil en el catálogo `intercard`. Es el proceso de alta de tarjeta — sin este batch el cliente no existe en el dominio de tarjetas.

**Patrón de ejecución:**
- Probablemente nocturno (ventana de bajo tráfico)
- Lee de tabla temporal o archivo de staging
- Aplica 16 reglas de validación y elegibilidad
- INSERT/UPDATE en tablas de `intercard`
- 1,778 LOC — proceso complejo con múltiples sub-flujos

**Riesgo de migración:**
- El batch más largo de D16 — golden master requiere dataset representativo con casos límite de las 16 reglas
- Probable uso de `UNLOAD`/`LOAD` de Informix — sin equivalente directo en PostgreSQL
- `[SME-PENDING]` ventana de ejecución, dependencia de job anterior, tolerancia a fallas parciales

---

## BATCH-D16-02/03 · Contacto por vencimiento (crédito + débito)

**Descripción:** Procesos de cobranza preventiva — contactan clientes próximos a vencer para evitar impago. Son los SPs con mayor densidad de reglas de negocio en el dominio (49 + 46).

**Patrón de ejecución:**
```
FOREACH SELECT cliente, tarjeta FROM tabla_vencimientos
    WHERE fecha_vencimiento BETWEEN hoy+N1 AND hoy+N2
DO
    evalua 49/46 reglas de elegibilidad
    IF elegible THEN
        CALL sp_notificacion(canal, mensaje)
        UPDATE registro_contacto
    END IF
END FOREACH
```

**Riesgo de migración:**
- 95 reglas combinadas — el mayor volumen de lógica de negocio documentada en D16
- Lógica de ventana horaria embebida (CONDUSEF) — debe externalizarse en target como configuración
- Coordinación de escritura con tablas compartidas entre crédito y débito
- `[SME-PENDING]` mapeo de las reglas contra restricciones CONDUSEF Circular 11/2011

---

## BATCH-D16-05 · Cuadre de inventario de tarjetas (`sp_inter_cuadrar_inventario_tarjetas`)

**Descripción:** Proceso de reconciliación del inventario de plásticos físicos (tarjetas emitidas vs. en stock en bóvedas). Crítico para control de riesgo operacional CNBV.

**`[SME-PENDING]`** frecuencia, fuente de inventario físico y destino del reporte.

---

## Consideraciones para migración de batch a AWS

| Aspecto | Situación actual (Informix/AIX) | Target recomendado (AWS) |
|---------|--------------------------------|--------------------------|
| Scheduler | IBM Tivoli Workload Scheduler / cron AIX | AWS EventBridge Scheduler |
| Ejecución | SPL dentro de Informix | AWS Lambda / ECS (Fargate) |
| Archivos de entrada | Filesystem AIX / tablas staging | S3 + DMS o Glue |
| Notificaciones | Canal ICCAT / SMS directo | Amazon SNS + SES |
| Logging | `[SME-PENDING]` — posiblemente archivos .log AIX | CloudWatch Logs |
| Alertas de falla | `[SME-PENDING]` | CloudWatch Alarms → SNS → PagerDuty |

---
*Generado: 2026-08-03 · fuente: brain.db intercard + inferencia de patrones SPL*
