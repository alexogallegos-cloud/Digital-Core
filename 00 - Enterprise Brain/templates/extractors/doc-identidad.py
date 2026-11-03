# -*- coding: utf-8 -*-
"""
doc-identidad.py — El primer extractor del pipeline. Familia `parser`.

Lee un documento de texto registrado en `source_catalog` y emite los candidatos
de la **Etapa 0 — Identidad**: la ficha de la empresa, su trayectoria, sus
cifras y lo que declara como estrategia. Es el extractor que permite que un
cliente en evaluación tenga brain desde el primer reporte anual, sin acceso
todavía a un solo repositorio de código.

QUÉ HACE Y QUÉ NO
-----------------
Hace la parte mecánica y verificable: segmenta el documento, encuentra los
pasajes candidatos, los normaliza, les estampa el tier natural de la fuente y
los ata a la línea de la que salieron. Emite **candidatos con procedencia**,
no verdades.

No hace la parte de juicio, y no finge hacerla. No decide si un pilar
declarado es el pilar real, no resuelve a qué capability se ata un driver y no
inventa un dato que el documento no trae. Todo eso es de `dt-client-intelligence`
con el humano en el ciclo, y lo que falta sale declarado en `knowledge_gaps`
en vez de salir en silencio (B17).

Por eso su tier dominante es silver y bronze, y está bien que lo sea: una
estrategia declarada en un reporte anual es intención, no hecho (B37).

POR QUÉ NO EMITE `driver_links`
-------------------------------
`driver_links` es el criterio de salida de la Etapa 0 y es justo lo que un
documento solo no puede saber: la traza de vuelta necesita el estate, no la
narrativa. Así que este extractor emite un hueco por cada driver, que es lo
que la metodología pide, "cada driver tiene al menos un link, o está declarado
como hueco". Un driver sin link es un hallazgo, no un silencio.

USO
---
    python doc-identidad.py --fuente SRC-003 --slug acme \\
        --catalogo ../../knowledge-base/source-catalog.md \\
        --documento ../../source/docs/reporte-anual-2025.md \\
        --salida ../../knowledge-base/extracted/

El resultado es un JSON que los cargadores de `build-brain.py` leen. Este
script jamás toca `brain.db`: esa frontera la impone `contrato.py`.
"""

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from datetime import date
from pathlib import Path

import contrato
import tiers

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except (AttributeError, ValueError):
    pass

EXTENSIONES = {".md", ".markdown", ".txt"}

ANIO = re.compile(r"\b(1[89]\d{2}|20\d{2})\b")
ENCABEZADO = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
VINETA = re.compile(r"^\s*(?:[-*+•]|\d{1,2}[.)])\s+")

