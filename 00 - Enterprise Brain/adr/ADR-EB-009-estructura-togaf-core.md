# ADR-EB-009 — Estructura TOGAF en el CORE: cadena de valor completa

> Estado: **APROBADO** · Propuesto: 2026-10-02 · Aprobado: 2026-10-02 · Asset: Enterprise Brain · Digital Core

---

## Contexto

La Regla B27 exige que el brain trace su conocimiento desde los productos hasta los datos y la infraestructura. La Regla B36 fija el modelo de frameworks: ETB es el negocio y da el north star, ITOM es TI y lo habilita, y TOGAF es el gobierno de la arquitectura que da la estructura (Regla B28).

Al contrastar el schema contra el metamodelo de TOGAF aparecieron tres problemas:

1. **Los dominios D (datos) y T (tecnología) no tenían tabla.** La cadena B27 cubría esos eslabones con tablas que no correspondían: `rules`, `vocabulary` y `journeys` para Datos, que son lógica de negocio, lenguaje y trazas de ejecución, e `itom_layer` para Infraestructura, que describe cómo opera TI y no qué opera.
2. **El dominio B no sabía quién decide.** No había stakeholders, aunque tres brains los modelan por su cuenta.
3. **El círculo TI-negocio no cerraba.** Un SLO de TI no podía declarar qué KPI de negocio habilita.

### Evidencia en el estate (42 brain.db revisados)

| Concepto TOGAF | Tabla en el estate | Brains | Volumen |
|---------------|-------------------|--------|---------|
| Stakeholders y roles | `capability_stakeholders` y `program_stakeholders` (Unity) · `stakeholders` (Coppel) · `team_roles` (Santander CAN) | 3 | 49 y 67 · 3 · 20 |
| Producto | `products` (bank-brain, Unity y uno más) | 3 | — |
| Entidad de datos y matriz CRUD | `sp_table_refs` (Informix) | 1 | 200,761 referencias |
| Componente tecnológico | `platforms` (Coppel) · `components.current_platform` (texto) | 1 | 5 plataformas |
| KPI | ninguna | 0 | — |

## Decisión

**1. Tres tablas nuevas en el CORE**, que pasa de 10 a 13:

> **[ENMIENDA 2026-10-05]** El CORE son hoy **15 tablas**. Después de este ADR se sumaron `knowledge_lineage` (ADR-EB-010) y `suppliers` (ADR-EB-011). La excepción al principio de destilación que concede este ADR se amplió con un segundo fundamento en ADR-EB-011: si un DT canónico obligatorio posee una tabla, esa tabla es CORE por consecuencia.


| Tabla | Dominio TOGAF | Destilada de |
|-------|--------------|-------------|
| `stakeholders` | B: Negocio | Unity, Coppel y Santander CAN |
| `data_entities` | D: Datos | Informix `sp_table_refs` |
| `technology_components` | T: Tecnología | Coppel `platforms` |

**2. `component_data` en la extensión SYSTEM**, que pasa de 9 a 10 tablas (hoy son **11**, con `component_processes`). Es la matriz CRUD aplicación-dato de TOGAF y homologa `sp_table_refs`.

**3. `slos.kpi_id`.** Cada SLO de TI declara el KPI de negocio que habilita. El Brain Auditor D8 avisa, sin bloquear, cuando falta.

**4. `itom_layer` conserva su rol.** Sigue siendo el IT Operating Model, es decir, cómo opera TI. `technology_components.itom_layer_id` la conecta con lo que opera.

## Excepción al principio de destilación

El canon v2.0 (ADR-EB-006) dice que una tabla entra al CORE cuando existe en al menos tres brains independientes. `stakeholders` y `products` lo cumplen. `kpis`, `data_entities` y `technology_components` no: tienen 0, 1 y 1 brains.

Se admiten como excepción explícita por tres razones:

- **La cadena B27 no se puede recorrer sin ellas.** Sin datos ni tecnología, `value_chain()` se detiene en los componentes y el brain no puede responder qué infraestructura sostiene un producto.
- **No son aspiracionales: la evidencia existe, aunque esté concentrada.** `sp_table_refs` tiene 200,761 filas reales y `platforms` modela una migración en curso.
- **La excepción es acotada.** No se agregan principios, dispensas, building blocks, value streams, servicios de negocio ni ubicaciones. Esas brechas de TOGAF siguen declaradas en B28 y entran al canon cuando tres brains las implementen.

## Consecuencias

- Los 16 brains del estate reprueban D1 por tres tablas adicionales del CORE. Es deuda real y medible; se registra en un nuevo baseline del Brain Auditor.
- Ruta de homologación (Regla B16): Informix expone `data_entities` y `component_data` como vistas sobre `sp_table_refs`; Coppel expone `technology_components` como vista sobre `platforms`; Unity, Coppel y Santander CAN exponen `stakeholders` como vistas sobre sus tablas actuales.
- Los portales compartibles no muestran nombres ni cargos de personas del cliente. Usan `stakeholder_type` y `role` como etiquetas genéricas.
- `value_chain()` ahora devuelve también `data` y `technology`.
