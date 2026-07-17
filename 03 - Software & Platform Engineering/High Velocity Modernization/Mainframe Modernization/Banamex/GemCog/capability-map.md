# Capability Map — Banamex GemCog
> Gemelo Cognitivo Capa 3 · Mapa de capacidades bancarias con estado de documentación
> Sistemas: S500 (Captación) + S151 (GL) · Unisys ClearPath MCP
> Última actualización: 2026-07-16 · v1.0

---

## Cobertura actual

| Métrica | Valor |
|---------|-------|
| Capacidades en el modelo | 104 + 1 extensión CFR |
| Cubiertas por S500 o S151 | 21 (20.2%) |
| `cap-{slug}.md` generados | 21 / 21 ✅ |
| `cap-{slug}.md` pendientes | 0 / 21 |
| Reglas disponibles para doc. | 826 (644 S151 + 182 S500) |
| Reglas vinculadas | ~783 / 826 (94.8%) |

---

## Mapa completo — 104 capacidades

**Leyenda de estado:**
- ✅ `cap-{slug}.md` generado (Tareas + Casuísticas + Diagrama + Reglas vinculadas)
- ⏳ Cubierto por S500/S151, pendiente generar `cap-{slug}.md`
- _(gap)_ No cubierto por los sistemas Unisys analizados

