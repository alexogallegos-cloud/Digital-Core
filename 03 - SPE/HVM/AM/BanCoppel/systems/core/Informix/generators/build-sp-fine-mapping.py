#!/usr/bin/env python3
"""
build-sp-fine-mapping.py — Informix SP Fine-Grained Capability Mapping v3.8
# v3.8 (2026-08-11): Round 26 — sucursal/grupo/noconciliad/msjafore/consaldo + D02→5.4.8
#   7.1.3  +'sucursal' — D02 sp_valida_sucursal fi=124; zero regression (only NONE SP with sucursal in 7.1.3 domains)
#   3.3.4  +'grupo' — D06 sp_obtienegrupo fi=174 (grupo crédito grupal); also D01 sp_pm_obtienegrupo fi=0
#   3.17.8 +'noconciliad' — D05 sp_sacreportesremesasnoconciliadasbts fi=26×2 (break 3-way tie vs 3.4.3/3.17.2)
#   5.3.5  +'msjafore' — D02 sp_inserta_msjafore fi=36 (mensaje AFORE = CONSAR regulatory message)
#   5.3.5  +'consaldo' — D02 sp_cnsif_consaldoscap* fi=0 (CNSIF saldos query — break tie vs 3.2.4/3.3.4)
#   D02→5.4.8(secondary) — valor_divisa_pesos fi=53 + sp_consulta_divisas_bym fi=0×2
# v3.7 (2026-08-11): Round 25 — cod47totales/statusaumlincred/principalrefer/principal_suc/actualizarfechacheques (tie-breakers for 5 high-fi SPs)
#   3.2.4  +'cod47totales' — breaks 3-way tie on sp_consultachequescod47totales_ccep fi=78 (ccep/totales/cod47 each 5.0)
#   3.3.1  +'statusaumlincred' — breaks 3-way tie on sp_cac_obtenstatusaumlincred fi=40 (status/aumlincred/lincred each 5.0)
#   3.3.4  +'principalrefer'/'principal_suc' — D03 principal debt SP (principalrefer fi=51, sp_principal_suc_rr fi=32)
#   3.2.4  +'actualizarfechacheques' — D01 sp_ope_actualizarfechacheques fi=35 (date+cheques update op)
# v3.6 (2026-08-11): Round 24 — pagoscre/archivoxml/genarchivo/tagxml/consecutivoarch/consecutivoarchivo/reportesbc/cod47/cod40/cheqsimg/liberasalret/diasret/imagenchqs/imagenchequedev/cal_fecha/productopermitido/bines
#   3.3.4  +'pagoscre' (D01: sp_consultareportepagoscre fi=250 — pagos+credito compound)
#   3.17.8 +'archivoxml'/'genarchivo'/'tagxml'/'consecutivoarch'/'consecutivoarchivo'/'reportesbc' (D01/D13 file ops)
#   3.2.4  +'cod47'/'cod40'/'cheqsimg'/'liberasalret'/'diasret'/'imagenchqs'/'imagenchequedev' (D01 check/account ops)
#   3.4.1  +'cal_fecha'/'productopermitido'/'bines' (D13 TEF pre-validation + BINS lookup)
# v3.5 (2026-08-11): Round 23 — fatca/generararchivo/reportecodigo/consultadatosrpt/chequedup/chequecod/tamdif/cuenta1/digver/cuentascan/extrae_cuentas/totaleslinea/eventos_msj/canaloperacion/conv_productos/cert_pag/msjafore/sw_ro/vdactas/consul_direc/compara_nombres/razonsocial
#   5.3.5  +'fatca' (D01: sp_cap_clasificadorparametrosfatca fi=78 — FATCA compliance)
#   3.17.8 +'generararchivo'/'reportecodigo'/'consultadatosrpt' (D01 file/report generation)
#   3.2.4  +'chequedup'/'chequecod'/'tamdif'/'cuenta1'/'digver'/'cuentascan'/'extrae_cuentas' (D01/D04 cheque+account primitives)
#   3.3.4  +'totaleslinea'/'eventos_msj'/'canaloperacion' (D03 credit servicing)
#   3.1.4  +'conv_productos' (D03: sp_conv_productos fi=283 — product conversion eligibility)
#   3.4.3  +'cert_pag'/'msjafore' (D03/D08 payment certificate + AFORE message)
#   7.1.4  +'sw ro'/'vdactas' (D01/D02 read-only switch + account view access)
#   7.1.1  +'consul_direc'/'compara_nombres'/'razonsocial' (D02 customer data queries)
# v3.4 (2026-08-10): Round 22 — factura/monthadd/genmov/familia + D03→7.1.4 + D23/D26/D36/D37/D40/D45/D46/D47
#   5.4.5  +'factura'/'facturacion' (D03: sp_obtentipofactura fi=280, sp_grabatipofacturacion fi=274)
#   3.15.2 +'monthadd' (D03 date-arithmetic utility para cálculo de períodos de interés, fi=271)
#   3.2.4  +'genmov'/'familia' (D03: genmov fi=176 genera movimiento; sp_consulta_familia fi=271 familia crédito)
#   Nuevos DOMAIN_CAPS_ADD (9):
#     D03→7.1.4(secondary) sp_bloqueocuenta fi=90, sp_desbloqueocuenta fi=40
#     D23→3.17.8(secondary) bdimis MIS sucursales — reporting KPI
#     D26→7.1.1(primary)   bdiprospectos prospectos/captación (prospecto, alta_clien)
#     D36→5.10.6(primary)  bdireporteas reportería regulatoria CNBV (resultadosat, eoetarjeta patterns)
#     D37→3.2.4(primary)   bdiadminnomina nómina — operaciones de cuenta (nomina, abona)
#     D40→1.1.1(primary)   bdibi banca por internet / portal BPI (bpi, internet, web)
#     D45→3.1.4(primary)   bdiprem premios/promociones (promo, sorteo, oferta)
#     D46→3.17.10(primary) bdiofi oficinas cobro / cajeros distribuidores (caja, cajero)
#     D47→5.9.1(primary)   bdigaran garantías y colaterales (parametro_riesgo, politica, motor)
# v3.3 (2026-08-09): Round 21 — manco/mensajeria-D09/innovattia
#   7.1.2  +'manco' (D14 bdibei: 5 unassigned mancomunidad SPs — internal; 0 SPs outside D14)
#   7.3.3  +'mnsj'/'depura mensajes'/'mover mensajes'/'errormensaje' (D09 bdimnsj — 4 SPs + D01 bonus)
#   7.3.4  +'ctetel'/'correotel'/'movregistros' (D09-only cap: sp_depura_ctetel_invalido + sp_registra_correotel + sp_movregistroshist)
#   3.17.8 +'innovattia' (D09 sp_generar_reporte_innovattia — innovattia partner report; unique SP)
# v3.2 (2026-08-09): Round 20 — politicacred/depuramov/ticketabono/sacreporteconciliacion
#   5.9.1  +'politicacred' (D03-only cap; sp_graba_politicacreditoprod fi=284 + sp_conspoliticacredprod)
#   5.3.5  +'depuramov' (D01+D02: sp_cnsif_depuramovimientostempo fi=133 — breaks 4-way tie to conf=0.4)
#   3.3.4  +'ticketabono' (D01 sp_ope_cons_ticketabonoapp fi=82 + 2 more variants)
#   3.17.8 +'sacreporteconciliacion' (D05 fi=75 — double-scores to break 3-way tie)
# v3.1 (2026-08-09): Round 19 — evaldispef (D03 fi=151) + D12 revaloriza/saldosi/sdo_dias/contcie
#   3.3.4  +'evaldispef' (D03 sp_evaldispefec_cred fi=151 — esb_exposed, evaluación disponibilidad efectiva)
#   5.4.2  +'revaloriza' (D12-exclusive cap; captures revaloriza + rrevaloriza — financial revaluation)
#   5.4.8  +'sdo dias'/'contcie'/'saldosi'/'corrige saldos' (D12 batch utilities fi=0)
# v3.0 (2026-08-09): Round 18 — sp_split_cadena (fi=857) + D16 card reports + D02 cuentas traspasar
#   Key insight: shared_service/cross_domain_primitive SPs are excluded by CROSS_ROLES (intentional).
#   sp_split_cadena (fi=857) is role='internal' — eligible; NOTE in v2.9 was outdated (D01 already had 3.17.11).
#   3.17.11 +'split cadena' (D01/D02 sp_split_cadena fi=857 — check reconciliation parser)
#   3.17.8  +'reportenegocio'/'reporte transaccional'/'reporteatmstat'/'reportespos'/'gen reporte' (D16, 9 SPs)
#   3.5.1   +'puntoscompro ' (trailing space — sp_puntoscompro_* NOT sp_puntoscompromiso, D16)
#   3.2.4   +'ctastraspasar' (D02 sp_consctastraspasar fi=221 — no collision with 7.1.1 'traspasocuen')
# v2.9 (2026-08-09): Round 17 FIX — remove 'cnsif'/'ipab' from 5.10.4 (already in 5.3.5)
#   Root cause: 'cnsif' in 5.10.4 → 3-way tie for sp_cnsif_confirmaejecutivo (fi=2400):
#     5.3.5=6, 5.10.4=6, 7.1.2=6 (via 'firma' ⊂ 'confirmaejecutivo') → 6/18=0.33 < 0.35
#     That SP was the 7.1.2 bridge node; its loss collapsed 254 propagated 7.1.2 assignments.
#   R17 effective keywords (cnsif/ipab stripped from 5.10.4, 'guardamensajeerror' kept):
#     3.17.8  +'llenacte' (D02 sp_llenacteestadocuenta* — account statement fill ~3 SPs),
#             +'sacreporte' (D05 sp_sacreporte* — SAC periodic reports ~8 SPs)
#     5.10.4  +'guardamensajeerror' (D05 sp_sac_guardamensajeerror fi=321 audit store)
#     5.4.1   +'concreing' (D12 sp_concreing_* contabilidad reintegro ~5 SPs)
#     7.1.1   +'ctedigital' (D02 sp_ctedigital_* digital account ~4 SPs)
#     3.16.1  +'pagares' (D04 sp_renuevapagares* promissory note renewal ~3 SPs)
#     3.3.4   +'adn ' (D06 sp_adn_* Adelanto de Nómina — trailing space matches prefix)
#     3.4.3   +'transfer' (D08 sp_transfer_* SPEI transfer validation ~5 SPs)
# v2.8 (2026-08-09): Round 17 — cnsif/ipab compliance + SAC reports + concreing + adn/pagares/transfer/llenacte/ctedigital
#   Sin nuevos DOMAIN_CAPS_ADD ('cheque'+D01→3.17.11 descartados: 'cheq' en 3.17.11 causa regresión)
#   REGRESIÓN: 74.1% vs R16 75.8% — causa: 'cnsif' duplicado → corregido en v2.9
# v2.7 (2026-08-09): Round 16 — D01 sp_cred_* + D08 SPEI scheduling + D44 quincena + D16 eventos
#   Nuevos DOMAIN_CAPS_ADD (2): D01→3.3.4, D16→7.3.3
#   Keywords nuevos:
#     3.3.4  +'cred ' (trailing space — sp_cred_* module en D01 bdicnweb ~18 SPs)
#     3.4.8  +'lotepend' (sp_conslotepend fi=137), +'validahoraejec' (fi=58)
#     3.5.1  +'enrola' (D16 card enrollment: sp_carga_ctes_enrola)
#     3.15.2 +'corrige capitaliz' (D03 sp_corrige_capitalizacion — reverse capitalization)
#     3.17.10 +'quincena' (D44 payroll bi-weekly ops), +'confalsuc' (D44 employee shortfall@branch)
#     3.17.11 +'cifra control' (D44 reconciliation control figure)
#     7.3.3  +'registra evento' (D16 sp_registra_evento* notification events)
# v2.6 (2026-08-09): Round 15 — D44/D32 cero-cobertura + expansión D01/D02/D03/D04/D05/D06/D16
#   Nuevos DOMAIN_CAPS_ADD (10): D44→3.17.11/5.4.1/3.17.10, D32→3.5.1/3.17.8,
#     D04→7.1.3/3.17.10, D05→3.17.10, D06→5.10.4, D03→5.4.5
#   Keywords nuevos por cap:
#     1.2.2  +atms (D01 ATM report/verify ops — sp_atms_*/sp_ope_*atms*)
#     3.2.4  +cheque (D01 checking account ops), +blqconcentr (D01 block inactive),
#            +notificactasinact (D04 inactive account notifications), +consultsolicitudes (D04)
#     3.3.1  +aumlincred (D01 credit line increase — 10 SPs)
#     3.3.4  +dicta (D02 credit decision/dictamen — 10 SPs), +prestamo (D06 loan management)
#     3.3.6  +moroso (D03 delinquent portfolio — spsd_morosos*), +validasolper (D16)
#     3.15.2 +capitaliza cred (D03 capitalizar créditos — sp_capitaliza_creditos_*)
#     3.17.8 +volumetria (D32 card volumetry), +chequesdev (D13 returned checks),
#            +replicainformacion (D32 replicate card data)
#     3.17.10 +cobranza (D04/D05 collection), +saccobranza (D05 SAC collection branch)
#     3.4.3  +payment (D05 app payment English SPs), +devoluciones pos (D16 POS returns)
#     3.5.1  +comercio (D16 merchant SPs), +transmc (D16 MC), +creditoclasico (D32),
#            +visaelectron (D32), +mc cal (D32 Mastercard daily/monthly calcs)
#     5.4.1  +quebranto (D44 bank write-offs), +sueldo (D44 employee salary)
#     5.9.5  +pldlim (D05 PLD AML limits)
#     7.1.3  +domicilio (D02 address management — 10 SPs), +medalia (D04 Medallia NPS)
# v2.5 (2026-08-09): Round 14 — FIX bug duplicado 3.15.2/3.16.1/3.3.6 + WEIGHT_NAME 4.0→5.0
#   BUG CRÍTICO: KEYWORDS dict tenía DOS entradas para '3.15.2' y '3.16.1' (D04 y D16)
#     → Python dict sobrescribía la primera entrada con la segunda
#     → D04/D03/D05 usaban keywords D16 (sin 'calcula','tasas','capintafecha','admintasas')
#     → Síntoma: sp_calculadv (D05), sp_capintafecha* (D04), sp_consulta_tasas* (D03) sin asignar
#   FIX: merge las dos entradas en una sola (unión de todos los keywords)
#   FIX 3.3.6: D03 tenía stub (9 keywords) que se sobrescribía con D11 (superset) — eliminado
#   WEIGHT_NAME 4.0→5.0: tolera hasta 9 biz-matches antes de diluir bajo 0.35
#     → cnsif D02 y totales D01 con biz corto pero múltiples caps tie: ahora pasan
#   Keywords: +cteprosp (D06 cliente prospecto → 3.1.4) +valmonto (D05 validate amount → 3.4.3)
#             +envioparametrico (D06 envíos paramétricos → 3.3.1)
# v2.4 (2026-08-09): Round 13 — WEIGHT_NAME 3.0→4.0 + D07/D11/D05/D01 expansión
#   WEIGHT_NAME 3.0→4.0: amplía tolerancia a dilución biz en D01/D02 (19/14 caps, evidencia larga)
#     → SPs con 1 name-match + 7 biz-matches: conf 3/10=0.30 (FAIL) → 4/11=0.36 (PASS)
#   domain_caps: +D05/3.15.2(comisiones SAC) +D05/5.10.4(bitacora SAC)
#                +D01/5.9.2(BCCC buró de crédito) +D11/3.17.11(depura cobranza)
#   7.1.4  +change/blqcancel (D07 sp_change_password; D01 sp_blq* blocking ops)
#   3.18.1 +recuperacion/documentos faltantes/inserta movimiento (D07 dispute ops)
#   4.5.1  +robo identidad (D07 identity theft report)
#   3.3.6  +campana/ctbcpl/telefono (D11 — bug fix 'campana'≠'campania'; ctbcpl files; phone lists)
#   3.4.3  +antad/decodifica (D05 ANTAD payment network decoding)
#   3.2.4  +confirmorder (D05 app payment confirmation)
#   5.9.2  +bccc/consultainforeportebc (D01 buró de crédito queries)
# v2.3 (2026-08-09): Round 12 — D07/D12/D03/D04 keyword expansion + domain_caps 5.10.4
#   domain_caps: +D07/5.10.4(siem/bitacora audit en aclaraciones)
#                +D03/5.10.4(bitacora audit log en créditos)
#   3.17.8 +estatus cuenta (D07 sp_consulta_estatus_cuenta* — 6 SPs account status in disputes)
#   3.18.1 +detalleeglobal/cuestionario/folio/afectacion (D07 — dispute detail, questionnaire, tracking)
#          +aclaraciones edocta (D03 — compound keyword for dispute+statement SPs)
#   3.5.7  +ajuste (D07 sp_cargoxajuste_debcred — cargo por ajuste debit/credit)
#   5.10.4 +siem (D07 sp_bitacora_siem — SIEM security audit log)
#   5.4.1  +concil/retaux/retsdo/detmaux/poliza/nivelac (D12 bdicont — GL accounting patterns)
#   3.3.4  +arr /linea/increm (D03 — ARR product ops, línea de crédito, increm* variants)
#   3.3.2  +altatarr (D03 altatarrepos* — alta tarjeta + origination of credit)
#   3.15.2 +calcula (D03 calcula_meses_fin, calculamesiversario — interest/period calculations)
#   3.2.4  +proac (D04 sp_proac_* — PROAC savings product operations — 11 SPs)
# v2.2 (2026-08-09): Round 11 — WEIGHT_NAME 2.0→3.0 + domain_caps D03/D04 + keywords
#   WEIGHT_NAME aumentado de 2.0 a 3.0: fix confidence dilution en D03/D04 (14 caps cada uno)
#     → SPs con 1 nombre-match + 4 biz-matches: conf 2/6=0.33 (FAIL) → 3/7=0.43 (PASS)
#     → Caso 'aclaraciones_edocta': 2+2 nombre=6, biz=2 → conf=3/8=0.375 (PASS vs 0.33 FAIL)
#   domain_caps: +D03/3.15.2(tasas de interés en crédito) +D04/3.15.2(tasas en bdicuen)
#   5.9.1  +motor (motor de crédito D03 — scoring engine)
#   3.3.4  +incremento (incremento de línea de crédito D03)
#   3.15.2 +tasas/calculo_int (D03/D04 interest rate calculations)
#   3.2.3  +porta (portabilidad abreviada D04)
#   3.2.4  +status (English 'status' ≠ 'estatus' — D04 account status queries)
# v2.1 (2026-08-09): Round 10 — expansión domain_caps D01/D02/D08/D10 + keywords
#   domain_caps: +D01/3.3.1(origination bdicnweb) +D01/3.3.2(disbursement bdicnweb)
#                +D02/5.10.4(bitacora/audit) +D02/1.1.2(mobile SPs) +D02/3.17.11(depura)
#                +D08/3.2.4(abono/deposit ops SPEI) +D10/7.1.1(expediente/nombre cliente)
#   1.2.2  +soldocta/recepdota (D10 ATM dotation solicitud/recepción)
#   5.9.4  +objetiva/evaluacion (D11 collection control targets/evaluation)
#   5.9.5  +agex (D11 sistema Agex = collection agency platform)
#   7.1.1  +nombrecliente (D10 sp_consultarnombrecliente*)
#   3.17.8 +consultacuentascliente (D11 exact match — 6 SPs)
# v2.0 (2026-08-09): Round 9 — recuperación adicional sobre residual post-R8
#   domain_caps: +D01/3.17.10(caja/efectivo) +D01/1.2.1(sucursales) +D01/5.4.1(contabilidad)
#                +D04/5.4.8(cierre/precierre posiciones diarias) +D05/3.1.4(cardif/convenio)
#                +D16/5.10.4(bitacora/monitor) +D16/7.1.4(genconadmin/conaut)
#   3.1.4  +cardif/convenio (D05 SAC insurance + agreement products)
#   3.15.2 +capintafecha (D04 capitalización de intereses por fecha)
#   1.2.1  +consultasucursal (D01 6 SPs branch queries)
#   7.1.1  +sepomex/consultacte (D02: postal code validation + client type query)
#   7.1.4  +genconadmin/conaut (D16: admin config generation + SP con autorización)
#   3.1.4  +boleto (D02 BanCoppel lottery ticket participation = sorteo eligibility)
#   3.17.8 +catalogo (D11 catalog of delinquent accounts — sp_cat_*)
#   3.17.11+depura (D16 reconciliation cleanup)
#   3.2.4  +maehis (D04 MAE histórico — monthly account data history)
# v1.9 (2026-08-09): Round 8 — recuperar SPs liberados por v1.8 hacia caps correctas
#   domain_caps: +D01/3.2.4(abono,nomina,transacc) +D01/3.4.3(pago,transferencia)
#                +D02/3.2.4(movimiento,movs reporting) +D03/3.2.4(ARR/invcrec servicing)
#                +D05/5.9.5(generaarchivocobranza,auronix) +D06/3.17.8(busca,totales)
#                +D07/7.1.4(session access) +D15/3.17.8(PLD queries) +D16/3.3.6(camp)
#   3.17.8 +totales(batch totals reporting) +busca(D07/D06 search) +edocuenta(D03 estado cuenta)
#   3.4.3  +spei (D08: 34 SPs alertacargospei/actualiza credspei; D13: TEF-SPEI)
#   7.1.4  +session (D14 English-language session SPs: sp_session*, sp_senet*)
#   1.2.2  +dotacion (D01 ATM cash dotation, 7 SPs)
#   3.2.4  +invcrec/movhis/movdia/abona/portanom (D03 ARR product; D01 bdicnweb ops)
#   3.3.3  +cierre (D03 credit/investment closure, 8 SPs — only D03 has 3.3.3 as cap)
#   5.9.5  +generaarchivocobranza/auronix (D05 SAC collection file generation)
#   5.10.6 +sorteo (D15 sp_sorteo_sat standalone — sorteosat no-split, sorteo splits)
# v1.8 (2026-08-09): Auditoría 3.17.8 — eliminar keywords genéricos catch-all
#   Quitados de 3.17.8: 'saldo','movimiento','estado','reporte','consulta','consultar','totales'
#   → eran verbos genéricos que capturaban 2,100+ SPs incorrectos (audit: 'consulta'=1719,
#     'reporte'=576, 'movimiento'=362, 'saldo'=359, 'estado'=285, 'totales'=248)
#   → 3.17.8 queda enfocado en account statements (edocta*) + reporting KPI (genrep/indicador)
#   → SPs liberados rutan a capacidades correctas via keywords existentes o quedan ambiguos
#   Añadidos a 7.1.4: 'reporte_acceso','reporte_usuario' (D02 access management reports)
#   Añadidos a 3.3.4: 'consultatgarantia','consulta_conv','consulta_prod_upgrade','cons_ampl'
#                     (D03 credit servicing queries capturadas antes por 'consulta' genérico)
# v1.7 (2026-08-09): Round 7 — expandir domain_caps D01/D03/D04/D05/D06/D10/D11/D16 + keywords:
#   domain_caps: +D01/1.2.2(atms_batch) +D03/5.4.1(pasecont) +D03/5.4.4(proyeccion)
#                +D04/7.1.4(bloqueo_ctas) +D04/5.4.1(auditapase) +D05/3.17.11(conciliacion)
#                +D06/1.1.2(movil) +D06/7.1.2(nip) +D10/3.17.8(consulta) +D10/5.10.4(monitor)
#                +D11/3.17.8(consultacuentascliente) +D16/7.1.3(contacto)
#   3.5.1 +altatarc/vencimiento (altatarcred D03, vencimiento tarjeta D16)
#   3.2.3 +portab/benefici/clabe (portabilidad, beneficiarios, CLABE D04)
#   3.1.4 +upgrade/prospect (mejora de producto, prospecteo D06)
#   5.4.4 +proyect (proyección de crédito D03/D06)
#   7.1.1 +ctes (clientes abreviado D02)
#   7.1.4 +bloquea/bloqueoctas (bloqueo masivo de cuentas D04)
#   3.4.3 +afore/guardaresp/validadv (AFORE D08, respuesta externa D05)
#   3.4.7 +reversion (reversa de operación D08/D10)
#   3.17.10 +caja (caja sucursal general D10)
#   5.10.4 +monitor (monitoreo sucursales D10)
#   7.1.3 +contacto (datos de contacto D16)
#   3.3.6 +triad (sistema Triad de cobranza D11)
# v1.6 (2026-08-09): Round 6 — expandir domain_caps D05/D06/D07/D10/D12/D13/D14/D16 + keywords:
#   domain_caps: +D06/5.9.2(cjunk scoring) +D06/3.3.4(pago/lincred en solicitudes)
#                +D07/3.17.8(busca/consulta en aclaraciones) +D10/3.4.3(corresp pagotdc)
#                +D10/5.4.1(pasecajag pase contable sucursales) +D11/7.3.3(mail/SMS cobranza)
#                +D12/3.17.8(gen_totaliz/totalizvar contabilidad) +D13/3.17.8(cons_* TEF)
#                +D14/3.17.8(consulta* BEI) +D16/3.17.8(reporte intercard) +D05/3.4.3(BTS payments)
#                +D02/3.1.4(sorteo/promo) +D09/3.17.8(recupera saldo mensajería)
#   7.1.1 +club/updcte/expedient/lineacte (club Coppel, update cliente, expedientes)
#   5.3.5 +privacidad (avisos de privacidad LFPDPPP)
#   3.3.2 +apercred (apertura crédito sin separador)
#   3.3.3 +cierrecred (cierre de crédito compuesto sin separador)
#   3.3.4 +lineacred/credisol/provisionlin (línea de crédito, CrediSoluciones, provisión)
#   3.1.4 +promo (promociones de crédito)
#   5.9.2 +calif/cjunk/circulocred (calificación crediticia, circulo de crédito)
#   3.4.3 +corresp/bts (corresponsal bank, Bancomer Transfer Services)
#   3.5.1 +synmotor (sync motor tarjetas D16)
#   5.9.5 +mail (envíos de correo en cobranza D11)
#   7.3.3 +suscript/notifica (suscriptores mensajería D09)
#   7.3.4 +suscriptor/recupera (historial suscripciones D09)
#   5.4.1 +auditapase/pasecajag/gen_totaliz (pases contables especiales)
#   3.17.11 +conciladm/concilatm (conciliación admin/ATM en D16)
#   5.10.6 +sorteosat (sorteo SAT sin separador — sp_carga_sorteosat D15)
#   3.17.8 +estadistic/lista_cuentas (estadísticas, lista de cuentas cliente)
# v1.5 (2026-08-09): Round 5 — expandir domain_caps D01/D03/D04/D16 + keywords:
#   domain_caps: +D01/3.17.8(totales,genrep) +D01/5.3.5(CNSIF,IPAB) +D01/3.15.2(admintasas)
#                +D03/3.17.8(edocta,consulta) +D03/3.18.1(aclaraciones) +D03/3.5.1(altatarjeta)
#                +D04/3.17.8(arr_edocta,indicadores) +D04/3.17.11(conciliachq) +D16/3.17.11(conciliacion)
#   3.17.8 +totales/genrep/indicador
#   5.3.5 +ipab
#   3.15.2 +admintasas
#   3.3.4 +lincred/amortiz/cuota
#   3.4.8 +domi (domiciliacion SPEI D08)
#   3.5.1 +altatarj
# v1.4 (2026-08-09): Round 4 — patrones residuales D02 bdinteg:
#   7.1.1 +migracion_/direcc/genclien/grabazona/prospecto (dirección, migración, prospectos)
#   7.1.2 +datoscte (sp_datoscte_ivr_web y similares)
#   7.1.3 +actvalcel (sp_actvalcel — actualiza celular)
#   3.17.8 +obtenerctas/tipo_cuenta (consultas de cuentas/tipo)
#   5.9.2 +ingreso (ingresos como dato de riesgo)
#   3.3.4 +sitcred (sitcredito — situación crédito)
# v1.3 (2026-08-09): expand D02 domain_capabilities + keywords (Round 3):
#   D02 nuevas caps: 3.17.8 (balance/reporting), 3.5.1 (cards), 5.9.2 (scoring), 3.3.4 (pago programado)
#   7.1.1 +consdirec/constipydir/comparadirec/conyuge/codpos/direccionbenef (D02 dirección/familia)
#   7.1.4 +cambio_perfil/logout/bm_nuevo/bm_recordar/limiteperfil/acivarservicio (D02 acceso BM/BPI)
#   3.17.8 +edocta/edoctageneral/ejecutaedocta/generainf_perfis/generareporte (D02 reporting)
#   3.5.1 +sol_tc/tdcaplazos (D02 cards query/solicitud)
#   5.9.2 +scoring/riesgo_cte/cal_riesgo (D02 scoring crediticio)
#   3.3.4 +ppes (D02 pago programado — consppes_n*, cteppes*)
# v1.2 (2026-08-09): expand keywords + domain_capabilities para dominios gap D01-D16:
#   domain_capabilities: +D01/7.1.1 +D10/1.1.5 +D11/3.3.6 +D16/3.5.1
#   1.1.1 +ccep/remesa/encabezad/masivo (D01 bdicnweb CCEP+batch)
#   7.1.1 +fusion/ctemoral/ctefisico/fsn/desbctas/colonias/apoderado (D01+D02 persona moral/fusión)
#   3.17.10 +bym/billetes/monedas/piezas/denominacion/faltsob/entrada_salida (D10 bdisuc)
#   1.1.5: cobertura IVR ya existe; D10 habilitado vía domain_capabilities
#   3.18.1 +acl_/buscar_mov/aplica_cierre/cancelacion_por (D07 bdiaclaracion)
#   3.3.6 +campania/bitacora_cob/inserta_gest/registra_gest (D11 bdicobranza)
#   5.9.5 +envio_camp/mail_cob (D11 bdicobranza)
#   3.4.2 +regorden/graba_spei/reg_orden (D08 bdispei)
#   3.4.8 +comasiva/reinicia_id (D08 bdispei)
#   5.4.8 +saldosdiar/cierre_diario/acumdias/carga_diaria (D12 bdicont)
#   5.4.1 +cuentacontable/auxiliar/cierre_mensual (D12 bdicont)
#   5.10.6 +eoetarjeta/resultadosat (D15 bdilide)
#   5.8.1 +declaracion/ejecutor_diario/consultacterfc (D15 bdilide)
#   7.1.4 +valida_perfil/perfil_usuario/amov (D02 bdinteg)
#   3.15.2 +horasazul (D16 intercard)
#   3.5.1: cobertura tarjeta ya existe; D16 habilitado vía domain_capabilities
# v1.1 (2026-08-08): fix accent normalization en tokenize(); expand keywords:
#   7.1.2 +huella/rostro/facial/rfc; 7.1.1 +consulta_cte patterns;
#   3.4.1/3.4.2 +TEF cheque/imagen; 7.3.4 +edocta; 3.15.1 +tokenizac/tarjeta queries

Asigna a cada SP la capacidad ETB L3 más específica dentro de su dominio,
usando keyword scoring sobre (sp.name + sp.biz).

Output:
  brain.db / sps.primary_l3            — L3 ID del SP (o NULL si transversal/ambiguo)
  brain.db / sps.primary_l3_confidence — score normalizado (0.0-1.0)
  brain.db / etb_l3.sp_fine_n          — SPs con primary_l3 = este L3
  portal/data/capability-sp-mapping.json — actualizado con conteos finos
"""
import sqlite3, json, re, sys, unicodedata
from collections import defaultdict

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BCOP     = str(__import__("pathlib").Path(__file__).resolve().parent.parent)
DB       = f"{BCOP}/digital-brain/brain.db"
OUT_JSON = f"{BCOP}/portal/data/capability-sp-mapping.json"

