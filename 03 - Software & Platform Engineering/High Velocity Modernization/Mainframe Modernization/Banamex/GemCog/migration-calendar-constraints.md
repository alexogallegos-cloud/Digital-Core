# Restricciones de Calendario — Migración Banamex S500+S151
> Artefacto P0 MANIFEST · Períodos prohibidos y ventanas de cutover
> Versión: v0.2-QC · 2026-07-21 · QC 2026-07-21: taxonomía BC-NN · BRCH-NBR=485 · CNBV 30d · punto no retorno Wave 3 · GemCog Capa 5 — Fronteras y Wave Map
> Owner: Specialist - 7R Assessment · Advisory: Mainframe Migration SME + Regulatory SME

---

## 1. Principios de programación de cutover

Todo cutover de producción en el sistema S500+S151 debe programarse en una **ventana limpia**: fuera del ciclo batch nocturno, fuera de períodos de alto volumen transaccional y fuera de los compromisos regulatorios de reporte con CNBV, Banxico y SAT. Los siguientes principios rigen la calendarización de todos los waves:

- **Separación de dominio:** S500 (Cargos y Abonos) puede realizar cutover de forma independiente a S151 (GL), pero el cutover de S151 requiere que S500 esté estabilizado en producción al menos un ciclo mensual completo.
- **Parallel-run obligatorio:** Todo wave tiene un período mínimo de parallel-run definido en sección 4. Este período no es negociable y no se solapa con la ventana de cutover.
- **Coordinación con Citi:** Hasta que concluya la separación corporativa, cualquier cutover que afecte los programas de interfaz Citi (P150, P151, BRANCH=484 (P150) y BRCH-NBR=485 (P151)) requiere aprobación del Citi IT Separation Office con mínimo 30 días de anticipación.
- **Rollback garantizado:** La ventana de cutover debe incluir tiempo suficiente para ejecutar rollback completo antes del inicio del siguiente ciclo batch (22:00). Si el rollback no cabe en la ventana, el cutover no está autorizado a iniciar.
- **Pre-anuncio mínimo:** Todo cutover en producción requiere comunicación interna con 15 días hábiles de anticipación y notificación formal a CNBV con mínimo 10 días hábiles cuando el alcance afecte la generación de reportes Serie B.

---

## 2. Períodos prohibidos — Lista negra

| Período | Motivo | Sistema afectado | Duración típica | Fuente |
|---|---|---|---|---|
| Último día hábil de cada mes | Cierre GL — P108/P109 activos; conciliación de saldos | S151 (GL) | 1 día | Operaciones contables |
| Primer día hábil de cada mes | Apertura GL + reporte CNBV B-0111A/B (T+1) | S151, S500 | 1 día | CNBV Serie B |
| Días 1-2 y 14-16 de cada mes | Pago de nómina masiva — volumen transaccional pico en S500 | S500 | 3 días por quincena |Operaciones |
| Primeros 5 días hábiles de enero | Cierre fiscal SAT; P020 activo en recalificación de tasas | S500, S151 | ~5 días | SAT / Código Fiscal |
| 24-26 diciembre y 31 dic - 2 enero | Feriados bancarios estrictos; ventana operacional cerrada | S500, S151 | 6 días | Banxico / CNBV |
| Jueves Santo y Viernes Santo | Feriado bancario oficial; volumen reducido pero sin soporte regulatorio | S500, S151 | 2 días | Ley de Instituciones de Crédito |
| Días de reporte CNBV T+1 (B-0111A/B) | Generación y transmisión de reportes de saldos contables | S151 (GL) | 1 día por mes | CNBV Serie B Circular Única |
| Días de reporte CNBV T+5 y T+15 | Reportes complementarios Serie B; ventana de validación activa | S151 | 1 día por reporte | CNBV Serie B |
| Reportes trimestrales CONDUSEF | Generación de datos de reclamaciones | S500 | 1 día por trimestre | CONDUSEF |
| Reportes semestrales IPAB | Captación e información de saldos | S151 | 1 día semestral | IPAB |
| 22:00 - 05:00 cualquier día | Ventana batch nocturna activa S151; Copia-5 VDM-MTY en curso | S500, S151 | 7 horas diarias | Arquitectura batch |
| Períodos de corte de libros Citi | Consolidación contable Citi/Banamex durante separación | S151, interfaces Citi | Variable — confirmar con Citi IT | Cronograma separación Citi |

---

## 3. Ventanas preferidas por tipo de wave

