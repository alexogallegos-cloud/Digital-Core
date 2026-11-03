# -*- coding: utf-8 -*-
"""Suite del Brain Auditor. Primera que tiene.

El auditor decide si un brain puede activarse y hasta hoy nadie lo auditaba a
él. Cubre D10, la dimensión de roster, y el acote de D7 que trajo ADR-EB-017. Es
el lugar donde van los casos de las dimensiones que se verifiquen después.

El criterio es el mismo de siempre en este asset: cada veredicto tiene que
poder darse por las dos razones. Una dimensión que solo sabe decir PASS no
valida nada.

Uso:
    python test-validate.py <ruta-del-asset>

Exit: 0 si todos los casos se comportan como se espera, 1 si alguno falla.
"""
import importlib.util
import shutil
import sqlite3
import sys
import tempfile
from pathlib import Path

ASSET = Path(sys.argv[1]).resolve()
TMP = Path(tempfile.mkdtemp())

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except (AttributeError, ValueError):
    pass

_spec = importlib.util.spec_from_file_location(
    "validate", ASSET / "dt" / "dt-brain-auditor" / "validate.py")
V = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(V)

PLANTILLA = (ASSET / "templates" / "roster-dt.md").read_text(encoding="utf-8")

resultados = []


def nuevo_brain(nombre: str) -> Path:
    """Un brain mínimo pero real: esquema canónico y una fila de identidad."""
    raiz = TMP / nombre
    (raiz / "digital-brain").mkdir(parents=True)
    db = raiz / "digital-brain" / "brain.db"
    c = sqlite3.connect(db)
    c.executescript((ASSET / "templates" / "schema.sql").read_text(encoding="utf-8"))
    c.execute("INSERT INTO system_info (slug, display_name, industry, "
              "brain_type, hemisphere, status) VALUES "
              "('prueba','Brain de prueba','banking','system','run','building')")
    c.commit()
    c.close()
    return db


def corre(db: Path):
    return V.Validator(db).run("roster")


def declara(db: Path, texto: str):
    destino = db.parent.parent / "dt"
    destino.mkdir(exist_ok=True)
    (destino / "roster-dt.md").write_text(texto, encoding="utf-8")


def caso(nombre, fn):
    try:
        fn()
        resultados.append((nombre, True, ""))
    except AssertionError as e:
        resultados.append((nombre, False, str(e)))
    except Exception as e:  # noqa: BLE001
        resultados.append((nombre, False, f"{type(e).__name__}: {e}"))


# ── El roster que se exige tiene que ser el que existe ──────────────────────

def roster_completo():
    assert len(V.ROSTER_CANONICO) == 24, len(V.ROSTER_CANONICO)
    carpetas = {d.name for d in (ASSET / "dt").iterdir()
                if d.is_dir() and d.name.startswith("dt-")}
    assert set(V.ROSTER_CANONICO) == carpetas, carpetas ^ set(V.ROSTER_CANONICO)


def plantilla_nombra_a_todos():
    """La plantilla es lo que copia una instancia: si le falta un rol, el brain
    que la copie arranca con un hallazgo bloqueante que no es suyo."""
    faltan = [r for r in V.ROSTER_CANONICO if r not in PLANTILLA]
    assert not faltan, faltan


# ── Los tres veredictos de D10 ──────────────────────────────────────────────

def sin_declarar_es_desconocido():
    """Desconocido no es cero. Reprobar aquí sería afirmar lo que no se sabe."""
    v = corre(nuevo_brain("sin-roster"))
    assert v.dim_status["roster"].strip() == "N/A", v.dim_status["roster"]
    assert not [f for f in v.findings if f.dim == "roster" and f.blocking]


def plantilla_sin_llenar_pasa_con_huecos():
    db = nuevo_brain("plantilla")
    declara(db, PLANTILLA)
    v = corre(db)
    assert v.dim_status["roster"] == "PASS", v.dim_status["roster"]
    assert v.metrics["roster_huecos"] == 24, v.metrics
    assert v.metrics["roster_cubiertos"] == 0, v.metrics
    # El hueco declarado avisa, no bloquea: es mejor que el silencio.
    avisos = [f for f in v.findings if f.dim == "roster" and not f.blocking]
    assert avisos, "un roster entero sin dueño debería al menos avisar"


def rol_sin_mencion_bloquea():
    """El caso que hace fallar a la dimensión. Sin él, D10 no valida nada."""
    db = nuevo_brain("incompleto")
    recortada = "\n".join(
        l for l in PLANTILLA.splitlines()
        if not l.startswith("| dt-source-steward")
        and not l.startswith("| dt-human-reviewer"))
    declara(db, recortada)
    v = corre(db)
    assert v.dim_status["roster"] == "FAIL", v.dim_status["roster"]
    assert v.metrics["roster_sin_mencion"] == 2, v.metrics
    bloq = [f for f in v.findings if f.dim == "roster" and f.blocking]
    assert bloq and "dt-source-steward" in bloq[0].sample, bloq[0].sample if bloq else None


def cobertura_con_nombres_propios():
    """Lo que ADR-EB-016 vino a permitir: cumplir sin llamarse igual."""
    db = nuevo_brain("nombres-propios")
    filas = "\n".join(f"| {rol} | dt-{i:02d}-propio | |"
                      for i, rol in enumerate(V.ROSTER_CANONICO, 1))
    declara(db, "| Rol canónico | DT en este brain | Nota |\n"
                "|---|---|---|\n" + filas)
    v = corre(db)
    assert v.dim_status["roster"] == "PASS", v.dim_status["roster"]
    assert v.metrics["roster_cubiertos"] == 24, v.metrics
    assert v.metrics["roster_huecos"] == 0, v.metrics


