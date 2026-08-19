# DT: Plan SIT/UAT — Unity R4
> **Digital Twin** · Fuente: RAID v2.0 · Minutas R4 · SME SRE & AIOps · SME Core Banking Transformation
> **Versión**: v1.0.0 · 2026-08-16
> **Propósito**: Plan de pruebas por capability, criterios de entrada/salida SIT y UAT, conflicto pentest noviembre, gestión de defectos y triage

---

## Cronograma de Pruebas

| Fase | Inicio | Fin | Status | Dependencia |
|------|--------|-----|--------|------------|
| Cierre análisis + desarrollo | — | 15 oct 2026 | Pending | — |
| **Inicio SIT** | **15 oct 2026** | **15 dic 2026** | **At risk** | DoD BUILD verde por capability |
| Pentest Cobranza (conflicto) | 15 nov 2026 | 20 nov 2026 | **At risk** | Paralelo con SIT activo |
| Code Freeze | 15 dic 2026 | — | Pending | Fin SIT verde |
| UAT | Dec 2026 | Dec 2026 | Pending | Code Freeze + sign-off BanCoppel |
| **Go-Live** | **~15 ene 2027** | — | Pending | UAT aprobado + todos los gates |

---

## 🔴 Conflicto Crítico — Pentest Cobranza (Nov 15-20)

Durante la ventana del 15 al 20 de noviembre, hay un **pentest de Cobranza Direccionada** programado que **corre simultáneo con el SIT activo**. Este conflicto no está resuelto.

| Problema | Impacto |
|---------|---------|
| El pentest requiere acceso agresivo (fuzzing, auth testing) al ambiente de QA/SIT | Puede corromper datos de SIT, invalidar pruebas en curso |
| Si SIT sigue corriendo durante el pentest, los defectos encontrados mezclan categorías (funcionales vs. seguridad) | Triage imposible, velocidad de fix reducida |
| Un freeze de SIT de 5 días (15-20 nov) reduce la ventana de pruebas en ~10% | Presión sobre el Code Freeze del 15-dic |

### Resoluciones posibles (requiere decisión)

| Opción | Ventaja | Riesgo |
|--------|---------|--------|
| A — Mover pentest antes del 15-oct (pre-SIT) | No interrumpe SIT | Requiere que Cobranza esté lista antes de SIT |
| B — Mover pentest post-SIT (después del 15-dic) | No interrumpe SIT | Retrasa evidencia de seguridad para go-live |
| C — Ambiente separado para el pentest | SIT no se interrumpe | Costo adicional; ambiente paralelo requiere sincronización de datos |
| D — Freeze SIT durante el pentest (5 días) | Pentest limpio | 5 días menos de SIT — cronograma más apretado |

> **Acción**: PMO BanCoppel + ACN deben decidir la resolución antes del 30 de septiembre.

---

## Criterios de Entrada a SIT

Antes de iniciar SIT el 15 de octubre, todos los criterios deben cumplirse:

| Criterio | Responsable | Estado |
|----------|------------|--------|
| Todos los casos de prueba por capability documentados y aprobados | ACN QA + BanCoppel PO | Pendiente |
| Ambiente de SIT configurado y estable (SmartVista + APOLO + App + Apificación) | ACN + BPC + Appwhere | Pendiente |
| CAT ambiente de SIT disponible (bloqueado hasta contratar proveedor) | Proveedor CAT | 🔴 Bloqueado |
| Datos de prueba cargados (clientes, cuentas, tarjetas de prueba) | ACN + BanCoppel | Pendiente |
| Herramienta de gestión de defectos configurada y con acceso a todos los actores | ACN | Pendiente |
| DoD BUILD verde para todas las capabilities mandatorias de R4 | Todos los vendors | Pendiente |
| Plan de triage de defectos acordado con todos los vendors | ACN | Pendiente |

---

## Plan de Pruebas por Capability

