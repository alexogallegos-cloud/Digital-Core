# Evaluación de Impacto Regulatorio — Banamex S500+S151 Modernización
> Artefacto P0 MANIFEST · CNBV · Banxico · SAT · CONDUSEF · IPAB
> Versión: v0.1-DRAFT · 2026-07-21 · GemCog Capa 5 — Fronteras y Wave Map
> Owner: Specialist - 7R Assessment · Advisory: Regulatory SME + Mainframe Migration SME

---

## 1. Alcance regulatorio del proyecto

El proyecto de modernización de S500 (Cargos y Abonos de Cuentas de Cheque) y S151 (Movimientos Contables General Ledger), actualmente operando sobre Unisys ClearPath MCP / DMSII, involucra la migración de los dos sistemas que producen prácticamente la totalidad de los reportes regulatorios de la institución. S151 es el motor de asientos del General Ledger y S500 es el sistema de captación que origina todos los movimientos de cuentas de cheque. La modernización de estos dos sistemas tiene impacto directo sobre la capacidad del banco para cumplir en tiempo y forma con sus obligaciones ante la CNBV, Banxico, SAT, IPAB y CONDUSEF.

El principio rector de este proyecto, desde la perspectiva regulatoria, es que la modernización no debe degradar ni interrumpir la generación de reportes regulatorios en ningún momento del proceso, incluyendo las fases de operación en paralelo. Cualquier diferencia entre el sistema legado y el sistema modernizado en los outputs regulatorios debe ser identificada, documentada y resuelta antes del corte definitivo. La tolerancia a la discrepancia regulatoria durante el parallel-run es cero: los reportes legales deben emitirse desde el sistema legado hasta que el regulador correspondiente haya aceptado formalmente la equivalencia del nuevo sistema.

La separación Citi/Banamex introduce una dimensión adicional de riesgo regulatorio: varias interfaces de reporte que hoy circulan a través de la infraestructura de Citi —en particular los reportes CUIF R01-R04 vía P150/P151 y las interfaces ALR/AHR/OCM— deberán ser absorbidas por infraestructura propia de Banamex antes o en paralelo con la modernización. La resolución de estos canales es un prerequisito no negociable del Wave 0 del plan de migración, anterior a cualquier transpilación de código.

---

## 2. Inventario de reportes regulatorios afectados

La tabla siguiente lista todos los reportes regulatorios identificados en el análisis GemCog de S500+S151. La columna "Wave de riesgo" indica en cuál wave de migración el reporte corre mayor riesgo de verse afectado si no se toman las medidas de mitigación correspondientes.

