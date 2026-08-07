"""
factors — Registro de generadores de factores estacionales.

Cada factor es un generador registrado con @factor(nombre, capa, descripcion). Dado el
DataFrame de dias (con columnas base d, dow, month, dom, t) y un MxCalendar, produce una
columna 0/1 (o continua, para 't'). Agregar una temporalidad nueva = agregar una funcion
con @factor; queda automaticamente disponible, documentada y lista para incluirse en un
FEATURE_SET.

Capas de estacionalidad (el "factor compuesto" del negocio = producto de capas en nivel,
suma en log):
  tendencia         crecimiento organico puro (t)
  dia-semana        efecto del dia de la semana
  ciclo-pagos       quincenas, ventana de deposito, dia 17, primer dia de mes
  calendario-of     festivos oficiales y su vecindad (vispera / post)
  comercial         Buen Fin, aguinaldo, 10 de mayo, navidad, anio nuevo
  candidato         temporalidades en evaluacion (no en el modelo final hasta validar)
"""

from dataclasses import dataclass
from datetime import date, timedelta
from typing import Callable
import pandas as pd

ORIGIN = date(2025, 1, 1)   # t = dias desde esta fecha


@dataclass
class Factor:
    name: str
    layer: str
    desc: str
    fn: Callable  # (df, cal) -> pd.Series

FACTORS: dict[str, Factor] = {}


def factor(name, layer, desc):
    def deco(fn):
        FACTORS[name] = Factor(name, layer, desc, fn)
        return fn
    return deco


# ── columnas base ─────────────────────────────────────────────────────────────

def add_base_columns(df, origin=ORIGIN):
    df = df.copy()
    df["date"] = pd.to_datetime(df["date"])
    df["d"] = df["date"].dt.date
    df["dow"] = df["date"].dt.dayofweek      # Lun=0 ... Dom=6
    df["month"] = df["date"].dt.month
    df["dom"] = df["date"].dt.day
    df["t"] = df["d"].apply(lambda x: (x - origin).days)
    return df


# ── dia de semana (Lunes = base, sin dummy) ─────────────────────────────────────
for _i, _nm in enumerate(["tue", "wed", "thu", "fri", "sat", "sun"], start=1):
    def _mk(idx):
        return lambda df, cal: (df["dow"] == idx).astype(int)
    factor(f"dow_{_nm}", "dia-semana", f"Dia de la semana = {_nm} (vs Lunes base)")(_mk(_i))


# ── ciclo de pagos ──────────────────────────────────────────────────────────────
@factor("is_q15_exact", "ciclo-pagos", "Dia habil de deposito de la quincena 15")
def _q15(df, cal):
    return df["d"].apply(lambda x: int(x in cal.q15))

@factor("is_qlast_exact", "ciclo-pagos", "Ultimo dia habil del mes (quincena fin de mes)")
def _qfin(df, cal):
    return df["d"].apply(lambda x: int(x in cal.qfin))

@factor("is_q1st_exact", "ciclo-pagos", "Primer dia habil del mes (pagos acumulados de fin de semana)")
def _q1st(df, cal):
    return df["d"].apply(lambda x: int(x in cal.q1st))

@factor("is_d17_exact", "ciclo-pagos", "Dia habil del 17 (limite SAT/IMSS)")
def _d17(df, cal):
    return df["d"].apply(lambda x: int(x in cal.d17))

@factor("is_q_dm1", "ciclo-pagos", "Vispera de quincena (Q-1 calendario desde el deposito)")
def _qdm1(df, cal):
    return df["d"].apply(lambda x: int(x in cal.qm1 and x not in cal.anchors))

@factor("is_q_dp1", "ciclo-pagos", "Post-quincena (Q+1 calendario desde el deposito)")
def _qdp1(df, cal):
    return df["d"].apply(lambda x: int(x in cal.qp1 and x not in cal.anchors))

@factor("is_q_dp2", "ciclo-pagos", "Post-quincena (Q+2 calendario desde el deposito)")
def _qdp2(df, cal):
    return df["d"].apply(lambda x: int(x in cal.qp2 and x not in cal.anchors and x not in cal.qp1))


# ── calendario oficial ──────────────────────────────────────────────────────────
@factor("is_holiday", "calendario-of", "Festivo oficial (LFTSS + Banxico Santo)")
def _hol(df, cal):
    return df["d"].apply(lambda x: int(x in cal.holidays))

@factor("is_holiday_eve", "calendario-of", "Vispera de festivo (dia inmediatamente anterior)")
def _holeve(df, cal):
    return df["d"].apply(lambda x: int((x + timedelta(1)) in cal.holidays))

