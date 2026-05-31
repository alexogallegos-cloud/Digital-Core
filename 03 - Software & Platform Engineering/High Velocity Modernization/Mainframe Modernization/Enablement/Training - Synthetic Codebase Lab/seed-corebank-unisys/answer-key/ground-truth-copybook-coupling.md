# Ground Truth — Acoplamiento por Copybook · SISTEMA-CORE-UNISYS

> EL HAIRBALL OCULTO. Este acoplamiento NO está en el call graph: dos programas que
> nunca se llaman pero comparten un copybook están acoplados por datos. Cambiar la
> estructura compartida los impacta a todos a la vez.
> Nombres con convención de librería realista (`CB-*` = compartidos de Core Banking;
> `{DOMINIO}-*` = propios del dominio) y significado explícito.

| Copybook | Significado | # programas | # dominios | Dominios |
|----------|-------------|------------:|-----------:|----------|
| `CB-RETCODE` | Standard return code shared across programs | 725 | 8 | cards, channels, customer, deposits, gl, loans, payments, reporting |
| `CB-ENCABEZADO` | Standard record header (common layout) | 681 | 8 | cards, channels, customer, deposits, gl, loans, payments, reporting |
| `CB-IMPORTE` | Standard monetary amount (amount, currency, sign) | 404 | 5 | cards, deposits, gl, loans, payments |
| `CB-CLIENTE` | Customer master data | 340 | 5 | cards, customer, deposits, loans, payments |
| `CB-CUENTA` | Bank account master | 239 | 3 | deposits, gl, loans |
| `CB-ASIENTO` | Accounting entry — posting to the General Ledger | 227 | 4 | deposits, gl, loans, payments |
| `DEP-AUXILIAR` | Auxiliary working structure of the deposits domain | 69 | 1 | deposits |
| `DEP-PARAMETRO` | Configuration parameters of the deposits domain | 61 | 1 | deposits |
| `RPT-PARAMETRO` | Configuration parameters of the reporting domain | 56 | 1 | reporting |
| `CHN-CATALOGO` | Reference catalog/table of the channels domain | 55 | 1 | channels |
| `CHN-AUXILIAR` | Auxiliary working structure of the channels domain | 55 | 1 | channels |
| `PAY-PARAMETRO` | Configuration parameters of the payments domain | 53 | 1 | payments |
| `GL-CATALOGO` | Reference catalog/table of the GL (accounting) domain | 52 | 1 | gl |
| `CHN-PARAMETRO` | Configuration parameters of the channels domain | 52 | 1 | channels |
| `LON-PARAMETRO` | Configuration parameters of the loans domain | 51 | 1 | loans |
| `LON-CATALOGO` | Reference catalog/table of the loans domain | 51 | 1 | loans |
| `LON-AUXILIAR` | Auxiliary working structure of the loans domain | 51 | 1 | loans |
| `RPT-CATALOGO` | Reference catalog/table of the reporting domain | 51 | 1 | reporting |
| `GL-PARAMETRO` | Configuration parameters of the GL (accounting) domain | 50 | 1 | gl |
| `RPT-AUXILIAR` | Auxiliary working structure of the reporting domain | 49 | 1 | reporting |
| `CRD-AUXILIAR` | Auxiliary working structure of the cards domain | 48 | 1 | cards |
| `GL-AUXILIAR` | Auxiliary working structure of the GL (accounting) domain | 48 | 1 | gl |
| `CUS-PARAMETRO` | Configuration parameters of the customer domain | 48 | 1 | customer |
| `CUS-AUXILIAR` | Auxiliary working structure of the customer domain | 48 | 1 | customer |
| `DEP-CATALOGO` | Reference catalog/table of the deposits domain | 47 | 1 | deposits |
| `PAY-CATALOGO` | Reference catalog/table of the payments domain | 47 | 1 | payments |
| `PAY-AUXILIAR` | Auxiliary working structure of the payments domain | 45 | 1 | payments |
| `CRD-CATALOGO` | Reference catalog/table of the cards domain | 40 | 1 | cards |
| `CUS-CATALOGO` | Reference catalog/table of the customer domain | 40 | 1 | customer |
| `CRD-PARAMETRO` | Configuration parameters of the cards domain | 37 | 1 | cards |

**Copybook de mayor acoplamiento:** `CB-RETCODE` — Standard return code shared across programs
(725 programas).

`[BENCHMARK]` El revelador más duro del seed. Una herramienta que sólo analiza el
call graph reportará comunidades limpias y NO verá este acoplamiento transversal.
La verdad: `CB-RETCODE` y los compartidos (`CB-CUENTA`/`CB-ASIENTO`) crean cliques de
acoplamiento que atraviesan dominios → el GL queda acoplado a depósitos/créditos/pagos
aunque no haya CALL entre ellos. Este es el motivo nº1 por el que el Strangler Fig
falla si sólo se mira el call graph.
