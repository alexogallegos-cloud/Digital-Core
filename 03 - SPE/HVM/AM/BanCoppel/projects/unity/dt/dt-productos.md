# DT-Productos — Catálogo de Productos y Componentes Unity

> **Tipo:** Digital Twin — Programa Unity  
> **Versión:** v1.0.0  
> **Estado:** `[STATE: ACTIVE]`  
> **Fuente:** Minutas R4 (Minuta de Sesiones/ — 17 documentos)  
> **Última actualización:** 2026-08-15

---

## Productos Unity

### UNITY-R4-P4900 — Tarjeta de Crédito

| Campo | Valor |
|-------|-------|
| **ID** | UNITY-R4-P4900 |
| **Nombre completo** | Tarjeta de Crédito |
| **Identificador BanCoppel** | Producto 4900 |
| **Estado** | `building` — en construcción |
| **Go-Live target** | Mediados de enero 2027 |
| **Plataforma core** | SmartVista (BPC Banking Technologies) |
| **Origination** | APOLO (Appwhere) |
| **Coexistencia con Informix** | `replaces` — sustituye CMS/Intercard/Macweb |
| **Dominios Informix que reemplaza** | TDC, Crédito, Cobranza, CMS |

**Descripción:** Primera TDC digital nativa de BanCoppel. El número de crédito de 18 dígitos equivale a la cuenta clave (clave interbancaria). Soporta parcializaciones MSI/MCI. La maquila de tarjetas plásticas se gestiona vía Connect Direct hacia proveedores (Forza, TGS, Tales).

> **Nota:** Los productos actualmente en producción sobre Temenos Transact no están especificados en las minutas R4. Actualizar este DT cuando se identifiquen.

---

## Componentes del Programa R4

Los componentes son los tracks de implementación de Unity R4, cada uno con su proveedor, alcance y estado.

### Resumen de Componentes

| ID | Nombre | Tipo | User Stories | Proveedor | Estado |
|----|--------|------|-----|-----------|--------|
| `smartvista` | SmartVista (BPC) | core | 22 | BPC Banking Technologies | development |
| `apolo` | APOLO — Originación Digital | core | 22 | Appwhere | development |
| `app` | APP / AppMovil | channel | 18 | Nova Solution Systems | development |
| `cat` | CAT — Contact Center (IBR+ICAT) | channel | 12 | **Por contratar** | **at_risk** |
| `siweb` | SIWEB — Sucursales | channel | 5 | Interno BanCoppel | **blocked** |
| `cobranza` | Cobranza Direccionada | enabler | 37–50 | Interno BanCoppel | development |
| `apificacion` | Apificación — Integraciones | transversal | — | Accenture | development |

**Total User Stories R4 (estimado):** ~116–129 User Stories

---

### Detalle por Componente

#### SmartVista — Core de Gestión de Tarjetas
- **Proveedor:** BPC Banking Technologies (contratado)
- **User Stories:** 22
- **Rol:** Motor de gestión de tarjetas de crédito. Procesa autorizaciones (88 reglas ISO 8583 validadas por eGlobal), saldos, pagos y estados de cuenta.
- **Reemplaza:** CMS / Intercard / Macweb (sistemas legados)
- **Diseño técnico (DTMs):** Responsable asignado: Appwhere
- **Dependencias:** Apificación para todos los contratos de integración con canales

#### APOLO — Originación Digital
- **Proveedor:** Appwhere (contratado)
- **User Stories:** 22
- **Rol:** Plataforma de originación y onboarding digital del Producto 4900. Gestiona el flujo desde solicitud hasta activación de la TDC.
- **Herramienta de gestión:** Mind Master
- **Metodología:** Flow Engineering (ciclos de 4 semanas de diseño)
- **Riesgo activo:** Latencia de 9 seg en PROD y 30 seg en QA — mejoras sin confirmar para producción.

#### APP / AppMovil — Canal Digital
- **Proveedor:** Nova Solution Systems (contratado)
- **User Stories:** 18
- **Rol:** Canal móvil principal del cliente para operar la TDC. Interfaz con el sistema de autorizaciones y con los SPs del core Informix.
- **Riesgo activo:** 6 User Stories Must Have cierran en noviembre 2026. SIT inicia el 15 de octubre — gap de al menos 1 mes.
- **Conexión Informix:** AppMovil utiliza 49 SPs del core Informix para canales existentes. La TDC será el primer producto nativo de Unity en AppMovil.

#### CAT — Contact Center (IBR + ICAT)
- **Proveedor:** Por contratar (RIESGO CRÍTICO)
- **User Stories:** 12
- **Rol:** Canal de atención telefónica. IBR es el sistema de contact center; ICAT es la herramienta de gestión de llamadas.
- **Riesgo:** Sin proveedor contratado al momento de las minutas. En el escenario optimista, el inicio de implementación sería mediados de octubre 2026 — justo cuando inicia SIT.
- **Bloqueo adicional:** El ambiente de IBR está bloqueado por infraestructura (requiere habilitación de servidor en nube que fue rechazada).

#### SIWEB — Sistema de Sucursales
- **Proveedor:** Interno BanCoppel
- **User Stories:** 5
- **Rol:** Sistema de atención en sucursal. Permite operar la TDC desde terminales físicas.
- **Estado:** BLOQUEADO — no puede avanzar hasta que Apificación entregue los contratos de API.
- **Riesgo adicional:** El responsable de DTMs de SIWEB (se asume Appwhere) no ha sido confirmado formalmente.

