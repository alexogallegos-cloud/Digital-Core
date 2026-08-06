# BCOPCore · Paquetes de Validación Regulatoria (HITL)

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction  
> **Generado:** 2026-07-04 · Insumo para las sesiones de validación con los **SMEs reguladores**  

Para cada regulador: el **packet `[INVOKE]`** hacia su agente SME, las **preguntas específicas** de validación (derivadas de las fórmulas/reglas halladas en el código) y las **reglas a validar**. Cada respuesta del SME se incorpora al golden master (equivalencia ≥ 99.95% en cálculos financieros).

---

## CNBV — SME Regulatorio
> Agente: `SME/Regulatory/CNBV/` · **360 reglas relevantes** (178 fórmulas) · dominios: D01, D02, D03, D04, D06, D08, D11, bdiburo, bdicorresp, bdinvers

### Packet `[INVOKE]`
```
[INVOKE: SME Regulatorio — CNBV en SME/Regulatory/CNBV/]
COMPONENTE   : BCOPCore · SPE-AM-001 · Etapa 3 Business Logic Extraction
SOLICITUD    : Validar 360 reglas/fórmulas de negocio extraídas del código SPL
ALCANCE      : Fórmulas financieras y validaciones con impacto CNBV
DOMINIOS     : D01, D02, D03, D04, D06, D08, D11, bdiburo, bdicorresp, bdinvers
ENTREGABLE   : Confirmación de cada fórmula + parámetros (tasas, bases, plazos) +
               definición del golden master test por regla
CRITICIDAD   : Equivalencia ≥ 99.95% (auditable ante CNBV)
```

### Preguntas de validación
- [ ] Base de cálculo de interés: `calc_interes` usa **/360** y `calcula_int` usa `vnumdias` — ¿confirmar 360 vs 365 por producto?
- [ ] **Art.61 LIC** (cuentas inactivas): `sp_blqdesconcentractasinactivas` procesa cuentas inactivas — ¿plazo (3 años) y proceso de traspaso a beneficencia pública correctos?
- [ ] **Atomicidad** débito-crédito: `cargo_ref`/`abono_ref` — ¿el target debe garantizar ACID estricto (sin cargos parciales)?
- [ ] Criterios contables **B-1 a D-4**: ¿cuáles aplican a las fórmulas de reserva/moratorios (`sp_calculo_reserva_corte_crd`)?