# ─── Vocabulario de keywords por capacidad ETB L3 ────────────────────────────
# Substrings que deben aparecer en el nombre o biz del SP.
# Peso nombre = 2.0, peso biz = 1.0
# Se usa substring matching (cubre morfología española).
KEYWORDS: dict[str, list[str]] = {
    # ── Canal Digital (D01) ──────────────────────────────────────
    '1.1.1': ['internet', 'banca_internet', 'bpi', 'web', 'portal',
              # D01 bdicnweb: CCEP, operaciones batch de canal, remesas
              'ccep', 'remesa', 'encabezad', 'masivo', 'presencod',
              'archivors', 'genera_arch', 'pagoscre'],
    '1.1.2': ['movil', 'mobile', 'app', 'celular', 'push'],
    '1.1.5': ['ivr', 'call_center', 'telefon', 'atencion_tel', 'voz'],
    '1.4.1': ['sesion', 'canal', 'login', 'token_canal'],
    # 7.1.2 / 7.1.4 compartidos — ver abajo

    # ── Integración (D02) ────────────────────────────────────────
    '5.3.5': ['cumplimiento', 'politica', 'normativ', 'regulat',
              # D02 bdinteg: monitoreo regulatorio CNSIF + personas vulnerables
              'cnsif', 'persona_vulnerable', '_aud',
              # D01 bdicnweb round 5: IPAB = Instituto para la Protección al Ahorro Bancario
              'ipab',
              # Round 6: aviso de privacidad LFPDPPP
              'privacidad',
              # Round 20: D01/D02 cnsif temporary-transaction purge (sp_cnsif_depuramovimientostempo fi=133)
              'depuramov',    # 'depuramov' subset of 'depuramovimientos' — double-scores with 'cnsif' → conf=0.4
              # Round 23: D01 FATCA classification (sp_cap_clasificadorparametrosfatca fi=78)
              'fatca',       # Foreign Account Tax Compliance Act — clasificador de parámetros FATCA
              # Round 26: D02 AFORE regulatory message + CNSIF saldo queries
              'msjafore',    # sp_inserta_msjafore fi=36 — CONSAR/AFORE regulated message; msjafore NOT in 3.4.3 for D02
              'consaldo'],   # sp_cnsif_consaldo* pattern — double-scores with 'cnsif' → 10 pts vs 3.2.4 6pts
    '7.1.1': ['alta_clien', 'registro_clien', 'nuevo_clien', 'onboard', 'crea_clien',
              'inserta_clien', 'graba_clien',
              # consulta de datos de cliente (patrones sin confundir con "credito")
              'datos_cte', 'consulta_cte', 'cons_cte', 'numcte', 'nacclien',
              'conscte', 'consclientenumcte', 'obtienedat', 'consulta_datos_cte',
              'catalogo_cte', 'catalogotipoclien', 'catalogoinfou',
              # nombres cortos sin separador (e.g. "consultacten2", "consnumcte")
              'cten', 'consnumcte', 'consedadcte', 'consultacten',
              # D01 bdicnweb: persona moral / cliente jurídico
              'ctemoral', 'apoderado', 'datos_legales',
              # D02 bdinteg: fusión/unificación de clientes, datos geográficos
              'fusion', 'fusiona', 'fsn', 'desbctas', 'logfsn', 'ctefisico',
              'colonias_cp', 'consultacp',
              # D02 bdinteg: documentos de cliente, cuenta nivel 2, club familiar, cartera externa
              'docto', 'ctanvl2', 'clubfam', 'cartera_externa', 'traspasocuen',
              # D02 bdinteg round 3: dirección/domicilio, cónyuge, código postal
              'consdirec', 'constipydir', 'comparadirec', 'conyuge', 'codpos', 'direccionbenef',
              # D02 bdinteg round 4: migración de datos de cliente, captura dirección, prospectos
              'migracion_', 'direcc', 'genclien', 'grabazona', 'prospecto',
              # Round 6: club Coppel (fidelización), update cliente, expedientes, lista de cuentas
              'club', 'updcte', 'expedient', 'lista_cuentas',
              # Round 7: "ctes" = clientes abreviado D02 (15 SPs)
              'ctes',
              # Round 9: D02 código postal (Sepomex) + consulta cliente tipo
              'sepomex', 'consultacte',
              # Round 10: D10 consultar nombre cliente + expedientes
              'nombrecliente',
              # Round 17: D02 cuenta digital (sp_ctedigital_* — ~4 SPs en bdinteg)
              'ctedigital',
              # Round 23: D02 consulta dirección / comparación de nombres / razón social
              'consul_direc',     # sp_consul_direc* — consulta dirección del cliente
              'compara_nombres',  # sp_compara_nombres* — comparación de nombres cliente
              'razonsocial'],     # sp_razonsocial* — razón social (persona moral)
    '7.1.3': ['preferencia', 'dato_contact', 'actualiz_dato', 'configurac',
              # D02 bdinteg: datos de contacto del cliente (correo, teléfono, SMS)
              'correo', 'telefono', 'bitsmstel', 'notifica_mod', 'mensaje_cel',
              'graba_tel', 'registra_tel', 'graba_cor', 'registra_cor',
              'insbitsms', 'sms_cte', 'telefonos_cte',
              # D02 bdinteg round 4: sp_actvalcel — actualizar/validar celular
              'actvalcel',
              # Round 7: datos de contacto de tarjetahabiente (D16 intercard)
              'contacto',
              # Round 15: D02 domicilio del cliente (sp_*domicilio* — 10 SPs address management)
              'domicilio',
              # Round 15: D04 Medallia NPS (sp_*medalia* — customer satisfaction survey ops)
              'medalia',    # BanCoppel spelling: medalia (sic) = Medallia NPS platform
              # Round 26: D02 branch validation (sp_valida_sucursal fi=124; only NONE in 7.1.3 domains)
              'sucursal'],  # branch/office — validación de sucursal para ops de integración D02
    # 7.1.4 shared

    # ── Créditos (D03) ───────────────────────────────────────────
    '3.1.4': ['elegib', 'oferta_cred', 'precalif', 'promocion', 'preaprobad', 'aplica_prod',
              'producto_elegib', 'califica_prod',
              # fix: compound names con underscore → tokenize los separa
              'pre_aprobad', 'consulta_pre', 'cons_param_bandera',
              # Round 6: prefijo promo* y sorteo* (product eligibility / fidelización)
              'promo', 'sorteo',
              # Round 7: upgrade de producto (mejora de condiciones), prospecteo D06
              'upgrade', 'prospect',
              # Round 9: D05 SAC insurance products + agreements; D02 lottery participation
              'cardif', 'convenio', 'boleto',
              # Round 14: D06 bdisolicitudes — cliente prospecto (sp_cteprosp_*, sp_actualiza_*_cteprosp)
              'cteprosp',   # cteprosp = cliente prospecto (abreviatura sin separador)
              # Round 23: D03 conversión de productos (sp_conv_productos fi=283 — product eligibility conversion)
              'conv_productos'],  # sp_conv_productos* — convierte elegibilidad entre productos de crédito
    '3.3.1': ['solicitud', 'aprobac', 'autorizac_cred', 'comite', 'estructur',
              'alta_cred', 'nuevo_cred', 'crea_cred', 'graba_cred', 'inserta_cred',
              # Round 14: D06 envíos paramétricos = modelos de scoring/aprobación crediticia
              'envioparametrico',  # sp_consultar_envioparametricocoppel (5 SPs D06)
              # Round 15: D01 aumento de línea de crédito (sp_aumlincred* — 10 SPs)
              'aumlincred',   # aum(ento) + lin(ea) + cred(ito) — compact portmanteau
              # Round 25: tie-breaker for sp_cac_obtenstatusaumlincred fi=40 (3-way tie: status/aumlincred/lincred each 5.0)
              'statusaumlincred'], # compound — makes 3.3.1 score 10.0 vs 5.0 on 3.3.4(lincred) + 3.2.4(status)
    '3.3.2': ['disposicion', 'dispersa', 'ministr', 'origina', 'apertura_cred',
              'desembolso', 'ministrac',
              # Round 6: apertura crédito sin separador (sp_apercred1_pp, etc.)
              'apercred',
              # Round 12: D03 altatarrepos* — alta de tarjeta + origination OS
              'altatarr'],
    '3.3.3': ['cancel', 'cierre_cred', 'liquida', 'termina_cred', 'finiquito',
              'saldo_cero', 'cierra_cred',
              # Round 6: cierre de crédito compuesto sin separador (sp_cierrecredito*)
              'cierrecred',
              # Round 8: cierre en D03 (cierre_* inversiones ARR) — seguro: solo D03 tiene cap 3.3.3
              'cierre'],
    '3.3.4': ['pago', 'saldo', 'frecpago', 'renov', 'reestructur', 'prorroga',
              'estado_cta', 'consulta_pago', 'abono', 'servicios_cred', 'consulta_saldo',
              # D02 bdinteg round 3: pago programado (consppes_n*, cteppes*)
              'ppes',
              # D02 bdinteg round 4: situación de crédito
              'sitcred',
              # D03 bdicred round 5: línea de crédito, amortización, cuotas
              'lincred', 'amortiz', 'cuota',
              # Round 6: línea de crédito compuesta sin separador, CrediSoluciones, provisión
              'lineacred', 'credisol', 'provisionlin',
              # v1.8 recovery D03: consultas de crédito antes capturadas por 'consulta' genérico
              # sp_consultatgarantia (fi=281), sp_consulta_conv_productos (fi=283),
              # sp_consulta_prod_upgrade (fi=219), cons_amplicred, conadecred
              'consultatgarantia', 'consulta_conv', 'consulta_prod_upgrade', 'cons_ampl', 'conadecred',
              # Round 11: incremento de línea de crédito (D03 sp_incremento_lincred*, sp_apli_incremento*)
              'incremento',
              # Round 12: D03 — ARR product operations, credit line, increm* short-form
              'arr ',    # ARR = Ahorro Recurrente Renovable product — arr_fechas, arr_nouno, etc.
              'linea',   # línea de crédito — act_lineas, aumento_disminucion_linea, etc.
              'increm',  # increm* prefix (incrementa_linea, etc.) — shorter than 'incremento'
              # Round 15: D02 dictamen crediticio (sp_dicta*, sp_consulta_dictamen* — 10 SPs)
              'dicta',   # dicta* = dictamen = credit committee decision
              # Round 15: D06 préstamo / gestión de crédito personal (sp_prestamo* — 5+ SPs)
              'prestamo',
              # Round 16: D01 bdicnweb módulo crédito (sp_cred_* prefix — ~18 SPs, D01→3.3.4 added)
              'cred ',   # 'cred ' (con espacio) — sp_cred_X tokeniza a ' cred X'; NO matchea 'credito' (sin espacio)
              # Round 17: D06 Adelanto de Nómina (sp_adn_* prefix — payroll advance ~5+ SPs)
              'adn ',    # 'adn ' (trailing space) — sp_adn_X tokeniza a ' adn X'
              # Round 19: D03 evaluación disponibilidad efectiva crédito (sp_evaldispefec_cred fi=151 — esb_exposed)
              'evaldispef',   # evalúa disponibilidad efectiva — D03 3.3.4; unique token, zero regression risk
              # Round 20: D01 ticket+abono consulta ops (sp_ope_cons_ticketabonoapp fi=82 + 2 more variants)
              'ticketabono',  # compound: 'ticketabono' matches all 4 ticketabono* SPs; doubly scores with 'abono'
              # Round 23: D03 credit servicing reports + event messaging + channel ops
              'totaleslinea',    # sp_totaleslinea* — totales por línea de crédito
              'eventos_msj',     # sp_eventos_msj* — mensajes de eventos de crédito
              'canaloperacion',  # sp_canaloperacion* — canal de operación para crédito
              # Round 24: D01 pagos+crédito compound (sp_consultareportepagoscre fi=250)
              'pagoscre',        # pagos+credito portmanteau — doubly scores with 'pago' → conf OK
              # Round 25: D03 principal debt SPs (principalrefer fi=51, sp_principal_suc_rr fi=32)
              'principalrefer',  # exact SP name — capital principal de deuda (referenciado)
              'principal_suc',   # sp_principal_suc_rr — principal de sucursal (deuda por sucursal)
              # Round 26: D06 grupo crédito (sp_obtienegrupo fi=174 — group loan in bdisolic)
              'grupo'],          # grupo de crédito — crédito grupal Coppel (microfinance group loan model)
    # '3.3.6' stub D03 eliminado — D11 es superset; ver definición canónica en sección D11
    '5.9.1': ['parametro_riesgo', 'politica_cred', 'regla_cred', 'score_param',
              # Round 11: D03 motor de crédito (credit scoring engine)
              'motor',
              # Round 20: D03 credit policy management (sp_graba_politicacreditoprod fi=284, 5.9.1 D03-only)
              'politicacred'],  # 'politicacred' substring of 'politicacreditoprod' — unique to credit policy SPs
    '5.9.2': ['buro', 'calificac', 'score', 'evaluac_riesgo', 'nivel_riesgo',
              'monburo', 'mon_buro', 'consulta_buro', 'riesgo_cred',
              # D02 bdinteg round 3: scoring crediticio (califica_scoring, riesgo_cliente)
              'scoring', 'riesgo_cte', 'cal_riesgo',
              # D02 bdinteg round 4: ingresos como dato de riesgo crediticio
              'ingreso',
              # Round 6: calificación sin sufijo completo, cjunk (junk credit tier D06), círculo
              'calif', 'cjunk', 'circulocred',
              # Round 13: D01 bdicnweb — Buró de Crédito Coppel (BCCC) queries
              'bccc',                  # sp_bccc_* (3 SPs) — consulta buró
              'consultainforeportebc'], # sp_consultainforeportebc* (5 SPs) — Info Reporte Buró de Crédito

    # ── Cheques / Cuentas (D04) ──────────────────────────────────
    '3.15.2': ['interes', 'comision', 'calcula_cargo', 'tarifa_cta', 'tasa_cta',
               # D01 bdicnweb round 5: administrador de tasas
               'admintasas',
               # Round 9: D04 capitalización de intereses por fecha (sp_capintafecha*)
               'capintafecha',
               # Round 11: D03 tasas de crédito (sp_consulta_tasas*, sp_actualiza_tasas*); calculo interés
               'tasas', 'calculo_int',
               # Round 12: D03 período/interés calculations (calcula_meses_fin, calculamesiversario)
               'calcula',
               # Round 14 FIX: merge keywords D16 intercard (antes en entrada duplicada sobrescribía D04)
               'tasa',        # tasa standalone D16 (≠ tasas plural) — sp_tasa_*, sp_cons_tasa*
               'calcula_tarj', # cálculo de cargos/intereses de tarjeta D16
               'cargo_tarj',  # cargo sobre tarjeta D16
               'cons_fechaexp', # consulta fecha expiración tarjeta D16
               'horasazul',  # D16 intercard: tarifa especial por horario (horas azules)
               # Round 15: D03 capitalizar créditos (sp_capitaliza_creditos_* — 5 SPs)
               'capitaliza cred',  # compound: capitaliza + crédito(s)
               # Round 16: D03 corregir capitalización (sp_corrige_capitalizacion — reverse fix)
               'corrige capitaliz',  # compound: corrige + capitaliz(acion)
               # Round 22: D03 aritmética de fechas para cálculo de períodos de interés
               'monthadd'],   # sp_monthadd fi=271 — utilidad de cálculo de mes; D03-only (3.15.2)
    '3.16.1': ['limite', 'saldo_max', 'tope', 'disposicion_max', 'linea_cred_cta',
               # Round 14 FIX: merge keywords D16 intercard (antes en entrada duplicada sobrescribía D04)
               'credito_disp', 'saldo_limite', 'saldo_tarj',
               # Round 17: D04 pagarés (sp_renuevapagares* — promissory note renewal ~3 SPs)
               'pagares'],
    '3.2.1':  ['apertura_cta', 'solicitud_cta', 'inicio_cta', 'nueva_cta'],
    '3.2.2':  ['formaliz', 'firma_contrato', 'contrato_cta', 'apertura_formal'],
    '3.2.3':  ['alta_cta', 'crea_cta', 'producto_ahorro', 'graba_cta',
               # Round 7: portabilidad de cuenta, beneficiarios, CLABE D04
               'portab', 'benefici', 'clabe',
               # Round 11: abbreviated portability pattern (sp_porta_*, sp_porta_cta — sin 'portab' completo)
               'porta'],
    '3.2.4':  ['retiro', 'deposito', 'cargo', 'abono', 'transacc', 'nomi', 'nomina',
               'aplica', 'aplica_pago', 'app_aplica', 'bts_aplica', 'msw_aplica',
               # balance / historial — incluidos en Deposit Account Servicing
               'saldo', 'sdos', 'cons_saldo', 'consulta_saldo',
               'movimiento', 'movs', 'consultmovs',
               # firmantes de cuenta
               'firmante', 'firma_cta', 'consctesfir',
               # notificación CUB ventanilla (actualización cuenta)
               'notif_cub', 'cub_vent',
               # reversas y grabado de pagos en cuenta
               'reverso', 'reversion', 'graba_pago', 'grabapago', 'grabapgserv',
               # mobile app orders (D05 SAC)
               'app_record', 'app_get', 'recordorder', 'getorder',
               # Round 8: ARR inversión recurrente (D03 bdicred) — movimientos y períodos
               'invcrec', 'movhis', 'movdia',
               # Round 8: D01 bdicnweb — formas verbales sin separador
               'abona',     # sp_abona_ctas* (abona en lugar de abono)
               'portanom',  # sp_portanom* (portanómina — pago nómina en portal web)
               # Round 9: D04 MAE histórico (monthly account entity — historial mensual de cuenta)
               'maehis',
               # Round 11: D04 English 'status' = account status queries (≠ Spanish 'estatus')
               'status',
               # Round 12: D04 PROAC = producto de cuenta de ahorro con inscripción y ciclo anual
               'proac',
               # Round 13: D05 bdisac app payment confirmation (sp_app_confirmorder, sp_app_confirmpayment)
               'confirmorder',
               # Round 15: D01 bloqueo de concentración cuentas inactivas (sp_blqconcentr*)
               'blqconcentr',
               # Round 15: D04 notificación cuentas inactivas (sp_notificactasinact*)
               'notificactasinact',
               # Round 15: D04 consulta solicitudes de cuenta (sp_consultsolicitudes*)
               'consultsolicitudes',
               # Round 18: D02 cuentas a traspasar (sp_consctastraspasar fi=221 — account transfer inquiry)
               'ctastraspasar',   # specific compound: no collision with 7.1.1's 'traspasocuen'
               # Round 22: D03 genera movimiento (sp_genmov fi=176) + familia de producto crédito (sp_consulta_familia fi=271)
               'genmov',    # sp_genmov — genera movimiento de cuenta; fi=176; D03 domain_cap 3.2.4 ya activo
               'familia',   # sp_consulta_familia (D03), conscteppesfamilia (D02 pago programado); 3.3.4 también score → conf OK
               # Round 23: D01 cheque operations + D04 bdicheq account primitives
               'chequedup',       # sp_ope_chequeduplicado — cheque duplicado (check dedup)
               'chequecod',       # sp_ope_consultadetallechequecodigo* — check return code detail
               'tamdif',          # sp_ope_consultachequetamdif — tamaño diferente check
               'cuenta1',         # sp_cuenta1* — acceso primitivo a cuenta (basic account access)
               'digver',          # sp_digver* — dígito verificador (digit check)
               'cuentascan',      # sp_extrae_cuentascan — extrae cuentas por scan
               'extrae_cuentas',  # sp_extrae_cuentas* — extrae cuentas (forma general)
               # Round 24: D01 check code + retention days + image ops (all fi≥42 bdicnweb)
               'cod47',           # sp_datosdiahoy_cod47 fi=78 — código 47 = cheque devuelto
               'cod40',           # sp_eliminasinprocesartmpcod40 fi=78 — código 40 = cheque truncado
               'cheqsimg',        # sp_ope_cheqsimg fi=52 — cheques + imágenes
               'liberasalret',    # sp_ope_liberasalret fi=42 — libera saldo retenido
               'diasret',         # sp_ope_diasret fi=42 — días de retención
               'imagenchqs',      # sp_ope_grabaimagenchqsdevueltos fi=52 — graba imagen cheques devueltos
               'imagenchequedev', # sp_ope_validaimagenchequedev fi=52 — valida imagen cheque devuelto
               # Round 25: tie-breakers for 3-way ties (each tie partner alone gives conf=0.333)
               'cod47totales',     # sp_consultachequescod47totales_ccep fi=78 — breaks tie with ccep(1.1.1) + totales(3.17.8)
               'actualizarfechacheques'], # sp_ope_actualizarfechacheques fi=35 — D01 cheque date update op
    '3.4.3':  ['pago', 'transferencia', 'proceso_pago', 'cargo_pago',
               # cargos directos / SPEI cargos
               'realizacargo', 'reali_cargo',
               # Round 6: corresponsal bancario (pagos en tiendas Coppel) + BTS (Bancomer Transfer)
               'corresp', 'bts',
               # Round 7: AFORE (pagos pensión vía SPEI D08), guardar respuesta servicio, validadv
               'afore', 'guardaresp', 'validadv',
               # Round 8: SPEI como keyword (D08: sp_alertacargospei, sp_actualiza_credspei, 34 SPs)
               'spei',
               # Round 13: D05 bdisac — red de pagos ANTAD + decodificación de mensajes de pago
               'antad',     # sp_decodifica_antad_* — ANTAD = Asociación Nacional de Tiendas
               'decodifica', # sp_decodifica_* — decodificación de mensajes/transacciones
               # Round 14: D05 bdisac — app validate payment amount
               'valmonto',  # sp_app_valmonto, sp_app_valmonto_aut, sp_app_valmonto_cpl (3 SPs)
               # Round 15: D05 bdisac English-named payment SPs (sp_payment_*, sp_submitpayment*)
               'payment',
               # Round 15: D16 devoluciones POS (sp_devoluciones_pos_* — POS return ops)
               'devoluciones pos',   # compound: devoluciones + pos
               # Round 17: D08 SPEI transfer validation (sp_transfer_valida_cta, sp_transfer_* ~5 SPs)
               'transfer',
               # Round 23: D03/D08 certificate of payment + AFORE message
               'cert_pag',    # sp_cert_pag* — certificado de pago (payment certificate)
               'msjafore'],   # sp_msjafore* — mensaje AFORE (pension payment messaging)
    '3.5.1':  ['tarjeta', 'emision', 'entrega_tarj', 'plastico', 'emite_tarj', 'enrola',
               # D02 bdinteg round 3: consultas y solicitudes de tarjeta de crédito
               'sol_tc', 'tdcaplazos',
               # D03 bdicred round 5: alta de tarjeta en base de créditos
               'altatarj',
               # Round 6: sync motor de tarjetas en intercard (sincronización emisor)
               'synmotor',
               # Round 7: alta tarjeta crédito sin separador, vencimiento de tarjeta
               'altatarc', 'vencimiento',
               # Round 15: D16 merchant operations (sp_comercio_* — 8 SPs tienda/comercio)
               'comercio',
               # Round 15: D16/D32 Mastercard transactions (sp_transmc_* — MC-branded SPs)
               'transmc',
               # Round 15: D32 Visa Classic / crédito clásico product (sp_calculamescreditoclasico*)
               'creditoclasico',
               # Round 15: D32 Visa Electron product (sp_replicainformacionvisaelectron*)
               'visaelectron',
               # Round 15: D32 Mastercard daily/monthly calculations (sp_mc_cal_* — 3 SPs)
               'mc cal',   # compound: 'mc' + 'cal' matches sp_mc_cal_*
               # Round 18: D16 loyalty points file generator (sp_puntoscompro_generaarchivo*)
               'puntoscompro '],   # trailing space: matches sp_puntoscompro_X but NOT sp_puntoscompromiso
    '3.5.2':  ['autorizac_tarj', 'autoriza_trans', 'verif_tarj', 'autorizatarj'],

    # ── Saldos y Cuentas (D05) ───────────────────────────────────
    '3.17.2': ['liquidez', 'tesoreria', 'fondeo', 'disponible', 'remesa', 'cambio'],
    '3.17.8': [# estados de cuenta — específicos (no genérico 'estado')
               'edocta', 'edoctageneral', 'ejecutaedocta', 'executaedocta',
               'generainf_perfis', 'generareporte',
               # consulta de cuentas por tipo (específico de reporting de cuentas)
               'obtenerctas', 'tipo_cuenta',
               # KPI / reporting analítico (no genérico 'reporte'/'consulta')
               'genrep', 'indicador', 'estadistic', 'lista_cuentas',
               # Round 8: recuperación selectiva de keywords removidos en v1.8
               # 'totales' = totales de operaciones del día (batch), específico de reporting
               'totales',
               # 'busca' = función de búsqueda informacional (D07 sp_busca_*, D06 buscar_*)
               'busca',
               # 'edocuenta' = estado de cuenta (D03: sp_edocuenta*, sin separador diferente a edocta)
               'edocuenta',
               # Round 9: D11 catálogo de cuentas deudoras (sp_cat_mora*, sp_cat_cartera*)
               'catalogo',
               # Round 10: D11 specific query pattern (6 SPs named sp_consulta_cuentas_cliente*)
               'consultacuentascliente',
               # Round 12: D07 account status queries in dispute context (sp_consulta_estatus_cuenta*)
               'estatus cuenta',
               # Round 15: D32 volumetría de tarjetas (sp_volumetriacred* — card volumetry reports)
               'volumetria',
               # Round 15: D13 cheques devueltos (sp_chequesdev* — returned checks reporting)
               'chequesdev',
               # Round 15: D32 replicación información Visa/MC (sp_replicainformacionvisa* — data sync)
               'replicainformacion',
               # Round 17: D02 account statement fill ops (sp_llenacteestadocuenta* — 3 SPs)
               'llenacte',
               # Round 17: D05 SAC periodic reports (sp_sacreportemensual*, sp_sacreportesemanal* — 8+ SPs)
               'sacreporte',
               # Round 18: D16 card-domain specific reporting (all fi=0, seed coverage)
               'reportenegocio',         # sp_reportenegocio* — 3 SPs (business reporting)
               'reporte transaccional',  # compound: sp_reporte_transaccional_* — 3 SPs (card tx report)
               'reporteatmstat',         # sp_reporteatmstat07 — ATM status report
               'reportespos',            # sp_reportespos325 — POS reports
               'gen reporte',            # compound: sp_gen_reporte_vcas — card generation report
               # Round 20: D05 SAC reconciliation+convention report (fi=75 — break 3-way tie)
               'sacreporteconciliacion', # doubly-scores with 'sacreporte' → conf=0.5 vs 3.17.11+3.1.4 at 5 each
               # Round 21: D09 innovattia partner report (sp_generar_reporte_innovattia — unique SP)
               'innovattia',   # 1 SP globally (D09); D09 has 3.17.8 in caps
               # Round 23: D01 file/report generation (sp_generararchivo_rst fi=345 + sp_reportecodigo* + sp_consultadatosrpt*)
               'generararchivo',    # sp_generararchivo_rst — genera archivo RST; no espacio entre 'generar' y 'archivo'
               'reportecodigo',     # sp_reportecodigo* — reporte por código (D01 bdicnweb)
               'consultadatosrpt',  # sp_consultadatosrpt* — consulta datos para reporte
               # Round 24: D01 file/XML/archive operations (high fi SPs not caught by Round 23)
               'archivoxml',          # sp_ca_cargaarchivoxml/sp_ca_procesaarchivoxml fi=107 (cargaarchivoxml⊃archivoxml)
               'genarchivo',          # sp_ope_datoscarga_genarchivo fi=78 — genera archivo (≠ generararchivo)
               'tagxml',              # sp_ro_extraevalor_tagxml fi=58 — extrae valor de tag XML
               'consecutivoarch',     # sp_ope_consultaconsecutivoarch fi=52 — consecutivo de archivo
               # Round 24: D13 file sequence (sp_consultaconsecutivoarchivo fi=54)
               'consecutivoarchivo',  # D13 TEF consecutive file number — D13 also has 3.17.8
               'reportesbc',          # sp_ope_reportesbc fi=42 — reportes banco central/buró crédito
               # Round 26: D05 SAC non-conciliated remittance report (break 3-way tie vs 3.4.3/3.17.2)
               'noconciliad'],        # sp_sacreportesremesas*noconciliad* fi=26×2; doubly-scores with 'sacreporte'
               # NOTE: 'cheque' intentionally NOT added — conflicts with 'cheq' keyword in 3.17.11
               # causing ~30 regressions in domains with both caps (D04/D11/D16/D44/D12)
               # NO restaurados: 'consulta','reporte','movimiento','saldo','estado','consultar'
               # — siguen siendo demasiado genéricos para 3.17.8
    # 3.2.4: 'aplica', 'pago', 'cargo', 'abono', 'retiro' — añadidos a la entrada de D04

    # ── Solicitudes (D06) ────────────────────────────────────────
    # 3.1.4, 3.2.1, 3.2.2, 3.3.1 shared from D03/D04
    '7.1.6': ['necesidad_clien', 'perfil_clien', 'evaluac_clien', 'datos_financ',
              # grupo de cliente / segmento (clasificación para solicitudes)
              'grupocliente', 'grupo_cte', 'obtengrupocliente', 'grupoclien'],

    # ── Aclaraciones (D07) ───────────────────────────────────────
    '3.18.1': ['aclarac', 'disputa', 'reclamac', 'queja', 'controversia',
               'inserta_aclar', 'graba_aclar', 'consulta_aclar',
               # D07 bdiaclaracion: prefijo sp_acl_* + operaciones de cierre/búsqueda
               'acl_', 'buscar_mov', 'aplica_cierre', 'cancelacion_por',
               # Round 12: D07 dispute operations — e-global detail, questionnaire, tracking
               'detalleeglobal', 'cuestionario', 'folio', 'afectacion',
               # Round 12: D03 compound — aclaraciones de estado de cuenta crédito
               'aclaraciones edocta',
               # Round 13: D07 — recuperación de montos/saldos en disputas
               'recuperacion',        # sp_consulta_recuperacion, sp_ins_recuperacion_saldos
               # Round 13: D07 — documentos requeridos/faltantes para aclaración
               'documentos faltantes', # sp_documentos_faltantes, sp_documentos_faltantes_canales
               # Round 13: D07 — inserción de movimiento en proceso de aclaración
               'inserta movimiento'],  # sp_inserta_movimiento, sp_inserta_tipo_movimiento
    '3.5.7':  ['contracargo', 'devolucion_cargo', 'reverso_cargo', 'chargeback',
               # Round 12: D07 sp_cargoxajuste_debcred — cargo por ajuste débito/crédito
               'ajuste'],
    '4.5.1':  ['condusef', 'denuncia', 'cumplimiento_reg', 'regulat_aclar',
               # Round 13: D07 — concentrado de robo de identidad (reporte CONDUSEF)
               'robo identidad'],  # sp_consulta_concentrado_robo_identidad

    # ── SPEI / TEF (D08 / D13) ───────────────────────────────────
    '3.4.1':  ['preproceso', 'pre_proceso', 'valida_orden', 'validatransf',
               'valida_spei', 'pre_valid',
               # TEF/cheque truncado: validación de imagen antes de captura
               'valida_imagen', 'valida_img', 'valida_imagencheque',
               # Round 24: D13 bditef pre-validation primitives
               'cal_fecha',          # cal_fecha_pre_fh fi=96 — cálculo de fecha pre-fecha (TEF scheduling)
               'productopermitido',  # sp_validaproductopermitido fi=57 — valida producto habilitado
               'bines'],             # sp_obtbines_sif fi=55 — obtiene BINs SIF (card routing validation)
    '3.4.2':  ['recepcion', 'recibe', 'captura_orden', 'rec_orden', 'recerror',
               'recdev', 'recext', 'recorden',
               # TEF/cheque truncado: insertar/consultar imagen de cheque
               'ins_img', 'ins_cheq', 'cons_img', 'imagen_cheque', 'img_det',
               'cheq_det', 'ins_cheq_det', 'cons_img_nula',
               # D08 bdispei: registro de órdenes SPEI (prefijo regorden / graba)
               'regorden', 'graba_spei', 'reg_orden'],
    # 3.4.3 shared (aplica, proceso, core payment)
    '3.4.4':  ['compensa', 'liquida_spei', 'siac', 'clearing', 'liquidac_spei'],
    '3.4.5':  ['banxico', 'interbancario', 'red_spei', 'spei_red'],
    '3.4.6':  ['notific_pago', 'confirma_pago', 'post_spei', 'estado_spei'],
    '3.4.7':  ['reverso_spei', 'devolucion_spei', 'soporte_spei', 'consultar_pp',
               'consulta_spei', 'consultar_spei',
               # Round 7: reversa/reversion de operaciones de pago (D08, D10)
               'reversion'],
    '3.4.8':  ['lote_spei', 'batch_spei', 'monitoreo_spei', 'cola_spei',
               'oper_spei', 'proceso_batch',
               # D08 bdispei: operaciones masivas y reset de ciclo
               'comasiva', 'reinicia_id',
               # D08 bdispei round 5: domiciliacion SPEI (débito automático)
               'domi',
               # Round 16: D08 consulta lote pendiente (sp_conslotepend fi=137 — SPEI lot queue)
               'lotepend',
               # Round 16: D08 valida hora de ejecución (sp_validahoraejec fi=58 — scheduling)
               'validahoraejec'],
    '7.4.1':  ['codi', 'cobro_digital', 'fintech', 'api_pago'],

    # ── Mensajería (D09) ─────────────────────────────────────────
    '2.7.1':  ['crea_mensaje', 'genera_mensaje', 'nuevo_mensaje'],
    '2.7.3':  ['plantilla', 'formato_msg', 'diseno_msg'],
    '7.3.3':  ['notificac', 'alerta', 'establece_cont', 'sms', 'msj', 'whatsapp',
               # Round 6: prefijo notifica* (sp_notifica_resultados D09) + suscriptores
               'notifica', 'suscript',
               # Round 16: D16 registra evento/notificación (sp_registra_evento* — 3+ SPs)
               'registra evento',  # compound: 'registra' + 'evento' (D16→7.3.3 added)
               # Round 21: D09 messaging ops — 'mnsj' abbreviation (safe: 1 D01 SP with mnsj already unassigned)
               'mnsj',             # sp_actstatus_mnsj (D09) + sp_cre_consultaplantillamnsj (D01 bonus, unassigned)
               'depura mensajes',  # compound: sp_depura_mensajes (D09); 0 collision in D01/D11/D16
               'mover mensajes',   # compound: sp_mover_mensajes (D09); 0 collision in D01/D11/D16
               'errormensaje'],    # sp_errormensaje (D09); 0 occurrence in D01/D11/D16 confirmed
    '7.3.4':  ['info_interact', 'seguimiento', 'historial_msg',
               # estados de cuenta electrónicos — D09
               'edocta', 'edoscta', 'estado_cta_elec', 'historica', 'serv_edoc',
               'consultanombre_serv', 'obtener_edos',
               # Round 6: suscriptor (gestión de suscripción a canales D09) + recupera historial
               'suscriptor', 'recupera',
               # Round 21: D09-only additions (7.3.4 exists only in D09 — zero cross-domain regression)
               'ctetel',       # sp_depura_ctetel_invalido — purge invalid customer phone entries
               'correotel',    # sp_registra_correotel — register customer email+phone (contact data)
               'movregistros'],# sp_movregistroshist — move historical message records

    # ── Sucursales (D10) ─────────────────────────────────────────
    '1.2.1':  ['sucursal', 'caja_suc', 'ventanilla', 'cajero_suc',
               # Round 9: branch queries from D01 bdicnweb channel DB
               'consultasucursal'],
    '1.2.2':  ['atm', 'pos', 'cajero_auto', 'kiosko', 'terminal',
               # Round 8: carga de efectivo en cajero automático (ATM cash loading D01)
               'dotacion',
               # Round 10: D10 ATM dotation documents (solicitud/recepción de dotación)
               'soldocta', 'recepdota',
               # Round 15: D01 sp_atms_* (concentración masiva ATMs — carga archivo ATM)
               'atms'],
    '3.17.10':['efectivo', 'arqueo', 'cierre_caja', 'deposito_efect',
               # D10 bdisuc: billetes y monedas (bym), piezas, denominaciones
               'bym', 'billetes', 'monedas', 'piezas', 'denominacion',
               'faltsob', 'entrada_salida', 'saldo_efect', 'sobrante', 'faltante',
               # Round 7: caja sucursal general (cajagen, numcaja, manejacajageneral D10)
               'caja',
               # Round 15: D04/D05 cobranza en caja (D04 no tiene 3.3.6 → no conflict)
               'cobranza',    # sp_*cobranza* en D04/D05 = cobro presencial en caja
               # Round 15: D05 bdisac SAC cobranza (sp_saccobranza* — 4 SPs específicos SAC)
               'saccobranza',
               # Round 16: D44 quincena = operaciones de nómina quincenal (descuentos, depósitos)
               'quincena',
               # Round 16: D44 confaltante en sucursal (sp*confalsuc* — shortfall tracking at branch)
               'confalsuc'],
    '3.17.9': ['buzon', 'deposito_noche', 'caja_noche'],

    # ── Cobranza (D11) ───────────────────────────────────────────
    # 3.3.4 Credit Servicing reusado (saldo, pago, renov)
    '3.3.6':  ['cartera', 'mora', 'vencid', 'cobr', 'recuperac',
               'castigo', 'reserva', 'portafolio', 'cobranza',
               # D11 bdicobranza: seguimiento de gestiones de cobro
               'campania', 'bitacora_cob', 'inserta_gest', 'registra_gest', 'gestion_cob',
               # Round 7: sistema Triad de cobranza tercerizado (D11)
               'triad',
               # Round 13: D11 — campana (bug fix: 'campania' ≠ 'campana' post-normalización ñ→n)
               'campana',  # sp_campana_mensual, sp_agrupacion_campana, etc.
               # Round 13: D11 ctbcpl — archivos contabilidad+CPL generados por cobranza
               'ctbcpl',   # sp_ctbcpl_gen_arcctesexcluidos, sp_ctbcpl_gen_arcctes, etc.
               # Round 13: D11 directorio de teléfonos para gestión de cobro
               'telefono', # sp_carga_telefonos, sp_cargatelefonosburo, sp_depura_telefonos
               # Round 15: D03 cartera morosa (spsd_morosos* — 5 SPs, needs D03→3.3.6 in domain_caps)
               'moroso',   # spsd_morosos_* = reporte/análisis de cartera morosa
               # Round 15: D16 validar solicitud personal de crédito (sp_validasolper* — 3 SPs)
               'validasolper'],
    '5.9.4':  ['control', 'limite', 'marca', 'mitigac', 'parametro_cobr', 'marca_cta',
               'cilocconsulta', 'ciloc',
               # Round 10: D11 collection target/evaluation (cobranza objetiva, evaluación)
               'objetiva', 'evaluacion'],
    '5.9.5':  ['alerta', 'situacion', 'mora', 'incumpl', 'cartera_venc', 'evento',
               'cilocloca', 'cilocgenera',
               # D11 bdicobranza: envío de campañas/correos de cobranza
               'envio_camp', 'mail_cob',
               # Round 6: correo electrónico de cobranza (sp_mail_envio_* sin sufijo _cob)
               'mail',
               # Round 8: D05 bdisac — generación de archivos de cobranza + sistema Auronix
               'generaarchivocobranza',  # sp_generaarchivocobranzacoppel* (3 SPs)
               'auronix',                # sistema de notificaciones de cobranza
               # Round 10: D11 sistema Agex = plataforma de cobranza externa
               'agex',
               # Round 15: D05 bdisac PLD/AML limits (sp_pldlim* — 2 SPs AML threshold validation)
               'pldlim'],

    # ── Contabilidad (D12) ───────────────────────────────────────
    '3.17.11':['conciliacion', 'cuadre', 'diferencia', 'reconcil', 'cam_', 'compensac',
               'cam_asigna', 'cam_carga', 'cam_dev', 'cam_firma', 'cam_monitor',
               'conscheq', 'cheq',
               # Round 6: conciliación admin y ATM (D16 intercard — conciladm*, concilatm*)
               'conciladm', 'concilatm',
               # Round 9: D16 limpieza de conciliación (sp_depura_*)
               'depura',
               # Round 16: D44 cifra de control (sp*cifracontrol* — hash/checksum reconciliation)
               'cifra control',   # compound: cifra + control (sp_*cifracontrol* → ' cifra control')
               # Round 18: D01/D02 string parser utility used in check reconciliation flows (fi=857)
               'split cadena'],   # compound: D01 already has 3.17.11; unique to sp_split_cadena*
    '5.4.1':  ['cont_catalogo', 'cont_catalog', 'mayor', 'cuenta_contable', 'cont_empresa',
               'cont_producto', 'cont_carga', 'catalogo_cont', 'asiento',
               # D12 bdicont: catálogo y estructura de cuentas contables
               'cuentacontable', 'auxiliar', 'cierre_mensual',
               # D12 bdicont batch: pases contables, generación de libros, depuración
               'genpoliza', 'pasecont', 'pase_movtos', 'gen_encab', 'ctas_nuevas',
               'depura_ctas', 'libmay', 'movlocal', 'pase_act_hist', 'grabarpase',
               'insertarcointeg',
               # Round 6: pase contable en caja sucursal (D10), auditoría de pase, totalizaciones
               'pasecajag', 'auditapase', 'gen_totaliz',
               # Round 12: D12 bdicont accounting patterns (GL conciliation, auxiliary ledger, voucher)
               'concil',    # concilsdos — conciliación de saldos GL
               'retaux',    # retaux, retaux_h — retorna auxiliar contable
               'retsdo',    # retsdo, retsdo_h, retsdomes — retorna saldo contable
               'detmaux',   # detmauxcon, detmauxsuc — detalle maestro auxiliar contable
               'poliza',    # rep_usuario_poliza — póliza contable (accounting voucher)
               'nivelac',   # nivelacion_ccostos — nivelación centros de costos
               # Round 15: D44 quebrantos (sp_*quebranto* — bank write-off accounting entries)
               'quebranto',
               # Round 15: D44 sueldos de empleados (sp_actualizar_sueldo_empleado*)
               'sueldo',
               # Round 17: D12 bdicont contabilidad con reintegro (sp_concreing_* — ~5 SPs)
               'concreing'],
    '5.4.2':  ['resultado', 'utilidad', 'balance', 'performance',
               # D12 bdicont batch: generación de balanza/reportes de resultados
               'balanza', 'balprev', 'repbal', 'totalbalanza', 'llenareport',
               # Round 19: D12-exclusive cap — financial revaluation (revaloriza + rrevaloriza)
               'revaloriza'],   # 5.4.2 is D12-only; 'revaloriza' substring also matches 'rrevaloriza'
    '5.4.4':  ['proyeccion', 'presupuesto', 'forecast',
               # Round 7: proyecta* en crédito (proyección de flujo de crédito D03/D06)
               'proyect'],
    '5.4.5':  ['impuesto', 'sat', 'isr', 'iva', 'retencion', 'fiscal', 'sorteo_sat',
               # Round 22: D03 bdicred — tipo de facturación/contrato (sp_obtentipofactura fi=280, sp_grabatipofacturacion fi=274)
               'factura', 'facturacion'],  # único en D03; no hay D12→5.4.5 que cree colisión
    '5.4.8':  ['posicion', 'saldo_diario', 'divisa', 'cont_divisa', 'cont_saldo',
               'datosdia', 'datos_dia',
               # D12 bdicont: posiciones y saldos diarios de contabilidad
               'saldosdiar', 'cierre_diario', 'acumdias', 'carga_diaria',
               # D12 bdicont batch: nombres abreviados de operaciones diarias de saldo
               'act_sdom', 'act_hist', 'cierre', 'precierre', 'del_co_hist',
               'act_sdodias', 'act_encab', 'inserta_estatus_cierre',
               # Round 19: D12 accounting batch utilities (fi=0; D12+D04 have 5.4.8; D04 has no these SPs)
               'sdo dias',       # compound: sp sdo_dias (' sdo dias') — D04 bdicheq has 0 sdo*dias SPs
               'contcie',        # contcie2 — contabilidad+cierre abbreviation; unique to bdicont
               'saldosi',        # saldosi — balance summary; unique name, no bdicheq collision
               'corrige saldos'], # compound: corrige_saldos; 'corrige saldos' ≠ 'corrige sdos' (D04)

    # ── TEF (D13) — mismos patrones que SPEI ────────────────────
    # keywords 3.4.1-3.4.8 ya definidas arriba, aplican igual
    # Patrones específicos de TEF/cheque están en 3.4.2 y 3.4.1 (ver D08)

    # ── BEI (D14) ────────────────────────────────────────────────
    # keywords 7.1.1-7.1.4 ya definidas arriba

    # ── LIDE / PLD (D15) ─────────────────────────────────────────
    '5.10.4': ['monitoreo', 'auditoria', 'supervision', 'bitacora', 'ope_bitacora',
               'mindstelefono',
               # Round 7: monitor* SPs en sucursales (sp_monitor_caja*, sp_admon_* D10)
               'monitor',
               # Round 12: SIEM = Security Information Event Management audit log (D07 bdiaclaracion)
               'siem',
               # Round 15: D01 acta MEC (sp_generaportadactamec* — reporte de cuentas inactivas/MEC)
               'actamec',    # acta + mec = "acta de cuenta inactiva" regulatory compliance report
               # Round 17: D05 SAC error message log (sp_sac_guardamensajeerror fi=321 — audit store)
               'guardamensajeerror'],
               # NOTE: 'cnsif' and 'ipab' NOT added here — already in 5.3.5.
               # Adding to 5.10.4 creates a 3-way tie (5.3.5 + 5.10.4 + 7.1.2 via 'firma' ⊂ 'confirma')
               # for sp_cnsif_confirmaejecutivo (fi=2400): 6+6+6=18 → 0.33 < threshold → unassigned.
               # That SP was the 7.1.2 bridge node; its loss collapsed 254 propagated 7.1.2 assignments.
    '5.10.6': ['reporte', 'ope_consulta', 'ope_carga', 'informe', 'uif', 'xml_reg',
               'cargainfo', 'ope_',
               # D15 bdilide: estado operativo emisor tarjeta + resultados SAT
               'eoetarjeta', 'resultadosat',
               # D15 bdilide batch: IDE/SAT reporting (idegen*, ideconsult*, ideconstanc*)
               'ftc_', 'idegen', 'ideconsult', 'ideconstanc',
               'generaarchiv', 'grabarsat', 'grabararch', 'consultasl',
               'actualizaide', 'consimpide', 'generafolio', 'eotd',
               'acumulacion', 'eliminaarchi', 'llamadogen', 'obtiene_movs_ide',
               # Round 6: sorteo SAT sin separador (sp_carga_sorteosat — tokeniza como 'sorteosat')
               'sorteosat',
               # Round 8: sorteo como palabra standalone (sp_sorteo_sat tokeniza como 'sorteo sat')
               'sorteo'],
    '5.8.1':  ['pld', 'lide', 'lavado', 'aml', 'listanegra', 'lista_negra',
               'busqueda_cte', 'sustituirse', 'eliminarse', 'marcarse',
               'insertasite', 'bf_', 'coincidencia',
               # D15 bdilide: declaraciones PLD, ejecución diaria screening, consulta RFC
               'declaracion', 'ejecutor_diario', 'consultacterfc',
               # D15 bdilide batch: verificación identidad, borrado operaciones
               'checacurp', 'borramovs'],
    '5.8.2':  ['fraude', 'deteccion', 'alerta_fraude', 'riesgo_op', 'bf_aplicar'],

    # ── Tarjetas (D16) ───────────────────────────────────────────
    '3.15.1': ['politica', 'procedimiento', 'parametro', 'regla',
               # consultas de catálogo / validación de producto de tarjeta
               'tokenizac', 'consultar_tarjeta', 'consulta_tarjeta',
               'tarjeta_bin', 'rango_tarjeta', 'consultatarjeta',
               'consultaregtarj', 'validaexistencia', 'consulta_rango',
               'consultatarjetabin', 'consultarangotarj'],
    # '3.15.2' D16 eliminado — mergeado en entrada canónica D04 (ver arriba)
    # '3.16.1' D16 eliminado — mergeado en entrada canónica D04 (ver arriba)
    # 3.4.3 shared (cargo, pago, transacc)
    # pin/chip/banda → autenticación de tarjeta → 3.5.2 no en D16; aproximar a 3.15.1

    # ── SAC / D05 — ampliar señales ──────────────────────────────
    # 3.17.8 Balance & reporting
    # 3.2.4  Deposit Account Servicing (aplica_pago, abono, cargo)

    # ── Shared across domains ────────────────────────────────────
    '7.1.2':  ['autenticac', 'nip', 'password', 'firma', 'biometri',
               'identificac', 'verifica', 'token', 'clave', 'acceso_cte',
               # biometría (fix acento: 'biometri' ya matchea 'biometrica' post-normaliz,
               # pero huella/rostro estaban completamente ausentes)
               'huella', 'rostro', 'facial', 'valida_hue', 'cons_hue',
               'ctehuella', 'huellacte', 'huellaine', 'bitacora_huella',
               'guardar_rostro', 'guardar_bitacora_rostro',
               # identificación fiscal / cliente (D01 batch + D02)
               'rfc', 'curp', 'ine', 'valida_rfc',
               # autenticación vía teléfono (cotel = código de teléfono)
               'cotel', 'valida_tel', 'ws_valida',
               # consulta flag de tarjeta como parte del flujo de auth
               'flagretarj', 'flag_tarj', 'consflag',
               # D02 bdinteg round 4: datos de cliente para canal IVR/web (sp_datoscte_ivr_web)
               'datoscte',
               # Round 21: D14 bdibei mancomunidad SPs without _bei suffix (5 SPs; 0 outside D14 confirmed)
               'manco'],   # sp_pp_opermancoprog, sp_consulta_detalle_admon_manco, etc.
    '7.1.4':  ['bloqueo', 'desbloqueo', 'sesion', 'permiso', 'perfil_acceso',
               'bloqueo_cta', 'desbloqueo_cta', 'bloquea_cta', 'desbloc_cta',
               # D02 bdinteg: validación y movimientos de perfil de acceso
               'valida_perfil', 'perfil_usuario', 'amov',
               # D02 bdinteg round 3: gestión de sesión/acceso en canales BM/BPI/web
               'cambio_perfil', 'logout', 'bm_nuevo', 'bm_recordar', 'limiteperfil', 'acivarservicio',
               # Round 7: bloqueo masivo de cuentas (bloquea_ctas_inactivas, bloqueoctas D04)
               'bloquea', 'bloqueoctas',
               # v1.8 recovery: reportes de acceso/usuarios (antes capturados por 'reporte' en 3.17.8)
               'reporte_acceso', 'reporte_usuario',
               # Round 8: English 'session' (D14 BEI: sp_session*, sp_senet* — español 'sesion' ≠ 'session')
               'session', 'senet',
               # Round 9: D16 admin config + autorización (sp_genconadmin*, sp_conaut*)
               'genconadmin', 'conaut',
               # Round 13: D07 — change password (English keyword, missed in R12)
               'change',      # sp_change_password
               # Round 13: D01 bdicnweb — bloqueo+cancelación de cuentas captación
               'blqcancel',   # sp_blqcancelactaexcluidacap, sp_blqconcentractainactivascap
               # Round 23: D01/D02 switch read-only mode + view/validate accounts
               'sw ro',     # sp_sw_ro* — switch read-only access control
               'vdactas'],  # sp_vdactas* — validación/visualización de cuentas (access control)
}

