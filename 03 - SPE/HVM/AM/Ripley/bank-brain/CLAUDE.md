# bank-brain — Cerebro Empresarial de Banco Ripley Chile

> Brain de nivel cliente. Agente de segundo orden: agrega y razona sobre el negocio del banco y sobre los brains de sistema cuando existan.
> Hereda el asset `00 - Enterprise Brain/` y sus 45 reglas de canon. Hereda también el `CLAUDE.md` de `03 - SPE/HVM/AM/`.

---

## Definición del brain

Citando al asset, sin parafrasear: *el Enterprise Digital Brain es el gemelo cognitivo de una empresa. Es un motor de razonamiento que entiende cómo funciona el negocio y la tecnología que lo habilita, y con ese entendimiento explica, anticipa y aconseja.*

Este brain no es una memoria ni un repositorio de documentos sobre Banco Ripley. El conocimiento que guarda es la evidencia con la que razona, y hoy esa evidencia es escasa y pública. Decirlo es parte de lo que el brain hace.

---

## Declaración canónica

| Campo de `system_info` | Valor | Regla |
|------------------------|-------|-------|
| `slug` | `ripley-bank-brain` | — |
| `brain_name` | `bank-brain` | B18 |
| `brain_type` | `enterprise` | B14 |
| `hemisphere` | `change` y `run` | B13 |
| `industry` | `banca` | ADR-EB-007 |
| `industry_sme` | `SME/Industry/Industry Banking/` | B19 |
| `itom_sme` | `SME/Framework/IT Operating Model/` | B23 |
| `capability_model` | Accenture Logical Operating Model for Banking, Digital Bank 4.0 | B2 |
| `source_of_truth` | Registros públicos: CMF, Bolsa de Santiago, memorias de Ripley Corp | B31 |
| `status` | `discovered` | §20 |
| `version` | `0.1.0` | §17 |
| `build_agent` | Enjambre de 23 Digital Twins canónicos | B29 |

La extensión que corresponde a `brain_type = enterprise` es `federated_brains`, `documents` y `processes`, exactamente una y no más (Regla B15). Las tablas del CORE son las 19 del schema canónico y el DDL vive en `00 - Enterprise Brain/templates/schema.sql`, que es la única fuente de verdad (ADR-EB-006).

---

## Ontología declarada

| Binding | Tipo | Estado |
|---------|------|--------|
| Digital Bank 4.0, 28 L1 en tres agrupaciones L0 | `etb` | Disponible en el asset |
| IT Operating Model v9.0, 38 procesos en 6 dominios | `it-capability` | Disponible en el SME |
| Cadena de valor de retail, solo para el canal tienda | `value-chain` | Disponible en el asset |
| BIAN Service Landscape v14 | `bian` | Disponible, aplicable cuando haya sistemas |
| Marco regulatorio chileno | `regulatory` | **Hueco abierto.** No existe en el Industry SME |

El último binding es la brecha bloqueante del análisis. Está escrito en `knowledge_gaps` con destinatario y acción de resolución, y no se rellena con la capa mexicana bajo ninguna circunstancia.

---

## Metodología activa

El método que gobierna la construcción de este brain es el de nivel empresa, que el asset no publica todavía y que aquí se escribió por primera vez:

[`knowledge-base/methodology/metodologia-analisis-situacion.md`](knowledge-base/methodology/metodologia-analisis-situacion.md)

Cinco rondas, con los 23 Digital Twins canónicos repartidos entre ellas, y una capa transversal de ingeniería que corre durante las cinco. Las cuatro etapas del asset, Lenguaje, Almas, Biografía e Intención, no aplican en este nivel: aplican por sistema, cuando haya código fuente, y cada sistema abrirá su propio brain de tipo `system` bajo `../systems/`.

---

## El enjambre: 23 Digital Twins en tres categorías

| Categoría | Cuántos | Razonan sobre | Se miden contra |
|-----------|---------|---------------|-----------------|
| A, rol de TI | 10 | La organización de TI del banco | Los 38 procesos del IT Operating Model v9.0 |
| B, ingeniería del brain | 5 | El brain como producto | El Brain Lifecycle y las reglas de pipeline P1 a P5 |
| C, negocio | 8 | El modelo de negocio del banco | Los 6 dominios L1 comunes a los catálogos de industria |

La cobertura es artefacto verificable: un proceso del modelo operativo sin Digital Twin dueño es hallazgo bloqueante del Brain Auditor. El reparto canónico vive en `00 - Enterprise Brain/dt/cobertura-dt.md` y este brain lo hereda sin modificarlo.