#### Cobranza Direccionada
- **Proveedor:** Interno BanCoppel
- **User Stories:** 37–50 (en consolidación)
- **Rol:** Sistema de cobranza. Preexistía a Unity R4 y se adapta para el Producto 4900.
- **Riesgo:** Pentest programado del 15 al 20 de noviembre 2026 — puede congelar el ambiente de Cobranza en pleno SIT.

#### Apificación — Equipo de Integraciones
- **Proveedor:** Accenture (José Villena, Oscar Melo)
- **User Stories:** Transversal — sin User Stories propias
- **Rol:** Diseña e implementa TODAS las integraciones entre componentes. Valida DTMs y DTCs (gobierno: Play Digital).
- **Riesgo:** El inventario de integraciones no está consolidado — ningún track tiene visión completa de sus dependencias con otros.

---

## Participantes Clave

| Nombre | Organización | Rol en Unity R4 |
|--------|-------------|-----------------|
| Pablo Lorenzo | Accenture | Líder del programa, coordinación con BanCoppel y proveedores |
| Ana Cervantes | Accenture | Gestión de User Stories, seguimiento de riesgos |
| José Villena | Accenture | Apificación — diseño e implementación de integraciones |
| Oscar Melo | Accenture | Apificación — diseño e implementación de integraciones |
| Fernanda Barbosa | BanCoppel | Responsable funcional — aprueba alcance |
| José Jaimes Ortiz | BanCoppel | Responsable técnico |

---

## Vista Producto — Definición del DT

Esta sección define lo que la Vista Producto del portal debe gobernar. El DT-Productos es el experto y establece el modelo; los valores concretos se alimentan desde `brain.db` y `source/`.

> **Principio rector del Gemelo Cognitivo:** El brain no es un dashboard de métricas. Es el motor de razonamiento que permite a los DT **proponer escenarios y alternativas** — técnicas y de gobernanza — cuando el estado del programa lo exige. Medir es el piso; el techo es el advisoring: *"dado este estado, estas son las tres rutas posibles y sus trade-offs"*.

---

### Capacidades de Negocio (ETB)

Mapa de capacidades de negocio del Producto 4900 hacia los sistemas que las habilitan:

| Capability | Descripción | Sistemas habilitadores | Semáforo | Motivo |
|------------|-------------|----------------------|----------|--------|
| `card-issuance` | Emisión, gestión y ciclo de vida de la TDC | SmartVista (BPC) | 🟡 At Risk | Gaps DPP, BYU0039, OCG manual sin resolver |
| `credit-origination` | Onboarding digital, solicitud y activación de la TDC | APOLO | 🟡 At Risk | Latencia 9s en PROD sin plan de mejora confirmado |
| `digital-channel` | Operación del producto vía canales del cliente | APP, SIWEB, CAT | 🔴 Crítico | CAT sin contratar; SIWEB bloqueado; App: 6 USs Must cierran en nov |
| `collections` | Cobranza del Producto 4900 | Cobranza Direccionada | 🟡 At Risk | Pentest 15-20 nov puede congelar ambiente en pleno SIT |
| `integration-fabric` | Contratos de integración entre todos los sistemas | Apificación (Accenture) | 🟡 At Risk | Inventario de integraciones no consolidado; ningún track tiene visión completa |
| `regulatory-reporting` | Reportes CNBV / Banxico del Producto 4900 | Reportes Regulatorios | 🟡 At Risk | Alcance R4 no confirmado formalmente |

---

### KPIs de Negocio — Modelo de Gobierno

Los siguientes KPIs gobiernan la Vista Producto. El DT define la estructura; los valores se completan desde source/ y el banco.

| KPI | Descripción | Valor actual | Fuente | Estado |
|-----|-------------|-------------|--------|--------|
| `us-must-completadas` | User Stories Must completadas vs. total Must | `[DATO-REQUERIDO]` | brain.db / track_rag | `[GAP]` |
| `us-total` | Total de User Stories R4 comprometidas | ~116–129 | DT-Productos | Estimado |
| `clientes-objetivo-r4` | Clientes objetivo fase 1 Go-Live | `[DATO-REQUERIDO]` | Documentos funcionales BanCoppel | `[GAP]` |
| `sla-autorizacion` | SLA de autorización de transacción (ms) | `[DATO-REQUERIDO]` | SLO/SLA contractual con BanCoppel | `[GAP]` |
| `sla-onboarding` | SLA de onboarding digital TDC (min) | `[DATO-REQUERIDO]` | SLO/SLA contractual con BanCoppel | `[GAP]` |
| `tracks-en-riesgo` | Tracks con semáforo 🔴 o 🟡 | 5 / 6 | DT-Productos | Calculable |
| `dias-go-live` | Días restantes al Go-Live 15-ene-2027 | Dinámico | brain.db | Calculable |
| `avance-r4` | % avance general del programa R4 | 21.19% (17-ago) | Plan de trabajo BanCoppel | Desactualizado |

---

### Bloqueos de Negocio Activos

Bloqueos que hoy impiden liberar valor al cliente final — perspectiva de negocio, no técnica:

