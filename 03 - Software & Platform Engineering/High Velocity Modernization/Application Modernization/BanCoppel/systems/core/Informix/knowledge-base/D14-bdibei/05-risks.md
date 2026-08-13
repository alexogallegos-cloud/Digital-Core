# D14 · Banca Electrónica Institucional (BEI) — Riesgos del Dominio

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Risk Assessment
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- DT-Riesgos (risk register Informix)
- Specialist — Informix SPL Analysis (análisis estático de SPs)
- SRE & AIOps (observabilidad y mitigación operativa)
- Industry Banking (impacto funcional bancario)
- Cybersecurity (riesgos de seguridad y regulatorios)
- Core Banking Transformation (diseño de mitigaciones en target)

> Riesgos marcados como ACTIVOS están en el `migration-risk-register.md` del proyecto.
---

## Resumen ejecutivo

El dominio `bdibei` concentra el **mayor riesgo empresarial de la Wave 3** debido al batch de nómina. Una falla en la dispersión de nómina durante la migración afecta directamente a empleados de empresas clientes de BanCoppel y puede generar reclamaciones masivas ante CONDUSEF. La combinación de alta proporción de SPs aislados (87.5%) y los errores ESB activos (INC-006) hace que este dominio requiera el mayor nivel de diligencia en DISCOVER antes de BUILD.

## Riesgos identificados

### RIESGO-BEI-001 — Batch nómina en quincena activa

| Atributo | Valor |
|----------|-------|
| **Nivel** | N1 — Crítico |
| **Tipo** | Operacional / Reputacional / Regulatorio |
| **Probabilidad** | Alta si no se controla la ventana |
| **Impacto** | Catastrófico — empleados de empresas cliente sin pago |
| **Estado** | ACTIVO |

**Descripción:** Si el cutover del dominio BEI ocurre durante un ciclo de nómina activo (días 1–3 o 15–18 de cada mes), el batch de dispersión puede fallar o ejecutarse parcialmente. Los beneficiarios afectados no reciben su pago. Las empresas clientes generarán reclamaciones masivas ante CONDUSEF.

**Regulación:** CNBV CUB Art. 48 — obligación de ejecutar los pagos recibidos en los plazos pactados. CONDUSEF LPDUSF Art. 50 — reclamaciones en pagos de nómina.

**Mitigación:** ventana de cutover restringida a días 5–13 y 20–28 del mes (ver `20-cutover-plan.md`).

---

### RIESGO-BEI-002 — 294 SPs aislados sin conocimiento documentado

| Atributo | Valor |
|----------|-------|
| **Nivel** | N2 — Alto |
| **Tipo** | Conocimiento / Alcance |
| **Probabilidad** | Certeza — 87.5% del dominio no está en callgraph |
| **Impacto** | Alto — funcionalidades BEI ocultas pueden no migrarse |
| **Estado** | ACTIVO |

**Descripción:** 294 de 336 SPs del dominio bdibei no aparecen en el callgraph de logs de producción del 2026-04-24. Esto puede deberse a: funcionalidad de uso infrecuente, procesos batch ejecutados fuera del período de logs, o SPs deprecados. Sin análisis de estos SPs, el target puede estar incompleto.

**Mitigación:** análisis estático completo de los 294 SPs aislados en Etapa 2. Priorizar SPs con nombres que sugieran: `*nomina*`, `*dispersion*`, `*convenio*`, `*empresa*`.

---

### RIESGO-BEI-003 — Código ESB 4394 en batch de nómina (INC-006)

| Atributo | Valor |
|----------|-------|
| **Nivel** | N1 — Crítico |
| **Tipo** | Técnico / Regulatorio |
| **Probabilidad** | Alta — 2,452 ocurrencias/día en todo el sistema |
| **Impacto** | Catastrófico si afecta el batch de nómina |
| **Estado** | ACTIVO — ver `migration-risk-register.md` P655-R005 |

**Descripción:** El error ESB 4394 (IBM MQ MbUserException) tiene 2,452 ocurrencias diarias en todo el sistema BanCoppel. En un proceso batch como la dispersión de nómina, este error puede dejar una tanda completa sin procesar si el batch no tiene manejo robusto de excepciones y reintentos. A diferencia de transacciones en línea, un fallo de batch de nómina afecta a todos los beneficiarios del lote.

