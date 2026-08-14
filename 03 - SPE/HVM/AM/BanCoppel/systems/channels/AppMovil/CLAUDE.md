# AppMovil — Canal Móvil BanCoppel (Application Modernization)
# togaf_type: channels
# togaf_state: active
# togaf_system_of: differentiation
# togaf_abb: digital-banking-mobile

> **Descubierto por:** Informix Informix seed — [app-movil-seed.json](../../core/Informix/digital-brain/seeds/app-movil-seed.json)
> **Fecha descubrimiento:** 2026-08-12
> **Estado:** `[STATE: ACTIVE]` — 14 Digital Twins activos · Brain construido (2026-08-14).
> **Última actualización:** 2026-08-14 — brain.db activo: 178 MSAs · 49 SPs únicos en 11 BDs Informix · 133 referencias · 2563 términos · 51 endpoints · 16 deps Feign.

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

## Relación con Informix PISA — desde seed + análisis brain

| Campo | Valor |
|-------|-------|
| Relación | `calls` |
| Dirección | `outbound` — AppMovil invoca SPs Informix vía JDBC/JPA |
| SPs Informix confirmados | **49 únicos** en 11 BDs (brain 2026-08-14) |
| Referencias totales | 133 (21 Java Constants + 112 properties) |
| Dominios Informix tocados | bdisac, bdicred, bdicheq, bdisolic, bdispei, bdinteg, intercard, bdiprog, bdinvers, bdimnsj, bdibpi |
| Regulación aplicable | CNBV Banca Electrónica · Banxico SPEI/CoDi · PCI-DSS |
| Criticidad | `critical` — CoDi/SPEI y cargo/abono son flujos de pago real |

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

## Estado del Brain (2026-08-14)

| Métrica | Valor |
|---------|-------|
| Microservicios analizados | 178 / 216 cargados |
| Almas identificadas | 11 |
| Referencias a SPs Informix | 133 (21 Java Constants + 112 properties) |
| SPs únicos extraídos | **49** en 11 BDs — 98% cobertura vs. portal curado (50 SPs) |
| Bases de datos Informix | 11 (`bdisac`·17 · `bdicred`·10 · `bdicheq`·9 · `bdisolic`·4 · `bdispei`·3 · `intercard`·1 · `bdiprog`·1 · `bdinvers`·1 · `bdinteg`·1 · `bdimnsj`·1 · `bdibpi`·1) |
| Endpoints REST | 51 |
| Términos vocabulario | 2563 |
| Dependencias Feign | 16 |
| MSAs con Informix (pom.xml) | 68 |
| MSAs con MongoDB | 96 |
| MSAs con Redis | 40 |

### Patrones de SP Discovery — Estado

| Patrón | Descripción | Estado |
|--------|-------------|--------|
| P1 | `{call db:sp(...)}` en `*Constants.java` | ✅ Activo |
| P2 | `EXECUTE PROCEDURE db:sp(...)` en `*Constants.java` | ✅ Activo |
| P3/P4 | CALL patterns en `.properties` | ✅ Activo |
| P5 | `db:sp_name` plain en `.properties` | ✅ Activo |
| P6c | `"db:sp_name"` o `"db:informix.sp_name"` plain string en Java | ✅ Activo (2026-08-14) |
| P6d | `"db\\:sp_name"` escaped-colon en Java (solo sin qualifier `informix.`) | ✅ Activo (2026-08-14) |
| P_DBINFER | SP sin prefijo en properties; DB inferida del JDBC URL (single-datasource) | ✅ Activo (2026-08-14) |
| P8 | `configMap.yml` scanned como properties adicionales | ✅ Activo (2026-08-14) |

### Gap Residual (2 SPs de 50)

| SP | DB | Motivo no capturado |
|----|----|--------------------|
| `sp_valida_celular_cancelado` | bdinteg | EXECUTE PROCEDURE con string concatenada (`"bdinteg:" + VAR_NAME + "(...")`) — no parseable estático |
| `sp_activatarjeta_iccat` | intercard | `{call sp_xxx(...)}` sin prefijo `db:` → requeriría inferencia cross-constante |

### Próximos Pasos

- [x] Ecosistema de 14 Digital Twins completo (2026-08-13)
- [x] Construir `digital-brain/build-brain.py` — brain.db activo (2026-08-14)
- [x] Patrones P6c/P6d/P_DBINFER/P8 implementados — 49 SPs (2026-08-14)
- [ ] Ejecutar DT-Validador: smoke tests de los 14 DTs (pase de existencia)
- [ ] Poblar artefactos centrales de cada DT analizando `source/code/`
- [ ] Emitir seeds propios (Regla B11) al terminar el rebuild con patrones P6-P8
- [ ] Actualizar `bank-brain/build-bank-brain.py` con ATTACH a este brain

---

*Generado automáticamente por `bank-brain/bootstrap-from-seeds.py` · 2026-08-12 · Regla B9 AM*
*Actualizado: 2026-08-14 — brain.db ACTIVO · 49 SPs únicos · 11 BDs Informix · 133 refs · patrones P6-P8 implementados*
