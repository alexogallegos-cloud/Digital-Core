# Gentera — Application Modernization (HVM · SAP ABAP RE)
> Proyecto cliente · Application Modernization · High Velocity Modernization · 03 S&PE · Digital Core
> Estado: DISCOVER — Etapa 0 (Setup & Inventory)
> Fecha de inicio: 2026-07-16

---

## Componentes en Scope

| ID | Sistema | Función | Tecnología legacy | Spec | Fase SDLC |
|---|---|---|---|---|---|
| `SPE-AM-002` | GENCore | SAP landscape Gentera — customizaciones Z/Y de negocio microfinanzas | SAP ECC 6.0 / S/4HANA · ABAP · ABAP Dictionary | [GENCore/spec-spe-am-002.md](GENCore/spec-spe-am-002.md) `[DATO-REQUERIDO]` | DISCOVER — Etapa 0 |

---

## Naturaleza del Sistema

Gentera opera sus procesos financieros back-office sobre un landscape SAP con customizaciones Z/Y desarrolladas a lo largo de múltiples implementaciones. La lógica de negocio específica del modelo de microfinanzas (crédito grupal · ciclos de crédito · cobranza en campo · comisiones · reportería regulatoria) vive parcialmente en **programas ABAP custom, BADís y tablas Z**, encima del estándar SAP.

```
[Canales front-end · Apps de campo · Sistemas externos (CNBV/SPEI)]
        │
        │  RFC · BAPI · IDoc · REST (si aplica)
        ▼
 ┌─ SAP ECC / S/4HANA ─────────────────────────────────────────┐
 │  Módulos estándar SAP (FI · CO · SD · MM · HCM · ...)       │
 │                      ↑                                       │
 │  Customizaciones Z/Y:                                        │
 │    Programas ABAP custom (ZFI* · ZSD* · ZHR* · ...)         │
 │    BADí implementations (extensiones a procesos estándar)    │
 │    Z-tables (datos y parametrización propios de Gentera)     │
 │    User Exits / Enhancement Spots                            │
 └─────────────────────────────────────────────────────────────┘
```

**Objetivo de la fase DISCOVER:** entender qué hay en el landscape SAP de Gentera — cuánto código Z existe, dónde vive la lógica de negocio real del modelo de microfinanzas, y qué tanto está acoplado al estándar SAP vs. qué puede extraerse o modernizarse.

---

## Hipótesis de Estrategia de Modernización (confirmar Etapa 4)

`[DATO-REQUERIDO]` — Pendiente de confirmar el objetivo de modernización con el sponsor de Gentera.

| Escenario | Patrón 7R | Descripción |
|---|---|---|
| **A — S/4HANA Migration** | Replatform (estándar) + Refactor (Z-code) | Upgrade brownfield/bluefield a S/4HANA · Remediación de Simplification Items · Z-code adaptado · Sin reemplazo de SAP |
| **B — SAP Replace Selectivo** | Replace (módulos específicos) + Retain (módulos estándar) | Módulos con alta densidad de Z-code custom se reemplazan por microservicios · SAP queda para funciones estándar (FI/CO base) |
| **C — SAP Decommission Total** | Replace | SAP reemplazado por plataforma cloud-native · Escenario menos probable pero evaluar si Z-code es > 60% de funcionalidad |

---

## Etapa 0 — Checklist de Setup & Inventory

### Insumos del cliente

- [ ] **0.1** Acceso read-only a tablas de repositorio SAP: `TADIR · TRDIR · TRDIRT · TFDIR · SXC_EXIT · SXS_INTER · DD02L · DD03L · E070 · E071`
- [ ] **0.2** Versión SAP exacta confirmada (transacción `SMSY` o tabla `CVERS`)
- [ ] **0.3** Lista de módulos SAP activos (FI · CO · SD · MM · HCM · WM · PP · otro)
- [ ] **0.4** Lista de landscapes (DEV · QA · PROD) y sistema de acceso para extracción
- [ ] **0.5** Resultado del SAP Readiness Check (si aplica migración a S/4HANA)
- [ ] **0.6** Resultado de ABAP Test Cockpit (ATC) con adaptation check (si disponible)
- [ ] **0.7** Lista de paquetes / namespaces custom del cliente (ZFI* · ZSD* · ZHR* · etc.)
- [ ] **0.8** SME técnico Gentera asignado (Basis + SME de dominio de negocio)
- [ ] **0.9** Objetivo de modernización confirmado por sponsor (ver hipótesis arriba)

