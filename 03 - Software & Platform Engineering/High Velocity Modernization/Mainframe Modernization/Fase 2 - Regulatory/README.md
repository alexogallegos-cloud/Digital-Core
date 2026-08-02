# Fase 2 — Regulatory Framework & Compliance
> Carpeta-puntero · Mainframe Modernization · HVM · 03 S&PE

```
┌─ CARPETA-PUNTERO ──────────────────────────────────────────┐
│ Esta fase NO tiene specialist local en Digital Core.        │
│ La ejecuta el SME externo indicado abajo.                   │
└─────────────────────────────────────────────────────────────┘
```

## Quién ejecuta esta fase

**SME ejecutor:** `SME/Framework/ITSM/GRC/Specialist - Mainframe Modernization Regulatory/`

## Objetivo de la fase

Clasificar cada regla de negocio extraída del sistema legacy en:
- **Mandato regulatorio** (CNBV · Banxico · CONDUSEF · auditoría interna) → no negociable en diseño del sistema moderno
- **Política del banco** → negociable, puede modernizarse
- **Regla obsoleta / residual** → candidata a eliminación

Produce el mapa de cumplimiento regulatorio que habilita la Fase 3 (diseño de equivalence testing) y la Fase DESIGN del SDLC.

## Prerequisitos de entrada

- `[ARTEFACTO]` Catálogo de Reglas de Negocio v1.0 del Specialist - Reverse Engineering (Etapa 3)
- `[ARTEFACTO]` Especificaciones Funcionales (Etapa 3) de los programas con CC > 5
- `[ARTEFACTO]` Data Dictionary v1.0 (Etapa 2) — campos regulatorios identificados
- Acceso al contrato de servicios del banco con los clientes (para validar comisiones vs. CONDUSEF)
- Auditoría interna del banco asignada como contraparte

## Outputs canónicos

| Artefacto | Descripción |
|---|---|
| `regulatory-map-{sistema}.md` | Clasificación `[REGLA-CNBV]`/`[REGLA-BANCO]`/`[REGLA-OBSOLETA?]` por cada regla del catálogo |
| `compliance-gap-{sistema}.md` | Reglas legacy que NO cumplen la normativa vigente (fueron bugs regulatorios perpetuados) |
| `regulatory-notification-plan-{sistema}.md` | Plan de notificación a CNBV / Banxico si el sistema procesa operaciones sujetas a aviso |
| `audit-signoff-{sistema}.md` | Firma de auditoría interna del banco sobre el alcance de equivalencia regulatoria |

## Packet `[INVOKE]`

```
[INVOKE: SME/Framework/ITSM/GRC/Specialist - Mainframe Modernization Regulatory/]
COMPONENTE      : SPE-MM-{NNN} — {nombre del sistema}
CLIENTE         : {banco} — institución de banca múltiple regulada por CNBV
INSUMOS         : Catálogo de Reglas de Negocio v{N} · Especificaciones Funcionales · Data Dictionary
JURISDICCION    : CNBV Circular Única de Bancos · CONDUSEF · Banxico (si incluye SPEI/pagos)
DELIVERABLE     : regulatory-map + compliance-gap + notification-plan + audit-signoff
PLAZO           : {fecha} — antes del inicio de Fase DESIGN
```

## Posición en el ciclo metodológico

```
Etapa 3 (RE: Business Logic) → FASE 2 REGULATORY → Fase 3 Test & Equivalence → DESIGN
                                        ↓
                              [REGLA-CNBV] marca las reglas
                              que deben tener equivalencia
                              ≥ 99.99% sin excepción
```

*Última actualización: 2026-06-30 · v1.0 · Fase creada como carpeta-puntero per REORG de fases MM.*