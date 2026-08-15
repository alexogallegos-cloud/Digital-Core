#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
enrich-rules.py — DEPRECADO per ADR-SPE-AM-010 (2026-08-14)

Este script generaba business_name heurísticamente.
Caso concreto: nivel 5 producía f"Cálculo con umbral/factor {key_nums[0]}" cuando la
fórmula contenía una constante numérica, sin ningún contexto de dominio real.

Viola la regla fundamental de Application Modernization:
  El extractor NUNCA genera business_name.
  La síntesis LLM es la única fuente del campo — cubre TODAS las clases
  (NEGOCIO, INFRAESTRUCTURA, ENSAMBLAJE_REPORTE, PRESENTACIÓN).

Ver: AM/adr/ADR-SPE-AM-010-llm-synthesis-as-generation.md
"""
raise SystemExit(
    "DEPRECADO: enrich-rules.py viola ADR-SPE-AM-010. "
    "Usa síntesis LLM (swarm) sobre brain.db en lugar de heurísticas locales."
)
