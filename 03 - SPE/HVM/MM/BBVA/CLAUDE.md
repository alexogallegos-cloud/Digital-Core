# BBVA México — Mainframe Modernization (Altamira + APX)
> Proyecto cliente dentro del Solution Delivery Agent de Mainframe Modernization (L4).
> Hereda: `CLAUDE.md` de Mainframe Modernization → HVM → S&PE → Digital Core.

---

## Identidad del Proyecto

| Campo | Valor |
|-------|-------|
| Cliente | BBVA México (BBVA Bancomer) |
| Sector | Banca — 2.° banco más grande de México (~23% participación) |
| Regulación | CNBV · Banxico · CONDUSEF · PCI-DSS |
| Grupo | BBVA S.A. (España) — subsidiaria mexicana |
| Deal Stage | Pre-S0 — Oportunidad activa por falla de incumbente |
| Competidor incumbente | **Kyndryl** — lleva ~8 meses en el proyecto; falla de desempeño documentada |
| Fase SDLC Actual | DISCOVER — Etapa 0 (contexto y scouting) |
| Component ID Prefix | `SPE-MM-BBVA-{NNN}` |

---

## Contexto Tecnológico del Cliente

### Sistema Altamira — Core Banking Legacy

**Altamira** es el sistema de core bancario de BBVA México. Fue construido por **Accenture** a principios de la década del 2000 y lleva operando en producción desde entonces. Es el mismo sistema core que históricamente han usado otros bancos del mercado mexicano.

| Atributo | Detalle |
|----------|---------|
| Origen | Desarrollado por Accenture (~2000–2003) |
| Plataforma | IBM z/OS (mainframe) |
| Lenguajes | COBOL / JCL / VSAM |
| Dominio funcional | Core bancario: cuentas, transacciones, productos, contabilidad, batch EOD |
| Integración actual | SOA (Service-Oriented Architecture) hacia NextGen y APX |
| % transacciones actuales | ~72% del volumen total (estimado, 2024) |
| Estado | Activo en producción — en proceso de desplazamiento gradual |

> **Ventaja competitiva de Accenture**: al ser el builder original de Altamira, disponemos de conocimiento profundo de su arquitectura, estructura de datos y lógica de negocio. Esto reduce drásticamente el esfuerzo de Reverse Engineering en Fase 1 vs. un competidor externo.

---

### APX — Arquitectura Plataforma Extendida

**APX** es la plataforma tecnológica interna desarrollada por BBVA como capa de desacoplamiento del mainframe. No es un producto de mercado — es un activo de ingeniería propio del banco.

| Atributo | Detalle |
|----------|---------|
| Nombre completo | Arquitectura Plataforma Extendida |
| Origen | Desarrollo interno BBVA |
| Stack | Java EE (Jakarta EE) — backend transaccional ligero sobre estándares abiertos |
| Objetivo original | Reducir uso de MIPS del mainframe; extender capacidades del backend en el mundo distribuido |
| Modelo de ejecución | Síncrono (online) y asíncrono (batch) |
| Exposición | Interfaces RESTful; microservicios Java que encapsulan lógica de negocio |
| Hito relevante | 2019: BBVA migró transacciones de **consulta** del mainframe a APX |
| Estado | Activo — pero también considerado "legado generacional" a sustituir por cloud-native |

> APX fue la solución de transición: quitó carga del mainframe pero generó su propia deuda técnica. El objetivo actual del banco es reemplazarlo por microservicios cloud-native, no mantenerlo como plataforma permanente.

---

### Arquitectura NextGen — El Target

BBVA llama "NextGen" a su arquitectura target: cloud-native, desacoplada del mainframe, orientada a microservicios. Sus características:

| Capa | Tecnología |
|------|-----------|
| Servicios de negocio | Java (Spring Boot / Quarkus) — perfiles NextGen |
| Datos analytics | Python — plataforma ADA sobre AWS |
| Mobile | Lenguaje Cells (interno BBVA) |
| Web | Java |
| Metodología | Scrum / Agile — squads NextGen vs. equipos legacy |
| Cloud primario | AWS (ADA data platform) + Red Hat OpenShift (aplicaciones) |
| Integración legacy↔NextGen | SOA / API Gateway |

**Estado de migración (referencia 2024):**
- NextGen: **~28%** de las transacciones totales
- Altamira legacy: **~72%** de las transacciones totales
- Roadmap BBVA México publicado: transformación hasta 2029

---

## Mapa de Sistemas a Modernizar

