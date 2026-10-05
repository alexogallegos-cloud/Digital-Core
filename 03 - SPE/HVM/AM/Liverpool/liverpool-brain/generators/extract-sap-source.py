#!/usr/bin/env python3
"""
extract-sap-source.py
Extrae metadata de los programas ABAP en source/Source Code SAP/
y los carga como components SAP de granularidad fina en liverpool-brain.db.

Los componentes se identifican con id SAP-{program_name}.
Se cargan con seeded_by='source/Source Code SAP' para diferenciarse
de los 117 servicios del dashboard (seeded_by='Arquitectura_Liverpool_Dashboard_1.html').

Ejecutar desde el directorio liverpool-brain/:
    python generators/extract-sap-source.py

Módulo cubierto: Importaciones (ZIM*, ZRT* relacionados con PO/Importación)
Dominio: R04 Cadena de Suministro + R01 Gestión Comercial
"""

import re
import sqlite3
from pathlib import Path
from datetime import datetime

BRAIN_DIR  = Path(__file__).parent.parent
SOURCE_DIR = BRAIN_DIR / "source" / "Source Code SAP"
DB_PATH    = BRAIN_DIR / "liverpool-brain.db"

SEEDED_BY = "source/Source Code SAP"

# ── Metadata estática por programa (extraída del encabezado ABAP) ─────────────
# Clave = filename exacto del archivo en source/Source Code SAP/

