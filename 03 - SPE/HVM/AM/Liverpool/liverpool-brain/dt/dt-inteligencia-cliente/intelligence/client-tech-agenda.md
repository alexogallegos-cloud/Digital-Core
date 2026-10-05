# Agenda Digital y Tecnológica — El Puerto de Liverpool, S.A.B. de C.V.

> **DT**: dt-inteligencia-cliente · `SPE-AM-003`
> **Última actualización**: 2026-09-02

---

## Postura Digital Declarada

> **"La prioridad ya no es abrir más tiendas"** — CEO Enrique Güijosa Hidalgo, Abr 2026

> **"Liverpool selects commercetools to unlock Agentic Commerce Experiences"** — PR Newswire, 2026

Liverpool anunció en 2026 una reorientación estratégica: de expansión física a modernización digital y logística. El CEO redujo la apertura de tiendas Suburbia a 2 en 2026 y concentra la inversión (MXN 10-11,000M/año) en:
1. Centro de distribución Arco Norte (logística last-mile)
2. Plataforma e-commerce (migración completada + selección commercetools)
3. Sistemas de pago en tienda (in-store payment modernization)

fuente: https://www.adn40.mx/mexico/2026-04-27/liverpool-cambia-de-estrategia-en-mexico-la-prioridad-ya-no-es-abrir-mas-tiendas/
fuente: https://www.prnewswire.com/news-releases/commercetools-selected-by-liverpool-to-unlock-agentic-commerce-experiences-302605025.html
fecha_consulta: 2026-09-02

---

## Proyectos Tecnológicos Conocidos

| Proyecto | Descripción | Estado | Sistema(s) | Fuente | Fecha |
|----------|-------------|--------|-----------|--------|-------|
| Migración a commercetools | Liverpool seleccionó commercetools para "agentic commerce experiences" y unified commerce | Anunciado 2026 | Java/Digital Platform → commercetools | PR Newswire | 2026 |
| Migración plataforma e-commerce | Migración a nueva plataforma e-commerce completada en 2025 (limitó GMV temporalmente) | Completado 2025 | Digital Platform (Java) | Cronista / Expansión | 2025-2026 |
| Click & Collect (Retira en Tienda) | 41% de transacciones digitales en 2024 — servicio omnicanal líder | En producción | Digital Platform + SAP + tiendas | ADN40 / AMVO | 2024-2025 |
| Centro distribución Arco Norte | Nuevo centro de distribución para acelerar entregas a domicilio | En construcción | Logística / WMS (SAP?) | Modaes / ADN40 | 2026 |
| Mejoras sistemas pago en tienda | Modernización de sistemas de pago in-store | En curso | Mainframe / POS | ADN40 | 2026 |
| SAP (GENCore Liverpool) | Análisis RE del ERP SAP de Liverpool — SPE-AM-003 | Activo (DISCOVER) | SAP ECC/S4HANA | Engagement interno | 2026-09 |

---

## Stack Tecnológico AS-IS (Conocido del Engagement)

| Sistema | Tecnología | Stack | Rol en el Negocio | TOGAF Type |
|---------|-----------|-------|------------------|-----------|
| ERP / Finanzas / Inventario | SAP ECC o S/4HANA | ABAP + SAP BTP? | Gestión comercial, finanzas, compras, HR | `core` |
| Procesamiento financiero / LiverpoolCard | Oracle + PL/SQL | PL/SQL packages, procedures | Crédito, cobranza, servicios LiverpoolCard | `processors` |
| Sistemas legacy core | IBM z/OS + COBOL | COBOL/JCL | [PENDIENTE: confirmar rol — posible POS legacy, liquidaciones, batch] | `core` |
| E-commerce / APIs digitales | Java + Microservicios | Java Spring Boot? | liverpool.com.mx, app móvil, APIs digitales | `channels` |

---

## Selección de commercetools — Señal Estratégica Clave

La selección de **commercetools** por Liverpool es la señal tech más relevante para el programa SPE-AM-003. Implica:

| Dimensión | Impacto en SPE-AM-003 |
|-----------|----------------------|
| Arquitectura composable (MACH) | El stack Java actual debe documentarse antes de la migración; SPE-AM-003 genera el "mapa del tesoro" del AS-IS |
| "Agentic commerce" | Liverpool busca IA embebida en el commerce platform — el programa debe exponer APIs que la soporten |
| Unified commerce | La integración SAP ↔ commercetools es una dependencia crítica que el brain debe mapear |
| Decisión 7R para Java stack | La plataforma Java actual probablemente sea "Repurchase" (reemplazar con commercetools) — confirmar con arquitecto |

fuente: https://www.prnewswire.com/news-releases/commercetools-selected-by-liverpool-to-unlock-agentic-commerce-experiences-302605025.html
fecha_consulta: 2026-09-02

---

## Indicadores Digitales (2024-2025)

| Métrica | Valor | Período | Fuente |
|---------|-------|---------|--------|
| Penetración digital (GMV) | 32.3% | 2025 | Cronista |
| GMV digital crecimiento | +4.8% | 2025 | Cronista |
| Click & Collect / transacciones digitales | 41% | 2024 | AMVO Premio eCommerce |

---

## Alianzas y Partners Tecnológicos

| Partner | Tipo | Área | Fuente | Fecha |
|---------|------|------|--------|-------|
| commercetools | Selección plataforma e-commerce composable | Digital commerce (unified commerce) | PR Newswire | 2026 |
| SAP | ERP vendor | Core operativo (gestión comercial) | Engagement / Conocimiento general | — |
| Accenture | Análisis AM RE (SPE-AM-003) | Modernización de aplicaciones | Este engagement | 2026-09 |
| [IBM/Unisys] | [PENDIENTE: confirmar mainframe vendor] | Infraestructura core legacy | Engagement | — |

---

## Premios y Reconocimientos Tech

| Premio | Descripción | Fuente | Fecha |
|--------|-------------|--------|-------|
| Premio eCommerce México 2025 (AMVO) | Ganador junto con IKEA y Coppel — liderazgo en Click & Collect omnicanal | Retailers.mx / Programmatic Mexico | 2025 |

fuente: https://retailers.mx/ikea-coppel-y-liverpool-lideran-premios-ecommerce-mexico-2025/
fecha_consulta: 2026-09-02

---

## Agenda de Investigación

- [ ] Confirmar versión SAP exacta (ECC 6.0 o ya en S/4HANA) — es diferente el nivel de esfuerzo RE
- [ ] Confirmar qué hace el mainframe z/OS en Liverpool (POS legacy, LiverpoolCard batch, otro)
- [ ] Confirmar qué hace el stack Oracle PL-SQL (LiverpoolCard processing, o aplicación separada)
- [ ] Buscar licitaciones o contratos SAP/Oracle/tech en Liverpool (prensa, LinkedIn, Compranet)
- [ ] Detallar la integración SAP ↔ commercetools que anunció Liverpool
- [ ] Identificar si el CTO Antonino Guichard tiene declaraciones públicas sobre la estrategia tech

---

*Actualizado 2026-09-02 · Señal clave: selección commercetools para unified commerce (2026) + migración e-commerce completada (2025) · Stack AS-IS: SAP + Oracle + Mainframe + Java · dt-inteligencia-cliente*