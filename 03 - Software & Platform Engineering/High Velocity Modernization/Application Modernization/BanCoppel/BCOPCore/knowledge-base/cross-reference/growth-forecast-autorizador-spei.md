# Proyeccion de Crecimiento Organico — SPEI Entradas + E-Global (v2)
> **Fuente**: Modelo OLS log-lineal v2 con filtrado avanzado y remocion estadistica de outliers
> **Version**: 2.0.0 · 2026-08-07
> **Proyecto**: BanCoppel BCOPCore · SPE-AM-001

---

## Mejoras sobre v1

| Aspecto | v1 | v2 |
|---------|----|----|
| Filtro E-Global | Todos los dias (dom + festivos con dummy) | Solo dias habiles Lun-Vie, sin festivos |
| Quincena 15 | Dias 14-16 (ventana +/-1) | Dia habil exacto mas cercano al 15 |
| Quincena fin de mes | Ultimos 2 dias calendario | Exacto ultimo dia habil del mes |
| Primer dia del mes | No modelado | Primer dia habil del mes (pagos acumulados) |
| Dia 17 SAT/IMSS | +/-1 dia calendario | Dia habil exacto mas cercano al 17 |
| Vispera de festivo | No modelado | Indicador: dia inmediatamente antes de festivo |
| Post-festivo | No modelado | Primer dia habil tras festivo o puente |
| Outliers estadisticos | Ninguna remocion | Residuos estudentizados |t*| > 2.5, hasta 2 iteraciones |

---

## Resultados: Crecimiento Organico

| Metrica | E-Global / Autorizador | SPEI Entradas |
|---------|----------------------|---------------|
| **Crecimiento mensual** | **+0.91%** | **+1.54%** |
| IC 95% mensual | [+0.84%, +0.98%] | [+1.42%, +1.65%] |
| **Crecimiento anual** | **+11.7%** | **+20.4%** |
| R² | 0.7875 | 0.8968 |
| R² ajustado | 0.7767 | 0.8916 |
| Observaciones | 374 dias habiles | 374 dias habiles |
| p-valor tendencia | 0.00000 | 0.00000 |

---

## Factores Estacionales: E-Global / Autorizador

| Factor | Efecto vs lunes base | p-valor |
|--------|-----------------------|---------|
| Martes | -7.0% | 0.0000 *** |
| Miercoles | -4.2% | 0.0038 ** |
| Jueves | -5.1% | 0.0004 *** |
| Viernes | +3.1% | 0.0432 * |
| Vispera de festivo | +2.7% | 0.2036  |
| Primer dia post-festivo | -2.0% | 0.1407  |
| Semana Santa | +10.6% | 0.0000 *** |
| Buen Fin | +1.3% | 0.6172  |
| Aguinaldo (15-23 dic) | +5.0% | 0.0084 ** |
| 10 de Mayo +/-1 | +3.6% | 0.1777  |
| Quincena 15 (dia habil exacto) | +6.0% | 0.0000 *** |
| Quincena fin de mes (ultimo dia habil) | +10.7% | 0.0000 *** |
| Primer dia habil del mes | +5.6% | 0.0000 *** |
| Dia 17 SAT/IMSS (dia habil exacto) | +2.1% | 0.0342 * |
| Navidad (24-26 dic) | +1.4% | 0.6404  |
| Anio Nuevo / 31 Dic | +0.0% | 0.0000 *** |
| Quincena-15 x Viernes [interaccion] | -1.3% | 0.4939  |
| Quincena-fin x Viernes [interaccion] | -4.6% | 0.0182 * |

---

## Factores Estacionales: SPEI Entradas

| Factor | Efecto vs lunes base | p-valor |
|--------|-----------------------|---------|
| Martes | -3.9% | 0.0995  |
| Miercoles | -4.2% | 0.0885  |
| Jueves | +4.9% | 0.0574  |
| Viernes | +27.4% | 0.0000 *** |
| Vispera de festivo | +5.4% | 0.1002  |
| Primer dia post-festivo | +5.3% | 0.0284 * |
| Semana Santa | +16.9% | 0.0000 *** |
| Buen Fin | +2.3% | 0.6178  |
| Aguinaldo (15-23 dic) | +21.4% | 0.0000 *** |
| 10 de Mayo +/-1 | +6.6% | 0.1553  |
| Quincena 15 (dia habil exacto) | +41.9% | 0.0000 *** |
| Quincena fin de mes (ultimo dia habil) | +47.0% | 0.0000 *** |
| Primer dia habil del mes | +19.8% | 0.0000 *** |
| Dia 17 SAT/IMSS (dia habil exacto) | +8.8% | 0.0000 *** |
| Navidad (24-26 dic) | +8.8% | 0.0885  |
| Anio Nuevo / 31 Dic | +0.0% | 0.2673  |
| Quincena-15 x Viernes [interaccion] | -13.2% | 0.0000 *** |
| Quincena-fin x Viernes [interaccion] | -12.5% | 0.0001 *** |

---

## Implicaciones para la Migracion (actualizadas)

Los volumenes proyectados en la ventana de migracion (H2 2027) deben considerar:
- Crecimiento organico E-Global +0.91%/mes acumulado desde ago 2026
- Crecimiento organico SPEI +1.54%/mes acumulado
- Los dias de mayor riesgo siguen siendo quincenas (especialmente fin de mes en viernes)
- El aguinaldo (dic 15-23) y el primer dia habil de enero son los picos anuales confirmados

---

*v2.0.0 · 2026-08-07 · Modelo refinado: filtrado a dias habiles unicamente + remocion iterativa de outliers + quincenas exactas + visperas/post-festivos*
*Supersede growth-forecast-autorizador-spei.md v1.0.0*
