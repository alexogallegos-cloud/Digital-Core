# -*- coding: utf-8 -*-
"""
contrato.py — El contrato del pipeline de fuentes (ADR-EB-015, decisión 1).

Un extractor recibe una fuente registrada en `source_catalog` y emite registros
normalizados con su procedencia. **Nunca escribe en `brain.db`**: la escritura
sigue siendo de los cargadores de `build-brain.py`. Esa frontera es lo que
parte el pipeline en dos mitades verificables por separado, y lo que hace que
un extractor defectuoso produzca datos malos pero jamás un esquema corrupto.

Lo que esta capa garantiza, y que por lo tanto ningún extractor vuelve a
implementar ni puede saltarse:

  1. Ningún registro supera el tier natural de su fuente (B37). El tope se
     aplica aquí y no en el extractor, porque un extractor que se autoregula
     no es una garantía: es una buena intención.
  2. Ningún registro entra sin procedencia. Un `source_ref` vacío es un error,
     no un valor por omisión.
  3. Ningún extractor escribe en una tabla que no declaró como destino.
  4. Ninguna cosecha se escribe sobre un archivo `.db`.

Las cuatro pueden fallar, y `test-extractores.py` las hace fallar una por una.
Una garantía sin caso que la rompa no está verificada: solo está escrita.

Flujo de carpetas (Regla P1):   source/  →  knowledge-base/  →  brain.db
El extractor cubre el primer tramo. El cargador cubre el segundo.
"""

import json
import sqlite3
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

import tiers

FAMILIAS = ("parser", "connector")
CONFIANZAS = ("declared", "inferred", "validated")


class TierInflado(ValueError):
    """La fuente declara un tier por encima del que su tipo admite."""


class SinProcedencia(ValueError):
    """Un registro sin `source_ref` que lo ate a su fuente."""


class TablaNoDeclarada(ValueError):
    """El extractor emitió hacia una tabla que no declaró en `tablas`."""


class FuenteNoAceptada(ValueError):
    """El tipo de la fuente no es de los que este extractor sabe leer."""


class EscrituraProhibida(RuntimeError):
    """Alguien intentó que una cosecha escribiera sobre un brain."""


#: Qué columnas de linaje admite cada tabla destino. No todas las tienen:
#: `knowledge_gaps` no tiene `tier` ni `source_ref`, y meterle esas claves
#: rompe el INSERT del cargador. Una tabla que no esté aquí se rechaza, para
#: que agregar un destino nuevo obligue a mirar su DDL.
COLUMNAS_LINAJE = {
    "company_profile":     {"tier", "source_ref"},
    "business_milestones": {"tier", "source_ref"},
    "strategic_drivers":   {"tier", "source_ref"},
    "driver_links":        {"tier", "source_ref"},
    "measurements":        {"tier", "source_ref"},
    "vocabulary":          {"tier", "source_ref"},
    # Estas dos llevan tier pero no source_ref: la procedencia viaja en el
    # registro y llega a knowledge_lineage, que es donde vive el linaje de una
    # fila que no tiene dónde guardarlo. components tiene source_doc, que es
    # otra cosa: el archivo del que salió, no la fuente que lo sostiene.
    "components":          {"tier"},
    "component_calls":     {"tier"},
    "source_catalog":      set(),
    "knowledge_gaps":      set(),
}


@dataclass(frozen=True)
class Fuente:
    """Una fila de `source_catalog`, ya resuelta y con su techo de tier."""
    id: str
    name: str
    source_type: str
    natural_tier: str
    generator_type: str = "parser"
    ontology: str = ""
    cadence: str = "batch"
    status: str = "activa"
    coverage_pct: float | None = None
    location: str = ""
    owner: str = ""
    last_refresh: str = ""
    ambigua: bool = False

    @classmethod
    def desde_fila(cls, fila: dict) -> "Fuente":
        falta = [c for c in ("id", "source_type") if not (fila.get(c) or "").strip()]
        if falta:
            raise ValueError(f"fuente sin {', '.join(falta)}: {fila}")
        tipo = fila["source_type"].strip()
        natural = tiers.tier_natural(tipo)
        declarado = (fila.get("natural_tier") or "").strip().lower() or None
        if declarado:
            if declarado not in tiers.ORDEN:
                raise ValueError(f"{fila['id']} — tier '{declarado}' no existe")
            # Degradar es facultad del steward (regla de degradación de F2).
            # Promover no lo es: eso es de dt-human-reviewer, fila por fila.
            if tiers.ORDEN[declarado] > tiers.ORDEN[natural]:
                raise TierInflado(
                    f"{fila['id']} declara '{declarado}' pero '{tipo}' admite "
                    f"'{natural}' como techo ({tiers.razon(tipo)}). Regla B37")
        return cls(
            id=fila["id"].strip(),
            name=(fila.get("name") or fila["id"]).strip(),
            source_type=tipo,
            natural_tier=declarado or natural,
            generator_type=(fila.get("generator_type") or "parser").strip(),
            ontology=(fila.get("ontology") or "").strip(),
            cadence=(fila.get("cadence") or "batch").strip(),
            status=(fila.get("status") or "activa").strip(),
            coverage_pct=fila.get("coverage_pct"),
            location=(fila.get("location") or "").strip(),
            owner=(fila.get("owner") or "").strip(),
            last_refresh=(fila.get("last_refresh") or "").strip(),
            ambigua=tiers.es_ambiguo(tipo),
        )


