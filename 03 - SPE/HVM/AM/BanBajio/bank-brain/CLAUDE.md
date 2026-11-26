# bank-brain de BanBajío — Enterprise Brain del cliente

> Hereda `CLAUDE.md` de `03 - SPE/HVM/AM/BanBajio/`.
> Asset que lo gobierna: `00 - Enterprise Brain/`. Canon: `canon/brain-rules.md`.

```
# brain_type: enterprise
# hemisphere: change y run
# industry: banca
# industry_sme: SME/Industry/Industry Banking
# status: discovered
```

---

## Qué es

El gemelo cognitivo de Banco del Bajío. Un motor de razonamiento que entiende
cómo funciona el negocio y la tecnología que lo habilita, y que con ese
entendimiento explica, anticipa y aconseja.

Hoy entiende el negocio y no entiende la tecnología, y eso está declarado, no
disimulado. El estado es `discovered`, no `active`: el brain no se activa hasta
que el Brain Auditor da PASS.

El nombre es `bank-brain` y no `banbajio-brain` porque la semántica la determina
la industria y no el cliente (Regla B18). Dos bancos comparten vocabulario,
capacidades, procesos y regulador; un banco y una aseguradora no comparten
ninguno.

---

## Cómo se construye

```bash
python build-bank-brain.py              # construye bank-brain.db
python build-bank-brain.py --dry-run    # construye en memoria, no escribe
python build-bank-brain.py --validate   # corre el Brain Auditor del asset
```

El pipeline es idempotente por DROP explícito: un rebuild produce siempre el
mismo resultado. Las tablas de runtime (`queries`, `action_catalog`, `actions`)
son la excepción y se preservan entre builds, porque su contenido no se puede
reconstruir desde la fuente.

### El esquema no vive aquí

`ADR-EB-006` fija que `00 - Enterprise Brain/templates/schema.sql` es la única
fuente de verdad del DDL. Este brain **no guarda copia local**, a diferencia de
otras instancias del estate. La razón es el modo de falla que el propio asset
documentó: una copia que nadie compara con el original deriva, y nadie se entera
hasta que el canon y la instancia afirman cosas distintas. El build resuelve el
esquema subiendo por el árbol y falla ruidosamente si no lo alcanza.

La Regla B1 pide que el brain responda sin el asset montado, y eso lo cumple
`bank-brain.db` una vez construida. Construirla sí requiere el canon vigente, que
es justo lo que se quiere.

---

## Qué sabe hoy

| Tabla | Filas | Qué contiene |
|-------|-------|--------------|
| `processes` | 28 | El modelo operativo Digital Bank 4.0 completo, tomado del Industry SME |
| `knowledge_gaps` | 22 | 15 propios y 7 generados por fuentes ausentes |
| `source_catalog` | 14 | 7 fuentes activas, todas públicas, y 7 ausentes, todas del cliente |
| `measurements` | 12 | Cifras del tercer trimestre de 2026 y de canal digital |
| `capabilities` | 8 | 6 del Banking ETB V5.0 y 2 extensiones propias del banco |
| `stakeholders` | 8 | 3 áreas por rol y 5 reguladores |
| `products` | 6 | Líneas de negocio, no productos contratables |
| `business_milestones` | 5 | De la fundación en 1994 al relevo directivo de 2026 |
| `strategic_drivers` | 5 | Lo que la institución declara públicamente que persigue |
| `knowledge_lineage` | 128 | Toda afirmación con su nivel, su fuente y su vigencia |

Lo que **no** sabe: el núcleo bancario, el inventario de aplicaciones, los KPI
por producto, el catálogo comercial y la cobertura real de los 28 procesos. Los
cinco están declarados como huecos con su pregunta concreta y su dueño.

---

## Las dos extensiones propias

El Banking ETB V5.0 no modela banca de segundo piso ni el canal de agentes
parafinancieros, y esas dos cosas son el diferenciador de este banco. Entraron
como `is_extension=1`, que es el mecanismo que la Regla B20 prevé para lo que una
empresa tiene y su catálogo de industria no nombra.

No es un parche. Es un hallazgo sobre el modelo global, del mismo tipo que la
ausencia de remesas que el Industry Banking SME ya documentó, y está declarado
en `GAP-BBAJIO-011` para que suba a ese SME como patrón anonimizado. La frontera
de cliente de la Regla B42 es absoluta: sube el patrón, nunca el caso.

---

## Niveles de certeza en este brain

Con corpus exclusivamente público, nada que describa la tecnología del banco
puede entrar en gold. Lo publicado por la propia emisora es intención o reporte,
no el sistema productivo.

Lo único gold aquí son los reguladores, porque su fuente es la ley, que no es
debatible. Todo lo demás es silver cuando tiene fuente fechada y bronze cuando
la fuente no permite verificar vigencia, como la fecha de fundación, que tres
fuentes contradicen entre sí.

Esto tiene una consecuencia operativa directa: **ningún gate de decisión puede
sostenerse en este brain todavía**, porque los gates exigen gold.

---

## Lo que falta para pasar a `active`

1. Correr el Brain Auditor y atender lo que reporte.
2. Cerrar `GAP-BBAJIO-001`, el núcleo bancario, que bloquea todo lo demás.
3. Poblar `coverage_status` en los 28 procesos con evidencia del estate, no con
   suposiciones.
4. Instanciar el roster de Digital Twins. `dt/roster-dt.md` está copiado del
   asset y ningún DT está instanciado todavía.
5. Generar el portal desde `generators/build-portal.py`. La Regla P4 es
   terminante: `portal/*.html` nunca se escribe a mano.

---

*Creado 2026-11-25. Instanciado desde `00 - Enterprise Brain/templates/`.*
