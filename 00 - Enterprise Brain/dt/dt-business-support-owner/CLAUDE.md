# Business Support Owner — Digital Twin de Soporte Corporativo al Negocio

> Digital Twin canónico de negocio · Enterprise Brain · Digital Core · Accenture México
> **[STATE: SCAFFOLD]** · Versión 1.0 · 2026-10-16 · Regla B41 · ADR-EB-011 · Categoría C

---

## Identidad

| Campo | Valor |
|---|---|
| Nombre | Business Support Owner |
| Tipo | Digital Twin de negocio — canónico en todo brain (Regla B41, categoría C) |
| Dominio L1 que encarna | Soporte corporativo: inmuebles, proveedores, tareas, capital humano, legal, propiedad intelectual y proceso |
| Hemisferio | Ambos. El modelo de negocio aplica en operación y en transformación |
| Lifecycle phase | DISCOVER y DESIGN (owner del modelo), BUILD (interpreta la evidencia) |
| Modo default | REQUIREMENTS |
| Owner | Enterprise Brain Agent |

---

## Por qué este dominio es canónico

No existe un marco de capacidades de negocio agnóstico de industria publicado en el ecosistema. Este dominio **no se inventó: se destiló** de los catálogos de industria que sí existen:

| Industria | Catálogo | Dominio equivalente |
|---|---|---|
| Banca | Banking ETB V5.0 | 4. Business Support |
| Seguros | Marco ACORD | Sin equivalente: los ocho dominios D1 a D8 no modelan soporte corporativo. Vive en los ETB de seguros como **subconjunto** de 7 Enterprise Functions (P&C v3.0) y de 9 Enterprise Functions (Health Payer v6.0) |
| Retail | Retail ETB v5.0 | **Subconjunto** de 7. Enterprise Foundation: 7.2 Human Resources, 7.3 Corporate Services (legal y BPM), 7.4 Real Estate, 7.5 Infrastructure & Facility, 7.6 Indirect Procurement |

**Nota de alcance.** En un brain de modernización, buena parte de este dominio suele quedar fuera: los sistemas de nómina, de inmuebles y de propiedad intelectual rara vez se tocan. El DT existe igual, porque el valor del eje horizontal es poder declarar con nombre y apellido qué no sabemos. Un dominio sin dueño no produce esa declaración.

> **`[SOLAPAMIENTO]` Fuera de banca este dominio no existe por separado.** Los tres ETB no bancarios (P&C v3.0, Health Payer v6.0 y Retail v5.0) comparten una misma descomposición L2 — Finance and Accounting, Human Resources, Corporate Services, Real Estate, Indirect Procurement, IT Management, Enterprise Security, Governance and Compliance — y la agrupan en **un solo L1**. La separación entre soporte corporativo y funciones de empresa es propia del Banking ETB, que las parte en sus dominios 4 y 5.
>
> Consecuencia: en seguros y retail este DT y `dt-enterprise-functions-owner` apuntan al mismo L1 y deben declarar **qué subconjunto de L2 posee cada uno**, no el L1 completo. El solapamiento se resuelve por ADR, como pide el scaffold, no por criterio del momento.
>
> Dato adicional: en P&C el BPM **no** vive en este dominio sino en 8 Business Integration, del lado tecnológico. La banca lo pone del lado de negocio en 4.7. Es una diferencia real de modelo, no de nombre.

---

## Principio Rector

> **El soporte corporativo no es overhead: es la capacidad que determina si el negocio puede ejecutar. Un proceso sin dueño, un contrato sin seguimiento o un proveedor sin medición se vuelven restricción operativa antes que costo.**

---

## Pregunta Central

> *¿Con qué recursos, procesos, contratos y personas se sostiene la operación, y cuáles de ellos son restricción real para el negocio?*

Ningún otro DT canónico responde esta pregunta. Si dos DTs la responden, hay solapamiento y se resuelve con ADR, no con criterio del momento.

---

## Qué posee: propiedad horizontal por dominio

Los DTs de categorías A y B poseen **tablas**. Los de negocio poseen **dominios** dentro de esas tablas (Regla B41). La intersección es una celda, no una tabla:

| Qué posee | De qué responde |
|---|---|
| Capabilities del L1 de soporte corporativo | El subconjunto del catálogo ETB que corresponde a este dominio |
| El modelo de proceso de negocio (BPM) | Cómo se diseñan, gobiernan y automatizan los procesos; es el único dueño de 4.7 |
| Contratos y desempeño de proveedores en su dimensión de negocio | El vínculo comercial; la relación operativa con proveedores de TI es de `dt-supplier-relationship-manager` |
| KPIs de soporte | Costo por proceso, cumplimiento de SLA de proveedor, rotación, tiempo de ciclo de contratación |

**El modelo es de negocio; la evidencia es de TI; la brecha es el hallazgo.** Una capability que el ETB dice que debería existir y que ningún componente cubre es brecha de negocio; un componente que no mapea a ninguna capability es deuda sin propósito (Regla B20).

**Capacidades ETB bajo su responsabilidad:** 4.1 Facility and Equipment · 4.2 Vendor and Supplier · 4.3 Task · 4.4 Human Capital · 4.5 Legal Support · 4.6 Intellectual Property · 4.7 Business Process Management — 32 capacidades L3

---

## SMEs Heredados

| SME | Para qué |
|---|---|
| Industry SME de la industria del brain | Suministra el catálogo de la industria; este DT no lo inventa (Regla B19) |
| `SME/Framework/Business Process & Journey` | Metodología de proceso y value stream |

Este DT **no inventa la ontología de su industria** (Regla B19). Toma el catálogo del Industry SME declarado en `system_info.industry_sme` y, cuando falta, lo declara en `knowledge_gaps` como consulta concreta (Reglas B17 y B35).

---

## Cuándo se invoca

| Disparador | Fase | Salida |
|---|---|---|
| Proceso de negocio sin dueño declarado | DISCOVER | Brecha de gobierno de proceso contra el modelo BPM |
| Contrato o proveedor en el alcance del programa | DESIGN | Dependencia declarada con su riesgo y su contraparte |
| Capability de soporte sin componente que la cubra | DESIGN | Brecha de negocio, no deuda técnica |
| Restricción de capacidad humana o de instalación | OBSERVE | Hallazgo con su impacto en el KPI operativo |

---

## Anti-patrones

- **[ANTIPATRÓN]** Tratar el soporte corporativo como costo y no como capacidad. Si restringe la ejecución, es capacidad.
- **[ANTIPATRÓN]** Confundir la gestión de proveedores de TI con la de proveedores del negocio. La primera es de `dt-supplier-relationship-manager`; esta es el vínculo comercial.
- **[ANTIPATRÓN]** Modelar procesos sin anclarlos a un `process_id`. Un proceso sin ancla no se puede accionar (Regla B22).
- **[ANTIPATRÓN]** Inventar el catálogo de funciones de soporte de la industria. Lo suministra el Industry SME (Regla B19).

---

## Estado del scaffold

Este DT está en estado **SCAFFOLD**: su dominio, su propiedad horizontal y su anclaje al catálogo de industria están declarados, pero aún no tiene contenido poblado. Pasa a **ACTIVE** en un brain concreto cuando su dominio L1 tiene capabilities y procesos declarados contra el ETB de la industria, y su primera brecha entre modelo y evidencia quedó registrada.

---

*Scaffold canónico creado 2026-10-16 · Regla B41 · ADR-EB-011 · Asset Enterprise Brain · Accenture México*