#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-brain.py — CAN Digital Brain
Créditos Asociados a Nómina · BanCoppel · SPE-AM-001

Brain regulatorio: estructura las obligaciones CAN, las brechas identificadas
y el roadmap de cambios en una SQLite consultable.

Ejecutar: python digital-brain/build-brain.py [--reset]
"""
import sqlite3, json, sys, os
from pathlib import Path
from datetime import date

BASE  = Path(__file__).resolve().parent.parent
DB    = Path(__file__).resolve().parent / "brain.db"
RESET = "--reset" in sys.argv

SCHEMA = """
PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

-- ── Meta ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS brain_meta (
    key   TEXT PRIMARY KEY,
    value TEXT
);

-- ── Obligaciones regulatorias CAN ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS regulatory_obligations (
    obligation_id   TEXT PRIMARY KEY,          -- CAN-OBL-{NNN}
    regulator       TEXT DEFAULT 'Banxico',
    instrument      TEXT,                      -- Circular / Artículo
    article         TEXT,
    description     TEXT,
    obligation_type TEXT,                      -- reporte|control|limite|disclosure|certificacion|autorizacion
    frequency       TEXT,                      -- diario|mensual|trimestral|anual|evento|continuo
    penalty_risk    TEXT,                      -- critico|alto|medio|bajo
    effective_date  TEXT,
    notes           TEXT
);

-- ── Sistemas en scope ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS systems_in_scope (
    id              TEXT PRIMARY KEY,          -- SCOPE-{sistema}-{NNN}
    system_slug     TEXT,                      -- informix|unity|apolo|ctm|etc
    togaf_type      TEXT,
    description     TEXT,
    in_scope_reason TEXT,
    obligation_ids  TEXT                       -- JSON array de CAN-OBL-{NNN}
);

-- ── Brechas de compliance ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS compliance_gaps (
    gap_id          TEXT PRIMARY KEY,          -- BRECHA-CAN-{NNN}
    obligation_id   TEXT,
    status          TEXT,                      -- CUMPLE|PARCIAL|NO-CUMPLE
    current_evidence TEXT,
    gap_description TEXT,
    criticality     TEXT,                      -- critico|alto|medio|bajo
    system_affected TEXT,                      -- JSON array de slugs
    target_deadline TEXT,
    FOREIGN KEY (obligation_id) REFERENCES regulatory_obligations(obligation_id)
);

-- ── User Stories de implementación ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_stories (
    us_id           TEXT PRIMARY KEY,          -- US-CAN-{NNN}
    gap_id          TEXT,
    title           TEXT,
    system_target   TEXT,
    change_type     TEXT,                      -- nuevo_sp|modificar_sp|nuevo_reporte|nuevo_control
    acceptance_criteria TEXT,
    effort_points   INTEGER,
    priority        TEXT,                      -- P1|P2|P3
    regulatory_deadline TEXT,
    sme_executor    TEXT,
    status          TEXT DEFAULT 'backlog',    -- backlog|in-progress|done
    FOREIGN KEY (gap_id) REFERENCES compliance_gaps(gap_id)
);

-- ── Vista — Dashboard de cumplimiento ────────────────────────────────────────
CREATE VIEW IF NOT EXISTS compliance_dashboard AS
SELECT
    o.obligation_id,
    o.obligation_type,
    o.penalty_risk,
    o.effective_date,
    COALESCE(g.status, 'NO-EVALUADO') AS gap_status,
    COALESCE(g.criticality, 'sin-evaluar') AS gap_criticality,
    COUNT(u.us_id) AS user_stories_count
FROM regulatory_obligations o
LEFT JOIN compliance_gaps g ON g.obligation_id = o.obligation_id
LEFT JOIN user_stories u    ON u.gap_id = g.gap_id
GROUP BY o.obligation_id;
"""


def build():
    if RESET and DB.exists():
        DB.unlink()
        print("brain.db eliminado (--reset)")

    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    con.executescript(SCHEMA)

    # Meta
    con.execute("INSERT OR REPLACE INTO brain_meta VALUES ('project','CAN')")
    con.execute("INSERT OR REPLACE INTO brain_meta VALUES ('version','0.1.0')")
    con.execute(f"INSERT OR REPLACE INTO brain_meta VALUES ('built_at','{date.today()}')")
    con.execute("INSERT OR REPLACE INTO brain_meta VALUES ('status','DATO-REQUERIDO — cargar circular Banxico CAN')")

    con.commit()
    con.close()

    stats(DB)


def stats(db_path: Path):
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    print("\n── CAN Brain ─────────────────────────────────────────────────")
    for t in ("regulatory_obligations","compliance_gaps","user_stories","systems_in_scope"):
        n = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
        print(f"  {t:<30} {n:>6}")
    print("──────────────────────────────────────────────────────────────\n")
    con.close()


if __name__ == "__main__":
    build()
