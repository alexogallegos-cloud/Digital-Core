# Registro de Riesgos — AppMovil BanCoppel
> **DT**: dt-riesgos · **Proyecto**: `SPE-AM-001` · **Canal**: AppMovil (togaf_type: channels)
> **Versión**: 1.0.0 · **Fecha**: 2026-11-04 · **Fase**: DISCOVER
> **Fuente de evidencia**: `brain.db::incidents`, 16 incidentes de enero al 2 de noviembre de 2026
> **Constraint activo**: viabilidad 2027

---

## Para qué sirve este documento

El registro preliminar de `dt-riesgos` se escribió en agosto como un ejercicio de anticipación: catorce riesgos deducidos de la arquitectura del canal, sin evidencia de que alguno hubiera ocurrido. Este documento cierra esa brecha. Cruza esos catorce contra los **dieciséis incidentes reales originados por Controles de Cambio** que los reportes corporativos documentan entre enero y noviembre de 2026, ocho de los cuales tocaron el canal móvil.

El resultado cambia la conversación. Cinco de los riesgos ya no son hipótesis: ocurrieron en producción, con folio, cronología y RCA. Dos se matizan a la luz de lo que pasó. Y los incidentes revelan tres mecanismos que el registro no contemplaba.

Un riesgo con evidencia se prioriza distinto a uno deducido, y eso es lo que este cruce aporta.

---

## 1. Riesgos que ya se materializaron

Cinco riesgos del registro preliminar ocurrieron durante el periodo analizado. Para cada uno, la evidencia que lo confirma.

### RISK-ARCH-002 — Plataforma de despliegue, de MEDIA a ALTA

El registro lo planteaba como una duda sobre la disponibilidad de OpenShift en el entorno destino. Lo que ocurrió es más inmediato: **la cuota de la plataforma bloqueó dos ventanas de cambio del canal**, y en ambas hubo que intervenir infraestructura en vivo.

El 7 de julio, el CC 175389 falló en parte por falta de pre-aprobación de cuota en los clústeres B3 y Rosa, lo que obligó a escalar servicios a cero hasta corregir. El 25 de agosto, el CC 176501 superó el límite configurado de cinco pods en OpenShift v3, y el bloqueo alcanzó a cuatro microservicios del canal más el componente Fuse `bsi-bex-deposits-rhbc-api`. La ventana de mantenimiento quedó detenida hasta que Infraestructura retiró la restricción.

La lectura para la migración es que el dimensionamiento de cuota no es un detalle de operación sino una precondición de cualquier ventana. Si hoy bloquea un despliegue rutinario, bloqueará una ola de migración que mueve decenas de microservicios a la vez.

### RISK-CHAN-001 — Bandera activada en caliente, de ALTA a CRÍTICA

El registro proponía banderas de funcionalidad y lanzamiento oscuro como **mitigación** del riesgo de convivencia de versiones. El incidente del 15 de septiembre muestra que la propia bandera es un vector de riesgo si se activa sin prueba de estrés.

A las 10:30 se encendió `ppc_active_flag` en el módulo de préstamos. Los tiempos de respuesta se degradaron de forma crítica y hubo errores masivos. La contención exigió aplicar diques de tráfico al ochenta y al noventa por ciento, y el canal no se recuperó hasta que la bandera se apagó a las 13:29. Casi tres horas de afectación.

La mitigación que el registro proponía necesita su propio control: una bandera que enciende carga sobre un flujo no probado es un cambio en producción, no un interruptor de seguridad.

### RISK-DATA-001 — Configuración externalizada, confirmado

El registro anticipaba que configuración no migrada tiraría el canal en silencio. El mecanismo real resultó más prosaico y más frecuente: **errores humanos al preparar la configuración**.

En el CC 175389 se ingresó el selector de MQ directo en lugar de la variable de secreto, y se introdujeron saltos de línea al codificar en base64. Los ConfigMaps y Secretos mal formados provocaron reinicios continuos de pods. Es el mecanismo más repetido de todo el corpus: cinco de los dieciséis incidentes son de configuración y sintaxis.

Es también el más automatizable, y por eso el de mejor relación entre esfuerzo y riesgo evitado.

