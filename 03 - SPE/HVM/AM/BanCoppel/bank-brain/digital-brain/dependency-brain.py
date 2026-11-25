#!/usr/bin/env python3
"""
dependency-brain.py — Agent API del brain de dependencias de la flota
BanCoppel Application Modernization · SPE-AM-001

Interfaz estandar de 5 metodos (Regla B1 · AM):
  coverage()            — estado del grafo
  components(...)       — los sistemas del ecosistema como nodos
  search(query)         — busqueda fulltext sobre las afirmaciones
  rules(component_id)   — las invariantes del grafo y quien las rompe
  domains()             — reparto por tipo TOGAF

Metodos propios:
  graph(...)            — el grafo deduplicado, un par por fila
  neighbors(system)     — de quien depende un sistema y quien depende de el
  evidence(source,target) — todas las afirmaciones sobre un par, con procedencia
  conflicts()           — donde dos fuentes no coinciden
  orphans()             — sistemas citados que no tienen carpeta (Regla B9)
  silent()              — brains que existen y no declaran ninguna dependencia
  catalog(system)       — las 211 interfaces del Anexo 5, la capa fina sin resumir
  catalog_gaps()        — apps del Anexo 5 que el grafo no modela como sistema

Uso:
  python dependency-brain.py
  python dependency-brain.py neighbors informix
  python dependency-brain.py evidence siweb informix
  python dependency-brain.py conflicts
"""

import json
import sqlite3
import sys
from pathlib import Path

# El catalogo trae acentos; sin esto la consola de Windows los rompe al salir.
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DB_PATH = Path(__file__).resolve().parent / "bank-brain.db"


