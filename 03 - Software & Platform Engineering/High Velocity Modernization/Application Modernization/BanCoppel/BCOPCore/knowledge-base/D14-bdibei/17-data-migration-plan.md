# D14 · Banca Electrónica Institucional (BEI) — Plan de Migración de Datos

> **Componente:** BCOPCore · SPE-AM-001 · BUILD → RELEASE Phase
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Data & ML — Data Architect (estrategia CDC, ETL, scripts de migración)
- DBA — IBM Informix IDS (extracción de datos, volúmenes reales — Etapa 2)
- Core Banking Transformation (estrategia de coexistencia dual-write)
- Cybersecurity (encriptación de datos PII durante migración)
- QA Lead — Equivalencia Funcional (reconciliación de datos post-migración)
- SRE & AIOps (coordinación del cutover de datos)

> `[SME-PENDING]` = requiere DBA y Data Architect para validar en Etapa 2.
---

## Estrategia de migración seleccionada

**Patrón:** Bulk Load histórico + CDC dual-write durante coexistencia + cutover por capacidad.

```
Fase 1 — BULK LOAD (fuera de línea):
  Exportar tablas históricas de bdibei en Informix
  → Transformar (tipos, encoding, PII tokenization)
  → Cargar en Aurora PostgreSQL (ambiente STG)
  → Verificar integridad referencial + reconciliación de registros

Fase 2 — DUAL-WRITE (coexistencia):
  Nuevas operaciones → escriben en Informix legacy AND Aurora target
  → CDC con Debezium captura deltas de Informix → aplica en Aurora
  → Comparator verifica consistencia diariamente

Fase 3 — CUTOVER:
  Momento cero: nueva escritura solo en Aurora (Informix legacy = read-only)
  → Verificar que todos los pending de Debezium se aplicaron
  → Failback plan listo si se detecta divergencia

Fase 4 — DECOMMISSION:
  Informix legacy permanece read-only ≥ 6 meses post-cutover
  → Cierre de auditoría CNBV
  → Apagado del dominio en Informix
```

---

## Tablas a migrar y estrategia por tabla

| Tabla | Volumen estimado | Estrategia | PII | Riesgo |
|-------|-----------------|-----------|:---:|--------|
| `bei_convenios` | `[DATO-REQUERIDO]` — bajo (cientos de empresas) | Bulk load completo | Sí (RFC, razón social) | MEDIO |
| `bei_beneficiarios` | `[DATO-REQUERIDO]` — alto (decenas de miles) | Bulk load + tokenización PII | Sí (CURP, nombre, CLABE) | ALTO |
| `bei_dispersiones` | `[DATO-REQUERIDO]` — histórico 5+ años | Bulk load histórico + CDC delta | Sí (montos) | ALTO |
| `bei_dispersiones_det` | `[DATO-REQUERIDO]` — muy alto | Bulk load histórico + CDC delta | Sí | ALTO |
| `bei_param` | Pequeño (docenas de filas) | Bulk load + gestión manual | No | BAJO |
| `bei_bitacora` | `[DATO-REQUERIDO]` — muy alto (años de logs) | Bulk load histórico + archivo S3 para pre-migración | Parcial | ALTO |
| `bei_comisiones` | Mediano (años de cálculos) | Bulk load histórico | No | BAJO |
| `bei_archivos_nomina` | Mediano | Bulk load histórico | No | BAJO |
| `bei_tokens_empresa` | Pequeño | No migrar — los tokens activos se invalidan en cutover; empresa genera nuevos | Sí | BAJO |

---

## Restricción crítica — Batch de nómina durante migración

**PROHIBICIÓN ABSOLUTA:** No iniciar el bulk load de `bei_dispersiones` y `bei_dispersiones_det` durante una quincena activa (días 1–3 o 15–18 del mes). El bulk load genera bloqueos de tabla que pueden interferir con el procesamiento del batch.

```
Ventana segura para bulk load: días 5–13 o días 20–28 del mes
Duración estimada bulk load bei_dispersiones_det: [SME-PENDING] — depende del volumen histórico
Buffer mínimo post-bulk-load antes de quincena: 48 horas para reconciliación
```

---

## Preparación pre-migración

### Auditoría de integridad referencial en Informix

Antes de iniciar la migración, ejecutar:

```sql
-- Huérfanos en bei_dispersiones_det
SELECT COUNT(*) AS huerfanos_det
FROM bei_dispersiones_det d
LEFT JOIN bei_dispersiones e ON d.folio = e.folio
WHERE e.folio IS NULL;

-- Beneficiarios con convenio inexistente
SELECT COUNT(*) AS huerfanos_benef
FROM bei_beneficiarios b
LEFT JOIN bei_convenios c ON b.num_convenio = c.num_convenio
WHERE c.num_convenio IS NULL;

-- Dispersiones con convenio inexistente
SELECT COUNT(*) AS huerfanos_disp
FROM bei_dispersiones d
LEFT JOIN bei_convenios c ON d.num_convenio = c.num_convenio
WHERE c.num_convenio IS NULL;
```