```
┌─────────────────────────────────────────────────────────────┐
│                     BBVA MÉXICO — AS-IS                     │
├─────────────────────┬───────────────────────────────────────┤
│  IBM z/OS Mainframe │  ALTAMIRA (COBOL/JCL/VSAM)           │
│  ~72% txns          │  Core bancario · EOD batch · Contab.  │
├─────────────────────┼───────────────────────────────────────┤
│  APX (Java EE)      │  Middleware de desacoplamiento         │
│  Capa de transición │  REST APIs · Consultas migradas 2019  │
├─────────────────────┼───────────────────────────────────────┤
│  NextGen (~28% txns)│  Microservicios Java · AWS · OpenShift │
│  TARGET PARCIAL     │  SOA hacia Altamira via API Gateway    │
└─────────────────────┴───────────────────────────────────────┘

                              ▼  TO-BE

┌─────────────────────────────────────────────────────────────┐
│               BBVA MÉXICO — TARGET ARCHITECTURE             │
├─────────────────────────────────────────────────────────────┤
│  Cloud-Native (AWS + Red Hat OpenShift)                      │
│  Java microservicios · Python · Event-driven (Kafka)        │
│  APIs RESTful / AsyncAPI · CQRS donde aplique               │
│  Zero mainframe · Zero APX legacy                           │
│  Regulatorio: CNBV CECOBAN · Banxico SPEI · PCI-DSS Nivel 1│
└─────────────────────────────────────────────────────────────┘
```

---

## Señal de Entrada — Burning Platform (Kyndryl)

> Esta sección documenta la situación competitiva crítica que abre la puerta a Accenture. Mantener actualizada con cada nueva inteligencia.

### Situación Confirmada (julio 2026)

**Kyndryl es el incumbente** contratado por BBVA para migrar el **bloque de contabilidad** de Altamira hacia APX.

| Dato | Detalle |
|------|---------|
| Incumbente | Kyndryl |
| Duración del engagement | ~8 meses (a julio 2026) |
| Dominio en migración | **Bloque de contabilidad** (módulo de mayor criticidad regulatoria) |
| Resultado observado | **Degradación severa de desempeño**: las mismas operaciones que Altamira ejecuta en su ventana de tiempo normal ahora tardan significativamente más en APX |
| Causa raíz | **Desconocida** — no identificada aún por el cliente ni por Kyndryl |
| Estado del engagement Kyndryl | En riesgo — sin resolución aparente después de 8 meses |

### ¿Por qué falla la migración de contabilidad a APX? — Hipótesis Técnicas

El bloque de contabilidad en un banco como BBVA es procesamiento batch masivo de alta complejidad financiera. Las causas probables de regresión de desempeño al pasar de COBOL/Altamira a Java/APX son:

| Hipótesis | Mecanismo | Probabilidad |
|-----------|-----------|-------------|
| **N+1 en batch** | El COBOL original procesa asientos contables en modo secuencial sobre VSAM/ficheros — un solo file read por millones de registros. Java/JDBC implementado ingenuamente hace una query por registro → degradación de 10–100x en volumen batch | **Alta** |
| **Packed decimal → BigDecimal** | COBOL usa `COMP-3` (packed decimal) acelerado por hardware IBM Z para aritmética financiera. Java BigDecimal es correcto pero CPU-intensivo; si además usaron `double`, hay rounding errors que rompen la equivalencia contable | **Alta** |
| **Pérdida del modelo transaccional COBOL** | Las unidades de trabajo en JCL/COBOL tienen checkpointing implícito y restart-ability. Java EE transactions tienen overhead por commit y no replican este comportamiento en batch | **Media** |
| **Contención de conexiones DB** | APX usa connection pool JDBC. Si el batch contable es secuencial en COBOL pero paralelo en Java, puede generar deadlocks o contención en el motor de base de datos | **Media** |
| **Ordenamiento de asientos** | La contabilidad bancaria depende del orden de aplicación de asientos (débito/crédito). Si la migración Java no preserva el orden exacto de procesamiento del COBOL, los saldos intermedios divergen → resultado incorrecto aunque cada asiento sea válido individualmente | **Alta** |
| **Aritmética de fechas y períodos** | COBOL en mainframe usa fechas julianas y períodos contables propios. La conversión a java.time puede perder precisión en cierres de período o diferencias de zona horaria | **Baja-media** |

> **El que conoce Altamira puede diagnosticar esto en semanas.** Kyndryl no construyó Altamira — Accenture sí. Esta asimetría de conocimiento es el diferenciador más concreto disponible.

> **Knowledge Base generalizado (cualquier banco):** ver [../kb-retos-modernizacion-mainframe-banca.md](../kb-retos-modernizacion-mainframe-banca.md) — 10 capítulos, síntesis de experiencia real incluyendo Proyecto Gamma. Reutilizable para cualquier engagement bancario.
>
> **Análisis técnico completo:** ver [analisis-desempeno-mainframe-a-java.md](analisis-desempeno-mainframe-a-java.md) — catálogo de 9 categorías de causas de degradación (30+ causas específicas), matriz de diagnóstico síntoma→causa, y alternativas estratégicas + patrones técnicos de remediación. Respalda el Performance Diagnosis Assessment.
>
> **Arquitectura de reimplementación:** ver [reimplementacion-batch-java-referencia.md](reimplementacion-batch-java-referencia.md) — cómo se reimplementa un batch de alto volumen en Java (Spring/Jakarta Batch chunk-oriented, partitioning, bulk I/O) sin caer en el anti-patrón chatty. Incluye tabla de mapeo COBOL/JCL→Java y esqueleto de código.
>
> **⚠️ Distinción interno vs. cliente:** los dos documentos anteriores son **inteligencia interna** (mencionan APX, el incumbente y la hipótesis de causa raíz). El documento [enfoque-BBVA-modernizacion-cobol-a-java.md](enfoque-BBVA-modernizacion-cobol-a-java.md) es la versión **client-facing sanitizada**: framework-agnóstica (Java/Spring Boot/Quarkus/Jakarta Batch, **sin mencionar APX**), sin referencias al incumbente, presenta los retos comunes COBOL→Java como punto de vista consultivo. Es el que se comparte con BBVA. Contiene una nota interna que debe borrarse antes de compartir.

