# D36-bdirepaut — Reportería Regulatoria CNBV (Sistema Sarjeta / SS)
> **Dominio**: Reportería regulatoria — Informes CNBV / SOFOM
> **Base de datos Informix**: bdirepaut
> **Estado**: [DISCOVER ETAPA 1 — caracterización inicial completa] · 2026-08-12
> **Prioridad**: ALTA — CNBV regulatorio · 10 reglas SBVR formal ya extraídas

---

## Descripción de Negocio

Gestiona la **generación y registro de reportes regulatorios** para la CNBV. Los SPs tienen prefijo `sp_ss_reg_*` (Sistema Sarjeta Reportes) e implementan el flujo: catálogo de períodos → catálogo de reportes → generación de archivos planos (UNLOAD) → archivo de planos para entrega. Equivale a la Serie R de la CNBV (reportes mensuales/trimestrales).

Es el único dominio D17-D49 con cobertura SBVR formal existente (10 reglas), confirmando la presencia de lógica financiera ya caracterizada.

## Estadísticas (brain.db · 2026-08-12)

| Métrica | Valor |
|---------|-------|
| SPs totales | 18 |
| Reglas extraídas | 244 |
| SBVR formal | 10 (único D17-D49 con cobertura inicial) |
| ESB-exposed | 0 (generación interna, consumo por CNBV vía FTP/SFTP) |
| CTM batch | 0 (detectado por sp_hints probable) |

## SPs Representativos

| SP | Descripción funcional |
|----|----------------------|
| `sp_ss_reg_catperiodaut` | Registra catálogo de períodos autorizados |
| `sp_ss_reg_consnomreportes` | Consulta y paginación del catálogo de reportes |
| `sp_ss_reg_detallerep` | Registra detalle de reporte |
| `sp_ss_reg_generareparchplanos` | Genera el reporte en archivo plano |
| `sp_ss_reg_detallereparchplanos_totales` | Registra totales del archivo de reporte |
| `sp_split_cadena` | Utilidad de split de cadena (helper compartido) |

## Riesgos de Migración Clave

| Riesgo | Descripción |
|--------|-------------|
| CNBV compliance | Formato exacto de los archivos planos CNBV (catálogo mínimo, separadores, encoding) debe preservarse |
| DBACCESS/UNLOAD | `sp_ss_reg_generareparchplanos` probablemente usa UNLOAD TO → paths AIX muertos en target |
| Ventana de entrega | Reportes tienen fecha límite CNBV; SLO target debe garantizar generación antes del deadline |
| SME Industry Banking Accounting | Esta BD tiene alta afinidad con D12-bdicont (contabilidad CNBV); requiere coordinación |

## Diagnóstico de Dominio

- **Tipo TOGAF**: compliance (output regulatorio primario)
- **Sistema de**: record (los reportes CNBV son evidencia oficial)
- **Dependency**: D12-bdicont (datos fuente de contabilidad), D03-bdicred (cartera)
- **Regulación**: Serie R CNBV, Circular 3/2012, reportes SOFOM

## Próximos Pasos

1. Ejecutar Layer C+ SBVR sobre 244 reglas — detectar UNLOAD/archivos planos CNBV
2. Consultar SME Industry Banking Accounting: catálogo mínimo y formatos Serie R
3. Identificar ventanas de entrega CNBV y mapear a SLO target
4. Crear `05-risks.md` con riesgo de compliance regulatorio

---

*Actualizado 2026-08-12 — DISCOVER Etapa 1 · Brain-First characterization*