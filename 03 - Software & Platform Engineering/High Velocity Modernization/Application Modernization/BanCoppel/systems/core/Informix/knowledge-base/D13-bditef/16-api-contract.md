# D13 · Transferencias Electrónicas de Fondos (TEF) — Contrato de API

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 4 — Design
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Architect Target — BCOPCore (diseño del contrato)
- SME — Core Banking Transformation (patrones de API bancaria)
- SME Regulatorio — CNBV (campos regulatorios obligatorios)

> Este documento define el contrato de API preliminar del microservicio `TransferenciasService`. Requiere revisión y aprobación del Architect Target antes de BUILD.
---

## Descripción

`TransferenciasService` expone una API REST que encapsula la lógica de los 139 SPs de `bditef`. El contrato define endpoints, esquemas de entrada/salida y el catálogo de errores tipados que reemplazan los códigos `char(5)` y los códigos ESB del sistema legacy.

**URL base:** `https://api.bancoppel.internal/transferencias/v1`

---

## Endpoints

### POST `/enviar` — Envío de transferencia TEF

Reemplaza: `sp_tef_grabaoperacion`, `sp_grabaoperaciontef`, `sp_tef_valida_datos`, `sp_tef_validahorario`

**Request:**
```json
{
  "empresa": "string(3)",
  "cuentaOrigen": "string(20)",
  "bancoDest": "string(3)",
  "cuentaDest": "string(20)",
  "importe": "number(16,2)",
  "moneda": "string(2)",
  "usuario": "string(8)",
  "fechaOperacion": "date (ISO 8601: YYYY-MM-DD)",
  "concepto": "string(40) [opcional]"
}
```

**Response 200 (éxito):**
```json
{
  "folio": "string(36) — UUID v4",
  "estado": "ENVIADA | PENDIENTE_CECOBAN",
  "fechaAplicacion": "date",
  "mensaje": "string"
}
```

**Validaciones de negocio aplicadas:** BR-D13-001 a BR-D13-007, BR-D13-REG-001 a BR-D13-REG-002.

---

### POST `/reverso` — Reverso de transferencia TEF

Reemplaza: `sp_tef_reversoperacion`, `sp_tef_buscaoperacion`

**Request:**
```json
{
  "folioOriginal": "string(36)",
  "empresa": "string(3)",
  "usuario": "string(8)",
  "motivoReverso": "string(2) — código CECOBAN"
}
```

**Response 200:**
```json
{
  "folioReverso": "string(36)",
  "folioOriginal": "string(36)",
  "estado": "REVERTIDA",
  "mensaje": "string"
}
```

---

### GET `/consulta` — Consulta de operaciones

Reemplaza: `sp_consultarepop_tef`, `sp_obtenerinformaciontef`, `sp_revoperacionestef`

**Query parameters:**
```
empresa=string(3) [requerido]
cuentaOrigen=string(20) [opcional]
fechaDesde=date ISO 8601 [requerido]
fechaHasta=date ISO 8601 [requerido]
estado=string(20) [opcional]
pagina=integer [opcional, default=1]
registrosPorPagina=integer [opcional, default=50]
```

**Response 200:**
```json
{
  "total": "integer",
  "pagina": "integer",
  "operaciones": [
    {
      "folio": "string(36)",
      "cuentaOrigen": "string(20)",
      "bancoDest": "string(3)",
      "cuentaDest": "string(20)",
      "importe": "number(16,2)",
      "moneda": "string(2)",
      "fechaOperacion": "date",
      "estado": "string",
      "motivoDevolucion": "string(2) [si aplica]"
    }
  ]
}
```

---

### GET `/estado/{folio}` — Estado de una operación

Reemplaza: `sp_tef_buscaoperacion`

**Response 200:**
```json
{
  "folio": "string(36)",
  "estado": "ENVIADA | PENDIENTE_CECOBAN | ACREDITADA | DEVUELTA | REVERTIDA",
  "fechaActualizacion": "datetime ISO 8601",
  "motivoDevolucion": "string(2) [si aplica]",
  "descripcionMotivo": "string(45) [si aplica]"
}
```

