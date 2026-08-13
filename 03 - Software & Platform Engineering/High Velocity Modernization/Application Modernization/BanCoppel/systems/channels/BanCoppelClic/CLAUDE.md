# BanCoppel Clic — Sistema Descubierto (Application Modernization)
# togaf_type: channels
# togaf_state: discovered
# togaf_system_of: differentiation
# togaf_abb: digital-banking-web

> **Descubierto por:** Informix Informix seed — [bancoppel-clic-seed.json](../../core/Informix/digital-brain/seeds/bancoppel-clic-seed.json)
> **Fecha descubrimiento:** 2026-08-12
> **Estado:** `[STATE: DISCOVERED]` — estructura canónica abierta por **Regla B9**. Brain pendiente.
> **Regla B10:** este CLAUDE.md es el registro del otro lado de la relación hasta que exista un brain propio.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `channels` |
| `togaf_state` | `discovered` |
| `togaf_system_of` | `differentiation` |
| `togaf_abb` | `digital-banking-web` |
| `bian_domains` | — *(pendiente de mapeo)* |

---

## Relación con Informix PISA — desde seed

| Campo | Valor |
|-------|-------|
| Relación | `calls` |
| Dirección | `unknown` (Informix es el receptor) |
| Volumen conocido | 34 endpoints |
| Criticidad | `unknown` |
| Dominios Informix involucrados | D01, D02 |
| Regulación aplicable | CNBV Banca Electrónica |
| Descripción | — |

---

## Seeds Recibidos

| Emisor | Versión | Fecha | Artefacto origen |
|--------|---------|-------|-----------------|
| `informix` | `Informix v1.8.0` | 2026-08-12 | `digital-brain/brain.db::external_systems` |

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
