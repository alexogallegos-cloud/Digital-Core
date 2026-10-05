"""
build-showcase-intencion.py — Genera portal/showcase-intencion.html
REAL DATA — Capa 4 · Intención del Proceso — AXA México Suscripción Daños (Property).
Swimlane journey del proceso AS-IS con sistemas involucrados y gaps críticos.
Fuente: Competitive Discovery Suscripción Daños.xlsx (entregable real de engagement AXA).
"""
import pathlib

ROOT     = pathlib.Path(__file__).parent.parent
OUT_HTML = ROOT / "portal" / "showcase-intencion.html"
LOGO_SRC = ROOT.parent / "design-studio" / "logos" / "Axa_logo.png"

html = r"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Digital Brain · Intención del Proceso — AXA Suscripción Daños</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
:root{
  --bg:#08091a;--card:rgba(255,255,255,.04);--border:rgba(255,255,255,.08);
  --blue:#00008F;--red:#FF1721;--muted:rgba(255,255,255,.45);
  --c-vector:#3355FF;--c-sinco:#00AA77;--c-hsd:#FF1721;--c-ern:#9933CC;
  --c-safac:#FF6600;--c-gd:#2277DD;--c-pbi:#F2B400;--c-mon:#999;
  --c-manual:#555;--c-pegaso:#44AADD;--c-citrix:#777;
}
body{background:var(--bg);color:#fff;font-family:'Segoe UI',system-ui,sans-serif;min-height:100vh}

/* ── Nav ────────────────────────────────────────────────────────────── */
nav{position:fixed;top:0;left:0;right:0;z-index:100;
  background:rgba(8,9,26,.92);backdrop-filter:blur(18px);
  border-bottom:1px solid var(--border);
  display:flex;align-items:center;justify-content:space-between;padding:0 24px;height:56px}
.nav-logo{height:26px;object-fit:contain}
.nav-center{font-size:14px;font-weight:700;letter-spacing:-.01em}
.nav-badge{font-size:9px;font-weight:800;letter-spacing:.08em;padding:3px 8px;
  border-radius:10px;color:#fff;background:var(--blue);margin-left:10px}
.nav-back{font-size:12px;color:var(--muted);text-decoration:none;
  display:flex;align-items:center;gap:6px;transition:color .2s}
.nav-back:hover{color:#fff}

/* ── Page ───────────────────────────────────────────────────────────── */
.page{padding:80px 22px 60px}

/* ── Hero ───────────────────────────────────────────────────────────── */
.hero{max-width:1300px;margin:0 auto 38px}
.hero-tag{display:inline-flex;align-items:center;gap:8px;font-size:11px;font-weight:700;
  letter-spacing:.07em;text-transform:uppercase;color:#6699ff;margin-bottom:14px}
.hero-tag::before{content:'';width:24px;height:2px;background:var(--blue);border-radius:2px}
h1{font-size:clamp(22px,3vw,34px);font-weight:900;letter-spacing:-.03em;line-height:1.15;margin-bottom:10px}
h1 span{color:var(--red)}
.hero-sub{font-size:14px;color:var(--muted);line-height:1.65;max-width:760px}

/* ── Data badge ─────────────────────────────────────────────────────── */
.data-badge{display:inline-flex;align-items:center;gap:8px;margin-top:14px;
  background:rgba(0,0,143,.12);border:1px solid rgba(0,0,143,.35);
  border-radius:8px;padding:7px 14px;font-size:12px;color:#aabbff}
.data-badge strong{color:#fff}

/* ── Stats row ─────────────────────────────────────────────────────── */
.stats{display:flex;gap:16px;flex-wrap:wrap;max-width:1300px;margin:0 auto 32px}
.stat{background:var(--card);border:1px solid var(--border);border-radius:14px;
  padding:16px 22px;flex:1;min-width:120px}
.stat-n{font-size:28px;font-weight:900;letter-spacing:-.04em}
.stat-l{font-size:11px;color:var(--muted);margin-top:3px}

/* ── Swimlane ───────────────────────────────────────────────────────── */
.swimlane-wrap{max-width:1300px;margin:0 auto 36px;overflow-x:auto}
.swimlane{min-width:900px}
.sl-phases{display:grid;grid-template-columns:120px repeat(5,1fr);gap:2px;margin-bottom:2px}
.sl-ph{background:rgba(0,0,143,.22);border:1px solid rgba(0,0,143,.4);
  border-radius:8px 8px 0 0;padding:10px 12px;text-align:center}
.sl-ph-n{font-size:9px;font-weight:700;letter-spacing:.08em;color:#7799ff;text-transform:uppercase}
.sl-ph-t{font-size:13px;font-weight:800;margin-top:3px}
.sl-ph-sub{font-size:10px;color:var(--muted);margin-top:2px}
.sl-lane-label{display:flex;align-items:center;justify-content:center;
  background:rgba(255,255,255,.04);border:1px solid var(--border);border-radius:8px;
  padding:8px 10px;font-size:11px;font-weight:700;letter-spacing:.04em;text-align:center;
  writing-mode:vertical-rl;text-orientation:mixed;min-height:100px}
.sl-row{display:grid;grid-template-columns:120px repeat(5,1fr);gap:2px;margin-bottom:2px}
.sl-cell{background:var(--card);border:1px solid var(--border);border-radius:0;
  padding:12px 10px;min-height:100px;position:relative}
.sl-cell.active{border-color:rgba(51,85,255,.3)}
.sl-cell.gap-cell{border-color:rgba(255,23,33,.25);background:rgba(255,23,33,.04)}
.sl-cell-empty{background:rgba(255,255,255,.01);border:1px solid rgba(255,255,255,.03)}
.sl-steps{font-size:11px;color:var(--muted);margin-bottom:8px}
.sl-steps strong{color:#fff;font-size:13px}
.sys-tags{display:flex;flex-wrap:wrap;gap:4px;margin-top:6px}
.sys-tag{display:inline-flex;align-items:center;gap:4px;font-size:10px;font-weight:700;
  padding:2px 7px;border-radius:8px;white-space:nowrap}
.sys-tag .dot{width:6px;height:6px;border-radius:50%;flex-shrink:0}
.gap-flag{display:inline-flex;align-items:center;gap:4px;font-size:9px;font-weight:800;
  letter-spacing:.04em;text-transform:uppercase;padding:2px 6px;border-radius:6px;
  background:rgba(255,23,33,.18);border:1px solid rgba(255,23,33,.4);color:#ff6677;
  margin-top:5px}

/* ── System legend ──────────────────────────────────────────────────── */
.legend{max-width:1300px;margin:0 auto 36px;
  background:var(--card);border:1px solid var(--border);border-radius:14px;padding:20px 24px}
.legend-title{font-size:12px;font-weight:700;letter-spacing:.05em;text-transform:uppercase;
  color:var(--muted);margin-bottom:14px}
.legend-grid{display:flex;flex-wrap:wrap;gap:10px}
.leg-item{display:flex;align-items:center;gap:7px;font-size:12px}
.leg-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0}

/* ── Gaps section ───────────────────────────────────────────────────── */
.section-head{max-width:1300px;margin:0 auto 18px}
.section-head h2{font-size:20px;font-weight:800;letter-spacing:-.02em}
.section-head p{font-size:13px;color:var(--muted);margin-top:5px}
.gaps-grid{max-width:1300px;margin:0 auto 48px;
  display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:14px}
.gap-card{background:var(--card);border:1px solid rgba(255,23,33,.18);border-radius:14px;
  padding:18px 20px;transition:transform .3s,border-color .3s}
.gap-card:hover{transform:translateY(-3px);border-color:rgba(255,23,33,.4)}
.gap-cat{font-size:9px;font-weight:800;letter-spacing:.09em;text-transform:uppercase;
  color:#ff6677;margin-bottom:8px}
.gap-text{font-size:13px;line-height:1.6;color:rgba(255,255,255,.85)}
.gap-mejora{font-size:11px;color:#aabbff;margin-top:10px;padding-top:10px;
  border-top:1px solid rgba(255,255,255,.06);line-height:1.55}
.gap-mejora strong{color:#7799ff}

/* ── Footer ─────────────────────────────────────────────────────────── */
footer{text-align:center;font-size:11px;color:var(--muted);padding:24px;
  border-top:1px solid var(--border);margin-top:20px}
</style>
</head>
<body>
<nav>
  <img src="logos/Axa_logo.png" alt="AXA" class="nav-logo">
  <div>
    <span class="nav-center">Digital Brain &middot; Intención del Proceso</span>
    <span class="nav-badge">CAPA 4</span>
  </div>
  <a class="nav-back" href="index.html">&#8592; Portal</a>
</nav>

<div class="page">

  <!-- Hero -->
  <div class="hero">
    <div class="hero-tag">Capa 4 · Intención</div>
    <h1>Suscripción Daños<br><span>Property &amp; Casualty · Commercial Lines</span></h1>
    <p class="hero-sub">
      Proceso AS-IS de suscripción en AXA México: etapas, sistemas involucrados y gaps críticos de automatización.
      El Digital Brain mapea la <strong>intención</strong> de cada etapa — qué quiere lograr el negocio — y contrasta con
      las fricciones y herramientas fragmentadas del estado actual.
    </p>
    <div class="data-badge">
      <strong>Datos reales</strong> &mdash; Competitive Discovery Suscripción Daños &middot; AXA México &middot; Property Líneas Comerciales
    </div>
  </div>

  <!-- Stats -->
  <div class="stats">
    <div class="stat"><div class="stat-n" style="color:#3355FF">5</div><div class="stat-l">Fases del proceso<br>Suscripción</div></div>
    <div class="stat"><div class="stat-n" style="color:#3355FF">57</div><div class="stat-l">Pasos documentados<br>Suscripción Daños</div></div>
    <div class="stat"><div class="stat-n" style="color:#FF6600">4</div><div class="stat-l">Fases Reaseguro<br>Facultativo</div></div>
    <div class="stat"><div class="stat-n" style="color:#2277DD">4</div><div class="stat-l">Fases Emisión<br>pólizas y endosos</div></div>
    <div class="stat"><div class="stat-n" style="color:#FF1721">34</div><div class="stat-l">Gaps identificados<br>Suscripción / Property</div></div>
    <div class="stat"><div class="stat-n" style="color:#FF1721">7+</div><div class="stat-l">Sistemas críticos<br>sin integración nativa</div></div>
  </div>

  <!-- System Legend -->
  <div class="legend">
    <div class="legend-title">Sistemas involucrados</div>
    <div class="legend-grid">
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-vector)"></div><span><strong>Vector</strong> — Workflow suscripción (folio/expediente)</span></div>
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-sinco)"></div><span><strong>SINCO</strong> — Base de cuentas y antecedentes</span></div>
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-hsd)"></div><span><strong>HSD (Excel)</strong> — Hoja de Suscripción · gap de automatización</span></div>
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-ern)"></div><span><strong>ERN</strong> — Modelación catastrófica (PML, cúmulos)</span></div>
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-safac)"></div><span><strong>SAFAC</strong> — Reaseguro Facultativo y seriación</span></div>
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-gd)"></div><span><strong>General Daños / SED</strong> — Emisión de pólizas</span></div>
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-pbi)"></div><span><strong>Power BI</strong> — Siniestralidad e historial</span></div>
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-mon)"></div><span><strong>Monitor</strong> — Reportes / monitoreo de cartera</span></div>
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-pegaso)"></div><span><strong>Pegaso</strong> — Entrega del documento emitido</span></div>
      <div class="leg-item"><div class="leg-dot" style="background:var(--c-manual)"></div><span><strong>Correo / Manual</strong> — Canal no integrado (gap)</span></div>
    </div>
  </div>

  <!-- Swimlane -->
  <div class="swimlane-wrap">
    <div class="swimlane">

      <!-- Phase headers -->
      <div class="sl-phases">
        <div></div><!-- label column -->
        <div class="sl-ph">
          <div class="sl-ph-n">Fase 1</div>
          <div class="sl-ph-t">Preparación</div>
          <div class="sl-ph-sub">18 pasos</div>
        </div>
        <div class="sl-ph">
          <div class="sl-ph-n">Fase 2</div>
          <div class="sl-ph-t">Evaluación del riesgo</div>
          <div class="sl-ph-sub">14 pasos</div>
        </div>
        <div class="sl-ph">
          <div class="sl-ph-n">Fase 3</div>
          <div class="sl-ph-t">Definición cotización</div>
          <div class="sl-ph-sub">14 pasos</div>
        </div>
        <div class="sl-ph">
          <div class="sl-ph-n">Fase 4</div>
          <div class="sl-ph-t">Negociación</div>
          <div class="sl-ph-sub">5 pasos</div>
        </div>
        <div class="sl-ph">
          <div class="sl-ph-n">Fase 5</div>
          <div class="sl-ph-t">Transferencia Emisión</div>
          <div class="sl-ph-sub">6 pasos</div>
        </div>
      </div>

      <!-- Row 1: SUSCRIPCIÓN -->
      <div class="sl-row">
        <div class="sl-lane-label">SUSCRIPCIÓN</div>

        <!-- Fase 1: Preparación -->
        <div class="sl-cell active">
          <div class="sl-steps"><strong>4</strong> etapas</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
            <span class="sys-tag" style="background:rgba(0,170,119,.12);color:#55dd99"><span class="dot" style="background:var(--c-sinco)"></span>SINCO</span>
            <span class="sys-tag" style="background:rgba(242,180,0,.12);color:#ffcc44"><span class="dot" style="background:var(--c-pbi)"></span>Power BI</span>
            <span class="sys-tag" style="background:rgba(153,153,153,.1);color:#bbb"><span class="dot" style="background:var(--c-mon)"></span>Monitor</span>
          </div>
          <div class="gap-flag">&#9888; Canal: correo / WhatsApp</div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Recepción, identificación de cuenta, antecedentes de renovación, validación del expediente</div>
        </div>

        <!-- Fase 2: Evaluación -->
        <div class="sl-cell gap-cell">
          <div class="sl-steps"><strong>4</strong> etapas</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(255,23,33,.18);color:#ff8888"><span class="dot" style="background:var(--c-hsd)"></span>HSD (Excel)</span>
            <span class="sys-tag" style="background:rgba(153,51,204,.15);color:#cc77ff"><span class="dot" style="background:var(--c-ern)"></span>ERN</span>
          </div>
          <div class="gap-flag">&#9888; GAP CRÍTICO: Excel no integrado</div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Carga en HSD, cálculos técnicos, modelación catastrófica, validación reglas suscripción e ingeniería</div>
        </div>

        <!-- Fase 3: Cotización -->
        <div class="sl-cell gap-cell">
          <div class="sl-steps"><strong>3</strong> etapas</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(255,23,33,.18);color:#ff8888"><span class="dot" style="background:var(--c-hsd)"></span>HSD (Excel)</span>
            <span class="sys-tag" style="background:rgba(153,51,204,.15);color:#cc77ff"><span class="dot" style="background:var(--c-ern)"></span>ERN</span>
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
          </div>
          <div class="gap-flag">&#9888; Aprobación manual por correo</div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Definición de precio y condiciones, aprobación de facultamiento, confirmación de capacidad, elaboración de cotización</div>
        </div>

        <!-- Fase 4: Negociación -->
        <div class="sl-cell active">
          <div class="sl-steps"><strong>2</strong> etapas</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
            <span class="sys-tag" style="background:rgba(85,85,85,.2);color:#aaa"><span class="dot" style="background:var(--c-manual)"></span>Correo</span>
          </div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Envío de cotización, negociación con broker/cliente, confirmación de términos aceptados</div>
        </div>

        <!-- Fase 5: Transferencia -->
        <div class="sl-cell gap-cell">
          <div class="sl-steps"><strong>2</strong> etapas</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(255,23,33,.18);color:#ff8888"><span class="dot" style="background:var(--c-hsd)"></span>HSD (Excel)</span>
            <span class="sys-tag" style="background:rgba(34,119,221,.15);color:#77bbff"><span class="dot" style="background:var(--c-gd)"></span>SED</span>
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
          </div>
          <div class="gap-flag">&#9888; Recaptura manual HSD → SED</div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Precarga en SED, validación de información, integración del expediente de emisión</div>
        </div>
      </div>

      <!-- Row 2: REASEGURO FAC -->
      <div class="sl-row">
        <div class="sl-lane-label">REASEGURO FAC</div>

        <!-- Fase 1 -->
        <div class="sl-cell active">
          <div class="sl-steps"><strong>4</strong> etapas</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
            <span class="sys-tag" style="background:rgba(85,85,85,.2);color:#aaa"><span class="dot" style="background:var(--c-manual)"></span>Correo</span>
          </div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Recepción de solicitud FAC, validación de información mínima, estrategia de mercados</div>
        </div>

        <!-- Fase 2 -->
        <div class="sl-cell active">
          <div class="sl-steps"><strong>2</strong> etapas</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(85,85,85,.2);color:#aaa"><span class="dot" style="background:var(--c-manual)"></span>Correo</span>
          </div>
          <div class="gap-flag">&#9888; Colocación 100% por correo</div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Salida a mercados de Reaseguro, seguimiento y recepción de términos</div>
        </div>

        <!-- Fase 3 -->
        <div class="sl-cell active">
          <div class="sl-steps"><strong>4</strong> etapas</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(85,85,85,.2);color:#aaa"><span class="dot" style="background:var(--c-manual)"></span>Excel / Correo</span>
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
          </div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Comparación de términos, validación Security, integración estructura de colocación</div>
        </div>

        <!-- Fase 4 -->
        <div class="sl-cell active">
          <div class="sl-steps"><strong>4</strong> etapas</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(255,102,0,.15);color:#ffaa55"><span class="dot" style="background:var(--c-safac)"></span>SAFAC</span>
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
          </div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Negociación, recepción de orden en firme, autorización SAFAC, liberación para Emisión</div>
        </div>

        <!-- Fase 5 (admin post-emisión, no es fase de Transferencia) -->
        <div class="sl-cell gap-cell">
          <div class="sl-steps"><strong>4</strong> etapas · post-emisión</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(255,102,0,.15);color:#ffaa55"><span class="dot" style="background:var(--c-safac)"></span>SAFAC</span>
            <span class="sys-tag" style="background:rgba(85,85,85,.2);color:#aaa"><span class="dot" style="background:var(--c-manual)"></span>CIRCAM</span>
          </div>
          <div class="gap-flag">&#9888; SAFAC solo estructura lineal</div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Conciliación, distribución FAC, registro de cesión, gestión expediente regulatorio</div>
        </div>
      </div>

      <!-- Row 3: EMISIÓN -->
      <div class="sl-row">
        <div class="sl-lane-label">EMISIÓN</div>

        <!-- Fase 1: Recepción documental -->
        <div class="sl-cell active">
          <div class="sl-steps"><strong>4</strong> etapas · Recepción</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
            <span class="sys-tag" style="background:rgba(153,153,153,.1);color:#bbb"><span class="dot" style="background:var(--c-mon)"></span>Monitor</span>
          </div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Recepción del expediente, identificación del movimiento, revisión documental, gestión de faltantes</div>
        </div>

        <!-- Fase 2: Validación en sistemas -->
        <div class="sl-cell gap-cell">
          <div class="sl-steps"><strong>4</strong> etapas · Validación</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(34,119,221,.15);color:#77bbff"><span class="dot" style="background:var(--c-gd)"></span>General Daños</span>
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
            <span class="sys-tag" style="background:rgba(119,119,119,.15);color:#ccc"><span class="dot" style="background:var(--c-citrix)"></span>Citrix</span>
          </div>
          <div class="gap-flag">&#9888; Recaptura manual entre sistemas</div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Preparación de consulta, validación de datos generales, coberturas y comisiones, gestión de diferencias</div>
        </div>

        <!-- Fase 3: Generación -->
        <div class="sl-cell active">
          <div class="sl-steps"><strong>4</strong> etapas · Generación</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(34,119,221,.15);color:#77bbff"><span class="dot" style="background:var(--c-gd)"></span>General Daños</span>
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
          </div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Preparación de captura, captura / actualización del movimiento, registro de soportes, generación de la póliza o endoso</div>
        </div>

        <!-- Fase 4: Entrega -->
        <div class="sl-cell active">
          <div class="sl-steps"><strong>2</strong> etapas · Entrega</div>
          <div class="sys-tags">
            <span class="sys-tag" style="background:rgba(68,170,221,.15);color:#99ddff"><span class="dot" style="background:var(--c-pegaso)"></span>Pegaso</span>
            <span class="sys-tag" style="background:rgba(34,119,221,.15);color:#77bbff"><span class="dot" style="background:var(--c-gd)"></span>General Daños</span>
            <span class="sys-tag" style="background:rgba(51,85,255,.15);color:#7799ff"><span class="dot" style="background:var(--c-vector)"></span>Vector</span>
          </div>
          <div style="font-size:10px;color:var(--muted);margin-top:7px;line-height:1.5">Impresión o envío de póliza, registro y cierre del folio en Vector</div>
        </div>

        <!-- Filler -->
        <div class="sl-cell-empty"></div>
      </div>

    </div><!-- /swimlane -->
  </div><!-- /swimlane-wrap -->

  <!-- Gaps section -->
  <div class="section-head">
    <h2>Gaps críticos identificados</h2>
    <p>Fricciones documentadas en el proceso AS-IS — Suscripción y Línea Property</p>
  </div>

  <div class="gaps-grid">

    <div class="gap-card">
      <div class="gap-cat">Información dispersa · Canales múltiples</div>
      <div class="gap-text">El suscriptor debe revisar y reconciliar solicitudes, seguimientos y negociaciones distribuidos entre Vector, correo electrónico y otros canales porque el sistema no unifica estas interacciones.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Incorporar al registro del caso la información relevante generada en otros canales (correo, Teams). Seguimiento y visibilidad del estado del caso en un punto único.</div>
    </div>

    <div class="gap-card">
      <div class="gap-cat">HSD Excel · Gap de automatización crítico</div>
      <div class="gap-text">La Hoja de Suscripción de Daños (HSD) es una herramienta Excel que concentra el cálculo técnico del riesgo. El suscriptor debe volver a capturar en HSD información que ya está disponible en el slip y en el expediente de Vector.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Permitir reutilizar directamente en HSD la información ya disponible en el expediente de Vector. Integración automática o API entre Vector y la herramienta de cálculo.</div>
    </div>

    <div class="gap-card">
      <div class="gap-cat">ERN sin integración con HSD</div>
      <div class="gap-text">El suscriptor debe trasladar manualmente los resultados de modelación catastrófica de ERN a la HSD porque las herramientas no intercambian datos automáticamente.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Permitir que los resultados de ERN (PML, cúmulos, participación preliminar) puedan utilizarse directamente en HSD sin recaptura manual.</div>
    </div>

    <div class="gap-card">
      <div class="gap-cat">SINCO · Identificador de cliente no confiable</div>
      <div class="gap-text">El suscriptor debe realizar búsquedas con distintas variantes de razón social y dirección porque diferencias de escritura entre registros impiden identificar de forma confiable si es el mismo cliente.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Permitir buscar y relacionar registros mediante un identificador confiable de cliente (RFC, CURP u otro estándar), no solo por razón social o dirección.</div>
    </div>

    <div class="gap-card">
      <div class="gap-cat">Validaciones manuales de facultamiento</div>
      <div class="gap-text">Las asignaciones de aprobaciones dependiendo del facultamiento del suscriptor se realizan de manera manual, generando retrasos y riesgo de omisión en los niveles de autorización requeridos.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Identificar automáticamente cuándo se necesita una aprobación y dirigir el caso al nivel de autorización correspondiente según las reglas de facultamiento.</div>
    </div>

    <div class="gap-card">
      <div class="gap-cat">Siniestralidad fragmentada</div>
      <div class="gap-text">El suscriptor debe consultar y descargar por separado la siniestralidad de cada póliza, vigencia y antecedentes del cliente, cruzando múltiples sistemas (Power BI, SINCO, Vector) sin una vista unificada.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Dar acceso a una vista consolidada de la siniestralidad e historial de la cuenta en el expediente del caso, sin necesidad de consultar cada sistema por separado.</div>
    </div>

    <div class="gap-card">
      <div class="gap-cat">Recaptura Vector ↔ Sistemas operativos</div>
      <div class="gap-text">El responsable debe recapturar o trasladar manualmente información entre Vector y los sistemas operativos (General Daños, SED, SAFAC) porque las herramientas no intercambian datos automáticamente.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Permitir que los datos necesarios pasen entre Vector y los sistemas operativos sin intervención manual.</div>
    </div>

    <div class="gap-card">
      <div class="gap-cat">SAFAC · Estructura solo lineal</div>
      <div class="gap-text">SAFAC solo permite estructuras de colocación lineales. Reaseguro Facultativo no puede cargar masivamente capas ni múltiples reaseguradores, lo que obliga a trabajo manual en estructuras complejas.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Ampliar SAFAC para soportar estructuras por capas y carga masiva de participantes. Validación automática de consistencia entre condiciones de directo y respaldo FAC.</div>
    </div>

    <div class="gap-card">
      <div class="gap-cat">Retrabajo por cambios en negociación</div>
      <div class="gap-text">Cuando cambia una condición negociada, el suscriptor debe identificar y repetir manualmente los cálculos, validaciones y documentos afectados porque el cambio no se propaga automáticamente a las herramientas relacionadas.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Permitir que un cambio de condición se refleje automáticamente en los cálculos y registros relacionados (HSD, cotización, SAFAC) sin rehacer cada componente por separado.</div>
    </div>

    <div class="gap-card">
      <div class="gap-cat">Visibilidad de gestiones pendientes</div>
      <div class="gap-text">No existe una vista única del estado de las gestiones con otras áreas, terceros y distribuidores, por lo que el seguimiento depende de recordar o rastrear correos y llamadas telefónicas.</div>
      <div class="gap-mejora"><strong>Mejora tecnológica:</strong> Dar visibilidad en un mismo punto al estado actualizado de las gestiones pendientes internas y externas relacionadas con el caso.</div>
    </div>

  </div>

</div><!-- /page -->

<footer>
  Intención del proceso · 5 fases suscripción · 57 pasos documentados · 34 gaps identificados &middot;
  Digital Brain · Capa 4 · AXA Insurance P&amp;C · Suscripción Daños Commercial Lines &middot;
  Datos reales Competitive Discovery
</footer>
</body>
</html>
"""

OUT_HTML.parent.mkdir(parents=True, exist_ok=True)
OUT_HTML.write_text(html, encoding="utf-8")

import shutil
if LOGO_SRC.exists():
    (ROOT / "portal" / "logos").mkdir(parents=True, exist_ok=True)
    shutil.copy2(LOGO_SRC, ROOT / "portal" / "logos" / "Axa_logo.png")

print(f"[ok] {OUT_HTML.name}  ({OUT_HTML.stat().st_size:,} bytes)")
