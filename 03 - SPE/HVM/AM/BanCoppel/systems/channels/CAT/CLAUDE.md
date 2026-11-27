# CAT — Centro de Atencion Telefonica — Sistema Descubierto (Application Modernization)
# togaf_type: channels
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: contact-center

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

Centro de atencion telefonica con criticidad Alta y complejidad Muy Alta, 200 Stored Procedures. Absorbe CAT Predictivo, que el inventario lista aparte como motor del mismo canal.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `channels` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `differentiation` |
| `togaf_abb` | `contact-center` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `004` | CAT (01-800) Centro de atencion Telefonica | Aplicación de Canal | Alta | Muy Alta | 200 | 2 | 20 |
| `105` | CAT Predictivo | Motor / Servicio | Media | Baja | 4 | 2 | 120 |

Suma del nodo: 204 Stored Procedures declarados, 4 hosts y 140 operaciones diarias.
Motores de datos: informix, postgres.
Middleware: InterAct.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 5 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Informix (Core OLTP) | `calls` | `outbound` | 2 | acceso_directo_a_DB (JDBC) | Alta |
| Interact Router (21) | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| HSM/RSA/Gemalto (seguridad) | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |

### Con contrapartes que el grafo todavia no modela

Quedan en `dep_catalog` y no generan arista. Son proveedores de servicio, motores de base de datos o sistemas externos sin nodo propio; inventarles un nodo ensuciaria el grafo.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| PostgreSQL | `calls` | `outbound` | 1 | acceso_directo_a_DB (JDBC) | Alta |

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