#: Verbo de hito y el tipo que implica. El orden decide: el primero que case
#: gana, y por eso `fundacion` va antes que `entrada_mercado`, que comparte
#: vocabulario con ella.
HITOS = [
    ("fundacion", r"(?:fundad[ao]s?|se\s+fund[óo]|fundamos|naci(?:[óo]|mos)\s+(?:en|como)|"
                  r"se\s+constituy[óo]|nos\s+constituimos|qued[óo]\s+constituid[ao]|"
                  r"se\s+cre[óo]\s+(?:en|la|el))"),
    ("fusion", r"(?:fusi[óo]n|se\s+fusion[óo]|nos\s+fusionamos|fusionaron|"
               r"se\s+integr[óo]\s+con)"),
    ("adquisicion", r"(?:adquiri(?:[óo]|mos|eron)|adquisici[óo]n|absorbi(?:[óo]|mos)|"
                    r"tom(?:[óo]|amos)\s+el\s+control|compr(?:[óo]|amos)\s+(?:a|el|la|los|las))"),
    ("ipo", r"(?:sali(?:[óo]|mos)\s+a\s+bolsa|oferta\s+p[úu]blica|"
            r"coloc(?:[óo]|amos)\s+(?:acciones|el|un)|debut(?:[óo]|amos)\s+en\s+la\s+bolsa|"
            r"list(?:[óo]|amos)\s+(?:sus|nuestras)\s+acciones)"),
    ("crisis", r"(?:crisis|quiebra|rescate|intervenci[óo]n|desplome|"
               r"p[ée]rdidas\s+(?:hist[óo]ricas|r[ée]cord)|ca[íi]da\s+de\s+ingresos)"),
    ("sancion", r"(?:sanci[óo]n|multa|apercibimiento|observaci[óo]n\s+de\s+la)"),
    ("reestructura", r"(?:reestructura|escisi[óo]n|spin[\s-]?off|reorganizaci[óo]n|"
                     r"separaci[óo]n\s+de\s+negocios)"),
    ("salida_mercado", r"(?:sali(?:[óo]|mos)\s+del\s+mercado|cerr(?:[óo]|amos)\s+operaciones|"
                       r"desinvirti(?:[óo]|mos)|vendi(?:[óo]|mos)\s+(?:su|nuestra)\s+participaci[óo]n|"
                       r"discontinu(?:[óo]|amos))"),
    ("entrada_mercado", r"(?:entr(?:[óo]|amos)\s+al\s+mercado|inaugur(?:[óo]|amos)|"
                        r"abri(?:[óo]|mos)\s+operaciones|inici(?:[óo]|amos)\s+operaciones|"
                        r"lanz(?:[óo]|amos)\s+(?:su|el|la|los|las|nuestro|nuestra))"),
]

#: Marcador de driver y el tipo que implica. De lo más específico a lo más
#: común: "objetivo" aparece dentro de frases que son de otra cosa, así que
#: va al final o se traga a los demás.
DRIVERS = [
    ("amenaza", r"(?:amenaza|nuevos\s+entrantes|disrupci[óo]n|competencia\s+de|"
                r"presi[óo]n\s+competitiva|p[ée]rdida\s+de\s+participaci[óo]n)"),
    ("reto", r"(?:reto|desaf[íi]o|dificultad|limitante|obst[áa]culo|brecha|"
             r"presi[óo]n\s+(?:regulatoria|de\s+costos|de\s+m[áa]rgenes))"),
    ("pilar", r"(?:pilar|eje\s+estrat[ée]gico|prioridad\s+estrat[ée]gica|"
              r"l[íi]nea\s+estrat[ée]gica|apuesta\s+estrat[ée]gica|nuestra\s+estrategia)"),
    ("objetivo", r"(?:objetivo|meta\s+(?:de|para|al)|aspiramos|nos\s+proponemos|"
                 r"buscamos\s+(?:alcanzar|llegar|duplicar)|alcanzar\s+(?:un|una|el|la))"),
]

#: Encabezados que por sí solos vuelven candidato a lo que cuelga de ellos, y
#: con qué tipo. Una frase sin marcador bajo "Nuestros pilares" es un pilar.
SECCIONES = [
    ("reto", r"(?:retos|desaf[íi]os|riesgos|entorno\s+competitivo)"),
    ("amenaza", r"(?:amenazas|competencia|presiones\s+del\s+mercado)"),
    ("objetivo", r"(?:objetivos|metas|aspiraci[óo]n)"),
    ("pilar", r"(?:estrategia|pilares|prioridades|visi[óo]n|plan\s+estrat[ée]gico|"
              r"transformaci[óo]n)"),
]

HORIZONTE = re.compile(r"(?:para|al|hacia|rumbo\s+a)\s+(?:el\s+a[ñn]o\s+)?(20\d{2})")
PRIORIDAD_ALTA = re.compile(r"(?:principal|prioritari[ao]|cr[íi]tic[ao]|"
                            r"m[áa]s\s+importante|primera\s+prioridad)", re.I)

NUM = r"(?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?"
CIFRA_MONEDA = re.compile(
    rf"(\$|USD\s?|MXN\s?)?({NUM})\s*(mil\s+millones|millones|mdp|mmdp|mdd|billones)?"
    rf"\s*(?:de\s+)?(pesos|d[óo]lares|MXN|USD)?", re.I)
