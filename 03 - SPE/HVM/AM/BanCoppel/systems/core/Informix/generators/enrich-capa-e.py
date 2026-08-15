"""
enrich-capa-e.py — DEPRECADO per ADR-SPE-AM-010 (2026-08-14)

Este script era un parche sobre parche: intentaba mejorar heurísticamente
los business_name genéricos que generaba enrich-rules.py sin LLM:
  • "Cálculo con umbral/factor N"  — 514 reglas (origen: enrich-rules.py:196)
  • "Fórmula: sp_name_tokens"       — 372 reglas (origen: enrich-rules-v3.py sp_to_name())
  • "Validación: sp_name_tokens"    — 70 reglas  (idem)

Estrategia que usaba (sin API Claude):
  A. Detectar constante de negocio del código (IVA, edad, FX…)
  B. Extraer variable LHS de la asignación
  C. Cruzar tokens con vocabulario de brain.db
  Resultado: nombres levemente mejores pero igualmente heurísticos.

Viola ADR-SPE-AM-010. Ambos generadores fueron deprecados:
  - enrich-rules.py → responsable de "Cálculo con umbral/factor N"
  - enrich-rules-v3.py sección 5 → responsable de "Fórmula:/Validación: sp_name"

Ver: AM/adr/ADR-SPE-AM-010-llm-synthesis-as-generation.md
"""
raise SystemExit(
    "DEPRECADO: enrich-capa-e.py viola ADR-SPE-AM-010. "
    "Usa síntesis LLM (swarm) sobre brain.db en lugar de heurísticas locales."
)
