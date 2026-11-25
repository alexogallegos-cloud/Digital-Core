# retail-brain — Cerebro Empresarial de OXXO

> Brain de nivel cliente. Agente de segundo orden: agrega y razona sobre el negocio de la empresa y sobre los brains de sistema cuando existan.
> Hereda el asset `00 - Enterprise Brain/` y sus 45 reglas de canon. Hereda también el `CLAUDE.md` de `03 - SPE/HVM/AM/`.

---

## Definición del brain

Citando al asset, sin parafrasear: *el Enterprise Digital Brain es el gemelo cognitivo de una empresa. Es un motor de razonamiento que entiende cómo funciona el negocio y la tecnología que lo habilita, y con ese entendimiento explica, anticipa y aconseja.*

Este brain no es una memoria ni un repositorio de documentos sobre OXXO. El conocimiento que guarda es la evidencia con la que razona, y hoy esa evidencia es escasa y pública. Decirlo es parte de lo que el brain hace.

---

## Declaración canónica

| Campo de `system_info` | Valor | Regla |
|------------------------|-------|-------|
| `slug` | `oxxo-retail-brain` | — |
| `brain_name` | `retail-brain` | B18 |
| `brain_type` | `enterprise` | B14 |
| `hemisphere` | `change` y `run` | B13 |
| `industry` | `retail` | B18 |
| `industry_sme` | `SME/Industry/Industry Retail/` | B19 |
| `itom_sme` | `SME/Framework/IT Operating Model/` | B23 |
| `capability_model` | Retail ETB v5.0, con extensión propia de la empresa | B2 |
| `lob_dimension` | No aplica. Retail no tiene eje de ramo, aunque sí categoría y departamento | B19 |
| `source_of_truth` | `knowledge-base/` | P1 |
| `status` | `discovered` | §20 |
| `version` | `0.1.0` | §17 |
| `build_agent` | Enjambre de 24 Digital Twins canónicos | B29, B41 |

La extensión que corresponde a `brain_type = enterprise` es `federated_brains` y `documents`, exactamente una y no más (Regla B15). El CORE son las 25 tablas que enumera B15 y el DDL vive en `00 - Enterprise Brain/templates/schema.sql`, que es la única fuente de verdad y nunca se transcribe aquí (ADR-EB-006).

---

## Ontología declarada

Esta empresa compone su ontología de más de una industria, que es la norma y no la excepción (Regla B20). El caso probado del estate es Liverpool, y conviene leerlo antes de cargar los bindings.

| Binding | Tipo | Rol | Estado |
|---------|------|-----|--------|
| Retail ETB v5.0 | `etb` | primary | Disponible en `SME/Industry/Industry Retail/source/` |
| Extensión propia de la empresa | `etb` | primary | Por construir. Son las capabilities que el ETB base no cubre, marcadas con `is_extension` |
| Servicios financieros | `etb` | secondary | Disponible en el estate por la instancia Liverpool, 50 capabilities L3 |
| IT Operating Model | `it-capability` | — | Disponible en el SME |
| Cadena de valor de retail, de planear a servir | `value-chain` | — | Disponible en el asset |
| Marco regulatorio del comercio en México | `regulatory` | — | **Hueco por verificar.** PROFECO, SAT, COFEPRIS y el régimen estatal de alcohol y tabaco no aparecen resueltos en el Industry Retail SME |

El último renglón es el candidato a brecha bloqueante de la primera ronda, análogo al que tuvo Banco Ripley con Chile. La diferencia es que aquí la mitad financiera sí está resuelta: CNBV, Banco de México y CONDUSEF viven en el Industry Banking SME con su capa mexicana. Lo que falta verificar es la mitad de comercio. Antes de declararlo hueco definitivo hay que preguntarle al Industry Retail SME, no suponerlo desde el listado de archivos.

---

## Qué aplica y qué no en este nivel

Las cuatro capas del gemelo cognitivo, Lenguaje, Almas, Biografía e Intención, no aplican a un brain de nivel empresa. Aplican por sistema, cuando haya código fuente, y cada sistema abrirá su propio brain de tipo `system` bajo `../systems/`.

Lo que sí aplica aquí es el conocimiento de nivel empresa: quién es la compañía, qué la mueve, qué capabilities declara su ontología, qué procesos las realizan y qué sistemas las implementan. Ese conocimiento no ata a un proceso de negocio y no debe inventársele uno: ancla en `company_profile`, que es la excepción cerrada de ADR-EB-017 a la Regla B22.

---

## Estado del brain

| Artefacto | Estado |
|-----------|--------|
| Estructura canónica | Creada el 2026-11-20 |
| Estudio histórico, Regla B26 | [`knowledge-base/history/estudio-historico.md`](knowledge-base/history/estudio-historico.md), versión 0.1 con 26 hechos y 17 huecos |
| `schema.sql`, `build-retail-brain.py`, `retail-brain.py` | Pendientes. Se instancian desde `00 - Enterprise Brain/templates/` |
| `retail-brain.db` | No existe todavía |
| Roster de Digital Twins | Pendiente. Se instancia desde `templates/roster-dt.md` a `dt/roster-dt.md` |
| Catálogo de fuentes | Pendiente |
| Portal | Pendiente. Nunca se escribe a mano, siempre se genera desde el brain |

---

## Carpetas

| Carpeta | Qué guarda |
|---------|-----------|
| `source/` | Artefactos originales del cliente, de solo lectura, en `code/`, `docs/` y `ops/` |
| `knowledge-base/` | Corpus curado: historia, metodología, ontología, regulación, reglas y vocabulario |
| `dt/` | Digital Twins de este brain, siempre en minúsculas |
| `generators/` | Scripts de análisis y enriquecimiento, re-ejecutables y versionados |
| `seeds/` | Evidencia que este brain emite hacia sus vecinos, Regla B11 |
| `portal/` | Visualizaciones generadas desde el brain, nunca escritas a mano |
| `old/` | Archivado. Nunca se borra nada, se mueve aquí |

El builder nunca lee `source/` directo: lee el corpus curado de `knowledge-base/`, y quien cruza ese primer tramo es un extractor (Regla P1, ADR-EB-015).

---

*Creado 2026-11-20. Instanciado desde la semilla del asset Enterprise Brain.*
