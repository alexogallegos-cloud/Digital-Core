# Handoff — Discover (Phase 1) → Regulatory (Phase 2)

> `[ARTIFACT]` Phase handoff specification
> **From:** Specialist · Reverse Engineering (Phase 1 · Discover) — local execution agent
> **To:** Specialist · Mainframe Modernization Regulatory (Phase 2) — external SME, invoked `[INVOKE]`
> Location of the receiver: `GenAI Projects/Delivery - SME/Framework/ITSM/GRC/Specialist - Mainframe Modernization Regulatory/`
> Sample case: `SISTEMA-CORE-UNISYS` (synthetic; regulatory context illustrative only)

---

## Purpose

Discover reconstructs *what the legacy system does*. Phase 2 Regulatory assesses *what of that is regulated and what cannot change without notice*. This handoff defines exactly which Discover artifacts the Regulatory SME needs, why, and what it returns — so the regulatory assessment is not a fresh discovery but a focused review on top of Discover's output.

`[TRIGGER]` Phase 2 fires after the Discover gate closes, with the **inventory** and the **7R decision per program** as the minimum payload.

---

## What Discover hands off (inputs to Regulatory)

| Discover artifact | Why Regulatory needs it |
|---|---|
| **7R decision per program** | Identify which programs **change the processing of critical transactions** → CNBV Circular Única de Bancos requires notifying the regulator |
| **Master Inventory** | Define the regulated scope of the system |
| **Business Rules Catalog** (regulated subset) | Rules that encode regulatory logic — interest calculation, limits, credit-bureau validation, **accounting entries (GL)** — must be preserved with equivalence ≥ 99.99% |
| **Domain Map — domains touching regulated data** | `gl` (accounting / CNBV), `customer` (PII / LFPDPPP) mark where compliance obligations sit |
| **Update programs** (the writers to the system of record) | They touch regulated transaction processing; highest regulatory scrutiny |
| **Retire list** (dead code) | Even dead code/data may carry a **regulatory retention** obligation (links to Phase 8) |
| **NFR Baseline** | The transaction SLAs relevant to regulatory commitments (availability, latency) |

### Sample-case figures (SISTEMA-CORE-UNISYS)

| Signal | Value | Regulatory relevance |
|---|---:|---|
| `gl` domain (accounting entry) | 98 programs | CNBV — accounting reconciliation |
| Update programs (system of record) | 461 | transactional processing under scrutiny |
| `customer` domain | 84 programs | PII / LFPDPPP residency |
| Retire candidates | 114 | retention check before discard |

`[NOTE]` These figures are from the synthetic sample. In a real engagement they come from the client's code and the 7R decisions signed at the Discover gate.

---

## What Regulatory does with it / returns

1. **Flags which 7R decisions require notification** to CNBV (banking) / CNSF (insurance) — any change in the processing of critical transactions.
2. **Defines the compliance gates** during the coexistence window (parallel-run with daily reconciliation signed by finance/risk).
3. **Sets data retention and residency requirements** (LFPDPPP — data in Mexican territory).
4. **Defines which migrations require sign-off** from internal audit and/or the regulator before cutover.

---

## This is a loop, not a one-way arrow

The handoff is bidirectional. Regulatory findings **feed back into the 7R decision and the wave plan**:

- A program marked **Retire** may be blocked by a retention obligation → returns to 7R.
- A transaction marked **Refactor** that changes critical processing → requires CNBV notification **before** cutover → constrains the wave plan.
- This is why Regulatory appears **twice** in the lifecycle: Phase 2 (assessment) and Phase 8 (retention / decommission).

```
Discover ──(inventory + 7R + regulated rules)──► Regulatory (Phase 2)
   ▲                                                   │
   └──────(retention vetoes · notification gates)──────┘
            feeds back into 7R + wave plan
```

---

## Regulatory anchors

- **CNBV Circular Única de Bancos** — notification when transaction processing changes (banking).
- **CNSF / LISF** — equivalent for insurance.
- **LFPDPPP** — data residency / PII (customer domain).
- **Equivalence ≥ 99.99%** — accounting reconciliation requirement; every divergence is an auditable adjustment entry.

---

## Handoff completeness checklist

The handoff is complete when Discover delivers, and the Regulatory SME acknowledges:

- [ ] Master Inventory (100% of backlog)
- [ ] 7R decision per program, signed (architect + sponsor)
- [ ] Business Rules Catalog with the regulated subset flagged
- [ ] Domain Map highlighting `gl` / `customer` / system-of-record writers
- [ ] Retire list with retention-sensitive items flagged
- [ ] NFR Baseline (transaction SLAs)
- [ ] Regulatory SME confirms scope and returns the notification/retention/sign-off requirements that feed back into the 7R and wave plan
