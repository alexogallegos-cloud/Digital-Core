#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
build-equipo.py — Genera portal/equipo-y-gantt.html desde lab-brain.db.

Contiene: Gantt ejecutivo con ruta crítica e hitos, matriz RACI, organigrama
del equipo y tablas de perfiles IMS.

El HTML no se edita a mano. Para cambiar el equipo o el calendario se cambia el
dato en build-brain.py, se reconstruye el brain y se vuelve a correr esto.

Paleta Banamex del Design Studio. Señal #EE3124 reservada a la barra de 3px,
los rombos de hito y los numerales, segun design-system.md.
"""
import datetime as dt
import html
import io
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE / "digital-brain"))

from brain import LabBrain  # noqa: E402

OUT = BASE / "portal" / "equipo-y-gantt.html"

ANCLA = "#004785"
PAPEL = "#FFFFFF"
PLANO = "#EEF3F9"
TRAZO = "#D6D7D6"
SENAL = "#EE3124"
TINTA = "#1A1A1A"
TENUE = "#5A6B7C"
APOYO = "#00BDF2"   # apoyo digital Banamex, solo para la viz del Gantt

HOY = dt.date.today()
MESES = ("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
         "agosto", "septiembre", "octubre", "noviembre", "diciembre")
MES_CORTO = ("ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL",
             "AGO", "SEP", "OCT", "NOV", "DIC")

# Ventana del Gantt: arranque del Anexo hasta el cierre indicativo de la Fase 4.
T0 = dt.date(2026, 10, 12)      # lunes
T1 = dt.date(2027, 1, 11)       # lunes. Ventana corta: la implementación es el foco
N_SEM = ((T1 - T0).days // 7) + 1


def e(x) -> str:
    return html.escape(str(x if x is not None else ""))


def fecha_larga(d: dt.date) -> str:
    return f"{d.day} de {MESES[d.month - 1]} de {d.year}"


def semana(d: dt.date) -> int:
    """Indice de semana (base 0) dentro de la ventana del Gantt."""
    return max(0, min(N_SEM - 1, (d - T0).days // 7))


def col(d: dt.date) -> int:
    """Columna CSS grid (base 1)."""
    return semana(d) + 1


CSS = f"""
*{{box-sizing:border-box;margin:0;padding:0}}
body{{font-family:Calibri,Arial,sans-serif;font-weight:300;color:{TINTA};
     background:{PAPEL};line-height:1.55;font-size:15px}}
.wrap{{max-width:1240px;margin:0 auto;padding:0 32px}}
b,strong,th{{font-weight:700}}

.ancla{{background:{ANCLA};color:{PAPEL};position:relative}}
.ancla::before{{content:"";position:absolute;top:0;left:0;right:0;height:3px;background:{SENAL}}}
.ancla *{{color:{PAPEL}}}
.eyebrow{{color:{SENAL};text-transform:uppercase;letter-spacing:.14em;font-size:11px;font-weight:700}}
.hero{{padding:46px 0 40px}}
.hero h1{{font-size:34px;font-weight:700;line-height:1.15;margin:12px 0 10px}}
.hero .sub{{font-size:16px;max-width:820px}}
.hero .meta{{display:flex;flex-wrap:wrap;gap:40px;margin-top:30px;padding-top:24px;
            border-top:1px solid rgba(255,255,255,.22)}}
.hero .meta .k{{font-size:11px;text-transform:uppercase;letter-spacing:.1em;
               color:{SENAL};font-weight:700}}
.hero .meta .v{{font-size:21px;font-weight:700;margin-top:4px}}
.hero .meta .n{{font-size:12px}}

.interno{{background:{PLANO};border-bottom:1px solid {TRAZO};padding:11px 0;font-size:13px}}
.interno b{{color:{ANCLA}}}

section{{padding:44px 0;border-bottom:1px solid {TRAZO}}}
section:last-of-type{{border-bottom:0}}
h2{{font-size:25px;font-weight:700;color:{ANCLA};margin-bottom:6px}}
h2 .num{{font-weight:700;color:{TRAZO};margin-right:12px}}
.lead{{font-size:15px;color:{TENUE};max-width:880px;margin-bottom:24px}}
h3{{font-size:17px;font-weight:700;color:{ANCLA};margin:28px 0 10px}}
p{{margin-bottom:12px;max-width:920px}}

/* ---------------- Gantt ---------------- */
.gantt{{border:1px solid {TRAZO};background:{PAPEL};overflow:hidden}}
.gfila{{display:grid;grid-template-columns:272px 1fr;align-items:stretch;
       border-bottom:1px solid {TRAZO}}}
.gfila:last-child{{border-bottom:0}}
.getiq{{padding:9px 12px;border-right:1px solid {TRAZO};font-size:13.5px;
       display:flex;flex-direction:column;justify-content:center}}
.getiq .n{{font-weight:700;color:{ANCLA}}}
.getiq .f{{font-size:11.5px;color:{TENUE}}}
.gpista{{position:relative;display:grid;grid-template-columns:repeat({N_SEM},1fr);grid-auto-rows:minmax(34px,auto);
        background:repeating-linear-gradient(to right,{PLANO} 0 1px,transparent 1px 100%);
        background-size:calc(100% / {N_SEM}) 100%}}
