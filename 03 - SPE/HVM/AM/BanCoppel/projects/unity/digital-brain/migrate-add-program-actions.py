"""
migrate-add-program-actions.py  --  Unity brain.db · migración v1.2.0
Agrega las 8 acciones abiertas del Plan Director (corte 14-ago-2026) a raid_issues.
Extiende la tabla con columnas 'tracks' y 'breach' si aún no existen.

Uso:
    python migrate-add-program-actions.py
    python migrate-add-program-actions.py --dry-run
"""

import sqlite3, argparse
from pathlib import Path

DB_PATH = Path(__file__).parent / "brain.db"

DDL_ALTER = [
    "ALTER TABLE raid_issues ADD COLUMN tracks TEXT",
    "ALTER TABLE raid_issues ADD COLUMN breach INTEGER DEFAULT 0",
]

# 8 acciones identificadas por el equipo Plan Director — corte 14-ago-2026.
# #1 due 2026-08-18 → BREACH (hoy 2026-08-20)
# #2 due 2026-08-14 → BREACH
# #3 due 2026-08-14 → BREACH
# #5 due 2026-08-07 → BREACH (13 días en breach, el más urgente)
# #6 due 2026-08-17 → BREACH (3 días)
# #7 due 2026-08-14 → BREACH
# #4 due 2026-08-21 → abierto, vence mañana
# #8 due 2026-08-28 → abierto, 8 días
ACTIONS = [
    {
        "id": "ISSUE-R4-001",
        "raid_id": "ACT-001",
        "description": "Confirmar fechas de diseño técnico e implementación de integraciones por track (Apolo→SIWEB→CAT→SV, 2 HUs pendientes)",
        "component_id": None,
        "category": "integration",
        "severity": "critical",
        "current_impact": "Sin fechas confirmadas el plan SIT cross-track es inválido — ningún track puede arrancar pruebas de integración",
        "remediation": "Sesión técnica urgente con leads de cada track para cerrar calendario de integraciones antes de arrancar SIT",
        "status": "open",
        "owner": "Oscar Melo",
        "due_date": "2026-08-18",
        "tracks": "Apolo, SIWEB, CAT, SmartVista",
        "breach": 1,
        "source": "Plan Director — slide acciones críticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-18.",
    },
    {
        "id": "ISSUE-R4-002",
        "raid_id": "ACT-002",
        "description": "Mitigar desfase de 6 HUs Must APP con implementación planificada en noviembre — posterior al inicio de SIT",
        "component_id": None,
        "category": "scope",
        "severity": "critical",
        "current_impact": "6 HUs Must del canal App cierran después del inicio de SIT; comprometiendo UAT y go-live 15-ene-2027",
        "remediation": "(1) Incorporar en 2do tramo SIT, (2) agilizar entregas de diseño e incremento de capacidad de desarrollo, (3) revisar prioridad de estas HUs",
        "status": "open",
        "owner": "Diana Estrada",
        "due_date": "2026-08-14",
        "tracks": "App",
        "breach": 1,
        "source": "Plan Director — slide acciones críticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-14.",
    },
    {
        "id": "ISSUE-R4-003",
        "raid_id": "ACT-003",
        "description": "Formalizar la contratación del proveedor CAT — on-boarding agosto, implementación 15-sep, margen cero al 15-oct",
        "component_id": None,
        "category": "vendor",
        "severity": "critical",
        "current_impact": "Sin proveedor CAT contratado: 12 HUs Must y 6 integraciones sin owner técnico; bloquea SIT completo del canal Contact Center",
        "remediation": "Contratación inmediata para garantizar on-boarding en agosto e inicio de implementación al 15-sep",
        "status": "open",
        "owner": "Ramses Santos / Fernanda Barbosa",
        "due_date": "2026-08-14",
        "tracks": "CAT",
        "breach": 1,
        "source": "Plan Director — slide acciones críticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-14. Vinculado a RISK-UNITY-R27. Deadline duro: proveedor operativo al 15-oct.",
    },
    {
        "id": "ISSUE-R4-004",
        "raid_id": "ACT-004",
        "description": "Completar inventario de integraciones R4 y trazabilidad con Historias de Usuario para validar viabilidad del plan integrado",
        "component_id": None,
        "category": "planning",
        "severity": "critical",
        "current_impact": "Sin inventario de integraciones el análisis de prioridad y el plan SIT cross-track son parciales e inválidos",
        "remediation": "Completar mapeo HU↔integración↔sistema por track; confirmar que el plan integrado es viable",
        "status": "open",
        "owner": "Oscar Melo / Pablo Lorenzo (Accenture)",
        "due_date": "2026-08-21",
        "tracks": "Apolo, SIWEB, CAT, SmartVista",
        "breach": 0,
        "source": "Plan Director — slide acciones críticas 14-ago-2026",
        "notes": "Accenture co-owner del análisis. Base indispensable para el SIT cross-track.",
    },
    {
        "id": "ISSUE-R4-005",
        "raid_id": "ACT-005",
        "description": "Compartir y completar análisis del Track de Cobranza — HUs, integraciones y dependencias con canales",
        "component_id": None,
        "category": "scope",
        "severity": "critical",
        "current_impact": "Track Cobranza completamente opaco: 30-50 HUs estimadas sin compartir, dependencias hacia canales desconocidas — bloquea análisis de prioridad del programa",
        "remediation": "Compartir backlog Cobranza completo: HUs, integraciones, dependencias y plan de entrega",
        "status": "open",
        "owner": "Marksey Sanvicente",
        "due_date": "2026-08-07",
        "tracks": "Cobranza",
        "breach": 1,
        "source": "Plan Director — slide acciones críticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-07 — 13 días en breach. Sin este análisis el SIT integral es inviable.",
    },
    {
        "id": "ISSUE-R4-006",
        "raid_id": "ACT-006",
        "description": "Habilitar vía ejecutiva de decisiones en 24-48h para decisiones críticas R4 y seguimiento a hitos críticos",
        "component_id": None,
        "category": "governance",
        "severity": "critical",
        "current_impact": "Sin mecanismo ejecutivo de decisión rápida las decisiones de alcance, prioridad y recursos se escalan sin SLA — riesgo de parálisis en momentos críticos del SIT",
        "remediation": "Definir autoridad ejecutiva con capacidad de decidir sobre alcance y prioridades; incluir líderes de track, APIficación, ambientes, pruebas, despliegue y Director de Transformación",
        "status": "open",
        "owner": "Pablo Madinaveitia",
        "due_date": "2026-08-17",
        "tracks": "Todos los tracks",
        "breach": 1,
        "source": "Plan Director — slide acciones críticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-17 — 3 días en breach.",
    },
    {
        "id": "ISSUE-R4-007",
        "raid_id": "ACT-007",
        "description": "Confirmar escenarios de mitigación para Maquila Automatizada SmartVista — 5 DTMs con gap crítico sin plan de cierre",
        "component_id": None,
        "category": "delivery",
        "severity": "high",
        "current_impact": "DPP, BYU0039 y OCG sin plan de cierre; riesgo de no completar SIT SmartVista a tiempo para el go-live",
        "remediation": "(1) Reducir alcance a 1 proveedor, (2) optimizar proceso de certificación y gobierno de APIs, (3) excluir HUs Should, (4) ejecutar pruebas SIT en segundo ciclo",
        "status": "open",
        "owner": "Armando García",
        "due_date": "2026-08-14",
        "tracks": "SmartVista",
        "breach": 1,
        "source": "Plan Director — slide acciones críticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-14. 4 opciones de mitigación a confirmar — decisión afecta scope R4.",
    },
    {
        "id": "ISSUE-R4-008",
        "raid_id": "ACT-008",
        "description": "Definir e implementar estrategia de despliegue R4: runbook de actividades, simulacros DR completos incluyendo rollback",
        "component_id": None,
        "category": "release",
        "severity": "high",
        "current_impact": "Sin runbook de despliegue ni simulacros DR, el go-live bancario 15-ene-2027 tiene riesgo operativo alto ante incidentes en producción",
        "remediation": "Runbook de actividades + planificación de simulacros de despliegue completos (DRs) incluyendo rollback probado en STG",
        "status": "open",
        "owner": "Christian Zazueta",
        "due_date": "2026-08-28",
        "tracks": "Despliegue",
        "breach": 0,
        "source": "Plan Director — slide acciones críticas 14-ago-2026",
        "notes": "Prerequisito para SIT y UAT seguros. 8 días restantes al momento de carga.",
    },
]


