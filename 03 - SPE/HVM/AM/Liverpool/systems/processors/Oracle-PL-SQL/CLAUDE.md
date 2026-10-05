# Oracle PL-SQL — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization
> Specialist activo: [Specialist - Oracle Forms PL-SQL](../../../Fase%200%20-%20Discover/Specialist%20-%20Oracle%20Forms%20PL-SQL/CLAUDE.md) `[STATE: PROPOSED]`
> **ROL CORREGIDO** — fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16)

```
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: merchandising-planning-tools
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | Oracle Database + PL/SQL (packages, procedures) |
| Lenguaje | PL/SQL |
| Rol | **Herramientas de planning y analytics de merchandising** — PL/SQL Size Scaling (curvas de tallas) y PL/SQL Allocation (distribución de pedidos entre tiendas) |
| TOGAF Type | `processors` (SoD — herramientas especializadas de planeación) |
| Dominios retail | R01 Gestión Comercial · R04 Cadena de Suministro |
| Estado | `[STATE: SCAFFOLD]` — análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## ⚠ Corrección Crítica de Hipótesis

**Hipótesis inicial INCORRECTA:**
> "Oracle PL-SQL procesa LiverpoolCard (crédito al consumo, cobranza, cargos)"

**Realidad confirmada en dashboard AS-IS:**

El procesamiento LiverpoolCard está distribuido entre:
| Sistema | Función real |
|---------|-------------|
| **VPL Vision Plus** (Mainframe) | Autorizaciones, estados de cuenta, cargos, intereses |
| **FICO TRIAD** | Originación de crédito, scoring, políticas APM/OM |
| **Base 24** | Switch transaccional (enruta autorizaciones) |
| **Cyberfinancial** | Cobranza y análisis de riesgo (SaaS EQUIFAX) |
| **Card Wizard** | Emisión de plástico |

Oracle PL-SQL en Liverpool **NO es el procesador financiero** — es un motor de planning/analytics de merchandising.

---

## Aplicaciones PL/SQL Confirmadas

| Aplicación | Función | Dominio |
|-----------|---------|---------|
| **PL/SQL Size Scaling** | Análisis de curvas de tallas (sizing) para compra de mercancía | R01 |
| **PL/SQL Allocation** | Optimización de distribución de pedidos entre tiendas | R01, R04 |

Ambas corren sobre Oracle DB y contienen lógica de planning comercial — no lógica financiera.

---

## Dependencias Conocidas

### Inbound:
- **SAP ECC** — datos de inventario y compras (insumo para allocation)

### Outbound:
- **SAP ECC** — plan de allocation resultante

---

## Decisión 7R (Actualizada)

- **PL/SQL Size Scaling**: Refactor (migrar lógica a microservicio Python/Java) o Repurchase (solución SCM moderna con sizing integrado)
- **PL/SQL Allocation**: Refactor o Repurchase (herramienta de demand planning: o9, SAP IBP)
- **Oracle DB como plataforma**: confirmar si se usa solo para estas herramientas o hay más lógica PL/SQL en Etapa 0

---

## Consideraciones de Regulación

Dado que Oracle PL-SQL **no procesa LiverpoolCard**, la regulación financiera (CONDUSEF, Banxico) **no aplica** a este sistema. Aplica lógica comercial de planeación. Sin embargo, confirmar en Etapa 0 si existe algún componente PL/SQL financiero adicional no identificado en el dashboard.

---

## Estructura

```
systems/processors/Oracle-PL-SQL/
├── source/code/     ← scripts PL/SQL, packages DDL, triggers
├── source/docs/     ← docs técnicos Oracle, diseño BD
├── source/ops/      ← scripts producción, config Oracle listener
├── digital-brain/seeds/
├── knowledge-base/rules/, vocab/, ontology/, regulacion/
├── generators/
├── dt/
├── portal/data/
└── old/
```

---

*Actualizado 2026-09-02 · ROL CORREGIDO — Oracle PL-SQL = planning/merchandising, NO procesador LiverpoolCard · fuente: Arquitectura_Liverpool_Dashboard_1.html · SPE-AM-003*
