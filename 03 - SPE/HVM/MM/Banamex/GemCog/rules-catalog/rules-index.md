# Catálogo de Reglas — Banamex S151 + S500
> Proyecto: Banamex GemCog · Gemelo Cognitivo Capa 2 (Reglas de Negocio)
> Sistema: Unisys ClearPath MCP · COBOL/ALGOL/DASDL
> Última actualización: 2026-07-16 — BC-04 completado (L002R3+L002R4+L002R5)

---

## Totales

| Sistema | Archivos | Reglas |
|---------|----------|--------|
| S500 | 4 | 182 |
| S151 | 16 | 644 |
| **Total** | **20** | **826** |

> ⚠️ `rules-s151-p109-vocab-enrichment.md` — declarado en versión anterior, **no existe en disco**. Pendiente de crear (cubrirá mismos RN-S151-021..060 con capa de vocabulario enriquecido).
> ⚠️ `rules-s151-p112.md` — contiene RN-S151-001..020 como **referencia cruzada** de `rules-s151.md` sección P112 (mismo rango de IDs — verificar si las reglas son equivalentes o complementarias).

---

## S500 — Cargos / Abonos

| Archivo | Programas | Proceso | Reglas | IDs | Estado |
|---------|-----------|---------|--------|-----|--------|
| rules-s500.md | P103 · P100 · P075 · P655 · S500P630 · S151/L002R2 · S151/P130 · S151/P015 | BATCH/MIXED/ONLINE | 78 | RN-S500-001..078 | ✅ completo — incluye 23 reglas S151 críticas del portal (⚠️ namespace S500) |
| rules-s500-p130.md | S500/P130 · WFL LINEA | BATCH/ONLINE | 29 | RN-S500-079..107 | ✅ extraído |
| rules-s500-p020-p142-p144.md | P020 · P142 · P144 | BATCH | 45 | RN-S500-108..152 | ✅ extraído |
| rules-s500-s151registra-p103fraude.md | S151REGISTRA · P103 S500 (FraudLink) | MIXED | 30 | RN-S500-153..182 | ✅ extraído |

> Hueco en secuencia S500: RN-S500-056..078 (23 reglas de programas S151 críticos) están en `rules-s500.md`, no en un archivo S151. Considerar migrar a `rules-s151.md` con IDs S151 propios en una iteración futura.

---

## S151 — Movimientos Contables GL

| Archivo | Programas | Reglas | IDs | Estado |
|---------|-----------|--------|-----|--------|
| rules-s151-p112.md | P112 — Punteo por claves | 20 | RN-S151-001..020 | ⚠️ referencia cruzada — verificar equivalencia vs rules-s151.md sección P112 |
| rules-s151.md | P109 — GL Posting Engine | 40 | RN-S151-021..060 | ✅ completo |
| rules-s151-p130-p131.md | P130 Agrupador · P131 Traductor CFR→CNBV | 42 | RN-S151-061..080 · 091..112 | ✅ migrado + enriquecido |
| rules-s151-p108-p150.md | P108 GL Bitácora · P150 Reportes CITI | 60 | RN-S151-121..180 | ✅ completo |
| rules-s151-p021-p120.md | P021 (ALGOL) · P120 Concentrador | 24 | RN-S151-181..185 · 201..207 · 221..232 | ✅ con vocab |
| rules-s151-p010.md | P010 — Gateway online MOVIMIENTOS | 32 | RN-S151-241..272 | ✅ con vocab |
| rules-s151-p050-p052.md | P050 CONCENTRACIÓN DE SALDOS · P052 ACCIVAL (Holdings) | 40 | RN-S151-281..300 · 311..330 | ✅ con vocab |
| rules-s151-p151.md | P151 — Transformador IBM-Citibank ALR/AHR/OCM | 30 | RN-S151-331..360 | ✅ extraído |
| rules-s151-p158.md | P158 — Movimientos por contrato | 30 | RN-S151-361..390 | ✅ extraído |
| rules-s151-p178-p138.md | P178 Verificación Saldos · P138 Posición Global | 20 | RN-S151-391..400 · 411..420 | ✅ con vocab |
| rules-s151-p199-p600.md | P199 · P610 · P612 · P677 | 70 | RN-S151-421..490 | ✅ con vocab |
| rules-s151-dasdl.md | DASDL BD10 · BD13 · BD99 · BD02 | 35 | RN-S151-491..525 | ✅ con vocab |
| rules-s151-l030.md | L030 — Librería contable batch | 25 | RN-S151-526..550 | ✅ extraído |
| rules-s151-p602-p606-p620-p630.md | P602 · P606 · P620 · P630 | 40 | RN-S151-551..590 | ✅ extraído |
| rules-s151-p655-p670-p671-p680-p690.md | P655 · P670 · P671 · P680 · P690 | 42 | RN-S151-591..632 | ✅ extraído |
| rules-s151-l002r3-r4-r5.md | L002R3 · L002R4 · L002R5 — ACL GL Interface multi-canal (ALGOL) | 57 | RN-S151-633..659 · 660..674 · 675..689 | ✅ BC-04 completo |
| rules-s151-p312-p330-p360.md | P312 Saldos S084 · P330 Extracción DMSII · P360 Integración DMSII | 37 | RN-S151-710..718 · 720..732 · 735..749 | ✅ BC-09 completo |

> Gaps de numeración S151 (82+8+20=110 IDs sin asignar): 081..090 · 113..120 · 186..200 · 208..220 · 233..240 · 273..280 · 301..310 · 401..410 · 690..709 (reserva BC-04) · 719 · 733..734. Son espacios de reserva entre programas — no hay reglas faltantes.

> **Próximos bloques disponibles:** reserva BC-04 = 690..709 · más allá de BC-09 = 750+

---

## Fuente canónica visual

Las 78 reglas críticas validadas línea por línea en formato interactivo con filtros Dominio · Proceso · Tipo · Regulatorio:

→ GemCog/portal/rules-report-gemcog.html
→ CloudFront: https://dldpl3f6co76b.cloudfront.net/banamex/portal/rules-report-gemcog.html
