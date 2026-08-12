# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Procesos Batch

> **Componente:** BCOPCore · SPE-AM-001 · BUILD/OPERATE Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Perfil de procesos batch de bdilide

El dominio `bdilide` es predominantemente batch. De los 101 SPs, la mayoría corresponde a procesos que se ejecutan fuera del flujo transaccional en línea. Esto contrasta con otros dominios de BCOPCore que son mayoritariamente servicios transaccionales. El motor PLD funciona como un sistema de análisis diferido que procesa los movimientos del día durante la noche.

## Inventario de procesos batch identificados

### BATCH-D15-01: Ejecutor Diario PLD

| Atributo | Valor |
|----------|-------|
| SP principal | `ejecutor_diario` |
| Frecuencia | Diaria — fin del día hábil |
| Ventana estimada | 22:00 – 02:00 CDMX (estimado; `[DATO-REQUERIDO]`) |
| Duración estimada | `[DATO-REQUERIDO]` — solicitar al DBA métricas históricas |
| Parámetros | `pFechaProceso DATE`, `pCve_Usuario CHAR(8)` |
| Dominios impactados | bdilide, bdinteg, bdicheq, bdicred |
| Criticidad | 🔴 CRÍTICO — coordinación cross-dominio |
| Regulatorio | Sí — la sincronización de fechas afecta los períodos de reporte |

**Descripción:** orquesta la actualización de las fechas de proceso en todos los dominios y registra los movimientos del día. Es la puerta de entrada del proceso PLD diario.

**Riesgo operacional:** si falla a mitad, las fechas quedan inconsistentes entre `bdilide`, `bdinteg`, `bdicheq` y `bdicred`. Requiere mecanismo de compensación o checkpoint para reanudación parcial.

### BATCH-D15-02: Acumulación de Operaciones PLD

| Atributo | Valor |
|----------|-------|
| SP principal | `sp_acumulacionoperaciones` |
| Frecuencia | Diaria — después de BATCH-D15-01 |
| Ventana estimada | 23:00 – 04:00 CDMX (estimado) |
| Duración estimada | `[DATO-REQUERIDO]` — depende del volumen de clientes |
| Parámetros | `pEmpresa CHAR(3)`, `pFechaProceso DATE`, `pCve_Usuario CHAR(8)`, `pFechaultimodia DATE` |
| Dominios impactados | bdilide, bdinteg |
| Criticidad | 🔴 CRÍTICO — genera los datos base para reportes regulatorios |
| Regulatorio | Sí — LFPIORPI / CNBV / SHCP |

**Descripción:** analiza los movimientos del día contra los umbrales PLD, acumula los montos por cliente y período, y genera los registros de retención IDE. Es el núcleo del motor PLD.

**Consideración de escalabilidad:** con ~3 millones de clientes BanCoppel, este batch puede ser significativamente largo. `[DATO-REQUERIDO]` — confirmar el volumen real con DBA.

### BATCH-D15-03: Generación de Informe SAT

| Atributo | Valor |
|----------|-------|
| SP principal | `sp_cargainformesat` → `sp_validaarchivoinforme` |
| Frecuencia | Mensual (o bajo demanda regulatoria) |
| Ventana | Primeros días hábiles del mes siguiente al período |
| Parámetros | Sin parámetros de entrada (toma fecha de `sc_fechas`) |
| Dominios impactados | bdilide, bdicheq (sc_fechas) |
| Criticidad | 🔴 CRÍTICO — reporte regulatorio obligatorio |
| Regulatorio | Sí — SAT (intercambio de información IDE/exentos) |

**Descripción:** genera el archivo de consulta al SAT con el listado de clientes para verificación de exención IDE. El archivo se construye en el sistema de archivos AIX mediante comandos `sed` y se envía al SAT.

**Riesgo de migración:** el uso de comandos shell del SO (AIX) para manipular el archivo es el principal riesgo. En el target AWS, este proceso debe reimplementarse como Lambda o ECS Task que genera el archivo directamente y lo deposita en S3 para envío.

### BATCH-D15-04: Procesamiento de Resultado SAT

| Atributo | Valor |
|----------|-------|
| SP principal | `sp_cargaresultadosat` → `sp_validaarchivoresultado` |
| Frecuencia | Después de recibir respuesta del SAT (días después del BATCH-D15-03) |
| Parámetros | Sin parámetros de entrada |
| Dominios impactados | bdilide, bdicheq (sc_fechas) |
| Criticidad | 🔴 CRÍTICO — actualiza el estado de exención de clientes |
| Regulatorio | Sí — SAT |

**Descripción:** procesa la respuesta del SAT para actualizar la lista de clientes exentos del IDE en `sl_exentos`. Este proceso alimenta directamente la acumulación del siguiente período.

### BATCH-D15-05: Reportes Regulatorios CNBV/SHCP

| Atributo | Valor |
|----------|-------|
| SPs | `[DATO-REQUERIDO]` — identificar en los 96 SPs aislados |
| Frecuencia | Mensual (operaciones relevantes) / Inmediato (inusuales) |
| Criticidad | 🔴 CRÍTICO — obligación regulatoria con plazo |
| Regulatorio | LFPIORPI Art. 17-27, CUB Título XIV |

**Descripción:** `[DATO-REQUERIDO]` — identificar los SPs específicos que generan los reportes de operaciones relevantes, inusuales y preocupantes para CNBV/UIF y SHCP.

## Orden de ejecución batch diario (propuesto)

```
22:00 CDMX — BATCH-D15-01 (ejecutor_diario)
                   │
                   ▼
23:00 CDMX — BATCH-D15-02 (acumulacion_operaciones)
                   │
                   ▼
Fin del batch: registros listos para reportes mensuales
```

> `[DATO-REQUERIDO]` — Confirmar el orden real con DBA IBM Informix mediante análisis de la tabla `sl_procesos` y la secuencia de `INSERT` en producción.

## Equivalente target en AWS

| Batch legacy | Equivalente AWS recomendado | Justificación |
|-------------|----------------------------|--------------|
| `ejecutor_diario` (cron AIX) | EventBridge Scheduled Rule → Lambda | Sin estado, < 15 minutos de ejecución estimada |
| `sp_acumulacionoperaciones` (masivo, >15 min) | EventBridge → ECS Fargate Task | Puede exceder el límite de Lambda; necesita timeout largo |
| `sp_cargainformesat` (comandos shell) | Step Functions + Lambda (procesamiento de archivos) → S3 | Reemplaza la lógica shell AIX |
| Reportes regulatorios CNBV/SHCP | ECS Fargate Task + SES/S3 para envío | Generación de archivos grandes |

## `[SME-PENDING]`

- [ ] DBA IBM Informix: extraer de `sl_procesos` la secuencia real de ejecución de los últimos 3 meses.
- [ ] Confirmar la duración histórica de cada batch para dimensionar el timeout en AWS.
- [ ] Identificar si hay dependencias de hora fija (p. ej., el proceso debe terminar antes de las 06:00 CDMX).
- [ ] Documentar el mecanismo de reintento actual si un batch falla a mitad.
- [ ] Identificar los SPs de reportes CNBV/SHCP entre los 96 aislados.

---
*Generado: análisis estático bdilide · 2026-08-03*
