# Análisis de Calidad Java — AppMovil BanCoppel
> **DT**: dt-java-analysis · **Proyecto**: `SPE-AM-001` · **Canal**: AppMovil (togaf_type: channels)
> **Versión**: 2.0.0 · **Fecha**: 2026-11-03 · **Fase**: DISCOVER
> **Fuente**: `generators/build-java-analysis.py` sobre `source/code/` — 215 repositorios con código Maven
> **Constraint activo**: viabilidad 2027

---

## Resumen Ejecutivo

El canal AppMovil está implementado en **215 microservicios** desplegados en OpenShift, con **12,155 archivos Java de producción** y **3,724 de prueba**. El canal arrastra cuatro generaciones tecnológicas en producción simultánea, desde Java 8 con Spring Boot 2.1 hasta Java 25 con Spring Boot 4.1.

Esta versión 2.0.0 corrige la del 2026-08-14. Aquella se construyó sobre un escaneo que no veía las 39 variantes `-b` del canal ni 773 archivos que faltaban en el working tree, y midió a mano. Las cifras de ahora salen de un generador reproducible, y tres de ellas cambian de forma material: la credencial de MongoDB no está en tres repos sino en **108**, Hystrix no está en 27 repos legacy sino en **98 repos de todas las generaciones**, y el canal no depende de 4 librerías propietarias sino de **19**.

| Indicador | Valor | Lectura |
|-----------|-------|---------|
| Repositorios con código Maven | 215 | De 218 clonados; 3 son cascarones sin `pom.xml` |
| Repos legacy (Java 8 u 11, SB 2.x) | **61** (28.4%) | Sin soporte de seguridad |
| Ratio prueba sobre producción | **30.6%** | Muy por debajo del DoD |
| Repos con credencial de base de datos en claro | **108** (50.2%) | Hallazgo más grave del canal |
| Repos con Hystrix, en EOL | **98** (45.6%) | 45 de ellos no son legacy |
| Repos que resuelven dependencias por HTTP sin TLS | **212** (98.6%) | Superficie de ataque de cadena de suministro |
| Librerías internas BanCoppel distintas | **19** | El DT solo tenía 4 catalogadas |
| Almas en stack legacy | **4 de 12** | Incluye seguridad de acceso y depósitos |

Las tres cifras de seguridad de arriba son prerrequisitos bloqueantes: ninguna migración debería arrancar antes de resolverlas, porque migrar un repo con la credencial adentro la propaga al destino.

---

## 1. Distribución por Generación Tecnológica

La clasificación por generación es el insumo principal de la decisión 7R. Lo que define la urgencia es el fin de soporte, no la antigüedad nominal.

| Generación | Java | Spring Boot | Repos | % | Acción requerida |
|-----------|------|-------------|-------|---|-----------------|
| **Legacy** | 1.8 (58) y 11 (3) | 2.1.x a 2.7.x | **61** | 28.4% | Migración obligatoria, sin parches de seguridad |
| **Modern-17** | 17 | 3.2.x a 3.5.x | **103** | 47.9% | Actualización de rama; evaluar salto a Java 21 |
| **Modern-21** | 21 | 3.5.x | **27** | 12.6% | Mantenimiento |
| **Modern-25** | 25 | 3.5.x y 4.x | **24** | 11.2% | Vanguardia; referencia para el resto |

La distribución por rama de Spring Boot muestra **once ramas distintas en producción**:

| Rama | Repos | Estado |
|------|-------|--------|
| 2.1.x | 27 | Fin de vida |
| 2.2.x | 23 | Fin de vida |
| 2.3.x | 3 | Fin de vida |
| 2.7.x | 8 | Soporte extendido terminado |
| 3.2.x | 34 | Fin de soporte |
| 3.3.x | 58 | Fin de soporte |
| 3.4.x | 6 | Soporte activo |
| 3.5.x | 52 | Soporte activo, candidato a target |
| 4.0.x | 1 | Vanguardia |
| 4.1.x | 2 | Vanguardia |
| Sin dato | 1 | `msamg-d-security-messaging-otp-notification`, sin `parent` ni propiedad de versión |

