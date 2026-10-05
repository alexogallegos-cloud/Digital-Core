"""
CANBrain — Santander México
Agent API para consultas sobre el proyecto de cumplimiento CAN.

Uso:
    python brain.py status
    python brain.py obligations [--rol ACREEDORA|DEPOSITARIA|AMBAS]
    python brain.py brechas [--criticidad CRITICA|ALTA]
    python brain.py stories
    python brain.py adrs
    python brain.py search <query>
"""

import sqlite3
import json
import os
import sys

DB_PATH = os.path.join(os.path.dirname(__file__), "brain.db")


class CANBrain:
    def __init__(self, db_path: str = DB_PATH):
        self.db_path = db_path

    def _con(self):
        return sqlite3.connect(self.db_path)

    # ------------------------------------------------------------------
    # Interfaz estándar (5 métodos)
    # ------------------------------------------------------------------

    def coverage(self) -> dict:
        con = self._con()
        cur = con.cursor()
        meta = dict(cur.execute("SELECT key, value FROM brain_meta").fetchall())
        obl_total = cur.execute("SELECT COUNT(*) FROM obligations").fetchone()[0]
        obl_criticas = cur.execute("SELECT COUNT(*) FROM obligations WHERE riesgo_sancion='critico'").fetchone()[0]
        brechas_abiertas = cur.execute("SELECT COUNT(*) FROM brechas WHERE estado='ABIERTA'").fetchone()[0]
        brechas_criticas = cur.execute(
            "SELECT COUNT(*) FROM brechas WHERE criticidad='CRITICA' AND estado='ABIERTA'"
        ).fetchone()[0]
        us_total = cur.execute("SELECT COUNT(*) FROM user_stories").fetchone()[0]
        adrs_total = cur.execute("SELECT COUNT(*) FROM adrs").fetchone()[0]
        con.close()
        return {
            **meta,
            "obligations_total": obl_total,
            "obligations_criticas": obl_criticas,
            "brechas_abiertas": brechas_abiertas,
            "brechas_criticas": brechas_criticas,
            "user_stories": us_total,
            "adrs": adrs_total,
        }

    def components(self, sistema: str = None) -> list:
        """User Stories filtradas por sistema (equivalente a 'components' en brains de sistemas)."""
        con = self._con()
        cur = con.cursor()
        if sistema:
            rows = cur.execute(
                "SELECT id, titulo, sistema_slug, estimacion, estado FROM user_stories WHERE sistema_slug LIKE ?",
                (f"%{sistema}%",)
            ).fetchall()
        else:
            rows = cur.execute(
                "SELECT id, titulo, sistema_slug, estimacion, estado FROM user_stories"
            ).fetchall()
        con.close()
        return [{"id": r[0], "titulo": r[1], "sistema": r[2], "estimacion": r[3], "estado": r[4]} for r in rows]

    def search(self, query: str) -> list:
        con = self._con()
        cur = con.cursor()
        results = []
        obl = cur.execute(
            "SELECT id, descripcion, riesgo_sancion FROM obligations_fts WHERE obligations_fts MATCH ? LIMIT 10",
            (query,)
        ).fetchall()
        for r in obl:
            results.append({"type": "obligation", "id": r[0], "descripcion": r[1], "riesgo": r[2]})
        brechas = cur.execute(
            "SELECT id, descripcion, criticidad FROM brechas_fts WHERE brechas_fts MATCH ? LIMIT 10",
            (query,)
        ).fetchall()
        for r in brechas:
            results.append({"type": "brecha", "id": r[0], "descripcion": r[1], "criticidad": r[2]})
        con.close()
        return results

    def rules(self, obligation_id: str) -> list:
        """Retorna impacto en sistemas para una obligación dada."""
        con = self._con()
        cur = con.cursor()
        rows = cur.execute(
            "SELECT sistema_slug, tipo_impacto, descripcion, estimacion_us FROM systems_impact WHERE obligation_id = ?",
            (obligation_id,)
        ).fetchall()
        con.close()
        return [{"sistema": r[0], "tipo": r[1], "descripcion": r[2], "estimacion": r[3]} for r in rows]

    def domains(self) -> list:
        """Retorna distribución de obligaciones por rol (Acreedora / Depositaria / Ambas)."""
        con = self._con()
        cur = con.cursor()
        rows = cur.execute(
            "SELECT rol_aplicable, COUNT(*) FROM obligations GROUP BY rol_aplicable"
        ).fetchall()
        con.close()
        return [{"rol": r[0], "obligaciones": r[1]} for r in rows]

    # ------------------------------------------------------------------
    # Métodos CAN-específicos
    # ------------------------------------------------------------------

    def obligations(self, rol: str = None, riesgo: str = None) -> list:
        con = self._con()
        cur = con.cursor()
        q = "SELECT id, articulo, descripcion, tipo, frecuencia, riesgo_sancion, plazo_dhb, rol_aplicable, estado FROM obligations WHERE 1=1"
        params = []
        if rol:
            q += " AND rol_aplicable = ?"
            params.append(rol.upper())
        if riesgo:
            q += " AND riesgo_sancion = ?"
            params.append(riesgo.lower())
        q += " ORDER BY id"
        rows = cur.execute(q, params).fetchall()
        con.close()
        return [
            {"id": r[0], "articulo": r[1], "descripcion": r[2], "tipo": r[3],
             "frecuencia": r[4], "riesgo_sancion": r[5], "plazo_dhb": r[6],
             "rol_aplicable": r[7], "estado": r[8]}
            for r in rows
        ]

    def brechas(self, criticidad: str = None) -> list:
        con = self._con()
        cur = con.cursor()
        q = "SELECT id, obligation_id, criticidad, descripcion, sistema_afectado, capacidad_faltante, user_story_id, estado FROM brechas WHERE estado='ABIERTA'"
        params = []
        if criticidad:
            q += " AND criticidad = ?"
            params.append(criticidad.upper())
        q += " ORDER BY CASE criticidad WHEN 'CRITICA' THEN 1 WHEN 'ALTA' THEN 2 WHEN 'MEDIA' THEN 3 ELSE 4 END"
        rows = cur.execute(q, params).fetchall()
        con.close()
        return [
            {"id": r[0], "obligacion": r[1], "criticidad": r[2], "descripcion": r[3],
             "sistema": r[4], "capacidad_faltante": r[5], "user_story": r[6], "estado": r[7]}
            for r in rows
        ]

    def user_stories(self, sistema: str = None) -> list:
        con = self._con()
        cur = con.cursor()
        q = "SELECT id, titulo, obligation_id, sistema_slug, estimacion, brecha_id, estado FROM user_stories WHERE 1=1"
        params = []
        if sistema:
            q += " AND sistema_slug LIKE ?"
            params.append(f"%{sistema}%")
        q += " ORDER BY id"
        rows = cur.execute(q, params).fetchall()
        con.close()
        return [
            {"id": r[0], "titulo": r[1], "obligacion": r[2], "sistema": r[3],
             "estimacion": r[4], "brecha": r[5], "estado": r[6]}
            for r in rows
        ]

    def adrs(self) -> list:
        con = self._con()
        cur = con.cursor()
        rows = cur.execute(
            "SELECT id, titulo, decision, estado FROM adrs ORDER BY id"
        ).fetchall()
        con.close()
        return [{"id": r[0], "titulo": r[1], "decision": r[2], "estado": r[3]} for r in rows]

    def sla_criticos(self) -> list:
        """Obligaciones con plazo DHB regulatorio — las más tiempo-sensibles."""
        con = self._con()
        cur = con.cursor()
        rows = cur.execute(
            "SELECT id, articulo, descripcion, plazo_dhb, riesgo_sancion FROM obligations WHERE plazo_dhb IS NOT NULL ORDER BY plazo_dhb"
        ).fetchall()
        con.close()
        return [
            {"id": r[0], "articulo": r[1], "descripcion": r[2], "plazo_dhb": r[3], "riesgo": r[4]}
            for r in rows
        ]


