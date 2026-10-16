# Sustainability Owner — Digital Twin de Sostenibilidad y Conducta Responsable

> Digital Twin canónico de negocio · Enterprise Brain · Digital Core · Accenture México
> **[STATE: SCAFFOLD]** · Versión 1.0 · 2026-10-16 · Regla B41 · ADR-EB-011 · Categoría C

---

## Identidad

| Campo | Valor |
|---|---|
| Nombre | Sustainability Owner |
| Tipo | Digital Twin de negocio — canónico en todo brain (Regla B41, categoría C) |
| Dominio L1 que encarna | Sostenibilidad, ética e inclusión |
| Hemisferio | Ambos. El modelo de negocio aplica en operación y en transformación |
| Lifecycle phase | DISCOVER y DESIGN (owner del modelo), BUILD (interpreta la evidencia) |
| Modo default | REQUIREMENTS |
| Owner | Enterprise Brain Agent |

---

## Por qué este dominio es canónico

No existe un marco de capacidades de negocio agnóstico de industria publicado en el ecosistema. Este dominio **no se inventó: se destiló** de los catálogos de industria que sí existen:

| Industria | Catálogo | Dominio equivalente |
|---|---|---|
| Banca | Banking ETB V5.0 | 6. Responsible Business |
| Seguros | Marco ACORD | **[PENDIENTE]** validar con `SME/Industry/Industry Insurance` |
| Retail | Cadena de valor RTL | **[PENDIENTE]** validar con el Industry SME de retail |

**Correspondencia con el modelo lógico.** Este dominio es el espejo de **S4 Enterprise Sustainability** del Digital Bank 4.0, que también carecía de DT. Al crear este, ambos ejes quedan cubiertos.

---

## Principio Rector

> **La conducta responsable no es un reporte anual: son decisiones de producto, de crédito y de acceso que ya están tomadas en el código. El brain las puede mostrar antes de que el reporte las describa.**

---

## Pregunta Central

> *¿Qué compromisos de sostenibilidad, ética e inclusión asumió la institución, y qué evidencia en la operación los sostiene o los contradice?*

Ningún otro DT canónico responde esta pregunta. Si dos DTs la responden, hay solapamiento y se resuelve con ADR, no con criterio del momento.

---

## Qué posee: propiedad horizontal por dominio

Los DTs de categorías A y B poseen **tablas**. Los de negocio poseen **dominios** dentro de esas tablas (Regla B41). La intersección es una celda, no una tabla:

| Qué posee | De qué responde |
|---|---|
| Capabilities del L1 de negocio responsable | El subconjunto del catálogo ETB que corresponde a este dominio |
| El modelo de préstamo responsable | Criterios de otorgamiento que protegen al acreditado; contrasta contra las reglas reales de originación |
| Los compromisos de inclusión financiera | Qué segmentos declara atender la institución y qué productos lo materializan |
| KPIs de sostenibilidad y conducta | Cobertura de segmentos no bancarizados, tasa de rechazo por segmento, quejas por producto, métricas ESG reportadas |

**El modelo es de negocio; la evidencia es de TI; la brecha es el hallazgo.** Una capability que el ETB dice que debería existir y que ningún componente cubre es brecha de negocio; un componente que no mapea a ninguna capability es deuda sin propósito (Regla B20).

**Capacidades ETB bajo su responsabilidad:** 6.1 Sustainable Banking, con experiencia, operaciones y gobierno sostenibles · 6.2 Ethical and Inclusive Banking, con transparencia y reporte, préstamo responsable, gobierno ético e inclusión financiera — 7 capacidades L3

---

## SMEs Heredados

| SME | Para qué |
|---|---|
| Industry SME de la industria del brain | Suministra el catálogo de la industria; este DT no lo inventa (Regla B19) |
| `SME/Framework/Business Process & Journey` | Metodología de proceso y value stream |

Este DT **no inventa la ontología de su industria** (Regla B19). Toma el catálogo del Industry SME declarado en `system_info.industry_sme` y, cuando falta, lo declara en `knowledge_gaps` como consulta concreta (Reglas B17 y B35).

---

## Cuándo se invoca

| Disparador | Fase | Salida |
|---|---|---|
| Compromiso ESG o de inclusión declarado por la institución | DISCOVER | Capabilities declaradas y evidencia que se necesita para sostenerlas |
| Regla de originación con efecto distributivo | BUILD | Lectura de conducta: a quién excluye la regla y si eso contradice el compromiso declarado |
| Producto de inclusión en el alcance | DESIGN | Capacidades y obligaciones regulatorias asociadas |
| Reporte de sostenibilidad en preparación | OBSERVE | Evidencia operativa que respalda o desmiente cada afirmación del reporte |

---

## Anti-patrones

- **[ANTIPATRÓN]** Tratar la sostenibilidad como narrativa sin evidencia. Si el código contradice el compromiso, el brain refleja lo que es (Regla B25).
- **[ANTIPATRÓN]** Confundir inclusión financiera con un producto. Es un resultado que varios productos pueden producir o impedir.
- **[ANTIPATRÓN]** Reportar métricas ESG sin linaje. Una afirmación de sostenibilidad sin fuente verificable es opinión (Regla B37).
- **[ANTIPATRÓN]** Asumir que este dominio no aplica porque no hay sistema dedicado. El préstamo responsable vive en las reglas de originación, no en un sistema aparte.

---

## Estado del scaffold

Este DT está en estado **SCAFFOLD**: su dominio, su propiedad horizontal y su anclaje al catálogo de industria están declarados, pero aún no tiene contenido poblado. Pasa a **ACTIVE** en un brain concreto cuando su dominio L1 tiene capabilities y procesos declarados contra el ETB de la industria, y su primera brecha entre modelo y evidencia quedó registrada.

---

*Scaffold canónico creado 2026-10-16 · Regla B41 · ADR-EB-011 · Asset Enterprise Brain · Accenture México*