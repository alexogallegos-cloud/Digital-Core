# D14 · Banca Electrónica Institucional (BEI) — Matriz SP × Tabla

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 2 — Schema Extraction
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- DBA — IBM Informix IDS (tablas reales desde `syscolumns` — Etapa 2) ← FUENTE DE VERDAD
- Specialist — Informix SPL Analysis (extracción de tablas desde código SPL)
- Core Banking Transformation (diseño de ownership de tablas en target microservicios)

> **ESTADO:** Matriz parcial basada en análisis estático de los 42 SPs del callgraph. Los 294 SPs aislados no están incluidos. Se requiere análisis completo de código fuente en Etapa 2.
---

## Leyenda

| Símbolo | Significado |
|---------|------------|
| `R` | SELECT (Read) |
| `W` | INSERT / UPDATE (Write) |
| `D` | DELETE |
| `RW` | Read + Write |
| `RWD` | Read + Write + Delete |
| `X` | Cross-DB (tabla en otro dominio) |

## SPs verificados en detalle (sp-specs-bdibei.md)

### `getrandomcode`

| Tabla | BD | Cross-DB | Operación | Línea | Notas |
|-------|-----|---------|-----------|-------|-------|
| `systables` | `bdibei` | no | `R` | L43 | Solo para entropía — conteo de filas |

**Clasificación:** SP de utilidad de seguridad. No accede a tablas de negocio BEI.

---

### `desbloque`

| Tabla | BD | Cross-DB | Operación | Notas |
|-------|-----|---------|-----------|-------|
| `[DATO-REQUERIDO]` | — | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | SP de 9 LOC — análisis de código completo pendiente |

---

## SPs del callgraph — tablas por inferencia de nomenclatura

> Las siguientes tablas se infieren del análisis de nombres de SPs y vocabulario del dominio BEI. Requieren verificación con DBA en Etapa 2.

| SP (inferido) | Tabla accedida (inferida) | BD | Operación | Evidencia |
|--------------|--------------------------|-----|-----------|----------|
| `sp_bei_alta_convenio` | `bei_convenios` | bdibei | `W` | Patrón alta_convenio |
| `sp_bei_valida_convenio` | `bei_convenios` | bdibei | `R` | Patrón valida_ |
| `sp_bei_carga_nomina` | `bei_archivos_nomina` · `bei_beneficiarios` | bdibei | `W` | Patrón carga_nomina |
| `sp_bei_dispersa` | `bei_dispersiones` · `bei_dispersiones_det` | bdibei | `RW` | Patrón dispersa_ |
| `sp_bei_confirma_dispersion` | `bei_dispersiones` | bdibei | `W` | Patrón confirma_ |
| `sp_bei_reverso` | `bei_dispersiones` · `bei_dispersiones_det` | bdibei | `RW` | Patrón reverso_ |
| `sp_bei_consulta_dispersion` | `bei_dispersiones` · `bei_dispersiones_det` | bdibei | `R` | Patrón consulta_ |
| `sp_bei_calcula_comision` | `bei_comisiones` · `bei_convenios` | bdibei | `RW` | Patrón calcula_comision |
| `sp_bei_genera_reporte` | `bei_dispersiones` · `bei_dispersiones_det` | bdibei | `R` | Patrón genera_reporte |
| `sp_bei_alta_beneficiario` | `bei_beneficiarios` | bdibei | `W` | Patrón alta_beneficiario |
| `sp_bei_baja_beneficiario` | `bei_beneficiarios` | bdibei | `W` | Patrón baja_beneficiario |

## Cross-DB calls esperadas desde bdibei

| SP origen (bdibei) | Tabla / SP destino | Dominio destino | Operación | Criticidad |
|-------------------|-------------------|-----------------|-----------|-----------|
| SP batch nómina | `[DATO-REQUERIDO]` | `bdispei` (D08) | `EXECUTE PROCEDURE` | CRÍTICA |
| SP validación empresa | `[DATO-REQUERIDO]` | `bdicred` (D03) | `R` | ALTA |
| SP autenticación empresa | `si_feriado` o equiv. | `bdinteg` | `R` | MEDIA |
| SP registro contable | `[DATO-REQUERIDO]` | `bdicont` (D12) | `W` | ALTA |
| SP cargo cuenta origen | `[DATO-REQUERIDO]` | `bdisac` (D05) | `W` | ALTA |

## Tablas con mayor exposición (estimación)

Basado en el modelo de negocio BEI, las siguientes tablas se estima que son accedidas por el mayor número de SPs:

| Tabla | # SPs estimados | Tipo de acceso | Criticidad migración |
|-------|---------------|----------------|---------------------|
| `bei_dispersiones` | ~15 SPs | RWD | CRÍTICA — tabla transaccional principal |
| `bei_convenios` | ~10 SPs | RW | ALTA — maestra de empresas |
| `bei_beneficiarios` | ~8 SPs | RW | ALTA — PII (ver `18-pii-security-assessment.md`) |
| `bei_dispersiones_det` | ~8 SPs | RW | CRÍTICA — detalle por beneficiario |
| `bei_param` | ~20 SPs | R | MEDIA — parámetros del sistema |
| `bei_bitacora` | ~15 SPs | W | ALTA — auditoría CNBV |
| `bei_comisiones` | ~5 SPs | RW | MEDIA — comisiones por dispersión |

> **`[DATO-REQUERIDO]`** DBA IBM Informix — ejecutar para obtener la matriz real:
>
> ```sql
> -- Requiere acceso a tablas de estadísticas o análisis de código
> -- No hay equivalente directo en Informix para obtener SP-tabla matrix
> -- El DBA debe analizar el código fuente de cada SP y extraer las referencias
> ```

## Implicaciones para el diseño del target (microservicios)

La matriz SP × Tabla define el ownership de cada tabla en los microservicios target. El principio es **database-per-service**: cada microservicio es el único que puede escribir en sus tablas.

| Tabla BEI | Microservicio owner en target | Otros servicios que leen |
|-----------|-------------------------------|--------------------------|
| `bei_convenios` | `ConvenioEmpresaService` | `DispersionService` (R) |
| `bei_beneficiarios` | `BeneficiariosService` | `DispersionService` (R) |
| `bei_dispersiones` | `DispersionService` | `ReporteService` (R) · `ReconciliacionService` (R) |
| `bei_dispersiones_det` | `DispersionService` | `ReporteService` (R) |
| `bei_comisiones` | `ComisionService` | `ReporteService` (R) |
| `bei_param` | `ConfigService` | Todos los servicios (R) |
| `bei_bitacora` | `AuditService` | Solo auditoría (R) |
| `bei_tokens_empresa` | `AuthEmpresaService` | — |

---
*Generado por: Specialist — Informix SPL Analysis · 2026-08-03 · Fuente: sp-specs-bdibei.md (2 SPs verificados en detalle) + análisis de nomenclatura dominio BEI. Matriz completa PENDIENTE análisis de código Etapa 2.*