class Catalogo:
    """El catálogo de fuentes, leído de donde mande la fase (ADR-EB-014).

    En DISCOVER el catálogo vive en el Markdown levantado a mano con el
    cliente. Desde la primera carga manda la tabla. Las dos lecturas existen
    porque las dos fases existen; lo que no existe es una tercera verdad.
    """

    def __init__(self, fuentes: list, origen: str):
        self.fuentes = {f.id: f for f in fuentes}
        self.origen = origen

    def __len__(self):
        return len(self.fuentes)

    def obtener(self, id_fuente: str) -> Fuente:
        if id_fuente not in self.fuentes:
            conocidas = ", ".join(sorted(self.fuentes)) or "ninguna"
            raise KeyError(f"{id_fuente} no está en {self.origen}. Hay: {conocidas}")
        return self.fuentes[id_fuente]

    @classmethod
    def desde(cls, ruta) -> "Catalogo":
        ruta = Path(ruta)
        if ruta.suffix == ".db":
            return cls.desde_brain(ruta)
        return cls.desde_markdown(ruta)

    @classmethod
    def desde_brain(cls, db_path) -> "Catalogo":
        """Lectura, y solo lectura. El modo `ro` lo vuelve imposible de violar."""
        db_path = Path(db_path)
        uri = f"file:{db_path.as_posix()}?mode=ro"
        con = sqlite3.connect(uri, uri=True)
        con.row_factory = sqlite3.Row
        try:
            filas = [dict(r) for r in con.execute("SELECT * FROM source_catalog")]
        finally:
            con.close()
        return cls([Fuente.desde_fila(f) for f in filas],
                   f"{db_path.name}:source_catalog")

    #: Encabezado de la tabla de instancia en `knowledge-base/source-catalog.md`
    COLUMNAS_MD = ["id", "name", "source_type", "generator_type", "cadence",
                   "status", "natural_tier", "coverage_pct", "last_refresh",
                   "enables"]

    @classmethod
    def desde_markdown(cls, ruta) -> "Catalogo":
        filas = []
        for linea in Path(ruta).read_text(encoding="utf-8").splitlines():
            if not linea.strip().startswith("|"):
                continue
            celdas = [c.strip() for c in linea.strip().strip("|").split("|")]
            if len(celdas) != len(cls.COLUMNAS_MD):
                continue
            if not celdas[0] or set(celdas[0]) <= set("- :") or celdas[0].lower() == "id":
                continue
            fila = dict(zip(cls.COLUMNAS_MD, celdas))
            # El Markdown escribe el tipo como texto legible y a veces con
            # formato. Se normaliza antes de clasificar, no después.
            for c in ("source_type", "generator_type", "status", "natural_tier"):
                fila[c] = fila[c].strip("* `").lower()
            fila["coverage_pct"] = _num(fila.get("coverage_pct"))
            filas.append(fila)
        return cls([Fuente.desde_fila(f) for f in filas], str(ruta))


def _num(txt):
    try:
        return float(str(txt).replace("%", "").replace(",", "").strip())
    except (TypeError, ValueError):
        return None


@dataclass
class Registro:
    """Una afirmación normalizada, lista para que un cargador la escriba."""
    tabla: str
    datos: dict
    source_ref: str
    tier: str = tiers.BRONZE
    confianza: str = "inferred"

    def a_fila(self) -> dict:
        """La fila tal como el cargador la va a insertar, con su linaje dentro.

        Solo se inyectan las columnas de linaje que la tabla realmente tiene:
        `knowledge_gaps` no tiene `tier`, y colársela haría fallar el INSERT.
        """
        if self.tabla not in COLUMNAS_LINAJE:
            raise TablaNoDeclarada(
                f"{self.tabla} no declara sus columnas de linaje en "
                f"COLUMNAS_LINAJE; revisa su DDL antes de emitir hacia ella")
        fila = dict(self.datos)
        admite = COLUMNAS_LINAJE[self.tabla]
        if "tier" in admite:
            fila["tier"] = self.tier
        if "source_ref" in admite:
            fila["source_ref"] = self.source_ref
        return fila