Hay tres repos que ya corren **Spring Boot 4.x sobre Java 25**: `msach-o-security-phone-enrollment-b`, `msacm-b-business-offer-products` y `msalo-b-business-salary-advance-reception`. Sirven como prueba de que el equipo puede llegar al stack moderno, y como referencia de configuración para las olas de migración.

### Las almas no están a salvo

De las 12 almas del canal, **4 corren sobre Java 8**, y dos de ellas son de seguridad y de depósitos:

| Alma | Java | Spring Boot | Generación |
|------|------|-------------|-----------|
| `msach-p-security-application-validations` | 1.8 | 2.1.5 | legacy |
| `msacm-d-domain-customer-data` | 1.8 | 2.2.0 | legacy |
| `msadp-d-domain-deposit-accounts` | 1.8 | 2.2.4 | legacy |
| `msaim-p-platform-push-notifications-service-management` | 1.8 | 2.2.4 | legacy |
| `msacm-p-security-session-management` | 25 | 3.5.16 | modern-25 |
| `msacm-d-security-customer-access-managment` | 17 | 3.5.3 | modern-17 |
| `msapy-d-domain-codi-payment` | 21 | 3.5.13 | modern-21 |
| `msasr-d-domain-services-banking-validations` | 21 | 3.5.3 | modern-21 |
| `msacr-d-security-card-data-validation` | 17 | 3.3.6 | modern-17 |
| `msach-b-business-application-configuration` | 17 | 3.3.3 | modern-17 |
| `msach-b-business-application-data` | 17 | 3.2.5 | modern-17 |
| `msacm-d-platform-customer-enrollment-verification` | 17 | 3.2.5 | modern-17 |

Que la validación de acceso al canal corra sobre un runtime sin parches desde 2019 es el riesgo de seguridad estructural del canal, por encima de cualquier antipatrón de código.

### Los repos legacy son la capa de negocio

Los 61 repos legacy no son auxiliares. Doce de ellos operan flujos de dinero real: `codi-transactions`, `codi-transaction-repayment`, `codi-payment-b`, `codi-agreement-management`, `service-payment-validation`, `services-payment`, `interbank-card-payment` y su variante, `intrabank-card-payment` y su variante, `apply-intrabank-transfer` y `remittance-payment`. Otros **15 repos legacy hablan con Informix** por JDBC, es decir, tocan el core bancario PISA desde un runtime sin soporte.

---

## 2. Stack de Datos y Dependencias

### 2.1 Datastores

Las cifras reconcilian exactamente con `brain.db::services`, que es la prueba de que ambas mediciones usan la misma definición.

| Datastore | Repos | % | Rol en el canal |
|-----------|-------|---|----------------|
| **OpenFeign** | 194 | 90.2% | Llamadas entre microservicios; el canal es una malla síncrona |
| **MongoDB** | 122 | 56.7% | Datastore primario del canal |
| **Informix por JDBC** | 77 | 35.8% | Acceso al core bancario PISA por stored procedures |
| **Redis** | 63 | 29.3% | Sesión y caché |

No hay mensajería asíncrona en ningún repo. El canal es síncrono de extremo a extremo, así que cualquier degradación de Informix o de MongoDB llega al usuario final sin amortiguación.

### 2.2 Las 19 librerías internas

El catálogo del DT tenía 4. El fuente declara **19 librerías BanCoppel** con el patrón `msa{dominio}-u-{función}`. Ninguna tiene equivalente de código abierto, así que cada una es deuda que ninguna migración hereda gratis.

