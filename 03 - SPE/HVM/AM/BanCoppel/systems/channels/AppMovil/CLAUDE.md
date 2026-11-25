# AppMovil — Canal Móvil BanCoppel (Application Modernization)
# togaf_type: channels
# togaf_state: active
# togaf_system_of: differentiation
# togaf_abb: digital-banking-mobile

> **Descubierto por:** Informix Informix seed — [app-movil-seed.json](../../core/Informix/digital-brain/seeds/app-movil-seed.json)
> **Fecha descubrimiento:** 2026-08-12
> **Estado:** `[STATE: ACTIVE]` — 14 Digital Twins activos, brain reconstruido sobre el fuente completo (2026-11-03).
> **Última actualización:** 2026-11-03 — brain.db activo: 215 MSAs, 49 pares base-SP en 11 BDs Informix, 134 referencias, 4,291 términos, 52 endpoints, 16 deps Feign, 2,997 reglas.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `channels` |
| `togaf_state` | `discovered` |
| `togaf_system_of` | `differentiation` |
| `togaf_abb` | `digital-banking-mobile` |
| `bian_domains` | — *(pendiente de mapeo)* |

---

## Relación con Informix PISA — desde seed + análisis brain

| Campo | Valor |
|-------|-------|
| Relación | `calls` |
| Dirección | `outbound` — AppMovil invoca SPs Informix vía JDBC/JPA |
| SPs Informix confirmados | **49 únicos** en 11 BDs (brain 2026-08-14) |
| Referencias totales | 133 (21 Java Constants + 112 properties) |
| Dominios Informix tocados | bdisac, bdicred, bdicheq, bdisolic, bdispei, bdinteg, intercard, bdiprog, bdinvers, bdimnsj, bdibpi |
| Regulación aplicable | CNBV Banca Electrónica · Banxico SPEI/CoDi · PCI-DSS |
| Criticidad | `critical` — CoDi/SPEI y cargo/abono son flujos de pago real |

---

## Seeds Recibidos

| Emisor | Versión | Fecha | Artefacto origen |
|--------|---------|-------|-----------------|
| `informix` | `Informix v1.8.0` | 2026-08-12 | `digital-brain/brain.db::external_systems` |

---

## Ecosistema de Digital Twins (14/14 activos)

| # | DT | Foco | Artefacto central |
|---|----|------|-------------------|
| 1 | [dt-almas](dt/dt-almas/CLAUDE.md) | 12 microservicios críticos del canal | `almas-appmovil.md` |
| 2 | [dt-autorizador-pagos](dt/dt-autorizador-pagos/CLAUDE.md) | Flujos CoDi / SPEI / Transferencias | `flujo-pagos-appmovil.md` |
| 3 | [dt-capacidades](dt/dt-capacidades/CLAUDE.md) | Cobertura ETB v5.0 por dominio | `capacidades-appmovil-etb.md` |
| 4 | [dt-catalogo-errores](dt/dt-catalogo-errores/CLAUDE.md) | 19 códigos de error del canal | `catalogo-errores-appmovil.md` |
| 5 | [dt-java-analysis](dt/dt-java-analysis/CLAUDE.md) | Calidad Java / ISO 5055 / deuda técnica | `analisis-calidad-appmovil.md` |
| 6 | [dt-journeys](dt/dt-journeys/CLAUDE.md) | ~24 customer journeys del canal | `journeys-catalog-appmovil.md` |
| 7 | [dt-modelo-dominio](dt/dt-modelo-dominio/CLAUDE.md) | Bounded contexts / capas / dependencias | `modelo-dominio-appmovil.md` |
| 8 | [dt-reglas](dt/dt-reglas/CLAUDE.md) | Reglas de negocio del canal | `catalogo-reglas-appmovil.md` |
| 9 | [dt-regulatorio](dt/dt-regulatorio/CLAUDE.md) | CNBV / Banxico / PCI-DSS | `marco-regulatorio-appmovil.md` |
| 10 | [dt-riesgos](dt/dt-riesgos/CLAUDE.md) | 14 riesgos de migración del canal | `registro-riesgos-appmovil.md` |
| 11 | [dt-sp-dependencies](dt/dt-sp-dependencies/CLAUDE.md) | **Puente JDBC → SPs Informix** (crítico AM) | `inventario-sp-dependencies.md` |
| 12 | [dt-spei](dt/dt-spei/CLAUDE.md) | Flujo SPEI saliente + CoDi interbank | `flujo-spei-appmovil.md` |
| 13 | [dt-brain-auditor](dt/dt-brain-auditor/CLAUDE.md) | Meta-agente: smoke tests de los 14 DTs | `reporte-validacion-appmovil.md` |
| 14 | [dt-vocabulario](dt/dt-vocabulario/CLAUDE.md) | Vocabulario de negocio y técnico del canal | `vocabulario-appmovil.md` |

