# D14 · Banca Electrónica Institucional (BEI) — Diccionario de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 2 — Schema Extraction
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- DBA — IBM Informix IDS (columnas reales desde `syscolumns` — Etapa 2) ← FUENTE DE VERDAD
- Specialist — Informix SPL Analysis (tipos de variables observados en código SPL)
- Industry Banking (semántica de negocio de cada campo)
- Data Architect — target PostgreSQL / Aurora (mapeo de tipos)
- Cybersecurity (identificación de campos PII)

> **ESTADO:** Diccionario parcial. Los campos documentados provienen de variables DEFINE observadas en el código SPL de los SPs del callgraph y de convenciones de nomenclatura del dominio BanCoppel. El diccionario definitivo requiere `syscolumns` real (DBA Etapa 2).
---

## Convenciones de nomenclatura BEI observadas en código

| Prefijo | Significado | Tipo típico |
|---------|------------|------------|
| `c` + nombre | Cadena de caracteres | `CHAR` / `VARCHAR` |
| `i` + nombre | Entero | `INTEGER` / `INT8` |
| `m` + nombre | Monto monetario | `MONEY` / `DECIMAL` |
| `d` + nombre | Fecha | `DATE` / `DATETIME` |
| `v` + nombre | Variable genérica | depende del contexto |
| `p` + nombre | Parámetro de entrada (IN param) | depende |
| `num_` + nombre | Número identificador | `CHAR` / `INTEGER` |
| `cod_` + nombre | Código de estado o resultado | `CHAR(5)` típico |
| `ind_` + nombre | Indicador / flag booleano | `CHAR(1)` / `SMALLINT` |

## Campos clave inferidos de `bei_convenios`

> `[DATO-REQUERIDO]` DBA Informix — validar contra `syscolumns WHERE tabname='bei_convenios'`

| Campo | Tipo Informix (inferido) | Tipo PG target | Nullable | PII | Descripción |
|-------|--------------------------|----------------|----------|:---:|-------------|
| `num_convenio` | `CHAR(10)` | `VARCHAR(10)` | NO | No | Identificador único del convenio empresa |
| `cve_empresa` | `CHAR(12)` | `VARCHAR(12)` | NO | No | Clave interna de la empresa en BanCoppel |
| `rfc_empresa` | `CHAR(13)` | `CHAR(13)` | NO | Sí | RFC de la empresa — dato fiscal |
| `razon_social` | `CHAR(100)` | `VARCHAR(200)` | NO | Sí | Razón social de la empresa |
| `ind_activo` | `CHAR(1)` | `CHAR(1)` | NO | No | S=activo · N=inactivo · B=bloqueado |
| `monto_max_dispersion` | `MONEY(18,2)` | `NUMERIC(18,2)` | NO | No | Límite de dispersión por operación (CNBV) |
| `monto_max_mensual` | `MONEY(18,2)` | `NUMERIC(18,2)` | NO | No | Límite mensual acumulado |
| `cuenta_cargo` | `CHAR(18)` | `VARCHAR(18)` | NO | No | Cuenta origen de las dispersiones |
| `fecha_alta` | `DATE` | `DATE` | NO | No | Fecha de incorporación del convenio |
| `fecha_baja` | `DATE` | `DATE` | YES | No | Fecha de baja del convenio |
| `horario_max_dispersion` | `CHAR(5)` | `TIME` | YES | No | Hora límite para dispersiones (ej. 15:00) |

## Campos clave inferidos de `bei_beneficiarios`

> `[DATO-REQUERIDO]` — Tabla de alta sensibilidad PII. Requiere validación Cybersecurity + DBA.

