# ITOM Overlay — IT Operating Model MONEX

## Qué es el ITOM overlay

El IT Operating Model (ITOM) overlay proyecta el landscape tecnológico de MONEX a los 6 dominios
operacionales de TI. Permite responder: "¿qué sistemas soportan qué función operacional?" y
"¿dónde están los gaps de operación que el programa Apolo debe resolver?"

El overlay vive en `monex-brain.db::itom_layer` — una capa sobre la tabla `systems` que añade
el dominio ITOM de cada sistema.

---

## Los 6 Dominios ITOM

| Dominio | Código | Pregunta que responde |
|---------|--------|----------------------|
| Technology Operations | TechOps | ¿Qué sistemas tienen cobertura operacional 24/7? |
| Service Management (ITSM) | ITSM | ¿Cómo se gestiona el ciclo de vida de incidentes y cambios? |
| Business Process Management | BPM | ¿Qué procesos de negocio están automatizados end-to-end? |
| Security Operations | SecOps | ¿Qué sistemas tienen controles de seguridad operacional activos? |
| Data Operations | DataOps | ¿Cómo fluyen, se curan y se gobiernan los datos en producción? |
| Platform Engineering | PlatEng | ¿Qué plataformas habilitan el delivery continuo de software? |

---

## Mapeo ITOM × Sistema MONEX

| Sistema | TechOps | ITSM | BPM | SecOps | DataOps | PlatEng |
|---------|---------|------|-----|--------|---------|---------|
| fx-engine | CRITICAL | DATO-REQ | COVERED | DATO-REQ | PARTIAL | N/A |
| treasury | CRITICAL | DATO-REQ | COVERED | DATO-REQ | PARTIAL | N/A |
| payments-legacy | CRITICAL | DATO-REQ | COVERED | DATO-REQ | PARTIAL | N/A |
| mulesoft | HIGH | DATO-REQ | COVERED | DATO-REQ | PARTIAL | COVERED |
| swift | HIGH | DATO-REQ | COVERED | DATO-REQ | N/A | N/A |
| spei | HIGH | DATO-REQ | COVERED | DATO-REQ | N/A | N/A |
| portal-clientes | MEDIUM | DATO-REQ | PARTIAL | DATO-REQ | N/A | N/A |
| api-marketplace | MEDIUM | DATO-REQ | PARTIAL | DATO-REQ | N/A | PARTIAL |
| golden-record-target | TARGET | TARGET | TARGET | TARGET | TARGET | TARGET |
| cnbv-banxico | HIGH | DATO-REQ | COVERED | DATO-REQ | COVERED | N/A |
| dora | HIGH | DATO-REQ | COVERED | DATO-REQ | PARTIAL | N/A |

**Leyenda**: CRITICAL=24/7 operacional · HIGH=alta disponibilidad · MEDIUM=horario extendido · TARGET=to-be · DATO-REQ=sin datos aún

---

## Gaps ITOM Prioritarios

| Gap | Dominio | Impacto | Iniciativa Apolo |
|----|---------|---------|-----------------|
| Sin MDM operacional | DataOps | CRÍTICO — datos inconsistentes en producción | Golden Record |
| Sin observabilidad unificada | TechOps | ALTO — incidentes sin visibilidad cross-sistema | Plataforma Apolo |
| DORA sin TLPT | SecOps | ALTO — FCA compliance desde ene-2025 | DORA compliance |
| Sin API lifecycle management completo | PlatEng | ALTO — MuleSoft sin developer portal maduro | Motor de Pagos |

---

## Relación con TOGAF

El ITOM overlay complementa la clasificación TOGAF:
- **TOGAF** clasifica los sistemas por tipo (core/processors/channels/data/integration/compliance) — el QUÉ hace el sistema
- **ITOM** clasifica los sistemas por función operacional — el CÓMO se opera el sistema

Un sistema `togaf_type: integration` (MuleSoft) puede tener `itom: PlatEng + TechOps`.
Un sistema `togaf_type: core` (fx-engine) siempre tiene `itom: TechOps + BPM`.

---

*v1.0 · 2026-09-22 · Seed inicial — Fase 1 desde estructura TOGAF; Fase 2 requiere entrevistas MONEX*