---

## Estado del Brain (2026-11-03)

| Métrica | Valor |
|---------|-------|
| Microservicios analizados | **215 / 215** con código Maven real |
| Almas identificadas | 12 |
| Referencias a SPs Informix | 141 (28 Java, 113 properties) |
| Pares base-SP detectados | **53** en 11 BDs, sobre 52 nombres distintos de SP |
| Inventario real de SPs | **56** nombres: los 52 detectados más 4 verificados a mano |
| Bases de datos Informix | 11 (`bdisac` 17, `bdicred` 15, `bdicheq` 9, `bdisolic` 4, `intercard` 3, `bdispei` 3, `bdinteg` 2, `bdiprog` 1, `bdinvers` 1, `bdimnsj` 1, `bdibpi` 1) |
| Endpoints REST | 52 |
| Términos vocabulario | 4,291 |
| Reglas de negocio | 2,997 |
| Incidentes por Control de Cambios | 16 (8 tocan el canal) |
| Dependencias Feign | 16 |
| MSAs con Informix (pom.xml) | 77 |
| MSAs con MongoDB | 122 |
| MSAs con Redis | 63 |

### Identidad del componente: el repositorio, no el `artifactId`

Hasta el 2026-11-03 `services.id` era el `artifactId` del `pom.xml`, y eso perdía
37 de los 215 componentes por colisión de clave. Las causas son dos y ambas son
hallazgos sobre el código, no sobre el brain:

1. **Las variantes `-b` no renombran su `artifactId`.** De los 39 repos que
   terminan en `-b`, 35 declaran el mismo `artifactId` que su gemelo, así que el
   `INSERT OR REPLACE` los sobreescribía. Hoy el brain ve las 39 variantes, que
   antes eran invisibles.
2. **Tres repos nunca renombraron el scaffold.** `msach-b-business-application-video-tours`,
   `msach-d-business-credit-cards-accounts` y `msacm-b-business-codi-agreement-management`
   siguen declarando `artifactId = jso-fwk-hello-service`. Los tres colapsaban en
   una sola fila con nombre de plantilla.

En total **41 componentes tienen `artifactId` distinto del nombre de su repositorio**.
La identidad canónica es el repositorio, que es además la que ya usaban
`load_sp_calls`, `load_endpoints` y `load_terms`. El `artifactId` se conserva en la
columna `services.artifact_id` para poder auditar la divergencia:

```sql
SELECT id, artifact_id FROM services WHERE artifact_id <> id;
```

### Patrones de SP Discovery — Estado

| Patrón | Descripción | Estado |
|--------|-------------|--------|
| P1 | `{call db:sp(...)}` en `*Constants.java` | ✅ Activo |
| P2 | `EXECUTE PROCEDURE db:sp(...)` en `*Constants.java` | ✅ Activo |
| P3/P4 | CALL patterns en `.properties` | ✅ Activo |
| P5 | `db:sp_name` plain en `.properties` | ✅ Activo |
| P6c | `"db:sp_name"` o `"db:informix.sp_name"` plain string en Java | ✅ Activo (2026-08-14) |
| P6d | `"db\\:sp_name"` escaped-colon en Java (solo sin qualifier `informix.`) | ✅ Activo (2026-08-14) |
| P_DBINFER | SP sin prefijo en properties; DB inferida del JDBC URL (single-datasource) | ✅ Activo (2026-08-14) |
| P9 | `db\:"informix".sp_name(` — colon escapado con el qualifier entrecomillado | ✅ Activo (2026-11-03) |
| P10 | `{call sp(...)}`, `CALL sp(...)` o `"sp_name"` sin prefijo de base; DB inferida del datasource del repo | ✅ Activo (2026-11-03) |
| P8 | `configMap.yml` scanned como properties adicionales | ✅ Activo (2026-08-14) |

