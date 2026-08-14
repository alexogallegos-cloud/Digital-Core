# D14 · Banca Electrónica Institucional (BEI) — Dependencias Externas y Terceros

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático de dependencias externas)
- DBA — IBM Informix IDS (DSNs reales y conexiones — Etapa 2)
- Industry Banking (impacto funcional de cada integración externa)
- Cybersecurity (riesgos PII, TLS, autenticación de terceros)
- Core Banking Transformation (diseño de integraciones en el target)
- SRE & AIOps (runbooks ante fallo de cada dependencia externa)

> `[SME-PENDING]` = requiere sesión de validación antes de Etapa 2.
---

## Por qué no hay package.json en Informix SPL

Las dependencias externas en SPL se manifiestan como: (1) nombres de servicios en comentarios de código, (2) DSNs de conexión, (3) URLs hardcodeadas o en parámetros, (4) prefijos de servicios en nombres de SPs, (5) errores de ESB en logs de producción.

## Resumen de dependencias externas detectadas / inferidas

| # | Dependencia | Tipo | Criticidad | Evidencia |
|---|------------|------|-----------|----------|
| EXT-BEI-01 | ESB BanCoppel (IBM IIB / MQ) | Middleware mensajería | CRÍTICA | INC-006 · códigos 4394/3743/3701/3165/6233 |
| EXT-BEI-02 | Sistema SPEI — Banxico | Liquidación interbancaria | CRÍTICA | Inferida — toda dispersión a otro banco usa SPEI |
| EXT-BEI-03 | CNBV — reporte de operaciones empresa | Regulatorio | ALTA | Obligación legal — dispersiones masivas CNBV |
| EXT-BEI-04 | CONDUSEF — canal de reclamaciones | Regulatorio | ALTA | Reclamaciones de empresas/empleados |
| EXT-BEI-05 | SAT — validación RFC empresa | Regulatorio | MEDIA | RFC en alta de convenio empresa |
| EXT-BEI-06 | TESOFE / SHCP | Regulatorio / cliente | MEDIA | `[SME-PENDING]` — confirmar si BanCoppel tiene convenios gobierno vía BEI |
| EXT-BEI-07 | Banxico — catálogo SPEI (CLABEs y bancos) | Catálogo de referencia | ALTA | Validación de CLABE y banco destino |
| EXT-BEI-08 | Sistema de notificaciones empresa | Canal de comunicación | MEDIA | Comprobantes de dispersión enviados a empresa |
| EXT-BEI-09 | Motor de autenticación empresa (PKI/TLS) | Seguridad | ALTA | Login empresa en portal BEI |

---

## EXT-BEI-01 · ESB BanCoppel (IBM Integration Bus / IBM MQ)

> **Fuente:** INC-006 · `migration-risk-register.md` P655-R005 · `06-exceptions.md`

**Criticidad:** CRÍTICA — el ESB es el middleware que conecta BEI con todos los sistemas externos.

| Atributo | Valor |
|----------|-------|
| Tecnología actual | IBM Integration Bus (IIB) + IBM MQ |
| Protocolo principal | SOAP/HTTPS · JNI/Axis2 |
| Servicios ESB relevantes para BEI | `[SME-PENDING]` — identificar qué servicios ESB sirve a bdibei filtrando logs |
| Errores activos (INC-006) | 4394 · 3743 · 3701 · 3165 · 6233 (ver `06-exceptions.md §BLOQUE CRÍTICO`) |
| Frecuencia de error 4394 | 2,452/día en todo el sistema (proporción BEI `[DATO-REQUERIDO]`) |
| Impacto en batch nómina | MÁXIMO — error 4394 puede dejar lote completo sin procesar |

**Tecnología target:**
- Integraciones síncronas: REST HTTP directo (eliminando Axis2/JNI)
- Integraciones asíncronas: Amazon MSK (Kafka)
- Circuit breaker: Resilience4j
- Timeout: 5s para operaciones en línea · 30s para integraciones batch

