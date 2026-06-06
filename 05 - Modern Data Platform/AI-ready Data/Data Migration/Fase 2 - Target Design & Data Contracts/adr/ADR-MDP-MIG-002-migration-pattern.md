# ADR-MDP-MIG-002 — Patrón de migración

- Estado: ACEPTADO
- Fecha: 2026-06-01

## Decisión
**Carga inicial bulk + CDC para coexistencia, ejecutada por waves** (Fase 1 wave plan):
Wave 0 Foundation (customizing + GL + Business Partner + mastering CRM) primero.

## Razones
- El acoplamiento oculto (tablas compartidas: company code, moneda, BUT000, GL) obliga a
  migrar la foundation antes que cualquier módulo (un plan por-módulo aislado falla).
- CDC permite parallel run + rollback durante la ventana de coexistencia.

## Consecuencias
- Sync reverso configurado antes del cutover (requisito no negociable de rollback).
- Reconciliación diaria durante coexistencia (conteos + sumas por moneda).
