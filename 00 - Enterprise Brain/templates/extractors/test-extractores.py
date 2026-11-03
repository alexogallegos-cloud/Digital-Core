# -*- coding: utf-8 -*-
"""Suite del pipeline de fuentes. Rompe a propósito cada garantía del contrato.

Un contrato que nadie intentó violar no está verificado: está escrito. Aquí
cada una de las cuatro garantías de `contrato.py` tiene un caso que la viola y
que debe terminar en excepción, y el caso feliz tiene cifras exactas contra el
documento de prueba, para que una regresión en el parseo no pase como "corrió
sin errores".

Si agregas una garantía al contrato o un extractor nuevo, agrega aquí el caso
que lo hace fallar.

Uso:
    python test-extractores.py

Exit: 0 si todos los casos se comportan como se espera, 1 si alguno falla.
"""

import importlib.util
import sqlite3
import sys
import tempfile
from pathlib import Path

AQUI = Path(__file__).parent
sys.path.insert(0, str(AQUI))

import contrato  # noqa: E402
import tiers  # noqa: E402

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except (AttributeError, ValueError):
    pass

_spec = importlib.util.spec_from_file_location("doc_identidad", AQUI / "doc-identidad.py")
di = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(di)

FIXTURES = AQUI / "fixtures"
CATALOGO = FIXTURES / "source-catalog.md"
REPORTE = FIXTURES / "reporte-anual-ficticio.md"
TMP = Path(tempfile.mkdtemp())

resultados = []


def caso(nombre, fn, espera=None):
    """`espera` es una clase de excepción, o None si el caso debe pasar limpio."""
    try:
        fn()
        ok, detalle = (espera is None), ("" if espera is None else f"no lanzó {espera.__name__}")
    except AssertionError as e:
        ok, detalle = False, f"aserción: {e}"
    except Exception as e:  # noqa: BLE001 — la clase es justo lo que se evalúa
        ok = espera is not None and isinstance(e, espera)
        detalle = "" if ok else f"lanzó {type(e).__name__}: {e}"
    resultados.append((nombre, ok, detalle))


def cosecha_fixture(**kw):
    cat = contrato.Catalogo.desde(CATALOGO)
    fuente = cat.obtener(kw.pop("fuente", "SRC-001"))
    base = dict(documento=str(REPORTE), slug="albor", periodo="2025", pais="Mexico")
    base.update(kw)
    return di.DocIdentidad().ejecutar(fuente, **base)


# ── El caso feliz, con cifras exactas ────────────────────────────────────────

def feliz():
    c = cosecha_fixture()
    r = c.resumen()
    # El documento de prueba trae siete hitos fechados, tres pilares más la
    # frase que los anuncia, dos retos, una amenaza y diez cifras. Si estas
    # cifras cambian, cambió el parseo y hay que mirar por qué.
    assert r["business_milestones"] == 7, r
    assert r["strategic_drivers"] == 7, r
    assert r["measurements"] == 10, r
    assert r["company_profile"] == 1, r
    perfil = c.por_tabla()["company_profile"][0].a_fila()
    assert perfil["legal_name"] == "Albor Servicios Financieros, S.A.B. de C.V.", perfil
    assert perfil["founded_year"] == 1973, perfil
    assert perfil["ticker"] == "ALBOR", perfil
    cifras = {x.a_fila()["metric"]: x.a_fila()["value_num"]
              for x in c.por_tabla()["measurements"]}
    # La trampa clásica del separador de miles: 18,400 se partía en 18,40 + 0.
    assert cifras["ingresos"] == 18_400_000_000, cifras
    assert cifras["utilidad"] == 2_750_000_000, cifras
    assert cifras["clientes"] == 4_300_000, cifras
    # Una meta a 2027 no es una medición de 2027.
    meta = [x.a_fila() for x in c.por_tabla()["measurements"]
            if x.a_fila()["metric"] == "eficiencia"][0]
    assert meta["source_type"] == "forecast", meta


def procedencia_hasta_la_linea():
    c = cosecha_fixture()
    for r in c.registros:
        assert r.source_ref.startswith("SRC-001"), r.source_ref
    hitos = {x.a_fila()["occurred_year"]: x.source_ref for x in c.por_tabla()["business_milestones"]}
    assert ":L" in hitos[2004], hitos[2004]


def criterio_de_salida():
    """Cada driver tiene link o está declarado como hueco. Aquí, hueco."""
    c = cosecha_fixture()
    drivers = {x.a_fila()["id"] for x in c.por_tabla()["strategic_drivers"]}
    con_hueco = {d for d in drivers
                 if any(d in (h.get("description") or "") for h in c.huecos)}
    assert con_hueco == drivers, drivers - con_hueco