| Librería | Repos | % | Riesgo de migración |
|---------|-------|---|---------------------|
| `msach-u-aop-commons` | 209 | 97.2% | ALTO, es el sustrato transversal del canal |
| `msaim-u-log-application` | 117 | 54.4% | BAJO, sustituible por Logback |
| `msach-u-platform-cryptography` | 115 | 53.5% | CRÍTICO, cambiarla obliga a recertificar PCI-DSS |
| `msaim-u-security-platform` | 89 | 41.4% | ALTO, no estaba catalogada y es de seguridad |
| `msach-u-redis-actions` | 62 | 28.8% | MEDIO, sustituible por Spring Session |
| `msach-u-business-geolocation-common` | 42 | 19.5% | MEDIO, no estaba catalogada |
| `msach-u-bex-business-validations` | 17 | 7.9% | MEDIO, lógica de negocio en librería |
| `msach-u-security-risk-validations` | 16 | 7.4% | ALTO, validación de riesgo compartida |
| `msasr-u-security-gemalto-token-validations` | 15 | 7.0% | ALTO, acopla el canal a un proveedor de token |
| `msaxd-u-business-digital-account-validations` | 10 | 4.7% | MEDIO |
| `msach-u-security-attempts-validation` | 5 | 2.3% | MEDIO, control de intentos de acceso |
| `msacm-u-security-personal-loan-session-validation` | 4 | 1.9% | MEDIO |
| `msach-u-transfer-amount-limit-validations` | 4 | 1.9% | ALTO, límites de transferencia en librería compartida |
| `msacm-u-domain-black-lists-validation` | 4 | 1.9% | ALTO, listas negras, con implicación regulatoria |
| `msaxd-u-mongodb-queryable-encryption` | 4 | 1.9% | ALTO, cifrado consultable sobre MongoDB |
| `msach-u-bex-business-frequent-validations` | 3 | 1.4% | MEDIO |
| `msaxd-u-conection-broker-configuration` | 2 | 0.9% | MEDIO |
| `msaxd-u-domain-account-validations` | 2 | 0.9% | MEDIO |
| `msach-u-log-application` | 1 | 0.5% | BAJO, pero ver abajo |

Dos observaciones que el catálogo anterior no podía ver. La primera es que **hay reglas de negocio viviendo en librerías compartidas**: límites de transferencia, listas negras y validaciones de riesgo no están en el microservicio que las aplica sino en una dependencia binaria, así que ni el catálogo de reglas ni los Digital Twins funcionales las alcanzan leyendo el código del servicio. La segunda es que `msach-u-log-application` existe en un repo mientras `msaim-u-log-application` existe en 117: son el mismo propósito con distinto prefijo de dominio, y conviene confirmar cuál es la vigente antes de estandarizar.

---

## 3. Análisis de Calidad, seis dimensiones ISO 5055

### 3.1 Seguridad

El hallazgo más grave del canal es la credencial de base de datos escrita en claro en los archivos de configuración.

| Defecto | Alcance medido | Severidad |
|---------|---------------|-----------|
| Credencial de MongoDB en archivos `.properties` | **108 repos**, 121 ocurrencias | CRÍTICO |
| Resolución de dependencias Maven por HTTP sin TLS | **212 repos**, contra 1 que usa HTTPS | ALTO |
| Hystrix en fin de vida como cortacircuitos | **98 repos** | ALTO |
| Spring Boot con vulnerabilidades conocidas (ramas 2.x) | **61 repos** | ALTO |
| Dependencia de framework de nicho `javanes` | **5 repos** | MEDIO |

Sobre la credencial, el detalle importa para dimensionar la respuesta. **Una sola credencial compartida aparece en 115 de las 121 ocurrencias**, lo que significa que rotarla es un movimiento único pero que toca medio canal a la vez. La exposición cruza todas las generaciones, con 50 repos modern-17, 41 legacy, 12 modern-21 y 5 modern-25, así que no es un pasivo de código viejo sino una práctica vigente.

Cuatro casos son peores que el resto porque la credencial no está en el perfil de desarrollo sino en uno que puede cargarse fuera de él:

| Repo | Archivo |
|------|---------|
| `msamg-d-security-messaging-otp-notification` | `application.properties`, perfil por omisión |
| `msach-i-business-credit-cards-accounts` | `application.properties`, perfil por omisión |
| `msacm-d-platform-customer-enrollment-verification` | `application-test.properties`, y además es un alma |
| `msacm-d-domain-customer-enrollment-status` | `application-test.properties` |

El patrón correcto ya existe en el canal: `msach-d-business-frequent-accounts` resuelve el usuario con `${MONGO_USER}` en lugar de escribirlo. Lo adoptó 1 repo de 108, así que la corrección no requiere inventar una solución, sino propagar la que ya está probada.

Este documento no transcribe el valor de la credencial de forma deliberada. La versión anterior del artefacto sí lo hacía, y ese texto se eliminó.

### 3.2 Confiabilidad

El canal maneja excepciones con `msach-u-aop-commons`, que intercepta lo no capturado y lo convierte en respuesta HTTP estructurada. El patrón es correcto, pero su implementación propietaria lo vuelve una caja negra: el comportamiento en casos límite solo está en el código de la librería.

El hallazgo nuevo es el cortacircuitos. **Hystrix aparece en 98 repos y solo 53 son legacy**: hay 31 repos modern-17, 7 modern-21 y 5 modern-25 que siguen declarándolo pese a correr sobre stacks modernos donde Resilience4J está disponible. En paralelo, 54 repos ya usan Resilience4J. Es decir, el canal mantiene dos cortacircuitos en convivencia y uno de ellos no recibe parches. Ese solapamiento es más urgente de resolver que la propia migración de runtime, porque afecta al comportamiento ante fallas de Informix.

Se mantiene el hallazgo de agosto sobre `CallableStatement` con 38 parámetros posicionales hacia Informix en `msach-b-business-application-data`.

### 3.3 Mantenibilidad

Once ramas de Spring Boot conviviendo en 215 repos es evidencia de que no hay un BOM central. Cada vulnerabilidad del framework se parchea repo por repo, y no existe una ruta de actualización única.

Sobre pruebas, la medición es ahora exacta y no estimada, porque el contador distingue `src/test` de los paquetes de producción que se llaman así:

| Categoría | Producción | Prueba | Ratio |
|-----------|-----------|--------|-------|
| Global | 12,155 | 3,724 | **30.6%** |
| Repos legacy | 3,384 | 952 | 28.1% |
| Repos no legacy | 8,771 | 2,772 | 31.6% |

El dato relevante es que la diferencia entre generaciones es de apenas 3.5 puntos. La cobertura baja no es un problema heredado de los repos viejos, es la práctica actual del canal. Los 215 repos tienen al menos un archivo de prueba, y 7 están por debajo del 20%.

La fragmentación `-b` queda ahora medida con precisión. Hay **39 repos que terminan en `-b`**, y **35 de ellos declaran el mismo `artifactId` que su gemelo**. Esto tiene una consecuencia operativa que va más allá del inventario: dos artefactos distintos se publican con el mismo nombre al repositorio Maven, así que cuál de los dos resuelve una dependencia transitiva depende del orden de compilación. Además, tres repos nunca renombraron el esqueleto del generador y siguen declarando `artifactId = jso-fwk-hello-service`: `msach-b-business-application-video-tours`, `msach-d-business-credit-cards-accounts` y `msacm-b-business-codi-agreement-management`. Los tres son legacy y los tres tienen el peor ratio de pruebas del canal, con 1 archivo de prueba contra 8 de producción.

### 3.4 Performance

| Patrón | Repos | Impacto |
|--------|-------|---------|
| Llamadas JDBC síncronas a Informix | 77 | ALTO, PISA corre en AIX y suma latencia de red y de ejecución del SP |
| Cadenas de llamadas Feign síncronas | 194 declaran Feign | ALTO, las latencias se suman en serie |
| Consultas a MongoDB sin índice visible en código | 122 | MEDIO, depende del esquema en Atlas |
| Redis sin expiración explícita en repos legacy | Subconjunto de 63 | BAJO |

