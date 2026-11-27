# Pago de TDC de Otros Bancos — Sistema Descubierto (Application Modernization)
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: card-payment

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

50,000 operaciones diarias de dispersion de pagos de tarjeta de credito hacia otros bancos.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `processors` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `record` |
| `togaf_abb` | `card-payment` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `026` | Pago de TDC de Otros Bancos | Proceso Batch / Interfaz | Alta | Media | 5 | 2 | 50000 |

Suma del nodo: 5 Stored Procedures declarados, 2 hosts y 50,000 operaciones diarias.
Motores de datos: informix.
Middleware: no declarado.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 3 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| App BanCoppel Móvil | `calls` | `inbound` | 1 | API_Rest | Media |
| Portal de Internet (Banca Por Internet) | `calls` | `inbound` | 1 | API_Rest | Media |
| Informix (Core OLTP) | `calls` | `outbound` | 1 | acceso_directo_a_DB (ODBC) | Alta |

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