### Inteligencia de Campo — Reunión 07-08-2026 (confirmaciones de primera mano)

Reunión semanal "Modernización bancaria Gamma" con Francisco Eduardo Hernandez (BBVA MX) y equipo. Hallazgos confirmados:

#### Sobre el Proyecto Gamma (Contabilidad)
- **"Gamma"** es el nombre interno del proyecto de modernización del bloque de contabilidad. Francisco contó letras, paró en Gamma, "no está bonita pero así se quedó".
- La conversión **funcionó perfectamente en equivalencia funcional** ("conversión perfecta, totalmente cuadrada"), pero **falló en desempeño**. El problema NO es funcional — es de rendimiento puro.
- La causa confirmada del fallo: "le metimos 120 millones de operaciones de contabilidad en un solo programa con N cálculos... no se quedaba sentada la red" → confirma el anti-patrón **N+1 a escala masiva**: la red colapsa con 120M operaciones por-registro.
- Adicionalmente, la conversión de tipos de datos (COMP-3 → tipos Java) genera overhead en cada cálculo: "la conversión de los tipos de datos y regresarlos al formato y volver a regresarlos ese extra llegado en ese cálculo."
- **SORT en servidor dedicado**: probaron la utilería SORT sobre una máquina dedicada con todos los procesadores, sin competencia, sin servicios concurrentes → **corre a ¼ de la velocidad del mainframe**. Inaceptable. El mainframe maneja SORT en hardware; Java/x86 no replica eso.

#### Assets que BBVA Ya Tiene Construidos
- **Procesador JCL / Control-M bridge**: "Ya tenemos un procesador de JTL que funciona a la perfección y se conectamos a Control-M y yo le traduzco cualquier JTL y ya tengo cómo correrlo." Asset propio — el JCL se puede traducir y orquestar vía Control-M.
- **136 millones de líneas de código** de Altamira en GitHub (todo el código aplicativo cargado, organizado por códigos aplicativos).
- **9,000 servicios de línea construidos** (objetivo original era 4,000). Las transacciones online/stateless ya migraron — ese problema está resuelto.
- **DB2 → Oracle migration**: funciona bien. Muy pocos cambios, principalmente tipos de dato. Solo errores de dedo humano, ningún error de conversión técnica.
- **Solución para capa conversacional** (pantallas de terminal = 70% del código): intentaron Angular — fue "un desastre, una cochinada, no se podía mantener." Con agentes de IA se auto-generan las screens y los servicios vaso. Solución funcionando.

#### Arquitectura en 3 Capas — Estado Real
| Capa | Tecnología | Estado | Notas |
|------|-----------|--------|-------|
| **Online (línea)** | Servicios REST stateless | ✅ RESUELTO | 9,000 servicios. Lleva 10-12 años construyéndose. |
| **Conversacional** | Pantallas de terminal CICS (70% del código) | 🔄 EN PROGRESO | Resuelto con agentes IA (CMAT tool, 4 semanas, pantallas funcionando en DEV) |
| **Batch** | Procesos nocturnos masivos (contabilidad, EOD) | ❌ BLOQUEADO | Proyecto Gamma. Performance inaceptable. El mainframe aquí es imbatible. |

#### Portfolio — Sistemas en Backlog (Más Allá de Gamma)
- **150 aplicaciones legacy** identificadas: COBOL, Java antiguo, VIsam-leasing, "hay de todo." Carlos Casas pidió explícitamente considerar este universo.
- **SIVA**: ~50 aplicaciones. Sistemas donde el performance NO es la variable — la complejidad del negocio y la antigüedad son el reto. Lógica de negocio en base de datos.
- **Fiduciarios**: Iniciativa de modernización lanzada. **DETENIDA**. "No vemos claro" — bloqueada, buscando entrada.
- **ST (Metro)**: Arquitectura compleja construida hace 20 años. No es un buen punto de entrada ahora — está en el plan directoral de arquitectura.
- **Medios de pago**: Ya migrados a cloud (fuera de mainframe). Dentro de la estrategia "Blandirector" (nuevo).
- **Proyecto Alfa**: Nueva base de clientes. Construcción nueva desde cero (no migración).

#### Estrategia de Modernización del Banco
- **"Realk" (Realki)**: Estrategia global = lo que se migra + lo nuevo.
  - **Migration lane**: Todo lo que viene de Gamma/Altamira y se moderniza (sigue siendo el mismo negocio).
  - **"Blandirector" lane**: Construcción nueva — Alfa (base de clientes), Medios de Pago, Córbatin. Aquí el banco reconstruye desde cero.
