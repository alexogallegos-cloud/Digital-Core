#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
classify-rule-nature.py — Clasificación de NATURALEZA de cada regla v1.0
========================================================================
Barrido total de las 8,955 reglas: distingue REGLAS DE NEGOCIO genuinas de
REGLAS DE ENSAMBLAJE (SQL dinámico para reportes), INFRAESTRUCTURA (shell/
file/dbaccess) y PRESENTACIÓN (formato/mensajes).

Añade el campo `clase` (eje ortogonal a `tipo`):
  NEGOCIO             — decisión/cálculo/restricción de negocio real
  ENSAMBLAJE_REPORTE  — construcción de query/export para reportes
  INFRAESTRUCTURA     — shell, file I/O, dbaccess, paths AIX (plumbing)
  PRESENTACION        — formato de strings, padding, mensajes al usuario

Modo de validación (--validate): re-lee la línea EXACTA del código fuente
para cada regla y compara la clase inferida del `code` truncado vs la línea
completa. Reporta discrepancias. "Ir al código para estar seguros."

SPE-AM-001 · Specialist Informix SPL · 2026-08-12
"""
import json, re, sqlite3, sys, os
from collections import Counter
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent
SRC  = BASE / "source" / "Informix" / "informix"
V3   = BASE / "portal" / "data" / "business-rules-v3.json"
DB   = BASE / "digital-brain" / "brain.db"

# ── Firmas de clasificación (orden: más específico primero) ───────────────────

# INFRAESTRUCTURA — shell, file I/O, procesos externos, paths
_RE_SHELL = re.compile(
    r"\b(echo|chmod|chown|rm|mv|cp|cat|dbaccess|dbload|dbexport|dbimport|dbschema|"
    r"onmode|onstat|touch|mkdir|gzip|gunzip|tar|ftp|sftp|scp|sed|awk|grep|sh\s|ksh|"
    r"/usr/bin/|/bin/)\b", re.I)
_RE_PATHS = re.compile(r"/resplogifx/|/ifxsif01/|/respaldosnew/|/tmp/|/opt/|/home/|"
                       r"/datos/|/data/|>\s*/|>>\s*/", re.I)
_RE_UNLOAD = re.compile(r"\bunload\s+to\b|\bload\s+from\b|\bsystem\s*\(", re.I)
_RE_PATHVAR = re.compile(r"^\s*\w*(ruta|path|archivo|nomarch|nombrearch|file|dir|carpeta)\w*\s*=\s*['\"]", re.I)

# ENSAMBLAJE_REPORTE — construcción de query/comando SQL dinámico
_RE_CMDVAR = re.compile(
    r"^\s*(ccmd|csql|vsql|cselect|ccmdselect|cquery|cstmt|vstmt|cinstr|vinstr|"
    r"ccadena|cadena|ssql|scmd|vcmd|cmd\w*|query\w*|sqlstr|vsentencia|csentencia|"
    r"strsql|str_sql|vquery)\w*\s*=", re.I)
_RE_SQL_CONCAT = re.compile(
    r"\|\|\s*[\"']?\s*(select|from\s|where\s|union\b|order\s+by|group\s+by|having\b|"
    r"insert\s+into|update\s|delete\s+from|and\s|or\s|left\s+join|inner\s+join)", re.I)
_RE_ACCUM = re.compile(r'=\s*""\s*\|\||=\s*\'\'\s*\|\|', re.I)

# PRESENTACION — formato de strings, padding, mensajes
_RE_PAD = re.compile(r"\b(lpad|rpad)\s*\(", re.I)
_RE_MSG = re.compile(r"^\s*\w*(dictamen|mensaje|msg|texto|leyenda|desc\w*|nota|obs\w*)\w*\s*=\s*[\"']", re.I)
_RE_DATEMASK = re.compile(r"to_char\s*\([^)]*['\"]%", re.I)

# NEGOCIO — aritmética financiera real (para desambiguar)
_RE_ARITH_FIN = re.compile(
    r"[a-z_]*(monto|saldo|importe|capital|tasa|interes|comis|iva|isr|cuota|abono|"
    r"cargo|reserva|rendim|pago|deuda)[a-z_]*\s*[-*/+]|[-*/+]\s*[a-z_]*(monto|saldo|"
    r"importe|capital|tasa|interes|comis|iva|isr|cuota)", re.I)


# Prefijo LET/SET que aparece en el fuente crudo pero no en el code almacenado
_RE_LET = re.compile(r"^\s*(let|set)\s+", re.I)


def classify(code: str) -> str:
    """Clasifica la naturaleza de una regla por su código."""
    c = _RE_LET.sub("", (code or "").strip())   # normalizar: quitar LET/SET inicial
    cl = c.lower()

    # 1. INFRAESTRUCTURA — shell/file/external tiene prioridad absoluta
    if _RE_SHELL.search(c) or _RE_PATHS.search(c) or _RE_UNLOAD.search(c) or _RE_PATHVAR.match(c):
        return "INFRAESTRUCTURA"

    # 2. ENSAMBLAJE_REPORTE — construcción de SQL dinámico
    if _RE_CMDVAR.match(c) or _RE_SQL_CONCAT.search(c) or _RE_ACCUM.search(c):
        return "ENSAMBLAJE_REPORTE"

    # 3. PRESENTACION — padding / mensajes / máscaras sin aritmética financiera
    if (_RE_PAD.search(c) or _RE_MSG.match(c)) and not _RE_ARITH_FIN.search(c):
        return "PRESENTACION"
    if _RE_DATEMASK.search(c) and cl.count("||") >= 2 and not _RE_ARITH_FIN.search(c):
        return "PRESENTACION"

    # 4. NEGOCIO — todo lo demás
    return "NEGOCIO"


def read_source_line(db: str, sp: str, line: int) -> str | None:
    """Lee la línea EXACTA del código fuente (ir al código)."""
    # sp puede venir como db:sp o db:db:sp — normalizar
    sp_clean = sp.split(":")[-1]
    fp = SRC / f"{db}_{sp_clean}.sql"
    if not fp.exists():
        return None
    try:
        lines = fp.read_text(encoding="utf-8", errors="replace").split("\n")
        if 1 <= line <= len(lines):
            return lines[line - 1].strip()
    except Exception:
        return None
    return None


def main():
    validate = "--validate" in sys.argv
    apply    = "--apply" in sys.argv

    con = sqlite3.connect(DB)
    rows = con.execute("SELECT id, tipo, sp, db, line, code FROM rules").fetchall()
    print(f"Total reglas: {len(rows)}\n")

    results = {}   # id → (clase, clase_src, discrepancia)
    buckets = Counter()
    by_tipo = Counter()
    discrepancias = []
    n_validated = 0

    for rid, tipo, sp, db, line, code in rows:
        clase = classify(code or "")
        buckets[clase] += 1
        by_tipo[(tipo, clase)] += 1
        results[rid] = clase

        if validate:
            src_line = read_source_line(db, sp, line or 0)
            if src_line:
                n_validated += 1
                clase_src = classify(src_line)
                if clase_src != clase:
                    discrepancias.append((rid, tipo, db, sp, line, clase, clase_src,
                                          (code or "")[:70], src_line[:70]))

    print("=== Distribución por CLASE (naturaleza) ===")
    for cl, n in buckets.most_common():
        print(f"  {cl:<20}: {n:>5} ({n*100//len(rows)}%)")

    print("\n=== tipo × clase ===")
    for (tipo, cl), n in sorted(by_tipo.items(), key=lambda x: (-x[1])):
        marca = "  ← RECLASIFICAR" if cl != "NEGOCIO" else ""
        print(f"  {tipo:<12} {cl:<20}: {n:>5}{marca}")

    if validate:
        print(f"\n=== VALIDACIÓN CONTRA CÓDIGO FUENTE ===")
        print(f"  Líneas leídas del fuente: {n_validated}/{len(rows)}")
        print(f"  Discrepancias (code truncado vs línea completa): {len(discrepancias)}")
        if discrepancias:
            print(f"  ({len(discrepancias)*100//max(n_validated,1)}% de las validadas)\n")
            for d in discrepancias[:25]:
                print(f"    {d[0]} [{d[1]}] {d[2]}:{d[3]} L{d[4]}")
                print(f"      code-trunc → {d[5]:<18} | source → {d[6]}")
                print(f"      trunc: {d[7]}")
                print(f"      src:   {d[8]}")
        else:
            print("  ✔ 0 discrepancias — la clasificación del code truncado coincide con el fuente")

    if apply:
        print("\n=== APLICANDO clase a brain.db + v3.json ===")
        # brain.db: añadir columna clase
        try:
            con.execute("ALTER TABLE rules ADD COLUMN clase TEXT")
        except sqlite3.OperationalError:
            pass
        con.executemany("UPDATE rules SET clase=? WHERE id=?",
                        [(cl, rid) for rid, cl in results.items()])
        con.commit()
        print(f"  brain.db: {len(results)} reglas con clase")

        # v3.json
        v3 = json.loads(V3.read_text(encoding="utf-8"))
        for r in v3["rules"]:
            r["clase"] = results.get(r["id"], "NEGOCIO")
        v3.setdefault("meta", {})["clase_taxonomy"] = [
            "NEGOCIO", "ENSAMBLAJE_REPORTE", "INFRAESTRUCTURA", "PRESENTACION"]
        V3.write_text(json.dumps(v3, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"  v3.json: {len(v3['rules'])} reglas con clase")
        n_negocio = sum(1 for c in results.values() if c == "NEGOCIO")
        print(f"\n  Reglas de NEGOCIO genuinas: {n_negocio} ({n_negocio*100//len(results)}%)")
        print(f"  No-negocio (ensamblaje/infra/presentación): {len(results)-n_negocio}")

    con.close()
    print("\nDone.")


if __name__ == "__main__":
    main()