CIFRA_PCT = re.compile(rf"({NUM})\s*%")
CIFRA_CONTEO = re.compile(
    rf"({NUM})\s+(sucursales|empleados|colaboradores|clientes|tiendas|cajeros|"
    rf"usuarios|transacciones|p[óo]lizas|cuentas|corresponsales)", re.I)

MULTIPLOS = {"mil millones": 1e9, "mmdp": 1e9, "billones": 1e9,
             "millones": 1e6, "mdp": 1e6, "mdd": 1e6}

METRICAS_MONEDA = [
    ("ingresos", r"(?:ingresos|ventas|facturaci[óo]n)"),
    ("utilidad", r"(?:utilidad|ganancia|beneficio\s+neto|resultado\s+neto)"),
    ("activos", r"(?:activos|balance)"),
    ("cartera", r"(?:cartera|portafolio\s+de\s+cr[ée]dito|colocaci[óo]n)"),
    ("captacion", r"(?:captaci[óo]n|dep[óo]sitos)"),
    ("inversion", r"(?:inversi[óo]n|capex|presupuesto)"),
]
METRICAS_PCT = [
    ("participacion_mercado", r"(?:participaci[óo]n\s+de\s+mercado|market\s+share|cuota)"),
    ("crecimiento", r"(?:crecimiento|creci[óo]|aument[óo]|increment[óo])"),
    ("margen", r"(?:margen|rentabilidad)"),
    ("morosidad", r"(?:morosidad|cartera\s+vencida|imor)"),
    ("roe", r"(?:ROE|retorno\s+sobre\s+capital)"),
    ("eficiencia", r"(?:[íi]ndice\s+de\s+eficiencia|eficiencia\s+operativa)"),
]

RAZON_SOCIAL = re.compile(
    r"\b([A-ZÁÉÍÓÚÑ][\wÁÉÍÓÚÑáéíóúñ&.,\- ]{2,60}?,?\s*"
    # El cierre es lookahead y no \b: con \b, "C.V." tenía que soltar su punto
    # final para encontrar frontera de palabra, y la razón social entraba mocha.
    r"S\.?\s?A\.?\s?B?\.?(?:\s+de\s+C\.?\s?V\.?)?)(?=[\s,;:)]|$)")
TICKER = re.compile(r"\b(?:BMV|BVM|NYSE|NASDAQ|LSE)\s*:\s*([A-Z]{1,6}\*?)\b")


def _norma(txt: str) -> str:
    """Para comparar y deduplicar, no para mostrar."""
    t = unicodedata.normalize("NFKD", txt.lower())
    t = "".join(c for c in t if not unicodedata.combining(c))
    return re.sub(r"\s+", " ", re.sub(r"[^\w\s]", " ", t)).strip()


def _h6(*partes) -> str:
    """Identidad estable por contenido.

    El esquema escribe los ids como `MIL-{nnn}`. Aquí el sufijo es un hash y no
    un consecutivo a propósito: un consecutivo cambia si el documento se
    reordena, y choca cuando dos fuentes alimentan la misma tabla. Un id que no
    sobrevive a la re-extracción rompe la idempotencia del rebuild.
    """
    return hashlib.sha1("|".join(partes).encode("utf-8")).hexdigest()[:6]


def _limpia(txt: str) -> str:
    txt = VINETA.sub("", txt)
    txt = re.sub(r"[*_`]{1,3}", "", txt)
    txt = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", txt)
    return re.sub(r"\s+", " ", txt).strip()


def _titulo(frase: str, limite: int = 90) -> str:
    frase = frase.strip().rstrip(".")
    if len(frase) <= limite:
        return frase
    corte = frase[:limite].rsplit(" ", 1)[0]
    return corte.rstrip(",;:") + "…"


def _numero(txt: str) -> float | None:
    try:
        return float(txt.replace(",", ""))
    except (TypeError, ValueError):
        return None


class Frase:
    __slots__ = ("texto", "linea", "seccion")

    def __init__(self, texto, linea, seccion):
        self.texto, self.linea, self.seccion = texto, linea, seccion


