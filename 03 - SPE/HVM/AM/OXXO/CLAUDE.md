# OXXO — Application Modernization Project Agent

> Hereda `CLAUDE.md` de `03 - SPE/HVM/AM/` y, por referencia, las reglas universales de Digital Core.
> Asset que gobierna el conocimiento: `00 - Enterprise Brain/`. Canon aplicable: `canon/brain-rules.md`, 45 reglas.

```
# project_type: enterprise-situation-analysis
# project_state: active
# platform: [DATO-REQUERIDO] plataforma de punto de venta y ERP por confirmar
# horizon_present: [DATO-REQUERIDO] landscape sin evidencia cargada
# horizon_future: [DATO-REQUERIDO]
# replaces_or_complements: —
```

---

## Qué es esta carpeta

El proyecto de conocimiento de **OXXO**. Hoy tiene un solo alcance activo: construir el gemelo cognitivo de la empresa y, con él, el análisis de su situación. No hay programa de modernización contratado ni sistemas con código fuente cargado.

La inteligencia vive en `retail-brain/`, que es el brain de nivel cliente, de tipo `enterprise`, y federa los brains de sistema y de proyecto cuando existan. El nombre lo fija la industria ancla y no el cliente, conforme a la Regla B18. Las carpetas `systems/` y `projects/` están creadas y vacías a propósito: se pueblan cuando la evidencia demuestre la existencia de cada sistema (Regla B8) y no antes.

---

## Identidad del cliente

| Campo | Valor | Nivel |
|-------|-------|-------|
| Entidad | OXXO, cadena de tiendas de proximidad | gold |
| Razón social | [DATO-REQUERIDO] por confirmar en registro público | — |
| Grupo | FEMSA, Fomento Económico Mexicano, emisora en la Bolsa Mexicana de Valores y con reportes ante la Securities and Exchange Commission | gold |
| Unidad de negocio del grupo | Proximity Americas | silver |
| Industria ancla | Retail de proximidad | gold |
| Industria secundaria | Servicios financieros, por la corresponsalía bancaria y la cuenta Spin by OXXO | silver |
| Reguladores del régimen de consumo | PROFECO y SAT | gold |
| Reguladores del régimen financiero | CNBV, Banco de México y CONDUSEF | gold |
| Regulador sanitario | COFEPRIS, aplicable a las farmacias del grupo | silver |
| Régimen de venta de alcohol y tabaco | Estatal y municipal, distinto por entidad federativa | silver |
| Escala de la operación en México | 24,759 tiendas al cierre de septiembre de 2026 | silver |
| Geografía del brain | [DATO-REQUERIDO] México confirmado como mercado principal; falta decidir si el alcance incluye Sudamérica y Valora | — |

El nivel de cada afirmación es el de la Regla B37 y se registra en `knowledge_lineage` cuando el brain se construya. Nada de lo marcado gold describe la tecnología de la empresa: a esa altura, hoy, no hay nada gold.

---

## La frontera que define a este cliente

En Banco Ripley la frontera fue el país. Aquí es la composición de la ontología.

OXXO no es un retailer puro y tampoco es una institución financiera. Opera como el principal corresponsal bancario del país y emite una cuenta de fondos de pago electrónico, lo que mete capacidades supervisadas por CNBV, Banco de México y CONDUSEF dentro de una empresa cuya industria ancla es el comercio. La consecuencia operativa la fija la Regla B20: la ontología se compone de `retail` como primaria y `financial_services` como secundaria, cada capability carga su propia regulación, y el nombre del brain no cambia por la composición. El caso probado en el estate es Liverpool, y conviene leerlo antes de declarar los bindings.

Hay una segunda frontera, con el grupo. FEMSA tiene otras unidades, entre ellas el embotellador de Coca-Cola, y una de ellas ya aparece en `Solutioning/Proposals - Clients/Coca Cola`. Este brain es de OXXO, no de FEMSA. Si el alcance se extiende al grupo, eso es una decisión que cambia la federación y se toma con ADR, no por acumulación.

---

## Estructura

```
OXXO/
├── CLAUDE.md                  ← este archivo
├── retail-brain/              ← brain de nivel cliente, tipo enterprise (Regla B18)
├── systems/                   ← hemisferio Run, por tipo TOGAF (vacío a propósito)
│   ├── core/ processors/ channels/ data/ integration/ compliance/
└── projects/                  ← hemisferio Change (vacío a propósito)
```

---

## Estado

| Fase del Brain Lifecycle | Estado | Fecha |
|--------------------------|--------|-------|
| DISCOVER, Brain Bootstrap | En curso | 2026-11-20 |
| DESIGN, Knowledge Architecture | No iniciada | — |
| BUILD, Brain Population | No iniciada | — |

Avance de DISCOVER al 2026-11-20: estudio histórico de la Regla B26 completo en su versión 0.1, con veintiséis hechos fechados y diecisiete huecos declarados. Estructura canónica creada. Falta instanciar el pipeline del brain desde las plantillas del asset.

Corpus fuente disponible al 2026-11-20: solo información pública. Ningún documento del cliente, ninguna entrevista, ningún código.

---

## Decisiones abiertas

Tres, y ninguna se resuelve leyendo el repositorio.

La primera es si OXXO permanece como cliente propio o pasa a colgar de una carpeta FEMSA, lo que cambiaría la forma de la federación si entra otra unidad del grupo. La segunda es qué fuentes habrá realmente: código, documentación de arquitectura, inventario de sistemas, tickets de operación, o solo lo público. La tercera es si existe un programa de transformación concreto, que abriría el hemisferio Change en `projects/`, o si el alcance es la foto del estate operativo y vive todo en Run.

---

*Creado 2026-11-20. Instanciado desde la semilla del asset Enterprise Brain.*
