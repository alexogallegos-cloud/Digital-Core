#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
build-plan.py — Genera portal/plan-setup.html desde lab-brain.db.

El HTML NUNCA se edita a mano: la fuente de verdad es el brain. Para cambiar el
plan, se cambia el dato en build-brain.py, se reconstruye el brain y se corre
este generador.

Paleta Banamex del Design Studio (Solutioning/Design - Studio/paleta_clientes.md):
    Ancla #004785 · Papel #FFFFFF · Plano #EEF3F9 · Trazo #D6D7D6 · Señal #EE3124
Reglas del design system aplicadas:
    - Barra Señal de 3px en la parte superior del panel Ancla, invariable
    - Texto sobre Ancla siempre #FFFFFF puro, nunca rgba
    - Señal solo sobre Ancla, nunca sobre Papel
    - Dos pesos tipográficos: 700 y 300
    - Indicadores de tabla con subrayado 1.5px, nunca badges rellenos

Uso:  PYTHONUTF8=1 python build-plan.py
"""
import datetime as dt
import html
import io
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE / "digital-brain"))

from brain import LabBrain  # noqa: E402

OUT = BASE / "portal" / "plan-setup.html"

ANCLA = "#004785"
PAPEL = "#FFFFFF"
PLANO = "#EEF3F9"
TRAZO = "#D6D7D6"
SENAL = "#EE3124"
TINTA = "#1A1A1A"
TENUE = "#5A6B7C"

HOY = dt.date.today()

MESES = ("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
         "agosto", "septiembre", "octubre", "noviembre", "diciembre")


def fecha_larga(d: dt.date) -> str:
    return f"{d.day} de {MESES[d.month - 1]} de {d.year}"


def e(x) -> str:
    return html.escape(str(x if x is not None else ""))


def dias_a(fecha_iso: str) -> int:
    return (dt.date.fromisoformat(fecha_iso) - HOY).days


CSS = f"""
*{{box-sizing:border-box;margin:0;padding:0}}
body{{font-family:Calibri,Arial,sans-serif;font-weight:300;color:{TINTA};
     background:{PAPEL};line-height:1.55;font-size:15px}}
.wrap{{max-width:1180px;margin:0 auto;padding:0 32px}}
b,strong,th{{font-weight:700}}

/* ---------- panel Ancla ---------- */
.ancla{{background:{ANCLA};color:{PAPEL};position:relative}}
.ancla::before{{content:"";position:absolute;top:0;left:0;right:0;height:3px;background:{SENAL}}}
.ancla *{{color:{PAPEL}}}
.eyebrow{{color:{SENAL};text-transform:uppercase;letter-spacing:.14em;
         font-size:11px;font-weight:700}}
.hero{{padding:52px 0 44px}}
.hero h1{{font-size:38px;font-weight:700;line-height:1.15;margin:14px 0 10px}}
.hero .sub{{font-size:17px;max-width:760px}}
.hero .meta{{display:flex;flex-wrap:wrap;gap:40px;margin-top:34px;
            padding-top:26px;border-top:1px solid rgba(255,255,255,.22)}}
.hero .meta div{{min-width:130px}}
.hero .meta .k{{font-size:11px;text-transform:uppercase;letter-spacing:.1em;
               color:{SENAL};font-weight:700}}
.hero .meta .v{{font-size:21px;font-weight:700;margin-top:4px}}
.hero .meta .n{{font-size:12px}}

/* ---------- aviso interno ---------- */
.interno{{background:{PLANO};border-bottom:1px solid {TRAZO};padding:11px 0;font-size:13px}}
.interno b{{color:{ANCLA}}}

