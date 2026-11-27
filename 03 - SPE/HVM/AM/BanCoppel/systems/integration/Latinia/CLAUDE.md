# Latinia — Sistema Descubierto (Application Modernization)
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: innovation
# togaf_abb: customer-notifications

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

Motor de notificaciones al cliente con 50 Stored Procedures y base propia ademas del core. Absorbe BancoppelSMS, que es la salida por mensaje de texto del mismo motor.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `integration` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `innovation` |
| `togaf_abb` | `customer-notifications` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `030` | Latinia | Motor / Servicio | Alta | Media | 50 | 0 | 20 |
| `052` | BancoppelSMS | Motor / Servicio | Alta | Media | 3 | 1 | 1 |

Suma del nodo: 53 Stored Procedures declarados, 1 hosts y 21 operaciones diarias.
Motores de datos: informix, postgres.
Middleware: Tomcat.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 5 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Informix (Core OLTP) | `feeds` | `outbound` | 1 | acceso_directo_a_DB (carga batch/Control-M) | Alta |
| Informix (Core OLTP) | `calls` | `outbound` | 1 | acceso_directo_a_DB (JDBC) | Alta |
| Interact Router (21) | `calls` | `outbound` | 1 | Message_broker (InterAct) | Alta |
| SIWEB | `calls` | `inbound` | 1 | API_Rest | Alta |
| Crédito Comercial (Orión) | `calls` | `inbound` | 1 | Message_broker (InterAct) | Alta |

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
