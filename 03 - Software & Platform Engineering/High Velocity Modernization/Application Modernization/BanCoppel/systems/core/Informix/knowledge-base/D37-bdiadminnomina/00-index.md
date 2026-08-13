# D37-bdiadminnomina — Administración de Cuenta Nómina (BPI)
> **Dominio**: Nómina — Cuentas de nómina y beneficios de empleados
> **Base de datos Informix**: bdiadminnomina
> **Estado**: [DISCOVER ETAPA 1 — caracterización inicial completa] · 2026-08-12
> **Prioridad**: MEDIA-ALTA — 4 ESB-exposed · integración con sistema nómina externo (SN)

---

## Descripción de Negocio

Gestiona las **cuentas de nómina** del programa BPI (Banco Para los que trabajan Coppel / Beneficios por Ingreso). Los SPs tienen prefijo `sp_sn_` (Sistema Nómina) y exponen APIs para consulta de beneficios de cuenta, status del cliente nómina y gestión de parámetros. Integrado con empleadores de la red Coppel que dispersan nómina vía BanCoppel.

## Estadísticas (brain.db · 2026-08-12)

| Métrica | Valor |
|---------|-------|
| SPs totales | 11 |
| Reglas extraídas | 56 |
| SBVR formal | 0 |
| ESB-exposed | 4 (todos los SPs estratégicos) |
| CTM batch | 0 |

## SPs ESB-Exposed (Journeys candidatos)

| SP | Descripción funcional | Riesgo |
|----|----------------------|--------|
| `sp_sn_retrieve_account_benefit` | Consulta beneficios de cuenta nómina | Financiero — monto/beneficios |
| `sp_sn_retrieve_client_status` | Consulta status del cliente nómina | PII — estado laboral |
| `sp_sn_insert_log_playroll_account` | Registra log de cuenta nómina | Auditoría — trazabilidad de nómina |
| `sp_consulta_parametros_cuenta_nomina` | Consulta parámetros de configuración de cuenta nómina | — |

## Riesgos de Migración Clave

| Riesgo | Descripción |
|--------|-------------|
| Nómina regulada | STPS / IMSS regulan datos laborales; retención y acceso controlado |
| Integración empleadores | El sistema nómina externo (SN) consume estas APIs; contratos de interfaz a preservar |
| Bajo volumen = alta criticidad | 11 SPs pero 4 ESB-exposed; cualquier degradación afecta directamente a empleados |
| Naming en inglés | `sp_sn_retrieve_*` sugiere que el dominio nació de integración con sistema externo angloparlante |

## Diagnóstico de Dominio

- **Tipo TOGAF**: channels (interfaz del canal nómina)
- **Sistema de**: engagement (datos transaccionales de nómina, no core bancario)
- **Dependency**: D01-bdicnweb (cuenta bancaria asociada), sistema nómina externo (SN)

## Próximos Pasos

1. Identificar sistema externo "SN" y sus consumidores (empleadores en red Coppel)
2. Ejecutar Layer C+ SBVR sobre 56 reglas
3. Agregar 4 SPs ESB-exposed a `journeys-data.json`
4. Validar con SME Industry Banking: regulación STPS/IMSS para datos de nómina bancaria

---

*Actualizado 2026-08-12 — DISCOVER Etapa 1 · Brain-First characterization*