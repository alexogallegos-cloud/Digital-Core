"""
callosum.py — Razonamiento del puente Change–Run (cuerpo calloso)
Versión: 1.0.0 · Enterprise Brain · Digital Core · Accenture México · Regla B24

Cada brain declara su lado del puente desde su propia perspectiva (Regla B1):
los de proyecto declaran `transitions`, los de sistema declaran `findings`.
Ningún brain por sí solo puede saber si el puente cruza. Este módulo federa los
brains vía ATTACH (ADR-EB-003), en solo lectura, y razona el cruce:

  Change → Run
    C1  hereda sin brain       transición hacia/desde un sistema no federado
    C2  cutover no absorbido   Change dice cutover/done; Run no tiene componentes
                               con origin_transition_id
    C3  done pero vivo         Change dice done; Run sigue operando la entidad
    C4  SLO sin medición       Change comprometió un target; Run no mide current

  Run → Change
    R1  hallazgo debe cruzar   hallazgo abierto que toca una entidad en transición
    R2  ruteo no recibido      Run ruteó; Change no registró story ni riesgo

USO:
    python callosum.py --brain projects/unity/digital-brain/brain.db \\
                       --brain systems/core/Informix/digital-brain/brain.db
    python callosum.py --enterprise bank-brain/digital-brain/bank-brain.db
    python callosum.py --brain ... --json

EXIT CODES: 0 = puente íntegro · 1 = rupturas bloqueantes · 2 = error
"""

import argparse
import json
import sqlite3
import sys
from pathlib import Path

CLOSED = ("cutover", "done")
INACTIVE = ("done", "cancelled")
GRAVE = ("blocker", "critical")


class Break:
    def __init__(self, code, direction, blocking, message, evidence=None):
        self.code = code
        self.direction = direction
        self.blocking = blocking
        self.message = message
        self.evidence = evidence or {}

    def as_dict(self):
        return vars(self)


