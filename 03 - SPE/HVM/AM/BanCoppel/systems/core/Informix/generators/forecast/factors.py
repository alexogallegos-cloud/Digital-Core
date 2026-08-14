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
    df["doy"] = df["date"].dt.dayofyear          # dia del anio (para patrones anuales repetibles)
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

@factor("is_q_dp3", "ciclo-pagos", "Post-quincena (Q+3): cola de gasto con tarjeta (tras cobrar)")
def _qdp3(df, cal):
    return df["d"].apply(lambda x: int(
        x in cal.qp3 and x not in cal.anchors and x not in cal.qp1 and x not in cal.qp2))


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


# ── temporada fiscal / gubernamental (recurrentes; validar con mas datos) ────────
@factor("is_pre_semana_santa", "calendario-of",
        "Compras previas a Semana Santa (MOVIL: ~11-4 dias antes del Domingo de Pascua)")
def _pre_ss(df, cal):
    from .calendar_mx import easter_sunday
    s = set()
    for yr in cal.years:
        e = easter_sunday(yr)
        for k in range(4, 12):
            s.add(e - timedelta(k))
    return df["d"].apply(lambda x: int(x in s))

@factor("is_sat_reembolso", "gobierno",
        "Temporada de declaracion/reembolso SAT PF (~15-abr a 20-may; vence 30-abr)")
def _sat(df, cal):
    return ((df["doy"] >= 105) & (df["doy"] <= 140)).astype(int)

@factor("is_bienestar", "gobierno",
        "Dispersion bimestral programas Bienestar (meses impares, dias 1-25). NULO en BanCoppel "
        "(se dispersa via Banco del Bienestar, no BanCoppel); registrado pero no activado.")
def _bienestar(df, cal):
    return (df["month"].isin([1, 3, 5, 7, 9, 11]) & (df["dom"] <= 25)).astype(int)


# ── temporadas de consumo del segmento BanCoppel (Coppel core) ───────────────────
# Todas registradas; el FEATURE_SET activa solo las que tienen soporte. Activas:
# is_pre_dia_nino (p=0.002) e is_post_fiesta (rational fuerte, -4%). Las demas quedan como
# candidatas (nulas/marginales en tarjeta con los datos actuales).
@factor("is_pre_dia_nino", "comercial",
        "Compras previas al Dia del Nino (25-30 abr): juguetes (Coppel core)")
def _pre_nino(df, cal):
    return ((df["month"] == 4) & df["dom"].between(25, 30)).astype(int)

@factor("is_post_fiesta", "calendario-of",
        "Resaca post-fiesta grande: dia siguiente no festivo (17-sep, 26-dic, 2-ene) -> consumo bajo")
def _post_fiesta(df, cal):
    pf = {(9, 17), (12, 26), (1, 2)}
    return df.apply(lambda r: int((int(r["month"]), int(r["dom"])) in pf), axis=1)

@factor("is_regreso_clases", "comercial",
        "Regreso a clases (15-jul a 25-ago): utiles/uniformes. Candidato (p=0.16 en tarjeta)")
def _regreso(df, cal):
    return df["doy"].between(196, 237).astype(int)

@factor("is_fiestas_patrias", "comercial",
        "Fiestas patrias (10-15 sep). Candidato (nulo en tarjeta)")
def _patrias(df, cal):
    return ((df["month"] == 9) & df["dom"].between(10, 15)).astype(int)

@factor("is_pre_dia_madres", "comercial",
        "Compras previas al 10-may (3-9 may). Candidato (nulo en tarjeta: el segmento compra a "
        "credito Coppel, no debito/e-global)")
def _pre_madres(df, cal):
    return ((df["month"] == 5) & df["dom"].between(3, 9)).astype(int)

@factor("is_dia_padre", "comercial",
        "Dia del Padre (3er domingo de junio +/-2). Candidato (p~0.08 marginal)")
