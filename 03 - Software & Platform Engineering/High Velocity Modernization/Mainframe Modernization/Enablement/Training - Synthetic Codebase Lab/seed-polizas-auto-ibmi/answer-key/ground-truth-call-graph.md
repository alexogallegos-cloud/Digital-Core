# Ground Truth — Call Graph · SISTEMA-POLIZAS-AUTO

## Edges esperados (7 en total)

| # | Origen | Destino | Tipo | Resoluble estáticamente |
|---|--------|---------|------|--------------------------|
| 1 | PROCNOC (CL) | POLVAL | CALL PGM | Sí |
| 2 | PROCNOC (CL) | POLALT | CALL PGM | Sí |
| 3 | PROCNOC (CL) | RPTSIN | CALL PGM | Sí |
| 4 | PROCNOC (CL) | BCKPOL | CALL PGM | Sí (target sin fuente — shadow) |
| 5 | POLVAL | PRIMCALC | CALLP (prototipo extpgm) | Sí |
| 6 | POLVAL | RIESGOEV | CALLP (prototipo extpgm) | Sí |
| 7 | RIESGOEV | SCOREXT | **CALLP dinámico** (`extpgm(wProgScore)`) | **NO** — `[AMBIGUO]` para RE |

OLDPRIM: **0 edges entrantes, 0 salientes** → dead code.

## Diagrama ASCII

```
SCHEDULER
    │
    ▼
PROCNOC (CL)
    ├──────────────┬──────────────┬──────────────┐
    ▼              ▼              ▼              ▼
 POLVAL         POLALT         RPTSIN         BCKPOL
    ├──────┐                                  (shadow:
    ▼      ▼                                   sin fuente)
PRIMCALC RIESGOEV
            │
            ▼ (dinámico extpgm)
        [SCOREXT]   ← target en runtime, no estático

  OLDPRIM  ← dead code: nadie lo llama
```

## Reveladores de benchmark
- El edge dinámico #7 usa `extpgm(wProgScore)` — el target ('SCOREXT') sólo se conoce en runtime.
- BCKPOL aparece sólo en el CL → shadow inventory; herramientas que sólo escanean RPG lo pierden.