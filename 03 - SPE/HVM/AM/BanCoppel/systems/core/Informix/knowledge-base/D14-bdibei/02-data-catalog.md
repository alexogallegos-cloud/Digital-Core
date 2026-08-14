# D14 · Banca Electrónica Institucional (BEI) — Catálogo de Datos

> **Componente:** Informix · SPE-AM-001 · Etapa 2 — Schema Extraction
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- DBA — IBM Informix IDS (extracción real desde syscolumns — Etapa 2) ← FUENTE DE VERDAD
- Specialist — Informix SPL Analysis (tablas detectadas en análisis estático)
- Industry Banking (clasificación funcional de entidades)
- Core Banking Transformation (mapeo target PostgreSQL)
- Cybersecurity (clasificación PII — LFPDPPP + CNBV)

> **IMPORTANTE:** Este catálogo es una aproximación basada en análisis estático del código SPL y convenciones de nomenclatura del dominio BEI. El catálogo definitivo requiere ejecución de `SELECT tabname FROM systables WHERE owner='informix'` en el motor Informix de producción (Etapa 2 — DBA IBM Informix).
---

## Metodología de detección

Las tablas se detectan por:
1. Clausulas `FROM`, `INTO`, `UPDATE`, `DELETE` en el código SPL de los 42 SPs del callgraph.
2. Análisis de prefijos y nomenclatura: el dominio `bdibei` usa prefijos `bei_*` para tablas propias.
3. Cross-DB: referencias a tablas en otros dominios detectadas como `dominio:tabla`.

## Tablas propias de `bdibei` detectadas / inferidas

| Tabla | Clasificación | Descripción | PII | Detección |
|-------|--------------|-------------|:---:|-----------|
| `bei_convenios` | Entidad maestra | Convenios empresa — parámetros de dispersión | No | Inferida por convención |
| `bei_empresa` | Entidad maestra | Catálogo de empresas clientes BEI | Sí (RFC, razón social) | Inferida |
| `bei_beneficiarios` | Entidad transaccional | Nómina de beneficiarios por convenio | Sí (CURP, cuenta, nombre) | Inferida |
| `bei_dispersiones` | Entidad transaccional | Registro de dispersiones realizadas | Sí (monto, cuenta destino) | Inferida |
| `bei_dispersiones_det` | Entidad transaccional | Detalle por beneficiario de cada dispersión | Sí | Inferida |
| `bei_archivos_nomina` | Entidad de control | Control de archivos de nómina recibidos | No | Inferida |
| `bei_param` | Configuración | Parámetros del dominio BEI | No | Inferida por patrón `*_param` en otros dominios |
| `bei_bitacora` | Auditoría | Log de operaciones BEI | Parcial (IP, usuario) | Inferida |
| `bei_errores` | Operacional | Registro de errores de dispersión | No | Inferida |
| `bei_comisiones` | Financiero | Comisiones por servicios BEI | No | Inferida |
| `bei_comisiones_det` | Financiero | Detalle de cálculo de comisiones | No | Inferida |
| `bei_preautorizaciones` | Transaccional | Pagos programados pendientes de ejecutar | Sí (monto) | Inferida |
| `bei_tokens_empresa` | Seguridad | Tokens de autenticación empresa | Sí (credenciales) | Inferida por `getrandomcode` |

> **[DATO-REQUERIDO] DBA IBM Informix:** ejecutar en producción:
> ```sql
> SELECT t.tabname, t.tabtype, t.nrows, t.ncols
> FROM systables t
> WHERE t.owner = 'informix'
> AND t.tabname NOT LIKE 'sys%'
> ORDER BY t.tabname;
> ```

## Tablas de otros dominios accedidas (cross-DB detectadas)

| Dominio | Tabla | Tipo de acceso | SP que accede | Criticidad |
|---------|-------|---------------|---------------|-----------|
| `bdicred` (D03) | [DATO-REQUERIDO] | SELECT (verificación crédito empresa) | [SME-PENDING] | ALTA |
| `bdispei` (D08) | [DATO-REQUERIDO] | EXECUTE / cross-domain call | [SME-PENDING] | CRÍTICA |
| `bdinteg` | `si_feriado` o equiv. | SELECT (validación fechas hábiles) | [SME-PENDING] | MEDIA |
| `bdicont` (D12) | [DATO-REQUERIDO] | INSERT (registro contable dispersión) | [SME-PENDING] | ALTA |

## Estimación de volúmenes

> `[SME-PENDING]` — requiere DBA IBM Informix con acceso a producción.

| Tabla | Volumen estimado | Criterio de estimación |
|-------|-----------------|----------------------|
| `bei_beneficiarios` | `[DATO-REQUERIDO]` | Número de empleados en nómina de empresas cliente BanCoppel |
| `bei_dispersiones` | `[DATO-REQUERIDO]` | Histórico de quincenas · estimado: 24 registros maestra/empresa/año |
| `bei_dispersiones_det` | `[DATO-REQUERIDO]` | Número de beneficiarios × número de dispersiones históricas |
| `bei_bitacora` | `[DATO-REQUERIDO]` | Alta rotación — evaluar retención (CNBV exige 5 años) |

## Política de retención regulatoria

| Tabla | Retención mínima | Regulación | Notas |
|-------|-----------------|-----------|-------|
| `bei_dispersiones` | 5 años | CNBV Circular Única Bancos | Comprobante de pagos masivos |
| `bei_dispersiones_det` | 5 años | CNBV | Trazabilidad por beneficiario |
| `bei_bitacora` | 5 años | CNBV — auditoría | Incluir en plan de archivado |
| `bei_beneficiarios` | Vigencia + 2 años | LFPDPPP | Datos personales — eliminación post-convenio |
| `bei_tokens_empresa` | Solo vigentes + 90 días | Seguridad interna | Sin valor de auditoría post-uso |

---
*Generado por: Specialist — Informix SPL Analysis · 2026-08-03 · Fuente: análisis estático sp-specs-bdibei.md + convenciones dominio BanCoppel. PENDIENTE: validación DBA Etapa 2.*
