# -*- coding: utf-8 -*-
"""
codigo-componentes.py — El segundo extractor. Familia `parser`.

Lee un árbol de código fuente y emite los componentes del sistema y el grafo de
llamadas entre ellos. Es el extractor del que cuelga casi todo lo demás: las
almas se leen de la topología de llamadas, el vocabulario se ancla a los
componentes y las reglas viven dentro de ellos.

POR QUÉ ESTE ES EL QUE ENTRA EN GOLD
------------------------------------
El código fuente productivo es el único tipo de fuente que la tabla F2
clasifica como hecho irrefutable: **es el sistema**. Lo que el código hace es
lo que el sistema hace, y eso no se debate. Por eso este extractor emite en
gold, y por eso es el primero que ejercita el camino gold del contrato de
punta a punta, hasta `knowledge_lineage`.

Dos consecuencias prácticas de eso. La primera es que lo que emita entra sin
revisión humana, así que solo emite lo que puede sostener: qué archivos hay,
qué componentes declaran y qué nombres se citan entre ellos. La segunda es que
todo lo que exige juicio no se emite: si un componente es un alma, a qué
capability sirve o qué regla de negocio encierra son preguntas que el código no
contesta solo.

CÓMO DECIDE QUÉ ES UN COMPONENTE
--------------------------------
Por perfil de lenguaje, declarado en `PERFILES`. Un perfil dice qué extensiones
cubre, qué patrón declara un componente dentro del archivo y cómo se ve una
llamada. Cuando un archivo no trae declaraciones, el componente es el archivo,
que es el comportamiento correcto para la mayoría de los lenguajes.

Un archivo cuya extensión no tiene perfil **no se ignora**: produce un hueco
declarado. Un árbol medio leído del que nadie avisa es peor que uno sin leer.

EL GRAFO DE LLAMADAS SE RESUELVE CONTRA LO QUE EXISTE
-----------------------------------------------------
Una llamada solo se emite cuando su destino es un componente que este mismo
árbol declaró. Un nombre que parece una llamada y no resuelve a nada no es una
arista: es una referencia externa, y se declara como hueco en vez de inventar
un nodo. Eso mantiene el grafo cerrado y hace que `fan_in` y `fan_out` sean
cifras que alguien puede verificar contando.

USO
---
    python codigo-componentes.py --fuente SRC-007 --slug acme \\
        --catalogo ../../knowledge-base/source-catalog.md \\
        --raiz ../../source/code \\
        --salida ../../knowledge-base/extracted/
"""

import argparse
import json
import re
import sys
from pathlib import Path

import contrato
import tiers

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except (AttributeError, ValueError):
    pass

#: Un perfil por familia de lenguaje. `declara` encuentra los componentes que
#: un archivo define; si el perfil no trae ninguno, el componente es el archivo.
#: `llama` encuentra los nombres que el archivo invoca.
#:
#: Los perfiles son deliberadamente pocos y explícitos. Un parser que dice
#: entender cualquier lenguaje entiende mal todos, y en un brain eso se paga
#: con un grafo que nadie puede auditar.
PERFILES = {
    "sql": {
        "exts": (".sql", ".spl", ".prc", ".pls", ".pkb"),
        "tipo": "sp",
        "declara": r"CREATE\s+(?:OR\s+REPLACE\s+)?(?:PROCEDURE|FUNCTION)\s+"
                   r"(?:IF\s+NOT\s+EXISTS\s+)?[\"'`\[]?(\w+)",
        "llama": r"(?:CALL|EXEC|EXECUTE\s+PROCEDURE|PERFORM)\s+[\"'`\[]?(\w+)",
        "comentario": (r"--[^\n]*", r"/\*.*?\*/"),
    },
    "cobol": {
        "exts": (".cbl", ".cob", ".cpy"),
        "tipo": "program",
        "declara": r"PROGRAM-ID\.\s+([\w-]+)",
        "llama": r"CALL\s+[\"']([\w-]+)[\"']",
        "comentario": (r"^......\*[^\n]*",),
    },
    "java": {
        "exts": (".java",),
        "tipo": "object",
        "declara": r"(?:public|private|protected)?\s*(?:final\s+)?"
                   r"(?:class|interface|enum)\s+(\w+)",
        "llama": r"\bnew\s+(\w+)\s*\(|\b(\w+)\s*\.\s*\w+\s*\(",
        "comentario": (r"//[^\n]*", r"/\*.*?\*/"),
    },
    "python": {
        "exts": (".py",),
        "tipo": "object",
        "declara": r"^(?:class|def)\s+(\w+)",
        "llama": r"\b(\w+)\s*\(",
        "comentario": (r"#[^\n]*",),
    },
}

