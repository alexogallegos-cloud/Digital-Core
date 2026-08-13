"""
forecast — Pipeline de proyeccion de volumen organico Informix (SPE-AM-001).

Paquete versionado que reemplaza los scripts de scratchpad (growth_forecast_v*.py).
Disenado para re-ejecutarse cada vez que llegan datos reales nuevos.

Modulos:
  calendar_mx   Calendario mexicano (LFTSS fijo/movil, Banxico, Semana Santa) + dias habiles.
  atypical_days Dias atipicos a excluir del ajuste (incidentes, colapsos operativos).
  data_sources  Loaders extensibles de las fuentes Excel + merge con dedup.
  factors       REGISTRO de generadores de factores estacionales (uno por factor).
  model         Ajuste OLS log-lineal con remocion iterativa de outliers + interpretacion.
  render        Salida a HTML (D3) y Markdown en knowledge-base/cross-reference/.

Punto de entrada: generators/build-forecast-spei.py (ejecutar desde Informix/).
"""

__version__ = "3.1.0"
