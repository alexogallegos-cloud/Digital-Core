# Proyeccion de Crecimiento Organico — SPEI Entradas + E-Global
> **Fuente**: pipeline `generators/forecast/` (OLS log-lineal, SPEI 7 dias con ventana de quincena)
> **Version**: 3.1.0 · 2026-08-07 · regenerable con datos nuevos
> **Proyecto**: BanCoppel BCOPCore · SPE-AM-001

---

## Pipeline reproducible

Este documento y su HTML se regeneran ejecutando, desde `BCOPCore/`:

```
python generators/build-forecast-spei.py
```

Los generadores de factores viven en `generators/forecast/factors.py` (un generador por
factor, registrado con `@factor`). Al llegar datos reales nuevos: agregar la fuente en
`generators/forecast/data_sources.py`, registrar cualquier dia atipico en
`generators/forecast/atypical_days.py`, y re-ejecutar.

---

## Dos canales, dos estructuras

Ambos canales se modelan sobre los **7 dias** (SPEI y el Autorizador tienen su pico en fin de
semana), pero su TENDENCIA es distinta:

- **SPEI** es log-lineal: tras quitar estacionalidad, la tendencia es una recta ascendente
  (R2 de una recta sobre la tendencia des-estacionalizada = 0.92). Se proyecta con una sola
  pendiente + los factores en inversa.
- **El Autorizador NO es log-lineal**: tiene un **patron anual repetible** (misma forma cada
  anio, funcion del dia-del-anio) mas una tendencia de crecimiento anio-a-anio. El patron es
  piecewise-linear continuo DENTRO del anio y **se resetea el 1-ene** ("arranque de cero"): sube
  fuerte ene-abr, baja abr-jul, mesetea jul-dic. Comparte temporalidades con SPEI pero con
  **factores propios**: la quincena mueve a SPEI +39/+47% y al Autorizador +7/+10%, y en tarjetas
  el efecto quincena es POST-pago (Q+1/Q+2 significativos, Q-1 no) porque se gasta despues de
  cobrar. El ajuste a nivel diario (~0.81) carga el ruido irregular de tarjetas (~3.6%); sobre la
  senial agregada el ajuste es 0.97 semanal / 0.99 mensual.

---

## Resultados

| Metrica | E-Global / Autorizador | SPEI Entradas |
|---------|------------------------|---------------|
| **Tendencia** | pendiente base + escalones (segmentada) | log-lineal |
| **Crecimiento mensual (pendiente base)** | **+0.73%** | **+1.55%** |
| IC 95% mensual | [+0.68%, +0.78%] | [+1.47%, +1.64%] |
| **Crecimiento anual (pendiente base)** | **+9.2%** | **+20.6%** |
| R² | 0.8379 | 0.9353 |
| R² ajustado | 0.8312 | 0.9323 |
| Observaciones | 553 dias (7-dia) | 557 dias (7-dia) |

> El "crecimiento mensual" del Autorizador es la **tendencia anio-a-anio** (continua); sobre
> ella se monta el patron anual repetible (sube ene-abr, baja abr-jul, resetea en enero). Para
> proyectar se combina la tendencia con el patron del dia-del-anio correspondiente. Ademas hay
> evidencia de censura por saturacion (techo de throughput ~4,300 txn/min) — ver el analisis de
> capacidad.

---

## Factores Estacionales: E-Global / Autorizador (7 dias, patron anual repetible)

| Factor | Efecto vs lunes base | p-valor |
|--------|----------------------|---------|
| Martes | -4.9% | 0.0000 *** |
| Miercoles | -2.6% | 0.0000 *** |
| Jueves | -4.0% | 0.0000 *** |
| Viernes | +4.1% | 0.0000 *** |
| Sabado | +1.3% | 0.0301 * |
| Domingo | -6.4% | 0.0000 *** |
| Quincena 15 (dia deposito) | +7.0% | 0.0000 *** |
| Quincena fin de mes (dia deposito) | +8.4% | 0.0000 *** |
| Post-quincena (Q+1) | +5.0% | 0.0000 *** |
| Post-quincena (Q+2) | +2.8% | 0.0000 *** |
| Primer dia habil del mes | +3.0% | 0.0009 *** |
| Pre-cierre de mes (penultimo habil) | +4.1% | 0.0000 *** |
| Rebote de quincena en finde | +2.8% | 0.0135 * |
| Semana Santa | -2.1% | 0.1476  |
| Pascua (Sab Gloria + Dom) | -5.0% | 0.0224 * |
| Aguinaldo (15-23 dic) | +2.8% | 0.0799  |
| Vispera de festivo | +2.7% | 0.0184 * |
| Primer dia post-festivo | -1.5% | 0.1474  |

---

## Factores Estacionales: SPEI Entradas (7 dias)

| Factor | Efecto vs lunes base | p-valor |
|--------|----------------------|---------|
| Martes | -9.2% | 0.0000 *** |
| Miercoles | -9.9% | 0.0000 *** |
| Jueves | -4.0% | 0.0000 *** |
| Viernes | +18.4% | 0.0000 *** |
| Sabado | +8.6% | 0.0000 *** |
| Domingo | -21.0% | 0.0000 *** |
| Quincena 15 (dia deposito) | +39.3% | 0.0000 *** |
| Quincena fin de mes (dia deposito) | +47.6% | 0.0000 *** |
| Vispera de quincena (Q-1) | +10.8% | 0.0000 *** |
| Post-quincena (Q+1) | +22.6% | 0.0000 *** |
| Post-quincena (Q+2) | +13.7% | 0.0000 *** |
| Primer dia habil del mes | +8.5% | 0.0000 *** |
| Pre-cierre de mes (penultimo habil) | +5.6% | 0.0006 *** |
| Rebote de quincena en finde | +8.4% | 0.0000 *** |
| Pascua (Sab Gloria + Dom) | -19.1% | 0.0000 *** |
| Aguinaldo (15-23 dic) | +20.3% | 0.0000 *** |
| Temporada dic (1-14) | +13.1% | 0.0000 *** |
| Cuesta de enero (2-28) | -6.6% | 0.0000 *** |
| 10 de Mayo +/-1 | +7.0% | 0.0021 ** |
| Navidad (24-26 dic) | +12.1% | 0.0043 ** |
| Anio Nuevo / 31 Dic | +0.0% | 0.0176 * |
| Buen Fin | +3.3% | 0.2269  |
| Vispera de festivo | +3.5% | 0.0568  |
| Primer dia post-festivo | +2.5% | 0.1460  |
| Quincena-fin x Viernes [interaccion] | -11.5% | 0.0000 *** |

---

*v3.1.0 · 2026-08-07 · Pipeline versionado en generators/forecast/. El analisis de dias
atipicos y su racional viven en `growth-forecast-dias-atipicos.md`.*
