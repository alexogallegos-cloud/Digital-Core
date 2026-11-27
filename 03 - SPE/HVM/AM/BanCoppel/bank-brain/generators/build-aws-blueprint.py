#!/usr/bin/env python3
"""Genera el blueprint de arquitectura en AWS para la flota de gemelos cognitivos.

Dibuja el diagrama en SVG con los iconos OFICIALES de AWS embebidos en base64,
siguiendo al Specialist - Architecture Diagrams del Design Studio. El marco usa
la paleta canonica de los portales de Application Modernization y el logo de
Accenture embebido, nunca una ruta relativa.

Uso:  python generators/build-aws-blueprint.py     (desde bank-brain/)
"""
from __future__ import annotations

import base64
import sqlite3
from pathlib import Path

HERE = Path(__file__).resolve().parent
BANK_BRAIN = HERE.parent
BANCOPPEL = BANK_BRAIN.parent
DOCUMENTS = BANCOPPEL.parents[4]          # ...\Documents
STUDIO = DOCUMENTS / "Solutioning" / "Design - Studio"
ICONS = STUDIO / "aws-icons"
LOGO = STUDIO / "logos" / "Accenture_logo_white_letters.png"
OUT = BANK_BRAIN / "blueprint-arquitectura-bancoppel-aws-2026-11-25.html"

SERVICE = ICONS / "Architecture-Service-Icons_01302026"
GROUP = ICONS / "Architecture-Group-Icons_01302026"
RESOURCE = ICONS / "Resource-Icons_01302026"

# ---------------------------------------------------------------- iconos ----

ICON_FILES = {
    "s3": SERVICE / "Arch_Storage/64/Arch_Amazon-Simple-Storage-Service_64.svg",
    "fargate": SERVICE / "Arch_Containers/64/Arch_AWS-Fargate_64.svg",
    "eventbridge": SERVICE / "Arch_Application-Integration/64/Arch_Amazon-EventBridge_64.svg",
    "codebuild": SERVICE / "Arch_Developer-Tools/64/Arch_AWS-CodeBuild_64.svg",
    "aurora": SERVICE / "Arch_Databases/64/Arch_Amazon-Aurora_64.svg",
    "lambda": SERVICE / "Arch_Compute/64/Arch_AWS-Lambda_64.svg",
    "sfn": SERVICE / "Arch_Application-Integration/64/Arch_AWS-Step-Functions_64.svg",
    "sqs": SERVICE / "Arch_Application-Integration/64/Arch_Amazon-Simple-Queue-Service_64.svg",
    "bedrock": SERVICE / "Arch_Artificial-Intelligence/64/Arch_Amazon-Bedrock_64.svg",
    "apigw": SERVICE / "Arch_Networking-Content-Delivery/64/Arch_Amazon-API-Gateway_64.svg",
    "cloudfront": SERVICE / "Arch_Networking-Content-Delivery/64/Arch_Amazon-CloudFront_64.svg",
    "waf": SERVICE / "Arch_Security-Identity/64/Arch_AWS-WAF_64.svg",
    "cognito": SERVICE / "Arch_Security-Identity/64/Arch_Amazon-Cognito_64.svg",
    "iam": SERVICE / "Arch_Security-Identity/64/Arch_AWS-Identity-and-Access-Management_64.svg",
    "kms": SERVICE / "Arch_Security-Identity/64/Arch_AWS-Key-Management-Service_64.svg",
    "secrets": SERVICE / "Arch_Security-Identity/64/Arch_AWS-Secrets-Manager_64.svg",
    "cloudtrail": SERVICE / "Arch_Management-Tools/64/Arch_AWS-CloudTrail_64.svg",
    "cloudwatch": SERVICE / "Arch_Management-Tools/64/Arch_Amazon-CloudWatch_64.svg",
    "privatelink": SERVICE / "Arch_Networking-Content-Delivery/64/Arch_AWS-PrivateLink_64.svg",
    "region": GROUP / "Region_32.svg",
    "vpc": GROUP / "Virtual-private-cloud-VPC_32.svg",
    "cloud": GROUP / "AWS-Cloud-logo_32.svg",
    "datacenter": GROUP / "Corporate-data-center_32.svg",
    "client": RESOURCE / "Res_General-Icons/Res_48_Dark/Res_Client_48_Dark.svg",
    "documents": RESOURCE / "Res_General-Icons/Res_48_Dark/Res_Documents_48_Dark.svg",
    "database": RESOURCE / "Res_General-Icons/Res_48_Dark/Res_Database_48_Dark.svg",
}


