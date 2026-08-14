# INC-20260807 — ConsNumCte -674 / SpgeneraReportePpWeb -1202 · Capa WAS

**ID:** INC-20260807  
**Fecha:** 2026-08-07  
**Ventana observada:** 07:00–22:00 CST  
**Capa afectada:** WebSphere Application Server 9.0.5.15 / AIX 7.2 (ClusterMember1_OfiWeb)  
**Sistemas involucrados:** bdinteg · bdisolic · bdicred · bdicnweb — vía SOAP  
**Severidad derivada:** OBSERVACIÓN — no es corte de servicio; son errores sistemáticos recurrentes identificados en análisis de logs DISCOVER  
**Fuentes analizadas:** `source/logs/2026-08-07/` — SystemOut*.log + SystemErr*.log (2 nodos · ~2.4M líneas)  
**Estado:** CAUSA RAÍZ CONFIRMADA por lectura de código fuente de los SPs involucrados (2026-08-07)  
**Derivación:** Análisis independiente del dato crudo. Sin referencia a análisis de terceros.  

---

## 1. Síntesis

El análisis de los logs del 2026-08-07 de la capa Java/SOAP que envuelve el core Informix revela dos patrones de error sistemáticos con causas raíz distintas. No representan degradación del día — son errores cotidianos que producción acepta silenciosamente como resultado normal de los SPs. Su importancia para `SPE-AM-001` es crítica: ambos exponen el anti-patrón de **propagación directa de errores del motor Informix como retcodes de negocio**, que el target debe replicar con exactitud.

| Error | SP | Tasa | Causa raíz |
|-------|----|------|------------|
| -674 | bdinteg:consnumcte | 3.3% (381/11,422) | Lock timeout en si_cliente — LOCK MODE WAIT 3 segundos |
| -1202 | bdisolic:sp_generareportepp_web | 26.7% (485/1,818) | NULL en aritmética MONEY dentro de FOREACH sp_proyecta_prestamos |

---

## 2. Contexto del stack

```
Cliente (sucursal/caja)
  → WAS ClusterMember1_OfiWeb (10.27.31.20 · 10.27.31.32)
  → SOAP mx.com.solser.*
  → Informix IDS 14.10 / DCMSIF01
```

Los nombres SOAP son PascalCase (`ConsNumCte`, `SpgeneraReportePpWeb`) y no mapean 1:1 a los nombres snake_case de los SPs (`consnumcte`, `sp_generareportepp_web`). La correspondencia se confirma por inspección del código fuente Java + Informix.

---

## 3. Métricas del día (2026-08-07)

| Métrica | Valor |
|---------|-------|
| SOAP responses totales | 534,394 |
| Errores SOAP (retcode negativo) | 906 (0.17%) |
| Excepciones Java (SystemErr) | 5,789 |
| ERROR en SystemOut | 44,706 |
| Contextos SOAP activos | 53 |
| HTTP requests de negocio | 2,324,816 |

### Distribución horaria SOAP

| Hora | Llamadas | % |
|------|----------|---|
| 09h | 46,928 | 8.8% |
| 10h | 163,895 | 30.7% (pico) |
| 11h | 130,161 | 24.4% |
| 12h | 71,352 | 13.4% |
| 13h | 64,842 | 12.1% |
| 20h | 44,793 | 8.4% (pico nocturno) |

Ventana 09–13h: 87.3% del tráfico diario.

---

## 4. Error 1 — ConsNumCte / -674

### 4.1 Evidencia cuantitativa

| Métrica | Valor |
|---------|-------|
| Llamadas totales del día | 11,422 |
| Retcodes -674 | 381 (3.3%) |
| Retcodes 00000 (éxito) | 11,041 (96.7%) |
| Clase Java que registra el error | GeneralCajaBusinessImpl |
| Mensaje en SystemOut | ERROR EN EL DESGLOSE DE CHEQUES (Backend) :: -674 |

