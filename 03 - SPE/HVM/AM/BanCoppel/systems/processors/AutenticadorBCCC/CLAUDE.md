# Autenticador BC/CC — Sistema Descubierto (Application Modernization)
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: credential-authentication

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

20,000 operaciones diarias sobre seis hosts. El inventario deja su criticidad en TBC, y el volumen por si solo ya cumple el umbral.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `processors` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `record` |
| `togaf_abb` | `credential-authentication` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `104` | Autenticador BC/CC | Motor / Servicio | TBC | Baja | 6 | 6 | 20000 |

Suma del nodo: 6 Stored Procedures declarados, 6 hosts y 20,000 operaciones diarias.
Motores de datos: informix, postgres.
Middleware: Jboss EAP 7.2.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 5 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Buró de Crédito | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| Bus IBM | `calls` | `outbound` | 1 | Message_broker (BUS) | Alta |
| Informix (Core OLTP) | `calls` | `outbound` | 1 | acceso_directo_a_DB (JDBC) | Alta |

### Con contrapartes que el grafo todavia no modela

Quedan en `dep_catalog` y no generan arista. Son proveedores de servicio, motores de base de datos o sistemas externos sin nodo propio; inventarles un nodo ensuciaria el grafo.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Círculo de Crédito | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
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
