# spec-spe-am-bcop-core
> Application Modernization · BanCoppel · IBM Informix IDS · SPL · Digital Core
> Offering: 03 — Software & Platform Engineering · Sub-Offering: High Velocity Modernization · Solution: Application Modernization
> Versión: 0.1.0 · Estado: DRAFT · Fase SDLC: DISCOVER — Etapa 0 · Fecha: 2026-07-02

---

## §00 — Header & Component Identity

### 00.1–00.6 Ficha del Componente

| Campo | Valor |
|---|---|
| **Component ID** | `SPE-AM-001` |
| **Nombre** | BCOPCore — Core bancario BanCoppel (Informix SPL) |
| **Tipo** | Database-as-monolith (IBM Informix IDS · SPL) → Target: Microservicios cloud-native + base de datos relacional gestionada |
| **Offering** | 03 — Software & Platform Engineering |
| **Sub-Offering** | High Velocity Modernization |
| **Solution L4** | Application Modernization |
| **Cliente** | BanCoppel, S.A., Institución de Banca Múltiple |
| **Plataforma Legacy** | IBM Informix IDS (versión: `[PENDIENTE — confirmar con DBA]`) |
| **Lenguaje legacy** | SPL — Informix Stored Procedure Language |
| **Fase SDLC Actual** | `DISCOVER` — Etapa 0 (Setup & Inventory) |
| **Owner — Lead Architect** | Por designar (Accenture MX) |
| **Owner — Sponsor Cliente** | Por designar (BanCoppel Technology) |
| **Estado** | `DRAFT` |
| **Versión Spec** | 0.1.0 |
| **Fecha creación** | 2026-07-02 |
| **Última actualización** | 2026-07-02 |

### 00.6 Changelog

| Versión | Fecha | Autor | Cambio |
|---|---|---|---|
| 0.1.0 | 2026-07-02 | alejandro.gallegos@accenture.com | Creación inicial — DISCOVER Etapa 0 kickoff |

### 00.7 Componentes Relacionados

| Componente | Relación | Dirección |
|---|---|---|
| Canales digitales BanCoppel | Invocan BCOPCore vía JDBC / ODBC directamente sobre SPs | Upstream |
| Plataforma SPEI / CoDi (Banxico) | Genera eventos de pago que BCOPCore registra y reconcilia | Upstream |
| Sistema contable / ERP BanCoppel | BCOPCore provee movimientos para contabilidad | Downstream |
| Reportería CNBV Serie R | Datos de cuentas, crédito y pagos extraídos de BCOPCore | Downstream |

### 00.8 Glosario Informix

| Término | Definición |
|---|---|
| **SPL** | Stored Procedure Language — lenguaje procedimental propietario de IBM Informix; SQL + control de flujo (FOR · WHILE · IF · RAISE EXCEPTION · FOREACH cursor) |
| **IDS** | IBM Informix Dynamic Server — motor de base de datos |
| **dbspace** | Unidad de almacenamiento físico de Informix (equivalente a tablespace Oracle) |
| **SERIAL** | Autoincremento nativo Informix (≠ SEQUENCE de otros RDBMS; su comportamiento en rollback difiere) |
| **DATETIME** | Tipo de fecha-hora Informix con precisión granular: `DATETIME YEAR TO SECOND`, `DATETIME YEAR TO FRACTION(5)` |
| **INTERVAL** | Tipo de intervalo temporal Informix: `INTERVAL HOUR TO SECOND`, etc. No tiene equivalente directo en PostgreSQL |
| **MONEY** | Tipo decimal para valores monetarios en Informix (precisión y rounding propietarios) |
| **LVARCHAR** | VARCHAR de longitud variable hasta 32,739 bytes (Informix) |
| **PDQ** | Parallel Database Query — feature de queries paralelas en SPs batch |
| **onstat** | Herramienta CLI de administración Informix (métricas de instancia, sesiones, locks) |
| **sysmaster** | Base de datos del sistema Informix: metadatos, sesiones activas, estadísticas de tablas |
| **sysprocedures** | Tabla del catálogo Informix que registra todos los SPs / funciones existentes |
| **SQLCA** | SQL Communication Area — estructura de manejo de errores SPL (`SQLCODE`, `SQLERRM`) |
| **dbslice** | Particionamiento físico de Informix para tablas grandes |

---

## §01 — Legacy Origen (Sistema Fuente)

### 01.1 Descripción del Sistema Legacy

