"""
build-portal.py — Reconstruye páginas del portal GemCog desde brain.db.

Regla de oro: TODO el contenido proviene del brain (pseudocodigo / kb_documents /
capacidades / flujos / stats / …). Sólo el SHELL de presentación (CSS/JS/layout/
logo base64) es plantilla, extraída UNA vez por generators/_extract_templates.py
a generators/templates/. Este script nunca lee la carpeta de referencia.

Uso:
    PYTHONUTF8=1 python generators/build-portal.py            # 3 pilotos
    PYTHONUTF8=1 python generators/build-portal.py pseudo P046 S500
    PYTHONUTF8=1 python generators/build-portal.py cap pos
    PYTHONUTF8=1 python generators/build-portal.py index
"""
from __future__ import annotations
import re
import sqlite3
import shutil
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
DB = BASE / "digital-brain" / "brain.db"
REF_ASSETS = BASE / "source" / "GemCogAlt" / "gemcog-portal-2026-08-26-cliente-entregable" / "assets"
TPL = Path(__file__).resolve().parent / "templates"
OUT = BASE / "portal"
NL = "\n"

# Constante de build no derivable del brain actual (ver reporte): nombre de KB de la
# entrega de referencia (2026-08-25). El brain vivo trae kb_source distinto.
KB_NAME = "gemcog-kb-2026-08-25-cliente-entregable"


def db():
    c = sqlite3.connect(DB)
    c.row_factory = sqlite3.Row
    return c


# ── Escaping ────────────────────────────────────────────────────────────────
def esc_pre(s: str) -> str:
    """Bloques <pre>: escapa & < > \" y '."""
    return (s.replace("&", "&amp;").replace("<", "&lt;")
             .replace(">", "&gt;").replace('"', "&quot;")
             .replace("'", "&#x27;"))


def esc_code(s: str, full: bool = True) -> str:
    """Inline <code>.  Pseudocódigo escapa & < > \" '; capacidades sólo &."""
    s = s.replace("&", "&amp;")
    if not full:
        return s
    return (s.replace("<", "&lt;").replace(">", "&gt;")
             .replace('"', "&quot;").replace("'", "&#x27;"))


def esc_mermaid(s: str) -> str:
    """Cuerpo mermaid: escapa & < > (no las comillas, son sintaxis)."""
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


# ── Slug (id de anclas) ─────────────────────────────────────────────────────
def slugify(text: str, limit: int = 60) -> str:
    s = text.lower()
    s = re.sub(r"[^a-z0-9]+", "-", s)      # acentos/no-alfanum → separador (se pierden)
    s = s.strip("-")
    if len(s) > limit:
        s = s[:limit]          # truncado duro: la referencia conserva el guión de corte
    return s


def slugify_heading(text: str, limit: int = 60) -> str:
    """Slug para ids de heading: strips <…> de code spans antes de slugificar."""
    t = re.sub(r"`([^`]*)`", lambda m: re.sub(r"<[^>]*>", "", m.group(1)), text)
    return slugify(t, limit)


# ── Inline markdown → HTML (texto de prosa / celdas / blockquote) ───────────
# Ancla: sólo [TOKEN_MAYUSCULAS Lnnn…].  `[p015 L9874]` (minúsculas),
# `[P010 Lnnnn]` (sin dígitos) y `[HARDCODE]` NO son anclas en la referencia.
RX_ANCHOR = re.compile(r"\[[A-Z0-9_]+ L\d[^\]]*\]")
RX_BR = re.compile(r"\(BR:[^)]*\)")
RX_DRIFT = re.compile(r"«[^»]*»")
# Solo las anotaciones formales «divergencia KB: …» reciben <span class="drift">.
# Las guillemets tipográficas (labels, nombres, anchors) se dejan tal cual.
RX_DRIFT_FORMAL = re.compile(r"«\s*divergencia\s+KB[^»]*»", re.IGNORECASE)
# Rutas del árbol de fuentes: la referencia siempre las reduce al basename,
# en cualquier contexto (blockquote, celda de tabla, prosa).
RX_SRCPATH = re.compile(r"(?:INPUT|DELIVERABLES|SOURCE)[/\\][^\s`|)]*")


def strip_src_paths(text: str) -> str:
    def _strip(m):
        parts = [p for p in re.split(r"[/\\]", m.group(0)) if p]
        return parts[-1] if parts else ""
    return RX_SRCPATH.sub(_strip, text)


