"""
build-portal.py — Enterprise Brain Portal Generator · Template Canónico
Versión: 1.0.0 · Enterprise Brain · Digital Core · Accenture México

INSTRUCCIONES DE USO:
    1. Copia este archivo a {sistema}/generators/build-portal.py
    2. Actualiza las constantes de configuración en la sección "Configuración"
    3. Ejecuta: python generators/build-portal.py

REGLA OBLIGATORIA (P4 — Enterprise Brain):
    portal/*.html NUNCA se edita a mano. Este script es la fuente canónica del portal.
    Si el portal necesita ajustes visuales, el ajuste va al generador, no al HTML.

Uso:
    python generators/build-portal.py
    python generators/build-portal.py --system "Nombre del Sistema"
    python generators/build-portal.py --db path/to/brain.db --out path/to/portal
"""

import html as _html
import sqlite3
import json
import argparse
from pathlib import Path
from datetime import datetime

# ── Configuración — ajustar por instancia ────────────────────────────────────
DB_PATH = Path(__file__).parent.parent / "digital-brain" / "brain.db"
PORTAL_PATH = Path(__file__).parent.parent / "portal"
SYSTEM_DISPLAY_NAME = "Sistema"   # Override con --system arg o editar aquí
ACCENTURE_COLOR = "#A100FF"
CLIENT_COLOR = "#1F2D3D"          # Ajustar al color de marca del cliente


# ── Carga de datos ────────────────────────────────────────────────────────────


def e(valor) -> str:
    """
    Escapa un valor del brain antes de interpolarlo en HTML.

    No es paranoia: `business_name` lo sintetiza un LLM y `fragmento` es código
    fuente del cliente, así que un simple `<` rompe la tabla y un payload hace
    cosas peores. El portal se comparte, y ADR-EB-005 lo manda generado, lo que
    significa que nadie lo revisa a mano antes de publicarlo.
    """
    if valor is None:
        return ""
    return _html.escape(str(valor), quote=True)



def n(valor) -> str:
    """
    Formatea un conteo del brain. `None` significa que la tabla no existe en
    este `brain_type`, y eso no es cero: es "no aplica". Mostrarlo como 0
    es lo que hacía que un brain de proyecto pareciera tener cero reglas
    en vez de no tener la tabla.
    """
    if valor is None:
        return "N/A"
    try:
        return f"{int(valor):,}"
    except (TypeError, ValueError):
        return str(valor)


def load_brain(db_path: Path) -> dict:
    """Carga todos los datos necesarios del brain.db para el portal."""
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row

    # Una consulta que falla NO es una consulta que devuelve cero. Confundirlas
    # pintaba de verde los gates de un brain sin la tabla correspondiente.
    def _count(sql: str):
        try:
            return conn.execute(sql).fetchone()[0]
        except sqlite3.Error:
            return None            # no aplica a este brain_type

    def _rows(sql: str) -> list[dict]:
        try:
            return [dict(r) for r in conn.execute(sql).fetchall()]
        except sqlite3.Error:
            return []

    data: dict = {}

    # Identidad del sistema
    try:
        info = conn.execute("SELECT * FROM system_info LIMIT 1").fetchone()
        data["system_info"] = dict(info) if info else {}
    except Exception:
        data["system_info"] = {}

    # Métricas de cobertura
    data["components_count"] = _count("SELECT COUNT(*) FROM components")
    data["rules_count"] = _count("SELECT COUNT(*) FROM rules")
    data["rules_negocio"] = _count(
        "SELECT COUNT(*) FROM rules WHERE clase='NEGOCIO'"
    )
    data["rules_infraestructura"] = _count(
        "SELECT COUNT(*) FROM rules WHERE clase='INFRAESTRUCTURA'"
    )
    data["vocabulary_count"] = _count("SELECT COUNT(*) FROM vocabulary")
    data["journeys_count"] = _count("SELECT COUNT(*) FROM journeys")
    data["souls_count"] = _count(
        "SELECT COUNT(*) FROM components WHERE is_soul=1"
    )

    # Calidad del brain (DoD-EB-02, DoD-EB-03, DoD-EB-04)
    data["quality"] = {
        "business_name_null": _count(
            "SELECT COUNT(*) FROM rules WHERE business_name IS NULL OR business_name=''"
        ),
        "clase_null": _count("SELECT COUNT(*) FROM rules WHERE clase IS NULL"),
        "reg_null": _count("SELECT COUNT(*) FROM rules WHERE reg IS NULL"),
    }

    # Dominios
    data["domains"] = _rows(
        """SELECT domain, COUNT(*) as count
           FROM components
           WHERE domain IS NOT NULL
           GROUP BY domain
           ORDER BY count DESC
           LIMIT 30"""
    )

    # Top reglas de negocio
    data["top_rules"] = _rows(
        """SELECT id, business_name, tipo, clase, reg, domain
           FROM rules
           WHERE clase='NEGOCIO' AND business_name IS NOT NULL AND business_name != ''
           ORDER BY id
           LIMIT 50"""
    )

    # Almas
    data["souls"] = _rows(
        """SELECT id, display_name, description, domain,
                  primary_capability, soul_rank, fan_in
           FROM components
           WHERE is_soul = 1
           ORDER BY soul_rank, fan_in DESC
           LIMIT 20"""
    )

    # Distribución por clase
    data["clase_distribution"] = _rows(
        """SELECT clase, COUNT(*) as count
           FROM rules
           WHERE clase IS NOT NULL
           GROUP BY clase
           ORDER BY count DESC"""
    )

    conn.close()
    return data


