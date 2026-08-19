# DT-Riesgos — RAID Log Unity R4

> **Tipo:** Digital Twin — Programa Unity  
> **Versión:** v2.0.0  
> **Estado:** `[STATE: ACTIVE]`  
> **Fuente autoritativa:** `RAID_Log_Programa_Unity_R4_v2.0.xlsx` — 03/08/2026 — Responsable: Ma. Fernanda Barbosa  
> **Fuente complementaria:** Minutas R4 (17 documentos, sesiones previas al 03/08)  
> **Última actualización:** 2026-08-15

---

## Resumen Ejecutivo

| Dimensión | Total | Alta/Severa | Abiertos |
|-----------|-------|-------------|---------|
| Risks (R) | 18 | 9 alta | 17 (1 cerrado) |
| Assumptions (H) | 4 | 3 alta | 4 (0 validados) |
| Issues (I) | 3 | 3 alta | 3 |
| Dependencies (D) | 2 | 2 severas | 2 |
| **TOTAL RAID** | **27** | **17 críticos/altos/severos** | **26** |

**Propietario de concentración de riesgo:** Armando García (PM SmartVista) — owner en R02, R10, R11, R13, R16, D01. Punto único de gestión de riesgo en el track más crítico.

**Hallazgo estructural:** La escala de severidad del RAID no registra ningún ítem en categoría "Crítica" formal — pero I02, D02 e I03 tienen impacto sistémico que bloquea todos los streams si no se resuelven. El log subestima la criticidad en la categoría de Issues.

---

## Top 10 — Ítems de Mayor Impacto Sistémico

| Prioridad | ID | Descripción corta | Dimensión | Estado |
|-----------|-----|-------------------|-----------|--------|
| 1 | I02 | Único entorno para SIT/UAT/NFT/Seguridad — colisión inevitable | Issue | Abierto, sin fecha |
| 2 | D02 | Infra BCPL debe estabilizar entorno antes de que cualquier stream inicie SIT | Dependency | Activa, sin fecha |
| 3 | I03 | Célula Apolo App sin contratar desde mayo 2026 | Issue | Abierto, sin fecha |
| 4 | I01 | CAT sin equipo — construcción iniciaría oct, freeze en dic | Issue | Abierto |
| 5 | R01 | 54% User Stories Appware sin delta técnico — bloquea SmartVista + SIWEB + CAT | Risk | Abierto (gate 10/ago vencido) |
| 6 | R09 | ATLAS Fase 2/Golden Record sin confirmar — puede bloquear migración TDC | Risk | Abierto, sin fecha |
| 7 | R10 | 4 despliegues en Q4 con capacidad limitada — riesgo de desestabilización go-live | Risk | Abierto, sin fecha |
| 8 | R18 | Ambiente IBR bloqueado — arquitectura rechazó servidor CAT | Risk | Abierto, sin fecha |
| 9 | R15 | Ambientes DEV/TEST SmartVista sin infraestructura para SVFM (88 reglas autorizador) | Risk | Abierto (gate 03/ago vencido) |
| 10 | D01 | Normatividad Contable sin entregar guía diferimientos — User Stories R418-R420 bloqueadas | Dependency | Activa (vencida 24/jul) |

---

## Risks (R01–R18)

### Alta Severidad — Abiertos

#### R01 — Retraso en DTMs Appware bloquea construcción SmartVista + SIWEB + CAT
| Campo | Valor |
|-------|-------|
| **Severidad** | Alta |
| **Categoría** | Capacidad |
| **Componente** | SmartVista / SIWEB / CAT |
| **Owner** | Program Lead / Ma. Fernanda Barbosa; Appware Alfredo Aguilar |
| **Due date** | 10/08/2026 — **VENCIDO** |
| **Fuente** | Weekly |

El 54% de las User Stories de Appware requiere mayor exploración técnica para determinar el alcance de diseño de los DTMs. Mientras el delta técnico no esté cerrado, SmartVista, SIWEB y CAT no pueden iniciar implementación. Gate formal fijado en 10 agosto — ya vencido.

**Mitigación:** Mesas de trabajo para cerrar delta técnico. Alfredo Aguilar define fechas DTMs. Gate formal como bloqueo en plan maestro.

---

#### R02 — Módulos SmartVista no contemplados: Inventario de Tarjetas + Campañas MSI/MCI
| Campo | Valor |
|-------|-------|
| **Severidad** | Alta |
| **Categoría** | Planning |
| **Componente** | SmartVista |
| **Owner** | PM SmartVista / Armando García |
| **Due date** | 30/07/2026 — **VENCIDO** |
| **Fuente** | Weekly |

