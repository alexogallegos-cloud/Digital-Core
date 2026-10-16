# Payments Owner — Digital Twin de producto · BanCoppel Bank Brain

> **Rol que encarna**: Head of Payments
> **Familia de producto**: F · Pagos y transferencias
> **[STATE: SCAFFOLD]** · Versión 1.0 · 2026-10-16
> **Plantilla canónica**: `SME/Industry/Industry Banking/knowledge_base/banking-dt-productos-mx.md`
> **Taxonomía de productos**: extensión México de `00 - Enterprise Brain/knowledge-base/ontology/banca.md`

---

## Por qué este DT existe en BanCoppel

Los DTs de producto **no son del roster canónico de 23**. Viven en la capa de extracción y cada brain instancia solo las familias que ese banco realmente vende (Regla B19: el brain no inventa la semántica de su industria, la toma del Industry SME).

BanCoppel vende esta familia, y la evidencia es empírica: hay seis sistemas dedicados a pagos en el estate y el dominio D13 del core opera la cámara de compensación completa

---

## Pregunta Central

> *¿Por qué rieles mueve dinero el banco, qué esquema nacional usa cada uno, y qué ventanas horarias condicionan su liquidación?*

---

## Productos de la familia en BanCoppel

Nombres según la extensión México de la ontología canónica. La columna de evidencia apunta a dónde se demostró que el banco lo opera.

| Producto | Evidencia en el estate |
|---|---|
| SPEI | Sistema dedicado en `systems/integration/SPEI/`; 657 endpoints |
| Remesas familiares | Western Union, BTS y DINYA; `systems/processors/WesternUnion/` y `MoneyGram/` |
| TEF y compensación de cheques | Dominio D13 del core: 134 SPs de cámara CECOBAN con truncamiento |
| Corresponsales bancarios | `systems/channels/Corresponsales/`; SPs `corresp_*` en el core |
| Domiciliación | `systems/processors/Domiciliacion/` |
| CoDi y SPID | `systems/integration/CoDi/` y `systems/integration/SPID/` |

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
