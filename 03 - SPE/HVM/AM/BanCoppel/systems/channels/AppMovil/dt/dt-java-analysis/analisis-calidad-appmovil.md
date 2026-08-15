# Análisis de Calidad Java — AppMovil BanCoppel
> **DT**: dt-java-analysis · **Proyecto**: `SPE-AM-001` · **Canal**: AppMovil (togaf_type: channels)
> **Versión**: 1.0.0 · **Fecha**: 2026-08-14 · **Fase**: DISCOVER
> **Fuente**: análisis estático de `source/code/` — 216 repositorios escaneados
> **Constraint activo**: viabilidad 2027

---

## Resumen Ejecutivo

El canal AppMovil de BanCoppel está implementado en **216 microservicios Spring Boot** desplegados en OpenShift, con un total de **12,110 archivos fuente Java** y **3,718 tests** (ratio 30.7%). El canal exhibe tres generaciones tecnológicas coexistiendo en producción, con 60 repositorios legacy que representan el riesgo técnico más urgente para la viabilidad del programa de modernización en 2027.

| Indicador | Valor | Semáforo |
|-----------|-------|----------|
| Repositorios analizados | 216 | — |
| Repos legacy (Java 8 + SB 2.x) | **60** (27.8%) | 🔴 |
| Ratio tests / código fuente global | **30.7%** | 🔴 |
| Repos con dependencia AOP propietario | **210** (97.2%) | 🟡 |
| Repos con crypto propietario PCI | **115** (53.2%) | 🟡 |
| Repos en Java 21+ | **48** (22.2%) | 🟢 |
| Plataforma de despliegue | OpenShift (todos) | — |

---

## 1. Distribución por Generación Tecnológica

La clasificación por generación es el insumo principal para la decisión 7R y el plan de migración.

| Generación | Java | Spring Boot | Repos | % | Acción requerida |
|-----------|------|-------------|-------|---|-----------------|
| **Legacy** | 1.8 | 2.1.x – 2.7.x | **60** | 27.8% | Migración obligatoria — EOL; sin soporte de seguridad |
| **Modern-17** | 17 | 3.2.x – 3.3.x | **106** | 49.1% | Actualización menor a 3.5.x; considerar upgrade a Java 21 |
| **Modern-21** | 21 | 3.x | **42** | 19.4% | Mantenimiento; LTS hasta septiembre 2026 |
| **Modern-25** | 25 | 3.5.x | **6** | 2.8% | Vanguardia — LTS; referencia para repos restantes |
| **Sin datos** | ? | 2.7.x | **2** | 0.9% | Revisar manualmente (pom.xml incompleto) |

### Detalle de repos legacy (60 repos · EOL)

Los 60 repos legacy incluyen flujos de negocio críticos del canal: pagos CoDi/SPEI, validación de cuentas, autenticación por teléfono, inscripción biométrica, transferencias, y cuentas de inversión. No son repos auxiliares — son la capa de negocio del canal.

**Agrupación funcional de los repos legacy:**

| Función | Repos legacy | Impacto |
|---------|-------------|---------|
| Pagos (CoDi, SPEI, interbank) | 8 | CRÍTICO — flujo de dinero real |
| Créditos (apertura, tarjeta, préstamos) | 10 | ALTO |
| Autenticación / seguridad | 7 | CRÍTICO — acceso al canal |
| Depósitos y cuentas | 9 | ALTO |
| Mensajería / notificaciones | 3 | MEDIO |
| Otros (configuración, remittance, nómina) | 23 | MEDIO |

---

## 2. Stack Tecnológico AS-IS

### 2.1 Dependencias por versión (Spring Boot)

El canal tiene **32 versiones distintas** de Spring Boot en producción — este es un antipatrón de gestión: sin un BOM (Bill of Materials) centralizado, cada equipo actualiza su repo de forma independiente sin coordinación.

| Rama SB | Repos | Estado |
|---------|-------|--------|
| 2.1.x | 27 | EOL — sin patches de seguridad |
| 2.2.x | 21 | EOL |
| 2.3.x | 3 | EOL |
| 2.7.x | 8 | Soporte extendido terminado 2023-11 |
| 3.2.x | 37 | Mantenimiento; soporte hasta 2025-08 |
| 3.3.x | 55 | Soporte activo hasta 2026-02 |
| 3.4.x | 6 | Soporte activo |
| 3.5.x | 48 | LTS vigente — **target 2027** |

