# Fiduciario — Sistema Descubierto (Application Modernization)
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: trust-services

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

1,000 Stored Procedures declarados sobre Oracle. Es la segunda mayor concentracion de logica almacenada del inventario fuera de Informix.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `processors` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `record` |
| `togaf_abb` | `trust-services` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `124` | Fiduciario | Producto de Terceros / SaaS | Media | Alta | 1000 | 0 | 30 |

Suma del nodo: 1000 Stored Procedures declarados, 0 hosts y 30 operaciones diarias.
Motores de datos: oracle.
Middleware: no declarado.

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
