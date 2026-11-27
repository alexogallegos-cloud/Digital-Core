# Consulta RENAPO — Sistema Descubierto (Application Modernization)
# togaf_type: compliance
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: identity-verification-renapo

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

Validacion de CURP contra el Registro Nacional de Poblacion, parte del expediente de identificacion exigido por las disposiciones de prevencion de lavado de dinero. Absorbe los motores de consumo de servicios web de RENAPO.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `compliance` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `record` |
| `togaf_abb` | `identity-verification-renapo` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `051` | Motores de Consumo de WS (RENAPO) | Motor / Servicio | Alta | Alta | 0 | 1 | 20 |
| `054` | Consulta Renapo | Motor / Servicio | Alta | Media | 0 | 1 | 1 |

Suma del nodo: 0 Stored Procedures declarados, 2 hosts y 21 operaciones diarias.
Motores de datos: informix.
Middleware: INTERACT; Tomcat.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 4 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Interact Router (21) | `calls` | `inbound` | 2 | Web_Service (SOAP) | Alta |

### Con contrapartes que el grafo todavia no modela

Quedan en `dep_catalog` y no generan arista. Son proveedores de servicio, motores de base de datos o sistemas externos sin nodo propio; inventarles un nodo ensuciaria el grafo.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| RENAPO | `calls` | `outbound` | 2 | Web_Service (SOAP) | Alta |

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
