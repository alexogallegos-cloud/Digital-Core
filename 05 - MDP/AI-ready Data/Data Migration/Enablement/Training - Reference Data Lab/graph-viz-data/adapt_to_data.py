#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
adapt_to_data.py - post-procesador de vocabulario para el graph-view de datos.

El visualizador render_graph.py vive en el Specialist - Reverse Engineering de
Mainframe y su copy (modal de entrada, leyenda, labels, JS inline) esta en
vocabulario de CODIGO mainframe (programs / copybooks / CALL / inquiry / Unisys).
Este script NO toca el renderer compartido: toma el HTML YA renderizado y
reemplaza el vocabulario por el de DATOS/SAP (tablas / FK / tabla compartida /
referencia vs transaccional). Reusable para cualquier graph-view de este Lab.

Uso:  python adapt_to_data.py <ruta/graph-view.html> [mas rutas...]
"""
import sys

# (old -> new). Frases completas para evitar colisiones. Cubre HTML y JS inline.
REPL = [
    # --- modal de entrada ---
    ("Dependency graph of a mainframe system · <b>each node is a program</b>, each edge a call",
     "Grafo de dependencias de un data estate (SAP Banking) · <b>cada nodo es una tabla</b>, cada arista una relación FK"),
    ("A real mainframe system is <b>not</b> a clean tree of boxes and arrows. It's a <i>hairball</i>: hundreds of programs where everything touches everything through shared utilities and common data structures.",
     "Un data estate real <b>no</b> es un árbol limpio de cajas y flechas. Es un <i>hairball</i>: cientos de tablas donde todo toca todo a través de tablas compartidas (customizing, master) y claves comunes."),
    ("This view exposes the real topology: hubs, cycles, communities and couplings.",
     "Esta vista expone la topología real: hubs, ciclos, comunidades y acoplamientos."),
    ("<b>Why does it look like a cloud?</b>", "<b>¿Por qué parece una nube?</b>"),
    ("That density is exactly where the pain —and the risk— of a migration project lives.",
     "Esa densidad es justo donde vive el dolor —y el riesgo— de un proyecto de migración."),
    # --- grid de stats ---
    ("<span>programs (graph nodes)</span>", "<span>tablas (nodos del grafo)</span>"),
    ("<span>call dependencies (edges)</span>", "<span>relaciones FK (aristas)</span>"),
    ("<span>highest fan-in hub (called by hundreds)</span>", "<span>hub de mayor fan-in (referenciado por cientos)</span>"),
    ("<span>cycles — circular dependencies between programs</span>", "<span>ciclos — dependencias circulares entre tablas</span>"),
    ("<span>unreachable nodes — likely dead code</span>", "<span>nodos no referenciados — tablas muertas (RETIRE)</span>"),
    ("<span>shared copybooks — data coupling</span>", "<span>tablas compartidas — acoplamiento de datos</span>"),
    ("<span>inquiry / update transactions</span>", "<span>tablas de referencia / transaccionales</span>"),
    # --- bullets ---
    ("<li><b>Hubs</b> — the few programs called by hundreds. Changing one impacts half the system: maximum <i>blast radius</i>. White border = utility; gold = business hub.</li>",
     "<li><b>Hubs</b> — las pocas tablas referenciadas por cientos (company code, moneda, business partner, GL account). Cambiar una impacta medio sistema: máximo <i>blast radius</i>. Borde dorado = hub.</li>"),
    ("<li><b>Cycles (SCCs)</b> — with circular dependencies there is no topological order, so <b>there is no obvious \"migration order\"</b>.</li>",
     "<li><b>Ciclos (SCCs)</b> — con dependencias circulares no hay orden topológico, así que <b>no hay un \"orden de migración\" obvio</b> dentro del ciclo.</li>"),
    ("<li><b>Dead clusters</b> — subsystems nobody calls anymore but still in the library: candidates to retire (and a risk if migrated by mistake).</li>",
     "<li><b>Dead clusters</b> — módulos legacy que nadie referencia pero siguen en la base: candidatos a RETIRE (y riesgo si se migran por error).</li>"),
    ("<li><b>Color by access</b> — distinguishes <b>inquiry</b> transactions (read-only, teal) from <b>update</b> ones (writes, amber). Derived from data-access verbs: an inquiry never reaches a write. Inquiry ones migrate <b>early and low-risk</b> (CQRS, read replica, cache); update ones are the hard transactional core (ACID, regulatory).</li>",
     "<li><b>Color por acceso</b> — distingue tablas de <b>referencia</b> (read-mostly: customizing/text/totals, teal) de las <b>transaccionales/master</b> (amber). Las de referencia migran <b>temprano y de bajo riesgo</b>; las transaccionales son el núcleo ACID (regulatorio).</li>"),
    ("<li><b>Copybook coupling layer</b> — the <b>hidden hairball</b>. Select a shared copybook (e.g. <kbd id=\"m-topcpy\">—</kbd>): you'll see programs coupled by data <u>without a single call arrow</u> between them, sometimes across domains.</li>",
     "<li><b>Acoplamiento por tabla compartida</b> — el <b>hairball oculto</b>. Selecciona una tabla compartida (p.ej. <kbd id=\"m-topcpy\">—</kbd>): verás tablas acopladas por datos <u>sin una FK directa</u> entre ellas, a veces de módulos distintos.</li>"),
    ("<li><b>Click a node</b> — highlights and <b>names its neighbors</b> (who it calls in amber, who calls it in teal); click the background to clear.</li>",
     "<li><b>Click en un nodo</b> — resalta y <b>nombra sus vecinos</b> (a quién referencia en amber, quién la referencia en teal); click al fondo para limpiar.</li>"),
    ("<b>Takeaway:</b> planning a Strangler Fig by looking only at the call graph <b>fails</b>, because data coupling (copybooks) is invisible there. Navigate with <kbd>scroll</kbd> to zoom and drag to pan.",
     "<b>Takeaway:</b> planear un Strangler Fig mirando solo el grafo de FK <b>falla</b>, porque el acoplamiento por tablas compartidas es invisible ahí. Usa <kbd>scroll</kbd> para zoom y arrastra para mover."),
    ("— what are you looking at?", "— ¿qué estás viendo?"),
    ("<b>What each control on the left panel shows:</b>", "<b>Qué muestra cada control del panel izquierdo:</b>"),
    (">Explore the graph<", ">Explorar el grafo<"),
    # --- sidebar / selects / labels ---
    ("<h3>Copybook coupling layer</h3>", "<h3>Acoplamiento por tabla compartida</h3>"),
    ("<h3>Search program</h3>", "<h3>Buscar tabla</h3>"),
    ("placeholder=\"e.g. DEPB0144 / UDMSIIWR\"", "placeholder=\"p.ej. BUT000 / T001\""),
    ("<option value=\"access\">Access: inquiry vs update</option>", "<option value=\"access\">Acceso: referencia vs transaccional</option>"),
    ("<option value=\"domain\">Domain (community)</option>", "<option value=\"domain\">Dominio / módulo (comunidad)</option>"),
    ("The hidden hairball: programs that share a", "El hairball oculto: tablas que comparten una"),
    ("copybook are coupled by data even if they never call each other.", "tabla de referencia están acopladas por datos aunque no tengan FK directa."),
    ("UTIL / hub (shared)", "Tabla compartida / hub"),
    # --- JS inline (literales) ---
    ("Each node is a program. Its layer:", "Cada nodo es una tabla. Su arquetipo:"),
    ("\" progs)\"", "\" tablas)\""),
    ("Copybooks (${d.cpys.length})", "Tablas compartidas (${d.cpys.length})"),
    ("</b> programs. Dotted edges = data coupling \"+", "</b> tablas. Aristas punteadas = acoplamiento de datos \"+"),
    ("\"(no CALL). Dimmed nodes do not use it.\"", "\"(sin FK directa). Nodos atenuados no la usan.\""),
    ("The hidden hairball: programs sharing a copybook are coupled by \"+", "El hairball oculto: tablas que comparten una tabla de referencia están \"+"),
    ("\"data even if they never call each other.\"", "\"acopladas por datos aunque no tengan FK directa.\""),
    ("read:\"inquiry (read-only)\", update:\"update (writes)\", none:\"no data access\"",
     "read:\"referencia (read-mostly)\", update:\"transaccional (escritura)\", none:\"sin acceso\""),
    ("[[\"read\",\"inquiry (read-only)\"],[\"update\",\"update (writes)\"],[\"none\",\"no access\"]]",
     "[[\"read\",\"referencia (read-mostly)\"],[\"update\",\"transaccional (escritura)\"],[\"none\",\"sin acceso\"]]"),
    ("source not available (graph node)", "sin esquema disponible para este nodo"),
    (">View source code<", ">Ver esquema (DDL de referencia)<"),
    (" — source code", " — esquema (DDL de referencia)"),
    ("generated skeleton · COPY = copybook coupling · CALL = graph edges",
     "esquema de referencia · columnas FK = aristas del grafo (topología)"),
    ("Calls (${outs.length})", "Referencia a (${outs.length})"),
    ("Called by (${ins.length})", "Referenciada por (${ins.length})"),
    ("generated skeleton · COPY = copybook coupling · CALL = graph edges",
     "grafo generado · tabla compartida = acoplamiento · FK = aristas"),
    # --- selector de capa de coupling (encabezado dropdown) ---
    ("Search program", "Buscar tabla"),
]


def adapt(path):
    with open(path, "r", encoding="utf-8") as f:
        html = f.read()
    n = 0
    for old, new in REPL:
        if old in html:
            html = html.replace(old, new)
            n += 1
    with open(path, "w", encoding="utf-8") as f:
        f.write(html)
    return n


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("uso: python adapt_to_data.py <graph-view.html> [...]")
        sys.exit(1)
    for p in sys.argv[1:]:
        applied = adapt(p)
        print("adaptado %s (%d reemplazos aplicados)" % (p, applied))