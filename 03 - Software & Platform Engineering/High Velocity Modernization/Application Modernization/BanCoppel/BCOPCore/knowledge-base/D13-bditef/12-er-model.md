# D13 · Transferencias Electrónicas de Fondos (TEF) — Modelo ER

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — DBA IBM Informix (esquema físico y restricciones)
- Data Architect (modelo lógico target)

> El modelo ER presentado es **inferido** del análisis estático de accesos a tablas en los SPs. Las columnas exactas, tipos de datos precisos y claves foráneas requieren validación contra el DDL de producción (`[DATO-REQUERIDO]`).
---

## Descripción

Modelo entidad-relación inferido del dominio `bditef`. El modelo se construyó a partir de las tablas accedidas en el análisis de los 139 SPs y de las columnas observadas como parámetros y variables en el código.

---

## Entidades principales (tablas propias de `bditef`)

### `tef_operaciones` — Maestro de operaciones TEF

```
tef_operaciones
├── folio              char(16)      PK — identificador único de operación
├── empresa            char(3)       FK → cce_param.empresa
├── cuenta_origen      char(20)      FK → bdicheq:sc_maechq.numcuenta
├── banco_destino      char(3)       — clave banco CECOBAN
├── cuenta_destino     char(20)      — cuenta beneficiaria
├── importe            decimal(16,2) — monto de la transferencia
├── moneda             char(2)       — MN u otro código
├── usuario            char(8)       — operador que registró
├── fecha_operacion    date          — fecha del cargo/abono
├── hora_operacion     [DATO-REQUERIDO]
├── estado             char(2)       — estado de la operación en CECOBAN
├── motivo_devolucion  char(2)       — código CECOBAN de devolución (si aplica)
└── [DATO-REQUERIDO]  columnas adicionales
```

### `tef_bitacora` — Auditoría de operaciones

```
tef_bitacora
├── id_bitacora        serial        PK — auto-incremental
├── folio              char(16)      FK → tef_operaciones.folio
├── fecha_log          datetime      — timestamp del evento
├── tipo_evento        char(2)       — tipo de registro de auditoría
├── usuario            char(8)       — usuario que generó el evento
├── descripcion        char(100)     [DATO-REQUERIDO]
└── [DATO-REQUERIDO]  columnas adicionales
```

### `tef_archivos` — Control de archivos de cámara

```
tef_archivos
├── id_archivo         serial        PK
├── nombre_archivo     char(30)      — convención de nombre CECOBAN
├── tipo_archivo       char(2)       — formato (10/60/61/62/63)
├── fecha_archivo      date          — fecha del ciclo de cámara
├── estado             char(1)       — procesado/pendiente/error
├── empresa            char(3)       FK → cce_param.empresa
└── [DATO-REQUERIDO]  columnas adicionales
```

### `tef_detalle` — Detalle de registros por archivo

```
tef_detalle
├── id_detalle         serial        PK
├── id_archivo         integer       FK → tef_archivos.id_archivo
├── folio              char(16)      FK → tef_operaciones.folio
├── secuencia          integer       — número de registro en el archivo
├── importe            decimal(16,2)
└── [DATO-REQUERIDO]  columnas adicionales
```

### `cce_param` — Parámetros de configuración CCE/TEF

```
cce_param
├── empresa            char(3)       PK — código de empresa
├── hora_corte         char(5)       — hora límite de operaciones TEF
├── dias_proceso       char(5)       [DATO-REQUERIDO]
└── [DATO-REQUERIDO]  columnas de configuración
```

### `cce_cheques_dev` — Cheques devueltos en cámara

```
cce_cheques_dev
├── empresa            char(3)       PK parte
├── fecha_devo         date          PK parte — fecha de devolución
├── cuenta             char(20)      — cuenta del cheque devuelto
├── numcheque          char(7)       — número de cheque
├── importe            decimal(16,2)
├── motivo_dev         char(2)       — código CECOBAN
├── folio              char(16)      FK → tef_operaciones.folio
└── [DATO-REQUERIDO]  columnas adicionales
```

### `cce_usuarios_aut` — Usuarios autorizados para operaciones CCE

```
cce_usuarios_aut
├── empresa            char(3)       PK parte
├── usuario            char(8)       PK parte
├── nivel_autorizacion char(2)       — nivel de autorización
├── activo             char(1)       — estado del usuario
└── [DATO-REQUERIDO]  columnas adicionales
```

---

## Relaciones inferidas

```
cce_param ─────────────────────── 1:N ──── tef_operaciones
tef_operaciones ─────────────── 1:N ──── tef_bitacora
tef_operaciones ─────────────── 1:N ──── tef_detalle
tef_archivos ────────────────── 1:N ──── tef_detalle
tef_operaciones ─────────────── 0:1 ──── cce_cheques_dev
cce_param ─────────────────────── 1:N ──── cce_cheques_dev

[Cross-DB - a resolver en target con API]
tef_operaciones.cuenta_origen ── M:1 ──── bdicheq:sc_maechq.numcuenta
tef_operaciones.banco_destino ── M:1 ──── [catálogo bancos CECOBAN]
```

---

## Modelo lógico target (PostgreSQL / Aurora)

El modelo Informix debe transformarse al target respetando:

1. Los tipos `char(n)` con trailing spaces → `varchar(n)` con `TRIM()` en migración.
2. El tipo `money` de Informix → `numeric(16,2)` en PostgreSQL.
3. Las fechas con formato `%m/%d/%Y` → tipo `DATE` nativo con conversión en la capa de ingesta.
4. Los seriales Informix → `BIGSERIAL` o `GENERATED ALWAYS AS IDENTITY` en PostgreSQL.
5. Las claves foráneas cross-DB → foreign keys en el nuevo schema unificado o referencias lógicas si los dominios siguen separados.

---

## `[DATO-REQUERIDO]`

- DDL completo del esquema `bditef` para completar este modelo.
- Nombres exactos de columnas en `tef_operaciones`, `tef_bitacora`, `tef_archivos`, `tef_detalle`.
- Restricciones CHECK, DEFAULT y UNIQUE definidas en el DDL.
- Índices existentes en tablas transaccionales (impacto en performance del target).
- Confirmar si `tef_operaciones` tiene particionamiento por fecha en producción.

---
*Generado por inferencia de parámetros y tablas accedidas en sp-specs-bditef.md — modelo PRELIMINAR*
