# Gemelo Cognitivo del Sistema
### *Cognitive Digital Twin* — método HVM-wide de comprensión de legacy para modernización

> **Qué es:** un método para destilar la inteligencia acumulada de un sistema legacy —su lenguaje, sus autores y su evolución— en un **modelo vivo y consultable** que sobrevive al sistema original y guía su modernización.
>
> **Alcance:** activo **HVM-wide**, reutilizable por **Application Modernization** (Informix, Oracle Forms, SQL Server) y **Mainframe Modernization** (COBOL, ALGOL, PL/I). Independiente de la tecnología: *lo que se destila es constante; de dónde se extrae cambia por tecnología*.
>
> **Nivel:** ★ Digital Core · S&PE · HVM (L3) · aplica en fase **DISCOVER**, se proyecta a todo el SDLC.

---

## 0 · Principio de reutilización — *método vs. mecánica*

La confusión más costosa es tratar cada engagement de legacy como si fuera nuevo. No lo es. El **90% del valor es el método** (qué destilar, por qué, con qué honestidad) y es idéntico para un core Informix, un mainframe COBOL o un Oracle Forms. Solo el **10% —la mecánica de extracción— es específico de la tecnología**.

```
   LEGACY (varía)                EXTRACTOR (1 por tecnología)         RENDERER COGNITIVO (constante)
 ┌──────────────────┐          ┌───────────────────────────┐       ┌──────────────────────────────┐
 │ Informix SPL      │          │ lee el catálogo / fuentes │       │ vocabulario + dedup canónico   │
 │ COBOL / z-OS      │  ──────▶ │ y emite el                │ ────▶ │ Mapa de las Almas              │
 │ Oracle Forms/PLSQL│          │ JSON NORMALIZADO           │       │ Biografía / evolución          │
 │ SQL Server T-SQL  │          │ (contrato §7)              │       │ Intención (journeys/reglas)    │
 └──────────────────┘          └───────────────────────────┘       │ portal + marca del cliente     │
                                                                     └──────────────────────────────┘
```

Un engagement nuevo **no reescribe el método ni el renderer** — solo elige (o construye) el extractor de su tecnología y hace *swap* de cuatro insumos del cliente: **source code · knowledge base del cliente · paleta de marca · semilla del vocabulario (CAT)**.

---

## 1 · El principio (por qué mira al futuro)

La ingeniería inversa clásica *desentierra el pasado*. El Gemelo Cognitivo hace lo contrario: **convierte el legacy en la semilla del sistema del futuro**. El código deja de ser un lastre a descifrar y se vuelve un activo que:

1. **Preserva la memoria institucional** — cuando las personas que escribieron el core ya no están y el sistema se apaga (decommission), su conocimiento no muere: queda capturado en un modelo consultable.
2. **Siembra la modernización AI-assisted** — el lenguaje, las reglas y la intención recuperados son la *especificación y el material de contexto* para los agentes/SMEs que construyen el target.
3. **Predice el riesgo** — de equivalencia funcional, de concentración de conocimiento (*bus factor*), de acoplamiento — **antes** de tocar una línea.

> El gemelo es **cognitivo** (no solo estructural): modela no únicamente *qué hace* el sistema, sino *qué idioma habla, quién lo pensó y cómo maduró su intención*.

---

## 2 · Fundamento de mercado

No es una metáfora aislada: cada capa se apoya en una disciplina establecida — y todas son independientes de la tecnología del legacy.

