# ADR-ANCE-007: Integración al Portal Empresa Existente — Modelo de Embedding y SSO Federado
Fecha: 2026-08-04
Estado: PARTIALLY ACCEPTED — premisa de trabajo aprobada · prod `[PENDIENTE DATO-REQUERIDO: IdP Scotiabank · mecanismo embedding portal padre]`
Owner: dt-solution-architect
SME consultado: `[PENDIENTE: IAM & PAM · Cybersecurity CISO — pendiente para validar token exchange en producción]`
Relacionado con: `ADR-ANCE-004` (IAM propio mock) · `ADR-ANCE-001` (integración core bancario)

---

## Contexto

El Portal Empresas Nómina es una app **standalone** (stack propio: Angular 20 + Java 21 + SQL Server 2022) que en producción se servirá **dentro del Portal Empresa existente de Scotiabank México** — el portal que ya gestiona cuentas de empleados, centros de trabajo y otros módulos corporativos.

La integración tiene dos dimensiones que deben resolverse de forma consistente:

1. **Embedding UI**: cómo el Portal Empresa padre "monta" o enlaza el Portal Nómina en su shell de navegación (micro-frontend federation, iframe, deep link, o menú externo).
2. **SSO / Federación de identidad**: cómo el Portal Nómina recibe la identidad del usuario ya autenticado en el portal padre, sin presentar una segunda pantalla de login.

En la fase mock el portal funciona como standalone con IAM propio (`ADR-ANCE-004`). Esta decisión cubre la **premisa de producción** — el modelo de integración asumido para guiar el diseño de la capa de auth, la abstracción del proveedor de identidad, y los contratos de integración con el portal padre.

### Datos conocidos
- El portal padre ya existe y tiene usuarios autenticados con sesión activa.
- Scotiabank México utiliza infraestructura de banca digital enterprise — alta probabilidad de que el portal padre use un IdP corporativo (Okta, Azure AD / Entra ID, Ping Identity, o IdP propio) con soporte OIDC y/o SAML 2.0.
- El diseño de `ADR-ANCE-004` ya dejó un `AuthenticationProvider` / `JwtDecoder` configurable para habilitar OIDC sin rearquitectura.

### Datos requeridos (no disponibles aún)
- `[DATO-REQUERIDO]` IdP corporativo Scotiabank México y versión del protocolo (OIDC · SAML 2.0 · custom).
- `[DATO-REQUERIDO]` Stack del portal padre y mecanismo de embedding (Module Federation · Nx · iframe · deep link · menú externo con cookie compartida).
- `[DATO-REQUERIDO]` Claims del token emitido por el IdP (email, roles, tenant/empresa, centroTrabajo).
- `[DATO-REQUERIDO]` Dominio de cookie de sesión del portal padre (para compartir token o lanzar silent refresh).

---

## Opciones Evaluadas

### Opción A — Micro-frontend Federation (Module Federation / Native Federation Angular 20)
El portal padre monta el Portal Nómina como un **remote module** a través de Webpack Module Federation (o el equivalente nativo de Angular 20). El shell padre ya tiene el token OIDC y lo inyecta al bundle remoto vía shared state o `APP_INITIALIZER`.

- **Ventajas**: integración UI profunda (navegación unificada, shared design system, sin borde de iframe); el token se comparte en memoria sin round-trip extra.
- **Desventajas**: requiere que el portal padre esté en Angular (u ofrezca el shell de federation), lo cual es `[DATO-REQUERIDO]`; build coordination entre equipos; rompe el standalone deployment del Portal Nómina para demos/QA.
- **Prerequisito bloqueante**: conocer stack frontend del portal padre.

### Opción B — iframe con postMessage para token exchange
El portal padre incrusta el Portal Nómina en un `<iframe>` y le envía el token OIDC vía `window.postMessage` con `targetOrigin` restringido.

- **Ventajas**: cero dependencia de stack entre portales; el Portal Nómina sigue siendo standalone; viable con cualquier tecnología del portal padre.
- **Desventajas**: limitaciones de UX (scroll, responsive, deep links); política CSP y X-Frame-Options requieren configuración explícita; `postMessage` debe ser asegurado con validación de origen estricta (riesgo XSS si mal configurado); Google y Apple restringen cookies de terceros en iframe (SameSite=None + Secure + negociación CORS).
- **Prerequisito bloqueante**: definir CSP y X-Frame-Options permitidos por el portal padre.

### Opción C — Deep Link + SSO redirect (OIDC Authorization Code Flow con token pasado vía redirect)
El portal padre redirige al usuario al Portal Nómina enviando el token de sesión como `id_token_hint` o vía cookie de sesión compartida en el mismo dominio (`*.scotiabank.com.mx`). El Portal Nómina valida el token contra el mismo IdP (token introspection / JWKS endpoint).

