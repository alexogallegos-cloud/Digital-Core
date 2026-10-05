# DT FX Next — Digital Twin
> Iniciativa Apolo 2 · Modernización plataforma FX · STP · CLS

## Pregunta Central
¿Cómo fluye una operación FX desde la cotización hasta el settlement final?

## AS-IS (hoy)
- Cliente cotiza en portal-clientes o directamente (dealer)
- fx-engine calcula tipo de cambio (fuente: confirmado como dato faltante)
- Confirmación al cliente
- Instrucción de pago a payments-legacy
- Settlement bilateral (sin CLS, riesgo de contraparte FX)
- Reporte DIOR a Banxico si > USD 10K

## TO-BE (FX Next)
- Pricing engine en tiempo real con feeds Bloomberg/Reuters
- STP completo — confirmación sin intervención manual
- Conectividad CLS (Payment-vs-Payment) para eliminar riesgo contraparte
- ISO 20022 para mensajería FX cross-border
- Integración con Golden Record para KYC/AML en tiempo real de contraparte

## Sistemas involucrados
- `fx-engine` → `fx-engine-next`
- `mulesoft` — orquestación
- `swift` — mensajería interbancaria
- `treasury` — posiciones y límites
- `golden-record-target` — KYC contraparte
- `cnbv-banxico` — reporting

## Pendientes (DATO-REQUERIDO)
- [ ] Fuente actual de tipos de cambio (¿Bloomberg? ¿Reuters? ¿interno?)
- [ ] Volumen de operaciones FX diarias (por tipo: spot/forward/NDF)
- [ ] STP rate actual (% de operaciones sin intervención manual)
- [ ] Arquitectura técnica del fx-engine actual

---
*v1.0 · 2026-09-22 · Scaffold*
