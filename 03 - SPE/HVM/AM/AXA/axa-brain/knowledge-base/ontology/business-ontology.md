# Ontología de Negocio — AXA México P&C Commercial Lines

## Dominios Canónicos

| Dominio | Subdominio | Responsable de negocio |
|---------|-----------|------------------------|
| **Distribución** | Canal agente, corredor, digital, bancaseguro | Comercial / Distribution |
| **Suscripción** | Análisis de riesgo, tarifación, aceptación | Underwriting |
| **Administración de Pólizas** | Emisión, endosos, renovaciones, cancelaciones | Policy Ops |
| **Siniestros** | FNOL, apertura, reservas, liquidación, cierre | Claims |
| **Finanzas y Actuaría** | Primas, comisiones, reservas técnicas, solvencia | Finance / Actuarial |
| **Reaseguro** | Tratados, cesiones, recuperos, retención | Reinsurance |
| **Regulatorio** | CNSF, Solvencia C, IFRS 17, CONDUSEF | Compliance & Legal |

---

## Entidades Canónicas

| Entidad | Tipo TOGAF | Atributos clave |
|---------|-----------|-----------------|
| `Party` | Business Actor | tipo (Tomador/Asegurado/Beneficiario/Corredor/Agente/Reasegurador), RFC, domicilio, régimen fiscal |
| `RiskObject` | Business Object | tipo (Propiedad/Flota/RC/Carga/Engineering/D&O), ubicación, valor declarado, suma asegurada |
| `Product` | Product | ramo CNSF, línea comercial, forma póliza, vigencia estándar, canal de distribución |
| `Coverage` | Business Service | tipo (básica/adicional/exclusión), suma asegurada, deducible, sublímite, coaseguro |
| `Policy` | Contract | número póliza, fechas vigencia, prima total, moneda, estado |
| `Claim` | Business Event | número siniestro, causa, fecha FNOL, reserva, estimado de pérdida, ajustador |
| `Premium` | Financial Object | prima neta, recargos, IVA, comisión agente/corredor, forma pago |
| `Reinsurance` | Contract | tratado (proporcional/excedente de pérdida), límite retención, cesión, recupero |
| `RegulatoryFiling` | Compliance Record | tipo reporte CNSF, reservas técnicas, nota técnica, estado presentación |

---

## Máquinas de Estado

```
Policy:
  QUOTE ──▶ BINDER ──▶ ISSUED ──▶ [ENDORSED] ──▶ RENEWED
                                └─────────────────────────▶ CANCELLED

Claim:
  FNOL ──▶ OPEN ──▶ [INVESTIGATION] ──▶ RESERVED ──▶ SETTLED ──▶ CLOSED
                                                  └──────────────▶ DENIED

Premium:
  BILLED ──▶ RECEIVED ──▶ POSTED
  BILLED ──▶ OVERDUE ──▶ WRITTEN_OFF

Reinsurance Cession:
  CREATED ──▶ CONFIRMED ──▶ SETTLED ──▶ CLOSED
```

---

## Eventos de Dominio

### Distribución y Póliza
- `QuoteRequested` — Solicitud de cotización recibida
- `PolicyBound` — Póliza comprometida (binder firmado)
- `PolicyIssued` — Póliza emitida y entregada
- `EndorsementApplied` — Endoso aplicado a póliza vigente
- `PolicyRenewed` — Póliza renovada para nueva vigencia
- `PolicyCancelled` — Póliza cancelada (por tomador, por mora, por compañía)

### Siniestros
- `ClaimFNOLReported` — Primer aviso de siniestro recibido
- `ClaimOpened` — Expediente de siniestro abierto
- `ClaimInvestigationStarted` — Investigación / ajuste iniciado
- `ReserveSet` — Reserva técnica establecida
- `ReserveAdjusted` — Reserva ajustada (up o down)
- `LossPaymentMade` — Pago de indemnización realizado
- `SubrogationRecovered` — Recupero por subrogación
- `ClaimClosed` — Siniestro cerrado

### Primas y Finanzas
- `PremiumBilled` — Prima facturada al tomador
- `PremiumReceived` — Prima cobrada y conciliada
- `CommissionPaid` — Comisión pagada al intermediario
- `PremiumWrittenOff` — Prima incobrable castigada

### Reaseguro
- `ReinsuranceCessionCreated` — Cesión al reasegurador creada
- `RecoveryBooked` — Recupero de reasegurador registrado
- `TreatyRenewed` — Tratado de reaseguro renovado

### Regulatorio
- `TechnicalReserveCalculated` — Reservas técnicas calculadas (cierre mensual)
- `CNSFReportFiled` — Reporte regulatorio presentado a CNSF
- `SolvencyCapitalCalculated` — Capital mínimo de solvencia calculado

---

## Jerarquía de Capacidades de Negocio

```
1. Distribución
   1.1 Gestión de Canales
       1.1.1 Canal Agente / Corredor
       1.1.2 Canal Digital
       1.1.3 Bancaseguro
   1.2 Gestión de Clientes (CRM)
   1.3 Cotización y Propuesta

2. Suscripción
   2.1 Análisis de Riesgo
   2.2 Tarifación
   2.3 Aceptación / Declive / Referral
   2.4 Gestión de Portafolio

3. Administración de Pólizas
   3.1 Emisión
   3.2 Endosos
   3.3 Renovaciones
   3.4 Cancelaciones
   3.5 Certificados y Documentación

4. Siniestros
   4.1 Recepción FNOL
   4.2 Apertura y Asignación
   4.3 Investigación y Ajuste
   4.4 Reservas
   4.5 Liquidación y Pago
   4.6 Subrogación y Recuperos
   4.7 Cierre y Análisis

5. Primas y Facturación
   5.1 Facturación
   5.2 Cobranza
   5.3 Comisiones a Intermediarios
   5.4 Conciliación

6. Reaseguro
   6.1 Diseño del Programa
   6.2 Cesiones Proporcionales
   6.3 Cesiones No Proporcionales (XL)
   6.4 Recuperos
   6.5 Contabilidad de Reaseguro

7. Finanzas y Actuaría
   7.1 Contabilidad Técnica
   7.2 Reservas Técnicas
   7.3 Resultados Técnicos
   7.4 Pricing Actuarial
   7.5 Reportes IFRS 17

8. Regulatorio y Cumplimiento
   8.1 Reportes CNSF
   8.2 Solvencia C
   8.3 Notas Técnicas
   8.4 Protección al Usuario (CONDUSEF)
   8.5 Protección de Datos (LFPDPPP)
```

---

*Última actualización: 2026-09-03 · v1.0 · AXA P&C Commercial Lines*