| Reporte | Regulador | Programa MCP | Periodicidad | Deadline | Impacto del proyecto | Wave de riesgo |
|---------|-----------|-------------|-------------|---------|---------------------|----------------|
| Serie B — B-0111A (Balances) | CNBV | P130 AGRUPADOR, P131 TRADUCTOR, S254 PeopleSoft | Diario (datos) / Mensual (cierre) | Día hábil siguiente | Alto — pipeline CFR con 9 catálogos hard-linked; SETID="BNMEX" en 14 ocurrencias de P131; bug sector 15/11 en P108 afecta clasificación | Wave 2 (BC-08 Reportería GL) |
| Serie B — B-0111B (Movimientos) | CNBV | P130, P131, S254 | Diario | Día hábil siguiente | Alto — mismo pipeline CFR; desvíos A-H sin corrección pueden modificar movimientos reportados; loop CONSEC genera N pares por movimiento | Wave 2 (BC-08) |
| CUIF R01 — ALR (Account Ledger Report) | CNBV | P150, P151 (interfaz IBM-Citi) | Diario | T+1 | Crítico — interfaz operada actualmente por Citi; BRANCH=484 hardcoded en P150; ambigüedad del valor 485 en P151 (MR-INT-01); sin documentación post-separación | Wave 0 (prerequisito separación Citi) |
| CUIF R02 — AHR (Account History Report) | CNBV | P150, P151 | Diario | T+1 | Crítico — misma interfaz Citi; dependencia directa de infraestructura no propia | Wave 0 |
| CUIF R03 | CNBV | P150, P151 | Mensual | Día 15 del mes siguiente | Crítico — sin documentación del formato ni del canal de entrega post-separación | Wave 0 |
| CUIF R04 | CNBV | P150, P151 | Mensual | Día 15 del mes siguiente | Crítico — igual que R03; decisión pendiente con equipo Citi | Wave 0 |
| Concentración SAR — IMSS, ISSSTE, INFONAVIT | Banxico / INFONAVIT | P120 EXTRACTOR (1,318 LOC, 1991) | Diario | 10 días hábiles del mes siguiente | Crítico — MR-RPT-01: bug activo desde 1991; ANT-INFO (saldo anterior INFONAVIT) siempre reporta cero; ANT-ISTE inflado con INFONAVIT mezclado | Wave 2 (BC-08) |
| Reporte CECOBAN / ICA (TANDEM interbancario) | Banxico / CECOBAN | P610 F09 (CALLLIBCTL) | Diario | Cierre del día hábil | Alto — APL-ORI=0236 y APL-DES=0264 hardcoded; protocolo TANDEM propietario Unisys; ruta XFER sin equivalente cloud certificado por CECOBAN | Wave 3 (BC-08 batch) |
| Captación asegurada | IPAB | P142, P144 (reconciliación B01, B03) | Mensual | Día 15 del mes siguiente | Medio — MR-DEP-01: error código 99 ambiguo en P142 (saturación vs. error DMSII); BIT-ACTBANDERA puede omitir contratos cross-CSI | Wave 2 (BC-01 Captación) |
| Retenciones ISR e IVA | SAT | P020 | Mensual | Día 17 del mes siguiente | Alto — tasas de retención hardcodeadas en código fuente; cambio de tasa SAT requiere recompilación y despliegue coordinado | Wave 2 (BC-01) |
| INTELAR CNBV (PROTECCOB, ALERTANOT, DOMICILIA) | CNBV | P671 (diciembre 2024) | Diario / tiempo real | Tiempo real | Medio — programa más reciente de la serie (creado dic. 2024); CLABE 18 dígitos; contrato CSV INTELAR con código de canal "15110S01" hardcoded | Wave 2 (BC-08) |
| FraudLink CNBV (S500B07MOVDIA) | CNBV | P103 FraudLink | Diario | Día hábil siguiente | Alto — MR-CMP-02 y MR-CMP-03: límites hardcoded de 5 sub-movimientos SAD y 10 claves B13; reporte puede llegar truncado a CNBV sin advertencia | Wave 2 (CMP) |
| Asientos GL con sector CNBV | CNBV | P108 GL Bitácora | Diario | Cierre del día | Alto — bug activo: sector CNBV 15 mapeado a 11 en P108; asientos contables con sector incorrecto en Serie B histórica; impacto no cuantificado | Wave 3 (BC-05 GL) |

---

## 3. Obligaciones de notificación — Circular 29/2010 CNBV

La Circular 29/2010 de la CNBV, hoy incorporada en los artículos 56 y 57 de la Circular Única de Bancos (CUB), establece que toda institución de banca múltiple debe notificar a la CNBV con al menos treinta días hábiles de anticipación cualquier cambio material en sus sistemas tecnológicos que pudiera afectar la integridad, confidencialidad, disponibilidad o continuidad de los servicios financieros o de la información regulatoria. La migración de S500+S151 califica como cambio material bajo todos estos criterios: modifica la plataforma core de captación y el General Ledger contable, altera los mecanismos de producción de reportes regulatorios Serie B, y cambia la infraestructura de trazabilidad de operaciones sujetas a supervisión.

Un cambio es "material" bajo la Circular cuando: modifica la lógica de producción de reportes regulatorios, altera los mecanismos de control interno sobre la contabilidad, cambia la plataforma tecnológica de un sistema core, o afecta la trazabilidad de operaciones sujetas a reporte. La migración de S151 cumple todas estas condiciones simultáneamente, y S500 las cumple en cuanto a captación y pagos.

La notificación a la CNBV debe incluir, como mínimo: descripción técnica del cambio y justificación del proyecto; análisis de riesgos con identificación de los reportes regulatorios afectados y su nivel de impacto; plan de pruebas con criterios de equivalencia funcional medibles; plan de parallel-run con mecanismo de comparación de outputs entre sistema legado y sistema modernizado; plan de rollback con RTO y RPO definidos; e identificación del responsable regulatorio del proyecto con facultades suficientes para comprometer a la institución.

