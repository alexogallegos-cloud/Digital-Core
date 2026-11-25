#!/usr/bin/env python3
"""
brain.py — Agent API del brain del BUS
BanCoppel Application Modernization · SPE-AM-001

Interfaz estandar de 5 metodos (Regla B1 · AM):
  coverage()           — estado del brain
  components(...)      — servicios expuestos por el bus
  search(query)        — busqueda fulltext
  rules(component_id)  — reglas de ruteo: que procedure del core resuelve cada servicio
  domains()            — datasources del core alcanzados

Metodos propios:
  core_calls()         — stored procedures invocados, con su cruce contra el core
  origins()            — sistemas origen, ya clasificados
  errors()             — firmas de error mas frecuentes
  hourly()             — volumetria por hora
  unconfirmed()        — procedures que el bus invoca y el brain del core no conoce

Uso:
  python brain.py
  python brain.py search "huella"
  python brain.py rules Caja2
"""

import json
import sqlite3
import sys
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / "brain.db"


class BusBrain:
    """Brain del bus de servicios empresarial. Autosuficiente (Regla B1)."""

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
            "system": "bus",
            "product": self._one("SELECT product FROM system_info"),
            "brain_version": self._one("SELECT brain_version FROM system_info"),
            "built_at": self._one("SELECT built_at FROM system_info"),
            "trazas_observadas": self._one("SELECT SUM(traces) FROM log_batches"),
            "servicios": self._one("SELECT COUNT(DISTINCT service) FROM services"),
            "operaciones": self._one("SELECT COUNT(DISTINCT operation) FROM operations"),
            "stored_procedures_core": self._one(
                "SELECT COUNT(*) FROM (SELECT DISTINCT datasource, sp_name FROM informix_sp_calls)"),
            "procedures_confirmados_en_el_core": self._one(
                "SELECT COUNT(*) FROM (SELECT DISTINCT datasource, sp_name "
                "FROM informix_sp_calls WHERE exists_in_core=1)"),
            "pares_servicio_procedure": self._one(
                "SELECT COUNT(*) FROM (SELECT DISTINCT service, datasource, sp_name FROM service_sp_map)"),
            "sistemas_origen_reales": self._one(
                "SELECT COUNT(DISTINCT family) FROM origin_systems WHERE class='sistema'"),
            "capabilities_etb_cubiertas": self._one(
                "SELECT COUNT(*) FROM etb_l3 WHERE bcop_status IN ('COVERED','CROSS_CUTTING')"),
            "lotes_de_evidencia": self._rows(
                "SELECT batch, traces, errors, error_pct, window_start, window_end, files "
                "FROM log_batches ORDER BY batch"),
        }

    def components(self, limit=40):
        """Servicios expuestos por el bus."""
        return self._rows("""
            SELECT service, SUM(calls) AS calls, SUM(errors) AS errors,
                   ROUND(100.0*SUM(errors)/NULLIF(SUM(calls),0), 2) AS error_pct,
                   (SELECT COUNT(DISTINCT sp_name) FROM service_sp_map m
                     WHERE m.service = s.service) AS procedures
            FROM services s GROUP BY service ORDER BY calls DESC LIMIT ?""", (limit,))

    def search(self, query, limit=25):
        return self._rows(
            "SELECT kind, key, text FROM knowledge_fts WHERE knowledge_fts MATCH ? LIMIT ?",
            (query, limit))

    def rules(self, component_id=None, limit=120):
        """
        Reglas de ruteo: que stored procedure del core resuelve cada servicio.
        Es el contrato que la modernizacion tiene que preservar.
        """
        sql = ("SELECT service, datasource, sp_name, SUM(calls) AS calls "
               "FROM service_sp_map")
        params = ()
        if component_id:
            sql += " WHERE service = ?"
            params = (component_id,)
        sql += " GROUP BY service, datasource, sp_name ORDER BY calls DESC LIMIT ?"
        return [{
            "tipo": "ruteo",
            "servicio": r["service"],
            "resuelve_en": f"{r['datasource']}.{r['sp_name']}" if r["datasource"] else r["sp_name"],
            "llamadas": r["calls"],
        } for r in self._rows(sql, params + (limit,))]

    def domains(self):
        """Datasources del core alcanzados, que son las bases de Informix."""
        return self._rows("""
            SELECT datasource AS domain, MAX(description) AS description,
                   SUM(calls) AS calls, MAX(sp_count) AS procedures
            FROM datasources GROUP BY datasource ORDER BY calls DESC""")

    # ── Propios ──────────────────────────────────────────────────

    def core_calls(self, limit=40):
        return self._rows("""
            SELECT datasource, sp_name, SUM(calls) AS calls, SUM(errors) AS errors,
                   MAX(exists_in_core) AS exists_in_core, MAX(core_db) AS core_db,
                   MAX(core_domain) AS core_domain, MAX(core_fan_in) AS core_fan_in,
                   MAX(core_biz) AS core_biz
            FROM informix_sp_calls GROUP BY datasource, sp_name
            ORDER BY calls DESC LIMIT ?""", (limit,))

    def unconfirmed(self, limit=40):
        """Procedures que el bus invoca y el brain del core no reconoce."""
        return self._rows("""
            SELECT datasource, sp_name, SUM(calls) AS calls FROM informix_sp_calls
            WHERE exists_in_core = 0 GROUP BY datasource, sp_name
            ORDER BY calls DESC LIMIT ?""", (limit,))

    def origins(self, solo_sistemas=True, limit=40):
        """
        Sistemas origen. El campo viene sin disciplina, asi que se devuelve
        clasificado: solo la clase 'sistema' es un inventario confiable.
        """
        sql = ("SELECT family, MAX(class) AS class, SUM(calls) AS calls, "
               "       SUM(errors) AS errors FROM origin_systems")
        if solo_sistemas:
            sql += " WHERE class = 'sistema'"
        sql += " GROUP BY family ORDER BY calls DESC LIMIT ?"
        return self._rows(sql, (limit,))

    def errors(self, limit=20):
        return self._rows("""
            SELECT signature, MAX(service) AS service, SUM(occurrences) AS occurrences
            FROM error_signatures GROUP BY signature ORDER BY occurrences DESC LIMIT ?""",
            (limit,))

    def hourly(self):
        return self._rows("""
            SELECT hour, SUM(traces) AS traces, SUM(errors) AS errors,
                   ROUND(100.0*SUM(errors)/NULLIF(SUM(traces),0), 2) AS error_pct
            FROM hourly_volume GROUP BY hour ORDER BY hour""")


def main():
    brain = BusBrain()
    args = sys.argv[1:]
    if not args:
        print(json.dumps(brain.coverage(), ensure_ascii=False, indent=2))
        return
    cmd, resto = args[0], args[1:]
    salida = {
        "search": lambda: brain.search(" ".join(resto)),
        "components": brain.components,
        "rules": lambda: brain.rules(resto[0] if resto else None),
        "domains": brain.domains,
        "core": brain.core_calls,
        "unconfirmed": brain.unconfirmed,
        "origins": brain.origins,
        "errors": brain.errors,
        "hourly": brain.hourly,
    }.get(cmd)
    if not salida:
        print(f"comando desconocido: {cmd}")
        return 1
    print(json.dumps(salida(), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    sys.exit(main() or 0)
