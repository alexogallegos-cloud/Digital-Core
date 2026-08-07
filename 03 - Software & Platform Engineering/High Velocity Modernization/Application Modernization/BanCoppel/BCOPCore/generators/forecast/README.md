# forecast — Pipeline de proyección de volumen orgánico

Pipeline versionado que estima el **crecimiento orgánico** de SPEI Entradas y E-Global /
Autorizador de BanCoppel, controlando estacionalidad multicapa. Reemplaza los scripts de
scratchpad `growth_forecast_v*.py`. Diseñado para **re-ejecutarse cada vez que llegan datos
reales nuevos** y recalcular todos los factores.

## Cómo re-ejecutar

Desde `BCOPCore/`:

```
python generators/build-forecast-spei.py
```

Genera, en `knowledge-base/cross-reference/`:
- `growth-forecast-autorizador-spei.html` — dashboard D3 (series, tendencia, proyección, factores)
- `growth-forecast-autorizador-spei.md` — resultados y tabla de factores
- `growth-forecast-outliers.json` — días atípicos removidos + mayores residuos (insumo del RCA)

## Cómo alimentar datos nuevos

1. **Nueva fuente de datos** → agregar una entrada a `SOURCES` en `data_sources.py`
   (archivo, loader, prioridad). El loader devuelve `[{date, eglobal, spei}]`. Fechas
   solapadas: gana la fuente de mayor prioridad.
2. **Nuevo día atípico / incidente** → registrarlo en `atypical_days.py` con su motivo
   (cross-referencia con `knowledge-base/D{NN}/21-observability-runbook.md`).
3. **Nueva temporalidad** → agregar un generador con `@factor(nombre, capa, desc)` en
   `factors.py` e incluir su nombre en el `FEATURE_SET` del canal correspondiente.
4. Re-ejecutar. El calendario mexicano se recalcula solo para el rango de años configurado
   en el runner (`MxCalendar(range(2023, 2031))`).

## Modelo

OLS log-lineal: `log V(t) = β₀ + β₁·t + Σ βₖ·factorₖ(t) + ε`
- `β₁` (coef. de `t`) = crecimiento orgánico diario; mensual = `exp(β₁·30) − 1`.
- Cada `βₖ` en log ⇒ efecto **multiplicativo**: `exp(βₖ) − 1` es el % del factor. El "factor
  compuesto" del negocio (p.ej. viernes + post-quincena) emerge como producto de capas.
- Remoción iterativa de outliers por residuo estudentizado externo `|t*| > 2.5` (2 iteraciones).
- **SPEI se modela sobre los 7 días** (riel 24/7: Sáb ≈ 112%, Dom ≈ 79% del volumen hábil).
  **E-Global sobre días hábiles L-V.**

## Estructura

| Módulo | Rol |
|--------|-----|
| `calendar_mx.py` | Calendario MX (LFTSS fijo/móvil, Banxico, Semana Santa) + día hábil + anclajes de quincena resueltos a día hábil exacto |
| `atypical_days.py` | Días atípicos excluidos del ajuste (incidentes, colapsos) |
| `data_sources.py` | Loaders extensibles de las fuentes Excel + merge con dedup por prioridad |
| `factors.py` | **Registro de generadores de factores** (uno por `@factor`) + `FEATURE_SETS` por canal + etiquetas |
| `model.py` | Ajuste OLS + remoción de outliers + interpretación + proyección |
| `render.py` | Salida a HTML (D3) y Markdown |

## Registro de factores

`factors.FACTORS` es el catálogo vivo. Cada factor declara su **capa** de estacionalidad:

- `tendencia` — crecimiento orgánico (`t`)
- `dia-semana` — efecto del día (lunes base)
- `ciclo-pagos` — quincena 15 / fin de mes (día hábil exacto), ventana asimétrica Q-1..Q+2,
  primer día del mes, día 17 SAT/IMSS, interacciones quincena×viernes
- `calendario-of` — festivos y vecindad (víspera / post), Semana Santa, núcleo de Pascua
- `comercial` — Buen Fin, aguinaldo (15-23), temporada decembrina (1-14), cuesta de enero,
  10 de mayo, Navidad, Año Nuevo
- `gobierno` — temporada fiscal SAT (reembolsos abr-may), programas Bienestar (bimestral;
  **nulo en BanCoppel** — se dispersa vía Banco del Bienestar; registrado, no activado)
- `estacional-anual` — patrón anual repetible del Autorizador (`annual_doy` + `annual_h*`,
  piecewise sobre día-del-año, reset en enero)
- `candidato` — temporalidades en evaluación (no en el modelo final hasta validarse)

**Todas las reglas exploradas quedan registradas** aunque no estén activas; el `FEATURE_SET`
de cada canal selecciona las activas y son las que se aplican al proyectar.

Temporadas de consumo del segmento BanCoppel (Coppel core) evaluadas para el Autorizador:
- **Activas**: `is_pre_dia_nino` (compras previas al Día del Niño, +4.2%, p=0.001, sólida);
  `is_pre_semana_santa` (móvil, sigue la Pascua, +2%, p~0.10) e `is_post_fiesta` (resaca
  post-fiesta grande 17-sep/26-dic/2-ene, −4%, p~0.06) — activas por rational fuerte, re-validar.
- **Registradas pero inactivas (nulas/marginales en tarjeta con los datos actuales)**:
  `is_sat_reembolso` (redundante con pre-Día del Niño en fin de abril), `is_regreso_clases`
  (¿va por crédito Coppel, no débito?), `is_pre_dia_madres` (ídem), `is_fiestas_patrias`,
  `is_dia_padre`, `is_vispera_puente`, `is_bienestar` (Banco del Bienestar, no BanCoppel),
  `is_mes_corto` (la longitud del mes ya se maneja al proyectar día a día).

El pico anómalo de abril-2025 restante apunta a una **campaña interna Coppel** (p.ej. Hot
Fashion); falta ese calendario para modelarlo.

El análisis que fundamenta los factores descubiertos vía días atípicos vive en
`knowledge-base/cross-reference/growth-forecast-dias-atipicos.md`.

## Dependencias

`pandas`, `numpy`, `statsmodels`, `openpyxl`.