def no_emite_driver_links():
    c = cosecha_fixture()
    assert "driver_links" not in c.por_tabla()
    assert "driver_links" not in di.DocIdentidad.tablas


# ── Las cuatro garantías del contrato, violadas una por una ──────────────────

def tier_inflado():
    contrato.Fuente.desde_fila(
        {"id": "X-1", "source_type": "minuta", "natural_tier": "gold"})


def tipo_desconocido():
    contrato.Fuente.desde_fila({"id": "X-2", "source_type": "telepatia"})


def tope_de_tier():
    """Un extractor que pide gold desde una fuente bronze queda topado."""

    class Ambicioso(contrato.Extractor):
        id, familia = "ambicioso", "parser"
        tablas = ("business_milestones",)

        def extraer(self, fuente, **kw):
            c = self.nueva_cosecha(fuente)
            c.agregar("business_milestones",
                      {"id": "MIL-x", "occurred_year": 2020, "title": "t"},
                      source_ref=f"{fuente.id}#L1", tier="gold")
            return c

    fuente = contrato.Catalogo.desde(CATALOGO).obtener("SRC-003")  # minuta, bronze
    c = Ambicioso().ejecutar(fuente)
    assert c.registros[0].tier == "bronze", c.registros[0].tier
    assert any("topados" in s for s in c.sellos), c.sellos


def sin_procedencia():
    class Anonimo(contrato.Extractor):
        id, familia, tablas = "anonimo", "parser", ("business_milestones",)

        def extraer(self, fuente, **kw):
            c = self.nueva_cosecha(fuente)
            c.agregar("business_milestones", {"id": "MIL-x", "occurred_year": 2020,
                                              "title": "t"}, source_ref="")
            return c

    Anonimo().ejecutar(contrato.Catalogo.desde(CATALOGO).obtener("SRC-001"))


def procedencia_de_otra_fuente():
    class Prestado(contrato.Extractor):
        id, familia, tablas = "prestado", "parser", ("business_milestones",)

        def extraer(self, fuente, **kw):
            c = self.nueva_cosecha(fuente)
            c.agregar("business_milestones", {"id": "MIL-x", "occurred_year": 2020,
                                              "title": "t"}, source_ref="SRC-999#L1")
            return c

    Prestado().ejecutar(contrato.Catalogo.desde(CATALOGO).obtener("SRC-001"))


def tabla_no_declarada():
    class Invasor(contrato.Extractor):
        id, familia, tablas = "invasor", "parser", ("business_milestones",)

        def extraer(self, fuente, **kw):
            c = self.nueva_cosecha(fuente)
            c.agregar("strategic_drivers", {"id": "DRV-x", "driver_type": "pilar",
                                            "title": "t"}, source_ref=f"{fuente.id}#L1")
            return c

    Invasor().ejecutar(contrato.Catalogo.desde(CATALOGO).obtener("SRC-001"))


def tabla_sin_columnas_de_linaje_declaradas():
    contrato.Registro("tabla_inventada", {"id": "x"}, "SRC-001#L1").a_fila()


def escritura_sobre_db():
    c = cosecha_fixture()
    c.a_json(TMP / "brain.db")


def escritura_sobre_sqlite_disfrazado():
    """Un .db renombrado sigue siendo un brain. La extensión no es la garantía."""
    disfraz = TMP / "cosecha.json"
    sqlite3.connect(disfraz).execute("CREATE TABLE t (a)").connection.close()
    cosecha_fixture().a_json(disfraz)


def fuente_no_aceptada():
    cosecha_fixture(fuente="SRC-004")  # logs: eso es un connector, no este parser


def binario_sin_convertir():
    cosecha_fixture(documento=str(TMP / "reporte.pdf"))


# ── Lo que no encuentra se declara, no se inventa ────────────────────────────

def documento_sin_estrategia():
    mudo = TMP / "mudo.md"
    mudo.write_text(
        "# Aviso\n\nEste documento no dice nada del negocio ni de su estrategia.\n"
        "Solo ocupa espacio y sirve para comprobar que el extractor calla.\n",
        encoding="utf-8")
    c = cosecha_fixture(documento=str(mudo))
    r = c.resumen()
    assert r.get("strategic_drivers", 0) == 0, r
    assert r.get("business_milestones", 0) == 0, r
    assert any("strategic_drivers" in (h.get("description") or "") for h in c.huecos), c.huecos
    assert any("business_milestones" in (h.get("description") or "") for h in c.huecos), c.huecos


