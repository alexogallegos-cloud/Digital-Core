# Catálogo de Fuentes — plantilla canónica

> Artefacto de **Capa 1 (Corpus)** · Dueño: `dt-source-steward` · Regla B17 y B35 · ADR-EB-014
> Esta es la **plantilla del asset**. Cada instancia tiene la suya en `knowledge-base/source-catalog.md` de su propio directorio.

---

## Para qué sirve

El brain declara lo que no sabe (B17). Pero eso solo funciona si alguien declaró primero **con qué se contaba**. Sin este catálogo, un brain sin logs de producción no sabe nada del comportamiento en operación y nada lo advierte: la ausencia se ve igual que el silencio.

Este artefacto responde tres preguntas antes de que el pipeline corra:

1. ¿Qué fuentes existen para este sistema?
2. ¿Cuál es el tier natural de cada una, es decir cuánta confianza merece por su naturaleza?
3. ¿Qué fuentes faltan, y qué deja de poder responder el brain por no tenerlas?

---

## Cuándo se usa el Markdown y cuándo la tabla

El orden importa y está fijado en ADR-EB-014:

| Momento | Dónde vive el catálogo |
|---------|------------------------|
| DISCOVER, cuando el brain todavía no existe | **Aquí**, levantado a mano con el cliente |
| Al construir el brain | Se carga a la tabla `source_catalog` del CORE |
| De ahí en adelante | La tabla manda; este Markdown se **regenera** desde ella |

Nunca se edita el Markdown después de la carga: sería una segunda verdad.

---

## Tier natural por tipo de fuente

**El tier no lo decide quien carga el dato: lo decide el tipo de fuente.** Esta tabla es normativa y viene de la función F2 de `dt-source-steward`. Una instancia que marque gold una minuta está violando el canon y el validador lo detecta.

| Tipo de fuente | Tier natural | Por qué |
|---------------|-------------|---------|
| Código fuente productivo | **gold** | Es el sistema. Irrefutable por definición |
| Logs de producción | **gold** | Registro de lo que ocurrió |
| Monitoreo y métricas en vivo | **gold** | Observación directa del sistema operando |
| Historial de Git mergeado a main | **gold** | Registro inmutable de cambios integrados |
| Regulación publicada | **gold** | Ley vigente, no es interpretable como opcional |
| Artefactos firmados | **gold** | Decisión comprometida y registrada |
| Documentación técnica con autor y fecha | **silver** | Fuente identificable, puede estar desactualizada |
| Tickets de Jira o ITSM | **silver** | Estructurada, pero refleja intención y no hecho |
| Entrevistas y minutas | **bronze** | Memoria humana, sin verificación |
| Presentaciones y decks | **bronze** | Narrativa construida para persuadir |

La consecuencia práctica de B37: **el tier de una afirmación nunca puede superar el tier natural de la fuente que la sostiene.** Una regla de negocio extraída de un deck es bronze aunque suene definitiva.

---

## Catálogo de la instancia

Reemplazar al instanciar. Una fila por fuente.

| id | Fuente | Tipo | Generador | Cadencia | Estado | Tier | Cobertura | Última carga | Habilita |
|----|--------|------|-----------|----------|--------|------|-----------|--------------|----------|
| SRC-001 | *(ej. SPs de Informix)* | código | parser | batch | activa | gold | 95% | 2026-10-16 | reglas · componentes · vocabulario |
| SRC-002 | *(ej. logs de producción)* | logs | connector | continuo | ausente | gold | 0% | — | comportamiento real · incidentes |

**Campos:**

- **Estado**: `activa` si se carga y está fresca; `parcial` si cubre solo una porción; `ausente` si se necesita y no se tiene; `planeada` si está comprometida pero no llega.
- **Cobertura**: qué porcentaje del sistema cubre esa fuente. Una fuente activa al 30% no es una fuente resuelta.
- **Habilita**: qué puede responder el brain gracias a ella. Es el campo que vuelve accionable la ausencia.

---

## Fuentes ausentes

**Toda fila con estado `ausente` genera una fila en `knowledge_gaps` con `gap_type = 'source'`.** No es opcional: es la correspondencia que hace que una fuente faltante tenga dueño y acción en lugar de ser un hueco silencioso.

| Fuente ausente | Qué deja de poder responder el brain | A quién se le pide | Estado |
|----------------|--------------------------------------|--------------------|--------|
| *(ej. logs de producción)* | *Comportamiento real bajo carga; correlación de incidentes* | *Operación del cliente* | *abierto* |

---

## Checklist de completitud

Antes de declarar la Capa 1 lista para que la Capa 2 extraiga:

- [ ] Toda fuente entregada por el cliente tiene su fila, aunque no se haya procesado todavía.
- [ ] Toda fuente con estado `ausente` tiene su `knowledge_gap` abierto con destinatario concreto.
- [ ] Ningún tier fue asignado a mano contra la tabla normativa de arriba.
- [ ] La cobertura declarada es estimada contra el inventario real del sistema, no supuesta.
- [ ] Las fuentes de tipo `connector` declaran su cadencia; sin ella no se sabe cuándo el dato está viejo.

---

*Plantilla canónica del asset Enterprise Brain · Capa 1 · ADR-EB-014 · Accenture México*
