# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Catálogo de Procesos de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel / Área de Cumplimiento (validación funcional y regulatoria)
- SME — Industry Banking (`SME/Industry/Industry Banking/`)
- SME — DBA IBM Informix (`SME/Technology/DBA IBM Informix/`)
- SME — Core Banking Transformation (`SME/Technology/Core Banking Transformation/`)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`) — obligatorio para PLD
- **SME Regulatorio — SAT** (`SME/Regulatory/SAT/`) — IDE y reportes SAT
- Cybersecurity (`SME/Technology/Cybersecurity/`) — PII + datos regulatorios
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado antes de BUILD.
> `[COMPLIANCE-SIGN-OFF-REQUIRED]` = requiere sign-off explícito del Área de Cumplimiento de BanCoppel además del CAB estándar.

---

## Rol del dominio

`bdilide` · Wave 4 · Riesgo CRÍTICO. 101 SPs; 5 en callgraph, 96 aislados. Dominio de mayor carga regulatoria en BCOPCore: gestiona la Lista de Instancias de Deudores Especiales (LIDE) y el motor de Prevención de Lavado de Dinero (PLD) de BanCoppel. Interactúa con CNBV, SHCP y SAT mediante reportes regulatorios formales. Cualquier degradación funcional post-migración tiene implicaciones de cumplimiento normativo directas.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP representativo | Tipo | Reg |
|----|--------------------|-------------------|------|:---:|
| BP-D15-01 | Acumulación diaria de operaciones para PLD | `sp_acumulacionoperaciones` | Batch/Orquestador | CNBV/SHCP |
| BP-D15-02 | Consulta e integración al Buró de Crédito | `borramovs_movefechis` | Servicio | CNBV |
| BP-D15-03 | Carga de informe SAT (consulta CURP/RFC) | `sp_cargainformesat` | Batch | SAT |
| BP-D15-04 | Carga de resultado SAT | `sp_cargaresultadosat` | Batch | SAT |
| BP-D15-05 | Actualización de informe SAT por RFC | `sp_actualizainformesat` | Mantenimiento | SAT |
| BP-D15-06 | Actualización de resultado SAT por RFC | `sp_actualizaresultadosat` | Mantenimiento | SAT |
| BP-D15-07 | Actualización de RFC en LIDE | `sp_actualizarfclide` | Mantenimiento | SAT/CNBV |
| BP-D15-08 | Actualización de código y fecha de envío | `sp_actualizacodfechaenvio` | Control | CNBV/SHCP |
| BP-D15-09 | Actualización de parámetros de transferencia | `sp_actparamtraspmovefec` | Control | PLD |
| BP-D15-10 | Verificación de CURP en lista LIDE | `sp_checacurp` | Consulta | CNBV |
| BP-D15-11 | Ejecutor diario de procesos PLD | `ejecutor_diario` | Orquestador batch | CNBV/SHCP |
| BP-D15-12 | Generación de archivos de reporte SAT | `sp_cargainformesat` / `sp_cargaresultadosat` | Batch regulatorio | SAT |
| BP-D15-13 | Gestión de lista de exentos (PLD/SAT) | `sp_actualizainformesat` → `sl_exentos` | Mantenimiento | SAT |

> Nota: los 96 SPs aislados del callgraph contienen lógica PLD que no fue capturada en los journeys principales. Se requiere análisis adicional de cada SP por el Área de Cumplimiento antes de BUILD. Ver `sp-specs-bdilide.md` para el inventario completo.

## `[SME-PENDING]`

- [ ] Nombre oficial de cada proceso en la nomenclatura de Cumplimiento de BanCoppel.
- [ ] Frecuencia y criticidad operativa de cada proceso batch (diario, mensual, bajo demanda).
- [ ] Confirmar cuáles procesos son obligatorios por Circular CNBV y cuáles son controles internos.
- [ ] Validar si el `ejecutor_diario` tiene un proceso equivalente en el target o se migra como Lambda scheduled.
- [ ] Identificar los 96 SPs aislados que corresponden a reportes regulatorios formales vs. utilidades internas.

## `[COMPLIANCE-SIGN-OFF-REQUIRED]`

- [ ] El Área de Cumplimiento de BanCoppel debe validar que todos los procesos regulatorios del catálogo estén identificados antes de que el equipo de BUILD inicie la implementación del target.

---
*Generado: análisis estático bdilide + sp-specs-bdilide.md · 2026-08-03*