def _padre(df, cal):
    from .calendar_mx import nth_weekday
    s = set()
    for yr in cal.years:
        p = nth_weekday(yr, 6, 6, 3)
        for k in range(-2, 1):
            s.add(p + timedelta(k))
    return df["d"].apply(lambda x: int(x in s))

@factor("is_vispera_puente", "calendario-of",
        "Ultimo dia habil antes de un puente (>=3 dias no habiles con festivo). Candidato (nulo)")
def _vispera_puente(df, cal):
    def f(d):
        if not cal.is_business_day(d):
            return 0
        run = 0; k = 1; festivo = False
        while not cal.is_business_day(d + timedelta(k)):
            if (d + timedelta(k)) in cal.holidays:
                festivo = True
            run += 1; k += 1
            if run > 6:
                break
        return int(run >= 3 and festivo)
    return df["d"].apply(f)

@factor("is_mes_corto", "candidato", "Febrero (mes corto). Nulo: la longitud del mes se maneja al agregar dia a dia")
def _mes_corto(df, cal):
    return (df["month"] == 2).astype(int)


# ── patron ANUAL REPETIBLE del Autorizador (piecewise sobre dia-del-anio) ─────────
# El Autorizador NO es log-lineal: su forma intra-anual sube y baja a lo largo del anio y
# se REPITE cada anio. Se modela como piecewise-linear sobre el DIA-DEL-ANIO (doy), continuo
# dentro del anio pero con RESET en el cambio de anio (doy salta 365->1 => "arranque de cero"
# cultural, sin wraparound). Esto se repite igual en 2025, 2026, 2027... y por eso SI proyecta
# (a diferencia de breakpoints en tiempo absoluto). La tendencia de crecimiento anio-a-anio se
# estima aparte con 't'. Knots optimos (maximizar adjR2, sin infra):
#   1-ene->10-abr +5.0%/mes · 10-abr->19-jul -2.0%/mes · 19-jul->31-dic +0.4%/mes.
# Recalcular con datos nuevos: generators/build-autorizador-knots.py.
ANNUAL_KNOTS_DOY = [100, 200]   # ~10-abr, ~19-jul

@factor("annual_doy", "estacional-anual", "Pendiente intra-anual base (dia-del-anio, reset en ene)")
def _annual_doy(df, cal):
    return df["doy"].astype(float)

for _i, _kd in enumerate(ANNUAL_KNOTS_DOY, start=1):
    def _mk_adoy(kd):
        return lambda df, cal: (df["doy"] - kd).clip(lower=0).astype(float)
    factor(f"annual_h{_i}", "estacional-anual",
           f"Cambio de pendiente intra-anual en doy={_kd}")(_mk_adoy(_kd))


# ── CATALOGO EXTENDIDO (marco de factores del usuario; registrados, se activan por FEATURE_SET) ──

# Ventana de quincena ampliada a +/-4 dias (offsets calendario desde el ancla de deposito)
def _q_off(cal, k):
    from datetime import timedelta as _td
    return {a + _td(k) for a in cal.anchors}
for _k in (2, 3, 4):
    def _mk_dm(k):
        return lambda df, cal: df["d"].apply(lambda x: int(x in _q_off(cal, -k) and x not in cal.anchors))
    factor(f"is_q_dm{_k}", "ciclo-pagos", f"Quincena Q-{_k} (dias antes del deposito)")(_mk_dm(_k))
def _q_dp4(df, cal):
    return df["d"].apply(lambda x: int(x in _q_off(cal, 4) and x not in cal.anchors))
factor("is_q_dp4", "ciclo-pagos", "Quincena Q+4")(_q_dp4)

# Semana Santa dia por dia + semana de Pascua + PTU
def _ss_day(offset):
    def f(df, cal):
        from .calendar_mx import easter_sunday
        s = {easter_sunday(yr) + timedelta(offset) for yr in cal.years}
        return df["d"].apply(lambda x: int(x in s))
    return f
factor("is_lunes_santo", "calendario-of", "Lunes Santo (Pascua-6)")(_ss_day(-6))
factor("is_martes_santo", "calendario-of", "Martes Santo (Pascua-5)")(_ss_day(-5))
factor("is_miercoles_santo", "calendario-of", "Miercoles Santo (Pascua-4)")(_ss_day(-4))

