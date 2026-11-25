#!/usr/bin/env python3
"""
Liverpool — Benchmark de modernización del mainframe (modelo paramétrico).

Calcula bandas de costo y duración para salir del mainframe, segmentadas por
ruta 7R. No es un estimado de propuesta: es un benchmark de orden de magnitud
para la conversación de inversión, con la cadena de supuestos auditable.

Principio de diseño: el brain no guarda un número, guarda el modelo. Cada banda
se deriva de drivers explícitos y de anclas de industria citadas. Al llegar un
dato real se edita el driver y el benchmark se recalcula.

    PYTHONUTF8=1 python generators/load-mainframe-benchmark.py
"""
import sqlite3
from pathlib import Path

BRAIN = Path(__file__).parent.parent / "liverpool-brain.db"

# ---------------------------------------------------------------------------
# ANCLAS DE INDUSTRIA  (source_quality: vendor | academico | prensa)
# ---------------------------------------------------------------------------
ANCHORS = [
    ("fp_rehost", "Costo por punto de función, rehost", 800, 1500, "USD/PF",
     "tech-stack.com", "https://tech-stack.com/blog/mainframe-modernization/", "vendor"),
    ("fp_replatform", "Costo por punto de función, replatform", 1000, 2200, "USD/PF",
     "tech-stack.com", "https://tech-stack.com/blog/mainframe-modernization/", "vendor"),
    ("fp_refactor", "Costo por punto de función, refactor a Java", 1200, 3500, "USD/PF",
     "tech-stack.com", "https://tech-stack.com/blog/mainframe-modernization/", "vendor"),
    ("prog_mid", "Programa mainframe mediano, total", 5, 50, "USD M",
     "migrationcost.com", "https://migrationcost.com/mainframe-modernisation-cost", "vendor"),
    ("prog_refactor", "Refactor a Java con tooling automatizado", 10, 30, "USD M",
     "migrationcost.com", "https://migrationcost.com/mainframe-modernisation-cost", "vendor"),
    ("bank_regional", "Banco regional, salida de mainframe", 5, 50, "USD M",
     "finantrix.com", "https://www.finantrix.com/in-focus/core-to-customer-modernizing-retail-banking/cloud-migration-strategies-retail-banks", "vendor"),
    ("bank_tier1", "Banco Tier 1, salida de mainframe", 50, 200, "USD M",
     "finantrix.com", "https://www.finantrix.com/in-focus/core-to-customer-modernizing-retail-banking/cloud-migration-strategies-retail-banks", "vendor"),
    ("core_replace", "Reemplazo de core bancario completo", 50, 300, "USD M",
     "TT Lab, análisis Temenos", "https://labhub.hopto.org/blog/culture/2026-05-25-core-banking-temenos-mambu-thought-machine-fis-ncr-finacle-bancs-2026-deep-dive?lang=en", "vendor"),
    ("cobol_auto", "COBOL a Java automatizado, alcance acotado", 0.3, 0.8, "USD M",
     "softwaremodernizationservices.com", "https://softwaremodernizationservices.com/cobol-migration-services/", "vendor"),
    ("mips_year", "Costo de run por MIPS al año", 840, 4500, "USD/MIPS",
     "EPAM, Quinnox y migrationcost", "https://www.epam.com/insights/blogs/mainframe-modernization-roi-a-cost-focused-guide-for-businesses", "vendor"),
    ("backfiring", "Backfiring COBOL, sentencias por punto de función", 106.7, 106.7, "LOC/PF",
     "Capers Jones, IFPUG", "https://www.ifpug.org/wp-content/uploads/2017/04/IYSM.-Thirty-years-of-IFPUG.-Software-Economics-and-Function-Point-Metrics-Capers-Jones.pdf", "academico"),
    ("parallel_run", "Ventana de parallel run en migración de tarjetas", 3, 6, "meses",
     "CSI Global, Kolega y Finantrix", "https://www.csiglobal.co.uk/vision-plus", "vendor"),
    ("impl_ratio", "Razón de licencia a implementación", 2, 3, "x",
     "Guía de core banking", "https://crassula.io/solutions/core-banking/guides/what-is-core-banking/", "vendor"),
    ("vp_cards", "Tarjetas procesadas en VisionPLUS a nivel mundial", 600, 600, "millones",
     "Wikipedia, VisionPLUS", "https://en.wikipedia.org/wiki/VisionPLUS", "prensa"),
]