| # | Bloqueo | Capability afectada | Dueño | Tipo | Fecha límite |
|---|---------|---------------------|-------|------|-------------|
| 1 | CAT (Contact Center) sin proveedor contratado | `digital-channel` | BanCoppel | Vendor / Contratación | Crítica — SIT inicia oct |
| 2 | SIWEB bloqueado hasta que Apificación entregue contratos API | `digital-channel` | Apificación (Accenture) | Dependencia técnica | `[DATO-REQUERIDO]` |
| 3 | Latencia APOLO 9s en PROD sin plan de mejora confirmado | `credit-origination` | Appwhere | Performance | `[DATO-REQUERIDO]` |
| 4 | Inventario de integraciones no consolidado | `integration-fabric` | Apificación (Accenture) | Gobernanza | Inmediato |
| 5 | Pentest nov 15-20 congela ambiente SIT de Cobranza | `collections` | BanCoppel / Infra | Planeación | 15-nov-2026 |

---

### Gaps de Información — Alimentar al Digital Brain

Los siguientes datos son necesarios para la Vista Producto ejecutiva y no están disponibles aún:

| Gap ID | Información requerida | Impacto en Vista Producto | Fuente probable |
|--------|----------------------|--------------------------|-----------------|
| GAP-VP-001 | Clientes objetivo fase 1 Go-Live | KPI central del producto | Documentos funcionales / DIP BanCoppel |
| GAP-VP-002 | SLAs de servicio contractuales (autorización, onboarding, cobranza) | Criterios de éxito del Go-Live | Contrato / SLO acordado con BanCoppel |
| GAP-VP-003 | User Stories Must completadas por track (no solo total) | Semáforo de avance real por capability | Sistema de gestión (Jira/Mind Master/Excel) |
| GAP-VP-004 | Volumen transaccional esperado mes 1 post Go-Live | Sizing y resiliencia operativa | Plan de negocio BanCoppel |
| GAP-VP-005 | Criterios de Go/No-Go formales del banco | Semáforo de readiness | Design Authority / Gobierno |

---

## Narrativa Funcional por Fase — Cadena de Valor TDC

> **Fuente DT**: DT-Productos · DT-Compliance · DT-SmartVista · DT-Apolo  
> **Marco de referencia**: Ley de Instituciones de Crédito (LIC), Circular Única de Bancos CNBV, CONDUSEF Reglamento TDC, Reglas Visa scheme, PCI-DSS v4.0, BANXICO SPEI, NIF C-16  
> **Propósito**: Describir la cadena de valor de la Tarjeta de Crédito desde la perspectiva del negocio y la industria — agnóstica al proyecto — para que sirva de referencia al identificar brechas en Unity R4.  
> **Principio de lectura**: cada fase describe primero el estándar de la industria tal como lo exige el marco regulatorio mexicano y las redes de pago. La columna "R4" describe qué tiene el proyecto hoy. La columna "Brechas" identifica el delta.

---

### Fase 01 — Originación

**Proceso de industria**

La originación es la primera experiencia del cliente con el producto de crédito. En México, el marco regulatorio exige que el banco valide la identidad del solicitante (KYC), realice una consulta al Buró de Crédito, evalúe su capacidad de pago y le entregue la información precontractual del producto antes de formalizar cualquier compromiso. La CONDUSEF establece que el contrato de adhesión debe registrarse en el sistema RECA antes de que el banco lo use con clientes, y que debe incluir el CAT (Costo Anual Total) calculado conforme a la Circular 9/2019 de Banxico. La institución está obligada a entregar al cliente el "Resumen de Contrato" en el momento de la firma.

El flujo estándar de industria tiene cinco momentos:

1. **Captación de solicitud**: el cliente inicia el proceso digital o presencial. Proporciona datos personales, laborales y financieros.
2. **Validación de identidad**: KYC (Know Your Customer) conforme a CNBV — verificación documental (INE/pasaporte), validación biométrica y cotejo con listas de PLD/Minds (UIF). La LFPIORPI obliga a reportar operaciones sospechosas.
3. **Análisis crediticio**: consulta al Buró de Crédito o Círculo de Crédito. Score interno (CES en el caso de BanCoppel) y reglas de elegibilidad. La LIC Art. 65 establece que el banco debe tener políticas de crédito documentadas y aprobadas por el Consejo.
4. **Decisión y oferta**: aprobación (con límite de crédito asignado), rechazo con causa, o contra-oferta. Si se rechaza, la CONDUSEF exige notificar al cliente. La CNBV exige que las políticas de crédito sean consistentes y no discriminatorias.
5. **Formalización**: firma del contrato de adhesión (RECA), entrega de información CONDUSEF y alta del producto en el sistema core (SmartVista para el Producto 4900).

**KPIs de referencia de la industria**

| KPI | Descripción | Benchmark MX |
|-----|-------------|-------------|
| Tasa de aprobación | Solicitudes aprobadas / solicitudes totales | 30-55% (varía por segmento) |
| Tiempo de resolución | Minutos desde solicitud hasta decisión | < 5 min digital; < 24h canal presencial |
| Tasa de activación en 30 días | % tarjetas emitidas que se activan en los primeros 30 días | > 70% en productos digitales |
| Tasa de fraude en originación | Solicitudes fraudulentas detectadas / solicitudes totales | < 0.5% |
| CAT comunicado | Costo Anual Total correcto en el resumen de contrato | Cumplimiento 100% (CONDUSEF) |
| Consulta Buró exitosa | % solicitudes con consulta Buró ejecutada sin error | > 99.5% |

**Mapa R4 (Unity)**

| Campo | Valor |
|-------|-------|
| User Stories | 22 (IAPLO-001…022) — track completo APOLO |
| Sistema habilitador | APOLO (Appwhere) |
| Sistemas de validación | PLD/Minds, Buró de Crédito, KYC, CES (Score) |
| Sistema destino | SmartVista BPC (alta de cuenta) |