@factor("is_semana_pascua", "calendario-of", "Semana de Pascua (6 dias despues del Domingo de Pascua)")
def _sem_pascua(df, cal):
    from .calendar_mx import easter_sunday
    s = set()
    for yr in cal.years:
        e = easter_sunday(yr)
        for k in range(1, 7):
            s.add(e + timedelta(k))
    return df["d"].apply(lambda x: int(x in s))

@factor("is_ptu", "gobierno", "Reparto de utilidades PTU (15-may a 15-jun): ingreso extra al trabajador")
def _ptu(df, cal):
    return (((df["month"] == 5) & (df["dom"] >= 15)) | ((df["month"] == 6) & (df["dom"] <= 15))).astype(int)

# Fechas fijas
@factor("is_san_valentin", "comercial", "San Valentin (13-14 feb)")
def _sanval(df, cal):
    return ((df["month"] == 2) & df["dom"].between(13, 14)).astype(int)

@factor("is_vispera_dia_madre", "comercial", "Vispera del Dia de la Madre (8-9 may)")
def _visp_madre(df, cal):
    return ((df["month"] == 5) & df["dom"].between(8, 9)).astype(int)

@factor("is_dia_maestro", "comercial", "Dia del Maestro (15 may)")
def _maestro(df, cal):
    return ((df["month"] == 5) & (df["dom"] == 15)).astype(int)

@factor("is_dia_muertos", "comercial", "Dia de Muertos (1-2 nov)")
def _muertos(df, cal):
    return ((df["month"] == 11) & df["dom"].between(1, 2)).astype(int)

@factor("is_vispera_guadalupe", "comercial", "Vispera Virgen de Guadalupe (11 dic)")
def _visp_guad(df, cal):
    return ((df["month"] == 12) & (df["dom"] == 11)).astype(int)

@factor("is_guadalupe", "comercial", "Virgen de Guadalupe (12 dic)")
def _guad(df, cal):
    return ((df["month"] == 12) & (df["dom"] == 12)).astype(int)

# Flotantes
@factor("is_black_cyber", "comercial", "Black Friday (4to vie nov) + Cyber Monday (lun siguiente)")
def _black_cyber(df, cal):
    from .calendar_mx import nth_weekday
    s = set()
    for yr in cal.years:
        bf = nth_weekday(yr, 11, 4, 4)   # 4to viernes de noviembre
        s.add(bf); s.add(bf + timedelta(3))  # Black Friday + Cyber Monday
    return df["d"].apply(lambda x: int(x in s))

@factor("is_inicio_vacacional", "candidato", "Inicio de periodo vacacional escolar (~15-jul, ~19-dic)")
def _inicio_vac(df, cal):
    return (((df["month"] == 7) & df["dom"].between(13, 18)) |
            ((df["month"] == 12) & df["dom"].between(18, 22))).astype(int)

# Efectos mensuales
@factor("is_domingo_quincena", "ciclo-pagos", "Domingo que cae en ventana de quincena (interaccion)")
def _dom_q(df, cal):
    en_q = df["d"].apply(lambda x: x in cal.q15 or x in cal.qfin or x in cal.qp1 or x in cal.qp2)
    return ((df["dow"] == 6) & en_q).astype(int)

@factor("is_mundial", "candidato", "Mundial de futbol 2026 (11-jun a 19-jul): efecto disperso, evento cada 4 anios")
def _mundial(df, cal):
    return df["d"].apply(lambda x: int(date(2026, 6, 11) <= x <= date(2026, 7, 19)))

# Navidad detallada
@factor("is_pre_navidad", "comercial", "Pre-Navidad (20-23 dic)")
def _prenav(df, cal):
    return ((df["month"] == 12) & df["dom"].between(20, 23)).astype(int)

