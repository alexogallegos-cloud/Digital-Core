# DT: Equipo y Change Management — Unity R4
> **Digital Twin** · Fuente: RAID v2.0 · Minutas R4 · SME IT Operating Model
> **Versión**: v2.0.0 · 2026-08-19 — Plan de Change Management formal, vacante Karina Zepeda, Communication Matrix, Adoption Roadmap, Change Champions
> **Propósito**: Mapa de equipo, capacidad, riesgos de rotación y plan de change management para el go-live de enero 2027

---

## 🔴 VACANTE CRÍTICA — Change Management Lead ACN

**Karina Nayeli Zepeda Arroyo renunció al engagement.** Era la responsable de Change Management en el equipo Accenture. No hay reemplazo confirmado.

| Elemento | Estado |
|---|---|
| Rol vacante | Change Management Lead — Accenture |
| Persona que salió | Karina Nayeli Zepeda Arroyo |
| Reemplazo ACN | **Sin confirmar** |
| Contraparte BanCoppel | Alondra Cárdenas (stakeholder, responsible) |
| Vendor con rol paralelo | Kreios (change management / implementación) — pero con 60% de rotación en dic |

**Riesgo inmediato**: sin Change Management Lead, las siguientes actividades no tienen owner:
- Plan de comunicación del go-live hacia usuarios finales (agentes CAT, cajeros, cobranza)
- Red de Change Champions por área de BanCoppel
- Medición de resistencia al cambio y adopción
- Capacitación y materiales de entrenamiento
- Comunicaciones ejecutivas de la transición

**Acción requerida antes del 2026-09-01**: definir uno de los tres modelos de cobertura:

| Opción | Descripción | Pros | Contras |
|---|---|---|---|
| A — Reemplazo ACN | Incorporar nuevo Change Management Lead ACN al equipo | Continuidad del rol; conocimiento del método ACN | Tiempo de rampa; disponibilidad |
| B — Absorber en PMO ACN | Pablo Lorenzo o miembro del equipo absorbe las actividades de change | Sin tiempo adicional de rampa | Sobrecarga; change no es el core de delivery |
| C — Delegar a Kreios | Kreios asume toda la carga de change management | Kreios ya tiene contexto | Kreios tiene 60% de rotación en dic; riesgo concentrado |

La opción A es la recomendada. La opción C es la más riesgosa.

---

## Riesgo Crítico — Rotación Diciembre-Enero

**60% del equipo en transición durante la ventana de go-live.** Este es el riesgo operacional más subestimado del programa. La mayoría de los programas que tienen incidentes graves en el primer mes de producción los tienen porque el equipo que hizo el go-live no es el mismo que opera el sistema el día siguiente.

| Riesgo | Impacto | Ventana |
|--------|---------|---------|
| 60% rotación Kreios | Pérdida de conocimiento tácito del sistema | Dic 2026 – Ene 2027 |
| Fatiga organizacional acumulada | Errores en pruebas finales SIT/UAT | Oct – Dic 2026 |
| Roles sin claridad (18% fricción) | Decisiones lentas en momentos críticos | Ahora |

---

## Estructura de Equipo por Componente

| Componente | Delivery owner | Vendor ejecutor | BanCoppel counterpart | Status |
|-----------|---------------|----------------|----------------------|--------|
| SmartVista (core) | ACN | BPC / Appwhere | DATO-REQUERIDO | En desarrollo |
| APOLO (originación) | ACN | Appwhere | DATO-REQUERIDO | En desarrollo |
| App / AppMovil | ACN | DATO-REQUERIDO | DATO-REQUERIDO | En desarrollo |
| CAT (contact center) | ACN | **SIN VENDOR** 🔴 | DATO-REQUERIDO | Bloqueado |
| SIWEB (sucursales) | ACN | DATO-REQUERIDO | DATO-REQUERIDO | Bloqueado |
| Cobranza Direccionada | DATO-REQUERIDO | DATO-REQUERIDO | DATO-REQUERIDO | En desarrollo |
| Apificación (middleware) | ACN | ACN | DATO-REQUERIDO | En desarrollo |

---

## Capacidad vs. Demanda del Roadmap

El programa tiene 16 iniciativas declaradas en el roadmap. El SME IT Operating Model calificó este roadmap como "wishful thinking" por ausencia de mapa de capacidad real.

### Carga estimada por fase (pendiente de validar)

