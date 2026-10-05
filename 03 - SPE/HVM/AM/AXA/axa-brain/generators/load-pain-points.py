"""
load-pain-points.py
Lee la hoja '2. Pain points' del Competitive Discovery Suscripción Daños
y carga los pain points en axa-brain.db.

Tabla destino: pain_points
Cada pain point registra: categorías, LoB impactada, causa raíz por dimensión
(proceso, tecnología, negocio, datos, organización) y patrones de mejora.
"""

import sqlite3
import os
import openpyxl

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "axa-brain.db")
SOURCE_DIR = os.path.join(BASE_DIR, "source")


def ensure_table(conn: sqlite3.Connection):
    conn.execute("""
        CREATE TABLE IF NOT EXISTS pain_points (
            id                  TEXT PRIMARY KEY,
            cat_c1              TEXT,
            cat_c2              TEXT,
            descripcion         TEXT,
            -- LoB impactada (1=sí, 0=no)
            lob_suscripcion     INTEGER DEFAULT 0,
            lob_reasfac         INTEGER DEFAULT 0,
            lob_emision         INTEGER DEFAULT 0,
            lob_property        INTEGER DEFAULT 0,
            lob_ramos_tecnicos  INTEGER DEFAULT 0,
            lob_rc              INTEGER DEFAULT 0,
            lob_maritimo        INTEGER DEFAULT 0,
            lob_aviacion        INTEGER DEFAULT 0,
            lob_obras_arte      INTEGER DEFAULT 0,
            lob_lineas_fin      INTEGER DEFAULT 0,
            -- Manualidad (alta manualidad = 1)
            manualidad          INTEGER DEFAULT 0,
            -- Dimensión Proceso
            causa_proceso       TEXT,
            mejora_proceso      TEXT,
            patron_proceso      TEXT,
            -- Dimensión Tecnología
            causa_tecnologia    TEXT,
            mejora_tecnologia   TEXT,
            patron_tecnologia   TEXT,
            -- Dimensión Negocio
            causa_negocio       TEXT,
            mejora_negocio      TEXT,
            patron_negocio      TEXT,
            -- Dimensión Datos
            causa_datos         TEXT,
            mejora_datos        TEXT,
            patron_datos        TEXT,
            -- Dimensión Organización
            causa_org           TEXT,
            mejora_org          TEXT,
            patron_org          TEXT
        )
    """)
    conn.commit()


def flag(val) -> int:
    """Convierte 'X', True, 'x', etc. a 1; cualquier otro valor a 0."""
    if val is None:
        return 0
    s = str(val).strip().upper()
    return 1 if s in ("X", "TRUE", "1", "SI", "SÍ") else 0


def txt(val) -> str:
    if val is None:
        return ""
    s = str(val).strip()
    return "" if s in ("None", "-", "FALSE", "False") else s