# ------------------------------------------------------------------
# CLI
# ------------------------------------------------------------------

def main():
    brain = CANBrain()

    if not os.path.exists(DB_PATH):
        print("brain.db no encontrado. Ejecuta primero: python build-brain.py")
        sys.exit(1)

    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"

    if cmd == "status":
        print(json.dumps(brain.coverage(), indent=2, ensure_ascii=False))

    elif cmd == "obligations":
        rol = None
        riesgo = None
        for i, arg in enumerate(sys.argv[2:], 2):
            if arg == "--rol" and i + 1 < len(sys.argv):
                rol = sys.argv[i + 1]
            if arg == "--riesgo" and i + 1 < len(sys.argv):
                riesgo = sys.argv[i + 1]
        print(json.dumps(brain.obligations(rol=rol, riesgo=riesgo), indent=2, ensure_ascii=False))

    elif cmd == "brechas":
        criticidad = None
        for i, arg in enumerate(sys.argv[2:], 2):
            if arg == "--criticidad" and i + 1 < len(sys.argv):
                criticidad = sys.argv[i + 1]
        print(json.dumps(brain.brechas(criticidad=criticidad), indent=2, ensure_ascii=False))

    elif cmd == "stories":
        sistema = sys.argv[2] if len(sys.argv) > 2 else None
        print(json.dumps(brain.user_stories(sistema=sistema), indent=2, ensure_ascii=False))

    elif cmd == "adrs":
        print(json.dumps(brain.adrs(), indent=2, ensure_ascii=False))

    elif cmd == "sla":
        print(json.dumps(brain.sla_criticos(), indent=2, ensure_ascii=False))

    elif cmd == "search":
        query = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else ""
        print(json.dumps(brain.search(query), indent=2, ensure_ascii=False))

    elif cmd == "domains":
        print(json.dumps(brain.domains(), indent=2, ensure_ascii=False))

    else:
        print(f"Comando desconocido: {cmd}")
        print("Uso: python brain.py [status|obligations|brechas|stories|adrs|sla|search|domains]")
        sys.exit(1)


if __name__ == "__main__":
    main()
