"""
atypical_days — Dias atipicos excluidos del ajuste del modelo.

Estos NO son factores de regresion: son dias cuyo volumen esta distorsionado por causas
que no queremos que el modelo aprenda como estacionalidad (incidentes de sistema, colapsos
operativos, jornadas parciales). Se excluyen del fit.

PRINCIPIO DE REMOCION (importante): un dia atipico se descarta SOLO si su desviacion no
tiene un rational predecible — es decir, si es un incidente o algo no predecible. Si la
desviacion cae en una temporalidad conocida (aguinaldo, pre-cierre, rebote de quincena,
etc.), el dia NO se bota: se modela como factor o se mantiene en el ajuste. La remocion
estadistica de model.fit_channel implementa esto de forma condicional: solo remueve los
outliers |t*|>2.5 que NO tienen ninguna etiqueta de calendario que los explique. Ver
knowledge-base/cross-reference/growth-forecast-dias-atipicos.md.

COMO MANTENER: al llegar datos nuevos, agrega aqui cualquier dia con un incidente
documentado (cross-referencia con knowledge-base/D{NN}/21-observability-runbook.md y con
knowledge-base/incidents/). Si un dia atipico resulta tener una temporalidad recurrente, NO
lo agregues aqui: crea un @factor en factors.py.
"""

from datetime import date

# fecha -> motivo (para trazabilidad; el motivo no afecta el calculo)
ATYPICAL_DAYS = {
    date(2025, 11, 29): "Incidente operativo nov-2025",
    date(2025, 12, 15): "Incidente / degradacion dic-2025",
    date(2025, 12, 17): "Incidente / recuperacion dic-2025",
    date(2025, 12, 21): "Incidente dic-2025",
    date(2025, 12, 23): "Incidente dic-2025",
    date(2025, 12, 31): "Cierre de anio — jornada atipica",
    date(2026, 1, 12):  "INC-20260112 (D01-bdicnweb)",
}


def to_set():
    return set(ATYPICAL_DAYS.keys())
