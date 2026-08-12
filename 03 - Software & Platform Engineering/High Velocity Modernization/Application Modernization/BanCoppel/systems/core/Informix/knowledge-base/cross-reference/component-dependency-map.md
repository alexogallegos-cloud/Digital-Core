# BCOPCore · Mapa de Dependencias entre Componentes

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Dependency Analysis  
> **Generado:** 2026-08-02 · `build-dependency-map-kb.py`  
> **Callgraph:** 3,761 nodos · 34,279 edges · 36 dominios/bases  
> **Propósito:** fuente de verdad para el plan de migración — qué depende de qué, cuáles SPs son bloqueantes, y qué dominios deben migrarse antes que otros.  

---

## 1. Matriz de dependencias entre dominios (cross-DB)

> Solo edges `cross_db=true` (llamadas que cruzan bases de datos). Las internas se muestran en §6.
> Leer como: fila = dominio **origen** (caller), columna = dominio **destino** (callee).

| Origen \ Destino | Canal We | Integrac | Créditos | Sucursal | Saldos/S | Sitio Es | Cheques | Solicitu | Mensajer | PLD/LIDE | Cobranza | TEF | Auditorí | Aclaraci | Tarjeta  | SPEI | Programa | Buró Cré | Transfer | BEI |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **Canal Web** (`D01`) | — | 11391 | 9027 | 3255 | 2601 | 1755 | 494 | 1316 | 949 | 718 | — | 20 | 172 | — | 137 | — | 10 | — | — | — |
| **Integración** (`D02`) | 4 | — | 53 | — | 9 | 1 | 46 | 3 | 73 | — | 13 | — | 10 | — | — | — | — | — | — | — |
| **Créditos** (`D03`) | — | 39 | — | — | — | 5 | 242 | 15 | 77 | — | 138 | — | 5 | — | — | — | — | 3 | — | — |
| **Sucursales** (`D10`) | — | 27 | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| **Saldos/SAC** (`D05`) | — | 12 | 21 | — | — | — | 312 | — | 10 | — | — | — | — | — | — | — | — | — | — | — |
| **Sitio Especi** (`bdisitesp`) | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| **Cheques** (`D04`) | 13 | 43 | 5 | 1 | 1 | — | — | — | 72 | — | — | — | — | — | — | 3 | — | — | — | — |
| **Solicitudes** (`D06`) | — | 7 | 54 | — | — | — | 6 | — | 23 | — | 4 | — | — | — | — | — | — | — | — | — |
| **Mensajería** (`D09`) | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| **PLD/LIDE** (`D15`) | — | — | — | — | — | — | 9 | — | — | — | — | — | — | — | — | — | — | — | — | — |
| **Cobranza** (`D11`) | — | — | 21 | — | — | 27 | — | — | 53 | — | — | — | — | — | — | — | — | — | — | — |
| **TEF** (`D13`) | — | 49 | 19 | — | — | — | 105 | — | — | — | — | — | — | — | — | — | — | — | — | — |
| **Auditoría** (`bdiauditor`) | — | 4 | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| **Aclaraciones** (`D07`) | — | — | 21 | — | — | — | 125 | — | 34 | — | — | — | — | — | — | — | — | — | — | — |
| **Tarjeta Copp** (`bditarjcop`) | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| **SPEI** (`D08`) | — | 2 | — | — | — | — | 48 | — | 19 | — | — | — | — | — | — | — | — | — | — | — |
| **Programas** (`bdiprog`) | — | 18 | 2 | — | 5 | — | 30 | — | 7 | — | — | — | — | — | — | — | — | — | — | — |
| **Buró Crédito** (`bdiburo`) | — | — | 8 | — | — | — | — | 16 | — | — | 34 | — | — | — | — | — | — | — | — | — |
| **Transfer** (`bditransfer`) | — | — | 14 | — | — | — | 37 | — | 3 | — | — | — | — | — | — | — | — | — | — | — |
| **BEI** (`D14`) | — | 39 | 4 | — | — | — | 8 | — | 1 | — | — | — | — | — | — | — | — | — | — | — |

---

## 2. Top 40 dependencias cross-dominio (pares más frecuentes)

