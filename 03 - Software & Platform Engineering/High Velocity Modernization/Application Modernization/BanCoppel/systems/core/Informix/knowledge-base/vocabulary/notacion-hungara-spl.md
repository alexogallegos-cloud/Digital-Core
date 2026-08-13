# Notación húngara SPL — Convención de nombres de variables BanCoppel

> **Artefacto de KB · Capa 1 (Lenguaje) del Gemelo Cognitivo**
> Owner: DT-Vocabulario · Proyecto: BanCoppel Informix · SPE-AM-001
> Creado: 2026-08-07

## Qué es y por qué importa

Los desarrolladores de BanCoppel nombran las variables de sus Stored Procedures siguiendo una convención de **notación húngara**: cada identificador arranca con una o dos letras que codifican el *scope* (dónde vive la variable) y a veces el *tipo* del dato. `vsdodisp` no es una palabra; es `v` (variable local) + `sdo` (saldo) + `disp` (disponible), es decir, "el saldo disponible". `mMontoCheque` es `m` (money) + `MontoCheque`.

Entender esta convención es una **llave para leer todo el código**, no solo un detalle cosmético. Sin ella, cada nombre de variable parece ruido; con ella, el prefijo te dice de entrada si estás viendo un monto de dinero, una fecha, una bandera de decisión o un simple contador. Por eso vive en el KB y no escondido en un script.

## Prefijos de SCOPE — son ruido, se quitan

Indican dónde vive la variable. No aportan significado de negocio: se eliminan al humanizar el nombre.

| Prefijo | Significado | Ejemplo | Se lee como |
|---------|-------------|---------|-------------|
| `v` | Variable local de trabajo (el más común) | `vmonto` | monto |
| `w` | Work variable (trabajo intermedio) | `wsaldo` | saldo |
| `p` | Parámetro de entrada del SP | `pcodret` | código de retorno |
| `g` | Global | `gfecha` | fecha |
| `l` | Local | `lcont` | contador |

En el pipeline de inferencia (`generators/infer-rule-names.py`) esto lo implementa `_strip_hungarian`, que quita el prefijo de scope **solo cuando el resto de la palabra resuelve a un término de negocio conocido**. Así `vmonto`→"monto" pero `venta` se queda intacto (el resto, "enta", no resuelve), evitando romper palabras reales que casualmente empiezan con `v`.

## Prefijos de TIPO — son HIPÓTESIS que se VALIDAN contra el `DEFINE`

Una letra inicial *puede* codificar el tipo del dato, pero **no se asume: se valida contra la declaración `DEFINE` de la variable en el SPL.** Esta es la regla de oro.

### Regla de validación (obligatoria)

> Si el prefijo es notación húngara de tipo, **debe coincidir con el tipo declarado**. Si no coincide, la letra **no es prefijo de tipo** — es semántica (p.ej. `c`=cálculo), inicial de palabra, o ruido inconsistente del legacy.

En Informix SPL las variables se declaran con `DEFINE <var> <TIPO>;`. Ese `DEFINE` es la verdad de fondo:

| Hipótesis por prefijo | Se confirma si el `DEFINE` es… | Se refuta si es… |
|-----------------------|-------------------------------|------------------|
| `m` = money | `MONEY` / `DECIMAL` | CHAR/VARCHAR → no es money |
| `d` = date | `DATE` / `DATETIME` | numérico/char → no es date |
| `i`/`n` = numérico | `INTEGER`/`SMALLINT`/`DECIMAL` | CHAR → no es numérico |
| `s`/`c` = string/char | `CHAR`/`VARCHAR` | MONEY/DECIMAL → **no es char** |
| `b` = boolean | `SMALLINT`/`CHAR(1)` | — |

**Caso probado (2026-08-07):** `cint1257` en `bdicred_spl_soldif1.sql` se declara `DEFINE x_cint1257_calc MONEY(14,2)`. La hipótesis "`c` = char" se **refuta** (es MONEY), luego la `c` no es tipo — es semántica (`c`=cálculo, y el sufijo `_calc` lo confirma). Conclusión doble: (1) el nombre correcto es "cálculo de interés", (2) es un **importe monetario → riesgo de equivalencia por redondeo**.