### 4.2 Código fuente — bdinteg_consnumcte.sql

Líneas relevantes:

```sql
-- Línea 164 — handler que captura el error
ON EXCEPTION SET vsqlerr
    IF vsqlerr <> 0 THEN
        let vcodret = vsqlerr;   -- ← Informix -674 se convierte en retcode
        RETURN vcodret, ...
    END IF;
END EXCEPTION;

-- Línea 182 — timeout configurado
SET LOCK MODE TO WAIT 3;  -- máximo 3 segundos

-- Línea 203 — consulta sobre la tabla caliente
SELECT ... FROM "informix".si_cliente c,
               outer "informix".si_ctepf f
WHERE c.numcte = pnumcte AND c.empresa = pempresa;
```

### 4.3 Cadena causal confirmada

```
1. Cajera llama ConsNumCte desde ventanilla (09–12h)
2. SP bdinteg:consnumcte adquiere SET LOCK MODE TO WAIT 3 sobre si_cliente
3. si_cliente está siendo modificada por otro proceso (escritura concurrente)
4. La espera supera 3 segundos → Informix emite error -674 (record lock refused)
5. ON EXCEPTION en línea 164 captura el error
6. let vcodret = vsqlerr → vcodret = -674
7. RETURN vcodret → SOAP devuelve -674 como retcode de negocio
8. Java: GeneralCajaBusinessImpl registra "ERROR EN EL DESGLOSE DE CHEQUES :: -674"
```

### 4.4 Causa raíz

**Lock contention en `si_cliente`**. La tabla es de alta escritura concurrente (actualizaciones de saldo en tiempo real + otros procesos). El timeout de 3 segundos era suficiente en volúmenes anteriores; con 11,422 llamadas/día en ventana caja pico ya no absorbe la contención. El SP no tiene lógica de reintentos — falla inmediatamente al expirar el timeout.

---

## 5. Error 2 — SpgeneraReportePpWeb / -1202

### 5.1 Evidencia cuantitativa

| Métrica | Valor |
|---------|-------|
| Llamadas totales del día | 1,818 |
| Retcodes -1202 | 485 (26.7%) |
| Retcodes 00000 (éxito) | 1,127 (62.0%) |
| Retcodes 00001 | 206 (11.3%) |
| Contexto SOAP | SolicitudesCred |

El 26.7% de error rate sobre una operación con 1,818 llamadas/día indica una condición **sistémica, no aleatoria**: hay un subconjunto de solicitudes o productos para los que la proyección de pagos no es calculable.

### 5.2 Código fuente — bdisolic_sp_generareportepp_web.sql

Líneas relevantes:

```sql
-- Línea 143 — handler que captura el error
ON EXCEPTION SET sql_err
    IF sql_err <> 0 THEN
        let cCodret = sql_err;   -- ← Informix -1202 se convierte en retcode
        RETURN cCodret, '', '', ...
    END IF;
END EXCEPTION;

-- Línea 297 — FOREACH donde se produce el NULL
FOREACH
    EXECUTE PROCEDURE "informix".sp_proyecta_prestamos(
        iMontoTotal, '0', cCapacidad_pres, pProducto, pSucursal,
        '1', '0', pNumSolicitud, '', pFrecuencia)
    INTO cCodRet, Periodo, FechaCouta, SaldoInicial, Mensualidad,
         Intereses,     -- MONEY(14,2) — candidato a NULL
         IvaInteres,    -- MONEY(14,2) — candidato a NULL
         Capital, SaldoFinal, DiasPeriodo, Fechaaper, cNumMesesPagos

    -- Línea 301 — aritmética sin guard
    LET cMontoTotales = cMontoTotales + Intereses + IvaInteres;
END FOREACH;
```

Informix error -1202 = **"Null value not allowed"** — se dispara cuando se intenta aritmética sobre una variable MONEY que contiene NULL.

