# GemCog Swarm — Orquestador AS-IS
> Digital Twins para el cierre del Gemelo Cognitivo AS-IS de Banamex S500+S151 (Unisys ClearPath MCP/DMSII).

---

## Contexto del proyecto

**GemCog** es la base de conocimiento de los sistemas mainframe de Banamex:
- **S500** — Cargos y Abonos (77 COBOL P-prefix · 14 capacidades BC-XX · ~60% reglas extraídas con ALTA confianza)
- **S151** — Movimientos Contables GL (75 COBOL P-prefix · 17 capacidades BC-XX · 44 programas en BAJA/MEDIA confianza)
- **Modelo canónico**: BC-01 a BC-23 (BIAN es referencia, BC-XX es clave primaria)
- **Cobertura actual**: 783 reglas · 94.8% · 21/21 capacidades mapeadas
- **Fuentes**: `source/S500/` y `source/S151/` — archivos .txt con código COBOL, ALGOL, DASDL, WFL

**Base de artefactos activos** (MANIFEST.md es fuente de verdad):
- `capability-model-taxonomy.md` — 23 capacidades BC-XX
- `program-registry-s500.md` — 77 programas S500 → BC-XX
- `program-registry-s151.md` — 75 programas S151 → BC-XX
- `capacidades/cap-*.md` — 21 archivos de capacidad
- `rules-catalog/rules-s500-*.md` + `rules-catalog/rules-s151-*.md` — catálogo de reglas por capacidad
- `portal/knowledge-graph.html` — grafo D3.js del conocimiento

---

## Equipo de Digital Twins

| Agente | Archivo | Rol principal | Cuándo activar |
|--------|---------|---------------|----------------|
| **dt-mainframe-analyst** | `dt-mainframe-analyst.md` | Extrae reglas de COBOL/ALGOL/WFL fuente | Programas sin reglas o confianza BAJA en program-registry |
| **dt-banking-domain** | `dt-banking-domain.md` | Valida BC-XX y dominio bancario | Reglas extraídas que necesitan clasificación funcional |
| **dt-knowledge-curator** | `dt-knowledge-curator.md` | Mantiene MANIFEST, registros, grafo | Cualquier cambio a un artefacto canónico |
| **dt-qa-engineer** | `dt-qa-engineer.md` | Audita cobertura y calidad de reglas | Antes de declarar una capacidad o sistema como cerrado |

---

## Flujo de trabajo para cierre AS-IS

```
dt-mainframe-analyst          dt-banking-domain
  ↓ lee source/SXX/*.txt        ↓ valida BC-XX
  ↓ extrae ≤10 progs/lote       ↓ sube confianza BAJA→ALTA
  ↓ genera reglas schema v2     ↓
          ↓                     ↓
          └─────────────────────┘
                    ↓
            dt-qa-engineer
              ↓ audita cobertura (10 dimensiones)
              ↓ emite coverage-report
                    ↓
            dt-knowledge-curator
              ↓ actualiza rules-catalog/
              ↓ actualiza program-registry
              ↓ actualiza MANIFEST + grafo
              ↓ genera ZIP de entrega
```

---

## Definition of Done — AS-IS cerrado

- [ ] Todos los programas en `program-registry-s151.md` tienen confianza ALTA o MEDIA-documentada (descripción funcional específica, no genérica)
- [ ] `program-registry-s500.md` — sin entradas pendientes de revisión
- [ ] Cobertura de reglas ≥ 98% en todas las capacidades con programas en S500 o S151
- [ ] `MANIFEST.md` contiene únicamente artefactos AS-IS activos (sin sección TO-BE)
- [ ] `portal/knowledge-graph.html` refleja el estado final del grafo
- [ ] ZIP `gemcog-kb-YYYY-MM-DD.zip` generado y verificado (MD AS-IS + HTML portal)

---

## Convenciones obligatorias

- **IDs de regla**: `RN-{SXX}-{BCXX}-{NNN}` (ej: `RN-S151-BC05-001`)
- **Scatter-gather**: máximo 10 programas por lote de extracción
- **Schema de regla** (v2): `id · nombre · descripción · tipo · origen · bc_id · bian_ref · dataset_dmsii · confianza · estado`
- **Confianza BAJA**: siempre requiere validación dt-banking-domain antes de commit
- **No modificar**: archivos en `source/` (solo lectura), `*-LEGACY.md` (archivados)
- **No modificar**: nada en CloudFront (solo local)

---

*Creado: 2026-07-24 · Fase 1 DISCOVER · Cierre AS-IS GemCog Banamex S500+S151*
