# Fase 2 — Regulatorio (externo · `[INVOKE]`)

> Esta fase **no se ejecuta en este offering**. Se orquesta hacia un SME externo del ecosistema Solutioning (modelo piloto "SME = experto / DC = ejecución"). Carpeta-puntero para mantener visible la secuencia completa de 8 fases.

| | |
|---|---|
| **Rol en el ciclo** | Assessment regulatorio (CNBV banca · CNSF seguros) · gates de cumplimiento durante coexistencia |
| **Specialist** | Mainframe Modernization Regulatory |
| **Ubicación** | `Solutioning/Delivery - SME/Framework/ITSM/GRC/Specialist - Mainframe Modernization Regulatory/` |
| **Cómo se invoca** | Packet `[INVOKE]` desde el L4 (ver `../CLAUDE.md` §"Ejecución del delivery") |
| **También participa en** | Fase 8 — Decommission (retención regulatoria) |

`[INVOKE]` Disparado tras Fase 1 (Discover) con el inventario + decisión 7R por programa.

## Handoff de entrada (Discover → esta fase)

El specialist de RE entrega un spec de handoff que define exactamente qué inputs recibe esta fase y qué devuelve (notificaciones CNBV/CNSF, retención, residencia, firmas) realimentando el 7R y el wave plan:

- [`handoff-discover-to-regulatory.md`](../Fase%201%20-%20Discover/Specialist%20-%20Reverse%20Engineering/handoff-discover-to-regulatory.md) — inventario · 7R por programa · reglas reguladas · dominios `gl`/`customer` · writers del sistema de registro · lista de Retire con retención.