class Callosum:
    def __init__(self, brain_paths: list[Path]):
        self.db = sqlite3.connect(":memory:", uri=True)
        self.db.row_factory = sqlite3.Row
        self.brains: dict[str, dict] = {}
        self.breaks: list[Break] = []
        for p in brain_paths:
            self._attach(Path(p))

    # ── Federación ───────────────────────────────────────────────────────────

    def _attach(self, path: Path):
        if not path.exists():
            raise FileNotFoundError(f"brain no encontrado: {path}")
        alias = f"b{len(self.brains)}"
        uri = f"file:{path.resolve().as_posix()}?mode=ro"
        self.db.execute(f"ATTACH DATABASE ? AS {alias}", (uri,))
        info = self._first(f"SELECT * FROM {alias}.system_info") or {}
        slug = info.get("slug") or path.parent.parent.name.lower()
        self.brains[slug] = {
            "alias": alias,
            "path": str(path),
            "hemisphere": (info.get("hemisphere") or "").lower(),
            "brain_type": (info.get("brain_type") or "").lower(),
            "tables": {
                r["name"] for r in self._rows(
                    f"SELECT name FROM {alias}.sqlite_master WHERE type IN ('table','view')"
                )
            },
        }

    def _rows(self, sql, params=()):
        try:
            return [dict(r) for r in self.db.execute(sql, params).fetchall()]
        except sqlite3.Error:
            return []

    def _first(self, sql, params=()):
        rows = self._rows(sql, params)
        return rows[0] if rows else None

    def _has(self, slug, table):
        return table in self.brains[slug]["tables"]

    def _side(self, hemisphere):
        return [s for s, b in self.brains.items() if b["hemisphere"] == hemisphere]

    def _add(self, *args, **kw):
        self.breaks.append(Break(*args, **kw))

    # ── Resolución de entidades en un brain de Run ───────────────────────────

    def _entity_rows(self, run_slug, entity_type, entity_id):
        """Componentes del brain de Run que materializan la entidad en transición."""
        a = self.brains[run_slug]["alias"]
        if not self._has(run_slug, "components"):
            return []
        if entity_type == "domain":
            return self._rows(f"SELECT * FROM {a}.components WHERE domain=?", (entity_id,))
        if entity_type == "component":
            return self._rows(f"SELECT * FROM {a}.components WHERE id=?", (entity_id,))
        if entity_type == "capability":
            return self._rows(
                f"SELECT * FROM {a}.components WHERE primary_capability=?", (entity_id,)
            )
        if entity_type == "application":
            # En brains de Run no hay tabla applications; se resuelve por
            # domain (si la app mapea a un dominio) o por id de componente.
            return self._rows(
                f"SELECT * FROM {a}.components WHERE domain=? OR id=?",
                (entity_id, entity_id),
            )
        return []

    def _finding_scope(self, run_slug, f) -> dict:
        """Dominios, componentes y capacidad que toca un hallazgo."""
        a = self.brains[run_slug]["alias"]
        comps = set()
        raw = f.get("entity_ids")
        if raw:
            try:
                comps = set(json.loads(raw))
            except (json.JSONDecodeError, TypeError):
                comps = {x.strip() for x in str(raw).split(",") if x.strip()}
        domains = {f["domain"]} if f.get("domain") else set()
        if comps and self._has(run_slug, "components"):
            ph = ",".join("?" * len(comps))
            for r in self._rows(
                f"SELECT domain FROM {a}.components WHERE id IN ({ph}) AND domain IS NOT NULL",
                tuple(comps),
            ):
                domains.add(r["domain"])
        return {
            "components": comps,
            "domains": domains,
            "capability": f.get("capability_id"),
        }

    # ── Change → Run ─────────────────────────────────────────────────────────

    def _transitions(self):
        for cs in self._side("change"):
            if not self._has(cs, "transitions"):
                continue
            a = self.brains[cs]["alias"]
            for t in self._rows(f"SELECT * FROM {a}.transitions"):
                yield cs, t

    def change_to_run(self):
        run = set(self._side("run"))
        for cs, t in self._transitions():
            status = (t.get("status") or "").lower()
            src, dst = t.get("from_system"), t.get("to_system")

            # C1
            for role, sys_ in (("from_system", src), ("to_system", dst)):
                if sys_ and sys_ not in run and status not in INACTIVE:
                    self._add(
                        "C1", "change→run", False,
                        f"{t['id']} ({cs}): {role}='{sys_}' no está federado — "
                        f"el cruce no se puede verificar",
                        {"transition": t["id"], role: sys_},
                    )

            # C2 — el que hereda debe saber de qué transición vino lo que opera
            if status in CLOSED and dst in run:
                if not self._has(dst, "components"):
                    absorbed = 0
                else:
                    a = self.brains[dst]["alias"]
                    absorbed = (self._first(
                        f"SELECT COUNT(*) n FROM {a}.components "
                        f"WHERE origin_transition_id=?", (t["id"],)
                    ) or {}).get("n", 0)
                if not absorbed:
                    self._add(
                        "C2", "change→run", True,
                        f"{t['id']} ({cs}) está en '{status}' hacia {dst}, pero {dst} "
                        f"no tiene ningún componente con origin_transition_id — "
                        f"Run no ha absorbido el cambio",
                        {"transition": t["id"], "to_system": dst},
                    )

            # C3 — terminado en Change, vivo en Run
            # Aplica a todos los fates que implican cese del sistema origen:
            # replace, retire, rearchitect y encapsulate (el legacy queda sin dueño).
            if status == "done" and src in run and (t.get("fate") or "") in (
                "replace", "retire", "rearchitect", "encapsulate"
            ):
                alive = [
                    c for c in self._entity_rows(src, t.get("entity_type"), t.get("entity_id"))
                    if (c.get("status") or "active").lower() == "active"
                ]
                if alive:
                    self._add(
                        "C3", "change→run", False,
                        f"{t['id']} ({cs}) dice '{t.get('entity_id')}' done hacia {dst}, "
                        f"pero {src} sigue con {len(alive)} componentes activos en esa "
                        f"entidad — o el decommission no ocurrió o la transición no está done",
                        {"transition": t["id"], "from_system": src,
                         "active_components": len(alive),
                         "sample": [c["id"] for c in alive[:5]]},
                    )

            # C4 — contrato sin medición
            if status in CLOSED and dst in run and self._has(cs, "slos"):
                a = self.brains[cs]["alias"]
                for s in self._rows(
                    f"SELECT * FROM {a}.slos WHERE transition_id=? AND target IS NOT NULL",
                    (t["id"],),
                ):
                    measured = None
                    if self._has(dst, "slos"):
                        b = self.brains[dst]["alias"]
                        measured = self._first(
                            f"SELECT current FROM {b}.slos WHERE id=? AND current IS NOT NULL",
                            (s["id"],),
                        )
                    if not measured:
                        self._add(
                            "C4", "change→run", False,
                            f"SLO {s['id']} ({s.get('metric')} {s.get('target')}) comprometido "
                            f"en {t['id']}; {dst} no lo mide",
                            {"slo": s["id"], "to_system": dst},
                        )

    # ── Run → Change ─────────────────────────────────────────────────────────

    def run_to_change(self):
        open_transitions = [
            (cs, t) for cs, t in self._transitions()
            if (t.get("status") or "").lower() not in INACTIVE
        ]
        for rs in self._side("run"):
            if not self._has(rs, "findings"):
                continue
            a = self.brains[rs]["alias"]
            for f in self._rows(f"SELECT * FROM {a}.findings"):
                route = (f.get("route_status") or "open").lower()
                sev = (f.get("severity") or "").lower()

                # R1 — lo que Run aprendió sobre algo que Change está moviendo
                if route == "open":
                    scope = self._finding_scope(rs, f)
                    for cs, t in open_transitions:
                        if t.get("from_system") != rs:
                            continue
                        et, eid = t.get("entity_type"), t.get("entity_id")
                        hit = (
                            (et == "domain" and eid in scope["domains"])
                            or (et == "component" and eid in scope["components"])
                            or (scope["capability"] and t.get("capability_id") == scope["capability"])
                        )
                        if hit:
                            self._add(
                                "R1", "run→change", sev in GRAVE,
                                f"Hallazgo {f['id']} [{sev}] de {rs} toca '{eid}', que "
                                f"{cs} está moviendo a {t.get('to_system')} "
                                f"({t['id']}, {t.get('status')}) — debe rutearse a {cs}",
                                {"finding": f["id"], "title": f.get("title"),
                                 "transition": t["id"], "change_brain": cs},
                            )

                # R2 — Run avisó; Change no lo registró
                dest = f.get("routed_to_brain")
                if route in ("routed", "accepted") and dest in self.brains:
                    b = self.brains[dest]["alias"]
                    got = False
                    for table in ("user_stories", "risks"):
                        if self._has(dest, table) and self._first(
                            f"SELECT 1 FROM {b}.{table} WHERE origin_finding_id=? OR id=?",
                            (f["id"], f.get("routed_ref") or ""),
                        ):
                            got = True
                            break
                    if not got:
                        self._add(
                            "R2", "run→change", True,
                            f"Hallazgo {f['id']} de {rs} ruteado a {dest}, pero {dest} no "
                            f"tiene story ni riesgo con origin_finding_id — Change no lo recibió",
                            {"finding": f["id"], "change_brain": dest},
                        )

    # ── Orquestación y reporte ───────────────────────────────────────────────

    def run(self):
        self.change_to_run()
        self.run_to_change()
        return self

    @property
    def intact(self):
        return not any(b.blocking for b in self.breaks)

    def as_dict(self):
        return {
            "brains": {s: {k: v for k, v in b.items() if k != "tables"}
                       for s, b in self.brains.items()},
            "result": "INTEGRO" if self.intact else "RUPTURA",
            "breaks": [b.as_dict() for b in self.breaks],
        }

    def render(self):
        out = ["CUERPO CALLOSO — puente Change–Run", "=" * 62]
        for s, b in self.brains.items():
            out.append(f"  {b['hemisphere'] or '?':<6} {s:<22} {b['path']}")
        for direction in ("change→run", "run→change"):
            items = [b for b in self.breaks if b.direction == direction]
            out.append("")
            out.append(f"{direction.upper()} — {len(items)} hallazgos")
            for b in items:
                tag = "BLOQUEA" if b.blocking else "aviso  "
                out.append(f"  [{tag}] {b.code} {b.message}")
        out.append("")
        n = sum(b.blocking for b in self.breaks)
        out.append("RESULTADO: " + ("puente íntegro" if self.intact else f"RUPTURA — {n} bloqueantes"))
        return "\n".join(out)


