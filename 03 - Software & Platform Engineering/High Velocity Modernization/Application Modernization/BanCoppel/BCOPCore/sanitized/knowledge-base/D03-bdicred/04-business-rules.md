# D03 · Créditos — Reglas de Negocio y Fórmulas

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)
- **SME Regulatorio — SAT** (`Solutioning/Delivery - SME/Regulatory/SAT/`)
- **SME Regulatorio — CONDUSEF** (`Solutioning/Delivery - SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen

**166 fórmulas** + **184 validaciones** extraídas del código de `bdicred`. Reguladores con reglas: CNBV, CONDUSEF, SAT.

## Fórmulas de negocio (evidencia directa del código)

| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-IFX-619 | `calc_intdia` L168 | CNBV | `ax_intdia = ((v_capital * v_tasa) / v_diasano) * ax_diascalc ` | |
| BR-IFX-620 | `calc_intdialiq` L125 | CNBV | `ax_intdia = ((v_capital * v_tasa) / v_diasano) * ax_diascalc ` | |
| BR-IFX-621 | `calc_iva_grav` L100 | operacional | `vIntGrav = vIvaIntGrav/vIvaSuc` | |
| BR-IFX-622 | `calc_iva_grav` L177 | CNBV | `vTasaIva = ((o_tasa / 100) / o_diascalc) * o_diasacum ` | |
| BR-IFX-623 | `calc_iva_grav` L179 | CNBV | `vIvaReal = (vTasaIntReal * vIvaSuc)/ vTasaIva; --se cambia el 0.16 por` | |
| BR-IFX-624 | `calc_iva_grav` L180 | operacional | `vIvaIntGrav = ROUND(o_monto * vIvaReal,2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-625 | `calc_iva_grav` L183 | CNBV | `vTasaIva = (o_tasa / 100) - (o_precioreal * 12)` | |
| BR-IFX-626 | `calc_iva_grav` L184 | CNBV | `vTasaReal = vTasaIva / (o_tasa / 100)` | |
| BR-IFX-627 | `calc_iva_grav` L185 | CNBV | `vIntGrav = o_intperiodo * vTasaReal` | |
| BR-IFX-628 | `calc_iva_grav` L189 | operacional | `vIvaIntGrav = o_intperiodo * vIvaSuc; --se cambia el 0.16 por la varia` | |
| BR-IFX-632 | `calc_iva_grav_cierre` L66 | CNBV | `vTasaIva = (o_tasa / 100) - (o_precioreal * 12)` | |
| BR-IFX-633 | `calc_iva_grav_cierre` L67 | CNBV | `vTasaIva = (vTasaIva / (o_tasa / 100)) * vIvaSuc ` | |
| BR-IFX-634 | `calc_iva_grav_cierre` L68 | CNBV | `vIvaIntGrav = (o_intperiodo) * vTasaIva` | |
| BR-IFX-635 | `calc_iva_grav_cierre` L69 | operacional | `vIvaReal = (o_intperiodo) * vIvaSuc` | |
| BR-IFX-636 | `calc_iva_grav_cierre` L72 | CNBV | `vTasaReal = vTasaIva / (o_tasa / 100)` | |
| BR-IFX-637 | `calc_iva_grav_cierre` L73 | CNBV | `vIntGrav = o_intperiodo * vTasaReal` | |
| BR-IFX-638 | `calc_iva_grav_cierre` L76 | operacional | `vIvaIntGrav = o_intperiodo * vIvaSuc` | |
| BR-IFX-642 | `calc_iva_grav_pp` L80 | CNBV | `l_dFactor1 = NVL(p_dTasaInt,0)/(l_diascalc *100)* l_iDias` | |
| BR-IFX-643 | `calc_iva_grav_pp` L100 | CNBV | `l_dFactorIntReal = (l_dTasaReal * p_dIvaSuc)/l_dFactor1` | |
| BR-IFX-644 | `calc_iva_grav_pp` L103 | operacional | `l_dIvaIntReal = round(l_dFactorIntReal * p_dIntNorm,2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-648 | `calc_iva_grav_pp_09062013` L80 | CNBV | `l_dFactor1 = NVL(p_dTasaInt,0)/(l_diascalc *100)* l_iDias` | |
| BR-IFX-649 | `calc_iva_grav_pp_09062013` L97 | CNBV | `l_dFactorIntReal = (l_dTasaReal * p_dIvaSuc)/l_dFactor1` | |
| BR-IFX-650 | `calc_iva_grav_pp_09062013` L99 | operacional | `l_dIvaIntReal = round(l_dFactorIntReal * p_dIntNorm,2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-654 | `calcula_meses_fin` L87 | operacional | `MontoFinanciado = ROUND((o_saldo_no_exigible * vFactorPorcentual), -0)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-655 | `calcula_meses_fin` L90 | operacional | `MontoFinanciado = ROUND((o_monto_otorgado * vFactorPagoMinLinC),-0)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-656 | `calcula_meses_fin` L126 | CNBV | `wfinincimainto = ((o_saldo_no_exigible * o_tasa / 360 * wdias) * (1 + ` | ⚠ base 360 (año comercial) — verificar vs 365 |
| BR-IFX-657 | `calcula_meses_fin_pagomin_base` L91 | operacional | `MontoFinanciado = MontoFinanciado * o_factor` | |
| BR-IFX-658 | `calcula_meses_fin_pagomin_base` L137 | CNBV | `wfinincimainto = ((o_saldo_no_exigible * o_tasa / 360 * wdias) * (1 + ` | ⚠ base 360 (año comercial) — verificar vs 365 |
| BR-IFX-659 | `calcula_meses_fin_pagomin_base` L140 | CNBV | `interes_iva = interes_iva + (o_saldo_no_exigible * o_tasa / 360 * wdia` | ⚠ base 360 (año comercial) — verificar vs 365 |
| BR-IFX-672 | `cobramoratorioscrd` L91 | operacional | `vIvaPag = (vSdoMoraOrdi + vSdoMoraCope) * vIvaSuc` | |
| BR-IFX-673 | `cobramoratorioscrd` L96 | operacional | `vIntVenc = g_Remanente / (1 + vIvaSuc)` | |
| BR-IFX-676 | `interes` L217 | CNBV | `PFECHA_CUOTA = PFECHA_CUOTA + (15 * FACTOR)` | |
| BR-IFX-677 | `interes` L228 | CNBV | `PFECHA_CUOTA = PFECHA_CUOTA + (V_DIAS * FACTOR)` | |
| BR-IFX-678 | `interes` L308 | CNBV | `V_DIAS = ABS(V_DIAS) * -1` | |
| BR-IFX-680 | `pasecont_cobra_comision_apertura` L391 | CONDUSEF | `wmonto = wmonto * valor_cambio` | |
| BR-IFX-681 | `revisa_tasa` L117 | CNBV | `v_tasa_mor = v_tasa_int * g_factor_moratorio` | |
| BR-IFX-682 | `revisa_tasa` L133 | CNBV | `v_tasa_mor = v_tasa_int / g_sobretasa_mora` | |
| BR-IFX-686 | `sp_actualiza_reserva_cierre` L619 | operacional | `dEICal = (dPorSaldoMin * dLimiteCredito) * dMax` | |
| BR-IFX-687 | `sp_actualiza_reserva_cierre` L659 | CNBV | `vImporteReservaBuroCC = vReservaGradual * 0.15` | |
| BR-IFX-688 | `sp_actualiza_reserva_cierre` L688 | CNBV | `vtotal_capitalizado = (1 - (vReservaGradual / dEndeudamientoTotCierre)` | |
| BR-IFX-692 | `sp_actualiza_reserva_corte` L439 | operacional | `dEndeudamientoTotCalc = dLimiteCredito * dPorSaldoMin` | |
| BR-IFX-696 | `sp_cac_calculalinsugcte` L265 | CNBV | `dTIP = ((dTasa_Interes) + (dTasa_Interes * dIvaSuc))/100` | |
| BR-IFX-697 | `sp_cac_calculalinsugcte` L295 | operacional | `dCRA = (pIngresoMens * dTopeAbono)` | |
| BR-IFX-698 | `sp_cac_calculalinsugcte` L307 | operacional | `dLineaMinima = dMontoOtor + (dMontoOtor * dPorcTopeValMin)` | |
| BR-IFX-699 | `sp_cac_calculalinsugcte` L308 | operacional | `dLineaMaxima_cci = dMontoOtor + (dMontoOtor * dPorcTopeValMax_cci)` | |
| BR-IFX-700 | `sp_cac_calculalinsugcte` L309 | operacional | `dLineaMaxima_sci = dMontoOtor + (dMontoOtor * dPorcTopeValMax_sci)` | |
| BR-IFX-701 | `sp_cac_calculalinsugcte` L337 | operacional | `dRazonIncremento = (dLineaSugerida / dMontoOtor) - 1` | |
| BR-IFX-722 | `sp_calcularaumlincred` L319 | operacional | `dLineaSugerida = round(dMontoOtor + (dMontoOtor * dAum2),-2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-734 | `sp_calculasaldopromediodiario` L69 | operacional | `dDeterminaQueMontoPoner = (CAST(pAbonos AS DECIMAL(14,2))* -1)` | |
| BR-IFX-736 | `sp_calculasaldosobreinteres` L163 | CNBV | `dInteresDiario = cSaldoSobreCalculoInteres::DECIMAL *((pTasaAnualPie::` | ⚠ base 360 (año comercial) — verificar vs 365 |
| BR-IFX-738 | `sp_calculo_beneficio_monedero_pl` L406 | operacional | `vDineroEOriginal = vMontoDiarioOriginal * vPorcentaje` | |
| BR-IFX-740 | `sp_calculo_beneficio_monedero_pl_2` L315 | operacional | `vDineroEOriginal = vMontoDiarioOriginal * vPorcentaje` | |
| BR-IFX-742 | `sp_calculo_cat_publicidad` L126 | CNBV | `vIntereses = ROUND ((((vSaldo * cTasa ) / 360)*30)/100, 6)` | ⚠ base 360 (año comercial) — verificar vs 365; ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-743 | `sp_calculo_cat_publicidad` L135 | operacional | `vPago = ROUND ((vSaldos * vPmin)/100, 6)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-744 | `sp_calculo_cat_publicidad` L157 | operacional | `npv = (SELECT SUM(flujo_neto / POWER(1 + tir, mes)) FROM sd_calc_cat_c` | |
| BR-IFX-745 | `sp_calculo_cat_publicidad` L161 | operacional | `tir = tir - npv / (SELECT SUM(-mes * flujo_neto / POWER(1 + tir, mes +` | |
| BR-IFX-751 | `sp_calculo_reserva_cierre` L596 | operacional | `dEndeudamientoTotCalc = dLimiteCredito * dPorSaldoMin` | |
| BR-IFX-752 | `sp_calculo_reserva_cierre` L652 | operacional | `dEI = (dPorSaldoMin * dLimiteCredito) * dMax` | |
| BR-IFX-753 | `sp_calculo_reserva_cierre` L949 | CNBV | `vImporteReservaBuroCC = dResCalificacion * 0.15` | |
| BR-IFX-754 | `sp_calculo_reserva_cierre` L1046 | operacional | `vtotal_capitalizado = vtotal_capitalizado * (1 - (dPorcentajeReserva /` | |
| BR-IFX-758 | `sp_calculo_reserva_corte` L898 | operacional | `iANT = round((dtFechaUltMes - dtFechaApertura)/dDiasXMes,2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-759 | `sp_calculo_reserva_corte` L988 | CNBV | `vImporteReservaBuroCC = dResCalificacion * dPorResSic * dGradual` | |
| BR-IFX-763 | `sp_calculo_reserva_corte_cnr` L701 | CNBV | `dSdoCierre = dSaldoCapitalInsoluto + dInteresVencido + dInteresDevenga` | |
| BR-IFX-764 | `sp_calculo_reserva_corte_cnr` L808 | operacional | `dVeces = dMontoTotalPagar / dMontoOtorgado` | |
| BR-IFX-765 | `sp_calculo_reserva_corte_cnr` L915 | operacional | `dVeces = dSdoCierre / dMontoOtorgado` | |
| BR-IFX-766 | `sp_calculo_reserva_corte_cnr` L967 | operacional | `dPromPorcentajePago = (dPromPorcentajePago / dTotalMontoExigible) / sN` | |
| BR-IFX-767 | `sp_calculo_reserva_corte_cnr` L995 | operacional | `dMontoReserva = dPI * dSP * dEI` | |
| BR-IFX-768 | `sp_calculo_reserva_corte_cnr` L1112 | CNBV | `dImporteReservaBuroCC = NVL(dMontoReserva,0) * NVL(dPorResSic,0)` | |
| BR-IFX-772 | `sp_calculo_reserva_corte_cnr_mx` L692 | CNBV | `dSdoCierre = dSaldoCapitalInsoluto + dInteresVencido + dInteresDevenga` | |
| BR-IFX-773 | `sp_calculo_reserva_corte_cnr_mx` L797 | operacional | `dVeces = dMontoTotalPagar / dMontoOtorgado` | |
| BR-IFX-774 | `sp_calculo_reserva_corte_cnr_mx` L904 | operacional | `dVeces = dSdoCierre / dMontoOtorgado` | |
| BR-IFX-775 | `sp_calculo_reserva_corte_cnr_mx` L956 | operacional | `dPromPorcentajePago = (dPromPorcentajePago / dTotalMontoExigible) / sN` | |
| BR-IFX-776 | `sp_calculo_reserva_corte_cnr_mx` L984 | operacional | `dMontoReserva = dPI * dSP * dEI` | |
| BR-IFX-777 | `sp_calculo_reserva_corte_cnr_mx` L1098 | CNBV | `dImporteReservaBuroCC = NVL(dMontoReserva,0) * NVL(dPorResSic,0)` | |
| BR-IFX-781 | `sp_calculo_reserva_corte_crd` L636 | operacional | `dMoratorios = Round(dMoratorios * (1 + dIvaSuc),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-782 | `sp_calculo_reserva_corte_crd` L922 | CNBV | `dImporteReservaBuroCC = dResCalificacion * dPorResSic` | |
| BR-IFX-786 | `sp_calculo_reserva_corte_inc` L866 | operacional | `iANT = round((dtFechaUltMes - dtFechaApertura)/dDiasXMes,2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-787 | `sp_calculo_reserva_corte_inc` L956 | CNBV | `vImporteReservaBuroCC = dResCalificacion * dPorResSic * dGradual` | |
| BR-IFX-791 | `sp_calculo_reserva_corte_pba` L879 | operacional | `iANT = round((dtFechaUltMes - dtFechaApertura)/dDiasXMes,2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-792 | `sp_calculo_reserva_corte_pba` L969 | CNBV | `vImporteReservaBuroCC = dResCalificacion * dPorResSic * dGradual` | |
| BR-IFX-796 | `sp_calculo_reserva_corte_previo` L433 | operacional | `dMoratorios = Round(dMoratorios * (1 + v_iva_suc),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-797 | `sp_calculo_reserva_corte_previo` L511 | operacional | `vcuotasvenc = ((Year(dtFechaCorte) - Year(dfechaini)) * 12) + Month(dt` | |
| BR-IFX-798 | `sp_calculo_reserva_corte_previo` L575 | CNBV | `vImporteReservaBuroCC = dResCalificacion * dPorResSic * dGradual` | |
| BR-IFX-802 | `sp_calculo_tiir` L82 | CNBV | `tasa_mensual = ((tasa_prom_pond / 36000) * 30)` | |
| BR-IFX-803 | `sp_calculo_tiir` L131 | CNBV | `int_mensualAux = SaldoInicio * tasa_mensual` | |
| BR-IFX-804 | `sp_calculo_tiir` L133 | operacional | `pago_mensualAux = SaldoFin * (pago_mensual / 100)` | |
| BR-IFX-805 | `sp_calculo_tiir` L171 | operacional | `vCATx = (1 + (vCAT / 100))` | |
| BR-IFX-806 | `sp_calculo_tiir` L174 | operacional | `vCATz = pow(vCATx, (vCATy / 12))` | |
| BR-IFX-807 | `sp_calculo_tiir` L176 | operacional | `vDispCosto = disp_mensualAux / vCATz` | |
| BR-IFX-808 | `sp_calculo_tiir` L177 | operacional | `vPagoCosto = pago_mensualAux / vCATz` | |
| BR-IFX-809 | `sp_calculo_tiir` L192 | operacional | `vCAT = (vCATMax + vCAT) / 2` | |
| BR-IFX-810 | `sp_calculo_tiir` L195 | operacional | `vCAT = (vCATMin + vCAT) / 2` | |
| BR-IFX-811 | `sp_calculo_tiir` L219 | operacional | `vCatFinal = ((pow((1 + (vCAT/10)),12)) - 1) * 100` | |
| BR-IFX-813 | `sp_calculo_tiir_pp` L97 | CONDUSEF | `pago_mensualAux = (montoDisposicion * -1) + comision` | |
| BR-IFX-814 | `sp_calculo_tiir_pp` L102 | operacional | `vCATx = 1 + (vCAT/100)` | |
| BR-IFX-815 | `sp_calculo_tiir_pp` L106 | operacional | `vPagoCosto = pago_mensualAux / vCATz` | |
| BR-IFX-816 | `sp_calculo_tiir_pp` L117 | operacional | `vCAT = (vCATMax + vCAT) / 2` | |
| BR-IFX-817 | `sp_calculo_tiir_pp` L120 | operacional | `vCAT = (vCATMin + vCAT) / 2` | |
| BR-IFX-818 | `sp_calculo_tiir_pp` L146 | operacional | `vCatFinal = ( pow(1+ (vCAT/100),numeroPagosPeriodos) - 1 ) * 100` | |
| BR-IFX-821 | `sp_cobro_comision_x_anualidad` L403 | CONDUSEF | `iMnto_Cobr_ComTi = iMnto_AnTit_6001 / dCob_Parc_6001; -- Divide el mon` | |
| BR-IFX-822 | `sp_cobro_comision_x_anualidad` L1252 | CONDUSEF | `iMnto_Cobro = (dMontoTot - dMontoApli) / iAfecPend; --- Realiza el cob` | |
| BR-IFX-826 | `sp_comision_anual_devolucion` L299 | CONDUSEF | `sPorcentNoCob = (sDiasTotAnio - sDiasTransCob) / sDiasTotAnio` | |
| BR-IFX-827 | `sp_comision_anual_devolucion` L350 | CONDUSEF | `dMntoIvaDevol = dMntoIvaCobr * sPorcentNoCob` | |
| BR-IFX-828 | `sp_comisiones` L109 | CONDUSEF | `V_MONTO_COM = V_MONTO_OTORGADO * (V_APLI_FACTOR/100)` | |
| BR-IFX-829 | `sp_comisiones` L312 | CONDUSEF | `V_MONTO_TOTAL = V_MONTO_TOTAL + V_MONTO_POLIZA+(V_MONTO_MENSUAL*2)` | |
| BR-IFX-830 | `sp_comisiones` L323 | CONDUSEF | `SALDO = NVL(SALDO,0) + V_MONTO_POLIZA+(V_MONTO_MENSUAL*2)` | |
| BR-IFX-831 | `sp_comisionxapertura_contable` L132 | CONDUSEF | `mMonto2 = ROUND((mMonto / 12),2) ` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-832 | `sp_comisionxapertura_contable` L193 | CONDUSEF | `dMntoAplicar = ROUND((dMontoTot / 12),2) ` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-833 | `sp_comisionxapertura_contable_fin` L120 | CONDUSEF | `mMonto2 = ROUND((mMonto / 12),2) ` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-837 | `sp_consulta_saldos_general` L507 | CONDUSEF | `dComPend = dSdoActCap * dFactorComision` | |
| BR-IFX-838 | `sp_consulta_saldos_general` L509 | CONDUSEF | `dComPend = dLineaOtorgada * dFactorComision` | |
| BR-IFX-839 | `sp_consulta_saldos_general` L511 | operacional | `dIvaCom = dComPend * dIvaSuc` | |
| BR-IFX-868 | `sp_encabezado_calculo_tdc` L674 | CNBV | `v_tasa_mora = v_tasa_mora * -1` | |
| BR-IFX-869 | `sp_encabezado_calculo_tdc` L880 | operacional | `v_dias_periodo_tc = (v_dias_periodo_tc * -1) ` | |
| BR-IFX-870 | `sp_encabezado_calculo_tdc` L1026 | operacional | `v_iva_moratorios_tc = v_moratorios_tc * v_iva_suc` | |
| BR-IFX-871 | `sp_encabezado_calculo_tdc` L1051 | CNBV | `v_disponible_tc = ((v_interes_pago_total_tc * -1) + v_limite_tc) - v_s` | |
| BR-IFX-872 | `sp_encabezado_calculo_tdc` L1172 | operacional | `v_dif_num_pagos = v_dif_num_cuota::VARCHAR(3) // '/' // v_dif_plazo::V` | |
| BR-IFX-873 | `sp_encabezado_calculo_tdc` L1187 | CNBV | `v_tasa_mensual = v_tasa_anual / 12` | |
| BR-IFX-874 | `sp_encabezado_calculo_tdc` L1188 | CNBV | `v_tasa_mensual_mora = v_tasa_mora / 12` | |
| BR-IFX-875 | `sp_encabezado_calculo_tdc` L1191 | CNBV | `v_saldo_promedio = round((v_interes_tc*360)/(v_dias_periodo_tc * (v_ta` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-878 | `sp_genera_reporte_tc_inactivas` L249 | SAT · CNBV | `cSql = 'echo " Set Isolation to dirty read; Unload to ' // '/resplogif` | |
| BR-IFX-879 | `sp_genera_reporte_tc_inactivas` L257 | SAT · CNBV | `cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Archivo_TC_Inacti` | |
| BR-IFX-880 | `sp_genera_reporte_tc_inactivas` L271 | SAT · CNBV | `cSql = "sed 's//$//g' /resplogifx/archivoscartera/Archivo_TC_Inactivas` | |
| BR-IFX-881 | `sp_genera_reporte_tc_inactivas` L275 | SAT · CNBV | `cSql = 'rm /resplogifx/archivoscartera/Archivo_TC_Inactivas.sql'` | |
| BR-IFX-886 | `sp_genera_reporte_tc_inactivas` L381 | SAT · CNBV | `cSql = 'rm /resplogifx/archivoscartera/Archivo_Concentrado_TC_Inactiva` | |
| BR-IFX-889 | `sp_genera_reporte_tc_inactivas_pba` L235 | SAT · CNBV | `cSql = 'echo " Set Isolation to dirty read; Unload to ' // '/resplogif` | |
| BR-IFX-890 | `sp_genera_reporte_tc_inactivas_pba` L243 | SAT · CNBV | `cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Archivo_TC_Inacti` | |
| BR-IFX-891 | `sp_genera_reporte_tc_inactivas_pba` L257 | SAT · CNBV | `cSql = "sed 's//$//g' /resplogifx/archivoscartera/Archivo_TC_Inactivas` | |
| BR-IFX-892 | `sp_genera_reporte_tc_inactivas_pba` L261 | SAT · CNBV | `cSql = 'rm /resplogifx/archivoscartera/Archivo_TC_Inactivas.sql'` | |
| BR-IFX-897 | `sp_genera_reporte_tc_inactivas_pba` L392 | SAT · CNBV | `cSql = 'rm /resplogifx/archivoscartera/Archivo_Concentrado_TC_Inactiva` | |
| BR-IFX-900 | `sp_ics_cuotas` L328 | CNBV | `v_iva_interes_mora = (v_interes_mora * dIvaSuc)` | |
| BR-IFX-901 | `sp_ics_cuotas_crd` L337 | CNBV | `v_iva_interes_mora = (v_interes_mora * dIvaSuc)` | |
| BR-IFX-909 | `sp_obtenercomisionreposiciontarjeta` L147 | CONDUSEF | `cIvaComision = cMontoComision * vValIva` | |
| BR-IFX-930 | `sp_plan_pausa_obtiene_tasa_interes` L36 | CNBV | `d_variable_z = ( (p_monto_abono_6_meses - p_pago_minimo_6_meses) / p_p` | |
| BR-IFX-931 | `sp_provision_de_intereses` L85 | CNBV | `V_FUNCION = '606'; /* Cierre. Provisión de Intereses Ordinarios */` | |
| BR-IFX-932 | `sp_provision_de_intereses` L164 | CNBV | `V_INT_DIARIO = V_SDO_CAPITAL * ((V_TASA_INTERES/100)/V_DIAS_ANIO)` | |
| BR-IFX-933 | `sp_provision_de_intereses` L259 | CNBV | `V_INT_DIARIO = ((V_MONTO_CUOTA/V_DIAS_CUOTA) * V_DIAS_CALC)` | |
| BR-IFX-934 | `sp_provision_intereses` L77 | CNBV | `V_INTERES = V_INTERES * (P_FECHA_HOY - P_FECHA_BANCO) ` | |
| BR-IFX-935 | `sp_provision_intereses` L98 | CNBV | `V_MONTO = V_INTERES / V_NUMREG` | |
| BR-IFX-936 | `sp_provision_intereses` L175 | CNBV | `V_MONTO = P_MONTO * (VPORCENT_PART / 100)` | |
| BR-IFX-937 | `sp_provision_intereses` L176 | CNBV | `V_PARTICIP = V_MONTO * V_NUM_DIAS * (VTASA_FONDO / 100) / V_DIAS_ANUAL` | |
| BR-IFX-938 | `sp_provision_moratorios` L135 | CNBV | `V_INT2 = (V_SDO_CUOTA + V_INT_CUOTA) * (V_TASA_MORA/100)` | |
| BR-IFX-939 | `sp_rasura_moratorios_condonacion` L128 | operacional | `vMoraIvaDebe = vMoraIvaDebe * g_IvaCte` | |
| BR-IFX-943 | `sp_rasura_moratorios_quitas` L101 | operacional | `vMoraIvaDebe = vMoraIvaDebe * g_IvaCte` | |
| BR-IFX-947 | `sp_rep_ctasactivas_sin_plastico` L254 | CNBV | `cSQL2 = ' SELECT * FROM "informix".sd_ctasactivas_sinplastico'` | |
| BR-IFX-948 | `sp_rep_ctasactivas_sin_plastico_mx3` L258 | CNBV | `cSQL2 = ' SELECT * FROM "informix".sd_ctasactivas_sinplastico'` | |
| BR-IFX-949 | `sp_rep_ctasactivas_sin_plastico_pba` L280 | CNBV | `cSQL2 = ' SELECT * FROM "informix".sd_ctasactivas_sinplastico'` | |
| BR-IFX-952 | `sp_tasaefectiva` L130 | CNBV | `vporcen_tasa_men = ptasacontrac_an/12` | |
| BR-IFX-953 | `sp_tasaefectiva` L131 | CNBV | `vtasa_mensual = vporcen_tasa_men/100` | |
| BR-IFX-954 | `sp_tasaefectiva` L134 | CNBV | `vtir_anual = ptasacontrac_an/100` | |
| BR-IFX-955 | `sp_tasaefectiva` L142 | CNBV | `vpago_int_mensual = (pmonto*vtasa_mensual)` | |
| BR-IFX-956 | `sp_tasaefectiva` L146 | CNBV | `vpago_mensual = vpago_int_mensual/vtasa_pagointmens` | |
| BR-IFX-957 | `sp_tasaefectiva` L150 | CONDUSEF · CNBV | `vvalinicial = -1*(pmonto-pcomisap)` | |
| BR-IFX-958 | `sp_tasaefectiva` L158 | CNBV | `vtotal = vtotal+(vpago_mensual/(pow(1+vtasa_mensual,vcontper)))` | |

## Reglas por regulador (SME dueño)

- **CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`) — 128 reglas · Criterios contables CNBV + GAT — cálculo de intereses/rendimientos
- **CONDUSEF** (`Solutioning/Delivery - SME/Regulatory/CONDUSEF/`) — 36 reglas · LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada
- **SAT** (`Solutioning/Delivery - SME/Regulatory/SAT/`) — 21 reglas · LIVA — IVA sobre comisiones (16% / 8% frontera)

## `[RIESGO-EQUIVALENCIA]` en este dominio

Semántica Informix que debe preservarse exacta en el target (golden master ≥ 99.95%):
- **TRUNC vs ROUND** · **base 360 vs 365** · **tipo MONEY (banker's rounding)** — divergencia auditable.

## `[SME-PENDING]` Validación regulatoria

- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-lgc.md`).
- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.
- [ ] Definir golden master test por fórmula.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*