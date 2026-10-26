#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-sanitized.py — Genera una version SANITIZADA del portal Enterprise Digital
Brain del core mainframe, apta para pitch a cualquier cliente:

  · anonimiza al cliente:   Banamex / BANAMEX / BNMX  → LegacyCore / LGCR
  · anonimiza al grupo:     Citi / Citibank / CitiDirect → Global / GlobalBank / GlobalDirect
  · renombra los sistemas:  S500 → CORE-DEP · S151 → CORE-GL (texto, hrefs y nombres de archivo)
  · neutraliza literales:   clave de institucion 485, cuenta propia 0000200002, BINs de tarjeta
  · seudonimiza personas:   los 34 autores reales y sus proveedores → Autor NN / Proveedor NN
  · marca Accenture:        logo Banamex (embebido y en assets) → logo Accenture
                            acento rojo #C1272D / #DA291C → morado Accenture #A100FF

Se conservan a proposito: Unisys ClearPath MCP, nombres de programa (P655, L012),
capacidades, y toda la paleta semantica del portal (severidad, dominios, reguladores).

NO toca los originales: lee de unisys/portal/ y escribe a unisys/sanitized/.
Al terminar corre un barrido de fugas sobre la salida y reporta PASS/FAIL.

USO:
    python build-sanitized.py

EXIT CODES:
    0 = PASS (sin fugas)  ·  1 = FAIL (quedaron tokens del cliente)
