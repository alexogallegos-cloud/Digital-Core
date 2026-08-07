"""
calendar_mx — Calendario mexicano y utilidades de dia habil.

Precomputa, para un rango de anios, todos los conjuntos de fechas que alimentan a los
generadores de factores: festivos oficiales (LFTSS fijo + movil), Banxico (Jueves/Viernes
Santo), Semana Santa, Buen Fin, y los anclajes de ciclo de pago (quincena 15, ultimo dia
habil del mes, primer dia habil del mes, dia 17 SAT/IMSS) resueltos al dia HABIL exacto.

El resto del pipeline nunca calcula fechas a mano: pide los conjuntos a un MxCalendar.
"""

from datetime import date, timedelta
from calendar import monthrange


def nth_weekday(year, month, weekday, n):
    """n-esimo <weekday> del mes (weekday: Lun=0 ... Dom=6)."""
    d = date(year, month, 1)
    d += timedelta((weekday - d.weekday()) % 7)
    return d + timedelta(weeks=n - 1)


def easter_sunday(year):
    """Domingo de Pascua (algoritmo de Gauss/Anonymous Gregorian)."""
    a = year % 19
    b, c = divmod(year, 100)
    d, e = divmod(b, 4)
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i, k = divmod(c, 4)
    ll = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * ll) // 451
    month = (h + ll - 7 * m + 114) // 31
    day = (h + ll - 7 * m + 114) % 31 + 1
    return date(year, month, day)


class MxCalendar:
    """Calendario mexicano precomputado sobre un rango de anios."""

    def __init__(self, years):
        self.years = list(years)
        self.holidays = self._holidays()
        self.semana_santa = self._semana_santa()
        self.buen_fin = self._buen_fin()
        self.q15 = self._quincena_15()
        self.qfin = self._last_biz_day()
        self.q1st = self._first_biz_day()
        self.d17 = self._day17()
        # Anclajes de deposito y ventana asimetrica alrededor de ellos
        self.anchors = self.q15 | self.qfin
        self.qm1 = {a - timedelta(1) for a in self.anchors}
        self.qp1 = {a + timedelta(1) for a in self.anchors}
        self.qp2 = {a + timedelta(2) for a in self.anchors}
        # Penultimo dia habil de cada mes (pre-cierre) y lunes de rebote cuando la
        # quincena calendario (15 o fin de mes) cayo en fin de semana.
        self.precierre = self._precierre()
        self.lunes_post_qfinde = self._lunes_post_qfinde()

    # ── festivos ────────────────────────────────────────────────────────────
    def _holidays(self):
        h = set()
        for yr in self.years:
            # LFTSS fijos
            h.add(date(yr, 1, 1))    # Anio Nuevo
            h.add(date(yr, 5, 1))    # Dia del Trabajo
            h.add(date(yr, 9, 16))   # Independencia
            h.add(date(yr, 12, 25))  # Navidad
            # LFTSS moviles
            h.add(nth_weekday(yr, 2, 0, 1))   # 1er lunes de febrero (Constitucion)
            h.add(nth_weekday(yr, 3, 0, 3))   # 3er lunes de marzo (Benito Juarez)
            h.add(nth_weekday(yr, 11, 0, 3))  # 3er lunes de noviembre (Revolucion)
            # Banxico: Jueves y Viernes Santo
            e = easter_sunday(yr)
            h.add(e - timedelta(3))
            h.add(e - timedelta(2))
        return h

    def _semana_santa(self):
        s = set()
        for yr in self.years:
            e = easter_sunday(yr)
            for delta in range(-6, 1):  # Domingo de Ramos -> Sabado de Gloria
                s.add(e + timedelta(delta))
        return s

    def _buen_fin(self):
        s = set()
        for yr in self.years:
            start = nth_weekday(yr, 11, 4, 3)  # 3er viernes de noviembre
            for delta in range(4):             # Vie -> Lun
                s.add(start + timedelta(delta))
        return s

    # ── dias habiles ──────────────────────────────────────────────────────────
    def is_business_day(self, d):
        return d.weekday() < 5 and d not in self.holidays

    def nearest_biz_on_or_before(self, d):
        while not self.is_business_day(d):
            d -= timedelta(1)
        return d

    def nearest_biz_on_or_after(self, d):
        while not self.is_business_day(d):
            d += timedelta(1)
        return d

    # ── anclajes de ciclo de pago (resueltos a dia habil exacto) ───────────────
    def _quincena_15(self):
        s = set()
        for yr in self.years:
            for mo in range(1, 13):
                s.add(self.nearest_biz_on_or_before(date(yr, mo, 15)))
        return s

    def _last_biz_day(self):
        s = set()
        for yr in self.years:
            for mo in range(1, 13):
                last = date(yr, mo, monthrange(yr, mo)[1])
                s.add(self.nearest_biz_on_or_before(last))
        return s

    def _first_biz_day(self):
        s = set()
        for yr in self.years:
            for mo in range(1, 13):
                s.add(self.nearest_biz_on_or_after(date(yr, mo, 1)))
        return s

    def _day17(self):
        s = set()
        for yr in self.years:
            for mo in range(1, 13):
                s.add(self.nearest_biz_on_or_before(date(yr, mo, 17)))
        return s

    def _precierre(self):
        """Penultimo dia habil de cada mes."""
        s = set()
        for yr in self.years:
            for mo in range(1, 13):
                last = self.nearest_biz_on_or_before(date(yr, mo, monthrange(yr, mo)[1]))
                s.add(self.nearest_biz_on_or_before(last - timedelta(1)))
        return s

    def _lunes_post_qfinde(self):
        """Primer dia habil de rebote cuando el 15 o el ultimo dia del mes cayeron en
        fin de semana (deposito adelantado al viernes; rebote el lunes siguiente)."""
        s = set()
        for yr in self.years:
            for mo in range(1, 13):
                d15 = date(yr, mo, 15)
                if d15.weekday() >= 5:
                    s.add(self.nearest_biz_on_or_after(d15))
                dlast = date(yr, mo, monthrange(yr, mo)[1])
                if dlast.weekday() >= 5:
                    s.add(self.nearest_biz_on_or_after(dlast))
        return s