# ---------------------------------------------------------------------------
# DRIVERS DE ESCALA LIVERPOOL  (prensa secundaria 2T26, validar contra reporte)
# ---------------------------------------------------------------------------
DRIVERS = [
    ("tarjetahabientes", "8.8", "millones", "Reporte 2T26, prensa secundaria",
     "Las fuentes discrepan. Vepormas reporta 8.8 millones de tarjetahabientes y Merca2.0 cita 6.47 millones de tarjetas; miden cosas distintas.", "VALIDAR"),
    ("cartera_bruta", "75,248", "MXN millones", "Reporte 2T26, prensa secundaria",
     "Cartera de crédito bruta al cierre de junio de 2026, con crecimiento de 9.5% anual.", "VALIDAR"),
    ("ingreso_financiero_trim", "6,028", "MXN millones", "Reporte 2T26, prensa secundaria",
     "Ingresos del negocio financiero en el trimestre, con crecimiento de 9.9%.", "VALIDAR"),
    ("cartera_vencida_90", "4.7", "por ciento", "Reporte 2T26, prensa secundaria",
     "Índice de cartera vencida a más de 90 días, contra 4.0% un año antes.", "VALIDAR"),
    ("share_tarjeta_propia", "50", "por ciento", "Prensa secundaria",
     "Más de la mitad de las compras en Liverpool se pagan con tarjeta de la propia tienda.", "VALIDAR"),
    ("tickets_ams_mainframe", "2,999", "tickets al año", "brain.db, tabla ams_groups",
     "Suma de AMS POS, AMS SOMS CIBERCOM, AMS CREDITO VPL, AMS BASE24 y AMS CREDITO VPL SATELITES.", "CONFIRMADO"),
    ("servicios_mainframe", "12", "servicios de negocio", "brain.db, tabla components",
     "Doce servicios con aplicación mainframe declarada, que son siete distintos duplicados por unidad de negocio.", "CONFIRMADO"),
    ("mips_instalados", "", "MIPS", "Sin fuente",
     "No hay dato de MIPS instalados. Es el driver que fija el costo de no hacer nada.", "DATO-REQUERIDO"),
    ("loc_cobol", "", "líneas", "Sin fuente",
     "No hay una sola línea de código del mainframe en el brain. Es el driver que colapsa la banda de refactor.", "DATO-REQUERIDO"),
    ("programas_cobol", "", "programas", "Sin fuente",
     "No hay inventario de programas, copybooks ni JCL. Ninguno de los 55 documentos de toma de control cubre el mainframe.", "DATO-REQUERIDO"),
    ("custom_vpl", "", "user exits y satélites", "Sin fuente",
     "El grupo AMS CREDITO VPL SATELITES prueba que existe una capa de desarrollo propio alrededor de VisionPLUS, pero no está inventariada.", "DATO-REQUERIDO"),
]

