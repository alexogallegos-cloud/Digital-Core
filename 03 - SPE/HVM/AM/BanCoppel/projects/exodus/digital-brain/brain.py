#!/usr/bin/env python3
"""brain.py — Agent API del Programa Exodus (BanCoppel)

Implementa la interfaz estándar de 5 métodos de la taxonomía canónica AM
(`coverage`, `components`, `search`, `rules`, `domains`) más métodos propios del
programa. Cumple la Regla B1: es auto-sustentable y no depende de `bank-brain`
en runtime.

Uso como librería:
    from brain import ExodusBrain
    b = ExodusBrain()
    b.coverage()

Uso como CLI:
    python brain.py coverage
    python brain.py waves
    python brain.py components --wave W1
    python brain.py search informix
    python brain.py reconciliation
    python brain.py questions

v1.0.0 · 2026-08-19
"""
from __future__ import annotations

import argparse
import json
import pathlib
import sqlite3

DB_PATH = pathlib.Path(__file__).resolve().parent / "brain.db"


def _jl(value: str | None) -> list:
    """Deserializa las columnas guardadas como JSON array."""
    if not value:
        return []
    try:
        return json.loads(value)
    except (json.JSONDecodeError, TypeError):
        return []


class ExodusBrain:
    """Brain del programa Exodus. Migración de datacenters de México a la nube."""

    def __init__(self, db_path: pathlib.Path | str = DB_PATH) -> None:
        self.db_path = pathlib.Path(db_path)
        if not self.db_path.exists():
            raise FileNotFoundError(
                f"No existe {self.db_path}. Ejecuta build-brain.py primero.")
        self.con = sqlite3.connect(f"file:{self.db_path}?mode=ro", uri=True)
        self.con.row_factory = sqlite3.Row

    # ── interfaz estándar AM ──────────────────────────────────────────────

    def coverage(self) -> dict:
        """Estado del brain: qué sabe y de qué tamaño es el programa."""
        q = lambda sql: self.con.execute(sql).fetchone()[0]
        info = self.con.execute("SELECT * FROM program_info").fetchone()
        return {
            "program": info["display_name"] if info else "Exodus",
            "brain_version": info["brain_version"] if info else None,
            "built_at": info["built_at"] if info else None,
            "horizon": f"{info['horizon_start']} a {info['horizon_end']}" if info else None,
            "waves": q("SELECT COUNT(*) FROM waves"),
            "applications": q("SELECT COUNT(*) FROM applications"),
            "core_applications": q("SELECT COUNT(*) FROM applications WHERE is_core=1"),
            "hosts_off_declared": info["hosts_off"] if info else None,
            "spls_refactored_declared": info["spls_refactored"] if info else None,
            "cross_dependencies": q("SELECT COUNT(*) FROM cross_dependencies"),
            "open_questions": q("SELECT COUNT(*) FROM open_questions"),
            "risks": q("SELECT COUNT(*) FROM risks"),
            "risks_critical": q("SELECT COUNT(*) FROM risks WHERE severity='critical'"),
        }

    def components(self, wave: str | None = None, core_only: bool = False,
                   apo: str | None = None) -> list[dict]:
        """Aplicaciones del programa. Filtrables por ola, criticidad core o clase APO."""
        sql = "SELECT * FROM applications WHERE 1=1"
        params: list = []
        if wave:
            sql += " AND wave_id = ?"
            params.append(wave.upper())
        if core_only:
            sql += " AND is_core = 1"
        if apo:
            sql += " AND apo_class LIKE ?"
            params.append(f"%{apo}%")
        sql += " ORDER BY wave_id, COALESCE(spl_count,0) DESC"

        out = []
        for r in self.con.execute(sql, params):
            d = dict(r)
            for col in ("business_functions", "target_apis", "golden_records",
                        "interop_capabilities", "yugabyte_entities"):
                d[col] = _jl(d.get(col))
            out.append(d)
        return out

    def search(self, query: str, limit: int = 20) -> list[dict]:
        """Búsqueda fulltext sobre las aplicaciones del programa."""
        rows = self.con.execute(
            "SELECT a.* FROM applications_fts f JOIN applications a ON a.id = f.id "
            "WHERE applications_fts MATCH ? LIMIT ?",
            (query, limit),
        ).fetchall()
        return [dict(r) for r in rows]

    def rules(self, component_id: str) -> list[dict]:
        """Exodus no extrae reglas de negocio: refactoriza los SPLs que las contienen.

        Las reglas del legado viven en el brain de Informix. Este método devuelve el
        puntero al alcance de SPLs de la aplicación para que el consumidor sepa dónde
        buscarlas.
        """
        r = self.con.execute(
            "SELECT id, app_id, name, spl_count, dbms, wave_id FROM applications "
            "WHERE id = ? OR app_id = ?", (component_id, component_id)).fetchone()
        if not r:
            return []
        return [{
            "component_id": r["id"],
            "name": r["name"],
            "declared_spl_count": r["spl_count"],
            "dbms": r["dbms"],
            "wave": r["wave_id"],
            "note": "Exodus declara el ALCANCE de SPLs a refactorizar, no su contenido. "
                    "Las reglas de negocio extraídas viven en "
                    "systems/core/Informix/digital-brain/brain.db::rules.",
            "caveat": "Los conteos por aplicación no reconcilian con las cabeceras de ola. "
                      "Ver reconciliation().",
        }]

    def domains(self) -> list[dict]:
        """Las olas son la unidad de agrupación del programa (equivalente a dominio)."""
        rows = self.con.execute("SELECT * FROM waves ORDER BY seq").fetchall()
        out = []
        for r in rows:
            d = dict(r)
            d["cdc_scope"] = _jl(d.get("cdc_scope"))
            d["risks"] = _jl(d.get("risks"))
            out.append(d)
        return out

    # ── métodos propios ──────────────────────────────────────────────────

    waves = domains  # alias legible

    def reconciliation(self) -> dict:
        """Contrasta las cifras declaradas en cabecera de ola contra la suma por aplicación.

        Existe porque las dos no cuadran, y la diferencia importa para el pricing.
        """
        per_wave = []
        for r in self.con.execute("""
            SELECT w.id, w.seq, w.spls_removed AS hdr_spls, w.hosts_off AS hdr_hosts,
                   w.app_count AS hdr_apps,
                   COALESCE(SUM(a.spl_count),0)      AS sum_spls,
                   COALESCE(SUM(a.hosts_released),0) AS sum_hosts,
                   COUNT(a.id)                       AS sum_apps
            FROM waves w LEFT JOIN applications a ON a.wave_id = w.id
            GROUP BY w.id ORDER BY w.seq"""):
            per_wave.append({
                "wave": r["id"],
                "spls_header": r["hdr_spls"], "spls_sum_apps": r["sum_spls"],
                "spls_delta": (r["sum_spls"] or 0) - (r["hdr_spls"] or 0),
                "hosts_header": r["hdr_hosts"], "hosts_sum_apps": r["sum_hosts"],
                "hosts_delta": (r["sum_hosts"] or 0) - (r["hdr_hosts"] or 0),
                "apps_header": r["hdr_apps"], "apps_sum": r["sum_apps"],
            })

        placeholders = [dict(r) for r in self.con.execute(
            "SELECT wave_id, app_id, name, spl_count FROM applications "
            "WHERE spl_count IN (10000, 1500, 1000) ORDER BY spl_count DESC")]

        return {
            "per_wave": per_wave,
            "totals": {
                "spls_header_sum": sum(w["spls_header"] or 0 for w in per_wave),
                "spls_app_sum": sum(w["spls_sum_apps"] or 0 for w in per_wave),
                "hosts_header_sum": sum(w["hosts_header"] or 0 for w in per_wave),
                "hosts_app_sum": sum(w["hosts_sum_apps"] or 0 for w in per_wave),
            },
            "round_number_placeholders": placeholders,
            "warning": "Las cifras de cabecera son planeacion top-down; las de aplicacion son "
                       "estimaciones con numeros redondos (tres apps declaran 10,000 SPLs cada "
                       "una). Ninguna es un conteo empirico. El unico conteo con base en codigo "
                       "real son los 11,391 SPs del brain de Informix (53 DBs, 2026-08-20). "
                       "Delta brain vs Exodus cabecera: ~3,911 SPs sin asignar a ninguna ola. "
                       "Ver EXO-R001.",
        }

    def cross_dependencies(self, direction: str | None = None) -> list[dict]:
        sql = "SELECT * FROM cross_dependencies"
        params: list = []
        if direction:
            sql += " WHERE direction = ?"
            params.append(direction)
        return [dict(r) for r in self.con.execute(sql + " ORDER BY criticality, id", params)]

    def questions(self) -> list[dict]:
        return [dict(r) for r in self.con.execute(
            "SELECT * FROM open_questions ORDER BY id")]

    def risks(self, severity: str | None = None, category: str | None = None,
              status: str | None = None) -> list[dict]:
        """Riesgos identificados por analisis del brain. Filtrables por severity/category/status."""
        sql = "SELECT * FROM risks WHERE 1=1"
        params: list = []
        if severity:
            sql += " AND severity = ?"
            params.append(severity.lower())
        if category:
            sql += " AND category = ?"
            params.append(category.lower())
        if status:
            sql += " AND status = ?"
            params.append(status.lower())
        order = "CASE severity WHEN 'critical' THEN 1 WHEN 'high' THEN 2 " \
                "WHEN 'medium' THEN 3 ELSE 4 END, id"
        return [dict(r) for r in self.con.execute(sql + f" ORDER BY {order}", params)]

    def close(self) -> None:
        self.con.close()

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()


