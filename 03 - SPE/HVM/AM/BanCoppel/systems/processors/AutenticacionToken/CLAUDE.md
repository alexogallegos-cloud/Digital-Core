# Autenticacion por token (CAS, RSA y Gemalto) — Sistema Descubierto (Application Modernization)
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: token-authentication

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

El inventario parte la autenticacion por token en tres filas: el administrador CAS con 70 Stored Procedures y los dos servicios de token RSA y Gemalto. Son la misma capability y se modelan como un nodo. El tipo processors es el mas cercano del canon, que no tiene un tipo de identidad y seguridad.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `processors` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `record` |
| `togaf_abb` | `token-authentication` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `002` | Administrador de token (CAS) | Aplicación de Negocio | Alta | Alta | 70 | 2 | 2 |
| `007` | Autentificación de token RSA/Gemalto | Motor / Servicio | Alta | Media | 1 | 4 | 0 |
| `008` | Autentificación de Token RSA | Motor / Servicio | Alta | Media | 0 | 1 | 0 |

Suma del nodo: 71 Stored Procedures declarados, 7 hosts y 2 operaciones diarias.
Motores de datos: informix, other, postgres.
Middleware: InterAct; InterAct intermedio -> InterAct central.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 2 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Informix (Core OLTP) | `calls` | `outbound` | 2 | acceso_directo_a_DB (SPL) | Alta |

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