def dt_de_dimension_avisa_sin_bloquear():
    db = nuevo_brain("con-dimension")
    declara(db, PLANTILLA + "\n| dt-spei | dt-spei | especialista de materia |\n")
    v = corre(db)
    assert v.dim_status["roster"] == "PASS", v.dim_status["roster"]
    ajenos = [f for f in v.findings
              if f.dim == "roster" and not f.blocking and "dimensión" in f.message]
    assert ajenos, [f.message for f in v.findings if f.dim == "roster"]


def la_declaracion_se_busca_junto_al_brain():
    """También vale al lado del brain.db, no solo un nivel arriba."""
    db = nuevo_brain("junto")
    (db.parent / "dt").mkdir()
    (db.parent / "dt" / "roster-dt.md").write_text(PLANTILLA, encoding="utf-8")
    v = corre(db)
    assert v.dim_status["roster"] == "PASS", v.dim_status["roster"]


# ── D7 · nivel proceso contra nivel empresa (ADR-EB-017) ───────────────────

def _con_filas(nombre, sentencias):
    db = nuevo_brain(nombre)
    c = sqlite3.connect(db)
    c.execute("INSERT INTO processes (id, ontology, l1_name) "
              "VALUES ('P-1', 'banca-etb', 'Cobranza')")
    for s in sentencias:
        c.execute(s)
    c.commit()
    c.close()
    return db


def nivel_empresa_no_cuenta_como_huerfano():
    """Los ingresos totales de una empresa no son de ningún proceso."""
    db = _con_filas("nivel-empresa", [
        "INSERT INTO measurements (entity_table, entity_id, metric, value_num, "
        "measured_at, recorded_at) VALUES "
        "('company_profile','acme','ingresos',1000,'2025-12-31','2026-11-03')",
        "INSERT INTO knowledge_gaps (id, gap_type, domain, description) VALUES "
        "('GAP-1','dato','identidad','quién es la empresa')",
        "INSERT INTO knowledge_gaps (id, gap_type, domain, description) VALUES "
        "('GAP-2','source','fuentes','faltan los logs')",
    ])
    v = V.Validator(db).run("process_linkage")
    assert v.dim_status["process_linkage"] == "PASS", v.dim_status
    assert v.metrics["nivel_empresa"] == 3, v.metrics
    assert not v.metrics["orphan_knowledge"], v.metrics


def nivel_proceso_sin_proceso_sigue_bloqueando():
    """El caso que hace fallar a D7. Sin él la excepción sería una puerta."""
    db = _con_filas("nivel-proceso", [
        "INSERT INTO measurements (entity_table, entity_id, metric, value_num, "
        "measured_at, recorded_at) VALUES "
        "('components','SP-1','latencia',120,'2026-10-01','2026-11-03')",
    ])
    v = V.Validator(db).run("process_linkage")
    assert v.dim_status["process_linkage"] == "FAIL", v.dim_status
    assert v.metrics["orphan_knowledge"].get("measurements") == 1, v.metrics


def la_exencion_no_se_activa_por_omision():
    """Omitir el ancla no exime: el hueco sin dominio sigue siendo huérfano."""
    db = _con_filas("sin-ancla", [
        "INSERT INTO knowledge_gaps (id, gap_type, description) VALUES "
        "('GAP-3','dato','un hueco que no dice de qué es')",
    ])
    v = V.Validator(db).run("process_linkage")
    assert v.dim_status["process_linkage"] == "FAIL", v.dim_status
    assert v.metrics["nivel_empresa"] == 0, v.metrics


# ── La dimensión no rompe a las otras nueve ─────────────────────────────────

def el_auditor_completo_sigue_corriendo():
    db = nuevo_brain("completo")
    declara(db, PLANTILLA)
    v = V.Validator(db).run()
    assert len(v.dim_status) == len(V.DIMENSIONS), v.dim_status
    assert "roster" in v.dim_status
    texto = V.render(v, summary=True)
    assert "D10" in texto, texto[:200]


caso("el roster exigido es el que existe en dt/", roster_completo)
caso("la plantilla nombra los 24 roles", plantilla_nombra_a_todos)
caso("sin declarar es DESCONOCIDO, no cero", sin_declarar_es_desconocido)
caso("plantilla sin llenar pasa con 24 huecos", plantilla_sin_llenar_pasa_con_huecos)
caso("un rol sin mención bloquea", rol_sin_mencion_bloquea)
caso("cobertura con nombres propios", cobertura_con_nombres_propios)
caso("un DT de dimensión avisa y no bloquea", dt_de_dimension_avisa_sin_bloquear)
caso("la declaración se busca junto al brain", la_declaracion_se_busca_junto_al_brain)
caso("nivel empresa no cuenta como huérfano", nivel_empresa_no_cuenta_como_huerfano)
caso("nivel proceso sin proceso sigue bloqueando", nivel_proceso_sin_proceso_sigue_bloqueando)
caso("la exención no se activa por omisión", la_exencion_no_se_activa_por_omision)
caso("el auditor completo sigue corriendo", el_auditor_completo_sigue_corriendo)


def main():
    print("BRAIN AUDITOR — suite de dimensiones")
    print("=" * 62)
    fallos = 0
    for nombre, ok, detalle in resultados:
        fallos += not ok
        print(f"[{'PASS' if ok else 'FALLA'}] {nombre}"
              + (f"\n        {detalle}" if detalle else ""))
    print("=" * 62)
    print(f"{len(resultados) - fallos}/{len(resultados)} casos como se esperaba")
    shutil.rmtree(TMP, ignore_errors=True)
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
