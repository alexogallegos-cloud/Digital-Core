# Test Strategy — Originación de tarjeta de crédito

> **Artefacto**: Catálogo completo de casos de prueba con criterio, datos de entrada, resultado esperado y casuísticas
> **Origen**: Criterios de aceptación aprobados del consolidado de historias de usuario
> **Versión**: 1.0.0
> **Fecha**: 2026-10-16
> **Casos**: 186

---

## Cómo leer este catálogo

Cada caso tiene dos naturalezas cruzadas. Es **funcional** cuando verifica que el sistema hace lo que la historia de usuario ofreció, y **no funcional** cuando verifica que lo hace a tiempo, de forma continua y sin exponer información. Y es **regulatorio** cuando lo que prueba es algo que una norma exige, con independencia de su naturaleza. Son dos ejes distintos: hay casos funcionales regulatorios y no funcionales regulatorios.

Los casos funcionales positivos son **transcripción literal del criterio de aceptación aprobado**. El dado, el cuando y el resultado esperado son los que escribió y firmó el equipo funcional, sin reinterpretación. Los casos negativos y de valores límite son derivados: el criterio los implica pero no los enuncia. Los no funcionales no derivan de ningún criterio, porque ninguna historia habla de tiempos ni de caídas; derivan del flujo y de sus dependencias externas.

Las **casuísticas** son las variantes que cada caso debe recorrer. Un caso con cuatro casuísticas no es una ejecución, son cuatro.

Todos los **datos de entrada** son sintéticos. No hay un solo dato real de cliente en este documento.

## Resumen

### Totales

| | Casos |
|---|---|
| Casos totales | 186 |
| Funcionales | 162 |
| No funcionales | 24 |
| Regulatorios | 131 |
| No regulatorios | 55 |

### Por prioridad

| | Casos |
|---|---|
| P1 | 131 |
| P2 | 39 |
| P3 | 16 |

### Por técnica

| | Casos |
|---|---|
| Partición de equivalencia | 107 |
| Valores límite | 39 |
| Prueba negativa | 28 |
| Transición de estado | 6 |
| Extremo a extremo | 6 |

### Por naturaleza no funcional

| | Casos |
|---|---|
| Desempeño | 6 |
| Disponibilidad | 6 |
| Seguridad | 6 |
| Carga | 4 |
| Continuidad | 2 |

### Por marco regulatorio

| | Casos |
|---|---|
| CNBV banca electrónica | 31 |
| PLD listas de personas bloqueadas | 24 |
| CONDUSEF grupos prioritarios | 19 |
| CONDUSEF y RECA | 13 |
| PLD persona políticamente expuesta | 10 |
| CONDUSEF | 10 |
| CNBV expediente y CONDUSEF | 10 |
| Banxico CAT y CONDUSEF | 9 |
| PLD origen de recursos | 5 |

---

## Parte 1. Casos funcionales por historia de usuario

### HDU-TDC-R4-01. Actualizar la tasa ordinaria y el CAT en la oferta de producto

**Bloque funcional**: Oferta de Producto

**Marco regulatorio**: Banxico CAT y CONDUSEF. **Prioridad**: P1. **Casos**: 8.

**Precondiciones de la historia**: Solicitante precalificado exitosamente ( una vez concluido fase de paramétrico); Oferta de Producto disponible dentro del flujo APOLO; Fórmula CAT vigente definida por negocio/regulación; Parámetro de tasa configurado

#### CA01

> Dado que el solicitante fue precalificado exitosamente y se encuentra en Oferta de Producto Cuando el sistema presenta la oferta de la tarjeta de crédito Entonces se muestra la tasa ordinaria vigente de 69.4%

**TC-ORG-001 — Visualización de tasa vigente**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Tasa ordinaria configurada 69.4%; monto preaprobado 25,000 MXN; prospecto precalificado
- **Dado** que el solicitante fue precalificado exitosamente y se encuentra en Oferta de Producto
- **Cuando** el sistema presenta la oferta de la tarjeta de crédito
- **Resultado esperado**: se muestra la tasa ordinaria vigente de 69.4%
- **Casuísticas**: Tasa vigente; tasa modificada en configuración; monto preaprobado distinto

**TC-ORG-002 — La tasa mostrada no corresponde a la vigente**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Tasa en configuración 65.0% contra tasa vigente 69.4%
- **Dado** Una configuración cuya tasa ordinaria difiere de la vigente
- **Cuando** el sistema presenta la oferta
- **Resultado esperado**: la oferta no se publica y el sistema señala la inconsistencia
- **Casuísticas**: Tasa menor; tasa mayor; tasa ausente

#### CA02

> Dado que negocio requiere modificar la tasa ordinaria sin desarrollo Cuando se consulta la configuración de tasa aplicable Entonces el sistema utiliza el valor parametrizado vigente

**TC-ORG-003 — Parametrización de tasa**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Tasa ordinaria configurada 69.4%; monto preaprobado 25,000 MXN; prospecto precalificado
- **Dado** que negocio requiere modificar la tasa ordinaria sin desarrollo
- **Cuando** se consulta la configuración de tasa aplicable
- **Resultado esperado**: el sistema utiliza el valor parametrizado vigente
- **Casuísticas**: Tasa vigente; tasa modificada en configuración; monto preaprobado distinto

**TC-ORG-004 — Cambio de tasa sin desarrollo surte efecto en la siguiente oferta**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: Tasa previa 69.4%, tasa nueva 72.0%
- **Dado** Una tasa ordinaria modificada en configuración
- **Cuando** se genera una oferta posterior al cambio
- **Resultado esperado**: la oferta toma el valor nuevo sin requerir despliegue
- **Casuísticas**: Cambio al alza; cambio a la baja; oferta en curso al momento del cambio

**TC-ORG-005 — Tasa fuera del rango permitido**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Tasa 0%; tasa 150%; tasa negativa
- **Dado** Un intento de configurar una tasa fuera del rango autorizado
- **Cuando** se guarda la configuración
- **Resultado esperado**: el sistema rechaza el valor
- **Casuísticas**: Límite inferior; límite superior; valor no numérico

#### CA03

> Dado que la tasa ordinaria vigente fue aplicada a la oferta Cuando el sistema calcula el CAT de la oferta Entonces el CAT refleja proporcionalmente la tasa conforme a la fórmula vigente

**TC-ORG-006 — Cálculo proporcional de CAT**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Tasa ordinaria configurada 69.4%; monto preaprobado 25,000 MXN; prospecto precalificado
- **Dado** que la tasa ordinaria vigente fue aplicada a la oferta
- **Cuando** el sistema calcula el CAT de la oferta
- **Resultado esperado**: el CAT refleja proporcionalmente la tasa conforme a la fórmula vigente
- **Casuísticas**: Tasa vigente; tasa modificada en configuración; monto preaprobado distinto

**TC-ORG-007 — El Costo Anual Total se recalcula al cambiar la tasa**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: Tasa 69.4% y tasa 72.0%, mismo monto y plazo
- **Dado** Una tasa ordinaria modificada
- **Cuando** se calcula el Costo Anual Total de la oferta
- **Resultado esperado**: el resultado refleja proporcionalmente la tasa nueva
- **Casuísticas**: Cambio al alza; cambio a la baja; monto distinto

**TC-ORG-008 — El Costo Anual Total no corresponde a la fórmula vigente**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Costo calculado con fórmula anterior contra el valor esperado
- **Dado** Una oferta cuyo Costo Anual Total se calculó con una fórmula anterior
- **Cuando** se contrasta contra la fórmula vigente
- **Resultado esperado**: la diferencia se detecta y la oferta no se publica
- **Casuísticas**: Diferencia por redondeo; diferencia por fórmula

---

### HDU-TDC-R4-03. Enviar por correo el contrato vigente al finalizar la firma

**Bloque funcional**: Bienvenida

**Marco regulatorio**: CONDUSEF y RECA. **Prioridad**: P1. **Casos**: 5.

**Precondiciones de la historia**: Firma completada; Onboarding exitoso; Correo del titular disponible; Contrato vigente identificado

#### CA01

