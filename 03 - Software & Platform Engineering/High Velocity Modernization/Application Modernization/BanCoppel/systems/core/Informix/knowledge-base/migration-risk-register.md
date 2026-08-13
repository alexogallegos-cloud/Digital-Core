# Risk Register — Informix Migración
> **Proyecto**: BanCoppel Informix · SPE-AM-001
> **Sistema**: IBM Informix IDS 14.10 / POWER-AIX → AWS Aurora PostgreSQL
> **DT responsable**: dt-riesgos · `Informix/dt/dt-riesgos/`
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
| N5 | 5 | 5 🔴 | 0 |
| N4 | 4 | 4 🔴 | 0 |
| N3 | 5 | 5 🟠 | 0 |
| N2 | 3 | 3 🟡 | 0 |
| N1 | 0 | 0 | 0 |
| **Total** | **17** | **17** | **0** |

> Los 44 riesgos de los archivos `05-risks.md` por dominio son riesgos de equivalencia de migración (código). Este registro contiene riesgos **de producción y de integración** descubiertos por análisis de logs, código fuente, y el diagnóstico arquitectónico de la capa de autorización (Autorizador / e-global).

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
| **Dominio** | PSQL-huellas (fuera de Informix — target ya migrado) |
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

**Mitigación**: Abrir ticket con el equipo de Huellas442; el bug debe resolverse antes de que Informix inicie parallel-run (cualquier servicio que consulte huellas durante parallel-run recibirá NPEs intermitentes).

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

## Riesgos Autorizador / e-Global (N5 y N4 — bloquean RELEASE de la wave de pagos)

> Fuente: diagnóstico arquitectónico enero 2026 (post-incidentes Nov-Dic 2025) + análisis de incidentes INC-20251129 a INC-20260112 + volumetría Excel `source/spei-aut-ent/`.

### P655-R012

| Campo | Valor |
|-------|-------|
| **ID** | P655-R012 |
| **Categoría** | TAR |
| **Nivel** | N5 🔴 CRÍTICO |
| **Dominio** | Autorizador Java (capa externa — e-global) |
| **Estado** | ABIERTO |
| **Bloquea** | RELEASE de la wave del Autorizador |
| **SME validador** | Integration Architecture + DBA IBM Informix |
| **Fecha de detección** | 2026-08-07 |
| **Fuente** | Diagnóstico arquitectónico enero 2026 + INC-20260112 |

**Descripción**: El Autorizador Java tiene **25 conexiones directas a Informix sin pool de conexiones y sin mecanismo de self-healing**. Cuando las 25 conexiones se agotan, el Autorizador no puede abrir nuevas conexiones de forma autónoma. El único mecanismo de recuperación disponible es el **reinicio manual** del Autorizador (ejecutado 5 veces el 31-DIC-2025). El INC-20260112 confirmó que el connection leak es sistémico: el sistema falló con Load Average de 50% porque el leak agotó todas las conexiones sin carga extraordinaria.

**Evidencia**: 7 incidentes Nov-2025 a Ene-2026; INC-20260112 (p15 E-Global, 50% Load, 6.58h de degradación).

**Impacto en migración**: si el Autorizador Java se conecta al nuevo backend (Aurora PostgreSQL + microservicios) sin haber corregido el connection leak + sin pool, el comportamiento se replica exactamente. El target heredará el mismo patrón de fallos.

**Mitigación**:
1. Implementar HikariCP (o equivalente) en el Autorizador Java como prerequisito de BUILD
2. Configurar pool con: `minimumIdle=5`, `maximumPoolSize=50`, `connectionTimeout=3000ms`, `idleTimeout=600000ms`, `maxLifetime=1800000ms`
3. Test de leak: 72 horas sostenidas a carga P95 sin reinicios manuales — prerequisito de RELEASE
4. Instrumentar métrica de conexiones activas en pool como SLO operacional (alerta si > 80% durante > 5 min)

---

### P655-R013

| Campo | Valor |
|-------|-------|
| **ID** | P655-R013 |
| **Categoría** | TAR |
| **Nivel** | N5 🔴 CRÍTICO |
| **Dominio** | SPEI AIX — capa de infraestructura |
| **Estado** | ABIERTO |
| **Bloquea** | RELEASE de la wave SPEI |
| **SME validador** | SRE & AIOps + Core Banking Transformation |
| **Fecha de detección** | 2026-08-07 |
| **Fuente** | Diagnóstico arquitectónico enero 2026 |