**BCOPCore** es el core bancario de BanCoppel, S.A., Institución de Banca Múltiple, implementado como **lógica de negocio embebida en IBM Informix Dynamic Server mediante Stored Procedure Language (SPL)**. Opera bajo el patrón **"base de datos como aplicación"**: no existe una capa de aplicación separada con lógica de negocio. Toda la funcionalidad operacional — apertura de cuentas, dispersión de crédito, cálculo de intereses y comisiones, reconciliación de saldos, reportería CNBV — vive íntegramente dentro del motor Informix como procedimientos almacenados.

Los canales (banca en línea, cajeros automáticos, sucursales, sistemas internos) invocan los SPs directamente via JDBC o ODBC, pasando parámetros y recibiendo resultados. El sistema atiende operaciones OLTP en tiempo real y también ejecuta carga batch nocturna (cierre de jornada, dispersión de nómina, domiciliaciones, cálculo de intereses).

Este caso es distinto a Mainframe Modernization (Banamex S500/S151) en plataforma y lenguaje, pero comparte el mismo nivel de criticidad financiera y exposición regulatoria CNBV, por lo que se aplican los umbrales de equivalencia y parallel-run del nivel MM.

### 01.2 Contexto Técnico Legacy

| Parámetro | Valor | Notas |
|---|---|---|
| Plataforma | IBM Informix IDS | Versión: `[PENDIENTE — DBA confirmar]` · Típico: 12.10 o 14.x |
| Sistema operativo host | `[PENDIENTE]` | Típico: RHEL, AIX, o Solaris |
| Lenguaje de lógica | SPL (Stored Procedure Language) | Propietario Informix; compile-on-create, no archivos separados en sistema de archivos |
| Lenguaje de datos | SQL Informix dialect | Tipos propietarios: DATETIME · INTERVAL · SERIAL · MONEY · LVARCHAR · BYTE · TEXT |
| Objetos de lógica | SPs · Funciones · Triggers · Vistas activas | `[PENDIENTE — Etapa 0: inventario via sysprocedures / systriggers]` |
| Esquema de datos | Tablas · índices · constraints · secuencias (SERIAL) | `[PENDIENTE — Etapa 0: DDL extraction via systables / syscolumns]` |
| Mecanismo batch | `[PENDIENTE]` | Típico: cron Linux + script shell que llama SPs vía `dbaccess` o JDBC |
| Modos operacionales | OLTP (tiempo real) + Batch nocturno | Confirmar horario de ventana batch con SME BanCoppel |
| LOC total | `[PENDIENTE — Etapa 1]` | Requiere extracción del catálogo + volcado de código fuente |
| Volumen transaccional | `[PENDIENTE — logs onstat / sysmaster]` | TPS peak, TPS promedio, volumen batch nocturno |
| Ventana batch | `[PENDIENTE]` | Duración del cierre nocturno (máximo admisible para el nuevo sistema) |

### 01.3 Criticidad Regulatoria

| Aspecto | Detalle |
|---|---|
| Regulación principal | CNBV — Circular Única de Bancos (CUB) · Disposiciones de crédito y captación |
| Reporte regulatorio | Operaciones de crédito (crédito personal, nómina) y captación en estados financieros CNBV |
| Reconciliación | Cuadre diario de saldos obligatorio · sin cuadre el banco no puede cerrar jornada |
| CONDUSEF | Comisiones, cargos y reclamaciones — catálogo de comisiones registrado · Art. 61 cuentas abandonadas |
| SPEI / CoDi | Pagos interbancarios regulados por Banxico (SPEI: liquidación en < 30 segundos) |
| ISR / SAT | Retenciones fiscales aplicadas sobre intereses y movimientos bancarios |
| Retención de evidencia | 10 años mínimo por CNBV Art. 58 Bis |
| Impacto de falla | **Sistémico** — falla en BCOPCore paraliza todas las operaciones de BanCoppel |
| Contexto adicional | BanCoppel sirve principalmente a clientes Coppel (retail + nómina) — perfil SOFOM / banca popular |

### 01.4 Driver de Modernización