**Brechas identificadas**

| Brecha | Tipo | Impacto |
|--------|------|---------|
| Flujo interno APOLO no mapeado en detalle (pantallas intermedias pendientes) | Cobertura funcional | No es posible validar completitud del journey |
| Clientes objetivo (volumen, segmento) sin definir | GAP-VP-001 | Imposible dimensionar infraestructura ni SLAs |
| Latencia 9 seg en PROD y 30 seg en QA — sin plan de mejora confirmado | Rendimiento | Viola benchmark < 5 min, puede afectar conversión |
| Resumen de Contrato CONDUSEF: sin evidencia de formato validado en R4 | Regulatorio | Riesgo de incumplimiento al go-live |
| RECA del contrato de adhesión: fecha de registro no confirmada | Regulatorio (DATO-REQUERIDO) | Bloquea emisión de primera tarjeta |

---

### Fase 02 — Emisión y maquila

**Proceso de industria**

La emisión es el proceso por el cual el banco convierte una cuenta de crédito aprobada en un instrumento de pago físico o digital. Para la tarjeta física, la industria opera con una cadena técnica estándar que involucra al sistema de gestión de tarjetas (CMS/processor), una herramienta de personalización de plásticos, y uno o más maquiladores externos certificados PCI-DSS.

El flujo estándar de la industria tiene cuatro etapas:

1. **Generación del lote**: el sistema de gestión de tarjetas (SmartVista SVBO para el Producto 4900) identifica las cuentas aprobadas pendientes de maquila y arma un lote de personalización.
2. **Preparación del archivo de personalización**: un módulo de generación (OCG/Cargen) produce el archivo con los datos de personalización: PAN, nombre del titular, fecha de expiración, datos del chip. Este archivo es el insumo para el maquilador.
3. **Cifrado y transferencia segura**: el archivo se cifra con PGP y se transfiere al maquilador mediante un protocolo de transferencia seguro (Connect-Direct, SFTP o similar). El HSM (Hardware Security Module) genera y custodia las llaves por tarjeta. PCI-DSS DSS 3.2 exige que los datos del titular no viajen en claro.
4. **Personalización física y envío**: el maquilador embosa el plástico, instala el chip, genera el PIN mailer y envía la tarjeta al cliente. El tiempo estándar de industria en México es 5-10 días hábiles desde la aprobación.

La CNBV exige que los maquiladores estén certificados y que el banco mantenga control sobre las llaves de personalización (dual control, Requirement 3.6 PCI-DSS). Los maquiladores en México más comunes son: Thales, G+D, TGS (Thomas Greg and Sons), Arroyo y Forza Form.

**KPIs de referencia de la industria**

| KPI | Descripción | Benchmark MX |
|-----|-------------|-------------|
| Tiempo aprobación → tarjeta en mano | Días hábiles | 5-10 días |
| Tasa de defectos de maquila | Tarjetas rechazadas / total producidas | < 0.1% |
| Tasa de activación post-maquila | Tarjetas activadas dentro de 30 días de recibidas | > 70% |
| Integridad de lote | Lotes sin incidentes de seguridad | 100% (PCI-DSS) |
| Cobertura de maquilador | Capacidad de producción vs. volumen proyectado | Definida por SLA con maquilador |

**Mapa R4 (Unity)**

| Campo | Valor |
|-------|-------|
| User Stories | 8 (ISV01, ISV02, HDU-SMART-R4-01 a 08) — track SmartVista |
| Sistema habilitador | SmartVista SVBO → OCG → Cargen → Connect-Direct |
| HSM | Thales payShield 10K (PIN y CVV2) |
| Maquilador definido | Forza Form (de facto, pendiente formalización) |

**Brechas identificadas**

| Brecha | Tipo | Impacto |
|--------|------|---------|
| Connect-Direct no está en producción — depósito manual por tickets | Operativo crítico | Bloquea flujo end-to-end; no puede escalar a volumen real |
| Maquilador único no definido formalmente | Contractual | Sin SLA de producción; riesgo si Forza Form no tiene capacidad |
| Inconsistencia de maquiladores en documentación (3-5 proveedores en distintos docs) | Gobernanza | Necesita decisión formal de Negocio BanCoppel |
| Certificación PCI-DSS del maquilador: no confirmada en R4 | Regulatorio | PCI-DSS exige maquiladores certificados (Req. 12.8) |
| Tiempo aprobación → tarjeta en mano: sin SLA definido en R4 | GAP-VP-002 | Sin criterio de éxito del go-live para esta fase |

---

### Fase 03 — Activación

**Proceso de industria**

La activación es el acto por el que el cliente declara recibir y aceptar la tarjeta, iniciando la relación crediticia activa. En México, la CONDUSEF exige que la tarjeta NO esté activa al momento de la entrega — el cliente debe activarla explícitamente, lo que funciona como segunda confirmación del consentimiento. Este requerimiento tiene un impacto directo en el diseño técnico: el sistema de autorización no puede responder positivamente a ninguna transacción de una cuenta no activada.

El estándar de industria ofrece cuatro canales de activación:

1. **Canal digital (App Móvil)**: validación de identidad biométrica o por token, activación en tiempo real. Es el canal preferido en productos nativos digitales.
2. **IVR (Contact Center automatizado)**: activación por voz con validación de datos personales. Canal crítico para clientes sin smartphone.
3. **Sucursal**: activación presencial con validación de identidad por ejecutivo. Canal de respaldo.
4. **ATM**: activación con tarjeta física + NIP provisional. Canal para tarjetas con chip físico.

Para la Tarjeta Digital (virtual), la activación incluye la provisión del token de pago (MDES/VTS para Apple Pay y Google Pay) mediante el sistema EMV 3DS del emisor.

**KPIs de referencia de la industria**

| KPI | Descripción | Benchmark MX |
|-----|-------------|-------------|
| Tasa de activación a 30 días | % tarjetas emitidas activadas en 30 días | > 70% |
| Tasa de activación a 7 días | Indicador temprano de engagement | > 40% para productos digitales |
| Canal de activación preferido | Distribución por canal | App > 60% en digital-first |
| Tiempo al primer uso | Horas desde activación hasta primera transacción | < 48h en productos digitales |
| Intentos fallidos de activación | % activaciones con al menos un intento fallido | < 5% |

**Mapa R4 (Unity)**

| Campo | Valor |
|-------|-------|
| User Stories | 2 (IAPP05) — track App |
| Sistema habilitador | App Móvil → CES (identidad) → SmartVista (activar) |
| Canales en R4 | App Móvil (con User Story) |

**Brechas identificadas**

| Brecha | Tipo | Impacto |
|--------|------|---------|
| Activación por ATM documentada como Customer Journey (CJ_ATM_01) pero sin User Story en R4 | Cobertura funcional | Clientes sin smartphone no pueden activar por canal alternativo probado |
| Activación por SIWEB (sucursal) documentada como CJ_OFI_22 pero sin User Story en R4 | Cobertura funcional | Dependencia de canal digital para 100% de activaciones |
| Provisión de token digital (Apple Pay / Google Pay): no mencionada en R4 | Omisión de producto | TDC digital sin soporte de billeteras digitales al go-live |
| SLA de tiempo al primer uso: sin definir en R4 | GAP-VP-002 | Sin criterio de éxito para el engagement post-activación |

---

### Fase 04 — Autorización

**Proceso de industria**

La autorización es el corazón operativo de cualquier producto de tarjeta de crédito. Ocurre en tiempo real cada vez que el portador intenta realizar una compra. El flujo estándar de la industria sigue el protocolo ISO 8583 y las reglas del esquema Visa:

1. **Captura del mensaje**: el POS o la terminal e-commerce captura los datos de la tarjeta y genera un mensaje ISO 8583 type 200 (Authorization Request).
2. **Enrutamiento**: la red adquirente envía el mensaje al emisor a través del switch de la red (Visa Net, PROSA, E-Global según el caso).
3. **Validación del switch emisor**: el sistema de autorización del emisor (SmartVista SVFE para el Producto 4900) aplica las reglas del producto: límite disponible, validez de la tarjeta, verificación de CVV2 (para e-commerce), control de fraude.
4. **Respuesta**: el sistema devuelve un mensaje ISO 8583 type 210 con código de respuesta (00 = aprobado; otros = declinado con causa).
5. **Registro**: la transacción queda registrada en el sistema de gestión de tarjetas con estado pendiente hasta la liquidación al día siguiente.

Regulatoriamente, Banxico exige tiempos de respuesta de autorización dentro de los SLAs de red de pagos. La CNBV exige que el banco tenga controles de fraude activos y reporte eventos de fraude en tiempo y forma. El esquema Visa tiene reglas específicas sobre tasas de declinación (un emisor con alta tasa de declinación injustificada recibe penalizaciones).

**KPIs de referencia de la industria**

| KPI | Descripción | Benchmark MX |
|-----|-------------|-------------|
| Tasa de autorización | Transacciones aprobadas / totales presentadas | > 85% (Visa recomienda > 90% para emisores maduros) |
| Latencia de autorización P99 | Percentil 99 del tiempo de respuesta | < 2,000 ms (Visa exige < 5,000 ms) |
| Tasa de fraude | Monto en fraude / monto total autorizado | < 0.05% (benchmark CNBV) |
| Tasa de chargebacks | Chargebacks / transacciones totales | < 1% para no activar reglas Visa |
| Disponibilidad del autorizador | Uptime del sistema de autorización | > 99.9% (24x7) |
| Tasa de falsos positivos | Transacciones legítimas declinadas por fraude | < 0.5% |

**Mapa R4 (Unity)**

| Campo | Valor |
|-------|-------|
| User Stories | 1 (88 reglas de autorización SmartVista) |
| Sistema habilitador | E-Global → SmartVista SVFE → HSM (CVV2 e-commerce) |
| Reglas | 88 reglas de autorización (se pueden reordenar, no ampliar) |
| Cierre de análisis | 16-oct-2026 — última US en cerrar de todo R4 |

**Brechas identificadas**

| Brecha | Tipo | Impacto |
|--------|------|---------|
| Contradicción abierta sobre SVFM: PreGame dice "no licenciado"; Plan de Trabajo dice "instalado y probado" | Gobernanza crítica | El módulo de fraude puede no estar disponible en go-live |
| PayTrue no está en la ruta sincrónica (ciclos de 3 min desacoplados) | Arquitectura | Ventana de 3 minutos sin modelo de riesgo actualizado |
| Segundo autorizador (Interact Switch/Syndein) para POS/ATM/débito no en scope R4 | Cobertura | Riesgo de inconsistencia entre autorizadores para el portador |
| SLA de autorización (latencia P99): sin definir en contrato R4 | GAP-VP-002 | Sin criterio técnico de go-live para la operación más crítica |
| Reglas de fraude Visa (3DS v2 para e-commerce): sin evidencia en R4 | Regulatorio/Esquema | Riesgo de incumplimiento Visa y alta tasa de chargebacks en e-commerce |
| Ventanas de prueba de confort con E-Global: no confirmadas | Cronograma | La US 88 reglas cierra análisis el 16-oct — overlap con inicio SIT |

