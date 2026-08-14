"""
integrate-triage.py — Integra el triaje del SME Regulatorio de las 50 candidatas.
Reemplaza el veredicto "candidata · SBVR heurístico" por el veredicto del SME
(33 genuinas VALIDADO Regulatorio con norma+severidad · 17 falsos positivos → VALIDADO analista).
"""
import re, glob, os
BASE = os.path.dirname(os.path.abspath(__file__)); RD = os.path.join(BASE, "rules-catalog")
CAND = "En validación — SME Regulatorio (candidata · SBVR heurístico)"
FP = "VALIDADO (analista) — falso positivo regulatorio (triaje SME 2026-07)"
def R(norma, sev): return f"VALIDADO por SME Regulatorio (triaje 2026-07) — {norma} — {sev}"

TRIAGE = {
    # S500 FraudLink / fiscal P310 / AML / gubernamental
    "RN-S500-001": FP, "RN-S500-002": FP, "RN-S500-003": FP,
    "RN-S500-004": R("completitud reporte FraudLink [DATO-REQUERIDO ¿filing CNBV?]", "🟡"),
    "RN-S500-005": R("monitoreo/reporte de fraude, CNBV CUB", "🟠"),
    "RN-S500-006": R("completitud sub-movimientos SAD (fraude)", "🟠"),
    "RN-S500-007": R("completitud claves B13 (fraude)", "🟠"),
    "RN-S500-008": R("cuadre/trailer del reporte de fraude", "🟡"),
    "RN-S500-060": R("SAT/TESOFE saldos de cuentas gubernamentales (10 canales SDO)", "🟠"),
    "RN-S500-185": R("LISR Art. 54/135 retención ISR sobre rendimientos", "🟠"),
    "RN-S500-186": R("LISR ISR residentes en el extranjero; /100 sospechoso HITL", "🟠"),
    "RN-S500-187": R("LISR selección de tasa por tipo de persona (11/12/15)", "🟠"),
    "RN-S500-190": R("LISR Art. 61 exención/beneficiario (STATUS 3/8)", "🟠"),
    "RN-S500-194": R("LIVA Art. 2 IVA frontera 8% vs general 16% por zona", "🔴 pre-cutover"),
    "RN-S500-197": R("SAT constancias de retención; SAT-IDSISTEMA=S152 hardcodeado", "🔴 BLOQUEA CUTOVER"),
    "RN-S500-118": R("aseguramiento/embargo de cuentas (judicial/SAT/PLD, EPP→S111)", "🟠"),
    "RN-S500-207": R("LIC Art. 115 + Disposiciones PLD, bloqueo AML restricciones 12-15", "🔴"),
    "RN-S500-210": R("Ley de Tesorería de la Federación, cuentas TESOFE concentradoras", "🟠"),
    "RN-S500-221": R("aseguramiento por orden judicial (triple copia)", "🔴 silencioso-crítico"),
    "RN-S500-377": R("LPAB reporte IPAB / cuotas del seguro de depósitos", "🟠"),
    "RN-S500-403": R("'Charity III' posible PLD/OFAC [DATO-REQUERIDO norma]", "🟡"),
    "RN-S500-093": R("CNBV CUB Serie R-04 rendimientos brutos de captación", "🟠"),
    "RN-S500-095": R("CNBV CUB Anexo 33 tasas y rendimientos por producto/instrumento", "🟠"),
    "RN-S500-552": R("Banxico tipo de cambio FIX, valuación ME (6 decimales)", "🟡"),
    "RN-S500-123": FP, "RN-S500-124": FP, "RN-S500-137": FP, "RN-S500-152": FP,
    "RN-S500-643": FP + " (preservar audit trail CUB Art. 50)",
    "RN-S500-644": FP + " (preservar audit trail)",
    "RN-S500-645": FP + " (preservar audit trail)",
    "RN-S500-650": FP,
    # S151
    "RN-S151-558": FP, "RN-S151-561": FP,
    "RN-S151-562": FP + " (INDLEY = indicador de ley fiscal, conservar nota)",
    "RN-S151-533": FP,
    "RN-S151-263": FP + " [DATO-REQUERIDO ¿NIO = clave de rastreo SPEI?]",
    "RN-S151-563": R("CNBV CUB Serie B fecha contable vs fecha valor (período)", "🟠"),
    "RN-S151-566": R("CNBV segregación de libros / cuentas de orden [DATO-REQUERIDO valores]", "🟠"),
    "RN-S151-567": R("LIC Art. 73 partes relacionadas / intercompany", "🟠"),
    "RN-S151-568": R("CNBV CUB Art. 50 trazabilidad de cancelaciones", "🟠"),
    "RN-S151-319": R("Banxico/CNBV portabilidad de nómina CONLI (reporte R10)", "🟠"),
    "RN-S151-015": R("CNBV catálogo de libros contables (FOBAPROA→IPAB residual)", "🟠"),
    "RN-S151-222": R("Ley del SAR + CNBV reportes SAR / Concentración Banxico", "🟠"),
    "RN-S151-227": R("Ley del SAR importes IMSS/ISSSTE/INFONAVIT a Banxico", "🟠"),
    "RN-S151-228": R("Ley del SAR / Ley INFONAVIT Art. 39; DEFECTO confirmado saldo anterior INFONAVIT=0 (ADR divergencia intencional)", "🔴 DEFECTO"),
    "RN-S151-231": R("Ley del SAR / INFONAVIT Concentración Banxico (13 aportaciones)", "🟠"),
    "RN-S151-124": R("CNBV normalización de SECTOR económico (Serie R); BUG sector 15→11 (MR-CFR-11)", "🟠 DEFECTO"),
    "RN-S151-139": R("CNBV archivo S115, reporte regulatorio de movimientos contables", "🔴"),
    "RN-S151-167": R("CNBV B-0111B operaciones intercompany (sensible separación Citi)", "🟠"),
}

def run():
    n = miss = 0; unknown = []
    for fp in sorted(glob.glob(os.path.join(RD, "*.md"))):
        txt = open(fp, encoding="utf-8").read()
        if CAND not in txt: continue
        parts = re.split(r'(?m)(?=^#{2,3} RN-S(?:151|500)-\d+)', txt)
        out = []
        for part in parts:
            hm = re.match(r'#{2,3} (RN-S(?:151|500)-\d+)', part)
            if hm and CAND in part:
                rid = hm.group(1)
                if rid in TRIAGE:
                    part = part.replace(f"| **Veredicto** | {CAND} |", f"| **Veredicto** | {TRIAGE[rid]} |")
                    n += 1
                else:
                    unknown.append(rid); miss += 1
            out.append(part)
        open(fp, "w", encoding="utf-8").write("".join(out))
    print(f"Integradas {n} · sin mapa {miss} {unknown}")
    rest = 0
    for fp in glob.glob(os.path.join(RD, "*.md")):
        rest += open(fp, encoding="utf-8").read().count(CAND)
    print(f"Candidatas sin integrar restantes: {rest}")

if __name__ == "__main__":
    run()