| Driver | Descripción | Peso |
|---|---|---|
| **Licenciamiento IBM Informix** | Costo de IDS creciendo; IBM reduce innovación en Informix; no hay managed service cloud | Alto |
| **Imposibilidad cloud-native** | Informix IDS no tiene offering gestionado en AWS, GCP ni Azure; bloquea estrategia cloud BanCoppel | Alto |
| **Skills escasos** | SPL es lenguaje propietario con pool de talento en contracción acelerada; riesgo de key-man | Alto |
| **Velocidad de cambio** | Modificar SPs requiere DBA especializado + testing regresivo manual; ciclos de feature > semanas | Alto |
| **Observabilidad nula** | Informix no se integra nativamente con OpenTelemetry / Datadog / Dynatrace; solo onstat | Medio |
| **Deuda técnica** | `[PENDIENTE — Etapa 1: SPs > 500 LOC, SPs sin tests, triggers ocultos, cursors anidados]` | Por confirmar |

---

## §02 — Scope de la Modernización

### 02.1 Capacidades en Scope (hipótesis — confirmar Etapa 2–4)

| ID | Capacidad Funcional Estimada | MoSCoW | Fuente de evidencia |
|---|---|---|---|
| CAP-BCOP-001 | Apertura y administración de cuentas (corriente · ahorro · nómina) | Must | Negocio core BanCoppel |
| CAP-BCOP-002 | Originación y seguimiento de crédito personal / nómina | Must | Producto principal Coppel |
| CAP-BCOP-003 | Registro de cargos / abonos (OLTP) | Must | Operación bancaria core |
| CAP-BCOP-004 | Cálculo de intereses y comisiones (CONDUSEF) | Must | Regulatorio |
| CAP-BCOP-005 | Cierre de jornada y reconciliación diaria | Must | Regulatorio CNBV |
| CAP-BCOP-006 | SPEI / CoDi — pagos interbancarios | Must | Regulatorio Banxico |
| CAP-BCOP-007 | Domiciliaciones y cobros recurrentes | Should | Batch nocturno |
| CAP-BCOP-008 | Dispersión masiva de nómina Coppel | Should | Producto nómina |
| CAP-BCOP-009 | Reportería regulatoria CNBV Serie R | Should | Regulatorio |
| CAP-BCOP-010 | Alertas, bloqueos y cuentas abandonadas (CONDUSEF Art. 61) | Could | Regulatorio |

### 02.2 Out of Scope (hipótesis — confirmar con BanCoppel)

- Canales / frontend (banca en línea, app móvil, ATM software) — engagement separado si aplica
- CRM BanCoppel
- Sistemas de la tienda Coppel (retail) — entidades legales separadas

### 02.3 Hipótesis de Estrategia 7R

**`[PENDIENTE ADR-SPE-AM-001 — Etapa 4]`** — hipótesis de trabajo:

| Fase | Patrón | Descripción | Duración est. | Riesgo |
|---|---|---|---|---|
| **A — Encapsulate** | Anti-Corruption Layer + API REST sobre Informix | API facade: canales dejan de llamar SPs directamente · Informix no se modifica · habilita Strangler-Fig en Fase B | 2–4 meses | Bajo |
| **B — Refactor + Replatform** | Strangler-Fig SP por SP | Extracción de SPs → Java 21 + Quarkus · Migración Informix → PostgreSQL / Aurora · Parallel-run por dominio funcional | 12–24 meses | Alto |

**Riesgo crítico de Fase B — aritmética financiera:**
El tipo `MONEY` y `DECIMAL(p,s)` de Informix aplica rounding y precisión con semántica propia. La conversión a `BigDecimal` de Java requiere un plan de equivalencia financiera explícito (equivalente al riesgo COMP-3 → BigDecimal de Banamex S151). Una divergencia de un centavo en cálculo de intereses o comisiones es un error auditable CNBV.

---

## §03 — Estado DISCOVER

### 03.1 Checklist Etapa 0 — Setup & Inventory

| Item | Descripción | Estado |
|---|---|---|
| 0.1 | Código fuente SPL disponible — cargado en `source/BCOPCore/` | ☐ Pendiente carga |
| 0.2 | Inventario de objetos: `SELECT procname, procid FROM sysprocedures` + triggers | ☐ |
| 0.3 | Extracción de DDL completo (tablas · tipos · índices · constraints) | ☐ |
| 0.4 | Logs onstat / sysmaster ≥ 30 días producción | ☐ |
| 0.5 | SME técnico BanCoppel asignado (DBA + dominio bancario) | ☐ |
| 0.6 | Versión IBM Informix IDS + OS + hardware confirmados | ☐ |
| 0.7 | Diagrama de capas: qué sistemas llaman a qué SPs (canales · batch · integraciones) | ☐ |
| 0.8 | Autorización extracción datos anonimizados producción (dataset regresión) | ☐ |
| 0.9 | Ambiente de análisis provisionado | ☐ |