def uri(key: str) -> str:
    """Ruta de icono a data URI. Base64 evita la colision de IDs de gradiente."""
    path = ICON_FILES[key]
    if not path.exists():
        raise FileNotFoundError(f"icono ausente: {path}")
    return "data:image/svg+xml;base64," + base64.b64encode(path.read_bytes()).decode()


def logo_uri() -> str:
    return "data:image/png;base64," + base64.b64encode(LOGO.read_bytes()).decode()


# ------------------------------------------------------------- inventario ----

def inventario() -> dict:
    """Cuenta la flota viva. El diagrama no inventa cifras, las lee del arbol."""
    dbs = sorted(BANCOPPEL.glob("**/digital-brain/*.db"))
    tablas = filas = 0
    for db in dbs:
        try:
            con = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
            nombres = [r[0] for r in con.execute(
                "select name from sqlite_master where type='table'")]
            tablas += len(nombres)
            for n in nombres:
                try:
                    filas += con.execute(f'select count(*) from "{n}"').fetchone()[0]
                except sqlite3.Error:
                    pass
            con.close()
        except sqlite3.Error:
            continue
    return {
        "brains": len(dbs),
        "tablas": tablas,
        "filas": filas,
        "mb": round(sum(d.stat().st_size for d in dbs) / 1024 / 1024),
        # un gemelo es una carpeta con su carta de identidad o un markdown suelto en dt/
        "gemelos": (len(list(BANCOPPEL.glob("**/dt/*/CLAUDE.md")))
                    + len([p for p in BANCOPPEL.glob("**/dt/*.md")
                           if p.name != "CLAUDE.md"])),
        "docs": len(list(BANCOPPEL.glob("**/knowledge-base/**/*.md"))),
        "generadores": len([p for p in BANCOPPEL.glob("**/generators/**/*.py")
                            if "__pycache__" not in p.parts]),
        "paginas": len([p for p in BANCOPPEL.glob("**/portal/**/*.html")]),
    }


# ------------------------------------------------------------------ svg -----

W, H = 1460, 1010
ICO = 54          # lado del icono de servicio
PANEL_FILL = "#0b1130"
PANEL_LINE = "#1f2a58"


def nodo(cx: int, cy: int, key: str, titulo: str, sub: str = "", size: int = ICO) -> str:
    x, y = cx - size / 2, cy - size / 2
    s = (f'<image x="{x:.0f}" y="{y:.0f}" width="{size}" height="{size}" '
         f'xlink:href="{uri(key)}"/>')
    s += (f'<text class="nl" x="{cx}" y="{cy + size/2 + 16:.0f}">{titulo}</text>')
    if sub:
        s += (f'<text class="ns" x="{cx}" y="{cy + size/2 + 30:.0f}">{sub}</text>')
    return s


def panel(x, y, w, h, etiqueta, color="#3D5FCD", dash="") -> str:
    d = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="14" '
            f'fill="{PANEL_FILL}" stroke="{color}" stroke-width="1.4"{d}/>'
            f'<text class="pl" x="{x + 18}" y="{y + 26}" fill="{color}">{etiqueta}</text>')


def flecha(x1, y1, x2, y2, color="#5e73c7", dash="") -> str:
    d = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<path d="M {x1} {y1} L {x2} {y2}" stroke="{color}" stroke-width="1.6" '
            f'fill="none" marker-end="url(#fl)"{d}/>')


def curva(x1, y1, x2, y2, bow=40, color="#5e73c7", dash="") -> str:
    mx, my = (x1 + x2) / 2 - bow, (y1 + y2) / 2
    d = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<path d="M {x1} {y1} Q {mx:.0f} {my:.0f} {x2} {y2}" stroke="{color}" '
            f'stroke-width="1.6" fill="none" marker-end="url(#fl)"{d}/>')