| # | DB Origen | DB Destino | Dom. Origen | Dom. Destino | Edges |
|---|---|---|---|---|---:|
| 1 | `bdicnweb` | `bdinteg` | Canal Web | Integración | 11,391 |
| 2 | `bdicnweb` | `bdicred` | Canal Web | Créditos | 9,027 |
| 3 | `bdicnweb` | `bdisuc` | Canal Web | Sucursales | 3,255 |
| 4 | `bdicnweb` | `bdisac` | Canal Web | Saldos/SAC | 2,601 |
| 5 | `bdicnweb` | `bdisitesp` | Canal Web | Sitio Especial | 1,755 |
| 6 | `bdicnweb` | `bdisolic` | Canal Web | Solicitudes | 1,316 |
| 7 | `bdicnweb` | `bdimnsj` | Canal Web | Mensajería | 949 |
| 8 | `bdicnweb` | `bdilide` | Canal Web | PLD/LIDE | 718 |
| 9 | `bdicnweb` | `bdicheq` | Canal Web | Cheques | 494 |
| 10 | `bdisac` | `bdicheq` | Saldos/SAC | Cheques | 312 |
| 11 | `bdicred` | `bdicheq` | Créditos | Cheques | 242 |
| 12 | `bdicnweb` | `bdiauditor` | Canal Web | Auditoría | 172 |
| 13 | `bdicred` | `bdicobranza` | Créditos | Cobranza | 138 |
| 14 | `bdicnweb` | `bditarjcop` | Canal Web | Tarjeta Coppel | 137 |
| 15 | `bdiaclaracion` | `bdicheq` | Aclaraciones | Cheques | 125 |
| 16 | `bditef` | `bdicheq` | TEF | Cheques | 105 |
| 17 | `bdicred` | `bdimnsj` | Créditos | Mensajería | 77 |
| 18 | `bdinteg` | `bdimnsj` | Integración | Mensajería | 73 |
| 19 | `bdicheq` | `bdimnsj` | Cheques | Mensajería | 72 |
| 20 | `bdisolic` | `bdicred` | Solicitudes | Créditos | 54 |
| 21 | `bdinteg` | `bdicred` | Integración | Créditos | 53 |
| 22 | `bdicobranza` | `bdimnsj` | Cobranza | Mensajería | 53 |
| 23 | `bditef` | `bdinteg` | TEF | Integración | 49 |
| 24 | `bdispei` | `bdicheq` | SPEI | Cheques | 48 |
| 25 | `bdinteg` | `bdicheq` | Integración | Cheques | 46 |
| 26 | `bdicheq` | `bdinteg` | Cheques | Integración | 43 |
| 27 | `bdicred` | `bdinteg` | Créditos | Integración | 39 |
| 28 | `bdibei` | `bdinteg` | BEI | Integración | 39 |
| 29 | `bditransfer` | `bdicheq` | Transfer | Cheques | 37 |
| 30 | `bdiaclaracion` | `bdimnsj` | Aclaraciones | Mensajería | 34 |
| 31 | `bdiburo` | `bdicobranza` | Buró Crédito | Cobranza | 34 |
| 32 | `bdidomi` | `bdicheq` | Domiciliación | Cheques | 34 |
| 33 | `bdiprog` | `bdicheq` | Programas | Cheques | 30 |
| 34 | `intercard` | `bdimnsj` | Tarjetas | Mensajería | 29 |
| 35 | `bdisuc` | `bdinteg` | Sucursales | Integración | 27 |
| 36 | `bdicobranza` | `bdisitesp` | Cobranza | Sitio Especial | 27 |
| 37 | `bditarjeta` | `bdicheq` | Tarjeta (tja) | Cheques | 27 |
| 38 | `bdisolic` | `bdimnsj` | Solicitudes | Mensajería | 23 |
| 39 | `bdiaclaracion` | `bdicred` | Aclaraciones | Créditos | 21 |
| 40 | `bdicobranza` | `bdicred` | Cobranza | Créditos | 21 |

> **Interpretación para el plan de migración:** si D01 llama a D02 3,490 veces,
> D02 debe estar estable en el target antes de migrar cualquier SP de D01.

---

## 3. Fan-in champions — SPs más llamados (nodos críticos)

> Un SP con fan_in alto es un **bloqueante de migración**: si falla, todos sus callers fallan.
> Estos SPs deben tener golden master y parallel-run verificado **antes** de cualquier cutover.