| ID | Capacidad | Dominio | Sistema | `cap-{slug}.md` | Estado |
|----|-----------|---------|---------|-----------------|--------|
| 1.1.1 | Onboarding | Ecosystem Management | — | — | _(gap)_ |
| 1.1.2 | Partnering means | Ecosystem Management | — | — | _(gap)_ |
| 1.1.3 | Agreements & SLA | Ecosystem Management | — | — | _(gap)_ |
| 1.1.4 | Review | Ecosystem Management | — | — | _(gap)_ |
| **2.1.1** | **Teller** | **Channels** | **S151+S500** | [cap-tel.md](capacidades/cap-tel.md) | ✅ |
| 2.1.2 | Retail Salesforce | Channels | — | — | _(gap)_ |
| 2.1.3 | Contact Centre (Phone) | Channels | — | — | _(gap)_ |
| 2.1.4 | Contact Centre (Web) | Channels | — | — | _(gap)_ |
| 2.1.5 | Relationship Manager | Channels | — | — | _(gap)_ |
| 2.1.6 | Mail | Channels | — | — | _(gap)_ |
| 2.1.7 | Social Media | Channels | — | — | _(gap)_ |
| 2.2.1 | IVR | Channels | — | — | _(gap)_ |
| 2.2.2 | Kiosk / SST | Channels | — | — | _(gap)_ |
| 2.2.3 | Web (BPI) | Channels | — | — | _(gap)_ |
| 2.2.4 | Mobile | Channels | — | — | _(gap)_ |
| 2.2.5 | SMS | Channels | — | — | _(gap)_ |
| **2.2.6** | **ATM** | **Channels** | **S500** | [cap-tar.md](capacidades/cap-tar.md) | ✅ |
| **2.2.7** | **PoS** | **Channels** | **S500** | [cap-tar.md](capacidades/cap-tar.md) | ✅ |
| 2.3.1 | Affiliate & Partner Channels | Channels | — | — | _(gap)_ |
| 2.3.2 | Device Management | Channels | — | — | _(gap)_ |
| 3.1.1 | Marketing | Marketing & Distribution | — | — | _(gap)_ |
| 3.1.2 | Digital Marketing | Marketing & Distribution | — | — | _(gap)_ |
| 3.1.3 | Sales Management | Marketing & Distribution | — | — | _(gap)_ |
| 3.1.4 | Contract Management | Marketing & Distribution | — | — | _(gap)_ |
| 3.1.5 | Illustration Management | Marketing & Distribution | — | — | _(gap)_ |
| 3.1.6 | Customer Finance Mgmt. | Marketing & Distribution | — | — | _(gap)_ |
| 3.1.7 | Brand Management | Marketing & Distribution | — | — | _(gap)_ |
| 4.1.1 | Demographics | Common Customer View | — | — | _(gap)_ |
| **4.1.2** | **Holdings** | **Common Customer View** | **S151** | [cap-hld.md](capacidades/cap-hld.md) | ✅ |
| 4.1.3 | Roles & Relationships | Common Customer View | — | — | _(gap)_ |
| 4.1.4 | Ref. Satellite | Common Customer View | — | — | _(gap)_ |
| 4.1.5 | Segmentation | Common Customer View | — | — | _(gap)_ |
| 4.2.1 | Registration | Common Customer View | — | — | _(gap)_ |
| 4.2.2 | Authentication | Common Customer View | — | — | _(gap)_ |
| 4.3.1 | Needs and offer | Common Customer View | — | — | _(gap)_ |
| 4.3.2 | Goals | Common Customer View | — | — | _(gap)_ |
| 4.3.3 | Communication | Common Customer View | — | — | _(gap)_ |
| 4.4.1 | Sentiment & Feedback | Common Customer View | — | — | _(gap)_ |
| 4.4.2 | Personalisation | Common Customer View | — | — | _(gap)_ |
| 4.5.1 | Operations author. | Common Customer View | — | — | _(gap)_ |
| 4.5.2 | Delegations, PoA | Common Customer View | — | — | _(gap)_ |
| 4.5.3 | Signatures | Common Customer View | — | — | _(gap)_ |
| 4.6.1 | Prospect Management | Common Customer View | — | — | _(gap)_ |
| **5.1.1** | **Deposits** | **Product Processing** | **S500** | [cap-dep.md](capacidades/cap-dep.md) | ✅ |
| 5.1.2 | Lending | Product Processing | — | — | _(gap)_ |
| 5.1.3 | Corp Finance | Product Processing | — | — | _(gap)_ |
| 5.1.4 | Asset Mgmt. | Product Processing | — | — | _(gap)_ |
| 5.1.5 | Insurance | Product Processing | — | — | _(gap)_ |
| 5.1.6 | FX | Product Processing | — | — | _(gap)_ |
| 5.1.7 | Cards | Product Processing | — | — | _(gap)_ |
| 5.1.8 | Non Financial Products | Product Processing | — | — | _(gap)_ |
| 5.1.9 | Custody & Funded Adm. | Product Processing | — | — | _(gap)_ |
| 6.1.1 | Master Contract Mgmt. | Common Services | — | — | _(gap)_ |
| 6.1.2 | Cash Mgmt. | Common Services | — | — | _(gap)_ |
| **6.1.3** | **Payments** | **Common Services** | **S500** | [cap-pay.md](capacidades/cap-pay.md) | ✅ |
| **6.1.4** | **Statements** | **Common Services** | **S500+S151** | [cap-sta.md](capacidades/cap-sta.md) | ✅ |
| **6.1.5** | **Interest & Fees** | **Common Services** | **S500** | [cap-int.md](capacidades/cap-int.md) | ✅ |
| 6.2.1 | Operational Risk | Common Services | — | — | _(gap)_ |
| 6.2.2 | Financial Risk | Common Services | — | — | _(gap)_ |
| 6.3.1 | AML | Common Services | — | — | _(gap)_ |
| 6.3.2 | Fraud | Common Services | — | — | _(gap)_ |
| 6.4.1 | Complaints Analysis | Common Services | — | — | _(gap)_ |
| 6.4.2 | Complaints Follow up | Common Services | — | — | _(gap)_ |
| 6.4.3 | Complaints Closing | Common Services | — | — | _(gap)_ |
| 6.5.1 | Collections & Recovery | Common Services | — | — | _(gap)_ |
| **6.5.2** | **Compliance & Regulation** | **Common Services** | **S500+S151** | [cap-cmp.md](capacidades/cap-cmp.md) | ✅ |
| 6.5.3 | Pricing Management | Common Services | — | — | _(gap)_ |
| 6.5.4 | Treasury | Common Services | — | — | _(gap)_ |
| **6.6.1** | **Financial Servicing** | **Common Services** | **S500** | [cap-int.md](capacidades/cap-int.md) — merge | ✅ |
| 6.6.2 | Non Financial Servicing | Common Services | — | — | _(gap)_ |
| 6.6.3 | Intelligent Servicing (RPA) | Common Services | — | — | _(gap)_ |
| **6.7.1** | **Financial Reconciliation** | **Common Services** | **S151** | [cap-rec.md](capacidades/cap-rec.md) | ✅ |
| **6.7.2** | **Operational Reconciliation** | **Common Services** | **S500+S151** | [cap-orc.md](capacidades/cap-orc.md) | ✅ |
| **7.1.1** | **Finance (GL)** | **Enterprise Support Functions** | **S151** | [cap-gl.md](capacidades/cap-gl.md) | ✅ |
| 7.1.2 | Talent & Organisation | Enterprise Support Functions | — | — | _(gap)_ |
| 7.1.3 | IT | Enterprise Support Functions | — | — | _(gap)_ |
| 7.1.4 | Corporate Services | Enterprise Support Functions | — | — | _(gap)_ |
| **8.1.1** | **Scheduling** | **Technology Tools** | **S500+S151** | [cap-sch.md](capacidades/cap-sch.md) | ✅ |
| 8.1.2 | Business Process Mgmt. | Technology Tools | — | — | _(gap)_ |
| 8.1.3 | AI Tools | Technology Tools | — | — | _(gap)_ |
| 8.1.4 | EA Tools | Technology Tools | — | — | _(gap)_ |
| 8.1.5 | Document Management | Technology Tools | — | — | _(gap)_ |
| 8.1.6 | Collaboration & Productivity | Technology Tools | — | — | _(gap)_ |
| 8.1.7 | Project Management | Technology Tools | — | — | _(gap)_ |
| 8.1.8 | RPA Tools | Technology Tools | — | — | _(gap)_ |
| **9.1.1** | **Operational Data Stores** | **Insights & Information** | **S500+S151** | [cap-ods.md](capacidades/cap-ods.md) | ✅ |
| 9.1.2 | Event Streams | Insights & Information | — | — | _(gap)_ |
| 9.1.3 | Data Lakes | Insights & Information | — | — | _(gap)_ |
| **10.1.1** | **Access Control** | **Integration & Interfaces** | **S500+S151** | [cap-sec.md](capacidades/cap-sec.md) — merge | ✅ |
| 10.1.2 | Traffic Management | Integration & Interfaces | — | — | _(gap)_ |
| 10.1.3 | API Catalogue | Integration & Interfaces | — | — | _(gap)_ |
| T.1.1 | API (External) | Transversal | — | — | _(gap)_ |
| T.1.2 | EDI | Transversal | — | — | _(gap)_ |
| **T.1.3** | **Payment Schemes (SPEI/CLABE)** | **Transversal** | **S500+S151** | [cap-pay.md](capacidades/cap-pay.md) — merge | ✅ |
| T.1.4 | Cloud Integration | Transversal | — | — | _(gap)_ |
| T.2.1 | API (Internal) | Transversal | — | — | _(gap)_ |
| T.2.2 | ESB | Transversal | — | — | _(gap)_ |
| **T.2.3** | **MQ / Async (L091-L093)** | **Transversal** | **S500** | [cap-mq.md](capacidades/cap-mq.md) | ✅ |
| T.2.4 | Others | Transversal | — | — | _(gap)_ |
| T.3.1 | Master Data Mgmt. | Transversal | — | — | _(gap)_ |
| T.3.2 | Metadata Mgmt. | Transversal | — | — | _(gap)_ |
| T.3.3 | Content Mgmt. | Transversal | — | — | _(gap)_ |
| **T.3.4** | **Analytics / Reporting** | **Transversal** | **S151** | [cap-rpt.md](capacidades/cap-rpt.md) | ✅ |
| **T.3.5** | **Security** | **Transversal** | **S500+S151** | [cap-sec.md](capacidades/cap-sec.md) | ✅ |
| **T.4.1** | **CFR Regulatory Reporting Pipeline** | **Transversal** | **S151** | [cap-cfr.md](capacidades/cap-cfr.md) | ✅ |

