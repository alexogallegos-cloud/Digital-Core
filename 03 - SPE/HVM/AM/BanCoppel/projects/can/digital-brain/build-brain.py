#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-brain.py — CAN Digital Brain
Créditos Asociados a Nómina · BanCoppel · SPE-AM-001

Brain regulatorio: estructura las obligaciones CAN, las brechas identificadas
y el roadmap de cambios en una SQLite consultable.

Ejecutar: python digital-brain/build-brain.py [--reset]
"""
import sqlite3, json, sys, os
from pathlib import Path
from datetime import date

BASE  = Path(__file__).resolve().parent.parent
DB    = Path(__file__).resolve().parent / "brain.db"
RESET = "--reset" in sys.argv

SCHEMA = """
PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

-- ── Meta ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS brain_meta (
    key   TEXT PRIMARY KEY,
    value TEXT
);

-- ── Obligaciones regulatorias CAN ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS regulatory_obligations (
    obligation_id   TEXT PRIMARY KEY,          -- CAN-OBL-{NNN}
    regulator       TEXT DEFAULT 'Banxico',
    instrument      TEXT,                      -- Circular / Artículo
    article         TEXT,
    description     TEXT,
    obligation_type TEXT,                      -- reporte|control|limite|disclosure|certificacion|autorizacion
    frequency       TEXT,                      -- diario|mensual|trimestral|anual|evento|continuo
    penalty_risk    TEXT,                      -- critico|alto|medio|bajo
    effective_date  TEXT,
    notes           TEXT
);

-- ── Sistemas en scope ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS systems_in_scope (
    id              TEXT PRIMARY KEY,          -- SCOPE-{sistema}-{NNN}
    system_slug     TEXT,                      -- informix|unity|apolo|ctm|etc
    togaf_type      TEXT,
    description     TEXT,
    in_scope_reason TEXT,
    obligation_ids  TEXT                       -- JSON array de CAN-OBL-{NNN}
);

-- ── Brechas de compliance ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS compliance_gaps (
    gap_id          TEXT PRIMARY KEY,          -- BRECHA-CAN-{NNN}
    obligation_id   TEXT,
    status          TEXT,                      -- CUMPLE|PARCIAL|NO-CUMPLE
    current_evidence TEXT,
    gap_description TEXT,
    criticality     TEXT,                      -- critico|alto|medio|bajo
    system_affected TEXT,                      -- JSON array de slugs
    target_deadline TEXT,
    FOREIGN KEY (obligation_id) REFERENCES regulatory_obligations(obligation_id)
);

-- ── User Stories de implementación ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_stories (
    us_id           TEXT PRIMARY KEY,          -- US-CAN-{NNN}
    gap_id          TEXT,
    title           TEXT,
    system_target   TEXT,
    change_type     TEXT,                      -- nuevo_sp|modificar_sp|nuevo_reporte|nuevo_control
    acceptance_criteria TEXT,
    effort_points   INTEGER,
    priority        TEXT,                      -- P1|P2|P3
    regulatory_deadline TEXT,
    sme_executor    TEXT,
    status          TEXT DEFAULT 'backlog',    -- backlog|in-progress|done
    FOREIGN KEY (gap_id) REFERENCES compliance_gaps(gap_id)
);

-- ── Vista — Dashboard de cumplimiento ────────────────────────────────────────
CREATE VIEW IF NOT EXISTS compliance_dashboard AS
SELECT
    o.obligation_id,
    o.obligation_type,
    o.penalty_risk,
    o.effective_date,
    COALESCE(g.status, 'NO-EVALUADO') AS gap_status,
    COALESCE(g.criticality, 'sin-evaluar') AS gap_criticality,
    COUNT(u.us_id) AS user_stories_count