| # | SP | DB | Dom. | fan_in | fan_out | LOC | Callers (muestra) |
|---|---|---|---|---:|---:|---:|---|
| 1 | `sp_cnsif_confirmaejecutivo` | `bdinteg` | D02 | 2,400 | 1 | 1,194 | `sp_cred_insertaproductos`, `sp_reportedetalletransucursalsac`, `sp_puntoscompro_generaarchivo` |
| 2 | `sp_registra_evento` | `bdimnsj` | D09 | 1,404 | 0 | 446 | `sp_insbitsmstelcte_apps`, `sp_cartareest_catpromo`, `sp_activatarjeta_iccat` |
| 3 | `sp_split_cadena` | `bdicnweb` | D01 | 857 | 1 | 171 | `sp_bitacora`, `sp_calificacion_scoring`, `sp_consultareportepagoscre` |
| 4 | `sp_cnsif_permisosejecutivo` | `bdinteg` | D02 | 621 | 1 | 1,140 | `sp_cp_validacaractertdc`, `sp_cnsif_consprodcte`, `sp_doctosfusionados` |
| 5 | `cargo_ref` | `bdicheq` | D04 | 561 | 27 | 5,790 | `bloqueo_cta`, `cargo_ref`, `reversion` |
| 6 | `abono_ref` | `bdicheq` | D04 | 520 | 7 | 1,654 | `bloqueo_cta`, `cargo_ref`, `reversion` |
| 7 | `sp_consulta_saldos_general` | `bdicred` | D03 | 435 | 4 | 815 | `reversion`, `sp_obtenerdoctosdigitalizar`, `sp_cnsif_consprodcte` |
| 8 | `sp_inserta_bitacora_cob` | `bdicobranza` | D11 | 406 | 0 | 56 | `sp_burofisicas_cortos`, `sp_cartareest_catpromo`, `sp_contacto_vencimiento_credito` |
| 9 | `sp_valida_perfil_usuario` | `bdinteg` | D02 | 388 | 0 | 183 | `sp_consultareportepagoscre`, `sp_cp_validacaractertdc`, `eliminasolicusuariomc` |
| 10 | `sp_consultadatospiezas_bym3` | `bdisuc` | D10 | 381 | 0 | 1,298 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 11 | `sp_consutacat_dictamen_bym` | `bdisuc` | D10 | 378 | 0 | 397 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 12 | `reversion` | `bdicheq` | D04 | 377 | 18 | 7,312 | `reversion`, `sp_cargarreversarcuentatoken_bei`, `sp_soe_cargarreversarcuentatoken` |
| 13 | `sp_consultadatospiezas_bym3_totales` | `bdisuc` | D10 | 376 | 0 | 432 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 14 | `sp_consultadatospiezas_bym2` | `bdisuc` | D10 | 376 | 0 | 2,164 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 15 | `sp_consultacat_estatus_bym` | `bdisuc` | D10 | 375 | 0 | 484 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 16 | `sp_consulta_catdenominacion_bym` | `bdisuc` | D10 | 374 | 0 | 1,052 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 17 | `sp_altamodificacion_piezas_bym` | `bdisuc` | D10 | 373 | 0 | 332 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 18 | `sp_ope_consultarutalmacenamientoxml` | `bdicnweb` | D01 | 372 | 10 | 2,381 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 19 | `sp_escribirarchivodedeclaracionide2` | `bdilide` | D15 | 360 | 0 | 95 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 20 | `sp_formararchivodedeclaracion2` | `bdilide` | D15 | 358 | 0 | 1,251 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 21 | `sp_desc_ret` | `bdinteg` | D02 | 358 | 0 | 144 | `sp_consultareportepagoscre`, `sp_obtenerdoctosdigitalizar`, `sp_obtctaschqras` |
| 22 | `sp_cuentadoctos_soc` | `bdinteg` | D02 | 354 | 2 | 656 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 23 | `sp_bitacora` | `bdicnweb` | D01 | 345 | 18 | 7,155 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 24 | `sp_generararchivo_rst` | `bdicnweb` | D01 | 345 | 18 | 7,603 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 25 | `sp_entrada_salida` | `bdisuc` | D10 | 333 | 1 | 540 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 26 | `sp_mon_buro_conssolcredlincred2` | `bdicred` | D03 | 325 | 6 | 2,622 | `sp_bitacora`, `sp_consultareportepagoscre`, `sp_generararchivo_rst` |
| 27 | `sp_sac_guardamensajeerror` | `bdisac` | D05 | 321 | 0 | 451 | `sp_app_submitpayreversal`, `sp_bts_obtieneinfoidentificacion`, `sp_consremcambiost` |
| 28 | `sp_obtieneencabezadomasivo` | `bdicnweb` | D01 | 314 | 0 | 43 | `sp_consultareportepagoscre` |
| 29 | `sp_inserta_productos` | `bdicred` | D03 | 305 | 0 | 2,627 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 30 | `sp_consulta_frecpago` | `bdicred` | D03 | 303 | 0 | 100 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 31 | `sp_conspoliticacreditoprod` | `bdicred` | D03 | 303 | 0 | 273 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 32 | `sp_obtenerdoctosdigitalizar` | `bdicred` | D03 | 300 | 4 | 1,182 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 33 | `sp_mensajes_activos` | `bdicred` | D03 | 299 | 0 | 0 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 34 | `sp_consulta_subproducto` | `bdicred` | D03 | 298 | 8 | 3,385 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 35 | `sp_faltsob_cg` | `bdisuc` | D10 | 288 | 0 | 129 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 36 | `sp_eliminatemp` | `bdicred` | D03 | 286 | 0 | 88 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 37 | `sp_obtenctasmedioacceso` | `bdicred` | D03 | 285 | 0 | 490 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 38 | `sp_graba_politicacreditoprod` | `bdicred` | D03 | 284 | 0 | 723 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 39 | `sp_consulta_conv_productos` | `bdicred` | D03 | 283 | 0 | 190 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 40 | `sp_consultacoloniascp` | `bdinteg` | D02 | 281 | 0 | 960 | `sp_consultareportepagoscre`, `sp_guardaapoderadosctemoral`, `sp_actinfosolicitudmc` |
| 41 | `sp_consultatgarantia` | `bdicred` | D03 | 281 | 0 | 0 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 42 | `sp_obtentipofactura` | `bdicred` | D03 | 280 | 0 | 103 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 43 | `sp_obtentipoedocta` | `bdicred` | D03 | 279 | 0 | 45 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 44 | `sp_obtenercanaloperacion` | `bdicred` | D03 | 278 | 0 | 360 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 45 | `sp_obtenerdoctosimprimir` | `bdicred` | D03 | 277 | 0 | 245 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 46 | `sp_obten_eventos_msj` | `bdicred` | D03 | 276 | 0 | 541 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 47 | `sp_inserta_subproducto` | `bdicred` | D03 | 275 | 8 | 2,974 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 48 | `sp_grabatipofacturacion` | `bdicred` | D03 | 274 | 0 | 0 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 49 | `sp_sustituirse` | `bdisitesp` | bdisitesp | 274 | 1 | 218 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 50 | `sp_inserta_conv_productos` | `bdicred` | D03 | 273 | 0 | 0 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 51 | `sp_consulta_productos` | `bdicred` | D03 | 272 | 8 | 3,761 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 52 | `sp_consulta_familia` | `bdicred` | D03 | 271 | 0 | 49 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 53 | `monthadd` | `bdicred` | D03 | 271 | 0 | 16 | `sp_consultacredbloqfallecimiento`, `sp_consulta_saldos_general`, `sp_consulta_sdo_apoyo` |
| 54 | `sp_dicta_actualizastatusalerta` | `bdinteg` | D02 | 270 | 0 | 544 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 55 | `sp_eliminarse` | `bdisitesp` | bdisitesp | 269 | 1 | 195 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 56 | `sp_dicta_consultactesdictamen2` | `bdinteg` | D02 | 268 | 3 | 665 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 57 | `sp_consultaciudades` | `bdinteg` | D02 | 265 | 0 | 1,088 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 58 | `sp_marcarse` | `bdisitesp` | bdisitesp | 260 | 1 | 178 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 59 | `sp_consultaclienteseindividual` | `bdisitesp` | bdisitesp | 255 | 0 | 149 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |
| 60 | `sp_status_sol_audexcel` | `bdicred` | D03 | 254 | 1 | 607 | `sp_consultareportepagoscre`, `sp_activardesactivarproductos`, `sp_atms_actualizaconcentracionatm` |

