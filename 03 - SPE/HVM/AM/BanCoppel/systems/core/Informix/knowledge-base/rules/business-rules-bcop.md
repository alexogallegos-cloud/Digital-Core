# Informix · Catálogo de Reglas de Negocio — v3.0 (Layer A+)

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Enrichment Layer A+
> **Generado:** 2026-08-06 · `enrich-rules-v3.py` · 5,979 reglas · 2,673 con nombre natural · 0 con explicación
> **Cobertura:** D01-D53 (todos los dominios) · 49 bases de datos activas
> **Fuente primaria:** `business-rules-v3.json` (v3.0, Layer A+)

## Resumen ejecutivo

| Tipo | Reglas |
|----|---:|
| VALIDACIÓN | 2,919 |
| FÓRMULA | 2,792 |
| UMBRAL | 240 |
| ESTADO | 28 |
| **TOTAL** | **5,979** |

| Dimensión | Valor |
|---|---|
| Reglas con nombre natural (business_name) | 2,673 |
| Reglas con explicación | 0 |
| Reglas con riesgo de equivalencia | 539 |
| Dominios cubiertos | 24 |

## Por categoría

| Categoría | Reglas |
|---|---:|
| REGULATORIO | 1,767 |
| OPERACIONAL | 1,696 |
| CALCULO_FINANCIERO | 1,370 |
| PARAMETRIA | 455 |
| RIESGO_CREDITO | 320 |
| PAGOS_TRANSFERENCIAS | 172 |
| CONTABILIDAD_REPORTES | 126 |
| FLUJO_OPERATIVO | 53 |
| ATENCION_CLIENTE | 20 |

## Por regulador