### Fuente y pipeline de rebuild

El código vive en `source/code/`, una carpeta por repositorio de Azure DevOps
(organización `Servicios-Financieros-GC`, proyecto `BanCoppel-App-BackEnd`). Son
218 repos clonados en `master`: 215 con código Maven real, 15,879 archivos Java y
1.6 GB. Los 3 restantes (`msadp-d-domain-digital-envelope-management`,
`-movements` y `-transactions`) son cascarones con solo `README.md`. De la lista
de 219 falta `msasr-d-serv-benefits-loyalty-plan`, que devuelve `TF401019` con el
PAT usado.

Todo `source/` está fuera de git por la Regla P1, así que el fuente no aparece en
el repositorio de Digital Core. Para re-descargarlo o actualizarlo:

```bash
cd systems/channels/AppMovil/source
export user_password='usuario:PAT'      # PAT con scope Code (Read)
./clone-repositories.sh                 # idempotente: los clones existentes solo se actualizan
```

El rebuild completo, brain y portal, es un solo comando:

```bash
python rebuild-portal.py            # brain y vistas
python rebuild-portal.py --portal   # solo las vistas, sin re-minar el fuente
```

Por dentro corre siete pasos en este orden, que no es negociable:

```bash
python digital-brain/build-brain.py            # servicios, SPs, endpoints, términos, deps
python generators/extract-rules-java.py        # catálogo de reglas (poda las obsoletas)
python generators/build-java-analysis.py       # métricas de calidad para dt-java-analysis
python generators/build-rules-portal.py        # vista: catálogo de reglas
python generators/build-sp-portal.py           # vista: dependencias SP
python generators/build-vocab-portal.py        # vista: vocabulario
python generators/build-portal.py              # landing
```

`build-brain.py` hace drop y recrea sus tablas, así que es idempotente. El
extractor de reglas hace upsert por id y **elimina las reglas que el fuente ya no
produce**; sin esa poda la tabla acumulaba entre cortes del fuente y mostraba
reglas de código que ya no existe. El upsert nunca toca `business_name`: el
enriquecimiento por síntesis LLM (ADR-SPE-AM-010) sobrevive a cada re-extracción.
Para conservar las obsoletas, `--no-prune`.

**El orden importa: el vocabulario alimenta las reglas.** `extract-rules-java.py`
lee `brain.db::terms` y con esos términos arma el patrón que ancla la detección
de reglas financieras. Si corre antes de `build-brain.py`, extrae contra el
vocabulario de la corrida anterior. Al ampliar el minero de vocabulario el
2026-11-03, las reglas pasaron de 2,808 a 2,997 sin tocar el extractor: 284
nuevas ancladas en términos que antes no existían y 95 que colgaban de términos
de ruido ya eliminados.

**Límite abierto:** la consulta de vocabulario del extractor termina en
`LIMIT 2000`, así que de los 4,291 términos del brain solo 2,000 anclan reglas.
No hay `ORDER BY`, de modo que el subconjunto depende del orden de inserción.
Hoy es estable y reproducible, pero subir o quitar ese límite cambiaría el
catálogo de reglas y es una decisión pendiente, no un defecto latente.

### Corpus documental: incidentes por Control de Cambios

`source/docs/` guarda los dos reportes corporativos de incidentes originados por
Controles de Cambio. No son código, así que no entran por `build-brain.py`, que
se reconstruye del fuente Java; entran por su propio camino:

```
source/docs/*.docx                        los dos reportes
  -> generators/extract-incidents.py      normaliza, fusiona y clasifica
  -> knowledge-base/incidentes-cc.json    la fuente estructurada
  -> generators/load-incidents.py         brain.db::incidents
  -> generators/build-incidents-portal.py portal/incidentes-cc.html
```

