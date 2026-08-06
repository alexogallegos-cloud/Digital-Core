# Risk Register — BCOPCore Migración
> **Proyecto**: BanCoppel BCOPCore · SPE-AM-001
> **Sistema**: IBM Informix IDS 14.10 / POWER-AIX → AWS Aurora PostgreSQL
> **DT responsable**: dt-riesgos · `BCOPCore/dt/dt-riesgos/`
> **Versión**: 1.2.0
> **Última actualización**: 2026-08-03

---

## Niveles de riesgo

| Nivel | Etiqueta | Criterio | Bloquea |
|-------|----------|----------|---------|
| N5 | DEFECTO-PROD 🔴 | Defecto activo en producción con impacto financiero o regulatorio directo | Avance a BUILD/DESIGN |
| N4 | CRÍTICO 🔴 | Riesgo que puede causar pérdida de datos o incumplimiento regulatorio en cutover | Avance a RELEASE |
| N3 | ALTO 🟠 | Riesgo operacional significativo; requiere plan de mitigación antes de TEST | Avance a TEST |
| N2 | MEDIO 🟡 | Riesgo conocido con workaround disponible | Documentar antes de cutover |
| N1 | BAJO 🟢 | Riesgo menor; monitorear | Ninguno |

**Regla de bloqueo**: cualquier riesgo N4-N5 sin plan de mitigación aprobado bloquea el avance de fase. El DT-Riesgos emite BLOQUEO formal antes de iniciar la fase siguiente.

---

## Resumen ejecutivo

| Nivel | Total | Abiertos | Cerrados |
|-------|-------|----------|---------|
| N5 | 2 | 2 🔴 | 0 |
| N4 | 1 | 1 🔴 | 0 |
| N3 | 5 | 5 🟠 | 0 |
| N2 | 3 | 3 🟡 | 0 |
| N1 | 0 | 0 | 0 |
| **Total** | **11** | **11** | **0** |

> Los 44 riesgos de los archivos `05-risks.md` por dominio son riesgos de equivalencia de migración (código). Este registro contiene riesgos **de producción y de integración** descubiertos por análisis de logs y código fuente.

---

## Riesgos N5 — DEFECTO-PROD (bloquean DESIGN)

### P655-R001

| Campo | Valor |
|-------|-------|
| **ID** | P655-R001 |
| **Categoría** | TAR |
| **Nivel** | N5 🔴 DEFECTO-PROD |
| **Dominio** | D01-bdicnweb |
| **Estado** | ABIERTO |
| **Bloquea** | Avance a DESIGN |
| **SME validador** | Core Banking Transformation + SRE & AIOps |

**Descripción**: Defecto activo en producción en el componente P655 / D01-bdicnweb. Detalles pendientes de sesión de diagnóstico con DBA IBM Informix y Core Banking.

**Estado en DISCOVER (AS-IS):** No bloquea el análisis AS-IS en curso. El diagnóstico se difiere a la entrada de DESIGN, donde el equipo target necesitará saber exactamente qué corregir para no replicar el defecto en el sistema migrado.

**Dependencia DESIGN:** antes de iniciar cualquier ADR o diseño de arquitectura target de D01-bdicnweb, este riesgo debe tener causa raíz documentada y fix validado por DBA IBM Informix.

**Mitigación**: Agendar sesión DBA IBM Informix + Core Banking Transformation al cierre de DISCOVER — antes del gate de entrada a DESIGN.

---

### P655-R002

| Campo | Valor |
|-------|-------|
| **ID** | P655-R002 |
| **Categoría** | TAR |
| **Nivel** | N5 🔴 DEFECTO-PROD |
| **Dominio** | D01-bdicnweb |
| **Estado** | ABIERTO |
| **Bloquea** | Avance a DESIGN |
| **SME validador** | Core Banking Transformation + SRE & AIOps |

**Descripción**: Segundo defecto activo en producción en el componente P655 / D01-bdicnweb. Detalles pendientes de sesión de diagnóstico.

**Estado en DISCOVER (AS-IS):** No bloquea el análisis AS-IS en curso. Mismo tratamiento que P655-R001 — diagnóstico diferido a entrada de DESIGN.

**Dependencia DESIGN:** ambos riesgos (R001 + R002) son pre-requisito del gate DISCOVER → DESIGN para el dominio D01-bdicnweb.

**Mitigación**: Resolver en la misma sesión que P655-R001 — agendar al cierre de DISCOVER.

---

## Riesgos N4 — CRÍTICO (bloquean RELEASE)

### P655-R009

