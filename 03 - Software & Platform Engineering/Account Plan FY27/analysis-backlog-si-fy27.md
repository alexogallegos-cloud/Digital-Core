# Análisis — Backlog SI · FY27 · Vista SIN SAP
> Fuente: `source/Backlog SI V1.xlsx` (Service Group = SI, 255 contratos) · Análisis: 2026-07-07
> Unidades: miles USD · Owner: alejandro.gallegos@accenture.com

---

## Corrección importante vs. análisis previo

En el primer pase asumí que **BBVA "Atenea"** era SAP. **No lo es** — su nombre (`MX-BK-SI-DF Atenea`) no tiene ningún marcador SAP/S4/HANA. Reclasifiqué solo con keywords SAP reales. Consecuencia: **BBVA Atenea es el mayor contrato que sangra y NO es SAP** — quitar SAP no lo resuelve. Pendiente: confirmar qué es Atenea (¿custom dev? ¿core banking?).

---

## Headline — con SAP vs sin SAP

| Métrica | Backlog CON SAP | Backlog SIN SAP | Efecto de quitar SAP |
|---------|-----------------|-----------------|----------------------|
| **Revenue FY27** | $18.03M | **$13.28M** | −$4.75M (−26%) |
| **CCI blended** | 26.8% | **33.3%** | **+6.5 pts** |
| **Contribución ($)** | $4.82M | $4.42M | −$0.40M |

Quitar SAP **sube el margen 6.5 puntos** (26.8% → 33.3%) pero **cuesta $4.75M de revenue** y ~$0.40M de contribución neta. El SAP en el book es $4.75M a solo **8.4% CCI** — mucho volumen, margen pésimo.

---

## Matiz: "todo el SAP" también quita SAP rentable

No todo el SAP sangra. El book SAP tiene contribución **neta positiva** (+$400K), mezcla de ganadores y perdedores:

| Contrato SAP | Backlog | CCI $ | CCI % | |
|--------------|---------|-------|-------|---|
| Coca-Cola — KOF Digital Procurement S/4HANA | $1,408K | +$348K | 25% | ✅ sano |
| Mondelez — MDLZ SAP S4 HANA | $1,362K | +$259K | 19% | ✅ ok |
| G500 — Paquete Servicios SAP | $147K | +$95K | 65% | ✅ excelente |
| AstraZeneca — SAP Axial Ph1 | $475K | +$83K | 18% | ✅ ok |
| **Cuprum — APOLO SAP S/4HANA** | $1,272K | **−$222K** | −17% | ❌ sangra |
| **Mondelez — S4 Hana MEU Swiss** | $80K | **−$236K** | −296% | ❌ sangra grave |
| AstraZeneca MSA · Compartamos RISE · Citi Basis | ~$4K | −$24K | neg | ❌ overruns |

> **Decisión de fondo**: "quita todo SAP" mejora el % pero tira $348K sanos de Coca-Cola KOF y $259K de Mondelez. La alternativa quirúrgica — **quitar solo el SAP que sangra** (Cuprum Apolo + Mondelez MEU Swiss = −$458K) y conservar el SAP rentable — sube el margen SIN sacrificar los $700K+ de contribución sana. Recomendado sobre el corte total.

---

## Impacto por cuenta named — qué se vacía al quitar SAP

| Cuenta | Backlog c/SAP | CCI% | Backlog SIN SAP | CCI% | Nota |
|--------|---------------|------|-----------------|------|------|
| **Santander** | $4,234K | 36.2% | **$4,234K** | 36.2% | Limpio — 100% no-SAP. La joya. |
| **Newmont** | $677K | 42.4% | $677K | 42.4% | Limpio, gran margen |
| **BBVA** | $847K | −32.5% | **$847K** | **−32.5%** | Atenea (NO SAP) sigue sangrando |
| **Citi/Banamex** | $545K | 12.1% | $545K | 12.3% | Limpio, margen bajo |
| **Volaris** | $177K | 60.1% | $177K | 60.1% | Limpio, excelente |
| **Cuprum** | $1,272K | −17.5% | **$0K** | — | **Se vacía — 100% SAP Apolo** |
| **Coca-Cola** | $1,459K | 33.5% | **$50K** | 87% | **Se vacía — 97% SAP KOF** |
| **Mondelez** | $1,648K | 5.6% | **$206K** | 33% | **Se desploma — 87% SAP** |
| Actinver · Sabadell · Coppel · Walmart | pequeños | — | igual | — | Limpios |