---

## 4. Fan-out champions — SPs con más salidas (orquestadores)

> Un SP con fan_out alto es un **orquestador complejo**: llama a muchos otros SPs.
> Son los más costosos de migrar porque requieren validar la equivalencia de todas sus dependencias.

| # | SP | DB | Dom. | fan_out | fan_in | LOC | Callees (muestra) |
|---|---|---|---|---:|---:|---:|---|
| 1 | `sysbldsqltextin` | `bdinteg` | D02 | 134 | 0 | 213,929 | `sp_inserta_bitacora_cob`, `sp_consulta_saldos_general`, `bloqueo_cta` |
| 2 | `sp_cedulacontablenombre` | `bdicnweb` | D01 | 124 | 0 | 50,418 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 3 | `sp_conscedulasusuariosccl` | `bdicnweb` | D01 | 124 | 0 | 50,344 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 4 | `sp_consreportesctasinactivasart61` | `bdicnweb` | D01 | 124 | 0 | 49,998 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 5 | `sp_consreportesctasinactivasart61_totales` | `bdicnweb` | D01 | 124 | 0 | 49,912 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 6 | `sp_consultafechasart61` | `bdicnweb` | D01 | 124 | 0 | 49,845 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 7 | `sp_consultainforeportebc_detalleconsultas` | `bdicnweb` | D01 | 124 | 0 | 50,524 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 8 | `sp_obtieneultimasimagenesdigicte` | `bdicnweb` | D01 | 124 | 0 | 49,331 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 9 | `sp_reportebloqueoctasmasivocre` | `bdicnweb` | D01 | 124 | 0 | 49,577 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 10 | `sp_reportedesbloqueoctasmasivocre` | `bdicnweb` | D01 | 124 | 0 | 49,456 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 11 | `sp_usuariocedulacons` | `bdicnweb` | D01 | 124 | 0 | 50,251 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 12 | `sp_usuarioscedulasmantto` | `bdicnweb` | D01 | 124 | 0 | 50,132 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 13 | `sp_verificastatusconsultafechasart61` | `bdicnweb` | D01 | 124 | 0 | 49,653 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 14 | `sp_conssolsupreenvioanalista` | `bdicnweb` | D01 | 123 | 0 | 48,511 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 15 | `sp_verificastatusconsrepexcepciones` | `bdicnweb` | D01 | 123 | 0 | 49,248 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 16 | `sp_verificastatusconsrepgralaut` | `bdicnweb` | D01 | 123 | 0 | 49,114 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 17 | `sp_verificastatusconsrepperfilusuario` | `bdicnweb` | D01 | 123 | 0 | 48,980 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 18 | `sp_verificastatusconsrepreenvioanalista` | `bdicnweb` | D01 | 123 | 0 | 48,712 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 19 | `sp_verificastatusconsreprevisioncac` | `bdicnweb` | D01 | 123 | 0 | 48,913 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 20 | `sp_verificastatusconsreprevisioncentral` | `bdicnweb` | D01 | 123 | 0 | 48,846 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 21 | `sp_verificastatusconsrepsolsupdetsol` | `bdicnweb` | D01 | 123 | 0 | 48,779 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 22 | `sp_verificastatusconsrepsolsupstatus` | `bdicnweb` | D01 | 123 | 0 | 48,645 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 23 | `sp_verificastatusconsrepstatus` | `bdicnweb` | D01 | 123 | 0 | 48,578 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 24 | `sp_conssolsupconstatus` | `bdicnweb` | D01 | 122 | 0 | 48,364 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 25 | `sp_conssolsupconstatus_totales` | `bdicnweb` | D01 | 121 | 0 | 48,179 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 26 | `sp_conssolsupdetallesolicitud` | `bdicnweb` | D01 | 120 | 0 | 48,040 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 27 | `sp_conssolsupdetallesolicitud_totales` | `bdicnweb` | D01 | 119 | 0 | 47,878 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 28 | `sp_conssolsupoperacionmc` | `bdicnweb` | D01 | 118 | 0 | 47,729 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 29 | `sp_conssolsupoperacionmc_totales` | `bdicnweb` | D01 | 117 | 0 | 47,615 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 30 | `sp_conssolsupreenvioanalista_totales` | `bdicnweb` | D01 | 116 | 0 | 47,459 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 31 | `sp_cnt_genreportesolcred` | `bdicnweb` | D01 | 115 | 0 | 44,796 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 32 | `sp_consultaexcepcionesaumlincred` | `bdicnweb` | D01 | 115 | 0 | 47,298 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 33 | `sp_consultagralaplicadosaumlincred` | `bdicnweb` | D01 | 115 | 0 | 47,185 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 34 | `sp_consultagralautaumlincred` | `bdicnweb` | D01 | 115 | 0 | 47,009 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 35 | `sp_consultagralstatusaumlincred` | `bdicnweb` | D01 | 115 | 0 | 46,833 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 36 | `sp_consultaperfilusuarioaumlincred` | `bdicnweb` | D01 | 115 | 0 | 46,720 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 37 | `sp_consultarevisioncacaumlincred` | `bdicnweb` | D01 | 115 | 0 | 46,539 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 38 | `sp_consultarevisioncentralaumlincred` | `bdicnweb` | D01 | 115 | 0 | 46,413 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 39 | `sp_consultatotexcepcionesaumlincred` | `bdicnweb` | D01 | 115 | 0 | 46,280 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 40 | `sp_consultatotgralaplicadosaumlincred` | `bdicnweb` | D01 | 115 | 0 | 46,162 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 41 | `sp_consultatotgralautaumlincred` | `bdicnweb` | D01 | 115 | 0 | 46,034 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 42 | `sp_consultatotgralstatusaumlincred` | `bdicnweb` | D01 | 115 | 0 | 45,912 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 43 | `sp_consultatotperfilusuarioaumlincred` | `bdicnweb` | D01 | 115 | 0 | 45,788 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 44 | `sp_consultatotrevisioncacaumlincred` | `bdicnweb` | D01 | 115 | 0 | 45,669 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 45 | `sp_consultatotrevisioncentralaumlincred` | `bdicnweb` | D01 | 115 | 0 | 45,546 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 46 | `sp_sac_consulta_remesas_abonadas_tdc` | `bdicnweb` | D01 | 115 | 0 | 45,139 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 47 | `sp_sac_consulta_remesas_abonadas_tdc_totales` | `bdicnweb` | D01 | 115 | 0 | 45,425 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 48 | `sp_sac_consulta_remesas_abonadas_tdc_xls` | `bdicnweb` | D01 | 115 | 0 | 45,352 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 49 | `sp_consultas_cac_centraltotcred` | `bdicnweb` | D01 | 114 | 0 | 44,452 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 50 | `sp_ca_detallearchivosxmlprocesados` | `bdicnweb` | D01 | 113 | 0 | 42,851 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 51 | `sp_conscattiporeporte` | `bdicnweb` | D01 | 113 | 0 | 44,107 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 52 | `sp_conscattiporeporteconciliacionapertura` | `bdicnweb` | D01 | 113 | 0 | 43,418 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 53 | `sp_consultaconciliaaperturapagarescargo` | `bdicnweb` | D01 | 113 | 0 | 43,342 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 54 | `sp_consultaconciliaaperturapagarescargos_totales` | `bdicnweb` | D01 | 113 | 0 | 43,161 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 55 | `sp_consultaconciliatraspcuentas_archivo` | `bdicnweb` | D01 | 113 | 0 | 43,839 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 56 | `sp_consultaconciliatraspcuentas_totales` | `bdicnweb` | D01 | 113 | 0 | 43,536 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 57 | `sp_generarelacionctebcpcp` | `bdicnweb` | D01 | 113 | 0 | 42,641 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 58 | `sp_generareporteconciliaaperturapagarescargo` | `bdicnweb` | D01 | 113 | 0 | 43,078 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 59 | `sp_repctasinactivasart61_totales` | `bdicnweb` | D01 | 113 | 0 | 44,234 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |
| 60 | `sp_verificastatusconscaccentral` | `bdicnweb` | D01 | 113 | 0 | 44,301 | `sp_cnsif_confirmaejecutivo`, `sp_consultaclienteseindividual`, `sp_status_sol_audexcel2` |

