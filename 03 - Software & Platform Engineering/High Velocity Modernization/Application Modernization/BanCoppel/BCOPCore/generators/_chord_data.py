import json, os, re, glob
from collections import defaultdict
BASE = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')) + os.sep
CG = json.load(open(BASE + 'portal/data/callgraph-data.json', encoding='utf-8'))['graph']
entry = {n['id'] for n in CG['nodes'] if n.get('fan_in', 0) == 0}

DOM = {  # db -> nombre de dominio (orden D01..D12)
 'bdicnweb': 'D01 Canal Web', 'bdinteg': 'D02 Integración', 'bdicred': 'D03 Crédito',
 'bdicheq': 'D04 Cheques', 'bdisac': 'D05 SAC', 'bdisolic': 'D06 Solicitudes',
 'bdiaclaracion': 'D07 Aclaraciones', 'bdispei': 'D08 SPEI', 'bdimnsj': 'D09 Mensajería',
 'bdisuc': 'D10 Sucursales', 'bdicobranza': 'D11 Cobranza', 'bdicont': 'D12 Contabilidad'}
DOM_ORDER = ['bdicnweb','bdinteg','bdicred','bdicheq','bdisac','bdisolic','bdiaclaracion',
             'bdispei','bdimnsj','bdisuc','bdicobranza','bdicont']

SIG = [
 ("SPEI · Banxico","Pagos Banxico",r"spei"),("CoDi · Banxico","Pagos Banxico",r"codi(?!g|f)"),
 ("SPID USD","Pagos Banxico",r"spid"),
 ("Western Union","Remesas",r"western|\bwu_"),("MoneyGram","Remesas",r"moneygram|money.?gram|mgram"),
 ("Buró de Crédito","Crédito/Tarjetas",r"\bburo\b|circulo.?de.?credito"),("PROSA switch","Crédito/Tarjetas",r"\bprosa\b"),
 ("Cajero/ATM","Red física",r"\batm\b|cajero"),("OXXO/corresponsal","Red física",r"\boxxo\b|corresponsal"),
 ("Domiciliación","Red física",r"domiciliaci"),
 ("CNBV","Reguladores",r"cnbv"),("SAT fiscal","Reguladores",r"\bsat\b"),("UIF/PLD","Reguladores",r"\bpld\b|antilavado"),("IPAB","Reguladores",r"ipab"),
 ("Nómina Coppel","Grupo Coppel",r"nomina|dispersa|dispersion"),
 ("App móvil","Canales propios",r"\bmovil\b|\bmvl\b"),("Banca x Internet","Canales propios",r"\bbpi\b"),("BanCoppel Clic","Canales propios",r"\bclic\b"),
]
CP = [(k, cat, re.compile(rx, re.I)) for k, cat, rx in SIG]
CATS = {"Pagos Banxico":"#2E6B8A","Remesas":"#2E6B48","Crédito/Tarjetas":"#B8860B",
        "Red física":"#A0602A","Reguladores":"#8B3A62","Grupo Coppel":"#F0D224","Canales propios":"#4A6FA5"}

def parse(path):
    b = re.split(r'[\\/]', path)[-1]
    if b.endswith('.sql'): b = b[:-4]
    if '_sp_' in b:
        db, rest = b.split('_sp_', 1); return db, db + ':sp_' + rest
    return None, None

M = defaultdict(lambda: defaultdict(int))  # dominio -> sistema -> endpoints
read = 0
for f in glob.glob(BASE + 'source/**/*.sql', recursive=True):
    db, nid = parse(f)
    if nid not in entry or db not in DOM:  # solo endpoints en un dominio conocido
        continue
    try:
        t = open(f, 'rb').read().decode('latin-1').lower()
    except Exception:
        continue
    read += 1
    dn = DOM[db]
    for k, cat, rx in CP:
        if rx.search(t):
            M[dn][k] += 1

domains = [{"key": DOM[d], "total": sum(M[DOM[d]].values())} for d in DOM_ORDER]
systems = [{"key": k, "cat": cat, "total": sum(M[dn][k] for dn in M)} for k, cat, _ in SIG]
out = {"domains": domains, "systems": systems, "cats": CATS,
       "matrix": {dn: dict(M[dn]) for dn in M}, "endpoints_leidos": read}
json.dump(out, open(BASE + 'portal/data/integrations-data.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(f"endpoints leídos={read} · dominios={len(domains)} · sistemas={len(systems)}")
print("integrations-data.json escrito")