| Campo | Valor |
|-------|-------|
| **ID** | P655-R009 |
| **Categoría** | CMP |
| **Nivel** | N4 🔴 CRÍTICO |
| **Dominio** | D11-bdicobranza |
| **SP afectado** | `sp_obtener_datos_cv_web` |
| **Estado** | ABIERTO |
| **Bloquea** | Avance a RELEASE (Wave D11) |
| **SME validador** | DBA IBM Informix + Core Banking Transformation |
| **Fecha de detección** | 2026-08-01 |
| **Fuente** | Lectura directa de código fuente + comparación con SP base |

**Descripción**: La versión `_web` del SP declara `cCodRet` como `CHAR(5)`, mientras que el SP base `sp_obtener_datos_cv` lo declara correctamente como `CHAR(6)`. El sub-SP llamado `sp_consulta_saldos_general` retorna su primer campo como `CHAR(6)` — confirmado en `bdicred_sp_consulta_saldos_general.sql` línea 3: `CHAR(6) AS codigo_retorno`. Al asignarse una cadena de 6 caracteres a una variable de 5, Informix trunca el último carácter silenciosamente:

| Código real retornado (CHAR 6) | Almacenado en `cCodRet` (CHAR 5) | Interpretado como |
|---|---|---|
| `'000000'` éxito | `'00000'` | éxito ✓ |
| `'000001'` sin datos | `'00000'` | éxito — INCORRECTO |
| `'000002'` error datos | `'00000'` | éxito — INCORRECTO |
| `'000003'` sin deuda vencida | `'00000'` | éxito — INCORRECTO |

Cuando `sp_consulta_saldos_general` devuelve cualquier código de error, la versión `_web` lo interpreta como éxito. Procede a evaluar campos financieros que quedaron en 0 (vacíos por el error del sub-SP), la condición `dSaldoVencido <= 0` es verdadera, y el SP retorna `cCodRet = '00003'`. Caja2 registra `'00003'` como respuesta de error/vacía.

**Evidencia de producción**: 51,043 llamadas/día · 97.37% error · `error_catalog: []` (ningún código llega a `errores_bus`). El SP hermano `sp_registro_ctetitular_cv_web` (escritura, sin sub-SP cross-DB) tiene 0% de error — confirma que el problema es exclusivamente en la cadena de lectura.

**Fix puntual**: cambiar `DEFINE cCodRet CHAR(5)` → `CHAR(6)` en `sp_obtener_datos_cv_web` y ajustar todos los literales de código de negocio de 5 a 6 dígitos (`'00000'`→`'000000'`, `'00001'`→`'000001'`, etc.). Este fix existe ya compilado en `sp_obtener_datos_cv` (la versión sin `_web`).

**Impacto en migración**: en el target, si se transpone el SP sin corregir este defecto, el módulo de cobranza web del target replicará el fallo. La Wave D11 no puede iniciar parallel-run hasta que el fix esté aplicado y verificado.

**Mitigación**:
1. Sesión DBA Informix: ejecutar `sp_obtener_datos_cv_web` con un cliente con deuda vencida conocida y trazar `cCodRet` justo después del EXECUTE de `sp_consulta_saldos_general`
2. Aplicar el fix (CHAR(5)→CHAR(6)) en el ambiente de pruebas y verificar que la tasa de error cae por debajo de 5%
3. Documentar en `ADR-SPE-AM-006` como caso de tipo propietario SPL con truncación silenciosa

---

## Riesgos N3 — ALTO (requieren plan de mitigación antes de TEST)

### P655-R003

| Campo | Valor |
|-------|-------|
| **ID** | P655-R003 |
| **Categoría** | TAR |
| **Nivel** | N3 🟠 ALTO |
| **Dominio** | D05-bdisac (integración `ifx_bdisac_remesas`) |
| **Estado** | ABIERTO |
| **Bloquea** | Avance a TEST (Wave 3) |
| **SME validador** | Core Banking Transformation + SRE & AIOps |
| **Fecha de detección** | 2026-08-01 |
| **Fuente** | Análisis de logs `transacciones_bus_20260424_*` |

**Descripción**: El servicio `RemesasAPPRIZAAutomaticas` llama a `sp_app_confirmpayment` 61,280 veces por día para confirmar remesas internacionales vía APPRIZA. El **8.7% (5,163 transacciones/día)** recibe código de respuesta `9999` de APPRIZA ("La operación ha terminado de manera incorrecta debido a un error inesperado"), dejando esas remesas en estado no confirmado.

**Evidencia de los logs**:

```
# Llamada exitosa (APPRIZA devuelve 0000):
call informix.sp_app_confirmpayment('BCL','004','22e4e9ee-...',
  '20260424','080037','0000','Operación completada.','P000',
  'La Operación ha sido realizada.','20260424','080136','911434372858','458521317',...)
|| {"CodRetorno":"00000","Desc_Error":"CONFIRMACION CFPA EXITOSA",...}

# Llamada fallida (APPRIZA devuelve 9999):
call informix.sp_app_confirmpayment('BCL','004','22e4e9ee-...',
  '20260424','080044','9999',
  'La operación ha terminado de manera incorrecta debido a un error inesperado...',...)
estatus: error
```

**Hallazgo adicional**: El UUID de sesión `22e4e9ee-32ea-484e-b89f-2573549bc625` es idéntico en TODAS las llamadas automáticas (éxitos y errores). En un sistema transaccional, cada pago debería tener un correlation ID único. Esto indica que el proceso automático de remesas usa un token de sesión fijo (batch token) — lo que puede causar race conditions y fallos de idempotencia si APPRIZA invalida o expira ese token.

**Riesgos secundarios relacionados**:
- `RemesasAPPRIZACanalesExternos` tiene además SSL timeouts de ~30s (código ESB 3166, 7 instancias en hora 09:00) — problema de conectividad o certificado SSL con APPRIZA
- Los timeouts y los 9999 son independientes pero suman al riesgo total de la integración

**Impacto en migración**:
- En la Wave 3 (D05-bdisac), si el target replica la misma integración sin resolver esta inestabilidad, el parallel-run mostrará divergencias sistemáticas en el 8.7% de las remesas
- El SP `sp_app_confirmpayment` no tiene DSN prefix en el log — su base de datos host no está en el mapeo actual de brain.db; se requiere identificar a qué BD pertenece

**Plan de mitigación**:
1. **Inmediato (producción actual)**: Confirmar con BanCoppel si los 5,163 fallos diarios son conocidos y si existe proceso de retry/reconciliación manual
2. **Diseño target**: Implementar circuit breaker (Spring Resilience4j) con retry exponencial para llamadas a APPRIZA
3. **UUID de sesión**: Validar con APPRIZA si el token compartido es un bug o el diseño de autenticación para el proceso batch
4. **SSL**: Verificar vigencia del certificado de la integración APPRIZA (timeouts ~30s → certificado expirado o rotación pendiente)
5. **Idempotencia**: Diseñar compensating transaction — si APPRIZA no confirma en N intentos, registrar en tabla de reconciliación para proceso nocturno

---

### P655-R004

| Campo | Valor |
|-------|-------|
| **ID** | P655-R004 |
| **Categoría** | TAR |
| **Nivel** | N3 🟠 ALTO |
| **Dominio** | PSQL-huellas (fuera de BCOPCore — target ya migrado) |
| **Estado** | ABIERTO |
| **Bloquea** | Avance a TEST (referencia) |
| **SME validador** | SRE & AIOps + Cybersecurity |
| **Fecha de detección** | 2026-08-01 |
| **Fuente** | Análisis de logs `errores_bus_20260424_*` |

**Descripción**: El servicio `Huellas442` (`postg_huellasemps`) ya migró a PostgreSQL pero produce una `NullPointerException` cada ~60 segundos (código ESB 4395). Se registran **3,979 errores por día**. El bug está en `com.bancoppel.huellas.clientes.consulta_template_clientes` línea 36.

```
Unhandled exception in plugin method ||
java.lang.NullPointerException ||
com.bancoppel.huellas.clientes.consulta_template_clientes.consultaTemplateClientes(consulta_template_clientes.java:36)
```

**Relevancia para migración**: Evidencia concreta de que el primer servicio migrado a PostgreSQL tiene un bug en producción que nadie ha reportado formalmente. Señal de alerta para el proceso de QA del target.

**Mitigación**: Abrir ticket con el equipo de Huellas442; el bug debe resolverse antes de que BCOPCore inicie parallel-run (cualquier servicio que consulte huellas durante parallel-run recibirá NPEs intermitentes).

---

### P655-R005

| Campo | Valor |
|-------|-------|
| **ID** | P655-R005 |
| **Categoría** | TAR |
| **Nivel** | N3 🟠 ALTO |
| **Dominio** | Todas las integraciones externas via ESB |
| **Estado** | ABIERTO |
| **Bloquea** | Avance a RELEASE |
| **SME validador** | SRE & AIOps |
| **Fecha de detección** | 2026-08-01 |
| **Fuente** | Análisis de logs `errores_bus_20260424_*` |

**Descripción**: Los logs del ESB revelan 5 códigos de error nuevos no documentados en los runbooks actuales:

