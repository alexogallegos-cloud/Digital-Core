# Frontend — Portal Empresas Nomina · Scotiabank Mexico

> Componente `SPE-ANCE-001` · SPA Angular 20 · TypeScript strict
> Swarm SPE-ANCE-001 · dt-frontend-engineer

App **standalone** (sin NgModules) que digitaliza el ciclo de nomina bancaria
(empleados, nominas, dispersion SPEI, CFDI). En produccion **se embebe en el
Portal Empresa existente** de Scotiabank via Module Federation o iframe con SSO
federado (`ADR-ANCE-007`); en desarrollo corre standalone con auth mock propio
(`ADR-ANCE-004`).

La marca visual es un **placeholder neutro** — el artefacto no incluye logotipo
ni nombre de cliente. Al integrarse, los tokens de `src/styles.scss` se alinean
al design system del portal padre.

---

## Stack

| Aspecto | Detalle |
|---------|---------|
| Framework | Angular 20 · Signals-first · Standalone Components · nuevo control flow (`@if`/`@for`) |
| Lenguaje | TypeScript 5.x (strict + flags adicionales en `tsconfig.json`) |
| HTTP | `HttpClient` con interceptors funcionales (auth Bearer + errores RFC 9457) |
| Estado | Signals / computed / effect — **sin BehaviorSubject** |
| Ruteo | Rutas standalone lazy (`loadComponent`) + guards funcionales |
| Testing | Jest + Testing Library Angular |
| Contrato | OpenAPI 3.1 (`../../api/openapi-nomina-portal.yaml`) — modelos y llamadas coinciden 1:1 |

---

## Como correrla

Prerrequisito: Node 20+ y el **mock API** escuchando en `http://localhost:8080`
(backend `SPE-ANCE-002` o un mock server generado desde el contrato OpenAPI).

```bash
npm install
npm start          # ng serve → http://localhost:4200 (configuracion development)
```

El environment de desarrollo (`src/environments/environment.development.ts`)
apunta la API a `http://localhost:8080/api/v1`. Ajusta ahi el `apiBaseUrl` si el
mock corre en otro puerto.

### Otros comandos

```bash
npm run build      # build de produccion (dist/nomina-portal)
npm test           # Jest (unit + component tests)
npm run test:watch # Jest en watch
```

---

## Estructura

```
src/
├── main.ts                       # bootstrapApplication (standalone)
├── styles.scss                   # tokens neutros + utilidades
├── environments/                 # dev (localhost:8080) · prod (placeholder)
└── app/
    ├── app.config.ts             # providers: HttpClient + interceptors + router
    ├── app.routes.ts             # rutas lazy + guards
    ├── app.component.ts          # root (router-outlet)
    ├── layout/shell.component.ts # navegacion (se sustituye por el portal padre en prod)
    ├── core/
    │   ├── api/                  # modelos (espejo OpenAPI) + servicios tipados
    │   │   ├── models.ts         # Empleado, Nomina, Dispersion, Cfdi, Money=string, ProblemDetails…
    │   │   ├── api.config.ts     # API_BASE_URL token + Idempotency-Key
    │   │   ├── empleado.service.ts
    │   │   ├── nomina.service.ts
    │   │   ├── dispersion.service.ts
    │   │   └── cfdi.service.ts
    │   ├── auth/
    │   │   ├── auth.service.ts    # sesion con Signals · JWT en memoria (PCI)
    │   │   ├── auth.guard.ts      # authGuard + roleGuard(...)
    │   │   ├── auth.interceptor.ts
    │   │   └── role.directive.ts  # *npHasRole
    │   └── interceptors/error.interceptor.ts
    ├── shared/
    │   ├── validators/mexican-validators.ts  # RFC · CURP · CLABE (regex del contrato)
    │   ├── components/            # data-table · file-upload · masked-field · estado-badge · empty-state
    │   └── pipes/money.pipe.ts    # formatea Money sin perder precision (nunca number)
    └── features/                  # standalone, lazy por ruta
        ├── auth/login/            # login + 2FA
        ├── dashboard/             # KPIs por estado (P-INI-01)
        ├── empleados/             # listado + alta individual + carga masiva
        ├── nominas/               # crear · layout · validar · resumen
        ├── dispersiones/          # instruir (2FA) · polling estado · rechazo SPEI
        └── cfdi/                  # consulta / descarga (shell)
```

---

## Decisiones clave

### Money siempre `string`
Todos los montos (`Money`) son `string` decimal (patron `^\d+\.\d{2}$`), nunca
`number`. La precision de punto flotante en banca es incidente P1. `MoneyPipe`
formatea para UI sin convertir a `number`.

### JWT solo en memoria (PCI-DSS · ADR-ANCE-004)
`AuthService` guarda el access token en un signal privado **en memoria** — nunca
en `localStorage`/`sessionStorage`. Un refresh de pagina pierde la sesion a
proposito. En produccion el token lo provee el portal padre por SSO federado.

### Signals-first
El estado de sesion, listados, formularios asincronos y polling de dispersion se
modelan con `signal`/`computed`/`effect`. No se usa `BehaviorSubject` para estado
que un signal resuelve (anti-patron del rol).

### Contract-first
`core/api/models.ts` es el espejo TypeScript del contrato OpenAPI 3.1. Los
`operationId` y paths (`/api/v1/...`) de los servicios coinciden con el contrato.
No editar los modelos sin actualizar el contrato (autoridad: dt-solution-architect).

### Roles
`ADMIN_EMPRESA` · `OPERADOR_NOMINA` · `AUDITOR` · `ADMIN_SCO`. Se refuerzan en
ruta (`roleGuard`) y en UI (`*npHasRole`). La autorizacion real la impone el
backend (`@PreAuthorize`) — el control de cliente es solo UX.

---

## Tests incluidos

| Test | Caso |
|------|------|
| `features/empleados/empleado-form.component.spec.ts` | **TC-EMP-002** — RFC invalido muestra error en el alta (Testing Library) |
| `shared/validators/mexican-validators.spec.ts` | RFC · CURP · CLABE (DV Banxico) · Money |

---

## Pendientes / notas de integracion

- El shell de navegacion (`layout/shell.component.ts`) es solo para el mock; en
  prod lo sustituye el chrome del Portal Empresa (`ADR-ANCE-007`).
- El dashboard deriva KPIs agregando el listado de empleados; en prod hay
  endpoint `/dashboard` dedicado (spec §8) aun no incluido en el contrato de la
  ruta critica.
- 2FA en dispersion reutiliza el challenge de sesion (mock); en prod se solicita
  un challenge fresco por operacion critica.
- OTel Browser SDK (observabilidad, spec §17) se agrega en fase de instrumentacion.