---

## 5. Hub SPs — alto fan_in Y fan_out (puentes estructurales)

> Los hubs son el **sistema nervioso del sistema**: los falla tanto callers como callees.
> Criterio: fan_in ≥ 50 AND fan_out ≥ 20. Estos SPs deben migrarse con doble parallel-run.

| SP | DB | Dom. | fan_in | fan_out | LOC | Rol estimado |
|---|---|---|---:|---:|---:|---|
| `sp_consultareportepagoscre` | `bdicnweb` | D01 | 250 | 84 | 22,779 | distribuidor |
| `cargo_ref` | `bdicheq` | D04 | 561 | 27 | 5,790 | distribuidor |
| `sp_cp_validacaractertdc` | `bdicnweb` | D01 | 120 | 42 | 7,308 | distribuidor |
| `sp_calificacion_scoring` | `bdicnweb` | D01 | 117 | 42 | 5,759 | distribuidor |
| `sp_ccep_eliminacheques_cod46` | `bdicnweb` | D01 | 78 | 37 | 4,159 | distribuidor |
| `sp_consultachequescod47totales_ccep` | `bdicnweb` | D01 | 78 | 37 | 3,960 | distribuidor |
| `sp_consultadelvorevcod46total_ccep` | `bdicnweb` | D01 | 78 | 37 | 3,716 | distribuidor |
| `sp_consultaprocescod41_ccep` | `bdicnweb` | D01 | 78 | 37 | 3,433 | distribuidor |
| `sp_datosdiahoy_cod47` | `bdicnweb` | D01 | 78 | 37 | 3,336 | distribuidor |
| `sp_eliminasinprocesartmpcod40` | `bdicnweb` | D01 | 78 | 37 | 3,243 | distribuidor |
| `sp_genera_archivo_presencod46` | `bdicnweb` | D01 | 78 | 37 | 3,192 | distribuidor |
| `sp_genera_archivo_presencod47` | `bdicnweb` | D01 | 78 | 37 | 2,668 | distribuidor |
| `sp_ca_procesaarchivoxml` | `bdicnweb` | D01 | 107 | 24 | 14,477 | distribuidor |
| `reversion` | `bdicred` | D03 | 114 | 20 | 3,163 | distribuidor |
| `sp_aplicadevol_cod41_ccep` | `bdicnweb` | D01 | 78 | 29 | 8,339 | distribuidor |
| `sp_ope_consultachequetamdif` | `bdicnweb` | D01 | 78 | 29 | 1,968 | distribuidor |
| `sp_ope_consultadetallechequecodigo40` | `bdicnweb` | D01 | 78 | 29 | 1,799 | distribuidor |
| `sp_ope_consultadetallechequecodigo46` | `bdicnweb` | D01 | 78 | 29 | 1,640 | distribuidor |
| `sp_ope_consultadetallechequecodigo47` | `bdicnweb` | D01 | 78 | 29 | 1,494 | distribuidor |
| `sp_ope_consultaimportececoban` | `bdicnweb` | D01 | 78 | 29 | 1,350 | distribuidor |
| `sp_ope_datoscarga_genarchivo` | `bdicnweb` | D01 | 78 | 29 | 1,288 | distribuidor |
| `sp_ope_datosgral_archivocod46_ccep` | `bdicnweb` | D01 | 78 | 29 | 1,210 | distribuidor |
| `sp_ope_reportecodigo46` | `bdicnweb` | D01 | 78 | 29 | 1,103 | distribuidor |
| `sp_ope_validachequeduplicado` | `bdicnweb` | D01 | 78 | 29 | 969 | distribuidor |
| `sp_ope_consbloquearchivopresentado` | `bdicnweb` | D01 | 78 | 27 | 8,165 | distribuidor |
| `sp_ope_consultacheqsimg` | `bdicnweb` | D01 | 52 | 40 | 4,486 | puente |
| `sp_ope_consultaconsecutivoarch` | `bdicnweb` | D01 | 52 | 40 | 4,427 | puente |
| `sp_ope_grabaimagenchqsdevueltos` | `bdicnweb` | D01 | 52 | 39 | 4,360 | puente |
| `sp_ope_validaimagenchequedev` | `bdicnweb` | D01 | 52 | 38 | 4,303 | puente |
| `cargon_ref` | `bdicheq` | D04 | 70 | 24 | 8,587 | distribuidor |
| `sp_ope_consultachequesdevueltos` | `bdicnweb` | D01 | 52 | 31 | 2,153 | puente |
| `sp_ope_consultachequesdevueltos_totales` | `bdicnweb` | D01 | 52 | 30 | 2,028 | puente |
| `sp_consultaconsecutivoarchivo` | `bditef` | D13 | 54 | 25 | 7,657 | distribuidor |
| `sp_obtienecveratreo` | `bditef` | D13 | 52 | 25 | 6,603 | distribuidor |

