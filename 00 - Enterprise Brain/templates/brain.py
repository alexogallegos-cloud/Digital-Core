"""
brain.py — Enterprise Brain Agent API · Template Canónico
Versión: 1.0.0 · Enterprise Brain · Digital Core · Accenture México

INSTRUCCIONES DE USO:
    1. Copia este archivo a {sistema}/digital-brain/brain.py
    2. Renombra la clase SystemBrain → {Sistema}Brain (ej. BCOPBrain, BANAMEXBrain)
    3. Actualiza SYSTEM_NAME
    4. Ajusta DB_PATH si la ubicación cambia

USO:
    from digital_brain.brain import SystemBrain
    brain = SystemBrain()
    print(brain.coverage())
    print(brain.search('crédito hipotecario'))

Como context manager:
    with SystemBrain() as brain:
        print(brain.rules('db:sp_name'))

CONTRATO (Regla B1 + Regla B2 — Enterprise Brain):
    Interfaz estándar de 5 métodos obligatorios:
      coverage()      — estado del brain (N componentes, N reglas, N dominios)
      components()    — entidades del sistema (SPs, programas, tablas, APIs)
      search(query)   — búsqueda fulltext sobre el brain
      rules(id)       — reglas de negocio de una entidad
      domains()       — dominios/módulos del sistema con conteos

    Todos los métodos retornan dicts/listas Python planos — serializables por JSON.
"""

import sqlite3
import json
from pathlib import Path

DB_PATH = Path(__file__).parent / "brain.db"

# Reemplazar con el nombre real del sistema
SYSTEM_NAME = "System"  # e.g. "BCOP", "BANAMEX", "MONEX", "LIVERPOOL"


