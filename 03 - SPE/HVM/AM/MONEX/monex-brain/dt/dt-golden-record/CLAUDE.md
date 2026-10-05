# DT Golden Record — Digital Twin
> Iniciativa Apolo 3 · MDM · Primer modelo de datos canónico MONEX

## Pregunta Central
¿Qué sistemas son fuente de datos maestros hoy y cómo se resuelven los conflictos entre ellos?

## Situación Actual — GAP CRÍTICO
**MONEX HOY NO TIENE MDM ni Data Catalog.** Los datos maestros están dispersos:
- Clientes en portal-clientes + fx-engine + payments-legacy (sin sincronía garantizada)
- Contrapartes en fx-engine + treasury
- Sin un único "golden record" para ninguna entidad

Impacto:
- Imposible responder cross-sistema "dame todos los pagos de esta contraparte"
- Riesgo regulatorio real: AML screening incompleto cross-jurisdicción
- Duplicados de entidades en múltiples sistemas sin reconciliación

## TO-BE (Golden Record Apolo)
- MDM centralizado como servicio consumible por todos los sistemas
- Domains: Cliente · Contraparte · Instrumento · Cuenta
- Confidence score por atributo y fuente
- Conflict resolution automatizado (reglas de maestro) con fallback humano
- APIs REST para consulta (read) y notificación de cambios (events)

## Sistemas involucrados (fuentes de datos maestros hoy)
- `fx-engine` — contrapartes, instrumentos
- `payments-legacy` — clientes, cuentas
- `portal-clientes` — datos cliente B2C
- `api-marketplace` — datos empresa B2B
- `cnbv-banxico` — entidades reguladas validadas

## Golden Record Target
- `golden-record-target` — el sistema TO-BE que centraliza

## Pendientes (DATO-REQUERIDO)
- [ ] Inventario de entidades maestras por sistema y atributos que cada uno mantiene
- [ ] Reglas de maestro: ¿quién gana cuando hay conflicto?
- [ ] Volumen de registros por dominio (clientes, contrapartes)
- [ ] Casos reales de inconsistencia cross-sistema

---
*v1.0 · 2026-09-22 · Scaffold*