def inline(text: str, rich: bool = True) -> str:
    """Markdown inline → HTML.

    Usa placeholders para code spans: BR/ancla se aplican dentro del <code>;
    drift («…») se aplica sólo en la prosa exterior (nunca dentro de <code>).
    `rich=False` = páginas de capacidades: sólo code/strong/em.
    """
    store: list[str] = []

    def _code(m):
        c = esc_code(m.group(1), rich)
        if rich:
            c = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", c)
            c = RX_BR.sub(r'<span class="br">\g<0></span>', c)
            c = RX_ANCHOR.sub(r'<span class="anchor">\g<0></span>', c)
            c = RX_DRIFT_FORMAL.sub(
                lambda d: '<span class="drift">«%s »</span>' % d.group(0)[1:-1], c)
        store.append("<code>" + c + "</code>")
        return "\x00%d\x00" % (len(store) - 1)

    t = re.sub(r"`([^`]*)`", _code, strip_src_paths(text))
    t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)
    if not rich:
        t = re.sub(r"(?<![A-Za-z0-9*])\*(?!\*)([^*]+)\*(?!\*)", r"<em>\1</em>", t)
        t = re.sub(r"\x00(\d+)\x00", lambda m: store[int(m.group(1))], t)
        return t
    t = re.sub(r'\(BR:[^)]*\)', r'<span class="br">\g<0></span>', t)
    t = RX_ANCHOR.sub(r'<span class="anchor">\g<0></span>', t)
    # Solo «divergencia KB: …» recibe <span class="drift">; guillemets tipográficas no.
    t = RX_DRIFT_FORMAL.sub(
        lambda d: '<span class="drift">«%s »</span>' % d.group(0)[1:-1], t)
    # Restore BEFORE italic so * inside <code> pairs with outer *
    # (matches the reference generator's behavior — malformed HTML but expected).
    t = re.sub(r"\x00(\d+)\x00", lambda m: store[int(m.group(1))], t)
    t = re.sub(r"(?<![A-Za-z0-9*])\*(?!\*)([^*]+)\*(?!\*)", r"<em>\1</em>", t)
    return t


def fuente_basename(text: str) -> str:
    """`Fuente: ruta/larga/x.alg` → `Fuente: x.alg` (respeta backticks)."""
    return re.sub(r"(Fuente: `?)([^\s`]+)",
                  lambda m: m.group(1) + m.group(2).split("/")[-1], text)


# ── Tabla markdown → HTML (una sola línea) ──────────────────────────────────
def render_table(rows: list[str], rich: bool = True) -> str:
    def cells(line):
        line = line.strip()
        if line.startswith("|"):
            line = line[1:]
        if line.endswith("|"):
            line = line[:-1]
        return [c.strip() for c in line.split("|")]

    head = cells(rows[0])
    ncols = len(head)
    body = [cells(r) for r in rows[2:]]
    out = ["<table><thead><tr>"]
    out += ["<th>" + inline(c, rich) + "</th>" for c in head]
    out.append("</tr></thead><tbody>")
    for r in body:
        while len(r) < ncols:
            r.append("")
        out.append("<tr>" + "".join("<td>" + inline(c, rich) + "</td>" for c in r) + "</tr>")
    out.append("</tbody></table>")
    return "".join(out)


# ── Bloques pseudocódigo (resaltado) ────────────────────────────────────────
# Vocabulario exacto que la referencia envuelve en <span class="kw">.
KW = {
    "MOVER", "SI", "PROCEDIMIENTO", "EJECUTAR", "SINO", "LLAMAR", "ESCRIBIR",
    "SUMAR", "CERRAR", "LEER", "ABRIR", "CALCULAR", "PARA", "MIENTRAS",
    "RETORNAR", "SEGÚN", "FUNCIÓN", "REPETIR", "BLOQUEAR", "LIBERAR",
    "RESTAR", "SEGUN", "ESPERAR", "SUBRUTINA", "ACEPTAR", "EXPORTAR",
    "VALIDAR", "DEVOLVER", "ENLAZAR", "SECCIÓN", "GRABAR", "INICIALIZAR",
    "ASIGNAR", "ENTONCES", "FUNCION", "DESENLAZAR", "PROGRAMA", "TERMINAR",
    "INICIAR",
}


def _note(s: str) -> str:
    """Envuelve « … » en <span class=\"note\"> dentro de un bloque pseudo."""
    return re.sub(r"«[^»]*»", r'<span class="note">\g<0></span>', s)


# `SINO-SI …` resalta sólo `SINO`: el match es por prefijo con borde de palabra, no por token.
RX_KW = re.compile(r"(\s*)(%s)\b(.*)$"
                   % "|".join(sorted(KW, key=len, reverse=True)), re.S)


def hl_code_part(code: str) -> str:
    e = esc_pre(code)
    m = RX_KW.match(e)
    if m:
        return (m.group(1) + '<span class="kw">' + m.group(2) + "</span>"
                + _note(m.group(3)))
    return _note(e)


def hl_pseudo_line(line: str) -> str:
    if line.lstrip().startswith("«"):
        return '<span class="note">' + esc_pre(line) + "</span>"
    idx = line.find("//")
    if idx >= 0:
        return (hl_code_part(line[:idx])
                + '<span class="cmt">' + _note(esc_pre(line[idx:])) + "</span>")
    return hl_code_part(line)


def first_tok(line: str) -> str:
    return re.match(r"\s*(\S*)", line).group(1)


def looks_pseudo(lines: list[str]) -> bool:
    """Un bloque es pseudocódigo si alguna línea abre con palabra clave."""
    return any(RX_KW.match(l) for l in lines)


def all_comment(lines: list[str]) -> bool:
    ne = [l for l in lines if l.strip()]
    return bool(ne) and all(l.strip().startswith("//") for l in ne)


# ── Parser de bloques (comparte pseudo y cap) ───────────────────────────────
class Block:
    __slots__ = ("kind", "data", "meta")

    def __init__(self, kind, data, meta=None):
        self.kind, self.data, self.meta = kind, data, meta


RX_HEAD = re.compile(r"^(#{1,6}) ")
RX_LI = re.compile(r"^(\s*)([-*+]|\d+\.)\s+(.*)$")
RX_LI0 = re.compile(r"^([-*+]|\d+\.)\s")     # viñeta a nivel 0: abre bloque nuevo