.gcab{{background:{ANCLA}}}
.gcab .getiq{{border-right-color:rgba(255,255,255,.3)}}
.gcab .getiq .n{{color:{PAPEL}}}
.gmes,.gsem{{display:grid;grid-template-columns:repeat({N_SEM},1fr)}}
.gmes div{{color:{PAPEL};font-size:11px;font-weight:700;text-align:center;
          padding:5px 0 2px;letter-spacing:.08em;
          border-left:1px solid rgba(255,255,255,.25)}}
.gsem div{{color:{PAPEL};font-size:9.5px;text-align:center;padding:0 0 5px;
          border-left:1px solid rgba(255,255,255,.14)}}
.barra{{grid-row:1;height:22px;align-self:center;display:flex;align-items:center;
       padding:0 9px;font-size:11.5px;font-weight:700;color:{PAPEL};
       white-space:nowrap;overflow:hidden}}
.b-crit{{background:{ANCLA}}}
.b-norm{{background:{APOYO};color:{TINTA}}}
.b-op{{background:{PLANO};color:{ANCLA};border:1px solid {TRAZO}}}
.hitofila{{background:{PLANO}}}
.hito{{grid-row:1;align-self:center;position:relative;height:30px}}
.rombo{{position:absolute;top:7px;width:13px;height:13px;background:{SENAL};
       transform:translateX(-50%) rotate(45deg)}}
.hcod{{position:absolute;top:-3px;transform:translateX(-50%);
      font-size:9px;font-weight:700;color:{ANCLA}}}
.banda{{position:absolute;top:0;bottom:0;background:rgba(0,71,133,.055);
       border-left:1px solid {ANCLA};border-right:1px solid {ANCLA};z-index:0;pointer-events:none}}
.banda-t{{position:absolute;bottom:1px;font-size:9.5px;font-weight:700;color:{ANCLA};
         letter-spacing:.06em;white-space:nowrap}}
.sigue{{position:relative}}
.sigue::after{{content:"";position:absolute;right:-1px;top:0;bottom:0;width:14px;
              background:linear-gradient(to right,transparent,{PAPEL})}}
.hoy{{position:absolute;top:0;bottom:0;width:2px;background:{SENAL};z-index:3}}
.leyenda{{display:flex;flex-wrap:wrap;gap:22px;margin-top:14px;font-size:12.5px;color:{TENUE}}}
.leyenda i{{display:inline-block;width:22px;height:11px;margin-right:7px;
           vertical-align:middle;font-style:normal}}

/* ---------------- tablero de 4 semanas ---------------- */
.sem{{border:1px solid {TRAZO};margin-bottom:16px}}
.sem-h{{background:{ANCLA};color:{PAPEL};padding:11px 16px;position:relative;
       display:flex;justify-content:space-between;align-items:baseline;gap:16px}}
.sem-h::before{{content:"";position:absolute;top:0;left:0;right:0;height:3px;background:{SENAL}}}
.sem-h .n{{font-weight:700;font-size:17px}}
.sem-h .f{{font-size:12.5px}}
.sem-h .c{{font-size:11px;letter-spacing:.08em;text-transform:uppercase;color:{SENAL};
          font-weight:700;white-space:nowrap}}
.sem-foco{{padding:11px 16px;background:{PLANO};font-size:14px;border-bottom:1px solid {TRAZO}}}
.sem-foco .rg{{font-size:13px;color:{TENUE};margin-top:5px}}
.sem table{{margin:0}}
.sem td.crit{{font-weight:700;color:{ANCLA}}}
.transcurrida .sem-h{{background:{TENUE}}}

/* ---------------- tablas ---------------- */
table{{width:100%;border-collapse:collapse;margin:14px 0;font-size:13.5px}}
th{{background:{ANCLA};color:{PAPEL};text-align:left;padding:8px 10px;
   font-size:11.5px;text-transform:uppercase;letter-spacing:.05em}}
td{{padding:8px 10px;border-bottom:1px solid {TRAZO};vertical-align:top}}
tr:last-child td{{border-bottom:0}}
tbody tr:nth-child(even){{background:{PLANO}}}
td.id{{font-weight:700;color:{ANCLA};white-space:nowrap}}
td.num{{text-align:right;white-space:nowrap}}
td.c{{text-align:center}}
.ind{{font-weight:700;padding-bottom:1px;white-space:nowrap}}
.ind-si{{border-bottom:1.5px solid {ANCLA};color:{ANCLA}}}
.ind-no{{border-bottom:1.5px solid {TRAZO};color:{TENUE}}}

/* RACI */
.raci td.c{{font-weight:700;font-size:14px}}
.raci .A{{color:{ANCLA};border-bottom:1.5px solid {ANCLA}}}
.raci .R{{color:{ANCLA}}}
.raci .C{{color:{TENUE}}}
.raci .I{{color:{TRAZO}}}
.raci th.rot{{font-size:10.5px;letter-spacing:0;text-transform:none;
             text-align:center;padding:8px 3px;line-height:1.2}}