**Implicación para 2027**: el target de versión para todos los repos es **Spring Boot 3.5.x + Java 21** como mínimo viable, con Java 25 como aspiracional.

### 2.2 Stack de datastores

| Datastore | Repos | Rol en el canal |
|-----------|-------|----------------|
| **MongoDB** | 121 (56%) | Datastore primario del canal (perfil cliente, estado de sesión, datos de operación) |
| **Informix (JDBC)** | 77 (35.6%) | Acceso al core bancario PISA vía stored procedures |
| **Redis** | 62 (28.7%) | Gestión de sesiones y caché |
| **Sin datastore propio** | ~20 | Orquestadores puros (solo Feign calls) |

### 2.3 Dependencias propietarias BanCoppel (riesgo sistémico)

Estas librerías no tienen equivalente OSS directo — su existencia en 210/216 repos las convierte en la mayor deuda técnica sistémica del canal.

| Librería | Versión | Repos | Riesgo AM | Bloqueo para 2027 |
|---------|---------|-------|-----------|-------------------|
| `msach-u-aop-commons` | 3.0.0 | **210** (97.2%) | ALTO | SÍ — si no se certifica el comportamiento del AOP, cualquier cambio puede romper logging, auditoría y manejo de errores en todos los repos |
| `msach-u-platform-cryptography` | 2.0.0 | **115** (53.2%) | CRÍTICO | SÍ — cambio requiere re-certificación PCI-DSS (estimado 6-12 meses de proceso) |
| `msach-u-redis-actions` | 1.0.1 | ~62 | MEDIO | CONDICIONAL — reemplazable con Spring Session, pero requiere pruebas de regresión de sesión |
| `msaim-u-log-application` | 1.0.1 | ~120 | BAJO | NO — reemplazable con Logback/ECS sin impacto funcional |

---

## 3. Análisis de Calidad — 6 Dimensiones ISO 5055

### 3.1 Seguridad 🔴

**Hallazgos confirmados desde análisis de código:**

| Defecto | Evidencia | Repos afectados | Severidad |
|---------|-----------|-----------------|-----------|
| Credenciales MongoDB en `application.properties` de desarrollo | `mongodb+srv://syscoppel:devsyscoppel@...` hardcodeado en repos legacy | Al menos 3 repos de Java 8 confirmados | CRÍTICO |
| URLs de Nexus interno sin HTTPS | `http://nexuscln.bcpl.mx/repository/bancoppel-dev` en todos los `pom.xml` | 216 repos | ALTO |
| Versiones de dependencias con CVEs conocidos (SB 2.1.x, 2.2.x) | Spring Boot 2.1.x: múltiples CVEs abiertos desde 2021 | 48 repos | ALTO |
| Librerías propietarias sin escaneo SAST público | `msach-u-platform-cryptography` sin evidencia de auditoría | 115 repos | MEDIO |

**Acción requerida para 2027**: los credenciales en properties deben moverse a OpenShift Secrets / Vault antes de cualquier migración. Este es un prerequisito del pipeline de CI/CD seguro.

### 3.2 Confiabilidad 🟡

**Patrón de manejo de errores:**

Los repos analizados usan `msach-u-aop-commons` para el manejo centralizado de excepciones — este AOP intercepta excepciones no capturadas y las transforma en responses HTTP estructurados. El patrón es correcto en concepto, pero su implementación propietaria crea un riesgo de caja negra: el comportamiento en casos edge no está documentado fuera del código de la librería.

**Hallazgos:**

| Patrón | Evidencia | Riesgo |
|--------|-----------|--------|
| Uso de AOP centralizado para excepciones | `msach-u-aop-commons:3.0.0` en 210 repos | MEDIO — dependencia no transparente |
| `CallableStatement` con 38 parámetros posicionales a Informix | `SPCTRANSCTASPROPIASCODI_BEX` en msach-b-business-application-data | ALTO — frágil a cambios de firma en SPs |
| Ausencia de circuit breaker explícito en repos legacy | Spring Cloud Greenwich (SB 2.1.x) tiene Hystrix en EOL | ALTO — Hystrix no recibe parches |

### 3.3 Mantenibilidad 🔴

**Fragmentación de versiones — antipatrón crítico:**