# Entradas adicionales que deben añadirse a domain_capabilities si aún no existen.
# Se insertan al inicio de main() para que el scoring los considere.
# Formato: (domain_id, l3_id, mapping_type)
DOMAIN_CAPS_ADD: list[tuple[str, str, str]] = [
    ('D01', '7.1.1', 'secondary'),  # bdicnweb: SPs de persona moral / cliente jurídico
    ('D10', '1.1.5', 'secondary'),  # bdivr: SPs de IVR/call center en dominio sucursales
    ('D11', '3.3.6', 'secondary'),  # bdicobranza: gestión de cartera / campañas cobro
    ('D16', '3.5.1', 'secondary'),  # intercard: emisión/activación/cancelación de tarjetas
    # Round 3: D02 bdinteg — expand candidates para batch/esb SPs de integración
    ('D02', '3.17.8', 'secondary'),  # balance/reporting: movs, edocta, sdos, consulta*, generainf_perfis*
    ('D02', '3.5.1', 'secondary'),   # cards: cons_tarjetas_cte*, alta_sol_tc*, tdcaplazos
    ('D02', '5.9.2', 'secondary'),   # risk assessment: califica_scoring, riesgo_cte
    ('D02', '3.3.4', 'secondary'),   # credit servicing: consppes_n*, cteppes* (pago programado)
    # Round 5: D01 bdicnweb — expand candidates para batch de reporting/compliance/tasas
    ('D01', '3.17.8', 'secondary'),  # batch reporting: sp_*_totales (148), genrep_* (16)
    ('D01', '5.3.5', 'secondary'),   # compliance batch: cnsif_* (17), ipab_* (10)
    ('D01', '3.15.2', 'secondary'),  # rate administration: admintasas_* (4)
    # Round 5: D03 bdicred — expand candidates para estados de cuenta y aclaraciones
    ('D03', '3.17.8', 'secondary'),  # credit statements: edocta (38), consulta (38), reporte (18)
    ('D03', '3.18.1', 'secondary'),  # disputes/aclaraciones en productos de crédito
    ('D03', '3.5.1', 'secondary'),   # tarjeta ops en base de créditos: altatarjeta
    # Round 5: D04 bdicuen — expand candidates para estados de cuenta y conciliación
    ('D04', '3.17.8', 'secondary'),  # account statements: arr_edocta*, indicadores*
    ('D04', '3.17.11', 'secondary'), # cheque reconciliation: conciliachq* (18)
    # Round 5: D16 intercard — expand candidates para conciliación
    ('D16', '3.17.11', 'secondary'), # card reconciliation: conciliacion* (9)
    # Round 6: D06 bdisolicitudes — scoring crediticio + servicing + cliente
    ('D06', '5.9.2', 'secondary'),   # credit scoring: califica_scoring_cjunk* (~53), scoring* (17)
    ('D06', '3.3.4', 'secondary'),   # credit servicing/payments: pago* (13), lincred (5)
    ('D06', '3.1.4', 'secondary'),   # product eligibility: promo*, productos elegibles
    # Round 6: D07 bdiaclaracion — consultas de soporte a aclaraciones
    ('D07', '3.17.8', 'secondary'),  # query/reporting en aclaraciones: busca* (19), consulta* (19)
    # Round 6: D10 bdisuc — pagos corresponsal + pases contables
    ('D10', '3.4.3', 'secondary'),   # corresponsal payments: corresp_pagotdc* (9)
    ('D10', '5.4.1', 'secondary'),   # accounting entries en cajas: pasecajag* (4), pasecont* (3)
    # Round 6: D11 bdicobranza — interacción con cliente vía mensajería
    ('D11', '7.3.3', 'secondary'),   # notification: sp_carga_sms_latinia*, mail_* (20)
    # Round 6: D12 bdicont — reporting contable complementario
    ('D12', '3.17.8', 'secondary'),  # reporting contable: gen_totaliz*, totalizvar* (batch)
    # Round 6: D13 bditef — consultas de soporte TEF
    ('D13', '3.17.8', 'secondary'),  # TEF queries: cons_dev* (15), totales* (5)
    # Round 6: D14 bdibei — consultas BEI empresarial
    ('D14', '3.17.8', 'secondary'),  # BEI queries: consulta_ctas*, consulta_limites* (12)
    # Round 6: D16 intercard — reporte/estadística tarjetas
    ('D16', '3.17.8', 'secondary'),  # reporting tarjetas: reporte* (10), estadisticas* (5)
    # Round 6: D05 bdisac — BTS/payment integration en SAC
    ('D05', '3.4.3', 'secondary'),   # BTS payments: sp_bts_confirmapayc, registrasdep (5)
    # Round 6: D02 bdinteg — sorteo/promo como producto
    ('D02', '3.1.4', 'secondary'),   # product eligibility: sorteo* (10), promo* (5)
    # Round 6: D09 bdimensajeria — recupera saldo/pago en mensajería
    ('D09', '3.17.8', 'secondary'),  # mensajería queries: recupera* (5), consulta* (3)
    # Round 7: D01 bdicnweb — ATM batch operations
    ('D01', '1.2.2', 'secondary'),   # ATM: sp_atms_cargaarchivoconcentracionmasiva* (~15 SPs)
    # Round 7: D03 bdicred — contabilidad interna + proyecciones
    ('D03', '5.4.1', 'secondary'),   # pases contables en créditos: pasecont* (5)
    ('D03', '5.4.4', 'secondary'),   # proyección de crédito: proyecta* (9)
    # Round 7: D04 bdicuen — bloqueo/acceso + pases contables en cuentas
    ('D04', '7.1.4', 'secondary'),   # bloqueo masivo cuentas: bloquea_ctas_inactivas* (10)
    ('D04', '5.4.1', 'secondary'),   # pases contables en cuentas: auditapase_ant* (7)
    # Round 7: D05 bdisac — conciliación SAC
    ('D05', '3.17.11', 'secondary'), # conciliacion: conciliacion* (5), obtienemovconciliacion (2)
    # Round 7: D06 bdisolicitudes — canal móvil + NIP
    ('D06', '1.1.2', 'secondary'),   # canal móvil solicitudes: movil* (9 SPs)
    ('D06', '7.1.2', 'secondary'),   # NIP authentication: cambio_nip (3), cancela_nip (2)
    # Round 7: D10 bdisuc — consultas + monitoreo
    ('D10', '3.17.8', 'secondary'),  # consultas: consulta* (8), saldos* (2), totales* (2)
    ('D10', '5.10.4', 'secondary'),  # monitoring: sp_monitor_* (9), sp_admon* (5)
    # Round 7: D11 bdicobranza — consultas de cuentas
    ('D11', '3.17.8', 'secondary'),  # queries: consultacuentascliente* (6), movimientos* (6)
    # Round 7: D16 intercard — datos de contacto
    ('D16', '7.1.3', 'secondary'),   # contacto cliente tarjeta: contacto* (5), ctes* (3)
    # Round 8: D01/D02/D03 — expandir a deposit account + payment (SPs liberados por v1.8)
    ('D01', '3.2.4', 'secondary'),   # bdicnweb deposit ops: abono, nomina, transacc, retiro, saldo
    ('D01', '3.4.3', 'secondary'),   # bdicnweb payment: pago, transferencia, corresp
    ('D02', '3.2.4', 'secondary'),   # bdinteg movement reporting: movimiento, movs, bm_obten_*
    ('D03', '3.2.4', 'secondary'),   # bdicred ARR product: invcrec, movhis, movdia, abona
    # Round 8: D05 SAC — colecciones/cobranza
    ('D05', '5.9.5', 'secondary'),   # bdisac collections monitoring: generaarchivocobranza, auronix
    # Round 8: D06 solicitudes — reporting queries
    ('D06', '3.17.8', 'secondary'),  # bdisolicitudes busca*, totales, edocuenta
    # Round 8: D07 aclaraciones — acceso
    ('D07', '7.1.4', 'secondary'),   # bdiaclaracion session/access: session, senet patterns
    # Round 8: D15 PLD — reporting queries
    ('D15', '3.17.8', 'secondary'),  # bdilide query reporting: busca*, totales
    # Round 8: D16 intercard — credit portfolio
    ('D16', '3.3.6', 'secondary'),   # intercard credit portfolio: campania*, objetiv*, camp*
    # Round 9: D01 bdicnweb — caja/sucursal/contabilidad adicionales
    ('D01', '3.17.10', 'secondary'), # caja/efectivo channel ops: caja* (bdicnweb tiene caja de internet)
    ('D01', '1.2.1', 'secondary'),   # branch queries: consultasucursal* (6 SPs in D01)
    ('D01', '5.4.1', 'secondary'),   # accounting entries: asiento*, cont_* (bdicnweb batch)
    # Round 9: D04 — cierre/precierre posiciones diarias
    ('D04', '5.4.8', 'secondary'),   # bdicuen: cierre, precierre — daily balance positions
    # Round 9: D05 — elegibilidad de productos de seguro/convenio
    ('D05', '3.1.4', 'secondary'),   # bdisac product eligibility: cardif*, convenio* (5 SPs)
    # Round 9: D16 — bitácora y acceso de administración
    ('D16', '5.10.4', 'secondary'),  # intercard audit/monitoring: bitacora* (8), genconadmin* (4)
    ('D16', '7.1.4', 'secondary'),   # intercard access: genconadmin* (4), conaut* (3)
    # Round 10: D01 — origination/disbursement (biz 'originacion'=46, 'ministr')
    ('D01', '3.3.1', 'secondary'),   # bdicnweb credit structuring/approval: solicitud*, aprobac*
    ('D01', '3.3.2', 'secondary'),   # bdicnweb disbursement: ministr*, apertura*, origina*
    # Round 10: D02 — bitacora, mobile, cleanup
    ('D02', '5.10.4', 'secondary'),  # bdinteg audit log: bitacora* (9 SPs in name)
    ('D02', '1.1.2', 'secondary'),   # bdinteg mobile channel: movil* (6 SPs in name)
    ('D02', '3.17.11', 'secondary'), # bdinteg reconciliation cleanup: depura* (5 SPs in name)
    # Round 10: D08 SPEI — deposit/abono ops
    ('D08', '3.2.4', 'secondary'),   # bdispei deposit: sp_abono_cta, sp_abonoordauto, sp_canc_abono
    # Round 10: D10 sucursales — customer document/expediente SPs
    ('D10', '7.1.1', 'secondary'),   # bdisuc customer data: expediente*, docto*, nombrecliente*
    # Round 11: D03 — tasas de interés en base de crédito
    ('D03', '3.15.2', 'secondary'),  # bdicred: tasas de crédito, cálculos de interés (5 SPs con 'tasas')
    # Round 12: D07 + D03 — audit log (bitácora SIEM en aclaraciones, bitácora de crédito)
    ('D07', '5.10.4', 'secondary'),  # bdiaclaracion: sp_bitacora_siem, sp_bitacorasistema
    ('D03', '5.10.4', 'secondary'),  # bdicred: bitácora de operaciones de crédito (5 SPs)
    # Round 13: D05 bdisac — comisiones y bitácora en SAC
    ('D05', '3.15.2', 'secondary'),  # bdisac: sp_calcula_comisiones* (2 SPs — cálculo de comisiones SAC)
    ('D05', '5.10.4', 'secondary'),  # bdisac: sp_bitacora_proceso, sp_bitacoragdf (audit log SAC)
    # Round 13: D01 bdicnweb — consultas de buró de crédito en canal web
    ('D01', '5.9.2', 'secondary'),   # bdicnweb: sp_bccc_* (3) + sp_consultainforeportebc* (5) — Buró de Crédito
    # Round 13: D11 bdicobranza — limpieza de datos de cobranza
    ('D11', '3.17.11', 'secondary'), # bdicobranza: sp_depura_directorio_cte, sp_depura_telefonos (2 SPs)
    # Round 15: D44 payroll/HR reconciliation — NUEVA cobertura (era 0%)
    ('D44', '3.17.10', 'primary'),   # faltantes de caja: sp_*faltantes* matchea 'faltante' keyword
    ('D44', '5.4.1', 'secondary'),   # contabilidad nómina: quebranto, sueldo, poliza keywords
    ('D44', '3.17.11', 'secondary'), # conciliación quincena: concil* matchea 'concil' keyword
    # Round 15: D32 Visa/MC reporting — NUEVA cobertura (era 0%)
    ('D32', '3.5.1', 'primary'),     # card ops: creditoclasico, visaelectron, mc cal, transmc keywords
    ('D32', '3.17.8', 'secondary'),  # reporting: volumetria, replicainformacion, generareporte keywords
    # Round 15: D04 bdicuen — nuevas capacidades
    ('D04', '7.1.3', 'secondary'),   # contacto cliente: medalia NPS + datos contacto SPs
    ('D04', '3.17.10', 'secondary'), # caja cobranza: sp_*cobranza* caja (cobranza != 3.3.6 en D04)
    # Round 15: D05 bdisac — caja cobranza SAC
    ('D05', '3.17.10', 'secondary'), # SAC cobranza: sp_saccobranza* (4 SPs — cobro en ventanilla SAC)
    # Round 15: D06 bdisolicitudes — supervisión compliance
    ('D06', '5.10.4', 'secondary'),  # supervisión: sp_supervisionbc* (supervision keyword ya existe)
    # Round 15: D03 bdicred — impuesto ISR en productos de crédito
    ('D03', '5.4.5', 'secondary'),   # ISR: sp_*ifsr* (isr keyword ya existe en 5.4.5)
    # Round 15: D03 bdicred — cartera morosa (separado de D11 principal)
    ('D03', '3.3.6', 'secondary'),   # morosa: spsd_morosos* (moroso keyword nuevo en 3.3.6)
    # Round 15: D01 bdicnweb — supervisión/compliance reporting
    ('D01', '5.10.4', 'secondary'),  # actamec: sp_generaportadactamec* (5 SPs — reporte cuentas inactivas)
    # Round 16: D01 bdicnweb — módulo de crédito (sp_cred_* prefix ~18 SPs)
    ('D01', '3.3.4', 'secondary'),   # credit servicing: sp_cred_consultaproductos, sp_cred_elimina_tmp...
    # Round 16: D16 intercard — eventos de notificación (sp_registra_evento* — 3 SPs)
    ('D16', '7.3.3', 'secondary'),   # notification: sp_registra_evento, _pba1, _pba2, _pba3
    # Round 22: D03 bdicred — bloqueo/desbloqueo de cuenta (7.1.4 keywords ya existen: 'bloqueo','desbloqueo')
    ('D03', '7.1.4', 'secondary'),   # sp_bloqueocuenta (fi=90), sp_desbloqueocuenta (fi=40)
    # Round 22: nuevos dominios D23-D49 — cobertura inicial para SPs sin biz
    # NOTE: FK en domain_capabilities no se aplica (SQLite FK OFF by default) — INSERT OR IGNORE safe
    ('D23', '3.17.8', 'secondary'),  # bdimis: MIS sucursales — reporting KPI (gen_rep, indicador, volumetria)
    ('D26', '7.1.1', 'primary'),     # bdiprospectos: prospectos/captación — alta_clien, prospecto, onboard
    ('D36', '5.10.6', 'primary'),    # bdireporteas: reportería regulatoria CNBV — resultadosat, eoetarjeta, ftc_
    ('D37', '3.2.4', 'primary'),     # bdiadminnomina: nómina — operaciones de cuenta (nomina, abona, aplica)
    ('D40', '1.1.1', 'primary'),     # bdibi: banca por internet / portal BPI — internet, bpi, web, portal
    ('D45', '3.1.4', 'primary'),     # bdiprem: premios/promociones — promo, sorteo, boleto, oferta
    ('D46', '3.17.10', 'primary'),   # bdiofi: oficinas cobro / cajeros distribuidores — caja, cajero, cobranza
    ('D47', '5.9.1', 'primary'),     # bdigaran: garantías y colaterales — motor, politicacred, parametro_riesgo
    # Round 23: D32/D34/D35/D44/D48/D49 — dominios restantes de D17-D49 sin cobertura sp_capabilities
    ('D32', '3.17.8', 'secondary'),  # bdireports: reportes Visa/MC — balance & transaction reporting (esquemas tarjeta)
    ('D34', '5.10.4', 'secondary'),  # bdiresp: respaldos DBA — compliance monitoring (backup = continuidad regulatoria)
    ('D35', '1.1.1', 'secondary'),   # bdidigital: digitalización — internet banking (habilita canal digital)
    ('D44', '3.17.11', 'primary'),   # bdirech: conciliación operativa — reconciliation services (match exacto)
    ('D48', '5.9.2', 'primary'),     # bdiriesgos: riesgos de crédito — risk assessment (match exacto)
    ('D49', '1.2.2', 'primary'),     # bdirst: retiro sin tarjeta — ATM, POS and Kiosk (cardless ATM withdrawal)
    # Round 26: D02 bdinteg — forex/divisas operations (valor_divisa_pesos fi=53 + consulta_divisas_bym fi=0×2)
    ('D02', '5.4.8', 'secondary'),   # foreign exchange: valor_divisa_pesos, consulta_divisas_bym* — 'divisa' keyword
]
# NOTE: D01→3.17.11 NOT added — would activate 'cheq' keyword for all D01 cheque* SPs,
# conflicting with 3.17.8 in D01 and causing regressions in domains with both caps