---

## Prioridad de generación — próximos `cap-{slug}.md`

| Prioridad | Capacidad | Slug | Sistema | Reglas disponibles | Razón |
|-----------|-----------|------|---------|-------------------|-------|
| ✅ DONE | ATM + PoS | TAR | S500 | RN-S500-037..055 (19) | Piloto — P630 TARINTERCAM |
| ✅ DONE | Finance (GL) | GL | S151 | RN-S151-021..060 (40) | Core del GL — motor de asientos, 15+ sistemas |
| ✅ DONE | Financial Reconciliation | REC | S151 | RN-S151-001..020 (20, P112) | Conciliación diaria S500↔S151 — riesgo contable |
| ✅ DONE | Security | SEC | S500+S151 | RN-S500-027..036 (10, P655) | PCI-DSS — scrambling de datos sensibles |
| ✅ DONE | Compliance & Regulation | CMP | S500+S151 | RN-S500-001..008 (P103 FraudLink) | Regulatorio CNBV — reporte FraudLink |
| ✅ DONE | Scheduling | SCH | S500+S151 | RN-S500-009..026 (P100+P075) | Control batch — gate de cierre diario |
| ✅ DONE | Interest & Fees | INT | S500 | RN-S500-079..107 (29, P130-S500) | Cálculo intereses + retención ISR |
| ✅ DONE | Operational Data Stores | ODS | S500+S151 | RN-S151-491..525 (DASDL, 6 BDs) | Modelo DMSII — BD10·BD11·BD12·BD13·BD99·BD02 |
| ✅ DONE | Payments | PAY | S500 | RN-S500-108..152 (P020 LINCOMS) | Cargos y abonos core — incluyendo DIVESTITURE flag |
| ✅ DONE | Operational Reconciliation | ORC | S500+S151 | RN-S500-153..182 (S151REGISTRA) | Flag compilación condicional — 2 variantes REGISTRA1/2 |
| P1 | Access Control | ACC | S500 | RN-S500-027..036 (P655, compartido SEC) | L010_CONTROL + P655 scrambling |
| ✅ DONE | Deposits | DEP | S500 | RN-S500-134, 138..152 · P142+P144 · 16 reglas | BIT-ACTBANDERA, conciliación B01↔B03, contratos captación |
| P1 | Payment Schemes (SPEI/CLABE) | SPI | S500 | RN-S500-NNN (L091-L093) | SPEI + CLABE + MQ async |
| ✅ DONE | Analytics / Reporting | RPT | S151 | RN-S151-421..490 (P199+P610+P612+P677) | Reportes Serie B CNBV · P199 bridge · P610 dispatcher |
| ✅ DONE | GL Adjustments & Sync | ADJ | S151 | RN-S151-710..749 (P312+P330+P360) | BC-09 · pipeline extracción/integración saldos GL · no migratable as-is |
| ✅ DONE | Teller — Gateway Online/Sucursal | TEL | S151+S500 | RN-S151-241..272 + RN-S500-143 · 33 reglas | P010 dispatcher, FACULTAD/Q015, integración MDA |
| ✅ DONE | Holdings | HLD | S151 | RN-S151-281..300 (P050) + RN-S151-311..330 (P052) · 40 reglas | TC=10 fallback CRÍTICO, LIB-L006, COMS 93 funciones, CONLI CNBV R10 |
| ✅ DONE | Statements | STA | S500+S151 | RN-S151-361..390 (P158) · 30 reglas | MOVSXCONT→S050, Y2K-2049, WFL auto-submisión, 9 archivos de salida |
| ✅ DONE | MQ / Async | MQ | S500 | RN-S500-108/109/112/114/119/136/151 · 7 reglas | TIPO-PROC 33-37, WKS-SIGUIENTE failover, WAIT 1200s, topología cross-CSI triplicada |
| ✅ DONE | Financial Servicing | FSV→INT | S500 | RN-S500-133/135 · 2 reglas (merge cap-int.md) | LIBOR flag compilación condicional + FECVENCIMIENTO exclusivo GL |
| ✅ DONE | Access Control | ACC→SEC | S500+S151 | RN-S151-244..262/272 · 8 reglas (merge cap-sec.md) | FACULTAD 1/2/3, Q015 hardcoded por pantalla, toggle HI 41/42 sin auditoría |
| ✅ DONE | Payment Schemes SPEI/CLABE | SPI→PAY | S500+S151 | RN-S500-110/111/121/163+RN-S151-263 · 5 reglas (merge cap-pay.md) | SPEI HA, topología cross-CSI, NIO SPEI, CVETRAN 4449 |
| ✅ DONE | CFR Regulatory Reporting Pipeline | CFR (T.4.1) | S151 | RN-S151-061..080 (P130) + 091..112 (P131) · 42 reglas | SETID=BNMEX hardcodeado — punto de quiebre Citi/Banamex; 7 catálogos CFR→Serie B CNBV |

---

## Dependencias entre capacidades

```
Finance (GL) [7.1.1]
  ← recibe asientos de → Payments [6.1.3] · ATM [2.2.6] · PoS [2.2.7]
  ← cuadra con → Financial Reconciliation [6.7.1] · Operational Reconciliation [6.7.2]
  → reporta a → Compliance & Regulation [6.5.2] · Analytics / Reporting [T.3.4]

Scheduling [8.1.1]
  → orquesta → Finance GL · Reconciliation · Interest & Fees · Statements · Compliance

Security [T.3.5]
  → protege datos de → Deposits [5.1.1] · Holdings [4.1.2] · Payments [6.1.3]
  → compartido con → Access Control [10.1.1]

Operational Data Stores [9.1.1]
  → sirve datos a → todas las capacidades cubiertas
```

---

*capability-map.md · v1.5 · 2026-07-16*
*Fuente: capability-model-taxonomy.md + rules-catalog/INDEX.md + kb-capa3-capacidades.md*
*COBERTURA COMPLETA: 21/21 capacidades S500+S151 documentadas · ~783/826 reglas vinculadas (94.8%) — GemCog Capa 3 cerrada*