| Campo | Tipo Informix (inferido) | Tipo PG target | Nullable | PII | Descripción |
|-------|--------------------------|----------------|----------|:---:|-------------|
| `num_convenio` | `CHAR(10)` | `VARCHAR(10)` | NO | No | FK a `bei_convenios` |
| `num_beneficiario` | `INTEGER` | `INTEGER` | NO | No | Número secuencial en la nómina |
| `curp` | `CHAR(18)` | `CHAR(18)` | YES | SÍ — SENSIBLE | CURP del empleado beneficiario |
| `nombre` | `CHAR(60)` | `VARCHAR(120)` | NO | SÍ | Nombre completo del beneficiario |
| `num_cuenta_destino` | `CHAR(18)` | `VARCHAR(18)` | NO | SÍ — FINANCIERO | Cuenta de acreditación (CLABE 18 dígitos) |
| `banco_destino` | `CHAR(3)` | `CHAR(3)` | NO | No | Clave de banco receptor (SPEI) |
| `monto_dispersion` | `MONEY(18,2)` | `NUMERIC(18,2)` | NO | Sí — FINANCIERO | Monto a dispersar por empleado |
| `ind_activo` | `CHAR(1)` | `CHAR(1)` | NO | No | S=activo · N=baja |
| `fecha_alta` | `DATE` | `DATE` | NO | No | Alta en nómina |
| `fecha_baja` | `DATE` | `DATE` | YES | No | Baja de nómina |

## Campos clave inferidos de `bei_dispersiones`

| Campo | Tipo Informix (inferido) | Tipo PG target | Nullable | PII | Descripción |
|-------|--------------------------|----------------|----------|:---:|-------------|
| `num_dispersion` | `SERIAL` | `BIGSERIAL` | NO | No | Folio único de la dispersión |
| `num_convenio` | `CHAR(10)` | `VARCHAR(10)` | NO | No | FK a `bei_convenios` |
| `fecha_dispersion` | `DATE` | `DATE` | NO | No | Fecha del ciclo de nómina |
| `tipo_dispersion` | `CHAR(2)` | `CHAR(2)` | NO | No | NM=nómina · PR=proveedor · SV=servicio |
| `total_registros` | `INTEGER` | `INTEGER` | NO | No | Total de beneficiarios en el lote |
| `total_importe` | `MONEY(18,2)` | `NUMERIC(18,2)` | NO | Sí | Importe total del lote |
| `cod_estatus` | `CHAR(2)` | `CHAR(2)` | NO | No | PE=pendiente · PR=procesando · OK=dispersado · ER=error |
| `cod_error` | `CHAR(5)` | `VARCHAR(10)` | YES | No | Código de error ESB si falló |
| `fecha_procesamiento` | `DATETIME YEAR TO FRACTION` | `TIMESTAMP` | YES | No | Timestamp de procesamiento |
| `num_folio_spei` | `CHAR(22)` | `VARCHAR(22)` | YES | No | Folio SPEI si la liquidación fue interbancaria |

## Tipos Informix de riesgo de equivalencia

| Tipo Informix | Uso en BEI | Riesgo equivalencia | Tipo PostgreSQL recomendado |
|--------------|-----------|--------------------|-----------------------------|
| `MONEY(18,2)` | Todos los campos de monto | CRÍTICO — redondeo bancario | `NUMERIC(18,2)` con escala fija |
| `SERIAL` | Folios de dispersión | ALTO — reseteo en migración | `BIGSERIAL` con seed ajustado |
| `CHAR(18)` | CLABE bancaria | BAJO — longitud fija | `CHAR(18)` |
| `DATETIME YEAR TO FRACTION` | Timestamps de procesamiento | MEDIO — precisión 5 decimales | `TIMESTAMP(5)` |
| `DATE` | Fechas de ciclo de nómina | BAJO | `DATE` |
| `INT8` | Variables internas de cálculo | BAJO | `BIGINT` |

---
*Generado por: Specialist — Informix SPL Analysis + Data Architect · 2026-08-03 · Fuente: variables DEFINE observadas en sp-specs-bdibei.md + convenciones dominio BanCoppel. PENDIENTE: validación syscolumns DBA Etapa 2.*