"""

import base64
import json
import os
import re
import shutil
import sqlite3
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

GEN = Path(__file__).resolve().parent
BASE = GEN.parent
SRC = BASE / "portal"
STAGING = GEN / "_staging"
OUT = BASE / "sanitized"
DB = BASE / "digital-brain" / "brain.db"

ALIAS = "LegacyCore"


# ── 0) personas y proveedores ────────────────────────────────────────────────
# La capa de Almas nombra personal real del cliente y a sus proveedores. En el
# portal interno eso es legitimo: el bus factor sin nombres no sirve para actuar.
# Aqui no. La lista NO se escribe a mano: sale de la tabla autores del brain, de
# modo que un autor nuevo queda seudonimizado solo. Se preserva el orden por
# numero de programas, asi la historia de concentracion sobrevive sin identidades.

PREFIJO = {"persona": "Autor", "organizacion": "Proveedor", "credencial": "Credencial"}

# El cliente firma como autor en la division AUTHOR. de algun programa, asi que entra
# al censo de organizaciones y se llevaba un seudonimo de proveedor. Eso lo convertia
# en "Proveedor NN" en TODO el portal -- prosa, etiquetas de campo, comentarios de
# codigo -- ganandole a la regla de marca de mas abajo, que es la que debe atenderlo
# (BANAMEX -> LEGACYCORE). Se excluye solo la forma exacta: un area interna como
# "FABRICA DE SOFTWARE BANAMEX" sigue siendo un proveedor y conserva su seudonimo.
CLIENTE_EXACTO = {"BANAMEX", "CITIBANAMEX", "BNMX", "BNM"}

ACENTOS = {"A": "AÁÀÄÂ", "E": "EÉÈËÊ", "I": "IÍÌÏÎ", "O": "OÓÒÖÔ", "U": "UÚÙÜÛ", "N": "NÑ"}


def _sin_acento(s: str) -> str:
    tabla = str.maketrans("ÁÀÄÂÉÈËÊÍÌÏÎÓÒÖÔÚÙÜÛÑáàäâéèëêíìïîóòöôúùüûñ",
                          "AAAAEEEEIIIIOOOOUUUUNaaaaeeeeiiiioooouuuun")
    return s.translate(tabla)


def _tokens(s: str) -> set[str]:
    return {t for t in re.split(r"[^A-Za-z]+", _sin_acento(s).upper()) if len(t) > 1}


def rx_flexible(nombre: str) -> re.Pattern:
    """Un nombre se escribe de varias formas en el portal: la division AUTHOR. lo
    guarda en mayusculas y sin acentos (LINO HECTOR TORRES CORONADO) mientras que
    la prosa curada lo escribe con acentos (Lino Héctor Torres Coronado). El
    patron tolera ambas, y admite apellidos de mas al final."""
    partes = []
    for ch in _sin_acento(nombre).upper():
        if ch in ACENTOS:
            partes.append(f"[{ACENTOS[ch]}]")
        elif ch.isalnum():
            partes.append(re.escape(ch))
        elif ch == " ":
            partes.append(r"\s+")
        else:
            partes.append(re.escape(ch))
    # Apellidos adicionales que la prosa trae y la division no (JUVENAL RUIZ SOTO).
    # Va en (?-i:...) a proposito: bajo IGNORECASE, [A-Z][a-z]+ casaria con
    # cualquier palabra y se comeria el texto que sigue al nombre.
    cola = (r"(?-i:(?:\s+(?:de\s+la\s+|de\s+|del\s+)?[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+"
            r"|\s+[A-ZÁÉÍÓÚÑ]{3,})*)")
    # Los \b evitan que un nombre corto se reemplace dentro de otra palabra.
    return re.compile(r"\b" + "".join(partes) + cola + r"\b", re.IGNORECASE)


RE_AUTOR_PROSA = re.compile(
    r"(?:[Aa]utor(?:es)?(?:\s+original)?|author|AUTHOR\.)\s*:?\s+"
    r"((?:[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+|[A-ZÁÉÍÓÚÑ]{2,})"
    r"(?:\s+(?:de\s+la\s+|de\s+|del\s+)?(?:[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+|[A-ZÁÉÍÓÚÑ]{2,})){1,4})")

RUIDO = {"ORIGINAL", "DEL", "SISTEMA", "DE", "LA", "EL", "INGENIERIA", "SOFTWARE"}


def _nombres_en_portal() -> set[str]:
    """Los nombres tambien viven en la prosa curada del brain, no solo en la
    division AUTHOR.. Se minan del propio portal para que la lista no haya que
    mantenerla a mano."""
    out = set()
    for f in SRC.rglob("*.html"):
        for n in RE_AUTOR_PROSA.findall(f.read_text(encoding="utf-8", errors="replace")):
            n = " ".join(n.split())
            if len(_tokens(n)) >= 2 and not _tokens(n) <= RUIDO:
                out.add(n)
    return out


def seudonimos() -> list[tuple[re.Pattern, str]]:
    if not DB.is_file():
        return []
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    try:
        filas = con.execute("SELECT display, tipo, formas FROM autores "
                            "ORDER BY n_programas DESC, display").fetchall()
    except sqlite3.OperationalError:
        return []
    finally:
        con.close()

    alias_de: dict[str, str] = {}
    grupos: list[tuple[set[str], str]] = []
    n = {k: 0 for k in PREFIJO}
    for f in filas:
        if _sin_acento(f["display"]).strip().upper() in CLIENTE_EXACTO:
            continue
        tipo = f["tipo"] if f["tipo"] in PREFIJO else "credencial"
        n[tipo] += 1
        alias = f"{PREFIJO[tipo]} {n[tipo]:02d}"
        formas = {f["display"]} | set((f["formas"] or "").split(" | "))
        formas = {x.strip() for x in formas if x.strip()}
        formas = {x for x in formas if _sin_acento(x).upper() not in CLIENTE_EXACTO}
        for forma in formas:
            alias_de[forma] = alias
        grupos.append((_tokens(f["display"]), alias))

    # Un nombre minado de la prosa se pega al mismo alias si comparte dos tokens
    # con un autor del brain; si no, estrena alias propio.
    for nom in _nombres_en_portal():
        if nom in alias_de:
            continue
        tn = _tokens(nom)
        destino = next((a for tg, a in grupos if len(tn & tg) >= 2), None)
        if destino is None:
            n["persona"] += 1
            destino = f"{PREFIJO['persona']} {n['persona']:02d}"
            grupos.append((tn, destino))
        alias_de[nom] = destino

    # Las formas largas primero: "RICARDO MORENO A" mutilaria a "RICARDO MORENO ARZAVE".
    # Las de menos de 5 caracteres (AS, CD, FT, MPD, JARC) quedan fuera: son
    # iniciales que no identifican a nadie por si solas y, en cambio, casarian
    # con palabras y con sintaxis SQL del codigo mostrado.
    return [(rx_flexible(f), alias_de[f])
            for f in sorted(alias_de, key=len, reverse=True) if len(f) >= 5]


RE_EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")

# ── 1) logos ─────────────────────────────────────────────────────────────────

LOGO_CLIENTE = SRC / "assets" / "logos" / "banamex.png"
LOGO_ACN = GEN / "_accenture-logo.png"

B64_CLIENTE = base64.b64encode(LOGO_CLIENTE.read_bytes()).decode()
B64_ACN = base64.b64encode(LOGO_ACN.read_bytes()).decode()

# ── 2) reemplazos de texto ───────────────────────────────────────────────────
# El orden es el contrato: lo compuesto y lo especifico va antes que lo generico.
# pad=True compensa el ancho en codigo de formato fijo (COBOL/ALGOL): si el token
# viene seguido de 2+ espacios, se consume o se agrega el delta para no desalinear
# las columnas de PIC / numero de secuencia.

SEUDONIMOS = seudonimos()

TEXT = [
    # --- activos de marca: antes que cualquier regla generica de Banamex ---
    # El logo embebido NO se reemplaza aqui: va en el restore de blobs (ver sanitize_text).
    ('alt="Banamex"', 'alt="Accenture"', False),
    ("assets/logos/banamex.png", "assets/logos/accenture.png", False),
    ("logos/banamex.png", "logos/accenture.png", False),
    ("brain-banamex.js", "brain-legacycore.js", False),

    # --- la marca fusionada es el cliente, no el grupo: va antes que ambos ---
    ("Citibanamex", ALIAS, True),
    ("CITIBANAMEX", ALIAS.upper(), True),
    ("citibanamex", ALIAS.lower(), True),

    # --- grupo matriz ---
    ("Citibank", "GlobalBank", True),
    ("CITIBANK", "GLOBALBANK", True),
    ("citibank", "globalbank", True),
    ("Citigroup", "GlobalGroup", True),
    ("CITIGROUP", "GLOBALGROUP", True),
    ("Citi", "Global", True),
    ("CITI", "GLOBAL", True),
    ("citi", "global", True),

    # --- cliente ---
    ("Banamex", ALIAS, True),
    ("BANAMEX", ALIAS.upper(), True),
    ("banamex", ALIAS.lower(), True),
    ("BNMX", "LGCR", True),
    ("Bnmx", "Lgcr", True),
    ("bnmx", "lgcr", True),

    # --- sistemas (texto, hrefs y nombres de archivo quedan consistentes) ---
    ("S500", "CORE-DEP", True),
    ("s500", "core-dep", True),
    ("S151", "CORE-GL", True),
    ("s151", "core-gl", True),

    # --- cuenta propia hardcodeada ---
    ("0000200002", "0000900009", False),
]

# Clave de institucion incrustada como literal. El guardia evita tocar numeros de
# secuencia (004850), identificadores de regla (RN-CORE-GL-485) y referencias de
# linea (L485): solo cae el literal suelto.
RE_CLAVE_INST = re.compile(r"(?<![\w-])485(?!\w)")

# Paleta: solo el acento de marca. Los hex semanticos del portal no se tocan.
HEX = {
    "C1272D": "A100FF",   # rojo de marca (dot de estado, pulse) → morado Accenture
    "DA291C": "A100FF",   # rojo de marca (borde de callout)
}

# Los BIN de tarjeta identifican al emisor aunque el nombre ya este anonimizado.
# Viven en un unico bloque del catalogo de reglas; se remapean solo ahi.
BIN_MAP = {"0793": "0993", "0794": "0994", "0795": "0995", "0796": "0996",
           "1502": "1902", "1503": "1903", "1504": "1904", "3505": "3905"}
RE_BIN_BLOQUE = re.compile(r"CLAVE 1500 se convierte.{0,600}?(?=\", \"exc\")", re.S)

# Corrida larga de alfanumericos sin puntuacion: base64 embebido, nunca prosa ni codigo.
RE_BLOB = re.compile(r"[A-Za-z0-9+/=]{200,}")

# ── 3) nombres de archivo ────────────────────────────────────────────────────

RENAME = [
    ("S500_", "CORE-DEP_"), ("S151_", "CORE-GL_"),
    ("wfl-s500-", "wfl-core-dep-"), ("wfl-s151-", "wfl-core-gl-"),
    ("brain-banamex.js", "brain-legacycore.js"),
    ("banamex.png", "accenture.png"),
]

TEXTO_EXT = {".html", ".htm", ".json", ".md", ".txt", ".css", ".svg"}
SALTAR = {"d3.min.js", "mermaid.min.js", "three.min.js"}   # librerias de terceros


def outname(rel: str) -> str:
    for a, b in RENAME:
        rel = rel.replace(a, b)
    return rel


def _sub(s: str, old: str, new: str, pad: bool) -> str:
    """Reemplaza old por new. Con pad, compensa el delta de ancho contra la
    corrida de espacios que sigue, para no desalinear codigo de formato fijo."""
    if old not in s:
        return s
    if not pad:
        return s.replace(old, new)
    delta = len(new) - len(old)
    if delta == 0:
        return s.replace(old, new)
    pat = re.compile(re.escape(old) + r"(?P<sp> *)")

    def repl(m):
        sp = m.group("sp")
        if len(sp) >= 2:                       # firma de columna fija
            sp = sp[delta:] if delta > 0 and len(sp) > delta else sp + " " * max(0, -delta)
        return new + sp

    return pat.sub(repl, s)


def sanitize_text(s: str) -> str:
    # Los blobs base64 (logo embebido, geometria del cerebro 3D) se retiran antes de
    # reemplazar: una coincidencia por azar dentro de un blob corrompe el binario.
    # Vuelven intactos al final, salvo el del logo, que ahi mismo cambia de marca.
    blobs: list[str] = []

    def esconder(m):
        blobs.append(m.group(0))
        return f"\x00BLOB{len(blobs) - 1}\x00"

    s = RE_BLOB.sub(esconder, s)

    # Personas y correos antes que nada: un nombre puede contener la marca del
    # cliente ("FABRICA DE SOFTWARE BANAMEX") y debe caer entero, no a pedazos.
    for rx, alias in SEUDONIMOS:
        s = rx.sub(alias, s)
    s = RE_EMAIL.sub("persona@ejemplo.com", s)

    for old, new, pad in TEXT:
        s = _sub(s, old, new, pad)
    s = RE_CLAVE_INST.sub("999", s)

    def bins(m):
        bloque = m.group(0)
        for a, b in BIN_MAP.items():
            bloque = re.sub(r"(?<!\d)" + a + r"(?!\d)", b, bloque)
        return bloque

    s = RE_BIN_BLOQUE.sub(bins, s)

    for i, blob in enumerate(blobs):
        s = s.replace(f"\x00BLOB{i}\x00", B64_ACN if blob == B64_CLIENTE else blob)
    return s


def sanitize_hex(s: str) -> str:
    for a, b in HEX.items():
        s = re.sub("#" + a, "#" + b, s, flags=re.IGNORECASE)
    return s


# ── 3.5) el hub, reagrupado por las 8 capas del metodo ──────────────────────
# El portal interno declara "2 Capas AS-IS" y agrupa por tipo de artefacto. Esa
# reagrupacion se aplica SOLO sobre la copia saneada, en memoria y antes de
# sanear, para que las tarjetas inyectadas pasen por las mismas reglas que el
# resto. El portal interno no se toca.
#
# Numeracion: la de HVM/metodologia-gemelo-cognitivo.md, que es la que el propio
# portal ya rotulaba en Capa 4 Intencion, Capa 5 Fronteras y Capa 6 Siembra.

MITADES = [
    ("Entender el sistema · AS-IS",
     "El gemelo nace. Cuatro capas que reconstruyen el sistema tal como es, "
     "del idioma que habla hasta las decisiones que toma.",
     [(1, "Lenguaje", "El vocabulario del negocio fosilizado en paragraph names, data-items "
       "COBOL y records DASDL.", ["vocab.html", "modelo-er.html"]),
      (2, "Almas", "Quién escribió el código y qué dialecto hablaba. La Ley de Conway: la "
       "organización que construyó el sistema, legible en el propio fuente.", ["almas.html"]),
      (3, "Biografía", "Las vetas del árbol. Cuándo nació y mutó el core, y qué proyecto dejó "
       "cada marca fechada en los comentarios.", ["biografia.html"]),
      (4, "Intención", "El modelo mental consultable: call graph real, dominios de negocio, "
       "capacidades bancarias y reglas ancladas al código.",
       ["modelo-capacidades.html", "rules-report.html", "pseudocodigo.html",
        "cap-relationships.html", "traceability.html", "wfl.html", "chord-gemcog.html"])]),
    ("Engendrar el futuro · TO-BE",
     "El gemelo deja de describir y empieza a construir. Cuatro capas que llevan "
     "el entendimiento hasta el target en producción.",
     [(5, "Fronteras", "Por dónde cortar: las costuras del legacy y los contextos delimitados "
       "del target, derivados de la intención y no de la partición por base de datos.",
       ["integration.html"]),
      (6, "Siembra", "El gemelo como especificación que siembra la construcción del target.",
       ["cobol-java.html", "arq-tobe.html"]),
      (7, "Equivalencia", "El oráculo de comportamiento: qué puede divergir entre legacy y "
       "target, y qué hay que probar antes del cutover.", ["equivalencia.html"]),
      (8, "Continuidad", "El gemelo vivo después del cutover: avance del decommission, "
       "observabilidad y la memoria que sobrevive a ambos sistemas.", [])]),
]

SHEAD = """<div class="shead reveal"><div class="kick">Explora · 8 Capas del Gemelo Cognitivo</div>
      <h2>Vistas del Digital Brain</h2>
      <p>Las vistas siguen el método: las capas <b>1 a 4</b> entienden el sistema como es hoy,
      las capas <b>5 a 8</b> lo proyectan al target. Si es tu primera visita, empieza por el
      <a href="modelo-capacidades.html">modelo de capacidades</a>: qué hace el banco, antes de
      ver cómo lo hace el código.</p></div>"""

CSS_HUB = """
.mhead{margin:58px 0 10px;padding-bottom:14px;border-bottom:1px solid rgba(255,255,255,.09)}
.mhead h3{font-size:clamp(19px,2.2vw,27px);font-weight:800;letter-spacing:-.02em}
.mhead span{display:block;margin-top:7px;font-size:13px;color:var(--muted);max-width:78ch;line-height:1.6}
.vcard.pend{opacity:.52;cursor:default}
"""


def _tarjeta(href: str, cards: dict) -> str:
    c = cards.get(href)
    if not c:
        return ""
    return (f'\n        <a class="vcard glass reveal" href="{href}" target="_blank">\n'
            f'          <div class="ico">{c["ico"]}</div><div>\n'
            f'            <div class="vt">{c["vt"]}</div>\n'
            f'            <div class="vd">{c["vd"]}</div>\n'
            f'            <div class="go">{c["go"]}</div>\n'
            f'          </div>\n        </a>')


def _grupos() -> str:
    cards = json.loads((GEN / "templates" / "index_cards.json").read_text(encoding="utf-8"))
    out = []
    for titulo, intro, capas in MITADES:
        out.append(f'\n    <div class="mhead reveal"><h3>{titulo}</h3><span>{intro}</span></div>')
        for num, nombre, desc, hrefs in capas:
            cuerpo = "".join(_tarjeta(h, cards) for h in hrefs)
            if not cuerpo:
                # La capa sin vistas se muestra igual: el hueco es informacion.
                cuerpo = ('\n        <div class="vcard glass reveal pend"><div class="ico">○</div>'
                          '<div><div class="vt">Sin vista todavía</div>'
                          '<div class="vd">Esta capa no tiene datos en el brain. Construirla '
                          'exigiría evidencia de operación del target, que aún no existe.</div>'
                          '</div></div>')
            out.append(
                f'\n    <div class="group">\n'
                f'      <div class="ghead reveal"><h3><span class="lbadge">{num}</span>&ensp;'
                f'{nombre}</h3><span>{desc}</span></div>\n'
                f'      <div class="cardgrid">{cuerpo}\n      </div>\n    </div>')
    return "".join(out)


def reagrupa_hub(s: str) -> str:
    i = s.find('<section id="vistas">')
    j = s.find("</section>", i)
    if i < 0 or j < 0:
        print("AVISO: no se encontro la seccion 'vistas'; el hub queda como estaba")
        return s
    sec = s[i:j]
    a = sec.find('<div class="shead reveal">')
    cta = sec.find("<!-- ── CHATBOT CTA ── -->")
    g1 = sec.find('<div class="group">')
    if min(a, cta, g1) < 0:
        print("AVISO: la seccion 'vistas' no tiene la forma esperada; el hub queda como estaba")
        return s
    nueva = sec[:a] + SHEAD + "\n\n    " + sec[cta:g1] + _grupos() + "\n  "
    s = s[:i] + nueva + s[j:]
    k = s.rfind("</style>")
    return s[:k] + CSS_HUB + s[k:] if k > 0 else s


# ── 4) recorrido ─────────────────────────────────────────────────────────────

def limpiar(d: Path):
    """Vacia la salida sin exigir borrar los directorios: OneDrive mantiene
    handles abiertos sobre las carpetas que esta sincronizando y rmtree falla."""
    if not d.exists():
        return
    for f in sorted(d.rglob("*"), reverse=True):
        try:
            f.unlink() if f.is_file() else f.rmdir()
        except OSError:
            pass            # carpeta bloqueada por el sync: se reutiliza tal cual


def main():
    if not SRC.is_dir():
        sys.exit(f"ERROR: no existe {SRC}")
    limpiar(OUT)
    OUT.mkdir(parents=True, exist_ok=True)

    n_txt = n_bin = 0
    for src in sorted(SRC.rglob("*")):
        if src.is_dir() or src.name == ".gitkeep":
            continue
        rel = src.relative_to(SRC).as_posix()
        dst = OUT / outname(rel)
        dst.parent.mkdir(parents=True, exist_ok=True)

        if src.name == LOGO_CLIENTE.name and src.parent.name == "logos":
            shutil.copy2(LOGO_ACN, dst)          # el png suelto tambien cambia de marca
            n_bin += 1
        elif src.suffix.lower() in TEXTO_EXT:
            s = src.read_text(encoding="utf-8", errors="replace")
            if rel == "index.html":
                s = reagrupa_hub(s)              # las 8 capas, solo en esta copia
            dst.write_text(sanitize_hex(sanitize_text(s)), encoding="utf-8")
            n_txt += 1
        elif src.suffix.lower() == ".js" and src.name not in SALTAR:
            s = src.read_text(encoding="utf-8", errors="replace")
            dst.write_text(sanitize_text(s), encoding="utf-8")
            n_txt += 1
        else:
            shutil.copy2(src, dst)
            n_bin += 1

    # Paginas de capa preparadas por build-capas.py, que no viven en el portal.
    n_cap = 0
    if STAGING.is_dir():
        for src in sorted(STAGING.glob("*.html")):
            s = src.read_text(encoding="utf-8", errors="replace")
            (OUT / outname(src.name)).write_text(
                sanitize_hex(sanitize_text(s)), encoding="utf-8")
            n_cap += 1

    danos = integridad_estructural()
    print(f"Archivos sanitizados : {n_txt}  (del portal, sin modificarlo)")
    print(f"Paginas de capa      : {n_cap}  (de generators/_staging)")
    print(f"Archivos copiados    : {n_bin}")
    print(f"Salida               : {OUT}")
    if danos:
        print(f"\nINTEGRIDAD ESTRUCTURAL: FAIL — {len(danos)} archivo(s) con marcado alterado")
        for ruta, a, b in danos[:6]:
            print(f"         · {ruta}: {a} etiquetas en origen, {b} en salida")
    else:
        print("\nINTEGRIDAD ESTRUCTURAL: PASS — marcado intacto en todos los HTML")
    return barrido_de_fugas() or (1 if danos else 0)


def integridad_estructural() -> list[tuple[str, int, int]]:
    """El saneado sustituye texto, nunca marcado. Si cambia el numero de etiquetas
    de un HTML es que un reemplazo se comio sintaxis: se reporta como dano."""
    malos = []
    for src in SRC.rglob("*.html"):
        rel = src.relative_to(SRC).as_posix()
        if rel == "index.html":
            continue     # el hub se reagrupa a proposito: su marcado SI cambia
        dst = OUT / outname(rel)
        if not dst.is_file():
            continue
        a = src.read_text(encoding="utf-8", errors="replace").count("<")
        b = dst.read_text(encoding="utf-8", errors="replace").count("<")
        if a != b:
            malos.append((dst.relative_to(OUT).as_posix(), a, b))
    return malos


# ── 5) barrido de fugas sobre la salida ──────────────────────────────────────

FUGAS = [
    ("nombre del cliente", re.compile(r"banamex", re.I)),
    ("grupo matriz", re.compile(r"citi", re.I)),
    ("abreviatura del cliente", re.compile(r"bnmx", re.I)),
    ("sistema S500", re.compile(r"s500", re.I)),
    ("sistema S151", re.compile(r"s151", re.I)),
    ("cuenta propia", re.compile(r"0000200002")),
    ("clave de institucion", RE_CLAVE_INST),
]

# Nombres propios de personal del cliente. Solo se vigilan los de dos o mas
# palabras: las siglas sueltas (FT, ISI, MPD) darian falsos positivos contra
# cualquier texto tecnico.
_personas = [rx for rx, alias in SEUDONIMOS
             if alias.startswith("Autor") and len(rx.pattern) > 40]
if _personas:
    FUGAS.append(("nombre de persona",
                  re.compile("|".join(r.pattern for r in _personas), re.IGNORECASE)))
# El propio sustituto es un correo valido: no debe contarse como fuga.
FUGAS.append(("correo electronico",
              re.compile(r"(?!persona@ejemplo\.com)" + RE_EMAIL.pattern)))


def barrido_de_fugas() -> int:
    print("\nBARRIDO DE FUGAS")
    print("=" * 62)
    hits = {etiqueta: [] for etiqueta, _ in FUGAS}
    for f in OUT.rglob("*"):                      # una sola lectura por archivo
        if not f.is_file() or f.suffix.lower() not in TEXTO_EXT | {".js"}:
            continue
        if f.name in SALTAR:
            continue
        s = RE_BLOB.sub(" ", f.read_text(encoding="utf-8", errors="replace"))
        for etiqueta, pat in FUGAS:
            n = len(pat.findall(s))
            if n:
                hits[etiqueta].append((f.relative_to(OUT).as_posix(), n))

    total = 0
    for etiqueta, _ in FUGAS:
        h = hits[etiqueta]
        n_total = sum(n for _, n in h)
        total += n_total
        estado = "PASS" if not n_total else "FAIL"
        print(f"[{estado}] {etiqueta:24s} {n_total:5d} ocurrencia(s) en {len(h)} archivo(s)")
        for ruta, n in sorted(h, key=lambda x: -x[1])[:5]:
            print(f"         · {ruta} ({n})")

    print("=" * 62)
    if total:
        print(f"RESULTADO: FAIL — {total} token(s) del cliente sobrevivieron")
        return 1
    print("RESULTADO: PASS — sin rastro del cliente en la salida")
    return 0


if __name__ == "__main__":
    sys.exit(main())