---

## 6. Índice de aislamiento por dominio

> **Aislamiento alto** = mayoría de llamadas son internas → puede migrarse con menor coordinación cross-domain.
> **Aislamiento bajo** = muchas llamadas cross-DB → la migración requiere coordinar con otros dominios.

| DB | Dom. | Edges internos | Edges externos | Total | % Interno | Riesgo coordinación |
|---|---|---:|---:|---:|---:|---|
| `bdicnweb` | D01 | 17 | 31,845 | 31,862 | 0% | ALTO |
| `bdicred` | D03 | 11 | 525 | 536 | 2% | ALTO |
| `bdisac` | D05 | 8 | 355 | 363 | 2% | ALTO |
| `bdinteg` | D02 | 6 | 212 | 218 | 2% | ALTO |
| `bdiaclaracion` | D07 | 0 | 180 | 180 | 0% | ALTO |
| `bditef` | D13 | 0 | 173 | 173 | 0% | ALTO |
| `bdicheq` | D04 | 14 | 138 | 152 | 9% | ALTO |
| `bdicobranza` | D11 | 0 | 101 | 101 | 0% | ALTO |
| `bdisolic` | D06 | 2 | 94 | 96 | 2% | ALTO |
| `bdispei` | D08 | 0 | 69 | 69 | 0% | ALTO |
| `bdiprog` | bdiprog | 0 | 62 | 62 | 0% | ALTO |
| `bdiburo` | bdiburo | 0 | 58 | 58 | 0% | ALTO |
| `bditransfer` | bditransfer | 0 | 54 | 54 | 0% | ALTO |
| `bdibei` | D14 | 0 | 52 | 52 | 0% | ALTO |
| `bdidomi` | bdidomi | 0 | 44 | 44 | 0% | ALTO |
| `intercard` | D16 | 0 | 37 | 37 | 0% | ALTO |
| `bdivr` | bdivr | 0 | 31 | 31 | 0% | ALTO |
| `bdisuc` | D10 | 0 | 27 | 27 | 0% | ALTO |
| `bditarjeta` | bditarjeta | 0 | 27 | 27 | 0% | ALTO |
| `bdibpi` | bdibpi | 0 | 26 | 26 | 0% | ALTO |
| `bdicont` | D12 | 0 | 19 | 19 | 0% | ALTO |
| `bdicorresp` | bdicorresp | 0 | 19 | 19 | 0% | ALTO |
| `intercardbpi` | intercardbpi | 0 | 19 | 19 | 0% | ALTO |
| `bdinvers` | bdinvers | 0 | 11 | 11 | 0% | ALTO |
| `bdilide` | D15 | 0 | 9 | 9 | 0% | ALTO |
| `bditrapres` | bditrapres | 0 | 8 | 8 | 0% | ALTO |
| `bdiedoelec` | bdiedoelec | 0 | 6 | 6 | 0% | ALTO |
| `bdimonitorcob` | bdimonitorcob | 0 | 6 | 6 | 0% | ALTO |
| `bditrans` | bditrans | 0 | 5 | 5 | 0% | ALTO |
| `bdiauditor` | bdiauditor | 0 | 4 | 4 | 0% | ALTO |
| `bdicntchq` | bdicntchq | 0 | 2 | 2 | 0% | ALTO |
| `bdicplbot` | bdicplbot | 0 | 2 | 2 | 0% | ALTO |
| `bdicat` | bdicat | 0 | 1 | 1 | 0% | ALTO |