**Lo que revela**: tres de tus mayores cuentas named por backlog (Cuprum, Coca-Cola, Mondelez) **son esencialmente cuentas SAP**. Sin SAP, tu backlog S&PE real se concentra en **Santander, BBVA, Newmont, Citi** — y Santander domina aún más.

---

## El $42M @ 36.8% — recalculado SIN SAP

| Concepto | Revenue | CCI | Contribución |
|----------|---------|-----|--------------|
| Backlog SIN SAP (base) | $13.28M | 33.3% | $4.42M |
| **Falta para $42M** | **~$28.7M** (nuevo) | **~38.4%** ← | $11.03M |
| Target $42M @ 36.8% | $42.0M | 36.8% | $15.46M |

**El nuevo negocio ahora debe entrar a ~38.4% CCI** — vs 44.3% cuando el SAP de bajo margen estaba en la base. **Quitar SAP hace el 36.8% mucho más alcanzable**: el CCI requerido a la venta nueva baja ~6 puntos y queda cerca del estándar de 41%.

Trade-off: sin SAP arrancas con menos revenue comprometido, así que el gap de venta nueva crece de ~$24M a ~$28.7M. Pero la matemática de margen se vuelve realista.

---

## Los bleeders que quedan DESPUÉS de quitar SAP

| Cuenta | Contrato | Backlog | CCI | ¿SAP? |
|--------|----------|---------|-----|-------|
| **BBVA** | MX-BK-SI-DF **Atenea** | $819.9K | **−$290.4K (−35%)** | **NO** — confirmar qué es |

Quitando SAP **y** BBVA Atenea: backlog $12.46M a **37.8% CCI** — ya por encima del escenario 36.8%. Atenea es el siguiente lever después de SAP.

---

## Estrellas limpias (proteger — no dependen de SAP)

| Cuenta | Backlog SIN SAP | CCI | Nota |
|--------|-----------------|-----|------|
| **Santander** | $4,234K | 36.2% | ×12 vs FY26. La joya, y 100% limpia. Blindar. |
| Newmont | $677K | 42.4% | Minería, gran margen |
| Volaris | $177K | 60.1% | Mejor margen del book |
| Actinver | $79K | 56.0% | Wealth, alto margen |

Fuera de las named, el motor de margen limpio: **Amazon** ($2,221K @ 48%), **L'Oréal** ($2,486K @ 40%), **Sanofi** ($469K @ 37%).

---

## Implicaciones para el Account Plan FY27

1. **Quitar SAP sube el margen de 26.8% a 33.3%** pero cuesta $4.75M de revenue. Preferir el **corte quirúrgico** (solo Cuprum Apolo + Mondelez MEU Swiss) para no perder el SAP rentable de Coca-Cola KOF y Mondelez.
2. **BBVA Atenea (−$290K) NO es SAP** — es el bleeder #1 restante. Confirmar naturaleza y decidir re-scope/exit. Vale +4.5 pts de CCI.
3. **Sin SAP, el $42M @ 36.8% es realista**: venta nueva a ~38.4% CCI (cerca del estándar), no 44.3%.
4. **Tu backlog S&PE "puro" se concentra en Santander** — riesgo de concentración alto. Diversificar con Newmont, banca limpia y el whitespace (Banorte, Liverpool, Techint, Arca).
5. **Coca-Cola, Cuprum, Mondelez son cuentas SAP** — si S&PE no las quiere por SAP, ¿se transfieren a la práctica SAP o se buscan workstreams no-SAP en ellas?

---

*Análisis de `source/Backlog SI V1.xlsx` · SAP clasificado por keywords en nombre de contrato (SAP/S4/HANA/ECC/Fiori/Ariba/Netweaver/RISE/BTP) · BBVA Atenea = NO SAP · Cubre solo Service Group = SI*