# Portal Agentes — Digital Brain · AXA México
> Canal Digital · Estado: SCAFFOLD

---

## IDENTIDAD DEL SISTEMA

| Campo | Valor |
|-------|-------|
| Nombre canónico | portal-agentes |
| Categoría TOGAF | Canal Digital |
| Tipo TOGAF | channel |
| Estado TOGAF | scaffold |
| Vendor / Plataforma | Propio / Guidewire Portal |
| Entorno productivo | Por confirmar |

---

## ROL EN LA CADENA DE VALOR

Portal web para agentes y corredores autorizados que permite cotizar, emitir y gestionar pólizas P&C Commercial Lines de AXA México, con visibilidad de cartera, estado de siniestros en curso y liquidación de comisiones, siendo el principal punto de contacto digital con la red intermediaria.

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