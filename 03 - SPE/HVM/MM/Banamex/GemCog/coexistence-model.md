# Modelo de Coexistencia — Banamex S500+S151 → Target
> Artefacto P0 MANIFEST · Gobernanza de parallel-run y sincronización de datos
> Versión: v0.1-DRAFT · 2026-07-21 · GemCog Capa 5 — Fronteras y Wave Map
> Owner: Specialist - 7R Assessment · Advisory: Mainframe Migration SME + Regulatory SME

---

## 1. Principio de coexistencia

La migración de S500+S151 opera bajo el principio de fuente de verdad única y transferible: en todo momento existe un único System of Record (SoR) por dominio de dato, y ese rol pasa del sistema legacy al sistema target en el momento del cutover de cada wave, no antes. Hasta que un wave concluye su parallel-run y el Comité de Migración emite la aceptación formal, el SoR permanece en Unisys ClearPath MCP.

**Definición de SoR por wave y por dato:**

| Dominio de dato | SoR durante Wave 0–2 | SoR desde Wave 3 | Fuente física |
|-----------------|----------------------|-------------------|---------------|
| Movimientos contables GL | S151 legacy (DMSII) | BC-05 General Ledger target | BD10 Transaction Register |
| Saldos GL por producto/instrumento/moneda | S151 legacy (DMSII) | BC-05 target | BD11 B72POSCONTA |
| Contratos de captación | S500 legacy (DMSII) | BC-01 target (post Wave 2) | BD01/BD02/BD03 |
| Asientos PeopleSoft (SETID=BNMEX) | P131→S254 legacy | BC-05 target (post Wave 3) | S254 externo |
| Datos de cliente (nombre, RFC, CURP) | S016 (externo, no migrado) | S016 → Customer Profile API | L422 |

**Regla de desempate ante divergencia entre sistemas:** si durante el parallel-run los saldos del target difieren de los de DMSII, la cifra de DMSII prevalece como correcta y el target debe explicar la diferencia. No existe excepción a esta regla. Toda divergencia que no tenga causa raíz documentada dentro de las 4 horas siguientes a su detección congela el avance del wave en curso.

---

## 2. Modelo de sincronización por wave

**Wave 0-A — BC-04 ACL (S151REGISTRA encapsulado)**

Los datos que fluyen en esta wave son exclusivamente los asientos que S500 escribe en S151 vía la biblioteca S151REGISTRA (L002R2-R5). El ACL target recibe las llamadas del legacy S500 sin cambios en el contrato de interfaz y las reenvía al GL legacy de S151. No hay escritura directa al target GL. La divergencia se detecta comparando los contadores de asientos aceptados por S151REGISTRA en ambos entornos al cierre de cada lote. La tolerancia es cero: cualquier discrepancia de un solo asiento detiene el wave. La resolución es automática si el delta es de reordenamiento sin diferencia de monto; requiere intervención humana si hay diferencia de monto o de número de registros.

**Wave 0-B — S151-Platform-Services (L030)**

L030 es la librería maestra de la que dependen en runtime todos los programas S151. Los seis microservicios de plataforma que la reemplazan (sistema-fechas, catálogo-transacciones, control-batch, consulta-movimientos, estructura-organizacional, cliente-enrichment) deben estar disponibles como servicios activos antes de que cualquier programa S151 del target pueda ejecutarse. Esta wave no tiene parallel-run propio: es un prerrequisito de habilitación tecnológica. La sincronización se verifica mediante smoke-tests al inicio de cada jornada operativa.

**Wave 1 — BC-02, BC-03, BC-09 (bajo riesgo)**

Estos bounded contexts leen del GL legacy y del ODS legacy pero no son fuente de asientos primarios. Los datos fluyen en sentido legacy→target para consulta y reporting. La divergencia se detecta con reconciliación de contadores de registros procesados al cierre del batch nocturno. El tiempo máximo de tolerancia de divergencia es de un ciclo de batch (24 horas). La resolución es automática cuando la diferencia es inferior al 0.001% del total de registros; requiere intervención del equipo de operaciones cuando supera ese umbral.