| Código | Frecuencia/día | Descripción |
|--------|---------------|-------------|
| 4394 | 2,452 | IBM MQ MbUserException — fallo de mensajería interna |
| 3743 | 761 | SOAP Handle Timed-out (~30s) |
| 3701 | 356 | JNI/Axis2 non-SOAP call error |
| 3165 | 320 | SSL socket error on connect |
| 6233 | 264 | Sin descripción disponible |

Ninguno de estos errores está documentado en los `06-exceptions.md` actuales. En el target, estos errores del middleware pueden manifestarse diferente y requerir mapeo explícito.

**Mitigación**: Documentar en `06-exceptions.md` de los dominios afectados antes del cutover; mapear los códigos ESB a excepciones del target middleware (MSK/Lambda).

---

### P655-R010

| Campo | Valor |
|-------|-------|
| **ID** | P655-R010 |
| **Categoría** | TAR |
| **Nivel** | N3 🟠 ALTO |
| **Dominio** | D11-bdicobranza |
| **SP afectado** | `sp_obtener_datos_cv_web`, `sp_obtener_datos_cv` |
| **Estado** | ABIERTO |
| **Bloquea** | Avance a TEST (Wave D11) |
| **SME validador** | DBA IBM Informix + SRE & AIOps |
| **Fecha de detección** | 2026-08-01 |
| **Fuente** | Lectura directa de código fuente |

**Descripción**: Ambas versiones del SP (`_web` y base) implementan un bloque `ON EXCEPTION` que captura cualquier excepción SQL y retorna `cCodRet = iSqlErr` con los 11 campos restantes vacíos. El valor `iSqlErr` es el código numérico interno de Informix (ej. `-243` lock timeout, `100` NOT FOUND, `-206` tabla no existe) — no es un código de negocio y nunca llega a `errores_bus`.

```sql
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    LET cCodRet = iSqlErr;   -- código SQL numérico, p.ej. -243
    RETURN cCodRet,'','','','','','','','','','','';
END EXCEPTION;
```

Este patrón implica que cualquier excepción en la cadena de 6 queries cross-DB y 3 sub-SPs que ejecuta el SP retorna respuesta vacía sin ningún registro observable — confirmado por `error_catalog: []` y `top_resp_codes: {}` en los logs de producción de D11.

**Impacto en migración**: el target debe implementar manejo de excepciones observable (structured logging, correlation ID, error catalog) en sustitución de este patrón. Sin esto, el parallel-run del módulo de cobranza será ciego a errores de integración.

**Mitigación**:
1. En el análisis del target: prohibir el patrón `ON EXCEPTION → RETURN vacío` — reemplazar con logging estructurado + código de negocio explícito
2. Documentar en `ADR-SPE-AM-006` como antipatrón SPL a eliminar en transpilación
3. El Specialist — Code Quality Assessment debe marcar este patrón como CWE-390 (Detection of Error Condition Without Action) en todos los SPs del scope

---

### P655-R011

| Campo | Valor |
|-------|-------|
| **ID** | P655-R011 |
| **Categoría** | CMP |
| **Nivel** | N3 🟠 ALTO |
| **Dominio** | D11-bdicobranza |
| **SP afectado** | `sp_obtener_datos_cv_web`, `sp_obtener_datos_cv` |
| **Estado** | ABIERTO — pendiente verificación DBA |
| **Bloquea** | Avance a TEST (Wave D11) |
| **SME validador** | DBA IBM Informix |
| **Fecha de detección** | 2026-08-01 |
| **Fuente** | Lectura directa de código fuente |

**Descripción**: La llamada al sub-SP `sp_consulta_saldocortemin` tiene un espacio entre el prefijo de base de datos y el owner que no aparece en las otras dos llamadas cross-DB del mismo SP:

```sql
-- Correcto (líneas 246 y 252):
EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(...)
EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(...)

-- Con espacio (línea 261 en _web / línea 250 en _cv):
EXECUTE PROCEDURE bdicred: "informix".sp_consulta_saldocortemin(...)
```

El espacio entre `bdicred:` y `"informix"` es inconsistente. Dependiendo de la versión exacta del parser SPL de Informix IDS 14.10, esto puede: (a) ignorarse como whitespace sin impacto, o (b) causar una excepción de resolución de nombre en runtime que el `ON EXCEPTION` captura silenciosamente. Si (b), `dImpSdoTotalCS` (saldo de corte mínimo) siempre queda en 0, y el importe mostrado al agente de cobranza es incorrecto.

**Impacto en migración**: si la cause (b) aplica, la transpilación al target replica un cálculo incorrecto de saldo de corte. El parallel-run detectaría divergencias en `cDesc6` (campo que porta `dImpSdoTotalCS`).

