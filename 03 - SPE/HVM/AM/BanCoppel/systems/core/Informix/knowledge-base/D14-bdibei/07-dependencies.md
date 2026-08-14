# D14 · Banca Electrónica Institucional (BEI) — Dependencias Internas (Cross-DB)

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático de cross-DB calls)
- DBA — IBM Informix IDS (verificación en producción — Etapa 2)
- Core Banking Transformation (diseño de APIs de integración interna)
- Industry Banking (impacto funcional de cada dependencia)

> `[SME-PENDING]` = requiere verificación en código fuente de los 294 SPs aislados.
---

## Por qué no hay package.json en Informix SPL

Las dependencias en SPL se manifiestan como: (1) prefijos de dominio en sentencias `EXECUTE PROCEDURE dominio:sp_nombre()`, (2) tablas cruzadas `FROM dominio:tabla`, (3) nombres de SPs que revelan integraciones, (4) referencias a DSNs de conexión en comentarios.

## Resumen de dependencias detectadas / inferidas

| # | Dependencia | Tipo | Criticidad | Evidencia |
|---|------------|------|-----------|----------|
| DEP-BEI-01 | IBM Informix IDS 14.10 | Motor de BD (a reemplazar) | CRÍTICA | Todo el dominio |
| DEP-BEI-02 | Scheduler AIX (cron/UC4/Control-M) | Orquestación batch nómina | CRÍTICA | SPs batch sin caller visible en logs |
| DEP-BEI-03 | `bdispei` (D08 — SPEI) | Cross-DB call / integración | CRÍTICA | Inferida — toda dispersión interbancaria usa SPEI |
| DEP-BEI-04 | `bdicred` (D03 — Crédito) | Cross-DB call | ALTA | Inferida — autorización de empresa |
| DEP-BEI-05 | `bdinteg` (Integración/Auth) | Cross-DB call | ALTA | Patrón observado en otros dominios; autenticación empresa |
| DEP-BEI-06 | `bdicont` (D12 — Contabilidad) | Cross-DB call | ALTA | Registro contable de dispersiones |
| DEP-BEI-07 | `bdisac` (Saldos/Cuentas) | Cross-DB call | ALTA | Cargo a cuenta empresa origen de dispersión |
| DEP-BEI-08 | ESB BanCoppel (IBM IIB/MQ) | Middleware de mensajería | CRÍTICA | INC-006 — códigos 4394, 3743, 3701, 3165, 6233 |
| DEP-BEI-09 | `sysmaster` | Cross-DB call (Informix interno) | BAJA | `getrandomcode` accede a `systables` para entropía |

---

## DEP-BEI-01 · IBM Informix IDS 14.10 — Motor de BD (a reemplazar)

| Atributo | Valor |
|----------|-------|
| Motor actual | IBM Informix IDS 14.10 FC10W2 / POWER-AIX |
| Motor target | Aurora PostgreSQL 15+ |
| Funciones SPL a reescribir | Ver `15-type-mapping.md` |
| Tipos críticos en BEI | MONEY (montos de dispersión) · SERIAL (folios) · DATETIME YEAR TO FRACTION (timestamps batch) |

---

## DEP-BEI-02 · Scheduler AIX — Orquestación Batch Nómina

**Criticidad:** CRÍTICA — sin scheduler el batch de nómina no se ejecuta.

| Atributo | Valor |
|----------|-------|
| Herramienta actual | `[SME-PENDING]` — UC4, Control-M, o cron nativo AIX |
| Job crítico | Dispersión de nómina quincenal |
| Frecuencia | Quincenal (días 1 y 15 del mes, o primer/último hábil) |
| Target equivalente | AWS EventBridge Scheduler + Step Functions |

**Acción urgente — verificar en producción:**
```bash
crontab -u informix -l
find /opt /home -name "*.cron" 2>/dev/null
# Buscar jobs con "bei" o "nomina" o "dispersion"
```

**Riesgo:** si el scheduler no está documentado, puede haber jobs de BEI que se ejecuten en horarios desconocidos. El target debe replicar exactamente los mismos horarios o acordar con el negocio un cambio explícito.

---

## DEP-BEI-03 · `bdispei` (D08) — Liquidación SPEI

**Criticidad:** CRÍTICA — toda dispersión a beneficiarios en otros bancos requiere SPEI.

| Atributo | Valor |
|----------|-------|
| Dominio | D08-bdispei (Banca Electrónica — SPEI) |
| Tipo de integración | Cross-DB call (dentro del motor Informix) → API call en target |
| Operación | Envío de instrucción de transferencia SPEI por cada beneficiario interbancario |
| Impacto si no disponible | Dispersiones interbancarias bloqueadas — solo acrédita en cuentas BanCoppel propias |
| Regulación | Banxico — protocolo SPEI; certificación SPEI de BanCoppel debe mantenerse |

**En el target:** la cross-DB call se convierte en llamada API interna al `SPEIService` (microservicio del dominio D08). Requiere definir contrato OpenAPI con D08 antes del BUILD de D14.

**Dependencia de Wave:** D08 debe estar disponible (en Informix legacy vía API wrapper, o migrado) antes de que BEI pueda hacer su cutover. Coordinar secuencia de waves.

---

## DEP-BEI-04 · `bdicred` (D03) — Autorización de Crédito Empresa