---

### Fase 05 — Transacciones

**Proceso de industria**

La fase de transacciones abarca todas las operaciones que el cliente realiza sobre el producto activo después de la activación: consultas de saldo, movimientos y estado de cuenta. La CONDUSEF establece que el emisor debe poner a disposición del cliente su estado de cuenta de forma gratuita y en el formato regulatorio establecido, con al menos 45 días entre la fecha de corte y la fecha límite de pago.

Los canales que la industria exige habilitar para una tarjeta de crédito bancaria en México son:

1. **App móvil o banca digital**: canal preferente. Debe mostrar saldo disponible, línea de crédito, movimientos detallados y fecha de corte / pago.
2. **Centro de atención (Contact Center / IVR)**: obligatorio por CONDUSEF. El IVR automatizado debe al menos ofrecer consulta de saldo y última fecha de pago.
3. **Sucursal**: acceso por sistema interno del ejecutivo de banco.
4. **ATM / cajero automático**: consulta de saldo básica mediante red PROSA o E-Global.
5. **Estado de cuenta mensual**: en formato físico (opcional) y/o digital. El formato CONDUSEF exige campos mínimos: saldo, intereses, fecha de corte, fecha de pago y pago mínimo.

Las compras diferidas (MSI — Meses Sin Intereses y MCI — Meses Con Intereses) son transacciones reguladas: el Banco de México y la CONDUSEF exigen que el estado de cuenta muestre el desglose de parcializaciones activas, el cargo por mes y el saldo pendiente de cada diferimiento.

**KPIs de referencia de la industria**

| KPI | Descripción | Benchmark MX |
|-----|-------------|-------------|
| Adopción de canal digital | % portadores con al menos 1 consulta digital / mes | > 60% en productos digitales |
| Tiempo de respuesta de consulta | Latencia P95 en App / Banca digital | < 2 segundos |
| Entrega oportuna de estado de cuenta | % estados de cuenta entregados antes de la fecha de corte | 100% (CONDUSEF) |
| Tasa de reclamación por estado de cuenta | Reclamaciones CONDUSEF por errores en estado de cuenta | < 0.1% de cuentas |
| Adopción de MSI/MCI | % transacciones diferidas sobre total de compras | Varía por segmento; > 30% en retail |

**Mapa R4 (Unity)**

| Campo | Valor |
|-------|-------|
| User Stories | 17 (IAPP01, ICAT01/02/04/07, ISV03) — multi-canal |
| Sistemas habilitadores | App, SIWEB, CAT/IVR → SmartVista (libro de saldos) |
| Canal con más integraciones | CAT (4 integraciones de consulta) |

**Brechas identificadas**

| Brecha | Tipo | Impacto |
|--------|------|---------|
| CAT ausente del diagrama original — 4 integraciones de consulta no documentadas | Cobertura | El canal de mayor criticidad para clientes sin smartphone estaba oculto |
| Inconsistencia IAPP02/IAPP03: dirección origen-destino invertida en inventario | Calidad de datos | Error de captura que afecta el mapa de integraciones |
| ATM (consulta de saldo): no en scope R4 | Omisión | Canal regulatorio básico no cubierto |
| Estado de cuenta formato CONDUSEF: sin evidencia de validación en R4 | Regulatorio | Riesgo incumplimiento al primer mes post go-live |
| MSI/MCI en estado de cuenta: sin User Story específica identificada | Cobertura funcional | Producto 4900 soporta MSI/MCI pero el desglose en canal no está confirmado |

---

### Fase 06 — Pagos

**Proceso de industria**

El pago es la fase de mayor impacto en la relación cliente-banco. Un proceso de pago mal diseñado es la principal causa de morosidad involuntaria y de reclamaciones CONDUSEF. El marco regulatorio en México establece obligaciones precisas:

La CONDUSEF exige que el cliente tenga al menos **dos mecanismos de pago sin costo** disponibles, que la fecha límite de pago sea al menos 45 días después de la fecha de corte, y que el banco ofrezca la opción de pago mínimo claramente separada del pago total. El Banco de México regula el cálculo del pago mínimo y establece el límite mínimo de pago en función del saldo.

Los canales de pago que la industria debe ofrecer en México son:

1. **Transferencia SPEI**: pago vía SPEI desde cualquier banco. Liquidación en minutos. Es el canal de mayor uso en pagos bancarios digitales.
2. **Pago en ventanilla / sucursal**: pago en efectivo o cheque en sucursal del propio banco. Obligatorio para bancos con red de sucursales.
3. **Domiciliación / cargo automático**: el cliente autoriza el cargo automático en una cuenta de débito o cheques.
4. **CoDi (Cobro Digital)**: pago mediante QR o CLABE de Banxico. Canal en crecimiento.
5. **Pago en tiendas de conveniencia** (Oxxo, 7-Eleven): disponible para algunos emisores mediante acuerdos con Bepensa/PayCash.
6. **Banca en línea del banco emisor**: desde la App o portal web del mismo banco.