La ausencia total de mensajería asíncrona confirma lo dicho arriba: el canal no tiene ningún punto donde absorber una degradación del backend.

### 3.5 Deuda Técnica

| ID | Ítem | Repos | Prioridad 2027 |
|----|------|-------|----------------|
| DT-01 | Sacar la credencial de los `.properties` y rotarla | 108 | CRÍTICA, bloqueante |
| DT-02 | Pasar la resolución de dependencias a HTTPS | 212 | CRÍTICA, bloqueante |
| DT-03 | Migrar de Java 8 u 11 a Java 21 con Spring Boot 3.5.x | 61 | CRÍTICA |
| DT-04 | Retirar Hystrix y unificar en Resilience4J | 98 | ALTA |
| DT-05 | Subir la cobertura de pruebas de 30.6% a 70% | 215 | ALTA |
| DT-06 | Actualizar los repos Java 17 a rama con soporte | 103 | ALTA |
| DT-07 | Centralizar versiones con un BOM propio | 215 | ALTA |
| DT-08 | Resolver la colisión de `artifactId` entre pares `-b` | 35 | ALTA, afecta resolución de dependencias |
| DT-09 | Catalogar y decidir destino de las 19 librerías internas | 215 | ALTA |
| DT-10 | Extraer a servicio las reglas de negocio que viven en librerías | 25 aprox. | MEDIA |
| DT-11 | Plan de sustitución de `msach-u-aop-commons` | 209 | MEDIA, requiere ADR |
| DT-12 | Plan de sustitución de `platform-cryptography` | 115 | MEDIA-BAJA, depende de recertificación PCI-DSS |

### 3.6 Cobertura de Pruebas, detalle

Los repos con peor relación entre prueba y producción:

| Repo | Prueba / Producción | Ratio | Generación |
|------|--------------------|-------|-----------|
| `msach-b-business-application-video-tours` | 1 / 8 | 12.5% | legacy |
| `msach-d-business-credit-cards-accounts` | 1 / 8 | 12.5% | legacy |
| `msacm-b-business-codi-agreement-management` | 1 / 8 | 12.5% | legacy |
| `msach-o-business-services-payment` | 15 / 92 | 16.3% | legacy |
| `msamg-p-platform-send-codi-process-log` | 8 / 49 | 16.3% | modern-17 |
| `msacm-d-business-identity-data-recovery` | 15 / 83 | 18.1% | legacy |
| `msapy-b-business-remittance-payment` | 18 / 92 | 19.6% | legacy |

Cinco de los siete operan pagos o identidad, que son justo los flujos donde una regresión no detectada cuesta dinero o acceso.

---

## 4. Antipatrones Confirmados

| ID | Antipatrón | Evidencia | Riesgo |
|----|-----------|-----------|--------|
| AP-01 | JDBC directo sin abstracción de repositorio | `session.doReturningWork()` con `prepareCall()` en capa D | ALTO, impide probar la capa D sin un Informix real |
| AP-02 | Nombres de SP incrustados como constantes | 21 archivos `Constants.java` con 49 pares base y SP | MEDIO, renombrar un SP obliga a tocar Java y volver a probar |
| AP-03 | 38 parámetros posicionales en `CallableStatement` | `SPCTRANSCTASPROPIASCODI_BEX` | ALTO, reordenar parámetros rompe en silencio |
| AP-04 | Credencial de base de datos en configuración versionada | 108 repos, 121 ocurrencias | CRÍTICO |
| AP-05 | Once ramas de Spring Boot sin BOM central | Cada `pom.xml` fija su versión | ALTO |
| AP-06 | Hystrix en fin de vida, conviviendo con Resilience4J | 98 repos contra 54 | ALTO |
| AP-07 | Dependencias Maven resueltas por HTTP sin TLS | 212 repos | ALTO, superficie de cadena de suministro |
| AP-08 | Framework de nicho `javanes` | 5 repos legacy | MEDIO |
| AP-09 | `artifactId` duplicado entre repos distintos | 35 pares `-b` y 3 con el esqueleto sin renombrar | ALTO, la resolución de dependencias deja de ser determinista |
| AP-10 | Reglas de negocio en librerías compartidas | Límites de transferencia, listas negras, validaciones de riesgo | MEDIO, invisibles al análisis del servicio |

