# Motor de Pago de Servicios — Sistema Descubierto (Application Modernization)
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: bill-payment

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

300 Stored Procedures sobre doce hosts y doce interfaces en el Anexo 5, nueve de ellas como origen. Es la aplicacion sin nodo con mas interfaces declaradas de todo el catalogo.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `processors` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `record` |
| `togaf_abb` | `bill-payment` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `037` | Motor de Pago de Servicios | Motor / Servicio | Alta | Alta | 300 | 12 | 300 |

Suma del nodo: 300 Stored Procedures declarados, 12 hosts y 300 operaciones diarias.
Motores de datos: informix, postgres.
Middleware: InterAct / Bus.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 12 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| App BanCoppel Móvil | `calls` | `inbound` | 1 | API_Rest | Media |
| Portal de Internet (Banca Por Internet) | `calls` | `inbound` | 1 | Message_broker (InterAct) | Alta |
| Informix (Core OLTP) | `calls` | `outbound` | 1 | acceso_directo_a_DB (SPL) | Media |
| Empresa Net | `calls` | `inbound` | 1 | Web_Service (SOAP) | Alta |

### Con contrapartes que el grafo todavia no modela

Quedan en `dep_catalog` y no generan arista. Son proveedores de servicio, motores de base de datos o sistemas externos sin nodo propio; inventarles un nodo ensuciaria el grafo.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| ANTAD | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| CARDIF | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| DISH | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| Gobierno CDMX (pago servicios) | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| Recargas Tiempo Aire | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| SKY (pago servicios) | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| Servicios/Ecommerce Coppel | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| Telmex (pago servicios) | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |

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
