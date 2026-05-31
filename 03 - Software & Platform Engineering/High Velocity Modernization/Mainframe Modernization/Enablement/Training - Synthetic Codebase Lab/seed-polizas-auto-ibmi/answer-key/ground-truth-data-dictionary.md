# Ground Truth — Data Dictionary · SISTEMA-POLIZAS-AUTO

| Campo | Origen | Tipo DDS | Tipo lógico | Packed | Notas |
|-------|--------|----------|-------------|:------:|-------|
| POLNUM | POLMAST | 10P 0 | ID póliza | **Sí** | PK |
| POLCLI | POLMAST | 10P 0 | FK → CLIMAST | **Sí** | join |
| POLPRIMA | POLMAST | 13P 2 | Prima anual | **Sí** | depack requerido |
| POLSUMASEG | POLMAST | 13P 2 | Suma asegurada | **Sí** | base de RN-108 |
| POLFACTOR | POLMAST | 5P 3 | Factor riesgo | **Sí** | — |
| POLTIPO | POLMAST | 2A | Cobertura | — | AM/LI/RC |
| POLESTADO | POLMAST | 2A | Estado póliza | — | VI/CA/VE/SU; base RN-108 |
| POLANIO | POLMAST | 2S 0 | Año emisión | — | **2 dígitos — ventana de siglo** |
| CLIID | CLIMAST | 10P 0 | ID cliente | **Sí** | PK |
| CLIEDAD | CLIMAST | 3S 0 | Edad conductor | — | base RN-102 |
| CLISINIEST | CLIMAST | 3S 0 | Siniestros previos | — | base RN-105/RN-106 |
| CLIESTADO | CLIMAST | 2A | Estado cliente | — | AC/BA; base RN-101 |
| TARBASE | TARIFA | 13P 2 | Prima base | **Sí** | base RN-103 |
| TARMINIMO | TARIFA | 13P 2 | Prima mínima | **Sí** | base RN-104 |
| SINMONTO | SINIEST | 13P 2 | Monto reclamado | **Sí** | — |
| SINANIO | SINIEST | 2S 0 | Año siniestro | — | **2 dígitos** |

## Campos a vigilar en migración de datos
- **Packed decimal (P):** POLNUM, POLCLI, POLPRIMA, POLSUMASEG, POLFACTOR, CLIID, TARBASE, TARMINIMO, SINMONTO → depack exacto.
- **Fechas de 2 dígitos:** POLANIO y SINANIO (+ `ANIO_CORTE INZ(26)` en RPTSIN) → ambigüedad 1926/2026.