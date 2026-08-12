# D09 · Mensajería — Estrategia de Pruebas de Equivalencia (Golden Master)

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdimnsj` · IBM Informix IDS 14.10 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático)
- Domain Expert — BanCoppel / Mensajería (validación funcional)
- Architect — Application Modernization (diseño target EventBus/AsyncAPI)
- QA Lead — Equivalencia funcional (casos de prueba)

> Secciones `[SME-PENDING]` requieren sesión de validación antes de Etapa 2.
---


## Objetivo

Demostrar que el `NotificationService` target (microservicio que reemplaza a `bdimnsj`) produce **resultados idénticos** al SP Informix original bajo todas las condiciones relevantes de producción. Sin esta equivalencia demostrada, el cutover no puede proceder.

## Prioridad de pruebas — D09 es Wave 1

Por ser el primer dominio en migrar, el golden master de D09 establece el **patrón de prueba** para todos los demás dominios. La estrategia aquí definida debe ser replicable.

## TS-D09-01 · Golden Master de sp_registra_evento

Este SP tiene 1,404 callers y es el único punto de entrada público. Su equivalencia es **no negociable**.

### Captura del golden master (Informix)

```sql
-- Ejecutar en instancia Informix PRODUCCIÓN durante ventana de observación (7 días):
-- Capturar: todos los parámetros de entrada + código de retorno + estado de tabla destino

SELECT
    pTipoMsj, pIdMsj, pIdPlantilla, pNumclt, pNumcta, pNumTarjeta,
    pImporte1, pImporte2, pImporte3,
    pfecha1, pfecha2,
    cCodRet,           -- retorno del SP
    CURRENT            -- timestamp de ejecución
FROM bdimnsj:mnsj_audit_log  -- [SME-PENDING: confirmar tabla de audit]
WHERE fecha_insert >= TODAY - 7
ORDER BY fecha_insert;
```

### Casos de prueba mínimos requeridos

| ID | Escenario | Parámetros relevantes | Resultado esperado |
|----|-----------|----------------------|-------------------|
| TC-01 | Evento de cargo exitoso | pTipoMsj='C', pImporte1>0 | cCodRet='00000', registro en tabla eventos |
| TC-02 | Evento de abono exitoso | pTipoMsj='A', pImporte1>0 | cCodRet='00000' |
| TC-03 | Cliente sin suscripción activa | pNumclt=cliente_sin_msj | cCodRet=? **[SME-PENDING]** |
| TC-04 | Evento duplicado mismo día (pIdMsj repetido) | Mismo pIdMsj en mismo día | cCodRet=? **[SME-PENDING]** — hay validación de dedup |
| TC-05 | pImporte con centavos .005 (rounding MONEY) | pImporte1=100.005 | Verificar round half-even vs half-up |
| TC-06 | pImporte1-5 todos en NULL/cero | pImporte=NULL | cCodRet=? ¿lanza excepción o procede? |
| TC-07 | pNumTarjeta con espacios o formato inválido | pNumTarjeta='1234 5678' | cCodRet=? |
| TC-08 | pfecha1 en domingo fuera de horario | pfecha1=domingo 03:00 | ¿Proceso diferido? **[SME-PENDING]** |
| TC-09 | pIdPlantilla inexistente | pIdPlantilla='XXXXXX' | cCodRet=error? **[SME-PENDING]** |
| TC-10 | Latinia no disponible (simulado) | — | ¿Falla silenciosa o propaga error? **[SME-PENDING]** |
| TC-11 | Volumen: 1,404 llamadas/seg sostenido | Carga de producción | Latencia < umbral target **[SME-PENDING]** |
| TC-12 | pcelular_alterno vs celular en suscriptores | pcelular_alterno='5512345678' | ¿Cuál prevalece? **[SME-PENDING]** |

### Criterios de aceptación de equivalencia

- **Código de retorno**: idéntico en el 100% de los casos
- **Registros en tabla de eventos**: mismo número de registros, mismos valores clave
- **Notificaciones enviadas a Latinia**: misma cantidad ± 0% (no se permite diferencia)
- **MONEY rounding**: comparación centavo a centavo — cero diferencias aceptadas
- **Latencia p99**: ≤ latencia actual Informix + 20% (SLA del canal)

## TS-D09-02 · Pruebas de confirmación SMS

| ID | Escenario | Input | Resultado esperado |
|----|-----------|-------|-------------------|
| TC-SMS-01 | Código correcto 6 dígitos | pCodigo=válido | Validación exitosa |
| TC-SMS-02 | Código expirado | pCodigo=válido pero >N min | Error de expiración |
| TC-SMS-03 | Código incorrecto 3 intentos | pCodigo=incorrecto ×3 | Bloqueo **[SME-PENDING]** |
| TC-SMS-04 | Variante BPI2 vs estándar | sp_confirmasmscte_bpi2 | Diferencias de comportamiento **[SME-PENDING]** |

## TS-D09-03 · Pruebas de procesos batch (ver 11-batch)

| ID | Proceso | Criterio de equivalencia |
|----|---------|--------------------------|
| TC-BATCH-01 | sp_depura_mensajes | Mismos registros borrados, misma cuenta en mnsj_errores |
| TC-BATCH-02 | sp_suscriptores_act | Mismo payload enviado a Latinia API |
| TC-BATCH-03 | sp_mover_mensajes | Mismos registros movidos a histórico |

## Plan de ejecución de pruebas

```
Semana 1: Captura del golden master en producción (sin cambios)
Semana 2: Configurar ambiente de pruebas paralelo
Semana 3: Ejecutar TC-01 a TC-12 con datos reales (anonimizados PII)
Semana 4: Parallel-run: ambos sistemas reciben el mismo tráfico
          → comparar outputs en tiempo real
Semana 5: Sign-off de Tesorería + Domain Expert BanCoppel
Semana 6: Cutover (ventana de mantenimiento nocturna)
```

## Riesgo de prueba: MONEY rounding

`sp_registra_evento` recibe `pImporte1..5 MONEY(16,2)`. En el target PostgreSQL:

```
-- Caso crítico: ¿se redondea antes o después de insertar?
pImporte1 = 100.005

Informix MONEY: almacena 100.00 o 100.01 (half-even → 100.00)
PostgreSQL NUMERIC: almacena 100.01 (half-up por defecto)

→ Diferencia de $0.01 por transacción × miles de eventos/día = discrepancia contable
```

**Mitigación**: configurar `RoundingMode.HALF_EVEN` en la capa Java antes de invocar cualquier operación NUMERIC.

---
*Generado por: Specialist — Informix SPL Analysis + QA Lead Equivalencia · 2026-07-03*
