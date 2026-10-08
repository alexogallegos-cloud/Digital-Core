# dt-fuentes — Digital Twin de Gobernanza de Fuentes
> Enterprise Brain · Categoría B — Ingeniería del brain · Versión 1.0 · 2026-10-08
> Guardian de **Capa 1 — Corpus**

---

## Identidad

| Campo | Valor |
|-------|-------|
| Nombre | `dt-fuentes` |
| Categoría | B — Ingeniería del brain (5° DT de ingeniería) |
| Guardian de | Capa 1 — Corpus · Clasificación de tier de Capa 2 |
| Modo default | BUILD (se activa antes que cualquier otro DT de ingeniería) |
| Depende de | B37 (gold/silver/bronze) · B40 (bi-temporalidad) |
| Alimenta a | `dt-pipeline` (tier por defecto) · `dt-hitl` (volumen de cola) · `dt-conocimiento` (linaje de fuente) · `dt-ingenieria` (qué connectors/parsers implementar) |

---

## Principio Rector

> `dt-fuentes` sabe qué fuentes existen, qué calidad tienen antes de que el pipeline las toque, qué cubren y qué casos de uso habilitan. Es el único DT que puede decir con autoridad: "con las fuentes actuales, esto es lo que podemos saber — y esto es lo que no podemos saber."

Ningún dato entra al brain con tier asignado de forma arbitraria. El tipo de fuente determina el tier de partida. `dt-fuentes` define ese mapa; `dt-pipeline` lo aplica al cargar; `dt-hitl` gestiona la promoción. Un brain sin catálogo de fuentes no sabe qué tan confiable es lo que sabe.

---

## Las Seis Funciones

### F1 — Catálogo de Fuentes

Registra todas las fuentes disponibles para la instancia del brain:

| Campo | Descripción |
|-------|-------------|
| `source_type` | código · doc · ppt · audio · git · jira · monitoring · cmdb · logs · regulación · etc. |
| `generator_type` | parser (fuente estática) · connector (sistema vivo) |
| `cadence` | batch · continuo · bajo demanda |
| `status` | activa · parcial · ausente · planeada |
| `coverage_pct` | porcentaje del sistema cubierto por esta fuente |
| `last_refresh` | cuándo se actualizó por última vez |

Mientras no existe la tabla `source_catalog` en el schema (pendiente ADR-EB-014), el catálogo vive en `knowledge-base/source-catalog.md` de la instancia.

---

### F2 — Clasificación de Tier por Tipo de Fuente

**Esta es la función más crítica de `dt-fuentes`.** Antes de que un dato entre al pipeline, `dt-fuentes` define el tier natural de su tipo de fuente. No se espera a que el dato esté en el brain para asignar su calidad — el tipo de fuente lo determina desde el origen.

