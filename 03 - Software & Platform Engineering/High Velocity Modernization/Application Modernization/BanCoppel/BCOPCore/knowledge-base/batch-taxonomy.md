# BCOPCore — Taxonomía Batch: Sub-arquetipos de SPs

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Generado:** 2026-08-09 · digital-brain/classify-batch.py
> **Fuente:** brain.db tabla `batch_analysis` · 6,861 candidatos (fan_in=0 · role=internal · biz≠null · loc>100)
> **SME responsable:** Specialist — Informix SPL Analysis · DBA IBM Informix

---

## Por qué los SPs batch son invisibles al call graph

Los SPs batch son invocados por un **scheduler externo** (cron AIX / UC4 / Control-M) — ningún otro SP los llama.
Su `fan_in=0` los hace indistinguibles del código muerto en análisis estático.
La diferencia es crítica: **código muerto = no migrar · batch = migrar como job**.
El trigger NO es un SP — es el scheduler. Equivalente AWS: **EventBridge Scheduler**.

**Acción pendiente [SME-PENDING — DBA BanCoppel]:**
```bash
crontab -u informix -l   # inventario cron AIX
grep -r "bdicred\|bdicnweb\|bdispei" /var/spool/cron/ 2>/dev/null
```

---

## Distribución global L1

| Sub-arquetipo L1 | n | Confianza batch | Señal principal |
|-----------------|---|----------------|-----------------|
| `FILE_LOADER` | 2297 | ALTA | Usa `LOAD FROM filename` (Informix ETL desde filesystem AIX) |
| `NO_SOURCE` | 1092 | — | Sin archivo SQL (D17-D49 o naming sin prefijo sp_) |
| `REPORT_AGGREGATOR` | 868 | MEDIA | FOREACH masivo → escribe tablas de reporte, 0 calls externos |
| `UNKNOWN` | 773 | — | Señales insuficientes para clasificar |
| `MASS_OPERATION` | 477 | ALTA | FOREACH ≥10 con cross-DB calls |
| `DATA_MAINT` | 442 | MEDIA | Escribe tablas sin calls externos, loops moderados |
| `ORCHESTRATOR` | 400 | MEDIA | Llama ≥2 SPs distintos |
| `SINGLE_CALL` | 283 | MEDIA | Delega a exactamente 1 SP |
| `PURGE_JOB` | 103 | ALTA | DELETE + INSERT a `_hist` |
| `ACCOUNTING_JOB` | 71 | ALTA | Escribe a sx_contproc/sd_contproc + recibe pEmpresa |
| `CONCILIACION` | 43 | MEDIA | Nombre contiene concilia/reconcil |
| `CIERRE_CORTE` | 12 | ALTA | Nombre contiene cierre/corte + escrituras contables |

---

## FILE_LOADER — Segundo nivel (L2)

Usan `LOAD FROM /ruta/archivo ... INSERT INTO tabla` (ETL desde filesystem AIX).

| L2 | n | Riesgo | Descripción | Target AWS |
|----|---|--------|-------------|------------|
| `FL_OPERATIONAL` | 1579 | — | Bucket residual — sin patrón específico | Revisar contra scheduler AIX |
| `FL_ACCOUNTS` | 238 | MEDIO | Cuentas, cheques, caja, efectivo | Lambda / ECS Fargate · bloqueo optimista |
| `FL_CREDIT` | 234 | MEDIO | Crédito, cobranza, cartera, provisiones | Step Function · equivalencia exacta en montos |
| `FL_CATALOG` | 142 | MEDIO | Tasas, tarifas, parámetros, catálogos | Lambda + S3 staging · idempotente |
| `FL_RECONCILIATION` | 44 | MEDIO | Arqueo, conciliación de archivos, cuadre | Step Function · checkpoint por lote |
| `FL_REGULATORY` | 25 | ALTO | SPEI, CNBV, FATCA, Art.61 LIC, SAR, CONDUSEF | AWS Glue + S3 + EventBridge · SLA regulatorio |
| `FL_PAYROLL` | 18 | MEDIO | Nómina, dispersión de pagos a empleados | AWS Glue + S3 + Step Function |
| `FL_CORRESPONDENT` | 17 | ALTO | CoDi, STP, Prosa, CoppelPay, redes de cobro | AWS Glue + S3 + SQS · coordinación proveedor |

### FL_OPERATIONAL — Tercer nivel (L3)

| L3 | n | Descripción |
|----|---|-------------|
| `FLO_GENERIC` | 1248 | Sin patrón identificado — requiere scheduler AIX |
| `FLO_VALIDATION` | 100 | Validación y verificación de datos |
| `FLO_WORKFLOW` | 69 | Solicitudes, flujos, mesa de control |
| `FLO_ATM_POS` | 54 | ATMs, terminales POS, cajeros |
| `FLO_CUSTOMER` | 27 | Datos de cliente, domicilio, actualización |
| `FLO_NOTIFICATION` | 26 | Notificaciones, SMS, correo electrónico |
| `FLO_ACTIVATION` | 15 | Activación/desactivación de productos y servicios |
| `FLO_TRANSFER` | 14 | TEF, transferencias internas |
| `FLO_CREDIT_SCORING` | 11 | Línea de crédito, scoring, buró |
| `FLO_CAMPAIGN` | 7 | Campañas de marketing y cobranza |
| `FLO_CCL` | 6 | Centro de llamadas / cobranza CCL |
| `FLO_ONBOARDING` | 2 | Apertura / alta de productos |

