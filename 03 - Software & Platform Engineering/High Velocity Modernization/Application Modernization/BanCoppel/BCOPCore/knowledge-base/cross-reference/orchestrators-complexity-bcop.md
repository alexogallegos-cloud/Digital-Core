# BCOPCore · Orquestadores Complejos — Deuda Técnica de Refactor

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 · **Fuente:** análisis de flujo de control del código SPL
> **Generado:** 2026-07-03 por `extract-flow.py`

SPs orquestadores ordenados por **complejidad de orquestación** = `invocaciones + 2·IF + 3·bucles + 2·profundidad`. Los de mayor score son **candidatos prioritarios a refactor antes de transpilar** (`[DT-IFX]`): concentran lógica condicional profunda difícil de reescribir con equivalencia garantizada.

| # | SP | Objetivo | Dominio | LOC | Invoc. | IF | Bucles | Prof. | Score |
|--:|---|---|---|--:|--:|--:|--:|--:|--:|
| 1 | `califica_scoring2_cjunk` | califica scoring crediticio | Solicitudes | 3,067 | 11 | 253 | 9 | 19 | 582 🔴 |
| 2 | `califica_scoring_cjunk` | califica scoring crediticio | Solicitudes | 2,797 | 23 | 189 | 2 | 17 | 441 🔴 |
| 3 | `abono_ref` | abono | Cheques | 1,653 | 9 | 166 | 3 | 8 | 366 🔴 |
| 4 | `califica_scoring_cjunk_motor` | califica scoring crediticio y motor de decisión | Solicitudes | 2,363 | 17 | 154 | 2 | 13 | 357 🔴 |
| 5 | `sp_obtiene_productos` | obtiene productos | Solicitudes | 1,799 | 9 | 138 | 17 | 8 | 352 🔴 |
| 6 | `califica_scoring_cjunk_precal_opt` | califica scoring crediticio | Solicitudes | 2,306 | 14 | 151 | 2 | 12 | 346 🔴 |
| 7 | `califica_scoring_cjunk_precal_opt_motor` | califica scoring crediticio y motor de decisión | Solicitudes | 2,277 | 14 | 151 | 2 | 12 | 346 🔴 |
| 8 | `califica_scoring_cjunk_precal` | califica scoring crediticio | Solicitudes | 2,280 | 14 | 144 | 2 | 11 | 330 🔴 |
| 9 | `califica_scoring_cjunk_pba` | califica scoring crediticio | Solicitudes | 2,250 | 12 | 144 | 2 | 11 | 328 🔴 |
| 10 | `determina_lincred_tc_cjunk` | determina línea de crédito | Solicitudes | 1,831 | 8 | 133 | 2 | 6 | 292 🔴 |
| 11 | `califica_scoring_cjunk_pbagh` | califica scoring crediticio | Solicitudes | 1,992 | 12 | 125 | 2 | 7 | 282 🔴 |
| 12 | `spei_recordenpago_ws` | recibe orden de pago | SPEI | 1,402 | 24 | 83 | 2 | 6 | 208 🔴 |
| 13 | `spei_devcodi` | devolución · CoDi — Cobro Digital | SPEI | 1,347 | 43 | 76 | 0 | 5 | 205 🔴 |
| 14 | `sp_regordenctecte_bex_codi_exp1` | orden y cliente · CoDi — Cobro Digital | SPEI | 1,304 | 45 | 73 | 0 | 4 | 199 🔴 |
| 15 | `sp_regordenctecte_bex_codi` | orden y cliente · CoDi — Cobro Digital | SPEI | 1,360 | 45 | 72 | 0 | 4 | 197 🔴 |
| 16 | `cargon_ref_web` | cargo (canal web) | Cheques | 1,106 | 7 | 86 | 1 | 7 | 196 🔴 |
| 17 | `cargon_ref` | cargo | Cheques | 1,064 | 7 | 82 | 1 | 7 | 188 🔴 |
| 18 | `cargo_ref` | cargo | Cheques | 769 | 11 | 74 | 2 | 7 | 179 🔴 |
| 19 | `reversion` | reversa | Cheques | 1,298 | 7 | 72 | 3 | 8 | 176 🔴 |
| 20 | `sp_mon_buro_conssolcredlincred2` | consulta Buró de Crédito, solicitud, crédito y línea de crédito | Créditos | 1,033 | 8 | 63 | 7 | 9 | 173 🔴 |
| 21 | `spei_recordenpago` | recibe orden de pago | SPEI | 1,120 | 23 | 62 | 2 | 6 | 165 🔴 |
| 22 | `sp_cnsif_consprodcte` | consulta producto de cliente | Integración | 873 | 2 | 37 | 21 | 6 | 151 🔴 |
| 23 | `spei_recerrorescodi` | recepción error · CoDi — Cobro Digital | SPEI | 416 | 0 | 58 | 0 | 3 | 122 🔴 |
| 24 | `sp_nom_gen_mov_mes` | genera nómina, movimiento y mes | Cheques | 689 | 0 | 29 | 11 | 4 | 99 🔴 |
| 25 | `sp_cont_conssaldosdiariosb4` | consulta saldos diarios | Contabilidad | 472 | 13 | 21 | 12 | 4 | 99 🔴 |
| 26 | `spei_aplicaordenpago` | aplica orden de pago | SPEI | 659 | 9 | 32 | 1 | 6 | 88 🔴 |
| 27 | `cargo_ref_pos` | cargo y punto de venta | Cheques | 346 | 5 | 36 | 0 | 4 | 85 🔴 |
| 28 | `sp_cac_consultasolincrelincred` | consulta solicitud de crédito, crédito y línea de crédito | Créditos | 492 | 0 | 31 | 4 | 5 | 84 🔴 |
| 29 | `sp_consulta_saldos_general` | consulta saldos (general) | Créditos | 548 | 4 | 29 | 0 | 9 | 80 🔴 |
| 30 | `sp_desbctasfus_consctas` | desbloqueo cuentas | Integración | 473 | 4 | 19 | 9 | 5 | 79 🔴 |
| 31 | `sp_obtenerdoctosdigitalizar` | obtiene documentos | Créditos | 402 | 0 | 27 | 4 | 6 | 78 🔴 |
| 32 | `sp_cont_cargamovimientob3` | carga movimiento | Contabilidad | 337 | 11 | 21 | 2 | 4 | 67 🔴 |
| 33 | `sp_cuentadoctos_soc` | cuenta, documentos y Sistema Operativo Central | Integración | 227 | 6 | 17 | 4 | 3 | 58 🟠 |
| 34 | `bloqueo_cta` | bloquea cuenta cuenta | Cheques | 419 | 2 | 21 | 1 | 4 | 55 🟠 |
| 35 | `sp_validanombenefbts` | valida nómina, beneficiario y beneficiarios | Saldos | 330 | 1 | 24 | 0 | 2 | 53 🟠 |
| 36 | `sp_dicta_consultactesdictamen2` | consulta clientes y dictamen | Integración | 466 | 0 | 14 | 6 | 2 | 50 🟠 |
| 37 | `sp_traspasocuentas_cred_soc` | traspaso entre cuentas cuenta, crédito y Sistema Operativo Central | Créditos | 374 | 1 | 17 | 2 | 3 | 47 🟠 |
| 38 | `sp_sac_wu_guardarespuesta_search` | guarda respuesta y archivo | Saldos | 287 | 3 | 17 | 0 | 5 | 47 🟠 |
| 39 | `sp_consultafechasart61` | consulta fechas · Art. 61 LIC | Canal Digital | 192 | 1 | 7 | 9 | 2 | 46 🟠 |
| 40 | `spei_recextemporanea` | recibe orden extemporánea | SPEI | 318 | 3 | 16 | 1 | 4 | 46 🟠 |

**32 orquestadores críticos** (score ≥ 60) concentran la mayor deuda de refactor. Recomendación: descomponerlos en servicios más pequeños **antes** de la transpilación a Java, y cubrir cada rama condicional con golden master tests (equivalencia ≥ 99.95%).

## Anti-patrón detectado

- **`[DT-IFX]` Mega-orquestador con anidamiento profundo:** un SP con profundidad de control ≥ 5 y decenas de invocaciones condicionales es equivalente al DT-002 (P010) de Banamex S500 — reescribirlo 1:1 arrastra la complejidad; refactorizar por rama de negocio reduce el riesgo de equivalencia.

*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: source/ + extract-flow.py*