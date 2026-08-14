# D13 · Transferencias Electrónicas de Fondos (TEF) — Catálogo de Datos

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — DBA IBM Informix (esquema físico y tipos de datos)
- Data Architect (modelado target PostgreSQL / Aurora)
- SME Regulatorio — CNBV (campos con requisitos regulatorios)

> Secciones marcadas `[DATO-REQUERIDO]` requieren acceso al esquema de producción o validación con DBA IBM Informix.
---

## Entidades del dominio (tablas identificadas en el código)

### Tablas propias de `bditef`

| Tabla | Tipo | Descripción inferida | Operaciones observadas |
|-------|------|---------------------|----------------------|
| `cce_param` | Configuración | Parámetros de configuración CCE/TEF | SELECT |
| `cce_cheques_dev` | Transaccional | Cheques devueltos en cámara | SELECT, INSERT |
| `cce_propios_det` | Transaccional | Detalle de cheques propios presentados | SELECT, INSERT |
| `tef_operaciones` | Transaccional maestra | Operaciones TEF registradas | SELECT, INSERT, UPDATE |
| `tef_bitacora` | Auditoría | Bitácora de auditoría de operaciones | INSERT |
| `tef_archivos` | Control | Control de archivos de cámara CECOBAN | SELECT, INSERT, UPDATE |
| `tef_detalle` | Transaccional | Detalle de registros dentro de un archivo | SELECT, INSERT |
| `cce_encabezado` | Archivo cámara | Encabezado de archivo CECOBAN | INSERT |
| `cce_sumario` | Archivo cámara | Sumario de lote CECOBAN | INSERT |
| `cce_gran_sumario` | Archivo cámara | Gran sumario del archivo CECOBAN | INSERT |
| `cce_detalle` | Archivo cámara | Registros de detalle del archivo CECOBAN | SELECT, INSERT |
| `cce_usuarios_aut` | Seguridad | Usuarios autorizados para operaciones CCE | SELECT, INSERT, UPDATE |
| `cce_cedula_usr` | Seguridad | Cédula/perfil de usuario CCE | SELECT, INSERT, UPDATE |
| `cce_archivos` | Control | Control de archivos guardados en CCE | INSERT |

> Nombres y estructura exacta de columnas: `[DATO-REQUERIDO]` — requiere consulta al DBA IBM Informix o inspección del DDL en producción.

---

### Tablas cross-DB referenciadas por `bditef`

| Tabla | Base de datos | Descripción | Operación |
|-------|--------------|-------------|-----------|
| `sc_maechq` | `bdicheq` | Maestro de cuentas de cheques | SELECT |
| `sc_fechas` | `bdicheq` | Fecha de proceso vigente | SELECT |
| `sc_movdia` | `bdicheq` | Movimientos del día | SELECT, INSERT |
| `sc_movhis` | `bdicheq` | Histórico de movimientos | SELECT |
| `sc_comisiones` | `bdicheq` | Tabla de comisiones | SELECT |
| `sc_producto` | `bdicheq` | Catálogo de productos | SELECT |
| `sc_maecomtasserv_pm` | `bdicheq` | Comisiones y tasas de servicio | SELECT |
| `sc_ctabloqueo` | `bdicheq` | Cuentas con bloqueo activo | SELECT |
| `sc_bloqueo` | `bdicheq` | Causas de bloqueo de cuentas | SELECT |
| `sc_contch` | `bdicheq` | Control de cheques por cuenta | SELECT |
| `sc_detcomis` | `bdicheq` | Detalle de comisiones aplicadas | INSERT |
| `sc_docret_sbc` | `bdicheq` | Documentos de retorno SBC | SELECT |
| `sq_param` | `bdicntchq` | Parámetros del sistema de cheques | SELECT |
| `si_feriado` | `bdinteg` | Catálogo de días feriados | SELECT |
| `si_param` | `bdinteg` | Parámetros de integración | SELECT |
| `si_coddevcam` | `bdinteg` | Códigos de devolución en cámara | SELECT |

---

## Clasificación de sensibilidad de datos

| Clasificación | Tablas | Obligación regulatoria |
|---------------|--------|----------------------|
| **PII Financiero — Alto** | `tef_operaciones`, `tef_detalle`, `cce_detalle` | LFPDPPP · CNBV Circular 3/2012 |
| **PII Financiero — Medio** | `cce_cheques_dev`, `cce_propios_det`, `tef_bitacora` | LFPDPPP |
| **Configuración sensible** | `cce_param`, `cce_usuarios_aut`, `cce_cedula_usr` | ISO 27001 |
| **Operacional** | `tef_archivos`, `cce_archivos`, `cce_encabezado`, `cce_sumario` | Archivo regulatorio CNBV 5 años |

Ver `18-pii-security-assessment.md` para análisis detallado de PII.

---

## Volumen estimado

| Tabla | Volumen estimado | `[DATO-REQUERIDO]` |
|-------|-----------------|---------------------|
| `tef_operaciones` | [DATO-REQUERIDO] transacciones/día | Logs de producción |
| `tef_bitacora` | [DATO-REQUERIDO] registros/día | Logs de producción |
| `cce_detalle` | [DATO-REQUERIDO] registros/ciclo de cámara | DBA |
| `cce_cheques_dev` | [DATO-REQUERIDO] devueltos/día | DBA |

---

## `[SME-PENDING]`

- [ ] DDL completo de todas las tablas propias de `bditef`.
- [ ] Retención de datos activos vs. histórico (política de archivado).
- [ ] Tamaño actual de tablas transaccionales en producción (para plan de migración).
- [ ] Confirmar si existen vistas (`VIEW`) o sinónimos (`SYNONYM`) relevantes en el esquema.

---
*Generado por análisis de sp-specs-bditef.md · tablas accedidas en el código*