| Tipo de Wave | Ventana preferida | Duración estimada de cutover | Rollback disponible hasta |
|---|---|---|---|
| Wave 0-A — BC-04 ACL — S151REGISTRA encapsulation (Anti-Corruption Layer) | Martes o miércoles de semanas centrales del mes (días 7-12) | 4-6 horas | Antes de 22:00 del mismo día |
| Wave 0-B — S151-Platform-Services — L030 librería maestra S151 (19,253 LOC, 6 microservicios de plataforma) | Martes o miércoles de semanas centrales del mes | 6-8 horas | Antes de 22:00 del mismo día |
| Wave 1 — BC-02 Control Operacional · BC-03 Tarjetas · BC-09 Ajustes GL | Semana del 7-12 de cualquier mes, excluyendo lista negra | 8-12 horas; iniciar máximo 09:00 | Antes de 20:00 del mismo día |
| Wave 2 — BC-01 Captación · BC-06 Movimientos parcial · BC-08 Reportería GL · BC-07 Control GL | Semana del 7-12, con confirmación de Banxico | 6-8 horas | Antes de 20:00 del mismo día |
| Wave 3 — BC-05 General Ledger (ÚLTIMO — alto riesgo regulatorio) | Semana del 7-12 del mes, post-cierre GL confirmado del mes anterior | 10-14 horas; iniciar máximo 07:00 | Antes de las 19:00 — **punto de no retorno: 16:00** (= 19:00 − 2h RTO − 60 min decisión). Si la validación no completó a las 16:00, iniciar rollback por defecto. |

---

## 4. Restricciones específicas por wave

### Wave 0-A — BC-04 ACL — S151REGISTRA encapsulation (Anti-Corruption Layer)

- **Restricción de calendario:** Sin restricción mayor; evitar último día hábil del mes.
- **Coordinación requerida:** Equipo de Infraestructura Banamex, Mainframe Migration SME.
- **Parallel-run mínimo previo al cutover:** No aplica (no es cutover productivo). Validación funcional 5 días hábiles.

### Wave 0-B — S151-Platform-Services — L030 librería maestra S151

- **Restricción de calendario:** Evitar quincenas (1-2 y 14-16) y último día hábil del mes.
- **Coordinación requerida:** Equipo de Operaciones S500, QA Equivalencia, Citi IT (si incluye interfaces BRANCH=484).
- **Parallel-run mínimo:** 15 días hábiles en ambiente de pre-producción con datos reales anonimizados.

### Wave 1 — BC-02 Control Operacional · BC-03 Tarjetas · BC-09 Ajustes GL

- **Restricción de calendario:** Semana central del mes (7-12). Prohibido primeros 5 días hábiles de enero, quincenas y último/primer día hábil del mes.
- **Coordinación requerida:** Operaciones, Regulatorio (CNBV), Banxico (notificación informativa), Citi IT.
- **Parallel-run mínimo:** 20 días hábiles con reconciliación diaria de transacciones. Se requiere cierre completo de un mes en parallel-run antes de fijar fecha de cutover.

### Wave 2 — BC-01 Captación · BC-06 Movimientos parcial · BC-08 Reportería GL · BC-07 Control GL

- **Restricción de calendario:** Coordinar con ventanas de mantenimiento informativas de Banxico. SPEI opera 24/7; el cutover debe garantizar continuidad de procesamiento en menos de 5 minutos.
- **Coordinación requerida:** Mesa SPEI Banxico (notificación 15 días hábiles), Operaciones, Tesorería.
- **Parallel-run mínimo:** 10 días hábiles con shadow-mode en interfaces de mensajería.

### Wave 3 — BC-05 General Ledger (ÚLTIMO — alto riesgo regulatorio)

- **Restricción de calendario:** Solo posible entre los días 7-12 del mes. Requiere que el cierre GL del mes anterior haya concluido sin observaciones en S151-legacy y en el sistema objetivo. Gate previo: desconexión SCIG completada y certificada.
- **Coordinación requerida:** Dirección Contable Banamex, Regulatorio CNBV (notificación formal), Citi IT Separation Office (aprobación 30 días), Auditoría Interna.
- **Parallel-run mínimo:** 2 cierres mensuales completos en parallel-run con reconciliación nivel cuenta-día. El segundo cierre debe ser aprobado por Auditoría Interna antes de autorizar cutover.

---

## 5. Coordinación con separación Citi

La separación corporativa Citi/Banamex (en progreso desde 2024, target 2026) introduce restricciones adicionales que se superponen al calendario regulatorio estándar:

- **Gate hard para Wave 3:** Los programas P150 y P151 (interfaces con BRANCH=484 (P150) y BRCH-NBR=485 (P151) — sucursales Citi) deben estar desconectados o migrados antes de iniciar el cutover GL. Este gate es verificado por el Citi IT Separation Office y no puede ser salteado.
- **Cortes de libros Citi:** Durante los períodos de consolidación contable Citi/Banamex (typicamente fin de trimestre fiscal Citi), cualquier modificación al GL de Banamex debe ser congelada. Confirmar fechas exactas con el equipo de separación con al menos 45 días de anticipación a cada wave.
- **Sincronización del Wave Map:** El Wave Map debe ser presentado al Citi IT Separation Office como parte de la planificación trimestral. Cualquier ajuste de fecha en Wave 2 o Wave 3 requiere reaprobación formal.
- **Dependencia de datos:** La migración de saldos históricos de S151 hacia el sistema objetivo no puede ejecutarse mientras el GL consolidado Citi permanezca activo. Confirmar fecha de cierre definitivo del GL consolidado antes de fijar fecha de Wave 3.