| Capa del gemelo | Disciplina | Referencia |
|-----------------|------------|------------|
| Lenguaje | **Software Linguistics / Source-Code Lexicon** + *Ubiquitous Language* (DDD) | Normalizing Source Code Vocabulary (ICSE'13); Eric Evans, *DDD* |
| Almas | **Code Stylometry / Authorship Attribution** + Software Forensics | Caliskan et al., *De-anonymizing Programmers via Code Stylometry* (USENIX'15) |
| Biografía | **Mining Software Repositories** + **Behavioral Code Analysis** | Adam Tornhill, *Your Code as a Crime Scene* / CodeScene |
| Intención | **Program Comprehension / Concept Location** | ICPC; *Software Archaeology* (Harry Sneed, 1994) |

> **Linaje honesto:** la *técnica* subyacente (software archaeology, análisis conductual) normalmente requiere **historia de Git**. En la mayoría de los cores legacy **no la hay** — por eso el gemelo se reconstruye de *vestigios*: headers de comentarios (autor/fecha/proyecto/ticket) + estilo de nombrado. El resultado es un gemelo **probabilístico y declarado por fuente**, no un registro completo. La cobertura de esos vestigios **varía por tecnología** (ver §6).

---

## 3 · Las ocho capas del Gemelo

Ocho capas en dos mitades: **1–4 entienden** el sistema tal como es (AS-IS) y dan nacimiento al gemelo; **5–8 lo proyectan** al futuro (TO-BE) y lo mantienen vivo. La *destilación* de cada capa —el "qué" y el "por qué"— es constante entre tecnologías; la *extracción* se adapta (§4).

### Capas 1–4 · Entender el sistema (AS-IS) — *el gemelo nace*

Del lenguaje a la intención. **El lenguaje primero.**

**Capa 1 · Lenguaje — *el idioma del gemelo.*** El vocabulario del negocio fosilizado en los identificadores. Antes de saber *qué hace*, el gemelo aprende a *hablar* el idioma del sistema.
- **Se destila:** identificadores → vocabulario controlado (átomos, compuestos, convenciones), con nivel de confiabilidad por fuente y **término canónico único por concepto** (se preserva todo alias para trazabilidad).
- **Artefacto canónico — `vocab-{sistema}.md`:** tabla de 8 columnas con esquema `# | Termino | Frecuencia | Categoria | Confianza | Evidencia | Significado | Alcance`. La columna **Alcance** clasifica cada campo en uno de 6 valores mutuamente excluyentes que revelan el rol arquitectónico del campo — fundamental para decidir qué persiste, qué se integra y qué desaparece en el target:

  | Alcance | Significado |
  |---------|-------------|
  | `Persistente-BD` | Campo que persiste en base de datos (DMSII, VSAM, SQL) — core del modelo de dominio |
  | `Interfaz-Externo` | Campo de mensaje o buffer de interfaz con sistema externo (TCP/IP, TRF, BNE) — contrato de integración |
  | `Efimero` | Working storage, variables de trabajo, acumuladores — sin persistencia fuera del job/transacción |
  | `Parametrico-Catalogo` | Campo con valores fijos de negocio codificados (condiciones 88, VALUE hardcoded) |
  | `Control-proceso` | Campo de control de flujo de batch/online (status, restart, punteo, llave-CTE) |
  | `N/A-componente` | Grupo/estructura contenedora, o término curado S1 — clasificación no aplica |

  La clasificación se obtiene por **swarm de agentes CAP** (~400 campos/agente, heurísticas de prioridad) + auto-clasificación automática de GRUPOs/ESTRUCTURAs. **Distribución de referencia (Banamex S151, 20,114 campos clasificados):** Efimero 67.2% · Interfaz-Externo 24.4% · Persistente-BD 7.1% · Parametrico-Catalogo 0.75% · Control-proceso 0.59%.

- **Hallazgo recurrente · deuda de nombrado:** el mismo concepto se escribe bajo múltiples alias (sinónimos, abreviaturas, plurales, anglicismos: cliente/cte, movimiento/mov/movto, status/estatus). Inconsistencia acumulada entre dialectos/generaciones; se normaliza al sembrar el target (Capa 5/6). Regla canónica: *forma completa singular en español, frecuencia como desempate, firma del SME.*

**Capa 2 · Almas — *la memoria social.*** Quién pensó el código y qué dialecto hablaba. Cientos de personas lo tocaron; cada una dejó un vestigio.
- **Se destila:** autoría *declarada* (Autor/Realizó/Proyecto/ticket en los headers) + huella *estilométrica* (dialectos de nombrado: prefijos húngaros, mezcla ES/EN, sufijos de versión, hábitos de abreviación).
- **Salidas:** Mapa de las Almas — quién/qué proyecto moldeó cada dominio · dialectos y eras de estilo · **bus factor** (concentración de conocimiento) · código huérfano · huella de terceros. *Ley de Conway: la organización fosilizada en el código.*

**Capa 3 · Biografía — *la evolución en el tiempo.*** Las vetas del árbol: cuándo nació y mutó, cómo derivó el lenguaje y el estilo entre eras, dónde están los *hotspots*.
- **Se destila:** fechas en comentarios + productos + hitos correlacionados con la historia del cliente y la regulación. Relevo generacional (¿cada generación heredó o reinventó el vocabulario?) y deuda por era.

**Capa 4 · Intención — *el modelo mental consultable.*** De lenguaje + almas + tiempo se reconstruye el propósito: journeys, reglas, capacidades. La "cognición" del gemelo = **la suma de intenciones de cientos de personas**.
- **Se destila:** orquestadores y servicios (journeys), reglas de negocio + fórmulas mapeadas a reguladores, cobertura del modelo de capacidades, topología de componentes.
- **Punto de partida de lectura:** el **modelo de capacidades de negocio** enmarca todo (qué hace el banco) antes del código (cómo lo hace).

### Capas 5–8 · Engendrar el futuro (TO-BE) — *el gemelo da a luz*

De entender a transformar. El gemelo deja de describir y empieza a **construir el mañana**.

**Capa 5 · Fronteras — *el mapa del futuro.*** Del *qué es* al *cómo debería partirse*. Se derivan los **bounded contexts** del target desde la intención (capa 4) y el lenguaje (capa 1) — **no** desde la partición física del legacy (base de datos, LPAR, librería). Las dependencias cruzando frontera revelan las **costuras** (*seams*) por donde cortar con Strangler-Fig.
- **Disciplina:** DDD (bounded contexts, context mapping) + análisis de modularidad/costuras (M. Feathers).
- **Salida:** contextos delimitados del target + **decisión 7R por capability**.
- ⚠ *Regla de oro:* dominio técnico ≠ capability de negocio. No heredar el corte físico del legacy.

**Capa 6 · Siembra — *engendrar el target.*** El gemelo se vuelve la **especificación y el contexto** que siembra la construcción AI-assisted: vocabulario → modelo de dominio y nombrado del target; reglas → lógica de negocio; journeys → servicios y contratos. La capa de **Almas marca dónde el juicio humano es crítico** (código financiero/regulatorio).
- **Disciplina:** transformación AI-assisted (Amazon Q Developer Transform, Copilot) + generación contract-first / spec-driven.
- **Salida:** contratos (OpenAPI/AsyncAPI), scaffolds del target, librería de contexto para los agentes.

**Capa 7 · Equivalencia — *el juicio de la verdad.*** El gemelo se vuelve **oráculo de comportamiento**: golden-master tests derivados de la intención + datos de regresión; comparador de parallel-run; monitoreo de *equivalence drift*. Los riesgos marcados en las capas 1–4 (rounding, aritmética de fechas, tipos propietarios) son el foco de prueba.
- **Disciplina:** Golden Master / characterization tests (M. Feathers) + parallel-run / shadow (HVM §19 EQUIVALENCE-CHECK).
- **Salida:** suite golden-master, comparador + dashboard de equivalencia (≥ 99.95% AM · ≥ 99.99% MM banca).
- **Handoff:** sub-specialist **Equivalence Testing** (HVM-wide).

**Capa 8 · Continuidad — *el gemelo vivo.*** El gemelo **no muere en el cutover**: persiste en OPERATE/AMS como documentación viva + semántica de observabilidad + libro de *decommission*. Mientras el legacy se apaga capability por capability, el gemelo registra el % migrado, el residual y preserva el *porqué* para los mantenedores futuros.
- **Disciplina:** Living Documentation + Observabilidad/AIOps + gestión del conocimiento.
- **Salida:** gemelo vivo (se actualiza con el target), tracking de decommission, memoria institucional que sobrevive a ambos sistemas.

### Transversales · Calidad y Seguridad — *dos hilos que atraviesan las 8 capas*

La calidad y la seguridad **no son una capa**: recorren las ocho. Cada una tiene un punto de máxima concentración.

**Calidad** — *¿el gemelo es fiel, el código legacy está sano, y el target es equivalente?* Tres preguntas, un solo hilo:
- **Fidelidad del gemelo** en 1–4 (confiabilidad declarada por fuente, caza de falsos positivos, cobertura).
- **Salud estructural del código AS-IS** medida contra **ISO/IEC 5055:2021** (CISQ) — los 4 factores (Reliability · Security · Performance Efficiency · Maintainability) como conteo de *weaknesses* del catálogo **CWE**. Es el **input estructural de la decisión 7R** (baja calidad + alto acoplamiento → Rewrite/Retire; dead-code → Retire), del **pricing** (deuda técnica = días de remediación) y de la **priorización de golden-masters** (el código más enredado es el más riesgoso de probar equivalencia). Se monta sobre el toolkit del gemelo (call graph → acoplamiento/dead-code; corpus → complejidad/LoC) — no reimplementa parsing.
- **Calidad del target** en 6 (DoD) → **corazón en 7 (equivalencia ≥ 99.95%)** → SLOs/DORA en 8.

> **Frontera:** *calidad estructural del AS-IS* (¿está bien escrito el legacy?, fase DISCOVER) ≠ *equivalencia funcional* (¿el target hace lo mismo?, fase TEST). Son preguntas y fases distintas, complementarias: la primera prioriza el trabajo de la segunda. **Handoff de ejecución:** sub-specialist **Code Quality Assessment** (HVM-wide) para la salud del AS-IS; **Equivalence Testing** (HVM-wide) para la paridad del target. El mercado no ofrece herramientas de calidad para dialectos nicho (Informix SPL, COBOL) — por eso se implementa el *estándar* ISO 5055 (agnóstico del lenguaje) con reglas calibradas al dialecto, evitando el ruido de las tools genéricas.

**Seguridad** — *DevSecOps (shift-left) + security archaeology en el AS-IS.* Arqueología de postura en 1–4 (autenticación, PLD/antilavado, PII, secretos hardcodeados, SQL/código dinámico) → threat modeling de bounded contexts en 5 → secure-by-design (SAST/SCA/secrets/container) en 6 → datos enmascarados en parallel-run en 7 → runtime + AIOps en 8.

> **Cumplimiento regulatorio** (CNBV · Banxico · CONDUSEF · PLD · PCI-DSS · ISO 27001) atraviesa ambos hilos. **Handoff de ejecución de seguridad:** SME de **Cybersecurity / Cloud Security** de `Solutioning/Delivery - SME/`. El gemelo le entrega el *mapa* (dónde viven secretos, auth y datos sensibles), no reemplaza su juicio.

---

## 4 · Adaptadores por tecnología — *la mecánica de extracción*

El método es el mismo; **de dónde sale la evidencia cambia**. Esta tabla es el corazón de la reutilización cross-tecnología: define, capa por capa, la fuente de extracción de cada tecnología. Cada *Specialist* de RE implementa su columna.

| Capa (qué destila — constante) | **Informix SPL** (AM) | **COBOL / z-OS** (MM) | **Oracle Forms + PL/SQL** (AM) | **SQL Server T-SQL** (AM) |
|---|---|---|---|---|
| **1 · Lenguaje** (identificadores → vocabulario) | nombres de SP/tabla/columna en `sysprocedures`/`syscolumns` | nombres de párrafos, *data items*, copybooks | items de bloque `.fmb`, paquetes/procedimientos PL/SQL | `sys.procedures`, `sys.columns`, nombres de objetos |
| **2 · Almas** (autoría + estilometría) | headers de comentario en `sysprocbody` | cabecera de programa + `CHANGE-LOG` en comentarios | headers en `.fmb`/`.pll`/*package spec* | headers de comentario + *extended properties* |
| **3 · Biografía** (fechas + productos + hitos) | fechas en comentarios | fechas + niveles de versión + calendario JCL | fechas en fuentes/versión de módulo | fechas en comentarios + git si existe |
| **4 · Intención** (journeys + reglas + capacidades) | call graph SP→SP + DML + triggers | grafo `PERFORM`/`CALL` + `COPY` + jobs JCL | triggers de Forms + llamadas PL/SQL | grafo de `EXEC`/call + DML + triggers |
| **5 · Fronteras** (bounded contexts / costuras) | dependencias cruzando frontera de BD | dependencias cross-program + copybooks compartidos | módulos Forms + esquemas PL/SQL | esquemas / bases / *linked servers* |
| **6 · Siembra** (spec del target) | tipos Informix → PostgreSQL/Java | COBOL → Java/microservicios | Forms/PLSQL → SPA + servicios | T-SQL → target |
| **7 · Equivalencia** (riesgos de tipo/rounding) | `MONEY`/`DECIMAL`, TRUNC vs ROUND, 360/365 | `COMP-3`/packed decimal, `PIC` edición | `NUMBER` rounding, `DATE` semántica | `MONEY`/`DECIMAL`, `DATETIME` precision |
| **8 · Continuidad** (decommission) | apagado de instancia IDS | apagado de LPAR/región | retiro de Forms runtime | retiro de instancia |
| **✕ Calidad AS-IS** (weaknesses ISO 5055 — *transversal*) | nodos de decisión SPL (`IF`/`FOREACH`/`ON EXCEPTION`), `OPEN` sin `CLOSE`, `COMMIT` en `FOREACH`, SQL dinámico | complejidad de párrafos, `GO TO` salvaje, `PERFORM THRU`, tablas sin `INITIALIZE` | triggers Forms complejos, PL/SQL sin `EXCEPTION`, cursores no cerrados | `TRY/CATCH` ausente, cursores, `sp_executesql` dinámico |

**Confiabilidad de vestigios por tecnología (Capa 2–3):** COBOL/mainframe suele tener headers y `CHANGE-LOG` más estructurados + scheduling JCL explícito (mayor cobertura de autoría/fechas); Informix y stored-proc-heavy suelen tener menos (cobertura declarada más baja → más peso en estilometría). **Se declara la cobertura real por engagement, no se asume.**

---

## 5 · El toolkit reutilizable — *renderer cognitivo + extractores*

El activo de software que acelera cada engagement, en dos partes:

**A) Renderer cognitivo (tech-agnóstico — se construye una vez):**
- Motor de vocabulario: tokenización, clasificación por categoría, **deduplicación canónica** (sinónimos + plurales + anglicismos vía union-find), confiabilidad por fuente.
- Generadores de vistas: Mapa de las Almas, evolución/biografía, relevo generacional y deuda, journeys, reglas, modelo de capacidades, mapa de componentes, **portal/landing** navegable por las 4 capas.
- **Brand-swap:** paleta + logo del cliente parametrizables (validados con `validate_palette` — banda de luminosidad, piso de croma, separación CVD ≥ 12, contraste). Los colores categóricos de dominio NO se tocan; solo el *chrome* de marca.
- Marco de confiabilidad honesta embebido (declarado vs. inferido, evidencia dura vs. convención).

**B) Extractores (uno por tecnología — se construye por familia):**
- Ingiere el legacy (catálogo, fuentes, copybooks…) y emite el **JSON normalizado** (§7).
- Informix SPL: ✅ existe (probado en BanCoppel). COBOL/z-OS, Oracle Forms/PL-SQL, T-SQL: por construir cuando un deal lo demande.

> Estado actual: el renderer está construido pero **acoplado a la instancia BanCoppel** (`.../Application Modernization/BanCoppel/BCOPCore/`). El plan de extracción a starter-kit reutilizable lo definirá el `delivery-playbook` de HVM. Hasta entonces, BCOPCore es la **implementación de referencia**.

---

## 6 · Contrato del JSON normalizado — *la interfaz extractor → renderer*

Lo que todo extractor debe emitir para que el renderer tech-agnóstico funcione sin cambios. Es la frontera que hace posible la reutilización cross-tecnología.

```jsonc
{
  "meta":    { "sistema": "…", "tecnologia": "informix-spl|cobol|oracle-forms|tsql",
               "objetos": 0, "conectados": 0, "fuente_evidencia": "catalogo|fuentes" },
  "objetos": [ { "id": "", "nombre": "", "tipo": "sp|programa|trigger|form|funcion",
                 "loc": 0, "dominio": "", "params": 0 } ],
  "callgraph": [ { "from": "", "to": "", "tipo": "call|perform|trigger|dml" } ],
  "acceso":  [ { "objeto": "", "entidad": "", "modo": "R|W|RW" } ],
  "headers": [ { "objeto": "", "autor": "", "fecha": "", "proyecto": "", "ticket": "" } ],
  "hitos":   [ { "anio": 0, "titulo": "", "tipo": "cliente|regulatorio|tecnologico" } ],
  "riesgos_tipo": [ { "entidad": "", "campo": "", "tipo_origen": "", "riesgo": "bajo|medio|alto|critico" } ]
}
```

- **Constante entre tecnologías:** el esquema. Un extractor COBOL y uno Informix producen el mismo shape.
- **Variable:** cómo se llena cada arreglo (los adaptadores de §4).
- El renderer consume solo este contrato → **cero acoplamiento** a la tecnología origen.

---

## 7 · Lugar en el SDLC y quién lo implementa

| Capa | Fase SDLC | Ejecutor (Specialist de RE) |
|------|-----------|------------------------------|
| 1–4 · Lenguaje · Almas · Biografía · Intención | DISCOVER | Specialist de la tecnología (Informix SPL · Reverse Engineering COBOL · …) |
| 5 · Fronteras | DESIGN | Solution architect + SME |
| 6 · Siembra | BUILD | Software Engineering SME + AI-assisted tooling |
| 7 · Equivalencia | TEST | Sub-specialist **Equivalence Testing** (HVM-wide) |
| 8 · Continuidad | RELEASE→ITERATE | AMS Reinvention + observabilidad |
| ✕ Calidad AS-IS (transversal) | DISCOVER | Sub-specialist **Code Quality Assessment** (HVM-wide) — ISO 5055; coordina la mecánica de detección con el Specialist de RE de cada tecnología |

**Familia de Specialists que implementan el método:**

| Specialist | Solution L4 | Tecnología | Estado |
|---|---|---|---|
| Specialist - Informix SPL | Application Modernization | Informix IDS / SPL | ✅ activo (BanCoppel) |
| Specialist - Reverse Engineering | Mainframe Modernization | COBOL / ALGOL / WFL | ✅ activo (Banamex) — alinear al método |
| Specialist - Oracle Forms / PL-SQL | Application Modernization | Oracle Forms + PL/SQL | ⏳ stub por crear |
| Specialist - SQL Server T-SQL | Application Modernization | SQL Server T-SQL | ⏳ stub por crear |

---

## 7a · Modelo de datos para Capa 4 — Capacidades, Tareas y Flujos

La Capa 4 (Intención) produce el modelo de capacidades de negocio del sistema legacy. Para que ese modelo sea consultable, trazable y útil como especificación del target, se estructura en una jerarquía de cinco niveles con artefactos concretos.

### Jerarquía de conocimiento

```
Dominio → Subdominio → Capacidad → Proceso → Tarea → Regla de Negocio
                                                  ↕
                                            Casuística (secuencia de tareas)
                                                  ↕
                                            Diagrama Mermaid (flujo/secuencia)
```

La **Tarea** es la unidad atómica: es el nivel donde la regla ancla, la secuencia ordena y el diagrama visualiza. Intentar vincular reglas directamente a Capacidades o Procesos produce trazabilidad imprecisa — la regla siempre se activa en el contexto de una tarea específica.

### IDs canónicos

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| Tarea | `T-{SLUG_CAPACIDAD}-{NNN}` | `T-TEL-001`, `T-ATM-003` |
| Casuística | `CS-{SLUG_CAPACIDAD}-{NN}` | `CS-TEL-01`, `CS-ATM-02` |
| Regla de negocio | `RN-{SISTEMA}-{NNN}` | `RN-S151-042`, `RN-S500-017` |

`{SLUG_CAPACIDAD}` es el identificador corto de la capacidad (3-5 caracteres, mayúsculas). Ejemplos: `TEL` (Telecomunicaciones), `ATM` (ATM/Cajeros), `INT` (Intereses), `COM` (Comisiones).

### Estructura de archivo por capacidad (`cap-{slug}.md`)

Un archivo por capacidad cubierta, con secciones en este orden:

```markdown
# Capacidad: {Nombre} [{Sistema}]
> Dominio: X · Subdominio: Y · Cobertura: S500/S151/compartida/gap

## Inventario de Tareas
| ID | Tarea | Programa | Componente fuente | Tipo |
|----|-------|----------|-------------------|------|
| T-{SLUG}-001 | {descripción imperativa} | P010 | COBOL_P010.txt | validación |

## Casuísticas
### CS-{SLUG}-01: {Nombre casuística}
**Tipo:** happy-path / error / edge-case
**Condición de entrada:** {precondición}
**Resultado:** {postcondición / efecto}
**Secuencia:** T-{X}-001 → T-{X}-002 → T-{X}-003

## Diagrama
```mermaid
sequenceDiagram
  ...
```

## Reglas vinculadas
| Tarea | Regla | Componente fuente | Descripción |
|-------|-------|-------------------|-------------|
| T-{X}-001 | RN-{S}-NNN | COBOL_P010.txt | {descripción breve} |
```

### Tipos válidos de Tarea

| Tipo | Cuándo usarlo |
|------|---------------|
| `validación` | Verifica una condición antes de continuar |
| `consulta` | Lee datos sin modificarlos |
| `escritura` | Persiste o actualiza un campo |
| `contable` | Genera un asiento o movimiento GL |
| `control` | Maneja flujo de batch (restart, punteo, control de llave) |

### Flujo de construcción (orden obligatorio)

1. **Inventario de tareas** — derivado del código fuente + reglas ya extraídas del catálogo RN-NNN
2. **Casuísticas** — agrupar tareas en secuencias por escenario (happy path primero, luego errores, luego edge cases)
3. **Diagrama Mermaid** — generado mecánicamente de la secuencia de cada casuística
4. **Vincular reglas** — cruzar cada tarea contra el catálogo `RN-{SISTEMA}-NNN`

No construir el diagrama antes de tener las casuísticas. No vincular reglas antes de tener el inventario de tareas. El orden garantiza trazabilidad completa de código → tarea → casuística → diagrama → regla.

### Relación con los otros artefactos del Gemelo (Capa 1 y 2)

- **Vocabulario (Capa 1):** los nombres de las Tareas usan el término canónico del vocab (`vocab-{sistema}.md`), no sinónimos. El `{SLUG_CAPACIDAD}` deriva del término canónico de la capacidad.
- **Reglas (Capa 2):** el catálogo `RN-{SISTEMA}-NNN` es el input de la columna "Reglas vinculadas". Una regla puede vincularse a múltiples tareas si es distribuida (`[REGLA-DISTRIBUIDA]`).
- **Fronteras (Capa 5):** los bounded contexts del target se derivan agrupando Capacidades de la misma Capa 4 — la jerarquía Dominio → Capacidad es el insumo directo de la decisión 7R por capability.

---

## 8 · Notas de honestidad

- El gemelo es **probabilístico**: la cobertura de autoría y fechas depende de los vestigios disponibles (varía por tecnología, §4). Se declara por fuente, no se infla.
- La Capa 2 combina evidencia **declarada** (headers, alta certeza donde existe) con **inferida** (estilometría, para el resto) — se marca la diferencia, no se mezcla.
- El gemelo **no reemplaza al SME**: lo acelera y le da un mapa. La validación final del negocio y lo regulatorio sigue siendo humana.
- El vocabulario canónico es una **recomendación automática** que requiere **firma del SME** antes de volverse nombre permanente del target.

---

## 9 · Instancia de referencia — BanCoppel (`SPE-AM-001`)

Primera implementación completa del método, sobre **IBM Informix IDS 14.10** (patrón "base de datos como aplicación", ~13,223 SPs / 3,761 conectados). Artefactos vivos en `.../Application Modernization/BanCoppel/BCOPCore/`: `sp_vocab.py` (fuente única del vocabulario), pipeline de ~15 generadores, portal `index-bcop.html` con las 4 capas, y `metodologia-gemelo-cognitivo.md` (instancia local de este método). Sirve como **plantilla de referencia** para el renderer y el primer extractor (Informix). Contexto de cliente: `.../BanCoppel/knowledge-base-coppel-bancoppel.md`.

---

*Gemelo Cognitivo del Sistema · método HVM-wide · v2.2 · Añadido artefacto canónico Capa 1: esquema 8 columnas con columna **Alcance** (6 valores: Persistente-BD · Interfaz-Externo · Efêmero · Parametrico-Catalogo · Control-proceso · N/A-componente), pipeline swarm de agentes CAP y distribución de referencia Banamex S151 (20,114 campos). v2.1: Añadido el hilo transversal **Calidad AS-IS** anclado a ISO/IEC 5055:2021 (§3) con mecánica de detección por tecnología (§4) y ejecutor **Code Quality Assessment** HVM-wide (§7) — resuelve la salud estructural del código legacy como input de la decisión 7R/pricing/equivalencia, complementaria a la equivalencia funcional del target. v2.0: generalizado a cross-tecnología (Informix · COBOL · Oracle Forms · T-SQL) con adaptadores (§4), toolkit renderer+extractores (§5) y contrato JSON normalizado (§6). Instancia de referencia: BanCoppel BCOPCore.*