**Wave 2 — BC-01, BC-06 parcial, BC-08**

En esta wave el flujo de datos es bidireccional: BC-01 recibe transacciones nuevas y escribe a S151 legacy vía el ACL de BC-04. El target aún no es SoR de contratos. La reconciliación se hace comparando los totales de cargos y abonos del día entre el registro batch de S500 y el log de BC-01. La tolerancia de divergencia es de 4 horas para diferencias menores a 0.01% del volumen diario y de cero horas para diferencias absolutas superiores a MXN 1,000. La intervención humana es obligatoria en el segundo caso.

**Wave 3 — BC-05 General Ledger (corte definitivo)**

Esta wave requiere un parallel-run mínimo de 3 meses calendario con los alimentadores de Wave 2 activos y validados. Durante el parallel-run, BC-05 produce asientos en paralelo al motor P109 legacy, pero BD10 y BD11 en DMSII continúan siendo el SoR. La divergencia se detecta comparando diariamente la identidad contable SDOACT = SDOANT + CARGOS - ABONOS entre el GL legacy y el GL target por cada dimensión (FILIAL · ORIGEN · MONEDA · BANCO · SUC-PROM · FECVEN · PRODUCTO · INSTRUMENTO · SECTOR · CVETRAN · ESQCON). La tolerancia es cero en montos netos diarios. La resolución siempre requiere intervención del equipo de Contabilidad Corporativa.

---

## 3. Control mutex — Interfaces Citi

El riesgo de doble contabilidad más crítico del sistema surge de la coexistencia de dos rutas de salida activas hacia Citi y hacia S254 PeopleSoft durante la transición:

- **SCIG** (generado por P109 hacia Citi) es la ruta legacy de envío de movimientos GL al grupo Citi. Activa en producción hoy.
- **PAQUETECONTABLE** (generado por P131 → S254, SETID=BNMEX) es la ruta de envío hacia PeopleSoft GL como entidad separada Banamex. También activa en producción hoy.

Ambas rutas pueden estar activas simultáneamente durante la transición Citi/Banamex. Si un asiento se procesa por las dos rutas, el GL de PeopleSoft recibe el mismo movimiento dos veces, produciendo doble contabilidad con impacto directo en los reportes Serie B de la CNBV.

**Mecanismo de control mutex:**

La desactivación de SCIG debe ejecutarse mediante una variable de configuración de ambiente en el programa P109, no mediante modificación de código fuente. El prerequisito es confirmar con el equipo de Citi que el corte de la alimentación SCIG no afecta ningún proceso de conciliación de grupo que aún esté vigente en la fecha de desconexión. La activación de PAQUETECONTABLE debe mantenerse inalterada hasta que el GL target (BC-05) sea el SoR definitivo.

**Condición de activación/desactivación:**

| Evento | Acción | Responsable |
|--------|--------|-------------|
| Inicio Wave 2 | Confirmar con Citi la fecha de corte de SCIG | Regulatory SME + Legal |
| Gate de entrada Wave 3 | Desactivar SCIG vía parámetro de ambiente en P109 | Mainframe Migration SME |
| Cutover Wave 3 | Redirigir PAQUETECONTABLE al BC-05 target; desactivar P131 legacy | Mainframe Migration SME |

**Fecha objetivo de desconexión SCIG:** por determinar — depende de la fecha de corte legal Citi/Banamex. Este punto debe quedar fijado como prerequisito absoluto del gate de entrada a Wave 3, con confirmación escrita del equipo jurídico de la separación.

Las interfaces P150 (BRANCH=484) y P151 (BRCH-NBR=485) hacia el sistema IBM-Citi (ALR/AHR/OCM) deben desconectarse explícitamente en el mismo gate de Wave 3. La ambigüedad semántica de los valores 484 y 485 (riesgo MR-INT-01) debe resolverse mediante validación con el equipo Citi antes de ese gate, no durante el cutover.

