# INC-20260424-002 — Perfil de Deudor Inaccesible: `sp_obtener_datos_cv_web` · Defecto CHAR(5) en Producción

**ID:** INC-20260424-002  
**Fecha captura:** 2026-04-24  
**Portal:** [inc-002-d11-cobranza-cv.html](../../portal/incidents/inc-002-d11-cobranza-cv.html)  
**Hora de actividad:** 00:00–23:59 CST (crónico — defecto de código activo en producción)  
**Sistemas afectados:** `bdicobranza` (D11) → Caja2 → ciclo de gestión de cobranza  
**Severidad:** N4 — 97.37% de falla en el SP principal de perfil de deudor; riesgo CNBV CUB Art. 75  
**Fuentes analizadas:** `bdicobranza_sp_obtener_datos_cv_web.sql` · runbook INC-D11-04 · risk register P655-R009/R010  
**Estado:** DEFECTO ACTIVO EN PRODUCCIÓN — CHAR(5) trunca código de retorno Informix (6 caracteres)  
**Runbook origen:** INC-D11-04 en `knowledge-base/D11-bdicobranza/21-observability-runbook.md`

---

## 1. Síntesis del incidente

El 24 de abril de 2026 (y cronológicamente desde antes), el SP `sp_obtener_datos_cv_web` presenta una tasa de error del **97.37%**: de aproximadamente 49,701 llamadas diarias, solo 2.63% completa exitosamente. El proceso de cobranza (Caja2) no puede acceder al perfil del cliente deudor en el 97.37% de los intentos.

La causa es un **defecto de código verificado en el SQL fuente**: la variable `cCodRet` está declarada como `CHAR(5)` cuando los códigos de error de Informix tienen 6 caracteres. El código de retorno queda truncado, el bloque `ON EXCEPTION` captura el error silenciosamente sin bitácora (CWE-390 — Error Without Action), y el SP retorna un código inválido que el cliente ESB no puede interpretar.

Este es un **estado crónico conocido**, no un incidente de infraestructura. La tasa de 97.37% es el baseline de producción desde que el defecto existe.

---

## 2. Evidencia cuantitativa

### 2.1 Métricas de impacto (desde runbook INC-D11-04)

| Métrica | Valor |
|---------|-------|
| Llamadas diarias a `sp_obtener_datos_cv_web` | ~49,701 |
| Tasa de error | **97.37%** |
| Llamadas fallidas / día | ~48,390 |
| Llamadas exitosas / día | ~1,311 (2.63%) |
| Perfil de deudor accesible | 2.63% de los casos |
| Clientes omitidos del ciclo de cobranza | ~97% |

### 2.2 Causa raíz verificada en código fuente

```sql
-- Defecto P655-R009: CHAR(5) trunca códigos Informix de 6 caracteres
DEFINE cCodRet CHAR(5);    -- debe ser CHAR(6)

-- Defecto P655-R010: ON EXCEPTION silencioso (CWE-390)
ON EXCEPTION SET sSqlErr
    LET cCodRet = sSqlErr; -- código de 6 chars truncado a 5
    RETURN cCodRet, ...;   -- retorna código inválido, sin bitácora
END EXCEPTION;
```

Los códigos de error de IBM Informix IDS son numéricos de hasta 6 dígitos (ej. `-25590`, `-23101`). Al ser asignados a `CHAR(5)`, el último dígito se pierde y el código resultante no coincide con ningún código documentado. El ESB recibe el código truncado y reporta `estatus=error` sin código válido en los logs (`errores_bus`), que es la firma CWE-390 observada en los logs.

### 2.3 Defecto relacionado P655-R011

```sql
-- bdicred:"informix".sp_consulta_saldocortemin
-- El SP tiene un espacio en el nombre del database qualifier:
-- "bdicred: " (con espacio) en lugar de "bdicred:"
-- Causa errores de resolución en llamadas cross-DB desde bdicobranza
```

Este defecto adicional (P655-R011) amplifica el impacto: las llamadas cross-DB de `sp_obtener_datos_cv_web` hacia `bdicred` también fallan cuando el SP destino tiene el espacio en el qualifier.

### 2.4 Impacto en el ciclo de cobranza

Con Caja2 sin acceso al perfil del deudor en el 97.37% de los intentos:
- El gestor de cobranza no puede ver el saldo, historial de pagos ni datos de contacto del cliente.
- Los clientes son omitidos del ciclo de gestión de cobranza sin ninguna alerta.
- Los planes de reestructura basados en datos de perfil son potencialmente incorrectos.
- Riesgo CNBV CUB Art. 75: el banco está obligado a mantener información actualizada del deudor accesible para los procesos de cobranza.

