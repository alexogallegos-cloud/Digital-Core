# ADR-ANCE-004: Gestión de Identidad y Accesos — IAM propio para el mock, SSO federado en producción
Fecha: 2026-07-24
Estado: ACCEPTED (alcance: mock / prototipo)
Owner: dt-security-engineer
SME consultado: `[PENDIENTE: IAM & PAM · Cybersecurity CISO para diseño de producción]`

## Contexto

El Portal Nómina es una app standalone que en producción se integrará al Portal Empresa existente de Scotiabank México, muy probablemente vía **SSO federado** (el portal padre emite la identidad). Sin embargo, para la fase de **mock / prototipo** no se tiene aún acceso al IdP de Scotiabank ni al contrato de federación del portal existente (ambos son `[DATO-REQUERIDO]`).

Bloquear el mock hasta tener el SSO real detendría todo el delivery. Se necesita una estrategia de autenticación que permita construir y demostrar el portal end-to-end sin depender del IdP de Scotiabank, pero sin acumular deuda que obligue a rearquitectura cuando llegue el SSO.

## Opciones evaluadas

1. **Esperar al SSO federado del Portal Empresa existente**
   - Ventajas: refleja la arquitectura de producción desde el día 1.
   - Desventajas: bloquea el mock indefinidamente (`[DATO-REQUERIDO]` del IdP y del contrato de federación); no hay forma de demostrar el portal.

2. **IAM propio del portal para el mock, abstraído tras un proveedor de autenticación intercambiable** ✅
   - Ventajas: desbloquea el mock de inmediato; el portal gestiona sus propios usuarios, roles y JWT; al abstraer el proveedor de identidad detrás de una interfaz, migrar a OIDC/SSO federado en producción no toca la lógica de negocio ni de autorización.
   - Desventajas: se implementa un auth service que en producción se reemplaza (esfuerzo parcialmente descartable, acotado por la abstracción).

3. **Mock sin autenticación (usuarios hardcodeados en el frontend)**
   - Ventajas: máxima velocidad inicial.
   - Desventajas: no permite validar el modelo de roles ni los flujos de autorización (`@PreAuthorize`), que son parte central del portal bancario; genera deuda que hay que rehacer entera.

## Decisión

Elegimos la **Opción 2**: el Portal Nómina implementa su **propia gestión de identidad y accesos para el mock**, con estas características:

- **Autenticación**: auth service propio (Spring Security) que emite **JWT** firmado por el portal. Login screen propia en Angular 20.
- **Almacén de usuarios y roles**: tabla de usuarios en SQL Server 2022 (o seed en memoria para el mock), con el modelo de roles del portal: `ADMIN-EMP`, `OPER-NOM`, `AUD-EMP`, `ADMIN-SCO`.
- **Autorización**: `@PreAuthorize` basado en roles desde el mock — el modelo de autorización es el mismo que en producción.
- **Abstracción del proveedor de identidad**: la validación del token y la extracción de claims se aíslan tras una interfaz (`AuthenticationProvider` / `JwtDecoder` configurable), de modo que en producción se sustituye el emisor propio por el **IdP de Scotiabank vía OIDC** sin cambiar controllers ni lógica de negocio.
- **2FA**: para el mock se simula (`[DATO-REQUERIDO: mecanismo real Scotiabank]`); la interfaz del segundo factor queda declarada para conectarse al mecanismo real después.

**Producción (diferido)**: la autenticación migra a **SSO federado / OIDC** contra el IdP de Scotiabank (decisión a formalizar cuando se resuelva el `[DATO-REQUERIDO]` del IdP y `ADR-ANCE-007` de integración al portal existente). El modelo de roles y autorización se conserva.

## Consecuencias

- **Positivas**:
  - Desbloquea el mock end-to-end sin dependencia del IdP de Scotiabank.
  - El modelo de roles y los flujos de autorización se validan desde el mock (no son deuda).
  - La migración a SSO en producción queda acotada al reemplazo del proveedor de identidad, no de la app.
- **Negativas / trade-offs**:
  - Se construye un auth service que en producción se reemplaza parcialmente.
  - El JWT propio del mock **no** debe llegar a producción — es exclusivo de ambientes DEV/QA/demo.
- **Componentes afectados**: `SPE-ANCE-001` (frontend: login + guard), `SPE-ANCE-002` (Nómina API: Spring Security), `SPE-ANCE-004` (Auth Gateway: emisor JWT propio en mock, OIDC en prod), `SPE-ANCE-005` (tabla de usuarios/roles).
- **Relación con otros ADRs**: para el mock, `ADR-ANCE-007` (integración al portal existente) se resuelve como **standalone con auth propia**; la integración vía SSO se difiere a producción.
