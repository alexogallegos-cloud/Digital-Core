"""
demo-n3-maintenance.py  --  Demo: Digital Brain para Mantenimiento N3
Simula el flujo de investigación de un ticket P1 real durante Hot Sale.
Muestra cómo el N3 usa CoppelRetailBrain para diagnosticar y generar runbook.

Uso:
    python demo-n3-maintenance.py
    python demo-n3-maintenance.py --html   # también genera reporte HTML
"""

import sys
import time
import argparse
from pathlib import Path
from datetime import datetime

# ── Ajusta el path para importar brain.py ────────────────────────────────────
BRAIN_DIR = Path(__file__).parent / "systems" / "core" / "ecommerce" / "digital-brain"
sys.path.insert(0, str(BRAIN_DIR))

try:
    from brain import CoppelRetailBrain
except FileNotFoundError as e:
    print(f"\n  ERROR: {e}")
    print("  Ejecuta primero: python systems/core/ecommerce/digital-brain/build-brain.py --reset\n")
    sys.exit(1)

# ── Estilos de terminal ───────────────────────────────────────────────────────
class C:
    RED    = "\033[91m"
    YELLOW = "\033[93m"
    GREEN  = "\033[92m"
    BLUE   = "\033[94m"
    CYAN   = "\033[96m"
    BOLD   = "\033[1m"
    DIM    = "\033[2m"
    RESET  = "\033[0m"
    PURPLE = "\033[95m"

def hr(char="─", width=70, color=C.DIM):
    print(f"{color}{char * width}{C.RESET}")

def section(title, icon=""):
    print()
    hr("═")
    print(f"{C.BOLD}{C.CYAN}  {icon}  {title}{C.RESET}")
    hr("═")

def step(n, label):
    print(f"\n{C.BOLD}{C.BLUE}  [{n}] {label}{C.RESET}")
    hr("─", 50)

def tag(text, color=C.GREEN):
    return f"{color}[{text}]{C.RESET}"

def bullet(text, color=C.DIM, prefix="  •"):
    print(f"{prefix} {color}{text}{C.RESET}")

def kv(key, value, key_color=C.YELLOW, val_color=C.RESET):
    print(f"    {key_color}{key:<22}{C.RESET} {val_color}{value}{C.RESET}")

def thinking(msg):
    print(f"  {C.DIM}🧠 Brain: {msg}{C.RESET}")
    time.sleep(0.3)

def alert(msg, color=C.RED):
    print(f"\n  {color}⚠️  {msg}{C.RESET}\n")

def ok(msg):
    print(f"  {C.GREEN}✅ {msg}{C.RESET}")

def info(msg):
    print(f"  {C.BLUE}ℹ️  {msg}{C.RESET}")

# ── Ticket simulado ───────────────────────────────────────────────────────────
TICKET = {
    "id":          "TKT-COPPEL-P1-0001",
    "priority":    "P1",
    "title":       "Checkout caído — usuarios no pueden completar compras",
    "platform":    "Coppel.com (Web)",
    "reported_by": "Equipo eCommerce Coppel",
    "timestamp":   "2026-09-16  10:23:00 CST",
    "environment": "Producción",
    "sla_remaining": "5 días hábiles",
    "symptoms": [
        "Error 500 al hacer clic en 'Pagar'",
        "ATC normal (clientes agregan productos) pero conversión = 0%",
        "Akamai logs: tráfico llegando correctamente a GKEs",
        "Datadog alerta: latencia >10s en subgraph 'Carrito' de Apollo Federation",
        "eGlobal health check: responde OK en panel interno",
    ],
}

# ── HTML report builder ───────────────────────────────────────────────────────
class HtmlReport:
    def __init__(self):
        self.sections: list[str] = []
        self.start = datetime.now()

    def add(self, html: str):
        self.sections.append(html)

    def card(self, title: str, body: str, color="#3498DB") -> str:
        return f"""
<div style="background:#fff;border-radius:8px;border-left:4px solid {color};
            padding:16px;margin:12px 0;box-shadow:0 1px 4px rgba(0,0,0,.08)">
  <div style="font-weight:700;color:{color};margin-bottom:8px">{title}</div>
  <div style="font-size:13px;color:#444;line-height:1.6">{body}</div>
</div>"""

    def table(self, headers: list[str], rows: list[list[str]], color="#C8102E") -> str:
        th = "".join(f"<th>{h}</th>" for h in headers)
        tr = "".join(
            "<tr>" + "".join(f"<td>{c}</td>" for c in r) + "</tr>"
            for r in rows
        )
        return f"""<div style="overflow-x:auto;margin:12px 0">
<table style="width:100%;border-collapse:collapse;font-size:12px">
<thead style="background:{color};color:#fff"><tr>{th}</tr></thead>
<tbody>{tr}</tbody></table></div>"""

    def build(self, brain_summary: dict) -> str:
        body = "\n".join(self.sections)
        return f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Reporte N3 — {TICKET['id']}</title>