### 03.2 Adaptación Metodología RE (ETAPAs 0–4) para Informix SPL

La metodología del Specialist - Reverse Engineering (ETAPAs 0–4) se adapta para objetos SQL/SPL. En Informix, el "código fuente" de los SPs puede obtenerse del catálogo (`sysprocbody`) o de scripts `.sql` de creación:

| Etapa | Actividad en Informix SPL | Artefacto de salida |
|---|---|---|
| **Etapa 0** — Setup & Inventory | Catálogo via `sysprocedures`, `systables`, `systriggers`, `syscolumns` · LOC de cada SP via `sysprocbody` | Inventario maestro de objetos SPL |
| **Etapa 1** — Static Analysis | Call graph SP→SP (`EXECUTE PROCEDURE` en cuerpo) · SP→tabla (DML en cuerpo) · Trigger→SP · Índice vs. query patterns | Call graph · Dependency matrix · Hotspots de complejidad |
| **Etapa 2** — Data RE | ERD desde DDL · Tipos Informix → tipos estándar · Constraints e índices · Volúmenes desde `sysmaster:systabnames` | Data Dictionary · ERD lógico · Mapa de tipos |
| **Etapa 3** — Business Logic | Reglas embebidas en SPs: validaciones, cálculos de interés/comisión, flujos de control (IF/WHILE/FOR/FOREACH) · Manejo de excepciones (ON EXCEPTION) | Catálogo de reglas de negocio · Especificaciones funcionales |
| **Etapa 4** — Domain Decomp. | Agrupar SPs + tablas en dominios (Crédito · Captación · Pagos · Comisiones · Batch · Reportería) por cohesión de acceso a datos | Bounded contexts · Wave map |

### 03.3 Señales de Deuda Técnica Específicas a SPL

| Señal | Descripción | Severidad |
|---|---|---|
| SPs con > 500 LOC | Lógica monolítica dentro del SP — alta complejidad de extracción | Alta |
| SPs con acceso a > 10 tablas | Mega-acoplamiento de datos (equivalente a DT-002 de Banamex S500/P010) | Alta |
| Triggers que llaman SPs | Acoplamiento oculto — difícil de detectar por análisis estático superficial | Alta |
| CURSOR anidados en loops FOR | Lógica batch embebida en contexto OLTP — antipatrón de extracción | Media |
| MONEY / DECIMAL con rounding implícito | Riesgo de equivalencia financiera en conversión a BigDecimal Java | **Crítica** |
| SPs sin comentarios ni documentación | Sin contexto de negocio para el análisis RE — requiere HITL con SME bancario | Media |
| Uso de `EXECUTE IMMEDIATE` (SQL dinámico) | Lógica no analizable estáticamente — requiere análisis de runtime | Alta |

### 03.4 Criterios de Salida DISCOVER (gate para iniciar DESIGN)

- [ ] Inventario completo de objetos SPL con LOC y complejidad estimada
- [ ] Call graph de dependencias SP→SP y SP→tabla documentado
- [ ] ERD lógico de tablas principales (mínimo entidades de crédito, cuenta, movimiento, cliente)
- [ ] Catálogo de SPs agrupados en ≥ 5 dominios funcionales propuestos
- [ ] Mapa regulatorio: qué SPs procesan operaciones CNBV / CONDUSEF / Banxico
- [ ] Catálogo inicial de tipos Informix propietarios con impacto en equivalencia financiera
- [ ] Hipótesis 7R por dominio funcional documentada
- [ ] Wave map v1 (secuencia de extracción de capabilities propuesta)
- [ ] Decisión de equivalencia mínima acordada con BanCoppel (recomendado ≥ 99.99% por banca CNBV)

---

## §04 — DoR y DoD del Componente

### 04.1 DoR — Definition of Ready

Hereda DoR de Application Modernization L4 + específicos BanCoppel:
- [ ] Código fuente SPL disponible en `source/BCOPCore/`
- [ ] Versión IBM Informix IDS confirmada
- [ ] SME técnico BanCoppel asignado (DBA + negocio bancario)
- [ ] Acceso de lectura a `sysmaster` para métricas de ejecución
- [ ] Autorización para extracción y anonimización de datos de producción (dataset regresión 6 meses)
- [ ] Decisión Etapa 4: dominio piloto de extracción identificado (wave 1)

