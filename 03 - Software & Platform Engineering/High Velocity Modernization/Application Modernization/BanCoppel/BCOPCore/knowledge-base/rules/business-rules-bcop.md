# BCOPCore · Catálogo de Reglas de Negocio — v2.2

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Enrichment  
> **Generado:** 2026-08-02 · `enrich-rules.py` · 7,784 reglas · 6,247 con explicación  
> **Anclaje:** vocabulario 787 términos · callgraph 34,279 edges · 12,832 SPs escaneados  
> **Fuente primaria:** `business-rules-v2.json` (v2.2) — este MD es resumen navegable y auditable  

## Resumen ejecutivo

| Tipo | Reglas | Con explicación |
|----|---:|---:|
| FÓRMULA | 4,596 | 3,432 |
| VALIDACIÓN | 2,919 | 2,765 |
| UMBRAL | 241 | 49 |
| ESTADO | 28 | 1 |
| **TOTAL** | **7,784** | **6,247** |

| Dimensión | Valor |
|---|---|
| SPs escaneados | 12,832 |
| Reglas con impacto regulatorio | 2,443 |
| Reglas con riesgo de equivalencia | 553 |
| Reglas con SP relacionado en callgraph | 2,793 |

## Reguladores

| Regulador | Reglas |
|---|---:|
| **CNBV** | 1,704 |
| **Banxico** | 52 |
| **CONDUSEF** | 624 |
| **SAT** | 191 |
| **TESOFE** | 22 |
| **IPAB** | 195 |

## Categorías de segmentación

| Categoría | Reglas |
|---|---:|
| CALCULO_FINANCIERO | 2,498 |
| REGULATORIO | 2,443 |
| OPERACIONAL | 1,697 |
| PARAMETRIA | 455 |
| RIESGO_CREDITO | 320 |
| PAGOS_TRANSFERENCIAS | 172 |
| CONTABILIDAD_REPORTES | 126 |
| FLUJO_OPERATIVO | 53 |
| ATENCION_CLIENTE | 20 |

---

## Explicaciones de negocio — Fórmulas críticas con riesgo de equivalencia

> Solo se muestran reglas donde la explicación tiene confianza **literal** o **formula**.
> Estas son las más importantes para el golden master de migración.