<style>
  * {{ box-sizing:border-box; margin:0; padding:0; }}
  body {{ font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;
          background:#F5F5F5;color:#222;font-size:14px; }}
  .header {{ background:#C8102E;color:#fff;padding:24px 32px; }}
  .header h1 {{ font-size:20px;font-weight:700; }}
  .header p  {{ font-size:12px;opacity:.8;margin-top:4px; }}
  .body  {{ padding:24px 32px;max-width:900px; }}
  .badge {{ display:inline-block;padding:3px 10px;border-radius:4px;
            font-size:11px;font-weight:700;color:#fff; }}
  table thead tr td, table thead tr th {{ padding:8px 12px; }}
  table tbody tr td {{ padding:8px 12px;border-bottom:1px solid #eee; }}
  table tbody tr:hover td {{ background:#fafafa; }}
  .step-title {{ font-size:15px;font-weight:700;color:#C8102E;
                 margin:24px 0 8px;border-bottom:2px solid #f0f0f0;padding-bottom:6px; }}
</style>
</head>
<body>
<div class="header">
  <h1>🛒 Reporte de Investigación N3 — Coppel Retail</h1>
  <p>Ticket: {TICKET['id']} · Prioridad: P1 · {self.start.strftime('%Y-%m-%d %H:%M')}</p>
</div>
<div class="body">
  <div class="step-title">🎫 Ticket</div>
  <div style="background:#fff;border-radius:8px;padding:16px;box-shadow:0 1px 4px rgba(0,0,0,.08)">
    <strong style="color:#C8102E">{TICKET['priority']}</strong> ·
    <strong>{TICKET['title']}</strong><br>
    <span style="font-size:12px;color:#888">{TICKET['timestamp']} · {TICKET['environment']}</span>
    <ul style="margin-top:12px;padding-left:20px;font-size:13px;color:#555">
      {''.join(f'<li>{s}</li>' for s in TICKET['symptoms'])}
    </ul>
  </div>
  {body}
  <div class="step-title">📊 Estado del Brain</div>
  {self.card("Coppel Retail Digital Brain — Resumen",
    "<br>".join(f"<strong>{k}</strong>: {v}" for k,v in brain_summary.items()),
    "#27AE60")}
  <p style="font-size:11px;color:#aaa;margin-top:24px">
    Generado por CoppelRetailBrain v{brain_summary.get('version','1.0.0')} ·
    Accenture Digital Core · {self.start.strftime('%Y-%m-%d %H:%M')}
  </p>
</div>
</body>
</html>"""


# ── Demo principal ────────────────────────────────────────────────────────────
def run_demo(generate_html: bool = False):
    report = HtmlReport()

    # ─────────────────────────────────────────────────────────────────────────
    print(f"\n{C.BOLD}{C.RED}{'═'*70}")
    print(f"  🛒  COPPEL RETAIL — DIGITAL BRAIN DEMO  (Mantenimiento N3)")
    print(f"{'═'*70}{C.RESET}")
    print(f"  {C.DIM}Simulación de ticket P1 · Accenture Managed Services N3{C.RESET}\n")

    # PASO 0: El ticket llega
    section("TICKET RECIBIDO", "🎫")
    print(f"\n  {tag('PRIORIDAD', C.RED)} {C.BOLD}{TICKET['priority']}{C.RESET}  "
          f"{tag('PLATAFORMA')} {TICKET['platform']}")
    print(f"\n  {C.BOLD}Título:{C.RESET}  {TICKET['title']}")
    print(f"  {C.BOLD}Hora:  {C.RESET}  {TICKET['timestamp']}")
    print(f"  {C.BOLD}SLA:   {C.RESET}  {C.RED}{TICKET['sla_remaining']}{C.RESET} para resolver")
    print(f"\n  {C.BOLD}Síntomas reportados:{C.RESET}")
    for s in TICKET["symptoms"]:
        bullet(s, C.RESET)

    report.add(f"""<div class="step-title">📋 Síntomas confirmados</div>
<ul style="padding-left:20px;font-size:13px;color:#555;margin:8px 0">
  {''.join(f'<li>{s}</li>' for s in TICKET['symptoms'])}
</ul>""")

    input(f"\n  {C.DIM}[Enter para iniciar investigación con el Digital Brain...]  {C.RESET}")

    # ─────────────────────────────────────────────────────────────────────────
    with CoppelRetailBrain() as brain:

        # PASO 1: Contexto de la plataforma
        section("PASO 1 — Contexto de Impacto de Negocio", "💰")
        step(1, "Consultando KPIs de negocio al Brain")

        info_data = brain.info()
        thinking("Recuperando métricas de impacto del proyecto...")

        impact = int(info_data.get("business_impact_mxn_per_min", 0))
        platform_strategy = info_data.get("platform_strategy", "")
        peak = info_data.get("peak_seasons", "")

        kv("Impacto por minuto:",  f"${impact:,} MXN / minuto de indisponibilidad", C.RED, C.RED)
        kv("Temporadas pico:",     peak, C.YELLOW, C.YELLOW)
        kv("Estrategia plataforma:", platform_strategy[:60] + "...")
        kv("Modelo de soporte:", info_data.get("model", ""))

        # Verificar si hoy es temporada
        alert(f"Hot Sale puede estar activo — cada minuto caído = ${impact:,} MXN perdidos", C.RED)

        report.add(report.card(
            "💰 Impacto de Negocio",
            f"<strong style='color:red'>${impact:,} MXN/minuto</strong> de indisponibilidad.<br>"
            f"Temporadas pico: {peak}<br>Estrategia: {platform_strategy[:80]}...",
            "#E74C3C"))

        time.sleep(0.5)
        input(f"\n  {C.DIM}[Enter para siguiente paso...]  {C.RESET}")

        # PASO 2: Capacidad afectada
        section("PASO 2 — Identificar la Capacidad Afectada", "🎯")
        step(2, "Consultando capacidad de Checkout en el Brain")

        thinking("Buscando CAP-CART-CHECKOUT en el brain...")
        cap = brain.capability("CAP-CART-CHECKOUT")

        if cap:
            print(f"\n  {C.BOLD}Capacidad encontrada:{C.RESET} {C.GREEN}{cap['name']}{C.RESET}")
            kv("Dominio:",           cap.get("domain", ""))
            kv("Criticidad:",        f"{C.RED}{cap.get('criticality','')}{C.RESET}")
            kv("Estado cobertura:",  cap.get("coverage_status", ""))
            kv("Estado migración:",  f"{C.YELLOW}{cap.get('migration_status','')}{C.RESET}")
            kv("Stack tecnológico:", cap.get("tech_stack", ""))
            kv("Plataforma actual:", cap.get("current_platform", ""))
            kv("Plataforma destino:", cap.get("target_platform", ""))

            if cap.get("notes"):
                print(f"\n  {C.DIM}Notas: {cap['notes']}{C.RESET}")

            alert("Estado MIGRANDO — Checkout usa tanto SFCC APIs como servicios HCL en coexistencia", C.YELLOW)

            tech_stack = cap.get("tech_stack", "").split(",")
            report.add(report.card(
                "🎯 Capacidad Afectada",
                f"<strong>{cap['name']}</strong><br>"
                f"Criticidad: <span style='color:red'>{cap.get('criticality')}</span><br>"
                f"Estado migración: {cap.get('migration_status')}<br>"
                f"Stack: {cap.get('tech_stack')}<br>"
                f"Nota: {cap.get('notes','')}",
                "#E74C3C"))

        time.sleep(0.5)
        input(f"\n  {C.DIM}[Enter para siguiente paso...]  {C.RESET}")

        # PASO 3: Stack de checkout
        section("PASO 3 — Stack Tecnológico del Checkout", "⚙️")
        step(3, "Recuperando componentes del stack involucrados")

        # Technologies involved in checkout based on brain
        checkout_techs = ["sfcc", "apollo-federation", "nextjs", "eglobal"]
        all_stack = brain.stack()
        stack_map = {t["id"]: t for t in all_stack}

        print(f"\n  {C.BOLD}Componentes del stack involucrados en Checkout:{C.RESET}\n")
        stack_rows = []
        for tech_id in checkout_techs:
            tech = stack_map.get(tech_id)
            if tech:
                status_color = C.GREEN if tech["status"] == "active" else C.YELLOW
                print(f"  {status_color}●{C.RESET} {C.BOLD}{tech['name']:<30}{C.RESET} "
                      f"{C.DIM}{tech['role'][:45]}{C.RESET}")
                kv("  Categoría:", tech.get("category", ""))
                kv("  Estado:", tech.get("status", ""))
                if tech.get("notes"):
                    kv("  Nota:", tech["notes"][:80])
                print()
                stack_rows.append([tech["name"], tech["category"], tech["status"], tech.get("role","")[:40]])

        report.add(f"""<div class="step-title">⚙️ Stack del Checkout</div>
{report.table(['Tecnología','Categoría','Estado','Rol'], stack_rows)}""")

        # Alerta SFCC
        sfcc = stack_map.get("sfcc")
        if sfcc and sfcc.get("notes"):
            thinking("Verificando nota crítica sobre SFCC...")
            alert(sfcc["notes"][:120], C.BLUE)

        time.sleep(0.5)
        input(f"\n  {C.DIM}[Enter para siguiente paso...]  {C.RESET}")

        # PASO 4: Mapa de integraciones del checkout
        section("PASO 4 — Integraciones Involucradas", "🔗")
        step(4, "Identificando todas las integraciones que tocan el Checkout")

        thinking("Consultando integraciones críticas en el brain...")
        all_integrations = brain.integrations()

        checkout_keywords = ["checkout", "sfcc", "basket", "eglobal", "apollo", "carrito"]
        relevant_ints = [
            i for i in all_integrations
            if any(kw in (i.get("description", "") + i.get("from_sys", "") +
                          i.get("to_sys", "") + str(i.get("notes", ""))).lower()
                   for kw in checkout_keywords)
            or i.get("criticality") == "critical"
        ]

        print(f"\n  {C.BOLD}Integraciones afectadas o críticas ({len(relevant_ints)}):{C.RESET}\n")
        int_rows = []
        for i in relevant_ints:
            crit_color = C.RED if i["criticality"] == "critical" else C.YELLOW
            status_icon = "✅" if i["status"] == "active" else ("🔄" if i["status"] == "migrating" else "📋")
            print(f"  {status_icon} {crit_color}{i['from_sys']}{C.RESET} "
                  f"→ {C.BOLD}{i['protocol']}{C.RESET} → "
                  f"{crit_color}{i['to_sys']}{C.RESET}")
            if i.get("description"):
                bullet(i["description"][:70], C.DIM)
            if i.get("notes"):
                bullet(f"Nota: {i['notes'][:70]}", C.YELLOW)
            print()
            int_rows.append([
                i["from_sys"], i["protocol"], i["to_sys"],
                i["criticality"], i.get("description", "")[:50]
            ])

        # Diagnóstico de la cadena de fallo
        print(f"  {C.BOLD}Cadena de fallo probable (basada en síntoma Datadog):{C.RESET}")
        chain = [
            ("Next.js Frontend", "GraphQL", "Apollo Federation"),
            ("Apollo Federation", "REST",    "SFCC Basket API"),
            ("SFCC Basket API",   "REST",    "eGlobal"),
        ]
        for src, proto, dst in chain:
            status_txt = f"{C.YELLOW}⚠️ LENTO{C.RESET}" if "Apollo" in src else f"{C.GREEN}OK{C.RESET}"
            print(f"    {src} → [{proto}] → {dst}  {status_txt}")

        report.add(f"""<div class="step-title">🔗 Integraciones del Checkout</div>
{report.table(['Origen','Protocolo','Destino','Criticidad','Descripción'], int_rows)}
<p style="font-size:12px;color:#E74C3C;margin-top:8px">⚠️ Datadog muestra latencia en Apollo Federation → SFCC Basket API</p>""")

        time.sleep(0.5)
        input(f"\n  {C.DIM}[Enter para siguiente paso...]  {C.RESET}")

        # PASO 5: Riesgos relevantes
        section("PASO 5 — Riesgos Conocidos Relacionados", "⚠️")
        step(5, "Consultando registro de riesgos en el Brain")

        thinking("Buscando riesgos de categoría 'operational' y 'migration'...")
        open_risks = brain.open_risks()

        relevant_risks = [
            r for r in open_risks
            if r["category"] in ("operational", "migration", "performance", "technical")
        ]

        print(f"\n  {C.BOLD}Riesgos abiertos relevantes para este ticket:{C.RESET}\n")
        risk_rows = []
        for r in relevant_risks:
            ic = C.RED if r["impact"] == "critical" else C.YELLOW
            print(f"  {ic}[{r['impact'].upper()}]{C.RESET} {C.BOLD}{r['id']}{C.RESET}: {r['title']}")
            if r.get("mitigation"):
                bullet(f"Mitigación: {r['mitigation'][:80]}", C.DIM)
            print()
            risk_rows.append([
                f"<span class='badge' style='background:{'#E74C3C' if r['impact']=='critical' else '#E67E22'}'>"
                f"{r['impact'].upper()}</span>",
                r["id"],
                r["title"],
                (r.get("mitigation") or "")[:60]
            ])

        # Alerta MTTR
        mttr_risk = next((r for r in open_risks if r["id"] == "RISK-MTTR-001"), None)
        if mttr_risk:
            alert(f"RIESGO MTTR ACTIVO: {mttr_risk['title']}\n"
                  f"  Este ticket DEBE resolverse en <5 días hábiles para diferenciarnos del incumbente.", C.RED)

        report.add(f"""<div class="step-title">⚠️ Riesgos Conocidos</div>
{report.table(['Impacto','ID','Riesgo','Mitigación'], risk_rows, '#E67E22')}""")

        time.sleep(0.5)
        input(f"\n  {C.DIM}[Enter para siguiente paso...]  {C.RESET}")

        # PASO 6: Búsqueda libre en el vocabulario
        section("PASO 6 — Lookup de Vocabulario (Apollo Federation)", "📖")
        step(6, "Consultando definición de Apollo Federation en el Brain")

        thinking("Buscando término 'Apollo Federation'...")
        apollo_term = brain.term("Apollo Federation")

        if apollo_term:
            print(f"\n  {C.BOLD}{apollo_term['term']}{C.RESET}")
            print(f"  {apollo_term['definition']}")
            kv("Dominio:", apollo_term.get("domain", ""))
            kv("Fuente:", apollo_term.get("source", ""))
        else:
            print("  Término no encontrado exacto — buscando por FTS...")
            results = brain.search("Apollo Federation")
            for section_name, items in results.items():
                if items:
                    print(f"\n  {C.BOLD}{section_name.upper()}:{C.RESET}")
                    for item in items[:3]:
                        for k, v in item.items():
                            if v:
                                print(f"    {C.DIM}{k}:{C.RESET} {str(v)[:80]}")

        # También lookup de eGlobal
        step("6b", "Verificando contexto de eGlobal (gateway de pagos)")
        thinking("¿eGlobal está en scope N3?")
        eg_cap = brain.capability("CAP-PAYMENTS")
        if eg_cap:
            print(f"\n  {C.BOLD}CAP-PAYMENTS:{C.RESET} {eg_cap['name']}")
            kv("Coverage:", eg_cap.get("coverage_status", ""))
            kv("Estado:", eg_cap.get("migration_status", ""))
            kv("Notas:", (eg_cap.get("notes") or "")[:100])
            info("eGlobal responde OK según síntomas — probable que el fallo sea ANTES del gateway")

        report.add(report.card(
            "📖 Contexto del Brain — Apollo Federation",
            (apollo_term["definition"] if apollo_term else "Ver búsqueda FTS") +
            "<br><br><strong>eGlobal (CAP-PAYMENTS):</strong> native · as-is · acceso restringido PCI",
            "#3498DB"))

        time.sleep(0.5)
        input(f"\n  {C.DIM}[Enter para ver el Runbook generado...]  {C.RESET}")

        # PASO 7: Runbook de diagnóstico generado por el Brain
        section("PASO 7 — Runbook de Diagnóstico Generado", "📋")
        step(7, "Brain genera runbook N3 basado en el análisis")

        print(f"""
  {C.BOLD}RUNBOOK-P1-CHECKOUT  /  {TICKET['id']}{C.RESET}
  {C.DIM}Generado automáticamente por CoppelRetailBrain v1.0.0{C.RESET}

  {C.BOLD}{C.YELLOW}HIPÓTESIS PRINCIPAL{C.RESET} (basada en síntomas + Brain):
    Apollo Federation → subgraph Carrito → SFCC Basket API → timeout/error

  {C.BOLD}1. VERIFICACIÓN RÁPIDA ({C.RED}< 15 min{C.RESET}{C.BOLD}){C.RESET}
  {C.DIM}─────────────────────────────────────────────{C.RESET}
  {C.GREEN}□{C.RESET} Datadog → Dashboard Apollo Federation → subgraph "Carrito"
       Verificar: latencia P95, error rate, timeouts hacia SFCC
  {C.GREEN}□{C.RESET} Datadog → Dashboard SFCC APIs → cpl-ec-sfcc-prod
       Verificar: Basket API endpoint /baskets response times
  {C.GREEN}□{C.RESET} GKE cpl-ec-dcplig-prod → pods Apollo Federation
       Verificar: pod restarts, CPU/memory, logs de error
  {C.GREEN}□{C.RESET} Akamai Dashboard → verificar tráfico y cache hit ratio
       (Akamai = CDN principal, no Redis)

  {C.BOLD}2. DIAGNÓSTICO (si paso 1 confirma SFCC Basket API lento){C.RESET}
  {C.DIM}─────────────────────────────────────────────{C.RESET}
  {C.GREEN}□{C.RESET} SFCC Admin Console → cpl-ec-sfcc-prod → Basket API logs
       Verificar: custom objects con errores, quote timeouts
  {C.GREEN}□{C.RESET} Verificar inventario en tiempo real (SFCC Inventory API)
       Alta carga en Hot Sale = posible lock contention en inventory
  {C.GREEN}□{C.RESET} PostgreSQL → cpl-ec-dcplig-prod → queries lentas
       Tablas de órdenes y carrito bajo alta concurrencia
  {C.GREEN}□{C.RESET} Redis (Google) → caches de sesión saturados
       Session cache miss puede forzar DB calls extra

  {C.BOLD}3. ESCALACIÓN (si no se resuelve en 2h){C.RESET}
  {C.DIM}─────────────────────────────────────────────{C.RESET}
  {C.GREEN}□{C.RESET} Escalar a Coppel Tech (N2) para acceso a plano de control GKE
  {C.GREEN}□{C.RESET} Solicitar configuración de alerta Datadog específica para Basket API
  {C.GREEN}□{C.RESET} Verificar con Coppel si hay deploy reciente en cpl-ec-dcplig-prod
  {C.GREEN}□{C.RESET} Revisar Confluence → CMDB → dependencias del subgraph Carrito

  {C.BOLD}4. COMUNICACIÓN (obligatorio P1){C.RESET}
  {C.DIM}─────────────────────────────────────────────{C.RESET}
  {C.GREEN}□{C.RESET} Update en InvGate cada 30 min con avance
  {C.GREEN}□{C.RESET} ETA de resolución a Coppel eCommerce Team
  {C.GREEN}□{C.RESET} Si SLA P1 en riesgo → escalar a TL N3 Accenture
  {C.RED}□{C.RESET} OBJETIVO: resolver en < 5 días hábiles
       (actual incumbente = 20 días — DEBEMOS diferenciarnos)
""")

        runbook_html = """
<div class="step-title">📋 Runbook de Diagnóstico Generado</div>
<div style="background:#fff;border-radius:8px;padding:20px;
            box-shadow:0 1px 4px rgba(0,0,0,.08);font-size:12px">
  <p><strong style="color:#E74C3C">Hipótesis principal:</strong>
  Apollo Federation → subgraph Carrito → SFCC Basket API → timeout/error</p>
  <br>
  <strong>1. Verificación rápida (< 15 min)</strong>
  <ul style="padding-left:20px;margin:8px 0;color:#555">
    <li>Datadog → Apollo Federation → subgraph Carrito → latencia P95 y error rate</li>
    <li>Datadog → SFCC APIs → cpl-ec-sfcc-prod → Basket API response times</li>
    <li>GKE cpl-ec-dcplig-prod → pods Apollo Federation → pod restarts y logs</li>
    <li>Akamai → tráfico y cache hit ratio</li>
  </ul>
  <strong>2. Diagnóstico (si SFCC Basket API lento)</strong>
  <ul style="padding-left:20px;margin:8px 0;color:#555">
    <li>SFCC Admin → custom objects y quote timeouts</li>
    <li>SFCC Inventory API → lock contention bajo alta carga Hot Sale</li>
    <li>PostgreSQL → queries lentas en tablas de carrito/órdenes</li>
    <li>Redis → caches de sesión saturados</li>
  </ul>
  <strong>3. Escalación (si no resuelto en 2h)</strong>
  <ul style="padding-left:20px;margin:8px 0;color:#555">
    <li>Escalar a Coppel Tech (N2) → acceso plano de control GKE</li>
    <li>Solicitar alerta Datadog específica para Basket API</li>
    <li>Verificar deploy reciente en cpl-ec-dcplig-prod</li>
  </ul>
  <p style="color:#E74C3C;margin-top:12px">
  <strong>⏱️ SLA P1:</strong> < 5 días hábiles.
  Incumbente Publicis Sapient = 20 días. Este ticket define la diferencia.
  </p>
</div>"""
        report.add(runbook_html)

        # PASO 8: Resumen final
        section("RESUMEN — Valor del Digital Brain en este Ticket", "🧠")

        summary = brain.summary()
        print(f"""
  El Brain respondió {C.BOLD}7 preguntas{C.RESET} en segundos que habrían tomado
  horas de exploración manual:

  {C.GREEN}✅{C.RESET} {C.BOLD}Impacto de negocio{C.RESET}:
       $180,000 MXN/min → urgencia cuantificada, no subjetiva

  {C.GREEN}✅{C.RESET} {C.BOLD}Capacidad afectada{C.RESET}:
       CAP-CART-CHECKOUT → criticidad, stack, estado de migración

  {C.GREEN}✅{C.RESET} {C.BOLD}Stack del checkout{C.RESET}:
       SFCC (headless) + Apollo Federation + eGlobal + Next.js

  {C.GREEN}✅{C.RESET} {C.BOLD}Cadena de integraciones{C.RESET}:
       Mapa completo de llamadas → hipótesis del fallo

  {C.GREEN}✅{C.RESET} {C.BOLD}Riesgos conocidos{C.RESET}:
       RISK-MIGR-001 (coexistencia HCL+Composable activa durante Hot Sale)

  {C.GREEN}✅{C.RESET} {C.BOLD}Vocabulario contextual{C.RESET}:
       SFCC = solo APIs headless; Akamai = CDN (no Redis); eGlobal = PCI scope

  {C.GREEN}✅{C.RESET} {C.BOLD}Runbook generado{C.RESET}:
       Pasos de diagnóstico ordenados por hipótesis del Brain

  {C.DIM}Brain stats:{C.RESET}
""")
        for k, v in summary.items():
            bullet(f"{k}: {v}", C.DIM)

        print(f"""
  {C.BOLD}{C.GREEN}{'─'*60}
  El Digital Brain no reemplaza al N3 — lo hace más rápido.
  Conocimiento del día 1, no del mes 3.
  {'─'*60}{C.RESET}
""")

        # Generar HTML report
        if generate_html:
            report_path = Path(__file__).parent / "demo-n3-report.html"
            html = report.build({**summary, "version": "1.0.0"})
            report_path.write_text(html, encoding="utf-8")
            print(f"  {C.GREEN}📄 Reporte HTML generado:{C.RESET}")
            print(f"  {report_path}")
            print(f"  Abre en browser o sirve con: python -m http.server 3002 --directory {report_path.parent}")

        print()
        hr("═")
        print(f"  {C.BOLD}Demo completada.{C.RESET} Digital Brain de Coppel Retail v1.0.0")
        hr("═")
        print()


# ── Entry point ───────────────────────────────────────────────────────────────
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Demo Digital Brain N3 — Coppel Retail")
    parser.add_argument("--html", action="store_true",
                        help="Genera también un reporte HTML al finalizar")
    args = parser.parse_args()
    run_demo(generate_html=args.html)