# ── CLI ──────────────────────────────────────────────────────────────────

def _main() -> None:
    ap = argparse.ArgumentParser(description="Agent API del Programa Exodus")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("coverage")
    sub.add_parser("waves")
    sub.add_parser("reconciliation")
    sub.add_parser("questions")
    sub.add_parser("deps")
    p_r = sub.add_parser("risks")
    p_r.add_argument("--severity", choices=["critical", "high", "medium", "low"])
    p_r.add_argument("--category")
    p_c = sub.add_parser("components")
    p_c.add_argument("--wave")
    p_c.add_argument("--core-only", action="store_true")
    p_c.add_argument("--apo")
    p_s = sub.add_parser("search")
    p_s.add_argument("query")

    a = ap.parse_args()
    with ExodusBrain() as b:
        if a.cmd == "coverage":
            print(json.dumps(b.coverage(), indent=2, ensure_ascii=False))
        elif a.cmd == "waves":
            for w in b.waves():
                print(f"\n{w['id']} · {w['horizon']}\n  {w['title']}")
                print(f"  apps={w['app_count']} hosts={w['hosts_off']} "
                      f"spls={w['spls_removed']} ops/día={w['ops_per_day']}")
                print(f"  objetivo: {w['objective']}")
                for r in w["risks"]:
                    print(f"  riesgo: {r}")
        elif a.cmd == "reconciliation":
            print(json.dumps(b.reconciliation(), indent=2, ensure_ascii=False))
        elif a.cmd == "questions":
            for q in b.questions():
                print(f"\n[{q['id']}] ({q['kind']}) {q['question']}\n  {q['evidence']}")
        elif a.cmd == "deps":
            for d in b.cross_dependencies():
                print(f"{d['id']:34} {d['other_system']:14} {d['relationship']:12} "
                      f"{d['direction']:9} {d['criticality']}")
        elif a.cmd == "components":
            for c in b.components(wave=a.wave, core_only=a.core_only, apo=a.apo):
                print(f"{c['wave_id']} {c['app_id']:7} {str(c['name'])[:40]:40} "
                      f"SPL={str(c['spl_count']):>6} core={c['is_core']} "
                      f"apo={str(c['apo_class'])[:26]}")
        elif a.cmd == "search":
            for r in b.search(a.query):
                print(f"{r['wave_id']} {r['app_id']:7} {r['name']}")
        elif a.cmd == "risks":
            SEV = {"critical": "CRIT", "high": "HIGH", "medium": "MED ", "low": "LOW "}
            risks = b.risks(severity=a.severity, category=a.category)
            for r in risks:
                sev = SEV.get(r["severity"], r["severity"])
                print(f"[{r['id']}] [{sev}] [{r['category']:<14}] {r['title']}")
                print(f"         related={r['related']}  status={r['status']}")
                print(f"         {r['description'][:120]}...")
                print()


if __name__ == "__main__":
    _main()