La CNBV puede solicitar aclaraciones o imponer condicionantes adicionales dentro de los veinte días hábiles siguientes a la recepción de la notificación. No existe mecanismo de "aprobación silenciosa": el banco no debe proceder con el go-live de ningún wave que afecte reportes regulatorios hasta recibir acuse de recibo formal o confirmación expresa. Para el Wave 3 (General Ledger), el gate de salida incluye explícitamente la notificación a CNBV con al menos treinta días de anticipación al cutover, conforme a los gates definidos en el plan de migración de kb-capa5-fronteras.md.

La Circular también exige que el banco mantenga, durante todo el período de parallel-run, registros completos de las diferencias entre ambos sistemas y la evidencia de cómo fueron resueltas. Para la Serie B específicamente, la CNBV exige que los reportes B-0111A y B-0111B sean conciliados mes a mes durante el parallel-run, y que cualquier diferencia que supere el umbral de materialidad definido internamente por la institución sea explicada y corregida antes del corte.

---

## 4. Hallazgos regulatorios pre-existentes que requieren resolución antes de migrar

El análisis GemCog identificó cuatro hallazgos con impacto regulatorio directo en el sistema AS-IS. Todos deben ser resueltos, o debe tomarse una decisión explícita y documentada sobre cada uno, antes de que el sistema modernizado entre en producción. El sistema destino heredará estos defectos si no se toma una decisión deliberada para cada caso.

| Hallazgo | Estado | Decisión requerida de | Fecha límite |
|---------|--------|----------------------|--------------|
| Bug sector CNBV 15→11 en P108 — asientos contables con sector CNBV incorrecto en Serie B histórica; impacto no cuantificado | Pendiente | Director de Regulación; CNBV (si se decide corregir) | Previo al inicio del Wave 3 |
| SAR P120 — ambigüedad regulatoria: destinatario real del reporte no confirmado (Banxico sistémico, CONSAR, UIF o INFONAVIT) | En análisis | Tesorería, área de Cumplimiento Regulatorio SAR, Banxico | Previo al inicio del Wave 2 |
| MR-RPT-01 — Error INFONAVIT ANT siempre = 0 desde 1991: posible obligación de corrección retroactiva ante Banxico e INFONAVIT | Pendiente | Dirección Legal, Tesorería, INFONAVIT | Previo al inicio del Wave 2, antes de corrección en target |
| CUIF R01-R04 vía P150 — sin canal de reporte post-separación Citi; BRANCH=484/485 sin confirmación semántica en P150/P151 | En análisis | Director de Regulación, equipo Citi, CNBV (definición del canal) | Wave 0, prerequisito bloqueante de cualquier cutover |

Para el hallazgo MR-RPT-01 (INFONAVIT ANT=0), la decisión de equivalencia del sistema destino tiene dos opciones excluyentes: replicar el error para mantener equivalencia exacta histórica, lo que perpetúa el reporte incorrecto; o corregir la asignación (`ADD B08-GSAR-ANT-INFO TO 77-ANT-INFO`), lo que producirá que los reportes SAR del sistema modernizado difieran del histórico legado y requerirá comunicación proactiva al regulador antes del go-live. Ninguna de las dos opciones puede tomarse sin soporte del área legal y del área de Cumplimiento Regulatorio. Esta decisión debe quedar registrada como un ADR firmado.

---

## 5. Restricciones regulatorias al parallel-run

Durante el período de parallel-run, la responsabilidad de la generación de reportes regulatorios recae exclusivamente sobre el sistema legado (Unisys ClearPath MCP). El sistema modernizado puede generar reportes en modo sombra para fines de comparación interna, pero estos reportes shadow no deben ser enviados al regulador bajo ninguna circunstancia hasta que el banco haya obtenido la confirmación formal de equivalencia regulatoria.

Cuando los reportes difieran entre el sistema legado y el sistema modernizado durante el parallel-run, la diferencia debe registrarse en un log de divergencias con los siguientes campos: fecha de proceso, reporte afectado, dimensión de diferencia (importe, conteo o clasificación), magnitud de la diferencia expresada en valor absoluto y porcentaje, causa identificada y fecha de resolución. Este log es un documento de auditoría que la CNBV puede solicitar en cualquier momento durante o después del proceso de migración. La institución debe mantener el log actualizado diariamente durante los Waves 2 y 3.

