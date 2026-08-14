# Account Plan FY27 — Citi / Banamex
> Creado: 2026-07-13 · Actualizado: 2026-07-13 · Owner: alejandro.gallegos@accenture.com
> Ciclo: FY27 Sep 2026 – Sep 2027 · Sub-offering principal: HVM · SAF

---

## 1. Snapshot de la Cuenta

| Campo | Valor |
|-------|-------|
| Industria | Banca retail · corporativa · wealth — México |
| Tamaño (revenue cliente) | ~$110B MXN en activos (estimado post-separación Citi) |
| Revenue S&PE Accenture FY26 (USD) | $6.50M (24.7% CCI — mayor cuenta del portfolio) |
| Proyectos S&PE activos | HVM Mainframe S500/S151 · ETAPA 0 DISCOVER · SME: por designar |
| AMS / Managed Services activo | No |
| Score de relación (1-5) | 3 — Vendedor consolidado; separación Citi abre oportunidad a Trusted Advisor |
| Decision Makers | Iván Fajardo (DM Apigee) · Álvaro Ruiz (exec sponsor) |
| Influencers técnicos | Orlan Eduardo · Roberto Sánchez (Arquitectura Apigee) · Iván Bula (Arquitectura Cloud) |
| MD Accenture responsable | Por confirmar |
| Último contacto ejecutivo | 2026-07-13 — 1ª sesión discovery Migración Apigee X con Iván Fajardo |

---

## 2. Prioridades del Cliente FY27

> Fuente: sesión de descubrimiento directa (Iván Fajardo + equipo técnico) + contexto de separación Citi

1. **Separación de Citi — independencia tecnológica completa** — Banamex debe operar su propio ambiente de API management (hoy en Apigee OPDK bajo infraestructura Citi) sin dependencia del grupo. Driver regulatorio y operativo crítico para la separación corporativa.
2. **Migración Apigee OPDK → Apigee X** — ~1,200 APIs por ambiente (Test, PERF, Producción) sobre Apigee 4.52/4.53; soporte extendido con Google como palanca; volumen de ~9.4M transacciones diarias con proyección de crecimiento ~20% anual. Sin estrategia de migración definida.
3. **Modernización del mainframe Unisys ClearPath** — S500 (Cargos y Abonos) y S151 (Movimientos Contables CNBV) en DISCOVER; separación de Citi también elimina el soporte técnico heredado de Unisys vía Citi.
4. **Developer Experience e IDP** — Plataforma Backstage para self-service de APIs y CI/CD; complementario al CICD Design y ServiceNow en evaluación.

**Presión regulatoria**: CNBV · Banxico · PCI-DSS · DORA (indirectamente vía grupos europeos en su red corresponsal)

---

## 3. Pipeline de Oportunidades S&PE FY27

| ID | Oportunidad | Sub-Offering | Q | USD Bookings | Prob | Stage | Sponsor cliente |
|----|-------------|-------------|---|-------------|------|-------|-----------------|
| OP-001 | Migración Apigee X | SAF / HVM | Q2 | $180K – $227K | 25% | Qualified | Iván Fajardo · Álvaro Ruiz |
| OP-002 | Backstage IDP | SAF | Q2–Q3 | $1.4M – $2.0M | 10% | Identified | Por confirmar |
| OP-003 | HVM Mainframe S500/S151 | HVM | Q1–Q4 | TBD (post-ETAPA 0) | 50% | Commit | Por designar |

**Pipeline total**: ~$1.6M – $2.2M USD · **Weighted**: ~$0.7M USD

> OP-003 booking se cuantifica al cerrar ETAPA 0 con inventario completo y CCM v1.8. No se incluye en totales de pipeline hasta tener spec validada.

### Detalle de oportunidades

