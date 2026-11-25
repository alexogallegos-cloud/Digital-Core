# Estudio histórico de {ORGANIZACIÓN}

> Plantilla canónica de la Regla B26. Se copia a `knowledge-base/history/` del brain y se completa ahí.
> **Primer artefacto de DISCOVER**: antes de leer código, antes de mapear sistemas, antes de la primera tabla.

---

## Para qué existe este documento

La historia no es contexto decorativo, es la explicación del porqué del código. Un procedimiento escrito de forma extraña tiene una razón histórica. Una regla que parece arbitraria responde a una regulación de hace veinte años. Un sistema con cuatro maneras de calcular lo mismo fue absorbiendo tres adquisiciones.

Sin este estudio el brain puede describir con precisión qué hace el sistema hoy, y no puede responder la pregunta que más importa en una modernización: **por qué lo hace así**.

**No tiene que ser exhaustivo desde el día uno.** Empieza con lo que se sabe y crece con cada conversación. Lo que no se sabe se declara como hueco, no se deja en blanco: cada laguna de este documento abre una fila en `knowledge_gaps` redactada como pregunta concreta a quien puede responderla (Reglas B17 y B35).

---

## Cómo se conecta al brain

| Enlace | Dónde | Qué significa |
|--------|-------|---------------|
| Referencia | `system_info.source_of_truth` | El brain declara que este estudio es una de sus fuentes |
| Huecos | `knowledge_gaps` | Cada dimensión sin responder, como consulta al stakeholder que la tiene |
| Tiempo | `knowledge_lineage.valid_from` | Cada hecho histórico lleva la fecha en que fue verdad, no la de captura (Regla B40) |
| Eje rector | `strategic_drivers` y `business_milestones` | Los hitos que siguen vivos se vuelven filas, no solo párrafos |

Un hecho de este estudio que entra al brain lo hace con el nivel que le corresponde por su fuente: una memoria anual auditada es distinta de un recuerdo de pasillo. Lo que viene de conversación entra **silver** y se promueve cuando una fuente documental lo confirma (Regla B37).

---

## Dimensión 1 — Fundación y modelo de negocio original

**Qué documentar:** año, giro, mercado inicial, propuesta de valor fundacional.

**Qué le explica al brain:** las capabilities más antiguas y los procesos más arraigados. Lo que la empresa hacía el primer día suele seguir siendo el núcleo que nadie se atreve a tocar.

{Completar. Si no se sabe, declarar el hueco y a quién preguntarle.}

---

## Dimensión 2 — Hitos de crecimiento y expansión

**Qué documentar:** adquisiciones, fusiones, nuevos mercados, alianzas estratégicas, con su fecha.

**Qué le explica al brain:** la heterogeneidad tecnológica. Los sistemas que no dialogan casi nunca es porque estén mal hechos, es porque nunca fueron diseñados juntos. Cada adquisición suele dejar un sistema paralelo que hace lo mismo de otra forma.

{Completar.}

---

## Dimensión 3 — Eventos regulatorios

**Qué documentar:** cambios de ley que obligaron a transformar procesos, con la circular o reforma que los originó y su fecha de entrada en vigor.

**Qué le explica al brain:** reglas de negocio que parecen arbitrarias y responden a obligaciones legales hoy olvidadas. En México la lista mínima a revisar es CNBV, Banxico y CONDUSEF; para grupos europeos, DORA; y las transversales PCI-DSS, ISO 27001 y SOC 2.

{Completar.}

---

## Dimensión 4 — Decisiones tecnológicas históricas

**Qué documentar:** plataformas adoptadas, migraciones intentadas y **cómo terminaron**, sistemas nunca reemplazados y por qué.

**Qué le explica al brain:** la deuda técnica. Por qué sigue corriendo lo que corre, por qué hay tres formas de calcular el mismo campo, y cuáles intentos de modernización ya fracasaron. Una migración fallida es el dato más valioso de esta dimensión: nadie quiere repetirla y casi nadie la documenta.

{Completar.}

---

## Dimensión 5 — Cultura organizacional y poder

**Qué documentar:** cómo se toman las decisiones, quién tiene autoridad real frente a la del organigrama, qué se valora y qué se evita.

**Qué le explica al brain:** por qué algunas capacidades están subdesarrolladas y otras sobrediseñadas. También quién puede aprobar qué, que es lo que alimenta `stakeholders` y, con ello, el rol accountable de cada acción (Regla B39).

{Completar.}

---

## Huecos abiertos por este estudio

Una fila por pregunta sin responder. Se sincroniza con `knowledge_gaps`.

| Dimensión | Pregunta concreta | A quién se le pregunta | Estado |
|-----------|-------------------|------------------------|--------|
| {1 a 5} | {la pregunta, redactada para que se pueda responder} | {rol o persona} | abierto |

---

*Plantilla de la Regla B26 · Asset Enterprise Brain · Digital Core · Accenture México*