> Dado que el usuario finalizó firma y onboarding exitosamente Cuando se genera el evento de confirmación de cuenta Entonces el sistema envía correo electrónico al titular con la documentacion ( (contrato múltiple de crédito para persona fisica(RECA asignado es: 1654-999-037863/09-01070-0526), tabla de comisiones, carátula y portada de tarjeta asi como contrato de servicios digitales y carátula de servicios digitales) (welcome Kit)

**TC-ORG-009 — Disparo de correo contractual**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Correo sintético prospecto@ejemplo.mx; paquete de seis documentos contractuales
- **Dado** que el usuario finalizó firma y onboarding exitosamente
- **Cuando** se genera el evento de confirmación de cuenta
- **Resultado esperado**: el sistema envía correo electrónico al titular con la documentacion ( (contrato múltiple de crédito para persona fisica(RECA asignado es: 1654-999-037863/09-01070-0526), tabla de comisiones, carátula y portada de tarjeta asi como contrato de servicios digitales y carátula de servicios digitales) (welcome Kit)
- **Casuísticas**: Correo válido; buzón lleno; correo rebotado; firma no concluida

**TC-ORG-010 — No se envía el correo si la firma no concluyó**

Partición de equivalencia, caso negativo, derivado.

- **Datos de entrada**: Firma abandonada en el paso previo a confirmar
- **Dado** Un proceso de firma interrumpido antes de concluir
- **Cuando** se evalúa el envío del correo contractual
- **Resultado esperado**: el correo no se dispara
- **Casuísticas**: Abandono voluntario; caída de sesión; firma rechazada

#### CA02

> Dado que se envía el correo contractual Cuando el titular recibe la comunicación Entonces el correo incluye el contrato en formato PDF(contrato múltiple de crédito para persona fisica(RECA asignado es: 1654-999-037863/09-01070-0526), tabla de comisiones, carátula y portada de tarjeta asi como contrato de servicios digitales y carátula de servicios digitales)

**TC-ORG-011 — Documentos PDF**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Correo sintético prospecto@ejemplo.mx; paquete de seis documentos contractuales
- **Dado** que se envía el correo contractual
- **Cuando** el titular recibe la comunicación
- **Resultado esperado**: el correo incluye el contrato en formato PDF(contrato múltiple de crédito para persona fisica(RECA asignado es: 1654-999-037863/09-01070-0526), tabla de comisiones, carátula y portada de tarjeta asi como contrato de servicios digitales y carátula de servicios digitales)
- **Casuísticas**: Correo válido; buzón lleno; correo rebotado; firma no concluida

**TC-ORG-012 — Falta uno de los documentos del paquete**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Paquete con cinco de seis documentos
- **Dado** Un envío contractual al que le falta uno de los seis documentos
- **Cuando** el titular recibe el correo
- **Resultado esperado**: la falta se detecta y el envío se marca como incompleto
- **Casuísticas**: Falta el contrato; falta la carátula; falta la tabla de comisiones

#### CA03

> Dado que el proceso de firma u onboarding no concluyó exitosamente Cuando se evalúa el envío contractual Entonces el sistema no dispara el correo contractual de cierre

**TC-ORG-013 — No envío sin finalización**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Correo sintético prospecto@ejemplo.mx; paquete de seis documentos contractuales
- **Dado** que el proceso de firma u onboarding no concluyó exitosamente
- **Cuando** se evalúa el envío contractual
- **Resultado esperado**: el sistema no dispara el correo contractual de cierre
- **Casuísticas**: Correo válido; buzón lleno; correo rebotado; firma no concluida

---

### HDU-TDC-R4-04. Aplicar Coltrane en bloques iniciales y validación temprana

**Bloque funcional**: Preparación / TyC / Validación de Teléfono / Validación del Cliente

**Marco regulatorio**: No regulatorio. **Prioridad**: P3. **Casos**: 4.

**Precondiciones de la historia**: Figma Mobile y Desktop disponible; BB iniciales existentes en flujo APOLO; Alcance limitado a cambio visual/patrón de interacción(Consultar con equipo ejemplos de en figma correspondientes, fuentes) (Administracion de accesos a jira)

#### CA01

> Dado que el prospecto accede al BB Preparación Cuando se carga la pantalla correspondiente Entonces los estilos cumplen el sistema Coltrane conforme a Figma

**TC-ORG-014 — Aplicación visual en Preparación**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el prospecto accede al BB Preparación
- **Cuando** se carga la pantalla correspondiente
- **Resultado esperado**: los estilos cumplen el sistema Coltrane conforme a Figma
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

#### CA02

> Dado que el prospecto visualiza el BB de Términos y Condiciones Cuando se muestran componentes de lectura o aceptación Entonces tipografía, colores y espaciados corresponden al Figma anexo

**TC-ORG-015 — Aplicación visual en Términos y Condiciones**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el prospecto visualiza el BB de Términos y Condiciones
- **Cuando** se muestran componentes de lectura o aceptación
- **Resultado esperado**: tipografía, colores y espaciados corresponden al Figma anexo
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

#### CA03

> Dado que el prospecto captura o valida teléfono Cuando se presenta el formulario de teléfono Entonces los componentes visuales corresponden a Coltrane

**TC-ORG-016 — Aplicación visual en Validación de Teléfono**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el prospecto captura o valida teléfono
- **Cuando** se presenta el formulario de teléfono
- **Resultado esperado**: los componentes visuales corresponden a Coltrane
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

#### CA04

> Dado que el flujo muestra validación de cliente Cuando el usuario interactúa con la pantalla Entonces la experiencia visual se mantiene consistente con Coltrane

**TC-ORG-017 — Aplicación visual en Validación del Cliente**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el flujo muestra validación de cliente
- **Cuando** el usuario interactúa con la pantalla
- **Resultado esperado**: la experiencia visual se mantiene consistente con Coltrane
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

---

### HDU-TDC-R4-05. Aplicar Coltrane en bloques de perfilamiento, riesgo y decisión

**Bloque funcional**: Perfilamiento / Validación de Domicilio / KYC-PEP / PLD / Persona Vulnerable / Validación SIC / Paramétrico

**Marco regulatorio**: No regulatorio. **Prioridad**: P3. **Casos**: 4.

**Precondiciones de la historia**: Figma anexo disponible; Pantallas de los BB identificadas; No se modifica lógica de validación ni decisión (Consultar con equipo ejemplos de en figma correspondientes fuentes)  (Administración de accesos a jira)

#### CA01

> Dado que el usuario se encuentra en Perfilamiento Cuando se cargan preguntas o formularios Entonces los componentes visuales aplican Coltrane

**TC-ORG-018 — Aplicación en Perfilamiento**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el usuario se encuentra en Perfilamiento
- **Cuando** se cargan preguntas o formularios
- **Resultado esperado**: los componentes visuales aplican Coltrane
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

#### CA02

> Dado que el usuario captura o valida domicilio Cuando se muestra la pantalla correspondiente Entonces la interfaz mantiene tipografía, paleta y espaciados definidos

**TC-ORG-019 — Aplicación en Domicilio**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el usuario captura o valida domicilio
- **Cuando** se muestra la pantalla correspondiente
- **Resultado esperado**: la interfaz mantiene tipografía, paleta y espaciados definidos
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

#### CA03

> Dado que el usuario transita por KYC/PEP, PLD o Persona Vulnerable Cuando se muestran preguntas, radio buttons o listas Entonces los componentes cumplen el patrón visual del Figma

**TC-ORG-020 — Aplicación en bloques de riesgo**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el usuario transita por KYC/PEP, PLD o Persona Vulnerable
- **Cuando** se muestran preguntas, radio buttons o listas
- **Resultado esperado**: los componentes cumplen el patrón visual del Figma
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

#### CA04

> Dado que el usuario llega a Validación SIC o Paramétrico Cuando se muestran formularios, cargas o respuestas Entonces el look and feel permanece alineado a Coltrane

**TC-ORG-021 — Aplicación en decisión crediticia**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el usuario llega a Validación SIC o Paramétrico
- **Cuando** se muestran formularios, cargas o respuestas
- **Resultado esperado**: el look and feel permanece alineado a Coltrane
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

---

### HDU-TDC-R4-06. Aplicar Coltrane en oferta, autenticación, expediente y cierre

**Bloque funcional**: Oferta de Producto / Prueba de Vida / Solicitud de Servicios Digitales / Validación de Correo / Integración de Expediente Digital / Bienvenida

**Marco regulatorio**: No regulatorio. **Prioridad**: P3. **Casos**: 4.

**Precondiciones de la historia**: Figma anexo disponible; Bloques finales vigentes en APOLO; Cambio limitado a experiencia visual/patrones

#### CA01

> Dado que el prospecto visualiza la oferta Cuando se muestran monto, condiciones o aceptación Entonces la pantalla sigue los estilos Coltrane del Figma

**TC-ORG-022 — Aplicación en Oferta de Producto**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el prospecto visualiza la oferta
- **Cuando** se muestran monto, condiciones o aceptación
- **Resultado esperado**: la pantalla sigue los estilos Coltrane del Figma
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

#### CA02

> Dado que el prospecto accede a prueba de vida o video selfie Cuando se muestran instrucciones y controles Entonces la interfaz cumple los componentes visuales definidos

**TC-ORG-023 — Aplicación en Prueba de Vida**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el prospecto accede a prueba de vida o video selfie
- **Cuando** se muestran instrucciones y controles
- **Resultado esperado**: la interfaz cumple los componentes visuales definidos
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

#### CA03

> Dado que el usuario solicita servicios digitales o valida correo Cuando interactúa con las pantallas del flujo Entonces los patrones visuales se mantienen consistentes

**TC-ORG-024 — Aplicación en servicios digitales y correo**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el usuario solicita servicios digitales o valida correo
- **Cuando** interactúa con las pantallas del flujo
- **Resultado esperado**: los patrones visuales se mantienen consistentes
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

#### CA04

> Dado que el proceso llega a integración de expediente o bienvenida Cuando se muestran documentos, estado o cierre Entonces las pantallas cumplen Coltrane en mobile y desktop

**TC-ORG-025 — Aplicación en expediente y bienvenida**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; referencia visual del diseño aprobado
- **Dado** que el proceso llega a integración de expediente o bienvenida
- **Cuando** se muestran documentos, estado o cierre
- **Resultado esperado**: las pantallas cumplen Coltrane en mobile y desktop
- **Casuísticas**: Teléfono móvil; escritorio; pantalla reducida; modo de accesibilidad

---

### HDU-TDC-R4-07. Capturar la declaración inicial de persona vulnerable

**Bloque funcional**: Persona Vulnerable

**Marco regulatorio**: CONDUSEF grupos prioritarios. **Prioridad**: P1. **Casos**: 13.

**Precondiciones de la historia**: Prospecto dentro del flujo APOLO; BB Persona Vulnerable habilitado; Opciones de respuesta definidas; Respuesta inicial Sí capturada; Listado de opciones aprobado; Base de datos disponible para persistencia

#### CA01

> Dado que el prospecto llega al BB Persona Vulnerable Cuando se muestra la pantalla principal Entonces el sistema presenta la pregunta obligatoria indicada

**TC-ORG-026 — Carga de pregunta obligatoria**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el prospecto llega al BB Persona Vulnerable
- **Cuando** se muestra la pantalla principal
- **Resultado esperado**: el sistema presenta la pregunta obligatoria indicada
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; sin respuesta; una opción; varias opciones

#### CA02

> Dado que la pantalla de Persona Vulnerable está visible Cuando el prospecto revisa las alternativas Entonces se muestran Sí, No y Prefiero no contestar como radio buttons

**TC-ORG-027 — Opciones de respuesta**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que la pantalla de Persona Vulnerable está visible
- **Cuando** el prospecto revisa las alternativas
- **Resultado esperado**: se muestran Sí, No y Prefiero no contestar como radio buttons
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; sin respuesta; una opción; varias opciones

#### CA03

> Dado que el prospecto intenta continuar sin elegir una opción Cuando presiona Continuar Entonces el sistema impide avanzar hasta seleccionar una respuesta

**TC-ORG-028 — Respuesta obligatoria**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el prospecto intenta continuar sin elegir una opción
- **Cuando** presiona Continuar
- **Resultado esperado**: el sistema impide avanzar hasta seleccionar una respuesta
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; sin respuesta; una opción; varias opciones

**TC-ORG-029 — Avance bloqueado sin respuesta seleccionada**

Partición de equivalencia, caso negativo, derivado.

- **Datos de entrada**: Ninguna opción marcada
- **Dado** Una pantalla de declaración sin opción seleccionada
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide avanzar y señala el campo obligatorio
- **Casuísticas**: Primer intento; segundo intento; tras recargar la pantalla

#### CA04

> Dado que el prospecto selecciona Sí en la pregunta inicial Cuando el sistema actualiza la pantalla Entonces se muestra el listado de selección múltiple

**TC-ORG-030 — Despliegue condicional**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el prospecto selecciona Sí en la pregunta inicial
- **Cuando** el sistema actualiza la pantalla
- **Resultado esperado**: se muestra el listado de selección múltiple
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; sin respuesta; una opción; varias opciones

#### CA05

> Dado que el listado se encuentra visible Cuando el prospecto marca una o varias opciones Entonces el sistema permite mantener múltiples selecciones

**TC-ORG-031 — Selección múltiple**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el listado se encuentra visible
- **Cuando** el prospecto marca una o varias opciones
- **Resultado esperado**: el sistema permite mantener múltiples selecciones
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; sin respuesta; una opción; varias opciones

#### CA06

> Dado que el prospecto seleccionó las opciones aplicables Cuando presiona Continuar Entonces el sistema guarda la información asociada al perfil y continúa el flujo almacenando información en informix/yuga)

**TC-ORG-032 — Persistencia y avance**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el prospecto seleccionó las opciones aplicables
- **Cuando** presiona Continuar
- **Resultado esperado**: el sistema guarda la información asociada al perfil y continúa el flujo almacenando información en informix/yuga)
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; sin respuesta; una opción; varias opciones

**TC-ORG-033 — La respuesta queda persistida y es recuperable**

Partición de equivalencia, caso positivo, derivado.

- **Datos de entrada**: Respuesta afirmativa con dos opciones marcadas
- **Dado** Una respuesta ya guardada
- **Cuando** se consulta el perfil del prospecto
- **Resultado esperado**: la respuesta es recuperable y corresponde a lo capturado
- **Casuísticas**: Una opción; varias opciones; respuesta negativa

**TC-ORG-034 — Fallo de persistencia de la respuesta**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Almacenamiento no disponible
- **Dado** Un fallo del almacenamiento al guardar
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema no avanza en silencio y el dato no se pierde
- **Casuísticas**: Fallo al escribir; fallo al confirmar; recuperación posterior

#### CA07

> Dado que el enlace ¿Para qué usamos esta información? está visible Cuando el prospecto hace clic en el enlace Entonces el sistema abre un popup con el texto informativo correspondiente

**TC-ORG-035 — Apertura de popup**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el enlace ¿Para qué usamos esta información? está visible
- **Cuando** el prospecto hace clic en el enlace
- **Resultado esperado**: el sistema abre un popup con el texto informativo correspondiente
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; sin respuesta; una opción; varias opciones

#### CA08

> Dado que el popup informativo está abierto Cuando el usuario selecciona cerrar Entonces el sistema regresa a la pantalla sin borrar la respuesta capturada

**TC-ORG-036 — Cierre sin pérdida de progreso**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el popup informativo está abierto
- **Cuando** el usuario selecciona cerrar
- **Resultado esperado**: el sistema regresa a la pantalla sin borrar la respuesta capturada
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; sin respuesta; una opción; varias opciones

**TC-ORG-037 — El progreso se conserva al cerrar la ventana informativa**

Transición de estado, caso positivo, derivado.

- **Datos de entrada**: Respuesta afirmativa capturada antes de abrir la ventana
- **Dado** Una respuesta capturada y la ventana informativa abierta
- **Cuando** el prospecto cierra la ventana
- **Resultado esperado**: la respuesta capturada permanece
- **Casuísticas**: Cierre con el botón; cierre con gesto; cierre con tecla de retroceso

#### CA09

> Dado que el prospecto selecciona No o Prefiero no contestar Cuando presiona Continuar Entonces el sistema persiste la respuesta y continúa el flujo sin desplegar listado adicional

**TC-ORG-038 — Continuidad con respuesta no afirmativa**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el prospecto selecciona No o Prefiero no contestar
- **Cuando** presiona Continuar
- **Resultado esperado**: el sistema persiste la respuesta y continúa el flujo sin desplegar listado adicional
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; sin respuesta; una opción; varias opciones

---

### HDU-TDC-R4-08. Desplegar y guardar opciones de grupo prioritario cuando el prospecto responde Sí

**Bloque funcional**: Persona Vulnerable

**Marco regulatorio**: CONDUSEF grupos prioritarios. **Prioridad**: P1. **Casos**: 5.

**Precondiciones de la historia**: Respuesta inicial Sí capturada; Listado de opciones aprobado; Base de datos disponible para persistencia

#### CA01

> Dado que el prospecto selecciona Sí en la pregunta inicial Cuando el sistema actualiza la pantalla Entonces se muestra el listado de selección múltiple

**TC-ORG-039 — Despliegue condicional**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el prospecto selecciona Sí en la pregunta inicial
- **Cuando** el sistema actualiza la pantalla
- **Resultado esperado**: se muestra el listado de selección múltiple
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; una opción; varias opciones

#### CA02

> Dado que el prospecto selecciona No o Prefiero no contestar Cuando el sistema evalúa la respuesta Entonces no se muestra el listado de selección múltiple

**TC-ORG-040 — No despliegue con otras respuestas**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el prospecto selecciona No o Prefiero no contestar
- **Cuando** el sistema evalúa la respuesta
- **Resultado esperado**: no se muestra el listado de selección múltiple
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; una opción; varias opciones

**TC-ORG-041 — El listado no aparece con respuesta negativa ni con la reservada**

Partición de equivalencia, caso negativo, derivado.

- **Datos de entrada**: Respuesta No; respuesta Prefiero no contestar
- **Dado** Un prospecto que responde no y, en otra ejecución, prefiero no contestar
- **Cuando** el sistema evalúa la respuesta
- **Resultado esperado**: el listado no se despliega en ninguno de los dos casos
- **Casuísticas**: Respuesta negativa; respuesta reservada; cambio de respuesta tras desplegar

#### CA03

> Dado que el listado se encuentra visible Cuando el prospecto marca una o varias opciones Entonces el sistema permite mantener múltiples selecciones

**TC-ORG-042 — Selección múltiple**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el listado se encuentra visible
- **Cuando** el prospecto marca una o varias opciones
- **Resultado esperado**: el sistema permite mantener múltiples selecciones
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; una opción; varias opciones

#### CA04

> Dado que el prospecto seleccionó las opciones aplicables Cuando presiona Continuar Entonces el sistema guarda la información asociada al perfil y continúa el flujo

**TC-ORG-043 — Persistencia y avance**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Sí, No, Prefiero no contestar; listado de grupos prioritarios
- **Dado** que el prospecto seleccionó las opciones aplicables
- **Cuando** presiona Continuar
- **Resultado esperado**: el sistema guarda la información asociada al perfil y continúa el flujo
- **Casuísticas**: Respuesta afirmativa; negativa; reservada; una opción; varias opciones

---

### HDU-TDC-R4-10. Actualizar imagen de tarjeta y textos legales en pantallas clave

**Bloque funcional**: Preparación/ Oferta de Producto / Bienvenida

**Marco regulatorio**: No regulatorio. **Prioridad**: P3. **Casos**: 4.

**Precondiciones de la historia**: Figma anexo disponible; Pantallas Inicio, Oferta y Bienvenida identificadas; Textos legales aprobados

#### CA01

> Dado que el usuario accede a Inicio Cuando se carga la pantalla Entonces se muestra la imagen de tarjeta de crédito BanCoppel conforme a Figma

**TC-ORG-044 — Imagen correcta en Inicio**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; imagen de tarjeta de crédito vigente
- **Dado** que el usuario accede a Inicio
- **Cuando** se carga la pantalla
- **Resultado esperado**: se muestra la imagen de tarjeta de crédito BanCoppel conforme a Figma
- **Casuísticas**: Inicio; oferta de producto; bienvenida; móvil y escritorio

#### CA02

> Dado que el usuario visualiza Oferta de Producto o Bienvenida Cuando se muestran elementos de tarjeta Entonces la imagen corresponde a tarjeta de crédito y no de débito

**TC-ORG-045 — Imagen correcta en Oferta y Bienvenida**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; imagen de tarjeta de crédito vigente
- **Dado** que el usuario visualiza Oferta de Producto o Bienvenida
- **Cuando** se muestran elementos de tarjeta
- **Resultado esperado**: la imagen corresponde a tarjeta de crédito y no de débito
- **Casuísticas**: Inicio; oferta de producto; bienvenida; móvil y escritorio

#### CA03

> Dado que la pantalla de Oferta de Producto presenta la leyenda correspondiente Cuando se renderiza la palabra preaprobada Entonces la palabra se muestra sin guion