---

## REPORT_AGGREGATOR — Segundo nivel (L2)

| L2 | n | Descripción | Target AWS |
|----|---|-------------|------------|
| `RA_OPERATIONAL` | 726 | Bucket residual | Revisar contra scheduler AIX |
| `RA_CREDIT` | 50 | Crédito, líneas, FATCA, credenciales | AWS Glue + S3 · equivalencia exacta |
| `RA_AUDIT` | 34 | Bitácora, log de operaciones, audit trail | Lambda + CloudWatch Logs · retención CNBV |
| `RA_BRANCH` | 29 | Sucursales, cajeros, ATM, punto de venta | AWS Glue + S3 + QuickSight |
| `RA_COLLECTION` | 19 | Cartera vencida, morosidad, cobranza | AWS Glue + S3 · Compliance CNBV |
| `RA_REGULATORY` | 10 | Indicadores SPEI, cuentas PEI, regulación Banxico | Lambda + S3 + QuickSight · SLA regulatorio |

### RA_OPERATIONAL — Tercer nivel (L3)

| L3 | n | Descripción |
|----|---|-------------|
| `RAO_GENERIC` | 502 | Sin patrón identificado — requiere scheduler AIX |
| `RAO_CUSTOMER` | 86 | Reportes de cliente, KYC, perfil |
| `RAO_PROCESS` | 34 | Reportes de procesos y workflows |
| `RAO_PRODUCT` | 31 | Reportes de productos financieros |
| `RAO_CCL` | 25 | Call center / cobranza CCL / horarios / asesores |
| `RAO_PARAMETER` | 24 | Parámetros del sistema, configuración |
| `RAO_SYNC` | 21 | Sincronización, integración, replicación |
| `RAO_WORKFORCE` | 3 | Fuerza laboral, ejecutivos, empleados |

---

## MASS_OPERATION — Segundo nivel (L2)

| L2 | n | Descripción | Target AWS |
|----|---|-------------|------------|
| `MO_OTHER` | 401 | Bucket residual | Revisar contra scheduler AIX |
| `MO_PAYMENT` | 29 | Cargo/abono/cobro masivo de cuentas | Step Function · MONEY equivalencia exacta · DLQ |
| `MO_UPDATE` | 18 | Actualización masiva de registros | Lambda / ECS Fargate · checkpoint |
| `MO_BLOCK_CANCEL` | 16 | Bloqueo/cancelación masiva de productos | Step Function · reversibilidad por lote |
| `MO_NOTIFICATION` | 8 | Alertas, SMS, correo masivo | Lambda + SNS/SES · idempotencia por mensaje |
| `MO_ASSIGNMENT` | 5 | Asignación/reasignación de solicitudes | Lambda + SQS FIFO |

---

## Otros sub-arquetipos L1

| Sub-arquetipo | n | Descripción | Target AWS |
|--------------|---|-------------|------------|
| `ACCOUNTING_JOB` | 71 | Escribe a sx_contproc/sd_contproc + pEmpresa · cierre contable diario | Step Function secuencial · ventana exclusiva sobre sx_contproc |
| `PURGE_JOB` | 103 | DELETE + INSERT a _hist · purga y archivado de datos históricos | Lambda paginada + DLQ · backup pre-purge en S3 |
| `CIERRE_CORTE` | 12 | Cierre/corte de período · escrituras contables finales del día | Step Function · ventana exclusiva nocturna |
| `CONCILIACION` | 43 | Conciliación standalone · verifica cuadre entre tablas | AWS Glue + S3 · comparador checksums |
| `DATA_MAINT` | 442 | Mantiene tablas sin calls externos · loops moderados · validar scheduler | Lambda + EventBridge · idempotente |
| `ORCHESTRATOR` | 400 | Llama ≥2 SPs distintos · puede ser online también · validar scheduler | Step Function o Lambda orquestadora |
| `SINGLE_CALL` | 283 | Delega a exactamente 1 SP · posible wrapper batch sobre SP online | Lambda thin wrapper |

---

## SPs de alta confianza batch (388 SPs)

ACCOUNTING_JOB + PURGE_JOB + CIERRE_CORTE + CONCILIACION + FL_REGULATORY + FL_CORRESPONDENT +
FL_PAYROLL + FL_RECONCILIATION + RA_REGULATORY + MO_PAYMENT + MO_BLOCK_CANCEL.
Estos son los que más urgentemente requieren validación contra scheduler AIX.

