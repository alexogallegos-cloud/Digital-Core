# D13 · Transferencias Electrónicas de Fondos (TEF) — Journey Map

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis de callgraph)
- Domain Expert — BanCoppel (validación de flujos)
- SME — Core Banking Transformation

> Secciones marcadas `[SME-PENDING]` requieren validación antes de BUILD.
---

## Journey J-D13-01 · Registro de transferencia TEF (envío)

**Descripción:** Un cliente o sistema interno inicia una transferencia electrónica de fondos hacia otra cuenta. El flujo valida horario hábil, datos de la operación, ejecuta el cargo en cuenta origen y registra la operación en la bitácora TEF para su posterior envío a CECOBAN.

```
Canal (app/web/caja)
  └─► sp_tef_validahorario         [valida ventana operativa CNBV]
        └─► sp_tef_valida_datos     [valida cuenta, monto, moneda, banco]
              └─► cargo_cta         [cargo en cuenta origen — cross-DB bdicheq]
                    └─► cargo_ref   [cross-DB bdicheq]
              └─► sp_tef_grabaoperacion  [registra en tef_operaciones]
                    └─► sp_tef_bitacora  [log auditoría]
```

**Tablas TEF clave involucradas:**
- `tef_operaciones` — registro maestro de operaciones
- `tef_bitacora` — log de auditoría de cada operación
- `cce_param` — parámetros de configuración TEF/CECOBAN

**Cross-DB involucrados:**
- `bdicheq:sc_maechq` — validación de cuenta origen
- `bdicheq:sc_fechas` — fecha de proceso vigente
- `bdinteg:si_feriado` — validación días hábiles

---

## Journey J-D13-02 · Recepción de transferencia TEF (inbound)

**Descripción:** CECOBAN envía un archivo de cámara con transferencias destinadas a cuentas BanCoppel. El proceso valida el archivo, lo procesa registro por registro y acredita las cuentas destino.

```
Job batch (scheduler)
  └─► sp_tef_buscararchivo         [localiza archivo en directorio CECOBAN]
        └─► sp_tef_validarnombrearchivos  [valida convención de nombre]
              └─► sp_tef_validarecepcion  [valida estructura del archivo]
                    └─► sp_tef_procesararchivo60 / 61 / 62 / 63
                          └─► abono_cta   [abono en cuenta destino — cross-DB bdicheq]
                                └─► abono_ref  [cross-DB bdicheq]
                          └─► sp_tef_grabaoperacion  [registra operación acreditada]
```

---

## Journey J-D13-03 · Reverso de transferencia TEF

**Descripción:** Cuando CECOBAN rechaza o devuelve una transferencia, o el cliente solicita un reverso autorizado, se revierte la operación. El proceso carga la operación original, valida que sea reversable y ejecuta el contra-movimiento.

```
Sistema TEF externo / operador
  └─► sp_tef_buscaoperacion        [recupera operación original por folio]
        └─► sp_tef_reversoperacion [valida estado, ejecuta reverso]
              └─► abono_cta        [reverso del cargo — cross-DB bdicheq]
              └─► sp_tef_bitacora  [log auditoría de reverso]
```

**Restricciones conocidas:** `[SME-PENDING]` — validar si aplica restricción de mismo día similar a `sp_reverso_msw` de `bdisac`.

---

## Journey J-D13-04 · Ciclo de cámara de compensación CECOBAN

**Descripción:** BanCoppel participa en el ciclo de cámara de compensación electrónica bancaria (CECOBAN) como presentador y receptor. Los archivos de cámara siguen el protocolo CECOBAN con formatos numéricos estandarizados.

```
[PRESENTADOR - Envío]
  sp_tef_presentador_g             [genera lote para presentación]
    └─► sp_tef_generararchivo60    [formato 60 — presentación crédito]
    └─► sp_tef_generararchivo62    [formato 62 — devolución]
    └─► sp_tef_generararchivo63    [formato 63 — presentación débito]
    └─► sp_tef_subirarchivos        [SFTP a CECOBAN]

[RECEPTOR - Recepción]
  sp_tef_receptor_g                [recibe y procesa lote entrante]
    └─► sp_tef_obt_arch_cam_recib41
    └─► sp_tef_obt_arch_cam_recibyprest40y41
    └─► sp_tef_procesararchivo10   [formato 10 — respuesta de CECOBAN]
    └─► sp_tef_procesararchivo60
    └─► sp_tef_procesararchivo61
```

---

## Journey J-D13-05 · Consulta de operaciones TEF (canal cliente)

**Descripción:** El cliente o operador consulta el estado de sus transferencias desde el portal o la app.

```
Canal (app/web/sucursal)
  └─► sp_obtenerinformaciontef     [consulta general por cuenta/fecha]
  └─► sp_consultarepop_tef         [reporte de operaciones TEF]
  └─► sp_consdevext_tef            [consulta devoluciones externas]
  └─► sp_revoperacionestef         [revisión de estado de operaciones]
```

---

## Fanout / fanin por SP clave (extraído del callgraph)

| SP | fan_in | fan_out | Rol en el grafo |
|----|--------|---------|-----------------|
| `abono_cta` | 25 | 1 | Hub de abono — muy llamado |
| `cal_fecha_pre_fh` | 96 | 0 | Utilidad de cálculo de fecha hábil |
| `cargo_cta` | 0 | 2 | Entry point de cargo |
| `sp_tef_grabaoperacion` | [SME-PENDING] | [SME-PENDING] | Registro central de operaciones |
| `sp_tef_bitacora` | [SME-PENDING] | [SME-PENDING] | Log de auditoría |

---

## `[SME-PENDING]`

- [ ] Confirmar el orden exacto de llamadas en los journeys de envío y recepción.
- [ ] Documentar el horario de corte CECOBAN y su impacto en `sp_tef_validahorario`.
- [ ] Validar si los 71 SPs aislados participan en journeys no documentados.
- [ ] Identificar el scheduler/job que dispara el ciclo de cámara (BP-D13-08 a BP-D13-15).

---
*Generado por análisis de callgraph bditef · Etapa 3*