**Descripción**: El sistema SPEI en AIX **forkea hasta 72 procesos** para procesar volumen de quincena / aguinaldo, versus 1-5 procesos en operación nominal. Este forking masivo satura el sistema operativo AIX y el disco hdisk3 (100% I/O wait observado en INC-20251215). El forking no es controlado — crece sin límite en función del volumen entrante.

**Evidencia**: INC-20251215 (hdisk3 100% I/O wait con SPEI p99, 7.5h de degradación).

**Impacto en migración**: el target (microservicios Java en Aurora PostgreSQL / AWS EKS) debe manejar spikes de SPEI sin forking OS. Aurora PostgreSQL + HPA en EKS distribuye la carga horizontalmente, pero el microservicio SPEI debe tener autoscaling configurado con límites explícitos antes de RELEASE.

**Mitigación**:
1. En el target: configurar HPA para el microservicio SPEI con `targetCPUUtilizationPercentage: 70`, `minReplicas: 2`, `maxReplicas: 20`
2. Test de spike: inyectar 32,000 txn/min (el máximo absoluto observado en 18-DIC-2025 — aguinaldo) en el microservicio SPEI target y validar que no hay degradación de latencia
3. Load test con perfil quincena (gradual p50 → p99 en 15 min) durante el parallel-run

---

### P655-R014

| Campo | Valor |
|-------|-------|
| **ID** | P655-R014 |
| **Categoría** | TAR |
| **Nivel** | N4 🔴 CRÍTICO |
| **Dominio** | Autorizador Java (capa externa) |
| **Estado** | ABIERTO |
| **Bloquea** | RELEASE de la wave del Autorizador |
| **SME validador** | Integration Architecture |
| **Fecha de detección** | 2026-08-07 |
| **Fuente** | Diagnóstico arquitectónico enero 2026 |

**Descripción**: La capa del Autorizador no tiene **load balancing**. Una sola instancia del Autorizador atiende todo el tráfico. Si la instancia falla o se satura, no hay failover automático. La única instancia configura 25 conexiones directas (riesgo P655-R012) — si el volumen supera la capacidad (3,240 txn/min), no hay segunda instancia que absorba el exceso.

**Impacto en migración**: el target debe desplegar al menos 2 instancias activas del Autorizador con load balancer delante. El patrón AS-IS de instancia única es un SPOF que no puede replicarse en el target.

**Mitigación**:
1. Desplegar mínimo 2 instancias del Autorizador con AWS ALB o Kubernetes Service balanceando tráfico round-robin
2. Test de failover: terminar una instancia durante carga P95 y validar que la segunda absorbe el tráfico sin incidente
3. Documentar en `ADR-SPE-AM-008` la estrategia de deployment del Autorizador modernizado

---

### P655-R015

| Campo | Valor |
|-------|-------|
| **ID** | P655-R015 |
| **Categoría** | TAR |
| **Nivel** | N4 🔴 CRÍTICO |
| **Dominio** | AIX + HSM (Firma Digital) |
| **Estado** | ABIERTO |
| **Bloquea** | RELEASE de cualquier wave que use Firma Digital |
| **SME validador** | Cybersecurity + SRE & AIOps |
| **Fecha de detección** | 2026-08-07 |
| **Fuente** | Diagnóstico arquitectónico enero 2026 |

**Descripción**: La **Firma Digital / HSM** es un bottleneck síncrono en la cadena de autorización. Cuando el forking de SPEI (P655-R013) satura AIX, la Firma Digital se convierte en el cuello de botella entre el OS y el OLTP de Informix. El HSM procesa operaciones criptográficas en cola secuencial sin paralelismo visible, lo que lleva el sistema operativo a 100% de utilización.

**Impacto en migración**: el target debe evaluar si la Firma Digital puede operarse de forma asíncrona o si se puede aumentar el throughput del HSM. Si el HSM sigue siendo síncrono y secuencial, el target replica el bottleneck aunque Aurora PostgreSQL sea más rápido.