def brains_from_enterprise(path: Path) -> list[Path]:
    con = sqlite3.connect(f"file:{path.resolve().as_posix()}?mode=ro", uri=True)
    try:
        # Filtra solo los brains con brain_attached=1; los declarados pero sin
        # archivo no generan FileNotFoundError en el ATTACH posterior.
        rows = con.execute(
            "SELECT brain_path FROM federated_brains WHERE brain_attached=1"
        ).fetchall()
    except sqlite3.Error:
        # Tabla sin columna brain_attached (brains pre-homologación): cargar todos
        rows = con.execute("SELECT brain_path FROM federated_brains").fetchall()
    con.close()
    candidates = [(path.parent / r[0]).resolve() for r in rows]
    return [p for p in candidates if p.exists()]


def main():
    p = argparse.ArgumentParser(description="Razona el puente Change–Run entre brains")
    p.add_argument("--brain", action="append", default=[], help="ruta a un brain.db (repetible)")
    p.add_argument("--enterprise", help="enterprise brain: federa sus federated_brains")
    p.add_argument("--json", action="store_true")
    args = p.parse_args()

    paths = [Path(b) for b in args.brain]
    try:
        if args.enterprise:
            paths += brains_from_enterprise(Path(args.enterprise))
        if len(paths) < 2:
            print("ERROR: el puente requiere al menos dos brains", file=sys.stderr)
            return 2
        c = Callosum(paths).run()
    except (FileNotFoundError, sqlite3.Error) as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 2

    print(json.dumps(c.as_dict(), ensure_ascii=False, indent=2) if args.json else c.render())
    return 0 if c.intact else 1


if __name__ == "__main__":
    sys.exit(main())
