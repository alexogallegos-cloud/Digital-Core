# -*- coding: utf-8 -*-
"""
tiers.py — La tabla F2 de `dt-source-steward`, ejecutable.

El tier no lo decide quien carga el dato: lo decide el tipo de fuente (B37,
ADR-EB-010). Mientras esa tabla vivió solo en Markdown, la regla dependía de
que quien cargara se acordara de ella. Aquí deja de depender de la memoria.

Dos vocabularios conviven y hay que respetarlos, porque son de tablas
distintas:

  · `source_catalog.source_type` usa códigos en español (codigo, doc, logs...)
  · `knowledge_lineage.source_type` usa códigos en inglés (code, log...), y
    `BrainBuilder.GOLD_BY_ORIGIN` se compara contra esos. Un registro gold que
    llegue con el código español revienta en `record_lineage`, y con razón.

`linaje()` traduce entre los dos. No se inventó un tercer vocabulario.

ADR-EB-015, decisión 2 — el tier se estampa en la frontera de entrada.
"""

GOLD, SILVER, BRONZE = "gold", "silver", "bronze"

#: Orden total. Sirve para topar, no para comparar calidad en abstracto.
ORDEN = {BRONZE: 0, SILVER: 1, GOLD: 2}


class TipoDeFuenteDesconocido(ValueError):
    """Un tipo sin clasificar no cae a bronze por omisión: se rechaza.

    Caer a bronze parecería prudente y es lo contrario: dejaría entrar al
    pipeline una fuente que nadie clasificó, con la apariencia de haber pasado
    por F2. Una fuente nueva se clasifica antes de usarse.
    """


#: Tabla F2 — tipo de fuente, tier natural y por qué.
TIER_NATURAL = {
    # ── Hecho irrefutable: entra directo a gold ──────────────────────────────
    "codigo":        (GOLD,   "Es el sistema. Irrefutable por definición"),
    "logs":          (GOLD,   "Registro de lo que ocurrió. No es debatible"),
    "monitoring":    (GOLD,   "Observación directa del sistema en operación"),
    "git":           (GOLD,   "Registro inmutable de cambios integrados a main"),
    "regulacion":    (GOLD,   "Ley vigente. No es interpretable como opcional"),
    "firmado":       (GOLD,   "Decisión comprometida y registrada con firma"),
    # ── Fuente identificable, no autoritativa: silver ────────────────────────
    "doc_tecnico":   (SILVER, "Tiene autor y fecha, pero puede estar desactualizada"),
    "jira":          (SILVER, "Estructurada, pero refleja intención y no hecho"),
    "roadmap":       (SILVER, "Aprobado no es igual a ejecutado"),
    "ppt":           (SILVER, "Fuente reconocible, no autoritativa por sí sola"),
    "cmdb":          (SILVER, "Tiene dueño, pero su sincronía con producción varía"),
    # ── Sin validación formal: bronze ────────────────────────────────────────
    "minuta":        (BRONZE, "Captura notas, no acuerdos"),
    "audio":         (BRONZE, "Perspectiva del entrevistado; puede estar incompleta"),
    "doc_sin_linaje": (BRONZE, "Sin fecha, autor ni versión: imposible verificar vigencia"),
    "diagrama":      (BRONZE, "Sin propietario ni versión; puede no ser el estado actual"),
    "codigo_rama":   (BRONZE, "Intención de cambio, no cambio efectivo"),
}

#: Códigos del esquema que no distinguen linaje. `doc` cubre desde un contrato
#: firmado hasta un PDF sin autor, y ahí es donde se cuela la inflación de
#: tier. No se rechazan, porque el DDL los admite: toman el piso y declaran la
#: ambigüedad, para que `dt-source-steward` la califique.
AMBIGUOS = {
    "doc": ("firmado", "doc_tecnico", "doc_sin_linaje"),
}
for _codigo, _opciones in AMBIGUOS.items():
    TIER_NATURAL[_codigo] = (
        BRONZE,
        "Tipo sin calificar: toma el piso hasta que se declare "
        + " o ".join(_opciones),
    )

#: Alias hacia el vocabulario de `knowledge_lineage.source_type`, que es contra
#: el que `BrainBuilder.GOLD_BY_ORIGIN` compara.
LINAJE = {
    "codigo": "code", "codigo_rama": "code", "logs": "log",
    "monitoring": "monitoring", "git": "code", "regulacion": "regulation",
    "firmado": "signed_artifact", "doc_tecnico": "doc", "doc_sin_linaje": "doc",
    "doc": "doc", "ppt": "doc", "jira": "ticket", "roadmap": "doc",
    "cmdb": "cmdb", "minuta": "doc", "audio": "interview", "diagrama": "doc",
}


def tier_natural(source_type: str) -> str:
    """El tier que el tipo de fuente admite como techo."""
    if source_type not in TIER_NATURAL:
        raise TipoDeFuenteDesconocido(
            f"'{source_type}' no está en la tabla F2 de dt-source-steward. "
            f"Clasifícalo antes de usarlo. Conocidos: {', '.join(sorted(TIER_NATURAL))}")
    return TIER_NATURAL[source_type][0]


def razon(source_type: str) -> str:
    """Por qué ese tipo tiene ese tier. Va al campo `tier_basis` del linaje."""
    return TIER_NATURAL[source_type][1] if source_type in TIER_NATURAL else ""


def es_ambiguo(source_type: str) -> bool:
    return source_type in AMBIGUOS


def linaje(source_type: str) -> str:
    """Traduce al vocabulario de `knowledge_lineage`."""
    return LINAJE.get(source_type, "doc")


def no_supera(pedido: str, techo: str) -> tuple[str, bool]:
    """Topa `pedido` al `techo`. Devuelve el tier efectivo y si hubo tope.

    Ninguna afirmación puede superar el tier natural de la fuente que la
    sostiene. Topar en silencio sería tan malo como no topar: el segundo valor
    existe para que la cosecha lo declare.
    """
    for t in (pedido, techo):
        if t not in ORDEN:
            raise ValueError(f"tier '{t}' no existe; son {', '.join(ORDEN)}")
    if ORDEN[pedido] <= ORDEN[techo]:
        return pedido, False
    return techo, True
