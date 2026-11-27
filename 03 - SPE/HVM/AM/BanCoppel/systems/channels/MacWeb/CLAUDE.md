# MAC WEB — Sistema Descubierto (Application Modernization)
# togaf_type: channels
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: customer-servicing

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

Dos millones de operaciones diarias sobre Informix con cuatro programas servidores conectados al Interact Router. El significado del acronimo MAC no esta confirmado en ninguna fuente del programa.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `channels` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `differentiation` |
| `togaf_abb` | `customer-servicing` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `012` | MAC WEB | Aplicación de Negocio | Alta | Alta | 10 | 2 | 2000000 |

Suma del nodo: 10 Stored Procedures declarados, 2 hosts y 2,000,000 operaciones diarias.
Motores de datos: informix.
Middleware: InterAct Router (mensajería distintos formatos), 8 o 10 canales conexión a router MacWeb 4 programas servidores.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 2 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| HSM/RSA/Gemalto (seguridad) | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
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
