# Exodus — Programa de Migración de Datacenters a la Nube (BanCoppel)
# project_type: datacenter-exit-and-cloud-migration
# project_state: active
# platform: AWS EKS + YugabyteDB + Kafka/Debezium CDC
# horizon_present: 636 hosts on-premise en 3 sites (Ciudad de México, Monterrey, Culiacán)
# horizon_future: apagado total de datacenters México y decomiso de Informix
# replaces_or_complements: complementa a projects/unity (Exodus migra, Unity construye el TO-BE)

> **Tipo:** Programa de migración de infraestructura y refactorización de legado
> **Estado:** `[STATE: ACTIVE]` — Ola 0 en curso (Q3–Q4 2026)
> **Horizonte:** 2026 a 2030, con meta interna de diciembre 2029
> **Descubierto:** 2026-08-19, por barrido documental del corpus de Unity
> **Última actualización:** 2026-08-19

---

## ¿Qué es Exodus?

Programa de **salida de los datacenters de México hacia la nube**, con el apagado de Informix como hito de cierre. Cita literal del informe ejecutivo:

> *"INFORME EJECUTIVO: PROGRAMA EXODUS — BANCOPPEL / ESTRATEGIA DE MIGRACIÓN DATACENTERS MÉXICO A LA NUBE (2026 - 2030)"*

| Métrica declarada | Valor |
|---|---|
| Oleadas | 6 operativas más Ola 0 de habilitación |
| Servidores a desactivar | 636 hosts on-premise |
| Stored procedures a refactorizar | 7,480 (cabecera Exodus) / 41,779 (xlsx banco, 32K estimados) |
| Aplicaciones core involucradas | 7 (Exodus) / 124 total inventario banco |
| Volumetría agregada | 31.2M operaciones por día |
| Cobertura con plataformas objetivo | 68% (Temenos Transact, SmartVista, Apolo) |

**Estrategia**: *"Estrategia de estrangulamiento (Strangler Fig Pattern) exponiendo APIs sobre la réplica YugabyteDB con CDC Debezium antes del reemplazo del backend."*

**Stack objetivo**: Java 21 con Spring Boot 3 sobre EKS, YugabyteDB, Kafka y Debezium para CDC, MuleSoft y Apigee con OpenAPI 3.0, Snowflake o Databricks para el DWH.

---

## Relación con Unity — son programas distintos

> **Regla de oro**: Exodus **no es parte de Unity**. Son dos programas con horizontes, patrocinios y planes separados que comparten el mismo legado como objeto.

| Dimensión | Unity | Exodus |
|-----------|-------|--------|
| Qué hace | Construye el TO-BE: productos nuevos sobre Transact y SmartVista | Migra el AS-IS: saca cargas del datacenter y refactoriza SPLs |
| Horizonte | Releases R1 a R4+, go-live enero 2027 | 6 olas semestrales, 2027 a 2029 |
| Unidad de trabajo | Producto y release | Ola y aplicación |
| Relación con Informix | Coexistencia | **Apagado** |

Ningún documento de Exodus menciona Unity por su nombre. En sentido inverso, los hallazgos de Unity tratan a Exodus como tercero al que alinearse: *"Evalúe el alineamiento con las iniciativas ACDC y Exodus"*. Y Exodus asume el TO-BE de Unity como destino, con 68% de cobertura declarada.

> **Existe un tercer programa: ACDC.** Iniciativa corporativa de migración a la nube, par de Exodus. No tenemos ningún documento suyo. Registrado como dependencia en el brain.

---

## Las 6 olas

| Ola | Horizonte | Alcance | Apps | Hosts | Ops/día | SPLs |
|-----|-----------|---------|------|-------|---------|------|
| **0** | Q3–Q4 2026 | Habilitación: contratos OpenAPI 3.0, réplica CDC de Informix a YugabyteDB, cluster Yugabyte, gobierno de APIs | — | 0 | 0 | 0 |
| **1** | 2027-H1 | Canales digitales, pagos SPEI y réplica core YugabyteDB | 10 | −164 | 4.55M | −970 |
| **2** | 2027-H2 | Operación de sucursales, remesas y servicios centrales | 9 | −138 | 2.15M | −620 |
| **3** | 2028-H1 | Red de cajeros ATM, domiciliación y corresponsalías | 5 | −92 | 3.74M | −480 |
| **4** | 2028-H2 | Banca empresarial, crédito corporativo y tesorería | 2 | −48 | 0.12M | −410 |
| **5** | 2029-H1 | Módulos del core bancario: créditos, cheques e inversiones | 1 | −110 | 10.40M | **−3,200** |
| **6** | 2029-H2 | Cierre de datacenter, contabilidad core y **apagado de Informix** | 3 | −84 | 0.50M | −1,800 |