def cifra_sin_anio_se_declara():
    suelta = TMP / "suelta.md"
    suelta.write_text(
        "# Cifras\n\nLos ingresos del grupo alcanzaron 1,200 millones de pesos.\n",
        encoding="utf-8")
    c = cosecha_fixture(documento=str(suelta), periodo=None)
    assert c.resumen().get("measurements", 0) == 0, c.resumen()
    assert any("no traen año" in (h.get("description") or "") for h in c.huecos), c.huecos


def tipo_ambiguo_entra_al_piso():
    c = cosecha_fixture(fuente="SRC-002")  # 'doc' sin calificar
    assert all(r.tier == "bronze" for r in c.registros), c.resumen()
    assert any("sin calificar" in s for s in c.sellos), c.sellos
    assert any(h.get("gap_type") == "source" for h in c.huecos), c.huecos


def el_catalogo_se_lee_del_brain():
    """La tabla manda desde la primera carga (ADR-EB-014). Y se lee en modo ro."""
    db = TMP / "mini.db"
    con = sqlite3.connect(db)
    con.execute("CREATE TABLE source_catalog (id TEXT, name TEXT, source_type TEXT, "
                "generator_type TEXT, cadence TEXT, status TEXT, natural_tier TEXT, "
                "coverage_pct REAL, location TEXT, owner TEXT, last_refresh TEXT, "
                "ontology TEXT, enables TEXT)")
    con.execute("INSERT INTO source_catalog (id, name, source_type, natural_tier) "
                "VALUES ('SRC-900', 'Reporte', 'doc_tecnico', 'silver')")
    con.commit()
    con.close()
    cat = contrato.Catalogo.desde(db)
    assert len(cat) == 1 and cat.obtener("SRC-900").natural_tier == "silver"


def la_tabla_f2_no_tiene_huecos():
    """Toda clasificación de F2 traduce al vocabulario de knowledge_lineage."""
    for tipo in tiers.TIER_NATURAL:
        assert tiers.linaje(tipo), tipo
        assert tiers.razon(tipo), tipo


caso("caso feliz con cifras exactas", feliz)
caso("procedencia hasta la línea", procedencia_hasta_la_linea)
caso("criterio de salida: todo driver con hueco de link", criterio_de_salida)
caso("no emite driver_links ni la declara", no_emite_driver_links)
caso("catálogo con tier inflado", tier_inflado, contrato.TierInflado)
caso("tipo de fuente sin clasificar", tipo_desconocido, tiers.TipoDeFuenteDesconocido)
caso("tier topado al natural de la fuente", tope_de_tier)
caso("registro sin source_ref", sin_procedencia, contrato.SinProcedencia)
caso("source_ref de otra fuente", procedencia_de_otra_fuente, contrato.SinProcedencia)
caso("emisión a tabla no declarada", tabla_no_declarada, contrato.TablaNoDeclarada)
caso("tabla sin columnas de linaje declaradas", tabla_sin_columnas_de_linaje_declaradas,
     contrato.TablaNoDeclarada)
caso("escritura sobre brain.db", escritura_sobre_db, contrato.EscrituraProhibida)
caso("escritura sobre sqlite disfrazado", escritura_sobre_sqlite_disfrazado,
     contrato.EscrituraProhibida)
caso("fuente de tipo no aceptado", fuente_no_aceptada, contrato.FuenteNoAceptada)
caso("binario sin convertir", binario_sin_convertir, ValueError)
caso("documento sin estrategia declara el hueco", documento_sin_estrategia)
caso("cifra sin año se declara y no se rellena", cifra_sin_anio_se_declara)
caso("tipo ambiguo entra al piso", tipo_ambiguo_entra_al_piso)
caso("el catálogo se lee del brain en modo ro", el_catalogo_se_lee_del_brain)
caso("la tabla F2 no tiene huecos", la_tabla_f2_no_tiene_huecos)


def main():
    print("PIPELINE DE FUENTES — suite del contrato")
    print("=" * 62)
    fallos = 0
    for nombre, ok, detalle in resultados:
        marca = "PASS" if ok else "FALLA"
        fallos += not ok
        print(f"[{marca}] {nombre}" + (f"\n        {detalle}" if detalle else ""))
    print("=" * 62)
    print(f"{len(resultados) - fallos}/{len(resultados)} casos como se esperaba")
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
