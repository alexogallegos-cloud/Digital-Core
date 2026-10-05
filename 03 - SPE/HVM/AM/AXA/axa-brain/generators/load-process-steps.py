"""
load-process-steps.py
Lee la hoja '1. Mapeo procesos' del Competitive Discovery Suscripción Daños
y carga los pasos del proceso en axa-brain.db.

Tabla destino: process_steps
Cross-reference con ETB capabilities via etb_capability.
"""

import sqlite3
import os
import openpyxl

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "axa-brain.db")
SOURCE_DIR = os.path.join(BASE_DIR, "source")

# Mapa: texto de sistema → slugs de sistemas del brain
SISTEMA_SLUG = {
    "vector":       "underwriting-engine",
    "sinco":        "crm",
    "hsd":          "underwriting-engine",  # HSD es satélite de Vector
    "ern":          "actuarial",
    "safac":        "reinsurance",
    "general daños":"policy-admin",
    "power bi":     "analytics",
    "monitor":      "reporting-cnsf",
    "correo":       None,
    "teams":        None,
    "teléfono":     None,
    "whatsapp":     None,
    "word":         None,
    "excel":        None,
}

# Mapa: fase L2 → ETB capability ID (D6 Underwriting)
ETB_MAP = {
    "preparación de la información":              "6.3.1",
    "evaluación del riesgo":                      "6.3.2",
    "modelación catastrófica":                    "6.3.3",
    "definición de la cotización":                "6.3.4",
    "negociación de la cotización":               "6.3.5",
    "carga de información en la hsd":             "6.3.2",
    "cálculo y revisión de resultados técnicos":  "6.3.2",
    "validación de reglas de suscripción":        "6.3.1",
    "elaboración y validación de la cotización":  "6.3.4",
    "envío y negociación":                        "6.3.5",
}


def map_etb(fase_l2: str) -> str:
    if not fase_l2:
        return ""
    lower = fase_l2.lower()
    for key, cap in ETB_MAP.items():
        if key in lower:
            return cap
    return "6.3"  # default: underwriting genérico


def map_sistemas(raw: str) -> str:
    """Devuelve los slugs de sistema identificados en el texto raw."""
    if not raw:
        return ""
    slugs = set()
    lower = raw.lower()
    for nombre, slug in SISTEMA_SLUG.items():
        if nombre in lower and slug:
            slugs.add(slug)
    return "; ".join(sorted(slugs))


def ensure_table(conn: sqlite3.Connection):
    conn.execute("""
        CREATE TABLE IF NOT EXISTS process_steps (
            id              TEXT PRIMARY KEY,
            id_padre        TEXT,
            rama            TEXT,
            lob             TEXT,
            proceso_l1      TEXT,
            fase_l2         TEXT,
            etapa_l3        TEXT,
            paso_l4         TEXT,
            sistemas_raw    TEXT,
            sistemas_slugs  TEXT,
            roles           TEXT,
            documentos      TEXT,
            regla_negocio   TEXT,
            tiempos         TEXT,
            etb_capability  TEXT
        )
    """)
    conn.commit()


def load_steps(conn: sqlite3.Connection, ws):
    inserted = 0
    skipped = 0
    for row in ws.iter_rows(min_row=4, values_only=True):
        # Columnas: [0]=vacío [1]=ID_LoB [2]=LoB [3]=ID_L1 [4]=Proceso_L1
        # [5]=ID_L2 [6]=Fase_L2 [7]=ID_L3 [8]=Etapa_L3
        # [9]=ID_Padre [10]=Rama [11]=ID_Final [12]=Paso_L4
        # [13]=Sistema [14]=Roles [15]=Documentos [16]=Regla_negocio [17]=Tiempos
        if not row or len(row) < 13:
            continue
        step_id   = str(row[11]).strip() if row[11] else ""
        if not step_id or step_id == "None":
            skipped += 1
            continue

        lob        = str(row[2]).strip()  if row[2]  else ""
        proceso_l1 = str(row[4]).strip()  if row[4]  else ""
        fase_l2    = str(row[6]).strip()  if row[6]  else ""
        etapa_l3   = str(row[8]).strip()  if row[8]  else ""
        id_padre   = str(row[9]).strip()  if row[9]  else ""
        rama       = str(row[10]).strip() if row[10] else ""
        paso_l4    = str(row[12]).strip() if row[12] else ""
        sistemas_r = str(row[13]).strip() if row[13] else ""
        roles      = str(row[14]).strip() if row[14] else ""
        documentos = str(row[15]).strip() if row[15] else ""
        regla      = str(row[16]).strip() if row[16] else ""
        tiempos    = str(row[17]).strip() if row[17] else ""

        sistemas_s = map_sistemas(sistemas_r)
        etb_cap    = map_etb(fase_l2)

        conn.execute("""
            INSERT OR REPLACE INTO process_steps
              (id, id_padre, rama, lob, proceso_l1, fase_l2, etapa_l3, paso_l4,
               sistemas_raw, sistemas_slugs, roles, documentos, regla_negocio,
               tiempos, etb_capability)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        """, (step_id, id_padre, rama, lob, proceso_l1, fase_l2, etapa_l3,
              paso_l4, sistemas_r, sistemas_s, roles, documentos, regla, tiempos,
              etb_cap))
        inserted += 1

    conn.commit()
    return inserted, skipped


def main():
    if not os.path.exists(DB_PATH):
        print(f"[ERROR] axa-brain.db no encontrado en {DB_PATH}")
        print("        Ejecuta build-axa-brain.py primero.")
        return

    # Encontrar el Excel
    excel_files = [f for f in os.listdir(SOURCE_DIR) if f.endswith(".xlsx")]
    if not excel_files:
        print(f"[ERROR] No se encontró ningún archivo .xlsx en {SOURCE_DIR}")
        return
    excel_path = os.path.join(SOURCE_DIR, excel_files[0])
    print(f"[INFO] Leyendo: {excel_path}")

    wb = openpyxl.load_workbook(excel_path, read_only=True, data_only=True)
    if "1. Mapeo procesos" not in wb.sheetnames:
        print("[ERROR] Hoja '1. Mapeo procesos' no encontrada.")
        print("        Hojas disponibles:", wb.sheetnames)
        return

    ws = wb["1. Mapeo procesos"]
    conn = sqlite3.connect(DB_PATH)
    ensure_table(conn)
    inserted, skipped = load_steps(conn, ws)
    conn.close()

    print(f"[OK] process_steps: {inserted} pasos cargados, {skipped} filas ignoradas.")
    print(f"     Tabla: process_steps en {DB_PATH}")


if __name__ == "__main__":
    main()