| Arquetipo | L2 | Dominio | SP | LOC |
|-----------|----|---------|----|-----|
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_activa_insertos_fijoscrd` | 121 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_actualiza_reserva_cierre` | 843 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_actualizacvlcobranzacte` | 201 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_adn_cart_activa` | 336 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_adn_cobroautomatico` | 637 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_adn_cobroautomatico_manual` | 3677 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_adn_res_general` | 272 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_calculo_grupoa` | 362 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_calculo_grupoa_crd` | 260 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_credito` | 2496 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_credito_01mx` | 1710 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_credito_2019` | 1647 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_credito_mx` | 1654 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_credito_paso` | 1537 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_diario_adn` | 1898 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_diario_adn_jom` | 1357 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_diario_pp_parte_mib` | 2598 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_diario_pp_parte_pbainci` | 1702 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cierre_tarjeta` | 1342 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_clona_tdc_upgrade` | 3714 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cobrautocrd` | 260 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_cobro_automatico_pp_6400` | 728 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_comisionxapertura_contable_fin` | 649 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_consulta_saldos_general_evaobj` | 924 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_consultas_cac_central_pba1` | 373 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_consultas_cac_central_pba2` | 433 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_consultasaldocortemin_mx2` | 243 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_consultasaldocortemin_pba` | 232 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_creacuota` | 114 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_credisoluciones_crd` | 577 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_credisoluciones_crd_cbro_manual` | 523 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_credisoluciones_crd_jom` | 490 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_credisoluciones_crd_mx` | 490 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_grabarincrementolincred_clon` | 149 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_integra_grupoa` | 266 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_mueve_20mar` | 148 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_mueve_movdia` | 279 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_mueve_movdia20mar` | 148 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_mueve_movdiacrd` | 146 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_obtener_prospectos_aumlincred` | 405 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_pf_obten_movimientos` | 4789 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_pf_proyecta_movimiento` | 4366 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_provision_de_intereses` | 428 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_provision_moratorios` | 192 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_renueva_escrow` | 282 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_renueva_grupoa` | 317 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_renueva_grupoa_crd` | 202 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_revision_de_tasas` | 308 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_secciona_ctasplazo_cierre` | 311 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_traspaso_cartera_vencida` | 120 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D03 | `sp_valida_tasas_del_dia` | 168 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_bloqueo_diainhabil` | 303 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachq` | 571 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachq_pba` | 450 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachqcomp1` | 590 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachqcomp10` | 568 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachqcomp1_pba` | 497 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachqcomp4` | 595 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachqcomp5` | 596 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachqcomp6` | 596 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachqcomp7` | 597 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachqcomp8` | 587 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_conciliachqcomp9` | 581 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_ctamec_consultarinfoctamoral` | 409 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D04 | `sp_ctamec_generarrpthojadefirmas` | 294 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D15 | `sp_acumulacionoperaciones` | 229 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D15 | `sp_eoetarjetacredito` | 305 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D15 | `sp_eoetarjetacredito_esp` | 309 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D15 | `sp_eoetarjetadebito` | 167 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D15 | `sp_eoetarjetadebito_pba` | 161 |
| `ACCOUNTING_JOB` | `ACCOUNTING_JOB` | D15 | `sp_eoetarjetadebito_prod` | 161 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D01 | `sp_cre_consultafechacorteproducto` | 1378 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D03 | `sp_actualiza_reserva_corte` | 493 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D04 | `sp_actparamcierre` | 295 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D04 | `sp_actparamcierre_alt` | 161 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D04 | `sp_actparamcierre_melleva` | 225 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D04 | `sp_actparamcierre_mib` | 225 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D04 | `sp_consultamovtoscortetienda` | 171 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D04 | `sp_consultamovtoscortetienda_pba` | 173 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D04 | `sp_consultamovtoscortetienda_pba2` | 171 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D07 | `sp_actualiza_folio_error_cierre` | 125 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D10 | `sp_corte_admin` | 161 |
| `CIERRE_CORTE` | `CIERRE_CORTE` | D16 | `sp_cierre_sucursal` | 214 |
| `CONCILIACION` | `CONCILIACION` | D01 | `sp_catbitacoraconciliacion` | 4379 |
| `CONCILIACION` | `CONCILIACION` | D01 | `sp_consconciliacionadminccl` | 3504 |
| `CONCILIACION` | `CONCILIACION` | D01 | `sp_consconciliacionadminccl_totales` | 3340 |
| `CONCILIACION` | `CONCILIACION` | D01 | `sp_consmonarchconciliacion` | 2952 |
| `CONCILIACION` | `CONCILIACION` | D01 | `sp_consmonarchconciliacion_totales` | 2781 |
| `CONCILIACION` | `CONCILIACION` | D01 | `sp_genreporteconciliacontabledmi` | 7095 |
| `CONCILIACION` | `CONCILIACION` | D02 | `sp_conciliacion_sepomex` | 133 |
| `CONCILIACION` | `CONCILIACION` | D02 | `sp_conciliar_ciudades_sepomex` | 323 |
| `CONCILIACION` | `CONCILIACION` | D02 | `sp_conciliar_colspmx_cp` | 188 |
| `CONCILIACION` | `CONCILIACION` | D02 | `sp_conciliarcatalogocalles` | 104 |
| `CONCILIACION` | `CONCILIACION` | D02 | `sp_scgenconcilia_cont` | 129 |
| `CONCILIACION` | `CONCILIACION` | D03 | `sp_chi_ope_concilia_com` | 188 |
| `CONCILIACION` | `CONCILIACION` | D03 | `sp_chi_ope_rep_concilia_com` | 161 |
| `CONCILIACION` | `CONCILIACION` | D03 | `sp_chi_ope_rep_concilia_mvtos` | 504 |
| `CONCILIACION` | `CONCILIACION` | D03 | `sp_conciliar_saldos_hist` | 193 |
| `CONCILIACION` | `CONCILIACION` | D03 | `sp_conciliarsaldoscredito` | 500 |
| `CONCILIACION` | `CONCILIACION` | D03 | `sp_conciliarsaldoscredito_pba` | 485 |
| `CONCILIACION` | `CONCILIACION` | D04 | `sp_cap_conciliaciontraspasosctas` | 865 |
| `CONCILIACION` | `CONCILIACION` | D04 | `sp_conciliachq_reg` | 410 |
| `CONCILIACION` | `CONCILIACION` | D04 | `sp_diferencia_concilia` | 216 |
| `CONCILIACION` | `CONCILIACION` | D04 | `sp_scgenconcilia_cont` | 129 |
| `CONCILIACION` | `CONCILIACION` | D04 | `sp_transfer_regtrxconciliacion` | 117 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_conciliacion_bcpl_cpl` | 117 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_conciliacion_bcpl_cpl_rep` | 266 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_conciliacion_bcpl_cpl_sig_dia` | 166 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_conciliaciontotalporconvenio` | 485 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_conciliaciontotalporconvenio_pba` | 654 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_generaconciliacioncoppel` | 141 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_insertaconciliaciontotalporconvenio` | 303 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_reportebts_conciliacion` | 158 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_sac_conciliadeta` | 353 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_sac_conciliatotbancos` | 182 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_sac_insertaremesasnoconciliadaswu_pba` | 779 |
| `CONCILIACION` | `CONCILIACION` | D05 | `sp_sacreporteconciliacionconveniosucursal_pba` | 279 |
| `CONCILIACION` | `CONCILIACION` | D12 | `sp_conciliaxctacontab` | 311 |
| `CONCILIACION` | `CONCILIACION` | D12 | `sp_svconciliacont` | 273 |
| `CONCILIACION` | `CONCILIACION` | D12 | `sp_svconciliacont_pba` | 273 |
| `CONCILIACION` | `CONCILIACION` | D16 | `sp_conciliacionautomatica_dep_atm` | 688 |
| `CONCILIACION` | `CONCILIACION` | D16 | `sp_descripcionerrorconciliacion` | 122 |
| `CONCILIACION` | `CONCILIACION` | D16 | `sp_guardarstatusconciliacion` | 288 |
| `CONCILIACION` | `CONCILIACION` | D16 | `sp_insertamovconciliados` | 204 |
| `CONCILIACION` | `CONCILIACION` | D16 | `sp_obtregmonitorconciliacionman` | 111 |
| `CONCILIACION` | `CONCILIACION` | D16 | `sp_reportes_conciliacion` | 164 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_actualizareportespendientesarqueosuc` | 6471 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_atms_reparqueoatm` | 36632 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_cap_consultaparamarchivofatca` | 990 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_ccl_conciliadorautoinvcreciente` | 29625 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_ccl_conciliadorautoinvcreciente_genrep` | 29485 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_ccl_conciliadorautoinvcreciente_totales` | 29366 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_cg_detallealertasspei` | 12102 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_cg_validasaldoarqueosucucaja` | 5433 |
| `FILE_LOADER` | `FL_PAYROLL` | D01 | `sp_cnt_consdetalleempleado` | 16212 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_con_actgenreportesconciliacion` | 6749 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_con_genreportesconciliacion` | 6684 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_con_genreportesconciliacion_totales` | 6605 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_conscattiporeporteconciliacionapertura` | 43418 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D01 | `sp_conscodigosufijopm` | 8570 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_consreportearqueosuc` | 6362 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_consreportearqueosuc_totales` | 6273 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_consultaconciliaaperturapagarescargo` | 43342 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_consultaconciliaaperturapagarescargos_totales` | 43161 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_consultaconciliatraspcuentas_archivo` | 43839 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_consultaconciliatraspcuentas_totales` | 43536 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_consultainfarqueosucucaja` | 851 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_detalledenoarqueosucaja` | 2935 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_fc_detallecuentastraspasar_totales` | 19498 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_generareporteconciliaaperturapagarescargo` | 43078 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_genreparqueosucucaja` | 697 |
| `FILE_LOADER` | `FL_PAYROLL` | D01 | `sp_ofi_actualizarsueldoempleado` | 13989 |
| `FILE_LOADER` | `FL_PAYROLL` | D01 | `sp_ofi_consultarempleado` | 12427 |
| `FILE_LOADER` | `FL_PAYROLL` | D01 | `sp_ofi_generarpolizanomina` | 4096 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_ope_actualizaprefijosparticipantesspei` | 29153 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_ope_altabajactaspei` | 18170 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_ope_conciliaarchivoptc` | 15515 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_ope_consultaprefijosparticipantesspei` | 29226 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_ope_consultastatusprefijosparticipantesspei` | 29281 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_registractualizactaspld` | 16174 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_repctasinactivasart61` | 1832 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_repctasinactivasart61_totales` | 44234 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_sac_reportesconciliacion` | 19755 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_sac_reportesremnoconciliadas` | 17367 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_sac_sacreporteconciliacionconveniosucursal` | 15168 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_spei_ctasinretencion` | 7088 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_totalesarqueosucucaja` | 3193 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D01 | `sp_validacodigoproveedorcaja` | 1380 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_verificareportespendientesarqueosuc` | 5727 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D01 | `sp_verificastatusarqueosucaja` | 508 |
| `FILE_LOADER` | `FL_REGULATORY` | D01 | `sp_verificastatusconsultafechasart61` | 49653 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D02 | `sp_clientescoppelpaytdc` | 111 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D02 | `sp_conciliar_colonias_sepomex_cps` | 1547 |
| `FILE_LOADER` | `FL_REGULATORY` | D03 | `sp_chi_pld_layout_sic` | 323 |
| `FILE_LOADER` | `FL_PAYROLL` | D03 | `sp_gen_archivo_pagotdcempleados` | 140 |
| `FILE_LOADER` | `FL_PAYROLL` | D03 | `sp_insert_ex_empleados_adn` | 1215 |
| `FILE_LOADER` | `FL_REGULATORY` | D03 | `sp_rep_regulatorios_irb` | 810 |
| `FILE_LOADER` | `FL_REGULATORY` | D03 | `sp_rep_regulatorios_irb_compl` | 689 |
| `FILE_LOADER` | `FL_REGULATORY` | D03 | `sp_rep_regulatorios_irb_pba` | 807 |
| `FILE_LOADER` | `FL_REGULATORY` | D03 | `sp_rep_regulatorios_irb_repr` | 989 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D03 | `sp_report_points_concilia_pl` | 149 |
| `FILE_LOADER` | `FL_REGULATORY` | D03 | `sp_valida_spei_cred` | 355 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D04 | `sp_activaciones_codi_isa` | 199 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_cargadividearchivonomina` | 652 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_cargadividearchivonomina_bpi` | 471 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_cargadividearchivonomina_pru` | 652 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D04 | `sp_concilia_ctas_chq` | 224 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D04 | `sp_concilia_donativos_becalos` | 574 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D04 | `sp_conciliachqfinal` | 476 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D04 | `sp_conciliachqtf` | 455 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_conciliaciondispersionnomina_his` | 204 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D04 | `sp_conciliainv` | 825 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_dispersionnominavalidacionestatus_bpi` | 255 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_generaarchivocuentasnomina` | 297 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_generaarchivocuentasnomina_exp` | 210 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D04 | `sp_generar_acum_corresponsal_mc` | 453 |
| `FILE_LOADER` | `FL_REGULATORY` | D04 | `sp_liberaretspei` | 4235 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_movnomina_consolidados` | 113 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_nominaencabezadosumarionvosemp` | 105 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_nominaobtienenvosemp` | 102 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D04 | `sp_obtinfototcorresponsal` | 349 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D04 | `sp_obtmovscorresponsales` | 314 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D04 | `sp_obtmovscorresponsales_esp` | 180 |
| `FILE_LOADER` | `FL_REGULATORY` | D04 | `sp_pld_conci` | 374 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D04 | `sp_prdcto_nvos_corresponsales` | 205 |
| `FILE_LOADER` | `FL_PAYROLL` | D04 | `sp_repmensualnomina` | 793 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D04 | `sp_reporte_concilia_seguros` | 507 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D05 | `sp_cargaarchivoaconciliacionbcpl` | 905 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D05 | `sp_decodifica_linea_base_licencias` | 137 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D05 | `sp_decodifica_linea_base_reimpresion` | 1512 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D05 | `sp_decodificadatosimpuestopredial` | 144 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D05 | `sp_sac_conciliaarchivoptc` | 362 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D05 | `sp_sac_conciliadeta_pba` | 5252 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D05 | `sp_sac_insertaremesasnoconciliadaswu` | 2525 |
| `FILE_LOADER` | `FL_PAYROLL` | D07 | `sp_buscaempleadohuella_alta` | 1379 |
| `FILE_LOADER` | `FL_REGULATORY` | D08 | `sp_alertacargospei` | 150 |
| `FILE_LOADER` | `FL_REGULATORY` | D08 | `sp_alertacargospei_exp1` | 170 |
| `FILE_LOADER` | `FL_REGULATORY` | D08 | `sp_alertacargospei_pba` | 148 |
| `FILE_LOADER` | `FL_REGULATORY` | D08 | `sp_alertasabonospei` | 150 |
| `FILE_LOADER` | `FL_REGULATORY` | D08 | `sp_alertasabonosspei` | 150 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D08 | `sp_stscodiapp` | 219 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D16 | `sp_carga_archivoseglobal` | 282 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D16 | `sp_cargararchivos_conciliacionauto` | 581 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D16 | `sp_concorresponsales` | 124 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D16 | `sp_generaarchivoconciliacion` | 293 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D16 | `sp_generaarchivoconciliacion_pba` | 293 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D16 | `sp_integridad_conciliacion_auto` | 1113 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D16 | `sp_oper_corr_oxxo_eleven_aut` | 772 |
| `FILE_LOADER` | `FL_CORRESPONDENT` | D16 | `sp_reporte_general_corresponsal_mc` | 877 |
| `FILE_LOADER` | `FL_RECONCILIATION` | D16 | `sp_tipo_conciliacion_pos2` | 672 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_bloquealotemasivo` | 122 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_cancelarprocejecpagosafore` | 4266 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_cargo_ref_masivo` | 14742 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_consbloqueomasivocre` | 7550 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_conscargomasivocre` | 2218 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_conscargomasivocre_hist` | 2077 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_conscargosaperturacheques` | 6428 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_conscargosaperturacheques_totales` | 6267 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_conscargosreversadoscheques` | 6211 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_conscargosreversadoscheques_totales` | 6128 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_consctascancelacionmasivocre` | 227 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_consmovpagaresnoaplicados` | 5381 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_conspagomasivocre_hist` | 1536 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_constotalbloqueomasivocre` | 1673 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_constotaldesbloqueomasivocre` | 1554 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_consultatotalenviospagodinya` | 947 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_desbloqueoctacre_masivo` | 7354 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_dinya_obtienetotalesordenpagosac` | 441 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_genrep_cons_orden_pago_aud` | 6008 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_grabarcargosmanualescre` | 1210 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_grabarpagosmanualescre` | 17090 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_gs_cancelarsolicitud` | 6933 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_gs_cancelarsolicitudreintento` | 6811 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_gs_consultamotivoscancelacion` | 2479 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_gs_consultamtvoscancelacion` | 2413 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_gs_grabamtvoscancelacion` | 1253 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_obtenerconceptocargomanualescre` | 1106 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_ope_pagoprogtipopagos` | 15273 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_ope_pagoprogtiporep` | 15338 |
| `MASS_OPERATION` | `MO_PAYMENT` | D01 | `sp_reportecargoindividualcredito` | 1002 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D01 | `sp_sw_ro_bloqueactacre` | 2654 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D02 | `sp_bloqueardesbloquearserviciobpi` | 1516 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D02 | `sp_cnsif_bloqueoctascred` | 219 |
| `MASS_OPERATION` | `MO_PAYMENT` | D02 | `sp_cnsif_consulta_pagos_recibidos_general` | 180 |
| `MASS_OPERATION` | `MO_PAYMENT` | D03 | `sp_gen_pago_quitacondonacion` | 464 |
| `MASS_OPERATION` | `MO_PAYMENT` | D03 | `sp_grabarcargosmasivos` | 404 |
| `MASS_OPERATION` | `MO_PAYMENT` | D03 | `sp_grabarreversocargosmasivos` | 340 |
| `MASS_OPERATION` | `MO_PAYMENT` | D03 | `sp_grabarreversopagosmasivos` | 367 |
| `MASS_OPERATION` | `MO_PAYMENT` | D03 | `sp_reporte_syspagos` | 2916 |
| `MASS_OPERATION` | `MO_BLOCK_CANCEL` | D04 | `sp_cap_cancelacta_masiva` | 1575 |
| `MASS_OPERATION` | `MO_PAYMENT` | D04 | `sp_cargoxcomision_pm` | 593 |
| `MASS_OPERATION` | `MO_PAYMENT` | D04 | `sp_cobroauto_sd` | 3006 |
| `MASS_OPERATION` | `MO_PAYMENT` | D04 | `sp_portabregistrapagoprogramado` | 535 |
| `MASS_OPERATION` | `MO_PAYMENT` | D05 | `sp_app_aplicapagos_cred` | 1082 |
| `MASS_OPERATION` | `MO_PAYMENT` | D05 | `sp_validapagoremesa` | 5437 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_atms_actualizaeliminacionfaltsobr` | 39349 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_atms_conseliminacionfaltsobr` | 38044 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_cancelarcreditomasivocre` | 1164 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_cargomasivocre` | 936 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_cc_eliminasuc` | 7966 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_cla_eliminactelistasnegativas` | 2975 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_cnsif_depuramovimientostemp` | 4490 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_cp_limpiatablas` | 8311 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_cp_limpiatablastdcoro` | 1953 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_cred_elimina_tmp` | 11332 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_depurar_genarchmovtos_masivo` | 9503 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_dic_eliminabitadicta` | 19990 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_eliminase` | 15195 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_eliminasignacionctesfusion` | 4875 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_eliminasolsupervision` | 18336 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_gs_eliminareportesrepositorio` | 1328 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_mc_eliminasolicatenusuariomc` | 14853 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_mc_eliminasolicatenusuariomc_prueba` | 22477 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_ofi_eliminaerrores` | 11554 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_ope_eliminamovimientosmetas` | 12411 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_pos_eliminapos` | 14016 |
| `PURGE_JOB` | `PURGE_JOB` | D01 | `sp_sw_ro_borraimagenes` | 140 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_actstatusctecopnvoparam_club` | 177 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_borra_reenvio_ext_tokens` | 144 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_borra_reenvio_ext_tokens_pba` | 134 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_consultarctemoral_03` | 609 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depura_celular_prospectos` | 237 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depura_ctehuella` | 137 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depura_ctespendictayanalisis` | 179 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depura_direcciones_ctes_sin_prod` | 302 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depura_direcciones_prospectos` | 271 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depura_limites_x` | 122 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depura_si_refdirecciones` | 315 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depura_tbl_si_cambiostcte_total` | 195 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depura_telefonos` | 213 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depuractanvl2` | 1092 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depurar_clientes_pyt` | 251 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depurar_telefonos_duplicados` | 723 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depurar_telefonos_duplicados_online` | 188 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_depurar_telefonos_incorrectos` | 234 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_desfusion_ctescap` | 1928 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_elimina_referencias` | 118 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_elimina_referencias_duplicadas_web` | 596 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_elimina_referencias_pba` | 113 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_elimina_referencias_web` | 520 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_elimina_suscriptores` | 257 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_eliminaacentos` | 203 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_fusion_retroactiva_rel_bancoppel_coppel` | 200 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_generahuellalinea` | 353 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_generahuellalinea_chl` | 319 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_ipab_borratablas` | 379 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_pay_depuracion` | 146 |
| `PURGE_JOB` | `PURGE_JOB` | D02 | `sp_pay_depuracion_pba` | 146 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_borrarever` | 116 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_carga_ctes_credisoluciones` | 149 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_chi_integra_reg_contables` | 348 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_cred_his` | 320 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_creditos_cancelados` | 358 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_edoctas_norevolventes` | 899 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_infoedocta_calif` | 107 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_movdiacrd` | 119 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_proc_incrementos_pd` | 279 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_sd_amortiza_2` | 182 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_sd_amortiza_3` | 258 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_sd_amortizacrd` | 186 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_sd_archivopagmin` | 150 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_sd_movhis` | 101 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depura_sd_movhis_3` | 101 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_depuratablascfd` | 470 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_eliminaadicional` | 131 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_eliminaadicional_web` | 128 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_ics_pagos` | 591 |
| `PURGE_JOB` | `PURGE_JOB` | D03 | `sp_identifica_saldosinmateriales` | 675 |
| `PURGE_JOB` | `PURGE_JOB` | D04 | `sp_depuratablascfd` | 470 |
| `PURGE_JOB` | `PURGE_JOB` | D04 | `sp_depuratablascfd_esp` | 494 |
| `PURGE_JOB` | `PURGE_JOB` | D04 | `sp_depuratablascfd_inc` | 406 |
| `PURGE_JOB` | `PURGE_JOB` | D05 | `sp_sac_agentes_depuracion` | 260 |
| `PURGE_JOB` | `PURGE_JOB` | D05 | `sp_sac_app_depuracion` | 1470 |
| `PURGE_JOB` | `PURGE_JOB` | D05 | `sp_sac_eliminamovsbtspayi` | 5545 |
| `PURGE_JOB` | `PURGE_JOB` | D05 | `sp_sac_eliminamovsbtsqryi` | 5484 |
| `PURGE_JOB` | `PURGE_JOB` | D05 | `sp_sac_wu_depuracion` | 579 |
| `PURGE_JOB` | `PURGE_JOB` | D06 | `sp_depura_autorizacion` | 131 |
| `PURGE_JOB` | `PURGE_JOB` | D06 | `sp_depura_osclientesuper` | 106 |
| `PURGE_JOB` | `PURGE_JOB` | D06 | `sp_depura_sol1` | 184 |
| `PURGE_JOB` | `PURGE_JOB` | D06 | `sp_depura_sol2` | 291 |
| `PURGE_JOB` | `PURGE_JOB` | D07 | `sp_eliminacion_puntos_coppel` | 259 |
| `PURGE_JOB` | `PURGE_JOB` | D08 | `sp_depura_tbl_registro_msj` | 135 |
| `PURGE_JOB` | `PURGE_JOB` | D09 | `sp_depura_ctetel_invalido` | 174 |
| `PURGE_JOB` | `PURGE_JOB` | D09 | `sp_depura_mensajes` | 686 |
| `PURGE_JOB` | `PURGE_JOB` | D09 | `sp_depura_mnsjr_bitacora_sms` | 140 |
| `PURGE_JOB` | `PURGE_JOB` | D11 | `sp_depura_actualiza_triad_salida` | 446 |
| `PURGE_JOB` | `PURGE_JOB` | D11 | `sp_depura_tbls_eval_objetiva` | 1051 |
| `PURGE_JOB` | `PURGE_JOB` | D11 | `sp_migra_tablas_smsmail` | 260 |
| `PURGE_JOB` | `PURGE_JOB` | D13 | `sp_eliminaarchivo_tef` | 3487 |
| `PURGE_JOB` | `PURGE_JOB` | D14 | `sp_depura_bitacora_bei` | 126 |
| `PURGE_JOB` | `PURGE_JOB` | D15 | `sp_eliminaarchivo` | 316 |
| `PURGE_JOB` | `PURGE_JOB` | D16 | `sp_borrararchconaut` | 118 |
| `PURGE_JOB` | `PURGE_JOB` | D16 | `sp_depuracion_alertservice` | 287 |
| `PURGE_JOB` | `PURGE_JOB` | D16 | `sp_depuracion_historica` | 120 |
| `PURGE_JOB` | `PURGE_JOB` | D16 | `sp_depuracion_tarjetapivote` | 769 |
| `PURGE_JOB` | `PURGE_JOB` | D16 | `sp_elimina_mj_vau` | 185 |
| `PURGE_JOB` | `PURGE_JOB` | D16 | `sp_limpiatarjeta` | 182 |
| `PURGE_JOB` | `PURGE_JOB` | D16 | `sp_trans_bitac_envios_depurar` | 104 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D01 | `sp_ope_actualizaindicadorespei` | 4355 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D01 | `sp_ope_bajacuentaspei` | 4232 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D01 | `sp_ope_buscacuentaspei` | 4172 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D01 | `sp_ope_consultacuentaspei` | 4087 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D01 | `sp_ope_consultacuentaspei_totales` | 4001 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D01 | `sp_ope_consultaindicadorespei` | 3945 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D01 | `sp_ope_consultaindicadorespei_pba` | 3699 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D01 | `sp_ope_insertacuentaspei` | 3857 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D04 | `sp_generainfcnbv` | 1462 |
| `REPORT_AGGREGATOR` | `RA_REGULATORY` | D04 | `sp_mspei_detallemovtos` | 193 |

