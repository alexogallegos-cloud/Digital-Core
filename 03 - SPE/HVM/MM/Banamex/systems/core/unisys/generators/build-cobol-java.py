"""
build-cobol-java.py — Landing COBOL → Java y páginas de detalle por componente.

Entradas (solo lectura):
  knowledge-base/transpilacion/_inventario.json   inventario de 199 componentes
  knowledge-base/transpilacion/{SIS}_{PROG}.json  transpilación demostrativa (contrato: _SCHEMA.md)
  source/...                                       fuente original, para verificar cada segmento
  digital-brain/brain.db                           descripción de reglas (mode=ro)
Salidas:
  portal/cobol-java.html                           landing con inventario
  portal/cobol-java/{SIS}_{PROG}.html              detalle por componente

Uso:  PYTHONUTF8=1 python generators/build-cobol-java.py
"""
from __future__ import annotations
import html
import json
import re
import sqlite3
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
KB = BASE / "knowledge-base" / "transpilacion"
OUT = BASE / "portal"
DET = OUT / "cobol-java"
DB = BASE / "digital-brain" / "brain.db"

ARQ = {
    "A1": ("Concentrador", "#6CC5D8"), "A2": ("Validador-Actualizador", "#28a745"),
    "A3": ("Reporteador", "#bd93f9"), "A4": ("Intercambiador", "#ffb86c"),
    "A5": ("Orquestador de Flujos", "#ff79c6"), "A6": ("Distribuidor Geográfico", "#50fa7b"),
    "L": ("Librería / Módulo", "#9fb8c0"),
}
TIPO = {"program": "Programa", "library": "Librería", "module": "Módulo", "wfl": "WFL"}
CHATBOT = "https://d39amrbevv1r5f.cloudfront.net/chatbot"
NAV_LINKS = [("index.html", "Inicio"), ("modelo-capacidades.html", "Capacidades"),
             ("cap-relationships.html", "Relaciones"), ("arq-tobe.html", "Arquitectura TO-BE"),
             ("cobol-java.html", "COBOL → Java")]
E = html.escape


# ── resaltado de sintaxis ───────────────────────────────────────────────────
COBOL_KW = set("""ACCEPT ADD AFTER ALL ALSO AND ASCENDING ASSIGN AT BEFORE BY CALL CANCEL CLOSE COMP COMP-3 COMP-5
COMPUTE CONTINUE COPY CORRESPONDING DATA DELETE DESCENDING DISPLAY DIVIDE DIVISION ELSE END END-CALL END-COMPUTE
END-EVALUATE END-IF END-PERFORM END-READ END-SEARCH END-WRITE ENVIRONMENT EVALUATE EXIT FD FILE FILLER FIND FOR
FROM GIVING GO GOBACK IF IN INITIALIZE INPUT INTO INVALID IS KEY LINKAGE LOCK MOVE MULTIPLY NEXT NOT OCCURS OF
OPEN OR OTHER OUTPUT PERFORM PIC PICTURE PROCEDURE PROGRAM-ID READ RECORD REDEFINES RELEASE REMAINDER REPLACING
RETURN REWRITE ROUNDED RUN SEARCH SECTION SELECT SET SORT STOP STORE STRING SUBTRACT THEN THROUGH THRU TIMES TO
UNSTRING UNTIL USAGE USING VALUE VALUES VARYING WHEN WITH WORKING-STORAGE WRITE ZERO ZEROS ZEROES SPACE SPACES
TRUE FALSE BEGIN-TRANSACTION END-TRANSACTION LOCK CREATE MODIFY FREE ON EXCEPTION OVERFLOW SIZE ERROR EOF""".split())
ALGOL_KW = set("""BEGIN END IF THEN ELSE DO WHILE FOR STEP UNTIL CASE OF GO TO PROCEDURE DEFINE REAL INTEGER BOOLEAN
ARRAY FILE LIBRARY EXPORT IMPORT OWN VALUE EBCDIC ASCII POINTER REPLACE BY SCAN WRITE READ OPEN CLOSE TRUE FALSE
AND OR NOT LABEL STRING TASK CALL RETURN FORWARD EXTERNAL ENTRY RESIZE DIV MOD""".split())
WFL_KW = set("""BEGIN END JOB RUN IF THEN ELSE TASK VALUE DISPLAY INITIATE PROCESS WAIT ABORT STOP CASE OF DO WHILE
SUBROUTINE CALL STRING INTEGER BOOLEAN REAL FILE COPY REMOVE TITLE KIND NOT AND OR TO FROM ON SET TRUE FALSE
SYSTEMSTATUS STATUS FAMILY USER PRIORITY OPTION""".split())
JAVA_KW = set("""abstract assert boolean break byte case catch char class const continue default do double else enum
extends final finally float for if implements import instanceof int interface long native new package private
protected public return short static strictfp super switch synchronized this throw throws transient try void
volatile while var record sealed permits yield non-sealed null true false""".split())

