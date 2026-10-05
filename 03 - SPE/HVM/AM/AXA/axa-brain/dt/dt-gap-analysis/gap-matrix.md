# Gap Matrix — AXA México P&C Commercial Lines
> Generado: 2026-09-03 · Fuente: axa-brain.db
> 33 pain points × capacidades ETB Insurance P&C v3.0

---

## Resumen de Brechas por Categoría

| Categoría | Pain Points | LoBs promedio | Manualidad | Dominio ETB afectado |
|-----------|------------|---------------|------------|----------------------|
| Información dispersa y herramientas no conectadas | 8 | 4.5 | 7/8 | D6 Underwriting / D1 Distribution |
| Reglas y controles no automatizados | 6 | 4.0 | 5/6 | Por mapear |
| Sistemas inestables o con limitaciones funcionales | 6 | 1.5 | 5/6 | Por mapear |
| Datos incompletos o inconsistentes | 5 | 3.0 | 4/5 | Por mapear |
| Avance condicionado por otras áreas y terceros | 4 | 3.2 | 0/4 | Por mapear |
| Datos y documentos que requieren preparación manual | 2 | 4.5 | 2/2 | Por mapear |
| Versiones y cambios gestionados manualmente | 2 | 5.5 | 2/2 | Por mapear |

---

## Brecha por Capacidad ETB

| ETB ID | Capacidad | Sistema AXA Actual | Estado | Impacto |
|--------|-----------|-------------------|--------|---------|
| 6.3.1 | Gestión de la información del riesgo | Vector (workflow) + HSD (cálculo — GAP CRÍTICO) | PARTIAL | 🟡 Medio |
| 6.3.2 | Evaluación y tarificación del riesgo | HSD Excel — sin sistema real | GAP | 🔴 Alto |
| 6.3.3 | Modelación catastrófica | ERN (confirmado) — manual al HSD | PARTIAL | 🟡 Medio |
| 6.3.4 | Gestión de la cotización | HSD Excel + negociación por correo | GAP | 🔴 Alto |
| 6.3.5 | Negociación y colocación | Sin sistema — correo/Teams/WhatsApp | GAP | 🔴 Alto |
| 6.4 | Administración de pólizas | General Daños — recaptura manual desde slip | PARTIAL | 🟡 Medio |
| 6.5 | Gestión de reaseguro | SAFAC — solo estructura lineal | PARTIAL | 🟡 Medio |
| 4.1 | Gestión de distribución / agentes | Sin sistema confirmado | SCAFFOLD | 🟡 Medio |
| 7.1 | Gestión de siniestros | Sin sistema confirmado | SCAFFOLD | 🟡 Medio |
| 9.1 | Reportes regulatorios | Monitor (tentativo) | PARTIAL | 🟡 Medio |
| 5.1 | Analítica e inteligencia de negocio | Power BI — acceso fragmentado | PARTIAL | 🟡 Medio |
| 8.1 | Plataforma de integración | Sin sistema confirmado | SCAFFOLD | 🟡 Medio |

---

## Pain Points Detalle

### Información dispersa y herramientas no conectadas