Organización por capability (no por componente técnico) — esta es la vista que importa para el go-live.

### Capabilities Mandatorias R4 — Coverage SIT

| Capability | BIAN Domain | Componentes bajo prueba | Casos de prueba estimados | Status |
|-----------|-------------|------------------------|--------------------------|--------|
| CAP-CARD-MANUFACTURING | Issued Device Administration | SmartVista (OCG/Cargen) + maquiladores | DATO-REQUERIDO | No iniciado |
| CAP-AUTHORIZATION | Credit Card Authorization | SmartVista (SVBO/SVIP) + PayTrue | DATO-REQUERIDO | No iniciado |
| CAP-CARD-LIFECYCLE | Issued Device Administration | SmartVista (SVBO) | DATO-REQUERIDO | No iniciado |
| CAP-OVERPAYMENT | Credit Facility | SmartVista — **BYU0039 abierto** 🔴 | DATO-REQUERIDO | Bloqueado |
| CAP-DEFERRED-PURCHASE | Consumer Lending | SmartVista (DPP — **no contratado**) 🔴 | N/A | Bloqueado |
| CAP-BALANCE-STATEMENT | Credit Card Position | SmartVista + App + SIWEB | DATO-REQUERIDO | No iniciado |
| CAP-PAYMENT | Payment Execution | SmartVista + APOLO + App | DATO-REQUERIDO | No iniciado |
| CAP-CUSTOMER-PROFILE | Customer Management | APOLO + ICCAT (CAT) | DATO-REQUERIDO | Parcial bloqueado |
| CAP-CHANNEL-SELFSERVICE | Contact Center Management | CAT **sin contratar** 🔴 | N/A | Bloqueado |
| CAP-AUTHENTICATION | Customer Authentication | CAT + App (OTP) | DATO-REQUERIDO | Parcial |
| CAP-COLLECTIONS-AGING | Collections Management | Cobranza Direccionada + SmartVista | DATO-REQUERIDO | No iniciado |
| CAP-FEE-COMMISSION | Product Fees | SmartVista (SVBO configuración) | DATO-REQUERIDO | No iniciado |
| CAP-ACCOUNTING-INTEGRATION | Financial Accounting | SmartVista + Apificación | DATO-REQUERIDO | No iniciado |
| CAP-ERROR-CATALOG | — | SmartVista + todos los canales | DATO-REQUERIDO | No iniciado |

### Capabilities con gaps — impacto en plan de pruebas

| Capability | Gap | Impacto en SIT |
|-----------|-----|----------------|
| CAP-DEFERRED-PURCHASE | DPP no contratado | Esta capability **no entra en SIT** — queda fuera del alcance R4 si no se decide antes de oct |
| CAP-OVERPAYMENT | BYU0039 sin cierre | SIT de esta capability depende de que BPC cierre el ticket — bloqueante |
| CAP-CHANNEL-SELFSERVICE + CAP-AUTHENTICATION (parcial) | CAT sin contratar | Las HUs de CAT no entran en SIT hasta contratar el proveedor |
| CAP-CARD-MANUFACTURING | OCG/Connect Direct manuales | SIT cubre el flujo manual; el automático es post-R4 |

---

## Tipos de Prueba por Fase

| Tipo | Fase | Herramienta | Responsable | Criterio de pase |
|------|------|------------|------------|-----------------|
| Prueba de integración por capability | SIT | DATO-REQUERIDO | ACN QA | 100% casos críticos pasando |
| Prueba de regresión | SIT | DATO-REQUERIDO | ACN QA | Sin regresiones en capabilities live |
| Prueba de carga / rendimiento SVIP | SIT | DATO-REQUERIDO | ACN + BPC | Latencia P95 ≤ SLO definido |
| Prueba de carga APOLO | SIT | DATO-REQUERIDO | ACN + Appwhere | Latencia P95 ≤ 5,000ms |
| Pentest Cobranza | Paralelo SIT (conflicto) | DATO-REQUERIDO | Equipo de seguridad | Sin vulnerabilidades High/Critical abiertas |
| UAT por capability | UAT | Manual + scripted | BanCoppel PO + ACN | Sign-off formal BanCoppel por capability |
| Prueba de equivalencia SmartVista vs. CMS | SIT/parallel run | Comparator | ACN | Divergencia ≤ 0.05% |