**Escenario de riesgo máximo:** el scheduler lanza el batch de nómina; el primer o segundo intento al ESB falla con 4394; el SP batch no tiene manejo de `ON EXCEPTION` adecuado; todos los registros del lote quedan en `cod_estatus='PE'`; el scheduler no relanza el job; la quincena cierra sin dispersión.

**Mitigación:** (1) verificar el manejo de `ON EXCEPTION` en los SPs batch de nómina, (2) implementar reintentos con backoff exponencial en el target, (3) alerta automática si el batch de nómina no completa en tiempo esperado.

---

### RIESGO-BEI-004 — Dependencia cruzada D08-bdispei sin API definida

| Atributo | Valor |
|----------|-------|
| **Nivel** | N2 — Alto |
| **Tipo** | Arquitectura / Integración |
| **Probabilidad** | Alta — toda dispersión interbancaria requiere SPEI |
| **Impacto** | Alto — pagos interbancarios bloqueados si D08 no está disponible |
| **Estado** | ACTIVO |

**Descripción:** La liquidación de dispersiones a beneficiarios en otros bancos depende de D08-bdispei. Si D08 no se migra en la misma Wave o no expone API en el momento del cutover de BEI, todas las dispersiones interbancarias fallarán.

**Mitigación:** coordinar la Wave 3 de D14-bdibei con el estado de D08-bdispei. Definir contrato API de integración antes del BUILD.

---

### RIESGO-BEI-005 — Algoritmo OTP no criptográfico en producción

| Atributo | Valor |
|----------|-------|
| **Nivel** | N2 — Alto |
| **Tipo** | Seguridad / Regulatorio |
| **Probabilidad** | Certeza — verificado en código `getrandomcode` |
| **Impacto** | Alto — compromiso de autenticación empresa |
| **Estado** | ACTIVO |

**Descripción:** el SP `getrandomcode` implementa un LCG determinístico para generar códigos OTP de autenticación. El algoritmo es predecible con parámetros conocidos y viola PCI-DSS 8.3 y la guía de seguridad CNBV sobre autenticación en banca electrónica.

**Mitigación:** no portar el LCG al target. Reemplazar con `java.security.SecureRandom` o un servicio externo de OTP (TOTP OATH RFC 6238).

---

### RIESGO-BEI-006 — Ventana de rollback restringida en quincena

| Atributo | Valor |
|----------|-------|
| **Nivel** | N2 — Alto |
| **Tipo** | Operacional |
| **Probabilidad** | Media |
| **Impacto** | Alto — rollback durante quincena puede generar doble dispersión o pérdida |
| **Estado** | ACTIVO |

**Descripción:** si el cutover ocurre correctamente fuera de la quincena pero surgen problemas graves justo antes del primer ciclo de nómina post-cutover, el rollback al Informix legacy puede ser complejo si ya se procesaron parcialmente registros en el target.

**Mitigación:** ventana de rollback garantizada hasta D-3 del primer ciclo quincenal post-cutover. Plan de rollback explícito en `20-cutover-plan.md`.

---

### RIESGO-BEI-007 — TESOFE como cliente BEI no confirmado

| Atributo | Valor |
|----------|-------|
| **Nivel** | N3 — Medio |
| **Tipo** | Regulatorio / Alcance |
| **Probabilidad** | Media |
| **Impacto** | Medio — requisitos regulatorios de TESOFE más estrictos que banca comercial |
| **Estado** | PENDIENTE |

**Descripción:** BanCoppel puede tener convenios BEI con dependencias de gobierno que usan TESOFE. Estos pagos tienen restricciones adicionales (SHCP, SAT, comprobación de pago) que deben identificarse antes de BUILD.

**Mitigación:** `[SME-PENDING]` — confirmar con Domain Expert BanCoppel si hay convenios TESOFE activos en bdibei.

---
*Generado por: DT-Riesgos · 2026-08-03 · Fuente: INC-006, sp-specs-bdibei.md, contexto dominio BEI*
