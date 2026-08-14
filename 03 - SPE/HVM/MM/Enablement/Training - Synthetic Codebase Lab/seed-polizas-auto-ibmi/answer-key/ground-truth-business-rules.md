# Ground Truth — Catálogo de Reglas de Negocio · SISTEMA-POLIZAS-AUTO

| ID | Programa | Descripción | Tipo | Ubicación | Hardcoded | Ambigüedad |
|----|----------|-------------|------|-----------|:---------:|------------|
| RN-101 | POLVAL | El cliente debe existir y estar activo (CLIESTADO='AC') | Validación | CHAIN CLIMAST + check estado | No | — |
| RN-102 | POLVAL | Edad mínima del conductor = 18 | Validación | `EDAD_MIN inz(18)` | **Sí (18)** | ¿regulatorio CNSF? |
| RN-103 | PRIMCALC | Prima = base × factor × (1 + IVA); IVA = 16% | Cálculo | `IVA inz(0.16)` | **Sí (0.16)** | tasa fiscal — externalizar |
| RN-104 | PRIMCALC | La prima no puede ser menor a la prima mínima de tarifa | Límite | `if outPrima < TARMINIMO` | No | — |
| RN-105 | RIESGOEV | Si score externo < 500 → recargo de factor 1.5× | Decisión | `UMBRAL inz(500)` + `* 1.500` | **Sí (500 / 1.5)** | ¿umbral del buró? |
| RN-106 | POLVAL | Rechazo automático si siniestros previos > 5 | Límite | `MAX_SINI inz(5)` | **Sí (5)** | ¿configurable? |
| RN-107 | RPTSIN | Reporte sólo de siniestros del año en curso (corte por año) | Filtro temporal | `ANIO_CORTE inz(26)` | **Sí (26)** | **año 2 dígitos: 1926/2026** |
| RN-108 | POLACT (LF) | "Póliza activa" = estado VI **y** suma asegurada > 0 | Filtro/dominio | DDS POLACT (SELECT/OMIT) | — | **regla escondida en el Logical File** |

## Resumen
- **8 reglas** (coincide con `business_rules.count: 8`).
- **6 con valor hardcoded** (18, 0.16, 500/1.5, 5, 26) → externalizar a configuración.
- `[AS400]` RN-108 vive en el **Logical File**, no en código RPG — el riesgo clásico de IBM i: lógica de negocio embebida en SELECT/OMIT de LFs que se pierde si sólo se analizan los programas.
- RN-102 y RN-105 tienen sabor regulatorio (CNSF / scoring de riesgo).