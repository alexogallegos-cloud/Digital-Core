# Ground Truth — Catálogo de Reglas de Negocio · SISTEMA-CREDITO-LATAM

> Espeja el "Catálogo de Reglas de Negocio" (Etapa 3) del Specialist - Reverse Engineering.
> Deliberadamente alineado con RN-001…RN-005 de los ejemplos del Specialist RE.

| ID | Programa | Descripción | Tipo | Ubicación (párrafo) | Hardcoded | Ambigüedad sembrada |
|----|----------|-------------|------|---------------------|:---------:|---------------------|
| RN-001 | CREDVAL | Máximo 3 créditos activos por cliente | Límite | `3000-CUENTA-ACTIVOS` (`WS-MAX-CREDITOS VALUE 3`) | **Sí (3)** | ¿configurable por segmento? |
| RN-002 | CREDVAL | Límite disponible = 5 × saldo promedio 6 meses | Cálculo | `4000-CALCULA-LIMITE` (`WS-FACTOR-LIMITE VALUE 5`) | **Sí (5)** | ¿de dónde sale el factor 5? |
| RN-003 | CREDVAL | Créditos hipotecarios requieren validación de buró | Validación | `5000-EVALUA-RIESGO` (WHEN 'HI') | No | — |
| RN-004 | CREDVAL / SCOVAL | Score < 600 → revisión manual (PE), no rechazo | Decisión | `5000-EVALUA-RIESGO` (`WS-UMBRAL-SCORE VALUE 600`) | **Sí (600)** | ¿umbral regulatorio? |
| RN-005 | LIMCHK | Límite máximo de crédito personal = 500,000 MXN | Límite | `0000-PRINCIPAL` (`WS-LIM-PERSONAL VALUE 500000.00`) | **Sí (500000)** | ¿actualizado? |
| RN-006 | CREDVAL | El cliente debe existir y estar activo (CLI_STATUS = 'AC') | Validación | `2000-VALIDA-CLIENTE` | No | — |
| RN-007 | RPTGEN | Solo se cuentan pagos del año en curso (corte por año) | Filtro temporal | `WS-ANIO-CORTE PIC 9(02) VALUE 26` | **Sí (26)** | **año 2 dígitos: 1926 vs 2026** |
| RN-008 | CREDALT | El monto del crédito no puede ser menor a 1,000 MXN | Validación | `0000-PRINCIPAL` (`WS-MONTO-MINIMO VALUE 1000.00`) | **Sí (1000)** | ¿configurable? |

## Resumen
- **8 reglas** plantadas (coincide con `business_rules.count: 8`).
- **6 con valor hardcoded** (3, 5, 600, 500000, 26, 1000) → todas candidatas a externalizar a configuración en la arquitectura destino.
- Las reglas RN-003 y RN-004 tienen sabor regulatorio (buró de crédito / CNBV).

`[CRÍTICO]` Cada valor hardcoded es una regla de negocio congelada en el código. Un RE de calidad debe listarlos todos y proponer externalización.