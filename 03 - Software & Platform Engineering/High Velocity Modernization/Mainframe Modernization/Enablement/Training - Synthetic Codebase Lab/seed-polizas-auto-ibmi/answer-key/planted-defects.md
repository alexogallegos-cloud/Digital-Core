# Planted Defects · SISTEMA-POLIZAS-AUTO (IBM i / RPG)

> Lista contra la que se puntúa precision/recall en modo benchmark.

| # | Tipo | Ubicación | Detalle | Qué debe detectar |
|---|------|-----------|---------|-------------------|
| D1 | **Dead code** | `rpg/OLDPRIM.rpgle` | Programa sin CALL/CALLP entrante ni referencia en CL | Candidato a Retire |
| D2 | **Shadow inventory** | `cl/PROCNOC.clle` `CALL PGM(BCKPOL)` | BCKPOL se ejecuta pero no hay fuente | Programa fantasma: localizar fuente |
| D3 | **Hardcoded value** | `rpg/POLVAL.rpgle` `EDAD_MIN inz(18)` | RN-102: edad mínima fija | Externalizar |
| D4 | **Hardcoded value** | `rpg/POLVAL.rpgle` `MAX_SINI inz(5)` | RN-106: máximo siniestros fijo | Externalizar |
| D5 | **Hardcoded value** | `rpg/PRIMCALC.rpgle` `IVA inz(0.16)` | RN-103: IVA 16% fijo | Externalizar (tasa fiscal) |
| D6 | **Hardcoded value** | `rpg/RIESGOEV.rpgle` `UMBRAL inz(500)` + `* 1.500` | RN-105: umbral de score y recargo fijos | Externalizar |
| D7 | **Dynamic CALL** | `rpg/RIESGOEV.rpgle` `extpgm(wProgScore)` | Target ('SCOREXT') en runtime | No resoluble por análisis estático → `[AMBIGUO]` |
| D8 | **2-digit date** | `dds/POLMAST.pf` POLANIO; `dds/SINIEST.pf` SINANIO; `rpg/RPTSIN.rpg` `ANIO_CORTE inz(26)` | Años de 2 dígitos | Ventana de siglo 1926/2026 |
| D9 | **Packed decimal** | DDS: POLPRIMA, POLSUMASEG, POLFACTOR, TARBASE, TARMINIMO, SINMONTO, POLNUM, POLCLI, CLIID | 9 campos packed | Depack exacto en migración |
| D10 | **Indicator logic** | `rpg/RPTSIN.rpg` `*IN50` (EOF) / `*IN60` (año en curso) | Flujo controlado por indicadores booleanos globales | Mapear indicadores antes de refactorizar (riesgo RPG clásico) |
| D11 | **Logical File business logic** | `dds/POLACT.lf` SELECT/OMIT | RN-108: "póliza activa" definida en el LF, no en código | Cazar lógica escondida en SELECT/OMIT |
| D12 | **RPG fixed vs free mix** | `rpg/RPTSIN.rpg` (fixed) vs resto (free) | Mezcla de dialectos en el mismo sistema | Estrategia de transpilación distinta por dialecto |

## Conteo para benchmark
- Dead code: **1** · Shadow inventory: **1** · Hardcoded: **4** · Dynamic call: **1**
- 2-digit date: **2 campos + 1 const** · Packed: **9** · Indicator logic: **1 programa** · LF business logic: **1**

## Cómo puntuar
Correr RE o una herramienta sobre `source/` (sin este archivo) y comparar contra D1–D12.
Los reveladores más duros de este seed: **D11 (lógica en el Logical File)** y **D10 (indicadores)** —
ambos son riesgos específicos de IBM i que una herramienta z/OS-only no caza.