RX_TOKEN = re.compile(r'("[^"\n]*"|\'[^\'\n]*\'|\b\d+(?:\.\d+)?\b|[A-Za-z_@][A-Za-z0-9_\-]*|\S)')


def _hl_words(line: str, kws: set, java: bool) -> str:
    out, pos = [], 0
    for m in RX_TOKEN.finditer(line):
        out.append(E(line[pos:m.start()]))
        t = m.group(0)
        if t[0] in "\"'":
            out.append('<span class="str">%s</span>' % E(t))
        elif t[0].isdigit():
            out.append('<span class="num">%s</span>' % E(t))
        elif java and t.startswith("@"):
            out.append('<span class="ann">%s</span>' % E(t))
        elif (t in kws) or (not java and t.upper() in kws and t.isupper()):
            out.append('<span class="kw">%s</span>' % E(t))
        elif java and t[:1].isupper() and not t.isupper():
            out.append('<span class="type">%s</span>' % E(t))
        elif not java and ("-" in t or t.isupper()) and len(t) > 2:
            out.append('<span class="var">%s</span>' % E(t))
        else:
            out.append(E(t))
        pos = m.end()
    out.append(E(line[pos:]))
    return "".join(out)


def hl_origen(code: str, lang: str) -> str:
    lang = (lang or "").upper()
    kws = ALGOL_KW if lang.startswith("ALGOL") or lang == "DASDL" else WFL_KW if lang == "WFL" else COBOL_KW
    res = []
    for line in code.split("\n"):
        s = line.lstrip()
        if (lang.startswith("COBOL") and line[:1] in "*/") or s.startswith("*>") or s.startswith("%"):
            res.append('<span class="cmt">%s</span>' % E(line))
            continue
        cut = line.find("%") if not lang.startswith("COBOL") else -1
        if cut > 0:
            res.append(_hl_words(line[:cut], kws, False) + '<span class="cmt">%s</span>' % E(line[cut:]))
        else:
            res.append(_hl_words(line, kws, False))
    return "\n".join(res)


def hl_java(code: str) -> str:
    res, in_block = [], False
    for line in code.split("\n"):
        if in_block or line.lstrip().startswith("/*"):
            res.append('<span class="cmt">%s</span>' % E(line))
            in_block = "*/" not in line
            continue
        i = line.find("//")
        if i >= 0 and line[:i].count('"') % 2 == 0:
            res.append(_hl_words(line[:i], JAVA_KW, True) + '<span class="cmt">%s</span>' % E(line[i:]))
        else:
            res.append(_hl_words(line, JAVA_KW, True))
    return "\n".join(res)


SAFE_TAGS = re.compile(r"&lt;(/?)(b|code|br|i|em|strong)\s*/?&gt;")


def safe_html(s: str) -> str:
    return SAFE_TAGS.sub(lambda m: "<%s%s>" % (m.group(1), m.group(2)), E(s or "", quote=False))


# ── verificación contra fuente ─────────────────────────────────────────────
_src_cache: dict[str, list[str]] = {}


def src_lines(rel: str | None) -> list[str]:
    """Líneas lógicas del fuente: se separa sólo por LF (los S500 traen CR CR LF)."""
    if not rel:
        return []
    if rel not in _src_cache:
        p = BASE / rel
        _src_cache[rel] = ([l.rstrip("\r") for l in p.read_bytes().decode("latin-1").split("\n")]
                           if p.exists() else [])
    return _src_cache[rel]


def norm(line: str, strip_seq: bool) -> str:
    if strip_seq and re.match(r"^\d{6}", line):
        line = line[6:]
    return re.sub(r"\s+", " ", line).strip()


MAX_SPAN = 800   # un extracto no puede abarcar más de N líneas del fuente


