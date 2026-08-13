# D14 · Banca Electrónica Institucional (BEI) — Estrategia de Pruebas

> **Componente:** Informix · SPE-AM-001 · TEST Phase
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- QA Lead — Equivalencia Funcional (golden master, parallel-run, criterios go/no-go)
- Specialist — Informix SPL Analysis (dataset de regresión histórico)
- Domain Expert — BanCoppel (validación funcional BEI)
- SRE & AIOps (pruebas de observabilidad y runbooks)
- Cybersecurity (pruebas de seguridad — PII, autenticación empresa)
- Industry Banking (criterios de aceptación CNBV)

> `[SME-PENDING]` = requiere sesión de validación antes de BUILD.
---

## Principios de la estrategia de pruebas BEI

1. **Nómina primero:** toda decisión de go/no-go para TEST del dominio BEI debe verificar el batch de nómina. Es el proceso de mayor criticidad y no admite equivalencia parcial.
2. **Equivalencia financiera exacta:** los montos de dispersión deben ser bit-a-bit idénticos entre Informix y PostgreSQL (tipo `MONEY` → `NUMERIC(18,2)`). Ninguna diferencia de redondeo es aceptable.
3. **Prueba de resiliencia ESB:** los 5 códigos de error INC-006 deben probarse explícitamente contra el target para verificar los circuit breakers y reintentos.
4. **Parallel-run en ventana segura:** el parallel-run debe ejecutarse incluyendo al menos un ciclo de nómina completo (quincenal) sin incidentes antes de autorizar el cutover.

---

## Pirámide de pruebas BEI

```
                     ┌─────────────┐
                     │  E2E / UAT  │  ← Ciclo completo nómina + SPEI en STG
                    ┌┴─────────────┴┐
                    │  Integration  │  ← BEI ↔ D08/D03/D05/D12 + ESB mocks
                   ┌┴───────────────┴┐
                   │    Contract     │  ← Pact consumer/provider por cada cross-dep
                  ┌┴─────────────────┴┐
                  │    Unit Tests     │  ← Cada regla de negocio (límites, comisiones)
                 ┌┴───────────────────┴┐
                 │  Golden Master      │  ← Equivalencia Informix vs target por SP
                └───────────────────────┘
```

---

## Tipos de prueba y cobertura objetivo

### TEST-BEI-01 — Golden Master (Equivalencia Funcional)

| Atributo | Valor |
|----------|-------|
| Objetivo | Verificar que cada SP del dominio BEI produce outputs idénticos en Informix y en el target |
| Umbral de aceptación | ≥ 99.95% de outputs idénticos bit-a-bit (0.05% máximo de diferencias documentadas como CR) |
| Dataset | Histórico de dispersiones últimos 3 meses + casos de borde (monto máximo, CLABE inválida, etc.) |
| Herramienta | Comparator tool Informix (golden master framework) |
| Responsable | QA Lead — Equivalencia Funcional |

**Casos obligatorios para batch de nómina:**
- Dispersión exitosa con 100 beneficiarios → todos acreditados.
- Dispersión con beneficiario CLABE inválida → rechazo del registro, continuación del lote.
- Dispersión con convenio bloqueado → rechazo total del lote.
- Dispersión que excede límite del convenio → rechazo con código correcto.
- Error ESB 4394 durante dispersión → retry x3 → checkpoint + alerta.

### TEST-BEI-02 — Pruebas de Unidad

| Atributo | Valor |
|----------|-------|
| Cobertura objetivo | ≥ 80% en microservicios críticos (DispersionService, BatchNominaService) · ≥ 70% global |
| Herramienta | JUnit 5 + Mockito |
| Casos críticos | Validación de CLABE (dígito verificador) · cálculo de comisiones · límite de dispersión |

### TEST-BEI-03 — Pruebas de Integración (Contract Tests)

| Atributo | Valor |
|----------|-------|
| Objetivo | Verificar que BEI respeta el contrato API de cada dominio dependiente |
| Herramienta | Pact (consumer-driven contracts) |
| Contratos a definir | BEI ↔ D08-bdispei · BEI ↔ D03-bdicred · BEI ↔ D05-bdisac · BEI ↔ D12-bdicont |
| Responsable | Core Banking Transformation + Software Engineering SME |

### TEST-BEI-04 — Prueba de Resiliencia ESB (INC-006)