**Criticidad:** ALTA — verificación de línea de crédito empresa antes de dispersar.

| Atributo | Valor |
|----------|-------|
| Dominio | D03-bdicred (Crédito) |
| Operación | Consulta de límite de crédito disponible de la empresa para la dispersión |
| Impacto si no disponible | Riesgo de dispersar más de lo autorizado — exposición crediticia de BanCoppel |

**En el target:** API call a `CreditoEmpresaService`. Requiere contrato API antes del BUILD.

---

## DEP-BEI-05 · `bdinteg` — Integración y Autenticación

**Criticidad:** ALTA — autenticación de empresa y parámetros operativos.

| Atributo | Valor |
|----------|-------|
| Dominio | bdinteg (Integración/Autenticación) |
| Operación | Validación de sesión empresa · tabla `si_feriado_banca` (días no hábiles) |
| Impacto si no disponible | Login empresa falla · validación de fechas hábiles incorrecta |

**En el target:** API call a `IntegrationAuthService`. Días feriados debe migrar a catálogo propio en PostgreSQL con job de sincronización desde Banxico.

---

## DEP-BEI-06 · `bdicont` (D12) — Contabilidad

**Criticidad:** ALTA — registro contable de cada dispersión para CNBV.

| Atributo | Valor |
|----------|-------|
| Dominio | D12-bdicont (Contabilidad) |
| Operación | INSERT en cuenta contable de dispersión (CUB Anexo 33 — Plan de cuentas CNBV) |
| Impacto si no disponible | Dispersiones sin registro contable — incumplimiento CNBV |
| Regulación | CNBV CUB Anexo 33-36 — SME Industry Banking Accounting |

**En el target:** API call a `ContabilidadService` (dominio D12). El contrato debe incluir: importe, cuenta contable, concepto, fecha valor, referencia dispersión.

---

## DEP-BEI-07 · `bdisac` (D05) — Saldos y Cuentas

**Criticidad:** ALTA — cargo a la cuenta empresa origen de la dispersión.

| Atributo | Valor |
|----------|-------|
| Dominio | D05-bdisac (Saldos y Cuentas) |
| Operación | Cargo a la cuenta de dispersión de la empresa (cuenta origen del lote) |
| Impacto si no disponible | Imposible ejecutar la dispersión sin debitar la cuenta empresa |

**En el target:** API call a `CuentasService` (D05). Operación atómica con la dispersión — debe ser parte de la misma transacción distribuida o saga compensatoria.

---

## DEP-BEI-08 · ESB BanCoppel (IBM IIB/MQ)

**Criticidad:** CRÍTICA — middleware de mensajería para integraciones externas BEI.

| Atributo | Valor |
|----------|-------|
| Tecnología actual | IBM Integration Bus (IIB) + IBM MQ |
| Tecnología target | Amazon MSK (Kafka) + EventBridge para eventos + HTTP directo para síncronos |
| Errores activos | 5 códigos INC-006: 4394 · 3743 · 3701 · 3165 · 6233 (ver `06-exceptions.md`) |
| Impacto en batch nómina | Código 4394 puede dejar lote completo sin procesar (ver `06-exceptions.md §4394`) |

**Acciones antes de cutover:**
1. Mapear cada servicio ESB que bdibei consume a su equivalente en el target.
2. Implementar circuit breakers y reintentos en el microservicio BEI.
3. Definir política de DLQ (Dead Letter Queue) para mensajes fallidos.
4. Documentar los 5 códigos ESB en el runbook operativo del target.

---

## DEP-BEI-09 · `sysmaster` / `systables` — Informix Interno

**Criticidad:** BAJA — solo usado por `getrandomcode` para entropía.

| Atributo | Valor |
|----------|-------|
| Uso | `SELECT COUNT(*) FROM systables` como fuente de "aleatoriedad" |
| Impacto en target | Eliminar completamente — usar `SecureRandom` en Java |

---

## Matriz de impacto en cutover

| Dependencia | ¿Bloquea cutover BEI? | Plan de continuidad | Owner |
|------------|----------------------|---------------------|-------|
| IBM Informix IDS | SÍ — es el motor | Aurora PostgreSQL 15+ | DBA + Cloud Architect |
| Scheduler AIX (batch nómina) | SÍ — sin scheduler no hay nómina | AWS EventBridge Scheduler + Step Functions | DevOps |
| `bdispei` (D08 SPEI) | SÍ — para dispersiones interbancarias | API wrapper D08 o cutover simultáneo | Architect AM |
| `bdicred` (D03) | Parcial — solo si dispersar sin autorización credit | API call a CreditoEmpresaService | Architect AM |
| `bdinteg` | Parcial — autenticación empresa | API call a IntegrationAuthService | Architect AM |
| `bdicont` (D12) | Parcial — sin registro contable CNBV | API call a ContabilidadService | Architect AM + Industry Banking Accounting |
| `bdisac` (D05) | SÍ — cargo a cuenta origen es obligatorio | API call a CuentasService | Architect AM |
| ESB BanCoppel | SÍ — integraciones externas | MSK + HTTP direct; circuit breakers | DevOps + Infra |

---
*Generado por: Specialist — Informix SPL Analysis · 2026-08-03 · Fuente: análisis estático sp-specs-bdibei.md + INC-006 + modelo operativo BEI*