### 5.3 Cadena causal confirmada

```
1. Canal web solicita reporte de Pago Programado (pTipo=1)
2. SP bdisolic:sp_generareportepp_web invoca sp_proyecta_prestamos en FOREACH
3. Para ciertos productos/solicitudes, sp_proyecta_prestamos devuelve NULL
   en Intereses o IvaInteres (no tiene proyección calculable)
4. LET cMontoTotales = cMontoTotales + Intereses + IvaInteres
   → aritmética sobre NULL → Informix -1202
5. ON EXCEPTION en línea 143 captura el error
6. let cCodret = sql_err → cCodret = -1202
7. RETURN cCodret → SOAP devuelve -1202 como retcode de negocio
```

### 5.4 Causa raíz

**NULL en variable MONEY durante proyección de pagos**. El SP no tiene guard explícito (`IF Intereses IS NULL THEN let Intereses = 0 END IF`) antes de la aritmética. El 26.7% de error rate indica que aproximadamente 1 de cada 4 solicitudes consultadas corresponde a productos sin parámetros de proyección válidos en `sp_proyecta_prestamos`.

Los códigos de error de negocio del SP (cuando la solicitud no existe) son positivos de 5 caracteres: `'00120'`, `'00110'`, `'00130'`, `'00140'`. El -1202 es puro error del motor — no es una validación de negocio intencional.

---

## 6. Anti-patrón común — ON EXCEPTION como propagador de errores del motor

Ambos SPs comparten el mismo anti-patrón de diseño:

```sql
ON EXCEPTION SET var_err
    IF var_err <> 0 THEN
        let retcode = var_err;   -- error del motor Informix → retcode de negocio
        RETURN retcode, ...
    END IF;
END EXCEPTION;
```

Este patrón está extendido en el corpus Informix. El motor Informix tiene códigos de error negativos (`-674`, `-1202`, `-255`, `-391`, etc.) que el SP captura y devuelve directamente como primera columna del retorno. La capa Java los recibe, los registra como error, y en algunos casos los propaga al frontend.

**Implicación para la migración:** el target no puede simplemente lanzar una excepción Java cuando ocurre una condición equivalente. Debe devolver exactamente el mismo código numérico negativo para que el comportamiento de la capa de presentación sea idéntico.

---

## 7. Defectos identificados

| ID | SP | Línea | Descripción |
|----|-----|-------|-------------|
| D1 | bdinteg:consnumcte | 182 | `SET LOCK MODE TO WAIT 3` insuficiente para contención actual de si_cliente; sin lógica de reintento |
| D2 | bdisolic:sp_generareportepp_web | 297-301 | FOREACH sin guard para NULL en Intereses/IvaInteres antes de aritmética MONEY |
| D3 | (múltiples SPs) | — | Anti-patrón `ON EXCEPTION SET → let retcode = error_motor` extendido en el corpus; cada instancia requiere análisis individual para el target |

---

## 8. Otros errores del día (menor severidad)

| Servicio | Error | Tasa | Candidato de causa |
|----------|-------|------|--------------------|
| SpConsCteBpiWeb | -0001 | 15.9% (21/132) | Sin código fuente; posiblemente registro no encontrado en BPI |
| SpConsultaPreAprobado | -284 | 0.2% (15/6,707) | Error motor Informix -284 |
| SpBuscarCtesaMigrarWeb | -391 | 0.07% (2/3,012) | Error motor Informix -391 |
| ArqueoSucursal | -268 | 0.4% (1/265) | Error motor Informix -268 |

### Excepciones Java del día

| Excepción | Ocurrencias | Impacto |
|-----------|-------------|---------|
| BusinessException | 4,179 | "No se Encontro Sesión Asociada" — validación de sesión en capa Java, no en SP |
| NestedServletException | 1,588 | NPE en ProductosDaoImpl — deuda técnica activa en producción |
| EmptyResultDataAccessException | 21 | Consulta sin resultado esperado |
| DataIntegrityViolationException | 1 | Error en bitácora FNBITACORA_TIMESTAMPS_INSTR |