| ID | Descripción | LoBs | Manual | Causa tecnológica | Mejora propuesta |
|----|-------------|------|--------|-------------------|------------------|
| 1.01.1 | El suscriptor debe revisar y reconciliar solicitudes, seguimientos y negociacion | 7 | Sí | El sistema no integra automáticamente la información generad | Incorporar al registro del caso la información relevante gen |
| 1.02.1 | El suscriptor debe consultar y descargar por separado la siniestralidad de cada  | 3 | Sí | La información esta fragmentada en diferentes sistemas | Dar acceso a una vista consolidada de la siniestralidad e hi |
| 1.03.1 | En el handoff entre Suscripción y Emisión, los responsables deben reconciliar ma | 7 | Sí | No hay controles que validen automáticamente que toda la inf | Validar la consistencia de slip, registros, autorizaciones y |
| 1.04.1 | El responsable debe recapturar o trasladar manualmente información entre Vector  | 8 | Sí | Las herramientas utilizadas en el proceso no cuentan de form | Permitir que los datos necesarios pasen entre Vector y los s |
| 1.04.2 | El suscriptor debe volver a capturar en la HSD información que ya está contenida | 3 | Sí | La HSD no recibe directamente la información contenida en el | Permitir reutilizar directamente en HSD la información ya di |
| 1.04.3 | El suscriptor debe trasladar manualmente los resultados de ERN a la HSD porque l | 2 | Sí | Los sistemas utilizados en el proceso no están concetados en | Permitir que los resultados de ERN puedan utilizarse directa |
| 1.04.4 | El responsable debe volver a capturar manualmente en General Daños coberturas, p | 4 | Sí | Los sistemas utilizados en el proceso no están concetados en | Permitir reutilizar en General Daños las condiciones ya defi |
| 1.05.1 | Los indicadores basados en Vector no reflejan todo el recorrido de algunos casos | 2 | No | Los reportes de tiempos y estatus utilizan principalmente la | Incorporar en los indicadores la actividad relevante que ocu |

### Reglas y controles no automatizados

| ID | Descripción | LoBs | Manual | Causa tecnológica | Mejora propuesta |
|----|-------------|------|--------|-------------------|------------------|
| 4.01.1 | La completitud y congruencia del expediente debe ser revisada manualmente antes  | 6 | Sí | No se validan automáticamente todos los requisitos que corre | Incorporar validaciones de los requisitos aplicables según p |
| 4.02.1 | El responsable debe consultar reglas, guías o referencias fuera de la herramient | 3 | No | La herramienta operativa no contiene todas las reglas que ne | Hacer disponibles dentro de la herramienta las reglas necesa |
| 4.03.1 | El suscriptor debe reunir, convertir y comparar manualmente distintas restriccio | 3 | Sí | No hay un sistema que considere todas las reglas de negocio  | Permitir evaluar en conjunto las restricciones necesarias pa |
| 4.04.1 | Las asignaciones de las aprobaciones dependiendo del facultamiento del suscripto | 5 | Sí | La herramienta no compara automáticamente el facultamiento d | Identificar cuándo se necesita una aprobación y dirigir el c |
| 4.04.2 | El suscriptor debe cotejar manualmente el slip de directo con el respaldo facult | 3 | Sí | No existe una validación automática que confirme que ambos d | Validar la consistencia entre las condiciones de directo y e |
| 4.05.1 | El emisor debe localizar, interpretar y contrastar manualmente datos legales y f | 4 | Sí | — | — |

### Sistemas inestables o con limitaciones funcionales

| ID | Descripción | LoBs | Manual | Causa tecnológica | Mejora propuesta |
|----|-------------|------|--------|-------------------|------------------|
| 7.01.2 | El analista debe transformar manualmente una colocación estructurada por capas p | 2 | Sí | SAFAC solo permite registrar la colocación bajo una estructu | Permitir registrar la colocación manteniendo la estructura p |
| 7.01.3 | El líder debe revisar manualmente la carga del equipo y redistribuir folios porq | 1 | Sí | El sistema no distribuye automáticamente los folios consider | Asignar los folios considerando carga, prioridad, urgencia y |
| 7.01.4 | El emisor debe revisar periódicamente la bandeja de Vector para identificar caso | 1 | Sí | Vector no genera una notificación al emisor cuando un caso n | Notificar al emisor cuando un caso nuevo o devuelto requiera |
| 7.01.6 | En pólizas con muchas ubicaciones, el responsable debe conciliar manualmente el  | 1 | Sí | Los cambios realizados en un registro no actualizan automáti | Mantener alineadas las altas, bajas y correcciones entre el  |
| 7.01.7 | El suscriptor debe cargar varias veces la información de un mismo caso para pode | 3 | Sí | La herramienta limita la cantidad de elementos que pueden pr | Permitir cargar en una sola vez todos los elementos que pert |
| 7.03.1 | Cada área de negocio desarrolla y mantiene herramientas propias para realizar cá | 1 | No | Las capacidades de cálculo de las herramientas oficiales no  | Ampliar la cobertura de las herramientas oficiales para aten |

