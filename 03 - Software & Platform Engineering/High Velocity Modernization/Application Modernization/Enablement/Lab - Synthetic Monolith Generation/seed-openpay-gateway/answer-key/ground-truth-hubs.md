# Ground Truth — Hubs (fan-in alto) · openpay-gateway

> Los hubs son el corazon del hairball: utilerias estaticas y los 9 enablers,
> llamados por decenas/cientos de clases. El discovery debe identificarlos como
> nodos de maximo riesgo de migracion (tocarlos impacta a todo el sistema).

| # | Clase | Capa | Dominio | Component | Fan-in |
|---|-------|------|---------|-----------|--------|
| 1 | JsonUtils | UTIL | shared | shared | 493 |
| 2 | StringUtils | UTIL | shared | shared | 277 |
| 3 | JdbcWriteGateway | UTIL | shared | shared | 239 |
| 4 | JdbcReadGateway | UTIL | shared | shared | 160 |
| 5 | RbacService | SERVICE | security | Dashboard | 74 |
| 6 | ConfigService | SERVICE | infra | Manager | 68 |
| 7 | NotificationService | SERVICE | infra | API | 67 |
| 8 | UserService | SERVICE | security | Dashboard | 48 |
| 9 | VaultService | SERVICE | security | Vault | 38 |
| 10 | ValidationUtils | UTIL | shared | shared | 32 |
| 11 | TokenizationService | SERVICE | security | API | 31 |
| 12 | DocumentService | SERVICE | infra | Dashboard | 28 |
| 13 | BinManagerService | SERVICE | infra | API | 24 |
| 14 | ChnRepository040 | REPO | channels | Dashboard | 23 |
| 15 | ApiKeyService | SERVICE | security | API | 22 |
| 16 | MoneyUtils | UTIL | shared | shared | 18 |
| 17 | SecRepository050 | REPO | security | API | 15 |
| 18 | InfService028 | SERVICE | infra | Manager | 14 |
| 19 | SecRepository023 | REPO | security | API | 14 |
| 20 | InfService006 | SERVICE | infra | Manager | 13 |

`[BENCHMARK]` Los hubs UTIL (MoneyUtils, JsonUtils, AuditLogger, los sinks JDBC) y
los 9 SERVICE enabler deben aparecer en el top. Quien no los detecte subestimara
el blast radius de cualquier cambio.