#: Dónde termina una oración. El salto de línea NO está aquí a propósito.
CORTE = re.compile(r"(?<=[.;!?])\s+(?=[A-ZÁÉÍÓÚÑ¿¡])")


def segmentar(texto: str) -> list:
    """Parte el documento en frases, cada una con su línea y su sección.

    Se arma el párrafo antes de cortar las oraciones. Cortando línea por línea
    salía una oración partida por cada salto de renglón, y como el extractor
    exige año y verbo en la MISMA frase, media trayectoria se perdía en el
    corte: el documento tenía siete hitos y la primera versión cosechó cuatro.
    Un markdown viene envuelto a setenta y tantas columnas y eso no es
    estructura, es tipografía.

    La sección importa tanto como la frase: bajo "Nuestros pilares", una
    oración sin ningún marcador sigue siendo un pilar, y esa es la mitad del
    trabajo que un extractor mecánico puede hacer bien.
    """
    frases, seccion, buffer = [], "", []

    def vaciar():
        if not buffer:
            return
        # Se conserva en qué línea empieza cada trozo para que la procedencia
        # apunte al renglón real y no al principio del párrafo.
        partes, cursor, inicios = [], 0, []
        for n, cuerpo in buffer:
            inicios.append((cursor, n))
            partes.append(cuerpo)
            cursor += len(cuerpo) + 1
        parrafo = " ".join(partes)
        pos = 0
        for trozo in CORTE.split(parrafo):
            arranque = parrafo.find(trozo, pos)
            if arranque < 0:
                arranque = pos
            pos = arranque + len(trozo)
            linea = inicios[0][1]
            for desplazamiento, n in inicios:
                if desplazamiento <= arranque:
                    linea = n
                else:
                    break
            trozo = trozo.strip()
            if len(trozo) >= 15:
                frases.append(Frase(trozo, linea, seccion))
        buffer.clear()

    for n, linea in enumerate(texto.splitlines(), start=1):
        enc = ENCABEZADO.match(linea)
        if enc:
            vaciar()
            seccion = _limpia(enc.group(2))
            continue
        cuerpo = _limpia(linea)
        if not cuerpo:
            vaciar()
            continue
        # Una viñeta es una unidad en sí misma: no se pega a la anterior.
        if VINETA.match(linea):
            vaciar()
        buffer.append((n, cuerpo))
    vaciar()
    return frases


def _tipo_por(patrones, texto) -> str | None:
    for tipo, patron in patrones:
        if re.search(patron, texto, re.I):
            return tipo
    return None