---

## 4. Parallel-run operacional

**Reconciliación diaria:**

El equipo de operaciones ejecuta cada mañana, antes de las 07:00 horas, un proceso de reconciliación automática que compara los totales de BD10 (Transaction Register) y BD11 (B72POSCONTA) del sistema legacy contra los registros equivalentes del sistema target. El proceso genera un reporte de reconciliación firmado digitalmente que debe ser revisado y aceptado por el Controller de Migración antes de autorizar la apertura operativa del día.

Los archivos de referencia para la reconciliación son: el dump nocturno de BD10 y BD11, el log de asientos del BC-05 target (cuando esté activo), y el archivo de control del WFL CICLODIA.

**Criterios de divergencia:**

| Tipo de divergencia | Umbral aceptable | Consecuencia |
|--------------------|-----------------|--------------|
| Diferencia de cantidad de movimientos | 0 registros | Pausa inmediata del wave |
| Diferencia de monto neto diario (MXN) | 0.00 | Pausa inmediata del wave |
| Diferencia de monto en posición acumulada (BD11) | 0.00 | Escalada a Dirección de Tecnología |
| Retraso en procesamiento de lote | Máximo 15 minutos sobre ventana batch | Alerta de capacidad |

**Proceso de escalada:** si la reconciliación detecta una divergencia que supera el umbral aceptable, el Controller de Migración notifica en los siguientes 30 minutos al Arquitecto Líder, al Director de Operaciones y al Regulatory SME. Si en 4 horas no existe causa raíz documentada y plan de remediación, el Comité de Migración decide si revertir el wave o continuar con restricciones de operación. El retroceso de wave es reversible hasta que se emite la aceptación formal del cutover.

---

## 5. Gates de coexistencia por wave

| Wave | Criterio de entrada a parallel-run | Criterio de salida (cutover) | Responsable |
|------|-------------------------------------|------------------------------|-------------|
| 0-A (BC-04 ACL) | S151REGISTRA target pasa suite de pruebas de equivalencia al 100% con datos golden-master | Cero divergencias en 5 días operativos consecutivos de parallel-run | Mainframe Migration SME |
| 0-B (L030 Platform Services) | Los 6 microservicios de plataforma pasan smoke-tests + pruebas de carga equivalente al pico de volumen S151 | Disponibilidad ≥ 99.9% en 10 días consecutivos | Mainframe Migration SME |
| 1 (BC-02, BC-03, BC-09) | Dependencias de Wave 0 aceptadas; stubs de S084 disponibles | Reconciliación de contadores al 100% en 10 días operativos | Specialist - 7R Assessment |
| 2 (BC-01, BC-06, BC-08) | SETID=BNMEX parametrizado y confirmado con PeopleSoft; Customer Profile API de S016 disponible; certificación ICA/CECOBAN completa | Reconciliación diaria cero-diferencia en 15 días operativos | Mainframe Migration SME + Regulatory SME |
| 3 (BC-05 GL) | SCIG desconectado; P150/P151 interfaces Citi desconectadas; 3 meses de parallel-run con alimentadores Wave 2; identidad contable validada 11 dimensiones | Cero diferencias en posición acumulada BD11 vs GL target en 20 días operativos; aprobación Contabilidad Corporativa | Comité de Migración |

---

## 6. Riesgos de coexistencia activos

**Doble contabilidad SCIG + PAQUETECONTABLE (CRÍTICO):** el riesgo se materializa si ambas rutas permanecen activas simultáneamente para los mismos asientos GL. El control mutex descrito en la sección 3 es el único mecanismo de mitigación. Sin una fecha de corte legal Citi/Banamex confirmada, este riesgo no tiene fecha de cierre.