### Reglas a validar (prioridad: fórmulas primero)

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-018 | FÓRMULA | `calc_int` L85 | Criterios contables CNBV + GAT — cálculo de  | `vsdo_prom = vacum_sdo_pos / vdia_sdo_pos` |
| BR-IFX-019 | FÓRMULA ⚠ | `calc_int` L117 | Criterios contables CNBV + GAT — cálculo de  | `vtot_int = vacum_sdo_pos * vvalor_tasa / 100 / 360` |
| BR-IFX-022 | FÓRMULA | `calc_interes` L92 | Criterios contables CNBV + GAT — cálculo de  | `vsdo_promedio = vacum_sdo_pos / vdia_sdo_pos` |
| BR-IFX-023 | FÓRMULA ⚠ | `calc_interes` L100 | Criterios contables CNBV + GAT — cálculo de  | `vcalc_int = ((vacum_sdo_pos / vdia_sdo_pos) * vtasa) * vdia_sdo_pos / 36` |
| BR-IFX-025 | FÓRMULA ⚠ | `calc_isr` L116 | Criterios contables CNBV + GAT — cálculo de  | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobase ` |
| BR-IFX-026 | FÓRMULA ⚠ | `calc_isr` L122 | Criterios contables CNBV + GAT — cálculo de  | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` |
| BR-IFX-027 | FÓRMULA ⚠ | `calc_isr` L127 | Criterios contables CNBV + GAT — cálculo de  | `vimp_isr = trunc( ( psdo_promedio * vtasa_isr_tr ), 2 )` |
| BR-IFX-029 | FÓRMULA ⚠ | `calc_isr_proy` L117 | Criterios contables CNBV + GAT — cálculo de  | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobase ` |
| BR-IFX-030 | FÓRMULA ⚠ | `calc_isr_proy` L118 | Criterios contables CNBV + GAT — cálculo de  | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` |
| BR-IFX-038 | FÓRMULA | `calcula_int` L246 | Criterios contables CNBV + GAT — cálculo de  | `vvalor_tasa = vvaltasa / 100` |
| BR-IFX-039 | FÓRMULA | `calcula_int` L320 | Criterios contables CNBV + GAT — cálculo de  | `vtotint = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` |
| BR-IFX-040 | FÓRMULA | `calcula_int` L365 | Criterios contables CNBV + GAT — cálculo de  | `vvalor_tasa = vvaltasa/100` |
| BR-IFX-041 | FÓRMULA | `calcula_int` L373 | Criterios contables CNBV + GAT — cálculo de  | `vgacum_sdo_int = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vn` |
| BR-IFX-043 | FÓRMULA | `calcula_int` L464 | Criterios contables CNBV + GAT — cálculo de  | `vtotint = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vnumdias)` |
| BR-IFX-044 | FÓRMULA | `calcula_int` L778 | Criterios contables CNBV + GAT — cálculo de  | `vintdia = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` |
| BR-IFX-047 | FÓRMULA | `calcula_int_pba` L222 | Criterios contables CNBV + GAT — cálculo de  | `vvalor_tasa = vvaltasa / 100` |
| BR-IFX-048 | FÓRMULA | `calcula_int_pba` L272 | Criterios contables CNBV + GAT — cálculo de  | `vtotint = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` |
| BR-IFX-049 | FÓRMULA | `calcula_int_pba` L317 | Criterios contables CNBV + GAT — cálculo de  | `vvalor_tasa = vvaltasa/100` |
| BR-IFX-050 | FÓRMULA | `calcula_int_pba` L325 | Criterios contables CNBV + GAT — cálculo de  | `vgacum_sdo_int = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vn` |
| BR-IFX-052 | FÓRMULA | `calcula_int_pba` L400 | Criterios contables CNBV + GAT — cálculo de  | `vtotint = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vnumdias)` |
| BR-IFX-053 | FÓRMULA | `calcula_int_pba` L693 | Criterios contables CNBV + GAT — cálculo de  | `vintdia = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` |
| BR-IFX-056 | FÓRMULA | `calcula_intqra` L211 | Criterios contables CNBV + GAT — cálculo de  | `vvalor_tasa = vvaltasa / 100` |
| BR-IFX-057 | FÓRMULA | `calcula_intqra` L255 | Criterios contables CNBV + GAT — cálculo de  | `vtotint = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` |
| BR-IFX-058 | FÓRMULA | `calcula_intqra` L295 | Criterios contables CNBV + GAT — cálculo de  | `vvalor_tasa = vvaltasa/100` |
| BR-IFX-059 | FÓRMULA | `calcula_intqra` L301 | Criterios contables CNBV + GAT — cálculo de  | `vgraacum_sdo_int = ((((vgraacum_sdo_pos / vgradia_sdo_pos) * vvalor_tasa` |
| BR-IFX-061 | FÓRMULA | `calcula_intqra` L378 | Criterios contables CNBV + GAT — cálculo de  | `vtotint = ((((vgraacum_sdo_pos / vgradia_sdo_pos) * vvalor_tasa) / vnumd` |
| BR-IFX-062 | FÓRMULA | `calcula_intqra` L617 | Criterios contables CNBV + GAT — cálculo de  | `vintdia = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom)` |
| BR-IFX-108 | FÓRMULA | `conisr_anual` L361 | Criterios contables CNBV + GAT — cálculo de  | `vtasapromedio = (((vtasaprom / 100) / vdiasanio) * vdiasdopos)` |
| BR-IFX-109 | FÓRMULA | `conisr_anual` L363 | Criterios contables CNBV + GAT — cálculo de  | `vtasapromedio = ((vtasaprom / vdiasanio) * vdiasdopos)` |
| BR-IFX-111 | FÓRMULA | `conisr_anual` L434 | Criterios contables CNBV + GAT — cálculo de  | `vtasapromanual = vtasapromanual / vmeses` |
| … | | | | *(+330 reglas más en `business-rules-bcop.md`)* |

---

## Banxico — SME Regulatorio
> Agente: `SME/Regulatory/Banxico/` · **24 reglas relevantes** (11 fórmulas) · dominios: D08

### Packet `[INVOKE]`
```
[INVOKE: SME Regulatorio — Banxico en SME/Regulatory/Banxico/]
COMPONENTE   : BCOPCore · SPE-AM-001 · Etapa 3 Business Logic Extraction
SOLICITUD    : Validar 24 reglas/fórmulas de negocio extraídas del código SPL
ALCANCE      : Fórmulas financieras y validaciones con impacto Banxico
DOMINIOS     : D08
ENTREGABLE   : Confirmación de cada fórmula + parámetros (tasas, bases, plazos) +
               definición del golden master test por regla
CRITICIDAD   : Equivalencia ≥ 99.95% (auditable ante Banxico)
```

### Preguntas de validación
- [ ] **Clave de rastreo SPEI** (30 posiciones): ¿la generación en `sp_regordenctecte_bex_codi` cumple Circular 3/2012?
- [ ] **CoDi**: reglas de cobro digital en los SPs `*_codi` — ¿validación de mensajes conforme a especificación Banxico?
- [ ] Migración **ISO 20022**: ¿pendiente? ¿impacta el formato de estos SPs?
- [ ] Ventana SPEI (mantenimiento sábado 22:00–domingo 06:00): ¿se refleja en la lógica de envío?

