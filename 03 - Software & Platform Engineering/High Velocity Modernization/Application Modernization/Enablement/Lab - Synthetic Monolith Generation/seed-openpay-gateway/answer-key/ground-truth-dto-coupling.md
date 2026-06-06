# Ground Truth — Acoplamiento por DTO compartido · openpay-gateway

> EL HAIRBALL OCULTO. Este acoplamiento NO esta en el call graph: dos clases que
> nunca se llaman pero comparten un DTO mutable (`TransactionDTO`, `MoneyAmount`)
> estan acopladas por datos. Cambiar la estructura compartida las impacta a todas a
> la vez. En Java es el equivalente exacto del copybook compartido del mainframe.

| DTO | Significado | # clases | # dominios | Dominios |
|-----|-------------|---------:|-----------:|----------|
| `ResponseEnvelope` | Standard API response wrapper (status, payload, errors) — used by every controller and service | 560 | 9 | channels, compliance, finance, infra, merchants, payments, risk-fraud, security, terminals |
| `AuditContext` | Cross-cutting audit/correlation context threaded through call chains | 387 | 9 | channels, compliance, finance, infra, merchants, payments, risk-fraud, security, terminals |
| `TransactionDTO` | GOD DTO carrying full transaction state; mutated across layers — the central coupling object | 298 | 5 | finance, merchants, payments, risk-fraud, terminals |
| `MoneyAmount` | Monetary value object (amount, currency, scale) — shared everywhere money flows | 240 | 4 | compliance, finance, merchants, payments |
| `MerchantDTO` | Merchant master snapshot passed between domains | 208 | 4 | finance, merchants, payments, risk-fraud |
| `AccountingEntry` | Double-entry accounting posting structure — couples finance to payments/compliance | 134 | 3 | compliance, finance, payments |
| `PayResponse` | Outbound response payload of the payments domain | 53 | 1 | payments |
| `PayEntity` | JPA persistence entity of the payments domain | 52 | 1 | payments |
| `PayRequest` | Inbound request payload of the payments domain | 50 | 1 | payments |
| `InfRequest` | Inbound request payload of the infra domain | 48 | 1 | infra |
| `FinResponse` | Outbound response payload of the finance domain | 45 | 1 | finance |
| `FinEntity` | JPA persistence entity of the finance domain | 45 | 1 | finance |
| `FinRequest` | Inbound request payload of the finance domain | 44 | 1 | finance |
| `RskEntity` | JPA persistence entity of the risk-fraud domain | 44 | 1 | risk-fraud |
| `SecRequest` | Inbound request payload of the security domain | 40 | 1 | security |
| `RskRequest` | Inbound request payload of the risk-fraud domain | 34 | 1 | risk-fraud |
| `RskResponse` | Outbound response payload of the risk-fraud domain | 34 | 1 | risk-fraud |
| `TrmRequest` | Inbound request payload of the terminals domain | 34 | 1 | terminals |
| `SecEntity` | JPA persistence entity of the security domain | 34 | 1 | security |
| `InfEntity` | JPA persistence entity of the infra domain | 34 | 1 | infra |
| `SecResponse` | Outbound response payload of the security domain | 33 | 1 | security |
| `InfResponse` | Outbound response payload of the infra domain | 32 | 1 | infra |
| `MerRequest` | Inbound request payload of the merchants domain | 31 | 1 | merchants |
| `CmpEntity` | JPA persistence entity of the compliance domain | 31 | 1 | compliance |
| `MerResponse` | Outbound response payload of the merchants domain | 30 | 1 | merchants |
| `TrmResponse` | Outbound response payload of the terminals domain | 30 | 1 | terminals |
| `TrmEntity` | JPA persistence entity of the terminals domain | 30 | 1 | terminals |
| `MerEntity` | JPA persistence entity of the merchants domain | 28 | 1 | merchants |
| `CmpRequest` | Inbound request payload of the compliance domain | 27 | 1 | compliance |
| `ChnEntity` | JPA persistence entity of the channels domain | 27 | 1 | channels |
| `CmpResponse` | Outbound response payload of the compliance domain | 26 | 1 | compliance |
| `ChnResponse` | Outbound response payload of the channels domain | 23 | 1 | channels |
| `ChnRequest` | Inbound request payload of the channels domain | 22 | 1 | channels |

**DTO de mayor acoplamiento:** `ResponseEnvelope` — Standard API response wrapper (status, payload, errors) — used by every controller and service
(560 clases).

`[BENCHMARK]` El revelador mas duro del seed. Una herramienta que solo analiza el
call graph reportara comunidades limpias y NO vera este acoplamiento transversal.
La verdad: `TransactionDTO` y `AccountingEntry` crean cliques de acoplamiento que
atraviesan dominios -> finanzas queda acoplado a pagos/compliance aunque no haya
llamada directa entre ellos. Este es el motivo nro 1 por el que el Strangler Fig
falla si solo se mira el call graph (y por que database-per-service es tan caro).