| Regulador | Reglas |
|---|---:|
| ['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 775 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'] | 238 |
| ['CNBV', 'CUB CNBV — calificación cartera vencida y constitución de reservas'] | 161 |
| ['CNBV', 'CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Severidad × Exposición'] | 111 |
| ['IPAB', 'LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiqueta LRAF'] | 73 |
| ['SAT', 'LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual)'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 67 |
| ['CNBV', 'LRSIC — Buró de Crédito; evaluación crediticia'] | 46 |
| ['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'],['IPAB', 'LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiqueta LRAF'] | 42 |
| ['CONDUSEF', 'RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario'] | 38 |
| ['SAT', 'LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual)'],['IPAB', 'LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiqueta LRAF'] | 38 |
| ['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'] | 29 |
| ['CNBV', 'CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R12 R22 R24'] | 16 |
| ['Banxico', 'SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s'] | 16 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'],['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'] | 14 |
| ['TESOFE', 'LTF — dispersión de recursos federales (pensiones, becas, apoyos)'] | 12 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'] | 11 |
| ['CNBV', 'Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública'] | 10 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 7 |
| ['SAT', 'CFDI/Retenciones bancarias — folio fiscal por transacción de pago de servicios (SAT)'] | 7 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 6 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'],['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 5 |
| ['TESOFE', 'LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF'] | 4 |
| ['Banxico', 'Circular 14/2017 — Notificación fallos remesas; max_retries 3; plazo ≤ 2 días hábiles'] | 4 |
| ['Banxico', 'Circular Banxico — formato CLABE 18 dígitos (validación algoritmo módulo-10)'] | 4 |
| ['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'],['Banxico', 'SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s'] | 4 |
| ['SAT', 'LIVA — IVA sobre comisiones (16% / 8% frontera)'],['CNBV', 'Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública'] | 3 |
| ['SAT', 'LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual)'],['CONDUSEF', 'RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 3 |
| ['CNBV', 'CUB Art.310-315 — Corresponsalía BTS; validación convenio activo + folio único'] | 3 |
| ['CONDUSEF', 'RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario'],['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'] | 2 |
| ['CONDUSEF', 'RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 2 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['CNBV', 'Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública'] | 2 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'] | 2 |
| ['SAT', 'CFDI/Retenciones bancarias — folio fiscal por transacción de pago de servicios (SAT)'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 2 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['Banxico', 'SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s'] | 2 |
| ['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'],['TESOFE', 'LTF — dispersión de recursos federales (pensiones, becas, apoyos)'] | 1 |
| ['CNBV', 'CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Severidad × Exposición'],['TESOFE', 'LTF — dispersión de recursos federales (pensiones, becas, apoyos)'] | 1 |
| ['Banxico', 'SPEI — confirmación bancos operadores; extemporáneo > 17:30'] | 1 |
| ['CNBV', 'Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)'],['TESOFE', 'LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF'] | 1 |
| ['CNBV', 'Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública'],['Banxico', 'SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s'] | 1 |
| ['CONDUSEF', 'LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente)'],['CNBV', 'Criterios contables CNBV + GAT — cálculo de intereses/rendimientos'] | 1 |
| ['CONDUSEF', 'LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente)'] | 1 |
| ['CONDUSEF', 'LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF'],['TESOFE', 'LTF — dispersión de recursos federales (pensiones, becas, apoyos)'] | 1 |

## Por dominio

| Dominio | Reglas |
|---|---:|
| D01 Canal Digital Web | 1,247 |
| D02 Integración y Auth | 499 |
| D03 Créditos | 1,568 |
| D04 Cheques / Cuentas | 1,293 |
| D05 Saldos y Cuentas | 132 |
| D06 Solicitudes | 234 |
| D07 Aclaraciones | 42 |
| D08 SPEI | 313 |
| D09 Mensajería | 10 |
| D10 Sucursales | 102 |
| D11 Cobranza | 127 |
| D12 Contabilidad | 54 |
| D13 TEF | 33 |
| D14 BEI | 41 |
| D15 LIDE / PLD | 134 |
| D16 Tarjetas | 63 |
| D23 MIS Sucursales | 24 |
| D26 Prospectos | 11 |
| D32 Reportes Visa/MC | 5 |
| D35 Digitalización | 8 |
| D36 Reportería CNBV | 27 |
| D44 Conciliación Operativa | 3 |
| D46 Oficinas de Cobro | 5 |
| D48 Riesgos de Crédito | 4 |

## Reglas críticas — riesgo de equivalencia financiera

| ID | business_name | SP | Riesgo |
|----|---|---|---|
| BR-V2-0003 | Retorno de código 000000 | `sp_acl_validarpreguntasiniciosesion` | base 365 — verificar vs 360 |
| BR-V2-0117 |  | `sp_random` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0127 |  | `burofisicas_cnr` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0129 |  | `burofisicas_cnr_pba` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0134 |  | `credito_revolvente` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0140 |  | `sp_burofisicas_cortos_cnr` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0142 |  | `sp_burofisicas_cortos_cnr` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0187 |  | `arr_intacum` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0189 | Ejecutar comando de sistema | `arr_invcrec_12262009` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0190 | Formato de fecha | `arr_pagaint` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0201 | Ejecutar comando de sistema | `arrpagoint_18082010` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0215 |  | `calc_int` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0218 |  | `calc_interes` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0220 | Calcular idpaisnacionalidad: n ÷ a | `calc_isr` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0221 |  | `calc_isr` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0222 |  | `calc_isr` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0224 | propaga error al ejecutar procedimiento chq crg bitacor | `calc_isr_proy` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0225 | propaga error al ejecutar procedimiento pld chq crg xml | `calc_isr_proy` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0261 |  | `cargo_comisiones_pba` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0262 |  | `cargo_comisiones_pba` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0265 | propaga error al ejecutar cancela SOE | `cargo_comisiones_per` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0266 | propaga error al ejecutar SOE | `cargo_comisiones_per` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0269 | propaga error al ejecutar cancela SOE | `cargo_comisiones_per_web` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0270 | propaga error al ejecutar SOE | `cargo_comisiones_per_web` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0273 |  | `cargo_comisiones_web` | ROUND — validar modo (banker's vs half-up) |
| BR-V2-0274 | propaga error al ejecutar cargo | `cargo_comisiones_web` | TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos) |
| BR-V2-0553 |  | `histsbg` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0554 | Calcular acumulado (multiplicación) | `histsbg` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0557 |  | `histsbg` | base 360 (año comercial) — verificar vs 365 |
| BR-V2-0558 |  | `histsbg` | base 360 (año comercial) — verificar vs 365 |
