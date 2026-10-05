# Evaluación de Plataformas Candidatas — Motor de Pagos MONEX
> Referencia: RFP-PAG v2.6 · Modelo de evaluación G1-G6 · Scoring 0-4 + factores de cobertura

---

## Candidatos en Evaluación

| Plataforma | Vendor | ISO 20022 nativo | CLS | SPEI | Cloud-native | Modelo de propuesta |
|------------|--------|:-:|:-:|:-:|:-:|---|
| **Temenos Payments Hub** | Temenos | Sí | Sí | Configurable | Sí | Joint con Temenos |
| **Form3 Cloud Payments** | Form3 | Sí | Sí | Configurable | Sí (API-first) | Joint con Form3 |
| **Volante VolPay** | Volante Technologies | Sí | Sí | Configurable | Parcial (containerizado) | Joint con Volante |
| **Finastra Global PAYplus** | Finastra | Sí | Sí | Configurable | Parcial | Joint con Finastra |

---

## Criterios de Evaluación Accenture como SI

El modelo del RFP requiere propuesta conjunta Vendor + SI. Como SI, Accenture evalúa las plataformas además por:

### Criterios Técnicos (alineados a PAG-D07 v0.2)

| Criterio | Descripción | Peso |
|----------|-------------|------|
| ISO 20022 nativo | Implementación nativa de mensajes MX — no adaptador/conversión | CRÍTICO |
| CLS Settlement | Habilitación Payment-vs-Payment para FX MONEX | CRÍTICO |
| Conectividad SPEI (Banxico) | Adaptador certificado o certificable | CRÍTICO |
| API-first (OpenAPI 3.1) | Contratos versionados y gobernados | ALTO |
| Multi-riel en un motor | SPEI + SWIFT + SEPA + ACH + FPS en una plataforma | ALTO |
| STP ≥ 99% | Documentado con evidencia, no declaración | ALTO |
| Cloud-native | Kubernetes, autoscaling, multi-AZ, failover probado | ALTO |
| Ecosistema MuleSoft | Integración con Anypoint (backbone MONEX confirmado) | ALTO |
| AI-ready | AI-01 a AI-12 habilitados o habilitables | MEDIO |
| Presencia LATAM / referencias México | Implementaciones bancarias comprobables en región | MEDIO |
| DORA compliance | Para operaciones UK/EU | MEDIO |

### Criterios SI (Accenture)

| Criterio | Descripción |
|----------|-------------|
| Fit-to-Standard depth | Qué % del alcance es estándar vs. extensión/bespoke |
| Implementación LATAM | Accenture tiene práctica certificada con el vendor |
| Tiempo a producción | Timeline realista para 18-24 meses |
| TCO 5 años | Licencias + implementación + operación + upgrades |
| Exit strategy | Portabilidad de datos y operaciones (P-11 del RFP) |

---

## Factores de Cobertura (Scoring RFP)

| Tipo de cobertura | Factor multiplicador |
|-------------------|---------------------|
| Standard (nativo, sin modificación) | × 1.00 |
| Configurable (parámetros existentes) | × 0.95 |
| Extension (customización guiada/API) | × 0.80 |
| External Integration (conector) | × 0.70 |
| Bespoke (desarrollo a medida) | × 0.50 |
| Roadmap (comprometido, no disponible) | × 0.25 |
| Not Covered | × 0.00 |

**Implicación**: cualquier requisito marcado "Bespoke" por el vendor multiplica el costo de implementación y el riesgo de la propuesta.

---

## Contexto de la Demostración (28-Sep-2026)

MONEX evaluará a los candidatos con 10 escenarios de demostración (D-01 a D-10).

**Escenarios de mayor peso para MONEX** (basado en el gap analysis del negocio):

| Escenario | Por qué es crítico para MONEX |
|-----------|-------------------------------|
| D-03: SWIFT cross-border | 80% del negocio MONEX es FX + pagos internacionales |
| D-04: Sanciones + PLD | Requisito CNBV/FCA no negociable — fallo = descalificación |
| D-05: Enrutamiento inteligente | Diferenciador de costo operacional para MONEX |
| D-08: Conciliación con AI | Gap actual del sistema legacy — alta visibilidad |
| D-10: AI Copiloto | AI-02 del RFP — señal de modernidad de la plataforma |

---

## Posición Accenture como SI

### Diferenciadores vs. otros SIs

1. **Digital Brain como activo de entrega**: el gemelo cognitivo del payments-legacy reduce el riesgo de la migración — sabemos exactamente qué capabilities tiene el sistema origen antes de empezar.
2. **Práctica LATAM certificada**: experiencia en implementaciones bancarias SPEI + SWIFT en México (Banamex, BanCoppel, Santander).
3. **DORA specialist**: regulación activa en Monex Europe UK — Accenture tiene práctica DORA.
4. **AI-12 habilitado**: Accenture usa AI en delivery (diseño, pruebas, documentación) con controles de IP — cumple AI-12 del RFP de forma diferenciada.
5. **Ecosistema MuleSoft**: Accenture es partner Premier de MuleSoft — integración con el backbone MONEX confirmado.

### Cómo posicionar en la demostración

- Presentar el Digital Brain de MONEX como activo ya construido (no un entregable futuro)
- Demostrar capabilities del `monex-brain` respondiendo preguntas reales del negocio
- Mostrar el conocimiento del payments-legacy como reducción de riesgo de migración
- Enfatizar Fit-to-Standard First (P-01 del RFP) — Accenture NO recomienda bespoke sin justificación

---

*Fuente: RFP-PAG v2.6 · 2026-09-22*