---

## 5. Evaluación de Viabilidad 2027

### 5.1 Qué es viable

| Ola | Alcance | Resultado | Horizonte |
|-----|---------|-----------|-----------|
| **Ola 0**, prerrequisito | Rotar y externalizar la credencial (DT-01), pasar a HTTPS (DT-02), BOM central (DT-07) | Base segura para migrar | 2 meses |
| **Ola 1** | 61 repos legacy a Java 21 con Spring Boot 3.5.x, retirando Hystrix en el camino | Canal libre de software sin soporte | 4 a 6 meses |
| **Ola 2** | 103 repos Java 17 a rama con soporte | Todo el canal en soporte activo | 3 meses |
| **Ola 3**, en paralelo | Cobertura de pruebas de 30.6% a 70% | Calidad suficiente para verificar equivalencia | Todo 2027 |
| **2028** | Sustitución de `aop-commons` y de la librería de cifrado | Independencia de librerías propietarias | Fuera de 2027 |

La Ola 0 no es negociable y no depende de BanCoppel para arrancar: migrar un repo con la credencial adentro la copia al destino y multiplica el problema en lugar de resolverlo.

### 5.2 La migración desde Java 8 es de dos pasos

No existe salto directo de Spring Boot 2.x sobre Java 8 a Spring Boot 3.x. La ruta es Java 8 con SB 2.1.x, luego Java 17 con SB 2.7.x, y después Java 21 con SB 3.5.x. El segundo paso es el caro, porque Spring Boot 3 cambia `javax` por `jakarta` en todos los imports. OpenRewrite automatiza la mayor parte, pero el remanente exige revisión manual, sobre todo en las integraciones con Informix.

Los tres repos que ya corren Spring Boot 4 sobre Java 25 demuestran que la ruta completa es transitable y sirven de plantilla.

### 5.3 El riesgo sistémico sigue siendo `aop-commons`

Con 209 de 215 repos dependiendo de él, sustituirlo no cabe en 2027: requiere un ADR con BanCoppel que fije el comportamiento equivalente, y pruebas de regresión sobre todos los flujos. La recomendación se mantiene: migrar conservando `msach-u-aop-commons:3.0.0`, previa verificación de que es compatible con Java 21 y Spring Boot 3.x, y abrir el reemplazo en el roadmap 2028.

La novedad es que `msaim-u-security-platform`, en 89 repos, merece el mismo tratamiento de ADR y no estaba identificada.

### 5.4 La librería de cifrado no cambia en 2027

`msach-u-platform-cryptography` carga certificación PCI-DSS implícita en 115 repos. Sustituirla exige análisis criptográfico formal, recertificación con el QSA de BanCoppel y un proceso que no cabe en el horizonte. Se mantiene en las migraciones de 2027 y el ADR de sustitución se inicia ese año para entregar en 2028.

---

## 6. Riesgos Identificados, insumo para dt-riesgos