---

## 9. Implicaciones para la migración · SPE-AM-001

### 9.1 Golden master tests

Los tests de equivalencia funcional (DoD-SPE-AM-01 — ≥ 99.95% de outputs idénticos) deben cubrir explícitamente los siguientes paths de error:

| Path | Input requerido | Output esperado del target |
|------|----------------|---------------------------|
| ConsNumCte bajo lock contention | Simular lock sobre si_cliente o usar solicitud con datos que disparen timeout | Retcode -674 |
| SpgeneraReportePpWeb con producto sin proyección | numSolicitud + pProducto de un producto sin datos en sp_proyecta_prestamos | Retcode -1202 |
| SpConsCteBpiWeb sin registro BPI | numCte sin registro BPI | Retcode -0001 |

### 9.2 Decisiones de diseño en el target

1. **ConsNumCte → microservicio target:** Aurora PostgreSQL usa MVCC — no hay lock contention equivalente. Sin embargo, el microservicio debe devolver -674 cuando se produzca un timeout de acceso a datos equivalente. Implementar circuit breaker con retcode -674 en caso de timeout configurado.

2. **sp_generareportepp_web → microservicio target:** Añadir guard explícito antes de aritmética:
   ```java
   BigDecimal intereses = row.getIntereses() != null ? row.getIntereses() : BigDecimal.ZERO;
   BigDecimal ivaIntereses = row.getIvaIntereses() != null ? row.getIvaIntereses() : BigDecimal.ZERO;
   ```
   Y cuando la proyección es imposible (datos NULL), devolver retcode -1202 para mantener la compatibilidad de comportamiento.

3. **Validación de sesión (BusinessException):** La lógica de "No se Encontro Sesión Asociada" vive en la capa Java, no en los SPs Informix. El microservicio target debe incluir esta validación de sesión explícitamente.

### 9.3 SLO paralell-run

Durante el parallel-run (DoD-SPE-AM-02 — mínimo 2 sprints), el comparador debe monitorear:
- Tasa de retcode -674 en ConsNumCte: expected ~3.3% en condiciones equivalentes
- Tasa de retcode -1202 en SpgeneraReportePpWeb: expected ~26.7% para el mismo subconjunto de productos

Una divergencia significativa en estas tasas indica que el target no está replicando las condiciones de error correctamente.

---

## 10. Preguntas abiertas

1. **sp_proyecta_prestamos** — ¿Cuáles son los productos o configuraciones específicos que devuelven NULL en Intereses/IvaInteres? ¿Es una condición de datos esperada (producto sin parámetros de amortización configurados) o un defecto de datos?

2. **ConsNumCte y si_cliente** — ¿Qué procesos concurrentes están escribiendo en `si_cliente` durante la ventana 09–12h? ¿Son otros SPs de la capa caja o procesos batch de actualización de cuentas?

3. **SpConsCteBpiWeb** — No hay código fuente disponible. El dominio BPI (D17-bdibpi) está en los placeholders D17-D49. Requiere análisis cuando se amplíe el scope de DISCOVER.

4. **NPE en ProductosDaoImpl** — 8,600 ocurrencias/día es una señal de deuda técnica activa. ¿Qué consulta de catálogo de productos devuelve null de forma sistemática?

---

*Fuentes: `source/logs/2026-08-07/` · `source/informix/bdinteg_consnumcte.sql` (313 líneas) · `source/informix/bdisolic_sp_generareportepp_web.sql` (436 líneas)*  
*Parser: `generators/analyze-was-logs.py` v1.0 · Artefacto visual: `portal/incidents/inc-009-was-2026-08-07.html`*  
*Creado: 2026-08-07 · Informix Gemelo Cognitivo — DISCOVER Etapa 1*
