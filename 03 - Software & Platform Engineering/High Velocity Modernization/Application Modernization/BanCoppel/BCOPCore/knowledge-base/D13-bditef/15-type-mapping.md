# D13 · Transferencias Electrónicas de Fondos (TEF) — Mapeo de Tipos de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 4 — Design
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — DBA IBM Informix (tipos nativos y comportamiento del motor)
- Data Architect (mapeo a PostgreSQL / Aurora)
- QA Lead (pruebas de equivalencia de tipos)

---

## Descripción

Mapeo de tipos de datos de IBM Informix IDS 14.10 a PostgreSQL (Amazon Aurora). Se identifican los riesgos de equivalencia para cada tipo y las acciones necesarias antes de la migración.

---

## Mapeo de tipos estándar

| Tipo Informix | Tipo PostgreSQL | Compatibilidad | Riesgo | Acción requerida |
|---------------|----------------|---------------|--------|-----------------|
| `char(n)` | `char(n)` o `varchar(n)` | PARCIAL | MEDIO | Informix rellena con espacios a la derecha (`CHAR`); PostgreSQL también con `char(n)` pero comparaciones difieren. Usar `varchar(n)` y aplicar `TRIM()` en la migración y en las consultas del target. |
| `varchar(n)` | `varchar(n)` | ALTA | BAJO | Equivalente directo. |
| `integer` | `integer` | ALTA | BAJO | Equivalente directo. |
| `smallint` | `smallint` | ALTA | BAJO | Equivalente directo. |
| `bigint` | `bigint` | ALTA | BAJO | Equivalente directo. |
| `decimal(p,s)` | `numeric(p,s)` | ALTA | MEDIO | La función `trunc()` de Informix trunca hacia cero; PostgreSQL `trunc()` también. Verificar en casos de decimales negativos. |
| `money` | `numeric(16,2)` | PARCIAL | **ALTO** | Ver sección detallada abajo. |
| `date` | `date` | ALTA | MEDIO | Formato de entrada Informix: `%m/%d/%Y` (americano). Insertar siempre con cast explícito en PostgreSQL. |
| `datetime year to second` | `timestamp` | ALTA | BAJO | Equivalente directo. Verificar timezone (Informix es sin timezone por defecto). |
| `datetime year to fraction` | `timestamp(3)` | ALTA | BAJO | Precisión de milisegundos. |
| `serial` | `serial` o `BIGINT GENERATED ALWAYS AS IDENTITY` | ALTA | BAJO | Equivalente. Preferir `BIGINT GENERATED ALWAYS AS IDENTITY` en PostgreSQL moderno. |
| `text` | `text` | ALTA | BAJO | Equivalente directo. |
| `byte` | `bytea` | MEDIA | MEDIO | Representación binaria diferente. Requiere conversión en la capa de migración. |

---

## `money` de Informix — análisis detallado (riesgo ALTO)

El tipo `money` de Informix tiene comportamiento específico que difiere de `numeric(16,2)` en PostgreSQL:

| Característica | Informix `money` | PostgreSQL `numeric(16,2)` |
|---------------|-----------------|--------------------------|
| Precisión por defecto | 2 decimales | 2 decimales (si se define así) |
| Truncamiento vs. redondeo | Reglas de truncamiento específicas del locale | Redondeo HALF UP por defecto |
| Símbolos de moneda | Puede incluir `$` en algunas configuraciones de locale | No incluye símbolo |
| Operaciones aritméticas | Usa reglas de precisión de Informix (FLOAT interno) | Aritmética exacta en `numeric` |
| Comparación con NULL | Comportamiento estándar ANSI | Comportamiento estándar ANSI |

**Impacto en `cargo_cta`:** Las 8 fórmulas financieras (BR-D13-025 a BR-D13-034) usan `money` con `trunc(...,2)`. En el target se debe usar `numeric(16,2)` con `TRUNC(value, 2)` explícito en cada operación — nunca depender del redondeo por defecto de PostgreSQL.

**Prueba obligatoria:** Golden master test TC-D13-EQ-001 a TC-D13-EQ-005 con valores de producción conocidos antes del cutover.

---

## Conversión de fechas — patrón `to_date(v_fechai,"%m/%d/%Y")`

Los SPs del dominio reciben fechas como `char(10)` con formato americano y las convierten con:

```sql
-- Informix
LET v_fecha = to_date(v_fechai, "%m/%d/%Y");
```

En PostgreSQL el equivalente es:

```sql
-- PostgreSQL
v_fecha := TO_DATE(v_fechai, 'MM/DD/YYYY');
```

**Impacto en el API target:** El endpoint REST de `TransferenciasService` debe aceptar fechas en formato ISO 8601 (`YYYY-MM-DD`) y convertir internamente. No debe exponer el formato americano al exterior.

---

## Campos `char(5)` de código de retorno

El patrón `RETURNING char(5), ...` (código de retorno) debe transformarse en el target como:

| Patrón Informix | Patrón PostgreSQL | Patrón target (Java) |
|----------------|-----------------|---------------------|
| `RETURNING char(5), char(35)` (codret, msg) | `OUT p_codret varchar(5), OUT p_msg varchar(35)` | `ResponseEntity<TransferResponse>` con `code` y `message` |

---

## Tipos específicos del dominio TEF

| Campo | Tipo Informix | Tipo PostgreSQL | Observación |
|-------|-------------|----------------|-------------|
| `pempresa` | `char(3)` | `varchar(3)` | Siempre 3 caracteres — puede ser `char(3)` |
| `pcuenta` | `char(20)` | `varchar(20)` | Número de cuenta — revisar padding ceros |
| `pimporte` | `decimal(16,2)` | `numeric(16,2)` | Importe de transferencia |
| `pmoneda` | `char(2)` | `varchar(2)` | Código de moneda |
| `pusuario` | `char(8)` | `varchar(8)` | ID de usuario operador |
| `vfolio` | `char(16)` | `varchar(36)` | En target cambia a UUID — ver RSK-D13-005 |
| `vmotdevol` | `char(2)` | `varchar(2)` | Código CECOBAN de devolución |
| `vstatchq` | `char(1)` | `char(1)` | Estado de cheque — valores fijos `"N"`, `"M"` |
| `viva` | `decimal` | `numeric(5,4)` | Tasa de IVA — ej. 0.16 para 16% |
| `vsdodisp` | `money` | `numeric(16,2)` | Saldo disponible — crítico |
| `vimportecom` | `decimal(16,2)` | `numeric(16,2)` | Importe de comisión |
| `viva_cob` | `money` | `numeric(16,2)` | IVA cobrado — `trunc` obligatorio |

---

## Checklist de verificación pre-migración de tipos

- [ ] Confirmar comportamiento de `trunc()` para valores negativos en Informix vs. PostgreSQL con el DBA.
- [ ] Probar inserción de `money` Informix → `numeric(16,2)` PostgreSQL con datos reales de `cargo_cta`.
- [ ] Confirmar que el locale del servidor Informix no afecta el símbolo de moneda en el tipo `money`.
- [ ] Validar comparaciones de `char(n)` con espacios trailing en consultas migradas.
- [ ] Confirmar el timezone del servidor Informix (relevante para `datetime` y operaciones de cámara CECOBAN).

---
*Generado por análisis de tipos en sp-specs-bditef.md + referencia IBM Informix IDS 14.10 vs. PostgreSQL 15*