Los `CLAUDE.md` de cada Digital Twin van en `dt/`, en minúsculas y sin excepción. Al 2026-10-27 están pendientes de generar: es el primer acto de las rondas R1 y R2.

---

## Pipeline

Reglas P1 y P2 sin excepción. Ningún dato entra a `bank-brain.db` sin el parser o el conector capaz de recrearlo desde la fuente original.

```
source/docs  →  knowledge-base/  →  digital-brain/bank-brain.db  →  portal/
  (PDFs CMF,     (corpus curado)     (SQLite, gitignored)          (generado)
   memorias,
   estados
   financieros)
```

Un PDF de la CMF se procesa con un parser versionado en `generators/`, no se transcribe a mano. El portal se genera siempre desde la base, nunca se escribe a mano (Regla P4). La base nunca se commitea (Regla P5, ya en `.gitignore`).

---

## Confidencialidad

Rige la Regla B42 con negado por defecto. Tres fronteras:

La de cliente es absoluta. Nada del conocimiento de Banco Ripley cruza al brain de otro cliente del estate, y lo único que sube al Industry SME es el patrón anonimizado, nunca el caso. Esto importa particularmente aquí: BanCoppel y Coppel son el análogo mexicano más cercano a este modelo de negocio y la tentación de cruzar datos entre ambos es real. No se cruza.

La de tercero aplica cuando en el ambiente del banco convivan proveedores que no son el banco. Los hallazgos van al banco y el banco decide qué comparte.

La interna aplica cuando haya stakeholders con `concern` distinto. Toda autorización es del par solicitante y propósito, y el propósito queda registrado en el linaje.

---

## Estado al 2026-10-27 — R0 cerrada

| Artefacto | Estado |
|-----------|--------|
| Estructura canónica de carpetas | Creada |
| Metodología de nivel empresa | Escrita, versión 1.0 |
| `bank-brain.db` | **Construida.** 33 afirmaciones con linaje sobre 6 tablas |
| `build-bank-brain.py` | **Operativo.** Idempotente, con `--dry-run` y `--validate` |
| `bank-brain.py` con la interfaz de 5 métodos | **Operativo.** Los 5 responden; `search()` cubre el corpus documental |
| `source_catalog` | 13 fuentes, 2 ausentes |
| `knowledge_gaps` | 10 abiertos, 1 bloqueante (GAP-RIP-001) |
| `ontology_bindings` | 5 filas, una primaria |
| Estudio histórico (Regla B26) | Línea de tiempo con 12 hitos fechados |
| Seed emitido | `seeds/car-sa-seed.json` (Regla B11) |
| `dt/` con los 23 Digital Twins | Vacío. Primer acto de R1 y R2 |
| Portal | No existe todavía |
| Capa regulatoria Chile | Hueco abierto, bloqueante |

Estado del path-to-production: **LOCAL**. La base existe y responde, pero no se comparte ni se activa: eso exige el Brain Auditor en PASS y los DoD-EB-01 a 05, que R0 no pretende cumplir.

### Resultado del Brain Auditor en R0

PASS en D1, D2, D6 y D9. No aplica en D3, D4, D5 y D8, que miden reglas y puente, inexistentes en un brain enterprise recién encuadrado. **FAIL en D7**, y es estructural y esperado: la Regla B22 exige que todo conocimiento ate a un proceso de negocio, los 10 huecos no tienen `process_id`, y no pueden tenerlo porque la tabla `processes` se puebla en R1 y su contenido depende justamente de GAP-RIP-001. La circularidad se rompe en R1, no antes.

El FAIL queda registrado y no se maquilla. Asignar un `process_id` a un proceso inexistente sería peor que el hallazgo.

### Las dos vistas del tablero de niveles

El Brain Auditor mide en D9 la columna `tier` de las tablas de conocimiento. Ni `source_catalog` ni `knowledge_gaps` tienen esa columna en el canon, así que 23 de las 24 filas de contenido de este brain le son invisibles y D9 reporta gold en 0%. La vista por linaje, que sí cubre toda afirmación cargada, da silver 32 y gold 1. Las dos cifras son correctas y miden cosas distintas; `build-bank-brain.py` las imprime por separado a propósito.

---

*Creado 2026-10-27, versión 0.1.0. Instanciado desde la semilla del asset Enterprise Brain, Digital Core, Accenture México.*