# Capabilities que corresponden a SPs transversales dentro de cada dominio
# (pago core, saldo, cargo, abono — presentes en casi todos los dominios de cuentas/pagos)
CROSS_CAPS = {'3.4.3', '3.2.4'}

# SPs que se marcan como cross-domain por rol → no asignar primary_l3
CROSS_ROLES = frozenset({'cross_domain_primitive', 'shared_service'})


def tokenize(text: str) -> str:
    """Normaliza texto: minúsculas, sin acentos, sustituye _ por espacio."""
    text = (text or '').lower()
    # strip diacríticos (é→e, á→a, ó→o, ú→u, ñ→n, etc.)
    text = ''.join(
        c for c in unicodedata.normalize('NFKD', text)
        if unicodedata.category(c) != 'Mn'
    )
    text = text.replace('_', ' ').replace('-', ' ')
    text = re.sub(r'\bsp\b', '', text)
    return text


def score_sp(name: str, biz: str, keywords: list[str]) -> float:
    """Suma ponderada: 2 si keyword en name, 1 si en biz."""
    if not keywords:
        return 0.0
    name_t = tokenize(name)
    biz_t  = tokenize(biz)
    s = 0.0
    for kw in keywords:
        kw_n = tokenize(kw)
        if kw_n in name_t:
            s += 5.0   # R14: 4.0→5.0 — tolera hasta 9 biz-matches antes de diluir bajo 0.35 (fix D01/D02 dilución)
        elif kw_n in biz_t:
            s += 1.0
    return s


