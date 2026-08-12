# Días Atípicos de SPEI — RCA y Temporalidades Descubiertas
> **Fuente**: Análisis de residuos del pipeline `generators/forecast/` sobre SPEI Entradas
> **Versión**: 2.0.0 · 2026-08-07
> **Proyecto**: BanCoppel BCOPCore · SPE-AM-001

Este documento explica el racional de los días que se desvían de la regresión de SPEI, y las
temporalidades que ese análisis reveló e incorporó al modelo.

---

## Principio de remoción de días atípicos

> **Un día atípico se descarta del ajuste SOLO si su desviación no tiene un rational
> predecible — es decir, si es un incidente o algo no predecible. Si la desviación cae en
> una temporalidad conocida, el día NO se bota: se modela como factor o se mantiene en el
> ajuste.**

Esto evita inflar artificialmente el R² botando días que en realidad son señal (aguinaldo,
pre-cierre, rebotes de quincena…). La implementación es una remoción **condicional**:

1. Los **incidentes documentados** (`atypical_days.py`) se excluyen siempre.
2. Se ajusta el modelo y se calcula el residuo estudentizado externo `t*` de cada día.
3. Un día con `|t*| > 2.5` se remueve **únicamente si no tiene ninguna etiqueta de
   calendario** que lo explique (inexplicable → probable incidente/impredecible). Si tiene
   una temporalidad activa, se **mantiene** en el ajuste y se reporta para calibración.

El reporte completo (removidos vs mantenidos) se regenera en `growth-forecast-outliers.json`.

---

## Resultado (SPEI, 7 días)

De 558 días válidos:

- **Removido por inexplicable: 1**
  - `2026-02-22` (domingo), `t* = −2.77`, sin etiqueta de calendario. Domingo de febrero
    anormalmente bajo, sin causa identificable → se descarta como impredecible.
- **Mantenidos (atípicos con rational, no se botan): 10** — todos con temporalidad activa:
  aguinaldo (18-dic, `t*` +5.4), primer día hábil de enero (2-ene), quincena de julio,
  Domingo de la Candelaria (2-feb), temporada decembrina (11-dic), quincena-fin en viernes
  (13-mar), pre-cierre de mayo (28-may), etc.

R² SPEI = **0.935** con el modelo ajustándose sobre 557 de 558 días (99.8%). No se descarta
señal.

---

## Método de RCA

Metodología: hipótesis propia sobre el dato crudo primero (día de la semana, etiquetas de
calendario, signo de la desviación), luego validación con fuentes externas. Un patrón se
promueve a factor si tiene **rational de negocio y ≥ 2 años de evidencia**; con un solo año
o un solo caso, se mantiene sin modelar (para no sobre-ajustar) hasta tener más datos.

---

## Temporalidades descubiertas e incorporadas

### 1. Núcleo de Pascua — Sábado de Gloria + Domingo de Pascua (colapso)

2025-04-19 (`t*` −4.9) y 2026-04-04 (`t*` −4.2), ambos Sábado de Gloria; 2025-04-20 Domingo
de Pascua. Jueves y Viernes Santo ya son festivos (excluidos); el colapso remanente está
concentrado en el fin de semana de Pascua. **2 años de evidencia.**

**Factor** `is_pascua_finde` → **−19.1%** (p < 0.001).

### 2. Temporada decembrina ampliada (1-14 dic)

Diciembre 2025 mostró exceso sistemático (11-dic, 18-dic, y días 1-5-10). El aguinaldo debe
pagarse **antes del 20 de diciembre** por ley (LFT art. 87) y muchas empresas lo escalonan
desde inicio de mes; se suma el gasto navideño. `is_aguinaldo` (15-23) era muy estrecho.

**Factor** `is_temporada_dic` (1-14 dic) → **+13.1%** (p < 0.001), complementa
`is_aguinaldo` (+20.3%) y `is_navidad` (+12.1%). *Cautela: un solo diciembre en datos.*

### 3. Cuesta de enero (2-28 ene)

Déficit sistemático en enero (07, 08, 09, 11, 21, 22, 27). La "cuesta de enero" es un
fenómeno económico documentado en México (menor liquidez y consumo post-fiestas). El RCA
mostró que dura casi todo enero, no solo la primera quincena. **2 años de evidencia.**

**Factor** `is_cuesta_enero` (2-28 ene) → **−6.6%** (p < 0.001).

### 4. Quincena de fin de mes en viernes — sub-aditividad

