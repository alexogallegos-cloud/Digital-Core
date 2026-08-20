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

## Estado de Capabilities ETB

> Pendiente de mapeo formal. La Tarjeta de Crédito cubre al menos: card-issuance, credit-origination, collections, digital-channel.

---

*Generado desde: minutas R4 · brain.db v0.2.0 · build-brain.py*
