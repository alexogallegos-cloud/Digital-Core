# Empresa Net — Sistema Descubierto (Application Modernization)
# togaf_type: channels
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: corporate-banking-portal

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** 2026-11-27
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

Canal de banca empresarial con 400 Stored Procedures, cuatro hosts y 2,800 operaciones diarias. Resuelve el huerfano banca-empresarial que SIWEB cita al describir el origen de las ordenes de pago entre sucursales.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `channels` |
| `togaf_state` | `baseline` |
| `togaf_system_of` | `differentiation` |
| `togaf_abb` | `corporate-banking-portal` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
| `003` | Empresa Net | Aplicación de Canal | Alta | Muy Alta | 400 | 4 | 2800 |

Suma del nodo: 400 Stored Procedures declarados, 4 hosts y 2,800 operaciones diarias.
Motores de datos: informix.
Middleware: InterAct.

---

## Dependencias conocidas — Anexo 5

El Catalogo de Interfaces AS-IS del Anexo 5 declara 5 interfaces en las que participa este sistema. La direccion viene del propio catalogo, que la declara fila por fila, y por eso no queda como inferida.

### Con sistemas del ecosistema

Estas son las que el brain semilla registra como `cross_dependencies`.

| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |
|-------------|----------|-----------|-----------:|------|-----------|
| Facturación Electrónica CFDI (Interfactura / Detecno) | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| HSM/RSA/Gemalto (seguridad) | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| Informix (Core OLTP) | `calls` | `outbound` | 1 | acceso_directo_a_DB (SPL) | Alta |
| Motor de Pago de Servicios | `calls` | `outbound` | 1 | Web_Service (SOAP) | Alta |
| Sistema Operativo Central (SOC) | `calls` | `outbound` | 1 | Message_broker (InterAct) | Media |

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
