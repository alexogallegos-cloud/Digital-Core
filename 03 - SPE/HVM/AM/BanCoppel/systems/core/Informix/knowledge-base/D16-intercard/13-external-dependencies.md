# D16 · Intercard (Tarjetas) — Dependencias Externas

> **Componente:** Informix · SPE-AM-001
> **Base de datos:** `intercard`
> **Última actualización:** 2026-08-03

---

## Dependencias identificadas

### DEP-D16-01 · ICCAT / BPI (canal de atención en sucursal)

| Campo | Valor |
|-------|-------|
| Sistema | ICCAT — canal de atención al cliente en sucursal BPI (BanCoppel Point of Interaction) |
| Integración | SPs con sufijo `_iccat`: `sp_activatarjeta_iccat`, `sp_consultartarjetas_debcred_can_iccat`, `sp_limpiatarjeta_bloqueada_iccat` |
| Patrón | Sincrónico — request/response dentro del SP |
| Criticidad | Alta — 3 de los 8 procesos principales del dominio dependen de ICCAT |
| Estado | `[SME-PENDING]` — protocolo de integración, timeouts y manejo de errores ICCAT no documentados |

**Riesgo de migración:** Si ICCAT/BPI permanece como sistema legacy durante Wave 4, la ACL (Anti-Corruption Layer) debe mantener compatibilidad con el protocolo ICCAT. Requiere coordinación con el equipo de Canales BPI.

---

### DEP-D16-02 · Motor de notificaciones (SMS / email / push)

| Campo | Valor |
|-------|-------|
| Sistema | Canal de notificación de BanCoppel (SMS, email, push app) |
| Integración | `sp_contacto_vencimiento_credito`, `sp_contacto_vencimiento_debito`, `sp_registra_evento`, `sp_rst_notificacion_clientes` |
| Patrón | Invocación desde batch — probablemente via CALL a SP de mensajería en `bdimnsj` (D09) |
| Criticidad | Alta — los batch de contacto por vencimiento (49+46 reglas) dependen de poder enviar notificaciones |
| Estado | Dependencia cross-domain: D16 → D09 (Mensajería) |

---

### DEP-D16-03 · D03 bdicred (Crédito) — caller de sp_cancelacion_tarjeta

| Campo | Valor |
|-------|-------|
| Relación | D03 → D16: `bdicred:reversion` LLAMA `intercard:sp_cancelacion_tarjeta` |
| Patrón | D16 es PROVEEDOR de servicio de cancelación |
| Impacto en Wave 4 | `sp_cancelacion_tarjeta` debe estar disponible en el target antes del cutover de D03 (Wave 1) |
| Estado | Riesgo de dependencia de Wave: si D16 (Wave 4) no está disponible cuando D03 (Wave 1) migra, se necesita ACL sobre el legacy |

---

### DEP-D16-04 · Horas Azules (motor de lealtad Coppel)

| Campo | Valor |
|-------|-------|
| Sistema | Motor de puntos y descuentos Horas Azules de Coppel Retail |
| Integración | `sp_horasazules_obtener_tdc_clientes` — D16 provee lista de TDC elegibles |
| Patrón | D16 como proveedor de datos — el motor de lealtad consulta el catálogo `intercard` |
| Estado | `[SME-PENDING]` — sistema destino de los datos de TDC (¿Coppel Retail tiene API? ¿Lectura directa de BD?) |

---

### DEP-D16-05 · Inventario de plásticos (bóvedas físicas)

| Campo | Valor |
|-------|-------|
| Sistema | Sistema de inventario físico de tarjetas (bóvedas) |
| Integración | `sp_inter_cuadrar_inventario_tarjetas` — reconcilia tarjetas emitidas vs. stock físico |
| Estado | `[SME-PENDING]` — fuente del inventario físico (¿sistema externo? ¿tabla en otra DB?) |

---

## Dependencias cross-domain (D16 como caller)

| SP en D16 | Llama a | Dominio destino |
|-----------|---------|-----------------|
| `sp_activatarjeta_iccat` | `[SME-PENDING]` 3 callees no identificados | Probable: D02 (bdinteg) o D09 (bdimnsj) |
| `sp_limpiatarjeta_bloqueada_iccat` | `[SME-PENDING]` 3 callees | Probable: D11 (bdicobranza) |
| `sp_carga_ctes_enrola` | `[SME-PENDING]` 3 callees | Probable: D03 (bdicred) o D04 (bdicheq) |
| `sp_contacto_vencimiento_credito` | `[SME-PENDING]` 2 callees | Probable: D09 (bdimnsj — mensajería) |
| `sp_contacto_vencimiento_debito` | `[SME-PENDING]` 2 callees | Probable: D09 (bdimnsj — mensajería) |

> Los callees exactos requieren análisis del código fuente (source/informix/intercard_*.sql). Los patrones de nombre sugieren dependencia con D09 Mensajería para las notificaciones.

---
*Generado: 2026-08-03 · fuente: brain.db sp_calls + análisis de patrones de nombres · `[SME-PENDING]` = confirmar con DBA IBM Informix*
