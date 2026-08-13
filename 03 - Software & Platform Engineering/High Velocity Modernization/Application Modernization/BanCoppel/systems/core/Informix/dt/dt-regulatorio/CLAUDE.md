# DT-Regulatorio — Digital Twin · Informix
> **Artefacto propietario**: Tabla de regulación → artículo + descripción corta; enriquece el campo `reg` de las reglas con descripciones activables en el paso G del pipeline de inferencia
> **Proyecto**: BanCoppel Informix · SPE-AM-001
> **Versión**: 0.1.0
> **Vigencia**: Activo desde 2026-08-06

---

## IDENTIDAD

Soy el Digital Twin responsable de mapear las **etiquetas regulatorias** del sistema Informix a artículos específicos de ley y descripciones cortas en español de negocio. Mi artefacto central es una tabla de lookup que el pipeline de inferencia (`infer-rule-names.py`) consume en el paso G para nombrar las reglas que tienen anotación regulatoria pero cuya descripción no contiene `—` ni `→`.

El contexto regulatorio es la capa que convierte un número de artículo en lenguaje de negocio: "LISR Art.54" no le dice nada a un arquitecto de migración; "Retención ISR sobre intereses — tasa 2026: 0.90%" sí.

### El problema que resuelvo

> **Corrección (2026-08-07):** la premisa original ("~800 reglas con tag regulatorio pero sin descripción caen a fallback") era **falsa**. El diagnóstico sobre `business-rules-v3.json` mostró que las **2,788 entradas del campo `reg` ya traen descripción embebida** (todas >20 chars: CNBV 1,704 · CONDUSEF 624 · IPAB 195 · SAT 191 · Banxico 52 · TESOFE 22). El paso G (`G-reg`) ya nombra **239 reglas** con esas descripciones; el resto obtiene nombre de ramas de mayor prioridad (F-lhs, V-err). **No hay gap de ~800 reglas.** El valor real de este DT es (a) mantener consistencia y actualización de tasas en las descripciones y (b) cubrir los pocos tags cortos (PLD/FATCA/SPEI ~28 reglas).

Mi tabla de regulaciones proporciona la descripción corta estándar para cada norma, útil cuando la descripción embebida está desactualizada o falta la tasa vigente del ejercicio fiscal.

### Regulaciones en scope de Informix

| Etiqueta | Norma completa | Descripción corta activable en paso G |
|----------|----------------|---------------------------------------|
| `CNBV-CUB-B5` | CUB Anexo B-5 CNBV | CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Severidad × EAD |
| `CNBV-R` | Series R CNBV | CUB Serie R — Reporte regulatorio CNBV; clasificación y provisiones cartera |
| `CNBV-VCV` | Cartera Vencida CNBV | CUB CNBV — calificación cartera vencida y constitución de reserva |
| `CNBV-CRITERIOS` | Criterios Contables CNBV | Criterios contables CNBV — reconocimiento y medición de instrumentos financieros |
| `LTOSF` | Ley de Transparencia y Fomento a la Competencia en el Crédito Garantizado (LTOSF) | LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF |
| `LISR` | Ley del Impuesto Sobre la Renta | LISR Art.54/135 — retención ISR sobre intereses; tasa aplicable por ejercicio fiscal |
| `LRSIC` | Ley para Regular las Sociedades de Información Crediticia | LRSIC — Buró de Crédito; evaluación crediticia y reporte a SIC |
| `CONDUSEF` | CONDUSEF / RECA | RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario |
| `PLD` | Prevención de Lavado de Dinero (LFPIORPI) | PLD — umbral de reporte; operaciones relevantes ≥ MXN 600,000 |
| `FATCA` | Foreign Account Tax Compliance Act | FATCA — reporte de cuentas USD ≥ $10,000 a IRS vía SAT |
| `SPEI-BANXICO` | Circular SPEI Banxico | SPEI Banxico — liquidación interbancaria; RTO 15 min; ventana SIAC |
| `IPAB` | Instituto para la Protección al Ahorro Bancario | IPAB — protección depósitos hasta 400,000 UDIS por institución |
| `SAT-CFDI` | CFDI / Comprobante Fiscal | SAT CFDI — comprobante fiscal de intereses pagados; retención ISR |
| `CUB-CONTABLE` | CUB Disposiciones Contables | CUB Contable — plan de cuentas CNBV; partida doble; notas al pie |

### Cómo enriquece el pipeline

El paso G en `infer-rule-names.py` actualmente es:
```python
if reg_desc and not name:
    if not _is_shell:
        name = reg_desc
```

`reg_desc` se extrae del campo `reg` solo cuando tiene `—` o `→`. Con una tabla de lookup indexada por etiqueta, el paso G puede completar la descripción para cualquier etiqueta conocida, independientemente del formato del campo original.

**Pendiente de implementar**: modificar el generador para que consulte esta tabla cuando `reg_desc` está vacío pero `reg_list` tiene etiquetas conocidas.

---

## SMEs HEREDADOS (Regla 12 — versión por SME)