@factor("is_post_navidad", "calendario-of", "Post-Navidad (26 dic)")
def _postnav(df, cal):
    return ((df["month"] == 12) & (df["dom"] == 26)).astype(int)

@factor("is_vispera_ano_nuevo", "comercial", "Vispera de Anio Nuevo (30-31 dic)")
def _visp_an(df, cal):
    return ((df["month"] == 12) & df["dom"].between(30, 31)).astype(int)

@factor("is_rezago_pre_quincena", "ciclo-pagos", "Rezago pre-quincena (7 a 4 dias antes del deposito)")
def _rezago(df, cal):
    s = set()
    for a in cal.anchors:
        for k in range(4, 8):
            s.add(a - timedelta(k))
    return df["d"].apply(lambda x: int(x in s and x not in cal.anchors))


# ── interaccion dia-de-semana x mes (SATURADA) — config de MAXIMO AJUSTE DIARIO ──────
# Cada combinacion (dia de semana, mes) tiene su propio nivel. Sube el R2 DIARIO (~0.84) pero
# es un modelo no-parametrico: sobreajusta las celdas de sep-dic (solo 1 anio de datos) y NO
# mejora la senial agregada (semanal/mensual). Reemplaza de facto a dow + patron anual. Se
# activa a peticion de negocio para el esquema diario; reversible quitandolo del FEATURE_SET.
_DOWMES_NAMES = {1: "tue", 2: "wed", 3: "thu", 4: "fri", 5: "sat", 6: "sun"}
for _mm in range(2, 13):
    for _dd, _dn in _DOWMES_NAMES.items():
        def _mk_dm(dd, mm):
            return lambda df, cal: ((df["dow"] == dd) & (df["month"] == mm)).astype(int)
        factor(f"dowmes_{_dn}_{_mm}", "dow-mes-saturado",
               f"{_dn} de mes {_mm} (interaccion dia x mes)")(_mk_dm(_dd, _mm))
DOWMES_FACTORS = [f"dowmes_{_dn}_{_mm}" for _mm in range(2, 13) for _dn in _DOWMES_NAMES.values()]


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
    # E-Global / Autorizador: 7 dias (el pico de tarjetas es en fin de semana) + tendencia
    # SEGMENTADA por escalones (no log-lineal). Factores propios de tarjetas.
    "eglobal": [
        "t",                                          # tendencia de crecimiento anio-a-anio
        "annual_doy", "annual_h1", "annual_h2",       # patron anual repetible (reset en ene)
        "dow_tue", "dow_wed", "dow_thu", "dow_fri", "dow_sat", "dow_sun",
        "is_q15_exact", "is_qlast_exact",             # anclas de quincena (dia de deposito)
        "is_q_dp1", "is_q_dp2", "is_q_dp3",            # ventana POST-pago (cola de gasto ~3 dias)
        "is_q_dm3",                                    # valle pre-cobro (Q-3, -1.5%, p=0.02): sin
        #   dinero antes de la quincena. Q-1/Q-2/Q-4/Q+4 no significativos en tarjeta.
        "is_q1st_exact",
        "is_precierre_mes", "is_lunes_post_qfinde",   # pre-cierre + rebote de quincena en finde
        "is_holiday_eve", "is_post_holiday",
        "is_semana_santa", "is_pascua_finde",         # moviles: siguen la Pascua
        "is_pre_semana_santa",                        # compras pre-Pascua (movil; rational fuerte,
        #   p~0.09 -> re-validar con mas datos)
        "is_pre_dia_nino",                            # compras previas al Dia del Nino (p=0.001)
        "is_post_fiesta",                             # resaca post-fiesta grande (-4%, p~0.06)
        # is_sat_reembolso NO se activa: quedo nulo (p=0.57) al competir con is_pre_dia_nino, que
        # captura mejor el pico de fin de abril. Registrado en el catalogo, inactivo.
        "is_aguinaldo",                               # aguinaldo (evento especifico)
        # NO se incluyen cuesta_enero / temporada_dic / navidad (el patron anual los absorbe);
        # podados por no-significancia: is_10_mayo, is_d17_exact, is_q15_fri, is_qlast_fri.
    ] + DOWMES_FACTORS,   # config MAXIMO AJUSTE DIARIO: dia x mes saturado (R2 diario ~0.84;
    #                       sobreajusta celdas sep-dic con 1 anio; la senial agregada no mejora).
}

