# D14 · Banca Electrónica Institucional (BEI) — Modelo Entidad-Relación

> **Componente:** Informix · SPE-AM-001 · Etapa 2 — Schema Extraction
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- DBA — IBM Informix IDS (schema real vía `syscolumns` y `sysreferences` — Etapa 2) ← FUENTE DE VERDAD
- Specialist — Informix SPL Analysis (relaciones inferidas de código SPL)
- Data Architect — target PostgreSQL / Aurora (modelado target)
- Industry Banking (validación funcional del modelo de datos BEI)

> **ESTADO:** Modelo ER inferido del análisis estático del código SPL y convenciones de nomenclatura del dominio BEI. El modelo definitivo requiere ejecución de consultas en `syscolumns` y `sysreferences` en producción Informix (Etapa 2 — DBA).
---

## Nota metodológica

IBM Informix IDS no exige declaración de foreign keys en el esquema — el dominio BanCoppel BEI probablemente mantiene la integridad referencial vía código SPL (validaciones en los SPs) en lugar de constraints del motor. El modelo ER real puede tener las relaciones sin FK explícitas en el catálogo.

**Consulta DBA requerida:**
```sql
-- Tablas reales del dominio
SELECT tabname, tabtype, nrows FROM systables
WHERE owner = 'informix' AND tabname LIKE 'bei%'
ORDER BY tabname;

-- Columnas y tipos
SELECT tabname, colname, coltype, collength, colno
FROM syscolumns c JOIN systables t ON c.tabid = t.tabid
WHERE t.owner = 'informix' AND t.tabname LIKE 'bei%'
ORDER BY tabname, colno;

-- Restricciones / claves primarias
SELECT c.constrname, c.constrtype, t.tabname
FROM sysconstraints c JOIN systables t ON c.tabid = t.tabid
WHERE t.tabname LIKE 'bei%';
```

---

## Modelo ER inferido — Diagrama conceptual

```
┌──────────────────┐         ┌──────────────────────────┐
│   bei_empresa    │────1:N──▶│     bei_convenios        │
│──────────────────│         │──────────────────────────│
│ PK cve_empresa   │         │ PK num_convenio          │
│ rfc_empresa (PII)│         │ FK cve_empresa           │
│ razon_social(PII)│         │ monto_max_dispersion     │
│ ind_activo       │         │ monto_max_mensual        │
└──────────────────┘         │ cuenta_cargo             │
                             │ ind_activo               │
                             │ horario_max_dispersion   │
                             └────────────┬─────────────┘
                                          │ 1:N
                    ┌─────────────────────┼──────────────────────┐
                    │                     │                      │
                    ▼                     ▼                      ▼
       ┌────────────────────┐  ┌────────────────────┐  ┌──────────────────┐
       │  bei_beneficiarios │  │  bei_dispersiones  │  │  bei_comisiones  │
       │────────────────────│  │────────────────────│  │──────────────────│
       │ PK num_beneficiario│  │ PK SERIAL folio    │  │ PK num_comision  │
       │ FK num_convenio    │  │ FK num_convenio    │  │ FK num_convenio  │
       │ curp (PII)         │  │ fecha_dispersion   │  │ periodo_mes      │
       │ nombre (PII)       │  │ tipo_dispersion    │  │ total_comision   │
       │ num_cuenta_destino │  │ total_registros    │  │ iva_comision     │
       │   (PII financiero) │  │ total_importe      │  │ cod_estatus      │
       │ banco_destino      │  │ monto_dispersion   │  └──────────────────┘
       │ monto_dispersion   │  │ cod_estatus        │
       │ ind_activo         │  │ cod_error          │
       └────────────────────┘  │ fecha_procesamiento│
                               │ num_folio_spei     │
                               └────────┬───────────┘
                                        │ 1:N
                               ┌────────▼───────────────┐
                               │  bei_dispersiones_det  │
                               │────────────────────────│
                               │ PK id_detalle          │
                               │ FK folio (bei_dispers) │
                               │ FK num_beneficiario    │
                               │ monto_dispersado       │
                               │ cod_estatus_det        │
                               │ num_folio_spei_det     │
                               │ mensaje_error          │
                               └────────────────────────┘

Entidades auxiliares:
┌──────────────────┐  ┌────────────────────────┐  ┌──────────────────────┐
│    bei_param     │  │    bei_archivos_nomina  │  │   bei_tokens_empresa │
│──────────────────│  │────────────────────────│  │──────────────────────│
│ clave_param      │  │ FK num_convenio         │  │ FK cve_empresa       │
│ valor_param      │  │ nombre_archivo          │  │ cod_token            │
│ descripcion      │  │ fecha_carga             │  │ fecha_expiracion     │
│                  │  │ cod_estatus_proceso     │  │ ind_usado            │
└──────────────────┘  └────────────────────────┘  └──────────────────────┘

┌──────────────────────────────────────────────────────┐
│                    bei_bitacora                       │
│──────────────────────────────────────────────────────│
│ PK id_bitacora (SERIAL)                              │
│ fecha_hora (DATETIME YEAR TO FRACTION)               │
│ cve_empresa o num_convenio (ref al evento)           │
│ tipo_operacion                                       │
│ usuario_sistema                                      │
│ ip_origen (anonimizado en target)                    │
│ resultado                                            │
│ descripcion                                          │
└──────────────────────────────────────────────────────┘
```

