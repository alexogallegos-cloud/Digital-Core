# BanCoppel Bank Brain — Agente Federado del Programa

> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`
> **Rol**: Inteligencia federada del programa — agrega, conecta y gobierna el conocimiento de todos los sistemas del cliente.
> **Ruta canónica**: `BanCoppel/bank-brain/`
> **Hereda**: `Application Modernization/CLAUDE.md` (Reglas B + Reglas V)

---

## QUÉ ES EL BANK-BRAIN

El `bank-brain` es el sistema de segundo orden del programa: no analiza código, sino los brains de los sistemas que sí analizan código. Su conocimiento tiene tres capas ortogonales:

| Capa | Qué contiene | `maturity` |
|------|-------------|-----------|
| **HOY** | Conocimiento verificado del AS-IS — extraído de código, logs, artefactos operativos | `live` |
| **AYER** | Historia del sistema — por qué el sistema llegó a ser lo que es (decisiones, incidentes, deuda) | `live` |
| **MAÑANA** | Escenarios, ideas, minutas, decisiones en maduración — el pipeline de transformación | `idea` · `exploring` · `decided` · `implementing` |

El campo `maturity` es la dimensión que separa estas capas **dentro del mismo brain** — sin bases de datos separadas, sin carpetas alternativas. Los queries filtran por `maturity` para obtener el corte deseado.

---

## ESTRUCTURA

```
bank-brain/
├── digital-brain/
│   ├── bank-brain.db          ← SQLite federado (gitignored)
│   ├── bank-brain.py          ← Agent API
│   └── build-bank-brain.py    ← pipeline de construcción
├── generators/                ← scripts de federación y enriquecimiento
├── knowledge-base/
│   ├── vocab/                 ← vocabulario canónico del banco (Regla V1)
│   ├── rules/                 ← reglas cross-sistema
│   ├── ontology/              ← taxonomía BanCoppel completa (ABB→SBB, BIAN)
│   └── manana/                ← documentos MAÑANA (ideas, minutas, escenarios)
├── dt/                        ← Digital Twins de programa (cross-sistema)
├── portal/                    ← vistas cross-sistema
├── source/                    ← minutas, contratos, docs del programa
└── old/                       ← archivados
```

---

## VOCABULARIO EMPRESARIAL — REGLA V1 (instancia de proyecto)

> Implementación de la Regla V1 de `Application Modernization/CLAUDE.md`.

El vocabulario canónico del banco vive en:
```
knowledge-base/vocab/vocab-bancoppel-v{N}.json
```

**Versión actual**: `v1.0` — 634 términos (fuente: Informix · 2026-08-13)
- `enterprise`: 422 términos confirmados como vocabulario del banco
- `review`: 204 términos pendientes de curaduría
- `system`: 8 términos específicos de Informix (no aplicables a otros sistemas)

### Cómo usa el vocabulario cada sistema nuevo

Cuando se incorpora un sistema nuevo al programa (Apolo, Transact, canal digital, etc.), su pipeline de extracción de vocabulario **debe**:

```python
# En {sistema}/generators/build-vocab-sistema.py
import json
from pathlib import Path

# 1. Cargar vocabulario empresarial como referencia
BANK_VOCAB = Path(__file__).parents[4] / "bank-brain/knowledge-base/vocab/vocab-bancoppel-v1.json"
enterprise_terms = {t["term"]: t for t in json.loads(BANK_VOCAB.read_text())["terms"]
                    if t["scope"] == "enterprise"}

# 2. Para cada término extraído del sistema:
#    - Si está en enterprise_terms → confirmar (misma semántica) o marcar conflicto
#    - Si no está → agregar a proposals con scope="proposed"
```

### Proceso de evolución del vocabulario

```
Sistema nuevo extrae términos
        ↓
