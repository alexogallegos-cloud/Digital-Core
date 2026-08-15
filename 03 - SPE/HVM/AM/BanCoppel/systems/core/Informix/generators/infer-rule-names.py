#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
infer-rule-names.py — DEPRECADO per ADR-SPE-AM-010 (2026-08-14)

Este script infería business_name heurísticamente usando vocabulario SPL,
patrones financieros (tasa, mora, IVA, ISR, reservas CNBV) y plantillas por tipo.
Algoritmo: LHS del LET/SET → vocab → plantilla. Fallback: nombre del SP tokenizado.

Violación de ADR-SPE-AM-010:
  El extractor NUNCA genera business_name.
  La síntesis LLM es la única fuente del campo — cubre TODAS las clases.
  Cualquier inferencia local (vocabulario, regex, plantillas) produce nombres
  que copian literales del código sin comprensión real de dominio.

Ver: AM/adr/ADR-SPE-AM-010-llm-synthesis-as-generation.md
"""
raise SystemExit(
    "DEPRECADO: infer-rule-names.py viola ADR-SPE-AM-010. "
    "Usa síntesis LLM (swarm) sobre brain.db en lugar de inferencia local."
)
