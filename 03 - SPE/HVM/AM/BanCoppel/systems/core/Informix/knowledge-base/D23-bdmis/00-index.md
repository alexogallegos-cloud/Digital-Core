# D23-bdmis — MIS Sucursales (Management Information System)
> **Dominio**: MIS — Reportes de gestión y métricas de red de sucursales
> **Base de datos Informix**: bdmis
> **Estado**: [DISCOVER ETAPA 1 — caracterización inicial completa] · 2026-08-12
> **Prioridad**: MEDIA — 107 SPs (mayor D17-D49) · solo batch interno · sin ESB

---

## Descripción de Negocio

Sistema de información de gestión (MIS) de la red de sucursales BanCoppel. Gestiona la **carga, acumulación y consulta de datos de performance de sucursales**: pasos por tipo de sucursal (`tpasotipsuc`), acumulados mensuales por sucursal (`sp_bcpl_acumpsmes`), y actualizaciones de status de solicitudes. Se alimenta de UNLOAD de otras BDs y produce reportes consolidados para la red de distribución Coppel.

Nota: el prefijo es `bdmis` (sin `i`), lo que causa un mismatch con la convención `bdi*` del resto del core.

## Estadísticas (brain.db · 2026-08-12)

| Métrica | Valor |
|---------|-------|
| SPs totales | 107 (mayor dominio D17-D49) |
| Reglas extraídas | 837 |
| SBVR formal | 7 |
| ESB-exposed | 0 (batch exclusivamente) |
| CTM batch | 0 (sp_hints probable — CTM_HINT pendiente) |

## SPs Representativos

| SP | Descripción funcional |
|----|----------------------|
| `cargasp` | Carga masiva `tpasotipsuc` desde archivo UNLOAD (`carga.unl`) |
| `sp_actualiza_statussol` | Actualiza status de solicitud (campo de gestión operativa) |
| `sp_bcpl_acumpsmes` | Acumula pasos/métricas por mes para sucursal |

## Riesgos de Migración Clave

| Riesgo | Descripción |
|--------|-------------|
| Batch/UNLOAD heavy | `cargasp` carga desde `carga.unl` — el proceso UNLOAD/LOAD de Informix debe migrar a COPY PostgreSQL o AWS DMS |
| Tablas de acumulado | 107 SPs procesan acumulados; lógica de MONEY/agregación debe preservarse exacta |
| Mismatch de nombre BD | `bdmis` vs `bdimis` — el prefijo causa que las reglas de brain.db pierdan linking con SPs; requiere corrección en build-brain.py |
| Dependencias ascendentes | Datos vienen de D01-D12 vía UNLOAD; sincronización del pipeline ETL en target |

## Diagnóstico de Dominio

- **Tipo TOGAF**: data (almacén analítico de gestión operativa)
- **Sistema de**: analytical (MIS, no transaccional en tiempo real)
- **sp_archetype**: batch / leaf (todo LOAD/UNLOAD, sin ESB)
- **Dependency**: D01-bdicnweb, D10-bdisuc (fuente de datos), sistema de BI Coppel (consumidor)

## Issue Técnico — Mismatch de Nombre BD

Las reglas en `business-rules-v3.json` usan `db='bdimis'` (con `i`) pero el callgraph usa `bdmis` (sin `i`). Esto causa que `rules.sp` ≠ `sps.id`, rompiendo el JOIN. Impacto: las 837 reglas de D23 no pueden enlazarse a sus SPs en brain.db por ID. Solución: agregar alias `'bdimis': 'D23'` en `DB_TO_DOMAIN` de `build-brain.py` o normalizar el extractor de reglas.

## Próximos Pasos

1. Corregir mismatch `bdmis`/`bdimis` en DB_TO_DOMAIN de build-brain.py
2. Ejecutar Layer C+ SBVR sobre 837 reglas — alto volumen
3. Verificar si CTM gestiona los jobs de `cargasp` (CTM_HINT pendiente)
4. Mapear pipeline ETL: fuentes D01-D12 → transformación → acumulado bdmis

---

*Actualizado 2026-08-12 — DISCOVER Etapa 1 · Brain-First characterization*