El consolidado cubre todo BanCoppel de enero al 2 de noviembre de 2026 con 15
incidentes; el del canal acota a App BanCoppel de mayo a noviembre con 6. El
segundo es casi un subconjunto del primero, con redacción operativa más detallada
y la cronología de cada caso. Se fusionan por la llave natural de fecha, folio de
incidente y folio de CC, y quedan **16 incidentes**, de los que **8 tocan el canal**.

Dos detalles del extractor que no son obvios y conviene no deshacer. Cuando un
incidente no trae folio ni CC, la fecha sola no alcanza como llave: el 14 de enero
hay dos incidentes distintos sin folio y uno pisaba al otro, así que entra la
aplicación para desempatar. Y la cronología de cada caso se amarra por los folios
que cita el párrafo, pero un párrafo que menciona tres o más folios no narra un
caso: es la lista de fuentes, y si se deja se pega a todos los incidentes que nombra.

**Lo que no se infiere.** Tres incidentes quedan con `patron = 'sin_clasificar'`
porque el reporte registra el síntoma y la clasificación de causa, pero no el
mecanismo técnico. Siete no tienen folio de CC visible. Ambas cosas se muestran
tal cual en la vista en lugar de rellenarse.

El cruce de este corpus contra el registro preliminar de riesgos vive en
[dt-riesgos/registro-riesgos-appmovil.md](dt/dt-riesgos/registro-riesgos-appmovil.md):
cinco riesgos pasan de hipótesis a evidencia, dos se matizan y tres son nuevos.

### El portal sigue el canon de Informix

El formato del portal de `systems/core/Informix/portal/` es el canon del
proyecto. AppMovil lo replica en forma y en fondo, y la fidelidad está medida:
los 81 selectores que comparten las hojas de estilo son **idénticos al carácter**,
y los tokens de paleta (`--blue`, `--yellow`, `--ink`, `--muted`) son los mismos.

**Dos arquetipos de página.** La landing lleva barra `nav`, aurora animada,
secciones y tarjetas de vista. Las páginas de contenido llevan `hero-bar` con
logo, migaja y enlaces de vuelta; luego `head` con kick, titular, intro y
bloques de métrica; después una barra de filtros pegajosa; y cierran con pie de
procedencia. El chrome vive en `generators/_canon.py`, cuya hoja de estilos está
tomada literal de `Informix/generators/build-test-catalog.py` para que ambos
portales se vean iguales de verdad y no parecido.

**Ningún HTML se escribe a mano.** Cada vista tiene su generador y cada cifra
sale de `brain.db` o del conocimiento curado en `knowledge-base/`:

| Vista | Generador | Fuentes |
|-------|-----------|---------|
| `index.html` | `build-portal.py` sobre `_landing.html` | brain, vocabulario curado |
| `rules-appmovil.html` | `build-rules-portal.py` | `brain.db::rules` |
| `sp-dependencies.html` | `build-sp-portal.py` | brain más `knowledge-base/sp-curado.json` |
| `vocabulario.html` | `build-vocab-portal.py` | `knowledge-base/vocabulario-curado.json` más `brain.db::terms` |
| `incidentes-cc.html` | `build-incidents-portal.py` | `brain.db::incidents` |

La landing es la excepción parcial: lleva ilustración SVG propia, así que su
maqueta vive en `generators/_landing.html` con tokens `__MSAS__`, `__SPS__` y
demás, y el generador solo inyecta las cifras.

**El conocimiento curado salió del HTML.** Hasta el 2026-11-04, los 196 términos
del glosario y el catálogo de 50 SPs con su función, criticidad y evidencia
vivían dentro del marcado, donde ningún proceso podía leerlos. Ahora están en
`knowledge-base/vocabulario-curado.json` y `knowledge-base/sp-curado.json`, que
son la fuente y sobreviven a cualquier regeneración.

**La costura entre lo detectado y lo curado se muestra, no se esconde.** La
vista de SPs marca cuáles encontró el análisis estático y cuáles están
verificados a mano, y explica por qué la inferencia no los alcanza. La de
vocabulario separa la capa curada de los 4,291 términos minados, que son materia
prima sin significado escrito.