| Fase | Ventana | Demanda estimada | Capacidad disponible | Gap |
|------|---------|-----------------|---------------------|-----|
| Cierre análisis | Sep – Oct 16 2026 | DATO-REQUERIDO | DATO-REQUERIDO | DATO-REQUERIDO |
| Desarrollo + UT | Hasta Oct 15 2026 | DATO-REQUERIDO | DATO-REQUERIDO | DATO-REQUERIDO |
| SIT | Oct 15 – Dic 15 2026 | DATO-REQUERIDO | DATO-REQUERIDO | DATO-REQUERIDO |
| UAT + fix | Dic 2026 | DATO-REQUERIDO | DATO-REQUERIDO | DATO-REQUERIDO |
| Go-live + hypercare | Ene 2027 | DATO-REQUERIDO | 40% del equipo estable | 🔴 RIESGO |

> **Acción urgente**: mapear headcount real por componente y cruzar contra la demanda del cronograma.

---

## Plan de Transferencia de Conocimiento (ante rotación)

Para mitigar la rotación del 60% en diciembre, cada miembro del equipo que salga debe completar:

### Artefactos de transferencia por rol

| Artefacto | Quién lo produce | Fecha límite |
|-----------|-----------------|-------------|
| Runbook operativo de su componente | Desarrollador / configurador | Nov 30 2026 |
| Documentación de decisiones técnicas tomadas | Tech lead por componente | Nov 15 2026 |
| Sesión de shadowing con sucesor (mín. 5 días) | Saliente + entrante | Dic 1-15 2026 |
| Accesos y credenciales entregados a BanCoppel | PMO BanCoppel | Antes de salida |
| Casos de prueba documentados | QA lead | Nov 30 2026 |

### Roles con mayor riesgo de conocimiento concentrado

| Rol | Riesgo si sale | Mitigación |
|----|---------------|-----------|
| Configurador SmartVista | Pérdida de parámetros y lógica de negocio en SVBO | Documentar configuraciones antes de nov |
| Integrador SVIP / APOLO | Pérdida de mapa de APIs y contratos | Actualizar brain::vocabulary + runbooks |
| QA Lead | Pérdida de casos de prueba y criterios | Exportar suite de pruebas a herramienta formal |
| DBA de transición | Pérdida de esquema de datos y queries críticas | Documentar en knowledge-base |

---

## Roles y Responsabilidades — Clarificación pendiente

El 18% de fricción identificada en el programa viene de zonas grises entre actores. Áreas críticas a clarificar:

| Zona gris | Actor 1 | Actor 2 | Decisión pendiente |
|-----------|---------|---------|-------------------|
| Owner de defectos encontrados en DTMs de Appwhere | ACN | Appwhere | DATO-REQUERIDO |
| Quién aprueba cambios de configuración SmartVista en producción | BanCoppel | BPC | DATO-REQUERIDO |
| Quién hace triage de incidentes durante SIT | ACN QA | BanCoppel QA | DATO-REQUERIDO |
| Owner del on-call de producción día 1 | ACN | BanCoppel Ops | DATO-REQUERIDO |
| Quién firma el sign-off de UAT por componente | BanCoppel PO | PMO | DATO-REQUERIDO |

---

## Plan de Change Management — TDC P4900

### Visión del cambio

El go-live de TDC P4900 no es solo un lanzamiento de producto — es la primera vez que BanCoppel opera dos sistemas de tarjetas en paralelo (Informix/CMS para cartera existente; SmartVista para nuevos clientes P4900). El cambio afecta a agentes, cajeros, operaciones, cobranza y fraude. Sin adopción real, el producto se lanza pero no se opera correctamente.

### Impacto organizacional por colectivo

| Colectivo | Cambio principal | Complejidad de adopción | Change Champion propuesto |
|---|---|---|---|
| Agentes Contact Center (CAT) | Nuevo sistema IVR + nuevos flujos TDC — menú dinámico por nivel de mora | Alta — sistema nuevo, scripts nuevos | Armando Riveros (track owner CAT) |
| Cajeros Sucursales (SIWEB) | Nuevas pantallas compras diferidas + saldo a favor TDC | Media — flujos nuevos en sistema conocido | Cristian Sasueta (track owner SIWEB) |
| Operadores de Cobranza | Dos fuentes de aging simultáneas (Informix cartera existente + SmartVista P4900) | Alta — duplicidad operativa | Alondra Bastidas (track owner Cobranza) |
| TI Operaciones (on-call) | Nuevo stack SmartVista + APOLO en producción; runbooks nuevos | Alta — sistema nuevo, sin experiencia previa | Stephany Ley (SmartVista accountable) |
| Fraude | PayTrue como motor de riesgo (sustituye SVFM no licenciado) | Media — nueva calibración de reglas | DATO-REQUERIDO (owner PayTrue) |
| Promotores / Fuerza de ventas | Nuevo producto TDC en APOLO — flujo de originación diferente | Media — proceso nuevo de alta digital | Luis Barragán (track owner APOLO) |
| Ejecutivos de cuenta (SIWEB) | Nuevas consultas de lote y operaciones diferidas | Baja | Sergio del Valle (track owner App) |

