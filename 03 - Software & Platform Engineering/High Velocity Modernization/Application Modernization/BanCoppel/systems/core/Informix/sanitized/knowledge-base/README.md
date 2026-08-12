# LegacyCore — Base de Conocimiento por Dominio

> **Proyecto:** LegacyCore — Application Modernization · SPE-AM-001
> **Fase:** DISCOVER Etapa 1 — Static Analysis
> **Generado:** 2026-07-03
> **Evidencia:** 12,881 archivos SQL · IBM Informix IDS 14.10 FC10W2 / POWER-AIX

## SMEs asignados

| Rol | Responsabilidad |
|-----|----------------|
| Specialist — Informix SPL Analysis | Análisis estático, extracción de código, equivalencias Informix→PostgreSQL |
| Domain Expert — LegacyCore | Validación funcional y semántica de negocio (`[SME-PENDING]`) |
| Data Architect | Modelado del esquema target (PostgreSQL / Aurora) |
| Risk Officer — Modernización | Clasificación regulatoria CNBV/Banxico, riesgos de equivalencia |

## Dominios — Índice

| ID | Dominio | Base de datos | Wave | Riesgo |
|----|---------|--------------|------|--------|
| [D01](D01-bdicnweb/) | [Canal Digital Web](D01-bdicnweb/) | `bdicnweb` | ÚLTIMO | ALTO |
| [D02](D02-bdinteg/) | [Integración y Autenticación](D02-bdinteg/) | `bdinteg` | Wave 5 | CRÍTICO |
| [D03](D03-bdicred/) | [Créditos](D03-bdicred/) | `bdicred` | Wave 4 | CRÍTICO |
| [D04](D04-bdicheq/) | [Cheques / Cuentas](D04-bdicheq/) | `bdicheq` | Wave 4 | CRÍTICO |
| [D05](D05-bdisac/) | [Saldos y Cuentas](D05-bdisac/) | `bdisac` | Wave 3 | ALTO |
| [D06](D06-bdisolic/) | [Solicitudes](D06-bdisolic/) | `bdisolic` | Wave 3 | ALTO |
| [D07](D07-bdiaclaracion/) | [Aclaraciones](D07-bdiaclaracion/) | `bdiaclaracion` | Wave 2 | ALTO |
| [D08](D08-bdispei/) | [SPEI](D08-bdispei/) | `bdispei` | Wave 2 | CRÍTICO |
| [D09](D09-bdimnsj/) | [Mensajería](D09-bdimnsj/) | `bdimnsj` | Wave 1 | BAJO |
| [D10](D10-bdisuc/) | [Sucursales](D10-bdisuc/) | `bdisuc` | Wave 3 | ALTO |
| [D11](D11-bdicobranza/) | [Cobranza](D11-bdicobranza/) | `bdicobranza` | Wave 2 | MEDIO |
| [D12](D12-bdicont/) | [Contabilidad](D12-bdicont/) | `bdicont` | Wave 4 | ALTO |

## Rubros por dominio

Cada dominio contiene los siguientes documentos:

| Archivo | Contenido |
|---------|-----------|
| `01-journey.md` | Journeys de procesos orquestados — SPs orquestadores y flujos cross-dominio |
| `02-data-catalog.md` | Catálogo de datos — tablas propias y accesos cross-DB |
| `03-data-dictionary.md` | Diccionario de datos — firmas de SPs, parámetros, tipos Informix |
| `04-business-rules.md` | Reglas de negocio — RAISE EXCEPTION, SPs de validación, invariantes |
| `05-risks.md` | Riesgos de equivalencia — MONEY, DATETIME, SERIAL, cross-DB, god procedures |
| `06-exceptions.md` | Excepciones — catálogo de códigos, ON EXCEPTION, mapeo al target |

## Estado de completitud

- **Evidencia estática (Etapa 1):** ✅ Incluida en todos los documentos
- **Validación funcional SME:** ⏳ `[SME-PENDING]` en todas las secciones semánticas
- **Schema de tablas (Etapa 2):** ⏳ Requiere conexión a instancia Informix
- **Casos de prueba (Etapa 3):** ⏳ Pendiente

---
*LegacyCore Knowledge Base · SPE-AM-001 · Accenture México Digital Core · 2026-07-03*

## Dependencias entre dominios

- [domain-dependency-matrix.md](domain-dependency-matrix.md) — Matriz completa N×N de llamadas cross-DB entre los 12 dominios
- [domain-dependency-graph.json](domain-dependency-graph.json) — Datos para grafo vis-network (nodos + aristas ponderadas)
- Cada dominio incluye `07-dependencies.md` con detalle de puentes SP-a-SP y contratos ACL requeridos
