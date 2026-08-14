# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Dependencias Externas

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Resumen de dependencias externas

`bdilide` tiene el mayor número de dependencias externas obligatorias de todo Informix. Todas son de naturaleza regulatoria — el sistema debe seguir comunicándose con los mismos reguladores y sistemas externos después de la migración, usando los mismos formatos y protocolos.

| Sistema externo | Tipo | Protocolo | Regulatorio | Criticidad |
|----------------|------|-----------|:-----------:|:----------:|
| Buró de Crédito | Consulta crediticia | CHI (protocolo propio) | Sí — CNBV | 🔴 CRÍTICO |
| SAT (Servicio de Administración Tributaria) | Intercambio de archivos | Archivo estructurado batch | Sí — SAT/LIDE | 🔴 CRÍTICO |
| CNBV / UIF (Unidad de Inteligencia Financiera) | Envío de reportes PLD | Archivo estructurado CNBV | Sí — LFPIORPI | 🔴 CRÍTICO |
| SHCP (Secretaría de Hacienda) | Reportes de operaciones relevantes | Archivo estructurado SHCP | Sí — LFPIORPI | 🔴 CRÍTICO |
| OFAC (Office of Foreign Assets Control) | Actualización de lista negra | `[DATO-REQUERIDO]` | Sí — compliance | 🟠 ALTO |
| ONU / INTERPOL | Actualización de lista negra | `[DATO-REQUERIDO]` | Sí — FATF/GAFI | 🟠 ALTO |

## DEX-D15-01: Buró de Crédito

| Atributo | Valor |
|----------|-------|
| Nombre oficial | Buró de Crédito (Sociedad de Información Crediticia) |
| Tipo de integración | Consulta de historial crediticio del cliente |
| Protocolo | CHI (Consulta de Historial de Información) — `[DATO-REQUERIDO]` confirmar versión |
| Evidencia en código | `borramovs_movefechis` — tokens `chi` en nombre del SP |
| Dirección | bdilide → Buró (consulta saliente) |
| SLA | `[DATO-REQUERIDO]` — confirmar tiempo máximo de respuesta |
| Impacto si no disponible | Onboarding de clientes puede quedar bloqueado |
| Credenciales | `[DATO-REQUERIDO]` — secretos en AWS Secrets Manager |
| Certificados TLS | `[DATO-REQUERIDO]` — renovación y gestión en el target |

**Consideración para el target:** la integración con Buró de Crédito debe migrarse como llamada de API desde el microservicio, no como comando shell o librería nativa de Informix. Confirmar si Buró de Crédito ofrece API REST o solo SOAP/XML.

## DEX-D15-02: SAT — Intercambio IDE/Exentos

| Atributo | Valor |
|----------|-------|
| Nombre oficial | Servicio de Administración Tributaria |
| Tipo de integración | Intercambio de archivos de consulta y resultado |
| Protocolo | Archivo estructurado (formato SAT) — generado/procesado vía shell en AIX |
| SPs involucrados | `sp_cargainformesat`, `sp_cargaresultadosat`, `sp_actualizainformesat`, `sp_actualizaresultadosat` |
| Dirección | Bidireccional — BanCoppel envía consulta, SAT responde con resultado |
| Frecuencia | Mensual (o bajo demanda) |
| Formato | `[DATO-REQUERIDO]` — solicitar el layout oficial SAT vigente |
| Plazo regulatorio | `[DATO-REQUERIDO]` — confirmar plazo de entrega con área de Cumplimiento |
| Impacto si falla | Incumplimiento regulatorio SAT — posible sanción |

**Riesgo de migración CRÍTICO:** los SPs actuales usan comandos shell AIX (`sed`, `rm -rf`) para construir el archivo. En el target AWS, este proceso debe reimplementarse como lógica Java/Python que genera el mismo formato de archivo. El archivo resultante debe ser byte-a-byte idéntico al generado por el sistema legacy.

## DEX-D15-03: CNBV / UIF — Reportes PLD

| Atributo | Valor |
|----------|-------|
| Nombre oficial | Comisión Nacional Bancaria y de Valores / Unidad de Inteligencia Financiera |
| Tipo de integración | Envío periódico de reportes de operaciones |
| SPs involucrados | `[DATO-REQUERIDO]` — identificar en los 96 SPs aislados |
| Tipos de reporte | Operaciones inusuales, operaciones preocupantes |
| Frecuencia | Mensual para operaciones relevantes; inmediato para inusuales |
| Canal de envío | `[DATO-REQUERIDO]` — ¿Portal CNBV? ¿SFTP? ¿API? |
| Formato | Layout CNBV vigente — `[DATO-REQUERIDO]` confirmar versión |
| Plazo regulatorio | 20 días hábiles después del período para relevantes; 2 días para inusuales |
| Impacto si falla | Sanción CUB + LFPIORPI — desde multa hasta suspensión de operaciones |

## DEX-D15-04: SHCP — Operaciones Relevantes

| Atributo | Valor |
|----------|-------|
| Nombre oficial | Secretaría de Hacienda y Crédito Público |
| Tipo de integración | Reporte mensual de operaciones en efectivo > $7,500 USD |
| SPs involucrados | `[DATO-REQUERIDO]` — identificar en los 96 SPs aislados |
| Umbral | $7,500 USD o equivalente en MXN (tipo de cambio de referencia Banxico) |
| Frecuencia | Mensual — día 17 del mes siguiente al período |
| Canal | `[DATO-REQUERIDO]` — Portal SHCP o sistema de intercambio |
| Formato | Layout SHCP vigente — ARCO (Archivo de Reportes de Cash Operations) |
| Impacto si falla | Sanción LFPIORPI Art. 52 — hasta $5 millones MXN por incumplimiento |

## DEX-D15-05: Listas OFAC y ONU

| Atributo | Valor |
|----------|-------|
| Fuentes | US Treasury OFAC (SDN list), ONU (Resolución 1267/1989, 2253) |
| Frecuencia de actualización | OFAC: diario / ONU: cuando se actualiza |
| Mecanismo actual | `[DATO-REQUERIDO]` — confirmar si es descarga manual o feed automático |
| Impacto | Clientes en estas listas deben ser bloqueados inmediatamente |
| Regulación | Cumplimiento propio BanCoppel; FATF R.6 (sanciones financieras específicas) |

## Estrategia de migración de integraciones externas

| Fase | Acción |
|------|--------|
| DESIGN | Documentar el protocolo exacto de cada integración (formato, credenciales, certificados) |
| BUILD | Implementar cada integración como servicio independiente en el target (no acoplado al motor PLD) |
| TEST | Probar con sandbox/UAT de cada sistema externo (Buró, SAT, CNBV, SHCP) |
| CUTOVER | Redirigir las integraciones al sistema target con monitoreo simultáneo del legacy |
| POST-CUTOVER | Mantener el legacy disponible durante 3 meses como fallback para integraciones externas |

## `[SME-PENDING]`

- [ ] Área de Cumplimiento: proporcionar los layouts oficiales vigentes de los reportes CNBV, SHCP y SAT.
- [ ] DBA IBM Informix: identificar los SPs que generan cada tipo de reporte regulatorio (buscar en los 96 aislados).
- [ ] Confirmar los canales de envío actuales (SFTP, portal web, API) para cada regulador.
- [ ] Obtener credenciales y certificados de las integraciones con Buró de Crédito y SAT para migrarlos a AWS Secrets Manager.
- [ ] Confirmar si OFAC y ONU tienen feed automático o es actualización manual periódica.

---
*Generado: SME Regulatorio CNBV + Cybersecurity · 2026-08-03*