Cruce contra vocab-bancoppel-v{N}.json
        ↓
  ┌─────────────────────────────────────┐
  │ Confirmar   Enriquecer   Proponer   │
  │ (ya existe) (nuevo ctx)  (nuevo)    │
  └─────────────────────────────────────┘
        ↓
Industry Banking SME revisa propuestos
        ↓
vocab-bancoppel-v{N+1}.json   (nueva versión)
        ↓
build-vocab-v{N+1}.py recarga bank-brain.db
```

### Poder real de la Regla V1

El vocabulario empresarial es el **Rosetta Stone** del programa. Cuando el mismo concepto aparece en distintos sistemas con distintos nombres, el vocabulario lo alinea:

| Sistema | Nombre interno | Término empresarial |
|---------|---------------|---------------------|
| Informix (SPL) | `vSaldoVigente` | `saldo` |
| Apolo (Java) | `currentBalance` | `saldo` |
| Transact (propietario) | `BAL_CURR` | `saldo` |

Sin vocabulario empresarial: tres nombres para el mismo concepto, imposible comparar reglas entre sistemas.
Con vocabulario empresarial: `business_name = "Saldo vigente"` en los tres sistemas. Los journeys, las reglas y las capacidades se vuelven comparables.

---

## CAPAS HOY / AYER / MAÑANA

### HOY — AS-IS verificado

- Fuente: brains de sistemas individuales (Informix, Apolo, etc.)
- `maturity: "live"` en todos los artefactos
- Nunca modificar directamente — se actualiza reconstruyendo el brain del sistema origen

### AYER — Historia del programa

Documentos en `source/` con `maturity: "history"`:
- Minutas de decisiones pasadas
- Post-mortems de incidentes que dieron forma al sistema
- ADRs implícitos que explican por qué el código es como es

### MAÑANA — Pipeline de transformación

Documentos en `knowledge-base/manana/` con maturity progresiva:

| Etapa | `maturity` | Descripción |
|-------|-----------|-------------|
| Idea inicial | `idea` | Observación, intuición, propuesta sin análisis |
| En exploración | `exploring` | Se está investigando — opciones, evidencia, trade-offs |
| Decidido | `decided` | Dirección elegida, no implementada aún |
| En implementación | `implementing` | SME ejecutando — Sprint activo |
| Vivo | `live` | Implementado y verificado → graduado a HOY |
| Descartado | `rejected` | Explorado y abandonado — se preserva para no repetir |

**Frontera HOY/MAÑANA**: un ítem de MAÑANA se gradúa a HOY únicamente cuando el sistema origen reconstruye su brain con el artefacto real en producción. La graduación la ejecuta `build-bank-brain.py`, no un cambio manual de campo.

---

## HANDOFFS CANÓNICOS

| Trigger | Destino |
|---------|---------|
| Conflicto de vocabulario entre sistemas | Industry Banking SME → resolución semántica |
| Término nuevo en `review` → enterprise | Industry Banking SME → curación |
| Ítem MAÑANA `decided` → `implementing` | SME técnico del sistema target |
| Capability gap detectado pre-decommission | Regla B7 → Core Banking Transformation SME |
| Término regulatorio nuevo | Regulatory SME correspondiente (Banxico · CNBV · CONSAR) |

---

## PIPELINE CANÓNICO DE REBUILD

```bash
# 1. Reconstruir vocabulario (cuando hay términos nuevos)
python generators/build-vocab-v1.py

# 2. Reconstruir bank-brain federado
python digital-brain/build-bank-brain.py

# 3. Inicializar seed brains de sistemas descubiertos
python generators/initialize-seed-brains.py

# 4. Enriquecimiento estratégico (minutas, decisiones)
python generators/extract-strategic.py
python generators/enrich-strategic.py   # requiere ANTHROPIC_API_KEY
```

---

*Última actualización: 2026-08-13 · v1.0 · Estructura canónica inicial + Regla V1 vocabulario empresarial + capas HOY/AYER/MAÑANA.*