# Consulta INE — Sistema Descubierto (Application Modernization)
# togaf_type: compliance
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: identity-verification-ine

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

10,000 operaciones diarias de verificacion de identidad contra el padron electoral, obligatoria en el expediente de identificacion del cliente. Absorbe el Bus INE 4.0 y los motores de consumo de servicios web de INE, que el inventario lista aparte.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `compliance` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `record` |
| `togaf_abb` | `identity-verification-ine` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `028` | Consulta INE (Bus INE 4.0) | Motor / Servicio | Alta | Media | 1 | 2 | 0 |
| `029` | Consulta INE | Motor / Servicio | Alta | Media | 10 | 0 | 10000 |
| `115` | Motores de Consumo de WS(INE) | Motor / Servicio | Alta | Alta | 20 | 0 | 20 |

Suma del nodo: 31 Stored Procedures declarados, 2 hosts y 10,020 operaciones diarias.
Motores de datos: informix.
Middleware: BUS IBM; INTERACT; Interact Bus.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 4 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Interact Router (21) | `calls` | `inbound` | 1 | Web_Service (SOAP) | Media |
| Informix (Core OLTP) | `calls` | `outbound` | 1 | acceso_directo_a_DB (SPL) | Alta |

### Con contrapartes que el grafo todavia no modela

Quedan en `dep_catalog` y no generan arista. Son proveedores de servicio, motores de base de datos o sistemas externos sin nodo propio; inventarles un nodo ensuciaria el grafo.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| INE (RENAPO/INE WS) | `calls` | `outbound` | 2 | Web_Service (SOAP) | Alta |

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