---

## 7. Cadenas críticas — paths 2-3 saltos sobre hubs

> Secuencias de llamada que pasan por al menos un hub. Son los caminos de mayor riesgo en el cutover.
> Formato: SP_A → SP_B (hub) → SP_C

| Origen | Hub | Destino | Dominios cruzados |
|---|---|---|---|
| `sp_consultareportepagoscre` | `sp_consultareportepagoscre` | `sp_cnsif_confirmaejecutivo` | 2 dominio(s) |
| `sp_consultareportepagoscre` | `sp_consultareportepagoscre` | `sp_dicta_registrositespcte` | 2 dominio(s) |
| `bloqueo_cta` | `cargo_ref` | `reversion` | 2 dominio(s) |
| `bloqueo_cta` | `cargo_ref` | `abono_ref` | 1 dominio(s) |
| `bloqueo_cta` | `cargo_ref` | `sp_cons_sdodisp_x_tpcalculo` | 1 dominio(s) |
| `cargo_ref` | `cargo_ref` | `reversion` | 2 dominio(s) |
| `cargo_ref` | `cargo_ref` | `abono_ref` | 1 dominio(s) |
| `cargo_ref` | `cargo_ref` | `sp_cons_sdodisp_x_tpcalculo` | 1 dominio(s) |
| `reversion` | `cargo_ref` | `abono_ref` | 2 dominio(s) |
| `reversion` | `cargo_ref` | `sp_cons_sdodisp_x_tpcalculo` | 2 dominio(s) |
| `sps_grabaremail` | `sp_calificacion_scoring` | `sp_cnsif_confirmaejecutivo` | 2 dominio(s) |
| `sps_grabaremail` | `sp_calificacion_scoring` | `sp_split_cadena` | 2 dominio(s) |
| `sps_grabaremail` | `sp_calificacion_scoring` | `sp_generafolionomina` | 3 dominio(s) |
| `sp_cnsif_soliccred` | `sp_calificacion_scoring` | `sp_cnsif_confirmaejecutivo` | 2 dominio(s) |
| `sp_cnsif_soliccred` | `sp_calificacion_scoring` | `sp_split_cadena` | 2 dominio(s) |
| `sp_cnsif_soliccred` | `sp_calificacion_scoring` | `sp_generafolionomina` | 3 dominio(s) |
| `sp_consultaorigenpoliza_clubfam` | `sp_calificacion_scoring` | `sp_cnsif_confirmaejecutivo` | 2 dominio(s) |
| `sp_consultaorigenpoliza_clubfam` | `sp_calificacion_scoring` | `sp_split_cadena` | 2 dominio(s) |
| `sp_consultaorigenpoliza_clubfam` | `sp_calificacion_scoring` | `sp_generafolionomina` | 3 dominio(s) |
| `reversion` | `reversion` | `sp_cons_sdodisp_x_tpcalculo` | 3 dominio(s) |
| `reversion` | `reversion` | `abono_ref` | 3 dominio(s) |
| `sp_cargarreversarcuentatoken_bei` | `reversion` | `reversion` | 3 dominio(s) |
| `sp_cargarreversarcuentatoken_bei` | `reversion` | `sp_cons_sdodisp_x_tpcalculo` | 3 dominio(s) |
| `sp_cargarreversarcuentatoken_bei` | `reversion` | `abono_ref` | 3 dominio(s) |
| `sp_soe_cargarreversarcuentatoken` | `reversion` | `reversion` | 3 dominio(s) |
| `sp_soe_cargarreversarcuentatoken` | `reversion` | `sp_cons_sdodisp_x_tpcalculo` | 3 dominio(s) |
| `sp_soe_cargarreversarcuentatoken` | `reversion` | `abono_ref` | 3 dominio(s) |

---

## 8. SPs sin conectividad en callgraph

> SPs del filesystem que NO aparecen en el callgraph — posible dead code o endpoints de entrada directa.
> **Criterio de riesgo**: si tienen > 200 LOC y no están en callgraph, revisar si son entry-points omitidos.

**Total SPs en filesystem:** 12,344  
**En callgraph:** 3,737  
**Sin conectividad (aislados):** 8,628  

> Muestra de los primeros 100 aislados (ordenados alfabéticamente):