**Regla de secuenciación declarada**: *"Distribución balanceada de aplicaciones de alta demanda a lo largo de las Olas 1 a 5, prohibiendo más de 2 sistemas críticos por ola."*

La Ola 0 no tiene ficha propia; solo aparece en el informe ejecutivo. Por eso el brain tiene W1 a W6.

---

## ⚠️ Las cifras de Exodus no reconcilian internamente

Verificado con `brain.py reconciliation` y cruzado contra el brain de Informix. **Hay tres capas de números que no cuadran entre sí**, y la diferencia es material para cualquier estimación.

| Fuente | SPLs | Método |
|--------|------|--------|
| Exodus cabecera (informe ejecutivo) | **7,480** | Top-down, sin metodología documentada |
| Exodus suma por aplicación (fichas de ola) | **34,728** | Suma de estimaciones por app (3 apps declaran 10K c/u) |
| Xlsx banco — total declarado (124 apps) | **41,778** | Auto-reporte de app owners (EXO-Q08: unidad sin confirmar) |
| **Brain Informix — parseo de código fuente** | **11,391** | Conteo empírico de archivos `.sql` en 53 DBs ← verdad |

**Discrepancia Exodus vs. código real: +3,911 SPs no contemplados.**
El brain tiene 11,391 SPs; Exodus planea migrar 7,480. La diferencia (~34%) no está asignada a ninguna ola ni a decommission. Posibles explicaciones:
- Los 7,480 son solo los SPs de las ~30 apps en scope de Exodus (no el universo completo de 53 DBs)
- Hay SPs en bases de datos auxiliares (respaldos, reporting) que Exodus no considera migrables
- La cifra 7,480 es planeación sin base en conteo real

| | Cabecera de ola | Suma por aplicación | Delta interno |
|---|---|---|---|
| Hosts a liberar | 636 | **275** | −361 |

La causa de la inflación en la suma por app es que **tres aplicaciones declaran exactamente 10,000 cada una**: Interact Router (ID-15), Oficina Financiera Integral (ID-58) y SIWEB (ID-60). Son números redondos, no conteos.

Hay además una quinta cifra: la sección de riesgos del propio informe dice *"10,000+ SPLs a Reemplazar"* mientras el cuadro de métricas dice 7,480.

> **Postura**: la única cifra con base empírica son los **11,391 SPs del brain de Informix** (parseo de fuente, 2026-08-20). Exodus subestima el universo en al menos 3,900 SPs. Antes de comprometer un roadmap de migración, Exodus necesita reconciliar su scope contra el inventario real del brain.

Otras inconsistencias verificadas: la volumetría por ola suma 21.46M contra los 31.2M declarados como total, y las olas cubren ~30 sistemas contra 116-129 del Anexo 5 (24% del inventario del legado).

---

## Assessment APO por aplicación

Las fichas traen un assessment completo por aplicativo: clasificación APO con racional, complejidad técnica, puntaje de obsolescencia de 0 a 10 con drivers, racional de asignación a la ola, APIs objetivo sugeridas, golden records relacionados, capacidades de interoperabilidad y entidades de datos en YugabyteDB.

| Clasificación APO | Apps | SPLs declarados |
|---|---|---|
| Invertir (Innovar) | 11 | 12,366 |
| Tolerar (Mantener) | 7 | 331 |
| Migrar (Transformar) | 9 | 1,731 |
| Eliminar (Deprecar) | 3 | 20,300 |

> **Contradicción a escalar**: **SIWEB está clasificado "Eliminar (Deprecar)"** en el assessment APO, y simultáneamente es uno de los cinco tracks de desarrollo activo de Unity R4, con HDUs propias (HDU-SIWEB-R4-01 a 05). Se está invirtiendo desarrollo en un aplicativo clasificado para decomiso.

---

## Procedencia de las fuentes

