# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Modelo Entidad-Relación

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 2 — Schema Analysis
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Advertencia

Este modelo ER es inferido del análisis estático de los SPs. Los tipos de columna, longitudes, constraints e índices reales solo pueden obtenerse del `syscolumns` del motor Informix. `[DATO-REQUERIDO]` — DBA IBM Informix debe validar y completar este modelo antes de la fase de diseño del schema target.

## Entidades principales identificadas

### `sl_movefec` — Movimientos por Fecha (entidad central PLD)

```
sl_movefec
├── [DATO-REQUERIDO] PK
├── num_cte          — referencia al cliente (probablemente FK a bdinteg.si_cliente)
├── rfc              — RFC del cliente CHAR(13) (evidencia en sp_acumulacionoperaciones)
├── anio_mes         — período de proceso CHAR(6) [AAAAMM]
├── imp_tot_ide      — importe total depósitos en efectivo MONEY
├── monto_recaudar   — monto calculado de recaudación IDE MONEY
├── status           — status del movimiento CHAR(1)
├── tipo_cta         — tipo de cuenta CHAR(1)
├── fecha_insert     — fecha de inserción DATE
└── [DATO-REQUERIDO] campos adicionales
```

### `sl_movefec_his` — Histórico de Movimientos por Fecha

```
sl_movefec_his
├── [DATO-REQUERIDO] estructura similar a sl_movefec
└── Nota: es el archivo histórico; DELETE masivo por período en borramovs_movefechis
```

### `sl_retlide` — Retenciones LIDE

```
sl_retlide
├── [DATO-REQUERIDO] PK
├── num_cte          — referencia al cliente
├── rfc              — RFC del cliente
├── anio_mes         — período CHAR(6)
├── monto_retener    — monto a retener MONEY (resultado de acumulación PLD)
├── fecha_proceso    — fecha del proceso batch
└── [DATO-REQUERIDO] campos adicionales
```

### `sl_detlide` — Detalle LIDE (clientes en lista negra interna)

```
sl_detlide
├── [DATO-REQUERIDO] PK
├── num_cte          — número de cliente en LIDE
├── curp / rfc       — identificadores del cliente
├── motivo           — causal de inclusión en LIDE
├── fecha_inclusion  — fecha en que fue agregado a LIDE
├── fecha_exclusion  — fecha estimada de exclusión (si aplica)
├── status           — activo/inactivo
└── [DATO-REQUERIDO] campos regulatorios adicionales
```

### `sl_exentos` — Clientes Exentos IDE (SAT)

```
sl_exentos
├── rfc              — RFC del cliente CHAR(13) (PK probable)
├── num_cte          — número de cliente CHAR(20)
├── anio             — año de exención CHAR(4)
├── status           — status de la exención CHAR(1)
├── fecha_proceso    — fecha de procesamiento DATE
└── [DATO-REQUERIDO] campos adicionales del resultado SAT
```

### `sl_consat` — Consultas al SAT

```
sl_consat
├── [DATO-REQUERIDO] PK
├── rfc              — RFC consultado CHAR(13)
├── anio_mes         — período de la consulta CHAR(6)
├── resultado        — resultado de la consulta SAT
├── fecha_consulta   — fecha de la consulta DATE
└── [DATO-REQUERIDO] campos adicionales
```

### `sl_procesos` — Control de Procesos Batch

```
sl_procesos
├── [DATO-REQUERIDO] PK
├── proceso          — identificador del proceso CHAR(10)
├── empresa          — código de empresa CHAR(3)
├── fecha_proceso    — fecha de ejecución DATE
├── status           — status de ejecución CHAR(1)
├── usuario          — clave del usuario ejecutor CHAR(8)
├── fecha_inicio     — timestamp de inicio
├── fecha_fin        — timestamp de fin
└── [DATO-REQUERIDO] campos adicionales
```

### `sl_parametros` — Parámetros del Motor PLD

```
sl_parametros
├── [DATO-REQUERIDO] PK
├── nombre_param     — nombre del parámetro (clave)
├── valor            — valor del parámetro (incluye vmMontLimite y viPorcaRecau)
├── descripcion      — descripción del parámetro
├── fecha_vigencia   — fecha desde la que aplica el valor
└── [DATO-REQUERIDO] campos adicionales
```

## Relaciones inferidas

```
bdinteg.si_cliente ──(1:N)── sl_movefec.num_cte
bdinteg.si_cliente ──(1:N)── sl_retlide.num_cte
bdinteg.si_cliente ──(1:N)── sl_detlide.num_cte
sl_movefec ──────────────── sl_movefec_his (archivo — copia histórica)
sl_procesos ────(1:N)────── sl_retlide (un proceso genera N retenciones)
sl_exentos.rfc ──(FK?)───── sl_consat.rfc
```

## Modelo ER simplificado (inferido)

```
[bdinteg.si_cliente]
      │ num_cte
      │
      ├─────────────────────────────────────────┐
      │                                         │
      ▼                                         ▼
[sl_movefec]                              [sl_detlide]
  anio_mes                                 (LIDE list)
  imp_tot_ide
  monto_recaudar
      │
      ├── archiva → [sl_movefec_his]
      │
      ▼
[sl_retlide]
  (retenciones IDE)
      │
      ▼
[sl_procesos] ── controla ──► [sp_acumulacionoperaciones]
      │
[sl_parametros]
  vmMontLimite
  viPorcaRecau
      │
      ▼
[sl_consat] ──► [sl_exentos]
  (intercambio SAT)   (exentos IDE)
```

## `[SME-PENDING]`

- [ ] DBA IBM Informix: ejecutar `DESCRIBE TABLE sl_*` o consultar `syscolumns` para obtener el schema completo.
- [ ] Confirmar las PKs y FKs reales (Informix puede no tener FK constraints definidas explícitamente).
- [ ] Documentar los índices para optimizar las consultas del motor PLD en el target Aurora.
- [ ] Confirmar la relación entre `sl_exentos` y `sl_consat` (¿son 1:1 o 1:N por período?).

---
*Generado: análisis estático bdilide · 2026-08-03*
