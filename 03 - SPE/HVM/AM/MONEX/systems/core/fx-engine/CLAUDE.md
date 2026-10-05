# FX Engine — Application Modernization Agent
> togaf_type: core | togaf_state: baseline | togaf_system_of: record | togaf_abb: fx-processing
> bian_domains: fx-management, position-management

## Sistema
Motor FX de MONEX: procesa operaciones spot, forward, NDF y opciones de divisas.
Núcleo del negocio de MONEX — el sistema de más alto valor y criticidad.

## Estado de Conocimiento
- Estado: SCAFFOLD — estructura creada, conocimiento por construir
- Fuente de datos disponible: ninguna aún (pendiente acceso a arquitectura)
- Brain: por construir

## Pendientes (DATO-REQUERIDO)
- [ ] Arquitectura técnica (plataforma, lenguaje, BD)
- [ ] Volumen de operaciones diarias por tipo (spot/forward/NDF/opciones)
- [ ] Interfaces externas (Bloomberg, Reuters, bancos corresponsales)
- [ ] SLAs actuales (latencia, disponibilidad)
- [ ] Integraciones con MuleSoft (qué APIs expone/consume)

## Cross-Dependencies conocidas
- `mulesoft` — enruta instrucciones al FX Engine
- `treasury` — consume posiciones del FX Engine
- `swift` — conectividad para FX cross-border
- `golden-record-target` — KYC contraparte (TO-BE)

*v1.0 · 2026-09-22 · Scaffold*
