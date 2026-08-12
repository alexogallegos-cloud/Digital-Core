# D16 · Intercard (Tarjetas) — Journey Map

> **Componente:** BCOPCore · SPE-AM-001
> **Base de datos:** `intercard`
> **Última actualización:** 2026-08-03

---

## BP-D16-01 · Cancelación de tarjeta

**Entry point:** `sp_cancelacion_tarjeta` · fan_in=28 · LOC=57 · caller cross-domain: `bdicred:reversion` (D03)

```
[D03 bdicred: reversion (reversa de crédito)]
    │
    ▼  CALL intercard:sp_cancelacion_tarjeta
[sp_cancelacion_tarjeta]
    │
    └── UPDATE tabla intercard (status → CANCELADA)
```

**Nota:** fan_in=28 sugiere que también es invocado directamente por la capa de aplicación (OFI_WEB, canal ICCAT) sin registrar en sp_calls. La reversión de crédito cancela la tarjeta asociada como parte del proceso de devolución. `[SME-PENDING]` confirmación de todos los callers.

---

## BP-D16-02 · Activación de tarjeta ICCAT

**Entry point:** `sp_activatarjeta_iccat` · fan_in=0 · fan_out=3 · LOC=941

```
[Canal ICCAT / BPI (atención en sucursal)]
    │
    ▼
[sp_activatarjeta_iccat]
    ├── valida datos de cliente y tarjeta
    ├── actualiza status tarjeta → ACTIVA
    ├── registra en bitácora ICCAT
    └── notifica canal BPI
```

**ICCAT:** canal interno de atención al cliente en sucursal BPI (Bancoppel Point of Interaction). `[SME-PENDING]` especificación del protocolo ICCAT/BPI.

---

## BP-D16-03 · Consulta de tarjetas débito/crédito ICCAT

**Entry point:** `sp_consultartarjetas_debcred_can_iccat` · fan_in=2 · fan_out=1 · LOC=1,226 · rules=1

```
[Canal ICCAT]
    │
    ▼
[sp_consultartarjetas_debcred_can_iccat]
    ├── SELECT tarjetas activas del cliente (débito + crédito)
    ├── filtra por canal (ICCAT)
    └── retorna catálogo de tarjetas con status y límites
```

---

## BP-D16-04 · Desbloqueo de tarjeta bloqueada por impago

**Entry point:** `sp_limpiatarjeta_bloqueada_iccat` · fan_in=0 · fan_out=3 · LOC=898

```
[Canal ICCAT / proceso de cobranza]
    │
    ▼
[sp_limpiatarjeta_bloqueada_iccat]
    ├── verifica n_impagos_consec ≤ umbral permitido
    ├── valida acuerdo de pago o saldo regularizado
    ├── UPDATE status tarjeta → ACTIVA (limpia bloqueo)
    └── notifica canal ICCAT
```

**Riesgo regulatorio:** CNBV exige bitácora de bloqueo/desbloqueo de tarjetas con evidencia de impago. `[SME-PENDING]` validación de campos requeridos en auditoría CNBV.

---

## BP-D16-05 · Enrolamiento batch de clientes

**Entry point:** `sp_carga_ctes_enrola` · fan_in=0 · fan_out=3 · LOC=1,778 · rules=16

```
[Scheduler AIX (nocturno)]
    │
    ▼
[sp_carga_ctes_enrola]
    ├── lee archivo/tabla de clientes a enrolar
    ├── valida datos de cliente (16 reglas)
    ├── INSERT/UPDATE en catálogo intercard
    ├── asigna tarjeta(s) al cliente
    └── genera bitácora de carga
```

**Patrón:** batch nocturno de alta complejidad (1,778 LOC). Las 16 reglas incluyen validaciones de elegibilidad de producto, límites de crédito inicial y captura de datos PII. `[SME-PENDING]` horario exacto y tolerancia a fallas parciales.

---

## BP-D16-06 · Contacto por vencimiento — crédito

**Entry point:** `sp_contacto_vencimiento_credito` · fan_in=0 · fan_out=2 · LOC=1,011 · rules=49

```
[Scheduler AIX (diario / periódico)]
    │
    ▼
[sp_contacto_vencimiento_credito]
    ├── SELECT cuentas con fecha_vencimiento = hoy + N días
    ├── aplica 49 reglas de elegibilidad de contacto
    │   (canal preferido, límite de intentos, horario permitido)
    ├── CALL sp de notificación (SMS / email / push)
    └── UPDATE contacto_flag, next_contact_date
```

**Criticidad:** 49 reglas — el SP más rico en lógica de D16. Define qué clientes reciben recordatorio preventivo antes del vencimiento. Regulatorio: CONDUSEF prohíbe contacto fuera de horario y limita frecuencia. `[SME-PENDING]` mapeo regla por regla con restricciones CONDUSEF/CNBV.

---

## BP-D16-07 · Contacto por vencimiento — débito

**Entry point:** `sp_contacto_vencimiento_debito` · fan_in=0 · fan_out=2 · LOC=998 · rules=46

Estructura idéntica a BP-D16-06 pero sobre la cartera de débito. 46 reglas. `[SME-PENDING]` diferencias funcionales documentadas respecto a crédito.

---

## BP-D16-08 · Obtención de TDC para Horas Azules

**Entry point:** `sp_horasazules_obtener_tdc_clientes` · fan_in=0 · fan_out=2 · LOC=1,333 · rules=6

```
[Programa Horas Azules (loyalty engine)]
    │
    ▼
[sp_horasazules_obtener_tdc_clientes]
    ├── SELECT TDC activas en horario "Horas Azules"
    ├── aplica 6 reglas de elegibilidad (tipo de tarjeta, status, límite)
    └── retorna lista de clientes elegibles para beneficio
```

**Contexto:** "Horas Azules" es el programa de puntos/descuentos de Coppel. Este SP alimenta el motor de lealtad con el inventario de TDC activas elegibles. `[SME-PENDING]` frecuencia de invocación y sistema destino.

---
*Generado: 2026-08-03 · fuente: brain.db + análisis estático · `[SME-PENDING]` = validación pendiente*
