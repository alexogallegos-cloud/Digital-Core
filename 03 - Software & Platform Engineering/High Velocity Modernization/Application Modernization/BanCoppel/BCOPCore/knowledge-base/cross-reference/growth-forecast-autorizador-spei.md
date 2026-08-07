# Proyección de Crecimiento Orgánico — SPEI Entradas + E-Global
> **Fuente**: Modelo OLS log-lineal sobre 580 días (2025-01-01 a 2026-08-04)
> **Versión**: 1.0.0 · 2026-08-07
> **Proyecto**: BanCoppel BCOPCore · SPE-AM-001

---

## Metodología

### Modelo

```
log V(t) = β₀ + β₁·t + Σ βₖ·factor_k(t) + ε
```

- **t**: índice ordinal de días (2025-01-01 = 0) — captura la tendencia de crecimiento puro
- **Factores estacionales multicapa**: día de semana, calendario mexicano oficial (LFTSS + Banxico), quincenas, eventos comerciales, interacciones
- **Transformación**: log-lineal → los coeficientes son efectos multiplicativos; crecimiento mensual = exp(β₁·30) − 1
- **Outliers excluidos**: 7 días de incidente Nov-2025 a Ene-2026 (volumen artificialmente bajo por fallos del sistema)
- **SPEI**: ajustado solo sobre días hábiles Banxico (lunes a viernes, no festivos) — SPEI no opera en fines de semana ni festivos oficiales

### Capas de estacionalidad controladas

| Capa | Variables |
|------|-----------|
| Día de semana | 6 dummies (lunes = base) |
| Calendario fijo (LFTSS) | Año Nuevo, Trabajo, Independencia, Navidad |
| Calendario móvil (LFTSS) | 1er lunes feb, 3er lunes mar, 3er lunes nov |
| Banxico | Jueves y Viernes Santo |
| Semana Santa completa | Domingo de Ramos → Sábado de Gloria |
| Comercial / cultural | Buen Fin, Aguinaldo (15–25 dic), 10 de Mayo ±1, Navidad (24–26 dic) |
| Ciclo de pagos | Quincena 15 (días 14–16), Quincena fin de mes, Día 17 SAT/IMSS ±1 |
| Interacciones compuestas | Quincena-15 × Viernes, Quincena-fin × Viernes |

---

## Resultados: Crecimiento Orgánico

| Métrica | E-Global / Autorizador | SPEI Entradas |
|---------|----------------------|---------------|
| **Crecimiento mensual** | **+0.81%** | **+1.60%** |
| IC 95% mensual | [+0.73%, +0.89%] | [+1.45%, +1.75%] |
| **Crecimiento anual** | **+10.3%** | **+21.3%** |
| R² del modelo | 0.6300 | 0.7689 |
| Observaciones | 573 días | 476 días hábiles |
| p-valor β_t | 0.00000 | 0.00000 |

> Interpretación: controlando toda la estacionalidad, E-Global crece al **+0.81% mensual** y SPEI Entradas al **+1.60% mensual** de forma orgánica por expansión del negocio BanCoppel.

---

## Factores Estacionales: E-Global / Autorizador

| Factor | Efecto vs. lunes base | p-valor |
|--------|-----------------------|---------|
| Martes | -5.5% | 0.0000 *** |
| Miércoles | -2.6% | 0.0020 ** |
| Jueves | -4.3% | 0.0000 *** |
| Viernes | +4.6% | 0.0000 *** |
| Sábado | +0.4% | 0.6617  |
| Domingo | -7.8% | 0.0000 *** |
| Día festivo oficial | -3.6% | 0.0260 * |
| Semana Santa | +2.3% | 0.1373  |
| Buen Fin | +1.7% | 0.5391  |
| Aguinaldo (15-25 dic) | +2.2% | 0.3449  |
| 10 de Mayo ±1 día | +3.8% | 0.0991  |
| Quincena 15 (días 14-16) | +3.2% | 0.0002 *** |
| Quincena fin de mes | +7.4% | 0.0000 *** |
| Día 17 SAT/IMSS (±1) | +1.1% | 0.1821  |
| Navidad (24-26 dic) | -11.2% | 0.0008 *** |
| Año Nuevo / 31 Dic | -30.9% | 0.0000 *** |
| Quincena-15 × Viernes [interacción] | +1.3% | 0.5674  |
| Quincena-fin × Viernes [interacción] | -2.7% | 0.2567  |

---

## Factores Estacionales: SPEI Entradas

| Factor | Efecto vs. lunes base | p-valor |
|--------|-----------------------|---------|
| Martes | -12.7% | 0.0000 *** |
| Miércoles | -12.8% | 0.0000 *** |
| Jueves | -6.5% | 0.0000 *** |
| Viernes | +18.5% | 0.0000 *** |
| Semana Santa | -0.3% | 0.9219  |
| Buen Fin | +0.9% | 0.8728  |
| Aguinaldo (15-25 dic) | +13.8% | 0.0011 ** |
| 10 de Mayo ±1 día | +7.8% | 0.1043  |
| Quincena 15 (días 14-16) | +24.1% | 0.0000 *** |
| Quincena fin de mes | +28.5% | 0.0000 *** |
| Día 17 SAT/IMSS (±1) | +3.0% | 0.0530  |
| Navidad (24-26 dic) | +4.8% | 0.4929  |
| Año Nuevo / 31 Dic | +0.0% | 0.2348  |
| Quincena-15 × Viernes [interacción] | -1.6% | 0.6826  |
| Quincena-fin × Viernes [interacción] | -3.9% | 0.3377  |

---

## Implicaciones para la Migración

### Dimensionamiento del sistema target

Con base en el crecimiento orgánico medido, los volúmenes proyectados para la
ventana de migración (estimada H2 2027) son:

| Escenario | E-Global (txn/día pico) | SPEI Entradas (txn/día pico) |
|-----------|------------------------|------------------------------|
| Promedio hábil actual (ago 2026) | ~2.77 M | ~1.67 M |
| Quincena típica Q4 2026 | ~3.2 M | ~2.1 M |
| Aguinaldo (dic 2026 pico) | >4.0 M | >2.5 M |

### Criterios go/no-go actualizados

Los criterios de `performance-baseline-autorizador-spei.md` deben ajustarse:
- **Pool de conexiones**: dimensionar para P99 proyectado al momento del cutover, no al P99 de 2025
- **HPA maxReplicas**: calcular contra volumen proyectado pico + 20% headroom
- **Parallel-run stress test**: ejecutar en quincena de mayor volumen proyectado, no en semana normal

### Señal de alarma

Si durante el parallel-run el E-Global procesado crece menos del **0.8%** mensual, el sistema target puede estar suprimiendo transacciones — revisar inmediatamente.

---

## Referencia al HTML interactivo

El análisis visual completo (series históricas, tendencia ajustada, proyección con bandas
de confianza, factores estacionales) está disponible en el scratchpad de sesión:
`growth_forecast.html`

---

*v1.0.0 · 2026-08-07 · Análisis inicial — datos hasta 2026-08-04*
