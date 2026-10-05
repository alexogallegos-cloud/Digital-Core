# Digital Twin — Pedido Omnicanal (Order Journey)
> `liverpool-brain/dt/dt-pedido-omnicanal/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-02

## Propósito

Gemelo digital del ciclo de vida de un pedido desde cualquier canal (tienda, liverpool.com.mx, suburbia.com, app móvil, call center) hasta la entrega al cliente o devolución.

Este DT tiene la señal operativa más crítica del programa: **Sterling OMS con 96.69% de órdenes en estado "pendiente"** — una deuda arquitectónica severa que afecta el NPS y la operación logística en tiempo real.

## Dominios Principales
R04 — Cadena de Suministro y Logística
R05 — Canales Digitales

## Sistemas Involucrados

| Sistema | togaf_type | Rol en el journey |
|---------|-----------|-------------------|
| ATG-Endeca (Oracle Commerce) | channels | Carrito / checkout en liverpool.com.mx y suburbia.com |
| Bridgecore (BridgePOS) | channels | Captura de pedido en POS tienda física |
| Digital-Platform (GCP) | channels | App móvil + nuevas experiencias digitales |
| Sterling OMS (IBM Sterling 10) | channels | Orquestación omnicanal — asignación, splits, fulfillment |
| SAP EWM | core | WMS — inventario en CD, picking, packing |
| TMS / Última milla | integration | Carriers + SCOL (tracking last mile) |
| IBM IIB | integration | Bus de integración entre OMS ↔ EWM ↔ canales |
| Tumbleweed (MFT) | integration | Intercambio archivos con carriers y proveedores logísticos |

## Flujos Clave a Modelar

1. **Click & Deliver** (eCommerce): ATG-Endeca checkout → Sterling OMS (orquestación) → SAP EWM (CD picking) → carrier (última milla)
2. **Click & Collect** (BOPIS): ATG-Endeca → Sterling OMS → SAP EWM (tienda) → notificación cliente → recogida
3. **Compra en tienda**: Bridgecore POS → Sterling OMS → SAP EWM (reserva/despacho)
4. **Ship from Store**: Sterling OMS (asignar tienda como origen) → Bridgecore (confirmar) → carrier
5. **Devolución**: Canal (cualquiera) → Sterling OMS (reverse logistics) → SAP EWM (recepción)

## Señales Activas — ALERTA

- **Sterling OMS 96.69% órdenes pendientes**: señal de cuello de botella severo — posiblemente backlog acumulado, lógica de asignación no optimizada, o cuellos de integración con EWM/carriers
- **5 servicios** con `p:"OMS"` en inventario
- **26 servicios** en R04 (el dominio con más servicios en el brain)

## Preguntas Estratégicas que Responde

1. ¿Dónde exactamente se acumula el 96.69% de órdenes pendientes en Sterling OMS?
2. ¿Qué lógica de orquestación tiene OMS que no puede resolverse sin refactor mayor?
3. ¿Cuál es el blast radius de migrar Sterling OMS (7R = Refactor o Repurchase)?
4. ¿Qué parte del flujo de pedido está en riesgo cuando se reemplace ATG-Endeca por commercetools?
5. ¿Cómo afecta la deuda de OMS a la experiencia de Canal Digital (R05)?

## Estado

`[STATE: SCAFFOLD]` — estructura creada 2026-09-02.
Pendiente: mapear lógica interna de Sterling OMS + interfaces con SAP EWM y carriers.

## Fuentes de Datos Necesarias para Activar

- [ ] Configuración Sterling OMS 10 — reglas de orquestación, splits, assignment rules
- [ ] Interfaces IBM IIB relacionadas con OMS (flows OMS↔EWM, OMS↔canales)
- [ ] Logs de órdenes: distribución de estados, tiempos por etapa
- [ ] Configuración SAP EWM — inbound delivery types, picking strategies
- [ ] Contratos/SLAs con carriers (SCOL, Estafeta, FedEx, etc.)

## Dependencias Cross-DT

- `dt-ecommerce-transicion` → OMS es el backend de pedidos para commercetools; cualquier migración ATG→commercetools hereda esta deuda
- `dt-bus-integracion` → IIB es el bus entre OMS ↔ EWM ↔ canales; blast radius de OMS pasa por IIB
- `dt-sap-doble-landscape` → SAP EWM existe en ambos landscapes (LIV on-prem + SBB Azure); la orquestación de OMS debe distinguirlos