**Mitigación**:
1. Consultar con Cybersecurity SME: ¿la Firma Digital puede paralelizarse? ¿el HSM tiene capacidad de procesar en batch o de forma asíncrona?
2. Evaluar HSM de alta disponibilidad (multi-instance) para el target
3. Si el HSM no puede paralelizarse, documentar como restricción regulatoria y dimensionar el target para que el throughput del HSM sea el límite explícito del SLA (no una sorpresa en producción)

---

### P655-R016

| Campo | Valor |
|-------|-------|
| **ID** | P655-R016 |
| **Categoría** | TAR |
| **Nivel** | N4 🔴 CRÍTICO |
| **Dominio** | e-Global ↔ target (SLA de integración) |
| **Estado** | ABIERTO |
| **Bloquea** | RELEASE de la wave del Autorizador |
| **SME validador** | Integration Architecture + Industry Payments |
| **Fecha de detección** | 2026-08-07 |
| **Fuente** | Diagnóstico arquitectónico enero 2026 |

**Descripción**: e-Global tiene un SLA estricto de **8 segundos de round-trip** — si el backend no responde en 8 segundos, e-Global cancela la transacción automáticamente sin posibilidad de retry. El sistema AS-IS frecuentemente supera este SLA en días de alta carga (INC-20251129, 69.71% de transacciones canceladas). El target debe garantizar que el nuevo backend responde en ≤ 4 segundos en P95 para mantener un margen de seguridad del 50%.

**Evidencia**: INC-20251129 ($663 MDP, 69.71% declinadas), INC-20251215 (7.5h), INC-20251223 (23 min).

**Impacto en migración**: si la latencia del nuevo backend Aurora PostgreSQL + microservicios es mayor que el legacy Informix bajo carga moderada, el SLA de e-Global se violará y las transacciones se cancelarán exactamente igual que en los incidentes. La latencia del target no puede "ser aceptable en promedio" — debe cumplir en P95.

**Mitigación**:
1. Definir SLO del target: latencia P95 ≤ 4s en el path completo e-Global → microservicio → Aurora PostgreSQL → respuesta
2. Test de latencia P95 en el parallel-run con carga P95 de E-Global (3,400 txn/min)
3. Implementar timeout en el microservicio objetivo de 6 segundos (dejando 2s de overhead de red antes del límite de e-Global)

---

### P655-R017

| Campo | Valor |
|-------|-------|
| **ID** | P655-R017 |
| **Categoría** | TAR |
| **Nivel** | N5 🔴 CRÍTICO |
| **Dominio** | e-Global (connection leak sistémico) |
| **Estado** | ABIERTO |
| **Bloquea** | RELEASE de la wave del Autorizador |
| **SME validador** | Integration Architecture + DBA IBM Informix |
| **Fecha de detección** | 2026-08-07 |
| **Fuente** | INC-20251223 + INC-20260112 |

**Descripción**: El **connection leak de e-Global** fue identificado el 23-DIC-2025 y confirmado como sistémico el 12-ENE-2026. Las 25 conexiones directas del Autorizador a Informix no se liberan correctamente al finalizar las transacciones. Para enero 2026, el leak se acumulaba incluso con volumen en percentil 15 — el sistema llegaba a agotamiento de conexiones sin carga extraordinaria.

**Evidencia**: INC-20260112 — 6.58 horas de degradación con Load Average de 50% y E-Global p15. Sin fix de código aplicado entre 23-DIC-2025 y 12-ENE-2026.

**Impacto en migración**: si el connection leak existe en el código del Autorizador Java (no en Informix), el leak **se replicará contra el nuevo backend Aurora PostgreSQL**. El comportamiento será idéntico: el Autorizador agotará el pool de conexiones al nuevo backend y fallará. Resolver R012 (pool de conexiones) mitiga parcialmente el impacto pero no elimina el leak subyacente.

**Mitigación**:
1. Identificar la línea de código en el Autorizador Java que causa el leak (conexión que se abre pero no se cierra en el finally block, o que se cierra solo en el happy path)
2. Fix de código + test de leak: 72 horas sostenidas a carga P50 sin incremento de conexiones activas
3. R012 (HikariCP pool) es prerequisito — con pool, el leak produce reconexión automática en lugar de fallo total. Sin pool, el leak sigue siendo N5
4. Este fix es prerequisito de entrar al parallel-run — no puede detectarse durante el parallel-run