### Evidencia empírica — 2,935,351 declaraciones DEFINE (12,863 SPs, 2026-08-07)

Extraídas por `generators/extract-var-types.py` → `variable-types.json`. Consistencia de cada prefijo contra el tipo declarado real:

| Prefijo | Tipo dominante | Consistencia | Veredicto |
|---------|---------------|--------------|-----------|
| `c` | CHAR | 96% | Húngara de tipo **real** |
| `i` | INT | 96% | Húngara de tipo **real** |
| `m` | MONEY | 84% | Húngara de tipo **real** (señal de riesgo de redondeo) |
| `n` | CHAR | 77% | Húngara de tipo **real** |
| `b` | BOOL | 70% | Borderline |
| `d` | DATE | 41% | **Ambiguo** — no es date confiable |
| `s` | CHAR | 53% | **Ambiguo** |
| `f` `r` `t` `v` `e` | varios | <65% | **Ambiguo** (semántica/ruido) |

Distribución global de tipos: CHAR 58.5% · INT 25.1% · MONEY 9.1% · DATE 4.3% · DATETIME 0.8% · FLOAT 0.6% · BOOL 0.5% · LIKE 0.2%.

**Lecciones:** (1) los prefijos confiables son `c/i/m/n`; `d/s/f/r/t/v/e` NO — no asumirlos. (2) `cint1257`=MONEY es una de las excepciones del 4% de `c`: la regla de validación (comparar contra el `DEFINE`) es precisamente el mecanismo para cazarlas. (3) La fuente de verdad no es el prefijo sino el tipo declarado por variable en `variable-types.json`.

### CamelCase del código = delimitador de sub-palabras (validado 2026-08-07)

Cuando la variable usa CamelCase en el source, las mayúsculas **delimitan las sub-palabras exactamente** — es la mejor señal para descomponer nombres compuestos:

| Variable en código | Descomposición | Nombre de negocio |
|--------------------|----------------|-------------------|
| `cFechCortMesSig` | Fech·Cort·Mes·Sig | fecha corte mes siguiente |
| `cFechCortInmAnt` | Fech·Cort·**Inm·Ant** | fecha corte **inmediato anterior** |
| `vIVAimpcomcte` | IVA·imp·com·cte | IVA importe comisión cliente |
| `fnNumeroSemana` | **fn**·Numero·Semana | número de semana (fn = prefijo de función, se descarta) |
| `v_idpaisnacionalidad` | id·pais·nacionalidad | país de nacionalidad |

`humanize_var_expr` parte por `_` **y** por CamelCase, expande cada sub-token vía ABBREV, y descarta prefijos de función/proc (`fn`, `sp`, `usp`). Los glued en minúsculas puras (sin CamelCase) usan el split de dos niveles (conservador + agresivo con tiling limpio). Sub-tokens validados agregados esta sesión: cort→corte, sig→siguiente, inm→inmediato, ant→anterior, tri→trimestre (evidencia: fecha 31-mar), pais→país, cnom→nombre, lin→línea.

### Cómo se aprovecha (leverage)

El tipo **declarado** (no el prefijo adivinado) es la señal:
- `MONEY`/`DECIMAL` en el LHS → regla monetaria → sube `equivalence_risk` (redondeo/truncamiento, CUB B-5, base 360/365).
- `DATE`/`DATETIME` → lógica temporal (vencimientos, corte).
- `SMALLINT`/`CHAR(1)` con dominio {0,1,'S','N'} → bandera → sugiere ESTADO/VALIDACIÓN.

Esto requiere extraer los `DEFINE` del source (`source/informix/*.sql`) a un mapa `variable→tipo declarado` por SP. Es el siguiente build (owner DT-Reglas + DBA IBM Informix para la semántica de tipos Informix).

## Propagación de constantes — LET var = literal como señal semántica

**Tercera señal de descubrimiento** (complementaria al `DEFINE` de tipo y al CamelCase de nombre).

Cuando un SP asigna un literal numérico o de cadena a una variable —`LET vValIva = 0.16`— ese valor es una constante de negocio embebida en el código. Descubrirla permite:

1. **Identificar tasas regulatorias encubiertas.** `vValIva = 0.16` no parece nada; 0.16 es la tasa del IVA en México (LIVA Art.1). Sin la asignación, leer `TRUNC(vMontoCom * vValIva, 2)` no revela que es un cálculo fiscal — el prefijo `vVal` solo dice "variable de valor". Con la asignación, el análisis semántico puede vincular `vValIva → 0.16 → IVA 16%` y subir la coherencia de la regla.

2. **Descubrir parámetros de umbral hardcodeados.** `LET vLimPLD = 10000` → UMBRAL_PLD (GAFI/UIF, $10,000 MXN). `LET vDiasVenc = 90` → umbral de cartera vencida (CUB B-5). Estos valores son la "intención regulatoria" codificada como constante y deben migrar como configuración, no como magic number.

3. **Confirmar factores fiscales implícitos.** En México: `0.16` / `16/100` → IVA; `8/100` → IVA frontera (zona libre fronteriza); `1.16` → monto con IVA incluido; `0.0090` / `0.90%` → tasa ISR retención sobre intereses 2026 (LISR Art.54/135).

### Patrón de detección

```sql
-- En cualquier línea del SP:
LET <var> = <literal_numérico_o_cadena>

-- Ejemplos capturados:
LET vValIva   = 0.16       -- tasa IVA 16%
LET vValIvaF  = 0.08       -- tasa IVA frontera 8%
LET vLimPLD   = 10000      -- umbral PLD (GAFI)
LET vTasaIsrT = 0.0090     -- tasa ISR 2026 (LISR 54/135)
LET vDiasVenc = 90         -- días cartera vencida (CUB B-5)
LET cCodRet   = '207'      -- código de error: cuenta no existe
```

### Implementación en el pipeline

`generators/validate-rules-vs-code.py` implementa esto con `build_const_map(lines)`:

```python
_CONST_RE = re.compile(
    r'\bLET\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*'
    r"(['\"][\d\.\,]+['\"]|\d+(?:\.\d+)?)",
    re.IGNORECASE,
)
```

Escanea el SP completo, construye `{var_lower: literal}`, y en el scoring de cada regla expande el contexto: si `vValIva` aparece en las ±8 líneas y `vvaliva → '0.16'` está en el mapa, agrega `'0.16'` y `'16'` a los tokens del código antes de calcular el solapamiento con `business_name`. Esto permite que "Cálculo con umbral/factor 16" matchee correctamente con código que usa `vValIva = 0.16`.

### Regla de descubrimiento

> Todo `LET <var> = <literal>` que sea un valor con significado regulatorio o financiero conocido **debe declararse en el vocabulario** (`knowledge-base/vocabulary/`) y **migrar como parámetro de configuración**, no como constante embebida. El valor hardcodeado es technical debt además de riesgo regulatorio (un cambio de tasa requiere redeployment).

Tasas y umbrales sujetos a cambio regulatorio frecuente en MX: IVA (16%/8%), ISR sobre intereses (varía anualmente por SAT), umbrales PLD (varía por nivel de riesgo), índices CUB (CNBV).

## Caveats — es legacy, no es 100% consistente

La convención es una guía, no una ley. En 15+ años de mantenimiento hay variables sin prefijo, prefijos mal usados y colisiones (una `c` puede ser char, cursor o el arranque de "cuenta"). Por eso:

- El strip de scope es **condicional** (solo si el resto resuelve), nunca ciego.
- El prefijo de tipo es **evidencia, no verdad**: se cruza con el uso real en el código antes de concluir. Un `m*` es fuerte indicio de dinero, pero se confirma viendo la expresión.
- Cualquier inferencia dudosa se escala al **DBA IBM Informix** (dueño de la semántica de tipos Informix: MONEY, DECIMAL, DATE) y a **Industry Banking** (semántica de negocio).

## Relación con otros artefactos

- Lo consume `_strip_hungarian` y las funciones `humanize_var` / `humanize_var_expr` del generador de nombres.
- Complementa la tabla `ABBREV` (owner DT-Vocabulario): scope se quita, el cuerpo se expande vía ABBREV.
- Análisis de tipos previo relacionado: `param-type-analysis.json` y `mask-units-analysis.json` en esta misma carpeta.

---

*v1.0 · 2026-08-07 · DT-Vocabulario · Documenta la convención de notación húngara para lectura de código y para el pipeline de inferencia de nombres (scope=ruido, tipo=señal).*
