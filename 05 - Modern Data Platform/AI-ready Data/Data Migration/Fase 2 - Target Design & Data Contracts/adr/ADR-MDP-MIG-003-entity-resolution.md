# ADR-MDP-MIG-003 — Estándar de Entity Resolution SAP↔CRM

- Estado: ACEPTADO
- Fecha: 2026-06-01

## Contexto
El cliente es la misma entidad en SAP (BUT000) y en el CRM (crm_account) y ningún FK lo
declara (acoplamiento oculto). El contrato `customer` depende de resolverlo.

## Decisión
Resolución en cascada:
1. **Determinístico**: si `crm_account.sap_partner_ref` resuelve en BUT000 -> match exacto.
2. **Fuzzy**: si no, match por `(norm_name + country)` (norm = sin acentos, mayúsculas, sin
   puntuación ni sufijos legales).
3. **Merge**: múltiples cuentas CRM del mismo party -> 1 golden record (MDM).
4. **HITL**: casos ambiguos -> revisión de Data Steward. Sin resolución -> prospecto (no cliente).

## Consecuencias
- El crosswalk es auditable y versionado; se mide precision/recall contra el ground truth del lab.
- Owner: Data Steward - Customer. El contrato `customer` es dueño de la regla.
