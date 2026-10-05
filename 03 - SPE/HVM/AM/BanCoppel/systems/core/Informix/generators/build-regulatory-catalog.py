"""
build-regulatory-catalog.py
Puebla regulatory_obligations y sp_regulatory_links desde la evidencia
ya disponible en brain.db (rules.reg + domains.reg).

No requiere entrevistas — la señal regulatoria fue extraída del código SPL.
Ejecutar después de build-brain.py y seed-itom-layer.py.

Uso: python generators/build-regulatory-catalog.py [--dry-run]
"""
import sqlite3
import pathlib
import sys
import json
from datetime import date

BRAIN = pathlib.Path(__file__).parent.parent / "digital-brain" / "brain.db"
DRY_RUN = "--dry-run" in sys.argv
TODAY = str(date.today())

# ---------------------------------------------------------------------------
# Catálogo canónico de obligaciones regulatorias para BanCoppel (CNBV-licensed)
# Derivado de: reguladores detectados en rules.reg + contexto banca múltiple MX
# ---------------------------------------------------------------------------
OBLIGATIONS = [
    # CNBV
    {
        "obligation_id": "OBL-CNBV-001",
        "regulator": "CNBV",
        "instrument": "Circular Única de Bancos (CUB)",
        "article": "Anexos 33–36 (Reportes Regulatorios)",
        "description": "Reportería financiera periódica a la CNBV: balance, estado de resultados, cartera crediticia, captación, índices de capitalización (Basilea III).",
        "obligation_type": "reporting",
        "frequency": "monthly",
        "penalty_risk": "high",
        "effective_date": "2016-01-01",
        "notes": "Incluye R01 (balance), R04 (crédito), R24 (captación), R25 (capitalización). Genera ~1,304 reglas SPL con señal CNBV.",
    },
    {
        "obligation_id": "OBL-CNBV-002",
        "regulator": "CNBV",
        "instrument": "LGOAIDSBT / Disposiciones PLD-FT",
        "article": "Arts. 115–116 LIC; Reglas CNBV PLD",
        "description": "Prevención de Lavado de Dinero y Financiamiento al Terrorismo: KYC, monitoreo de operaciones inusuales/relevantes, reporte UIFE/UIF.",
        "obligation_type": "compliance",
        "frequency": "continuous",
        "penalty_risk": "critical",
        "effective_date": "2013-07-17",
        "notes": "Dominios D17-D49 con mayor concentración. Requiere sp_regulatory_links hacia reglas de monitoreo transaccional.",
    },
    {
        "obligation_id": "OBL-CNBV-003",
        "regulator": "CNBV",
        "instrument": "Disposiciones Generales de Bancos (LRAF / LIC)",
        "article": "LIC Arts. 1-164",
        "description": "Operación general como institución de banca múltiple: reservas, límites de concentración, gobierno corporativo, auditoría, transparencia.",
        "obligation_type": "operational",
        "frequency": "continuous",
        "penalty_risk": "high",
        "effective_date": "1990-07-18",
        "notes": "Marco base de operación bancaria. Transversal a todos los dominios.",
    },
    # CONDUSEF
    {
        "obligation_id": "OBL-CDF-001",
        "regulator": "CONDUSEF",
        "instrument": "LTOSFCB (Ley de Transparencia y Ordenamiento de Servicios Financieros)",
        "article": "Arts. 1-53",
        "description": "Transparencia en tasas, comisiones, CAT; estados de cuenta; contratos de adhesión; publicidad de productos financieros.",
        "obligation_type": "compliance",
        "frequency": "continuous",
        "penalty_risk": "high",
        "effective_date": "2007-01-26",
        "notes": "~306 reglas con señal CONDUSEF. Principalmente en módulos de crédito, cuentas y estados de cuenta.",
    },
    {
        "obligation_id": "OBL-CDF-002",
        "regulator": "CONDUSEF",
        "instrument": "Buró de Entidades Financieras",
        "article": "Art. 10-bis LIC; Acuerdo CONDUSEF BEF",
        "description": "Publicación periódica de información de desempeño ante el Buró de Entidades Financieras de la CONDUSEF.",
        "obligation_type": "reporting",
        "frequency": "quarterly",
        "penalty_risk": "medium",
        "effective_date": "2014-03-01",
        "notes": "Requiere cálculo y envío de métricas de quejas, resoluciones y productos.",
    },
    {
        "obligation_id": "OBL-CDF-003",
        "regulator": "CONDUSEF",
        "instrument": "RECA (Registro de Contratos de Adhesión)",
        "article": "Art. 11 LTOSFCB",
        "description": "Registro y actualización de contratos de adhesión de productos financieros ante la CONDUSEF.",
        "obligation_type": "compliance",
        "frequency": "on-change",
        "penalty_risk": "medium",
        "effective_date": "2007-01-26",
        "notes": "Aplica a tarjetas, créditos personales, cuentas de ahorro.",
    },
    # Banxico
    {
        "obligation_id": "OBL-BXC-001",
        "regulator": "Banxico",
        "instrument": "Circular SPEI (Sistema de Pagos Electrónicos Interbancarios)",
        "article": "Circular 14/2017 Banxico y modificaciones",
        "description": "Operación del Sistema de Pagos Electrónicos Interbancarios: envío/recepción de transferencias interbancarias, ventanas operativas, reportes de disponibilidad.",
        "obligation_type": "operational",
        "frequency": "continuous",
        "penalty_risk": "critical",
        "effective_date": "2004-08-13",
        "notes": "~657 endpoints en external_systems. Genera señal en dominios de pagos y transferencias.",
    },
    {
        "obligation_id": "OBL-BXC-002",
        "regulator": "Banxico",
        "instrument": "CoDi / DiMo (Cobro Digital / Dinero Móvil)",
        "article": "Circular 14/2017 Apéndice CoDi",
        "description": "Participación en CoDi: generación y cobro de peticiones de pago QR/NFC; reportes de operaciones; disponibilidad del servicio.",
        "obligation_type": "operational",
        "frequency": "continuous",
        "penalty_risk": "high",
        "effective_date": "2019-09-30",
        "notes": "~215 endpoints en external_systems. Obligatoria para bancos con canal digital activo.",
    },
    {
        "obligation_id": "OBL-BXC-003",
        "regulator": "Banxico",
        "instrument": "Circular 3/2012 Banxico (Instituciones de Banca Múltiple)",
        "article": "Arts. diversos",
        "description": "Obligaciones generales ante Banco de México: encaje legal, reportes de operaciones cambiarias, información de tasas y spreads.",
        "obligation_type": "reporting",
        "frequency": "monthly",
        "penalty_risk": "high",
        "effective_date": "2012-03-23",
        "notes": "~117 reglas con señal Banxico pura.",
    },
    # SAT
    {
        "obligation_id": "OBL-SAT-001",
        "regulator": "SAT",
        "instrument": "CFF / LISR — CFDI y Retenciones",
        "article": "CFF Arts. 29, 29-A; LISR Art. 96",
        "description": "Emisión de CFDI por retenciones e información de pagos: intereses, arrendamiento, dividendos; timbrado y envío al SAT.",
        "obligation_type": "reporting",
        "frequency": "per-transaction",
        "penalty_risk": "high",
        "effective_date": "2014-01-01",
        "notes": "~24+ reglas SAT pura + combinadas SAT;CNBV (~88) y SAT;IPAB (~38). Dominio fiscal/retenciones.",
    },
    {
        "obligation_id": "OBL-SAT-002",
        "regulator": "SAT",
        "instrument": "LISR / LIVA — Declaraciones Informativas",
        "article": "LISR Arts. 76-VIII, 86; LIVA Art. 32-VIII",
        "description": "Declaraciones informativas anuales: operaciones con terceros (DIOT), retenciones por salarios, intereses bancarios pagados.",
        "obligation_type": "reporting",
        "frequency": "annual",
        "penalty_risk": "high",
        "effective_date": "2002-01-01",
        "notes": "Genera necesidad de consolidación de datos fiscales del sistema.",
    },
    # IPAB
    {
        "obligation_id": "OBL-IPAB-001",
        "regulator": "IPAB",
        "instrument": "Ley de Protección al Ahorro Bancario (LPAB)",
        "article": "Arts. 6, 10, 12, 67",
        "description": "Reportería de depósitos asegurados al IPAB; cálculo y pago de cuotas al seguro de depósitos; mantenimiento de la base de depositantes protegidos.",
        "obligation_type": "reporting",
        "frequency": "quarterly",
        "penalty_risk": "high",
        "effective_date": "1999-01-19",
        "notes": "~73 reglas puras + combinadas (CNBV;IPAB ~42, SAT;IPAB ~38). Cuentas de ahorro y cheques.",
    },
    # TESOFE
    {
        "obligation_id": "OBL-TSF-001",
        "regulator": "TESOFE",
        "instrument": "Ley Federal de Presupuesto y Responsabilidad Hacendaria",
        "article": "Arts. 89-95 LFPRH; Acuerdos TESOFE",
        "description": "Procesamiento de pagos del Gobierno Federal a través de la TESOFE: nómina federal, transferencias gubernamentales, pagos masivos.",
        "obligation_type": "operational",
        "frequency": "per-transaction",
        "penalty_risk": "high",
        "effective_date": "2006-03-30",
        "notes": "~22 reglas con señal TESOFE. Integración directa con TESOFE para pagos del sector público.",
    },
    # IMSS
    {
        "obligation_id": "OBL-IMSS-001",
        "regulator": "IMSS",
        "instrument": "LSS (Ley del Seguro Social)",
        "article": "Arts. 15, 27-39 LSS; Reglas IMSS IDSE",
        "description": "Procesamiento de aportaciones de seguridad social de empleados de BanCoppel y/o clientes corporativos: IMSS, INFONAVIT, SUA.",
        "obligation_type": "operational",
        "frequency": "monthly",
        "penalty_risk": "medium",
        "effective_date": "1997-07-01",
        "notes": "~10 reglas con señal IMSS. Módulo de nómina/pagos corporativos.",
    },
]