**TC-ORG-046 — Texto preaprobada**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; imagen de tarjeta de crédito vigente
- **Dado** que la pantalla de Oferta de Producto presenta la leyenda correspondiente
- **Cuando** se renderiza la palabra preaprobada
- **Resultado esperado**: la palabra se muestra sin guion
- **Casuísticas**: Inicio; oferta de producto; bienvenida; móvil y escritorio

#### CA04

> Dado que el usuario visualiza la leyenda de aceptación de oferta Cuando el sistema muestra el texto legal Entonces la denominación BanCoppel se incluye en la leyenda (definicion por ux)

**TC-ORG-047 — Denominación Tarjeta de crédito BanCoppel**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; imagen de tarjeta de crédito vigente
- **Dado** que el usuario visualiza la leyenda de aceptación de oferta
- **Cuando** el sistema muestra el texto legal
- **Resultado esperado**: la denominación BanCoppel se incluye en la leyenda (definicion por ux)
- **Casuísticas**: Inicio; oferta de producto; bienvenida; móvil y escritorio

---

### HDU-TDC-R4-13. Validar al solicitante contra listas negras en Perfilamiento/ listas negras de PLD

**Bloque funcional**: Perfilamiento LISTAS NEGRAS PLD / Name Matching

**Marco regulatorio**: PLD listas de personas bloqueadas. **Prioridad**: P1. **Casos**: 9.

**Precondiciones de la historia**: Datos del solicitante disponibles; Servicio Name Matching disponible; Reglas de KO actuales vigentes

#### CA01

> Dado que el usuario llega a Perfilamiento/PLD con datos del solicitante disponibles Cuando el sistema ejecuta validación Name Matching (listas negras) si dicha consulta no resolviera se debe consultar a informix (100%) Entonces se consulta al solicitante contra listas negras o bloqueantes

**TC-ORG-048 — Consulta de solicitante**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Nombre sintético con coincidencia bloqueante; nombre sin coincidencia; homónimo parcial
- **Dado** que el usuario llega a Perfilamiento/PLD con datos del solicitante disponibles
- **Cuando** el sistema ejecuta validación Name Matching (listas negras) si dicha consulta no resolviera se debe consultar a informix (100%)
- **Resultado esperado**: se consulta al solicitante contra listas negras o bloqueantes
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; servicio sin respuesta

**TC-ORG-049 — La consulta primaria no resuelve y se recurre al respaldo**

Transición de estado, caso positivo, derivado.

- **Datos de entrada**: Servicio primario sin respuesta
- **Dado** Una consulta de coincidencia de nombre que no obtiene respuesta
- **Cuando** el sistema aplica el respaldo previsto
- **Resultado esperado**: la validación se completa y queda registrada la vía utilizada
- **Casuísticas**: Tiempo agotado; error del servicio; respuesta vacía

**TC-ORG-050 — Ni la consulta primaria ni el respaldo resuelven**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Ambos servicios sin respuesta
- **Dado** Una consulta y su respaldo, ambos sin respuesta
- **Cuando** el sistema evalúa el resultado
- **Resultado esperado**: la solicitud no avanza sin validación y el estado queda explícito
- **Casuísticas**: Ambos con tiempo agotado; ambos con error; uno vacío y otro con error

#### CA02

> Dado que la consulta devuelve coincidencia bloqueante Cuando el sistema procesa el resultado Entonces se genera KO y se muestra TYP (Debera mostrar mensaje: Gracias por tu interés. Por ahora no es posible avanzar con tu solicitud)

**TC-ORG-051 — Resultado HIT**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Nombre sintético con coincidencia bloqueante; nombre sin coincidencia; homónimo parcial
- **Dado** que la consulta devuelve coincidencia bloqueante
- **Cuando** el sistema procesa el resultado
- **Resultado esperado**: se genera KO y se muestra TYP (Debera mostrar mensaje: Gracias por tu interés. Por ahora no es posible avanzar con tu solicitud)
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; servicio sin respuesta

**TC-ORG-052 — Coincidencia parcial que no debe bloquear a un homónimo**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Nombre sintético con coincidencia parcial de apellidos
- **Dado** Un nombre que coincide parcialmente sin ser la persona listada
- **Cuando** el sistema evalúa la coincidencia
- **Resultado esperado**: el resultado no genera rechazo automático y se somete a revisión
- **Casuísticas**: Coincidencia de nombre y un apellido; de ambos apellidos; con fecha de nacimiento distinta

#### CA03

> Dado que la consulta no devuelve coincidencia bloqueante Cuando el sistema procesa la respuesta Entonces el flujo continúa al siguiente paso

**TC-ORG-053 — Resultado NO HIT**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Nombre sintético con coincidencia bloqueante; nombre sin coincidencia; homónimo parcial
- **Dado** que la consulta no devuelve coincidencia bloqueante
- **Cuando** el sistema procesa la respuesta
- **Resultado esperado**: el flujo continúa al siguiente paso
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; servicio sin respuesta

#### CA04

> Dado que se genera un KO por listas negras Cuando se registra el resultado funcional Entonces el rechazo queda asociado al solicitante/prospecto evaluado (Valores deberan guardarse en bitacora Clave RLN, Causa 66, SE:U)

**TC-ORG-054 — Trazabilidad de rechazo**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Nombre sintético con coincidencia bloqueante; nombre sin coincidencia; homónimo parcial
- **Dado** que se genera un KO por listas negras
- **Cuando** se registra el resultado funcional
- **Resultado esperado**: el rechazo queda asociado al solicitante/prospecto evaluado (Valores deberan guardarse en bitacora Clave RLN, Causa 66, SE:U)
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; servicio sin respuesta

**TC-ORG-055 — El rechazo queda en bitácora con clave RLN, causa 66 y origen U**

Partición de equivalencia, caso positivo, derivado.

- **Datos de entrada**: Rechazo con clave RLN, causa 66, origen U
- **Dado** Un rechazo generado por coincidencia en listas
- **Cuando** se consulta la bitácora funcional
- **Resultado esperado**: existe el registro con clave RLN, causa 66 y origen U asociado al evaluado
- **Casuísticas**: Un rechazo; rechazos consecutivos del mismo prospecto; rechazo tras reintento

**TC-ORG-056 — El rechazo no queda en bitácora**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Servicio de bitácora no disponible al momento del rechazo
- **Dado** Un rechazo por listas cuyo registro de bitácora falla
- **Cuando** se consulta la bitácora funcional
- **Resultado esperado**: la ausencia se detecta, porque sin registro no hay evidencia ante el regulador
- **Casuísticas**: Bitácora caída; escritura parcial; escritura duplicada

---

### HDU-TDC-R4-14. Validar al familiar con cargo público contra listas negras

**Bloque funcional**: KYC / PEP / Name Matching

**Marco regulatorio**: PLD persona políticamente expuesta. **Prioridad**: P1. **Casos**: 9.

**Precondiciones de la historia**: Datos del familiar con cargo público capturados; BB PEP(KYC) habilitado; Servicio Name Matching disponible

#### CA01

> Dado que el prospecto declara familiar con cargo público Cuando el flujo llega al BB PEP(KYC) y validación Name Matching (listas negras) si dicha consulta no resolviera se debe consultar a informix (100%) Entonces el sistema consulta al familiar en listas negras o bloqueantes

**TC-ORG-057 — Consulta del familiar PEP**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Declaración de familiar con cargo público; nombre del familiar con y sin coincidencia
- **Dado** que el prospecto declara familiar con cargo público
- **Cuando** el flujo llega al BB PEP(KYC) y validación Name Matching (listas negras) si dicha consulta no resolviera se debe consultar a informix (100%)
- **Resultado esperado**: el sistema consulta al familiar en listas negras o bloqueantes
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; servicio sin respuesta

**TC-ORG-058 — La consulta primaria no resuelve y se recurre al respaldo**

Transición de estado, caso positivo, derivado.

- **Datos de entrada**: Servicio primario sin respuesta
- **Dado** Una consulta de coincidencia de nombre que no obtiene respuesta
- **Cuando** el sistema aplica el respaldo previsto
- **Resultado esperado**: la validación se completa y queda registrada la vía utilizada
- **Casuísticas**: Tiempo agotado; error del servicio; respuesta vacía

**TC-ORG-059 — Ni la consulta primaria ni el respaldo resuelven**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Ambos servicios sin respuesta
- **Dado** Una consulta y su respaldo, ambos sin respuesta
- **Cuando** el sistema evalúa el resultado
- **Resultado esperado**: la solicitud no avanza sin validación y el estado queda explícito
- **Casuísticas**: Ambos con tiempo agotado; ambos con error; uno vacío y otro con error

#### CA02

> Dado que Name Matching identifica coincidencia bloqueante Cuando el sistema evalúa el resultado Entonces se genera KO y TYP con estatus Rechazo Listas Negras Persona Políticamente Expuesta(Debera mostrar mensaje: Gracias por tu interés. Por ahora no es posible avanzar con tu solicitud)

**TC-ORG-060 — HIT familiar PEP**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Declaración de familiar con cargo público; nombre del familiar con y sin coincidencia
- **Dado** que Name Matching identifica coincidencia bloqueante
- **Cuando** el sistema evalúa el resultado
- **Resultado esperado**: se genera KO y TYP con estatus Rechazo Listas Negras Persona Políticamente Expuesta(Debera mostrar mensaje: Gracias por tu interés. Por ahora no es posible avanzar con tu solicitud)
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; servicio sin respuesta

**TC-ORG-061 — Coincidencia parcial que no debe bloquear a un homónimo**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Nombre sintético con coincidencia parcial de apellidos
- **Dado** Un nombre que coincide parcialmente sin ser la persona listada
- **Cuando** el sistema evalúa la coincidencia
- **Resultado esperado**: el resultado no genera rechazo automático y se somete a revisión
- **Casuísticas**: Coincidencia de nombre y un apellido; de ambos apellidos; con fecha de nacimiento distinta

#### CA03

> Dado que la validación no encuentra coincidencia Cuando el sistema recibe la respuesta Entonces el flujo continúa al siguiente paso

**TC-ORG-062 — NO HIT familiar PEP**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Declaración de familiar con cargo público; nombre del familiar con y sin coincidencia
- **Dado** que la validación no encuentra coincidencia
- **Cuando** el sistema recibe la respuesta
- **Resultado esperado**: el flujo continúa al siguiente paso
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; servicio sin respuesta

#### CA04

> Dado que se genera un KO por listas negras del familiar Cuando se obtiene el resultado Entonces el sistema conserva trazabilidad funcional del resultado evaluado (Valores deberan guardar en bitacora Clave LNE, Causa 117 y SE:P)

**TC-ORG-063 — Trazabilidad de rechazo**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Declaración de familiar con cargo público; nombre del familiar con y sin coincidencia
- **Dado** que se genera un KO por listas negras del familiar
- **Cuando** se obtiene el resultado
- **Resultado esperado**: el sistema conserva trazabilidad funcional del resultado evaluado (Valores deberan guardar en bitacora Clave LNE, Causa 117 y SE:P)
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; servicio sin respuesta

**TC-ORG-064 — El rechazo queda en bitácora con clave LNE, causa 117 y origen P**

Partición de equivalencia, caso positivo, derivado.

- **Datos de entrada**: Rechazo con clave LNE, causa 117, origen P
- **Dado** Un rechazo generado por coincidencia en listas
- **Cuando** se consulta la bitácora funcional
- **Resultado esperado**: existe el registro con clave LNE, causa 117 y origen P asociado al evaluado
- **Casuísticas**: Un rechazo; rechazos consecutivos del mismo prospecto; rechazo tras reintento

**TC-ORG-065 — El rechazo no queda en bitácora**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Servicio de bitácora no disponible al momento del rechazo
- **Dado** Un rechazo por listas cuyo registro de bitácora falla
- **Cuando** se consulta la bitácora funcional
- **Resultado esperado**: la ausencia se detecta, porque sin registro no hay evidencia ante el regulador
- **Casuísticas**: Bitácora caída; escritura parcial; escritura duplicada

---

### HDU-TDC-R4-16. Validar la referencia contra listas negras en Paramétrico

**Bloque funcional**: PLD / PEP/ Name Matching/parametrico

**Marco regulatorio**: PLD listas de personas bloqueadas. **Prioridad**: P1. **Casos**: 9.

**Precondiciones de la historia**: Referencia capturada; BB Paramétrico habilitado; Servicio Name Matching disponible

#### CA01

> Dado que el flujo llega al BB Paramétrico con referencia disponible Cuando el sistema ejecuta Name Matching (listas negras) si dicha consulta no resolviera se debe consultar a informix (100%) Entonces la referencia se consulta contra listas negras o bloqueantes

**TC-ORG-066 — Consulta de referencia**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Referencia personal declarada, con y sin coincidencia bloqueante
- **Dado** que el flujo llega al BB Paramétrico con referencia disponible
- **Cuando** el sistema ejecuta Name Matching (listas negras) si dicha consulta no resolviera se debe consultar a informix (100%)
- **Resultado esperado**: la referencia se consulta contra listas negras o bloqueantes
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; sin referencia declarada

**TC-ORG-067 — La consulta primaria no resuelve y se recurre al respaldo**

Transición de estado, caso positivo, derivado.

- **Datos de entrada**: Servicio primario sin respuesta
- **Dado** Una consulta de coincidencia de nombre que no obtiene respuesta
- **Cuando** el sistema aplica el respaldo previsto
- **Resultado esperado**: la validación se completa y queda registrada la vía utilizada
- **Casuísticas**: Tiempo agotado; error del servicio; respuesta vacía

**TC-ORG-068 — Ni la consulta primaria ni el respaldo resuelven**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Ambos servicios sin respuesta
- **Dado** Una consulta y su respaldo, ambos sin respuesta
- **Cuando** el sistema evalúa el resultado
- **Resultado esperado**: la solicitud no avanza sin validación y el estado queda explícito
- **Casuísticas**: Ambos con tiempo agotado; ambos con error; uno vacío y otro con error

#### CA02

> Dado que la consulta identifica coincidencia bloqueante Cuando el sistema procesa el resultado Entonces se genera KO (Debera mostrar mensaje: Gracias por tu interés. Por ahora no es posible avanzar con tu solicitud)

**TC-ORG-069 — HIT referencia**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Referencia personal declarada, con y sin coincidencia bloqueante
- **Dado** que la consulta identifica coincidencia bloqueante
- **Cuando** el sistema procesa el resultado
- **Resultado esperado**: se genera KO (Debera mostrar mensaje: Gracias por tu interés. Por ahora no es posible avanzar con tu solicitud)
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; sin referencia declarada

