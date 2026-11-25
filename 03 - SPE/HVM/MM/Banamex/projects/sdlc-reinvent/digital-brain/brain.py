#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
brain.py - API de consulta del Digital Brain de SDLC Reinvent (Banamex).

    from brain import SdlcBrain
    with SdlcBrain() as b:
        b.estado_del_deal()
        b.objeciones()
        b.que_tan_aterrizada()

No es un almacen de documentos: es un motor de razonamiento sobre la propuesta y
sobre el ciclo de entrega del banco. Las preguntas que contesta son de decision.

Los brains del Laboratorio de Aceleracion y del core Unisys se federan POR
REFERENCIA. Se abren en solo lectura cuando hacen falta y su corpus nunca se
duplica aqui. Del core solo se leen agregados: ningun nombre de persona entra.
"""
from __future__ import annotations

import sqlite3
from datetime import date
from pathlib import Path
from typing import Any

_BASE = Path(__file__).resolve().parent
_DB = _BASE / "sdlc-brain.db"
_LAB = _BASE.parents[1] / "laboratorio-aceleracion" / "digital-brain" / "lab-brain.db"
_CORE = _BASE.parents[2] / "systems" / "core" / "unisys" / "digital-brain" / "brain.db"


class SdlcBrain:
    def __init__(self, db_path: str | Path = _DB,
                 lab_path: str | Path = _LAB,
                 core_path: str | Path = _CORE):
        self.path = Path(db_path)
        if not self.path.exists():
            raise FileNotFoundError(
                f"No existe {self.path}. Corre primero: PYTHONUTF8=1 python build-brain.py"
            )
        self.conn = sqlite3.connect(f"file:{self.path}?mode=ro", uri=True)
        self.conn.row_factory = sqlite3.Row
        self.lab_path = Path(lab_path)
        self.core_path = Path(core_path)

    def close(self):
        self.conn.close()

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()

    # ---------------- helpers ----------------

    def _q(self, sql: str, params=()) -> list[dict]:
        return [dict(r) for r in self.conn.execute(sql, params)]

    def _one(self, sql: str, params=()) -> dict | None:
        r = self.conn.execute(sql, params).fetchone()
        return dict(r) if r else None

    @staticmethod
    def _ro(path: Path) -> sqlite3.Connection | None:
        if not path.exists():
            return None
        c = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
        c.row_factory = sqlite3.Row
        return c

    def stats(self) -> dict[str, int]:
        return {r["clave"]: r["valor"] for r in self._q("SELECT clave, valor FROM stats")}

    # ---------------- capa 0: mandato y partnership ----------------

    def narrativa_consejo(self, solo_ancla: bool = False) -> list[dict]:
        """Compromisos de la narrativa de valor presentada al consejo."""
        sql = "SELECT * FROM narrativa_consejo"
        if solo_ancla:
            sql += " WHERE ancla_sdlc = 1"
        return self._q(sql + " ORDER BY id")

    def mandato(self) -> dict:
        """
        De que compromiso del consejo cuelga este proyecto. Sirve para abrir la
        conversacion sin pedir permiso: el tema ya fue aprobado.
        """
        anclas = self.narrativa_consejo(solo_ancla=True)
        return {
            "anclas": anclas,
            "lectura": ("La productividad del desarrollador y el time to market aparecen dos veces "
                        "en la narrativa que el consejo aprobo. SDLC Reinvent instrumenta un "
                        "compromiso existente, no abre un tema nuevo."),
        }

    def partnership(self) -> dict:
        return {
            "areas": self._q("SELECT * FROM partnership_areas ORDER BY id"),
            "modelo": self._q("SELECT * FROM partnership_modelo ORDER BY id"),
            "esta_area": self._one("SELECT * FROM partnership_areas WHERE es_este_proyecto = 1"),
        }

    # ---------------- capa 1: el ciclo ----------------

    def etapas(self) -> list[dict]:
        return self._q("SELECT * FROM etapas ORDER BY orden")

    def friccion(self, etapa: str | None = None, solo_observada: bool = False) -> list[dict]:
        sql = "SELECT * FROM friccion WHERE 1=1"
        p: list[Any] = []
        if etapa:
            sql += " AND etapa = ?"
            p.append(etapa)
        if solo_observada:
            sql += " AND estado = 'OBSERVADA'"
        return self._q(sql + " ORDER BY etapa, id", tuple(p))

    def cuellos_de_botella(self) -> list[dict]:
        filas = self._q("""
            SELECT e.id, e.orden, e.nombre,
                   SUM(CASE WHEN f.estado='OBSERVADA' THEN 1 ELSE 0 END) AS observada,
                   SUM(CASE WHEN f.estado='HIPOTESIS' THEN 1 ELSE 0 END) AS hipotesis
            FROM etapas e LEFT JOIN friccion f ON f.etapa = e.id
            GROUP BY e.id ORDER BY observada DESC, hipotesis DESC, e.orden
        """)
        return [f for f in filas if (f["observada"] or 0) + (f["hipotesis"] or 0) > 0]

    def diagnostico(self, solo_fragiles: bool = False) -> list[dict]:
        """
        Las cifras con las que abre la propuesta. No son linea base medida: son
        el assessment de Accenture, y varias cargan un anio de antiguedad.
        """
        sql = "SELECT * FROM diagnostico"
        if solo_fragiles:
            sql += " WHERE estado LIKE '%ANTIGUEDAD%' OR estado LIKE '%VALIDAR%'"
        return self._q(sql + " ORDER BY id")

    def metricas(self, familia: str | None = None) -> list[dict]:
        if familia:
            return self._q("SELECT * FROM metricas WHERE familia = ? ORDER BY id", (familia,))
        return self._q("SELECT * FROM metricas ORDER BY familia, id")

    def linea_base(self) -> dict:
        """
        Cuanto del desempeno esta medido. Las metricas de control nacen con
        umbral y las de adopcion solo se miden en el piloto, asi que la cuenta
        se hace sobre la familia de desempeno.
        """
        des = self.metricas(familia="Desempeno")
        con_base = [m for m in des if m["linea_base"] is not None]
        cobertura = round(100.0 * len(con_base) / len(des), 1) if des else 0.0
        dg = self.diagnostico()
        return {
            "metricas_de_desempeno": len(des),
            "con_linea_base": len(con_base),
            "cobertura_pct": cobertura,
            "faltantes": [m["id"] for m in des if m["linea_base"] is None],
            "hay_diagnostico": len(dg),
            "diagnostico_fragil": len(self.diagnostico(solo_fragiles=True)),
            "veredicto": ("Diagnostico si, linea base medida no" if cobertura == 0
                          else "Linea base parcial" if cobertura < 80
                          else "Linea base suficiente"),
        }

    # ---------------- capa 2: la propuesta ----------------

    def gates(self) -> list[dict]:
        return self._q("SELECT * FROM gates ORDER BY orden")

    def rutas(self) -> list[dict]:
        return self._q("SELECT * FROM rutas ORDER BY id")

    def fases(self) -> list[dict]:
        return self._q("SELECT * FROM fases ORDER BY orden")

    def entregables(self, fase: str | None = None, valor: str | None = None) -> list[dict]:
        sql = "SELECT * FROM entregables WHERE 1=1"
        p: list[Any] = []
        if fase:
            sql += " AND fase = ?"
            p.append(fase.upper())
        if valor:
            sql += " AND valor LIKE ?"
            p.append(f"{valor.upper()}%")
        return self._q(sql + " ORDER BY valor, id", tuple(p))

    def que_compraria_el_banco(self) -> dict:
        """
        Los entregables ordenados por lo que cambian en el banco, no por la fase
        en que se entregan. El criterio es duro: que pasa el dia despues.
        """
        todos = self.entregables()
        alto = [e for e in todos if e["valor"].startswith("ALTO")]
        doc = [e for e in todos if e["valor"] == "DOCUMENTO"]
        perdidos = [e for e in todos if "SE CAYO" in (e["estado"] or "")]
        return {
            "alto_valor": alto,
            "documentos": doc,
            "perdidos_en_la_version_nueva": perdidos,
            "lectura": (f"{len(alto)} de {len(todos)} cambian algo en el banco y {len(doc)} son "
                        "documentos. Dos de los de alto valor, el MVP tecnico y el equipo "
                        "habilitado, estaban en la v3.3 y se cayeron de la version nueva: son "
                        "justo los que eran capacidad instalada y no papel."),
        }

    # ---------------- capa 3: toolchain ----------------

    def herramientas(self, estado: str | None = None) -> list[dict]:
        if estado:
            return self._q("SELECT * FROM herramientas WHERE estado = ? ORDER BY id", (estado.upper(),))
        return self._q("SELECT * FROM herramientas ORDER BY categoria, id")

    def contradicciones(self, solo_abiertas: bool = True) -> list[dict]:
        sql = "SELECT * FROM contradicciones"
        if solo_abiertas:
            sql += " WHERE estado = 'ABIERTA'"
        return self._q(sql + " ORDER BY CASE impacto WHEN 'ALTO' THEN 0 ELSE 1 END, id")

    # ---------------- capa 4: programa y vecindario ----------------

    def componentes(self) -> list[dict]:
        return self._q("SELECT * FROM componentes ORDER BY id")

    def componente(self, cid: str) -> dict | None:
        return self._one("SELECT * FROM componentes WHERE id = ?", (cid.upper(),))

    def vecinas(self) -> list[dict]:
        return self._q("SELECT * FROM iniciativas_vecinas ORDER BY id")

    def dependencias(self, cid: str | None = None) -> list[dict]:
        if cid:
            return self._q(
                "SELECT * FROM dependencias WHERE de_componente = ? OR a_componente = ? ORDER BY id",
                (cid.upper(), cid.upper()),
            )
        return self._q("SELECT * FROM dependencias ORDER BY id")

    def hitos(self, desde: str | None = None) -> list[dict]:
        desde = desde or date.today().isoformat()
        return self._q("SELECT * FROM hitos WHERE fecha != '' AND fecha >= ? ORDER BY fecha", (desde,))

    def hitos_sin_fecha(self) -> list[dict]:
        return self._q("SELECT * FROM hitos WHERE fecha = '' ORDER BY id")

    def ruta_critica(self) -> dict:
        proximos = self.hitos()
        if not proximos:
            return {"proximo": None, "dias": None, "sin_fecha": self.hitos_sin_fecha()}
        h = proximos[0]
        y, m, d = (int(x) for x in h["fecha"].split("-"))
        return {
            "proximo": h,
            "dias": (date(y, m, d) - date.today()).days,
            "siguientes": proximos[1:],
            "sin_fecha": self.hitos_sin_fecha(),
        }

    # ---------------- capa 5: razonamiento ----------------

    def objeciones(self, solo_abiertas: bool = True) -> list[dict]:
        """Lo que el cliente respondio al presentarle la propuesta."""
        sql = "SELECT * FROM objeciones"
        if solo_abiertas:
            sql += " WHERE estado = 'ABIERTA'"
        return self._q(sql + " ORDER BY id")

    def estado_del_deal(self) -> dict:
        """
        Donde esta realmente la propuesta. Mientras haya objeciones abiertas, el
        siguiente paso no es la sesion con la PMO sino el reencuadre.
        """
        obj = self.objeciones()
        comp = self.componente("C-00")
        return {
            "componente": comp,
            "objeciones": obj,
            "veredicto": ("DEVUELTA CON OBJECIONES" if obj else "SIN OBJECIONES REGISTRADAS"),
            "siguiente_paso": (self.hitos_sin_fecha()[0]["hito"] if self.hitos_sin_fecha() else None),
            "escenario": self.recomendar_escenario()["escenario"],
        }

    def que_tan_aterrizada(self) -> dict:
        """
        Cuanto de la propuesta es especifico de Banamex y cuanto se promete para
        despues. Es la objecion de poco aterrizada, medida contra el documento.
        """
        frag = self.diagnostico(solo_fragiles=True)
        ilus = self.herramientas(estado="ILUSTRATIVA")
        ob = self._one("SELECT * FROM objeciones WHERE id = 'OB-01'")
        return {
            "evidencia_del_cliente": ob["evidencia"] if ob else None,
            "cifras_fragiles": [{"id": d["id"], "hallazgo": d["hallazgo"], "estado": d["estado"]} for d in frag],
            "herramientas_sin_decidir": len(ilus),
            "decisiones_abiertas": len(self.decisiones_abiertas()),
            "contra_movimiento": ob["contra_movimiento"] if ob else None,
        }

    def casos_uso_ia(self, etapa_ruta: str | None = None, nivel: str | None = None) -> list[dict]:
        """
        Los 27 casos de uso de IA en el ciclo, sin nombre de producto. La
        herramienta se elige con el banco: lo que este catalogo fija es que hace
        la IA, con cuanta autonomia, que tiene que existir antes y cuando entra.
        """
        sql = "SELECT * FROM casos_uso_ia WHERE 1=1"
        p: list[Any] = []
        if etapa_ruta:
            sql += " AND entra_en = ?"
            p.append(etapa_ruta)
        if nivel:
            sql += " AND nivel = ?"
            p.append(nivel.upper())
        return self._q(sql + " ORDER BY id", tuple(p))

    def que_se_puede_hoy(self) -> dict:
        """
        Que casos de uso caben en la Etapa 1, es decir, en lo que de verdad
        estamos vendiendo. Es el alcance honesto de la primera conversacion.
        """
        e1 = self.casos_uso_ia(etapa_ruta="Etapa 1")
        todos = self.casos_uso_ia()
        return {
            "en_etapa_1": e1,
            "cuantos": f"{len(e1)} de {len(todos)}",
            "lectura": ("Los casos de la Etapa 1 no piden integracion continua ni pruebas "
                        "automatizadas: piden criterios escritos y acuerdos de proceso. "
                        "Por eso caben antes de los minimos tecnicos."),
        }

    def laminas(self) -> list[dict]:
        """Revision lamina por lamina del PoV, con el movimiento de cada una."""
        return self._q("SELECT * FROM laminas ORDER BY numero")

    def palancas(self, metrica: str | None = None, componente: str | None = None) -> list[dict]:
        filas = self._q("SELECT * FROM palancas ORDER BY id")
        if metrica:
            filas = [p for p in filas if metrica.upper() in (p["metrica"] or "")]
        if componente:
            filas = [p for p in filas if componente.upper() == (p["componente"] or "")]
        return filas

    def que_mueve(self, metrica_id: str) -> dict:
        m = self._one("SELECT * FROM metricas WHERE id = ?", (metrica_id.upper(),))
        if not m:
            return {"error": f"No existe la metrica {metrica_id}"}
        pal = self.palancas(metrica=metrica_id)
        return {
            "metrica": m,
            "palancas": pal,
            "medible_hoy": m["linea_base"] is not None,
        }

    # ---------------------------------------------------------------- DTs

    def dts(self, categoria: str | None = None) -> list[dict]:
        """Roster de Digital Twins. Detalle narrativo en dt/cobertura-dt.md."""
        filas = self._q("SELECT * FROM dts ORDER BY id")
        if categoria:
            filas = [d for d in filas if d["categoria"] == categoria.upper()]
        return filas

    def dt(self, did: str) -> dict | None:
        return self._one("SELECT * FROM dts WHERE id = ? OR slug = ?",
                         (did.upper(), did.lower()))

    def quien_responde(self, texto: str) -> list[dict]:
        """Que twin responde por una palanca, una metrica o un componente."""
        t = texto.upper()
        out = []
        for d in self.dts():
            donde = []
            if t in (d["palancas"] or ""):
                donde.append("es dueno de la palanca")
            if t in (d["mide"] or ""):
                donde.append("responde por medirla")
            if t in (d["mueve"] or ""):
                donde.append("responde por moverla")
            if t in (d["componente"] or "").upper():
                donde.append("es el twin del componente" if d["categoria"] == "A"
                             else "cruza el componente")
            if donde:
                out.append({"id": d["id"], "nombre": d["nombre"],
                            "relacion": " y ".join(donde),
                            "pregunta": d["pregunta"]})
        return out

    def dts_bloqueados(self) -> dict:
        """Quien espera algo del banco y quien puede avanzar hoy."""
        hoy, esperando = [], []
        for d in self.dts():
            (hoy if "PUEDE AVANZAR HOY" in (d["estado"] or "") else esperando).append(
                {"id": d["id"], "nombre": d["nombre"], "necesita": d["para_active"]})
        return {"pueden_avanzar_hoy": hoy, "esperan": esperando,
                "lectura": f"{len(esperando)} de {len(hoy) + len(esperando)} twins esperan "
                           "un dato del banco o una decision conjunta"}

    def guardrails(self, severidad: str | None = None) -> list[dict]:
        if severidad:
            return self._q("SELECT * FROM guardrails WHERE severidad = ? ORDER BY id", (severidad.upper(),))
        return self._q("SELECT * FROM guardrails ORDER BY id")

    def escenarios(self) -> list[dict]:
        return self._q("SELECT * FROM escenarios ORDER BY id")

    def recomendar_escenario(self) -> dict:
        """
        El escenario que corresponde al estado real. Con objeciones abiertas, el
        movimiento correcto es reencuadrar, no insistir ni escalar.
        """
        escs = {e["id"]: e for e in self.escenarios()}
        if self.objeciones():
            return {"escenario": escs["ESC-E"],
                    "razon": ("La propuesta fue devuelta por poco aterrizada y muy cara. "
                              "Volver con el mismo documento repite las dos objeciones.")}
        lb = self.linea_base()
        if lb["cobertura_pct"] < 80:
            return {"escenario": escs["ESC-A"],
                    "razon": "Sin linea base medida, el piloto es lo unico que produce evidencia propia."}
        return {"escenario": escs["ESC-B"],
                "razon": "Hay linea base suficiente para escalar por olas con criterio de paro."}

    def listo_para_comprometer(self) -> dict:
        """
        Se puede comprometer un numero de productividad con el cliente. Es el
        guardrail GR-01 hecho funcion, y ahora tambien protege el esquema de
        riesgo compartido del partnership.
        """
        razones: list[str] = []
        lb = self.linea_base()
        if lb["cobertura_pct"] < 80:
            razones.append(
                f"Cobertura de linea base {lb['cobertura_pct']} por ciento sobre las metricas de desempeno. "
                f"Hay diagnostico ({lb['hay_diagnostico']} cifras) pero {lb['diagnostico_fragil']} de ellas "
                "son no exhaustivas o cargan un anio de antiguedad"
            )
        altas = [c for c in self.contradicciones() if c["impacto"] == "ALTO"]
        if altas:
            razones.append("Contradicciones de toolchain de impacto alto sin resolver: "
                           + ", ".join(c["id"] for c in altas))
        dr = [b for b in self.brechas() if b["estado"] == "DATO-REQUERIDO"]
        if dr:
            razones.append(f"{len(dr)} brechas marcadas como dato requerido del banco")
        if self.objeciones():
            razones.append("La propuesta esta devuelta con objeciones abiertas")
        return {
            "veredicto": "NO" if razones else "SI",
            "razones": razones,
            "guardrail": self._one("SELECT * FROM guardrails WHERE id = 'GR-01'"),
            "alternativa": ("Comprometer el metodo y la cadencia de medicion, no el porcentaje"
                            if razones else "Se puede comprometer con la evidencia del piloto"),
        }

    # ---------------- capa 6: gobierno ----------------

    def brechas(self, solo_dato_requerido: bool = False) -> list[dict]:
        sql = "SELECT * FROM brechas"
        if solo_dato_requerido:
            sql += " WHERE estado = 'DATO-REQUERIDO'"
        return self._q(sql + " ORDER BY id")

    def datos_requeridos(self) -> list[dict]:
        return self._q("""
            SELECT id, brecha, impacto, bloquea FROM brechas
            WHERE estado = 'DATO-REQUERIDO' AND quien_resuelve LIKE '%Banamex%'
            ORDER BY id
        """)

    def decisiones_abiertas(self) -> list[dict]:
        return self._q("SELECT * FROM decisiones_abiertas WHERE estado = 'ABIERTA' ORDER BY id")

    def interno(self) -> list[dict]:
        """Material marcado como no compartible con el cliente. Ver GR-08."""
        return self._q("SELECT * FROM interno ORDER BY id")

    def fuentes(self) -> list[dict]:
        return self._q("SELECT * FROM fuentes ORDER BY id")

    # ------------------------------------------------------------------
    # Capa 7: a quien le vendemos, contra quien competimos, con que doctrina
    # ------------------------------------------------------------------

    def proceso_asis(self) -> list[dict]:
        """Las seis etapas del levantamiento de octubre de 2025, con insumos y herramientas."""
        return self._q("SELECT * FROM etapas ORDER BY orden")

    def controles(self, solo_en_riesgo: bool = False) -> list[dict]:
        """Puntos de control nombrados en el as-is. Ver proceso-asis-2025.md."""
        sql = "SELECT * FROM controles_asis"
        if solo_en_riesgo:
            sql += " WHERE sobrevive_separacion NOT LIKE 'SI%'"
        return self._q(sql + " ORDER BY id")

    def proceso_prestado(self) -> dict:
        """Responde si el ciclo documentado sobrevive a la separacion de la matriz.

        Es el hallazgo que convierte el rediseno del ciclo en entregable obligatorio
        del programa de separacion, en lugar de una mejora de eficiencia opcional.
        """
        ctr = self._q("SELECT * FROM controles_asis ORDER BY id")
        herr = self._q("SELECT * FROM herramientas_asis ORDER BY id")
        no_sobreviven = [c for c in ctr if c["sobrevive_separacion"].startswith("NO")]
        dudosos = [c for c in ctr if "CONFIRMAR" in c["sobrevive_separacion"]]
        herr_matriz = [h for h in herr if "MATRIZ" in (h["duenio"] or "").upper()]
        sin_resultado = self._q("SELECT * FROM etapas WHERE resultados LIKE 'Ninguno%'")
        return {
            "controles_totales": len(ctr),
            "no_sobreviven": no_sobreviven,
            "por_confirmar": len(dudosos),
            "herramientas_de_la_matriz": herr_matriz,
            "etapas_sin_resultado": sin_resultado,
            "veredicto": (
                f"De {len(ctr)} controles nombrados, {len(no_sobreviven)} no sobreviven a la separacion "
                f"y {len(dudosos)} estan por confirmar. {len(herr_matriz)} de 7 herramientas es de la matriz. "
                "El ciclo documentado es prestado: rediseñarlo no es una mejora opcional, "
                "es un entregable del programa de separacion con la misma fecha dura."
            ),
        }

    def quien_es_leyva(self) -> dict:
        """Perfil del interlocutor. Responde que NO se le puede vender."""
        hitos = self._q("SELECT * FROM interlocutor ORDER BY id")
        acn = [h for h in hitos if "Accenture" in (h["hecho"] or "")]
        return {
            "hitos": hitos,
            "fue_consultor_de_accenture": bool(acn),
            "anios_en_accenture": acn[0]["periodo"] if acn else None,
            "dirigio_organizacion_de_software": "Area global de Software de BBVA, mas de 16,000 personas, enero de 2022",
            "no_vender": [
                "Metodologia. Dirigio la fabrica de software de BBVA y adopto Agile en Mexico en 2015",
                "Explicaciones de que es un ciclo de entrega, un gate o por que medir",
                "Propuestas con relleno. Fue consultor nuestro seis anios y sabe reconocerlo",
            ],
            "si_vender": [
                "Datos de su propio banco que hoy no tiene, empezando por la linea base del ciclo",
                "Capacidad de ejecucion inmediata, porque no alcanza a contratar al ritmo del plan",
                "El inventario del core, que nosotros tenemos y el no",
            ],
        }

    def citas(self, solo_vigentes: bool = False) -> list[dict]:
        """Frases del interlocutor con fecha y vigencia declarada."""
        sql = "SELECT * FROM citas_interlocutor"
        if solo_vigentes:
            sql += " WHERE vigencia LIKE 'VIGENTE%'"
        return self._q(sql + " ORDER BY fecha, id")

    def benchmark(self, banco: str | None = None) -> list[dict]:
        if banco:
            return self._q("SELECT * FROM benchmark WHERE banco = ? ORDER BY id", (banco,))
        return self._q("SELECT * FROM benchmark ORDER BY banco, id")

    def pov_casa(self, solo_con_cuidado: bool = False) -> list[dict]:
        """Elementos del Punto de Vista de firma sobre ciclo con IA."""
        sql = "SELECT * FROM pov_casa"
        if solo_con_cuidado:
            sql += " WHERE cuidado IS NOT NULL"
        return self._q(sql + " ORDER BY lamina, id")

    def donde_se_va_el_tiempo(self) -> dict:
        """Las seis bolsas del tiempo de salida y que tan solida es la evidencia de cada una."""
        bolsas = self._q("SELECT * FROM bolsas_tiempo ORDER BY id")
        propias = [b for b in bolsas if (b["calidad"] or "").startswith("PROPIA")]
        faltantes = [b for b in bolsas if b["calidad"] == "DATO-REQUERIDO"]
        return {
            "bolsas": bolsas,
            "con_evidencia_propia": propias,
            "sin_evidencia": faltantes,
            "veredicto": (
                f"De {len(bolsas)} bolsas solo {len(propias)} tiene evidencia propia y reciente, "
                f"y {len(faltantes)} no tienen ninguna. Por eso la medicion es el primer entregable."
            ),
        }

    def en_alcance(self, frente: str) -> dict | None:
        """Decision de alcance sobre un frente comercial. Ver AX-01 a AX-05."""
        filas = self._q(
            "SELECT * FROM alcance_excluido WHERE LOWER(frente) LIKE LOWER(?)", (f"%{frente}%",)
        )
        return filas[0] if filas else None

    def alcance(self) -> list[dict]:
        return self._q("SELECT * FROM alcance_excluido ORDER BY id")

    def buscar(self, texto: str) -> list[dict]:
        like = f"%{texto}%"
        out: list[dict] = []
        campos = {
            "friccion": ("id", "descripcion"),
            "palancas": ("id", "nombre"),
            "brechas": ("id", "brecha"),
            "contradicciones": ("id", "tema"),
            "guardrails": ("id", "regla"),
            "decisiones_abiertas": ("id", "decision"),
            "componentes": ("id", "nombre"),
            "diagnostico": ("id", "hallazgo"),
            "objeciones": ("id", "objecion"),
            "narrativa_consejo": ("id", "compromiso"),
        }
        for tabla, (ic, nc) in campos.items():
            cols = [r["name"] for r in self._q(f"PRAGMA table_info({tabla})")]
            cond = " OR ".join(f"{c} LIKE ?" for c in cols)
            for r in self._q(f"SELECT * FROM {tabla} WHERE {cond}", tuple([like] * len(cols))):
                out.append({"tabla": tabla, "id": r[ic], "texto": r[nc]})
        return out

    # ---------------- federacion: laboratorio ----------------

    def lab_disponible(self) -> bool:
        return self.lab_path.exists()

    def lab_iniciativa_sdlc(self) -> dict:
        c = self._ro(self.lab_path)
        if not c:
            return {}
        try:
            ini = c.execute("SELECT * FROM iniciativas WHERE id = 'INI-04'").fetchone()
            hab = c.execute("SELECT * FROM habilitadores WHERE iniciativa = 'INI-04'").fetchall()
            bre = c.execute("SELECT * FROM brechas WHERE iniciativa = 'INI-04'").fetchall()
            return {
                "iniciativa": dict(ini) if ini else None,
                "habilitadores": [dict(r) for r in hab],
                "brechas": [dict(r) for r in bre],
            }
        finally:
            c.close()

    def lab_compuertas(self) -> list[dict]:
        c = self._ro(self.lab_path)
        if not c:
            return []
        try:
            return [dict(r) for r in c.execute("SELECT * FROM compuertas ORDER BY orden")]
        finally:
            c.close()

    # ---------------- federacion: core ----------------

    def core_disponible(self) -> bool:
        return self.core_path.exists()

    def core_resumen(self) -> dict:
        c = self._ro(self.core_path)
        if not c:
            return {}
        try:
            def n(tabla: str) -> int:
                try:
                    return c.execute(f"SELECT COUNT(*) FROM {tabla}").fetchone()[0]
                except sqlite3.Error:
                    return 0
            return {
                "reglas": n("rules"),
                "capacidades": n("capacidades"),
                "programas": n("programs"),
                "riesgos_migracion": n("riesgos_migracion"),
            }
        finally:
            c.close()

    def core_cadencia_historica(self) -> list[dict]:
        """
        Cadencia de cambio del core por anio, de las marcas fechadas del codigo.
        Es un piso, no una medicion: solo cuenta los cambios que alguien fecho en
        un comentario. Nunca devuelve nombres de personas.
        """
        c = self._ro(self.core_path)
        if not c:
            return []
        try:
            return [dict(r) for r in c.execute("""
                SELECT anio, COUNT(*) AS eventos, SUM(n_programas) AS programas_tocados
                FROM cronologia_eventos GROUP BY anio ORDER BY anio
            """)]
        finally:
            c.close()

    def core_candidatos_contrato(self, limit: int = 15) -> list[dict]:
        """
        Capacidades del core con mas reglas extraidas del codigo. Son las mejores
        candidatas para proponerle al banco contratos de interfaz derivados de su
        propio legado, en vez de esperar a que los redacte.
        """
        c = self._ro(self.core_path)
        if not c:
            return []
        try:
            return [dict(r) for r in c.execute("""
                SELECT c.bc_id, c.nombre, COUNT(r.rule_id) AS reglas
                FROM capacidades c LEFT JOIN rules r ON r.bc_id = c.bc_id
                GROUP BY c.bc_id HAVING reglas > 0
                ORDER BY reglas DESC LIMIT ?
            """, (limit,))]
        finally:
            c.close()

    def municion_propia(self) -> dict:
        """
        Datos del propio banco disponibles hoy para aterrizar la propuesta sin
        pedirle nada al cliente. Es el contra-movimiento de la objecion OB-01.

        Advertencia honesta: lo que aporta el core es de S500 y S151 en Unisys,
        no del SDLC del banco entero. Sirve para ilustrar con hechos del cliente,
        no para sustituir el levantamiento del ciclo.
        """
        res = self.core_resumen()
        cad = self.core_cadencia_historica()
        return {
            "del_core": res,
            "anios_con_cambio_registrado": [c["anio"] for c in cad],
            "capacidades_con_mas_reglas": self.core_candidatos_contrato(5),
            "del_laboratorio": {"compuertas": [g["id"] for g in self.lab_compuertas()]},
            "advertencia": ("El corpus del core cubre S500 y S151 en Unisys, no el SDLC del banco. "
                            "Sirve para ilustrar con hechos del cliente, no para sustituir el levantamiento."),
        }

    # ---------------- tablero ----------------

    def tablero(self) -> dict:
        return {
            "mandato": self.mandato(),
            "estado_del_deal": self.estado_del_deal(),
            "aterrizaje": self.que_tan_aterrizada(),
            "linea_base": self.linea_base(),
            "compromiso": self.listo_para_comprometer(),
            "ruta_critica": self.ruta_critica(),
            "contradicciones": self.contradicciones(),
            "datos_requeridos": self.datos_requeridos(),
        }


if __name__ == "__main__":
    with SdlcBrain() as b:
        print("Digital Brain de SDLC Reinvent, Banamex\n")

        m = b.mandato()
        print("Mandato del consejo:")
        for a in m["anclas"]:
            print(f"  {a['id']} {a['compromiso'][:88]}")

        ed = b.estado_del_deal()
        print(f"\nEstado del deal: {ed['veredicto']}")
        for o in ed["objeciones"]:
            print(f"  {o['id']} {o['objecion']}")
            print(f"     causa: {o['causa_raiz'][:110]}")
        print(f"  Siguiente paso: {ed['siguiente_paso']}")
        print(f"  Escenario: {ed['escenario']['id']} {ed['escenario']['nombre']}")

        at = b.que_tan_aterrizada()
        print(f"\nAterrizaje: {len(at['cifras_fragiles'])} cifras fragiles, "
              f"{at['herramientas_sin_decidir']} herramientas sin decidir, "
              f"{at['decisiones_abiertas']} decisiones abiertas")

        lb = b.linea_base()
        print(f"\nLinea base: {lb['veredicto']}, cobertura {lb['cobertura_pct']} por ciento "
              f"({lb['con_linea_base']} de {lb['metricas_de_desempeno']} metricas de desempeno)")

        comp = b.listo_para_comprometer()
        print(f"\nSe puede comprometer productividad: {comp['veredicto']}")
        for r in comp["razones"]:
            print(f"  - {r}")

        rc = b.ruta_critica()
        if rc["proximo"]:
            print(f"\nProxima fecha dura: {rc['proximo']['fecha']} en {rc['dias']} dias, "
                  f"{rc['proximo']['hito']}")

        print("\nContradicciones abiertas:")
        for c in b.contradicciones():
            print(f"  {c['id']} [{c['impacto']}] {c['tema']}")

        mu = b.municion_propia()
        print(f"\nMunicion propia del core: {mu['del_core'].get('reglas', 0)} reglas, "
              f"{mu['del_core'].get('programas', 0)} programas, "
              f"{mu['del_core'].get('riesgos_migracion', 0)} riesgos")
        print(f"  {mu['advertencia']}")
