# Portafolio de Productos BanCoppel — Capa de Producto del Vocabulario

> **Artefacto de KB · Capa 1 (Lenguaje) del Gemelo Cognitivo**
> Owner: DT-Vocabulario + SME Industry Banking · Proyecto: BanCoppel Informix · SPE-AM-001
> Creado: 2026-08-07 · Fuente: portafolio público BanCoppel + evidencia de código

## Por qué los productos son vocabulario

Los nombres de variables y SPs del core referencian productos por **código interno** (`cope`, `cci`, `ccc`…). Sin el mapa producto→código, esos tokens quedan crípticos. Este artefacto ancla la **capa de producto** del lenguaje: qué productos existen y con qué códigos internos aparecen en el código. Es la contraparte de negocio de los códigos de dominio que el DBA debe validar.

## Portafolio de productos (portafolio público, ago-2026)

| Categoría | Productos |
|-----------|-----------|
| **Crédito (tarjeta)** | Tarjeta de Crédito BanCoppel: Básica · Oro · Platinum · Infinite · **Grupo Coppel** |
| **Crédito (tienda)** | **Crédito Coppel** (originado en tienda Coppel — modelo dual Coppel/BanCoppel) |
| **Crédito (personal)** | Préstamo Personal BanCoppel (6–24 meses, $3,000–$50,000 MXN) |
| **Débito / cuentas** | Cuenta Efectiva Digital · Cuenta de Cheques · Básico General · Básico de Nómina |
| **Nómina** | Cuenta de Nómina sin comisión |
| **Inversión** | **Pagaré** · **Inversión Creciente** (desde $2,500) |
| **Retiro** | Afore Coppel |
| Otros | Seguros · Remesas · Banca por Internet / App BanCoppel |

## Mapa código interno → producto/concepto

| Código | Significado | Estado | Evidencia |
|--------|-------------|--------|-----------|
| `cope` | **Coppel** (porción/mora del crédito originado en Coppel) | ✅ Validado vs portafolio | Columnas `mora_provi_cope`, `mora_sdo_cope` en `sd_amortiza_credito`; productos "Grupo Coppel" / "Crédito Coppel" |
| `invcrec` | **Inversión Creciente** | ✅ Producto público | `sp_consulta_instruccinversioncreciente`; producto de inversión |
| `pagare` | **Pagaré** | ✅ Producto público | Producto de inversión |
| `sbg` | **Saldo Base Generador** (de intereses) | ✅ Validado por fórmula + término MX | `v_int_sbg_dia = (v_imp_sbg_ccc × (tasa/100))/360 × días` — es la base sobre la que se genera interés; "saldo base" es concepto estándar de banca MX |
| `cci` | **Línea de crédito** — hipótesis: "**Crédito Coppel Individual**" | 🟡 Hipótesis (dominio Créditos) | `dLineaMaxima_cci = dMontoOtor + (dMontoOtor × dPorcTopeValMax_cci)` en `sp_cac_calculalinsugcte` (línea sugerida). En D03 Créditos → encaja crédito individual. Probado "i=interés": descartado (fórmula sin interés) |
| `ccc` | Concepto de crédito Coppel (bucket de interés) | 🟡 Hipótesis (patrón C=Coppel) | `imp_int_sbg` vs `imp_int_ccc`; en D04 Cheques/Cuentas |
| `bccc` | **BanCoppel** + ccc — módulo de crédito del canal digital | 🟡 Hipótesis (patrón BC=BanCoppel) | SPs `sp_bccc_*` **exclusivamente en `bdicnweb` (Canal Digital Web de BanCoppel)** → sostiene BC=BanCoppel; `bccc = b + ccc` (versión banco del concepto ccc) |

> **Hipótesis de prefijo de entidad — EN INVESTIGACIÓN (usuario, 2026-08-07):** las siglas codificarían la entidad originadora — **`C` = Coppel** (tienda), **`BC` = BanCoppel** (banco) — igual que `cope`=Coppel ya confirmado. Evidencia de dominio consistente: `bccc` vive solo en el canal digital de BanCoppel; `cci`/`cope` en Créditos; `ccc` en Cuentas. Coherente con el modelo dual crédito departamental Coppel vs crédito bancario BanCoppel.
>
> **Estado:** `cci`, `ccc`, `bccc`, `tim` quedan **en investigación del usuario** (validación con BanCoppel/DBA). **NO aplicadas al generador de nombres** — regla de no-adivinar: solo las de confianza alta (`cope`, `sbg`) están activas. Al confirmarse, se agregan a `ABBREV` y se mueven a ✅.
| `tim` | Inconcluso | ⏳ PENDIENTE DBA | Solo `cTimEdoCiv`; resto falsos positivos (op**tim**o, úl**tim**as). El genérico "TIM = tasa interés mensual" NO encaja con el uso en código |

**Búsqueda web (2026-08-07):** la mecánica pública de interés de BanCoppel (prorrateo diario desde el corte) coincide con las fórmulas, pero los códigos internos `cci/ccc/bccc/tim` **no aparecen** en documentación pública — son internos. `sbg` se resolvió por fórmula + concepto estándar MX ("saldo base generador").

## Regla de gobernanza

Los códigos ✅ se usan en el generador de nombres (`ABBREV`). Los ⏳ NO se traducen (no inventar — ver regla de validación en [DT-Vocabulario](../../dt/dt-vocabulario/CLAUDE.md)); se escalan al **DBA IBM Informix + Industry Banking** con esta tabla como worklist. Al confirmarse, se mueven a ✅ y se agregan a ABBREV.

## Fuentes

- Portafolio: [bancoppel.com — Tarjeta Grupo Coppel](https://www.bancoppel.com/credito_bcopp/tdcg.html), [Cuenta Nómina](https://www.bancoppel.com/descubre-mas/cuenta-nomina-bancoppel/), [Cuenta Efectiva Digital](https://www.bancoppel.com/descubre-mas/cuenta-efectiva-digital/), [Solicita tu Crédito Coppel/BanCoppel](https://tucredito.bancoppel.com/solicita-tu-credito), [Documentación productos](https://bancario.com.mx/banks/bancoppel)
- Evidencia de código: `variable-types.json` (tipos + LIKE columnas), `business-rules-v3.json`.

---

*v1.0 · 2026-08-07 · Capa de producto del vocabulario; cope=Coppel + invcrec/pagaré validados vs portafolio; cci/ccc/bccc/tim/sbg = worklist para DBA.*
