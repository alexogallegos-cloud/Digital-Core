#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
load-action-catalog.py — El catálogo de acciones de BanCoppel y su linaje (Regla B39).

Siembra `action_catalog` y `actions` en bank-brain.db con las acciones reales del
programa, empezando por el workaround de capacidad de Caja de noviembre de 2026.

Por qué existe esta tabla aquí y no solo en el asset: B39 dice que el nivel de
autonomía no lo decide la intención sino la naturaleza de la acción, y eso solo
es verificable si cada acción concreta del cliente está catalogada. Mientras el
dictamen vivió en una conversación, nadie podía revisar después con qué nivel se
propuso algo ni quién tenía que firmarlo.

Va en su propio cargador porque `build-bank-brain.py` borra y recrea la base en
cada corrida. Se encadena al final de ese pipeline, igual que el grafo de
dependencias.

Pendiente de rebindeo: `accountable_role` trae el nombre del rol canónico. Cuando
bank-brain tenga tabla `stakeholders` con los roles reales de BanCoppel, estas
filas apuntan a su id.

Uso:
  python generators/load-action-catalog.py
"""
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
DB = BASE / "digital-brain" / "bank-brain.db"
TS = datetime.now(timezone.utc).isoformat(timespec="seconds")

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DDL = """
CREATE TABLE IF NOT EXISTS action_catalog (
    id                TEXT PRIMARY KEY,
    tier              TEXT NOT NULL DEFAULT 'bronze',
    action_type       TEXT NOT NULL,
    itom_domain       TEXT,
    description       TEXT,
    authorized_level  TEXT NOT NULL DEFAULT 'A1',   -- A0 | A1 | A2 | A3 (Regla B39)
    never_below_a3    INTEGER NOT NULL DEFAULT 0,
    accountable_role  TEXT,
    tool              TEXT,
    creates_only      INTEGER NOT NULL DEFAULT 1,
    authorized_by     TEXT,
    authorized_at     TEXT,
    demoted_reason    TEXT
);