# ---------------------------------------------------------------------------
# UNIDADES DE ALCANCE  — una por aplicación mainframe, con su ruta 7R
# ---------------------------------------------------------------------------
UNITS = [
    dict(
        unit_id="U1", app="VPL Vision Plus", vendor="Fiserv, vía First Data, origen PaySys",
        fate="repurchase", fate_label="Reemplazo de plataforma de tarjetas",
        uom="Cuentas y cartera", fp_min=None, fp_max=None,
        cost_min=35.0, cost_base=65.0, cost_max=110.0,
        months_min=36, months_base=48, months_max=60,
        services=2, tickets=591, criticality="Crítico 24x7",
        rationale=(
            "VisionPLUS es producto empaquetado, de modo que el código no es de Liverpool y no "
            "existe la opción de migrarlo a Java. Las rutas reales son reemplazar la plataforma "
            "por una moderna de emisión de tarjetas, o encapsularla y dejarla corriendo. El "
            "dimensionamiento no sale de líneas de código sino de la escala de la cartera: 8.8 "
            "millones de tarjetahabientes y 75,248 millones de pesos de cartera bruta colocan a "
            "Liverpool por encima de la banda de banco regional y por debajo de un reemplazo de "
            "core bancario completo, porque el alcance es solo tarjetas y no el core entero."),
        anchors="bank_regional,bank_tier1,core_replace,impl_ratio,parallel_run",
    ),
    dict(
        unit_id="U2", app="SOMS", vendor="Desarrollo propio",
        fate="absorb", fate_label="Absorción en OMS existente",
        uom="Servicios funcionales", fp_min=1660, fp_max=4000,
        cost_min=1.7, cost_base=4.5, cost_max=8.8,
        months_min=18, months_base=24, months_max=36,
        services=3, tickets=851, criticality="Crítico",
        rationale=(
            "SOMS administra las órdenes de entrega y es desarrollo propio, pero reescribirlo en "
            "Java compite con dos sistemas que ya existen en el landscape y hacen lo mismo: "
            "Sterling OMS y PAO. La ruta económica es absorber la funcionalidad, que es "
            "configuración e integración antes que código nuevo. El riesgo está en el destino, "
            "porque Sterling OMS carga la señal de 96.69% de órdenes pendientes, así que "
            "absorber SOMS ahí sin sanear primero traslada el problema en lugar de resolverlo."),
        anchors="fp_replatform,prog_mid",
    ),
    dict(
        unit_id="U3", app="Mainframe Clientes", vendor="Desarrollo propio",
        fate="refactor", fate_label="Migración a Java",
        uom="Puntos de función", fp_min=1800, fp_max=4500,
        cost_min=2.2, cost_base=7.0, cost_max=15.8,
        months_min=18, months_base=30, months_max=42,
        services=1, tickets=0, criticality="Crítico",
        rationale=(
            "Es la única unidad que constituye una migración genuina de COBOL a Java. Sostiene la "
            "contabilidad de clientes de LiverpoolCard, de modo que el alcance escala con la "
            "cartera y no con el número de pantallas. La envolvente de puntos de función se "
            "triangula por dos caminos independientes: la banda de complejidad del servicio de "
            "negocio, y el backfiring de un subsistema contable de 200 a 600 mil líneas de "
            "COBOL. Ambos coinciden en el orden de magnitud, que es la única validación "
            "disponible mientras no haya código cargado."),
        anchors="fp_refactor,prog_refactor,cobol_auto,backfiring",
    ),
    dict(
        unit_id="U4", app="MARC 90", vendor="Desarrollo propio",
        fate="retire", fate_label="Retiro con absorción en SAP",
        uom="Servicios funcionales", fp_min=600, fp_max=1500,
        cost_min=0.5, cost_base=1.2, cost_max=2.0,
        months_min=9, months_base=12, months_max=18,
        services=1, tickets=0, criticality="Operativo",
        rationale=(
            "MARC 90 atiende devoluciones de mercancía a proveedor, funcionalidad que SAP MM "
            "cubre de forma nativa. No amerita migración a Java sino retiro con absorción. Es la "
            "unidad de menor costo y la de mayor retorno relativo, porque saca carga del "
            "mainframe sin construir nada nuevo."),
        anchors="fp_rehost",
    ),
    dict(
        unit_id="U5", app="Control-D y orquestación batch", vendor="BMC Software",
        fate="replatform", fate_label="Replatform de orquestación",
        uom="Cadenas de batch", fp_min=None, fp_max=None,
        cost_min=0.8, cost_base=1.8, cost_max=3.0,
        months_min=12, months_base=18, months_max=24,
        services=1, tickets=0, criticality="Operativo",
        rationale=(
            "Control-D agenda el batch y distribuye las salidas, entre ellas los estados de "
            "cuenta y los manifiestos. No es una aplicación de negocio, pero ninguna unidad "
            "anterior puede apagarse mientras la orquestación siga anclada al mainframe. Se "
            "dimensiona por cadenas de batch y es prerrequisito de decomiso, no un entregable "
            "independiente."),
        anchors="prog_mid",
    ),
]

# ---------------------------------------------------------------------------
# COSTOS DE PROGRAMA  — no atribuibles a una sola unidad
# ---------------------------------------------------------------------------
PROGRAM_COSTS = [
    ("Descubrimiento e ingeniería inversa", 1.5, 3.0, 5.0, 6, 9, 12,
     "Hoy no hay código, ni inventario de programas, ni MIPS, ni un documento de toma de control "
     "del mainframe. Sin esta fase ninguna banda del benchmark se puede colapsar, de modo que es "
     "la primera inversión y la que más incertidumbre retira por peso invertido."),
    ("Parallel run y doble operación", 4.0, 9.0, 18.0, 3, 6, 6,
     "La ventana típica en migración de tarjetas va de tres a seis meses con ambas plataformas "
     "vivas. El costo no es solo infraestructura: incluye la conciliación diaria y el equipo que "
     "sostiene los dos lados al mismo tiempo."),
    ("Pruebas con duplicidad de unidad de negocio", 2.0, 5.0, 9.0, 0, 0, 0,
     "Cada servicio del mainframe corre para Liverpool y para Suburbia, de modo que el alcance de "
     "pruebas se duplica aunque el código sea el mismo. Es un multiplicador de esfuerzo que no "
     "aparece en el conteo de puntos de función."),
    ("Migración de datos de cartera", 2.5, 6.0, 12.0, 9, 12, 18,
     "Mover 8.8 millones de cuentas con historia contable y saldos exige conciliación contable "
     "formal. El antecedente comparable más cercano movió cerca de un millón de cuentas sin "
     "interrupción de servicio, de modo que Liverpool opera a casi nueve veces esa escala."),
    ("Run del mainframe durante la transición", 0.0, 0.0, 0.0, 0, 0, 0,
     "Es función de los MIPS instalados, que es dato requerido. Con la banda de industria de 840 "
     "a 4,500 dólares por MIPS al año, cada 1,000 MIPS agregan entre 0.8 y 4.5 millones de "
     "dólares anuales que siguen corriendo hasta el decomiso."),
]


