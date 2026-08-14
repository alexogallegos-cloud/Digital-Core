# D13 · Transferencias Electrónicas de Fondos (TEF) — Dependencias Externas

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — Core Banking Transformation (dependencias de integración)
- SME Regulatorio — CNBV (requisitos de CECOBAN y sistema TEF externo)
- Architect Target (estrategia de desacoplamiento y API adapter)

---

## Descripción

Catálogo de dependencias externas del dominio `bditef` — sistemas y servicios fuera del perímetro de la base de datos que deben seguir operando durante y después de la migración.

---

## DEP-EXT-001 · CECOBAN — Centro de Compensación Bancaria

| Atributo | Valor |
|----------|-------|
| **Tipo** | Sistema externo regulatorio (organización supervisada por Banxico) |
| **Protocolo de comunicación** | SFTP para transferencia de archivos de cámara |
| **Formatos de archivo** | Formato 10 (respuesta), 60 (crédito), 61, 62, 63 (variantes) |
| **SPs involucrados** | `sp_tef_subirarchivos`, `sp_tef_buscararchivo`, `sp_tef_validarnombrearchivos`, todos los `sp_tef_procesararchivo*`, todos los `sp_tef_generararchivo*` |
| **Criticidad** | CRÍTICA — sin esta dependencia BanCoppel no puede participar en la cámara interbancaria |
| **Ventana operativa** | `[SME-PENDING]` — horario de ciclos de cámara definido por CECOBAN/Banxico |
| **Riesgo de migración** | El microservicio `TransferenciasService` debe mantener compatibilidad exacta con los formatos de archivo CECOBAN. Un error de formato implica rechazo de todo el lote por CECOBAN. |
| **Acción requerida** | Certificar el formato de archivos generados con CECOBAN antes del cutover. |

### Archivos de cámara y SPs asociados

| Formato | Dirección | SP generador | SP procesador | Descripción |
|---------|-----------|-------------|--------------|-------------|
| 10 | Recepción de CECOBAN | — | `sp_tef_procesararchivo10` | Respuesta de CECOBAN a presentación |
| 60 | Envío a CECOBAN | `sp_tef_generararchivo60` | `sp_tef_procesararchivo60` | Presentación de crédito |
| 61 | Recepción de CECOBAN | — | `sp_tef_procesararchivo61` | Crédito recibido de otros bancos |
| 62 | Bilateral | `sp_tef_generararchivo62` | `sp_tef_procesararchivo62` | Devoluciones |
| 63 | Bilateral | `sp_tef_generararchivo63` | `sp_tef_procesararchivo63` | Débito |

---

## DEP-EXT-002 · ESB BanCoppel (IBM Integration Bus / App Connect Enterprise)

| Atributo | Valor |
|----------|-------|
| **Tipo** | Bus de integración empresarial interno de BanCoppel |
| **Tecnología** | IBM IIB (Integration Bus) / ACE (App Connect Enterprise) |
| **Protocolo** | SOAP/HTTP, JNI, IBM MQ, Axis2 |
| **SPs involucrados** | Todos los entry points del dominio expuestos como servicios SOAP |
| **Criticidad** | CRÍTICA — toda la comunicación canal→dominio pasa por el ESB |
| **Incidente activo** | INC-005 — 5 códigos de error sin runbook (4394, 3743, 3701, 3165, 6233) |
| **Riesgo de migración** | El microservicio `TransferenciasService` debe publicar un endpoint equivalente que el ESB pueda invocar. Si el ESB persiste en paralelo durante el período de transición, debe apuntar al nuevo endpoint. |

### Códigos ESB activos (INC-005)

| Código ESB | Frecuencia estimada/día | Descripción | Runbook |
|------------|------------------------|-------------|---------|
| `4394` | ~2,452 | IBM MQ MbUserException — fallo de mensajería interna | Sin runbook |
| `3743` | ~761 | SOAP Handle Timed-out (~30s) | Sin runbook |
| `3701` | ~356 | JNI/Axis2 non-SOAP call error | Sin runbook |
| `3165` | ~320 | SSL socket error on connect | Sin runbook |
| `6233` | ~264 | Sin descripción disponible | `[SME-PENDING]` |

