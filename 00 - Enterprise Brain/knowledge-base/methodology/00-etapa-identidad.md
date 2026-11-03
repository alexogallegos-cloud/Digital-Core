# Etapa 0 — Identidad: Quién Es la Empresa

> Etapa 0 del Gemelo Cognitivo. Metodología Enterprise Brain · Digital Core.
> **Eje de metodología, no de arquitectura.** Esta es la etapa 0 de cinco del método y puebla `company_profile`, `business_milestones`, `strategic_drivers` y `driver_links` del CORE. No es una de las seis capas de la arquitectura. Ver "Los Dos Ejes del Conocimiento" en `reference-architecture-enterprise-brain.md`.
> Introducida por ADR-EB-015. Dueño: `dt-client-intelligence`.

## Objetivo

Establecer quién es la empresa antes de que el método toque una línea de código: su identidad, la trayectoria que la hizo como es, sus números, lo que la presiona y hacia dónde dice que va.

## Por qué va antes del Lenguaje

Las otras cuatro etapas entran por el sistema. El vocabulario sale de nombres de stored procedures, las almas de la topología de llamadas, los journeys de la secuencia de operaciones y las reglas de las condiciones del código. Todas responden **qué hace el sistema**. Ninguna responde por qué le importa al negocio que lo haga.

Esa es la diferencia práctica: un hallazgo sobre un stored procedure de cobranza no sabe si la cobranza es el frente donde el banco está perdiendo margen o una función estable que nadie mira. La Etapa 0 le da ese marco, y lo hace primero porque todo lo que viene después se ancla a ella.

Hay además una razón de disponibilidad. El conocimiento de esta etapa **no sale de código nunca**, así que es la única que puede ejecutarse sin acceso a repositorios. Un cliente en evaluación puede tener brain desde el primer reporte anual.

## Fuentes

| Fuente | Tipo | Tier natural | Qué aporta |
|--------|------|--------------|------------|
| Reporte anual o informe financiero | doc | gold si va firmado, silver si es resumen | Cifras, estructura societaria, estrategia declarada |
| Regulación publicada sobre la entidad | regulación | gold | Obligaciones, sanciones, autorizaciones |
| Notas de prensa y comunicados | doc | silver | Hitos, adquisiciones, cambios de dirección |
| Presentaciones corporativas | ppt | silver | Pilares declarados, narrativa de transformación |
| Entrevistas con ejecutivos | audio | bronze | Retos reales, prioridades no publicadas |
| Análisis de mercado de terceros | doc | silver | Posición competitiva, participación |

Toda fuente se registra antes en `source_catalog` y el tier se estampa en la frontera de entrada, derivado del tipo (ADR-EB-015, decisión 2). El tier dominante de esta etapa es silver y bronze, lo cual es correcto y debe declararse: **una estrategia declarada en un reporte anual es intención, no hecho.**

## Qué produce

| Tabla | Contenido | Volumen típico |
|-------|-----------|----------------|
| `company_profile` | La ficha de identidad | 1 fila |
| `business_milestones` | La trayectoria por año | 5 a 20 filas |
| `strategic_drivers` | Pilares, objetivos, retos y amenazas | 5 a 15 filas |
| `measurements` | Cifras ancladas a `company_profile` | 10 a 50 filas |
| `driver_links` | La traza de vuelta | crece con el brain |

## El criterio de salida

La etapa no termina cuando las tablas tienen filas. Termina cuando **cada driver tiene al menos un link, o está declarado como hueco**.

Un pilar estratégico sin ninguna capability, producto o regla que lo sirva significa una de dos cosas, y las dos importan: o el brain todavía no cubre esa parte del estate, o la empresa declara una prioridad que su tecnología no sostiene. Lo primero es una brecha de extracción y va a `knowledge_gaps`. Lo segundo es un hallazgo de negocio y es de las cosas más valiosas que un brain puede decir.

Por eso el criterio no es de volumen sino de conexión. Sin `driver_links` poblada, la Etapa 0 produjo un documento, no conocimiento.

## Anti-patrones

- Marcar como gold un pilar declarado. Es intención y su tier es silver por origen (B37).
- Poblar `strategic_drivers` y dejar `driver_links` vacía. El estudio queda como prólogo, que es justo lo que esta etapa existe para evitar.
- Confundir a la empresa con sus clientes. Esta etapa modela a la compañía; la gestión de cliente es de `dt-customer-owner`.
- Inventar cifras de mercado. Lo que no esté en una fuente registrada va a `knowledge_gaps` como consulta concreta (B17).

---

*Etapa 0 de 5 · Metodología Enterprise Brain · ADR-EB-015 · Accenture México*
