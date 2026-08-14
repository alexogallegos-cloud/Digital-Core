> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Cross-Reference KB · Generado: 2026-08-02 · Scope expandido: 2026-08-03 (D01-D49)

# Cross-Reference KB — Informix

Este directorio conecta el vocabulario, las reglas de negocio y el grafo de llamadas del sistema Informix en un único mapa de conocimiento navegable. Cada artefacto toma un ángulo de análisis diferente; juntos permiten responder preguntas que ninguna fuente aislada puede responder: ¿qué procedimiento concentra mayor riesgo regulatorio?, ¿qué término de negocio es transversal a más lógica?, ¿cuáles SPs son candidatos obligatorios para el golden master de migración?

---

## Tabla de Contenidos

| Artefacto | Descripción |
|-----------|-------------|
| [sp-rules-vocab-map.md](sp-rules-vocab-map.md) | Top 100 SPs por densidad de conocimiento · Índice por Categoría · Índice Regulatorio |
| [vocab-sp-coverage.md](vocab-sp-coverage.md) | Mapa vocabulario → SPs · Términos sin cobertura de reglas |
| [regulatory-sp-index.md](regulatory-sp-index.md) | Índice regulatorio completo por organismo: CNBV, CONDUSEF, SAT, Banxico, IPAB, TESOFE |
| [component-dependency-map.md](component-dependency-map.md) | Mapa de dependencias entre componentes — SPs cross-DB, contratos ACL, blast radius |
| [latency-baseline-bcop.md](latency-baseline-bcop.md) | Latency baseline — percentiles P50/P95/P99 por dominio y SP (fuente: logs ESB) |
| [domain-dependency-matrix.md](domain-dependency-matrix.md) | Matriz N×N de llamadas cross-DB entre los 16 dominios analizados |
| [../../output/log-analysis/19-performance-baseline-from-logs.md](../../output/log-analysis/19-performance-baseline-from-logs.md) | Performance baseline desde logs — volumen de llamadas por SP y dominio |
| [../../output/log-analysis/20-latency-baseline.md](../../output/log-analysis/20-latency-baseline.md) | Latency baseline cross-domain — datos raw para comparación post-migración |
| [../../output/log-analysis/21-latency-all-sps.md](../../output/log-analysis/21-latency-all-sps.md) | Latencia individual por SP — ranking completo para priorización golden master |

---

## Resumen Numérico

| Dimensión | Valor |
|-----------|-------|
| SPs con reglas de negocio | 3,676 |
| Total reglas de negocio | 7,784 |
| Términos de vocabulario (átomos + compuestos) | 663 |
| Nodos en callgraph | 3,761 |
| Edges en callgraph | 34,279 |
| SPs con anotación regulatoria | 839 |
| Reglas con referencia regulatoria | 2,434 |

### Distribución por Regulador

| Regulador | # Reglas | # SPs |
|-----------|----------|-------|
| Banxico | 52 | 34 |
| CNBV | 1,697 | 540 |
| CONDUSEF | 622 | 237 |
| IPAB | 195 | 89 |
| SAT | 191 | 87 |
| TESOFE | 22 | 16 |

### Distribución por Categoría

| Categoría | # Reglas | # SPs |
|-----------|----------|-------|
| CALCULO_FINANCIERO | 2,517 | 1,231 |
| REGULATORIO | 2,434 | 839 |
| OPERACIONAL | 1,696 | 1,258 |
| PARAMETRIA | 455 | 357 |
| RIESGO_CREDITO | 321 | 234 |
| PAGOS_TRANSFERENCIAS | 173 | 118 |
| CONTABILIDAD_REPORTES | 126 | 113 |
| FLUJO_OPERATIVO | 53 | 41 |
| ATENCION_CLIENTE | 20 | 13 |

### Distribución por Dominio — D01-D16 (analizados)

| Dominio | BD | # Reglas | # SPs |
|---------|-----|----------|-------|
| D03 Créditos | bdicred | 1,743 | 522 |
| D04 Cheques | bdicheq | 1,344 | 658 |
| D01 Canal | bdicnweb | 1,339 | 1,058 |
| D02 Integr. | bdinteg | 723 | 396 |
| D16 Intercard | intercard | 324 | 113 |
| D06 Solic. | bdisolic | 251 | 96 |
| D07 Aclar. | bdiaclaracion | 217 | 41 |
| D11 Cobr. | bdicobranza | 209 | 75 |
| D05 Saldos | bdisac | 208 | 99 |
| D08 SPEI | bdispei | 117 | 53 |
| D14 BEI | bdibei | 90 | 34 |
| D12 Cont. | bdicont | 87 | 51 |
| D13 TEF | bditef | 75 | 38 |
| D10 Suc. | bdisuc | 62 | 31 |
| D15 LIDE | bdilide | 44 | 21 |
| D09 Mensaj. | bdimnsj | 22 | 19 |