@dataclass
class Cosecha:
    """Lo que un extractor produce: registros, huecos y lo que tuvo que topar."""
    fuente: Fuente
    extractor: str
    familia: str
    registros: list = field(default_factory=list)
    huecos: list = field(default_factory=list)
    sellos: list = field(default_factory=list)

    def agregar(self, tabla, datos, source_ref, tier=tiers.BRONZE,
                confianza="inferred"):
        self.registros.append(Registro(tabla, datos, source_ref, tier, confianza))

    def hueco(self, **fila):
        """Un hueco declarado es conocimiento; uno callado es un defecto (B17)."""
        self.huecos.append(fila)

    def por_tabla(self) -> dict:
        salida = {}
        for r in self.registros:
            salida.setdefault(r.tabla, []).append(r)
        return salida

    def resumen(self) -> dict:
        res = {t: len(v) for t, v in sorted(self.por_tabla().items())}
        res["knowledge_gaps"] = len(self.huecos)
        return res

    def a_dict(self) -> dict:
        return {
            "extractor": self.extractor,
            "familia": self.familia,
            "generado_en": datetime.now(timezone.utc).isoformat(timespec="seconds"),
            "fuente": {
                "id": self.fuente.id,
                "name": self.fuente.name,
                "source_type": self.fuente.source_type,
                "source_type_linaje": tiers.linaje(self.fuente.source_type),
                "natural_tier": self.fuente.natural_tier,
                "tier_basis": tiers.razon(self.fuente.source_type),
                "location": self.fuente.location,
            },
            "sellos": self.sellos,
            "registros": {
                tabla: [
                    {"fila": r.a_fila(), "tier": r.tier,
                     "source_ref": r.source_ref, "confianza": r.confianza}
                    for r in regs
                ]
                for tabla, regs in sorted(self.por_tabla().items())
            },
            "knowledge_gaps": self.huecos,
            "resumen": self.resumen(),
        }

    def a_json(self, destino) -> Path:
        """Escribe la cosecha en `knowledge-base/extracted/`. Nunca en un brain."""
        destino = Path(destino)
        # `is_dir()` solo no basta: la carpeta de salida casi nunca existe la
        # primera vez, y sin esto la cosecha se escribia como un archivo sin
        # extension que ningun cargador vuelve a encontrar.
        if destino.is_dir() or not destino.suffix:
            destino = destino / f"{self.fuente.id}.json"
        if destino.suffix == ".db" or _huele_a_sqlite(destino):
            raise EscrituraProhibida(
                f"{destino.name} es un brain. Un extractor no escribe en "
                f"brain.db: la escritura es de los cargadores (ADR-EB-015)")
        destino.parent.mkdir(parents=True, exist_ok=True)
        destino.write_text(
            json.dumps(self.a_dict(), ensure_ascii=False, indent=2),
            encoding="utf-8")
        return destino


def _huele_a_sqlite(ruta: Path) -> bool:
    """Un .db renombrado sigue siendo un .db. La extensión no es la garantía."""
    try:
        with open(ruta, "rb") as fh:
            return fh.read(16).startswith(b"SQLite format 3")
    except OSError:
        return False


class Extractor(ABC):
    """Base de las dos familias. `parser` lee una fuente estática entera;
    `connector` consulta un sistema vivo. El contrato de salida es el mismo."""

    id = "extractor"
    familia = "parser"
    tipos_fuente = ()
    tablas = ()

    @abstractmethod
    def extraer(self, fuente: Fuente, **kw) -> Cosecha:
        """Lo propio de cada extractor. No se llama directo: usa `ejecutar`."""

    def nueva_cosecha(self, fuente: Fuente) -> Cosecha:
        return Cosecha(fuente=fuente, extractor=self.id, familia=self.familia)

    def ejecutar(self, fuente: Fuente, **kw) -> Cosecha:
        if self.familia not in FAMILIAS:
            raise ValueError(f"familia '{self.familia}' no existe; son {FAMILIAS}")
        if self.tipos_fuente and fuente.source_type not in self.tipos_fuente:
            raise FuenteNoAceptada(
                f"{self.id} lee {', '.join(self.tipos_fuente)}; "
                f"{fuente.id} es de tipo {fuente.source_type}")
        cosecha = self.extraer(fuente, **kw)
        self._sellar(cosecha, fuente)
        return cosecha

    def _sellar(self, cosecha: Cosecha, fuente: Fuente):
        """La frontera de entrada: aquí se estampa el tier y se exige procedencia."""
        topados = 0
        for r in cosecha.registros:
            if r.tabla not in self.tablas:
                raise TablaNoDeclarada(
                    f"{self.id} emitió hacia {r.tabla}, que no declaró. "
                    f"Declara: {', '.join(self.tablas)}")
            if not (r.source_ref or "").strip():
                raise SinProcedencia(
                    f"{self.id} emitió una fila de {r.tabla} sin source_ref")
            if not r.source_ref.startswith(fuente.id):
                raise SinProcedencia(
                    f"el source_ref {r.source_ref} no ata a la fuente {fuente.id}")
            if r.confianza not in CONFIANZAS:
                raise ValueError(f"confianza '{r.confianza}'; son {CONFIANZAS}")
            efectivo, topado = tiers.no_supera(r.tier, fuente.natural_tier)
            r.tier = efectivo
            topados += topado
            # a_fila() valida de paso que la tabla declare sus columnas de linaje
            r.a_fila()
        if topados:
            cosecha.sellos.append(
                f"{topados} registro(s) topados a {fuente.natural_tier} por el "
                f"tier natural de la fuente: {tiers.razon(fuente.source_type)} (B37)")
        if fuente.ambigua:
            cosecha.sellos.append(
                f"{fuente.source_type} es un tipo sin calificar: la cosecha entra "
                f"al piso. dt-source-steward debe calificarla para subirla")