### Reglas a validar (prioridad: fórmulas primero)

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-1253 | FÓRMULA | `sp_alertasabonospei` L67 | Circular 3/2012 SPEI — irrevocabilidad, clav | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_abono_spei.txt I` |
| BR-IFX-1254 | FÓRMULA | `sp_alertasabonospei` L70 | Circular 3/2012 SPEI — irrevocabilidad, clav | `vstmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/abonospe` |
| BR-IFX-1255 | FÓRMULA | `sp_alertasabonosspei` L67 | Circular 3/2012 SPEI — irrevocabilidad, clav | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_abono_spei.txt I` |
| BR-IFX-1256 | FÓRMULA | `sp_alertasabonosspei` L70 | Circular 3/2012 SPEI — irrevocabilidad, clav | `vstmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/abonospe` |
| BR-IFX-1277 | FÓRMULA | `sp_regordenctecte_bex_codi` L259 | Reglas CoDi — Cobro Digital | `intBancoOrd = (vchrparametro * 1)` |
| BR-IFX-1281 | FÓRMULA | `sp_regordenctecte_bex_codi_exp1` L260 | Reglas CoDi — Cobro Digital | `intBancoOrd = (vchrparametro * 1)` |
| BR-IFX-1285 | FÓRMULA ⚠ | `spei_calculointeres` L112 | Circular 3/2012 SPEI — irrevocabilidad, clav | `vMontoPgo = ROUND((((cTsaPond * vImporte) * vDifmins ) / 518400),2)` |
| BR-IFX-1288 | FÓRMULA ⚠ | `spei_calculointeres_pba` L112 | Circular 3/2012 SPEI — irrevocabilidad, clav | `vMontoPgo = ROUND((((cTsaPond * vImporte) * vDifmins ) / 518400),2)` |
| BR-IFX-1291 | FÓRMULA | `spei_devcodi` L571 | Circular 3/2012 SPEI — irrevocabilidad, clav | `intBancoOrd = (vchrparametro * 1)` |
| BR-IFX-1296 | FÓRMULA | `spei_recordenpago` L602 | Circular 3/2012 SPEI — irrevocabilidad, clav | `vmonto_udi = pmnyimporte / vprecio_udi` |
| BR-IFX-1297 | FÓRMULA | `spei_recordenpago_ws` L1133 | Circular 3/2012 SPEI — irrevocabilidad, clav | `vmonto_udi = pmnyimporte / vprecio_udi` |
| BR-IFX-1278 | VALIDACIÓN | `sp_regordenctecte_bex_codi` L205 | Reglas CoDi — Cobro Digital | `LET vcodret = ''` |
| BR-IFX-1279 | VALIDACIÓN | `sp_regordenctecte_bex_codi` L247 | Reglas CoDi — Cobro Digital | `LET vchrcodret = '000'` |
| BR-IFX-1280 | VALIDACIÓN | `sp_regordenctecte_bex_codi` L263 | Reglas CoDi — Cobro Digital | `LET vchrcodret = '011'` |
| BR-IFX-1282 | VALIDACIÓN | `sp_regordenctecte_bex_codi_exp1` L205 | Reglas CoDi — Cobro Digital | `LET vcodret = ''` |
| BR-IFX-1283 | VALIDACIÓN | `sp_regordenctecte_bex_codi_exp1` L248 | Reglas CoDi — Cobro Digital | `LET vchrcodret = '000'` |
| BR-IFX-1284 | VALIDACIÓN | `sp_regordenctecte_bex_codi_exp1` L264 | Reglas CoDi — Cobro Digital | `LET vchrcodret = '011'` |
| BR-IFX-1286 | VALIDACIÓN | `spei_calculointeres` L32 | Circular 3/2012 SPEI — irrevocabilidad, clav | `LET cCodret = '000'` |
| BR-IFX-1287 | VALIDACIÓN | `spei_calculointeres` L154 | Circular 3/2012 SPEI — irrevocabilidad, clav | `LET cCodret='100'` |
| BR-IFX-1289 | VALIDACIÓN | `spei_calculointeres_pba` L32 | Circular 3/2012 SPEI — irrevocabilidad, clav | `LET cCodret = '000'` |
| BR-IFX-1290 | VALIDACIÓN | `spei_calculointeres_pba` L154 | Circular 3/2012 SPEI — irrevocabilidad, clav | `LET cCodret='100'` |
| BR-IFX-1292 | VALIDACIÓN | `spei_devcodi` L217 | Circular 3/2012 SPEI — irrevocabilidad, clav | `LET vcodret = ''` |
| BR-IFX-1293 | VALIDACIÓN | `spei_devcodi` L292 | Circular 3/2012 SPEI — irrevocabilidad, clav | `LET vchrcodret = '000'` |
| BR-IFX-1294 | VALIDACIÓN | `spei_devcodi` L331 | Circular 3/2012 SPEI — irrevocabilidad, clav | `LET vchrcodret = '012'` |

