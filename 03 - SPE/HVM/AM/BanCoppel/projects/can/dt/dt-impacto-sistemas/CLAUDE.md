# DT — Impacto en Sistemas BanCoppel (CAN)
> **Proyecto:** CAN · BanCoppel
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Mapea qué sistemas, bases de datos y Stored Procedures de BanCoppel están en scope
de la normativa CAN. Cruza las obligaciones regulatorias contra el código existente
en Informix (especialmente `bdiadminnomina`) usando BCOPBrain como fuente de verdad.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Specialist — Informix SPL | Análisis de SPs en bdiadminnomina + dominios relacionados |
| DBA IBM Informix | Schema de tablas, volúmenes, relaciones entre DBs |
| Industry Banking | Validación de qué productos bancarios de nómina están en scope |

## Inputs Esperados

1. `knowledge-base/regulacion/obligaciones-can.md` — producido por dt-normativa-can
2. BCOPBrain `brain.db` — para queries sobre bdiadminnomina
3. Lista de productos BanCoppel en scope CAN

## Outputs

| Artefacto | Ruta |
|-----------|------|
| SPs en scope CAN | `knowledge-base/rules/sps-en-scope-can.md` |
| Sistemas en scope | `knowledge-base/rules/sistemas-en-scope-can.md` |
| Reglas existentes relacionadas | `knowledge-base/rules/reglas-existentes-can.md` |

## Metodología

1. Cargar obligaciones de dt-normativa-can
2. Ejecutar queries sobre BCOPBrain para identificar SPs de bdiadminnomina:
   ```python
   from digital-brain.brain import BCOPBrain
   b = BCOPBrain()
   nomina_sps = b.components(domain="D_NOMINA")  # ajustar dominio
   ```
3. Cruzar obligaciones regulatorias vs. lógica de SPs existentes
4. Identificar qué obligaciones ya tienen cobertura parcial o total en el código
5. Documentar hallazgos como evidencia para dt-brecha-compliance

## Dependencias

- `[DEPENDS-ON: dt-normativa-can]` — requiere obligaciones estructuradas
- `[DEPENDS-ON: BCOPBrain brain.db]` — requiere brain.db actualizado de Informix

## Estado

`[DATO-REQUERIDO]` — Pendiente activación de dt-normativa-can.

*v0.1.0 · 2026-09-16*
