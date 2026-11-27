# Alta Movil — Sistema Descubierto (Application Modernization)
# togaf_type: channels
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: digital-onboarding

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

Originacion digital con 500 Stored Procedures y doce hosts. El inventario la lista como aplicacion de canal separada de la App BanCoppel Movil; queda por confirmar con el banco si comparte runtime con ella.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `channels` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `differentiation` |
| `togaf_abb` | `digital-onboarding` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `113` | Alta Móvil | Aplicación de Canal | Alta | Alta | 500 | 12 | 2000 |

Suma del nodo: 500 Stored Procedures declarados, 12 hosts y 2,000 operaciones diarias.
Motores de datos: informix.
Middleware: InterAct.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces del Anexo 5 no lo menciona. Su existencia la sostiene el inventario de aplicaciones, que es fuente suficiente bajo la Regla B8.

_El Anexo 5 no declara interfaces para este sistema._

---

## Proximos pasos para activar el brain

- [ ] Conseguir los artefactos fuente del sistema: codigo, configuracion, logs o export de su herramienta.
- [ ] Dejarlos en `source/` sin modificarlos.
- [ ] Escribir `digital-brain/build-brain.py`, preservando el `cross_dependencies` y los `signals` que este brain semilla ya trae.
- [ ] Validar las dependencias contra el equipo de BanCoppel.
- [ ] Emitir seeds propios por Regla B11 al cerrar el primer build.
- [ ] Reconstruir el grafo con `bank-brain/generators/build-dependency-graph.py`.

---

*Generado por `bank-brain/generators/bootstrap-from-inventory.py` el 2026-11-27. Reglas B9 y B12 de Application Modernization.*
