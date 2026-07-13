# BCOPCore · Análisis de Scope del Vocabulario (efímero vs. trasciende)

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 · **Generado:** 2026-07-04 por `extract-dataflow.py`  
> Analizados **3,738 SPs** · 20,519 parámetros (API) · 17,725 accesos a tabla (BD) · 89,305 variables locales (1,604 de cálculo)

Cada término del vocabulario se clasifica por **dónde vive el dato**:

| Scope | Significado | Uso en modernización |
|-------|-------------|----------------------|
| **TRASCIENDE** | Aparece sobre todo como parámetro (API) o columna (BD) | **Contrato del microservicio target** (entra/sale) |
| **EFÍMERA-CÁLCULO** | Variable local que participa en fórmulas (LET aritmético) | **Regla de negocio** — lógica interna a preservar |
| **EFÍMERA** | Variable local auxiliar (contadores, control) | Lógica interna, no contrato |
| **MIXTO** | Trasciende y también se usa localmente | Revisar caso por caso |

**Distribución:** TRASCIENDE: 142 · EFÍMERA-CÁLCULO: 84 · EFÍMERA: 196 · MIXTO: 140

---

## 🟢 Términos que TRASCIENDEN — candidatos al contrato de la API/BD target

Datos que entran/salen del SP: definen la **interfaz** del microservicio modernizado.

| Término | Significado | API | BD | Local |
|---------|-------------|----:|---:|------:|
| `usuario` | usuario | 2496 | 83 | 429 |
| `idfuncion` | id de funcionalidad | 2122 | 0 | 9 |
| `param` | parámetro | 36 | 799 | 180 |
| `sac` | Servicios de Atención al Cliente — subsistema de atención en sucursal (ventanilla, domiciliación, abonos ATM, remesas WU); base de datos propia bdisac: con tabla sac_movimientoshistorial | 4 | 748 | 241 |
| `crd` | crédito (abreviación) | 0 | 861 | 100 |
| `fechas` | fechas | 6 | 696 | 182 |
| `cat` | catálogo | 7 | 498 | 113 |
| `bitacora` | bitácora | 1 | 439 | 54 |
| `sdos` | saldos (abreviación) | 0 | 412 | 56 |
| `acl` | familia aclaraciones | 16 | 316 | 118 |
| `dic` | [polisemia] Dictamen (bdicnweb:sp_dic_* — decisión crediticia, analista de dictamen, hawk) | Diciembre (columna dic en tablas de series mensuales ene…dic) | 17 | 271 | 122 |
| `fechafin` | fecha fin | 286 | 0 | 116 |
| `cce` | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — sistema de compensación interbancaria de cheques; SPs: sp_cce_consultar_cheques40/46, chequespresentados (bdicheq) | 2 | 223 | 108 |
| `temp` | temporal | 3 | 242 | 86 |
| `solicitudes` | solicitudes (plural) | 8 | 303 | 19 |
| `detalle` | detalle | 3 | 242 | 53 |
| `movhis` | Movimientos Históricos — tabla/proceso de historial de movimientos (bdicheq:arrmovhis, borra_movhis; bdicred:carga_movhis_edoctacrd) | 0 | 250 | 42 |
| `fal` | faltantes / documentación de expediente | 12 | 180 | 75 |
| `inicio` | inicio | 24 | 164 | 75 |
| `tef` | TEF — transferencia electrónica de fondos | 17 | 153 | 74 |
| `fechainicio` | fecha inicio | 182 | 1 | 39 |
| `telefonos` | teléfonos | 0 | 219 | 0 |
| `scoring` | scoring crediticio | 0 | 173 | 27 |
| `ics` | ICS — sistema de cuotas/mensualidades de crédito (sp_ics_cuotas, sp_ics_compara_secuencias, sp_ics_genera_control — bdicred) | 2 | 157 | 22 |
| `his` | histórico | 0 | 112 | 55 |

---

## 🔴 Términos EFÍMEROS-CÁLCULO — señal de reglas de negocio

Variables locales que participan en fórmulas: **aquí vive la lógica de negocio** (cálculos de interés, ISR, comisión, saldo). No son contrato, pero **su fórmula debe preservarse** (golden master).

