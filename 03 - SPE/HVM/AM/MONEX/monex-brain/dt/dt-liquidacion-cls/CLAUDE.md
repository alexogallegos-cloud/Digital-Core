# DT Liquidación CLS — Digital Twin
> CLS Settlement · Payment-vs-Payment · Ambición 2030

## Pregunta Central
¿Cuál es la arquitectura de conectividad CLS y qué gaps bloquean el acceso de MONEX?

## Por Qué CLS es Crítico para MONEX

MONEX quiere escalar a $2B USD y 30% internacional. Sin CLS:
- Cada operación FX tiene riesgo de contraparte (Herstatt risk)
- Clientes institucionales grandes exigen PvP
- Competitive disadvantage vs. bancos CLS miembros

## Arquitectura CLS (conceptual)

MONEX FX Engine → Instrucción CLS → CLS Bank → Settlement PvP → Confirmación
                                         |
                              MuleSoft (orquestación)
                                         |
                              treasury (posiciones post-CLS)

## Requisitos para CLS Membership

| Requisito | Estado MONEX | Gap |
|-----------|-------------|-----|
| Participante directo (banco corresponsal) | Por confirmar | DATO-REQUERIDO |
| Conectividad SWIFT con CLS Bank | swift existe pero CLS no está configurado | ALTO |
| Mensajería ISO 15022 o 20022 | Migración pendiente (Motor de Pagos) | ALTO |
| Settlement accounts en CLS currencies | Por confirmar | DATO-REQUERIDO |
| Riesgo operacional DORA-compatible | Evaluación pendiente | ALTO |

## Pendientes (DATO-REQUERIDO)
- [ ] ¿Tiene MONEX relación previa con CLS o algún agente CLS?
- [ ] ¿Cuáles divisas opera MONEX actualmente?
- [ ] Volumen FX diario (para evaluar threshold de CLS membership)
- [ ] Estado actual de conectividad SWIFT — versión, arquitectura

---
*v1.0 · 2026-09-22 · Scaffold*
