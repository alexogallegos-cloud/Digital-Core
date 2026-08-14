# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Plan de Migración de Datos

> **Componente:** Informix · SPE-AM-001 · RELEASE Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Consideraciones regulatorias para la migración de datos PLD

> `[COMPLIANCE-SIGN-OFF-REQUIRED]` — El plan de migración de datos de `bdilide` requiere aprobación explícita del Área de Cumplimiento de BanCoppel antes de ejecutarse. Los datos PLD son registros regulatorios con retención obligatoria de 10 años (LFPIORPI Art. 19).

**Restricciones especiales:**
- Todos los datos históricos en `sl_movefec_his` deben migrarse íntegramente — ningún registro puede perderse.
- La migración debe documentarse en un informe de integridad que puede ser requerido por la CNBV en auditoría.
- Los datos migrados deben ser verificables (hash/checksum) para demostrar que no hubo alteración.

## Clasificación de tablas por estrategia de migración

| Tabla | Estrategia | Justificación |
|-------|-----------|--------------|
| `sl_movefec` | CDC (Change Data Capture) | Tabla activa con escrituras diarias; requiere sincronización continua |
| `sl_movefec_his` | Full Load + verificación | Histórico inmutable (solo INSERT, nunca UPDATE/DELETE); migrar completo |
| `sl_retlide` | CDC | Actualizada diariamente por el proceso batch |
| `sl_detlide` | CDC | Lista LIDE actualizada frecuentemente |
| `sl_exentos` | CDC | Actualizada mensualmente por el SAT |
| `sl_exentostemp` | Full Load | Tabla temporal; migrar en snapshot del cutover |
| `sl_constancias` | Full Load + CDC | Datos históricos + nuevas constancias |
| `sl_consat` | Full Load + CDC | Histórico SAT + nuevas consultas |
| `sl_procesos` | Reinicio limpio | Tabla de control operativo; inicializar vacía en el target |
| `sl_parametros` | Full Load | Parámetros de configuración; migrar y verificar manualmente |
| `sl_archsat` | Full Load | Control de archivos enviados; migrar completo |
| `sl_archivoconsulta` | Full Load punto de corte | Archivos de trabajo transitorios |
| `sl_archivocontrol` | Full Load punto de corte | Archivos de trabajo transitorios |

## Herramienta de CDC para bdilide

Herramienta: **AWS DMS** (Database Migration Service) con Debezium como complemento para captura de cambios.

Configuración especial para tipos MONEY:
```
decimal.handling.mode=string
numeric.mapping=best_fit
```

> Esto evita la pérdida de precisión en los campos `MONEY` — el valor viaja como String y se convierte a `BigDecimal` con `HALF_EVEN` en la capa de aplicación.

## Fases de la migración de datos

### Fase 1: Full Load inicial (T-30 días antes del cutover)

1. Extraer snapshot completo de todas las tablas `sl_*` de Informix.
2. Transformar tipos (MONEY → NUMERIC, DATETIME → TIMESTAMP, etc.).
3. Cargar en Aurora PostgreSQL (ambiente de staging).
4. Verificar integridad:
   - Recuento de registros: tabla origen vs. tabla destino (debe ser 100%).
   - Hash MD5 de `sl_movefec_his` por período (tabla histórica crítica).
   - Verificar los 10 años de histórico (`sl_movefec_his`): `COUNT(DISTINCT anio_mes) = 120` mínimo.

### Fase 2: CDC continuo (T-30 días → T-día del cutover)

5. Activar CDC con Debezium desde Informix.
6. Replicar cambios en tiempo real hacia Aurora.
7. Monitorear el lag de replicación: alerta si lag > 5 minutos.
8. Verificar integridad diariamente durante el período de CDC:
   - Comparar saldos de `sl_retlide` Informix vs. Aurora al final de cada batch.
   - Comparar registros de `sl_exentos` después de cada procesamiento SAT.

### Fase 3: Verificación final (T-48 horas antes del cutover)

9. Ejecutar el batch PLD completo en el sistema target en modo shadow (sin impacto real).
10. Comparar resultados del batch legacy vs. target — tolerancia cero en diferencias.
11. Verificar que `sl_parametros` tiene los valores correctos (especialmente `vmMontLimite` y `viPorcaRecau`).
12. Obtener sign-off del QA Lead y del Área de Cumplimiento.

### Fase 4: Migración final en ventana de cutover

13. Freeze de escrituras en Informix `bdilide` (durante la ventana de corte).
14. Sincronizar delta final con CDC.
15. Verificar que el lag de CDC es 0 (todos los cambios sincronizados).
16. Cambiar el feature flag de tráfico al 100% target.

## Plan de rollback de datos

| Escenario | Acción de rollback | Tiempo estimado |
|-----------|-------------------|----------------|
| Divergencia detectada en batch < T+1 | Revertir feature flag al 100% legacy; los datos de Aurora quedan como backup | < 5 minutos |
| Divergencia detectada en reporte regulatorio | Emitir el reporte desde el sistema legacy; escalar a Cumplimiento | < 30 minutos |
| Corrupción de datos en Aurora post-cutover | Restaurar desde snapshot pre-cutover; verificar integridad; escalar a DBA | < 4 horas |

## Verificación de integridad regulatoria

El siguiente script de verificación debe ejecutarse antes del cutover y su resultado debe guardarse como evidencia:

```sql
-- Verificar completitud del histórico PLD (10 años)
SELECT
  COUNT(*) AS total_registros,
  COUNT(DISTINCT anio_mes) AS periodos_cubiertos,
  MIN(anio_mes) AS periodo_mas_antiguo,
  MAX(anio_mes) AS periodo_mas_reciente
FROM sl_movefec_his;

-- Verificar integridad de exentos actuales
SELECT COUNT(*) AS total_exentos, anio
FROM sl_exentos
WHERE status = 'A'  -- activos
GROUP BY anio
ORDER BY anio DESC;

-- Verificar parámetros PLD críticos
SELECT nombre_param, valor
FROM sl_parametros
WHERE nombre_param IN ('MONTO_LIMITE_IDE', 'PORC_RECAUDACION');
```

## `[SME-PENDING]`

- [ ] DBA IBM Informix: confirmar si Debezium puede configurarse para captura de cambios en Informix IDS 14.10.
- [ ] Confirmar el volumen real de registros en `sl_movefec_his` (10 años de datos — puede ser decenas de millones de registros).
- [ ] Área de Cumplimiento: firmar el plan de migración antes de iniciar la Fase 1.
- [ ] Definir el criterio de "integridad aceptada" para el informe de verificación (¿100.000% o se acepta alguna tolerancia técnica?).
- [ ] Confirmar si CNBV requiere notificación formal antes de migrar el sistema de monitoreo PLD.

---
*Generado: DBA IBM Informix + Data Architect + SME Regulatorio CNBV · 2026-08-03*