**OP-001 — Migración Apigee X**
```
SUB-OFFERING: Software Architecture Foundation (SAF) + HVM (modernización de plataforma API)
TIPO        : NB (New Business)
DESCRIPCIÓN : Diseño de estrategia de migración + ejecución técnica de ~1,200 APIs de Apigee
              OPDK 4.52/4.53 (3 ambientes: Test, PERF, Producción) hacia Apigee X.
              Driver: separación Citi + soporte extendido Google. Volumen: ~9.4M tx/día
              con proyección de crecimiento ~20% anual. El cliente no tiene estrategia
              definida y solicitó explícitamente el apoyo de Accenture para diseñarla y
              ejecutarla. Google (Gustavo Sánchez) refirió a Accenture al no poder cubrir
              el servicio completo.
TRIMESTRE   : Q2 Ene-Mar 2027 (kick-off formal: ~2 meses de aprobaciones internas por
              parte del cliente — cost case, presupuesto, decisión IVA/PJ)
BOOKINGS    : $180K – $227K USD TCV (migración 6m + hypercare 4m, preliminar)
              + potencial de managed services de la plataforma post-migración
CCI EST.    : Target 37% SI
PROBABILIDAD: 25% (Qualified)
SPONSOR     : Iván Fajardo (DM), Álvaro Ruiz (exec sponsor)
BD SOLICITADO: USD 5K (profundizar levantamiento: logs API Gateway, reportes SolarWinds)
SIG. ACCIÓN : Obtener presupuesto BD · Conseguir info propuesta GCP y referencias de Brazil
              · Construir propuesta técnico-comercial · alejandro.gallegos · Jul 2026
BLOQUEANTE  : ~2 meses de aprobaciones internas del cliente (cost case + presupuesto +
              decisión IVA/PJ). Riesgo: cliente es sensible a costo-beneficio — podría
              explorar otros integradores si no se actúa con velocidad.
COMPETIDOR  : Sin proceso competitivo formal a la fecha. Google cubrirá parte GCP;
              parte de implementación referida a Accenture. Monitorear integradores
              alternativos (sensibilidad a precio del cliente).
```

**OP-002 — Backstage IDP**
```
SUB-OFFERING: Software Architecture Foundation (SAF)
TIPO        : NB
DESCRIPCIÓN : Implementación de Internal Developer Platform con Backstage como base.
              Driver: separación Citi requiere que Banamex opere su propio IDP con
              golden paths de CI/CD, catálogo de APIs y self-service de plataforma.
              Complementario a CICD Design y ServiceNow en evaluación. S0 activo.
TRIMESTRE   : Q2–Q3 Ene-Jun 2027
BOOKINGS    : ~$1.4M – $2.0M USD (SI $25M–$35M MXN + AMS subsecuente)
CCI EST.    : 41% SI
PROBABILIDAD: 10% (Identified)
SPONSOR     : Por confirmar
SIG. ACCIÓN : Vincular a la narrativa de separación Citi + Apigee X · Identificar sponsor
              técnico · alejandro.gallegos · Ago 2026
BLOQUEANTE  : Sponsor técnico no confirmado. Pendiente alinear con OP-001 como secuencia
              natural (API Gateway → IDP).
```

**OP-003 — HVM Mainframe S500 (Cargos/Abonos) y S151 (Movimientos Contables)**
```
SUB-OFFERING: High Velocity Modernization (HVM)
TIPO        : NB
DESCRIPCIÓN : Modernización del mainframe Unisys ClearPath — S500 (~65 COBOL + 15 ALGOL,
              ~297K LOC) y S151 (~79 COBOL + 16 ALGOL, ~445K LOC). 741,669 LOC total.
              Actualmente en ETAPA 0 DISCOVER (Setup & Inventory). Dos componentes:
              SPE-MM-001 (S500) y SPE-MM-002 (S151). Dependency: S151 consume
              movimientos de S500 — secuencia: S500 primero, S151 segundo.
TRIMESTRE   : Q1–Q4 FY27 (multi-año)
BOOKINGS    : TBD — cuantificar al cerrar ETAPA 0 con CCM v1.8
CCI EST.    : TBD (target 41% SI)
PROBABILIDAD: 50% (Commit — ya en delivery DISCOVER)
SPONSOR     : Por designar (Banamex SME técnico pendiente de asignación)
SIG. ACCIÓN : Completar ETAPA 0: cargar source en /source/, recibir DASDL schema,
              30+ días de execution logs, asignar SMEs Banamex · Jul–Ago 2026
BLOQUEANTE  : ETAPA 0 checklist pendiente (source code cargado, logs de ejecución,
              asignación SME Banamex, ambiente de análisis).
```

---

## 4. Targets FY27