- **Plataforma Calipso**: Plataforma multidivisa considerada como destino alternativo. Si el negocio la adopta, cambia radicalmente el proyecto — es una decisión de negocio, no técnica.

#### Proveedores en el Ecosistema
| Proveedor | Rol | Estado |
|-----------|-----|--------|
| **Kyndryl** | Conversión clásica (determinística) Gamma | Falla de performance. Sigue en el proyecto. |
| **Base100** | Proveedor de conversión determinística masiva ("un botón, 1.5M líneas de código") | Activo. Capacidad probada en volumen pero con los mismos problemas de performance. |
| **Microsoft** | Azure, GitHub Copilot, partner de Darwin Edge | Presente en Holding/España |
| **GFTE** | Consorcio que hizo el piloto Mexico de Gamma | Hizo el piloto local; diferente al piloto España (España solo mostró 2 programas en laptop; Mexico exige pruebas en DEV). |
| **Darwin Edge** | Herramienta modernización de Holding/España | Usa Microsoft tools + Anthropic agents sobre Azure. Piloto sobre CLAN. Silvia y Enrique lo desarrollan. |

#### Dinámica de Decisión y What Accenture Propone
- El cliente quiere **conversión 100% automatizada** — "un programa que yo pico sin que nadie lo toque, tiene que funcionar perfecto." La intervención humana es un riesgo político.
- Ya recibió el análisis de código de Accenture: "la propuesta inicial ya la revisé, se ve bien."
- El siguiente paso es demostrar conversión que funcione en el ambiente DEV del banco — no basta con reportes firmados (eso fue el error de España).
- "Modernizar no es traducir" — dicho explícitamente por el equipo Accenture España en la llamada. Francisco lo valida.
- Galle presentó los 25-526 patrones COBOL→Java (IO, COMP-3, chunking, cursors, caches). Francisco reconoció que ya lo vivieron: "no somos muy buenos, somos un poquito tos y nos equivocamos."

---

### Oportunidad para Accenture

La falla de Kyndryl abre tres vectores de entrada:

1. **Diagnóstico de Performance** (tiempo corto): Proponer un assessment focalizado del bloque de contabilidad en APX. Deliverable: causa raíz + roadmap de remediación. Posicionamiento: "somos los únicos que conocemos el algoritmo original".

2. **Remediación + Continuación** (tiempo medio): Accenture toma el relevo de Kyndryl. Migra correctamente el bloque de contabilidad aplicando patrones de batch adecuados (Spring Batch, AWS Batch, o migración chunk-oriented que replica el modelo COBOL).

3. **Programa completo de Modernización** (largo plazo): El error de Kyndryl valida que la migración de Altamira requiere conocimiento profundo del sistema original. Esto justifica a Accenture como el socio estratégico para el programa completo Altamira → Cloud-native.

---

## Perfil del Engagement

### Por qué BBVA es una Oportunidad Estratégica para Accenture

1. **Origen Accenture de Altamira**: Somos los arquitectos originales del sistema que el banco quiere reemplazar. Nadie conoce mejor el código, la lógica de negocio embebida y los puntos de riesgo.
2. **Escala**: Si el 72% de las transacciones del 2.° banco de México viven en mainframe, el volumen de modernización es masivo. Comparable o mayor que Banamex.
3. **APX como punto de entrada**: APX ya existe como arquitectura de transición — podemos proponer acelerar su evolución hacia microservicios cloud-native sin reescritura completa.
4. **BBVA Roadmap 2029**: El banco tiene un roadmap publicado de transformación hasta 2029, señal de compromiso ejecutivo real.
5. **Regulatorio**: La migración requiere parallel-run extenso (CNBV/Banxico) — trabajo intensivo de integración que Accenture puede ancorar.

### Riesgos del Engagement

| Riesgo | Descripción | Mitigación |
|--------|-------------|-----------|
| Conocimiento propietario APX | APX es tecnología interna BBVA — no existen consultoras externas con experiencia en ella | Reverse Engineering de APX como Etapa 1 de Discover |
| Deuda técnica acumulada en Altamira | 20+ años de parches y evoluciones sobre el COBOL original | Code Quality Assessment (ISO 5055) como gate de entrada |
| Paralelismo regulatorio largo | CNBV exige parallel-run antes de decommission | Planificación de ventana ≥3 meses desde inicio |
| Lockout de talento | Equipos BBVA formados en APX y NextGen — poco conocimiento de Altamira disponible internamente | Knowledge transfer como deliverable explícito |
| BBVA Engineering interno fuerte | BBVA Next Technologies y BBVA Engineering tienen 1,000+ ingenieros — pueden preferir insourcing | Diferenciar con Accenture como co-diseñador de arquitectura, no solo proveedor de capacidad |

---

## Stakeholders Clave (Conocidos)