**Acciones antes de BUILD:**
1. Obtener catálogo completo de servicios ESB que bdibei consume (análisis de DSNs + logs).
2. Por cada servicio ESB: definir equivalente en el target (REST endpoint directo, MSK topic, o legado encapsulado).
3. Implementar circuit breakers antes del primer test de integración.
4. Documentar los 5 códigos INC-006 en el runbook operativo del target.

---

## EXT-BEI-02 · Sistema SPEI — Banxico

**Criticidad:** CRÍTICA — sin SPEI, BEI solo puede dispersar a cuentas BanCoppel.

| Atributo | Valor |
|----------|-------|
| Sistema | SPEI (Sistema de Pagos Electrónicos Interbancarios) — Banxico |
| Integración actual | A través de D08-bdispei → ESB → certificación SPEI BanCoppel |
| Protocolo | Mensaje ISO 20022 (pacs.008) vía red SPEI |
| Impacto si no disponible | Dispersiones a otros bancos bloqueadas — solo se puede acreditar en cuentas BanCoppel |
| SLA Banxico | SPEI disponible 24/7/365 con ventanas de mantenimiento nocturnas |
| Regulación | Banxico Circular 14/2017 · SPEI · SPID |

**Nota de dependencia de Wave:** EXT-BEI-02 accede a SPEI a través del dominio D08-bdispei. Si D08 no está migrado o no expone API al momento del cutover de D14, las dispersiones interbancarias fallarán. Ver `07-dependencies.md §DEP-BEI-03`.

**En el target:** la integración SPEI debe mantener la certificación vigente de BanCoppel con Banxico. El microservicio `SPEIService` (D08) es el owner de esta certificación.

---

## EXT-BEI-03 · CNBV — Reportes de Operaciones Empresa

**Criticidad:** ALTA — incumplimiento implica sanciones y suspensión de servicios BEI.

| Atributo | Valor |
|----------|-------|
| Regulador | Comisión Nacional Bancaria y de Valores (CNBV) |
| Obligación | Reportar operaciones de empresa: dispersiones masivas, empresas activas, volúmenes |
| Frecuencia | Mensual · Trimestral (según el tipo de reporte) |
| Formato | `[SME-PENDING]` — formato CNBV para banca electrónica institucional |
| Canal de entrega | Portal CNBV (SITI u otros) |

**Impacto de migración:** los reportes CNBV deben seguir generándose sin interrupción durante y después del cutover. Si el batch de reportes (BATCH-BEI-05) no está funcionando en el target, el cutover debe posponerse.

---

## EXT-BEI-04 · CONDUSEF — Canal de Reclamaciones BEI

**Criticidad:** ALTA — las reclamaciones de empresas y empleados van a CONDUSEF.

| Atributo | Valor |
|----------|-------|
| Regulador | Comisión Nacional para la Protección y Defensa de los Usuarios de Servicios Financieros |
| Integración actual | `[SME-PENDING]` — portal CONDUSEF + API de reporte de reclamaciones |
| Tipos de reclamación BEI | Dispersión no acreditada · dispersión incorrecta · cobro de comisión no autorizada |
| Plazo de atención | CONDUSEF LPDUSF Art. 50 — 30 días hábiles para resolver reclamación de empresa |

**Escenario de riesgo migración:** si el cutover genera fallos de dispersión de nómina, el volumen de reclamaciones CONDUSEF puede aumentar masivamente. El canal de reclamaciones debe estar disponible y monitoreado durante las 48 horas post-cutover.

---

## EXT-BEI-05 · SAT — Validación de RFC Empresa

**Criticidad:** MEDIA — validación al alta de convenio empresa.

| Atributo | Valor |
|----------|-------|
| Sistema | SAT — servicio de validación RFC personas morales |
| Integración actual | `[SME-PENDING]` — API SAT o consulta en línea |
| Frecuencia de uso | Baja — solo al alta de convenio empresa |

**En el target:** mantener o reemplazar con llamada directa a la API de validación RFC del SAT (servicio público disponible).

---

