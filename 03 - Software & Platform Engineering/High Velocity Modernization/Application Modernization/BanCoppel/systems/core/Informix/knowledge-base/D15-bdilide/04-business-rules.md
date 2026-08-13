# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Reglas de Negocio y Fórmulas

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`) — Circular PLD, Título XIV CUB
- **SME Regulatorio — SAT** (`SME/Regulatory/SAT/`) — IDE, exentos, archivos de intercambio
- Domain Expert — BanCoppel / Área de Cumplimiento (validación funcional regulatoria)
- QA Lead — Equivalencia Funcional

> `[COMPLIANCE-SIGN-OFF-REQUIRED]` en toda regla que afecte umbrales regulatorios o criterios de reporte.

---

## Resumen

**7 fórmulas financieras** + **12 validaciones** extraídas del código de `bdilide` en el análisis inicial. Los 96 SPs aislados aún no han sido analizados a profundidad — se estima que contienen 50-100 reglas adicionales. `[DATO-REQUERIDO]`

## Fórmulas de negocio extraídas del código (evidencia directa)

| ID | SP · Línea | Regulador | Fórmula | Riesgo equivalencia |
|----|-----------|-----------|---------|---------------------|
| BR-D15-001 | `sp_acumulacionoperaciones` L192 | SHCP/IDE | `vmImpGrabar = vmImpTotIde - vmMontLimite` | 🔴 MONEY/aritmética financiera |
| BR-D15-002 | `sp_acumulacionoperaciones` L193 | SHCP/IDE | `vmMontoRecaudar = vmImpGrabar * viPorcaRecau` | 🔴 MONEY/aritmética financiera |
| BR-D15-003 | `sp_acumulacionoperaciones` L194 | SHCP/IDE | `vmMontoRecaudar = ROUND(vmMontoRecaudar - 0.01)` | 🔴 CRÍTICO — ajuste histórico de redondeo |
| BR-D15-004 | `sp_acumulacionoperaciones` L85 | PLD | `IF pFechaProceso IS NULL OR pFechaProceso = "" THEN [error 00018]` | Validación de entrada |
| BR-D15-005 | `sp_acumulacionoperaciones` L126 | PLD | `LET vcCodRet = "018" — proceso de recaudación diaria ya ejecutado` | Control de idempotencia |
| BR-D15-006 | `sp_acumulacionoperaciones` L162 | SHCP/IDE | `IF vmMontLimite = 0 OR vmMontLimite IS NULL THEN [error — parámetro no configurado]` | Validación de parámetro crítico |
| BR-D15-007 | `sp_acumulacionoperaciones` L171 | SHCP/IDE | `IF viPorcaRecau = 0 OR viPorcaRecau IS NULL THEN [error — porcentaje no configurado]` | Validación de parámetro crítico |
| BR-D15-008 | `sp_actparamtraspmovefec` L77 | PLD | `IF vparam_serial IS NULL OR vparam_serial = '' THEN [error]` | Validación de parámetro |
| BR-D15-009 | `sp_actparamtraspmovefec` L86 | PLD | `LET vbrinca = vpromedio * 2` | Factor de salto en paginación/batch |
| BR-D15-010 | `sp_actualizacodfechaenvio` L112 | CNBV/SHCP | `vcArchivoCT = TRIM(vcArchivoCT) \|\| TRIM(SUBSTR(pNomArch,3,LENGTH(pNomArch)-2))` | Construcción del nombre de archivo de control |
| BR-D15-011 | `borramovs_movefechis` L24 | PLD | `LET vcomienza = -1` (bandera de inicio de cursor) | Control de cursor |
| BR-D15-012 | `borramovs_movefechis` L65 | PLD | `LET vcontador = vcontador + 1` | Contador de registros procesados |

## Reglas regulatorias aplicables al dominio

### Marco FATF/GAFI — Recomendaciones aplicables a bdilide

| Rec. FATF | Obligación | Implementación esperada en bdilide |
|-----------|-----------|-----------------------------------|
| R.10 | Debida diligencia del cliente (DDC) | Verificación de clientes en lista LIDE antes de operar; `sl_lide` como registro principal |
| R.11 | Conservación de registros | Registros transaccionales PLD deben conservarse ≥ 10 años (LFPIORPI Art. 19) |
| R.12 | Personas políticamente expuestas (PEP) | `[DATO-REQUERIDO]` — Confirmar si bdilide incluye screening PEP o se delega a otro dominio |
| R.13 | Banca corresponsal | `[DATO-REQUERIDO]` — Verificar si aplica para BanCoppel |
| R.15 | Tecnologías nuevas | Motor PLD debe evaluarse en el target contra nuevos vectores de riesgo digital |
| R.16 | Transferencias electrónicas | Análisis de patrones en transferencias — vinculado con `bditef` y `bdispei` |
| R.20 | Reporte de operaciones sospechosas | Motor de detección de operaciones inusuales → reporte a UIF/SHCP |

### Umbrales CNBV/SHCP para reporte de operaciones

| Tipo de operación | Umbral | Base legal | Frecuencia de reporte |
|-------------------|--------|-----------|----------------------|
| Operaciones relevantes (depósitos en efectivo) | $7,500 USD o equivalente en MXN | LFPIORPI Art. 17 | Mensual a SHCP |
| Operaciones inusuales | Sin umbral fijo — criterio de patrón | CUB Título XIV Art. 124 | Cuando se detecten |
| Operaciones preocupantes | Sin umbral fijo — criterio de patrón | CUB Título XIV Art. 125 | Cuando se detecten |
| Operaciones en efectivo acumuladas | >$7,500 USD en 6 meses | LFPIORPI Art. 17 Fr. I | Mensual a SHCP |

> `vmMontLimite` en `sl_parametros` debe contener el equivalente MXN de $7,500 USD actualizado. `[COMPLIANCE-SIGN-OFF-REQUIRED]` — el valor del tipo de cambio de referencia debe estar documentado y auditado.

### Reglas CNBV — Circular única de bancos, Título XIV (PLD)

| Artículo CUB | Obligación | Impacto en bdilide |
|-------------|-----------|-------------------|
| Art. 115 | Sistema automatizado de monitoreo de operaciones | Motor PLD en bdilide es este sistema — equivalencia funcional ≥ 99.99% requerida |
| Art. 124 | Reporte de operaciones inusuales a UIF | SPs de generación de reporte deben producir el archivo en el formato exacto de CNBV |
| Art. 125 | Reporte de operaciones preocupantes | `[DATO-REQUERIDO]` — Identificar SPs de reporte de operaciones preocupantes |
| Art. 129 | Conservación de registros PLD | Base de datos de archivo (`sl_movefec_his`) debe migrarse íntegramente |
| Art. 130 | Confidencialidad de reportes UIF | Los logs del motor PLD no deben exponer el contenido de los reportes UIF |

### Reglas SAT — Impuesto a los Depósitos en Efectivo (IDE)

| Norma | Obligación | Implementación en bdilide |
|-------|-----------|--------------------------|
| LIDE Art. 2 | Umbral de recaudación de IDE | `vmMontLimite` en `sl_parametros` — verificar vigencia (LIDE fue abrogada en 2014 pero puede haber obligaciones históricas) |
| Archivo de consulta SAT | Formato de intercambio de información de exentos | `sp_cargainformesat` genera archivos en formato SAT — formato debe preservarse exactamente |
| Archivo de resultado SAT | Respuesta del SAT sobre exentos | `sp_cargaresultadosat` procesa la respuesta — lógica de parsing debe migrar exacta |
| Constancias de retención | Emisión de constancias al cliente | `sl_constancias` — verificar si se generan documentos físicos o solo registros |

### Reglas de listas negras (LIDE + OFAC + ONU)

| Lista | Fuente | Frecuencia de actualización | Proceso de screening |
|-------|--------|---------------------------|---------------------|
| LIDE interna | BanCoppel — generada internamente | Tiempo real + batch diario | Verificación en onboarding y en operaciones relevantes |
| Lista OFAC | US Treasury — Office of Foreign Assets Control | Diario | `[DATO-REQUERIDO]` — Confirmar si bdilide o un sistema externo hace el screening |
| Lista ONU (Resolución 1267) | ONU | Cuando se actualiza | `[DATO-REQUERIDO]` — Confirmar mecanismo de actualización |
| Lista SAT contribuyentes incumplidos | SAT — Art. 69 CFF | Quincenal | `sl_consat` puede contener referencias |

## `[SME-PENDING]` Validación regulatoria

- [ ] CNBV: confirmar que `vmMontLimite` corresponde exactamente al umbral vigente (puede haber cambios por tipo de cambio o modificaciones a LFPIORPI).
- [ ] SAT: validar si el régimen IDE sigue activo para BanCoppel (la LIDE fue abrogada en 2014 — puede haber disposiciones transitorias vigentes).
- [ ] Cumplimiento BanCoppel: documentar si el motor PLD cubre las 40 recomendaciones FATF o solo las de la CUB.
- [ ] Identificar todos los SPs que generan archivos de reporte y validar su formato contra el Layout oficial del regulador.
- [ ] Confirmar el tratamiento de BR-D15-003 (`ROUND - 0.01`) con el Área de Cumplimiento — este ajuste puede tener consecuencias en el monto reportado al SAT.

---
*Generado: análisis estático bdilide · 2026-08-03*
