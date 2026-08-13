# atlas — Sistema Descubierto (Application Modernization)
# togaf_type: data
# togaf_state: discovered
# togaf_system_of: innovation
# togaf_abb: data-platform

> **Descubierto por:** BCOPCore Informix seed — [atlas-seed.json](../../core/Informix/digital-brain/seeds/atlas-seed.json)
> **Fecha descubrimiento:** 2026-08-12
> **Estado:** `[STATE: DISCOVERED]` — estructura canónica abierta por **Regla B9**. Brain pendiente.
> **Regla B10:** este CLAUDE.md es el registro del otro lado de la relación hasta que exista un brain propio.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `data` |
| `togaf_state` | `discovered` |
| `togaf_system_of` | `innovation` |
| `togaf_abb` | `data-platform` |
| `bian_domains` | — *(pendiente de mapeo)* |

---

## Relación con Informix PISA — desde seed

| Campo | Valor |
|-------|-------|
| Relación | `reads` |
| Dirección | `inbound` (Informix es el receptor) |
| Volumen conocido | 0 jobs CTM |
| Criticidad | `high` |
| Dominios Informix involucrados | — |
| Regulación aplicable | — |
| Descripción | Atlas extrae datos historicos de Informix via JDBC y archivos flat para la migracion a los sistemas target (Transact, Apolo, SmartVista). Compite con ventana batch. |

---

## Seeds Recibidos

| Emisor | Versión | Fecha | Artefacto origen |
|--------|---------|-------|-----------------|
| `informix` | `BCOPCore v1.8.0` | 2026-08-12 | `digital-brain/brain.db::cross_dependencies` |

---

## Próximos Pasos (DoR para activar brain)

- [ ] Obtener artefactos fuente del sistema: código, config, logs, inventario
- [ ] Mover artefactos a `source/` (readonly — no modificar originales)
- [ ] Construir `digital-brain/build-brain.py` para este sistema
- [ ] Validar cross-dependencies con equipo BanCoppel
- [ ] Emitir seeds propios (Regla B11) al terminar el primer build del brain
- [ ] Actualizar `bank-brain/build-bank-brain.py` con ATTACH a este brain

---

*Generado automáticamente por `bank-brain/bootstrap-from-seeds.py` · 2026-08-12 · Regla B9 AM*