#: Nombres que casan con el patrón de llamada y no son llamadas a nada. Sin
#: esta lista el grafo se llena de aristas hacia palabras reservadas.
RUIDO = {
    "if", "else", "end", "begin", "select", "from", "where", "into", "values",
    "return", "returns", "let", "set", "while", "for", "foreach", "case",
    "when", "then", "and", "or", "not", "null", "print", "trace", "raise",
    "exception", "define", "on", "to", "as", "by", "is", "in", "int", "str",
    "len", "range", "list", "dict", "self", "super", "this", "new", "try",
    "catch", "finally", "throw", "throws", "public", "private", "static",
    "void", "class", "def", "import", "from_", "true", "false",
}


def sin_comentarios(texto: str, patrones) -> str:
    """Quita los comentarios antes de buscar llamadas.

    Un `CALL` dentro de un comentario no es una llamada, y el grafo de un
    sistema viejo se desfigura con los bloques comentados que nadie borró.
    """
    for pat in patrones:
        texto = re.sub(pat, " ", texto, flags=re.S | re.M)
    return texto


def perfil_de(ruta: Path):
    ext = ruta.suffix.lower()
    for nombre, perfil in PERFILES.items():
        if ext in perfil["exts"]:
            return nombre, perfil
    return None, None


class CodigoComponentes(contrato.Extractor):
    id = "codigo-componentes"
    familia = "parser"
    #: Solo código productivo. Una rama sin mergear es `codigo_rama` y su tier
    #: natural es bronze: la misma lectura, otra confianza, y el contrato se
    #: encarga de toparla.
    tipos_fuente = ("codigo", "codigo_rama", "git")
    tablas = ("components", "component_calls")

    def extraer(self, fuente, *, raiz, db=None, **_):
        raiz = Path(raiz)
        if not raiz.is_dir():
            raise ValueError(f"{raiz} no es un directorio de código")
        cosecha = self.nueva_cosecha(fuente)
        techo = fuente.natural_tier
        prefijo = db or fuente.ontology or "src"

        archivos, sin_perfil = [], {}
        for p in sorted(raiz.rglob("*")):
            if not p.is_file():
                continue
            nombre, perfil = perfil_de(p)
            if perfil is None:
                sin_perfil[p.suffix.lower() or "(sin extensión)"] = \
                    sin_perfil.get(p.suffix.lower() or "(sin extensión)", 0) + 1
                continue
            archivos.append((p, nombre, perfil))

        # Primera pasada: qué componentes existen. El grafo no se puede
        # resolver hasta saberlo, porque una llamada solo es arista si su
        # destino es algo que este árbol declaró.
        declarados = {}
        for p, nombre, perfil in archivos:
            texto = p.read_text(encoding="utf-8", errors="replace")
            limpio = sin_comentarios(texto, perfil.get("comentario", ()))
            nombres = []
            if perfil.get("declara"):
                nombres = [m.group(1) for m in
                           re.finditer(perfil["declara"], limpio, re.I | re.M)]
            if not nombres:
                nombres = [p.stem]
            for n in nombres:
                cid = f"{prefijo}:{n}"
                if cid in declarados:
                    continue
                declarados[cid] = {
                    "nombre": n, "tipo": perfil["tipo"], "ruta": p,
                    "rel": p.relative_to(raiz).as_posix(),
                    "loc": len(texto.splitlines()), "texto": limpio,
                }

        indice = {d["nombre"].lower(): cid for cid, d in declarados.items()}

        # Segunda pasada: el grafo, resuelto contra el índice.
        aristas, externas = set(), {}
        for cid, d in declarados.items():
            perfil = PERFILES[perfil_de(d["ruta"])[0]]
            if not perfil.get("llama"):
                continue
            for m in re.finditer(perfil["llama"], d["texto"], re.I | re.M):
                llamado = next((g for g in m.groups() if g), "")
                clave = llamado.lower()
                if not clave or clave in RUIDO or clave == d["nombre"].lower():
                    continue
                destino = indice.get(clave)
                if destino is None:
                    externas[llamado] = externas.get(llamado, 0) + 1
                    continue
                if destino != cid:
                    aristas.add((cid, destino))

        entrantes = {cid: 0 for cid in declarados}
        salientes = {cid: 0 for cid in declarados}
        for origen, destino in aristas:
            salientes[origen] += 1
            entrantes[destino] += 1

        for cid, d in sorted(declarados.items()):
            cosecha.agregar(
                "components",
                {"id": cid, "name": d["nombre"], "display_name": None,
                 # Lo que exige juicio no se emite: el nombre de negocio, el
                 # dominio, la capability y el alma son de quien conoce el
                 # sistema, no del parser.
                 "description": None, "domain": None, "tipo": d["tipo"],
                 "fan_in": entrantes[cid], "fan_out": salientes[cid],
                 "loc": d["loc"], "is_soul": 0, "soul_rank": None,
                 "seeded_by": self.id, "fill_quality": "partial",
                 "source_doc": d["rel"], "status": "active"},
                source_ref=f"{fuente.id}#{d['rel']}", tier=techo,
                confianza="declared")

        for origen, destino in sorted(aristas):
            cosecha.agregar(
                "component_calls",
                {"from_component": origen, "to_component": destino,
                 "cross_db": 0},
                source_ref=f"{fuente.id}#{declarados[origen]['rel']}",
                tier=techo, confianza="declared")

        self._huecos(cosecha, fuente, declarados, sin_perfil, externas)
        return cosecha

    def _huecos(self, cosecha, fuente, declarados, sin_perfil, externas):
        hoy = __import__("datetime").date.today().isoformat()

        for ext, n in sorted(sin_perfil.items()):
            cosecha.hueco(
                id=f"GAP-{_h6(fuente.id, 'perfil', ext)}", gap_type="dato",
                # Es cobertura de fuente, no conocimiento del negocio: su
                # dominio es `fuentes` y por eso no cuenta como huérfano en D7
                # (ADR-EB-017). El de dependencias externas sí cuenta, y debe:
                # alguien tiene que decir a qué proceso sirven.
                dimension="tecnología", domain="fuentes", process_id=None,
                description=(f"{n} archivo(s) {ext} quedaron fuera: ningún perfil "
                             f"de lenguaje los cubre"),
                impact="Esa parte del sistema no está en el grafo, y el brain no "
                       "puede saber que le falta si nadie lo declara",
                required_for="Etapa 2 — Almas",
                resolution_action=(f"Consulta dt-source-steward: ¿qué lenguaje es "
                                   f"{ext} y vale la pena un perfil, o queda fuera "
                                   f"de alcance declarado?"),
                owner="dt-source-steward", status="open",
                opened_at=hoy, resolved_at=None)

        if externas:
            top = sorted(externas.items(), key=lambda x: -x[1])[:10]
            cosecha.hueco(
                id=f"GAP-{_h6(fuente.id, 'externas')}", gap_type="dato",
                dimension="tecnología", domain="codigo", process_id=None,
                description=(f"{len(externas)} nombre(s) invocados que no resuelven "
                             f"a ningún componente de este árbol: "
                             + ", ".join(f"{n} ({c})" for n, c in top)),
                impact="O son llamadas a sistemas externos, y entonces son "
                       "dependencias cruzadas que nadie ha declarado, o el árbol "
                       "está incompleto. Las dos importan y se arreglan distinto",
                required_for="Regla B5 — dependencias cruzadas",
                resolution_action=("Consulta dt-asset-configuration-manager: "
                                   "¿cuáles de estos son sistemas externos? Los que "
                                   "lo sean van a cross_dependencies"),
                owner="dt-asset-configuration-manager", status="open",
                opened_at=hoy, resolved_at=None)

        if not declarados:
            cosecha.hueco(
                id=f"GAP-{_h6(fuente.id, 'vacio')}", gap_type="acceso",
                dimension="tecnología", domain="codigo", process_id=None,
                description=f"{fuente.name} no produjo ningún componente",
                impact="Sin componentes no hay almas, ni vocabulario anclado, ni "
                       "reglas: las cuatro etapas que siguen cuelgan de esta",
                required_for="Etapa 2 — Almas",
                resolution_action=("Consulta dt-source-steward: ¿la ruta de código "
                                   "es la correcta y está completa?"),
                owner="dt-source-steward", status="open",
                opened_at=hoy, resolved_at=None)