| ID | Riesgo | Probabilidad | Impacto | Mitigación |
|----|--------|-------------|---------|-----------|
| RISK-JA-01 | La credencial compartida se propaga a los repos migrados | ALTA | CRÍTICO | Ola 0 bloqueante, con detección de secretos en el pipeline |
| RISK-JA-02 | `aop-commons` resulta incompatible con Spring Boot 3.x | MEDIA | CRÍTICO | Prueba de compatibilidad en entorno aislado antes de la Ola 1 |
| RISK-JA-03 | La colisión de `artifactId` publica el binario equivocado | MEDIA | ALTO | Renombrar los 35 pares y los 3 esqueletos antes de tocar el pipeline |
| RISK-JA-04 | Las pruebas insuficientes ocultan regresiones tras migrar | ALTA | ALTO | Ola 3 en paralelo, con pruebas de referencia antes del cambio |
| RISK-JA-05 | Compromiso de cadena de suministro por Maven sin TLS | ALTA | ALTO | HTTPS como prerrequisito bloqueante de la Ola 0 |
| RISK-JA-06 | Hystrix sin parches falla ante degradación de Informix | MEDIA | ALTO | Unificar en Resilience4J durante la Ola 1 |
| RISK-JA-07 | Cuatro almas en Java 8 concentran el riesgo de disponibilidad | ALTA | CRÍTICO | Priorizarlas al frente de la Ola 1 |
| RISK-JA-08 | Reglas de negocio en librerías quedan fuera del catálogo | MEDIA | MEDIO | Extraer y registrar en dt-reglas antes del cutover |

---

## 7. Insumos para Otros Digital Twins

| DT receptor | Insumo |
|-------------|--------|
| **dt-riesgos** | RISK-JA-01 a RISK-JA-08 |
| **dt-sp-dependencies** | AP-01, AP-02 y AP-03; los 49 pares base y SP necesitan envoltorio antes del cutover |
| **dt-regulatorio** | AP-04 sobre la credencial, DT-12 sobre PCI-DSS, y las listas negras que viven en librería |
| **dt-modelo-dominio** | Los 39 repos `-b` y sus 35 colisiones de `artifactId` necesitan clasificación de cuál está activo |
| **dt-reglas** | AP-10; las reglas en librerías compartidas no se alcanzan leyendo el código del servicio |
| **dt-capacidades** | DT-07 sobre el BOM central como prerrequisito de gobierno |
| **dt-almas** | Las 4 almas en stack legacy encabezan la Ola 1 |

---

## 8. Reproducir este análisis

```bash
cd systems/channels/AppMovil
python generators/build-java-analysis.py          # tablas en consola y portal/data/java-analysis.json
python generators/build-java-analysis.py -v       # detalle por repositorio
```

El generador mide versión de Java y de Spring Boot, generación, librerías internas, datastores y archivos de prueba contra producción, para los 215 repos con `pom.xml`. Sus conteos de datastore reconcilian con `brain.db::services` por construcción. Si una cifra de este documento no coincide con la salida del generador, la del generador es la válida y este documento está vencido.

---

## 9. Smoke Tests, para el Brain Auditor

| ID | Test | Estado |
|----|------|--------|
| JA-01 | `analisis-calidad-appmovil.md` existe | Pasa |
| JA-02 | Cubre las seis dimensiones ISO 5055 | Pasa |
| JA-03 | Las librerías propietarias están catalogadas con su riesgo | Pasa, ahora con las 19 |
| JA-04 | El antipatrón de JDBC directo está documentado | Pasa |
| JA-05 | La credencial en configuración está marcada como crítica | Pasa, con alcance de 108 repos |
| JA-06 | Cubre los repos legacy y la viabilidad 2027 | Pasa |
| JA-07 | Las cifras provienen de un generador reproducible | Pasa |

---

*v2.0.0 · 2026-11-03 · Reconstruido por dt-java-analysis desde `build-java-analysis.py` sobre 215 repos, tras el rebuild del brain que recuperó 37 componentes invisibles. Corrige la v1.0.0 del 2026-08-14 en tres cifras materiales: credencial expuesta de 3 a 108 repos, Hystrix de 27 a 98, librerías internas de 4 a 19. Se eliminó del documento el valor de la credencial que la versión anterior transcribía.*