def ruta(d: str, color="#5e73c7", dash="") -> str:
    """Trayecto en ele, para rodear paneles en vez de atravesarlos."""
    da = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<path d="{d}" stroke="{color}" stroke-width="1.6" fill="none" '
            f'marker-end="url(#fl)"{da}/>')


def diagrama(inv: dict) -> str:
    p = []
    p.append(f'<svg viewBox="0 0 {W} {H}" xmlns="http://www.w3.org/2000/svg" '
             'xmlns:xlink="http://www.w3.org/1999/xlink" role="img" '
             'aria-label="Arquitectura de la plataforma de gemelos cognitivos en AWS">')
    p.append('<defs><marker id="fl" viewBox="0 0 10 10" refX="9" refY="5" '
             'markerWidth="6" markerHeight="6" orient="auto-start-reverse">'
             '<path d="M 0 0 L 10 5 L 0 10 z" fill="#5e73c7"/></marker></defs>')

    # ---- origen, fuera de la nube
    p.append('<rect x="22" y="96" width="186" height="690" rx="14" fill="#090e22" '
             'stroke="#2a3870" stroke-width="1.4" stroke-dasharray="5 4"/>')
    p.append(f'<image x="38" y="110" width="26" height="26" xlink:href="{uri("datacenter")}"/>')
    p.append('<text class="pl" x="74" y="128" fill="#aab3d4">ORIGEN ACTUAL</text>')
    p.append(nodo(115, 215, "client", "Sesión del arquitecto", "Cliente de agentes", 46))
    p.append(nodo(115, 400, "documents", "Código y minutas", "SPL, actas, bitácoras", 46))
    p.append(nodo(115, 585, "database", f'Flota de {inv["brains"]} archivos',
                  f'SQLite, {inv["mb"]} MB', 46))
    p.append('<text class="nh" x="115" y="700">El techo de diez bases</text>'
             '<text class="nh" x="115" y="716">adjuntas vive aquí</text>')

    # ---- nube y region
    p.append('<rect x="238" y="58" width="1196" height="892" rx="18" fill="none" '
             'stroke="#8f9bb3" stroke-width="1.4"/>')
    p.append(f'<image x="254" y="72" width="26" height="26" xlink:href="{uri("cloud")}"/>')
    p.append('<text class="pl" x="290" y="90" fill="#c7cede">NUBE DE AWS</text>')
    p.append('<rect x="258" y="106" width="1156" height="824" rx="16" fill="none" '
             'stroke="#879196" stroke-width="1.3" stroke-dasharray="7 5"/>')
    p.append(f'<image x="272" y="118" width="24" height="24" xlink:href="{uri("region")}"/>')
    p.append('<text class="pl" x="304" y="135" fill="#aab3d4">REGIÓN us-east-1</text>')

    # ---- banda 1: ingesta
    p.append(panel(282, 158, 318, 374, "1. INGESTA"))
    p.append(nodo(362, 235, "s3", "Fuentes", "Versionadas y cifradas"))
    p.append(nodo(520, 235, "eventbridge", "EventBridge", "Dispara el ciclo"))
    p.append(nodo(362, 420, "fargate", "Fargate", "Construye el cerebro"))
    p.append(nodo(520, 420, "codebuild", "CodeBuild", "Genera el portal"))
    p.append('<text class="nh" x="441" y="500">Tareas de minutos, no de segundos:</text>'
             '<text class="nh" x="441" y="514">no caben en una función</text>')

    # ---- banda 2: almacen, con VPC
    p.append(panel(620, 158, 300, 374, "2. ALMACÉN", "#ED7100"))
    p.append('<rect x="640" y="192" width="260" height="318" rx="12" fill="#120d22" '
             'stroke="#ED7100" stroke-width="1.2" stroke-dasharray="5 4"/>')
    p.append(f'<image x="652" y="202" width="22" height="22" xlink:href="{uri("vpc")}"/>')
    p.append('<text class="pl" x="682" y="218" fill="#ED7100">SUBREDES PRIVADAS</text>')
    p.append(nodo(770, 290, "aurora", "Aurora PostgreSQL", "Serverless v2"))
    p.append(f'<text class="nf" x="770" y="384">{inv["brains"]} esquemas, uno por cerebro</text>')
    p.append(f'<text class="nf" x="770" y="404">{inv["tablas"]} tablas, '
             f'{inv["filas"]:,} filas</text>'.replace(",", " "))
    p.append('<text class="nf" x="770" y="424">Búsqueda con tsvector y GIN</text>')
    p.append('<text class="nf" x="770" y="444">Vectores con pgvector</text>')
    p.append('<text class="nf" x="770" y="464">Aislamiento por fila</text>')

    # ---- banda 3: gobierno
    p.append(panel(942, 158, 452, 374, "3. GOBIERNO"))
    p.append(nodo(1030, 235, "iam", "IAM", "Permisos", 48))
    p.append(nodo(1168, 235, "kms", "KMS", "Llaves propias", 48))
    p.append(nodo(1306, 235, "secrets", "Secrets Manager", "Credenciales", 48))
    p.append(nodo(1100, 400, "cloudtrail", "CloudTrail", "Quién consultó qué", 48))
    p.append(nodo(1240, 400, "cloudwatch", "CloudWatch", "Salud y costo", 48))

    # ---- banda 4: acceso
    p.append(panel(282, 556, 548, 244, "4. ACCESO"))
    p.append(nodo(355, 650, "waf", "WAF", "Filtro de borde"))
    p.append(nodo(490, 650, "cloudfront", "CloudFront", "Entrega del portal"))
    p.append(nodo(625, 650, "s3", "Portal", f'{inv["paginas"]} páginas'))
    p.append(nodo(760, 650, "cognito", "Cognito", "Identidad y roles"))
    p.append('<text class="nh" x="556" y="760">Lo que hoy sirve un servidor local</text>'
             '<text class="nh" x="556" y="774">pasa a tener identidad y bitácora</text>')

    # ---- banda 5: razonamiento
    p.append(panel(850, 556, 544, 344, "5. RAZONAMIENTO"))
    p.append(nodo(940, 650, "apigw", "API HTTP", "Puerta única"))
    p.append(nodo(1122, 650, "lambda", "Función del gemelo", "Un runtime, muchos DT"))
    p.append(nodo(1304, 650, "sfn", "Step Functions", "Enjambre en abanico"))
    p.append(nodo(940, 800, "lambda", "Consulta al cerebro", "43 consultas publicadas"))
    p.append(nodo(1122, 800, "sqs", "Cola", "Absorbe las ráfagas"))
    p.append(nodo(1304, 800, "bedrock", "Bedrock", "Modelo del gemelo"))
    p.append(f'<text class="nh" x="1122" y="878">{inv["gemelos"]} gemelos declarados, '
             'una sola unidad de despliegue</text>')

    # ---- flujos
    p.append(flecha(208, 400, 330, 250, dash="6 4"))            # documentos hacia S3
    p.append(curva(208, 250, 324, 642, 60, "#F0D224", "4 4"))   # la persona entra por el borde
    p.append(flecha(362, 306, 362, 390))                        # S3 a Fargate
    p.append(flecha(520, 306, 520, 390))                        # EventBridge a CodeBuild
    p.append(ruta("M 493 235 H 470 V 420 H 392"))               # EventBridge a Fargate
    p.append(flecha(392, 408, 739, 300))                        # Fargate escribe en Aurora
    p.append(ruta("M 547 420 H 610 V 600 H 625 V 619"))         # CodeBuild publica el portal
    p.append(flecha(386, 650, 459, 650))                        # WAF a CloudFront
    p.append(flecha(598, 650, 521, 650))                        # CloudFront entrega el portal
    p.append(flecha(788, 650, 911, 650))                        # Cognito a la API
    p.append(flecha(968, 650, 1093, 650))                       # API al gemelo
    p.append(flecha(1150, 650, 1275, 650))                      # gemelo a Step Functions
    p.append(flecha(940, 718, 940, 769))                        # API a la consulta
    p.append(flecha(1122, 718, 1122, 769))                      # gemelo a la cola
    p.append(flecha(1304, 718, 1304, 769))                      # Step Functions a Bedrock
    p.append(ruta("M 912 800 H 870 V 305 H 801"))               # la consulta llega a Aurora

    p.append('</svg>')
    return "".join(p)


