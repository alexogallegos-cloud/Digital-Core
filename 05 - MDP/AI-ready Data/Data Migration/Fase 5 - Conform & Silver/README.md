# Fase 5 - Conform & Silver

> Fase del sub-offering **Data Migration** (offering domain AI-ready Data). Fuente de verdad: el `CLAUDE.md` del sub-offering (seccion "Fases de la Migracion"). Esta carpeta es el contenedor orquestador de la fase; el delivery lo ejecuta el SME via `[INVOKE]`.

| Campo | Valor |
|-------|-------|
| Mapea a (DataOps) | BUILD->TEST |
| Objetivo | Tipado, conformado, dedup, FK validadas/cuarentena, MDM/entity resolution -> Silver. |
| Gate de salida | DQ tests verdes; cuarentena documentada. |
| Ejecuta (`[INVOKE]`) | Data & ML SME, Data Architect |

**Enablement / validacion:** Reference Data Lab -> capa **Silver** del medallion (`../Enablement/Training - Reference Data Lab/`).
