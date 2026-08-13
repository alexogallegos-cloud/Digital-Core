# Informix · Catálogo de Reglas de Negocio — v3.0 (Layer A+)

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Enrichment Layer A+
> **Generado:** 2026-08-06 · `enrich-rules-v3.py` · 8,005 reglas · 8,005 con nombre natural · 5,759 con explicación
> **Cobertura:** D01-D53 (todos los dominios) · 49 bases de datos activas
> **Fuente primaria:** `business-rules-v3.json` (v3.0, Layer A+)

## Resumen ejecutivo

| Tipo | Reglas |
|----|---:|
| FÓRMULA | 4,597 |
| VALIDACIÓN | 3,141 |
| UMBRAL | 241 |
| ESTADO | 28 |
| CONDICIÓN | 1 |
| **TOTAL** | **8,005** |

| Dimensión | Valor |
|---|---|
| Reglas con nombre natural (business_name) | 8,005 |
| Reglas con explicación | 5,759 |
| Reglas con riesgo de equivalencia | 553 |
| Dominios cubiertos | 30 |

## Por categoría

| Categoría | Reglas |
|---|---:|
| CALCULO_FINANCIERO | 2,499 |
| REGULATORIO | 2,443 |
| OPERACIONAL | 1,920 |
| PARAMETRIA | 455 |
| RIESGO_CREDITO | 320 |
| PAGOS_TRANSFERENCIAS | 172 |
| CONTABILIDAD_REPORTES | 126 |
| FLUJO_OPERATIVO | 53 |
| ATENCION_CLIENTE | 20 |

## Por regulador