PROGRAM_META = {
    "ZIMPOC001": {
        "report_name":    "ZIMPOC001",
        "business_name":  "Reserva de pedidos de importación",
        "description":    "Reporte ALV de reserva de pedidos de importación con control de allocation y auto-allocation por grupo de compras. Publica eventos en Event Manager (EM).",
        "domain_id":      "R04",
        "component_type": "report",
        "complexity":     "high",
        "last_mod_date":  "2016-05",
        "last_mod_author":"GHERNANDEZV (IBM)",
        "z_tables":       "ZIM_RVPO,ZRT_LEKPO",
        "std_tables":     "EKKO,EKPO,MARA,T024",
    },
    "ZIMFIC002": {
        "report_name":    "ZIMFIC002",
        "business_name":  "Contabilización de solicitudes de pago de importación",
        "description":    "Contabilización de solicitudes de pago de pedidos de importación. Maneja anticipos, gastos (conceptos 003/008/016), retenciones IVA, tipos de cambio fijo, facturas Duty Free. Interfaz con ZIM015.",
        "domain_id":      "R07",
        "component_type": "report",
        "complexity":     "very-high",
        "last_mod_date":  "2011-05",
        "last_mod_author":"Elliot Mata (IBM)",
        "z_tables":       "ZIM_LIPG,ZIM_LDPG",
        "std_tables":     "EKKO,EKPO",
    },
    "ZIMPOC002": {
        "report_name":    "ZIMPOC002",
        "business_name":  "Registro de datos generales de compras e importaciones",
        "description":    "Registro y actualización de datos de importaciones por pedido: fechas estimadas de embarque/arribo, broker, agente aduanal, pedimentos parciales. Publica en Event Manager.",
        "domain_id":      "R04",
        "component_type": "report",
        "complexity":     "very-high",
        "last_mod_date":  "2009",
        "last_mod_author":"equipo Net Partners / IBM",
        "z_tables":       "ZIM_RVPO,ZIM_CNST",
        "std_tables":     "EKKO,EKPO",
    },
    "ZIMPOC003": {
        "report_name":    "ZIMP_0001",
        "business_name":  "Generación de pedidos de importación — interfaz ME21I",
        "description":    "Creación de pedidos de importación vía interfaz ME21I con activación de eventos EM. Maneja Incoterms por grupo de compras y tipos de pedido diferenciados (IM, IP, TIM, TIP).",
        "domain_id":      "R04",
        "component_type": "report",
        "complexity":     "high",
        "last_mod_date":  "2007-01",
        "last_mod_author":"HMR",
        "z_tables":       "ZIM_RVPO",
        "std_tables":     "EKKO,EKPO,MARA",
    },
    "ZIMPOC005": {
        "report_name":    "ZIMFIC001",
        "business_name":  "Portal de pre-embarques para proveedores",
        "description":    "Pantalla para que proveedores visualicen pre-embarques y decidan aceptación o rechazo. Proceso batch con actualización de log EM (ZIMRFC005 desactivado desde 2010).",
        "domain_id":      "R04",
        "component_type": "report",
        "complexity":     "medium",
        "last_mod_date":  "2010-12",
        "last_mod_author":"HGG",
        "z_tables":       "",
        "std_tables":     "",
    },
    "ZIMPOC007": {
        "report_name":    "ZIMPOC007",
        "business_name":  "Reserva de pedidos de importación — variante extendida",
        "description":    "Variante extendida de ZIMPOC001: agrega parámetros de fecha estimada de embarque, columna de fin de proceso, temporada y comentarios masivos. Soporta sociedad 150 (Sfera Moda Joven).",
        "domain_id":      "R04",
        "component_type": "report",
        "complexity":     "high",
        "last_mod_date":  "2009-10",
        "last_mod_author":"SRG",
        "z_tables":       "ZIM_RVPO",
        "std_tables":     "EKKO,EKPO",
    },
    "ZIMPOC023": {
        "report_name":    "ZIMPOC023",
        "business_name":  "Reporte de faltantes y sobrantes en recepción de importaciones",
        "description":    "Reporte de discrepancias de recepción (faltantes y sobrantes) para pedidos de importación. Cruza recepciones ECC vs. tabla de tracking de entregas por parcial.",
        "domain_id":      "R04",
        "component_type": "report",
        "complexity":     "medium",
        "last_mod_date":  "2013-06",
        "last_mod_author":"BCR (Prospectiva)",
        "z_tables":       "ZIM_RCBP,ZIM_LICH,ZIM_RVPO",
        "std_tables":     "EKKO,EKPO",
    },
    "ZIMPOC024": {
        "report_name":    "ZIMPOC024",
        "business_name":  "Mantenimiento de pedidos de importación (PO IM)",
        "description":    "Programa de mantenimiento de POs de importación: cambio de aduana, actualización de agente aduanal, contenedor y bulto. Usa módulos de pantalla ZIMPOC024_TOP/_CLASS/_SCREEN.",
        "domain_id":      "R04",
        "component_type": "program",
        "complexity":     "high",
        "last_mod_date":  "2014-07",
        "last_mod_author":"Ismael Salgado Vargas",
        "z_tables":       "ZIM_LICH,ZIM_LIPS",
        "std_tables":     "EKKO,EKPO",
    },
    "ZIMPOB010B": {
        "report_name":    "ZIMPOB010B",
        "business_name":  "Reporte de pedimentos (include batch)",
        "description":    "Subrutina batch (INCLUDE _F01) que genera el layout ALV para el reporte de pedimentos de importación. Componente de soporte del programa principal ZIMPOB010.",
        "domain_id":      "R04",
        "component_type": "include",
        "complexity":     "low",
        "last_mod_date":  "",
        "last_mod_author":"",
        "z_tables":       "",
        "std_tables":     "",
    },
    "ZRTPOC079": {
        "report_name":    "ZRTPOC079",
        "business_name":  "Validación y generación de pedido de traslado tipo 7",
        "description":    "Subrutinas de validación (INCLUDE _F01) para pedidos tipo 7: asignación de traslado, validación de clase IM/IP/TIM/TIP, centros CDT (0090/L090/T090/U090/P090) y bloqueo de pool de entregas (WF30).",
        "domain_id":      "R04",
        "component_type": "include",
        "complexity":     "medium",
        "last_mod_date":  "2014-05",
        "last_mod_author":"Farid Franco Lara",
        "z_tables":       "",
        "std_tables":     "EKKO,EKPO",
    },
    "ZRTPOC079N": {
        "report_name":    "ZRTPOC079N",
        "business_name":  "Reporte de pedidos por tipo de orden — variante N",
        "description":    "Reporte con selection screen sobre EKKO-BSART para análisis de pedidos por tipo. Soporta búsqueda por rango de fechas o por número de pedido. Modificado abril 2025 (activo en producción).",
        "domain_id":      "R04",
        "component_type": "report",
        "complexity":     "medium",
        "last_mod_date":  "2025-04",
        "last_mod_author":"RON",
        "z_tables":       "",
        "std_tables":     "EKKO,EKPO",
    },
    "ZRT_PO_REP_EPI_BD": {
        "report_name":    "ZRT_PO_REP_EPI_BD",
        "business_name":  "Interfaz de pedimentos ECC → POS",
        "description":    "Interface que transfiere pedimentos aduanales de SAP ECC al sistema POS. Incluye parámetro de pedimento extendido a 16 dígitos. Modificado octubre 2025 (activo en producción).",
        "domain_id":      "R06",
        "component_type": "report",
        "complexity":     "medium",
        "last_mod_date":  "2025-10",
        "last_mod_author":"Erika E. Cruz Pech / EECRUZP01",
        "z_tables":       "",
        "std_tables":     "EKKO,EKPO",
    },
}

# ── Helpers ───────────────────────────────────────────────────────────────────

def count_source_lines(content: str) -> int:
    """Cuenta líneas no vacías y no solo comentario."""
    count = 0
    for line in content.splitlines():
        stripped = line.strip()
        if stripped and not stripped.startswith("*"):
            count += 1
    return count


def build_description_full(meta: dict, loc: int) -> str:
    parts = [meta["description"]]
    if meta.get("z_tables"):
        parts.append(f"Tablas Z: {meta['z_tables']}")
    if meta.get("std_tables"):
        parts.append(f"Tablas estándar: {meta['std_tables']}")
    if meta.get("last_mod_date"):
        parts.append(f"Última modificación: {meta['last_mod_date']} — {meta.get('last_mod_author','')}")
    parts.append(f"LOC (no comentario): {loc}")
    return " | ".join(parts)