Los documentos de Exodus llegaron dentro del corpus de Unity, en `projects/unity/source/docs/InformaciónCompartidaBCP/Exodus/`. Al abrir este proyecto se **copiaron** aquí, dejando los originales en su lugar.

> **Duplicación consciente y pendiente de resolver**: los 13 archivos existen en dos rutas. La copia canónica para este programa es `projects/exodus/source/docs/`. Decidir con el owner si se retiran los originales de Unity o si se dejan como registro de cómo llegaron.

---

## Brain

`digital-brain/brain.db` se construye parseando las fichas de ola. Las fichas tienen extensión `.doc` pero **son HTML con BOM UTF-8**, no binario de Word: por eso fallan los extractores convencionales.

```bash
python digital-brain/build-brain.py --dry-run   # valida el parseo sin escribir
python digital-brain/build-brain.py             # construye brain.db
python digital-brain/brain.py coverage
python digital-brain/brain.py waves
python digital-brain/brain.py reconciliation     # el contraste de cifras
python digital-brain/brain.py components --wave W5 --core-only
python digital-brain/brain.py questions
```

| Tabla | Registros | Contenido |
|-------|-----------|-----------|
| `program_info` | 1 | Métricas, horizonte, estrategia y stack objetivo |
| `waves` | 6 | W1 a W6 con alcance, impacto, ámbito CDC y riesgos |
| `applications` | 30 | Assessment APO completo por aplicativo |
| `cross_dependencies` | 8 | Informix, Unity, App Móvil, SPEI, E-Global, DataStage, Contabilidad, ACDC |
| `open_questions` | 7 | EXO-Q01 a Q07 |
| `applications_fts` | vista | Búsqueda fulltext |

`brain.py` implementa la interfaz estándar de 5 métodos (`coverage`, `components`, `search`, `rules`, `domains`) más `reconciliation`, `cross_dependencies` y `questions`. El método `rules` no devuelve reglas de negocio: Exodus declara el **alcance** de SPLs a refactorizar, y las reglas extraídas viven en el brain de Informix.

---

## Preguntas abiertas

| ID | Pregunta | Por qué importa |
|----|----------|-----------------|
| EXO-Q01 | ¿Quién patrocina Exodus y con qué presupuesto? | Solo se documenta que Edgar Mejía *"está iniciando"* el programa. Cero menciones de sponsor ejecutivo, presupuesto aprobado, integrador contratado o gobierno en las 7 fichas |
| EXO-Q02 | ¿El decomiso de Informix es de Exodus o de Unity? | El business case de Unity dice que *"el decomiso de PISA es parte central del ahorro proyectado"*, pero el apagado está planeado en Exodus Ola 6. Si es de Exodus, el business case de Unity descansa sobre el roadmap de otro programa sin dueño compartido |
| EXO-Q03 | ¿Cuántos stored procedures hay realmente? | Inventario verificado (2026-08-20): xlsx banco = 124 apps, 41,779 SPLs declarados (32,000 son estimaciones redondas en 5 apps: Interact/OFI/SIWEB=10K c/u, BUS IBM+SistFiduciario=1K c/u), orgánico verificado = 9,779. Brain parseo real = 11,391 (53 DBs). Exodus cabecera = 7,480. DA estima 13-14K sin fuente. El "17,380" mencionado en sesiones previas no corresponde al xlsx — posiblemente del systable de Informix o documento no disponible |
| EXO-Q08 | ¿Qué significa el campo `# SPL` del xlsx para apps que no usan Informix? | SPL es el lenguaje de stored procedures de Informix. Apps como Bus IBM (DB2) y Fiduciario (Oracle) declaran SPLs en ese campo, lo cual es una contradicción técnica. Tres hipótesis: (1) el banco usa "SPL" genéricamente para cualquier stored procedure de cualquier DBMS; (2) esas apps tienen una capa Informix no documentada; (3) el campo está mal llenado. Hasta aclarar esto, los 41,778 no son comparables con los 11,391 del brain — pueden ser unidades distintas. Requiere sesión con los dueños del xlsx o con el DBA IBM Informix para confirmar. |
| EXO-Q04 | ¿Por qué Exodus consolida en Apigee si Unity lo declara EOL 2027? | Ola 1 dice *"Mantener y migrar su gateway a Apigee"*. El Plan Director de Unity declara Apigee EOL 2027 con migración a MuleSoft. Los Lineamientos StackTech ofrecen una tercera opción. Tres direcciones incompatibles |
| EXO-Q05 | ¿Exodus cubre solo el 24% del legado? | Las olas suman ~30 sistemas contra 116-129 del Anexo 5. Qué pasa con el resto no está documentado |
| EXO-Q06 | ¿Cuál es la volumetría real? | 31.2M declarado contra 21.46M sumado por ola |
| EXO-Q07 | ¿Dónde caen los reportes regulatorios? | Ola 6 declara migrar *"Reportes Regulatorios CNBV"* pero su lista es de 3 sistemas y las apps 96, 97 y 100 no aparecen en ninguna ola |

