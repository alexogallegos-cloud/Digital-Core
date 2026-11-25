#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-mitigacion-portal.py — El plan de mitigación de capacidad de Caja, en portal.

Lee las acciones y su nivel de autonomía de `bank-brain.db` (tablas `action_catalog`
y `actions`, Regla B39) y arma `portal/mitigacion-caja.html`.

Se genera y no se escribe a mano, por la Regla P4: un HTML editado a mano deja de
ser el brain y pasa a ser una opinión sobre el brain. Si cambia una autorización,
se cambia en `load-action-catalog.py` y se vuelve a correr esto.

Uso:
  python generators/build-mitigacion-portal.py
"""
import sqlite3
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _canon import DB, MARCA, PORTAL, pagina, sb, item_leyenda  # noqa: E402

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SALIDA = PORTAL / "mitigacion-caja.html"

# Orden de presentación y nota de secuencia. El nivel, el rol y la razón salen
# del brain; esto es lo único editorial y vive aquí a propósito.
SECUENCIA = {
    "ACT-BCOP-alertas-plugin":        (1, "Mañana", "Enterarse a las 11:40 y no por los tickets de las 18:51"),
    "ACT-BCOP-permiso-cluster27":     (2, "Mañana", "Limpia las marcas falsas que ensucian la señal de las alertas"),
    "ACT-BCOP-param150-reintentos":   (3, "Jueves", "Rompe la espiral: el 12 por ciento de carga que la falla se genera sola"),
    "ACT-BCOP-param151-mensaje":      (4, "Jueves", "Que el error que ahora sí se ve diga qué hacer"),
    "ACT-BCOP-param916-huella":       (5, "Jueves", "Lo mismo sobre el segundo amplificador, el reenvío de huella"),
    "ACT-BCOP-entitlement-ihs":       (6, "Lunes", "Seguro contra inanición del pool compartido. No es un arreglo"),
    "ACT-BCOP-dimensionar-eg-caja":   (7, "Por confirmar", "Lo único que baja la latencia, que es el motor real"),
}

PRONOSTICO = [
    ("Viernes 13 de noviembre", "Quincena, con el 15 en domingo, y arranque del Buen Fin",
     "8,039 a 9,825", "Falla con errores 5xx todo el día"),
    ("Sábado 14 de noviembre", "Quincena y Buen Fin", "5,806 a 8,039",
     "Falla con errores 5xx todo el día"),
    ("15 y 16 de noviembre", "Buen Fin", "4,913 a 6,252",
     "Degradación de 11 a 19 horas"),
]


def tarjeta_accion(fila, idx, cuando, compra):
    firma = "Sí" if fila["never_below_a3"] else "No"
    clase = "si" if fila["never_below_a3"] else "no"
    return f"""
    <article class="acc">
      <div class="acc-n">{idx}</div>
      <div class="acc-b">
        <h3>{fila['action_type']}</h3>
        <p class="acc-compra">{compra}.</p>
        <p class="acc-desc">{fila['description']}</p>
        <div class="acc-meta">
          <span class="chip chip-{clase}">Requiere firma: {firma}</span>
          <span class="chip">Nivel autorizado: {fila['authorized_level']}</span>
          <span class="chip">Rol responsable: {fila['accountable_role']}</span>
          <span class="chip">Cuándo: {cuando}</span>
        </div>
      </div>
    </article>"""


CSS_EXTRA = r"""
.bloque{margin:34px 0}
.bloque h2{font-size:19px;margin:0 0 6px;letter-spacing:-.01em}
.bloque .sub{color:rgba(255,255,255,.55);font-size:13px;margin:0 0 16px;max-width:76ch;line-height:1.65}
.bloque p{color:rgba(255,255,255,.72);font-size:13.5px;line-height:1.75;max-width:80ch;margin:0 0 12px}
.destacado{border-left:3px solid var(--accent);background:rgba(240,210,36,.05);
  padding:16px 20px;border-radius:0 8px 8px 0;margin:18px 0}
