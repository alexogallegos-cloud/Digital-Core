# D13 · Transferencias Electrónicas de Fondos (TEF) — Plan de Migración de Datos

> **Componente:** Informix · SPE-AM-001 · Etapa 4 — Design
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — DBA IBM Informix (extracción y transformación de datos legacy)
- Data Architect (diseño del pipeline de migración)
- SME — Core Banking Transformation (restricciones operativas de cutover)
- SME Regulatorio — CNBV (retención de datos históricos)

---

## Principios de migración de datos

1. **Cero pérdida de datos transaccionales:** Todas las operaciones TEF de los últimos 5 años deben estar disponibles en el target (requisito CNBV Circular Única de Bancos).
2. **Datos maestros migran primero:** `cce_param`, `cce_usuarios_aut`, catálogo de bancos CECOBAN y `si_feriado` deben estar en Aurora antes del primer día de operación del target.
3. **Transformación limpia:** Conversión explícita de tipos (especialmente `money` → `numeric(16,2)` y `char` → `varchar` con TRIM).
4. **Validación de integridad:** Conteo de registros y checksum de montos antes de confirmar la migración.
5. **Periodo de convivencia:** Informix y Aurora operan en paralelo durante `[DATO-REQUERIDO]` días.

---

## Clasificación de tablas por estrategia de migración

### Categoría A — Datos maestros (migrar antes del cutover)

| Tabla | Estrategia | Frecuencia de sincronización | Propietario |
|-------|-----------|------------------------------|-------------|
| `cce_param` | Migración directa one-shot | Una vez (pre-cutover) | DBA IBM Informix |
| `cce_usuarios_aut` | Migración directa one-shot | Una vez (pre-cutover) + delta | DBA IBM Informix |
| `cce_cedula_usr` | Migración directa one-shot | Una vez (pre-cutover) | DBA IBM Informix |
| `bdinteg:si_feriado` | Migración directa one-shot | Anual (actualización de calendario) | MasterDataService |
| Catálogo de bancos CECOBAN | `[DATO-REQUERIDO]` | Una vez + actualización CECOBAN | SME CNBV |

### Categoría B — Datos históricos (migrar antes del cutover, sin sync)

| Tabla | Criterio de corte | Volumen estimado | Retención mínima |
|-------|-----------------|-----------------|-----------------|
| `tef_operaciones` (históricas) | Operaciones > `[DATO-REQUERIDO]` días anteriores | `[DATO-REQUERIDO]` | 5 años — CNBV |
| `tef_bitacora` (histórica) | Bitácora > `[DATO-REQUERIDO]` días anteriores | `[DATO-REQUERIDO]` | 5 años — CNBV |
| `tef_archivos` (procesados) | Archivos procesados y cerrados | `[DATO-REQUERIDO]` | 3 años mínimo |
| `cce_cheques_dev` (histórico) | Cheques devueltos > `[DATO-REQUERIDO]` días | `[DATO-REQUERIDO]` | `[SME-PENDING]` |

### Categoría C — Datos operativos activos (migrar en cutover con window mínimo)

| Tabla | Descripción | Ventana de migración |
|-------|-------------|---------------------|
| `tef_operaciones` (activas) | Operaciones pendientes de CECOBAN | Ventana de corte CECOBAN |
| `tef_detalle` (activos) | Registros de archivos en proceso | Simultáneo con `tef_operaciones` |
| `tef_archivos` (en proceso) | Archivos no cerrados | Simultáneo con `tef_operaciones` |

---

## Pipeline de migración

### Fase 1 — Extracción (Informix → staging)

```
Informix bditef (POWER-AIX)
  └── Sqoop / IBM DataStage / script ETL personalizado
        └── S3 Staging (encrypted, región us-east-1)
              ├── tef_operaciones.parquet
              ├── tef_bitacora.parquet
              ├── cce_param.csv
              └── [otras tablas].parquet
```

**Herramienta de extracción:** `[SME-PENDING]` — confirmar con DBA IBM Informix si se usa UNLOAD nativo de Informix o herramienta ETL existente.

### Fase 2 — Transformación

| Transformación | Descripción |
|---------------|-------------|
| `char` → `varchar` | TRIM() en todas las columnas `char(n)` |
| `money` → `numeric(16,2)` | Conversión explícita con precisión verificada |
| Fechas `%m/%d/%Y` → ISO 8601 | Conversión de formato americano a estándar |
| Folios `char(16)` → `varchar(36)` | Los folios legacy se conservan; nuevos folios serán UUID |
| Códigos de retorno | Mapeo de `char(5)` → columna `estado` del target |

### Fase 3 — Carga (staging → Aurora PostgreSQL)

```
S3 Staging
  └── AWS DMS (Data Migration Service) o pg_restore
        └── Aurora PostgreSQL bditef_target
              ├── Carga datos maestros (Categoría A)
              ├── Carga históricos (Categoría B)
              └── [Cutover] Carga operativos activos (Categoría C)
```

---

## Validación de integridad post-migración

| Validación | Criterio de aceptación |
|-----------|----------------------|
| Conteo de filas por tabla | Target count = Informix count ± 0 |
| Suma de importes en `tef_operaciones` | Target sum = Informix sum (tolerancia cero) |
| Suma de importes en `tef_bitacora` | Target sum = Informix sum (tolerancia cero) |
| Verificación de folios únicos | 0 duplicados en `tef_operaciones.folio` |
| Verificación de fechas | 0 fechas inválidas (nulls o fuera de rango) |
| Verificación de `cce_param` | Todos los parámetros activos migrados |

---

## Datos maestros cross-domain

Estas tablas pertenecen a otros dominios pero son necesarias para `bditef`:

| Tabla origen | Dominio | Acción |
|-------------|---------|--------|
| `bdicheq:sc_maechq` | D[X] Cheques | Se migra junto con `bdicheq` en el mismo wave |
| `bdicheq:sc_fechas` | D[X] Cheques | Se migra junto con `bdicheq` |
| `bdinteg:si_feriado` | Integración | Migrar a `MasterDataService` compartido |
| `bdinteg:si_coddevcam` | Integración | Migrar a `MasterDataService` compartido |

---

## `[SME-PENDING]`

- [ ] Confirmar el volumen actual de `tef_operaciones` (registros totales) con el DBA IBM Informix.
- [ ] Definir el criterio de corte entre datos históricos y activos (número de días hacia atrás).
- [ ] Confirmar la herramienta de extracción disponible (UNLOAD nativo, DataStage, AWS DMS con conector Informix).
- [ ] Definir la ventana de migración de datos activos (Categoría C) — debe coincidir con la ventana de corte CECOBAN.
- [ ] Obtener aprobación de CNBV para el plan de retención de 5 años en Aurora (vs. Informix).

---
*Generado por análisis de tablas del dominio + requisitos CNBV de retención + estrategia Wave 3*
