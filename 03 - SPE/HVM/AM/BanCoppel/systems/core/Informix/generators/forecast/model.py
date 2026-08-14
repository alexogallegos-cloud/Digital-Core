"""
model — Ajuste OLS log-lineal con remocion iterativa de outliers + interpretacion.

log V(t) = b0 + b1*t + sum_k bk * factor_k(t) + e
  b1 (coef. de t) = crecimiento organico diario; mensual = exp(b1*30)-1.
  Cada bk en log => efecto multiplicativo: exp(bk)-1 es el % del factor.
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm
from datetime import date

from . import factors as F


def fit_channel(df, channel, features, include_weekends, min_vol=500_000,
                max_iter=2, resid_thresh=2.5, verbose=True):
    """
    Filtra a dias validos y ajusta OLS sobre log(volumen).

    PRINCIPIO DE REMOCION (condicional): un dia atipico (|t* externo| > resid_thresh) SOLO
    se remueve si NO tiene ninguna etiqueta de calendario que lo explique — es decir, si su
    desviacion es por un incidente o algo no predecible. Los dias atipicos que caen en una
    temporalidad conocida (aguinaldo, pre-cierre, rebote de quincena, etc.) NO se descartan:
    se mantienen en el ajuste y se reportan como 'mantenido' para calibrar con mas datos o,
    si procede, promover a factor. Los incidentes documentados ya se excluyen antes via
    atypical_days.

    Devuelve (modelo, df_limpio, eventos), donde eventos incluye tanto los removidos
    (action='removed') como los atipicos explicables mantenidos (action='kept_explained').
    """
    dow_mask = (df["dow"] < 7) if include_weekends else (df["dow"] < 5)
    df_m = df[
        (df["is_atypical"] == 0) &
        (df["is_holiday"] == 0) &
        dow_mask &
        (df[channel] >= min_vol)
    ].copy()

    span = "7 dias (riel 24/7)" if include_weekends else "dias habiles L-V"
    if verbose:
        print(f"\n  {channel.upper()} [{span}]: {len(df_m)} dias tras filtro base")

    events = []
    model = None
    for it in range(max_iter + 1):
        df_m = df_m.reset_index(drop=True)
        df_m["log_vol"] = np.log(df_m[channel])
        X = sm.add_constant(df_m[features])
        model = sm.OLS(df_m["log_vol"], X).fit()
        if it == max_iter:
            break
        stud = model.get_influence().resid_studentized_external
        big = np.abs(stud) > resid_thresh
        if not big.any():
            if verbose:
                print(f"  Iter {it+1}: sin atipicos (convergido)")
            break

        remove_idx = []
        for pos in np.where(big)[0]:
            r = df_m.iloc[pos]
            tags = _calendar_tags(r)
            explained = len(tags) > 0
            rec = {
                "date": str(r["d"]),
                "dow": ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"][int(r["dow"])],
                "vol": int(r[channel]),
                "t_star": round(float(stud[pos]), 2),
                "iter": it + 1,
                "fitted": int(np.exp(model.fittedvalues.iloc[pos])),
                "calendar": tags,
                "action": "kept_explained" if explained else "removed",
            }
            # kept_explained se registra una sola vez (en la 1a iteracion que aparece)
            if explained:
                if not any(e["date"] == rec["date"] and e["action"] == "kept_explained" for e in events):
                    events.append(rec)
            else:
                events.append(rec)
                remove_idx.append(pos)

        n_rm = len(remove_idx)
        if verbose:
            n_kept = int(big.sum()) - n_rm
            print(f"  Iter {it+1}: {n_rm} removidos (inexplicables) · "
                  f"{n_kept} atipicos explicables mantenidos")
        if n_rm == 0:
            break                    # solo quedan atipicos explicables -> convergido
        df_m = df_m.drop(df_m.index[remove_idx])

    if verbose:
        print(f"  Final: {len(df_m)} obs · R2={model.rsquared:.4f}")
    return model, df_m, events


def _calendar_tags(row):
    """Etiquetas de calendario activas en un dia (para razonar outliers)."""
    tags = []
    for name in F.FACTORS:
        if name.startswith("dow_"):
            continue
        try:
            if int(row.get(name, 0)) == 1:
                tags.append(name)
        except (TypeError, ValueError):
            pass
    return tags


def residual_report(model, df_clean, channel, top=25):
    """Top-N dias por |residuo estudentizado| dentro del set limpio (para buscar patrones)."""
    stud = model.get_influence().resid_studentized_external
    df = df_clean.reset_index(drop=True).copy()
    df["t_star"] = stud
    df["abs_t"] = np.abs(stud)
    df = df.sort_values("abs_t", ascending=False).head(top)
    rows = []
    for _, r in df.iterrows():
        rows.append({
            "date": str(r["d"]),
            "dow": ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"][int(r["dow"])],
            "vol": int(r[channel]),
            "t_star": round(float(r["t_star"]), 2),
            "calendar": _calendar_tags(r),
        })
    return rows


def interpret(model, label, factor_labels, n_raw):
    names = list(model.params.index)
    annual = "annual_doy" in names   # Autorizador: patron anual repetible sobre dia-del-anio

    bt = model.params["t"]
    ci = model.conf_int()
    mg = (np.exp(bt * 30) - 1) * 100
    mlo = (np.exp(ci.loc["t", 0] * 30) - 1) * 100
    mhi = (np.exp(ci.loc["t", 1] * 30) - 1) * 100
    ag = (np.exp(bt * 365) - 1) * 100
    p_t = float(model.pvalues["t"])

    if annual:
        # pendientes intra-anuales del patron repetible (sobre doy), en %/mes por tramo.
        # La tendencia de crecimiento anio-a-anio es 't' (arriba); el patron se repite y
        # resetea cada 1-ene.
        hs = [p for p in names if p.startswith("annual_h")]
        segs = [model.params["annual_doy"]]
        for h in hs:
            segs.append(segs[-1] + model.params[h])
        segments_pct = [round((np.exp(s * 30) - 1) * 100, 2) for s in segs]
    else:
        segments_pct = None

    print(f"\n{'='*68}\n  {label}\n{'='*68}")
    print(f"  R2 {model.rsquared:.4f} (adj {model.rsquared_adj:.4f}) · obs {int(model.nobs)}/{n_raw}")
    print(f"  {'Tendencia anio-a-anio' if annual else 'Crecimiento'}/mes {mg:+.2f}% "
          f"IC95%[{mlo:+.2f}%,{mhi:+.2f}%] · /anio {ag:+.1f}%")
    if segments_pct:
        print(f"  Patron anual repetible (%/mes intra-anio por tramo): {segments_pct}")
    print(f"\n  {'Factor':<42} {'Efecto':>8} {'p':>8}")
    print(f"  {'-'*60}")
    factors_out = {}
    for k, lbl in factor_labels.items():
        if k not in model.params:
            continue
        b, pv = model.params[k], model.pvalues[k]
        pct = (np.exp(b) - 1) * 100
        sig = "***" if pv < 0.001 else ("**" if pv < 0.01 else ("*" if pv < 0.05 else ""))
        print(f"  {lbl:<42} {pct:>+7.1f}% {pv:>8.4f} {sig}")
        factors_out[k] = {"pct_effect": round(pct, 1), "pvalue": round(float(pv), 4)}

    return {
        "label": label,
        "r2": round(model.rsquared, 4),
        "r2_adj": round(model.rsquared_adj, 4),
        "n_obs": int(model.nobs),
        "monthly_growth_pct": round(mg, 3),
        "monthly_ci_low": round(mlo, 3),
        "monthly_ci_high": round(mhi, 3),
        "annual_growth_pct": round(ag, 2),
        "p_value_t": p_t,
        "segments_pct": segments_pct,
        "factors": factors_out,
    }


def build_future(cal, start_d, end_d):
    dates = pd.date_range(start_d, end_d, freq="D")
    return F.build_features(pd.DataFrame({"date": dates}), cal)


def forecast_points(model, df_future, features):
    df_f = df_future.reset_index(drop=True)
    X = sm.add_constant(df_f[features], has_constant="add")
    pred = model.get_prediction(X)
    means = np.exp(pred.predicted_mean)
    ci = np.exp(pred.conf_int())
    rows = []
    for j, row in df_f.iterrows():
        rows.append({
            "date": str(row["d"]), "mean": int(means[j]),
            "ci_low": int(ci[j, 0]), "ci_high": int(ci[j, 1]),
        })
    return rows
