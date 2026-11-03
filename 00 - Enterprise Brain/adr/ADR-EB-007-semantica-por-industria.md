# ADR-EB-007 — La industria determina la semántica del brain

> Estado: **APROBADO** · Fecha: 2026-09-29 · Asset: Enterprise Brain · Digital Core


<!-- PROPAGACION
templates/schema.sql :: ontology_bindings
canon/brain-rules.md :: ontology_bindings
-->

---

## Contexto

Al adoptar el canon v2.0 (ADR-EB-006) quedó abierta una divergencia de
nomenclatura: el brain de nivel cliente usa dos convenciones incompatibles.

| Convención | Ejemplos |
|-----------|----------|
| Semántica por industria | `bank-brain` (BanCoppel) · `retail-brain` (Coppel) |
| Nominal por cliente | `liverpool-brain` · `axa-brain` · `monex-brain` · `santander-brain` |

La pregunta parecía cosmética. No lo es: al auditar el estate, la evidencia
mostró que **la industria determina toda la semántica del brain**, y que los
brains construidos para industrias distintas divergieron precisamente en las
dimensiones que la industria gobierna.

### Evidencia

**El brain de AXA (seguros) necesitó estructuras que ningún brain bancario
tiene.** Su tabla `pain_points` lleva 11 columnas `lob_*` (suscripción,
reaseguro facultativo, emisión, property, ramos técnicos, RC, marítimo,
aviación, obras de arte, líneas financieras) y `systems.lob`. Eso no es
capricho del implementador: el SME `Industry Insurance` está organizado por
ramo (P&C, Vida-AP, Salud-GMM, Fianzas) y **cada ramo trae su propio ETB**
(P&C Insurance ETB v3.0, Life Insurance ETB v2.0). En seguros el ramo es el eje
raíz. En banca ese eje no existe.

**Las ontologías de procesos son incompatibles entre industrias**, y no se
derivan de la ontología de capabilities:

| Industria | Ontología de procesos | Fuente verificada |
|-----------|----------------------|-------------------|
| Banca | Por producto financiero, anclado a ETB numerado: Captación (3.2), Crédito al Consumo (3.3), Saldos (3.17), Intereses y Comisiones (3.15), Disputas (3.18) | `Industry Banking/knowledge_base/kb-banking-procesos-*.md` |
| Seguros | Ramo primero, luego ciclo de póliza: suscripción → emisión → siniestro → reaseguro | `Industry Insurance/{P&C,Vida-AP,Salud-GMM,Fianzas}/` |
| Retail | Cadena de valor por fases: PLAN (MFP, OTB, Assortment) → BUY → MOVE → SELL → SERVE | `Industry Retail/mapping-procesos-retail-*.md` |

**Liverpool probó que las ontologías se componen, y que la composición es la
norma.** Es retail con brazo financiero (Base24, Card-Wizard, VPL Vision-Plus,
FICO TRIAD). Su brain no eligió una ontología ni le agregó un parche: compuso
la suya a partir de los ETB que le corresponden.

| `source_etb` | Catálogo | Versión | L3 |
|-------------|----------|---------|-----|
| `retail` | Retail_ETB_V4 | 5.0 | 171 |
| `retail` | **Newly Added** (extensión propia) | 5.0 | **61** |
| `financial_services` | financial_services | 1.0 | 50 |

Los 61 "Newly Added" son capabilities de Liverpool que no existen en el ETB
base. La ontología de una empresa es **los ETB que le corresponden más sus
extensiones propias** — no un catálogo heredado tal cual.

Además, las 50 capabilities FSV cargan `regulation: ["CONDUSEF","Banxico"]`
dentro de una empresa de retail. **La regulación viaja con la capability, no
con la empresa.**

Dos bancos comparten vocabulario, capabilities, procesos y regulador. Un banco
y una aseguradora no comparten ninguno de los cuatro. Nombrar el brain por
cliente oculta lo que el brain realmente es.

---

## Decisión

**1. El brain de nivel `enterprise` se nombra por industria: `{industria}-brain`.**

| Industria | Brain | Clientes |
|-----------|-------|----------|
| Banca | `bank-brain` | BanCoppel · Banamex · Santander · MONEX · Gentera |
| Seguros | `insurance-brain` | AXA |
| Retail | `retail-brain` | Liverpool · Coppel |

Se retira la convención nominal por cliente (`liverpool-brain`, `axa-brain`,
`monex-brain`, `santander-brain`).