def main():
    con = sqlite3.connect(BRAIN)
    cur = con.cursor()

    cur.executescript("""
    DROP TABLE IF EXISTS mf_benchmark_anchors;
    DROP TABLE IF EXISTS mf_benchmark_drivers;
    DROP TABLE IF EXISTS mf_benchmark_units;
    DROP TABLE IF EXISTS mf_benchmark_program;

    CREATE TABLE mf_benchmark_anchors(
        anchor_key TEXT PRIMARY KEY, concept TEXT, val_min REAL, val_max REAL,
        unit TEXT, source TEXT, url TEXT, source_quality TEXT);

    CREATE TABLE mf_benchmark_drivers(
        driver_key TEXT PRIMARY KEY, value TEXT, unit TEXT, source TEXT,
        note TEXT, status TEXT);

    CREATE TABLE mf_benchmark_units(
        unit_id TEXT PRIMARY KEY, app TEXT, vendor TEXT, fate TEXT, fate_label TEXT,
        uom TEXT, fp_min INTEGER, fp_max INTEGER,
        cost_min REAL, cost_base REAL, cost_max REAL,
        months_min INTEGER, months_base INTEGER, months_max INTEGER,
        services INTEGER, tickets INTEGER, criticality TEXT,
        rationale TEXT, anchors TEXT);

    CREATE TABLE mf_benchmark_program(
        item TEXT PRIMARY KEY, cost_min REAL, cost_base REAL, cost_max REAL,
        months_min INTEGER, months_base INTEGER, months_max INTEGER, note TEXT);
    """)

    cur.executemany("INSERT INTO mf_benchmark_anchors VALUES (?,?,?,?,?,?,?,?)", ANCHORS)
    cur.executemany("INSERT INTO mf_benchmark_drivers VALUES (?,?,?,?,?,?)", DRIVERS)
    cur.executemany("""INSERT INTO mf_benchmark_units VALUES
        (:unit_id,:app,:vendor,:fate,:fate_label,:uom,:fp_min,:fp_max,
         :cost_min,:cost_base,:cost_max,:months_min,:months_base,:months_max,
         :services,:tickets,:criticality,:rationale,:anchors)""", UNITS)
    cur.executemany("INSERT INTO mf_benchmark_program VALUES (?,?,?,?,?,?,?,?)", PROGRAM_COSTS)

    u_min = sum(u["cost_min"] for u in UNITS)
    u_base = sum(u["cost_base"] for u in UNITS)
    u_max = sum(u["cost_max"] for u in UNITS)
    p_min = sum(p[1] for p in PROGRAM_COSTS)
    p_base = sum(p[2] for p in PROGRAM_COSTS)
    p_max = sum(p[3] for p in PROGRAM_COSTS)
    t_min, t_base, t_max = u_min + p_min, u_base + p_base, u_max + p_max

    vpl = next(u for u in UNITS if u["unit_id"] == "U1")["cost_base"]
    java = next(u for u in UNITS if u["unit_id"] == "U3")["cost_base"]

    for k, v in [
        ("mf_bench_total_min", f"{t_min:.1f}"),
        ("mf_bench_total_base", f"{t_base:.1f}"),
        ("mf_bench_total_max", f"{t_max:.1f}"),
        ("mf_bench_units_base", f"{u_base:.1f}"),
        ("mf_bench_program_base", f"{p_base:.1f}"),
        ("mf_bench_vpl_share_base", f"{100 * vpl / t_base:.0f}"),
        ("mf_bench_java_share_base", f"{100 * java / t_base:.0f}"),
        ("mf_bench_built_at", "2026-10-28"),
        ("mf_bench_currency", "USD millones"),
        ("mf_bench_purpose", "Conversación de inversión, orden de magnitud"),
    ]:
        cur.execute("INSERT OR REPLACE INTO brain_meta VALUES (?,?)", (k, v))

    con.commit()
    print(f"anclas de industria         : {len(ANCHORS)}")
    print(f"drivers de escala           : {len(DRIVERS)} "
          f"({sum(1 for d in DRIVERS if d[5] == 'DATO-REQUERIDO')} sin dato)")
    print(f"unidades de alcance         : {len(UNITS)}")
    print(f"costos de programa          : {len(PROGRAM_COSTS)}")
    print(f"total USD M (min/base/max)  : {t_min:.1f} / {t_base:.1f} / {t_max:.1f}")
    print(f"peso de VPL en el caso base : {100 * vpl / t_base:.0f}%")
    print(f"peso de la migración a Java : {100 * java / t_base:.0f}%")
    con.close()


if __name__ == "__main__":
    main()