**Mitigación**:
1. Verificar en sesión DBA: ejecutar `EXECUTE PROCEDURE bdicred: "informix".sp_consulta_saldocortemin('001','<num_credito>', 0)` directamente desde dbaccess y observar si produce error o retorno normal
2. Si es (b): corregir el espacio en ambas versiones del SP antes de la Wave D11
3. Si es (a): documentar como hallazgo cosmético y marcar CERRADO

---

## Riesgos N2 — MEDIO (documentar antes de cutover)

### P655-R006

| Campo | Valor |
|-------|-------|
| **ID** | P655-R006 |
| **Categoría** | CMP |
| **Nivel** | N2 🟡 MEDIO |
| **Dominio** | D02-bdinteg (autenticación), PSQL-huellas |
| **Estado** | ABIERTO |
| **SME validador** | Cybersecurity |
| **Fecha de detección** | 2026-08-01 |

**Descripción**: `sp_consulta_huella_actual` es el SP más llamado del sistema con 205,079 llamadas/día — es el punto de entrada de autenticación biométrica de TODOS los servicios. La tabla `si_cte_huella` en bdinteg es stale (Huellas migró a PostgreSQL `postg_huellasemps`). Hay riesgo de divergencia entre el inventario de huellas en Informix y el stock real en PostgreSQL.

---

### P655-R007

| Campo | Valor |
|-------|-------|
| **ID** | P655-R007 |
| **Categoría** | CMP |
| **Nivel** | N2 🟡 MEDIO |
| **Dominio** | Infraestructura ESB |
| **Estado** | ABIERTO |
| **SME validador** | SRE & AIOps |
| **Fecha de detección** | 2026-08-01 |

**Descripción**: `ACEPTPORTA` (`PrestamoNominaExpedienteDigital`) falla **3,244 veces/día** con error SFTP 3381: "password authentication credentials invalid || sysportabnominaapp". Credenciales de SFTP para descarga de expedientes digitales inválidas o expiradas. No está documentado como incidente conocido.

---

### P655-R008

| Campo | Valor |
|-------|-------|
| **ID** | P655-R008 |
| **Categoría** | TAR |
| **Nivel** | N2 🟡 MEDIO |
| **Dominio** | D05-bdisac, D10-bdisuc, otros (dominios `???`) |
| **Estado** | ABIERTO |
| **SME validador** | Specialist — Informix SPL Analysis |
| **Fecha de detección** | 2026-08-01 |

**Descripción**: El análisis de logs identificó **632 SPs llamados desde el ESB** de los 10,144 en brain.db (6.2%). Sin embargo, 8 de los top-30 SPs por volumen tienen dominio `???` — no tienen prefijo DSN en la trama y no están mapeados al esquema de 12 dominios actual. Posibles candidatos: `bdiadminnomina` u otras BDs no incluidas en el scope inicial.

| SP sin dominio | Llamadas/día |
|----------------|-------------|
| `sp_obtenerfechahoy` | 161,665 |
| `sp_obtenernumproducto` | 82,999 |
| `sp_val_clubproteccion_web` | 56,729 |
| `sp_app_recordorder` | 56,626 |
| `sp_app_getorder` | 55,126 |
| `sp_obtengrupocliente` | 51,600 |
| `sp_obtenerparametro` | 42,981 |
| `sp_retiro_sd` | 41,286 |

**Mitigación**: Identificar a qué BD pertenecen estos SPs; actualizar el mapeo DSN en `analyze-logs.py` y `KNOWLEDGE-MANIFEST.json`.

---

## Historial de cambios

| Versión | Fecha | Cambio |
|---------|-------|--------|
| 1.0.0 | 2026-07-31 | Creación — P655-R001 y P655-R002 registrados (pre-existentes en KNOWLEDGE-MANIFEST) |
| 1.1.0 | 2026-08-01 | P655-R003 a R008 — hallazgos de análisis de logs producción 2026-04-24 |
| 1.2.0 | 2026-08-01 | P655-R009 a R011 — D11-bdicobranza análisis de código fuente `bdicobranza_sp_obtener_datos_cv_web.sql` vs `bdicred_sp_consulta_saldos_general.sql`; causa raíz del 97.4% error rate: type mismatch CHAR(5)/CHAR(6); + silent exception swallowing + space en cross-DB call |

---

*Mantenido por: DT-Riesgos · `BCOPCore/dt/dt-riesgos/CLAUDE.md`*
*Fuente primaria validada: `source/logs/` (producción 2026-04-24) + `source/BCOPCore/informix/*.sql`*