El proceso de aplicación del pago en el sistema de gestión de tarjetas incluye: recepción del mensaje de liquidación (normalmente via SPEI o archivo batch), actualización del saldo disponible en SmartVista, y notificación al cliente.

**KPIs de referencia de la industria**

| KPI | Descripción | Benchmark MX |
|-----|-------------|-------------|
| Tasa de pago a tiempo | % portadores que pagan antes de la fecha límite | > 80% (cartera sana) |
| Tasa de pago mínimo | % portadores que pagan solo el mínimo | < 30% (señal de riesgo si es mayor) |
| Tiempo de acreditación SPEI | Minutos desde transferencia hasta saldo disponible | < 5 minutos (estándar SPEI) |
| Tasa de morosidad involuntaria | Pagos tardíos por error del canal (no del cliente) | < 0.1% |
| Uso de pago domiciliado | % portadores con cargo automático activo | > 20% en portadores maduros |
| Reclamaciones CONDUSEF por pagos | Reclamaciones por errores de aplicación de pago | < 0.05% de cuentas |

**Mapa R4 (Unity)**

| Campo | Valor |
|-------|-------|
| User Stories | 14 (ISV, IAPP02-03) — SmartVista + App |
| Sistemas habilitadores | App Móvil / SIWEB → SmartVista → SPEI |
| Canal SPEI | Liquidación vía SPEI (integración confirmada) |

**Brechas identificadas**

| Brecha | Tipo | Impacto |
|--------|------|---------|
| Pago en ventanilla de sucursal (SIWEB): sin plan de entrega confirmado dado el bloqueo de SIWEB | Operativo | Clientes sin canal digital no tienen alternativa de pago confirmada |
| Pago por CoDi: no mencionado en R4 | Omisión | Canal regulatorio emergente (Banxico lo promueve activamente) |
| Domiciliación / cargo automático: sin User Story identificada en R4 | Omisión de producto | Herramienta clave para reducir morosidad involuntaria |
| Pago en tiendas de conveniencia: sin cobertura en R4 | Omisión | Segmento BanCoppel usa este canal activamente |
| Acreditación SPEI y notificación al cliente: sin SLA definido en R4 | GAP-VP-002 | Sin criterio de éxito para la experiencia de pago |

---

### Fase 07 — Contabilidad y conciliación

**Proceso de industria**

La contabilidad y conciliación es la fase invisible para el cliente pero crítica para el regulador. Todo banco en México debe mantener un libro contable (mayor general) que refleje fielmente cada operación del portador de tarjeta, en el mismo día hábil en que ocurre. La CNBV — vía la Circular Única de Bancos, Anexos 33 y 36 — define los catálogos contables mínimos y los reportes que el banco debe entregar mensualmente.

El proceso estándar de la industria tiene cuatro momentos:

1. **Posting diario (end-of-day)**: el sistema de gestión de tarjetas (SmartVista) cierra el día y genera los asientos contables de todas las transacciones autorizadas. Cada transacción produce un débito y un crédito en las cuentas del plan contable del banco. Para el Producto 4900, esto incluye: cargos por compras, pagos recibidos, intereses devengados, comisiones, y reversiones.
2. **Interfaz al Core Bancario**: los asientos contables se envían al sistema de contabilidad central (PISA/CBS en BanCoppel), que es el libro de registro oficial del banco. La interfaz estándar para SmartVista es SVXP (un archivo XML contable). La CNBV exige que el libro contable esté en el core bancario, no en el procesador de tarjetas.
3. **Conciliación**: el banco verifica que el total de transacciones autorizadas en el día coincida con el total de movimientos contabilizados. Cualquier diferencia (break) debe investigarse y resolverse dentro del mismo día hábil o el siguiente según las políticas del banco. Los breaks no resueltos se reportan a la CNBV.
4. **Reportería regulatoria CNBV**: el banco genera mensualmente los reportes R01 (Catálogo Mínimo), R04C (Portafolio de Crédito), y los anexos de tarjeta de crédito según el Cuaderno Contable de la CNBV. La NIF C-16 exige que el banco estime y registre la pérdida esperada (provisión) sobre el portafolio de tarjeta de crédito.

**KPIs de referencia de la industria**

| KPI | Descripción | Benchmark MX |
|-----|-------------|-------------|
| Tasa de conciliación D+0 | % transacciones conciliadas el mismo día | > 99.5% |
| Breaks sin resolver > 24h | Número de diferencias contables abiertas más de 1 día | 0 (objetivo CNBV) |
| Latencia de posting | Horas desde cierre de negocio hasta posting completo | < 4 horas |
| Compliance reportería CNBV | Reportes entregados en tiempo y forma | 100% — multas automáticas por incumplimiento |
| Provisión NIF C-16 | Pérdida esperada calculada y registrada mensualmente | Obligatorio |

**Mapa R4 (Unity)**

| Campo | Valor |
|-------|-------|
| User Stories | Ninguna propia — entregables pendientes (guía contable + definición de TRNTs) |
| Sistemas habilitadores | SmartVista SVBO → SVXP → Informix/PISA |
| BIN | 42680711 — conciliación informativa en PISA (sin afectación de cuentas) |
| Bloqueo | SVXP→PISA no construida (tramo punteado) |

**Brechas identificadas**