### 04.2 DoD — Definition of Done

Hereda DoD-SPE-AM-01..05 + DoD-SPE-01..08 + específicos del componente:

- [ ] **DoD-BCOP-01**: Equivalencia financiera ≥ 99.99% — aritmética MONEY/DECIMAL Informix vs. BigDecimal Java verificada sobre dataset de regresión ≥ 6 meses de producción (umbral MM aplicado por ser banca CNBV, más estricto que DoD-SPE-AM-01 de 99.95%)
- [ ] **DoD-BCOP-02**: Tablas Informix migradas a PostgreSQL / Aurora con integridad referencial completa (0 registros huérfanos) y tipos propietarios correctamente convertidos
- [ ] **DoD-BCOP-03**: Parallel-run ≥ 3 meses — umbral MM por criticidad core bancario (más estricto que DoD-SPE-AM-02 de 2 sprints)
- [ ] **DoD-BCOP-04**: Rollback al Informix legacy probado en STG incluyendo sync reverso de datos
- [ ] **DoD-BCOP-05**: Auditoría interna BanCoppel + notificación CNBV si el cambio afecta procesamiento de transacciones sujetas a aviso
- [ ] **DoD-BCOP-06**: Tipos propietarios Informix (DATETIME · INTERVAL · SERIAL · MONEY) tratados según `ADR-SPE-AM-005` — sin pérdida de precisión ni semántica

---

## §05 — SLOs del Componente

| SLO ID | Descripción | Baseline legacy | Target nuevo |
|---|---|---|---|
| SLO-BCOP-01 | Latencia P95 transacción OLTP | `[PENDIENTE — onstat]` | ≤ baseline legacy |
| SLO-BCOP-02 | Throughput (TPS pico) | `[PENDIENTE]` | ≥ baseline legacy |
| SLO-BCOP-03 | Disponibilidad mensual | `[PENDIENTE]` | ≥ 99.95% |
| SLO-BCOP-04 | Duración ventana batch nocturna | `[PENDIENTE]` | ≤ baseline legacy |
| SLO-BCOP-05 | Equivalencia drift en parallel-run | N/A (solo legacy) | < 0.01% (umbral MM por ser banca CNBV) |

---

## §06 — ADRs Pendientes

| ADR | Descripción | Gate |
|---|---|---|
| `ADR-SPE-AM-001` | Decisión 7R por dominio funcional (Refactor + Replatform vs. Retain para casos edge) | Etapa 4 |
| `ADR-SPE-AM-002` | Patrón de coexistencia: ACL sobre Informix → Strangler-Fig SP por SP | DESIGN |
| `ADR-SPE-AM-003` | Data migration: Informix → PostgreSQL / Aurora (CDC · dual-write · bulk + delta) | DESIGN |
| `ADR-SPE-AM-004` | Target runtime por dominio (Kubernetes GKE/EKS · Cloud Run · Lambda para batch) | DESIGN |
| `ADR-SPE-AM-005` | Tratamiento de tipos propietarios Informix en DDL target y código Java (DATETIME · INTERVAL · SERIAL · MONEY) | Etapa 3 — antes de BUILD |
| `ADR-SPE-AM-006` | Equivalencia financiera: MONEY / DECIMAL Informix vs. BigDecimal Java — casos de borde en rounding e interés compuesto | Etapa 3 |

---

## §07 — Dependencias Cross-Offering

| Dependencia | Razón | Trigger |
|---|---|---|
| `[BLOCKED-BY: 01 TS&T]` | Target architecture (runtime · data platform · ACL design) requiere endorsement TS&T antes de DESIGN | Inicio de DESIGN |
| `[DEPENDS-ON: 04 Intelligent Infrastructure]` | LZ + cluster + observability obligatorio antes de RELEASE de Fase A | Pre-RELEASE Fase A |
| `[DEPENDS-ON: 05 Modern Data Platform]` | Data migration Informix → PostgreSQL no trivial: tipos propietarios · CDC bidireccional · sync reverso para rollback | Pre-BUILD Fase B |
| `[HANDOFF: 07 AMS Reinvention]` | Modelo AMS doble (Informix + nuevo) durante ventana de coexistencia ≥ 12 meses | Pre-RELEASE Fase A |

---

*Última actualización: 2026-07-02 · v0.1.0 · Creación inicial — DISCOVER Etapa 0 kickoff.*