class DependencyBrain:
    """Vista global de dependencias. Cada brain declara su lado; este agrega."""

    def __init__(self, db_path=DB_PATH):
        self.con = sqlite3.connect(str(db_path))
        self.con.row_factory = sqlite3.Row

    def _rows(self, sql, params=()):
        return [dict(r) for r in self.con.execute(sql, params)]

    def _one(self, sql, params=()):
        r = self.con.execute(sql, params).fetchone()
        return r[0] if r else None

    # ── Interfaz estandar ────────────────────────────────────────

    def coverage(self):
        return {
            "system": "dependency-brain",
            "brain_version": json.loads(
                self._one("SELECT metadata FROM dep_signals LIMIT 1") or "{}").get("brain_version"),
            "built_at": self._one("SELECT seeded_at FROM dep_signals LIMIT 1"),
            "nodos": self._one("SELECT COUNT(*) FROM dep_nodes"),
            "nodos_con_carpeta": self._one("SELECT COUNT(*) FROM dep_nodes WHERE folder IS NOT NULL"),
            "nodos_con_brain": self._one("SELECT COUNT(*) FROM dep_nodes WHERE has_brain = 1"),
            "brains_maduros": self._one("SELECT COUNT(*) FROM dep_nodes WHERE brain_kind = 'maduro'"),
            "brains_semilla": self._one("SELECT COUNT(*) FROM dep_nodes WHERE brain_kind = 'seed'"),
            "afirmaciones": self._one("SELECT COUNT(*) FROM dep_edges"),
            "pares": self._one("SELECT COUNT(*) FROM dep_graph"),
            "pares_bidireccionales": self._one("SELECT COUNT(*) FROM dep_graph WHERE bidireccional = 1"),
            "pares_con_varias_fuentes": self._one("SELECT COUNT(*) FROM dep_graph WHERE fuentes > 1"),
            "pares_direccion_inferida": self._one(
                "SELECT COUNT(*) FROM dep_graph WHERE dir_confianza = 'inferida'"),
            "pares_direccion_reorientada": self._one(
                "SELECT COUNT(DISTINCT source || '>' || target) FROM dep_edges "
                "WHERE reorientada = 1"),
            "conflictos": self._one("SELECT COUNT(*) FROM dep_conflicts"),
            "huerfanos": self._one("SELECT COUNT(*) FROM dep_orphans"),
            "catalogo_interfaces": self._one("SELECT COUNT(*) FROM dep_catalog"),
            "catalogo_mapeadas_a_sistemas": self._one(
                "SELECT COUNT(*) FROM dep_catalog WHERE mapeada = 1"),
            "catalogo_apps_sin_nodo": len(self.catalog_gaps()),
            "fuentes": self._rows(
                "SELECT origin AS fuente, COUNT(*) AS afirmaciones FROM dep_edges "
                "GROUP BY origin ORDER BY afirmaciones DESC"),
            "nota": ("Una afirmacion no es un hecho: es lo que un brain dice. El grafo las "
                     "contrasta y marca donde no coinciden en vez de elegir por su cuenta."),
        }

    def components(self, category=None, limit=100):
        """Los sistemas del ecosistema. `category` filtra por tipo TOGAF."""
        sql = ("SELECT id, display_name, togaf_type, togaf_state, brain_kind, "
               "       declara, citado_por, folder FROM dep_nodes")
        params = ()
        if category:
            sql += " WHERE togaf_type = ?"
            params = (category,)
        return self._rows(sql + " ORDER BY citado_por DESC, id LIMIT ?", params + (limit,))

    def search(self, query, limit=30):
        try:
            return self._rows(
                "SELECT id, source, target, relationship, description FROM dep_edges_fts "
                "WHERE dep_edges_fts MATCH ? LIMIT ?", (query, limit))
        except sqlite3.OperationalError:
            return []

    def rules(self, component_id=None, limit=200):
        """Las invariantes que el grafo puede verificar, con quien las rompe.

        No son reglas de negocio: son reglas del ecosistema, las Reglas B de AM
        traducidas a algo medible sobre el grafo.
        """
        invariantes = [
            ("B9", "Todo sistema citado por otro brain tiene carpeta propia",
             "SELECT id AS incumple, citado_por AS detalle FROM dep_orphans"),
            ("B10", "La relacion se declara en los dos extremos",
             "SELECT source || ' -> ' || target AS incumple, declarers AS detalle "
             "FROM dep_graph WHERE bidireccional = 0 AND fuentes = 1"),
            ("B11", "Un brain con dependencias declara al menos una",
             "SELECT id AS incumple, brain_kind AS detalle FROM dep_nodes "
             "WHERE has_brain = 1 AND declara = 0"),
            ("dir", "El sentido de la dependencia lo declara una fuente primaria",
             "SELECT source || ' -> ' || target AS incumple, declarers AS detalle "
             "FROM dep_graph WHERE dir_confianza = 'inferida'"),
            ("voz", "Dos fuentes no se contradicen sobre el mismo par",
             "SELECT source || ' -> ' || target AS incumple, detalle FROM dep_conflicts "
             "WHERE tipo IN ('relacion','criticidad','direccion')"),
        ]
        salida = []
        for clave, enunciado, sql in invariantes:
            incumplen = self._rows(sql)
            if component_id:
                incumplen = [i for i in incumplen if component_id in str(i.get("incumple", ""))]
            salida.append({
                "regla": clave, "enunciado": enunciado,
                "incumplen": len(incumplen), "detalle": incumplen[:limit],
            })
        return salida

    def domains(self):
        return self._rows(
            "SELECT togaf_type AS domain, COUNT(*) AS sistemas, "
            "       SUM(has_brain) AS con_brain, SUM(declara) AS afirmaciones "
            "FROM dep_nodes GROUP BY togaf_type ORDER BY sistemas DESC")

    # ── Metodos propios ──────────────────────────────────────────

    def graph(self, criticality=None, limit=200):
        sql = ("SELECT source, target, rel_norm, criticality, fuentes, declarers, "
               "       bidireccional, dir_confianza, conflicto FROM dep_graph")
        params = ()
        if criticality:
            sql += " WHERE criticality = ?"
            params = (criticality,)
        return self._rows(sql + " ORDER BY fuentes DESC, source LIMIT ?", params + (limit,))

    def neighbors(self, system):
        s = system.lower()
        return {
            "sistema": s,
            "depende_de": self._rows(
                "SELECT target AS sistema, rel_norm, criticality, fuentes, dir_confianza "
                "FROM dep_graph WHERE source = ? ORDER BY target", (s,)),
            "dependen_de_el": self._rows(
                "SELECT source AS sistema, rel_norm, criticality, fuentes, dir_confianza "
                "FROM dep_graph WHERE target = ? ORDER BY source", (s,)),
        }

    def evidence(self, source, target):
        """Todas las afirmaciones sobre un par, con quien las hizo y desde donde."""
        return self._rows(
            "SELECT declared_by, origin, relationship, criticality, dir_declarada, "
            "       primaria, reorientada, orientada_por, description, evidence, artifact "
            "FROM dep_edges WHERE source = ? AND target = ? "
            "ORDER BY primaria DESC, declared_by",
            (source.lower(), target.lower()))

    def conflicts(self):
        return self._rows("SELECT * FROM dep_conflicts ORDER BY tipo, source")

    def orphans(self):
        return self._rows("SELECT * FROM dep_orphans ORDER BY veces DESC, id")

    def catalog(self, system=None, limit=250):
        """Las interfaces del Anexo 5. `system` filtra por nodo del grafo.

        Es la capa fina: 211 interfaces entre 129 aplicaciones, con protocolo,
        sincronia y confianza por fila. El grafo de sistemas la resume; aqui
        esta sin resumir.
        """
        sql = ("SELECT id, origen_app, destino_app, tipo, sincronia, entidad, "
               "       confianza, documento, source, target, mapeada FROM dep_catalog")
        params = ()
        if system:
            sql += " WHERE source = ? OR target = ?"
            params = (system.lower(), system.lower())
        return self._rows(sql + " ORDER BY id LIMIT ?", params + (limit,))

    def catalog_gaps(self, limit=200):
        """Aplicaciones del Anexo 5 que el grafo no modela como sistema.

        No son huerfanos de Regla B9: nadie las declaro desde un brain. Son la
        distancia entre el mapa de sistemas y el mapa de aplicaciones, ordenada
        por cuantas interfaces toca cada una. Las de arriba son las que mas
        caro cuesta no tener.
        """
        return self._rows(
            "SELECT app, SUM(veces) AS interfaces, "
            "       SUM(como_origen) AS como_origen, SUM(como_destino) AS como_destino FROM ("
            "  SELECT origen_app AS app, COUNT(*) AS veces, COUNT(*) AS como_origen, "
            "         0 AS como_destino FROM dep_catalog WHERE source IS NULL "
            "  GROUP BY origen_app"
            "  UNION ALL "
            "  SELECT destino_app AS app, COUNT(*) AS veces, 0 AS como_origen, "
            "         COUNT(*) AS como_destino FROM dep_catalog WHERE target IS NULL "
            "  GROUP BY destino_app"
            ") GROUP BY app ORDER BY interfaces DESC, app LIMIT ?", (limit,))

    def silent(self):
        """Brains que existen y no declaran una sola dependencia."""
        return self._rows(
            "SELECT id, folder, brain_kind FROM dep_nodes "
            "WHERE has_brain = 1 AND declara = 0 ORDER BY id")


def main():
    brain = DependencyBrain()
    args = sys.argv[1:]
    if not args:
        print(json.dumps(brain.coverage(), ensure_ascii=False, indent=2))
        return
    cmd, resto = args[0], args[1:]
    salida = {
        "coverage": brain.coverage,
        "components": lambda: brain.components(resto[0] if resto else None),
        "search": lambda: brain.search(" ".join(resto)),
        "rules": lambda: brain.rules(resto[0] if resto else None),
        "domains": brain.domains,
        "graph": lambda: brain.graph(resto[0] if resto else None),
        "neighbors": lambda: brain.neighbors(resto[0]) if resto else {"error": "falta el sistema"},
        "evidence": lambda: brain.evidence(*resto[:2]) if len(resto) == 2
                            else {"error": "faltan source y target"},
        "conflicts": brain.conflicts,
        "orphans": brain.orphans,
        "silent": brain.silent,
        "catalog": lambda: brain.catalog(resto[0] if resto else None),
        "gaps": brain.catalog_gaps,
    }.get(cmd)
    if not salida:
        print(f"comando desconocido: {cmd}")
        return 1
    print(json.dumps(salida(), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    sys.exit(main() or 0)