**TC-ORG-070 — Coincidencia parcial que no debe bloquear a un homónimo**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Nombre sintético con coincidencia parcial de apellidos
- **Dado** Un nombre que coincide parcialmente sin ser la persona listada
- **Cuando** el sistema evalúa la coincidencia
- **Resultado esperado**: el resultado no genera rechazo automático y se somete a revisión
- **Casuísticas**: Coincidencia de nombre y un apellido; de ambos apellidos; con fecha de nacimiento distinta

#### CA03

> Dado que la consulta no identifica coincidencia bloqueante Cuando el sistema evalúa la respuesta Entonces el flujo continúa de manera natural

**TC-ORG-071 — NO HIT referencia**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Referencia personal declarada, con y sin coincidencia bloqueante
- **Dado** que la consulta no identifica coincidencia bloqueante
- **Cuando** el sistema evalúa la respuesta
- **Resultado esperado**: el flujo continúa de manera natural
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; sin referencia declarada

#### CA04

> Dado que se genera un KO por listas negras de referencia Cuando el sistema almacena o mantiene trazabilidad Entonces el resultado queda asociado a la referencia evaluada (Valores deberan guardar en bitacoraClave LNE, Causa 119 y SE:P)

**TC-ORG-072 — Trazabilidad de rechazo**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Referencia personal declarada, con y sin coincidencia bloqueante
- **Dado** que se genera un KO por listas negras de referencia
- **Cuando** el sistema almacena o mantiene trazabilidad
- **Resultado esperado**: el resultado queda asociado a la referencia evaluada (Valores deberan guardar en bitacoraClave LNE, Causa 119 y SE:P)
- **Casuísticas**: Coincidencia bloqueante; sin coincidencia; coincidencia parcial; sin referencia declarada

**TC-ORG-073 — El rechazo queda en bitácora con clave LNE, causa 119 y origen P**

Partición de equivalencia, caso positivo, derivado.

- **Datos de entrada**: Rechazo con clave LNE, causa 119, origen P
- **Dado** Un rechazo generado por coincidencia en listas
- **Cuando** se consulta la bitácora funcional
- **Resultado esperado**: existe el registro con clave LNE, causa 119 y origen P asociado al evaluado
- **Casuísticas**: Un rechazo; rechazos consecutivos del mismo prospecto; rechazo tras reintento

**TC-ORG-074 — El rechazo no queda en bitácora**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Servicio de bitácora no disponible al momento del rechazo
- **Dado** Un rechazo por listas cuyo registro de bitácora falla
- **Cuando** se consulta la bitácora funcional
- **Resultado esperado**: la ausencia se detecta, porque sin registro no hay evidencia ante el regulador
- **Casuísticas**: Bitácora caída; escritura parcial; escritura duplicada

---

### HDU-TDC-R4-17. Presentar la pantalla de términos con Contrato Múltiple y Servicios Digitales

**Bloque funcional**: Integración Expediente digital

**Marco regulatorio**: CONDUSEF y RECA. **Prioridad**: P1. **Casos**: 7.

**Precondiciones de la historia**: Correo del prospecto disponible; Documentos legales definidos; Pantalla de formalización habilitada

#### CA01

> Dado que el prospecto llega a la etapa previa a firma Cuando el sistema carga la pantalla de términos Entonces se indica que debe leer y firmar los términos y condiciones de su oferta

**TC-ORG-075 — Pantalla de lectura y firma**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Prospecto en formalización; seis documentos contractuales; correo capturado previamente
- **Dado** que el prospecto llega a la etapa previa a firma
- **Cuando** el sistema carga la pantalla de términos
- **Resultado esperado**: se indica que debe leer y firmar los términos y condiciones de su oferta
- **Casuísticas**: Documentos completos; documento faltante; correo capturado; intento de modificar el correo

#### CA02

> Dado que la pantalla de términos está visible Cuando se muestran los documentos de crédito Entonces se incluye Contrato Múltiple de Crédito con contrato múltiple de crédito para persona fisica(RECA asignado es: 1654-999-037863/09-01070-0526), tabla de comisiones, carátula y portada de tarjeta

**TC-ORG-076 — Campo Contrato Múltiple**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Prospecto en formalización; seis documentos contractuales; correo capturado previamente
- **Dado** que la pantalla de términos está visible
- **Cuando** se muestran los documentos de crédito
- **Resultado esperado**: se incluye Contrato Múltiple de Crédito con contrato múltiple de crédito para persona fisica(RECA asignado es: 1654-999-037863/09-01070-0526), tabla de comisiones, carátula y portada de tarjeta
- **Casuísticas**: Documentos completos; documento faltante; correo capturado; intento de modificar el correo

#### CA03

> Dado que la pantalla de términos está visible Cuando se muestran documentos de servicios digitales Entonces se incluye contrato de servicios digitales y carátula de servicios digitales

**TC-ORG-077 — Campo Servicios Digitales**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Prospecto en formalización; seis documentos contractuales; correo capturado previamente
- **Dado** que la pantalla de términos está visible
- **Cuando** se muestran documentos de servicios digitales
- **Resultado esperado**: se incluye contrato de servicios digitales y carátula de servicios digitales
- **Casuísticas**: Documentos completos; documento faltante; correo capturado; intento de modificar el correo

#### CA04

> Dado que prospecto se encuentra en pantalla de integracion de expediente digital Cuando se muestra dato en pantalla Entonces se mostrara corereo electronico del prospecto capturado previamente sin opción a modificación

**TC-ORG-078 — Mostrar correo electronico**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Prospecto en formalización; seis documentos contractuales; correo capturado previamente
- **Dado** que prospecto se encuentra en pantalla de integracion de expediente digital
- **Cuando** se muestra dato en pantalla
- **Resultado esperado**: se mostrara corereo electronico del prospecto capturado previamente sin opción a modificación
- **Casuísticas**: Documentos completos; documento faltante; correo capturado; intento de modificar el correo

#### CA05

> Dado que el correo del prospecto está disponible Cuando se muestra la pantalla de términos Entonces se presenta el mensaje de envío de documentación al correo del prospecto

**TC-ORG-079 — Mensaje de envío a correo**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Prospecto en formalización; seis documentos contractuales; correo capturado previamente
- **Dado** que el correo del prospecto está disponible
- **Cuando** se muestra la pantalla de términos
- **Resultado esperado**: se presenta el mensaje de envío de documentación al correo del prospecto
- **Casuísticas**: Documentos completos; documento faltante; correo capturado; intento de modificar el correo

#### CA06

> Dado que el prospecto se encuenra en pantalla de expediente digital Cuando se realiza la firma del expediente Entonces se debe guardar (contrato múltiple de crédito para persona fisica(RECA asignado es: 1654-999-037863/09-01070-0526), tabla de comisiones, carátula y portada de tarjeta asi como contrato de servicios digitales y carátula de servicios digitales) en Onbase

**TC-ORG-080 — Resguardo documental**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Prospecto en formalización; seis documentos contractuales; correo capturado previamente
- **Dado** que el prospecto se encuenra en pantalla de expediente digital
- **Cuando** se realiza la firma del expediente
- **Resultado esperado**: se debe guardar (contrato múltiple de crédito para persona fisica(RECA asignado es: 1654-999-037863/09-01070-0526), tabla de comisiones, carátula y portada de tarjeta asi como contrato de servicios digitales y carátula de servicios digitales) en Onbase
- **Casuísticas**: Documentos completos; documento faltante; correo capturado; intento de modificar el correo

**TC-ORG-081 — El resguardo documental falla**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Repositorio documental no disponible
- **Dado** Una firma concluida cuyo resguardo documental no se completa
- **Cuando** se consulta el repositorio documental
- **Resultado esperado**: la ausencia se detecta y el expediente no se da por cerrado
- **Casuísticas**: Repositorio caído; resguardo parcial; documento corrupto

---

### HDU-TDC-R4-18. Permitir lectura de documentos y avance a firma electrónica

**Bloque funcional**: Integración de Expediente Digital

**Marco regulatorio**: CONDUSEF. **Prioridad**: P1. **Casos**: 4.

**Precondiciones de la historia**: Documentos disponibles para lectura; Regla de no personalización definida; Flujo de firma electrónica habilitado

#### CA01

> Dado que el cliente se encuentra en pantalla de servicios digitales Cuando el prospecto selecciona los vinculos (contrato múltiple de crédito o contrato de servicios digitales) Entonces el sistema muestra los contratos correspondientes al vinculo seleccionado para lectura detallada

**TC-ORG-082 — Apertura de documentos**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Documentos en modo de lectura previa, sin personalizar
- **Dado** que el cliente se encuentra en pantalla de servicios digitales
- **Cuando** el prospecto selecciona los vinculos (contrato múltiple de crédito o contrato de servicios digitales)
- **Resultado esperado**: el sistema muestra los contratos correspondientes al vinculo seleccionado para lectura detallada
- **Casuísticas**: Contrato de crédito; contrato de servicios digitales; ambos; documento no disponible

#### CA02

> Dado que los documentos se presentan en modo lectura previa Cuando el prospecto revisa el contenido Entonces no se muestran datos del cliente, crédito o producto

**TC-ORG-083 — Documentos sin datos personalizados**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Documentos en modo de lectura previa, sin personalizar
- **Dado** que los documentos se presentan en modo lectura previa
- **Cuando** el prospecto revisa el contenido
- **Resultado esperado**: no se muestran datos del cliente, crédito o producto
- **Casuísticas**: Contrato de crédito; contrato de servicios digitales; ambos; documento no disponible

**TC-ORG-084 — Fuga de datos del cliente en la lectura previa**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Documento en lectura previa de un prospecto con datos ya capturados
- **Dado** Un documento en modo de lectura previa
- **Cuando** se inspecciona su contenido
- **Resultado esperado**: no aparece ningún dato del cliente, del crédito ni del producto
- **Casuísticas**: Contrato de crédito; contrato de servicios digitales; carátula

#### CA03

> Dado que el contrato de Servicios Digitales se muestra al prospecto Cuando se despliega su contenido Entonces también se visualiza la carátula de servicios digitales

**TC-ORG-085 — Visualización de carátula de servicios digitales**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Documentos en modo de lectura previa, sin personalizar
- **Dado** que el contrato de Servicios Digitales se muestra al prospecto
- **Cuando** se despliega su contenido
- **Resultado esperado**: también se visualiza la carátula de servicios digitales
- **Casuísticas**: Contrato de crédito; contrato de servicios digitales; ambos; documento no disponible

---

### HDU-TDC-R4-19. Mostrar información de activación de servicios digitales mediante popup

**Bloque funcional**: Integración de Expediente Digital

**Marco regulatorio**: CONDUSEF. **Prioridad**: P1. **Casos**: 5.

**Precondiciones de la historia**: Contenido aprobado por Marketing/UX/Negocio( validardependencia de HDU de cambio de marca fase 2 ); Pantalla de servicios digitales habilitada; Popup definido

#### CA01

> Dado que el prospecto se encuentra en la pantalla de integración de expediente digital dentro de la apliicación en versión mobile Cuando la pantalla carga correctamente Entonces se muestra el link informativo de activación

**TC-ORG-086 — Visualización del link**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; contenido informativo aprobado y no aprobado
- **Dado** que el prospecto se encuentra en la pantalla de integración de expediente digital dentro de la apliicación en versión mobile
- **Cuando** la pantalla carga correctamente
- **Resultado esperado**: se muestra el link informativo de activación
- **Casuísticas**: Móvil; escritorio; contenido aprobado; contenido pendiente de aprobación

#### CA02

> Dado que el prospecto se encuentra en la pantalla de integración de expediente digital dentro de la apliicación en versión desktop Cuando la pantalla carga correctamente Entonces se muestra Información en lado derecho de la pantalla

**TC-ORG-087 — Mostrar informacion de activación de servicios degitales version Desktop**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; contenido informativo aprobado y no aprobado
- **Dado** que el prospecto se encuentra en la pantalla de integración de expediente digital dentro de la apliicación en versión desktop
- **Cuando** la pantalla carga correctamente
- **Resultado esperado**: se muestra Información en lado derecho de la pantalla
- **Casuísticas**: Móvil; escritorio; contenido aprobado; contenido pendiente de aprobación

#### CA03

> Dado que el prospecto hace clic en el link Cuando el sistema procesa la interacción Entonces se abre popup con el contenido aprobado

**TC-ORG-088 — Apertura de popup**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; contenido informativo aprobado y no aprobado
- **Dado** que el prospecto hace clic en el link
- **Cuando** el sistema procesa la interacción
- **Resultado esperado**: se abre popup con el contenido aprobado
- **Casuísticas**: Móvil; escritorio; contenido aprobado; contenido pendiente de aprobación

#### CA04

> Dado que el popup de activación está abierto Cuando el prospecto cierra la ventana Entonces el sistema vuelve a la pantalla previa sin pérdida de avance

**TC-ORG-089 — Cierre del popup**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; contenido informativo aprobado y no aprobado
- **Dado** que el popup de activación está abierto
- **Cuando** el prospecto cierra la ventana
- **Resultado esperado**: el sistema vuelve a la pantalla previa sin pérdida de avance
- **Casuísticas**: Móvil; escritorio; contenido aprobado; contenido pendiente de aprobación

#### CA05

> Dado que el contenido aprobado no está disponible Cuando se requiere validar el popup Entonces la información se marca como insuficiente hasta contar con aprobación

**TC-ORG-090 — Contenido pendiente**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Dispositivo móvil y escritorio; contenido informativo aprobado y no aprobado
- **Dado** que el contenido aprobado no está disponible
- **Cuando** se requiere validar el popup
- **Resultado esperado**: la información se marca como insuficiente hasta contar con aprobación
- **Casuísticas**: Móvil; escritorio; contenido aprobado; contenido pendiente de aprobación

---

### HDU-TDC-R4-20. Integrar firma, alta de crédito, expediente digital y marcaje de visualización

**Bloque funcional**: Integración Expediente Digital

**Marco regulatorio**: CNBV expediente y CONDUSEF. **Prioridad**: P1. **Casos**: 8.

**Precondiciones de la historia**: Firma electrónica completada; Integración con SmartVista y OnBase disponible; Documentos visualizados identificables

#### CA01

> Dado que prospecto firma exitosamente Cuando el sistema confirma la firma Entonces se activa automáticamente el alta del crédito y la asignación del producto en SmartVista

**TC-ORG-091 — Alta posterior a firma**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Firma concluida; número de crédito sintético de dieciocho dígitos
- **Dado** que prospecto firma exitosamente
- **Cuando** el sistema confirma la firma
- **Resultado esperado**: se activa automáticamente el alta del crédito y la asignación del producto en SmartVista
- **Casuísticas**: Firma exitosa; firma fallida; resguardo exitoso; resguardo fallido

**TC-ORG-092 — El alta no se dispara si la firma falla**

