"""
build-showcase-arquitectura.py — Genera portal/showcase-arquitectura.html
Mapa de Arquitectura Tecnológica de AXA México — datos reales del TOGAF PDF.
Fuente: arquitectura_TOGAF_accenture_v19.pdf (Fases A–H).
"""
import pathlib

ROOT     = pathlib.Path(__file__).parent.parent
OUT_HTML = ROOT / "portal" / "showcase-arquitectura.html"

HTML = r"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Digital Brain · Mapa de Arquitectura — AXA México</title>
<style>
:root{
  --axa-blue:#00008F; --axa-red:#FF1721;
  --bg:#080c1a; --panel:#0d1225; --glass:rgba(255,255,255,.05);
  --border:rgba(255,255,255,.10); --txt:#e8eaf6; --dim:#8899bb;
  --vida:#7c3aed; --salud:#0ea5e9; --danos:#f59e0b; --autos:#10b981;
  --integ:#3b82f6; --data:#8b5cf6; --ent:#64748b; --agent:#FF1721;
}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Segoe UI',system-ui,sans-serif;min-height:100vh}

/* ── Nav ─────────────────────────────── */
nav{
  position:fixed;top:0;left:0;right:0;z-index:100;
  display:flex;align-items:center;justify-content:space-between;
  padding:10px 24px;background:rgba(8,12,26,.92);
  backdrop-filter:blur(12px);border-bottom:1px solid var(--border);
}
nav .logo{display:flex;align-items:center;gap:12px}
nav .logo img{height:28px}
nav .badge{
  font-size:10px;font-weight:700;letter-spacing:.08em;
  padding:3px 9px;border-radius:4px;
  background:rgba(255,23,33,.14);border:1px solid rgba(255,23,33,.35);color:#ff6677;
}
nav a{color:var(--dim);text-decoration:none;font-size:13px}
nav a:hover{color:var(--txt)}

/* ── Hero ────────────────────────────── */
.hero{
  padding:96px 32px 32px;text-align:center;
  background:radial-gradient(ellipse at 50% 0,rgba(0,0,143,.18) 0,transparent 70%);
}
.hero h1{font-size:clamp(22px,3vw,32px);font-weight:700;letter-spacing:-.02em;margin-bottom:8px}
.hero p{color:var(--dim);font-size:14px;max-width:640px;margin:0 auto 20px}
.hero .meta{display:flex;justify-content:center;gap:16px;flex-wrap:wrap}
.hero .meta span{font-size:11px;color:var(--dim);padding:4px 10px;border-radius:20px;border:1px solid var(--border)}

/* ── Main layout ─────────────────────── */
.arch{max-width:1400px;margin:0 auto;padding:0 24px 80px}

/* ── Layer ───────────────────────────── */
.layer{margin-bottom:12px}
.layer-head{
  display:flex;align-items:center;gap:10px;
  padding:8px 14px;border-radius:8px 8px 0 0;
  font-size:11px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;
}
.layer-body{
  display:flex;flex-wrap:wrap;gap:8px;
  padding:12px;border-radius:0 0 10px 10px;
  border:1px solid var(--border);border-top:none;background:var(--panel);
}

