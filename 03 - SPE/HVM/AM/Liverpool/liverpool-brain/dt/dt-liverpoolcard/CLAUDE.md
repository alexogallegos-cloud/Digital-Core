# Digital Twin — LiverpoolCard Ciclo Completo
> `liverpool-brain/dt/dt-liverpoolcard/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-02

## Propósito

Gemelo digital del ciclo de vida completo de la tarjeta LiverpoolCard: originación de crédito → autorización de compras → emisión de plásticos → estados de cuenta → cobranza → disputas y aclaraciones.

Es el dominio más regulado del programa (Banxico + CONDUSEF) y el de mayor complejidad técnica: 5 sistemas especializados en cadena sobre un host z/OS. Con una migración ya en curso (Cyberfinancial v8.4→v9C), cualquier decisión 7R sin este DT es ciega.

## Dominio Principal
R03 — Servicios Financieros

## Sistemas Involucrados

| Sistema | togaf_type | Rol en el ciclo |
|---------|-----------|-----------------|
| VPL Vision Plus (FIS Global) | processors | Core autorizaciones 24×7 — motor central LiverpoolCard en z/OS |
| FICO TRIAD (FICO) | processors | Originación crédito APM+OM + scoring + Buró de Crédito |
| Base24 (ACI Worldwide) | processors | Switch transaccional — POS / ATG / ATM |
| Card Wizard | processors | Emisión de plásticos + personalización + activación |
| Cyberfinancial (EQUIFAX/Harman Navigator) | processors | Cobranza SaaS — migración v8.4→v9C en curso |
| Mainframe (IBM z/OS) | core | Host de VPL Vision Plus + SOMS + contabilidad clientes + MARC 90 |

## Flujos Clave a Modelar

1. **Originación**: Solicitud → FICO TRIAD (scoring) → Buró de Crédito → aprobación → Card Wizard (emisión) → activación VPL
2. **Autorización**: Compra POS/ATG → Base24 (switch) → VPL Vision Plus (autorización) → respuesta en <3 seg
3. **Ciclo facturación**: Corte mensual → VPL (cálculo saldo/intereses) → Mainframe Clientes (estado de cuenta) → canal (digital/papel)
4. **Cobranza**: Deuda vencida → Cyberfinancial (gestión cobranza, SaaS AWS) → alertas → acuerdos de pago
5. **Disputas**: Reclamación → Gestor de Aclaraciones (Mainframe/Fraude) → Key Monitor → resolución

## Señales Activas (del Dashboard AS-IS)

- **Cyberfinancial**: migración v8.4→v9C **ya en proceso** (EQUIFAX cloud) — riesgo de continuidad del flujo de cobranza
- **VPL Vision Plus**: corre en z/OS — cualquier modernización requiere encapsulación API previa (7R = Encapsulate)
- **Preautorizador + Key Monitor**: detección de fraude corre en Mainframe, integrado con VPL
- **19 servicios** con `d:"SF"` en el inventario de 117

## Regulación Aplicable

| Norma | Alcance |
|-------|---------|
| Banxico — Circular 14/2017 (SPEI) | Liquidación de pagos con tarjeta |
| CONDUSEF — Ley para la Transparencia | Contratos de crédito + CETES de referencia |
| Buró de Crédito | Consulta y reporte en originación |
| PCI-DSS | Transmisión de datos de tarjeta en Base24 |

## Preguntas Estratégicas que Responde

1. ¿Cuál es el path de modernización del stack LiverpoolCard sin interrumpir autorización 24×7?
2. ¿Qué impacto tiene la migración Cyberfinancial v8.4→v9C en el resto del ciclo?
3. ¿Cuál es el blast radius de encapsular VPL Vision Plus vía API?
4. ¿Qué capability de FICO TRIAD puede moverse a cloud sin romper el scoring regulatorio?

## Estado

`[STATE: SCAFFOLD]` — estructura creada 2026-09-02.
Pendiente: poblar flujos detallados con reglas de negocio reales (requiere acceso a código VPL + configuración FICO TRIAD).

## Fuentes de Datos Necesarias para Activar

- [ ] Código / interfaces VPL Vision Plus (FIS Global — bajo NDA)
- [ ] Configuración FICO TRIAD (modelos de scoring, flujo APM/OM)
- [ ] Interfaces Cyberfinancial v8.4 actuales vs v9C target
- [ ] Logs volumetría Base24 (TPS autorizaciones)
- [ ] Scripts JCL + Control-D para cortes y cierres mensuales

## Dependencias Cross-DT

- `dt-pedido-omnicanal` → Base24 es shared: autoriza compras tanto LiverpoolCard como otras formas de pago
- `dt-bus-integracion` → IBM IIB conecta Cyberfinancial + FICO TRIAD con el resto del landscape
- `dt-inteligencia-cliente` → el ciclo crediticio alimenta el Customer 360 en CDP-GCP