class DocIdentidad(contrato.Extractor):
    id = "doc-identidad"
    familia = "parser"
    #: Todo lo que es texto y habla del negocio. Lo que cambia entre ellos no
    #: es cómo se lee sino qué tier admite, y de eso se encarga la tabla F2.
    tipos_fuente = ("doc", "doc_tecnico", "doc_sin_linaje", "firmado",
                    "regulacion", "ppt", "minuta", "audio")
    #: `driver_links` no está, y no por olvido: ver el encabezado del módulo.
    tablas = ("company_profile", "business_milestones", "strategic_drivers",
              "measurements")

    def extraer(self, fuente, *, documento, slug, periodo=None, razon_social=None,
                nombre=None, pais=None, **_):
        ruta = Path(documento)
        if ruta.suffix.lower() not in EXTENSIONES:
            raise ValueError(
                f"{ruta.name}: este parser lee texto ({', '.join(sorted(EXTENSIONES))}). "
                f"Convierte antes el binario y registra la conversión como la "
                f"fuente: un PDF leído a medias es peor que un hueco declarado")
        texto = ruta.read_text(encoding="utf-8", errors="replace")
        frases = segmentar(texto)
        cosecha = self.nueva_cosecha(fuente)
        techo = fuente.natural_tier
        hoy = date.today().isoformat()

        hitos = self._hitos(cosecha, fuente, frases, techo)
        drivers = self._drivers(cosecha, fuente, frases, techo)
        cifras = self._cifras(cosecha, fuente, frases, techo, slug, periodo, hoy)
        self._perfil(cosecha, fuente, texto, frases, techo, slug,
                     razon_social, nombre, pais, hitos, hoy)

        self._huecos(cosecha, fuente, drivers, hitos, cifras, hoy)
        return cosecha

    # ── business_milestones ──────────────────────────────────────────────────

    def _hitos(self, cosecha, fuente, frases, techo) -> list:
        vistos, emitidos = set(), []
        for f in frases:
            anios = ANIO.findall(f.texto)
            if not anios:
                continue
            tipo = _tipo_por(HITOS, f.texto)
            if not tipo:
                continue
            clave = (tipo, anios[0], _norma(f.texto)[:120])
            if clave in vistos:
                continue
            vistos.add(clave)
            mid = f"MIL-{_h6(fuente.id, tipo, anios[0], _norma(f.texto))}"
            cosecha.agregar(
                "business_milestones",
                {"id": mid, "occurred_year": int(anios[0]), "milestone_type": tipo,
                 "title": _titulo(f.texto), "description": f.texto,
                 # El efecto en el negocio no se infiere del verbo: lo pone
                 # quien conoce la empresa. NULL declarado es mejor que un
                 # impacto inventado.
                 "impact": None},
                source_ref=_ref(fuente, f), tier=techo, confianza="inferred")
            emitidos.append(mid)
        return emitidos

    # ── strategic_drivers ────────────────────────────────────────────────────

    def _drivers(self, cosecha, fuente, frases, techo) -> list:
        vistos, emitidos = set(), []
        for f in frases:
            tipo = _tipo_por(DRIVERS, f.texto)
            confianza = "declared" if tipo else "inferred"
            if not tipo and f.seccion:
                tipo = _tipo_por(SECCIONES, f.seccion)
                # Bajo un encabezado de estrategia, una frase corta suele ser
                # un conector, no un driver. El umbral evita cosechar ruido.
                if tipo and len(f.texto) < 40:
                    tipo = None
            if not tipo:
                continue
            clave = (tipo, _norma(f.texto)[:120])
            if clave in vistos:
                continue
            vistos.add(clave)
            did = f"DRV-{_h6(fuente.id, tipo, _norma(f.texto))}"
            hz = HORIZONTE.search(f.texto)
            cosecha.agregar(
                "strategic_drivers",
                {"id": did, "driver_type": tipo, "title": _titulo(f.texto),
                 "description": f.texto,
                 "horizon": hz.group(1) if hz else None,
                 "priority": "alta" if PRIORIDAD_ALTA.search(f.texto) else None,
                 "status": "declarado",
                 "declared_by": fuente.name},
                source_ref=_ref(fuente, f), tier=techo, confianza=confianza)
            emitidos.append(did)
        return emitidos

    # ── measurements ─────────────────────────────────────────────────────────

    def _cifras(self, cosecha, fuente, frases, techo, slug, periodo, hoy) -> list:
        vistos, emitidos, sin_fecha = set(), [], 0
        for f in frases:
            for metrica, valor, unidad in _cifras_de(f.texto):
                anios = ANIO.findall(f.texto)
                cuando = anios[0] if anios else (str(periodo) if periodo else None)
                if not cuando:
                    # `measured_at` es NOT NULL y una cifra sin año no se
                    # rellena con la fecha de carga: eso falsea la ventana
                    # temporal que B40 exige. Se declara el hueco y se tira.
                    sin_fecha += 1
                    continue
                clave = (metrica, valor, unidad, cuando)
                if clave in vistos:
                    continue
                vistos.add(clave)
                # "Reducir el índice por debajo de 45% al 2027" no es una
                # medición: es una meta. Cargarla como `report` mete el futuro
                # en la serie histórica y nadie vuelve a distinguirlos. El
                # esquema ya tiene el valor para decirlo.
                meta = bool(HORIZONTE.search(f.texto)) or int(cuando) > date.today().year
                cosecha.agregar(
                    "measurements",
                    {"entity_table": "company_profile", "entity_id": slug,
                     "metric": metrica, "value_num": valor, "value_text": None,
                     "unit": unidad, "measured_at": f"{cuando}-12-31",
                     "period_start": f"{cuando}-01-01", "period_end": f"{cuando}-12-31",
                     "source_type": "forecast" if meta else "report",
                     "process_id": None, "recorded_at": hoy},
                    source_ref=_ref(fuente, f), tier=techo, confianza="inferred")
                emitidos.append(metrica)
        if sin_fecha:
            cosecha.hueco(
                id=f"GAP-{_h6(fuente.id, 'cifras-sin-anio')}", gap_type="dato",
                dimension="negocio", domain="identidad", process_id=None,
                description=(f"{sin_fecha} cifra(s) de {fuente.name} no traen año y se "
                             f"descartaron: measured_at no se rellena con la fecha de carga"),
                impact="La serie de negocio queda incompleta y sin ventana temporal (B40)",
                required_for="Etapa 0 — Identidad",
                resolution_action=(f"Consulta dt-client-intelligence: ¿a qué ejercicio "
                                   f"corresponden las cifras de {fuente.name}? "
                                   f"Alternativa: re-extraer con --periodo"),
                owner="dt-client-intelligence", status="open",
                opened_at=hoy, resolved_at=None)
        return emitidos

    # ── company_profile ──────────────────────────────────────────────────────

    def _perfil(self, cosecha, fuente, texto, frases, techo, slug,
                razon_social, nombre, pais, hitos, hoy):
        cabeza = "\n".join(texto.splitlines()[:60])
        if not razon_social:
            m = RAZON_SOCIAL.search(cabeza)
            razon_social = m.group(1).strip(" ,") if m else None
        if not nombre and razon_social:
            nombre = re.sub(r",?\s*S\.?\s?A\.?\s?B?\.?(\s+de\s+C\.?\s?V\.?)?$", "",
                            razon_social).strip()
        if not (razon_social and nombre):
            # NOT NULL en el DDL. Sin razón social no hay ficha, y la ficha no
            # se inventa del nombre del archivo.
            cosecha.hueco(
                id=f"GAP-{_h6(fuente.id, 'perfil-sin-nombre')}", gap_type="dato",
                dimension="negocio", domain="identidad", process_id=None,
                description=(f"No se pudo determinar la razón social en {fuente.name}; "
                             f"company_profile no se emitió"),
                impact="La Etapa 0 no tiene ancla: measurements y driver_links "
                       "cuelgan de company_profile.slug",
                required_for="Etapa 0 — Identidad",
                resolution_action=("Consulta dt-client-intelligence: ¿cuál es la razón "
                                   "social y el nombre de mercado? Re-extraer con "
                                   "--razon-social y --nombre"),
                owner="dt-client-intelligence", status="open",
                opened_at=hoy, resolved_at=None)
            return

        fundacion = None
        for f in frases:
            if re.search(HITOS[0][1], f.texto, re.I):
                anios = ANIO.findall(f.texto)
                if anios:
                    fundacion = int(min(anios))
                    break
        tk = TICKER.search(texto)
        fila = {
            "slug": slug, "legal_name": razon_social, "display_name": nombre,
            "founded_year": fundacion,
            # Lo que sigue no se infiere de un documento sin arriesgar una
            # ficha falsa. Va NULL y se declara abajo.
            "ownership": "publica" if tk else None,
            "parent_group": None, "ticker": tk.group(1) if tk else None,
            "hq_country": pais, "geographies": None, "industries": None,
            "business_model": None,
        }
        cosecha.agregar("company_profile", fila, source_ref=f"{fuente.id}#perfil",
                        tier=techo, confianza="inferred")
        faltan = [c for c in ("ownership", "parent_group", "hq_country",
                              "geographies", "industries", "business_model")
                  if fila[c] is None]
        if faltan:
            cosecha.hueco(
                id=f"GAP-{_h6(fuente.id, 'perfil-incompleto')}", gap_type="dato",
                dimension="negocio", domain="identidad", process_id=None,
                description=f"company_profile de {slug} sin {', '.join(faltan)}",
                impact="La ficha de identidad queda parcial y el brain no puede "
                       "responder dónde opera la empresa ni cómo gana dinero",
                required_for="Etapa 0 — Identidad",
                resolution_action=(f"Consulta dt-client-intelligence: para {nombre}, "
                                   f"¿{', '.join(faltan)}?"),
                owner="dt-client-intelligence", status="open",
                opened_at=hoy, resolved_at=None)

    # ── knowledge_gaps ───────────────────────────────────────────────────────

    def _huecos(self, cosecha, fuente, drivers, hitos, cifras, hoy):
        for did in drivers:
            # El criterio de salida de la Etapa 0, hecho fila. Un documento no
            # conoce el estate: no puede atar un driver a una capability.
            cosecha.hueco(
                id=f"GAP-{_h6(fuente.id, 'link', did)}", gap_type="dato",
                dimension="negocio", domain="identidad", process_id=None,
                description=f"{did} no tiene ningún elemento del estate que lo sirva",
                impact="Sin driver_links el estudio del cliente es prólogo y no eje "
                       "rector: nadie puede preguntarle al brain qué sostiene este driver",
                required_for="Etapa 0 — criterio de salida",
                resolution_action=(f"Consulta dt-client-intelligence: ¿qué capability, "
                                   f"producto, proceso o regla sirve a {did}? Si no hay "
                                   f"ninguno, no es brecha de extracción sino hallazgo "
                                   f"de negocio, y vale más que el link"),
                owner="dt-client-intelligence", status="open",
                opened_at=hoy, resolved_at=None)

        vacias = {"business_milestones": hitos, "strategic_drivers": drivers,
                  "measurements": cifras}
        for tabla, emitidos in vacias.items():
            if emitidos:
                continue
            cosecha.hueco(
                id=f"GAP-{_h6(fuente.id, 'vacia', tabla)}", gap_type="dato",
                dimension="negocio", domain="identidad", process_id=None,
                description=f"{fuente.name} no produjo ninguna fila de {tabla}",
                impact="O el documento no cubre esa dimensión, o el extractor no sabe "
                       "leer cómo la nombra. Las dos se arreglan distinto",
                required_for="Etapa 0 — Identidad",
                resolution_action=(f"Consulta dt-source-steward: ¿hay otra fuente que "
                                   f"cubra {tabla} para este cliente? Si la fuente sí la "
                                   f"cubre, el vocabulario del extractor se queda corto"),
                owner="dt-source-steward", status="open",
                opened_at=hoy, resolved_at=None)

        if fuente.ambigua:
            cosecha.hueco(
                id=f"GAP-{_h6(fuente.id, 'tipo-ambiguo')}", gap_type="source",
                dimension="negocio", domain="fuentes", process_id=None,
                description=(f"{fuente.id} se registró como '{fuente.source_type}', que "
                             f"no distingue linaje; la cosecha entró al piso"),
                impact="Todo lo extraído queda en bronze aunque la fuente sea un "
                       "artefacto firmado",
                required_for="Etapa 0 — Identidad",
                resolution_action=(f"Consulta dt-source-steward: ¿{fuente.name} es "
                                   f"{' o '.join(tiers.AMBIGUOS[fuente.source_type])}?"),
                owner="dt-source-steward", status="open",
                opened_at=hoy, resolved_at=None)


