# Proyeccion de Crecimiento Organico — SPEI Entradas + E-Global (v3)
> **Fuente**: Modelo OLS log-lineal v3 — SPEI modelado sobre los 7 dias con ventana de quincena asimetrica
> **Version**: 3.0.0 · 2026-08-07
> **Proyecto**: BanCoppel BCOPCore · SPE-AM-001

---

## Cambio central de v3: SPEI es un riel 24/7

El EDA sobre datos crudos mostro que SPEI Entradas opera todos los dias con volumen alto:

| Dia | Volumen (mediana) vs mediana dias habiles L-V | Dias con datos |
|-----|-----------------------------------------------|----------------|
| Viernes | 125% | — |
| **Sabado** | **112%** | 82/82 |
| Lunes | 101% | — |
| Jueves | 99% | — |
| Martes | 91% | — |
| Miercoles | 92% | — |
| **Domingo** | **79%** | 82/82 |

Excluir sabados y domingos (como hizo v2) descartaba ~1/3 de la operacion real y volvia
imposible modelar la absorcion de fin de semana. **v3 modela SPEI sobre los 7 dias.**
E-Global se mantiene en dias habiles L-V (ver nota al final).

---

## Ventana de quincena asimetrica x dia de la semana

El deposito de nomina cae en el **dia habil de deposito** (ancla = dia habil mas cercano
al 15 / al ultimo dia del mes). El spike se reparte alrededor del ancla, y su forma
depende del dia de la semana en que cae el ancla.

### Analisis de amplitud de ventana (multiplicador marginal vs dia normal del mes)

| Offset desde ancla | Exceso de volumen | Decision de modelado |
|--------------------|-------------------|----------------------|
| Q+0 (deposito) | +50% | Nucleo — incluido |
| Q+1 | +32% | Nucleo — incluido |
| Q-1 | +7.6% | Incluido (pre-funding) |
| Q+2 | +6.4% | Incluido (marginal) |
| Q+3 | +12% pero ruidoso | **Descartado** — contaminacion con dia-17 y 1er dia de mes (modelados aparte) |
| Q-2, Q-3 | -2 a -3% | Descartado (es el valle previo, no un pico) |
| Q+-4 | ~+1% | Descartado (ruido) |

### Superficie observada (multiplicador por DOW del ancla)

| Ancla (dia deposito) | Q+0 | Q+1 | Lectura |
|----------------------|-----|-----|---------|
| **Jueves** | 1.45 | **1.48** (=Vie) | Doble efecto: quincena + viernes de gasto |
| **Viernes** | 1.59 | **1.37** (=Sab) | El sabado absorbe el flujo de la quincena |
| **Lunes** | 1.44 | 1.18 (=Mar) | Fin de semana previo elevado (Q-2=Sab 1.22) — pre-funding |

### Hallazgo: el "factor compuesto" ya vive en la forma log-lineal

Se probaron explicitamente tres interacciones ventana x DOW y **ninguna resulto necesaria**:

| Interaccion probada | Coef. | p-valor | Veredicto |
|---------------------|-------|---------|-----------|
| Q+1 en Viernes (ancla Jueves) | -4.4% | 0.23 | No significativa |
| Q+1 en Sabado (ancla Viernes) | +0.0% | 0.98 | No significativa |
| Q-1 en Viernes (ancla Lunes) | — | — | Estructuralmente imposible (ancla siempre habil) |

La razon es que el efecto DOW y el efecto ventana **se apilan multiplicativamente**, que es
exactamente lo que codifica el modelo log-lineal sin necesidad de terminos de interaccion:

- Ancla Jueves -> Q+1 = Viernes: `Viernes (x1.239) x Q+1 (x1.222) = x1.51` vs **1.48 observado**.
- Ancla Viernes -> Q+1 = Sabado: `Sabado (x1.149) x Q+1 (x1.222) = x1.40` vs **1.37 observado**.

Es decir, la intuicion de negocio del **factor compuesto es correcta** y el modelo ya la
representa: un dia que es a la vez viernes y post-quincena se predice como el producto de
ambos factores. No hay bono super-aditivo, asi que el modelo final se queda con los efectos
principales (DOW + ventana Q-1..Q+2) y el producto emerge solo.

---

## Resultados: Crecimiento Organico

| Metrica | E-Global / Autorizador | SPEI Entradas |
|---------|------------------------|---------------|
| **Crecimiento mensual** | **+0.91%** | **+1.62%** |
| IC 95% mensual | [+0.84%, +0.98%] | [+1.54%, +1.71%] |
| **Crecimiento anual** | **+11.7%** | **+21.6%** |
| R² | 0.7875 | 0.9280 |
| R² ajustado | 0.7767 | 0.9254 |
| Observaciones | 374 dias habiles | 540 dias (7-dia) |
| p-valor tendencia | 0.00000 | 0.00000 |