def main():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    cur  = conn.cursor()

    # ── Añadir entradas faltantes a domain_capabilities ───────────────────
    for dom_id, l3_id, mtype in DOMAIN_CAPS_ADD:
        cur.execute(
            "INSERT OR IGNORE INTO domain_capabilities (domain_id, l3_id, mapping_type) "
            "VALUES (?, ?, ?)",
            (dom_id, l3_id, mtype)
        )
    added = sum(
        1 for d, l, _ in DOMAIN_CAPS_ADD
        if cur.execute("SELECT 1 FROM domain_capabilities WHERE domain_id=? AND l3_id=?",
                       (d, l)).fetchone()
    )
    print(f"domain_capabilities: {len(DOMAIN_CAPS_ADD)} entradas verificadas ({added} activas)")

    # ── Añadir columnas a sps si no existen ────────────────────────────────
    existing_cols = {r[1] for r in cur.execute("PRAGMA table_info(sps)").fetchall()}
    for col, typ in [('primary_l3','TEXT'), ('primary_l3_confidence','REAL')]:
        if col not in existing_cols:
            cur.execute(f"ALTER TABLE sps ADD COLUMN {col} {typ}")
            print(f"  + sps.{col} añadida")

    # ── Añadir etb_l3.sp_fine_n si no existe ───────────────────────────────
    l3_cols = {r[1] for r in cur.execute("PRAGMA table_info(etb_l3)").fetchall()}
    if 'sp_fine_n' not in l3_cols:
        cur.execute("ALTER TABLE etb_l3 ADD COLUMN sp_fine_n INTEGER DEFAULT 0")
        print("  + etb_l3.sp_fine_n añadida")

    # ── Cargar capacidades por dominio ─────────────────────────────────────
    domain_caps: dict[str, list[str]] = defaultdict(list)
    for row in cur.execute("SELECT domain_id, l3_id FROM domain_capabilities").fetchall():
        domain_caps[row['domain_id']].append(row['l3_id'])

    # ── Procesar todos los SPs con dominio D01-D16 ─────────────────────────
    sps = cur.execute("""
        SELECT id, name, biz, sp_role, domain
        FROM sps WHERE domain IS NOT NULL AND domain != ''
    """).fetchall()

    fine_n     = 0
    cross_n    = 0
    ambig_n    = 0
    no_domain_n= 0

    l3_fine_count: dict[str, int] = defaultdict(int)
    updates = []

    for sp in sps:
        sp_id   = sp['id']
        name    = sp['name'] or ''
        biz     = sp['biz']  or ''
        role    = sp['sp_role'] or ''
        domain  = sp['domain']

        # Cross-domain primitives / shared services → no primary assignment
        if role in CROSS_ROLES:
            updates.append((None, None, sp_id))
            cross_n += 1
            continue

        candidates = domain_caps.get(domain, [])
        if not candidates:
            updates.append((None, None, sp_id))
            no_domain_n += 1
            continue

        if len(candidates) == 1:
            # Solo una capacidad en el dominio → asignación directa con confianza alta
            l3_id = candidates[0]
            updates.append((l3_id, 1.0, sp_id))
            l3_fine_count[l3_id] += 1
            fine_n += 1
            continue

        # Puntuar contra cada capacidad candidata
        scores: list[tuple[float, str]] = []
        for l3_id in candidates:
            kws = KEYWORDS.get(l3_id, [])
            s   = score_sp(name, biz, kws)
            scores.append((s, l3_id))

        scores.sort(reverse=True)
        best_score, best_l3 = scores[0]
        second_score = scores[1][0] if len(scores) > 1 else 0.0

        if best_score == 0.0:
            # Sin señal → ambiguo, sin primary
            updates.append((None, None, sp_id))
            ambig_n += 1
            continue

        # Confianza = fracción del score del ganador sobre la suma total
        total = sum(s for s, _ in scores)
        confidence = best_score / total if total > 0 else 0.0

        # Umbral mínimo de confianza para asignar primary
        if confidence < 0.35:
            updates.append((None, None, sp_id))
            ambig_n += 1
            continue

        updates.append((best_l3, round(confidence, 4), sp_id))
        l3_fine_count[best_l3] += 1
        fine_n += 1

    # ── Aplicar updates ────────────────────────────────────────────────────
    cur.executemany(
        "UPDATE sps SET primary_l3=?, primary_l3_confidence=? WHERE id=?",
        updates
    )

    # ── Actualizar etb_l3.sp_fine_n ───────────────────────────────────────
    cur.execute("UPDATE etb_l3 SET sp_fine_n=0")
    for l3_id, n in l3_fine_count.items():
        cur.execute("UPDATE etb_l3 SET sp_fine_n=? WHERE id=?", (n, l3_id))

    conn.commit()
    print(f"\n=== Resultados ===")
    print(f"  Fine-grained asignados  : {fine_n:>6,}  ({fine_n/len(sps)*100:.1f}%)")
    print(f"  Cross/shared (sin asig) : {cross_n:>6,}  ({cross_n/len(sps)*100:.1f}%)")
    print(f"  Ambiguos (sin asig)     : {ambig_n:>6,}  ({ambig_n/len(sps)*100:.1f}%)")

    # ── Distribución por L3 ───────────────────────────────────────────────
    print(f"\n  Top 20 capacidades por SPs fine asignados:")
    top = sorted(l3_fine_count.items(), key=lambda x: -x[1])[:20]
    for l3_id, n in top:
        meta = cur.execute("SELECT name FROM etb_l3 WHERE id=?", (l3_id,)).fetchone()
        name_str = meta['name'] if meta else '?'
        print(f"    {l3_id:<10} {name_str:<45} {n:>5} SPs")

    # ── Actualizar JSON ───────────────────────────────────────────────────
    print(f"\nActualizando {OUT_JSON}...")
    try:
        with open(OUT_JSON, encoding='utf-8') as f:
            cap_map = json.load(f)

        for l3_id, n in l3_fine_count.items():
            if l3_id in cap_map.get('capabilities', {}):
                cap_map['capabilities'][l3_id]['sp_fine_n'] = n

        # También poblar key_sps_fine: top 10 SPs con primary_l3 = este L3
        for l3_id in cap_map.get('capabilities', {}):
            fine_sps = cur.execute("""
                SELECT id, name, biz, sp_role, is_soul, fan_in, fan_out, prod_calls_day
                FROM sps WHERE primary_l3=?
                ORDER BY
                  CASE sp_role
                    WHEN 'esb_exposed' THEN 0 WHEN 'entry_point' THEN 1
                    WHEN 'batch_orchestrator' THEN 2
                    WHEN 'super_orchestrator' THEN 3 WHEN 'orchestrator' THEN 4
                    ELSE 5 END,
                  is_soul DESC,
                  COALESCE(prod_calls_day, 0) DESC, fan_in DESC
                LIMIT 10
            """, (l3_id,)).fetchall()
            cap_map['capabilities'][l3_id]['key_sps_fine'] = [
                {'id': r['id'], 'name': r['name'], 'biz': r['biz'] or '',
                 'role': r['sp_role'] or '', 'is_soul': bool(r['is_soul']),
                 'fan_in': r['fan_in'] or 0,
                 'prod_calls': r['prod_calls_day']} for r in fine_sps
            ]

        # Actualizar domain_l3_map con sp_fine_n
        for domain, caps in cap_map.get('domain_l3_map', {}).items():
            for cap in caps:
                l3_id = cap['l3_id']
                cap['sp_fine_n'] = l3_fine_count.get(l3_id, 0)

        with open(OUT_JSON, 'w', encoding='utf-8') as f:
            json.dump(cap_map, f, ensure_ascii=False, indent=2)
        print(f"JSON actualizado.")
    except Exception as e:
        print(f"  WARN: no se pudo actualizar JSON: {e}")

    conn.close()


if __name__ == '__main__':
    main()
