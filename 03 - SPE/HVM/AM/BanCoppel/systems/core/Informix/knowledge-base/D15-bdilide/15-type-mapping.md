# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Mapeo de Tipos

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Mapeo de tipos Informix → PostgreSQL/Aurora

### Tipos identificados en el análisis de SPs de bdilide

| Tipo Informix | Tipo Aurora PostgreSQL | Consideraciones para D15 |
|--------------|----------------------|--------------------------|
| `MONEY(16,2)` | `NUMERIC(16,2)` | **CRÍTICO** — usar `RoundingMode.HALF_EVEN` en JDBC. El ajuste `ROUND(x - 0.01)` debe preservarse exactamente tal como está en el código SPL |
| `MONEY` (sin precisión) | `NUMERIC(18,4)` | Inferir precisión del contexto; confirmar con DBA |
| `CHAR(n)` | `CHAR(n)` o `VARCHAR(n)` | Usar `CHAR` solo si el campo es de longitud fija (RFC=13, CURP=18, anio_mes=6). Usar `VARCHAR` para campos de longitud variable |
| `DATE` | `DATE` | Sin zona horaria — compatible |
| `DATETIME YEAR TO FRACTION` | `TIMESTAMP(5) WITHOUT TIME ZONE` | Nunca usar `TIMESTAMPTZ` — rompería semántica temporal del legacy |
| `SMALLINT` | `SMALLINT` | Compatible |
| `INTEGER` | `INTEGER` | Compatible |
| `CHAR(1)` (flags/status) | `CHAR(1)` | Mantener como CHAR para compatibilidad — documentar todos los valores posibles |

### Campos críticos específicos de D15

| Campo | Tipo Informix | Tipo Aurora | Regla especial |
|-------|--------------|-------------|----------------|
| `rfc` | `CHAR(13)` | `CHAR(13)` | RFC mexicano siempre 13 caracteres — NUNCA VARCHAR |
| `curp` | `CHAR(18)` | `CHAR(18)` | CURP mexicano siempre 18 caracteres — NUNCA VARCHAR |
| `anio_mes` | `CHAR(6)` | `CHAR(6)` | Formato AAAAMM — considerar `CHAR(6)` con CHECK constraint |
| `monto_recaudar` | `MONEY(16,2)` | `NUMERIC(16,2)` | HALF_EVEN obligatorio + preservar ajuste -0.01 |
| `imp_tot_ide` | `MONEY(16,2)` | `NUMERIC(16,2)` | HALF_EVEN obligatorio |
| `vmMontLimite` | `MONEY(16,2)` | `NUMERIC(16,2)` | Umbral regulatorio — no redondear al insertar/actualizar |
| `viPorcaRecau` | `MONEY(16,2)` | `NUMERIC(16,2)` | Porcentaje como decimal (p. ej. `0.0075` para 0.75%) |

## Manejo del redondeo MONEY — regla crítica D15

La fórmula `ROUND(vmMontoRecaudar - 0.01)` en `sp_acumulacionoperaciones` implica un ajuste de redondeo que debe implementarse exactamente. En Java:

```java
// Implementación correcta para D15:
BigDecimal montocalculado = impTotIde.subtract(montLimite);
BigDecimal montoRecaudar = montoCalculado.multiply(porcaRecau);
// Ajuste histórico del legacy — NO modificar sin sign-off de Cumplimiento
BigDecimal montoFinal = montoRecaudar
    .subtract(new BigDecimal("0.01"))
    .setScale(0, RoundingMode.HALF_EVEN);  // ROUND sin decimales
```

> `[COMPLIANCE-SIGN-OFF-REQUIRED]` — Esta fórmula reporta directamente al SAT. Cualquier cambio en la lógica de redondeo debe aprobarse con el Área de Cumplimiento.

## Tipos de retorno de SPs

| Convención Informix | Equivalente Java | Notas |
|--------------------|-----------------|-------|
| `RETURNING CHAR(5)` | `String codigoRetorno` (5 chars) | Verificar que la longitud no exceda 5 caracteres en ningún path |
| `RETURNING CHAR(6)` | `String codigoRetorno` (6 chars) | Algunos SPs retornan 6 caracteres |
| `RETURNING CHAR(5), CHAR(5), INTEGER` | `PldReturnDto` con múltiples campos | Crear DTOs por SP para evitar pérdida de retornos múltiples |

## Tipos en la interfaz con sistemas externos

| Sistema | Tipo de dato en el archivo/protocolo | Mapeo en target |
|---------|-------------------------------------|----------------|
| SAT (archivos de intercambio) | Texto delimitado / posicional | `String` — preservar el formato exacto byte-a-byte |
| CNBV (reportes PLD) | `[DATO-REQUERIDO]` — obtener layout | `[DATO-REQUERIDO]` |
| SHCP (operaciones relevantes) | `[DATO-REQUERIDO]` — obtener layout ARCO | `[DATO-REQUERIDO]` |
| Buró de Crédito (CHI) | `[DATO-REQUERIDO]` — protocolo CHI | `[DATO-REQUERIDO]` |

## Configuración JDBC recomendada para D15

```yaml
# application.yml del LideService
spring:
  datasource:
    url: jdbc:postgresql://bdilide-aurora.cluster-xxxx.us-east-1.rds.amazonaws.com:5432/bdilide
    hikari:
      connection-timeout: 3000      # 3s — PLD no puede esperar
      maximum-pool-size: 20
      minimum-idle: 5
  jpa:
    properties:
      hibernate:
        jdbc:
          time_zone: America/Mexico_City   # Preservar timezone del AIX legacy
        default_schema: pld
      # CRÍTICO: configurar HALF_EVEN para todos los NUMERIC
      javax.persistence.lock.timeout: 5000
```

## `[SME-PENDING]`

- [ ] DBA IBM Informix: confirmar los tipos exactos de todos los campos MONEY en `bdilide` (ejecutar `SELECT colname, coltype FROM syscolumns WHERE tabid IN (...)`).
- [ ] Confirmar la precisión exacta de `vmMontLimite` y `viPorcaRecau` — si son MONEY(16,2) o MONEY genérico.
- [ ] Obtener los layouts oficiales de los archivos de reporte para documentar los tipos de datos en los campos de posición fija.
- [ ] Validar con el QA Lead que el golden master incluye verificación del redondeo en `monto_recaudar`.

---
*Generado: DBA IBM Informix + Cloud Architect · 2026-08-03*
