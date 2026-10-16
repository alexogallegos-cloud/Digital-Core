# -*- coding: utf-8 -*-
"""Prueba funcional del ciclo de consulta, snapshot y autoevaluación.

Cada aserción tiene que poder fallar: se verifican tanto el camino feliz como
el que niega, y snapshot se prueba con una fecha en la que el hecho NO era
verdad todavía.
"""
import importlib.util
import os
import sqlite3
import sys
import tempfile
from pathlib import Path

ASSET = Path(sys.argv[1])
tmp = Path(tempfile.mkdtemp())
db = tmp / "brain.db"

c = sqlite3.connect(db)
c.executescript((ASSET / "templates" / "schema.sql").read_text(encoding="utf-8"))
c.execute("INSERT INTO system_info (slug, display_name, industry, brain_type, "
          "hemisphere, status) VALUES "
          "('prueba','Brain de prueba','banking','system','run','building')")
# dos afirmaciones con vigencias distintas, para que snapshot pueda discriminar
c.executemany(
    "INSERT INTO knowledge_lineage (entity_table, entity_id, tier, tier_basis, "
    "source_type, source_ref, valid_from, valid_to, recorded_at) "
    "VALUES (?,?,?,?,?,?,?,?,?)",
    [("rules", "R-1", "gold", "origin", "code", "sp_pago.spl:120",
      "2026-01-01", None, "2026-01-10"),
     ("rules", "R-2", "gold", "origin", "regulation", "Circ 6/2025",
      "2026-06-01", "2026-08-01", "2026-06-02")])
c.commit()
c.close()

spec = importlib.util.spec_from_file_location("brain", ASSET / "templates" / "brain.py")
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
Brain = next(v for k, v in vars(m).items()
             if isinstance(v, type) and hasattr(v, "coverage"))
b = Brain(str(db))

fallos = []


def ok(nombre, cond, detalle=""):
    print(f"  {'OK  ' if cond else 'FALLA'} {nombre}" + (f" — {detalle}" if detalle else ""))
    if not cond:
        fallos.append(nombre)


print("B40 · snapshot y latencia")
ok("snapshot al 2026-07-01 ve las dos", len(b.snapshot("2026-07-01")) == 2)
ok("snapshot al 2026-03-01 ve solo la vigente entonces",
   [r["entity_id"] for r in b.snapshot("2026-03-01")] == ["R-1"],
   "la regulatoria aún no entraba en vigor")
ok("snapshot al 2026-09-01 no ve la expirada",
   [r["entity_id"] for r in b.snapshot("2026-09-01")] == ["R-1"],
   "valid_to la cerró en agosto")
ok("snapshot filtra por tabla", b.snapshot("2026-07-01", "components") == [])
lat = b.latencia_bitemporal()
ok("latencia bitemporal se calcula", lat["n"] == 2 and lat["mediana_dias"] == 5.0,
   f"mediana {lat['mediana_dias']} días")
ok("declara si cumple SLO-EB-05", lat["cumple_slo_eb_05"] is True)

print("\nB45 y B42 · ciclo de consulta")
q = b.abrir_consulta("¿Qué reglas toca el SP de pago?", proposito="modernizacion",
                     solicitante="arquitecto-am", organizacion="consultora")
ok("admite propósito permitido", q["admitida"] and q["denied_reason"] is None)

neg = b.abrir_consulta("¿Cómo le va al proveedor X?", proposito="modernizacion",
                       organizacion="tercero")
ok("niega al tercero un propósito que no le toca",
   not neg["admitida"] and "tercero" in neg["denied_reason"])

try:
    b.abrir_consulta("algo", proposito="")
    ok("rechaza consulta sin propósito", False)
except ValueError as e:
    ok("rechaza consulta sin propósito", "B42" in str(e))

filas = b.snapshot("2026-07-01")
r = b.responder(q, filas)
ok("la respuesta declara su resumen de niveles", r["tier_summary"] == {"gold": 2})
ok("todo gold sostiene decisión de gate", r["sostiene_decision_de_gate"] is True)

mezcla = b.responder(q, filas + [{"entity_id": "R-3", "tier": "bronze"}])
ok("con una bronze ya no sostiene el gate",
   mezcla["sostiene_decision_de_gate"] is False, "es el filo de B37")

rneg = b.responder(neg, filas)
ok("la negada no devuelve datos", rneg["datos"] == [] and rneg["denegada"])

b.registrar_consulta(q, r)
b.registrar_consulta(neg)
n = sqlite3.connect(db).execute("SELECT COUNT(*) FROM queries").fetchone()[0]
ok("ambas quedan registradas, incluida la negada", n == 2)

print("\nB43 · autoevaluación")
a = b.autoevaluacion()
ok("eje de uso", a["uso"]["consultas"] == 2 and a["uso"]["denegadas"] == 1)
ok("uso desglosado por propósito",
   a["uso"]["por_proposito"] == {"modernizacion": 2})
ok("eje de costo presente", "costo" in a)
ok("eje de frescura usa la latencia bitemporal", a["frescura"]["n"] == 2)

print("\nADR-EB-002 vs B45 · el rebuild no borra el registro de consultas")
spec_b = importlib.util.spec_from_file_location(
    "bb", ASSET / "templates" / "build-brain.py")
mb = importlib.util.module_from_spec(spec_b)
spec_b.loader.exec_module(mb)
bld = mb.BrainBuilder(db)
bld.open()
antes = sqlite3.connect(db).execute("SELECT COUNT(*) FROM queries").fetchone()[0]
bld.init_schema()
despues = bld.db.execute("SELECT COUNT(*) FROM queries").fetchone()[0]
reglas = bld.db.execute("SELECT COUNT(*) FROM knowledge_lineage").fetchone()[0]
bld.close()
ok("el DROP preserva las consultas", antes == 2 and despues == 2,
   f"{antes} antes, {despues} después")
ok("y sí borra lo que el pipeline reconstruye", reglas == 0,
   "el linaje se reconstruye desde source/, la consulta no")

print()
if fallos:
    print(f"HAY {len(fallos)} FALLAS: {', '.join(fallos)}")
else:
    print("Las 20 comprobaciones pasan, y las de negación fallan cuando deben.")
import shutil
shutil.rmtree(tmp, ignore_errors=True)
sys.exit(1 if fallos else 0)
