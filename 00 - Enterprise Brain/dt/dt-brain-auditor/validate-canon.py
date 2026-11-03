#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
validate-canon.py — Valida el ASSET Enterprise Brain contra sí mismo.

`validate.py` valida un brain.db contra el canon.
Este script valida el canon contra la realidad: que lo que los documentos
afirman sea cierto, y que las cifras coincidan entre ellos.

Existe porque el QA del 2026-10-05 encontró que el defecto recurrente del asset
no era el contenido sino la PROPAGACIÓN: nada comprobaba que un cambio del canon
llegara a sus dependientes, y nada comprobaba que una afirmación de "verificado"
fuera cierta. Seis instancias del mismo patrón, más una remediación que afirmó
invariantes globales comprobando casos particulares.

Regla de diseño: **toda comprobación debe poder fallar.** Una verificación que
no puede dar negativo no verifica nada. Si agregas un check, escribe primero el
caso que lo hace fallar.

Uso:
    python validate-canon.py                 # reporte completo
    python validate-canon.py --summary       # una línea por dimensión
    python validate-canon.py --dim sql       # una sola dimensión
    python validate-canon.py --json

Exit: 0 PASS · 1 hallazgos bloqueantes · 2 error de ejecución
"""
from __future__ import annotations

import argparse
import json
import re
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

ASSET = Path(__file__).resolve().parents[2]
SCHEMA = ASSET / "templates" / "schema.sql"

# Nombres que el canon retiró. Aparecer en un contexto ejecutable es defecto.
# (tabla_o_columna, qué es hoy, ADR o regla que lo retiró)
RETIRADOS = [
    ("souls",            "components.is_soul",        "ADR-EB-006"),
    ("etb_l3",           "capabilities",              "ADR-EB-006"),
    ("primary_l3",       "components.primary_capability", "ADR-EB-006"),
    ("etb_primary_l3",   "components.primary_capability", "ADR-EB-006"),
    ("entry_sp",         "journeys.entry_component",  "canon v2.0"),
    ("sp_count",         "journeys.component_count",  "canon v2.0"),
    ("related_terms",    "vocabulary.aliases",        "canon v2.0"),
    ("capability_version", "ontology_bindings.catalog_version", "canon v2.0"),
]

# Cifras que DEBEN coincidir en todo documento que las mencione.
# clave -> (regex que la captura, valor correcto, cómo se deriva)
CIFRAS = {
    "core_tables":  (r"CORE[^.\n]{0,40}?(\d{1,2})\s+tablas|(\d{1,2})\s+tablas del CORE", None, "schema.sql"),
    "dimensiones":  (r"(\d{1,2})\s+dimensiones", 9, "validate.py DIMENSIONS"),
    "reglas_b":     (r"(\d{1,3})\s+reglas", None, "brain-rules.md"),
    "dts":          (r"(\d{1,2})\s+DTs? canónicos", None, "carpetas dt/dt-*"),
}

SEV_BLOQ = "BLOQUEANTE"

# ── Cifras escritas con letra ────────────────────────────────────────────────
# Una cifra en letra se queda vieja igual que una en dígitos, y miente igual.
# El validador solo miraba dígitos, y por eso el deck del asset pudo seguir
# diciendo "nueve dimensiones" después de que fueran diez, sin que nada lo
# detectara. El punto ciego valía más que el archivo.

def _palabras_hasta_99() -> dict:
    u = ["cero", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete",
         "ocho", "nueve"]
    especiales = {
        10: "diez", 11: "once", 12: "doce", 13: "trece", 14: "catorce",
        15: "quince", 16: "dieciséis", 17: "diecisiete", 18: "dieciocho",
        19: "diecinueve", 20: "veinte", 21: "veintiuno", 22: "veintidós",
        23: "veintitrés", 24: "veinticuatro", 25: "veinticinco",
        26: "veintiséis", 27: "veintisiete", 28: "veintiocho",
        29: "veintinueve",
    }
    decenas = {30: "treinta", 40: "cuarenta", 50: "cincuenta", 60: "sesenta",
               70: "setenta", 80: "ochenta", 90: "noventa"}
    mapa = {w: n for n, w in enumerate(u)}
    mapa["un"] = 1
    mapa["una"] = 1
    for n, w in especiales.items():
        mapa[w] = n
        # Sin acento también se escribe, y el canon lo hace en algunos sitios.
        mapa[w.replace("é", "e").replace("ó", "o").replace("í", "i")] = n
    for d, w in decenas.items():
        mapa[w] = d
        for k in range(1, 10):
            mapa[f"{w} y {u[k]}"] = d + k
    return mapa


PALABRAS = _palabras_hasta_99()
#: Las más largas primero: sin eso, "treinta" casaría antes que "treinta y
#: cinco" y la cifra leída sería otra.
_ALT = "|".join(re.escape(w) for w in sorted(PALABRAS, key=len, reverse=True))
NUM = rf"(?:\d{{1,3}}|{_ALT})"


def valor(token: str):
    """El número que expresa un token, venga en dígitos o en letra."""
    t = token.strip().lower()
    if t.isdigit():
        return int(t)
    return PALABRAS.get(t)

SEV_AVISO = "aviso"


class Hallazgo:
    def __init__(self, dim, sev, msg, donde=""):
        self.dim, self.sev, self.msg, self.donde = dim, sev, msg, donde

    def __str__(self):
        d = f"  {self.donde}" if self.donde else ""
        return f"[{self.sev}] {self.msg}{d}"

    def as_dict(self):
        return {"dim": self.dim, "sev": self.sev, "msg": self.msg, "donde": self.donde}


class CanonValidator:
    def __init__(self, asset: Path):
        self.asset = asset
        self.h: list[Hallazgo] = []
        self.stats: dict = {}
        self._db = None
        self._esquema = None

    # ── utilidades ────────────────────────────────────────────────────────
    def add(self, dim, sev, msg, donde=""):
        self.h.append(Hallazgo(dim, sev, msg, donde))

    def docs(self, *exts):
        for e in exts:
            for p in sorted(self.asset.rglob(f"*.{e}")):
                # test-canon.py contiene defectos a propósito, como fixtures de
                # la suite de inyección. Escanearlo haría que el validador se
                # denuncie a sí mismo.
                if "__pycache__" in p.parts or p.name == "test-canon.py":
                    continue
                yield p

    def rel(self, p: Path) -> str:
        try:
            return str(p.relative_to(self.asset))
        except ValueError:
            return str(p)

    def esquema(self) -> dict[str, list[str]]:
        """{tabla: [columnas]} desde el DDL canónico. Única fuente de verdad."""
        if self._esquema is None:
            if not SCHEMA.exists():
                raise SystemExit(f"No existe el DDL canónico: {SCHEMA}")
            con = sqlite3.connect(":memory:")
            con.executescript(SCHEMA.read_text(encoding="utf-8"))
            self._db = con
            self._esquema = {
                t[0]: [c[1] for c in con.execute(f"PRAGMA table_info({t[0]})")]
                for t in con.execute(
                    "SELECT name FROM sqlite_master WHERE type IN ('table','view')")
            }
        return self._esquema

    # ── D1 · SQL ejecutable ───────────────────────────────────────────────
    def d1_sql(self):
        """Toda consulta SELECT de todo .md y .py debe ejecutar contra el DDL."""
        self.esquema()
        total = fallan = 0
        for p in self.docs("md", "py"):
            txt = p.read_text(encoding="utf-8", errors="ignore")
            consultas = re.findall(r"`(SELECT\s[^`]+)`", txt)
            consultas += re.findall(r"^\s*(SELECT\s.+?);", txt, re.M | re.S)
            consultas += re.findall(r'"""(SELECT\s.*?)"""', txt, re.S)
            for q in consultas:
                q = q.strip().rstrip(";")
                # Se omiten: plantillas, parámetros nombrados o posicionales, y
                # ejemplos de homologación sobre la tabla histórica de un brain.
                if re.search(r"[{}?]|:\w+|\bFROM\s+(sps|informix\.|unity\.|appmovil\.)", q):
                    continue
                total += 1
                try:
                    self._db.execute(q).fetchall()
                except Exception as e:
                    fallan += 1
                    self.add("sql", SEV_BLOQ,
                             f"SQL no ejecuta: {e}", f"{self.rel(p)} :: {q[:70]}")
        self.stats["sql_total"], self.stats["sql_fallan"] = total, fallan

    # ── D2 · Nombres retirados ────────────────────────────────────────────
    def d2_retirados(self):
        """Un nombre retirado en contexto ejecutable es defecto; en prosa histórica no."""
        esquema = self.esquema()
        for p in self.docs("md", "py", "sql", "html"):
            txt = p.read_text(encoding="utf-8", errors="ignore")
            for nombre, reemplazo, origen in RETIRADOS:
                if nombre in esquema:            # por si vuelve al canon
                    continue
                for m in re.finditer(rf"\b{re.escape(nombre)}\b", txt):
                    ln = txt.count("\n", 0, m.start()) + 1
                    # La nota que declara un término como histórico puede venir antes
                    # o después de la mención; mirar solo hacia atrás dejaba marcados
                    # como defecto a los ADR ya enmendados.
                    ctx = txt[max(0, m.start() - 160):m.start() + 420].replace("\n", " ")
                    # contexto ejecutable: SQL, DDL o acceso a atributo
                    ejecutable = re.search(
                        r"(FROM|JOIN|INTO|UPDATE|CREATE TABLE|SELECT)[^\n]{0,80}$",
                        txt[max(0, m.start() - 90):m.start()], re.I)
                    historico = re.search(
                        r"(retirad|ya no|nunca existi|antes documentad|v1\.0|ENMIENDA|"
                        r"no tiene|inexistent|dejó de|reemplaz)", ctx, re.I)
                    if ejecutable and not historico:
                        self.add("retirados", SEV_BLOQ,
                                 f"'{nombre}' fue retirado por {origen}; hoy es {reemplazo}",
                                 f"{self.rel(p)}:{ln}")

    # ── D3 · Referencias a archivos y ADRs ────────────────────────────────
    def d3_referencias(self):
        adrs_ex = {re.search(r"ADR-EB-(\d{3})", f.name).group(1)
                   for f in (self.asset / "adr").glob("ADR-EB-*.md")}
        citados = defaultdict(list)
        for p in self.docs("md", "py", "sql"):
            txt = p.read_text(encoding="utf-8", errors="ignore")
            for m in re.finditer(r"ADR-EB-(\d{3})", txt):
                citados[m.group(1)].append(self.rel(p))
        for num, donde in sorted(citados.items()):
            if num not in adrs_ex:
                self.add("referencias", SEV_BLOQ,
                         f"ADR-EB-{num} se cita {len(donde)} vez(ces) y no existe",
                         ", ".join(sorted(set(donde))[:3]))

        # rutas internas del asset
        for p in self.docs("md"):
            txt = p.read_text(encoding="utf-8", errors="ignore")
            for m in re.finditer(r"`((?:templates|dt|adr|knowledge-base|portal|source)/[\w\-./]+\.\w+)`", txt):
                if not (self.asset / m.group(1)).exists():
                    ln = txt.count("\n", 0, m.start()) + 1
                    self.add("referencias", SEV_BLOQ,
                             f"ruta inexistente: {m.group(1)}", f"{self.rel(p)}:{ln}")

    # ── D4 · Cifras consistentes ──────────────────────────────────────────
    def d4_cifras(self):
        esquema = self.esquema()
        # CORE real = tablas de la sección CORE del DDL
        ddl = SCHEMA.read_text(encoding="utf-8")
        ini_core = ddl.index("-- CORE")
        fin_core = ddl.index("-- SYSTEM", ini_core)
        core_real = len(re.findall(r"CREATE TABLE IF NOT EXISTS (\w+)",
                                   ddl[ini_core:fin_core]))
        self.stats["core_real"] = core_real

        # dimensiones reales del validador
        vp = (self.asset / "dt" / "dt-brain-auditor" / "validate.py").read_text(encoding="utf-8")
        # Contar elementos, no comas: la coma final produce un vacío que
        # inflaba la cifra en uno. El propio validador falló aquí primero.
        dims_real = len(re.findall(r'"(\w+)"',
                        re.search(r"DIMENSIONS\s*=\s*\[(.*?)\]", vp, re.S).group(1)))
        self.stats["dims_real"] = dims_real

        # DTs reales
        dts_real = len([d for d in (self.asset / "dt").iterdir()
                        if d.is_dir() and d.name.startswith("dt-")])
        self.stats["dts_real"] = dts_real

        # El roster que el auditor exige, contra las carpetas que existen.
        # Es una lista escrita a mano en validate.py y por tanto puede derivar;
        # sin esta comprobación, D10 mediría contra un roster viejo y lo haría
        # en silencio, que es el modo de falla que esta auditoría persigue.
        carpetas = {d.name for d in (self.asset / "dt").iterdir()
                    if d.is_dir() and d.name.startswith("dt-")}
        m_roster = re.search(r"ROSTER_CANONICO\s*=\s*\((.*?)\n\)", vp, re.S)
        if m_roster:
            declarado = set(re.findall(r'"(dt-[a-z-]+)"', m_roster.group(1)))
            faltan = carpetas - declarado
            sobran = declarado - carpetas
            if faltan or sobran:
                self.add("cifras", SEV_BLOQ,
                         "ROSTER_CANONICO no coincide con las carpetas de dt/: "
                         + (f"faltan {sorted(faltan)} " if faltan else "")
                         + (f"sobran {sorted(sobran)}" if sobran else ""),
                         "dt/dt-brain-auditor/validate.py")
        else:
            self.add("cifras", SEV_BLOQ,
                     "validate.py ya no declara ROSTER_CANONICO; D10 no tiene "
                     "contra qué medir B41", "dt/dt-brain-auditor/validate.py")

        # reglas B reales
        br = (self.asset / "canon" / "brain-rules.md").read_text(encoding="utf-8")
        reglas_real = len(set(re.findall(r"^\*\*B(\d+)", br, re.M)))
        self.stats["reglas_real"] = reglas_real

        # DoD y SLO máximos declarados
        dod_real = max(int(x) for x in re.findall(r"DoD-EB-(\d+)",
                       (self.asset / "quality-gates-enterprise-brain.md").read_text(encoding="utf-8")))
        self.stats["dod_real"] = dod_real

        # Cada chequeo captura la cifra en el grupo 1, venga en dígitos o en
        # letra, y se compara por VALOR. Antes se comparaba por texto con una
        # anticipación negativa, y eso solo sabía leer dígitos.
        chequeos = [
            # El CORE se nombra de varias formas y la vieja solo entendía una.
            # "CORE: 18 tablas obligatorias" se quedó tres semanas viejo en el
            # portal sin que el validador lo viera.
            (rf"({NUM})\s+tablas\s+del\s+CORE", core_real, f"CORE son {core_real} tablas"),
            (rf"CORE[^.\n]{{0,25}}?({NUM})\s+tablas", core_real, f"CORE son {core_real} tablas"),
            # "0 dimensiones bloqueantes" cuenta hallazgos; no declara el total.
            # "dos dimensiones" de una matriz 2x2 no son las del auditor. Se
            # exige el ancla: sin ella, el chequeo cosechaba cualquier frase
            # que tuviera la palabra y el validador se volvia ruido.
            (rf"(?:brain.?auditor|validaci|validador)[^.\n]{{0,60}}?({NUM})\s+"
             rf"dimensiones(?!\s+bloqueante)", dims_real,
             f"son {dims_real} dimensiones"),
            (rf"({NUM})\s+dimensiones\s+de\s+validaci", dims_real,
             f"son {dims_real} dimensiones"),
            (rf"({NUM})\s+dimensiones\*{{0,2}},?\s+D1\s+a\s+D", dims_real,
             f"son {dims_real} dimensiones"),
            (rf"({NUM})\s+dimensiones\s+(?:de\s+validaci|D1\s+a\s+D)", dims_real,
             f"son {dims_real} dimensiones"),
            (rf"({NUM})\s+dimensiones\*{{0,2}},?\s+D1\s+a\s+D", dims_real,
             f"son {dims_real} dimensiones"),
            (rf"({NUM})\s+DTs?\s+canónicos", dts_real, f"son {dts_real} DTs canónicos"),
            # Solo el conteo del CANON. Un "8,955 reglas" de un brain son reglas
            # de negocio y no tienen relación: por eso se exige el calificador.
            (rf"({NUM})\s+reglas\s+(?:canónicas|viven|en \d+ niveles)", reglas_real,
             f"son {reglas_real} reglas del canon"),
        ]
        vistos = set()
        for p in self.docs("md", "html"):
            # Un ADR declara las cifras que eran ciertas el dia que se aprobo, y
            # eso no es un error: es el registro de una decision fechada.
            # ADR-EB-006 dice "CORE de 15 tablas" porque eso fue lo que decidio.
            # Lo que mantiene honestos a los ADR es D8, la propagacion, no esta
            # dimension. Exigirles la cifra de hoy seria pedirles que mientan
            # sobre lo que decidieron.
            if "adr" in p.parts:
                continue
            txt = p.read_text(encoding="utf-8", errors="ignore")
            for patron, esperado, msg in chequeos:
                for m in re.finditer(patron, txt, re.I):
                    dice = valor(m.group(1))
                    if dice is None or dice == esperado:
                        continue
                    ln = txt.count("\n", 0, m.start()) + 1
                    # Dos patrones pueden ver la misma cifra: se reporta una vez.
                    if (p, ln, m.group(1)) in vistos:
                        continue
                    vistos.add((p, ln, m.group(1)))
                    ctx = txt[max(0, m.start() - 70):m.start() + 50].replace("\n", " ")
                    # Con límites de palabra: sin ellos, "antes" casaba dentro de
                    # "bloqueantes" y silenciaba el hallazgo. Un filtro demasiado
                    # amplio vuelve ciego al validador sin que nadie lo note.
                    if re.search(r"(ENMIENDA|\bv1\.0\b|\bantes\b|\bhistórico\b|"
                                 r"\bEran\b|\bera\b|\bhoy son\b|\bhoy tiene\b|\banterior\b|"
                                 r"\ben esa fecha\b)",
                                 ctx, re.I):
                        continue
                    self.add("cifras", SEV_BLOQ, f"{msg}; aquí dice {m.group(1)}",
                             f"{self.rel(p)}:{ln}")

        # El diagrama del esquema dibuja el CORE tabla por tabla. Comparar su
        # cifra no basta: puede decir 23 y dibujar otras 23. Se contrasta el
        # contenido, que es lo unico que un lector del portal ve.
        diagrama = self.asset / "portal" / "digital-brain-schema.html"
        if diagrama.exists():
            html = diagrama.read_text(encoding="utf-8", errors="ignore")
            if '<div class="core-grid">' in html:
                ini = html.index('<div class="core-grid">')
                fin = html.find("ONTOLOGY MATRIX", ini)
                dibujadas = set(re.findall(r'<div class="tname">([a-z_]+)</div>',
                                           html[ini:fin if fin > 0 else len(html)]))
                core = set(re.findall(r"CREATE TABLE IF NOT EXISTS (\w+)",
                                      ddl[ini_core:fin_core]))
                faltan = core - dibujadas
                sobran = dibujadas - core
                if faltan or sobran:
                    self.add("cifras", SEV_BLOQ,
                             "el diagrama del esquema no dibuja el CORE real: "
                             + (f"faltan {sorted(faltan)} " if faltan else "")
                             + (f"sobran {sorted(sobran)}" if sobran else ""),
                             self.rel(diagrama))

        # rangos de DoD: nadie debe declarar un tope menor al real
        for p in self.docs("md"):
            txt = p.read_text(encoding="utf-8", errors="ignore")
            for m in re.finditer(r"DoD-EB-0?1\s*(?:a|hasta|-|–|—)\s*DoD-EB-(\d+)|"
                                 r"DoD-EB\s*0?1\s*-\s*(\d+)", txt):
                tope = int(m.group(1) or m.group(2))
                if tope < dod_real:
                    ln = txt.count("\n", 0, m.start()) + 1
                    self.add("cifras", SEV_BLOQ,
                             f"rango de DoD incompleto: declara hasta {tope}, el canon llega a {dod_real}",
                             f"{self.rel(p)}:{ln}")

    # ── D5 · DDL transcrito fuera del esquema ─────────────────────────────
    def d5_ddl(self):
        """ADR-EB-006: el DDL vive solo en templates/schema.sql."""
        esquema = self.esquema()
        for p in self.docs("md"):
            txt = p.read_text(encoding="utf-8", errors="ignore")
            for m in re.finditer(r"CREATE TABLE (?:IF NOT EXISTS )?(\w+)\s*\((.*?)\n\s*\)", txt, re.S):
                tabla, cuerpo = m.group(1), m.group(2)
                ln = txt.count("\n", 0, m.start()) + 1
                if tabla not in esquema:
                    self.add("ddl", SEV_BLOQ,
                             f"transcribe DDL de '{tabla}', que no existe en el canon",
                             f"{self.rel(p)}:{ln}")
                    continue
                cols_doc = set(re.findall(r"^\s*(\w+)\s+(?:TEXT|INTEGER|REAL|BLOB|NUMERIC)",
                                          cuerpo, re.M | re.I))
                faltan = set(esquema[tabla]) - cols_doc
                sobran = cols_doc - set(esquema[tabla])
                self.add("ddl", SEV_BLOQ,
                         f"transcribe el DDL de '{tabla}' (ADR-EB-006 lo prohíbe)"
                         + (f"; omite {sorted(faltan)[:5]}" if faltan else "")
                         + (f"; inventa {sorted(sobran)[:5]}" if sobran else ""),
                         f"{self.rel(p)}:{ln}")

    # ── D7 · Corrupcion de escape ─────────────────────────────────────────
    def d7_escapes(self):
        """
        Busca bytes de retroceso (0x08) en archivos de texto.

        Aparecen cuando un parche escribe \\b dentro de una cadena Python no
        cruda, donde \\b es el caracter de retroceso y no el limite de palabra
        de una expresion regular. El sintoma es traicionero: el archivo compila,
        el patron deja de casar y nada lo reporta. Ocurrio dos veces en este
        mismo validador y en ambas dejo un filtro inservible.
        """
        for p in self.docs("py", "md", "sql", "html", "json"):
            try:
                txt = p.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                continue
            if "\x08" in txt:
                ln = txt.count("\n", 0, txt.index("\x08")) + 1
                self.add("escapes", SEV_BLOQ,
                         f"{txt.count(chr(8))} byte(s) de retroceso: un parche escribió "
                         f"\\b en una cadena no cruda y el patrón quedó inservible",
                         f"{self.rel(p)}:{ln}")

    # ── D6 · Guardas que no pueden fallar ─────────────────────────────────
    def d6_guardas(self):
        """Una verificación que no puede dar negativo no verifica nada."""
        bb = self.asset / "templates" / "build-brain.py"
        if bb.exists():
            txt = bb.read_text(encoding="utf-8")
            self.stats["cargadores_con_linaje"] = len(re.findall(r"source_type\s*=", txt))
            cuerpo = re.search(r"def assert_lineage\(self\):(.*?)(?=\n    def |\n\ndef )",
                               txt, re.S)
            if cuerpo:
                c = cuerpo.group(1)
                # Una guarda sirve si CONTRASTA lo cargado contra lo que tiene linaje.
                # Si solo cuenta filas de knowledge_lineage, basta un cargador que
                # escriba una para volverla vacua: deja de poder dar negativo.
                if not ("self.counts" in c and "raise" in c):
                    self.add("guardas", SEV_BLOQ,
                             "assert_lineage() no puede fallar: no contrasta las tablas "
                             "cargadas contra las que tienen linaje, así que basta un "
                             "cargador para volverla vacua",
                             self.rel(bb))
            elif "assert_lineage" in txt:
                self.add("guardas", SEV_AVISO,
                         "assert_lineage() se invoca pero no se pudo leer su cuerpo",
                         self.rel(bb))

        # except que devuelven valor neutro en métodos que son gate
        for nombre in ("brain.py", "build-portal.py", "callosum.py"):
            p = self.asset / "templates" / nombre
            if not p.exists():
                continue
            txt = p.read_text(encoding="utf-8")
            n = len(re.findall(r"except\s+Exception[^\n]*:\s*\n\s*return\s*(\[\]|None|0|\{\})", txt))
            if n:
                self.add("guardas", SEV_AVISO,
                         f"{n} excepción(es) amplias que devuelven valor neutro: "
                         f"un error se vuelve indistinguible de 'sin hallazgos'",
                         self.rel(p))

    # ── ejecución ─────────────────────────────────────────────────────────
    DIMS = {
        "sql": ("SQL ejecutable", "d1_sql"),
        "retirados": ("Nombres retirados", "d2_retirados"),
        "referencias": ("Referencias y rutas", "d3_referencias"),
        "cifras": ("Cifras consistentes", "d4_cifras"),
        "ddl": ("DDL fuera del esquema", "d5_ddl"),
        "guardas": ("Guardas que pueden fallar", "d6_guardas"),
        "escapes": ("Escapes sin corromper", "d7_escapes"),
        "propagacion": ("Propagación de ADRs", "d8_propagacion"),
    }

    # ── D8 · Propagación de ADRs aprobados ────────────────────────────────
    def d8_propagacion(self):
        """
        Un ADR aprobado que no bajó a los artefactos es el modo de falla que
        esta auditoría encontró tres veces (EB-011, EB-012, EB-014): el canon
        escrito terminó contradiciendo decisiones aprobadas.

        El contrato: un ADR declara su propagación en un bloque legible por
        máquina, y mientras esté en APROBADO toda aserción debe cumplirse.

            <!-- PROPAGACION
            templates/schema.sql :: 23 tablas
            canon/brain-rules.md :: company_profile
            -->

        Cada línea es `ruta :: cadena que debe aparecer en esa ruta`. Un ADR en
        PROPUESTO con aserciones pendientes es normal y se reporta como aviso:
        es su lista de trabajo. Uno en APROBADO, no.
        """
        aprobados = pendientes = 0
        for p in sorted((self.asset / "adr").glob("ADR-EB-*.md")):
            txt = p.read_text(encoding="utf-8", errors="ignore")
            # Dos formatos conviven y los dos son válidos: "Estado: **APROBADO**"
            # en los ADR nuevos y "**Estado**: APROBADO" en los cinco primeros.
            # "APROBADO y ENMENDADO" también rige, así que no sirve \w+.
            m_est = (re.search(r"Estado:\s*\*\*([^*\n]+)\*\*", txt)
                     or re.search(r"\*\*Estado\*\*:\s*([^\n·]+)", txt))
            estado = m_est.group(1).strip().upper() if m_est else "SIN_ESTADO"
            aprobado = "APROBADO" in estado
            bloque = re.search(r"<!--\s*PROPAGACION\s*(.*?)-->", txt, re.S)

            if estado == "SIN_ESTADO":
                self.add("propagacion", SEV_AVISO,
                         "no declara Estado: no se puede saber si rige", self.rel(p))
                continue
            if aprobado:
                aprobados += 1
            if not bloque:
                if aprobado:
                    self.add("propagacion", SEV_AVISO,
                             "aprobado sin bloque PROPAGACION: su bajada a los "
                             "artefactos no es verificable", self.rel(p))
                continue

            sev = SEV_BLOQ if aprobado else SEV_AVISO
            for linea in bloque.group(1).splitlines():
                linea = linea.strip()
                if not linea or linea.startswith("#"):
                    continue
                if "::" not in linea:
                    self.add("propagacion", SEV_BLOQ,
                             f"línea de PROPAGACION mal formada: {linea[:60]}", self.rel(p))
                    continue
                ruta, esperado = (x.strip() for x in linea.split("::", 1))
                destino = self.asset / ruta
                if not destino.exists():
                    pendientes += 1
                    self.add("propagacion", sev,
                             f"{estado}: la ruta de propagación no existe: {ruta}", self.rel(p))
                    continue
                cuerpo = destino.read_text(encoding="utf-8", errors="ignore")
                if esperado not in cuerpo:
                    pendientes += 1
                    self.add("propagacion", sev,
                             f"{estado}: {ruta} no contiene «{esperado[:45]}»", self.rel(p))

        self.stats["adrs_aprobados"] = aprobados
        self.stats["propagacion_pendiente"] = pendientes

    def run(self, solo=None):
        for clave, (_, metodo) in self.DIMS.items():
            if solo and clave != solo:
                continue
            try:
                getattr(self, metodo)()
            except Exception as e:
                self.add(clave, SEV_BLOQ, f"la verificación falló: {e}")
        return self.h


def main():
    ap = argparse.ArgumentParser(description="Valida el canon del Enterprise Brain contra sí mismo")
    ap.add_argument("--dim", choices=list(CanonValidator.DIMS))
    ap.add_argument("--summary", action="store_true")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()

    v = CanonValidator(ASSET)
    v.run(a.dim)
    bloq = [x for x in v.h if x.sev == SEV_BLOQ]
    por_dim = defaultdict(list)
    for x in v.h:
        por_dim[x.dim].append(x)

    if a.json:
        print(json.dumps({"stats": v.stats, "hallazgos": [x.as_dict() for x in v.h],
                          "bloqueantes": len(bloq)}, ensure_ascii=False, indent=2))
        return 1 if bloq else 0

    print("VALIDACIÓN DEL CANON — asset Enterprise Brain")
    print("=" * 62)
    for clave, (titulo, _) in CanonValidator.DIMS.items():
        if a.dim and clave != a.dim:
            continue
        hs = por_dim.get(clave, [])
        nb = len([x for x in hs if x.sev == SEV_BLOQ])
        estado = "PASS" if nb == 0 else "FAIL"
        print(f"[{estado}] {titulo:28s} — {len(hs)} hallazgo(s), {nb} bloqueante(s)")
        if not a.summary:
            for x in hs[:14]:
                print(f"      {x}")
            if len(hs) > 14:
                print(f"      ... y {len(hs) - 14} más")

    if v.stats:
        print("\nCifras derivadas de la realidad:")
        for k, val in sorted(v.stats.items()):
            print(f"   {k}: {val}")

    print("\n" + ("RESULTADO: PASS" if not bloq
                  else f"RESULTADO: FAIL — {len(bloq)} hallazgo(s) bloqueante(s)"))
    return 1 if bloq else 0


if __name__ == "__main__":
    sys.exit(main())