Surgieron en mesas de entendimiento sin estar en el plan original. Requieren desarrollo a medida con BPC. Impactan alcance, costo y cronograma de SmartVista R4.

**Mitigación:** Demo con BPC para dimensionar alcance y costo. Plan de trabajo específico.

---

#### R04 — Fragmentación de capa APIs: sin estándar único, latencia supera 10 seg en App
| Campo | Valor |
|-------|-------|
| **Severidad** | Alta |
| **Categoría** | Arquitectura |
| **Componente** | Apificación (transversal) |
| **Owner** | Arquitectura BCPL |
| **Due date** | TBD |
| **Fuente** | Entrevista SmartVista |

La capa intermedia se construyó sin estándar de servicio único por función. Cualquier cambio regulatorio o de negocio requiere modificar múltiples APIs por canal en paralelo, generando riesgo de regresión y latencia acumulada ya observada > 10 seg en App.

**Mitigación:** Mapear procesos core R4 afectados y cuantificar esfuerzo adicional de modificación.

---

#### R05 — Latencia Apolo persiste en PROD — mejoras de Apificación no confirmadas
| Campo | Valor |
|-------|-------|
| **Severidad** | Alta |
| **Categoría** | Performance |
| **Componente** | APOLO |
| **Owner** | API / Edgar Mejía; Arquitectura / Edgar Mejía |
| **Due date** | 08/08/2026 — **VENCIDO** |
| **Fuente** | Due Diligence |

Las mejoras aplicadas por Apificación no han sido confirmadas como desplegadas en PROD con mediciones reales. La latencia documentada (9 seg PROD, 30 seg QA) compromete la experiencia de onboarding y puede bloquear la salida a mercado abierto.

**Mitigación:** Oscar Melo confirma mejoras en PROD con métricas reales. Edgar Mejía revisa orquestación en WebMethods y diagnostica cuello de botella GCP/AWS → Informix.

---

#### R09 — ATLAS Fase 2 / Golden Record sin confirmar alcance — bloquea migración TDC
| Campo | Valor |
|-------|-------|
| **Severidad** | Alta |
| **Categoría** | Planning |
| **Componente** | SmartVista |
| **Owner** | Leader Programa ATLAS BCPL |
| **Due date** | TBD |
| **Fuente** | Due Diligence |

Si ATLAS Fase 2 (MDM/Golden Record) no confirma alcance, fecha y criterios de disponibilidad antes del hito requerido por R4, la migración de TDC a SmartVista no puede iniciar o completarse. No existe fecha objetivo definida.

**Mitigación:** Documentar decisión ATLAS-SmartVista: alcance, interfaces y plan de pruebas.

---

#### R10 — 4 despliegues por canal en Q4 con capacidad limitada — riesgo de desestabilización go-live
| Campo | Valor |
|-------|-------|
| **Severidad** | Alta |
| **Categoría** | Despliegue |
| **Componente** | Transversal |
| **Owner** | PM SmartVista / Armando García |
| **Due date** | TBD |
| **Fuente** | Due Diligence |

El escenario actual concentra 4 despliegues por canal en Q4-2026 con capacidad limitada y pruebas paralelas. Alta probabilidad de que R4 se desestabilice durante el período de despliegue, comprometiendo el go-live de Dic'26.

**Mitigación:** Evaluar escenarios alternativos de despliegue. Si se mantiene el escenario actual, reforzar regresión automatizada y capacidad vendor.

---

#### R12 — Retraso en diseños CX/Figma bloquea desarrollo Bloque 2 App
| Campo | Valor |
|-------|-------|
| **Severidad** | Alta |
| **Categoría** | Capacidad |
| **Componente** | APP |
| **Owner** | CX / Benjamín Herrera |
| **Due date** | 29/07/2026 — **VENCIDO** |
| **Fuente** | Entrevista App |

CX lleva desde septiembre 2025 sin cerrar el alcance completo de diseños. La segunda entrega de Figma estaba comprometida para el 29 de julio. Sin diseños, el desarrollo del Bloque 2 de App no puede iniciar.

---