32 versiones distintas de Spring Boot en 216 repos es evidencia de ausencia de un BOM centralizado o un proceso de alineación de versiones. Esto significa que:
- Cada vulnerabilidad de Spring Boot debe parchearse en N repos individualmente
- No existe un "upgrade path" simple — hay que gestionar 32 bases de código distintas
- El onboarding de nuevos desarrolladores requiere conocer las diferencias entre versiones

**Test coverage — insuficiente para AM:**

| Métrica | Valor | Target DoD-SPE-AM | Gap |
|---------|-------|-------------------|-----|
| Archivos fuente Java | 12,110 | — | — |
| Archivos test Java | 3,718 | — | — |
| Ratio global | **30.7%** | ≥ 70% crítico / ≥ 70% global | **-39.3pp** |
| Repos con test code | 216/216 | 100% | ✅ |

La existencia de tests en todos los repos es un punto positivo, pero la cobertura del 30.7% es insuficiente para garantizar equivalencia funcional en la migración. Se requiere doblar la cobertura antes del parallel-run.

**Duplicación de código entre repos -b y repos -b-b:**

Existen pares de repos `{nombre}` y `{nombre}-b` — por ejemplo `msach-b-business-application-configuration` y `msach-b-business-application-configuration-b`. Hay al menos **34 pares** de este tipo. Esto sugiere un patrón de bifurcación para versiones paralelas (A/B deployment, canary), pero sin evidencia de cuándo se consolidan.

### 3.4 Performance 🟡

**Patrones de latencia detectados:**

| Patrón | Repos afectados | Impacto en latencia |
|--------|----------------|---------------------|
| Llamadas JDBC síncronas a Informix (SPs remotos) | 77 repos | ALTO — Informix PISA está en AIX; latencia de red + SP execution |
| Cadenas de Feign calls síncronos (microservicios orquestadores) | ~20 repos orchestrators | ALTO — N llamadas síncronas en serie = suma de latencias |
| MongoDB queries sin índices visibles en el código | 121 repos | MEDIO — depende del schema de Atlas |
| Redis sin TTL explícito en algunos repos legacy | ~15 repos | BAJO — riesgo de memory leak en Redis |

**No hay Kafka ni mensajería asíncrona** — el canal es 100% síncrono. Esto es una decisión arquitectónica válida para el canal móvil, pero implica que cualquier degradación en Informix o MongoDB se propaga inmediatamente al usuario final.

### 3.5 Deuda Técnica 🔴

**Inventario de deuda técnica priorizado:**

| ID | Ítem de deuda | Repos afectados | Esfuerzo estimado | Prioridad 2027 |
|----|--------------|-----------------|-------------------|----------------|
| DT-01 | Migración Java 8 → Java 21 + SB 2.x → SB 3.5.x | **60 repos** | 4-6 meses · 4 FTEs | CRÍTICA |
| DT-02 | Eliminación de credenciales hardcodeadas en properties | ~10 repos | 2 semanas · 1 FTE | CRÍTICA |
| DT-03 | Actualizar repos Java 17 a SB 3.5.x | **106 repos** | 2-3 meses · 2 FTEs | ALTA |
| DT-04 | Incrementar cobertura de tests de 30.7% a 70% | 216 repos | 6-9 meses · 3 FTEs QA | ALTA |
| DT-05 | Centralizar gestión de versiones con BOM propio | 216 repos | 1 mes arquitectura + 2 meses implementación | ALTA |
| DT-06 | Reemplazar Hystrix por Resilience4J en repos Java 8 | 27 repos | Incluido en DT-01 | ALTA |
| DT-07 | Plan de sustitución de `msach-u-aop-commons` | 210 repos | 3-4 meses · requiere ADR | MEDIA |
| DT-08 | Plan de sustitución de `platform-cryptography` | 115 repos | 12+ meses · PCI-DSS recertificación | MEDIA-BAJA |
| DT-09 | Eliminar pares `-b` repos obsoletos o consolidarlos | ~34 repos | 1 mes · revisión con BanCoppel | BAJA |

### 3.6 Cobertura de Tests — Detalle

Todos los 216 repos tienen archivos de test, pero la distribución es desigual:

| Categoría | Archivos fuente | Archivos test | Ratio |
|-----------|----------------|---------------|-------|
| Global | 12,110 | 3,718 | **30.7%** |
| Repos legacy (Java 8) | ~3,000 (estimado) | ~900 (estimado) | ~30% |
| Repos modern (Java 17+) | ~9,110 (estimado) | ~2,818 (estimado) | ~30.9% |

La cobertura es homogéneamente baja en todas las generaciones — no es un problema exclusivo de los repos legacy. Esto indica una práctica de desarrollo que priorizó velocidad de entrega sobre calidad de tests sistemáticamente.

---

## 4. Antipatrones Confirmados

| ID | Antipatrón | Evidencia directa | Riesgo AM |
|----|-----------|-------------------|-----------|
| AP-01 | **JDBC directo sin abstracción de repositorio limpia** | `session.doReturningWork()` + `prepareCall()` en capa D — sin interfaz entre el SP y el servicio | ALTO: cambio de SP en Informix requiere cambio en Java; imposibilita unit tests de la capa D sin Informix real |
| AP-02 | **Constantes de SPs hardcodeadas en código fuente** | `Constants.SPCENVIOASPEI_BEX`, `Constants.SPCTRANSCTASPROPIASCODI_BEX` — 49 SPs en 21 archivos Constants | MEDIO: refactor de SP → cambio en 21 archivos Java + re-test |
| AP-03 | **38 parámetros posicionales en CallableStatement** | `SPCTRANSCTASPROPIASCODI_BEX(?, ?, ..., ?)` — posición importa, no el nombre | ALTO: sin names binding; cualquier reordenamiento de parámetros en el SP rompe silenciosamente |
| AP-04 | **Credenciales en application.properties** | `mongodb+srv://syscoppel:devsyscoppel@...` | CRÍTICO: secret management desde día 0 de AM |
| AP-05 | **32 versiones de Spring Boot sin BOM centralizado** | `pom.xml` de cada repo define su propia versión independiente | ALTO: vulnerabilidades sin parche unificado; upgrade en cascada manual |
| AP-06 | **Hystrix como circuit breaker en repos Java 8** | Spring Cloud Greenwich · Hystrix oficialmente en EOL | ALTO: sin parches de seguridad; Resilience4J disponible pero requiere migración |
| AP-07 | **URLs de repositorio Maven sin TLS** | `http://nexuscln.bcpl.mx/...` en 216 pom.xml | ALTO: supply chain attack surface; npm-style dependency confusion |
| AP-08 | **Dependencia de Javanes Framework** | `com.javanes.framework.*` en 4 repos legacy — framework de tercero de nicho | MEDIO: si el framework deja de mantenerse, estos repos quedan sin soporte upstream |

---

## 5. Evaluación de Viabilidad 2027

### 5.1 Qué es viable para 2027

Con el constraint explícito de viabilidad 2027 y asumiendo inicio del programa en Q4 2026:

| Wave | Alcance | Resultado | Timeline |
|------|---------|-----------|---------|
| **Wave 0** (prerrequisito) | Credenciales en Secrets · BOM centralizado · pipeline CI/CD seguro | Infraestructura de AM lista | Q4 2026 — 2 meses |
| **Wave 1** | Migración de 60 repos legacy a Java 21 + SB 3.5.x | Canal libre de EOL software | Q1-Q2 2027 — 4-6 meses |
| **Wave 2** | Actualización 106 repos Java 17 a SB 3.5.x | Todos los repos en LTS activo | Q2-Q3 2027 — 3 meses |
| **Wave 3** | Tests: subir cobertura global de 30.7% a 70% | Calidad suficiente para equivalence-check | Q1-Q4 2027 — paralelo a W1+W2 |
| **Posible por 2028** | Sustitución de AOP commons / crypto propietaria | Independencia de librerías propietarias | 2028+ |

### 5.2 La migración Java 8 → SB 3.x es de dos pasos

La migración directa de Spring Boot 2.x (Java 8) a Spring Boot 3.x no es posible — requiere paso intermedio:

```
Java 8 + SB 2.1.x → [PASO A] → Java 17 + SB 2.7.x → [PASO B] → Java 21 + SB 3.5.x
```

El PASO B es el más crítico: SB 3.x migra de `javax.*` a `jakarta.*` — todos los imports del código fuente deben actualizarse. Herramientas como `OpenRewrite` automatizan el 80-90% de esto, pero el 10-20% requiere revisión manual, especialmente en integraciones con Informix.

