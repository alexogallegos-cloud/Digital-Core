# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Estrategia de Testing

> **Componente:** Informix · SPE-AM-001 · TEST Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Estándar de equivalencia para D15

El estándar de equivalencia funcional para D15-bdilide es **≥ 99.99%** (vs. 99.95% estándar del proyecto AM), debido a la naturaleza regulatoria del dominio. Una divergencia de 0.01% en los reportes PLD puede representar una operación mal clasificada, lo cual constituye incumplimiento de la CUB/LFPIORPI.

| Métrica | Estándar AM (otros dominios) | Estándar D15-bdilide |
|---------|:----------------------------:|:--------------------:|
| Equivalencia funcional | ≥ 99.95% | ≥ 99.99% |
| Cobertura de SPs regulatorios | ≥ 90% | **100%** obligatorio |
| Archivos de reporte regulatorio | N/A | Comparación byte-a-byte |
| Parallel-run mínimo | 1 mes | **3 meses** |

## Categorías de casos de prueba

### Cat-1: Golden Master — Acumulación de Operaciones (CRÍTICO)

| ID caso | SP | Escenario | Criterio |
|---------|----|-----------|---------:|
| TC-D15-001 | `sp_acumulacionoperaciones` | Cliente con depósitos < umbral `vmMontLimite` | No genera retención IDE |
| TC-D15-002 | `sp_acumulacionoperaciones` | Cliente con depósitos = umbral exacto | Comportamiento en el límite — confirmar con Cumplimiento |
| TC-D15-003 | `sp_acumulacionoperaciones` | Cliente con depósitos > umbral en múltiples cuentas | Acumula correctamente entre cuentas |
| TC-D15-004 | `sp_acumulacionoperaciones` | Proceso ejecutado dos veces el mismo día | Retorna código `018` en el segundo intento (idempotencia) |
| TC-D15-005 | `sp_acumulacionoperaciones` | `vmMontLimite` = NULL en `sl_parametros` | Retorna error; proceso no continúa |
| TC-D15-006 | `sp_acumulacionoperaciones` | Validar fórmula `ROUND(vmMontoRecaudar - 0.01)` | Resultado debe ser idéntico al legacy en 500 casos con valores de borde |
| TC-D15-007 | `sp_acumulacionoperaciones` | `bdinteg` no disponible (falla cross-DB) | Proceso aborta y registra error; no deja registros parciales |

### Cat-2: Archivos Regulatorios (CRÍTICO — comparación byte-a-byte)

| ID caso | SP | Escenario | Criterio |
|---------|----|-----------|---------:|
| TC-D15-010 | `sp_cargainformesat` | Archivo de consulta SAT válido | Archivo generado es byte-a-byte idéntico al generado por el legacy |
| TC-D15-011 | `sp_cargainformesat` | Archivo de consulta SAT con registros EOF | Procesamiento correcto del marcador EOF (sed en legacy) |
| TC-D15-012 | `sp_cargaresultadosat` | Archivo de resultado SAT válido | Procesamiento correcto y actualización de `sl_exentos` |
| TC-D15-013 | `sp_cargaresultadosat` | Archivo de resultado SAT malformado | Retorna error; no actualiza `sl_exentos` parcialmente |
| TC-D15-014 | `sp_actualizaresultadosat` | RFC existente en `sl_consat` | Actualiza correctamente |
| TC-D15-015 | `sp_actualizaresultadosat` | RFC nuevo | Inserta en `sl_exentos` |

### Cat-3: Verificación LIDE (CRÍTICO — sin falsos negativos permitidos)

| ID caso | SP | Escenario | Criterio |
|---------|----|-----------|---------:|
| TC-D15-020 | SP de consulta LIDE (callgraph) | CURP en lista LIDE | Retorna BLOQUEADO — error tipo PLD |
| TC-D15-021 | SP de consulta LIDE (callgraph) | CURP no en lista LIDE | Retorna LIBRE |
| TC-D15-022 | SP de consulta LIDE (callgraph) | CURP en lista con fecha de vencimiento pasada | Validar si bdilide soporta vencimiento de registros LIDE |
| TC-D15-023 | `sp_checacurp` | CURP inválido (18 caracteres incorrectos) | Retorna error de validación |
| TC-D15-024 | `sp_actualizarfclide` | Cambio de RFC con historial de movimientos | Todos los registros históricos son actualizados |

### Cat-4: Ejecución del Proceso Diario (ALTO)

| ID caso | SP | Escenario | Criterio |
|---------|----|-----------|---------:|
| TC-D15-030 | `ejecutor_diario` | Ejecución normal en día hábil | Todas las fechas en `bdinteg`, `bdicheq`, `bdicred` actualizadas |
| TC-D15-031 | `ejecutor_diario` | Ejecución en día festivo | Comportamiento documentado por Cumplimiento |
| TC-D15-032 | `ejecutor_diario` | Falla en update de `bdicheq` a mitad del proceso | Rollback limpio sin fechas inconsistentes |

### Cat-5: Consulta al Buró de Crédito (ALTO)

| ID caso | SP | Escenario | Criterio |
|---------|----|-----------|---------:|
| TC-D15-040 | `borramovs_movefechis` | Periodo con movimientos en `sl_movefec_his` | Retorna y borra correctamente |
| TC-D15-041 | `borramovs_movefechis` | Periodo sin movimientos | Retorna sin error, cero registros borrados |
| TC-D15-042 | `borramovs_movefechis` | Formato CHI inválido | `[DATO-REQUERIDO]` — validar comportamiento |

## Enfoque de golden master

```
Para cada SP regulatorio de D15:

1. Capturar snapshot de sl_* antes de la ejecución en legacy
2. Ejecutar el SP en el sistema legacy (Informix)
3. Capturar snapshot de sl_* después de la ejecución en legacy
4. Guardar: parámetros de entrada + snapshot pre + snapshot post + RETURNING values

5. Ejecutar los mismos parámetros en el target (microservicio Java)
6. Comparar: snapshot post target vs. snapshot post legacy
7. Para archivos de reporte: comparar bytes del archivo generado

Herramienta: golden-master-framework-bcop (QA Lead)
Almacenamiento: S3 con versionado + firma digital para evidencia regulatoria
```

## Datos de prueba

> `[COMPLIANCE-SIGN-OFF-REQUIRED]` — Los datos de prueba para D15 deben ser datos anonimizados o sintéticos. Bajo ninguna circunstancia se usarán datos reales de clientes en la lista LIDE para testing en ambientes no-productivos.

- Los datos de prueba de clientes en LIDE deben ser CURP/RFC sintéticos con el formato correcto.
- Los montos de prueba para acumulación PLD deben incluir casos con valores exactamente en el umbral y ±1 centavo.
- Los archivos de intercambio SAT de prueba deben construirse manualmente con el formato oficial.

## `[SME-PENDING]`

- [ ] QA Lead: confirmar la herramienta de golden master y el procedimiento de captura para SPs batch.
- [ ] Área de Cumplimiento: validar los casos de prueba Cat-3 (LIDE) y confirmar los criterios de "BLOQUEADO".
- [ ] Definir la ventana de parallel-run (3 meses) y el criterio de "equivalencia aceptada" para declarar el go/no-go.
- [ ] Confirmar si los archivos de reporte requieren firma digital para ser válidos ante el regulador.

---
*Generado: QA Lead — Equivalencia Funcional + SME Regulatorio CNBV · 2026-08-03*
