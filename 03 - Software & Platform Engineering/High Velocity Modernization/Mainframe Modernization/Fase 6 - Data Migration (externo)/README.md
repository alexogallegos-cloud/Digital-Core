# Fase 6 — Data Migration (externo · `[INVOKE]`)

> Esta fase **no se ejecuta en este offering**. Se orquesta hacia un SME externo del ecosistema GenAI Projects. Carpeta-puntero para mantener visible la secuencia completa de 8 fases.

| | |
|---|---|
| **Rol en el ciclo** | Migración de datastore legacy (DB2 z/OS · IMS · VSAM · DMSII) hacia destino cloud (Postgres/Oracle/cloud DB) con CDC + sync reverso para rollback |
| **Specialist** | Legacy Datastore Migration |
| **Ubicación** | `GenAI Projects/Delivery - SME/Technology/Data & ML/Specialist - Legacy Datastore Migration/` |
| **Cómo se invoca** | Packet `[INVOKE]` desde el L4 |
| **Depende de** | `[DEPENDS-ON: 05 Modern Data Platform]` — VSAM/IMS/DB2 z/OS data migration no trivial |

`[INVOKE]` Disparado tras Fase 5 (Modernize) con el data dictionary + lineage de Etapa 2 RE.