Para la Serie B específicamente, el criterio de equivalencia regulatoria requiere cuadre al 100% en montos y clasificaciones antes de la firma del acta de equivalencia. El período mínimo de parallel-run para los reportes B-0111A y B-0111B es de seis meses con cierres contables mensuales completos, conforme al gate de salida del Wave 3 en kb-capa5-fronteras.md. Cualquier diferencia que no pueda ser explicada técnicamente debe escalarse al área de Regulación y Cumplimiento el mismo día de su detección.

Para el reporte CECOBAN/ICA vía P610 F09, el protocolo TANDEM de Unisys y el mecanismo XFER de transferencia inter-nodo deben seguir operando desde el sistema legado durante todo el parallel-run, dado que no existe un canal cloud certificado por CECOBAN. La certificación del nuevo mecanismo de entrega ante CECOBAN es un prerequisito del Wave 3 batch y no puede postergarse al período de parallel-run.

---

## 6. Plan de validación regulatoria por wave

| Wave | Reportes a validar | Criterio de equivalencia regulatoria | Responsable de firma |
|------|-------------------|-------------------------------------|---------------------|
| Wave 0 — ACL Foundation y separación Citi | CUIF R01-R04 (ALR/AHR/OCM) — definición del canal de reporte post-separación | Canal de reporte propio de Banamex definido y aceptado por CNBV; BRANCH correcto en P150/P151 confirmado por equipo Citi | Director de Regulación, equipo Citi, CNBV |
| Wave 2 — BC-01 Captación, BC-08 Reportería GL | Serie B B-0111A y B-0111B; SAR P120; FraudLink CNBV; INTELAR CNBV; captación IPAB; retenciones SAT | Equivalencia mayor o igual a 99.99% en montos y clasificaciones; diferencias explicadas en log de divergencias; parallel-run de 3 meses con auditoría mensual; decisión sobre MR-RPT-01 documentada como ADR | Auditoría Interna, Regulatory SME |
| Wave 3 — BC-05 GL General Ledger, batch pesado | Todos los anteriores más CECOBAN/ICA; asientos GL con sector CNBV; cierres contables mensuales y anuales | Cuadre GL mayor o igual a 99.99%; parallel-run de 6 meses Serie B; al menos 3 cierres mensuales validados en sistema destino; certificación CECOBAN del nuevo canal; decisión sobre bug sector 15→11 registrada en ADR; notificación CNBV con 30 días de anticipación al cutover | Director de Finanzas, Director de Regulación, sign-off CNBV |

---

## 7. Comunicación a reguladores

| Regulador | Tipo de comunicación | Momento | Responsable | Formato |
|-----------|---------------------|---------|-------------|---------|
| CNBV | Notificación de cambio material — Circular 29/2010 CUB | Al menos 30 días hábiles antes del inicio del Wave 2 | Director de Regulación | Oficio formal con expediente técnico adjunto (descripción del cambio, análisis de riesgos, plan de pruebas, plan de rollback) |
| CNBV | Definición del canal de reporte CUIF post-separación Citi | Wave 0, antes de cualquier cutover | Director de Regulación, equipo Citi | Reunión técnica y carta de entendimiento formal |
| CNBV | Comunicación sobre bug sector CNBV 15→11 en P108 (si se decide corregir) | Previo al Wave 3, antes del cutover del GL | Director de Regulación, Auditoría | Nota aclaratoria con cuantificación del impacto histórico y metodología de corrección |
| Banxico | Notificación de cambio en sistema de generación del reporte CECOBAN | Al menos 30 días antes del Wave 3 batch | Tesorería, Regulación | Oficio formal a Banxico SPEI/Clearing según protocolo CECOBAN |
| Banxico / INFONAVIT | Comunicación sobre error SAR ANT-INFO (si se decide corregir antes del go-live) | Previo al Wave 2, antes de implementar la corrección en el sistema target | Director de Regulación, Director Legal, Tesorería | Oficio formal con análisis de impacto histórico y cuantificación del error acumulado desde 1991 |
| IPAB | Notificación de cambio en sistema de captación asegurada (S500 / BC-01) | Al menos 30 días antes del Wave 2 | Tesorería | Oficio formal con detalle de los programas P142 y P144 afectados |
| SAT | Sin notificación previa requerida, siempre que las tasas de retención se parametricen correctamente antes del cutover | N/A | N/A | N/A |
| CONDUSEF | Sin notificación previa requerida, salvo interrupción de servicio durante el parallel-run | En caso de incidente con impacto en clientes durante el parallel-run | Director de Atención al Cliente | Reporte de incidente según SIPRES en el plazo establecido |