---

## 3. Causa raíz confirmada

**Defecto P655-R009:** `DEFINE cCodRet CHAR(5)` en lugar de `CHAR(6)`. Los códigos de retorno negativos de Informix como `-25590` tienen 6 caracteres incluyendo el signo. Al truncarse a 5, el código resultante no coincide con ningún código documentado.

**Defecto P655-R010:** El bloque `ON EXCEPTION SET sSqlErr` captura el error pero no registra ninguna entrada en bitácora ni lanza un error hacia arriba — patrón CWE-390 (Error Without Action). El SP parece "completar normalmente" pero retorna datos incorrectos o vacíos.

**Mecanismo de falla:**
```
1. sp_obtener_datos_cv_web invocado por Caja2 con id_cliente
2. Cross-DB hacia bdicred → error Informix (código 6 chars)
3. ON EXCEPTION captura el error → LET cCodRet = sSqlErr (truncado a 5 chars)
4. RETURN cCodRet, ... → retorna código inválido
5. ESB recibe código inválido → reporta estatus=error sin código en logs
6. Caja2 no puede mostrar perfil del deudor → omite al cliente del ciclo de cobranza
7. Sin alerta → 97.37% de falla pasa como "estado normal"
```

---

## 4. Defectos identificados

| ID | SP | Tipo | Descripción |
|----|----|----|-------------|
| P655-R009 | `sp_obtener_datos_cv_web` | CWE-131 (buffer insuf.) | `DEFINE cCodRet CHAR(5)` — debe ser `CHAR(6)` |
| P655-R010 | `sp_obtener_datos_cv_web` | CWE-390 (error silencioso) | `ON EXCEPTION` sin logging ni re-raise |
| P655-R011 | `bdicred:sp_consulta_saldocortemin` | Error de qualifier | Espacio en `"bdicred: "` causa fallo de resolución cross-DB |

---

## 5. Patrones de riesgo para la migración

### Patrón 1 — CHAR(N) insuficiente para códigos de error de sistema
IBM Informix IDS usa códigos de error numéricos de hasta 6 dígitos. En PostgreSQL (Aurora), los códigos SQLSTATE son cadenas de 5 caracteres alfanuméricos. La migración requiere revisar todos los `DEFINE cVar CHAR(N)` que almacenan códigos de error del motor y redefinirlos con el tipo correcto en el target.

### Patrón 2 — ON EXCEPTION silencioso (CWE-390) como anti-patrón sistémico
El análisis del corpus (2026-08-05) confirma que **108 SPs en 12 bases de datos** tienen el exception handler comentado o silencioso. Este es el patrón de mayor riesgo en la migración: los errores que hoy son silenciosos en Informix pueden manifestarse diferente en Aurora PostgreSQL, haciendo imposible el parallel-run si no se instrumenta logging en todos los exception handlers.

### Patrón 3 — Tasa de error como "estado normal"
Una tasa de 97.37% de error se convierte en el baseline de producción. En el target, la alerta de error rate para `sp_obtener_datos_cv_web` debe recalibrarse post-fix a `> 5%` (no al 97% actual), ya que el SP corregido debería tener < 1% de error rate.

---

## 6. Acciones correctivas

**Fix de código (prioridad alta — bloquea wave D11):**
1. Cambiar `DEFINE cCodRet CHAR(5)` → `CHAR(6)` en `sp_obtener_datos_cv_web`.
2. Agregar logging en el bloque `ON EXCEPTION` (nombre del SP, código de error, timestamp, id_cliente).
3. Verificar y corregir el espacio en `bdicred: "informix".sp_consulta_saldocortemin` (P655-R011).
4. Validar en ambiente no productivo: id_cliente sin saldo corte debe retornar `000001`, no error.

**Post-fix:**
1. Recalibrar alerta de error_rate a `> 5%`.
2. Reprocesar los perfiles de clientes omitidos durante el período del defecto — coordinar con Crédito BanCoppel.
3. Actualizar risk register P655-R009/R010/R011 a estado RESUELTO.

---

*Fuentes: `knowledge-base/D11-bdicobranza/21-observability-runbook.md` INC-D11-04 · `source/BCOPCore/informix/bdicobranza_sp_obtener_datos_cv_web.sql` · risk register P655-R009/R010/R011.*  
*Creado: 2026-08-06 | BCOPCore Gemelo Cognitivo — DISCOVER Etapa 1*