### Gap Residual (4 SPs de 56)

El barrido de SPs pasó de `*Constants.java` a todos los `*.java` del canal, y
con los patrones P9 y P10 recuperó 4 SPs que el catálogo curado del portal sí
tenía: `sp_consulta_saldos_general`, `sp_prestamoflex_multicanal`,
`sp_graba_prod_upgrade` y `sp_clona_tdc_upgrade`. Quedan 4 fuera:

| SP | DB | Motivo no capturado |
|----|----|--------------------|
| `sp_valida_celular_cancelado` | bdinteg | `EXECUTE PROCEDURE` con la base concatenada desde una variable; no es parseable de forma estática |
| `sp_activatarjeta_iccat` | intercard | Nombre sin prefijo de base y el repo declara dos datasources |
| `sp_registro_cte_cvv2din` | intercard | Nombre sin prefijo de base y el repo declara dos datasources |
| `sp_proyecta_prest_credisol` | bdicred | Nombre sin prefijo de base y el repo declara dos datasources |

Los tres últimos comparten causa: `infer_db_from_repo` solo resuelve cuando el
microservicio tiene un único datasource Informix. Con dos o más devuelve nada a
propósito, porque ubicar un SP en la base equivocada es peor que no registrarlo.
Ese es también el motivo por el que el portal declara 56 SPs y el brain 52: la
diferencia es conocimiento curado que la inferencia estática no alcanza.

**Al barrer todo el Java aparecen tablas disfrazadas de SP.** Las referencias
`FROM bdicred\:sd_maecredcrd` y `@Table(name = "bdisac:sac_servicios_cpl")`
tienen la misma forma que una llamada a procedimiento. Se descartan por el
contexto que las precede, no por una lista de prefijos: tras `FROM`, `JOIN`,
`INTO`, `UPDATE` o `@Table` hay una tabla, nunca un procedimiento.

### Próximos Pasos

- [x] Ecosistema de 14 Digital Twins completo (2026-08-13)
- [x] Construir `digital-brain/build-brain.py` — brain.db activo (2026-08-14)
- [x] Patrones P6c/P6d/P_DBINFER/P8 implementados — 49 SPs (2026-08-14)
- [x] Patrones P9/P10 y barrido sobre todo el Java — 53 pares, 52 nombres (2026-11-03)
- [x] **dt-java-analysis poblado** — `analisis-calidad-appmovil.md` construido desde análisis estático de 216 repos (2026-08-14)
- [x] **Rebuild sobre el fuente completo** — 215 MSAs, identidad por repositorio, reglas podadas (2026-11-03)
- [x] **Re-correr `dt-java-analysis` sobre los 215 componentes** — artefacto v2.0.0 desde `generators/build-java-analysis.py` (2026-11-03)
- [ ] Ejecutar Brain Auditor: smoke tests de los 14 DTs (pase de existencia)
- [ ] Poblar artefactos centrales de DTs restantes (dt-riesgos · dt-regulatorio · dt-sp-dependencies · dt-modelo-dominio)
- [ ] Emitir seeds propios (Regla B11) al terminar el rebuild con patrones P6-P8
- [ ] Actualizar `bank-brain/build-bank-brain.py` con ATTACH a este brain

## Evidencia de ejecución: el primer log de pod (2026-11-07)

Hasta hoy todo lo que este brain sabía venía del análisis estático de los 215 repositorios. Llegó el primer log de producción y confirma que hacía falta.

Es un pod de OpenShift del microservicio `msach-o-business-deposit-account-validation`, variante B, réplica 28. 88,464 líneas, 2,248 transacciones, del 30 de octubre entre las 16:59 y las 17:30.

### Por qué este formato vale

Cada línea trae el nivel, la marca de tiempo al milisegundo, la clase, el método y la línea exacta, un identificador de correlación y, entre corchetes, **el nombre de negocio en español escrito por el propio desarrollador**:

```
INFO, 2026-10-30 17:00:23,353, c.b.a.v.b.OtpBusiness:findByDeviceId...:121,
23c91d88-..., Tx REPOSITORY CALL - [Consulta otp por dispositivo y telefono - validate], 302
```

Eso resuelve de un golpe lo que la Regla V1 pide: el `business_name` no se infiere con heurísticos, viene del código. Son 27 operaciones distintas, entre ellas "Recupera la información general de una cuenta.", "Consulta el MTU del cliente" y "Recupera la bandera para saber si hay contingencia spei".

El identificador de correlación reconstruye el árbol de llamadas completo de cada transacción, y la clase con su número de línea amarra cada paso al código ya clonado en `source/code/`.

### Lo que dice la evidencia

| Métrica | Valor |
|---------|-------|
| Transacciones | 2,248, de ellas 29 con error |
| Endpoint observado | `/api/public/v4/dept/ca/val`, el único del servicio |
| Duración de la transacción | p50 2,947 ms, p95 3,632 ms, máximo 17,198 ms |
| Operaciones de negocio distintas | 27 |
| Pasos registrados | 79,637 |
| Códigos de error | 4 |

**Validar una cuenta de depósito tarda tres segundos en la mediana.** Para una pantalla de app móvil eso se siente, y el p95 apenas mejora: 3.6 segundos. La cola es peor, con un máximo de 17 segundos.

**El 88 por ciento de ese tiempo no está instrumentado.** El aspecto que envuelve la petición mide 2,944 ms en la mediana, pero la suma de los pasos hijos que la bitácora sí registra da 343 ms. Quedan 2,598 ms dentro de código que no deja traza. El pod trae el agente de OpenTelemetry inyectado, así que ese tiempo probablemente sí existe en las trazas de APM; en este log no. Antes de teorizar sobre la causa conviene pedir la traza correspondiente.

### Producción no corre lo que dice el repositorio

| Fuente | Versión | Java |
|--------|---------|------|
| Catálogo estático, del `pom.xml` | ALFA-2.3.0 | 17 |
| Pod en producción | vB-2.0.5 | 21.0.6 |

Las dos difieren, y en sentidos opuestos: el repositorio declara una versión más nueva y un Java más viejo que el que realmente corre. Esta es la razón de ser de la evidencia de ejecución y conviene extenderla al resto de los componentes antes de apoyar cualquier decisión de migración en las versiones del `pom.xml`.

### Los errores traen el texto que ve el cliente

| Código | Veces | Mensaje al cliente |
|--------|------|--------------------|
| `000063` | 18 | ¡Ups! Cuenta CLABE no valida. |
| `000052` | 9 | ¡Recuerda! Para enviar dinero a otro banco ingresa una cuenta CLABE |
| `000901` | 6 | Algo ha salido mal!! |
| `000902` | 1 | Falta de credenciales/Credenciales invalidas |

Los cuatro los levanta la misma validación, "Revisa que la cuenta de depósito de destino sea válida". Dos son de captura del usuario y se esperan; `000901` es genérico y vale la pena mirarlo.

El arranque regala además las seis entidades que declara Spring Data: `BankRepository`, `CellphoneCustomerEnrollmentRepository`, `CustomerRepository`, `DailyFrequentAccumulatedAmountsRepository`, `ServicesConfigRepository` y `UnlimitedAccountTransactionRepository`.

### La advertencia

Son **32 minutos de un pod de uno de los 215 microservicios**, en la tarde de un viernes. Ninguna cifra de arriba describe la operación del canal: describen media hora de un servicio. Ya pasó con e-global, donde las conclusiones de una ventana de veinte minutos se cayeron enteras al llegar el día completo.

### Pipeline

```bash
python generators/parse-pod-logs.py      # destila source/logs/ a knowledge-base/runtime-pods.json
python generators/load-pod-runtime.py    # materializa en brain.db::runtime_*
```

Las tablas `runtime_pods`, `runtime_operations`, `runtime_endpoints` y `runtime_errors` llevan el lote en la llave primaria, así que dos capturas del mismo servicio en ventanas distintas conviven sin pisarse. Viven fuera de `build-brain.py` y sobreviven a sus rebuilds, igual que `incidents`.