---

## Grupos funcionales conocidos (11 SPs validados en KB)

| Grupo | SPs | Arquetipo | Dominio | Riesgo |
|-------|-----|-----------|---------|--------|
| G1 Tasas/Admin | sp_adminitasas_cargarchivo, sp_admintasas_bitacoraerror, sp_admintasas_consultabitacora | `FL_CATALOG` | D01 | MEDIO |
| G2 Bitácora usuarios | sp_adm_consultabitacora_usuarios, sp_adm_consultabitacora_usuarios_totales | `REPORT_AGGREGATOR` | D01 | MEDIO |
| G3 Reportes sucursal | sp_actualizareportespendientesarqueosuc, sp_actualizareportespendientesentradasalida | `FL_RECONCILIATION` | D01 | BAJO |
| G4 Abono masivo | sp_abono_ref_masivo | `FL_OPERATIONAL` | D01 | MEDIO |
| G5 Reservas crédito | sp_actualiza_reserva_cierre, sp_adn_res_general | `ACCOUNTING_JOB` | D03 | ALTO |
| G6 Depuración SPEI | sp_depura_tbl_registro_msj | `PURGE_JOB` | D08 | ALTO |

---

## Pendientes críticos

- **[SME-PENDING — DBA BanCoppel]** Inventario scheduler AIX — sin este dato no se distingue batch real de código muerto.
- **NO_SOURCE (1,092)** — SPs sin SQL encontrado: mayormente D17-D49 o naming sin prefijo `sp_`.
- **FLO_GENERIC (1,248) + RAO_GENERIC (502) + MO_OTHER (401)** — buckets residuales, requieren scheduler AIX.
- **D17-D49** — mapear en `DB_TO_DOMAIN` de build-brain.py para resolver NO_SOURCE y sp_capabilities gap.

---

## Cómo consultar en brain.db

```python
from digital_brain.brain import BCOPBrain
# O directamente:
conn.execute("""
    SELECT domain, db, sp_name, loc, archetype, l2_archetype, l3_archetype,
           n_foreach, n_writes, n_calls, has_contproc, has_hist
    FROM batch_analysis
    WHERE archetype = 'ACCOUNTING_JOB'
    ORDER BY domain, sp_name
""").fetchall()
```

*Generado 2026-08-09 · classify-batch.py v1.0 · Signals: LOAD stmt · FOREACH count · cross-DB calls · write targets · name patterns*