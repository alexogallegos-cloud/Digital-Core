# D14 · Banca Electrónica Institucional (BEI) — Catálogo de Procesos de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional BEI — pagos masivos, dispersiones)
- Industry Banking (banca electrónica institucional, pagos empresariales)
- Core Banking Transformation (arquitectura target, ACL design, API contracts)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Cybersecurity (PII, CNBV, LFPDPPP)
- SRE & AIOps (observabilidad, runbooks, cutover)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---

## Rol del dominio

`bdibei` · Wave 3 · Riesgo CRÍTICO. 336 SPs totales; 42 en callgraph · 294 aislados. Dominio central de Banca Electrónica Institucional: gobierna el ciclo completo de pagos masivos y dispersiones institucionales que BanCoppel ofrece a sus clientes empresa. Su criticidad máxima deriva del **batch de nómina**: si falla durante migración, miles de empleados de empresas clientes de BanCoppel no reciben su pago.

La alta proporción de SPs aislados (294 / 336 = 87.5%) indica que la mayor parte de la funcionalidad BEI no fue cubierta por los logs de producción del 2026-04-24. Esto representa un riesgo de conocimiento que debe resolverse en Etapa 2 antes de BUILD.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D14-01 | Alta y mantenimiento de convenio empresa | `[SME-PENDING]` | Orquestador | CNBV |
| BP-D14-02 | Carga de archivo de nómina masiva (layout BEI) | `[SME-PENDING]` | Batch crítico | CNBV · IMSS |
| BP-D14-03 | Dispersión de nómina — acreditación en cuentas beneficiarios | `[SME-PENDING]` | Batch crítico | CNBV · CONDUSEF |
| BP-D14-04 | Dispersión masiva de pagos (proveedores, servicios empresa) | `[SME-PENDING]` | Batch | CNBV |
| BP-D14-05 | Pre-autorización de pagos programados | `[SME-PENDING]` | Orquestador | CNBV |
| BP-D14-06 | Alta y administración de beneficiarios múltiples | `[SME-PENDING]` | Orquestador | CNBV · LFPDPPP |
| BP-D14-07 | Consulta de estado de dispersión y saldo empresa | `[SME-PENDING]` | Servicio expuesto | |
| BP-D14-08 | Reverso de dispersión / pago fallido | `[SME-PENDING]` | Orquestador | CNBV · CONDUSEF |
| BP-D14-09 | Liquidación vía SPEI de pagos masivos | `[SME-PENDING]` | Delegado a D08 | Banxico |
| BP-D14-10 | Generación de reportes BEI (nómina, dispersiones, comisiones) | `[SME-PENDING]` | Batch / Servicio | CNBV |
| BP-D14-11 | Autenticación y autorización empresa (token BEI) | `[SME-PENDING]` | Servicio expuesto | CNBV |
| BP-D14-12 | Cálculo de comisiones por dispersión | `[SME-PENDING]` | Orquestador | CONDUSEF · SAT |
| BP-D14-13 | Bloqueo / desbloqueo de convenio empresa | `desbloque` (aislado) | Servicio expuesto | CNBV |
| BP-D14-14 | Generación de código aleatorio (autenticación OTP) | `getrandomcode` (aislado) | Servicio expuesto | |

> **Nota crítica sobre BP-D14-02 y BP-D14-03 (batch nómina):** estos dos procesos son los de mayor criticidad en todo el dominio BEI y en la Wave 3. La ventana de migración **no puede coincidir con ciclo quincenal activo** (días 1–3 y 15–18 de cada mes). Ver `20-cutover-plan.md` para restricciones formales.

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`

- [ ] Nombre de negocio oficial de cada proceso (terminología interna BanCoppel BEI).
- [ ] SP entry point real de cada proceso (requiere análisis de los 294 SPs aislados en Etapa 2).
- [ ] Frecuencia y criticidad operativa por proceso (ciclos: diario, quincenal, mensual).
- [ ] Volumen de empresas clientes activas en BEI (contexto: BanCoppel es 3ª red bancaria MX).
- [ ] Confirmar si TESOFE es un cliente BEI activo (pagos de gobierno).
- [ ] Confirmar número aproximado de empleados beneficiarios de la nómina BEI.

## Mapa de criticidad por proceso

| Proceso | Criticidad | Ventana permitida para cutover | Impacto si falla |
|---------|-----------|-------------------------------|-----------------|
| Batch nómina (BP-D14-02/03) | CRÍTICA | Fuera de quincena activa | Empleados sin pago — reclamaciones CONDUSEF masivas |
| Dispersión masiva proveedores (BP-D14-04) | ALTA | Fuera de cierres contables | Proveedores empresa sin pago |
| Liquidación SPEI (BP-D14-09) | ALTA | Coordinar con D08-bdispei | Pagos interbancarios sin liquidar |
| Alta convenio empresa (BP-D14-01) | MEDIA | Cualquier ventana nocturna | Solo impacta incorporación nueva |
| Reportes BEI (BP-D14-10) | MEDIA | Ventana nocturna | Reportes regulatorios demorados |
| Consultas (BP-D14-07) | BAJA | Cualquier ventana | Experiencia digital empresa degradada |

---
*Generado por: DT-Riesgos + Specialist — Informix SPL Analysis · 2026-08-03 · Fuente: 21-observability-runbook.md + sp-specs-bdibei.md (grounding pass) + contexto INC-006*