/* ── Card ────────────────────────────── */
.card{
  background:var(--glass);border:1px solid var(--border);border-radius:8px;
  padding:10px 12px;display:flex;flex-direction:column;align-items:center;
  gap:6px;min-width:110px;flex:1 1 110px;max-width:170px;
  transition:transform .15s,border-color .15s;cursor:default;
  text-align:center;position:relative;
}
.card:hover{transform:translateY(-2px);border-color:rgba(255,255,255,.22)}
.card img{height:28px;max-height:28px;width:auto;max-width:120px;object-fit:contain;display:block}
.card .cname{font-size:11px;font-weight:600;line-height:1.3;color:var(--txt)}
.card .csub{font-size:9.5px;color:var(--dim);line-height:1.3}
.card .ctag{
  font-size:9px;font-weight:700;letter-spacing:.06em;
  padding:2px 6px;border-radius:3px;margin-top:2px;
}
.card .ctag.gap{background:rgba(255,23,33,.15);border:1px solid rgba(255,23,33,.3);color:#ff7788}
.card .ctag.pilot{background:rgba(255,165,0,.12);border:1px solid rgba(255,165,0,.3);color:#ffc060}
.card .ctag.impl{background:rgba(59,130,246,.12);border:1px solid rgba(59,130,246,.3);color:#7ab3f8}
.card .ctag.dep{background:rgba(100,116,139,.12);border:1px solid rgba(100,116,139,.3);color:#94a3b8}

/* ── LOB grid ────────────────────────── */
.lob-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;width:100%}
.lob-col{border-radius:8px;padding:10px;border:1px solid var(--border)}
.lob-col h4{font-size:10px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;margin-bottom:8px;padding-bottom:6px;border-bottom:1px solid var(--border)}
.lob-col .card{max-width:none;min-width:0}

/* ── Layer color vars ─────────────────── */
.layer.canales .layer-head{background:rgba(0,0,143,.25);color:#8899ff}
.layer.lob .layer-head{background:rgba(16,185,129,.1);color:#6ee7b7}
.layer.integ .layer-head{background:rgba(59,130,246,.15);color:#7ab3f8}
.layer.data .layer-head{background:rgba(139,92,246,.15);color:#c4b5fd}
.layer.ent .layer-head{background:rgba(100,116,139,.15);color:#94a3b8}
.layer.agent .layer-head{background:rgba(255,23,33,.15);color:#ff8899}

.lob-col.vida{border-color:rgba(124,58,237,.35);background:rgba(124,58,237,.06)}
.lob-col.vida h4{color:#a78bfa}
.lob-col.salud{border-color:rgba(14,165,233,.35);background:rgba(14,165,233,.06)}
.lob-col.salud h4{color:#7dd3fc}
.lob-col.danos{border-color:rgba(245,158,11,.35);background:rgba(245,158,11,.06)}
.lob-col.danos h4{color:#fcd34d}
.lob-col.autos{border-color:rgba(16,185,129,.35);background:rgba(16,185,129,.06)}
.lob-col.autos h4{color:#6ee7b7}

/* ── Agent layer ─────────────────────── */
.agent-flow{display:flex;align-items:center;gap:6px;width:100%;flex-wrap:wrap}
.agent-card{
  background:rgba(255,23,33,.07);border:1px solid rgba(255,23,33,.2);
  border-radius:8px;padding:10px 14px;flex:1 1 130px;text-align:center;
}
.agent-card .aname{font-size:11.5px;font-weight:600;color:#ffaaaa}
.agent-card .asub{font-size:9.5px;color:#cc7788;margin-top:3px}
.agent-arrow{color:rgba(255,23,33,.5);font-size:18px;font-weight:300;flex-shrink:0}

/* ── Legend ──────────────────────────── */
.legend{
  display:flex;gap:16px;flex-wrap:wrap;justify-content:center;
  padding:16px 0 4px;font-size:11px;color:var(--dim);
}
.legend span{display:flex;align-items:center;gap:5px}
.legend .dot{width:8px;height:8px;border-radius:2px}

/* ── Footer ──────────────────────────── */
footer{text-align:center;padding:24px;font-size:11px;color:var(--dim);border-top:1px solid var(--border)}

/* ── Logo placeholder ───────────────── */
.logo-placeholder{
  height:28px;display:flex;align-items:center;justify-content:center;
  font-size:10px;font-weight:700;color:var(--dim);letter-spacing:.05em;
}
</style>
</head>
<body>

<nav>
  <div class="logo">
    <img src="logos/Axa_logo.png" alt="AXA">
    <span style="font-size:13px;font-weight:600;color:#aabbdd">Digital Brain</span>
    <span style="color:var(--border)">|</span>
    <span style="font-size:12px;color:var(--dim)">Mapa de Arquitectura</span>
  </div>
  <div style="display:flex;align-items:center;gap:12px">
    <span class="badge">DATOS REALES</span>
    <a href="index.html">← Portal</a>
  </div>
</nav>

<div class="hero">
  <h1>AXA México &mdash; Mapa de Arquitectura Tecnológica</h1>
  <p>Landscape tecnológico completo multi-línea (Vida · Salud · Daños · Autos) más plataforma de integración, datos y capa agéntica. Fuente: TOGAF Fases A–H + Competitive Discovery Suscripción Daños.</p>
  <div class="meta">
    <span>22 sistemas confirmados</span>
    <span>4 líneas de negocio</span>
    <span>6 capas arquitectónicas</span>
    <span>Capa agéntica en piloto</span>
  </div>
</div>

<div class="arch">

  <!-- ── CANALES ──────────────────────────────────────────── -->
  <div class="layer canales">
    <div class="layer-head">&#127758; Canales de Distribución &amp; Engagement</div>
    <div class="layer-body">
      <div class="card">
        <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">My AXA</div>
        <div class="cname">My AXA</div>
        <div class="csub">Web + iOS + Android · B2C multi-línea</div>
      </div>
      <div class="card">
        <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">axa.mx</div>
        <div class="cname">axa.mx</div>
        <div class="csub">Portal público · cotizador · siniestros</div>
      </div>
      <div class="card">
        <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">AXA Drive</div>
        <div class="cname">AXA Drive</div>
        <div class="csub">Telemática Autos · iOS + Android</div>
      </div>
      <div class="card">
        <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">Keralty</div>
        <div class="cname">AXA Keralty</div>
        <div class="csub">Portal + app salud · citas · historial</div>
      </div>
      <div class="card">
        <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">Distribuidores</div>
        <div class="cname">Portal Distribuidores</div>
        <div class="csub">Agentes y promotorías · SSO B2B</div>
      </div>
      <div class="card">
        <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">AXA Partners</div>
        <div class="cname">AXA Partners</div>
        <div class="csub">B2B · asistencia · reaseguro · API</div>
      </div>
      <div class="card">
        <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">ATC Plus</div>
        <div class="cname">ATC Plus</div>
        <div class="csub">Atención al cliente interno</div>
      </div>
    </div>
  </div>

  <!-- ── LÍNEAS DE NEGOCIO ─────────────────────────────────── -->
  <div class="layer lob">
    <div class="layer-head">&#127970; Core de Negocio — por Línea de Negocio</div>
    <div class="layer-body">
      <div class="lob-grid">

        <!-- VIDA -->
        <div class="lob-col vida">
          <h4>&#129505; Vida</h4>
          <div class="card">
            <img src="logos/Progress_Software_logo.svg.webp" alt="Progress" height="28" style="max-height:28px;width:auto;max-width:120px">
            <div class="cname">Progress / COBOL</div>
            <div class="csub">Core Vida monolítico legacy</div>
            <span class="ctag gap">GAP CRÍTICO</span>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">SINCO</div>
            <div class="cname">SINCO</div>
            <div class="csub">CRM · base de cuentas</div>
            <span class="ctag gap">Sin ID confiable</span>
          </div>
        </div>

        <!-- SALUD -->
        <div class="lob-col salud">
          <h4>&#128153; Salud</h4>
          <div class="card">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">Visual Time</div>
            <div class="cname">Visual Time</div>
            <div class="csub">SaaS pólizas Salud</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">GMM/ISES</div>
            <div class="cname">GMM 2000 · ISES</div>
            <div class="csub">Pólizas colectivas</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">SaludWeb</div>
            <div class="cname">SaludWeb · SIGAME · DictaMedic</div>
            <div class="csub">Autorización · reembolso · prestaciones</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">Qantev</div>
            <div class="cname">Qantev · RedPres</div>
            <div class="csub">Telemedicina · red prestadores</div>
          </div>
        </div>

        <!-- DAÑOS -->
        <div class="lob-col danos">
          <h4>&#127968; Daños (P&amp;C)</h4>
          <div class="card">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">General Daños</div>
            <div class="cname">General Daños / SED</div>
            <div class="csub">Emisión pólizas · endosos</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">Vector</div>
            <div class="cname">Vector</div>
            <div class="csub">Workflow suscripción · folios</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">HSD Excel</div>
            <div class="cname">HSD (Excel)</div>
            <div class="csub">Cálculo técnico manual</div>
            <span class="ctag gap">GAP CRÍTICO</span>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">ERN</div>
            <div class="cname">ERN</div>
            <div class="csub">Modelación catastrófica · PML</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">SAFAC</div>
            <div class="cname">SAFAC</div>
            <div class="csub">Reaseguro Facultativo</div>
          </div>
        </div>

        <!-- AUTOS -->
        <div class="lob-col autos">
          <h4>&#128663; Autos</h4>
          <div class="card">
            <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">Visual Time</div>
            <div class="cname">Visual Time</div>
            <div class="csub">SaaS pólizas Autos</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Guidewire-logo.png" alt="Guidewire" height="28" style="max-height:28px;width:auto;max-width:120px">
            <div class="cname">Guidewire Claims</div>
            <div class="csub">Core siniestros Autos</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Audatex-logo.webp" alt="Audatex" height="28" style="max-height:28px;width:auto;max-width:120px">
            <div class="cname">Audatex</div>
            <div class="csub">Peritación · valoración daños</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/Shift-Technology-logo.png" alt="Shift Technology" height="28" style="max-height:28px;width:auto;max-width:120px">
            <div class="cname">Shift Technology</div>
            <div class="csub">Detección fraude ML</div>
          </div>
          <div class="card" style="margin-top:6px">
            <img src="logos/FIS_logo.svg" alt="FIS" height="28" style="max-height:28px;width:auto;max-width:120px">
            <div class="cname">FIS Payments</div>
            <div class="csub">Pasarela de pagos · siniestros</div>
          </div>
        </div>

      </div>
    </div>
  </div>

  <!-- ── INTEGRACIÓN ───────────────────────────────────────── -->
  <div class="layer integ">
    <div class="layer-head">&#128279; Integración &amp; Seguridad Perimetral</div>
    <div class="layer-body">
      <div class="card" style="max-width:200px">
        <img src="logos/mulesoft_logo.webp" alt="MuleSoft" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">MuleSoft Anypoint</div>
        <div class="csub">iPaaS · bus canónico · mediación · adaptadores</div>
        <span class="ctag impl">EN IMPLEMENTACIÓN</span>
      </div>
      <div class="card">
        <img src="logos/IBM_logo.svg" alt="IBM" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">Datapower MPG</div>
        <div class="csub">API Gateway · OAuth 2.0 · TLS 1.2 · X509</div>
      </div>
      <div class="card">
        <img src="logos/f5-logo.svg" alt="F5" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">F5</div>
        <div class="csub">Balanceo de carga · SSL offload</div>
      </div>
      <div class="card">
        <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">WAF</div>
        <div class="cname">WAF · IPS/IDS</div>
        <div class="csub">Web Application Firewall · IP listing</div>
      </div>
      <div class="card">
        <img src="logos/OpenShift-Logo.webp" alt="OpenShift" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">OpenShift</div>
        <div class="csub">Contenedores · nube privada</div>
      </div>
      <div class="card">
        <img src="logos/jfrog-logo.png" alt="JFrog" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">JFrog</div>
        <div class="csub">Artefactos · CI/CD</div>
      </div>
      <div class="card">
        <img src="logos/Coupa_Logo.webp" alt="Coupa" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">Coupa</div>
        <div class="csub">Procurement SaaS · talleres · proveedores</div>
      </div>
    </div>
  </div>

  <!-- ── DATOS ─────────────────────────────────────────────── -->
  <div class="layer data">
    <div class="layer-head">&#128202; Datos &amp; Analítica</div>
    <div class="layer-body">
      <div class="card" style="max-width:200px">
        <img src="logos/Oracle_logo.svg.webp" alt="Oracle" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">Oracle DB Corporativo</div>
        <div class="csub">Golden record · clientes · pólizas · finanzas</div>
        <span class="ctag gap">Sin MDM entre instancias</span>
      </div>
      <div class="card">
        <img src="logos/Oracle_logo.svg.webp" alt="Oracle" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">Oracle DB × 3</div>
        <div class="csub">Instancias: Daños · Salud · Autos</div>
      </div>
      <div class="card" style="max-width:200px">
        <img src="logos/Azure_Logo.webp" alt="Azure" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">Azure ADF + ADL + Databricks</div>
        <div class="csub">Data platform TO BE · ETL · repositorio · ML</div>
        <span class="ctag impl">EN MIGRACIÓN</span>
      </div>
      <div class="card">
        <img src="logos/MySQL-logo.png" alt="MySQL" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">MySQL Data Hub + Pentaho</div>
        <div class="csub">Data Hub legado AS IS</div>
        <span class="ctag dep">EN DECOMMISSION</span>
      </div>
      <div class="card">
        <img src="logos/power-bi-logo.png" alt="Power BI" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">Power BI</div>
        <div class="csub">BI · siniestralidad · primas · reporting</div>
      </div>
    </div>
  </div>

  <!-- ── EMPRESARIAL ───────────────────────────────────────── -->
  <div class="layer ent">
    <div class="layer-head">&#127970; Plataforma Empresarial &amp; Cloud</div>
    <div class="layer-body">
      <div class="card">
        <img src="logos/SAP_logo.webp" alt="SAP" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">SAP ECC v8</div>
        <div class="csub">Finanzas FICO · RRHH · consolidación Grupo AXA</div>
      </div>
      <div class="card">
        <img src="logos/ServiceNow_logo.svg.webp" alt="ServiceNow" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">ServiceNow</div>
        <div class="csub">ITSM corporativo</div>
      </div>
      <div class="card" style="max-width:220px">
        <img src="logos/Azure_Logo.webp" alt="Azure" height="28" style="max-height:28px;width:auto;max-width:120px">
        <div class="cname">Azure (stack completo)</div>
        <div class="csub">AD/Entra · APIM · Service Bus · Key Vault · Sentinel · AI Foundry/OpenAI</div>
      </div>
      <div class="card" style="max-width:200px">
        <img src="logos/Axa_logo.png" alt="AXA" height="28" style="max-height:28px;width:auto;max-width:120px"><div class="logo-placeholder" style="display:none">IAM</div>
        <div class="cname">One Account + Ping + LISA</div>
        <div class="csub">IAM B2C+B2B → Azure AD · IGA global</div>
        <span class="ctag impl">EN MIGRACIÓN (desde LDAP)</span>
      </div>
    </div>
  </div>

  <!-- ── CAPA AGÉNTICA ─────────────────────────────────────── -->
  <div class="layer agent">
    <div class="layer-head">&#129302; Capa Agéntica (Piloto Activo · Azure AI Foundry / OpenAI)</div>
    <div class="layer-body">
      <div class="agent-flow">
        <div class="agent-card">
          <div class="aname">Triggers</div>
          <div class="asub">My AXA · axa.mx · ATC Plus · AXA Keralty · B2B externos</div>
        </div>
        <div class="agent-arrow">→</div>
        <div class="agent-card">
          <div class="aname">Orquestador</div>
          <div class="asub">Gestiona estado · decide siguiente paso · coordina flujo</div>
        </div>
        <div class="agent-arrow">→</div>
        <div class="agent-card">
          <div class="aname">Agente 1</div>
          <div class="asub">Validación de acceso · identidad · permisos</div>
        </div>
        <div class="agent-arrow">→</div>
        <div class="agent-card">
          <div class="aname">Agente 2</div>
          <div class="asub">Verificación de condiciones · línea / producto</div>
        </div>
        <div class="agent-arrow">→</div>
        <div class="agent-card">
          <div class="aname">Agente 3</div>
          <div class="asub">Cálculo financiero · primas · reservas · indemnización</div>
        </div>
        <div class="agent-arrow">→</div>
        <div class="agent-card">
          <div class="aname">Agente 4</div>
          <div class="asub">Validación clínica/técnica · salud · siniestros</div>
        </div>
        <div class="agent-arrow">→</div>
        <div class="agent-card" style="background:rgba(255,23,33,.14);border-color:rgba(255,23,33,.35)">
          <div class="aname" style="color:#ff6677">LLM Generativo</div>
          <div class="asub" style="color:#cc5566">Azure AI Foundry / OpenAI · nota de resolución · comunicación multicanal</div>
        </div>
      </div>
    </div>
  </div>

  <!-- ── Leyenda ───────────────────────────────────────────── -->
  <div class="legend">
    <span><span class="dot" style="background:rgba(255,23,33,.6)"></span>Gap crítico documentado</span>
    <span><span class="dot" style="background:rgba(59,130,246,.6)"></span>En implementación / migración</span>
    <span><span class="dot" style="background:rgba(100,116,139,.6)"></span>En decommission</span>
    <span><span class="dot" style="background:rgba(255,165,0,.6)"></span>Piloto activo</span>
  </div>

</div><!-- /arch -->

<footer>
  Digital Brain &middot; Mapa de Arquitectura Tecnológica &middot; AXA México &middot;
  Fuente: TOGAF PDF Fases A&ndash;H + Competitive Discovery Suscripción Daños &middot; datos reales
</footer>

</body>
</html>
"""

OUT_HTML.parent.mkdir(parents=True, exist_ok=True)
OUT_HTML.write_text(HTML, encoding="utf-8")
print(f"[ok] {OUT_HTML.name}  ({OUT_HTML.stat().st_size:,} bytes)")