#!/usr/bin/env python3
"""
build-knowledge-base.py — Documentos de conocimiento de e-global
BanCoppel Application Modernization · SPE-AM-001

Genera los documentos de `knowledge-base/` desde `digital-brain/brain.db`.
El brain es la fuente de verdad; estos markdown son su proyeccion legible.
Nunca se editan a mano: el ajuste va a este generador.

Produce:
  knowledge-base/rules/validaciones-autorizador.md
  knowledge-base/rules/codigos-respuesta.md
  knowledge-base/vocab/vocabulario-autorizador.md

Uso:
  python generators/build-knowledge-base.py
"""

import json
import sqlite3
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SYSTEM_DIR = Path(__file__).resolve().parent.parent
DB_PATH = SYSTEM_DIR / "digital-brain" / "brain.db"
KB = SYSTEM_DIR / "knowledge-base"


def conectar():
    con = sqlite3.connect(f"file:{DB_PATH}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return con


def encabezado(con, titulo, intro):
    """Las cifras agregan todos los lotes de evidencia; el encabezado los declara."""
    lotes = con.execute(
        "SELECT batch, transactions, window_start, window_end, window_minutes, files "
        "FROM log_batches ORDER BY batch").fetchall()
    construido = con.execute("SELECT built_at FROM system_info").fetchone()[0][:10]
    total = sum(l["transactions"] for l in lotes)
    lineas = "\n".join(
        f"> - `{l['batch']}`: {l['transactions']:,} transacciones en "
        f"{l['window_minutes']:.0f} minutos ({l['window_start'][:8]} a {l['window_end'][:8]}), "
        f"{l['files']} archivos."
        for l in lotes)
    return (
        f"# {titulo}\n\n"
        f"{intro}\n\n"
        f"> Generado desde `digital-brain/brain.db` por `generators/build-knowledge-base.py`. "
        f"No editar a mano. Construido el {construido}.\n"
        f"> Las cifras agregan {len(lotes)} lote(s) de evidencia, {total:,} transacciones "
        f"en total:\n{lineas}\n\n---\n\n")


def tipos_resumen(json_text, tope=3):
    """
    Convierte el JSON de tipos de transaccion en prosa breve.
    Al agregar varios lotes, SQLite concatena los JSON de cada uno, asi que
    puede llegar mas de un objeto en el mismo texto y hay que sumarlos.
    """
    acumulado = {}
    decoder = json.JSONDecoder()
    texto = (json_text or "").strip()
    pos = 0
    while pos < len(texto):
        try:
            obj, fin = decoder.raw_decode(texto, pos)
        except ValueError:
            break
        if isinstance(obj, dict):
            for k, v in obj.items():
                acumulado[k] = acumulado.get(k, 0) + v
        pos = fin
        while pos < len(texto) and texto[pos] in ", \n":
            pos += 1
    if not acumulado:
        return "sin registro"
    orden = sorted(acumulado.items(), key=lambda x: -x[1])[:tope]
    return ", ".join(f"{k.replace('_', ' ').lower()} ({v:,})" for k, v in orden)


# ─────────────────────────────────────────────────────────────────

def doc_validaciones(con):
    total = con.execute("SELECT SUM(transactions) FROM log_batches").fetchone()[0]
    filas = con.execute("""
        SELECT validation_id,
               SUM(executions) AS executions,
               ROUND(100.0 * SUM(executions) / ?, 1) AS coverage_pct,
               ROUND(SUM(avg_position * executions) / NULLIF(SUM(executions),0), 1) AS avg_position,
               ROUND(100.0 * SUM(in_declined) / NULLIF(SUM(executions),0), 1) AS declined_pct,
               GROUP_CONCAT(transaction_types) AS transaction_types,
               MAX(meaning) AS meaning
        FROM validations GROUP BY validation_id ORDER BY avg_position""", (total,)).fetchall()

    universales = [f for f in filas if f["coverage_pct"] >= 95]
    condicionales = [f for f in filas if f["coverage_pct"] < 95]

    out = encabezado(
        con, "Validaciones de negocio del autorizador",
        "Cada autorización de tarjeta atraviesa una secuencia de validaciones que el "
        "autorizador registra por número al cerrar la transacción. Este documento es el "
        "catálogo de las que se observaron en producción, ordenado por el momento en que "
        "aparecen en la secuencia.\n\n"
        "El log entrega el número y la posición, no el nombre. Dar significado de negocio a "
        "cada identificador requiere documentación del vendor o una sesión con el equipo de "
        "tarjetas, y es trabajo pendiente.")

    out += (f"## Panorama\n\n"
            f"Se identificaron {len(filas)} validaciones distintas sobre {total:,} transacciones. "
            f"De ellas, {len(universales)} se ejecutan prácticamente en toda transacción y "
            f"{len(condicionales)} dependen del caso.\n\n")

    out += ("## Validaciones universales\n\n"
            "Se ejecutan en 95 por ciento o más de las transacciones. Forman el troncal del "
            "ciclo de autorización.\n\n"
            "| Orden | ID | Ejecuciones | Cobertura | Presencia en rechazos | Significado |\n"
            "|-------|----|-------------|-----------|----------------------|-------------|\n")
    for f in universales:
        out += (f"| {f['avg_position']:.0f} | `{f['validation_id']}` | {f['executions']:,} | "
                f"{f['coverage_pct']:.1f}% | {f['declined_pct']:.1f}% | "
                f"{f['meaning'] or 'Pendiente de documentar'} |\n")

    out += ("\n## Validaciones condicionales\n\n"
            "Se ejecutan sólo bajo ciertas condiciones de la transacción. La columna de tipos "
            "muestra dónde aparecen con más frecuencia, y es la mejor pista disponible sobre "
            "qué controlan.\n\n"
            "| Orden | ID | Ejecuciones | Cobertura | Dónde aparece |\n"
            "|-------|----|-------------|-----------|---------------|\n")
    for f in condicionales:
        out += (f"| {f['avg_position']:.0f} | `{f['validation_id']}` | {f['executions']:,} | "
                f"{f['coverage_pct']:.1f}% | {tipos_resumen(f['transaction_types'])} |\n")

    out += ("\n---\n\n## Lo que estas validaciones NO son\n\n"
            "Ninguna de ellas es criptográfica. El autorizador no calcula el NIP, ni el CVV, "
            "ni el CVV2, ni el criptograma EMV: los recibe ya resueltos del sistema InterAct, "
            "que es el front-end ISO 8583 de la plataforma y ejecuta esa validación contra el "
            "HSM antes de entregar el mensaje. El autorizador solo lee el resultado.\n\n"
            "Los campos que traen ese resultado, y el número de transacciones donde la "
            "validación sí aplicó, son estos. El valor `FF` significa que no aplicaba.\n\n"
            "| Campo | Qué valida | Transacciones donde aplicó | Dónde aplica |\n"
            "|-------|------------|---------------------------|---------------|\n")
    significados = {
        "PINRc": "El NIP",
        "CVCRc": "El CVV de banda o chip",
        "CVC2Rc": "El CVV2 impreso",
        "ARQCRc": "El criptograma EMV",
        "CAVVRc": "La autenticación 3D Secure",
        "EMVScriptRc": "El script EMV enviado a la tarjeta",
    }
    for r in con.execute("""
            SELECT field, SUM(volume) AS total FROM hsm_applied
            GROUP BY field ORDER BY total DESC"""):
        destino = con.execute("""
            SELECT transaction_type, SUM(volume) v FROM hsm_applied WHERE field = ?
            GROUP BY transaction_type ORDER BY v DESC LIMIT 3""", (r["field"],)).fetchall()
        donde = ", ".join(f"{d['transaction_type'].replace('_',' ').lower()} ({d['v']:,})"
                          for d in destino)
        out += (f"| `{r['field']}` | {significados.get(r['field'], 'Sin catalogar')} | "
                f"{r['total']:,} | {donde} |\n")
    out += ("\nEsa tabla verifica la política que InterAct declara en prosa: el NIP solo se "
            "valida en cajero, y en punto de venta el CVV se valida cuando hubo banda o chip. "
            "Las cifras de ambos sistemas coinciden.\n")

    out += ("\n---\n\n## Cómo leer la posición\n\n"
            "La posición es el promedio del lugar que ocupa la validación dentro de la lista "
            "que el autorizador emite al cerrar cada transacción. Una posición baja indica que "
            "la validación corre temprano, cuando todavía no se conoce el resultado del core. "
            "Una posición alta indica que corre al final, ya con la respuesta del core en mano.\n\n"
            "La presencia en rechazos no implica causalidad. Una validación que aparece en el "
            "90 por ciento de los rechazos puede ser simplemente una validación universal que "
            "también corre en las aprobaciones. Para atribuir causa hay que cruzar contra el "
            "código de respuesta, y eso vive en `codigos-respuesta.md`.\n")
    return out


def doc_codigos(con):
    out = encabezado(
        con, "Códigos de respuesta del autorizador",
        "El autorizador responde a la red de marca con un código ISO 8583 de dos dígitos. "
        "Ese código no lo inventa: en la mayoría de los casos lo deriva del código de retorno "
        "que le entrega el core Informix. Este documento recoge ambos catálogos y la regla de "
        "traducción entre ellos.")

    out += ("## Traducción del código del core al código de la red\n\n"
            "Esta es la regla de negocio central del documento. La columna de significado en el "
            "core proviene del `codret_dictionary` del brain de Informix, cruzada en tiempo de "
            "construcción.\n\n"
            "| Código del core | Significado en el core | Respuesta ISO | Qué ve el cliente | Volumen |\n"
            "|-----------------|------------------------|---------------|-------------------|--------|\n")
    for r in con.execute("""
            SELECT h.host_code, MAX(h.core_meaning) AS core_meaning, h.iso_rc,
                   (SELECT MAX(description) FROM response_codes r WHERE r.iso_rc = h.iso_rc)
                     AS description,
                   SUM(h.volume) AS volume
            FROM host_response_map h
            GROUP BY h.host_code, h.iso_rc ORDER BY volume DESC"""):
        significado = (r["core_meaning"] or "Sin registro en el diccionario del core").strip()
        out += (f"| `{r['host_code']}` | {significado} | `{r['iso_rc']}` | "
                f"{r['description']} | {r['volume']:,} |\n")

    out += ("\nEl autorizador rellena con ceros a la izquierda el código de tres dígitos que "
            "emite el core hasta dejarlo en cinco. Por eso el `400` del diccionario de Informix "
            "aparece aquí como `00400`.\n\n"
            "Dos salvedades sobre la columna del core. La entrada de `00000` en el diccionario "
            "de Informix quedó con una descripción imprecisa, tomada de una muestra ajena a la "
            "ruta de tarjetas; la evidencia del propio diccionario muestra que el valor "
            "significa que el procedure terminó correctamente. Y la entrada de `00005` proviene "
            "de dominios que nada tienen que ver con autorización, así que su significado en "
            "esta ruta está sin confirmar pese a aparecer 120 veces.\n\n")

    out += ("## Códigos ISO observados\n\n"
            "| Código | Significado | Volumen | Participación |\n"
            "|--------|-------------|---------|---------------|\n")
    for r in con.execute("""
            SELECT iso_rc, MAX(description) AS description, SUM(volume) AS volume,
                   ROUND(100.0 * SUM(volume) / (SELECT SUM(volume) FROM response_codes), 2)
                     AS share_pct
            FROM response_codes GROUP BY iso_rc ORDER BY volume DESC"""):
        out += (f"| `{r['iso_rc']}` | {r['description']} | {r['volume']:,} | "
                f"{r['share_pct']:.1f}% |\n")

    out += ("\n## Resultado por tipo de transacción\n\n"
            "| Tipo de transacción | Total | Aprobadas | Tasa de aprobación |\n"
            "|---------------------|-------|-----------|--------------------|\n")
    for r in con.execute("""
            SELECT label, SUM(volume) AS total,
                   SUM(CASE WHEN iso_rc='00' THEN volume ELSE 0 END) AS ok
            FROM transaction_outcomes GROUP BY label ORDER BY total DESC"""):
        pct = 100.0 * r["ok"] / r["total"] if r["total"] else 0
        etiqueta = r["label"].replace("_", " ").capitalize()
        out += f"| {etiqueta} | {r['total']:,} | {r['ok']:,} | {pct:.1f}% |\n"

    out += ("\n## Desglose de rechazos\n\n"
            "| Tipo de transacción | Resultado | Código ISO | Volumen |\n"
            "|---------------------|-----------|------------|--------|\n")
    for r in con.execute(
            "SELECT label, outcome, iso_rc, SUM(volume) AS volume FROM transaction_outcomes "
            "WHERE iso_rc != '00' GROUP BY label, outcome, iso_rc "
            "ORDER BY volume DESC LIMIT 25"):
        etiqueta = r["label"].replace("_", " ").capitalize()
        resultado = r["outcome"].replace("_", " ").capitalize()
        out += f"| {etiqueta} | {resultado} | `{r['iso_rc']}` | {r['volume']:,} |\n"
    return out


def doc_vocabulario(con):
    out = encabezado(
        con, "Vocabulario del autorizador e-global",
        "Términos, funciones y catálogos que el autorizador usa en su operación diaria, "
        "extraídos de su propio log. Es el punto de partida para cruzar contra el vocabulario "
        "empresarial del banco conforme a la Regla V1.")

    out += "## Funciones del autorizador por categoría\n\n"
    for d in con.execute(
            "SELECT category, COUNT(DISTINCT name) n, SUM(invocations) inv "
            "FROM authorizer_functions GROUP BY category ORDER BY inv DESC"):
        out += (f"### {d['category'].replace('-', ' ').capitalize()}\n\n"
                f"{d['n']} funciones, {d['inv']:,} invocaciones.\n\n"
                "| Función | Invocaciones | Por transacción | Latencia media | Descripción |\n"
                "|---------|--------------|-----------------|----------------|-------------|\n")
        for f in con.execute("""
                SELECT name, SUM(invocations) AS invocations,
                       ROUND(AVG(calls_per_txn), 2) AS calls_per_txn,
                       ROUND(SUM(avg_ms * invocations) / NULLIF(SUM(invocations),0), 2) AS avg_ms,
                       MAX(description) AS description
                FROM authorizer_functions WHERE category = ?
                GROUP BY name ORDER BY invocations DESC""", (d["category"],)):
            ms = f"{f['avg_ms']:.1f} ms" if f["avg_ms"] is not None else "sin medir"
            out += (f"| `{f['name']}` | {f['invocations']:,} | {f['calls_per_txn']:.2f} | {ms} | "
                    f"{f['description'] or 'Pendiente de documentar'} |\n")
        out += "\n"

    out += ("## Tipos de transacción\n\n"
            "| Tipo | Código interno | Mensaje ISO | Producto | Volumen |\n"
            "|------|----------------|-------------|----------|--------|\n")
    for r in con.execute(
            "SELECT label, tipotran, messtype, product, SUM(volume) AS volume "
            "FROM transaction_types GROUP BY label, tipotran, messtype, product "
            "ORDER BY volume DESC"):
        out += (f"| {r['label'].replace('_', ' ').capitalize()} | `{r['tipotran']}` | "
                f"`{r['messtype']}` | `{r['product']}` | {r['volume']:,} |\n")

    out += ("\n## Modos de entrada en el punto de venta\n\n"
            "| Código | Descripción | Volumen | Participación |\n"
            "|--------|-------------|---------|---------------|\n")
    for r in con.execute(
            "SELECT code, MAX(description) AS description, SUM(volume) AS volume, "
            "       ROUND(100.0*SUM(volume)/(SELECT SUM(volume) FROM pos_entry_modes),2) AS share_pct "
            "FROM pos_entry_modes GROUP BY code ORDER BY volume DESC"):
        desc = (r["description"] or "Sin descripción").capitalize()
        out += f"| `{r['code']}` | {desc} | {r['volume']:,} | {r['share_pct']:.1f}% |\n"

    out += ("\n## Banderas de contexto de la transacción\n\n"
            "Marcadores que el autorizador imprime cuando la transacción cumple cierta "
            "condición. Describen el perfil del tráfico real del banco.\n\n"
            "| Bandera | Transacciones | Participación |\n"
            "|---------|---------------|---------------|\n")
    for r in con.execute(
            "SELECT flag, SUM(volume) AS volume, "
            "       ROUND(100.0*SUM(volume)/(SELECT SUM(transactions) FROM log_batches),2) AS share_pct "
            "FROM context_flags GROUP BY flag ORDER BY volume DESC"):
        out += (f"| {r['flag'].replace('_', ' ').capitalize()} | {r['volume']:,} | "
                f"{r['share_pct']:.1f}% |\n")

    out += ("\n## Tokens propietarios del mensaje ISO\n\n"
            "Campos privados que viajan dentro del mensaje. El estado indica si el autorizador "
            "los encontró, no los encontró, o los pasó sin interpretar.\n\n"
            "| Token | Estado | Volumen |\n"
            "|-------|--------|--------|\n")
    for r in con.execute(
            "SELECT token, status, SUM(volume) AS volume FROM iso_tokens "
            "GROUP BY token, status ORDER BY volume DESC"):
        out += f"| `{r['token']}` | {r['status'].capitalize()} | {r['volume']:,} |\n"

    out += ("\n## Giros de negocio más frecuentes\n\n"
            "Los veinte códigos de giro de comercio con más tráfico.\n\n"
            "| Giro | Transacciones |\n|------|---------------|\n")
    for r in con.execute(
            "SELECT mcc, SUM(volume) AS volume FROM merchant_categories "
            "GROUP BY mcc ORDER BY volume DESC LIMIT 20"):
        out += f"| `{r['mcc']}` | {r['volume']:,} |\n"
    return out


def main():
    if not DB_PATH.exists():
        print(f"[!] falta {DB_PATH} — ejecuta antes digital-brain/build-brain.py")
        return 1
    con = conectar()
    documentos = [
        (KB / "rules" / "validaciones-autorizador.md", doc_validaciones(con)),
        (KB / "rules" / "codigos-respuesta.md", doc_codigos(con)),
        (KB / "vocab" / "vocabulario-autorizador.md", doc_vocabulario(con)),
    ]
    for ruta, contenido in documentos:
        ruta.parent.mkdir(parents=True, exist_ok=True)
        ruta.write_text(contenido, encoding="utf-8")
        print(f"  {ruta.relative_to(SYSTEM_DIR)}  ({len(contenido):,} caracteres)")
    con.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