El log no registra payloads ni datos de cliente, verificado con barrido de CLABEs, PANs, teléfonos, tokens y CURP. Aun así el extractor sólo persiste catálogos, conteos y estadísticas de latencia, y enmascara cualquier tira larga de dígitos que apareciera en una versión futura.

---

---

*Generado automáticamente por `bank-brain/bootstrap-from-seeds.py` · 2026-08-12 · Regla B9 AM*
*Actualizado: 2026-08-14 — brain.db ACTIVO · 49 SPs únicos · 11 BDs Informix · 133 refs · patrones P6-P8 implementados*
*Actualizado: 2026-08-14 — dt-java-analysis: 216 repos analizados · 60 legacy · viabilidad 2027 evaluada*
*Actualizado: 2026-11-03 — rebuild sobre el fuente completo. `services.id` pasa a ser el repositorio y no el `artifactId`, lo que recupera 37 componentes que se perdían por colisión de clave (215 MSAs). El clonador queda en `source/`, junto al código que produce. El extractor de reglas poda las obsoletas, lo que retiró 110 reglas de agosto que el fuente ya no produce. Corregido el prefijo de dominio del alma de notificaciones push, que estaba escrita `msamg-` cuando el repositorio es `msaim-`, y por eso faltaba la alma 12.*
*Actualizado: 2026-11-03 (2) — el minero de vocabulario pasa de `constant/Constants.java` a `*Constants.java`, el mismo patrón amplio que ya usaba el descubrimiento de SPs. Dejaba fuera 17,098 constantes en 947 archivos, sobre todo los `ApiConstants.java`. Términos de 2,591 a 4,291, con 603 términos de ruido eliminados de la base anterior (placeholders `${...}`, plantillas de log y pointcuts AOP). Como el extractor de reglas se ancla en el vocabulario, las reglas suben de 2,808 a 2,997 sin tocar su código.*
*Actualizado: 2026-11-03 (3) — el descubrimiento de SPs deja de leer solo `*Constants.java` y barre todo el Java del canal, con dos patrones nuevos: P9 para el colon escapado con qualifier entrecomillado y P10 para SPs sin prefijo de base, resueltos contra el datasource del repo. Recupera 4 SPs que el catálogo curado tenía y el brain no veía, y el hueco residual queda documentado en 4 de 56, todos por ambigüedad real de base. Al ampliar el barrido aparecieron tablas con forma de SP (`FROM db\:tabla`, `@Table(name=...)`) que se descartan por contexto. Los cuatro HTML del portal quedan alineados al brain.*
*Actualizado: 2026-11-04 — el portal pasa al canon de Informix. Los cuatro HTML dejan de escribirse a mano y los produce un generador por vista, con el chrome compartido en `generators/_canon.py`: 81 selectores idénticos al carácter contra el portal de Informix. El conocimiento curado que vivía dentro del marcado (196 términos y 50 SPs con su función, criticidad y evidencia) se rescató a `knowledge-base/`. AppMovil estrena logo propio, en vez de apuntar a la carpeta de Informix, y `rebuild-portal.py` reconstruye brain y portal de punta a punta.*
*Actualizado: 2026-11-04 (2) — entra el corpus documental de incidentes por Control de Cambios. Los dos reportes de `source/docs/` se normalizan a `knowledge-base/incidentes-cc.json`, se cargan a `brain.db::incidents` y salen en una quinta vista del portal. El cruce contra el registro preliminar de riesgos puebla `dt-riesgos`, que estaba sin artefacto: cinco riesgos tenían evidencia en producción y nadie los había conectado.*
*Actualizado: 2026-11-07 — entra la primera evidencia de ejecución del canal: un log de pod de OpenShift del servicio de validación de cuenta de depósito. Aporta 27 operaciones de negocio con su nombre en español escrito por el desarrollador, el árbol de llamadas por transacción y la latencia por paso. Tres hallazgos: validar una cuenta tarda 2,947 ms en la mediana, el 88 por ciento de ese tiempo no está instrumentado, y la versión que corre en producción no es la que declara el `pom.xml`.*
