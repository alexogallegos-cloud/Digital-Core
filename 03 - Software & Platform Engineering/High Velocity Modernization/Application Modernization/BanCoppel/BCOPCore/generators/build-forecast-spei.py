#!/usr/bin/env python3
"""
build-forecast-spei.py — BCOPCore · Proyeccion de crecimiento organico SPEI + E-Global.

Orquesta el pipeline generators/forecast/: carga fuentes -> genera factores -> ajusta OLS
(SPEI 7 dias, E-Global dias habiles) con remocion iterativa de outliers -> escribe HTML,
Markdown y el reporte de dias atipicos en knowledge-base/cross-reference/.

Uso: python generators/build-forecast-spei.py   (ejecutar desde BCOPCore/)

Re-ejecutable cada vez que llegan datos reales nuevos: basta registrar la nueva fuente en
forecast/data_sources.py y cualquier incidente en forecast/atypical_days.py.
"""

import sys, json
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parent.parent          # BCOPCore/
sys.path.insert(0, str(Path(__file__).resolve().parent))  # generators/ (para importar forecast)

from forecast import factors as F
from forecast import model as M
from forecast import render as R
from forecast.calendar_mx import MxCalendar
from forecast import data_sources as DS
from forecast import atypical_days as A

OUT_KB     = ROOT / "knowledge-base" / "cross-reference"   # knowledge: MD, CSV, JSON
OUT_PORTAL = ROOT / "portal"                                # presentación: HTML
OUT_KB.mkdir(parents=True, exist_ok=True)
OUT_PORTAL.mkdir(parents=True, exist_ok=True)


def main():
    print("Cargando fuentes de datos...")
    df = DS.load_all(ROOT)

    cal = MxCalendar(range(2023, 2031))
    df = F.build_features(df, cal)
    atypical = A.to_set()
    df["is_atypical"] = df["d"].apply(lambda x: int(x in atypical))

    n_total = len(df)
    print(f"\nDataset: {n_total} dias · dias atipicos excluidos: {int(df.is_atypical.sum())}")

    models, cleans, outliers, results = {}, {}, {}, {}
    for ch in ("eglobal", "spei"):
        cfg = F.CHANNELS[ch]
        feats = F.FEATURE_SETS[ch]
        m, clean, outl = M.fit_channel(df, ch, feats, cfg["include_weekends"], cfg["min_vol"])
        models[ch], cleans[ch], outliers[ch] = m, clean, outl
        results[ch] = M.interpret(m, cfg["label"], F.FACTOR_LABELS, n_total)

    # Salidas
    R.render_html(df, cal, models, cleans, outliers, results, str(OUT_PORTAL / "growth-forecast-autorizador-spei.html"))
    R.render_markdown(results, models, str(OUT_KB / "growth-forecast-autorizador-spei.md"))
    # serie diaria consumible: pasado (real+ajustado) + futuro (proyeccion+banda)
    R.render_series_csv(df, cal, models, cleans, str(OUT_KB / "forecast-series-diaria.csv"))

    # Reporte de dias atipicos: separa removidos (inexplicables) de mantenidos (explicables)
    def split(ch, top):
        ev = outliers[ch]
        return {
            "removed_unexplained": [e for e in ev if e["action"] == "removed"],
            "kept_explained": [e for e in ev if e["action"] == "kept_explained"],
            "largest_residuals_clean": M.residual_report(models[ch], cleans[ch], ch, top=top),
        }
    atypical_report = {"spei": split("spei", 25), "eglobal": split("eglobal", 15)}
    rep_path = OUT_KB / "growth-forecast-outliers.json"
    with open(rep_path, "w", encoding="utf-8") as f:
        json.dump(atypical_report, f, ensure_ascii=False, indent=2)
    print(f"  Outliers: {rep_path}")

    print("\n[OK] Pipeline completo.")


if __name__ == "__main__":
    main()
