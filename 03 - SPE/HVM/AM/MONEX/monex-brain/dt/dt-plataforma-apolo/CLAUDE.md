# DT Plataforma Apolo — Digital Twin
> Iniciativa Apolo 4 · Plataforma destino + Decommissioning legacy

## Pregunta Central
¿Cuál es el path de decommission del legado capability por capability?

## Riesgo #1 Declarado por MONEX
La capacidad de **ejecución organizacional** — no la tecnología — es el riesgo crítico.

## Estrategia: Strangler-Fig por Capability
- Nunca big-bang cutover
- Cada capability del legado se reemplaza incrementalmente
- Parallel-run obligatorio mínimo por capability
- Feature flag por flujo de negocio
- Rollback al legacy probado y firmado

## Mapa de Capabilities → Decommission Order

| Capability | Sistema actual | Iniciativa Apolo | Prioridad |
|------------|---------------|-----------------|----------|
| Pagos SPEI | payments-legacy | Motor de Pagos | Alta |
| Pagos SWIFT | payments-legacy | Motor de Pagos | Alta |
| FX Spot | fx-engine | FX Next | Media |
| FX Forward/NDF | fx-engine | FX Next | Media |
| Datos maestros cliente | portal-clientes, payments-legacy | Golden Record | Alta |
| Reporting DIOR | payments-legacy | Motor de Pagos | Alta |

## Criterios de Decommission por Capability

- [ ] Equivalencia funcional >= 99.99% verificada en parallel-run
- [ ] Parallel-run >= 3 meses sin divergencia bloqueante
- [ ] Rollback al legacy probado en STG
- [ ] Reguladores notificados si aplica (CNBV/Banxico/FCA)
- [ ] On-call doble durante ventana de coexistencia

## Pendientes (DATO-REQUERIDO)
- [ ] Inventario completo de capabilities del payments-legacy
- [ ] Inventario completo de capabilities del fx-engine
- [ ] Dependencias cross-sistema del legado
- [ ] SLAs actuales que el target debe igualar o superar

---
*v1.0 · 2026-09-22 · Scaffold*