/* ---------------- organigrama ---------------- */
.org{{margin-top:20px;overflow-x:auto;padding-bottom:8px}}
.org ul{{display:flex;justify-content:center;padding-top:22px;position:relative;
        list-style:none;gap:14px}}
.org li{{list-style:none;position:relative;padding:22px 7px 0;text-align:center}}
.org ul ul::before{{content:"";position:absolute;top:0;left:50%;width:1px;height:22px;
                   background:{TRAZO}}}
.org li::before,.org li::after{{content:"";position:absolute;top:0;right:50%;
                               width:50%;height:22px;border-top:1px solid {TRAZO}}}
.org li::after{{right:auto;left:50%;border-left:1px solid {TRAZO}}}
.org li:only-child::before,.org li:only-child::after{{display:none}}
.org li:only-child{{padding-top:22px}}
.org li:first-child::before,.org li:last-child::after{{border:0}}
.org li:last-child::before{{border-right:1px solid {TRAZO}}}
.caja{{display:inline-block;min-width:168px;max-width:205px;padding:9px 11px;
      border:1px solid {TRAZO};background:{PLANO};text-align:left}}
.caja.gob{{background:{ANCLA};border-color:{ANCLA}}}
.caja.gob .r,.caja.gob .m{{color:{PAPEL}}}
.caja .r{{font-weight:700;font-size:12.5px;color:{ANCLA};line-height:1.25}}
.caja .m{{font-size:10.5px;color:{TENUE};margin-top:3px}}
.org .raiz{{padding-top:0}}
.org .raiz::before,.org .raiz::after{{display:none}}

.grid{{display:grid;gap:16px;margin-top:18px}}
.g3{{grid-template-columns:repeat(3,1fr)}}
.g4{{grid-template-columns:repeat(4,1fr)}}
.card{{background:{PLANO};border:1px solid {TRAZO};padding:16px 18px}}
.card .t{{font-weight:700;color:{ANCLA};font-size:22px}}
.card .d{{font-size:13px;color:{TINTA};margin-top:4px}}

.aviso{{border-left:3px solid {ANCLA};padding:10px 0 10px 18px;margin:18px 0;
       font-size:14.5px;max-width:920px;background:{PLANO};padding-right:16px}}

footer{{background:{ANCLA};color:{PAPEL};padding:28px 0;font-size:13px;position:relative}}
footer::before{{content:"";position:absolute;top:0;left:0;right:0;height:3px;background:{SENAL}}}
footer *{{color:{PAPEL}}}
footer .marca{{font-weight:700;font-size:16px}}