### Setup Digital Core

- [ ] **0.10** Ambiente de análisis provisionado (acceso RFC / GUI acordado con Basis de Gentera)
- [ ] **0.11** Lead Architect AM designado (Accenture MX)
- [ ] **0.12** Decisión: ¿AM solo o requiere doble handoff con `05 MDP` por data migration compleja?
- [ ] **0.13** Protocolo de confidencialidad SAP source acordado con cliente (ABAP code es propiedad de SAP + customizaciones son del cliente)

---

## Estructura del Proyecto

```
Gentera/
├── README.md                       ← este archivo
├── CLAUDE.md                       ← Project Agent (SPE-AM-002)
├── knowledge-base-gentera.md       ← Knowledge base del cliente
├── GENCore/                        ← Directorio de trabajo principal
│   ├── source/                     ← Exports SAP: ABAP code dumps · DDIC exports · ATC reports
│   ├── knowledge-base/             ← Knowledge base por módulo SAP (post-Etapa 0)
│   │   ├── FI-ContabilidadFinanciera/   (se crea post-Etapa 0)
│   │   ├── CO-Controlling/              (se crea post-Etapa 0)
│   │   ├── MM-ComprasInventarios/       (se crea post-Etapa 0)
│   │   ├── HR-RecursosHumanos/          (se crea post-Etapa 0)
│   │   └── ...                          (otros módulos)
│   └── spec-spe-am-002.md          ← Component spec (se crea post-Etapa 0)
└── adr/
    └── (ADRs se crean a partir de Etapa 4)
```

---

## Equipo

| Rol | Nombre | Estado |
|---|---|---|
| Lead Architect AM (Accenture MX) | `[DATO-REQUERIDO]` | Pendiente |
| Sponsor Técnico Gentera | `[DATO-REQUERIDO]` | Pendiente |
| SME Gentera — Dominio de negocio | `[DATO-REQUERIDO]` | Pendiente |
| SME Gentera — Basis / Arquitecto SAP | `[DATO-REQUERIDO]` | Pendiente |
| Program Manager | `[DATO-REQUERIDO]` | Pendiente |

---

## Dependencias Cross-Offering

| Dependencia | Razón |
|---|---|
| `[DEPENDS-ON: 04 Intelligent Infrastructure]` | LZ + cluster + observability obligatorio antes de RELEASE (si escenario B/C) |
| `[DEPENDS-ON: 05 Modern Data Platform]` | Data migration SAP → plataforma destino es no trivial (tipos CURR/QUAN, tablas Z con datos transaccionales) |
| `[HANDOFF: 07 AMS Reinvention]` | Coexistencia SAP + nuevo durante ventana de migración requiere modelo AMS doble |
| `[BLOCKED-BY: 01 TS&T]` | Target architecture (escenario B/C: microservicios que reemplazan módulos SAP) requiere endorsement TS&T |

---

## Notas de Clasificación del Caso

**¿Por qué Application Modernization y no Mainframe Modernization?**

SAP ECC / S/4HANA corre sobre servidores estándar (x86/Linux/HANA) — no es un mainframe. El lenguaje ABAP es propiedad de SAP pero sigue siendo un lenguaje de aplicación sobre base de datos relacional. La metodología de RE (5 Etapas del Specialist SAP ABAP) es equivalente a la de Informix SPL, no a la de COBOL z/OS.

| Criterio | SAP ABAP / Gentera | Mainframe (Banamex S500) |
|---|---|---|
| Plataforma | Servidor Linux / HANA standard | Unisys ClearPath MCP (mainframe propietario) |
| Lenguaje | ABAP (high-level, OO, SQL-based) | COBOL · ALGOL · WFL |
| Base de datos | HANA / Oracle / MaxDB (relacional) | DMSII (jerárquico propietario) |
| Lifecycle | **Application Modernization** | Mainframe Modernization |
| Metodología RE | 5 Etapas Specialist - SAP ABAP | 5 Etapas Specialist - Reverse Engineering COBOL |

---

*Última actualización: 2026-07-16 · v0.1 · Creación inicial — DISCOVER Etapa 0.*