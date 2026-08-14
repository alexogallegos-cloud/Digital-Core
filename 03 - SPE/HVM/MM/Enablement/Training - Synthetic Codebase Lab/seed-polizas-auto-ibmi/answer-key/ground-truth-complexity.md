# Ground Truth — Matriz de Complejidad · SISTEMA-POLIZAS-AUTO

| Programa | LOC aprox | CC objetivo | CALLs salientes | CALLs entrantes | Riesgo |
|----------|-----------|-------------|------------------|------------------|--------|
| POLVAL | 90 | 18 | 2 (PRIMCALC, RIESGOEV) | 1 (PROCNOC) | Alto |
| PRIMCALC | 40 | 5 | 0 | 1 (POLVAL) | Medio |
| RIESGOEV | 50 | 7 | 1 dinámico | 1 (POLVAL) | Medio (dinámico) |
| POLALT | 35 | 4 | 0 | 1 (PROCNOC) | Medio |
| RPTSIN | 40 | 8 | 0 | 1 (PROCNOC) | Medio · **indicadores** |
| OLDPRIM | 35 | 4 | 0 | **0** | Bajo · dead code |

- CC medio ponderado ≈ 10 (coincide con `cyclomatic_avg: 10`).
- Pico CC en POLVAL ≈ 18 (coincide con `cyclomatic_max: 18`).
- `[RPGTPN]` RPTSIN suma complejidad oculta por el uso de indicadores `*IN50/*IN60` como booleanos globales — mapear todos los indicadores antes de refactorizar.