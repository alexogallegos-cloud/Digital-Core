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

*Generado desde: minutas R4 · brain.db v0.2.0 · build-brain.py*  
*Vista Producto enriquecida por DT-Productos v1.1.0 · 2026-08-20*
