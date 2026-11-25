#!/usr/bin/env python3
"""
brain.py — Agent API del brain de SIWEB
BanCoppel Application Modernization · SPE-AM-001

Interfaz estandar de 5 metodos (Regla B1 · AM):
  coverage()            — estado del brain
  components(...)       — operaciones de core que el canal sabe pedir
  search(query)         — busqueda fulltext
  rules(component_id)   — reglas de negocio del canal
  domains()             — areas funcionales de la ventanilla

Metodos propios del sistema:
  modules()             — modulos Maven del reactor CPlaSu
  core_bridges()        — un DAO por base de datos alcanzada a traves del BUS
  endpoints(...)        — URLs del canal y el controlador que las publica
  views(area)           — pantallas FXML de ventanilla
  legacy_sps()          — enums EXECUTE PROCEDURE heredados, con su estado de uso
  findings()            — lo que el brain detecto y nadie ha resuelto
  dependencies()        — cross-dependencies declaradas, propias y sembradas

Uso:
  python brain.py                       # resumen
  python brain.py search "huella"
  python brain.py components BDINTEG
  python brain.py findings
"""

import json
import sqlite3
import sys
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / "brain.db"

# Bases que el DAO alcanza pero que no son bases Informix del core bancario.
NO_CORE = ("AIDABAN", "COPPEL", "INTERAPI")


