# D04 · Cheques / Cuentas — Reglas de Negocio y Fórmulas

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — TESOFE** (`SME/Regulatory/TESOFE/`)
- **SME Regulatorio — IPAB** (`SME/Regulatory/IPAB/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen

**133 fórmulas** + **173 validaciones** extraídas del código de `bdicheq`. Reguladores con reglas: CNBV, CONDUSEF, SAT, TESOFE.

## Fórmulas de negocio (evidencia directa del código)

| ID | SP · línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-IFX-005 | `abono_ctas_comis` L87 | CONDUSEF | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/comisionesxabonar.unl ` | |
| BR-IFX-006 | `abono_ctas_comis_pba` L87 | CONDUSEF | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/comisionesxabonar.unl ` | |
| BR-IFX-007 | `abono_ctas_ivas` L87 | SAT | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ivasxabonar.unl DELIMI` | |
| BR-IFX-008 | `abono_ctas_ivas_pba` L87 | operacional | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ivasxabonar.unl DELIMI` | |
| BR-IFX-009 | `abono_ref` L792 | operacional | `vmonto_udi = pmto_tot / vprecio_udi` | |
| BR-IFX-013 | `bloqueo_cta` L223 | operacional | `vmonto_cong = pmonto * -1` | |
| BR-IFX-018 | `calc_int` L85 | CNBV | `vsdo_prom = vacum_sdo_pos / vdia_sdo_pos` | |
| BR-IFX-019 | `calc_int` L117 | CNBV | `vtot_int = vacum_sdo_pos * vvalor_tasa / 100 / 360` | ⚠ base 360 (año comercial) — verificar vs 365 |
| BR-IFX-022 | `calc_interes` L92 | CNBV | `vsdo_promedio = vacum_sdo_pos / vdia_sdo_pos` | |
| BR-IFX-023 | `calc_interes` L100 | CNBV | `vcalc_int = ((vacum_sdo_pos / vdia_sdo_pos) * vtasa) * vdia_sdo_pos / ` | ⚠ base 360 (año comercial) — verificar vs 365 |
| BR-IFX-025 | `calc_isr` L116 | SAT · CNBV | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobas` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-026 | `calc_isr` L122 | SAT · CNBV | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-027 | `calc_isr` L127 | SAT · CNBV | `vimp_isr = trunc( ( psdo_promedio * vtasa_isr_tr ), 2 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-029 | `calc_isr_proy` L117 | SAT · CNBV | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobas` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-030 | `calc_isr_proy` L118 | SAT · CNBV | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-037 | `calcula_int` L221 | operacional | `vsdo_promedio = vgacum_sdo_pos / vgdia_sdo_pos` | |
| BR-IFX-038 | `calcula_int` L246 | CNBV | `vvalor_tasa = vvaltasa / 100` | |
| BR-IFX-039 | `calcula_int` L320 | CNBV | `vtotint = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` | |
| BR-IFX-040 | `calcula_int` L365 | CNBV | `vvalor_tasa = vvaltasa/100` | |
| BR-IFX-041 | `calcula_int` L373 | CNBV | `vgacum_sdo_int = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / ` | |
| BR-IFX-042 | `calcula_int` L416 | operacional | `vgacum_sdo_int = vgacum_sdo_int * -1` | |
| BR-IFX-043 | `calcula_int` L464 | CNBV | `vtotint = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vnumdia` | |
| BR-IFX-044 | `calcula_int` L778 | CNBV | `vintdia = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` | |
| BR-IFX-046 | `calcula_int_pba` L205 | operacional | `vsdo_promedio = vgacum_sdo_pos / vgdia_sdo_pos` | |
| BR-IFX-047 | `calcula_int_pba` L222 | CNBV | `vvalor_tasa = vvaltasa / 100` | |
| BR-IFX-048 | `calcula_int_pba` L272 | CNBV | `vtotint = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` | |
| BR-IFX-049 | `calcula_int_pba` L317 | CNBV | `vvalor_tasa = vvaltasa/100` | |
| BR-IFX-050 | `calcula_int_pba` L325 | CNBV | `vgacum_sdo_int = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / ` | |
| BR-IFX-051 | `calcula_int_pba` L361 | operacional | `vgacum_sdo_int = vgacum_sdo_int * -1` | |
| BR-IFX-052 | `calcula_int_pba` L400 | CNBV | `vtotint = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vnumdia` | |
| BR-IFX-053 | `calcula_int_pba` L693 | CNBV | `vintdia = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` | |
| BR-IFX-055 | `calcula_intqra` L194 | operacional | `vsdo_promedio = vgraacum_sdo_pos / vgradia_sdo_pos` | |
| BR-IFX-056 | `calcula_intqra` L211 | CNBV | `vvalor_tasa = vvaltasa / 100` | |
| BR-IFX-057 | `calcula_intqra` L255 | CNBV | `vtotint = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` | |
| BR-IFX-058 | `calcula_intqra` L295 | CNBV | `vvalor_tasa = vvaltasa/100` | |
| BR-IFX-059 | `calcula_intqra` L301 | CNBV | `vgraacum_sdo_int = ((((vgraacum_sdo_pos / vgradia_sdo_pos) * vvalor_ta` | |
| BR-IFX-060 | `calcula_intqra` L342 | operacional | `vgraacum_sdo_int = vgraacum_sdo_int * -1` | |
| BR-IFX-061 | `calcula_intqra` L378 | CNBV | `vtotint = ((((vgraacum_sdo_pos / vgradia_sdo_pos) * vvalor_tasa) / vnu` | |
| BR-IFX-062 | `calcula_intqra` L617 | CNBV | `vintdia = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` | |
| BR-IFX-064 | `cargo_comisiones_pba` L143 | CONDUSEF | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` | |
| BR-IFX-065 | `cargo_comisiones_pba` L169 | CONDUSEF | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-066 | `cargo_comisiones_pba` L173 | CONDUSEF | `vIVA = TRUNC((vMontoCom * vValIva),2)` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-070 | `cargo_comisiones_per` L171 | CONDUSEF | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` | |
| BR-IFX-071 | `cargo_comisiones_per` L199 | CONDUSEF | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-072 | `cargo_comisiones_per` L203 | CONDUSEF | `vIVA = TRUNC((vMontoCom * vValIva),2)` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-076 | `cargo_comisiones_per_web` L169 | CONDUSEF | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` | |
| BR-IFX-077 | `cargo_comisiones_per_web` L197 | CONDUSEF | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-078 | `cargo_comisiones_per_web` L201 | CONDUSEF | `vIVA = TRUNC((vMontoCom * vValIva),2)` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-082 | `cargo_comisiones_web` L171 | CONDUSEF | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` | |
| BR-IFX-083 | `cargo_comisiones_web` L197 | CONDUSEF | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-084 | `cargo_comisiones_web` L201 | CONDUSEF | `vIVA = TRUNC((vMontoCom * vValIva),2)` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-088 | `cargo_ref` L441 | operacional | `vsdo_retenido = vsdo_retenido * -1` | |
| BR-IFX-089 | `cargo_ref` L445 | operacional | `vsdo_cong = vsdo_cong * -1` | |
| BR-IFX-090 | `cargo_ref` L454 | operacional | `mSaldoSbc = mSaldoSbc * -1` | |
| BR-IFX-091 | `cargo_ref` L721 | operacional | `msdo_retenido = msdo_retenido * -1` | |
| BR-IFX-092 | `cargo_ref` L725 | operacional | `msdo_cong = msdo_cong * -1` | |
| BR-IFX-107 | `conisr_anual` L246 | operacional | `vsaldoprom = vacumsdopos / vdiasdopos` | |
| BR-IFX-108 | `conisr_anual` L361 | CNBV | `vtasapromedio = (((vtasaprom / 100) / vdiasanio) * vdiasdopos)` | |
| BR-IFX-109 | `conisr_anual` L363 | CNBV | `vtasapromedio = ((vtasaprom / vdiasanio) * vdiasdopos)` | |
| BR-IFX-110 | `conisr_anual` L391 | operacional | `vintnomext = vsaldoprom * vajustexinf` | |
| BR-IFX-111 | `conisr_anual` L434 | CNBV | `vtasapromanual = vtasapromanual / vmeses` | |
| BR-IFX-113 | `conisr_anual_cta` L244 | CNBV | `vt_tasapromt = ((8.50/vt_diasanio) * vt_diasinver)/100` | |
| BR-IFX-114 | `conisr_anual_cta` L245 | CNBV | `vt_tasapromtx100 = vt_tasapromt * 100` | |
| BR-IFX-115 | `conisr_anual_cta` L249 | CNBV | `vt_sdoprom = ((vt_totintpag * vt_diasanio)/(vt_tasaprom/100))/vt_diasi` | |
| BR-IFX-116 | `conisr_anual_cta` L359 | CNBV | `vt_interesreal = vt_sdoprom * vt_tasarealperi` | |
| BR-IFX-117 | `conisr_anual_cta` L360 | CNBV | `vt_interesreal = (vt_interesreal/100)` | |
| BR-IFX-118 | `conisr_anual_cta` L376 | CNBV | `vt_tasarealperi = ((vt_tasapromt)-(vt_ajustexinf))*100` | |
| BR-IFX-119 | `conisr_anual_cta` L379 | CNBV | `vt_tasaperdida = (vt_sdoprom * vt_tasarealperi)/100` | |
| BR-IFX-122 | `sp_blqdesconcentractasinactivas` L247 | SAT · CNBV | `vIsrCalc = (mBase_gravable * (dPorRetSuj/100)) * iDias / iAniobase` | |
| BR-IFX-123 | `sp_blqdesconcentractasinactivas` L252 | SAT · CNBV | `vIsrCalc = (vSdoActual * (dPorRetSuj/100)) * iDias / iAniobase` | |
| BR-IFX-124 | `sp_calcmtoglobcap` L222 | operacional | `vmonto_glob_cap = vmonto_glob_cap / 12` | |
| BR-IFX-127 | `sp_calcsdo_ctasinactivas` L184 | SAT · CNBV · CNBV | `vIntereses = (((pSdoConcentrado * vAjustexInf) / 365) * vDias)` | ⚠ base 365 — verificar vs 360 |
| BR-IFX-128 | `sp_calcsdo_ctasinactivas` L225 | SAT · SAT · CNBV · CNBV | `vTasa_ISR = TRUNC( ( ( ( vPorRetSuj / 100 ) * vDias ) / 365 ), 6 )` | ⚠ base 365 — verificar vs 360; TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-129 | `sp_calcsdo_ctasinactivas` L231 | SAT · SAT · CNBV · CNBV | `vISR = TRUNC( ( vBaseGravable * vTasa_ISR ), 2 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-130 | `sp_calcsdo_ctasinactivas` L236 | SAT · SAT · CNBV · CNBV | `vISR = TRUNC( ( pSdoConcentrado * vTasa_ISR ), 2 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-131 | `sp_calcsdoctainactiva` L213 | CNBV · CNBV | `vIntereses = (((vSaldoConcentrado * vAjustexInf) / 365) * vDias)` | ⚠ base 365 — verificar vs 360 |
| BR-IFX-132 | `sp_calcsdoctainactiva` L251 | SAT · CNBV · CNBV | `vTasa_ISR = TRUNC( ( ( ( vPorRetSuj / 100 ) * vDias ) / 365 ), 6 )` | ⚠ base 365 — verificar vs 360; TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-133 | `sp_calcsdoctainactiva` L257 | SAT · CNBV · CNBV | `vISR = TRUNC( ( vBaseGravable * vTasa_ISR ), 2 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-134 | `sp_calcsdoctainactiva` L262 | SAT · CNBV · CNBV | `vISR = TRUNC( ( vSaldoConcentrado * vTasa_ISR ), 2 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-136 | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` L109 | CNBV | `vsdo_ponderado_maehis = (vsdo_ponderado_maehis / vdia_sdo) * vdia_sdo` | |
| BR-IFX-137 | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` L127 | CNBV | `vsdo_ponderado_pagare_for = vsdo_ponderado_pagare * vdias_pagare` | |
| BR-IFX-138 | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` L153 | CNBV | `vsdo_ponderado_maenoc_sum = vsdo_ponderado_maenoc_sum + (vsdo_ponderad` | |
| BR-IFX-139 | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` L183 | CNBV | `vsdo_ponderado_pagare_sum = vsdo_ponderado_pagare * vdias_transc` | |
| BR-IFX-140 | `sp_calcula_sdo_nvo_y_promedio_admin_tasas` L196 | CNBV | `vsaldo_promedio_total = vsaldo_suma / vdia_sdo_total` | |
| BR-IFX-142 | `sp_calculagat` L56 | CNBV | `gat_nominal = ROUND((POW((1 + ((tasa/100)/periodo)),periodo) - 1) * 10` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-143 | `sp_calculagat` L61 | CNBV | `gat_nomina = ROUND((POW((1 + ((tasa/100)/periodo)),periodo) - 1) * 100` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-144 | `sp_calculagat` L71 | operacional | `gat_real = ROUND(((((1 + (gat_nominal/100)) / (1 + dMedInflacion))-1)*` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-145 | `sp_calculagat` L74 | operacional | `gat_real = ROUND(((((1 + (gat_nomina/100)) / (1 + dMedInflacion))-1)*1` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-148 | `sp_calculagat_morales` L60 | operacional | `vGatReal = ROUND(((((1 + (vValor/100)) / (1 + (vMedianaInflacion/100))` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-150 | `sp_calculaintaclaraciones` L151 | operacional | `vvalorISR = vvalorISR / 100` | |
| BR-IFX-151 | `sp_calculaintaclaraciones` L175 | operacional | `vbase_excenta = vsalariomin * vdiassalariomin * vaniobase` | |
| BR-IFX-152 | `sp_calculaintaclaraciones` L191 | CNBV | `vvaltasa = vvaltasa / 100` | |
| BR-IFX-153 | `sp_calculaintaclaraciones` L195 | CNBV | `vintereses = (((pmonto * vvaltasa) * vdias) / 360)` | ⚠ base 360 (año comercial) — verificar vs 365 |
| BR-IFX-154 | `sp_calculaintaclaraciones` L198 | SAT · CNBV | `vtasa_isr = TRUNC( ( ( vvalorISR * vdias ) / vaniobase ), 6 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-155 | `sp_calculaintaclaraciones` L204 | SAT · CNBV | `visr = TRUNC( ( vbase_gravable * vtasa_isr ), 2 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-156 | `sp_calculaintaclaraciones` L209 | SAT · CNBV | `visr = TRUNC( ( pmonto * vtasa_isr ), 2 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-157 | `sp_cancelactasinactivas` L158 | SAT · CNBV | `vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conci` | |
| BR-IFX-158 | `sp_cap_recalculagat1200` L99 | CNBV | `vgat_nominal = ROUND((POW((1 + dTasa/iPeriodo),iPeriodo) - 1), 2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-159 | `sp_cap_recalculagat1200` L100 | operacional | `vgat_real = ROUND(((((1 + (vgat_nominal/100)) / (1 + (dMedianaInfl/100` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-166 | `sp_cargoxcomision_pm` L284 | CONDUSEF | `mValorSdoPos = mAcumSdoPos / iDiaSdoPos` | |
| BR-IFX-167 | `sp_cargoxcomision_pm` L527 | CONDUSEF | `dMontoAplica = ROUND(mDisponible / (1 + dValIva),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-168 | `sp_cargoxcomision_pm` L531 | CONDUSEF | `mIva = TRUNC((dMontoAplica * dValIva),2)` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-170 | `sp_cargoxcomision_pm_comp2` L258 | CONDUSEF | `mValorSdoPos = mAcumSdoPos / iDiaSdoPos` | |
| BR-IFX-171 | `sp_cargoxcomision_pm_comp2` L500 | CONDUSEF | `dMontoAplica = ROUND(mDisponible / (1 + dValIva),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-172 | `sp_cargoxcomision_pm_comp2` L504 | CONDUSEF | `mIva = TRUNC((dMontoAplica * dValIva),2)` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-174 | `sp_cargoxcomision_pm_esp` L258 | CONDUSEF | `mValorSdoPos = mAcumSdoPos / iDiaSdoPos` | |
| BR-IFX-175 | `sp_cargoxcomision_pm_esp` L501 | CONDUSEF | `dMontoAplica = ROUND(mDisponible / (1 + dValIva),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-176 | `sp_cargoxcomision_pm_esp` L505 | CONDUSEF | `mIva = TRUNC((dMontoAplica * dValIva),2)` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-178 | `sp_cargoxcomision_pmcomp` L256 | CONDUSEF | `mValorSdoPos = mAcumSdoPos / iDiaSdoPos` | |
| BR-IFX-179 | `sp_cargoxcomision_pmcomp` L498 | CONDUSEF | `dMontoAplica = ROUND(mDisponible / (1 + dValIva),2)` | ⚠ ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-180 | `sp_cargoxcomision_pmcomp` L502 | CONDUSEF | `mIva = TRUNC((dMontoAplica * dValIva),2)` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-189 | `sp_cobrocomisionreposiciondebito` L96 | CONDUSEF | `cIvaCom = cMontoCom * cIvaCom` | |
| BR-IFX-231 | `sp_corrige_isr` L166 | operacional | `mSdoPromedio = mSdoAcum / iDias` | |
| BR-IFX-232 | `sp_corrige_isr` L170 | SAT · CNBV | `dTasa_ISR = TRUNC( ( ( ( dTasaISR / 100 ) * iDias ) / iAnioBase ), 6 )` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-233 | `sp_corrige_isr` L185 | SAT · CNBV | `mISRCalculado = TRUNC( (mBaseGravable * dTasa_ISR ), 2)` | ⚠ TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos) |
| BR-IFX-239 | `sp_dispersionlinea_bei` L100 | TESOFE | `pIvaDisp = pCargoDisp * mMontoTransIvaDisp` | |
| BR-IFX-241 | `sp_dispersionlinea_bpi` L102 | TESOFE | `pIvaDisp = pCargoDisp * mMontoTransIvaDisp` | |
| BR-IFX-243 | `sp_dispersionlinea_bpi_pba2` L96 | TESOFE | `pIvaDisp = pCargoDisp * mMontoTransIvaDisp` | |
| BR-IFX-257 | `sp_gen_isr_cfdi_sdo` L319 | operacional | `vt_sdoprom1 = vt_sdoprom1 * (-1)` | |
| BR-IFX-258 | `sp_gen_isr_cfdi_sdo` L382 | operacional | `vt_sdoprom10 = vt_sdoprom10 * (-1)` | |
| BR-IFX-261 | `sp_grabaintsisr` L158 | operacional | `mSdoPromedio = mSdoAcum / iDias` | |
| BR-IFX-262 | `sp_grabaintsisr` L160 | CNBV | `mIntsCalculados = ROUND((((mSdoPromedio * dTasa) * iDias) / 360),2)` | ⚠ base 360 (año comercial) — verificar vs 365; ROUND — validar modo de redondeo (banker's vs half-up) |
| BR-IFX-263 | `sp_grabaintsisr` L174 | CNBV | `mISRCalculado = (((mBaseGravable * dTasaISR) / iAnioBase) * iDias)` | |
| BR-IFX-264 | `sp_grabaintsisr` L179 | CNBV | `mISRCalculado = (((mSdoPromedio * dTasaISR) / iAnioBase) * iDias)` | |
| BR-IFX-267 | `sp_nominaconsultasaldoeje` L120 | CONDUSEF · CNBV | `mTotalComision = pTotalRegistros * mMontoComisionDispercion` | |
| BR-IFX-268 | `sp_nominaconsultasaldoeje` L121 | SAT · CONDUSEF · CNBV | `mTotaliva = mTotalComision * mValorIva; --Nueva Forma de Calcular el I` | |
| BR-IFX-269 | `sp_nominaconsultasaldoeje` L128 | CNBV | `mSaldo = mSaldo * -1` | |
| BR-IFX-276 | `sp_nominatotalivacomision` L65 | CONDUSEF | `mTotalComision = iNumeroRegistrosAplicados * mValorComisionDispercion` | |
| BR-IFX-277 | `sp_nominatotalivacomision` L66 | SAT · CONDUSEF | `mTotaliva = mTotalComision * mValorIva; /* Nueva Forma de Calcular el ` | |
| BR-IFX-280 | `sp_nominatotalivacomision_bpi` L72 | CONDUSEF | `mTotalComision = iNumeroRegistrosAplicados * mValorComisionDispercion` | |
| BR-IFX-281 | `sp_nominatotalivacomision_bpi` L73 | SAT · CONDUSEF | `mTotaliva = mTotalComision * mValorIva; /* Nueva Forma de Calcular el ` | |
| BR-IFX-307 | `sp_reportactasinactivas` L274 | SAT · CNBV | `vStmt = "sed 's/\\//g' /resplogifx/conciliachq/cuentasinactivas5000_pr` | |
| BR-IFX-308 | `sp_reportactasinactivas` L279 | SAT · CNBV | `vStmt = "rm /resplogifx/conciliachq/cuentasinactivas5000_prod"//vProdu` | |

## Reglas por regulador (SME dueño)

- **CNBV** (`SME/Regulatory/CNBV/`) — 106 reglas · Criterios contables CNBV + GAT — cálculo de intereses/rendimientos
- **CONDUSEF** (`SME/Regulatory/CONDUSEF/`) — 72 reglas · LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada
- **SAT** (`SME/Regulatory/SAT/`) — 40 reglas · LIVA — IVA sobre comisiones (16% / 8% frontera)
- **TESOFE** (`SME/Regulatory/TESOFE/`) — 26 reglas · LTF — dispersión de recursos federales

## `[RIESGO-EQUIVALENCIA]` en este dominio

Semántica Informix que debe preservarse exacta en el target (golden master ≥ 99.95%):
- **TRUNC vs ROUND** · **base 360 vs 365** · **tipo MONEY (banker's rounding)** — divergencia auditable.

## `[SME-PENDING]` Validación regulatoria

- [ ] Cada fórmula → validar con el SME regulador dueño (ver `regulatory-validation-packets-lgc.md`).
- [ ] Confirmar parámetros: tasas, bases de cálculo (360/365), plazos.
- [ ] Definir golden master test por fórmula.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: business-rules.json*