Partición de equivalencia, caso negativo, derivado.

- **Datos de entrada**: Firma rechazada por el prospecto
- **Dado** Una firma que no concluye correctamente
- **Cuando** el sistema evalúa el alta del crédito
- **Resultado esperado**: el alta no se ejecuta y no queda un crédito huérfano
- **Casuísticas**: Firma rechazada; sesión caída durante la firma; firma con tiempo agotado

#### CA02

> Dado que se realiza el alta de crédito en SMARTVISTA Cuando se realice la generación de la documentacion contractual Entonces el numero de crédito obtenido (18 digitos) debera aparecer en el documento portada

**TC-ORG-093 — Mapeo de número de crédito**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Firma concluida; número de crédito sintético de dieciocho dígitos
- **Dado** que se realiza el alta de crédito en SMARTVISTA
- **Cuando** se realice la generación de la documentacion contractual
- **Resultado esperado**: el numero de crédito obtenido (18 digitos) debera aparecer en el documento portada
- **Casuísticas**: Firma exitosa; firma fallida; resguardo exitoso; resguardo fallido

**TC-ORG-094 — El número de crédito tiene exactamente dieciocho dígitos**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: Número sintético de dieciocho dígitos
- **Dado** Un alta de crédito concluida
- **Cuando** se inspecciona el número obtenido
- **Resultado esperado**: tiene exactamente dieciocho dígitos y aparece en el documento de portada
- **Casuísticas**: Número con ceros iniciales; número máximo; número mínimo

**TC-ORG-095 — El número de crédito llega con longitud distinta de dieciocho**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Números sintéticos de diecisiete y diecinueve dígitos
- **Dado** Un número de crédito de diecisiete y, en otra ejecución, de diecinueve dígitos
- **Cuando** se genera la documentación contractual
- **Resultado esperado**: la inconsistencia se detecta antes de emitir el documento
- **Casuísticas**: Diecisiete dígitos; diecinueve dígitos; campo vacío

#### CA03

> Dado que el expediente digital se encuentra completo Cuando el sistema realiza almacenamiento definitivo Entonces los documentos, firma, numero de crédito (18 digitos) y datos quedan almacenados en OnBase

**TC-ORG-096 — Almacenamiento en OnBase**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Firma concluida; número de crédito sintético de dieciocho dígitos
- **Dado** que el expediente digital se encuentra completo
- **Cuando** el sistema realiza almacenamiento definitivo
- **Resultado esperado**: los documentos, firma, numero de crédito (18 digitos) y datos quedan almacenados en OnBase
- **Casuísticas**: Firma exitosa; firma fallida; resguardo exitoso; resguardo fallido

#### CA04

> Dado que el prospecto visualiza la documentación Cuando se muestren en la pantalla de integración de expediente digital Entonces se genera registra el time stamp en tabla autorizaciones dentro de Onbase

**TC-ORG-097 — Marcaje de visualización**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Firma concluida; número de crédito sintético de dieciocho dígitos
- **Dado** que el prospecto visualiza la documentación
- **Cuando** se muestren en la pantalla de integración de expediente digital
- **Resultado esperado**: se genera registra el time stamp en tabla autorizaciones dentro de Onbase
- **Casuísticas**: Firma exitosa; firma fallida; resguardo exitoso; resguardo fallido

**TC-ORG-098 — La marca de tiempo de visualización queda registrada**

Partición de equivalencia, caso positivo, derivado.

- **Datos de entrada**: Visualización de los seis documentos
- **Dado** Una documentación mostrada al prospecto
- **Cuando** se consulta la tabla de autorizaciones del repositorio
- **Resultado esperado**: existe la marca de tiempo de la visualización
- **Casuísticas**: Un documento; todos los documentos; segunda visualización del mismo documento

---

### HDU-TDC-R4-21. Aplicar KO automático cuando el prospecto usará dinero de otra persona

**Bloque funcional**: PLD

**Marco regulatorio**: PLD origen de recursos. **Prioridad**: P1. **Casos**: 4.

**Precondiciones de la historia**: BB PLD habilitado; Pregunta de origen de recursos disponible; Yugabyte disponible para almacenar KO; Mensaje TYP aprobado

#### CA01

> Dado que el prospecto responde Usaré mi dinero Cuando presiona Continuar Entonces el sistema continúa su flujo sin cambio funcional

**TC-ORG-099 — Continuidad con dinero propio**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Usaré mi dinero, Usaré el dinero de otra persona
- **Dado** que el prospecto responde Usaré mi dinero
- **Cuando** presiona Continuar
- **Resultado esperado**: el sistema continúa su flujo sin cambio funcional
- **Casuísticas**: Dinero propio; dinero de otra persona; sin responder

#### CA02

> Dado que el prospecto responde Usaré el dinero de otra persona Cuando presiona Continuar Entonces el sistema genera KO y almacena el resultado en Yugabyte

**TC-ORG-100 — KO por dinero de otra persona**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Usaré mi dinero, Usaré el dinero de otra persona
- **Dado** que el prospecto responde Usaré el dinero de otra persona
- **Cuando** presiona Continuar
- **Resultado esperado**: el sistema genera KO y almacena el resultado en Yugabyte
- **Casuísticas**: Dinero propio; dinero de otra persona; sin responder

**TC-ORG-101 — El rechazo por origen de recursos queda almacenado**

Partición de equivalencia, caso positivo, derivado.

- **Datos de entrada**: Respuesta: Usaré el dinero de otra persona
- **Dado** Un prospecto que declara que usará dinero de otra persona
- **Cuando** se consulta el almacén de resultados
- **Resultado esperado**: el rechazo queda registrado y es recuperable
- **Casuísticas**: Primer rechazo; reintento del mismo prospecto; consulta posterior del registro

#### CA03

> Dado que se genera el KO por proveedor de recursos Cuando el sistema muestra la TYP Entonces se presenta el mensaje Lo sentimos... y Te invitamos... con botón Conoce las sucursales

**TC-ORG-102 — TYP de rechazo**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Respuestas posibles: Usaré mi dinero, Usaré el dinero de otra persona
- **Dado** que se genera el KO por proveedor de recursos
- **Cuando** el sistema muestra la TYP
- **Resultado esperado**: se presenta el mensaje Lo sentimos... y Te invitamos... con botón Conoce las sucursales
- **Casuísticas**: Dinero propio; dinero de otra persona; sin responder

---

### HDU-TDC-R4-23. Validar formato del número celular en preparación y validación de Teléfono

**Bloque funcional**: Preparación / Validación de Teléfono

**Marco regulatorio**: No regulatorio. **Prioridad**: P2. **Casos**: 20.

**Precondiciones de la historia**: Campo de teléfono disponible en Preparación y Validación del teléfono; Reglas de formato definidas - Reglas de secuencia definida, longitud minima e caracteres que no deben permitirse; Figma mobile/desktop disponible

#### CA01

> Dado que el usuario visualiza el campo teléfono Cuando la pantalla carga el formulario Entonces se muestra bandera de México y lada +52 bloqueada

**TC-ORG-103 — Prefijo fijo México**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Números válidos 5533445566; inválidos 5655555555, 5512345678, 9876543210
- **Dado** que el usuario visualiza el campo teléfono
- **Cuando** la pantalla carga el formulario
- **Resultado esperado**: se muestra bandera de México y lada +52 bloqueada
- **Casuísticas**: Longitud válida e inválida; formato inválido; repeticiones; secuencias

**TC-ORG-104 — La lada no se puede modificar**

Partición de equivalencia, caso negativo, derivado.

- **Datos de entrada**: Intento de cambiar +52 por otra lada
- **Dado** Un formulario con la lada de México bloqueada
- **Cuando** el prospecto intenta modificarla
- **Resultado esperado**: el campo no admite cambio
- **Casuísticas**: Edición directa; pegado de texto; teclado numérico

#### CA02

> Dado que el usuario captura número celular Cuando intenta continuar Entonces el sistema permite avanzar solo con exactamente 10 dígitos numéricos

**TC-ORG-105 — Longitud válida**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Números válidos 5533445566; inválidos 5655555555, 5512345678, 9876543210
- **Dado** que el usuario captura número celular
- **Cuando** intenta continuar
- **Resultado esperado**: el sistema permite avanzar solo con exactamente 10 dígitos numéricos
- **Casuísticas**: Longitud válida e inválida; formato inválido; repeticiones; secuencias

**TC-ORG-106 — Nueve dígitos no permiten avanzar**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: 553344556
- **Dado** Un número celular de nueve dígitos
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Nueve dígitos

**TC-ORG-107 — Diez dígitos permiten avanzar**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: 5533445566
- **Dado** Un número celular de diez dígitos válidos
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema permite el avance
- **Casuísticas**: Diez dígitos válidos

**TC-ORG-108 — Once dígitos no permiten avanzar**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: 55334455667
- **Dado** Un número celular de once dígitos
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Once dígitos

#### CA03

> Dado que el usuario ingresa número que inicia con 0, letras, espacios o caracteres especiales Cuando presiona Continuar Entonces el sistema impide el avance

**TC-ORG-109 — Restricciones de formato**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Números válidos 5533445566; inválidos 5655555555, 5512345678, 9876543210
- **Dado** que el usuario ingresa número que inicia con 0, letras, espacios o caracteres especiales
- **Cuando** presiona Continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Longitud válida e inválida; formato inválido; repeticiones; secuencias

**TC-ORG-110 — Número que inicia con cero**

Partición de equivalencia, caso negativo, derivado.

- **Datos de entrada**: 0533445566
- **Dado** Un número que comienza con cero
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Cero inicial

**TC-ORG-111 — Número con letras**

Partición de equivalencia, caso negativo, derivado.

- **Datos de entrada**: 55AB445566
- **Dado** Un número que contiene letras
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Letras intercaladas

**TC-ORG-112 — Número con espacios**

Partición de equivalencia, caso negativo, derivado.

- **Datos de entrada**: 55 3344 5566
- **Dado** Un número que contiene espacios
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Espacios internos

**TC-ORG-113 — Número con caracteres especiales**

Partición de equivalencia, caso negativo, derivado.

- **Datos de entrada**: 55-3344-5566
- **Dado** Un número con caracteres especiales
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Guiones; paréntesis; punto

#### CA04

> Dado que el prospecto captura un número celular, cuando el número ingresado contenga repetición consecutiva del mismo dígito en un rango mínimo de 8 dígitos y hasta un máximo de 10 posiciones, entonces el sistema deberá considerar el número como inválido, impedir el avance del flujo y mostrar el mensaje de validación correspondiente para solicitar la captura de un número celular válido. Ejemplos no permitidos: 5655555555 5555555555 5511111111 9999999999

**TC-ORG-114 — Validación de números repetidos consecutivos**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Números válidos 5533445566; inválidos 5655555555, 5512345678, 9876543210
- **Dado** que el prospecto captura un número celular,
- **Cuando** el número ingresado contenga repetición consecutiva del mismo dígito en un rango mínimo de 8 dígitos y hasta un máximo de 10 posiciones,
- **Resultado esperado**: el sistema deberá considerar el número como inválido, impedir el avance del flujo y mostrar el mensaje de validación correspondiente para solicitar la captura de un número celular válido.
- **Casuísticas**: Longitud válida e inválida; formato inválido; repeticiones; secuencias

**TC-ORG-115 — Siete repeticiones consecutivas todavía se aceptan**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: 5535555555 con siete repeticiones
- **Dado** Un número con siete repeticiones consecutivas del mismo dígito
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema permite el avance, porque el mínimo de rechazo son ocho
- **Casuísticas**: Repetición al inicio; al centro; al final

**TC-ORG-116 — Ocho repeticiones consecutivas se rechazan**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: 5655555555
- **Dado** Un número con ocho repeticiones consecutivas
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance y muestra el mensaje de validación
- **Casuísticas**: Ocho repeticiones

**TC-ORG-117 — Diez posiciones del mismo dígito se rechazan**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: 5555555555 y 9999999999
- **Dado** Un número con las diez posiciones iguales
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance y muestra el mensaje de validación
- **Casuísticas**: Diez repeticiones

#### CA05

> Dado que el prospecto captura un número celular, Cuando el número ingresado contenga una secuencia numérica consecutiva en orden ascendente o descendente en un rango mínimo de 8 dígitos y hasta un máximo de 10 posiciones, Entonces el sistema deberá considerar el número como inválido, impedir el avance del flujo y mostrar el mensaje de validación correspondiente para solicitar la captura de un número celular válido. Ejemplos no permitidos: 5512345678 1234567890 5598765432 9876543210

**TC-ORG-118 — Validación de secuencias consecutivas ascendentes o descendentes**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Números válidos 5533445566; inválidos 5655555555, 5512345678, 9876543210
- **Dado** que el prospecto captura un número celular,
- **Cuando** el número ingresado contenga una secuencia numérica consecutiva en orden ascendente o descendente en un rango mínimo de 8 dígitos y hasta un máximo de 10 posiciones,
- **Resultado esperado**: el sistema deberá considerar el número como inválido, impedir el avance del flujo y mostrar el mensaje de validación correspondiente para solicitar la captura de un número celular válido.
- **Casuísticas**: Longitud válida e inválida; formato inválido; repeticiones; secuencias

**TC-ORG-119 — Siete dígitos en secuencia todavía se aceptan**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: 5531234567 con siete en secuencia
- **Dado** Un número con una secuencia consecutiva de siete dígitos
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema permite el avance, porque el mínimo de rechazo son ocho
- **Casuísticas**: Secuencia ascendente; descendente

**TC-ORG-120 — Ocho dígitos en secuencia ascendente se rechazan**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: 5512345678
- **Dado** Un número con una secuencia ascendente de ocho dígitos
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Ocho ascendentes

**TC-ORG-121 — Ocho dígitos en secuencia descendente se rechazan**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: 5598765432
- **Dado** Un número con una secuencia descendente de ocho dígitos
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Ocho descendentes

**TC-ORG-122 — Diez dígitos en secuencia se rechazan**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: 1234567890 y 9876543210
- **Dado** Un número con las diez posiciones en secuencia
- **Cuando** el prospecto presiona continuar
- **Resultado esperado**: el sistema impide el avance
- **Casuísticas**: Diez ascendentes; diez descendentes

---

### HDU-TDC-R4-24. Validar titularidad del celular y disponibilidad por regla de 30 días

**Bloque funcional**: Validación del teléfono

**Marco regulatorio**: CNBV banca electrónica. **Prioridad**: P1. **Casos**: 7.

**Precondiciones de la historia**: Número celular cumple formato; Regla de verificación de 30 días disponible; Mensaje de error aprobado

#### CA01

