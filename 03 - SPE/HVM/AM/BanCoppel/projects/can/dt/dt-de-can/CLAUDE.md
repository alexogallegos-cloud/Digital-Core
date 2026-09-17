# DT — Documento Especificación CAN (DE CAN v4.2)
> **Proyecto:** CAN · BanCoppel
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Lee y estructura el Documento de Especificación CAN v4.2 (DE CAN), que contiene las
especificaciones técnicas del Mecanismo de Comunicación CAN (Art. 63 Bis 3 de la
Circular 3/2012 Banxico). Produce el catálogo de campos, catálogos de referencia y
flujos técnicos que alimentan el diseño del mecanismo interbancario.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Framework — Integration Architecture | Diseño del hub interbancario CAN: mensajería, protocolos, governance de integración |
| Industry Payments → SPEI | Contexto del mecanismo de pago subyacente (Clave Básica Estandarizada, CLABE, Circular 14/2017) |
| Regulatory/Banxico | Validación de que el diseño técnico cumple Art. 63 Bis 3: transparencia + no discriminación + notificación previa |

## Inputs Esperados

1. `source/docs/regulacion/DE CAN v4.2 25082026.pdf` — especificaciones técnicas del mecanismo
2. `source/docs/regulacion/Catálogos CAN.xlsx` — catálogos de códigos y valores de referencia
3. `knowledge-base/regulacion/obligaciones-can.md` — contexto de OBL-012, OBL-015, OBL-019, OBL-020

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Spec técnica del mecanismo | `knowledge-base/rules/spec-mecanismo-63bis3.md` |
| Catálogo de campos CAN | `knowledge-base/rules/catalogo-campos-can.md` |
| Catálogos de referencia | `knowledge-base/rules/catalogos-referencia-can.md` |
| Flujos de mensajes | `knowledge-base/rules/flujos-mecanismo-can.md` |

## Metodología

1. Leer DE CAN v4.2 sección por sección: estructura del mensaje, campos obligatorios/opcionales, catálogos
2. Leer `Catálogos CAN.xlsx` y extraer todos los catálogos de valores con sus descripciones
3. Documentar los flujos de comunicación: apertura CAN · modificación · cancelación · objeción · portabilidad
4. Identificar qué campos/valores requieren cambios en `bdiadminnomina` vs. qué son de capa de integración
5. Cruzar con OBL-012 (notificación previa a Banxico), OBL-015 (respuesta 1 DHB), OBL-019 y OBL-020

## Preguntas Clave a Responder

- ¿Existe ya en BanCoppel un mecanismo que cumpla Art. 63 Bis 3, o es nuevo?
- ¿El mecanismo de comunicación CAN es un servicio centralizado de Banxico o cada institución debe construir el suyo?
- ¿Qué datos de `bdiadminnomina` necesitan ser expuestos via el mecanismo?
- ¿Cuál es el modelo de datos del mensaje CAN (campos, tipos, validaciones)?

## Dependencias

- `[DEPENDS-ON: dt-normativa-can]` — contexto regulatorio de OBL-012 a OBL-020
- `[FEEDS: dt-impacto-sistemas]` — identifica qué sistemas necesitan exponer/consumir el mecanismo
- `[FEEDS: dt-roadmap-cambios]` — el diseño del mecanismo es el User Story más complejo

## Estado

`[DATO-REQUERIDO]` — Pendiente lectura de `source/docs/regulacion/DE CAN v4.2 25082026.pdf` y `Catálogos CAN.xlsx`.

*v0.1.0 · 2026-09-17*