CHANNELS = {
    "spei":    {"include_weekends": True, "min_vol": 500_000, "label": "SPEI Entradas (7 dias)"},
    "eglobal": {"include_weekends": True, "min_vol": 500_000, "label": "E-Global / Autorizador (7 dias)"},
}

FACTOR_LABELS = {
    "trend_eg_h1": "Cambio pendiente (17-abr-25)",
    "trend_eg_h2": "Cambio pendiente (1-jul-25)",
    "dow_tue": "Martes", "dow_wed": "Miercoles", "dow_thu": "Jueves",
    "dow_fri": "Viernes", "dow_sat": "Sabado", "dow_sun": "Domingo",
    "is_q15_exact": "Quincena 15 (dia deposito)",
    "is_qlast_exact": "Quincena fin de mes (dia deposito)",
    "is_q_dm1": "Vispera de quincena (Q-1)",
    "is_q_dp1": "Post-quincena (Q+1)",
    "is_q_dp2": "Post-quincena (Q+2)",
    "is_q_dp3": "Post-quincena (Q+3)",
    "is_q1st_exact": "Primer dia habil del mes",
    "is_precierre_mes": "Pre-cierre de mes (penultimo habil)",
    "is_lunes_post_qfinde": "Rebote de quincena en finde",
    "is_d17_exact": "Dia 17 SAT/IMSS (dia habil exacto)",
    "is_semana_santa": "Semana Santa",
    "is_pascua_finde": "Pascua (Sab Gloria + Dom)",
    "is_pre_semana_santa": "Pre-Semana Santa (compras, movil)",
    "is_sat_reembolso": "Temporada fiscal SAT (abr-may)",
    "is_bienestar": "Programas Bienestar (bimestral)",
    "is_pre_dia_nino": "Pre-Dia del Nino (compras)",
    "is_post_fiesta": "Resaca post-fiesta (17sep/26dic/2ene)",
    "is_regreso_clases": "Regreso a clases (jul-ago)",
    "is_fiestas_patrias": "Fiestas patrias (10-15 sep)",
    "is_pre_dia_madres": "Pre-Dia de las Madres",
    "is_dia_padre": "Dia del Padre",
    "is_vispera_puente": "Vispera de puente",
    "is_mes_corto": "Mes corto (feb)",
    "is_q_dm2": "Quincena Q-2", "is_q_dm3": "Quincena Q-3", "is_q_dm4": "Quincena Q-4",
    "is_q_dp4": "Post-quincena (Q+4)",
    "is_lunes_santo": "Lunes Santo", "is_martes_santo": "Martes Santo",
    "is_miercoles_santo": "Miercoles Santo", "is_semana_pascua": "Semana de Pascua",
    "is_ptu": "PTU (reparto utilidades may-jun)",
    "is_san_valentin": "San Valentin", "is_vispera_dia_madre": "Vispera Dia de la Madre",
    "is_dia_maestro": "Dia del Maestro", "is_dia_muertos": "Dia de Muertos",
    "is_vispera_guadalupe": "Vispera Virgen de Guadalupe", "is_guadalupe": "Virgen de Guadalupe",
    "is_black_cyber": "Black Friday + Cyber Monday", "is_inicio_vacacional": "Inicio periodo vacacional",
    "is_domingo_quincena": "Domingo en quincena", "is_mundial": "Mundial 2026",
    "is_pre_navidad": "Pre-Navidad (20-23 dic)", "is_post_navidad": "Post-Navidad (26 dic)",
    "is_vispera_ano_nuevo": "Vispera Anio Nuevo (30-31 dic)",
    "is_rezago_pre_quincena": "Rezago pre-quincena (Q-7 a Q-4)",
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