@factor("is_post_holiday", "calendario-of", "Primer dia habil tras un FESTIVO o puente (no lunes ordinario)")
def _posthol(df, cal):
    def f(d):
        if not cal.is_business_day(d):
            return 0
        prev_bd = cal.nearest_biz_on_or_before(d - timedelta(1))
        if (d - prev_bd).days <= 1:
            return 0                      # dia habil consecutivo
        # hubo un hueco de dias no habiles: solo cuenta si incluyo un festivo
        k = 1
        while (d - timedelta(k)) > prev_bd:
            if (d - timedelta(k)) in cal.holidays:
                return 1
            k += 1
        return 0                          # solo fin de semana -> lunes ordinario, no cuenta
    return df["d"].apply(f)

@factor("is_semana_santa", "calendario-of", "Semana Santa (Domingo de Ramos a Sabado de Gloria)")
def _ss(df, cal):
    return df["d"].apply(lambda x: int(x in cal.semana_santa))

@factor("is_pascua_finde", "calendario-of",
        "Nucleo de Pascua: Sabado de Gloria + Domingo de Pascua (colapso de SPEI)")
def _pascua(df, cal):
    from .calendar_mx import easter_sunday
    s = set()
    for yr in cal.years:
        e = easter_sunday(yr)
        s.add(e - timedelta(1))  # Sabado de Gloria
        s.add(e)                 # Domingo de Pascua
    return df["d"].apply(lambda x: int(x in s))


# ── comercial / cultural ────────────────────────────────────────────────────────
@factor("is_buen_fin", "comercial", "Buen Fin (3er viernes a lunes de noviembre)")
def _bf(df, cal):
    return df["d"].apply(lambda x: int(x in cal.buen_fin))

@factor("is_aguinaldo", "comercial", "Zona de aguinaldo (15-23 dic)")
def _agui(df, cal):
    return ((df["month"] == 12) & df["dom"].between(15, 23)).astype(int)

@factor("is_10_mayo", "comercial", "10 de Mayo +/-1 (Dia de las Madres)")
def _mayo(df, cal):
    return ((df["month"] == 5) & df["dom"].between(9, 11)).astype(int)

@factor("is_navidad", "comercial", "Navidad (24-26 dic)")
def _nav(df, cal):
    return ((df["month"] == 12) & df["dom"].between(24, 26)).astype(int)

@factor("is_ano_nuevo", "comercial", "Anio Nuevo / 31 Dic")
def _anonuevo(df, cal):
    return (((df["month"] == 12) & (df["dom"] == 31)) |
            ((df["month"] == 1) & (df["dom"] == 1))).astype(int)

@factor("is_temporada_dic", "comercial",
        "Primera quincena decembrina (1-14 dic): aguinaldo escalonado + gasto navideno")
def _tempdic(df, cal):
    # El aguinaldo debe pagarse antes del 20-dic (LFT art. 87); muchas empresas lo
    # escalonan desde inicio de mes. Complementa is_aguinaldo (15-23) y is_navidad (24-26).
    return ((df["month"] == 12) & df["dom"].between(1, 14)).astype(int)

@factor("is_cuesta_enero", "comercial",
        "Cuesta de enero (dias 2-28): consumo/liquidez deprimidos post-fiestas")
def _cuesta(df, cal):
    # Fenomeno economico documentado en MX (menor liquidez y consumo en enero).
    # Ventana 2-28: el analisis de dias atipicos mostro deficit hasta fin de enero.
    return ((df["month"] == 1) & df["dom"].between(2, 28)).astype(int)


# ── interacciones (usadas por E-Global) ──────────────────────────────────────────
@factor("is_q15_fri", "ciclo-pagos", "Quincena-15 en Viernes [interaccion]")
def _q15fri(df, cal):
    return ((df["d"].apply(lambda x: x in cal.q15)) & (df["dow"] == 4)).astype(int)

@factor("is_qlast_fri", "ciclo-pagos", "Quincena-fin en Viernes [interaccion]")
def _qfinfri(df, cal):
    return ((df["d"].apply(lambda x: x in cal.qfin)) & (df["dow"] == 4)).astype(int)


# ── candidatos (en evaluacion — ver analisis de dias atipicos) ───────────────────
@factor("is_sabado_gloria", "candidato", "Sabado de Gloria (sabado anterior a Pascua)")
def _sabgloria(df, cal):
    sg = set()
    for yr in cal.years:
        from .calendar_mx import easter_sunday
        sg.add(easter_sunday(yr) - timedelta(1))
    return df["d"].apply(lambda x: int(x in sg))

@factor("is_arranque_anio", "candidato", "Primeros 5 dias habiles del anio (resaca de inicio)")
def _arranque(df, cal):
    dates = set()
    for yr in cal.years:
        d = date(yr, 1, 1)
        count = 0
        while count < 5:
            if cal.is_business_day(d):
                dates.add(d)
                count += 1
            d += timedelta(1)
    return df["d"].apply(lambda x: int(x in dates))

@factor("is_precierre_mes", "ciclo-pagos", "Penultimo dia habil del mes (liquidaciones de cierre)")
def _precierre(df, cal):
    return df["d"].apply(lambda x: int(x in cal.precierre))

