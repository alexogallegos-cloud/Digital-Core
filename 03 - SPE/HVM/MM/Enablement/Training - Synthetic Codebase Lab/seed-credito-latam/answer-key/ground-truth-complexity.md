# Ground Truth — Matriz de Complejidad · SISTEMA-CREDITO-LATAM

> Espeja la "Matriz de Complejidad" (Etapa 1) del Specialist - Reverse Engineering.
> CC = nº de IF + EVALUATE WHEN + PERFORM UNTIL + AND/OR + 1.

| Programa | LOC aprox | CC objetivo | CALLs salientes | CALLs entrantes | Riesgo |
|----------|-----------|-------------|------------------|------------------|--------|
| CREDVAL | 175 | 19 | 2 (LIMCHK, SCOVAL) | 1 (PROCREDI) | Alto |
| LIMCHK | 45 | 6 | 0 | 1 (CREDVAL) | Medio |
| SCOVAL | 40 | 4 | 1 dinámico | 1 (CREDVAL) | Medio (dinámico) |
| CREDALT | 50 | 5 | 0 | 1 (PROCREDI) | Medio |
| RPTGEN | 50 | 5 | 0 | 1 (PROCREDI) | Bajo |
| OLDVAL | 35 | 3 | 0 | **0** | Bajo · dead code |

- CC medio ponderado del sistema ≈ 11 (coincide con `cyclomatic_avg: 11` de la spec).
- Pico CC en CREDVAL ≈ 19 (coincide con `cyclomatic_max: 19`).