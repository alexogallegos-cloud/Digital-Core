#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-mapa-tablas.py — Genera el mapa de las tablas del canon.

Lee las tres fuentes de verdad y emite tres vistas del mismo modelo:

    templates/schema.sql     tablas, columnas, llaves y comentarios
    dt/cobertura-dt.md       qué DT es dueño de cada tabla
    canon/brain-rules.md     qué regla gobierna cada tabla

Salidas:
    canon/mapa-tablas.md     referencia para construir un brain
    portal/mapa-tablas.html  diagrama visual por capas y relaciones

Se genera, no se escribe a mano, por la misma razón que el portal (Regla P4):
un mapa transcrito se desfasa del esquema y nadie lo nota. Si cambia el DDL,
se vuelve a correr y punto.

Uso:  python canon/build-mapa-tablas.py
"""
from __future__ import annotations

import html
import re
import sqlite3
from collections import OrderedDict
from datetime import date
from pathlib import Path

ASSET = Path(__file__).resolve().parent.parent
SCHEMA = ASSET / "templates" / "schema.sql"
COBERTURA = ASSET / "dt" / "cobertura-dt.md"
REGLAS = ASSET / "canon" / "brain-rules.md"
OUT_MD = ASSET / "canon" / "mapa-tablas.md"
OUT_HTML = ASSET / "portal" / "mapa-tablas.html"

# La cadena de valor de la Regla B27, para la vista por dominio de negocio.
CADENA = OrderedDict([
    ("Productos", (["products"], "¿Qué ofrece el negocio al mercado?")),
    ("KPIs", (["kpis"], "¿Cómo se mide el éxito de cada producto?")),
    ("Procesos", (["processes", "journeys"], "¿Cómo opera el negocio para entregarlo?")),
    ("Aplicaciones", (["components", "component_calls", "applications",
                       "external_systems", "component_capabilities",
                       "component_processes", "rules"],
                      "¿Qué sistemas realizan esos procesos?")),
    ("Infraestructura", (["technology_components", "suppliers"],
                         "¿Qué plataformas los sostienen?")),
    ("Datos", (["data_entities", "component_data"],
               "¿Qué entidades de información consumen y producen?")),
])


# ── Lectura del DDL ──────────────────────────────────────────────────────────
def lee_schema() -> OrderedDict:
    ddl = SCHEMA.read_text(encoding="utf-8")

    # Capa de cada tabla, por la sección del DDL en que aparece
    capas = {}
    actual = "CORE"
    for linea in ddl.split("\n"):
        m = re.match(r"^-- (CORE|SYSTEM|PROJECT|ENTERPRISE|PUENTE)\b", linea)
        if m:
            actual = m.group(1)
        m = re.match(r"CREATE TABLE IF NOT EXISTS (\w+)", linea)
        if m:
            capas[m.group(1)] = actual

    # Tipos reales: se los pide a SQLite en vez de parsearlos
    con = sqlite3.connect(":memory:")
    con.executescript(ddl)

    tablas = OrderedDict()
    for nombre, capa in capas.items():
        cols = [
            {"nombre": c[1], "tipo": c[2], "nn": bool(c[3]),
             "default": c[4], "pk": bool(c[5])}
            for c in con.execute(f"PRAGMA table_info({nombre})")
        ]
        cuerpo = re.search(
            rf"CREATE TABLE IF NOT EXISTS {nombre}\s*\((.*?)\n\);", ddl, re.S)
        cuerpo = cuerpo.group(1) if cuerpo else ""

        # Comentario de cada columna y enumeración de valores
        notas, valores = {}, {}
        for l in cuerpo.split("\n"):
            m = re.match(r"\s*(\w+)\s+\w+[^-]*--\s*(.+)$", l)
            if m:
                col, nota = m.group(1), m.group(2).strip()
                notas[col] = nota
                if "|" in nota and not nota.lower().startswith("regla"):
                    valores[col] = [v.strip() for v in nota.split("|")]

        # Llaves foráneas lógicas, declaradas como comentario en el DDL
        fks = {}
        for m in re.finditer(r"FK lógica a (\w+)\.(\w+)", cuerpo):
            fks[m.group(1)] = m.group(2)
        for c in cols:
            if c["nombre"].endswith("_id") and c["nombre"] != "id":
                destino = c["nombre"][:-3]
                for cand in (destino + "s", destino, destino + "es"):
                    if cand in capas:
                        fks[cand] = c["nombre"]
                        break

        # Reglas citadas en los comentarios de la tabla
        reglas = sorted(set(re.findall(r"\bB(\d{1,2})\b", cuerpo)), key=int)
        # Propósito: el primer comentario de bloque antes del CREATE
        prev = ddl[:ddl.index(f"CREATE TABLE IF NOT EXISTS {nombre}")]
        bloque = re.findall(r"((?:^--[^\n]*\n)+)\s*$", prev, re.M)
        proposito = ""
        if bloque:
            proposito = " ".join(
                l.lstrip("- ").strip() for l in bloque[-1].strip().split("\n")
                if not re.match(r"^-{3,}|^-- ={3,}", l))[:230]

        tablas[nombre] = {
            "capa": capa, "cols": cols, "notas": notas, "valores": valores,
            "fks": fks, "reglas": [f"B{r}" for r in reglas],
            "proposito": proposito,
        }
    con.close()
    return tablas


# ── Dueño de cada tabla, desde el artefacto de cobertura ────────────────────
def lee_duenos() -> dict:
    txt = COBERTURA.read_text(encoding="utf-8")
    bloque = re.search(r"\| DT \| Tablas que posee \|(.*?)\n\n", txt, re.S)
    duenos = {}
    if bloque:
        for linea in bloque.group(1).split("\n"):
            m = re.match(r"\|\s*`?(dt-[\w-]+)`?\s*\|(.+?)\|", linea)
            if m:
                dt = m.group(1)
                for t in re.findall(r"`(\w+)`", m.group(2)):
                    duenos.setdefault(t, dt)
    return duenos


# ── Salida en Markdown ──────────────────────────────────────────────────────
def md(tablas, duenos) -> str:
    por_capa = OrderedDict()
    for n, d in tablas.items():
        por_capa.setdefault(d["capa"], []).append(n)

    o = [f"# Mapa de tablas del canon\n",
         f"> Generado el {date.today().isoformat()} por `canon/build-mapa-tablas.py` "
         f"desde `templates/schema.sql`. **No editar a mano**: se regenera.\n",
         f"El canon son **{len(tablas)} tablas**. Ningún brain las implementa todas: "
         f"implementa el CORE más la extensión que le corresponde por su `brain_type`, "
         f"más su lado del puente (Reglas B14 y B15).\n",
         "## Resumen por capa\n",
         "| Capa | Tablas | A quién aplica |",
         "|------|--------|----------------|"]
    aplica = {
        "CORE": "Todo brain, sin excepción",
        "SYSTEM": "`brain_type='system'`, sistemas en operación",
        "PROJECT": "`brain_type='project'`, proyectos de transformación",
        "ENTERPRISE": "`brain_type='enterprise'`, el brain de nivel cliente",
        "PUENTE": "Cada hemisferio implementa su lado (Regla B24)",
    }
    for capa, ts in por_capa.items():
        o.append(f"| **{capa}** | {len(ts)} | {aplica.get(capa, '')} |")

    o.append("\n---\n\n## Las tablas, por capa\n")
    for capa, ts in por_capa.items():
        o.append(f"### {capa}\n")
        o.append("| Tabla | Dueño | Columnas | Reglas | Se relaciona con |")
        o.append("|-------|-------|----------|--------|------------------|")
        for t in ts:
            d = tablas[t]
            fks = ", ".join(f"`{k}`" for k in sorted(d["fks"])) or "—"
            reglas = " ".join(d["reglas"]) or "—"
            o.append(f"| `{t}` | `{duenos.get(t, '—')}` | {len(d['cols'])} "
                     f"| {reglas} | {fks} |")
        o.append("")

    o.append("---\n\n## Vista por cadena de valor (Regla B27)\n")
    o.append("El conocimiento técnico se ancla en la cadena del negocio. "
             "Un componente que no se puede trazar hasta un producto y un KPI "
             "es conocimiento muerto.\n")
    usadas = set()
    for eslabon, (ts, pregunta) in CADENA.items():
        presentes = [t for t in ts if t in tablas]
        usadas.update(presentes)
        o.append(f"**{eslabon}** — *{pregunta}*  ")
        o.append("  " + ", ".join(f"`{t}`" for t in presentes) + "\n")
    resto = sorted(set(tablas) - usadas)
    o.append(f"**Fuera de la cadena** — gobierno, ontología, federación y calidad  ")
    o.append("  " + ", ".join(f"`{t}`" for t in resto) + "\n")

    o.append("---\n\n## Detalle de cada tabla\n")
    for capa, ts in por_capa.items():
        for t in ts:
            d = tablas[t]
            o.append(f"### `{t}`\n")
            meta = [f"**Capa**: {capa}", f"**Dueño**: `{duenos.get(t,'—')}`"]
            if d["reglas"]:
                meta.append("**Reglas**: " + " ".join(d["reglas"]))
            o.append(" · ".join(meta).replace(" · ", ", ") + "\n")
            if d["proposito"]:
                o.append(f"{d['proposito']}\n")
            o.append("| Columna | Tipo | Obligatoria | Qué guarda |")
            o.append("|---------|------|-------------|------------|")
            for c in d["cols"]:
                nota = d["notas"].get(c["nombre"], "")
                # Los pipes de las enumeraciones rompen la tabla markdown
                nota = re.sub(r"\s+", " ", nota)[:95].replace("|", ", ")
                pk = " (PK)" if c["pk"] else ""
                o.append(f"| `{c['nombre']}`{pk} | {c['tipo'] or 'TEXT'} "
                         f"| {'sí' if c['nn'] else 'no'} | {nota} |")
            if d["fks"]:
                o.append("\n**Se relaciona con**: " +
                         ", ".join(f"`{k}` (por `{v}`)" for k, v in sorted(d["fks"].items())))
            o.append("")
    return "\n".join(o)


# ── Salida en HTML ──────────────────────────────────────────────────────────
def htm(tablas, duenos) -> str:
    por_capa = OrderedDict()
    for n, d in tablas.items():
        por_capa.setdefault(d["capa"], []).append(n)
    e = html.escape
    color = {"CORE": "#1A3A6C", "SYSTEM": "#2B7FB8", "PROJECT": "#7A6FB0",
             "ENTERPRISE": "#1A7A50", "PUENTE": "#B45309"}

    cards = []
    for capa, ts in por_capa.items():
        c = color.get(capa, "#555")
        items = []
        for t in ts:
            d = tablas[t]
            fks = "".join(f'<span class="fk">{e(k)}</span>' for k in sorted(d["fks"]))
            reglas = "".join(f'<span class="rg">{e(r)}</span>' for r in d["reglas"])
            items.append(
                f'<div class="t"><div class="tn">{e(t)}<span class="nc">{len(d["cols"])} col</span></div>'
                f'<div class="dt">{e(duenos.get(t, "—"))}</div>'
                f'<div class="tags">{reglas}{fks}</div></div>')
        cards.append(
            f'<section class="capa" style="--c:{c}">'
            f'<h2>{e(capa)}<span class="n">{len(ts)} tablas</span></h2>'
            f'<div class="grid">{"".join(items)}</div></section>')

    cadena = []
    for eslabon, (ts, pregunta) in CADENA.items():
        pres = [t for t in ts if t in tablas]
        cadena.append(
            f'<div class="esl"><div class="eh">{e(eslabon)}</div>'
            f'<div class="eq">{e(pregunta)}</div>'
            f'<div class="et">{"".join(f"<span>{e(t)}</span>" for t in pres)}</div></div>')

    return f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Mapa de tablas del canon — Enterprise Brain</title>
<style>
*{{box-sizing:border-box}}
body{{margin:0;font:14px/1.5 -apple-system,Segoe UI,Roboto,sans-serif;background:#F7F7FB;color:#1C1C2E}}
header{{padding:26px 34px;background:#1C1C3A;color:#fff}}
h1{{margin:0;font-size:1.45rem;font-weight:800}}
.sub{{opacity:.75;font-size:.76rem;margin-top:5px}}
.capa{{margin:18px 34px;background:#fff;border-radius:11px;border-left:5px solid var(--c);padding:15px 19px;box-shadow:0 1px 3px rgba(0,0,0,.06)}}
.capa h2{{margin:0 0 11px;font-size:.92rem;color:var(--c);display:flex;justify-content:space-between;align-items:baseline}}
.n{{font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:.07em;opacity:.6}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(216px,1fr));gap:8px}}
.t{{border:1px solid #E6E6F0;border-radius:8px;padding:8px 11px;background:#FCFCFE}}
.tn{{font-family:ui-monospace,monospace;font-size:.76rem;font-weight:700;display:flex;justify-content:space-between;gap:6px}}
.nc{{font-family:inherit;font-size:.56rem;font-weight:600;opacity:.5;white-space:nowrap}}
.dt{{font-size:.62rem;color:#555;margin:3px 0 5px}}
.tags{{display:flex;flex-wrap:wrap;gap:3px}}
.rg,.fk{{font-size:.55rem;font-weight:600;border-radius:7px;padding:1px 6px}}
.rg{{background:#EEF2FF;color:#3730A3}}
.fk{{background:#F1F5F9;color:#475569;font-family:ui-monospace,monospace}}
.cadena{{margin:18px 34px;background:#fff;border-radius:11px;padding:15px 19px;box-shadow:0 1px 3px rgba(0,0,0,.06)}}
.cadena h2{{margin:0 0 4px;font-size:.92rem;color:#1A3A6C}}
.lead{{font-size:.72rem;color:#555;margin-bottom:12px}}
.esls{{display:grid;grid-template-columns:repeat(6,1fr);gap:8px}}
.esl{{border:1.5px solid #CBD5E1;border-radius:9px;padding:9px 11px;background:#FAFBFF}}
.eh{{font-size:.74rem;font-weight:800;color:#1A3A6C}}
.eq{{font-size:.6rem;color:#64748B;margin:3px 0 6px;line-height:1.35}}
.et span{{display:inline-block;font-family:ui-monospace,monospace;font-size:.56rem;background:#E8EEF9;color:#1A3A6C;border-radius:6px;padding:1px 5px;margin:0 2px 2px 0}}
footer{{padding:16px 34px;font-size:.66rem;color:#64748B}}
@media(max-width:1100px){{.esls{{grid-template-columns:repeat(3,1fr)}}}}
</style></head><body>
<header>
  <h1>Mapa de tablas del canon</h1>
  <div class="sub">{len(tablas)} tablas. Generado el {date.today().isoformat()} desde templates/schema.sql. Ningún brain las implementa todas: implementa el CORE más su extensión más su lado del puente.</div>
</header>
<div class="cadena">
  <h2>Vista por cadena de valor, Regla B27</h2>
  <div class="lead">El conocimiento técnico se ancla en la cadena del negocio. Un componente que no se puede trazar hasta un producto y un KPI es conocimiento muerto.</div>
  <div class="esls">{"".join(cadena)}</div>
</div>
{"".join(cards)}
<footer>Asset Enterprise Brain, Digital Core, Accenture México. Este archivo se genera; no se edita a mano.</footer>
</body></html>"""


def main() -> int:
    tablas = lee_schema()
    duenos = lee_duenos()
    OUT_MD.write_text(md(tablas, duenos), encoding="utf-8")
    OUT_HTML.write_text(htm(tablas, duenos), encoding="utf-8")
    sin_dueno = [t for t in tablas if t not in duenos]
    print(f"tablas mapeadas: {len(tablas)}")
    print(f"con dueño declarado: {len(tablas) - len(sin_dueno)}")
    if sin_dueno:
        print(f"sin dueño en cobertura-dt.md: {', '.join(sin_dueno)}")
    print(f"  {OUT_MD.relative_to(ASSET)}")
    print(f"  {OUT_HTML.relative_to(ASSET)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