### Red de Change Champions

Los track owners de BanCoppel son los change champions naturales. Su rol es llevar el cambio a su área, identificar resistencia temprana y reportarla al Change Management Lead.

| Champion | Área | Activación | Responsabilidad de change |
|---|---|---|---|
| Stephany Ley | SmartVista / TI Core | Sep 2026 | Adopción del nuevo sistema por equipos TI; runbooks en manos del equipo |
| Armando Riveros | CAT / Contact Center | Oct 2026 (cuando CAT se contrate) | Capacitación agentes; validación de scripts IVR |
| Alondra Bastidas | Cobranza | Oct 2026 | Adopción del modelo de aging dual; scripts actualizados |
| Cristian Sasueta | SIWEB / Sucursales | Nov 2026 | Capacitación cajeros; materiales en punto de venta |
| Luis Barragán | APOLO / Promotores | Oct 2026 | Adopción del flujo digital de originación |
| Alondra Cárdenas | Change Management BanCoppel | Inmediato | Coordinación transversal con todas las áreas |
| Erika Mata | Arquitectura / Decisiones ⚠ agenda saturada | Sep 2026 | Involucrar desde el inicio — no en el último momento |

### Adoption Roadmap — Hitos de change por mes

| Mes | Hito de change | Responsable | Estado |
|---|---|---|---|
| Ago 2026 | Definir reemplazo o modelo de cobertura para Karina Zepeda | Pablo Lorenzo + Juan Manuel | 🔴 Pendiente |
| Ago 2026 | Activar Alondra Cárdenas como coordinadora BanCoppel | Tere González | 🔴 Pendiente |
| Sep 2026 | Change Impact Assessment formal por colectivo | Change Mgmt Lead (vacante) | 🔴 Bloqueado |
| Sep 2026 | Activar red de Change Champions; sesión de kickoff | Change Mgmt Lead + Champions | 🔴 Bloqueado |
| Oct 2026 | Materiales de capacitación v1 listos (CAT, SIWEB, Cobranza) | Change Mgmt Lead + Kreios | Pendiente |
| Oct 2026 | Encuesta de resistencia al cambio — línea base | Change Mgmt Lead | Pendiente |
| Nov 2026 | Piloto de capacitación con grupo reducido (CAT + cajeros) | Kreios + Champions | Pendiente |
| Nov 2026 | Communication Package go-live listo (qué cambia, cuándo, para quién) | Change Mgmt Lead | Pendiente |
| Dic 2026 | Capacitación masiva todos los colectivos completada | Kreios + Champions | Pendiente |
| Dic 2026 | Encuesta de adopción post-capacitación | Change Mgmt Lead | Pendiente |
| Ene 2027 | Comunicación oficial go-live hacia clientes y operaciones | BanCoppel Marketing + Change | Pendiente |
| Feb 2027 | Encuesta de adopción 30 días post-go-live | Change Mgmt Lead | Pendiente |

### Communication Matrix

Cada audiencia recibe el mensaje correcto, en el canal correcto, en el momento correcto.