---

## Cardinalidades inferidas

| Relación | Cardinalidad | Tipo | Notas |
|----------|-------------|------|-------|
| bei_empresa → bei_convenios | 1:N | Padre-hijo | Una empresa puede tener varios convenios (nómina, proveedores, etc.) |
| bei_convenios → bei_beneficiarios | 1:N | Padre-hijo | Los beneficiarios pertenecen al convenio de nómina |
| bei_convenios → bei_dispersiones | 1:N | Padre-hijo | Múltiples dispersiones históricas por convenio |
| bei_dispersiones → bei_dispersiones_det | 1:N | Padre-hijo | Un registro por beneficiario por dispersión |
| bei_convenios → bei_comisiones | 1:N | Padre-hijo | Comisión mensual por convenio |
| bei_dispersiones_det → bei_beneficiarios | N:1 | FK inversa | Cada línea de detalle referencia al beneficiario |

---

## Diferencias esperadas Informix → PostgreSQL en el modelo ER

| Concepto Informix | Equivalente PostgreSQL | Riesgo |
|------------------|----------------------|--------|
| `SERIAL` como PK | `BIGSERIAL` / `UUID` | ALTO — seeds deben preservarse para datos históricos |
| Sin FK explícitas | FK reales en PostgreSQL | ALTO — pueden haber datos huérfanos no detectados por falta de FK en Informix |
| `MONEY(18,2)` | `NUMERIC(18,2)` | MEDIO — equivalencia exacta garantizada con escala fija |
| `DATETIME YEAR TO FRACTION` | `TIMESTAMP(5)` | BAJO — ajuste de precisión |
| Cross-DB join directo | API call o schema federado | CRÍTICO — las relaciones cross-DB deben convertirse en joins inter-servicio |

---

## Riesgo de datos huérfanos

Dado que Informix no tiene FK declaradas, es posible que existan:
- Registros en `bei_dispersiones_det` sin registro padre en `bei_dispersiones` (folios eliminados manualmente).
- Beneficiarios en `bei_beneficiarios` con `num_convenio` que ya no existe en `bei_convenios`.

**Acción antes de migración de datos:** ejecutar queries de auditoría de integridad referencial antes del bulk load en PostgreSQL:

```sql
-- Ejemplo: huérfanos en bei_dispersiones_det
SELECT d.id_detalle
FROM bei_dispersiones_det d
LEFT JOIN bei_dispersiones e ON d.folio = e.folio
WHERE e.folio IS NULL;
```

---
*Generado por: Specialist — Informix SPL Analysis + Data Architect · 2026-08-03 · Fuente: análisis estático sp-specs-bdibei.md + convenciones dominio BEI. PENDIENTE: validación DBA con syscolumns + sysreferences Etapa 2.*