**COPIA-5 WAIT 1200s incompatible con arquitectura event-driven:** el mecanismo I11-REPLICA en S500 replica movimientos SPEI entre nodos VDM y MTY con una espera activa de 1,200 segundos. En la arquitectura target cloud-native, esta semántica de espera activa no existe. Si el target intenta replicar este patrón mediante un consumer de eventos con timeout equivalente, el umbral de 20 minutos puede ser inaceptable para los SLOs de SPEI en tiempo real. La decisión de arquitectura debe quedar formalizada como ADR antes de Wave 1.

**BD10 y BD11 como única fuente de verdad contable durante transición:** durante todas las waves anteriores a Wave 3, BD10 (Transaction Register) y BD11 (B72POSCONTA) en DMSII son los únicos registros contables aceptados como definitivos. Cualquier proceso del sistema target que modifique estos archivos directamente sin pasar por el motor P109 legacy introduce un riesgo de corrupción de la fuente de verdad. Está prohibido el acceso de escritura directo de componentes target a BD10 y BD11 hasta el cutover de Wave 3.

**Fallo silencioso S016 en datos de cliente:** cuando P050 llama a L422(S016) para obtener el nombre del cliente y S016 devuelve SPACES, el programa continúa sin error ni alerta, usando el campo en blanco. Este comportamiento no cambia durante la coexistencia. El Customer Profile API que reemplace a L422 en el target debe implementar un fallo explícito ante respuesta vacía, no replicar el silencio del legado. Durante el parallel-run de Wave 2, el equipo de QA debe incluir un caso de prueba específico para SPACES en datos de cliente que valide que el comportamiento del target es auditable.

---

## 7. Plan de comunicación a CNBV

La migración de los sistemas S500+S151 de Banamex implica cambios en los mecanismos de generación de reportes regulatorios que pueden requerir notificación a la CNBV bajo las Disposiciones de Carácter General aplicables a las instituciones de crédito.

Los eventos que activan comunicación obligatoria son los siguientes. Primero, el inicio del parallel-run de Wave 3 (BC-05 GL), dado que durante ese período los asientos contables que alimentan los reportes Serie B se generan en dos sistemas simultáneamente. Segundo, el cutover de Wave 3, que implica el cambio del sistema de generación de reportes R04C y R27C CNBV del motor P131 legacy al servicio equivalente target. Tercero, cualquier corrección de defecto activo con impacto regulatorio (en particular MR-RPT-01, el bug del reporte SAR con saldo anterior INFONAVIT incorrecto desde 1991) debe notificarse antes de que el target implemente la corrección, dado que la cifra histórica reportada a Banxico e INFONAVIT diferirá.

La Circular aplicable para notificación de cambios en sistemas de procesamiento es la Circular Única de Bancos (CUB), Título Décimo Tercero, Disposiciones de carácter general sobre los requerimientos mínimos de administración de riesgos tecnológicos. El Regulatory SME confirmará el alcance exacto de la notificación y si se requiere comunicación adicional bajo el Artículo 52 de la Ley de Instituciones de Crédito (cambios en sistemas de procesamiento de información que afecten el cumplimiento de la normativa).

El calendario de comunicaciones regulatorias debe quedar definido como prerequisito del gate de entrada a Wave 2, con al menos 60 días de anticipación antes del inicio del parallel-run de Wave 3.

---

## Metadata

| Campo | Valor |
|-------|-------|
| Generado | 2026-07-21 |
| Owner | Specialist - 7R Assessment |
| Advisory | Mainframe Migration SME · Regulatory SME |
| Estado | v0.1-DRAFT — pendiente de revisión por Comité de Migración |
| Indexado en MANIFEST | Pendiente — activar al pasar a v1.0 |
| Referencias canónicas | kb-capa5-fronteras.md · migration-risk-register.md · integration-map.md · equivalencia-strategy.md |
| Próxima revisión | Al cierre de Wave 0-A (gate de cutover) |
| Riesgos relacionados | MR-GL-09 · MR-ORC-01 · MR-RPT-01 · MR-INT-01 · MR-CFR-01 · MR-ADJ-02 |
