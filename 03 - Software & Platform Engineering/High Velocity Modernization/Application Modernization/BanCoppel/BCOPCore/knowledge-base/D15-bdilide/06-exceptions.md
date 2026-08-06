# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Manejo de Excepciones

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Convención de manejo de errores en `bdilide`

El dominio usa la convención de retorno de código estándar de BCOPCore. Los SPs retornan `CHAR(5)` o `CHAR(6)` como código de resultado. La convención es:

- `00000` o `000000` — éxito
- Valores distintos de cero — error o condición especial

El patrón `ON EXCEPTION SET sql_err, isam_err` es el mecanismo primario de captura. El SP `sp_grabarerrores` (identificado en `sp_actualizacodfechaenvio`) es el handler centralizado de registro de errores del dominio.

## Códigos de retorno identificados en el código

| Código | SP origen | Condición | Severidad |
|--------|----------|-----------|-----------|
| `018` | `sp_acumulacionoperaciones` L126 | El proceso de recaudación diaria ya fue ejecutado anteriormente (idempotencia) | 🟡 INFO — no reejecutar |
| `[DATO-REQUERIDO]` | `sp_acumulacionoperaciones` | `pFechaProceso IS NULL` — parámetro inválido | 🔴 ERROR |
| `[DATO-REQUERIDO]` | `sp_acumulacionoperaciones` | `vmMontLimite = 0 OR NULL` — umbral PLD no configurado | 🔴 CRÍTICO — proceso no puede continuar sin umbral |
| `[DATO-REQUERIDO]` | `sp_acumulacionoperaciones` | `viPorcaRecau = 0 OR NULL` — porcentaje IDE no configurado | 🔴 CRÍTICO — proceso no puede continuar sin porcentaje |
| `[DATO-REQUERIDO]` | `sp_actualizacodfechaenvio` | Error al actualizar fecha de envío regulatorio | 🔴 ERROR |
| `[DATO-REQUERIDO]` | `sp_cargainformesat` | Archivo de informe SAT no encontrado | 🔴 CRÍTICO — reporte regulatorio fallido |
| `[DATO-REQUERIDO]` | `sp_cargaresultadosat` | Archivo de resultado SAT no encontrado | 🔴 CRÍTICO — reporte regulatorio fallido |
| `[DATO-REQUERIDO]` | `borramovs_movefechis` | Error al consultar o eliminar historial de movimientos | 🟠 ALTO |

> `[DATO-REQUERIDO]` — Los valores exactos de los códigos de retorno deben extraerse del código fuente completo de cada SP. Se requiere acceso al código fuente completo de los 101 SPs.

## Excepciones regulatorias — impacto especial

A diferencia de otros dominios, las excepciones en `bdilide` tienen consecuencias regulatorias además de operacionales:

| Excepción | Consecuencia regulatoria | Acción requerida |
|-----------|-------------------------|-----------------|
| Falla en `sp_acumulacionoperaciones` | El período de acumulación queda sin reportar al SHCP | Notificación inmediata al Área de Cumplimiento; evaluar reporte manual sustituto |
| Falla en `sp_cargainformesat` / `sp_cargaresultadosat` | El intercambio con SAT no se completa | Verificar si el plazo regulatorio puede cumplirse con reintento; si no, notificar al SAT |
| Archivo regulatorio generado con error de formato | Rechazo del archivo por CNBV/SHCP/SAT | Los archivos rechazados deben corregirse y reenviarse dentro del plazo |
| `ejecutor_diario` fallido a mitad de batch | Inconsistencia de fechas entre dominios | Requiere rollback coordinado entre `bdilide`, `bdicheq` y `bdicred` |
| SP de screening LIDE no disponible | Clientes no verificados contra la lista negra | BLOQUEANTE — operaciones no deben procesarse hasta restaurar el screening |

## Patrón de captura de excepciones en SPL

```sql
-- Patrón estándar identificado en el dominio:
ON EXCEPTION SET sql_err, isam_err
    LET desc_err = "Error en [nombre SP]: " || sql_err::CHAR(10);
    CALL sp_grabarerrores(sql_err, isam_err, desc_err, ...);
    RETURN vcCodRet, ...;
END EXCEPTION

-- Control de cursor (patrón identificado en borramovs_movefechis):
LET vcomienza = -1;  -- bandera: -1 = no iniciado, 1 = iniciado
-- Al abrir cursor: vcomienza = 1
-- En limpieza: IF vcomienza = 1 THEN CLOSE cursor END IF
```

## Equivalencia de excepciones en el target

La estrategia de excepciones del target debe preservar la semántica de los códigos de retorno existentes:

| Patrón Informix SPL | Equivalente target (Java/Spring) |
|--------------------|----------------------------------|
| `ON EXCEPTION SET sql_err, isam_err` | `try-catch (DataAccessException e)` |
| `RETURN vcCodRet` (código de error) | Retornar objeto `PldResponse` con `codigoRetorno` y `mensaje` |
| `CALL sp_grabarerrores(...)` | Escribir en log estructurado + publicar evento en CloudWatch |
| Código `018` (proceso ya ejecutado) | HTTP 409 Conflict con cuerpo explicativo |
| Excepción regulatoria | HTTP 503 + notificación automática a Compliance vía SNS |
| Excepción de parámetro no configurado | HTTP 500 + alerta PagerDuty nivel CRÍTICO |

## `[SME-PENDING]`

- [ ] Completar la tabla de códigos de retorno con los valores exactos de todos los SPs.
- [ ] Confirmar con el Área de Cumplimiento el procedimiento de escalación para excepciones en reportes regulatorios.
- [ ] Definir el SLA de resolución para excepciones en `sp_cargainformesat` (plazo regulatorio SAT).
- [ ] Documentar si `sp_grabarerrores` registra en tabla o en archivo — necesario para migrar el mecanismo.

---
*Generado: análisis estático bdilide · 2026-08-03*