**2. La semántica la suministra el Industry SME, no el brain.** El brain no
inventa vocabulario, capabilities ni procesos de su industria: los toma del SME
correspondiente en `SME/Industry/`, declarado en `system_info.industry_sme`.
Existen 18 Industry SMEs con modelo lógico
Dominio→Subdominio→Capacidad→Proceso→Regla, mapa de capacidades, regulación,
core típico, vocabulario y KPIs. Duplicar eso dentro del brain es divergencia
garantizada.

**3. Capabilities y procesos son ontologías separadas y ambas se declaran.**
`system_info` gana cuatro campos:

| Campo | Qué declara |
|-------|-------------|
| `industry` + `industry_sme` | Binding a la autoridad semántica |
| `capability_model` + `capability_version` | Qué sabe hacer el negocio |
| `process_ontology` + `process_ontology_version` | Cómo opera el negocio |
| `lob_dimension` | Eje de ramo/línea de negocio, o NULL si la industria no lo tiene |

**4. Nueva tabla `processes`** en el schema canónico, con jerarquía genérica
L1-L4 y columna `lob`. Es el modelo de la industria. Se distingue de `journeys`,
que son las trazas reales por el código.

| Tabla | Qué contiene | Pregunta que responde |
|-------|-------------|----------------------|
| `capabilities` | Modelo de capacidades | ¿Qué sabe hacer el negocio? |
| `processes` | Ontología de procesos de la industria | ¿Cómo debería operar? |
| `journeys` | Trazas por el call graph (entry point → cadena) | ¿Qué hace de hecho el sistema? |

**La brecha entre `processes` y `journeys` es hallazgo de negocio**, no error de
datos: un proceso sin journey que lo realice es una capacidad declarada sin
soporte en el código; un journey sin proceso es funcionalidad no documentada.

**5. `lob_dimension` se deja NULL cuando la industria no tiene ese eje.** No se
inventa un eje que no existe.

**6. Cada empresa tiene su propia ontología, compuesta (Regla B20).** La
multi-industria es la norma, no la excepción. Nueva tabla CORE
`ontology_bindings` declara la composición: qué ETB corresponden a la empresa,
en qué rol (`primary` / `secondary`), con qué versión, qué reguladores trae cada
uno y cuántas capabilities son base vs. extensión propia.

- Exactamente una ontología lleva `role='primary'` — es la que fija el nombre
  del brain (Regla B18). Liverpool sigue siendo `retail-brain` aunque componga
  dos ontologías.
- `capabilities.ontology` registra lo que de hecho está cargado;
  `capabilities.is_extension` marca las capabilities propias de la empresa.
- Declaración y carga deben coincidir: el Brain Auditor falla si hay una
  ontología cargada sin declarar.

---

## Consecuencias

**Positivas**
- El nombre del brain dice qué semántica carga. Un loader genérico puede
  resolver ontología, regulador y vocabulario desde `system_info.industry`.
- La composición cross-industria queda soportada y documentada (caso Liverpool),
  en vez de resolverse ad hoc en cada cliente.
- Se elimina la duplicación entre el asset y los 18 Industry SMEs: el brain
  consume, no reimplementa.

**Negativas / costo asumido**
- Cuatro brains de nivel cliente deben renombrarse: `liverpool-brain` y el
  scaffold `retail-brain` de Coppel convergen en `retail-brain`; `axa-brain` →
  `insurance-brain`; `monex-brain` y `santander-brain` → `bank-brain`.
  El rename es de carpeta y archivo; los datos no cambian.
- Todo brain debe declarar su composición de ontologías en `ontology_bindings`
  antes de cargar capabilities. Ninguno de los 16 brains del estate lo hace hoy.

**Neutras**
- `.gitignore` ya cubre el patrón `**/*-brain/*-brain.db`, que sigue siendo
  válido tras el rename.

---

## Alternativas consideradas

- **Nombrar por cliente en todos los casos.** Rechazada: el nombre no comunica
  la semántica y obliga a abrir el brain para saber qué ontología usa. Además
  multiplica los nombres sin agregar información — el cliente ya está en la ruta
  (`AM/{Cliente}/`).

- **Nombre genérico `client-brain` para todos.** Rechazada: pierde la
  información que sí importa para resolver la ontología, y reintroduce el
  problema que ADR-EB-006 resolvió — un contrato que no distingue lo que de
  hecho difiere.

- **Una sola ontología de procesos para todo el estate.** Rechazada por la
  evidencia: los tres modelos verificados no son reconciliables sin perder
  significado. Forzar el modelo bancario sobre seguros elimina el eje de ramo,
  que en seguros es la raíz.

---

*Relacionado: ADR-EB-006 (canon v2.0) · Reglas B18, B19 · `SME/Industry/`*
