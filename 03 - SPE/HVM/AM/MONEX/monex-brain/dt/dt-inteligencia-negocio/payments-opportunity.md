# La Oportunidad de Pagos — MONEX
> Documento de análisis estratégico para el engagement de Modernización del Core de Pagos
> Clasificación: Uso interno engagement — no compartir con MONEX sin revisión
> Actualizado: 2026-09-22

---

## Por Qué los Pagos Son la Oportunidad Central

MONEX tiene 41 años de historia en FX. El FX es su fortaleza diferenciadora y seguirá siéndolo.
Pero los **pagos internacionales** son el puente que hace que el FX sea operacionalmente ejecutable.

Un flujo FX corporativo completo es: **cotización → instrucción de pago → liquidación → confirmación**.
Hoy, MONEX puede hacer la cotización con excelencia. El motor de pagos es la parte que falla:
legacy, no ISO 20022, sin CLS, sin STP real al 99%.

---

## Volúmenes del Negocio de Pagos

| Métrica | Valor | Implicación |
|---------|-------|-------------|
| Operaciones de pago internacional | **7.6 millones/año** | ~20,800 pagos/día — el sistema procesa en promedio 14+ pagos por minuto |
| Facturación FX | **$198,284 millones USD** | Volumen masivo de liquidación que depende del motor de pagos |
| Clientes corporativos | **>40,000 empresas** | Cada cliente con múltiples operaciones — alta carga transaccional |
| Remesas hacia México (mercado) | **>$63,000 millones USD** (2024) | Contexto del mercado donde MONEX opera |

### Por Qué el Volumen Importa para el RFP
- **14+ pagos/minuto en promedio** → picos de hasta 10x en apertura de mercados → el motor legacy tiene límites de throughput no documentados.
- **$198B USD** de facturación FX → cada milisegundo de latencia tiene costo financiero real.
- **40,000+ empresas** → falla del motor = impacto reputacional masivo simultáneo.

---

## Los 5 Gaps del Motor de Pagos Actual

### Gap 1 — ISO 20022: El Lenguaje Universal que MONEX No Habla

**Estado actual**: el motor de pagos procesa SWIFT MT (mensajería legacy, texto plano).

**El problema**: el mundo de pagos migró a ISO 20022.

| Hito ISO 20022 | Fecha | Impacto MONEX |
|---------------|-------|---------------|
| SWIFT migración global MT → MX | Nov 2022 - Nov 2025 | MONEX en período de coexistencia forzada |
| CBPR+ deadline ISO 20022 obligatorio | Nov 2025 | Mensajes SWIFT MX son el estándar |
| Banxico adopción ISO 20022 (SPEI) | En curso | Alineación doméstica requerida |
| CLS requiere ISO 20022 para nuevos accesos | 2024+ | Bloquea acceso CLS de MONEX |

**Lo que le cuesta a MONEX hoy**: costos de conversión MT↔MX, pérdida de datos ricos
en los mensajes (ISO 20022 transporta 10x más información que MT), y rechazo de
mensajes por bancos corresponsales que ya migaron a 100% MX.

### Gap 2 — CLS: El Riesgo de Contraparte que MONEX Absorbe Solo

**Estado actual**: MONEX liquida FX sin CLS (Continuous Linked Settlement).

**El problema**: sin CLS, cada operación FX tiene **riesgo Herstatt** — el riesgo de que
MONEX pague su lado de la transacción y el corresponsal no pague el suyo.

| Cifra | Impacto |
|-------|---------|
| $198,284 millones USD de facturación FX | Todo sin protección PvP — exposición 100% |
| 7.6M operaciones/año | Cada una con riesgo de contraparte |
| CLS liquida ~$6.5T USD diarios globalmente | MONEX está fuera de este pool |

**Lo que significa para la Ambición 2030**: si MONEX quiere servir a instituciones
financieras internacionales más grandes (bancos globales, fondos), la ausencia de CLS
es una barrera de acceso — no aceptan contrapartes sin mitigación Herstatt.

**Bloqueante técnico para acceso CLS**: ISO 20022 nativo es prerrequisito.
Mientras el motor no hable MX nativo, CLS no es alcanzable.

### Gap 3 — STP: El 99% que No Existe

**Estado actual**: porcentaje real de STP (Straight-Through Processing) desconocido —
DATO-REQUERIDO en el brain, pero la presencia de un motor legacy pre-ISO 20022 sugiere
que STP está significativamente por debajo del 99% objetivo.