### Distribución por Dominio — D17-D49 (en scope, pendientes de análisis)

> Estos dominios se incorporaron al scope el 2026-08-03. Los conteos de reglas y SPs se actualizarán conforme se ejecute el scatter-gather en cada dominio. Los 5 marcados con (*) ya tienen reglas detectadas en la extracción amplia v2.2.

| Dominio | BD | # Reglas* | # SPs fuente | Estado |
|---------|-----|-----------|-------------|--------|
| D28 Inversiones* | bdinvers | 155 | 48 | PENDIENTE |
| D24 Buró Crédito* | bdiburo | 153 | 64 | PENDIENTE |
| D20 Progr. Beneficios* | bdiprog | 115 | 143 | PENDIENTE |
| D21 Domiciliación* | bdidomi | 99 | 142 | PENDIENTE |
| D19 Tarjetas* | bditarjeta | 93 | 162 | PENDIENTE |
| D17 Banca Internet | bdibpi | — | 315 | PENDIENTE |
| D18 Intercard BPI | intercardbpi | — | 203 | PENDIENTE |
| D22 Transferencias | bditransfer | — | 107 | PENDIENTE |
| D23 MIS | bdmis | — | 106 | PENDIENTE |
| D25 Site ESP | bdisitesp | — | 53 | PENDIENTE |
| D26 Prospectos | bdiprospectos | — | 50 | PENDIENTE |
| D27 Auditoría | bdiauditor | — | 49 | PENDIENTE |
| D29 Edo Cta Electr. | bdiedoelec | — | 47 | PENDIENTE |
| D30 Tarjeta Coppel | bditarjcop | — | 41 | PENDIENTE |
| D31 Ctas/Cheq aux. | bdicntchq | — | 37 | PENDIENTE |
| D32 Reportes | bdireports | — | 36 | PENDIENTE |
| D33 Monitor Cobr. | bdimonitorcob | — | 33 | PENDIENTE |
| D34 Respaldos | bdiresp | — | 30 | PENDIENTE |
| D35 Digital | bdidigital | — | 24 | PENDIENTE |
| D36 Rep. Automát. | bdirepaut | — | 12 | PENDIENTE |
| D37 Adm. Nómina | bdiadminnomina | — | 11 | PENDIENTE |
| D38 Compl. Bot | bdicplbot | — | 8 | PENDIENTE |
| D39 Servicios | bdiservicios | — | 6 | PENDIENTE |
| D40 BI | bdibi | — | 6 | PENDIENTE |
| D41 Corresponsalía | bdicorresp | — | 6 | PENDIENTE |
| D42 IVR | bdivr | — | 6 | PENDIENTE |
| D43 Trasp. Préstamos | bditrapres | — | 5 | PENDIENTE |
| D44 Rechazos | bdirech | — | 4 | PENDIENTE |
| D45 Premios | bdiprem | — | 2 | PENDIENTE |
| D46 Oficina | bdiofi | — | 2 | PENDIENTE |
| D47 Garantías | bdigaran | — | 1 | PENDIENTE |
| D48 Riesgos | bdiriesgos | — | 1 | PENDIENTE |
| D49 RST | bdirst | — | 1 | PENDIENTE |

---

## Propósito de la Cross-Reference

El objetivo es conectar el vocabulario, las reglas de negocio y el grafo de llamadas en un único mapa de conocimiento navegable que permita:

- Identificar los procedimientos de mayor criticidad para el golden master de migración
- Rastrear cualquier término de negocio hacia todos los SPs que lo implementan
- Priorizar la cobertura de pruebas por densidad regulatoria y de riesgo
- Detectar gaps de extracción donde el vocabulario no tiene cobertura en reglas
- Establecer el blast radius de cualquier cambio en el callgraph

Estos artefactos son input directo a las fases BUILD y TEST del SDLC del componente SPE-AM-001 y alimentan el Digital Brain SQLite semántico (BCOPBrain).
