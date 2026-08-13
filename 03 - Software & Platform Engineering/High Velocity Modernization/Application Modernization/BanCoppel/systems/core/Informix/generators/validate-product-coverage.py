#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Validación: ¿qué productos BanCoppel aparecen en el lenguaje del código?
   Cuenta ocurrencias de cada producto (por nombre y por código interno) en el corpus."""
import re, io, sys, json
from collections import Counter
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
rules = json.load(open(BASE+"portal/data/business-rules-v3.json", encoding="utf-8"))["rules"]

# producto -> patrones (nombre y/o código interno) a buscar en code+sp+name
PRODUCTS = {
    'Tarjeta de Crédito':      r'\btdc\b|tarjeta.{0,3}cred|\btarjcred|tarjetacredito',
    'Tarjeta de Débito':       r'\btdd\b|tarjeta.{0,3}deb',
    'Grupo Coppel / Crédito Coppel (cope)': r'\bcope\b|grupo.?coppel|credito.?coppel',
    'Crédito al Consumo (cartconsumo)':     r'cartconsumo|cartera.?consumo|\bconsumo\b',
    'Préstamo Personal':       r'prestamo|prest_pers|\bpp\b',
    'Cuenta de Cheques':       r'\bcheq|cuenta.?cheq|bdicheq',
    'Cuenta / Nómina':         r'nomina|\bnom\b|cuentanom',
    'Pagaré':                  r'pagare|pagar[eé]',
    'Inversión Creciente':     r'invcrec|inversion.?creciente|inv_crec',
    'Inversiones (general)':   r'\binv\b|inversion',
    'Afore Coppel':            r'\bafore\b',
    'Buró de Crédito':         r'\bburo\b|burofisic|circulocredito',
    'Línea de Crédito (cci)':  r'\bcci\b|lineamaxima|lincred|linea.?credito',
    'Remesas':                 r'\bremesa|\brem\b',
    'SPEI / Pagos':            r'\bspei\b',
    'Reservas CNBV (cartera)': r'reserva|calificacion|cub.?b',
}

counts = {p: 0 for p in PRODUCTS}
compiled = {p: re.compile(pat, re.I) for p, pat in PRODUCTS.items()}
for r in rules:
    blob = ' '.join([(r.get('code','') or ''), (r.get('sp','') or ''),
                     (r.get('business_name','') or ''), (r.get('dominio','') or '')]).lower()
    for p, rx in compiled.items():
        if rx.search(blob):
            counts[p] += 1

N = len(rules)
print(f"PRODUCTOS COMO LENGUAJE — cobertura en {N:,} reglas\n")
print(f"  {'Producto':42} {'reglas':>7}  {'%':>6}")
for p, c in sorted(counts.items(), key=lambda x: -x[1]):
    print(f"  {p:42} {c:7,}  {c/N*100:5.1f}%")
tot = sum(1 for r in rules if any(rx.search(' '.join([(r.get('code','') or ''),(r.get('sp','') or ''),(r.get('business_name','') or '')]).lower()) for rx in compiled.values()))
print(f"\n  Reglas que tocan ≥1 producto identificable: {tot:,} ({tot/N*100:.0f}%)")