| Rol | Persona | Relevancia |
|-----|---------|-----------|
| CIO BBVA México | Francisco Leyva | Sponsor ejecutivo de la estrategia NextGen; conductor de la agenda de modernización; IT Master del año (reconocimiento industria) |
| Director Arquitectura / Programa Modernización BBVA MX | **Francisco Eduardo Hernandez** | Líder del Programa Gamma en México. Conoce el detalle técnico profundo de Altamira. Interlocutor principal en la reunión 07-08. Toma decisiones de arquitectura y portfolio. Reporta a Sergio Hidalgo y Beatriz (finanzas). Clave de decisión sobre los 150 sistemas del backlog. |
| Carlos Casas | BBVA | Stakeholder de portfolio; solicitó explícitamente pensar en los sistemas fuera de Gamma — los 150 sistemas legacy. Decisor sobre estrategia de modernización de largo plazo. |
| BBVA Next Technologies | N/D | Entidad de ingeniería del grupo BBVA — puede tener voz en decisiones de arquitectura para México |
| **Accenture MX** | Viridiana Zurita | Organización Accenture MX — misma org que Alejandro Gallegos. Presente en reunión 07-08. |
| **Accenture (técnico)** | "Galle" | Perfil técnico Accenture, conocimiento de patrones COBOL→Java (COMP-3, IO, chunking, cursors). Presentó la propuesta de 25-526 patrones en la reunión 07-08. |
| Silvia / Enrique | BBVA España / Darwin Edge | Desarrollando Darwin Edge — herramienta de modernización con Anthropic agents + Microsoft. Haciendo piloto sobre plataforma CLAN en Holding. |

---

## Contexto Regulatorio Aplicable

| Marco | Aplicación en este proyecto |
|-------|----------------------------|
| CNBV Circular Única de Bancos | Toda migración de sistema core requiere notificación y, en algunos casos, autorización previa |
| Banxico SPEI | La plataforma de pagos interbancarios opera sobre Altamira — la migración de este flujo requiere certificación Banxico |
| CECOBAN | Cámara de compensación — integración regulada que debe certificarse en el nuevo sistema antes de decommission |
| PCI-DSS Nivel 1 | BBVA procesa tarjetas; la nueva arquitectura debe mantener certificación PCI-DSS |
| ISO 27001 | El banco opera bajo este estándar; cambios de arquitectura deben pasar por change management formal |

---

## Fuente del Código

| Sistema | Estado | Ubicación |
|---------|--------|-----------|
| Altamira (COBOL/JCL/VSAM) | Pendiente obtención | `BBVA/Altamira/source/` |
| APX (Java EE services) | Pendiente obtención | `BBVA/APX/source/` |

> Al igual que en Banamex, el código fuente se cargará en `source/` cuando sea proporcionado por el cliente o extraído en engagement activo. Hasta entonces, este CLAUDE.md sirve como contexto de scouting.

---

## Fases del Lifecycle Aplicables

Siguiendo las 8 fases del Solution Delivery Agent de Mainframe Modernization:

| Fase | Nombre | Estado | Notas BBVA-específicas |
|------|--------|--------|------------------------|
| Fase 1 | DISCOVER | Etapa 0 — Scouting | RE de Altamira + RE de APX como dos streams paralelos |
| Fase 2 | REGULATORY | No iniciada | Notificación CNBV · Certificación SPEI · PCI re-scope |
| Fase 3 | TEST & EQUIVALENCE | No iniciada | Comparativa Altamira output ↔ NextGen output |
| Fase 4 | ENCAPSULATE | Parcialmente hecha | APX ya encapsula consultas — extender al resto |
| Fase 5 | MODERNIZE | En progreso (NextGen 28%) | Continuar migración microservicio a microservicio |
| Fase 6 | DATA MIGRATION | No iniciada | VSAM → Postgres/Aurora según dominio |
| Fase 7 | OPS & ECONOMICS | No iniciada | MIPS reduction targets · AWS cost baseline |
| Fase 8 | DECOMMISSION | No iniciada | LPARs + APX servers |

---

## Diferenciadores de Propuesta Accenture

Al posicionarse ante BBVA para este engagement, usar estos diferenciadores **en orden de impacto** dado el contexto Kyndryl:

1. **"Nosotros construimos Altamira — podemos diagnosticar lo que Kyndryl no puede"** — La causa raíz de la degradación de performance en el bloque de contabilidad está en la lógica original de Altamira. Solo Accenture tiene ese conocimiento sin RE desde cero. Esto convierte el assessment de diagnóstico en una oferta de tiempo corto con alto valor demostrable.

2. **Batch accounting expertise** — La migración de batch contable de COBOL a Java tiene patrones conocidos y anti-patrones documentados (N+1, packed decimal, transactional overhead). Accenture HVM tiene playbook específico para esto — Spring Batch con chunk-oriented processing, BigDecimal obligatorio para aritmética financiera, equivalencia de asientos como test de aceptación.

3. **"Nosotros construimos Altamira"** — Reducimos 40–60% el esfuerzo de Reverse Engineering vs. cualquier competidor. Kyndryl tardó 8 meses sin entender el problema; con nuestro conocimiento de Altamira, el diagnóstico se puede hacer en semanas.