/* ---------- secciones ---------- */
section{{padding:46px 0;border-bottom:1px solid {TRAZO}}}
section:last-of-type{{border-bottom:0}}
h2{{font-size:26px;font-weight:700;color:{ANCLA};margin-bottom:6px}}
h2 .num{{font-weight:700;color:{TRAZO};margin-right:12px}}
.lead{{font-size:15px;color:{TENUE};max-width:860px;margin-bottom:26px}}
h3{{font-size:17px;font-weight:700;color:{ANCLA};margin:26px 0 10px}}
p{{margin-bottom:12px;max-width:900px}}

/* ---------- tablas ---------- */
table{{width:100%;border-collapse:collapse;margin:14px 0;font-size:14px}}
th{{background:{ANCLA};color:{PAPEL};text-align:left;padding:9px 11px;
   font-size:12px;text-transform:uppercase;letter-spacing:.06em}}
td{{padding:9px 11px;border-bottom:1px solid {TRAZO};vertical-align:top}}
tr:last-child td{{border-bottom:0}}
tbody tr:nth-child(even){{background:{PLANO}}}
td.id{{font-weight:700;color:{ANCLA};white-space:nowrap}}
td.num{{text-align:right;white-space:nowrap}}

/* indicadores: subrayado 1.5px, nunca badge relleno */
.ind{{font-weight:700;padding-bottom:1px;white-space:nowrap}}
.ind-si{{border-bottom:1.5px solid {ANCLA};color:{ANCLA}}}
.ind-no{{border-bottom:1.5px solid {TRAZO};color:{TENUE}}}
.ind-alerta{{border-bottom:1.5px solid {SENAL};color:{TINTA}}}

/* ---------- tarjetas ---------- */
.grid{{display:grid;gap:16px;margin-top:18px}}
.g2{{grid-template-columns:repeat(2,1fr)}}
.g3{{grid-template-columns:repeat(3,1fr)}}
.g4{{grid-template-columns:repeat(4,1fr)}}
.card{{background:{PLANO};border:1px solid {TRAZO};padding:18px 20px}}
.card .t{{font-weight:700;color:{ANCLA};font-size:15px;margin-bottom:6px}}
.card .d{{font-size:13.5px;color:{TINTA}}}
.card .f{{font-size:12px;color:{TENUE};margin-top:10px;
         padding-top:9px;border-top:1px solid {TRAZO}}}

/* ---------- fase ---------- */
.fase{{margin-top:30px}}
.fase-h{{background:{ANCLA};color:{PAPEL};padding:13px 18px;position:relative}}
.fase-h::before{{content:"";position:absolute;top:0;left:0;right:0;height:3px;background:{SENAL}}}
.fase-h .id{{font-weight:700;font-size:12px;letter-spacing:.1em;color:{SENAL}}}
.fase-h .n{{font-weight:700;font-size:19px;margin-top:2px}}
.fase-h .w{{font-size:13px;margin-top:2px}}

/* ---------- ruta critica ---------- */
.ruta{{counter-reset:paso}}
.ruta li{{list-style:none;position:relative;padding:10px 0 10px 54px;
         border-bottom:1px solid {TRAZO};font-size:14.5px}}
.ruta li:last-child{{border-bottom:0}}
.ruta li::before{{counter-increment:paso;content:counter(paso);position:absolute;left:0;top:10px;
                 width:34px;height:24px;background:{ANCLA};color:{PAPEL};
                 font-weight:700;font-size:12px;display:flex;align-items:center;
                 justify-content:center}}
.ruta li b{{color:{ANCLA}}}

/* ---------- cita ---------- */
.cita{{border-left:3px solid {ANCLA};padding:4px 0 4px 18px;margin:18px 0;
      font-size:15px;max-width:880px}}
.cita .src{{font-size:12px;color:{TENUE};margin-top:6px}}

footer{{background:{ANCLA};color:{PAPEL};padding:30px 0;font-size:13px;position:relative}}
footer::before{{content:"";position:absolute;top:0;left:0;right:0;height:3px;background:{SENAL}}}
footer *{{color:{PAPEL}}}
footer .marca{{font-weight:700;font-size:16px}}