---

## CONDUSEF — SME Regulatorio
> Agente: `SME/Regulatory/CONDUSEF/` · **156 reglas relevantes** (79 fórmulas) · dominios: D01, D02, D03, D04, D05, D08, bdicorresp, bdidomi, bdiprog, intercard

### Packet `[INVOKE]`
```
[INVOKE: SME Regulatorio — CONDUSEF en SME/Regulatory/CONDUSEF/]
COMPONENTE   : BCOPCore · SPE-AM-001 · Etapa 3 Business Logic Extraction
SOLICITUD    : Validar 156 reglas/fórmulas de negocio extraídas del código SPL
ALCANCE      : Fórmulas financieras y validaciones con impacto CONDUSEF
DOMINIOS     : D01, D02, D03, D04, D05, D08, bdicorresp, bdidomi, bdiprog, intercard
ENTREGABLE   : Confirmación de cada fórmula + parámetros (tasas, bases, plazos) +
               definición del golden master test por regla
CRITICIDAD   : Equivalencia ≥ 99.95% (auditable ante CONDUSEF)
```

### Preguntas de validación
- [ ] Fórmula **GAT nominal** (`sp_cap_recalculagat1200`): `ROUND((POW((1+tasa/periodo),periodo)-1),2)` — ¿el `periodo` de capitalización es correcto por producto?
- [ ] **GAT real**: ajuste por inflación `(1+GAT_nom)/(1+inflación)-1` — ¿la fuente de la inflación (`dMedianaInfl`) es el INPC/mediana Banxico vigente?
- [ ] **CAT** (Costo Anual Total): ¿se calcula con fórmula IRR? ¿en qué SP? (no detectado claramente en el código — confirmar).
- [ ] **Comisiones**: ¿todas las de `sp_consultacatcomisiones*` están registradas en **RECO** con el monto exacto del código?
- [ ] Comisión de apertura `ROUND(monto/12,2)` (`sp_comisionxapertura_contable`) — ¿prorrateo correcto?