class SiwebBrain:
    """Brain del canal de sucursal, ventanilla y caja. Autosuficiente (Regla B1)."""

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
        """Estado del brain: que sabe y sobre que evidencia."""
        return {
            "system": "siweb",
            "display_name": self._one("SELECT display_name FROM system_info"),
            "brain_version": self._one("SELECT brain_version FROM system_info"),
            "built_at": self._one("SELECT built_at FROM system_info"),
            "togaf_state": self._one("SELECT togaf_state FROM system_info"),
            "vendor": self._one("SELECT vendor FROM system_info"),
            "stack_confirmado": self._one("SELECT stack_confirmado FROM system_info"),
            "source_snapshot": self._one("SELECT source_snapshot FROM system_info"),
            "modulos_maven": self._one("SELECT COUNT(*) FROM modules"),
            "archivos_java": self._one("SELECT MAX(java_files) FROM modules"),
            "servicios_de_core": self._one("SELECT COUNT(*) FROM ws_services"),
            "servicios_invocados": self._one("SELECT COUNT(*) FROM ws_services WHERE usages > 0"),
            "puentes_de_datos": self._one("SELECT COUNT(*) FROM core_bridges"),
            "bases_del_core": self._one(
                f"SELECT COUNT(*) FROM core_bridges WHERE db_domain NOT IN {NO_CORE}"),
            "endpoints": self._one("SELECT COUNT(*) FROM endpoints"),
            "endpoints_publicados": self._one(
                "SELECT COUNT(*) FROM endpoints WHERE controller IS NOT NULL"),
            "pantallas": self._one("SELECT COUNT(*) FROM views"),
            "areas_funcionales": self._one("SELECT COUNT(DISTINCT area) FROM views"),
            "sps_heredados": self._one("SELECT COUNT(*) FROM sp_calls"),
            "sps_heredados_en_uso": self._one(
                "SELECT COUNT(*) FROM sp_calls WHERE status = 'en-uso'"),
            "reglas_de_negocio": self._one("SELECT COUNT(*) FROM rules")
                                 if self._tabla("rules") else 0,
            "cross_dependencies": self._one("SELECT COUNT(*) FROM cross_dependencies"),
            "nota": ("El canal no invoca stored procedures: pide operaciones al BUS por "
                     "identificador de web service. La unidad de dependencia contra el core "
                     "es el servicio, no el SP."),
        }

    def _tabla(self, nombre):
        return bool(self._one(
            "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=?", (nombre,)))

    def components(self, category=None, limit=50):
        """Operaciones de core que el canal sabe pedir. `category` filtra por base
        de datos destino o por seccion funcional del catalogo."""
        sql = ("SELECT s.constant AS servicio, s.ws_id AS numero, s.functional_group AS seccion, "
               "       s.usages AS invocaciones, "
               "       (SELECT GROUP_CONCAT(DISTINCT u.db_domain) FROM ws_usages u "
               "        WHERE u.constant = s.constant) AS bases "
               "FROM ws_services s")
        params = ()
        if category:
            sql += (" WHERE s.functional_group = ? OR s.constant IN "
                    "(SELECT constant FROM ws_usages WHERE db_domain = ?)")
            params = (category, category.upper())
        sql += " ORDER BY s.usages DESC, s.constant LIMIT ?"
        return self._rows(sql, params + (limit,))

    def search(self, query, limit=25):
        """Busqueda fulltext sobre servicios, endpoints, SPs heredados y dependencias."""
        salida = []
        consultas = [
            ("servicio", "SELECT constant AS key, constant || ' — ' || "
                         "COALESCE(functional_group,'') AS text FROM ws_services_fts "
                         "WHERE ws_services_fts MATCH ? LIMIT ?"),
            ("endpoint", "SELECT constant AS key, COALESCE(url,'') || ' — ' || "
                         "COALESCE(controller,'sin controlador') AS text FROM endpoints_fts "
                         "WHERE endpoints_fts MATCH ? LIMIT ?"),
            ("sp-heredado", "SELECT id AS key, db_name || ':' || sp_name AS text "
                            "FROM sp_calls_fts WHERE sp_calls_fts MATCH ? LIMIT ?"),
            ("dependencia", "SELECT id AS key, other_system || ' — ' || COALESCE(description,'') "
                            "AS text FROM cross_dependencies_fts "
                            "WHERE cross_dependencies_fts MATCH ? LIMIT ?"),
        ]
        for kind, sql in consultas:
            try:
                for r in self._rows(sql, (query, limit)):
                    salida.append({"kind": kind, "key": r["key"], "text": r["text"]})
            except sqlite3.OperationalError:
                continue
        return salida[:limit * 2]

    def rules(self, component_id=None, limit=200):
        """Reglas de negocio del canal.

        Todavia no hay extractor de reglas para SIWEB: el brain cubre estructura,
        dependencias y superficie, no logica. Devuelve una lista vacia en vez de
        inventar reglas, y `coverage()['reglas_de_negocio']` lo reporta como cero.
        """
        if not self._tabla("rules"):
            return []
        sql = "SELECT * FROM rules"
        params = ()
        if component_id:
            sql += " WHERE component_id = ?"
            params = (component_id,)
        return self._rows(sql + " LIMIT ?", params + (limit,))

    def domains(self):
        """Areas funcionales de la ventanilla, por numero de pantallas."""
        return self._rows(
            "SELECT area AS domain, COUNT(*) AS pantallas FROM views "
            "GROUP BY area ORDER BY pantallas DESC")

    # ── Metodos propios ──────────────────────────────────────────

    def modules(self):
        return self._rows(
            "SELECT id, artifact_id, packaging, java_files, role FROM modules "
            "ORDER BY java_files DESC")

    def core_bridges(self):
        """Un DAO por base de datos alcanzada a traves del BUS."""
        return self._rows(
            f"SELECT db_domain, dao_class, bean_name, ws_ids_used, methods, "
            f"       CASE WHEN db_domain IN {NO_CORE} THEN 0 ELSE 1 END AS core "
            f"FROM core_bridges ORDER BY ws_ids_used DESC")

    def endpoints(self, controller=None, limit=100):
        sql = "SELECT constant, url, http_method, controller FROM endpoints"
        params = ()
        if controller:
            sql += " WHERE controller LIKE ?"
            params = (f"%{controller}%",)
        return self._rows(sql + " ORDER BY constant LIMIT ?", params + (limit,))

    def views(self, area=None, limit=200):
        sql = "SELECT name, area, path FROM views"
        params = ()
        if area:
            sql += " WHERE area = ?"
            params = (area,)
        return self._rows(sql + " ORDER BY area, name LIMIT ?", params + (limit,))

    def legacy_sps(self):
        """Enums EXECUTE PROCEDURE heredados del acceso directo anterior al BUS."""
        return self._rows(
            "SELECT db_name, sp_name, constant, params, status FROM sp_calls "
            "ORDER BY db_name, sp_name")

    def findings(self):
        """Lo que el brain detecto y nadie ha resuelto todavia."""
        compartidos = self._rows(
            "SELECT ws_id, GROUP_CONCAT(constant, ', ') AS constantes "
            "FROM ws_services GROUP BY ws_id HAVING COUNT(*) > 1 ORDER BY ws_id")
        return [
            {"id": "SIWEB-F01",
             "hallazgo": "Identificadores de web service que comparten numero",
             "cuenta": len(compartidos),
             "detalle": compartidos[:20],
             "impacto": "El numero no es clave unica. El brain usa el nombre de la constante."},
            {"id": "SIWEB-F02",
             "hallazgo": "Servicios declarados que nunca se invocan",
             "cuenta": self._one("SELECT COUNT(*) FROM ws_services WHERE usages = 0"),
             "detalle": self._rows(
                 "SELECT constant, ws_id FROM ws_services WHERE usages = 0 ORDER BY constant"),
             "impacto": "Candidatos a catalogo muerto, a confirmar contra el registro del BUS."},
            {"id": "SIWEB-F03",
             "hallazgo": "URLs declaradas que ningun controlador publica",
             "cuenta": self._one("SELECT COUNT(*) FROM endpoints WHERE controller IS NULL"),
             "detalle": self._rows(
                 "SELECT constant, url FROM endpoints WHERE controller IS NULL "
                 "ORDER BY constant LIMIT 100"),
             "impacto": "Mismo patron que F02, del lado del canal."},
            {"id": "SIWEB-F04",
             "hallazgo": "Puentes de datos que no son bases del core bancario",
             "cuenta": len(NO_CORE),
             "detalle": self._rows(
                 f"SELECT db_domain, dao_class FROM core_bridges WHERE db_domain IN {NO_CORE}"),
             "impacto": "Hay que clasificarlos antes de leer el total de puentes como bases del core."},
            {"id": "SIWEB-F05",
             "hallazgo": "Los EXECUTE PROCEDURE heredados no estan en uso",
             "cuenta": self._one("SELECT COUNT(*) FROM sp_calls WHERE status != 'en-uso'"),
             "detalle": [],
             "impacto": "No leerlos como dependencia viva ni como inventario de SPs del canal."},
        ]

    def dependencies(self):
        """Cross-dependencies declaradas. `emitter` dice quien escribio cada fila."""
        return self._rows(
            "SELECT id, other_system, relationship, direction, criticality, "
            "       evidence_kind, emitter, description FROM cross_dependencies "
            "ORDER BY emitter, criticality, id")

    def seeds(self):
        """Seeds emitidos a los vecinos (Regla B11)."""
        manifest = Path(__file__).resolve().parent / "seeds" / "manifest.json"
        if not manifest.exists():
            return []
        return json.loads(manifest.read_text(encoding="utf-8")).get("seeds", [])


def main():
    brain = SiwebBrain()
    args = sys.argv[1:]
    if not args:
        print(json.dumps(brain.coverage(), ensure_ascii=False, indent=2))
        return
    cmd, resto = args[0], args[1:]
    salida = {
        "coverage": brain.coverage,
        "search": lambda: brain.search(" ".join(resto)),
        "components": lambda: brain.components(resto[0] if resto else None),
        "rules": lambda: brain.rules(resto[0] if resto else None),
        "domains": brain.domains,
        "modules": brain.modules,
        "bridges": brain.core_bridges,
        "endpoints": lambda: brain.endpoints(resto[0] if resto else None),
        "views": lambda: brain.views(resto[0] if resto else None),
        "legacy": brain.legacy_sps,
        "findings": brain.findings,
        "deps": brain.dependencies,
        "seeds": brain.seeds,
    }.get(cmd)
    if not salida:
        print(f"comando desconocido: {cmd}")
        return 1
    print(json.dumps(salida(), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    sys.exit(main() or 0)