def locate(seg: dict, rel: str | None, lang: str):
    """→ (score, linea_ini, linea_fin, gaps) buscando el bloque, en orden, dentro del fuente.

    Acepta extractos: las líneas deben aparecer en el mismo orden dentro de un tramo de
    MAX_SPAN líneas; gaps[i] = líneas no vacías del fuente omitidas antes de la línea i
    del bloque. El rango devuelto es el real del fuente, no el declarado por el agente.
    """
    lines = src_lines(rel)
    want = [norm(l, False) for l in (seg.get("origen_codigo") or "").split("\n") if l.strip()]
    if not lines or not want:
        return None, seg.get("linea_ini"), seg.get("linea_fin"), []
    strip = (lang or "").upper().startswith("COBOL")
    src = [(i + 1, norm(l, strip), norm(l, False)) for i, l in enumerate(lines) if norm(l, strip)]
    hint = int(seg.get("linea_ini") or 0)
    best = (0, -10 ** 9, -10 ** 9, None, None, [])
    for k, (ln, a, b) in enumerate(src):
        if want[0] not in (a, b):
            continue
        hit, j, last, prev, gaps = 1, k + 1, ln, k, [0]
        for w in want[1:]:
            m = j
            while m < len(src) and src[m][0] - ln <= MAX_SPAN and w not in (src[m][1], src[m][2]):
                m += 1
            if m < len(src) and src[m][0] - ln <= MAX_SPAN:
                gaps.append(m - prev - 1)
                hit, last, prev, j = hit + 1, src[m][0], m, m + 1
            else:
                gaps.append(0)
        dist = min(abs(ln - hint), abs(ln - hint // 2)) if hint else 0
        key = (hit, -(last - ln), -dist)
        if key > best[:3]:
            best = (hit, -(last - ln), -dist, ln, last, gaps)
    if best[3] is not None and best[0] / len(want) >= 0.95:
        return best[0] / len(want), best[3], best[4], best[5]
    # extracto compuesto: tramos de zonas distintas del fuente; gap < 0 = salto a la línea -gap
    pos_of = {}
    for m, (ln, a, b) in enumerate(src):
        pos_of.setdefault(a, []).append(m)
        if b != a:
            pos_of.setdefault(b, []).append(m)
    cur, gaps, hit, first, last = None, [], 0, None, None
    for w in want:
        cands = pos_of.get(w, [])
        nxt = [m for m in cands if cur is not None and m > cur and src[m][0] - src[cur][0] <= MAX_SPAN]
        if nxt:
            m = nxt[0]
            gaps.append(m - cur - 1)
        elif cands:
            m = min(cands, key=lambda c: abs(c - (cur or 0)))
            gaps.append(-src[m][0] if cur is not None else 0)
        else:
            gaps.append(0)
            continue
        hit, cur, last = hit + 1, m, src[m][0]
        first = first or src[m][0]
    if not hit:
        return 0.0, seg.get("linea_ini"), seg.get("linea_fin"), []
    return hit / len(want), first, last, gaps


def verify(seg: dict, rel: str | None, lang: str) -> float | None:
    return locate(seg, rel, lang)[0]


def with_gaps(code: str, gaps: list, lang: str) -> str:
    """Inserta un marcador visible donde el extracto omite líneas del fuente."""
    out = []
    pre = "      *> " if (lang or "").upper().startswith("COBOL") else "  % "
    for i, l in enumerate([l for l in code.split("\n") if l.strip()]):
        g = gaps[i] if i < len(gaps) else 0
        if g > 0:
            out.append(pre + "⋯ %d línea%s omitida%s" % (g, "s" if g > 1 else "", "s" if g > 1 else ""))
        elif g < 0:
            out.append(pre + "⋯ continúa en la línea %d" % -g)
        out.append(l)
    return "\n".join(out)


# ── piezas compartidas ─────────────────────────────────────────────────────
def nav(prefix: str, title: str) -> str:
    jumps = "".join('<a class="jump%s" href="%s%s">%s</a>' % (" cur" if h == "cobol-java.html" else "", prefix, h, l)
                    for h, l in NAV_LINKS)
    return ('<nav class="dbnav">\n  <a class="nlogo" href="%sindex.html"><img src="%sassets/logos/banamex.png" alt="Banamex"></a>\n'
            '  <span class="nt">Enterprise Digital Brain · %s</span><span class="sp"></span>\n  %s\n'
            '  <a class="chat-link" href="%s" target="_blank" rel="noopener noreferrer">💬 Chat Enterprise Digital Brain</a>\n'
            '</nav>') % (prefix, prefix, E(title), jumps, CHATBOT)


CSS = (Path(__file__).resolve().parent / "templates" / "cobol_java.css")


def page(title: str, prefix: str, nav_title: str, body: str, extra_js: str = "") -> str:
    return ("<!DOCTYPE html><html lang=\"es\"><head><meta charset=\"UTF-8\">\n"
            "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\">\n"
            "<title>%s · Enterprise Digital Brain · Banamex</title>\n<style>\n%s\n</style>\n</head>\n<body>\n"
            "<div class=\"aurora\"><div class=\"blob\"></div></div>\n%s\n%s\n"
            "<footer>Enterprise Digital Brain · Banamex · Transpilación asistida por IA con revisión humana obligatoria · "
            "Accenture México · High Velocity Modernization</footer>\n%s</body></html>\n"
            % (E(title), CSS.read_text(encoding="utf-8"), nav(prefix, nav_title), body, extra_js))


# ── detalle ────────────────────────────────────────────────────────────────
def build_detail(item: dict, data: dict, rules_desc: dict, prev_next) -> tuple[str, dict]:
    lang = data.get("lenguaje_origen") or "COBOL85"
    rel = item.get("fuente")
    arq = ARQ.get(data.get("arquetipo") or item.get("arquetipo"), ARQ["L"])
    mappings, secs_html, n_seg, n_ok, used_rules = {}, [], 0, 0, {}
    for si, sec in enumerate(data.get("secciones") or [], 1):
        o_parts, j_parts = [], []
        for seg in sec.get("segmentos") or []:
            sid = seg.get("id") or "s%d" % (n_seg + 1)
            jid = "j" + sid[1:]
            n_seg += 1
            score, l_ini, l_fin, gaps = locate(seg, rel, lang)
            ok = score is not None and score >= 0.95
            n_ok += ok
            vcls = "" if ok else (" unverified" if score is not None else " nosrc")
            lines = "L%s–%s" % (l_ini or "?", l_fin or "?")
            shown = with_gaps(seg.get("origen_codigo", ""), gaps, lang) if ok else seg.get("origen_codigo", "")
            o_parts.append('<span class="seg%s" data-cid="%s" data-jid="%s" title="%s · %s">%s</span>'
                           % (vcls, sid, jid, E(seg.get("titulo", "")), lines, hl_origen(shown, lang)))
            j_parts.append('<span class="seg java-seg" data-jid="%s">%s</span>' % (jid, hl_java(seg.get("java_codigo", ""))))
            rules = [r for r in seg.get("reglas") or [] if r in rules_desc]
            for r in rules:
                used_rules.setdefault(r, []).append(seg.get("titulo", ""))
            mappings[sid] = {"title": seg.get("titulo", ""), "cobol": shown,
                             "java": seg.get("java_codigo", ""), "rationale": safe_html(seg.get("racional", "")),
                             "risk": safe_html(seg.get("riesgo", "")), "rules": rules, "lines": lines,
                             "verified": ok, "score": None if score is None else round(score * 100)}
        o, j = sec.get("origen") or {}, sec.get("java") or {}
        secs_html.append(
            '<div class="sec-hdr">%d · %s</div>\n<div class="split">\n'
            '<div class="pane"><div class="pane-hdr ch"><div class="dots"><div class="dot dr"></div><div class="dot dy"></div><div class="dot dg"></div></div>'
            '<span>%s</span><span class="fname">%s</span><span class="lang-label ll-c">%s</span></div><pre>%s</pre></div>\n'
            '<div class="pane"><div class="pane-hdr jh"><div class="dots"><div class="dot dr"></div><div class="dot dy"></div><div class="dot dg"></div></div>'
            '<span>%s</span><span class="fname">%s</span><span class="lang-label ll-j">Java 21</span></div><pre>%s</pre></div>\n</div>'
            % (si, E(sec.get("titulo", "")), E(o.get("archivo", "")), E(o.get("contexto", "")), E(lang),
               "\n".join(o_parts), E(j.get("archivo", "")), E(j.get("contexto", "")), "\n".join(j_parts)))

    rules_rows = "".join('<tr><td>%s</td><td>%s</td><td>%s</td></tr>' % (E(r), E(rules_desc.get(r, "")), E(" · ".join(dict.fromkeys(t))))
                         for r, t in sorted(used_rules.items()))
    risks = "".join('<div class="risk"><b>%s</b><p>%s</p></div>' % (E(r.get("titulo", "")), safe_html(r.get("detalle", "")))
                    for r in data.get("riesgos") or [])
    pend = "".join("<li>%s</li>" % safe_html(p) for p in data.get("pendientes_revision") or [])
    vtxt = "%d de %d segmentos verificados contra el fuente" % (n_ok, n_seg)
    prev, nxt = prev_next
    pn = '<div class="pn">%s<a href="../cobol-java.html">Inventario</a>%s</div>' % (
        '<a href="%s.html">← %s</a>' % (prev, E(prev.replace("_", " · "))) if prev else "<span></span>",
        '<a href="%s.html">%s →</a>' % (nxt, E(nxt.replace("_", " · "))) if nxt else "<span></span>")
    body = """
<div id="scrim" onclick="closePopup()"></div>
<div id="popup"><div id="popup-hdr"><span class="from-badge">%(lang)s</span><span class="arrow">→</span><span class="to-badge">Java 21</span>
<span id="popup-title"></span><button id="popup-close" onclick="closePopup()">×</button></div>
<div id="popup-body">
<div class="pp-section"><div class="pp-label">Código original <span id="pp-lines"></span></div><div class="pp-code pc" id="pp-cobol"></div></div>
<div class="pp-section"><div class="pp-label">Equivalente Java 21 · Spring Boot 3</div><div class="pp-code pj" id="pp-java"></div></div>
<div class="pp-section"><div class="pp-label">Racional de equivalencia</div><div class="pp-rationale" id="pp-rat"></div></div>
<div class="pp-section" id="pp-risk-sec"><div class="pp-label">Riesgo de migración</div><div class="pp-rationale" id="pp-risk"></div></div>
<div class="pp-section"><div class="pp-label">Reglas de negocio trazadas</div><div class="pp-rules" id="pp-rules"></div></div>
</div></div>
<div class="hero">
  <div class="eyebrow">Enterprise Digital Brain · COBOL → Java · %(arqname)s</div>
  <h1><span class="cw">%(sis)s · %(prog)s</span> a <span class="jw">Java 21 Spring Boot</span></h1>
  <p class="sub">%(resumen)s</p>
  <div class="hint">Haz clic en cualquier bloque de código original para ver su equivalencia en Java y el racional de la traducción</div>
</div>
<div class="wrap">
  %(pn)s
  <div class="ctx">
    <div class="ctx-chip"><div class="cl">Programa</div><div class="cv">%(sis)s · %(prog)s · %(lang)s</div></div>
    <div class="ctx-chip"><div class="cl">Tamaño fuente</div><div class="cv">%(loc)s</div></div>
    <div class="ctx-chip"><div class="cl">Función</div><div class="cv">%(funcion)s</div></div>
    <div class="ctx-chip"><div class="cl">Arquetipo</div><div class="cv" style="color:%(arqcol)s">%(arqname)s</div></div>
    <div class="ctx-chip"><div class="cl">Reglas vinculadas</div><div class="cv">%(nrules)d de %(nbrain)d del brain</div></div>
    <div class="ctx-chip"><div class="cl">Target</div><div class="cv">%(target)s</div></div>
  </div>
  %(secs)s
  %(rules)s
  %(risks)s
  %(pend)s
  %(pn)s
</div>
""" % {"lang": E(lang), "arqname": E(arq[0]), "arqcol": arq[1], "sis": E(item["sistema"]), "prog": E(item["programa"]),
       "resumen": safe_html(data.get("resumen", item.get("descripcion", ""))), "estado": E(data.get("estado", "BORRADOR IA · pendiente revisión SME")),
       "vtxt": vtxt, "pn": pn, "loc": ("{:,} LOC".format(item["loc"]) if item.get("loc") else "Sin fuente"),
       "funcion": E(data.get("funcion", "")), "nrules": len(used_rules), "nbrain": len(item.get("reglas_brain") or []),
       "target": E(data.get("target", "Java 21 · Spring Boot 3")), "secs": "\n".join(secs_html),
       "rules": ('<div class="sec-hdr">Reglas de negocio trazadas</div><table class="rules-table"><thead><tr><th>ID regla</th>'
                 '<th>Descripción (brain)</th><th>Segmento</th></tr></thead><tbody>%s</tbody></table>' % rules_rows) if rules_rows else "",
       "risks": ('<div class="sec-hdr">Riesgos de migración</div><div class="risks">%s</div>' % risks) if risks else "",
       "pend": ('<div class="sec-hdr">Pendiente de revisión SME</div><ul class="pend">%s</ul>' % pend) if pend else ""}
    js = "<script>\nconst MAPPINGS = %s;\n%s</script>\n" % (json.dumps(mappings, ensure_ascii=False), DETAIL_JS)
    html_out = page("%s · %s → Java" % (item["sistema"], item["programa"]), "../",
                    "COBOL → Java · %s %s" % (item["sistema"], item["programa"]), body, js)
    return html_out, {"segmentos": n_seg, "verificados": n_ok, "reglas": len(used_rules), "secciones": len(data.get("secciones") or [])}


DETAIL_JS = r"""
let active = null;
function openPopup(cid){
  const m = MAPPINGS[cid]; if(!m) return;
  document.querySelectorAll('.seg.active-cobol,.seg.active-java').forEach(e=>e.classList.remove('active-cobol','active-java'));
  const c = document.querySelector(`.seg[data-cid="${cid}"]`); if(c) c.classList.add('active-cobol');
  const j = c && document.querySelector(`.java-seg[data-jid="${c.dataset.jid}"]`);
  if(j){ j.classList.add('active-java'); j.scrollIntoView({block:'nearest',behavior:'smooth'}); }
  document.getElementById('popup-title').textContent = m.title;
  document.getElementById('pp-lines').textContent = '· ' + m.lines + (m.verified ? ' · verificado contra fuente' : (m.score===null ? ' · sin fuente para verificar' : ' · NO coincide con el fuente (' + m.score + '%)'));
  document.getElementById('pp-cobol').textContent = m.cobol;
  document.getElementById('pp-java').textContent = m.java;
  document.getElementById('pp-rat').innerHTML = m.rationale;
  document.getElementById('pp-risk').innerHTML = m.risk;
  document.getElementById('pp-risk-sec').style.display = m.risk ? '' : 'none';
  document.getElementById('pp-rules').innerHTML = m.rules.length
    ? m.rules.map(r=>`<span class="pp-rule-tag">${r}</span>`).join('')
    : '<span style="font-size:12px;color:var(--muted2)">Sin regla de negocio específica: decisión de arquitectura de la traducción</span>';
  document.getElementById('popup').style.display='block';
  document.getElementById('scrim').style.display='block';
  active = cid;
}
function closePopup(){
  document.getElementById('popup').style.display='none';
  document.getElementById('scrim').style.display='none';
  document.querySelectorAll('.seg.active-cobol,.seg.active-java').forEach(e=>e.classList.remove('active-cobol','active-java'));
  active = null;
}
document.querySelectorAll('.seg[data-cid]').forEach(el=>{
  el.addEventListener('click',()=>openPopup(el.dataset.cid));
  el.addEventListener('mouseenter',()=>document.querySelector(`.java-seg[data-jid="${el.dataset.jid}"]`)?.classList.add('peer-java'));
  el.addEventListener('mouseleave',()=>document.querySelector(`.java-seg[data-jid="${el.dataset.jid}"]`)?.classList.remove('peer-java'));
});
document.querySelectorAll('.java-seg[data-jid]').forEach(el=>{
  const peer = ()=>document.querySelector(`.seg[data-jid="${el.dataset.jid}"]:not(.java-seg)`);
  el.addEventListener('mouseenter',()=>peer()?.classList.add('peer-cobol'));
  el.addEventListener('mouseleave',()=>peer()?.classList.remove('peer-cobol'));
  el.addEventListener('click',()=>{ const p = peer(); if(p) openPopup(p.dataset.cid); });
});
document.addEventListener('keydown',e=>{ if(e.key==='Escape') closePopup(); });
"""


# ── landing ────────────────────────────────────────────────────────────────
def build_landing(inv: list, stats: dict) -> str:
    rows = []
    for it in inv:
        st = stats.get(it["slug"])
        rows.append({"s": it["sistema"], "p": it["programa"], "t": TIPO.get(it.get("tipo"), it.get("tipo") or ""),
                     "a": it.get("arquetipo") or "L", "d": re.sub(r"`", "", it.get("descripcion") or ""),
                     "loc": it.get("loc") or 0, "nr": len(it.get("reglas_brain") or []),
                     "href": ("cobol-java/%s.html" % it["slug"]) if st else None,
                     "seg": st["segmentos"] if st else 0, "ver": st["verificados"] if st else 0})
    done = sum(1 for r in rows if r["href"])
    segs = sum(r["seg"] for r in rows)
    ver = sum(r["ver"] for r in rows)
    chips = "".join('<button class="fchip" data-a="%s" style="--c:%s"><b>%s</b> %s <span>%d</span></button>'
                    % (k, c, k, E(n), sum(1 for r in rows if r["a"] == k)) for k, (n, c) in ARQ.items())
    body = """
<div class="hero">
  <div class="eyebrow">Enterprise Digital Brain · Transpilación asistida por IA</div>
  <h1>De <span class="cw">COBOL Unisys</span> a <span class="jw">Java 21 Spring Boot</span></h1>
  <p class="sub">Cada componente de S500 y S151 tiene una página donde el código original y su equivalente en Java aparecen lado a lado. Cada bloque explica por qué se tradujo así y qué reglas de negocio del brain implementa. El código original se verifica línea por línea contra el fuente, y todo el Java es un borrador que requiere revisión de un SME antes de usarse.</p>
</div>
<div class="wrap">
  <div class="kpis">
    <div class="kpi"><div class="kn">%(total)d</div><div class="kl">Componentes S500 y S151</div></div>
    <div class="kpi"><div class="kn">%(done)d</div><div class="kl">Con transpilación demostrativa</div></div>
    <div class="kpi"><div class="kn">%(segs)s</div><div class="kl">Segmentos COBOL ↔ Java</div></div>
    <div class="kpi"><div class="kn">%(pct)s</div><div class="kl">Segmentos verificados contra fuente</div></div>
  </div>
  <div class="sec-hdr">Inventario por arquetipo</div>
  <div class="filters">
    <div class="fgroup"><button class="fsys on" data-s="">Todos</button><button class="fsys" data-s="S500">S500</button><button class="fsys" data-s="S151">S151</button></div>
    <div class="fgroup">%(chips)s</div>
    <input id="q" type="search" placeholder="Buscar programa o descripción">
    <label class="only"><input type="checkbox" id="onlydone"> Solo con transpilación</label>
  </div>
  <table class="inv"><thead><tr><th data-k="p">Componente</th><th data-k="s">Sistema</th><th data-k="t">Tipo</th><th data-k="a">Arquetipo</th>
  <th data-k="d">Descripción</th><th data-k="loc" class="r">LOC</th><th data-k="nr" class="r">Reglas</th><th data-k="seg" class="r">Segmentos</th></tr></thead>
  <tbody id="tb"></tbody></table>
  <div id="cnt" class="cnt"></div>
</div>
""" % {"total": len(rows), "done": done, "segs": "{:,}".format(segs), "pct": ("%d%%" % round(ver * 100 / segs)) if segs else "—",
       "chips": chips}
    js = "<script>\nconst INV = %s;\nconst ARQ = %s;\n%s</script>\n" % (
        json.dumps(rows, ensure_ascii=False), json.dumps({k: list(v) for k, v in ARQ.items()}, ensure_ascii=False), LANDING_JS)
    return page("COBOL → Java Spring Boot", "", "COBOL → Java Spring Boot", body, js)


LANDING_JS = r"""
const st = {s:'', a:'', q:'', only:false, k:'p', dir:1};
const esc = s => String(s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
function render(){
  const q = st.q.toLowerCase();
  let r = INV.filter(x => (!st.s || x.s===st.s) && (!st.a || x.a===st.a) && (!st.only || x.href)
                       && (!q || x.p.toLowerCase().includes(q) || x.d.toLowerCase().includes(q)));
  r.sort((a,b) => (a[st.k] > b[st.k] ? 1 : a[st.k] < b[st.k] ? -1 : 0) * st.dir);
  document.getElementById('tb').innerHTML = r.map(x => {
    const [n,c] = ARQ[x.a] || ARQ.L;
    const name = x.href ? `<a href="${x.href}">${esc(x.p)}</a>` : `<span class="pend">${esc(x.p)}</span>`;
    const seg = x.href ? `${x.seg}${x.ver===x.seg ? '' : ` <span class="warn" title="${x.seg-x.ver} sin verificar">·${x.seg-x.ver}</span>`}` : '<span class="pend">pendiente</span>';
    return `<tr class="${x.href?'go':''}" ${x.href?`onclick="location.href='${x.href}'"`:''}><td class="pc">${name}</td><td>${x.s}</td><td>${esc(x.t)}</td>`+
      `<td><span class="abadge" style="--c:${c}">${x.a} · ${esc(n)}</span></td><td class="dsc">${esc(x.d)}</td>`+
      `<td class="r">${x.loc ? x.loc.toLocaleString('es-MX') : '—'}</td><td class="r">${x.nr}</td><td class="r">${seg}</td></tr>`;
  }).join('');
  document.getElementById('cnt').textContent = `${r.length} de ${INV.length} componentes`;
}
document.querySelectorAll('.fsys').forEach(b => b.onclick = () => {
  document.querySelectorAll('.fsys').forEach(x => x.classList.remove('on')); b.classList.add('on'); st.s = b.dataset.s; render(); });
document.querySelectorAll('.fchip').forEach(b => b.onclick = () => {
  const on = !b.classList.contains('on'); document.querySelectorAll('.fchip').forEach(x => x.classList.remove('on'));
  if (on) b.classList.add('on'); st.a = on ? b.dataset.a : ''; render(); });
document.getElementById('q').oninput = e => { st.q = e.target.value; render(); };
document.getElementById('onlydone').onchange = e => { st.only = e.target.checked; render(); };
document.querySelectorAll('th[data-k]').forEach(th => th.onclick = () => {
  st.dir = st.k === th.dataset.k ? -st.dir : 1; st.k = th.dataset.k; render(); });
render();
"""


def main():
    inv = json.loads((KB / "_inventario.json").read_text(encoding="utf-8"))
    con = sqlite3.connect("file:%s?mode=ro" % DB.as_posix(), uri=True)
    rules_desc = {r[0]: (r[1] or r[2] or "") for r in con.execute("SELECT rule_id, descripcion, nombre FROM rules")}
    con.close()
    DET.mkdir(parents=True, exist_ok=True)
    done = [it for it in inv if (KB / ("%s.json" % it["slug"])).exists()]
    slugs = [it["slug"] for it in done]
    stats, problems = {}, []
    for i, it in enumerate(done):
        try:
            data = json.loads((KB / ("%s.json" % it["slug"])).read_text(encoding="utf-8-sig"))
        except Exception as e:
            problems.append("%s: JSON inválido (%s)" % (it["slug"], e))
            continue
        bad_rules = [r for s in data.get("secciones") or [] for g in s.get("segmentos") or [] for r in g.get("reglas") or []
                     if r not in (it.get("reglas_brain") or [])]
        if bad_rules:
            problems.append("%s: reglas fuera del brain del programa %s" % (it["slug"], sorted(set(bad_rules))))
        pn = (slugs[i - 1] if i else None, slugs[i + 1] if i + 1 < len(slugs) else None)
        out, st = build_detail(it, data, rules_desc, pn)
        (DET / ("%s.html" % it["slug"])).write_text(out, encoding="utf-8")
        stats[it["slug"]] = st
        if st["verificados"] < st["segmentos"]:
            problems.append("%s: %d de %d segmentos no coinciden con el fuente" % (it["slug"], st["segmentos"] - st["verificados"], st["segmentos"]))
    (OUT / "cobol-java.html").write_text(build_landing(inv, stats), encoding="utf-8")
    tot = sum(s["segmentos"] for s in stats.values())
    print("detalle: %d páginas · segmentos %d · verificados %d" % (len(stats), tot, sum(s["verificados"] for s in stats.values())))
    for p in problems:
        print("  ⚠", p)


def check(slugs):
    """Valida JSON contra fuente y brain sin escribir nada."""
    inv = {x["slug"]: x for x in json.loads((KB / "_inventario.json").read_text(encoding="utf-8"))}
    for slug in slugs:
        it = inv.get(slug)
        f = KB / ("%s.json" % slug)
        if not it or not f.exists():
            print("%s: no existe en inventario o falta el JSON" % slug); continue
        try:
            data = json.loads(f.read_text(encoding="utf-8-sig"))
        except Exception as e:
            print("%s: JSON inválido: %s" % (slug, e)); continue
        lang = data.get("lenguaje_origen") or "COBOL85"
        segs = [g for s in data.get("secciones") or [] for g in s.get("segmentos") or []]
        bad = []
        for g in segs:
            sc = verify(g, it.get("fuente"), lang)
            if sc is None or sc < 0.95:
                bad.append("%s (%s)" % (g.get("id"), "sin fuente" if sc is None else "%d%%" % round(sc * 100)))
        rules = [r for g in segs for r in g.get("reglas") or [] if r not in (it.get("reglas_brain") or [])]
        ids = [g.get("id") for g in segs]
        print("%s: %d secciones · %d segmentos · no verificados: %s · reglas inválidas: %s · ids duplicados: %s"
              % (slug, len(data.get("secciones") or []), len(segs), bad or "ninguno", sorted(set(rules)) or "ninguna",
                 sorted({i for i in ids if ids.count(i) > 1}) or "ninguno"))


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    if len(sys.argv) > 2 and sys.argv[1] == "--check":
        check(sys.argv[2:])
    else:
        main()
