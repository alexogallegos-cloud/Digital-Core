# Banxico SPEI/DiMo — Application Modernization Agent
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: payment-rails-banxico
# bian_domains: ["payment-execution", "interbank-settlement"]
# discovered: 2026-09-17 · fuente: Banxico (regulado — participación obligatoria para IBMs)

> Conectividad regulada con Banxico — SPEI · DiMo · CoDi
> Sistema externo regulado. Santander MX es participante obligatorio.
> Agente especializado del sistema. Para vista federada: `../../santander-brain/CLAUDE.md`

---

## IDENTIDAD DEL SISTEMA

| Campo | Valor |
|-------|-------|
| Nombre real | Banxico SPEI / DiMo / CoDi (sistemas regulados Banxico) |
| Tipo TOGAF | integration — Sistema regulado externo |
| Estado | Baseline (participación obligatoria) |
| Propietario | Banco de México (Banxico) |
| Participación Santander | Obligatoria como IBM (Institución de Banca Múltiple) |
| Regulación | Circular 14/2017 Banxico (SPEI) · Reglas DiMo · Reglas CoDi |

---

## SISTEMAS BANXICO

### SPEI — Sistema de Pagos Electrónicos Interbancarios

| Parámetro | Valor |
|-----------|-------|
| Tipo | Liquidación bruta en tiempo real (RTGS) |
| Horario | Ciclos regulados Banxico (múltiples ventanas) |
| Monto máximo | Sin límite (con autorización) |
| Tiempo de liquidación | < 30 segundos |
| Formato | Propietario Banxico → ISO 20022 (transición) |
| Volumen sistema | ~8.5B transacciones / año (2024) |

### DiMo — Dinero Móvil

| Parámetro | Valor |
|-----------|-------|
| Tipo | Pagos P2P por número de teléfono |
| Horario | 24x7x365 |
| Límite | $8,000 MXN por operación (retail) |
| Tiempo | Tiempo real |

### CoDi — Cobro Digital

| Parámetro | Valor |
|-----------|-------|
| Tipo | Pagos QR en punto de venta / comercio electrónico |
| Horario | 24x7x365 |
| Infraestructura | Sobre rails SPEI |

---

## DEPENDENCIAS DESDE SANTANDER

| Sistema Santander | Tipo de uso | Criticidad |
|-------------------|------------|------------|
| Payments Engine | Envía/recibe mensajes Banxico | CRÍTICA |
| Core Banking | Debit/credit a cuentas por SPEI | CRÍTICA |
| SuperMóvil | UI para iniciar transferencias | ALTA |
| Santander Online | UI para iniciar transferencias | ALTA |

---

## REGULACIÓN Y CUMPLIMIENTO

| Requisito | Marco | Estado |
|-----------|-------|--------|
| Disponibilidad SPEI | Circular Banxico | Por verificar |
| Tiempo de respuesta < 30s | Circular Banxico | Por verificar |
| Reporte de incidentes | Banxico 24h | Por verificar |
| ISO 20022 migración | 2025 deadline global | Por confirmar estado |

---

*Última actualización: 2026-09-17 · v0.1 · Stub inicial — sistema externo regulado, participación confirmada*