| Regulador | Reglas |
|---|---:|
| ['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 803 |
| ['CNBV', 'CUB CNBV — calificación cartera vencida y constitución de reservas'] | 255 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'] | 252 |
| ['CONDUSEF', 'RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario'] | 184 |
| ['CNBV', 'LRSIC — Buró de Crédito; evaluación crediticia'] | 152 |
| ['CNBV', 'CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Severidad × Exposición'] | 124 |
| ['IPAB', 'LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiqueta LRAF'] | 114 |
| ['CONDUSEF', 'RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario'],['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'] | 85 |
| ['SAT', 'LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual)'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 67 |
| ['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'] | 50 |
| ['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'],['IPAB', 'LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiqueta LRAF'] | 42 |
| ['CONDUSEF', 'LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente)'] | 40 |
| ['SAT', 'LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual)'],['IPAB', 'LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiqueta LRAF'] | 38 |
| ['Banxico', 'SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s'] | 36 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'],['CNBV', 'Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública'] | 26 |
| ['CNBV', 'Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública'] | 22 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'] | 20 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'],['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'] | 17 |
| ['CONDUSEF', 'LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente)'],['CNBV', 'LRSIC — Buró de Crédito; evaluación crediticia'] | 17 |
| ['CNBV', 'CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R12 R22 R24'] | 16 |
| ['TESOFE', 'LTF — dispersión de recursos federales (pensiones, becas, apoyos)'] | 14 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 7 |
| ['SAT', 'CFDI/Retenciones bancarias — folio fiscal por transacción de pago de servicios (SAT)'] | 7 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 6 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'],['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 5 |
| ['TESOFE', 'LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF'] | 4 |
| ['Banxico', 'Circular 14/2017 — Notificación fallos remesas; max_retries 3; plazo ≤ 2 días hábiles'] | 4 |
| ['Banxico', 'Circular Banxico — formato CLABE 18 dígitos (validación algoritmo módulo-10)'] | 4 |
| ['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'],['Banxico', 'SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s'] | 4 |
| ['SAT', 'LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual)'],['CONDUSEF', 'RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 3 |
| ['CNBV', 'CUB Art.310-315 — Corresponsalía BTS; validación convenio activo + folio único'] | 3 |
| ['CONDUSEF', 'LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente)'],['CNBV', 'CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Severidad × Exposición'] | 2 |
| ['CONDUSEF', 'RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 2 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['CNBV', 'Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública'] | 2 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'] | 2 |
| ['SAT', 'CFDI/Retenciones bancarias — folio fiscal por transacción de pago de servicios (SAT)'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 2 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['Banxico', 'SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s'] | 2 |
| ['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'],['TESOFE', 'LTF — dispersión de recursos federales (pensiones, becas, apoyos)'] | 1 |
| ['CNBV', 'CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Severidad × Exposición'],['TESOFE', 'LTF — dispersión de recursos federales (pensiones, becas, apoyos)'] | 1 |
| ['Banxico', 'SPEI — confirmación bancos operadores; extemporáneo > 17:30'] | 1 |
| ['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'],['TESOFE', 'LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF'] | 1 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['IPAB', 'LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiqueta LRAF'] | 1 |
| ['CNBV', 'Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública'],['Banxico', 'SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s'] | 1 |
| ['CNBV', 'CUB Anexo 33-34 — Plan de cuentas mínimo; cuadre DEBE = HABER a centavo'] | 1 |
| ['CONDUSEF', 'LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente)'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 1 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['TESOFE', 'LTF — dispersión de recursos federales (pensiones, becas, apoyos)'] | 1 |
| ['CONDUSEF', 'RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario'],['CNBV', 'Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública'] | 1 |

## Por dominio

| Dominio | Reglas |
|---|---:|
| D01 Canal Digital Web | 1,338 |
| D02 Integración y Auth | 729 |
| D03 Créditos | 1,903 |
| D04 Cheques / Cuentas | 1,593 |
| D05 Saldos y Cuentas | 216 |
| D06 Solicitudes | 245 |
| D07 Aclaraciones | 216 |
| D08 SPEI | 448 |
| D09 Mensajería | 11 |
| D10 Sucursales | 120 |
| D11 Cobranza | 240 |
| D12 Contabilidad | 56 |
| D13 TEF | 34 |
| D14 BEI | 43 |
| D15 LIDE / PLD | 198 |
| D16 Tarjetas | 352 |
| D23 MIS Sucursales | 24 |
| D26 Prospectos | 11 |
| D32 Reportes Visa/MC | 11 |
| D34 Respaldos DBA | 142 |
| D35 Digitalización | 8 |
| D36 Reportería CNBV | 27 |
| D37 Nómina BPI | 2 |
| D40 Banca Internet | 13 |
| D44 Conciliación Operativa | 3 |
| D45 Premios | 8 |
| D46 Oficinas de Cobro | 5 |
| D47 Garantías | 7 |
| D48 Riesgos de Crédito | 4 |
| D49 Retiro sin Tarjeta | 1 |

## Reglas críticas — riesgo de equivalencia financiera

| ID | business_name | SP | Riesgo |
|----|---|---|---|
| BR-V2-0006 | Cálculo con umbral/factor 365.25 | `sp_acl_validarpreguntasiniciosesion` | base 365 — verificar vs 360 |
| BR-V2-0305 | Cálculo con umbral/factor 65536 | `sp_random` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0316 | Calcular plazo: pago ÷ 2 | `burofisicas_cnr` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0318 | Calcular plazo: pago ÷ 2 | `burofisicas_cnr_pba` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0343 | Calcular abono (multiplicación) | `credito_revolvente` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0365 | Cálculo con umbral/factor 30.4 | `sp_burofisicas_cortos_cnr` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0367 | Calcular plazo: pago ÷ 2 | `sp_burofisicas_cortos_cnr` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0506 | Cálculo con umbral/factor 04 | `arr_intacum` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0508 | Cálculo con umbral/factor 025 | `arr_invcrec_12262009` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0509 | Cálculo con umbral/factor 04 | `arr_pagaint` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0521 | Cálculo con umbral/factor 360 | `arrpagoint_18082010` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0535 | Cálculo con umbral/factor 360 | `calc_int` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0538 | Cálculo con umbral/factor 360 | `calc_interes` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0540 | LISR Art.54/135 | `calc_isr` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0541 | LISR Art.54/135 | `calc_isr` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0542 | LISR Art.54/135 | `calc_isr` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0544 | LISR Art.54/135 | `calc_isr_proy` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0545 | LISR Art.54/135 | `calc_isr_proy` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0582 | LTOSF Art.17 (CAT) + RECO | `cargo_comisiones_pba` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0583 | LTOSF Art.17 (CAT) + RECO | `cargo_comisiones_pba` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0586 | LTOSF Art.17 (CAT) + RECO | `cargo_comisiones_per` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0587 | LTOSF Art.17 (CAT) + RECO | `cargo_comisiones_per` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0590 | LTOSF Art.17 (CAT) + RECO | `cargo_comisiones_per_web` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0591 | LTOSF Art.17 (CAT) + RECO | `cargo_comisiones_per_web` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0594 | LTOSF Art.17 (CAT) + RECO | `cargo_comisiones_web` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0595 | LTOSF Art.17 (CAT) + RECO | `cargo_comisiones_web` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0928 | Cálculo con umbral/factor 360 | `histsbg` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0929 | Cálculo con umbral/factor 360 | `histsbg` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0932 | Cálculo con umbral/factor 360 | `histsbg` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0933 | Cálculo con umbral/factor 360 | `histsbg` | base 360 (año comercial) — verificar vs 365 |