# Mapeo: string que aparece en rules.reg → obligation_ids que aplican
# Un reg puede tener múltiples obligaciones (ej. "CNBV" → OBL-CNBV-001 + 002 + 003)
# Usamos el obligación más representativa para el link (evitar explosión cartesiana)
REG_TO_OBL: dict[str, list[str]] = {
    "CNBV":      ["OBL-CNBV-001", "OBL-CNBV-002", "OBL-CNBV-003"],
    "CONDUSEF":  ["OBL-CDF-001"],
    "Banxico":   ["OBL-BXC-001", "OBL-BXC-003"],
    "SAT":       ["OBL-SAT-001", "OBL-SAT-002"],
    "IPAB":      ["OBL-IPAB-001"],
    "TESOFE":    ["OBL-TSF-001"],
    "IMSS":      ["OBL-IMSS-001"],
}


def parse_reg(reg_str: str) -> list[str]:
    """Descompone 'CNBV; SAT; IPAB' en ['CNBV', 'SAT', 'IPAB']."""
    if not reg_str or reg_str in ("[]", ""):
        return []
    # Puede venir como lista JSON o como 'A; B; C'
    if reg_str.startswith("["):
        try:
            return [r.strip() for r in json.loads(reg_str) if r.strip()]
        except Exception:
            pass
    return [r.strip() for r in reg_str.replace(";", ",").split(",") if r.strip()]


