# Señales Regulatorias — AXA México P&C Commercial Lines

> Documento vivo · Actualizar ante publicaciones de CNSF, DOF y circulares
> Fuente: CNSF · DOF · CINIF · CONDUSEF · SHCP

---

## Marco Regulatorio Primario AXA México

| Marco | Organismo | Vigencia | Impacto en sistemas |
|-------|-----------|----------|---------------------|
| Ley de Instituciones de Seguros y Fianzas (LISF) | CNSF | Vigente | policy-admin · billing |
| Circular Única de Seguros y Fianzas (CUSF) | CNSF | Vigente, con actualizaciones continuas | Todos los sistemas |
| Solvencia C (RCSF, FAMS) | CNSF | Vigente | solvency · actuarial |
| IFRS 17 (NIF C-3 en MX) | CINIF / CNSF | Transición activa | actuarial · billing · reporting-cnsf |
| CONDUSEF — Protección al usuario | CONDUSEF | Vigente | crm · digital · portal-agentes |
| LSFE / UIF — Prevención lavado | UIF / SHCP | Vigente | compliance (cnsf) |
| LFPDPPP — Datos personales | INAI | Vigente | Todos los sistemas con datos de cliente |
| DORA (contexto AXA Group Europa) | BCE / EIOPA | Vigente en EU · derivada en MX | integration · api-gateway |

---

## Iniciativas Regulatorias en Curso (2025-2027)

### 1. IFRS 17 — Implementación en México
**Estado**: Transición activa (CINIF emitió NIF C-3 equivalente; CNSF en proceso de alineación)

**Qué cambia**:
- Modelo de medición de contratos de seguro (GMM vs PAA para corto plazo P&C)
- Reconocimiento de primas y siniestros: eliminación del "earned basis" tradicional
- CSM (Contractual Service Margin) como nuevo componente de balance
- Disclosure narrativo obligatorio sobre metodología actuarial

**Impacto AXA México**:
- `actuarial`: modelos de reservas deben reflejar IFRS 17 (BBA/PAA selector)
- `reporting-cnsf`: nuevos formatos de reporte con reconciliación IFRS 17 vs CUSF
- `billing`: separación de componentes de la prima según IFRS 17
- AXA Group tiene implementación global avanzada → posible acelerador para MX

**Deadline**: CNSF no ha fijado fecha de adopción obligatoria local. Monitorear DOF.

**Riesgo si no se actúa**: audit findings, restatements, potencial multa CNSF.

---

### 2. Solvencia C — Evolución del RCSF
**Estado**: Marco vigente; CNSF revisa calibraciones periódicas de factores

**Qué cambia**:
- Revisión de factores de riesgo para riesgos catastrófico (RCat), de crédito (RCred) y operacional (ROp)
- Posible incorporación de riesgo climático como categoría explícita
- Mayor granularidad en requerimientos de divulgación del capital

**Impacto AXA México**:
- `solvency`: actualización de modelos de cálculo RCSF / FAMS
- `actuarial`: inputs de reservas técnicas para el cálculo de solvencia
- `reporting-cnsf`: formatos de reporte de capital (Estados Financieros Estatutarios)

**Señal de alerta**: AXA Group está bajo DORA y Solvencia II en Europa → metodologías más exigentes que el marco MX actual.

---

### 3. Regulación Ciberseguros — Nuevo Ramo CNSF
**Estado**: CNSF en consulta; no hay circular final

**Qué implicaría**:
- Creación de ramo de seguros de ciberriesgo con nota técnica obligatoria
- Requisitos de cumplimiento técnico del riesgo (Cyber Risk Assessment para underwriting)
- Posible limitación de cobertura de ransomware sin controls certificados

**Impacto AXA México**:
- `underwriting-engine`: nuevas reglas de suscripción para cyber
- `cnsf`: nueva nota técnica a registrar
- `actuarial`: nuevos modelos de frecuencia-severidad para cibersiniestros

**Oportunidad**: AXA XL tiene expertise global en cyber → ventaja de first-mover si AXA MX activa el ramo.

---

### 4. Inclusión Financiera en Seguros — SHCP / CNSF
**Estado**: Agenda activa del gobierno federal

**Qué implica**:
- Microseguros con requisitos simplificados de nota técnica
- Seguros agrícolas con subsidio gubernamental (AGROASEMEX)
- Simplificación de procesos de contratación para segmentos no bancarizados

**Impacto AXA México**:
- `digital`: canal digital obligatorio para microseguros
- `policy-admin`: soporte de productos simplificados
- Moderado para Commercial Lines — mayor impacto en segmentos masivos

---

### 5. Ciberseguridad Sectorial — Circulares CNSF
**Estado**: Circular existente (S-3.1 de CNSF sobre continuidad). Posible actualización.

**Qué cambia**:
- Marcos de gestión de riesgos tecnológicos para instituciones de seguros
- Requerimientos de plan de continuidad de negocio (BCP) y DRP
- Inventario de sistemas críticos y proveedores tecnológicos

**Impacto AXA México**:
- `api-gateway · event-bus`: controles de seguridad en integración
- `datawarehouse`: clasificación de datos sensibles
- AXA Group: DORA compliance exige controles de ciber-resiliencia que exceden el estándar MX

---

### 6. CONDUSEF — Protección al Asegurado
**Estado**: Marco vigente con actualizaciones periódicas de UNE, tiempos de respuesta

**Señales recientes**:
- Mayor supervisión de tiempos de atención de siniestros (P&C: 30 días hábiles máximo)
- Regulación de chatbots y IA en atención al usuario
- Requisitos de transparencia en exclusiones de póliza

**Impacto AXA México**:
- `claims`: tracking de tiempos de atención CONDUSEF
- `digital`: chatbots deben declarar ser IA ante el usuario
- `crm`: registro de quejas y seguimiento UNE

---

## Calendario Regulatorio — Eventos a Monitorear

| Evento | Organismo | Frecuencia | Relevancia |
|--------|-----------|-----------|-----------|
| Boletín Estadístico | CNSF | Trimestral | Alta — market data |
| Estados Financieros del Sector | CNSF | Semestral / Anual | Alta |
| Publicaciones DOF — seguros | SHCP / CNSF | Continuo | Alta — cambios regulatorios |
| Circular Única actualizaciones | CNSF | Periódico | Alta |
| Asamblea AMIS | AMIS | Anual | Media — tendencias sector |
| FORO CNSF Solvencia | CNSF | Anual | Alta — señales de cambio |
| Publicación NIF CINIF | CINIF | Anual | Alta para IFRS 17 |

---

## Riesgos Regulatorios — Registro

| Riesgo | Probabilidad | Impacto | Sistemas afectados | Mitigación |
|--------|-------------|---------|-------------------|------------|
| Retraso en IFRS 17 MX genera desfase con grupo | Media | Alto | actuarial · reporting-cnsf | Monitorear CINIF / CNSF; usar metodología grupo AXA como referencia |
| Nueva circular ciberseguridad con plazos cortos | Media | Alto | Todos | Anticipar con DORA framework del grupo |
| Sanción CONDUSEF por tiempos de siniestros | Baja-Media | Medio | claims · crm | Dashboard de tracking SLA operacional |
| Reforma fiscal seguros (deducibilidad primas) | Baja | Medio-Alto | billing · actuarial | Monitorear SAT / SHCP |
| Cambio en factores RCSF catastrófico | Media | Alto | solvency · actuarial | Stress testing periódico |

---

*Documento scaffold — completar con textos de circulares CNSF, resoluciones DOF y análisis jurídico*
*Última actualización: 2026-09-03 · v1.0*