# BCOPCore · Catálogo de Reglas de Negocio y Fórmulas

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction  
> **Evidencia:** extraído del código SPL (SP + línea) · **Generado:** 2026-07-04 por `extract-rules.py`  

**395 fórmulas** + **913 validaciones** extraídas · **725 con impacto regulatorio**. Cada regla tiene evidencia directa (SP + línea de código). Las fórmulas financieras llevan `[RIESGO-EQUIVALENCIA]` cuando su semántica Informix (TRUNC, base 360/365, MONEY) puede divergir en el target.

## SMEs reguladores presentes

Cada regla regulatoria tiene un **SME dueño** que valida el cumplimiento contra su corpus normativo:

| Regulador | SME (agente) | Reglas |
|-----------|--------------|-------:|
| **CNBV** | `SME/Regulatory/CNBV/` | 454 |
| **Banxico** | `SME/Regulatory/Banxico/` | 30 |
| **CONDUSEF** | `SME/Regulatory/CONDUSEF/` | 202 |
| **SAT** | `SME/Regulatory/SAT/` | 87 |
| **TESOFE** | `SME/Regulatory/TESOFE/` | 38 |
| **IPAB** | `SME/Regulatory/IPAB/` | 9 |

---

## Fórmulas de negocio críticas (con riesgo de equivalencia)

- `BR-IFX-019` **calc_int** (D04 Cheques · L117) — **CNBV**  
  ```
  vtot_int = vacum_sdo_pos * vvalor_tasa / 100 / 360
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` base 360 (año comercial) — verificar vs 365

- `BR-IFX-023` **calc_interes** (D04 Cheques · L100) — **CNBV**  
  ```
  vcalc_int = ((vacum_sdo_pos / vdia_sdo_pos) * vtasa) * vdia_sdo_pos / 360
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` base 360 (año comercial) — verificar vs 365