### Reglas a validar (prioridad: fórmulas primero)

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-005 | FÓRMULA | `abono_ctas_comis` L87 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/comisionesxabonar.unl DE` |
| BR-IFX-006 | FÓRMULA | `abono_ctas_comis_pba` L87 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/comisionesxabonar.unl DE` |
| BR-IFX-064 | FÓRMULA | `cargo_comisiones_pba` L143 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` |
| BR-IFX-065 | FÓRMULA ⚠ | `cargo_comisiones_pba` L169 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` |
| BR-IFX-066 | FÓRMULA ⚠ | `cargo_comisiones_pba` L173 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vIVA = TRUNC((vMontoCom * vValIva),2)` |
| BR-IFX-070 | FÓRMULA | `cargo_comisiones_per` L171 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` |
| BR-IFX-071 | FÓRMULA ⚠ | `cargo_comisiones_per` L199 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` |
| BR-IFX-072 | FÓRMULA ⚠ | `cargo_comisiones_per` L203 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vIVA = TRUNC((vMontoCom * vValIva),2)` |
| BR-IFX-076 | FÓRMULA | `cargo_comisiones_per_web` L169 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` |
| BR-IFX-077 | FÓRMULA ⚠ | `cargo_comisiones_per_web` L197 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` |
| BR-IFX-078 | FÓRMULA ⚠ | `cargo_comisiones_per_web` L201 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vIVA = TRUNC((vMontoCom * vValIva),2)` |
| BR-IFX-082 | FÓRMULA | `cargo_comisiones_web` L171 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vMontoCom = eMOnto * vFactorAplic; -- Por Factor` |
| BR-IFX-083 | FÓRMULA ⚠ | `cargo_comisiones_web` L197 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vMontoCom = ROUND(vDisponible / (1 + vValIva),2)` |
| BR-IFX-084 | FÓRMULA ⚠ | `cargo_comisiones_web` L201 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `vIVA = TRUNC((vMontoCom * vValIva),2)` |
| BR-IFX-166 | FÓRMULA | `sp_cargoxcomision_pm` L284 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mValorSdoPos = mAcumSdoPos / iDiaSdoPos` |
| BR-IFX-167 | FÓRMULA ⚠ | `sp_cargoxcomision_pm` L527 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `dMontoAplica = ROUND(mDisponible / (1 + dValIva),2)` |
| BR-IFX-168 | FÓRMULA ⚠ | `sp_cargoxcomision_pm` L531 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mIva = TRUNC((dMontoAplica * dValIva),2)` |
| BR-IFX-170 | FÓRMULA | `sp_cargoxcomision_pm_comp2` L258 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mValorSdoPos = mAcumSdoPos / iDiaSdoPos` |
| BR-IFX-171 | FÓRMULA ⚠ | `sp_cargoxcomision_pm_comp2` L500 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `dMontoAplica = ROUND(mDisponible / (1 + dValIva),2)` |
| BR-IFX-172 | FÓRMULA ⚠ | `sp_cargoxcomision_pm_comp2` L504 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mIva = TRUNC((dMontoAplica * dValIva),2)` |
| BR-IFX-174 | FÓRMULA | `sp_cargoxcomision_pm_esp` L258 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mValorSdoPos = mAcumSdoPos / iDiaSdoPos` |
| BR-IFX-175 | FÓRMULA ⚠ | `sp_cargoxcomision_pm_esp` L501 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `dMontoAplica = ROUND(mDisponible / (1 + dValIva),2)` |
| BR-IFX-176 | FÓRMULA ⚠ | `sp_cargoxcomision_pm_esp` L505 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mIva = TRUNC((dMontoAplica * dValIva),2)` |
| BR-IFX-178 | FÓRMULA | `sp_cargoxcomision_pmcomp` L256 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mValorSdoPos = mAcumSdoPos / iDiaSdoPos` |
| BR-IFX-179 | FÓRMULA ⚠ | `sp_cargoxcomision_pmcomp` L498 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `dMontoAplica = ROUND(mDisponible / (1 + dValIva),2)` |
| BR-IFX-180 | FÓRMULA ⚠ | `sp_cargoxcomision_pmcomp` L502 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mIva = TRUNC((dMontoAplica * dValIva),2)` |
| BR-IFX-189 | FÓRMULA | `sp_cobrocomisionreposiciondebito` L96 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `cIvaCom = cMontoCom * cIvaCom` |
| BR-IFX-267 | FÓRMULA | `sp_nominaconsultasaldoeje` L120 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mTotalComision = pTotalRegistros * mMontoComisionDispercion` |
| BR-IFX-268 | FÓRMULA | `sp_nominaconsultasaldoeje` L121 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mTotaliva = mTotalComision * mValorIva; --Nueva Forma de Calcular el Iva` |
| BR-IFX-276 | FÓRMULA | `sp_nominatotalivacomision` L65 | LTOSF Art.17 (CAT) + RECO — comisión debe es | `mTotalComision = iNumeroRegistrosAplicados * mValorComisionDispercion` |
| … | | | | *(+126 reglas más en `business-rules-bcop.md`)* |

---

## SAT — SME Regulatorio
> Agente: `SME/Regulatory/SAT/` · **62 reglas relevantes** (41 fórmulas) · dominios: D01, D03, D04, D05, bdidomi, bdinvers

### Packet `[INVOKE]`
```
[INVOKE: SME Regulatorio — SAT en SME/Regulatory/SAT/]
COMPONENTE   : BCOPCore · SPE-AM-001 · Etapa 3 Business Logic Extraction
SOLICITUD    : Validar 62 reglas/fórmulas de negocio extraídas del código SPL
ALCANCE      : Fórmulas financieras y validaciones con impacto SAT
DOMINIOS     : D01, D03, D04, D05, bdidomi, bdinvers
ENTREGABLE   : Confirmación de cada fórmula + parámetros (tasas, bases, plazos) +
               definición del golden master test por regla