> Dado que el celular cumple las reglas de captura Cuando el usuario da clic en Continuar Entonces el sistema ejecuta validación de titularidad

**TC-ORG-123 — Ejecución posterior a formato**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Número con verificación previa de otro cliente a 29, 30 y 31 días
- **Dado** que el celular cumple las reglas de captura
- **Cuando** el usuario da clic en Continuar
- **Resultado esperado**: el sistema ejecuta validación de titularidad
- **Casuísticas**: Número libre; número tomado; corrección del número; servicio sin respuesta

#### CA02

> Dado que el número no ha sido verificado por otro cliente en los últimos 30 días Cuando el sistema obtiene la respuesta de verificación Entonces el flujo continúa al envío de OTP

**TC-ORG-124 — Número disponible**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Número con verificación previa de otro cliente a 29, 30 y 31 días
- **Dado** que el número no ha sido verificado por otro cliente en los últimos 30 días
- **Cuando** el sistema obtiene la respuesta de verificación
- **Resultado esperado**: el flujo continúa al envío de OTP
- **Casuísticas**: Número libre; número tomado; corrección del número; servicio sin respuesta

**TC-ORG-125 — Número verificado hace treinta y un días queda disponible**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: Verificación previa con fecha de hace 31 días
- **Dado** Un número verificado por otro cliente hace treinta y un días
- **Cuando** el sistema evalúa la titularidad
- **Resultado esperado**: el número se considera disponible y el flujo continúa
- **Casuísticas**: Treinta y un días; sesenta días; sin verificación previa

#### CA03

> Dado que el número está activo y verificado por otro cliente en menos de 30 días Cuando el sistema valida la regla Entonces se muestra error en texto rojo bajo el campo

**TC-ORG-126 — Número no disponible**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Número con verificación previa de otro cliente a 29, 30 y 31 días
- **Dado** que el número está activo y verificado por otro cliente en menos de 30 días
- **Cuando** el sistema valida la regla
- **Resultado esperado**: se muestra error en texto rojo bajo el campo
- **Casuísticas**: Número libre; número tomado; corrección del número; servicio sin respuesta

**TC-ORG-127 — Número verificado hace veintinueve días no está disponible**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Verificación previa con fecha de hace 29 días
- **Dado** Un número verificado por otro cliente hace veintinueve días
- **Cuando** el sistema evalúa la titularidad
- **Resultado esperado**: se muestra el error bajo el campo y el flujo no avanza
- **Casuísticas**: Veintinueve días; un día; quince días

**TC-ORG-128 — Número verificado hace exactamente treinta días**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Verificación previa con fecha de hace exactamente 30 días
- **Dado** Un número verificado por otro cliente hace exactamente treinta días
- **Cuando** el sistema evalúa la titularidad
- **Resultado esperado**: el comportamiento en el límite queda determinado y documentado, porque los dos criterios se contradicen en ese punto
- **Casuísticas**: Treinta días exactos al segundo; al corte del día

#### CA04

> Dado que el mensaje de error está visible Cuando el usuario captura un número distinto válido Entonces el sistema permite reevaluar titularidad

**TC-ORG-129 — Corrección de número**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Número con verificación previa de otro cliente a 29, 30 y 31 días
- **Dado** que el mensaje de error está visible
- **Cuando** el usuario captura un número distinto válido
- **Resultado esperado**: el sistema permite reevaluar titularidad
- **Casuísticas**: Número libre; número tomado; corrección del número; servicio sin respuesta

---

### HDU-TDC-R4-25. Cancelar vínculo previo del número cuando la originación concluye exitosamente

**Bloque funcional**: Integracion de Expediente digital

**Marco regulatorio**: No regulatorio. **Prioridad**: P2. **Casos**: 5.

**Precondiciones de la historia**: Proceso de originación exitoso; Número validado; Regla de vinculación previa disponible

#### CA01

> Dado que el prospecto concluye exitosamente el proceso Cuando el sistema valida vinculación del número Entonces se identifica si existía vínculo previo con otro cliente origen

**TC-ORG-130 — Originación exitosa**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Número con vínculo previo a otro cliente; originación exitosa y fallida
- **Dado** que el prospecto concluye exitosamente el proceso
- **Cuando** el sistema valida vinculación del número
- **Resultado esperado**: se identifica si existía vínculo previo con otro cliente origen
- **Casuísticas**: Con vínculo previo; sin vínculo previo; originación exitosa; originación fallida

#### CA02

> Dado que existe vinculación previa del número Cuando la originación finaliza correctamente Entonces el sistema cancela el vínculo anterior

**TC-ORG-131 — Cancelación de vínculo previo**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Número con vínculo previo a otro cliente; originación exitosa y fallida
- **Dado** que existe vinculación previa del número
- **Cuando** la originación finaliza correctamente
- **Resultado esperado**: el sistema cancela el vínculo anterior
- **Casuísticas**: Con vínculo previo; sin vínculo previo; originación exitosa; originación fallida

#### CA03

> Dado que el vínculo previo fue cancelado Cuando el sistema actualiza la asociación Entonces el número queda disponible/asociado al cliente final de la originación

**TC-ORG-132 — Nuevo vínculo vigente**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Número con vínculo previo a otro cliente; originación exitosa y fallida
- **Dado** que el vínculo previo fue cancelado
- **Cuando** el sistema actualiza la asociación
- **Resultado esperado**: el número queda disponible/asociado al cliente final de la originación
- **Casuísticas**: Con vínculo previo; sin vínculo previo; originación exitosa; originación fallida

#### CA04

> Dado que la originación no concluye exitosamente Cuando el sistema evalúa vínculo telefónico Entonces no se cancela el vínculo previo por este flujo

**TC-ORG-133 — No cancelación sin éxito**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Número con vínculo previo a otro cliente; originación exitosa y fallida
- **Dado** que la originación no concluye exitosamente
- **Cuando** el sistema evalúa vínculo telefónico
- **Resultado esperado**: no se cancela el vínculo previo por este flujo
- **Casuísticas**: Con vínculo previo; sin vínculo previo; originación exitosa; originación fallida

**TC-ORG-134 — El vínculo previo sobrevive a una originación fallida**

Transición de estado, caso positivo, derivado.

- **Datos de entrada**: Número con vínculo previo y originación abandonada
- **Dado** Una originación que no concluye y un número con vínculo previo
- **Cuando** el sistema evalúa el vínculo telefónico
- **Resultado esperado**: el vínculo anterior permanece intacto
- **Casuísticas**: Abandono; rechazo por listas; rechazo por origen de recursos

---

### HDU-TDC-R4-26. Gestionar reglas del OTP para validación telefónica

**Bloque funcional**: Validación de telefono/ Validación SIC/Retomar solicitud

**Marco regulatorio**: CNBV banca electrónica. **Prioridad**: P1. **Casos**: 14.

**Precondiciones de la historia**: Flujo de OTP habilitado; Parámetros de vigencia y reenvíos configurados; Mensaje TYP aprobado

#### CA01

> Dado que se genera un OTP Cuando el usuario recibe el código Entonces el código tiene vigencia de 10 minutos conforme al parámetro

**TC-ORG-135 — Vigencia parametrizable**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Código de seis dígitos; reloj controlado para vigencia, reenvíos e intentos
- **Dado** que se genera un OTP
- **Cuando** el usuario recibe el código
- **Resultado esperado**: el código tiene vigencia de 10 minutos conforme al parámetro
- **Casuísticas**: Código vigente; vencido; reenviado; intentos fallidos; bloqueo y liberación

**TC-ORG-136 — Código usado al minuto nueve con cincuenta y nueve**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: Reloj controlado a 9 minutos 59 segundos
- **Dado** Un código generado hace nueve minutos y cincuenta y nueve segundos
- **Cuando** el prospecto lo captura
- **Resultado esperado**: el código se acepta
- **Casuísticas**: Inmediato; a la mitad; en el límite

**TC-ORG-137 — Código usado al minuto diez con un segundo**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Reloj controlado a 10 minutos 1 segundo
- **Dado** Un código generado hace diez minutos y un segundo
- **Cuando** el prospecto lo captura
- **Resultado esperado**: el código se rechaza por vigencia
- **Casuísticas**: Un segundo después; una hora después

#### CA02

> Dado que el usuario solicita reenvío de OTP Cuando no ha excedido el límite Entonces el sistema permite hasta 3 reenvíos y 4 mensajes totales

**TC-ORG-138 — Reenvíos controlados**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Código de seis dígitos; reloj controlado para vigencia, reenvíos e intentos
- **Dado** que el usuario solicita reenvío de OTP
- **Cuando** no ha excedido el límite
- **Resultado esperado**: el sistema permite hasta 3 reenvíos y 4 mensajes totales
- **Casuísticas**: Código vigente; vencido; reenviado; intentos fallidos; bloqueo y liberación

**TC-ORG-139 — Tercer reenvío permitido**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: Dos reenvíos previos registrados
- **Dado** Un prospecto que ya solicitó dos reenvíos
- **Cuando** solicita el tercero
- **Resultado esperado**: el sistema lo permite y suman cuatro mensajes en total
- **Casuísticas**: Tercer reenvío; conteo total de mensajes

**TC-ORG-140 — Cuarto reenvío rechazado**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Tres reenvíos previos registrados
- **Dado** Un prospecto que ya agotó los tres reenvíos
- **Cuando** solicita un cuarto
- **Resultado esperado**: el sistema lo rechaza
- **Casuísticas**: Cuarto reenvío; quinto intento

#### CA03

> Dado que el usuario solicita reenvío Cuando se genera un nuevo OTP Entonces el código anterior queda invalidado y reinicia espera de 1 minuto

**TC-ORG-141 — Invalidación de código anterior**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Código de seis dígitos; reloj controlado para vigencia, reenvíos e intentos
- **Dado** que el usuario solicita reenvío
- **Cuando** se genera un nuevo OTP
- **Resultado esperado**: el código anterior queda invalidado y reinicia espera de 1 minuto
- **Casuísticas**: Código vigente; vencido; reenviado; intentos fallidos; bloqueo y liberación

**TC-ORG-142 — El código anterior deja de servir tras un reenvío**

Transición de estado, caso negativo, derivado.

- **Datos de entrada**: Código previo y código nuevo generados
- **Dado** Un código vigente y un reenvío solicitado después
- **Cuando** el prospecto captura el código anterior
- **Resultado esperado**: el código anterior se rechaza
- **Casuísticas**: Código inmediatamente anterior; dos códigos atrás

**TC-ORG-143 — Reenvío antes de cumplir el minuto de espera**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Reloj controlado a 59 segundos
- **Dado** Un reenvío solicitado a los cincuenta y nueve segundos del anterior
- **Cuando** el prospecto presiona reenviar
- **Resultado esperado**: el sistema no lo permite todavía
- **Casuísticas**: Cincuenta y nueve segundos; sesenta segundos

#### CA04

> Dado que el usuario captura OTP incorrecto Cuando acumula intentos Entonces al 4to intento fallido se redirige a TYP con mensaje de seguridad

**TC-ORG-144 — Intentos fallidos**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Código de seis dígitos; reloj controlado para vigencia, reenvíos e intentos
- **Dado** que el usuario captura OTP incorrecto
- **Cuando** acumula intentos
- **Resultado esperado**: al 4to intento fallido se redirige a TYP con mensaje de seguridad
- **Casuísticas**: Código vigente; vencido; reenviado; intentos fallidos; bloqueo y liberación

**TC-ORG-145 — Tercer intento fallido todavía permite reintentar**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: Dos intentos fallidos previos
- **Dado** Un prospecto con dos intentos fallidos
- **Cuando** captura un tercer código incorrecto
- **Resultado esperado**: el sistema permite un intento más
- **Casuísticas**: Tercer intento; conteo visible al usuario

**TC-ORG-146 — Cuarto intento fallido redirige y bloquea**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Tres intentos fallidos previos
- **Dado** Un prospecto con tres intentos fallidos
- **Cuando** captura un cuarto código incorrecto
- **Resultado esperado**: el sistema redirige con el mensaje de seguridad y bloquea
- **Casuísticas**: Cuarto intento; intento tras el bloqueo

#### CA05

> Dado que el usuario fue bloqueado por intentos fallidos Cuando llega la hora 00:00 del día siguiente Entonces el sistema libera automáticamente el bloqueo

**TC-ORG-147 — Liberación de bloqueo**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Código de seis dígitos; reloj controlado para vigencia, reenvíos e intentos
- **Dado** que el usuario fue bloqueado por intentos fallidos
- **Cuando** llega la hora 00:00 del día siguiente
- **Resultado esperado**: el sistema libera automáticamente el bloqueo
- **Casuísticas**: Código vigente; vencido; reenviado; intentos fallidos; bloqueo y liberación

**TC-ORG-148 — El bloqueo persiste hasta el cierre del día**

Valores límite, caso negativo, derivado.

- **Datos de entrada**: Reloj controlado a las 23:59
- **Dado** Un prospecto bloqueado y la hora veintitrés con cincuenta y nueve
- **Cuando** intenta de nuevo
- **Resultado esperado**: el bloqueo sigue vigente
- **Casuísticas**: Un minuto antes; en el cambio de día; al día siguiente

---

### HDU-TDC-R4-27. Asegurar máscara de SMS BanCoppel en mensajes OTP

**Bloque funcional**: Validación de telefono/ Validación SIC/Retomar solicitud

**Marco regulatorio**: CNBV banca electrónica. **Prioridad**: P1. **Casos**: 5.

**Precondiciones de la historia**: Servicio SMS disponible ( depende de proveedor de servio) (formato del mensaje bien definido); Plantilla de mensaje validada; Máscara BanCoppel configurada

#### CA01

> Dado que el sistema envía SMS de OTP Cuando el prospecto recibe el mensaje Entonces la máscara/remitente corresponde a BanCoppel

**TC-ORG-149 — Máscara correcta**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Configuración de remitente válida e inválida; idioma del mensaje
- **Dado** que el sistema envía SMS de OTP
- **Cuando** el prospecto recibe el mensaje
- **Resultado esperado**: la máscara/remitente corresponde a BanCoppel
- **Casuísticas**: Remitente correcto; remitente incorrecto; primer envío; reenvío

#### CA02

> Dado que el SMS de OTP es generado Cuando se construye el contenido del mensaje Entonces el texto se envie en Español

**TC-ORG-150 — Idioma español**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Configuración de remitente válida e inválida; idioma del mensaje
- **Dado** que el SMS de OTP es generado
- **Cuando** se construye el contenido del mensaje
- **Resultado esperado**: el texto se envie en Español
- **Casuísticas**: Remitente correcto; remitente incorrecto; primer envío; reenvío

#### CA03

