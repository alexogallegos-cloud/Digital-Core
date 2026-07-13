import json, re, glob, sys
sys.stdout.reconfigure(encoding='utf-8')
CG = json.load(open('callgraph-data.json', encoding='utf-8'))['graph']
entry = {n['id'] for n in CG['nodes'] if n.get('fan_in', 0) == 0}
allids = {n['id'] for n in CG['nodes']}

def fid(path):
    b = re.split(r'[\\/]', path)[-1]
    if b.endswith('.sql'): b = b[:-4]
    if '_sp_' in b:
        db, rest = b.split('_sp_', 1); return db + ':sp_' + rest
    return None

SIG = {
 "SPEI · Banxico": r"spei", "CoDi · Banxico": r"codi(?!g|f)", "SPID USD": r"spid", "CEP · Banxico": r"\bcep\b",
 "Western Union": r"western|\bwu_", "MoneyGram": r"moneygram|money.?gram|mgram",
 "Buró de Crédito": r"\bburo\b|circulo.?de.?credito", "PROSA (switch)": r"\bprosa\b",
 "OXXO/corresponsal": r"\boxxo\b|corresponsal", "Domiciliación": r"domiciliaci",
 "Nómina/dispersión": r"nomina|dispersa|dispersion", "CNBV": r"cnbv", "SAT (fiscal)": r"\bsat\b",
 "UIF/PLD": r"\bpld\b|antilavado", "IPAB": r"ipab", "CONDUSEF": r"condusef", "TESOFE": r"tesofe",
 "App móvil": r"\bmovil\b|\bmvl\b", "Banca x Internet": r"\bbpi\b", "BanCoppel Clic": r"\bclic\b", "Cajero/ATM": r"\batm\b|cajero",
}
CP = {k: re.compile(v, re.I) for k, v in SIG.items()}
tot = {k: 0 for k in SIG}; eps = {k: 0 for k in SIG}
files = glob.glob('source/**/*.sql', recursive=True)
mapped = 0
for f in files:
    try:
        t = open(f, 'rb').read().decode('latin-1').lower()
    except Exception:
        continue
    nid = fid(f)
    if nid in allids: mapped += 1
    is_ep = nid in entry
    for k, rx in CP.items():
        if rx.search(t):
            tot[k] += 1
            if is_ep: eps[k] += 1
with open('_endpoints.log', 'w', encoding='utf-8') as o:
    o.write(f"files={len(files)} mapped={mapped} entrypoints={len(entry)}/{len(allids)}\n")
    for k in sorted(SIG, key=lambda x: -eps[x]):
        o.write(f"{k}\t{tot[k]}\t{eps[k]}\n")
    o.write("ENDPOINTS_DONE\n")