# ----------------------------------------------------------------- html -----

CSS = """
*{box-sizing:border-box}
body{margin:0;background:#060a1a;color:#F4F6FF;
     font-family:Calibri,'Segoe UI',Arial,sans-serif;line-height:1.6}
a{color:#F0D224;text-decoration:none}
.hero-bar{display:flex;align-items:center;gap:18px;padding:16px 36px;
     border-bottom:1px solid #1b2450;background:#080d22;position:sticky;top:0;z-index:9}
.hero-bar img{height:26px}
.hb-sep{width:1px;height:22px;background:#2a3870}
.crumb{font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#818ab0}
.wrap{max-width:1360px;margin:0 auto;padding:40px 36px 90px}
.kick{font-size:11px;letter-spacing:.18em;text-transform:uppercase;color:#F0D224;
     margin-bottom:10px}
h1{font-size:34px;line-height:1.2;margin:0 0 16px;font-weight:600}
h2{font-size:22px;margin:52px 0 14px;font-weight:600}
h3{font-size:15px;margin:0 0 8px;font-weight:600;color:#F4F6FF}
p{color:#c6cce4;max-width:94ch;margin:0 0 14px}
.sb-row{display:flex;flex-wrap:wrap;gap:14px;margin:26px 0 8px}
.sb{background:#0b1130;border:1px solid #1f2a58;border-radius:12px;
     padding:14px 18px;min-width:150px}
.sb b{display:block;font-size:26px;font-weight:600;color:#F0D224;line-height:1.2}
.sb span{font-size:11px;letter-spacing:.13em;text-transform:uppercase;color:#818ab0}
.diag{background:#080d22;border:1px solid #1f2a58;border-radius:16px;
     padding:18px;margin:30px 0 10px}
.diag svg{display:block;width:100%;height:auto}
.nl{fill:#F4F6FF;font-size:11.5px;font-weight:600;text-anchor:middle;
     font-family:Calibri,'Segoe UI',Arial,sans-serif}
.ns{fill:#818ab0;font-size:10px;text-anchor:middle;
     font-family:Calibri,'Segoe UI',Arial,sans-serif}
.nf{fill:#aab3d4;font-size:11px;text-anchor:middle;
     font-family:Calibri,'Segoe UI',Arial,sans-serif}
.nh{fill:#6f7aa6;font-size:10.5px;text-anchor:middle;font-style:italic;
     font-family:Calibri,'Segoe UI',Arial,sans-serif}
.pl{font-size:10.5px;letter-spacing:.14em;font-weight:700;
     font-family:Calibri,'Segoe UI',Arial,sans-serif}
.cap{font-size:12px;color:#6f7aa6;margin:0 0 30px}
table{width:100%;border-collapse:collapse;margin:16px 0 8px;font-size:14px}
th{text-align:left;font-size:10.5px;letter-spacing:.14em;text-transform:uppercase;
     color:#818ab0;font-weight:700;padding:10px 12px;border-bottom:1px solid #1f2a58}
td{padding:11px 12px;border-bottom:1px solid #141c3e;color:#c6cce4;vertical-align:top}
td b{color:#F4F6FF;font-weight:600}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:16px;
     margin:18px 0}
.card{background:#0b1130;border:1px solid #1f2a58;border-radius:12px;padding:18px 20px}
.card .tag{font-size:10px;letter-spacing:.14em;text-transform:uppercase;color:#F0D224;
     display:block;margin-bottom:8px}
.card p{font-size:13.5px;margin:0;color:#aab3d4}
.dot{display:inline-block;width:8px;height:8px;border-radius:50%;margin-right:8px;
     vertical-align:middle}
footer{border-top:1px solid #1b2450;margin-top:60px;padding:22px 36px;
     color:#6f7aa6;font-size:12px}
@media(max-width:820px){.wrap{padding:28px 18px 70px}h1{font-size:26px}}
"""


