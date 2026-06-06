# Ground Truth — Seams de los 9 Enablers in-scope · openpay-gateway

> Estos 9 `@Service` son los **seams** que la Fase 1 (Enabler Extraction) extrae
> en waves. Se plantaron como hubs nombrados con fan-in objetivo igual al
> `regression_scope` del `fanout-graph.json` del Reference Case. Asi la narrativa
> se cose de punta a punta:
>
>   **Fase 0 (este monolito)** descubre el tangle e identifica estos hubs →
>   **Fase 1 (fanout-graph)** los extrae como enablers en waves 1-4.

| Enabler (clase) | Dominio | Component | Fan-in real | Blast radius objetivo | Wave | PCI | Acceso |
|-----------------|---------|-----------|------------:|----------------------:|:----:|:---:|:------:|
| RbacService | security | Dashboard | 74 | 74 | 4 | — | read |
| ConfigService | infra | Manager | 68 | 68 | 4 | — | read |
| NotificationService | infra | API | 67 | 67 | 3 | — | update |
| UserService | security | Dashboard | 48 | 48 | 3 | — | update |
| VaultService | security | Vault | 38 | 38 | 3 | PCI | read |
| TokenizationService | security | API | 31 | 31 | 3 | PCI | update |
| DocumentService | infra | Dashboard | 28 | 28 | 2 | — | update |
| BinManagerService | infra | API | 24 | 24 | 1 | — | read |
| ApiKeyService | security | API | 22 | 22 | 1 | — | read |

`[COHERENCIA]` El fan-in real es aproximado al objetivo (el top-up procedural lo
ajusta sin romper el cierre de acceso). Las dependencias entre enablers
(UserService->RbacService, TokenizationService->VaultService, ApiKeyService->ConfigService)
reflejan las del fanout. RBAC (read, fan-in mas alto) es el SPOF de seguridad;
ConfigService (read) es el de parametrizacion. Ambos = wave 4 (mayor blast radius).

`[BENCHMARK]` Recuperar estos 9 seams del grafo crudo (sin este answer key) y
ordenarlos por blast radius = el ejercicio central del discovery de Fase 0.