---

## Historial de cambios

| Versión | Fecha | Cambio |
|---------|-------|--------|
| 1.0.0 | 2026-07-31 | Creación — P655-R001 y P655-R002 registrados (pre-existentes en KNOWLEDGE-MANIFEST) |
| 1.1.0 | 2026-08-01 | P655-R003 a R008 — hallazgos de análisis de logs producción 2026-04-24 |
| 1.2.0 | 2026-08-01 | P655-R009 a R011 — D11-bdicobranza análisis de código fuente `bdicobranza_sp_obtener_datos_cv_web.sql` vs `bdicred_sp_consulta_saldos_general.sql`; causa raíz del 97.4% error rate: type mismatch CHAR(5)/CHAR(6); + silent exception swallowing + space en cross-DB call |
| 1.3.0 | 2026-08-07 | P655-R012 a R017 — diagnóstico arquitectónico capa Autorizador/e-global (enero 2026 post-incidentes Nov-Dic 2025); connection leak sistémico (R012, R017), SPEI forking (R013), sin load balancing (R014), Firma Digital bottleneck (R015), SLA e-Global 8s (R016) |
| 1.4.0 | 2026-08-07 | Actualización de estados R012-R017 — 11 mejoras ejecutadas en 2026 (enero-julio); R017 CERRADO (2.5 connection leak fix), R015 CERRADO para SPEI (3.1 firma extraída), R013/R016 MITIGADOS para producción; R012/R014 PARCIALMENTE MITIGADOS (pendiente AUT-DR-05/06/07) |

---

## Estado post-mejoras 2026 (P655-R012 a R017)

> Fuente: `knowledge-base/autorizador/mejoras-2026.md` — 11 hitos completados entre enero y julio 2026.

| ID | Estado actualizado | Mejora que lo resuelve | DATO-REQUERIDO pendiente |
|----|-------------------|------------------------|--------------------------|
| P655-R012 | 🟡 PARCIALMENTE MITIGADO — leak corregido (2.5), sin evidencia de pool formal | Hito 2.5 (Connection Leak fix) | AUT-DR-05 |
| P655-R013 | 🟢 MITIGADO para producción — balanceo automático + firma extraída + Power 10 | Hitos 3.6, 3.1, 1.4 | Validar en target |
| P655-R014 | 🟡 PARCIALMENTE MITIGADO — colas SPEI balanceadas; instancia única Autorizador sin confirmar | Hito 3.6 (SPEI queues) | AUT-DR-07 |
| P655-R015 | 🟢 CERRADO para SPEI — firma extraída del flujo síncrono + HSM tables optimizadas | Hitos 3.1, 1.1 | Verificar otros flujos con Firma Digital |
| P655-R016 | 🟢 MITIGADO para producción / 🟡 Abierto para migración — el target debe validar latencia ≤ 4s P95 | Hitos 2.5, 3.6, 3.1, 1.4 | Validar en parallel-run |
| P655-R017 | ✅ **CERRADO** — connection leak corregido en código del Autorizador Java | Hito 2.5 (27-mar-2026, Eduardo Reynoso / Syndein) | — |

**Resumen conteo actualizado:**

| Nivel | Total | Producción ABIERTOS | Migración ABIERTOS | Cerrados |
|-------|-------|--------------------|--------------------|---------|
| N5 | 5 | 2 (R001, R002) | 3 (R012 parcial, R013, R017✅) | 1 (R017) |
| N4 | 4 | 1 (R009) | 3 (R014 parcial, R015✅SPEI, R016 mig.) | — |
| N3 | 5 | 5 | — | — |
| N2 | 3 | 3 | — | — |

---

*Mantenido por: DT-Riesgos · `Informix/dt/dt-riesgos/CLAUDE.md`*
*Fuente primaria validada: `source/logs/` (producción 2026-04-24) + `source/informix/*.sql` + `source/spei-aut-ent/` (volumetría 2025-2026) + diagnóstico arquitectónico enero 2026 + roadmap mejoras 2026 (11 hitos completados)*
