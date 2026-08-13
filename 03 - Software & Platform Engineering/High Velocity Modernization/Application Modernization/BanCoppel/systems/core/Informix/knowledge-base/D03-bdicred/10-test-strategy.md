# D03 · Créditos — Estrategia de Pruebas de Equivalencia (Golden Master)

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert BanCoppel (validación funcional)
- Cybersecurity (riesgos PII, regulación CNBV/LFPDPPP)
- QA Lead — Equivalencia Funcional (estrategia de pruebas) ← NUEVO
- Cloud Architect AWS Banking (arquitectura target) ← NUEVO
> [SME-PENDING] = requiere sesión de validación antes de Etapa 2.
---

## Objetivo

Demostrar que el `CreditService (Loan Lifecycle Engine)` target produce **resultados idénticos** al SP Informix original bajo todas las condiciones relevantes de producción. Sin esta equivalencia demostrada, el cutover no puede proceder.

## Prioridad — D03 es Wave 4

**Wave 4** — prioridad alta. Es un dominio core que requiere equivalencia perfecta antes de cutover.

## TS-D03-01 · Golden Master del SP más crítico: `sp_actualizastatuscred`

Este SP tiene 13 callers y es el punto de entrada más crítico del dominio.

### Captura del golden master (Informix)

```sql
-- Ejecutar en instancia Informix PRODUCCIÓN durante ventana de observación (7 días):
-- Capturar: parámetros de entrada + código de retorno + estado de tabla destino
SELECT
    proc_name, input_params, output_code, CURRENT AS exec_ts
FROM bdicred:sp_audit_log           -- [SME-PENDING: confirmar tabla de audit]
WHERE fecha_insert >= TODAY - 7
  AND proc_name = 'sp_actualizastatuscred'
ORDER BY exec_ts;
```

### Casos de prueba mínimos requeridos

| ID | Escenario | Parámetros relevantes | Resultado esperado |
|----|-----------|----------------------|-------------------|
| TC-01 | Operación exitosa (happy path) | Datos válidos completos | Código retorno '00000', tablas actualizadas |
| TC-02 | Cliente inexistente | num_cte=99999999 | Código de error controlado |
| TC-03 | Cuenta bloqueada | num_cta en estatus bloqueado | Código error CNBV apropiado |
| TC-04 | Parámetros nulos / vacíos | NULL en campo obligatorio | RAISE EXCEPTION o código error |
| TC-05 | Importe con centavos .005 (MONEY rounding) | importe=100.005 | Verificar round half-even vs half-up |
| TC-06 | Operación duplicada (idempotencia) | Mismo request repetido | Dedup correcto o error controlado |
| TC-07 | Concurrencia — dos llamadas simultáneas | Mismo registro, dos hilos | Sin deadlock; solo una transacción confirma |
| TC-08 | Fechas especiales (domingo, día festivo, fin de mes) | Fecha especial | Comportamiento según reglas de negocio |
| TC-09 | Volumen de carga de producción | Carga real × 100 req/seg | Latencia dentro de SLA target |
| TC-10 | Rollback por error en SP anidado | Error en SP hijo | Estado consistente tras ROLLBACK |

### Criterios de aceptación de equivalencia

- **Código de retorno**: idéntico en el 100% de los casos de prueba
- **Registros en tablas**: mismo número, mismos valores en columnas clave
- **MONEY rounding**: comparación centavo a centavo — cero diferencias aceptadas
- **Latencia p99**: ≤ latencia actual Informix + 20% del SLA del canal
- **Excepciones no manejadas**: 0% de errores no controlados en el target

## TS-D03-02 · Pruebas de procesos batch (ver 11-batch-processes.md)

| ID | Proceso | Criterio de equivalencia |
|----|---------|--------------------------|
| TC-BATCH-01 | SP de purga principal | Mismos registros borrados, mismo número en tabla de control |
| TC-BATCH-02 | SP de generación de reportes | Mismo archivo/dataset de salida byte a byte |
| TC-BATCH-03 | SP de archivado histórico | Mismos registros movidos, integridad referencial mantenida |

## TS-D03-03 · Pruebas de integración cross-domain

Los SPs de `bdicred` hacen llamadas cross-DB a otros dominios. En el target, estas se convierten en llamadas API.

| SP | Dependencia cross-DB | Prueba requerida |
|----|---------------------|-----------------|
| `sp_abona_cheques` | `bdicred` | Simular respuesta API de `bdicred` con mock — verificar contrato |
| `sp_abonoact_credplazos` | `bdinteg` | Simular respuesta API de `bdinteg` con mock — verificar contrato |
| `sp_abonoact_credplazos` | `bdicred` | Simular respuesta API de `bdicred` con mock — verificar contrato |
| `sp_act_historica_cac_aumlincred` | `intercard` | Simular respuesta API de `intercard` con mock — verificar contrato |
| `sp_act_historica_cac_aumlincred` | `bdinteg` | Simular respuesta API de `bdinteg` con mock — verificar contrato |
| `sp_act_historica_cac_aumlincred` | `bdicred` | Simular respuesta API de `bdicred` con mock — verificar contrato |
| `sp_act_retenido` | `bdicred` | Simular respuesta API de `bdicred` con mock — verificar contrato |
| `sp_actestatustarjeta` | `bdicheq` | Simular respuesta API de `bdicheq` con mock — verificar contrato |
| `sp_actestatustarjeta` | `bdinteg` | Simular respuesta API de `bdinteg` con mock — verificar contrato |
| `sp_actestatustarjeta` | `bdicred` | Simular respuesta API de `bdicred` con mock — verificar contrato |
| `sp_actestatustarjeta` | `intercard` | Simular respuesta API de `intercard` con mock — verificar contrato |
| `sp_actestatustarjeta` | `bditransfer` | Simular respuesta API de `bditransfer` con mock — verificar contrato |
| `sp_actestatustarjeta` | `sysmaster` | Simular respuesta API de `sysmaster` con mock — verificar contrato |
| `sp_actestatustarjeta` | `bdisolic` | Simular respuesta API de `bdisolic` con mock — verificar contrato |

## Plan de ejecución de pruebas

```
Semana 1: Captura del golden master en producción (sin cambios)
Semana 2: Configurar ambiente de pruebas paralelo con misma data
Semana 3: Ejecutar TC-01 a TC-10 con datos reales anonimizados (PII masked)
Semana 4: Parallel-run — ambos sistemas reciben mismo tráfico
          → comparar outputs en tiempo real con consumer de Kafka/Kinesis
Semana 5: Sign-off de Domain Expert BanCoppel + QA Lead
Semana 6: Cutover en ventana de mantenimiento nocturna
```

## Riesgo crítico: MONEY rounding (Informix vs PostgreSQL)

`bdicred` contiene operaciones con `MONEY` e `INTEGER`. En el target PostgreSQL:

```
Caso crítico:
  Informix MONEY(16,2): redondea HALF-EVEN (banker's rounding) → 100.005 = 100.00
  PostgreSQL NUMERIC:   redondea HALF-UP por defecto           → 100.005 = 100.01

→ Diferencia de $0.01 por transacción × miles de ops/día = discrepancia contable

Mitigación: configurar RoundingMode.HALF_EVEN en la capa de aplicación
            antes de cualquier operación numérica.
```

> **[SME-PENDING — QA Lead]** Definir la lista completa de SPs con operaciones MONEY que requieren validación de rounding.


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicred_*.sql (análisis estático de 70 archivos SQL) · Specialist — Informix SPL Analysis + QA Lead Equivalencia*