2026-07-31 y 2026-01-30 (ambos último día hábil en viernes) salieron por debajo de lo que el
modelo multiplicativo predice: parte del flujo se absorbe el sábado (Q+1). 2026-07-31 se
verificó completo (`dia_completo=True`, 1440 min) → no es dato parcial.

**Factor** `is_qlast_fri` → **−11.5%** (p < 0.001). El efecto "puro" de la quincena de fin de
mes (cuando no es viernes) sube a **+47.6%**.

### 5. Pre-cierre de mes (penúltimo día hábil)

2025-03-28, 2025-10-30, 2025-12-30 elevados: liquidaciones/conciliaciones de cierre de mes
extienden el pico más allá del último día hábil.

**Factor** `is_precierre_mes` → **+5.6%** (p < 0.001).

### 6. Rebote de quincena caída en fin de semana

2025-06-16 y 2026-02-16 (lunes) elevados: cuando el 15 cae en domingo, el depósito se
adelanta al viernes y el lunes siguiente rebota con los movimientos represados del fin de
semana. **2 años de evidencia.**

**Factor** `is_lunes_post_qfinde` → **+8.4%** (p < 0.001).

---

## Pendiente — E-Global (fuera del foco actual)

La remoción condicional dejó al descubierto un **cluster de abril 2025 en E-Global** (03, 07,
08, 22, 28-abr, todos `t*` +2.5 a +4.1) sin etiqueta de calendario. No es ruido aleatorio: es
un patrón, probablemente **rebote post-Semana Santa del autorizador de tarjetas**. Debe
investigarse y modelarse cuando se reespecifique E-Global (que además conviene pasar a 7 días
como SPEI). Hasta entonces, esos días se remueven como inexplicables y el R² de E-Global baja
a 0.685 — reflejo honesto de una temporalidad aún no modelada, no un empeoramiento real.

---

## Verificación

- Ninguna fecha atípica de SPEI coincide con un incidente de sistema no documentado; los
  patrones son estacionales/culturales. Los incidentes conocidos ya se excluyen en
  `atypical_days.py`.
- 2026-07-31: `dia_completo=True`, `minutos_observados=1440` → no es dato parcial.

---

## Impacto en el modelo (SPEI)

| Versión | R² SPEI | Nota |
|---------|---------|------|
| v2 (solo días hábiles L-V) | 0.769 | base |
| v3 (7 días + ventana quincena) | 0.928 | riel 24/7 |
| v3.1 (+ temporalidades, remoción ciega 2.5σ) | 0.945 | botaba 21 días (inflaba R²) |
| **v3.2 (remoción condicional, solo 1 día botado)** | **0.935** | honesto: mantiene 557/558 días |

> v3.2 tiene R² algo menor que v3.1 **a propósito**: v3.1 botaba 21 días (muchos
> explicables), lo que inflaba el ajuste. v3.2 solo descarta lo genuinamente inexplicable.

---

## Fuentes externas

- Cuesta de enero: [BBVA México](https://www.bbva.mx/educacion-financiera/temporalidad/cuesta-de-enero/que-es-la-cuesta-de-enero.html) · [Expansión](https://expansion.mx/opinion/2026/01/14/la-cuesta-de-enero-un-termometro-economico-y-cultural)
- Aguinaldo antes del 20-dic (LFT art. 87): [PROFEDET — gob.mx](https://www.gob.mx/profedet/articulos/las-y-los-trabajadores-deben-recibir-el-aguinaldo-antes-del-20-de-diciembre-por-ley-258958)
- Crecimiento SPEI nacional +36.8% 2024→2025: [Bitso / Banxico vía El Cronista](https://www.cronista.com/mexico/pc-celular/spei-mueve-10-veces-el-pib-de-mexico-proceso-7000-millones-de-transferencias-en-2025-bitso/)

> Observación de negocio: el SPEI nacional creció **+36.8%** anual, mientras que las entradas
> SPEI de BanCoppel crecen orgánicamente **~+20.6%** anual — BanCoppel estaría ganando volumen
> SPEI por debajo del mercado nacional. Señal a validar con negocio.

---

*v2.0.0 · 2026-08-07 · Incorpora el principio de remoción condicional (solo se botan días
inexplicables/incidentes) y dos temporalidades adicionales (pre-cierre de mes, rebote de
quincena en fin de semana). Fundamenta los factores en `generators/forecast/factors.py`.*
