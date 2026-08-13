# D26-bdiprospectos — Prospectos / Captación de Clientes
> **Dominio**: Captación — Gestión de prospectos y solicitudes de cobranza
> **Base de datos Informix**: bdiprospectos
> **Estado**: [DISCOVER ETAPA 1 — caracterización inicial completa] · 2026-08-12
> **Prioridad**: ALTA — 3 ESB-exposed · inicio del ciclo de vida del cliente

---

## Descripción de Negocio

Gestiona el **pipeline de captación de clientes** de BanCoppel: desde la identificación del prospecto hasta la consulta de solicitudes de cobranza pre-aprobadas. Es el punto de entrada del ciclo de vida del cliente (antes de bdicnweb D01 que maneja la cuenta activa). Integrado con la red de crédito Coppel (`bdicred` D03) para consulta de pre-aprobados.

## Estadísticas (brain.db · 2026-08-12)

| Métrica | Valor |
|---------|-------|
| SPs totales | 54 |
| Reglas extraídas | 520 |
| SBVR formal | 0 (Layer C+ pendiente) |
| ESB-exposed | 3 |
| CTM batch | 0 |

## SPs ESB-Exposed (Journeys candidatos)

| SP | Descripción funcional | Riesgo |
|----|----------------------|--------|
| `sp_consultactepr` | Consulta cliente prospecto | PII — retorna datos personales del prospecto |
| `sp_consultasolcobranza` | Consulta solicitudes de cobranza (pre-aprobados) | Financiero — expone línea de crédito pre-aprobada |
| `sp_identcte_pros` | Identifica y valida cliente prospecto | PII + CONDUSEF — datos de identificación |

## Riesgos de Migración Clave

| Riesgo | Descripción |
|--------|-------------|
| PII — prospecto | Datos personales antes de la cuenta; retención y derecho de eliminación LFPDPPP |
| CONDUSEF | Solicitudes de cobranza están reguladas; proceso de altas/bajas requiere notificación |
| Cross-domain | Dependencia con D03-bdicred (pre-aprobados) y D01-bdicnweb (conversión a cuenta) |
| Lógica de scoring | Las 520 reglas pueden contener lógica de pre-aprobación crediticia; revisar en parallel-run |

## Diagnóstico de Dominio

- **Tipo TOGAF**: channels (interface de captación omnicanal)
- **Sistema de**: engagement (prospectos son datos transitorios hasta conversión)
- **Dependency**: D03-bdicred (pre-aprobados), D01-bdicnweb (conversión)

## Próximos Pasos

1. Ejecutar Layer C+ SBVR sobre 520 reglas — detectar scoring crediticio / CONDUSEF
2. Agregar 3 SPs ESB-exposed a `journeys-data.json`
3. Mapear flujo: Prospecto → Pre-aprobado → Apertura cuenta (D01)
4. Consultar SME Industry Banking sobre criterios CONDUSEF para prospectos

---

*Actualizado 2026-08-12 — DISCOVER Etapa 1 · Brain-First characterization*