| Métrica | FY26 Real | FY27 Target | Gap | CCI |
|---------|----------|------------|-----|-----|
| Revenue total (USD) | $6.50M | $7.5M | +$1.0M | 24.7% → 30%+ |
| New Business bookings (USD) | — | $2.5M – $4.0M | — | 37–41% |
| Revenue recurrente (USD) | $6.50M | $6.5M (proteger) | — | ~25% |

**Supuestos clave**:
1. OP-001 Apigee X cierra en Q2 FY27 (~$200K USD bookings a 37% CCI).
2. OP-003 HVM Mainframe pasa a fase BUILD en Q2–Q3 tras completar DISCOVER y cuantificar alcance con CCM v1.8.
3. La separación Citi actúa como catalizador: cada workstream de independencia tecnológica es una oportunidad S&PE.

---

## 5. Narrativa de Valor — CIO/CTO

Banamex atraviesa la transformación corporativa más significativa de su historia reciente: la separación de Citi implica construir capacidad tecnológica propia en dominios donde hoy depende del grupo. API management, mainframe Unisys, plataformas de developer experience — todos requieren ownership técnico independiente antes del cierre de la separación.

Accenture S&PE es el único partner que combina las tres capacidades que Banamex necesita hoy: (1) la experiencia probada en migración de plataformas de API management a escala — ~1,200 APIs en producción no se migran con documentación genérica de Google, se migran con playbooks probados en bancos de tamaño comparable; (2) la metodología de High Velocity Modernization para desmantelar el mainframe Unisys sin apagar el sistema — con equivalencia funcional probada y rollback plan en cada fase, algo que ninguna firma de niche puede ofrecer; y (3) Google nos refirió directamente porque no pueden cubrir el servicio completo: somos el partner de implementación, no el competidor.

El diferenciador frente a integradores locales es la escala y las referencias: Brazil ya ejecutó migraciones Apigee similares con Accenture — esas referencias son concretas, verificables y relevantes para el cliente. Frente a IBM/Kyndryl en mainframe, ya estamos dentro del cliente con el gemelo cognitivo de los sistemas S500/S151 — tenemos el conocimiento previo del sistema que ningún competidor tiene.

**Llamada a la acción**: Asegurar el presupuesto BD de USD 5K para profundizar el levantamiento (logs API Gateway, reportes SolarWinds) y construir la propuesta técnico-comercial de Apigee X antes de que el cliente inicie el proceso de aprobaciones internas (~2 meses).

---

## 6. Situación Competitiva

| Competidor | Presencia actual | Fortaleza | Nuestra ventaja diferencial |
|------------|-----------------|-----------|----------------------------|
| Google (GCP) | Activo — refirió a Accenture | Soporte extendido Apigee X · conocimiento del producto | Google cubre la parte GCP; la implementación la hace Accenture — somos complementarios, no competidores |
| Integradores locales / niche | Riesgo latente | Precio | Escala + referencias Brazil + conocimiento previo del stack Banamex |
| IBM / Kyndryl | Incumbente histórico en mainframe | Relación larga con Citi/Banamex en Unisys | Ya estamos dentro con el gemelo cognitivo S500/S151 — ventaja de conocimiento que IBM no tiene |
| Equipo propio Banamex | ~20–40 personas estimadas en IT | Conocimiento del negocio | Sin experiencia en migración Apigee X a escala; separación Citi genera urgencia que supera su capacidad interna |

---

## 7. Roadmap de Ejecución FY27

### Q1 — Oct-Dic 2026 (pre-FY27 — acciones inmediatas)
- [ ] Asegurar presupuesto BD $5K para levantamiento Apigee X · alejandro.gallegos · Jul 2026
- [ ] Profundizar levantamiento: obtener logs API Gateway + reportes SolarWinds · Equipo técnico + Iván Fajardo · Jul–Ago 2026
- [ ] Conseguir info de propuesta GCP (Gustavo Sánchez) y referencias de Brazil · alejandro.gallegos · Jul–Ago 2026
- [ ] Construir propuesta técnico-comercial Apigee X con pricing CCM v1.8 · S&PE + Pricing · Ago–Sep 2026
- [ ] Completar ETAPA 0 Mainframe (source cargado, logs 30 días, SMEs Banamex asignados) · alejandro.gallegos · Ago 2026
- [ ] Identificar sponsor técnico para Backstage IDP y vincular a narrativa separación Citi · alejandro.gallegos · Sep 2026

