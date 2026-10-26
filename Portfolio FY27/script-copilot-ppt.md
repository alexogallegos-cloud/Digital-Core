# Script para Copilot — Plan de cobertura de arquitectura

> Fuente de datos: `data/pipeline-fy27.json` (línea base validada 2026-10-21).
> Offerings consolidados: AI Enabled Enterprise, Modern Data Platform e Innovation ahora son **Data & AI**.
> Antes de correr el script, abre la plantilla corporativa Accenture o aplica el tema. Copilot no aplica hex exactos desde el prompt.

---

```
Eres un diseñador de presentaciones ejecutivas de Accenture. Genera una
presentación de 8 láminas en PowerPoint.

AUDIENCIA: liderazgo de Digital Core, Accenture México.
PROPÓSITO: acordar cómo se cubre con arquitectos un portafolio de 53 frentes.
Es un plan operativo de cobertura. NO es una presentación comercial: no incluyas
tarifas, márgenes, CCI, TCV, bookings ni cifras de revenue.

FORMATO Y COLOR:
Usa el tema de la plantilla Accenture ya aplicada. Si tienes que definir color,
usa esta jerarquía de cinco roles:
  Ancla #6B21A8 morado Accenture, para paneles de encabezado y títulos de sección
  Papel #FFFFFF blanco puro, fondo de contenido
  Plano #F5F5F5 gris muy claro, fondos alternos y tablas
  Trazo #E0E0E0 gris, sólo bordes y separadores, nunca texto
  Señal #000000 negro, etiquetas de alta jerarquía
Texto sobre Ancla siempre blanco puro, sin transparencias.
Tipografía Calibri, sólo dos pesos, Bold para títulos y datos clave, Light para
cuerpo. Sin iconos decorativos, sin emojis, sin flechas como adorno.
Tablas limpias con línea divisoria, sin rellenos de color en celdas.

ESTILO DE TEXTO:
Prosa profesional en español de México. Frases completas, no telegramas.
Máximo cinco viñetas por lámina. Toda descripción inicia con mayúscula.

LÁMINA 1, portada
Título: Plan de cobertura de arquitectura
Subtítulo: Cómo atendemos 53 frentes con el equipo de arquitectos
Pie: Digital Core México, FY27, 21 de octubre de 2026

LÁMINA 2, Qué hay que atender
Dato grande: 53 oportunidades en 16 cuentas across cinco offerings.
Tabla, Offering y Oportunidades:
  03 Software y Platform Engineering, 26
  07 AMS Reinvention, 11
  04 Intelligent Infrastructure, 8
  Data & AI, 5
  01 Technology Strategy y Transformation, 3
Nota al pie: Línea base validada el 21 de octubre de 2026. Data & AI consolida
los offerings previos de AI Enabled Enterprise, Modern Data Platform e
Innovation.

LÁMINA 3, Dónde está concentrado el portafolio
Tabla, Cuenta y Oportunidades:
  AXA, 14
  Banamex, 11
  BanCoppel, 5
  Actinver, 3
  BBVA, 3
  Gentera, Liverpool, MIFEL, Mapfre, Scotia y Volaris, 2 cada una
  Banorte, Coppel, HSBC, KOF y Posadas, 1 cada una
Mensaje: Tres cuentas concentran 30 de los 53 frentes. Las trece restantes
tienen tres frentes o menos, y esa dispersión es lo que encarece la atención.

LÁMINA 4, Cómo está repartida la carga hoy
Compara la asignación de tiempo del líder de arquitectura contra la
distribución real del portafolio.
Tabla, Asignación, Tiempo comprometido y Frentes que cubre:
  Banamex, 40 por ciento, 11 frentes
  BanCoppel, 40 por ciento, 5 frentes
  Todo lo demás, 20 por ciento, 37 frentes
Mensaje: El 20 por ciento equivale a ocho horas semanales repartidas entre 37
frentes, unos trece minutos por frente. AXA, la cuenta más grande del
portafolio con 14 oportunidades, vive completa dentro de ese 20 por ciento.

LÁMINA 5, Los ocho frentes de cobertura y sus perfiles
Explica primero que la unidad de trabajo deja de ser la oportunidad y pasa a
ser el frente de arquitectura, de modo que 53 oportunidades caben en ocho
perfiles en lugar de 53 equipos distintos.
Tabla con seis columnas, Frente, Alcance, Perfil, Nivel, Skill exigido y
Nombre. La columna Nombre va vacía para asignación posterior.
  A, Reinvention AMS y Observabilidad, 11 oportunidades en 9 cuentas,
     Service Architect AMS e IMS más SRE and Observability Architect, L6 y L7,
     Diseño de modelo de servicio, SLA y OLA, transición y shadow, Dynatrace y
     OpenTelemetry, SLI SLO y error budget, correlación de eventos, ITIL v4
  D, Infraestructura y Salida de Legado, 10 oportunidades en 3 cuentas,
     Cloud Architect más Infrastructure Migration Architect, L6 y L7,
     Landing zone y gobierno, networking híbrido, F5 y Akamai, dependency
     mapping, olas de migración, cutover y rollback, VMware y HPUX
  C, Plataforma, API e Integración, 9 oportunidades en 5 cuentas,
     Integration and Platform Architect más API Architect, L6 y L7,
     Arquitectura de integración, event driven, Apigee X y OPDK, MuleSoft,
     gobierno de APIs, GitHub Actions, Backstage
  B, Modernización de Core con Digital Brain, 6 oportunidades en 6 cuentas,
     Lead Architect de Modernización más Brain Engineer más Information
     Architect, L6, L7 y L8, Patrones 7R, equivalencia funcional, Informix SPL
     y COBOL, SQLite semántico, extracción de reglas de negocio, linaje
  F, Producto Digital y Originación, 6 oportunidades en 5 cuentas,
     Solution Architect de Producto más Frontend Architect, L6 y L7,
     Arquitectura de tres capas, diseño de API, Angular o React, BPM,
     originación y KYC, spec driven development
  H, Estrategia, Gobierno y Arquitectura, 4 oportunidades en 3 cuentas,
     Enterprise Architect, L5, TOGAF ADM y dominios BDAT, capability based
     planning, modelo operativo de TI, roadmap y secuenciación
  G, Data, IA y Agentes, 4 oportunidades en 3 cuentas,
     AI Solution Architect más Data Architect, L6, Patrones ReAct y multi
     agente, RAG sobre ontología del cliente, diseño de evaluaciones,
     guardrails, lakehouse, CDC desde SAP, contratos de datos
  E, Quality Engineering, 3 oportunidades en 3 cuentas,
     Quality Engineering Architect, L6, Shift left con casos desde discovery,
     automatización de pruebas, gestión de datos de prueba, equivalencia
Nota: Los niveles corresponden a career levels Accenture, L5 Associate
Managing Director, L6 Senior Manager, L7 Manager, L8 Consultant.
Mensaje de cierre: Dos patrones opuestos mandan sobre la asignación. El frente
D está concentrado, ocho de sus diez oportunidades son de AXA, así que un
arquitecto puede dueñarlo casi completo. El frente A está disperso en nueve
cuentas distintas, y por eso necesita un líder más gente, no una sola persona.

LÁMINA 6, Por qué el Enterprise Brain hace posible la cobertura
Explica que el conocimiento de la cuenta vive en el gemelo cognitivo y no en la
cabeza del arquitecto, y que por eso una persona puede cubrir varias cuentas
sin convertirse en cuello de botella.
Lista los gemelos que ya operan:
  BanCoppel, con brains de core Informix, canales, Unity, Exodus y CAN
  Banamex, con el brain del laboratorio y el gemelo del core Unisys
  AXA, con 88 sistemas, 53 dependencias y el portafolio 2027 cargado
  Liverpool, con 232 capacidades de Run the Business y el corpus de toma de
  control
  MONEX, Coppel, Santander y Gentera, con gemelos en construcción
Mensaje: Dos de los frentes ya traen su equipo propuesto desde el propio
gemelo. El brain de Exodus en BanCoppel define ocho aplicaciones con roles y
niveles, y el brain de AXA trae los ocho perfiles que el cliente escribió.

LÁMINA 7, Cómo operamos
  Ritmo: revisión semanal por frente, no por oportunidad.
  Escalamiento: el 20 por ciento del líder se usa en gobierno y desbloqueo, no
  en ejecución.
  Criterio de entrada: una oportunidad nueva se asigna a un frente existente o
  no entra.
  Levantamiento: siete oportunidades no tienen carpeta, deal-state ni material
  fuente, y levantarles expediente es el primer trabajo del equipo.
  Depuración: diez oportunidades tienen deadline vencido sin evidencia
  posterior y se cierran formalmente en el registro.

LÁMINA 8, Decisiones que pido
  Confirmar el cierre formal de las diez oportunidades con deadline vencido.
  Autorizar el levantamiento de expediente de las siete sin material.
  Aprobar que el 20 por ciento del líder pase a gobierno y deje la ejecución.
  Asignar nombre a los perfiles de los frentes A, C y D, que concentran 30 de
  los 53 frentes.
```

---

## Notas de uso

- No incluye nombres de personas del cliente, aunque los brains los tienen, porque es un riesgo innecesario en material que puede circular.
- Los nombres de cuenta quedan visibles porque es un deck interno de planeación. Si sale del equipo, sustituirlos por códigos.
- La columna Nombre de la lámina 5 se llena manualmente. Este plan no asigna personas.