def _is_struct(line: str) -> bool:
    s = line.strip()
    return (not s or bool(RX_HEAD.match(line)) or s == "---"
            or line.startswith(">") or s.startswith("```") or s.startswith("|"))


def parse_blocks(md: str):
    """Devuelve (h1, [Block,...]).

    Bloques: h2..h6, hr, bq, fence, table, list, pseudo, p.
    `pseudo` = bloque de líneas crudas que abren con palabra clave (los .pseudo
    escriben el pseudocódigo sin cercar con ```); se fusiona con el bloque
    previo cuando arranca indentado (continuación del mismo procedimiento).
    """
    md = md.replace("\r\n", "\n").replace("\r", "\n")
    lines = md.split(NL)
    h1 = ""
    blocks: list[Block] = []
    i = 0
    n = len(lines)
    while i < n:
        ln = lines[i]
        s = ln.strip()
        if not s:
            i += 1
            continue
        mh = RX_HEAD.match(ln)
        if mh:
            lvl = len(mh.group(1))
            txt = ln[lvl + 1:].strip()
            if lvl == 1:
                h1 = txt
                i += 1
                continue
            if lvl == 3 and RX_PROC_H3.match(RX_LEAD_NUM.sub("", txt)):
                # `### PROCEDIMIENTO X()` que encabeza pseudocódigo: TODA la
                # región hasta el siguiente heading entra verbatim en un bloque.
                j = i + 1
                while j < n and not lines[j].strip():
                    j += 1
                if j < n and not RX_HEAD.match(lines[j]):
                    body: list[str] = []
                    k = j
                    while k < n and not RX_HEAD.match(lines[k]):
                        body.append(lines[k])
                        k += 1
                    while body and not body[-1].strip():
                        body.pop()
                    blocks.append(Block("h3proc", txt, body))
                    i = k
                    continue
            blocks.append(Block("h%d" % lvl, txt))
            i += 1
            continue
        if s == "---":
            blocks.append(Block("hr", None))
            i += 1
            continue
        if ln.startswith(">"):
            buf = []
            while i < n and lines[i].startswith(">"):
                buf.append(lines[i][1:].lstrip() if lines[i][1:2] == " " else lines[i][1:])
                i += 1
            blocks.append(Block("bq", buf))
            continue
        if s.startswith("```"):
            lang = s[3:].strip().lower()
            i += 1
            buf = []
            while i < n and not lines[i].strip().startswith("```"):
                buf.append(lines[i])
                i += 1
            i += 1  # skip closing fence
            blocks.append(Block("fence", buf, lang))
            continue
        if s.startswith("|"):
            buf = []
            while i < n and lines[i].strip().startswith("|"):
                buf.append(lines[i])
                i += 1
            blocks.append(Block("table", buf))
            continue
        # bloque de líneas contiguas no estructurales.  Una viñeta a nivel 0
        # corta el párrafo en curso (la referencia separa <p> de <ul>).
        buf = []
        while i < n and not _is_struct(lines[i]):
            if buf and RX_LI0.match(lines[i]) and not RX_LI0.match(buf[0]):
                break
            # Break at raw PROCEDIMIENTO/FUNCIÓN line at col 0 → new <pre> block
            if buf and not lines[i][:1].isspace() and RX_PROC_H3.match(lines[i]):
                break
            # Break at «…» annotation at col 0 after pseudo → separate <p> via inline()
            if (buf and looks_pseudo(buf)
                    and not lines[i][:1].isspace()
                    and lines[i].lstrip().startswith("«")):
                break
            buf.append(lines[i])
            i += 1
        if not buf:                       # guardia anti-loop
            buf = [lines[i]]
            i += 1
        if looks_pseudo(buf):
            prev = blocks[-1] if blocks else None
            if (prev is not None and prev.kind == "pseudo"
                    and buf[0][:1] in (" ", "\t")):
                prev.data.append("")      # la línea vacía del markdown se conserva
                prev.data.extend(buf)
            else:
                blocks.append(Block("pseudo", list(buf)))
        elif RX_LI.match(buf[0]):
            blocks.append(Block("list", list(buf)))
        else:
            blocks.append(Block("p", " ".join(x.strip() for x in buf)))
    return h1, blocks


def render_list(lines: list[str]) -> str:
    """Lista markdown plana → <ul>/<ol> en una sola línea."""
    m0 = RX_LI.match(lines[0])
    tag = "ol" if m0.group(2)[:1].isdigit() else "ul"
    items: list[list[str]] = []
    for ln in lines:
        m = RX_LI.match(ln)
        if m:
            items.append([m.group(3).strip()])
        elif items:
            items[-1].append(ln.strip())
        else:
            items.append([ln.strip()])
    body = "".join("<li>%s</li>" % inline(" ".join(x)) for x in items)
    return "<%s>%s</%s>" % (tag, body, tag)