FROM regulatory_obligations o
LEFT JOIN compliance_gaps g ON g.obligation_id = o.obligation_id
LEFT JOIN user_stories u    ON u.gap_id = g.gap_id
GROUP BY o.obligation_id;
"""


def build():
    if RESET and DB.exists():
        DB.unlink()
        print("brain.db eliminado (--reset)")

    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    con.executescript(SCHEMA)

    # Meta
    con.execute("INSERT OR REPLACE INTO brain_meta VALUES ('project','CAN')")
    con.execute("INSERT OR REPLACE INTO brain_meta VALUES ('version','0.2.0')")
    con.execute(f"INSERT OR REPLACE INTO brain_meta VALUES ('built_at','{date.today()}')")
    con.execute("INSERT OR REPLACE INTO brain_meta VALUES ('status','dt-normativa-can COMPLETO — 23 obligaciones cargadas; pendiente dt-impacto-sistemas')")
    con.execute("INSERT OR REPLACE INTO brain_meta VALUES ('circular','Circular 3/2012 Banxico compilado Circular 6/2025')")
    con.execute("INSERT OR REPLACE INTO brain_meta VALUES ('fuente','source/docs/regulacion/Circular 3-2012 CAN Compilado 6-2025.pdf')")

    # ── Sistemas en scope ────────────────────────────────────────────────────
    sistemas = [
        ("SCOPE-INF-001", "informix-bdiadminnomina", "core",
         "Módulo bdiadminnomina — nómina en producción (Informix IDS 14.10/AIX)",
         "Motor de cargos CAN, identificación de Cuentas Ordenantes, prelación, mandatos",
         '["CAN-OBL-013","CAN-OBL-014","CAN-OBL-015","CAN-OBL-016","CAN-OBL-017","CAN-OBL-018","CAN-OBL-019","CAN-OBL-023"]'),
        ("SCOPE-INF-002", "informix-bdispei",        "core",
         "Módulo bdispei — SPEI en producción (Informix)",
         "Liquidaciones SPEI para refinanciamientos CAN y Clave Básica Estandarizada",
         '["CAN-OBL-006","CAN-OBL-009"]'),
        ("SCOPE-CHN-001", "appmovil",                "channels",
         "App Móvil BanCoppel",
         "Interfaz para firma de mandatos y presentación de comparativo CAN vs. no-CAN",
         '["CAN-OBL-005","CAN-OBL-007","CAN-OBL-018"]'),
        ("SCOPE-CHN-002", "banca-internet",           "channels",
         "Banca por Internet BanCoppel",
         "Canal alternativo para mandatos y contratos CAN",
         '["CAN-OBL-005","CAN-OBL-018"]'),
        ("SCOPE-INT-001", "controlm",                "integration",
         "Control-M — Orquestador batch de nómina",
         "Scheduling de cargos periódicos CAN y procesamiento de transferencias de nómina",
         '["CAN-OBL-016","CAN-OBL-023"]'),
        ("SCOPE-INT-002", "mecanismo-63bis3",        "integration",
         "Mecanismo Art. 63 Bis 3 — Hub de comunicación interbancaria CAN",
         "Plataforma de intercambio de información CAN entre instituciones; debe notificarse a Banxico",
         '["CAN-OBL-012","CAN-OBL-015","CAN-OBL-019","CAN-OBL-020"]'),
        ("SCOPE-CPL-001", "reporting-cnbv",          "compliance",
         "Reporting regulatorio CNBV/Banxico",
         "Notificación del límite del Comité de Riesgos a Banxico y reporte a buró de crédito",
         '["CAN-OBL-003","CAN-OBL-008"]'),
    ]
    con.executemany(
        "INSERT OR IGNORE INTO systems_in_scope VALUES (?,?,?,?,?,?)", sistemas)

    # ── Obligaciones regulatorias CAN ────────────────────────────────────────
    obligaciones = [
        # Rol: Institución Acreedora
        ("CAN-OBL-001","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 63 Bis párrafo 1",
         "Antes de celebrar crédito designable como CAN en Cuenta Ordenante de otra Institución, solicitar información (Art. 22 Bis 1 I(b)) por medio del mecanismo Art. 63 Bis 3",
         "control","evento","alto","2018-01-01",
         "La información solo puede usarse para estimar viabilidad de pago; uso para otro fin prohibido"),
        ("CAN-OBL-002","Banxico","Circular 3/2012 mod. 15/2018","Art. 63 Bis párrafo 2",
         "El monto total de amortizaciones periódicas de todos los CANs del acreditado no puede exceder el porcentaje límite del Comité de Riesgos, basado en promedio mensual de abonos 6 meses en Cuenta Ordenante",
         "limite","continuo","critico","2018-01-01",
         "Comité de Riesgos determina el porcentaje; Banxico supervisa cumplimiento"),
        ("CAN-OBL-003","Banxico","Circular 3/2012 mod. 15/2018","Art. 63 Bis párrafo 2 (último)",
         "Enviar comunicación suscrita por quien presida el Comité de Riesgos a Gerencia de Autorizaciones y Consultas Banxico informando el límite aprobado, dentro de 10 DHB siguientes a su aprobación o modificación",
         "reporte","evento","alto","2018-01-01",
         "Plazo: 10 Días Hábiles Bancarios desde la aprobación del límite"),
        ("CAN-OBL-004","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 63 Bis párrafo 3",
         "Verificar identidad del cliente antes de solicitar información a la institución depositaria: obtener carátula de contrato, estado de cuenta del trimestre anterior, o tarjeta de débito vigente con nombre del cuentahabiente",
         "control","evento","medio","2018-01-01",
         "El cliente elige cuál de las tres opciones presenta"),
        ("CAN-OBL-005","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 63 Bis párrafo 4",
         "Obtener mandato del acreditado antes de celebrar el CAN, autorizando a la institución: (a) solicitar info de Cuenta Ordenante, (b) requerir modificación contrato de depósito, (c) gestionar Domiciliación a nombre del acreditado, (d) informar a otras instituciones la designación CAN. Puede ser escrito, electrónico o huella digital",
         "control","evento","critico","2018-01-01",
         "Sin este mandato la institución no tiene base legal para actuar ante la institución depositaria"),
        ("CAN-OBL-006","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 63 Bis párrafo 5",
         "Si el CAN sirve para liquidar otro crédito, transferir vía SPEI los recursos a la institución acreedora anterior usando la Clave Básica Estandarizada del crédito a liquidar",
         "control","evento","alto","2018-01-01",
         "El CAN de refinanciamiento obtiene la misma prelación si: (a) importe periódico no supera el anterior, (b) condiciones del CAN son mejores, (c) cumple Art. 2059 Código Civil Federal"),
        ("CAN-OBL-007","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 63 Bis penúltimo párrafo",
         "Presentar al cliente las condiciones del CAN comparadas con las condiciones de un crédito similar que no sea designado como CAN, antes de contratar",
         "disclosure","evento","alto","2018-01-01",
         "Obligación de transparencia informativa previo a la contratación"),
        ("CAN-OBL-008","Banxico","Circular 3/2012 mod. 15/2018","Art. 63 Bis anteúltimo párrafo",
         "Reportar a sociedad de información crediticia (buró) que el crédito tiene el carácter de Crédito Asociado a la Nómina, conforme a disposiciones aplicables",
         "reporte","evento","medio","2018-01-01",
         "Obligación de reporte a buró de crédito"),
        ("CAN-OBL-009","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 63 Bis último párrafo",
         "Asignar Clave Básica Estandarizada (conforme Reglas SPEI Circular 14/2017) a cada Crédito Asociado a la Nómina que se otorgue",
         "control","evento","medio","2018-01-01",
         "Esta clave se usa en liquidaciones SPEI de refinanciamiento CAN"),
        ("CAN-OBL-010","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 63 Bis 1 párrafo 1",
         "La institución acreedora debe gestionar la Domiciliación ante la institución depositaria (Cuenta Ordenante) mediante solicitud del Art. 64, asumiendo rol de Proveedor y Banco del Proveedor. Debe indicar importes, días del mes y plazo",
         "control","evento","alto","2018-01-01",
         "La institución acreedora actúa como Proveedor para efectos de Domiciliación"),
        ("CAN-OBL-011","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 63 Bis 1 párrafo 2",
         "En caso de pagos anticipados o reducción del importe/número de pagos, ajustar el monto de pagos periódicos pendientes conforme a Circular 16/2007 Banxico (transparencia pagos anticipados)",
         "control","evento","alto","2018-01-01",
         "Referencia: Circular 16/2007 Banxico sobre pagos anticipados"),
        # Ambos roles
        ("CAN-OBL-012","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 63 Bis 3",
         "Las consultas e información entre instituciones (Arts. 22 Bis 1, 63 Bis, 65) deben realizarse únicamente por mecanismos transparentes que no restrinjan participación en igualdad de circunstancias. Términos deben notificarse a Banxico (Gerencia de Autorizaciones y Consultas) de manera previa a su implementación",
         "control","evento","alto","2018-01-01",
         "El Hub/plataforma CAN debe notificarse a Banxico antes de usarse; es infraestructura crítica interinstitucional"),
        # Rol: Institución Depositaria (Cuenta Ordenante)
        ("CAN-OBL-013","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 22 Bis",
         "La institución que administre cuentas de personas físicas debe identificar como Cuentas Ordenantes: (I) cuentas con Prestaciones Laborales del Servicio de Nómina, (II) cuentas básicas de nómina (Art. 48 Bis 2 LIC), (III) cuentas abiertas por el cliente indicando que recibirá Prestaciones Laborales de Patrones identificados",
         "control","continuo","critico","2018-01-01",
         "Para fracción III: la institución debe permitir que el cliente indique que recibirá Prestaciones Laborales y requerir documentación del Patrón"),
        ("CAN-OBL-014","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 22 Bis 1 fracción I párrafo 1",
         "La institución depositaria debe ofrecer al cuentahabiente el derecho de designar créditos/préstamos (propios o de otras instituciones/SOFOM) como CANs. Este derecho y sus condiciones deben quedar estipulados en el contrato de la Cuenta Ordenante",
         "control","evento","critico","2018-01-01",
         "Aplica al momento de abrir la cuenta o al modificar el contrato para designarla como Cuenta Ordenante"),
        ("CAN-OBL-015","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 22 Bis 1 fracción I inciso b)",
         "Cuando otra Institución/SOFOM declare (via Art. 63 Bis 3) haber ofrecido un CAN en mandato del cuentahabiente, la depositaria debe responder a más tardar al DHB siguiente: (i) confirmación de Cuenta Ordenante, (ii) monto agregado de cargos + saldo insoluto de CANs y créditos no-CAN + fecha límite liquidación, (iii) monto y fecha de cada abono de últimos 6 meses (mínimo 3 si el período es menor)",
         "reporte","evento","critico","2018-01-01",
         "Plazo crítico: 1 Día Hábil Bancario desde la consulta"),
        ("CAN-OBL-016","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 22 Bis 1 fracción I inciso e)",
         "Respetar prelación al cargar la Cuenta Ordenante: (i) créditos no-CAN previos con la misma institución depositaria, (ii) CANs en orden de fecha y hora de designación, (iii) Domiciliaciones de bienes/servicios y otros créditos no-CAN. Si fondos insuficientes para un CAN, cargar lo disponible y completar con siguientes abonos",
         "control","diario","critico","2018-01-01",
         "Regla crítica que impacta el motor de procesamiento de cargos de bdiadminnomina"),
        ("CAN-OBL-017","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 22 Bis 1 fracción I inciso f)",
         "Al abrir nueva Cuenta Ordenante y habiendo sido notificada de CANs vigentes previos en otra cuenta del mismo cuentahabiente (via Art. 63 Bis 3), la nueva institución depositaria debe efectuar los cargos de esos CANs en la prelación correspondiente",
         "control","evento","alto","2018-01-01",
         "Aplica al momento de apertura de nueva Cuenta Ordenante cuando hay CANs previos conocidos"),
        ("CAN-OBL-018","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 22 Bis 1 fracción II",
         "Al abrir/designar Cuenta Ordenante, obtener mandato del cuentahabiente autorizando expresamente a la institución para: proporcionar información regulatoria y consultar (via Art. 63 Bis 3) si tiene CANs previos. Puede ser escrito, electrónico o huella digital",
         "control","evento","critico","2018-01-01",
         "Sin este mandato la institución no puede legalmente consultar ni compartir información CAN del cliente"),
        ("CAN-OBL-019","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 22 Bis 1 fracción II párrafos 2-4",
         "Al abrir/designar Cuenta Ordenante cuando otra institución tiene CANs previos del mismo cuentahabiente, comunicar a esa institución: (i) nombre de la institución que abre la cuenta, (ii) número y CLABE de la nueva Cuenta Ordenante, (iii) nombre completo, RFC (con homoclave) y CURP del cuentahabiente",
         "reporte","evento","alto","2018-01-01",
         "Información solo puede usarse para identificar a la institución acreedora del CAN — no para otros fines"),
        ("CAN-OBL-020","Banxico","Circular 3/2012 mod. 7/2019 y 6/2025","Art. 65",
         "Cuando el cuentahabiente solicite cancelar la Domiciliación de un CAN de otra institución/SOFOM, el Banco del Cliente debe informar a esa institución/SOFOM via mecanismo Art. 63 Bis 3, a más tardar al DHB siguiente a la recepción de la solicitud de cancelación",
         "control","evento","alto","2019-01-01",
         "Plazo: 1 Día Hábil Bancario desde la solicitud de cancelación"),
        ("CAN-OBL-021","Banxico","Circular 3/2012 mod. 15/2018 y 6/2025","Art. 68 párrafo 2",
         "Para objeciones de Domiciliaciones relacionadas con CANs, resolver en máximo 5 Días Hábiles Bancarios. Si procede la objeción, abonar a más tardar al DHB siguiente a la fecha de resolución",
         "control","evento","alto","2018-01-01",
         "Plazo diferente al régimen general (60 días); es plazo especial CAN"),
        ("CAN-OBL-022","Banxico","Circular 3/2012 mod. 7/2019 y 6/2025","Art. 68 párrafo 3",
         "Para objeciones de CANs otorgados por otra institución/SOFOM, remitir copia de la notificación de objeción a esa institución/SOFOM en máximo 2 DHB. La institución/SOFOM debe responder en máximo 3 DHB adicionales",
         "control","evento","alto","2019-01-01",
         "Plazo: 2 DHB para remitir + 3 DHB para respuesta de la acreedora"),
        ("CAN-OBL-023","Banxico","Circular 3/2012 mod. 7/2015, 15/2018 y 7/2019","Art. 75",
         "La Institución Ordenante debe ejecutar transferencias de Prestaciones Laborales a Cuenta Receptora: (a) el mismo DHB si el abono llega antes de las 17:00:00 hrs, (b) el DHB siguiente si llega después de las 17:00:00. Excepción: si debe cargar previamente montos de CANs. Sin costo para el cuentahabiente",
         "control","diario","critico","2015-01-01",
         "La excepción CAN es crítica: si hay cargos CAN pendientes, se aplican antes de transferir el remanente"),
    ]
    con.executemany(
        "INSERT OR IGNORE INTO regulatory_obligations VALUES (?,?,?,?,?,?,?,?,?,?)",
        obligaciones)

    con.commit()
    con.close()

    stats(DB)


def stats(db_path: Path):
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    print("\n── CAN Brain ─────────────────────────────────────────────────")
    for t in ("regulatory_obligations","compliance_gaps","user_stories","systems_in_scope"):
        n = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
        print(f"  {t:<30} {n:>6}")
    print("──────────────────────────────────────────────────────────────\n")
    con.close()


if __name__ == "__main__":
    build()
