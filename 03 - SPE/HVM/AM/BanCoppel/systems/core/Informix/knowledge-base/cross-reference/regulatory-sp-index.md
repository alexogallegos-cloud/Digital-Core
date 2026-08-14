> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Cross-Reference KB · Generado: 2026-08-02

# Índice Regulatorio — SPs por Organismo

Índice completo de todos los procedimientos almacenados con anotación regulatoria, agrupados por organismo regulador. Estos SPs son candidatos obligatorios para el golden master de migración y requieren cobertura de pruebas de regresión regulatoria.

---

## Resumen por Regulador

| Regulador | # SPs | # Reglas reg. | Normas representativas |
|-----------|-------|---------------|------------------------|
| [CNBV](#cnbv) | 543 | 1697 | CUB CNBV — calificación cartera vencida y constitución de reservas |
| [CONDUSEF](#condusef) | 237 | 622 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| [IPAB](#ipab) | 89 | 195 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titula... |
| [SAT](#sat) | 88 | 191 | LIVA — IVA sobre comisiones (16% / 8% frontera) |
| [Banxico](#banxico) | 34 | 52 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-1... |
| [TESOFE](#tesofe) | 16 | 22 | LTF — dispersión de recursos federales (pensiones, becas, apoyos) |

---

## CNBV

**543 SPs** con un total de **1697 reglas** con anotación CNBV.

| SP | DB | Dominio | # Reglas reg. | Normas relevantes | Explicación |
|----|----|---------|--------------|--------------------|-------------|
| `sp_mueve_aclaraciones_historico` | bdiaclaracion | D07 Aclar. | 72 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Fórmula: aclaraciones (proceso de disputas/reclamaciones de cliente) ·... |
| `sp_envio_camp_ctes_ctaspzo` | bdicobranza | D11 Cobr. | 38 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_envio_camp_ctes_ctasrev` | bdicobranza | D11 Cobr. | 36 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `generaestadosdecuenta` | bdicred | D03 Créditos | 17 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `proyecta_pba` | bdicred | D03 Créditos | 17 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_proyecta_creditos_web` | bdicred | D03 Créditos | 17 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_genera_cintas_semanales` | bdiburo | bdiburo | 16 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `sp_genera_cintas_semanales_clon` | bdiburo | bdiburo | 16 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `sp_genera_cintas_semanales_cnr` | bdiburo | bdiburo | 16 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `sp_burofisicas_cortos_cnr` | bdiburo | bdiburo | 12 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `provisionlineacred_parte` | bdicred | D03 Créditos | 12 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `gencartconsumo` | bdicred | D03 Créditos | 11 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `generaestadosdecuenta_repro` | bdicred | D03 Créditos | 11 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `proyecta` | bdicred | D03 Créditos | 11 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `proyecta_web` | bdicred | D03 Créditos | 11 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtiene_amortizacion` | bdicred | D03 Créditos | 11 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_proyecta_prestamos` | bdicred | D03 Créditos | 11 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_tasaefectiva` | bdicred | D03 Créditos | 11 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_burofisicas_cortos` | bdiburo | bdiburo | 10 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `sp_actualiza_reserva_cierre` | bdicred | D03 Créditos | 10 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | CUB B-5 |
| `sp_calculo_reserva_cierre` | bdicred | D03 Créditos | 10 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `sp_calculo_reserva_corte_cnr` | bdicred | D03 Créditos | 10 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_calculo_reserva_corte_cnr_mx` | bdicred | D03 Créditos | 10 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cierre_tarjeta` | bdicred | D03 Créditos | 10 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_genera_reporte_tc_inactivas` | bdicred | D03 Créditos | 10 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | LIVA |
| `sp_genera_reporte_tc_inactivas_pba` | bdicred | D03 Créditos | 10 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | LIVA |
| `sp_obtiene_aproximacion_creditos` | bdicred | D03 Créditos | 10 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtiene_aproximacion` | bdisolic | D06 Solic. | 10 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_burofisicas_cortos_clon` | bdiburo | bdiburo | 9 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `sp_burofisicas_cortos_nov19` | bdiburo | bdiburo | 9 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `sp_burofisicas_cortos_pbajj` | bdiburo | bdiburo | 9 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `gencartconsumo_p` | bdicred | D03 Créditos | 9 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `gencartconsumo_reproc` | bdicred | D03 Créditos | 9 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `provisionlineacred_parte_inc` | bdicred | D03 Créditos | 9 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `provisionlineacred_parte_mx` | bdicred | D03 Créditos | 9 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `provisionlineacred_parte_pba` | bdicred | D03 Créditos | 9 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_generasdosvdos` | bdicred | D03 Créditos | 9 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_geninsumos_calif_parte` | bdicred | D03 Créditos | 9 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `apercred1_pp_domicilia_web` | bdicred | D03 Créditos | 8 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `apercred1_pp_web` | bdicred | D03 Créditos | 8 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `apercred1_tc` | bdicred | D03 Créditos | 8 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `apercred1_tc_upgrade` | bdicred | D03 Créditos | 8 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cierre_diario_pp_parte_mib` | bdicred | D03 Créditos | 8 | CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | CUB Anexo 36 |
| `sp_geninsumos_calif_oyp` | bdicred | D03 Créditos | 8 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `determina_lincred_tc_cjunk` | bdisolic | D06 Solic. | 8 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 10 |
| `conisr_anual_cta` | bdicheq | D04 Cheques | 7 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_nominaconsultasaldoeje` | bdicheq | D04 Cheques | 7 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_traspasoctabeneficencia` | bdicnweb | D01 Canal | 7 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Art.61 LIC |
| `calporcentaje_condonacionquitas` | bdicred | D03 Créditos | 7 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `generaedosctacrd_pp` | bdicred | D03 Créditos | 7 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | CFDI/Retenciones bancarias |
| `sp_apercred1_credisol` | bdicred | D03 Créditos | 7 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_apertura_credito` | bdicred | D03 Créditos | 7 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_apertura_credito_aut` | bdicred | D03 Créditos | 7 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_apertura_credito_restructura_prestamo` | bdicred | D03 Créditos | 7 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_apertura_credito_restructura_prestamo_web` | bdicred | D03 Créditos | 7 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_apertura_credito_web` | bdicred | D03 Créditos | 7 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_ics_genera_layouts_hilos` | bdicred | D03 Créditos | 7 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_msi_apercred1_msi` | bdicred | D03 Créditos | 7 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `burofisicas_concilia` | bdiburo | bdiburo | 6 | LRSIC — Buró de Crédito; evaluación crediticia | Fórmula: saldo |
| `burofisicas_concilia_clon` | bdiburo | bdiburo | 6 | LRSIC — Buró de Crédito; evaluación crediticia | Fórmula: saldo |
| `burofisicas_concilia_cnr` | bdiburo | bdiburo | 6 | LRSIC — Buró de Crédito; evaluación crediticia | Fórmula: saldo |
| `calcula_int` | bdicheq | D04 Cheques | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calcula_int_pba` | bdicheq | D04 Cheques | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calcula_intqra` | bdicheq | D04 Cheques | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `apercred1_tcpba` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `generaestadosdecuenta_detalle` | bdicred | D03 Créditos | 6 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `interes` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_calculo_reserva_corte` | bdicred | D03 Créditos | 6 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `sp_calculo_reserva_corte_inc` | bdicred | D03 Créditos | 6 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `sp_calculo_reserva_corte_pba` | bdicred | D03 Créditos | 6 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `sp_calculo_reserva_corte_previo` | bdicred | D03 Créditos | 6 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `sp_cierre_diario_adn_jom` | bdicred | D03 Créditos | 6 | CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cierre_diario_pp_parte_pbainci` | bdicred | D03 Créditos | 6 | CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_clona_tdc_upgrade` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_clona_tdc_upgrade_nocturno` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_clona_tdc_upgrade_sc` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_clona_tdc_upgrade_web` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_consulta_proyecta_credisol` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_encabezado_calculo_tdc` | bdicred | D03 Créditos | 6 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtiene_tabla_amortizacion` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtiene_tabla_amortizacion_web` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_pagopp_quitacondona` | bdicred | D03 Créditos | 6 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | CUB CNBV |
| `sp_proyecta_prest_credisol` | bdicred | D03 Créditos | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_rpt_calificacion_riesgo_cliente` | bdinteg | D02 Integr. | 6 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `sp_obtensolicitudmaquilatdc` | bdisolic | D06 Solic. | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtensolicitudmaquilatdc_nom` | bdisolic | D06 Solic. | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtensolicitudmaquilatdc_web` | bdisolic | D06 Solic. | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_proyecta_prestamos` | bdisolic | D06 Solic. | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_proyecta_prestamos_web` | bdisolic | D06 Solic. | 6 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_registra_documento_en_bitacora` | bdiaclaracion | D07 Aclar. | 5 | Art.78 LIC — conservación de información 5 años (bitácoras y... | La invocación debe tener algún valor |
| `sp_reportediarioacl` | bdiaclaracion | D07 Aclar. | 5 | Art.78 LIC — conservación de información 5 años (bitácoras y... | RECA/SAC |
| `sp_reportediarioacl_2day` | bdiaclaracion | D07 Aclar. | 5 | Art.78 LIC — conservación de información 5 años (bitácoras y... | RECA/SAC |
| `sp_calcula_sdo_nvo_y_promedio_admin_tasas` | bdicheq | D04 Cheques | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_calculaintaclaraciones` | bdicheq | D04 Cheques | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | RECA/SAC |
| `sp_generaredoctaeje_factelect_esp` | bdicheq | D04 Cheques | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `calc_iva_grav` | bdicred | D03 Créditos | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calc_iva_grav_cierre` | bdicred | D03 Créditos | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `gencartconsumo_crd` | bdicred | D03 Créditos | 5 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `generaedosctacrd_pp_pba` | bdicred | D03 Créditos | 5 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `nivelavencido` | bdicred | D03 Créditos | 5 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `revisa_tasa` | bdicred | D03 Créditos | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cierre_diario_adn` | bdicred | D03 Créditos | 5 | CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | CUB Anexo 36 |
| `sp_generareporteivaintreal` | bdicred | D03 Créditos | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: respaldo / garantía de crédito (aval) |
| `sp_obtiene_tabla_amortizacion_edocta` | bdicred | D03 Créditos | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtiene_tabla_amortizacion_edocta_inha` | bdicred | D03 Créditos | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtienecatanual` | bdicred | D03 Créditos | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_pflex_disposicion` | bdicred | D03 Créditos | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_rep_cartera_quebrantar_crd` | bdicred | D03 Créditos | 5 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_cal_riesgo_cliente` | bdinteg | D02 Integr. | 5 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `cancela` | bdinvers | bdinvers | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cierreinv` | bdinvers | bdinvers | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cierreinv_28102009` | bdinvers | bdinvers | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cierreinv_pba` | bdinvers | bdinvers | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cierreinv_tmp` | bdinvers | bdinvers | 5 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `burofisicas` | bdiburo | bdiburo | 4 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `cobintcomsbg` | bdicheq | D04 Cheques | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `histsbg` | bdicheq | D04 Cheques | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `sp_activaciones_codi_isa` | bdicheq | D04 Cheques | 4 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Fórmula: conciliación de cheques |
| `sp_calcsdo_ctasinactivas` | bdicheq | D04 Cheques | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_calcsdoctainactiva` | bdicheq | D04 Cheques | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_cuenta` | bdicheq | D04 Cheques | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_esp_pru` | bdicheq | D04 Cheques | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelectxcuenta` | bdicheq | D04 Cheques | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_adminitasas_cargarchivo` | bdicnweb | D01 Canal | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_consultasaldoscredito` | bdicnweb | D01 Canal | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Error en la ejecucion del sp bdicred:sp_conssdoticket |
| `abreax` | bdicred | D03 Créditos | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cal_tradicion` | bdicred | D03 Créditos | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `determina_lincred_tc` | bdicred | D03 Créditos | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Calcula tasa (de interés) |
| `mora_detalle` | bdicred | D03 Créditos | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `provision` | bdicred | D03 Créditos | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_actualiza_reserva_corte` | bdicred | D03 Créditos | 4 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `sp_calculo_reserva_corte_crd` | bdicred | D03 Créditos | 4 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `sp_calporcentaje_pp` | bdicred | D03 Créditos | 4 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_calporcentaje_rr` | bdicred | D03 Créditos | 4 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_provision_intereses` | bdicred | D03 Créditos | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_generaredoctaeje_factelect_transfer` | bditransfer | bditransfer | 4 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_actualiza_inventarios` | intercard | intercard | 4 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Dbaccess intercard /resplogifx/log_existencia_sucursal.sql |
| `burofisicas_cnr` | bdiburo | bdiburo | 3 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `burofisicas_pba_jj` | bdiburo | bdiburo | 3 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `sp_chi_cre_layout_sics` | bdiburo | bdiburo | 3 | LRSIC — Buró de Crédito; evaluación crediticia | Xburofis.unl > |
| `sp_ctes_activ_rep_buro_cred` | bdiburo | bdiburo | 3 | LRSIC — Buró de Crédito; evaluación crediticia | Retorna código de error 102005 |
| `ajusteprovision` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `arrpagoint_18082010` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 00 |
| `calc_int` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calc_interes` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calc_isr` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `cargo_ref_cel` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cargo_ref_cel_mib` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cargo_ref_cel_pba` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Rrg se modifica para el proyecto de circular 22/2010 comisiones atm 26... |
| `coninvsr_anual` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `conisr_anual` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_dskrgactasinform3anios` | bdicheq | D04 Cheques | 3 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Fórmula: conciliación de cheques |
| `sp_generainfcnbv` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_generaredoctaeje_factelect` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp1` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp2` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp3` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp4` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp5` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_grabaintsisr` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `tmpsaldos` | bdicheq | D04 Cheques | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cb_genrepcuentasatraspasar` | bdicnweb | D01 Canal | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_guardainfoctemoral` | bdicnweb | D01 Canal | 3 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_guardactemoral |
| `sp_guardainfoctemoral2` | bdicnweb | D01 Canal | 3 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_guardactemoral |
| `sp_guardainfoctemoral_may29` | bdicnweb | D01 Canal | 3 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_guardactemoral |
| `calcula_meses_fin_pagomin_base` | bdicred | D03 Créditos | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `califcartconsumo` | bdicred | D03 Créditos | 3 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `cargo_ref_cel_pba_sfsa` | bdicred | D03 Créditos | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Rrg se modifica para el proyecto de circular 22/2010 comisiones atm 26... |
| `cargo_ref_celpba` | bdicred | D03 Créditos | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `generaedosctacrd` | bdicred | D03 Créditos | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `sp_modmaesdos_central` | bdicred | D03 Créditos | 3 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB CNBV — calificación cartera vencida y constitución de re... | CUB B-5 |
| `sp_obtiene_tabla_amortizacion_pp` | bdicred | D03 Créditos | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtiene_tabla_amortizacion_pp_web` | bdicred | D03 Créditos | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_pflex_disposicion_apoyo` | bdicred | D03 Créditos | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_provision_de_intereses` | bdicred | D03 Créditos | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_proyecta_promo` | bdicred | D03 Créditos | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `ctemoral` | bdinteg | D02 Integr. | 3 | CUB CNBV — calificación cartera vencida y constitución de re... | Retorna código de error 110 |
| `ctemoral2` | bdinteg | D02 Integr. | 3 | CUB CNBV — calificación cartera vencida y constitución de re... | Retorna código de error 110 |
| `apertura` | bdinvers | bdinvers | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `apertura_app` | bdinvers | bdinvers | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `conprev1` | bdinvers | bdinvers | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `conprev1_web` | bdinvers | bdinvers | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtentasaprod` | bdinvers | bdinvers | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_renuevapagares_19022014` | bdinvers | bdinvers | 3 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_cargoxajuste_debcred` | bdiaclaracion | D07 Aclar. | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | Intento de cargo con crédito vencido "bt" y bloqueado |
| `burofisicas_cnr_pba` | bdiburo | bdiburo | 2 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `burofisicas_fecha` | bdiburo | bdiburo | 2 | LRSIC — Buró de Crédito; evaluación crediticia | Cálculo con umbral/factor 10 |
| `calc_isr_proy` | bdicheq | D04 Cheques | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `cierre_diario` | bdicheq | D04 Cheques | 2 | CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R... | CUB Anexo 36 |
| `cierre_diario_pba` | bdicheq | D04 Cheques | 2 | CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R... | CUB Anexo 36 |
| `cierre_diarioqra` | bdicheq | D04 Cheques | 2 | CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R... | CUB Anexo 36 |
| `crea_maehis` | bdicheq | D04 Cheques | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `crea_maehisqra` | bdicheq | D04 Cheques | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `reversiontd_cel` | bdicheq | D04 Cheques | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sc_cons_ctasdos_bpi_mx` | bdicheq | D04 Cheques | 2 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | - valida que el cliente no sea blanco |
| `sp_blqdesconcentractasinactivas` | bdicheq | D04 Cheques | 2 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | LIVA |
| `sp_calculagat` | bdicheq | D04 Cheques | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: periodo · tasa (de interés) (conversión porcentual (÷100)) |
| `sp_cobracominactividad` | bdicheq | D04 Cheques | 2 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | LTOSF Art.17 (CAT) + RECO |
| `sp_corrige_isr` | bdicheq | D04 Cheques | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_ctamec_consultarinfoctamoral` | bdicheq | D04 Cheques | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | Se verifica que se tenga al menos un parametro |
| `sp_ctamec_consultarinfoctamoral2` | bdicheq | D04 Cheques | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | Se verifica que se tenga al menos un parametro |
| `sp_proyeccionsc` | bdicheq | D04 Cheques | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `sp_proyeccionsc_web` | bdicheq | D04 Cheques | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `sp_reportactasinactivas` | bdicheq | D04 Cheques | 2 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Fórmula: conciliación de cheques |
| `tmp_proyeccionsc` | bdicheq | D04 Cheques | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `sp_adminitasas_ope_guardainfo` | bdicnweb | D01 Canal | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Error en la ejecucion del sp bdinvers:sp_calculagat_promocion |
| `sp_admintasas_consultapagare` | bdicnweb | D01 Canal | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Reinversion capital / deposito intereses a cta |
| `sp_ccl_consultainteresisr` | bdicnweb | D01 Canal | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Error en la ejecucion del sp bdicheq:sp_consintisrxprod2 |
| `sp_consultabitacoraccl` | bdicnweb | D01 Canal | 2 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Error en la ejecuciãn del sp bditarjeta:sp_conbitacora_con2 |
| `sp_consultabitacoratasascomipmtc` | bdicnweb | D01 Canal | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Error en la ejecuciãn del sp bdicheq:sp_consultavalorparametro |
| `sp_guardacambioinstruccionpagare_vtototal` | bdicnweb | D01 Canal | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 36000 |
| `sp_guardadatoslegalesctemoral` | bdicnweb | D01 Canal | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp ctemoraldatoslegales |
| `sp_repctasinactivasart61` | bdicnweb | D01 Canal | 2 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Fecha de consulta |
| `sp_cat_cierrellamadas` | bdicobranza | D11 Cobr. | 2 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Art.78 LIC |
| `sp_generafechpagoreestructura_baja` | bdicobranza | D11 Cobr. | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `cons_pago_minimo_no_interes_pba` | bdicorresp | bdicorresp | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 999 |
| `calc_iva_grav_pp` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calc_iva_grav_pp_09062013` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calporcentaje` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `cobraintvencidocrd` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `cobramoratorioscrd` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `consultmovscre_tipo_bpi_exp` | bdicred | D03 Créditos | 2 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `crea_plazoniv` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `pagnive_pagare` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `pagnive_pagaxe` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `pagos_nivelados` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `principalcrd` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `renivela_ax` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_administra_reestructura_pp` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_calculo_tiir` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cierre_credito` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cierre_credito_01mx` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cierre_credito_2019` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cierre_credito_mx` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cierre_credito_paso` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_complivaintvenci` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 15 |
| `sp_consulta_saldos_general_mora` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_consulta_sdo` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_consulta_tc` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_consulta_vencido_bancoppel` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_consultadatos_motor` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | CUB CNBV |
| `sp_descarga_movhisedocta_credisoluciones` | bdicred | D03 Créditos | 2 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Descargacredsolsdoint1.unl |
| `sp_genera_reporte_calificacion` | bdicred | D03 Créditos | 2 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Cp /resplogifx/burodecredito/calificacion.unl /resplogifx/burodecredit... |
| `sp_geninsumos_calif_pp_parte` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_identificar_clientes` | bdicred | D03 Créditos | 2 | Art.78 LIC — conservación de información 5 años (bitácoras y... | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Cálculo con umbral/factor 30.42 |
| `sp_ofi_consultasdos` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos2` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos_2` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos_exp` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos_mib` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos_pba` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_plan_pausa_obtiene_tasa_interes` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_reduce_pagoanticipado` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_rep_cartera_quebrantar` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_rep_ctes_pagvencidos` | bdicred | D03 Créditos | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | Reportectes_pagosvencidos.unl > |
| `sp_saldos_facturacion` | bdicred | D03 Créditos | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 65 |
| `sp_venta_cartera` | bdicred | D03 Créditos | 2 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | CUB B-5 |
| `sp_venta_cartera_parte` | bdicred | D03 Créditos | 2 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | CUB B-5 |
| `sp_venta_cartera_pba` | bdicred | D03 Créditos | 2 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | CUB B-5 |
| `direcciones_ctemoral` | bdinteg | D02 Integr. | 2 | CUB CNBV — calificación cartera vencida y constitución de re... | Retorna código de error 104 |
| `sp_ipab_pagare` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_ipab_prueba` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repchequesipab` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repchequesipab_temp` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repchequesipab_temp_esp` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repchequesipab_temp_esp2` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repinveripab` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_repipab_direc_pte1` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_direc_pte2` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_direc_pte3` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_parte1` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_parte10` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_parte4` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_parte5` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_parte6` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_parte7` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_parte8` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipab_parte9` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_repipabinver` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_reppagaresipab` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_reppagaresipab_temp` | bdinteg | D02 Integr. | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `actinversion1` | bdinvers | bdinvers | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 365 |
| `actualiza_intereses_pagares` | bdinvers | bdinvers | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: conciliación de cheques |
| `canc_antic` | bdinvers | bdinvers | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_actualiza_intereses_pagares` | bdinvers | bdinvers | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: conciliación de cheques |
| `sp_desprov_pagares` | bdinvers | bdinvers | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_generaredoctaeje_factelect_pag` | bdinvers | bdinvers | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_modintacum_pagares` | bdinvers | bdinvers | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_renuevapagares` | bdinvers | bdinvers | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_renuevapagares_comp` | bdinvers | bdinvers | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_alertasabonospei` | bdispei | D08 SPEI | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: conciliación de cheques |
| `sp_alertasabonosspei` | bdispei | D08 SPEI | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: conciliación de cheques |
| `spei_calculointeres` | bdispei | D08 SPEI | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 518400 |
| `spei_calculointeres_pba` | bdispei | D08 SPEI | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 518400 |
| `sp_auditortarjeta` | intercard | intercard | 2 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Dbaccess intercard /resplogifx/tarasignadas.sql |
| `sp_ope_bitacoraxml` | bdiauditor | bdiauditor | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Error en la ejecuciãn del sp bdiauditor:sp_chq_crg_bitacora |
| `sp_permorales_listanegra` | bdiauditor | bdiauditor | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | - validacion de campos requeridos |
| `sp_cargarreversarcuentatoken_bpi_web` | bdibpi | bdibpi | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `burocred` | bdiburo | bdiburo | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Retorna código de error 260 |
| `burocred1` | bdiburo | bdiburo | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Retorna código de error 260 |
| `burocred_apolo` | bdiburo | bdiburo | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Retorna código de error 260 |
| `burocred_oc` | bdiburo | bdiburo | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Retorna código de error 260 |
| `sp_val_conciliacion_cnr` | bdiburo | bdiburo | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `bonifica` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calc_tasa` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 901 |
| `calc_tasaqra` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 901 |
| `cobraivaint` | bdicheq | D04 Cheques | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `con_canc` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `con_canc_pba` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cons_saldo_cel` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cons_sdoschq_bpi_pba` | bdicheq | D04 Cheques | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | - valida que la cuenta  no sea blanco |
| `construyehis` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 36000 |
| `crea_maehis_especial` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `inicio_mes` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `inicio_mes_esp` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `mod_ctaefecplus` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 075 |
| `pasex` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_aplicaaclaradebito` | bdicheq | D04 Cheques | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Intento de cargo con crã?ã?ã?ãâ©dito vencido "bt" y bloqueado |
| `sp_aplicaaclaradebito_prueba` | bdicheq | D04 Cheques | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Intento de cargo con crã?ã?ã?ãâ©dito vencido "bt" y bloqueado |
| `sp_calculagat_morales` | bdicheq | D04 Cheques | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_cancelactasinactivas` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Fórmula: conciliación de cheques |
| `sp_cap_recalculagat1200` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_conciliaciondispersionnomina_his` | bdicheq | D04 Cheques | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 110 |
| `sp_conciliainv` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: conciliación de cheques |
| `sp_dispersionlinea_bpi_pba2` | bdicheq | D04 Cheques | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `sp_dskrgactasinform3anios3meses` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Set isolation to dirty read; unload to /resplogifx/conciliachq/ctasina... |
| `sp_dskrgainfoperativa` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Fórmula: conciliación de cheques |
| `sp_dskrgainfoperativa_pbas3` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Fórmula: conciliación de cheques |
| `sp_dskrgainfoperativacomp1` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Fórmula: conciliación de cheques |
| `sp_dskrgainfoperativapbahtm` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Fórmula: conciliación de cheques |
| `sp_liberaretinterpza` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: conciliación de cheques |
| `sp_liberaretinterpza_pba` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: conciliación de cheques |
| `sp_pagaintsinvscrecs2` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `sp_paso_movdia_movhis` | bdicheq | D04 Cheques | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Truncate table "informix".paso_movdia_movhis; |
| `sp_pld_conci` | bdicheq | D04 Cheques | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_procsdesconcentracionctasmasivas` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Error en la ejecucion del sp bdicheq:sp_blqdesconcentractasinactivas |
| `sp_respuesta_isa` | bdicheq | D04 Cheques | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Cat /resplogifx/conciliachq/archivosrespuestaisa/kpi_seguimiento_isa_ |
| `sp_rptcobrocominactividad` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Set isolation to dirty read; unload to /resplogifx/conciliachq/rptcobr... |
| `sp_rptctasinact` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Set isolation to dirty read; unload to /resplogifx/conciliachq/rptctas... |
| `sp_traspasoctabeneficencia_com` | bdicheq | D04 Cheques | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Load from /resplogifx/conciliachq/cuentas.txt insert into ctas_trasp; |
| `sp_validatransferencias_bpi_trans` | bdicheq | D04 Cheques | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Retorna código de error 50001 |
| `tmp_renovacre` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Calcula intereses (base 360 (año comercial), conversión porcentual (÷1... |
| `tmppagoint` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `upielayout_edocuenta` | bdicheq | D04 Cheques | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 12 |
| `sp_adm_consultabitacora_usuarios` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 1001 |
| `sp_admintasas_bitacoraerror` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 1001 |
| `sp_admintasas_consultabitacora` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 1001 |
| `sp_admintasas_detallegat` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 1001 |
| `sp_bccc_catcomentario` | bdicnweb | D01 Canal | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Error en la ejecución del sp bdicred:sp_mon_buro_conscaterrores |
| `sp_bccc_consinforeenvio` | bdicnweb | D01 Canal | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Error en la ejecución del sp bdicred:sp_mon_buro_coninfoctestatus |
| `sp_bccc_detsolicitudeslincred_totales` | bdicnweb | D01 Canal | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Error en la ejecuciãn del sp bdicred:sp_mon_buro_conssolcredlincred |
| `sp_blqdesconcentractasinactivascap` | bdicnweb | D01 Canal | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Cuenta no existe |
| `sp_catalogoactividadsocialctemoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_consultaactividadsocial |
| `sp_catalogoctasxproductomoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecuciãn del sp bdicheq:sp_consultarctasxproductomoral |
| `sp_catalogogiromercantilctemoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_consultagiromercantil |
| `sp_catalogosufijosctemoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_consultasufijos |
| `sp_catalogotasasfecha` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 1001 |
| `sp_ccl_consultainteresisr_totales` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Error en la ejecucion del sp bdicheq:sp_consintisrxprod2_totales |
| `sp_ccl_finalizacedulainterescap` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Error en la ejecucion del sp bdicheq:sp_finintisrxprodcedula |
| `sp_cg_consultabitacorasumarestaimp` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 1001 |
| `sp_cg_consultasaldoactualsumarestaimp` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Error en la ejecucion del sp bdisuc: |
| `sp_cg_detallebitacora` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 1001 |
| `sp_cg_detallebitacoramodificaciones` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 1001 |
| `sp_cg_detallebitacoratipoconcentracion` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 1001 |
| `sp_consdireccionctemoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_consul_direc |
| `sp_consdireccionctemoral2` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_consul_direc |
| `sp_consguardabitacoraccl` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Error en la ejecucion del sp bditarjeta.sp_concreing_guardabitacora |
| `sp_conspagaresvencidosvigentes` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Retorna código de error 1001 |
| `sp_consreportesctasinactivasart61` | bdicnweb | D01 Canal | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Retorna código de error 1001 |
| `sp_constasatabular` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 1001 |
| `sp_consulta_desactualizadas_buro` | bdicnweb | D01 Canal | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Retorna código de error 1001 |
| `sp_consultacomisionestasatc` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Error en la ejecucion del sp bdicheq:sp_consultadettasacomi_pm |
| `sp_consultainfoctemoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_consultarctemoral_03 |
| `sp_consultainfoctemoral2` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_consultarctemoral_04 |
| `sp_consultainfoctemoralrfc` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_consultarctemoral_04 |
| `sp_consultainformacionctamoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_ctamec_consultarinfoctamoral: |
| `sp_consultainformacionctamoral2` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_ctamec_consultarinfoctamoral: |
| `sp_consultainfosolicitudmc` | bdicnweb | D01 Canal | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Error en ejecucion de sp productivo sp_mc_obteninfosolicitudgen |
| `sp_consultasaldopagare` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | La cuenta no existe |
| `sp_cp_bitacoraerrormanualtdc` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 1001 |
| `sp_cred_consultasaldosgeneral` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Error en la ejecucion del sp |
| `sp_fc_bitacorahuellas` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Error en la ejecucion del sp bdinteg:sp_bithuellasfusion |
| `sp_fc_traspasoctascap` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp bdinteg:sp_traspasocuentas_cap_soc |
| `sp_genrepstatussol` | bdicnweb | D01 Canal | 1 | LRSIC — Buró de Crédito; evaluación crediticia | To_char(fecha_alta, |
| `sp_guardaapoderadosctemoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp ctemoralapoderados |
| `sp_guardaapoderadosctemoral2` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp ctemoralapoderados |
| `sp_guardabitacoraccl` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Error en la ejecuciãn del sp bditarjeta:sp_concreing_guardabitacora |
| `sp_guardactemoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp ctemoral |
| `sp_guardactemoral2` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp ctemoral |
| `sp_guardadireccionesctemoral2` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp direcciones_ctemoral |
| `sp_insertabitacoracomisiontc` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Error en la ejecucion del sp bdicheq:sp_guardabittascomi_pm |
| `sp_insertabitacoracomisiontc2` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Error en la ejecucion del sp bdicheq:sp_guardabittascomi_pm |
| `sp_obtieneparametrochequeractamoral` | bdicnweb | D01 Canal | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Error en la ejecucion del sp sp_obtieneparametrochequera |
| `sp_ope_consultabitacoraerroresmetas` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 1001 |
| `sp_ope_insertasolicitudtdcmasivo` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Fórmula: producto · fecha · usuario |
| `sp_pos_busquedabitacorapos` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 1001 |
| `sp_rem_obtieneinfoidentificacionbts` | bdicnweb | D01 Canal | 1 | CUB Art.310-315 — Corresponsalía BTS; validación convenio ac... | Error en la ejecución del sp bdisac:sp_bts_obtieneinfoidentificacion |
| `sp_reporteestadocuentasac` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 1001 |
| `sp_reporteestadocuentasac_pba` | bdicnweb | D01 Canal | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Retorna código de error 1001 |
| `sp_reportetraspasoctabeneficencia` | bdicnweb | D01 Canal | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Art.61 LIC |
| `sp_sac_consultabitacoraiva` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 1001 |
| `sp_sac_repbitacoraiva` | bdicnweb | D01 Canal | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Cálculo con umbral/factor 10 |
| `sp_cargatelefonosburo_pba` | bdicobranza | D11 Cobr. | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Retorna código de error 11100 |
| `sp_cat_auronix_target_phone` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_cat_consulta_disponibilidad_cliente` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_cilocgeneraarchivocobranza` | bdicobranza | D11 Cobr. | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 36000 |
| `sp_envio_mail_sms_tgc` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_formulario_liquidez` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_gen_reporte_campana_prev_pzo` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Fórmula: campaña · número de cliente |
| `sp_gen_reporte_campana_prev_rev` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Fórmula: campaña · número de cliente |
| `sp_genera_reportes_agex` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Monto_ult_pago_periodo, to_char(fecha_ult_pago_periodo, |
| `sp_generainfo_automatiza_800` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Cálculo con umbral/factor 16 |
| `sp_mail_compconadeudo` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_mail_compsincumplir` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_mail_montovencido` | bdicobranza | D11 Cobr. | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 36000 |
| `sp_mail_montovencido_baja` | bdicobranza | D11 Cobr. | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 36000 |
| `sp_mail_montovencido_pln` | bdicobranza | D11 Cobr. | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 36000 |
| `sp_mail_montovencido_tco` | bdicobranza | D11 Cobr. | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 36000 |
| `sp_registro_evaluacion_objetiva` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | 20191024 |
| `sp_registro_evaluacion_objetiva_crd` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Cálculo con umbral/factor 100,2 |
| `sp_rep_cobvent_ctesvencsuc` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Fórmula: empleado · nombre · sucursal |
| `sp_reportes_cobranza_resultados_campanias` | bdicobranza | D11 Cobr. | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `sp_validavencidos` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_validavencidos_bis` | bdicobranza | D11 Cobr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `inicializa` | bdicont | D12 Contab. | 1 | CUB Anexo 33-34 — Plan de cuentas mínimo; cuadre DEBE = HABE... | Dbschema -q -d bdicont -t co_sdodias -p all tabla; sed /revoke/d tabla... |
| `calc_intdia` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calc_intdialiq` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `calcula_meses_fin` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `cat` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 |
| `clasica_sdoscuadra` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `clasica_sdosp` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `clasica_sdosx` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cobracapvencidocrd` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `cobranza` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `comdistdc` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `cons_saldo_cel` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Calcula IVA (impuesto — SAT) |
| `generaestadosdecuenta_comple` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `metodo_frances` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Fórmula: plazo (depósito / crédito a plazo) · tasa (de interés) · mont... |
| `minispro2` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `ministracion` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `pasecont_his` | bdicred | D03 Créditos | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Art.78 LIC |
| `pasecont_movhis` | bdicred | D03 Créditos | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Art.78 LIC |
| `pasecontrees_his` | bdicred | D03 Créditos | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Art.78 LIC |
| `renivelaesp` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 12 |
| `renivelaplanpagos` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 12 |
| `sd_datosriesgoscred` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Cálculo con umbral/factor 30 |
| `sd_datosriesgoscredprueba` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Cálculo con umbral/factor 30 |
| `sd_riesgoscredito` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Cálculo con umbral/factor 30 |
| `sp_actvig_camp` | bdicred | D03 Créditos | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Fórmula: origen · plazo (depósito / crédito a plazo) · Campaña — campa... |
| `sp_actvig_camp_mx` | bdicred | D03 Créditos | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Fórmula: origen · plazo (depósito / crédito a plazo) · Campaña — campa... |
| `sp_aplicaaclaracredito` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Intento de cargo con crã©dito vencido "bt" y bloqueado |
| `sp_buscarctesamigrar` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_buscarctesamigrar_web` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_cac_calculalinsugcte` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_calculasaldosobreinteres` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `sp_calculo_cat_publicidad` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 360 |
| `sp_carga_info_risck` | bdicred | D03 Créditos | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Insert into |
| `sp_cobro_automatico_pp_6400` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_compone_vencidos_bt` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_compra_promo_pf` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Valide el plazo/tasa seleccionado |
| `sp_consulta_credito_hoy_iccat` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Cálculo con umbral/factor 15 |
| `sp_consulta_retiro_tdc` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_consultadatos_motor_precal` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_corrige_aumlincred` | bdicred | D03 Créditos | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Cálculo con umbral/factor 30.42 |
| `sp_corrige_capitalizacion` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 67 |
| `sp_depura_cred_his` | bdicred | D03 Créditos | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 100100 |
| `sp_factura` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 30 |
| `sp_genera_reestructuras_aut` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_genera_universo_aumlincred` | bdicred | D03 Créditos | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Cálculo con umbral/factor 30.42 |
| `sp_geninsumos_calif_an` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_geninsumos_calif_pdig` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_geninsumos_calif_reest` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_ics_cuotas` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_ics_cuotas_crd` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_identifica_saldosinmateriales` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Fórmula: empresa (entidad bancaria) · número de cliente · estatus |
| `sp_identificar_clientes_ofi` | bdicred | D03 Créditos | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Cálculo con umbral/factor 30.42 |
| `sp_identificar_clientes_pba` | bdicred | D03 Créditos | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Cálculo con umbral/factor 30.42 |
| `sp_liquida_prestamo_reestructura` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_mon_buro_conssolcredlincred` | bdicred | D03 Créditos | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Encuentre mas registros devuelve una última linea |
| `sp_mon_buro_conssolcredlincred2` | bdicred | D03 Créditos | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Encuentre mas registros devuelve una ãltima linea |
| `sp_msi_proyecta_msi` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_obtienecatanual_pdn` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_pago_anticipado_pp` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_plan_pausa_evalua_pago_cliente` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_provision` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Calcula interés |
| `sp_provision_moratorios` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_proyecta_pfsms` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_rasura_moratorios_condonacion` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_rasura_moratorios_quitas` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_rep_aumlincred` | bdicred | D03 Créditos | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Fórmula: número de cliente (base 30 días/mes) |
| `sp_rep_clientes_mora0a1` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_rep_ctasactivas_sin_plastico` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_rep_ctasactivas_sin_plastico_mx3` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_rep_ctasactivas_sin_plastico_pba` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_rep_men_increm_auto_cartven` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | LTOSF Art.17 |
| `sp_rep_men_increm_auto_hist` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | LTOSF Art.17 |
| `sp_reporte_bim_alta_cte` | bdicred | D03 Créditos | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Fórmula: estado (entidad federativa / estatus) · nacionalidad · país |
| `sp_reporte_saldosinmateriales` | bdicred | D03 Créditos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | Fórmula: empresa (entidad bancaria) · número de cliente · estatus |
| `sp_restaura_calificacion` | bdicred | D03 Créditos | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Cálculo con umbral/factor 15 |
| `spsd_cupones` | bdicred | D03 Créditos | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_bitacora_cambiosdomcobranza` | bdinteg | D02 Integr. | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | No se encontró información |
| `sp_bitacora_ife_opt` | bdinteg | D02 Integr. | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Art.78 LIC |
| `sp_claveasocia_cta_cel_bpi_mx` | bdinteg | D02 Integr. | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | Para la validacion de itunes |
| `sp_consultabitacoraencuesta` | bdinteg | D02 Integr. | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Art.78 LIC |
| `sp_gen_report_articulo_51` | bdinteg | D02 Integr. | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Set isolation to dirty read; set lock mode to wait 3; unload to |
| `sp_generaarchivoconsultarespuestaburo` | bdinteg | D02 Integr. | 1 | LRSIC — Buró de Crédito; evaluación crediticia | LRSIC |
| `sp_grabarfcalternobitacoramtto` | bdinteg | D02 Integr. | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Retorna código de error 373 |
| `sp_llenacteestadocuenta_comple` | bdinteg | D02 Integr. | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 36000 |
| `sp_relacion_consultainfocte` | bdinteg | D02 Integr. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `actinteisr` | bdinvers | bdinvers | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Calcula importe sobre importe |
| `actinteres` | bdinvers | bdinvers | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `actinversion` | bdinvers | bdinvers | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 365 |
| `calc_isr` | bdinvers | bdinvers | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `coninv_antic` | bdinvers | bdinvers | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `instrucc` | bdinvers | bdinvers | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `instrucc_pba` | bdinvers | bdinvers | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_calcula_promedio_ponderado_pagare_admin_tasas` | bdinvers | bdinvers | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Criterios contables CNBV + GAT |
| `sp_altabajaterceros_bpi_trans` | bdiprog | bdiprog | 1 | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Sever... | CUB B-5 |
| `r04a0411` | bdiriesgos | bdiriesgos | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_bts_confirmapayc` | bdisac | D05 Saldos | 1 | CUB Art.310-315 — Corresponsalía BTS; validación convenio ac... | Retorna código de error 9982 |
| `sp_bts_recuperapayc` | bdisac | D05 Saldos | 1 | CUB Art.310-315 — Corresponsalía BTS; validación convenio ac... | Retorna código de error 9978 |
| `sp_sac_pago_atm_infonavit` | bdisac | D05 Saldos | 1 | Art.61 LIC — cuentas inactivas → prescripción a beneficencia... | Tarjeta bloqueada/inactiva |
| `califica_scoring2_cjunk` | bdisolic | D06 Solic. | 1 | LRSIC — Buró de Crédito; evaluación crediticia | Solicitud enviada a orden de supervision |
| `calulavariables_modelo2_pp` | bdisolic | D06 Solic. | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | Cálculo con umbral/factor 22 |
| `situacion_pago_tienda_cjunk` | bdisolic | D06 Solic. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `situacion_pago_tienda_cjunk_precal` | bdisolic | D06 Solic. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `situacion_pago_tienda_cjunk_precal1_pru` | bdisolic | D06 Solic. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_generareportepp` | bdisolic | D06 Solic. | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_generareportepp_web` | bdisolic | D06 Solic. | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LTOSF Art.17 (CAT) + RECO |
| `sp_mc_obteninfosolicitudsoc` | bdisolic | D06 Solic. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_mc_respuestaconscoppel` | bdisolic | D06 Solic. | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `sp_afecta_cajageneral` | bdisuc | D10 Suc. | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Art.78 LIC |
| `sp_au_guardarbitacora` | bditarjcop | bditarjcop | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Art.78 LIC |
| `sp_au_guardarbitacora_pba` | bditarjcop | bditarjcop | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Art.78 LIC |
| `sp_generaredoctaeje_factelect_transfer_esp` | bditransfer | bditransfer | 1 | Criterios contables CNBV + GAT — cálculo de intereses/rendim... | LISR Art.54/135 |
| `sp_consulta_disponibilidad_pred` | bditrapres | bditrapres | 1 | CUB CNBV — calificación cartera vencida y constitución de re... | CUB CNBV |
| `ivr_valida_telefono` | bdivr | bdivr | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | // se activa registro en bitacora |
| `sp_cancelatarjetas_lote` | intercard | intercard | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Fórmula: fecha · usuario · resultado |
| `sp_cancelatarjetas_rob_frau_ext` | intercard | intercard | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Unload to encab1.txt select * from intercard:bitacoracancelaciontarjet... |
| `sp_depura_bitacora_token_cardoperation` | intercard | intercard | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Set isolation to dirty read; set lock mode to wait 3; unload to |
| `sp_depura_bitacora_token_digitalcard` | intercard | intercard | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Set isolation to dirty read; set lock mode to wait 3; unload to |
| `sp_depura_bitacora_tokenizacion_otp` | intercard | intercard | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Set isolation to dirty read; set lock mode to wait 3; unload to |
| `sp_validaaumentolincred` | intercardbpi | intercardbpi | 1 | Art.78 LIC — conservación de información 5 años (bitácoras y... | Fórmula: cuenta · tarjeta |

> **Nota:** Los 543 SPs listados son candidatos obligatorios para el golden master de migración en el segmento CNBV. Requieren test cases con datos de golden set regulatorio y validación cruzada con el SME regulatorio.

---

## CONDUSEF

**237 SPs** con un total de **622 reglas** con anotación CONDUSEF.

| SP | DB | Dominio | # Reglas reg. | Normas relevantes | Explicación |
|----|----|---------|--------------|--------------------|-------------|
| `sp_mueve_aclaraciones_historico` | bdiaclaracion | D07 Aclar. | 107 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Fórmula: aclaraciones (proceso de disputas/reclamaciones de cliente) ·... |
| `sp_sac_app_depuracion` | bdisac | D05 Saldos | 21 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Cálculo con umbral/factor 621028 |
| `sp_sac_insertaremesasnoconciliadaswu` | bdisac | D05 Saldos | 20 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_sv_aprovisionamiento_aclaraciones` | bdiaclaracion | D07 Aclar. | 8 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_reportediarioacl` | bdiaclaracion | D07 Aclar. | 7 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_reportediarioacl_2day` | bdiaclaracion | D07 Aclar. | 7 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_calculaintaclaraciones` | bdicheq | D04 Cheques | 7 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_cierres_masivos_afectacion` | bdiaclaracion | D07 Aclar. | 6 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Fórmula: aclaración bancaria — proceso de disputa o reclamación del cl... |
| `sp_top20acl` | bdiaclaracion | D07 Aclar. | 6 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Cálculo con umbral/factor 20 |
| `sp_cargoxcomision_pm` | bdicheq | D04 Cheques | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_cargoxcomision_pm_comp2` | bdicheq | D04 Cheques | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_cargoxcomision_pm_esp` | bdicheq | D04 Cheques | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_cargoxcomision_pmcomp` | bdicheq | D04 Cheques | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ejecutartransacciones` | bdiprog | bdiprog | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ejecutartransacciones_inc` | bdiprog | bdiprog | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ejecutartransacciones_pba` | bdiprog | bdiprog | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_sac_reportediario_seg` | bdisac | D05 Saldos | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | LTOSF Art.17 (CAT) + RECO |
| `certi_chq` | bditrans | bditrans | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `gir_comi` | bditrans | bditrans | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `ord_comi` | bditrans | bditrans | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `ordpago` | bditrans | bditrans | 6 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_integracion_cuenta` | bdiaclaracion | D07 Aclar. | 5 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `cargo_ref_cel_pba` | bdicheq | D04 Cheques | 5 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Rrg se modifica para el proyecto de circular 22/2010 comisiones atm 26... |
| `cargo_ref_cel_pba_sfsa` | bdicred | D03 Créditos | 5 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Rrg se modifica para el proyecto de circular 22/2010 comisiones atm 26... |
| `sp_repaltaunicaidbox` | bdinteg | D02 Integr. | 5 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Fórmula: aclaraciones (proceso de disputas/reclamaciones de cliente) ·... |
| `sp_sac_pago_atm_infonavit` | bdisac | D05 Saldos | 5 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Tarjeta bloqueada/inactiva |
| `chq_comi` | bditrans | bditrans | 5 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `chqcaj` | bditrans | bditrans | 5 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `chqcaj1` | bditrans | bditrans | 5 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `girbanc` | bditrans | bditrans | 5 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_reportediarioacl_paralelo` | bdiaclaracion | D07 Aclar. | 4 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_reportediarioacl_paralelo_2day` | bdiaclaracion | D07 Aclar. | 4 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `cargo_comisiones_pba` | bdicheq | D04 Cheques | 4 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `cargo_comisiones_per` | bdicheq | D04 Cheques | 4 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `cargo_comisiones_per_web` | bdicheq | D04 Cheques | 4 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `cargo_comisiones_web` | bdicheq | D04 Cheques | 4 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_rep_men_increm_auto_hist` | bdicred | D03 Créditos | 4 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LTOSF Art.17 |
| `sp_calcula_comisiones_pba` | bdisac | D05 Saldos | 4 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_dinya_calcularcomisioniva_bpi` | bdisac | D05 Saldos | 4 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_eliminacion_puntos_coppel` | bdiaclaracion | D07 Aclar. | 3 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_dispercionnomina_bpi` | bdicheq | D04 Cheques | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_nominaconsultasaldoeje` | bdicheq | D04 Cheques | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_nominatotalivacomision` | bdicheq | D04 Cheques | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_nominatotalivacomision_bpi` | bdicheq | D04 Cheques | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_obtienectasefectabiertas_suc` | bdicheq | D04 Cheques | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_obtienetarjetasentregadas` | bdicheq | D04 Cheques | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_tpoaire_transfer` | bdicnweb | D01 Canal | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `minispro2` | bdicred | D03 Créditos | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_comisiones` | bdicred | D03 Créditos | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_domi_cop_procesararchivo` | bdidomi | bdidomi | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_dinya_calcularcomisioniva` | bdisac | D05 Saldos | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_sac_alta_ctesremesas` | bdisac | D05 Saldos | 3 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 10001 |
| `sp_calc_comasiva` | bdispei | D08 SPEI | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_calc_comasiva_web` | bdispei | D08 SPEI | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_pgservicios_transfer` | bditransfer | bditransfer | 3 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_consulta_aclaraciones_producto_cliente_2` | bdiaclaracion | D07 Aclar. | 2 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_recuperacion_saldos` | bdiaclaracion | D07 Aclar. | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | No se realizó la afectación de comision/iva. |
| `sp_relaciona_folioacl_idacl` | bdiaclaracion | D07 Aclar. | 2 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | La invocaciã³n debe tener algãºn valor |
| `sp_reporte_diario_cat` | bdiaclaracion | D07 Aclar. | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_reporte_evidencias_3410` | bdiaclaracion | D07 Aclar. | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_reporte_mensual_acl` | bdiaclaracion | D07 Aclar. | 2 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `burofisicas_concilia` | bdiburo | bdiburo | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Fórmula: saldo |
| `burofisicas_concilia_clon` | bdiburo | bdiburo | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Fórmula: saldo |
| `burofisicas_concilia_cnr` | bdiburo | bdiburo | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Fórmula: saldo |
| `sp_genera_cintas_semanales` | bdiburo | bdiburo | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LRSIC |
| `sp_genera_cintas_semanales_clon` | bdiburo | bdiburo | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LRSIC |
| `sp_genera_cintas_semanales_cnr` | bdiburo | bdiburo | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LRSIC |
| `cobracom` | bdicheq | D04 Cheques | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Rqm 09 704 se agrega la validacion del codigo de retorno no exitoso(di... |
| `sp_cobracom_sin_mov_esp1` | bdicheq | D04 Cheques | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_cobracom_sin_mov_esp2` | bdicheq | D04 Cheques | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_cobracom_sin_mov_esp3` | bdicheq | D04 Cheques | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_cobracominactividad` | bdicheq | D04 Cheques | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_concilia_seguro_atm` | bdicheq | D04 Cheques | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_dispercionnominaautomatico` | bdicheq | D04 Cheques | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_dispercionnominaautomatico_pba` | bdicheq | D04 Cheques | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_dispercionnominamanual` | bdicheq | D04 Cheques | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_sac_reportesremnoconciliadas` | bdicnweb | D01 Canal | 2 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Fórmula: usuario |
| `sp_carga_tabla_movimientos_agex` | bdicobranza | D11 Cobr. | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Pro_206_37_56_carga_movimientos_pentafon_archivo.sql | sed |
| `apercred1_pp_domicilia_web` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Criterios contables CNBV + GAT |
| `apercred1_pp_web` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Criterios contables CNBV + GAT |
| `cat` | bdicred | D03 Créditos | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LTOSF Art.17 |
| `sp_cobro_comision_x_anualidad` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Divide el monto a cobrar para la parcializacion. |
| `sp_comision_anual_devolucion` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_comisionxapertura_contable` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Cálculo con umbral/factor 12 |
| `sp_consulta_saldos_general` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_consulta_saldos_general_evaobj` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_consulta_saldos_general_pba` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ics_genera_layouts_hilos` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Criterios contables CNBV + GAT |
| `sp_info_gen_edocta` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Descargaacl1.unl |
| `sp_proyecta_credisoluciones` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_proyecta_credisoluciones_web` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_proyecta_pfsms` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Criterios contables CNBV + GAT |
| `sp_proyecta_promo` | bdicred | D03 Créditos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Criterios contables CNBV + GAT |
| `sp_domi_procesararchivo31` | bdidomi | bdidomi | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_cargarcatalogosepomex` | bdinteg | D02 Integr. | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LTOSF Art.17 |
| `sp_cargarcatalogosepomex_pba` | bdinteg | D02 Integr. | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LTOSF Art.17 |
| `sp_calcula_comisiones` | bdisac | D05 Saldos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | - se calcula el iva del convenio de acuerdo a la comisión |
| `sp_dinya_calcularcomisioniva_bei` | bdisac | D05 Saldos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_dinya_calcularcomisioniva_pba` | bdisac | D05 Saldos | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_obtensolicitudmaquilatdc` | bdisolic | D06 Solic. | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Criterios contables CNBV + GAT |
| `sp_obtensolicitudmaquilatdc_nom` | bdisolic | D06 Solic. | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Criterios contables CNBV + GAT |
| `sp_obtensolicitudmaquilatdc_web` | bdisolic | D06 Solic. | 2 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Criterios contables CNBV + GAT |
| `sp_generaredoctaeje_factelect_transfer` | bditransfer | bditransfer | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_transfer_esp` | bditransfer | bditransfer | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LISR Art.54/135 |
| `sp_calcula_caratulaproducto_pba` | intercard | intercard | 2 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_acl_reporte_log` | bdiaclaracion | D07 Aclar. | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_consulta_recuperacion` | bdiaclaracion | D07 Aclar. | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ins_recuperacion_saldos` | bdiaclaracion | D07 Aclar. | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Cálculo con umbral/factor 16 |
| `sp_registra_comentario_cliente` | bdiaclaracion | D07 Aclar. | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | La invocaciã³n debe tener algãºn valor |
| `sp_registra_documento_en_bitacora` | bdiaclaracion | D07 Aclar. | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | La invocación debe tener algún valor |
| `sp_reporte_atm_acl_extra` | bdiaclaracion | D07 Aclar. | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_upd_credrecuperacion` | bdiaclaracion | D07 Aclar. | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Calculo cobro comisiãn |
| `sp_burofisicas_cortos` | bdiburo | bdiburo | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LRSIC |
| `sp_burofisicas_cortos_clon` | bdiburo | bdiburo | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LRSIC |
| `sp_burofisicas_cortos_cnr` | bdiburo | bdiburo | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LRSIC |
| `sp_burofisicas_cortos_nov19` | bdiburo | bdiburo | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LRSIC |
| `sp_burofisicas_cortos_pbajj` | bdiburo | bdiburo | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LRSIC |
| `abono_ctas_comis` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Load from /resplogifx/conciliachq/comisionesxabonar.unl delimiter |
| `abono_ctas_comis_pba` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Load from /resplogifx/conciliachq/comisionesxabonar.unl delimiter |
| `cobintcomsbg` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Criterios contables CNBV + GAT |
| `pagoenviar1` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_activaciones_codi_isa` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Fórmula: conciliación de cheques |
| `sp_cobra_comision_cap` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Retorna código de error 975 |
| `sp_cobracom_sin_mov` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_cobracomspei` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Retorna código de error 999 |
| `sp_cobrocomisionreposiciondebito` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_generaredoctaeje_factelect` | bdicheq | D04 Cheques | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | LISR Art.54/135 |
| `sp_generaredoctaejetxt` | bdicheq | D04 Cheques | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Unload to |
| `sp_histmovcheqconsolida` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cat /resplogifx/conciliachq/histmovcheq_aplicados_pte1_ |
| `sp_medalia_atm` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cat /resplogifx/conciliachq/originales/coppel_banco_atm_invitacion_ |
| `sp_medalia_prom` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cálculo con umbral/factor 365 |
| `sp_medalia_vent` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Fórmula: conciliación de cheques |
| `sp_regordenctecte` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | // la cuenta ord. no se encuentra activa |
| `sp_regordenctecte_web` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | // la cuenta ord. no se encuentra activa |
| `sp_respuesta_isa` | bdicheq | D04 Cheques | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cat /resplogifx/conciliachq/archivosrespuestaisa/kpi_seguimiento_isa_ |
| `sp_consultacatcomisionespmtc` | bdicnweb | D01 Canal | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Error en la ejecuciãn del sp bdicheq:sp_consultacatcomisiones_pm |
| `sp_consultacomisionestasatc` | bdicnweb | D01 Canal | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Error en la ejecucion del sp bdicheq:sp_consultadettasacomi_pm |
| `sp_insertabitacoracomisiontc` | bdicnweb | D01 Canal | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Error en la ejecucion del sp bdicheq:sp_guardabittascomi_pm |
| `sp_insertabitacoracomisiontc2` | bdicnweb | D01 Canal | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Error en la ejecucion del sp bdicheq:sp_guardabittascomi_pm |
| `sp_insertactualizacomisiontc` | bdicnweb | D01 Canal | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Error en la ejecucion del sp bdicheq:sp_guardatascomi_pm |
| `sp_insertactualizacomisiontc2` | bdicnweb | D01 Canal | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Error en la ejecucion del sp bdicheq:sp_guardatascomi_pm |
| `sp_ipab_repfideicomisomarcajeipab` | bdicnweb | D01 Canal | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ope_actualizastatusarch` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Error en la ejecucion del sp bdisac:sp_sac_actualizastatusarch |
| `sp_ope_conciliaarchivoptc` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Error en la ejecución del sp bdisac:sp_sac_conciliaarchivoptc |
| `sp_ope_conciliadeta` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Error en la ejecución del sp bdisac:sp_sac_conciliadeta |
| `sp_ope_conciliatotbancos` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Error en la ejecución del sp bdisac:sp_sac_conciliatotbancos |
| `sp_ope_consultaconcmovtotal` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Error en la ejecucion del sp: bdisac:sp_sac_concimovtotal |
| `sp_rem_validaremesabts` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Error en la ejecución del sp bdisac:sp_validarembtsensac |
| `sp_remesasguardarespuestawu` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Error en la ejecucion del sp bdisac:sp_sac_wu_guardarespuesta_search |
| `sp_remesasguardarespuestawu2` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Error en la ejecucion del sp bdisac:sp_sac_wu_guardarespuesta_search_w... |
| `sp_sac_catsucaralreporte` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 1001 |
| `sp_sac_consulta_remesas_abonadas_tdc` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 1001 |
| `sp_sac_consulta_remesas_abonadas_tdc_xls` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_sac_consultabitacoraiva` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 1001 |
| `sp_sac_consultareportes` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 1001 |
| `sp_sac_consultasucursalesfiltro` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 1001 |
| `sp_sac_repabonoatm` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_sac_repbitacoraiva` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Cálculo con umbral/factor 10 |
| `sp_sac_reportedetalletransucursal` | bdicnweb | D01 Canal | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Secuencia |
| `sp_sac_reportesconciliacion` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Fórmula: usuario · sucursal |
| `sp_sac_reportesdiario` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Fórmula: usuario · importe · sucursal |
| `sp_sac_reportesmontototal` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Fórmula: usuario · monto · sucursal |
| `sp_sac_sacreportetotalporconvenio` | bdicnweb | D01 Canal | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Fórmula: usuario |
| `sp_actualiza_catdirectoriocte` | bdicobranza | D11 Cobr. | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Proceso cat directorio cte |
| `sp_carga_tabla_movimientos` | bdicobranza | D11 Cobr. | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | S/vnom_archivo/ |
| `sp_carga_tabla_movimientos_peticion` | bdicobranza | D11 Cobr. | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | S/vnom_archivo/ |
| `sp_gen_reporte_campana_prev_pzo` | bdicobranza | D11 Cobr. | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Fórmula: campaña · número de cliente |
| `sp_gen_reporte_campana_prev_rev` | bdicobranza | D11 Cobr. | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Fórmula: campaña · número de cliente |
| `aclaraciones_edocta` | bdicred | D03 Créditos | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 185 |
| `aclaraciones_edocta_sif` | bdicred | D03 Créditos | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 185 |
| `aclaraciones_edoctacrd` | bdicred | D03 Créditos | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 185 |
| `aclaraciones_edoctacrd_sif` | bdicred | D03 Créditos | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 185 |
| `generaestadosdecuenta` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Criterios contables CNBV + GAT |
| `generaestadosdecuenta_repro` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Criterios contables CNBV + GAT |
| `pasecont_cobra_comision_apertura` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_calculo_tiir_pp` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Fórmula: comisión (CONDUSEF — debe estar en RECO) |
| `sp_comisionxapertura_contable_fin` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Cálculo con umbral/factor 12 |
| `sp_depura_edoctas_norevolventes` | bdicred | D03 Créditos | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_generar_aclaraciones_pl` | bdicred | D03 Créditos | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_obtenercomisionreposiciontarjeta` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_obtienecatanual_pdn` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos2` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos_2` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos_exp` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos_mib` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_consultasdos_pba` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_ofi_ticketmovtos` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_rep_men_increm_auto_acepynoacep` | bdicred | D03 Créditos | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LTOSF Art.17 |
| `sp_rep_men_increm_auto_apli` | bdicred | D03 Créditos | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LTOSF Art.17 |
| `sp_rep_men_increm_auto_cartven` | bdicred | D03 Créditos | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LTOSF Art.17 |
| `sp_rep_men_increm_auto_noapli` | bdicred | D03 Créditos | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | LTOSF Art.17 |
| `sp_tasaefectiva` | bdicred | D03 Créditos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Criterios contables CNBV + GAT |
| `sp_domi_procesararchivo32` | bdidomi | bdidomi | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_domi_procesararchivo36` | bdidomi | bdidomi | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_cnsif_aclaraciones` | bdinteg | D02 Integr. | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 1001 |
| `sp_cnsif_consprodcte_aclaraciones` | bdinteg | D02 Integr. | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 1001 |
| `sp_comisionreposicion` | bdinteg | D02 Integr. | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_comisionreposicion_web` | bdinteg | D02 Integr. | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_generaredoctaeje_factelect_pag` | bdinvers | bdinvers | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Criterios contables CNBV + GAT |
| `get_numcheque` | bdiofi | bdiofi | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Fórmula: importe |
| `sp_afore_cobrocomision` | bdiprog | bdiprog | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Let cmensaje = 'faltan parametros'; |
| `sp_afore_dispersion` | bdiprog | bdiprog | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_aplica_pago_con_cargo_msw` | bdisac | D05 Saldos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_aplica_pago_msw` | bdisac | D05 Saldos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_generaarchivocobranzacp` | bdisac | D05 Saldos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_generaarchivocobranzacp_pba` | bdisac | D05 Saldos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_generaarchivocobranzasuk` | bdisac | D05 Saldos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_genreporbenefrem` | bdisac | D05 Saldos | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Fórmula: fecha · monto |
| `sp_reporteremesascomision` | bdisac | D05 Saldos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Unload to |
| `sp_reporteremesascomision_pbajj` | bdisac | D05 Saldos | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Unload to |
| `sp_sac_consulta_ctesremesas` | bdisac | D05 Saldos | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Retorna código de error 10001 |
| `sp_sac_mc_dummy` | bdisac | D05 Saldos | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | RECA/SAC |
| `sp_genera_ostelrdo` | bdisolic | D06 Solic. | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Rm /home/syscobra/cat/ejecutascripts_sp_genera_ostelrdo.sql |
| `sp_generareportepp` | bdisolic | D06 Solic. | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_generareportepp_web` | bdisolic | D06 Solic. | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_calc_com` | bdispei | D08 SPEI | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_regordenctecte_exp1` | bdispei | D08 SPEI | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | // la cuenta ord. no se encuentra activa |
| `sp_regordenctecte_pba` | bdispei | D08 SPEI | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | // la cuenta ord. no se encuentra activa |
| `spei_realizacargo` | bdispei | D08 SPEI | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `spei_realizacargo_exp1` | bdispei | D08 SPEI | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_sorteo_sat` | bditarjeta | bditarjeta | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cat /resplogifx/sat_buenfin.unl >> /resplogifx/entregasat2017.txt |
| `sp_sorteo_sat2` | bditarjeta | bditarjeta | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cat /resplogifx/sat_buenfin.unl >> /resplogifx/bancoppel_sat1.txt |
| `sp_sorteo_sat2_600091693165` | bditarjeta | bditarjeta | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cat /resplogifx/sat_buenfin.unl >> /resplogifx/bancoppel_sat1_c2017.tx... |
| `sp_sorteo_sat3` | bditarjeta | bditarjeta | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cat /resplogifx/sat_buenfin.unl >> /resplogifx/bancoppel_sat2.txt |
| `sp_sorteo_sat_complemento_2017` | bditarjeta | bditarjeta | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cat /resplogifx/sat_buenfin.unl >> /resplogifx/entregasat2017.txt |
| `sp_sorteo_sat_pba` | bditarjeta | bditarjeta | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Cat /resplogifx/sat_buenfin.unl >> /resplogifx/entregasat2014.txt |
| `sp_consultarchequesdevueltos` | bditef | bditef | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_consultarchequesdevueltos2` | bditef | bditef | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_consultarchequesdevueltos3` | bditef | bditef | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `stgencont` | bditrans | bditrans | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | Calcula monto |
| `sp_transfer_genarch_svaincomming` | bditransfer | bditransfer | 1 | LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente) | Tfsvaincoming.unl | sed |
| `sp_genconadmin` | intercard | intercard | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_generaarchivoconciliacion` | intercard | intercard | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_generaarchivoconciliacion_pba` | intercard | intercard | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_geninfocomitmp` | intercard | intercard | 1 | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada e... | LTOSF Art.17 (CAT) + RECO |
| `sp_oper_corr_oxxo_eleven_aut` | intercard | intercard | 1 | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario | Cálculo con umbral/factor 01 |

> **Nota:** Los 237 SPs listados son candidatos obligatorios para el golden master de migración en el segmento CONDUSEF. Requieren test cases con datos de golden set regulatorio y validación cruzada con el SME regulatorio.

---

## IPAB

**89 SPs** con un total de **195 reglas** con anotación IPAB.

| SP | DB | Dominio | # Reglas reg. | Normas relevantes | Explicación |
|----|----|---------|--------------|--------------------|-------------|
| `sp_repipab_parte1` | bdinteg | D02 Integr. | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_parte10` | bdinteg | D02 Integr. | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_parte4` | bdinteg | D02 Integr. | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_parte5` | bdinteg | D02 Integr. | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_parte6` | bdinteg | D02 Integr. | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_parte7` | bdinteg | D02 Integr. | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_parte8` | bdinteg | D02 Integr. | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_parte9` | bdinteg | D02 Integr. | 8 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repchequesipab_temp` | bdinteg | D02 Integr. | 7 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repchequesipab_temp_esp` | bdinteg | D02 Integr. | 7 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repchequesipab_temp_esp2` | bdinteg | D02 Integr. | 7 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_direc_pte1` | bdinteg | D02 Integr. | 5 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_direc_pte2` | bdinteg | D02 Integr. | 5 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repipab_direc_pte3` | bdinteg | D02 Integr. | 5 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_ipab_prueba` | bdinteg | D02 Integr. | 4 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_repchequesipab` | bdinteg | D02 Integr. | 4 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LISR Art.54/135 |
| `sp_ipab` | bdinteg | D02 Integr. | 3 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Fórmula: conciliación de cheques · IPAB — Instituto para la Protección... |
| `sp_ipab_comp1` | bdinteg | D02 Integr. | 3 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Fórmula: conciliación de cheques · IPAB — Instituto para la Protección... |
| `sp_ipab_pagare` | bdinteg | D02 Integr. | 3 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Criterios contables CNBV + GAT |
| `sp_repinveripab` | bdinteg | D02 Integr. | 3 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Criterios contables CNBV + GAT |
| `sp_repipabinver` | bdinteg | D02 Integr. | 3 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Criterios contables CNBV + GAT |
| `sp_reppagaresipab` | bdinteg | D02 Integr. | 3 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Criterios contables CNBV + GAT |
| `sp_reppagaresipab_temp` | bdinteg | D02 Integr. | 3 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Criterios contables CNBV + GAT |
| `sp_ipab_consulta_usuario` | bdicnweb | D01 Canal | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Retorna código de error 1001 |
| `sp_ipab_repfideicomisomarcajeipab` | bdicnweb | D01 Canal | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LTOSF Art.17 (CAT) + RECO |
| `sp_actualiza_saldos_ipab` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Registros procesados: |
| `sp_capintafecha_ipab_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // cuenta no existe en fecha |
| `sp_compensa_saldos_ipab` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Registros procesados compensacion saldos: |
| `sp_ipab_actualiza_saldos` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Registros procesados: |
| `sp_ipab_comp10` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp11` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp12` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp13` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp14` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp15` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp16` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp17` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp18` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp19` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp2` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp20` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp3` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp4` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp5` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp6` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp7` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp8` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_comp9` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_compensa_saldos` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | Registros procesados compensacion saldos: |
| `sp_ipab_parte1` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte10` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte10_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte11` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte11_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte12` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte12_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte13` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte13_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte14_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte15_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte16` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte16_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte17` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte17_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte18` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte18_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte19` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte1_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte2` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte20` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte20_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte21` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte21_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte2_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte3` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte3_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte4` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte4_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte5` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte5_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte6` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte6_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte7` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte7_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte8` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte8_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte9` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_ipab_parte9_esp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | // valida parametros de entrada |
| `sp_repcredsipab_temp` | bdinteg | D02 Integr. | 1 | LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs ... | LPAB Art.22 |

> **Nota:** Los 89 SPs listados son candidatos obligatorios para el golden master de migración en el segmento IPAB. Requieren test cases con datos de golden set regulatorio y validación cruzada con el SME regulatorio.

---

## SAT

**88 SPs** con un total de **191 reglas** con anotación SAT.

| SP | DB | Dominio | # Reglas reg. | Normas relevantes | Explicación |
|----|----|---------|--------------|--------------------|-------------|
| `sp_genera_reporte_tc_inactivas` | bdicred | D03 Créditos | 10 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LIVA |
| `sp_genera_reporte_tc_inactivas_pba` | bdicred | D03 Créditos | 10 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LIVA |
| `sp_generaredoctaeje_factelect_esp` | bdicheq | D04 Cheques | 5 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_calcsdo_ctasinactivas` | bdicheq | D04 Cheques | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LIVA — IVA sobre comisiones (16% / 8% frontera) | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_cuenta` | bdicheq | D04 Cheques | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_esp_pru` | bdicheq | D04 Cheques | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelectxcuenta` | bdicheq | D04 Cheques | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repchequesipab_temp` | bdinteg | D02 Integr. | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repchequesipab_temp_esp` | bdinteg | D02 Integr. | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repchequesipab_temp_esp2` | bdinteg | D02 Integr. | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_transfer` | bditransfer | bditransfer | 4 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `calc_isr` | bdicheq | D04 Cheques | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `cargo_ref_cel_pba` | bdicheq | D04 Cheques | 3 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Rrg se modifica para el proyecto de circular 22/2010 comisiones atm 26... |
| `sp_calcsdoctainactiva` | bdicheq | D04 Cheques | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_calculaintaclaraciones` | bdicheq | D04 Cheques | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | RECA/SAC |
| `sp_generaredoctaeje_factelect` | bdicheq | D04 Cheques | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp1` | bdicheq | D04 Cheques | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp2` | bdicheq | D04 Cheques | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp3` | bdicheq | D04 Cheques | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp4` | bdicheq | D04 Cheques | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_generaredoctaeje_factelect_comp5` | bdicheq | D04 Cheques | 3 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_nominaconsultasaldoeje` | bdicheq | D04 Cheques | 3 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LTOSF Art.17 (CAT) + RECO |
| `cargo_ref_cel_pba_sfsa` | bdicred | D03 Créditos | 3 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Rrg se modifica para el proyecto de circular 22/2010 comisiones atm 26... |
| `sp_recuperacion_saldos` | bdiaclaracion | D07 Aclar. | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | No se realizó la afectación de comision/iva. |
| `calc_isr_proy` | bdicheq | D04 Cheques | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_blqdesconcentractasinactivas` | bdicheq | D04 Cheques | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LIVA |
| `sp_cons_cap_cfdi_bpi` | bdicheq | D04 Cheques | 2 | CFDI/Retenciones bancarias — folio fiscal por transacción de... | - valida que el cliente no sea blanco |
| `sp_corrige_isr` | bdicheq | D04 Cheques | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_dispercionnomina_bpi` | bdicheq | D04 Cheques | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LTOSF Art.17 (CAT) + RECO |
| `sp_dispercionnominaautomatico` | bdicheq | D04 Cheques | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LTOSF Art.17 (CAT) + RECO |
| `sp_dispercionnominaautomatico_pba` | bdicheq | D04 Cheques | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LTOSF Art.17 (CAT) + RECO |
| `sp_gen_isr_cfdi_sdo` | bdicheq | D04 Cheques | 2 | CFDI/Retenciones bancarias — folio fiscal por transacción de... | CFDI/Retenciones bancarias |
| `sp_reportactasinactivas` | bdicheq | D04 Cheques | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Fórmula: conciliación de cheques |
| `generaedosctacrd_pp` | bdicred | D03 Créditos | 2 | CFDI/Retenciones bancarias — folio fiscal por transacción de... | CFDI/Retenciones bancarias |
| `generaestadosdecuenta` | bdicred | D03 Créditos | 2 | CFDI/Retenciones bancarias — folio fiscal por transacción de... | Criterios contables CNBV + GAT |
| `sp_pagopp_quitacondona` | bdicred | D03 Créditos | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | CUB CNBV |
| `sp_domi_consulta_autorizacionesactivas` | bdidomi | bdidomi | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Parametros de entrada estan en blanco. |
| `sp_ipab_prueba` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repchequesipab` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_direc_pte1` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_direc_pte2` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_direc_pte3` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_parte1` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_parte10` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_parte4` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_parte5` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_parte6` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_parte7` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_parte8` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_repipab_parte9` | bdinteg | D02 Integr. | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `cierreinv` | bdinvers | bdinvers | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | Criterios contables CNBV + GAT |
| `cierreinv_28102009` | bdinvers | bdinvers | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | Criterios contables CNBV + GAT |
| `cierreinv_pba` | bdinvers | bdinvers | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | Criterios contables CNBV + GAT |
| `cierreinv_tmp` | bdinvers | bdinvers | 2 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | Criterios contables CNBV + GAT |
| `sp_calcula_comisiones` | bdisac | D05 Saldos | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | - se calcula el iva del convenio de acuerdo a la comisión |
| `sp_calcula_comisiones_pba` | bdisac | D05 Saldos | 2 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LTOSF Art.17 (CAT) + RECO |
| `sp_soe_cargarreversarcuentatoken` | bdibei | bdibei | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Error en la ejecucion del sp reversion |
| `sp_soe_cargarreversarcuentatokenreenvio` | bdibei | bdibei | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Error en la ejecucion del sp reversion |
| `abono_ctas_ivas` | bdicheq | D04 Cheques | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Load from /resplogifx/conciliachq/ivasxabonar.unl delimiter |
| `sp_cancelactasinactivas` | bdicheq | D04 Cheques | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Fórmula: conciliación de cheques |
| `sp_dispercionnominamanual` | bdicheq | D04 Cheques | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LTOSF Art.17 (CAT) + RECO |
| `sp_nominatotalivacomision` | bdicheq | D04 Cheques | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LTOSF Art.17 (CAT) + RECO |
| `sp_nominatotalivacomision_bpi` | bdicheq | D04 Cheques | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LTOSF Art.17 (CAT) + RECO |
| `sp_procsdesconcentracionctasmasivas` | bdicheq | D04 Cheques | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Error en la ejecucion del sp bdicheq:sp_blqdesconcentractasinactivas |
| `sp_regordenctecte` | bdicheq | D04 Cheques | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | // la cuenta ord. no se encuentra activa |
| `sp_regordenctecte_web` | bdicheq | D04 Cheques | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | // la cuenta ord. no se encuentra activa |
| `sp_cla_consdetallelistasnegativas` | bdicnweb | D01 Canal | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Retorna código de error 1001 |
| `sp_sac_reportedetalletransucursal` | bdicnweb | D01 Canal | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Secuencia |
| `sp_repcob_cdadcampcat` | bdicobranza | D11 Cobr. | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | LIVA |
| `apercred1_pp_domicilia_web` | bdicred | D03 Créditos | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Criterios contables CNBV + GAT |
| `apercred1_pp_web` | bdicred | D03 Créditos | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Criterios contables CNBV + GAT |
| `cons_saldo_cel` | bdicred | D03 Créditos | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Calcula IVA (impuesto — SAT) |
| `generaedosctacrd` | bdicred | D03 Créditos | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Cálculo con umbral/factor 360 |
| `movimientos_edoctacrd` | bdicred | D03 Créditos | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Fórmula: pago · cargo / débito |
| `movimientos_edoctacrd_web` | bdicred | D03 Créditos | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Fórmula: pago · cargo / débito |
| `sp_ce_aplicapago` | bdicred | D03 Créditos | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Pago linea/credito emp: |
| `sp_geninsumos_calif_parte` | bdicred | D03 Créditos | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Criterios contables CNBV + GAT |
| `sp_consctemttorfcalterno_cfdi` | bdinteg | D02 Integr. | 1 | CFDI/Retenciones bancarias — folio fiscal por transacción de... | Return ccodret,'','','','','','','','','','',''; |
| `apertura` | bdinvers | bdinvers | 1 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | Criterios contables CNBV + GAT |
| `apertura_app` | bdinvers | bdinvers | 1 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | Criterios contables CNBV + GAT |
| `calc_isr` | bdinvers | bdinvers | 1 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `conprev1` | bdinvers | bdinvers | 1 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | Criterios contables CNBV + GAT |
| `conprev1_web` | bdinvers | bdinvers | 1 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | Criterios contables CNBV + GAT |
| `sp_renuevapagares_19022014` | bdinvers | bdinvers | 1 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |
| `sp_pago_servicios_gdf` | bdisac | D05 Saldos | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | Calculo iva de convenio |
| `sp_regordenctecte_exp1` | bdispei | D08 SPEI | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | // la cuenta ord. no se encuentra activa |
| `sp_regordenctecte_pba` | bdispei | D08 SPEI | 1 | LIVA — IVA sobre comisiones (16% / 8% frontera) | // la cuenta ord. no se encuentra activa |
| `sp_generaredoctaeje_factelect_transfer_esp` | bditransfer | bditransfer | 1 | LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 =... | LISR Art.54/135 |

> **Nota:** Los 88 SPs listados son candidatos obligatorios para el golden master de migración en el segmento SAT. Requieren test cases con datos de golden set regulatorio y validación cruzada con el SME regulatorio.

---

## Banxico

**34 SPs** con un total de **52 reglas** con anotación Banxico.

| SP | DB | Dominio | # Reglas reg. | Normas relevantes | Explicación |
|----|----|---------|--------------|--------------------|-------------|
| `spei_pasemovspeich_2` | bdispei | D08 SPEI | 4 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | SPEI Reglas técnicas |
| `spei_actualizamovspeich` | bdispei | D08 SPEI | 3 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Cálculo con umbral/factor 2500 |
| `spei_devcodi` | bdispei | D08 SPEI | 3 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | SPEI Reglas técnicas |
| `spei_pasemovspeich` | bdispei | D08 SPEI | 3 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Cálculo con umbral/factor 2500 |
| `sp_genrep_cons_spei_aud` | bdicnweb | D01 Canal | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Error en la ejecucion del bdinteg:sp_cons_spei_aud |
| `sp_regordenpagospei_pp` | bdispei | D08 SPEI | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | SPEI Reglas técnicas |
| `spei_actualizamovspeich_2` | bdispei | D08 SPEI | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Load from /home/sysspei/detspeich |
| `spei_calculointeres` | bdispei | D08 SPEI | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Cálculo con umbral/factor 518400 |
| `spei_calculointeres_pba` | bdispei | D08 SPEI | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Cálculo con umbral/factor 518400 |
| `spei_concilia_cargos_ef` | bdispei | D08 SPEI | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Fórmula: conciliación de cheques |
| `spei_concilia_cargos_ef_exp` | bdispei | D08 SPEI | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Fórmula: conciliación de cheques |
| `spei_recordenpago` | bdispei | D08 SPEI | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | SPEI Reglas técnicas |
| `spei_recordenpago_ws` | bdispei | D08 SPEI | 2 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | SPEI Reglas técnicas |
| `spei_ctaspropiasdevcodi` | bdicheq | D04 Cheques | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Retorna código de error 549 |
| `sp_cg_actbancont` | bdicnweb | D01 Canal | 1 | SPEI — confirmación bancos operadores; extemporáneo > 17:30 | Error en la ejecucion del sp bdispei:sp_actbancont |
| `sp_rem_submitpayreversal` | bdicnweb | D01 Canal | 1 | Circular 14/2017 — Notificación fallos remesas; max_retries ... | Error en la ejecucion del sp bdisac:sp_app_submitpayreversal |
| `sp_rem_validaprocesosappriza` | bdicnweb | D01 Canal | 1 | Circular 14/2017 — Notificación fallos remesas; max_retries ... | Error en la ejecución del sp bdisac:sp_app_valdigito |
| `sp_traspasoctabeneficencia` | bdicnweb | D01 Canal | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Art.61 LIC |
| `sp_domi_valida_cuentatarjeta` | bdidomi | bdidomi | 1 | Circular Banxico — formato CLABE 18 dígitos (validación algo... | Se valida el parametro de entrada |
| `sp_domi_valida_cuentatarjeta_ob` | bdidomi | bdidomi | 1 | Circular Banxico — formato CLABE 18 dígitos (validación algo... | Se valida el parametro de entrada |
| `sp_aforearchconfob` | bdiprog | bdiprog | 1 | Circular Banxico — formato CLABE 18 dígitos (validación algo... | Errores |
| `sp_aforegenerararchivodeconfirmaciondepagos` | bdiprog | bdiprog | 1 | Circular Banxico — formato CLABE 18 dígitos (validación algo... | -------------------errores |
| `sp_app_confirmpayment` | bdisac | D05 Saldos | 1 | Circular 14/2017 — Notificación fallos remesas; max_retries ... | Retorna código de error 1100 |
| `sp_consultasucursalappriza` | bdisac | D05 Saldos | 1 | Circular 14/2017 — Notificación fallos remesas; max_retries ... | Retorna código de error 99999 |
| `sp_alertacargospei_exp1` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Load from /resplogifx/conciliachq/ordenes_pago_spei.txt insert into ca... |
| `sp_alertacargospei_pba` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Load from /resplogifx/conciliachq/ordenes_pago_spei.txt insert into ca... |
| `sp_regordenpagospei_exp1` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | SPEI Reglas técnicas |
| `spei_actualizamovspeich_esp` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Load from /home/sysspei/detspeich |
| `spei_actualizamovspeich_tmp` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Fórmula: conciliación de cheques |
| `spei_apgbanope` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Retorna código de error 11110 |
| `spei_encbanope` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Retorna código de error 11110 |
| `spei_pasemovspeich_esp` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | Load from /home/sysspei/movspeich |
| `spei_realizacargo` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | LTOSF Art.17 (CAT) + RECO |
| `spei_realizacargo_exp1` | bdispei | D08 SPEI | 1 | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, venta... | LTOSF Art.17 (CAT) + RECO |

> **Nota:** Los 34 SPs listados son candidatos obligatorios para el golden master de migración en el segmento Banxico. Requieren test cases con datos de golden set regulatorio y validación cruzada con el SME regulatorio.

---

## TESOFE

**16 SPs** con un total de **22 reglas** con anotación TESOFE.

| SP | DB | Dominio | # Reglas reg. | Normas relevantes | Explicación |
|----|----|---------|--------------|--------------------|-------------|
| `sp_afore_dispersion` | bdiprog | bdiprog | 4 | LTF — dispersión de recursos federales (pensiones, becas, ap... | LTOSF Art.17 (CAT) + RECO |
| `sp_dispersionnominavalidacionestatus` | bdicheq | D04 Cheques | 2 | LTF — dispersión de recursos federales (pensiones, becas, ap... | Retorna código de error 805 |
| `sp_dispersionnominavalidacionestatus_bpi` | bdicheq | D04 Cheques | 2 | LTF — dispersión de recursos federales (pensiones, becas, ap... | Retorna código de error 805 |
| `sp_aforedispersionautomatica` | bdiprog | bdiprog | 2 | LTF — dispersión de recursos federales (pensiones, becas, ap... | Dsb 12/03/2014 |
| `sp_concilia_donativos_becalos` | bdicheq | D04 Cheques | 1 | LTF — dispersión de recursos federales (pensiones, becas, ap... | Transaccion|cuenta|folio|fecha|monto|transaccion|cuenta|folio|fecha|mo... |
| `sp_conciliaciondispersionnomina_his` | bdicheq | D04 Cheques | 1 | LTF — dispersión de recursos federales (pensiones, becas, ap... | Retorna código de error 110 |
| `sp_dispersionlinea_bei` | bdicheq | D04 Cheques | 1 | LTF — dispersión de recursos federales (pensiones, becas, ap... | LTF |
| `sp_dispersionlinea_bpi` | bdicheq | D04 Cheques | 1 | LTF — dispersión de recursos federales (pensiones, becas, ap... | LTF |
| `sp_dispersionlinea_bpi_pba2` | bdicheq | D04 Cheques | 1 | LTF — dispersión de recursos federales (pensiones, becas, ap... | CUB B-5 |
| `sp_dispersionnominatransacciones` | bdicheq | D04 Cheques | 1 | LTF — dispersión de recursos federales (pensiones, becas, ap... | Retorna código de error 840 |
| `sp_cg_cattipoconcentracion` | bdicnweb | D01 Canal | 1 | LTF — concentración/dispersión fondos gobierno; conciliación... | Retorna código de error 1001 |
| `sp_cg_conslistasolicitudesconcentracion` | bdicnweb | D01 Canal | 1 | LTF — concentración/dispersión fondos gobierno; conciliación... | Retorna código de error 1001 |
| `sp_cg_detallealtatipoconcentracion` | bdicnweb | D01 Canal | 1 | LTF — concentración/dispersión fondos gobierno; conciliación... | Retorna código de error 1001 |
| `sp_cg_detallebajatipoconcentracion` | bdicnweb | D01 Canal | 1 | LTF — concentración/dispersión fondos gobierno; conciliación... | Retorna código de error 1001 |
| `sp_cg_detallebitacoratipoconcentracion` | bdicnweb | D01 Canal | 1 | LTF — concentración/dispersión fondos gobierno; conciliación... | Retorna código de error 1001 |
| `sp_dispersionafore` | bdicnweb | D01 Canal | 1 | LTF — dispersión de recursos federales (pensiones, becas, ap... | Error en la ejecuciãn del sp bdiprog:sp_validahoraejec |

> **Nota:** Los 16 SPs listados son candidatos obligatorios para el golden master de migración en el segmento TESOFE. Requieren test cases con datos de golden set regulatorio y validación cruzada con el SME regulatorio.

---

## SPs con Múltiples Reguladores

Los siguientes 139 SPs tienen anotaciones de más de un organismo regulador — son de máxima prioridad para el golden master.

| SP | DB | # Reguladores | Reguladores | # Reglas reg. |
|----|----|-----------|--------------|---------|
| `generaestadosdecuenta` | bdicred | 3 | CNBV, CONDUSEF, SAT | 19 |
| `apercred1_pp_domicilia_web` | bdicred | 3 | CNBV, CONDUSEF, SAT | 10 |
| `apercred1_pp_web` | bdicred | 3 | CNBV, CONDUSEF, SAT | 10 |
| `sp_repipab_parte1` | bdinteg | 3 | CNBV, IPAB, SAT | 8 |
| `sp_repipab_parte10` | bdinteg | 3 | CNBV, IPAB, SAT | 8 |
| `sp_repipab_parte4` | bdinteg | 3 | CNBV, IPAB, SAT | 8 |
| `sp_repipab_parte5` | bdinteg | 3 | CNBV, IPAB, SAT | 8 |
| `sp_repipab_parte6` | bdinteg | 3 | CNBV, IPAB, SAT | 8 |
| `sp_repipab_parte7` | bdinteg | 3 | CNBV, IPAB, SAT | 8 |
| `sp_repipab_parte8` | bdinteg | 3 | CNBV, IPAB, SAT | 8 |
| `sp_repipab_parte9` | bdinteg | 3 | CNBV, IPAB, SAT | 8 |
| `sp_calculaintaclaraciones` | bdicheq | 3 | CNBV, CONDUSEF, SAT | 7 |
| `sp_nominaconsultasaldoeje` | bdicheq | 3 | CNBV, CONDUSEF, SAT | 7 |
| `sp_repchequesipab_temp` | bdinteg | 3 | CNBV, IPAB, SAT | 7 |
| `sp_repchequesipab_temp_esp` | bdinteg | 3 | CNBV, IPAB, SAT | 7 |
| `sp_repchequesipab_temp_esp2` | bdinteg | 3 | CNBV, IPAB, SAT | 7 |
| `sp_generaredoctaeje_factelect_transfer` | bditransfer | 3 | CNBV, CONDUSEF, SAT | 6 |
| `cargo_ref_cel_pba` | bdicheq | 3 | CNBV, CONDUSEF, SAT | 5 |
| `cargo_ref_cel_pba_sfsa` | bdicred | 3 | CNBV, CONDUSEF, SAT | 5 |
| `sp_repipab_direc_pte1` | bdinteg | 3 | CNBV, IPAB, SAT | 5 |
| `sp_repipab_direc_pte2` | bdinteg | 3 | CNBV, IPAB, SAT | 5 |
| `sp_repipab_direc_pte3` | bdinteg | 3 | CNBV, IPAB, SAT | 5 |
| `sp_generaredoctaeje_factelect` | bdicheq | 3 | CNBV, CONDUSEF, SAT | 4 |
| `sp_ipab_prueba` | bdinteg | 3 | CNBV, IPAB, SAT | 4 |
| `sp_repchequesipab` | bdinteg | 3 | CNBV, IPAB, SAT | 4 |
| `sp_generaredoctaeje_factelect_transfer_esp` | bditransfer | 3 | CNBV, CONDUSEF, SAT | 3 |
| `sp_mueve_aclaraciones_historico` | bdiaclaracion | 2 | CNBV, CONDUSEF | 107 |
| `sp_genera_cintas_semanales` | bdiburo | 2 | CNBV, CONDUSEF | 16 |
| `sp_genera_cintas_semanales_clon` | bdiburo | 2 | CNBV, CONDUSEF | 16 |
| `sp_genera_cintas_semanales_cnr` | bdiburo | 2 | CNBV, CONDUSEF | 16 |
| `sp_burofisicas_cortos_cnr` | bdiburo | 2 | CNBV, CONDUSEF | 12 |
| `generaestadosdecuenta_repro` | bdicred | 2 | CNBV, CONDUSEF | 12 |
| `sp_tasaefectiva` | bdicred | 2 | CNBV, CONDUSEF | 11 |
| `sp_burofisicas_cortos` | bdiburo | 2 | CNBV, CONDUSEF | 10 |
| `sp_genera_reporte_tc_inactivas` | bdicred | 2 | CNBV, SAT | 10 |
| `sp_genera_reporte_tc_inactivas_pba` | bdicred | 2 | CNBV, SAT | 10 |
| `sp_geninsumos_calif_parte` | bdicred | 2 | CNBV, SAT | 10 |
| `sp_burofisicas_cortos_clon` | bdiburo | 2 | CNBV, CONDUSEF | 9 |
| `sp_burofisicas_cortos_nov19` | bdiburo | 2 | CNBV, CONDUSEF | 9 |
| `sp_burofisicas_cortos_pbajj` | bdiburo | 2 | CNBV, CONDUSEF | 9 |
| `sp_ics_genera_layouts_hilos` | bdicred | 2 | CNBV, CONDUSEF | 9 |
| `generaedosctacrd_pp` | bdicred | 2 | CNBV, SAT | 8 |
| `sp_obtensolicitudmaquilatdc` | bdisolic | 2 | CNBV, CONDUSEF | 8 |
| `sp_obtensolicitudmaquilatdc_nom` | bdisolic | 2 | CNBV, CONDUSEF | 8 |
| `sp_obtensolicitudmaquilatdc_web` | bdisolic | 2 | CNBV, CONDUSEF | 8 |
| `sp_reportediarioacl` | bdiaclaracion | 2 | CNBV, CONDUSEF | 7 |
| `sp_reportediarioacl_2day` | bdiaclaracion | 2 | CNBV, CONDUSEF | 7 |
| `sp_traspasoctabeneficencia` | bdicnweb | 2 | Banxico, CNBV | 7 |
| `burofisicas_concilia` | bdiburo | 2 | CNBV, CONDUSEF | 6 |
| `burofisicas_concilia_clon` | bdiburo | 2 | CNBV, CONDUSEF | 6 |
| _(+89 más)_ | | | | |