- `BR-IFX-025` **calc_isr** (D04 Cheques · L116) — **SAT** · **CNBV**  
  ```
  vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobase ), 6 )
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-026` **calc_isr** (D04 Cheques · L122) — **SAT** · **CNBV**  
  ```
  vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-027` **calc_isr** (D04 Cheques · L127) — **SAT** · **CNBV**  
  ```
  vimp_isr = trunc( ( psdo_promedio * vtasa_isr_tr ), 2 )
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-029` **calc_isr_proy** (D04 Cheques · L117) — **SAT** · **CNBV**  
  ```
  vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobase ), 6)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-030` **calc_isr_proy** (D04 Cheques · L118) — **SAT** · **CNBV**  
  ```
  vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-065` **cargo_comisiones_pba** (D04 Cheques · L169) — **CONDUSEF**  
  ```
  vMontoCom = ROUND(vDisponible / (1 + vValIva),2)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` ROUND — validar modo de redondeo (banker's vs half-up)

- `BR-IFX-066` **cargo_comisiones_pba** (D04 Cheques · L173) — **CONDUSEF**  
  ```
  vIVA = TRUNC((vMontoCom * vValIva),2)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-071` **cargo_comisiones_per** (D04 Cheques · L199) — **CONDUSEF**  
  ```
  vMontoCom = ROUND(vDisponible / (1 + vValIva),2)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` ROUND — validar modo de redondeo (banker's vs half-up)

- `BR-IFX-072` **cargo_comisiones_per** (D04 Cheques · L203) — **CONDUSEF**  
  ```
  vIVA = TRUNC((vMontoCom * vValIva),2)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-077` **cargo_comisiones_per_web** (D04 Cheques · L197) — **CONDUSEF**  
  ```
  vMontoCom = ROUND(vDisponible / (1 + vValIva),2)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` ROUND — validar modo de redondeo (banker's vs half-up)

- `BR-IFX-078` **cargo_comisiones_per_web** (D04 Cheques · L201) — **CONDUSEF**  
  ```
  vIVA = TRUNC((vMontoCom * vValIva),2)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-083` **cargo_comisiones_web** (D04 Cheques · L197) — **CONDUSEF**  
  ```
  vMontoCom = ROUND(vDisponible / (1 + vValIva),2)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` ROUND — validar modo de redondeo (banker's vs half-up)

- `BR-IFX-084` **cargo_comisiones_web** (D04 Cheques · L201) — **CONDUSEF**  
  ```
  vIVA = TRUNC((vMontoCom * vValIva),2)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-127` **sp_calcsdo_ctasinactivas** (D04 Cheques · L184) — **SAT** · **CNBV** · **CNBV**  
  ```
  vIntereses = (((pSdoConcentrado * vAjustexInf) / 365) * vDias)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` base 365 — verificar vs 360

- `BR-IFX-128` **sp_calcsdo_ctasinactivas** (D04 Cheques · L225) — **SAT** · **SAT** · **CNBV** · **CNBV**  
  ```
  vTasa_ISR = TRUNC( ( ( ( vPorRetSuj / 100 ) * vDias ) / 365 ), 6 )
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` base 365 — verificar vs 360
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-129` **sp_calcsdo_ctasinactivas** (D04 Cheques · L231) — **SAT** · **SAT** · **CNBV** · **CNBV**  
  ```
  vISR = TRUNC( ( vBaseGravable * vTasa_ISR ), 2 )
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-130` **sp_calcsdo_ctasinactivas** (D04 Cheques · L236) — **SAT** · **SAT** · **CNBV** · **CNBV**  
  ```
  vISR = TRUNC( ( pSdoConcentrado * vTasa_ISR ), 2 )
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)

- `BR-IFX-131` **sp_calcsdoctainactiva** (D04 Cheques · L213) — **CNBV** · **CNBV**  
  ```
  vIntereses = (((vSaldoConcentrado * vAjustexInf) / 365) * vDias)
  ```
  ⚠ `[RIESGO-EQUIVALENCIA]` base 365 — verificar vs 360

---

## Reglas por regulador

### CNBV — SME Regulatorio — CNBV
> Corpus: `SME/Regulatory/CNBV/` · 454 reglas

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-001 | VALIDACIÓN | `sp_acl_validarpreguntasautenticacion` L30 | Criterios contables CNBV + GAT — cálculo de inte | `LET cCodRet='00000'` |
| BR-IFX-004 | VALIDACIÓN | `califica_scoring_cjunk_apolo` L362 | Buró de Crédito — evaluación crediticia (LRSIC) | `LET cCodret = ""` |
| BR-IFX-018 | FÓRMULA | `calc_int` L85 | Criterios contables CNBV + GAT — cálculo de inte | `vsdo_prom = vacum_sdo_pos / vdia_sdo_pos` |
| BR-IFX-019 | FÓRMULA | `calc_int` L117 | Criterios contables CNBV + GAT — cálculo de inte | `vtot_int = vacum_sdo_pos * vvalor_tasa / 100 / 360` |
| BR-IFX-020 | VALIDACIÓN | `calc_int` L37 | Criterios contables CNBV + GAT — cálculo de inte | `let vcodret = "000"` |
| BR-IFX-021 | VALIDACIÓN | `calc_int` L63 | Criterios contables CNBV + GAT — cálculo de inte | `let vcodret = "100"` |
| BR-IFX-022 | FÓRMULA | `calc_interes` L92 | Criterios contables CNBV + GAT — cálculo de inte | `vsdo_promedio = vacum_sdo_pos / vdia_sdo_pos` |
| BR-IFX-023 | FÓRMULA | `calc_interes` L100 | Criterios contables CNBV + GAT — cálculo de inte | `vcalc_int = ((vacum_sdo_pos / vdia_sdo_pos) * vtasa) * vdia_sdo_pos / ` |
| BR-IFX-024 | VALIDACIÓN | `calc_interes` L33 | Criterios contables CNBV + GAT — cálculo de inte | `LET vcodret = "000"` |
| BR-IFX-025 | FÓRMULA | `calc_isr` L116 | Criterios contables CNBV + GAT — cálculo de inte | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobas` |
| BR-IFX-026 | FÓRMULA | `calc_isr` L122 | Criterios contables CNBV + GAT — cálculo de inte | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` |
| BR-IFX-027 | FÓRMULA | `calc_isr` L127 | Criterios contables CNBV + GAT — cálculo de inte | `vimp_isr = trunc( ( psdo_promedio * vtasa_isr_tr ), 2 )` |
| BR-IFX-029 | FÓRMULA | `calc_isr_proy` L117 | Criterios contables CNBV + GAT — cálculo de inte | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobas` |
| BR-IFX-030 | FÓRMULA | `calc_isr_proy` L118 | Criterios contables CNBV + GAT — cálculo de inte | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` |
| BR-IFX-032 | VALIDACIÓN | `calc_tasa` L48 | Criterios contables CNBV + GAT — cálculo de inte | `LET vcodret = "000"` |
| BR-IFX-033 | VALIDACIÓN | `calc_tasa` L66 | Criterios contables CNBV + GAT — cálculo de inte | `LET vcodret = "901"` |
| BR-IFX-034 | VALIDACIÓN | `calc_tasaqra` L49 | Criterios contables CNBV + GAT — cálculo de inte | `LET vcodret = "000"` |
| BR-IFX-035 | VALIDACIÓN | `calc_tasaqra` L73 | Criterios contables CNBV + GAT — cálculo de inte | `LET vcodret = "901"` |
| BR-IFX-038 | FÓRMULA | `calcula_int` L246 | Criterios contables CNBV + GAT — cálculo de inte | `vvalor_tasa = vvaltasa / 100` |
| BR-IFX-039 | FÓRMULA | `calcula_int` L320 | Criterios contables CNBV + GAT — cálculo de inte | `vtotint = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` |
| BR-IFX-040 | FÓRMULA | `calcula_int` L365 | Criterios contables CNBV + GAT — cálculo de inte | `vvalor_tasa = vvaltasa/100` |
| BR-IFX-041 | FÓRMULA | `calcula_int` L373 | Criterios contables CNBV + GAT — cálculo de inte | `vgacum_sdo_int = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / ` |
| BR-IFX-043 | FÓRMULA | `calcula_int` L464 | Criterios contables CNBV + GAT — cálculo de inte | `vtotint = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vnumdia` |
| BR-IFX-044 | FÓRMULA | `calcula_int` L778 | Criterios contables CNBV + GAT — cálculo de inte | `vintdia = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` |
| BR-IFX-047 | FÓRMULA | `calcula_int_pba` L222 | Criterios contables CNBV + GAT — cálculo de inte | `vvalor_tasa = vvaltasa / 100` |

### Banxico — SME Regulatorio — Banxico
> Corpus: `SME/Regulatory/Banxico/` · 30 reglas

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-1253 | FÓRMULA | `sp_alertasabonospei` L67 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_abono_spei.txt` |
| BR-IFX-1254 | FÓRMULA | `sp_alertasabonospei` L70 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `vstmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/abonos` |
| BR-IFX-1255 | FÓRMULA | `sp_alertasabonosspei` L67 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_abono_spei.txt` |
| BR-IFX-1256 | FÓRMULA | `sp_alertasabonosspei` L70 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `vstmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/abonos` |
| BR-IFX-1277 | FÓRMULA | `sp_regordenctecte_bex_codi` L259 | Reglas CoDi — Cobro Digital | `intBancoOrd = (vchrparametro * 1)` |
| BR-IFX-1278 | VALIDACIÓN | `sp_regordenctecte_bex_codi` L205 | Reglas CoDi — Cobro Digital | `LET vcodret = ''` |
| BR-IFX-1279 | VALIDACIÓN | `sp_regordenctecte_bex_codi` L247 | Reglas CoDi — Cobro Digital | `LET vchrcodret = '000'` |
| BR-IFX-1280 | VALIDACIÓN | `sp_regordenctecte_bex_codi` L263 | Reglas CoDi — Cobro Digital | `LET vchrcodret = '011'` |
| BR-IFX-1281 | FÓRMULA | `sp_regordenctecte_bex_codi_exp1` L260 | Reglas CoDi — Cobro Digital | `intBancoOrd = (vchrparametro * 1)` |
| BR-IFX-1282 | VALIDACIÓN | `sp_regordenctecte_bex_codi_exp1` L205 | Reglas CoDi — Cobro Digital | `LET vcodret = ''` |
| BR-IFX-1283 | VALIDACIÓN | `sp_regordenctecte_bex_codi_exp1` L248 | Reglas CoDi — Cobro Digital | `LET vchrcodret = '000'` |
| BR-IFX-1284 | VALIDACIÓN | `sp_regordenctecte_bex_codi_exp1` L264 | Reglas CoDi — Cobro Digital | `LET vchrcodret = '011'` |
| BR-IFX-1285 | FÓRMULA | `spei_calculointeres` L112 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `vMontoPgo = ROUND((((cTsaPond * vImporte) * vDifmins ) / 518400),2)` |
| BR-IFX-1286 | VALIDACIÓN | `spei_calculointeres` L32 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `LET cCodret = '000'` |
| BR-IFX-1287 | VALIDACIÓN | `spei_calculointeres` L154 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `LET cCodret='100'` |
| BR-IFX-1288 | FÓRMULA | `spei_calculointeres_pba` L112 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `vMontoPgo = ROUND((((cTsaPond * vImporte) * vDifmins ) / 518400),2)` |
| BR-IFX-1289 | VALIDACIÓN | `spei_calculointeres_pba` L32 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `LET cCodret = '000'` |
| BR-IFX-1290 | VALIDACIÓN | `spei_calculointeres_pba` L154 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `LET cCodret='100'` |
| BR-IFX-1291 | FÓRMULA | `spei_devcodi` L571 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `intBancoOrd = (vchrparametro * 1)` |
| BR-IFX-1292 | VALIDACIÓN | `spei_devcodi` L217 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `LET vcodret = ''` |
| BR-IFX-1293 | VALIDACIÓN | `spei_devcodi` L292 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `LET vchrcodret = '000'` |
| BR-IFX-1294 | VALIDACIÓN | `spei_devcodi` L331 | Circular 3/2012 SPEI — irrevocabilidad, clave de | `LET vchrcodret = '012'` |

### CONDUSEF — SME Regulatorio — CONDUSEF
> Corpus: `SME/Regulatory/CONDUSEF/` · 202 reglas

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-002 | VALIDACIÓN | `sp_obt_comision_reposiciontkn` L15 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET cCodret = '00000'` |
| BR-IFX-003 | VALIDACIÓN | `sp_obt_comision_reposiciontkn_web` L15 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET cCodret = '00000'` |
| BR-IFX-005 | FÓRMULA | `abono_ctas_comis` L87 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/comisionesxabonar.unl ` |
| BR-IFX-006 | FÓRMULA | `abono_ctas_comis_pba` L87 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/comisionesxabonar.unl ` |
| BR-IFX-015 | VALIDACIÓN | `busca_folio_comision` L19 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `let vcodret = "000"` |
| BR-IFX-016 | VALIDACIÓN | `busca_folio_comision` L25 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `let vcodret = "001"` |
| BR-IFX-017 | VALIDACIÓN | `busca_folio_comision` L37 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `let vcodret = "002"` |
| BR-IFX-064 | FÓRMULA | `cargo_comisiones_pba` L143 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` |
| BR-IFX-065 | FÓRMULA | `cargo_comisiones_pba` L169 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` |
| BR-IFX-066 | FÓRMULA | `cargo_comisiones_pba` L173 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vIVA = TRUNC((vMontoCom * vValIva),2)` |
| BR-IFX-067 | VALIDACIÓN | `cargo_comisiones_pba` L51 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET eCodRet = "000"` |
| BR-IFX-068 | VALIDACIÓN | `cargo_comisiones_pba` L88 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET eCodRet = '110'` |
| BR-IFX-069 | VALIDACIÓN | `cargo_comisiones_pba` L100 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET eCodRet = '000'` |
| BR-IFX-070 | FÓRMULA | `cargo_comisiones_per` L171 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` |
| BR-IFX-071 | FÓRMULA | `cargo_comisiones_per` L199 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` |
| BR-IFX-072 | FÓRMULA | `cargo_comisiones_per` L203 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vIVA = TRUNC((vMontoCom * vValIva),2)` |
| BR-IFX-073 | VALIDACIÓN | `cargo_comisiones_per` L59 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET eCodRet = "000"` |
| BR-IFX-074 | VALIDACIÓN | `cargo_comisiones_per` L105 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET eCodRet = '110'` |
| BR-IFX-075 | VALIDACIÓN | `cargo_comisiones_per` L124 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET eCodRet = '420'` |
| BR-IFX-076 | FÓRMULA | `cargo_comisiones_per_web` L169 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` |
| BR-IFX-077 | FÓRMULA | `cargo_comisiones_per_web` L197 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` |
| BR-IFX-078 | FÓRMULA | `cargo_comisiones_per_web` L201 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `vIVA = TRUNC((vMontoCom * vValIva),2)` |
| BR-IFX-079 | VALIDACIÓN | `cargo_comisiones_per_web` L59 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET eCodRet = "00000"` |
| BR-IFX-080 | VALIDACIÓN | `cargo_comisiones_per_web` L104 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET eCodRet = '110'` |
| BR-IFX-081 | VALIDACIÓN | `cargo_comisiones_per_web` L121 | LTOSF Art.17 (CAT) + RECO — comisión debe estar  | `LET eCodRet = '420'` |

### SAT — SME Regulatorio — SAT
> Corpus: `SME/Regulatory/SAT/` · 87 reglas

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-007 | FÓRMULA | `abono_ctas_ivas` L87 | LIVA — IVA sobre comisiones (16% / 8% frontera) | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ivasxabonar.unl DELIMI` |
| BR-IFX-025 | FÓRMULA | `calc_isr` L116 | LISR Art.54/135 — retención de ISR sobre interes | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobas` |
| BR-IFX-026 | FÓRMULA | `calc_isr` L122 | LISR Art.54/135 — retención de ISR sobre interes | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` |
| BR-IFX-027 | FÓRMULA | `calc_isr` L127 | LISR Art.54/135 — retención de ISR sobre interes | `vimp_isr = trunc( ( psdo_promedio * vtasa_isr_tr ), 2 )` |
| BR-IFX-029 | FÓRMULA | `calc_isr_proy` L117 | LISR Art.54/135 — retención de ISR sobre interes | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobas` |
| BR-IFX-030 | FÓRMULA | `calc_isr_proy` L118 | LISR Art.54/135 — retención de ISR sobre interes | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` |
| BR-IFX-122 | FÓRMULA | `sp_blqdesconcentractasinactivas` L247 | LIVA — IVA sobre comisiones (16% / 8% frontera) | `vIsrCalc = (mBase_gravable * (dPorRetSuj/100)) * iDias / iAniobase` |
| BR-IFX-123 | FÓRMULA | `sp_blqdesconcentractasinactivas` L252 | LIVA — IVA sobre comisiones (16% / 8% frontera) | `vIsrCalc = (vSdoActual * (dPorRetSuj/100)) * iDias / iAniobase` |
| BR-IFX-127 | FÓRMULA | `sp_calcsdo_ctasinactivas` L184 | LIVA — IVA sobre comisiones (16% / 8% frontera) | `vIntereses = (((pSdoConcentrado * vAjustexInf) / 365) * vDias)` |
| BR-IFX-128 | FÓRMULA | `sp_calcsdo_ctasinactivas` L225 | LISR Art.54/135 — retención de ISR sobre interes | `vTasa_ISR = TRUNC( ( ( ( vPorRetSuj / 100 ) * vDias ) / 365 ), 6 )` |
| BR-IFX-129 | FÓRMULA | `sp_calcsdo_ctasinactivas` L231 | LISR Art.54/135 — retención de ISR sobre interes | `vISR = TRUNC( ( vBaseGravable * vTasa_ISR ), 2 )` |
| BR-IFX-130 | FÓRMULA | `sp_calcsdo_ctasinactivas` L236 | LISR Art.54/135 — retención de ISR sobre interes | `vISR = TRUNC( ( pSdoConcentrado * vTasa_ISR ), 2 )` |
| BR-IFX-132 | FÓRMULA | `sp_calcsdoctainactiva` L251 | LISR Art.54/135 — retención de ISR sobre interes | `vTasa_ISR = TRUNC( ( ( ( vPorRetSuj / 100 ) * vDias ) / 365 ), 6 )` |
| BR-IFX-133 | FÓRMULA | `sp_calcsdoctainactiva` L257 | LISR Art.54/135 — retención de ISR sobre interes | `vISR = TRUNC( ( vBaseGravable * vTasa_ISR ), 2 )` |
| BR-IFX-134 | FÓRMULA | `sp_calcsdoctainactiva` L262 | LISR Art.54/135 — retención de ISR sobre interes | `vISR = TRUNC( ( vSaldoConcentrado * vTasa_ISR ), 2 )` |
| BR-IFX-154 | FÓRMULA | `sp_calculaintaclaraciones` L198 | LISR Art.54/135 — retención de ISR sobre interes | `vtasa_isr = TRUNC( ( ( vvalorISR * vdias ) / vaniobase ), 6 )` |
| BR-IFX-155 | FÓRMULA | `sp_calculaintaclaraciones` L204 | LISR Art.54/135 — retención de ISR sobre interes | `visr = TRUNC( ( vbase_gravable * vtasa_isr ), 2 )` |
| BR-IFX-156 | FÓRMULA | `sp_calculaintaclaraciones` L209 | LISR Art.54/135 — retención de ISR sobre interes | `visr = TRUNC( ( pmonto * vtasa_isr ), 2 )` |
| BR-IFX-157 | FÓRMULA | `sp_cancelactasinactivas` L158 | LIVA — IVA sobre comisiones (16% / 8% frontera) | `vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conci` |
| BR-IFX-163 | VALIDACIÓN | `sp_cargadesconcentracionctasmasivas` L30 | LIVA — IVA sobre comisiones (16% / 8% frontera) | `LET cCodRet = '00000'` |
| BR-IFX-164 | VALIDACIÓN | `sp_cargadesconcentracionctasmasivas` L70 | LIVA — IVA sobre comisiones (16% / 8% frontera) | `LET cCodRet = '00003'` |
| BR-IFX-165 | VALIDACIÓN | `sp_cargadesconcentracionctasmasivas` L156 | LIVA — IVA sobre comisiones (16% / 8% frontera) | `LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO` |

### TESOFE — SME Regulatorio — TESOFE
> Corpus: `SME/Regulatory/TESOFE/` · 38 reglas

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-193 | VALIDACIÓN | `sp_conciliaciondispersionnomina_his` L38 | LTF — dispersión de recursos federales | `LET v_cCodRet = "000"` |
| BR-IFX-194 | VALIDACIÓN | `sp_conciliaciondispersionnomina_his` L91 | LTF — dispersión de recursos federales | `LET v_cCodRet = "110"; /* datos insuficientes */` |
| BR-IFX-214 | VALIDACIÓN | `sp_consulta_dispersion_poraplicar_canceladas` L26 | LTF — dispersión de recursos federales | `LET v_cCodRet = "00000"` |
| BR-IFX-215 | VALIDACIÓN | `sp_consulta_dispersion_poraplicar_canceladas` L72 | LTF — dispersión de recursos federales | `LET v_cCodRet = "00001"` |
| BR-IFX-216 | VALIDACIÓN | `sp_consulta_dispersion_poraplicar_canceladas` L288 | LTF — dispersión de recursos federales | `LET v_cCodRet ='00002'` |
| BR-IFX-239 | FÓRMULA | `sp_dispersionlinea_bei` L100 | LTF — dispersión de recursos federales | `pIvaDisp = pCargoDisp * mMontoTransIvaDisp` |
| BR-IFX-240 | VALIDACIÓN | `sp_dispersionlinea_bei` L31 | LTF — dispersión de recursos federales | `LET vcodret = "00000"` |
| BR-IFX-241 | FÓRMULA | `sp_dispersionlinea_bpi` L102 | LTF — dispersión de recursos federales | `pIvaDisp = pCargoDisp * mMontoTransIvaDisp` |
| BR-IFX-242 | VALIDACIÓN | `sp_dispersionlinea_bpi` L32 | LTF — dispersión de recursos federales | `LET vcodret = "00000"` |
| BR-IFX-243 | FÓRMULA | `sp_dispersionlinea_bpi_pba2` L96 | LTF — dispersión de recursos federales | `pIvaDisp = pCargoDisp * mMontoTransIvaDisp` |
| BR-IFX-244 | VALIDACIÓN | `sp_dispersionlinea_bpi_pba2` L28 | LTF — dispersión de recursos federales | `LET vcodret = "00000"` |
| BR-IFX-245 | VALIDACIÓN | `sp_dispersionnominatransacciones` L21 | LTF — dispersión de recursos federales | `LET vCodRet = "000"` |
| BR-IFX-246 | VALIDACIÓN | `sp_dispersionnominatransacciones` L86 | LTF — dispersión de recursos federales | `LET vCodRet = '840'` |
| BR-IFX-247 | VALIDACIÓN | `sp_dispersionnominatransacciones` L88 | LTF — dispersión de recursos federales | `LET vCodRet = '845'` |
| BR-IFX-248 | VALIDACIÓN | `sp_dispersionnominavalidacionestatus` L40 | LTF — dispersión de recursos federales | `LET vcodret = "000"` |
| BR-IFX-249 | VALIDACIÓN | `sp_dispersionnominavalidacionestatus` L60 | LTF — dispersión de recursos federales | `LET vcodret = '805'` |
| BR-IFX-250 | VALIDACIÓN | `sp_dispersionnominavalidacionestatus` L76 | LTF — dispersión de recursos federales | `Let vcodret = "815"` |
| BR-IFX-251 | VALIDACIÓN | `sp_dispersionnominavalidacionestatus_bpi` L40 | LTF — dispersión de recursos federales | `LET vcodret = "000"` |
| BR-IFX-252 | VALIDACIÓN | `sp_dispersionnominavalidacionestatus_bpi` L60 | LTF — dispersión de recursos federales | `LET vcodret = '805'` |
| BR-IFX-253 | VALIDACIÓN | `sp_dispersionnominavalidacionestatus_bpi` L76 | LTF — dispersión de recursos federales | `Let vcodret = "815"` |
| BR-IFX-254 | VALIDACIÓN | `sp_dispersionprogramada_bpi` L10 | LTF — dispersión de recursos federales | `LET vcodret = "000"` |
| BR-IFX-255 | VALIDACIÓN | `sp_dispersiontraspasomovtos` L12 | LTF — dispersión de recursos federales | `LET cCodRet = '00000'` |
| BR-IFX-256 | VALIDACIÓN | `sp_dispersiontraspasomovtos` L50 | LTF — dispersión de recursos federales | `LET cCodRet = '00001'` |
| BR-IFX-273 | VALIDACIÓN | `sp_nominadispersiondetalle_bei` L58 | LTF — dispersión de recursos federales | `LET v_cCodRet = "00000"` |
| BR-IFX-274 | VALIDACIÓN | `sp_nominadispersiondetalle_bei` L97 | LTF — dispersión de recursos federales | `LET v_cCodRet = "00001"` |

### IPAB — SME Regulatorio — IPAB
> Corpus: `SME/Regulatory/IPAB/` · 9 reglas

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-516 | VALIDACIÓN | `sp_ipab_consulta_fideicomiso` L44 | LPAB Art.22 — cuota ordinaria 4 al millar sobre  | `LET cCodRet = '00000'` |
| BR-IFX-517 | VALIDACIÓN | `sp_ipab_consulta_fideicomiso` L74 | LPAB Art.22 — cuota ordinaria 4 al millar sobre  | `LET cCodRet = '00003'` |
| BR-IFX-518 | VALIDACIÓN | `sp_ipab_consulta_fideicomiso` L89 | LPAB Art.22 — cuota ordinaria 4 al millar sobre  | `LET cCodRet = '00981'; -- El usuario no tiene una area designada` |
| BR-IFX-519 | VALIDACIÓN | `sp_ipab_ope_fideicomiso` L49 | LPAB Art.22 — cuota ordinaria 4 al millar sobre  | `LET cCodRet = '00000'` |
| BR-IFX-520 | VALIDACIÓN | `sp_ipab_ope_fideicomiso` L80 | LPAB Art.22 — cuota ordinaria 4 al millar sobre  | `LET cCodRet = '00003'` |
| BR-IFX-521 | FÓRMULA | `sp_ipab_repfideicomisomarcajeipab` L84 | LPAB Art.22 — cuota ordinaria 4 al millar sobre  | `cCmd1 = ""//TRIM(cCmd1)//" UNION ALL SELECT * FROM (SELECT f.no_fideic` |
| BR-IFX-522 | VALIDACIÓN | `sp_ipab_repfideicomisomarcajeipab` L25 | LPAB Art.22 — cuota ordinaria 4 al millar sobre  | `LET cCodRet = '00000'` |
| BR-IFX-523 | VALIDACIÓN | `sp_ipab_repfideicomisomarcajeipab` L49 | LPAB Art.22 — cuota ordinaria 4 al millar sobre  | `LET cCodRet = '00003'` |
| BR-IFX-524 | VALIDACIÓN | `sp_ipab_repfideicomisomarcajeipab` L71 | LPAB Art.22 — cuota ordinaria 4 al millar sobre  | `LET cCodRet = '00017'` |

---

## Riesgos de equivalencia consolidados `[RIESGO-EQUIVALENCIA]`

Semántica Informix en fórmulas financieras que **debe validarse con golden master** antes de transpilar:

- **Base de cálculo de interés `/360` vs `/365`:** año comercial vs año natural — una diferencia sistemática en todos los intereses. Debe confirmarse con el SME cuál aplica por producto.
- **`TRUNC` vs `ROUND`:** Informix trunca (no redondea) en las fórmulas de ISR e interés; el target debe replicar TRUNC exacto o divergirá por centavos en cada cálculo — **auditable ante SAT/CNBV**.
- **Tipo `MONEY`:** Informix aplica banker's rounding por defecto; PostgreSQL `NUMERIC` no. Toda aritmética sobre MONEY es `[RIESGO-EQUIVALENCIA]` crítico.
- **Tasa `/100`:** conversión de porcentaje a decimal — verificar precisión (DECIMAL vs FLOAT).

## Método de validación (HITL con SMEs reguladores)

```
1. Cada fórmula/regla → se envía al SME regulador dueño (tabla arriba)
2. El SME valida contra su corpus normativo (ej. SAT confirma tasa ISR y base de cálculo)
3. Se define el golden master test que preserva la fórmula exacta (incl. TRUNC/base)
4. Equivalencia ≥ 99.95% obligatoria en cálculos financieros (auditable)
```

*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: source/ + extract-rules.py · coordina con SMEs en SME/Regulatory/*