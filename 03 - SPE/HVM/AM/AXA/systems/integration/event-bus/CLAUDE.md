# Event Bus — Digital Brain · AXA México
> Integración · Estado: SCAFFOLD

---

## IDENTIDAD DEL SISTEMA

| Campo | Valor |
|-------|-------|
| Nombre canónico | event-bus |
| Categoría TOGAF | Integración |
| Tipo TOGAF | integration |
| Estado TOGAF | scaffold |
| Vendor / Plataforma | Apache Kafka / Azure Service Bus |
| Entorno productivo | Por confirmar |

---

## ROL EN LA CADENA DE VALOR

Bus de eventos asíncrono que desacopla la comunicación entre los sistemas core de AXA México, habilitando integración event-driven entre policy-admin, claims, billing y los sistemas de datos y compliance, garantizando resiliencia y consistencia eventual en la cartera P&C Commercial Lines.

---

## GEMELO COGNITIVO — 4 CAPAS

| Capa | Descripción | Estado |
|------|-------------|--------|
| **Lenguaje** | Vocabulario, términos y glosario del sistema | VACÍO |
| **Almas** | Módulos funcionales y capacidades del sistema | VACÍO |
| **Biografía** | Historia, evoluciones e incidentes relevantes | VACÍO |
| **Intención** | Dirección de transformación y roadmap | VACÍO |

---

## DIGITAL BRAIN

- `digital-brain/brain.db` — SQLite del sistema (por construir)
- `digital-brain/brain.py` — API de consulta
- `digital-brain/build-brain.py` — pipeline de extracción

Estado actual: **SCAFFOLD** — sin datos. Requiere acceso al sistema fuente para iniciar extracción.

---

## DIGITAL TWINS

| DT | Vista | Estado |
|----|-------|--------|
| `dt/dt-modelo-dominio/` | Taxonomía de negocio del sistema | VACÍO |
| `dt/dt-reglas/` | Reglas de negocio extraídas | VACÍO |
| `dt/dt-vocabulario/` | Vocabulario técnico-negocio | VACÍO |

---

## CAPACIDADES ETB MAPEADAS

Las capacidades del ETB Insurance P&C Commercial Lines que este sistema soporta se documentarán
en `knowledge-base/ontology/` una vez completado el mapeo ETB → sistema.

---

*Última actualización: 2026-09-03 · v1.0 · Scaffold*