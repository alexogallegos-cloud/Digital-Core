# DT Motor de Pagos — Digital Twin
> Iniciativa Apolo 1 · Cloud-native · ISO 20022 · CLS Settlement target

## Pregunta Central
¿Qué sistemas tocan un pago desde la instrucción del cliente hasta la liquidación final?

## AS-IS (hoy)
- Instrucción entra por portal-clientes o API B2B
- MuleSoft enruta hacia payments-legacy
- payments-legacy procesa y conecta con SPEI (MXN) o SWIFT (internacional)
- Liquidación bilateral (sin CLS)
- DIOR reportado a Banxico desde payments-legacy

## TO-BE (Motor de Pagos Apolo)
- Instrucción en ISO 20022 nativo
- Motor de pagos cloud-native con enrutamiento inteligente
- Conectividad CLS para FX payments (PvP)
- Reconciliación automática
- DIOR generado automáticamente desde el motor

## Sistemas involucrados
- `portal-clientes` — punto de entrada
- `api-marketplace` — entrada B2B
- `mulesoft` — orquestación y enrutamiento
- `payments-legacy` → `motor-pagos-apolo` (reemplazo)
- `spei` — pagos MXN
- `swift` — pagos internacionales
- `cnbv-banxico` — DIOR, reporting

## Pendientes (DATO-REQUERIDO)
- [ ] Volúmenes actuales de pagos por canal y destino
- [ ] SLA actuales del payments-legacy
- [ ] Arquitectura detallada del motor legacy
- [ ] Requisitos técnicos CLS para onboarding MONEX

---
*v1.0 · 2026-09-22 · Scaffold*