class SystemBrain:
    """
    Agent-facing interface al Enterprise Brain.
    Implementa el contrato estándar de 5 métodos (Regla B1).
    """

    def __init__(self, db_path: Path = DB_PATH):
        if not Path(db_path).exists():
            raise FileNotFoundError(
                f"brain.db no encontrado en {db_path}. "
                "Ejecuta primero: python digital-brain/build-brain.py"
            )
        self._path = db_path
        self._conn: sqlite3.Connection | None = None

    # ── Conexión ─────────────────────────────────────────────────────────────

    def _db(self) -> sqlite3.Connection:
        if self._conn is None:
            self._conn = sqlite3.connect(self._path)
            self._conn.row_factory = sqlite3.Row
            self._conn.execute("PRAGMA query_only=1")
        return self._conn

    def _db_registro(self) -> sqlite3.Connection:
        """
        Conexión de escritura, y la única que existe en esta API.

        `_db()` lleva `query_only=1` a propósito: un agente consulta el brain, no
        lo edita, y el conocimiento solo entra por el pipeline (ADR-EB-002). La
        excepción es el registro de consultas de B45, que por definición se
        escribe al consultar y no se puede reconstruir desde el código fuente.

        Se abre aparte y no se cachea, para que ninguna otra ruta de esta clase
        pueda escribir por accidente a través de ella.
        """
        conn = sqlite3.connect(self._path)
        conn.row_factory = sqlite3.Row
        return conn

    def close(self):
        if self._conn:
            self._conn.close()
            self._conn = None

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()

    # ── Helpers ──────────────────────────────────────────────────────────────

    @staticmethod
    def _rows(rows) -> list[dict]:
        return [dict(r) for r in rows]

    @staticmethod
    def _one(row) -> dict | None:
        return dict(row) if row else None

    @staticmethod
    def _json_field(d: dict, key: str):
        val = d.get(key)
        if isinstance(val, str):
            try:
                return json.loads(val)
            except (json.JSONDecodeError, TypeError):
                return val
        return val

    # ── Interfaz estándar obligatoria (B1 contract) ───────────────────────────

    def coverage(self) -> dict:
        """
        Estado del brain — cuántos componentes, reglas, dominios tiene.
        Retorna siempre — nunca lanza excepción, devuelve 0 si la tabla no existe.
        """
        db = self._db()
        stats: dict = {"system": SYSTEM_NAME}

        def _count(sql: str, default=0):
            try:
                return db.execute(sql).fetchone()[0]
            except Exception:
                return default

        stats["components"] = _count("SELECT COUNT(*) FROM components")
        stats["rules"] = _count("SELECT COUNT(*) FROM rules")
        stats["rules_negocio"] = _count(
            "SELECT COUNT(*) FROM rules WHERE clase='NEGOCIO'"
        )
        stats["vocabulary"] = _count("SELECT COUNT(*) FROM vocabulary")
        stats["journeys"] = _count("SELECT COUNT(*) FROM journeys")
        stats["souls"] = _count("SELECT COUNT(*) FROM components WHERE is_soul=1")
        stats["domains"] = _count(
            "SELECT COUNT(DISTINCT domain) FROM components WHERE domain IS NOT NULL"
        )

        try:
            info = db.execute("SELECT * FROM system_info LIMIT 1").fetchone()
            if info:
                stats["system_info"] = dict(info)
        except Exception:
            pass

        # Gates de calidad (DoD-EB-02 y DoD-EB-03)
        stats["quality"] = {
            "business_name_null": _count(
                "SELECT COUNT(*) FROM rules WHERE business_name IS NULL OR business_name=''"
            ),
            "clase_null": _count(
                "SELECT COUNT(*) FROM rules WHERE clase IS NULL"
            ),
            "reg_null": _count(
                "SELECT COUNT(*) FROM rules WHERE reg IS NULL"
            ),
        }

        return stats

    def components(
        self,
        domain: str | None = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[dict]:
        """
        Entidades del sistema — SPs, programas, tablas, APIs.
        Filtra por dominio si se especifica.
        """
        db = self._db()
        try:
            if domain:
                rows = db.execute(
                    "SELECT * FROM components WHERE domain=? LIMIT ? OFFSET ?",
                    (domain, limit, offset),
                ).fetchall()
            else:
                rows = db.execute(
                    "SELECT * FROM components LIMIT ? OFFSET ?",
                    (limit, offset),
                ).fetchall()
            return self._rows(rows)
        except Exception:
            return []

    def search(self, query: str, limit: int = 20) -> list[dict]:
        """
        Búsqueda fulltext sobre el brain — reglas, vocabulario, componentes.
        Usa FTS5 si está disponible, fallback a LIKE si no.
        """
        db = self._db()
        results: list[dict] = []

        # Intento FTS5 en rules
        try:
            rows = db.execute(
                """SELECT r.*, 'rule' as result_type
                   FROM rules_fts fts
                   JOIN rules r ON r.id = fts.id
                   WHERE rules_fts MATCH ?
                   LIMIT ?""",
                (query, limit),
            ).fetchall()
            results.extend(self._rows(rows))
        except Exception:
            pass

        # Fallback LIKE si FTS5 no disponible o sin resultados
        if not results:
            pattern = f"%{query}%"
            try:
                rows = db.execute(
                    """SELECT *, 'rule' as result_type FROM rules
                       WHERE business_name LIKE ? OR description LIKE ?
                       LIMIT ?""",
                    (pattern, pattern, limit),
                ).fetchall()
                results.extend(self._rows(rows))
            except Exception:
                pass

        # Búsqueda en vocabulario
        if len(results) < limit:
            pattern = f"%{query}%"
            try:
                rows = db.execute(
                    """SELECT *, 'vocab' as result_type FROM vocabulary
                       WHERE term LIKE ? OR definition LIKE ?
                       LIMIT ?""",
                    (pattern, pattern, limit - len(results)),
                ).fetchall()
                results.extend(self._rows(rows))
            except Exception:
                pass

        return results[:limit]

    def rules(self, component_id: str) -> list[dict]:
        """Reglas de negocio asociadas a una entidad (SP, programa, etc.)."""
        db = self._db()
        try:
            rows = db.execute(
                "SELECT * FROM rules WHERE component_id=? ORDER BY tipo, id",
                (component_id,),
            ).fetchall()
            return self._rows(rows)
        except Exception:
            return []

    def domains(self) -> list[dict]:
        """Dominios/módulos del sistema con conteo de componentes y reglas."""
        db = self._db()
        try:
            rows = db.execute(
                """SELECT
                       c.domain,
                       COUNT(DISTINCT c.id) as component_count,
                       COUNT(DISTINCT r.id) as rule_count,
                       COUNT(DISTINCT CASE WHEN r.clase='NEGOCIO' THEN r.id END) as negocio_count
                   FROM components c
                   LEFT JOIN rules r ON r.component_id = c.id
                   WHERE c.domain IS NOT NULL
                   GROUP BY c.domain
                   ORDER BY component_count DESC"""
            ).fetchall()
            return self._rows(rows)
        except Exception:
            return []

    # ── Métodos adicionales recomendados ──────────────────────────────────────

    def vocabulary(self, scope: str | None = None, limit: int = 500) -> list[dict]:
        """Vocabulario empresarial del sistema."""
        db = self._db()
        try:
            if scope:
                rows = db.execute(
                    "SELECT * FROM vocabulary WHERE scope=? ORDER BY term LIMIT ?",
                    (scope, limit),
                ).fetchall()
            else:
                rows = db.execute(
                    "SELECT * FROM vocabulary ORDER BY term LIMIT ?", (limit,)
                ).fetchall()
            return self._rows(rows)
        except Exception:
            return []

    def journeys(self, domain: str | None = None) -> list[dict]:
        """Customer journeys del sistema."""
        db = self._db()
        try:
            if domain:
                rows = db.execute(
                    "SELECT * FROM journeys WHERE domain=? ORDER BY display_name",
                    (domain,),
                ).fetchall()
            else:
                rows = db.execute(
                    "SELECT * FROM journeys ORDER BY domain, display_name"
                ).fetchall()
            return self._rows(rows)
        except Exception:
            return []

    def souls(self) -> list[dict]:
        """Módulos funcionales (almas) del sistema — componentes con is_soul=1 (ADR-EB-006)."""
        db = self._db()
        try:
            rows = db.execute(
                "SELECT * FROM components WHERE is_soul=1 ORDER BY soul_rank, name"
            ).fetchall()
            return self._rows(rows)
        except Exception:
            return []

    # ── Métodos de razonamiento ───────────────────────────────────────────────
    # Estos métodos cruzan múltiples tablas para inferir algo — no son SELECT
    # planos. Son la diferencia entre un wrapper de SQL y un motor de razonamiento.

    def impact(self, component_id: str) -> dict:
        """
        Qué procesos de negocio, reglas y sistemas se ven afectados si este
        componente cambia. Responde la pregunta central del análisis de impacto.
        Usa component_calls (grafo) + component_processes (N:M) + rules.
        """
        db = self._db()
        comp = self.component(component_id)
        result: dict = {
            "component_id": component_id,
            "found": comp is not None,
            "component": comp,
            "called_by": [],
            "calls": [],
            "processes": [],
            "rules_count": 0,
        }
        if not comp:
            return result

        try:
            result["called_by"] = self._rows(
                db.execute(
                    "SELECT * FROM component_calls WHERE to_component=? "
                    "ORDER BY from_component",
                    (component_id,),
                ).fetchall()
            )
        except Exception:
            pass

        try:
            result["calls"] = self._rows(
                db.execute(
                    "SELECT * FROM component_calls WHERE from_component=? "
                    "ORDER BY to_component",
                    (component_id,),
                ).fetchall()
            )
        except Exception:
            pass

        try:
            result["processes"] = self._rows(
                db.execute(
                    """SELECT DISTINCT p.* FROM processes p
                       JOIN component_processes cp ON cp.process_id = p.id
                       WHERE cp.component_id = ?""",
                    (component_id,),
                ).fetchall()
            )
        except Exception:
            pass

        result["rules_count"] = len(self.rules(component_id))
        return result

    def callers_of(self, component_id: str) -> list[dict]:
        """Componentes que llaman a este componente (dependencias inversas)."""
        db = self._db()
        try:
            return self._rows(
                db.execute(
                    "SELECT * FROM component_calls WHERE to_component=? "
                    "ORDER BY from_component",
                    (component_id,),
                ).fetchall()
            )
        except Exception:
            return []

    def callees_of(self, component_id: str) -> list[dict]:
        """Componentes a los que llama este componente."""
        db = self._db()
        try:
            return self._rows(
                db.execute(
                    "SELECT * FROM component_calls WHERE from_component=? "
                    "ORDER BY to_component",
                    (component_id,),
                ).fetchall()
            )
        except Exception:
            return []

    def capability_gap(self) -> list[dict]:
        """
        Capabilities declaradas sin ningún componente que las cubra. Antes de
        decommissionar un sistema debe ser vacío, o cada gap llevar
        [BREAK-GLASS] firmado con dueño del riesgo (Regla B7).

        Una capability se considera cubierta por dos caminos: un componente que
        la declara como `primary_capability`, o un enlace en
        `component_capabilities` (N:M, con su confianza).

        Este método NO captura excepciones a propósito. Es un gate de seguridad:
        devolver lista vacía ante un error equivale a afirmar "sin brechas", que
        es justo la falla que el gate existe para evitar. Si algo falla, falla
        ruidosamente.
        """
        db = self._db()
        faltantes = [t for t in ("capabilities", "components") if t not in self._table_names()]
        if faltantes:
            raise RuntimeError(
                f"capability_gap() no es aplicable a este brain: faltan {faltantes}. "
                f"El gate de decommission (B7) solo se evalúa donde existe el "
                f"inventario de componentes."
            )
        enlace = "component_capabilities" in self._table_names()
        clausula_enlace = (
            """
                     AND NOT EXISTS (
                         SELECT 1 FROM component_capabilities cc
                         WHERE cc.capability_id = c.id
                     )""" if enlace else ""
        )
        return self._rows(
            db.execute(
                f"""SELECT c.* FROM capabilities c
                    WHERE NOT EXISTS (
                        SELECT 1 FROM components comp
                        WHERE comp.primary_capability = c.id
                    ){clausula_enlace}"""
            ).fetchall()
        )

    def _table_names(self) -> set[str]:
        """Tablas presentes en este brain. Cacheado por instancia."""
        if getattr(self, "_tn_cache", None) is None:
            self._tn_cache = {
                r[0] for r in self._db().execute(
                    "SELECT name FROM sqlite_master WHERE type IN ('table','view')"
                ).fetchall()
            }
        return self._tn_cache

    def knowledge_gaps(self, open_only: bool = True) -> list[dict]:
        """Huecos de conocimiento declarados (Regla B17)."""
        db = self._db()
        try:
            sql = (
                "SELECT * FROM knowledge_gaps WHERE status != 'resolved' "
                "ORDER BY opened_at DESC, id"
                if open_only
                else "SELECT * FROM knowledge_gaps ORDER BY id"
            )
            return self._rows(db.execute(sql).fetchall())
        except Exception:
            return []

    def processes_gap(self) -> dict:
        """
        Procesos sin journeys que los realicen, y journeys sin proceso.
        La brecha es hallazgo de negocio (brain-rules.md B20):
        - Proceso sin journey = capacidad declarada sin soporte en código.
        - Journey sin proceso = funcionalidad no documentada.
        """
        db = self._db()
        result: dict = {
            "processes_without_journey": [],
            "journeys_without_process": [],
        }
        try:
            result["processes_without_journey"] = self._rows(
                db.execute(
                    """SELECT p.* FROM processes p
                       WHERE NOT EXISTS (
                           SELECT 1 FROM journeys j WHERE j.process_id = p.id
                       )"""
                ).fetchall()
            )
        except Exception:
            pass
        try:
            result["journeys_without_process"] = self._rows(
                db.execute(
                    """SELECT j.* FROM journeys j
                       WHERE j.process_id IS NULL
                          OR NOT EXISTS (
                              SELECT 1 FROM processes p WHERE p.id = j.process_id
                          )"""
                ).fetchall()
            )
        except Exception:
            pass
        return result

    TIER_RANK = {"gold": 3, "silver": 2, "bronze": 1, "rejected": 0}

    def _tier_filter(self, rows: list[dict], min_tier: str | None) -> list[dict]:
        """Regla B37 — una fila sin tier se trata como bronze: no se presume certeza."""
        if not min_tier:
            return rows
        floor = self.TIER_RANK[min_tier]
        return [r for r in rows if self.TIER_RANK.get((r.get("tier") or "bronze").lower(), 1) >= floor]

    def lineage(self, entity_table: str, entity_id: str) -> list[dict]:
        """De dónde viene una afirmación: nivel, fuente, versión, quién la afirmó y quién la validó."""
        db = self._db()
        try:
            return self._rows(db.execute(
                "SELECT * FROM knowledge_lineage WHERE entity_table=? AND entity_id=? "
                "ORDER BY recorded_at DESC, id DESC", (entity_table, entity_id)).fetchall())
        except Exception:
            return []

    # Peso para la cola HITL: primero lo que sostiene decisiones de gate y regulación
    HITL_WEIGHT = {"transitions": 5, "readiness_gates": 5, "regulatory_obligations": 4,
                   "rules": 4, "kpis": 4, "products": 3, "data_entities": 3, "findings": 3}

    def hitl_queue(self, limit: int = 50) -> list[dict]:
        """
        Afirmaciones silver y bronze vigentes que esperan validación humana (Regla B37).
        Prioriza por peso de la tabla y por si su proceso mueve un KPI (cadena B27).
        """
        db = self._db()
        try:
            pending = self._rows(db.execute(
                "SELECT * FROM knowledge_lineage WHERE superseded_by IS NULL "
                "AND LOWER(tier) IN ('silver','bronze')").fetchall())
            kpi_procs = {r["process_id"] for r in self._rows(db.execute(
                "SELECT DISTINCT process_id FROM kpis WHERE process_id IS NOT NULL").fetchall())}
        except Exception:
            return []
        proc_cache: dict = {}

        def proc_of(t: str, i: str):
            if (t, i) not in proc_cache:
                try:
                    row = db.execute(f"SELECT process_id FROM {t} WHERE id=?", (i,)).fetchone()
                    proc_cache[(t, i)] = row[0] if row else None
                except Exception:
                    proc_cache[(t, i)] = None
            return proc_cache[(t, i)]

        for r in pending:
            score = self.HITL_WEIGHT.get(r["entity_table"], 1)
            score += 2 if (r["tier"] or "").lower() == "silver" else 0
            if proc_of(r["entity_table"], r["entity_id"]) in kpi_procs:
                score += 3
            r["priority"] = score
        pending.sort(key=lambda r: (-r["priority"], r["recorded_at"] or ""))
        return pending[:limit]

    def value_chain(self, product_id: str | None = None, min_tier: str | None = None) -> dict:
        """
        Traza la cadena de valor completa (Regla B27):
          Producto → KPIs → Procesos → Componentes → Datos → Tecnología (+ ITOM que la opera)
        Si se da product_id, filtra a ese producto. Sin filtro, devuelve todo.
        """
        db = self._db()
        result: dict = {"product_id": product_id, "products": [], "kpis": [],
                        "processes": [], "components": [], "itom": []}
        try:
            if product_id:
                result["products"] = self._rows(
                    db.execute("SELECT * FROM products WHERE id=?", (product_id,)).fetchall()
                )
                result["kpis"] = self._rows(
                    db.execute(
                        "SELECT * FROM kpis WHERE product_id=? ORDER BY metric_type",
                        (product_id,),
                    ).fetchall()
                )
                result["processes"] = self._rows(
                    db.execute(
                        "SELECT DISTINCT p.* FROM processes p "
                        "JOIN kpis k ON k.process_id = p.id "
                        "WHERE k.product_id=? "
                        "UNION "
                        "SELECT p.* FROM processes p "
                        "JOIN products pr ON pr.process_id = p.id "
                        "WHERE pr.id=?",
                        (product_id, product_id),
                    ).fetchall()
                )
            else:
                result["products"] = self._rows(
                    db.execute("SELECT * FROM products ORDER BY product_line, name").fetchall()
                )
                result["kpis"] = self._rows(
                    db.execute("SELECT * FROM kpis ORDER BY product_id, metric_type").fetchall()
                )
                result["processes"] = self._rows(
                    db.execute("SELECT * FROM processes ORDER BY id").fetchall()
                )
            result["itom"] = self._rows(
                db.execute("SELECT * FROM itom_layer ORDER BY layer").fetchall()
            )
        except Exception:
            pass

        # Brain de sistema: componentes vía component_processes. Brain de proyecto: applications.
        proc_ids = [p["id"] for p in result["processes"]]
        if proc_ids:
            marks = ",".join("?" * len(proc_ids))
            for sql in (
                f"SELECT DISTINCT c.* FROM components c JOIN component_processes cp "
                f"ON cp.component_id = c.id WHERE cp.process_id IN ({marks})",
                f"SELECT * FROM applications WHERE process_id IN ({marks})",
            ):
                try:
                    result["components"].extend(
                        self._rows(db.execute(sql, proc_ids).fetchall())
                    )
                except Exception:
                    pass

        # Eslabón Datos: entidades que tocan esos componentes (matriz CRUD)
        comp_ids = [c["id"] for c in result["components"] if c.get("id")]
        result["data"], result["technology"] = [], []
        if comp_ids:
            marks = ",".join("?" * len(comp_ids))
            try:
                result["data"] = self._rows(db.execute(
                    f"SELECT DISTINCT de.*, cd.access_type FROM data_entities de "
                    f"JOIN component_data cd ON cd.entity_id = de.id "
                    f"WHERE cd.component_id IN ({marks})", comp_ids).fetchall())
            except Exception:
                pass
        # Eslabón Infraestructura: tecnología donde viven esos datos, o todo el stack del brain
        try:
            tech_ids = sorted({d["technology_id"] for d in result["data"] if d.get("technology_id")})
            if tech_ids:
                marks = ",".join("?" * len(tech_ids))
                result["technology"] = self._rows(db.execute(
                    f"SELECT * FROM technology_components WHERE id IN ({marks})", tech_ids).fetchall())
            else:
                result["technology"] = self._rows(
                    db.execute("SELECT * FROM technology_components ORDER BY category").fetchall())
        except Exception:
            pass

        # Regla B35 y B37 — la respuesta declara con qué nivel de certeza se construyó
        chain = ("products", "kpis", "processes", "components", "data", "technology", "itom")
        for k in chain:
            result[k] = self._tier_filter(result[k], min_tier)
        result["tier_summary"] = {
            k: {t: sum(1 for r in result[k] if (r.get("tier") or "bronze").lower() == t)
                for t in ("gold", "silver", "bronze")}
            for k in chain
        }
        return result

    def cross_dependencies(self) -> list[dict]:
        """Dependencias con otros sistemas (Regla B5)."""
        db = self._db()
        try:
            rows = db.execute(
                "SELECT * FROM cross_dependencies ORDER BY criticality DESC, other_system"
            ).fetchall()
            return self._rows(rows)
        except Exception:
            return []

    def capability_alignment(self) -> list[dict]:
        """
        Brains federados cuya versión de ETB difiere de la declarada en este brain
        (Regla B3). Solo significativo en enterprise brains (`brain_type='enterprise'`).
        Retorna lista de {brain_slug, brain_path, etb_version, expected_version, gap}.
        """
        db = self._db()
        # La versión esperada la fija la ontología primaria de ESTE brain (B20).
        # `ontology_bindings.catalog_version` es el campo canónico; `system_info`
        # declara el modelo (`capability_model`), no su versión.
        fila = self._one(
            db.execute(
                "SELECT ontology, catalog, catalog_version FROM ontology_bindings "
                "WHERE role='primary' LIMIT 1"
            ).fetchone()
        )
        if not fila or not fila.get("catalog_version"):
            raise RuntimeError(
                "capability_alignment() exige una ontología primaria con "
                "catalog_version declarada en ontology_bindings (Reglas B20, B21)."
            )
        esperada = fila["catalog_version"]
        federados = self._rows(
            db.execute(
                "SELECT slug, brain_path, brain_attached FROM federated_brains"
            ).fetchall()
        )

        # No se copia la versión del vecino: se lee de su propio brain vía ATTACH
        # (Regla B4, y "una sola verdad por dato" de B38).
        result = []
        for fb in federados:
            slug, path = fb.get("slug", ""), fb.get("brain_path", "")
            entrada = {"brain_slug": slug, "brain_path": path,
                       "expected_version": esperada}
            try:
                # La ruta del vecino es relativa a la ubicación de ESTE brain,
                # no al directorio de trabajo del proceso. Resolverla contra el
                # cwd marcaba como inalcanzable a todo brain federado.
                ruta = Path(path)
                if not ruta.is_absolute():
                    ruta = (Path(self._path).resolve().parent / ruta).resolve()
                vecino = sqlite3.connect(f"file:{ruta}?mode=ro", uri=True)
                try:
                    v = vecino.execute(
                        "SELECT catalog_version FROM ontology_bindings "
                        "WHERE role='primary' LIMIT 1"
                    ).fetchone()
                finally:
                    vecino.close()
            except Exception as e:
                # Indeterminable NO es alineado: se reporta como hallazgo propio.
                result.append({**entrada, "etb_version": None,
                               "gap": True, "undeterminable": str(e)})
                continue
            ver = v[0] if v else None
            if ver != esperada:
                result.append({**entrada, "etb_version": ver, "gap": True})
        return result


    # ── Regla B40 · el reloj del negocio ─────────────────────────────────────

    def snapshot(self, fecha: str, entity_table: str | None = None) -> list[dict]:
        """
        El conocimiento tal como fue verdad en la empresa en esa fecha.

        No es lo mismo que "lo que el brain sabía entonces": filtra por el reloj
        del NEGOCIO (`valid_from` y `valid_to`), no por el del brain
        (`recorded_at`). Sirve para reconstruir cómo estaba la arquitectura
        antes de una ola de migración, o qué regulación estaba vigente cuando
        ocurrió un incidente.

        Un `valid_from` nulo se interpreta como verdad desde el origen del
        sistema, y un `valid_to` nulo como vigente hoy.
        """
        db = self._db()
        sql = ("SELECT * FROM knowledge_lineage "
               "WHERE (valid_from IS NULL OR valid_from <= ?) "
               "AND (valid_to IS NULL OR valid_to >= ?)")
        params: list = [fecha, fecha]
        if entity_table:
            sql += " AND entity_table = ?"
            params.append(entity_table)
        return self._rows(db.execute(sql + " ORDER BY entity_table, entity_id",
                                     params).fetchall())

    def latencia_bitemporal(self) -> dict:
        """
        Cuánto tarda el brain en enterarse de lo que pasa en la empresa.

        Es la medida honesta de frescura (Reglas B40 y B43, SLO-EB-05), más
        exacta que la fecha del último build: un brain reconstruido ayer puede
        tener conocimiento de hace seis meses.
        """
        db = self._db()
        filas = db.execute(
            "SELECT julianday(recorded_at) - julianday(valid_from) AS dias "
            "FROM knowledge_lineage WHERE valid_from IS NOT NULL "
            "AND recorded_at IS NOT NULL"
        ).fetchall()
        dias = sorted(f[0] for f in filas if f[0] is not None)
        if not dias:
            return {"n": 0, "mediana_dias": None,
                    "nota": "ninguna afirmación declara valid_from"}
        m = len(dias) // 2
        mediana = dias[m] if len(dias) % 2 else (dias[m - 1] + dias[m]) / 2
        return {"n": len(dias), "mediana_dias": round(mediana, 1),
                "max_dias": round(dias[-1], 1),
                "cumple_slo_eb_05": mediana <= 15}

    # ── Regla B45 · el ciclo de vida de una consulta ─────────────────────────

    #: Qué propósitos puede atender cada tipo de solicitante (Regla B42).
    #: Lo que no está permitido, está negado.
    PROPOSITOS = {
        "cliente":    {"operar", "decidir", "auditar", "cumplimiento", "onboarding"},
        "consultora": {"operar", "decidir", "auditar", "cumplimiento",
                       "onboarding", "diagnostico", "modernizacion"},
        "tercero":    {"operar"},
    }

    def abrir_consulta(self, pregunta: str, *, proposito: str,
                       solicitante: str = "", organizacion: str = "consultora") -> dict:
        """
        Etapa 1 de B45: admisión. Devuelve la consulta con su identidad.

        **Sin propósito declarado no cruza ninguna frontera** (Regla B42). La
        autorización es del par solicitante y propósito, no del solicitante: la
        misma persona que puede leer un hallazgo para documentar una causa raíz
        no puede leerlo para comparar proveedores.
        """
        import uuid
        from datetime import datetime, timezone

        if not proposito:
            raise ValueError(
                "Toda consulta declara su propósito antes de cruzar una "
                "frontera (Regla B42). Sin él, no se admite.")

        permitidos = self.PROPOSITOS.get(organizacion, set())
        negada = proposito not in permitidos
        q = {
            "id": f"Q-{uuid.uuid4().hex[:12]}",
            "question": pregunta,
            "purpose": proposito,
            "requester": solicitante,
            "requester_org": organizacion,
            "asked_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
            "denied_reason": (
                f"'{proposito}' no está entre los propósitos permitidos para "
                f"'{organizacion}': {sorted(permitidos)}" if negada else None),
            "admitida": not negada,
        }
        return q

    def responder(self, consulta: dict, filas: list[dict]) -> dict:
        """
        Etapas 4 y 5 de B45: razonamiento y respuesta.

        El brain no devuelve lo que puede, devuelve lo que se necesita y dice
        con qué certeza lo sostiene. Una respuesta que no distingue el hecho
        irrefutable de la interpretación obliga a desconfiar de ambos.
        """
        from collections import Counter

        if not consulta.get("admitida", False):
            return {"query_id": consulta["id"], "datos": [],
                    "denegada": consulta.get("denied_reason")}
        resumen = dict(Counter(f.get("tier") or "bronze" for f in filas))
        return {
            "query_id": consulta["id"],
            "datos": filas,
            "tier_summary": resumen,
            # Por B37 ninguna decisión de gate se sostiene sobre algo que no sea gold
            "sostiene_decision_de_gate": bool(filas) and resumen.get("gold", 0) == len(filas),
        }

    def registrar_consulta(self, consulta: dict, respuesta: dict | None = None,
                           decision_id: str | None = None) -> None:
        """
        Etapa 6 de B45: registro. Es lo que vuelve medibles a B42 y B43.

        Sin esto no hay qué contar para el eje de uso, el propósito no queda en
        ninguna parte, y una decisión equivocada no se puede rastrear hasta la
        respuesta que la motivó.

        **Escribe en brain.db, que el pipeline reconstruye (ADR-EB-002).** Un
        rebuild borra el registro de consultas, y eso choca con B43, que necesita
        la serie para medir el uso, y con B44, que exige que el registro
        sobreviva al archivado. Mientras no haya una ruta de persistencia
        decidida, `build-brain.py` preserva la tabla entre builds en lugar de
        recrearla. Queda declarado como hueco en vez de escondido.
        """
        import json
        from datetime import datetime, timezone

        if "queries" not in self._table_names():
            return
        db = self._db_registro()
        ahora = datetime.now(timezone.utc).isoformat(timespec="seconds")
        db.execute(
            "INSERT OR REPLACE INTO queries (id, tier, requester, requester_org, "
            "purpose, question, tier_summary, denied_reason, decision_id, "
            "answered_at, asked_at) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (consulta["id"], "gold", consulta.get("requester"),
             consulta.get("requester_org"), consulta["purpose"],
             consulta.get("question"),
             json.dumps((respuesta or {}).get("tier_summary", {}), ensure_ascii=False),
             consulta.get("denied_reason"), decision_id,
             ahora if respuesta else None, consulta["asked_at"]))
        db.commit()
        db.close()

    # ── Regla B43 · el brain se mide a sí mismo ──────────────────────────────

    def autoevaluacion(self) -> dict:
        """
        Los cinco ejes de B43. El quinto es el que vuelve aprendiz al brain:
        si aconsejó y el KPI no se movió, ese es su hallazgo más valioso.
        """
        db = self._db()
        tablas = self._table_names()
        r: dict = {}

        if "queries" in tablas:
            r["uso"] = {
                "consultas": db.execute("SELECT COUNT(*) FROM queries").fetchone()[0],
                "denegadas": db.execute(
                    "SELECT COUNT(*) FROM queries WHERE denied_reason IS NOT NULL"
                ).fetchone()[0],
                "por_proposito": dict(db.execute(
                    "SELECT purpose, COUNT(*) FROM queries GROUP BY purpose").fetchall()),
            }
            lat = db.execute(
                "SELECT AVG(latency_ms) FROM queries WHERE latency_ms IS NOT NULL"
            ).fetchone()[0]
            r["desempeno"] = {"latencia_media_ms": round(lat, 1) if lat else None}

        if "costs" in tablas:
            r["costo"] = {
                "registros": db.execute("SELECT COUNT(*) FROM costs").fetchone()[0],
                "con_producto": db.execute(
                    "SELECT COUNT(*) FROM costs WHERE product_id IS NOT NULL").fetchone()[0],
            }

        r["frescura"] = self.latencia_bitemporal()

        if "decisions" in tablas:
            cols = {x[1] for x in db.execute("PRAGMA table_info(decisions)")}
            if "outcome" in cols:
                tot = db.execute("SELECT COUNT(*) FROM decisions").fetchone()[0]
                con_ev = db.execute(
                    "SELECT COUNT(*) FROM decisions WHERE knowledge_refs IS NOT NULL"
                ).fetchone()[0]
                con_res = db.execute(
                    "SELECT COUNT(*) FROM decisions "
                    "WHERE outcome IS NOT NULL AND outcome != 'pendiente'"
                ).fetchone()[0]
                aciertos = db.execute(
                    "SELECT COUNT(*) FROM decisions WHERE outcome = 'logrado'"
                ).fetchone()[0]
                r["trazabilidad_decision"] = {
                    "decisiones": tot,
                    "con_evidencia": con_ev,
                    "con_resultado": con_res,
                    "acierto": round(aciertos / con_res, 2) if con_res else None,
                    "nota": ("Un brain que acumula consejos sin verificar su acierto "
                             "no mejora y pierde el derecho a que le crean."),
                }
        return r


    def component(self, component_id: str) -> dict | None:
        """Detalle de un componente específico por ID canónico (db:sp_name)."""
        db = self._db()
        try:
            row = db.execute(
                "SELECT * FROM components WHERE id=?", (component_id,)
            ).fetchone()
            return self._one(row)
        except Exception:
            return None
