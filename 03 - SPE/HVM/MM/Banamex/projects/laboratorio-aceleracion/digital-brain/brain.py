#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
brain.py — API de consulta del Digital Brain del Laboratorio de Aceleracion.

    from brain import LabBrain
    with LabBrain() as b:
        b.estado_setup()
        b.preparacion_iniciativa("INI-01")
        b.ruta_critica()

El brain del core se federa POR REFERENCIA: las consultas cruzadas abren el
brain.db del core en solo lectura. Nunca se duplica su corpus.
"""
from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import Any

_BASE = Path(__file__).resolve().parent
_DB = _BASE / "lab-brain.db"
_CORE = _BASE.parents[2] / "systems" / "core" / "unisys" / "digital-brain" / "brain.db"


class LabBrain:
    def __init__(self, db_path: str | Path = _DB, core_path: str | Path = _CORE):
        self.path = Path(db_path)
        if not self.path.exists():
            raise FileNotFoundError(
                f"No existe {self.path}. Corre primero: python build-brain.py"
            )
        self.conn = sqlite3.connect(f"file:{self.path}?mode=ro", uri=True)
        self.conn.row_factory = sqlite3.Row
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

    def _core(self) -> sqlite3.Connection | None:
        """Abre el brain del core en solo lectura. None si no esta disponible."""
        if not self.core_path.exists():
            return None
        c = sqlite3.connect(f"file:{self.core_path}?mode=ro", uri=True)
        c.row_factory = sqlite3.Row
        return c

    # ---------------- contrato ----------------

    def stats(self) -> dict[str, int]:
        return {r["clave"]: r["valor"] for r in self._q("SELECT clave, valor FROM stats")}

    def contrato(self, clave: str | None = None) -> Any:
        if clave:
            r = self._one("SELECT * FROM contrato WHERE clave=?", (clave,))
            return r["valor"] if r else None
        return {r["clave"]: r["valor"] for r in self._q("SELECT clave, valor FROM contrato")}

    def entregables_contractuales(self, solo_pendientes: bool = False) -> list[dict]:
        sql = "SELECT * FROM entregables_contractuales"
        if solo_pendientes:
            sql += " WHERE estado='PENDIENTE'"
        return self._q(sql + " ORDER BY num")

    def con_fecha_dura(self) -> list[dict]:
        """Entregables contractuales con fecha de vencimiento fijada."""
        return self._q("SELECT * FROM entregables_contractuales WHERE vence != '' ORDER BY vence")

    def compromisos(self, nivel: str | None = None) -> list[dict]:
        if nivel:
            return self._q("SELECT * FROM compromisos_servicio WHERE nivel=? ORDER BY id", (nivel,))
        return self._q("SELECT * FROM compromisos_servicio ORDER BY id")

    def talla(self, nombre: str) -> dict | None:
        return self._one("SELECT * FROM tallas WHERE talla=? COLLATE NOCASE", (nombre,))

    def tallas(self) -> list[dict]:
        return self._q("SELECT * FROM tallas ORDER BY orden")

    def talla_por_consumo(self, consumo_usd: float) -> dict | None:
        """La talla no se contrata: se lee del rango de consumo mensual."""
        for t in self.tallas():
            if t["consumo_hasta"] is None:
                if consumo_usd >= t["consumo_desde"]:
                    return t
            elif t["consumo_desde"] <= consumo_usd < t["consumo_hasta"]:
                return t
        return None

    def criterios_arranque(self) -> list[dict]:
        """Los cuatro criterios que vuelven exigible la cuota de arranque."""
        return self._q("SELECT * FROM criterios_arranque ORDER BY num")

    def penas(self) -> list[dict]:
        return self._q("SELECT * FROM penas")

    # ---------------- laboratorio ----------------

    def arquetipos(self) -> list[dict]:
        return self._q("SELECT * FROM arquetipos ORDER BY id")

    def arquetipo(self, id_: str) -> dict | None:
        return self._one("SELECT * FROM arquetipos WHERE id=? COLLATE NOCASE", (id_,))

    def capas(self) -> list[dict]:
        return self._q("SELECT * FROM capas_lab ORDER BY num")

    def compuertas(self) -> list[dict]:
        return self._q("SELECT * FROM compuertas ORDER BY orden")

    def stack(self, categoria: str | None = None) -> list[dict]:
        if categoria:
            return self._q("SELECT * FROM stack WHERE categoria=? COLLATE NOCASE ORDER BY componente",
                           (categoria,))
        return self._q("SELECT * FROM stack ORDER BY categoria, componente")

    def rutas_codigo(self) -> list[dict]:
        return self._q("SELECT * FROM rutas_codigo ORDER BY recomendada DESC, id")

    # ---------------- setup ----------------

    def fases(self) -> list[dict]:
        return self._q("SELECT * FROM fases ORDER BY orden")

    def actividades(self, fase: str | None = None, workstream: str | None = None,
                    estado: str | None = None) -> list[dict]:
        sql = "SELECT * FROM actividades WHERE 1=1"
        p: list = []
        if fase:
            sql += " AND fase=?"
            p.append(fase)
        if workstream:
            sql += " AND workstream=? COLLATE NOCASE"
            p.append(workstream)
        if estado:
            sql += " AND estado=? COLLATE NOCASE"
            p.append(estado)
        return self._q(sql + " ORDER BY id", tuple(p))

    def actividad(self, id_: str) -> dict | None:
        return self._one("SELECT * FROM actividades WHERE id=? COLLATE NOCASE", (id_,))

    def sin_dependencias(self, solo_pendientes: bool = True) -> list[dict]:
        """Actividades que pueden arrancar hoy: no esperan a nadie."""
        sql = "SELECT * FROM actividades WHERE depende_de=''"
        if solo_pendientes:
            sql += " AND estado='PENDIENTE'"
        return self._q(sql + " ORDER BY id")

    def bloquea_a(self, id_: str) -> list[dict]:
        """Actividades que dependen de la dada."""
        return self._q(
            "SELECT * FROM actividades WHERE depende_de LIKE ? OR depende_de LIKE ? "
            "OR depende_de LIKE ? OR depende_de = ? ORDER BY id",
            (f"{id_},%", f"%,{id_},%", f"%,{id_}", id_),
        )

    def ruta_critica(self) -> list[dict]:
        """
        Cadena hacia ACT-29, la sesion en vivo que acredita los cuatro criterios
        y vuelve exigible la cuota de arranque.
        """
        vistos: set[str] = set()
        orden: list[dict] = []

        def sube(aid: str):
            if aid in vistos:
                return
            vistos.add(aid)
            a = self.actividad(aid)
            if not a:
                return
            for dep in filter(None, (a["depende_de"] or "").split(",")):
                sube(dep.strip())
            orden.append(a)

        sube("ACT-29")
        sube("ACT-30")
        return orden

    def estado_setup(self) -> list[dict]:
        return self._q("""
            SELECT f.id, f.nombre, f.ventana, f.estado AS estado_fase,
                   COUNT(a.id) AS actividades,
                   SUM(CASE WHEN a.estado='PENDIENTE' THEN 1 ELSE 0 END) AS pendientes,
                   SUM(CASE WHEN a.estado='HECHO' THEN 1 ELSE 0 END) AS hechas
            FROM fases f LEFT JOIN actividades a ON a.fase = f.id
            GROUP BY f.id ORDER BY f.orden
        """)

    def entregables_setup(self, solo_contractuales: bool = False) -> list[dict]:
        sql = "SELECT * FROM entregables_setup"
        if solo_contractuales:
            sql += " WHERE contractual=1"
        return self._q(sql + " ORDER BY contractual DESC, fase, nombre")

    def buscar_actividad(self, query: str, limit: int = 20) -> list[dict]:
        if not query or not query.strip():
            return []
        return self._q(
            "SELECT a.* FROM actividades_fts f JOIN actividades a ON a.rowid = f.rowid "
            "WHERE actividades_fts MATCH ? LIMIT ?",
            (query, limit),
        )

    def hitos(self) -> list[dict]:
        return self._q("SELECT * FROM hitos ORDER BY fecha, id")

    def fases_sow(self) -> list[dict]:
        """Solo los componentes que la Cláusula Cuarta del Anexo reconoce."""
        return self._q("SELECT * FROM fases WHERE en_sow=1 ORDER BY orden")

    def actividades_sow(self, en_sow: int = 1) -> list[dict]:
        return self._q("SELECT * FROM actividades WHERE en_sow=? ORDER BY id", (en_sow,))

    def cobertura_sow(self) -> list[dict]:
        return self._q("""
            SELECT f.id, f.nombre, f.clausula, f.en_sow,
                   COUNT(a.id) AS actividades,
                   SUM(CASE WHEN a.en_sow=1 THEN 1 ELSE 0 END) AS en_sow_n,
                   SUM(CASE WHEN a.en_sow=0 THEN 1 ELSE 0 END) AS apoyo
            FROM fases f LEFT JOIN actividades a ON a.fase = f.id
            GROUP BY f.id ORDER BY f.orden
        """)

    def semanas(self) -> list[dict]:
        """Las cuatro semanas de la ventana de implementación."""
        return self._q("SELECT * FROM semanas ORDER BY num")

    def actividades_por_semana(self, num: int) -> list[dict]:
        return self._q("SELECT * FROM actividades WHERE semana=? ORDER BY id", (num,))

    def carga_semanal(self) -> list[dict]:
        return self._q("""
            SELECT s.num, s.inicio, s.fin, s.foco, s.riesgo,
                   COUNT(a.id) AS actividades,
                   SUM(CASE WHEN a.estado='PENDIENTE' THEN 1 ELSE 0 END) AS pendientes
            FROM semanas s LEFT JOIN actividades a ON a.semana = s.num
            GROUP BY s.num ORDER BY s.num
        """)

    def ruta_critica_por_semana(self) -> dict[int, list[dict]]:
        criticas = {a["id"] for a in self.ruta_critica()}
        m: dict[int, list[dict]] = {}
        for s in self.semanas():
            m[s["num"]] = [a for a in self.actividades_por_semana(s["num"])
                           if a["id"] in criticas]
        return m

    # ---------------- equipo ----------------

    def roles(self, frente: str | None = None) -> list[dict]:
        if frente:
            return self._q("SELECT * FROM roles WHERE frente=? COLLATE NOCASE ORDER BY id", (frente,))
        return self._q("SELECT * FROM roles ORDER BY id")

    def rol(self, id_: str) -> dict | None:
        return self._one("SELECT * FROM roles WHERE id=? COLLATE NOCASE", (id_,))

    def frentes(self) -> list[str]:
        return [r["frente"] for r in self._q(
            "SELECT frente, MIN(id) AS o FROM roles GROUP BY frente ORDER BY o")]

    def organigrama(self) -> list[dict]:
        """Arbol de reporte. Cada nodo trae su profundidad y sus subordinados."""
        todos = {r["id"]: dict(r, hijos=[]) for r in self.roles()}
        raiz: list[dict] = []
        for r in todos.values():
            padre = todos.get(r["reporta_a"])
            if padre:
                padre["hijos"].append(r)
            else:
                raiz.append(r)
        return raiz

    def supuestos(self) -> list[dict]:
        """Supuestos que sostienen el dimensionamiento. Si uno cae, el equipo crece."""
        return self._q("SELECT * FROM supuestos ORDER BY id")

    def limites_ia(self) -> list[dict]:
        """Lo que la IA no puede bajar, y por qué."""
        return self._q("SELECT * FROM limites_ia ORDER BY id")

    def fte(self, con_ia: bool = False) -> dict[str, float]:
        a, b = ("fte_ia_setup", "fte_ia_steady") if con_ia else ("fte_setup", "fte_steady")
        r = self._one(f"SELECT ROUND(SUM({a}),2) AS setup, ROUND(SUM({b}),2) AS steady FROM roles")
        return r or {"setup": 0.0, "steady": 0.0}

    def escenarios_fte(self) -> list[dict]:
        """Las tres curvas: patrón de banca, ajustado al laboratorio y habilitado por IA."""
        base = self.fte()
        ia = self.fte(con_ia=True)
        return [
            {"escenario": "Patrón de banca productiva", "setup": 13.55, "steady": 11.80,
             "nota": "Guideline de IMS aplicado sin ajustar al perfil del ambiente"},
            {"escenario": "Ajustado al laboratorio", "setup": base["setup"], "steady": base["steady"],
             "nota": "Sin operación continua, sin datos reales, sin recuperación ante desastres"},
            {"escenario": "Habilitado por IA", "setup": ia["setup"], "steady": ia["steady"],
             "nota": "Beneficio en años 2 y 3, no en el primero"},
        ]

    def palancas_ia(self) -> list[dict]:
        return self._q("""
            SELECT id, rol, nivel, fte_setup, fte_ia_setup, fte_steady, fte_ia_steady,
                   ROUND(fte_steady - fte_ia_steady, 2) AS ahorro_steady, palanca_ia
            FROM roles ORDER BY (fte_steady - fte_ia_steady) DESC, id
        """)

    def piramide_tier(self) -> list[dict]:
        return self._q("""
            SELECT tier, COUNT(*) AS roles,
                   ROUND(SUM(fte_setup),2) AS fte_setup,
                   ROUND(SUM(fte_steady),2) AS fte_steady
            FROM roles GROUP BY tier
            ORDER BY CASE tier WHEN 'Gobierno' THEN 0 WHEN 'T3' THEN 1
                               WHEN 'T2' THEN 2 ELSE 3 END
        """)

    def geografia(self) -> list[dict]:
        return self._q("""
            SELECT ubicacion, ROUND(SUM(fte_steady),2) AS fte_steady
            FROM roles GROUP BY ubicacion ORDER BY fte_steady DESC
        """)

    def entregables_raci(self) -> list[str]:
        return [r["entregable"] for r in self._q(
            "SELECT entregable, MIN(id) AS o FROM raci GROUP BY entregable ORDER BY o")]

    def raci_matriz(self) -> dict[str, dict[str, str]]:
        """{entregable: {rol_id: letra}}"""
        m: dict[str, dict[str, str]] = {}
        for r in self._q("SELECT entregable, rol_id, letra FROM raci"):
            m.setdefault(r["entregable"], {})[r["rol_id"]] = r["letra"]
        return m

    def roles_en_raci(self) -> list[dict]:
        """Solo los roles que aparecen en la matriz, en orden de jerarquía."""
        return self._q("""
            SELECT r.* FROM roles r
            WHERE EXISTS (SELECT 1 FROM raci x WHERE x.rol_id = r.id)
            ORDER BY r.id
        """)

    def accountable_de(self, entregable: str) -> dict | None:
        r = self._one("SELECT rol_id FROM raci WHERE entregable=? AND letra='A'", (entregable,))
        return self.rol(r["rol_id"]) if r else None

    # ---------------- iniciativas estrategicas ----------------

    def iniciativas(self) -> list[dict]:
        return self._q("SELECT * FROM iniciativas ORDER BY id")

    def iniciativa(self, id_: str) -> dict | None:
        return self._one("SELECT * FROM iniciativas WHERE id=? COLLATE NOCASE", (id_,))

    def preparacion_iniciativa(self, id_: str) -> dict:
        """Que tiene y que le falta a una iniciativa para poder arrancar."""
        ini = self.iniciativa(id_)
        if not ini:
            return {}
        return {
            "iniciativa": ini,
            "habilitadores": self._q(
                "SELECT tipo, que_aporta, origen FROM habilitadores WHERE iniciativa=? ORDER BY tipo",
                (ini["id"],)),
            "brechas": self._q(
                "SELECT brecha, impacto, quien_resuelve, estado FROM brechas WHERE iniciativa=?",
                (ini["id"],)),
        }

    def tablero_iniciativas(self) -> list[dict]:
        return self._q("""
            SELECT i.id, i.nombre, i.estado, i.en_anexo_b, i.vehiculo,
                   (SELECT COUNT(*) FROM habilitadores h WHERE h.iniciativa=i.id) AS habilitadores,
                   (SELECT COUNT(*) FROM brechas b WHERE b.iniciativa=i.id AND b.estado!='CERRADA') AS brechas,
                   (SELECT COUNT(*) FROM brechas b WHERE b.iniciativa=i.id AND b.estado='DATO-REQUERIDO')
                       AS datos_requeridos
            FROM iniciativas i ORDER BY i.id
        """)

    def fuera_de_contrato(self) -> list[dict]:
        """Iniciativas sin cobertura en el Anexo B. Entregarlas exige otro vehiculo."""
        return self._q("SELECT * FROM iniciativas WHERE en_anexo_b=0 ORDER BY id")

    def datos_requeridos(self) -> list[dict]:
        return self._q(
            "SELECT b.*, i.nombre AS iniciativa_nombre FROM brechas b "
            "JOIN iniciativas i ON i.id=b.iniciativa WHERE b.estado='DATO-REQUERIDO' ORDER BY b.iniciativa")

    def decisiones_abiertas(self) -> list[dict]:
        return self._q("SELECT * FROM decisiones_abiertas WHERE estado='ABIERTA' ORDER BY id")

    # ---------------- federacion con el brain del core ----------------

    def core_disponible(self) -> bool:
        return self.core_path.exists()

    def core_snapshot(self) -> list[dict]:
        return self._q("SELECT * FROM core_snapshot ORDER BY filas DESC")

    def core_capacidades(self) -> list[dict]:
        """Capacidades de negocio del core. Consulta en vivo al brain federado."""
        c = self._core()
        if not c:
            return []
        try:
            return [dict(r) for r in c.execute(
                "SELECT bc_id, nombre, dominio, sistema FROM capacidades ORDER BY bc_id")]
        finally:
            c.close()

    def core_reglas_por_capacidad(self, bc_id: str, limit: int = 50) -> list[dict]:
        """Reglas de negocio del legado para una capacidad. Insumo de contratos de interfaz."""
        c = self._core()
        if not c:
            return []
        try:
            return [dict(r) for r in c.execute(
                "SELECT rule_id, titulo, descripcion, sistema, programa FROM rules "
                "WHERE bc_id=? LIMIT ?", (bc_id, limit))]
        finally:
            c.close()

    def core_7r(self) -> list[dict]:
        """Decisiones de disposicion ya tomadas sobre el legado."""
        c = self._core()
        if not c:
            return []
        try:
            return [dict(r) for r in c.execute("SELECT * FROM sevenr_decisions")]
        finally:
            c.close()

    def core_riesgos_criticos(self, limit: int = 25) -> list[dict]:
        c = self._core()
        if not c:
            return []
        try:
            return [dict(r) for r in c.execute(
                "SELECT * FROM riesgos_migracion LIMIT ?", (limit,))]
        finally:
            c.close()

    def candidatos_contrato(self, limit: int = 20) -> list[dict]:
        """
        Capacidades del core ordenadas por densidad de reglas: las mejores candidatas
        para derivar contratos de interfaz del core emulado (ACT-37).
        """
        c = self._core()
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


if __name__ == "__main__":
    with LabBrain() as b:
        print("Digital Brain del Laboratorio de Aceleracion\n")
        for k, v in sorted(b.stats().items()):
            print(f"  {k:36s} {v:>6}")
        print("\nEstado del setup por fase:")
        for f in b.estado_setup():
            print(f"  {f['id']:4s} {f['nombre']:42s} {f['hechas']}/{f['actividades']} hechas")
        print("\nTablero de iniciativas:")
        for i in b.tablero_iniciativas():
            print(f"  {i['id']} {i['nombre'][:44]:44s} hab {i['habilitadores']:2d}  "
                  f"brechas {i['brechas']}  datos req {i['datos_requeridos']}")
        print(f"\nBrain del core federado: {'si' if b.core_disponible() else 'NO DISPONIBLE'}")
