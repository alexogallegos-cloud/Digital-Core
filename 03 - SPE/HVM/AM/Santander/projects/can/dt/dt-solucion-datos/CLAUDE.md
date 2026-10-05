# DT — Solución Datos CAN · Santander México
> **Proyecto:** CAN · Santander México
> **Fase:** DESIGN / BUILD
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Define los cambios en el modelo de datos de Santander requeridos para implementar el
cumplimiento CAN: nuevos campos en sistemas `loans` y `core-banking`, estructura de la
Clave Básica Estandarizada, registro de Cuentas Ordenantes, prelación de cargos, mandatos
y trazabilidad regulatoria.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Core Banking Transformation | Modelo de datos de `loans` y `core-banking` |
| Software Engineering | Diseño de esquema · migration scripts |
| Regulatory/Banxico | Validación de campos requeridos por normativa CAN |
| Framework — Integration Architecture | Modelo compartido entre sistemas (loans ↔ core-banking ↔ payments-engine) |

---

## Entidades del Dominio CAN

### Entidad 1 — CAN (Crédito Asociado a Nómina)

> Extiende la entidad de crédito existente en `loans`.

```sql
-- Campos nuevos en tabla de créditos (hipótesis — confirmar schema real)
ALTER TABLE creditos ADD COLUMN (
  es_can                    BOOLEAN DEFAULT FALSE,
  clave_basica_estandarizada VARCHAR(40),         -- OBL-009: formato per Circular 14/2017
  rol_can                   VARCHAR(20),           -- 'ORIGINADORA' | 'ACREEDORA' | 'ORDENANTE'
  cuenta_ordenante_clabe    CHAR(18),              -- CLABE de la Cuenta Ordenante del acreditado
  institucion_depositaria   VARCHAR(10),           -- Clave Banxico de la institución depositaria
  limite_comite_riesgos_pct DECIMAL(5,2),          -- OBL-002: % máximo de amortizaciones
  mandato_digital_id        VARCHAR(50),           -- Referencia al mandato (OBL-005)
  fecha_designacion_can     TIMESTAMP,             -- Para prelación cronológica (OBL-016)
  es_refinanciamiento       BOOLEAN DEFAULT FALSE, -- OBL-006: liquidó crédito anterior
  clabe_credito_liquidado   VARCHAR(40),           -- Clave Básica del crédito liquidado (OBL-006)
  reportado_buro            BOOLEAN DEFAULT FALSE, -- OBL-008
  notificado_banxico        BOOLEAN DEFAULT FALSE, -- OBL-003
  estado_can                VARCHAR(20)            -- 'ACTIVO' | 'CANCELADO' | 'VENCIDO'
);
```

### Entidad 2 — Cuenta Ordenante

> Extiende la entidad de cuenta en `core-banking`.

```sql
-- Campos nuevos en tabla de cuentas (hipótesis)
ALTER TABLE cuentas ADD COLUMN (
  es_cuenta_ordenante       BOOLEAN DEFAULT FALSE, -- OBL-013
  fecha_identificacion_co   TIMESTAMP,
  fuente_identificacion     VARCHAR(20),           -- 'NOMINA' | 'BASICA_NOMINA' | 'CLIENTE_INDICA'
  mandato_consulta_can_id   VARCHAR(50),           -- Mandato para consultar CANs (OBL-018)
  cans_designados_count     INT DEFAULT 0,         -- Contador de CANs designados
  cans_no_can_previos_monto DECIMAL(15,2)          -- Monto no-CAN previos para prelación (OBL-016)
);
```

### Entidad 3 — Registro de Prelación CAN

> Tabla nueva — no existe en sistemas actuales. Gobierna OBL-016.

```sql
CREATE TABLE can_prelacion (
  id                        BIGINT PRIMARY KEY AUTO_INCREMENT,
  cuenta_clabe              CHAR(18) NOT NULL,     -- Cuenta Ordenante
  clave_basica_estandarizada VARCHAR(40) NOT NULL, -- Identifica el CAN
  institucion_acreedora     VARCHAR(10) NOT NULL,  -- Puede ser Santander u otra IBM
  importe_periodico         DECIMAL(15,2) NOT NULL,
  fecha_hora_designacion    TIMESTAMP NOT NULL,    -- Determina orden prelación (OBL-016)
  dia_cargo                 INT NOT NULL,          -- Día del mes del cargo
  plazo_meses               INT,
  estado                    VARCHAR(20) NOT NULL,  -- 'ACTIVO' | 'CANCELADO' | 'COMPLETADO'
  importe_pendiente         DECIMAL(15,2),         -- Para cargos parciales (OBL-016 excepción)
  created_at                TIMESTAMP DEFAULT NOW(),
  updated_at                TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_prelacion_cuenta ON can_prelacion(cuenta_clabe, estado, fecha_hora_designacion);
```

### Entidad 4 — Mandato Digital CAN

> Tabla nueva — trazabilidad regulatoria obligatoria.