def render_pseudo_pre(lines: list[str]) -> str:
    rendered: list[str] = []
    note_open = False
    for line in lines:
        if note_open:
            if "»" in line:
                rendered.append(esc_pre(line) + "</span>")
                note_open = False
            else:
                rendered.append(esc_pre(line))
        elif line.lstrip().startswith("«"):
            stripped = line.lstrip()
            indent = line[:len(line) - len(stripped)]
            if "»" in line:
                close_pos = stripped.index("»") + 1
                note_part = stripped[:close_pos]
                rest = stripped[close_pos:]
                rest_html = hl_pseudo_line(indent + rest)[len(indent):]  # apply keyword/comment highlighting
                rendered.append(indent + '<span class="note">' + esc_pre(note_part) + "</span>" + rest_html)
            else:
                rendered.append(indent + '<span class="note">' + esc_pre(stripped))
                note_open = True
        else:
            rendered.append(hl_pseudo_line(line))
    if note_open and rendered:
        rendered[-1] += "</span>"
    return '<pre class="pseudo">' + NL.join(rendered) + "</pre>"


# ════════════════════════════════════════════════════════════════════════════
#  PSEUDOCÓDIGO
# ════════════════════════════════════════════════════════════════════════════
TIPO_LABEL = {"program": "Programa", "copybook": "Copybook", "wfl": "WFL",
              "library": "Librería", "module": "Módulo"}
# El lenguaje sale de la extensión del `Fuente:` del markdown (no hay columna en
# el brain): .alg → ALGOL, .wfl → WFL, resto (y sin extensión) → COBOL.
LANG_STYLE = {"ALGOL": "border-color:#b98ce0;color:#b98ce0",
              "WFL": "border-color:#66bb6a;color:#66bb6a",
              "COBOL": "border-color:#5aa9e0;color:#5aa9e0"}
LANG_BY_EXT = {"alg": "ALGOL", "wfl": "WFL"}


def detect_lang(md: str) -> str:
    m = re.search(r"Fuente:\s*`?([^\s`]+)", md)
    if not m:
        return "COBOL"
    base = m.group(1).rsplit("/", 1)[-1]
    if "." not in base:
        return "COBOL"
    return LANG_BY_EXT.get(base.rsplit(".", 1)[-1].lower(), "COBOL")


RX_PROC_H3 = re.compile(r"^(FUNCIÓN|FUNCION|PROCEDIMIENTO)\b")
# Etiquetas de encabezado que la referencia descarta: numeración propia
# (`4.`, `4.1`), enumeración alfabética (`B.`) y el prefijo `Sección:`.
RX_LEAD_NUM = re.compile(r"^(?:\d+(\.\d+)*\.?|[A-Z]\.|[Ss]ecci[óo]n:)\s+")


def toc_text(numbered: str) -> str:
    """Texto del TOC: aplica esc_code a spans de código, normaliza drift y escapa HTML."""
    t = re.sub(r"`([^`]*)`", lambda m: esc_code(m.group(1)), numbered)
    t = t.replace("**", "")
    t = re.sub(r"\*([^*]+)\*", r"\1", t)  # strip italic markers, keep content
    # Normaliza solo las anotaciones formales: agrega espacio antes del cierre.
    t = RX_DRIFT_FORMAL.sub(lambda d: "«%s »" % d.group(0)[1:-1], t)
    return t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def render_pseudo_content(blocks):
    """Emite el stream de <div class='psect'> + headings/TOC del archetipo pseudo."""
    out: list[str] = []
    toc: list[tuple[str, str, str]] = []   # (level, id, text)
    psect_open = False
    h2c = 0
    h3c = 0

    def ensure_open(first_html):
        nonlocal psect_open
        if not psect_open:
            psect_open = True
            return '<div class="psect">' + first_html
        return first_html

    for bi, b in enumerate(blocks):
        nxt = blocks[bi + 1] if bi + 1 < len(blocks) else None
        if b.kind == "h2":
            h2c += 1
            h3c = 0
            numbered = "%d. %s" % (h2c, RX_LEAD_NUM.sub("", b.data))
            hid = slugify_heading(numbered)
            head = "<h2 id='%s'>%s</h2>" % (hid, inline(numbered))
            if psect_open:
                out.append("</div>")
            out.append('<div class="psect">' + head)
            psect_open = True
            toc.append(("l2", hid, toc_text(numbered)))
        elif b.kind == "h3proc":
            # Encabezado de procedimiento: rótulo `·`, comentario `:  // …`
            # recortado, texto plano (sin code ni anclas) y la región completa
            # que le sigue volcada verbatim en un único <pre class="pseudo">.
            h3c += 1
            raw = RX_PROC_H3.sub("·", RX_LEAD_NUM.sub("", b.data))
            raw = re.sub(r":?\s*//.*$", "", raw)
            raw = re.sub(r"\(\s*\)\s*$", "", raw).strip()
            numbered = "%d.%d %s" % (h2c, h3c, raw)
            hid = slugify_heading(numbered)
            out.append(ensure_open("<h3 id='%s' class='proc'>%s</h3>"
                                   % (hid, esc_pre(numbered))))
            out.append(render_pseudo_pre([b.data] + b.meta))
            toc.append(("l3", hid, toc_text(numbered)))
        elif b.kind == "h3":
            h3c += 1
            numbered = "%d.%d %s" % (h2c, h3c, RX_LEAD_NUM.sub("", b.data))
            hid = slugify_heading(numbered)
            out.append(ensure_open("<h3 id='%s'>%s</h3>"
                                   % (hid, inline(numbered))))
            toc.append(("l3", hid, toc_text(numbered)))
        elif b.kind in ("h4", "h5", "h6"):
            hid = slugify_heading(b.data)
            out.append(ensure_open("<%s id='%s'>%s</%s>"
                                   % (b.kind, hid, inline(b.data), b.kind)))
        elif b.kind == "hr":
            out.append(ensure_open("<hr>"))
        elif b.kind == "bq":
            ps = "".join("<p>%s</p>" % inline(fuente_basename(x)) for x in b.data if x.strip())
            out.append(ensure_open("<blockquote>%s</blockquote>" % ps))
        elif b.kind == "p":
            out.append(ensure_open("<p>%s</p>" % inline(fuente_basename(b.data))))
        elif b.kind == "list":
            out.append(ensure_open(render_list(b.data)))
        elif b.kind == "table":
            out.append(ensure_open(render_table(b.data)))
        elif b.kind == "pseudo":
            # ¿continúa el <pre> abierto por un encabezado de procedimiento?
            if out and isinstance(out[-1], Block) and out[-1].kind == "procpre":
                out[-1].data.extend(b.data)
            else:
                out.append(ensure_open(render_pseudo_pre(b.data)))
        elif b.kind == "fence":
            if looks_pseudo(b.data) or all_comment(b.data):
                html = render_pseudo_pre(b.data)
            else:
                html = "<pre><code>" + NL.join(esc_pre(l) for l in b.data) + "</code></pre>"
            out.append(ensure_open(html))
    out = [render_pseudo_pre(x.data) if isinstance(x, Block) else x for x in out]
    if psect_open:
        out[-1] = out[-1] + "</div>"
    return NL.join(out), toc