def build_links(db: sqlite3.Connection) -> list[dict]:
    """Genera sp_regulatory_links desde rules.reg."""
    links = []
    seen: set[tuple] = set()

    cur = db.execute(
        "SELECT sp, db, reg FROM rules "
        "WHERE reg IS NOT NULL AND reg != '' AND reg != '[]'"
    )
    for row in cur:
        # rules.sp ya viene en formato db:sp_name — no anteponer db de nuevo
        sp_key = row['sp']
        regs = parse_reg(row['reg'])
        for reg_token in regs:
            # Normalizar tokens duplicados como "CNBV; CNBV"
            for obl_id in REG_TO_OBL.get(reg_token, []):
                key = (sp_key, obl_id)
                if key in seen:
                    continue
                seen.add(key)
                links.append({
                    "sp_key": sp_key,
                    "obligation_id": obl_id,
                    "evidence_type": "rule_reg_signal",
                    "confidence": "medium",
                    "notes": f"Señal rules.reg='{reg_token}' → {obl_id} ({TODAY})",
                })
    return links


def main() -> None:
    if not BRAIN.exists():
        print(f"ERROR: brain.db no encontrado en {BRAIN}")
        sys.exit(1)

    with sqlite3.connect(BRAIN) as db:
        db.row_factory = sqlite3.Row

        # --- Paso 1: regulatory_obligations ---
        print(f"Catalogando {len(OBLIGATIONS)} obligaciones regulatorias...")
        if DRY_RUN:
            for o in OBLIGATIONS:
                print(f"  {o['obligation_id']:<18} {o['regulator']:<12} {o['instrument'][:45]}")
        else:
            db.execute("DELETE FROM regulatory_obligations")
            db.executemany(
                "INSERT INTO regulatory_obligations "
                "(obligation_id, regulator, instrument, article, description, "
                "obligation_type, frequency, penalty_risk, effective_date, notes) "
                "VALUES (:obligation_id, :regulator, :instrument, :article, :description, "
                ":obligation_type, :frequency, :penalty_risk, :effective_date, :notes)",
                OBLIGATIONS,
            )
            print(f"  regulatory_obligations: {len(OBLIGATIONS)} obligaciones insertadas")

        # --- Paso 2: sp_regulatory_links ---
        print("\nGenerando sp_regulatory_links desde rules.reg...")
        links = build_links(db)
        print(f"  Links generados: {len(links)}")

        if DRY_RUN:
            print("\n  Muestra (10 primeros):")
            for lk in links[:10]:
                print(f"  {lk['sp_key'][:38]:<38} → {lk['obligation_id']}")
            # Resumen por obligation
            from collections import Counter
            counts = Counter(lk['obligation_id'] for lk in links)
            print("\n  Por obligación:")
            for obl, n in sorted(counts.items()):
                print(f"    {obl:<18} {n:>5} SPs vinculados")
        else:
            db.execute("DELETE FROM sp_regulatory_links")
            db.executemany(
                "INSERT INTO sp_regulatory_links "
                "(sp_key, obligation_id, evidence_type, confidence, notes) "
                "VALUES (:sp_key, :obligation_id, :evidence_type, :confidence, :notes)",
                links,
            )
            db.commit()
            print(f"  sp_regulatory_links: {len(links)} links insertados")

            # Resumen por obligación
            print("\nDistribución por obligación:")
            cur = db.execute(
                "SELECT l.obligation_id, o.regulator, COUNT(*) n "
                "FROM sp_regulatory_links l "
                "JOIN regulatory_obligations o ON l.obligation_id = o.obligation_id "
                "GROUP BY l.obligation_id ORDER BY n DESC"
            )
            for r in cur:
                print(f"  {r['obligation_id']:<18} [{r['regulator']:<10}] {r['n']:>5} SPs")

        # --- Paso 3: knowledge_completeness ---
        if not DRY_RUN:
            cur = db.execute("SELECT dimension, total_items, fill_pct FROM knowledge_completeness")
            print("\nknowledge_completeness actualizado:")
            for r in cur:
                status = "✅" if r['fill_pct'] == 100 else ("⚠️" if r['fill_pct'] > 0 else "❌")
                print(f"  {status} {r['dimension']:<15} {r['total_items']:>6} ítems  {r['fill_pct']:.0f}%")


if __name__ == "__main__":
    main()