**El problema**: cada pago que sale del flujo STP requiere intervención humana:
- Operador mira la excepción, la analiza, decide si aprobar o rechazar.
- Latencia de horas en lugar de segundos.
- Riesgo operativo: error humano en pagos de alto valor.
- SPEI exige pagos en tiempo real (SECS) — STP bajo hace imposible el SLA real-time.

**Benchmark sector**: bancos con motores ISO 20022 nativos reportan STP >99.5%.
Sin ISO 20022, el STP real raramente supera 85-90% en operaciones internacionales
porque los campos no mapeados requieren revisión manual.

### Gap 4 — MDM: Sin Golden Record No Hay AML Real

**Estado actual**: sin MDM/Golden Record — gap crítico documentado en el brain.

**La conexión con pagos**: AML en pagos requiere screening de contraparte en tiempo real.
Ese screening necesita un registro canónico de clientes y contrapartes.

Sin MDM → el AML screening opera con datos fragmentados → falsos positivos altos →
más excepciones manuales → STP cae más → círculo vicioso.

**El proyecto Oracle AML (2023)** fue un intento de parchar este problema.
La modernización real requiere Golden Record como prerequisito del motor de pagos.

### Gap 5 — Disponibilidad: 24/7/365 en Teoría, No en Práctica

**Estado actual**: SPEI exige 24/7/365 desde su migración a tiempo real.
El motor legacy fue diseñado para horarios bancarios (L-V 8am-6pm en su época).

**El problema**: extensiones de horario y pagos de fin de semana requieren esfuerzo
operativo extra sobre un sistema que no fue diseñado para ello.

**Riesgo real**: un fallo del motor en sábado a las 2am impacta pagos SPEI que
clientes corporativos tienen programados como críticos (nómina, proveedores internacionales).

---

## La Oportunidad para Accenture

### Por Qué MONEX Lanza el RFP Ahora

1. **Presión regulatoria**: SWIFT MT sunset + ISO 20022 obligatorio = urgencia de migrar.
2. **Competencia**: bancos como BBVA y Banamex ya migraron a ISO 20022 — MONEX en desventaja.
3. **Ambición 2030**: doblar revenue a $2B USD requiere procesar volúmenes que el motor legacy no aguantará.
4. **DORA desde ene-2025**: operaciones UK (Monex Europe) bajo DORA — el motor de pagos es infraestructura crítica que debe ser resiliente bajo DORA.
5. **CLS como diferenciador**: acceso CLS requiere ISO 20022 nativo — objetivo estratégico documentado.

### Tamaño de la Oportunidad

| Dimensión | Estimación |
|-----------|------------|
| Tipo de engagement | SI (System Integration) |
| CCI objetivo S&PE | 41% |
| Duración estimada | 18-24 meses |
| Stack tecnológico | MuleSoft confirmado + plataforma pagos cloud-native (TBD en RFP) |
| Apalancamiento futuro | AMS sobre el motor nuevo post-go-live |

### Win Theme: El Digital Brain como Diferenciador

El win theme para este engagement es que Accenture no entrega un proyecto de integración
convencional — entrega un **Digital Brain de pagos** que puede responder en tiempo real:

> *"¿Qué flujos quedan en incumplimiento si el schema de ISO 20022 del corresponsal X cambia?"*

Ningún otro proponente tiene esta capacidad. Es el diferenciador de Accenture en el RFP.

---

## Prerequisitos para el Engagement

Para ejecutar la modernización del motor de pagos con éxito, MONEX necesita resolver:

| Prerequisito | Estado | Acción requerida |
|-------------|--------|------------------|
| Golden Record / MDM | NOT_COVERED | Iniciativa 3 Apolo — paralela o secuencial |
| SWIFT Alliance (para CLS) | DATO-REQUERIDO | Confirmar membresía SWIFT Alliance de MONEX |
| Inventario capabilities payments-legacy | DATO-REQUERIDO | Cargar RFP en `source/rfp/` |
| Volúmenes SPEI/SWIFT por tipo | DATO-REQUERIDO | Análisis del sistema origen |
| SLAs actuales del motor legacy | DATO-REQUERIDO | Medición línea base pre-migración |

---

*Cross-reference: `dt-motor-pagos/` para flujo técnico de pagos · `dt-liquidacion-cls/` para arquitectura CLS ·
`dt-regulatorio/` para obligaciones DIOR/CNBV · `projects/payments-modernization/` para el proyecto activo*