| Término | Significado | En fórmula (LET) | Local total |
|---------|-------------|-----------------:|------------:|
| `cod` | código | 4 | 8804 |
| `fecha` | fecha | 154 | 5423 |
| `num` | número (de) | 23 | 3280 |
| `nombre` | nombre | 5 | 2240 |
| `int` | interés | 39 | 2258 |
| `status` | estatus | 6 | 1613 |
| `monto` | monto | 92 | 1699 |
| `cte` | cliente | 3 | 1353 |
| `cred` | crédito | 5 | 880 |
| `total` | total | 32 | 1582 |
| `cta` | cuenta | 14 | 1368 |
| `cap` | Captación — cuentas de ahorro/depósito; evidencia: sp_cap_genrepcancelacioncuentascaptacion, nCtaCap, recalculagat1200 (GAT = Ganancia Anual Total regulado por Banxico) | 8 | 1503 |
| `act` | actualiza | 10 | 1128 |
| `desc` | [polisemia] Descripción (sp_desc_ret: devuelve descripción del código de retorno) | Descarga (sp_desc_archivos_cfdi/conc: descarga archivos CFDI y conciliación) | 8 | 1436 |
| `pago` | pago | 24 | 1277 |
| `iva` | IVA (impuesto — SAT) | 69 | 1269 |
| `nom` | nómina | 3 | 1206 |
| `cont` | familia contabilidad | 5 | 979 |
| `sdo` | saldo | 12 | 1208 |
| `mes` | mes | 43 | 1152 |
| `mensaje` | mensaje | 4 | 1190 |
| `error` | error | 5 | 1008 |
| `dia` | del día | 13 | 905 |
| `venc` | vencimiento | 12 | 1053 |
| `rec` | recepción / recibe | 8 | 720 |
| `com` | Comisión bancaria — cobro de comisión sobre cuenta (bdicheq:sp_cobra_com, sp_com_manejo_cta_cobro_*; también en OXXO) | 10 | 706 |
| `archivo` | archivo | 13 | 621 |
| `ant` | anterior | 6 | 658 |
| `credito` | crédito | 8 | 511 |
| `saldo` | saldo | 9 | 791 |

---

## ⚪ Términos EFÍMEROS auxiliares (control interno)

Variables de control/temporales sin cálculo — lógica interna que **no** forma parte del contrato ni suele ser regla de negocio (códigos de retorno, contadores, banderas técnicas).

| Término | Significado | Local |
|---------|-------------|------:|
| `registros` | registros | 1268 |
| `cuenta` | cuenta | 1176 |
| `folio` | folio | 970 |
| `numcte` | número de cliente | 777 |
| `cre` | crédito | 851 |
| `suc` | sucursal | 620 |
| `sol` | solicitud | 554 |
| `estado` | estado (entidad federativa / estatus) | 506 |
| `ref` | referencia | 503 |
| `cve` | clave (cve) | 549 |
| `estatus` | estatus | 463 |
| `descripcion` | descripción | 540 |
| `rev` | reversión (abreviación de reversa/reverso) | 456 |
| `secuencia` | secuencia | 491 |
| `proceso` | proceso | 435 |
| `gen` | genera / general | 404 |
| `resultado` | resultado | 514 |
| `transacc` | código de transacción | 412 |
| `cargo` | cargo / débito | 474 |
| `calle` | calle (domicilio) | 358 |

---

## Cómo se usa este análisis

1. **TRASCIENDE → contrato target.** Los términos que entran/salen por parámetro o BD definen la interfaz del microservicio (OpenAPI / esquema de datos). Ej. `cuenta`, `monto`, `numcte` trascienden.
2. **EFÍMERA-CÁLCULO → reglas de negocio.** Variables como `vimp_isr`, `vcalc_int`, `vtasa_isr_tr` son locales pero llevan la fórmula — se documentan en `business-rules-bcop.md` y requieren golden master exacto.
3. **EFÍMERA → descartable en el contrato.** Códigos de retorno, contadores y banderas técnicas son detalle de implementación; el target los reescribe libremente.

> ⚠ **Heurística, no análisis formal de data-flow:** el scope se infiere por dónde aparece el identificador (firma / tabla / DEFINE). Casos límite (variables reusadas, SQL dinámico) requieren revisión. La distinción efímero/trasciende es direccional, útil para priorizar el contrato y las reglas.

*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: source/ + sp_vocab.py*