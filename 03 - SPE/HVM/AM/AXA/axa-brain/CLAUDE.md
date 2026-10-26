# axa-brain — Cerebro Federado AXA México
> Agente de segundo orden: agrega y razona sobre los brains de cada sistema.
> No lee código fuente directamente. Para análisis de un sistema específico, ve al CLAUDE.md del sistema.

---

## ROL DE ESTE AGENTE

Soy el **Cerebro Federado** de AXA México. Mi responsabilidad es:

1. **Agregar** el conocimiento de los system-level brains vía SQLite `ATTACH`
2. **Mantener** el vocabulario empresarial canónico (Rosetta Stone AXA)
3. **Razonar** sobre el landscape tecnológico completo: dependencias cross-sistema, duplicidades, gaps
4. **Proponer** escenarios de cambio (capa MAÑANA) y alternativas de transformación

Para analizar código fuente o reglas de un sistema específico: `../systems/{categoría}/{sistema}/CLAUDE.md`.

---

## CAPAS DE CONOCIMIENTO

Cada registro en `axa-brain.db` tiene un campo `maturity`:

| Maturity | Capa | Descripción |
|----------|------|-------------|
| `HOY` | Estado actual | AS-IS verificado, lo que opera hoy en producción |
| `AYER` | Historia | Por qué las cosas son como son, decisiones pasadas |
| `MAÑANA` | Pipeline | `idea → exploring → decided → implementing → live → rejected` |

---

## VOCABULARIO EMPRESARIAL — ROSETTA STONE

Archivo: `knowledge-base/vocab/vocab-axa-v1.json`

El vocabulario es el **Rosetta Stone** cross-sistema: mapea el mismo concepto de negocio a sus
representaciones en cada sistema tecnológico. Toda extracción de código en un system-brain debe
cruzar con este vocabulario.

Estructura de entrada:
```json
{
  "term": "Prima neta",
  "domain": "finanzas",
  "scope": "enterprise",
  "en": "net_premium",
  "etb_capability": "Premium Management",
  "systems": {
    "policy-admin": "NET_PREM",
    "billing": "net_premium_amount",
    "datawarehouse": "DIM_PRIMA.NET_PREMIUM",
    "reporting-cnsf": "PRIMA_NETA"
  }
}
```

---

## REGISTRO CANÓNICO DE SISTEMAS

El inventario de sistemas **no se edita a mano en ningún CLAUDE.md**. Vive en:

```
knowledge-base/landscape/landscape-axa-v2.json
```

Lo genera `generators/build-landscape-v2.py`, que es también quien carga en `axa-brain.db`
las tablas `systems`, `components` y `cross_dependencies`, y quien migra los slugs v1.0 que
quedaron referenciados en `process_steps`.

Estado actual: **88 sistemas**, **36 componentes**, **53 dependencias cross-sistema**.

Cada sistema lleva un campo `source` con su procedencia:

| Código | Fuente |
|--------|--------|
| `TOGAF-pN` | `source/arquitectura_TOGAF_accenture_v19.pdf`, página N |
| `DISCOVERY` | Excel de Competitive Discovery de Suscripción Daños |
| `CLAUDE-2.0` | Tabla de landscape heredada de la v2.0 del CLAUDE.md de AXA |

Las dependencias tienen dos orígenes distintos y conviene no mezclarlos al razonar:

- **39 declaradas** en el TOGAF, con cita de página en el campo `evidence`. Son integraciones
  de sistema a sistema documentadas por arquitectura.
- **14 derivadas** de la coocurrencia de sistemas en los pasos del Discovery. No son
  integraciones técnicas: son handoffs manuales observados en el proceso real de suscripción.
  Su `dependency_type` es `manual-handoff` y por eso son interesantes, no ruido.

`build-axa-brain.py` lee este registro y hace `ATTACH` de los system brains que existan en
`../systems/{categoría}/{slug}/digital-brain/brain.db`. Hoy ninguno existe todavía: los
system-level brains se construyen cuando se cargue código fuente o documentación por sistema.

---

## PORTAFOLIO 2027 — EJE CHANGE

Fuente: `source/Roles Description_Team 2027 portfolio.xlsx`.
Generador: `generators/load-portfolio-2027.py`.