def _h6(*partes) -> str:
    import hashlib
    return hashlib.sha1("|".join(partes).encode("utf-8")).hexdigest()[:6]


def main():
    ap = argparse.ArgumentParser(
        description="Extrae componentes y grafo de llamadas de un árbol de código")
    ap.add_argument("--fuente", required=True, help="id en source_catalog")
    ap.add_argument("--catalogo", required=True)
    ap.add_argument("--slug", required=True, help="el mismo slug que system_info")
    ap.add_argument("--raiz", help="por omisión, el location de la fuente")
    ap.add_argument("--db", help="prefijo de los ids, por omisión la ontología")
    ap.add_argument("--salida")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()

    catalogo = contrato.Catalogo.desde(Path(a.catalogo))
    fuente = catalogo.obtener(a.fuente)
    raiz = a.raiz or fuente.location
    if not raiz:
        raise SystemExit(f"{fuente.id} no declara location y no se pasó --raiz")

    cosecha = CodigoComponentes().ejecutar(fuente, raiz=raiz, db=a.db)

    if a.json:
        print(json.dumps(cosecha.a_dict(), ensure_ascii=False, indent=2))
        return

    print(f"{cosecha.extractor} · {fuente.id} · {fuente.name}")
    print(f"  tier natural: {fuente.natural_tier} — {tiers.razon(fuente.source_type)}")
    for tabla, n in cosecha.resumen().items():
        print(f"  {tabla}: {n}")
    for sello in cosecha.sellos:
        print(f"  [sello] {sello}")

    if a.dry_run:
        print("  DRY-RUN — no se escribió nada")
        return
    salida = Path(a.salida) if a.salida else Path(a.catalogo).parent / "extracted"
    print(f"  escrito: {cosecha.a_json(salida)}")


if __name__ == "__main__":
    main()