def run(dry_run: bool = False):
    if not DB_PATH.exists():
        print(f"[ERROR] brain.db no encontrado en {DB_PATH}")
        return

    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row

    # Extender tabla con columnas nuevas (idempotente)
    for stmt in DDL_ALTER:
        col = stmt.split("ADD COLUMN")[1].strip().split()[0]
        exists = con.execute(
            "SELECT COUNT(*) FROM pragma_table_info('raid_issues') WHERE name=?", (col,)
        ).fetchone()[0]
        if not exists:
            if dry_run:
                print(f"[DRY-RUN] {stmt}")
            else:
                con.execute(stmt)
                print(f"  ALTER TABLE raid_issues ADD COLUMN {col} ✓")
        else:
            print(f"  Columna '{col}' ya existe — skip")

    # Insertar acciones
    cols = ("id","raid_id","description","component_id","category","severity",
            "current_impact","remediation","status","owner","due_date",
            "tracks","breach","source","notes")
    placeholders = ",".join("?" * len(cols))
    sql = f"INSERT OR REPLACE INTO raid_issues ({','.join(cols)}) VALUES ({placeholders})"

    if dry_run:
        for a in ACTIONS:
            print(f"[DRY-RUN] INSERT {a['id']} — {a['description'][:60]}...")
    else:
        for a in ACTIONS:
            con.execute(sql, [a.get(c) for c in cols])
        con.commit()
        print(f"\n  raid_issues: {len(ACTIONS)} acciones insertadas ✓")

    breach = sum(1 for a in ACTIONS if a["breach"])
    crit   = sum(1 for a in ACTIONS if a["severity"] == "critical")
    print(f"  Resumen: {len(ACTIONS)} acciones | {crit} críticas | {breach} en BREACH")
    con.close()


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()
    run(dry_run=args.dry_run)