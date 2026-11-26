# BanBajío — Application Modernization Project Agent

> Hereda `CLAUDE.md` de `03 - SPE/HVM/AM/` y, por referencia, las reglas universales de Digital Core.
> Asset que gobierna el conocimiento: `00 - Enterprise Brain/`. Canon aplicable: `canon/brain-rules.md`, 45 reglas.

```
# project_type: enterprise-situation-analysis
# project_state: active
# platform: [DATO-REQUERIDO] núcleo bancario sin fuente pública
# horizon_present: [DATO-REQUERIDO] landscape sin evidencia cargada
# horizon_future: [DATO-REQUERIDO]
# replaces_or_complements: —
```

---

## Qué es esta carpeta

El proyecto de conocimiento de **Banco del Bajío**. Hoy tiene un solo alcance
activo: construir el gemelo cognitivo del banco y, con él, el análisis de su
situación. No hay programa de modernización contratado ni sistemas con código
fuente cargado.

La inteligencia vive en `bank-brain/`, que es el brain de nivel cliente, de tipo
`enterprise`, y federa los brains de sistema y de proyecto cuando existan. El
nombre lo fija la industria ancla y no el cliente, conforme a la Regla B18. Las
carpetas `systems/` y `projects/` están creadas y vacías a propósito: se pueblan
cuando la evidencia demuestre la existencia de cada sistema (Regla B8) y no
antes.

---

## Identidad del cliente

| Campo | Valor | Nivel |
|-------|-------|-------|
| Razón social | Banco del Bajío, S.A., Institución de Banca Múltiple | silver |
| Nombre de mercado | BanBajío | silver |
| Fundación | 1994, León, Guanajuato | bronze, tres fuentes dan tres fechas |
| Régimen | Emisora en la Bolsa Mexicana de Valores desde el 8 de junio de 2017 | silver |
| Industria ancla | Banca múltiple | silver |
| Segmentos | Empresas, pequeña y mediana empresa, agronegocios, gobierno y personas | silver |
| Reguladores | CNBV, Banco de México, CONDUSEF, IPAB y UIF | gold, por regulación publicada |
| Geografía del brain | México | silver |
| Cartera de crédito | 312,368 millones de pesos al 30 de septiembre de 2026 | silver |
| Depósitos | 310,315 millones de pesos al 30 de septiembre de 2026 | silver |
| Posición declarada | Octavo del sistema por activos, tercero de control mexicano | silver |

El nivel de cada afirmación es el de la Regla B37 y está registrado en
`knowledge_lineage`. Nada de lo marcado gold describe la tecnología del banco: a
esa altura, hoy, no hay nada por encima de bronze.

---

## La frontera que define a este cliente

En Banco Ripley la frontera fue el país y en OXXO la composición de la
ontología. Aquí es otra: **el modelo de negocio, no la escala**.

BanBajío es un banco mediano por tamaño y atípico por composición. Su cartera no
es de consumo masivo sino de empresa, productor agropecuario y gobierno, y buena
parte del crédito agropecuario llega al productor pequeño por un segundo
intermediario, con fondeo y garantías de banca de desarrollo de segundo piso. Eso
tiene dos consecuencias que condicionan el brain entero.

La primera es ontológica. El Banking ETB V5.0 no modela banca de segundo piso ni
el canal de agentes parafinancieros, de modo que las dos capacidades centrales
del diferenciador de este banco entraron como extensiones propias y no como
capacidades del catálogo. Es brecha del modelo global frente al mercado
mexicano, del mismo tipo que la ausencia de remesas que el Industry SME ya
documentó, y sube a ese SME como patrón anonimizado, nunca como caso del cliente
(Regla B42).

La segunda es de arquitectura. Un banco cuyo expediente de crédito y cuya
verificación ocurren fuera de la sucursal tiene integraciones con terceros donde
otro banco tiene pantallas. Dónde vive el riesgo y dónde la trazabilidad son
preguntas de sistemas, no de negocio, y hoy no tienen respuesta.

Hay además una hipótesis de origen que vale la pena verificar temprano, porque
si se confirma cambia la conversación de modernización: no hay fusiones ni
adquisiciones en el corpus público, y el banco nació en 1994. Un banco sin
historia de integraciones y sin plataformas heredadas de los años setenta no
tiene por qué cargar la deuda que define el estate de sus comparables.

---

## Frontera con los demás clientes del estate

BanCoppel también es banca mexicana ligada a una red de retail, y Banco Ripley es
su análogo chileno. La Regla B42 prohíbe que el conocimiento de un cliente cruce
al brain de otro. De esos dos se toma método, nunca dato.

Lo que sí se hereda, y es la gran diferencia frente a Banco Ripley, es la **capa
México del Industry Banking SME**, que está resuelta: 261 capacidades L3 del
Banking ETB V5.0, el catálogo L4 de banca mexicana con 271 operaciones en 26 L3,
la taxonomía de 89 productos de banca múltiple y el mapa de los seis supervisores
del sistema financiero. En Chile esa capa no existía y era la brecha bloqueante
de aquel brain. Aquí no lo es.

---

## Estructura

```
BanBajio/
├── CLAUDE.md                  ← este archivo
├── bank-brain/                ← brain de nivel cliente, tipo enterprise (Regla B18)
├── systems/                   ← hemisferio Run, por tipo TOGAF (vacío a propósito)
│   ├── core/ processors/ channels/ data/ integration/ compliance/
└── projects/                  ← hemisferio Change (vacío a propósito)
```

---

## Estado

| Fase del Brain Lifecycle | Estado | Fecha |
|--------------------------|--------|-------|
| DISCOVER, Brain Bootstrap | En curso | 2026-11-25 |
| DESIGN, Knowledge Architecture | No iniciada | — |
| BUILD, Brain Population | No iniciada | — |

Avance de DISCOVER al 25 de noviembre de 2026: estructura canónica creada,
estudio histórico de la Regla B26 en su versión 0.1 con cinco dimensiones
cubiertas, catálogo de fuentes levantado con siete activas y siete ausentes, y
`bank-brain.db` construida y operativa con 128 afirmaciones con linaje, 28
procesos del modelo operativo y 22 huecos declarados.

Corpus fuente disponible: solo información pública. Ningún documento del
cliente, ninguna entrevista, ningún código.

---

## Decisiones abiertas

Tres, y ninguna se resuelve leyendo el repositorio.

La primera es si hay un pursuit o una relación comercial detrás, porque eso
decide si el brain sirve para preparar una conversación o para sostener un
programa. La segunda es qué fuentes del cliente serán realmente accesibles:
mientras el corpus siga siendo público, el brain conoce el negocio y no la
tecnología, y esa frontera no se mueve por insistir. La tercera es si el alcance
incluye solo al banco o también a sus subsidiarias, lo que cambiaría la forma de
la federación y se decide con un ADR, no por acumulación.

---

*Creado 2026-11-25. Instanciado desde la semilla del asset Enterprise Brain.*