### Q2 — Ene-Mar 2027
- [ ] Propuesta Apigee X entregada y en aprobaciones internas cliente · alejandro.gallegos · Oct 2026
- [ ] OP-001 Apigee X a Commit (≥ 50%) · Nov 2026
- [ ] Kick-off formal Apigee X (tras ~2 meses de aprobaciones internas) · Ene–Feb 2027
- [ ] ETAPA 1 Mainframe: análisis funcional profundo S500 · Q2 2027
- [ ] OP-002 Backstage IDP a Qualified si sponsor confirmado · Feb 2027

### Q3 — Abr-Jun 2027
- [ ] Hito de migración Apigee X: ambiente Test migrado al 100% · May 2027
- [ ] Inicio análisis S151 (fase paralela a BUILD S500) · Abr 2027
- [ ] Propuesta Backstage IDP entregada a cliente · Jun 2027

### Q4 — Jul-Sep 2027
- [ ] Hito de migración Apigee X: PERF migrado + inicio PROD · Jul 2027
- [ ] Hypercare Apigee X comenzando (4 meses post-migración core) · Ago 2027
- [ ] Revisión de plan FY28 con exec sponsor Álvaro Ruiz · Sep 2027
- [ ] OP-003 Mainframe: S500 completando BUILD → first wave en TEST · Sep 2027

---

## 8. Próximas Acciones Inmediatas (≤ 30 días)

1. Asegurar presupuesto BD $5K para levantamiento Apigee X · alejandro.gallegos · 25-Jul-2026
2. Solicitar a Gustavo Sánchez (Google) la propuesta GCP y referencias de implementaciones Apigee X en Brazil · alejandro.gallegos · 18-Jul-2026
3. Agendar sesión técnica con Roberto Sánchez y Orlan Eduardo para revisar logs API Gateway + SolarWinds · Equipo técnico · 25-Jul-2026
4. Asignar SME Banamex para ETAPA 0 Mainframe (contacto con equipo técnico S500/S151) · alejandro.gallegos · 20-Jul-2026

---

## 9. Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Cliente explora integradores alternativos por sensibilidad a precio | Media | Alto | Actuar con velocidad — propuesta antes de que terminen las aprobaciones internas; anclar con referencias de Brazil |
| Aprobaciones internas Banamex se extienden más de 2 meses | Alta | Medio | Mantener momentum técnico con BD (levantamiento gratuito mientras aprobaciones) |
| Sponsor Iván Fajardo cambia de rol durante separación Citi | Media | Alto | Construir relación paralela con Álvaro Ruiz (exec sponsor) e Iván Bula (Cloud) |
| Competidor entra con precio agresivo (integrador local) | Media | Medio | Diferenciación por referencias Brazil + conocimiento previo del stack Banamex (mainframe + APIs) |
| ETAPA 0 Mainframe se extiende por falta de SME Banamex | Alta | Medio | Escalar necesidad de asignación SME como bloqueante crítico |
| Mainframe modernization descubierta más compleja (10 anomalías ya detectadas) | Alta | Alto | Las 10 anomalías ANO-001/ANO-010 están documentadas en knowledge-base; pricing debe incorporar buffer de complejidad |

---

## 10. Log de Actualizaciones

| Fecha | Qué cambió |
|-------|-----------|
| 2026-07-13 | Plan creado — SCAN inicial basado en sesión discovery Apigee X + memoria activa de proyectos Banamex |
| 2026-07-13 | OP-001 Migración Apigee X registrada (Stage 1 Identificación → Qualified 25%) |
| 2026-07-13 | OP-002 Backstage IDP incorporada desde memoria activa (S0 activo) |
| 2026-07-13 | OP-003 HVM Mainframe S500/S151 incorporada como Commit 50% (en DISCOVER activo) |

---

*Archivo: `accounts/citi-banamex.md` · FY27 · alejandro.gallegos@accenture.com*
*Proyectos activos vinculados: [[project-banamex-mainframe]] · [[project-banamex-backstage]]*