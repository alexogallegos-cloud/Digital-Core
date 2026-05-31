# Benchmark — Blind Reconstruction · SISTEMA-CORE-UNISYS

> `[STAGE-1..4]` · `[ARTIFACT]` Benchmark of the RE methodology at scale (graph-as-data)
> Synthetic system: `Enablement/Training - Synthetic Codebase Lab/seed-corebank-unisys` (seed 2200)
> Reconstructor: `Fase 1 - Discover/Specialist - Reverse Engineering/benchmark/blind_reconstruct.py`
> Date: 2026-05-30

---

## What this is

A **blind** test of the Reverse Engineering methodology applied at real scale (830
nodes). The reconstructor receives **only the call graph** — each program `id` plus
call edges — together with the **documented naming convention** (`{DOM}{LAYER}{NNNN}`,
e.g. `DEPB0003` = deposits/BL). It does **not** see the `domain`/`access`/`intent`/`layer`
fields embedded in the JSON: those are the planted truth the Lab reserves for scoring.

It also does not receive the `copybook-usage.json` sidecar — exactly what a blind test at
scale withholds (Lab `CLAUDE.md` §10).

What the reconstructor **derives from pure topology** (algorithms over the graph):
hubs (fan-in with multiplicity), SCCs (Tarjan), WCC, reachability (dead code),
inquiry/update classification (call-closure to `UDMSIIWR`/`UDMSIIRD`) and
communities (weighted Louvain).

---

## Result

```
Dimension                             Truth   Reconstr.       Metric
--------------------------------------------------------------------------
Hubs (top-20 fan-in)                     20          20    recall 100%
  max fan-in (ULOGWRT)                  790         790        exact
Non-trivial SCCs                          9           9    recall 100%
  nodes in SCCs                         105         105        exact
WCC (components)                          5           5        exact
Unreachable (dead)                      114         114    recall 100%
  planted dead cluster (ZZDEAD*)         30          30        exact
  emergent orphans                       84          84        exact
Access: UPDATE (recall)                 461         461    recall 100%
Access: global accuracy                 830         830       100.0%
Communities (Louvain)                  8 dom         15      Q=0.384   <-
Copybook coupling                     30 cpy          0    recall 0%   <-
```

Access-classification confusion (truth → reconstructed) — perfect diagonal:

| Truth ↓ / Reconstr. → | none | read | update |
|---|---:|---:|---:|
| **none**   | 12 | 0 | 0 |
| **read**   | 0 | 357 | 0 |
| **update** | 0 | 0 | 461 |

---

## Reading — what the call graph DOES recover

- **Hubs (blast radius)** — recall 100%. `ULOGWRT` (790), `UDATECONV` (453),
  `UDMSIIWR` (329), `UDMSIIRD` (271) come out exact. Touching any of these four
  impacts hundreds of programs: they are the highest-risk node of any wave.
- **Cycles / SCCs** — 9/9, the 105 nodes in cycles identified. There is no topological
  migration order for those nodes: wave planning must treat each SCC as an indivisible
  unit (you cannot migrate `LONB0401` without migrating its 56-node cycle).
- **Dead code** — 114/114. The planted dead cluster (`ZZDEAD*`, 30 nodes) separated
  cleanly from the 84 emergent orphans. `[CRITICAL]` the 84 emergent ones are Retire
  candidates but require validation in production logs before discarding (shadow execution).
- **Inquiry vs update** — recall 100% over the 461 writers; global accuracy 100%. This is
  the headline reconstruction: it enables the CQRS split — 357 inquiry programs go to
  early, low-risk waves (read replica, cache, read-only API facade); 461 update programs
  are the late ACID core with a shadow period and regulatory validation. **No writer
  misclassified as inquiry** (the expensive false negative that corrupts data): 0.

`[OBSERVATION]` The 100% recalls on hubs/SCC/dead/access are expected and honest:
in a synthetic system the answer key is **computed from the graph** (Lab invariant §4.1),
so a faithful algorithm applying the same definition reproduces the exact truth.
The value of the benchmark is not "it scored 100" — it is **proving that the methodology,
applied with the correct definitions, recovers blast radius, cycles, dead code and the
CQRS split without seeing the answers**. Where the call graph falls short is below.

---

## Reading — the two blind spots of the call graph

This is the real lesson of the exercise.

### 1. Structural communities are NOT the bounded contexts (Q=0.384, 65% purity)

Louvain over the call graph finds **15 communities**, not the **8 real domains**.
Purity is 65%: **about 1 in 3 nodes falls into a structural community different from its
business domain**. Cause: cross-domain leakage (18% of BL→BL edges cross domain)
and the shared hubs that stitch together domains that "should" be separate. The modularity
of the real partition is only Q=0.345 — real communities, but with leakage.

`[CRITICAL]` **Finding the Strangler Fig *seams* cannot be automated with the call graph
alone.** Community detection gives a starting point, but the real seams require the
naming convention plus domain knowledge plus validation with the business SME.

### 2. Copybook coupling is invisible (recall 0%)

The call graph **cannot see** that `CB-RETCODE` is included in ~735 programs or that
`CB-ASIENTO` crosses 4 domains. Two programs that **never call each other** are coupled by
data if they share a copybook — and that coupling appears in no call edge.