> Dado que el usuario solicita reenvío de OTP Cuando el sistema genera nuevo SMS Entonces la máscara y el idioma se mantienen correctos

**TC-ORG-151 — Consistencia con reenvío**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Configuración de remitente válida e inválida; idioma del mensaje
- **Dado** que el usuario solicita reenvío de OTP
- **Cuando** el sistema genera nuevo SMS
- **Resultado esperado**: la máscara y el idioma se mantienen correctos
- **Casuísticas**: Remitente correcto; remitente incorrecto; primer envío; reenvío

#### CA04

> Dado que la configuración de máscara no corresponde a BanCoppel Cuando se intenta enviar OTP Entonces la condición debe ser corregida antes de considerarse lista funcionalmente

**TC-ORG-152 — No envío con máscara inválida**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Configuración de remitente válida e inválida; idioma del mensaje
- **Dado** que la configuración de máscara no corresponde a BanCoppel
- **Cuando** se intenta enviar OTP
- **Resultado esperado**: la condición debe ser corregida antes de considerarse lista funcionalmente
- **Casuísticas**: Remitente correcto; remitente incorrecto; primer envío; reenvío

**TC-ORG-153 — Configuración de remitente incorrecta**

Prueba negativa, caso negativo, derivado.

- **Datos de entrada**: Remitente configurado distinto del institucional
- **Dado** Una configuración de remitente que no corresponde a la institución
- **Cuando** se intenta enviar el código
- **Resultado esperado**: la condición se detecta y se corrige antes de considerar la función lista
- **Casuísticas**: Remitente vacío; remitente de otra marca; remitente numérico

---

### HDU-TDC-R4-34. Asignar sucursal corporativa parametrizable a la TDC BanCoppel

**Bloque funcional**: Validación de domicilio / Intengración de expediente digital

**Marco regulatorio**: No regulatorio. **Prioridad**: P2. **Casos**: 3.

**Precondiciones de la historia**: Producto TDC BanCoppel identificado; Parámetro de sucursal disponible; Regla de asignación confirmada

#### CA01

> Dado que se genera la tarjeta de crédito BanCoppel Cuando el sistema asigna sucursal Entonces se obtiene de forma dinamica la sucursal que se encuentra establecida Nota: al momento de la definición del requerimiento la sucursal corporativa establecida es la 6700

**TC-ORG-154 — Asignación dinamica**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Sucursal corporativa configurada 6700; sucursal alterna 6800
- **Dado** que se genera la tarjeta de crédito BanCoppel
- **Cuando** el sistema asigna sucursal
- **Resultado esperado**: se obtiene de forma dinamica la sucursal que se encuentra establecida Nota: al momento de la definición del requerimiento la sucursal corporativa establecida es la 6700
- **Casuísticas**: Sucursal configurada; sucursal cambiada; transacción posterior

**TC-ORG-155 — Cambio de sucursal corporativa sin desarrollo**

Valores límite, caso positivo, derivado.

- **Datos de entrada**: Sucursal 6700 y sucursal 6800
- **Dado** Una sucursal corporativa distinta configurada
- **Cuando** se genera una tarjeta posterior al cambio
- **Resultado esperado**: la tarjeta toma la sucursal nueva sin requerir despliegue
- **Casuísticas**: Cambio de sucursal; tarjeta en curso al momento del cambio

#### CA02

> Dado que la TDC queda asignada a una sucursal Cuando se registran transacciones del producto Entonces la sucursal asignada permite trazabilidad operativa

**TC-ORG-156 — Trazabilidad de producto**

Partición de equivalencia, caso positivo, literal.

- **Datos de entrada**: Sucursal corporativa configurada 6700; sucursal alterna 6800
- **Dado** que la TDC queda asignada a una sucursal
- **Cuando** se registran transacciones del producto
- **Resultado esperado**: la sucursal asignada permite trazabilidad operativa
- **Casuísticas**: Sucursal configurada; sucursal cambiada; transacción posterior

---

## Parte 2. Casos no funcionales

Ninguno de estos casos deriva de un criterio de aceptación. Derivan del flujo completo y de sus dependencias externas, que es donde viven el tiempo, la carga, la caída y la exposición de información.

### Desempeño

**TC-ORG-157 — El flujo completo responde en menos de cinco minutos**

Valores límite, prioridad P2, No regulatorio.

- **Datos de entrada**: Carga nominal y carga de hora pico
- **Dado** Un prospecto que recorre el flujo sin reintentos
- **Cuando** se mide el tiempo desde el primer dato capturado hasta la resolución
- **Resultado esperado**: el percentil noventa y cinco se mantiene por debajo de cinco minutos
- **Casuísticas**: Baja demanda; hora pico; campaña; con un servicio externo lento

**TC-ORG-158 — El código de un solo uso llega en segundos**

Valores límite, prioridad P1, CNBV banca electrónica.

- **Datos de entrada**: Envíos a las principales compañías telefónicas
- **Dado** Un prospecto que solicita el código
- **Cuando** se mide el tiempo hasta la recepción del mensaje
- **Resultado esperado**: el mensaje llega dentro del tiempo acordado con el proveedor
- **Casuísticas**: Primer envío; reenvío; hora pico; compañía distinta

**TC-ORG-159 — La consulta a listas responde sin frenar el flujo**

Valores límite, prioridad P2, No regulatorio.

- **Datos de entrada**: Nombres con y sin coincidencia
- **Dado** Una validación de coincidencia de nombre en curso
- **Cuando** se mide el tiempo de respuesta
- **Resultado esperado**: la consulta se resuelve dentro del presupuesto asignado al paso
- **Casuísticas**: Respuesta inmediata; respuesta lenta; uso del respaldo

**TC-ORG-160 — El visor de contrato abre sin espera perceptible**

Valores límite, prioridad P2, No regulatorio.

- **Datos de entrada**: Documentos del paquete contractual
- **Dado** Un prospecto en la pantalla de términos
- **Cuando** abre el documento
- **Resultado esperado**: el documento se muestra dentro del tiempo aceptable
- **Casuísticas**: Documento ligero; documento pesado; conexión lenta

**TC-ORG-161 — El correo contractual sale dentro de la ventana comprometida**

Valores límite, prioridad P1, CONDUSEF y RECA.

- **Datos de entrada**: Paquete de seis documentos
- **Dado** Una firma concluida
- **Cuando** se mide el tiempo hasta el envío del correo
- **Resultado esperado**: el correo sale dentro de la ventana acordada con negocio
- **Casuísticas**: Envío inmediato; cola saturada; reintento tras fallo

**TC-ORG-162 — El alta del crédito ocurre inmediatamente tras la firma**

Valores límite, prioridad P2, No regulatorio.

- **Datos de entrada**: Firma de un prospecto aprobado
- **Dado** Una firma confirmada
- **Cuando** se mide el tiempo hasta el alta del crédito
- **Resultado esperado**: el alta se completa sin que el prospecto espere en pantalla
- **Casuísticas**: Carga nominal; hora pico; sistema de alta degradado


### Carga

**TC-ORG-163 — El flujo sostiene el volumen de una campaña comercial**

Valores límite, prioridad P2, No regulatorio.

- **Datos de entrada**: Volumen nominal y volumen de campaña
- **Dado** El volumen proyectado de campaña
- **Cuando** se ejecuta carga sostenida durante la ventana de campaña
- **Resultado esperado**: no aparecen errores ni esperas fuera del objetivo
- **Casuísticas**: Volumen nominal; volumen de campaña; volumen sobre el pico

**TC-ORG-164 — Se identifica el punto de quiebre del flujo**

Valores límite, prioridad P2, No regulatorio.

- **Datos de entrada**: Carga incremental
- **Dado** Una carga creciente por encima del pico proyectado
- **Cuando** se incrementa hasta la degradación
- **Resultado esperado**: el punto de quiebre queda medido y documentado
- **Casuísticas**: Degradación progresiva; error en cascada; recuperación

**TC-ORG-165 — El flujo se recupera una vez que el pico pasa**

Valores límite, prioridad P2, No regulatorio.

- **Datos de entrada**: Pico seguido de carga nominal
- **Dado** Un pico de carga que termina
- **Cuando** se observa el comportamiento posterior
- **Resultado esperado**: el servicio vuelve a su desempeño nominal sin intervención
- **Casuísticas**: Recuperación inmediata; recuperación lenta; necesidad de reinicio

**TC-ORG-166 — El envío masivo de códigos no se encola ni se pierde**

Valores límite, prioridad P1, CNBV banca electrónica.

- **Datos de entrada**: Solicitudes concurrentes del código
- **Dado** Muchos prospectos solicitando el código al mismo tiempo
- **Cuando** se ejecuta el pico de solicitudes
- **Resultado esperado**: todos los mensajes salen y ninguno se duplica
- **Casuísticas**: Pico de solicitudes; reenvíos simultáneos; proveedor degradado


### Disponibilidad

**TC-ORG-167 — La caída del servicio de listas no deja aprobar sin validar**

Prueba negativa, prioridad P1, PLD listas de personas bloqueadas.

- **Datos de entrada**: Servicio de listas no disponible
- **Dado** Un servicio de listas fuera de servicio
- **Cuando** un prospecto llega al bloque de validación
- **Resultado esperado**: la solicitud no avanza como aprobada y el estado queda explícito
- **Casuísticas**: Caída total; respuesta lenta; respuesta con error

**TC-ORG-168 — La caída del respaldo de listas se maneja de forma segura**

Prueba negativa, prioridad P1, PLD listas de personas bloqueadas.

- **Datos de entrada**: Ambos servicios no disponibles
- **Dado** El servicio primario y su respaldo fuera de servicio
- **Cuando** un prospecto llega al bloque de validación
- **Resultado esperado**: la solicitud se detiene y queda en un estado recuperable
- **Casuísticas**: Ambos caídos; primario caído y respaldo lento; recuperación posterior

**TC-ORG-169 — La caída del repositorio documental no cierra el expediente**

Prueba negativa, prioridad P1, CNBV expediente y CONDUSEF.

- **Datos de entrada**: Repositorio no disponible
- **Dado** Un repositorio documental fuera de servicio
- **Cuando** una firma se concluye
- **Resultado esperado**: el expediente no se da por cerrado y el caso queda recuperable
- **Casuísticas**: Caída antes de la firma; durante el resguardo; después del resguardo

**TC-ORG-170 — La caída del alta tras una firma exitosa no deja al cliente sin crédito**

Prueba negativa, prioridad P1, CNBV expediente y CONDUSEF.

- **Datos de entrada**: Sistema de alta no disponible
- **Dado** Una firma exitosa y el sistema de alta fuera de servicio
- **Cuando** el sistema intenta el alta
- **Resultado esperado**: el caso queda en un estado recuperable y el cliente recibe una respuesta clara
- **Casuísticas**: Caída durante el alta; tras el alta; reintento exitoso

**TC-ORG-171 — La caída del proveedor de mensajes detiene el paso sin perder la solicitud**

Prueba negativa, prioridad P1, CNBV banca electrónica.

- **Datos de entrada**: Proveedor de mensajes no disponible
- **Dado** Un proveedor de mensajes fuera de servicio
- **Cuando** el prospecto solicita el código
- **Resultado esperado**: el sistema informa y conserva el avance de la solicitud
- **Casuísticas**: Caída total; entrega parcial; recuperación durante la espera

**TC-ORG-172 — El flujo de originación está disponible durante el mes**

Prueba negativa, prioridad P2, No regulatorio.

- **Datos de entrada**: Medición mensual
- **Dado** Una ventana de medición de un mes
- **Cuando** se mide la disponibilidad del flujo completo
- **Resultado esperado**: la disponibilidad cumple el objetivo acordado
- **Casuísticas**: Mes sin incidentes; con mantenimiento programado; con interrupción no programada


### Seguridad

**TC-ORG-173 — La información del historial crediticio no se persiste ni viaja en claro**

Prueba negativa, prioridad P1, PLD listas de personas bloqueadas.

- **Datos de entrada**: Consulta de historial de un prospecto sintético
- **Dado** Una consulta de historial resuelta
- **Cuando** se inspeccionan registros, almacenamiento y tránsito
- **Resultado esperado**: no hay detalle del historial almacenado ni transmitido sin protección
- **Casuísticas**: Consulta aprobatoria; consulta con rechazo; reintento

**TC-ORG-174 — El resultado de listas solo es visible para perfiles autorizados**

Prueba negativa, prioridad P1, PLD listas de personas bloqueadas.

- **Datos de entrada**: Perfiles autorizado y no autorizado
- **Dado** Un resultado de validación de listas registrado
- **Cuando** un perfil sin autorización intenta consultarlo
- **Resultado esperado**: el acceso se niega y el intento queda registrado
- **Casuísticas**: Perfil operativo; perfil de soporte; perfil externo

**TC-ORG-175 — Los documentos en lectura previa no exponen datos personales**

Prueba negativa, prioridad P1, CONDUSEF.

- **Datos de entrada**: Documentos del paquete contractual
- **Dado** Documentos en modo de lectura previa
- **Cuando** se inspecciona su contenido y sus metadatos
- **Resultado esperado**: no aparece ningún dato del prospecto, del crédito ni del producto
- **Casuísticas**: Contrato de crédito; contrato de servicios digitales; carátulas

**TC-ORG-176 — El código de un solo uso no se almacena ni se registra en claro**

Prueba negativa, prioridad P1, CNBV banca electrónica.

- **Datos de entrada**: Código de seis dígitos
- **Dado** Un código generado y usado
- **Cuando** se inspeccionan registros y almacenamiento
- **Resultado esperado**: el código no aparece en claro en ningún punto
- **Casuísticas**: Código vigente; código vencido; código reenviado

**TC-ORG-177 — El número celular aparece enmascarado en los registros**

Prueba negativa, prioridad P1, CNBV banca electrónica.

- **Datos de entrada**: Número sintético 5533445566
- **Dado** Una solicitud con número celular capturado
- **Cuando** se inspeccionan los registros de operación
- **Resultado esperado**: el número aparece enmascarado salvo los últimos dígitos
- **Casuísticas**: Registro de captura; de validación; de envío de código

**TC-ORG-178 — La bitácora de rechazos está protegida contra alteración**

Prueba negativa, prioridad P1, PLD listas de personas bloqueadas.

- **Datos de entrada**: Registros de rechazo existentes
- **Dado** Una bitácora con rechazos registrados
- **Cuando** se intenta modificar o borrar un registro
- **Resultado esperado**: la operación se impide y queda constancia del intento
- **Casuísticas**: Intento de modificación; de borrado; de inserción retroactiva


### Continuidad

**TC-ORG-179 — El prospecto retoma su solicitud sin repetir lo superado**