# ── Generación HTML ───────────────────────────────────────────────────────────

def generate_html(data: dict, system_name: str) -> str:
    """Genera el HTML completo del portal desde los datos del brain."""
    build_date = datetime.now().strftime("%Y-%m-%d %H:%M")
    info = data.get("system_info", {})
    quality = data.get("quality", {})

    # Quality badges
    bname_null = quality.get("business_name_null", 0)
    clase_null = quality.get("clase_null", 0)
    def _gate(n, etiqueta):
        if n is None:
            return "N/A", "#94a3b8"      # el brain_type no tiene esa tabla
        return ("PASS", "#22c55e") if n == 0 else (f"FAIL ({n} {etiqueta})", "#ef4444")

    dod02, dod02_color = _gate(bname_null, "vacíos")
    dod03, dod03_color = _gate(clase_null, "sin clase")

    # Domains pills
    domains_html = ""
    for d in data.get("domains", []):
        domains_html += f'<span class="pill">{e(d["domain"])} ({e(d["count"])})</span> '

    # Rules table rows
    rules_rows = ""
    for rule in data.get("top_rules", [])[:20]:
        biz = rule.get("business_name", "") or rule.get("id", "")
        tipo = rule.get("tipo", "")
        reg = rule.get("reg", "") or ""
        domain = rule.get("domain", "") or ""
        rules_rows += (
            f"<tr>"
            f"<td>{e(rule.get('id'))}</td>"
            f"<td>{e(biz)}</td>"
            f"<td>{e(tipo)}</td>"
            f"<td>{e(domain)}</td>"
            f"<td>{e(reg)}</td>"
            f"</tr>\n"
        )

    # Souls rows
    souls_rows = ""
    for soul in data.get("souls", []):
        souls_rows += (
            f"<tr>"
            f"<td>{e(soul.get('display_name'))}</td>"
            f"<td>{e(soul.get('domain'))}</td>"
            f"<td>{e(soul.get('fan_in'))}</td>"
            f"<td>{e(soul.get('primary_capability'))}</td>"
            f"</tr>\n"
        )

    # Clase distribution
    clase_rows = ""
    for c in data.get("clase_distribution", []):
        clase_rows += (
            f"<tr>"
            f"<td>{e(c.get('clase'))}</td>"
            f"<td>{c.get('count', 0):,}</td>"
            f"</tr>\n"
        )

    togaf_type = e(info.get("togaf_type"))
    togaf_state = e(info.get("togaf_state"))
    version = e(info.get("version"))

    html = f"""<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{system_name} — Enterprise Brain</title>
    <style>
        :root {{
            --accenture: {ACCENTURE_COLOR};
            --client: {CLIENT_COLOR};
            --bg: #0a0a0f;
            --surface: #12121a;
            --surface2: #1a1a28;
            --border: #2a2a3a;
            --text: #e8e8f0;
            --muted: #8888a8;
            --green: #22c55e;
            --red: #ef4444;
        }}
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ background: var(--bg); color: var(--text); font-family: 'Segoe UI', system-ui, sans-serif; line-height: 1.6; }}

        .hero {{
            background: linear-gradient(135deg, var(--client) 0%, var(--accenture) 100%);
            padding: 48px 32px;
        }}
        .hero h1 {{ font-size: 2rem; font-weight: 700; margin-bottom: 8px; }}
        .hero .subtitle {{ color: rgba(255,255,255,0.8); font-size: 1rem; }}
        .hero .meta {{ font-size: 0.75rem; color: rgba(255,255,255,0.5); margin-top: 12px; }}
        .hero .badges {{ display: flex; gap: 8px; margin-top: 12px; flex-wrap: wrap; }}
        .badge {{ background: rgba(255,255,255,0.15); border-radius: 4px; padding: 2px 10px; font-size: 0.75rem; }}

        .container {{ max-width: 1200px; margin: 0 auto; padding: 32px; }}

        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 16px;
            margin-bottom: 32px;
        }}
        .stat-card {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 20px;
        }}
        .stat-card .value {{ font-size: 2rem; font-weight: 700; color: var(--accenture); }}
        .stat-card .label {{ color: var(--muted); font-size: 0.8rem; margin-top: 4px; }}

        .quality-bar {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 16px 20px;
            margin-bottom: 24px;
            display: flex;
            gap: 24px;
            flex-wrap: wrap;
            align-items: center;
        }}
        .quality-bar .label {{ color: var(--muted); font-size: 0.85rem; }}
        .quality-item {{ display: flex; align-items: center; gap: 8px; font-size: 0.85rem; }}
        .dot {{ width: 8px; height: 8px; border-radius: 50%; }}

        .section {{ margin-bottom: 32px; }}
        .section h2 {{
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 16px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 8px;
        }}

        .pill {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 4px 12px;
            font-size: 0.78rem;
            display: inline-block;
            margin: 3px;
        }}

        table {{ width: 100%; border-collapse: collapse; font-size: 0.82rem; }}
        th {{
            text-align: left;
            padding: 10px 12px;
            background: var(--surface2);
            border-bottom: 1px solid var(--border);
            color: var(--muted);
            font-weight: 500;
        }}
        td {{ padding: 9px 12px; border-bottom: 1px solid var(--border); vertical-align: top; }}
        tr:hover td {{ background: rgba(161,0,255,0.04); }}

        .footer {{
            text-align: center;
            padding: 24px;
            color: var(--muted);
            font-size: 0.78rem;
            border-top: 1px solid var(--border);
            margin-top: 32px;
        }}
    </style>
</head>
<body>

<div class="hero">
    <h1>{system_name}</h1>
    <p class="subtitle">Enterprise Brain — Gemelo Cognitivo del Sistema</p>
    <div class="badges">
        {'<span class="badge">' + togaf_type + '</span>' if togaf_type else ''}
        {'<span class="badge">' + togaf_state + '</span>' if togaf_state else ''}
        {'<span class="badge">v' + version + '</span>' if version else ''}
    </div>
    <p class="meta">Generado: {build_date} · Digital Core · Accenture México · NUNCA editar a mano</p>
</div>

<div class="container">

    <div class="stats-grid">
        <div class="stat-card">
            <div class="value">{n(data.get('components_count'))}</div>
            <div class="label">Componentes</div>
        </div>
        <div class="stat-card">
            <div class="value">{n(data.get('rules_negocio'))}</div>
            <div class="label">Reglas de negocio</div>
        </div>
        <div class="stat-card">
            <div class="value">{n(data.get('rules_count'))}</div>
            <div class="label">Reglas totales</div>
        </div>
        <div class="stat-card">
            <div class="value">{n(data.get('vocabulary_count'))}</div>
            <div class="label">Vocabulario</div>
        </div>
        <div class="stat-card">
            <div class="value">{n(data.get('journeys_count'))}</div>
            <div class="label">Customer journeys</div>
        </div>
        <div class="stat-card">
            <div class="value">{data.get('souls_count', 0)}</div>
            <div class="label">Almas (módulos)</div>
        </div>
        <div class="stat-card">
            <div class="value">{len(data.get('domains', []))}</div>
            <div class="label">Dominios</div>
        </div>
    </div>

    <div class="quality-bar">
        <span class="label">Calidad del brain:</span>
        <div class="quality-item">
            <div class="dot" style="background:{dod02_color}"></div>
            DoD-EB-02 business_name: {dod02}
        </div>
        <div class="quality-item">
            <div class="dot" style="background:{dod03_color}"></div>
            DoD-EB-03 clase: {dod03}
        </div>
    </div>

    <div class="section">
        <h2>Dominios cubiertos</h2>
        <div>{domains_html or '<span class="pill">Sin dominios registrados</span>'}</div>
    </div>

    {f'''
    <div class="section">
        <h2>Almas del sistema</h2>
        <table>
            <thead>
                <tr><th>Alma</th><th>Dominio</th><th>SPs</th><th>Capability ETB</th></tr>
            </thead>
            <tbody>{souls_rows or '<tr><td colspan="4">Sin almas registradas</td></tr>'}</tbody>
        </table>
    </div>
    ''' if souls_rows else ''}

    <div class="section">
        <h2>Distribución de reglas por naturaleza</h2>
        <table>
            <thead><tr><th>Clase</th><th>Cantidad</th></tr></thead>
            <tbody>{clase_rows or '<tr><td colspan="2">Sin datos</td></tr>'}</tbody>
        </table>
    </div>

    <div class="section">
        <h2>Muestra de reglas de negocio</h2>
        <table>
            <thead>
                <tr><th>ID</th><th>Regla de negocio</th><th>Tipo</th><th>Dominio</th><th>Regulación</th></tr>
            </thead>
            <tbody>{rules_rows or '<tr><td colspan="5">Sin reglas registradas</td></tr>'}</tbody>
        </table>
    </div>

</div>

<div class="footer">
    Enterprise Brain · {system_name} · Digital Core · Accenture México<br>
    Este portal es generado automáticamente desde brain.db · Regla P4 Enterprise Brain · No editar a mano
</div>

</body>
</html>"""
    return html


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> int:
    parser = argparse.ArgumentParser(description="Enterprise Brain Portal Generator")
    parser.add_argument("--system", default=SYSTEM_DISPLAY_NAME, help="Nombre del sistema")
    parser.add_argument("--db", default=str(DB_PATH), help="Ruta al brain.db")
    parser.add_argument("--out", default=str(PORTAL_PATH), help="Carpeta de salida del portal")
    args = parser.parse_args()

    db_path = Path(args.db)
    portal_path = Path(args.out)

    if not db_path.exists():
        print(f"ERROR: brain.db no encontrado en {db_path}")
        print("Ejecuta primero: python digital-brain/build-brain.py")
        return 1

    portal_path.mkdir(parents=True, exist_ok=True)

    print(f"Cargando brain desde {db_path}...")
    data = load_brain(db_path)

    print(f"Generando portal '{args.system}'...")
    html = generate_html(data, args.system)

    out_file = portal_path / "index.html"
    out_file.write_text(html, encoding="utf-8")

    print(f"Portal generado: {out_file}")
    print(f"  Componentes:      {n(data.get('components_count'))}")
    print(f"  Reglas negocio:   {n(data.get('rules_negocio'))}")
    print(f"  Reglas totales:   {n(data.get('rules_count'))}")
    print(f"  Vocabulario:      {n(data.get('vocabulary_count'))}")
    print(f"  Journeys:         {n(data.get('journeys_count'))}")
    print(f"  DoD-EB-02 (biz null): {data['quality'].get('business_name_null', 0)}")
    print(f"  DoD-EB-03 (clase null): {data['quality'].get('clase_null', 0)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
