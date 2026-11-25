#!/usr/bin/env python3
"""
brain.py — Agent API del brain de e-global
BanCoppel Application Modernization · SPE-AM-001

Interfaz estandar de 5 metodos (Regla B1 · AM):
  coverage()            — estado del brain
  components(...)       — funciones del autorizador
  search(query)         — busqueda fulltext
  rules(component_id)   — reglas de negocio (validaciones y traduccion de codigos)
  domains()             — categorias funcionales del autorizador

Metodos propios del sistema:
  transaction_mix()     — mezcla transaccional observada con tasa de aprobacion
  response_codes()      — codigos de respuesta ISO con su distribucion
  host_mapping()        — traduccion CodRet del core -> codigo ISO de la red
  core_calls()          — stored procedures de Informix invocados
  evidence()            — lotes de log que sustentan el conocimiento

Uso:
  python brain.py                       # resumen
  python brain.py search "fondos"
  python brain.py rules
"""

import json
import sqlite3
import sys
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / "brain.db"


class EGlobalBrain:
    """Brain del autorizador de pagos e-global. Autosuficiente (Regla B1)."""

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
        lote = self._rows(
            "SELECT batch, transactions, window_start, window_end, window_minutes, files "
            "FROM log_batches ORDER BY batch DESC")
        return {
            "system": "e-global",
            "brain_version": self._one("SELECT brain_version FROM system_info"),
            "built_at": self._one("SELECT built_at FROM system_info"),
            "transacciones_observadas": self._one("SELECT SUM(transactions) FROM log_batches"),
            "validaciones": self._one("SELECT COUNT(DISTINCT validation_id) FROM validations"),
            "funciones": self._one("SELECT COUNT(DISTINCT name) FROM authorizer_functions"),
            "tipos_transaccion": self._one("SELECT COUNT(DISTINCT label) FROM transaction_types"),
            "codigos_respuesta": self._one("SELECT COUNT(DISTINCT iso_rc) FROM response_codes"),
            # La base forma parte de la identidad del procedure
            "stored_procedures_core": self._one(
                "SELECT COUNT(*) FROM (SELECT DISTINCT sp_name, database FROM informix_sp_calls)"),
            "giros_de_negocio": self._one("SELECT COUNT(DISTINCT mcc) FROM merchant_categories"),
            "capabilities_etb_cubiertas": self._one(
                "SELECT COUNT(*) FROM etb_l3 WHERE bcop_status IN ('COVERED','CROSS_CUTTING')"),
            "etb_version": self._one("SELECT etb_version FROM etb_l3 LIMIT 1"),
            "lotes_de_evidencia": lote,
        }

    def components(self, category=None, limit=50):
        """
        Funciones del autorizador, las unidades que componen el sistema.
        Agrega los lotes de evidencia: la latencia media se pondera por volumen.
        """
        sql = ("SELECT name, category, SUM(invocations) AS invocations, "
               "       ROUND(AVG(calls_per_txn), 2) AS calls_per_txn, "
               "       ROUND(SUM(avg_ms * invocations) / NULLIF(SUM(invocations), 0), 2) AS avg_ms, "
               "       MAX(max_ms) AS max_ms, MAX(description) AS description "
               "FROM authorizer_functions")
        params = ()
        if category:
            sql += " WHERE category = ?"
            params = (category,)
        sql += " GROUP BY name, category ORDER BY invocations DESC LIMIT ?"
        return self._rows(sql, params + (limit,))

    def search(self, query, limit=25):
        """Busqueda fulltext sobre funciones, validaciones, codigos, SPs y capabilities."""
        return self._rows(
            "SELECT kind, key, text FROM knowledge_fts WHERE knowledge_fts MATCH ? LIMIT ?",
            (query, limit))

    def rules(self, component_id=None, limit=200):
        """
        Reglas de negocio del autorizador. Dos familias:
          - validacion: cada ID ejecutado en el ciclo de autorizacion
          - traduccion-codigo: como el codigo del core se convierte en respuesta ISO
        """
        total = self._one("SELECT SUM(transactions) FROM log_batches") or 1
        reglas = []
        sql = ("SELECT validation_id, SUM(executions) AS executions, "
               "       ROUND(SUM(avg_position * executions) / NULLIF(SUM(executions),0), 1) AS avg_position, "
               "       SUM(in_declined) AS in_declined, MAX(meaning) AS meaning "
               "FROM validations")
        params = ()
        if component_id:
            sql += " WHERE validation_id = ?"
            params = (component_id,)
        sql += " GROUP BY validation_id ORDER BY avg_position LIMIT ?"
        for r in self._rows(sql, params + (limit,)):
            reglas.append({
                "tipo": "validacion",
                "id": r["validation_id"],
                "ejecuciones": r["executions"],
                "cobertura_pct": round(100.0 * r["executions"] / total, 2),
                "posicion_media": r["avg_position"],
                "pct_en_rechazos": round(100.0 * (r["in_declined"] or 0) / r["executions"], 2)
                                   if r["executions"] else None,
                "significado": r["meaning"],
            })
        if not component_id:
            for r in self._rows(
                    "SELECT host_code, iso_rc, MAX(core_meaning) AS core_meaning, "
                    "       SUM(volume) AS volume FROM host_response_map "
                    "GROUP BY host_code, iso_rc ORDER BY volume DESC"):
                desc = self._one(
                    "SELECT MAX(description) FROM response_codes WHERE iso_rc = ?", (r["iso_rc"],))
                reglas.append({
                    "tipo": "traduccion-codigo",
                    "id": f"{r['host_code']}->{r['iso_rc']}",
                    "regla": f"El codigo {r['host_code']} del core se responde a la red como "
                             f"ISO {r['iso_rc']} ({desc})",
                    "significado_en_el_core": r["core_meaning"],
                    "ejecuciones": r["volume"],
                })
        return reglas

    def domains(self):
        """Categorias funcionales del autorizador."""
        return self._rows(
            "SELECT category AS domain, COUNT(DISTINCT name) AS funciones, "
            "       SUM(invocations) AS invocaciones "
            "FROM authorizer_functions GROUP BY category ORDER BY invocaciones DESC")

    # ── Metodos propios ──────────────────────────────────────────

    def transaction_mix(self):
        """Mezcla transaccional con tasa de aprobacion por tipo."""
        return self._rows("""
            SELECT label AS tipo,
                   SUM(volume) AS total,
                   SUM(CASE WHEN iso_rc = '00' THEN volume ELSE 0 END) AS aprobadas,
                   ROUND(100.0 * SUM(CASE WHEN iso_rc = '00' THEN volume ELSE 0 END)
                         / SUM(volume), 1) AS aprobacion_pct
            FROM transaction_outcomes GROUP BY label ORDER BY total DESC""")

    def response_codes(self):
        return self._rows("""
            SELECT iso_rc, MAX(description) AS description, SUM(volume) AS volume,
                   ROUND(100.0 * SUM(volume) / (SELECT SUM(volume) FROM response_codes), 2)
                     AS share_pct
            FROM response_codes GROUP BY iso_rc ORDER BY volume DESC""")

    def host_mapping(self):
        """Traduccion CodRet del core -> respuesta ISO, con el significado del core."""
        return self._rows("""
            SELECT h.host_code, MAX(h.core_meaning) AS core_meaning, h.iso_rc,
                   (SELECT MAX(description) FROM response_codes r WHERE r.iso_rc = h.iso_rc)
                     AS iso_description,
                   SUM(h.volume) AS volume, MAX(h.core_confidence) AS core_confidence
            FROM host_response_map h
            GROUP BY h.host_code, h.iso_rc ORDER BY volume DESC""")

    def core_calls(self):
        """Stored procedures del core invocados. La base es parte de la identidad."""
        return self._rows("""
            SELECT sp_name, database, SUM(invocations) AS invocations,
                   ROUND(AVG(calls_per_txn), 2) AS calls_per_txn
            FROM informix_sp_calls GROUP BY sp_name, database ORDER BY invocations DESC""")

    def evidence(self):
        return self._rows("SELECT * FROM log_batches ORDER BY batch DESC")


def main():
    brain = EGlobalBrain()
    args = sys.argv[1:]
    if not args:
        print(json.dumps(brain.coverage(), ensure_ascii=False, indent=2))
        return
    cmd, resto = args[0], args[1:]
    salida = {
        "search": lambda: brain.search(" ".join(resto)),
        "components": lambda: brain.components(resto[0] if resto else None),
        "rules": lambda: brain.rules(resto[0] if resto else None),
        "domains": brain.domains,
        "mix": brain.transaction_mix,
        "codes": brain.response_codes,
        "mapping": brain.host_mapping,
        "core": brain.core_calls,
        "evidence": brain.evidence,
    }.get(cmd)
    if not salida:
        print(f"comando desconocido: {cmd}")
        return 1
    print(json.dumps(salida(), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    sys.exit(main() or 0)