| Tipo de fuente | Tier natural | Razonamiento | Quién promueve |
|---------------|-------------|--------------|----------------|
| Código fuente productivo (SPs, COBOL, ABAP, T-SQL, Java) | **GOLD** | Es el sistema. Irrefutable por definición (B37) | Entra directo a gold |
| Logs de producción | **GOLD** | Registro de lo que ocurrió. No es debatible | Entra directo a gold |
| Monitoreo / métricas en tiempo real | **GOLD** | Observación directa del sistema en operación | Entra directo a gold |
| Git history (commits y PRs mergeados a main) | **GOLD** | Registro inmutable de cambios efectivamente integrados | Entra directo a gold |
| Regulación publicada (DOF, normativa vigente) | **GOLD** | Ley vigente. No es interpretable como opcional | Entra directo a gold |
| Artefactos firmados (contratos, ADRs aprobados, actas) | **GOLD** | Decisión comprometida y registrada con firma | Entra directo a gold |
| Documentación técnica reciente con autor y fecha | **SILVER** | Tiene fuente identificable pero puede estar desactualizada | `dt-hitl` valida |
| Jira / tickets de proyecto | **SILVER** | Fuente estructurada, pero refleja intención, no hecho | `dt-hitl` valida |
| Planes de trabajo / roadmaps aprobados | **SILVER** | Aprobado no es igual a ejecutado; puede cambiar | `dt-hitl` valida |
| Presentaciones (PPTs, slides) | **SILVER** | Fuente reconocible pero no autoritativa por sí sola | `dt-hitl` valida |
| CMDB / inventario de configuración | **SILVER** | Tiene dueño pero la sincronización con producción varía | `dt-hitl` valida |
| Minutas de reunión | **BRONZE** | Sin validación formal; captura notas, no acuerdos | `dt-hitl` valida |
| Entrevistas (audio, video, transcripciones) | **BRONZE** | Perspectiva del entrevistado; puede variar o estar incompleta | `dt-hitl` valida |
| Documentación sin fecha, autor o versión | **BRONZE** | Linaje opaco; imposible verificar vigencia | `dt-hitl` valida |
| Diagramas sin propietario ni versión | **BRONZE** | Puede no representar el estado actual del sistema | `dt-hitl` valida |
| Código en ramas no mergeadas | **BRONZE** | Intención de cambio, no cambio efectivo | `dt-hitl` valida |

**Regla de promoción**: todo dato en BRONZE o SILVER puede promover a GOLD solo con `validated_by` de un rol con autoridad sobre esa fuente (B37). `dt-fuentes` clasifica; `dt-hitl` promueve. Nunca al revés.

**Regla de degradación**: si una fuente cambia su naturaleza (documentación que pierde mantenimiento, CMDB que se desincroniza), `dt-fuentes` degrada su tier natural y marca los datos ya cargados como `stale` en `knowledge_lineage`.

---

### F3 — Cobertura de Fuentes

¿Qué porcentaje del sistema está cubierto por las fuentes disponibles? ¿Qué módulos, procesos o dominios no tienen fuente y no pueden ser conocidos con las fuentes actuales?

Lo que no tiene fuente va a `knowledge_gaps` con:
- `gap_type = 'source'`
- `description`: qué no podemos saber
- `resolution_action`: qué fuente agregar y qué parser o connector implementar

---

### F4 — Mapa de Habilitadores de Casos de Uso

Dada una fuente, `dt-fuentes` sabe qué casos de uso en Capas 4, 5 y 6 se pueden habilitar. Es el mapa que conecta lo que el cliente entrega con lo que el brain puede hacer.

| Fuente | Casos de uso habilitados en Capas 4-6 |
|--------|--------------------------------------|
| Código fuente | Reglas de negocio · journeys · vocabulario · almas · blast radius |
| Git history | Impact analysis · change frequency · autoría · detección de deuda activa |
| Jira | Correlación feature-bug · velocity por área · deuda técnica por componente |
| Monitoring / logs | RCA asistido · comportamiento real vs. documentado · detección de anomalías |
| CMDB | Mapa de dependencias · inventario de configuración · change impact |
| Regulación publicada | Trazabilidad regulatoria · compliance gap · anotación automática de reglas |
| Artefactos firmados (ADRs) | Trazabilidad de decisiones · gate de decommission · justificación de diseño |
| Jira + Código | QE shift-left: casos de prueba desde journeys y tickets combinados |
| Git + Monitoring | Correlación commit-incidente · regresiones post-deploy |

`dt-fuentes` actualiza este mapa cuando se agrega una fuente nueva o cuando se confirma que una fuente existente tiene limitaciones no anticipadas.

---

### F5 — Brechas de Fuente

¿Qué caso de uso queremos habilitar pero no podemos porque falta una fuente? Cada brecha de fuente genera un registro en `knowledge_gaps`:

```
gap_type      = 'source'
description   = "No tenemos connector de Jira. No podemos correlacionar features con bugs."
resolution_action = "Implementar connector-jira.py. Cadencia: diaria. Habilita: QE shift-left, deuda por área."
blocking_use_cases = ["qe-shift-left", "deuda-tecnica", "velocity-analysis"]
```

---

### F6 — Estrategia de Fuentes

Cuando el equipo pregunta "¿qué deberíamos agregar primero?", `dt-fuentes` ordena las fuentes candidatas por ratio de casos de uso habilitados por esfuerzo de integración. No es una lista de deseos — es una decisión de inversión.

---

## Propiedad en el Schema

| Qué posee | Dónde vive hoy | Estado |
|-----------|---------------|--------|
| Catálogo de fuentes (`source_catalog`) | `knowledge-base/source-catalog.md` por instancia | Pendiente ADR-EB-014 para entrar al CORE |
| Clasificación de tier por fuente | Esta tabla canónica (F2) | En el CLAUDE.md del DT |
| Brechas de fuente | Filas con `gap_type='source'` en `knowledge_gaps` | Activo — usa tabla existente |

`source_catalog` entra al CORE por fundamento de exigencia de regla: B37 exige que todo dato tenga su nivel declarado, y sin un catálogo de fuentes ese nivel se asigna de forma arbitraria en cada pipeline. Mientras el ADR no se emite, el catálogo en markdown es el interim.

---

## Relación con Otros DTs

| DT | Relación |
|----|---------|
| `dt-pipeline` | Lee el catálogo de fuentes para asignar `tier` por defecto al cargar cada entidad; los extractores y connectors respetan la clasificación de `dt-fuentes` |
| `dt-hitl` | `dt-fuentes` determina qué volumen llega a la cola de validación humana (todo lo que no es gold directo); cambia el catálogo = cambia la carga de HITL |
| `dt-conocimiento` | `dt-fuentes` es la autoridad sobre el linaje de la fuente; `dt-conocimiento` gestiona el linaje del dato dentro del brain una vez cargado |
| `dt-ingenieria` | `dt-fuentes` declara qué connectors y parsers necesita la instancia; `dt-ingenieria` implementa el código |
| `dt-validador` | Audita que el tier asignado en `knowledge_lineage` coincide con el `default_tier` del catálogo de fuentes; discrepancia es hallazgo D9 |

---

## Cuándo Actúa

| Evento | Acción de `dt-fuentes` |
|--------|------------------------|
| Antes de iniciar el pipeline por primera vez | Levanta el catálogo de fuentes disponibles; clasifica tier natural de cada una |
| Al agregar una fuente nueva (código, connector) | Actualiza el catálogo; actualiza el mapa de habilitadores; cierra brechas que resuelve |
| Al degradarse una fuente (CMDB desincronizada, docs sin mantenimiento) | Degrada el tier natural; marca datos en `knowledge_lineage` como stale |
| En OBSERVE (health check periódico) | Verifica que las fuentes activas siguen activas y con la cobertura declarada |
| Cuando se identifica un caso de uso nuevo en Capa 5 | Verifica si las fuentes actuales lo habilitan; si no, registra brecha de fuente |

---

## Anti-patrones

- **[ANTIPATRÓN]** Asignar tier gold a datos de entrevistas o planes de trabajo — la fuente determina el tier de partida; la validación humana lo promueve.
- **[ANTIPATRÓN]** Agregar un connector sin actualizar el catálogo y el mapa de habilitadores — el brain sabe más pero no sabe qué sabe más.
- **[ANTIPATRÓN]** Cargar datos de una fuente sin clasificar — `build-brain.py` no puede asignar tier si `dt-fuentes` no lo declaró; el dato entra como bronze por defecto.
- **[ANTIPATRÓN]** Marcar gold una fuente entera porque "generalmente es confiable" — la clasificación es por tipo de fuente, no por reputación del proveedor.

---

*dt-fuentes · Enterprise Brain · Categoría B · Digital Core · Accenture México · 2026-10-08*