`[CRITICAL]` This is the **definitive revealer** and the number one reason the Strangler Fig
fails when planned with the call graph alone: you cut a "bounded context" that looks clean
in the call graph, and it turns out it shares the account or accounting-entry layout with
three other domains. The copybook coupling layer is a **separate mandatory input** — in a
real engagement it is reconstructed by parsing the `COPY` statements in each source, not
derived from the call graph.

---

## Implication for wave planning

| Recovered finding | Migration decision |
|---|---|
| 4 UTIL hubs (fan-in 271–790) | Wave 0 / Foundation: wrap or rewrite first; everything afterward depends on them |
| 357 inquiry programs | Early, low-risk waves: CQRS read model, read replica, API facade |
| 461 update programs | Late waves: ACID core, saga/outbox, shadow period, regulatory sign-off |
| 9 SCCs (105 nodes) | Each SCC migrates as an indivisible unit; no internal order |
| Dead cluster ZZDEAD* (30) | Direct Retire |
| 84 emergent orphans | Retire candidate — validate in production logs first |
| Impure communities (35%) plus copybooks | **Do not cut seams with the call graph alone** — require the copybook layer plus business validation |

---

## Augmented reconstruction — closing the domain gap

Second run (`augmented_reconstruct.py`): it incorporates the number one signal withheld in
the blind test — **copybook coupling** (`copybook-usage.json` plus glossary). The
glossary distinguishes the 6 universal `CB-*` copybooks (cross-domain noise, ignored
for domain) from the 24 domain copybooks `{DOM}-*` (the clean signal).

### Track 1 — does the copybook recover the domains?

| Clustering signal | Communities | Purity vs 8 real domains |
|---|---:|---:|
| Call graph ALONE (baseline) | 15 | 65% |
| **Call plus domain copybooks** | 13 | **97%** |

Confirmed: the domain is recovered from the **data graph**, not the call graph. Adding
the domain copybooks as a structural signal jumps purity from 65% to 97%.

### Track 2 — Human-in-the-Loop pattern (over 786 business programs)

Fusion of 3 signals per program (naming · domain copybook · majority of call neighbors).
Confidence = degree of agreement among signals:

| Confidence | # prog | % | Action |
|---|---:|---:|---|
| **HIGH** — the 3 signals agree | 684 | 87% | auto-accept plus sampled spot-check |
| **MEDIUM** — one signal corroborates | 87 | 11% | human reviews the AI proposal |
| **LOW** — active conflict among signals | 15 | 2% | human **adjudicates** (mandatory) |

**The figure that justifies the pattern:** without the copybook signal, call-graph-only
clustering misclassifies 274/786 (35%). The naming-plus-copybook fusion auto-resolves
771/786 (98%) without intervention; only **15 programs (2%)** remain in active conflict and
escalate to the human — and **11 of those 15 carry a cross-domain copybook**
(`CB-ASIENTO`/`CB-CUENTA`/`CB-CLIENTE`), that is, they are the real seam-ambiguity zone,
not noise.

Adjudication queue example (`reconstructed/hitl-adjudicacion.csv`):

| Program | Domain (by name) | Conflict | Cross-domain copybooks |
|---|---|---|---|
| LONB0444 | loans | neighbors mostly 'deposits' | CB-ASIENTO; CB-CUENTA; CB-CLIENTE |
| GLO0056 | gl | neighbors mostly 'channels' | CB-ASIENTO; CB-CUENTA |
| DEPO0008 | deposits | neighbors mostly 'customer' | CB-ASIENTO; CB-CUENTA |

`[CRITICAL]` The human does not reconstruct from scratch: they receive the program, its
proposed domain, the conflict reason and the coupling evidence. They decide the seam and
the decision is recorded. The scarce SME time is spent on 15 cases, not 786.

---

## Reproduce

```
# (paths relative to the offering root "Mainframe Modernization/")
# Blind reconstruction (call-graph-only)
python "Fase 1 - Discover/Specialist - Reverse Engineering/benchmark/blind_reconstruct.py" \
       "Enablement/Training - Synthetic Codebase Lab/seed-corebank-unisys/graph/dependency-graph.json" \
       "Fase 1 - Discover/Specialist - Reverse Engineering/benchmark/reconstructed"

# Augmented reconstruction plus HITL gate
python "Fase 1 - Discover/Specialist - Reverse Engineering/benchmark/augmented_reconstruct.py" \
       "Enablement/Training - Synthetic Codebase Lab/seed-corebank-unisys/graph/dependency-graph.json" \
       "Enablement/Training - Synthetic Codebase Lab/seed-corebank-unisys/graph/copybook-usage.json" \
       "Enablement/Training - Synthetic Codebase Lab/seed-corebank-unisys/graph/copybook-glossary.json" \
       "Fase 1 - Discover/Specialist - Reverse Engineering/benchmark/reconstructed"
```

Output: `reconstructed/dependency-graph.reconstructed.json` — reconstructed graph in the
shared schema (with `domain` from naming, `community` from Louvain, `access` reconstructed,
`fan_in`). Viewable with the same `graph-viz/render_graph.py`.
