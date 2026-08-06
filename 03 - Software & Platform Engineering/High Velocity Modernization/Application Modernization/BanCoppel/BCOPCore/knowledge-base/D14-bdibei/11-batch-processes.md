# D14 · Banca Electrónica Institucional (BEI) — Procesos Batch

> **Componente:** BCOPCore · SPE-AM-001 · DISCOVER / BUILD Phase
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- DBA — IBM Informix IDS (horarios reales del scheduler AIX — Etapa 2) ← FUENTE DE VERDAD
- Specialist — Informix SPL Analysis (SPs batch identificados por análisis estático)
- Domain Expert — BanCoppel (validación de lógica y horarios de negocio BEI)
- SRE & AIOps (monitoreo de jobs batch en target, alertas de fallo)
- Industry Banking (impacto regulatorio de fallos en batch)

> `[SME-PENDING]` = requiere sesión con DBA y Domain Expert para confirmar horarios y SPs reales de cada job.
---

## Importancia crítica de los procesos batch en BEI

Los procesos batch del dominio `bdibei` son **los de mayor criticidad empresarial del proyecto BCOPCore** por una razón única: el batch de nómina afecta directamente a los empleados de las empresas clientes de BanCoppel. Un fallo de batch durante la migración tiene impacto inmediato en personas reales (no en transacciones anónimas), genera reclamaciones masivas ante CONDUSEF, y puede comprometer la relación de BanCoppel con sus clientes empresa.

## Por qué los batches no aparecen en los logs de producción de un día

Los 294 SPs aislados incluyen muy probablemente los SPs de batch. Los logs del 2026-04-24 corresponden a un día de producción normal. Los batches de nómina solo se ejecutan en las quincenas (días 1 y 15 del mes, o los primeros y últimos hábiles). Si el 2026-04-24 fue un día normal, los SPs de batch estaban en producción pero inactivos.

**Esto NO significa que sean dead code.** Son los procesos más importantes del dominio.

---

## BATCH-BEI-01 — Dispersión de Nómina Quincenal ⚠️ PROCESO CRÍTICO

| Atributo | Valor |
|----------|-------|
| **Criticidad** | CRÍTICA — máxima del proyecto BCOPCore |
| **Tipo** | Batch quincenal |
| **Frecuencia** | 2 veces al mes — día 1 y día 15 (o primer/último hábil del mes) |
| **Ventana de ejecución** | `[SME-PENDING]` — probable: 22:00 h - 04:00 h CDMX (ventana nocturna) |
| **SP entry point** | `[SME-PENDING]` — requiere DBA Informix + Domain Expert BanCoppel |
| **Dominio fuente** | `bdibei` |
| **Dominios dependientes** | D08-bdispei (SPEI para interbancarios) · D05-bdisac (cargo cuenta empresa) · D12-bdicont (registro contable) |
| **Impacto de fallo** | Empleados de empresas clientes BanCoppel sin pago de nómina |
| **Regulación** | CNBV CUB Art. 48 · CONDUSEF LPDUSF Art. 50 |

**Restricción CRÍTICA de migración:**

> **El cutover del dominio D14-bdibei NO puede ocurrir durante los días 1–3 ni los días 15–18 de ningún mes calendario.** Si el cutover coincide con el ciclo de nómina activo y ocurre algún problema, el batch de nómina fallará y los empleados no recibirán su pago.

Ventana segura para cutover: días 5–13 y días 20–28 del mes (ver `20-cutover-plan.md` para restricciones completas).

**Descripción del proceso (inferido del modelo operativo BEI):**

```
1. El scheduler AIX (cron / UC4 / Control-M) lanza el job de nómina
2. Job llama al SP entry point de bdibei (SME-PENDING nombre real)
3. SP lee el archivo de nómina cargado por la empresa (bei_archivos_nomina)
4. Para cada registro del archivo:
   a. Valida el convenio empresa (bei_convenios → bdibei)
   b. Verifica límite de crédito empresa (cross-DB → bdicred)
   c. Valida CLABE del beneficiario (formato + dígito verificador)
   d. Si CLABE es BanCoppel → acreditación directa
   e. Si CLABE es otro banco → instrucción SPEI (cross-DB → bdispei)
5. Por cada dispersión exitosa:
   a. INSERT en bei_dispersiones_det
   b. Cargo a cuenta empresa origen (cross-DB → bdisac)
   c. INSERT contable (cross-DB → bdicont)
   d. Cálculo y registro de comisión (bei_comisiones)
6. Al completar el lote:
   a. UPDATE bei_dispersiones (estatus COMPLETADO)
   b. Generación de comprobante para la empresa
```

**Riesgo específico de ESB en este batch:**

```
Si el ESB devuelve error 4394 (IBM MQ) durante el paso 4e (instrucción SPEI):
  - Sin ON EXCEPTION adecuado: todo el lote falla
  - Con ON EXCEPTION pero sin reintentos: ese beneficiario queda en PENDIENTE
  - Con ON EXCEPTION + reintentos: el sistema intenta 3 veces, luego PENDIENTE
  - Sin alerta automática: el equipo de operaciones no se entera hasta el día siguiente
```

