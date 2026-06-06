# ADR-MDP-MIG-004 — PII y retención

- Estado: ACEPTADO
- Fecha: 2026-06-01

## Decisión
PII (nombre de cliente/contraparte, datos de contacto) con **tokenización + column-level
security + row-level security** según rol. Clasificación PII por Cybersecurity Data Security
antes de Bronze.

## Consecuencias
- Retención: CNBV 10 años para datos transaccionales; LFPDPPP para datos personales.
- Bronze conserva el dato crudo cifrado at-rest; Silver/Gold exponen tokenizado salvo rol autorizado.