Si hay huérfanos, documentarlos como `[DATO-REQUERIDO]` y decidir con Domain Expert si limpiar en Informix o en PostgreSQL.

---

## Scripts de migración (esqueleto)

### Exportación desde Informix

```bash
# Exportar tablas BEI en formato delimitado
dbexport -d bdibei -o /data/export/bdibei/

# Alternativa: UNLOAD TO para tablas críticas
UNLOAD TO '/data/export/bei_beneficiarios.unl'
  SELECT * FROM bei_beneficiarios;
UNLOAD TO '/data/export/bei_dispersiones.unl'
  SELECT * FROM bei_dispersiones
  ORDER BY folio;
```

### Transformación y carga en PostgreSQL

```python
# Pseudocódigo — implementar con dbt o script Python
def migrate_bei_beneficiarios():
    # 1. Leer desde Informix UNLOAD file
    # 2. Tokenizar PII (CURP, nombre, num_cuenta_destino)
    # 3. Convertir MONEY → NUMERIC (verificar escala exacta)
    # 4. Convertir SERIAL seeds
    # 5. Cargar en Aurora con COPY
    # 6. Reconciliar COUNT(*) origen vs destino
```

### Reconciliación post-carga

```sql
-- Verificar que todos los registros fueron migrados
SELECT 'bei_convenios' as tabla,
  (SELECT COUNT(*) FROM informix_staging.bei_convenios) as origen,
  (SELECT COUNT(*) FROM public.bei_convenios) as destino,
  (SELECT COUNT(*) FROM informix_staging.bei_convenios) -
  (SELECT COUNT(*) FROM public.bei_convenios) as diferencia;
```

---

## Configuración CDC con Debezium

```json
{
  "name": "bdibei-cdc-connector",
  "config": {
    "connector.class": "io.debezium.connector.informix.InformixConnector",
    "database.hostname": "[DATO-REQUERIDO: hostname Informix prod]",
    "database.port": "9088",
    "database.user": "cdc_user_bei",
    "database.password": "${CDC_PASSWORD}",
    "database.dbname": "bdibei",
    "table.include.list": "informix.bei_convenios,informix.bei_beneficiarios,informix.bei_dispersiones,informix.bei_dispersiones_det",
    "database.history.kafka.bootstrap.servers": "[DATO-REQUERIDO: MSK brokers]",
    "database.history.kafka.topic": "schema-changes.bdibei",
    "transforms": "route",
    "transforms.route.type": "org.apache.kafka.connect.transforms.ReplaceField$Value"
  }
}
```

> **Nota:** Debezium Informix connector requiere que IBM Informix tenga CDC Log habilitado. `[SME-PENDING]` DBA IBM Informix — verificar si `CDRSERVER` está habilitado en producción.

---

## Plan de reconciliación diaria durante dual-write

Durante el período de coexistencia, ejecutar diariamente:

1. Conteo de registros: `COUNT(*)` por tabla en Informix vs Aurora → diferencia debe ser 0.
2. Hash check de las últimas 24 horas de `bei_dispersiones`: suma de montos y conteo deben coincidir.
3. Verificación de `cod_estatus` en dispersiones del día: no deben existir registros en estados inconsistentes.

---

## Estimación del timeline de migración de datos

| Actividad | Duración estimada | Prerequisito |
|-----------|------------------|-------------|
| Auditoría de integridad referencial | 1 día | DBA Informix con acceso producción |
| Configurar ambiente Aurora STG | 3 días | Cloud Architect AWS |
| Bulk load STG (prueba) | `[SME-PENDING]` — depende de volumen | Ambiente STG listo |
| Reconciliación STG | 2 días | Bulk load completado |
| Configurar Debezium CDC | 3 días | Kafka MSK + CDC habilitado en Informix |
| Prueba dual-write en STG | 5 días (incluye ciclo batch) | Debezium funcionando |
| Bulk load PROD | `[SME-PENDING]` | Ventana fuera de quincena activa |
| Activar CDC en PROD | 1 día | Post bulk load |
| Período dual-write PROD | ≥ 15 días (1 ciclo quincenal completo) | CDC activo |
| Cutover datos | 4 horas (ventana de mantenimiento) | Después del parallel-run verde |

---
*Generado por: Data & ML — Data Architect + Core Banking Transformation · 2026-08-03*