---

## 6. Notificaciones previas obligatorias

| Destinatario | Anticipación mínima | Formato | Fundamento |
|---|---|---|---|
| CNBV — Dirección de Supervisión | 30 días hábiles | Oficio formal firmado por Dirección General IT | CUB Art. 56-57 / Circular 29/2010 — cambios materiales |
| Banxico — Mesa SPEI | 15 días hábiles (Waves 2 y 3) | Notificación electrónica en plataforma Banxico | Regulación SPEI — Banxico |
| Citi IT Separation Office | 30 días calendario (Waves 2 y 3) | Documento formal del programa de separación | Acuerdo de separación corporativa Citi/Banamex |
| Auditoría Interna Banamex | 10 días hábiles (Wave 3) | Memo interno con plan de parallel-run y resultados | Política de riesgo operacional Banamex |
| Dirección Contable Banamex | 15 días hábiles (Wave 3) | Presentación ejecutiva con plan de cutover y rollback | Política interna de cambios críticos |
| SAT — Notificación informativa | 5 días hábiles (Wave 1 si afecta P020) | Aviso electrónico vía buzón tributario | Código Fiscal de la Federación |

> **Nota:** el plazo de 30 días hábiles aplica a cambios materiales en sistemas core según Circular 29/2010. Para cambios menores no materiales (sin impacto en reportes regulatorios): 10 días hábiles.

---

## 7. Calendario indicativo 2026-2027

El siguiente template identifica los bloques de disponibilidad por trimestre. Las celdas sombreadas representan períodos prohibidos; las celdas abiertas son ventanas candidatas sujetas a confirmación operacional.

### 2026 — Segundo semestre

| Mes | Días prohibidos (lista negra) | Ventana disponible Wave 0-A/0-B | Ventana disponible Wave 1 | Observaciones |
|---|---|---|---|---|
| Agosto 2026 | 1, 14-16, 31 | 4-13, 17-29 | 7-12 | Confirmar corte Q2 Citi |
| Septiembre 2026 | 1, 14-16, 30 | 4-13, 17-28 | 7-12 | Feriado 16 sep (Independencia) — verificar impacto |
| Octubre 2026 | 1, 14-16, 30 | 4-13, 17-29 | 7-12 | Reporte CONDUSEF Q3 — confirmar fecha exacta |
| Noviembre 2026 | 1-2, 14-16, 30 | 5-13, 17-28 | 7-12 | Feriado 20 nov — verificar impacto; cierre fiscal Citi Q3 |
| Diciembre 2026 | 1, 14-16, 24-31 | PROHIBIDO para waves core | PROHIBIDO | Cierre fiscal SAT; feriados bancarios |

### 2027 — Primer semestre

| Mes | Días prohibidos (lista negra) | Ventana disponible Wave 1 | Ventana disponible Wave 3 (GL) | Observaciones |
|---|---|---|---|---|
| Enero 2027 | 1-5 (SAT), 14-16, 31 | 7-12 (post día 5) | NO DISPONIBLE | P020 en recalificación fiscal; Wave 3 requiere dos cierres previos |
| Febrero 2027 | 1, 14-16, 28 | 7-13 | Candidato (si Wave 1 estabilizado oct-nov 2026) | Mes corto — ventana ajustada |
| Marzo 2027 | 1-2, 14-16, 31 | 7-13 | 7-12 (sujeto a gate SCIG) | Semana Santa variable — verificar Jueves/Viernes Santo |
| Abril 2027 | 1, 14-16, 30 | 7-13 | 7-12 | Verificar Semana Santa si cae en abril |
| Mayo 2027 | 1, 14-16, 30 | 7-13 | 7-12 | Feriado 1 mayo — verificar impacto en apertura GL |
| Junio 2027 | 1, 14-16, 30 | 7-13 | 7-12 | Reporte IPAB semestral — confirmar fecha |

> **Nota de uso:** Este calendario es un template de restricciones, no un cronograma comprometido. Las fechas definitivas de cada wave se fijan en el Wave Map una vez completados los parallel-run mínimos y obtenidas las aprobaciones requeridas en sección 6. Actualizar este artefacto cada trimestre con las fechas confirmadas de reportes regulatorios y los ajustes del cronograma de separación Citi.

---

*Última actualización: 2026-07-21 · v0.2-QC · Pendiente revisión: Regulatory SME (CNBV/Banxico), Mainframe Migration SME, Dirección Contable Banamex*