def load_pain_points(conn: sqlite3.Connection, ws):
    inserted = 0
    skipped = 0
    # Encabezados en R3 (fila 3). Datos desde R4.
    # Col layout (0-indexed desde col B que es índice 1 en iter_rows):
    # [1]=ID_C1 [2]=Cat_C1 [3]=ID_C2 [4]=Cat_C2 [5]=ID_PP [6]=Pain point
    # [7]=Suscripción [8]=Reasfac [9]=Emisión
    # [10]=Property [11]=RamosTécnicos [12]=RC [13]=Marítimo [14]=Aviación
    # [15]=ObrasArte [16]=LíneasFinancieras [17]=Manualidad
    # [18]=CausaProceso [19]=MejoraProceso [20]=PatrónProceso
    # [21]=CausaTec [22]=MejoraTec [23]=PatrónTec
    # [24]=CausaNegocio [25]=MejoraNegocio [26]=PatrónNegocio
    # [27]=CausaDatos [28]=MejoraDatos [29]=PatrónDatos
    # [30]=CausaOrg [31]=MejoraOrg [32]=PatrónOrg

    for row in ws.iter_rows(min_row=4, values_only=True):
        if not row or len(row) < 7:
            continue
        pp_id = txt(row[5])
        if not pp_id:
            skipped += 1
            continue

        cat_c1 = txt(row[2])
        cat_c2 = txt(row[4])
        desc   = txt(row[6])

        conn.execute("""
            INSERT OR REPLACE INTO pain_points
              (id, cat_c1, cat_c2, descripcion,
               lob_suscripcion, lob_reasfac, lob_emision,
               lob_property, lob_ramos_tecnicos, lob_rc,
               lob_maritimo, lob_aviacion, lob_obras_arte, lob_lineas_fin,
               manualidad,
               causa_proceso,  mejora_proceso,  patron_proceso,
               causa_tecnologia, mejora_tecnologia, patron_tecnologia,
               causa_negocio,  mejora_negocio,  patron_negocio,
               causa_datos,    mejora_datos,    patron_datos,
               causa_org,      mejora_org,      patron_org)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        """, (
            pp_id, cat_c1, cat_c2, desc,
            flag(row[7]),  flag(row[8]),  flag(row[9]),
            flag(row[10]), flag(row[11]), flag(row[12]),
            flag(row[13]), flag(row[14]), flag(row[15]), flag(row[16]),
            flag(row[17]),
            txt(row[18]),  txt(row[19]),  txt(row[20]),
            txt(row[21]),  txt(row[22]),  txt(row[23]),
            txt(row[24]),  txt(row[25]),  txt(row[26]),
            txt(row[27]),  txt(row[28]),  txt(row[29]),
            txt(row[30]),  txt(row[31]),  txt(row[32]) if len(row) > 32 else "",
        ))
        inserted += 1

    conn.commit()
    return inserted, skipped


def print_summary(conn: sqlite3.Connection):
    print("\n[RESUMEN PAIN POINTS]")
    rows = conn.execute("""
        SELECT cat_c1, COUNT(*) as n
        FROM pain_points
        GROUP BY cat_c1
        ORDER BY n DESC
    """).fetchall()
    for cat, n in rows:
        print(f"  {n:2d}  {cat}")

    print("\n[LOB MÁS IMPACTADAS]")
    lobs = [
        ("Property",        "lob_property"),
        ("Suscripción",     "lob_suscripcion"),
        ("Ramos Técnicos",  "lob_ramos_tecnicos"),
        ("RC",              "lob_rc"),
        ("Líneas Fin.",     "lob_lineas_fin"),
        ("Marítimo",        "lob_maritimo"),
        ("Emisión",         "lob_emision"),
        ("Aviación",        "lob_aviacion"),
        ("Reasfac",         "lob_reasfac"),
        ("Obras Arte",      "lob_obras_arte"),
    ]
    for label, col in lobs:
        n = conn.execute(f"SELECT COUNT(*) FROM pain_points WHERE {col}=1").fetchone()[0]
        bar = "█" * n
        print(f"  {label:<18} {bar} {n}")


def main():
    if not os.path.exists(DB_PATH):
        print(f"[ERROR] axa-brain.db no encontrado en {DB_PATH}")
        print("        Ejecuta build-axa-brain.py primero.")
        return

    excel_files = [f for f in os.listdir(SOURCE_DIR) if f.endswith(".xlsx")]
    if not excel_files:
        print(f"[ERROR] No se encontró ningún archivo .xlsx en {SOURCE_DIR}")
        return
    excel_path = os.path.join(SOURCE_DIR, excel_files[0])
    print(f"[INFO] Leyendo: {excel_path}")

    wb = openpyxl.load_workbook(excel_path, read_only=True, data_only=True)
    if "2. Pain points" not in wb.sheetnames:
        print("[ERROR] Hoja '2. Pain points' no encontrada.")
        print("        Hojas disponibles:", wb.sheetnames)
        return

    ws = wb["2. Pain points"]
    conn = sqlite3.connect(DB_PATH)
    ensure_table(conn)
    inserted, skipped = load_pain_points(conn, ws)
    print(f"[OK] pain_points: {inserted} pain points cargados, {skipped} filas ignoradas.")

    print_summary(conn)
    conn.close()


if __name__ == "__main__":
    main()