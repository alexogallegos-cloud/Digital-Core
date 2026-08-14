# Ground Truth — Mapa de Dominios · SISTEMA-CREDITO-LATAM

> Espeja el "Mapa de Dominios" + "Wave Plan" (Etapa 4) del Specialist - Reverse Engineering.

## Bounded contexts plantados

### credit-origination (dominio principal)
- **Programas:** CREDVAL, LIMCHK, SCOVAL, CREDALT
- **Copybooks:** CREDCPY, LIMCPY
- **Tablas:** CREDITOS, LIMITES_CREDITO
- **Reglas:** RN-001 a RN-006, RN-008
- **Microservicio propuesto:** `credit-origination-service`
  - Commands: ValidateCredit, RegisterCredit
  - Queries: GetAvailableLimit
  - Events: CreditApproved, CreditRejected, CreditPending

### customer-data (dominio de soporte)
- **Tablas:** CLIENTES
- **Acceso:** consultado por credit-origination (read-only en este subset)
- **Microservicio propuesto:** `customer-service` (probablemente externo a este subsistema)

### reporting
- **Programas:** RPTGEN
- **Reglas:** RN-007
- **Microservicio propuesto:** `credit-reporting-service`

### integración externa
- **SCOVAL → BUROEXT1** (buró de crédito) — Anti-Corruption Layer candidate; llamada dinámica.

## Wave plan implícito
| Wave | Dominio | Estrategia | Notas |
|------|---------|------------|-------|
| Wave 0 | API Gateway + Landing Zone | Foundation | — |
| Wave 1 | customer-data | Rearchitect | base de datos cliente |
| Wave 2 | credit-origination | Rearchitect | núcleo; integrar buró vía ACL |
| Wave 3 | reporting | Replatform | RPTGEN → batch moderno |
| — | OLDVAL | **Retire** | dead code: descomisionar |
| — | BCKPUTI | Investigar | shadow inventory: localizar fuente antes de migrar |