| Atributo | Valor |
|----------|-------|
| Objetivo | Verificar que los 5 códigos ESB son manejados correctamente por el microservicio BEI |
| Metodología | Chaos injection: simular cada código ESB durante el procesamiento de un lote de nómina |
| Criterio de éxito | Ningún lote queda en estado inconsistente; alertas disparan correctamente |
| Casos obligatorios | Error 4394 durante batch nómina → checkpoint + retry + alerta P1 · Error 3743 (timeout) → circuit breaker · Error 3165 (SSL) → alerta inmediata + no retry |

### TEST-BEI-05 — Prueba de Performance (Carga)

| Atributo | Valor |
|----------|-------|
| Objetivo | Verificar que el microservicio BEI procesa el volumen de nómina quincenal en el tiempo esperado |
| Herramienta | k6 o JMeter |
| Dataset de carga | `[SME-PENDING]` — número real de beneficiarios de nómina BEI |
| SLO a verificar | Batch de nómina completa en ≤ tiempo esperado (2× ventana histórica de Informix) |

### TEST-BEI-06 — Parallel-Run (Producción Shadow)

| Atributo | Valor |
|----------|-------|
| Duración mínima | **Al menos un ciclo quincenal completo** (15 días), incluyendo al menos una ejecución exitosa del batch de nómina |
| Metodología | Legacy Informix procesa las dispersiones en PROD; BEI target procesa en shadow; comparator verifica outputs |
| Umbral de divergencia | < 0.05% de transacciones con diferencia |
| Gate de go/no-go | QA Lead — Equivalencia Funcional (soberano — no se puede puentear) |

**Prerequisito crítico:** el parallel-run debe incluir al menos un ciclo de nómina exitoso en el target antes de autorizar el cutover. Si el parallel-run inicia a mediados de período, debe extenderse hasta el siguiente ciclo quincenal completo.

### TEST-BEI-07 — Pruebas de Seguridad

| Tipo | Objetivo | Herramienta | Gate |
|------|----------|-------------|------|
| SAST | Cero vulnerabilidades High/Critical en código BEI | SonarQube + Semgrep | CI — bloqueante |
| SCA | Sin CVEs High/Critical en dependencias | Snyk + Dependabot | CI — bloqueante |
| Secrets scan | Sin credenciales en código | gitleaks | CI — bloqueante |
| OTP security | Verificar que `getrandomcode` fue reemplazado por SecureRandom | Revisión manual | Gate BUILD |
| PII encryption | Datos de beneficiarios encriptados en tránsito y reposo | Penetration test | TEST |
| Auth empresa | Autenticación empresa cumple PCI-DSS 8.3 | Security review | TEST |

### TEST-BEI-08 — UAT (User Acceptance Testing)

| Atributo | Valor |
|----------|-------|
| Responsables de firmar | Domain Expert BanCoppel + operaciones BEI + área de empresas clientes piloto |
| Casos obligatorios | Ciclo completo de nómina de empresa piloto · alta de convenio empresa · reverso de dispersión |
| Criterio de aceptación | 100% de los casos críticos de nómina pasando · cero discrepancias financieras |

---

## Dataset de regresión

El dataset de regresión debe incluir:

| Categoría | # de casos | Fuente |
|-----------|-----------|--------|
| Dispersiones históricas exitosas | `[SME-PENDING]` — mínimo 3 ciclos quincenales | Informix producción |
| Dispersiones con error ESB histórico | `[SME-PENDING]` | Logs producción + INC-006 |
| Convenios con límite de dispersión exacto | `[SME-PENDING]` | Catálogo convenios BEI |
| Beneficiarios con CLABE inválida | `[SME-PENDING]` | Casos históricos de rechazo |
| Dispersiones interbancarias (SPEI) | `[SME-PENDING]` | Incluir todos los bancos del catálogo SPEI |
| Dispersiones en cuentas BanCoppel propias | `[SME-PENDING]` | Acreditación directa sin SPEI |

---

## Definition of Done — TEST para D14-bdibei

- [ ] Golden master verde ≥ 99.95% sobre dataset de regresión histórico (incluyendo batch nómina).
- [ ] Todos los casos de error ESB (INC-006) tienen comportamiento correcto verificado.
- [ ] Parallel-run ≥ 1 ciclo quincenal sin divergencia bloqueante.
- [ ] Performance: batch de nómina completa en ≤ tiempo objetivo.
- [ ] Security gates: SAST + SCA + secrets + OTP reemplazado + PII encryption verdes.
- [ ] UAT firmado por Domain Expert BanCoppel + operaciones BEI.
- [ ] Contract tests BEI ↔ D08/D03/D05/D12 pasando.
- [ ] QA Lead — Equivalencia Funcional ha firmado go/no-go.

---
*Generado por: QA Lead — Equivalencia Funcional + Specialist — Informix SPL Analysis · 2026-08-03*
