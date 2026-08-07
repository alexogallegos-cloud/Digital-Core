"""
capacity — Percentiles de carga (txn/min) mes a mes + deteccion de rafagas.

Complementa el forecast de VOLUMEN (diario) con el analisis de CARGA por minuto, para
dimensionar el sistema target y ver si la carga soportada crece.

Inferencia propia (no se adopta la convencion del cliente de percentil sobre 1440 min):
la madrugada muerta contamina el P70. Se infiere la VENTANA OPERATIVA de los datos
(perfil intradia) y los percentiles se calculan sobre la carga de negocio.

Distingue tres cosas:
  - Carga tipica (P70) y pico tipico (P90/P99): demanda servida en horas de operacion.
  - Pico maximo diario: la demanda instantanea maxima de un dia normal.
  - Rafagas: minutos con val >> P99 del dia (colas represadas que se liberan tras un
    valle/incidente). No son carga sostenida; se reportan aparte.
"""

import numpy as np
from collections import defaultdict

# Fuentes minuto-a-minuto por canal: (relpath, kind, param)
#   kind='sheet2025' -> hoja (Fecha, Hora, Transacciones)
#   kind='col2026'   -> hoja 'Min a min SPEI y Eglobal', col con el valor
DIR = "source/spei-aut-ent"
F25 = f"{DIR}/Master_Transacciones minxmin_01-01-25 a 4-mar-26.xlsx"
F26 = f"{DIR}/Transacciones_maestro_Medios_de_Pago.xlsx"

MINUTE_SOURCES = {
    "spei":    [(F25, "sheet2025", "SPEI Recibidos minxmin"), (F26, "col2026", 5)],
    "eglobal": [(F25, "sheet2025", "Eglobal minxmin"),        (F26, "col2026", 7)],
}

DOW = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"]


def load_minute_channel(root, channel):
    """Devuelve by_day[date] = list[(minute_of_day, val)] fusionando fuentes (2026 gana)."""
    import openpyxl
    by_day = {}
    for relpath, kind, param in MINUTE_SOURCES[channel]:
        path = str(root / relpath)
        wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
        tmp = defaultdict(list)
        if kind == "sheet2025":
            ws = wb[param]
            for i, row in enumerate(ws.iter_rows(values_only=True)):
                if i == 0 or row[0] is None:
                    continue
                d = row[0].date() if hasattr(row[0], "date") else row[0]
                h = row[1]
                mod = h.hour * 60 + h.minute if hasattr(h, "hour") else 0
                v = row[2]
                tmp[d].append((mod, float(v) if v is not None else 0.0))
        else:  # col2026
            ws = wb["Min a min SPEI y Eglobal"]
            for i, row in enumerate(ws.iter_rows(values_only=True)):
                if i == 0 or row[0] is None:
                    continue
                dt = row[0]
                d = dt.date() if hasattr(dt, "date") else dt
                mod = dt.hour * 60 + dt.minute if hasattr(dt, "hour") else 0
                v = row[param]
                tmp[d].append((mod, float(v) if v is not None else 0.0))
        wb.close()
        for d, vals in tmp.items():
            by_day[d] = vals          # fuente posterior (2026) gana en solape
    return by_day


def intraday_profile(by_day, min_obs=1400):
    acc = np.zeros(1440); cnt = np.zeros(1440)
    for d, mins in by_day.items():
        if len(mins) < min_obs:
            continue
        for mod, v in mins:
            if 0 <= mod < 1440:
                acc[mod] += v; cnt[mod] += 1
    cnt[cnt == 0] = 1
    return acc / cnt


def operating_window(profile, frac=0.25):
    """Minutos cuyo promedio >= frac*pico. Devuelve (set_minutos, (hora0, hora1))."""
    active = np.where(profile >= frac * profile.max())[0]
    return set(int(m) for m in active), (int(active.min()) // 60, int(active.max()) // 60)


def daily_metrics(by_day, win, min_obs=1400):
    """Por dia completo: percentiles en ventana operativa + max + p50 (para deteccion de valle)."""
    out = {}
    for d, mins in by_day.items():
        if len(mins) < min_obs:
            continue
        oper = np.array([v for mod, v in mins if mod in win], float)
        if len(oper) < 30:
            continue
        out[d] = {
            "p70": float(np.percentile(oper, 70)), "p90": float(np.percentile(oper, 90)),
            "p99": float(np.percentile(oper, 99)), "max": float(oper.max()),
            "p50": float(np.percentile(oper, 50)),
        }
    return out


def monthly(daily):
    by_m = defaultdict(list)
    for d, r in daily.items():
        by_m[(d.year, d.month)].append((d, r))
    rows = []
    for (yr, mo) in sorted(by_m):
        rs = [r for _, r in by_m[(yr, mo)]]
        pico_d, pico_v = max(by_m[(yr, mo)], key=lambda t: t[1]["max"])[0], max(r["max"] for r in rs)
        rows.append({
            "m": f"{yr}-{mo:02d}", "year": yr, "month": mo, "days": len(rs),
            "p70": round(float(np.median([r["p70"] for r in rs]))),
            "p90": round(float(np.median([r["p90"] for r in rs]))),
            "p99": round(float(np.median([r["p99"] for r in rs]))),
            "max_med": round(float(np.median([r["max"] for r in rs]))),
            "pico": round(pico_v), "pico_date": str(pico_d),
        })
    return rows


def detect_bursts(by_day, daily, win, cal=None, atypical=None, k=2.5, top=20):
    """Minutos con val > k * P99_dia. Marca si hay valle en los 30 min previos (recuperacion)."""
    atypical = atypical or set()
    bursts = []
    for d, mins in by_day.items():
        if d not in daily:
            continue
        p99 = daily[d]["p99"]; p50 = daily[d]["p50"]
        thr = k * p99
        mp = {mod: v for mod, v in mins}
        for mod, v in mins:
            if mod not in win or v <= thr:
                continue
            prev = [mp.get(m, 0) for m in range(max(0, mod - 30), mod)]
            valley = bool(prev) and min(prev) < 0.10 * p50   # colapso previo -> recuperacion
            near_inc = any(abs((d - a).days) <= 1 for a in atypical)
            tag = []
            if cal is not None:
                if d in cal.q15 or d in cal.qfin:
                    tag.append("quincena")
                if not cal.is_business_day(d):
                    tag.append("no-habil")
            bursts.append({
                "date": str(d), "dow": DOW[d.weekday()],
                "time": f"{mod//60:02d}:{mod%60:02d}", "val": round(v),
                "x_over_p99": round(v / p99, 1), "recovery": valley,
                "near_incident": near_inc, "calendar": tag,
            })
    bursts.sort(key=lambda b: -b["val"])
    return bursts[:top]