@factor("is_lunes_post_qfinde", "ciclo-pagos",
        "Rebote de quincena: 1er dia habil cuando el 15 o fin de mes cayo en fin de semana")
def _lunespost(df, cal):
    return df["d"].apply(lambda x: int(x in cal.lunes_post_qfinde))

@factor("is_reyes", "candidato", "Dia de Reyes 5-6 ene (compras de reyes)")
def _reyes(df, cal):
    return ((df["month"] == 1) & df["dom"].between(5, 6)).astype(int)


# ── construccion de features ──────────────────────────────────────────────────────

def build_features(df, cal, origin=ORIGIN):
    """Agrega columnas base + TODOS los factores del registro."""
    df = add_base_columns(df, origin)
    for name, f in FACTORS.items():
        df[name] = f.fn(df, cal)
    return df


# ── conjuntos de features por canal ───────────────────────────────────────────────

FEATURE_SETS = {
    # SPEI v3.1: riel 24/7 (7 dias) + ventana de quincena asimetrica + temporalidades
    # descubiertas via analisis de dias atipicos (Pascua, cuesta de enero, temporada dic).
    "spei": [
        "t",
        "dow_tue", "dow_wed", "dow_thu", "dow_fri", "dow_sat", "dow_sun",
        "is_q15_exact", "is_qlast_exact",
        "is_q_dm1", "is_q_dp1", "is_q_dp2",
        "is_qlast_fri",                              # sub-aditividad: quincena-fin en viernes
        "is_precierre_mes", "is_lunes_post_qfinde",  # pre-cierre + rebote de quincena en finde
        "is_q1st_exact",
        "is_aguinaldo", "is_temporada_dic", "is_navidad",  # temporada decembrina completa
        "is_cuesta_enero",                           # cuesta de enero
        "is_pascua_finde",                           # colapso Sabado Gloria + Domingo Pascua
        "is_10_mayo", "is_ano_nuevo", "is_buen_fin",
        "is_holiday_eve", "is_post_holiday",
    ],
    # E-Global: dias habiles L-V (sin cambios respecto a v2)
    "eglobal": [
        "t",
        "dow_tue", "dow_wed", "dow_thu", "dow_fri",
        "is_semana_santa", "is_buen_fin", "is_aguinaldo",
        "is_10_mayo", "is_navidad", "is_ano_nuevo",
        "is_q15_exact", "is_qlast_exact", "is_q1st_exact", "is_d17_exact",
        "is_holiday_eve", "is_post_holiday",
        "is_q15_fri", "is_qlast_fri",
    ],
}

CHANNELS = {
    "spei":    {"include_weekends": True,  "min_vol": 500_000, "label": "SPEI Entradas (7 dias)"},
    "eglobal": {"include_weekends": False, "min_vol": 500_000, "label": "E-Global / Autorizador"},
}

FACTOR_LABELS = {
    "dow_tue": "Martes", "dow_wed": "Miercoles", "dow_thu": "Jueves",
    "dow_fri": "Viernes", "dow_sat": "Sabado", "dow_sun": "Domingo",
    "is_q15_exact": "Quincena 15 (dia deposito)",
    "is_qlast_exact": "Quincena fin de mes (dia deposito)",
    "is_q_dm1": "Vispera de quincena (Q-1)",
    "is_q_dp1": "Post-quincena (Q+1)",
    "is_q_dp2": "Post-quincena (Q+2)",
    "is_q1st_exact": "Primer dia habil del mes",
    "is_precierre_mes": "Pre-cierre de mes (penultimo habil)",
    "is_lunes_post_qfinde": "Rebote de quincena en finde",
    "is_d17_exact": "Dia 17 SAT/IMSS (dia habil exacto)",
    "is_semana_santa": "Semana Santa",
    "is_pascua_finde": "Pascua (Sab Gloria + Dom)",
    "is_aguinaldo": "Aguinaldo (15-23 dic)",
    "is_temporada_dic": "Temporada dic (1-14)",
    "is_cuesta_enero": "Cuesta de enero (2-28)",
    "is_10_mayo": "10 de Mayo +/-1",
    "is_navidad": "Navidad (24-26 dic)",
    "is_ano_nuevo": "Anio Nuevo / 31 Dic",
    "is_buen_fin": "Buen Fin",
    "is_holiday_eve": "Vispera de festivo",
    "is_post_holiday": "Primer dia post-festivo",
    "is_q15_fri": "Quincena-15 x Viernes [interaccion]",
    "is_qlast_fri": "Quincena-fin x Viernes [interaccion]",
    "is_sabado_gloria": "Sabado de Gloria",
    "is_arranque_anio": "Arranque de anio (5 dias habiles)",
    "is_reyes": "Dia de Reyes (5-6 ene)",
}