Prueba negativa, prioridad P2, No regulatorio.

- **Datos de entrada**: Solicitud abandonada en distintos bloques
- **Dado** Una solicitud abandonada después de validar el teléfono
- **Cuando** el prospecto la retoma más tarde
- **Resultado esperado**: el avance se conserva y no se le exigen los pasos ya superados
- **Casuísticas**: Abandono temprano; a mitad del flujo; antes de firmar

**TC-ORG-180 — La sesión de originación expira de forma controlada**

Prueba negativa, prioridad P2, No regulatorio.

- **Datos de entrada**: Inactividad por encima del tiempo permitido
- **Dado** Una solicitud inactiva más allá del tiempo permitido
- **Cuando** el prospecto intenta continuar
- **Resultado esperado**: la sesión expira con un mensaje claro y sin dejar datos a medias
- **Casuísticas**: Expiración por inactividad; por tiempo total; durante la firma


---

## Parte 3. Recorridos completos

**TC-ORG-181 — Originación aprobada de extremo a extremo**

Prioridad P1, Banxico CAT y CONDUSEF.

- **Datos de entrada**: Prospecto sintético aprobado; teléfono 5533445566
- **Dado** Un prospecto precalificado, sin coincidencias, con teléfono válido y dinero propio
- **Cuando** recorre el flujo completo hasta la firma
- **Resultado esperado**: el crédito queda dado de alta, el expediente resguardado y el correo contractual enviado
- **Casuísticas**: Primera solicitud; prospecto que ya es cliente; monto menor al solicitado

**TC-ORG-182 — Rechazo por coincidencia en listas del solicitante**

Prioridad P1, PLD listas de personas bloqueadas.

- **Datos de entrada**: Nombre sintético con coincidencia bloqueante
- **Dado** Un prospecto con coincidencia bloqueante
- **Cuando** el flujo llega al bloque de perfilamiento
- **Resultado esperado**: se genera el rechazo, se muestra el mensaje acordado y el evento queda en bitácora
- **Casuísticas**: Coincidencia total; parcial elevada a revisión; reintento posterior

**TC-ORG-183 — Rechazo por familiar con cargo público**

Prioridad P1, PLD persona políticamente expuesta.

- **Datos de entrada**: Declaración afirmativa y nombre con coincidencia
- **Dado** Un prospecto que declara familiar con cargo público con coincidencia bloqueante
- **Cuando** el flujo llega al bloque correspondiente
- **Resultado esperado**: se genera el rechazo con su estatus propio y queda la trazabilidad
- **Casuísticas**: Familiar directo; asociado cercano; homónimo

**TC-ORG-184 — Rechazo por origen de recursos de terceros**

Prioridad P1, PLD origen de recursos.

- **Datos de entrada**: Respuesta: Usaré el dinero de otra persona
- **Dado** Un prospecto que declara que usará dinero de otra persona
- **Cuando** presiona continuar
- **Resultado esperado**: se genera el rechazo y se presenta la pantalla con el mensaje y el botón acordados
- **Casuísticas**: Respuesta directa; cambio de respuesta; reintento

**TC-ORG-185 — Abandono y retoma de la solicitud**

Prioridad P2, No regulatorio.

- **Datos de entrada**: Solicitud abandonada tras validar teléfono
- **Dado** Un prospecto que abandona después de validar su teléfono
- **Cuando** retoma la solicitud más tarde
- **Resultado esperado**: el avance se conserva y no se le exige repetir los pasos superados
- **Casuísticas**: Retoma el mismo día; al día siguiente; tras expirar la sesión

**TC-ORG-186 — Declaración de grupo prioritario completa**

Prioridad P1, CONDUSEF grupos prioritarios.

- **Datos de entrada**: Respuesta afirmativa con dos opciones marcadas
- **Dado** Un prospecto que se declara en situación de vulnerabilidad
- **Cuando** selecciona sus opciones y continúa
- **Resultado esperado**: la información queda asociada al perfil y el flujo continúa sin penalizarlo
- **Casuísticas**: Una opción; varias opciones; respuesta reservada

---

## Parte 4. Trazabilidad de criterio a casos

| Historia | Criterio | Casos derivados | IDs |
|---|---|---|---|
| HDU-TDC-R4-01 | CA01 | 2 | TC-ORG-001, TC-ORG-002 |
| HDU-TDC-R4-01 | CA02 | 3 | TC-ORG-003, TC-ORG-004, TC-ORG-005 |
| HDU-TDC-R4-01 | CA03 | 3 | TC-ORG-006, TC-ORG-007, TC-ORG-008 |
| HDU-TDC-R4-03 | CA01 | 2 | TC-ORG-009, TC-ORG-010 |
| HDU-TDC-R4-03 | CA02 | 2 | TC-ORG-011, TC-ORG-012 |
| HDU-TDC-R4-03 | CA03 | 1 | TC-ORG-013 |
| HDU-TDC-R4-04 | CA01 | 1 | TC-ORG-014 |
| HDU-TDC-R4-04 | CA02 | 1 | TC-ORG-015 |
| HDU-TDC-R4-04 | CA03 | 1 | TC-ORG-016 |
| HDU-TDC-R4-04 | CA04 | 1 | TC-ORG-017 |
| HDU-TDC-R4-05 | CA01 | 1 | TC-ORG-018 |
| HDU-TDC-R4-05 | CA02 | 1 | TC-ORG-019 |
| HDU-TDC-R4-05 | CA03 | 1 | TC-ORG-020 |
| HDU-TDC-R4-05 | CA04 | 1 | TC-ORG-021 |
| HDU-TDC-R4-06 | CA01 | 1 | TC-ORG-022 |
| HDU-TDC-R4-06 | CA02 | 1 | TC-ORG-023 |
| HDU-TDC-R4-06 | CA03 | 1 | TC-ORG-024 |
| HDU-TDC-R4-06 | CA04 | 1 | TC-ORG-025 |
| HDU-TDC-R4-07 | CA01 | 1 | TC-ORG-026 |
| HDU-TDC-R4-07 | CA02 | 1 | TC-ORG-027 |
| HDU-TDC-R4-07 | CA03 | 2 | TC-ORG-028, TC-ORG-029 |
| HDU-TDC-R4-07 | CA04 | 1 | TC-ORG-030 |
| HDU-TDC-R4-07 | CA05 | 1 | TC-ORG-031 |
| HDU-TDC-R4-07 | CA06 | 3 | TC-ORG-032, TC-ORG-033, TC-ORG-034 |
| HDU-TDC-R4-07 | CA07 | 1 | TC-ORG-035 |
| HDU-TDC-R4-07 | CA08 | 2 | TC-ORG-036, TC-ORG-037 |
| HDU-TDC-R4-07 | CA09 | 1 | TC-ORG-038 |
| HDU-TDC-R4-08 | CA01 | 1 | TC-ORG-039 |
| HDU-TDC-R4-08 | CA02 | 2 | TC-ORG-040, TC-ORG-041 |
| HDU-TDC-R4-08 | CA03 | 1 | TC-ORG-042 |
| HDU-TDC-R4-08 | CA04 | 1 | TC-ORG-043 |
| HDU-TDC-R4-10 | CA01 | 1 | TC-ORG-044 |
| HDU-TDC-R4-10 | CA02 | 1 | TC-ORG-045 |
| HDU-TDC-R4-10 | CA03 | 1 | TC-ORG-046 |
| HDU-TDC-R4-10 | CA04 | 1 | TC-ORG-047 |
| HDU-TDC-R4-13 | CA01 | 3 | TC-ORG-048, TC-ORG-049, TC-ORG-050 |
| HDU-TDC-R4-13 | CA02 | 2 | TC-ORG-051, TC-ORG-052 |
| HDU-TDC-R4-13 | CA03 | 1 | TC-ORG-053 |
| HDU-TDC-R4-13 | CA04 | 3 | TC-ORG-054, TC-ORG-055, TC-ORG-056 |
| HDU-TDC-R4-14 | CA01 | 3 | TC-ORG-057, TC-ORG-058, TC-ORG-059 |
| HDU-TDC-R4-14 | CA02 | 2 | TC-ORG-060, TC-ORG-061 |
| HDU-TDC-R4-14 | CA03 | 1 | TC-ORG-062 |
| HDU-TDC-R4-14 | CA04 | 3 | TC-ORG-063, TC-ORG-064, TC-ORG-065 |
| HDU-TDC-R4-16 | CA01 | 3 | TC-ORG-066, TC-ORG-067, TC-ORG-068 |
| HDU-TDC-R4-16 | CA02 | 2 | TC-ORG-069, TC-ORG-070 |
| HDU-TDC-R4-16 | CA03 | 1 | TC-ORG-071 |
| HDU-TDC-R4-16 | CA04 | 3 | TC-ORG-072, TC-ORG-073, TC-ORG-074 |
| HDU-TDC-R4-17 | CA01 | 1 | TC-ORG-075 |
| HDU-TDC-R4-17 | CA02 | 1 | TC-ORG-076 |
| HDU-TDC-R4-17 | CA03 | 1 | TC-ORG-077 |
| HDU-TDC-R4-17 | CA04 | 1 | TC-ORG-078 |
| HDU-TDC-R4-17 | CA05 | 1 | TC-ORG-079 |
| HDU-TDC-R4-17 | CA06 | 2 | TC-ORG-080, TC-ORG-081 |
| HDU-TDC-R4-18 | CA01 | 1 | TC-ORG-082 |
| HDU-TDC-R4-18 | CA02 | 2 | TC-ORG-083, TC-ORG-084 |
| HDU-TDC-R4-18 | CA03 | 1 | TC-ORG-085 |
| HDU-TDC-R4-19 | CA01 | 1 | TC-ORG-086 |
| HDU-TDC-R4-19 | CA02 | 1 | TC-ORG-087 |
| HDU-TDC-R4-19 | CA03 | 1 | TC-ORG-088 |
| HDU-TDC-R4-19 | CA04 | 1 | TC-ORG-089 |
| HDU-TDC-R4-19 | CA05 | 1 | TC-ORG-090 |
| HDU-TDC-R4-20 | CA01 | 2 | TC-ORG-091, TC-ORG-092 |
| HDU-TDC-R4-20 | CA02 | 3 | TC-ORG-093, TC-ORG-094, TC-ORG-095 |
| HDU-TDC-R4-20 | CA03 | 1 | TC-ORG-096 |
| HDU-TDC-R4-20 | CA04 | 2 | TC-ORG-097, TC-ORG-098 |
| HDU-TDC-R4-21 | CA01 | 1 | TC-ORG-099 |
| HDU-TDC-R4-21 | CA02 | 2 | TC-ORG-100, TC-ORG-101 |
| HDU-TDC-R4-21 | CA03 | 1 | TC-ORG-102 |
| HDU-TDC-R4-23 | CA01 | 2 | TC-ORG-103, TC-ORG-104 |
| HDU-TDC-R4-23 | CA02 | 4 | TC-ORG-105, TC-ORG-106, TC-ORG-107, TC-ORG-108 |
| HDU-TDC-R4-23 | CA03 | 5 | TC-ORG-109, TC-ORG-110, TC-ORG-111, TC-ORG-112, TC-ORG-113 |
| HDU-TDC-R4-23 | CA04 | 4 | TC-ORG-114, TC-ORG-115, TC-ORG-116, TC-ORG-117 |
| HDU-TDC-R4-23 | CA05 | 5 | TC-ORG-118, TC-ORG-119, TC-ORG-120, TC-ORG-121, TC-ORG-122 |
| HDU-TDC-R4-24 | CA01 | 1 | TC-ORG-123 |
| HDU-TDC-R4-24 | CA02 | 2 | TC-ORG-124, TC-ORG-125 |
| HDU-TDC-R4-24 | CA03 | 3 | TC-ORG-126, TC-ORG-127, TC-ORG-128 |
| HDU-TDC-R4-24 | CA04 | 1 | TC-ORG-129 |
| HDU-TDC-R4-25 | CA01 | 1 | TC-ORG-130 |
| HDU-TDC-R4-25 | CA02 | 1 | TC-ORG-131 |
| HDU-TDC-R4-25 | CA03 | 1 | TC-ORG-132 |
| HDU-TDC-R4-25 | CA04 | 2 | TC-ORG-133, TC-ORG-134 |
| HDU-TDC-R4-26 | CA01 | 3 | TC-ORG-135, TC-ORG-136, TC-ORG-137 |
| HDU-TDC-R4-26 | CA02 | 3 | TC-ORG-138, TC-ORG-139, TC-ORG-140 |
| HDU-TDC-R4-26 | CA03 | 3 | TC-ORG-141, TC-ORG-142, TC-ORG-143 |
| HDU-TDC-R4-26 | CA04 | 3 | TC-ORG-144, TC-ORG-145, TC-ORG-146 |
| HDU-TDC-R4-26 | CA05 | 2 | TC-ORG-147, TC-ORG-148 |
| HDU-TDC-R4-27 | CA01 | 1 | TC-ORG-149 |
| HDU-TDC-R4-27 | CA02 | 1 | TC-ORG-150 |
| HDU-TDC-R4-27 | CA03 | 1 | TC-ORG-151 |
| HDU-TDC-R4-27 | CA04 | 2 | TC-ORG-152, TC-ORG-153 |
| HDU-TDC-R4-34 | CA01 | 2 | TC-ORG-154, TC-ORG-155 |
| HDU-TDC-R4-34 | CA02 | 1 | TC-ORG-156 |

---

## Advertencias y hallazgos

**El alcance derivado son 92 criterios, no 159.** El consolidado tiene 40 historias, pero solo 22 cuentan con visto bueno. Diez están marcadas como fuera de alcance para esta entrega, dos están desestimadas, tres dependen de una definición de terceros y tres no tienen estatus. Derivar de las historias fuera de alcance habría producido casos para cosas que nadie va a construir.

**Hay una contradicción en la regla de los treinta días.** Un criterio declara el número disponible si no fue verificado por otro cliente en los últimos treinta días; otro lo declara no disponible si fue verificado en menos de treinta días. En el día treinta exacto las dos reglas dan resultados opuestos. El caso de límite correspondiente deja el comportamiento como pendiente de determinar en lugar de elegir una interpretación.

**Los casos no funcionales no tienen umbral acordado.** No existe un objetivo de nivel de servicio firmado para esta línea. Deben ejecutarse para establecer una línea base, no para dar un resultado de aprobado o reprobado.

**Las tres historias que dependen de una definición de terceros siguen sin resolverse.** Suman trece criterios. Si entran en alcance agregan del orden de veinte casos al mismo nivel de detalle.

*v1.0.0 — 2026-10-16 — 186 casos — Datos de entrada sintéticos*