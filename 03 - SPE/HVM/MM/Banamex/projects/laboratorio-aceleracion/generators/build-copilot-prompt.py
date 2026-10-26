#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
build-copilot-prompt.py — Genera prompt-copilot-deck.md desde lab-brain.db.

Produce el guion completo para pedirle a Copilot un deck de 5 láminas
ejecutivas. El prompt lleva los datos embebidos para que Copilot no tenga que
inventar nada: el brain es la fuente de verdad, no la memoria del modelo.

Uso:  PYTHONUTF8=1 python build-copilot-prompt.py
"""
import argparse
import datetime as dt
import io
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE / "digital-brain"))

from brain import LabBrain  # noqa: E402

LOGOS = ("C:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/"
         "Solutioning/Design - Studio/logos")

# Dos marcas posibles. La de Accenture es la del Design Studio para material que
# comunica la marca Accenture; la de Banamex es la paleta del cliente.
MARCAS = {
    "accenture": {
        "nombre": "Accenture",
        "ancla": "#1C0032",
        "senal": "#A100FF",
        "papel": "#FFFFFF",
        "plano": "#F8F4FF",
        "trazo": "rgba(161, 0, 255, 0.18)",
        "texto": "#1A1A1A",
        "muted": "#666666",
        "color_ancla": "morado profundo",
        "color_banda": "morada tenue",
        "tipografia": "Segoe UI, con Calibri y Arial como alternativas",
        "logo": ("Accenture_logo_white_letters.png sobre fondos oscuros, "
                 "Accenture_logo_hd.png sobre blanco"),
        "nota": ("El morado vibrante es el acento icónico de la marca. Úsalo solo sobre el "
                 "morado profundo, nunca sobre blanco."),
    },
    "banamex": {
        "nombre": "Banamex",
        "ancla": "#004785",
        "senal": "#EE3124",
        "papel": "#FFFFFF",
        "plano": "#EEF3F9",
        "trazo": "#D6D7D6",
        "texto": "#1A1A1A",
        "muted": "#5A6B7C",
        "color_ancla": "azul ancla",
        "color_banda": "azul tenue",
        "tipografia": "Calibri, con Arial como alternativa",
        "logo": "Sin logotipo del cliente disponible en el Design Studio",
        "nota": ("El rojo es el color más distintivo de la marca. Úsalo solo sobre el azul "
                 "ancla, nunca sobre blanco."),
    },
}

MESES = ("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
         "agosto", "septiembre", "octubre", "noviembre", "diciembre")


def larga(iso: str) -> str:
    d = dt.date.fromisoformat(iso)
    return f"{d.day} de {MESES[d.month - 1]} de {d.year}"


def main(marca_id: str = "accenture"):
    m = MARCAS[marca_id]
    out = BASE / ("prompt-copilot-deck.md" if marca_id == "banamex"
                  else "prompt-copilot-deck-acn.md")
    b = LabBrain()
    try:
        c = b.contrato()
        fte = b.fte()
        o: list[str] = []
        w = o.append

        w("# Guion para Copilot — Deck ejecutivo del Laboratorio de Aceleración")
        w(f"## Versión con identidad {m['nombre']}")
        w("")
        w(f"> Generado el {larga(dt.date.today().isoformat())} desde `lab-brain.db`.")
        w("> No editar a mano: se regenera con `generators/build-copilot-prompt.py`.")
        w("")
        w("**Cómo usarlo.** Abre PowerPoint, invoca Copilot y pega todo lo que viene después de "
          "la línea divisoria. Está escrito para que Copilot no tenga que buscar ni inferir "
          "nada: todos los datos van embebidos y verificados contra el Anexo B firmado.")
        w("")
        w("**Antes de compartir.** Este deck es interno. La lámina 1 incluye modelo económico y "
          "penalizaciones, y la 2 distingue lo contratado de lo que no. Si va a salir del equipo "
          "de delivery, hay que sanitizarlo primero.")
        w("")
        w("---")
        w("")

        # =================== encabezado del prompt ===================
        w("Necesito una presentación de **exactamente 5 láminas**, en español de México, para un "
          "comité ejecutivo. Audiencia: dirección de Accenture y liderazgo de delivery. Tiempo de "
          "exposición: 10 minutos, dos minutos por lámina.")
        w("")
        w("## Reglas que aplican a todas las láminas")
        w("")
        w("- **No inventes ningún dato.** Usa solo lo que te doy. Si algo falta, deja el espacio "
          "en blanco y anótalo como dato pendiente en las notas del orador.")
        w("- **Nada de tarifas, costos por persona ni precios unitarios.** No los tienes y no se "
          "deben estimar.")
        w("- **No incluyas nombres de personas del cliente ni cargos individuales.** Usa roles "
          "genéricos.")
        w("- Cada lámina lleva un título corto y una frase de bajada que diga la conclusión, no "
          "el tema.")
        w("- Prosa en frases completas. Sin flechas, sin vinetas con símbolos decorativos, sin "
          "emojis. Máximo seis líneas de texto por lámina fuera de las tablas.")
        w("- Las notas del orador llevan el detalle; la lámina lleva lo que se ve de lejos.")
        w("")
        w(f"### Identidad visual: marca {m['nombre']}")
        w("")
        w("Formato 16 por 9. Paleta de cinco roles, sin introducir colores fuera de esta lista:")
        w("")
        w("| Rol | Color | Uso |")
        w("|---|---|---|")
        w(f"| Ancla | `{m['ancla']}` | Paneles de encabezado, barras de tabla, cifras grandes |")
        w(f"| Papel | `{m['papel']}` | Fondo de las láminas |")
        w(f"| Plano | `{m['plano']}` | Superficies secundarias, filas alternas, recuadros |")
        w(f"| Trazo | `{m['trazo']}` | Solo líneas, bordes y separadores. Nunca texto |")
        w(f"| Señal | `{m['senal']}` | Acento: barra superior de 3 puntos, rombos de hito y "
          "numerales de lámina |")
        w(f"| Texto | `{m['texto']}` | Cuerpo sobre papel o plano |")
        w(f"| Texto secundario | `{m['muted']}` | Notas al pie y valores de referencia |")
        w("")
        w(f"- {m['nota']}")
        w("- Todo texto sobre el color ancla va en blanco puro, sin transparencias ni grises.")
        w("- Cada panel de color ancla lleva una barra de 3 puntos en color señal en su borde "
          "superior. Es el único elemento que se repite en todas las láminas.")
        w(f"- Tipografía {m['tipografia']}. Solo dos pesos: negrita para títulos y datos, ligera "
          "para el cuerpo. La jerarquía se hace con peso, no con un tercer color.")
        w("- Nada de recuadros rellenos de color para marcar estado. Si necesitas destacar una "
          "celda, usa un subrayado de 1.5 puntos en color ancla.")
        if marca_id == "accenture":
            w("")
            w("### Logotipo")
            w("")
            w("Coloca el logotipo de Accenture en la esquina inferior derecha de cada lámina, a "
              f"un tamaño discreto. Los archivos están en `{LOGOS}`:")
            w("")
            w(f"- {m['logo']}")
        w("")

        # =================== LÁMINA 1 ===================
        w("---")
        w("")
        w("## Lámina 1. Resumen ejecutivo del contrato")
        w("")
        w("Título sugerido: **Qué contratamos**. La bajada debe decir que es un laboratorio "
          "aislado de desarrollo, no un entorno productivo, y que esa distinción gobierna todo "
          "lo demás.")
        w("")
        w("Datos exactos:")
        w("")
        w("| Concepto | Valor |")
        w("|---|---|")
        w(f"| Instrumento | {c['instrumento']} |")
        w(f"| Servicio | {c['servicio']} |")
        w(f"| Vigencia | Tres años, del {larga(c['vigencia_inicio'])} al {larga(c['vigencia_fin'])} |")
        w(f"| Región | {c['region_aws']} |")
        w(f"| Ventana de servicio | {c['horario']} |")
        w(f"| Componentes | {c['componentes']} |")
        w(f"| Cuota de arranque | {int(c['cuota_arranque_usd']):,} USD más IVA, exigible solo al "
          "acreditar en sesión en vivo que el laboratorio está listo |")
        w("| Modelo económico | Consumo de nube a precio de lista más un servicio mensual que va "
          "del 37 al 45 por ciento del consumo según la talla |")
        w(f"| Penalizaciones | Tope de {c['pena_tope_mensual_pct']} por ciento del monto mensual |")
        w(f"| Propiedad intelectual | {c['propiedad_intelectual']} |")
        w("")
        w("**El mensaje central de la lámina**, que debe quedar visualmente destacado:")
        w("")
        w(f"> {c['exclusion_critica']}")
        w("")
        w("Y los cinco entregables formales, en una tabla compacta:")
        w("")
        w("| # | Entregable | Frecuencia | Vence |")
        w("|---|---|---|---|")
        for d in b.entregables_contractuales():
            w(f"| {d['num']} | {d['nombre']} | {d['frecuencia']} | "
              f"{larga(d['vence']) if d['vence'] else 'Recurrente'} |")
        w("")
        w("En las notas del orador: la aceptación opera por silencio a los diez días hábiles, y "
          "los entregables 1 y 2 son los únicos con fecha dura.")
        w("")

        # =================== LÁMINA 2 ===================
        w("---")
        w("")
        w("## Lámina 2. Calendario")
        w("")
        w("Título sugerido: **Cuatro semanas para una fecha que no se mueve**. La bajada debe "
          "decir que el Anexo no fija plazo de implementación y que su única fecha es el primer "
          "mes, por eso la ventana se ajustó a cuatro semanas.")
        w("")
        w("Construye un **diagrama de Gantt horizontal** con eje semanal del 12 de octubre de "
          "2026 al 11 de enero de 2027. Cuatro barras:")
        w("")
        w("| Componente | Desde | Hasta | Tratamiento |")
        w("|---|---|---|---|")
        for f in b.fases():
            trat = (f"{m['color_ancla'].capitalize()} sólido, está en la ruta crítica" if f["critica"]
                    else ("Gris claro con borde, continúa más allá del eje" if f["id"] == "OPE"
                          else "Gris claro, no está contratado"))
            w(f"| {f['id']} {f['nombre']} | {larga(f['inicio'])} | {larga(f['fin'])} | {trat} |")
        w("")
        w("**Importante sobre la barra de Operación y Soporte:** el eje termina en enero pero el "
          "servicio corre hasta octubre de 2029. Etiquétala para que se entienda que continúa, "
          "no la cortes sin avisar.")
        w("")
        w("Sombrea las primeras cuatro semanas, del 12 de octubre al 6 de noviembre, con una "
          f"banda {m['color_banda']} rotulada **Implementación, 4 semanas**.")
        w("")
        w("Marca los hitos con rombos en color acento:")
        w("")
        w("| Hito | Fecha | Qué es |")
        w("|---|---|---|")
        for h in b.hitos():
            w(f"| {h['id']} | {larga(h['fecha'])} | {h['nombre']} |")
        w("")
        w("En las notas del orador: los hitos H3 y H4 caen el mismo día, y el H4 no tiene fecha "
          "en el contrato, es la que proponemos nosotros.")
        w("")

        # =================== LÁMINA 3 ===================
        w("---")
        w("")
        w("## Lámina 3. Equipo")
        w("")
        w("Título sugerido: **Equipo dimensionado al ambiente, no al patrón**. La bajada debe "
          "decir que los niveles de servicio son de un ambiente de desarrollo y el equipo se "
          "dimensionó en consecuencia.")
        w("")
        w(f"Dos cifras grandes y legibles de lejos: **{fte['setup']:.2f} FTE** en implementación y "
          f"**{fte['steady']:.2f} FTE** en operación, sobre {len(b.roles())} perfiles.")
        w("")
        w("Tabla de perfiles, ordenada como viene:")
        w("")
        w("| Rol | Nivel | Tier | Ubicación | FTE implementación | FTE operación |")
        w("|---|---|---|---|---|---|")
        for r in b.roles():
            w(f"| {r['rol']} | {r['nivel']} | {r['tier']} | {r['ubicacion']} | "
              f"{r['fte_setup']:.2f} | {r['fte_steady']:.2f} |")
        w(f"| **Total** | | | | **{fte['setup']:.2f}** | **{fte['steady']:.2f}** |")
        w("")
        w("Agrega un recuadro lateral con tres frases cortas que expliquen por qué el equipo es "
          "más chico que el patrón de banca del guideline:")
        w("")
        w("- No hay datos reales de clientes ni ruta al core real.")
        w("- La ventana de servicio es de lunes a viernes de 9 a 18 horas, y el contrato no "
          "menciona operación continua en ningún lugar.")
        w("- No hay recuperación ante desastres en el alcance.")
        w("")
        w("En las notas del orador: estos FTE son un patrón de referencia para dimensionar. El "
          "headcount formal lo calcula IMS Estimation y se formaliza en el SP-11. Y hay un "
          "supuesto pendiente de confirmar por escrito, que el reloj de severidad 1 y 2 corra "
          "dentro de la ventana de servicio; si no se cumple, el equipo crece más de un FTE.")
        w("")

        # =================== LÁMINA 4 ===================
        w("---")
        w("")
        w("## Lámina 4. Responsabilidades")
        w("")
        w("Título sugerido: **Un solo responsable por entregable**. La bajada debe decir que cada "
          "entregable tiene un dueño único que responde, y que el resto ejecuta, consulta o se "
          "entera.")
        w("")
        w("Construye una **matriz RACI**: entregables en las filas, roles en las columnas. "
          "Usa las iniciales A, R, C e I. Destaca la A con negrita o con un subrayado de color, "
          "nunca con un recuadro relleno.")
        w("")
        rr = b.roles_en_raci()
        m = b.raci_matriz()
        w("Columnas, en este orden:")
        w("")
        for r in rr:
            w(f"- **{r['id']}**: {r['rol']}")
        w("")
        w("Matriz:")
        w("")
        w("| Entregable | " + " | ".join(r["id"] for r in rr) + " |")
        w("|---" * (len(rr) + 1) + "|")
        for ent in b.entregables_raci():
            fila = " | ".join(m.get(ent, {}).get(r["id"], "") for r in rr)
            w(f"| {ent} | {fila} |")
        w("")
        w("Leyenda al pie: A es quien responde, R quien ejecuta, C a quien se consulta, I a quien "
          "se informa.")
        w("")

        # =================== LÁMINA 5 ===================
        w("---")
        w("")
        w("## Lámina 5. Detalle de la implementación")
        w("")
        w("Título sugerido: **Las cuatro semanas, actividad por actividad**. La bajada debe decir "
          "dónde está el cuello de botella.")
        w("")
        w("Organiza la lámina en **cuatro columnas, una por semana**. Encabeza cada columna con "
          "el rango de fechas y el número de actividades. Dentro de cada columna lista las "
          "actividades por su identificador y un resumen de cinco a ocho palabras. Marca en "
          "negrita las que están en la ruta crítica.")
        w("")
        criticas = {a["id"] for a in b.ruta_critica()}
        for sm in b.carga_semanal():
            w(f"### Semana {sm['num']}: del {larga(sm['inicio'])} al {larga(sm['fin'])} "
              f"({sm['actividades']} actividades)")
            w("")
            w(f"Foco: {sm['foco']}")
            w("")
            w("| ID | Actividad | Ruta crítica | Componente |")
            w("|---|---|---|---|")
            for a in b.actividades_por_semana(sm["num"]):
                w(f"| {a['id']} | {a['actividad']} | "
                  f"{'Sí' if a['id'] in criticas else ''} | {a['fase']} |")
            w("")
        w("Al pie de la lámina, una franja con esta frase, que es la conclusión:")
        w("")
        w("> La semana 2 concentra la mayor carga y seis de sus actividades están en la ruta "
          "crítica. Tres de ellas no dependen de trabajo técnico nuestro: dependen de que el "
          "banco designe usuarios, dé una agenda con Arquitectura y Seguridad, y cierre tres "
          "decisiones de seguridad.")
        w("")
        w("En las notas del orador: la ruta crítica completa tiene "
          f"{len(b.ruta_critica())} pasos y termina en la sesión en vivo que acredita los cuatro "
          "criterios y vuelve exigible la cuota de arranque.")
        w("")
        w("---")
        w("")
        w("Cuando termines, dime qué datos dejaste en blanco por no tenerlos.")
        w("")

        doc = "\n".join(o)
        io.open(out, "w", encoding="utf-8").write(doc)
        print(f"Generado: {out}")
        print(f"  {len(doc):,} caracteres, {len(o)} líneas")
    finally:
        b.close()


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Guion de Copilot para el deck ejecutivo")
    ap.add_argument("--marca", choices=sorted(MARCAS), default="accenture")
    main(ap.parse_args().marca)