### RISK-JDBC-003 — Degradación de consultas, confirmado en su forma inversa

El registro anticipaba que el SP de Informix fuera más lento en el destino. Lo que ocurrió el 26 de agosto es el espejo: **un cambio estructural en las tablas de movimientos de Intercard elevó el costo de las consultas que el canal consume**, sin que el canal cambiara una línea.

El RCA fue explícito en la causa de fondo: las validaciones de desempeño preproductivas no simularon el volumen ni el patrón real de la App. El canal fue víctima de un cambio ajeno.

Esto obliga a ampliar el riesgo. No basta con medir el desempeño de los SPs que el canal invoca cuando el canal cambia; hay que medirlo cuando cambia la base, porque el acoplamiento es bidireccional y el canal no se entera.

### RISK-OPS-001 — Observabilidad, confirmado por omisión

El registro pedía definir SLOs y alertas desde la construcción. El corpus muestra por qué: en el incidente del 8 de octubre la pérdida de conectividad con la base OLTP afectó al canal junto con SPEI, sucursales y cajeros, y el RCA cerró manteniendo hipótesis técnicas por validar. En siete de los dieciséis incidentes el folio del Control de Cambios no quedó visible en la evidencia.

Cuando la trazabilidad falla, la causa se vuelve una conjetura y el aprendizaje se pierde.

---

## 2. Riesgos que se matizan

### RISK-OPS-002 — El rollback funciona, pero no es el que preocupa

El registro daba por riesgo que el rollback no estuviera probado. La evidencia muestra lo contrario en la operación cotidiana: **cinco incidentes se resolvieron revirtiendo el cambio**, y en todos la recuperación se confirmó. El del 14 de octubre, con Préstamos Digitales sin autorizar en el canal ONE CLICK, se cerró con un rollback directo al CC 177739.

El matiz importa. Revertir un Control de Cambios acotado es rutina probada. Revertir una ola de migración que ya movió datos y tráfico es otra cosa, y de eso el corpus no dice nada. El riesgo sigue abierto, pero su redacción debe distinguir ambos casos en lugar de apoyarse en una supuesta falta de práctica que la evidencia no respalda.

### RISK-ARCH-001 — Librerías propias, sin evidencia en este corpus

Ninguno de los dieciséis incidentes se originó en las librerías internas de BanCoppel. Eso no reduce el riesgo de migración, que sigue siendo alto por su alcance (`msach-u-aop-commons` está en 209 de 215 microservicios), pero conviene no inflarlo con evidencia que no existe: es un riesgo de migración, no un problema operativo actual.

---

## 3. Riesgos nuevos que la evidencia revela

Tres mecanismos aparecen en los incidentes y no estaban en el registro preliminar.

| ID | Riesgo | Categoría | Probabilidad | Impacto | Evidencia |
|----|--------|-----------|-------------|---------|-----------|
| RISK-OPS-003 | La inyección de secretos y configuración se hace a mano, y el error de sintaxis llega a producción | Operación | ALTA | ALTO | CC 175389, más cinco incidentes de configuración en el corpus |
| RISK-OPS-004 | Un cambio en un sistema vecino degrada el canal sin que el canal cambie ni se entere | Operación | ALTA | ALTO | CC 176699 en Intercard; incidentes 3997149 y 3998011 en la base OLTP |
| RISK-OPS-005 | Ante una degradación inducida por un cambio, el único control disponible es contener tráfico con diques | Operación | MEDIA | ALTO | Incidente 3899131, diques al ochenta y al noventa por ciento durante casi tres horas |

**RISK-OPS-003** es el de mejor retorno. Automatizar la generación de ConfigMaps y Secretos elimina de raíz el mecanismo más frecuente del corpus, y no depende de ninguna decisión de arquitectura.

**RISK-OPS-004** es el más incómodo para la migración, porque el canal no controla su mitigación. Exige que las pruebas de desempeño de cambios en Intercard y en la base OLTP incluyan el patrón de consumo del canal móvil, lo que es una conversación con los dueños de esos sistemas y no una tarea del equipo del canal.

**RISK-OPS-005** señala una carencia de mecanismos de contención finos. Los diques de tráfico son un instrumento grueso: protegen la plataforma degradando el servicio a una parte de los clientes.

