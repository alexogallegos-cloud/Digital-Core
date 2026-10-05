# Digital Twin — eCommerce Transición (ATG+Endeca → commercetools)
> `liverpool-brain/dt/dt-ecommerce-transicion/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-02
> Señal estratégica: Liverpool seleccionó commercetools el **5 de noviembre de 2025**

## Propósito

Gemelo digital de la transición del canal eCommerce de Liverpool: desde el AS-IS (Oracle ATG + Endeca) hacia el TO-BE (commercetools — plataforma composable MACH). Este DT mapea qué capabilities existen hoy en ATG, cuáles sobreviven al reemplazo, cuáles se redesignan, y qué necesita Digital-Platform GCP para alojar la nueva plataforma.

Con menos de un año desde el anuncio (nov 2025), la migración está en etapas iniciales — este DT es urgente para diseñar correctamente la estrategia de transición.

## Dominio Principal
R05 — Canales Digitales

## Sistemas Involucrados

### AS-IS (estado actual)
| Sistema | togaf_type | Rol actual |
|---------|-----------|-----------|
| ATG-Endeca (Oracle Commerce) | channels (baseline) | Motor eCommerce liverpool.com.mx + suburbia.com — carrito, checkout, promociones |
| Endeca (Oracle) | channels (baseline) | Motor de búsqueda y navegación — facetado, relevancia, merchandising visual |
| Sterling OMS | channels (baseline) | Backend de pedidos del canal digital — orquestación omnicanal |
| IBM IIB | integration | Bus ATG ↔ SAP, ATG ↔ OMS, ATG ↔ Siebel |

### TO-BE (plataforma destino)
| Sistema | togaf_type | Rol futuro |
|---------|-----------|-----------|
| commercetools | channels (target) | Plataforma MACH composable — cart, catalog, order, pricing APIs |
| Digital-Platform (GCP) | channels (transitional→target) | Landing zone para commercetools + servicios GCP complementarios |
| Apigee | integration (target) | API Gateway para exponer las APIs de commercetools |
| CDP-GCP | data (target) | Customer 360 que alimenta personalización en commercetools |

## Capabilities ATG a Mapear (AS-IS → TO-BE)

| Capability | Sistema AS-IS | Sistema TO-BE | Decisión hipótesis |
|-----------|--------------|--------------|-------------------|
| Catálogo de producto | ATG + Endeca | commercetools Product | Repurchase |
| Carrito de compras | ATG | commercetools Cart | Repurchase |
| Checkout + pagos | ATG | commercetools + PSP | Repurchase |
| Búsqueda y navegación | Endeca | commercetools Search / Algolia | Repurchase |
| Promociones y descuentos | ATG | commercetools Discounts | Repurchase |
| Gestión de pedidos (OMS) | Sterling OMS | Sterling OMS o nuevo OMS | Refactor / Repurchase |
| Personalización | ATG Rules | CDP-GCP + commercetools AI Hub | Evolve |
| Integración ERP | ATG → IIB → SAP | commercetools → Apigee → SAP | Replatform |
| Cuentas de cliente | ATG | commercetools Customer + CDP | Refactor |

## Señales Activas

- Anuncio público **5-nov-2025**: *"commercetools Selected by Liverpool to Unlock Agentic Commerce Experiences"*
- Liverpool usará **AI Hub + Agent Gateway** de commercetools para habilitar agentic commerce
- ATG+Endeca: 7R = **Repurchase** — confirmar AS-IS antes de diseñar TO-BE
- **6 servicios** con `p:"eCommerce"` en el inventario AS-IS
- **Digital-Platform GCP**: ya contiene apps cloud-native (Gestor4PL, XD/App Surtido) — será la LZ de commercetools
- Sterling OMS: **96.69% órdenes pendientes** — riesgo que la migración eCommerce hereda si OMS no se atiende en paralelo

## Preguntas Estratégicas que Responde

1. ¿Qué capabilities de ATG+Endeca deben replicarse en commercetools vs cuáles pueden descartarse?
2. ¿Cuál es la estrategia de transición (Strangler-Fig capability por capability vs cutover)?
3. ¿Qué hace falta en Digital-Platform GCP para ser la landing zone de commercetools?
4. ¿Cómo se conecta commercetools con SAP ECC/S4, Sterling OMS y CDP-GCP?
5. ¿Qué impacto tiene la deuda de Sterling OMS en el timeline de la migración eCommerce?
6. ¿Cuál es el modelo de datos de cliente que commercetools debe absorber desde ATG?

## Estado

`[STATE: SCAFFOLD]` — estructura creada 2026-09-02.
Urgente: el anuncio es de nov 2025 — la migración está en curso sin AS-IS documentado.
Primera acción: mapear capabilities ATG con el equipo de arquitectura de Liverpool.

## Fuentes de Datos Necesarias para Activar

- [ ] Arquitectura técnica de ATG-Endeca (versión, módulos, customizaciones Java)
- [ ] Catálogo de APIs/servicios que ATG expone hacia canales (app móvil, etc.)
- [ ] Configuración Endeca: reglas de búsqueda, clasificaciones, merchandising
- [ ] Volumetría ATG: requests/día, SKUs indexados, sesiones concurrentes
- [ ] Roadmap commercetools de Liverpool (si existe — puede estar en Digital-Platform)
- [ ] Contratos de integración ATG ↔ IIB ↔ SAP (qué datos fluyen y con qué frecuencia)

## Dependencias Cross-DT

- `dt-catalogo-producto` → el modelo de catálogo PIM-STEP define lo que commercetools debe absorber — prerequisito
- `dt-pedido-omnicanal` → Sterling OMS es el backend de pedidos del canal digital; la deuda OMS bloquea o complica la migración
- `dt-bus-integracion` → la migración ATG→commercetools requiere reimaginar los flows IIB que hoy alimentan ATG
- `dt-inteligencia-cliente` → la estrategia "agentic commerce" de commercetools requiere Customer 360 de CDP-GCP