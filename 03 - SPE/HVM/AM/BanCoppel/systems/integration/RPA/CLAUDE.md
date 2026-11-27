# RPA (Robots) — Sistema Descubierto (Application Modernization)
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: innovation
# togaf_abb: robotic-process-automation

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

137 hosts, el mayor despliegue del inventario, y ocho interfaces en el Anexo 5, todas como origen y seis por acceso directo a base. Un automata que lee la base del core por ODBC es deuda de integracion y merece visibilidad propia.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `integration` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `innovation` |
| `togaf_abb` | `robotic-process-automation` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `047` | RPA (Robots) | Proceso Batch / Interfaz | Alta | Media | 2 | 137 | 80 |

Suma del nodo: 2 Stored Procedures declarados, 137 hosts y 80 operaciones diarias.
Motores de datos: informix.
Middleware: no declarado.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 8 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Aclaraciones | `calls` | `outbound` | 1 | acceso_directo_a_DB (ODBC) | Alta |
| Crédito Comercial (Orión) | `calls` | `outbound` | 1 | acceso_directo_a_DB (ODBC) | Alta |
| Informix (Core OLTP) | `calls` | `outbound` | 1 | acceso_directo_a_DB (ODBC) | Alta |
| Pago de Remesas WU/Orlandi/Vigo | `calls` | `outbound` | 1 | acceso_directo_a_DB (ODBC) | Alta |
| Sistema Operativo Central (SOC) | `calls` | `outbound` | 1 | acceso_directo_a_DB (ODBC) | Alta |

### Con contrapartes que el grafo todavia no modela

Quedan en `dep_catalog` y no generan arista. Son proveedores de servicio, motores de base de datos o sistemas externos sin nodo propio; inventarles un nodo ensuciaria el grafo.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| ESQ (Monitoreo ATMs) | `calls` | `outbound` | 1 | Especializada (RPA/scraping) | Alta |
| SQL Server | `calls` | `outbound` | 1 | acceso_directo_a_DB (ODBC) | Alta |
| Segurifact | `calls` | `outbound` | 1 | Especializada (RPA/scraping) | Alta |

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