---

## Criterios de Salida de SIT (Code Freeze Gate)

Para aprobar el Code Freeze el 15 de diciembre, **todos** los criterios deben cumplirse:

| Criterio | Umbral | Fuente |
|----------|--------|--------|
| Defectos Críticos abiertos | 0 | Herramienta de defectos |
| Defectos Altos abiertos | ≤ DATO-REQUERIDO | Herramienta de defectos |
| Casos de prueba pasando (capabilities mandatorias) | ≥ 95% | Reporte SIT |
| CAP-OVERPAYMENT | BYU0039 cerrado o workaround aceptado | BPC ValueEdge |
| CAP-CARD-MANUFACTURING | Certificación con ≥ 1 maquilador | Certificado de layout |
| Pentest Cobranza | Sin vulnerabilidades High/Critical | Reporte pentest |
| SLOs de latencia en ambiente SIT | Dentro de SLO definido | Dashboard |

---

## Protocolo de Triage de Defectos

Durante SIT, los defectos deben ser triaged en ≤ 24 horas:

```
Defecto detectado
      │
      ▼
ACN QA clasifica: ¿capability? ¿severidad?
      │
      ├── Crítico → War Room inmediato (todos los vendors involucrados)
      │                  → SLA: fix en ≤ 48h; si no se puede, workaround o descope documentado
      │
      ├── Alto → Owner del componente tiene ≤ 72h para fix o plan
      │
      └── Medio/Bajo → Sprint de fix semanal
      
VENDORES involucrados en el triage:
- Defecto en SmartVista → BPC + Appwhere
- Defecto en APOLO → Appwhere
- Defecto en App → ACN
- Defecto en Apificación → ACN
- Defecto en CAT → Proveedor CAT
```

---

## UAT — Plan por Capability

| Capability | Firmante UAT BanCoppel | Escenarios mínimos | Modalidad |
|-----------|----------------------|-------------------|-----------|
| CAP-CARD-MANUFACTURING | DATO-REQUERIDO | Solicitud → maquila → entrega | Manual con datos reales |
| CAP-AUTHORIZATION | DATO-REQUERIDO | Autorización exitosa, declinada, fraude | Scripted |
| CAP-PAYMENT | DATO-REQUERIDO | Pago desde App, SIWEB | Manual |
| CAP-BALANCE-STATEMENT | DATO-REQUERIDO | Consulta saldo, movimientos, estado de cuenta | Manual |
| CAP-COLLECTIONS-AGING | DATO-REQUERIDO | Acciones por período E1/E2/E3 | Manual |
| Todas las demás capabilities | DATO-REQUERIDO | DATO-REQUERIDO | DATO-REQUERIDO |

---

## DATO-REQUERIDO — Información crítica faltante

1. Herramienta de gestión de defectos seleccionada (Jira? Azure DevOps? otra?)
2. Resolución del conflicto pentest Cobranza (Opción A, B, C o D)
3. Número de casos de prueba por capability (plan de pruebas formal)
4. Firmantes UAT por capability (BanCoppel PO por área)
5. Umbral de defectos Altos aceptable para Code Freeze
6. Herramienta de prueba de carga seleccionada
7. Owner del triage war room durante SIT
8. Decisión de alcance de CAP-DEFERRED-PURCHASE en R4 (¿se descopa o se resuelve el DPP?)

---

*Creado: 2026-08-16 — Digital Twin Plan SIT/UAT Unity R4 v1.0.0*