> Ver `06-exceptions.md` para el análisis completo de estos códigos y su mapeo al target.

---

## DEP-EXT-003 · Sistema TEF Externo

| Atributo | Valor |
|----------|-------|
| **Tipo** | Sistema externo de procesamiento de transferencias (proveedor `[DATO-REQUERIDO]`) |
| **Protocolo** | SOAP / Axis2 / JNI (evidenciado por código ESB 3701 y 3743) |
| **Criticidad** | CRÍTICA — procesa las transferencias en tiempo real |
| **Riesgo activo** | ESB code 3743 (timeout ~30s) indica que el sistema puede no responder dentro del SLA |
| **SPs involucrados** | `sp_tef_grabaoperacion`, `sp_tef_validahorario`, `sp_tef_valida_datos` (via ESB) |
| **Acción requerida** | Implementar circuit breaker en `TransferenciasService` con retry policy. Definir SLA de respuesta en el target. |
| **`[DATO-REQUERIDO]`** | Nombre del proveedor del sistema TEF externo, versión del API, documentación del WSDL |

---

## DEP-EXT-004 · SPEI (D08 — `bdispei`)

| Atributo | Valor |
|----------|-------|
| **Tipo** | Dominio hermano funcional dentro del mismo ecosistema Informix |
| **Relación** | Misma regulación Banxico. Ambos son mecanismos de transferencia interbancaria. Las devoluciones SPEI pueden llegar al dominio TEF y viceversa. |
| **Criticidad** | ALTA — dependencia funcional de validación de fechas y calendario hábil compartido |
| **Riesgo de migración** | Deben migrar en el mismo wave o coordinados. Una migración desincronizada puede generar inconsistencias en el calendario de días hábiles y en el enrutamiento de transferencias. |
| **Acción requerida** | Coordinar Wave 3 con el equipo de D08-bdispei. |

---

## DEP-EXT-005 · `bdicheq` — D[X] Cheques (cross-DB)

| Atributo | Valor |
|----------|-------|
| **Tipo** | Dominio interno del mismo sistema BanCoppel (cross-DB Informix) |
| **Dependencia** | 12 tablas de `bdicheq` accedidas directamente; 2 SPs de `bdicheq` llamados desde `bditef` |
| **Criticidad** | CRÍTICA — sin acceso a `bdicheq` los SPs `cargo_cta` y `abono_cta` no pueden ejecutarse |
| **Riesgo** | RSK-D13-002 — migración coordinada obligatoria |
| **Detalle** | Ver `07-dependencies.md` |

---

## Estrategia de desacoplamiento en el target

En el estado actual, `bditef` accede directamente a `bdicheq` mediante referencias cross-DB de Informix (`bdicheq:tabla`). En el target AWS esta dependencia debe transformarse en:

1. **Llamada API interna** → `ChequeService` expone los endpoints que `TransferenciasService` necesita (`/cuenta/{id}/validar`, `/cuenta/{id}/cargo`, `/cuenta/{id}/abono`).
2. **Transacciones distribuidas** → Saga pattern para garantizar consistencia entre cargo en cheques y registro en TEF.
3. **Datos maestros compartidos** → El calendario de días hábiles (`si_feriado`) y los parámetros CECOBAN (`cce_param`) deben migrar a un servicio centralizado `MasterDataService` o a una tabla compartida en Aurora.

---

## `[SME-PENDING]`

- [ ] Confirmar el nombre y versión del sistema TEF externo (DEP-EXT-003).
- [ ] Obtener el WSDL del servicio SOAP del sistema TEF para diseñar el adapter.
- [ ] Confirmar el SLA de respuesta del sistema TEF externo (actualmente evidencia de timeout a 30s).
- [ ] Validar con CECOBAN los formatos de archivo vigentes para 2026.
- [ ] Confirmar si el ESB actual seguirá operando durante el período de transición o se migra simultáneamente.

---
*Generado por análisis de SPs del callgraph + INC-005 + contexto regulatorio TEF/CECOBAN*