> Nota: el crecimiento organico de SPEI en v3 no es directamente comparable con v2 porque
> la base de dias cambio (7 dias vs solo habiles). La tendencia `t` sigue midiendo el
> crecimiento organico diario controlando toda la estacionalidad.

---

## Factores Estacionales: E-Global / Autorizador (dias habiles L-V)

| Factor | Efecto vs lunes base | p-valor |
|--------|----------------------|---------|
| Martes | -7.0% | 0.0000 *** |
| Miercoles | -4.2% | 0.0038 ** |
| Jueves | -5.1% | 0.0004 *** |
| Viernes | +3.1% | 0.0432 * |
| Quincena 15 (dia deposito) | +6.0% | 0.0000 *** |
| Quincena fin de mes (dia deposito) | +10.7% | 0.0000 *** |
| Primer dia habil del mes | +5.6% | 0.0000 *** |
| Dia 17 SAT/IMSS (dia habil exacto) | +2.1% | 0.0342 * |
| Semana Santa | +10.6% | 0.0000 *** |
| Aguinaldo (15-23 dic) | +5.0% | 0.0084 ** |
| 10 de Mayo +/-1 | +3.6% | 0.1777  |
| Navidad (24-26 dic) | +1.4% | 0.6404  |
| Anio Nuevo / 31 Dic | +0.0% | 0.0000 *** |
| Buen Fin | +1.3% | 0.6172  |
| Vispera de festivo | +2.7% | 0.2036  |
| Primer dia post-festivo | -2.0% | 0.1407  |
| Quincena-15 x Viernes [interaccion] | -1.3% | 0.4939  |
| Quincena-fin x Viernes [interaccion] | -4.6% | 0.0182 * |

---

## Factores Estacionales: SPEI Entradas (7 dias)

| Factor | Efecto vs lunes base | p-valor |
|--------|----------------------|---------|
| Martes | -4.0% | 0.0486 * |
| Miercoles | -4.7% | 0.0280 * |
| Jueves | +1.2% | 0.5922  |
| Viernes | +24.3% | 0.0000 *** |
| Sabado | +15.4% | 0.0000 *** |
| Domingo | -17.2% | 0.0000 *** |
| Quincena 15 (dia deposito) | +37.6% | 0.0000 *** |
| Quincena fin de mes (dia deposito) | +39.5% | 0.0000 *** |
| Vispera de quincena (Q-1) | +13.8% | 0.0000 *** |
| Post-quincena (Q+1) | +22.1% | 0.0000 *** |
| Post-quincena (Q+2) | +12.8% | 0.0000 *** |
| Primer dia habil del mes | +9.8% | 0.0000 *** |
| Aguinaldo (15-23 dic) | +13.4% | 0.0000 *** |
| 10 de Mayo +/-1 | +7.6% | 0.0012 ** |
| Navidad (24-26 dic) | +8.5% | 0.0494 * |
| Anio Nuevo / 31 Dic | +0.0% | 0.0000 *** |
| Buen Fin | +3.8% | 0.1738  |
| Vispera de festivo | +7.9% | 0.0001 *** |
| Primer dia post-festivo | +6.3% | 0.0027 ** |

---

## Implicaciones para la Migracion

- El **sabado post-quincena** (cuando el ancla cae en viernes) es un pico de SPEI que v2
  ni siquiera veia. El dimensionamiento del sistema target y las ventanas de parallel-run
  deben cubrir explicitamente los fines de semana de quincena, no solo dias habiles.
- El **viernes de doble efecto** (quincena en jueves + gasto de viernes) es el mayor pico
  recurrente de SPEI. Es el peor dia para un cutover.
- SPEI no tiene ventana de cierre operativo de fin de semana — el sistema target debe
  sostener carga 24/7/365, incluida la madrugada de sabado y domingo.

---

## Nota sobre E-Global / Autorizador

E-Global se mantiene modelado solo sobre dias habiles L-V. El Autorizador de tarjetas
tambien procesa fin de semana; si se confirma que la fuente de E-Global incluye
transaccionalidad de sabado/domingo con volumen material, conviene reespecificarlo a 7 dias
igual que SPEI en una v4. Pendiente de validar la semantica de la serie E-Global.

---

*v3.0.0 · 2026-08-07 · SPEI reespecificado a 7 dias (riel 24/7) + ventana de quincena asimetrica Q-1..Q+2 con interacciones DOW (Q+1 viernes/sabado, Q-1 viernes). Supersede v2.0.0.*