def build_pseudo(programa: str, sistema: str) -> str:
    con = db()
    row = con.execute(
        "SELECT * FROM pseudocodigo WHERE programa=? AND sistema=?",
        (programa, sistema)).fetchone()
    if not row:
        raise SystemExit("pseudocodigo %s/%s no encontrado" % (sistema, programa))
    md = row["contenido"]
    tipo = row["tipo"]
    con.close()

    h1, blocks = parse_blocks(md)
    # `# Pseudocódigo — L010_CONTROL · Librería … (S500 · ALGOL)`
    #                   ^^^ nombre        ^^^ descripción
    head_txt = h1.split("— ", 1)[1] if "— " in h1 else h1
    nombre, desc = (head_txt.split(" · ", 1) + [""])[:2] if " · " in head_txt \
        else (head_txt, "")
    title = "%s — Pseudocódigo Digital Brain" % programa
    hero_h1 = "%s · <span>%s</span>" % (nombre, desc)
    tip = TIPO_LABEL.get(tipo, "Programa")
    lang = detect_lang(md)
    badges = ('<span class="pb" style="background:#0a1e28;border-color:#6CC5D8;color:#6CC5D8">%s</span>'
              '<span class="pb" style="background:#160a24;border-color:#b98ce0;color:#d9c2f2">%s</span>'
              '<span class="pb" style="%s">%s</span>'
              % (sistema, tip, LANG_STYLE[lang], lang))

    content, toc = render_pseudo_content(blocks)
    toc_html = NL.join('<a class="toc-%s" href="#%s">%s</a>' % (lvl, hid, txt)
                       for lvl, hid, txt in toc)

    head = (TPL / "pseudo_head.html").read_text(encoding="utf-8").replace("{{TITLE}}", title)
    parts = [
        head.rstrip(NL),
        '<div class="pseudo-wrap">',
        '  <nav class="toc"><div class="toc-title">Contenido</div>',
        toc_html,
        "  </nav>",
        '  <main class="pseudo-main">',
        '    <div class="phero">',
        "      <h1>%s</h1>" % hero_h1,
        "      <div>%s</div>" % badges,
        "    </div>",
        content,
        "  </main>",
        "</div>",
        "</body></html>",
    ]
    return NL.join(parts) + NL


# ════════════════════════════════════════════════════════════════════════════
#  MODELO DE CAPACIDADES
# ════════════════════════════════════════════════════════════════════════════
# classDefs oscuros fijos (orden fijo) que reemplazan a los del mermaid crudo.
CAP_CLASSDEFS = [
    "classDef ext fill:#0e2e3a,stroke:#f0736b,color:#F0F8FA;",
    "classDef xcap fill:#33300f,stroke:#ffd54a,stroke-width:2.5px,color:#ffe98a;",
    "classDef canal fill:#0e2e3a,stroke:#6CC5D8,color:#F0F8FA;",
    "classDef bd fill:#0e2e3a,stroke:#5aa9e0,color:#F0F8FA;",
    "classDef arch fill:#0e2e3a,stroke:#6CC5D8,color:#F0F8FA;",
    "classDef cap fill:#0e2e3a,stroke:#b98ce0,stroke-width:2px,color:#F0F8FA;",
    "classDef term fill:#0e2e3a,stroke:#66bb6a,color:#F0F8FA;",
]


def transform_mermaid(raw: str) -> str:
    lines = raw.replace("\r\n", "\n").split("\n")
    body = [l for l in lines if not l.lstrip().startswith("classDef")]
    while body and not body[-1].strip():   # drop trailing blanks
        body.pop()
    esc = [esc_mermaid(l) for l in body]
    # click directives for xcap nodes cuya etiqueta contiene cap-XXX
    clicks = []
    for l in body:
        m = re.match(r"\s*([A-Za-z0-9_]+)[\[(]", l)
        if not m:
            continue
        cm = re.search(r"cap-([a-z]+)", l)
        if cm:
            cap = cm.group(1)
            clicks.append('  click %s "cap-%s.html#diag" "Ir al flujo de cap-%s"'
                          % (m.group(1), cap, cap))
    return NL.join(esc + clicks + CAP_CLASSDEFS)


