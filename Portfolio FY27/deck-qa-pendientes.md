# QA del deck de cobertura de arquitectura — hallazgos y cambios pendientes

> Revisión de las láminas 1 a 7 hecha el 2026-10-21 contra `data/pipeline-fy27.json`.
> Los scripts de modificación para Copilot están en `script-copilot-ppt.md`.

---

## Lo que se verificó y está correcto

La aritmética de cobertura cuadra en las tres láminas de perfiles. Banamex reparte 3, 2, 3 y 3 para sus 11 oportunidades. BanCoppel reparte 1, 2 y 2 para sus 5. El bloque restante reparte 9, 9, 7 y 12 para sus 37. Suman 53 sin traslapes y sin oportunidades huérfanas.

También cuadran los derivados: 14 cuentas en el bloque restante, ocho de los nueve frentes de salida de legado concentrados en AXA, siete cuentas para el perfil más disperso, y el 70 por ciento de oportunidades atendido con el 36 por ciento del equipo.

## Bloqueantes

**Lámina 4, columna mal etiquetada.** El encabezado dice "Demanda de pipeline" y la columna contiene 4, 3, 4 y 11, que son los arquitectos asignados. La demanda real es 2.65, 2.30, 6.70 y 11.65. El recuadro de la misma lámina cita "una demanda de 6.70" mientras la tabla muestra 4 en esa celda. La tabla de seis columnas se colapsó a tres al generarse; hay que rehacerla con cinco columnas y verificar que no se vuelva a colapsar.

**Lámina 2, prefijo incorrecto.** La fila dice "02 Data & AI". Data & AI consolida 02, 05 y 06, así que no puede llevar el número de uno de ellos.

**Lámina 3, el mensaje no cierra.** Dice que tres cuentas concentran 30 y las otras once suman 17, pero eso da 47. Faltan las seis de Actinver y BBVA.

## Cambios que no se aplicaron

**Lámina 7** sigue titulada "Los cuatro arquitectos para todo lo demás". No se aplicó la reconversión a "Digital Brain para Arquitectura en Reinvention Managed Services" con los tres bloques de qué es, por qué aquí y qué ya está construido.

**Lámina 2** no tiene la nota de consolidación. Sin ella, la desaparición de Modern Data Platform e Innovation no está explicada en ninguna parte del deck.

## Menores

El cuarto perfil de la lámina 7 quedó en nivel L5 mientras los otros tres están en L6.

La lámina 6 no tiene nota al pie, y es justo donde hace falta explicar por qué tres arquitectos para cinco oportunidades. El dato es que la demanda de BanCoppel con entrega contratada es 3.30 contra tres asignados, y la de Banamex 3.65 contra cuatro.

Los nombres de offering mezclan "y" con ampersand en la misma tabla de la lámina 2.

En la lámina 7 el segundo perfil dice "Reinvention Managed Service" en singular; el offering es "Reinvention Managed Services".

La portada no tiene la barra de 3px en color Señal sobre el panel Ancla, que es el único elemento invariable del sistema de diseño del ecosistema.

## Hueco estructural

El deck no tiene lámina de cierre. La de Decisiones se eliminó al podar el rango 5 a 8 y nunca se repuso. Hoy la presentación expone el problema, la asignación y los perfiles, pero no pide nada.

## Inconsistencia de fondo, no de formato

Los perfiles de Banamex de la lámina 5 no corresponden a los que el Anexo B exige. El contrato pide un Solution Architect L7 y un SDLC y DevSecOps Architect L8 para el laboratorio, con entregables al 11 de noviembre, y esos no aparecen en la lámina. Hay que reconciliar la lámina 5 con el contrato antes de presentar.
