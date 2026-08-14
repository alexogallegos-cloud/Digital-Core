# Banamex — Modernización Mainframe Unisys ClearPath
> Proyecto activo · Digital Core · Offering 03 S&PE · Sub-Offering: High Velocity Modernization · Solution: Mainframe Modernization
> Fase SDLC actual: **DISCOVER — ETAPA 0 (Setup & Inventory)**
> Fecha de inicio: 2026-06-30
> Indexado: ✅ 2026-07-17 — README del proyecto/componente (contexto de conocimiento)

---

## Componentes en este Proyecto

| Component ID | Sistema | Función | Spec | Fase Actual |
|---|---|---|---|---|
| `SPE-MM-001` | **S500** — Cargos y Abonos de Cuentas de Cheque | Sistema transaccional OLTP + batch para débitos y créditos en cuentas de cheque | [S500/spec-spe-mm-s500.md](S500/spec-spe-mm-s500.md) | DISCOVER — ETAPA 0 |
| `SPE-MM-002` | **S151** — Movimientos Contables | Libro mayor (general ledger) — convierte cargos/abonos en asientos contables CNBV | [S151/spec-spe-mm-s151.md](S151/spec-spe-mm-s151.md) | DISCOVER — ETAPA 0 |

**Dependencia crítica**: S151 consume los movimientos que produce S500. La secuencia de modernización es S500 primero; S151 después (en DESIGN y BUILD). El DISCOVER puede correr en paralelo.

---

## Estado Actual — ETAPA 0

La ETAPA 0 del Specialist - Reverse Engineering requiere el código fuente de ambos sistemas.

### Próximos pasos inmediatos

```
1. Cargar código fuente de S500 en:
   Banamex/S500/source/
   (Archivos: .cob, .alg, .wfl, .dasdl, .cpy)

2. Cargar código fuente de S151 en:
   Banamex/S151/source/
   (Archivos: .cob, .alg, .wfl, .dasdl, .cpy)

3. Activar Specialist - Reverse Engineering (Fase 1 - Discover) con el código cargado.
   Ruta del specialist: ../Fase 1 - Discover/Specialist - Reverse Engineering/

4. Completar el checklist §07 de cada spec con el inventario resultante.
```

### Checklist de ETAPA 0 — Estado Consolidado

| Ítem | S500 | S151 |
|---|---|---|
| Código fuente cargado en `source/` | ☐ | ☐ |
| Inventario maestro completo (LOC, programas, jobs) | ☐ | ☐ |
| DASDL schema del DMSII recibido | ☐ | ☐ |
| Logs de ejecución (30+ días) disponibles | ☐ | ☐ |
| SME técnico Banamex asignado | ☐ | ☐ |
| Ambiente de análisis provisionado | ☐ | ☐ |

---

## Equipo y Contactos

| Rol | Nombre | Organización | Estado |
|---|---|---|---|
| Lead Architect | Por designar | Accenture MX | ☐ |
| Sponsor Técnico Banamex | Por designar | Banamex Technology | ☐ |
| SME Técnico S500 | Por designar | Banamex Technology | ☐ |
| SME Técnico S151 | Por designar | Banamex Technology | ☐ |
| SME Contabilidad | Por designar | Banamex Finance | ☐ |
| SME Unisys Banking | Por designar | Solutioning/Platform/Unisys | ☐ |
| Program Manager | Por designar | Accenture MX | ☐ |

---

## Links del Ecosistema

| Recurso | Ruta |
|---|---|
| Specialist - Reverse Engineering | [../Fase 1 - Discover/Specialist - Reverse Engineering/](../Fase%201%20-%20Discover/Specialist%20-%20Reverse%20Engineering/) |
| Specialist - Static Analysis Tooling | [../Fase 1 - Discover/Specialist - Static Analysis Tooling/](../Fase%201%20-%20Discover/Specialist%20-%20Static%20Analysis%20Tooling/) |
| Mainframe Modernization L4 CLAUDE.md | [../CLAUDE.md](../CLAUDE.md) |
| HVM Sub-Offering CLAUDE.md | [../../CLAUDE.md](../../CLAUDE.md) |