def cap_section_meta(title: str):
    """→ (id, sn, kind).  kind ∈ {None,'amp','sme','changelog'}."""
    t = title.strip()
    fixed = {"Contexto funcional": ("ctx", "1"), "Inventario de Tareas": ("inv", "2"),
             "Casuísticas": ("cas", "3"), "Diagrama de secuencia": ("seq", "4"),
             "Diagrama de flujo": ("flujo", "5"), "Reglas vinculadas": ("reg", "6")}
    for k, (i, s) in fixed.items():
        if t.startswith(k):
            return (i, s, None)
    if t.startswith("Secuencia"):
        return ("seq", "4", None)
    if t.startswith("Hallazgos"):
        return ("hal", "7", None)
    m = re.match(r"Ampliación\s*[—–-]\s*(P\d+)", t)
    if m:
        return ("amp-" + m.group(1).lower(), "AMP", "amp")
    if t.startswith("Ampliación"):
        return (("amp-" + slugify(t))[:20], "AMP", "amp")
    m = re.match(r"M(\d)\b", t)
    if m:
        return ("m" + m.group(1), "M" + m.group(1), None)
    if t.startswith("Comentarios") and "SME" in t:
        return ("sme", None, "sme")
    if t.startswith("CHANGELOG"):
        return ("changelog", None, "changelog")
    return (slugify(t, 20), None, None)


def cap_h2(title, cid, sn, kind):
    if kind == "amp":
        return ('<h2 id="%s" class="amp-h"><span class="sn" style="background:#1E8FA0">AMP</span>%s</h2>'
                % (cid, inline(title, False)))
    if kind == "changelog" or sn is None:
        return '<h2 id="%s">%s</h2>' % (cid, inline(title, False))
    return '<h2 id="%s"><span class="sn">%s</span>%s</h2>' % (cid, sn, inline(title, False))


def render_cap_blocks(blocks):
    out = []
    for b in blocks:
        if b.kind == "hr":
            continue
        elif b.kind == "h3":
            out.append("<h3>%s</h3>" % inline(b.data, False))
        elif b.kind == "bq":
            out.append("<blockquote>%s</blockquote>"
                       % "".join("<p>%s</p>" % inline(x, False) for x in b.data))
        elif b.kind == "p":
            out.append("<p>%s</p>" % inline(b.data, False))
        elif b.kind in ("list", "pseudo"):
            # Las capacidades no llevan listas ni <pre>: se reunifican en párrafo.
            out.append("<p>%s</p>"
                       % inline(" ".join(x.strip() for x in b.data), False))
        elif b.kind == "table":
            out.append(render_table(b.data, False))
        elif b.kind == "fence":
            if b.meta == "mermaid":
                out.append('<div class="mermaid mmscroll">\n%s\n</div>' % NL.join(b.data).strip("\n"))
            else:
                out.append("<pre><code>%s</code></pre>"
                           % NL.join(b.data).replace("&", "&amp;").replace("<", "&lt;")
                           .replace(">", "&gt;").replace('"', "&quot;"))
    return out


# Las notas SME del brain vienen con paleta clara; el portal validado las pinta en oscuro.
SME_STYLE_MAP = {
    "background:#FFF3CD;border-left:3px solid #DA291C;padding:8px 12px;margin:8px 0":
        "background:rgba(245,166,35,.10);color:#F0F8FA;border-left:3px solid #F5A623;"
        "padding:9px 13px;margin:8px 0;border-radius:0 7px 7px 0",
    "background:#FFF3CD;border-left:3px solid #DA291C;padding:2px 6px":
        "background:#2a2205;border-left:3px solid #f0c04a;padding:2px 6px;color:#ffe6a8;border-radius:3px",
}


def dark_sme_styles(html: str) -> str:
    for light, dark in SME_STYLE_MAP.items():
        html = html.replace('style="%s"' % light, 'style="%s"' % dark)
    return html


def flujo_subflows(ens_md: str, slug: str):
    """[(subid, titulo, mermaid_raw, narrative_md)] si la sección usa `### 5.x · …`; si no, []."""
    ens_md = ens_md.replace("\r\n", "\n")
    m = re.search(r"^## cap-%s\b.*?$" % re.escape(slug), ens_md, re.M)
    if not m:
        return []
    nxt = re.search(r"^## cap-", ens_md[m.end():], re.M)
    section = ens_md[m.end(): m.end() + nxt.start()] if nxt else ens_md[m.end():]
    heads = list(re.finditer(r"^### (5\.[a-z])\s*·\s*(.+)$", section, re.M))
    subs = []
    for k, h in enumerate(heads):
        body = section[h.end(): heads[k + 1].start() if k + 1 < len(heads) else len(section)]
        fm = re.search(r"```mermaid\n(.*?)\n```", body, re.S)
        narr = body[fm.end():] if fm else body
        narr = re.split(r"^---\s*$", narr, flags=re.M)[0].strip()
        subs.append((h.group(1), h.group(2).strip(), fm.group(1) if fm else "", narr))
    return subs


