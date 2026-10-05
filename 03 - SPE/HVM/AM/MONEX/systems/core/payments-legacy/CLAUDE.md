# Payments Legacy — Application Modernization Agent
> togaf_type: core | togaf_state: baseline→deprecated | togaf_system_of: record | togaf_abb: payment-processing
> bian_domains: payment-execution, payment-initiation

## Sistema
Motor de pagos legacy de MONEX — procesa pagos SPEI y SWIFT.
Será **reemplazado** por el Motor de Pagos Apolo (Iniciativa 1).

## Estado
- `togaf_state: baseline` (HOY) → `deprecated` (cuando Motor de Pagos Apolo entra en producción)
- Iniciativa de decommission: `motor-pagos` (Apolo)

## Pendientes (DATO-REQUERIDO)
- [ ] Plataforma (¿Finacle? ¿custom? ¿SWIFT Alliance?)
- [ ] Volumen diario SPEI y SWIFT
- [ ] Capabilities específicas (lista completa para Strangler-Fig)
- [ ] Dependencias downstream

*v1.0 · 2026-09-22 · Scaffold*