| Brecha | Tipo | Impacto |
|--------|------|---------|
| Interfaz SVXP→PISA no construida — prioridad PreGame no ejecutada | Técnico crítico | Sin esta interfaz no hay contabilidad regulatoria al go-live |
| Guía contable formal (definición de TRNTs del Producto 4900): no entregada al cierre de documentación | Regulatorio crítico | Sin guía contable, PISA no puede parametrizarse |
| Nuevo tipo de conciliación SOC (Característica 5 del requerimiento 16-nov-2023): sin plan en R4 | Omisión de alcance | Incumplimiento de requerimiento formal de BanCoppel |
| User Stories de contabilidad: sin identificar en R4 — la fase existe solo como entregables informales | Gobernanza | No hay criterio de aceptación formal para esta fase |
| Provisión NIF C-16: sin evidencia de diseño en R4 | Regulatorio CNBV | Obligatorio desde el primer mes en producción |
| Reportería CNBV desde SmartVista (Anexos 33/36): alcance no confirmado en R4 | GAP-VP-005 (Reg.) | Riesgo de incumplimiento en primer mes post go-live |

---

### Fase 08 — Cobranza

**Proceso de industria**

La cobranza es la fase que cierra el ciclo de crédito y determina la salud de la cartera. En México, el marco regulatorio establece límites precisos al banco para proteger al deudor: la CONDUSEF prohíbe llamadas en horarios fuera de 8am-9pm, exige que el banco ofrezca reestructura antes de reportar al Buró, y establece el proceso de aclaración (PROFECO). La CNBV exige que el banco reporte mensualmente la cartera vencida al Sistema de Información de Sociedades de Información Crediticia (SISEC) y realice la provisión contable correspondiente (NIF C-16).

El proceso estándar de industria opera en cuatro capas de gestión por antigüedad de vencimiento (aging):

1. **Gestión preventiva (1-29 días)**: activación temprana por notificaciones digitales, SMS y campañas de pago. El objetivo es evitar que el portador llegue a vencimiento.
2. **Gestión temprana (30-60 días)**: contacto activo por IVR automatizado y agentes. Oferta de pago del mínimo o de un acuerdo de pago. Reporte al Buró de Crédito al día 30 de atraso.
3. **Gestión de cartera vencida (61-120 días)**: agentes especializados en cobranza. Posibilidad de reestructura del crédito. Incremento de provisión contable.
4. **Gestión de cartera en litigio / castigo (> 120 días)**: proceso de castigo contable y, en algunos casos, cesión de cartera a agencias de cobranza externas. La CNBV exige que la institución tenga una política de castigo documentada.

**KPIs de referencia de la industria**

| KPI | Descripción | Benchmark MX |
|-----|-------------|-------------|
| Índice de morosidad (NPL ratio) | Cartera vencida > 90 días / cartera total | < 4% (cartera sana para TDC masiva) |
| Tasa de recuperación temprana | % deudores en gestión temprana que pagan en < 30 días de contacto | > 60% |
| Contactabilidad | % deudores contactados sobre intentos realizados | > 40% (canal digital) |
| Tasa de castigo | % cartera castigada / cartera vencida > 180 días | Según política interna (CNBV valida consistency) |
| Costo de cobranza / monto recuperado | Eficiencia operativa de la gestión | Varía; objetivo < 20% |
| Reclamaciones CONDUSEF por prácticas de cobranza | Quejas por hostigamiento o violación de horarios | 0 tolerancia |

**Mapa R4 (Unity)**

| Campo | Valor |
|-------|-------|
| User Stories | Ninguna en inventario R4 — Cobranza Direccionada tiene 37-50 USs en refinamiento (iniciativa pre-existente) |
| Sistemas habilitadores | SmartVista (aging) → Informix (agingPeriod batch) → Connect-Direct → CAT/IVR |
| Estado | Iniciativa pre-existente; alcance no incorporado al inventario unificado R4 |

**Brechas identificadas**

| Brecha | Tipo | Impacto |
|--------|------|---------|
| 37-50 User Stories de Cobranza no incorporadas al inventario R4 | Gobernanza crítica | Hueco de alcance formal en el programa |
| Pentest 15-20 noviembre congela ambiente de Cobranza en pleno SIT | Cronograma crítico | Bloquea pruebas en la fase con más USs por confirmar |
| Reporte al Buró de Crédito (CNBV/SISEC): sin evidencia de diseño en R4 | Regulatorio | Obligatorio al día 30 de atraso — primer portador moroso activa el requerimiento |
| Gestión preventiva digital (día 1-29): sin User Story identificada en R4 | Omisión | Sin gestión preventiva, la tasa de morosidad temprana será mayor |
| Proceso de reestructura de deuda: sin alcance en R4 | Omisión regulatoria | CONDUSEF exige oferta de reestructura antes del castigo |
| Política de castigo contable documentada: sin evidencia en R4 | Regulatorio CNBV | Obligatoria para la primera cartera vencida del producto |

---

*Narrativa funcional elaborada por DT-Productos v1.2.0 · 2026-08-20*  
*Cross-referencia: DT-Compliance v1.0.0 · DT-SmartVista · DT-Apolo · DT-Integraciones*  
*Marco regulatorio: LIC, CUB CNBV Anexos 33-36, CONDUSEF Circular 09/2019, Banxico SPEI, Visa Core Rules, PCI-DSS v4.0, NIF C-16*

---

*Generado desde: minutas R4 · brain.db v0.2.0 · build-brain.py*  
*Vista Producto enriquecida por DT-Productos v1.2.0 · 2026-08-20*