def flujo_section_from_ensamblado(ens_md: str, slug: str):
    """Extrae (mermaid_raw, narrative_md) de la sección cap-{slug} de flujos-ensamblado.md."""
    ens_md = ens_md.replace("\r\n", "\n")
    m = re.search(r"^## cap-%s\b.*?$" % re.escape(slug), ens_md, re.M)
    if not m:
        return None, None
    start = m.start()
    nxt = re.search(r"^## cap-", ens_md[m.end():], re.M)
    section = ens_md[start: m.end() + nxt.start()] if nxt else ens_md[start:]
    fm = re.search(r"```mermaid\n(.*?)\n```", section, re.S)
    mermaid_raw = fm.group(1) if fm else ""
    nar = re.search(r"(### Narrativa del flujo.*)", section, re.S)
    narrative_md = nar.group(1).strip() if nar else ""
    return mermaid_raw, narrative_md


def build_cap(slug: str) -> str:
    con = db()
    cap = con.execute("SELECT * FROM capacidades WHERE slug=?", (slug,)).fetchone()
    doc = con.execute("SELECT contenido FROM kb_documents WHERE path=?",
                      ("capacidades/cap-%s.md" % slug,)).fetchone()["contenido"]
    ens = con.execute("SELECT contenido FROM kb_documents WHERE path='flujos-ensamblado.md'"
                      ).fetchone()["contenido"]
    kb_version = con.execute("SELECT value FROM stats WHERE key='kb_version'").fetchone()["value"]
    prog_rows = con.execute("SELECT prog_id, sistema FROM programs WHERE bc_slug=?", (slug,)).fetchall()
    con.close()

    bian = cap["bian_ref"]
    h1, blocks = parse_blocks(doc)
    bc_id, nombre = (h1.split(" · ", 1) + [""])[:2]

    # frontmatter (bloques antes del primer h2)
    fm_blocks = []
    idx = 0
    while idx < len(blocks) and blocks[idx].kind != "h2":
        fm_blocks.append(blocks[idx])
        idx += 1
    fm_lines = doc.replace("\r\n", "\n").split("\n")
    progs = re.findall(r"\*\*(P\d+)\*\*", next((l for l in fm_lines if l.startswith("> Cobertura:")), ""))
    n_progs = len(prog_rows) or len(set(re.findall(r"\bP\d{3}\b", doc)))
    sistemas = sorted({r["sistema"] for r in prog_rows if r["sistema"]}, key=lambda s: (s != "S500", s))
    sistema = "+".join(sistemas) or (cap["sistema"] or "")
    if sistema == "AMBOS":
        sistema = "S500+S151"
    # Un rango RN-x-218..227 cuenta sólo su extremo inicial (criterio del portal validado).
    reglas = len(set(re.findall(r"RN-S\d{3}-\d+", doc)))
    version = kb_version.split(" / ")[0].strip()

    # secciones
    sections = []
    cur = None
    for b in blocks[idx:]:
        if b.kind == "h2":
            cur = (b.data, [])
            sections.append(cur)
        elif cur is not None:
            cur[1].append(b)

    # stats derivadas del md
    tareas = len(set(re.findall(r"\bT-[A-Z]+-\d+\b", doc)))
    casuisticas = 0
    for title, cont in sections:
        cid = cap_section_meta(title)[0]
        if cid == "cas":
            casuisticas = sum(1 for b in cont if b.kind == "h3")

    # ── hero ──
    hero = [
        '  <div class="eyebrow reveal"><span class="dot"></span>Modelo de Capacidades · %s</div>' % bc_id,
        '  <h1 class="reveal">%s · <span>%s</span></h1>' % (bc_id, nombre),
        '  <p class="subtitle reveal">%s</p>'
        % " &middot; ".join(x for x in (bian, sistema, " · ".join(progs), KB_NAME, version) if x),
        '  <div class="stats reveal">',
        '<div class="stat"><div class="statn">%d</div><div class="statl">Programas</div></div>' % n_progs,
        '<div class="stat"><div class="statn">%d</div><div class="statl">Reglas</div></div>' % reglas,
        '<div class="stat"><div class="statn">%d</div><div class="statl">Tareas</div></div>' % tareas,
        '<div class="stat"><div class="statn">%d</div><div class="statl">Casuísticas</div></div>' % casuisticas,
        '<div class="stat"><div class="statn">%s</div><div class="statl">Sistema</div></div>' % sistema,
        "  </div>",
    ]

    # ── meta-card ──
    fm_bq = next((b for b in fm_blocks if b.kind == "bq"), None)
    bq_html = "".join("<p>%s</p>" % inline(x, False) for x in fm_bq.data) if fm_bq else ""
    meta_card = ('<div class="card meta-card reveal"><p># %s</p>%s<blockquote>%s</blockquote></div>'
                 % (h1, NL, bq_html))

    # ── cards ──
    slug_up = slug.upper()
    body_lines = list(hero) + [meta_card]
    for si, (title, cont) in enumerate(sections):
        cid, sn, kind = cap_section_meta(title)
        nxt_is_flujo = (si + 1 < len(sections)
                        and cap_section_meta(sections[si + 1][0])[0] == "flujo")
        if kind == "sme":
            sme = (TPL / "cap_sme_card.html").read_text(encoding="utf-8").replace(
                "{{SLUG_UPPER}}", slug_up).replace("\r\n", "\n")
            body_lines.append(sme)
            continue
        if cid == "flujo" and flujo_subflows(ens, slug):
            card = ['<div class="card reveal">' + cap_h2(title, cid, sn, kind), ""]
            for subid, stitle, mraw, narr in flujo_subflows(ens, slug):
                card.append('<h3 id="diag-%s">%s · %s</h3>'
                            % (subid.replace(".", ""), subid, inline(stitle, False)))
                card += ['<div class="mermaid">', transform_mermaid(mraw), "</div>"]
                for para in re.split(r"\n\s*\n", narr):
                    if para.strip():
                        card.append('<p class="nar">%s</p>'
                                    % inline(" ".join(x.strip() for x in para.split("\n")), False))
            card[-1] = card[-1] + "</div>"
            body_lines.append(NL.join(card))
            continue
        if cid == "flujo":
            mraw, narr = flujo_section_from_ensamblado(ens, slug)
            mer = transform_mermaid(mraw)
            _, nblocks = parse_blocks("# x\n\n" + narr)
            narr_html = render_cap_blocks(nblocks)
            card = ['<div class="card reveal">' + cap_h2(title, cid, sn, kind), "",
                    '<div class="mermaid">', mer, "</div>"] + narr_html
            card[-1] = card[-1] + "</div>"
            body_lines.append(NL.join(card))
            continue
        content = render_cap_blocks(cont)
        if nxt_is_flujo:
            content += ["<hr>", '<span id="diag" style="position:relative;top:-70px"></span>']
        card = ['<div class="card reveal">' + cap_h2(title, cid, sn, kind)] + content
        if len(card) == 1:
            card[0] += "</div>"
        else:
            card[-1] = card[-1] + "</div>"
        body_lines.append(NL.join(card))

    title_tag = "%s · %s — Enterprise Digital Brain Banamex" % (bc_id, nombre)
    head = (TPL / "cap_head.html").read_text(encoding="utf-8").replace("{{TITLE}}", title_tag)
    foot = (TPL / "cap_foot.html").read_text(encoding="utf-8")
    foot = (foot.replace("{{KB_NAME}}", KB_NAME).replace("{{CAPTITLE}}", h1)
                .replace("{{SLUG_UPPER}}", slug_up).replace("{{SLUG}}", slug))

    body_lines = [dark_sme_styles(x) for x in body_lines]
    parts = [head.rstrip(NL)] + body_lines + ["</main>", foot.rstrip(NL)]
    return NL.join(parts)   # cap NO lleva newline final (ver referencia)