@media print{{
  section{{page-break-inside:avoid}}
  body{{font-size:11pt}}
}}
"""


def render() -> str:
    b = LabBrain()
    try:
        c = b.contrato()
        fases = b.fases()
        iniciativas = b.tablero_iniciativas()
        o: list[str] = []
        w = o.append

        vence = "2026-11-11"
        restan = dias_a(vence)

        w("<!DOCTYPE html><html lang='es'><head><meta charset='utf-8'>")
        w("<meta name='viewport' content='width=device-width,initial-scale=1'>")
        w("<title>Laboratorio de Aceleración — Plan de Setup</title>")
        w(f"<style>{CSS}</style></head><body>")

        # ---------------- hero ----------------
        w("<div class='ancla'><div class='wrap hero'>")
        w("<div class='eyebrow'>Banamex, Change the Bank</div>")
        w("<h1>Laboratorio de Aceleración<br>Plan de Setup</h1>")
        w("<div class='sub'>Habilitación, activación y operación de un laboratorio Cloud aislado "
          "para construir, integrar y probar productos digitales contra un core emulado y datos "
          "sintéticos. El setup termina cuando las cuatro iniciativas estratégicas pueden arrancar.</div>")
        w("<div class='meta'>")
        w(f"<div><div class='k'>Vigencia</div><div class='v'>3 años</div>"
          f"<div class='n'>Del 12 de octubre de 2026 al 11 de octubre de 2029</div></div>")
        w(f"<div><div class='k'>Fecha dura</div><div class='v'>11 nov 2026</div>"
          f"<div class='n'>Entregables 1 y 2, restan {restan} días</div></div>")
        w(f"<div><div class='k'>Actividades</div><div class='v'>{len(b.actividades())}</div>"
          f"<div class='n'>Repartidas en {len(fases)} componentes</div></div>")
        w(f"<div><div class='k'>Cuota de arranque</div><div class='v'>30,000 USD</div>"
          f"<div class='n'>Se libera en sesión en vivo, no con documentos</div></div>")
        w("</div></div></div>")

        w("<div class='interno'><div class='wrap'><b>Documento interno de delivery.</b> "
          "Contiene análisis de frontera contractual que no debe compartirse con el cliente sin "
          "sanitizar previamente.</div></div>")

        # ---------------- 1. donde estamos ----------------
        w("<section><div class='wrap'>")
        w("<h2><span class='num'>01</span>Dónde estamos parados</h2>")
        w(f"<p>El Anexo B arrancó el lunes 12 de octubre de 2026. El primer mes vence el miércoles "
          f"11 de noviembre, y para esa fecha tienen que estar entregados el diseño de arquitectura "
          f"y seguridad y el laboratorio base habilitado. Restan <b>{restan} días naturales</b>.</p>")
        w("<p>El diseño de solución comprometió una habilitación de una semana, con sandbox "
          "operado al quinto día, y una activación de seis semanas. Esas duraciones son del deck, "
          "no del Anexo: el contrato no fija plazo de implementación para ninguno de sus tres "
          "componentes. Por eso la ventana se fijó en cuatro semanas, del 12 de octubre al 6 de "
          "noviembre, que es lo que cabe antes del 11. La primera actividad del plan es "
          "contrastar el estado real de la habilitación contra lo comprometido.</p>")
        w("<div class='cita'>" + e(c.get("exclusion_critica", "")) +
          "<div class='src'>Anexo B, cláusula tercera</div></div>")
        w("</div></section>")

        # ---------------- 2. iniciativas ----------------
        w(f"<section style='background:{PLANO}'><div class='wrap'>")
        w("<h2><span class='num'>02</span>Las cuatro iniciativas estratégicas</h2>")
        w("<div class='lead'>El laboratorio no se monta para tener un laboratorio. Se monta para "
          "habilitar estas cuatro, y el setup está terminado cuando las cuatro pueden arrancar.</div>")
        w("<table><thead><tr><th>Iniciativa</th><th>Qué necesita del laboratorio</th>"
          "<th class='num'>Habilitadores</th><th class='num'>Brechas</th><th>Anexo B</th></tr></thead><tbody>")
        for i in iniciativas:
            prep = b.preparacion_iniciativa(i["id"])
            lab = [h for h in prep["habilitadores"] if h["tipo"] == "Laboratorio"]
            necesita = lab[0]["que_aporta"] if lab else ""
            ind = "<span class='ind ind-no'>Fuera de alcance</span>" if not i["en_anexo_b"] \
                else "<span class='ind ind-si'>Cubierta</span>"
            w(f"<tr><td class='id'>{e(i['id'])}<br>{e(i['nombre'])}</td>"
              f"<td>{e(necesita)}</td>"
              f"<td class='num'>{i['habilitadores']}</td>"
              f"<td class='num'>{i['brechas']}</td><td>{ind}</td></tr>")
        w("</tbody></table>")
        w("<p><b>La transformación del SDLC no es la del laboratorio, es la de todo el banco.</b> "
          "El laboratorio es donde el modelo se incuba y se prueba con productos reales, pero el "
          "objetivo es que salga de ahí. Eso obliga a diseñar el SDLC del laboratorio como algo "
          "extensible y transferible desde el principio, y a levantar la línea base del banco en "
          "paralelo.</p>")
        w("</div></section>")

        # ---------------- 3. frontera contractual ----------------
        w("<section><div class='wrap'>")
        w("<h2><span class='num'>03</span>Qué contrata el Anexo B</h2>")
        w("<div class='lead'>Cinco entregables formales. Dos tienen fecha dura y tres son "
          "recurrentes desde que arranca la operación.</div>")
        w("<table><thead><tr><th class='num'>#</th><th>Entregable</th><th>Criterio de aceptación</th>"
          "<th>Frecuencia</th><th>Vence</th></tr></thead><tbody>")
        for d in b.entregables_contractuales():
            vcol = f"<span class='ind ind-alerta'>{e(d['vence'])}</span>" if d["vence"] else "Recurrente"
            w(f"<tr><td class='num'>{d['num']}</td><td class='id'>{e(d['nombre'])}</td>"
              f"<td>{e(d['criterio'])}</td><td>{e(d['frecuencia'])}</td><td>{vcol}</td></tr>")
        w("</tbody></table>")
        w(f"<p>La aceptación opera por silencio: Banamex tiene {e(c.get('aceptacion_dias_habiles'))} "
          "días hábiles desde el envío para aceptar o rechazar por escrito, y pasado ese plazo el "
          "entregable se considera aceptado. Conviene registrar la fecha de envío de cada uno.</p>")

        w("<h3>El criterio de salida real del setup</h3>")
        w("<p>La cuota de arranque de treinta mil dólares no se acredita con documentos. Se verifica "
          "en una sesión en vivo con usuarios de Banamex sobre el laboratorio funcionando, y solo es "
          "exigible cuando el banco lo confirma por escrito.</p>")
        w("<div class='grid g4'>")
        for cr in b.criterios_arranque():
            w(f"<div class='card'><div class='t'>Criterio {cr['num']}</div>"
              f"<div class='d'>{e(cr['criterio'])}</div></div>")
        w("</div>")
        w("</div></section>")

        # ---------------- 4. fases y actividades ----------------
        w(f"<section style='background:{PLANO}'><div class='wrap'>")
        w("<h2><span class='num'>04</span>Fases, actividades y entregables</h2>")
        w("<div class='lead'>Cada actividad lleva su entregable y su dependencia. El orden no es "
          "arbitrario: se deriva de las dependencias técnicas y contractuales.</div>")
        for f in b.estado_setup():
            acts = b.actividades(fase=f["id"])
            if not acts:
                continue
            w("<div class='fase'><div class='fase-h'>")
            w(f"<div class='id'>{e(f['id'])}</div>")
            w(f"<div class='n'>{e(f['nombre'])}</div>")
            w(f"<div class='w'>{e(f['ventana'])} — {f['hechas']} de {f['actividades']} completadas</div>")
            w("</div>")
            w("<table><thead><tr><th>ID</th><th>Actividad</th><th>Entregable</th>"
              "<th>Depende de</th></tr></thead><tbody>")
            for a in acts:
                dep = a["depende_de"].replace(",", ", ") if a["depende_de"] else "Nada, puede arrancar"
                w(f"<tr><td class='id'>{e(a['id'])}</td><td>{e(a['actividad'])}</td>"
                  f"<td>{e(a['entregable'])}</td><td>{e(dep)}</td></tr>")
            w("</tbody></table></div>")
        w("</div></section>")

        # ---------------- 5. ruta critica ----------------
        w("<section><div class='wrap'>")
        w("<h2><span class='num'>05</span>La ruta crítica</h2>")
        w("<div class='lead'>Cadena de actividades que llevan a la sesión en vivo que acredita los "
          "cuatro criterios y vuelve exigible la cuota de arranque. Todo lo demás del setup existe "
          "para llegar ahí.</div>")
        w("<ul class='ruta'>")
        for a in b.ruta_critica():
            w(f"<li><b>{e(a['id'])}</b> &nbsp; {e(a['actividad'])}</li>")
        w("</ul>")
        libres = b.sin_dependencias()
        w(f"<h3>Pueden arrancar hoy, sin esperar a nadie</h3>")
        w("<div class='grid g3'>")
        for a in libres:
            w(f"<div class='card'><div class='t'>{e(a['id'])}</div>"
              f"<div class='d'>{e(a['actividad'])}</div>"
              f"<div class='f'>{e(a['entregable'])}</div></div>")
        w("</div>")
        w("<p>Las tres primeras no dependen de trabajo técnico nuestro, dependen de decisiones y de "
          "una agenda del cliente. Es el patrón por el que este tipo de arranque se atrasa, y el "
          "atraso no se recupera porque la fecha del primer mes es contractual.</p>")
        w("</div></section>")

        # ---------------- 6. decisiones y datos ----------------
        w(f"<section style='background:{PLANO}'><div class='wrap'>")
        w("<h2><span class='num'>06</span>Decisiones abiertas y datos requeridos</h2>")
        w("<div class='lead'>Lo que bloquea el setup hoy. Las decisiones son del cliente o conjuntas; "
          "los datos requeridos son insumos que solo el banco puede entregar.</div>")
        w("<h3>Decisiones abiertas</h3>")
        w("<table><thead><tr><th>ID</th><th>Decisión</th><th>Por qué bloquea</th>"
          "<th>Quién decide</th></tr></thead><tbody>")
        for d in b.decisiones_abiertas():
            w(f"<tr><td class='id'>{e(d['id'])}</td><td><b>{e(d['decision'])}</b></td>"
              f"<td>{e(d['por_que_bloquea'])}</td><td>{e(d['quien_decide'])}</td></tr>")
        w("</tbody></table>")
        w("<h3>Datos requeridos al banco</h3>")
        w("<table><thead><tr><th>Iniciativa</th><th>Qué falta</th><th>Impacto si no llega</th>"
          "</tr></thead><tbody>")
        for d in b.datos_requeridos():
            w(f"<tr><td class='id'>{e(d['iniciativa'])}<br>{e(d['iniciativa_nombre'])}</td>"
              f"<td><b>{e(d['brecha'])}</b></td><td>{e(d['impacto'])}</td></tr>")
        w("</tbody></table>")
        w("</div></section>")

        # ---------------- 7. arquetipos y talla ----------------
        w("<section><div class='wrap'>")
        w("<h2><span class='num'>07</span>Arquetipos y talla del servicio</h2>")
        w("<div class='lead'>La talla no se contrata: se lee del rango de consumo mensual, y trae "
          "consigo el cupo de arquetipos, usuarios y dominios de core emulado.</div>")
        w("<div class='grid g4'>")
        for a in b.arquetipos():
            w(f"<div class='card'><div class='t'>Arquetipo {e(a['id'])}. {e(a['nombre'])}</div>"
              f"<div class='d'>{e(a['descripcion'])}</div>"
              f"<div class='f'>Consumo de referencia {a['consumo_aws']:,} USD al mes, "
              f"{a['corridas_mes']:,} corridas de pipeline</div></div>")
        w("</div>")
        w("<table><thead><tr><th>Talla</th><th class='num'>Consumo mensual USD</th>"
          "<th class='num'>Servicio</th><th class='num'>Arquetipos</th><th class='num'>Usuarios</th>"
          "<th class='num'>Pipelines al mes</th><th class='num'>Dominios de core</th>"
          "</tr></thead><tbody>")
        for t in b.tallas():
            rango = f"{t['consumo_desde']:,} en adelante" if t["consumo_hasta"] is None \
                else f"{t['consumo_desde']:,} a {t['consumo_hasta']:,}"
            w(f"<tr><td class='id'>{e(t['talla'])}</td><td class='num'>{rango}</td>"
              f"<td class='num'>{t['pct_servicio']:.0f} por ciento</td>"
              f"<td class='num'>{t['arquetipos_cupo']}</td><td class='num'>{t['usuarios']}</td>"
              f"<td class='num'>{t['pipelines_mes']:,}</td>"
              f"<td class='num'>{t['dominios_core']}</td></tr>")
        w("</tbody></table>")
        w("</div></section>")

        # ---------------- 8. brain ----------------
        w(f"<section style='background:{PLANO}'><div class='wrap'>")
        w("<h2><span class='num'>08</span>El Digital Brain como acelerador</h2>")
        w("<div class='lead'>El brain del core ya existe y está poblado. Federarlo convierte la "
          "dependencia más riesgosa de la activación en una revisión en lugar de una redacción.</div>")
        snap = b.core_snapshot()
        w("<div class='grid g4'>")
        for s in snap[:8]:
            w(f"<div class='card'><div class='t'>{s['filas']:,}</div>"
              f"<div class='d'>{e(s['que_es'])}</div></div>")
        w("</div>")
        w("<p>El Anexo B condiciona el diseño del core emulado a contratos de interfaz, esquemas de "
          "mensajes y reglas de negocio proporcionados y aprobados por el cliente. El brain del core "
          "contiene exactamente eso, extraído del código fuente del legado. En lugar de esperar a que "
          "el banco redacte contratos desde cero, se le pueden proponer contratos derivados de su "
          "propio código para que los apruebe.</p>")
        w("<h3>Capacidades del core con más reglas, candidatas a contrato de interfaz</h3>")
        w("<table><thead><tr><th>Capacidad</th><th>Nombre</th>"
          "<th class='num'>Reglas de negocio</th></tr></thead><tbody>")
        for r in b.candidatos_contrato(10):
            w(f"<tr><td class='id'>{e(r['bc_id'])}</td><td>{e(r['nombre'])}</td>"
              f"<td class='num'>{r['reglas']}</td></tr>")
        w("</tbody></table>")
        w("</div></section>")

        # ---------------- footer ----------------
        w("<footer><div class='wrap'>")
        w("<div class='marca'>accenture</div>")
        w(f"<p style='margin-top:10px'>Generado el {fecha_larga(HOY)} desde "
          "lab-brain.db por generators/build-plan.py. Este archivo no se edita a mano: para "
          "cambiar el plan se cambia el dato en el brain y se vuelve a generar.</p>")
        w(f"<p>Fuente contractual: Anexo B del Contrato Maestro {e(c.get('instrumento','')).split()[-1]}. "
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
    print(f"  {len(doc):,} bytes")


if __name__ == "__main__":
    main()
