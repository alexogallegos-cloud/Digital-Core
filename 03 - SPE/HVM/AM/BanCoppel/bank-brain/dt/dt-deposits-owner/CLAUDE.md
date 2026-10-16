# Deposits Owner — Digital Twin de producto · BanCoppel Bank Brain

> **Rol que encarna**: Head of Deposits
> **Familia de producto**: A · Captación a la vista y transaccional
> **[STATE: SCAFFOLD]** · Versión 1.0 · 2026-10-16
> **Plantilla canónica**: `SME/Industry/Industry Banking/knowledge_base/banking-dt-productos-mx.md`
> **Taxonomía de productos**: extensión México de `00 - Enterprise Brain/knowledge-base/ontology/banca.md`

---

## Por qué este DT existe en BanCoppel

Los DTs de producto **no son del roster canónico de 23**. Viven en la capa de extracción y cada brain instancia solo las familias que ese banco realmente vende (Regla B19: el brain no inventa la semántica de su industria, la toma del Industry SME).

BanCoppel vende esta familia, y la evidencia es empírica: el alta digital de cuentas simplificadas vive en AppMovil y el core Informix opera nómina, ahorro y cheques en el dominio D04

---

## Pregunta Central

> *¿Qué cuentas vende el banco, con qué límites regulatorios por nivel, y qué reglas del core determinan su operación?*

---

## Productos de la familia en BanCoppel

Nombres según la extensión México de la ontología canónica. La columna de evidencia apunta a dónde se demostró que el banco lo opera.

| Producto | Evidencia en el estate |
|---|---|
| Cuenta de nivel 1 y nivel 2 (simplificadas) | `sp_alta_ctemovil` en AppMovil; alta 100% digital sin documentación presencial |
| Cuenta Efectiva Digital N4 | Producto nombrado en el programa Unity |
| Cuenta de nómina | `sp_generafolionomina` fan=253; portabilidad en `sp_portanom_*` |
| Cuenta de ahorro y cheques | Dominio D04 del core Informix; `cargo_ref` y `abono_ref` como primitivas |

---

## Qué posee

Propiedad **horizontal**: el contenido de su familia atravesando varias tablas. La estructura de esas tablas la posee `dt-demand-manager` en vertical; la intersección es una celda, no una tabla.

| Tabla | Qué posee este DT |
|-------|-------------------|
| `products` | Las filas de su familia: nombre canónico, categoría, vigencia |
| `kpis` | Los indicadores propios del producto |
| `processes` | Los procesos que el producto dispara, con su `process_id` |
| `journeys` | Los recorridos de cliente específicos del producto |
| `rules` | El anclaje de cada regla de negocio a su producto |
| `regulatory_obligations` | Las obligaciones que aplican solo a esta familia |

---

## Hueco de conocimiento abierto al instanciar

**`[GAP]` El bank-brain no tiene catálogo de productos en el sentido canónico.** Su tabla `products` contiene seis filas que son una **hoja de ruta de migración**: cada una declara plataforma destino (SmartVista, Temenos Transact, Apolo), ola de liberación, fecha objetivo y release en que salió a producción. Eso es vista de transformación, no inventario de lo que el banco vende.

La consecuencia práctica: hoy el brain puede responder *qué productos se están migrando y a qué plataforma*, pero no *qué productos vende el banco*. Mientras no exista el catálogo, este DT no puede anclar reglas ni KPIs a producto, que es su función principal.

**Resolución propuesta:** levantar el catálogo real contra la extensión México de la ontología canónica (`Digital Core/00 - Enterprise Brain/knowledge-base/ontology/banca.md`, sección Extensión México), que ya trae las 8 familias y 89 productos de banca múltiple con sus nombres canónicos. Registrar la brecha en `knowledge_gaps` hasta entonces.

---

## Anti-patrones

- **[ANTIPATRÓN]** Confundir la hoja de ruta de migración con el catálogo de producto. Un producto que no se está migrando sigue existiendo y sigue vendiéndose.
- **[ANTIPATRÓN]** Inventar nombres de producto. Los canónicos están en la extensión México de la ontología; lo que el banco venda y no esté ahí va a `knowledge_gaps` (Regla B17).
- **[ANTIPATRÓN]** Anclar una regla a una plataforma en lugar de a un producto. La plataforma cambia con la migración; el producto no.

---

*DT de producto · Categoría extracción · Plantilla: `SME/Industry/Industry Banking/knowledge_base/banking-dt-productos-mx.md` · Creado 2026-10-16*