CRITICIDAD   : Equivalencia ≥ 99.95% (auditable ante SAT)
```

### Preguntas de validación
- [ ] Tasa de retención de ISR sobre intereses: el código usa `vtasa_isr` parametrizada — ¿el valor vigente es **0.90% anual** (LIF 2026)? ¿Cómo/cuándo se actualiza?
- [ ] Base de cálculo del ISR: `calc_isr` usa `vaniobase` (`… × días / vaniobase`) — ¿es **360** (año comercial) o **365**? Impacta todos los cálculos.
- [ ] Uso de **`TRUNC`** (no ROUND) en `calc_isr` — ¿es intencional y debe preservarse **exacto** en el target? Divergencia = observación SAT.
- [ ] ¿Aplica exención por **UMA** sobre intereses (monto exento)? ¿Dónde se calcula el importe gravable (`vbase_gravable`)?
- [ ] IVA: ¿**16% general / 8% frontera**? ¿Qué comisiones causan IVA y cuál es la fuente de la tasa por sucursal (`dIvaSuc`)?

### Reglas a validar (prioridad: fórmulas primero)

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-007 | FÓRMULA | `abono_ctas_ivas` L87 | LIVA — IVA sobre comisiones (16% / 8% fronte | `vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ivasxabonar.unl DELIMITE` |
| BR-IFX-025 | FÓRMULA ⚠ | `calc_isr` L116 | LISR Art.54/135 — retención de ISR sobre int | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobase ` |
| BR-IFX-026 | FÓRMULA ⚠ | `calc_isr` L122 | LISR Art.54/135 — retención de ISR sobre int | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` |
| BR-IFX-027 | FÓRMULA ⚠ | `calc_isr` L127 | LISR Art.54/135 — retención de ISR sobre int | `vimp_isr = trunc( ( psdo_promedio * vtasa_isr_tr ), 2 )` |
| BR-IFX-029 | FÓRMULA ⚠ | `calc_isr_proy` L117 | LISR Art.54/135 — retención de ISR sobre int | `vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobase ` |
| BR-IFX-030 | FÓRMULA ⚠ | `calc_isr_proy` L118 | LISR Art.54/135 — retención de ISR sobre int | `vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 )` |
| BR-IFX-122 | FÓRMULA | `sp_blqdesconcentractasinactivas` L247 | LIVA — IVA sobre comisiones (16% / 8% fronte | `vIsrCalc = (mBase_gravable * (dPorRetSuj/100)) * iDias / iAniobase` |
| BR-IFX-123 | FÓRMULA | `sp_blqdesconcentractasinactivas` L252 | LIVA — IVA sobre comisiones (16% / 8% fronte | `vIsrCalc = (vSdoActual * (dPorRetSuj/100)) * iDias / iAniobase` |
| BR-IFX-127 | FÓRMULA ⚠ | `sp_calcsdo_ctasinactivas` L184 | LIVA — IVA sobre comisiones (16% / 8% fronte | `vIntereses = (((pSdoConcentrado * vAjustexInf) / 365) * vDias)` |
| BR-IFX-128 | FÓRMULA ⚠ | `sp_calcsdo_ctasinactivas` L225 | LISR Art.54/135 — retención de ISR sobre int | `vTasa_ISR = TRUNC( ( ( ( vPorRetSuj / 100 ) * vDias ) / 365 ), 6 )` |
| BR-IFX-129 | FÓRMULA ⚠ | `sp_calcsdo_ctasinactivas` L231 | LISR Art.54/135 — retención de ISR sobre int | `vISR = TRUNC( ( vBaseGravable * vTasa_ISR ), 2 )` |
| BR-IFX-130 | FÓRMULA ⚠ | `sp_calcsdo_ctasinactivas` L236 | LISR Art.54/135 — retención de ISR sobre int | `vISR = TRUNC( ( pSdoConcentrado * vTasa_ISR ), 2 )` |
| BR-IFX-132 | FÓRMULA ⚠ | `sp_calcsdoctainactiva` L251 | LISR Art.54/135 — retención de ISR sobre int | `vTasa_ISR = TRUNC( ( ( ( vPorRetSuj / 100 ) * vDias ) / 365 ), 6 )` |
| BR-IFX-133 | FÓRMULA ⚠ | `sp_calcsdoctainactiva` L257 | LISR Art.54/135 — retención de ISR sobre int | `vISR = TRUNC( ( vBaseGravable * vTasa_ISR ), 2 )` |
| BR-IFX-134 | FÓRMULA ⚠ | `sp_calcsdoctainactiva` L262 | LISR Art.54/135 — retención de ISR sobre int | `vISR = TRUNC( ( vSaldoConcentrado * vTasa_ISR ), 2 )` |
| BR-IFX-154 | FÓRMULA ⚠ | `sp_calculaintaclaraciones` L198 | LISR Art.54/135 — retención de ISR sobre int | `vtasa_isr = TRUNC( ( ( vvalorISR * vdias ) / vaniobase ), 6 )` |
| BR-IFX-155 | FÓRMULA ⚠ | `sp_calculaintaclaraciones` L204 | LISR Art.54/135 — retención de ISR sobre int | `visr = TRUNC( ( vbase_gravable * vtasa_isr ), 2 )` |
| BR-IFX-156 | FÓRMULA ⚠ | `sp_calculaintaclaraciones` L209 | LISR Art.54/135 — retención de ISR sobre int | `visr = TRUNC( ( pmonto * vtasa_isr ), 2 )` |
| BR-IFX-157 | FÓRMULA | `sp_cancelactasinactivas` L158 | LIVA — IVA sobre comisiones (16% / 8% fronte | `vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/concili` |
| BR-IFX-232 | FÓRMULA ⚠ | `sp_corrige_isr` L170 | LISR Art.54/135 — retención de ISR sobre int | `dTasa_ISR = TRUNC( ( ( ( dTasaISR / 100 ) * iDias ) / iAnioBase ), 6 )` |
| BR-IFX-233 | FÓRMULA ⚠ | `sp_corrige_isr` L185 | LISR Art.54/135 — retención de ISR sobre int | `mISRCalculado = TRUNC( (mBaseGravable * dTasa_ISR ), 2)` |
| BR-IFX-268 | FÓRMULA | `sp_nominaconsultasaldoeje` L121 | LIVA — IVA sobre comisiones (16% / 8% fronte | `mTotaliva = mTotalComision * mValorIva; --Nueva Forma de Calcular el Iva` |
| BR-IFX-277 | FÓRMULA | `sp_nominatotalivacomision` L66 | LIVA — IVA sobre comisiones (16% / 8% fronte | `mTotaliva = mTotalComision * mValorIva; /* Nueva Forma de Calcular el Iv` |
| BR-IFX-281 | FÓRMULA | `sp_nominatotalivacomision_bpi` L73 | LIVA — IVA sobre comisiones (16% / 8% fronte | `mTotaliva = mTotalComision * mValorIva; /* Nueva Forma de Calcular el Iv` |
| BR-IFX-307 | FÓRMULA | `sp_reportactasinactivas` L274 | LIVA — IVA sobre comisiones (16% / 8% fronte | `vStmt = "sed 's/\\//g' /resplogifx/conciliachq/cuentasinactivas5000_prod` |
| BR-IFX-308 | FÓRMULA | `sp_reportactasinactivas` L279 | LIVA — IVA sobre comisiones (16% / 8% fronte | `vStmt = "rm /resplogifx/conciliachq/cuentasinactivas5000_prod"//vProduct` |
| BR-IFX-878 | FÓRMULA | `sp_genera_reporte_tc_inactivas` L249 | LIVA — IVA sobre comisiones (16% / 8% fronte | `cSql = 'echo " Set Isolation to dirty read; Unload to ' // '/resplogifx/` |
| BR-IFX-879 | FÓRMULA | `sp_genera_reporte_tc_inactivas` L257 | LIVA — IVA sobre comisiones (16% / 8% fronte | `cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Archivo_TC_Inactiva` |
| BR-IFX-880 | FÓRMULA | `sp_genera_reporte_tc_inactivas` L271 | LIVA — IVA sobre comisiones (16% / 8% fronte | `cSql = "sed 's//$//g' /resplogifx/archivoscartera/Archivo_TC_Inactivas.u` |
| BR-IFX-881 | FÓRMULA | `sp_genera_reporte_tc_inactivas` L275 | LIVA — IVA sobre comisiones (16% / 8% fronte | `cSql = 'rm /resplogifx/archivoscartera/Archivo_TC_Inactivas.sql'` |
| … | | | | *(+32 reglas más en `business-rules-bcop.md`)* |

---

## TESOFE — SME Regulatorio
> Agente: `SME/Regulatory/TESOFE/` · **28 reglas relevantes** (5 fórmulas) · dominios: D01, D04, bdiprog

### Packet `[INVOKE]`
```
[INVOKE: SME Regulatorio — TESOFE en SME/Regulatory/TESOFE/]
COMPONENTE   : BCOPCore · SPE-AM-001 · Etapa 3 Business Logic Extraction
SOLICITUD    : Validar 28 reglas/fórmulas de negocio extraídas del código SPL
ALCANCE      : Fórmulas financieras y validaciones con impacto TESOFE
DOMINIOS     : D01, D04, bdiprog
ENTREGABLE   : Confirmación de cada fórmula + parámetros (tasas, bases, plazos) +
               definición del golden master test por regla
CRITICIDAD   : Equivalencia ≥ 99.95% (auditable ante TESOFE)
```

### Preguntas de validación
- [ ] **Dispersión bimestral** (Pensión Bienestar / Becas): ¿la cadena TESOFE→SPEI→`abono_ref` es correcta? ¿ventana de cutover?
- [ ] **Cuenta concentradora**: ¿mecánica de sweeping y clasificación de fondos federales?

### Reglas a validar (prioridad: fórmulas primero)

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-239 | FÓRMULA | `sp_dispersionlinea_bei` L100 | LTF — dispersión de recursos federales | `pIvaDisp = pCargoDisp * mMontoTransIvaDisp` |
| BR-IFX-241 | FÓRMULA | `sp_dispersionlinea_bpi` L102 | LTF — dispersión de recursos federales | `pIvaDisp = pCargoDisp * mMontoTransIvaDisp` |
| BR-IFX-243 | FÓRMULA | `sp_dispersionlinea_bpi_pba2` L96 | LTF — dispersión de recursos federales | `pIvaDisp = pCargoDisp * mMontoTransIvaDisp` |
| BR-IFX-1081 | FÓRMULA | `sp_afore_dispersion` L327 | LTF — dispersión de recursos federales | `mIVAUnitario = mComisionCargo * dePorcIVA` |
| BR-IFX-1085 | FÓRMULA | `sp_aforedispersionautomatica` L38 | LTF — dispersión de recursos federales | `cCodRetInterno = '00000'; --DSB 12/03/2014` |
| BR-IFX-193 | VALIDACIÓN | `sp_conciliaciondispersionnomina_his` L38 | LTF — dispersión de recursos federales | `LET v_cCodRet = "000"` |
| BR-IFX-194 | VALIDACIÓN | `sp_conciliaciondispersionnomina_his` L91 | LTF — dispersión de recursos federales | `LET v_cCodRet = "110"; /* datos insuficientes */` |
| BR-IFX-215 | VALIDACIÓN | `sp_consulta_dispersion_poraplicar_canceladas` L72 | LTF — dispersión de recursos federales | `LET v_cCodRet = "00001"` |
| BR-IFX-216 | VALIDACIÓN | `sp_consulta_dispersion_poraplicar_canceladas` L288 | LTF — dispersión de recursos federales | `LET v_cCodRet ='00002'` |
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
| BR-IFX-256 | VALIDACIÓN | `sp_dispersiontraspasomovtos` L50 | LTF — dispersión de recursos federales | `LET cCodRet = '00001'` |
| BR-IFX-274 | VALIDACIÓN | `sp_nominadispersiondetalle_bei` L97 | LTF — dispersión de recursos federales | `LET v_cCodRet = "00001"` |
| BR-IFX-275 | VALIDACIÓN | `sp_nominadispersiondetalle_bei` L355 | LTF — dispersión de recursos federales | `LET v_cCodRet='00002'` |
| BR-IFX-499 | VALIDACIÓN | `sp_dispersionafore` L41 | LTF — dispersión de recursos federales | `LET cCodRet = '00003'` |
| BR-IFX-500 | VALIDACIÓN | `sp_dispersionafore` L54 | LTF — dispersión de recursos federales | `LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR` |
| BR-IFX-1083 | VALIDACIÓN | `sp_afore_dispersion` L173 | LTF — dispersión de recursos federales | `LET vcodret = '10011'` |
| BR-IFX-1084 | VALIDACIÓN | `sp_afore_dispersion` L193 | LTF — dispersión de recursos federales | `LET vcodret = '10013'` |
| BR-IFX-1087 | VALIDACIÓN | `sp_aforedispersionautomatica` L56 | LTF — dispersión de recursos federales | `LET vcodret = '10035'` |
| BR-IFX-1088 | VALIDACIÓN | `sp_aforedispersionautomatica` L71 | LTF — dispersión de recursos federales | `LET vcodret = '10011'` |

---

## IPAB — SME Regulatorio
> Agente: `SME/Regulatory/IPAB/` · **6 reglas relevantes** (1 fórmulas) · dominios: D01

### Packet `[INVOKE]`
```
[INVOKE: SME Regulatorio — IPAB en SME/Regulatory/IPAB/]
COMPONENTE   : BCOPCore · SPE-AM-001 · Etapa 3 Business Logic Extraction
SOLICITUD    : Validar 6 reglas/fórmulas de negocio extraídas del código SPL
ALCANCE      : Fórmulas financieras y validaciones con impacto IPAB
DOMINIOS     : D01
ENTREGABLE   : Confirmación de cada fórmula + parámetros (tasas, bases, plazos) +
               definición del golden master test por regla
