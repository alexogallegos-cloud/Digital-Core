# Gemelo Cognitivo del Sistema
### *Cognitive Digital Twin* — metodología de comprensión de legacy para modernización

> **Qué es:** una metodología para destilar la inteligencia acumulada de un sistema legacy —su lenguaje, sus autores y su evolución— en un **modelo vivo y consultable** que sobrevive al sistema original y guía su modernización.
>
> **Componente:** BanCoppel BCOPCore · SPE-AM-001 · Fase DISCOVER · Etapa 3 · Specialist Informix SPL · **v1.0 · 2026-07-06**

---

## 1 · El principio (por qué mira al futuro)

La ingeniería inversa clásica *desentierra el pasado*. El Gemelo Cognitivo hace lo contrario: **convierte el legacy en la semilla del sistema del futuro**. El código deja de ser un lastre a descifrar y se vuelve un activo que:

1. **Preserva la memoria institucional** — cuando las personas que escribieron el core ya no están y el sistema se apaga (decommission), su conocimiento no muere: queda capturado en un modelo consultable.
2. **Siembra la modernización AI-assisted** — el lenguaje, las reglas y la intención recuperados son la *especificación y el material de contexto* para los agentes/SMEs que construyen el target.
3. **Predice el riesgo** — de equivalencia funcional, de concentración de conocimiento (*bus factor*), de acoplamiento — **antes** de tocar una línea.

> El gemelo es **cognitivo** (no solo estructural): modela no únicamente *qué hace* el sistema, sino *qué idioma habla, quién lo pensó y cómo maduró su intención*.

---

## 2 · Fundamento de mercado

No es una metáfora aislada: cada capa se apoya en una disciplina establecida.

