# Ares, Veritran y Veribank — Sistema Descubierto (Application Modernization)
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: innovation
# togaf_abb: low-code-channel-platform

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

120 Stored Procedures y 4,747 operaciones diarias. El Anexo 5 lo situa en la gestion de APIs y orquestacion de servicios, como la capa que resuelve sesion y enrolamiento del cliente.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `integration` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `innovation` |
| `togaf_abb` | `low-code-channel-platform` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `110` | Ares - Veritran - Veribank | Producto de Terceros / SaaS | Baja | Baja | 120 | 0 | 4747 |

Suma del nodo: 120 Stored Procedures declarados, 0 hosts y 4,747 operaciones diarias.
Motores de datos: informix.
Middleware: no declarado.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 2 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| OpenBanking | `calls` | `inbound` | 1 | API_Rest | Media |
| Informix (Core OLTP) | `calls` | `outbound` | 1 | acceso_directo_a_DB (JDBC) | Alta |

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
