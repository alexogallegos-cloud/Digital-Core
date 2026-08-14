# Ground Truth — Mapa de Dominios · SISTEMA-POLIZAS-AUTO

## Bounded contexts plantados

### policy-issuance (dominio principal)
- **Programas:** POLVAL, PRIMCALC, RIESGOEV, POLALT
- **Files:** POLMAST, TARIFA, POLACT (LF)
- **Reglas:** RN-101 a RN-106, RN-108
- **Microservicio propuesto:** `policy-issuance-service`
  - Commands: ValidatePolicy, IssuePolicy
  - Queries: CalculatePremium, GetRiskFactor
  - Events: PolicyIssued, PolicyRejected

### customer-data (soporte)
- **Files:** CLIMAST
- **Acceso:** read-only desde policy-issuance
- **Microservicio:** `customer-service` (probablemente externo)

### claims-reporting
- **Programas:** RPTSIN
- **Files:** SINIEST
- **Reglas:** RN-107
- **Microservicio:** `claims-reporting-service`

### integración externa
- **RIESGOEV → SCOREXT** (scoring de riesgo) — ACL candidate; llamada dinámica.

## Wave plan implícito
| Wave | Dominio | Estrategia | Notas |
|------|---------|------------|-------|
| Wave 0 | API Gateway + Landing Zone | Foundation | — |
| Wave 1 | customer-data | Rearchitect | CLIMAST → RDBMS |
| Wave 2 | policy-issuance | Rearchitect | núcleo; ACL al scoring; **migrar lógica del LF POLACT a código** |
| Wave 3 | claims-reporting | Replatform | RPTSIN → batch moderno; **desenredar indicadores** |
| — | OLDPRIM | **Retire** | dead code |
| — | BCKPOL | Investigar | shadow inventory: localizar fuente |