---

## Catálogo de errores tipados

Reemplaza los códigos `char(5)` legacy y los códigos ESB de INC-005.

| Código HTTP | Código de error interno | Descripción | SP/código legacy |
|-------------|------------------------|-------------|-----------------|
| 400 | `CUENTA_INVALIDA` | Cuenta origen nula o vacía | `00400` · BR-D13-001 |
| 400 | `IMPORTE_INSUFICIENTE` | Saldo insuficiente para la operación | BR-D13-025 |
| 400 | `HORARIO_NO_HABIL` | Operación fuera del horario hábil TEF | BR-D13-REG-001 |
| 400 | `DATOS_INVALIDOS` | Error de validación de datos de entrada | `00400` · BR-D13-003 |
| 400 | `BANCO_INVALIDO` | Código de banco destino no registrado en CECOBAN | — |
| 403 | `CUENTA_BLOQUEADA` | Cuenta origen tiene bloqueo activo | `vmotdevol="09"` · BR-D13-020 a BR-D13-022 |
| 404 | `OPERACION_NO_ENCONTRADA` | Folio no existe en el sistema | `00001` |
| 409 | `FOLIO_DUPLICADO` | El folio ya existe (idempotencia) | Informix -268 |
| 422 | `DIA_NO_HABIL` | La fecha de operación es un día no hábil bancario | `si_feriado` |
| 503 | `SISTEMA_TEF_TIMEOUT` | Sistema TEF externo no responde (timeout 30s) | ESB code `3743` |
| 503 | `MQ_UNAVAILABLE` | IBM MQ no disponible | ESB code `4394` |
| 503 | `SSL_ERROR` | Error de certificado TLS con endpoint externo | ESB code `3165` |
| 503 | `JNI_ERROR` | Error de comunicación JNI/Axis2 | ESB code `3701` |
| 500 | `ERROR_INTERNO` | Error interno no categorizado | `09999` · ESB code `6233` `[SME-PENDING]` |

---

## Enumeraciones de dominio

```java
// Estado de operación TEF
enum EstadoOperacion {
    ENVIADA,           // Registrada, enviada a CECOBAN
    PENDIENTE_CECOBAN, // En espera de confirmación de CECOBAN
    ACREDITADA,        // CECOBAN confirmó la acreditación
    DEVUELTA,          // CECOBAN devolvió la operación
    REVERTIDA          // Reverso aplicado
}

// Motivos de devolución CECOBAN (parcial — completar con catálogo vigente)
enum DevolucionCECOBAN {
    // "[09]" = CUENTA_BLOQUEADA
    CUENTA_BLOQUEADA("09"),
    // "[18/53]" = motivo cambiado en 2012 (ver BR-D13-023)
    MOTIVO_18_53("53"),
    // Catálogo completo: [DATO-REQUERIDO]
    ;
    private final String codigo;
    DevolucionCECOBAN(String codigo) { this.codigo = codigo; }
}
```

---

## Versioning y compatibilidad

| Versión | URL | Estado |
|---------|-----|--------|
| v1 | `/transferencias/v1/` | TARGET — Wave 3 |
| legacy | ESB endpoint SOAP | A deprecar tras cutover Wave 3 |

---

## `[SME-PENDING]`

- [ ] Confirmar los campos regulatorios obligatorios CNBV en el request de envío (ej. CLABE, referencia numérica).
- [ ] Definir el catálogo completo de `DevolucionCECOBAN` con los códigos vigentes 2026.
- [ ] Confirmar el SLA de respuesta del sistema TEF externo para definir el timeout del circuit breaker.
- [ ] Validar si el Architect Target requiere soporte de idempotency key en el header HTTP para `/enviar`.
- [ ] Confirmar si `cuentaDest` es CLABE (18 dígitos) o número de cuenta (20 dígitos) — requiere validación con CNBV.

---
*Generado por análisis de SP callgraph + codigos ESB INC-005 + códigos de retorno char(5) del dominio*
