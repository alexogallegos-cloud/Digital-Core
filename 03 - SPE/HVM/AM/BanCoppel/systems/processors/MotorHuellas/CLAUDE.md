# Motor de Huellas — Sistema Descubierto (Application Modernization)
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: biometric-authentication

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

Autenticacion biometrica con complejidad Alta. Resuelve el huerfano gestor-central-huellas que SIWEB cita como el servicio de huella para OFI y SIWEB resuelto contra bdinteg. Absorbe el Motor de Rostros, que es la misma capability por otra modalidad.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `processors` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `record` |
| `togaf_abb` | `biometric-authentication` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `032` | Motor de Rostros | Motor / Servicio | Baja | Media | 20 | 1 | 5 |
| `033` | Motor de Huellas | Motor / Servicio | Media | Alta | 20 | 1 | 5 |

Suma del nodo: 40 Stored Procedures declarados, 2 hosts y 10 operaciones diarias.
Motores de datos: informix.
Middleware: BUS.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 9 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Bus IBM | `calls` | `outbound` | 2 | Message_broker (BUS) | Media |
| Informix (Core OLTP) | `calls` | `outbound` | 2 | acceso_directo_a_DB (JDBC) | Alta |
| Interact Router (21) | `calls` | `outbound` | 1 | Message_broker (InterAct) | Media |
| Oficina Financiera Integral (OFI) | `feeds` | `inbound` | 1 | Batch (SFTP) | Alta |
| Oficina Financiera Integral (OFI) | `calls` | `inbound` | 1 | Especializada (Biometria) | Media |

### Con contrapartes que el grafo todavia no modela

Quedan en `dep_catalog` y no generan arista. Son proveedores de servicio, motores de base de datos o sistemas externos sin nodo propio; inventarles un nodo ensuciaria el grafo.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Servidor de Imágenes | `calls` | `outbound` | 2 | Web_Service (SOAP) | Alta |

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