---

## 8. Riesgos regulatorios del proyecto

| Riesgo | Probabilidad | Impacto | Mitigación | Responsable |
|--------|-------------|---------|-----------|-------------|
| CUIF R01-R04 sin canal de reporte propio: si la interfaz Citi se desconecta antes de que Banamex tenga su propio canal certificado, el banco incumplirá con la entrega de reportes CUIF a la CNBV | Alta | Crítico — sanción CNBV por incumplimiento de reporte regulatorio; posible medida de intervención | Definir el canal de reporte propio en Wave 0 como prerequisito bloqueante; no iniciar ninguna desconexión de la interfaz Citi hasta que el canal alternativo esté certificado y aceptado por la CNBV | Director de Regulación, equipo Citi |
| Error SAR ANT-INFO (MR-RPT-01) descubierto por el regulador antes de comunicación proactiva del banco: si CNBV, Banxico o INFONAVIT detectan el error de 34 años por sus propios medios, la sanción y el escrutinio regulatorio serán significativamente mayores que si el banco lo reporta proactivamente | Media | Alto — multa, medida correctiva CNBV, observación de auditoría interna y externa, posible nota pública | Iniciar la conversación interna con el equipo de Tesorería y el área SAR de forma inmediata; decidir si se comunica proactivamente al regulador y documentar la decisión en ADR con soporte legal antes del inicio del Wave 2 | Director de Regulación, Director Legal |
| Bug sector CNBV 15→11 replicado en el sistema modernizado sin decisión deliberada: si el sistema target hereda el error sin registro de la decisión, la Serie B continuará siendo incorrecta y la institución quedará expuesta ante una revisión de la CNBV de sus reportes históricos | Media | Alto — reportes Serie B con clasificación sectorial incorrecta; riesgo de observación de auditoría CNBV en visita de inspección | Incluir la resolución de este hallazgo como gate obligatorio previo al Wave 3; registrar la decisión en el ADR de equivalencia del GL; si se corrige, notificar a CNBV antes del cutover | Director de Finanzas, Director de Regulación |
| Fallo en la certificación regulatoria del parallel-run de la Serie B: si durante los seis meses de parallel-run del GL aparecen diferencias no explicadas en los reportes B-0111A y B-0111B, el banco no podrá obtener el sign-off regulatorio y el proyecto quedará bloqueado con costos de extensión significativos | Media | Alto — paralización del proyecto; presión regulatoria; extensión no planificada del parallel-run y de los costos de doble operación | Implementar comparador automático de outputs Serie B desde el inicio del Wave 2; escalar diferencias al Regulatory SME el mismo día de su detección; mantener el catálogo de diferencias explicadas disponible para auditoría CNBV en cualquier momento | Auditoría Interna, Regulatory SME, Specialist - Transpilation |
| Tasas de retención ISR e IVA hardcodeadas en P020: un cambio de tasa fiscal emitido por el SAT durante el período de migración requeriría modificación de código en el sistema legado y en el sistema modernizado simultáneamente, con el riesgo de desincronización en las retenciones durante el parallel-run | Baja | Medio — error en retenciones durante la transición; multa SAT; necesidad de ajuste retroactivo y potencial litigio con retenidos | Parametrizar las tasas de retención ISR e IVA como primera acción de modernización del módulo P020 en Wave 2, sin esperar al cutover final; incluir una prueba de regresión de retenciones como parte del gate de Wave 2 | Specialist - Transpilation, Regulación Fiscal |

---

*Generado: 2026-07-21 · GemCog Capa 5 — Fronteras y Wave Map · Banamex S500+S151 · Unisys ClearPath MCP*
*Fuentes base: migration-risk-register.md v3.0 (144 riesgos · 5 DEFECTO-PROD) · cap-cfr.md · cap-rpt.md · kb-capa5-fronteras.md · MANIFEST.md v2.1*
*Próximos pasos obligatorios: (1) HITL con Tesorería y área SAR sobre MR-RPT-01; (2) definición del canal CUIF post-Citi con Director de Regulación; (3) confirmación del impacto del bug sector CNBV 15→11 con equipo GL; (4) registro como ADR de las tres decisiones de equivalencia con base regulatoria*