### 5.3 El riesgo más alto: AOP Commons sistémico

El `msach-u-aop-commons` en 210/216 repos es un riesgo sistémico de primer orden. **No está en scope para 2027** porque:
1. Reemplazarlo requiere un ADR con BanCoppel que defina el comportamiento equivalente
2. Las pruebas de regresión del comportamiento del AOP (logging, auditoría, manejo de errores) deben cubrir todos los flujos de negocio
3. El timeline de certificación interna en BanCoppel para cambios sistémicos excede el horizonte 2027

**Decisión recomendada**: migrar los repos legacy manteniendo `msach-u-aop-commons:3.0.0` — la librería es compatible con Java 21 y Spring Boot 3.x (verificar con BanCoppel). La sustitución va en el roadmap 2028.

### 5.4 PCI-DSS crypto library — no cambia en 2027

La librería `msach-u-platform-cryptography` tiene certificación PCI-DSS implícita. Cualquier sustitución requiere:
- Análisis criptográfico formal del comportamiento actual
- Re-certificación PCI-DSS (6-12 meses de proceso)
- Validación de BanCoppel con su QSA (Qualified Security Assessor)

**Decisión**: mantener la librería en las migraciones de 2027. El ADR de sustitución se inicia en 2027 para delivery en 2028.

---

## 6. Riesgos Identificados (input para DT-Riesgos)

| ID | Riesgo | Probabilidad | Impacto | Mitigación |
|----|--------|-------------|---------|-----------|
| RISK-JA-01 | Incompatibilidad de `aop-commons` con SB 3.x | MEDIA | CRÍTICO | Prueba de compatibilidad en sandbox antes de Wave 1 |
| RISK-JA-02 | Los 34 pares repos `-b` tienen estado inconsistente | ALTA | ALTO | Inventariar cuáles son activos en producción antes de Wave 1 |
| RISK-JA-03 | Tests insuficientes impiden detectar regresiones post-migración | ALTA | ALTO | Wave 3 de tests paralela a migraciones; golden-master tests antes del cutover |
| RISK-JA-04 | Informix SP con 38 parámetros posicionales — cualquier refactor rompe silenciosamente | MEDIA | ALTO | Wrapper DTO en capa D antes de migrar el SP |
| RISK-JA-05 | Supply chain attack por HTTP Maven repo | ALTA | ALTO | Migrar a HTTPS en Wave 0 como prerequisito bloqueante |
| RISK-JA-06 | Credenciales MongoDB en properties llegan a repo migrado | ALTA | CRÍTICO | Secrets migration en Wave 0 · `gitleaks` en CI desde Wave 0 |

---

## 7. Inputs para Otros DTs

| DT receptor | Input de este análisis |
|-------------|----------------------|
| **dt-riesgos** | RISK-JA-01 a RISK-JA-06 (sección 6) |
| **dt-sp-dependencies** | AP-01, AP-02, AP-03 — el antipatrón JDBC directo y los 49 SPs deben tener wrapper DTO antes del cutover |
| **dt-regulatorio** | AP-04 (credenciales) · DT-08 (PCI-DSS crypto) — prerequisitos regulatorios del canal |
| **dt-modelo-dominio** | Pares repos `-b` — necesitan clasificación de cuáles son activos en prod vs. archivados |
| **dt-capacidades** | DT-05 (BOM centralizado) — prerequisito de governance para todas las capacidades |

---

## 8. Smoke Tests (para DT-Validador)

| ID | Test | Estado |
|----|------|--------|
| JA-01 | `analisis-calidad-appmovil.md` existe | ✅ |
| JA-02 | El análisis cubre las 6 dimensiones: Seguridad, Confiabilidad, Mantenibilidad, Performance, Deuda Técnica, Cobertura | ✅ |
| JA-03 | Las 4 librerías propietarias están catalogadas con su riesgo de migración | ✅ |
| JA-04 | El antipatrón JDBC directo (`prepareCall` sin abstracción) está documentado | ✅ |
| JA-05 | La credencial MongoDB en properties está marcada como defecto CRÍTICO | ✅ |
| JA-06 | El análisis cubre los repos legacy y la evaluación de viabilidad 2027 | ✅ |

---

*v1.0.0 · 2026-08-14 · Construido por dt-java-analysis desde análisis estático de 216 repos · constraint viabilidad 2027*