### Datos incompletos o inconsistentes

| ID | Descripción | LoBs | Manual | Causa tecnológica | Mejora propuesta |
|----|-------------|------|--------|-------------------|------------------|
| 3.02.2 | El suscriptor debe realizar búsquedas con distintas variantes de razón social y  | 4 | Sí | Sistema  unicamente te permite busacr por razon social y dir | Permitir buscar y relacionar registros mediante un identific |
| 3.02.3 | El suscriptor debe reconstruir manualmente la secuencia correcta de los folios d | 2 | Sí | — | — |
| 3.02.4 | El suscriptor debe revisar y reclasificar manualmente siniestros cuando la categ | 2 | Sí | — | — |
| 3.02.5 | La solicitud puede ser canalizada a una línea de negocio o equipo incorrecto cua | 5 | Sí | El sistema no corrige automáticamente clasificaciones ambigu | Detectar datos faltantes o clasificaciones ambiguas antes de |
| 3.04.1 | Reaseguro Facultativo puede recibir una solicitud sin información técnica sufici | 2 | No | El ingreso del caso a FAC no valida automáticamente que esté | Validar la completitud antes de que FAC inicie la salida a m |

### Avance condicionado por otras áreas y terceros

| ID | Descripción | LoBs | Manual | Causa tecnológica | Mejora propuesta |
|----|-------------|------|--------|-------------------|------------------|
| 5.01.1 | El responsable debe solicitar y dar seguimiento a faltantes, aclaraciones y corr | 5 | No | El canal existente (Vector) no es la unica fuente de la verd | Concentrar en el registro del caso la información necesaria  |
| 5.01.2 | El emisor recibe documentación de Art. 492 incompleta y no puede continuar hasta | 0 | No | No hay un control de completitud del Art. 492 | Validar la completitud de Art. 492 antes de transferir el ex |
| 5.01.3 | No todos los usuarios pueden generar directamente el folio en Vector, por lo que | 4 | No | — | — |
| 5.03.1 | No existe una vista única del estado de las gestiones con otras áreas, terceros  | 4 | No | Las herramientas internas no actualizan automáticamente el a | Dar visibilidad en un mismo punto al estado actualizado de l |

### Datos y documentos que requieren preparación manual

| ID | Descripción | LoBs | Manual | Causa tecnológica | Mejora propuesta |
|----|-------------|------|--------|-------------------|------------------|
| 2.01.1 | El responsable debe descargar, clasificar y ordenar manualmente archivos de dist | 3 | Sí | — | — |
| 2.02.1 | El suscriptor debe construir o adaptar manualmente el documento de propuesta -sl | 6 | Sí | El documento de propuesta no se genera automaticamente a par | Permitir generar la propuesta a partir de las condiciones ap |

### Versiones y cambios gestionados manualmente

| ID | Descripción | LoBs | Manual | Causa tecnológica | Mejora propuesta |
|----|-------------|------|--------|-------------------|------------------|
| 6.01.1 | El suscriptor debe identificar manualmente cuál es la versión vigente de la prop | 6 | Sí | El repositorio conserva documentos, pero no concentra los ac | Mantener un historial de versiones que permita identificar c |
| 6.02.1 | Cuando cambia una condición negociada, el suscriptor debe identificar y repetir  | 5 | Sí | Son varios sistemas involucrados que están fragmentados y qu | Permitir que un cambio se refleje en los cálculos y registro |

---

*Generado por build-gap-analysis.py el 2026-09-03*