**Requisitos del target para este batch:**
- Procesamiento transaccional por beneficiario (no por lote completo) para minimizar impacto de fallos parciales.
- Checkpoint cada 100 beneficiarios: si falla el registro 456 de 5,000, los 455 anteriores ya están acreditados y se continúa desde 456.
- Alerta P1 automática si el job no completa en 120% del tiempo esperado.
- Reintento automático del job con registros PENDIENTE al día siguiente hábil.
- Notificación a la empresa cliente del resultado (exitosos + rechazados).

---

## BATCH-BEI-02 — Dispersión de Pagos Masivos (Proveedores / Servicios)

| Atributo | Valor |
|----------|-------|
| **Criticidad** | ALTA |
| **Tipo** | Batch diario o bajo demanda |
| **Frecuencia** | `[SME-PENDING]` — probable: diario o según demanda empresa |
| **Ventana de ejecución** | `[SME-PENDING]` — probable: horario comercial o nocturno |
| **SP entry point** | `[SME-PENDING]` |
| **Impacto de fallo** | Proveedores / servicios de empresa sin pago |

**Descripción:** proceso análogo al de nómina pero para pagos a proveedores y servicios. Las empresas cargan archivos de pago masivo y BEI los dispersa. Menos crítico que la nómina en términos de impacto inmediato a personas.

---

## BATCH-BEI-03 — Conciliación de Dispersiones del Día

| Atributo | Valor |
|----------|-------|
| **Criticidad** | ALTA |
| **Tipo** | Batch nocturno diario |
| **Frecuencia** | Diario (cierre de operaciones) |
| **Ventana de ejecución** | `[SME-PENDING]` — probable: 22:00 h - 00:00 h CDMX |
| **SP entry point** | `[SME-PENDING]` |

**Descripción:** concilia el estado de todas las dispersiones del día. Identifica dispersiones PENDIENTE que requieren reintento o escalación. Genera el arqueo diario BEI para cuadre contable.

---

## BATCH-BEI-04 — Cálculo de Comisiones Mensual

| Atributo | Valor |
|----------|-------|
| **Criticidad** | MEDIA |
| **Tipo** | Batch mensual |
| **Frecuencia** | Último hábil del mes |
| **Ventana de ejecución** | `[SME-PENDING]` |
| **Regulación** | CONDUSEF (comisiones BEI registradas y transparentes) · SAT (IVA) |

**Descripción:** calcula las comisiones por servicios BEI para cada empresa cliente activa durante el mes. Genera los comprobantes de comisión y el registro contable.

---

## BATCH-BEI-05 — Generación de Reportes Regulatorios

| Atributo | Valor |
|----------|-------|
| **Criticidad** | ALTA |
| **Tipo** | Batch periódico (mensual / trimestral) |
| **Frecuencia** | `[SME-PENDING]` — según calendario CNBV |
| **Regulación** | CNBV — reportes de operaciones de empresa |

**Descripción:** genera los reportes de operaciones BEI requeridos por CNBV (volumen de dispersiones, montos, empresas activas).

---

## Comparación Informix vs Target — Orquestación Batch

| Atributo | Informix (AS-IS) | Target (TO-BE) |
|----------|------------------|----------------|
| Orquestador | Scheduler AIX (cron/UC4/Control-M) | AWS EventBridge Scheduler |
| Ejecución | SP SPL en IBM Informix | AWS Step Functions + microservicio Java |
| Reintentos | `[SME-PENDING]` — sin documentar | Retry automático + DLQ |
| Monitoreo | `[SME-PENDING]` — logs AIX | CloudWatch + PagerDuty alerta P1 |
| Checkpoint | `[SME-PENDING]` | Por cada 100 beneficiarios |
| Notificación fallo | `[SME-PENDING]` | SNS → correo operaciones BEI + PagerDuty |

---

## Acciones urgentes antes de BUILD

- [ ] `[SME-PENDING]` DBA IBM Informix: listar todos los jobs del scheduler AIX con nombre, horario y SP invocado para el dominio BEI.
- [ ] `[SME-PENDING]` Domain Expert BanCoppel: confirmar el nombre del SP entry point del batch de nómina.
- [ ] `[SME-PENDING]` DBA Informix: verificar si los SPs de batch tienen `ON EXCEPTION` con reintentos.
- [ ] `[SME-PENDING]` Domain Expert: confirmar el número típico de beneficiarios por lote de nómina (dimensionamiento del target).
- [ ] Core Banking Transformation: diseñar la arquitectura de Step Functions para el batch de nómina con checkpoint.
- [ ] SRE & AIOps: configurar alerta P1 automática para fallo de batch de nómina (no esperar a que el negocio reporte).

---
*Generado por: Specialist — Informix SPL Analysis + DT-Riesgos · 2026-08-03 · Fuente: sp-specs-bdibei.md + INC-006 + contexto operativo BEI. Horarios y SPs reales PENDIENTES de validación DBA + Domain Expert.*