Trece iniciativas de transformación de infraestructura y deuda técnica, todas en estado
"Discovery no iniciado", más los ocho roles del equipo objetivo. Es un eje distinto al de
negocio: donde el Discovery de Suscripción mira el escritorio del suscriptor, el portafolio
mira la salida de entornos obsoletos.

| Tabla | Contenido |
|-------|-----------|
| `initiatives` | 13 iniciativas con contexto, siguientes pasos y horizonte |
| `initiative_systems` | 15 cruces hacia el landscape, con relación y evidencia |
| `initiative_dependencies` | 8 dependencias entre iniciativas declaradas en la fuente |
| `portfolio_roles` | 8 roles con actividades y perfil técnico |

Relación de un cruce: `decommission`, `migrate-to`, `remediate`, `stabilize` o `depends-on`.

**Confidencialidad.** Las columnas `responsable_axa`, `opp_acn` y `winability` son de uso
interno. Los nombres de personas del cliente no salen a portales ni entregables, y el scoring
comercial es pipeline, cuyo dueño es `Solutioning/`, no Digital Core.

---

## DIMENSIÓN DE HOSTING

Generador: `generators/load-hosting-zones.py`.

Responde dónde vive cada sistema, que es la pregunta que condiciona Exit Run Off Zone. Un
sistema puede ocupar varias zonas según el ambiente, así que es una tabla de relación y no una
columna de `systems`. El caso testigo es Datapower: producción en la Run Off Zone y los
ambientes de desarrollo y QA en MPI.

Nueve zonas: `roz` (objetivo de salida antes del Q4 2028), `pod`, `mpi`, `core-it`, `azure`,
`nube-privada`, `saas`, `externo` y `endpoint`.

Cada asignación lleva un campo `confidence`:

- `evidenced`: la fuente dice explícitamente dónde vive el sistema.
- `inferred`: no lo dice, pero la naturaleza del producto no deja alternativa razonable, como
  un SaaS de mercado. Se marca aparte para poder filtrarlo y validarlo con el cliente.

Lo que no cae en ninguna de las dos **no se registra**. Queda como brecha y sale en el reporte
de cobertura, que hoy es de 26 sistemas con zona frente a 62 pendientes de dato.

```bash
python generators/load-hosting-zones.py --roz   # inventario de la Run Off Zone
```

---

## DIGITAL TWINS — NIVEL FEDERADO (cross-sistema)

| Digital Twin | Pregunta que responde |
|-------------|----------------------|
| `dt-policy-lifecycle/` | ¿Qué sistemas tocan una póliza desde cotización hasta cancelación? |
| `dt-claims-lifecycle/` | ¿Qué sistemas intervienen de FNOL a cierre del siniestro? |
| `dt-underwriting-intelligence/` | ¿Cómo se toma la decisión de suscripción y en qué sistemas vive? |
| `dt-distribution-network/` | ¿Cómo fluye la venta de un agente/corredor a la póliza emitida? |
| `dt-reinsurance-program/` | ¿Cómo se calcula y registra la cesión de reaseguro cross-sistema? |
| `dt-regulatory-solvency/` | ¿Qué sistemas alimentan el cálculo de reservas técnicas para CNSF? |
| `dt-financial-reporting/` | ¿Cómo se consolida el resultado técnico y se reporta internamente y al regulador? |
| `dt-inteligencia-mercado/` | ¿Cuál es el contexto competitivo, regulatorio y de crecimiento del mercado asegurador? |

---

## PIPELINE DE RECONSTRUCCIÓN

```bash
# Desde AXA/axa-brain/
python build-axa-brain.py          # reconstruye axa-brain.db desde todos los system brains
python axa-brain.py "prima neta"   # query de prueba
python axa-brain.py systems        # lista sistemas registrados
```

---

## GENERATORS — PIPELINE DE FEDERACIÓN

| Script | Propósito |
|--------|-----------|
| `build-axa-brain.py` | ETL principal: ATTACH + agregación |
| `build-vocab-v1.py` | Construye vocab-axa-v1.json (Rosetta Stone) |
| `enrich-strategic.py` | Enriquece con perspectiva estratégica (ETB capabilities) |
| `extract-strategic.py` | Extrae capacidades desde ETB Insurance P&C |

---

*Última actualización: 2026-10-19 · v2.0 · El registro de sistemas pasa a `landscape-axa-v2.json`. El brain deja de ser un scaffold de 16 sistemas y pasa a 88 sistemas con componentes y dependencias cross-sistema trazables a fuente.*