| Capa del gemelo | Disciplina | Referencia |
|-----------------|------------|------------|
| Lenguaje | **Software Linguistics / Source-Code Lexicon** + *Ubiquitous Language* (DDD) | Normalizing Source Code Vocabulary (ICSE'13); Eric Evans, *DDD* |
| Almas | **Code Stylometry / Authorship Attribution** + Software Forensics | Caliskan et al., *De-anonymizing Programmers via Code Stylometry* (USENIX'15) |
| Biografía | **Mining Software Repositories** + **Behavioral Code Analysis** | Adam Tornhill, *Your Code as a Crime Scene* / CodeScene |
| Intención | **Program Comprehension / Concept Location** | ICPC; *Software Archaeology* (Harry Sneed, 1994) |

> **Linaje honesto:** la *técnica* subyacente proviene de la software archaeology (Sneed) y del análisis conductual (Tornhill), que normalmente requieren **historia de Git**. Aquí **no la hay** — por eso el gemelo se reconstruye de *vestigios*: headers de comentarios (autor/fecha/proyecto/RQM) + estilo de nombrado. El resultado es un gemelo **probabilístico y declarado por fuente**, no un registro completo.

---

## 3 · Las ocho capas del Gemelo

Ocho capas en dos mitades: **1–4 entienden** el sistema tal como es (AS-IS) y dan nacimiento al gemelo; **5–8 lo proyectan** al futuro (TO-BE) y lo mantienen vivo.

### Capas 1–4 · Entender el sistema (AS-IS) — *el gemelo nace*

Del lenguaje a la intención. **El lenguaje primero.**

### Capa 1 · Lenguaje — *el idioma del gemelo*
El vocabulario del negocio fosilizado en los identificadores. Antes de saber *qué hace*, el gemelo aprende a *hablar* el idioma del sistema.
- **Se destila:** identificadores → vocabulario controlado (átomos, compuestos, convenciones), con nivel de confiabilidad por fuente.
- **Artefacto:** `sp_vocab.py` · `vocabulary-report-bcop.html` (531 términos). **✅ construido.**
- **Hallazgo · deuda de nombrado:** el mismo concepto se escribe bajo múltiples alias (~86 conceptos en ~196 términos: cliente/cte, movimiento/mov/movto, cheque/cheques, cheque/cheques). Inconsistencia acumulada entre dialectos/generaciones; se normaliza a un término canónico al sembrar el target (Capa 5/6).

### Capa 2 · Almas — *la memoria social*  `← NUEVO`
Quién pensó el código y qué dialecto hablaba. Cientos de personas lo tocaron; cada una dejó un vestigio.
- **Se destila:** autoría *declarada* (Autor/Realizó/Proyecto/RQM en **~27%** de los headers — nombres reales + terceros como *Solser*) + huella *estilométrica* (dialectos de nombrado: prefijos húngaros, mezcla ES/EN, sufijos de versión, hábitos de abreviación).
- **Artefacto (pendiente):** **Mapa de las Almas** (`souls-bcop.html`) — quién/qué proyecto moldeó cada dominio · dialectos y eras de estilo · **bus factor** (concentración de conocimiento) · código huérfano · huella de terceros. *Ley de Conway: la organización fosilizada en el código.*

### Capa 3 · Biografía — *la evolución en el tiempo*
Las vetas del árbol: cuándo nació y mutó, cómo derivó el lenguaje y el estilo entre eras, dónde están los *hotspots*.
- **Se destila:** fechas en comentarios (~11–44% cobertura) + productos + hitos correlacionados con la historia de Coppel/BanCoppel y la regulación.
- **Artefacto:** `evolution-bcop.html` (18 hitos, 2007–2025). **✅ construido** — se enriquece con hotspots y *drift* de lenguaje por era.

### Capa 4 · Intención — *el modelo mental consultable*
De lenguaje + almas + tiempo se reconstruye el propósito: journeys, reglas, capacidades. La "cognición" del gemelo = **la suma de intenciones de cientos de personas**.
- **Se destila:** orquestadores y servicios (journeys), reglas de negocio + fórmulas mapeadas a reguladores, cobertura del modelo de capacidades.
- **Artefacto:** `journeys-bcop.html` · `rules-report-bcop.html` · `capability-model-bcop.html` · `banking-model-bcop.html`. **✅ construido.**

### Capas 5–8 · Engendrar el futuro (TO-BE) — *el gemelo da a luz*

De entender a transformar. El gemelo deja de describir y empieza a **construir el mañana**.

### Capa 5 · Fronteras — *el mapa del futuro*
Del *qué es* al *cómo debería partirse*. Se derivan los **bounded contexts** del target desde la intención (capa 4) y el lenguaje (capa 1) — **no** desde la partición por base de datos del legacy. Las 34,279 dependencias (casi todas cruzando frontera de BD) revelan las **costuras** (*seams*) por donde cortar con Strangler-Fig.
- **Disciplina:** Domain-Driven Design (bounded contexts, context mapping) + análisis de modularidad/costuras (M. Feathers).
- **Salida:** contextos delimitados del target + **decisión 7R por capability** (ADR-SPE-AM-001/002).
- ⚠ *Regla de oro:* dominio técnico ≠ capability de negocio. No heredar el corte por base de datos.

### Capa 6 · Siembra — *engendrar el target*
El gemelo se vuelve la **especificación y el contexto** que siembra la construcción AI-assisted: vocabulario → modelo de dominio y nombrado del target; reglas → lógica de negocio; journeys → servicios y contratos. La capa de **Almas marca dónde el juicio humano es crítico** (código financiero/regulatorio).
- **Disciplina:** transformación AI-assisted (Amazon Q Developer Transform, Copilot) + generación contract-first / spec-driven.
- **Salida:** contratos (OpenAPI/AsyncAPI), scaffolds del target, librería de contexto para los agentes.

### Capa 7 · Equivalencia — *el juicio de la verdad*
El gemelo se vuelve **oráculo de comportamiento**: golden-master tests derivados de la intención + datos de regresión; comparador de parallel-run; monitoreo de *equivalence drift*. Los riesgos marcados en las capas 1–4 (TRUNC vs ROUND, base 360/365, redondeo MONEY) son el foco de prueba.
- **Disciplina:** Golden Master / characterization tests (M. Feathers) + parallel-run / shadow (HVM §19 EQUIVALENCE-CHECK).
- **Salida:** suite golden-master, comparador + dashboard de equivalencia (≥ 99.95% AM).

### Capa 8 · Continuidad — *el gemelo vivo*
El gemelo **no muere en el cutover**: persiste en OPERATE/AMS como documentación viva + semántica de observabilidad + libro de *decommission*. Mientras el legacy se apaga capability por capability, el gemelo registra el % migrado, el residual y preserva el *porqué* para los mantenedores futuros. El legado se vuelve **semilla y memoria** a la vez.
- **Disciplina:** Living Documentation + Observabilidad/AIOps + gestión del conocimiento.
- **Salida:** gemelo vivo (se actualiza con el target), tracking de decommission, memoria institucional que sobrevive a ambos sistemas.

### Transversales · Calidad y Seguridad — *dos hilos que atraviesan las 8 capas*

La calidad y la seguridad **no son una capa**: recorren las ocho. Forzarlas a un solo lugar las esconde del resto. Cada una tiene, eso sí, un punto de máxima concentración.

**Calidad** — *¿el gemelo es fiel, y el target es equivalente?*

| Capa | Manifestación de calidad |
|------|--------------------------|
| 1–4 · AS-IS | **Fidelidad del gemelo**: confiabilidad declarada por fuente, caza de falsos positivos, cobertura — el gemelo no miente sobre lo que sabe |
| 5 · Fronteras | Contextos cohesivos y de bajo acoplamiento, validados con SME |
| 6 · Siembra | Calidad del target: cobertura de tests, linting, complejidad (DoD-SPE-02) |
| **7 · Equivalencia** | **El corazón de la calidad** — golden-master + parallel-run ≥ 99.95% |
| 8 · Continuidad | Calidad en producción: SLOs, error budget, métricas DORA |

**Seguridad** — *el hueco más grande si no se hace explícita.* Enfoque **DevSecOps** (shift-left) + *security archaeology* en el AS-IS.

| Capa | Manifestación de seguridad |
|------|----------------------------|
| 1–4 · AS-IS | **Arqueología de postura de seguridad**: lógica de autenticación (dominio Integración/Auth), controles PLD/antilavado, reglas de acceso/privilegio, flujos de datos sensibles/PII, secretos/credenciales hardcodeados, SQL dinámico propenso a inyección |
| 5 · Fronteras | **Threat modeling** de los bounded contexts; clasificación de sensibilidad de datos; los límites de confianza = las nuevas fronteras de servicio |
| 6 · Siembra | **Secure-by-design**: SAST · SCA · secrets · container scan en CI (gates DoD-SPE); no propagar vulnerabilidades del legacy al target |
| 7 · Equivalencia | **Seguridad de datos en parallel-run**: enmascarado de PII en datasets shadow, comparador seguro; DAST / pentest del target |
| 8 · Continuidad | **Seguridad en runtime + AIOps**: detección de anomalías, rotación de secretos, trazas de auditoría (regulatorio) |

**Cumplimiento regulatorio** (CNBV · Banxico · CONDUSEF · PLD · PCI-DSS · ISO 27001) atraviesa ambos hilos y ya tiene a los 6 SME reguladores presentes desde la capa 4.

> **Handoff:** la ejecución de seguridad la lleva el SME de **Cybersecurity / Cloud Security** de `SME/` (gates SAST/SCA/DAST). El gemelo le entrega el **mapa** — dónde viven los secretos, la autenticación y los datos sensibles — no reemplaza su juicio.

---

## 4 · Salidas de valor futuro

| Salida | Para quién | Valor |
|--------|-----------|-------|
| **Modelo consultable** (portal `index-bcop.html`) | Equipo de modernización, AMS, cliente | Memoria institucional que persiste tras el decommission |
| **Vocabulario + reglas + intención** | Agentes AI-assisted + SMEs | Especificación y contexto para construir el target |
| **Bus factor + código huérfano** (Capa 2) | Gestión de riesgo / delivery lead | Dónde el conocimiento está en riesgo de perderse |
| **Riesgos de equivalencia** (fórmulas, TRUNC/360-365/MONEY) | Risk officer / QA equivalencia | Qué validar antes del cutover |

---

## 5 · Lugar en el SDLC de HVM

Las 8 capas recorren el SDLC completo: las 4 de entendimiento en DISCOVER, las 4 del futuro en la mitad de delivery.

| Capa | Fase SDLC |
|------|-----------|
| 1–4 · Lenguaje · Almas · Biografía · Intención | DISCOVER |
| 5 · Fronteras | DESIGN |
| 6 · Siembra | BUILD |
| 7 · Equivalencia | TEST |
| 8 · Continuidad | RELEASE · OPERATE · OBSERVE · ITERATE |

- **Fase de origen:** DISCOVER (Etapa 3 · Business Logic Extraction). Alimenta directamente:
  - la decisión **7R por capability** (qué refactor / rehost / replace / retire),
  - el gate de **equivalencia funcional** (§19 EQUIVALENCE-CHECK),
  - el **ADR-SPE-AM-006** (tipos propietarios / semántica del datastore origen).
- **Reutilizable:** la metodología aplica a cualquier sistema legacy con patrón "base de datos como aplicación" (Informix, Oracle Forms, SQL Server stored-proc-heavy) donde la lógica vive en el datastore y la documentación es escasa.

---

## 6 · Notas de honestidad

- El gemelo es **probabilístico**: autoría declarada ~27%, fechas 11–44%, vocabulario 84% "confirmado" (código + SME + convención; la evidencia *dura* de código es menor).
- La Capa 2 combina evidencia **declarada** (headers, alta certeza donde existe) con **inferida** (estilometría, para el resto) — se marca la diferencia, no se mezcla.
- El gemelo **no reemplaza al SME**: lo acelera y le da un mapa. La validación final del negocio y lo regulatorio sigue siendo humana.

---

*Gemelo Cognitivo del Sistema · v1.2 · 8 capas (1–4 entender el AS-IS · 5–8 engendrar el TO-BE) + 2 transversales (Calidad, Seguridad). Sustituye el marco previo "Arqueología del Código" (mismo método, propósito reorientado al futuro). Fuente única del pipeline: `sp_vocab.py`. Ver base de conocimiento del cliente: `../knowledge-base-coppel-bancoppel.md`.*