4. **Metodología probada en banca MX** — Banamex Unisys (en curso) demuestra el muscle de mainframe banking en México. Dos bancos sistémicos = referencia creíble.

5. **Equivalencia contable como gate de salida** — Nuestro playbook exige equivalencia ≥ 99.99% de salida de asientos contables antes de cualquier cutover. Es el criterio exacto que la migración Kyndryl aparentemente no validó.

6. **Parallel-run regulatorio como disciplina** — Ventana de coexistencia con CNBV/Banxico integrada al plan desde el inicio, no como afterthought.

7. **AI-assisted transpilation con revisión humana obligatoria** — Generative AI acelera la modernización de COBOL → Java; el review humano sobre lógica contable-regulatoria es no negociable (exactamente lo que faltó en el approach de Kyndryl).

---

## Lecciones Aprendidas — Migración COBOL→Java con Agentes de IA (Intel BBVA)

> Hallazgos obtenidos de engagements reales de migración de procesos batch COBOL→Java en BBVA usando agentes de interpretación de funcionalidad. Aplicar como checklist de calidad antes de cualquier entrega de código migrado. Son también hipótesis directas sobre la causa del fallo de Kyndryl.

---

### Funcional — Limitaciones de los Agentes de Interpretación

| # | Hallazgo | Implicación operativa |
|---|----------|----------------------|
| F-01 | **Nombres de variables tomados literalmente**: El agente usa el nombre de la variable COBOL como definición de la regla de negocio en lugar de inferir la regla desde la lógica del código. Genera especificaciones funcionales incorrectas o ambiguas. | Todo output funcional del agente debe ser revisado por un experto en el negocio bancario que valide contra el comportamiento real del programa, no contra su nombre. |
| F-02 | **Complemento con conocimiento general**: Al interpretar el objetivo de un componente, el agente rellena con información genérica de dominio que se aleja de la implementación real. Ejemplo crítico: el cálculo de interés moratorio se documenta con la fórmula general estándar en lugar de replicar la fórmula exacta hardcoded en el COBOL. | En aritmética financiera, la fórmula del agente ≠ la fórmula real = error contable auditable. La fórmula debe extraerse línea a línea del COBOL, no inferirse del dominio. |
| F-03 | **Lógica de negocio embebida en JCL via utilerías**: Hay reglas de negocio que no viven en programas COBOL sino en el control flow de JCL (SORT, JOINKEYS, INCLUDE/OMIT conditions). El agente no tiene contexto para interpretarlas como reglas — las trata como instrucciones técnicas. | Requiere analista con conocimiento de negocio bancario que decodifique la intención de cada step JCL con utilerías. No es automatizable con el agente solo. |

---

### Técnico — Constructs COBOL/JCL con Traducción Problemática

| # | Construct | Problema de traducción | Solución requerida |
|---|-----------|----------------------|-------------------|
| T-01 | **JOINKEYS (SORT utility)** | El agente no replica correctamente el match entre archivos — puede perder registros, duplicar, o no respetar el orden de join. Resultado diferente al COBOL original. | Implementar y verificar la lógica de JOINKEYS como join explícito en Java con prueba de equivalencia registro a registro. |
| T-02 | **Instrucciones propietarias IBM**: `COUNT`, `SKIP`, `NODUP`, `EDIT` (en SORT/DFSORT) | El agente no conoce estas instrucciones de forma nativa — genera código Java que no replica el comportamiento. Requiere entrenamiento explícito por instrucción. | Crear un catálogo de equivalencias IBM-utility → Java para cada instrucción usada en el sistema. |
| T-03 | **`REDEFINES`** | Una misma posición de memoria con tipos de dato diferentes según contexto. El agente genera código Java que no maneja el overlay — puede crear clases separadas que rompen la semántica compartida de memoria. | Entrenar al agente con patrón Union/tagged-union en Java o BitBuffer para replicar el overlay. Validar con test de igualdad de bytes en memoria. |
| T-04 | **`STRING` / `UNSTRING`** | Concatenación y división de strings con delimitadores y manejo de overflow que Java no replica con operaciones estándar. | Implementar helpers Java equivalentes verificados con pruebas de comportamiento borde. |
| T-05 | **`INSPECT`** | Recuento y sustitución de caracteres en posiciones específicas — semántica distinta a `String.replace()` de Java. | Mapear cada uso de INSPECT a su equivalente exacto en Java; no usar traducción automática. |
| T-06 | **`LOW-VALUES` / `HIGH-VALUES`** | Representan el byte mínimo (0x00) y máximo (0xFF) — no tienen equivalente directo en Java String. Se usan como delimitadores, inicializadores y sentinels en comparaciones. | Usar constantes `byte[]` o `char` con valor explícito 0x00/0xFF; nunca traducir a `""` o `null`. |
| T-07 | **Ordenamientos implícitos en utilerías de match** | El SORT/JOINKEYS ordena los archivos antes del match de forma implícita. Si Java no replica ese ordenamiento previo, el resultado del join es diferente aunque la lógica de join sea correcta. | Todo match entre colecciones en Java debe ir precedido del mismo criterio de ordenamiento que usaba la utilería JCL. Documentar el sort key por cada JOINKEYS del JCL. |
| T-08 | **Relación de tiempo COBOL vs. Java: 1:10** | El procesamiento batch en Java es hasta 10× más lento que el COBOL equivalente para el mismo volumen de datos. Esto es el **anti-patrón base** que explica la falla de Kyndryl en el bloque de contabilidad. | Nunca hacer row-by-row processing en Java para lo que el COBOL hacía en modo secuencial de archivo. Usar Spring Batch chunk-oriented, bulk inserts, y streaming en lugar de query-por-registro. |