```sql
CREATE TABLE can_mandatos (
  id                    VARCHAR(50) PRIMARY KEY,   -- UUID
  tipo                  VARCHAR(20) NOT NULL,       -- 'ACREDITADO_OBL005' | 'CUENTAHABIENTE_OBL018'
  acreditado_rfc        VARCHAR(13) NOT NULL,
  acreditado_curp       VARCHAR(18) NOT NULL,
  canal                 VARCHAR(20) NOT NULL,       -- 'SUPERMOVIL' | 'SANTANDER_ONLINE' | 'SUCURSAL'
  texto_mandato_version VARCHAR(20) NOT NULL,       -- Versión del texto del mandato aceptado
  fecha_aceptacion      TIMESTAMP NOT NULL,
  ip_cliente            VARCHAR(45),               -- Para mandatos digitales
  pdf_hash              VARCHAR(64),               -- SHA-256 del PDF generado (evidencia Banxico)
  pdf_storage_path      VARCHAR(200),              -- Ruta en Azure Blob Storage
  vigente               BOOLEAN DEFAULT TRUE,
  fecha_revocacion      TIMESTAMP
);
```

### Entidad 5 — Log de Comunicaciones al Hub CAN

> Trazabilidad de todas las interacciones con el Mecanismo Art. 63 Bis 3.

```sql
CREATE TABLE can_hub_log (
  id                    BIGINT PRIMARY KEY AUTO_INCREMENT,
  tipo_mensaje          VARCHAR(50) NOT NULL,       -- 'SOLICITUD_INFO' | 'REGISTRAR_DOMICILIACION' | etc.
  direccion             VARCHAR(10) NOT NULL,       -- 'OUTBOUND' | 'INBOUND'
  institucion_contraparte VARCHAR(10),
  payload_request       TEXT,                       -- JSON del request (para auditoría)
  payload_response      TEXT,                       -- JSON de la respuesta
  http_status           INT,
  sla_requerido_dhb     INT,                        -- DHBs de plazo regulatorio
  fecha_solicitud       TIMESTAMP NOT NULL,
  fecha_respuesta       TIMESTAMP,
  cumple_sla            BOOLEAN,
  error_code            VARCHAR(20),
  error_descripcion     TEXT
);

CREATE INDEX idx_hub_log_fecha ON can_hub_log(fecha_solicitud, tipo_mensaje);
```

---

## Clave Básica Estandarizada — Especificación

> Per Circular 14/2017 Banxico (Reglas SPEI). `[DATO-REQUERIDO]` — confirmar formato exacto en DE CAN v4.2.

| Campo | Descripción | Longitud | Ejemplo |
|-------|-------------|----------|---------|
| Prefijo institución | Clave Banxico de Santander | 4 dígitos | `0014` |
| Tipo de crédito | Código de producto CAN | 2 dígitos | `01` |
| Folio crédito | Número único del crédito en `loans` | `[DATO-REQUERIDO]` | — |
| Dígito verificador | Cálculo per Circular 14/2017 | 1 dígito | — |

**Generación:** Al momento de originar el CAN en `loans`. Inmutable una vez asignada.
**Almacenamiento:** Campo `clave_basica_estandarizada` en tabla de créditos.
**Uso:** OBL-006 (SPEI refinanciamiento), identificación en mensajes al Hub CAN.

---

## Migración de Datos

### Estrategia

| Fase | Acción | Sistema |
|------|--------|---------|
| 1 — Schema migration | ALTER TABLE + CREATE TABLE (sin datos) | `loans` · `core-banking` |
| 2 — Backfill Cuentas Ordenantes | Identificar cuentas que reciben nómina (OBL-013) | `core-banking` |
| 3 — Backfill créditos nómina existentes | Marcar créditos de nómina activos como CAN candidatos | `loans` |
| 4 — Validación regulatoria | Confirmar que cuentas identificadas cumplen criterios Art. 22 Bis | compliance |
| 5 — Go-live | Activar motor de prelación + integración Hub CAN | todos |

> **Riesgo de migración:** créditos de nómina activos que no tienen Clave Básica Estandarizada
> pueden requerir proceso de migración coordinado con Banxico. `[DATO-REQUERIDO]` — confirmar
> tratamiento regulatorio para cartera existente.

---

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Schema migration scripts (SQL) | `knowledge-base/rules/schema-migration-can.sql` |
| Data model diagram (entidades CAN) | `source/docs/arquitectura/data-model-can.md` |
| Especificación Clave Básica Estandarizada | `knowledge-base/rules/spec-clave-basica-estandarizada.md` |
| Plan de migración de datos | `knowledge-base/rules/plan-migracion-can.md` |

## Dependencias

- `[DEPENDS-ON: dt-solucion-arquitectura]` — qué sistemas modificar
- `[DEPENDS-ON: dt-normativa-can]` — campos regulatorios requeridos (OBL-002, OBL-005, OBL-009, OBL-016)
- `[DATO-REQUERIDO]` — Schema real de tablas de créditos en `loans`
- `[DATO-REQUERIDO]` — Schema real de tablas de cuentas en `core-banking`
- `[DATO-REQUERIDO]` — Formato exacto Clave Básica Estandarizada per Circular 14/2017

*v0.1.0 · 2026-09-17 · fase DESIGN*
