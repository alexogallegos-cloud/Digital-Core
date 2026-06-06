# Fase 4 - Ingest & Bronze

> Fase del sub-offering **Data Migration** (offering domain AI-ready Data). Fuente de verdad: el `CLAUDE.md` del sub-offering (seccion "Fases de la Migracion"). Esta carpeta es el contenedor orquestador de la fase; el delivery lo ejecuta el SME via `[INVOKE]`.

| Campo | Valor |
|-------|-------|
| Mapea a (DataOps) | BUILD |
| Objetivo | Extraccion + landing raw 1:1 (carga inicial + CDC) en Bronze. |
| Gate de salida | Bronze poblado = conteo fuente; CDC con lag bajo control. |
| Ejecuta (`[INVOKE]`) | Specialist - Legacy Datastore Migration, Interoperability (CDC) |

**Enablement / validacion:** Reference Data Lab -> capa **Bronze** del medallion (`../Enablement/Training - Reference Data Lab/`).