def _ref(fuente, frase) -> str:
    """Procedencia hasta la línea. Sin esto el contrato rechaza el registro."""
    if frase.seccion:
        return f"{fuente.id}#{frase.seccion}:L{frase.linea}"
    return f"{fuente.id}#L{frase.linea}"


def _antes_de(texto: str, pos: int) -> str:
    """Lo que la cifra tiene inmediatamente a su izquierda.

    La métrica se decide por lo que está pegado al número, no por la frase
    entera. "Los ingresos alcanzaron 18,400 millones, con una utilidad neta de
    2,750 millones" trae dos cifras distintas y leyendo la oración completa las
    dos salían como ingresos.
    """
    ventana = texto[max(0, pos - 70):pos]
    corte = max(ventana.rfind(","), ventana.rfind(";"), ventana.rfind(" y "))
    return ventana[corte + 1:] if corte >= 0 else ventana


def _metrica(patrones, texto, pos, defecto):
    return (_tipo_por(patrones, _antes_de(texto, pos))
            or _tipo_por(patrones, texto) or defecto)


def _cifras_de(texto: str):
    """Las cifras de una frase, ya normalizadas a (métrica, valor, unidad)."""
    salida = []
    for m in CIFRA_MONEDA.finditer(texto):
        simbolo, crudo, escala, moneda = m.groups()
        if not (simbolo or moneda):
            continue  # un número suelto no es una cifra de negocio
        valor = _numero(crudo)
        if valor is None:
            continue
        valor *= MULTIPLOS.get((escala or "").lower().strip(), 1)
        unidad = "USD" if re.search(r"USD|d[óo]lar", f"{simbolo}{moneda}", re.I) else "MXN"
        if (escala or "").lower() == "mdd":
            unidad = "USD"
        salida.append((_metrica(METRICAS_MONEDA, texto, m.start(), "monto"),
                       valor, unidad))
    for m in CIFRA_PCT.finditer(texto):
        valor = _numero(m.group(1))
        if valor is not None:
            salida.append((_metrica(METRICAS_PCT, texto, m.start(), "porcentaje"),
                           valor, "%"))
    for m in CIFRA_CONTEO.finditer(texto):
        valor = _numero(m.group(1))
        if valor is not None:
            salida.append((m.group(2).lower(), valor, m.group(2).lower()))
    return salida