.destacado p{margin:0;color:rgba(255,255,255,.85)}
.acc{display:flex;gap:16px;padding:18px 0;border-bottom:1px solid rgba(255,255,255,.07)}
.acc:last-child{border-bottom:0}
.acc-n{flex:0 0 32px;height:32px;border-radius:50%;background:rgba(240,210,36,.12);
  color:var(--accent);display:flex;align-items:center;justify-content:center;
  font-weight:700;font-size:14px}
.acc-b{flex:1;min-width:0}
.acc h3{font-size:15px;margin:4px 0 6px;letter-spacing:-.01em}
.acc-compra{color:rgba(255,255,255,.82);font-size:13.5px;line-height:1.6;margin:0 0 8px}
.acc-desc{color:rgba(255,255,255,.52);font-size:12.5px;line-height:1.65;margin:0 0 10px;max-width:84ch}
.acc-meta{display:flex;flex-wrap:wrap;gap:6px}
.chip{font-size:10.5px;font-weight:600;letter-spacing:.04em;text-transform:uppercase;
  padding:4px 9px;border-radius:999px;background:rgba(255,255,255,.06);
  color:rgba(255,255,255,.6);border:1px solid rgba(255,255,255,.08)}
.chip-si{background:rgba(133,77,14,.22);color:#f0c674;border-color:rgba(240,198,116,.25)}
.chip-no{background:rgba(26,92,48,.22);color:#7fcf99;border-color:rgba(127,207,153,.25)}
table.pron{width:100%;border-collapse:collapse;margin:14px 0;font-size:13px}
table.pron th{text-align:left;font-size:10.5px;letter-spacing:.08em;text-transform:uppercase;
  color:rgba(255,255,255,.4);font-weight:600;padding:8px 12px 8px 0;
  border-bottom:1px solid rgba(255,255,255,.1)}
table.pron td{padding:11px 12px 11px 0;border-bottom:1px solid rgba(255,255,255,.06);
  color:rgba(255,255,255,.72);vertical-align:top;line-height:1.55}
table.pron td:first-child{color:#fff;font-weight:600;white-space:nowrap}
table.pron td.cifra{color:var(--accent);font-weight:600;white-space:nowrap}
.aviso{border-left:3px solid #f0c674;background:rgba(240,198,116,.07);padding:13px 18px;
  border-radius:0 8px 8px 0;margin:16px 0 0;color:#f0c674;font-size:12.5px;line-height:1.65}
.procedencia{color:rgba(255,255,255,.5);font-size:12px;line-height:1.7;font-style:italic;
  max-width:80ch;margin:0 0 10px}
"""


def main():
    if not DB.exists():
        sys.exit(f"No existe {DB}. Corre antes digital-brain/build-bank-brain.py")
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row

    # El chrome del canon trae un enlace de volver al index. El portal del
    # bank-brain todavia no tiene landing, y un enlace a un 404 es peor que no
    # tenerlo: se omite hasta que exista.
    marca = dict(MARCA)
    if not (PORTAL / "index.html").exists():
        marca["back"] = ""

    filas = {r["id"]: r for r in con.execute(
        "SELECT * FROM action_catalog WHERE id LIKE 'ACT-BCOP-%'")}
    if not filas:
        sys.exit("El catálogo no tiene acciones ACT-BCOP-. Corre load-action-catalog.py")

    nivel_hoy = con.execute(
        "SELECT DISTINCT level FROM actions WHERE catalog_id LIKE 'ACT-BCOP-%'").fetchall()
    tier_hoy = con.execute(
        "SELECT DISTINCT knowledge_tier FROM actions WHERE catalog_id LIKE 'ACT-BCOP-%'").fetchall()
    nivel_hoy = ", ".join(sorted(r[0] for r in nivel_hoy)) or "sin registro"
    tier_hoy = ", ".join(sorted(r[0] or "sin declarar" for r in tier_hoy))

    total = len(filas)
    con_firma = sum(1 for r in filas.values() if r["never_below_a3"])
    con.close()

    metricas = (sb(total, "Acciones") + sb(con_firma, "Requieren firma")
                + sb(total - con_firma, "Preautorizables", azul=True)
                + sb(nivel_hoy, "Nivel efectivo hoy"))

    leyenda = (item_leyenda("Sustento", tier_hoy)
               + item_leyenda("Ninguna requiere", "Despliegue")
               + item_leyenda("Regla", "B39"))

    # El catalogo manda. SECUENCIA solo aporta orden y nota editorial: una accion
    # que el catalogo tiene y el diccionario no, se pinta igual al final y se
    # marca. Antes se caia en silencio y la metrica contaba una mas de las que
    # el cuerpo dibujaba, o sea que la pagina se contradecia sola.
    sin_anotar = [cid for cid in filas if cid not in SECUENCIA]
    orden = sorted(filas, key=lambda c: SECUENCIA.get(c, (99, "", ""))[0])
    acciones = "".join(
        tarjeta_accion(
            filas[cid],
            SECUENCIA.get(cid, (i + 1, "Sin clasificar", "Sin nota de secuencia"))[0],
            SECUENCIA.get(cid, (0, "Sin clasificar", ""))[1],
            SECUENCIA.get(cid, (0, "", "Alta nueva en el catalogo, pendiente de ubicar en la secuencia"))[2],
        )
        for i, cid in enumerate(orden))
    if sin_anotar:
        acciones += (
            '<p class="aviso">Hay ' + str(len(sin_anotar)) + ' accion(es) en el catalogo sin '
            'nota de secuencia en el generador: <code>' + '</code>, <code>'.join(sin_anotar)
            + '</code>. Se pintan al final, sin fecha sugerida.</p>')

    pron = "".join(
        f"<tr><td>{f}</td><td>{m}</td><td class='cifra'>{c}</td><td>{q}</td></tr>"
        for f, m, c, q in PRONOSTICO)

    cuerpo = f"""
    <div class="bloque">
      <h2>La pregunta que destraba todo lo demás</h2>
      <div class="destacado">
        <p><b>¿El dimensionamiento del grupo de ejecución de Caja también está bloqueado,
        o sólo el plugin del servidor web?</b></p>
      </div>
      <p>Son dos artefactos distintos y dos equipos distintos. El plugin vive en
      <code>plugin-cfg.xml</code> del IBM HTTP Server, el servidor web que está al frente.
      El grupo de ejecución, que es el proceso del bus que atiende el puerto 7806 y que IBM
      renombró a Integration Server desde la versión 10, se administra del lado del broker.
      Lo que quedó bloqueado fue el plugin; del otro nadie ha dicho nada.</p>
      <p>Importa porque es la única palanca que baja la latencia, y la latencia es el motor
      real. Con Caja respondiendo en 100 milisegundos harían falta más de 30,000 llamadas por
      minuto para agotar el tope de conexiones; con Caja en 5 segundos bastan 8,000. El tope
      sólo se alcanza cuando Caja ya está lenta, así que las demás acciones trabajan alrededor
      del síntoma.</p>
    </div>

    <div class="bloque">
      <h2>Las acciones, en orden de ejecución</h2>
      <p class="sub">Ninguna requiere despliegue. Seis de siete requieren firma igual, porque
      caen en los cuatro tipos que nunca bajan de nivel A3 y siempre exigen aprobación
      explícita del rol responsable.</p>
      {acciones}
    </div>

    <div class="bloque">
      <h2>Por qué seis de siete necesitan firma</h2>
      <p>El criterio son dos razones, no una: o el efecto sobre lo que ya ocurrió no se
      recupera, o hay consecuencia regulatoria directa. Conviene no colapsarlas en la palabra
      irreversible, porque describe mal la causa.</p>
      <p>Cinco lo son por cambio en producción. El parámetro 150, por ejemplo, sí se revierte
      con otro UPDATE en segundos. Lo que no se revierte son las operaciones de ventanilla que
      ocurrieron mientras estuvo puesto: deshacer la configuración no deshace lo que pasó con
      esos clientes. La sexta, el permiso del clúster de reportería, lo es por la otra razón,
      porque tocar permisos de red entra en el alcance de PCI-DSS.</p>
      <p>La única que puede ir preautorizada son las alertas, porque crean reglas nuevas de
      monitoreo y no tocan el servicio.</p>
    </div>

    <div class="bloque">
      <h2>Tres cosas que conviene tener claras antes de decidir</h2>
      <p><b>El parámetro 150 va a 1, nunca a 0.</b> La condición en el código es
      <code>intentos == numIntentosWs</code> arrancando en cero: con 1 hay un intento y ningún
      reintento, y con 0 truena la primera llamada de toda operación de ventanilla. Antes de
      proponerlo hay que leer su valor vigente en DB2, que no está en el código porque es dato.
      Si ya estuviera en 1, el 12 por ciento medido viene de otro lado.</p>
      <p><b>El timeout no se puede arreglar sin despliegue, sólo los reintentos.</b> No hay un
      solo parámetro de timeout entre los 188 de la tabla, y el cliente SOAP construye su
      <code>HttpClient</code> sin ningún <code>RequestConfig</code>, o sea sin timeout de
      conexión, de socket ni de solicitud. Cada intento fallido seguirá costando los 20
      segundos de <code>ConnectTimeout</code> del plugin; lo único que se logra es dejar de
      multiplicarlos.</p>
      <p><b>El plan no evita el evento del viernes.</b> El 12 por ciento es amplificación y no
      demanda: aparece cuando ya empezaron los errores 5xx. Lo que el plan le quita al evento
      es la espiral, no el evento.</p>
      <p class="procedencia">Las cifras de esta tabla no salen del brain: están tomadas del
      diagnóstico de performance en sucursales de octubre de 2026, que las construyó con
      multiplicadores de quincena sobre el pico normal. Son un pronóstico con supuestos, no una
      medición, y el propio diagnóstico deja el perfil de quincena por confirmar con negocio.</p>
      <table class="pron">
        <tr><th scope="col">Fecha</th><th scope="col">Motivo</th><th scope="col">Llamadas por minuto</th><th scope="col">Comportamiento esperado</th></tr>
        {pron}
      </table>
      <p>Contra los 7,939 que tiraron el servicio el 16 de octubre, el viernes se esperan hasta
      9,825. Ninguna combinación de parámetros cierra esa brecha.</p>
    </div>

    <div class="bloque">
      <h2>Qué haría hoy</h2>
      <p>Dos consultas, no dos cambios, y destraban el resto: preguntar por el estado del
      grupo de ejecución y leer el parámetro 150 en DB2. La segunda además es el requisito
      formal para que estas acciones pasen de proponer a poder ejecutarse, porque los niveles
      A2 y A3 exigen conocimiento gold y hoy el sustento es silver.</p>
    </div>"""

    html = pagina(
        titulo="Mitigación de capacidad de Caja",
        vista="Mitigación",
        kick="Plan sin despliegue",
        h1="Mitigación de capacidad de Caja",
        intro=("Qué se puede hacer antes del Buen Fin sin desplegar código, qué requiere firma "
               "y qué no alcanza a evitarse. Las acciones y su nivel de autonomía salen del "
               "catálogo del brain; el orden y la fecha son editoriales."),
        metricas=metricas,
        leyenda=leyenda,
        cuerpo=cuerpo,
        pie=(f"Generado el {date.today().isoformat()} por <code>generators/build-mitigacion-portal.py</code> "
             f"desde <code>bank-brain.db::action_catalog</code> y <code>::actions</code>. "
             f"Evidencia: diagnóstico de performance en sucursales de octubre de 2026 y el fuente de CPlaSu."),
        css_extra=CSS_EXTRA,
        marca=marca,
    )

    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    SALIDA.write_text(html, encoding="utf-8")
    print(f"  {SALIDA}  ({SALIDA.stat().st_size:,} bytes)")
    print(f"  {total} acciones, {con_firma} requieren firma, nivel efectivo {nivel_hoy}")


if __name__ == "__main__":
    main()