# ════════════════════════════════════════════════════════════════════════════
#  INDEX (dashboard) — shell templado + agregados del brain
# ════════════════════════════════════════════════════════════════════════════
def build_index() -> str:
    con = db()
    rules = con.execute("SELECT value FROM stats WHERE key='rules'").fetchone()["value"]
    objetos = con.execute("SELECT value FROM stats WHERE key='inventario'").fetchone()["value"]
    con.close()
    rules_fmt = "{:,}".format(int(rules))   # 1583 → "1,583"
    tpl = (TPL / "index_page.html").read_text(encoding="utf-8")
    tpl = tpl.replace("{{RULES}}", rules_fmt).replace("{{OBJETOS}}", str(objetos))
    return tpl


# ── asset copy ──────────────────────────────────────────────────────────────
def copy_assets():
    dst = OUT / "assets"
    dst.mkdir(parents=True, exist_ok=True)
    for f in ("d3.min.js", "mermaid.min.js"):
        shutil.copyfile(REF_ASSETS / f, dst / f)


def write(relpath: str, html: str):
    p = OUT / relpath
    p.parent.mkdir(parents=True, exist_ok=True)
    data = html.replace("\r\n", "\n").replace("\n", "\r\n")  # reference usa CRLF
    p.write_bytes(data.encode("utf-8"))
    print("wrote", relpath, len(data))


# ── main ────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    args = sys.argv[1:]
    copy_assets()
    if not args:
        write("pseudocodigo/S500_P046.html", build_pseudo("P046", "S500"))
        write("modelo capacidades/cap-pos.html", build_cap("pos"))
        write("index.html", build_index())
    elif args[0] == "pseudo":
        prog = args[1]
        sis = args[2] if len(args) > 2 else "S500"
        write("pseudocodigo/%s_%s.html" % (sis, prog), build_pseudo(prog, sis))
    elif args[0] == "cap":
        write("modelo capacidades/cap-%s.html" % args[1], build_cap(args[1]))
    elif args[0] == "index":
        write("index.html", build_index())
    elif args[0] == "all":
        con = db()
        pseudos = con.execute("SELECT programa, sistema FROM pseudocodigo ORDER BY sistema, programa").fetchall()
        caps = con.execute("SELECT slug FROM capacidades ORDER BY slug").fetchall()
        con.close()
        ok_ps = err_ps = 0
        for prog, sis in pseudos:
            try:
                write("pseudocodigo/%s_%s.html" % (sis, prog), build_pseudo(prog, sis))
                ok_ps += 1
            except Exception as e:
                print("ERROR pseudo %s/%s: %s" % (sis, prog, e))
                err_ps += 1
        ok_cap = err_cap = 0
        for (slug,) in caps:
            try:
                write("modelo capacidades/cap-%s.html" % slug, build_cap(slug))
                ok_cap += 1
            except Exception as e:
                print("ERROR cap %s: %s" % (slug, e))
                err_cap += 1
        write("index.html", build_index())
        print("\n=== TOTAL: pseudo %d ok / %d err | cap %d ok / %d err ===" % (ok_ps, err_ps, ok_cap, err_cap))