def main():
    ap = argparse.ArgumentParser(
        description="Extrae los candidatos de la Etapa 0 de un documento de texto")
    ap.add_argument("--fuente", required=True, help="id en source_catalog, ej. SRC-003")
    ap.add_argument("--catalogo", required=True,
                    help="source-catalog.md de la instancia, o su brain.db")
    ap.add_argument("--slug", required=True, help="el mismo slug que system_info")
    ap.add_argument("--documento", help="por omisión, el location de la fuente")
    ap.add_argument("--salida", help="por omisión, knowledge-base/extracted/")
    ap.add_argument("--periodo", help="ejercicio al que pertenecen las cifras sin año")
    ap.add_argument("--razon-social")
    ap.add_argument("--nombre")
    ap.add_argument("--pais")
    ap.add_argument("--dry-run", action="store_true", help="no escribe nada")
    ap.add_argument("--json", action="store_true", help="imprime la cosecha completa")
    a = ap.parse_args()

    catalogo = contrato.Catalogo.desde(Path(a.catalogo))
    fuente = catalogo.obtener(a.fuente)
    documento = a.documento or fuente.location
    if not documento:
        raise SystemExit(f"{fuente.id} no declara location y no se pasó --documento")

    cosecha = DocIdentidad().ejecutar(
        fuente, documento=documento, slug=a.slug, periodo=a.periodo,
        razon_social=a.razon_social, nombre=a.nombre, pais=a.pais)

    if a.json:
        print(json.dumps(cosecha.a_dict(), ensure_ascii=False, indent=2))
        return

    print(f"{cosecha.extractor} · {fuente.id} · {fuente.name}")
    print(f"  tier natural: {fuente.natural_tier} — {tiers.razon(fuente.source_type)}")
    for tabla, n in cosecha.resumen().items():
        print(f"  {tabla}: {n}")
    for sello in cosecha.sellos:
        print(f"  [sello] {sello}")

    if a.dry_run:
        print("  DRY-RUN — no se escribió nada")
        return
    salida = Path(a.salida) if a.salida else Path(a.catalogo).parent / "extracted"
    destino = cosecha.a_json(salida)
    print(f"  escrito: {destino}")


if __name__ == "__main__":
    main()
