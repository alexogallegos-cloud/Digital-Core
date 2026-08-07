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

## SPEI es un riel 24/7

El EDA mostro volumen alto todos los dias (Sabado 112%, Domingo 79% del volumen habil L-V);
por eso SPEI se modela sobre los 7 dias. La ventana de quincena se ancla al dia habil de
deposito y es asimetrica: Q+1 pesa mas que Q-1, y el fin de semana absorbe el flujo cuando
el deposito cae en viernes.

---

## Resultados: Crecimiento Organico

| Metrica | E-Global / Autorizador | SPEI Entradas |
|---------|------------------------|---------------|
| **Crecimiento mensual** | **+0.87%** | **+1.55%** |
| IC 95% mensual | [+0.78%, +0.95%] | [+1.47%, +1.64%] |
| **Crecimiento anual** | **+11.1%** | **+20.6%** |
| R² | 0.6849 | 0.9353 |
| R² ajustado | 0.6696 | 0.9323 |
| Observaciones | 389 dias habiles | 557 dias (7-dia) |

---

## Factores Estacionales: E-Global / Autorizador (dias habiles L-V)

| Factor | Efecto vs lunes base | p-valor |
|--------|----------------------|---------|
| Martes | -4.9% | 0.0000 *** |
| Miercoles | -2.3% | 0.0020 ** |
| Jueves | -3.4% | 0.0000 *** |
| Viernes | +4.6% | 0.0000 *** |
| Quincena 15 (dia deposito) | +6.1% | 0.0001 *** |
| Quincena fin de mes (dia deposito) | +9.8% | 0.0000 *** |
| Primer dia habil del mes | +4.6% | 0.0001 *** |
| Dia 17 SAT/IMSS (dia habil exacto) | +2.1% | 0.0821  |
| Semana Santa | +2.4% | 0.2431  |
| Aguinaldo (15-23 dic) | +5.0% | 0.0352 * |
| 10 de Mayo +/-1 | +3.7% | 0.2701  |
| Navidad (24-26 dic) | -1.5% | 0.6651  |
| Anio Nuevo / 31 Dic | +0.0% | 0.0000 *** |
| Buen Fin | +1.4% | 0.6642  |
| Vispera de festivo | +8.4% | 0.0004 *** |
| Primer dia post-festivo | -1.3% | 0.3844  |
| Quincena-15 x Viernes [interaccion] | -1.0% | 0.6702  |
| Quincena-fin x Viernes [interaccion] | -3.4% | 0.1368  |

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
