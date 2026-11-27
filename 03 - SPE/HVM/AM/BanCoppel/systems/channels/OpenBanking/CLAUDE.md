# OpenBanking — Sistema Descubierto (Application Modernization)
# togaf_type: channels
# togaf_state: transitional
# togaf_system_of: differentiation
# togaf_abb: open-banking-apis

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

Entra por el criterio regulatorio y no por volumen. Las disposiciones de APIs de la Ley Fintech lo vuelven obligatorio, y el Catalogo de Interfaces del Anexo 5 ya le reconoce cuatro interfaces.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `channels` |
| `togaf_state` | `transitional` |
| `togaf_system_of` | `differentiation` |
| `togaf_abb` | `open-banking-apis` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `010` | OpenBanking | Motor / Servicio | Media | Baja | 0 | 2 | 0 |

Suma del nodo: 0 Stored Procedures declarados, 2 hosts y 0 operaciones diarias.
Motores de datos: postgres.
Middleware: no declarado.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 4 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Ares - Veritran - Veribank | `calls` | `outbound` | 1 | API_Rest | Media |
| HSM/RSA/Gemalto (seguridad) | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |

### Con contrapartes que el grafo todavia no modela

Quedan en `dep_catalog` y no generan arista. Son proveedores de servicio, motores de base de datos o sistemas externos sin nodo propio; inventarles un nodo ensuciaria el grafo.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| MongoDB | `calls` | `outbound` | 1 | acceso_directo_a_DB (JDBC) | Alta |
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