---

## Riesgos declarados en el informe ejecutivo

- **Tiempo de migración por app core de 10 a 12 meses**: *"Sistemas Core como SOC y Créditos involucran miles de SPLs y dependencias entrelazadas, requiriendo fases híbridas prolongadas."*
- **Volumetría alta**: aplicaciones con millones de operaciones diarias (SOC, BPI, SPEI, ATMs) representan riesgo operacional si se agrupan.
- **Dependencia de Informix**: la lógica de negocio central vive en SPL sobre AIX con *"acoplamiento severo"*.
- **Cumplimiento del objetivo 2030**: seis olas de seis meses desde 2027, con 12 meses de margen antes del límite.

> **Nota de versión**: el informe dice *"Informix 12 alberga la lógica de negocio central"*. Eso está desactualizado. El log de la instancia productiva dice `IBM Informix Dynamic Server Version 14.10.FC10W2`. Prevalece la instancia.

---

## Dependencias cross-programa

Declaradas en `brain.db::cross_dependencies` conforme a la Regla B5. Todas outbound desde Exodus.

| Sistema | Relación | Criticidad | Nota |
|---------|----------|-----------|------|
| `informix` | reads | critical | Exodus ejecuta el apagado. Ola 6 cierra el datacenter |
| `spei` | reads | critical | Ola 1: 19 hosts, 1.8M ops/día. El mayor volumen de la ola |
| `eglobal` | reads | critical | Ola 3 migra el autorizador a microservicios EKS |
| `contabilidad` | reads | critical | Ola 6. Declarado Core Bancario con host dedicado |
| `app-movil` | reads | high | Ola 1: 57 hosts, 12,650 ops/día |
| `datastage` | reads | high | Ola 6 hacia Snowflake o Databricks. Conecta con el gap IC-83 |
| `unity` | feeds | high | Exodus asume el TO-BE de Unity como destino |
| `acdc` | notifies | medium | Tercer programa, sin documentación |

**Pendiente de Regla B10**: propagar estas dependencias al lado receptor. El brain de Informix y el de Unity todavía no declaran su contraparte con Exodus.

---

## Próximos pasos

- [x] Estructura canónica AM creada (ADR-SPE-AM-008)
- [x] `brain.db` construido desde las 6 fichas de ola: 30 aplicaciones con assessment APO
- [x] `brain.py` con interfaz estándar de 5 métodos más `reconciliation`
- [x] 8 dependencias cross-programa y 7 preguntas abiertas registradas
- [ ] **Propagar dependencias (Regla B10)** a los brains de Informix y Unity
- [ ] Procesar `source/docs/Inventario 20260803/` — 6 xlsx, incluye `Inventario_bdanalisis.xlsx` (los 17,380 SPLs) y `Clasificacion_APO.xlsx`
- [ ] Cruzar las 30 aplicaciones de Exodus contra los 29 dominios D01-D49 del brain de Informix
- [ ] Emitir seeds (Regla B11) hacia Informix, Unity, App Móvil, SPEI, E-Global, DataStage y Contabilidad
- [ ] Conseguir documentación de **ACDC**
- [ ] Cerrar EXO-Q01 (patrocinio) y EXO-Q02 (a quién pertenece el decomiso) con el cliente
- [ ] Digital Twins en `dt/` y portal en `portal/`

---

*Creado: 2026-08-19 · v1.0.0 · Descubierto por barrido documental del corpus de Unity. Reglas B8 (evidencia operativa como prueba de existencia), B9 (acción inmediata) y B12 (el brain no arranca de cero).*
