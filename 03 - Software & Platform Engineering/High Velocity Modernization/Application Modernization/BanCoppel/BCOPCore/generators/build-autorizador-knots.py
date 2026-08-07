#!/usr/bin/env python3
"""
build-autorizador-knots.py — BCOPCore · Recalibra los knots del patron anual del Autorizador.

El Autorizador (E-Global) tiene un patron ANUAL REPETIBLE modelado como piecewise-linear sobre
el DIA-DEL-ANIO (doy), continuo dentro del anio y con reset en enero. Esta herramienta busca
los knots optimos (donde cambia la pendiente intra-anual) maximizando adjR2, para actualizar
ANNUAL_KNOTS_DOY en forecast/factors.py cuando lleguen datos nuevos.

Uso: python generators/build-autorizador-knots.py   (ejecutar desde BCOPCore/)
NO modifica el pipeline; solo reporta los knots recomendados.
"""
import sys
from pathlib import Path
from itertools import combinations
import numpy as np, pandas as pd, statsmodels.api as sm
from datetime import date, timedelta

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from forecast import data_sources as DS, factors as F, atypical_days as A
from forecast.calendar_mx import MxCalendar

cal = MxCalendar(range(2023, 2031))
df = F.build_features(DS.load_all(ROOT), cal)
df["is_atypical"] = df["d"].apply(lambda x: int(x in A.to_set()))
m = df[(df.is_atypical == 0) & (df.is_holiday == 0) & (df.dow < 7) & (df.eglobal >= 500_000)].copy().reset_index(drop=True)
y = np.log(m["eglobal"]).values

# estacionalidad de corto plazo + moviles (lo que NO es el patron anual de baja frecuencia)
short = ["dow_tue","dow_wed","dow_thu","dow_fri","dow_sat","dow_sun",
         "is_q15_exact","is_qlast_exact","is_q_dp1","is_q_dp2","is_q1st_exact",
         "is_precierre_mes","is_lunes_post_qfinde","is_holiday_eve","is_post_holiday",
         "is_semana_santa","is_pascua_finde","is_aguinaldo"]
Xs = m[short].values.astype(float)
t = m["t"].values.astype(float)
doy = m["doy"].values.astype(float)
mesname = lambda k: (date(2025, 1, 1) + timedelta(int(k) - 1)).strftime("%d-%b")

def fit(knots):
    cols = [Xs, t.reshape(-1, 1), doy.reshape(-1, 1)]
    for k in knots:
        cols.append(np.maximum(0, doy - k).reshape(-1, 1))
    r = sm.OLS(y, sm.add_constant(np.hstack(cols))).fit()
    return r.rsquared_adj, r

cand = list(range(40, 330, 20)); MINSEP = 50
print(f"\nBusqueda de knots del patron anual (doy) · obs={len(m)}\n")
print(f"  n=0 (sin patron): adjR2={fit([])[0]:.4f}")
for n in (1, 2, 3):
    best = (-1, None)
    for combo in combinations(cand, n):
        if any(combo[i+1]-combo[i] < MINSEP for i in range(len(combo)-1)):
            continue
        a, _ = fit(list(combo))
        if a > best[0]:
            best = (a, list(combo))
    a, ks = best
    print(f"  n={n}: knots={ks} ({[mesname(k) for k in ks]})  adjR2={a:.4f}")
print(f"\nActual en factors.py: ANNUAL_KNOTS_DOY = {F.ANNUAL_KNOTS_DOY}")
print("Si el optimo n=2 difiere, actualizar ANNUAL_KNOTS_DOY y re-ejecutar build-forecast-spei.py.")
