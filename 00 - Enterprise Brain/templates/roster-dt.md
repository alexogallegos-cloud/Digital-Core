# Roster de Digital Twins — plantilla canónica

> Artefacto de instancia · Regla B41 · ADR-EB-011, reformulado por ADR-EB-016
> Se copia al `dt/` del brain, con el nombre `roster-dt.md`, y se completa.
> La dimensión D10 del Brain Auditor lo lee desde ahí.

---

## Qué declara este archivo, y qué no

B41 no exige que un brain tenga veinticuatro carpetas con nombre canónico.
Exige que **ninguna de las veinticuatro responsabilidades quede sin dueño
declarado**. Este archivo es esa declaración: por cada rol del roster, qué
Digital Twin de **este** brain lo asume, con el nombre que este brain use.

La diferencia no es retórica. La auditoría de noviembre de 2026 midió la
formulación anterior contra los ocho brains del estate: se instancian cuarenta
y cuatro nombres distintos de Digital Twin y la intersección con el roster
canónico es vacía. Bajo la regla vieja los ocho reprueban y la regla es letra
muerta. Bajo la nueva se audita lo que siempre quiso decir: un brain sin nadie
que responda por la calidad del conocimiento tiene un problema real, se llame
como se llame quien lo asuma.

**Los DTs de dimensión no van aquí.** `dt-spei`, `dt-autorizador-pagos`,
`dt-java-analysis` y los demás especialistas en una materia del sistema son
población libre: cada brain instancia los que su materia pida y no se enumeran.
Mezclarlos en esta tabla los vuelve enumerables, que es justo lo que no son.

## Cómo se llena

Una fila por rol. En la segunda columna va el DT de este brain que lo asume.
Si todavía no hay nadie, se escribe `—` y se declara el hueco: **un dominio sin
dueño no se borra de la tabla, se declara**. Borrarlo haría desaparecer la
responsabilidad justo donde más falta hace verla.

Un rol que no aparezca en la tabla, ni con dueño ni como hueco, es hallazgo
bloqueante de D10. No mencionarlo no es cubrirlo.

---

## El roster

### Categoría A — rol de TI

Cada uno encarna un rol del catálogo de 46 que prescribe el SME de IT
Operating Model, y es dueño único de una porción del esquema.

| Rol canónico | DT en este brain | Nota |
|---|---|---|
| dt-domain-architect | — | Arquitectura, ontología y decisiones |
| dt-information-architect | — | Modelo de información y vocabulario |
| dt-knowledge-manager | — | Linaje, huecos y la columna tier |
| dt-asset-configuration-manager | — | Componentes, CIs y dependencias |
| dt-change-manager | — | Transiciones, gates y el objetivo del SLO |
| dt-service-operations-lead | — | Operación del servicio y su SLO actual |
| dt-it-risk-manager | — | Riesgo tecnológico y continuidad |
| dt-demand-manager | — | Demanda y portafolio de iniciativas |
| dt-programme-manager | — | Programa, olas y dependencias |
| dt-supplier-relationship-manager | — | Proveedores y contratos |

### Categoría B — ingeniería del brain

No razonan sobre el cliente: construyen y cuidan el brain.

| Rol canónico | DT en este brain | Nota |
|---|---|---|
| dt-build-operator | — | Corre el pipeline de construcción |
| dt-human-reviewer | — | Promueve a gold. Nadie más puede |
| dt-brain-engineer | — | Esquema, consultas y API |
| dt-brain-auditor | — | Valida el brain contra el canon |
| dt-source-steward | — | Catálogo de fuentes y su pipeline |

### Categoría C — negocio

Destilados de los catálogos de industria que sí existen, no inventados.

| Rol canónico | DT en este brain | Nota |
|---|---|---|
| dt-channel-owner | — | Canales de atención |
| dt-distribution-owner | — | Distribución y red comercial |
| dt-product-owner | — | Diseño y catálogo de producto |
| dt-customer-owner | — | Gestión del cliente del cliente |
| dt-operations-owner | — | Lado operativo del dominio de producto |
| dt-enterprise-functions-owner | — | Finanzas, riesgo y regulatorio |
| dt-business-support-owner | — | Soporte corporativo y BPM |
| dt-sustainability-owner | — | Sostenibilidad, ética e inclusión |
| dt-client-intelligence | — | Quién es la empresa y qué la mueve |

---

## Sobre el dominio que no existe en tu industria

`dt-sustainability-owner` tiene un L1 propio en banca, aparece degradado a
capacidad L3 en retail y no existe en los catálogos de seguros. Se mantiene en
el roster de todas formas, y la razón está en `ADR-EB-016`: el criterio para
conservar un dominio no es su presencia en el catálogo sino si la
responsabilidad existe en el negocio real. En seguros y retail existe aunque el
catálogo no la nombre, porque hay obligaciones de reporte, inclusión y gobierno
ambiental que alguien responde.

Lo mismo aplica a cualquier dominio futuro en esa situación. Se instancia
declarando el hueco.

---

*Plantilla del asset Enterprise Brain · Digital Core · Accenture México*