---

## 4. Cuadro de materialización

| Riesgo preliminar | Estado tras la evidencia | Incidentes que lo sustentan |
|-------------------|--------------------------|------------------------------|
| RISK-ARCH-002 | **Materializado dos veces** | `INC-CC-20260707-3519622`, `INC-CC-20260825-3800254` |
| RISK-CHAN-001 | **Materializado**, la mitigación es también vector | `INC-CC-20260915-3899131` |
| RISK-DATA-001 | **Materializado**, mecanismo más frecuente | `INC-CC-20260707-3519622` y cuatro más de configuración |
| RISK-JDBC-003 | **Materializado en forma inversa** | `INC-CC-20260826-176699` |
| RISK-OPS-001 | **Confirmado por omisión** | `INC-CC-20261008-3997149`, siete incidentes sin folio de CC |
| RISK-OPS-002 | **Matizado**, el rollback de CC sí está probado | Cinco incidentes resueltos con rollback |
| RISK-ARCH-001 | Sin evidencia en este corpus | Ninguno |
| RISK-JDBC-001, RISK-JDBC-002 | Sin evidencia, siguen como hipótesis de migración | Ninguno |
| RISK-CHAN-002, RISK-CHAN-003 | Sin evidencia, siguen como hipótesis de migración | Ninguno |
| RISK-REG-001, RISK-REG-002, RISK-REG-003 | Sin evidencia, siguen como hipótesis de migración | Ninguno |
| RISK-DATA-001 (sesiones) | Sin evidencia | Ninguno |
| RISK-OPS-002 (migración) | Abierto, el corpus no lo cubre | Ninguno |

---

## 5. Qué debería ser bloqueante antes de una ola de migración

De la evidencia se desprenden cuatro condiciones de entrada, todas con un incidente detrás que las justifica.

La **cuota y capacidad del clúster** se valida y se pre-aprueba antes de abrir la ventana, no durante. Dos incidentes se detuvieron por esto.

La **generación de ConfigMaps y Secretos** se automatiza, sin preparación manual de base64 ni de selectores. Es el mecanismo más frecuente del corpus.

Las **pruebas de desempeño** usan volumen y patrón de consumo reales del canal, y se aplican también cuando el cambio es de un sistema vecino. El caso de Intercard muestra que el canal se degrada sin participar en el cambio.

La **activación de banderas** pasa por prueba de estrés previa y trae un plan de reversión más fino que contener tráfico. Casi tres horas de degradación con diques es un costo alto para un interruptor.

---

## 6. Trazabilidad

Los dieciséis incidentes viven en `brain.db::incidents` y se consultan en la vista `portal/incidentes-cc.html`. El recorrido completo es:

```
source/docs/*.docx                        los dos reportes corporativos
  -> generators/extract-incidents.py      normaliza y fusiona los dos reportes
  -> knowledge-base/incidentes-cc.json    la fuente estructurada
  -> generators/load-incidents.py         brain.db::incidents
  -> generators/build-incidents-portal.py portal/incidentes-cc.html
```

Las fuentes corporativas que los reportes citan son el seguimiento de incidentes mayores, los RCA de separación de tablas de movimientos, cajeros propios, eGlobal y el incidente 3997149, los comités operativos de septiembre y octubre, y las bitácoras de Command Center.

---

## 7. Smoke tests

| ID | Test | Estado |
|----|------|--------|
| RG-01 | `registro-riesgos-appmovil.md` existe | Pasa |
| RG-02 | Cada riesgo materializado cita el incidente que lo sustenta | Pasa |
| RG-03 | Los riesgos sin evidencia se declaran como tales y no se inflan | Pasa |
| RG-04 | Los riesgos nuevos derivan de incidentes del corpus, no de deducción | Pasa |
| RG-05 | La trazabilidad del dato llega hasta el documento origen | Pasa |

---

*v1.0.0 · 2026-11-04 · Construido por dt-riesgos cruzando el registro preliminar de agosto contra los 16 incidentes de Control de Cambios cargados en el brain. Cinco riesgos pasan de hipótesis a evidencia, dos se matizan y tres son nuevos.*