---

### Pruebas — Retos en la Transición y Validación

| # | Hallazgo | Implicación en QA |
|---|----------|------------------|
| P-01 | **Campos compactados (COMP-3 / Packed Decimal)**: Los archivos de prueba contienen campos en formato packed decimal que Java no lee nativamente. El agente genera código que trata estos campos como texto plano → valores incorrectos desde el primer registro. | Antes de cualquier prueba de equivalencia, se requiere una etapa de **transformación de datos**: convertir los archivos de prueba de COMP-3 a formato legible por Java (o implementar un decoder COMP-3 en el reader). |
| P-02 | **Utilerías IBM reemplazadas por tablas relacionales**: El agente, al no poder replicar la utilería IBM, propone crear tablas en base de datos como sustituto. Esto incrementa la complejidad de la solución, introduce dependencias nuevas, y cambia el modelo de datos. | Evaluar caso a caso si la tabla es el reemplazo correcto o si existe una solución en memoria (collections Java) que preserve la semántica original sin persistencia adicional. |
| P-03 | **`REDEFINES` en pruebas**: Al haber múltiples tipos de dato sobre la misma posición de memoria, los casos de prueba deben cubrir todos los layouts posibles del REDEFINES — el agente tiende a probar solo el layout principal. | Generar casos de prueba explícitos para cada rama de REDEFINES. La cobertura de equivalencia debe incluir todos los tipos de dato del overlay. |

---

### Checklist de Gate de Calidad — Validación Pre-Entrega de Componente Migrado

Aplicar antes de considerar cualquier componente COBOL→Java como listo para parallel-run:

- [ ] Fórmulas financieras verificadas línea a línea contra el COBOL original (no contra documentación genérica)
- [ ] Toda lógica de JCL con utilerías documentada como regla de negocio explícita y aprobada por SME bancario
- [ ] Equivalencias IBM-utility catalogadas y probadas: SORT, JOINKEYS, COUNT, SKIP, NODUP, EDIT
- [ ] REDEFINES implementados como Union/BitBuffer con tests para cada layout
- [ ] STRING/UNSTRING/INSPECT con helpers Java verificados en casos borde
- [ ] LOW-VALUES/HIGH-VALUES con constantes byte explícitas — sin traducción a null/empty
- [ ] Ordenamientos JCL implícitos documentados y replicados en el sort previo al match en Java
- [ ] Archivos de prueba transformados de COMP-3 a formato Java antes de ejecutar equivalencia
- [ ] Procesamiento batch implementado en modo chunk/streaming — prohibido row-by-row JDBC para volúmenes > 10K registros
- [ ] Ratio de tiempo de respuesta COBOL vs. Java medido y dentro de ventana batch aceptable (objetivo: < 3:1; máximo tolerable: 5:1)
- [ ] Equivalencia de output ≥ 99.99% registro a registro antes de habilitar parallel-run

---

## Glosario de Acrónimos y Términos BBVA

| Término | Significado | Contexto |
|---------|-------------|---------|
| **Altamira** | Core bancario mainframe COBOL/JCL/VSAM de BBVA México | Construido por Accenture ~2000–2003; ~72% del volumen transaccional |
| **APX** | Arquitectura Plataforma Extendida — middleware Java EE interno BBVA | Capa de desacoplamiento del mainframe; ya considerado legacy generacional |
| **NextGen** | Arquitectura target cloud-native de BBVA (microservicios Java + AWS) | ~28% del volumen transaccional; roadmap 2029 |
| **Gamma** | Nombre interno del proyecto de migración del bloque de contabilidad Altamira→APX | Liderado por Francisco Eduardo Hernandez; Kyndryl incumbente; bloqueado por performance |
| **BTS** | Bancomer Transfer Services — subsidiaria de BBVA para transferencias internacionales y remesas | Sistema relevante dentro del portfolio Altamira por volumen de remesas |
| **SIVA** | Grupo de ~50 aplicaciones legacy BBVA (lógica de negocio compleja en base de datos) | No es performance el reto — complejidad y antigüedad; candidato a modernización post-Gamma |
| **Calipso** | Plataforma multidivisa considerada como destino alternativo para algunos dominios | Si el negocio la adopta, cambia el scope del proyecto — decisión de negocio, no técnica |
| **Realk / Realki** | Nombre interno de la estrategia global de modernización BBVA | Dos lanes: Migration (Gamma/Altamira) + Blandirector (Alfa, Medios de Pago, nuevos) |
| **Blandirector** | Lane de construcción nueva dentro de Realk | Alfa (base de clientes), Medios de Pago, Córbatin — construcción desde cero, no migración |
| **Alfa** | Nuevo sistema de base de clientes (construcción nueva, no migración) | Parte del lane Blandirector |
| **CMAT** | Herramienta con agentes IA para auto-generación de screens conversacionales | Soluciona capa conversacional (70% del código); 4 semanas, pantallas funcionando en DEV |
| **Darwin Edge** | Herramienta de modernización de Holding/España (Microsoft + Anthropic agents) | Piloto sobre plataforma CLAN; desarrollada por Silvia/Enrique de BBVA España |
| **CLAN** | Plataforma BBVA donde Darwin Edge hace su piloto en España | N/D |
| **Base100** | Proveedor de conversión determinística masiva ("un botón, 1.5M líneas") | Tiene los mismos problemas de performance que Kyndryl en batch |
| **GFTE** | Consorcio que hizo el piloto Mexico de Gamma | Diferente al piloto España; México exige pruebas en DEV |

