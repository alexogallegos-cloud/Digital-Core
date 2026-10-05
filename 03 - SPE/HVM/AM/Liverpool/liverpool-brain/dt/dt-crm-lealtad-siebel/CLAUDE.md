# Digital Twin — CRM y Lealtad (Oracle Siebel)
> `liverpool-brain/dt/dt-crm-lealtad-siebel/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-08
> **[STATE: ACTIVE — scaffold; fuente de datos pendiente]**

## Propósito

Gemelo digital del CRM de Liverpool: Oracle Siebel CRM para la operación del Call Center y la gestión del programa de lealtad (puntos Liverpool). Opera exclusivamente en Liverpool LIV — Suburbia SBB no lo usa.

Siebel es el candidato más claro a **Repurchase** del landscape: es un producto Oracle en mantenimiento extendido, sin innovación activa, con una base de instalación que el mercado está abandonando en favor de Salesforce Service Cloud o Microsoft Dynamics 365. Sin este DT, la decisión 7R en el dominio de Clientes y Lealtad es incompleta.

## Capa de Arquitectura

**Processors (SoR especializado)** — Capa de Diferenciación

## Dominios Principales

R02 — Gestión de Clientes y Lealtad
R05 — Canales Digitales (Call Center como canal)

## Sistemas Involucrados

| Sistema | Vendor | Rol |
|---------|--------|-----|
| **Oracle Siebel CRM** | Oracle | CRM core: casos de servicio, historial de cliente, gestión de interacciones |
| **Programa de Lealtad** | Liverpool interno (sobre Siebel) | Acumulación y redención de puntos Liverpool |
| **CDP-GCP** | Internal / GCP | Destino target — Customer 360 que eventualmente reemplaza la vista de cliente de Siebel |

## Proceso AS-IS

```
CLIENTE (llamada / chat / tienda)
    │
    ▼
CALL CENTER LIVERPOOL
    │
    │  Agente consulta Siebel:
    │  · Historial de compras
    │  · Saldo de puntos
    │  · Casos abiertos
    │  · Estado de LiverpoolCard
    ▼
ORACLE SIEBEL CRM
    │
    ├── Gestión de casos (servicio al cliente)
    │     · Devoluciones y aclaraciones
    │     · Reclamaciones LiverpoolCard
    │     · Seguimiento de pedidos (consulta a Sterling OMS)
    │
    ├── Programa de Lealtad
    │     · Acumulación de puntos por compra
    │     · Redención de puntos en tienda / online
    │     · Niveles de membresía
    │
    └── Vista 360 del cliente (parcial)
          · Compras en tienda (integración SAP)
          · Compras online (`[DATO-REQUERIDO]` — integración ATG/Digital)
          · Saldo LiverpoolCard (integración VPL)

INTEGRACIÓN:
  Siebel ←→ SAP ECC (compras, devoluciones)
  Siebel ←→ VPL Vision Plus (saldo tarjeta)
  Siebel → IBM IIB (eventos de lealtad) → `[DATO-REQUERIDO]`
```

## Señales del AS-IS

| Señal | Impacto | Evidencia |
|-------|---------|-----------|
| Solo en LIV (no SBB) | Suburbia no tiene CRM ni programa de lealtad unificado — brecha competitiva | Dashboard AS-IS |
| Siebel en mantenimiento extendido Oracle | Sin nuevas funcionalidades desde ~2020; soporte extendido con costo creciente | Conocimiento de mercado |
| CDP-GCP en construcción sin reemplazar Siebel aún | Riesgo de inversión duplicada: Liverpool construye Customer 360 pero sigue alimentando Siebel | Dashboard AS-IS |
| Lealtad como módulo de Siebel (no sistema dedicado) | La lógica de puntos está acoplada al CRM — difícil de escalar o abrir a Suburbia | Arquitectura AS-IS |

## Hipótesis 7R para Este Módulo

| Hipótesis | Fundamento |
|-----------|-----------|
| **Repurchase → Salesforce Service Cloud** | Salesforce es el estándar de mercado para CRM en retail. Tiene conectores nativos para commercetools (target ecommerce de Liverpool). Migración es compleja pero el ROI a 3 años es superior al mantenimiento de Siebel. |
| **Repurchase → Microsoft Dynamics 365** | Alternativa si Liverpool tiene acuerdo Microsoft (Azure ya en uso para SBB). Dynamics 365 Customer Service + Loyalty Management cubren ambos casos de uso. |
| **Retain temporal** | Mientras CDP-GCP madura y se define el stack digital, Siebel puede permanecer en mantenimiento mínimo. Riesgo: la deuda técnica crece. |
| **Retire módulo de lealtad → plataforma dedicada** | Separar el programa de puntos de Siebel hacia Salesforce Loyalty Management o Antavo (best-of-breed retail loyalty). Prerequisito para extender lealtad a Suburbia. |

**Señal estratégica**: Liverpool seleccionó commercetools (nov-2025). Commercetools tiene integración nativa con Salesforce — si Liverpool elige Salesforce para CRM, el stack digital (commercetools + Salesforce + CDP-GCP) forma una arquitectura composable coherente.

## Estado

`[STATE: ACTIVE — scaffold]` — DT creado 2026-09-08.
Fuentes de datos primarias (`[DATO-REQUERIDO]`): versión de Siebel, volumen de casos/mes, número de agentes Call Center, base de clientes con puntos activos, integración con VPL/SAP.

## Fuentes de Datos Disponibles

- [x] Dashboard AS-IS (existencia y rol de Siebel en LIV)
- [ ] Versión de Oracle Siebel instalada y estado de soporte
- [ ] Volumen: casos/mes, agentes concurrentes, transacciones de puntos/mes
- [ ] Integraciones activas de Siebel (VPL, SAP, IIB, ATG)
- [ ] Roadmap CDP-GCP y su relación con Siebel (¿reemplaza? ¿coexiste?)
- [ ] Acuerdos comerciales Oracle (costo de mantenimiento extendido Siebel)

## Dependencias Cross-DT

- `dt-inteligencia-cliente` → CDP-GCP es el destino target del Customer 360 que hoy vive en Siebel; ambos DTs deben definir la estrategia de migración de datos de cliente
- `dt-liverpoolcard` → Siebel consulta saldo y movimientos de LiverpoolCard (VPL); la vista del agente de Call Center depende de esta integración
- `dt-ecommerce-transicion` → commercetools + Salesforce formarían el stack digital; la decisión 7R de Siebel debe coordinarse con la selección del stack de ecommerce
- `dt-pedido-omnicanal` → Call Center gestiona reclamaciones de pedidos — integración Siebel ↔ Sterling OMS