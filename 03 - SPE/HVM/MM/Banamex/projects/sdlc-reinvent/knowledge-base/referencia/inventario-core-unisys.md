<!--
  NO FORMA PARTE DEL PAQUETE DE SDLC REINVENT.
  Se sacó de propuesta/ el 2026-10-28: la conversación con el banco es sobre el ciclo
  de entrega, y meter el inventario del core ahí se lee como empaquetar otro proyecto.
  Se conserva como referencia porque las cifras están verificadas y la tabla de
  obligaciones regulatorias no existe armada en ningún otro lado.
  Su conversación natural es la de modernización del core, no esta.
  Corrección pendiente si se reutiliza: las 302,999 líneas son de S500 únicamente;
  S151 no tiene conteo registrado. Las 1,583 reglas sí se reparten, 1,000 de S151
  y 583 de S500, y 1,576 de ellas llevan regulador asociado.
-->

# Lo que ya tenemos de su core

Octubre de 2026

---

Llevamos meses leyendo el código de los sistemas en Unisys. Lo que sigue no es una propuesta de levantamiento: está hecho, se puede verificar contra su propio código y es suyo.

## El inventario

| | |
|---|---|
| Programas leídos | 152, repartidos en 75 de S151 y 77 de S500 |
| Líneas de código analizadas | 302,999 |
| Reglas de negocio extraídas del código | 1,583 |
| Tareas funcionales identificadas | 950 |
| Capacidades de negocio mapeadas a estándar bancario | 26, con 104 correspondencias |
| Flujos de negocio reconstruidos | 45 |
| Conjuntos de datos y campos catalogados | 192 y 849 |
| Vocabulario de negocio normalizado | 2,668 términos |

Cada una de las 1,583 reglas apunta al programa y a la línea de código de la que salió. No son interpretaciones: son trazas.

## Las trece obligaciones regulatorias, trazadas al programa que las produce

Esta es la parte que no existe en ningún otro lado. Para cada reporte sabemos qué programa lo genera, con qué periodicidad y qué pasa si ese programa se toca.

| Reporte | Regulador | Programas |
|---|---|---|
| Serie B, balances y movimientos | CNBV | P130, P131, S254 |
| CUIF R01 a R04 | CNBV | P150, P151 |
| Concentración SAR para IMSS, ISSSTE e INFONAVIT | Banxico e INFONAVIT | P120, de 1991 |
| Interbancario CECOBAN | Banxico y CECOBAN | P610 |
| Captación asegurada | IPAB | P142, P144 |
| Retenciones de ISR e IVA | SAT | P020 |
| INTELAR | CNBV | P671 |
| FraudLink | CNBV | P103 |
| Asientos contables con sector | CNBV | P108 |

Trece obligaciones, nueve de ellas diarias o en tiempo real. Cualquier plan de modernización que no sepa esto de antemano descubre estas dependencias cuando ya es tarde.

## Lo que encontramos de paso

178 hallazgos técnicos sobre los programas leídos, 36 de ellos clasificados como críticos y dos como defecto en producción, con el programa y la línea identificados en ambos casos.

No los traemos como reproche. Los traemos porque aparecieron solos al leer el código, y porque son demostrables en pantalla en la misma sesión si les interesa verlos.

## Lo que todavía no sabemos

De las trazas entre reporte regulatorio y programa de origen, 22 están resueltas y 92 siguen abiertas. El inventario declara sus propios huecos en vez de rellenarlos. Es la misma disciplina con la que vamos a tratar todo lo demás.

## Es suyo

Este inventario es propiedad del banco, se entrega en el formato que prefieran y no condiciona ninguna conversación posterior. Lo construimos trabajando en sus sistemas y ahí se queda.

Lo traemos a esta sesión por una razón: mientras lo armábamos, notamos cuatro cosas sobre su ciclo de entrega que probablemente quieran saber. Van en la hoja siguiente.
