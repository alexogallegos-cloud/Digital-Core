# Plan Estratégico MONEX — Ambición 2030
> Fuente: Declaraciones ejecutivos · Noticias El Financiero / Expansión · Contexto del engagement
> Actualizado: 2026-09-22
> NOTA: "Plan Apolo" es denominación interna del RFP — no un programa públicamente divulgado.

---

## Ambición 2030: Doblar el Negocio

MONEX ha declarado una ambición de crecimiento significativo hacia 2030. Las señales públicas
de sus ejecutivos apuntan a:

| Dimensión | Hoy (estimado 2025) | Objetivo 2030 |
|-----------|---------------------|---------------|
| Revenue anual | ~$1B USD (estimado) | ~$2B USD |
| Participación de ingresos internacionales | ~20% | ~30%+ |
| Geografía | 8 países | Expansión APAC y LATAM adicional |
| Cartera de productos | FX + pagos corporativos | FX + pagos + treasury + estructurados |

### Por Qué Esta Ambición Requiere Modernización Tecnológica

La ambición de doblar revenue en 5 años no es posible con el stack tecnológico actual:

1. **Volúmenes**: si MONEX crece de 7.6M a 15M+ operaciones/año, el motor legacy no escala.
2. **Nuevos mercados**: entrar a APAC requiere ISO 20022 nativo — estándar en Asia.
3. **Nuevos segmentos**: servir a instituciones financieras globales como corresponsales requiere CLS.
4. **Velocidad de innovación**: el motor legacy limita cuán rápido MONEX puede lanzar nuevos productos (opciones exóticas, pagos embebidos B2B).

---

## Los 4 Pilares de la Transformación (Programa Apolo Interno)

### Iniciativa 1: Motor de Pagos — La Más Urgente

**Por qué es urgente**: presión regulatoria ISO 20022 + DORA desde ene-2025 + competencia ya migrada.

**Objetivo**: plataforma cloud-native ISO 20022 con CLS Settlement habilitado.

**Plazo estimado**: 18-24 meses (duración del RFP activo).

**Plataformas en evaluación**: Temenos Payments Hub · Form3 · Volante VolPay · Finastra Global PAYplus.

**Stack de integración confirmado**: MuleSoft Anypoint como orquestador — el backbone ya existe.

### Iniciativa 2: FX Next — Modernización del Engine Core

**Objetivo**: modernizar la plataforma FX — pricing en tiempo real, STP total, integración CLS post-Motor de Pagos.

**Contexto**: el FX Engine es la joya de la corona de MONEX. Su modernización se hace
**después** del Motor de Pagos porque la liquidación FX depende del motor de pagos.

**Stack target**: por definir en DESIGN phase — pricing engines de Bloomberg/Reuters integrados nativamente.

### Iniciativa 3: Golden Record / MDM — El Prerequisito

**Objetivo**: primer Master Data Management canónico de MONEX.

**Por qué no existe hoy**: MONEX nació FX-only con datos de clientes simples. Al crecer,
cada sistema (FX Engine, Payments, Portal) mantiene su propia copia de datos de cliente
con inconsistencias. Esto es el gap más crítico para AML real y para CLS.

**Candidatos MDM**: Informatica MDM · Collibra · solución custom cloud-native.

**Relación con Motor de Pagos**: el Golden Record es prerequisito del AML en tiempo real
que el nuevo motor requiere. Se construye en paralelo o antes del motor.

### Iniciativa 4: Plataforma Apolo / Decommission

**Objetivo**: plataforma cloud-native que sirve de destino final para todas las iniciativas,
más el plan ordenado de decommission del legado capability por capability.

**Patrón**: Strangler-Fig — el legacy sigue operando hasta que cada capability migra y
se valida en parallel-run. No hay big-bang cutover.

---

## Internacionalización como Motor de Crecimiento

La estrategia de internacionalización ya está en marcha (8 países) pero el objetivo 2030
requiere escalarla:

| Región | Estado hoy | Objetivo 2030 |
|--------|-----------|---------------|
| México | Core — 80%+ del negocio | Consolidar y modernizar |
| USA | Monex USA operativo | Crecer mercado hispano corporativo |
| UK + Europa | Monex Europe operativo (FCA) | Crecer cross-border EUR/GBP |
| LATAM | Sin presencia fuera de México | Expansión a Brasil, Colombia, Perú |
| APAC | Solo Singapur (MonFX) | Expandir Asia — requiere ISO 20022 nativo |

### El Arreglo ISO 20022 Habilita la Expansión Internacional

Cada nuevo mercado internacional que MONEX quiere entrar tiene ISO 20022 como estándar.
La modernización del motor de pagos no es solo una decisión técnica — es el habilitador
estratégico de la expansión geográfica.

---

## Señales de Prioridad Ejecutiva

**Mauricio Naranjo (CEO), diciembre 2025**: declaró que 2026 presenta una "ventana alentadora"
para inversión en México si el gobierno define estrategias claras. Contexto: MONEX ve el
entorno regulatorio y macroeconómico como favorable para inversión corporativa.

**Janneth Quiroz (Directora Análisis)**: activa en medios, proyecta crecimiento México 1.3%
en 2026. Contexto: MONEX tiene research económico propio — voz respetada en mercados.

**Implicación para el engagement**: la dirección de MONEX tiene apetito para inversión en
infraestructura tecnológica que habilite crecimiento — el timing del RFP es intencional.

---

## Riesgo Estratégico #1: Capacidad de Ejecución

**El mayor riesgo del programa Apolo, declarado por MONEX, es la capacidad de ejecución organizacional.**

MONEX no es una empresa de tecnología. Es una empresa financiera con fortaleza en FX y relaciones
corporativas. Ejecutar 4 iniciativas tecnológicas simultáneas requiere:
- Gestión del cambio organizacional profunda.
- Capacidad de integrar un partner tecnológico (Accenture) con los equipos internos.
- Gouvernance del programa que asegure continuidad en los 18-24 meses de implementación.

**Implicación para Accenture**: la propuesta debe incluir explícitamente un modelo de
co-delivery y gestión del cambio — no solo integración técnica. El Design Authority (Rafa)
es el punto de contacto técnico, pero el sponsor ejecutivo necesita ver un plan de
operacionalización del programa, no solo una arquitectura.

---

*Cross-reference: `payments-opportunity.md` para la urgencia del Motor de Pagos ·
`projects/payments-modernization/` para el proyecto activo · `dt-plataforma-apolo/` para el decommission plan*
