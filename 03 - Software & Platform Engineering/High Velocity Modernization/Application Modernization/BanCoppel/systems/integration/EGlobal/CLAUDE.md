# e-global — Sistema Descubierto (Application Modernization)
# togaf_type: integration
# togaf_state: discovered
# togaf_system_of: innovation
# togaf_abb: payment-authorization

> **Descubierto por:** BCOPCore Informix seed — [e-global-seed.json](../../core/Informix/digital-brain/seeds/e-global-seed.json)
> **Fecha descubrimiento:** 2026-08-12
> **Estado:** `[STATE: DISCOVERED]` — estructura canónica abierta por **Regla B9**. Brain pendiente.
> **Regla B10:** este CLAUDE.md es el registro del otro lado de la relación hasta que exista un brain propio.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `integration` |
| `togaf_state` | `discovered` |
| `togaf_system_of` | `innovation` |
| `togaf_abb` | `payment-authorization` |
| `bian_domains` | — *(pendiente de mapeo)* |

---

## Relación con Informix PISA — desde seed

| Campo | Valor |
|-------|-------|
| Relación | `calls` |
| Dirección | `inbound` (Informix es el receptor) |
| Volumen conocido | 0 jobs CTM |
| Criticidad | `critical` |
| Dominios Informix involucrados | — |
| Regulación aplicable | — |
| Descripción | e-global (capa de autorizacion externa) invoca SPs de autorizacion de pagos en Informix (dominio D08 SPEI + D16 Tarjetas). Codigos ESB sin contexto son probablemente errores de autorizacion e-global. |

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
