# D12 · Contabilidad — Catálogo de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de código)
- Domain Expert — BanCoppel (validación funcional y de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- Risk Officer — Modernización (clasificación regulatoria CNBV)

> Toda sección marcada `[SME-PENDING]` requiere sesión de validación con el Domain Expert de BanCoppel antes de pasar a Etapa 2.
---


## Descripción

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 168 archivos SQL del dominio `bdicont`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 125 | 74% |
| Actualización | 13 | 7% |
| Validación | 9 | 5% |
| Borrado / Cancelación | 6 | 3% |
| Reporte / Cálculo | 5 | 2% |
| Consulta / Lectura | 5 | 2% |
| Inserción / Alta | 4 | 2% |
| Transacción financiera | 1 | 0% |

## Tablas propias del dominio `bdicont`

Tablas accedidas exclusivamente dentro de `bdicont` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `1` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `11` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `13` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `5` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `7` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `9` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `FROM` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `STATISTICS` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `WCOD_RET` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `auxiliar_cta` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `auxmoneda` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `baccmayor` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `balan` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicont` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinteg` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bpempresa` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bpsaldo_anterior` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bpsaldo_dia_anterior` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `c_cargos_dia` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `c_empresa` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `c_promedio_anual` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `catccmayor` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `ccosto_institucional` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_auditerr` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_auditpase` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_auxiliar` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_balanza` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_balprev` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_cance` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_canret` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_celdas` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_cierre_cif` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_clv_pasesuc` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_contab` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_contproc` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_contproc_inicializa` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_cta_ccdest` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_cta_ccorig` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_ctasob` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `co_ctrlpoliza` | `bdicont` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdicont` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `si_catalog` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `si_divisas` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `si_ejecut` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `si_fechas` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `si_histdiv` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `si_param` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `si_plazas` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `si_regional` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `si_sucursales` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `si_tpcambio` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `sp_preciocontable` | `bdirepaut` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `sx_contproc` | `bdinteg` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |
| `systabnames` | `sysmaster` | Referencia cross-DB | Lectura | `bdicont` accede vía `CALL db:sp()` |

> **[SME-PENDING]** Validar ownership y acuerdos de acceso entre dominios. En el target, cada acceso cross-DB se convierte en llamada API o evento — requiere contrato de interfaz.

## Entidades de datos candidatas (modelado target)

Basado en el análisis de nombres de tablas, las siguientes **entidades de negocio** son candidatas para el modelo de datos target:

```
[SME-PENDING] Completar con Domain Expert:
- ¿Qué entidades son maestros (catálogos)?
- ¿Qué entidades son transaccionales?
- ¿Qué entidades son temporales / de staging?
- ¿Qué datos deben migrarse en la fase de cutover?
- ¿Qué datos históricos requieren archivado?
```

## Flujo de datos entre dominios

```
[SME-PENDING] Diagrama de flujo de datos:
bdicont ←→ [dominio] : [entidad compartida]
bdicont ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdicont:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicont_*.sql*
