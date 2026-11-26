# Catálogo de fuentes — bank-brain de BanBajío

> `ADR-EB-014` y `ADR-EB-015`. Dueño: `dt-source-steward`.
> Este archivo manda mientras el brain esté en DISCOVER. Desde la primera carga
> manda la tabla `source_catalog` dentro de `bank-brain.db`.

El catálogo se levanta antes de poblar nada. La razón es que una ausencia no
declarada se ve exactamente igual que un silencio, y la diferencia entre no
saber y no haber mirado es la única que le da valor a lo que el brain sí
afirma. Cada fuente marcada como ausente genera su propio hueco en
`knowledge_gaps` al construir, sin que nadie tenga que acordarse.

El nivel natural de cada fuente no se captura a mano: lo deriva la tabla F2 del
pipeline a partir del tipo. Un documento sin fecha ni autor no puede sostener
una afirmación gold por mucho que convenga.

## Estado al 25 de noviembre de 2026

Siete fuentes activas, todas públicas. Siete ausentes, todas del cliente. Esa
proporción es el retrato honesto del brain hoy: sabe lo que BanBajío publica de
sí mismo y no sabe nada de su tecnología por dentro.

| id | name | source_type | generator_type | cadence | status | natural_tier | coverage_pct | last_refresh | enables |
|----|------|-------------|----------------|---------|--------|--------------|--------------|--------------|---------|
| SRC-001 | Reportes trimestrales de resultados de la emisora | doc_tecnico | parser | batch | activa | silver | 100 | 2026-10-28 | Cifras de cartera, depósitos, utilidad y capitalización |
| SRC-002 | Eventos relevantes ante la Bolsa Mexicana de Valores | firmado | parser | continuo | activa | gold | 100 | 2026-11-25 | Hitos de gobierno corporativo y cambios de estructura |
| SRC-003 | Reporte Anual presentado ante la Bolsa Mexicana de Valores | firmado | parser | batch | activa | gold | 100 | 2026-04-30 | Modelo de negocio, segmentos y gestión de riesgo |
| SRC-004 | Sitio institucional del banco | doc_sin_linaje | parser | bajo demanda | activa | bronze | 60 | 2026-11-25 | Catálogo comercial por línea y red de distribución |
| SRC-005 | Prensa financiera mexicana | doc_sin_linaje | parser | bajo demanda | activa | bronze | 40 | 2026-11-25 | Estrategia declarada y proveedores de tecnología |
| SRC-006 | Regulación bancaria mexicana vigente | regulacion | parser | batch | activa | gold | 100 | 2026-11-25 | Obligaciones ante CNBV, Banco de México, CONDUSEF, IPAB y UIF |
| SRC-007 | Catálogo de capacidades del Industry Banking SME | doc_tecnico | parser | batch | activa | silver | 100 | 2026-10-16 | Ontología de capacidades y de procesos de banca mexicana |
| SRC-008 | Código fuente de los sistemas del banco | codigo | parser | batch | ausente | gold | | | Componentes, reglas de negocio y grafo de llamadas |
| SRC-009 | Inventario de aplicaciones o base de datos de configuración | cmdb | connector | batch | ausente | silver | | | Landscape, dependencias y ciclo de vida de la tecnología |
| SRC-010 | Documentación de arquitectura | diagrama | parser | bajo demanda | ausente | bronze | | | Arquitectura declarada, para contrastar con la observada |
| SRC-011 | Entrevistas con equipos del cliente | audio | parser | bajo demanda | ausente | bronze | | | Conocimiento tácito, convenciones y razones históricas |
| SRC-012 | Tickets de operación y backlog | jira | connector | continuo | ausente | silver | | | Dolor operativo real y deuda que se paga cada semana |
| SRC-013 | Plataforma de observabilidad | monitoring | connector | continuo | ausente | gold | | | Comportamiento productivo, el único hecho irrefutable del lado Run |
| SRC-014 | Minutas de sesiones de trabajo | minuta | parser | continuo | ausente | bronze | | | Acuerdos en curso y decisiones en formación |

## Por qué ninguna fuente activa puede describir la tecnología

Las siete activas son de dos clases. Las que publica la propia emisora por
obligación regulatoria dicen cuánto presta, cuánto capta y qué se propone, y
nada sobre qué sistemas lo ejecutan. Las de prensa nombran un proveedor de
pagos y una reestructura de áreas, y ahí se acaban.

La consecuencia está declarada en `GAP-BBAJIO-001`: el núcleo bancario es
desconocido. Hasta que se cierre, el brain puede razonar sobre el negocio de
BanBajío y sobre el modelo de cómo debería operar un banco, pero no puede
opinar sobre modernización, equivalencia funcional ni riesgo de migración.

## Regla de promoción

Degradar el nivel de una fuente es facultad de `dt-source-steward`. Promoverlo
no lo es: eso se hace afirmación por afirmación, con revisión humana, y queda
registrado en `knowledge_lineage` con quién validó y cuándo.
