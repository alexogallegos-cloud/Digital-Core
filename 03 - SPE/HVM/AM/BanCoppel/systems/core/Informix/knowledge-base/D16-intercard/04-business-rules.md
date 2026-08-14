# D16 · Intercard (Tarjetas) — Reglas de Negocio

> **Componente:** Informix · SPE-AM-001
> **Base de datos:** `intercard`
> **Última actualización:** 2026-08-03

---

## Resumen de densidad de reglas

| SP | Rules | LOC | Tipo dominante |
|----|------:|----:|----------------|
| `sp_contacto_vencimiento_credito` | 49 | 1,011 | Elegibilidad de contacto, calendario |
| `sp_contacto_vencimiento_debito` | 46 | 998 | Elegibilidad de contacto, calendario |
| `sp_reporte_parametrico_rpt` | 20 | — | Parámetros de reportes |
| `sp_carga_ctes_enrola` | 16 | 1,778 | Validación de enrolamiento |
| `sp_validaexistenciatarjetasbandachip` | 8 | — | Validación de chip/banda |
| `sp_registra_evento` | 8 | — | Registro de eventos |
| `sp_horasazules_obtener_tdc_clientes` | 6 | 1,333 | Elegibilidad Horas Azules |
| `sp_actualizainventarj` | 4 | — | Inventario de tarjetas |
| `sp_consultatarjetabini_02_pbajlh` | 4 | — | (versión prueba) |
| `sp_genrep_puntoscompromiso` | 4 | — | Puntos de compromiso de pago |

**Total reglas inventariadas en D16:** ~170+ (extraídas de brain.db)

---

## BR-D16-C01 a C49 · Contacto por vencimiento — crédito

`[SME-PENDING]` Las 49 reglas de `sp_contacto_vencimiento_credito` requieren sesión de validación con Industry Banking y Cybersecurity para mapeo completo. Categorías esperadas:

| Categoría | Reglas estimadas | Descripción |
|-----------|:----------------:|-------------|
| Elegibilidad de contacto (canal preferido) | ~10 | SMS vs. email vs. llamada según preferencia del cliente |
| Frecuencia de contacto (CONDUSEF) | ~8 | Máximo N intentos por período, horario permitido |
| Umbral de días antes de vencimiento | ~6 | D-15, D-7, D-3, D-1 |
| Tipos de producto elegibles | ~5 | TDC vs. crédito personal vs. crédito de nómina |
| Status de cuenta | ~8 | Solo cuentas activas, no canceladas, no en litigio |
| Actualización de campos post-contacto | ~7 | next_contact_date, attempt_count, channel_used |
| Excepciones y errores | ~5 | Manejo de fallas de canal de notificación |

**Riesgo regulatorio:** CONDUSEF Circular 11/2011 — prohíbe contacto antes de las 8:00am y después de las 9:00pm. Las reglas de ventana horaria son de cumplimiento obligatorio.

---

## BR-D16-D01 a D46 · Contacto por vencimiento — débito

Estructura paralela a crédito. 46 reglas en `sp_contacto_vencimiento_debito`. Diferencia esperada: los productos de débito tienen ciclos de vencimiento distintos (fecha de corte vs. fecha de pago mínimo). `[SME-PENDING]`

---

## BR-D16-E01 a E16 · Enrolamiento de clientes

`sp_carga_ctes_enrola` · 16 reglas. Categorías inferidas del nombre y patrón:

| Regla | Descripción inferida |
|-------|----------------------|
| E01 | Cliente debe existir en bdicred o bdicheq antes de enrolar |
| E02 | Tipo de producto válido para enrolamiento en intercard |
| E03 | Límite de crédito inicial ≥ umbral mínimo del producto |
| E04 | Datos PII completos (nombre, RFC, CURP, domicilio) |
| E05 | No duplicados: un cliente no puede enrolarse dos veces en el mismo producto |
| E06–E16 | `[SME-PENDING]` — requieren lectura directa del código fuente |

---

## BR-D16-H01 a H06 · Horas Azules (programa de lealtad)

`sp_horasazules_obtener_tdc_clientes` · 6 reglas:

| Regla | Descripción inferida |
|-------|----------------------|
| H01 | TDC con status ACTIVA únicamente |
| H02 | No incluir tarjetas BLOQUEADA, CANCELADA o EN_LITIGIO |
| H03 | Tipo de tarjeta elegible para el programa (no todas las TDC participan) |
| H04 | Ventana horaria "Horas Azules" activa al momento de la consulta |
| H05 | Límite de crédito disponible > 0 |
| H06 | `[SME-PENDING]` — criterio de antigüedad o saldo mínimo |

---

## BR-D16-V01 · Validación de cancelación

`sp_cancelacion_tarjeta` · 0 reglas registradas en brain.db (57 LOC — SP muy conciso). El SP probablemente ejecuta un UPDATE directo sin validación previa (la validación la hace el llamador en D03). `[SME-PENDING]` confirmar si existen validaciones implícitas en el UPDATE.

---

## Riesgo de migración — reglas de negocio D16

| Riesgo | Descripción | Severidad |
|--------|-------------|-----------|
| R-D16-01 | 49+46 reglas de contacto sin documentar — riesgo de incumplimiento CONDUSEF en target | N3 |
| R-D16-02 | Reglas de elegibilidad Horas Azules con lógica de horario embebida en SPL — difícil de externalizar | N2 |
| R-D16-03 | `sp_carga_ctes_enrola` batch de 1,778 LOC con 16 reglas — golden master complejo | N2 |

---
*Generado: 2026-08-03 · fuente: brain.db rules count + inferencia del patrón de nombres · `[SME-PENDING]` requiere análisis del código fuente*
