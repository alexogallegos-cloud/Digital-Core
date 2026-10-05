# Digital Platform — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization
> SME: [Software Engineering SME](../../../../../SME/Technology/Software%20Engineering/CLAUDE.md)

```
# togaf_type: channels
# togaf_state: transitional
# togaf_system_of: differentiation
# togaf_abb: digital-commerce-platform
# bian_domains: []  (N/A — retail, no banking BIAN)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | Plataforma Digital Liverpool (Java + Microservicios) |
| Lenguaje | Java (Spring Boot hipótesis) + APIs REST |
| Rol | Canal digital — e-commerce liverpool.com.mx, app móvil, APIs omnicanal, Click & Collect |
| TOGAF Type | `channels` (System of Differentiation — alta velocidad de cambio) |
| Dominios retail | R02 Gestión de Clientes · R05 Canales Digitales · R09 Analítica |
| Estado | `[STATE: SCAFFOLD]` — estructura creada; en TRANSICIÓN (migración a commercetools anunciada) |
| Proyecto | `SPE-AM-003` |

---

## Señal Estratégica Crítica: Migración a commercetools

> **Estado: TRANSITIONAL** — Liverpool ya seleccionó commercetools como reemplazo de esta plataforma.

La plataforma Java actual está en estado transitional. Esto implica para el programa:

| Implicación | Descripción |
|-------------|-------------|
| Decisión 7R probable | **Repurchase** (reemplazar con commercetools) o **Refactor** parcial (migrar lógica custom no cubierta por commercetools) |
| Urgencia del análisis RE | Alta — documentar el AS-IS ANTES de que comience la migración para no perder el conocimiento |
| Alcance del RE | Identificar lógica de negocio custom (reglas de precios, promociones, loyalty Liverpool Premia) que debe re-implementarse en commercetools |
| Click & Collect | 41% de transacciones — flujo crítico que no puede degradarse en la migración |

---

## Lo Que Sabemos

| Aspecto | Conocido | Por Confirmar |
|---|---|---|
| Tecnología | Java + Microservicios (declarado) | Framework exacto (Spring Boot, Quarkus, etc.), versión Java |
| Canal principal | liverpool.com.mx + app móvil | Confirmar arquitectura (SPA + BFF + microservicios backend?) |
| Click & Collect | 41% de tx digitales 2024 | Confirmar arquitectura del flujo C&C |
| Migración e-commerce 2025 | Completada | A qué plataforma se migró (¿ya es commercetools o es plataforma intermedia?) |
| Integración con SAP | Probable — catalogo, inventario, precios | Confirmar APIs SAP-Digital |
| Integración con Oracle | Probable — LiverpoolCard crédito en checkout | Confirmar |
| Microservicios | Arquitectura distribuida declarada | Confirmar #servicios, patterns, deployment |

---

## Liverpool Premia (Loyalty Program)

El programa de lealtad Liverpool Premia es un componente del stack digital con reglas de negocio propias:
- Acumulación y redención de puntos
- Integración LiverpoolCard + tiendas + e-commerce
- Personalización de ofertas

Este componente es candidato a documentación RE específica dentro del sistema Digital Platform.

---

## Estructura del Sistema

```
systems/channels/Digital-Platform/
├── source/
│   ├── code/     ← código Java microservicios, APIs, frontend
│   ├── docs/     ← docs técnicos, diagramas de arquitectura
│   └── ops/      ← config CI/CD, k8s manifests, etc.
├── digital-brain/
│   ├── brain.db           [PENDING]
│   ├── build-brain.py     [PENDING]
│   └── brain.py           [PENDING]
├── knowledge-base/
│   ├── rules/             [PENDING — reglas de precios, promociones, loyalty]
│   ├── vocab/             [PENDING]
│   └── ontology/          [PENDING]
├── generators/            [PENDING]
├── dt/                    [PENDING]
├── portal/                [PENDING]
└── CLAUDE.md              ← este archivo
```

---

## Nota sobre el Análisis RE

A diferencia de SAP (ABAP) y Oracle (PL-SQL), el análisis de este sistema sigue el path de **Application Modernization** puro (sin specialist de lenguaje propietario). El SME ejecutor es `Software Engineering SME` vía `[INVOKE]`. El análisis se enfoca en:
1. Inventario de microservicios y sus responsabilidades
2. Mapa de APIs expuestas y consumidas
3. Lógica de negocio custom (reglas de precios, loyalty, C&C)
4. Dependencias con SAP, Oracle y Mainframe

---

*Creado 2026-09-02 · Scaffold · Java Microservicios Liverpool — canal digital e-commerce · EN TRANSICIÓN hacia commercetools (anunciado 2026) · análisis RE urgente antes de migración · SPE-AM-003*