#### R15 — Ambientes DEV/TEST SmartVista sin infraestructura para SVFM
| Campo | Valor |
|-------|-------|
| **Severidad** | Alta |
| **Categoría** | Entornos |
| **Componente** | SmartVista |
| **Owner** | Infra BCPL / Miguel Castillo |
| **Due date** | 03/08/2026 — **VENCIDO** |
| **Fuente** | Matriz RAID |

SVFM es el componente del autorizador de SmartVista que valida las 88 reglas ISO 8583 con eGlobal. Sin infraestructura adecuada en DEV/TEST, el ciclo de pruebas SmartVista no puede arrancar formalmente. Tickets de escalamiento #13830642 y #13830651 pendientes de aprobación de Miguel Castillo.

---

#### R18 — Habilitación de ambientes CAT bloqueada — IBR rechazado por arquitectura
| Campo | Valor |
|-------|-------|
| **Severidad** | Alta |
| **Categoría** | Entornos |
| **Componente** | CAT |
| **Owner** | CAT Ramsés Santos |
| **Due date** | TBD |
| **Fuente** | Entrevista CAT |

Arquitectura rechazó habilitar el servidor IBR por no cumplir requisito de nube. El proceso involucra múltiples áreas con SLAs independientes que pueden acumular retrasos. Sin ambiente IBR, el canal CAT no puede ejecutar pruebas.

**Mitigación:** Escalar a nivel con autoridad sobre infraestructura y arquitectura. Definir owner único del proceso con fecha límite.

---

### Media Severidad — Abiertos

| ID | Descripción | Owner | Due date |
|----|-------------|-------|----------|
| R06 | Plan de trabajo Cobranza sin formalizar | Program Lead / Ma. Fernanda Barbosa | 30/07 vencido |
| R07 | QA sin calendario integrado entre canales — colisión sep-nov | Testing R4 | 26/07 vencido |
| R08 | Entregables Contabilidad (guía contable + reportes regulatorios + matriz de casos) con retraso | Contabilidad / J.A. Valverde, G. Martínez, S. Melo | 26/07 vencido |
| R11 | Guía contable diferimientos incompleta — User Stories R418-R420 sin criterios de aceptación | SmartVista / Armando García | 24/07 vencido |
| R13 | Disponibilidad limitada de SmartVista y Apificación para pruebas App | SmartVista / Armando García | 10/ago |
| R14 | Inestabilidad ambiente Unity en pruebas R4 — ya ocurrió en R3 | Testing / Miguel Burcio | 28/sep |
| R16 | Incompatibilidad SmartVista vs legado detectada tarde en pruebas | PM Lead SmartVista / Armando García | Antes pruebas SIWEB |
| R17 | Frameworks obsoletos en CAT generan deuda técnica y riesgo cronograma | CAT Ramsés Santos / Arq. Mercedes Espinosa | 03/ago vencido |

---

### Cerrado

| ID | Descripción | Fecha cierre |
|----|-------------|-------------|
| R03 | Confirmación de refuerzo equipo Appware | 22/07/2026 |

---

## Assumptions (H01–H04)

> **Alerta:** Las 4 assumptions están en estado "Por Validar". Ninguna ha sido formalmente aprobada por negocio. Cada una representa un riesgo latente que puede materializar trabajo no dimensionado en plena construcción o SIT.

| ID | Supuesto | Componente | Relevancia | Validador | Impacto si no se confirma |
|----|---------|-----------|-----------|----------|--------------------------|
| H01 | Exclusión de abonos bancarios del límite de saldo a favor queda fuera de R4 | SmartVista | Alta | Armando García | +1.5 meses pruebas + personalización BPC |
| H02 | Restricción liquidación última mensualidad (pago anticipado) fuera de alcance R4 | SIWEB | Media | Armando García | Desarrollo adicional con BPC — impacta cronograma SIWEB |
| H03 | Cargos recurrentes y domiciliaciones en bloqueo de tarjeta fuera de alcance R4 | APP | Alta | Eduardo Guzmán | Criterios adicionales en múltiples User Stories + desarrollo no dimensionado |
| H04 | Pagos anticipados y cancelación de compras diferidas corresponden a SIWEB (no a App) en R4 | APP | Alta | Eduardo Guzmán | User Stories regresan al backlog de App — impacto cronograma y capacidad |

---

## Issues (I01–I03)

### I01 — CAT sin equipo de desarrollo

**Severidad:** Alta | **Estado:** Abierto | **Owner:** CAT / Ramsés Santos | **Due date:** 07/08/2026