# ── Carga en DB ───────────────────────────────────────────────────────────────

def load_sap_programs(conn) -> int:
    rows = []

    for filename, meta in PROGRAM_META.items():
        src_file = SOURCE_DIR / filename
        if not src_file.exists():
            print(f"  WARN: archivo no encontrado — {filename}")
            continue

        content = src_file.read_text(encoding="utf-8", errors="replace")
        loc     = count_source_lines(content)
        comp_id = f"SAP-{meta['report_name']}"

        rows.append((
            comp_id,
            meta["report_name"],                # name
            "SAP",                              # source_system
            "ABAP",                             # source_language
            meta["component_type"],             # component_type (report|program|include)
            meta["domain_id"],                  # domain_id
            meta["business_name"],              # business_name
            build_description_full(meta, loc),  # description
            "core",                             # togaf_type — SAP es SoR core
            "replatform",                       # migration_fate — SAP ECC → S/4HANA
            loc,                                # lines_of_code
            meta["complexity"],                 # complexity
            "active",                           # status
            None,                               # rtb_capabilities
            SEEDED_BY,                          # seeded_by
        ))

    conn.executemany("""
        INSERT OR REPLACE INTO components
        (id, name, source_system, source_language, component_type,
         domain_id, business_name, description, togaf_type,
         migration_fate, lines_of_code, complexity, status,
         rtb_capabilities, seeded_by)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, rows)

    try:
        conn.execute("INSERT INTO components_fts(components_fts) VALUES('rebuild')")
    except Exception:
        pass

    conn.commit()
    return len(rows)


def update_domain_counts(conn):
    for r_id in [f"R{i:02d}" for i in range(1, 11)]:
        count = conn.execute(
            "SELECT COUNT(*) FROM components WHERE domain_id = ?", (r_id,)
        ).fetchone()[0]
        conn.execute(
            "UPDATE retail_domains SET component_count = ? WHERE id = ?", (count, r_id)
        )
    conn.commit()


def print_summary(conn):
    total      = conn.execute("SELECT COUNT(*) FROM components").fetchone()[0]
    sap_source = conn.execute(
        "SELECT COUNT(*) FROM components WHERE seeded_by = ?", (SEEDED_BY,)
    ).fetchone()[0]
    dash       = conn.execute(
        "SELECT COUNT(*) FROM components WHERE seeded_by = 'Arquitectura_Liverpool_Dashboard_1.html'"
    ).fetchone()[0]
    by_dom = conn.execute("""
        SELECT d.id, d.name, COUNT(c.id)
        FROM retail_domains d
        LEFT JOIN components c ON c.domain_id = d.id
        GROUP BY d.id ORDER BY d.id
    """).fetchall()
    active_2025 = conn.execute("""
        SELECT id, business_name, description
        FROM components
        WHERE seeded_by = ? AND description LIKE '%2025%'
    """, (SEEDED_BY,)).fetchall()

    print()
    print(f"Programas SAP fuente cargados : {sap_source}")
    print(f"Servicios dashboard           : {dash}")
    print(f"Total components en brain     : {total}")
    print()
    print("Por dominio (total):")
    for dom_id, dom_name, cnt in by_dom:
        print(f"  {dom_id}  {dom_name:40s}  {cnt:3d}")
    if active_2025:
        print()
        print("Programas activos en 2025 (modificados recientemente):")
        for comp_id, bname, _ in active_2025:
            print(f"  {comp_id}  {bname}")


def main():
    print("Liverpool SAP Source Extractor — Módulo Importaciones")
    print("=" * 55)

    if not SOURCE_DIR.exists():
        print(f"ERROR: directorio no encontrado — {SOURCE_DIR}")
        return
    if not DB_PATH.exists():
        print(f"ERROR: brain no encontrado — {DB_PATH}")
        print("  Ejecutar primero: python build-liverpool-brain.py")
        print("  Luego: python generators/extract-from-dashboard.py")
        return

    conn = sqlite3.connect(str(DB_PATH))
    conn.execute("PRAGMA journal_mode=WAL")

    # Borrar carga anterior de esta fuente
    deleted = conn.execute(
        "DELETE FROM components WHERE seeded_by = ?", (SEEDED_BY,)
    ).rowcount
    if deleted:
        print(f"  Eliminados {deleted} registros previos de {SEEDED_BY}")
    conn.commit()

    print(f"Leyendo {SOURCE_DIR.name}/ ...")
    n = load_sap_programs(conn)

    print("Actualizando conteos de dominios ...")
    update_domain_counts(conn)

    print_summary(conn)
    conn.close()

    print()
    print("Módulo de Importaciones SAP cargado en liverpool-brain.db")
    print("Programas cubiertos: ZIM* + ZRT* (pedidos de importación, pedimentos, contabilización)")


if __name__ == "__main__":
    main()
