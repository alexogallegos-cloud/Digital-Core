# D13 · Transferencias Electrónicas de Fondos (TEF) — Dependencias del Dominio

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — Core Banking Transformation (dependencias funcionales)
- SME — DBA IBM Informix (dependencias de datos y esquema)
- Architect Target (diseño de desacoplamiento)

---

## Dependencias internas (cross-DB dentro del ecosistema BanCoppel)

### `bdicheq` — Cheques y Cuentas (DEPENDENCIA CRÍTICA)

`bditef` tiene la dependencia cross-DB más fuerte del sistema hacia `bdicheq`. Los SPs de cargo y abono acceden directamente a tablas de cheques para ejecutar los movimientos en cuenta.

| Tabla en `bdicheq` | Accedida por (SPs en `bditef`) | Operación | Criticidad |
|-------------------|-------------------------------|-----------|------------|
| `sc_fechas` | `abono_cta`, `cargo_cta` | SELECT | ALTA — fecha de proceso |
| `sc_maechq` | `abono_cta`, `cargo_cta` | SELECT | CRÍTICA — validación de cuenta |
| `sc_movdia` | `cargo_cta`, `cons_dev_coppel` | SELECT, INSERT | CRÍTICA — movimientos del día |
| `sc_movhis` | `cons_dev_coppel` | SELECT | MEDIA — histórico |
| `sc_comisiones` | `cargo_cta` | SELECT | ALTA — comisiones |
| `sc_producto` | `cargo_cta` | SELECT | MEDIA — tipo de producto |
| `sc_maecomtasserv_pm` | `cargo_cta` | SELECT | ALTA — tasas de servicio |
| `sc_ctabloqueo` | `cargo_cta` | SELECT | CRÍTICA — estado de bloqueo |
| `sc_bloqueo` | `cargo_cta` | SELECT | ALTA — causas de bloqueo |
| `sc_contch` | `cargo_cta` | SELECT | MEDIA — control de cheques |
| `sc_detcomis` | `cargo_cta` | INSERT | ALTA — registro de comisiones |
| `sc_docret_sbc` | `cal_fechapre` | SELECT | MEDIA — documentos de retorno |

**SPs en `bdicheq` llamados desde `bditef`:**

| SP en `bdicheq` | Llamado por | Propósito |
|----------------|-------------|-----------|
| `abono_ref` | `abono_cta` | Ejecuta el abono de referencia en cuenta |
| `cargo_ref` | `cargo_cta` | Ejecuta el cargo de referencia en cuenta |
| `sp_cons_sdodisp_x_tpcalculo` | `cargo_cta` | Consulta saldo disponible según tipo de cálculo |

**Implicación para migración:** `bditef` y `bdicheq` deben migrar en el mismo wave o debe implementarse un adapter API entre ambos dominios. El riesgo de período de convivencia es RSK-D13-002.

---

### `bdinteg` — Integración (DEPENDENCIA MEDIA)

| Tabla en `bdinteg` | Accedida por | Operación | Uso |
|-------------------|-------------|-----------|-----|
| `si_feriado` | `cal_fecha_pre_fh`, `cal_fecha_pre_fh_web`, `cal_fechapre`, `cal_fecharet`, `cal_habil_ant` | SELECT | Catálogo de días feriados para cálculo de fechas hábiles |
| `si_param` | `cargo_cta` | SELECT | Parámetros de integración |
| `si_coddevcam` | `cargo_cta` | SELECT | Códigos de devolución en cámara |

---

### `bdicntchq` — Control de Cheques (DEPENDENCIA BAJA)

| Tabla en `bdicntchq` | Accedida por | Operación | Uso |
|---------------------|-------------|-----------|-----|
| `sq_param` | `cargo_cta` | SELECT | Parámetros del sistema de cheques |

---

## Dependencias externas

Ver `13-external-dependencies.md` para el detalle completo. Resumen:

| Sistema externo | Protocolo | Criticidad | Riesgo activo |
|----------------|-----------|------------|---------------|
| CECOBAN (Cámara de Compensación) | SFTP + formatos 10/60/61/62/63 | CRÍTICA | Cambio de protocolo en migración |
| ESB BanCoppel (IBM IIB/ACE) | SOAP/JNI/MQ | CRÍTICA | INC-005 — 5 códigos sin runbook |
| Sistema TEF externo | SOAP/Axis2 | CRÍTICA | ESB code 3743 (timeout) |
| `bdispei` (D08) | Cross-DB funcional | ALTA | Hermano regulatorio — migrar coordinado |

---

## Dependencias de datos maestros

| Dato maestro | Fuente | Impacto si no migra |
|-------------|--------|---------------------|
| Calendario de días feriados | `bdinteg:si_feriado` | Transferencias habilitadas en días no hábiles — rechazo CECOBAN |
| Catálogo de bancos CECOBAN | `[DATO-REQUERIDO]` tabla en bditef | Destinos de transferencia inválidos |
| Parámetros TEF/CCE | `bditef:cce_param` | Sistema sin configuración operativa |
| Usuarios autorizados CCE | `bditef:cce_usuarios_aut` | Operadores sin acceso post-migración |

---

## Grafo de dependencias simplificado

```
                    [Sistema Externo TEF]
                           |
                        [ESB / IIB]
                           |
              ┌────────────┼────────────┐
              |                         |
         [bditef]  ──cross-DB──  [bdicheq]
              |                         |
              └────────────────── [bdinteg]
                                     |
                                [si_feriado]
```

---
*Generado por análisis de tablas accedidas y llamadas cross-DB en sp-specs-bditef.md*
