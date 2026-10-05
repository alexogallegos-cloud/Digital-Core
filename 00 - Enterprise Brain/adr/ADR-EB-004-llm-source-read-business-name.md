# ADR-EB-004 — Síntesis LLM source-read como fuente de business_name

**Estado**: APROBADO
**Fecha**: 2026-09-29
**Autores**: alejandro.gallegos@accenture.com
**Contexto**: Método canónico para asignar nombre de negocio a reglas extraídas de código legacy

---

## Contexto

Cada regla de negocio en el brain.db necesita un `business_name` — un nombre en lenguaje empresarial que describa qué hace esa regla en términos del negocio del cliente, no en términos del código fuente.

Ejemplo de lo que NO es un business_name:
- `"sp_calc_int_mora_liq"` — es el nombre del SP, no un nombre de negocio
- `"validación de parámetros"` — es genérico, no describe nada específico
- `"DEFINE vl_tasa MONEY"` — es un token de código fuente

Ejemplo de lo que SÍ es un business_name:
- `"Cálculo de intereses moratorios sobre saldo liquidado"` — describe el qué del negocio

La pregunta es: ¿cómo se produce el business_name de forma confiable y escalable para miles de reglas?

---

## Decisión

**Claude (LLM) lee el SP o programa completo** (no el fragmento aislado) y sintetiza el business_name en contexto. Este método se llama **source-read** y se registra en brain.db como `enrichment_method = 'llm_synthesis_source_read'`.

### Protocolo canónico (scatter-gather)

1. Exportar reglas con business_name vacío o débil en lotes de ~70-80, incluyendo su `source_file`.
2. Por lote: un agente usa `Read(source_file)` para leer el SP completo — no el fragmento.
3. El agente sintetiza el business_name leyendo el código en contexto completo.
4. Colectar resultados → deduplicar → guardia anti-genérico → cargar con `method='llm_synthesis_source_read'`.
5. Verificar: 0 vacíos, 0 genéricos, 0 tokens de código fuente, 0 errores factuales.

---

## Razones

1. **El fragmento aislado no tiene contexto suficiente**: una línea `IF vl_saldo > 0` sin saber qué calcula el SP completo produce nombres incorrectos o genéricos.
2. **Los heurísticos producen errores factuales**: intentamos 8 variantes de heurísticos en BanCoppel — todos producían nombres con errores (tipo de dato incorrecto en el nombre, proceso equivocado) o genéricos ("procesamiento de datos", "validación de registro").
3. **Claude tiene capacidad multilingüe**: los SPs de Informix SPL mezclan español e inglés — Claude lee ambos y produce el business_name en español empresarial correcto.
4. **Escala con scatter-gather**: 12,812 SPs de BanCoppel se procesaron en olas de 70-80 reglas por agente — paralelo, con guardia de calidad en cada lote.
5. **Trazabilidad**: `enrichment_method` registra cómo se produjo cada nombre — auditable y corregible individualmente.
6. **Consistencia de modelo**: usar siempre Claude (no GPT, no Gemini) garantiza consistencia de calibración entre olas, entre sistemas y entre clientes.

---

## Guardia anti-genérico (obligatoria)

Antes de cargar un lote a brain.db, el detector verifica que ningún business_name:
- Sea idéntico al nombre del SP o a un campo del SP
- Contenga tokens de código (`vl_`, `sp_`, `DEFINE`, `IF`, `RETURN`)
- Sea de longitud < 10 caracteres
- Sea igual a otro business_name ya existente en el mismo componente
- Sea una frase genérica de una lista negra: "proceso de", "validación de", "cálculo de" sin especificar qué

---

## Consecuencias

- El tiempo de síntesis es proporcional al número de reglas — ~70-80 reglas/agente/minuto en modo paralelo.
- Los errores de síntesis son corregibles individualmente: resintetizar el lote afectado con `method='llm_synthesis_source_read'` y reload puntual.
- **Prohibición de heurísticos**: los 8 scripts heurísticos eliminados en BanCoppel (2026-08-20) no deben recrearse en ningún deployment del Enterprise Brain.

---

## Alternativas rechazadas

| Alternativa | Por qué se rechazó |
|-------------|-------------------|
| Heurísticos de nombres (regex, patrones) | 8 variantes probadas — todas producían errores factuales o nombres genéricos. Eliminados definitivamente. |
| Embedding similarity (buscar nombre parecido a uno ya existente) | No genera nombres nuevos — solo copia nombres existentes. Produce inconsistencias cuando el sistema no tiene precedentes. |
| Nombre = campo `display_name` del SP | Solo existe cuando el DBA documentó el SP — menos del 10% de los casos en sistemas legacy. |
| GPT-4 / Gemini | Consistencia requiere el mismo modelo en todas las olas. Calibración de Claude en español técnico bancario validada en BanCoppel y Banamex. |

---

*ADR-EB-004 · Enterprise Brain · Digital Core · Accenture México · 2026-09-29*