## EXT-BEI-06 · TESOFE / SHCP — Pagos de Gobierno

**Criticidad:** `[SME-PENDING]`

| Atributo | Valor |
|----------|-------|
| Sistema | TESOFE (Tesorería de la Federación) / SHCP |
| Estado | `[SME-PENDING]` — confirmar si BanCoppel tiene convenios BEI con dependencias federales |
| Requisitos adicionales | Pagos de gobierno tienen requerimientos de comprobación fiscal adicionales (CFDI) |
| Regulación | Reglas de Tesorería · SHCP |

**Acción:** `[SME-PENDING]` sesión urgente con Domain Expert BanCoppel para confirmar si bdibei procesa pagos TESOFE. Si sí, el alcance regulatorio del dominio se amplía significativamente.

---

## EXT-BEI-07 · Banxico — Catálogo de CLABEs y Bancos SPEI

**Criticidad:** ALTA — sin catálogo actualizado, las validaciones de CLABE pueden rechazar CLABEs válidas.

| Atributo | Valor |
|----------|-------|
| Sistema | Banxico — catálogo de participantes SPEI |
| Integración actual | `[SME-PENDING]` — archivo descargable o API |
| Frecuencia de actualización | Banxico actualiza el catálogo cuando hay altas/bajas de bancos participantes |

**En el target:** el catálogo de participantes SPEI debe sincronizarse automáticamente con Banxico (job diario o evento de Banxico).

---

## EXT-BEI-08 · Sistema de Notificaciones Empresa

**Criticidad:** MEDIA — comprobantes de dispersión para la empresa cliente.

| Atributo | Valor |
|----------|-------|
| Tipo | Email / portal web empresa / SMS |
| Integración actual | `[SME-PENDING]` — integración ESB o servicio SMTP interno |
| Contenido | Confirmación de dispersión con total de registros, importes, rechazados |

---

## Tabla de errores externos observados en producción

> **Fuente:** INC-006 · `migration-risk-register.md` P655-R005 · Logs 2026-04-24

| Sistema | Código | Descripción | Frecuencia/día (sistema) | Impacto BEI |
|---------|--------|-------------|--------------------------|------------|
| ESB (IBM MQ) | `4394` | MbUserException — fallo de mensajería interna | 2,452 | MÁXIMO — batch nómina |
| ESB (SOAP) | `3743` | SOAP Handle Timed-out ~30s | 761 | ALTO — timeouts en dispersión |
| ESB (JNI/Axis2) | `3701` | JNI call error — Axis2Invoker | 356 | ALTO — integraciones legado |
| ESB (SSL/TLS) | `3165` | SSL socket error on connect | 320 | MEDIO — HTTPS externos |
| ESB (desconocido) | `6233` | Sin descripción | 264 | `[SME-PENDING]` |

---

## Matriz de impacto en cutover — Dependencias Externas

| Dependencia | ¿Bloquea cutover? | Plan de continuidad | Riesgo si no disponible |
|------------|-------------------|---------------------|-------------------------|
| ESB / IBM MQ | SÍ — hasta migrar a MSK | Circuit breaker + MSK target | Dispersiones fallidas |
| SPEI / Banxico | SÍ (vía D08) | D08 debe estar disponible antes de D14 cutover | Interbancarios bloqueados |
| CNBV reportes | Parcial (no bloquea operación pero sí compliance) | Batch reportes funcional en target antes de cutover | Incumplimiento regulatorio |
| CONDUSEF | No bloquea cutover | Canal de reclamaciones monitoreado 48h post-cutover | Reclamaciones sin atender |
| SAT RFC validation | No bloquea operación | API SAT directa en target | Altas de convenio demoradas |
| Notificaciones empresa | No bloquea cutover | Email SMTP directo en target | Experiencia empresa degradada |

---
*Generado por: Specialist — Informix SPL Analysis · 2026-08-03 · Fuente: INC-006, sp-specs-bdibei.md, migration-risk-register.md, análisis estático + modelo operativo BEI*
