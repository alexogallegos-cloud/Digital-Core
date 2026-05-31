# Ground Truth — Call Graph · SISTEMA-CREDITO-LATAM

> Espeja el "Call Graph" (Etapa 1) del Specialist - Reverse Engineering.

## Edges esperados (7 en total)

| # | Origen | Destino | Tipo | Resoluble estáticamente |
|---|--------|---------|------|--------------------------|
| 1 | PROCREDI (JCL) | CREDVAL | EXEC PGM | Sí |
| 2 | PROCREDI (JCL) | CREDALT | EXEC PGM | Sí |
| 3 | PROCREDI (JCL) | RPTGEN | EXEC PGM | Sí |
| 4 | PROCREDI (JCL) | BCKPUTI | EXEC PGM | Sí (pero target sin fuente — shadow) |
| 5 | CREDVAL | LIMCHK | CALL estático | Sí |
| 6 | CREDVAL | SCOVAL | CALL estático | Sí |
| 7 | SCOVAL | BUROEXT1 | **CALL dinámico** (`CALL WS-PROG-BURO`) | **NO** — `[AMBIGUO]` para RE |

OLDVAL: **0 edges entrantes, 0 salientes** → dead code.

## Diagrama ASCII

```
SCHEDULER
    │
    ▼
PROCREDI (JCL)
    ├──────────────┬──────────────┬──────────────┐
    ▼              ▼              ▼              ▼
 CREDVAL        CREDALT        RPTGEN        BCKPUTI
    ├──────┐                                  (shadow:
    ▼      ▼                                   sin fuente)
 LIMCHK  SCOVAL
            │
            ▼ (dinámico)
        [BUROEXT1]   ← target en runtime, no estático

  OLDVAL  ← dead code: nadie lo llama
```

## Reveladores de benchmark
- Una herramienta con **recall alto** debe cazar el edge dinámico #7 (marcándolo ambiguo) y el shadow #4.
- Quien NO detecte BCKPUTI como shadow inventory, o cuente OLDVAL como vivo, tiene recall bajo donde más cuesta en una migración real.