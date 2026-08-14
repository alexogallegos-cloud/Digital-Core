# AppMovil — Canal Móvil BanCoppel (Application Modernization)
# togaf_type: channels
# togaf_state: discovering
# togaf_system_of: differentiation
# togaf_abb: digital-banking-mobile

> **Descubierto por:** Informix Informix seed — [app-movil-seed.json](../../core/Informix/digital-brain/seeds/app-movil-seed.json)
> **Fecha descubrimiento:** 2026-08-12
> **Estado:** `[STATE: DISCOVERING]` — 14 Digital Twins activos · Brain pendiente de construcción.
> **Última actualización:** 2026-08-13 — ecosistema de DTs completo (14/14).

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `channels` |
| `togaf_state` | `discovered` |
| `togaf_system_of` | `differentiation` |
| `togaf_abb` | `digital-banking-mobile` |
| `bian_domains` | — *(pendiente de mapeo)* |

---

## Relación con Informix PISA — desde seed

| Campo | Valor |
|-------|-------|
| Relación | `calls` |
| Dirección | `unknown` (Informix es el receptor) |
| Volumen conocido | 363 endpoints |
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

## Ecosistema de Digital Twins (14/14 activos)

| # | DT | Foco | Artefacto central |
|---|----|------|-------------------|
| 1 | [dt-almas](dt/dt-almas/CLAUDE.md) | 12 microservicios críticos del canal | `almas-appmovil.md` |
| 2 | [dt-autorizador-pagos](dt/dt-autorizador-pagos/CLAUDE.md) | Flujos CoDi / SPEI / Transferencias | `flujo-pagos-appmovil.md` |
| 3 | [dt-capacidades](dt/dt-capacidades/CLAUDE.md) | Cobertura ETB v5.0 por dominio | `capacidades-appmovil-etb.md` |
| 4 | [dt-catalogo-errores](dt/dt-catalogo-errores/CLAUDE.md) | 19 códigos de error del canal | `catalogo-errores-appmovil.md` |
| 5 | [dt-java-analysis](dt/dt-java-analysis/CLAUDE.md) | Calidad Java / ISO 5055 / deuda técnica | `analisis-calidad-appmovil.md` |
| 6 | [dt-journeys](dt/dt-journeys/CLAUDE.md) | ~24 customer journeys del canal | `journeys-catalog-appmovil.md` |
| 7 | [dt-modelo-dominio](dt/dt-modelo-dominio/CLAUDE.md) | Bounded contexts / capas / dependencias | `modelo-dominio-appmovil.md` |
| 8 | [dt-reglas](dt/dt-reglas/CLAUDE.md) | Reglas de negocio del canal | `catalogo-reglas-appmovil.md` |
| 9 | [dt-regulatorio](dt/dt-regulatorio/CLAUDE.md) | CNBV / Banxico / PCI-DSS | `marco-regulatorio-appmovil.md` |
| 10 | [dt-riesgos](dt/dt-riesgos/CLAUDE.md) | 14 riesgos de migración del canal | `registro-riesgos-appmovil.md` |
| 11 | [dt-sp-dependencies](dt/dt-sp-dependencies/CLAUDE.md) | **Puente JDBC → SPs Informix** (crítico AM) | `inventario-sp-dependencies.md` |
| 12 | [dt-spei](dt/dt-spei/CLAUDE.md) | Flujo SPEI saliente + CoDi interbank | `flujo-spei-appmovil.md` |
| 13 | [dt-validador](dt/dt-validador/CLAUDE.md) | Meta-agente: smoke tests de los 14 DTs | `reporte-validacion-appmovil.md` |
| 14 | [dt-vocabulario](dt/dt-vocabulario/CLAUDE.md) | Vocabulario de negocio y técnico del canal | `vocabulario-appmovil.md` |

---

## Próximos Pasos (DoR para activar brain)

- [x] Ecosistema de 14 Digital Twins completo (2026-08-13)
- [ ] Construir `digital-brain/build-brain.py` — extrae ~200 microservicios Java a `brain.db`
- [ ] Ejecutar DT-Validador: smoke tests de los 14 DTs (pase de existencia)
- [ ] Poblar artefactos centrales de cada DT analizando `source/code/`
- [ ] Emitir seeds propios (Regla B11) al terminar el primer build del brain
- [ ] Actualizar `bank-brain/build-bank-brain.py` con ATTACH a este brain

---

*Generado automáticamente por `bank-brain/bootstrap-from-seeds.py` · 2026-08-12 · Regla B9 AM*
*Actualizado: 2026-08-13 — 14 DTs activos · STATE: DISCOVERING*