El proveedor de CAT está en proceso de contratación. La incorporación estimada es mediados de septiembre + 1 mes de onboarding = construcción inicia mediados de octubre. El code freeze es diciembre. El margen real de construcción es de **6 a 8 semanas para 12 User Stories**.

**Remediación:** Confirmar DTMs con Appware en paralelo a la contratación para no perder tiempo de diseño al momento de la incorporación. Confirmar nombre, fechas y SLA del proveedor. Explorar capacidad interna como contingencia.

---

### I02 — Único entorno homologado para SIT/UAT/NFT/Seguridad

**Severidad:** Alta (impacto sistémico equivalente a Crítica) | **Estado:** Abierto | **Owner:** Infra BCPL | **Due date:** TBD

Desde el inicio del programa existe un solo entorno homologado compartido para todos los ciclos de prueba. En R3 ya se observó contención. En R4, con múltiples tracks convergiendo en Q4, la colisión es prácticamente inevitable. Ya genera bloqueos efectivos entre equipos y riesgo de contaminación de datos entre ciclos.

**Remediación:** Provisionar entorno ETL E2E adicional + entorno pre-productivo para Dress Rehearsals. Publicar calendario centralizado de uso de entornos con SLA y responsables.

---

### I03 — Célula Apolo App BanCoppel sin contratar

**Severidad:** Alta (impacto sistémico equivalente a Crítica) | **Estado:** Abierto | **Owner:** Apolo Lead / Leonardo Hernández | **Due date:** TBD

La contratación de la célula completa de Apolo en App BanCoppel no se ha concretado. Abierto desde el 19/05/2026 — lleva más de 3 meses sin resolverse. Sin equipo, el canal App no puede completar la integración con Apolo antes del SIT. Los hitos de R4 en diciembre están en riesgo directo.

**Remediación:** Contratación inmediata con fechas, SLA y plan de onboarding. Definir cierre de canales como gate formal del SIT. Preparar plan alterno con mocks si hay retraso en la contratación.

---

## Dependencies (D01–D02)

### D01 — Normatividad Contable → SmartVista (User Stories R418–R420)

**Severidad:** Severa | **Estado:** Activa | **Due date:** 24/07/2026 — **VENCIDA**

Normatividad Contable debe entregar la guía de diferimientos (diferimientos + pagos anticipados + liquidaciones + meses con intereses) para que SmartVista pueda cerrar los criterios de aceptación de R418, R419 y R420. Sin esta guía, las tres User Stories no pueden cerrar refinamiento ni iniciar construcción.

**Predecesor:** Normatividad Contable / J.A. Valverde  
**Sucesor:** PM SmartVista / Armando García

---

### D02 — Infra BCPL → Todos los streams (inicio SIT)

**Severidad:** Severa | **Estado:** Activa | **Due date:** TBD

Infra BCPL debe estabilizar el entorno homologado (aplicativos desplegados, comunicaciones certificadas, arquitectura conectada) antes de que cualquier stream pueda iniciar SIT. Si no se resuelve, bloquea en cascada: SIT → UAT → NFT → Go-Live.

**Predecesor:** Infra BCPL  
**Sucesor:** QA Lead / PMO

---

## Ítems con Due Dates Vencidas (al 2026-08-15)

| ID | Descripción corta | Due date | Días vencido |
|----|-------------------|----------|-------------|
| D01 | Guía contable Normatividad | 24/07 | 22 días |
| R11 | Guía diferimientos contable | 24/07 | 22 días |
| R07 | Calendario integrado QA | 26/07 | 20 días |
| R08 | Entregables Contabilidad | 26/07 | 20 días |
| R06 | Plan Cobranza | 30/07 | 16 días |
| R12 | Diseños CX/Figma | 29/07 | 17 días |
| R03 | Refuerzo Appware | 22/07 | CERRADO |
| R15 | Infra SVFM ambientes | 03/08 | 12 días |
| R05 | Confirmación mejoras Apolo | 08/08 | 7 días |
| R01 | Gate DTMs Appware | 10/08 | 5 días |
| R17 | Postura frameworks CAT | 03/08 | 12 días |

**11 ítems con due date vencida. El RAID necesita una sesión urgente de re-baselining.**

---

*Fuente: `RAID_Log_Programa_Unity_R4_v2.0.xlsx` (03/08/2026) + `Propuesta de RAID_R4.pptx` (30/07/2026)*  
*Próximo paso: cruzar con BCPL_R4 Roadmap para ver impacto en cronograma maestro.*  
*Generado: brain.db v0.3.0*