| SP | Observación |
|---|---|
| `abona_ctas` | revisar uso |
| `abonacompensatorio` | revisar uso |
| `abono` | revisar uso |
| `abono_atm` | revisar uso |
| `abono_cred` | revisar uso |
| `abono_ctas` | revisar uso |
| `abono_ctas_18112010` | revisar uso |
| `abono_ctas_comis` | revisar uso |
| `abono_ctas_comis_pba` | revisar uso |
| `abono_ctas_ivas` | revisar uso |
| `abono_ctas_ivas_pba` | revisar uso |
| `abono_ref_pos` | revisar uso |
| `abono_ref_web` | revisar uso |
| `abono_web` | revisar uso |
| `abonoref_td` | revisar uso |
| `abreax` | revisar uso |
| `aclaraciones_edocta_sif` | revisar uso |
| `aclaraciones_edoctacrd` | revisar uso |
| `act_amocuota` | revisar uso |
| `act_amortiza_mes` | revisar uso |
| `act_cuota_periodo` | revisar uso |
| `act_datos_firma` | revisar uso |
| `act_datosfirmas` | revisar uso |
| `act_datosfirmas_web` | revisar uso |
| `act_edos_varios` | revisar uso |
| `act_encab` | revisar uso |
| `act_encab_ant` | revisar uso |
| `act_fecha` | revisar uso |
| `act_hist` | revisar uso |
| `act_histsdos` | revisar uso |
| `act_lineas` | revisar uso |
| `act_mens` | revisar uso |
| `act_movfal` | revisar uso |
| `act_movmes` | revisar uso |
| `act_pagmin` | revisar uso |
| `act_pie` | revisar uso |
| `act_pie_edos` | revisar uso |
| `act_pwd_solpendientes_bc` | revisar uso |
| `act_recursos` | revisar uso |
| `act_sdodias` | revisar uso |
| `act_sdom` | revisar uso |
| `act_sdomux` | revisar uso |
| `actasacred` | revisar uso |
| `actbancos` | revisar uso |
| `actchequessbc` | revisar uso |
| `actcuota` | revisar uso |
| `actesp` | revisar uso |
| `actgaran` | revisar uso |
| `actinstrucc` | revisar uso |
| `actinteisr` | revisar uso |
| `actinteres` | revisar uso |
| `actinversion` | revisar uso |
| `actinversion1` | revisar uso |
| `actinvmac` | revisar uso |
| `activa_procesos` | revisar uso |
| `actividad` | revisar uso |
| `actminimo` | revisar uso |
| `actsect` | revisar uso |
| `actual_sdos_dia` | revisar uso |
| `actualiza_ctasnoproc` | revisar uso |
| `actualiza_ctasnoproc_comp` | revisar uso |
| `actualiza_fecha_unicareg` | revisar uso |
| `actualiza_indicadores` | revisar uso |
| `actualiza_institucion` | revisar uso |
| `actualiza_institucion2` | revisar uso |
| `actualiza_intereses` | revisar uso |
| `actualiza_intereses_pagares` | revisar uso |
| `actualiza_saldos` | revisar uso |
| `actualiza_solicitud` | revisar uso |
| `actualiza_solos` | revisar uso |
| `actualiza_solos_pba` | revisar uso |
| `actualizaguardaconyuge_cjunk` | revisar uso |
| `actualizarpasesuc` | revisar uso |
| `actualizastatusreproceso` | revisar uso |
| `acumdias` | revisar uso |
| `afecta_amortizacion` | revisar uso |
| `ajusta_pagos` | revisar uso |
| `ajusteprovision` | revisar uso |
| `alta_firmantes` | revisar uso |
| `alta_nip` | revisar uso |
| `alta_sol_tc` | revisar uso |
| `alta_sol_tc_cjunk_multicanal` | revisar uso |
| `alta_sol_tc_cjunk_rodo` | revisar uso |
| `alta_sol_tc_cjunk_rodo2` | revisar uso |
| `alta_sol_tc_cjunk_web` | revisar uso |
| `alta_sol_tcpba` | revisar uso |
| `altaejecutivos` | revisar uso |
| `altas_td` | revisar uso |
| `altatardeb` | revisar uso |
| `altatardeb_n_mx2` | revisar uso |
| `altatardeb_n_mx3` | revisar uso |
| `altatarjeta` | revisar uso |
| `altatarrepos` | revisar uso |
| `altatarrepos_n` | revisar uso |
| `altatarrepos_n_web` | revisar uso |
| `amortizaba` | revisar uso |
| `analiza_chq` | revisar uso |
| `anioscumplidos` | revisar uso |
| `apercred1_pp` | revisar uso |
| `apercred1_tcpba` | revisar uso |
| *(+8528 más — ver filesystem)* | |

---

## 9. Recomendaciones para el plan de migración

| Prioridad | Hallazgo | Acción |
|---|---|---|
| **P1** | `sp_cnsif_confirmaejecutivo` (fan_in=2,400): SP más llamado del sistema | Estabilizar y golden-master antes de cualquier cutover |
| **P1** | `sysbldsqltextin` (fan_out=134): SP más complejo | Mapear todas sus dependencias antes de migrar |
| **P1** | Dominio `D01` (bdicnweb): 31,845 edges cross-DB | Alta coordinación — migrar SPs dependientes ANTES |
| **P2** | 34 Hub SPs identificados (fan_in≥50 Y fan_out≥20) | Cada hub requiere double parallel-run (callers + callees) |
| **P2** | Dominio `D04` (bdicheq): mayor % interno → menor coordinación | Candidato para Wave temprana — pocas dependencias externas |
| **P3** | SPs con fan_in=0 y fan_out=0 en callgraph | Revisar como posible dead code candidato a retire (7R) |

---

*Generado automáticamente · `build-dependency-map-kb.py` · BCOPCore SPE-AM-001*  
*Fuente: `callgraph-data.json` · Para actualizar: `python build-dependency-map-kb.py`*