| ID | SP | Dominio | BC | Explicación | Riesgo equiv. | SPs relacionados |
|----|----|----|---|---|---|---|
| BR-V2-0006 | `sp_acl_validarpreguntasiniciosesion` | D07 Aclar. | — | Cálculo con umbral/factor 365.25 | base 365 — verificar vs 360 |  |
| BR-V2-0305 | `sp_random` | bdibpi | — | Cálculo con umbral/factor 65536 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0316 | `burofisicas_cnr` | bdiburo | — | LRSIC | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-0318 | `burofisicas_cnr_pba` | bdiburo | — | LRSIC | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-0365 | `sp_burofisicas_cortos_cnr` | bdiburo | — | Cálculo con umbral/factor 30.4 | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-0367 | `sp_burofisicas_cortos_cnr` | bdiburo | — | LRSIC | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-0506 | `arr_intacum` | D04 Cheques | — | Cálculo con umbral/factor 04 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0508 | `arr_invcrec_12262009` | D04 Cheques | — | Cálculo con umbral/factor 025 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0509 | `arr_pagaint` | D04 Cheques | — | Cálculo con umbral/factor 04 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0521 | `arrpagoint_18082010` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0535 | `calc_int` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0538 | `calc_interes` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0540 | `calc_isr` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0541 | `calc_isr` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0542 | `calc_isr` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0544 | `calc_isr_proy` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0545 | `calc_isr_proy` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0582 | `cargo_comisiones_pba` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-0583 | `cargo_comisiones_pba` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0586 | `cargo_comisiones_per` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-0587 | `cargo_comisiones_per` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0590 | `cargo_comisiones_per_web` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-0591 | `cargo_comisiones_per_web` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0594 | `cargo_comisiones_web` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-0595 | `cargo_comisiones_web` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-0928 | `histsbg` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0929 | `histsbg` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0932 | `histsbg` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0933 | `histsbg` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0936 | `inicio_mes` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0941 | `inicio_mes_esp` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-0953 | `mod_ctaefecplus` | D04 Cheques | — | Cálculo con umbral/factor 075 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-1116 | `sp_calcsdo_ctasinactivas` | D04 Cheques | — | Cálculo con umbral/factor 365 | base 365 — verificar vs 360 |  |
| BR-V2-1117 | `sp_calcsdo_ctasinactivas` | D04 Cheques | — | Cálculo con umbral/factor 365 | base 365 — verificar vs 360; TRUNC — Informix trunca; Postgr |  |
| BR-V2-1118 | `sp_calcsdo_ctasinactivas` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1119 | `sp_calcsdo_ctasinactivas` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1120 | `sp_calcsdoctainactiva` | D04 Cheques | — | Cálculo con umbral/factor 365 | base 365 — verificar vs 360 |  |
| BR-V2-1121 | `sp_calcsdoctainactiva` | D04 Cheques | — | Cálculo con umbral/factor 365 | base 365 — verificar vs 360; TRUNC — Informix trunca; Postgr |  |
| BR-V2-1122 | `sp_calcsdoctainactiva` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1123 | `sp_calcsdoctainactiva` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1129 | `sp_calculagat` | D04 Cheques | `BC-3.3` | Fórmula: periodo · tasa (de interés) (conversión porcentual (÷100)) | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1130 | `sp_calculagat` | D04 Cheques | `BC-3.3` | Fórmula: periodo · tasa (de interés) (conversión porcentual (÷100)) | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1133 | `sp_calculagat_morales` | D04 Cheques | — | CUB CNBV | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1137 | `sp_calculaintaclaraciones` | D04 Cheques | — | Cálculo con umbral/factor 360 | base 360 (año comercial) — verificar vs 365 |  |
| BR-V2-1138 | `sp_calculaintaclaraciones` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1139 | `sp_calculaintaclaraciones` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1140 | `sp_calculaintaclaraciones` | D04 Cheques | — | LISR Art.54/135 | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1149 | `sp_cap_recalculagat1200` | D04 Cheques | — | Criterios contables CNBV + GAT | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1187 | `sp_cargoxcomision_pm` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1188 | `sp_cargoxcomision_pm` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1193 | `sp_cargoxcomision_pm_comp2` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1194 | `sp_cargoxcomision_pm_comp2` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1199 | `sp_cargoxcomision_pm_esp` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1200 | `sp_cargoxcomision_pm_esp` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1205 | `sp_cargoxcomision_pmcomp` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1206 | `sp_cargoxcomision_pmcomp` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1210 | `sp_cobra_com` | D04 Cheques | — | Cálculo con umbral/factor 10 | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1220 | `sp_cobracominactividad` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |
| BR-V2-1221 | `sp_cobracominactividad` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | TRUNC — Informix trunca; PostgreSQL puede redondear (diverge |  |
| BR-V2-1233 | `sp_concilia_seguro_atm` | D04 Cheques | — | LTOSF Art.17 (CAT) + RECO | ROUND — validar modo (banker's vs half-up) |  |

---

## Explicaciones por categoría — muestra representativa

### REGULATORIO — muestra (12 de 2,443)

| ID | Tipo | SP | Explicación | Vocab relacionado |
|----|------|----|-------------|-------------------|
| BR-V2-0002 | FÓRMULA | `sp_acl_reporte_log` | RECA/SAC | — |
| BR-V2-0008 | VALIDACIÓN | `sp_cargoxajuste_debcred` | Intento de cargo con crédito vencido "bt" y bloqueado | cargo (cargo / débito) |
| BR-V2-0009 | VALIDACIÓN | `sp_cargoxajuste_debcred` | Intento de cargo con crédito vencido "bt" y bloqueado | cargo (cargo / débito) |
| BR-V2-0014 | FÓRMULA | `sp_cierres_masivos_afectacion` | File /resplogifx/repaclaraciones/ | aclaracion (aclaración bancaria — proceso ) |
| BR-V2-0015 | FÓRMULA | `sp_cierres_masivos_afectacion` | Insert into | aclaracion (aclaración bancaria — proceso ) |
| BR-V2-0016 | FÓRMULA | `sp_cierres_masivos_afectacion` | Chmod 777 /resplogifx/repaclaraciones/aclaracion.sql | aclaracion (aclaración bancaria — proceso ) |
| BR-V2-0017 | FÓRMULA | `sp_cierres_masivos_afectacion` | Fórmula: aclaración bancaria — proceso de disputa o reclamación d | aclaracion (aclaración bancaria — proceso ) |
| BR-V2-0018 | FÓRMULA | `sp_cierres_masivos_afectacion` | Rm /resplogifx/repaclaraciones/aclaracion.sql | aclaracion (aclaración bancaria — proceso ) |
| BR-V2-0019 | FÓRMULA | `sp_cierres_masivos_afectacion` | Rm /resplogifx/repaclaraciones/ | — |
| BR-V2-0020 | FÓRMULA | `sp_consulta_aclaraciones_producto_cliente_2` | RECA/SAC | — |
| BR-V2-0021 | FÓRMULA | `sp_consulta_aclaraciones_producto_cliente_2` | RECA/SAC | — |
| BR-V2-0022 | FÓRMULA | `sp_consulta_recuperacion` | LTOSF Art.17 (CAT) + RECO | — |

### CALCULO_FINANCIERO — muestra (12 de 2,498)

| ID | Tipo | SP | Explicación | Vocab relacionado |
|----|------|----|-------------|-------------------|
| BR-V2-0004 | FÓRMULA | `sp_acl_valida_dfa_devo` | Devolucion | devolucion (devuelve) |
| BR-V2-0005 | FÓRMULA | `sp_acl_valida_dfa_devo` | Fórmula: cantidad · cuenta · procede | cantidad (cantidad); cuenta (cuenta); procede (procede) |
| BR-V2-0006 | FÓRMULA | `sp_acl_validarpreguntasiniciosesion` | Cálculo con umbral/factor 365.25 | — |
| BR-V2-0028 | FÓRMULA | `sp_fal_busca_creditos_cat` | And fecha_ingreso between to_date ( | fechafinal (fecha final); fechainicial (fecha inicial) |
| BR-V2-0030 | FÓRMULA | `sp_integracion_cuenta` | Fórmula: tarjeta · procede · concepto de pago | tarjeta (tarjeta); procede (procede); concepto (concepto de  |
| BR-V2-0163 | FÓRMULA | `sp_reporte_acl_aud` | Fórmula: tarjeta · evento/notificación · analista | tarjeta (tarjeta); evento (evento/notificación); analista (a |
| BR-V2-0164 | FÓRMULA | `sp_reporte_acl_aud` | Unload to /resplogifx/reportesaud/reporteaclaud.unl | analista (analista) |
| BR-V2-0165 | FÓRMULA | `sp_reporte_atm_acl_extra` | Fórmula: teléfono · secuencia · evento/notificación | telefono (teléfono); secuencia (secuencia); evento (evento/n |
| BR-V2-0169 | FÓRMULA | `sp_reporte_diario_cat` | Select * from acl_reporte_reporte_diario_cat | — |
| BR-V2-0213 | FÓRMULA | `sp_upd_debrecuperacion` | Cálculo con umbral/factor 16 | — |
| BR-V2-0217 | FÓRMULA | `sp_generar_arch_cta_nom` | Movimientos_cta_nom.unl > | — |
| BR-V2-0218 | FÓRMULA | `sp_generar_arch_mov_spei` | Movimientos_spei.unl > | — |

### CONTABILIDAD_REPORTES — muestra (12 de 126)

| ID | Tipo | SP | Explicación | Vocab relacionado |
|----|------|----|-------------|-------------------|
| BR-V2-2103 | VALIDACIÓN | `sp_cnsif_consdetallemovimientos_totales` | Error en la ejecucion del sp bdinteg:sp_cnsif_consultatotalmovtos | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2107 | VALIDACIÓN | `sp_cnsif_genarch_aumlimcred_mc` | Error en la ejecucion del sp bdimnsj:sp_registra_evento | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2112 | VALIDACIÓN | `sp_cnsif_genarchmovimientos` | Error en la ejecucion del sp bdimnsj:sp_registra_evento | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2115 | VALIDACIÓN | `sp_cnsif_genarchmovimientos2` | Error en la ejecucion del sp bdimnsj:sp_registra_evento | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2116 | VALIDACIÓN | `sp_cnsif_genarchmovimientos_masivo` | Error en la ejecucion del sp bdicnweb:sp_cnsif_consdetallemovimie | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2117 | VALIDACIÓN | `sp_cnsif_genarchmovimientos_masivo` | Error en la ejecucion del sp bdicnweb:sp_cnsif_genarchmovimientos | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2119 | VALIDACIÓN | `sp_cnsif_genarchprocesosucursal` | Error en la ejecucion del sp bdimnsj:sp_registra_evento | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2120 | VALIDACIÓN | `sp_cnsif_genreportes_aumlimcred_mc` | Error en la ejecucion del sp bdicnweb:sp_consultagralautaumlincre | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2121 | VALIDACIÓN | `sp_cnsif_genreportes_aumlimcred_mc` | Error en la ejecucion del sp bdicnweb:sp_cnsif_genarch_aumlimcred | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2617 | VALIDACIÓN | `sp_fc_bloqueactas` | Error en la ejecucion del sp bdinteg:sp_bloqueactas | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2618 | VALIDACIÓN | `sp_fc_conscliente` | Error en la ejecucion del sp bdinteg:sp_fuscte_conscte | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2619 | VALIDACIÓN | `sp_fc_consctesdesb` | Error en la ejecucion del sp bdinteg:sp_desbctasfus_conscte | ejecucion (ejecución (de proceso)); error (error) |

### PAGOS_TRANSFERENCIAS — muestra (12 de 172)

| ID | Tipo | SP | Explicación | Vocab relacionado |
|----|------|----|-------------|-------------------|
| BR-V2-1091 | VALIDACIÓN | `sp_aplicaaclaradebito` | Fondos insuficientes dã©bito | — |
| BR-V2-1092 | VALIDACIÓN | `sp_aplicaaclaradebito` | Naturaleza de la transaccion incorrecta abono | abono (abono / crédito); transaccion (transacción) |
| BR-V2-1093 | VALIDACIÓN | `sp_aplicaaclaradebito` | Naturaleza de la transaccion incorrecta cargo | cargo (cargo / débito); transaccion (transacción) |
| BR-V2-1094 | VALIDACIÓN | `sp_aplicaaclaradebito` | Cuenta bloqueada | cuenta (cuenta) |
| BR-V2-1096 | VALIDACIÓN | `sp_aplicaaclaradebito_prueba` | Fondos insuficientes dã©bito | — |
| BR-V2-1097 | VALIDACIÓN | `sp_aplicaaclaradebito_prueba` | Naturaleza de la transaccion incorrecta abono | abono (abono / crédito); transaccion (transacción) |
| BR-V2-1098 | VALIDACIÓN | `sp_aplicaaclaradebito_prueba` | Naturaleza de la transaccion incorrecta cargo | cargo (cargo / débito); transaccion (transacción) |
| BR-V2-1099 | VALIDACIÓN | `sp_aplicaaclaradebito_prueba` | Cuenta bloqueada | cuenta (cuenta) |
| BR-V2-1176 | VALIDACIÓN | `sp_cargo_val` | // valida el parametro de entrada | — |
| BR-V2-1852 | VALIDACIÓN | `sp_aplicacargaarchimgcecoban` | Error en la ejecuciï¿½n del sp bditef:ins_img_det | error (error) |
| BR-V2-1853 | VALIDACIÓN | `sp_aplicadevol_cod41_ccep` | Error en la ejecucion del sp ins_reg_devo | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1854 | VALIDACIÓN | `sp_aplicadevol_cod41_ccep` | Error en la ejecucion del sp sp_tef_grab_arch_cam | ejecucion (ejecución (de proceso)); error (error) |

### ATENCION_CLIENTE — muestra (12 de 20)

| ID | Tipo | SP | Explicación | Vocab relacionado |
|----|------|----|-------------|-------------------|
| BR-V2-0010 | VALIDACIÓN | `sp_cargoxajuste_debcred` | Fondos insuficientes débito | — |
| BR-V2-0011 | VALIDACIÓN | `sp_cargoxajuste_debcred` | Naturaleza de la transaccion incorrecta abono | abono (abono / crédito); transaccion (transacción) |
| BR-V2-0012 | VALIDACIÓN | `sp_cargoxajuste_debcred` | Naturaleza de la transaccion incorrecta cargo | cargo (cargo / débito); transaccion (transacción) |
| BR-V2-0143 | VALIDACIÓN | `sp_obten_estatus_canales` | El estatus de la aclaración no puede ser nulo | estatus (estatus) |
| BR-V2-0144 | VALIDACIÓN | `sp_obten_estatus_canales_sms` | El estatus de la aclaraciã³n no puede ser nulo | estatus (estatus) |
| BR-V2-0149 | VALIDACIÓN | `sp_registra_comentario_cliente` | La invocaciã³n debe tener algãºn valor | valor (valor) |
| BR-V2-0150 | VALIDACIÓN | `sp_registra_comentario_cliente` | Debe proporcionar el mensaje a almacenar | mensaje (mensaje) |
| BR-V2-0152 | VALIDACIÓN | `sp_registra_comentario_cliente` | No existe la aclaraciã³n | — |
| BR-V2-0158 | VALIDACIÓN | `sp_relaciona_folioacl_idacl` | La invocaciã³n debe tener algãºn valor | valor (valor) |
| BR-V2-0161 | VALIDACIÓN | `sp_relaciona_folioacl_idacl` | Valores de invocaciã³n incorrectos | — |
| BR-V2-0162 | VALIDACIÓN | `sp_relaciona_folioacl_idacl` | No existe el folio de aclaraciã³n | folio (folio) |
| BR-V2-0215 | VALIDACIÓN | `sp_validapassword` | El usuario no existe | usuario (usuario) |

### RIESGO_CREDITO — muestra (12 de 320)

| ID | Tipo | SP | Explicación | Vocab relacionado |
|----|------|----|-------------|-------------------|
| BR-V2-0232 | VALIDACIÓN | `sp_pld_chq_crg_xml_head` | No se encontro el organismo regulador en la tabla bdiauditor:para | param (parámetro) |
| BR-V2-0233 | VALIDACIÓN | `sp_pld_chq_crg_xml_head` | No se encontro la clavede la entidad en la tabla bdiauditor:param | param (parámetro) |
| BR-V2-1819 | VALIDACIÓN | `sp_actualizacentrallincred` | Error en la ejecucion del sp sp_actualiza_lincred_central | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1859 | VALIDACIÓN | `sp_asignasolanalistaaumlincred` | Error en la ejecucion del sp sp_cac_asignasolanalista | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1860 | VALIDACIÓN | `sp_asignasolanalistaaumlincred` | Solicitud estã siendo atendida por xxxxxx xxxxxx xxxxx xxxxx | — |
| BR-V2-1927 | VALIDACIÓN | `sp_calculalinsugcteaumlincred` | Error en la ejecucion del sp sp_cac_calculalinsugcte | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1979 | VALIDACIÓN | `sp_catalogoexcepcionesaumlincred` | Error en la ejecucion del sp sp_consultar_excepciones_aumlincred | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1989 | VALIDACIÓN | `sp_catalogorigenaumlincred` | Error en la ejecucion del sp sp_consultar_origen_aumlincred | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1991 | VALIDACIÓN | `sp_catalogostatusaumlincred` | Error en la ejecucion del sp sp_consultar_status_aumlincred | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2288 | VALIDACIÓN | `sp_consultacatalogocausastatusaumlincred` | Error en la ejecucion del sp sp_cac_obtencausastatusaumlincred | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2290 | VALIDACIÓN | `sp_consultacatalogorigenaumlincred` | Error en la ejecucion del sp sp_consultar_origen_aumlincred | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2293 | VALIDACIÓN | `sp_consultacatalogostatusaumlincred` | Error en la ejecucion del sp sp_cac_obtenstatusaumlincred | ejecucion (ejecución (de proceso)); error (error) |

### FLUJO_OPERATIVO — muestra (12 de 53)

| ID | Tipo | SP | Explicación | Vocab relacionado |
|----|------|----|-------------|-------------------|
| BR-V2-0469 | VALIDACIÓN | `sp_cat_ejecuta_mensaje` | Validacion que los parametros de entrada no esten vacios | — |
| BR-V2-1648 | VALIDACIÓN | `sp_portabprocesaalta` | Se valida que el estatus no este cancelada | — |
| BR-V2-1827 | VALIDACIÓN | `sp_actualizaprocesoconau` | Error en la ejecucion del sp bditarjeta:sp_concreing_actualizapro | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1906 | VALIDACIÓN | `sp_buscarchivosprocesarafore` | Error en la ejecuciãn del sp bdiprog:sp_aforebuscararchivosproce | error (error) |
| BR-V2-1917 | VALIDACIÓN | `sp_ca_ejecutacargaautomaticaxml` | Error en la ejecucion del sp bdimnsj:sp_registra_evento | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1918 | VALIDACIÓN | `sp_ca_ejecutacargaautomaticaxmlpba` | Error en la ejecucion del sp bdimnsj:sp_registra_evento | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1919 | VALIDACIÓN | `sp_ca_ejecutacargaautomaticaxmlpbanew` | Error en la ejecucion del sp bdimnsj:sp_registra_evento | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1920 | VALIDACIÓN | `sp_ca_procesaarchivoxml` | Error en la ejecucion del sp | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2232 | VALIDACIÓN | `sp_conslotesmasivo` | No se obtuvieron resultados | — |
| BR-V2-2655 | VALIDACIÓN | `sp_genera_archivo_presencod46` | Error en la ejecucion del sp bditef:sp_cce_guardar_encabezado | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2656 | VALIDACIÓN | `sp_genera_archivo_presencod47` | Error en la ejecucion del sp bditef:sp_cce_guardar_encabezado | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-2657 | VALIDACIÓN | `sp_genera_archivo_presencod47` | Error en la ejecucion del sp bdicheq:sp_cce_eliminar_cheques | ejecucion (ejecución (de proceso)); error (error) |

### PARAMETRIA — muestra (12 de 455)

| ID | Tipo | SP | Explicación | Vocab relacionado |
|----|------|----|-------------|-------------------|
| BR-V2-0145 | VALIDACIÓN | `sp_obtiene_periodo_vigencia_preingreso` | La invocaciã³n debe tener algãºn valor | valor (valor) |
| BR-V2-0146 | VALIDACIÓN | `sp_obtiene_periodo_vigencia_preingreso` | No existe el tipo de ingreso de aclaraciã³n | tipo (tipo de); ingreso (ingreso (del solicitante)) |
| BR-V2-0251 | VALIDACIÓN | `sp_consultaparametro` | Error en la ejecucion del sp | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-1253 | VALIDACIÓN | `sp_consulta_firmasregistradas` | Parámetro de entrada vacío | — |
| BR-V2-1254 | VALIDACIÓN | `sp_consulta_firmasregistradas` | No se encontraron datos referentes a las firmas registradas | datos (datos); firmas (firmas mancomunadas) |
| BR-V2-1255 | VALIDACIÓN | `sp_consulta_instruccinversioncreciente` | // parámetro de entrada vacío // | — |
| BR-V2-1256 | VALIDACIÓN | `sp_consulta_instruccinversioncreciente` | // no se encontró información referente a los datos de la cuenta  | datos (datos); cuenta (cuenta) |
| BR-V2-1258 | VALIDACIÓN | `sp_consulta_instruccinversioncreciente` | // no se encontró información // | — |
| BR-V2-1259 | VALIDACIÓN | `sp_consulta_instruccionautoridad` | Parámetro de entrada vacío | — |
| BR-V2-1260 | VALIDACIÓN | `sp_consulta_instruccionautoridad` | No se encontró información relacionada a la cuenta | cuenta (cuenta) |
| BR-V2-1261 | VALIDACIÓN | `sp_consulta_instruccionvencimiento` | Parámetro de entrada vacío | — |
| BR-V2-1262 | VALIDACIÓN | `sp_consulta_instruccionvencimiento` | No se encontró información | — |

### OPERACIONAL — muestra (12 de 1,697)

| ID | Tipo | SP | Explicación | Vocab relacionado |
|----|------|----|-------------|-------------------|
| BR-V2-0223 | VALIDACIÓN | `sp_ope_addfolio_xml` | Error en la ejecuciãn del sp bdiauditor:sp_pld_chq_addfolio_clon | error (error) |
| BR-V2-0225 | VALIDACIÓN | `sp_ope_cargainfo_xml` | Error en la ejecuciãn del sp bdiauditor:sp_pld_chq_crg_xml | error (error) |
| BR-V2-0227 | VALIDACIÓN | `sp_ope_crgxml_head` | Error en la ejecuciãn del sp bdiauditor:sp_pld_chq_crg_xml_head | error (error) |
| BR-V2-0228 | VALIDACIÓN | `sp_perfisica_listanegra` | - validacion de campos requeridos | — |
| BR-V2-0229 | VALIDACIÓN | `sp_perfisica_listanegra_exp` | - validacion de campos requeridos | — |
| BR-V2-0246 | VALIDACIÓN | `sp_cambiostatus_token_bei` | Error en la ejecucion del sp sp_set_estatus_tokenasociados_bei | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-0247 | VALIDACIÓN | `sp_cambiostatus_token_bei` | Error en la ejecucion del sp sp_set_solicitudstatus_admtoken_bei | ejecucion (ejecución (de proceso)); error (error) |
| BR-V2-0253 | VALIDACIÓN | `sp_cuentas_bei` | - valida que el cliente no sea blanco | — |
| BR-V2-0254 | VALIDACIÓN | `sp_cuentas_bei` | Cliente no tiene cuentas de cheques | cliente (cliente); cuentas (cuentas (plural)); cheques (cheq |
| BR-V2-0258 | VALIDACIÓN | `sp_registraoperacion` | La operacion no puede ser un valor nulo o vacio | operacion (operación); valor (valor) |
| BR-V2-0259 | VALIDACIÓN | `sp_registraoperacion` | El usuario no existe o no tiene su servicio activo o no es operad | usuario (usuario); servicio (servicio) |
| BR-V2-0260 | VALIDACIÓN | `sp_registraoperacion` | El numcte no puede ser un valor nulo o vacio | valor (valor); numcte (número de cliente) |

---

## Umbrales hardcodeados — parámetros a externalizar

Cada umbral es un valor de negocio embebido en código que **debe migrar a tabla de configuración**.

| ID | SP | Dominio | Explicación | Vocab |
|----|----|----|---|---|
| BR-V2-0291 | `sp_cancelartokensucursal` | bdibpi | Or (cestatussol::integer >= 300 and cestatussol::integer < 3 |  |
| BR-V2-0313 | `burofisicas` | bdiburo | LRSIC |  |
| BR-V2-0315 | `burofisicas_cnr` | bdiburo | LRSIC |  |
| BR-V2-0346 | `sp_burofisicas_cortos` | bdiburo | LRSIC |  |
| BR-V2-0366 | `sp_burofisicas_cortos_cnr` | bdiburo | LRSIC |  |
| BR-V2-0537 | `calc_interes` | D04 Cheques | Criterios contables CNBV + GAT |  |
| BR-V2-1184 | `sp_cargoxcomision_pm` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1185 | `sp_cargoxcomision_pm` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1186 | `sp_cargoxcomision_pm` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1190 | `sp_cargoxcomision_pm_comp2` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1191 | `sp_cargoxcomision_pm_comp2` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1192 | `sp_cargoxcomision_pm_comp2` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1196 | `sp_cargoxcomision_pm_esp` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1197 | `sp_cargoxcomision_pm_esp` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1198 | `sp_cargoxcomision_pm_esp` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1202 | `sp_cargoxcomision_pmcomp` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1203 | `sp_cargoxcomision_pmcomp` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1204 | `sp_cargoxcomision_pmcomp` | D04 Cheques | LTOSF Art.17 (CAT) + RECO |  |
| BR-V2-1840 | `sp_adminitasas_cargarchivo` | D01 Canal | Criterios contables CNBV + GAT |  |
| BR-V2-3170 | `sp_cat_consulta_disponibilidad_cliente` | D11 Cobr. | CUB CNBV |  |
| BR-V2-3359 | `sp_validavencidos` | D11 Cobr. | CUB CNBV |  |
| BR-V2-3360 | `sp_validavencidos_bis` | D11 Cobr. | CUB CNBV |  |
| BR-V2-3818 | `interes` | D03 Créditos | Criterios contables CNBV + GAT |  |
| BR-V2-3820 | `interes` | D03 Créditos | Criterios contables CNBV + GAT |  |
| BR-V2-3821 | `interes` | D03 Créditos | Criterios contables CNBV + GAT |  |
| BR-V2-3906 | `principalcrd` | D03 Créditos | CUB CNBV |  |
| BR-V2-4229 | `sp_calculo_reserva_cierre` | D03 Créditos | CUB B-5 |  |
| BR-V2-4236 | `sp_calculo_reserva_corte` | D03 Créditos | CUB B-5 |  |
| BR-V2-4240 | `sp_calculo_reserva_corte_cnr` | D03 Créditos | CUB B-5 |  |
| BR-V2-4250 | `sp_calculo_reserva_corte_cnr_mx` | D03 Créditos | CUB B-5 |  |

---

## Riesgos de equivalencia — guía de validación

| Riesgo | Origen Informix | Acción requerida |
|---|---|---|
| Base 360 | `/360` año comercial | Confirmar con SME CNBV cuál base aplica por producto |
| Base 365 | `/365` año natural | Confirmar con SME CNBV cuál base aplica por producto |
| TRUNC | Trunca sin redondear | Replicar `TRUNC` exacto en PostgreSQL (no ROUND) |
| ROUND | Half-up | Validar modo banker's vs half-up en target |
| MONEY | Banker's rounding | Usar `NUMERIC(18,4)` + ROUND explícito |

---

*Generado automáticamente · Specialist — Informix SPL Analysis · BCOPCore Etapa 3*  
*Fuentes: `business-rules-v2.json` v2.2 · `vocabulary-inventory.json` · `callgraph-data.json`*  
*Para actualizar: `python enrich-rules.py`*