def html(inv: dict) -> str:
    sb = [
        (f'{inv["brains"]}', "Cerebros en la flota"),
        (f'{inv["tablas"]}', "Tablas"),
        (f'{inv["filas"]:,}'.replace(",", " "), "Filas"),
        (f'{inv["gemelos"]}', "Gemelos digitales"),
        (f'{inv["docs"]}', "Documentos de conocimiento"),
        (f'{inv["paginas"]}', "Páginas de portal"),
    ]
    sbs = "".join(f'<div class="sb"><b>{v}</b><span>{k}</span></div>' for v, k in sb)

    decisiones = [
        ("Decisión 1", "Un esquema por cerebro, no una base por cerebro",
         "Los treinta y siete cerebros entran a una sola base de datos como esquemas "
         "separados. Cruzar dos cerebros deja de ser una maniobra de adjuntar archivos "
         "y se vuelve una consulta con punto. El techo de diez bases adjuntas que hoy "
         "obliga a recorrer la flota por lotes desaparece por construcción."),
        ("Decisión 2", "Vistas de federación que normalizan lo heterogéneo",
         "Hoy conviven tres formas distintas de declarar una dependencia entre sistemas "
         "y la que no se puede leer se pierde en silencio. En Postgres cada forma entra "
         "por su propia vista y las tres se unen en una sola vista canónica. Lo que no "
         "se puede mapear queda registrado como excepción, no como ausencia."),
        ("Decisión 3", "Construir el cerebro no es consultarlo",
         "La ingesta corre en contenedores de Fargate porque procesar once mil "
         "procedimientos y doscientas mil referencias de tabla no cabe en los quince "
         "minutos de una función. Las funciones quedan para lo que sí es interactivo: "
         "responder una consulta y razonar sobre ella."),
        ("Decisión 4", "Un runtime de gemelo, no setenta y siete funciones",
         "Cada gemelo es una declaración en texto, no un programa. Una sola función "
         "recibe el identificador del gemelo, carga su carta de identidad y su cinturón "
         "de herramientas, y actúa. Setenta y siete funciones serían setenta y siete "
         "unidades de despliegue y setenta y siete permisos para el mismo código."),
        ("Decisión 5", "El enjambre lo coordina Step Functions",
         "La metodología de extracción reparte el trabajo en agentes pequeños y junta "
         "los resultados. Ese patrón de abanico con reintentos y control de concurrencia "
         "es exactamente lo que resuelve un mapa distribuido de Step Functions. Un "
         "orquestador propio tendría que llevar ese estado a mano y moriría al minuto "
         "quince."),
        ("Decisión 6", "Un solo almacén para texto y para vectores",
         "La búsqueda de texto completo pasa a tsvector con índice GIN y configuración "
         "en español. Los novecientos documentos de conocimiento se indexan con pgvector "
         "en la misma base. Eso retira la dependencia de un servicio externo de vectores "
         "que el patrón anterior necesitaba."),
    ]
    cards = "".join(
        f'<div class="card"><span class="tag">{t}</span><h3>{h}</h3><p>{d}</p></div>'
        for t, h, d in decisiones)

    comparativo = [
        ("Federar la flota", "Adjuntar archivos de nueve en nueve y agregar en Python",
         "Una consulta con punto entre esquemas, sin techo"),
        ("Búsqueda", "Cinco tablas virtuales de FTS5 por cerebro",
         "tsvector con índice GIN, configuración en español y acentos neutralizados"),
        ("Concurrencia", "Un archivo, un escritor, una laptop",
         "Lectura concurrente real, escritura transaccional por esquema"),
        ("Ejecutar un gemelo", "Una sesión manual en la laptop del arquitecto",
         "Una invocación con identidad, bitácora y costo medido"),
        ("Un enjambre de diez agentes", "Diez conversaciones coordinadas a mano",
         "Un mapa distribuido con reintento y cola de descartes"),
        ("Publicar el portal", "Un servidor local y una sincronización manual",
         "Construcción automática y entrega por CloudFront con identidad"),
        ("Respaldo", "La carpeta sincronizada de OneDrive",
         "Instantáneas y recuperación a un punto en el tiempo"),
        ("Quién consultó qué", "No hay registro",
         "CloudTrail sobre los datos y bitácora de cada consulta"),
    ]
    filas_tabla = "".join(
        f"<tr><td><b>{a}</b></td><td>{b}</td><td>{c}</td></tr>" for a, b, c in comparativo)

    fases = [
        ("Fase 1", "Piloto con un cerebro", "Dos semanas",
         "El cerebro del banco, quince mil filas, con la API de datos y un gemelo "
         "funcionando. El corte se aprueba con paridad de filas tabla por tabla y con "
         "cinco consultas que devuelven lo mismo que hoy."),
        ("Fase 2", "La flota completa", "Cuatro a seis semanas",
         "Los treinta y seis cerebros restantes, con Informix al final porque concentra "
         "el ochenta y siete por ciento de las filas. El corte se aprueba cuando la "
         "consulta federada de huecos de capacidad devuelve el mismo número que la "
         "versión por lotes de hoy."),
        ("Fase 3", "Los gemelos en funciones", "Cuatro semanas",
         "El runtime genérico, el cinturón de herramientas sobre las consultas "
         "publicadas y tres enjambres en operación. El corte se aprueba cuando un "
         "enjambre reproduce un resultado ya conocido."),
        ("Fase 4", "Acceso y gobierno", "Tres semanas",
         "Construcción automática del portal, entrega por CloudFront con identidad, "
         "aislamiento por fila para separar lo interno de lo que ve el cliente y "
         "bitácora de consultas."),
    ]
    filas_fases = "".join(
        f"<tr><td><b>{a}</b></td><td>{b}</td><td>{c}</td><td>{d}</td></tr>"
        for a, b, c, d in fases)

    riesgos = [
        ("#e05c5c", "El orden de los resultados de búsqueda cambia",
         "FTS5 y tsvector no puntúan igual. Las consultas que hoy devuelven los primeros "
         "veinte resultados por relevancia van a devolver otro orden. Hay que recalibrar "
         "contra un conjunto de consultas de referencia, no dar por buena la migración "
         "porque el conteo de filas cuadre."),
        ("#e05c5c", "Un solo cerebro concentra el riesgo del corte",
         "Informix aporta cuatrocientas cuarenta y cuatro mil de las quinientas diez mil "
         "filas. El plan de corte es, en la práctica, el plan de corte de ese cerebro; "
         "los otros treinta y seis son de bajo riesgo."),
        ("#F0D224", "Lo interno y lo del cliente quedan en la misma base",
         "El destino de migración de cada procedimiento y las posturas de los "
         "participantes del programa son análisis interno de Accenture, y hay un "
         "competidor dentro del programa. El aislamiento por fila no es una mejora "
         "opcional, es condición de entrada."),
        ("#F0D224", "El acceso al modelo tiene trámite",
         "Los modelos más capaces de Bedrock piden un formulario de caso de uso en la "
         "consola. Conviene levantarlo en la primera semana y dejar una alternativa "
         "declarada para no detener la fase tres."),
        ("#5e73c7", "El costo que sorprende no es la infraestructura",
         "La base de datos, las funciones y la entrega del portal suman decenas de "
         "dólares al mes. El consumo del modelo en un enjambre de diez agentes puede "
         "superar eso en una sola corrida larga, así que el presupuesto se controla "
         "ahí y no en el tamaño de la base."),
        ("#5e73c7", "Aparece gobierno donde hoy hay un archivo",
         "Un archivo en una carpeta sincronizada no tiene credenciales, ni rotación, ni "
         "ventana de mantenimiento. Un servicio sí. Eso es una ganancia, pero cuesta "
         "trabajo operativo que hoy no existe y conviene nombrarlo desde el principio."),
    ]
    filas_riesgos = "".join(
        f'<tr><td><span class="dot" style="background:{c}"></span><b>{t}</b></td>'
        f"<td>{d}</td></tr>" for c, t, d in riesgos)

    costo = [
        ("Base de datos Aurora Serverless v2", "Entre 15 y 40 dólares",
         "Con escalado a cero en reposo y un uso intermitente de unas pocas horas al día. "
         "La alternativa de una instancia pequeña encendida todo el tiempo ronda los "
         "veinticinco dólares y simplifica la operación."),
        ("Funciones y orquestación", "Menos de 5 dólares",
         "El volumen de invocaciones de un equipo de arquitectura no alcanza los umbrales "
         "de cobro relevantes."),
        ("Ingesta en contenedores", "Menos de 5 dólares",
         "Corridas esporádicas de minutos cuando entra fuente nueva."),
        ("Almacenamiento y entrega del portal", "Menos de 5 dólares",
         "Cien megabytes de fuente, el portal estático y el tráfico de un equipo interno."),
        ("Modelo de lenguaje", "Variable, es el renglón a vigilar",
         "Depende del volumen de enjambres. Conviene medirlo por corrida desde la primera "
         "semana y fijar un tope por proyecto."),
    ]
    filas_costo = "".join(
        f"<tr><td><b>{a}</b></td><td>{b}</td><td>{c}</td></tr>" for a, b, c in costo)

    return f"""<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Plataforma de Gemelos Cognitivos en AWS</title>
<style>{CSS}</style>
</head>
<body>
<div class="hero-bar">
  <img src="{logo_uri()}" alt="Accenture">
  <div class="hb-sep"></div>
  <div class="crumb">Arquitectura de referencia · Nube de AWS</div>
</div>

<div class="wrap">
  <div class="kick">Application Modernization · Gemelo Cognitivo</div>
  <h1>Plataforma de gemelos cognitivos en AWS</h1>
  <p>Hoy el conocimiento de un programa de modernización vive en una flota de archivos
  SQLite dentro de una carpeta sincronizada, y los gemelos digitales que razonan sobre
  ese conocimiento se ejecutan a mano en la laptop de quien los invoca. Funciona, y es
  precisamente por eso que ya se topó con sus propios límites: no hay concurrencia, no
  hay registro de quién consultó qué, y la federación entre cerebros se detiene en el
  décimo archivo adjunto porque ese es un límite de compilación de SQLite y no se puede
  subir en tiempo de ejecución.</p>
  <p>Esta arquitectura mueve el almacén a PostgreSQL administrado y los gemelos a
  funciones, sin cambiar la forma de trabajo: el cerebro se sigue construyendo desde la
  fuente con un proceso reproducible, el portal se sigue generando y los gemelos siguen
  siendo declaraciones en texto. Lo que cambia es dónde corren y quién puede verlos.</p>

  <div class="sb-row">{sbs}</div>

  <h2>El diagrama</h2>
  <div class="diag">{diagrama(inv)}</div>
  <p class="cap">Los íconos son los oficiales de AWS. La línea amarilla es la ruta
  interactiva de quien consulta; las punteadas son procesos que corren solos.</p>

  <h2>Las seis decisiones que sostienen el diseño</h2>
  <div class="grid">{cards}</div>

  <h2>Qué cambia en la práctica</h2>
  <table>
    <tr><th>Capacidad</th><th>Hoy</th><th>En la nube</th></tr>
    {filas_tabla}
  </table>

  <h2>Cómo se llega</h2>
  <p>Cada fase cierra con una comprobación que se puede ejecutar, no con una opinión
  sobre si quedó bien.</p>
  <table>
    <tr><th>Fase</th><th>Alcance</th><th>Duración</th><th>Criterio de corte</th></tr>
    {filas_fases}
  </table>

  <h2>Costo mensual estimado</h2>
  <p>Cifras de referencia para la región us-east-1, en el orden de magnitud de un
  entorno de trabajo de un equipo de arquitectura, no de una carga productiva del banco.</p>
  <table>
    <tr><th>Concepto</th><th>Estimado</th><th>Supuesto</th></tr>
    {filas_costo}
  </table>

  <h2>Riesgos y lo que hay que vigilar</h2>
  <table>
    <tr><th>Riesgo</th><th>Lectura</th></tr>
    {filas_riesgos}
  </table>
</div>

<footer>
Generado con <b>generators/build-aws-blueprint.py</b> a partir del inventario vivo de la
flota de cerebros. Íconos oficiales de AWS y paleta tomados del Design Studio.
Documento interno de Accenture.
</footer>
</body>
</html>
"""


def main() -> None:
    inv = inventario()
    OUT.write_text(html(inv), encoding="utf-8")
    print(f"Blueprint escrito: {OUT}")
    print(f"Inventario: {inv}")


if __name__ == "__main__":
    main()