CRITICIDAD   : Equivalencia ≥ 99.95% (auditable ante IPAB)
```

### Preguntas de validación
- [ ] **Cuota 4 al millar** (LPAB Art.22): ¿se calcula en el core o en un sistema contable externo? (los SPs de cuota no se detectaron claramente).
- [ ] **Pasivos asegurados**: base de cálculo — ¿qué depósitos incluye/excluye?
- [ ] **Cobertura 400,000 UDIs**: ¿se valida en el core el límite por cliente?

### Reglas a validar (prioridad: fórmulas primero)

| ID | Tipo | SP · línea | Norma | Evidencia (código) |
|----|------|-----------|-------|--------------------|
| BR-IFX-521 | FÓRMULA | `sp_ipab_repfideicomisomarcajeipab` L84 | LPAB Art.22 — cuota ordinaria 4 al millar so | `cCmd1 = ""//TRIM(cCmd1)//" UNION ALL SELECT * FROM (SELECT f.no_fideicom` |
| BR-IFX-517 | VALIDACIÓN | `sp_ipab_consulta_fideicomiso` L74 | LPAB Art.22 — cuota ordinaria 4 al millar so | `LET cCodRet = '00003'` |
| BR-IFX-518 | VALIDACIÓN | `sp_ipab_consulta_fideicomiso` L89 | LPAB Art.22 — cuota ordinaria 4 al millar so | `LET cCodRet = '00981'; -- El usuario no tiene una area designada` |
| BR-IFX-520 | VALIDACIÓN | `sp_ipab_ope_fideicomiso` L80 | LPAB Art.22 — cuota ordinaria 4 al millar so | `LET cCodRet = '00003'` |
| BR-IFX-523 | VALIDACIÓN | `sp_ipab_repfideicomisomarcajeipab` L49 | LPAB Art.22 — cuota ordinaria 4 al millar so | `LET cCodRet = '00003'` |
| BR-IFX-524 | VALIDACIÓN | `sp_ipab_repfideicomisomarcajeipab` L71 | LPAB Art.22 — cuota ordinaria 4 al millar so | `LET cCodRet = '00017'` |

---

*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: business-rules.json · coordina con SMEs en SME/Regulatory/*