---

## Historial del Proyecto

| Fecha | Evento |
|-------|--------|
| 2026-07-07 | Creación inicial del proyecto — contexto basado en scouting web e inteligencia de mercado. Sin engagement activo. |
| 2026-07-07 | Inteligencia de campo: Kyndryl lleva ~8 meses migrando bloque de contabilidad a APX con degradación severa de desempeño. Causa raíz desconocida. Deal Stage actualizado a oportunidad activa. |
| 2026-07-07 | Lecciones aprendidas de engagement real BBVA: 11 hallazgos técnico-funcionales de migración COBOL→Java con agentes de IA documentados (F-01 a F-03, T-01 a T-08, P-01 a P-03) + checklist de gate de calidad pre-parallel-run. |
| 2026-07-07 | Creado `analisis-desempeno-mainframe-a-java.md`: catálogo completo de causas de degradación mainframe→Java (9 categorías, 30+ causas) + alternativas estratégicas y patrones técnicos de remediación para BBVA. |
| 2026-07-07 | Creado `reimplementacion-batch-java-referencia.md`: arquitectura de referencia de cómo reimplementar batch de alto volumen en Java (chunk-oriented, partitioning, bulk I/O), tabla de mapeo COBOL/JCL→Java y esqueleto de código. |
| 2026-07-07 | Creado `enfoque-BBVA-modernizacion-cobol-a-java.md`: documento **client-facing** framework-agnóstico (sin APX ni incumbente) con los 8 retos comunes COBOL→Java y el enfoque Accenture. Versión sanitizada para compartir con el cliente. |
| 2026-07-08 | Creados dos artefactos visuales client-facing con marca Accenture oficial (logo de `Solutioning/Design - Studio/logos/` embebido base64): `patrones-arquitecturas-cobol-java.html` (documento de referencia con scroll, tema claro/oscuro) y `deck-modernizacion-cobol-java-BBVA.html` (deck 16:9 de 7 slides siguiendo el Design System — panel Ancla + barra Señal 3px, morado #6B21A8/#A100FF, 2 pesos tipográficos, sin pills). Ambos framework-agnósticos. |
| 2026-07-08 | **Reunión semanal con BBVA (Francisco Eduardo Hernandez).** Inteligencia de primera mano incorporada: (1) "Proyecto Gamma" = nombre interno de la migración de contabilidad; (2) Falla confirmada: 120M operaciones de contabilidad → red colapsada (N+1 a escala); (3) SORT en servidor dedicado = ¼ velocidad mainframe; (4) Tipo de datos COMP-3 → overhead en cada cálculo; (5) JCL translator + Control-M bridge ya existe como asset BBVA; (6) 136M líneas de código Altamira en GitHub; (7) Online transactions resueltas (9,000 servicios); (8) Capa conversacional en progreso con agentes IA (CMAT); (9) Portfolio: 150 sistemas legacy, SIVA (50 apps), Fiduciarios (bloqueado), Alfa, Medios de Pago; (10) Proveedores: Kyndryl + Base100 + Microsoft + Darwin Edge (Spain) + GFTE; (11) Cliente quiere conversión 100% automatizada, sin intervención humana; (12) Análisis de código Accenture recibido favorablemente; next step: demostrar conversión en ambiente DEV. Stakeholders nuevos: Francisco Eduardo Hernandez (Director Arquitectura/Programa MX), Carlos Casas (decisor portfolio), Viridiana Zurita y "Galle" (Accenture MX). |

---

*Última actualización: 2026-07-08 · v0.8 · Inteligencia de primera mano de reunión con BBVA incorporada (Proyecto Gamma, arquitectura 3 capas, portfolio 150 sistemas, proveedores, stakeholders). v0.7: Artefactos visuales client-facing (HTML referencia + deck 16:9) con marca Accenture del Design Studio.*