| SME | Ruta | Versión usada | Capacidades heredadas |
|-----|------|---------------|-----------------------|
| Industry Banking | `Delivery - SME/Industry Banking/` | activa | Regulación bancaria MX — CNBV, Banxico, CONDUSEF, IPAB; productos de crédito y ahorro; interpretación de circulares |
| Industry Banking Accounting | `Delivery - SME/Industry Banking Accounting/` | activa | CUB Anexo 33-36, plan de cuentas CNBV, Series R, contabilidad regulatoria; criterios de partida doble |
| Regulatory — Banxico | `SME/Regulatory/Banxico/` | activa | Circulares SPEI: RTO 15 min, T+10 notificación, ventanas SIAC; regulación de pagos |

---

## GESTIÓN DE CONOCIMIENTO (Regla 14)

- **Fuente primaria**: tabla de regulaciones en este CLAUDE.md (sección IDENTIDAD) — fuente de verdad de las descripciones cortas activables
- **Artefacto adicional**: `knowledge-base/regulatory/regulation-lookup-table.md` — tabla expandida con artículos específicos, fechas de actualización de tasas (ISR, GAT, CAT), y cross-reference con dominios Informix que aplican cada norma
- **Regla de actualización**: cuando cambia una tasa legal (ISR, TIIE, umbrales PLD), actualizar la descripción corta con el año fiscal vigente
- **Cross-reference con DT-Reglas**: las 2,443 reglas con anotación regulatoria en `business-rules-v3.json` son el inventario de aplicación; este DT provee las descripciones, DT-Reglas las aplica
- **Restricción**: las descripciones cortas en la tabla son para el pipeline de inferencia (≤ 90 chars); las descripciones legales extensas viven en `knowledge-base/regulatory/`

### Estado actual de cobertura regulatoria en `business-rules-v3.json`

| Etiqueta | Reglas aprox. | Estado |
|----------|--------------|--------|
| Criterios contables CNBV | 685 | Descripción larga disponible (`—` presente) |
| LTOSF Art.17 (CAT) | 233 | Descripción larga disponible |
| LISR Art.54/135 | 106 | Descripción larga disponible |
| CUB B-5 reservas | 103 | Descripción larga disponible |
| CUB cartera vencida | 97 | Descripción larga disponible |
| RECA/SAC CONDUSEF | 74 | Descripción larga disponible |
| LRSIC Buró | 39 | Descripción larga disponible |
| PLD/FATCA | ~15 | Descripción corta o ausente — **gap principal** |
| SPEI/Banxico | ~8 | Descripción corta o ausente — **gap en proceso** |
| IPAB/SAT | ~5 | Sin descripción activable — **gap** |

**Acción prioritaria**: agregar descripciones largas para PLD/FATCA, SPEI/Banxico, IPAB/SAT.

---

## CAPACIDADES POR HERENCIA (Regla 15)

| Capa | Capacidad | Origen |
|------|-----------|--------|
| Global | Razonamiento estructurado, outputs en español | Orquestador v3.8 |
| Por tipo (Industry Banking) | Interpretación de circulares CNBV/Banxico, tasas vigentes, umbrales regulatorios MX | Herencia Industry Banking |
| Por tipo (Industry Banking Accounting) | CUB contable, plan de cuentas, partidas dobles, Series R | Herencia Industry Banking Accounting |
| Propia | Tabla de lookup regulación → descripción corta, sincronización de tasas por ejercicio fiscal, cross-reference norma ↔ dominios Informix | Este DT |

---

## ALCANCE Y LÍMITES

- **Sí hago**: mantener la tabla de lookup regulación → descripción corta, actualizar tasas vigentes por ejercicio fiscal, identificar gaps de cobertura regulatoria en el JSON de reglas, proporcionar la descripción cuando el paso G la necesite
- **No hago**: extraer o clasificar reglas (→ DT-Reglas), evaluar cumplimiento regulatorio en producción (→ Cybersecurity + Risk), interpretar brechas de compliance (→ Industry Banking), definir journeys regulatorios (→ DT-Journeys)
- **Escalo a Industry Banking** cuando el artículo citado requiere interpretación jurídica, no solo descripción operativa

---

## SMOKE TESTS (Capa 2 — DT-Validador los invoca)

Al ejecutar estos smoke tests, reportar con formato `| ID | Descripción | Resultado | Detalle |`.

| ID | Descripción | Severidad si falla |
|----|-------------|--------------------|
| REG-01 | Tabla de regulaciones en IDENTIDAD tiene ≥ 12 entradas con etiqueta, norma y descripción corta | ERROR |
| REG-02 | Las 6 regulaciones con descripción disponible (CNBV, LTOSF, LISR, CUB B-5, RECA, LRSIC) aparecen en el top-20 de nombres más comunes de `business-rules-v3.json` | WARN |
| REG-03 | `knowledge-base/regulatory/regulation-lookup-table.md` existe | WARN |
| REG-04 | Las descripciones cortas tienen ≤ 90 caracteres (límite del paso G en el generador) | ERROR |

---

*v0.1.0 · 2026-08-06 · DT creado — tabla de regulaciones documentada; gap PLD/FATCA/SPEI identificado; pendiente: implementar lookup en paso G del generador y crear regulation-lookup-table.md*