CREATE TABLE IF NOT EXISTS actions (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    tier              TEXT NOT NULL DEFAULT 'bronze',
    catalog_id        TEXT NOT NULL,
    level             TEXT NOT NULL,
    what              TEXT NOT NULL,
    target_table      TEXT,
    target_id         TEXT,
    knowledge_refs    TEXT,
    knowledge_tier    TEXT,
    approved_by       TEXT,
    approved_at       TEXT,
    executed_at       TEXT,
    outcome           TEXT,
    incident_id       TEXT,
    outcome_notes     TEXT,
    query_id          TEXT,
    decision_id       TEXT
);
CREATE INDEX IF NOT EXISTS ix_actions_catalog ON actions(catalog_id);
"""

# Las acciones del workaround de Caja. El nivel sale de la naturaleza de la accion,
# no de lo conveniente que seria. Las que llevan never_below_a3 en 1 son las que
# caen en los cuatro tipos que nunca bajan de A3, y en cada una se dice por cual
# de las dos razones del canon: o el efecto sobre lo ya ocurrido no se recupera, o
# hay consecuencia regulatoria directa. Casi todas estas SI se deshacen
# tecnicamente; lo que no se deshace es el tiempo que estuvieron vigentes.
CATALOGO = [
    ("ACT-BCOP-param150-reintentos",
     "Bajar a 1 el parametro 150 NUMERO_INTENTOS_WS_BUS",
     "Technology Operations",
     "Apaga los reintentos inmediatos del cliente SOAP de CPlaSu contra el BUS. El valor "
     "seguro es 1: la condicion es intentos == numIntentosWs arrancando en cero, asi que 0 "
     "truena la primera llamada de toda operacion de ventanilla. Es dato en DB2, no codigo, "
     "asi que no requiere despliegue; requiere firma igual. Nunca baja de A3 porque las "
     "operaciones de ventanilla que ocurran mientras este puesto quedan hechas: revertir "
     "el parametro no revierte lo que paso con los clientes en esa ventana.",
     "A3", 1, "Change Manager", "DB2 parametros web", 0),
    ("ACT-BCOP-param151-mensaje",
     "Redactar el parametro 151 MENSAJE_INTENTOS_WS_BUS",
     "Technology Operations",
     "Es el texto que ve el cajero al agotarse los intentos. Va de la mano del 150: con un "
     "solo intento el error transitorio deja de absorberse y le llega al cajero. Nunca baja "
     "de A3 porque es texto de cara al cliente y lo que se le dijo mal ya se le dijo.",
     "A3", 1, "Change Manager", "DB2 parametros web", 0),
    ("ACT-BCOP-param916-huella",
     "Bajar los reintentos de reenvio de huella, parametro 916",
     "Technology Operations",
     "Mismo mecanismo sobre el segundo amplificador. El evento del 14 de octubre fue de "
     "huella y agoto los 1,200 hilos del IHS de puresys14. Nunca baja de A3 por la misma "
     "razon que el 150: afecta identificacion de clientes en vivo.",
     "A3", 1, "Change Manager", "DB2 parametros web", 0),
    ("ACT-BCOP-alertas-plugin",
     "Configurar alertas sobre http_plugin.log y error.log del IHS",
     "Technology Operations",
     "Marking down, maximum connections y 5xx hacia Caja, con los umbrales de la lamina de "
     "indicadores. Crea reglas de alerta nuevas y no toca el servicio: es la unica del "
     "workaround que puede ir preautorizada.",
     "A2", 0, "Capacity and Availability Manager", "observabilidad", 1),
    ("ACT-BCOP-permiso-cluster27",
     "Corregir el permiso de Cluster_27 hacia el puerto 7824",
     "IT Management",
     "Se marca caido cada dos minutos todo el mes por OS err=13. Habilitante de las alertas: "
     "ensucia justo la senal del http_plugin.log sobre la que se quiere alertar. Nunca baja "
     "de A3 por consecuencia regulatoria: tocar permisos de red entra en el alcance de "
     "PCI-DSS. Clasificada asi de forma conservadora, y aflojarla le toca al risk owner, "
     "no al brain.",
     "A3", 1, "IT Risk Manager", "gestion de seguridad", 0),
    ("ACT-BCOP-entitlement-ihs",
     "Subir el entitlement de los IHS de 0.7 a 1.5-2 en la HMC",
     "Technology Operations",
     "LPAR dinamica, sin reinicio. Seguro contra inanicion del pool compartido, que bajo a "
     "0.86 CPU libres el 16 de octubre a las 17:45. No es un arreglo: ninguna capa satura "
     "CPU. Nunca baja de A3 porque mueve capacidad de un pool compartido y puede dejar "
     "corta a otra LPAR que nadie esta mirando.",
     "A3", 1, "Change Manager", "HMC", 0),
    # El dimensionamiento del EG no es el plugin, y es la unica palanca que ataca la latencia.
    ("ACT-BCOP-dimensionar-eg-caja",
     "Dimensionar el grupo de ejecucion Caja del BUS para quincena",
     "Integration",
     "Hilos del listener, instancias y backlog del EG 7806 a 2x la carga normal. Vive del lado "
     "del broker IIB, NO del plugin del IHS: son artefactos y equipos distintos. Es la unica "
     "accion que ataca la latencia, que es el motor real del techo de conexiones. Pendiente "
     "confirmar si tambien esta bloqueada o solo lo esta el plugin.",
     "A3", 1, "Change Manager", "IBM Integration Bus", 0),
]

# Lo unico que el brain hizo de verdad: proponer. Se registra como A1 porque es
# lo que la regla permite con conocimiento silver, y queda el rastro de que el
# dictamen existio y con que sustento.
PROPUESTAS = [
    (cid, "A1",
     "Propuesta de mitigacion sin despliegue para la temporada, entregada en estado silver",
     "silver",
     "Sale de leer el fuente de CPlaSu y el diagnostico de performance de octubre de 2026. "
     "Sube a gold cuando se lea en DB2 el valor vigente del parametro 150.")
    for cid, *_ in CATALOGO
]


def main():
    if not DB.exists():
        sys.exit(f"No existe {DB}. Corre antes digital-brain/build-bank-brain.py")

    con = sqlite3.connect(DB)
    con.executescript(DDL)
    con.execute("DELETE FROM action_catalog WHERE id LIKE 'ACT-BCOP-%'")
    con.execute("DELETE FROM actions WHERE catalog_id LIKE 'ACT-BCOP-%'")

    con.executemany(
        "INSERT INTO action_catalog (id, tier, action_type, itom_domain, description, "
        "authorized_level, never_below_a3, accountable_role, tool, creates_only, "
        "authorized_by, authorized_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
        [(cid, "gold", tipo, dom, desc, niv, nunca, rol, tool, solo_crea,
          "Change Manager", TS)
         for cid, tipo, dom, desc, niv, nunca, rol, tool, solo_crea in CATALOGO])

    con.executemany(
        "INSERT INTO actions (tier, catalog_id, level, what, knowledge_tier, "
        "executed_at, outcome, outcome_notes) VALUES (?,?,?,?,?,?,?,?)",
        [("gold", cid, niv, what, ktier, TS, "pendiente", nota)
         for cid, niv, what, ktier, nota in PROPUESTAS])

    con.commit()

    print(f"  catalogo: {len(CATALOGO)} acciones  ·  propuestas registradas: {len(PROPUESTAS)}")
    print()
    print(f"  {'accion':<34} {'nivel':<6} {'irrev':<6} {'rol accountable'}")
    for r in con.execute(
            "SELECT id, authorized_level, never_below_a3, accountable_role "
            "FROM action_catalog WHERE id LIKE 'ACT-BCOP-%' ORDER BY authorized_level, id"):
        print(f"  {r[0]:<34} {r[1]:<6} {'si' if r[2] else 'no':<6} {r[3]}")

    irrev = con.execute(
        "SELECT COUNT(*) FROM action_catalog WHERE id LIKE 'ACT-BCOP-%' AND never_below_a3=1"
    ).fetchone()[0]
    a2 = con.execute(
        "SELECT COUNT(*) FROM action_catalog WHERE id LIKE 'ACT-BCOP-%' "
        "AND authorized_level='A2' AND never_below_a3=0").fetchone()[0]
    print()
    print(f"  fijas en A3, siempre exigen aprobacion: {irrev} de {len(CATALOGO)}")
    print(f"  ejecutables preautorizadas   : {a2}")
    print("  nivel efectivo hoy           : A1 en todas, el conocimiento es silver (B39)")
    con.close()


if __name__ == "__main__":
    main()