- **Ventajas**: modelo estándar OAuth2/OIDC; el Portal Nómina actúa como Relying Party del mismo IdP; el backend Java puede validar el JWT directamente con el JWKS público del IdP sin intermediario.
- **Desventajas**: requiere que ambos portales sean clientes registrados del mismo IdP; la URL del Portal Nómina cambia (el usuario "sale" del portal padre momentáneamente).
- **Prerequisito bloqueante**: IdP corporativo Scotiabank con OIDC Discovery document o JWKS endpoint accesible desde el backend del Portal Nómina.

### Opción D — Token Proxy / BFF pass-through (sesión del portal padre vía cookie httpOnly compartida)
El portal padre y el Portal Nómina comparten el mismo dominio raíz. La cookie de sesión httpOnly emitida por el portal padre es válida para el Portal Nómina. El backend del Portal Nómina valida la cookie contra el servicio de sesiones del portal padre (API interna).

- **Ventajas**: transparente para el usuario; no hay redirect ni postMessage.
- **Desventajas**: acoplamiento al servicio de sesiones del portal padre (dependency en tiempo de ejecución); cualquier cambio en la API de sesiones del portal padre rompe el Portal Nómina; modelo más difícil de probar en QA.
- **Prerequisito bloqueante**: acceso al endpoint de validación de sesiones del portal padre.

---

## Decisión

### Premisa de Trabajo (BUILD — en vigor hasta resolver DATOs REQUERIDOS)

Adoptamos la **Opción C como premisa arquitectónica de producción**: el Portal Nómina operará como **Relying Party OIDC** del IdP corporativo de Scotiabank, con el usuario llegando vía deep link desde el portal padre. El backend Java valida el JWT recibido directamente contra el JWKS endpoint del IdP.

Esta premisa es la que **mayor probabilidad tiene de sobrevivir** dado que:
- OIDC Authorization Code Flow es el estándar de la industria bancaria.
- La abstracción `JwtDecoder` de Spring Security ya existe (`ADR-ANCE-004`) y solo requiere cambiar la fuente del JWKS (de clave local a URL del IdP).
- No requiere conocer el stack del portal padre (compatible con cualquier tecnología).
- Es auditable para CNBV (el token tiene claims trazables) y alineado con PCI-DSS (no hay tokens en memoria del browser sin control).

### Consecuencia de la premisa en el código actual

El código del mock (`AuthService.java`, `SecurityConfig.java`, `JwtIssuer.java`) está diseñado para que en producción:

1. `JwtDecoder` se configure con la URL de JWKS del IdP de Scotiabank vía `application.yml`:
   ```yaml
   spring:
     security:
       oauth2:
         resourceserver:
           jwt:
             jwk-set-uri: https://idp.scotiabank.com.mx/.well-known/jwks.json
   ```
2. Los claims de roles (`roles`, `empresa`, `centroTrabajo`) que hoy vienen de la tabla de usuarios en SQL Server, en producción vendrán del JWT emitido por el IdP. El mapeo de claims se centraliza en `JwtAuthConverter` (a crear en fase de prod).
3. La pantalla de login de Angular desaparece — el guard redirige directamente al IdP si no hay token válido.

### Embedding UI — premisa secundaria

Mientras no se confirme el stack del portal padre, asumimos **Opción B (iframe + postMessage) como fallback de embedding**, dado que es la que menos dependencias tiene del portal padre. Si el portal padre es Angular y soporta Module Federation, se promoverá a Opción A con un ADR suplementario.

Para el mock y los demos: el Portal Nómina se sirve standalone (sin iframe) — eso no cambia.

---

## Consecuencias

**Positivas:**
- El diseño existente de `ADR-ANCE-004` es 100% compatible con esta premisa — no hay deuda de rearquitectura.
- BUILD puede continuar sin bloqueo: todos los flujos de autorización (`@PreAuthorize`, guards Angular) se construyen contra el modelo de roles unificado, que es el mismo en mock y producción.
- El contrato de claims del token (`idEmpresa`, `roles`, `centroTrabajo`) queda documentado aquí — cuando llegue el IdP real, la validación es contra este contrato.

**Negativas / trade-offs:**
- Si Scotiabank usa SAML 2.0 (no OIDC), esta premisa debe revisarse — Spring Security soporta SAML pero requiere configuración distinta.
- Si el portal padre no permite deep link y fuerza iframe, la premisa de embedding cambia pero la premisa de SSO (Opción C) se mantiene — el token llega vía postMessage en lugar de redirect.

**Componentes afectados:**
- `SPE-ANCE-004` (Auth Gateway / JwtDecoder): punto de cambio principal en prod.
- `SPE-ANCE-001` (frontend Angular): login guard se convierte en redirect OIDC; login component se retira.
- `SPE-ANCE-002` (Nómina API): `SecurityConfig` solo cambia el `JwtDecoder` bean.

**DATOs REQUERIDOS que desbloquean la versión FINAL de este ADR:**
- IdP corporativo Scotiabank + protocolo (OIDC · SAML 2.0 · custom).
- JWKS endpoint o metadata URL del IdP.
- Claims del JWT de producción (nombres de claim para empresa, roles, centros de trabajo).
- Stack del portal padre (desbloquea embedding definitivo).
- Política CSP y dominio de cookie (desbloquea embedding vía iframe si aplica).