| Audiencia | Mensaje clave | Canal | Frecuencia | Emisor | Cuándo inicia |
|---|---|---|---|---|---|
| Ejecutivos BanCoppel (Juan Manuel, Pablo M.) | Avance del programa, decisiones pendientes, riesgos | Steering Committee + reporte ejecutivo | Quincenal | ACN Lead + PM | Ya activo |
| Track owners BanCoppel | Estado por componente, bloqueos, acciones requeridas | Sesión de trabajo semanal | Semanal | ACN por track | Ya activo |
| Agentes CAT | Qué cambia en sus herramientas y scripts para TDC | Capacitación presencial + manual | Una vez (+ refuerzo) | Kreios + Champion CAT | Nov 2026 |
| Cajeros SIWEB | Nuevas pantallas de compras diferidas y saldo a favor | Capacitación en sucursal + guía rápida | Una vez | Kreios + Champion SIWEB | Nov 2026 |
| Operadores Cobranza | Nuevo modelo de aging dual; qué ver en cada sistema | Taller presencial + playbook | Una vez | Change Mgmt Lead + Champion | Oct 2026 |
| TI Operaciones | Runbooks nuevos, on-call model, contactos de escalación | Sesión técnica + runbooks firmados | Una vez + drill | ACN + Champion TI | Nov 2026 |
| Clientes finales TDC | Nuevo producto disponible; cómo activarlo | App + comunicación oficial BanCoppel | Go-live | Marketing BanCoppel | Ene 2027 |

### Resistencia al cambio — Riesgos de adopción

| Riesgo | Colectivo | Señal de alerta | Mitigación |
|---|---|---|---|
| Agentes CAT operan TDC con procesos del sistema anterior | Agentes Contact Center | Quejas de clientes por atención inconsistente en primeros 30 días | Supervisión reforzada semana 1-2; scripts obligatorios validados por Armando Riveros |
| Cajeros ignoran nuevas pantallas SIWEB y operan manualmente | Cajeros sucursales | Errores en compras diferidas; reportes manuales | Champion SIWEB en piso durante primera semana; guía visual en cada caja |
| Cobranza sigue operando solo con Informix, ignora SmartVista aging | Operadores cobranza | Cartera P4900 sin seguimiento correcto; mora no detectada | Playbook explícito de cuándo ir a cada sistema; revisión diaria primera semana |
| TI Operaciones escala todo a ACN post-go-live sin ownership propio | TI BanCoppel | Incidentes que no deberían requerir ACN; on-call saturado | Drill de incidentes en dic antes del go-live; runbooks firmados con owner TI |

### Plan de capacitación detallado

| Colectivo | Personas estimadas | Modalidad | Duración | Fecha límite | Materiales |
|---|---|---|---|---|---|
| Agentes CAT | DATO-REQUERIDO | Presencial por turnos | 4 horas | 2026-12-15 | Manual de agente + scripts + guía de manejo de excepciones |
| Cajeros SIWEB | DATO-REQUERIDO | Presencial en sucursal | 2 horas | 2026-12-15 | Guía rápida visual + pantallas de referencia |
| Operadores Cobranza | DATO-REQUERIDO | Taller presencial | 3 horas | 2026-10-31 | Playbook aging dual + criterios de escalación |
| TI Operaciones | DATO-REQUERIDO | Sesión técnica + drill | 8 horas | 2026-12-01 | Runbooks firmados + diagrama de escalación |
| Fraude / PayTrue | DATO-REQUERIDO | Sesión técnica | 4 horas | 2026-11-15 | Reglas PayTrue TDC + umbrales de alerta |
| Promotores / Fuerza ventas | DATO-REQUERIDO | E-learning + piloto | 2 horas | 2026-10-31 | Demo APOLO TDC + FAQ de ventas |

---

## Modelo de On-Call — Transición

Durante los primeros 90 días en producción (hypercare), el modelo de on-call es diferente al steady-state:

| Periodo | Modelo | Responsable principal |
|---------|--------|-----------------------|
| Go-live día 1-7 | War room 24/7 con todos los vendors | ACN Delivery Lead |
| Semana 2-4 | On-call rotativo ACN + BPC + Appwhere | ACN |
| Mes 2-3 (hypercare) | On-call ACN con escala a vendors | ACN / BanCoppel Ops |
| Post-hypercare (AMS) | Steady-state AMS BanCoppel | BanCoppel Ops |

> Detalle de SLAs y escalación → ver `dt-ops-readiness.md`

---

## DATO-REQUERIDO — Información crítica faltante

1. Headcount real por componente (ACN + vendor + BanCoppel)
2. Nombres de delivery leads por componente
3. Plan formal de Kreios para mitigar la rotación del 60%
4. Counterpart BanCoppel por cada componente
5. Plan de capacitación: colectivos, fechas, modalidad
6. Resolución de las 5 zonas grises de roles y responsabilidades
7. Owner del on-call de producción día 1 (BanCoppel Ops o ACN)
8. Modelo de hypercare: duración, costo, quién lo financia

---

*Creado: 2026-08-16 — Digital Twin Equipo y Change Management Unity R4 v1.0.0*