@media print{{section{{page-break-inside:avoid}}body{{font-size:10.5pt}}}}
"""


def marca_hoy() -> str:
    """Linea vertical en la semana en curso. T0 es lunes, asi que cae al centro."""
    if not (T0 <= HOY <= T1 + dt.timedelta(days=6)):
        return ""
    pct = (semana(HOY) + 0.5) * 100.0 / N_SEM
    return f"<div class='hoy' style='left:{pct:.3f}%'></div>"


def banda_implementacion(etiqueta: bool = False) -> str:
    """Resalta las 4 semanas de implementación sobre toda la altura de la pista."""
    ini, fin = dt.date(2026, 10, 12), dt.date(2026, 11, 6)
    izq = semana(ini) * 100.0 / N_SEM
    ancho = (semana(fin) - semana(ini) + 1) * 100.0 / N_SEM
    s = f"<div class='banda' style='left:{izq:.3f}%;width:{ancho:.3f}%'></div>"
    if etiqueta:
        s += (f"<div class='banda-t' style='left:{izq + 0.6:.3f}%'>"
              f"IMPLEMENTACIÓN, 4 SEMANAS</div>")
    return s


def cabecera_gantt(o):
    """Cabecera de meses y semanas sobre la ventana del Gantt."""
    o.append("<div class='gfila gcab'><div class='getiq'><div class='n'>Componente</div></div>")
    o.append("<div>")
    # meses
    o.append("<div class='gmes'>")
    i = 0
    while i < N_SEM:
        d = T0 + dt.timedelta(weeks=i)
        j = i
        while j + 1 < N_SEM and (T0 + dt.timedelta(weeks=j + 1)).month == d.month:
            j += 1
        pal = j - i + 1
        o.append(f"<div style='grid-column:span {pal}'>{MES_CORTO[d.month - 1]} {d.year % 100:02d}</div>")
        i = j + 1
    o.append("</div>")
    # semanas
    o.append("<div class='gsem'>")
    for i in range(N_SEM):
        o.append(f"<div>{(T0 + dt.timedelta(weeks=i)).day}</div>")
    o.append("</div>")
    o.append("</div></div>")


def render() -> str:
    b = LabBrain()
    try:
        o: list[str] = []
        w = o.append
        fte = b.fte()
        roles = b.roles()
        hitos = b.hitos()

        w("<!DOCTYPE html><html lang='es'><head><meta charset='utf-8'>")
        w("<meta name='viewport' content='width=device-width,initial-scale=1'>")
        w("<title>Laboratorio de Aceleración — Plan ejecutivo y equipo</title>")
        w(f"<style>{CSS}</style></head><body>")

        # ---------------- hero ----------------
        w("<div class='ancla'><div class='wrap hero'>")
        w("<div class='eyebrow'>Banamex, Change the Bank</div>")
        w("<h1>Laboratorio de Aceleración<br>Plan ejecutivo, ruta crítica y equipo</h1>")
        w("<div class='sub'>Calendario de los tres componentes del Anexo con sus hitos "
          "contractuales, la cadena que libera la cuota de arranque, el reparto de "
          "responsabilidades y el equipo requerido según los guidelines de Infrastructure "
          "Management Services.</div>")
        w("<div class='meta'>")
        w(f"<div><div class='k'>Equipo en setup</div><div class='v'>{fte['setup']:.2f} FTE</div>"
          f"<div class='n'>{len(roles)} perfiles</div></div>")
        w(f"<div><div class='k'>Equipo en operación</div><div class='v'>{fte['steady']:.2f} FTE</div>"
          f"<div class='n'>Estado estable</div></div>")
        w(f"<div><div class='k'>Ruta crítica</div><div class='v'>{len(b.ruta_critica())} pasos</div>"
          f"<div class='n'>Hacia la sesión que acredita los criterios</div></div>")
        w(f"<div><div class='k'>Hitos</div><div class='v'>{len(hitos)}</div>"
          f"<div class='n'>Dos de ellos con fecha dura</div></div>")
        w("</div></div></div>")

        w("<div class='interno'><div class='wrap'><b>Documento interno de delivery.</b> "
          "Los FTE son un patrón de referencia para dimensionar. El headcount formal lo calcula "
          "IMS Estimation y se formaliza en el SP-11. No contiene tarifas.</div></div>")

        # ---------------- 1. Gantt ----------------
        w("<section><div class='wrap'>")
        w("<h2><span class='num'>01</span>Gantt ejecutivo</h2>")
        w("<div class='lead'>Los tres componentes que reconoce la Cláusula Cuarta del Anexo, más el trabajo de apoyo que no está contratado y se marca como tal. Los rombos marcan los hitos.</div>")

        w("<div class='gantt'>")
        cabecera_gantt(o)

        # fila de hitos
        w("<div class='gfila hitofila'><div class='getiq'><div class='n'>Hitos</div>"
          "<div class='f'>Rombo en la semana del hito</div></div>")
        w("<div class='gpista'>")
        w(banda_implementacion(etiqueta=True))
        w(marca_hoy())
        porcol: dict[int, list] = {}
        for h in hitos:
            porcol.setdefault(col(dt.date.fromisoformat(h["fecha"])), []).append(h)
        for c, grupo in sorted(porcol.items()):
            n = len(grupo)
            for i, h in enumerate(grupo):
                pct = (i + 1) * 100.0 / (n + 1)   # reparte dentro de la celda, sin encimarse
                w(f"<div class='hito' style='grid-column:{c}' title='{e(h['nombre'])}'>"
                  f"<span class='hcod' style='left:{pct:.2f}%'>{e(h['id'])}</span>"
                  f"<span class='rombo' style='left:{pct:.2f}%'></span></div>")
        w("</div></div>")

        # filas de fase
        for f in b.fases():
            ini = dt.date.fromisoformat(f["inicio"])
            fin = dt.date.fromisoformat(f["fin"])
            rebasa = fin > T1
            c0, c1 = col(ini), col(fin)
            pal = max(1, c1 - c0 + 1)
            if f["id"] in ("OPE", "EXT"):
                cls = "b-op"
            elif f["critica"]:
                cls = "b-crit"
            else:
                cls = "b-norm"
            w(f"<div class='gfila'><div class='getiq'><div class='n'>{e(f['id'])} {e(f['nombre'])}</div>"
              f"<div class='f'>{e(f['clausula'])}</div></div>")
            if rebasa:
                etq = (f"{ini.day} {MES_CORTO[ini.month-1].lower()} {ini.year % 100}, "
                       "continúa hasta oct 2029")
                cls += " sigue"
            else:
                etq = (f"{ini.day} {MES_CORTO[ini.month-1].lower()} a "
                       f"{fin.day} {MES_CORTO[fin.month-1].lower()}")
            w("<div class='gpista'>")
            w(banda_implementacion())
            w(marca_hoy())
            w(f"<div class='barra {cls}' style='grid-column:{c0} / span {pal};z-index:1'>{etq}</div>")
            w("</div></div>")
        w("</div>")

        w("<div class='leyenda'>")
        w(f"<span><i style='background:{ANCLA}'></i>Componente en ruta crítica</span>")
        w(f"<span><i style='background:{PLANO};border:1px solid {TRAZO}'></i>"
          "Operación recurrente y trabajo de apoyo</span>")
        w(f"<span><i style='background:rgba(0,71,133,.12);border-left:1px solid {ANCLA};"
          f"border-right:1px solid {ANCLA}'></i>Ventana de implementación</span>")
        w(f"<span><i style='background:{SENAL};width:11px;height:11px;transform:rotate(45deg)'></i>Hito</span>")
        w(f"<span><i style='background:{SENAL};width:2px;height:14px'></i>Semana en curso</span>")
        w("</div>")

        w("<h3>Los hitos, uno por uno</h3>")
        w("<table><thead><tr><th>Hito</th><th>Fecha</th><th>Nombre</th><th>Tipo</th>"
          "<th>Qué significa</th></tr></thead><tbody>")
        for h in hitos:
            f = dt.date.fromisoformat(h["fecha"])
            w(f"<tr><td class='id'>{e(h['id'])}</td><td>{fecha_larga(f)}</td>"
              f"<td><b>{e(h['nombre'])}</b></td><td>{e(h['tipo'].capitalize())}</td>"
              f"<td>{e(h['nota'])}</td></tr>")
        w("</tbody></table>")
        w("</div></section>")

        # ---------------- 2. las cuatro semanas ----------------
        w(f"<section style='background:{PLANO}'><div class='wrap'>")
        w("<h2><span class='num'>02</span>Las cuatro semanas de implementación</h2>")
        w("<div class='lead'>La ventana de implementación es de cuatro semanas, del 12 de octubre "
          "al 6 de noviembre, con la entrega formal de los entregables 1 y 2 el 11 de noviembre. "
          "Es lo que cabe dentro del único plazo que el Anexo fija, que es el primer mes.</div>")
        criticas = {a["id"] for a in b.ruta_critica()}
        for sm in b.carga_semanal():
            ini = dt.date.fromisoformat(sm["inicio"])
            fin = dt.date.fromisoformat(sm["fin"])
            pasada = fin < HOY
            en_curso = ini <= HOY <= fin
            cls = "sem transcurrida" if pasada else "sem"
            w(f"<div class='{cls}'><div class='sem-h'>")
            w(f"<span class='n'>Semana {sm['num']}</span>")
            w(f"<span class='f'>{ini.day} de {MESES[ini.month-1]} al {fin.day} de "
              f"{MESES[fin.month-1]}</span>")
            w(f"<span class='c'>{sm['actividades']} actividades</span>")
            w("</div>")
            w(f"<div class='sem-foco'>{e(sm['foco'])}"
              f"<div class='rg'><b>Riesgo de la semana.</b> {e(sm['riesgo'])}</div></div>")
            w("<table><thead><tr><th>ID</th><th>Actividad</th><th>Entregable</th>"
              "<th>Ruta crítica</th></tr></thead><tbody>")
            for a in b.actividades_por_semana(sm["num"]):
                cr = a["id"] in criticas
                marca = "<span class='ind ind-si'>Sí</span>" if cr else ""
                clase = " class='crit'" if cr else ""
                w(f"<tr><td class='id'>{e(a['id'])}</td>"
                  f"<td{clase}>{e(a['actividad'])}</td>"
                  f"<td>{e(a['entregable'])}</td>"
                  f"<td>{marca}</td></tr>")
            w("</tbody></table></div>")
        w("<div class='aviso'><b>Lo que la compresión cuesta.</b> El diseño de solución planteaba "
          "una semana de habilitación y seis de activación. Al ajustar a cuatro semanas, la "
          "activación pasa de seis semanas a tres, y el punto que se vuelve crítico es la entrega "
          "de los contratos de interfaz por parte del banco: si no llegan en la semana 2, el core "
          "emulado no se puede construir en las semanas 3 y 4. Es justo donde el Digital Brain "
          "deja de ser un extra y se vuelve el camino: permite proponerle al banco contratos "
          "derivados de su propio código para que los apruebe, en lugar de esperar a que los "
          "redacte.</div>")
        w("</div></section>")

        # ---------------- 3. ruta critica ----------------
        w("<section><div class='wrap'>")
        w("<h2><span class='num'>03</span>La ruta crítica</h2>")
        w("<div class='lead'>Cadena que termina en la sesión en vivo donde usuarios de Banamex "
          "acreditan los cuatro criterios. Es lo único que vuelve exigible la cuota de arranque, "
          "y no se acredita con documentos.</div>")
        w("<table><thead><tr><th class='num'>Paso</th><th>ID</th><th>Fase</th><th>Actividad</th>"
          "<th>Entregable</th><th>Responsable</th></tr></thead><tbody>")
        dueno = {
            "ACT-01": "R05", "ACT-03": "R02", "ACT-04": "R03", "ACT-05": "R03",
            "ACT-08": "R05", "ACT-10": "R09", "ACT-12": "R06", "ACT-13": "R06",
            "ACT-14": "R05", "ACT-15": "R05", "ACT-17": "R09", "ACT-27": "R05",
            "ACT-29": "R02", "ACT-30": "R02",
        }
        for n, a in enumerate(b.ruta_critica(), 1):
            r = b.rol(dueno.get(a["id"], "R02"))
            w(f"<tr><td class='num'>{n}</td><td class='id'>{e(a['id'])}</td>"
              f"<td>{e(a['fase'])}</td><td>{e(a['actividad'])}</td>"
              f"<td>{e(a['entregable'])}</td><td>{e(r['rol'] if r else '')}</td></tr>")
        w("</tbody></table>")
        w("<div class='aviso'>Las tres primeras de la cadena no dependen de trabajo técnico "
          "nuestro. Dependen de una designación de usuarios, una agenda con Arquitectura y "
          "Seguridad, y tres decisiones de seguridad del banco. Es donde este tipo de arranque "
          "se atrasa, y el atraso no se recupera porque la fecha del primer mes es contractual.</div>")
        w("</div></section>")

        # ---------------- 4. RACI ----------------
        w(f"<section style='background:{PLANO}'><div class='wrap'>")
        w("<h2><span class='num'>04</span>Roles y responsabilidades</h2>")
        w("<div class='lead'>Un solo responsable último por entregable. A es quien responde, "
          "R quien ejecuta, C a quien se consulta e I a quien se informa.</div>")
        rr = b.roles_en_raci()
        m = b.raci_matriz()
        w("<table class='raci'><thead><tr><th>Entregable o compromiso</th>")
        for r in rr:
            w(f"<th class='rot' title='{e(r['rol'])}'>{e(r['id'])}<br>{e(r['nivel'])}</th>")
        w("</tr></thead><tbody>")
        for ent in b.entregables_raci():
            w(f"<tr><td><b>{e(ent)}</b></td>")
            for r in rr:
                L = m.get(ent, {}).get(r["id"], "")
                w(f"<td class='c'><span class='{L}'>{L}</span></td>" if L else "<td class='c'></td>")
            w("</tr>")
        w("</tbody></table>")
        w("<div class='leyenda'>")
        for r in rr:
            w(f"<span><b>{e(r['id'])}</b> {e(r['rol'])}</span>")
        w("</div>")
        w("</div></section>")

        # ---------------- 5. organigrama ----------------
        w("<section><div class='wrap'>")
        w("<h2><span class='num'>05</span>Organigrama del equipo</h2>")
        w("<div class='lead'>Estructura de reporte. Los niveles siguen el mapeo de bill codes a "
          "niveles de carrera del guideline de staffing de Infrastructure Management Services.</div>")

        def nodo(n, raiz=False):
            cls = "caja gob" if n["frente"] == "Gobierno" and n["nivel"] in ("L4", "L7") else "caja"
            li = "<li class='raiz'>" if raiz else "<li>"
            s = [li, f"<div class='{cls}'><div class='r'>{e(n['rol'])}</div>"
                     f"<div class='m'>{e(n['bc'])}, {e(n['nivel'])}, {e(n['tier'])}, "
                     f"{e(n['ubicacion'])}</div></div>"]
            if n["hijos"]:
                s.append("<ul>")
                for h in n["hijos"]:
                    s.append(nodo(h))
                s.append("</ul>")
            s.append("</li>")
            return "".join(s)

        w("<div class='org'><ul>")
        for r in b.organigrama():
            w(nodo(r, raiz=True))
        w("</ul></div>")
        w("</div></section>")

        # ---------------- 6. equipo detallado ----------------
        w(f"<section style='background:{PLANO}'><div class='wrap'>")
        w("<h2><span class='num'>06</span>Perfiles y dedicación</h2>")
        w("<div class='lead'>Patrón de referencia construido sobre el modelo de banca del "
          "guideline de staffing de Infrastructure Management Services, con los ajustes que sus "
          "propias tablas de riesgo exigen para este deal.</div>")
        w("<table><thead><tr><th>ID</th><th>Rol</th><th>BC</th><th>Nivel</th><th>Tier</th>"
          "<th>Ubicación</th><th>Frente</th><th class='num'>FTE setup</th>"
          "<th class='num'>FTE operación</th></tr></thead><tbody>")
        for r in roles:
            w(f"<tr><td class='id'>{e(r['id'])}</td><td><b>{e(r['rol'])}</b><br>"
              f"<span style='color:{TENUE};font-size:12.5px'>{e(r['responsabilidad'])}</span></td>"
              f"<td>{e(r['bc'])}</td><td>{e(r['nivel'])}</td><td>{e(r['tier'])}</td>"
              f"<td>{e(r['ubicacion'])}</td><td>{e(r['frente'])}</td>"
              f"<td class='num'>{r['fte_setup']:.2f}</td>"
              f"<td class='num'>{r['fte_steady']:.2f}</td></tr>")
        w(f"<tr><td></td><td><b>Total</b></td><td colspan='5'></td>"
          f"<td class='num'><b>{fte['setup']:.2f}</b></td>"
          f"<td class='num'><b>{fte['steady']:.2f}</b></td></tr>")
        w("</tbody></table>")

        w("<div class='grid g3'>")
        w(f"<div class='card'><div class='t'>{fte['setup']:.2f} a {fte['steady']:.2f}</div>"
          "<div class='d'>FTE de implementación a operación. El equipo se encoge 51 por ciento "
          "al pasar a régimen, porque construir pesa más que operar un laboratorio no "
          "productivo</div></div>")
        geo = {g["ubicacion"]: g["fte_steady"] for g in b.geografia()}
        pct_ns = 100 * geo.get("Nearshore", 0) / fte["steady"] if fte["steady"] else 0
        w(f"<div class='card'><div class='t'>{pct_ns:.0f} por ciento</div>"
          "<div class='d'>Del equipo en operación es nearshore México, lo que encaja con el "
          "horario de servicio de lunes a viernes de 9 a 18 horas</div></div>")
        w("<div class='card'><div class='t'>ITS_LT</div><div class='d'>Perfil económico que "
          "corresponde, porque los deals de servicios gestionados plurianuales son de largo "
          "plazo por definición</div></div>")
        w("</div>")

        w("<h3>Distribución por tier</h3>")
        w("<table><thead><tr><th>Tier</th><th class='num'>Perfiles</th>"
          "<th class='num'>FTE setup</th><th class='num'>FTE operación</th>"
          "<th>Qué contiene</th></tr></thead><tbody>")
        que = {
            "Gobierno": "Patrocinio ejecutivo y escalamiento final",
            "T3": "Arquitectura, diseño del SDLC agéntico y liderazgo de seguridad",
            "T2": "Ingeniería de plataforma, harness, datos sintéticos, identidad y FinOps",
            "T1": "Monitoreo y escalamiento según runbooks",
        }
        for t in b.piramide_tier():
            w(f"<tr><td class='id'>{e(t['tier'])}</td><td class='num'>{t['roles']}</td>"
              f"<td class='num'>{t['fte_setup']:.2f}</td><td class='num'>{t['fte_steady']:.2f}</td>"
              f"<td>{e(que.get(t['tier'], ''))}</td></tr>")
        w("</tbody></table>")

        w("<h3>Por qué este equipo es más chico que el patrón de banca</h3>")
        w("<p>El guideline de staffing parte de un modelo de banca productiva, y este laboratorio "
          "no lo es. No hay datos reales de clientes, no existe ruta al core real, la ventana de "
          "servicio es de lunes a viernes de 9 a 18 horas, el Anexo no menciona operación "
          "continua en ningún lugar, no hay recuperación ante desastres en el alcance, y las "
          "restauraciones de respaldo son de una a seis por trimestre, que es cadencia de prueba. "
          "Sus niveles de servicio son los de un ambiente de desarrollo, no los de uno "
          "productivo.</p>")
        w("<p>Eso cambia la forma del equipo, no solo su tamaño. Sale el turno de monitoreo "
          "continuo, porque no hay nada que vigilar fuera de la ventana. Sale el perfil de "
          "cumplimiento dedicado, porque sin datos reales ni reportes regulatorios originados "
          "en el laboratorio no hay superficie que atender. Sale el ingeniero de red como perfil "
          "propio, porque un entorno aislado con endpoints privados es trabajo de una sola vez. "
          "El liderazgo de seguridad baja de tier tres a tier dos. Y la arquitectura de "
          "infraestructura se absorbe entre el Solution Architect y el Cloud Engineer Senior.</p>")
        w("<p>En sentido contrario, un perfil sube: el ingeniero de plataforma que escribe las "
          "plantillas de Terraform pasa a dos dedicaciones completas en la implementación. Ahí "
          "está el producto, y además es el entregable 5 del Anexo, que es mensual.</p>")
        w("<h3>Los supuestos que sostienen este tamaño</h3>")
        w("<div class='lead'>Si alguno de estos cae, el equipo vuelve a crecer. El primero es el "
          "que más pesa y todavía no está confirmado por escrito.</div>")
        w("<table><thead><tr><th>ID</th><th>Supuesto</th><th>En qué se sostiene</th>"
          "<th>Si cae</th><th>Impacto</th><th>Estado</th></tr></thead><tbody>")
        for sp in b.supuestos():
            est = "ind-si" if sp["estado"].startswith("SOSTENIDO") else "ind-no"
            w(f"<tr><td class='id'>{e(sp['id'])}</td><td><b>{e(sp['supuesto'])}</b></td>"
              f"<td>{e(sp['sustento'])}</td><td>{e(sp['si_cae'])}</td>"
              f"<td class='num'>{e(sp['impacto_fte'])}</td>"
              f"<td><span class='ind {est}'>{e(sp['estado'].capitalize())}</span></td></tr>")
        w("</tbody></table>")
        w("<h3>Nota sobre el patrón de origen</h3>")
        w("<p>Dos ajustes del guideline sí se conservan, porque no dependen de que el ambiente "
          "sea productivo. El control de consumo entra desde el primer mes, ya que el servicio se "
          "cobra como porcentaje del consumo y quien vigila el consumo vigila el margen. Y la "
          "gestión de identidad se sostiene pese al recorte, porque la baja de persona atrasada "
          "que deje un acceso abierto es la pena de nivel A más fácil de incurrir de todo el "
          "Anexo.</p>")
        w("<div class='aviso'><b>Dos cosas que este documento no decide.</b> El headcount "
          "definitivo lo calcula IMS Estimation, no un patrón de referencia, y se formaliza en el "
          "SP-11. Las tarifas no se infieren: salen del tabulador vigente por bill code y las "
          "fija Pricing. Aquí no aparece ninguna.</div>")
        w("<div class='aviso'>El Anexo fija una ventana de servicio de lunes a viernes de 9 a 18 "
          "horas, y al mismo tiempo compromete atención de incidentes de severidad 1 en 30 "
          "minutos. Conviene dejar por escrito que ese reloj corre dentro de la ventana, o "
          "dimensionar guardia fuera de horario y reflejarlo en el equipo.</div>")
        w("</div></section>")

        # ---------------- 7. hasta donde optimiza la IA ----------------
        ia = b.fte(con_ia=True)
        piso = round(ia["steady"] - 0.80 + 1.25, 2)
        w("<section><div class='wrap'>")
        w("<h2><span class='num'>07</span>Hasta dónde optimiza la IA</h2>")
        w("<div class='lead'>Tres curvas sobre el mismo alcance. La tercera asume automatización "
          "madura, que el guideline sitúa en los años 2 y 3, no en el primero.</div>")
        w("<table><thead><tr><th>Escenario</th><th class='num'>Implementación</th>"
          "<th class='num'>Operación</th><th>Qué asume</th></tr></thead><tbody>")
        for es in b.escenarios_fte():
            w(f"<tr><td class='id'>{e(es['escenario'])}</td>"
              f"<td class='num'>{es['setup']:.2f}</td><td class='num'>{es['steady']:.2f}</td>"
              f"<td>{e(es['nota'])}</td></tr>")
        w("</tbody></table>")

        w("<div class='grid g3'>")
        w(f"<div class='card'><div class='t'>{ia['steady']:.2f}</div><div class='d'>FTE en "
          "operación con automatización madura. Es el mínimo teórico</div></div>")
        w(f"<div class='card'><div class='t'>{piso:.2f}</div><div class='d'>Piso práctico una vez "
          "que se respeta la cobertura diaria que exigen los compromisos de servicio</div></div>")
        w("<div class='card'><div class='t'>64 por ciento</div><div class='d'>Reducción acumulada "
          "en operación frente al patrón de banca con el que se partió</div></div>")
        w("</div>")

        w("<h3>Dónde está el ahorro</h3>")
        w("<table><thead><tr><th>Rol</th><th class='num'>Operación hoy</th>"
          "<th class='num'>Con IA</th><th class='num'>Ahorro</th><th>Palanca</th>"
          "</tr></thead><tbody>")
        for r in b.palancas_ia():
            if r["ahorro_steady"] <= 0:
                continue
            w(f"<tr><td class='id'>{e(r['rol'])}</td>"
              f"<td class='num'>{r['fte_steady']:.2f}</td>"
              f"<td class='num'>{r['fte_ia_steady']:.2f}</td>"
              f"<td class='num'>{r['ahorro_steady']:.2f}</td>"
              f"<td>{e(r['palanca_ia'])}</td></tr>")
        w("</tbody></table>")

        w("<h3>Lo que la IA no puede bajar</h3>")
        w("<table><thead><tr><th>ID</th><th>Límite</th><th>Por qué</th><th>Piso que impone</th>"
          "</tr></thead><tbody>")
        for l in b.limites_ia():
            w(f"<tr><td class='id'>{e(l['id'])}</td><td><b>{e(l['limite'])}</b></td>"
              f"<td>{e(l['por_que'])}</td><td>{e(l['piso'])}</td></tr>")
        w("</tbody></table>")

        w("<div class='aviso'><b>El FTE no es el precio, es el costo.</b> El servicio se cobra "
          "como porcentaje del consumo de nube, entre 37 y 45 por ciento según la talla, no por "
          "persona asignada. Reducir el equipo no abarata la oferta para el cliente: mejora "
          "nuestro margen. Conviene decidir cuánto margen se necesita antes de seguir recortando, "
          "porque cada recorte adicional compra margen a cambio de riesgo de entrega en un "
          "contrato de tres años con penalizaciones.</div>")
        w("</div></section>")

        # ---------------- footer ----------------
        w("<footer><div class='wrap'>")
        w("<div class='marca'>accenture</div>")
        w(f"<p style='margin-top:10px'>Generado el {fecha_larga(HOY)} desde lab-brain.db por "
          "generators/build-equipo.py. Para cambiar el equipo o el calendario se cambia el dato "
          "en el brain y se vuelve a generar.</p>")
        w("<p>Equipo construido sobre el guideline de staffing de Infrastructure Management "
          "Services y la definición de Solution Architect del ecosistema de Solutioning. "
          "Documento interno de delivery.</p>")
        w("</div></footer>")
        w("</body></html>")
        return "\n".join(o)
    finally:
        b.close()


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    doc = render()
    io.open(OUT, "w", encoding="utf-8").write(doc)
    print(f"Generado: {OUT}")
    print(f"  {len(doc):,} bytes, ventana del Gantt de {N_SEM} semanas")


if __name__ == "__main__":
    main()
